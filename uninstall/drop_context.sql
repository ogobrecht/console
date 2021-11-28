set define on
set serveroutput on
set verify off
set feedback off
set linesize 240
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback

prompt ORACLE INSTRUMENTATION CONSOLE: DROP CONTEXT
declare
  v_schema                varchar2( 30);
  v_package               varchar2( 30);
  v_namespace             varchar2( 30);
  v_ddl                   varchar2(200);
  v_context_exist_yn      varchar2(  1);
  v_dba_context_access_yn varchar2(  1);
  --
  table_does_not_exist    exception;
  insufficient_privileges exception;
  --
  pragma exception_init(table_does_not_exist,     -942);
  pragma exception_init(insufficient_privileges, -1031);
begin

  --set config
  v_schema    := substr(upper('&1'), 1, 30);
  v_package   := 'CONSOLE';
  v_namespace := v_package || '_' || substr(v_schema, 1, 30 - length(v_package));
  v_ddl       := 'drop context ' || v_namespace;

  --handle different issues with missing or incorrect target schemas
  if v_schema is null then
    raise_application_error(
      -20000,
      chr(10) || 'Target schema cannot be NULL - use it like so:' || chr(10)
      || '@uninstall/drop_context.sql "my_target_schema"');
  elsif v_schema like 'EXIT %' then
    raise_application_error(
      -20000,
      chr(10) || 'Seems that you forgot to provide the target schema as the first' || chr(10)
      || 'parameter to the script by calling something like this:' || chr(10)
      || 'echo exit | sqlplus ... @uninstall/drop_context.sql' || chr(10)
      || 'Please call the script with a parameter like this:' || chr(10)
      || '... @uninstall/drop_context.sql "my_target_schema"'
      );
  end if;

  --check for existing context
  begin
    execute immediate q'{
      select case when count(*) = 1 then 'Y' else 'N' end
        from dba_context
       where schema    = :v_schema
         and package   = :v_package
         and namespace = :v_namespace
    }' into v_context_exist_yn using v_schema, v_package, v_namespace;
    v_dba_context_access_yn := 'Y';
  exception
    when table_does_not_exist then
      v_dba_context_access_yn := 'N';
      v_context_exist_yn := 'N';
  end;

  --show current config
  dbms_output.put_line('- Target namespace = ' || v_namespace);
  dbms_output.put_line('- Target schema    = ' || v_schema);
  dbms_output.put_line('- Target package   = ' || v_package);

  --finally try to drop the context, if needed
  if v_dba_context_access_yn = 'Y' and v_context_exist_yn = 'N' then
    dbms_output.put_line('- Context not found, no action required');
  else
    if v_dba_context_access_yn = 'Y' and v_context_exist_yn = 'Y' then
      dbms_output.put_line('- Context found, try to run drop command');
    else
      dbms_output.put_line('- Context status unknown, try to run drop command');
    end if;
    begin
      dbms_output.put_line('- ' || v_ddl);
      execute immediate v_ddl;
      dbms_output.put_line('- It seems we were successful :-)');
    exception
      when insufficient_privileges then
        dbms_output.put_line(chr(10) || '- ERROR:');
        dbms_output.put_line('- You have not enough rights for this action - please ask your DBA for help.' || chr(10));
        raise;
    end;
  end if;
end;
/
prompt - FINISHED
