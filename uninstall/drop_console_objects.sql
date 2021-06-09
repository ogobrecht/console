set define on
set serveroutput on
set verify off
set feedback off
set linesize 240
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback

prompt ORACLE INSTRUMENTATION CONSOLE: DROP DATABASE OBJECTS

declare
  v_count        pls_integer;
  v_object_count pls_integer := 0;
  v_ddl          varchar2 (100);
begin

  --cleanup job
  for i in (
    select 'begin sys.dbms_scheduler.drop_job(job_name => ''' || job_name || ''', force => true); end;' as ddl
      from user_scheduler_jobs
     where job_name = 'CONSOLE_CLEANUP' )
  loop
    dbms_output.put_line('- ' || i.ddl);
    execute immediate i.ddl;
    v_object_count := v_object_count + 1;
  end loop;

  --package body
  for i in (
    select 'drop ' || lower(object_type) || ' ' || object_name as ddl
      from user_objects
     where object_type = 'PACKAGE BODY'
       and object_name = 'CONSOLE')
  loop
    dbms_output.put_line('- ' || i.ddl);
    execute immediate i.ddl;
    v_object_count := v_object_count + 1;
  end loop;

  --package spec
  for i in (
    select 'drop ' || lower(object_type) || ' ' || object_name as ddl
      from user_objects
     where object_type = 'PACKAGE'
       and object_name = 'CONSOLE')
  loop
    dbms_output.put_line('- ' || i.ddl);
    execute immediate i.ddl;
    v_object_count := v_object_count + 1;
  end loop;

  --tables
  for i in (
    select 'drop table ' || table_name || ' cascade constraints' as ddl,
           table_name
      from user_tables
     where table_name in (
       'CONSOLE_CLIENT_PREFS',
       'CONSOLE_CONF',         -- replaced by console_global_conf
       'CONSOLE_GLOBAL_CONF',
       'CONSOLE_LOGS',
       'CONSOLE_SESSIONS'      -- replaced by console_client_prefs
       ) )
  loop
    --FIXME: Should we really check for permanent entries?
    --execute immediate 'select count(*) from ' || i.table_name ||
    --  case when i.table_name = 'CONSOLE_LOGS' then q'{ where permanent = 'Y' }' else null end
    --  into v_count;
    --if i.table_name = 'CONSOLE_LOGS' and v_count > 0 then
    --  dbms_output.put_line(
    --    '- NOTE: ' || i.table_name ||
    --    ' contains important user data - please review and drop it by youself (' ||
    --    i.ddl || ')');
    --else
      dbms_output.put_line('- ' || i.ddl);
      execute immediate i.ddl;
      v_object_count := v_object_count + 1;
    --end if;
  end loop;

  dbms_output.put_line('- ' || v_object_count || ' object' || case when v_object_count != 1 then 's' end || ' dropped');

end;
/

prompt - FINISHED
