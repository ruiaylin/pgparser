# pgparser
A SQL Parser for postgres using golang from Cockroachdb 


## How to use it

### 1. import the parser pkg

```
import "github.com/ruiaylin/pgparser"
```
### 2. demo

> this demo show how to parse a alter statement， and get the main info of it

```
package main

import (
	"fmt"
	"log"
	"reflect"

	"github.com/ruiaylin/pgparser/ast"
	parser "github.com/ruiaylin/pgparser/parser"
	"github.com/ruiaylin/pgparser/types"
)

func main() {

	fmtStr := ast.NewFmtCtx(ast.FmtSimple)
	defer fmtStr.Close()
	postgres := "alter table ttt.tables add column3 varchar(10);"
	stmts, err := parser.Parse(postgres)
	if err != nil {
		log.Println("err = ", err)
	}
	stmt := stmts[0]
	switch node := stmt.AST.(type) {
	case *ast.AlterTable:
		node.Table.Format(fmtStr)
		// get table information from sql
		fmt.Println("table =  ", fmtStr.String())
		fmtStr.Reset()
		// Format implements the NodeFormatter interface.
		fmtStr.FormatNode(&node.Cmds)
		fmt.Println("sub_command =  ", fmtStr.String())
		fmtStr.Reset()
		for _, cmd := range node.Cmds {
			switch cmdType := cmd.(type) {
			case *ast.AlterTableAddColumn:
				fmt.Println("SUB CMD: ADD_COL")
				cmdType.ColumnDef.Format(fmtStr)
				fmt.Println("Col =  ", fmtStr.String())
				fmtStr.Reset()
				fmt.Println("col = ", cmdType.ColumnDef.Name)
				fmt.Println("col type = ", cmdType.ColumnDef.Type)
				fmt.Println("col full type  = ", cmdType.ColumnDef.Type.SQLString())
				tt := cmdType.ColumnDef.Type
				switch t := tt.(type) {
				case *types.T:
					fmt.Println("types length = ", t.InternalType.Width)
				}
			}
		}
	default:
		fmt.Println("stream: " + reflect.TypeOf(node).String() + " " + node.String() + "\n")
	}

}
```

> The ouput: 

```
table =   ttt.tables
sub_command =    ADD COLUMN column3 VARCHAR(10)
SUB CMD: ADD_COL
Col =   column3 VARCHAR(10)
col =  column3
col type =  varchar
col full type  =  VARCHAR(10)
types length =  10
```
