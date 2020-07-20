// Copyright 2018 The Cockroach Authors.
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
	"github.com/ruiaylin/pgparser/ast"
	"github.com/ruiaylin/pgparser/types"
	"github.com/ruiaylin/pgparser/utils/leaktest"
	"github.com/ruiaylin/pgparser/utils/log"
)

func TestConstantEvalArrayComparison(t *testing.T) {
	defer leaktest.AfterTest(t)()
	defer log.Scope(t).Close(t)
	defer ast.MockNameTypes(map[string]*types.T{"a": types.MakeArray(types.Int)})()

	expr, err := parser.ParseExpr("a = ARRAY[1:::INT,2:::INT]")
	if err != nil {
		t.Fatal(err)
	}

	semaCtx := ast.MakeSemaContext()
	typedExpr, err := expr.TypeCheck(context.Background(), &semaCtx, types.Any)
	if err != nil {
		t.Fatal(err)
	}

	ctx := ast.NewTestingEvalContext(cluster.MakeTestingClusterSettings())
	defer ctx.Mon.Stop(context.Background())
	c := ast.MakeConstantEvalVisitor(ctx)
	expr, _ = ast.WalkExpr(&c, typedExpr)
	if err := c.Err(); err != nil {
		t.Fatal(err)
	}

	left := ast.ColumnItem{
		ColumnName: "a",
	}
	right := ast.DArray{
		ParamTyp:    types.Int,
		Array:       ast.Datums{ast.NewDInt(1), ast.NewDInt(2)},
		HasNonNulls: true,
	}
	expected := ast.NewTypedComparisonExpr(ast.EQ, &left, &right)
	if !reflect.DeepEqual(expr, expected) {
		t.Errorf("invalid expr '%v', expected '%v'", expr, expected)
	}
}
