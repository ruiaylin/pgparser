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
	"testing"

	"github.com/ruiaylin/pgparser/parser"
	_ "github.com/ruiaylin/pgparser/sem/builtins"
	"github.com/ruiaylin/pgparser/ast"
	"github.com/ruiaylin/pgparser/sessiondata"
	"github.com/ruiaylin/pgparser/testutils"
	"github.com/ruiaylin/pgparser/utils/leaktest"
	"github.com/ruiaylin/pgparser/utils/log"
)

func TestResolveFunction(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	testCases := []struct {
		in, out string
		err     string
	}{
		{`count`, `count`, ``},
		{`pg_catalog.pg_typeof`, `pg_typeof`, ``},

		{`foo`, ``, `unknown function: foo`},
		{`""`, ``, `invalid function name: ""`},
	}

	searchPath := sessiondata.MakeSearchPath([]string{"pg_catalog"})
	for _, tc := range testCases {
		stmt, err := parser.ParseOne("SELECT " + tc.in + "(1)")
		if err != nil {
			t.Fatalf("%s: %v", tc.in, err)
		}
		f, ok := stmt.AST.(*ast.Select).Select.(*ast.SelectClause).Exprs[0].Expr.(*ast.FuncExpr)
		if !ok {
			t.Fatalf("%s does not parse to a ast.FuncExpr", tc.in)
		}
		q := f.Func
		_, err = q.Resolve(searchPath)
		if tc.err != "" {
			if !testutils.IsError(err, tc.err) {
				t.Fatalf("%s: expected %s, but found %v", tc.in, tc.err, err)
			}
			continue
		}
		if err != nil {
			t.Fatalf("%s: expected success, but found %v", tc.in, err)
		}
		if out := q.String(); tc.out != out {
			t.Errorf("%s: expected %s, but found %s", tc.in, tc.out, out)
		}
	}
}
