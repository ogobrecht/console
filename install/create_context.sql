set define on
set serveroutput on
set verify off
set feedback off
set linesize 120
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback
column logfile noprint new_val logfile
select to_char(sysdate,'yyyymmdd_hh24miss') || '_create_context.log' as logfile from dual;
spool &logfile

prompt
prompt Oracle Instrumentation Console: Create Context
prompt ================================================================================
declare
  v_schema    varchar2( 30);
  v_package   varchar2( 30);
  v_namespace varchar2( 30);
  v_ddl       varchar2(200);
  v_count     pls_integer;
begin
  v_schema    := substr(upper('&1'), 1, 30);
  if v_schema is null then
    raise_application_error(-20000, 'Target schema cannot be NULL (call @create_context.sql "my_target_schema").');
  end if;
  v_package   := 'CONSOLE';
  v_namespace := v_package || '_' || substr(v_schema, 1, 22);
  v_ddl       := 'create context ' || v_namespace || ' using '
                 || v_schema || '.' || v_package || ' accessed globally';
  dbms_output.put_line('(1) Show config');
  dbms_output.put_line('Installation log = &logfile');
  dbms_output.put_line('Target namespace = ' || v_namespace);
  dbms_output.put_line('Target schema    = ' || v_schema);
  dbms_output.put_line('Target package   = ' || v_package);
  dbms_output.put_line('(2) Create context');
  select count(*)
    into v_count
    from dba_context
   where schema    = v_schema
     and package   = v_package
     and namespace = v_namespace;
  if v_count = 0 then
    dbms_output.put_line('Context not found, run create command:');
    dbms_output.put_line(v_ddl);
    execute immediate v_ddl;
  else
    dbms_output.put_line('Context found, no action required.');
  end if;
end;
/
prompt ================================================================================
prompt Finished
prompt
spool off
