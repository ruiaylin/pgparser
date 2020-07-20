// Copyright 2020 The Cockroach Authors.
//
// Use of this software is governed by the Business Source License
// included in the file licenses/BSL.txt.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the Apache License, Version 2.0, included in the file
// licenses/APL.txt.

package fmtsafe

// requireConstMsg records functions for which the last string
// argument must be a constant string.
var requireConstMsg = map[string]bool{
	"errors.New": true,

	"github.com/pkg/errors.New":  true,
	"github.com/pkg/errors.Wrap": true,

	"github.com/cockroachdb/errors.New":                        true,
	"github.com/cockroachdb/errors.Error":                      true,
	"github.com/cockroachdb/errors.NewWithDepth":               true,
	"github.com/cockroachdb/errors.WithMessage":                true,
	"github.com/cockroachdb/errors.Wrap":                       true,
	"github.com/cockroachdb/errors.WrapWithDepth":              true,
	"github.com/cockroachdb/errors.AssertionFailed":            true,
	"github.com/cockroachdb/errors.HandledWithMessage":         true,
	"github.com/cockroachdb/errors.HandledInDomainWithMessage": true,

	"github.com/ruiaylin/pgparser/pgwire/pgerror.New": true,

	"github.com/ruiaylin/pgparser/utils/errorutil/unimplemented.New":                true,
	"github.com/ruiaylin/pgparser/utils/errorutil/unimplemented.NewWithIssue":       true,
	"github.com/ruiaylin/pgparser/utils/errorutil/unimplemented.NewWithIssueDetail": true,

	"github.com/ruiaylin/pgparser/pgwire.newAdminShutdownErr": true,

	"(*github.com/ruiaylin/pgparser/pkg/parser/lexer).Error": true,

	"github.com/ruiaylin/pgparser/utils/log.Shout":     true,
	"github.com/ruiaylin/pgparser/utils/log.Info":      true,
	"github.com/ruiaylin/pgparser/utils/log.Warning":   true,
	"github.com/ruiaylin/pgparser/utils/log.Error":     true,
	"github.com/ruiaylin/pgparser/utils/log.Event":     true,
	"github.com/ruiaylin/pgparser/utils/log.VEvent":    true,
	"github.com/ruiaylin/pgparser/utils/log.VErrEvent": true,

	"(*github.com/ruiaylin/pgparser/pkg/sql.optPlanningCtx).log": true,
}

// requireConstFmt records functions for which the string arg
// before the final ellipsis must be a constant string.
var requireConstFmt = map[string]bool{
	// Logging things.
	"log.Printf":           true,
	"log.Fatalf":           true,
	"log.Panicf":           true,
	"(*log.Logger).Fatalf": true,
	"(*log.Logger).Panicf": true,
	"(*log.Logger).Printf": true,

	"github.com/ruiaylin/pgparser/utils/log.Shoutf":                true,
	"github.com/ruiaylin/pgparser/utils/log.Infof":                 true,
	"github.com/ruiaylin/pgparser/utils/log.Warningf":              true,
	"github.com/ruiaylin/pgparser/utils/log.Errorf":                true,
	"github.com/ruiaylin/pgparser/utils/log.Eventf":                true,
	"github.com/ruiaylin/pgparser/utils/log.vEventf":               true,
	"github.com/ruiaylin/pgparser/utils/log.VEventf":               true,
	"github.com/ruiaylin/pgparser/utils/log.VErrEventf":            true,
	"github.com/ruiaylin/pgparser/utils/log.InfofDepth":            true,
	"github.com/ruiaylin/pgparser/utils/log.WarningfDepth":         true,
	"github.com/ruiaylin/pgparser/utils/log.ErrorfDepth":           true,
	"github.com/ruiaylin/pgparser/utils/log.FatalfDepth":           true,
	"github.com/ruiaylin/pgparser/utils/log.VEventfDepth":          true,
	"github.com/ruiaylin/pgparser/utils/log.VErrEventfDepth":       true,
	"github.com/ruiaylin/pgparser/utils/log.ReportOrPanic":         true,
	"github.com/ruiaylin/pgparser/utils/log.MakeEntry":             true,
	"github.com/ruiaylin/pgparser/utils/log.FormatWithContextTags": true,
	"github.com/ruiaylin/pgparser/utils/log.renderArgs":            true,

	"(*github.com/ruiaylin/pgparser/utils/log.loggerT).makeStartLine":     true,
	"(*github.com/ruiaylin/pgparser/utils/log.SecondaryLogger).output":    true,
	"(*github.com/ruiaylin/pgparser/utils/log.SecondaryLogger).Logf":      true,
	"(*github.com/ruiaylin/pgparser/utils/log.SecondaryLogger).LogfDepth": true,

	"(github.com/ruiaylin/pgparser/pkg/rpc.breakerLogger).Debugf": true,
	"(github.com/ruiaylin/pgparser/pkg/rpc.breakerLogger).Infof":  true,

	"(*github.com/ruiaylin/pgparser/pkg/internal/rsg/yacc.Tree).errorf": true,

	"(github.com/ruiaylin/pgparser/pkg/storage.pebbleLogger).Infof":  true,
	"(github.com/ruiaylin/pgparser/pkg/storage.pebbleLogger).Fatalf": true,

	"(*github.com/ruiaylin/pgparser/utils/grpcutil.logger).Infof":    true,
	"(*github.com/ruiaylin/pgparser/utils/grpcutil.logger).Warningf": true,
	"(*github.com/ruiaylin/pgparser/utils/grpcutil.logger).Errorf":   true,
	"(*github.com/ruiaylin/pgparser/utils/grpcutil.logger).Fatalf":   true,

	"(*github.com/ruiaylin/pgparser/pkg/kv/kvserver.raftLogger).Debugf":   true,
	"(*github.com/ruiaylin/pgparser/pkg/kv/kvserver.raftLogger).Infof":    true,
	"(*github.com/ruiaylin/pgparser/pkg/kv/kvserver.raftLogger).Warningf": true,
	"(*github.com/ruiaylin/pgparser/pkg/kv/kvserver.raftLogger).Errorf":   true,
	"(*github.com/ruiaylin/pgparser/pkg/kv/kvserver.raftLogger).Fatalf":   true,
	"(*github.com/ruiaylin/pgparser/pkg/kv/kvserver.raftLogger).Panicf":   true,

	"github.com/ruiaylin/pgparser/pkg/kv/kvserver.makeNonDeterministicFailure":     true,
	"github.com/ruiaylin/pgparser/pkg/kv/kvserver.wrapWithNonDeterministicFailure": true,

	"(go.etcd.io/etcd/raft.Logger).Debugf":   true,
	"(go.etcd.io/etcd/raft.Logger).Infof":    true,
	"(go.etcd.io/etcd/raft.Logger).Warningf": true,
	"(go.etcd.io/etcd/raft.Logger).Errorf":   true,
	"(go.etcd.io/etcd/raft.Logger).Fatalf":   true,
	"(go.etcd.io/etcd/raft.Logger).Panicf":   true,

	"(google.golang.org/grpc/grpclog.Logger).Infof":    true,
	"(google.golang.org/grpc/grpclog.Logger).Warningf": true,
	"(google.golang.org/grpc/grpclog.Logger).Errorf":   true,

	"(github.com/cockroachdb/pebble.Logger).Infof":  true,
	"(github.com/cockroachdb/pebble.Logger).Fatalf": true,

	"(github.com/cockroachdb/circuitbreaker.Logger).Infof":  true,
	"(github.com/cockroachdb/circuitbreaker.Logger).Debugf": true,

	"github.com/ruiaylin/pgparser/opt/optgen/exprgen.errorf": true,
	"github.com/ruiaylin/pgparser/opt/optgen/exprgen.wrapf":  true,

	"(*github.com/ruiaylin/pgparser/pkg/sql.connExecutor).sessionEventf": true,

	"(*github.com/ruiaylin/pgparser/logictest.logicTest).outf":   true,
	"(*github.com/ruiaylin/pgparser/logictest.logicTest).Errorf": true,
	"(*github.com/ruiaylin/pgparser/logictest.logicTest).Fatalf": true,

	"(*github.com/ruiaylin/pgparser/pkg/server.adminServer).serverErrorf": true,
	"github.com/ruiaylin/pgparser/pkg/server.guaranteedExitFatal":         true,

	"(*github.com/ruiaylin/pgparser/pkg/ccl/changefeedccl.kafkaLogAdapter).Printf": true,

	// Error things.
	"fmt.Errorf": true,

	"github.com/pkg/errors.Errorf": true,
	"github.com/pkg/errors.Wrapf":  true,

	"github.com/cockroachdb/errors.Newf":                             true,
	"github.com/cockroachdb/errors.Errorf":                           true,
	"github.com/cockroachdb/errors.NewWithDepthf":                    true,
	"github.com/cockroachdb/errors.WithMessagef":                     true,
	"github.com/cockroachdb/errors.Wrapf":                            true,
	"github.com/cockroachdb/errors.WrapWithDepthf":                   true,
	"github.com/cockroachdb/errors.AssertionFailedf":                 true,
	"github.com/cockroachdb/errors.AssertionFailedWithDepthf":        true,
	"github.com/cockroachdb/errors.NewAssertionErrorWithWrappedErrf": true,
	"github.com/cockroachdb/errors.WithSafeDetails":                  true,

	"github.com/cockroachdb/redact.Sprintf":              true,
	"github.com/cockroachdb/redact.Fprintf":              true,
	"(github.com/cockroachdb/redact.SafePrinter).Printf": true,
	"(github.com/cockroachdb/redact.SafeWriter).Printf":  true,
	"(*github.com/cockroachdb/redact.printer).Printf":    true,

	"github.com/ruiaylin/pgparser/pkg/roachpb.NewErrorf": true,

	"github.com/ruiaylin/pgparser/pkg/ccl/importccl.makeRowErr": true,
	"github.com/ruiaylin/pgparser/pkg/ccl/importccl.wrapRowErr": true,

	"github.com/ruiaylin/pgparser/sqlbase.NewSyntaxErrorf":          true,
	"github.com/ruiaylin/pgparser/sqlbase.NewDependentObjectErrorf": true,

	"github.com/ruiaylin/pgparser/ast.newSourceNotFoundError": true,
	"github.com/ruiaylin/pgparser/ast.decorateTypeCheckError": true,

	"github.com/ruiaylin/pgparser/opt/optbuilder.unimplementedWithIssueDetailf": true,

	"(*github.com/ruiaylin/pgparser/pgwire.authPipe).Logf": true,

	"github.com/ruiaylin/pgparser/pgwire/pgerror.Newf":                true,
	"github.com/ruiaylin/pgparser/pgwire/pgerror.NewWithDepthf":       true,
	"github.com/ruiaylin/pgparser/pgwire/pgerror.DangerousStatementf": true,
	"github.com/ruiaylin/pgparser/pgwire/pgerror.Wrapf":               true,
	"github.com/ruiaylin/pgparser/pgwire/pgerror.WrapWithDepthf":      true,

	"github.com/ruiaylin/pgparser/pgwire/pgnotice.Newf":                                   true,
	"github.com/ruiaylin/pgparser/pgwire/pgnotice.NewWithSeverityf":                       true,
	"github.com/ruiaylin/pgparser/pgwire/pgwirebase.NewProtocolViolationErrorf":           true,
	"github.com/ruiaylin/pgparser/pgwire/pgwirebase.NewInvalidBinaryRepresentationErrorf": true,

	"github.com/ruiaylin/pgparser/utils/errorutil.UnexpectedWithIssueErrorf": true,

	"github.com/ruiaylin/pgparser/utils/errorutil/unimplemented.Newf":                  true,
	"github.com/ruiaylin/pgparser/utils/errorutil/unimplemented.NewWithDepthf":         true,
	"github.com/ruiaylin/pgparser/utils/errorutil/unimplemented.NewWithIssuef":         true,
	"github.com/ruiaylin/pgparser/utils/errorutil/unimplemented.NewWithIssueDetailf":   true,
	"github.com/ruiaylin/pgparser/utils/errorutil/unimplemented.unimplementedInternal": true,

	"github.com/ruiaylin/pgparser/utils/timeutil/pgdate.inputErrorf": true,

	"github.com/ruiaylin/pgparser/pkg/ccl/sqlproxyccl.newErrorf": true,
}
