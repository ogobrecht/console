set define on
set serveroutput on
set verify off
set feedback off
set linesize 240
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback

prompt ORACLE INSTRUMENTATION CONSOLE: DROP CONSOLE OBJECTS

declare
  v_count        pls_integer;
  v_object_count pls_integer := 0;
  v_ddl          varchar2 (100 char);
begin

  --package body
  for i in (select 'drop ' || lower(object_type) || ' ' || object_name as ddl
              from user_objects
             where object_type = 'PACKAGE BODY'
               and object_name = 'CONSOLE')
  loop
    dbms_output.put_line('- ' || i.ddl);
    execute immediate i.ddl;
    v_object_count := v_object_count + 1;
  end loop;

  --package spec
  for i in (select 'drop ' || lower(object_type) || ' ' || object_name as ddl
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
     where table_name in ('CONSOLE_LOGS','CONSOLE_SESSIONS', 'CONSOLE_LEVELS', 'CONSOLE_CONSTRAINT_MESSAGES') )
  loop
    execute immediate 'select count(*) from ' || i.table_name ||
      case when i.table_name = 'CONSOLE_LOGS'
        then q'{ where log_level = 0 and message not like '{o,o} CONSOLE%' }'
        else null
      end
      into v_count;
    if i.table_name in ('CONSOLE_LOGS','CONSOLE_CONSTRAINT_MESSAGES') and v_count > 0 then
      dbms_output.put_line(
        '- NOTE: ' || i.table_name ||
        ' contains important user data - please review and drop it by youself (' ||
        i.ddl || ')');
    else
      dbms_output.put_line('- ' || i.ddl);
      execute immediate i.ddl;
      v_object_count := v_object_count + 1;
    end if;
  end loop;

  dbms_output.put_line('- ' || v_object_count || ' object' || case when v_object_count != 1 then 's' end || ' dropped');

end;
/

prompt - FINISHED
