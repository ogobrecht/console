set define on
set serveroutput on
set verify off
set feedback off
set linesize 120
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback
column logfile noprint new_val logfile
select 'create_console_objects_' || to_char(sysdate,'yyyymmdd_hh24miss')
       || '.log' as logfile from dual;
spool &logfile

prompt
prompt Create Database Objects for Oracle Instrumentation Console
prompt ================================================================================

prompt (1) Set install log to &logfile

prompt (2) Set compiler flags
DECLARE
  v_apex_installed VARCHAR2(5) := 'FALSE'; -- Do not change (is set dynamically).
  v_utils_public   VARCHAR2(5) := 'FALSE'; -- Make utilities public available (for testing or other usages).
BEGIN
  FOR i IN (SELECT 1
              FROM all_objects
             WHERE object_type = 'SYNONYM'
               AND object_name = 'APEX_EXPORT')
  LOOP
    v_apex_installed := 'TRUE';
  END LOOP;

  -- Show unset compiler flags as errors (results for example in errors like "PLW-06003: unknown inquiry directive '$$UTILS_PUBLIC'")
  EXECUTE IMMEDIATE 'alter session set plsql_warnings = ''ENABLE:6003''';
  -- Finally set compiler flags
  EXECUTE IMMEDIATE 'alter session set plsql_ccflags = '''
    || 'apex_installed:' || v_apex_installed || ','
    || 'utils_public:'   || v_utils_public   || '''';
END;
/

prompt (3) Create or alter table console_logs
@console_logs.sql

prompt (4) Compile package console (spec)
@CONSOLE.pks
show errors

prompt (5) Compile package console (body)
@CONSOLE.pkb
show errors

prompt ================================================================================
prompt Finished
prompt
