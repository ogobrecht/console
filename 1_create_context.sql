/*

Create Context for Oracle Instrumentation Console
-------------------------------------------------

This script creates a global accessible context for the schema provided in the
first parameter.

EXAMPLE

Start SQL*Plus, connect with a privileged user who can create a context and run
the script with the target installation schema for the Oracle Instrumentation
Console.

```shell
@create_context.sql "my_target_schema"
```

You should see one of the following outputs

If the context was created:

```shell
Create Context for Oracle Instrumentation Console
================================================================================
- Installation Log = 1_create_context_20210108_210835.log
- Target Namespace = CONSOLE_MY_TARGET_SCHEMA
- Target Schema    = MY_TARGET_SCHEMA
- Target Package   = CONSOLE
- Check for existing context
- Context not found, create it with the following command:
- create context CONSOLE_PLAYGROUND_DATA using PLAYGROUND_DATA.CONSOLE accessed globally
================================================================================
Done
```

If the context was already existing:

```shell
Create Context for Oracle Instrumentation Console
================================================================================
- Installation Log = 1_create_context_20210108_210840.log
- Target Namespace = CONSOLE_MY_TARGET_SCHEMA
- Target Schema    = MY_TARGET_SCHEMA
- Target Package   = CONSOLE
- Check for existing context
- Context found, no action needed
================================================================================
Done
```

META

- Author: [Ottmar Gobrecht](https://ogobrecht.github.io)
- Script: [1_create_context.sql](https://github.com/ogobrecht/console/blob/main/1_create_context.sql)
- Last Update: 2021-01-08

*/

set define on
set serveroutput on
set verify off
set feedback off
set linesize 120
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback
column logfile noprint new_val logfile
select '1_create_context_' || to_char(sysdate,'yyyymmdd_hh24miss')
       || '.log' as logfile from dual;
spool &logfile

prompt
prompt Create Context for Oracle Instrumentation Console
prompt ================================================================================
declare
  v_schema    varchar2( 30);
  v_package   varchar2( 30);
  v_namespace varchar2( 30);
  v_ddl       varchar2(200);
  v_count     pls_integer;
begin
  v_schema    := substr(upper('&1'), 1, 30);
  v_package   := 'CONSOLE';
  v_namespace := v_package || '_' || substr(v_schema, 1, 22);
  v_ddl       := 'create context ' || v_namespace || ' using '
                 || v_schema || '.' || v_package || ' accessed globally';
  dbms_output.put_line('- Installation Log = &logfile');
  dbms_output.put_line('- Target Namespace = ' || v_namespace);
  dbms_output.put_line('- Target Schema    = ' || v_schema);
  dbms_output.put_line('- Target Package   = ' || v_package);
  dbms_output.put_line('- Check for existing context');
  select count(*)
    into v_count
    from dba_context
   where schema    = v_schema
     and package   = v_package
     and namespace = v_namespace;
  if v_count = 1 then
    dbms_output.put_line('- Context found, no action needed');
  else
    dbms_output.put_line('- Context not found, create it with the following command:');
    dbms_output.put_line('- ' || v_ddl);
    execute immediate v_ddl;
  end if;
end;
/
prompt ================================================================================
prompt Done
prompt
spool off
