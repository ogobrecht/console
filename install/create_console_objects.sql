--DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT sources/build.js
set define on
set serveroutput on
set verify off
set feedback off
set linesize 240
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback

prompt ORACLE INSTRUMENTATION CONSOLE: CREATE DATABASE OBJECTS
prompt - Project page https://github.com/ogobrecht/console
-- select * from all_plsql_object_settings where name = 'CONSOLE';

prompt - Set compiler flags
declare
  v_apex_installed varchar2(5) := 'FALSE'; -- Do not change (is set dynamically).
  v_apex_fun       varchar2(5) := 'FALSE'; -- Bring some fun into the APEX error handling ;-)
  v_utils_public   varchar2(5) := 'FALSE'; -- Make utilities public available (for testing or other usages).
begin

  --Basic settings
  execute immediate 'alter session set plsql_warnings = ''enable:all,disable:5004,disable:6005,disable:6006,disable:6009,disable:6010,disable:6027''';
  execute immediate 'alter session set plscope_settings = ''identifiers:all''';
  execute immediate 'alter session set plsql_optimize_level = 3';

  for i in (select 1
              from all_objects
             where object_type = 'SYNONYM'
               and object_name = 'APEX_EXPORT')
  loop
    v_apex_installed := 'TRUE';
  end loop;

  execute immediate 'alter session set plsql_ccflags = '''
    || 'APEX_INSTALLED:' || v_apex_installed || ','
    || 'APEX_FUN:      ' || v_apex_fun       || ','
    || 'UTILS_PUBLIC:'   || v_utils_public   || '''';

end;
/

declare
  v_count pls_integer;
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_CONF';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_CONF not found, run creation command');
    execute immediate q'{
      create table console_conf (
        conf_id              varchar2 (  16 byte)  not null  ,
        conf_by              varchar2 (  64 byte)            ,
        conf_sysdate         date                  not null  ,
        level_id             number   (   1,0)     not null  ,
        level_name           varchar2 (  10 byte)  not null  ,
        check_interval       number   (   2,0)     not null  ,
        units_level_warning  varchar2 (4000 byte)            ,
        units_level_info     varchar2 (4000 byte)            ,
        units_level_debug    varchar2 (4000 byte)            ,
        units_level_trace    varchar2 (4000 byte)            ,
        --
        constraint  console_conf_pk   primary key ( conf_id                 )  ,
        constraint  console_conf_ck1  check       ( conf_id = 'GLOBAL_CONF' )  ,
        --
        constraint  console_conf_ck2  check ( level_id   in (1, 2, 3)                                          )  ,
        constraint  console_conf_ck3  check ( level_name =  decode(level_id, 1,'error', 2,'warning', 3,'info') )  ,
        --
        constraint  console_conf_ck4  check ( check_interval between 10 and 60 )
      ) organization index
    }';
  else
    dbms_output.put_line('- Table CONSOLE_CONF found, no action required');
  end if;

end;
/

comment on table  console_conf                     is 'Holds the global console configuration in a single record.';
comment on column console_conf.conf_id             is 'The primary key - is secured by a check constraint which allows only one record in the table.';
comment on column console_conf.conf_by             is 'The user who configured the console the last time.';
comment on column console_conf.conf_sysdate        is 'The date when the console was configured the last time.';
comment on column console_conf.level_id            is 'The defined global log level ID.';
comment on column console_conf.level_name          is 'The defined log level name.';
comment on column console_conf.check_interval      is 'The number of seconds a session looks for a changed configuration.';
comment on column console_conf.units_level_warning is 'A comma separated list of units configured for level warning.';
comment on column console_conf.units_level_info    is 'A comma separated list of units configured for level info.';
comment on column console_conf.units_level_debug   is 'A comma separated list of units configured for level debug.';
comment on column console_conf.units_level_trace   is 'A comma separated list of units configured for level trace.';



declare
  v_count pls_integer;
  --
  procedure create_index (
    p_type        varchar2,
    p_column_list varchar2,
    p_postfix     varchar2)
  is
  begin
    with t as (
      select listagg(column_name, ', ') within group(order by column_position) as index_column_list
        from user_ind_columns
      where table_name = 'CONSOLE_LOGS'
      group by index_name
    )
    select count(*)
      into v_count
      from t
    where index_column_list = p_column_list;
    if v_count = 0 then
      dbms_output.put_line('- Index for CONSOLE_LOGS column list ' || p_column_list || ' not found, run creation command');
      execute immediate 'create ' || p_type || ' index CONSOLE_LOGS_' || p_postfix || ' on CONSOLE_LOGS (' || p_column_list || ')';
    else
      dbms_output.put_line('- Index for CONSOLE_LOGS column list ' || p_column_list || ' found, no action required');
    end if;
  end;
  --
begin

  --create table
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_LOGS';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_LOGS not found, run creation command');
    execute immediate q'{
      create table console_logs (
        log_id             number   (   *,0)     generated by default  on null   as identity,
        log_systime        timestamp                                   not null  ,
        level_id           number   (   1,0)                           not null  ,
        level_name         varchar2 (  10 byte)                        not null  ,
        permanent          varchar2 (   1 byte)                        not null  ,
        scope              varchar2 ( 256 byte)                                  ,
        message            clob                                                  ,
        error_code         number   (  10,0)                                     ,
        call_stack         varchar2 (4000 byte)                                  ,
        session_user       varchar2 (  32 byte)                                  ,
        module             varchar2 (  48 byte)                                  ,
        action             varchar2 (  32 byte)                                  ,
        client_info        varchar2 (  64 byte)                                  ,
        client_identifier  varchar2 (  64 byte)                                  ,
        ip_address         varchar2 (  48 byte)                                  ,
        host               varchar2 (  64 byte)                                  ,
        os_user            varchar2 (  64 byte)                                  ,
        os_user_agent      varchar2 ( 200 byte)                                  ,
        --
        constraint  console_logs_pk  primary key (log_id)                        ,
        constraint  console_logs_ck  check       (permanent in ('Y','N'))
      )
    }';
  else
    dbms_output.put_line('- Table CONSOLE_LOGS found, no action required');
  end if;

  --FIXME: which way should we go with indexes?
    create_index (null    , 'LOG_SYSTIME, LEVEL_ID', 'IX');
  --create_index (null    , 'LOG_SYSTIME'          , 'IX1');
  --create_index ('bitmap', 'LEVEL_ID, LEVEL_NAME' , 'IX2');
  --create_index ('bitmap', 'PERMANENT'            , 'IX3');

end;
/

comment on table  console_logs                   is 'Table for log entries of the package CONSOLE. Column names are mostly driven by the attribute names of SYS_CONTEXT(''USERENV'') and DBMS_SESSION for easier mapping and clearer context.';
comment on column console_logs.log_id            is 'Primary key based on a sequence.';
comment on column console_logs.log_systime       is 'Log systimestamp.';
comment on column console_logs.level_id          is 'Level ID. Can be 0 (permanent), 1 (error), 2 (warning), 3 (info), 4 (debug) or 5 (trace).';
comment on column console_logs.level_name        is 'Level name. Can be Permanent, Error, Warning, Info or Verbose.';
comment on column console_logs.scope             is 'The current unit/module in which the log was generated (OWNER.PACKAGE.MODULE.SUBMODULE, line number). Couls also be an external scope provided by the user.';
comment on column console_logs.message           is 'The log message itself.';
comment on column console_logs.error_code        is 'The error code. Is normally the SQLCODE, but could also be a user error code when log entry was coming from external (user interface, ETL preprocessing, whatever...)';
comment on column console_logs.call_stack        is 'The call_stack and in case of an error also the error stack and error backtrace. Could also be an external call stack provided by the user.';
comment on column console_logs.session_user      is 'The name of the session user (the user who logged on). This may change during the duration of a database session as Real Application Security sessions are attached or detached. For enterprise users, returns the schema. For other users, returns the database user name. If a Real Application Security session is currently attached to the database session, returns user XS$NULL.';
comment on column console_logs.module            is 'The application name (module). Can be set by an application using the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.action            is 'The action/position in the module (application name). Can be set through the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.client_info       is 'The client information. Can be set by an application using the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.client_identifier is 'The client identifier. Can be set by an application using the DBMS_SESSION.SET_IDENTIFIER procedure, the OCI attribute OCI_ATTR_CLIENT_IDENTIFIER, or Oracle Dynamic Monitoring Service (DMS). This attribute is used by various database components to identify lightweight application users who authenticate as the same database user.';
comment on column console_logs.ip_address        is 'IP address of the machine from which the client is connected. If the client and server are on the same machine and the connection uses IPv6 addressing, then it is set to ::1.';
comment on column console_logs.host              is 'Name of the host machine from which the client is connected.';
comment on column console_logs.os_user           is 'Operating system user name of the client process that initiated the database session.';
comment on column console_logs.os_user_agent     is 'Operating system user agent (for example web browser engine). This information will only be available, if actively provided to one of the console log methods. For APEX we will have a plug-in in the future to log client side JavaScript errors - then this attribute will be interesting.';




declare
  v_count pls_integer;
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_SESSIONS';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_SESSIONS not found, run creation command');
    execute immediate q'{
      create table console_sessions (
        client_identifier varchar2 (64 byte)  not null  ,
        init_by           varchar2 (64 byte)            ,
        init_sysdate      date                not null  ,
        exit_sysdate      date                not null  ,
        level_id          number   ( 1,0)     not null  ,
        level_name        varchar2 (10 byte)  not null  ,
        cache_size        number   ( 4,0)     not null  ,
        check_interval    number   ( 2,0)     not null  ,
        call_stack        varchar2 ( 1 byte)  not null  ,
        user_env          varchar2 ( 1 byte)  not null  ,
        apex_env          varchar2 ( 1 byte)  not null  ,
        cgi_env           varchar2 ( 1 byte)  not null  ,
        console_env       varchar2 ( 1 byte)  not null  ,
        --
        constraint  console_sessions_pk   primary key ( client_identifier          )  ,
        constraint  console_sessions_ck1  check       ( call_stack  in ('Y','N')   )  ,
        constraint  console_sessions_ck2  check       ( user_env    in ('Y','N')   )  ,
        constraint  console_sessions_ck3  check       ( apex_env    in ('Y','N')   )  ,
        constraint  console_sessions_ck4  check       ( cgi_env     in ('Y','N')   )  ,
        constraint  console_sessions_ck5  check       ( console_env in ('Y','N')   )  ,
        --
        constraint  console_sessions_ck6  check       ( level_id   in (1, 2, 3, 4, 5)                                                          )  ,
        constraint  console_sessions_ck7  check       ( level_name =  decode(level_id, 1,'error', 2,'warning', 3,'info', 4,'debug', 5,'trace') )  ,
        --
        constraint  console_sessions_ck8  check       ( check_interval between 1 and 60 )
      ) organization index
    }';
  else
    dbms_output.put_line('- Table CONSOLE_SESSIONS found, no action required');
  end if;

end;
/

comment on table  console_sessions                     is 'Holds the sessions that are initialized for debugging. Used to manage the global context.';
comment on column console_sessions.init_by             is 'The user who initiated the logging.';
comment on column console_sessions.init_sysdate        is 'The logging start date for the nominated client identifier.';
comment on column console_sessions.exit_sysdate        is 'The planned logging end date for the nominated client identifier.';
comment on column console_sessions.client_identifier   is 'The client identifier provided by the application or console itself (this is the primary key).';
comment on column console_sessions.level_id            is 'The defined log level ID. Any session not listed here has the configured global log level defined in CONSOLE_CONF.';
comment on column console_sessions.level_name          is 'The defined log level name.';
comment on column console_sessions.check_interval      is 'The number of seconds a session looks for a changed configuration. Defaults to 10.';
comment on column console_sessions.cache_size          is 'The number of log entries to cache before they are written down into the log table. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shared environments like APEX.';
comment on column console_sessions.call_stack          is 'Should the call_stack be included.';
comment on column console_sessions.user_env            is 'Should the user environment be included.';
comment on column console_sessions.apex_env            is 'Should the APEX environment be included.';
comment on column console_sessions.cgi_env             is 'Should the CGI environment be included.';
comment on column console_sessions.console_env         is 'Should the console environment be included.';




prompt - Package CONSOLE (spec)
create or replace package console authid definer is

c_name    constant varchar2 ( 30 byte ) := 'Oracle Instrumentation Console'       ;
c_version constant varchar2 ( 20 byte ) := '1.0-beta4'                            ;
c_url     constant varchar2 ( 40 byte ) := 'https://github.com/ogobrecht/console' ;
c_license constant varchar2 (  5 byte ) := 'MIT'                                  ;
c_author  constant varchar2 ( 15 byte ) := 'Ottmar Gobrecht'                      ;

c_level_error     constant pls_integer := 1 ;
c_level_warning   constant pls_integer := 2 ;
c_level_info      constant pls_integer := 3 ;
c_level_debug     constant pls_integer := 4 ;
c_level_trace     constant pls_integer := 5 ;

/**

Oracle Instrumentation Console
==============================

An instrumentation tool for Oracle developers. Save to install on production and
mostly API compatible with the [JavaScript
console](https://developers.google.com/web/tools/chrome-devtools/console/api).

For more infos have a look at the [project page on
GitHub](https://github.com/ogobrecht/console).

**/


--------------------------------------------------------------------------------
-- PUBLIC TYPES
--------------------------------------------------------------------------------

type rec_key_value is record(
  key    varchar2 ( 128 byte)  ,
  value  varchar2 (4000 byte)  );
type tab_key_value is table of rec_key_value;
type tab_logs      is table of console_logs%rowtype;


--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------

function my_client_identifier return varchar2;
/**

Returns the current session identifier of the own session. This information is cached in a
package variable and determined on package initialization.

```sql
select console.my_client_identifier from dual;
```

**/

--------------------------------------------------------------------------------

function my_log_level return integer;
/**

Returns the current log level of the own session. This information is cached in a
package variable for performance reasons and re-evaluated every 10 seconds.

```sql
select console.my_log_level from dual;
```

**/

--------------------------------------------------------------------------------

function view_last (p_log_rows integer default 100) return tab_logs pipelined;
/**

View the last log entries from the log cache and the log table (if not enough in
the cache) in descending order.

The entries without a log_id are from the cache, the others from the log table.

EXAMPLE

```sql
--init logging for own session
exec console.init(
  p_level          => c_level_debug ,
  p_duration       => 90            ,
  p_cache_size     => 10            ,
  p_check_interval => 30            );

--test some business logic
begin
  --your code here;

  console.log('test', p_user_env => true);
end;
{{/}}

--view last cache and log entries
select * from console.view_last(50);
```

**/

--------------------------------------------------------------------------------

procedure error_save_stack;
/**

Saves the error stack, so that you are able to handle the error on the most
outer point in your code without loosing detail information of the original
error nested deeper in your code.

With this method we try to prevent log spoiling  - if you use it right you can
have ONE log entry for your errors with the saved details where the error
occured.

EXAMPLE

```sql
set define off
set feedback off
set serveroutput on
set linesize 120
set pagesize 40
column call_stack heading "Call Stack" format a120
whenever sqlerror exit sql.sqlcode rollback

prompt TEST ERROR_SAVE_STACK

prompt - compile package spec
create or replace package some_api is
  procedure do_stuff;
end;
{{/}}

prompt - compile package body
create or replace package body some_api is
------------------------------------------------------------------------------
    procedure do_stuff is
    --------------------------------------
        procedure sub1 is
        --------------------------------------
            procedure sub2 is
            --------------------------------------
                procedure sub3 is
                begin
                  console.assert(1 = 2, 'Demo');
                exception --sub3
                  when others then
                    console.error_save_stack;
                    raise;
                end;
            --------------------------------------
            begin
              sub3;
            exception --sub2
              when others then
                console.error_save_stack;
                raise;
            end;
        --------------------------------------
        begin
          sub2;
        exception --sub1
          when others then
            console.error_save_stack;
            raise no_data_found;
        end;
    --------------------------------------
    begin
      sub1;
    exception --do_stuff
      when others then
        console.error;
        raise;
    end;
------------------------------------------------------------------------------
end;
{{/}}

prompt - call the package
begin
  some_api.do_stuff;
exception
  when others then
    null; --> I know, I know, never do that without a final raise...
          --> But we want only test our logging without killing the script run...
end;
{{/}}

prompt - FINISHED, selecting now the call stack from the last log entry...

select call_stack from console_logs order by log_id desc fetch first row only;
```

EXAMPLE OUTPUT

```bash
TEST ERROR_SAVE_STACK
- compile package spec
- compile package body
- call the package
- FINISHED, selecting now the call stack from the last log entry...

Call Stack
------------------------------------------------------------------------------------------------------------------------
{{#}}# Saved Error Stack

- PLAYGROUND_DATA.SOME_API.DO_STUFF.SUB1.SUB2.SUB3, line 14 (line 11, ORA-20777 Assertion failed: Demo)
- PLAYGROUND_DATA.SOME_API.DO_STUFF.SUB1.SUB2, line 22 (line 19)
- PLAYGROUND_DATA.SOME_API.DO_STUFF.SUB1, line 30 (line 27)
- PLAYGROUND_DATA.SOME_API.DO_STUFF, line 38 (line 35, ORA-01403 no data found)

{{#}}# Call Stack

- PLAYGROUND_DATA.SOME_API.DO_STUFF, line 38
- __anonymous_block, line 2

{{#}}# Error Stack

- ORA-01403 no data found
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 31
- ORA-20777 Assertion failed: Test assertion with line break.
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 23
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 15
- ORA-06512 at "PLAYGROUND_DATA.CONSOLE", line 750
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 11
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 19
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 27

{{#}}# Error Backtrace

- PLAYGROUND_DATA.SOME_API, line 31
- PLAYGROUND_DATA.SOME_API, line 23
- PLAYGROUND_DATA.SOME_API, line 15
- PLAYGROUND_DATA.CONSOLE, line 750
- PLAYGROUND_DATA.SOME_API, line 11
- PLAYGROUND_DATA.SOME_API, line 19
- PLAYGROUND_DATA.SOME_API, line 27
- PLAYGROUND_DATA.SOME_API, line 35
```

**/

--------------------------------------------------------------------------------

procedure error (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  );
/**

Log a message with the level 1 (error).

**/

function error (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 1 (error). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure warn (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  );
/**

Log a message with the level 2 (warning).

**/

function warn (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 2 (warning). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure info (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  );
/**

Log a message with the level 3 (info).

**/

function info (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 3 (info). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure log(
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  );
/**

Log a message with the level 3 (info).

**/

function log(
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 3 (info). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure debug (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  );
/**

Log a message with the level 4 (debug).

**/

function debug (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 4 (debug). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure trace (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default true  ,
  p_apex_env        boolean  default true  ,
  p_cgi_env         boolean  default true  ,
  p_console_env     boolean  default true  ,
  p_user_env        boolean  default true  ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  );
/**

Log a message with the level 5 (trace).

**/

function trace (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default true  ,
  p_apex_env        boolean  default true  ,
  p_cgi_env         boolean  default true  ,
  p_console_env     boolean  default true  ,
  p_user_env        boolean  default true  ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 5 (trace). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure count ( p_label varchar2 default null );
/**

Starts a new counter with a value of one or adds one to an existent counter.

Call `console.count_end('yourLabel')` to stop the counter and get or log the count
value.

**/

procedure count_log ( p_label varchar2 default null );
/**

Logs a counter, if current log level >= 3 (info).

Can be called multiple times - use `console.count_end` to stop a counter and get or
log the counter value.

**/

procedure count_end ( p_label varchar2 default null );
/**

Stops a counter and logs the result, if current log level >= 3 (info).

EXAMPLE

```sql
--Set your own session in logging mode (defaults: level 3=info for the next 60 minutes).
exec console.init;

begin
  --Do your stuff here.
  for i in 1 .. 1000 loop
    if mod(i, 3) = 0 then
      console.count('myLabel');
    end if;
  end loop;

  --Log your count value.
  console.count_end('myLabel');
end;
{{/}}

--Stop logging mode of your own session.
exec console.exit;
```

**/

function count_end ( p_label varchar2 default null ) return varchar2;
/**

Stops a counter and returns the result.

Does not depend on a log level, can be used anywhere to count things.

EXAMPLE

```sql
set serveroutput on

declare
  v_my_label constant varchar2(20) := 'My label: ';
begin
  --do your stuff here
  for i in 1 .. 1000 loop
    if mod(i, 3) = 0 then
      console.count(v_my_label);
    end if;
  end loop;

  --Return your count value.
  dbms_output.put_line(v_my_label || console.count_end(v_my_label) );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure time ( p_label varchar2 default null );
/**

Starts a new timer.

Call `console.time_end('yourLabel')` to stop the timer and get or log the elapsed
time.

**/

procedure time_log ( p_label varchar2 default null );
/**

Logs the elapsed time, if current log level >= 3 (info).

Can be called multiple times - use `console.time_end` to stop a timer and get or
log the elapsed time.

EXAMPLE

```sql
--Set you own session in logging mode with the defaults: level 3(info) for the next 60 minutes.
exec console.init;

begin
  console.time('myLabel');

  --Do your stuff here.
  for i in 1 .. 100000 loop
    null;
  end loop;

  --Log the elapsed time.
  console.time_log('myLabel');

  --Do other things.
  --Your code here...

  --Log the elapsed time.
  console.time_log('myLabel');

end;
{{/}}

--Stop logging mode of your own session.
exec console.exit;
```

**/

procedure time_end ( p_label varchar2 default null );
/**

Stops a timer and logs the result, if current log level >= 3 (info).

EXAMPLE

```sql
--Set you own session in logging mode with the defaults: level 3(info) for the next 60 minutes.
exec console.init;

begin
  console.time('myLabel');

  --Do your stuff here.
  for i in 1 .. 100000 loop
    null;
  end loop;

  --Log the time.
  console.time_end('myLabel');
end;
{{/}}

--Stop logging mode of your own session.
exec console.exit;
```

**/

function time_end ( p_label varchar2 default null ) return varchar2;
/**

Stops a timer and returns the result.

Does not depend on a log level, can be used anywhere to measure runtime.

EXAMPLE

```sql
set serveroutput on

declare
  v_my_label constant varchar2(20) := 'My label: ';
begin
  console.time(v_my_label);

  --do your stuff here
  for i in 1 .. 100000 loop
    null;
  end loop;

  --Return the runtime.
  dbms_output.put_line(v_my_label || console.time_end(v_my_label) );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------
procedure table# (
  p_data_cursor       sys_refcursor         ,
  p_comment           varchar2 default null ,
  p_include_row_num   boolean  default true ,
  p_max_rows          integer  default 100  ,
  p_max_column_length integer  default 1000 );
/**

Logs a cursor as a HTML table with the level 3 (info).

Using a cursor for the table method is very flexible, but opening a cursor can
produce unnecessary work for your system when you are not in the log level info.
Therefore please check your current log level before you open the cursor.

EXAMPLE

```sql
declare
  v_dataset sys_refcursor;
begin
  -- Your business logic here...

  -- Debug code
  if console.level_is_info then
    open v_dataset for
      select table_name,
             tablespace_name,
             logging,
             num_rows,
             last_analyzed,
             partitioned,
             has_identity
        from user_tables;
    console.table#(v_dataset);
  end if;

  -- Your business logic here...
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure assert (
  p_expression boolean,
  p_message    varchar2
);
/**

If the given expression evaluates to false, an error is raised with the given
message.

EXAMPLE

```sql
declare
  x number := 5;
  y number := 3;
begin
  console.assert(
    x < y,
    'X should be less then Y (x=' || to_char(x) || ', y=' || to_char(y) || ')'
  );
exception
  when others then
    console.error;
    raise;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function format (
  p_message in varchar2              ,
  p0        in varchar2 default null ,
  p1        in varchar2 default null ,
  p2        in varchar2 default null ,
  p3        in varchar2 default null ,
  p4        in varchar2 default null ,
  p5        in varchar2 default null ,
  p6        in varchar2 default null ,
  p7        in varchar2 default null ,
  p8        in varchar2 default null ,
  p9        in varchar2 default null )
return varchar2;
/**

Formats a message after the following rules:

1. Replace all occurrences of `%0` .. `%9` by id with the corresponding
   parameters `p0` .. `p9`
2. Replace `%n` with new lines (line feed character)
3. Replace all occurrences of `%s` in positional order with the corresponding
   parameters using sys.utl_lms.format_message - also see the [Oracle
   docs](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/UTL_LMS.html#GUID-88FFBFB6-FCA4-4951-884B-B0275BD5DF44).

**/

--------------------------------------------------------------------------------

procedure action ( p_action varchar2 );
/**

An alias for dbms_application_info.set_action.

Use the given action to set the session action attribute (in memory operation,
does not log anything). This attribute is then visible in the system session
views, the user environment and will be logged within all console logging
methods.

When you set the action attribute with `console.action` you should also reset it
when you have finished your work to prevent wrong info in the system and your
logging for subsequent method calls.

EXAMPLE

```sql
begin
  console.action('My process/task');
  -- do your stuff here...
  console.action(null);
exception
  when others then
    console.error('something went wrong');
    console.action(null);
    raise;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure module (
  p_module varchar2,
  p_action varchar2 default null
);
/**

An alias for dbms_application_info.set_module.

Use the given module and action to set the session module and action attributes
(in memory operation, does not log anything). These attributes are then visible
in the system session views, the user environment and will be logged within all
console logging methods.

Please note that your app framework may set the module and you should consider
to only set the action attribute with the `action` (see below).

**/

--------------------------------------------------------------------------------

function level_error     return integer; /** Returns the number code for the level 1 error.     **/
function level_warning   return integer; /** Returns the number code for the level 2 warning.   **/
function level_info      return integer; /** Returns the number code for the level 3 info.      **/
function level_debug     return integer; /** Returns the number code for the level 4 debug.     **/
function level_trace     return integer; /** Returns the number code for the level 5 trace.     **/

function level_is_warning return boolean; /** Returns true when the level is greater than or equal warning, otherwise false. **/
function level_is_info    return boolean; /** Returns true when the level is greater than or equal info, otherwise false.    **/
function level_is_debug   return boolean; /** Returns true when the level is greater than or equal debug, otherwise false.   **/
function level_is_trace   return boolean; /** Returns true when the level is greater than or equal trace, otherwise false.   **/

function level_is_warning_yn return varchar2; /** Returns 'Y' when the level is greater than or equal warning, otherwise 'N'. **/
function level_is_info_yn    return varchar2; /** Returns 'Y' when the level is greater than or equal info, otherwise 'N'.    **/
function level_is_debug_yn   return varchar2; /** Returns 'Y' when the level is greater than or equal debug, otherwise 'N'.   **/
function level_is_trace_yn   return varchar2; /** Returns 'Y' when the level is greater than or equal trace, otherwise 'N'.   **/


--------------------------------------------------------------------------------
-- PUBLIC HELPER METHODS
--------------------------------------------------------------------------------

$if $$apex_installed $then

function apex_error_handling ( p_error in apex_error.t_error )
return apex_error.t_error_result;
/**

You can register this example APEX error handler function to log APEX internal
errors.

To do so go into the Application Builder into your app > Edit Application
Properties > Error Handling > Error Handling Function. You can then provide here
`console.apex_error_handling`.

For more info see the [official
docs](https://docs.oracle.com/en/database/oracle/application-express/20.2/aeapi/Example-of-an-Error-Handling-Function.html#GUID-2CD75881-1A59-4787-B04B-9AAEC14E1A82).

The implementation code (see package body) is taken from the docs and aligned
for CONSOLE as a starting point. If this does not fit your needs then simply
reimplement an own function and use that instead.

**/

function apex_plugin_render (
  p_dynamic_action  in  apex_plugin.t_dynamic_action ,
  p_plugin          in  apex_plugin.t_plugin         )
return apex_plugin.t_dynamic_action_render_result;
/**

Used for the APEX plugin to capture frontend JavaScript errors.

If you plan to use the plugin make sure you have either console installed in
your APEX parsing schema or a synonym named `console` for it as this function is
referenced in the plug-in as a callback to `console.apex_plugin_render`.

**/
function apex_plugin_ajax (
  p_dynamic_action  in  apex_plugin.t_dynamic_action ,
  p_plugin          in  apex_plugin.t_plugin         )
return apex_plugin.t_dynamic_action_ajax_result;
/**

Used for the APEX plugin to capture frontend JavaScript errors.

If you plan to use the plugin make sure you have either console installed in
your APEX parsing schema or a synonym named `console` for it as this function is
referenced in the plug-in as a callback to `console.apex_plugin_ajax`.

**/

$end

--------------------------------------------------------------------------------

procedure conf (
  p_level               integer default c_level_error , -- Level 1 (error), 2 (warning) or 3 (info).
  p_check_interval      integer default 10            , -- The number of seconds a session looks for a changed configuration. Allowed values: 1 to 60 seconds.
  p_units_level_warning varchar2 default null         , -- A comma separated list of units names which should have log level warning. Example: p_units_level_warning => 'OWNER.UNIT,SCHEMA2.PACKAGE3'
  p_units_level_info    varchar2 default null         , -- Same as p_units_level_warning for level info.
  p_units_level_debug   varchar2 default null         , -- Same as p_units_level_warning for level debug.
  p_units_level_trace   varchar2 default null           -- Same as p_units_level_warning for level trace.
);
/**

Set the global console configuration.

EXAMPLE

```sql
--set all sessions to level warning
exec console.conf(p_level => console.c_level_warning);

--set all session to level info and two new packages to debug
begin
  console.conf(
    p_level             => console.c_level_info,
    p_check_interval    => 10,
    p_units_level_debug => 'MY_SCHEMA.SOME_API,MY_SCHEMA.ANOTHER_API'
  );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure init (
  p_client_identifier varchar2                      , -- The client identifier provided by the application or console itself.
  p_level             integer  default c_level_info , -- Level 2 (warning), 3 (info), 4 (debug) or 5 (trace).
  p_duration          integer  default 60           , -- The number of minutes the session should be in logging mode. Allowed values: 1 to 1440 minutes (24 hours).
  p_cache_size        integer  default 0            , -- The number of log entries to cache before they are written down into the log table. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shared environments like APEX. Allowed values: 0 to 1000 records.
  p_check_interval    integer  default 10           , -- The number of seconds a session looks for a changed configuration. Allowed values: 1 to 60 seconds.
  p_call_stack        boolean  default false        , -- Should the call stack be included.
  p_user_env          boolean  default false        , -- Should the user environment be included.
  p_apex_env          boolean  default false        , -- Should the APEX environment be included.
  p_cgi_env           boolean  default false        , -- Should the CGI environment be included.
  p_console_env       boolean  default false          -- Should the console environment be included.
);
/**

Starts the logging for a specific session.

To avoid spoiling the context with very long input the p_client_identifier parameter is
truncated after 64 characters before using it.

For easier usage there is an overloaded procedure available which uses always
your own client identifier.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING LOGGING MODES OF SESSIONS.

EXAMPLES

```sql
-- Dive into your own session with the default level of 3 (info) and the
-- default duration of 60 (minutes).
exec console.init;

-- With level 4 (debug) for the next 15 minutes.
exec console.init(4, 15);

-- Using a constant for the level
exec console.init(console.c_level_debug, 90);

-- Debug an APEX session...
exec console.init('OGOBRECHT:8805903776765', 4, 90);

-- ...with named parameters
begin
  console.init(
    p_client_identifier => 'OGOBRECHT:8805903776765',
    p_level             => console.c_level_debug,
    p_duration          => 15
  );
end;
{{/}}
```

**/

procedure init (
  p_level          integer default c_level_info , -- Level 2 (warning), 3 (info), 4 (debug) or 5 (trace).
  p_duration       integer default 60           , -- The number of minutes the session should be in logging mode. Allowed values: 1 to 1440 minutes (24 hours).
  p_cache_size     integer default 0            , -- The number of log entries to cache before they are written down into the log table. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shared environments like APEX. Allowed values: 0 to 1000 records.
  p_check_interval integer default 10           , -- The number of seconds a session in logging mode looks for a changed configuration. Allowed values: 1 to 60 seconds.
  p_call_stack     boolean default false        , -- Should the call stack be included.
  p_user_env       boolean default false        , -- Should the user environment be included.
  p_apex_env       boolean default false        , -- Should the APEX environment be included.
  p_cgi_env        boolean default false        , -- Should the CGI environment be included.
  p_console_env    boolean default false          -- Should the console environment be included.
);
/**
An overloaded procedure for easier initialization of the own session in an development IDE.
**/

procedure exit (
  p_client_identifier varchar2 default my_client_identifier -- The client identifier provided by the application or console itself.
);
/**

Stops the logging for a specific session.

If you stop your own session then this has an immediate effect as we can clear
the configuration cache in our package. If you stop another session then it can
take some seconds until the other session is reloading the cached configuration
from the context (if available) or the sessions table. The default cache
duration is ten seconds.

Stopping the logging mode means also the cached log entries will be flushed to
the logging table CONSOLE_LOGS. If you do not need the cached entries you can
delete them in advance by calling the `clear` procedure.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING LOGGING MODES OF SESSIONS.

**/

procedure exit_stale;
/**

Stops the logging for all sessions in the table console_sessions which have a
exit date older than one hour.

This procedure is used by the cleanup job (job name is CONSOLE_CLEANUP) which
runs per default at 1 o'clock after midnight.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING LOGGING MODES OF SESSIONS.

**/

--------------------------------------------------------------------------------

function context_is_available return boolean;
/**

Checks the availability of the global context. Returns true, if available and
false if not.

```sql
begin
  if not console.context_is_available then
    dbms_output.put_line('I need to speak with my DBA :-(');
  end if;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function context_is_available_yn return varchar2;
/**

Checks the availability of the global context. Returns `Y`, if available and `N`
if not.

```sql
select case when console.context_is_available_yn = 'N'
         then 'I need to speak with my DBA :-('
         else 'We have a global context :-)'
       end as "Test context availability"
  from dual;
```

**/


--------------------------------------------------------------------------------

function version return varchar2;
/**

Returns the version information from the console package.


```sql
select console.version from dual;
```

**/

--------------------------------------------------------------------------------

function to_yn ( p_bool boolean ) return varchar2;
/**

Converts a boolean value to a string.

Returns `Y` when the input is true and `N` if the input is false or null.

**/

--------------------------------------------------------------------------------

function to_bool ( p_string varchar2 ) return boolean;
/**

Converts a string to a boolean value.

Returns true when the uppercased, trimmed input is `Y`, `YES`, `1` or `TRUE`. In
all other cases (also on null) false is returned.

**/

--------------------------------------------------------------------------------

function to_html_table (
  p_data_cursor       sys_refcursor         ,
  p_comment           varchar2 default null ,
  p_include_row_num   boolean  default true ,
  p_max_rows          integer  default 100  ,
  p_max_column_length integer  default 1000 )
return clob;
/**

Helper to convert a cursor to a HTML table.

Note: As this helper is designed to work always it does not check your log
level. And if it would check, it would not help for the opening of the cursor,
which is done before. To save work for your database in cases you are not in
logging mode you should check the log level before open the cursor. Please see the
examples below.

EXAMPLES 1 - Open cursor in advance

```sql
declare
  v_dataset sys_refcursor;
begin
  -- Your business logic here.

  -- Debug code
  if console.level_is_info then
    open v_dataset for select * from user_tables;
    console.info(console.to_html_table(v_dataset));
  end if;
end;
{{/}}
```

EXAMPLES 2 - Open cursor in for loop

```sql
begin
  -- Your business logic here.

  -- Debug code
  if console.my_log_level >= console.c_level_info then
    for i in (
      select console.to_html_table(cursor(select * from user_tables)) as html
        from dual )
    loop
      console.info(i.html);
    end loop;
  end if;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function to_md_tab_header (
  p_key              varchar2 default 'Attribute' ,
  p_value            varchar2 default 'Value'     )
return varchar2;
/**

Converts the given key and value strings to a Markdown table header.

`to_md_tab_header` will return the following Markdown table header:

```md
| Attribute                      | Value                                       |
| ------------------------------ | ------------------------------------------- |
```

**/

function to_md_tab_data (
  p_key              varchar2               ,
  p_value            varchar2               ,
  p_value_max_length integer  default 1000  ,
  p_show_null_values boolean  default false )
return varchar2;
/**

Converts the given key and value strings to a Markdown table data row.

EXAMPLE

`to_md_tab_header('CLIENT_IDENTIFIER', '{o,o} 4C8E71DF0001')` will return the
following Markdown table row:

```md
| CLIENT_IDENTIFIER              | {o,o} 4C8E71DF0001                          |

```

**/

function to_unibar (
  p_value                   in  number,
  p_scale                   in  number default 1,
  p_width_block_characters  in  number default 25,
  p_fill_scale              in  number default 0
) return varchar2 deterministic;
/**

Returns a text bar consisting of unicode block characters.

You can build simple text based bar charts with it. Not all fonts implement
clean block characters, so the result depends a little bit on the font.

EXAMPLE

```sql
column textbar format a30

select 'Some text'       as description, 0.84 as value, console.to_unibar(0.84) as textbar from dual union all
select 'Some other text' as description, 0.75 as value, console.to_unibar(0.75) as textbar from dual union all
select 'Bla bla bla'     as description, 0.54 as value, console.to_unibar(0.54) as textbar from dual;
```

RESULT

```
DESCRIPTION          VALUE TEXTBAR
--------------- ---------- ------------------------------
Some text              .84 █████████████████████
Some other text        .75 ██████████████████▊
Bla bla bla            .54 █████████████▌
```

**/

--------------------------------------------------------------------------------

procedure print ( p_message in varchar2 );
/**

An alias for dbms_output.put_line.

Writing dbms_output.put_line is very annoying for me...

**/

--------------------------------------------------------------------------------

function  get_runtime ( p_start timestamp ) return varchar2;
/**

Returns a string in the format hh24:mi:ss.ff6 (for example 00:00:01.123456).

Is internally used by the `time_end` method and uses `localtimestamp` to compare
with `p_start`.

EXAMPLE

```sql
set serveroutput on
declare
  v_start timestamp := localtimestamp;
begin

  --do your stuff here

  dbms_output.put_line('Runtime: ' || console.get_runtime(v_start));
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function get_runtime_seconds ( p_start timestamp ) return number;
/**

Subtracts the start `localtimestamp` from the current `localtimestamp` and
returns the exracted seconds.

EXAMPLE

```sql
set serveroutput on
declare
  v_start timestamp := localtimestamp;
begin

  --do your stuff here

  dbms_output.put_line (
    'Runtime (seconds): ' || to_char(console.get_runtime_seconds(v_start)) );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function get_runtime_milliseconds ( p_start timestamp ) return number;
/**

Subtracts the start `localtimestamp` from the current `localtimestamp` and
returns the exracted milliseconds.

EXAMPLE

```sql
set serveroutput on
declare
  v_start timestamp := localtimestamp;
begin

  --do your stuff here

  dbms_output.put_line (
    'Runtime (milliseconds): ' || to_char(console.get_runtime_milliseconds(v_start)) );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function get_level_name (p_level integer) return varchar2 deterministic;
/**

Returns the level name for a given level id and null, if the level is not
between 0 and 4.

**/

--------------------------------------------------------------------------------

function get_scope return varchar2;
/**

Get the current scope (method, line number) from the call stack.

Is used internally by console to automatically provide the scope attribute for a
log entry.

**/

--------------------------------------------------------------------------------

function get_calling_unit return varchar2;
/**

Get the calling unit (OWNER.UNIT) from the call stack.

Is used internally by console to check if unit is configured for current log
level.

**/

--------------------------------------------------------------------------------

function get_call_stack return varchar2;
/**

Get the current call stack (and error stack/backtrace, if available).

Is used internally by console to provide the call stack for a log entry when
requested by one of the logging methods (which is the default for error and
trace).

**/

--------------------------------------------------------------------------------

function get_apex_env return clob;
/**

Get the current APEX environment.

Is used internally by console to provide the APEX environment for a log entry
when requested by one of the logging methods.

**/

--------------------------------------------------------------------------------

function get_cgi_env return varchar2;
/**

Get the current CGI environment.

Is used internally by console to provide the CGI environment for a log entry
when requested by one of the logging methods.

**/

--------------------------------------------------------------------------------

function get_user_env return varchar2;
/**

Get the current user environment.

Is used internally by console to provide the user environment for a log entry
when requested by one of the logging methods.

**/

--------------------------------------------------------------------------------

function get_console_env return varchar2;
/**

Get the current console environment.

Is used internally by console to provide the console environment for a log entry
when requested by one of the logging methods.

**/

--------------------------------------------------------------------------------
procedure clob_append (
  p_clob  in out nocopy clob     ,
  p_cache in out nocopy varchar2 ,
  p_text  in            varchar2 );
/**

High performance clob concatenation. Also see clob_flush_cache below.

Is used internally by console for the table method (and other things). Do not
forget a final flush cache call when you use it in your own code.

EXAMPLE

```sql
set serveroutput on feedback off
declare
  v_start  timestamp := localtimestamp;
  v_clob   clob;
  v_cache  varchar2(32767 char);
begin
  for i in 1..100000 loop
    console.clob_append(v_clob, v_cache, 'a');
  end loop;
  console.clob_flush_cache(v_clob, v_cache);
  dbms_output.put_line('Runtime (seconds): ' || to_char(console.get_runtime_seconds(v_start)));
  dbms_output.put_line('Lenght CLOB      : ' || length(v_clob));
end;
{{/}}
```

**/

procedure clob_append (
  p_clob  in out nocopy clob     ,
  p_cache in out nocopy varchar2 ,
  p_text  in            clob     );
/**

High performance clob concatenation.

Overloaded method for appending a clob. Also see clob_append above with p_text
beeing a varchar2 parameter and clob_flush_cache below.

**/

procedure clob_flush_cache (
  p_clob  in out nocopy clob     ,
  p_cache in out nocopy varchar2 );
/**

Flushes finally the cache in a high performance clob concatenation.

Also see clob_append above.

**/

--------------------------------------------------------------------------------

function view_cache return tab_logs pipelined;
/**

View the content of the log cache.

EXAMPLE

```sql
--init logging for own session
exec console.init(
  p_level          => c_level_debug ,
  p_duration       => 90            ,
  p_cache_size     => 1000          ,
  p_check_interval => 30            );

--test some business logic
begin
  --your code here;

  console.log('test', p_user_env => true);
end;
{{/}}

--check current cache entries
select * from console.view_cache();
```

**/

--------------------------------------------------------------------------------

procedure flush_cache;
/**

Flushes the log cache and writes down the entries to the log table.

Also see clob_append above.

**/

--------------------------------------------------------------------------------

procedure clear ( p_client_identifier varchar2 default my_client_identifier );
/**

Clears the cached log entries (if any).

This procedure is useful when you have initialized your own session with a cache
size greater then zero (for example 1000) and you take a look at the log entries
with the pipelined function `console.view_cache` or
`console.view_last([numRows])` during development. By clearing the cache you can
avoid spoiling your CONSOLE_LOGS table with entries you do not need anymore.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING LOGGING MODES OF SESSIONS.

**/

--------------------------------------------------------------------------------

function view_status return tab_key_value pipelined;
/**

View the current package status (config, number entries cache/timer/counter,
version etc.).

EXAMPLE

```sql
select * from console.view_status();
```

**/

--------------------------------------------------------------------------------
procedure purge (
  p_min_level integer default c_level_info, -- Delete log entries greater or equal the given level.
  p_min_days  number  default 30 );         -- Delete log entries older than the given minimum days.
/**

Deletes log entries for the given condition.

Deletion is only allowed for the owner of the package console.

EXAMPLES

```sql
--> default: all level info, debug and trace older than 30 days
exec console.purge;

--> all three examples are equivalent
exec console.purge(3, 0.25);
exec console.purge(console.c_level_info, 0.25);
exec console.purge(p_min_level => console.c_level_info, p_min_days => 0.25);
```

**/

procedure purge_all;
/**

Deletes all log entries except level permanent.

Deletion is only allowed for the owner of the package console.

EXAMPLE

```sql
exec console.purge_all;
```

**/

procedure cleanup_job_create (
  p_repeat_interval varchar2 default 'FREQ=DAILY;BYHOUR=1;' , -- See the Oracle docs: https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/scheduling-jobs-with-oracle-scheduler.html#GUID-10B1E444-8330-4EC9-85F8-9428D749F7D5
  p_min_level       integer  default c_level_info           , -- Delete log entries greater or equal the given level.
  p_min_days        number   default 30                       -- Delete log entries older than the given minimum days.
);
/**
Creates a cleanup job which deletes old log entries from console_logs and stale
debug sessions from console_sessions.
**/
procedure cleanup_job_drop;    /** Drops the cleanup job (if it exists).    **/
procedure cleanup_job_enable;  /** Enables the cleanup job (if it exists).  **/
procedure cleanup_job_disable; /** Disables the cleanup job (if it exists). **/
procedure cleanup_job_run;     /** Runs the cleanup job (if it exists).     **/

--------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS (only visible when ccflag `utils_public` is set to true)
--------------------------------------------------------------------------------

$if $$utils_public $then

function utl_escape_md_tab_text (p_text varchar2) return varchar2;
function utl_get_error return varchar2;
function utl_logging_is_enabled (p_level integer) return boolean;
function utl_normalize_label (p_label varchar2) return varchar2;
function utl_read_global_conf return console_conf%rowtype result_cache;
function utl_read_session_conf (p_client_identifier varchar2) return console_sessions%rowtype result_cache;
function utl_replace_linebreaks (p_text varchar2, p_replace_with varchar2 default ' ') return varchar2;
procedure utl_ctx_check_availability;
procedure utl_ctx_clear (p_client_identifier varchar2);
procedure utl_ctx_clear_all;
procedure utl_ctx_set (p_attribute varchar2, p_value varchar2, p_client_identifier varchar2);
procedure utl_load_session_configuration;
procedure utl_set_client_identifier;
--
function utl_create_log_entry (
  p_level           integer                ,
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type;

$end

end console;
/

prompt - Package CONSOLE (body)
create or replace package body console is

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS, TYPES, GLOBALS
--------------------------------------------------------------------------------

insufficient_privileges exception;
pragma exception_init (insufficient_privileges, -1031);

c_crlf                 constant varchar2 ( 2 byte) := chr(13) || chr(10);
c_cr                   constant varchar2 ( 1 byte) := chr(13);
c_lf                   constant varchar2 ( 1 byte) := chr(10);
c_lflf                 constant varchar2 ( 2 byte) := chr(10) || chr(10);
c_ampersand            constant varchar2 ( 1 byte) := chr(38);
c_html_ampersand       constant varchar2 ( 5 byte) := chr(38) || 'amp;';
c_html_less_then       constant varchar2 ( 4 byte) := chr(38) || 'lt;';
c_html_greater_then    constant varchar2 ( 4 byte) := chr(38) || 'gt;';
c_timestamp_format     constant varchar2 (25 byte) := 'yyyy-mm-dd hh24:mi:ss.ff6';
c_default_label        constant varchar2 ( 7 byte) := 'Default';
c_conf_id              constant varchar2 (11 byte) := 'GLOBAL_CONF';
c_client_id_prefix     constant varchar2 ( 6 byte) := '{o,o} ';
c_console_owner        constant varchar2 (30 byte) := user;
c_console_pkg_name_dot constant varchar2 ( 8 byte) := 'CONSOLE.';
c_console_job_name     constant varchar2 (15 byte) := 'CONSOLE_CLEANUP';
c_ctx_namespace        constant varchar2 (30 byte) := substr('CONSOLE_' || user, 1, 30);
c_ctx_test_attribute   constant varchar2 ( 4 byte) := 'TEST';
c_ctx_date_format      constant varchar2 (21 byte) := 'yyyy-mm-dd hh24:mi:ss';
c_ctx_exit_sysdate     constant varchar2 (12 byte) := 'EXIT_SYSDATE';
c_ctx_level            constant varchar2 ( 5 byte) := 'LEVEL';
c_ctx_cache_size       constant varchar2 (10 byte) := 'CACHE_SIZE';
c_ctx_check_interval   constant varchar2 (14 byte) := 'CHECK_INTERVAL';
c_ctx_call_stack       constant varchar2 (10 byte) := 'CALL_STACK';
c_ctx_user_env         constant varchar2 ( 8 byte) := 'USER_ENV';
c_ctx_apex_env         constant varchar2 ( 8 byte) := 'APEX_ENV';
c_ctx_cgi_env          constant varchar2 ( 7 byte) := 'CGI_ENV';
c_ctx_console_env      constant varchar2 (11 byte) := 'CONSOLE_ENV';

subtype t_vc32  is varchar2 (   32 byte);
subtype t_vc64  is varchar2 (   64 byte);
subtype t_vc128 is varchar2 (  128 byte);
subtype t_vc256 is varchar2 (  256 byte);
subtype t_vc1k  is varchar2 ( 1024 byte);
subtype t_vc4k  is varchar2 ( 4096 byte);
subtype t_vc32k is varchar2 (32767 byte);

-- numeric type identfiers
c_number                 constant pls_integer :=   2; -- float
c_binary_float           constant pls_integer := 100;
c_binary_double          constant pls_integer := 101;
-- string type identfiers
c_char                   constant pls_integer :=  96; -- nchar
c_varchar2               constant pls_integer :=   1; -- nvarchar2
c_long                   constant pls_integer :=   8;
c_clob                   constant pls_integer := 112; -- nclob
c_xmltype                constant pls_integer := 109; -- anydata, anydataset, anytype, object type, varray, nested table
c_rowid                  constant pls_integer :=  69;
c_urowid                 constant pls_integer := 208;
-- binary type identfiers
c_raw                    constant pls_integer :=  23;
c_long_raw               constant pls_integer :=  24;
c_blob                   constant pls_integer := 113;
c_bfile                  constant pls_integer := 114;
-- date type identfiers
c_date                   constant pls_integer :=  12;
c_timestamp              constant pls_integer := 180;
c_timestamp_tz           constant pls_integer := 181;
c_timestamp_ltz          constant pls_integer := 231;
-- interval type identfiers
c_interval_year_to_month constant pls_integer := 182;
c_interval_day_to_second constant pls_integer := 183;
-- cursor type identfiers
c_ref                    constant pls_integer := 111;
c_ref_cursor             constant pls_integer := 102; -- same identfiers for strong and weak ref cursor

type timers_tab      is table of timestamp   index by t_vc128;
type counters_tab    is table of pls_integer index by t_vc128;
type saved_stack_tab is table of t_vc1k      index by binary_integer;
type unit_list_tab   is table of t_vc4k      index by binary_integer;

g_timers         timers_tab;
g_counters       counters_tab;
g_log_cache      tab_logs := new tab_logs();
g_saved_stack    saved_stack_tab;
g_prev_error_msg t_vc1k;

g_conf_check_sysdate        date;
g_conf_exit_sysdate         date;
g_conf_context_is_available boolean;
g_conf_client_identifier    t_vc64;
g_conf_level                pls_integer;
g_conf_cache_size           integer;
g_conf_check_interval       integer;
g_conf_call_stack           boolean;
g_conf_user_env             boolean;
g_conf_apex_env             boolean;
g_conf_cgi_env              boolean;
g_conf_console_env          boolean;
g_conf_unit_levels          unit_list_tab;

-------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS (forward declarations)
--------------------------------------------------------------------------------

$if not $$utils_public $then

function utl_escape_md_tab_text (p_text varchar2) return varchar2;
function utl_get_error return varchar2;
function utl_logging_is_enabled (p_level integer) return boolean;
function utl_normalize_label (p_label varchar2) return varchar2;
function utl_read_global_conf return console_conf%rowtype result_cache;
function utl_read_session_conf (p_client_identifier varchar2) return console_sessions%rowtype result_cache;
function utl_replace_linebreaks (p_text varchar2, p_replace_with varchar2 default ' ') return varchar2;
procedure utl_ctx_check_availability;
procedure utl_ctx_clear (p_client_identifier varchar2);
procedure utl_ctx_clear_all;
procedure utl_ctx_set (p_attribute varchar2, p_value varchar2, p_client_identifier varchar2);
procedure utl_load_session_configuration;
procedure utl_set_client_identifier;
--
function utl_create_log_entry (
  p_level           integer                ,
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type;

$end

--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------

function my_client_identifier return varchar2 is
begin
  return g_conf_client_identifier;
end;

--------------------------------------------------------------------------------

function my_log_level return integer is
begin
  return g_conf_level;
end my_log_level;

--------------------------------------------------------------------------------

function view_last (p_log_rows integer default 100)
return tab_logs pipelined is
  v_count pls_integer := 0;
  v_left  pls_integer;
begin
  for i in reverse 1 .. g_log_cache.count loop
    exit when v_count > p_log_rows;
    pipe row(g_log_cache(i));
    v_count := v_count + 1;
  end loop;
  if v_count < p_log_rows then
    v_left := p_log_rows - v_count;
    for i in (select * from console_logs
              order by log_systime desc
              fetch first v_left rows only)
    loop
          pipe row(i);
    end loop;
  end if;
end view_last;

--------------------------------------------------------------------------------

procedure error_save_stack is
begin
  g_saved_stack(g_saved_stack.count + 1) := substrb(get_scope || utl_get_error, 1, 1024);
end error_save_stack;

--------------------------------------------------------------------------------

procedure error (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
  v_log_id console_logs.log_id%type;
begin
  v_log_id := utl_create_log_entry (
    p_level           => c_level_error     ,
    p_message         => p_message         ,
    p_permanent       => p_permanent       ,
    p_call_stack      => p_call_stack      ,
    p_apex_env        => p_apex_env        ,
    p_cgi_env         => p_cgi_env         ,
    p_console_env     => p_console_env     ,
    p_user_env        => p_user_env        ,
    p_user_agent      => p_user_agent      ,
    p_user_scope      => p_user_scope      ,
    p_user_error_code => p_user_error_code ,
    p_user_call_stack => p_user_call_stack );
end error;

function error (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type
is
  v_log_id console_logs.log_id%type;
begin
  v_log_id := utl_create_log_entry (
    p_level           => c_level_error     ,
    p_message         => p_message         ,
    p_permanent       => p_permanent       ,
    p_call_stack      => p_call_stack      ,
    p_apex_env        => p_apex_env        ,
    p_cgi_env         => p_cgi_env         ,
    p_console_env     => p_console_env     ,
    p_user_env        => p_user_env        ,
    p_user_agent      => p_user_agent      ,
    p_user_scope      => p_user_scope      ,
    p_user_error_code => p_user_error_code ,
    p_user_call_stack => p_user_call_stack );
  return v_log_id;
end error;

--------------------------------------------------------------------------------

procedure warn (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
  v_log_id console_logs.log_id%type;
begin
  if utl_logging_is_enabled (c_level_warning) then
    v_log_id := utl_create_log_entry (
      p_level           => c_level_warning   ,
      p_message         => p_message         ,
      p_permanent       => p_permanent       ,
      p_call_stack      => p_call_stack      ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
end warn;

function warn (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type
is
  v_log_id console_logs.log_id%type;
begin
  if utl_logging_is_enabled (c_level_warning) then
    v_log_id := utl_create_log_entry (
      p_level           => c_level_warning   ,
      p_message         => p_message         ,
      p_permanent       => p_permanent       ,
      p_call_stack      => p_call_stack      ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
  return v_log_id;
end warn;

--------------------------------------------------------------------------------

procedure info (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
  v_log_id console_logs.log_id%type;
begin
  if utl_logging_is_enabled (c_level_info) then
    v_log_id := utl_create_log_entry (
      p_level           => c_level_info      ,
      p_message         => p_message         ,
      p_permanent       => p_permanent       ,
      p_call_stack      => p_call_stack      ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
end info;

function info (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type
is
  v_log_id console_logs.log_id%type;
begin
  if utl_logging_is_enabled (c_level_info) then
    v_log_id := utl_create_log_entry (
      p_level           => c_level_info      ,
      p_message         => p_message         ,
      p_permanent       => p_permanent       ,
      p_call_stack      => p_call_stack      ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
  return v_log_id;
end info;

--------------------------------------------------------------------------------

procedure log (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
  v_log_id console_logs.log_id%type;
begin
  if utl_logging_is_enabled (c_level_info) then
    v_log_id := utl_create_log_entry (
      p_level           => c_level_info    ,
      p_message         => p_message         ,
      p_permanent       => p_permanent       ,
      p_call_stack      => p_call_stack      ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
end log;

function log (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type
is
  v_log_id console_logs.log_id%type;
begin
  if utl_logging_is_enabled (c_level_info) then
    v_log_id := utl_create_log_entry (
      p_level           => c_level_info    ,
      p_message         => p_message         ,
      p_permanent       => p_permanent       ,
      p_call_stack      => p_call_stack      ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
  return v_log_id;
end log;

--------------------------------------------------------------------------------

procedure debug (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
  v_log_id console_logs.log_id%type;
begin
  if utl_logging_is_enabled (c_level_debug) then
    v_log_id := utl_create_log_entry (
      p_level           => c_level_debug     ,
      p_message         => p_message         ,
      p_permanent       => p_permanent       ,
      p_call_stack      => p_call_stack      ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
end debug;

function debug (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type
is
  v_log_id console_logs.log_id%type;
begin
  if utl_logging_is_enabled (c_level_debug) then
    v_log_id := utl_create_log_entry (
      p_level           => c_level_debug     ,
      p_message         => p_message         ,
      p_permanent       => p_permanent       ,
      p_call_stack      => p_call_stack      ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
  return v_log_id;
end debug;

--------------------------------------------------------------------------------

procedure trace (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default true  ,
  p_apex_env        boolean  default true  ,
  p_cgi_env         boolean  default true  ,
  p_console_env     boolean  default true  ,
  p_user_env        boolean  default true  ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
  v_log_id console_logs.log_id%type;
begin
  if utl_logging_is_enabled (c_level_trace) then
    v_log_id := utl_create_log_entry (
      p_level           => c_level_trace     ,
      p_message         => p_message         ,
      p_permanent       => p_permanent       ,
      p_call_stack      => p_call_stack      ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
end trace;

function trace (
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default true  ,
  p_apex_env        boolean  default true  ,
  p_cgi_env         boolean  default true  ,
  p_console_env     boolean  default true  ,
  p_user_env        boolean  default true  ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type
is
  v_log_id console_logs.log_id%type;
begin
  if utl_logging_is_enabled (c_level_trace) then
    v_log_id := utl_create_log_entry (
      p_level           => c_level_trace     ,
      p_message         => p_message         ,
      p_permanent       => p_permanent       ,
      p_call_stack      => p_call_stack      ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
  return v_log_id;
end trace;

--------------------------------------------------------------------------------

procedure count (
  p_label varchar2 default null )
is
  v_label t_vc128;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    g_counters(v_label) := g_counters(v_label) + 1;
  else
    g_counters(v_label) := 1;
  end if;
end count;

procedure count_log (
  p_label  varchar2 default null )
is
  v_label  t_vc128;
  v_log_id console_logs.log_id%type;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    if utl_logging_is_enabled (c_level_info) then
      v_log_id := utl_create_log_entry (
        p_level   => c_level_info,
        p_message => v_label || ': ' || to_char(g_counters(v_label)) );
    end if;
  else
    warn('Counter `' || v_label || '` does not exist.');
  end if;
end count_log;

procedure count_end (
  p_label  varchar2 default null )
is
  v_label  t_vc128;
  v_log_id console_logs.log_id%type;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    if utl_logging_is_enabled (c_level_info) then
      v_log_id := utl_create_log_entry (
        p_level   => c_level_info,
        p_message => v_label || ': ' || to_char(g_counters(v_label)) || ' - counter ended');
    end if;
    g_counters.delete(v_label);
  else
    warn('Counter `' || v_label || '` does not exist.');
  end if;
end count_end;

function count_end (
  p_label varchar2 default null )
return varchar2
is
  v_label  t_vc128;
  v_return t_vc64;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    v_return := to_char(g_counters(v_label));
    g_counters.delete(v_label);
  else
    v_return := 'Counter `' || v_label || '` does not exist.';
  end if;
  return v_return;
end count_end;

--------------------------------------------------------------------------------

procedure time (
  p_label varchar2 default null )
is
begin
  g_timers(utl_normalize_label(p_label)) := localtimestamp;
end time;

procedure time_log (
  p_label varchar2 default null )
is
  v_label  t_vc128;
  v_log_id console_logs.log_id%type;
begin
  v_label := utl_normalize_label(p_label);
  if g_timers.exists(v_label) then
    if utl_logging_is_enabled (c_level_info) then
      v_log_id := utl_create_log_entry (
        p_level   => c_level_info,
        p_message => v_label || ': ' || get_runtime (g_timers(v_label)) );
    end if;
  else
    warn('Timer `' || v_label || '` does not exist.');
  end if;
end time_log;

procedure time_end (
  p_label varchar2 default null )
is
  v_label  t_vc128;
  v_log_id console_logs.log_id%type;
begin
  v_label := utl_normalize_label(p_label);
  if g_timers.exists(v_label) then
    if utl_logging_is_enabled (c_level_info) then
      v_log_id := utl_create_log_entry (
        p_level   => c_level_info,
        p_message => v_label || ': ' || get_runtime (g_timers(v_label)) || ' - timer ended' );
    end if;
    g_timers.delete(v_label);
  else
    warn('Timer `' || v_label || '` does not exist.');
  end if;
end time_end;

function time_end (
  p_label varchar2 default null )
return varchar2
is
  v_label  t_vc128;
  v_return t_vc64;
begin
  v_label := utl_normalize_label(p_label);
  if g_timers.exists(v_label) then
    v_return :=  get_runtime(g_timers(v_label));
    g_timers.delete(v_label);
  else
    v_return := 'Timer `' || v_label || '` does not exist.';
  end if;
  return v_return;
end time_end;

--------------------------------------------------------------------------------

procedure table# (
  p_data_cursor       sys_refcursor         ,
  p_comment           varchar2 default null ,
  p_include_row_num   boolean  default true ,
  p_max_rows          integer  default 100  ,
  p_max_column_length integer  default 1000 )
is
  v_log_id console_logs.log_id%type;
begin
  if utl_logging_is_enabled (c_level_info) then
    v_log_id := utl_create_log_entry (
      p_level   => c_level_info,
      p_message => to_html_table (
        p_data_cursor       => p_data_cursor       ,
        p_comment           => p_comment           ,
        p_include_row_num   => p_include_row_num   ,
        p_max_rows          => p_max_rows          ,
        p_max_column_length => p_max_column_length ) );
  end if;
end table#;

--------------------------------------------------------------------------------

procedure assert (
  p_expression boolean  ,
  p_message    varchar2 )
is
begin
  if not p_expression then
    raise_application_error(-20777, 'Assertion failed: ' || p_message, true);
  end if;
end assert;

--------------------------------------------------------------------------------

function format (
  p_message in varchar2              ,
  p0        in varchar2 default null ,
  p1        in varchar2 default null ,
  p2        in varchar2 default null ,
  p3        in varchar2 default null ,
  p4        in varchar2 default null ,
  p5        in varchar2 default null ,
  p6        in varchar2 default null ,
  p7        in varchar2 default null ,
  p8        in varchar2 default null ,
  p9        in varchar2 default null )
return varchar2 is
  v_message t_vc32k := p_message;
begin
  -- id replacements
  v_message := replace(v_message, '%0', p0);
  v_message := replace(v_message, '%1', p1);
  v_message := replace(v_message, '%2', p2);
  v_message := replace(v_message, '%3', p3);
  v_message := replace(v_message, '%4', p4);
  v_message := replace(v_message, '%5', p5);
  v_message := replace(v_message, '%6', p6);
  v_message := replace(v_message, '%7', p7);
  v_message := replace(v_message, '%8', p8);
  v_message := replace(v_message, '%9', p9);

  -- new line
  v_message := replace(v_message, '%n', c_lf);

  -- positional replacements
  return sys.utl_lms.format_message(v_message, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9);
end format;

--------------------------------------------------------------------------------

procedure action (
  p_action varchar2 )
is
begin
  dbms_application_info.set_action (
    p_action );
end action;

--------------------------------------------------------------------------------

procedure module (
  p_module varchar2,
  p_action varchar2 default null
)
is
begin
  dbms_application_info.set_module(
    p_module ,
    p_action );
end module;

--------------------------------------------------------------------------------

function level_error   return integer is begin return c_level_error  ; end;
function level_warning return integer is begin return c_level_warning; end;
function level_info    return integer is begin return c_level_info   ; end;
function level_debug   return integer is begin return c_level_debug  ; end;
function level_trace   return integer is begin return c_level_trace  ; end;

function level_is_warning return boolean is begin return utl_logging_is_enabled(c_level_warning); end;
function level_is_info    return boolean is begin return utl_logging_is_enabled(c_level_info   ); end;
function level_is_debug   return boolean is begin return utl_logging_is_enabled(c_level_debug  ); end;
function level_is_trace   return boolean is begin return utl_logging_is_enabled(c_level_trace  ); end;

function level_is_warning_yn return varchar2 is begin return to_yn(utl_logging_is_enabled(c_level_warning)); end;
function level_is_info_yn    return varchar2 is begin return to_yn(utl_logging_is_enabled(c_level_info   )); end;
function level_is_debug_yn   return varchar2 is begin return to_yn(utl_logging_is_enabled(c_level_debug  )); end;
function level_is_trace_yn   return varchar2 is begin return to_yn(utl_logging_is_enabled(c_level_trace  )); end;


--------------------------------------------------------------------------------
-- PUBLIC HELPER METHODS
--------------------------------------------------------------------------------

$if $$apex_installed $then

function apex_error_handling (
  p_error in apex_error.t_error )
return apex_error.t_error_result
is
  v_result          apex_error.t_error_result;
  v_reference_id    number;
  v_constraint_name t_vc256;
  v_message         clob;
  v_app_id          pls_integer;
  --
  function extract_constraint_name(p_sqlerrm varchar2) return varchar2 is
  begin
    return regexp_substr(p_sqlerrm, '\(\S+?\.(\S+?)\)', 1, 1, 'i', 1);
  end;
  --
  procedure create_apex_lang_message ( p_constraint_name varchar2 ) is
    pragma autonomous_transaction;
  begin
    apex_lang.create_message(
      p_application_id => v_app_id,
      p_name           => p_constraint_name,
      p_language       => apex_util.get_preference('FSP_LANGUAGE_PREFERENCE'),
      p_message_text   => 'DEVELOPER TODO: Change this message for constraint ' || p_constraint_name);
    commit;
  end;
  --
begin
  v_app_id := v('APP_ID');
  v_result := apex_error.init_error_result (p_error => p_error);

  -- If it's an internal error raised by APEX, like an invalid statement or
  -- code which can't be executed, the error text might contain security sensitive
  -- information. To avoid this security problem we can rewrite the error to
  -- a generic error message and log the original error message for further
  -- investigation by the help desk.
  if p_error.is_internal_error then
    -- mask all errors that are not common runtime errors (Access Denied
    -- errors raised by application / page authorization and all errors
    -- regarding session and session state)
    if not p_error.is_common_runtime_error then
      -- log error for example with an autonomous transaction and return
      -- v_reference_id as reference#
      v_message :=
        case when p_error.message is not null then p_error.message || c_lf end ||
        case when p_error.additional_info is not null then p_error.additional_info || c_lf end ||
        case when p_error.error_statement is not null then p_error.error_statement || c_lf end;
        --FIXME what about other attributes like p_error.component?
      v_reference_id := error (
        p_message         => v_message               ,
        p_call_stack      => false                   ,
        p_apex_env        => true                    ,
        p_user_error_code => p_error.ora_sqlcode     ,
        p_user_call_stack => p_error.error_backtrace );
      -- Change the message to the generic error message which doesn't expose
      -- any sensitive information.
      v_result.message :=
        $if $$apex_fun $then
        replace(replace(q'[<pre>

                \|||/
                (o o)
    ,-------ooO--(_)------------.
    | Ooops, there was an ERROR |
    | Application ID: #APP_ID## |
    | Log ID: #LOG_ID########## |
    '----------------Ooo--------'
               |__|__|
                || ||
               ooO Ooo

</pre>]', '#APP_ID##', rpad(v_app_id, 9, ' ')),
          '#LOG_ID##########', rpad(to_char(v_reference_id), 17, ' ')) ||
        $end
        'An unexpected internal application error has occurred. ' ||
        'Please get in contact with your Oracle APEX support team and provide ' ||
        '"Application ID ' || to_char(v_app_id) || '" and "Log ID ' ||
         to_char(v_reference_id) || '" for further investigation.';
      v_result.additional_info := null;
    end if;
  else
    -- Always show the error as inline error
    -- Note: If you have created manual tabular forms (using the package
    --       apex_item/htmldb_item in the SQL statement) you should still
    --       use "On error page" on that pages to avoid loosing entered data
    v_result.display_location :=
      case when v_result.display_location = apex_error.c_on_error_page
        then apex_error.c_inline_in_notification
        else v_result.display_location
      end;

    --
    -- Note: If you want to have friendlier ORA error messages, you can also define
    --       a text message with the name pattern APEX.ERROR.ORA-number
    --       There is no need to implement custom code for that.
    --

    -- If it's a constraint violation like
    --
    --   -) ORA-00001: unique constraint violated
    --   -) ORA-02091: transaction rolled back (-> can hide a deferred constraint)
    --   -) ORA-02290: check constraint violated
    --   -) ORA-02291: integrity constraint violated - parent key not found
    --   -) ORA-02292: integrity constraint violated - child record found
    --
    -- we try to get a friendly error message from our constraint lookup configuration.
    -- If we don't find the constraint in our lookup table we fallback to
    -- the original ORA error message.
    if p_error.ora_sqlcode in (-1, -2091, -2290, -2291, -2292) then
      v_constraint_name :=  extract_constraint_name(p_error.ora_sqlerrm);
      v_result.message := apex_lang.message( v_constraint_name );
      if v_result.message = v_constraint_name then
        --Idea by Roel Hartman: https://roelhartman.blogspot.com/2021/02/stop-using-validations-for-checking.html
        create_apex_lang_message (v_constraint_name);
      end if;
    end if;

    -- If an ORA error has been raised, for example a raise_application_error(-20xxx, '...')
    -- in a table trigger or in a PL/SQL package called by a process and we
    -- haven't found the error in our lookup table, then we just want to see
    -- the actual error text and not the full error stack with all the ORA error numbers.
    if p_error.ora_sqlcode is not null and v_result.message = p_error.message then
      v_result.message := apex_error.get_first_ora_error_text (p_error => p_error);
    end if;

    -- If no associated page item/tabular form column has been set, we can use
    -- apex_error.auto_set_associated_item to automatically guess the affected
    -- error field by examine the ORA error for constraint names or column names.
    if v_result.page_item_name is null and v_result.column_alias is null then
      apex_error.auto_set_associated_item (
        p_error        => p_error,
        p_error_result => v_result );
    end if;
  end if;

  return v_result;
end apex_error_handling;

--------------------------------------------------------------------------------

function apex_plugin_render (
  p_dynamic_action  in  apex_plugin.t_dynamic_action ,
  p_plugin          in  apex_plugin.t_plugin         )
return apex_plugin.t_dynamic_action_render_result is
  v_result apex_plugin.t_dynamic_action_render_result;
begin
  v_result.ajax_identifier := apex_plugin.get_ajax_identifier;

  if apex_application.g_debug then
    apex_plugin_util.debug_dynamic_action(
      p_plugin          => p_plugin         ,
      p_dynamic_action  => p_dynamic_action );
  end if;

  apex_javascript.add_library(
    p_name                   => 'console'            ,
    p_directory              => p_plugin.file_prefix ,
    p_check_to_add_minified  => true                 );

  apex_javascript.add_onload_code(
    'oic.pluginId         = '  || apex_javascript.add_value(apex_plugin.get_ajax_identifier, false) ||  ';' ||
    'oic.version          = "' || console.version                                                   || '";' ||
    'oic.clientIdentifier = "' || console.my_client_identifier                                      || '";' ||
    'oic.level            = '  || console.my_log_level                                              ||  ';' ||
    'oic.init();'    ,
    'COM.OGOBRECHT.CONSOLE' );

  v_result.javascript_function := 'function(){ null; }';

  return v_result;
end apex_plugin_render;

--------------------------------------------------------------------------------

function apex_plugin_ajax (
  p_dynamic_action  in  apex_plugin.t_dynamic_action ,
  p_plugin          in  apex_plugin.t_plugin         )
return apex_plugin.t_dynamic_action_ajax_result is
  v_result          apex_plugin.t_dynamic_action_ajax_result;
  v_level           pls_integer;
  v_message         t_vc32k;
  v_user_scope      t_vc32k;
  v_user_call_stack t_vc32k;
  v_user_agent      t_vc32k;
begin
  -- If we do not provide a value for p_user_scope and p_user_call_stack, then
  -- our console package provides per default the values from the PL/SQL
  -- environment. But this is useless for frontend messages from JavaScript.
  -- Therefore we set any null value for these two parmaters to a point.
  v_level           := to_number(apex_application.g_x01) ;
  v_message         := apex_application.g_x02            ;
  v_user_scope      := nvl(apex_application.g_x03, '.')  ;
  v_user_call_stack := nvl(apex_application.g_x04, '.')  ;
  v_user_agent      := apex_application.g_x05            ;
  case v_level
    when c_level_error then
      console.error(
        p_message         => v_message         ,
        p_user_scope      => v_user_scope      ,
        p_user_call_stack => v_user_call_stack ,
        p_user_agent      => v_user_agent      );
    when c_level_warning then
      console.warn (
        p_message         => v_message         ,
        p_user_scope      => v_user_scope      ,
        p_user_call_stack => v_user_call_stack ,
        p_user_agent      => v_user_agent      );
    when c_level_info then
      console.info (
        p_message         => v_message         ,
        p_user_scope      => v_user_scope      ,
        p_user_call_stack => v_user_call_stack ,
        p_user_agent      => v_user_agent      );
    when c_level_debug then
      console.debug(
        p_message         => v_message         ,
        p_user_scope      => v_user_scope      ,
        p_user_call_stack => v_user_call_stack ,
        p_user_agent      => v_user_agent      );
    when c_level_trace then
      console.trace(
        p_message         => v_message         ,
        p_user_scope      => v_user_scope      ,
        p_user_call_stack => v_user_call_stack ,
        p_user_agent      => v_user_agent      );
  else
    null;
  end case;

  htp.prn('SUCCESS');
  return v_result;
exception when others then
  htp.prn(sqlerrm);
  return v_result;
end apex_plugin_ajax;

$end

--------------------------------------------------------------------------------

procedure conf (
  p_level               integer  default c_level_error ,
  p_check_interval      integer  default 10            ,
  p_units_level_warning varchar2 default null          ,
  p_units_level_info    varchar2 default null          ,
  p_units_level_debug   varchar2 default null          ,
  p_units_level_trace   varchar2 default null          )
is
  pragma autonomous_transaction;
  v_old_conf console_conf%rowtype;
  v_conf     console_conf%rowtype;
  v_sep      varchar2(1 byte) := ',';
  --
  procedure add_unit_to_level (
    p_unit  varchar2    ,
    p_level pls_integer )
  is
  begin
    if p_level >= 2 then v_conf.units_level_warning := v_sep || p_unit; end if;
    if p_level >= 3 then v_conf.units_level_info    := v_sep || p_unit; end if;
    if p_level >= 4 then v_conf.units_level_debug   := v_sep || p_unit; end if;
    if p_level >= 5 then v_conf.units_level_trace   := v_sep || p_unit; end if;
  end add_unit_to_level;
  --
  procedure close_unit_levels is
  begin
    if v_conf.units_level_warning is not null then v_conf.units_level_warning := v_conf.units_level_warning || v_sep; end if;
    if v_conf.units_level_info    is not null then v_conf.units_level_info    := v_conf.units_level_info    || v_sep; end if;
    if v_conf.units_level_debug   is not null then v_conf.units_level_debug   := v_conf.units_level_debug   || v_sep; end if;
    if v_conf.units_level_trace   is not null then v_conf.units_level_trace   := v_conf.units_level_trace   || v_sep; end if;
  end close_unit_levels;
  --
  procedure normalize_units_and_levels (
    p_units varchar2    ,
    p_level pls_integer )
  is
    v_units t_vc32k;
    v_unit  t_vc32k;
    v_index pls_integer;
  begin
    if p_units is not null then
      v_units := p_units;
      loop
        v_index := instr(v_units, v_sep);
        if v_index > 0 then
          add_unit_to_level( trim(substr(v_units, 1, v_index - 1)), p_level );
          v_units := substr(v_units, v_index + 1);
        else
          add_unit_to_level( trim(v_units), p_level );
          exit;
        end if;
      end loop;
    end if;
  end normalize_units_and_levels;
  --
begin
  assert (
    p_level in (1, 2, 3),
    'Level needs to be 1 (error), 2 (warning) or 3 (info). ' ||
    'Levels 4 (debug) and 5 (trace) can only be set per session with the procedure init.');
  assert (
    c_console_owner = sys_context('USERENV','SESSION_USER'),
    'Setting of the global console configuration is only allowed for the owner of the console package.');
  assert (
    p_check_interval between 10 and 60,
    'Check interval needs to be between 10 and 60 (seconds). ' ||
    'Values between 1 and 10 seconds can only be set per session with the procedure init.');
  v_conf.conf_id        := c_conf_id;
  v_conf.conf_by        := substrb(
                            coalesce(sys_context('USERENV','OS_USER'), sys_context('USERENV','SESSION_USER')),
                            1,
                            64);
  v_conf.conf_sysdate   := sysdate;
  v_conf.level_id       := p_level;
  v_conf.level_name     := get_level_name(p_level);
  v_conf.check_interval := p_check_interval;
  normalize_units_and_levels (p_units_level_warning, 2);
  normalize_units_and_levels (p_units_level_info   , 3);
  normalize_units_and_levels (p_units_level_debug  , 4);
  normalize_units_and_levels (p_units_level_trace  , 5);
  close_unit_levels;
  --
  v_old_conf := utl_read_global_conf;
  --
  update console_conf set row = v_conf where conf_id = c_conf_id;
  if sql%rowcount = 0 then
    insert into console_conf values v_conf;
  end if;
  commit;
  --
  if nvl(v_old_conf.level_id, 1) != v_conf.level_id then
    utl_ctx_clear_all;
  end if;
end conf;

--------------------------------------------------------------------------------

procedure init (
  p_client_identifier varchar2                      ,
  p_level             integer  default c_level_info ,
  p_duration          integer  default 60           ,
  p_cache_size        integer  default 0            ,
  p_check_interval    integer  default 10           ,
  p_call_stack        boolean  default false        ,
  p_user_env          boolean  default false        ,
  p_apex_env          boolean  default false        ,
  p_cgi_env           boolean  default false        ,
  p_console_env       boolean  default false        )
is
  pragma autonomous_transaction;
  v_row console_sessions%rowtype;
  --
begin
  assert (
    p_level in (1, 2, 3, 4, 5),
    'Level needs to be 1 (error), 2 (warning), 3 (info), 4 (debug) or 5 (trace). ' ||
    'NOTE: Level 1 (error) will be always logged and needs no explicit call to the init method.' );
  assert ( p_client_identifier is not null        , 'Client identifier must not be null.'                      );
  assert ( p_duration          between 1 and 1440 , 'Duration needs to be between 1 and 1440 (minutes).'       );
  assert ( p_cache_size        between 0 and 1000 , 'Cache size needs to be between 1 and 1000 (log entries).' );
  assert ( p_check_interval    between 1 and   60 , 'Check interval needs to be between 1 and 60 (seconds).'   );
  assert ( p_call_stack        is not null        , 'Call stack needs to be true or false (not null).'         );
  assert ( p_user_env          is not null        , 'User env needs to be true or false (not null).'           );
  assert ( p_apex_env          is not null        , 'APEX env needs to be true or false (not null).'           );
  assert ( p_cgi_env           is not null        , 'CGI env needs to be true or false (not null).'            );
  assert ( p_console_env       is not null        , 'Console env needs to be true or false (not null).'        );
  --
  v_row.init_by           := substrb(coalesce(
                                sys_context('USERENV', 'OS_USER'),
                                sys_context('USERENV', 'SESSION_USER') ), 1, 64 );
  v_row.init_sysdate      := sysdate;
  v_row.exit_sysdate      := sysdate + 1/24/60 * p_duration;
  v_row.client_identifier := substrb ( p_client_identifier, 1, 64 );
  v_row.level_id          := p_level;
  v_row.level_name        := get_level_name(p_level);
  v_row.cache_size        := p_cache_size;
  v_row.check_interval    := p_check_interval;
  v_row.call_stack        := to_yn ( p_call_stack  );
  v_row.user_env          := to_yn ( p_user_env    );
  v_row.apex_env          := to_yn ( p_apex_env    );
  v_row.cgi_env           := to_yn ( p_cgi_env     );
  v_row.console_env       := to_yn ( p_console_env );
  --
  update console_sessions set row = v_row where client_identifier = v_row.client_identifier;
  if sql%rowcount = 0 then
    insert into console_sessions values v_row;
  end if;
  commit;
  --
  if g_conf_context_is_available then
    utl_ctx_set ( c_ctx_level          , to_char ( v_row.level_id                        ) , p_client_identifier );
    utl_ctx_set ( c_ctx_exit_sysdate   , to_char ( v_row.exit_sysdate, c_ctx_date_format ) , p_client_identifier );
    utl_ctx_set ( c_ctx_cache_size     , to_char ( v_row.cache_size                      ) , p_client_identifier );
    utl_ctx_set ( c_ctx_check_interval , to_char ( v_row.check_interval                  ) , p_client_identifier );
    utl_ctx_set ( c_ctx_call_stack     , to_char ( v_row.call_stack                      ) , p_client_identifier );
    utl_ctx_set ( c_ctx_user_env       , to_char ( v_row.user_env                        ) , p_client_identifier );
    utl_ctx_set ( c_ctx_apex_env       , to_char ( v_row.apex_env                        ) , p_client_identifier );
    utl_ctx_set ( c_ctx_cgi_env        , to_char ( v_row.cgi_env                         ) , p_client_identifier );
    utl_ctx_set ( c_ctx_console_env    , to_char ( v_row.console_env                     ) , p_client_identifier );
  end if;

  -- If we want to monitor our own session, wee need to load the configuration
  -- data from the context or table into the cache (package variables).
  -- Otherwise we need to wait until the cache duration is over (which defaults
  -- to 10 seconds) and the package reloads the configuration from the context
  -- or table on next call of a public logging method.
  if p_client_identifier = g_conf_client_identifier then
    utl_load_session_configuration;
  end if;
end init;

procedure init (
  p_level          integer default c_level_info ,
  p_duration       integer default 60           ,
  p_cache_size     integer default 0            ,
  p_check_interval integer default 10           ,
  p_call_stack     boolean default false        ,
  p_user_env       boolean default false        ,
  p_apex_env       boolean default false        ,
  p_cgi_env        boolean default false        ,
  p_console_env    boolean default false        )
is
begin
  init (
    p_client_identifier => g_conf_client_identifier ,
    p_level             => p_level                  ,
    p_duration          => p_duration               ,
    p_check_interval    => p_check_interval         ,
    p_cache_size        => p_cache_size             ,
    p_user_env          => p_user_env               ,
    p_apex_env          => p_apex_env               ,
    p_cgi_env           => p_cgi_env                ,
    p_console_env       => p_console_env            );
end init;

--------------------------------------------------------------------------------

-- We need this procedure to be able to use the identifier "exit". An internal
-- call to "exit" would not compile, to "exit_" it is ok. Also see calls to
-- "exit_" in the next two procedures.
procedure exit_ (
  p_client_identifier varchar2 )
is
  pragma autonomous_transaction;
begin
  assert(p_client_identifier is not null, 'Client identifier must not be null.');
  delete from console_sessions where client_identifier = p_client_identifier;
  commit;
  utl_ctx_clear( p_client_identifier );
  -- If we monitor our own session, wee need to load the configuration
  -- data from the context or table into the cache (package variables).
  -- Otherwise we need to wait until the cache duration is over (which defaults
  -- to 10 seconds) and the package reloads the configuration from the context
  -- or table on next call of a public logging method.
  if p_client_identifier = g_conf_client_identifier then
    utl_load_session_configuration;
    flush_cache;
  end if;
end exit_;

--------------------------------------------------------------------------------

procedure exit (
  p_client_identifier varchar2 default my_client_identifier )
is
begin
  exit_(p_client_identifier);
end exit;

--------------------------------------------------------------------------------

procedure exit_stale is
begin
  for i in (
    select client_identifier
      from console_sessions
     where exit_sysdate < sysdate - 1/24 )
  loop
    exit_(i.client_identifier);
  end loop;
end exit_stale;

--------------------------------------------------------------------------------

function context_is_available return boolean is
begin
  return g_conf_context_is_available;
end;

--------------------------------------------------------------------------------

function context_is_available_yn return varchar2 is
begin
  return to_yn(g_conf_context_is_available);
end;

--------------------------------------------------------------------------------

function version return varchar2 is
begin
  return c_version;
end;

--------------------------------------------------------------------------------

function to_yn (
  p_bool boolean )
return varchar2 is
begin
  return case when p_bool then 'Y' else 'N' end;
end;

--------------------------------------------------------------------------------

function to_bool (
  p_string varchar2 )
return boolean is
begin
  return
    case when upper(trim(p_string)) in ('Y', 'YES', '1', 'TRUE')
      then true
      else false
    end;
end;

--------------------------------------------------------------------------------

function to_html_table (
  p_data_cursor       sys_refcursor         ,
  p_comment           varchar2 default null ,
  p_include_row_num   boolean  default true ,
  p_max_rows          integer  default 100  ,
  p_max_column_length integer  default 1000 )
return clob is
  v_data_cursor        sys_refcursor := p_data_cursor;
  v_cursor_id          integer;
  v_clob               clob;
  v_cache              t_vc32k;
  v_data_count         pls_integer := 0;
  v_col_count          pls_integer;
  v_desc_tab           dbms_sql.desc_tab3;
  v_buffer_varchar2    t_vc32k;
  v_buffer_clob        clob;
  v_buffer_xmltype     xmltype;
  v_buffer_long        long;
  v_buffer_long_length pls_integer;
  --
  procedure close_cursor ( p_cursor_id in out integer ) is
  begin
    if dbms_sql.is_open(p_cursor_id) then
      dbms_sql.close_cursor(p_cursor_id);
    end if;
  exception
    when invalid_cursor then null;
  end close_cursor;
  --
  function escape ( p_text varchar2 ) return varchar2 is
  begin
    return replace(replace(replace(p_text,
      c_ampersand, c_html_ampersand    ),
      '<'        , c_html_less_then    ),
      '>'        , c_html_greater_then );
  end;
  --
  procedure describe_columns is
  begin
    dbms_sql.describe_columns3(v_cursor_id, v_col_count, v_desc_tab);
    for i in 1..v_col_count loop
      if v_desc_tab(i).col_type = c_clob then
        dbms_sql.define_column(v_cursor_id, i, v_buffer_clob);
      elsif v_desc_tab(i).col_type = c_xmltype then
        dbms_sql.define_column(v_cursor_id, i, v_buffer_xmltype);
      elsif v_desc_tab(i).col_type = c_long then
        dbms_sql.define_column_long(v_cursor_id, i);
      elsif v_desc_tab(i).col_type in (c_raw, c_long_raw, c_blob, c_bfile) then
        null; --> we ignore binary data types
      else
        dbms_sql.define_column(v_cursor_id, i, v_buffer_varchar2, p_max_column_length);
      end if;
    end loop;
  end describe_columns;
  --
  procedure create_header is
  begin
    clob_append(v_clob, v_cache, c_lf || '<tr><!--- header -->' || c_lf);
    if p_include_row_num then
      clob_append(v_clob, v_cache, '<th id="row_num">Row#</th>' || c_lf);
    end if;
    for i in 1..v_col_count loop
      clob_append(v_clob, v_cache, '<th id="' || lower(v_desc_tab(i).col_name) || '">'
      || initcap(replace(v_desc_tab(i).col_name, '_', ' ')) || '</th>' || c_lf);
    end loop;
    clob_append(v_clob, v_cache, '</tr><!-- header -->' || c_lf);
  end create_header;
  --
  procedure create_data is
  begin
    loop
      exit when dbms_sql.fetch_rows(v_cursor_id) = 0 or v_data_count = p_max_rows;
      v_data_count := v_data_count + 1;
      clob_append(v_clob, v_cache, c_lf || '<tr><!--- row ' || to_char(v_data_count) || ' -->' || c_lf);
      if p_include_row_num then
        clob_append(v_clob, v_cache, '<td headers="row_num">' || to_char(v_data_count) || '</td>' || c_lf);
      end if;
      for i in 1..v_col_count loop
        clob_append(v_clob, v_cache, '<td headers="' || lower(v_desc_tab(i).col_name) || '">');
        --
        if v_desc_tab(i).col_type = c_clob then
          dbms_sql.column_value(v_cursor_id, i, v_buffer_clob);
          clob_append(
            v_clob,
            v_cache,
            escape(substr(v_buffer_clob, 1, p_max_column_length))
            || case when length(v_buffer_clob) > p_max_column_length then '...' end
          );
        --
        elsif v_desc_tab(i).col_type = c_xmltype then
          dbms_sql.column_value(v_cursor_id, i, v_buffer_xmltype);
          if v_buffer_xmltype is not null then
            v_buffer_clob := v_buffer_xmltype.getclobval();
            clob_append(
              v_clob,
              v_cache,
              escape(substr(v_buffer_clob, 1, p_max_column_length))
              || case when length(v_buffer_clob) > p_max_column_length then '...' end
            );
          end if;
        --
        elsif v_desc_tab(i).col_type = c_long then
          dbms_sql.column_value_long(v_cursor_id, i, p_max_column_length, 0, v_buffer_varchar2, v_buffer_long_length);
            clob_append(
              v_clob,
              v_cache,
              escape(v_buffer_varchar2)
              || case when v_buffer_long_length > p_max_column_length then '...' end
            );
        --
        elsif v_desc_tab(i).col_type in (c_raw, c_long_raw, c_blob, c_bfile) then
          clob_append(v_clob, v_cache, 'Binary data type skipped - not supported for HTML');
        --
        else
          dbms_sql.column_value(v_cursor_id, i, v_buffer_varchar2);
          clob_append(v_clob, v_cache, escape(v_buffer_varchar2));
        end if;
        --
        clob_append(v_clob, v_cache, '</td>' || c_lf);
      end loop;
      clob_append(v_clob, v_cache, '</tr><!-- row ' || to_char(v_data_count) || ' -->' || c_lf);
    end loop;
  end create_data;
  --
begin
  v_cursor_id := dbms_sql.to_cursor_number(v_data_cursor);
  describe_columns;
  if p_comment is not null then
    clob_append(v_clob, v_cache, escape(p_comment) || c_lflf);
  end if;
  clob_append(v_clob, v_cache, '<table>' || c_lf);
  create_header;
  create_data;
  clob_append(v_clob, v_cache, c_lf || '</table>' || c_lf);
  clob_flush_cache(v_clob, v_cache);
  close_cursor(v_cursor_id);
  return v_clob;
end to_html_table;

--------------------------------------------------------------------------------

function to_md_tab_header (
  p_key   varchar2 default 'Attribute' ,
  p_value varchar2 default 'Value'     )
return varchar2 is
  v_key   t_vc32k;
  v_value t_vc32k;
begin
  v_key   := utl_escape_md_tab_text(p_key);
  v_value := utl_escape_md_tab_text(p_value);
  return '| ' ||
    case when nvl(length(v_key),   0) < 30 then rpad(nvl(v_key  ,' '), 30, ' ') else v_key   end || ' | ' ||
    case when nvl(length(v_value), 0) < 43 then rpad(nvl(v_value,' '), 43, ' ') else v_value end || ' |'  || c_lf ||
    '| ------------------------------ | ------------------------------------------- |' || c_lf;
end;

--------------------------------------------------------------------------------

function to_md_tab_data (
  p_key              varchar2               ,
  p_value            varchar2               ,
  p_value_max_length integer  default 1000  ,
  p_show_null_values boolean  default false )
return varchar2 is
  v_key   t_vc32k;
  v_value t_vc32k;
begin
  if p_value is null and not p_show_null_values then
    return null;
  else
    v_key   := utl_escape_md_tab_text(p_key);
    v_value := utl_escape_md_tab_text(substr(p_value, 1, p_value_max_length));
    return '| ' ||
      case when nvl(length(v_key),   0) < 30 then rpad(nvl(v_key  ,' '), 30, ' ') else v_key   end || ' | ' ||
      case when nvl(length(v_value), 0) < 43 then rpad(nvl(v_value,' '), 43, ' ') else v_value end || ' |'  || c_lf;
  end if;
end;

--------------------------------------------------------------------------------

function to_unibar (
  p_value                   in  number,
  p_scale                   in  number default 1,
  p_width_block_characters  in  number default 25,
  p_fill_scale              in  number default 0
) return varchar2
  deterministic
is
  v_return               varchar2(1000);
  v_value_one_character  number;
begin
  if p_value is not null then
  -- calculate the value of one character
    v_value_one_character := p_scale / p_width_block_characters;

  -- create textbar: full block characters
    for i in 1..FLOOR(p_value / v_value_one_character) loop
      v_return := v_return || UNISTR('\2588');
    end loop;

  -- create textbar: last character - can be between 0 and 8(rounded), because there
  -- are block character available in unicode for 1/8, 1/4, 3/8, 1/2, 5/8, 3/4, 7/8 and 1;
    case ROUND((p_value / v_value_one_character - FLOOR(p_value / v_value_one_character)) / 0.125)
      when 1 then -- 1/8 = char U+258F
        v_return := v_return || UNISTR('\258F');
      when 2 then -- 2/8 = char U+258E
        v_return := v_return || UNISTR('\258E');
      when 3 then -- 3/8 = char U+258D
        v_return := v_return || UNISTR('\258D');
      when 4 then -- 4/8 = char U+258C
        v_return := v_return || UNISTR('\258C');
      when 5 then -- 5/8 = char U+258B
        v_return := v_return || UNISTR('\258B');
      when 6 then -- 6/8 = char U+258A
        v_return := v_return || UNISTR('\258A');
      when 7 then -- 7/8 = char U+2589
        v_return := v_return || UNISTR('\2589');
      when 8 then -- 8/8 = char U+2588
        v_return := v_return || UNISTR('\2588');
      else
        null;
    end case;

  -- fill up scale with shade
    if p_fill_scale = 1 then
      for i in 1..( p_width_block_characters - NVL(LENGTH(v_return), 0) ) loop
        v_return := v_return || UNISTR('\2591');
      end loop;
    end if;
  end if;

  return v_return;
exception
  when VALUE_ERROR then
    return UNISTR('\221E');
end to_unibar;

--------------------------------------------------------------------------------

procedure print ( p_message in varchar2 ) is
begin
  dbms_output.put_line(p_message);
end;

--------------------------------------------------------------------------------

function get_runtime ( p_start timestamp ) return varchar2 is
  v_runtime t_vc32;
begin
  v_runtime := to_char(localtimestamp - p_start);
  return substr(v_runtime, instr(v_runtime,':')-2, 15);
end get_runtime;

--------------------------------------------------------------------------------

function get_runtime_seconds ( p_start timestamp ) return number is
  v_runtime interval day to second;
begin
  v_runtime := localtimestamp - p_start;
  return
    extract(hour   from v_runtime) * 3600 +
    extract(minute from v_runtime) *   60 +
    extract(second from v_runtime)        ;
end get_runtime_seconds;

--------------------------------------------------------------------------------

function get_runtime_milliseconds ( p_start timestamp ) return number is
begin
  return get_runtime_seconds(p_start) * 1000;
end get_runtime_milliseconds;

--------------------------------------------------------------------------------

function get_level_name (p_level integer) return varchar2 deterministic is
begin
  return case p_level
    when 1 then 'error'
    when 2 then 'warning'
    when 3 then 'info'
    when 4 then 'debug'
    when 5 then 'trace'
    else null
  end;
end get_level_name;

--------------------------------------------------------------------------------

function get_scope return varchar2 is
  v_return     t_vc32k;
  v_subprogram t_vc32k;
begin
  if utl_call_stack.dynamic_depth > 0 then
    --ignore 1, is always this function (get_scope) itself
    for i in 2 .. utl_call_stack.dynamic_depth
    loop
      v_subprogram := utl_call_stack.concatenate_subprogram( utl_call_stack.subprogram(i) );
      --exclude console package from the scope
      if instr ( upper(v_subprogram), 'CONSOLE.' ) = 0 then
        v_return := v_return
          || case when utl_call_stack.owner(i) is not null then utl_call_stack.owner(i) || '.' end
          || v_subprogram || ', line ' || utl_call_stack.unit_line(i);
      end if;
      exit when v_return is not null;
    end loop;
  end if;
  return v_return;
end get_scope;

--------------------------------------------------------------------------------

function get_calling_unit return varchar2 is
  v_return     t_vc32k;
  v_subprogram t_vc32k;
begin
  if utl_call_stack.dynamic_depth > 0 then
    --ignore 1, is always this function (get_scope) itself
    for i in 2 .. utl_call_stack.dynamic_depth
    loop
      v_subprogram := utl_call_stack.concatenate_subprogram( utl_call_stack.subprogram(i) );
      --exclude console package
      if instr ( upper(v_subprogram), 'CONSOLE.' ) = 0 then
        v_return := v_return
          || case when utl_call_stack.owner(i) is not null then utl_call_stack.owner(i) || '.' end
          || substr(v_subprogram, 1, instr(v_subprogram,'.') - 1 );
      end if;
      exit when v_return is not null;
    end loop;
  end if;
  return v_return;
end get_calling_unit;

--------------------------------------------------------------------------------

function get_call_stack return varchar2
is
  v_return     t_vc32k;
  v_subprogram t_vc32k;
begin

  if g_saved_stack.count > 0 then
    v_return := v_return || '## Saved Error Stack' || c_lflf;
    for i in 1 .. g_saved_stack.count
    loop
      v_return := v_return || '- ' || g_saved_stack (i) || c_lf;
    end loop;
    v_return := v_return || c_lf;
  end if;

  if utl_call_stack.dynamic_depth > 0 then
    v_return := v_return || '## Call Stack' || c_lflf;
    --ignore 1, is always this function (get_call_stack) itself
    for i in 2 .. utl_call_stack.dynamic_depth
    loop
      v_subprogram := utl_call_stack.concatenate_subprogram ( utl_call_stack.subprogram(i) );
      --exclude console package from the call stack
      if instr( upper(v_subprogram), 'CONSOLE.' ) = 0 then
        v_return := v_return
          || '- '
          || case when utl_call_stack.owner(i) is not null then utl_call_stack.owner(i) || '.' end
          || v_subprogram || ', line ' || utl_call_stack.unit_line(i) || c_lf;
      end if;
    end loop;
    v_return := v_return || c_lf;
  end if;

  if utl_call_stack.error_depth > 0 then
    v_return := v_return || '## Error Stack' || c_lflf;
    for i in 1 .. utl_call_stack.error_depth
    loop
      v_return := v_return
        || '- ORA-'
        || trim(to_char(utl_call_stack.error_number(i), '00009')) || ' '
        || utl_replace_linebreaks(utl_call_stack.error_msg(i)) || c_lf;
    end loop;
    v_return := v_return || c_lf;
  end if;

  if utl_call_stack.backtrace_depth > 0 then
    v_return := v_return || '## Error Backtrace' || c_lflf;
    for i in 1 .. utl_call_stack.backtrace_depth
    loop
      v_return := v_return
        || '- '
        || coalesce( utl_call_stack.backtrace_unit(i), '__anonymous_block' )
        || ', line ' || utl_call_stack.backtrace_line(i) || c_lf;
    end loop;
    v_return := v_return || c_lf;
  end if;

  return v_return || chr(10);
end get_call_stack;

--------------------------------------------------------------------------------

function get_apex_env return clob
is
  v_clob        clob;
  v_cache       t_vc32k;
  v_value       t_vc32k;
  v_app_id      pls_integer;
  v_app_page_id pls_integer;
  v_app_session pls_integer;
  --
begin
  $if not $$apex_installed $then
  null;
  $else

  --https://jeffkemponoracle.com/2015/11/apex-5-application-context/
  --https://joelkallman.blogspot.com/2016/09/correlating-apex-sessions-to-database.html
  --sys_context('APEX$SESSION','APP_USER')
  --sys_context('APEX$SESSION','WORKSPACE_ID')
  v_app_id      :=           v(                 'APP_ID'      );
  v_app_page_id :=           v(                 'APP_PAGE_ID' );
  v_app_session := sys_context( 'APEX$SESSION', 'APP_SESSION' );

  clob_append(v_clob, v_cache, '## APEX Environment' || c_lflf);

  clob_append(v_clob, v_cache,
    '### Application Items' ||
    case when v_app_id is not null then ' - APP_ID ' || v_app_id end ||
    c_lflf || to_md_tab_header('Item Name'));
  for i in (
    select item_name
      from apex_application_items
    where application_id = v_app_id )
  loop
    v_value := v(i.item_name);
    clob_append(v_clob, v_cache, to_md_tab_data(i.item_name, v_value));
  end loop;
  clob_append(v_clob, v_cache, c_lf);

  --Only page items from current page when level < debug, otherwise all page items.
  clob_append(v_clob, v_cache,
    '### Page Items' ||
    case when g_conf_level < c_level_debug and v_app_page_id is not null then ' - APP_PAGE_ID ' || v_app_page_id end ||
    c_lflf || to_md_tab_header('Item Name'));
  for i in (
    select item_name
      from apex_application_page_items
    where application_id = v_app_id
      and page_id        = case when (select console.my_log_level from dual) >= (select console.level_debug from dual)
                              then page_id
                              else v_app_page_id
                            end )
  loop
    v_value := v(i.item_name);
    clob_append(v_clob, v_cache, to_md_tab_data(i.item_name, v_value));
  end loop;
  clob_append(v_clob, v_cache, c_lf);

  clob_flush_cache(v_clob, v_cache);

  $end
  return v_clob;
end get_apex_env;

--------------------------------------------------------------------------------

function get_cgi_env return varchar2
is
  v_return t_vc32k;
begin
  v_return := '## CGI Environment' || c_lflf || to_md_tab_header;
  for i in 1 .. nvl(owa.num_cgi_vars, 0) loop
    v_return := v_return ||
      to_md_tab_data(
        p_key   => owa.cgi_var_name(i) ,
        p_value => owa.cgi_var_val (i) );
  end loop;
  v_return := v_return || c_lf;
  return v_return;
exception
  when value_error then
    --> we simply return here what we already have and forget about the rest...
    return v_return;
end get_cgi_env;

--------------------------------------------------------------------------------

function get_console_env return varchar2
is
  v_return t_vc32k;
  v_index t_vc128;
  --
  procedure append_row (p_key varchar2, p_value varchar2) is
  begin
    v_return := v_return || to_md_tab_data(p_key, p_value, p_show_null_values => true);
  end append_row;
  --
begin
  v_return := '## Console Environment' || c_lflf || to_md_tab_header;
  append_row('c_version',                       to_char( c_version                                     ) );
  append_row('g_conf_context_is_available',       to_yn( g_conf_context_is_available                   ) );
  append_row('c_ctx_namespace',                          c_ctx_namespace                                 );
  append_row('g_conf_check_sysdate',            to_char( g_conf_check_sysdate,       c_ctx_date_format ) );
  append_row('g_conf_exit_sysdate',             to_char( g_conf_exit_sysdate,        c_ctx_date_format ) );
  append_row('g_conf_client_identifier',                 g_conf_client_identifier                        );
  append_row('g_conf_level',                    to_char( g_conf_level                                  ) );
  append_row('get_level_name(g_conf_level)',             get_level_name(g_conf_level)                    );
  append_row('g_conf_cache_size',               to_char( g_conf_cache_size                             ) );
  append_row('g_conf_check_interval',           to_char( g_conf_check_interval                         ) );
  append_row('g_conf_call_stack',                 to_yn( g_conf_call_stack                             ) );
  append_row('g_conf_user_env',                   to_yn( g_conf_user_env                               ) );
  append_row('g_conf_apex_env',                   to_yn( g_conf_apex_env                               ) );
  append_row('g_conf_cgi_env',                    to_yn( g_conf_cgi_env                                ) );
  append_row('g_conf_console_env',                to_yn( g_conf_console_env                            ) );
  append_row('g_conf_unit_levels(2)',                    g_conf_unit_levels(2)                           );
  append_row('g_conf_unit_levels(3)',                    g_conf_unit_levels(3)                           );
  append_row('g_conf_unit_levels(4)',                    g_conf_unit_levels(4)                           );
  append_row('g_conf_unit_levels(5)',                    g_conf_unit_levels(5)                           );
  append_row('g_counters.count',                to_char( g_counters.count                              ) );
  append_row('g_timers.count',                  to_char( g_timers.count                                ) );
  append_row('g_log_cache.count',               to_char( g_log_cache.count                             ) );
  append_row('g_saved_stack.count',             to_char( g_saved_stack.count                           ) );
  append_row('g_prev_error_msg', utl_replace_linebreaks( g_prev_error_msg                              ) );

  v_return := v_return || c_lf;

  if g_timers.count > 0 then
    v_return := v_return || '### Running Timers' || c_lflf || to_md_tab_header('Label', 'Start Time (localtimestamp)');
    v_index := g_timers.first;
    loop
      exit when v_index is null;
      append_row(v_index, to_char(g_timers(v_index), c_timestamp_format));
      v_index := g_timers.next(v_index);
    end loop;
    v_return := v_return || c_lf;
  end if;

  if g_counters.count > 0 then
    v_return := v_return || '### Running Counters' || c_lflf || to_md_tab_header('Label', 'Current Count');
    v_index := g_counters.first;
    loop
      exit when v_index is null;
      append_row(v_index, to_char(g_counters(v_index)));
      v_index := g_counters.next(v_index);
    end loop;
    v_return := v_return || c_lf;
  end if;

  return v_return;
exception
  when value_error then
    --> we simply return here what we already have and forget about the rest...
    return v_return;
end get_console_env;

--------------------------------------------------------------------------------

function get_user_env return varchar2
is
  v_return t_vc32k;
  invalid_user_env_key exception;
  pragma exception_init(invalid_user_env_key, -2003);
  --
  procedure append_row (p_key varchar2) is
  begin
    v_return := v_return || to_md_tab_data(
      p_key              => p_key                         ,
      p_value            => sys_context('USERENV', p_key) ,
      p_value_max_length => 4000); --> we do this for the CURRENT_SQL attribute, which can have up to 4000 bytes
  exception
    when invalid_user_env_key then
      null;
  end append_row;
  --
begin
  v_return := '## User Environment' || c_lflf || to_md_tab_header;
  --
  append_row('ACTION');
  append_row('AUDITED_CURSORID');
  append_row('AUTHENTICATED_IDENTITY');
  append_row('AUTHENTICATION_DATA');
  append_row('AUTHENTICATION_METHOD');
  append_row('BG_JOB_ID');
  append_row('CDB_DOMAIN');
  append_row('CDB_NAME');
  append_row('CLIENT_IDENTIFIER');
  append_row('CLIENT_INFO');
  append_row('CLIENT_PROGRAM_NAME');
  append_row('CON_ID');
  append_row('CON_NAME');
  append_row('CURRENT_BIND');
  append_row('CURRENT_EDITION_ID');
  append_row('CURRENT_EDITION_NAME');
  append_row('CURRENT_SCHEMA');
  append_row('CURRENT_SCHEMAID');
  append_row('CURRENT_SQL_LENGTH');
  append_row('CURRENT_SQL');
  append_row('CURRENT_USER');
  append_row('CURRENT_USERID');
  append_row('DATABASE_ROLE');
  append_row('DB_DOMAIN');
  append_row('DB_NAME');
  append_row('DB_SUPPLEMENTAL_LOG_LEVEL');
  append_row('DB_UNIQUE_NAME');
  append_row('DBLINK_INFO');
  append_row('ENTERPRISE_IDENTITY');
  append_row('ENTRYID');
  append_row('FG_JOB_ID');
  append_row('GLOBAL_CONTEXT_MEMORY');
  append_row('GLOBAL_UID');
  append_row('HOST');
  append_row('IDENTIFICATION_TYPE');
  append_row('INSTANCE_NAME');
  append_row('INSTANCE');
  append_row('IP_ADDRESS');
  append_row('IS_APPLICATION_PDB');
  append_row('IS_APPLICATION_ROOT');
  append_row('IS_APPLY_SERVER');
  append_row('IS_DG_ROLLING_UPGRADE');
  append_row('ISDBA');
  append_row('LANG');
  append_row('LANGUAGE');
  append_row('LDAP_SERVER_TYPE');
  append_row('MODULE');
  append_row('NETWORK_PROTOCOL');
  append_row('NLS_CALENDAR');
  append_row('NLS_CURRENCY');
  append_row('NLS_DATE_FORMAT');
  append_row('NLS_DATE_LANGUAGE');
  append_row('NLS_SORT');
  append_row('NLS_TERRITORY');
  append_row('ORACLE_HOME');
  append_row('OS_USER');
  append_row('PLATFORM_SLASH');
  append_row('POLICY_INVOKER');
  append_row('PROXY_ENTERPRISE_IDENTITY');
  append_row('PROXY_USER');
  append_row('PROXY_USERID');
  append_row('SCHEDULER_JOB');
  append_row('SERVER_HOST');
  append_row('SERVICE_NAME');
  append_row('SESSION_DEFAULT_COLLATION');
  append_row('SESSION_EDITION_ID');
  append_row('SESSION_EDITION_NAME');
  append_row('SESSION_USER');
  append_row('SESSION_USERID');
  append_row('SESSIONID');
  append_row('SID');
  append_row('STATEMENTID');
  append_row('TERMINAL');
  append_row('UNIFIED_AUDIT_SESSIONID');
  --
  v_return := v_return || c_lf ||
    'We tried to show [documented attributes from Oracle 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/SYS_CONTEXT.html#GUID-B9934A5D-D97B-4E51-B01B-80C76A5BD086).' || c_lf ||
    'On older databases not existing attributes or values which are null are simply omitted.' || c_lflf;
  return v_return;
exception
  when value_error then
    --> we simply return here what we already have and forget about the rest...
    return v_return;
end get_user_env;

--------------------------------------------------------------------------------

procedure clob_append (
  p_clob  in out nocopy clob     ,
  p_cache in out nocopy varchar2 ,
  p_text  in            varchar2 )
is
begin
  p_cache := p_cache || p_text;
exception
  when value_error then
    if p_clob is null then
      p_clob := p_cache;
    else
      dbms_lob.writeappend(p_clob, length(p_cache), p_cache);
    end if;
    p_cache := p_text;
end clob_append;

--------------------------------------------------------------------------------

procedure clob_append (
  p_clob  in out nocopy clob     ,
  p_cache in out nocopy varchar2 ,
  p_text  in            clob     )
is
begin
  if p_text is not null then
    clob_flush_cache(p_clob, p_cache);
    if p_clob is null then
      p_clob := p_text;
    else
      dbms_lob.writeappend(p_clob, length(p_text), p_text);
    end if;
  end if;
end;

--------------------------------------------------------------------------------

procedure clob_flush_cache (
  p_clob  in out nocopy clob     ,
  p_cache in out nocopy varchar2 )
is
begin
  if p_cache is not null then
    if p_clob is null then
      p_clob := p_cache;
    else
      dbms_lob.writeappend(p_clob, length(p_cache), p_cache);
    end if;
    p_cache := null;
  end if;
end clob_flush_cache;

--------------------------------------------------------------------------------

function view_cache return tab_logs pipelined is
begin
  for i in reverse 1 .. g_log_cache.count loop
    pipe row(g_log_cache(i));
  end loop;
end view_cache;

--------------------------------------------------------------------------------

procedure flush_cache is
  pragma autonomous_transaction;
begin
  if g_log_cache.count > 0 then
    forall i in 1 .. g_log_cache.count
      insert into console_logs values g_log_cache(i);
    commit;
    g_log_cache.delete;
  end if;
end flush_cache;

--------------------------------------------------------------------------------

procedure clear (
  p_client_identifier varchar2 default my_client_identifier )
is
begin
  g_log_cache.delete;
end;

--------------------------------------------------------------------------------

function view_status return tab_key_value pipelined is
  v_row rec_key_value;
begin
  pipe row(new rec_key_value('c_version',                       to_char( c_version                                      )) );
  pipe row(new rec_key_value('g_conf_context_is_available',       to_yn( g_conf_context_is_available                    )) );
  pipe row(new rec_key_value('g_conf_check_sysdate',            to_char( g_conf_check_sysdate,       c_ctx_date_format  )) );
  pipe row(new rec_key_value('g_conf_exit_sysdate',             to_char( g_conf_exit_sysdate,        c_ctx_date_format  )) );
  pipe row(new rec_key_value('g_conf_client_identifier',                 g_conf_client_identifier                        ) );
  pipe row(new rec_key_value('g_conf_level',                    to_char( g_conf_level                                   )) );
  pipe row(new rec_key_value('get_level_name(g_conf_level)',    to_char( get_level_name(g_conf_level)                   )) );
  pipe row(new rec_key_value('g_conf_cache_size',               to_char( g_conf_cache_size                              )) );
  pipe row(new rec_key_value('g_conf_check_interval',           to_char( g_conf_check_interval                          )) );
  pipe row(new rec_key_value('g_conf_call_stack',                 to_yn( g_conf_call_stack                              )) );
  pipe row(new rec_key_value('g_conf_user_env',                   to_yn( g_conf_user_env                                )) );
  pipe row(new rec_key_value('g_conf_apex_env',                   to_yn( g_conf_apex_env                                )) );
  pipe row(new rec_key_value('g_conf_cgi_env',                    to_yn( g_conf_cgi_env                                 )) );
  pipe row(new rec_key_value('g_conf_console_env',                to_yn( g_conf_console_env                             )) );
  pipe row(new rec_key_value('g_counters.count',                to_char( g_counters.count                               )) );
  pipe row(new rec_key_value('g_timers.count',                  to_char( g_timers.count                                 )) );
  pipe row(new rec_key_value('g_log_cache.count',               to_char( g_log_cache.count                              )) );
  pipe row(new rec_key_value('g_saved_stack.count',             to_char( g_saved_stack.count                            )) );
  pipe row(new rec_key_value('g_prev_error_msg', utl_replace_linebreaks( g_prev_error_msg                               )) );
end view_status;

--------------------------------------------------------------------------------

procedure purge (
  p_min_level integer default c_level_info,
  p_min_days  number  default 30 )
is
  pragma autonomous_transaction;
begin
  assert (
    p_min_level in (1,2,3,4,5),
    'Minimum level must be 1 (error), 2 (warning), 3 (info), 4 (debug) or 5 (trace).');
  assert (
    c_console_owner = sys_context('USERENV','SESSION_USER'),
    'Deleting log entries is only allowed for the owner of the console package.');
  delete from console_logs
    where level_id >= p_min_level
      and permanent = 'N'
      and log_systime <= sysdate - p_min_days;
  commit;
end;

--------------------------------------------------------------------------------

procedure purge_all is
begin
  purge(
    p_min_level => 1,
    p_min_days  => -1 -- to be sure we delete everything (sysdate - -1 is the same time tomorrow)
  );
end purge_all;

--------------------------------------------------------------------------------

procedure cleanup_job_create (
  p_repeat_interval varchar2 default 'FREQ=DAILY;BYHOUR=1;' ,
  p_min_level       integer  default c_level_info           ,
  p_min_days        number   default 30                     )
is
begin
  execute immediate replace(replace(replace(replace(q'[
    begin
      for i in (
        select '#CONSOLE_JOB_NAME#' as job_name from dual
        minus
        select job_name from user_scheduler_jobs )
      loop
        sys.dbms_scheduler.create_job(
          job_name        => i.job_name                                                              ,
          job_type        => 'PLSQL_BLOCK'                                                           ,
          job_action      => 'begin console.purge(p_min_level=>#MIN_LEVEL#,p_min_days=>#MIN_DAYS#);' ||
                             ' console.exit_stale; end;'                                             ,
          start_date      => sysdate                                                                 ,
          repeat_interval => '#REPEAT_INTERVAL#'                                                     ,
          enabled         => true                                                                    ,
          auto_drop       => false                                                                   ,
          comments        => 'Cleanup CONSOLE log entries and stale debug sessions.'                 );
      end loop;
    end;
  ]',
  '#CONSOLE_JOB_NAME#', c_console_job_name ),
  '#REPEAT_INTERVAL#' , p_repeat_interval  ),
  '#MIN_LEVEL#'       , p_min_level        ),
  '#MIN_DAYS#'        , p_min_days         );
end cleanup_job_create;

--------------------------------------------------------------------------------

procedure cleanup_job_drop is
begin
  execute immediate replace(q'[
    begin
      for i in (
        select job_name
          from user_scheduler_jobs
         where job_name = '#CONSOLE_JOB_NAME#' )
      loop
        sys.dbms_scheduler.drop_job(
          job_name => i.job_name ,
          force    => true       );
      end loop;
    end;
  ]',
  '#CONSOLE_JOB_NAME#', c_console_job_name );
end cleanup_job_drop;

--------------------------------------------------------------------------------

procedure cleanup_job_enable is
begin
  execute immediate replace(q'[
    begin
      for i in (
        select job_name
          from user_scheduler_jobs
         where job_name = '#CONSOLE_JOB_NAME#' )
      loop
        sys.dbms_scheduler.enable(name => i.job_name);
      end loop;
    end;
  ]',
  '#CONSOLE_JOB_NAME#', c_console_job_name );
end cleanup_job_enable;

--------------------------------------------------------------------------------

procedure cleanup_job_disable is
begin
  execute immediate replace(q'[
    begin
      for i in (
        select job_name
          from user_scheduler_jobs
         where job_name = '#CONSOLE_JOB_NAME#' )
      loop
        sys.dbms_scheduler.disable(
          name  => i.job_name ,
          force => true       );
      end loop;
    end;
  ]',
  '#CONSOLE_JOB_NAME#', c_console_job_name );
end cleanup_job_disable;

--------------------------------------------------------------------------------

procedure cleanup_job_run is
begin
  execute immediate replace(q'[
    begin
      for i in (
        select job_name
          from user_scheduler_jobs
         where job_name = '#CONSOLE_JOB_NAME#' )
      loop
        sys.dbms_scheduler.run_job(job_name => i.job_name);
      end loop;
    end;
  ]',
  '#CONSOLE_JOB_NAME#', c_console_job_name );
end cleanup_job_run;


--------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS
--------------------------------------------------------------------------------

function utl_escape_md_tab_text (p_text varchar2) return varchar2 is
begin
  return replace(replace(replace(replace(p_text,
    c_crlf,   ' '),
    c_lf,     ' '),
    c_cr,     ' '),
    '|', '&#124;');
end;

--------------------------------------------------------------------------------

function utl_get_error return varchar2 is
  v_return t_vc32k;
begin
  if utl_call_stack.error_depth > 0 and utl_call_stack.backtrace_depth > 0 then
    if utl_call_stack.error_number(1) != 6512 and utl_call_stack.error_msg(1) != coalesce(g_prev_error_msg, 'null') then
      --Get the last backtrace line number and also the error message
      v_return := ' (line ' || to_char(utl_call_stack.backtrace_line(utl_call_stack.backtrace_depth)) ||
        ', ORA-' || trim(to_char(utl_call_stack.error_number(1), '00009')) || ' ' ||
        utl_replace_linebreaks(utl_call_stack.error_msg(1)) || ')';
      --Set the new error message as the last error message.
      g_prev_error_msg := utl_call_stack.error_msg(1);
    else
      --Get only the last backtrace line number
      v_return := ' (line ' || to_char(utl_call_stack.backtrace_line(utl_call_stack.backtrace_depth)) || ')';
    end if;
  end if;

  return v_return;
end utl_get_error;

--------------------------------------------------------------------------------

function utl_logging_is_enabled (
  p_level integer )
return boolean is
begin
  if g_conf_check_sysdate < sysdate then
    utl_load_session_configuration;
  end if;
  return
    g_conf_level >= p_level
    or
    sqlcode != 0
    or
    g_conf_unit_levels(p_level) is not null and instr(g_conf_unit_levels(p_level), ','||get_calling_unit||',') > 0;
end utl_logging_is_enabled;

--------------------------------------------------------------------------------

function utl_normalize_label (p_label varchar2) return varchar2 is
begin
  return coalesce(substrb(p_label, 1, 128), c_default_label);
end;

--------------------------------------------------------------------------------

/* HOW TO CHECK THE RESULT CACHE
select id, name, cache_id, type, status, invalidations, scan_count
  from v$result_cache_objects
 where name like '%CONSOLE%'
   and status != 'Invalid';
*/
function utl_read_global_conf
return console_conf%rowtype result_cache is
  v_row console_conf%rowtype;
begin
  select *
    into v_row
    from console_conf
   where conf_id = c_conf_id;
  return v_row;
exception
  when no_data_found then
    return v_row;
end utl_read_global_conf;


function utl_read_session_conf (
  p_client_identifier varchar2 )
return console_sessions%rowtype result_cache is
  v_row console_sessions%rowtype;
begin
  select *
    into v_row
    from console_sessions
   where client_identifier = p_client_identifier;
  return v_row;
exception
  when no_data_found then
    return v_row;
end utl_read_session_conf;

--------------------------------------------------------------------------------

function utl_replace_linebreaks (
  p_text varchar2,
  p_replace_with varchar2 default ' ')
return varchar2 is
begin
  return replace(replace(replace(p_text,
    c_crlf, p_replace_with),
    c_lf,   p_replace_with),
    c_cr,   p_replace_with);
end;

--------------------------------------------------------------------------------

procedure utl_ctx_check_availability is
begin
  sys.dbms_session.set_context(c_ctx_namespace, c_ctx_test_attribute, 'test');
  g_conf_context_is_available := true;
exception
  when insufficient_privileges then
    g_conf_context_is_available := false;
end utl_ctx_check_availability;

--------------------------------------------------------------------------------

procedure utl_ctx_set (
p_attribute         varchar2 ,
p_value             varchar2 ,
p_client_identifier varchar2 )
is
begin
  sys.dbms_session.set_context(
    namespace => c_ctx_namespace     ,
    attribute => p_attribute         ,
    value     => p_value             ,
    client_id => p_client_identifier );
exception
  when insufficient_privileges then
    error ( 'Context not available, package var g_conf_context_is_available tells us it is ?!?' );
end utl_ctx_set;

--------------------------------------------------------------------------------

procedure utl_ctx_clear_all is
begin
  if g_conf_context_is_available then
    sys.dbms_session.clear_all_context(c_ctx_namespace);
  end if;
end utl_ctx_clear_all;

--------------------------------------------------------------------------------

procedure utl_ctx_clear (
  p_client_identifier varchar2 )
is
begin
  if g_conf_context_is_available then
    sys.dbms_session.clear_context(c_ctx_namespace, p_client_identifier);
  end if;
end utl_ctx_clear;

--------------------------------------------------------------------------------

procedure utl_load_session_configuration is
  v_session_conf console_sessions%rowtype;
  v_global_conf  console_conf%rowtype;
  --
  procedure set_default_config is
  begin
    --We have no real conf until now, so we fake 24 hours.
    --Conf will be re-evaluated at least every 10 seconds.
    g_conf_exit_sysdate   := sysdate + 1;
    g_conf_level          := coalesce(v_global_conf.level_id, 1);
    g_conf_cache_size     := 0;
    g_conf_check_interval := coalesce(v_global_conf.check_interval, 10);
    g_conf_call_stack     := false;
    g_conf_user_env       := false;
    g_conf_apex_env       := false;
    g_conf_cgi_env        := false;
    g_conf_console_env    := false;
  end set_default_config;
  --
  procedure load_config_from_context is
  begin
    g_conf_level          := to_number ( sys_context ( c_ctx_namespace, c_ctx_level          ) );
    g_conf_cache_size     := to_number ( sys_context ( c_ctx_namespace, c_ctx_cache_size     ) );
    g_conf_check_interval := to_number ( sys_context ( c_ctx_namespace, c_ctx_check_interval ) );
    g_conf_call_stack     := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_call_stack     ) );
    g_conf_user_env       := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_user_env       ) );
    g_conf_apex_env       := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_apex_env       ) );
    g_conf_cgi_env        := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_cgi_env        ) );
    g_conf_console_env    := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_console_env    ) );
  end load_config_from_context;
  --
  procedure load_config_from_table_row is
  begin
    g_conf_level          :=           v_session_conf.level_id        ;
    g_conf_cache_size     :=           v_session_conf.cache_size      ;
    g_conf_check_interval :=           v_session_conf.check_interval  ;
    g_conf_call_stack     := to_bool ( v_session_conf.call_stack     );
    g_conf_user_env       := to_bool ( v_session_conf.user_env       );
    g_conf_apex_env       := to_bool ( v_session_conf.apex_env       );
    g_conf_cgi_env        := to_bool ( v_session_conf.cgi_env        );
    g_conf_console_env    := to_bool ( v_session_conf.console_env    );
  end load_config_from_table_row;
  --
begin
  v_global_conf := utl_read_global_conf;
  g_conf_unit_levels(2) := v_global_conf.units_level_warning ;
  g_conf_unit_levels(3) := v_global_conf.units_level_info    ;
  g_conf_unit_levels(4) := v_global_conf.units_level_debug   ;
  g_conf_unit_levels(5) := v_global_conf.units_level_trace   ;
  if g_conf_context_is_available then
    g_conf_exit_sysdate := to_date(sys_context(c_ctx_namespace, c_ctx_exit_sysdate), c_ctx_date_format);
    if g_conf_exit_sysdate is null then
      set_default_config;
    elsif g_conf_exit_sysdate < sysdate then
      utl_ctx_clear(g_conf_client_identifier);
      set_default_config;
    else
      load_config_from_context;
    end if;
  else
    v_session_conf := utl_read_session_conf(g_conf_client_identifier);
    g_conf_exit_sysdate := v_session_conf.exit_sysdate;
    if g_conf_exit_sysdate is null or g_conf_exit_sysdate < sysdate then
      set_default_config;
    else
      load_config_from_table_row;
    end if;
  end if;
  g_conf_check_sysdate := least(g_conf_exit_sysdate, sysdate + 1/24/60/60 * g_conf_check_interval);

end utl_load_session_configuration;

--------------------------------------------------------------------------------

procedure utl_set_client_identifier is
begin
  g_conf_client_identifier := sys_context('USERENV', 'CLIENT_IDENTIFIER');
  if g_conf_client_identifier is null or g_conf_client_identifier = ':' then
    g_conf_client_identifier := c_client_id_prefix || dbms_session.unique_session_id;
    dbms_session.set_identifier(g_conf_client_identifier);
  end if;
end utl_set_client_identifier;

--------------------------------------------------------------------------------

function utl_create_log_entry (
  p_level           integer                ,
  p_message         clob     default null  ,
  p_permanent       boolean  default false ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type
is
  pragma autonomous_transaction;
  v_row   console_logs%rowtype;
  v_cache t_vc32k;
begin
  v_row.scope :=
    case
      when p_user_scope is not null then substrb(p_user_scope, 1, 256)
      else substrb(get_scope, 1, 256)
    end;

  -- This is the very first (possible) assignment to the row.message variable,
  -- so we can do it without our clob_append method.
  v_row.message :=
    case
      when p_message is not null then p_message || c_lflf
      when sqlcode != 0 then sqlerrm || c_lflf
      else null
    end;

  v_row.error_code :=
    case
      when p_user_error_code is not null then p_user_error_code
      when sqlcode != 0 then sqlcode
      else null
    end;


  if p_user_call_stack is not null then
    v_row.call_stack := substrb(p_user_call_stack, 1, 4000);
  elsif p_call_stack then
    --Save the last occured error (if any and if we called before
    --error_save_stack) before we going to log the callstack.
    if sqlcode != 0 and g_saved_stack.count > 0 then
      error_save_stack;
    end if;
    v_row.call_stack := substrb(get_call_stack, 1, 4000);
    if p_level = 1 then
      --We finally logged the saved stack, so we need to reset it.
      g_saved_stack.delete;
      g_prev_error_msg := null;
    end if;
  end if;

  if p_apex_env or g_conf_apex_env then
    clob_append(v_row.message, v_cache, get_apex_env);
  end if;

  if p_cgi_env or g_conf_cgi_env then
    clob_append(v_row.message, v_cache, get_cgi_env);
  end if;

  if p_console_env or g_conf_console_env then
    clob_append(v_row.message, v_cache, get_console_env);
  end if;

  if p_user_env or g_conf_user_env then
    clob_append(v_row.message, v_cache, get_user_env);
  end if;

  clob_flush_cache(v_row.message, v_cache);

  v_row.log_systime       := systimestamp;
  v_row.level_id          := p_level;
  v_row.level_name        := get_level_name(p_level);
  v_row.permanent         := to_yn(p_permanent);
  v_row.session_user      := substrb ( sys_context ( 'USERENV', 'SESSION_USER'      ), 1, 32 );
  v_row.module            := substrb ( sys_context ( 'USERENV', 'MODULE'            ), 1, 48 );
  v_row.action            := substrb ( sys_context ( 'USERENV', 'ACTION'            ), 1, 32 );
  v_row.client_info       := substrb ( sys_context ( 'USERENV', 'CLIENT_INFO'       ), 1, 64 );
  v_row.client_identifier := substrb ( sys_context ( 'USERENV', 'CLIENT_IDENTIFIER' ), 1, 64 );
  v_row.ip_address        := substrb ( sys_context ( 'USERENV', 'IP_ADDRESS'        ), 1, 48 );
  v_row.host              := substrb ( sys_context ( 'USERENV', 'HOST'              ), 1, 64 );
  v_row.os_user           := substrb ( sys_context ( 'USERENV', 'OS_USER'           ), 1, 64 );
  v_row.os_user_agent     := substrb ( p_user_agent, 1, 200 );

  if g_conf_cache_size > 0 and p_level > c_level_error and sqlcode = 0 then
    g_log_cache.extend;
    g_log_cache(g_log_cache.count) := v_row;
  else
    if g_conf_cache_size > 0 then
      flush_cache;
    end if;
    insert into console_logs values v_row returning log_id into v_row.log_id;
    commit;
  end if;

  return v_row.log_id;
end utl_create_log_entry;

--------------------------------------------------------------------------------

--package inizialization
begin
  utl_set_client_identifier;
  utl_ctx_check_availability;
  utl_load_session_configuration;
end console;
/

declare
  v_count pls_integer;
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count = 0 then
    -- without execute immediate this script will raise an error when the package console is not valid
    select count(*) into v_count from user_scheduler_jobs where job_name = 'CONSOLE_CLEANUP';
    if v_count = 0 then
      dbms_output.put_line('- Job CONSOLE_CLEANUP not found, run creation command with the defaults (purge entries of level info after 30 days)');
      execute immediate 'begin console.cleanup_job_create; end;';
    else
      dbms_output.put_line('- Job CONSOLE_CLEANUP found, no action required');
    end if;
  end if;
end;
/


-- check for errors in package console and for existing context
declare
  v_count                   pls_integer;
  v_context_is_available_yn varchar2(1 byte);
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count > 0 then
    dbms_output.put_line('- Package CONSOLE has errors :-(');
  else
    execute immediate 'select console.context_is_available_yn from dual' into v_context_is_available_yn;
    if v_context_is_available_yn = 'Y' then
      dbms_output.put_line('- Context available :-)');
    else
      dbms_output.put_line('- CONTEXT NOT AVAILABLE :-(');
      dbms_output.put_line('-  | No worries - you can still start with the instrumentation of your code.');
      dbms_output.put_line('-  | Until you have a context, console uses a table as the config storage for the sessions.');
      dbms_output.put_line('-  | When you (or your DBA) have the context created then simply reconnect and check the availability:');
      dbms_output.put_line('-  | select console.context_is_available_yn from dual;');
    end if;
  end if;
end;
/

column "Name"      format a15
column "Line,Col"  format a10
column "Type"      format a10
column "Message"   format a80

select name || case when type like '%BODY' then ' body' end as "Name",
       line || ',' || position as "Line,Col",
       attribute               as "Type",
       text                    as "Message"
  from user_errors
 where name = 'CONSOLE'
 order by name, line, position;

prompt
declare
  v_count           pls_integer;
  v_console_version varchar2(10 byte);
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count = 0 then
    -- without execute immediate this script will raise an error when the package console is not valid
    execute immediate 'select console.version from dual' into v_console_version;
    execute immediate q'[begin console.info('{o,o} CONSOLE v]' || v_console_version || q'[ installed'); end;]';
    dbms_output.put_line('>           ');
    dbms_output.put_line('>   .___.   ');
    dbms_output.put_line('>   {o,o}   ');
    dbms_output.put_line('>   /)__)   Hopefully you have now sharper debugging eyes with');
    dbms_output.put_line('>   -"-"-   CONSOLE v' || v_console_version);
    dbms_output.put_line('>           ');
  end if;
end;
/
prompt




