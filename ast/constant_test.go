// Copyright 2016 The Cockroach Authors.
//
// Use of this software is governed by the Business Source License
// included in the file licenses/BSL.txt.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the Apache License, Version 2.0, included in the file
// licenses/APL.txt.

package ast_test

import (
	"context"
	"go/constant"
	"go/token"
	"reflect"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/cockroachdb/apd/v2"
	"github.com/ruiaylin/pgparser/settings/cluster"
	"github.com/ruiaylin/pgparser/ast"
	"github.com/ruiaylin/pgparser/types"
	"github.com/ruiaylin/pgparser/utils/leaktest"
	"github.com/ruiaylin/pgparser/utils/log"
)

// TestNumericConstantVerifyAndResolveAvailableTypes verifies that test NumVals will
// all return expected available type sets, and that attempting to resolve the NumVals
// as each of these types will all succeed with an expected ast.Datum result.
func TestNumericConstantVerifyAndResolveAvailableTypes(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	wantInt := ast.NumValAvailInteger
	wantDecButCanBeInt := ast.NumValAvailDecimalNoFraction
	wantDec := ast.NumValAvailDecimalWithFraction

	testCases := []struct {
		str   string
		avail []*types.T
	}{
		{"1", wantInt},
		{"0", wantInt},
		{"-1", wantInt},
		{"9223372036854775807", wantInt},
		{"1.0", wantDecButCanBeInt},
		{"-1234.0000", wantDecButCanBeInt},
		{"1e10", wantDecButCanBeInt},
		{"1E10", wantDecButCanBeInt},
		{"1.1", wantDec},
		{"1e-10", wantDec},
		{"1E-10", wantDec},
		{"-1231.131", wantDec},
		{"876543234567898765436787654321", wantDec},
	}

	for i, test := range testCases {
		tok := token.INT
		if strings.ContainsAny(test.str, ".eE") {
			tok = token.FLOAT
		}

		str := test.str
		neg := false
		if str[0] == '-' {
			neg = true
			str = str[1:]
		}

		val := constant.MakeFromLiteral(str, tok, 0)
		if val.Kind() == constant.Unknown {
			t.Fatalf("%d: could not parse value string %q", i, test.str)
		}

		// Check available types.
		c := ast.NewNumVal(val, str, neg)
		avail := c.AvailableTypes()
		if !reflect.DeepEqual(avail, test.avail) {
			t.Errorf("%d: expected the available type set %v for %v, found %v",
				i, test.avail, c.ExactString(), avail)
		}

		// Make sure it can be resolved as each of those types.
		for _, availType := range avail {
			ctx := context.Background()
			semaCtx := ast.MakeSemaContext()
			if res, err := c.ResolveAsType(ctx, &semaCtx, availType); err != nil {
				t.Errorf("%d: expected resolving %v as available type %s would succeed, found %v",
					i, c.ExactString(), availType, err)
			} else {
				resErr := func(parsed, resolved interface{}) {
					t.Errorf("%d: expected resolving %v as available type %s would produce a ast.Datum"+
						" with the value %v, found %v",
						i, c, availType, parsed, resolved)
				}
				switch typ := res.(type) {
				case *ast.DInt:
					var i int64
					var err error
					if tok == token.INT {
						if i, err = strconv.ParseInt(test.str, 10, 64); err != nil {
							t.Fatal(err)
						}
					} else {
						var f float64
						if f, err = strconv.ParseFloat(test.str, 64); err != nil {
							t.Fatal(err)
						}
						i = int64(f)
					}
					if resI := int64(*typ); i != resI {
						resErr(i, resI)
					}
				case *ast.DFloat:
					f, err := strconv.ParseFloat(test.str, 64)
					if err != nil {
						t.Fatal(err)
					}
					if resF := float64(*typ); f != resF {
						resErr(f, resF)
					}
				case *ast.DDecimal:
					d := new(apd.Decimal)
					if !strings.ContainsAny(test.str, "eE") {
						if _, _, err := d.SetString(test.str); err != nil {
							t.Fatalf("could not set %q on decimal", test.str)
						}
					} else {
						_, _, err = d.SetString(test.str)
						if err != nil {
							t.Fatal(err)
						}
					}
					resD := &typ.Decimal
					if d.Cmp(resD) != 0 {
						resErr(d, resD)
					}
				}
			}
		}
	}
}

// TestStringConstantVerifyAvailableTypes verifies that test StrVals will all
// return expected available type sets, and that attempting to resolve the StrVals
// as each of these types will either succeed or return a parse error.
func TestStringConstantVerifyAvailableTypes(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	wantStringButCanBeAll := ast.StrValAvailAllParsable
	wantBytes := ast.StrValAvailBytes

	testCases := []struct {
		c     *ast.StrVal
		avail []*types.T
	}{
		{ast.NewStrVal("abc 世界"), wantStringButCanBeAll},
		{ast.NewStrVal("t"), wantStringButCanBeAll},
		{ast.NewStrVal("2010-09-28"), wantStringButCanBeAll},
		{ast.NewStrVal("2010-09-28 12:00:00.1"), wantStringButCanBeAll},
		{ast.NewStrVal("PT12H2M"), wantStringButCanBeAll},
		{ast.NewBytesStrVal("abc 世界"), wantBytes},
		{ast.NewBytesStrVal("t"), wantBytes},
		{ast.NewBytesStrVal("2010-09-28"), wantBytes},
		{ast.NewBytesStrVal("2010-09-28 12:00:00.1"), wantBytes},
		{ast.NewBytesStrVal("PT12H2M"), wantBytes},
		{ast.NewBytesStrVal(string([]byte{0xff, 0xfe, 0xfd})), wantBytes},
	}

	for i, test := range testCases {
		// Check that the expected available types are returned.
		avail := test.c.AvailableTypes()
		if !reflect.DeepEqual(avail, test.avail) {
			t.Errorf("%d: expected the available type set %v for %+v, found %v",
				i, test.avail, test.c, avail)
		}

		// Make sure it can be resolved as each of those types or throws a parsing error.
		for _, availType := range avail {

			// The enum value in c.AvailableTypes() is AnyEnum, so we will not be able to
			// resolve that exact type. In actual execution, the constant would be resolved
			// as a hydrated enum type instead.
			if availType.Family() == types.EnumFamily {
				continue
			}

			semaCtx := ast.MakeSemaContext()
			if _, err := test.c.ResolveAsType(context.Background(), &semaCtx, availType); err != nil {
				if !strings.Contains(err.Error(), "could not parse") {
					// Parsing errors are permitted for this test, as proper ast.StrVal parsing
					// is tested in TestStringConstantTypeResolution. Any other error should
					// throw a failure.
					t.Errorf("%d: expected resolving %v as available type %s would either succeed"+
						" or throw a parsing error, found %v",
						i, test.c, availType, err)
				}
			}
		}
	}
}

func mustParseDBool(t *testing.T, s string) ast.Datum {
	d, err := ast.ParseDBool(s)
	if err != nil {
		t.Fatal(err)
	}
	return d
}
func mustParseDDate(t *testing.T, s string) ast.Datum {
	d, _, err := ast.ParseDDate(nil, s)
	if err != nil {
		t.Fatal(err)
	}
	return d
}
func mustParseDTime(t *testing.T, s string) ast.Datum {
	d, _, err := ast.ParseDTime(nil, s, time.Microsecond)
	if err != nil {
		t.Fatal(err)
	}
	return d
}
func mustParseDTimeTZ(t *testing.T, s string) ast.Datum {
	d, _, err := ast.ParseDTimeTZ(nil, s, time.Microsecond)
	if err != nil {
		t.Fatal(err)
	}
	return d
}
func mustParseDTimestamp(t *testing.T, s string) ast.Datum {
	d, _, err := ast.ParseDTimestamp(nil, s, time.Millisecond)
	if err != nil {
		t.Fatal(err)
	}
	return d
}
func mustParseDTimestampTZ(t *testing.T, s string) ast.Datum {
	d, _, err := ast.ParseDTimestampTZ(nil, s, time.Millisecond)
	if err != nil {
		t.Fatal(err)
	}
	return d
}
func mustParseDInterval(t *testing.T, s string) ast.Datum {
	d, err := ast.ParseDInterval(s)
	if err != nil {
		t.Fatal(err)
	}
	return d
}
func mustParseDJSON(t *testing.T, s string) ast.Datum {
	d, err := ast.ParseDJSON(s)
	if err != nil {
		t.Fatal(err)
	}
	return d
}
func mustParseDStringArray(t *testing.T, s string) ast.Datum {
	evalContext := ast.MakeTestingEvalContext(cluster.MakeTestingClusterSettings())
	d, _, err := ast.ParseDArrayFromString(&evalContext, s, types.String)
	if err != nil {
		t.Fatal(err)
	}
	return d
}
func mustParseDIntArray(t *testing.T, s string) ast.Datum {
	evalContext := ast.MakeTestingEvalContext(cluster.MakeTestingClusterSettings())
	d, _, err := ast.ParseDArrayFromString(&evalContext, s, types.Int)
	if err != nil {
		t.Fatal(err)
	}
	return d
}
func mustParseDDecimalArray(t *testing.T, s string) ast.Datum {
	evalContext := ast.MakeTestingEvalContext(cluster.MakeTestingClusterSettings())
	d, _, err := ast.ParseDArrayFromString(&evalContext, s, types.Decimal)
	if err != nil {
		t.Fatal(err)
	}
	return d
}

var parseFuncs = map[*types.T]func(*testing.T, string) ast.Datum{
	types.String:       func(t *testing.T, s string) ast.Datum { return ast.NewDString(s) },
	types.Bytes:        func(t *testing.T, s string) ast.Datum { return ast.NewDBytes(ast.DBytes(s)) },
	types.Bool:         mustParseDBool,
	types.Date:         mustParseDDate,
	types.Time:         mustParseDTime,
	types.TimeTZ:       mustParseDTimeTZ,
	types.Timestamp:    mustParseDTimestamp,
	types.TimestampTZ:  mustParseDTimestampTZ,
	types.Interval:     mustParseDInterval,
	types.Jsonb:        mustParseDJSON,
	types.DecimalArray: mustParseDDecimalArray,
	types.IntArray:     mustParseDIntArray,
	types.StringArray:  mustParseDStringArray,
}

func typeSet(tys ...*types.T) map[*types.T]struct{} {
	set := make(map[*types.T]struct{}, len(tys))
	for _, t := range tys {
		set[t] = struct{}{}
	}
	return set
}

// TestStringConstantResolveAvailableTypes verifies that test StrVals can all be
// resolved successfully into an expected set of ast.Datum types. The test will make sure
// the correct set of ast.Datum types are resolvable, and that the resolved ast.Datum match
// the expected results which come from running the string literal through a
// corresponding parseFunc (above).
func TestStringConstantResolveAvailableTypes(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	testCases := []struct {
		c            *ast.StrVal
		parseOptions map[*types.T]struct{}
	}{
		{
			c:            ast.NewStrVal("abc 世界"),
			parseOptions: typeSet(types.String, types.Bytes),
		},
		{
			c:            ast.NewStrVal("true"),
			parseOptions: typeSet(types.String, types.Bytes, types.Bool, types.Jsonb),
		},
		{
			c:            ast.NewStrVal("2010-09-28"),
			parseOptions: typeSet(types.String, types.Bytes, types.Date, types.Timestamp, types.TimestampTZ),
		},
		{
			c:            ast.NewStrVal("2010-09-28 12:00:00.1"),
			parseOptions: typeSet(types.String, types.Bytes, types.Time, types.TimeTZ, types.Timestamp, types.TimestampTZ, types.Date),
		},
		{
			c:            ast.NewStrVal("2006-07-08T00:00:00.000000123Z"),
			parseOptions: typeSet(types.String, types.Bytes, types.Time, types.TimeTZ, types.Timestamp, types.TimestampTZ, types.Date),
		},
		{
			c:            ast.NewStrVal("PT12H2M"),
			parseOptions: typeSet(types.String, types.Bytes, types.Interval),
		},
		{
			c:            ast.NewBytesStrVal("abc 世界"),
			parseOptions: typeSet(types.String, types.Bytes),
		},
		{
			c:            ast.NewBytesStrVal("true"),
			parseOptions: typeSet(types.String, types.Bytes),
		},
		{
			c:            ast.NewBytesStrVal("2010-09-28"),
			parseOptions: typeSet(types.String, types.Bytes),
		},
		{
			c:            ast.NewBytesStrVal("2010-09-28 12:00:00.1"),
			parseOptions: typeSet(types.String, types.Bytes),
		},
		{
			c:            ast.NewBytesStrVal("PT12H2M"),
			parseOptions: typeSet(types.String, types.Bytes),
		},
		{
			c:            ast.NewStrVal(`{"a": 1}`),
			parseOptions: typeSet(types.String, types.Bytes, types.Jsonb),
		},
		{
			c:            ast.NewStrVal(`{1,2}`),
			parseOptions: typeSet(types.String, types.Bytes, types.StringArray, types.IntArray, types.DecimalArray),
		},
		{
			c:            ast.NewStrVal(`{1.5,2.0}`),
			parseOptions: typeSet(types.String, types.Bytes, types.StringArray, types.DecimalArray),
		},
		{
			c:            ast.NewStrVal(`{a,b}`),
			parseOptions: typeSet(types.String, types.Bytes, types.StringArray),
		},
		{
			c:            ast.NewBytesStrVal(string([]byte{0xff, 0xfe, 0xfd})),
			parseOptions: typeSet(types.String, types.Bytes),
		},
	}

	evalCtx := ast.NewTestingEvalContext(cluster.MakeTestingClusterSettings())
	defer evalCtx.Stop(context.Background())
	for i, test := range testCases {
		parseableCount := 0

		// Make sure it can be resolved as each of those types or throws a parsing error.
		for _, availType := range test.c.AvailableTypes() {

			// The enum value in c.AvailableTypes() is AnyEnum, so we will not be able to
			// resolve that exact type. In actual execution, the constant would be resolved
			// as a hydrated enum type instead.
			if availType.Family() == types.EnumFamily {
				continue
			}

			semaCtx := ast.MakeSemaContext()
			typedExpr, err := test.c.ResolveAsType(context.Background(), &semaCtx, availType)
			var res ast.Datum
			if err == nil {
				res, err = typedExpr.Eval(evalCtx)
			}
			if err != nil {
				if !strings.Contains(err.Error(), "could not parse") && !strings.Contains(err.Error(), "parsing") {
					// Parsing errors are permitted for this test, but the number of correctly
					// parseable types will be verified. Any other error should throw a failure.
					t.Errorf("%d: expected resolving %v as available type %s would either succeed"+
						" or throw a parsing error, found %v",
						i, test.c, availType, err)
				}
				continue
			}
			parseableCount++

			if _, isExpected := test.parseOptions[availType]; !isExpected {
				t.Errorf("%d: type %s not expected to be resolvable from the ast.StrVal %v, found %v",
					i, availType, test.c, res)
			} else {
				expectedDatum := parseFuncs[availType](t, test.c.RawString())
				if res.Compare(evalCtx, expectedDatum) != 0 {
					t.Errorf("%d: type %s expected to be resolved from the ast.StrVal %v to ast.Datum %v"+
						", found %v",
						i, availType, test.c, expectedDatum, res)
				}
			}
		}

		// Make sure the expected number of types can be resolved from the ast.StrVal.
		if expCount := len(test.parseOptions); parseableCount != expCount {
			t.Errorf("%d: expected %d successfully resolvable types for the ast.StrVal %v, found %d",
				i, expCount, test.c, parseableCount)
		}
	}
}
