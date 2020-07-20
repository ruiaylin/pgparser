// Copyright 2017 The Cockroach Authors.
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
	"fmt"
	"io/ioutil"
	"path/filepath"
	"testing"

	"github.com/ruiaylin/pgparser/pkg/internal/rsg"
	"github.com/ruiaylin/pgparser/parser"
	_ "github.com/ruiaylin/pgparser/sem/builtins"
	"github.com/ruiaylin/pgparser/ast"
	"github.com/ruiaylin/pgparser/types"
	"github.com/ruiaylin/pgparser/utils/leaktest"
	"github.com/ruiaylin/pgparser/utils/log"
)

func TestFormatStatement(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	testData := []struct {
		stmt     string
		f        ast.FmtFlags
		expected string
	}{
		{`CREATE USER foo WITH PASSWORD 'bar'`, ast.FmtSimple,
			`CREATE USER 'foo' WITH PASSWORD *****`},
		{`CREATE USER foo WITH PASSWORD 'bar'`, ast.FmtShowPasswords,
			`CREATE USER 'foo' WITH PASSWORD 'bar'`},

		{`CREATE TABLE foo (x INT8)`, ast.FmtAnonymize,
			`CREATE TABLE _ (_ INT8)`},
		{`INSERT INTO foo(x) TABLE bar`, ast.FmtAnonymize,
			`INSERT INTO _(_) TABLE _`},
		{`UPDATE foo SET x = y`, ast.FmtAnonymize,
			`UPDATE _ SET _ = _`},
		{`DELETE FROM foo`, ast.FmtAnonymize,
			`DELETE FROM _`},
		{`TRUNCATE foo`, ast.FmtAnonymize,
			`TRUNCATE TABLE _`},
		{`ALTER TABLE foo RENAME TO bar`, ast.FmtAnonymize,
			`ALTER TABLE _ RENAME TO _`},
		{`SHOW COLUMNS FROM foo`, ast.FmtAnonymize,
			`SHOW COLUMNS FROM _`},
		{`SHOW CREATE TABLE foo`, ast.FmtAnonymize,
			`SHOW CREATE _`},
		{`GRANT SELECT ON bar TO foo`, ast.FmtAnonymize,
			`GRANT SELECT ON TABLE _ TO _`},

		{`INSERT INTO a VALUES (-2, +3)`,
			ast.FmtHideConstants,
			`INSERT INTO a VALUES (_, _)`},

		{`INSERT INTO a VALUES (0), (0), (0), (0), (0), (0)`,
			ast.FmtHideConstants,
			`INSERT INTO a VALUES (_), (__more5__)`},
		{`INSERT INTO a VALUES (0, 0, 0, 0, 0, 0)`,
			ast.FmtHideConstants,
			`INSERT INTO a VALUES (_, _, __more4__)`},
		{`INSERT INTO a VALUES (ARRAY[0, 0, 0, 0, 0, 0, 0])`,
			ast.FmtHideConstants,
			`INSERT INTO a VALUES (ARRAY[_, _, __more5__])`},
		{`INSERT INTO a VALUES (ARRAY[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ` +
			`0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ` +
			`0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])`,
			ast.FmtHideConstants,
			`INSERT INTO a VALUES (ARRAY[_, _, __more30__])`},

		{`SELECT 1+COALESCE(NULL, 'a', x)-ARRAY[3.14]`, ast.FmtHideConstants,
			`SELECT (_ + COALESCE(_, _, x)) - ARRAY[_]`},

		// This here checks encodeSQLString on non-ast.DString strings also
		// calls encodeSQLString with the right formatter.
		// See TestFormatExprs below for the test on DStrings.
		{`CREATE DATABASE foo TEMPLATE = 'bar-baz'`, ast.FmtBareStrings,
			`CREATE DATABASE foo TEMPLATE = bar-baz`},
		{`CREATE DATABASE foo TEMPLATE = 'bar baz'`, ast.FmtBareStrings,
			`CREATE DATABASE foo TEMPLATE = 'bar baz'`},
		{`CREATE DATABASE foo TEMPLATE = 'bar,baz'`, ast.FmtBareStrings,
			`CREATE DATABASE foo TEMPLATE = 'bar,baz'`},
		{`CREATE DATABASE foo TEMPLATE = 'bar{baz}'`, ast.FmtBareStrings,
			`CREATE DATABASE foo TEMPLATE = 'bar{baz}'`},

		{`SET "time zone" = UTC`, ast.FmtSimple,
			`SET "time zone" = utc`},
		{`SET "time zone" = UTC`, ast.FmtBareIdentifiers,
			`SET time zone = utc`},
		{`SET "time zone" = UTC`, ast.FmtBareStrings,
			`SET "time zone" = utc`},
	}

	for i, test := range testData {
		t.Run(fmt.Sprintf("%d %s", i, test.stmt), func(t *testing.T) {
			stmt, err := parser.ParseOne(test.stmt)
			if err != nil {
				t.Fatal(err)
			}
			stmtStr := ast.AsStringWithFlags(stmt.AST, test.f)
			if stmtStr != test.expected {
				t.Fatalf("expected %q, got %q", test.expected, stmtStr)
			}
		})
	}
}

func TestFormatTableName(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	testData := []struct {
		stmt     string
		expected string
	}{
		{`CREATE TABLE foo (x INT8)`,
			`CREATE TABLE xoxoxo (x INT8)`},
		{`INSERT INTO foo(x) TABLE bar`,
			`INSERT INTO xoxoxo(x) TABLE xoxoxo`},
		{`UPDATE foo SET x = y`,
			`UPDATE xoxoxo SET x = y`},
		{`DELETE FROM foo`,
			`DELETE FROM xoxoxo`},
		{`ALTER TABLE foo RENAME TO bar`,
			`ALTER TABLE xoxoxo RENAME TO xoxoxo`},
		{`SHOW COLUMNS FROM foo`,
			`SHOW COLUMNS FROM xoxoxo`},
		{`SHOW CREATE TABLE foo`,
			`SHOW CREATE xoxoxo`},
		// TODO(knz): TRUNCATE and GRANT table names are removed by
		// ast.FmtAnonymize but not processed by table formatters.
		//
		// {`TRUNCATE foo`,
		// `TRUNCATE TABLE xoxoxo`},
		// {`GRANT SELECT ON bar TO foo`,
		// `GRANT SELECT ON xoxoxo TO foo`},
	}

	f := ast.NewFmtCtx(ast.FmtSimple)
	f.SetReformatTableNames(func(ctx *ast.FmtCtx, _ *ast.TableName) {
		ctx.WriteString("xoxoxo")
	})

	for i, test := range testData {
		t.Run(fmt.Sprintf("%d %s", i, test.stmt), func(t *testing.T) {
			stmt, err := parser.ParseOne(test.stmt)
			if err != nil {
				t.Fatal(err)
			}
			f.Reset()
			f.FormatNode(stmt.AST)
			stmtStr := f.String()
			if stmtStr != test.expected {
				t.Fatalf("expected %q, got %q", test.expected, stmtStr)
			}
		})
	}
}

func TestFormatExpr(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	testData := []struct {
		expr     string
		f        ast.FmtFlags
		expected string
	}{
		{`null`, ast.FmtShowTypes,
			`(NULL)[unknown]`},
		{`true`, ast.FmtShowTypes,
			`(true)[bool]`},
		{`123`, ast.FmtShowTypes,
			`(123)[int]`},
		{`123.456`, ast.FmtShowTypes,
			`(123.456)[decimal]`},
		{`'abc'`, ast.FmtShowTypes,
			`('abc')[string]`},
		{`b'abc'`, ast.FmtShowTypes,
			`('\x616263')[bytes]`},
		{`B'10010'`, ast.FmtShowTypes,
			`(B'10010')[varbit]`},
		{`interval '3s'`, ast.FmtShowTypes,
			`('00:00:03')[interval]`},
		{`date '2003-01-01'`, ast.FmtShowTypes,
			`('2003-01-01')[date]`},
		{`date 'today'`, ast.FmtShowTypes,
			`(('today')[string]::DATE)[date]`},
		{`timestamp '2003-01-01 00:00:00'`, ast.FmtShowTypes,
			`('2003-01-01 00:00:00+00:00')[timestamp]`},
		{`timestamp 'now'`, ast.FmtShowTypes,
			`(('now')[string]::TIMESTAMP)[timestamp]`},
		{`timestamptz '2003-01-01 00:00:00+03:00'`, ast.FmtShowTypes,
			`('2003-01-01 00:00:00+03:00')[timestamptz]`},
		{`timestamptz '2003-01-01 00:00:00'`, ast.FmtShowTypes,
			`(('2003-01-01 00:00:00')[string]::TIMESTAMPTZ)[timestamptz]`},
		{`greatest(unique_rowid(), 12)`, ast.FmtShowTypes,
			`(greatest((unique_rowid())[int], (12)[int]))[int]`},

		// While TestFormatStmt above checks StrVals, this here
		// checks DStrings.
		{`ARRAY['a','b c','d,e','f{g','h}i']`, ast.FmtBareStrings,
			`ARRAY[a, 'b c', 'd,e', 'f{g', 'h}i']`},
		// TODO(jordan): pg does *not* quote strings merely containing hex
		// escapes when included in array values. #16487
		// {`ARRAY[e'j\x10k']`, ast.FmtBareStrings,
		//	 `ARRAY[j\x10k]`},

		{`(-1):::INT`, ast.FmtParsableNumerics, "(-1)"},
		{`'NaN':::FLOAT`, ast.FmtParsableNumerics, "'NaN'"},
		{`'-Infinity':::FLOAT`, ast.FmtParsableNumerics, "'-Inf'"},
		{`'Infinity':::FLOAT`, ast.FmtParsableNumerics, "'+Inf'"},
		{`3.00:::FLOAT`, ast.FmtParsableNumerics, "3.0"},
		{`(-3.00):::FLOAT`, ast.FmtParsableNumerics, "(-3.0)"},
		{`'NaN':::DECIMAL`, ast.FmtParsableNumerics, "'NaN'"},
		{`'-Infinity':::DECIMAL`, ast.FmtParsableNumerics, "'-Infinity'"},
		{`'Infinity':::DECIMAL`, ast.FmtParsableNumerics, "'Infinity'"},
		{`3.00:::DECIMAL`, ast.FmtParsableNumerics, "3.00"},
		{`(-3.00):::DECIMAL`, ast.FmtParsableNumerics, "(-3.00)"},

		{`1`, ast.FmtParsable, "1:::INT8"},
		{`1:::INT`, ast.FmtParsable, "1:::INT8"},
		{`9223372036854775807`, ast.FmtParsable, "9223372036854775807:::INT8"},
		{`9223372036854775808`, ast.FmtParsable, "9223372036854775808:::DECIMAL"},
		{`-1`, ast.FmtParsable, "(-1):::INT8"},
		{`(-1):::INT`, ast.FmtParsable, "(-1):::INT8"},
		{`-9223372036854775808`, ast.FmtParsable, "(-9223372036854775808):::INT8"},
		{`-9223372036854775809`, ast.FmtParsable, "(-9223372036854775809):::DECIMAL"},
		{`(-92233.1):::FLOAT`, ast.FmtParsable, "(-92233.1):::FLOAT8"},
		{`92233.00:::DECIMAL`, ast.FmtParsable, "92233.00:::DECIMAL"},

		{`B'00100'`, ast.FmtParsable, "B'00100'"},

		{`unique_rowid() + 123`, ast.FmtParsable,
			`unique_rowid() + 123:::INT8`},
		{`sqrt(123.0) + 456`, ast.FmtParsable,
			`sqrt(123.0:::DECIMAL) + 456:::DECIMAL`},
		{`ROW()`, ast.FmtParsable, `()`},
		{`now() + interval '3s'`, ast.FmtSimple,
			`now() + '00:00:03'`},
		{`now() + interval '3s'`, ast.FmtParsable,
			`now():::TIMESTAMPTZ + '00:00:03':::INTERVAL`},
		{`current_date() - date '2003-01-01'`, ast.FmtSimple,
			`current_date() - '2003-01-01'`},
		{`current_date() - date '2003-01-01'`, ast.FmtParsable,
			`current_date() - '2003-01-01':::DATE`},
		{`current_date() - date 'yesterday'`, ast.FmtSimple,
			`current_date() - 'yesterday'::DATE`},
		{`now() - timestamp '2003-01-01'`, ast.FmtSimple,
			`now() - '2003-01-01 00:00:00+00:00'`},
		{`now() - timestamp '2003-01-01'`, ast.FmtParsable,
			`now():::TIMESTAMPTZ - '2003-01-01 00:00:00+00:00':::TIMESTAMP`},
		{`'+Inf':::DECIMAL + '-Inf':::DECIMAL + 'NaN':::DECIMAL`, ast.FmtParsable,
			`('Infinity':::DECIMAL + '-Infinity':::DECIMAL) + 'NaN':::DECIMAL`},
		{`'+Inf':::FLOAT8 + '-Inf':::FLOAT8 + 'NaN':::FLOAT8`, ast.FmtParsable,
			`('+Inf':::FLOAT8 + '-Inf':::FLOAT8) + 'NaN':::FLOAT8`},
		{`'12:00:00':::TIME`, ast.FmtParsable, `'12:00:00':::TIME`},
		{`'63616665-6630-3064-6465-616462656562':::UUID`, ast.FmtParsable,
			`'63616665-6630-3064-6465-616462656562':::UUID`},

		{`(123:::INT, 123:::DECIMAL)`, ast.FmtCheckEquivalence,
			`(123:::INT8, 123:::DECIMAL)`},

		{`(1, COALESCE(NULL, 123), ARRAY[45.6])`, ast.FmtHideConstants,
			`(_, COALESCE(_, _), ARRAY[_])`},
	}

	ctx := context.Background()
	for i, test := range testData {
		t.Run(fmt.Sprintf("%d %s", i, test.expr), func(t *testing.T) {
			expr, err := parser.ParseExpr(test.expr)
			if err != nil {
				t.Fatal(err)
			}
			semaContext := ast.MakeSemaContext()
			typeChecked, err := ast.TypeCheck(ctx, expr, &semaContext, types.Any)
			if err != nil {
				t.Fatal(err)
			}
			exprStr := ast.AsStringWithFlags(typeChecked, test.f)
			if exprStr != test.expected {
				t.Fatalf("expected %q, got %q", test.expected, exprStr)
			}
		})
	}
}

func TestFormatExpr2(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	// This tests formatting from an expr AST. Suitable for use if your input
	// isn't easily creatable from a string without running an Eval.
	testData := []struct {
		expr     ast.Expr
		f        ast.FmtFlags
		expected string
	}{
		{ast.NewDOidWithName(ast.DInt(10), types.RegClass, "foo"),
			ast.FmtParsable, `crdb_internal.create_regclass(10,'foo'):::REGCLASS`},
		{ast.NewDOidWithName(ast.DInt(10), types.RegProc, "foo"),
			ast.FmtParsable, `crdb_internal.create_regproc(10,'foo'):::REGPROC`},
		{ast.NewDOidWithName(ast.DInt(10), types.RegType, "foo"),
			ast.FmtParsable, `crdb_internal.create_regtype(10,'foo'):::REGTYPE`},
		{ast.NewDOidWithName(ast.DInt(10), types.RegNamespace, "foo"),
			ast.FmtParsable, `crdb_internal.create_regnamespace(10,'foo'):::REGNAMESPACE`},

		// Ensure that nulls get properly type annotated when printed in an
		// enclosing tuple that has a type for their position within the tuple.
		{ast.NewDTuple(
			types.MakeTuple([]*types.T{types.Int, types.String}),
			ast.DNull, ast.NewDString("foo")),
			ast.FmtParsable,
			`(NULL::INT8, 'foo':::STRING)`,
		},
		{ast.NewDTuple(
			types.MakeTuple([]*types.T{types.Unknown, types.String}),
			ast.DNull, ast.NewDString("foo")),
			ast.FmtParsable,
			`(NULL, 'foo':::STRING)`,
		},
		{&ast.DArray{
			ParamTyp: types.Int,
			Array:    ast.Datums{ast.DNull, ast.DNull},
			HasNulls: true,
		},
			ast.FmtParsable,
			`ARRAY[NULL,NULL]:::INT8[]`,
		},

		// Ensure that nulls get properly type annotated when printed in an
	}

	ctx := context.Background()
	for i, test := range testData {
		t.Run(fmt.Sprintf("%d %s", i, test.expr), func(t *testing.T) {
			semaCtx := ast.MakeSemaContext()
			typeChecked, err := ast.TypeCheck(ctx, test.expr, &semaCtx, types.Any)
			if err != nil {
				t.Fatal(err)
			}
			exprStr := ast.AsStringWithFlags(typeChecked, test.f)
			if exprStr != test.expected {
				t.Fatalf("expected %q, got %q", test.expected, exprStr)
			}
		})
	}
}

func TestFormatPgwireText(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	testData := []struct {
		expr     string
		expected string
	}{
		{`true`, `t`},
		{`false`, `f`},
		{`ROW(1)`, `(1)`},
		{`ROW(1, NULL)`, `(1,)`},
		{`ROW(1, true, 3)`, `(1,t,3)`},
		{`ROW(1, (2, 3))`, `(1,"(2,3)")`},
		{`ROW(1, (2, 'a b'))`, `(1,"(2,""a b"")")`},
		{`ROW(1, (2, 'a"b'))`, `(1,"(2,""a""""b"")")`},
		{`ROW(1, 2, ARRAY[1,2,3])`, `(1,2,"{1,2,3}")`},
		{`ROW(1, 2, ARRAY[1,NULL,3])`, `(1,2,"{1,NULL,3}")`},
		{`ROW(1, 2, ARRAY['a','b','c'])`, `(1,2,"{a,b,c}")`},
		{`ROW(1, 2, ARRAY[true,false,true])`, `(1,2,"{t,f,t}")`},
		{`ARRAY[(1,2),(3,4)]`, `{"(1,2)","(3,4)"}`},
		{`ARRAY[(false,'a'),(true,'b')]`, `{"(f,a)","(t,b)"}`},
		{`ARRAY[(1,ARRAY[2,NULL])]`, `{"(1,\"{2,NULL}\")"}`},
		{`ARRAY[(1,(1,2)),(2,(3,4))]`, `{"(1,\"(1,2)\")","(2,\"(3,4)\")"}`},

		{`(((1, 'a b', 3), (4, 'c d'), ROW(6)), (7, 8), ROW('e f'))`,
			`("(""(1,""""a b"""",3)"",""(4,""""c d"""")"",""(6)"")","(7,8)","(""e f"")")`},

		{`(((1, '2', 3), (4, '5'), ROW(6)), (7, 8), ROW('9'))`,
			`("(""(1,2,3)"",""(4,5)"",""(6)"")","(7,8)","(9)")`},

		{`ARRAY[('a b',ARRAY['c d','e f']), ('g h',ARRAY['i j','k l'])]`,
			`{"(\"a b\",\"{\"\"c d\"\",\"\"e f\"\"}\")","(\"g h\",\"{\"\"i j\"\",\"\"k l\"\"}\")"}`},

		{`ARRAY[('1',ARRAY['2','3']), ('4',ARRAY['5','6'])]`,
			`{"(1,\"{2,3}\")","(4,\"{5,6}\")"}`},

		{`ARRAY[e'\U00002001☃']`, `{ ☃}`},
	}
	ctx := context.Background()
	var evalCtx ast.EvalContext
	for i, test := range testData {
		t.Run(fmt.Sprintf("%d %s", i, test.expr), func(t *testing.T) {
			expr, err := parser.ParseExpr(test.expr)
			if err != nil {
				t.Fatal(err)
			}
			semaCtx := ast.MakeSemaContext()
			typeChecked, err := ast.TypeCheck(ctx, expr, &semaCtx, types.Any)
			if err != nil {
				t.Fatal(err)
			}
			typeChecked, err = evalCtx.NormalizeExpr(typeChecked)
			if err != nil {
				t.Fatal(err)
			}
			exprStr := ast.AsStringWithFlags(typeChecked, ast.FmtPgwireText)
			if exprStr != test.expected {
				t.Fatalf("expected %s, got %s", test.expected, exprStr)
			}
		})
	}
}

// BenchmarkFormatRandomStatements measures the time needed to format
// 1000 random statements.
func BenchmarkFormatRandomStatements(b *testing.B) {
	// Generate a bunch of random statements.
	yBytes, err := ioutil.ReadFile(filepath.Join("..", "..", "parser", "sql.y"))
	if err != nil {
		b.Fatalf("error reading grammar: %v", err)
	}
	// Use a constant seed so multiple runs are consistent.
	const seed = 1134
	r, err := rsg.NewRSG(seed, string(yBytes), false)
	if err != nil {
		b.Fatalf("error instantiating RSG: %v", err)
	}
	strs := make([]string, 1000)
	stmts := make([]ast.Statement, 1000)
	for i := 0; i < 1000; {
		rdm := r.Generate("stmt", 20)
		stmt, err := parser.ParseOne(rdm)
		if err != nil {
			// Some statements (e.g. those containing error terminals) do
			// not parse.  It's all right. Just ignore this and continue
			// until we have all we want.
			continue
		}
		strs[i] = rdm
		stmts[i] = stmt.AST
		i++
	}

	// Benchmark the parses.
	b.Run("parse", func(b *testing.B) {
		for i := 0; i < b.N; i++ {
			for _, sql := range strs {
				_, err := parser.ParseOne(sql)
				if err != nil {
					b.Fatal(err)
				}
			}
		}
	})

	// Benchmark the formats.
	b.Run("format", func(b *testing.B) {
		for i := 0; i < b.N; i++ {
			for i, stmt := range stmts {
				f := ast.NewFmtCtx(ast.FmtSimple)
				f.FormatNode(stmt)
				strs[i] = f.CloseAndGetString()
			}
		}
	})
}
