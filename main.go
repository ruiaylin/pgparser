package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"net/http"
	_ "net/http/pprof"
	"os"
	"reflect"
	"strconv"

	"github.com/ruiaylin/pgparser/ast"
	parser "github.com/ruiaylin/pgparser/parser"

	"github.com/cockroachdb/errors"
)

func initPprofMonitor() error {
	pPort := 8082

	var err error
	addr := ":" + strconv.Itoa(pPort)

	fmt.Println("jajajja")
	go func() {
		err = http.ListenAndServe(addr, nil)
		if err != nil {
			fmt.Printf("funcRetErr=http.ListenAndServe||err=%s\n", err.Error())
		}
	}()

	return err
}

func main() {

	// 启动 pprof 监控
	initPprofMonitor()

	sql := `select name from t1 full join t2 on t1.num = t2.num; alter table ttt add column1 varchar(10);
	select name2 from t1 full join t2 on t1.num = t2.num; 
	alter table ttt add column2 varchar(10);
	select name3 from t1 full join t2 on t1.num = t2.num; 
	alter table ttt add column3 varchar(10);
	select name4 from t1 full join t2 on t1.num = t2.num; 
	alter table ttt add column4 varchar(10);
	select name4 from t1 full join t2 on t1.num = t2.num; 
	-- this is a tseting
	alter /* +hind(tt) */table ttt1 add column4 varchar(110);
	`
	stmts1, err := parser.Parse(sql)
	if err != nil {
		log.Println("err = ", err)
	}
	fmt.Println(stmts1)
	for _, stmt := range stmts1 {
		switch node := stmt.AST.(type) {
		default:
			fmt.Println(reflect.TypeOf(node), node)
		}
	}

	// scaner
	data := []byte(sql)
	if pos, ok := parser.SplitFirstStatement(string(sql)); ok {
		fmt.Println(pos)
		fmt.Println(string(data[:pos]))
	}
	fmt.Println(len(sql))
	last := 0
	for {
		pos, ok := parser.SplitFirstStatement(sql[last:])
		if !ok {
			break
		}
		fmt.Println(string(sql[last : last+pos]))
		last += pos
	}

	//
	file, err := os.Open("/Users/linruichao/data.sql")
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	defer file.Close()

	f, err := os.OpenFile("/Users/linruichao/Development/go/pgparser/data-out.sql", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0777)
	if err != nil {
		fmt.Println("os OpenFile error: ", err)
		return
	}
	defer f.Close()

	rd := bufio.NewReader(file)
	stream := NewStream(rd)

	for {
		stmt, err := stream.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			fmt.Println(err)
		}
		switch node := stmt.(type) {
		default:
			f.WriteString("stream: " + reflect.TypeOf(node).String() + " " + node.String() + "\n")
			// fmt.Println("stream: ", reflect.TypeOf(node), node)
		}
	}
}

// Stream streams an io.Reader into tree.Statements.
type Stream struct {
	scan *bufio.Scanner
}

// NewStream returns a new Stream to read from r.
func NewStream(r io.Reader) *Stream {
	const defaultMax = 1024 * 1024 * 32
	s := bufio.NewScanner(r)
	s.Buffer(make([]byte, 0, defaultMax), defaultMax)
	p := &Stream{scan: s}
	s.Split(splitSQLSemicolon)
	return p
}

// splitSQLSemicolon is a bufio.SplitFunc that splits on SQL semicolon tokens.
func splitSQLSemicolon(data []byte, atEOF bool) (advance int, token []byte, err error) {
	if atEOF && len(data) == 0 {
		return 0, nil, nil
	}

	if pos, ok := parser.SplitFirstStatement(data); ok {

		return pos, data[:pos], nil
	}
	// If we're at EOF, we have a final, non-terminated line. Return it.
	if atEOF {
		return len(data), data, nil
	}
	// Request more data.
	return 0, nil, nil
}

// Next returns the next statement, or io.EOF if complete.
func (s *Stream) Next() (ast.Statement, error) {
	for s.scan.Scan() {
		t := s.scan.Text()
		// fmt.Println("origin sql = ", strings.Trim(t, "\n"))
		stmts, err := parser.Parse(t)
		if err != nil {
			return nil, err
		}
		switch len(stmts) {
		case 0:
			// Got whitespace or comments; try again.
		case 1:
			return stmts[0].AST, nil
		default:
			return nil, errors.Errorf("unexpected: got %d statements", len(stmts))
		}
	}
	if err := s.scan.Err(); err != nil {
		if errors.Is(err, bufio.ErrTooLong) {
			err = errors.HandledWithMessage(err, "line too long")
		}
		return nil, err
	}
	return nil, io.EOF
}
