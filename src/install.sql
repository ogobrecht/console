set define off feedback off
whenever sqlerror exit sql.sqlcode rollback

prompt
prompt Installing Oracle Instrumentation Console
prompt ==================================================

prompt Set compiler flags
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

prompt Create or alter table console_logs
@console_logs.sql

prompt Compile package console (spec)
@CONSOLE.pks
show errors

prompt Compile package console (body)
@CONSOLE.pkb
show errors

prompt ==================================================
prompt Installation Done
prompt
