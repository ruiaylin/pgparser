// Copyright 2020 The Cockroach Authors.
//
// Use of this software is governed by the Business Source License
// included in the file licenses/BSL.txt.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the Apache License, Version 2.0, included in the file
// licenses/APL.txt.

package roleoption

import (
	"strings"

	"crypto/sha256"
	
	"golang.org/x/crypto/bcrypt"
	"github.com/ruiaylin/pgparser/pgwire/pgcode"
	"github.com/ruiaylin/pgparser/pgwire/pgerror"
	"github.com/ruiaylin/pgparser/sqltelemetry"
	"github.com/cockroachdb/errors"
)

//go:generate stringer -type=Option
var BcryptCost = bcrypt.DefaultCost


// ErrEmptyPassword indicates that an empty password was attempted to be set.
var ErrEmptyPassword = errors.New("empty passwords are not permitted")


// Option defines a role option. This is output by the parser
type Option uint32

// RoleOption represents an Option with a value.
type RoleOption struct {
	Option
	HasValue bool
	// Need to resolve value in Exec for the case of placeholders.
	Value func() (bool, string, error)
}

// KindList of role options.
const (
	_ Option = iota
	CREATEROLE
	NOCREATEROLE
	PASSWORD
	LOGIN
	NOLOGIN
	VALIDUNTIL
)

// toSQLStmts is a map of Kind -> SQL statement string for applying the
// option to the role.
var toSQLStmts = map[Option]string{
	CREATEROLE:   `UPSERT INTO system.role_options (username, option) VALUES ($1, 'CREATEROLE')`,
	NOCREATEROLE: `DELETE FROM system.role_options WHERE username = $1 AND option = 'CREATEROLE'`,
	LOGIN:        `DELETE FROM system.role_options WHERE username = $1 AND option = 'NOLOGIN'`,
	NOLOGIN:      `UPSERT INTO system.role_options (username, option) VALUES ($1, 'NOLOGIN')`,
	VALIDUNTIL:   `UPSERT INTO system.role_options (username, option, value) VALUES ($1, 'VALID UNTIL', $2::timestamptz::string)`,
}

// Mask returns the bitmask for a given role option.
func (o Option) Mask() uint32 {
	return 1 << o
}

// ByName is a map of string -> kind value.
var ByName = map[string]Option{
	"CREATEROLE":   CREATEROLE,
	"NOCREATEROLE": NOCREATEROLE,
	"PASSWORD":     PASSWORD,
	"LOGIN":        LOGIN,
	"NOLOGIN":      NOLOGIN,
	"VALID_UNTIL":  VALIDUNTIL,
}

// ToOption takes a string and returns the corresponding Option.
func ToOption(str string) (Option, error) {
	ret := ByName[strings.ToUpper(str)]
	if ret == 0 {
		return 0, pgerror.New(pgcode.Syntax, "option does not exist")
	}

	return ret, nil
}

// List is a list of role options.
type List []RoleOption

// GetSQLStmts returns a map of SQL stmts to apply each role option.
// Maps stmts to values (value of the role option).
func (rol List) GetSQLStmts(op string) (map[string]func() (bool, string, error), error) {
	if len(rol) <= 0 {
		return nil, nil
	}

	stmts := make(map[string]func() (bool, string, error), len(rol))

	err := rol.CheckRoleOptionConflicts()
	if err != nil {
		return stmts, err
	}

	for _, ro := range rol {
		sqltelemetry.IncIAMOptionCounter(
			op,
			strings.ToLower(ro.Option.String()),
		)
		// Skip PASSWORD option.
		// Since PASSWORD still resides in system.users, we handle setting PASSWORD
		// outside of this set stmt.
		// TODO(richardjcai): migrate password to system.role_options
		if ro.Option == PASSWORD {
			continue
		}

		stmt := toSQLStmts[ro.Option]
		if ro.HasValue {
			stmts[stmt] = ro.Value
		} else {
			stmts[stmt] = nil
		}
	}

	return stmts, nil
}

// ToBitField returns the bitfield representation of
// a list of role options.
func (rol List) ToBitField() (uint32, error) {
	var ret uint32
	for _, p := range rol {
		if ret&p.Option.Mask() != 0 {
			return 0, pgerror.Newf(pgcode.Syntax, "redundant role options")
		}
		ret |= p.Option.Mask()
	}
	return ret, nil
}

// Contains returns true if List contains option, false otherwise.
func (rol List) Contains(p Option) bool {
	for _, ro := range rol {
		if ro.Option == p {
			return true
		}
	}

	return false
}

// CheckRoleOptionConflicts returns an error if two or more options conflict with each other.
func (rol List) CheckRoleOptionConflicts() error {
	roleOptionBits, err := rol.ToBitField()

	if err != nil {
		return err
	}

	if (roleOptionBits&CREATEROLE.Mask() != 0 &&
		roleOptionBits&NOCREATEROLE.Mask() != 0) ||
		(roleOptionBits&LOGIN.Mask() != 0 &&
			roleOptionBits&NOLOGIN.Mask() != 0) {
		return pgerror.Newf(pgcode.Syntax, "conflicting role options")
	}
	return nil
}

// GetHashedPassword returns the value of the password after hashing it.
// Returns error if no password option is found or if password is invalid.
func (rol List) GetHashedPassword() ([]byte, error) {
	var hashedPassword []byte
	for _, ro := range rol {
		if ro.Option == PASSWORD {
			isNull, password, err := ro.Value()
			if isNull {
				// Use empty byte array for hashedPassword.
				return hashedPassword, nil
			}
			if err != nil {
				return hashedPassword, err
			}
			if password == "" {
				return hashedPassword, ErrEmptyPassword
			}
			hashedPassword, err = HashPassword(password)
			if err != nil {
				return hashedPassword, err
			}

			return hashedPassword, nil
		}
	}
	// Password option not found.
	return hashedPassword, errors.New("password not found in role options")
}


var sha256NewSum = sha256.New().Sum(nil)


// TODO(mjibson): properly apply SHA-256 to the password. The current code
// erroneously appends the SHA-256 of the empty hash to the unhashed password
// instead of actually hashing the password. Fixing this requires a somewhat
// complicated backwards compatibility dance. This is not a security issue
// because the round of SHA-256 was only intended to achieve a fixed-length
// input to bcrypt; it is bcrypt that provides the cryptographic security, and
// bcrypt is correctly applied.
func appendEmptySha256(password string) []byte {
	// In the past we incorrectly called the hash.Hash.Sum method. That
	// method uses its argument as a place to put the current hash:
	// it does not add its argument to the current hash. Thus, using
	// h.Sum([]byte(password))) is the equivalent to the below append.
	return append([]byte(password), sha256NewSum...)
}


// HashPassword takes a raw password and returns a bcrypt hashed password.
func HashPassword(password string) ([]byte, error) {
	return bcrypt.GenerateFromPassword(appendEmptySha256(password), BcryptCost)
}