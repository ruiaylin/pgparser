





















%{
package parser

import (
    "fmt"
    "strings"

    "go/constant"

    "github.com/ruiaylin/pgparser/types/geo/geopb"
    "github.com/ruiaylin/pgparser/lex"
    "github.com/ruiaylin/pgparser/privilege"
    "github.com/ruiaylin/pgparser/roleoption"
    "github.com/ruiaylin/pgparser/ast"
    "github.com/ruiaylin/pgparser/types"
)


const MaxUint = ^uint(0)

const MaxInt = int(MaxUint >> 1)

func unimplemented(sqllex sqlLexer, feature string) int {
    sqllex.(*lexer).Unimplemented(feature)
    return 1
}

func purposelyUnimplemented(sqllex sqlLexer, feature string, reason string) int {
    sqllex.(*lexer).PurposelyUnimplemented(feature, reason)
    return 1
}

func setErr(sqllex sqlLexer, err error) int {
    sqllex.(*lexer).setErr(err)
    return 1
}

func unimplementedWithIssue(sqllex sqlLexer, issue int) int {
    sqllex.(*lexer).UnimplementedWithIssue(issue)
    return 1
}

func unimplementedWithIssueDetail(sqllex sqlLexer, issue int, detail string) int {
    sqllex.(*lexer).UnimplementedWithIssueDetail(issue, detail)
    return 1
}
%}

%{



















type sqlSymUnion struct {
    val interface{}
}























func (u *sqlSymUnion) numVal() *ast.NumVal {
    return u.val.(*ast.NumVal)
}
func (u *sqlSymUnion) strVal() *ast.StrVal {
    if stmt, ok := u.val.(*ast.StrVal); ok {
        return stmt
    }
    return nil
}
func (u *sqlSymUnion) placeholder() *ast.Placeholder {
    return u.val.(*ast.Placeholder)
}
func (u *sqlSymUnion) auditMode() ast.AuditMode {
    return u.val.(ast.AuditMode)
}
func (u *sqlSymUnion) bool() bool {
    return u.val.(bool)
}
func (u *sqlSymUnion) strPtr() *string {
    return u.val.(*string)
}
func (u *sqlSymUnion) strs() []string {
    return u.val.([]string)
}
func (u *sqlSymUnion) newTableIndexName() *ast.TableIndexName {
    tn := u.val.(ast.TableIndexName)
    return &tn
}
func (u *sqlSymUnion) tableIndexName() ast.TableIndexName {
    return u.val.(ast.TableIndexName)
}
func (u *sqlSymUnion) newTableIndexNames() ast.TableIndexNames {
    return u.val.(ast.TableIndexNames)
}
func (u *sqlSymUnion) shardedIndexDef() *ast.ShardedIndexDef {
  return u.val.(*ast.ShardedIndexDef)
}
func (u *sqlSymUnion) nameList() ast.NameList {
    return u.val.(ast.NameList)
}
func (u *sqlSymUnion) unresolvedName() *ast.UnresolvedName {
    return u.val.(*ast.UnresolvedName)
}
func (u *sqlSymUnion) unresolvedObjectName() *ast.UnresolvedObjectName {
    return u.val.(*ast.UnresolvedObjectName)
}
func (u *sqlSymUnion) unresolvedObjectNames() []*ast.UnresolvedObjectName {
    return u.val.([]*ast.UnresolvedObjectName)
}
func (u *sqlSymUnion) functionReference() ast.FunctionReference {
    return u.val.(ast.FunctionReference)
}
func (u *sqlSymUnion) tablePatterns() ast.TablePatterns {
    return u.val.(ast.TablePatterns)
}
func (u *sqlSymUnion) tableNames() ast.TableNames {
    return u.val.(ast.TableNames)
}
func (u *sqlSymUnion) indexFlags() *ast.IndexFlags {
    return u.val.(*ast.IndexFlags)
}
func (u *sqlSymUnion) arraySubscript() *ast.ArraySubscript {
    return u.val.(*ast.ArraySubscript)
}
func (u *sqlSymUnion) arraySubscripts() ast.ArraySubscripts {
    if as, ok := u.val.(ast.ArraySubscripts); ok {
        return as
    }
    return nil
}
func (u *sqlSymUnion) stmt() ast.Statement {
    if stmt, ok := u.val.(ast.Statement); ok {
        return stmt
    }
    return nil
}
func (u *sqlSymUnion) cte() *ast.CTE {
    if cte, ok := u.val.(*ast.CTE); ok {
        return cte
    }
    return nil
}
func (u *sqlSymUnion) ctes() []*ast.CTE {
    return u.val.([]*ast.CTE)
}
func (u *sqlSymUnion) with() *ast.With {
    if with, ok := u.val.(*ast.With); ok {
        return with
    }
    return nil
}
func (u *sqlSymUnion) slct() *ast.Select {
    return u.val.(*ast.Select)
}
func (u *sqlSymUnion) selectStmt() ast.SelectStatement {
    return u.val.(ast.SelectStatement)
}
func (u *sqlSymUnion) colDef() *ast.ColumnTableDef {
    return u.val.(*ast.ColumnTableDef)
}
func (u *sqlSymUnion) constraintDef() ast.ConstraintTableDef {
    return u.val.(ast.ConstraintTableDef)
}
func (u *sqlSymUnion) tblDef() ast.TableDef {
    return u.val.(ast.TableDef)
}
func (u *sqlSymUnion) tblDefs() ast.TableDefs {
    return u.val.(ast.TableDefs)
}
func (u *sqlSymUnion) likeTableOption() ast.LikeTableOption {
    return u.val.(ast.LikeTableOption)
}
func (u *sqlSymUnion) likeTableOptionList() []ast.LikeTableOption {
    return u.val.([]ast.LikeTableOption)
}
func (u *sqlSymUnion) colQual() ast.NamedColumnQualification {
    return u.val.(ast.NamedColumnQualification)
}
func (u *sqlSymUnion) colQualElem() ast.ColumnQualification {
    return u.val.(ast.ColumnQualification)
}
func (u *sqlSymUnion) colQuals() []ast.NamedColumnQualification {
    return u.val.([]ast.NamedColumnQualification)
}
func (u *sqlSymUnion) storageParam() ast.StorageParam {
    return u.val.(ast.StorageParam)
}
func (u *sqlSymUnion) storageParams() []ast.StorageParam {
    if params, ok := u.val.([]ast.StorageParam); ok {
        return params
    }
    return nil
}
func (u *sqlSymUnion) persistenceType() bool {
 return u.val.(bool)
}
func (u *sqlSymUnion) colType() *types.T {
    if colType, ok := u.val.(*types.T); ok && colType != nil {
        return colType
    }
    return nil
}
func (u *sqlSymUnion) tableRefCols() []ast.ColumnID {
    if refCols, ok := u.val.([]ast.ColumnID); ok {
        return refCols
    }
    return nil
}
func (u *sqlSymUnion) colTypes() []*types.T {
    return u.val.([]*types.T)
}
func (u *sqlSymUnion) int32() int32 {
    return u.val.(int32)
}
func (u *sqlSymUnion) int64() int64 {
    return u.val.(int64)
}
func (u *sqlSymUnion) seqOpt() ast.SequenceOption {
    return u.val.(ast.SequenceOption)
}
func (u *sqlSymUnion) seqOpts() []ast.SequenceOption {
    return u.val.([]ast.SequenceOption)
}
func (u *sqlSymUnion) expr() ast.Expr {
    if expr, ok := u.val.(ast.Expr); ok {
        return expr
    }
    return nil
}
func (u *sqlSymUnion) exprs() ast.Exprs {
    return u.val.(ast.Exprs)
}
func (u *sqlSymUnion) selExpr() ast.SelectExpr {
    return u.val.(ast.SelectExpr)
}
func (u *sqlSymUnion) selExprs() ast.SelectExprs {
    return u.val.(ast.SelectExprs)
}
func (u *sqlSymUnion) retClause() ast.ReturningClause {
        return u.val.(ast.ReturningClause)
}
func (u *sqlSymUnion) aliasClause() ast.AliasClause {
    return u.val.(ast.AliasClause)
}
func (u *sqlSymUnion) asOfClause() ast.AsOfClause {
    return u.val.(ast.AsOfClause)
}
func (u *sqlSymUnion) tblExpr() ast.TableExpr {
    return u.val.(ast.TableExpr)
}
func (u *sqlSymUnion) tblExprs() ast.TableExprs {
    return u.val.(ast.TableExprs)
}
func (u *sqlSymUnion) from() ast.From {
    return u.val.(ast.From)
}
func (u *sqlSymUnion) int32s() []int32 {
    return u.val.([]int32)
}
func (u *sqlSymUnion) joinCond() ast.JoinCond {
    return u.val.(ast.JoinCond)
}
func (u *sqlSymUnion) when() *ast.When {
    return u.val.(*ast.When)
}
func (u *sqlSymUnion) whens() []*ast.When {
    return u.val.([]*ast.When)
}
func (u *sqlSymUnion) lockingClause() ast.LockingClause {
    return u.val.(ast.LockingClause)
}
func (u *sqlSymUnion) lockingItem() *ast.LockingItem {
    return u.val.(*ast.LockingItem)
}
func (u *sqlSymUnion) lockingStrength() ast.LockingStrength {
    return u.val.(ast.LockingStrength)
}
func (u *sqlSymUnion) lockingWaitPolicy() ast.LockingWaitPolicy {
    return u.val.(ast.LockingWaitPolicy)
}
func (u *sqlSymUnion) updateExpr() *ast.UpdateExpr {
    return u.val.(*ast.UpdateExpr)
}
func (u *sqlSymUnion) updateExprs() ast.UpdateExprs {
    return u.val.(ast.UpdateExprs)
}
func (u *sqlSymUnion) limit() *ast.Limit {
    return u.val.(*ast.Limit)
}
func (u *sqlSymUnion) targetList() ast.TargetList {
    return u.val.(ast.TargetList)
}
func (u *sqlSymUnion) targetListPtr() *ast.TargetList {
    return u.val.(*ast.TargetList)
}
func (u *sqlSymUnion) privilegeType() privilege.Kind {
    return u.val.(privilege.Kind)
}
func (u *sqlSymUnion) privilegeList() privilege.List {
    return u.val.(privilege.List)
}
func (u *sqlSymUnion) onConflict() *ast.OnConflict {
    return u.val.(*ast.OnConflict)
}
func (u *sqlSymUnion) orderBy() ast.OrderBy {
    return u.val.(ast.OrderBy)
}
func (u *sqlSymUnion) order() *ast.Order {
    return u.val.(*ast.Order)
}
func (u *sqlSymUnion) orders() []*ast.Order {
    return u.val.([]*ast.Order)
}
func (u *sqlSymUnion) groupBy() ast.GroupBy {
    return u.val.(ast.GroupBy)
}
func (u *sqlSymUnion) windowFrame() *ast.WindowFrame {
    return u.val.(*ast.WindowFrame)
}
func (u *sqlSymUnion) windowFrameBounds() ast.WindowFrameBounds {
    return u.val.(ast.WindowFrameBounds)
}
func (u *sqlSymUnion) windowFrameBound() *ast.WindowFrameBound {
    return u.val.(*ast.WindowFrameBound)
}
func (u *sqlSymUnion) windowFrameExclusion() ast.WindowFrameExclusion {
    return u.val.(ast.WindowFrameExclusion)
}
func (u *sqlSymUnion) distinctOn() ast.DistinctOn {
    return u.val.(ast.DistinctOn)
}
func (u *sqlSymUnion) dir() ast.Direction {
    return u.val.(ast.Direction)
}
func (u *sqlSymUnion) nullsOrder() ast.NullsOrder {
    return u.val.(ast.NullsOrder)
}
func (u *sqlSymUnion) alterTableCmd() ast.AlterTableCmd {
    return u.val.(ast.AlterTableCmd)
}
func (u *sqlSymUnion) alterTableCmds() ast.AlterTableCmds {
    return u.val.(ast.AlterTableCmds)
}
func (u *sqlSymUnion) alterIndexCmd() ast.AlterIndexCmd {
    return u.val.(ast.AlterIndexCmd)
}
func (u *sqlSymUnion) alterIndexCmds() ast.AlterIndexCmds {
    return u.val.(ast.AlterIndexCmds)
}
func (u *sqlSymUnion) isoLevel() ast.IsolationLevel {
    return u.val.(ast.IsolationLevel)
}
func (u *sqlSymUnion) userPriority() ast.UserPriority {
    return u.val.(ast.UserPriority)
}
func (u *sqlSymUnion) readWriteMode() ast.ReadWriteMode {
    return u.val.(ast.ReadWriteMode)
}
func (u *sqlSymUnion) idxElem() ast.IndexElem {
    return u.val.(ast.IndexElem)
}
func (u *sqlSymUnion) idxElems() ast.IndexElemList {
    return u.val.(ast.IndexElemList)
}
func (u *sqlSymUnion) dropBehavior() ast.DropBehavior {
    return u.val.(ast.DropBehavior)
}
func (u *sqlSymUnion) validationBehavior() ast.ValidationBehavior {
    return u.val.(ast.ValidationBehavior)
}
func (u *sqlSymUnion) interleave() *ast.InterleaveDef {
    return u.val.(*ast.InterleaveDef)
}
func (u *sqlSymUnion) partitionBy() *ast.PartitionBy {
    return u.val.(*ast.PartitionBy)
}
func (u *sqlSymUnion) createTableOnCommitSetting() ast.CreateTableOnCommitSetting {
    return u.val.(ast.CreateTableOnCommitSetting)
}
func (u *sqlSymUnion) listPartition() ast.ListPartition {
    return u.val.(ast.ListPartition)
}
func (u *sqlSymUnion) listPartitions() []ast.ListPartition {
    return u.val.([]ast.ListPartition)
}
func (u *sqlSymUnion) rangePartition() ast.RangePartition {
    return u.val.(ast.RangePartition)
}
func (u *sqlSymUnion) rangePartitions() []ast.RangePartition {
    return u.val.([]ast.RangePartition)
}
func (u *sqlSymUnion) setZoneConfig() *ast.SetZoneConfig {
    return u.val.(*ast.SetZoneConfig)
}
func (u *sqlSymUnion) tuples() []*ast.Tuple {
    return u.val.([]*ast.Tuple)
}
func (u *sqlSymUnion) tuple() *ast.Tuple {
    return u.val.(*ast.Tuple)
}
func (u *sqlSymUnion) windowDef() *ast.WindowDef {
    return u.val.(*ast.WindowDef)
}
func (u *sqlSymUnion) window() ast.Window {
    return u.val.(ast.Window)
}
func (u *sqlSymUnion) op() ast.Operator {
    return u.val.(ast.Operator)
}
func (u *sqlSymUnion) cmpOp() ast.ComparisonOperator {
    return u.val.(ast.ComparisonOperator)
}
func (u *sqlSymUnion) intervalTypeMetadata() types.IntervalTypeMetadata {
    return u.val.(types.IntervalTypeMetadata)
}
func (u *sqlSymUnion) kvOption() ast.KVOption {
    return u.val.(ast.KVOption)
}
func (u *sqlSymUnion) kvOptions() []ast.KVOption {
    if colType, ok := u.val.([]ast.KVOption); ok {
        return colType
    }
    return nil
}
func (u *sqlSymUnion) backupOptions() *ast.BackupOptions {
  return u.val.(*ast.BackupOptions)
}
func (u *sqlSymUnion) transactionModes() ast.TransactionModes {
    return u.val.(ast.TransactionModes)
}
func (u *sqlSymUnion) compositeKeyMatchMethod() ast.CompositeKeyMatchMethod {
  return u.val.(ast.CompositeKeyMatchMethod)
}
func (u *sqlSymUnion) referenceAction() ast.ReferenceAction {
    return u.val.(ast.ReferenceAction)
}
func (u *sqlSymUnion) referenceActions() ast.ReferenceActions {
    return u.val.(ast.ReferenceActions)
}
func (u *sqlSymUnion) createStatsOptions() *ast.CreateStatsOptions {
    return u.val.(*ast.CreateStatsOptions)
}
func (u *sqlSymUnion) scrubOptions() ast.ScrubOptions {
    return u.val.(ast.ScrubOptions)
}
func (u *sqlSymUnion) scrubOption() ast.ScrubOption {
    return u.val.(ast.ScrubOption)
}
func (u *sqlSymUnion) resolvableFuncRefFromName() ast.ResolvableFunctionReference {
    return ast.ResolvableFunctionReference{FunctionReference: u.unresolvedName()}
}
func (u *sqlSymUnion) rowsFromExpr() *ast.RowsFromExpr {
    return u.val.(*ast.RowsFromExpr)
}
func (u *sqlSymUnion) partitionedBackup() ast.PartitionedBackup {
    return u.val.(ast.PartitionedBackup)
}
func (u *sqlSymUnion) partitionedBackups() []ast.PartitionedBackup {
    return u.val.([]ast.PartitionedBackup)
}
func (u *sqlSymUnion) fullBackupClause() *ast.FullBackupClause {
    return u.val.(*ast.FullBackupClause)
}
func (u *sqlSymUnion) geoShapeType() geopb.ShapeType {
  return u.val.(geopb.ShapeType)
}
func newNameFromStr(s string) *ast.Name {
    return (*ast.Name)(&s)
}
func (u *sqlSymUnion) typeReference() ast.ResolvableTypeReference {
    return u.val.(ast.ResolvableTypeReference)
}
func (u *sqlSymUnion) typeReferences() []ast.ResolvableTypeReference {
    return u.val.([]ast.ResolvableTypeReference)
}
func (u *sqlSymUnion) alterTypeAddValuePlacement() *ast.AlterTypeAddValuePlacement {
    return u.val.(*ast.AlterTypeAddValuePlacement)
}
%}





%token <str> IDENT SCONST BCONST BITCONST
%token <union>   ICONST FCONST
%token <union>   PLACEHOLDER
%token <str> TYPECAST TYPEANNOTATE DOT_DOT
%token <str> LESS_EQUALS GREATER_EQUALS NOT_EQUALS
%token <str> NOT_REGMATCH REGIMATCH NOT_REGIMATCH
%token <str> ERROR






%token <str> ABORT ACTION ADD ADMIN AFTER AGGREGATE
%token <str> ALL ALTER ALWAYS ANALYSE ANALYZE AND AND_AND ANY ANNOTATE_TYPE ARRAY AS ASC
%token <str> ASYMMETRIC AT ATTRIBUTE AUTHORIZATION AUTOMATIC

%token <str> BACKUP BEFORE BEGIN BETWEEN BIGINT BIGSERIAL BIT
%token <str> BUCKET_COUNT
%token <str> BOOLEAN BOTH BUNDLE BY

%token <str> CACHE CANCEL CASCADE CASE CAST CBRT CHANGEFEED CHAR
%token <str> CHARACTER CHARACTERISTICS CHECK CLOSE
%token <str> CLUSTER COALESCE COLLATE COLLATION COLUMN COLUMNS COMMENT COMMENTS COMMIT
%token <str> COMMITTED COMPACT COMPLETE CONCAT CONCURRENTLY CONFIGURATION CONFIGURATIONS CONFIGURE
%token <str> CONFLICT CONSTRAINT CONSTRAINTS CONTAINS CONVERSION COPY COVERING CREATE CREATEROLE
%token <str> CROSS CUBE CURRENT CURRENT_CATALOG CURRENT_DATE CURRENT_SCHEMA
%token <str> CURRENT_ROLE CURRENT_TIME CURRENT_TIMESTAMP
%token <str> CURRENT_USER CYCLE

%token <str> DATA DATABASE DATABASES DATE DAY DEC DECIMAL DEFAULT DEFAULTS
%token <str> DEALLOCATE DECLARE DEFERRABLE DEFERRED DELETE DESC DETACHED
%token <str> DISCARD DISTINCT DO DOMAIN DOUBLE DROP

%token <str> ELSE ENCODING ENCRYPTION_PASSPHRASE END ENUM ESCAPE EXCEPT EXCLUDE EXCLUDING
%token <str> EXISTS EXECUTE EXECUTION EXPERIMENTAL
%token <str> EXPERIMENTAL_FINGERPRINTS EXPERIMENTAL_REPLICA
%token <str> EXPERIMENTAL_AUDIT
%token <str> EXPIRATION EXPLAIN EXPORT EXTENSION EXTRACT EXTRACT_DURATION

%token <str> FALSE FAMILY FETCH FETCHVAL FETCHTEXT FETCHVAL_PATH FETCHTEXT_PATH
%token <str> FILES FILTER
%token <str> FIRST FLOAT FLOAT4 FLOAT8 FLOORDIV FOLLOWING FOR FORCE_INDEX FOREIGN FROM FULL FUNCTION

%token <str> GENERATED GEOGRAPHY GEOMETRY GEOMETRYCOLLECTION
%token <str> GLOBAL GRANT GRANTS GREATEST GROUP GROUPING GROUPS

%token <str> HAVING HASH HIGH HISTOGRAM HOUR

%token <str> IDENTITY
%token <str> IF IFERROR IFNULL IGNORE_FOREIGN_KEYS ILIKE IMMEDIATE IMPORT IN INCLUDE INCLUDING INCREMENT INCREMENTAL
%token <str> INET INET_CONTAINED_BY_OR_EQUALS
%token <str> INET_CONTAINS_OR_EQUALS INDEX INDEXES INJECT INTERLEAVE INITIALLY
%token <str> INNER INSERT INT INTEGER
%token <str> INTERSECT INTERVAL INTO INVERTED IS ISERROR ISNULL ISOLATION

%token <str> JOB JOBS JOIN JSON JSONB JSON_SOME_EXISTS JSON_ALL_EXISTS

%token <str> KEY KEYS KV

%token <str> LANGUAGE LAST LATERAL LC_CTYPE LC_COLLATE
%token <str> LEADING LEASE LEAST LEFT LESS LEVEL LIKE LIMIT LINESTRING LIST LOCAL
%token <str> LOCALTIME LOCALTIMESTAMP LOCKED LOGIN LOOKUP LOW LSHIFT

%token <str> MATCH MATERIALIZED MERGE MINVALUE MAXVALUE MINUTE MONTH
%token <str> MULTILINESTRING MULTIPOINT MULTIPOLYGON

%token <str> NAN NAME NAMES NATURAL NEVER NEXT NO NOCREATEROLE NOLOGIN NO_INDEX_JOIN
%token <str> NONE NORMAL NOT NOTHING NOTNULL NOWAIT NULL NULLIF NULLS NUMERIC

%token <str> OF OFF OFFSET OID OIDS OIDVECTOR ON ONLY OPT OPTION OPTIONS OR
%token <str> ORDER ORDINALITY OTHERS OUT OUTER OVER OVERLAPS OVERLAY OWNED OWNER OPERATOR

%token <str> PARENT PARTIAL PARTITION PARTITIONS PASSWORD PAUSE PHYSICAL PLACING
%token <str> PLAN PLANS POINT POLYGON POSITION PRECEDING PRECISION PREPARE PRESERVE PRIMARY PRIORITY
%token <str> PROCEDURAL PUBLIC PUBLICATION

%token <str> QUERIES QUERY

%token <str> RANGE RANGES READ REAL RECURSIVE RECURRING REF REFERENCES
%token <str> REGCLASS REGPROC REGPROCEDURE REGNAMESPACE REGTYPE REINDEX
%token <str> REMOVE_PATH RENAME REPEATABLE REPLACE
%token <str> RELEASE RESET RESTORE RESTRICT RESUME RETURNING RETRY REVISION_HISTORY REVOKE RIGHT
%token <str> ROLE ROLES ROLLBACK ROLLUP ROW ROWS RSHIFT RULE

%token <str> SAVEPOINT SCATTER SCHEDULE SCHEMA SCHEMAS SCRUB SEARCH SECOND SELECT SEQUENCE SEQUENCES
%token <str> SERIALIZABLE SERVER SESSION SESSIONS SESSION_USER SET SETTING SETTINGS
%token <str> SHARE SHOW SIMILAR SIMPLE SKIP SMALLINT SMALLSERIAL SNAPSHOT SOME SPLIT SQL

%token <str> START STATISTICS STATUS STDIN STRICT STRING STORAGE STORE STORED STORING SUBSTRING
%token <str> SYMMETRIC SYNTAX SYSTEM SQRT SUBSCRIPTION

%token <str> TABLE TABLES TEMP TEMPLATE TEMPORARY TENANT TESTING_RELOCATE EXPERIMENTAL_RELOCATE TEXT THEN
%token <str> TIES TIME TIMETZ TIMESTAMP TIMESTAMPTZ TO THROTTLING TRAILING TRACE TRANSACTION TREAT TRIGGER TRIM TRUE
%token <str> TRUNCATE TRUSTED TYPE
%token <str> TRACING

%token <str> UNBOUNDED UNCOMMITTED UNION UNIQUE UNKNOWN UNLOGGED UNSPLIT
%token <str> UPDATE UPSERT UNTIL USE USER USERS USING UUID

%token <str> VALID VALIDATE VALUE VALUES VARBIT VARCHAR VARIADIC VIEW VARYING VIRTUAL

%token <str> WHEN WHERE WINDOW WITH WITHIN WITHOUT WORK WRITE

%token <str> YEAR

%token <str> ZONE











%token NOT_LA WITH_LA AS_LA GENERATED_ALWAYS

%union {
  id    int32
  pos   int32
  str   string
  union sqlSymUnion
}

%type <union>   stmt_block
%type <union>   stmt

%type <union>   alter_stmt
%type <union>   alter_ddl_stmt
%type <union>   alter_table_stmt
%type <union>   alter_index_stmt
%type <union>   alter_view_stmt
%type <union>   alter_sequence_stmt
%type <union>   alter_database_stmt
%type <union>   alter_range_stmt
%type <union>   alter_partition_stmt
%type <union>   alter_role_stmt
%type <union>   alter_type_stmt


%type <union>   alter_zone_range_stmt


%type <union>   alter_onetable_stmt
%type <union>   alter_split_stmt
%type <union>   alter_unsplit_stmt
%type <union>   alter_rename_table_stmt
%type <union>   alter_scatter_stmt
%type <union>   alter_relocate_stmt
%type <union>   alter_relocate_lease_stmt
%type <union>   alter_zone_table_stmt


%type <union>   alter_zone_partition_stmt


%type <union>   alter_rename_database_stmt
%type <union>   alter_zone_database_stmt


%type <union>   alter_oneindex_stmt
%type <union>   alter_scatter_index_stmt
%type <union>   alter_split_index_stmt
%type <union>   alter_unsplit_index_stmt
%type <union>   alter_rename_index_stmt
%type <union>   alter_relocate_index_stmt
%type <union>   alter_relocate_index_lease_stmt
%type <union>   alter_zone_index_stmt


%type <union>   alter_rename_view_stmt


%type <union>   alter_rename_sequence_stmt
%type <union>   alter_sequence_options_stmt

%type <union>   backup_stmt
%type <union>   begin_stmt

%type <union>   cancel_stmt
%type <union>   cancel_jobs_stmt
%type <union>   cancel_queries_stmt
%type <union>   cancel_sessions_stmt


%type <union>   scrub_stmt
%type <union>   scrub_database_stmt
%type <union>   scrub_table_stmt
%type <union>   opt_scrub_options_clause
%type <union>   scrub_option_list
%type <union>   scrub_option

%type <union>   comment_stmt
%type <union>   commit_stmt
%type <union>   copy_from_stmt

%type <union>   create_stmt
%type <union>   create_changefeed_stmt
%type <union>   create_ddl_stmt
%type <union>   create_database_stmt
%type <union>   create_index_stmt
%type <union>   create_role_stmt
%type <union>   create_schedule_for_backup_stmt
%type <union>   create_schema_stmt
%type <union>   create_table_stmt
%type <union>   create_table_as_stmt
%type <union>   create_view_stmt
%type <union>   create_sequence_stmt

%type <union>   create_stats_stmt
%type <union>   opt_create_stats_options
%type <union>   create_stats_option_list
%type <union>   create_stats_option

%type <union>   create_type_stmt
%type <union>   delete_stmt
%type <union>   discard_stmt

%type <union>   drop_stmt
%type <union>   drop_ddl_stmt
%type <union>   drop_database_stmt
%type <union>   drop_index_stmt
%type <union>   drop_role_stmt
%type <union>   drop_table_stmt
%type <union>   drop_type_stmt
%type <union>   drop_view_stmt
%type <union>   drop_sequence_stmt

%type <union>   analyze_stmt
%type <union>   explain_stmt
%type <union>   prepare_stmt
%type <union>   preparable_stmt
%type <union>   row_source_extension_stmt
%type <union>   export_stmt
%type <union>   execute_stmt
%type <union>   deallocate_stmt
%type <union>   grant_stmt
%type <union>   insert_stmt
%type <union>   import_stmt
%type <union>   pause_stmt
%type <union>   release_stmt
%type <union>   reset_stmt reset_session_stmt reset_csetting_stmt
%type <union>   resume_stmt
%type <union>   restore_stmt
%type <union>   partitioned_backup
%type <union>   partitioned_backup_list
%type <union>   revoke_stmt
%type <union>   select_stmt
%type <union>   abort_stmt
%type <union>   rollback_stmt
%type <union>   savepoint_stmt

%type <union>   preparable_set_stmt nonpreparable_set_stmt
%type <union>   set_session_stmt
%type <union>   set_csetting_stmt
%type <union>   set_transaction_stmt
%type <union>   set_exprs_internal
%type <union>   generic_set
%type <union>   set_rest_more
%type <union>   set_names

%type <union>   show_stmt
%type <union>   show_backup_stmt
%type <union>   show_columns_stmt
%type <union>   show_constraints_stmt
%type <union>   show_create_stmt
%type <union>   show_csettings_stmt
%type <union>   show_databases_stmt
%type <union>   show_fingerprints_stmt
%type <union>   show_grants_stmt
%type <union>   show_histogram_stmt
%type <union>   show_indexes_stmt
%type <union>   show_partitions_stmt
%type <union>   show_jobs_stmt
%type <union>   show_queries_stmt
%type <union>   show_ranges_stmt
%type <union>   show_range_for_row_stmt
%type <union>   show_roles_stmt
%type <union>   show_schemas_stmt
%type <union>   show_sequences_stmt
%type <union>   show_session_stmt
%type <union>   show_sessions_stmt
%type <union>   show_savepoint_stmt
%type <union>   show_stats_stmt
%type <union>   show_syntax_stmt
%type <union>   show_last_query_stats_stmt
%type <union>   show_tables_stmt
%type <union>   show_trace_stmt
%type <union>   show_transaction_stmt
%type <union>   show_users_stmt
%type <union>   show_zone_stmt

%type <str> session_var
%type <union>   comment_text

%type <union>   transaction_stmt
%type <union>   truncate_stmt
%type <union>   update_stmt
%type <union>   upsert_stmt
%type <union>   use_stmt

%type <union>   close_cursor_stmt
%type <union>   declare_cursor_stmt
%type <union>   reindex_stmt

%type <union>   opt_incremental
%type <union>   kv_option
%type <union>   kv_option_list opt_with_options var_set_list opt_with_schedule_options
%type <union>   opt_with_backup_options backup_options backup_options_list
%type <str> import_format
%type <union>   storage_parameter
%type <union>   storage_parameter_list opt_table_with

%type <union>   select_no_parens
%type <union>   select_clause select_with_parens simple_select values_clause table_clause simple_select_clause
%type <union>   for_locking_clause opt_for_locking_clause for_locking_items
%type <union>   for_locking_item
%type <union>   for_locking_strength
%type <union>   opt_nowait_or_skip
%type <union>   set_operation

%type <union>   alter_column_default
%type <union>   opt_asc_desc
%type <union>   opt_nulls_order

%type <union>   alter_table_cmd
%type <union>   alter_table_cmds
%type <union>   alter_index_cmd
%type <union>   alter_index_cmds

%type <union>   opt_drop_behavior
%type <union>   opt_interleave_drop_behavior

%type <union>   opt_validate_behavior

%type <str> opt_template_clause opt_encoding_clause opt_lc_collate_clause opt_lc_ctype_clause

%type <union>   transaction_iso_level
%type <union>   transaction_user_priority
%type <union>   transaction_read_mode

%type <str> name opt_name opt_name_parens
%type <str> privilege savepoint_name
%type <union>   role_option password_clause valid_until_clause
%type <union>   subquery_op
%type <union>   func_name func_name_no_crdb_extra
%type <str> opt_collate

%type <str> cursor_name database_name index_name opt_index_name column_name insert_column_item statistics_name window_name
%type <str> family_name opt_family_name table_alias_name constraint_name target_name zone_name partition_name collation_name
%type <str> db_object_name_component
%type <union>   table_name standalone_index_name sequence_name type_name view_name db_object_name simple_db_object_name complex_db_object_name
%type <union>   type_name_list
%type <str> schema_name
%type <union>   table_pattern complex_table_pattern
%type <union>   column_path prefixed_column_path column_path_with_star
%type <union>   insert_target create_stats_target analyze_target

%type <union>   table_index_name
%type <union>   table_index_name_list

%type <union>   math_op

%type <union>   iso_level
%type <union>   user_priority

%type <union>   opt_table_elem_list table_elem_list create_as_opt_col_list create_as_table_defs
%type <union>   like_table_option_list
%type <union>   like_table_option
%type <union>   opt_create_table_on_commit
%type <union>   opt_interleave
%type <union>   opt_partition_by partition_by
%type <str> partition opt_partition
%type <union>   list_partition
%type <union>   list_partitions
%type <union>   range_partition
%type <union>   range_partitions
%type <empty> opt_all_clause
%type <union>   distinct_clause
%type <union>   distinct_on_clause
%type <union>   opt_column_list insert_column_list opt_stats_columns
%type <union>   sort_clause single_sort_clause opt_sort_clause
%type <union>   sortby_list
%type <union>   index_params create_as_params
%type <union>   name_list privilege_list
%type <union>   opt_array_bounds
%type <union>   from_clause
%type <union>   from_list rowsfrom_list opt_from_list
%type <union>   table_pattern_list single_table_pattern_list
%type <union>   table_name_list opt_locked_rels
%type <union>   expr_list opt_expr_list tuple1_ambiguous_values tuple1_unambiguous_values
%type <union>   expr_tuple1_ambiguous expr_tuple_unambiguous
%type <union>   attrs
%type <union>   target_list
%type <union>   set_clause_list
%type <union>   set_clause multiple_set_clause
%type <union>   array_subscripts
%type <union>   group_clause
%type <union>   select_limit opt_select_limit
%type <union>   relation_expr_list
%type <union>   returning_clause
%type <empty> opt_using_clause

%type <union>   sequence_option_list opt_sequence_option_list
%type <union>   sequence_option_elem

%type <union>   all_or_distinct
%type <union>   with_comment
%type <empty> join_outer
%type <union>   join_qual
%type <str> join_type
%type <str> opt_join_hint

%type <union>   extract_list
%type <union>   overlay_list
%type <union>   position_list
%type <union>   substr_list
%type <union>   trim_list
%type <union>   execute_param_clause
%type <union>   opt_interval_qualifier interval_qualifier interval_second
%type <union>   overlay_placing

%type <union>   opt_unique opt_concurrently opt_cluster
%type <union>   opt_using_gin_btree

%type <union>   limit_clause offset_clause opt_limit_clause
%type <union>   select_fetch_first_value
%type <empty> row_or_rows
%type <empty> first_or_next

%type <union>   insert_rest
%type <union>   opt_conf_expr opt_col_def_list
%type <union>   on_conflict

%type <union>   begin_transaction
%type <union>   transaction_mode_list transaction_mode

%type <union>   opt_hash_sharded
%type <union>   opt_storing
%type <union>   column_def
%type <union>   table_elem
%type <union>   where_clause opt_where_clause
%type <union>   array_subscript
%type <union>   opt_slice_bound
%type <union>   opt_index_flags
%type <union>   index_flags_param
%type <union>   index_flags_param_list
%type <union>   a_expr b_expr c_expr d_expr typed_literal
%type <union>   substr_from substr_for
%type <union>   in_expr
%type <union>   having_clause
%type <union>   array_expr
%type <union>   interval_value
%type <union>   type_list prep_type_clause
%type <union>   array_expr_list
%type <union>   row labeled_row
%type <union>   case_expr case_arg case_default
%type <union>   when_clause
%type <union>   when_clause_list
%type <union>   sub_type
%type <union>   numeric_only
%type <union>   alias_clause opt_alias_clause
%type <union>   opt_ordinality opt_compact
%type <union>   sortby
%type <union>   index_elem create_as_param
%type <union>   table_ref numeric_table_ref func_table
%type <union>   rowsfrom_list
%type <union>   rowsfrom_item
%type <union>   joined_table
%type <union>   relation_expr
%type <union>   table_expr_opt_alias_idx table_name_opt_idx
%type <union>   target_elem
%type <union>   single_set_clause
%type <union>   as_of_clause opt_as_of_clause
%type <union>   opt_changefeed_sink

%type <str> explain_option_name
%type <union>   explain_option_list opt_enum_val_list enum_val_list

%type <union>   typename simple_typename cast_target
%type <union>   const_typename
%type <union>   opt_add_val_placement
%type <union>   opt_timezone
%type <union>   numeric opt_numeric_modifiers
%type <union>   opt_float
%type <union>   character_with_length character_without_length
%type <union>   const_datetime interval_type
%type <union>   bit_with_length bit_without_length
%type <union>   character_base
%type <union>   geo_shape_type
%type <union>   const_geo
%type <str> extract_arg
%type <union>   opt_varying

%type <union>   signed_iconst only_signed_iconst
%type <union>   signed_fconst only_signed_fconst
%type <union>   iconst32
%type <union>   signed_iconst64
%type <union>   iconst64
%type <union>   var_value
%type <union>   var_list
%type <union>   var_name
%type <str> unrestricted_name type_function_name type_function_name_no_crdb_extra
%type <str> non_reserved_word
%type <str> non_reserved_word_or_sconst
%type <union>   zone_value
%type <union>   string_or_placeholder
%type <union>   string_or_placeholder_list

%type <str> unreserved_keyword type_func_name_keyword type_func_name_no_crdb_extra_keyword type_func_name_crdb_extra_keyword
%type <str> col_name_keyword reserved_keyword cockroachdb_extra_reserved_keyword extra_var_value

%type <union>   complex_type_name
%type <str> general_type_name

%type <union>   table_constraint constraint_elem create_as_constraint_def create_as_constraint_elem
%type <union>   index_def
%type <union>   family_def
%type <union>   col_qual_list create_as_col_qual_list
%type <union>   col_qualification create_as_col_qualification
%type <union>   col_qualification_elem create_as_col_qualification_elem
%type <union>   key_match
%type <union>   reference_actions
%type <union>   reference_action reference_on_delete reference_on_update

%type <union>   func_application func_expr_common_subexpr special_function
%type <union>   func_expr func_expr_windowless
%type <empty> opt_with
%type <union>   with_clause opt_with_clause
%type <union>   cte_list
%type <union>   common_table_expr
%type <union>   materialize_clause

%type <union>   within_group_clause
%type <union>   filter_clause
%type <union>   opt_partition_clause
%type <union>   window_clause window_definition_list
%type <union>   window_definition over_clause window_specification
%type <str> opt_existing_window_name
%type <union>   opt_frame_clause
%type <union>   frame_extent
%type <union>   frame_bound
%type <union>   opt_frame_exclusion

%type <union>   opt_tableref_col_list tableref_col_list

%type <union>   targets targets_roles changefeed_targets
%type <union>   opt_on_targets_roles opt_backup_targets
%type <union>   for_grantee_clause
%type <union>   privileges
%type <union>   opt_role_options role_options
%type <union>   audit_mode

%type <str> relocate_kw

%type <union>   set_zone_config

%type <union>   opt_alter_column_using

%type <union>   opt_temp
%type <union>   opt_temp_create_table
%type <union>   role_or_group_or_user

%type <union>    cron_expr opt_description sconst_or_placeholder
%type <union>   opt_full_backup_clause


%nonassoc  VALUES
%nonassoc  SET
%left      UNION EXCEPT
%left      INTERSECT
%left      OR
%left      AND
%right     NOT
%nonassoc  IS ISNULL NOTNULL
%nonassoc  '<' '>' '=' LESS_EQUALS GREATER_EQUALS NOT_EQUALS
%nonassoc  '~' BETWEEN IN LIKE ILIKE SIMILAR NOT_REGMATCH REGIMATCH NOT_REGIMATCH NOT_LA
%nonassoc  ESCAPE
%nonassoc  CONTAINS CONTAINED_BY '?' JSON_SOME_EXISTS JSON_ALL_EXISTS
%nonassoc  OVERLAPS
%left      POSTFIXOP























%nonassoc  UNBOUNDED
%nonassoc  IDENT NULL PARTITION RANGE ROWS GROUPS PRECEDING FOLLOWING CUBE ROLLUP
%left      CONCAT FETCHVAL FETCHTEXT FETCHVAL_PATH FETCHTEXT_PATH REMOVE_PATH
%left      '|'
%left      '#'
%left      '&'
%left      LSHIFT RSHIFT INET_CONTAINS_OR_EQUALS INET_CONTAINED_BY_OR_EQUALS AND_AND SQRT CBRT
%left      '+' '-'
%left      '*' '/' FLOORDIV '%'
%left      '^'

%left      AT
%left      COLLATE
%right     UMINUS
%left      '[' ']'
%left      '(' ')'
%left      TYPEANNOTATE
%left      TYPECAST
%left      '.'





%left      JOIN CROSS LEFT FULL RIGHT INNER NATURAL
%right     HELPTOKEN

%%

stmt_block:
  stmt
  {
    sqllex.(*lexer).SetStmt($1.stmt())
  }

stmt:
  HELPTOKEN { return helpWith(sqllex, "") }
| preparable_stmt
| analyze_stmt       %prec VALUES |  analyze_stmt       HELPTOKEN %prec UMINUS { return helpWith(sqllex, "ANALYZE") }
| copy_from_stmt
| comment_stmt
| execute_stmt       %prec VALUES |  execute_stmt       HELPTOKEN %prec UMINUS { return helpWith(sqllex, "EXECUTE") }
| deallocate_stmt    %prec VALUES |  deallocate_stmt    HELPTOKEN %prec UMINUS { return helpWith(sqllex, "DEALLOCATE") }
| discard_stmt       %prec VALUES |  discard_stmt       HELPTOKEN %prec UMINUS { return helpWith(sqllex, "DISCARD") }
| grant_stmt         %prec VALUES |  grant_stmt         HELPTOKEN %prec UMINUS { return helpWith(sqllex, "GRANT") }
| prepare_stmt       %prec VALUES |  prepare_stmt       HELPTOKEN %prec UMINUS { return helpWith(sqllex, "PREPARE") }
| revoke_stmt        %prec VALUES |  revoke_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "REVOKE") }
| savepoint_stmt     %prec VALUES |  savepoint_stmt     HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SAVEPOINT") }
| release_stmt       %prec VALUES |  release_stmt       HELPTOKEN %prec UMINUS { return helpWith(sqllex, "RELEASE") }
| nonpreparable_set_stmt
| transaction_stmt
| close_cursor_stmt
| declare_cursor_stmt
| reindex_stmt
|
  {
    $$.val = ast.Statement(nil)
  }




alter_stmt:
  alter_ddl_stmt
| alter_role_stmt      %prec VALUES |  alter_role_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "ALTER ROLE") }
| ALTER error          { return helpWith(sqllex, "ALTER") }

alter_ddl_stmt:
  alter_table_stmt      %prec VALUES |   alter_table_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "ALTER TABLE") }
| alter_index_stmt      %prec VALUES |  alter_index_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "ALTER INDEX") }
| alter_view_stmt       %prec VALUES |  alter_view_stmt       HELPTOKEN %prec UMINUS { return helpWith(sqllex, "ALTER VIEW") }
| alter_sequence_stmt   %prec VALUES |  alter_sequence_stmt   HELPTOKEN %prec UMINUS { return helpWith(sqllex, "ALTER SEQUENCE") }
| alter_database_stmt   %prec VALUES |  alter_database_stmt   HELPTOKEN %prec UMINUS { return helpWith(sqllex, "ALTER DATABASE") }
| alter_range_stmt      %prec VALUES |  alter_range_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "ALTER RANGE") }
| alter_partition_stmt  %prec VALUES |  alter_partition_stmt  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "ALTER PARTITION") }
| alter_type_stmt       %prec VALUES |  alter_type_stmt       HELPTOKEN %prec UMINUS { return helpWith(sqllex, "ALTER TYPE") }










































alter_table_stmt:
  alter_onetable_stmt
| alter_relocate_stmt
| alter_relocate_lease_stmt
| alter_split_stmt
| alter_unsplit_stmt
| alter_scatter_stmt
| alter_zone_table_stmt
| alter_rename_table_stmt


| ALTER TABLE error      { return helpWith(sqllex, "ALTER TABLE") }























alter_partition_stmt:
  alter_zone_partition_stmt
| ALTER PARTITION error  { return helpWith(sqllex, "ALTER PARTITION") }






alter_view_stmt:
  alter_rename_view_stmt


| ALTER VIEW error  { return helpWith(sqllex, "ALTER VIEW") }











alter_sequence_stmt:
  alter_rename_sequence_stmt
| alter_sequence_options_stmt
| ALTER SEQUENCE error  { return helpWith(sqllex, "ALTER SEQUENCE") }

alter_sequence_options_stmt:
  ALTER SEQUENCE sequence_name sequence_option_list
  {
    $$.val = &ast.AlterSequence{Name: $3.unresolvedObjectName(), Options: $4.seqOpts(), IfExists: false}
  }
| ALTER SEQUENCE IF EXISTS sequence_name sequence_option_list
  {
    $$.val = &ast.AlterSequence{Name: $5.unresolvedObjectName(), Options: $6.seqOpts(), IfExists: true}
  }






alter_database_stmt:
  alter_rename_database_stmt
|  alter_zone_database_stmt


| ALTER DATABASE error  { return helpWith(sqllex, "ALTER DATABASE") }
















alter_range_stmt:
  alter_zone_range_stmt
| ALTER RANGE error  { return helpWith(sqllex, "ALTER RANGE") }




















alter_index_stmt:
  alter_oneindex_stmt
| alter_relocate_index_stmt
| alter_relocate_index_lease_stmt
| alter_split_index_stmt
| alter_unsplit_index_stmt
| alter_scatter_index_stmt
| alter_rename_index_stmt
| alter_zone_index_stmt


| ALTER INDEX error  { return helpWith(sqllex, "ALTER INDEX") }

alter_onetable_stmt:
  ALTER TABLE relation_expr alter_table_cmds
  {
    $$.val = &ast.AlterTable{Table: $3.unresolvedObjectName(), IfExists: false, Cmds: $4.alterTableCmds()}
  }
| ALTER TABLE IF EXISTS relation_expr alter_table_cmds
  {
    $$.val = &ast.AlterTable{Table: $5.unresolvedObjectName(), IfExists: true, Cmds: $6.alterTableCmds()}
  }

alter_oneindex_stmt:
  ALTER INDEX table_index_name alter_index_cmds
  {
    $$.val = &ast.AlterIndex{Index: $3.tableIndexName(), IfExists: false, Cmds: $4.alterIndexCmds()}
  }
| ALTER INDEX IF EXISTS table_index_name alter_index_cmds
  {
    $$.val = &ast.AlterIndex{Index: $5.tableIndexName(), IfExists: true, Cmds: $6.alterIndexCmds()}
  }

alter_split_stmt:
  ALTER TABLE table_name SPLIT AT select_stmt
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Split{
      TableOrIndex: ast.TableIndexName{Table: name},
      Rows: $6.slct(),
      ExpireExpr: ast.Expr(nil),
    }
  }
| ALTER TABLE table_name SPLIT AT select_stmt WITH EXPIRATION a_expr
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Split{
      TableOrIndex: ast.TableIndexName{Table: name},
      Rows: $6.slct(),
      ExpireExpr: $9.expr(),
    }
  }

alter_split_index_stmt:
  ALTER INDEX table_index_name SPLIT AT select_stmt
  {
    $$.val = &ast.Split{TableOrIndex: $3.tableIndexName(), Rows: $6.slct(), ExpireExpr: ast.Expr(nil)}
  }
| ALTER INDEX table_index_name SPLIT AT select_stmt WITH EXPIRATION a_expr
  {
    $$.val = &ast.Split{TableOrIndex: $3.tableIndexName(), Rows: $6.slct(), ExpireExpr: $9.expr()}
  }

alter_unsplit_stmt:
  ALTER TABLE table_name UNSPLIT AT select_stmt
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Unsplit{
      TableOrIndex: ast.TableIndexName{Table: name},
      Rows: $6.slct(),
    }
  }
| ALTER TABLE table_name UNSPLIT ALL
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Unsplit {
      TableOrIndex: ast.TableIndexName{Table: name},
      All: true,
    }
  }

alter_unsplit_index_stmt:
  ALTER INDEX table_index_name UNSPLIT AT select_stmt
  {
    $$.val = &ast.Unsplit{TableOrIndex: $3.tableIndexName(), Rows: $6.slct()}
  }
| ALTER INDEX table_index_name UNSPLIT ALL
  {
    $$.val = &ast.Unsplit{TableOrIndex: $3.tableIndexName(), All: true}
  }

relocate_kw:
  TESTING_RELOCATE
| EXPERIMENTAL_RELOCATE

alter_relocate_stmt:
  ALTER TABLE table_name relocate_kw select_stmt
  {

    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Relocate{
      TableOrIndex: ast.TableIndexName{Table: name},
      Rows: $5.slct(),
    }
  }

alter_relocate_index_stmt:
  ALTER INDEX table_index_name relocate_kw select_stmt
  {

    $$.val = &ast.Relocate{TableOrIndex: $3.tableIndexName(), Rows: $5.slct()}
  }

alter_relocate_lease_stmt:
  ALTER TABLE table_name relocate_kw LEASE select_stmt
  {

    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Relocate{
      TableOrIndex: ast.TableIndexName{Table: name},
      Rows: $6.slct(),
      RelocateLease: true,
    }
  }

alter_relocate_index_lease_stmt:
  ALTER INDEX table_index_name relocate_kw LEASE select_stmt
  {

    $$.val = &ast.Relocate{TableOrIndex: $3.tableIndexName(), Rows: $6.slct(), RelocateLease: true}
  }

alter_zone_range_stmt:
  ALTER RANGE zone_name set_zone_config
  {
     s := $4.setZoneConfig()
     s.ZoneSpecifier = ast.ZoneSpecifier{NamedZone: ast.UnrestrictedName($3)}
     $$.val = s
  }

set_zone_config:
  CONFIGURE ZONE to_or_eq a_expr
  {

    $$.val = &ast.SetZoneConfig{YAMLConfig: $4.expr()}
  }
| CONFIGURE ZONE USING var_set_list
  {
    $$.val = &ast.SetZoneConfig{Options: $4.kvOptions()}
  }
| CONFIGURE ZONE USING DEFAULT
  {

    $$.val = &ast.SetZoneConfig{SetDefault: true}
  }
| CONFIGURE ZONE DISCARD
  {
    $$.val = &ast.SetZoneConfig{YAMLConfig: ast.DNull}
  }

alter_zone_database_stmt:
  ALTER DATABASE database_name set_zone_config
  {
     s := $4.setZoneConfig()
     s.ZoneSpecifier = ast.ZoneSpecifier{Database: ast.Name($3)}
     $$.val = s
  }

alter_zone_table_stmt:
  ALTER TABLE table_name set_zone_config
  {
    name := $3.unresolvedObjectName().ToTableName()
    s := $4.setZoneConfig()
    s.ZoneSpecifier = ast.ZoneSpecifier{
       TableOrIndex: ast.TableIndexName{Table: name},
    }
    $$.val = s
  }

alter_zone_index_stmt:
  ALTER INDEX table_index_name set_zone_config
  {
    s := $4.setZoneConfig()
    s.ZoneSpecifier = ast.ZoneSpecifier{
       TableOrIndex: $3.tableIndexName(),
    }
    $$.val = s
  }

alter_zone_partition_stmt:
  ALTER PARTITION partition_name OF TABLE table_name set_zone_config
  {
    name := $6.unresolvedObjectName().ToTableName()
    s := $7.setZoneConfig()
    s.ZoneSpecifier = ast.ZoneSpecifier{
       TableOrIndex: ast.TableIndexName{Table: name},
       Partition: ast.Name($3),
    }
    $$.val = s
  }
| ALTER PARTITION partition_name OF INDEX table_index_name set_zone_config
  {
    s := $7.setZoneConfig()
    s.ZoneSpecifier = ast.ZoneSpecifier{
       TableOrIndex: $6.tableIndexName(),
       Partition: ast.Name($3),
    }
    $$.val = s
  }
| ALTER PARTITION partition_name OF INDEX table_name '@' '*' set_zone_config
  {
    name := $6.unresolvedObjectName().ToTableName()
    s := $9.setZoneConfig()
    s.ZoneSpecifier = ast.ZoneSpecifier{
       TableOrIndex: ast.TableIndexName{Table: name},
       Partition: ast.Name($3),
    }
    s.AllIndexes = true
    $$.val = s
  }
| ALTER PARTITION partition_name OF TABLE table_name '@' error
  {
    err := errors.New("index name should not be specified in ALTER PARTITION ... OF TABLE")
    err = errors.WithHint(err, "try ALTER PARTITION ... OF INDEX")
    return setErr(sqllex, err)
  }
| ALTER PARTITION partition_name OF TABLE table_name '@' '*' error
  {
    err := errors.New("index wildcard unsupported in ALTER PARTITION ... OF TABLE")
    err = errors.WithHint(err, "try ALTER PARTITION <partition> OF INDEX <tablename>@*")
    return setErr(sqllex, err)
  }

var_set_list:
  var_name '=' COPY FROM PARENT
  {
    $$.val = []ast.KVOption{ast.KVOption{Key: ast.Name(strings.Join($1.strs(), "."))}}
  }
| var_name '=' var_value
  {
    $$.val = []ast.KVOption{ast.KVOption{Key: ast.Name(strings.Join($1.strs(), ".")), Value: $3.expr()}}
  }
| var_set_list ',' var_name '=' var_value
  {
    $$.val = append($1.kvOptions(), ast.KVOption{Key: ast.Name(strings.Join($3.strs(), ".")), Value: $5.expr()})
  }
| var_set_list ',' var_name '=' COPY FROM PARENT
  {
    $$.val = append($1.kvOptions(), ast.KVOption{Key: ast.Name(strings.Join($3.strs(), "."))})
  }

alter_scatter_stmt:
  ALTER TABLE table_name SCATTER
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Scatter{TableOrIndex: ast.TableIndexName{Table: name}}
  }
| ALTER TABLE table_name SCATTER FROM '(' expr_list ')' TO '(' expr_list ')'
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Scatter{
      TableOrIndex: ast.TableIndexName{Table: name},
      From: $7.exprs(),
      To: $11.exprs(),
    }
  }

alter_scatter_index_stmt:
  ALTER INDEX table_index_name SCATTER
  {
    $$.val = &ast.Scatter{TableOrIndex: $3.tableIndexName()}
  }
| ALTER INDEX table_index_name SCATTER FROM '(' expr_list ')' TO '(' expr_list ')'
  {
    $$.val = &ast.Scatter{TableOrIndex: $3.tableIndexName(), From: $7.exprs(), To: $11.exprs()}
  }

alter_table_cmds:
  alter_table_cmd
  {
    $$.val = ast.AlterTableCmds{$1.alterTableCmd()}
  }
| alter_table_cmds ',' alter_table_cmd
  {
    $$.val = append($1.alterTableCmds(), $3.alterTableCmd())
  }

alter_table_cmd:

  RENAME opt_column column_name TO column_name
  {
    $$.val = &ast.AlterTableRenameColumn{Column: ast.Name($3), NewName: ast.Name($5) }
  }

| RENAME CONSTRAINT column_name TO column_name
  {
    $$.val = &ast.AlterTableRenameConstraint{Constraint: ast.Name($3), NewName: ast.Name($5) }
  }

| ADD column_def
  {
    $$.val = &ast.AlterTableAddColumn{IfNotExists: false, ColumnDef: $2.colDef()}
  }

| ADD IF NOT EXISTS column_def
  {
    $$.val = &ast.AlterTableAddColumn{IfNotExists: true, ColumnDef: $5.colDef()}
  }

| ADD COLUMN column_def
  {
    $$.val = &ast.AlterTableAddColumn{IfNotExists: false, ColumnDef: $3.colDef()}
  }

| ADD COLUMN IF NOT EXISTS column_def
  {
    $$.val = &ast.AlterTableAddColumn{IfNotExists: true, ColumnDef: $6.colDef()}
  }

| ALTER opt_column column_name alter_column_default
  {
    $$.val = &ast.AlterTableSetDefault{Column: ast.Name($3), Default: $4.expr()}
  }

| ALTER opt_column column_name DROP NOT NULL
  {
    $$.val = &ast.AlterTableDropNotNull{Column: ast.Name($3)}
  }

| ALTER opt_column column_name DROP STORED
  {
    $$.val = &ast.AlterTableDropStored{Column: ast.Name($3)}
  }

| ALTER opt_column column_name SET NOT NULL
  {
    $$.val = &ast.AlterTableSetNotNull{Column: ast.Name($3)}
  }

| DROP opt_column IF EXISTS column_name opt_drop_behavior
  {
    $$.val = &ast.AlterTableDropColumn{
      IfExists: true,
      Column: ast.Name($5),
      DropBehavior: $6.dropBehavior(),
    }
  }

| DROP opt_column column_name opt_drop_behavior
  {
    $$.val = &ast.AlterTableDropColumn{
      IfExists: false,
      Column: ast.Name($3),
      DropBehavior: $4.dropBehavior(),
    }
  }




| ALTER opt_column column_name opt_set_data TYPE typename opt_collate opt_alter_column_using
  {
    $$.val = &ast.AlterTableAlterColumnType{
      Column: ast.Name($3),
      ToType: $6.typeReference(),
      Collation: $7,
      Using: $8.expr(),
    }
  }

| ADD table_constraint opt_validate_behavior
  {
    $$.val = &ast.AlterTableAddConstraint{
      ConstraintDef: $2.constraintDef(),
      ValidationBehavior: $3.validationBehavior(),
    }
  }

| ALTER CONSTRAINT constraint_name error { return unimplementedWithIssueDetail(sqllex, 31632, "alter constraint") }


| ALTER PRIMARY KEY USING COLUMNS '(' index_params ')' opt_hash_sharded opt_interleave
  {
    $$.val = &ast.AlterTableAlterPrimaryKey{
      Columns: $7.idxElems(),
      Sharded: $9.shardedIndexDef(),
      Interleave: $10.interleave(),
    }
  }
| VALIDATE CONSTRAINT constraint_name
  {
    $$.val = &ast.AlterTableValidateConstraint{
      Constraint: ast.Name($3),
    }
  }

| DROP CONSTRAINT IF EXISTS constraint_name opt_drop_behavior
  {
    $$.val = &ast.AlterTableDropConstraint{
      IfExists: true,
      Constraint: ast.Name($5),
      DropBehavior: $6.dropBehavior(),
    }
  }

| DROP CONSTRAINT constraint_name opt_drop_behavior
  {
    $$.val = &ast.AlterTableDropConstraint{
      IfExists: false,
      Constraint: ast.Name($3),
      DropBehavior: $4.dropBehavior(),
    }
  }

| EXPERIMENTAL_AUDIT SET audit_mode
  {
    $$.val = &ast.AlterTableSetAudit{Mode: $3.auditMode()}
  }

| partition_by
  {
    $$.val = &ast.AlterTablePartitionBy{
      PartitionBy: $1.partitionBy(),
    }
  }

| INJECT STATISTICS a_expr
  {

    $$.val = &ast.AlterTableInjectStats{
      Stats: $3.expr(),
    }
  }

audit_mode:
  READ WRITE { $$.val = ast.AuditModeReadWrite }
| OFF        { $$.val = ast.AuditModeDisable }

alter_index_cmds:
  alter_index_cmd
  {
    $$.val = ast.AlterIndexCmds{$1.alterIndexCmd()}
  }
| alter_index_cmds ',' alter_index_cmd
  {
    $$.val = append($1.alterIndexCmds(), $3.alterIndexCmd())
  }

alter_index_cmd:
  partition_by
  {
    $$.val = &ast.AlterIndexPartitionBy{
      PartitionBy: $1.partitionBy(),
    }
  }

alter_column_default:
  SET DEFAULT a_expr
  {
    $$.val = $3.expr()
  }
| DROP DEFAULT
  {
    $$.val = nil
  }

opt_alter_column_using:
  USING a_expr
  {
     $$.val = $2.expr()
  }
|
  {
     $$.val = nil
  }


opt_drop_behavior:
  CASCADE
  {
    $$.val = ast.DropCascade
  }
| RESTRICT
  {
    $$.val = ast.DropRestrict
  }
|
  {
    $$.val = ast.DropDefault
  }

opt_validate_behavior:
  NOT VALID
  {
    $$.val = ast.ValidationSkip
  }
|
  {
    $$.val = ast.ValidationDefault
  }




















alter_type_stmt:
  ALTER TYPE type_name ADD VALUE SCONST opt_add_val_placement
  {
    $$.val = &ast.AlterType{
      Type: $3.unresolvedObjectName(),
      Cmd: &ast.AlterTypeAddValue{
        NewVal: $6,
        IfNotExists: false,
        Placement: $7.alterTypeAddValuePlacement(),
      },
    }
  }
| ALTER TYPE type_name ADD VALUE IF NOT EXISTS SCONST opt_add_val_placement
  {
    $$.val = &ast.AlterType{
      Type: $3.unresolvedObjectName(),
      Cmd: &ast.AlterTypeAddValue{
        NewVal: $9,
        IfNotExists: true,
        Placement: $10.alterTypeAddValuePlacement(),
      },
    }
  }
| ALTER TYPE type_name RENAME VALUE SCONST TO SCONST
  {
    $$.val = &ast.AlterType{
      Type: $3.unresolvedObjectName(),
      Cmd: &ast.AlterTypeRenameValue{
        OldVal: $6,
        NewVal: $8,
      },
    }
  }
| ALTER TYPE type_name RENAME TO name
  {
    $$.val = &ast.AlterType{
      Type: $3.unresolvedObjectName(),
      Cmd: &ast.AlterTypeRename{
        NewName: $6,
      },
    }
  }
| ALTER TYPE type_name SET SCHEMA schema_name
  {
    $$.val = &ast.AlterType{
      Type: $3.unresolvedObjectName(),
      Cmd: &ast.AlterTypeSetSchema{
        Schema: $6,
      },
    }
  }
| ALTER TYPE type_name OWNER TO role_spec
  {
    return unimplementedWithIssueDetail(sqllex, 48700, "ALTER TYPE OWNER TO")
  }
| ALTER TYPE type_name RENAME ATTRIBUTE column_name TO column_name opt_drop_behavior
  {
    return unimplementedWithIssueDetail(sqllex, 48701, "ALTER TYPE ATTRIBUTE")
  }
| ALTER TYPE type_name alter_attribute_action_list
  {
    return unimplementedWithIssueDetail(sqllex, 48701, "ALTER TYPE ATTRIBUTE")
  }
| ALTER TYPE error  { return helpWith(sqllex, "ALTER TYPE") }

opt_add_val_placement:
  BEFORE SCONST
  {
    $$.val = &ast.AlterTypeAddValuePlacement{
       Before: true,
       ExistingVal: $2,
    }
  }
| AFTER SCONST
  {
    $$.val = &ast.AlterTypeAddValuePlacement{
       Before: false,
       ExistingVal: $2,
    }
  }
|
  {
    $$.val = (*ast.AlterTypeAddValuePlacement)(nil)
  }

role_spec:
  non_reserved_word_or_sconst
| CURRENT_USER
| SESSION_USER

alter_attribute_action_list:
  alter_attribute_action
| alter_attribute_action_list ',' alter_attribute_action

alter_attribute_action:
  ADD ATTRIBUTE column_name type_name opt_collate opt_drop_behavior
| DROP ATTRIBUTE column_name opt_drop_behavior
| DROP ATTRIBUTE IF EXISTS column_name opt_drop_behavior
| ALTER ATTRIBUTE column_name TYPE type_name opt_collate opt_drop_behavior
| ALTER ATTRIBUTE column_name SET DATA TYPE type_name opt_collate opt_drop_behavior























backup_stmt:
  BACKUP opt_backup_targets TO partitioned_backup opt_as_of_clause opt_incremental opt_with_backup_options
  {
    backup := &ast.Backup{
      To:              $4.partitionedBackup(),
      IncrementalFrom: $6.exprs(),
      AsOf:            $5.asOfClause(),
      Options:         *$7.backupOptions(),
    }

    tl := $2.targetListPtr()
    if tl == nil {
      backup.DescriptorCoverage = ast.AllDescriptors
    } else {
      backup.DescriptorCoverage = ast.RequestedDescriptors
      backup.Targets = *tl
    }

    $$.val = backup
  }
| BACKUP error  { return helpWith(sqllex, "BACKUP") }

opt_backup_targets:

  {
    $$.val = (*ast.TargetList)(nil)
  }
| targets
  {
    t := $1.targetList()
    $$.val = &t
  }


opt_with_backup_options:
  WITH backup_options_list
  {
    $$.val = $2.backupOptions()
  }
| WITH OPTIONS '(' backup_options_list ')'
  {
    $$.val = $4.backupOptions()
  }
|
  {
    $$.val = &ast.BackupOptions{}
  }

backup_options_list:

  backup_options
  {
    $$.val = $1.backupOptions()
  }
| backup_options_list ',' backup_options
  {
    if err := $1.backupOptions().CombineWith($3.backupOptions()); err != nil {
      return setErr(sqllex, err)
    }
  }


backup_options:
  ENCRYPTION_PASSPHRASE '=' string_or_placeholder
  {
    $$.val = &ast.BackupOptions{EncryptionPassphrase: $3.expr()}
  }
| REVISION_HISTORY
  {
    $$.val = &ast.BackupOptions{CaptureRevisionHistory: true}
  }
| DETACHED
  {
    $$.val = &ast.BackupOptions{Detached: true}
  }











































































create_schedule_for_backup_stmt:
  CREATE SCHEDULE  opt_description FOR BACKUP  opt_backup_targets TO
   partitioned_backup  opt_with_backup_options
   cron_expr  opt_full_backup_clause  opt_with_schedule_options
  {
    $$.val = &ast.ScheduledBackup{
      ScheduleName:     $3.expr(),
      Recurrence:       $10.expr(),
      FullBackup:       $11.fullBackupClause(),
      To:               $8.partitionedBackup(),
      Targets:          $6.targetListPtr(),
      BackupOptions:    *($9.backupOptions()),
      ScheduleOptions:  $12.kvOptions(),
    }
  }
| CREATE SCHEDULE error   { return helpWith(sqllex, "CREATE SCHEDULE FOR BACKUP") }

opt_description:
  string_or_placeholder
|
  {
     $$.val = nil
  }



sconst_or_placeholder:
  SCONST
  {
    $$.val =  ast.NewStrVal($1)
  }
| PLACEHOLDER
  {
    p := $1.placeholder()
    sqllex.(*lexer).UpdateNumPlaceholders(p)
    $$.val = p
  }

cron_expr:
  RECURRING NEVER
  {
    $$.val = nil
  }
| RECURRING sconst_or_placeholder


  {
    $$.val = $2.expr()
  }

opt_full_backup_clause:
  FULL BACKUP sconst_or_placeholder


  {
    $$.val = &ast.FullBackupClause{Recurrence: $3.expr()}
  }
| FULL BACKUP ALWAYS
  {
    $$.val = &ast.FullBackupClause{AlwaysFull: true}
  }
|
  {
    $$.val = (*ast.FullBackupClause)(nil)
  }

opt_with_schedule_options:
  WITH EXPERIMENTAL SCHEDULE OPTIONS kv_option_list
  {
    $$.val = $5.kvOptions()
  }
| WITH EXPERIMENTAL SCHEDULE OPTIONS '(' kv_option_list ')'
  {
    $$.val = $6.kvOptions()
  }
|
  {
    $$.val = nil
  }





















restore_stmt:
  RESTORE FROM partitioned_backup_list opt_as_of_clause opt_with_options
  {
    $$.val = &ast.Restore{DescriptorCoverage: ast.AllDescriptors, From: $3.partitionedBackups(), AsOf: $4.asOfClause(), Options: $5.kvOptions()}
  }
| RESTORE targets FROM partitioned_backup_list opt_as_of_clause opt_with_options
  {
    $$.val = &ast.Restore{Targets: $2.targetList(), From: $4.partitionedBackups(), AsOf: $5.asOfClause(), Options: $6.kvOptions()}
  }
| RESTORE error  { return helpWith(sqllex, "RESTORE") }

partitioned_backup:
  string_or_placeholder
  {
    $$.val = ast.PartitionedBackup{$1.expr()}
  }
| '(' string_or_placeholder_list ')'
  {
    $$.val = ast.PartitionedBackup($2.exprs())
  }

partitioned_backup_list:
  partitioned_backup
  {
    $$.val = []ast.PartitionedBackup{$1.partitionedBackup()}
  }
| partitioned_backup_list ',' partitioned_backup
  {
    $$.val = append($1.partitionedBackups(), $3.partitionedBackup())
  }

import_format:
  name
  {
    $$ = strings.ToUpper($1)
  }
































import_stmt:
 IMPORT import_format '(' string_or_placeholder ')' opt_with_options
  {

    $$.val = &ast.Import{Bundle: true, FileFormat: $2, Files: ast.Exprs{$4.expr()}, Options: $6.kvOptions()}
  }
| IMPORT import_format string_or_placeholder opt_with_options
  {
    $$.val = &ast.Import{Bundle: true, FileFormat: $2, Files: ast.Exprs{$3.expr()}, Options: $4.kvOptions()}
  }
| IMPORT TABLE table_name FROM import_format '(' string_or_placeholder ')' opt_with_options
  {

    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Import{Bundle: true, Table: &name, FileFormat: $5, Files: ast.Exprs{$7.expr()}, Options: $9.kvOptions()}
  }
| IMPORT TABLE table_name FROM import_format string_or_placeholder opt_with_options
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Import{Bundle: true, Table: &name, FileFormat: $5, Files: ast.Exprs{$6.expr()}, Options: $7.kvOptions()}
  }
| IMPORT TABLE table_name CREATE USING string_or_placeholder import_format DATA '(' string_or_placeholder_list ')' opt_with_options
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Import{Table: &name, CreateFile: $6.expr(), FileFormat: $7, Files: $10.exprs(), Options: $12.kvOptions()}
  }
| IMPORT TABLE table_name '(' table_elem_list ')' import_format DATA '(' string_or_placeholder_list ')' opt_with_options
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Import{Table: &name, CreateDefs: $5.tblDefs(), FileFormat: $7, Files: $10.exprs(), Options: $12.kvOptions()}
  }
| IMPORT INTO table_name '(' insert_column_list ')' import_format DATA '(' string_or_placeholder_list ')' opt_with_options
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Import{Table: &name, Into: true, IntoCols: $5.nameList(), FileFormat: $7, Files: $10.exprs(), Options: $12.kvOptions()}
  }
| IMPORT INTO table_name import_format DATA '(' string_or_placeholder_list ')' opt_with_options
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Import{Table: &name, Into: true, IntoCols: nil, FileFormat: $4, Files: $7.exprs(), Options: $9.kvOptions()}
  }
| IMPORT error  { return helpWith(sqllex, "IMPORT") }













export_stmt:
  EXPORT INTO import_format string_or_placeholder opt_with_options FROM select_stmt
  {
    $$.val = &ast.Export{Query: $7.slct(), FileFormat: $3, File: $4.expr(), Options: $5.kvOptions()}
  }
| EXPORT error  { return helpWith(sqllex, "EXPORT") }

string_or_placeholder:
  non_reserved_word_or_sconst
  {
    $$.val = ast.NewStrVal($1)
  }
| PLACEHOLDER
  {
    p := $1.placeholder()
    sqllex.(*lexer).UpdateNumPlaceholders(p)
    $$.val = p
  }

string_or_placeholder_list:
  string_or_placeholder
  {
    $$.val = ast.Exprs{$1.expr()}
  }
| string_or_placeholder_list ',' string_or_placeholder
  {
    $$.val = append($1.exprs(), $3.expr())
  }

opt_incremental:
  INCREMENTAL FROM string_or_placeholder_list
  {
    $$.val = $3.exprs()
  }
|
  {
    $$.val = ast.Exprs(nil)
  }

kv_option:
  name '=' string_or_placeholder
  {
    $$.val = ast.KVOption{Key: ast.Name($1), Value: $3.expr()}
  }
|  name
  {
    $$.val = ast.KVOption{Key: ast.Name($1)}
  }
|  SCONST '=' string_or_placeholder
  {
    $$.val = ast.KVOption{Key: ast.Name($1), Value: $3.expr()}
  }
|  SCONST
  {
    $$.val = ast.KVOption{Key: ast.Name($1)}
  }

kv_option_list:
  kv_option
  {
    $$.val = []ast.KVOption{$1.kvOption()}
  }
|  kv_option_list ',' kv_option
  {
    $$.val = append($1.kvOptions(), $3.kvOption())
  }

opt_with_options:
  WITH kv_option_list
  {
    $$.val = $2.kvOptions()
  }
| WITH OPTIONS '(' kv_option_list ')'
  {
    $$.val = $4.kvOptions()
  }
|
  {
    $$.val = nil
  }

copy_from_stmt:
  COPY table_name opt_column_list FROM STDIN opt_with_options
  {
    name := $2.unresolvedObjectName().ToTableName()
    $$.val = &ast.CopyFrom{
       Table: name,
       Columns: $3.nameList(),
       Stdin: true,
       Options: $6.kvOptions(),
    }
  }




cancel_stmt:
  cancel_jobs_stmt      %prec VALUES |   cancel_jobs_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CANCEL JOBS") }
| cancel_queries_stmt   %prec VALUES |  cancel_queries_stmt   HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CANCEL QUERIES") }
| cancel_sessions_stmt  %prec VALUES |  cancel_sessions_stmt  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CANCEL SESSIONS") }
| CANCEL error          { return helpWith(sqllex, "CANCEL") }







cancel_jobs_stmt:
  CANCEL JOB a_expr
  {
    $$.val = &ast.ControlJobs{
      Jobs: &ast.Select{
        Select: &ast.ValuesClause{Rows: []ast.Exprs{ast.Exprs{$3.expr()}}},
      },
      Command: ast.CancelJob,
    }
  }
| CANCEL JOB error  { return helpWith(sqllex, "CANCEL JOBS") }
| CANCEL JOBS select_stmt
  {
    $$.val = &ast.ControlJobs{Jobs: $3.slct(), Command: ast.CancelJob}
  }
| CANCEL JOBS error  { return helpWith(sqllex, "CANCEL JOBS") }







cancel_queries_stmt:
  CANCEL QUERY a_expr
  {
    $$.val = &ast.CancelQueries{
      Queries: &ast.Select{
        Select: &ast.ValuesClause{Rows: []ast.Exprs{ast.Exprs{$3.expr()}}},
      },
      IfExists: false,
    }
  }
| CANCEL QUERY IF EXISTS a_expr
  {
    $$.val = &ast.CancelQueries{
      Queries: &ast.Select{
        Select: &ast.ValuesClause{Rows: []ast.Exprs{ast.Exprs{$5.expr()}}},
      },
      IfExists: true,
    }
  }
| CANCEL QUERY error  { return helpWith(sqllex, "CANCEL QUERIES") }
| CANCEL QUERIES select_stmt
  {
    $$.val = &ast.CancelQueries{Queries: $3.slct(), IfExists: false}
  }
| CANCEL QUERIES IF EXISTS select_stmt
  {
    $$.val = &ast.CancelQueries{Queries: $5.slct(), IfExists: true}
  }
| CANCEL QUERIES error  { return helpWith(sqllex, "CANCEL QUERIES") }







cancel_sessions_stmt:
  CANCEL SESSION a_expr
  {
   $$.val = &ast.CancelSessions{
      Sessions: &ast.Select{
        Select: &ast.ValuesClause{Rows: []ast.Exprs{ast.Exprs{$3.expr()}}},
      },
      IfExists: false,
    }
  }
| CANCEL SESSION IF EXISTS a_expr
  {
   $$.val = &ast.CancelSessions{
      Sessions: &ast.Select{
        Select: &ast.ValuesClause{Rows: []ast.Exprs{ast.Exprs{$5.expr()}}},
      },
      IfExists: true,
    }
  }
| CANCEL SESSION error  { return helpWith(sqllex, "CANCEL SESSIONS") }
| CANCEL SESSIONS select_stmt
  {
    $$.val = &ast.CancelSessions{Sessions: $3.slct(), IfExists: false}
  }
| CANCEL SESSIONS IF EXISTS select_stmt
  {
    $$.val = &ast.CancelSessions{Sessions: $5.slct(), IfExists: true}
  }
| CANCEL SESSIONS error  { return helpWith(sqllex, "CANCEL SESSIONS") }

comment_stmt:
  COMMENT ON DATABASE database_name IS comment_text
  {
    $$.val = &ast.CommentOnDatabase{Name: ast.Name($4), Comment: $6.strPtr()}
  }
| COMMENT ON TABLE table_name IS comment_text
  {
    $$.val = &ast.CommentOnTable{Table: $4.unresolvedObjectName(), Comment: $6.strPtr()}
  }
| COMMENT ON COLUMN column_path IS comment_text
  {
    varName, err := $4.unresolvedName().NormalizeVarName()
    if err != nil {
      return setErr(sqllex, err)
    }
    columnItem, ok := varName.(*ast.ColumnItem)
    if !ok {
      sqllex.Error(fmt.Sprintf("invalid column name: %q", ast.ErrString($4.unresolvedName())))
            return 1
    }
    $$.val = &ast.CommentOnColumn{ColumnItem: columnItem, Comment: $6.strPtr()}
  }
| COMMENT ON INDEX table_index_name IS comment_text
  {
    $$.val = &ast.CommentOnIndex{Index: $4.tableIndexName(), Comment: $6.strPtr()}
  }

comment_text:
  SCONST
  {
    t := $1
    $$.val = &t
  }
| NULL
  {
    var str *string
    $$.val = str
  }







create_stmt:
  create_role_stmt      %prec VALUES |   create_role_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CREATE ROLE") }
| create_ddl_stmt
| create_stats_stmt     %prec VALUES |  create_stats_stmt     HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CREATE STATISTICS") }
| create_schedule_for_backup_stmt    %prec VALUES |  create_schedule_for_backup_stmt    HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CREATE SCHEDULE FOR BACKUP") }
| create_unsupported   {}
| CREATE error          { return helpWith(sqllex, "CREATE") }

create_unsupported:
  CREATE AGGREGATE error { return unimplemented(sqllex, "create aggregate") }
| CREATE CAST error { return unimplemented(sqllex, "create cast") }
| CREATE CONSTRAINT TRIGGER error { return unimplementedWithIssueDetail(sqllex, 28296, "create constraint") }
| CREATE CONVERSION error { return unimplemented(sqllex, "create conversion") }
| CREATE DEFAULT CONVERSION error { return unimplemented(sqllex, "create def conv") }
| CREATE EXTENSION IF NOT EXISTS name error { return unimplemented(sqllex, "create extension " + $6) }
| CREATE EXTENSION name error { return unimplemented(sqllex, "create extension " + $3) }
| CREATE FOREIGN TABLE error { return unimplemented(sqllex, "create foreign table") }
| CREATE FOREIGN DATA error { return unimplemented(sqllex, "create fdw") }
| CREATE FUNCTION error { return unimplementedWithIssueDetail(sqllex, 17511, "create function") }
| CREATE OR REPLACE FUNCTION error { return unimplementedWithIssueDetail(sqllex, 17511, "create function") }
| CREATE opt_or_replace opt_trusted opt_procedural LANGUAGE name error { return unimplementedWithIssueDetail(sqllex, 17511, "create language " + $6) }
| CREATE MATERIALIZED VIEW error { return unimplementedWithIssue(sqllex, 41649) }
| CREATE OPERATOR error { return unimplemented(sqllex, "create operator") }
| CREATE PUBLICATION error { return unimplemented(sqllex, "create publication") }
| CREATE opt_or_replace RULE error { return unimplemented(sqllex, "create rule") }
| CREATE SERVER error { return unimplemented(sqllex, "create server") }
| CREATE SUBSCRIPTION error { return unimplemented(sqllex, "create subscription") }
| CREATE TEXT error { return unimplementedWithIssueDetail(sqllex, 7821, "create text") }
| CREATE TRIGGER error { return unimplementedWithIssueDetail(sqllex, 28296, "create") }

opt_or_replace:
  OR REPLACE {}
|   {}

opt_trusted:
  TRUSTED {}
|   {}

opt_procedural:
  PROCEDURAL {}
|   {}

drop_unsupported:
  DROP AGGREGATE error { return unimplemented(sqllex, "drop aggregate") }
| DROP CAST error { return unimplemented(sqllex, "drop cast") }
| DROP COLLATION error { return unimplemented(sqllex, "drop collation") }
| DROP CONVERSION error { return unimplemented(sqllex, "drop conversion") }
| DROP DOMAIN error { return unimplementedWithIssueDetail(sqllex, 27796, "drop") }
| DROP EXTENSION IF EXISTS name error { return unimplemented(sqllex, "drop extension " + $5) }
| DROP EXTENSION name error { return unimplemented(sqllex, "drop extension " + $3) }
| DROP FOREIGN TABLE error { return unimplemented(sqllex, "drop foreign table") }
| DROP FOREIGN DATA error { return unimplemented(sqllex, "drop fdw") }
| DROP FUNCTION error { return unimplementedWithIssueDetail(sqllex, 17511, "drop function") }
| DROP opt_procedural LANGUAGE name error { return unimplementedWithIssueDetail(sqllex, 17511, "drop language " + $4) }
| DROP OPERATOR error { return unimplemented(sqllex, "drop operator") }
| DROP PUBLICATION error { return unimplemented(sqllex, "drop publication") }
| DROP RULE error { return unimplemented(sqllex, "drop rule") }
| DROP SCHEMA error { return unimplementedWithIssueDetail(sqllex, 26443, "drop") }
| DROP SERVER error { return unimplemented(sqllex, "drop server") }
| DROP SUBSCRIPTION error { return unimplemented(sqllex, "drop subscription") }
| DROP TEXT error { return unimplementedWithIssueDetail(sqllex, 7821, "drop text") }
| DROP TRIGGER error { return unimplementedWithIssueDetail(sqllex, 28296, "drop") }

create_ddl_stmt:
  create_changefeed_stmt
| create_database_stmt  %prec VALUES |  create_database_stmt  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CREATE DATABASE") }
| create_index_stmt     %prec VALUES |  create_index_stmt     HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CREATE INDEX") }
| create_schema_stmt    %prec VALUES |  create_schema_stmt    HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CREATE SCHEMA") }
| create_table_stmt     %prec VALUES |  create_table_stmt     HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CREATE TABLE") }
| create_table_as_stmt  %prec VALUES |  create_table_as_stmt  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CREATE TABLE") }

| CREATE opt_temp_create_table TABLE error    { return helpWith(sqllex, "CREATE TABLE") }
| create_type_stmt      %prec VALUES |  create_type_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CREATE TYPE") }
| create_view_stmt      %prec VALUES |  create_view_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CREATE VIEW") }
| create_sequence_stmt  %prec VALUES |  create_sequence_stmt  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "CREATE SEQUENCE") }







create_stats_stmt:
  CREATE STATISTICS statistics_name opt_stats_columns FROM create_stats_target opt_create_stats_options
  {
    $$.val = &ast.CreateStats{
      Name: ast.Name($3),
      ColumnNames: $4.nameList(),
      Table: $6.tblExpr(),
      Options: *$7.createStatsOptions(),
    }
  }
| CREATE STATISTICS error  { return helpWith(sqllex, "CREATE STATISTICS") }

opt_stats_columns:
  ON name_list
  {
    $$.val = $2.nameList()
  }
|
  {
    $$.val = ast.NameList(nil)
  }

create_stats_target:
  table_name
  {
    $$.val = $1.unresolvedObjectName()
  }
| '[' iconst64 ']'
  {

    $$.val = &ast.TableRef{
      TableID: $2.int64(),
    }
  }

opt_create_stats_options:
  WITH OPTIONS create_stats_option_list
  {

    $$.val = $3.createStatsOptions()
  }


| as_of_clause
  {
    $$.val = &ast.CreateStatsOptions{
      AsOf: $1.asOfClause(),
    }
  }
|
  {
    $$.val = &ast.CreateStatsOptions{}
  }

create_stats_option_list:
  create_stats_option
  {
    $$.val = $1.createStatsOptions()
  }
| create_stats_option_list create_stats_option
  {
    a := $1.createStatsOptions()
    b := $2.createStatsOptions()
    if err := a.CombineWith(b); err != nil {
      return setErr(sqllex, err)
    }
    $$.val = a
  }

create_stats_option:
  THROTTLING FCONST
  {

    value, _ := constant.Float64Val($2.numVal().AsConstantValue())
    if value < 0.0 || value >= 1.0 {
      sqllex.Error("THROTTLING fraction must be between 0 and 1")
      return 1
    }
    $$.val = &ast.CreateStatsOptions{
      Throttling: value,
    }
  }
| as_of_clause
  {
    $$.val = &ast.CreateStatsOptions{
      AsOf: $1.asOfClause(),
    }
  }

create_changefeed_stmt:
  CREATE CHANGEFEED FOR changefeed_targets opt_changefeed_sink opt_with_options
  {
    $$.val = &ast.CreateChangefeed{
      Targets: $4.targetList(),
      SinkURI: $5.expr(),
      Options: $6.kvOptions(),
    }
  }
| EXPERIMENTAL CHANGEFEED FOR changefeed_targets opt_with_options
  {

    $$.val = &ast.CreateChangefeed{
      Targets: $4.targetList(),
      Options: $5.kvOptions(),
    }
  }

changefeed_targets:
  single_table_pattern_list
  {
    $$.val = ast.TargetList{Tables: $1.tablePatterns()}
  }
| TABLE single_table_pattern_list
  {
    $$.val = ast.TargetList{Tables: $2.tablePatterns()}
  }

single_table_pattern_list:
  table_name
  {
    $$.val = ast.TablePatterns{$1.unresolvedObjectName().ToUnresolvedName()}
  }
| single_table_pattern_list ',' table_name
  {
    $$.val = append($1.tablePatterns(), $3.unresolvedObjectName().ToUnresolvedName())
  }


opt_changefeed_sink:
  INTO string_or_placeholder
  {
    $$.val = $2.expr()
  }
|
  {

    $$.val = nil
  }








delete_stmt:
  opt_with_clause DELETE FROM table_expr_opt_alias_idx opt_using_clause opt_where_clause opt_sort_clause opt_limit_clause returning_clause
  {
    $$.val = &ast.Delete{
      With: $1.with(),
      Table: $4.tblExpr(),
      Where: ast.NewWhere(ast.AstWhere, $6.expr()),
      OrderBy: $7.orderBy(),
      Limit: $8.limit(),
      Returning: $9.retClause(),
    }
  }
| opt_with_clause DELETE error  { return helpWith(sqllex, "DELETE") }

opt_using_clause:
  USING from_list { return unimplementedWithIssueDetail(sqllex, 40963, "delete using") }
|   { }





discard_stmt:
  DISCARD ALL
  {
    $$.val = &ast.Discard{Mode: ast.DiscardModeAll}
  }
| DISCARD PLANS { return unimplemented(sqllex, "discard plans") }
| DISCARD SEQUENCES { return unimplemented(sqllex, "discard sequences") }
| DISCARD TEMP { return unimplemented(sqllex, "discard temp") }
| DISCARD TEMPORARY { return unimplemented(sqllex, "discard temp") }
| DISCARD error  { return helpWith(sqllex, "DISCARD") }






drop_stmt:
  drop_ddl_stmt
| drop_role_stmt      %prec VALUES |  drop_role_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "DROP ROLE") }
| drop_unsupported   {}
| DROP error          { return helpWith(sqllex, "DROP") }

drop_ddl_stmt:
  drop_database_stmt  %prec VALUES |   drop_database_stmt  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "DROP DATABASE") }
| drop_index_stmt     %prec VALUES |  drop_index_stmt     HELPTOKEN %prec UMINUS { return helpWith(sqllex, "DROP INDEX") }
| drop_table_stmt     %prec VALUES |  drop_table_stmt     HELPTOKEN %prec UMINUS { return helpWith(sqllex, "DROP TABLE") }
| drop_view_stmt      %prec VALUES |  drop_view_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "DROP VIEW") }
| drop_sequence_stmt  %prec VALUES |  drop_sequence_stmt  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "DROP SEQUENCE") }
| drop_type_stmt      %prec VALUES |  drop_type_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "DROP TYPE") }





drop_view_stmt:
  DROP VIEW table_name_list opt_drop_behavior
  {
    $$.val = &ast.DropView{Names: $3.tableNames(), IfExists: false, DropBehavior: $4.dropBehavior()}
  }
| DROP VIEW IF EXISTS table_name_list opt_drop_behavior
  {
    $$.val = &ast.DropView{Names: $5.tableNames(), IfExists: true, DropBehavior: $6.dropBehavior()}
  }
| DROP VIEW error  { return helpWith(sqllex, "DROP VIEW") }





drop_sequence_stmt:
  DROP SEQUENCE table_name_list opt_drop_behavior
  {
    $$.val = &ast.DropSequence{Names: $3.tableNames(), IfExists: false, DropBehavior: $4.dropBehavior()}
  }
| DROP SEQUENCE IF EXISTS table_name_list opt_drop_behavior
  {
    $$.val = &ast.DropSequence{Names: $5.tableNames(), IfExists: true, DropBehavior: $6.dropBehavior()}
  }
| DROP SEQUENCE error  { return helpWith(sqllex, "DROP VIEW") }





drop_table_stmt:
  DROP TABLE table_name_list opt_drop_behavior
  {
    $$.val = &ast.DropTable{Names: $3.tableNames(), IfExists: false, DropBehavior: $4.dropBehavior()}
  }
| DROP TABLE IF EXISTS table_name_list opt_drop_behavior
  {
    $$.val = &ast.DropTable{Names: $5.tableNames(), IfExists: true, DropBehavior: $6.dropBehavior()}
  }
| DROP TABLE error  { return helpWith(sqllex, "DROP TABLE") }





drop_index_stmt:
  DROP INDEX opt_concurrently table_index_name_list opt_drop_behavior
  {
    $$.val = &ast.DropIndex{
      IndexList: $4.newTableIndexNames(),
      IfExists: false,
      DropBehavior: $5.dropBehavior(),
      Concurrently: $3.bool(),
    }
  }
| DROP INDEX opt_concurrently IF EXISTS table_index_name_list opt_drop_behavior
  {
    $$.val = &ast.DropIndex{
      IndexList: $6.newTableIndexNames(),
      IfExists: true,
      DropBehavior: $7.dropBehavior(),
      Concurrently: $3.bool(),
    }
  }
| DROP INDEX error  { return helpWith(sqllex, "DROP INDEX") }





drop_database_stmt:
  DROP DATABASE database_name opt_drop_behavior
  {
    $$.val = &ast.DropDatabase{
      Name: ast.Name($3),
      IfExists: false,
      DropBehavior: $4.dropBehavior(),
    }
  }
| DROP DATABASE IF EXISTS database_name opt_drop_behavior
  {
    $$.val = &ast.DropDatabase{
      Name: ast.Name($5),
      IfExists: true,
      DropBehavior: $6.dropBehavior(),
    }
  }
| DROP DATABASE error  { return helpWith(sqllex, "DROP DATABASE") }




drop_type_stmt:
  DROP TYPE type_name_list opt_drop_behavior
  {
    $$.val = &ast.DropType{
      Names: $3.unresolvedObjectNames(),
      IfExists: false,
      DropBehavior: $4.dropBehavior(),
    }
  }
| DROP TYPE IF EXISTS type_name_list opt_drop_behavior
  {
    $$.val = &ast.DropType{
      Names: $5.unresolvedObjectNames(),
      IfExists: true,
      DropBehavior: $6.dropBehavior(),
    }
  }
| DROP TYPE error  { return helpWith(sqllex, "DROP TYPE") }


type_name_list:
  type_name
  {
    $$.val = []*ast.UnresolvedObjectName{$1.unresolvedObjectName()}
  }
| type_name_list ',' type_name
  {
    $$.val = append($1.unresolvedObjectNames(), $3.unresolvedObjectName())
  }






drop_role_stmt:
  DROP role_or_group_or_user string_or_placeholder_list
  {
    $$.val = &ast.DropRole{Names: $3.exprs(), IfExists: false, IsRole: $2.bool()}
  }
| DROP role_or_group_or_user IF EXISTS string_or_placeholder_list
  {
    $$.val = &ast.DropRole{Names: $5.exprs(), IfExists: true, IsRole: $2.bool()}
  }
| DROP role_or_group_or_user error  { return helpWith(sqllex, "DROP ROLE") }

table_name_list:
  table_name
  {
    name := $1.unresolvedObjectName().ToTableName()
    $$.val = ast.TableNames{name}
  }
| table_name_list ',' table_name
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = append($1.tableNames(), name)
  }







analyze_stmt:
  ANALYZE analyze_target
  {
    $$.val = &ast.Analyze{
      Table: $2.tblExpr(),
    }
  }
| ANALYZE error  { return helpWith(sqllex, "ANALYZE") }
| ANALYSE analyze_target
  {
    $$.val = &ast.Analyze{
      Table: $2.tblExpr(),
    }
  }
| ANALYSE error  { return helpWith(sqllex, "ANALYZE") }

analyze_target:
  table_name
  {
    $$.val = $1.unresolvedObjectName()
  }

















explain_stmt:
  EXPLAIN preparable_stmt
  {
    var err error
    $$.val, err = ast.MakeExplain(nil  , $2.stmt())
    if err != nil {
      return setErr(sqllex, err)
    }
  }
| EXPLAIN error  { return helpWith(sqllex, "EXPLAIN") }
| EXPLAIN '(' explain_option_list ')' preparable_stmt
  {
    var err error
    $$.val, err = ast.MakeExplain($3.strs(), $5.stmt())
    if err != nil {
      return setErr(sqllex, err)
    }
  }
| EXPLAIN ANALYZE preparable_stmt
  {
    var err error
    $$.val, err = ast.MakeExplain([]string{"DISTSQL", "ANALYZE"}, $3.stmt())
    if err != nil {
      return setErr(sqllex, err)
    }
  }
| EXPLAIN ANALYSE preparable_stmt
  {
    var err error
    $$.val, err = ast.MakeExplain([]string{"DISTSQL", "ANALYZE"}, $3.stmt())
    if err != nil {
      return setErr(sqllex, err)
    }
  }
| EXPLAIN ANALYZE '(' explain_option_list ')' preparable_stmt
  {
    var err error
    $$.val, err = ast.MakeExplain(append($4.strs(), "ANALYZE"), $6.stmt())
    if err != nil {
      return setErr(sqllex, err)
    }
  }
| EXPLAIN ANALYSE '(' explain_option_list ')' preparable_stmt
  {
    var err error
    $$.val, err = ast.MakeExplain(append($4.strs(), "ANALYZE"), $6.stmt())
    if err != nil {
      return setErr(sqllex, err)
    }
  }




| EXPLAIN '(' error  { return helpWith(sqllex, "EXPLAIN") }

preparable_stmt:
  alter_stmt
| backup_stmt        %prec VALUES |  backup_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "BACKUP") }
| cancel_stmt
| create_stmt
| delete_stmt        %prec VALUES |  delete_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "DELETE") }
| drop_stmt
| explain_stmt       %prec VALUES |  explain_stmt       HELPTOKEN %prec UMINUS { return helpWith(sqllex, "EXPLAIN") }
| import_stmt        %prec VALUES |  import_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "IMPORT") }
| insert_stmt        %prec VALUES |  insert_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "INSERT") }
| pause_stmt         %prec VALUES |  pause_stmt         HELPTOKEN %prec UMINUS { return helpWith(sqllex, "PAUSE JOBS") }
| reset_stmt
| restore_stmt       %prec VALUES |  restore_stmt       HELPTOKEN %prec UMINUS { return helpWith(sqllex, "RESTORE") }
| resume_stmt        %prec VALUES |  resume_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "RESUME JOBS") }
| export_stmt        %prec VALUES |  export_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "EXPORT") }
| scrub_stmt
| select_stmt
  {
    $$.val = $1.slct()
  }
| preparable_set_stmt
| show_stmt
| truncate_stmt      %prec VALUES |  truncate_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "TRUNCATE") }
| update_stmt        %prec VALUES |  update_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "UPDATE") }
| upsert_stmt        %prec VALUES |  upsert_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "UPSERT") }



row_source_extension_stmt:
  delete_stmt        %prec VALUES |   delete_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "DELETE") }
| explain_stmt       %prec VALUES |  explain_stmt       HELPTOKEN %prec UMINUS { return helpWith(sqllex, "EXPLAIN") }
| insert_stmt        %prec VALUES |  insert_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "INSERT") }
| select_stmt
  {
    $$.val = $1.slct()
  }
| show_stmt
| update_stmt        %prec VALUES |  update_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "UPDATE") }
| upsert_stmt        %prec VALUES |  upsert_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "UPSERT") }

explain_option_list:
  explain_option_name
  {
    $$.val = []string{$1}
  }
| explain_option_list ',' explain_option_name
  {
    $$.val = append($1.strs(), $3)
  }





prepare_stmt:
  PREPARE table_alias_name prep_type_clause AS preparable_stmt
  {
    $$.val = &ast.Prepare{
      Name: ast.Name($2),
      Types: $3.typeReferences(),
      Statement: $5.stmt(),
    }
  }
| PREPARE table_alias_name prep_type_clause AS OPT PLAN SCONST
  {

    $$.val = &ast.Prepare{
      Name: ast.Name($2),
      Types: $3.typeReferences(),
      Statement: &ast.CannedOptPlan{Plan: $7},
    }
  }
| PREPARE error  { return helpWith(sqllex, "PREPARE") }

prep_type_clause:
  '(' type_list ')'
  {
    $$.val = $2.typeReferences();
  }
|
  {
    $$.val = []ast.ResolvableTypeReference(nil)
  }





execute_stmt:
  EXECUTE table_alias_name execute_param_clause
  {
    $$.val = &ast.Execute{
      Name: ast.Name($2),
      Params: $3.exprs(),
    }
  }
| EXECUTE table_alias_name execute_param_clause DISCARD ROWS
  {

    $$.val = &ast.Execute{
      Name: ast.Name($2),
      Params: $3.exprs(),
      DiscardRows: true,
    }
  }
| EXECUTE error  { return helpWith(sqllex, "EXECUTE") }

execute_param_clause:
  '(' expr_list ')'
  {
    $$.val = $2.exprs()
  }
|
  {
    $$.val = ast.Exprs(nil)
  }





deallocate_stmt:
  DEALLOCATE name
  {
    $$.val = &ast.Deallocate{Name: ast.Name($2)}
  }
| DEALLOCATE PREPARE name
  {
    $$.val = &ast.Deallocate{Name: ast.Name($3)}
  }
| DEALLOCATE ALL
  {
    $$.val = &ast.Deallocate{}
  }
| DEALLOCATE PREPARE ALL
  {
    $$.val = &ast.Deallocate{}
  }
| DEALLOCATE error  { return helpWith(sqllex, "DEALLOCATE") }

















grant_stmt:
  GRANT privileges ON targets TO name_list
  {
    $$.val = &ast.Grant{Privileges: $2.privilegeList(), Grantees: $6.nameList(), Targets: $4.targetList()}
  }
| GRANT privilege_list TO name_list
  {
    $$.val = &ast.GrantRole{Roles: $2.nameList(), Members: $4.nameList(), AdminOption: false}
  }
| GRANT privilege_list TO name_list WITH ADMIN OPTION
  {
    $$.val = &ast.GrantRole{Roles: $2.nameList(), Members: $4.nameList(), AdminOption: true}
  }
| GRANT error  { return helpWith(sqllex, "GRANT") }

















revoke_stmt:
  REVOKE privileges ON targets FROM name_list
  {
    $$.val = &ast.Revoke{Privileges: $2.privilegeList(), Grantees: $6.nameList(), Targets: $4.targetList()}
  }
| REVOKE privilege_list FROM name_list
  {
    $$.val = &ast.RevokeRole{Roles: $2.nameList(), Members: $4.nameList(), AdminOption: false }
  }
| REVOKE ADMIN OPTION FOR privilege_list FROM name_list
  {
    $$.val = &ast.RevokeRole{Roles: $5.nameList(), Members: $7.nameList(), AdminOption: true }
  }
| REVOKE error  { return helpWith(sqllex, "REVOKE") }


privileges:
  ALL
  {
    $$.val = privilege.List{privilege.ALL}
  }
  | privilege_list
  {
     privList, err := privilege.ListFromStrings($1.nameList().ToStrings())
     if err != nil {
       return setErr(sqllex, err)
     }
     $$.val = privList
  }

privilege_list:
  privilege
  {
    $$.val = ast.NameList{ast.Name($1)}
  }
| privilege_list ',' privilege
  {
    $$.val = append($1.nameList(), ast.Name($3))
  }




privilege:
  name
| CREATE
| GRANT
| SELECT

reset_stmt:
  reset_session_stmt   %prec VALUES |   reset_session_stmt   HELPTOKEN %prec UMINUS { return helpWith(sqllex, "RESET") }
| reset_csetting_stmt  %prec VALUES |  reset_csetting_stmt  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "RESET CLUSTER SETTING") }





reset_session_stmt:
  RESET session_var
  {
    $$.val = &ast.SetVar{Name: $2, Values:ast.Exprs{ast.DefaultVal{}}}
  }
| RESET SESSION session_var
  {
    $$.val = &ast.SetVar{Name: $3, Values:ast.Exprs{ast.DefaultVal{}}}
  }
| RESET error  { return helpWith(sqllex, "RESET") }





reset_csetting_stmt:
  RESET CLUSTER SETTING var_name
  {
    $$.val = &ast.SetClusterSetting{Name: strings.Join($4.strs(), "."), Value:ast.DefaultVal{}}
  }
| RESET CLUSTER error  { return helpWith(sqllex, "RESET CLUSTER SETTING") }








use_stmt:
  USE var_value
  {
    $$.val = &ast.SetVar{Name: "database", Values: ast.Exprs{$2.expr()}}
  }
| USE error  { return helpWith(sqllex, "USE") }


nonpreparable_set_stmt:
  set_transaction_stmt  %prec VALUES |   set_transaction_stmt  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SET TRANSACTION") }
| set_exprs_internal   {   }
| SET CONSTRAINTS error { return unimplemented(sqllex, "set constraints") }
| SET LOCAL error { return unimplementedWithIssue(sqllex, 32562) }


preparable_set_stmt:
  set_session_stmt      %prec VALUES |   set_session_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SET SESSION") }
| set_csetting_stmt     %prec VALUES |  set_csetting_stmt     HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SET CLUSTER SETTING") }
| use_stmt              %prec VALUES |  use_stmt              HELPTOKEN %prec UMINUS { return helpWith(sqllex, "USE") }












scrub_stmt:
  scrub_table_stmt
| scrub_database_stmt
| EXPERIMENTAL SCRUB error  { return helpWith(sqllex, "SCRUB") }












scrub_database_stmt:
  EXPERIMENTAL SCRUB DATABASE database_name opt_as_of_clause
  {
    $$.val = &ast.Scrub{Typ: ast.ScrubDatabase, Database: ast.Name($4), AsOf: $5.asOfClause()}
  }
| EXPERIMENTAL SCRUB DATABASE error  { return helpWith(sqllex, "SCRUB DATABASE") }















scrub_table_stmt:
  EXPERIMENTAL SCRUB TABLE table_name opt_as_of_clause opt_scrub_options_clause
  {
    $$.val = &ast.Scrub{
      Typ: ast.ScrubTable,
      Table: $4.unresolvedObjectName(),
      AsOf: $5.asOfClause(),
      Options: $6.scrubOptions(),
    }
  }
| EXPERIMENTAL SCRUB TABLE error  { return helpWith(sqllex, "SCRUB TABLE") }

opt_scrub_options_clause:
  WITH OPTIONS scrub_option_list
  {
    $$.val = $3.scrubOptions()
  }
|
  {
    $$.val = ast.ScrubOptions{}
  }

scrub_option_list:
  scrub_option
  {
    $$.val = ast.ScrubOptions{$1.scrubOption()}
  }
| scrub_option_list ',' scrub_option
  {
    $$.val = append($1.scrubOptions(), $3.scrubOption())
  }

scrub_option:
  INDEX ALL
  {
    $$.val = &ast.ScrubOptionIndex{}
  }
| INDEX '(' name_list ')'
  {
    $$.val = &ast.ScrubOptionIndex{IndexNames: $3.nameList()}
  }
| CONSTRAINT ALL
  {
    $$.val = &ast.ScrubOptionConstraint{}
  }
| CONSTRAINT '(' name_list ')'
  {
    $$.val = &ast.ScrubOptionConstraint{ConstraintNames: $3.nameList()}
  }
| PHYSICAL
  {
    $$.val = &ast.ScrubOptionPhysical{}
  }






set_csetting_stmt:
  SET CLUSTER SETTING var_name to_or_eq var_value
  {
    $$.val = &ast.SetClusterSetting{Name: strings.Join($4.strs(), "."), Value: $6.expr()}
  }
| SET CLUSTER error  { return helpWith(sqllex, "SET CLUSTER SETTING") }

to_or_eq:
  '='
| TO

set_exprs_internal:
  /* SET ROW serves to accelerate parser.parseExprs().
     It cannot be used by clients. */
  SET ROW '(' expr_list ')'
  {
    $$.val = &ast.SetVar{Values: $4.exprs()}
  }











set_session_stmt:
  SET SESSION set_rest_more
  {
    $$.val = $3.stmt()
  }
| SET set_rest_more
  {
    $$.val = $2.stmt()
  }

| SET SESSION CHARACTERISTICS AS TRANSACTION transaction_mode_list
  {
    $$.val = &ast.SetSessionCharacteristics{Modes: $6.transactionModes()}
  }












set_transaction_stmt:
  SET TRANSACTION transaction_mode_list
  {
    $$.val = &ast.SetTransaction{Modes: $3.transactionModes()}
  }
| SET TRANSACTION error  { return helpWith(sqllex, "SET TRANSACTION") }
| SET SESSION TRANSACTION transaction_mode_list
  {
    $$.val = &ast.SetTransaction{Modes: $4.transactionModes()}
  }
| SET SESSION TRANSACTION error  { return helpWith(sqllex, "SET TRANSACTION") }

generic_set:
  var_name to_or_eq var_list
  {


    varName := $1.strs()
    if len(varName) == 1 && varName[0] == "tracing" {
      $$.val = &ast.SetTracing{Values: $3.exprs()}
    } else {
      $$.val = &ast.SetVar{Name: strings.Join($1.strs(), "."), Values: $3.exprs()}
    }
  }

set_rest_more:

   generic_set




| TIME ZONE zone_value
  {

    $$.val = &ast.SetVar{Name: "timezone", Values: ast.Exprs{$3.expr()}}
  }


| SCHEMA var_value
  {

    $$.val = &ast.SetVar{Name: "search_path", Values: ast.Exprs{$2.expr()}}
  }
| SESSION AUTHORIZATION DEFAULT
  {

    $$.val = &ast.SetSessionAuthorizationDefault{}
  }
| SESSION AUTHORIZATION non_reserved_word_or_sconst
  {
    return unimplementedWithIssue(sqllex, 40283)
  }

| set_names
| var_name FROM CURRENT { return unimplemented(sqllex, "set from current") }
| error  { return helpWith(sqllex, "SET SESSION") }





set_names:
  NAMES var_value
  {

    $$.val = &ast.SetVar{Name: "client_encoding", Values: ast.Exprs{$2.expr()}}
  }
| NAMES
  {

    $$.val = &ast.SetVar{Name: "client_encoding", Values: ast.Exprs{ast.DefaultVal{}}}
  }

var_name:
  name
  {
    $$.val = []string{$1}
  }
| name attrs
  {
    $$.val = append([]string{$1}, $2.strs()...)
  }

attrs:
  '.' unrestricted_name
  {
    $$.val = []string{$2}
  }
| attrs '.' unrestricted_name
  {
    $$.val = append($1.strs(), $3)
  }

var_value:
  a_expr
| extra_var_value
  {
    $$.val = ast.Expr(&ast.UnresolvedName{NumParts: 1, Parts: ast.NameParts{$1}})
  }












extra_var_value:
  ON
| cockroachdb_extra_reserved_keyword

var_list:
  var_value
  {
    $$.val = ast.Exprs{$1.expr()}
  }
| var_list ',' var_value
  {
    $$.val = append($1.exprs(), $3.expr())
  }

iso_level:
  READ UNCOMMITTED
  {
    $$.val = ast.SerializableIsolation
  }
| READ COMMITTED
  {
    $$.val = ast.SerializableIsolation
  }
| SNAPSHOT
  {
    $$.val = ast.SerializableIsolation
  }
| REPEATABLE READ
  {
    $$.val = ast.SerializableIsolation
  }
| SERIALIZABLE
  {
    $$.val = ast.SerializableIsolation
  }

user_priority:
  LOW
  {
    $$.val = ast.Low
  }
| NORMAL
  {
    $$.val = ast.Normal
  }
| HIGH
  {
    $$.val = ast.High
  }






zone_value:
  SCONST
  {
    $$.val = ast.NewStrVal($1)
  }
| IDENT
  {
    $$.val = ast.NewStrVal($1)
  }
| interval_value
  {
    $$.val = $1.expr()
  }
| numeric_only
| DEFAULT
  {
    $$.val = ast.DefaultVal{}
  }
| LOCAL
  {
    $$.val = ast.NewStrVal($1)
  }










show_stmt:
  show_backup_stmt           %prec VALUES |   show_backup_stmt           HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW BACKUP") }
| show_columns_stmt          %prec VALUES |  show_columns_stmt          HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW COLUMNS") }
| show_constraints_stmt      %prec VALUES |  show_constraints_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW CONSTRAINTS") }
| show_create_stmt           %prec VALUES |  show_create_stmt           HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW CREATE") }
| show_csettings_stmt        %prec VALUES |  show_csettings_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW CLUSTER SETTING") }
| show_databases_stmt        %prec VALUES |  show_databases_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW DATABASES") }
| show_fingerprints_stmt
| show_grants_stmt           %prec VALUES |  show_grants_stmt           HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW GRANTS") }
| show_histogram_stmt        %prec VALUES |  show_histogram_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW HISTOGRAM") }
| show_indexes_stmt          %prec VALUES |  show_indexes_stmt          HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW INDEXES") }
| show_partitions_stmt       %prec VALUES |  show_partitions_stmt       HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW PARTITIONS") }
| show_jobs_stmt             %prec VALUES |  show_jobs_stmt             HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW JOBS") }
| show_queries_stmt          %prec VALUES |  show_queries_stmt          HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW QUERIES") }
| show_ranges_stmt           %prec VALUES |  show_ranges_stmt           HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW RANGES") }
| show_range_for_row_stmt
| show_roles_stmt            %prec VALUES |  show_roles_stmt            HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW ROLES") }
| show_savepoint_stmt        %prec VALUES |  show_savepoint_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW SAVEPOINT") }
| show_schemas_stmt          %prec VALUES |  show_schemas_stmt          HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW SCHEMAS") }
| show_sequences_stmt        %prec VALUES |  show_sequences_stmt        HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW SEQUENCES") }
| show_session_stmt          %prec VALUES |  show_session_stmt          HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW SESSION") }
| show_sessions_stmt         %prec VALUES |  show_sessions_stmt         HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW SESSIONS") }
| show_stats_stmt            %prec VALUES |  show_stats_stmt            HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW STATISTICS") }
| show_syntax_stmt           %prec VALUES |  show_syntax_stmt           HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW SYNTAX") }
| show_tables_stmt           %prec VALUES |  show_tables_stmt           HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW TABLES") }
| show_trace_stmt            %prec VALUES |  show_trace_stmt            HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW TRACE") }
| show_transaction_stmt      %prec VALUES |  show_transaction_stmt      HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW TRANSACTION") }
| show_users_stmt            %prec VALUES |  show_users_stmt            HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW USERS") }
| show_zone_stmt
| SHOW error                 { return helpWith(sqllex, "SHOW") }
| show_last_query_stats_stmt  %prec VALUES |  show_last_query_stats_stmt  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SHOW LAST QUERY STATISTICS") }



close_cursor_stmt:
	CLOSE ALL { }
| CLOSE cursor_name { return unimplementedWithIssue(sqllex, 41412) }

declare_cursor_stmt:
	DECLARE { return unimplementedWithIssue(sqllex, 41412) }

reindex_stmt:
  REINDEX TABLE error
  {

    return purposelyUnimplemented(sqllex, "reindex table", "CockroachDB does not require reindexing.")
  }
| REINDEX INDEX error
  {

    return purposelyUnimplemented(sqllex, "reindex index", "CockroachDB does not require reindexing.")
  }
| REINDEX DATABASE error
  {

    return purposelyUnimplemented(sqllex, "reindex database", "CockroachDB does not require reindexing.")
  }
| REINDEX SYSTEM error
  {

    return purposelyUnimplemented(sqllex, "reindex system", "CockroachDB does not require reindexing.")
  }





show_session_stmt:
  SHOW session_var         { $$.val = &ast.ShowVar{Name: $2} }
| SHOW SESSION session_var { $$.val = &ast.ShowVar{Name: $3} }
| SHOW SESSION error  { return helpWith(sqllex, "SHOW SESSION") }

session_var:
  IDENT



| ALL
| DATABASE


| NAMES { $$ = "client_encoding" }
| SESSION_USER

| TIME ZONE { $$ = "timezone" }
| TIME error  { return helpWith(sqllex, "SHOW SESSION") }











show_stats_stmt:
  SHOW STATISTICS FOR TABLE table_name
  {
    $$.val = &ast.ShowTableStats{Table: $5.unresolvedObjectName()}
  }
| SHOW STATISTICS USING JSON FOR TABLE table_name
  {

    $$.val = &ast.ShowTableStats{Table: $7.unresolvedObjectName(), UsingJSON: true}
  }
| SHOW STATISTICS error  { return helpWith(sqllex, "SHOW STATISTICS") }








show_histogram_stmt:
  SHOW HISTOGRAM ICONST
  {

    id, err := $3.numVal().AsInt64()
    if err != nil {
      return setErr(sqllex, err)
    }
    $$.val = &ast.ShowHistogram{HistogramID: id}
  }
| SHOW HISTOGRAM error  { return helpWith(sqllex, "SHOW HISTOGRAM") }





show_backup_stmt:
  SHOW BACKUP string_or_placeholder opt_with_options
  {
    $$.val = &ast.ShowBackup{
      Details: ast.BackupDefaultDetails,
      Path:    $3.expr(),
      Options: $4.kvOptions(),
    }
  }
| SHOW BACKUP SCHEMAS string_or_placeholder opt_with_options
  {
    $$.val = &ast.ShowBackup{
      Details: ast.BackupDefaultDetails,
      ShouldIncludeSchemas: true,
      Path:    $4.expr(),
      Options: $5.kvOptions(),
    }
  }
| SHOW BACKUP RANGES string_or_placeholder opt_with_options
  {

    $$.val = &ast.ShowBackup{
      Details: ast.BackupRangeDetails,
      Path:    $4.expr(),
      Options: $5.kvOptions(),
    }
  }
| SHOW BACKUP FILES string_or_placeholder opt_with_options
  {

    $$.val = &ast.ShowBackup{
      Details: ast.BackupFileDetails,
      Path:    $4.expr(),
      Options: $5.kvOptions(),
    }
  }
| SHOW BACKUP error  { return helpWith(sqllex, "SHOW BACKUP") }







show_csettings_stmt:
  SHOW CLUSTER SETTING var_name
  {
    $$.val = &ast.ShowClusterSetting{Name: strings.Join($4.strs(), ".")}
  }
| SHOW CLUSTER SETTING ALL
  {
    $$.val = &ast.ShowClusterSettingList{All: true}
  }
| SHOW CLUSTER error  { return helpWith(sqllex, "SHOW CLUSTER SETTING") }
| SHOW ALL CLUSTER SETTINGS
  {
    $$.val = &ast.ShowClusterSettingList{All: true}
  }
| SHOW ALL CLUSTER error  { return helpWith(sqllex, "SHOW CLUSTER SETTING") }
| SHOW CLUSTER SETTINGS
  {
    $$.val = &ast.ShowClusterSettingList{}
  }
| SHOW PUBLIC CLUSTER SETTINGS
  {
    $$.val = &ast.ShowClusterSettingList{}
  }
| SHOW PUBLIC CLUSTER error  { return helpWith(sqllex, "SHOW CLUSTER SETTING") }





show_columns_stmt:
  SHOW COLUMNS FROM table_name with_comment
  {
    $$.val = &ast.ShowColumns{Table: $4.unresolvedObjectName(), WithComment: $5.bool()}
  }
| SHOW COLUMNS error  { return helpWith(sqllex, "SHOW COLUMNS") }





show_partitions_stmt:
  SHOW PARTITIONS FROM TABLE table_name
  {
    $$.val = &ast.ShowPartitions{IsTable: true, Table: $5.unresolvedObjectName()}
  }
| SHOW PARTITIONS FROM DATABASE database_name
  {
    $$.val = &ast.ShowPartitions{IsDB: true, Database: ast.Name($5)}
  }
| SHOW PARTITIONS FROM INDEX table_index_name
  {
    $$.val = &ast.ShowPartitions{IsIndex: true, Index: $5.tableIndexName()}
  }
| SHOW PARTITIONS FROM INDEX table_name '@' '*'
  {
    $$.val = &ast.ShowPartitions{IsTable: true, Table: $5.unresolvedObjectName()}
  }
| SHOW PARTITIONS error  { return helpWith(sqllex, "SHOW PARTITIONS") }





show_databases_stmt:
  SHOW DATABASES with_comment
  {
    $$.val = &ast.ShowDatabases{WithComment: $3.bool()}
  }
| SHOW DATABASES error  { return helpWith(sqllex, "SHOW DATABASES") }










show_grants_stmt:
  SHOW GRANTS opt_on_targets_roles for_grantee_clause
  {
    lst := $3.targetListPtr()
    if lst != nil && lst.ForRoles {
      $$.val = &ast.ShowRoleGrants{Roles: lst.Roles, Grantees: $4.nameList()}
    } else {
      $$.val = &ast.ShowGrants{Targets: lst, Grantees: $4.nameList()}
    }
  }
| SHOW GRANTS error  { return helpWith(sqllex, "SHOW GRANTS") }





show_indexes_stmt:
  SHOW INDEX FROM table_name with_comment
  {
    $$.val = &ast.ShowIndexes{Table: $4.unresolvedObjectName(), WithComment: $5.bool()}
  }
| SHOW INDEX error  { return helpWith(sqllex, "SHOW INDEXES") }
| SHOW INDEX FROM DATABASE database_name with_comment
  {
    $$.val = &ast.ShowDatabaseIndexes{Database: ast.Name($5), WithComment: $6.bool()}
  }
| SHOW INDEXES FROM table_name with_comment
  {
    $$.val = &ast.ShowIndexes{Table: $4.unresolvedObjectName(), WithComment: $5.bool()}
  }
| SHOW INDEXES FROM DATABASE database_name with_comment
  {
    $$.val = &ast.ShowDatabaseIndexes{Database: ast.Name($5), WithComment: $6.bool()}
  }
| SHOW INDEXES error  { return helpWith(sqllex, "SHOW INDEXES") }
| SHOW KEYS FROM table_name with_comment
  {
    $$.val = &ast.ShowIndexes{Table: $4.unresolvedObjectName(), WithComment: $5.bool()}
  }
| SHOW KEYS FROM DATABASE database_name with_comment
  {
    $$.val = &ast.ShowDatabaseIndexes{Database: ast.Name($5), WithComment: $6.bool()}
  }
| SHOW KEYS error  { return helpWith(sqllex, "SHOW INDEXES") }





show_constraints_stmt:
  SHOW CONSTRAINT FROM table_name
  {
    $$.val = &ast.ShowConstraints{Table: $4.unresolvedObjectName()}
  }
| SHOW CONSTRAINT error  { return helpWith(sqllex, "SHOW CONSTRAINTS") }
| SHOW CONSTRAINTS FROM table_name
  {
    $$.val = &ast.ShowConstraints{Table: $4.unresolvedObjectName()}
  }
| SHOW CONSTRAINTS error  { return helpWith(sqllex, "SHOW CONSTRAINTS") }





show_queries_stmt:
  SHOW opt_cluster QUERIES
  {
    $$.val = &ast.ShowQueries{All: false, Cluster: $2.bool()}
  }
| SHOW opt_cluster QUERIES error  { return helpWith(sqllex, "SHOW QUERIES") }
| SHOW ALL opt_cluster QUERIES
  {
    $$.val = &ast.ShowQueries{All: true, Cluster: $3.bool()}
  }
| SHOW ALL opt_cluster QUERIES error  { return helpWith(sqllex, "SHOW QUERIES") }

opt_cluster:

  { $$.val = true }
| CLUSTER
  { $$.val = true }
| LOCAL
  { $$.val = false }







show_jobs_stmt:
  SHOW AUTOMATIC JOBS
  {
    $$.val = &ast.ShowJobs{Automatic: true}
  }
| SHOW JOBS
  {
    $$.val = &ast.ShowJobs{Automatic: false}
  }
| SHOW AUTOMATIC JOBS error  { return helpWith(sqllex, "SHOW JOBS") }
| SHOW JOBS error  { return helpWith(sqllex, "SHOW JOBS") }
| SHOW JOBS select_stmt
  {
    $$.val = &ast.ShowJobs{Jobs: $3.slct()}
  }
| SHOW JOBS WHEN COMPLETE select_stmt
  {
    $$.val = &ast.ShowJobs{Jobs: $5.slct(), Block: true}
  }
| SHOW JOBS select_stmt error  { return helpWith(sqllex, "SHOW JOBS") }
| SHOW JOB a_expr
  {
    $$.val = &ast.ShowJobs{
      Jobs: &ast.Select{
        Select: &ast.ValuesClause{Rows: []ast.Exprs{ast.Exprs{$3.expr()}}},
      },
    }
  }
| SHOW JOB WHEN COMPLETE a_expr
  {
    $$.val = &ast.ShowJobs{
      Jobs: &ast.Select{
        Select: &ast.ValuesClause{Rows: []ast.Exprs{ast.Exprs{$5.expr()}}},
      },
      Block: true,
    }
  }
| SHOW JOB error  { return helpWith(sqllex, "SHOW JOBS") }






show_trace_stmt:
  SHOW opt_compact TRACE FOR SESSION
  {
    $$.val = &ast.ShowTraceForSession{TraceType: ast.ShowTraceRaw, Compact: $2.bool()}
  }
| SHOW opt_compact TRACE error  { return helpWith(sqllex, "SHOW TRACE") }
| SHOW opt_compact KV TRACE FOR SESSION
  {
    $$.val = &ast.ShowTraceForSession{TraceType: ast.ShowTraceKV, Compact: $2.bool()}
  }
| SHOW opt_compact KV error  { return helpWith(sqllex, "SHOW TRACE") }
| SHOW opt_compact EXPERIMENTAL_REPLICA TRACE FOR SESSION
  {

    $$.val = &ast.ShowTraceForSession{TraceType: ast.ShowTraceReplica, Compact: $2.bool()}
  }
| SHOW opt_compact EXPERIMENTAL_REPLICA error  { return helpWith(sqllex, "SHOW TRACE") }

opt_compact:
  COMPACT { $$.val = true }
|   { $$.val = false }





show_sessions_stmt:
  SHOW opt_cluster SESSIONS
  {
    $$.val = &ast.ShowSessions{Cluster: $2.bool()}
  }
| SHOW opt_cluster SESSIONS error  { return helpWith(sqllex, "SHOW SESSIONS") }
| SHOW ALL opt_cluster SESSIONS
  {
    $$.val = &ast.ShowSessions{All: true, Cluster: $3.bool()}
  }
| SHOW ALL opt_cluster SESSIONS error  { return helpWith(sqllex, "SHOW SESSIONS") }





show_tables_stmt:
  SHOW TABLES FROM name '.' name with_comment
  {
    $$.val = &ast.ShowTables{ObjectNamePrefix:ast.ObjectNamePrefix{
        CatalogName: ast.Name($4),
        ExplicitCatalog: true,
        SchemaName: ast.Name($6),
        ExplicitSchema: true,
    },
    WithComment: $7.bool()}
  }
| SHOW TABLES FROM name with_comment
  {
    $$.val = &ast.ShowTables{ObjectNamePrefix:ast.ObjectNamePrefix{


        SchemaName: ast.Name($4),
        ExplicitSchema: true,
    },
    WithComment: $5.bool()}
  }
| SHOW TABLES with_comment
  {
    $$.val = &ast.ShowTables{WithComment: $3.bool()}
  }
| SHOW TABLES error  { return helpWith(sqllex, "SHOW TABLES") }

with_comment:
  WITH COMMENT { $$.val = true }
|    { $$.val = false }




show_schemas_stmt:
  SHOW SCHEMAS FROM name
  {
    $$.val = &ast.ShowSchemas{Database: ast.Name($4)}
  }
| SHOW SCHEMAS
  {
    $$.val = &ast.ShowSchemas{}
  }
| SHOW SCHEMAS error  { return helpWith(sqllex, "SHOW SCHEMAS") }




show_sequences_stmt:
  SHOW SEQUENCES FROM name
  {
    $$.val = &ast.ShowSequences{Database: ast.Name($4)}
  }
| SHOW SEQUENCES
  {
    $$.val = &ast.ShowSequences{}
  }
| SHOW SEQUENCES error  { return helpWith(sqllex, "SHOW SEQUENCES") }




show_syntax_stmt:
  SHOW SYNTAX SCONST
  {

    $$.val = &ast.ShowSyntax{Statement: $3}
  }
| SHOW SYNTAX error  { return helpWith(sqllex, "SHOW SYNTAX") }




show_last_query_stats_stmt:
  SHOW LAST QUERY STATISTICS
  {

   $$.val = &ast.ShowLastQueryStatistics{}
  }




show_savepoint_stmt:
  SHOW SAVEPOINT STATUS
  {
    $$.val = &ast.ShowSavepointStatus{}
  }
| SHOW SAVEPOINT error  { return helpWith(sqllex, "SHOW SAVEPOINT") }





show_transaction_stmt:
  SHOW TRANSACTION ISOLATION LEVEL
  {

    $$.val = &ast.ShowVar{Name: "transaction_isolation"}
  }
| SHOW TRANSACTION PRIORITY
  {

    $$.val = &ast.ShowVar{Name: "transaction_priority"}
  }
| SHOW TRANSACTION STATUS
  {

    $$.val = &ast.ShowTransactionStatus{}
  }
| SHOW TRANSACTION error  { return helpWith(sqllex, "SHOW TRANSACTION") }





show_create_stmt:
  SHOW CREATE table_name
  {
    $$.val = &ast.ShowCreate{Name: $3.unresolvedObjectName()}
  }
| SHOW CREATE create_kw table_name
  {

    $$.val = &ast.ShowCreate{Name: $4.unresolvedObjectName()}
  }
| SHOW CREATE error  { return helpWith(sqllex, "SHOW CREATE") }

create_kw:
  TABLE
| VIEW
| SEQUENCE





show_users_stmt:
  SHOW USERS
  {
    $$.val = &ast.ShowUsers{}
  }
| SHOW USERS error  { return helpWith(sqllex, "SHOW USERS") }





show_roles_stmt:
  SHOW ROLES
  {
    $$.val = &ast.ShowRoles{}
  }
| SHOW ROLES error  { return helpWith(sqllex, "SHOW ROLES") }

show_zone_stmt:
  SHOW ZONE CONFIGURATION FOR RANGE zone_name
  {
    $$.val = &ast.ShowZoneConfig{ZoneSpecifier: ast.ZoneSpecifier{NamedZone: ast.UnrestrictedName($6)}}
  }
| SHOW ZONE CONFIGURATION FOR DATABASE database_name
  {
    $$.val = &ast.ShowZoneConfig{ZoneSpecifier: ast.ZoneSpecifier{Database: ast.Name($6)}}
  }
| SHOW ZONE CONFIGURATION FOR TABLE table_name opt_partition
  {
    name := $6.unresolvedObjectName().ToTableName()
    $$.val = &ast.ShowZoneConfig{ZoneSpecifier: ast.ZoneSpecifier{
        TableOrIndex: ast.TableIndexName{Table: name},
        Partition: ast.Name($7),
    }}
  }
| SHOW ZONE CONFIGURATION FOR PARTITION partition_name OF TABLE table_name
  {
    name := $9.unresolvedObjectName().ToTableName()
    $$.val = &ast.ShowZoneConfig{ZoneSpecifier: ast.ZoneSpecifier{
      TableOrIndex: ast.TableIndexName{Table: name},
      Partition: ast.Name($6),
    }}
  }
| SHOW ZONE CONFIGURATION FOR INDEX table_index_name opt_partition
  {
    $$.val = &ast.ShowZoneConfig{ZoneSpecifier: ast.ZoneSpecifier{
      TableOrIndex: $6.tableIndexName(),
      Partition: ast.Name($7),
    }}
  }
| SHOW ZONE CONFIGURATION FOR PARTITION partition_name OF INDEX table_index_name
  {
    $$.val = &ast.ShowZoneConfig{ZoneSpecifier: ast.ZoneSpecifier{
      TableOrIndex: $9.tableIndexName(),
      Partition: ast.Name($6),
    }}
  }
| SHOW ZONE CONFIGURATIONS
  {
    $$.val = &ast.ShowZoneConfig{}
  }
| SHOW ALL ZONE CONFIGURATIONS
  {
    $$.val = &ast.ShowZoneConfig{}
  }






show_range_for_row_stmt:
  SHOW RANGE FROM TABLE table_name FOR ROW '(' expr_list ')'
  {
    name := $5.unresolvedObjectName().ToTableName()
    $$.val = &ast.ShowRangeForRow{
      Row: $9.exprs(),
      TableOrIndex: ast.TableIndexName{Table: name},
    }
  }
| SHOW RANGE FROM INDEX table_index_name FOR ROW '(' expr_list ')'
  {
    $$.val = &ast.ShowRangeForRow{
      Row: $9.exprs(),
      TableOrIndex: $5.tableIndexName(),
    }
  }
| SHOW RANGE error  { return helpWith(sqllex, "SHOW RANGE") }






show_ranges_stmt:
  SHOW RANGES FROM TABLE table_name
  {
    name := $5.unresolvedObjectName().ToTableName()
    $$.val = &ast.ShowRanges{TableOrIndex: ast.TableIndexName{Table: name}}
  }
| SHOW RANGES FROM INDEX table_index_name
  {
    $$.val = &ast.ShowRanges{TableOrIndex: $5.tableIndexName()}
  }
| SHOW RANGES FROM DATABASE database_name
  {
    $$.val = &ast.ShowRanges{DatabaseName: ast.Name($5)}
  }
| SHOW RANGES error  { return helpWith(sqllex, "SHOW RANGES") }

show_fingerprints_stmt:
  SHOW EXPERIMENTAL_FINGERPRINTS FROM TABLE table_name
  {

    $$.val = &ast.ShowFingerprints{Table: $5.unresolvedObjectName()}
  }

opt_on_targets_roles:
  ON targets_roles
  {
    tmp := $2.targetList()
    $$.val = &tmp
  }
|
  {
    $$.val = (*ast.TargetList)(nil)
  }



















































































































targets:
  IDENT
  {
    $$.val = ast.TargetList{Tables: ast.TablePatterns{&ast.UnresolvedName{NumParts:1, Parts: ast.NameParts{$1}}}}
  }
| col_name_keyword
  {
    $$.val = ast.TargetList{Tables: ast.TablePatterns{&ast.UnresolvedName{NumParts:1, Parts: ast.NameParts{$1}}}}
  }
| unreserved_keyword
  {
































    $$.val = ast.TargetList{
      Tables: ast.TablePatterns{&ast.UnresolvedName{NumParts:1, Parts: ast.NameParts{$1}}},
      ForRoles: $1 == "role",
    }
  }
| complex_table_pattern
  {
    $$.val = ast.TargetList{Tables: ast.TablePatterns{$1.unresolvedName()}}
  }
| table_pattern ',' table_pattern_list
  {
    remainderPats := $3.tablePatterns()
    $$.val = ast.TargetList{Tables: append(ast.TablePatterns{$1.unresolvedName()}, remainderPats...)}
  }
| TABLE table_pattern_list
  {
    $$.val = ast.TargetList{Tables: $2.tablePatterns()}
  }
| TENANT iconst64
  {
    tenID := uint64($2.int64())
    if tenID == 0 {
		  return setErr(sqllex, errors.New("invalid tenant ID"))
	  }
    $$.val = ast.TargetList{Tenant: roachpb.MakeTenantID(tenID)}
  }
| DATABASE name_list
  {
    $$.val = ast.TargetList{Databases: $2.nameList()}
  }




targets_roles:
  ROLE name_list
  {
     $$.val = ast.TargetList{ForRoles: true, Roles: $2.nameList()}
  }
| targets

for_grantee_clause:
  FOR name_list
  {
    $$.val = $2.nameList()
  }
|
  {
    $$.val = ast.NameList(nil)
  }







pause_stmt:
  PAUSE JOB a_expr
  {
    $$.val = &ast.ControlJobs{
      Jobs: &ast.Select{
        Select: &ast.ValuesClause{Rows: []ast.Exprs{ast.Exprs{$3.expr()}}},
      },
      Command: ast.PauseJob,
    }
  }
| PAUSE JOBS select_stmt
  {
    $$.val = &ast.ControlJobs{Jobs: $3.slct(), Command: ast.PauseJob}
  }
| PAUSE error  { return helpWith(sqllex, "PAUSE JOBS") }





create_schema_stmt:
  CREATE SCHEMA schema_name
  {
    $$.val = &ast.CreateSchema{
      Schema: $3,
    }
  }
| CREATE SCHEMA IF NOT EXISTS schema_name
  {
    $$.val = &ast.CreateSchema{
      Schema: $6,
      IfNotExists: true,
    }
  }
| CREATE SCHEMA error  { return helpWith(sqllex, "CREATE SCHEMA") }




































create_table_stmt:
  CREATE opt_temp_create_table TABLE table_name '(' opt_table_elem_list ')' opt_interleave opt_partition_by opt_table_with opt_create_table_on_commit
  {
    name := $4.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateTable{
      Table: name,
      IfNotExists: false,
      Interleave: $8.interleave(),
      Defs: $6.tblDefs(),
      AsSource: nil,
      PartitionBy: $9.partitionBy(),
      Temporary: $2.persistenceType(),
      StorageParams: $10.storageParams(),
      OnCommit: $11.createTableOnCommitSetting(),
    }
  }
| CREATE opt_temp_create_table TABLE IF NOT EXISTS table_name '(' opt_table_elem_list ')' opt_interleave opt_partition_by opt_table_with opt_create_table_on_commit
  {
    name := $7.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateTable{
      Table: name,
      IfNotExists: true,
      Interleave: $11.interleave(),
      Defs: $9.tblDefs(),
      AsSource: nil,
      PartitionBy: $12.partitionBy(),
      Temporary: $2.persistenceType(),
      StorageParams: $13.storageParams(),
      OnCommit: $14.createTableOnCommitSetting(),
    }
  }

opt_table_with:

  {
    $$.val = nil
  }
| WITHOUT OIDS
  {


    $$.val = nil
  }
| WITH '(' storage_parameter_list ')'
  {

    $$.val = $3.storageParams()
  }
| WITH OIDS error
  {
    return unimplemented(sqllex, "create table with oids")
  }

opt_create_table_on_commit:

  {
    $$.val = ast.CreateTableOnCommitUnset
  }
| ON COMMIT PRESERVE ROWS
  {

    $$.val = ast.CreateTableOnCommitPreserveRows
  }
| ON COMMIT DELETE ROWS error
  {

    return unimplementedWithIssueDetail(sqllex, 46556, "delete rows")
  }
| ON COMMIT DROP error
  {

    return unimplementedWithIssueDetail(sqllex, 46556, "drop")
  }

storage_parameter:
  name '=' d_expr
  {
    $$.val = ast.StorageParam{Key: ast.Name($1), Value: $3.expr()}
  }
|  SCONST '=' d_expr
  {
    $$.val = ast.StorageParam{Key: ast.Name($1), Value: $3.expr()}
  }

storage_parameter_list:
  storage_parameter
  {
    $$.val = []ast.StorageParam{$1.storageParam()}
  }
|  storage_parameter_list ',' storage_parameter
  {
    $$.val = append($1.storageParams(), $3.storageParam())
  }

create_table_as_stmt:
  CREATE opt_temp_create_table TABLE table_name create_as_opt_col_list opt_table_with AS select_stmt opt_create_as_data opt_create_table_on_commit
  {
    name := $4.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateTable{
      Table: name,
      IfNotExists: false,
      Interleave: nil,
      Defs: $5.tblDefs(),
      AsSource: $8.slct(),
      StorageParams: $6.storageParams(),
      OnCommit: $10.createTableOnCommitSetting(),
    }
  }
| CREATE opt_temp_create_table TABLE IF NOT EXISTS table_name create_as_opt_col_list opt_table_with AS select_stmt opt_create_as_data opt_create_table_on_commit
  {
    name := $7.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateTable{
      Table: name,
      IfNotExists: true,
      Interleave: nil,
      Defs: $8.tblDefs(),
      AsSource: $11.slct(),
      StorageParams: $9.storageParams(),
      OnCommit: $13.createTableOnCommitSetting(),
    }
  }

opt_create_as_data:
     {   }
| WITH DATA    {     }
| WITH NO DATA { return unimplemented(sqllex, "create table as with no data") }

/*
 * Redundancy here is needed to avoid shift/reduce conflicts,
 * since TEMP is not a reserved word.  See also OptTempTableName.
 *
 * NOTE: we accept both GLOBAL and LOCAL options.  They currently do nothing,
 * but future versions might consider GLOBAL to request SQL-spec-compliant
 * temp table behavior.  Since we have no modules the
 * LOCAL keyword is really meaningless; furthermore, some other products
 * implement LOCAL as meaning the same as our default temp table behavior,
 * so we'll probably continue to treat LOCAL as a noise word.
 *
 * NOTE: PG only accepts GLOBAL/LOCAL keywords for temp tables -- not sequences
 * and views. These keywords are no-ops in PG. This behavior is replicated by
 * making the distinction between opt_temp and opt_temp_create_table.
 */
 opt_temp:
  TEMPORARY         { $$.val = true }
| TEMP              { $$.val = true }
|           { $$.val = false }

opt_temp_create_table:
   opt_temp
|  LOCAL TEMPORARY   { $$.val = true }
| LOCAL TEMP        { $$.val = true }
| GLOBAL TEMPORARY  { $$.val = true }
| GLOBAL TEMP       { $$.val = true }
| UNLOGGED          { return unimplemented(sqllex, "create unlogged") }

opt_table_elem_list:
  table_elem_list
|
  {
    $$.val = ast.TableDefs(nil)
  }

table_elem_list:
  table_elem
  {
    $$.val = ast.TableDefs{$1.tblDef()}
  }
| table_elem_list ',' table_elem
  {
    $$.val = append($1.tblDefs(), $3.tblDef())
  }

table_elem:
  column_def
  {
    $$.val = $1.colDef()
  }
| index_def
| family_def
| table_constraint
  {
    $$.val = $1.constraintDef()
  }
| LIKE table_name like_table_option_list
  {
    $$.val = &ast.LikeTableDef{
      Name: $2.unresolvedObjectName().ToTableName(),
      Options: $3.likeTableOptionList(),
    }
  }

like_table_option_list:
  like_table_option_list INCLUDING like_table_option
  {
    $$.val = append($1.likeTableOptionList(), $3.likeTableOption())
  }
| like_table_option_list EXCLUDING like_table_option
  {
    opt := $3.likeTableOption()
    opt.Excluded = true
    $$.val = append($1.likeTableOptionList(), opt)
  }
|
  {
    $$.val = []ast.LikeTableOption(nil)
  }

like_table_option:
  COMMENTS			{ return unimplementedWithIssueDetail(sqllex, 47071, "like table in/excluding comments") }
| CONSTRAINTS		{ $$.val = ast.LikeTableOption{Opt: ast.LikeTableOptConstraints} }
| DEFAULTS			{ $$.val = ast.LikeTableOption{Opt: ast.LikeTableOptDefaults} }
| IDENTITY	  	{ return unimplementedWithIssueDetail(sqllex, 47071, "like table in/excluding identity") }
| GENERATED			{ $$.val = ast.LikeTableOption{Opt: ast.LikeTableOptGenerated} }
| INDEXES			{ $$.val = ast.LikeTableOption{Opt: ast.LikeTableOptIndexes} }
| STATISTICS		{ return unimplementedWithIssueDetail(sqllex, 47071, "like table in/excluding statistics") }
| STORAGE			{ return unimplementedWithIssueDetail(sqllex, 47071, "like table in/excluding storage") }
| ALL				{ $$.val = ast.LikeTableOption{Opt: ast.LikeTableOptAll} }


opt_interleave:
  INTERLEAVE IN PARENT table_name '(' name_list ')' opt_interleave_drop_behavior
  {
    name := $4.unresolvedObjectName().ToTableName()
    $$.val = &ast.InterleaveDef{
      Parent: name,
      Fields: $6.nameList(),
      DropBehavior: $8.dropBehavior(),
    }
  }
|
  {
    $$.val = (*ast.InterleaveDef)(nil)
  }


opt_interleave_drop_behavior:
  CASCADE
  {

    $$.val = ast.DropCascade
  }
| RESTRICT
  {

    $$.val = ast.DropRestrict
  }
|
  {
    $$.val = ast.DropDefault
  }

partition:
  PARTITION partition_name
  {
    $$ = $2
  }

opt_partition:
  partition
|
  {
    $$ = ""
  }

opt_partition_by:
  partition_by
|
  {
    $$.val = (*ast.PartitionBy)(nil)
  }

partition_by:
  PARTITION BY LIST '(' name_list ')' '(' list_partitions ')'
  {
    $$.val = &ast.PartitionBy{
      Fields: $5.nameList(),
      List: $8.listPartitions(),
    }
  }
| PARTITION BY RANGE '(' name_list ')' '(' range_partitions ')'
  {
    $$.val = &ast.PartitionBy{
      Fields: $5.nameList(),
      Range: $8.rangePartitions(),
    }
  }
| PARTITION BY NOTHING
  {
    $$.val = (*ast.PartitionBy)(nil)
  }

list_partitions:
  list_partition
  {
    $$.val = []ast.ListPartition{$1.listPartition()}
  }
| list_partitions ',' list_partition
  {
    $$.val = append($1.listPartitions(), $3.listPartition())
  }

list_partition:
  partition VALUES IN '(' expr_list ')' opt_partition_by
  {
    $$.val = ast.ListPartition{
      Name: ast.UnrestrictedName($1),
      Exprs: $5.exprs(),
      Subpartition: $7.partitionBy(),
    }
  }

range_partitions:
  range_partition
  {
    $$.val = []ast.RangePartition{$1.rangePartition()}
  }
| range_partitions ',' range_partition
  {
    $$.val = append($1.rangePartitions(), $3.rangePartition())
  }

range_partition:
  partition VALUES FROM '(' expr_list ')' TO '(' expr_list ')' opt_partition_by
  {
    $$.val = ast.RangePartition{
      Name: ast.UnrestrictedName($1),
      From: $5.exprs(),
      To: $9.exprs(),
      Subpartition: $11.partitionBy(),
    }
  }




column_def:
  column_name typename col_qual_list
  {
    typ := $2.typeReference()
    tableDef, err := ast.NewColumnTableDef(ast.Name($1), typ, ast.IsReferenceSerialType(typ), $3.colQuals())
    if err != nil {
      return setErr(sqllex, err)
    }
    $$.val = tableDef
  }

col_qual_list:
  col_qual_list col_qualification
  {
    $$.val = append($1.colQuals(), $2.colQual())
  }
|
  {
    $$.val = []ast.NamedColumnQualification(nil)
  }

col_qualification:
  CONSTRAINT constraint_name col_qualification_elem
  {
    $$.val = ast.NamedColumnQualification{Name: ast.Name($2), Qualification: $3.colQualElem()}
  }
| col_qualification_elem
  {
    $$.val = ast.NamedColumnQualification{Qualification: $1.colQualElem()}
  }
| COLLATE collation_name
  {
    $$.val = ast.NamedColumnQualification{Qualification: ast.ColumnCollation($2)}
  }
| FAMILY family_name
  {
    $$.val = ast.NamedColumnQualification{Qualification: &ast.ColumnFamilyConstraint{Family: ast.Name($2)}}
  }
| CREATE FAMILY family_name
  {
    $$.val = ast.NamedColumnQualification{Qualification: &ast.ColumnFamilyConstraint{Family: ast.Name($3), Create: true}}
  }
| CREATE FAMILY
  {
    $$.val = ast.NamedColumnQualification{Qualification: &ast.ColumnFamilyConstraint{Create: true}}
  }
| CREATE IF NOT EXISTS FAMILY family_name
  {
    $$.val = ast.NamedColumnQualification{Qualification: &ast.ColumnFamilyConstraint{Family: ast.Name($6), Create: true, IfNotExists: true}}
  }













col_qualification_elem:
  NOT NULL
  {
    $$.val = ast.NotNullConstraint{}
  }
| NULL
  {
    $$.val = ast.NullConstraint{}
  }
| UNIQUE
  {
    $$.val = ast.UniqueConstraint{}
  }
| PRIMARY KEY
  {
    $$.val = ast.PrimaryKeyConstraint{}
  }
| PRIMARY KEY USING HASH WITH BUCKET_COUNT '=' a_expr
{
  $$.val = ast.ShardedPrimaryKeyConstraint{
    Sharded: true,
    ShardBuckets: $8.expr(),
  }
}
| CHECK '(' a_expr ')'
  {
    $$.val = &ast.ColumnCheckConstraint{Expr: $3.expr()}
  }
| DEFAULT b_expr
  {
    $$.val = &ast.ColumnDefault{Expr: $2.expr()}
  }
| REFERENCES table_name opt_name_parens key_match reference_actions
 {
    name := $2.unresolvedObjectName().ToTableName()
    $$.val = &ast.ColumnFKConstraint{
      Table: name,
      Col: ast.Name($3),
      Actions: $5.referenceActions(),
      Match: $4.compositeKeyMatchMethod(),
    }
 }
| generated_as '(' a_expr ')' STORED
 {
    $$.val = &ast.ColumnComputedDef{Expr: $3.expr()}
 }
| generated_as '(' a_expr ')' VIRTUAL
 {
    return unimplemented(sqllex, "virtual computed columns")
 }
| generated_as error
 {
    sqllex.Error("use AS ( <expr> ) STORED")
    return 1
 }


generated_as:
  AS {}
| GENERATED_ALWAYS ALWAYS AS {}


index_def:
  INDEX opt_index_name '(' index_params ')' opt_hash_sharded opt_storing opt_interleave opt_partition_by opt_where_clause
  {
    $$.val = &ast.IndexTableDef{
      Name:    ast.Name($2),
      Columns: $4.idxElems(),
      Sharded: $6.shardedIndexDef(),
      Storing: $7.nameList(),
      Interleave: $8.interleave(),
      PartitionBy: $9.partitionBy(),
      Predicate: $10.expr(),
    }
  }
| UNIQUE INDEX opt_index_name '(' index_params ')' opt_hash_sharded opt_storing opt_interleave opt_partition_by opt_where_clause
  {
    $$.val = &ast.UniqueConstraintTableDef{
      IndexTableDef: ast.IndexTableDef {
        Name:    ast.Name($3),
        Columns: $5.idxElems(),
        Sharded: $7.shardedIndexDef(),
        Storing: $8.nameList(),
        Interleave: $9.interleave(),
        PartitionBy: $10.partitionBy(),
        Predicate: $11.expr(),
      },
    }
  }
| INVERTED INDEX opt_name '(' index_params ')' opt_where_clause
  {
    $$.val = &ast.IndexTableDef{
      Name:    ast.Name($3),
      Columns: $5.idxElems(),
      Inverted: true,
      Predicate: $7.expr(),
    }
  }

family_def:
  FAMILY opt_family_name '(' name_list ')'
  {
    $$.val = &ast.FamilyTableDef{
      Name: ast.Name($2),
      Columns: $4.nameList(),
    }
  }




table_constraint:
  CONSTRAINT constraint_name constraint_elem
  {
    $$.val = $3.constraintDef()
    $$.val.(ast.ConstraintTableDef).SetName(ast.Name($2))
  }
| constraint_elem
  {
    $$.val = $1.constraintDef()
  }

constraint_elem:
  CHECK '(' a_expr ')' opt_deferrable
  {
    $$.val = &ast.CheckConstraintTableDef{
      Expr: $3.expr(),
    }
  }
| UNIQUE '(' index_params ')' opt_storing opt_interleave opt_partition_by opt_deferrable opt_where_clause
  {
    $$.val = &ast.UniqueConstraintTableDef{
      IndexTableDef: ast.IndexTableDef{
        Columns: $3.idxElems(),
        Storing: $5.nameList(),
        Interleave: $6.interleave(),
        PartitionBy: $7.partitionBy(),
        Predicate: $9.expr(),
      },
    }
  }
| PRIMARY KEY '(' index_params ')' opt_hash_sharded opt_interleave
  {
    $$.val = &ast.UniqueConstraintTableDef{
      IndexTableDef: ast.IndexTableDef{
        Columns: $4.idxElems(),
        Sharded: $6.shardedIndexDef(),
        Interleave: $7.interleave(),
      },
      PrimaryKey: true,
    }
  }
| FOREIGN KEY '(' name_list ')' REFERENCES table_name
    opt_column_list key_match reference_actions opt_deferrable
  {
    name := $7.unresolvedObjectName().ToTableName()
    $$.val = &ast.ForeignKeyConstraintTableDef{
      Table: name,
      FromCols: $4.nameList(),
      ToCols: $8.nameList(),
      Match: $9.compositeKeyMatchMethod(),
      Actions: $10.referenceActions(),
    }
  }
| EXCLUDE USING error
  {
    return unimplementedWithIssueDetail(sqllex, 46657, "add constraint exclude using")
  }


create_as_opt_col_list:
  '(' create_as_table_defs ')'
  {
    $$.val = $2.val
  }
|
  {
    $$.val = ast.TableDefs(nil)
  }

create_as_table_defs:
  column_name create_as_col_qual_list
  {
    tableDef, err := ast.NewColumnTableDef(ast.Name($1), nil, false, $2.colQuals())
    if err != nil {
      return setErr(sqllex, err)
    }

    var colToTableDef ast.TableDef = tableDef
    $$.val = ast.TableDefs{colToTableDef}
  }
| create_as_table_defs ',' column_name create_as_col_qual_list
  {
    tableDef, err := ast.NewColumnTableDef(ast.Name($3), nil, false, $4.colQuals())
    if err != nil {
      return setErr(sqllex, err)
    }

    var colToTableDef ast.TableDef = tableDef

    $$.val = append($1.tblDefs(), colToTableDef)
  }
| create_as_table_defs ',' family_def
  {
    $$.val = append($1.tblDefs(), $3.tblDef())
  }
| create_as_table_defs ',' create_as_constraint_def
{
  var constraintToTableDef ast.TableDef = $3.constraintDef()
  $$.val = append($1.tblDefs(), constraintToTableDef)
}

create_as_constraint_def:
  create_as_constraint_elem
  {
    $$.val = $1.constraintDef()
  }

create_as_constraint_elem:
  PRIMARY KEY '(' create_as_params ')'
  {
    $$.val = &ast.UniqueConstraintTableDef{
      IndexTableDef: ast.IndexTableDef{
        Columns: $4.idxElems(),
      },
      PrimaryKey:    true,
    }
  }

create_as_params:
  create_as_param
  {
    $$.val = ast.IndexElemList{$1.idxElem()}
  }
| create_as_params ',' create_as_param
  {
    $$.val = append($1.idxElems(), $3.idxElem())
  }

create_as_param:
  column_name
  {
    $$.val = ast.IndexElem{Column: ast.Name($1)}
  }

create_as_col_qual_list:
  create_as_col_qual_list create_as_col_qualification
  {
    $$.val = append($1.colQuals(), $2.colQual())
  }
|
  {
    $$.val = []ast.NamedColumnQualification(nil)
  }

create_as_col_qualification:
  create_as_col_qualification_elem
  {
    $$.val = ast.NamedColumnQualification{Qualification: $1.colQualElem()}
  }
| FAMILY family_name
  {
    $$.val = ast.NamedColumnQualification{Qualification: &ast.ColumnFamilyConstraint{Family: ast.Name($2)}}
  }

create_as_col_qualification_elem:
  PRIMARY KEY
  {
    $$.val = ast.PrimaryKeyConstraint{}
  }

opt_deferrable:
    {   }
| DEFERRABLE { return unimplementedWithIssueDetail(sqllex, 31632, "deferrable") }
| DEFERRABLE INITIALLY DEFERRED { return unimplementedWithIssueDetail(sqllex, 31632, "def initially deferred") }
| DEFERRABLE INITIALLY IMMEDIATE { return unimplementedWithIssueDetail(sqllex, 31632, "def initially immediate") }
| INITIALLY DEFERRED { return unimplementedWithIssueDetail(sqllex, 31632, "initially deferred") }
| INITIALLY IMMEDIATE { return unimplementedWithIssueDetail(sqllex, 31632, "initially immediate") }

storing:
  COVERING
| STORING
| INCLUDE










opt_storing:
  storing '(' name_list ')'
  {
    $$.val = $3.nameList()
  }
|
  {
    $$.val = ast.NameList(nil)
  }

opt_hash_sharded:
  USING HASH WITH BUCKET_COUNT '=' a_expr
  {
    $$.val = &ast.ShardedIndexDef{
      ShardBuckets: $6.expr(),
    }
  }
  |
  {
    $$.val = (*ast.ShardedIndexDef)(nil)
  }

opt_column_list:
  '(' name_list ')'
  {
    $$.val = $2.nameList()
  }
|
  {
    $$.val = ast.NameList(nil)
  }















key_match:
  MATCH SIMPLE
  {
    $$.val = ast.MatchSimple
  }
| MATCH FULL
  {
    $$.val = ast.MatchFull
  }
| MATCH PARTIAL
  {
    return unimplementedWithIssueDetail(sqllex, 20305, "match partial")
  }
|
  {
    $$.val = ast.MatchSimple
  }




reference_actions:
  reference_on_update
  {
     $$.val = ast.ReferenceActions{Update: $1.referenceAction()}
  }
| reference_on_delete
  {
     $$.val = ast.ReferenceActions{Delete: $1.referenceAction()}
  }
| reference_on_update reference_on_delete
  {
    $$.val = ast.ReferenceActions{Update: $1.referenceAction(), Delete: $2.referenceAction()}
  }
| reference_on_delete reference_on_update
  {
    $$.val = ast.ReferenceActions{Delete: $1.referenceAction(), Update: $2.referenceAction()}
  }
|
  {
    $$.val = ast.ReferenceActions{}
  }

reference_on_update:
  ON UPDATE reference_action
  {
    $$.val = $3.referenceAction()
  }

reference_on_delete:
  ON DELETE reference_action
  {
    $$.val = $3.referenceAction()
  }

reference_action:


  NO ACTION
  {
    $$.val = ast.NoAction
  }
| RESTRICT
  {
    $$.val = ast.Restrict
  }
| CASCADE
  {
    $$.val = ast.Cascade
  }
| SET NULL
  {
    $$.val = ast.SetNull
  }
| SET DEFAULT
  {
    $$.val = ast.SetDefault
  }














create_sequence_stmt:
  CREATE opt_temp SEQUENCE sequence_name opt_sequence_option_list
  {
    name := $4.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateSequence {
      Name: name,
      Temporary: $2.persistenceType(),
      Options: $5.seqOpts(),
    }
  }
| CREATE opt_temp SEQUENCE IF NOT EXISTS sequence_name opt_sequence_option_list
  {
    name := $7.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateSequence {
      Name: name, Options: $8.seqOpts(),
      Temporary: $2.persistenceType(),
      IfNotExists: true,
    }
  }
| CREATE opt_temp SEQUENCE error  { return helpWith(sqllex, "CREATE SEQUENCE") }

opt_sequence_option_list:
  sequence_option_list
|            { $$.val = []ast.SequenceOption(nil) }

sequence_option_list:
  sequence_option_elem                       { $$.val = []ast.SequenceOption{$1.seqOpt()} }
| sequence_option_list sequence_option_elem  { $$.val = append($1.seqOpts(), $2.seqOpt()) }

sequence_option_elem:
  AS typename                  { return unimplementedWithIssueDetail(sqllex, 25110, $2.typeReference().SQLString()) }
| CYCLE                        {
                                 $$.val = ast.SequenceOption{Name: ast.SeqOptCycle} }
| NO CYCLE                     { $$.val = ast.SequenceOption{Name: ast.SeqOptNoCycle} }
| OWNED BY NONE                { $$.val = ast.SequenceOption{Name: ast.SeqOptOwnedBy, ColumnItemVal: nil} }
| OWNED BY column_path         { varName, err := $3.unresolvedName().NormalizeVarName()
                                     if err != nil {
                                       return setErr(sqllex, err)
                                     }
                                     columnItem, ok := varName.(*ast.ColumnItem)
                                     if !ok {
                                       sqllex.Error(fmt.Sprintf("invalid column name: %q", ast.ErrString($3.unresolvedName())))
                                             return 1
                                     }
                                 $$.val = ast.SequenceOption{Name: ast.SeqOptOwnedBy, ColumnItemVal: columnItem} }
| CACHE signed_iconst64        {
                                 x := $2.int64()
                                 $$.val = ast.SequenceOption{Name: ast.SeqOptCache, IntVal: &x} }
| INCREMENT signed_iconst64    { x := $2.int64()
                                 $$.val = ast.SequenceOption{Name: ast.SeqOptIncrement, IntVal: &x} }
| INCREMENT BY signed_iconst64 { x := $3.int64()
                                 $$.val = ast.SequenceOption{Name: ast.SeqOptIncrement, IntVal: &x, OptionalWord: true} }
| MINVALUE signed_iconst64     { x := $2.int64()
                                 $$.val = ast.SequenceOption{Name: ast.SeqOptMinValue, IntVal: &x} }
| NO MINVALUE                  { $$.val = ast.SequenceOption{Name: ast.SeqOptMinValue} }
| MAXVALUE signed_iconst64     { x := $2.int64()
                                 $$.val = ast.SequenceOption{Name: ast.SeqOptMaxValue, IntVal: &x} }
| NO MAXVALUE                  { $$.val = ast.SequenceOption{Name: ast.SeqOptMaxValue} }
| START signed_iconst64        { x := $2.int64()
                                 $$.val = ast.SequenceOption{Name: ast.SeqOptStart, IntVal: &x} }
| START WITH signed_iconst64   { x := $3.int64()
                                 $$.val = ast.SequenceOption{Name: ast.SeqOptStart, IntVal: &x, OptionalWord: true} }
| VIRTUAL                      { $$.val = ast.SequenceOption{Name: ast.SeqOptVirtual} }





truncate_stmt:
  TRUNCATE opt_table relation_expr_list opt_drop_behavior
  {
    $$.val = &ast.Truncate{Tables: $3.tableNames(), DropBehavior: $4.dropBehavior()}
  }
| TRUNCATE error  { return helpWith(sqllex, "TRUNCATE") }

password_clause:
  PASSWORD string_or_placeholder
  {
    $$.val = ast.KVOption{Key: ast.Name($1), Value: $2.expr()}
  }
| PASSWORD NULL
  {
    $$.val = ast.KVOption{Key: ast.Name($1), Value: ast.DNull}
  }





create_role_stmt:
  CREATE role_or_group_or_user string_or_placeholder opt_role_options
  {
    $$.val = &ast.CreateRole{Name: $3.expr(), KVOptions: $4.kvOptions(), IsRole: $2.bool()}
  }
| CREATE role_or_group_or_user IF NOT EXISTS string_or_placeholder opt_role_options
  {
    $$.val = &ast.CreateRole{Name: $6.expr(), IfNotExists: true, KVOptions: $7.kvOptions(), IsRole: $2.bool()}
  }
| CREATE role_or_group_or_user error  { return helpWith(sqllex, "CREATE ROLE") }





alter_role_stmt:
  ALTER role_or_group_or_user string_or_placeholder opt_role_options
{
  $$.val = &ast.AlterRole{Name: $3.expr(), KVOptions: $4.kvOptions(), IsRole: $2.bool()}
}
| ALTER role_or_group_or_user IF EXISTS string_or_placeholder opt_role_options
{
  $$.val = &ast.AlterRole{Name: $5.expr(), IfExists: true, KVOptions: $6.kvOptions(), IsRole: $2.bool()}
}
| ALTER role_or_group_or_user error  { return helpWith(sqllex, "ALTER ROLE") }



role_or_group_or_user:
  ROLE
  {
    $$.val = true
  }
| GROUP
  {

    $$.val = true
  }
| USER
  {
    $$.val = false
  }





create_view_stmt:
  CREATE opt_temp opt_view_recursive VIEW view_name opt_column_list AS select_stmt
  {
    name := $5.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateView{
      Name: name,
      ColumnNames: $6.nameList(),
      AsSource: $8.slct(),
      Temporary: $2.persistenceType(),
      IfNotExists: false,
      Replace: false,
    }
  }


| CREATE OR REPLACE opt_temp opt_view_recursive VIEW view_name opt_column_list AS select_stmt
  {
    name := $7.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateView{
      Name: name,
      ColumnNames: $8.nameList(),
      AsSource: $10.slct(),
      Temporary: $4.persistenceType(),
      IfNotExists: false,
      Replace: true,
    }
  }
| CREATE opt_temp opt_view_recursive VIEW IF NOT EXISTS view_name opt_column_list AS select_stmt
  {
    name := $8.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateView{
      Name: name,
      ColumnNames: $9.nameList(),
      AsSource: $11.slct(),
      Temporary: $2.persistenceType(),
      IfNotExists: true,
      Replace: false,
    }
  }
| CREATE opt_temp opt_view_recursive VIEW error  { return helpWith(sqllex, "CREATE VIEW") }

role_option:
  CREATEROLE
  {
    $$.val = ast.KVOption{Key: ast.Name($1), Value: nil}
  }
| NOCREATEROLE
	{
		$$.val = ast.KVOption{Key: ast.Name($1), Value: nil}
	}
| LOGIN
	{
		$$.val = ast.KVOption{Key: ast.Name($1), Value: nil}
	}
| NOLOGIN
	{
		$$.val = ast.KVOption{Key: ast.Name($1), Value: nil}
	}
| password_clause
| valid_until_clause

role_options:
  role_option
  {
    $$.val = []ast.KVOption{$1.kvOption()}
  }
|  role_options role_option
  {
    $$.val = append($1.kvOptions(), $2.kvOption())
  }

opt_role_options:
	opt_with role_options
	{
		$$.val = $2.kvOptions()
	}
|
	{
		$$.val = nil
	}

valid_until_clause:
  VALID UNTIL string_or_placeholder
  {
		$$.val = ast.KVOption{Key: ast.Name(fmt.Sprintf("%s_%s",$1, $2)), Value: $3.expr()}
  }
| VALID UNTIL NULL
  {
		$$.val = ast.KVOption{Key: ast.Name(fmt.Sprintf("%s_%s",$1, $2)), Value: ast.DNull}
	}

opt_view_recursive:
    {   }
| RECURSIVE { return unimplemented(sqllex, "create recursive view") }





create_type_stmt:

  CREATE TYPE type_name AS ENUM '(' opt_enum_val_list ')'
  {
    $$.val = &ast.CreateType{
      TypeName: $3.unresolvedObjectName(),
      Variety: ast.Enum,
      EnumLabels: $7.strs(),
    }
  }
| CREATE TYPE error  { return helpWith(sqllex, "CREATE TYPE") }

| CREATE TYPE type_name AS '(' error      { return unimplementedWithIssue(sqllex, 27792) }

| CREATE TYPE type_name AS RANGE error    { return unimplementedWithIssue(sqllex, 27791) }

| CREATE TYPE type_name '(' error         { return unimplementedWithIssueDetail(sqllex, 27793, "base") }

| CREATE TYPE type_name                   { return unimplementedWithIssueDetail(sqllex, 27793, "shell") }

| CREATE DOMAIN type_name error           { return unimplementedWithIssueDetail(sqllex, 27796, "create") }

opt_enum_val_list:
  enum_val_list
  {
    $$.val = $1.strs()
  }
|
  {
    $$.val = []string(nil)
  }

enum_val_list:
  SCONST
  {
    $$.val = []string{$1}
  }
| enum_val_list ',' SCONST
  {
    $$.val = append($1.strs(), $3)
  }













create_index_stmt:
  CREATE opt_unique INDEX opt_concurrently opt_index_name ON table_name opt_using_gin_btree '(' index_params ')' opt_hash_sharded opt_storing opt_interleave opt_partition_by opt_where_clause
  {
    table := $7.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateIndex{
      Name:    ast.Name($5),
      Table:   table,
      Unique:  $2.bool(),
      Columns: $10.idxElems(),
      Sharded: $12.shardedIndexDef(),
      Storing: $13.nameList(),
      Interleave: $14.interleave(),
      PartitionBy: $15.partitionBy(),
      Predicate: $16.expr(),
      Inverted: $8.bool(),
      Concurrently: $4.bool(),
    }
  }
| CREATE opt_unique INDEX opt_concurrently IF NOT EXISTS index_name ON table_name opt_using_gin_btree '(' index_params ')' opt_hash_sharded opt_storing opt_interleave opt_partition_by opt_where_clause
  {
    table := $10.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateIndex{
      Name:        ast.Name($8),
      Table:       table,
      Unique:      $2.bool(),
      IfNotExists: true,
      Columns:     $13.idxElems(),
      Sharded:     $15.shardedIndexDef(),
      Storing:     $16.nameList(),
      Interleave:  $17.interleave(),
      PartitionBy: $18.partitionBy(),
      Inverted:    $11.bool(),
      Predicate:   $19.expr(),
      Concurrently: $4.bool(),
    }
  }
| CREATE opt_unique INVERTED INDEX opt_concurrently opt_index_name ON table_name '(' index_params ')' opt_storing opt_interleave opt_partition_by opt_where_clause
  {
    table := $8.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateIndex{
      Name:       ast.Name($6),
      Table:      table,
      Unique:     $2.bool(),
      Inverted:   true,
      Columns:    $10.idxElems(),
      Storing:     $12.nameList(),
      Interleave:  $13.interleave(),
      PartitionBy: $14.partitionBy(),
      Predicate:   $15.expr(),
      Concurrently: $5.bool(),
    }
  }
| CREATE opt_unique INVERTED INDEX opt_concurrently IF NOT EXISTS index_name ON table_name '(' index_params ')' opt_storing opt_interleave opt_partition_by opt_where_clause
  {
    table := $11.unresolvedObjectName().ToTableName()
    $$.val = &ast.CreateIndex{
      Name:        ast.Name($9),
      Table:       table,
      Unique:      $2.bool(),
      Inverted:    true,
      IfNotExists: true,
      Columns:     $13.idxElems(),
      Storing:     $15.nameList(),
      Interleave:  $16.interleave(),
      PartitionBy: $17.partitionBy(),
      Predicate:   $18.expr(),
      Concurrently: $5.bool(),
    }
  }
| CREATE opt_unique INDEX error  { return helpWith(sqllex, "CREATE INDEX") }

opt_using_gin_btree:
  USING name
  {

    switch $2 {
      case "gin":
        $$.val = true
      case "btree":
        $$.val = false
      case "hash", "gist", "spgist", "brin":
        return unimplemented(sqllex, "index using " + $2)
      default:
        sqllex.Error("unrecognized access method: " + $2)
        return 1
    }
  }
|
  {
    $$.val = false
  }

opt_concurrently:
  CONCURRENTLY
  {
    $$.val = true
  }
|
  {
    $$.val = false
  }

opt_unique:
  UNIQUE
  {
    $$.val = true
  }
|
  {
    $$.val = false
  }

index_params:
  index_elem
  {
    $$.val = ast.IndexElemList{$1.idxElem()}
  }
| index_params ',' index_elem
  {
    $$.val = append($1.idxElems(), $3.idxElem())
  }




index_elem:
  a_expr opt_asc_desc opt_nulls_order
  {

    e := $1.expr()
    dir := $2.dir()
    nullsOrder := $3.nullsOrder()

    if nullsOrder != ast.DefaultNullsOrder {
      if dir == ast.Descending && nullsOrder == ast.NullsFirst {
        return unimplementedWithIssue(sqllex, 6224)
      }
      if dir != ast.Descending && nullsOrder == ast.NullsLast {
        return unimplementedWithIssue(sqllex, 6224)
      }
    }
    if colName, ok := e.(*ast.UnresolvedName); ok && colName.NumParts == 1 {
      $$.val = ast.IndexElem{Column: ast.Name(colName.Parts[0]), Direction: dir, NullsOrder: nullsOrder}
    } else {
      return unimplementedWithIssueDetail(sqllex, 9682, fmt.Sprintf("%T", e))
    }
  }

opt_collate:
  COLLATE collation_name { $$ = $2 }
|   { $$ = "" }

opt_asc_desc:
  ASC
  {
    $$.val = ast.Ascending
  }
| DESC
  {
    $$.val = ast.Descending
  }
|
  {
    $$.val = ast.DefaultDirection
  }

alter_rename_database_stmt:
  ALTER DATABASE database_name RENAME TO database_name
  {
    $$.val = &ast.RenameDatabase{Name: ast.Name($3), NewName: ast.Name($6)}
  }

alter_rename_table_stmt:
  ALTER TABLE relation_expr RENAME TO table_name
  {
    name := $3.unresolvedObjectName()
    newName := $6.unresolvedObjectName()
    $$.val = &ast.RenameTable{Name: name, NewName: newName, IfExists: false, IsView: false}
  }
| ALTER TABLE IF EXISTS relation_expr RENAME TO table_name
  {
    name := $5.unresolvedObjectName()
    newName := $8.unresolvedObjectName()
    $$.val = &ast.RenameTable{Name: name, NewName: newName, IfExists: true, IsView: false}
  }

alter_rename_view_stmt:
  ALTER VIEW relation_expr RENAME TO view_name
  {
    name := $3.unresolvedObjectName()
    newName := $6.unresolvedObjectName()
    $$.val = &ast.RenameTable{Name: name, NewName: newName, IfExists: false, IsView: true}
  }
| ALTER VIEW IF EXISTS relation_expr RENAME TO view_name
  {
    name := $5.unresolvedObjectName()
    newName := $8.unresolvedObjectName()
    $$.val = &ast.RenameTable{Name: name, NewName: newName, IfExists: true, IsView: true}
  }

alter_rename_sequence_stmt:
  ALTER SEQUENCE relation_expr RENAME TO sequence_name
  {
    name := $3.unresolvedObjectName()
    newName := $6.unresolvedObjectName()
    $$.val = &ast.RenameTable{Name: name, NewName: newName, IfExists: false, IsSequence: true}
  }
| ALTER SEQUENCE IF EXISTS relation_expr RENAME TO sequence_name
  {
    name := $5.unresolvedObjectName()
    newName := $8.unresolvedObjectName()
    $$.val = &ast.RenameTable{Name: name, NewName: newName, IfExists: true, IsSequence: true}
  }

alter_rename_index_stmt:
  ALTER INDEX table_index_name RENAME TO index_name
  {
    $$.val = &ast.RenameIndex{Index: $3.newTableIndexName(), NewName: ast.UnrestrictedName($6), IfExists: false}
  }
| ALTER INDEX IF EXISTS table_index_name RENAME TO index_name
  {
    $$.val = &ast.RenameIndex{Index: $5.newTableIndexName(), NewName: ast.UnrestrictedName($8), IfExists: true}
  }

opt_column:
  COLUMN {}
|   {}

opt_set_data:
  SET DATA {}
|   {}





release_stmt:
  RELEASE savepoint_name
  {
    $$.val = &ast.ReleaseSavepoint{Savepoint: ast.Name($2)}
  }
| RELEASE error  { return helpWith(sqllex, "RELEASE") }







resume_stmt:
  RESUME JOB a_expr
  {
    $$.val = &ast.ControlJobs{
      Jobs: &ast.Select{
        Select: &ast.ValuesClause{Rows: []ast.Exprs{ast.Exprs{$3.expr()}}},
      },
      Command: ast.ResumeJob,
    }
  }
| RESUME JOBS select_stmt
  {
    $$.val = &ast.ControlJobs{Jobs: $3.slct(), Command: ast.ResumeJob}
  }
| RESUME error  { return helpWith(sqllex, "RESUME JOBS") }





savepoint_stmt:
  SAVEPOINT name
  {
    $$.val = &ast.Savepoint{Name: ast.Name($2)}
  }
| SAVEPOINT error  { return helpWith(sqllex, "SAVEPOINT") }


transaction_stmt:
  begin_stmt     %prec VALUES |   begin_stmt     HELPTOKEN %prec UMINUS { return helpWith(sqllex, "BEGIN") }
| commit_stmt    %prec VALUES |  commit_stmt    HELPTOKEN %prec UMINUS { return helpWith(sqllex, "COMMIT") }
| rollback_stmt  %prec VALUES |  rollback_stmt  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "ROLLBACK") }
| abort_stmt












begin_stmt:
  BEGIN opt_transaction begin_transaction
  {
    $$.val = $3.stmt()
  }
| BEGIN error  { return helpWith(sqllex, "BEGIN") }
| START TRANSACTION begin_transaction
  {
    $$.val = $3.stmt()
  }
| START error  { return helpWith(sqllex, "BEGIN") }







commit_stmt:
  COMMIT opt_transaction
  {
    $$.val = &ast.CommitTransaction{}
  }
| COMMIT error  { return helpWith(sqllex, "COMMIT") }
| END opt_transaction
  {
    $$.val = &ast.CommitTransaction{}
  }
| END error  { return helpWith(sqllex, "COMMIT") }

abort_stmt:
  ABORT opt_abort_mod
  {
    $$.val = &ast.RollbackTransaction{}
  }

opt_abort_mod:
  TRANSACTION {}
| WORK        {}
|   {}







rollback_stmt:
  ROLLBACK opt_transaction
  {
     $$.val = &ast.RollbackTransaction{}
  }
| ROLLBACK opt_transaction TO savepoint_name
  {
     $$.val = &ast.RollbackToSavepoint{Savepoint: ast.Name($4)}
  }
| ROLLBACK error  { return helpWith(sqllex, "ROLLBACK") }

opt_transaction:
  TRANSACTION {}
|   {}

savepoint_name:
  SAVEPOINT name
  {
    $$ = $2
  }
| name
  {
    $$ = $1
  }

begin_transaction:
  transaction_mode_list
  {
    $$.val = &ast.BeginTransaction{Modes: $1.transactionModes()}
  }
|
  {
    $$.val = &ast.BeginTransaction{}
  }

transaction_mode_list:
  transaction_mode
  {
    $$.val = $1.transactionModes()
  }
| transaction_mode_list opt_comma transaction_mode
  {
    a := $1.transactionModes()
    b := $3.transactionModes()
    err := a.Merge(b)
    if err != nil { return setErr(sqllex, err) }
    $$.val = a
  }




opt_comma:
  ','
  { }
|
  { }

transaction_mode:
  transaction_iso_level
  {

    $$.val = ast.TransactionModes{Isolation: $1.isoLevel()}
  }
| transaction_user_priority
  {
    $$.val = ast.TransactionModes{UserPriority: $1.userPriority()}
  }
| transaction_read_mode
  {
    $$.val = ast.TransactionModes{ReadWriteMode: $1.readWriteMode()}
  }
| as_of_clause
  {
    $$.val = ast.TransactionModes{AsOf: $1.asOfClause()}
  }

transaction_user_priority:
  PRIORITY user_priority
  {
    $$.val = $2.userPriority()
  }

transaction_iso_level:
  ISOLATION LEVEL iso_level
  {
    $$.val = $3.isoLevel()
  }

transaction_read_mode:
  READ ONLY
  {
    $$.val = ast.ReadOnly
  }
| READ WRITE
  {
    $$.val = ast.ReadWrite
  }





create_database_stmt:
  CREATE DATABASE database_name opt_with opt_template_clause opt_encoding_clause opt_lc_collate_clause opt_lc_ctype_clause
  {
    $$.val = &ast.CreateDatabase{
      Name: ast.Name($3),
      Template: $5,
      Encoding: $6,
      Collate: $7,
      CType: $8,
    }
  }
| CREATE DATABASE IF NOT EXISTS database_name opt_with opt_template_clause opt_encoding_clause opt_lc_collate_clause opt_lc_ctype_clause
  {
    $$.val = &ast.CreateDatabase{
      IfNotExists: true,
      Name: ast.Name($6),
      Template: $8,
      Encoding: $9,
      Collate: $10,
      CType: $11,
    }
   }
| CREATE DATABASE error  { return helpWith(sqllex, "CREATE DATABASE") }

opt_template_clause:
  TEMPLATE opt_equal non_reserved_word_or_sconst
  {
    $$ = $3
  }
|
  {
    $$ = ""
  }

opt_encoding_clause:
  ENCODING opt_equal non_reserved_word_or_sconst
  {
    $$ = $3
  }
|
  {
    $$ = ""
  }

opt_lc_collate_clause:
  LC_COLLATE opt_equal non_reserved_word_or_sconst
  {
    $$ = $3
  }
|
  {
    $$ = ""
  }

opt_lc_ctype_clause:
  LC_CTYPE opt_equal non_reserved_word_or_sconst
  {
    $$ = $3
  }
|
  {
    $$ = ""
  }

opt_equal:
  '=' {}
|   {}









insert_stmt:
  opt_with_clause INSERT INTO insert_target insert_rest returning_clause
  {
    $$.val = $5.stmt()
    $$.val.(*ast.Insert).With = $1.with()
    $$.val.(*ast.Insert).Table = $4.tblExpr()
    $$.val.(*ast.Insert).Returning = $6.retClause()
  }
| opt_with_clause INSERT INTO insert_target insert_rest on_conflict returning_clause
  {
    $$.val = $5.stmt()
    $$.val.(*ast.Insert).With = $1.with()
    $$.val.(*ast.Insert).Table = $4.tblExpr()
    $$.val.(*ast.Insert).OnConflict = $6.onConflict()
    $$.val.(*ast.Insert).Returning = $7.retClause()
  }
| opt_with_clause INSERT error  { return helpWith(sqllex, "INSERT") }








upsert_stmt:
  opt_with_clause UPSERT INTO insert_target insert_rest returning_clause
  {
    $$.val = $5.stmt()
    $$.val.(*ast.Insert).With = $1.with()
    $$.val.(*ast.Insert).Table = $4.tblExpr()
    $$.val.(*ast.Insert).OnConflict = &ast.OnConflict{}
    $$.val.(*ast.Insert).Returning = $6.retClause()
  }
| opt_with_clause UPSERT error  { return helpWith(sqllex, "UPSERT") }

insert_target:
  table_name
  {
    name := $1.unresolvedObjectName().ToTableName()
    $$.val = &name
  }




| table_name AS table_alias_name
  {
    name := $1.unresolvedObjectName().ToTableName()
    $$.val = &ast.AliasedTableExpr{Expr: &name, As: ast.AliasClause{Alias: ast.Name($3)}}
  }
| numeric_table_ref
  {
    $$.val = $1.tblExpr()
  }

insert_rest:
  select_stmt
  {
    $$.val = &ast.Insert{Rows: $1.slct()}
  }
| '(' insert_column_list ')' select_stmt
  {
    $$.val = &ast.Insert{Columns: $2.nameList(), Rows: $4.slct()}
  }
| DEFAULT VALUES
  {
    $$.val = &ast.Insert{Rows: &ast.Select{}}
  }

insert_column_list:
  insert_column_item
  {
    $$.val = ast.NameList{ast.Name($1)}
  }
| insert_column_list ',' insert_column_item
  {
    $$.val = append($1.nameList(), ast.Name($3))
  }















insert_column_item:
  column_name
| column_name '.' error { return unimplementedWithIssue(sqllex, 27792) }

on_conflict:
  ON CONFLICT opt_conf_expr DO UPDATE SET set_clause_list opt_where_clause
  {
    $$.val = &ast.OnConflict{Columns: $3.nameList(), Exprs: $7.updateExprs(), Where: ast.NewWhere(ast.AstWhere, $8.expr())}
  }
| ON CONFLICT opt_conf_expr DO NOTHING
  {
    $$.val = &ast.OnConflict{Columns: $3.nameList(), DoNothing: true}
  }

opt_conf_expr:
  '(' name_list ')'
  {
    $$.val = $2.nameList()
  }
| '(' name_list ')' where_clause { return unimplementedWithIssue(sqllex, 32557) }
| ON CONSTRAINT constraint_name { return unimplementedWithIssue(sqllex, 28161) }
|
  {
    $$.val = ast.NameList(nil)
  }

returning_clause:
  RETURNING target_list
  {
    ret := ast.ReturningExprs($2.selExprs())
    $$.val = &ret
  }
| RETURNING NOTHING
  {
    $$.val = ast.ReturningNothingClause
  }
|
  {
    $$.val = ast.AbsentReturningClause
  }











update_stmt:
  opt_with_clause UPDATE table_expr_opt_alias_idx
    SET set_clause_list opt_from_list opt_where_clause opt_sort_clause opt_limit_clause returning_clause
  {
    $$.val = &ast.Update{
      With: $1.with(),
      Table: $3.tblExpr(),
      Exprs: $5.updateExprs(),
      From: $6.tblExprs(),
      Where: ast.NewWhere(ast.AstWhere, $7.expr()),
      OrderBy: $8.orderBy(),
      Limit: $9.limit(),
      Returning: $10.retClause(),
    }
  }
| opt_with_clause UPDATE error  { return helpWith(sqllex, "UPDATE") }

opt_from_list:
  FROM from_list {
    $$.val = $2.tblExprs()
  }
|   {
    $$.val = ast.TableExprs{}
}

set_clause_list:
  set_clause
  {
    $$.val = ast.UpdateExprs{$1.updateExpr()}
  }
| set_clause_list ',' set_clause
  {
    $$.val = append($1.updateExprs(), $3.updateExpr())
  }




set_clause:
  single_set_clause
| multiple_set_clause

single_set_clause:
  column_name '=' a_expr
  {
    $$.val = &ast.UpdateExpr{Names: ast.NameList{ast.Name($1)}, Expr: $3.expr()}
  }
| column_name '.' error { return unimplementedWithIssue(sqllex, 27792) }

multiple_set_clause:
  '(' insert_column_list ')' '=' in_expr
  {
    $$.val = &ast.UpdateExpr{Tuple: true, Names: $2.nameList(), Expr: $5.expr()}
  }





































select_stmt:
  select_no_parens %prec UMINUS
| select_with_parens %prec UMINUS
  {
    $$.val = &ast.Select{Select: $1.selectStmt()}
  }

select_with_parens:
  '(' select_no_parens ')'
  {
    $$.val = &ast.ParenSelect{Select: $2.slct()}
  }
| '(' select_with_parens ')'
  {
    $$.val = &ast.ParenSelect{Select: &ast.Select{Select: $2.selectStmt()}}
  }










select_no_parens:
  simple_select
  {
    $$.val = &ast.Select{Select: $1.selectStmt()}
  }
| select_clause sort_clause
  {
    $$.val = &ast.Select{Select: $1.selectStmt(), OrderBy: $2.orderBy()}
  }
| select_clause opt_sort_clause for_locking_clause opt_select_limit
  {
    $$.val = &ast.Select{Select: $1.selectStmt(), OrderBy: $2.orderBy(), Limit: $4.limit(), Locking: $3.lockingClause()}
  }
| select_clause opt_sort_clause select_limit opt_for_locking_clause
  {
    $$.val = &ast.Select{Select: $1.selectStmt(), OrderBy: $2.orderBy(), Limit: $3.limit(), Locking: $4.lockingClause()}
  }
| with_clause select_clause
  {
    $$.val = &ast.Select{With: $1.with(), Select: $2.selectStmt()}
  }
| with_clause select_clause sort_clause
  {
    $$.val = &ast.Select{With: $1.with(), Select: $2.selectStmt(), OrderBy: $3.orderBy()}
  }
| with_clause select_clause opt_sort_clause for_locking_clause opt_select_limit
  {
    $$.val = &ast.Select{With: $1.with(), Select: $2.selectStmt(), OrderBy: $3.orderBy(), Limit: $5.limit(), Locking: $4.lockingClause()}
  }
| with_clause select_clause opt_sort_clause select_limit opt_for_locking_clause
  {
    $$.val = &ast.Select{With: $1.with(), Select: $2.selectStmt(), OrderBy: $3.orderBy(), Limit: $4.limit(), Locking: $5.lockingClause()}
  }

for_locking_clause:
  for_locking_items { $$.val = $1.lockingClause() }
| FOR READ ONLY     { $$.val = (ast.LockingClause)(nil) }

opt_for_locking_clause:
  for_locking_clause { $$.val = $1.lockingClause() }
|          { $$.val = (ast.LockingClause)(nil) }

for_locking_items:
  for_locking_item
  {
    $$.val = ast.LockingClause{$1.lockingItem()}
  }
| for_locking_items for_locking_item
  {
    $$.val = append($1.lockingClause(), $2.lockingItem())
  }

for_locking_item:
  for_locking_strength opt_locked_rels opt_nowait_or_skip
  {
    $$.val = &ast.LockingItem{
      Strength:   $1.lockingStrength(),
      Targets:    $2.tableNames(),
      WaitPolicy: $3.lockingWaitPolicy(),
    }
  }

for_locking_strength:
  FOR UPDATE        { $$.val = ast.ForUpdate }
| FOR NO KEY UPDATE { $$.val = ast.ForNoKeyUpdate }
| FOR SHARE         { $$.val = ast.ForShare }
| FOR KEY SHARE     { $$.val = ast.ForKeyShare }

opt_locked_rels:
           { $$.val = ast.TableNames{} }
| OF table_name_list { $$.val = $2.tableNames() }

opt_nowait_or_skip:
    { $$.val = ast.LockWaitBlock }
| SKIP LOCKED { $$.val = ast.LockWaitSkip }
| NOWAIT      { $$.val = ast.LockWaitError }

select_clause:


  '(' error  { return helpWith(sqllex, "<SELECTCLAUSE>") }
| simple_select
| select_with_parens































simple_select:
  simple_select_clause  %prec VALUES |   simple_select_clause  HELPTOKEN %prec UMINUS { return helpWith(sqllex, "SELECT") }
| values_clause         %prec VALUES |  values_clause         HELPTOKEN %prec UMINUS { return helpWith(sqllex, "VALUES") }
| table_clause          %prec VALUES |  table_clause          HELPTOKEN %prec UMINUS { return helpWith(sqllex, "TABLE") }
| set_operation
















simple_select_clause:
  SELECT opt_all_clause target_list
    from_clause opt_where_clause
    group_clause having_clause window_clause
  {
    $$.val = &ast.SelectClause{
      Exprs:   $3.selExprs(),
      From:    $4.from(),
      Where:   ast.NewWhere(ast.AstWhere, $5.expr()),
      GroupBy: $6.groupBy(),
      Having:  ast.NewWhere(ast.AstHaving, $7.expr()),
      Window:  $8.window(),
    }
  }
| SELECT distinct_clause target_list
    from_clause opt_where_clause
    group_clause having_clause window_clause
  {
    $$.val = &ast.SelectClause{
      Distinct: $2.bool(),
      Exprs:    $3.selExprs(),
      From:     $4.from(),
      Where:    ast.NewWhere(ast.AstWhere, $5.expr()),
      GroupBy:  $6.groupBy(),
      Having:   ast.NewWhere(ast.AstHaving, $7.expr()),
      Window:   $8.window(),
    }
  }
| SELECT distinct_on_clause target_list
    from_clause opt_where_clause
    group_clause having_clause window_clause
  {
    $$.val = &ast.SelectClause{
      Distinct:   true,
      DistinctOn: $2.distinctOn(),
      Exprs:      $3.selExprs(),
      From:       $4.from(),
      Where:      ast.NewWhere(ast.AstWhere, $5.expr()),
      GroupBy:    $6.groupBy(),
      Having:     ast.NewWhere(ast.AstHaving, $7.expr()),
      Window:     $8.window(),
    }
  }
| SELECT error  { return helpWith(sqllex, "SELECT") }

set_operation:
  select_clause UNION all_or_distinct select_clause
  {
    $$.val = &ast.UnionClause{
      Type:  ast.UnionOp,
      Left:  &ast.Select{Select: $1.selectStmt()},
      Right: &ast.Select{Select: $4.selectStmt()},
      All:   $3.bool(),
    }
  }
| select_clause INTERSECT all_or_distinct select_clause
  {
    $$.val = &ast.UnionClause{
      Type:  ast.IntersectOp,
      Left:  &ast.Select{Select: $1.selectStmt()},
      Right: &ast.Select{Select: $4.selectStmt()},
      All:   $3.bool(),
    }
  }
| select_clause EXCEPT all_or_distinct select_clause
  {
    $$.val = &ast.UnionClause{
      Type:  ast.ExceptOp,
      Left:  &ast.Select{Select: $1.selectStmt()},
      Right: &ast.Select{Select: $4.selectStmt()},
      All:   $3.bool(),
    }
  }





table_clause:
  TABLE table_ref
  {
    $$.val = &ast.SelectClause{
      Exprs:       ast.SelectExprs{ast.StarSelectExpr()},
      From:        ast.From{Tables: ast.TableExprs{$2.tblExpr()}},
      TableSelect: true,
    }
  }
| TABLE error  { return helpWith(sqllex, "TABLE") }









with_clause:
  WITH cte_list
  {
    $$.val = &ast.With{CTEList: $2.ctes()}
  }
| WITH_LA cte_list
  {

    $$.val = &ast.With{CTEList: $2.ctes()}
  }
| WITH RECURSIVE cte_list
  {
    $$.val = &ast.With{Recursive: true, CTEList: $3.ctes()}
  }

cte_list:
  common_table_expr
  {
    $$.val = []*ast.CTE{$1.cte()}
  }
| cte_list ',' common_table_expr
  {
    $$.val = append($1.ctes(), $3.cte())
  }

materialize_clause:
  MATERIALIZED
  {
    $$.val = true
  }
| NOT MATERIALIZED
  {
    $$.val = false
  }

common_table_expr:
  table_alias_name opt_column_list AS '(' preparable_stmt ')'
    {
      $$.val = &ast.CTE{
        Name: ast.AliasClause{Alias: ast.Name($1), Cols: $2.nameList() },
        Mtr: ast.MaterializeClause{
          Set: false,
        },
        Stmt: $5.stmt(),
      }
    }
| table_alias_name opt_column_list AS materialize_clause '(' preparable_stmt ')'
    {
      $$.val = &ast.CTE{
        Name: ast.AliasClause{Alias: ast.Name($1), Cols: $2.nameList() },
        Mtr: ast.MaterializeClause{
          Materialize: $4.bool(),
          Set: true,
        },
        Stmt: $6.stmt(),
      }
    }

opt_with:
  WITH {}
|   {}

opt_with_clause:
  with_clause
  {
    $$.val = $1.with()
  }
|
  {
    $$.val = nil
  }

opt_table:
  TABLE {}
|   {}

all_or_distinct:
  ALL
  {
    $$.val = true
  }
| DISTINCT
  {
    $$.val = false
  }
|
  {
    $$.val = false
  }

distinct_clause:
  DISTINCT
  {
    $$.val = true
  }

distinct_on_clause:
  DISTINCT ON '(' expr_list ')'
  {
    $$.val = ast.DistinctOn($4.exprs())
  }

opt_all_clause:
  ALL {}
|   {}

opt_sort_clause:
  sort_clause
  {
    $$.val = $1.orderBy()
  }
|
  {
    $$.val = ast.OrderBy(nil)
  }

sort_clause:
  ORDER BY sortby_list
  {
    $$.val = ast.OrderBy($3.orders())
  }

single_sort_clause:
  ORDER BY sortby
  {
    $$.val = ast.OrderBy([]*ast.Order{$3.order()})
  }
| ORDER BY sortby ',' sortby_list
  {
    sqllex.Error("multiple ORDER BY clauses are not supported in this function")
    return 1
  }

sortby_list:
  sortby
  {
    $$.val = []*ast.Order{$1.order()}
  }
| sortby_list ',' sortby
  {
    $$.val = append($1.orders(), $3.order())
  }

sortby:
  a_expr opt_asc_desc opt_nulls_order
  {

    dir := $2.dir()
    nullsOrder := $3.nullsOrder()

    if nullsOrder != ast.DefaultNullsOrder {
      if dir == ast.Descending && nullsOrder == ast.NullsFirst {
        return unimplementedWithIssue(sqllex, 6224)
      }
      if dir != ast.Descending && nullsOrder == ast.NullsLast {
        return unimplementedWithIssue(sqllex, 6224)
      }
    }
    $$.val = &ast.Order{
      OrderType:  ast.OrderByColumn,
      Expr:       $1.expr(),
      Direction:  dir,
      NullsOrder: nullsOrder,
    }
  }
| PRIMARY KEY table_name opt_asc_desc
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = &ast.Order{OrderType: ast.OrderByIndex, Direction: $4.dir(), Table: name}
  }
| INDEX table_name '@' index_name opt_asc_desc
  {
    name := $2.unresolvedObjectName().ToTableName()
    $$.val = &ast.Order{
      OrderType: ast.OrderByIndex,
      Direction: $5.dir(),
      Table:     name,
      Index:     ast.UnrestrictedName($4),
    }
  }

opt_nulls_order:
  NULLS FIRST
  {
    $$.val = ast.NullsFirst
  }
| NULLS LAST
  {
    $$.val = ast.NullsLast
  }
|
  {
    $$.val = ast.DefaultNullsOrder
  }




select_limit:
  limit_clause offset_clause
  {
    if $1.limit() == nil {
      $$.val = $2.limit()
    } else {
      $$.val = $1.limit()
      $$.val.(*ast.Limit).Offset = $2.limit().Offset
    }
  }
| offset_clause limit_clause
  {
    $$.val = $1.limit()
    if $2.limit() != nil {
      $$.val.(*ast.Limit).Count = $2.limit().Count
      $$.val.(*ast.Limit).LimitAll = $2.limit().LimitAll
    }
  }
| limit_clause
| offset_clause

opt_select_limit:
  select_limit { $$.val = $1.limit() }
|    { $$.val = (*ast.Limit)(nil) }

opt_limit_clause:
  limit_clause
|   { $$.val = (*ast.Limit)(nil) }

limit_clause:
  LIMIT ALL
  {
    $$.val = &ast.Limit{LimitAll: true}
  }
| LIMIT a_expr
  {
    if $2.expr() == nil {
      $$.val = (*ast.Limit)(nil)
    } else {
      $$.val = &ast.Limit{Count: $2.expr()}
    }
  }






| FETCH first_or_next select_fetch_first_value row_or_rows ONLY
  {
    $$.val = &ast.Limit{Count: $3.expr()}
  }
| FETCH first_or_next row_or_rows ONLY
	{
    $$.val = &ast.Limit{
      Count: ast.NewNumVal(constant.MakeInt64(1), ""  , false  ),
    }
  }

offset_clause:
  OFFSET a_expr
  {
    $$.val = &ast.Limit{Offset: $2.expr()}
  }



| OFFSET select_fetch_first_value row_or_rows
  {
    $$.val = &ast.Limit{Offset: $2.expr()}
  }












select_fetch_first_value:
  c_expr
| only_signed_iconst
| only_signed_fconst


row_or_rows:
  ROW {}
| ROWS {}

first_or_next:
  FIRST {}
| NEXT {}














group_clause:
  GROUP BY expr_list
  {
    $$.val = ast.GroupBy($3.exprs())
  }
|
  {
    $$.val = ast.GroupBy(nil)
  }

having_clause:
  HAVING a_expr
  {
    $$.val = $2.expr()
  }
|
  {
    $$.val = ast.Expr(nil)
  }














values_clause:
  VALUES '(' expr_list ')' %prec UMINUS
  {
    $$.val = &ast.ValuesClause{Rows: []ast.Exprs{$3.exprs()}}
  }
| VALUES error  { return helpWith(sqllex, "VALUES") }
| values_clause ',' '(' expr_list ')'
  {
    valNode := $1.selectStmt().(*ast.ValuesClause)
    valNode.Rows = append(valNode.Rows, $4.exprs())
    $$.val = valNode
  }





from_clause:
  FROM from_list opt_as_of_clause
  {
    $$.val = ast.From{Tables: $2.tblExprs(), AsOf: $3.asOfClause()}
  }
| FROM error  { return helpWith(sqllex, "<SOURCE>") }
|
  {
    $$.val = ast.From{}
  }

from_list:
  table_ref
  {
    $$.val = ast.TableExprs{$1.tblExpr()}
  }
| from_list ',' table_ref
  {
    $$.val = append($1.tblExprs(), $3.tblExpr())
  }

index_flags_param:
  FORCE_INDEX '=' index_name
  {
     $$.val = &ast.IndexFlags{Index: ast.UnrestrictedName($3)}
  }
| FORCE_INDEX '=' '[' iconst64 ']'
  {

    $$.val = &ast.IndexFlags{IndexID: ast.IndexID($4.int64())}
  }
| ASC
  {

    $$.val = &ast.IndexFlags{Direction: ast.Ascending}
  }
| DESC
  {

    $$.val = &ast.IndexFlags{Direction: ast.Descending}
  }
|
  NO_INDEX_JOIN
  {
    $$.val = &ast.IndexFlags{NoIndexJoin: true}
  }
|
  IGNORE_FOREIGN_KEYS
  {

    $$.val = &ast.IndexFlags{IgnoreForeignKeys: true}
  }

index_flags_param_list:
  index_flags_param
  {
    $$.val = $1.indexFlags()
  }
|
  index_flags_param_list ',' index_flags_param
  {
    a := $1.indexFlags()
    b := $3.indexFlags()
    if err := a.CombineWith(b); err != nil {
      return setErr(sqllex, err)
    }
    $$.val = a
  }

opt_index_flags:
  '@' index_name
  {
    $$.val = &ast.IndexFlags{Index: ast.UnrestrictedName($2)}
  }
| '@' '[' iconst64 ']'
  {
    $$.val = &ast.IndexFlags{IndexID: ast.IndexID($3.int64())}
  }
| '@' '{' index_flags_param_list '}'
  {
    flags := $3.indexFlags()
    if err := flags.Check(); err != nil {
      return setErr(sqllex, err)
    }
    $$.val = flags
  }
|
  {
    $$.val = (*ast.IndexFlags)(nil)
  }


























table_ref:
  numeric_table_ref opt_index_flags opt_ordinality opt_alias_clause
  {

    $$.val = &ast.AliasedTableExpr{
        Expr:       $1.tblExpr(),
        IndexFlags: $2.indexFlags(),
        Ordinality: $3.bool(),
        As:         $4.aliasClause(),
    }
  }
| relation_expr opt_index_flags opt_ordinality opt_alias_clause
  {
    name := $1.unresolvedObjectName().ToTableName()
    $$.val = &ast.AliasedTableExpr{
      Expr:       &name,
      IndexFlags: $2.indexFlags(),
      Ordinality: $3.bool(),
      As:         $4.aliasClause(),
    }
  }
| select_with_parens opt_ordinality opt_alias_clause
  {
    $$.val = &ast.AliasedTableExpr{
      Expr:       &ast.Subquery{Select: $1.selectStmt()},
      Ordinality: $2.bool(),
      As:         $3.aliasClause(),
    }
  }
| LATERAL select_with_parens opt_ordinality opt_alias_clause
  {
    $$.val = &ast.AliasedTableExpr{
      Expr:       &ast.Subquery{Select: $2.selectStmt()},
      Ordinality: $3.bool(),
      Lateral:    true,
      As:         $4.aliasClause(),
    }
  }
| joined_table
  {
    $$.val = $1.tblExpr()
  }
| '(' joined_table ')' opt_ordinality alias_clause
  {
    $$.val = &ast.AliasedTableExpr{Expr: &ast.ParenTableExpr{Expr: $2.tblExpr()}, Ordinality: $4.bool(), As: $5.aliasClause()}
  }
| func_table opt_ordinality opt_alias_clause
  {
    f := $1.tblExpr()
    $$.val = &ast.AliasedTableExpr{
      Expr: f,
      Ordinality: $2.bool(),


      As: $3.aliasClause(),
    }
  }
| LATERAL func_table opt_ordinality opt_alias_clause
  {
    f := $2.tblExpr()
    $$.val = &ast.AliasedTableExpr{
      Expr: f,
      Ordinality: $3.bool(),
      Lateral: true,
      As: $4.aliasClause(),
    }
  }














| '[' row_source_extension_stmt ']' opt_ordinality opt_alias_clause
  {
    $$.val = &ast.AliasedTableExpr{Expr: &ast.StatementSource{ Statement: $2.stmt() }, Ordinality: $4.bool(), As: $5.aliasClause() }
  }

numeric_table_ref:
  '[' iconst64 opt_tableref_col_list alias_clause ']'
  {

    $$.val = &ast.TableRef{
      TableID: $2.int64(),
      Columns: $3.tableRefCols(),
      As:      $4.aliasClause(),
    }
  }

func_table:
  func_expr_windowless
  {
    $$.val = &ast.RowsFromExpr{Items: ast.Exprs{$1.expr()}}
  }
| ROWS FROM '(' rowsfrom_list ')'
  {
    $$.val = &ast.RowsFromExpr{Items: $4.exprs()}
  }

rowsfrom_list:
  rowsfrom_item
  { $$.val = ast.Exprs{$1.expr()} }
| rowsfrom_list ',' rowsfrom_item
  { $$.val = append($1.exprs(), $3.expr()) }

rowsfrom_item:
  func_expr_windowless opt_col_def_list
  {
    $$.val = $1.expr()
  }

opt_col_def_list:

  { }
| AS '(' error
  { return unimplemented(sqllex, "ROWS FROM with col_def_list") }

opt_tableref_col_list:
                  { $$.val = nil }
| '(' ')'                   { $$.val = []ast.ColumnID{} }
| '(' tableref_col_list ')' { $$.val = $2.tableRefCols() }

tableref_col_list:
  iconst64
  {
    $$.val = []ast.ColumnID{ast.ColumnID($1.int64())}
  }
| tableref_col_list ',' iconst64
  {
    $$.val = append($1.tableRefCols(), ast.ColumnID($3.int64()))
  }

opt_ordinality:
  WITH_LA ORDINALITY
  {
    $$.val = true
  }
|
  {
    $$.val = false
  }















joined_table:
  '(' joined_table ')'
  {
    $$.val = &ast.ParenTableExpr{Expr: $2.tblExpr()}
  }
| table_ref CROSS opt_join_hint JOIN table_ref
  {
    $$.val = &ast.JoinTableExpr{JoinType: ast.AstCross, Left: $1.tblExpr(), Right: $5.tblExpr(), Hint: $3}
  }
| table_ref join_type opt_join_hint JOIN table_ref join_qual
  {
    $$.val = &ast.JoinTableExpr{JoinType: $2, Left: $1.tblExpr(), Right: $5.tblExpr(), Cond: $6.joinCond(), Hint: $3}
  }
| table_ref JOIN table_ref join_qual
  {
    $$.val = &ast.JoinTableExpr{Left: $1.tblExpr(), Right: $3.tblExpr(), Cond: $4.joinCond()}
  }
| table_ref NATURAL join_type opt_join_hint JOIN table_ref
  {
    $$.val = &ast.JoinTableExpr{JoinType: $3, Left: $1.tblExpr(), Right: $6.tblExpr(), Cond: ast.NaturalJoinCond{}, Hint: $4}
  }
| table_ref NATURAL JOIN table_ref
  {
    $$.val = &ast.JoinTableExpr{Left: $1.tblExpr(), Right: $4.tblExpr(), Cond: ast.NaturalJoinCond{}}
  }

alias_clause:
  AS table_alias_name opt_column_list
  {
    $$.val = ast.AliasClause{Alias: ast.Name($2), Cols: $3.nameList()}
  }
| table_alias_name opt_column_list
  {
    $$.val = ast.AliasClause{Alias: ast.Name($1), Cols: $2.nameList()}
  }

opt_alias_clause:
  alias_clause
|
  {
    $$.val = ast.AliasClause{}
  }

as_of_clause:
  AS_LA OF SYSTEM TIME a_expr
  {
    $$.val = ast.AsOfClause{Expr: $5.expr()}
  }

opt_as_of_clause:
  as_of_clause
|
  {
    $$.val = ast.AsOfClause{}
  }

join_type:
  FULL join_outer
  {
    $$ = ast.AstFull
  }
| LEFT join_outer
  {
    $$ = ast.AstLeft
  }
| RIGHT join_outer
  {
    $$ = ast.AstRight
  }
| INNER
  {
    $$ = ast.AstInner
  }


join_outer:
  OUTER {}
|   {}


















opt_join_hint:
  HASH
  {
    $$ = ast.AstHash
  }
| MERGE
  {
    $$ = ast.AstMerge
  }
| LOOKUP
  {
    $$ = ast.AstLookup
  }
|
  {
    $$ = ""
  }








join_qual:
  USING '(' name_list ')'
  {
    $$.val = &ast.UsingJoinCond{Cols: $3.nameList()}
  }
| ON a_expr
  {
    $$.val = &ast.OnJoinCond{Expr: $2.expr()}
  }

relation_expr:
  table_name              { $$.val = $1.unresolvedObjectName() }
| table_name '*'          { $$.val = $1.unresolvedObjectName() }
| ONLY table_name         { $$.val = $2.unresolvedObjectName() }
| ONLY '(' table_name ')' { $$.val = $3.unresolvedObjectName() }

relation_expr_list:
  relation_expr
  {
    name := $1.unresolvedObjectName().ToTableName()
    $$.val = ast.TableNames{name}
  }
| relation_expr_list ',' relation_expr
  {
    name := $3.unresolvedObjectName().ToTableName()
    $$.val = append($1.tableNames(), name)
  }








table_expr_opt_alias_idx:
  table_name_opt_idx %prec UMINUS
  {
     $$.val = $1.tblExpr()
  }
| table_name_opt_idx table_alias_name
  {
     alias := $1.tblExpr().(*ast.AliasedTableExpr)
     alias.As = ast.AliasClause{Alias: ast.Name($2)}
     $$.val = alias
  }
| table_name_opt_idx AS table_alias_name
  {
     alias := $1.tblExpr().(*ast.AliasedTableExpr)
     alias.As = ast.AliasClause{Alias: ast.Name($3)}
     $$.val = alias
  }
| numeric_table_ref opt_index_flags
  {

    $$.val = &ast.AliasedTableExpr{
      Expr: $1.tblExpr(),
      IndexFlags: $2.indexFlags(),
    }
  }

table_name_opt_idx:
  table_name opt_index_flags
  {
    name := $1.unresolvedObjectName().ToTableName()
    $$.val = &ast.AliasedTableExpr{
      Expr: &name,
      IndexFlags: $2.indexFlags(),
    }
  }

where_clause:
  WHERE a_expr
  {
    $$.val = $2.expr()
  }

opt_where_clause:
  where_clause
|
  {
    $$.val = ast.Expr(nil)
  }







typename:
  simple_typename opt_array_bounds
  {
    if bounds := $2.int32s(); bounds != nil {
      var err error
      $$.val, err = arrayOf($1.typeReference(), bounds)
      if err != nil {
        return setErr(sqllex, err)
      }
    } else {
      $$.val = $1.typeReference()
    }
  }


| simple_typename ARRAY '[' ICONST ']' {

    var err error
    $$.val, err = arrayOf($1.typeReference(), nil)
    if err != nil {
      return setErr(sqllex, err)
    }
  }
| simple_typename ARRAY '[' ICONST ']' '[' error { return unimplementedWithIssue(sqllex, 32552) }
| simple_typename ARRAY {
    var err error
    $$.val, err = arrayOf($1.typeReference(), nil)
    if err != nil {
      return setErr(sqllex, err)
    }
  }

cast_target:
  typename
  {
    $$.val = $1.typeReference()
  }

opt_array_bounds:


  '[' ']' { $$.val = []int32{-1} }
| '[' ']' '[' error { return unimplementedWithIssue(sqllex, 32552) }
| '[' ICONST ']'
  {

    bound, err := $2.numVal().AsInt32()
    if err != nil {
      return setErr(sqllex, err)
    }
    $$.val = []int32{bound}
  }
| '[' ICONST ']' '[' error { return unimplementedWithIssue(sqllex, 32552) }
|   { $$.val = []int32(nil) }




general_type_name:
  type_function_name_no_crdb_extra



complex_type_name:
  general_type_name '.' unrestricted_name
  {
    aIdx := sqllex.(*lexer).NewAnnotation()
    res, err := ast.NewUnresolvedObjectName(2, [3]string{$3, $1}, aIdx)
    if err != nil { return setErr(sqllex, err) }
    $$.val = res
  }
| general_type_name '.' unrestricted_name '.' unrestricted_name
  {
    aIdx := sqllex.(*lexer).NewAnnotation()
    res, err := ast.NewUnresolvedObjectName(3, [3]string{$5, $3, $1}, aIdx)
    if err != nil { return setErr(sqllex, err) }
    $$.val = res
  }

simple_typename:
  general_type_name
  {






    if $1 == "char" {
      $$.val = types.MakeQChar(0)
    } else if $1 == "serial" {
        switch sqllex.(*lexer).nakedIntType.Width() {
        case 32:
          $$.val = &types.Serial4Type
        default:
          $$.val = &types.Serial8Type
        }
    } else {


      var ok bool
      var err error
      var unimp int
      $$.val, ok, unimp = types.TypeForNonKeywordTypeName($1)
      if !ok {
        switch unimp {
          case 0:


            aIdx := sqllex.(*lexer).NewAnnotation()
            $$.val, err = ast.NewUnresolvedObjectName(1, [3]string{$1}, aIdx)
            if err != nil { return setErr(sqllex, err) }
          case -1:
            return unimplemented(sqllex, "type name " + $1)
          default:
            return unimplementedWithIssueDetail(sqllex, unimp, $1)
        }
      }
    }
  }
| '@' iconst32
  {
    id := $2.int32()
    $$.val = &ast.IDTypeReference{ID: uint32(id)}
  }
| complex_type_name
  {
    $$.val = $1.typeReference()
  }
| const_typename
| bit_with_length
| character_with_length
| interval_type
| POINT error { return unimplementedWithIssueDetail(sqllex, 21286, "point") }
| POLYGON error { return unimplementedWithIssueDetail(sqllex, 21286, "polygon") }

geo_shape_type:
  POINT { $$.val = geopb.ShapeType_Point }
| LINESTRING { $$.val = geopb.ShapeType_LineString }
| POLYGON { $$.val = geopb.ShapeType_Polygon }
| GEOMETRYCOLLECTION { $$.val = geopb.ShapeType_GeometryCollection }
| MULTIPOLYGON { $$.val = geopb.ShapeType_MultiPolygon }
| MULTILINESTRING { $$.val = geopb.ShapeType_MultiLineString }
| MULTIPOINT { $$.val = geopb.ShapeType_MultiPoint }
| GEOMETRY { $$.val = geopb.ShapeType_Geometry }

const_geo:
  GEOGRAPHY { $$.val = types.Geography }
| GEOMETRY  { $$.val = types.Geometry }
| GEOMETRY '(' geo_shape_type ')'
  {
    $$.val = types.MakeGeometry($3.geoShapeType(), 0)
  }
| GEOGRAPHY '(' geo_shape_type ')'
  {
    $$.val = types.MakeGeography($3.geoShapeType(), 0)
  }
| GEOMETRY '(' geo_shape_type ',' signed_iconst ')'
  {
    val, err := $5.numVal().AsInt32()
    if err != nil {
      return setErr(sqllex, err)
    }
    $$.val = types.MakeGeometry($3.geoShapeType(), geopb.SRID(val))
  }
| GEOGRAPHY '(' geo_shape_type ',' signed_iconst ')'
  {
    val, err := $5.numVal().AsInt32()
    if err != nil {
      return setErr(sqllex, err)
    }
    $$.val = types.MakeGeography($3.geoShapeType(), geopb.SRID(val))
  }










const_typename:
  numeric
| bit_without_length
| character_without_length
| const_datetime
| const_geo

opt_numeric_modifiers:
  '(' iconst32 ')'
  {
    dec, err := newDecimal($2.int32(), 0)
    if err != nil {
      return setErr(sqllex, err)
    }
    $$.val = dec
  }
| '(' iconst32 ',' iconst32 ')'
  {
    dec, err := newDecimal($2.int32(), $4.int32())
    if err != nil {
      return setErr(sqllex, err)
    }
    $$.val = dec
  }
|
  {
    $$.val = nil
  }


numeric:
  INT
  {
    $$.val = sqllex.(*lexer).nakedIntType
  }
| INTEGER
  {
    $$.val = sqllex.(*lexer).nakedIntType
  }
| SMALLINT
  {
    $$.val = types.Int2
  }
| BIGINT
  {
    $$.val = types.Int
  }
| REAL
  {
    $$.val = types.Float4
  }
| FLOAT opt_float
  {
    $$.val = $2.colType()
  }
| DOUBLE PRECISION
  {
    $$.val = types.Float
  }
| DECIMAL opt_numeric_modifiers
  {
    typ := $2.colType()
    if typ == nil {
      typ = types.Decimal
    }
    $$.val = typ
  }
| DEC opt_numeric_modifiers
  {
    typ := $2.colType()
    if typ == nil {
      typ = types.Decimal
    }
    $$.val = typ
  }
| NUMERIC opt_numeric_modifiers
  {
    typ := $2.colType()
    if typ == nil {
      typ = types.Decimal
    }
    $$.val = typ
  }
| BOOLEAN
  {
    $$.val = types.Bool
  }

opt_float:
  '(' ICONST ')'
  {
    nv := $2.numVal()
    prec, err := nv.AsInt64()
    if err != nil {
      return setErr(sqllex, err)
    }
    typ, err := newFloat(prec)
    if err != nil {
      return setErr(sqllex, err)
    }
    $$.val = typ
  }
|
  {
    $$.val = types.Float
  }

bit_with_length:
  BIT opt_varying '(' iconst32 ')'
  {
    bit, err := newBitType($4.int32(), $2.bool())
    if err != nil { return setErr(sqllex, err) }
    $$.val = bit
  }
| VARBIT '(' iconst32 ')'
  {
    bit, err := newBitType($3.int32(), true)
    if err != nil { return setErr(sqllex, err) }
    $$.val = bit
  }

bit_without_length:
  BIT
  {
    $$.val = types.MakeBit(1)
  }
| BIT VARYING
  {
    $$.val = types.VarBit
  }
| VARBIT
  {
    $$.val = types.VarBit
  }

character_with_length:
  character_base '(' iconst32 ')'
  {
    colTyp := *$1.colType()
    n := $3.int32()
    if n == 0 {
      sqllex.Error(fmt.Sprintf("length for type %s must be at least 1", colTyp.SQLString()))
      return 1
    }
    $$.val = types.MakeScalar(types.StringFamily, colTyp.Oid(), colTyp.Precision(), n, colTyp.Locale())
  }

character_without_length:
  character_base
  {
    $$.val = $1.colType()
  }

character_base:
  char_aliases
  {
    $$.val = types.MakeChar(1)
  }
| char_aliases VARYING
  {
    $$.val = types.VarChar
  }
| VARCHAR
  {
    $$.val = types.VarChar
  }
| STRING
  {
    $$.val = types.String
  }

char_aliases:
  CHAR
| CHARACTER

opt_varying:
  VARYING     { $$.val = true }
|   { $$.val = false }


const_datetime:
  DATE
  {
    $$.val = types.Date
  }
| TIME opt_timezone
  {
    if $2.bool() {
      $$.val = types.TimeTZ
    } else {
      $$.val = types.Time
    }
  }
| TIME '(' iconst32 ')' opt_timezone
  {
    prec := $3.int32()
    if prec < 0 || prec > 6 {
      sqllex.Error(fmt.Sprintf("precision %d out of range", prec))
      return 1
    }
    if $5.bool() {
      $$.val = types.MakeTimeTZ(prec)
    } else {
      $$.val = types.MakeTime(prec)
    }
  }
| TIMETZ                             { $$.val = types.TimeTZ }
| TIMETZ '(' iconst32 ')'
  {
    prec := $3.int32()
    if prec < 0 || prec > 6 {
      sqllex.Error(fmt.Sprintf("precision %d out of range", prec))
      return 1
    }
    $$.val = types.MakeTimeTZ(prec)
  }
| TIMESTAMP opt_timezone
  {
    if $2.bool() {
      $$.val = types.TimestampTZ
    } else {
      $$.val = types.Timestamp
    }
  }
| TIMESTAMP '(' iconst32 ')' opt_timezone
  {
    prec := $3.int32()
    if prec < 0 || prec > 6 {
      sqllex.Error(fmt.Sprintf("precision %d out of range", prec))
      return 1
    }
    if $5.bool() {
      $$.val = types.MakeTimestampTZ(prec)
    } else {
      $$.val = types.MakeTimestamp(prec)
    }
  }
| TIMESTAMPTZ
  {
    $$.val = types.TimestampTZ
  }
| TIMESTAMPTZ '(' iconst32 ')'
  {
    prec := $3.int32()
    if prec < 0 || prec > 6 {
      sqllex.Error(fmt.Sprintf("precision %d out of range", prec))
      return 1
    }
    $$.val = types.MakeTimestampTZ(prec)
  }

opt_timezone:
  WITH_LA TIME ZONE { $$.val = true; }
| WITHOUT TIME ZONE { $$.val = false; }
|           { $$.val = false; }

interval_type:
  INTERVAL
  {
    $$.val = types.Interval
  }
| INTERVAL interval_qualifier
  {
    $$.val = types.MakeInterval($2.intervalTypeMetadata())
  }
| INTERVAL '(' iconst32 ')'
  {
    prec := $3.int32()
    if prec < 0 || prec > 6 {
      sqllex.Error(fmt.Sprintf("precision %d out of range", prec))
      return 1
    }
    $$.val = types.MakeInterval(types.IntervalTypeMetadata{Precision: prec, PrecisionIsSet: true})
  }

interval_qualifier:
  YEAR
  {
    $$.val = types.IntervalTypeMetadata{
      DurationField: types.IntervalDurationField{
        DurationType: types.IntervalDurationType_YEAR,
      },
    }
  }
| MONTH
  {
    $$.val = types.IntervalTypeMetadata{
      DurationField: types.IntervalDurationField{
        DurationType: types.IntervalDurationType_MONTH,
      },
    }
  }
| DAY
  {
    $$.val = types.IntervalTypeMetadata{
      DurationField: types.IntervalDurationField{
        DurationType: types.IntervalDurationType_DAY,
      },
    }
  }
| HOUR
  {
    $$.val = types.IntervalTypeMetadata{
      DurationField: types.IntervalDurationField{
        DurationType: types.IntervalDurationType_HOUR,
      },
    }
  }
| MINUTE
  {
    $$.val = types.IntervalTypeMetadata{
      DurationField: types.IntervalDurationField{
        DurationType: types.IntervalDurationType_MINUTE,
      },
    }
  }
| interval_second
  {
    $$.val = $1.intervalTypeMetadata()
  }


| YEAR TO MONTH
  {
    $$.val = types.IntervalTypeMetadata{
      DurationField: types.IntervalDurationField{
        FromDurationType: types.IntervalDurationType_YEAR,
        DurationType: types.IntervalDurationType_MONTH,
      },
    }
  }
| DAY TO HOUR
  {
    $$.val = types.IntervalTypeMetadata{
      DurationField: types.IntervalDurationField{
        FromDurationType: types.IntervalDurationType_DAY,
        DurationType: types.IntervalDurationType_HOUR,
      },
    }
  }
| DAY TO MINUTE
  {
    $$.val = types.IntervalTypeMetadata{
      DurationField: types.IntervalDurationField{
        FromDurationType: types.IntervalDurationType_DAY,
        DurationType: types.IntervalDurationType_MINUTE,
      },
    }
  }
| DAY TO interval_second
  {
    ret := $3.intervalTypeMetadata()
    ret.DurationField.FromDurationType = types.IntervalDurationType_DAY
    $$.val = ret
  }
| HOUR TO MINUTE
  {
    $$.val = types.IntervalTypeMetadata{
      DurationField: types.IntervalDurationField{
        FromDurationType: types.IntervalDurationType_HOUR,
        DurationType: types.IntervalDurationType_MINUTE,
      },
    }
  }
| HOUR TO interval_second
  {
    ret := $3.intervalTypeMetadata()
    ret.DurationField.FromDurationType = types.IntervalDurationType_HOUR
    $$.val = ret
  }
| MINUTE TO interval_second
  {
    $$.val = $3.intervalTypeMetadata()
    ret := $3.intervalTypeMetadata()
    ret.DurationField.FromDurationType = types.IntervalDurationType_MINUTE
    $$.val = ret
  }

opt_interval_qualifier:
  interval_qualifier
|
  {
    $$.val = nil
  }

interval_second:
  SECOND
  {
    $$.val = types.IntervalTypeMetadata{
      DurationField: types.IntervalDurationField{
        DurationType: types.IntervalDurationType_SECOND,
      },
    }
  }
| SECOND '(' iconst32 ')'
  {
    prec := $3.int32()
    if prec < 0 || prec > 6 {
      sqllex.Error(fmt.Sprintf("precision %d out of range", prec))
      return 1
    }
    $$.val = types.IntervalTypeMetadata{
      DurationField: types.IntervalDurationField{
        DurationType: types.IntervalDurationType_SECOND,
      },
      PrecisionIsSet: true,
      Precision: prec,
    }
  }




















a_expr:
  c_expr
| a_expr TYPECAST cast_target
  {
    $$.val = &ast.CastExpr{Expr: $1.expr(), Type: $3.typeReference(), SyntaxMode: ast.CastShort}
  }
| a_expr TYPEANNOTATE typename
  {
    $$.val = &ast.AnnotateTypeExpr{Expr: $1.expr(), Type: $3.typeReference(), SyntaxMode: ast.AnnotateShort}
  }
| a_expr COLLATE collation_name
  {
    $$.val = &ast.CollateExpr{Expr: $1.expr(), Locale: $3}
  }
| a_expr AT TIME ZONE a_expr %prec AT
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("timezone"), Exprs: ast.Exprs{$5.expr(), $1.expr()}}
  }







| '+' a_expr %prec UMINUS
  {

    $$.val = $2.expr()
  }
| '-' a_expr %prec UMINUS
  {
    $$.val = unaryNegation($2.expr())
  }
| '~' a_expr %prec UMINUS
  {
    $$.val = &ast.UnaryExpr{Operator: ast.UnaryComplement, Expr: $2.expr()}
  }
| SQRT a_expr
  {
    $$.val = &ast.UnaryExpr{Operator: ast.UnarySqrt, Expr: $2.expr()}
  }
| CBRT a_expr
  {
    $$.val = &ast.UnaryExpr{Operator: ast.UnaryCbrt, Expr: $2.expr()}
  }
| a_expr '+' a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Plus, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '-' a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Minus, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '*' a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Mult, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '/' a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Div, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr FLOORDIV a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.FloorDiv, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '%' a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Mod, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '^' a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Pow, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '#' a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Bitxor, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '&' a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Bitand, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '|' a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Bitor, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '<' a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.LT, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '>' a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.GT, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '?' a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.JSONExists, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr JSON_SOME_EXISTS a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.JSONSomeExists, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr JSON_ALL_EXISTS a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.JSONAllExists, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr CONTAINS a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.Contains, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr CONTAINED_BY a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.ContainedBy, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr '=' a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.EQ, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr CONCAT a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Concat, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr LSHIFT a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.LShift, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr RSHIFT a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.RShift, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr FETCHVAL a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.JSONFetchVal, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr FETCHTEXT a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.JSONFetchText, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr FETCHVAL_PATH a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.JSONFetchValPath, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr FETCHTEXT_PATH a_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.JSONFetchTextPath, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr REMOVE_PATH a_expr
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("json_remove_path"), Exprs: ast.Exprs{$1.expr(), $3.expr()}}
  }
| a_expr INET_CONTAINED_BY_OR_EQUALS a_expr
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("inet_contained_by_or_equals"), Exprs: ast.Exprs{$1.expr(), $3.expr()}}
  }
| a_expr AND_AND a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.Overlaps, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr INET_CONTAINS_OR_EQUALS a_expr
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("inet_contains_or_equals"), Exprs: ast.Exprs{$1.expr(), $3.expr()}}
  }
| a_expr LESS_EQUALS a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.LE, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr GREATER_EQUALS a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.GE, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr NOT_EQUALS a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.NE, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr AND a_expr
  {
    $$.val = &ast.AndExpr{Left: $1.expr(), Right: $3.expr()}
  }
| a_expr OR a_expr
  {
    $$.val = &ast.OrExpr{Left: $1.expr(), Right: $3.expr()}
  }
| NOT a_expr
  {
    $$.val = &ast.NotExpr{Expr: $2.expr()}
  }
| NOT_LA a_expr %prec NOT
  {
    $$.val = &ast.NotExpr{Expr: $2.expr()}
  }
| a_expr LIKE a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.Like, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr LIKE a_expr ESCAPE a_expr %prec ESCAPE
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("like_escape"), Exprs: ast.Exprs{$1.expr(), $3.expr(), $5.expr()}}
  }
| a_expr NOT_LA LIKE a_expr %prec NOT_LA
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.NotLike, Left: $1.expr(), Right: $4.expr()}
  }
| a_expr NOT_LA LIKE a_expr ESCAPE a_expr %prec ESCAPE
 {
   $$.val = &ast.FuncExpr{Func: ast.WrapFunction("not_like_escape"), Exprs: ast.Exprs{$1.expr(), $4.expr(), $6.expr()}}
 }
| a_expr ILIKE a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.ILike, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr ILIKE a_expr ESCAPE a_expr %prec ESCAPE
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("ilike_escape"), Exprs: ast.Exprs{$1.expr(), $3.expr(), $5.expr()}}
  }
| a_expr NOT_LA ILIKE a_expr %prec NOT_LA
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.NotILike, Left: $1.expr(), Right: $4.expr()}
  }
| a_expr NOT_LA ILIKE a_expr ESCAPE a_expr %prec ESCAPE
 {
   $$.val = &ast.FuncExpr{Func: ast.WrapFunction("not_ilike_escape"), Exprs: ast.Exprs{$1.expr(), $4.expr(), $6.expr()}}
 }
| a_expr SIMILAR TO a_expr %prec SIMILAR
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.SimilarTo, Left: $1.expr(), Right: $4.expr()}
  }
| a_expr SIMILAR TO a_expr ESCAPE a_expr %prec ESCAPE
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("similar_to_escape"), Exprs: ast.Exprs{$1.expr(), $4.expr(), $6.expr()}}
  }
| a_expr NOT_LA SIMILAR TO a_expr %prec NOT_LA
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.NotSimilarTo, Left: $1.expr(), Right: $5.expr()}
  }
| a_expr NOT_LA SIMILAR TO a_expr ESCAPE a_expr %prec ESCAPE
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("not_similar_to_escape"), Exprs: ast.Exprs{$1.expr(), $5.expr(), $7.expr()}}
  }
| a_expr '~' a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.RegMatch, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr NOT_REGMATCH a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.NotRegMatch, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr REGIMATCH a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.RegIMatch, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr NOT_REGIMATCH a_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.NotRegIMatch, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr IS NAN %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.EQ, Left: $1.expr(), Right: ast.NewStrVal("NaN")}
  }
| a_expr IS NOT NAN %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.NE, Left: $1.expr(), Right: ast.NewStrVal("NaN")}
  }
| a_expr IS NULL %prec IS
  {
    $$.val = &ast.IsNullExpr{Expr: $1.expr()}
  }
| a_expr ISNULL %prec IS
  {
    $$.val = &ast.IsNullExpr{Expr: $1.expr()}
  }
| a_expr IS NOT NULL %prec IS
  {
    $$.val = &ast.IsNotNullExpr{Expr: $1.expr()}
  }
| a_expr NOTNULL %prec IS
  {
    $$.val = &ast.IsNotNullExpr{Expr: $1.expr()}
  }
| row OVERLAPS row { return unimplemented(sqllex, "overlaps") }
| a_expr IS TRUE %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.IsNotDistinctFrom, Left: $1.expr(), Right: ast.MakeDBool(true)}
  }
| a_expr IS NOT TRUE %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.IsDistinctFrom, Left: $1.expr(), Right: ast.MakeDBool(true)}
  }
| a_expr IS FALSE %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.IsNotDistinctFrom, Left: $1.expr(), Right: ast.MakeDBool(false)}
  }
| a_expr IS NOT FALSE %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.IsDistinctFrom, Left: $1.expr(), Right: ast.MakeDBool(false)}
  }
| a_expr IS UNKNOWN %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.IsNotDistinctFrom, Left: $1.expr(), Right: ast.DNull}
  }
| a_expr IS NOT UNKNOWN %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.IsDistinctFrom, Left: $1.expr(), Right: ast.DNull}
  }
| a_expr IS DISTINCT FROM a_expr %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.IsDistinctFrom, Left: $1.expr(), Right: $5.expr()}
  }
| a_expr IS NOT DISTINCT FROM a_expr %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.IsNotDistinctFrom, Left: $1.expr(), Right: $6.expr()}
  }
| a_expr IS OF '(' type_list ')' %prec IS
  {
    $$.val = &ast.IsOfTypeExpr{Expr: $1.expr(), Types: $5.typeReferences()}
  }
| a_expr IS NOT OF '(' type_list ')' %prec IS
  {
    $$.val = &ast.IsOfTypeExpr{Not: true, Expr: $1.expr(), Types: $6.typeReferences()}
  }
| a_expr BETWEEN opt_asymmetric b_expr AND a_expr %prec BETWEEN
  {
    $$.val = &ast.RangeCond{Left: $1.expr(), From: $4.expr(), To: $6.expr()}
  }
| a_expr NOT_LA BETWEEN opt_asymmetric b_expr AND a_expr %prec NOT_LA
  {
    $$.val = &ast.RangeCond{Not: true, Left: $1.expr(), From: $5.expr(), To: $7.expr()}
  }
| a_expr BETWEEN SYMMETRIC b_expr AND a_expr %prec BETWEEN
  {
    $$.val = &ast.RangeCond{Symmetric: true, Left: $1.expr(), From: $4.expr(), To: $6.expr()}
  }
| a_expr NOT_LA BETWEEN SYMMETRIC b_expr AND a_expr %prec NOT_LA
  {
    $$.val = &ast.RangeCond{Not: true, Symmetric: true, Left: $1.expr(), From: $5.expr(), To: $7.expr()}
  }
| a_expr IN in_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.In, Left: $1.expr(), Right: $3.expr()}
  }
| a_expr NOT_LA IN in_expr %prec NOT_LA
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.NotIn, Left: $1.expr(), Right: $4.expr()}
  }
| a_expr subquery_op sub_type a_expr %prec CONCAT
  {
    op := $3.cmpOp()
    subOp := $2.op()
    subOpCmp, ok := subOp.(ast.ComparisonOperator)
    if !ok {
      sqllex.Error(fmt.Sprintf("%s %s <array> is invalid because %q is not a boolean operator",
        subOp, op, subOp))
      return 1
    }
    $$.val = &ast.ComparisonExpr{
      Operator: op,
      SubOperator: subOpCmp,
      Left: $1.expr(),
      Right: $4.expr(),
    }
  }
| DEFAULT
  {
    $$.val = ast.DefaultVal{}
  }


| UNIQUE '(' error { return unimplemented(sqllex, "UNIQUE predicate") }








b_expr:
  c_expr
| b_expr TYPECAST cast_target
  {
    $$.val = &ast.CastExpr{Expr: $1.expr(), Type: $3.typeReference(), SyntaxMode: ast.CastShort}
  }
| b_expr TYPEANNOTATE typename
  {
    $$.val = &ast.AnnotateTypeExpr{Expr: $1.expr(), Type: $3.typeReference(), SyntaxMode: ast.AnnotateShort}
  }
| '+' b_expr %prec UMINUS
  {
    $$.val = $2.expr()
  }
| '-' b_expr %prec UMINUS
  {
    $$.val = unaryNegation($2.expr())
  }
| '~' b_expr %prec UMINUS
  {
    $$.val = &ast.UnaryExpr{Operator: ast.UnaryComplement, Expr: $2.expr()}
  }
| b_expr '+' b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Plus, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr '-' b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Minus, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr '*' b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Mult, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr '/' b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Div, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr FLOORDIV b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.FloorDiv, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr '%' b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Mod, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr '^' b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Pow, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr '#' b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Bitxor, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr '&' b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Bitand, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr '|' b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Bitor, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr '<' b_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.LT, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr '>' b_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.GT, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr '=' b_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.EQ, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr CONCAT b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.Concat, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr LSHIFT b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.LShift, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr RSHIFT b_expr
  {
    $$.val = &ast.BinaryExpr{Operator: ast.RShift, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr LESS_EQUALS b_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.LE, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr GREATER_EQUALS b_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.GE, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr NOT_EQUALS b_expr
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.NE, Left: $1.expr(), Right: $3.expr()}
  }
| b_expr IS DISTINCT FROM b_expr %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.IsDistinctFrom, Left: $1.expr(), Right: $5.expr()}
  }
| b_expr IS NOT DISTINCT FROM b_expr %prec IS
  {
    $$.val = &ast.ComparisonExpr{Operator: ast.IsNotDistinctFrom, Left: $1.expr(), Right: $6.expr()}
  }
| b_expr IS OF '(' type_list ')' %prec IS
  {
    $$.val = &ast.IsOfTypeExpr{Expr: $1.expr(), Types: $5.typeReferences()}
  }
| b_expr IS NOT OF '(' type_list ')' %prec IS
  {
    $$.val = &ast.IsOfTypeExpr{Not: true, Expr: $1.expr(), Types: $6.typeReferences()}
  }








c_expr:
  d_expr
| d_expr array_subscripts
  {
    $$.val = &ast.IndirectionExpr{
      Expr: $1.expr(),
      Indirection: $2.arraySubscripts(),
    }
  }
| case_expr
| EXISTS select_with_parens
  {
    $$.val = &ast.Subquery{Select: $2.selectStmt(), Exists: true}
  }































d_expr:
  ICONST
  {
    $$.val = $1.numVal()
  }
| FCONST
  {
    $$.val = $1.numVal()
  }
| SCONST
  {
    $$.val = ast.NewStrVal($1)
  }
| BCONST
  {
    $$.val = ast.NewBytesStrVal($1)
  }
| BITCONST
  {
    d, err := ast.ParseDBitArray($1)
    if err != nil { return setErr(sqllex, err) }
    $$.val = d
  }
| func_name '(' expr_list opt_sort_clause ')' SCONST { return unimplemented(sqllex, $1.unresolvedName().String() + "(...) SCONST") }
| typed_literal
  {
    $$.val = $1.expr()
  }
| interval_value
  {
    $$.val = $1.expr()
  }
| TRUE
  {
    $$.val = ast.MakeDBool(true)
  }
| FALSE
  {
    $$.val = ast.MakeDBool(false)
  }
| NULL
  {
    $$.val = ast.DNull
  }
| column_path_with_star
  {
    $$.val = ast.Expr($1.unresolvedName())
  }
| '@' iconst64
  {
    colNum := $2.int64()
    if colNum < 1 || colNum > int64(MaxInt) {
      sqllex.Error(fmt.Sprintf("invalid column ordinal: @%d", colNum))
      return 1
    }
    $$.val = ast.NewOrdinalReference(int(colNum-1))
  }
| PLACEHOLDER
  {
    p := $1.placeholder()
    sqllex.(*lexer).UpdateNumPlaceholders(p)
    $$.val = p
  }

| '(' a_expr ')' '.' '*'
  {
    $$.val = &ast.TupleStar{Expr: $2.expr()}
  }
| '(' a_expr ')' '.' unrestricted_name
  {
    $$.val = &ast.ColumnAccessExpr{Expr: $2.expr(), ColName: $5 }
  }
| '(' a_expr ')' '.' '@' ICONST
  {
    idx, err := $6.numVal().AsInt32()
    if err != nil || idx <= 0 { return setErr(sqllex, err) }
    $$.val = &ast.ColumnAccessExpr{Expr: $2.expr(), ByIndex: true, ColIndex: int(idx-1)}
  }
| '(' a_expr ')'
  {
    $$.val = &ast.ParenExpr{Expr: $2.expr()}
  }
| func_expr
| select_with_parens %prec UMINUS
  {
    $$.val = &ast.Subquery{Select: $1.selectStmt()}
  }
| labeled_row
  {
    $$.val = $1.tuple()
  }
| ARRAY select_with_parens %prec UMINUS
  {
    $$.val = &ast.ArrayFlatten{Subquery: &ast.Subquery{Select: $2.selectStmt()}}
  }
| ARRAY row
  {
    $$.val = &ast.Array{Exprs: $2.tuple().Exprs}
  }
| ARRAY array_expr
  {
    $$.val = $2.expr()
  }
| GROUPING '(' expr_list ')' { return unimplemented(sqllex, "d_expr grouping") }

func_application:
  func_name '(' ')'
  {
    $$.val = &ast.FuncExpr{Func: $1.resolvableFuncRefFromName()}
  }
| func_name '(' expr_list opt_sort_clause ')'
  {
    $$.val = &ast.FuncExpr{Func: $1.resolvableFuncRefFromName(), Exprs: $3.exprs(), OrderBy: $4.orderBy(), AggType: ast.GeneralAgg}
  }
| func_name '(' VARIADIC a_expr opt_sort_clause ')' { return unimplemented(sqllex, "variadic") }
| func_name '(' expr_list ',' VARIADIC a_expr opt_sort_clause ')' { return unimplemented(sqllex, "variadic") }
| func_name '(' ALL expr_list opt_sort_clause ')'
  {
    $$.val = &ast.FuncExpr{Func: $1.resolvableFuncRefFromName(), Type: ast.AllFuncType, Exprs: $4.exprs(), OrderBy: $5.orderBy(), AggType: ast.GeneralAgg}
  }


| func_name '(' DISTINCT expr_list ')'
  {
    $$.val = &ast.FuncExpr{Func: $1.resolvableFuncRefFromName(), Type: ast.DistinctFuncType, Exprs: $4.exprs()}
  }
| func_name '(' '*' ')'
  {
    $$.val = &ast.FuncExpr{Func: $1.resolvableFuncRefFromName(), Exprs: ast.Exprs{ast.StarExpr()}}
  }
| func_name '(' error { return helpWithFunction(sqllex, $1.resolvableFuncRefFromName()) }



typed_literal:



  func_name_no_crdb_extra SCONST
  {
    name := $1.unresolvedName()
    if name.NumParts == 1 {
      typName := name.Parts[0]






      if typName == "char" {
        $$.val = &ast.CastExpr{Expr: ast.NewStrVal($2), Type: types.MakeQChar(0), SyntaxMode: ast.CastPrepend}
      } else if typName == "serial" {
        switch sqllex.(*lexer).nakedIntType.Width() {
        case 32:
          $$.val = &ast.CastExpr{Expr: ast.NewStrVal($2), Type: &types.Serial4Type, SyntaxMode: ast.CastPrepend}
        default:
          $$.val = &ast.CastExpr{Expr: ast.NewStrVal($2), Type: &types.Serial8Type, SyntaxMode: ast.CastPrepend}
        }
      } else {




        var typ ast.ResolvableTypeReference
        var ok bool
        var err error
        var unimp int
        typ, ok, unimp = types.TypeForNonKeywordTypeName(typName)
        if !ok {
          switch unimp {
            case 0:


              aIdx := sqllex.(*lexer).NewAnnotation()
              typ, err = name.ToUnresolvedObjectName(aIdx)
              if err != nil { return setErr(sqllex, err) }
            case -1:
              return unimplemented(sqllex, "type name " + typName)
            default:
              return unimplementedWithIssueDetail(sqllex, unimp, typName)
          }
        }
      $$.val = &ast.CastExpr{Expr: ast.NewStrVal($2), Type: typ, SyntaxMode: ast.CastPrepend}
      }
    } else {
      aIdx := sqllex.(*lexer).NewAnnotation()
      res, err := name.ToUnresolvedObjectName(aIdx)
      if err != nil { return setErr(sqllex, err) }
      $$.val = &ast.CastExpr{Expr: ast.NewStrVal($2), Type: res, SyntaxMode: ast.CastPrepend}
    }
  }
| const_typename SCONST
  {
    $$.val = &ast.CastExpr{Expr: ast.NewStrVal($2), Type: $1.colType(), SyntaxMode: ast.CastPrepend}
  }








func_expr:
  func_application within_group_clause filter_clause over_clause
  {
    f := $1.expr().(*ast.FuncExpr)
    w := $2.expr().(*ast.FuncExpr)
    if w.AggType != 0 {
      f.AggType = w.AggType
      f.OrderBy = w.OrderBy
    }
    f.Filter = $3.expr()
    f.WindowDef = $4.windowDef()
    $$.val = f
  }
| func_expr_common_subexpr
  {
    $$.val = $1.expr()
  }





func_expr_windowless:
  func_application { $$.val = $1.expr() }
| func_expr_common_subexpr { $$.val = $1.expr() }


func_expr_common_subexpr:
  COLLATION FOR '(' a_expr ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("pg_collation_for"), Exprs: ast.Exprs{$4.expr()}}
  }
| CURRENT_DATE
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| CURRENT_SCHEMA
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }


| CURRENT_CATALOG
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("current_database")}
  }
| CURRENT_TIMESTAMP
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| CURRENT_TIME
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| LOCALTIMESTAMP
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| LOCALTIME
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| CURRENT_USER
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }


| CURRENT_ROLE
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("current_user")}
  }
| SESSION_USER
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("current_user")}
  }
| USER
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("current_user")}
  }
| CAST '(' a_expr AS cast_target ')'
  {
    $$.val = &ast.CastExpr{Expr: $3.expr(), Type: $5.typeReference(), SyntaxMode: ast.CastExplicit}
  }
| ANNOTATE_TYPE '(' a_expr ',' typename ')'
  {
    $$.val = &ast.AnnotateTypeExpr{Expr: $3.expr(), Type: $5.typeReference(), SyntaxMode: ast.AnnotateExplicit}
  }
| IF '(' a_expr ',' a_expr ',' a_expr ')'
  {
    $$.val = &ast.IfExpr{Cond: $3.expr(), True: $5.expr(), Else: $7.expr()}
  }
| IFERROR '(' a_expr ',' a_expr ',' a_expr ')'
  {
    $$.val = &ast.IfErrExpr{Cond: $3.expr(), Else: $5.expr(), ErrCode: $7.expr()}
  }
| IFERROR '(' a_expr ',' a_expr ')'
  {
    $$.val = &ast.IfErrExpr{Cond: $3.expr(), Else: $5.expr()}
  }
| ISERROR '(' a_expr ')'
  {
    $$.val = &ast.IfErrExpr{Cond: $3.expr()}
  }
| ISERROR '(' a_expr ',' a_expr ')'
  {
    $$.val = &ast.IfErrExpr{Cond: $3.expr(), ErrCode: $5.expr()}
  }
| NULLIF '(' a_expr ',' a_expr ')'
  {
    $$.val = &ast.NullIfExpr{Expr1: $3.expr(), Expr2: $5.expr()}
  }
| IFNULL '(' a_expr ',' a_expr ')'
  {
    $$.val = &ast.CoalesceExpr{Name: "IFNULL", Exprs: ast.Exprs{$3.expr(), $5.expr()}}
  }
| COALESCE '(' expr_list ')'
  {
    $$.val = &ast.CoalesceExpr{Name: "COALESCE", Exprs: $3.exprs()}
  }
| special_function

special_function:
  CURRENT_DATE '(' ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| CURRENT_DATE '(' error { return helpWithFunctionByName(sqllex, $1) }
| CURRENT_SCHEMA '(' ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| CURRENT_SCHEMA '(' error { return helpWithFunctionByName(sqllex, $1) }
| CURRENT_TIMESTAMP '(' ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| CURRENT_TIMESTAMP '(' a_expr ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1), Exprs: ast.Exprs{$3.expr()}}
  }
| CURRENT_TIMESTAMP '(' error { return helpWithFunctionByName(sqllex, $1) }
| CURRENT_TIME '(' ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| CURRENT_TIME '(' a_expr ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1), Exprs: ast.Exprs{$3.expr()}}
  }
| CURRENT_TIME '(' error { return helpWithFunctionByName(sqllex, $1) }
| LOCALTIMESTAMP '(' ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| LOCALTIMESTAMP '(' a_expr ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1), Exprs: ast.Exprs{$3.expr()}}
  }
| LOCALTIMESTAMP '(' error { return helpWithFunctionByName(sqllex, $1) }
| LOCALTIME '(' ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| LOCALTIME '(' a_expr ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1), Exprs: ast.Exprs{$3.expr()}}
  }
| LOCALTIME '(' error { return helpWithFunctionByName(sqllex, $1) }
| CURRENT_USER '(' ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1)}
  }
| CURRENT_USER '(' error { return helpWithFunctionByName(sqllex, $1) }
| EXTRACT '(' extract_list ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1), Exprs: $3.exprs()}
  }
| EXTRACT '(' error { return helpWithFunctionByName(sqllex, $1) }
| EXTRACT_DURATION '(' extract_list ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1), Exprs: $3.exprs()}
  }
| EXTRACT_DURATION '(' error { return helpWithFunctionByName(sqllex, $1) }
| OVERLAY '(' overlay_list ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1), Exprs: $3.exprs()}
  }
| OVERLAY '(' error { return helpWithFunctionByName(sqllex, $1) }
| POSITION '(' position_list ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("strpos"), Exprs: $3.exprs()}
  }
| SUBSTRING '(' substr_list ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1), Exprs: $3.exprs()}
  }
| SUBSTRING '(' error { return helpWithFunctionByName(sqllex, $1) }
| TREAT '(' a_expr AS typename ')' { return unimplemented(sqllex, "treat") }
| TRIM '(' BOTH trim_list ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("btrim"), Exprs: $4.exprs()}
  }
| TRIM '(' LEADING trim_list ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("ltrim"), Exprs: $4.exprs()}
  }
| TRIM '(' TRAILING trim_list ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("rtrim"), Exprs: $4.exprs()}
  }
| TRIM '(' trim_list ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction("btrim"), Exprs: $3.exprs()}
  }
| GREATEST '(' expr_list ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1), Exprs: $3.exprs()}
  }
| GREATEST '(' error { return helpWithFunctionByName(sqllex, $1) }
| LEAST '(' expr_list ')'
  {
    $$.val = &ast.FuncExpr{Func: ast.WrapFunction($1), Exprs: $3.exprs()}
  }
| LEAST '(' error { return helpWithFunctionByName(sqllex, $1) }



within_group_clause:
  WITHIN GROUP '(' single_sort_clause ')'
  {
    $$.val = &ast.FuncExpr{OrderBy: $4.orderBy(), AggType: ast.OrderedSetAgg}
  }
|
  {
    $$.val = &ast.FuncExpr{}
  }

filter_clause:
  FILTER '(' WHERE a_expr ')'
  {
    $$.val = $4.expr()
  }
|
  {
    $$.val = ast.Expr(nil)
  }


window_clause:
  WINDOW window_definition_list
  {
    $$.val = $2.window()
  }
|
  {
    $$.val = ast.Window(nil)
  }

window_definition_list:
  window_definition
  {
    $$.val = ast.Window{$1.windowDef()}
  }
| window_definition_list ',' window_definition
  {
    $$.val = append($1.window(), $3.windowDef())
  }

window_definition:
  window_name AS window_specification
  {
    n := $3.windowDef()
    n.Name = ast.Name($1)
    $$.val = n
  }

over_clause:
  OVER window_specification
  {
    $$.val = $2.windowDef()
  }
| OVER window_name
  {
    $$.val = &ast.WindowDef{Name: ast.Name($2)}
  }
|
  {
    $$.val = (*ast.WindowDef)(nil)
  }

window_specification:
  '(' opt_existing_window_name opt_partition_clause
    opt_sort_clause opt_frame_clause ')'
  {
    $$.val = &ast.WindowDef{
      RefName: ast.Name($2),
      Partitions: $3.exprs(),
      OrderBy: $4.orderBy(),
      Frame: $5.windowFrame(),
    }
  }









opt_existing_window_name:
  name
|   %prec CONCAT
  {
    $$ = ""
  }

opt_partition_clause:
  PARTITION BY expr_list
  {
    $$.val = $3.exprs()
  }
|
  {
    $$.val = ast.Exprs(nil)
  }

opt_frame_clause:
  RANGE frame_extent opt_frame_exclusion
  {
    $$.val = &ast.WindowFrame{
      Mode: ast.RANGE,
      Bounds: $2.windowFrameBounds(),
      Exclusion: $3.windowFrameExclusion(),
    }
  }
| ROWS frame_extent opt_frame_exclusion
  {
    $$.val = &ast.WindowFrame{
      Mode: ast.ROWS,
      Bounds: $2.windowFrameBounds(),
      Exclusion: $3.windowFrameExclusion(),
    }
  }
| GROUPS frame_extent opt_frame_exclusion
  {
    $$.val = &ast.WindowFrame{
      Mode: ast.GROUPS,
      Bounds: $2.windowFrameBounds(),
      Exclusion: $3.windowFrameExclusion(),
    }
  }
|
  {
    $$.val = (*ast.WindowFrame)(nil)
  }

frame_extent:
  frame_bound
  {
    startBound := $1.windowFrameBound()
    switch {
    case startBound.BoundType == ast.UnboundedFollowing:
      sqllex.Error("frame start cannot be UNBOUNDED FOLLOWING")
      return 1
    case startBound.BoundType == ast.OffsetFollowing:
      sqllex.Error("frame starting from following row cannot end with current row")
      return 1
    }
    $$.val = ast.WindowFrameBounds{StartBound: startBound}
  }
| BETWEEN frame_bound AND frame_bound
  {
    startBound := $2.windowFrameBound()
    endBound := $4.windowFrameBound()
    switch {
    case startBound.BoundType == ast.UnboundedFollowing:
      sqllex.Error("frame start cannot be UNBOUNDED FOLLOWING")
      return 1
    case endBound.BoundType == ast.UnboundedPreceding:
      sqllex.Error("frame end cannot be UNBOUNDED PRECEDING")
      return 1
    case startBound.BoundType == ast.CurrentRow && endBound.BoundType == ast.OffsetPreceding:
      sqllex.Error("frame starting from current row cannot have preceding rows")
      return 1
    case startBound.BoundType == ast.OffsetFollowing && endBound.BoundType == ast.OffsetPreceding:
      sqllex.Error("frame starting from following row cannot have preceding rows")
      return 1
    case startBound.BoundType == ast.OffsetFollowing && endBound.BoundType == ast.CurrentRow:
      sqllex.Error("frame starting from following row cannot have preceding rows")
      return 1
    }
    $$.val = ast.WindowFrameBounds{StartBound: startBound, EndBound: endBound}
  }




frame_bound:
  UNBOUNDED PRECEDING
  {
    $$.val = &ast.WindowFrameBound{BoundType: ast.UnboundedPreceding}
  }
| UNBOUNDED FOLLOWING
  {
    $$.val = &ast.WindowFrameBound{BoundType: ast.UnboundedFollowing}
  }
| CURRENT ROW
  {
    $$.val = &ast.WindowFrameBound{BoundType: ast.CurrentRow}
  }
| a_expr PRECEDING
  {
    $$.val = &ast.WindowFrameBound{
      OffsetExpr: $1.expr(),
      BoundType: ast.OffsetPreceding,
    }
  }
| a_expr FOLLOWING
  {
    $$.val = &ast.WindowFrameBound{
      OffsetExpr: $1.expr(),
      BoundType: ast.OffsetFollowing,
    }
  }

opt_frame_exclusion:
  EXCLUDE CURRENT ROW
  {
    $$.val = ast.ExcludeCurrentRow
  }
| EXCLUDE GROUP
  {
    $$.val = ast.ExcludeGroup
  }
| EXCLUDE TIES
  {
    $$.val = ast.ExcludeTies
  }
| EXCLUDE NO OTHERS
  {

    $$.val = ast.NoExclusion
  }
|
  {
    $$.val = ast.NoExclusion
  }








row:
  ROW '(' opt_expr_list ')'
  {
    $$.val = &ast.Tuple{Exprs: $3.exprs(), Row: true}
  }
| expr_tuple_unambiguous
  {
    $$.val = $1.tuple()
  }

labeled_row:
  row
| '(' row AS name_list ')'
  {
    t := $2.tuple()
    labels := $4.nameList()
    t.Labels = make([]string, len(labels))
    for i, l := range labels {
      t.Labels[i] = string(l)
    }
    $$.val = t
  }

sub_type:
  ANY
  {
    $$.val = ast.Any
  }
| SOME
  {
    $$.val = ast.Some
  }
| ALL
  {
    $$.val = ast.All
  }

math_op:
  '+' { $$.val = ast.Plus  }
| '-' { $$.val = ast.Minus }
| '*' { $$.val = ast.Mult  }
| '/' { $$.val = ast.Div   }
| FLOORDIV { $$.val = ast.FloorDiv }
| '%' { $$.val = ast.Mod    }
| '&' { $$.val = ast.Bitand }
| '|' { $$.val = ast.Bitor  }
| '^' { $$.val = ast.Pow }
| '#' { $$.val = ast.Bitxor }
| '<' { $$.val = ast.LT }
| '>' { $$.val = ast.GT }
| '=' { $$.val = ast.EQ }
| LESS_EQUALS    { $$.val = ast.LE }
| GREATER_EQUALS { $$.val = ast.GE }
| NOT_EQUALS     { $$.val = ast.NE }

subquery_op:
  math_op
| LIKE         { $$.val = ast.Like     }
| NOT_LA LIKE  { $$.val = ast.NotLike  }
| ILIKE        { $$.val = ast.ILike    }
| NOT_LA ILIKE { $$.val = ast.NotILike }




















expr_tuple1_ambiguous:
  '(' ')'
  {
    $$.val = &ast.Tuple{}
  }
| '(' tuple1_ambiguous_values ')'
  {
    $$.val = &ast.Tuple{Exprs: $2.exprs()}
  }

tuple1_ambiguous_values:
  a_expr
  {
    $$.val = ast.Exprs{$1.expr()}
  }
| a_expr ','
  {
    $$.val = ast.Exprs{$1.expr()}
  }
| a_expr ',' expr_list
  {
     $$.val = append(ast.Exprs{$1.expr()}, $3.exprs()...)
  }






expr_tuple_unambiguous:
  '(' ')'
  {
    $$.val = &ast.Tuple{}
  }
| '(' tuple1_unambiguous_values ')'
  {
    $$.val = &ast.Tuple{Exprs: $2.exprs()}
  }

tuple1_unambiguous_values:
  a_expr ','
  {
    $$.val = ast.Exprs{$1.expr()}
  }
| a_expr ',' expr_list
  {
     $$.val = append(ast.Exprs{$1.expr()}, $3.exprs()...)
  }

opt_expr_list:
  expr_list
|
  {
    $$.val = ast.Exprs(nil)
  }

expr_list:
  a_expr
  {
    $$.val = ast.Exprs{$1.expr()}
  }
| expr_list ',' a_expr
  {
    $$.val = append($1.exprs(), $3.expr())
  }

type_list:
  typename
  {
    $$.val = []ast.ResolvableTypeReference{$1.typeReference()}
  }
| type_list ',' typename
  {
    $$.val = append($1.typeReferences(), $3.typeReference())
  }

array_expr:
  '[' opt_expr_list ']'
  {
    $$.val = &ast.Array{Exprs: $2.exprs()}
  }
| '[' array_expr_list ']'
  {
    $$.val = &ast.Array{Exprs: $2.exprs()}
  }

array_expr_list:
  array_expr
  {
    $$.val = ast.Exprs{$1.expr()}
  }
| array_expr_list ',' array_expr
  {
    $$.val = append($1.exprs(), $3.expr())
  }

extract_list:
  extract_arg FROM a_expr
  {
    $$.val = ast.Exprs{ast.NewStrVal($1), $3.expr()}
  }
| expr_list
  {
    $$.val = $1.exprs()
  }



extract_arg:
  IDENT
| YEAR
| MONTH
| DAY
| HOUR
| MINUTE
| SECOND
| SCONST






overlay_list:
  a_expr overlay_placing substr_from substr_for
  {
    $$.val = ast.Exprs{$1.expr(), $2.expr(), $3.expr(), $4.expr()}
  }
| a_expr overlay_placing substr_from
  {
    $$.val = ast.Exprs{$1.expr(), $2.expr(), $3.expr()}
  }
| expr_list
  {
    $$.val = $1.exprs()
  }

overlay_placing:
  PLACING a_expr
  {
    $$.val = $2.expr()
  }


position_list:
  b_expr IN b_expr
  {
    $$.val = ast.Exprs{$3.expr(), $1.expr()}
  }
|
  {
    $$.val = ast.Exprs(nil)
  }












substr_list:
  a_expr substr_from substr_for
  {
    $$.val = ast.Exprs{$1.expr(), $2.expr(), $3.expr()}
  }
| a_expr substr_for substr_from
  {
    $$.val = ast.Exprs{$1.expr(), $3.expr(), $2.expr()}
  }
| a_expr substr_from
  {
    $$.val = ast.Exprs{$1.expr(), $2.expr()}
  }
| a_expr substr_for
  {
    $$.val = ast.Exprs{$1.expr(), ast.NewDInt(1), $2.expr()}
  }
| opt_expr_list
  {
    $$.val = $1.exprs()
  }

substr_from:
  FROM a_expr
  {
    $$.val = $2.expr()
  }

substr_for:
  FOR a_expr
  {
    $$.val = $2.expr()
  }

trim_list:
  a_expr FROM expr_list
  {
    $$.val = append($3.exprs(), $1.expr())
  }
| FROM expr_list
  {
    $$.val = $2.exprs()
  }
| expr_list
  {
    $$.val = $1.exprs()
  }

in_expr:
  select_with_parens
  {
    $$.val = &ast.Subquery{Select: $1.selectStmt()}
  }
| expr_tuple1_ambiguous






case_expr:
  CASE case_arg when_clause_list case_default END
  {
    $$.val = &ast.CaseExpr{Expr: $2.expr(), Whens: $3.whens(), Else: $4.expr()}
  }

when_clause_list:

  when_clause
  {
    $$.val = []*ast.When{$1.when()}
  }
| when_clause_list when_clause
  {
    $$.val = append($1.whens(), $2.when())
  }

when_clause:
  WHEN a_expr THEN a_expr
  {
    $$.val = &ast.When{Cond: $2.expr(), Val: $4.expr()}
  }

case_default:
  ELSE a_expr
  {
    $$.val = $2.expr()
  }
|
  {
    $$.val = ast.Expr(nil)
  }

case_arg:
  a_expr
|
  {
    $$.val = ast.Expr(nil)
  }

array_subscript:
  '[' a_expr ']'
  {
    $$.val = &ast.ArraySubscript{Begin: $2.expr()}
  }
| '[' opt_slice_bound ':' opt_slice_bound ']'
  {
    $$.val = &ast.ArraySubscript{Begin: $2.expr(), End: $4.expr(), Slice: true}
  }

opt_slice_bound:
  a_expr
|
  {
    $$.val = ast.Expr(nil)
  }

array_subscripts:
  array_subscript
  {
    $$.val = ast.ArraySubscripts{$1.arraySubscript()}
  }
| array_subscripts array_subscript
  {
    $$.val = append($1.arraySubscripts(), $2.arraySubscript())
  }

opt_asymmetric:
  ASYMMETRIC {}
|   {}

target_list:
  target_elem
  {
    $$.val = ast.SelectExprs{$1.selExpr()}
  }
| target_list ',' target_elem
  {
    $$.val = append($1.selExprs(), $3.selExpr())
  }

target_elem:
  a_expr AS target_name
  {
    $$.val = ast.SelectExpr{Expr: $1.expr(), As: ast.UnrestrictedName($3)}
  }





| a_expr IDENT
  {
    $$.val = ast.SelectExpr{Expr: $1.expr(), As: ast.UnrestrictedName($2)}
  }
| a_expr
  {
    $$.val = ast.SelectExpr{Expr: $1.expr()}
  }
| '*'
  {
    $$.val = ast.StarSelectExpr()
  }



table_index_name_list:
  table_index_name
  {
    $$.val = ast.TableIndexNames{$1.newTableIndexName()}
  }
| table_index_name_list ',' table_index_name
  {
    $$.val = append($1.newTableIndexNames(), $3.newTableIndexName())
  }

table_pattern_list:
  table_pattern
  {
    $$.val = ast.TablePatterns{$1.unresolvedName()}
  }
| table_pattern_list ',' table_pattern
  {
    $$.val = append($1.tablePatterns(), $3.unresolvedName())
  }














table_index_name:
  table_name '@' index_name
  {
    name := $1.unresolvedObjectName().ToTableName()
    $$.val = ast.TableIndexName{
       Table: name,
       Index: ast.UnrestrictedName($3),
    }
  }
| standalone_index_name
  {

    name := $1.unresolvedObjectName().ToTableName()
    indexName := ast.UnrestrictedName(name.ObjectName)
    name.ObjectName = ""
    $$.val = ast.TableIndexName{
        Table: name,
        Index: indexName,
    }
  }











table_pattern:
  simple_db_object_name
  {
     $$.val = $1.unresolvedObjectName().ToUnresolvedName()
  }
| complex_table_pattern



complex_table_pattern:
  complex_db_object_name
  {
     $$.val = $1.unresolvedObjectName().ToUnresolvedName()
  }
| db_object_name_component '.' unrestricted_name '.' '*'
  {
     $$.val = &ast.UnresolvedName{Star: true, NumParts: 3, Parts: ast.NameParts{"", $3, $1}}
  }
| db_object_name_component '.' '*'
  {
     $$.val = &ast.UnresolvedName{Star: true, NumParts: 2, Parts: ast.NameParts{"", $1}}
  }
| '*'
  {
     $$.val = &ast.UnresolvedName{Star: true, NumParts: 1}
  }

name_list:
  name
  {
    $$.val = ast.NameList{ast.Name($1)}
  }
| name_list ',' name
  {
    $$.val = append($1.nameList(), ast.Name($3))
  }


numeric_only:
  signed_iconst
| signed_fconst

signed_iconst:
  ICONST
| only_signed_iconst

only_signed_iconst:
  '+' ICONST
  {
    $$.val = $2.numVal()
  }
| '-' ICONST
  {
    n := $2.numVal()
    n.SetNegative()
    $$.val = n
  }

signed_fconst:
  FCONST
| only_signed_fconst

only_signed_fconst:
  '+' FCONST
  {
    $$.val = $2.numVal()
  }
| '-' FCONST
  {
    n := $2.numVal()
    n.SetNegative()
    $$.val = n
  }


iconst32:
  ICONST
  {
    val, err := $1.numVal().AsInt32()
    if err != nil { return setErr(sqllex, err) }
    $$.val = val
  }




signed_iconst64:
  signed_iconst
  {
    val, err := $1.numVal().AsInt64()
    if err != nil { return setErr(sqllex, err) }
    $$.val = val
  }


iconst64:
  ICONST
  {
    val, err := $1.numVal().AsInt64()
    if err != nil { return setErr(sqllex, err) }
    $$.val = val
  }

interval_value:
  INTERVAL SCONST opt_interval_qualifier
  {
    var err error
    var d ast.Datum
    if $3.val == nil {
      d, err = ast.ParseDInterval($2)
    } else {
      d, err = ast.ParseDIntervalWithTypeMetadata($2, $3.intervalTypeMetadata())
    }
    if err != nil { return setErr(sqllex, err) }
    $$.val = d
  }
| INTERVAL '(' iconst32 ')' SCONST
  {
    prec := $3.int32()
    if prec < 0 || prec > 6 {
      sqllex.Error(fmt.Sprintf("precision %d out of range", prec))
      return 1
    }
    d, err := ast.ParseDIntervalWithTypeMetadata($5, types.IntervalTypeMetadata{
      Precision: prec,
      PrecisionIsSet: true,
    })
    if err != nil { return setErr(sqllex, err) }
    $$.val = d
  }































collation_name:        unrestricted_name

partition_name:        unrestricted_name

index_name:            unrestricted_name

opt_index_name:        opt_name

zone_name:             unrestricted_name

target_name:           unrestricted_name

constraint_name:       name

database_name:         name

column_name:           name

family_name:           name

opt_family_name:       opt_name

table_alias_name:      name

statistics_name:       name

window_name:           name

view_name:             table_name

type_name:             db_object_name

sequence_name:         db_object_name

schema_name:           name

table_name:            db_object_name

standalone_index_name: db_object_name

explain_option_name:   non_reserved_word

cursor_name:           name












column_path:
  name
  {
      $$.val = &ast.UnresolvedName{NumParts:1, Parts: ast.NameParts{$1}}
  }
| prefixed_column_path

prefixed_column_path:
  db_object_name_component '.' unrestricted_name
  {
      $$.val = &ast.UnresolvedName{NumParts:2, Parts: ast.NameParts{$3,$1}}
  }
| db_object_name_component '.' unrestricted_name '.' unrestricted_name
  {
      $$.val = &ast.UnresolvedName{NumParts:3, Parts: ast.NameParts{$5,$3,$1}}
  }
| db_object_name_component '.' unrestricted_name '.' unrestricted_name '.' unrestricted_name
  {
      $$.val = &ast.UnresolvedName{NumParts:4, Parts: ast.NameParts{$7,$5,$3,$1}}
  }








column_path_with_star:
  column_path
| db_object_name_component '.' unrestricted_name '.' unrestricted_name '.' '*'
  {
    $$.val = &ast.UnresolvedName{Star:true, NumParts:4, Parts: ast.NameParts{"",$5,$3,$1}}
  }
| db_object_name_component '.' unrestricted_name '.' '*'
  {
    $$.val = &ast.UnresolvedName{Star:true, NumParts:3, Parts: ast.NameParts{"",$3,$1}}
  }
| db_object_name_component '.' '*'
  {
    $$.val = &ast.UnresolvedName{Star:true, NumParts:2, Parts: ast.NameParts{"",$1}}
  }








func_name:
  type_function_name
  {
    $$.val = &ast.UnresolvedName{NumParts:1, Parts: ast.NameParts{$1}}
  }
| prefixed_column_path



func_name_no_crdb_extra:
  type_function_name_no_crdb_extra
  {
    $$.val = &ast.UnresolvedName{NumParts:1, Parts: ast.NameParts{$1}}
  }
| prefixed_column_path






db_object_name:
  simple_db_object_name
| complex_db_object_name



simple_db_object_name:
  db_object_name_component
  {
    aIdx := sqllex.(*lexer).NewAnnotation()
    res, err := ast.NewUnresolvedObjectName(1, [3]string{$1}, aIdx)
    if err != nil { return setErr(sqllex, err) }
    $$.val = res
  }





complex_db_object_name:
  db_object_name_component '.' unrestricted_name
  {
    aIdx := sqllex.(*lexer).NewAnnotation()
    res, err := ast.NewUnresolvedObjectName(2, [3]string{$3, $1}, aIdx)
    if err != nil { return setErr(sqllex, err) }
    $$.val = res
  }
| db_object_name_component '.' unrestricted_name '.' unrestricted_name
  {
    aIdx := sqllex.(*lexer).NewAnnotation()
    res, err := ast.NewUnresolvedObjectName(3, [3]string{$5, $3, $1}, aIdx)
    if err != nil { return setErr(sqllex, err) }
    $$.val = res
  }





db_object_name_component:
  name
| type_func_name_crdb_extra_keyword
| cockroachdb_extra_reserved_keyword


name:
  IDENT
| unreserved_keyword
| col_name_keyword

opt_name:
  name
|
  {
    $$ = ""
  }

opt_name_parens:
  '(' name ')'
  {
    $$ = $2
  }
|
  {
    $$ = ""
  }




non_reserved_word_or_sconst:
  non_reserved_word
| SCONST


type_function_name:
  IDENT
| unreserved_keyword
| type_func_name_keyword


type_function_name_no_crdb_extra:
  IDENT
| unreserved_keyword
| type_func_name_no_crdb_extra_keyword


non_reserved_word:
  IDENT
| unreserved_keyword
| col_name_keyword
| type_func_name_keyword




unrestricted_name:
  IDENT
| unreserved_keyword
| col_name_keyword
| type_func_name_keyword
| reserved_keyword









unreserved_keyword:
  ABORT
| ACTION
| ADD
| ADMIN
| AFTER
| AGGREGATE
| ALTER
| ALWAYS
| AT
| ATTRIBUTE
| AUTOMATIC
| AUTHORIZATION
| BACKUP
| BEFORE
| BEGIN
| BUCKET_COUNT
| BUNDLE
| BY
| CACHE
| CANCEL
| CASCADE
| CHANGEFEED
| CLOSE
| CLUSTER
| COLUMNS
| COMMENT
| COMMENTS
| COMMIT
| COMMITTED
| COMPACT
| COMPLETE
| CONFLICT
| CONFIGURATION
| CONFIGURATIONS
| CONFIGURE
| CONSTRAINTS
| CONVERSION
| COPY
| COVERING
| CREATEROLE
| CUBE
| CURRENT
| CYCLE
| DATA
| DATABASE
| DATABASES
| DAY
| DEALLOCATE
| DECLARE
| DELETE
| DEFAULTS
| DEFERRED
| DETACHED
| DISCARD
| DOMAIN
| DOUBLE
| DROP
| ENCODING
| ENCRYPTION_PASSPHRASE
| ENUM
| ESCAPE
| EXCLUDE
| EXCLUDING
| EXECUTE
| EXECUTION
| EXPERIMENTAL
| EXPERIMENTAL_AUDIT
| EXPERIMENTAL_FINGERPRINTS
| EXPERIMENTAL_RELOCATE
| EXPERIMENTAL_REPLICA
| EXPIRATION
| EXPLAIN
| EXPORT
| EXTENSION
| FILES
| FILTER
| FIRST
| FOLLOWING
| FORCE_INDEX
| FUNCTION
| GENERATED
| GEOMETRYCOLLECTION
| GLOBAL
| GRANTS
| GROUPS
| HASH
| HIGH
| HISTOGRAM
| HOUR
| IDENTITY
| IMMEDIATE
| IMPORT
| INCLUDE
| INCLUDING
| INCREMENT
| INCREMENTAL
| INDEXES
| INJECT
| INSERT
| INTERLEAVE
| INVERTED
| ISOLATION
| JOB
| JOBS
| JSON
| KEY
| KEYS
| KV
| LANGUAGE
| LAST
| LC_COLLATE
| LC_CTYPE
| LEASE
| LESS
| LEVEL
| LINESTRING
| LIST
| LOCAL
| LOCKED
| LOGIN
| LOOKUP
| LOW
| MATCH
| MATERIALIZED
| MAXVALUE
| MERGE
| MINUTE
| MINVALUE
| MULTILINESTRING
| MULTIPOINT
| MULTIPOLYGON
| MONTH
| NAMES
| NAN
| NEVER
| NEXT
| NO
| NORMAL
| NO_INDEX_JOIN
| NOCREATEROLE
| NOLOGIN
| NOWAIT
| NULLS
| IGNORE_FOREIGN_KEYS
| OF
| OFF
| OIDS
| OPERATOR
| OPT
| OPTION
| OPTIONS
| ORDINALITY
| OTHERS
| OVER
| OWNED
| OWNER
| PARENT
| PARTIAL
| PARTITION
| PARTITIONS
| PASSWORD
| PAUSE
| PHYSICAL
| PLAN
| PLANS
| PRECEDING
| PREPARE
| PRESERVE
| PRIORITY
| PUBLIC
| PUBLICATION
| QUERIES
| QUERY
| RANGE
| RANGES
| READ
| RECURRING
| RECURSIVE
| REF
| REINDEX
| RELEASE
| RENAME
| REPEATABLE
| REPLACE
| RESET
| RESTORE
| RESTRICT
| RESUME
| RETRY
| REVISION_HISTORY
| REVOKE
| ROLE
| ROLES
| ROLLBACK
| ROLLUP
| ROWS
| RULE
| SCHEDULE
| SETTING
| SETTINGS
| STATUS
| SAVEPOINT
| SCATTER
| SCHEMA
| SCHEMAS
| SCRUB
| SEARCH
| SECOND
| SERIALIZABLE
| SEQUENCE
| SEQUENCES
| SERVER
| SESSION
| SESSIONS
| SET
| SHARE
| SHOW
| SIMPLE
| SKIP
| SNAPSHOT
| SPLIT
| SQL
| START
| STATISTICS
| STDIN
| STORAGE
| STORE
| STORED
| STORING
| STRICT
| SUBSCRIPTION
| SYNTAX
| SYSTEM
| TABLES
| TEMP
| TEMPLATE
| TEMPORARY
| TENANT
| TESTING_RELOCATE
| TEXT
| TIES
| TRACE
| TRANSACTION
| TRIGGER
| TRUNCATE
| TRUSTED
| TYPE
| THROTTLING
| UNBOUNDED
| UNCOMMITTED
| UNKNOWN
| UNLOGGED
| UNSPLIT
| UNTIL
| UPDATE
| UPSERT
| USE
| USERS
| VALID
| VALIDATE
| VALUE
| VARYING
| VIEW
| WITHIN
| WITHOUT
| WRITE
| YEAR
| ZONE










col_name_keyword:
  ANNOTATE_TYPE
| BETWEEN
| BIGINT
| BIT
| BOOLEAN
| CHAR
| CHARACTER
| CHARACTERISTICS
| COALESCE
| DEC
| DECIMAL
| EXISTS
| EXTRACT
| EXTRACT_DURATION
| FLOAT
| GEOGRAPHY
| GEOMETRY
| GREATEST
| GROUPING
| IF
| IFERROR
| IFNULL
| INT
| INTEGER
| INTERVAL
| ISERROR
| LEAST
| NULLIF
| NUMERIC
| OUT
| OVERLAY
| POINT
| POLYGON
| POSITION
| PRECISION
| REAL
| ROW
| SMALLINT
| STRING
| SUBSTRING
| TIME
| TIMETZ
| TIMESTAMP
| TIMESTAMPTZ
| TREAT
| TRIM
| VALUES
| VARBIT
| VARCHAR
| VIRTUAL
| WORK



type_func_name_keyword:
  type_func_name_no_crdb_extra_keyword
| type_func_name_crdb_extra_keyword














type_func_name_no_crdb_extra_keyword:
  COLLATION
| CROSS
| FULL
| INNER
| ILIKE
| IS
| ISNULL
| JOIN
| LEFT
| LIKE
| NATURAL
| NONE
| NOTNULL
| OUTER
| OVERLAPS
| RIGHT
| SIMILAR









type_func_name_crdb_extra_keyword:
  FAMILY










reserved_keyword:
  ALL
| ANALYSE
| ANALYZE
| AND
| ANY
| ARRAY
| AS
| ASC
| ASYMMETRIC
| BOTH
| CASE
| CAST
| CHECK
| COLLATE
| COLUMN
| CONCURRENTLY
| CONSTRAINT
| CREATE
| CURRENT_CATALOG
| CURRENT_DATE
| CURRENT_ROLE
| CURRENT_SCHEMA
| CURRENT_TIME
| CURRENT_TIMESTAMP
| CURRENT_USER
| DEFAULT
| DEFERRABLE
| DESC
| DISTINCT
| DO
| ELSE
| END
| EXCEPT
| FALSE
| FETCH
| FOR
| FOREIGN
| FROM
| GRANT
| GROUP
| HAVING
| IN
| INITIALLY
| INTERSECT
| INTO
| LATERAL
| LEADING
| LIMIT
| LOCALTIME
| LOCALTIMESTAMP
| NOT
| NULL
| OFFSET
| ON
| ONLY
| OR
| ORDER
| PLACING
| PRIMARY
| REFERENCES
| RETURNING
| SELECT
| SESSION_USER
| SOME
| SYMMETRIC
| TABLE
| THEN
| TO
| TRAILING
| TRUE
| UNION
| UNIQUE
| USER
| USING
| VARIADIC
| WHEN
| WHERE
| WINDOW
| WITH
| cockroachdb_extra_reserved_keyword








cockroachdb_extra_reserved_keyword:
  INDEX
| NOTHING

%%
