// Copyright 2015 The Cockroach Authors.
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
	"reflect"
	"testing"

	"github.com/ruiaylin/pgparser/settings/cluster"
	"github.com/ruiaylin/pgparser/parser"
	_ "github.com/ruiaylin/pgparser/sem/builtins"
	"github.com/ruiaylin/pgparser/ast"
	"github.com/ruiaylin/pgparser/types"
	"github.com/ruiaylin/pgparser/utils/leaktest"
	"github.com/ruiaylin/pgparser/utils/log"
	"github.com/stretchr/testify/require"
)

// TestUnresolvedNameString tests the string representation of ast.UnresolvedName and thus ast.Name.
func TestUnresolvedNameString(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	testCases := []struct {
		in, out string
	}{
		{"*", `"*"`},
		// Non-reserved keyword.
		{"DATABASE", `"DATABASE"`},
		{"dAtAbAse", `"dAtAbAse"`},
		// Reserved keyword.
		{"SELECT", `"SELECT"`},
		{"sElEcT", `"sElEcT"`},
		// Ident format: starts with [a-zA-Z_] or extended ascii,
		// and is then followed by [a-zA-Z0-9$_] or extended ascii.
		{"foo$09", "foo$09"},
		{"_Ab10", `"_Ab10"`},
		// Everything else quotes the string and escapes double quotes.
		{".foobar", `".foobar"`},
		{`".foobar"`, `""".foobar"""`},
		{`\".foobar\"`, `"\"".foobar\"""`},
	}

	for _, tc := range testCases {
		q := ast.UnresolvedName{NumParts: 1, Parts: ast.NameParts{tc.in}}
		if q.String() != tc.out {
			t.Errorf("expected q.String() == %q, got %q", tc.out, q.String())
		}
	}
}

// TestCastFromNull checks every type can be cast from NULL.
func TestCastFromNull(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	for _, typ := range types.Scalar {
		castExpr := ast.CastExpr{Expr: ast.DNull, Type: typ}
		res, err := castExpr.Eval(nil)
		require.NoError(t, err)
		require.Equal(t, ast.DNull, res)
	}
}

// TestExprString verifies that converting an expression to a string and back
// doesn't change the (normalized) expression.
func TestExprString(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	defer ast.MockNameTypes(map[string]*types.T{
		"a": types.Bool,
		"b": types.Bool,
		"c": types.Bool,
		"d": types.Bool,
		"e": types.Bool,
		"f": types.Int,
		"g": types.Int,
		"h": types.Int,
		"i": types.Int,
		"j": types.Int,
		"k": types.Int,
	})()
	testExprs := []string{
		`a AND b`,
		`a AND b OR c`,
		`(a AND b) OR c`,
		`a AND (b OR c)`,
		`a AND NOT ((b OR c) AND (d AND e))`,
		`~-f`,
		`-2*(f+3)*g`,
		`f&g<<(g+h)&i > 0 AND (g&i)+h>>(i&f) > 0`,
		`f&(g<<g+h)&i > 0 AND g&(i+h>>i)&f > 0`,
		`f = g|h`,
		`f != g|h`,
		`NOT a AND b`,
		`NOT (a AND b)`,
		`(NOT a) AND b`,
		`NOT (a = NOT b = c)`,
		`NOT NOT a = b`,
		`NOT NOT (a = b)`,
		`NOT (NOT a) < b`,
		`NOT (NOT a = b)`,
		`(NOT NOT a) >= b`,
		`(a OR (g BETWEEN (h+i) AND (j+k))) AND b`,
		`(1 >= 2) IS OF (BOOL)`,
		`(1 >= 2) = (2 IS OF (BOOL))`,
		`count(1) FILTER (WHERE true)`,
	}
	ctx := context.Background()
	for _, exprStr := range testExprs {
		expr, err := parser.ParseExpr(exprStr)
		if err != nil {
			t.Fatalf("%s: %v", exprStr, err)
		}
		typedExpr, err := ast.TypeCheck(ctx, expr, nil, types.Any)
		if err != nil {
			t.Fatalf("%s: %v", expr, err)
		}
		// str may differ than exprStr (we may be adding some parens).
		str := typedExpr.String()
		expr2, err := parser.ParseExpr(str)
		if err != nil {
			t.Fatalf("%s: %v", exprStr, err)
		}
		typedExpr2, err := ast.TypeCheck(ctx, expr2, nil, types.Any)
		if err != nil {
			t.Fatalf("%s: %v", expr2, err)
		}
		// Verify that when we stringify the expression again, the string is the
		// same. This is important because we don't want cycles of parsing and
		// printing an expression to keep adding parens.
		if str2 := typedExpr2.String(); str != str2 {
			t.Errorf("Print/parse/print cycle changes the string: `%s` vs `%s`", str, str2)
		}
		// Compare the normalized expressions.
		ctx := ast.NewTestingEvalContext(cluster.MakeTestingClusterSettings())
		defer ctx.Mon.Stop(context.Background())
		normalized, err := ctx.NormalizeExpr(typedExpr)
		if err != nil {
			t.Fatalf("%s: %v", exprStr, err)
		}
		normalized2, err := ctx.NormalizeExpr(typedExpr2)
		if err != nil {
			t.Fatalf("%s: %v", exprStr, err)
		}
		if !reflect.DeepEqual(ast.StripMemoizedFuncs(normalized), ast.StripMemoizedFuncs(normalized2)) {
			t.Errorf("normalized expressions differ\n"+
				"original:     %s\n"+
				"intermediate: %s\n"+
				"before: %#v\n"+
				"after:  %#v", exprStr, str, normalized, normalized2)
		}
	}
}

func TestStripParens(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	testExprs := []struct {
		in, out string
	}{
		{`1`, `1`},
		{`(1)`, `1`},
		{`((1))`, `1`},
		{`(1) + (2)`, `(1) + (2)`},
		{`((1) + (2))`, `(1) + (2)`},
	}
	for i, test := range testExprs {
		expr, err := parser.ParseExpr(test.in)
		if err != nil {
			t.Fatalf("%d: %v", i, err)
		}
		stripped := ast.StripParens(expr)
		if str := stripped.String(); str != test.out {
			t.Fatalf("%d: expected ast.StripParens(%s) = %s, but found %s", i, test.in, test.out, str)
		}
	}
}
