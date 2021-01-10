set define on
set serveroutput on
set verify off
set feedback off
set linesize 120
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback
column logfile noprint new_val logfile
select to_char(sysdate,'yyyymmdd_hh24miss') || '_drop_synonyms.log' as logfile from dual;
spool &logfile

prompt
prompt Oracle Instrumentation Console: Drop Synonyms
prompt ================================================================================

prompt FIXME: implement

prompt ================================================================================
prompt Finished
prompt
spool off
