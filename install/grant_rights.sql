set define on
set serveroutput on
set verify off
set feedback off
set linesize 240
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback

prompt ORACLE INSTRUMENTATION CONSOLE: GRANT RIGHTS TO CLIENT SCHEMA
declare
  v_schema                varchar2( 30);
  v_ddl                   varchar2(100);
begin

  --set config
  v_schema := substr(upper('&1'), 1, 30);

  --handle different issues with missing or incorrect target schemas
  if v_schema is null then
    raise_application_error(
      -20000,
      chr(10) || 'Target schema cannot be NULL - use it like so:' || chr(10)
      || '@grant_rights.sql "my_target_schema"');
  elsif v_schema like 'EXIT %' then
    raise_application_error(
      -20000,
      chr(10) || 'Seems that you forgot to provide the target schema as the first' || chr(10)
      || 'parameter to the script by calling something like this:' || chr(10)
      || 'echo exit | sqlplus ... @grant_rights.sql' || chr(10)
      || 'Please call the script with a parameter like this:' || chr(10)
      || '... @grant_rights.sql "my_target_schema"'
      );
  end if;

  --show current config
  dbms_output.put_line('- Target schema = ' || v_schema);

  --grant rights
  for i in (
    select object_name,
            object_type
      from user_objects
      where object_name = 'CONSOLE'
        and object_type = 'PACKAGE'
        or object_name in ('CONSOLE_LOGS', 'CONSOLE_CONF')
        and object_type = 'TABLE')
  loop
    v_ddl := 'grant ' ||
      case when i.object_type = 'TABLE' then 'select' else 'execute' end ||
      ' on ' || i.object_name || ' to ' || v_schema;
    dbms_output.put_line('- ' || v_ddl);
    execute immediate v_ddl;
  end loop;

end;
/
prompt - FINISHED

