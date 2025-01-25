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
  v_apex_installed     varchar2(5) := 'FALSE'; -- Do not change (is set dynamically).
  v_utils_public       varchar2(5) := 'FALSE'; -- Make utilities public available (for testing or other usages).
  v_native_compilation boolean     := false;   -- Set this to true on your own risk (in the Oracle cloud you will get likely an "insufficient privileges" error)
  v_count pls_integer;
begin

  execute immediate 'alter session set plsql_warnings = ''enable:all,disable:5004,disable:6005,disable:6006,disable:6009,disable:6010,disable:6027,disable:7203,disable:7207''';
  execute immediate 'alter session set plscope_settings = ''identifiers:all''';
  execute immediate 'alter session set plsql_optimize_level = 3';

  if v_native_compilation then
    execute immediate 'alter session set plsql_code_type=''native''';
  end if;

  select count(*) into v_count from all_objects where object_type = 'SYNONYM' and object_name = 'APEX_EXPORT';
  v_apex_installed := case when v_count = 0 then 'FALSE' else 'TRUE' end;

  execute immediate 'alter session set plsql_ccflags = '''
    || 'APEX_INSTALLED:' || v_apex_installed || ','
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
        conf_id           varchar2 (   4 byte)  not null  ,
        conf_sysdate      date                  not null  ,
        conf_user         varchar2 (  64 byte)            ,
        level_id          number   (   1,0)     not null  ,
        level_name        varchar2 (  10 byte)  not null  ,
        check_interval    number   (   2,0)     not null  ,
        enable_ascii_art  varchar2 (   5 byte)  not null  ,
        client_prefs      varchar2 (4000 byte)            ,
        --
        constraint  console_conf_pk   primary key ( conf_id )                                                                          ,
        constraint  console_conf_ck1  check ( conf_id = 'CONF' )                                                                       ,
        constraint  console_conf_ck2  check ( level_id in (1, 2, 3, 4, 5) )                                                            ,
        constraint  console_conf_ck3  check ( level_name = decode(level_id, 1,'error', 2,'warning', 3,'info', 4,'debug', 5,'trace') )  ,
        constraint  console_conf_ck4  check ( check_interval between 10 and 60 )                                                       ,
        constraint  console_conf_ck5  check ( enable_ascii_art in ('true','false') )
      )
    }';
  else
    dbms_output.put_line('- Table CONSOLE_CONF found, no action required');
  end if;

end;
/

comment on table  console_conf                  is 'Holds the console configuration in a single record.';
comment on column console_conf.conf_id          is 'The primary key - is secured by a check constraint which allows only one record in the table.';
comment on column console_conf.conf_user        is 'The user who configured the console the last time.';
comment on column console_conf.conf_sysdate     is 'The date when console was configured the last time.';
comment on column console_conf.level_id         is 'The defined log level ID.';
comment on column console_conf.level_name       is 'The defined log level name (only for informational purposes).';
comment on column console_conf.check_interval   is 'The number of seconds a session looks for a changed configuration.';
comment on column console_conf.enable_ascii_art is 'Currently used to have more fun with the APEX error handling messages. But who knows...';
comment on column console_conf.client_prefs     is 'Client preferences in CSV format. We save it in this way to have always only one row of configuration data which we read with the result cache.';





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
        log_id             number   (   *,0)               generated by default  on null   as identity (cache 1000),
        log_time           timestamp with local time zone                        not null  ,
        level_id           number   (   1,0)                                     not null  ,
        level_name         varchar2 (  10 byte)                                  not null  ,
        permanent          varchar2 (   1 byte)                                  not null  ,
        scope              varchar2 ( 256 byte)                                            ,
        message            clob                                                            ,
        error_code         number   (  10,0)                                               ,
        call_stack         varchar2 (4000 byte)                                            ,
        session_user       varchar2 (  32 byte)                                            ,
        module             varchar2 (  48 byte)                                            ,
        action             varchar2 (  32 byte)                                            ,
        client_info        varchar2 (  64 byte)                                            ,
        client_identifier  varchar2 (  64 byte)                                            ,
        ip_address         varchar2 (  48 byte)                                            ,
        host               varchar2 (  64 byte)                                            ,
        os_user            varchar2 (  64 byte)                                            ,
        os_user_agent      varchar2 ( 200 byte)                                            ,
        --
        constraint  console_logs_pk  primary key (log_id)                                  ,
        constraint  console_logs_ck  check       (permanent in ('Y','N'))
      )
    }';
  else
    dbms_output.put_line('- Table CONSOLE_LOGS found, no action required');
  end if;

  create_index (null, 'LOG_TIME, LEVEL_ID', 'IX');

end;
/

comment on table  console_logs                   is 'Table for log entries of the package CONSOLE. Column names are mostly driven by the attribute names of SYS_CONTEXT(''USERENV'') and DBMS_SESSION for easier mapping and clearer context.';
comment on column console_logs.log_id            is 'Primary key based on a sequence.';
comment on column console_logs.log_time          is 'Log systimestamp.';
comment on column console_logs.level_id          is 'Level ID. Can be 1 (error), 2 (warning), 3 (info), 4 (debug) or 5 (trace).';
comment on column console_logs.level_name        is 'Level name - for informational purposes only. Indexed columns are only LOG_TIME, LEVEL_ID. If you need more indexes please help yourself.';
comment on column console_logs.permanent         is 'If ''Y'' the log entry will not be deleted when calling CONSOLE.PURGE or CONSOLE.PURGE_ALL.';
comment on column console_logs.scope             is 'The current unit/module in which the log was generated (OWNER.PACKAGE.MODULE.SUBMODULE, line number). Couls also be an external scope provided by the user.';
comment on column console_logs.message           is 'The log message itself.';
comment on column console_logs.error_code        is 'The error code. Is normally the SQLCODE, but could also be a user error code when log entry was coming from an external process (user interface, ETL preprocessing, whatever...)';
comment on column console_logs.call_stack        is 'The call_stack and in case of an error also the error stack and error backtrace. Could also be an external call stack provided by the user.';
comment on column console_logs.session_user      is 'The name of the session user (the user who logged on). This may change during the duration of a database session as Real Application Security sessions are attached or detached. For enterprise users, returns the schema. For other users, returns the database user name. If a Real Application Security session is currently attached to the database session, returns user XS$NULL.';
comment on column console_logs.module            is 'The application name (module). Can be set by an application using the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.action            is 'The action/position in the module. Can be set through the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.client_info       is 'The client information. Can be set by an application using the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.client_identifier is 'The client identifier. Can be set by an application using the DBMS_SESSION.SET_IDENTIFIER procedure, the OCI attribute OCI_ATTR_CLIENT_IDENTIFIER, or Oracle Dynamic Monitoring Service (DMS). This attribute is used by various database components to identify lightweight application users who authenticate as the same database user.';
comment on column console_logs.ip_address        is 'IP address of the machine from which the client is connected. If the client and server are on the same machine and the connection uses IPv6 addressing, then it is set to ::1.';
comment on column console_logs.host              is 'Name of the host machine from which the client is connected.';
comment on column console_logs.os_user           is 'Operating system user name of the client process that initiated the database session.';
comment on column console_logs.os_user_agent     is 'Operating system user agent (for example web browser engine). This information will only be available, if actively provided to one of the console log methods. For APEX we have a plug-in to log client side JavaScript errors, which provides here the user agent of the browser.';




prompt - Type T_CONSOLE (spec)
create or replace type t_console authid definer as object (
  dummy_attribute number                                                                                                        ,
  constructor function t_console return self as result                                                                          ,
  member function  add_param(self in t_console, p_name in varchar2, p_value in varchar2)                       return t_console ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in varchar2)                                        ,
  member function  add_param(self in t_console, p_name in varchar2, p_value in number)                         return t_console ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in number)                                          ,
  member function  add_param(self in t_console, p_name in varchar2, p_value in date)                           return t_console ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in date)                                            ,
  member function  add_param(self in t_console, p_name in varchar2, p_value in timestamp)                      return t_console ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in timestamp)                                       ,
  member function  add_param(self in t_console, p_name in varchar2, p_value in timestamp with time zone)       return t_console ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in timestamp with time zone)                        ,
  member function  add_param(self in t_console, p_name in varchar2, p_value in timestamp with local time zone) return t_console ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in timestamp with local time zone)                  ,
  member function  add_param(self in t_console, p_name in varchar2, p_value in interval year to month)         return t_console ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in interval year to month)                          ,
  member function  add_param(self in t_console, p_name in varchar2, p_value in interval day to second)         return t_console ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in interval day to second)                          ,
  member function  add_param(self in t_console, p_name in varchar2, p_value in boolean)                        return t_console ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in boolean)                                         ,
  member function  add_param(self in t_console, p_name in varchar2, p_value in clob)                           return t_console ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in clob)                                            ,
  member function  add_param(self in t_console, p_name in varchar2, p_value in xmltype)                        return t_console ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in xmltype)                                         );
/
prompt - Package CONSOLE (spec)
create or replace package console authid definer is

c_name    constant varchar2 ( 30 byte ) := 'Oracle Instrumentation Console'       ;
c_version constant varchar2 ( 10 byte ) := '1.2.1'                                ;
c_url     constant varchar2 ( 36 byte ) := 'https://github.com/ogobrecht/console' ;
c_license constant varchar2 (  3 byte ) := 'MIT'                                  ;
c_author  constant varchar2 ( 15 byte ) := 'Ottmar Gobrecht'                      ;


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
-- PUBLIC SIMPLE TYPES
--------------------------------------------------------------------------------

subtype t_num  is number;
subtype t_int  is pls_integer;
subtype t_1b   is varchar2 (    1 byte);
subtype t_2b   is varchar2 (    2 byte);
subtype t_4b   is varchar2 (    4 byte);
subtype t_8b   is varchar2 (    8 byte);
subtype t_16b  is varchar2 (   16 byte);
subtype t_32b  is varchar2 (   32 byte);
subtype t_64b  is varchar2 (   64 byte);
subtype t_128b is varchar2 (  128 byte);
subtype t_256b is varchar2 (  256 byte);
subtype t_512b is varchar2 (  512 byte);
subtype t_1kb  is varchar2 ( 1024 byte);
subtype t_2kb  is varchar2 ( 2048 byte);
subtype t_4kb  is varchar2 ( 4096 byte);
subtype t_8kb  is varchar2 ( 8192 byte);
subtype t_16kb is varchar2 (16384 byte);
subtype t_32kb is varchar2 (32767 byte);


--------------------------------------------------------------------------------
-- PUBLIC COMPLEX TYPES
--------------------------------------------------------------------------------

type t_client_prefs_row is record(
  client_identifier t_64b   ,
  check_interval    integer ,
  exit_sysdate      date    ,
  level_id          integer ,
  level_name        t_16b   ,
  call_stack        t_8b    ,
  user_env          t_8b    ,
  apex_env          t_8b    ,
  cgi_env           t_8b    ,
  console_env       t_8b    );
type t_attribute_value_row is record(
  attribute t_128b ,
  value     t_4kb  );
type t_client_prefs_tab      is table of t_client_prefs_row;
type t_client_prefs_tab_i    is table of t_client_prefs_row index by pls_integer;
type t_attribute_value_tab   is table of t_attribute_value_row;
type t_attribute_value_tab_i is table of t_attribute_value_row index by pls_integer;
type t_vc2_tab               is table of t_32kb;
type t_vc2_tab_i             is table of t_32kb index by pls_integer;


--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------

c_level_error            constant t_int   :=      1 ;
c_level_warning          constant t_int   :=      2 ;
c_level_info             constant t_int   :=      3 ;
c_level_debug            constant t_int   :=      4 ;
c_level_trace            constant t_int   :=      5 ;
c_check_interval_min     constant t_int   :=      3 ; -- seconds
c_check_interval_default constant t_int   :=     10 ; -- seconds
c_check_interval_max     constant t_int   :=     60 ; -- seconds
c_duration_min           constant t_int   :=      1 ; -- minutes
c_duration_default       constant t_int   :=     60 ; -- minutes
c_duration_max           constant t_int   :=   1440 ; -- minutes (1 day)
c_enable_ascii_art       constant boolean :=   true ;


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
{{#}}### Saved Error Stack

- PLAYGROUND.SOME_API.DO_STUFF.SUB1.SUB2.SUB3, line 14 (line 11, ORA-20777 Assertion failed: Demo)
- PLAYGROUND.SOME_API.DO_STUFF.SUB1.SUB2, line 22 (line 19)
- PLAYGROUND.SOME_API.DO_STUFF.SUB1, line 30 (line 27)
- PLAYGROUND.SOME_API.DO_STUFF, line 38 (line 35, ORA-01403 no data found)

{{#}}### Call Stack

- PLAYGROUND.SOME_API.DO_STUFF, line 38
- __anonymous_block, line 2

{{#}}### Error Stack

- ORA-01403 no data found
- ORA-06512 at "PLAYGROUND.SOME_API", line 31
- ORA-20777 Assertion failed: Test assertion with line break.
- ORA-06512 at "PLAYGROUND.SOME_API", line 23
- ORA-06512 at "PLAYGROUND.SOME_API", line 15
- ORA-06512 at "PLAYGROUND.CONSOLE", line 750
- ORA-06512 at "PLAYGROUND.SOME_API", line 11
- ORA-06512 at "PLAYGROUND.SOME_API", line 19
- ORA-06512 at "PLAYGROUND.SOME_API", line 27

{{#}}### Error Backtrace

- PLAYGROUND.SOME_API, line 31
- PLAYGROUND.SOME_API, line 23
- PLAYGROUND.SOME_API, line 15
- PLAYGROUND.CONSOLE, line 750
- PLAYGROUND.SOME_API, line 11
- PLAYGROUND.SOME_API, line 19
- PLAYGROUND.SOME_API, line 27
- PLAYGROUND.SOME_API, line 35
```

**/

--------------------------------------------------------------------------------

procedure error (
  p_message         in clob     default null  , -- The log message itself
  p_permanent       in boolean  default false , -- Should the log entry be permanent (not deleted by purge methods)
  p_call_stack      in boolean  default true  , -- Include call stack
  p_apex_env        in boolean  default false , -- Include APEX environment
  p_cgi_env         in boolean  default false , -- Include CGI environment
  p_console_env     in boolean  default false , -- Include Console environment
  p_user_env        in boolean  default false , -- Include user environment
  p_user_agent      in varchar2 default null  , -- User agent of browser or other client technology
  p_user_scope      in varchar2 default null  , -- Override PL/SQL scope
  p_user_error_code in integer  default null  , -- Override PL/SQL error code
  p_user_call_stack in varchar2 default null    -- Override PL/SQL call stack
);
/**

Log a message with the level 1 (error).

**/

function error (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default true  ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 1 (error). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure warn (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  );
/**

Log a message with the level 2 (warning).

**/

function warn (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 2 (warning). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure info (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  );
/**

Log a message with the level 3 (info).

**/

function info (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 3 (info). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure log (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  );
/**

Log a message with the level 3 (info).

**/

function log (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 3 (info). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure debug (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  );
/**

Log a message with the level 4 (debug).

**/

function debug (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 4 (debug). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure trace (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default true  ,
  p_apex_env        in boolean  default true  ,
  p_cgi_env         in boolean  default true  ,
  p_console_env     in boolean  default true  ,
  p_user_env        in boolean  default true  ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  );
/**

Log a message with the level 5 (trace).

**/

function trace (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default true  ,
  p_apex_env        in boolean  default true  ,
  p_cgi_env         in boolean  default true  ,
  p_console_env     in boolean  default true  ,
  p_user_env        in boolean  default true  ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 5 (trace). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure count ( p_label in varchar2 default null );
/**

Creates a new counter with a value of one or adds one to an existing counter.

Does not depend on a log level, can be used anywhere to count things.

EXAMPLE

```sql
declare
  v_counter varchar2(30) := 'Processing xyz';
begin
  for i in 1 .. 10 loop
    console.count(v_counter);
  end loop;
  console.count_current(v_counter); -- without optional message

  for i in 1 .. 100 loop
    console.count(v_counter);
  end loop;
  console.count_current(v_counter, 'end of step two');

  for i in 1 .. 1000 loop
    console.count(v_counter);
  end loop;
  console.count_end(v_counter, 'end of step three');
end;
{{/}}
```

This will produce the following log messages in the table CONSOLE_LOGS when your
current log level is 3 (info) or higher:

- Processing xyz: 10
- Processing xyz: 110 - end of step two
- Processing xyz: 1110 - end of step three

**/

--------------------------------------------------------------------------------

procedure count_reset ( p_label in varchar2 default null );
/**

Reset an existing counter or create a new one.

Does not depend on a log level, can be used anywhere to count things.

Also see procedure `count` above.

**/

--------------------------------------------------------------------------------

procedure count_current (
  p_label   in varchar2 default null ,
  p_message in varchar2 default null );
/**

Log the current value of a counter, if the sessions log level is greater or
equal 3 (info).

Also see procedure `count` above.

**/

--------------------------------------------------------------------------------

procedure count_end (
  p_label   in varchar2 default null ,
  p_message in varchar2 default null );
/**

Log the current value of a counter, if the sessions log level is greater or
equal 3 (info). Delete the counter.

Also see procedure `count` above.

**/

--------------------------------------------------------------------------------

function count_current (
  p_label   in varchar2 default null )
return t_int;
/**

Returns the current counter value or null, if the given label does not exist.

Does not depend on a log level, can be used anywhere to count things.

Also see procedure `count` above. The following example does not use the
optional label, therefore the implicit label used in the background will be
`default`. As we get only the value back from the funtion and we need only one
counter at the same time this is ok for us here and it keeps the code simple.


EXAMPLE

```sql
set serveroutput on

begin
  console.print('Counting nonsense...');
  for i in 1 .. 1000 loop
    if mod(i, 3) = 0 then
      console.count;
    end if;
  end loop;
  console.printf('Current value: %s', console.count_current );

  console.count_reset;
  for i in 1 .. 10 loop
    console.count;
  end loop;
  console.printf('Final value: %s', console.count_end );
end;

{{/}}
```

This will print something like the following to the server output:

```
Counting nonsense...
Current value: 333
Final value: 10
```

**/

--------------------------------------------------------------------------------

function count_end (
  p_label   in varchar2 default null )
return t_int;
/**

Returns the current counter value or null, if the given label does not exist.
Deletes the counter.

Does not depend on a log level, can be used anywhere to count things.

Also see function `count_current` above.

**/

--------------------------------------------------------------------------------

procedure time ( p_label in varchar2 default null );
/**

Create and a new timer. If the timer is already existing it will start again
with the current local timestamp.

Does not depend on a log level, can be used anywhere to measure runtime.

EXAMPLE

```sql
declare
  v_timer varchar2(30) := 'Processing xyz';
begin

  --basic usage
  console.time;
  sys.dbms_session.sleep(0.1);
  console.time_end; -- without optional label and message

  console.time(v_timer);

  sys.dbms_session.sleep(0.1);
  console.time_current(v_timer); -- without optional message

  sys.dbms_session.sleep(0.1);
  console.time_current(v_timer, 'end of step two');

  sys.dbms_session.sleep(0.1);
  console.time_end(v_timer, 'end of step three');

end;
{{/}}
```

This will produce the following log messages in the table CONSOLE_LOGS when your
current log level is 3 (info) or higher:

- default: 00:00:00.102508
- Processing xyz: 00:00:00.108048
- Processing xyz: 00:00:00.212045 - end of step two
- Processing xyz: 00:00:00.316084 - end of step three

**/

--------------------------------------------------------------------------------

procedure time_reset ( p_label in varchar2 default null );
/**

Reset an existing timer or create a new one.

Does not depend on a log level, can be used anywhere to measure runtime.

Also see procedure `time` above.

**/

--------------------------------------------------------------------------------

procedure time_current (
  p_label   in varchar2 default null ,
  p_message in varchar2 default null );
/**

Log the elapsed time, if the sessions log level is greater or equal 3 (info).

Can be called multiple times - use `console.time_end` to log the elapsed time
and delete the timer.

Also see procedure `time` above.

**/

--------------------------------------------------------------------------------

procedure time_end (
  p_label   in varchar2 default null ,
  p_message in varchar2 default null );
/**

Log the elapsed time and delete the timer, if the sessions log level is greater
or equal 3 (info).

Also see procedure `time` above.

**/

--------------------------------------------------------------------------------

function time_current ( p_label in varchar2 default null ) return varchar2;
/**

Returns the elapsed time as varchar in the format 00:00:00.000000 or null, if
the given label does not exist.

Does not depend on a log level, can be used anywhere to measure runtime.

Can be called multiple times - use `console.time_end` to return the elapsed time
and delete the timer.

Also see procedure `time` above. The following example does not use the optional
label, therefore the implicit label used in the background will be `default`. As
we get only the runtime back from the funtion in the format 00:00:00.000000 and
we need only one timer at the same time this is ok for us here and it keeps the
code simple.

EXAMPLE

```sql
set serveroutput on

begin
  console.time;

  console.print('Processing step one...');
  sys.dbms_session.sleep(0.1);
  console.printf('Elapsed time: %s', console.time_current);

  console.print('Processing step two...');
  sys.dbms_session.sleep(0.1);
  console.printf('Elapsed time: %s', console.time_current);

  console.print('Processing step three...');
  sys.dbms_session.sleep(0.1);
  console.printf('Elapsed time: %s', console.time_end);
end;
{{/}}
```

This will result in something like the following output:

```
Processing step one...
Elapsed time: 00:00:00.105398
Processing step two...
Elapsed time: 00:00:00.209267
Processing step three...
Elapsed time: 00:00:00.313301
```

**/

--------------------------------------------------------------------------------

function time_end ( p_label in varchar2 default null ) return varchar2;
/**

Returns the elapsed time as varchar in the format 00:00:00.000000 or null, if
the given label does not exist. Deletes the timer.

Does not depend on a log level, can be used anywhere to measure runtime.

Also see function `time_current` above.

**/

--------------------------------------------------------------------------------

procedure table# (
  p_data_cursor       in sys_refcursor         ,
  p_comment           in varchar2 default null ,
  p_include_row_num   in boolean  default true ,
  p_max_rows          in integer  default 100  ,
  p_max_column_length in integer  default 1000 );
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
  p_expression in boolean,
  p_message    in varchar2
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
    'x should be less then y (x=' || to_char(x) || ', y=' || to_char(y) || ')'
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

procedure assertf (
  p_expression in boolean               ,
  p_message    in varchar2              ,
  p0           in varchar2 default null ,
  p1           in varchar2 default null ,
  p2           in varchar2 default null ,
  p3           in varchar2 default null ,
  p4           in varchar2 default null ,
  p5           in varchar2 default null ,
  p6           in varchar2 default null ,
  p7           in varchar2 default null ,
  p8           in varchar2 default null ,
  p9           in varchar2 default null
);
/**

If the given expression evaluates to false, an error is raised with the given
formatted message.

EXAMPLE

```sql
declare
  x number := 5;
  y number := 3;
begin
  console.assertf(
    x < y,
    'x should be less then y (x=%s, y=%s)',
    to_char(x),
    to_char(y)
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

procedure add_param ( p_name in varchar2, p_value in varchar2                       );
/**

Add a parameter to the package internal parameter collection which will be
included in the next log call (error, warn, info, log, debug or trace)

The procedure is overloaded to support different parameter types. It is also
overloaded to support a Builder-Pattern-Style chaining.

VARCHAR and CLOB parameters are shortened to 2000 characters and additionally
escaped for Markdown table columns (replacing all line endings with whitespace
and the pipe character with `&#124;`). If you need your full parameter text then
please use the `p_message` CLOB parameter in the log methods error, warn, info,
log, debug and trace to do your own parameter handling.

```sql
procedure add_param ( p_name in varchar2, p_value in varchar2                       );
procedure add_param ( p_name in varchar2, p_value in number                         );
procedure add_param ( p_name in varchar2, p_value in date                           );
procedure add_param ( p_name in varchar2, p_value in timestamp                      );
procedure add_param ( p_name in varchar2, p_value in timestamp with time zone       );
procedure add_param ( p_name in varchar2, p_value in timestamp with local time zone );
procedure add_param ( p_name in varchar2, p_value in interval year to month         );
procedure add_param ( p_name in varchar2, p_value in interval day to second         );
procedure add_param ( p_name in varchar2, p_value in boolean                        );
procedure add_param ( p_name in varchar2, p_value in clob                           );
procedure add_param ( p_name in varchar2, p_value in xmltype                        );
```

EXAMPLE

```sql
--create demo procedure
create or replace procedure demo_proc (
  p_01 varchar2                       ,
  p_02 number                         ,
  p_03 date                           ,
  p_04 timestamp                      ,
  p_05 timestamp with time zone       ,
  p_06 timestamp with local time zone ,
  p_07 interval year to month         ,
  p_08 interval day to second         ,
  p_09 boolean                        ,
  p_10 clob                           ,
  p_11 xmltype                        )
is
begin
  raise_application_error(-20999, 'Demo Error.');
exception
  when others then
    console.add_param('p_01', p_01);
    console.add_param('p_02', p_02);
    console.add_param('p_03', p_03);
    console.add_param('p_04', p_04);
    console.add_param('p_05', p_05);
    console.add_param('p_06', p_06);
    console.add_param('p_07', p_07);
    console.add_param('p_08', p_08);
    console.add_param('p_09', p_09);
    console.add_param('p_10', p_10);
    console.add_param('p_11', p_11);

    -- Alternatively, chain the invocations like this:
    console.add_param('p_12', p_12)
      .add_param('p_13', p_13)
      .add_param('p_14', p_14)
      .add_param('p_15', p_15)
      .add_param('p_16', p_16);

    console.error('Ooops, something went wrong');
    raise;
end demo_proc;
{{/}}

--run demo procedure
begin
  demo_proc (
    p_01 => 'test vc2'                             ,
    p_02 => 1.23                                   ,
    p_03 => sysdate                                ,
    p_04 => systimestamp                           ,
    p_05 => systimestamp                           ,
    p_06 => localtimestamp                         ,
    p_07 => interval '4-2' year to month           ,
    p_08 => interval '7 6:12:42.123' day to second ,
    p_09 => true                                   ,
    p_10 => to_clob('test clob')                   ,
    p_11 => xmltype('<test_xml/>')                 );
end;
{{/}}
```

**/
function add_param ( p_name  in varchar2 ,p_value in varchar2      ) return t_console;
procedure add_param ( p_name in varchar2, p_value in number                         );
function add_param ( p_name  in varchar2 ,p_value in number        ) return t_console;
procedure add_param ( p_name in varchar2, p_value in date                           );
function add_param ( p_name  in varchar2 ,p_value in date          ) return t_console;
procedure add_param ( p_name in varchar2, p_value in timestamp                      );
function add_param ( p_name  in varchar2 ,p_value in timestamp     ) return t_console;
procedure add_param ( p_name in varchar2, p_value in timestamp with time zone       );
function add_param ( p_name  in varchar2 ,p_value in timestamp with time zone ) return t_console;
procedure add_param ( p_name in varchar2, p_value in timestamp with local time zone );
function add_param ( p_name  in varchar2 ,p_value in timestamp with local time zone ) return t_console;
procedure add_param ( p_name in varchar2, p_value in interval year to month         );
function add_param ( p_name  in varchar2 ,p_value in interval year to month ) return t_console;
procedure add_param ( p_name in varchar2, p_value in interval day to second         );
function add_param ( p_name  in varchar2 ,p_value in interval day to second ) return t_console;
procedure add_param ( p_name in varchar2, p_value in boolean                        );
function add_param ( p_name  in varchar2 ,p_value in boolean       ) return t_console;
procedure add_param ( p_name in varchar2, p_value in clob                           );
function add_param ( p_name  in varchar2 ,p_value in clob          ) return t_console;
procedure add_param ( p_name in varchar2, p_value in xmltype                        );
function add_param ( p_name  in varchar2 ,p_value in xmltype       ) return t_console;

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

Formats a message with the following rules:

1. Replace all occurrences of `%0` .. `%9` by id with the corresponding
   parameters `p0` .. `p9`
2. Replace `%n` with new lines (line feed character)
3. Replace all occurrences of `%s` in positional order with the corresponding
   parameters using sys.utl_lms.format_message - also see the [Oracle
   docs](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/UTL_LMS.html#GUID-88FFBFB6-FCA4-4951-884B-B0275BD5DF44).

**/

--------------------------------------------------------------------------------

procedure action ( p_action in varchar2 );
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
  p_module in varchar2,
  p_action in varchar2 default null
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
  p_dynamic_action in apex_plugin.t_dynamic_action ,
  p_plugin         in apex_plugin.t_plugin         )
return apex_plugin.t_dynamic_action_render_result;
/**

Used for the APEX plugin to capture frontend JavaScript errors.

If you plan to use the plugin make sure you have either console installed in
your APEX parsing schema or a synonym named `console` for it as this function is
referenced in the plug-in as a callback to `console.apex_plugin_render`.

**/
function apex_plugin_ajax (
  p_dynamic_action in apex_plugin.t_dynamic_action ,
  p_plugin         in apex_plugin.t_plugin         )
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
  p_level            in integer default null , -- Level 1 (error), 2 (warning), 3 (info), 4 (debug) or 5 (trace).
  p_check_interval   in integer default null , -- The number of seconds a session looks for a changed configuration. Allowed values: 1 to 60 seconds.
  p_enable_ascii_art in boolean default null   -- Currently used to have more fun with the APEX error handling messages. But who knows...
);
/**

Set the global console configuration.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING GLOBAL PREFERENCES.

EXAMPLE

```sql
--set all sessions to level warning
exec console.conf(p_level => 2);
--or
exec console.conf(p_level => console.c_level_warning);

--set multiple options at once
begin
  console.conf(
    p_level             => console.c_level_info,
    p_check_interval    => 10
  );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure init (
  p_client_identifier in varchar2                                  , -- The client identifier provided by the application or console itself.
  p_level             in integer  default c_level_info             , -- Level 2 (warning), 3 (info), 4 (debug) or 5 (trace).
  p_duration          in integer  default c_duration_default       , -- The number of minutes the session should be in client preferences mode. Allowed values: 1 to 1440 minutes (24 hours).
  p_check_interval    in integer  default c_check_interval_default , -- The number of seconds a session looks for a changed configuration. Allowed values: 1 to 60 seconds.
  p_call_stack        in boolean  default false                    , -- Should the call stack be included.
  p_user_env          in boolean  default false                    , -- Should the user environment be included.
  p_apex_env          in boolean  default false                    , -- Should the APEX environment be included.
  p_cgi_env           in boolean  default false                    , -- Should the CGI environment be included.
  p_console_env       in boolean  default false                      -- Should the console environment be included.
);
/**

Init/set the preferences for a specific session/client_identifier and duration.

To avoid spoiling the context with very long input the parameter
p_client_identifier is truncated after 64 characters before using it.

For easier usage there is an overloaded procedure available which uses always
your own session/client_identifier.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING CLIENT PREFERENCES.

EXAMPLES

```sql
-- Dive into your own session with the default log level of 3 (info) and the
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
  p_level          in integer default c_level_info             , -- Level 2 (warning), 3 (info), 4 (debug) or 5 (trace).
  p_duration       in integer default c_duration_default       , -- The number of minutes the session should be in client preferences mode. Allowed values: 1 to 1440 minutes (24 hours).
  p_check_interval in integer default c_check_interval_default , -- The number of seconds a session in logging mode looks for a changed configuration. Allowed values: 1 to 60 seconds.
  p_call_stack     in boolean default false                    , -- Should the call stack be included.
  p_user_env       in boolean default false                    , -- Should the user environment be included.
  p_apex_env       in boolean default false                    , -- Should the APEX environment be included.
  p_cgi_env        in boolean default false                    , -- Should the CGI environment be included.
  p_console_env    in boolean default false                      -- Should the console environment be included.
);
/**

An overloaded procedure for easier initialization of the own
session/client_identifier in an development IDE.

**/

procedure exit (
  p_client_identifier in varchar2 default my_client_identifier -- The client identifier provided by the application or console itself.
);
/**

Exit/unset the preferences for a specific session/client_identifier.

If you exit/unset your own client preferencs then this has an immediate effect
as we can unset the preferences in our package state. If you exit another
session/client_identifier then it can take some seconds until the other
session/client_identifier is reloading the configuration from the context (if
available) or the client_prefs table. The default check interval for a changed
configuration is ten seconds.

Exit/unset the preferences means also the cached log entries will be flushed to
the logging table CONSOLE_LOGS. If you do not need the cached entries you can
delete them in advance by calling the `clear` procedure.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING CLIENT PREFERENCES.

**/

procedure exit_all;
/**

Exit/unset all client preferences in one go.

EXAMPLE

```sql
exec console.exit_all;
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

procedure generate_param_trace (
  p_program in varchar2              , -- The package and/or program name ('some_api.do_stuff').
  p_level   in pls_integer default 3   -- The level you want to use for the parameter tracing.
);
/**

Generates parameter tracing code for you.

Writes to the server output - switch it on to see results. Input for parameter
`p_program` will be uppercased and spaces will be replaced by underscores. The
default for parameter `p_level` is 3 (info). These calls are all equivalent:

```sql
set serveroutput on
exec console.generate_param_trace('some api.do stuff');
exec console.generate_param_trace('Some_API.do_stuff', 3);
exec console.generate_param_trace('SOME_API.DO_STUFF', console.c_level_info);
begin
  console.generate_param_trace(
    p_program => 'SOME_API.DO_STUFF',
    p_level   => console.c_level_info
  );
end;
{{/}}
```

EXAMPLE 1

```sql
create or replace function demo_func (
  p_01 in     varchar2 ,
  p_02 in     number   ,
  p_03 in     date     )
return varchar2 is
begin
  null; --YOUR CODE HERE
end demo_func;
{{/}}
set serveroutput on
exec console.generate_param_trace('demo func');
```

This will output something like:

```sql
--------------------------------------------------------
-- Signature not recoverable with user_arguments
-- We start with declare for easier formatting
-- Your Program : DEMO_FUNC
-- Package Name : -
-- Object Name  : DEMO_FUNC
--------------------------------------------------------
declare
  procedure console_add_in_params is
  begin
    console.add_param('p_01', p_01);
    console.add_param('p_02', p_02);
    console.add_param('p_03', p_03);
  end console_add_in_params;
  procedure console_add_out_params is
  begin
    console.add_param('your_return_value', your_return_value);
  end console_add_out_params;
begin
  console_add_in_params;
  console.info('ENTER');
  --------------------
  -- YOUR CODE HERE
  --------------------
  console_add_out_params;
  console.info('LEAVE');
  ----------------------
  -- YOUR RETURN HERE
  ----------------------
exception
  when others then
    console_add_out_params;
    console.error;
    raise;
end;
{{/}}
```

As you can see in the procedure `console_add_out_params` you have to align the
name of your return variable (`console.add_param('your_return_value',
your_return_value)`).

EXAMPLE 2

```sql
create or replace procedure demo_proc (
  p_01 in     varchar2                       ,
  p_02 in     number                         ,
  p_03 in     date                           ,
  p_04 in     timestamp                      ,
  p_05 in     timestamp with time zone       ,
  p_06 in     timestamp with local time zone ,
  p_07 in     interval year to month         ,
  p_08 in     interval day to second         ,
  p_09 in     boolean                        ,
  p_10 in out clob                           ,
  p_11 in out xmltype                        ,
  p_12 in out console.t_client_prefs_row     ,
  p_13 in out console.t_client_prefs_tab     )
is
begin
  null; --YOUR CODE HERE
end demo_proc;
{{/}}
set serveroutput on
exec console.generate_param_trace('demo proc');
```

This will output something like:

```sql
--------------------------------------------------------
-- Signature not recoverable with user_arguments
-- We start with declare for easier formatting
-- Your Program : DEMO_PROC
-- Package Name : -
-- Object Name  : DEMO_PROC
--------------------------------------------------------
declare
  procedure console_add_in_params is
  begin
    console.add_param('p_01', p_01);
    console.add_param('p_02', p_02);
    console.add_param('p_03', p_03);
    console.add_param('p_04', p_04);
    console.add_param('p_05', p_05);
    console.add_param('p_06', p_06);
    console.add_param('p_07', p_07);
    console.add_param('p_08', p_08);
    console.add_param('p_09', p_09);
    console.add_param('p_10', p_10);
    console.add_param('p_11', p_11);
    --unsupported data type PL/SQL RECORD: console.add_param('p_12', p_12);
    --unsupported data type TABLE: console.add_param('p_13', p_13);
  end console_add_in_params;
  procedure console_add_out_params is
  begin
    console.add_param('p_10', p_10);
    console.add_param('p_11', p_11);
    --unsupported data type PL/SQL RECORD: console.add_param('p_12', p_12);
    --unsupported data type TABLE: console.add_param('p_13', p_13);
  end console_add_out_params;
begin
  console_add_in_params;
  console.info('ENTER');
  --------------------
  -- YOUR CODE HERE
  --------------------
  console_add_out_params;
  console.info('LEAVE');
exception
  when others then
    console_add_out_params;
    console.error;
    raise;
end;
{{/}}
```

As you can see in the output, unsupported data types for `console.add_param`
will be commented out.

**/

--------------------------------------------------------------------------------

function split_to_table (
  p_string in varchar2             , -- The string to split into a table.
  p_sep    in varchar2 default ','   -- The separator.
) return t_vc2_tab pipelined;
/**

Splits a string into a (pipelined) SQL table of varchar2.

If the separator is null the string will be splitted into its characters.

EXAMPLE

```sql
select * from console.split_to_table('1,2,3');
```

| COLUMN_VALUE |
|--------------|
| 1            |
| 2            |
| 3            |

**/

--------------------------------------------------------------------------------

function split (
  p_string in varchar2             , -- The string to split into an array.
  p_sep    in varchar2 default ','   -- The separator.
) return t_vc2_tab_i;
/**

Splits a string into a PL/SQL associative array.

If the separator is null the string will be splitted into its characters.

EXAMPLE

```sql
set serveroutput on
declare
  v_array console.t_vc2_tab_i;
begin
  v_array := console.split('A,B,C');
  for i in 1 .. v_array.count loop
    console.print(i||': '||v_array(i));
  end loop;
end;
{{/}}

1: A
2: B
3: C
```

**/

--------------------------------------------------------------------------------

function join (
  p_table in t_vc2_tab_i          , -- The PL/SQL array to join into a string.
  p_sep   in varchar2 default ','   -- The separator.
) return varchar2;
/**

Joins a PL/SQL associative array into a string.

**/

--------------------------------------------------------------------------------

function to_yn ( p_bool in boolean ) return varchar2;
/**

Converts a boolean value to a string.

Returns `Y` when the input is true, `N` when the input is false and null when
the input is null.

**/

--------------------------------------------------------------------------------

function to_string ( p_bool in boolean ) return varchar2;
/**

Converts a boolean value to a string.

Returns `true` when the input is true, `false` when the input is false and null
when the input is null.

**/

--------------------------------------------------------------------------------

function to_bool ( p_string in varchar2 ) return boolean;
/**

Converts a string to a boolean value.

Returns true when the uppercased, trimmed input is `TRUE`, `Y`, `YES` or `1`.
When the input is `FALSE`, `N`, `NO` or `0` false is returned. In all other
cases null is returned.

**/

--------------------------------------------------------------------------------

function to_html_table (
  p_data_cursor       in sys_refcursor         ,
  p_comment           in varchar2 default null ,
  p_include_row_num   in boolean  default true ,
  p_max_rows          in integer  default 100  ,
  p_max_column_length in integer  default 1000 )
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

function to_md_code_block (
  p_text in varchar2 )
return varchar2;
/**

Converts the given text to a Markdown code block by indent each line with four
spaces.

**/

--------------------------------------------------------------------------------

function to_md_tab_header (
  p_key   in varchar2 default 'Attribute' ,
  p_value in varchar2 default 'Value'     )
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
  p_key              in varchar2               ,
  p_value            in varchar2               ,
  p_value_max_length in integer  default 1000  ,
  p_show_null_values in boolean  default false )
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
  p_value                   in number            ,
  p_scale                   in number default 1  ,
  p_width_block_characters  in number default 25 ,
  p_fill_scale              in number default 0
) return varchar2 deterministic;
/**

Returns a text bar consisting of unicode block characters.

You can build simple text based bar charts with it. Not all fonts implement
clean block characters, so the result depends a little bit on the font. The
unicode block characters can have eight different widths from 1/8 up to 8/8 -
together with the default width of a bar chart of 25 characters you can show bar
charts with a precision of 0.5 percent - that is not bad for a text based bar
chart...

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

procedure printf (
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
  p9        in varchar2 default null );
/**

A shorthand for

```
begin
  console.print(console.format('A string with %s %s.', 'dynamic', 'content'));
  --is equivalent to
  console.printf('A string with %s %s.', 'dynamic', 'content');
end;
{{/}}
```

Also see [console.format](#function-format)

**/

--------------------------------------------------------------------------------

function  runtime ( p_start in timestamp ) return varchar2;
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

  dbms_output.put_line('Runtime: ' || console.runtime(v_start));
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function runtime_seconds ( p_start in timestamp ) return number;
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
    'Runtime (seconds): ' || to_char(console.runtime_seconds(v_start)) );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function runtime_milliseconds ( p_start in timestamp ) return number;
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
    'Runtime (milliseconds): ' || to_char(console.runtime_milliseconds(v_start)) );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function level_name (p_level in integer) return varchar2 deterministic;
/**

Returns the level name for a given level id and null, if the level is not
between 0 and 4.

**/

--------------------------------------------------------------------------------

function scope return varchar2;
/**

Get the current scope (method, line number) from the call stack.

Is used internally by console to automatically provide the scope attribute for a
log entry.

**/

--------------------------------------------------------------------------------

function call_stack return varchar2;
/**

Get the current call stack (and error stack/backtrace, if available).

Is used internally by console to provide the call stack for a log entry when
requested by one of the logging methods (which is the default for error and
trace).

**/

--------------------------------------------------------------------------------

function apex_env return clob;
/**

Get the current APEX environment.

Is used internally by console to provide the APEX environment for a log entry
when requested by one of the logging methods.

**/

--------------------------------------------------------------------------------

function cgi_env return varchar2;
/**

Get the current CGI environment.

Is used internally by console to provide the CGI environment for a log entry
when requested by one of the logging methods.

**/

--------------------------------------------------------------------------------

function user_env return varchar2;
/**

Get the current user environment.

Is used internally by console to provide the user environment for a log entry
when requested by one of the logging methods.

**/

--------------------------------------------------------------------------------

function console_env return varchar2;
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
  dbms_output.put_line('Runtime (seconds): ' || to_char(console.runtime_seconds(v_start)));
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

function status return t_attribute_value_tab pipelined;
/**

View the current package status (config, number entries cache/timer/counter,
version etc.).

EXAMPLE

```sql
select * from console.status();
```

**/

--------------------------------------------------------------------------------

function conf return t_attribute_value_tab pipelined;
/**

View the global console configuration.

EXAMPLE

```sql
select * from console.conf();
```

**/

--------------------------------------------------------------------------------

function client_prefs return t_client_prefs_tab pipelined;
/**

View the client preferences.

EXAMPLE

```sql
select * from console.client_prefs();
```

**/

--------------------------------------------------------------------------------
procedure purge (
  p_min_level in integer default c_level_info, -- Delete log entries greater or equal the given level.
  p_min_days  in number  default 30 );         -- Delete log entries older than the given minimum days.
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

procedure purge_job_create (
  p_repeat_interval in varchar2 default 'FREQ=DAILY;BYHOUR=1;' , -- See the Oracle docs: https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/scheduling-jobs-with-oracle-scheduler.html#GUID-10B1E444-8330-4EC9-85F8-9428D749F7D5
  p_min_level       in integer  default c_level_info           , -- Delete log entries greater or equal the given level.
  p_min_days        in number   default 30                       -- Delete log entries older than the given minimum days.
);
/**
Creates a cleanup job which deletes old log entries from console_logs and stale
debug sessions from console_client_prefs.
**/
procedure purge_job_drop;    /** Drops the cleanup job (if it exists).    **/
procedure purge_job_enable;  /** Enables the cleanup job (if it exists).  **/
procedure purge_job_disable; /** Disables the cleanup job (if it exists). **/
procedure purge_job_run;     /** Runs the cleanup job (if it exists).     **/

--------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS (only visible when ccflag `utils_public` is set to true)
--------------------------------------------------------------------------------

$if $$utils_public $then

procedure utl_set_client_identifier;

procedure utl_set_session_conf;

procedure utl_set_conf (
  p_conf console_conf%rowtype );

procedure utl_set_client_prefs (
  p_prefs varchar2 );

function utl_get_conf return console_conf%rowtype result_cache;

function utl_get_client_prefs (
  p_all_prefs_csv varchar2     ,
  p_client_identifier varchar2 )
return t_client_prefs_row;

function utl_get_client_prefs_tab return t_client_prefs_tab_i;

function utl_escape_md_tab_text (
  p_text varchar2 )
return varchar2;

function utl_last_error return varchar2;

function utl_logging_is_enabled (
  p_level integer )
return boolean;

function utl_normalize_label (
  p_label varchar2 )
return varchar2;

function utl_replace_linebreaks (
  p_text varchar2                     ,
  p_replace_with varchar2 default ' ' )
return varchar2;

function utl_get_clean_client_prefs_csv (
  p_client_identifier_to_remove in varchar2           default null ,
  p_client_prefs_to_append      in t_client_prefs_row default null )
return varchar2;

function utl_client_prefs_to_csv (
  p_client_prefs t_client_prefs_row )
return varchar2;

function utl_csv_to_client_prefs (
  p_csv varchar2 ) return t_client_prefs_row;

function utl_csv_get_client_identifier (
  p_csv varchar2 )
return varchar2;

function utl_csv_get_exit_sysdate (
  p_csv varchar2 )
return date;

function utl_csv_get_check_interval (
  p_csv varchar2 )
return integer;

function utl_csv_get_level (
  p_csv varchar2 )
return integer;

function utl_csv_get_boolean_options (
  p_csv varchar2 )
return integer;

function utl_create_log_entry (
  p_level           in integer                ,
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;

$end

end console;
/

prompt - Package CONSOLE (body)
create or replace package body console is

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS, TYPES, GLOBALS
--------------------------------------------------------------------------------

c_crlf                   constant t_2b  := chr(13) || chr(10);
c_cr                     constant t_1b  := chr(13);
c_lf                     constant t_1b  := chr(10);
c_lflf                   constant t_2b  := chr(10) || chr(10);
c_ampersand              constant t_1b  := chr(38);
c_html_ampersand         constant t_8b  := chr(38) || 'amp;';
c_html_less_then         constant t_4b  := chr(38) || 'lt;';
c_html_greater_then      constant t_4b  := chr(38) || 'gt;';
c_timestamp_format       constant t_32b := 'yyyy-mm-dd hh24:mi:ss.ff6';
c_date_format            constant t_32b := 'yyyy-mm-dd hh24:mi:ss';
c_date_format_short      constant t_16b := 'yymmddhh24miss';
c_default_label          constant t_8b  := 'default';
c_conf_id                constant t_4b  := 'CONF';
c_client_id_prefix       constant t_8b  := '{o,o} ';
c_console_owner          constant t_32b := $$plsql_unit_owner;
c_console_job_name       constant t_16b := 'CONSOLE_PURGE';
c_param_value_max_length constant t_int :=  2000;
c_assert_error_code      constant t_int := -20777 ;
c_assert_error_message   constant t_32b := 'Assertion failed: ';

-- CONSTANTS FOR BITAND OPERATIONS
c_call_stack             constant t_int := 16;
c_user_env               constant t_int :=  8;
c_apex_env               constant t_int :=  4;
c_cgi_env                constant t_int :=  2;
c_console_env            constant t_int :=  1;

-- NUMERIC TYPE IDENTFIERS
-- c_number                 constant t_int :=   2; -- float
-- c_binary_float           constant t_int := 100;
-- c_binary_double          constant t_int := 101;
-- STRING TYPE IDENTFIERS
-- c_char                   constant t_int :=  96; -- nchar
-- c_varchar2               constant t_int :=   1; -- nvarchar2
   c_long                   constant t_int :=   8;
   c_clob                   constant t_int := 112; -- nclob
   c_xmltype                constant t_int := 109; -- anydata, anydataset, anytype, object type, varray, nested table
-- c_rowid                  constant t_int :=  69;
-- c_urowid                 constant t_int := 208;
-- BINARY TYPE IDENTFIERS
   c_raw                    constant t_int :=  23;
   c_long_raw               constant t_int :=  24;
   c_blob                   constant t_int := 113;
   c_bfile                  constant t_int := 114;
-- DATE TYPE IDENTFIERS
-- c_date                   constant t_int :=  12;
-- c_timestamp              constant t_int := 180;
-- c_timestamp_tz           constant t_int := 181;
-- c_timestamp_ltz          constant t_int := 231;
-- INTERVAL TYPE IDENTFIERS
-- c_interval_year_to_month constant t_int := 182;
-- c_interval_day_to_second constant t_int := 183;
-- CURSOR TYPE IDENTFIERS
-- c_ref                    constant t_int := 111;
-- c_ref_cursor             constant t_int := 102; -- same identfiers for strong and weak ref cursor

type t_timers_tab      is table of timestamp index by t_128b;
type t_counters_tab    is table of t_int     index by t_128b;
type t_saved_stack_tab is table of t_1kb     index by binary_integer;

g_params         t_attribute_value_tab_i;
g_timers         t_timers_tab;
g_counters       t_counters_tab;
g_saved_stack    t_saved_stack_tab;
g_prev_error_msg t_1kb;

g_conf_client_identifier t_64b;
g_conf_exit_sysdate      date;
g_conf_check_interval    integer;
g_conf_check_sysdate     date;
g_conf_level             t_int;
g_conf_call_stack        boolean;
g_conf_user_env          boolean;
g_conf_apex_env          boolean;
g_conf_cgi_env           boolean;
g_conf_console_env       boolean;
g_conf_enable_ascii_art  boolean;

-------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS (forward declarations)
--------------------------------------------------------------------------------

$if not $$utils_public $then

procedure utl_set_client_identifier;

procedure utl_set_session_conf;

procedure utl_set_conf (
  p_conf console_conf%rowtype );

procedure utl_set_client_prefs (
  p_prefs varchar2 );

function utl_get_conf return console_conf%rowtype result_cache;

function utl_get_client_prefs (
  p_all_prefs_csv varchar2     ,
  p_client_identifier varchar2 )
return t_client_prefs_row;

function utl_get_client_prefs_tab return t_client_prefs_tab_i;

function utl_escape_md_tab_text (
  p_text varchar2 )
return varchar2;

function utl_last_error return varchar2;

function utl_logging_is_enabled (
  p_level integer )
return boolean;

function utl_normalize_label (
  p_label varchar2 )
return varchar2;

function utl_replace_linebreaks (
  p_text varchar2                     ,
  p_replace_with varchar2 default ' ' )
return varchar2;

function utl_get_clean_client_prefs_csv (
  p_client_identifier_to_remove in varchar2           default null ,
  p_client_prefs_to_append      in t_client_prefs_row default null )
return varchar2;

function utl_client_prefs_to_csv (
  p_client_prefs t_client_prefs_row )
return varchar2;

function utl_csv_to_client_prefs (
  p_csv varchar2 ) return t_client_prefs_row;

function utl_csv_get_client_identifier (
  p_csv varchar2 )
return varchar2;

function utl_csv_get_exit_sysdate (
  p_csv varchar2 )
return date;

function utl_csv_get_check_interval (
  p_csv varchar2 )
return integer;

function utl_csv_get_level (
  p_csv varchar2 )
return integer;

function utl_csv_get_boolean_options (
  p_csv varchar2 )
return integer;

function utl_create_log_entry (
  p_level           in integer                ,
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;

$end

--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------

function my_client_identifier return varchar2 is
begin
  return g_conf_client_identifier;
end my_client_identifier;

--------------------------------------------------------------------------------

function my_log_level return integer is
begin
  return g_conf_level;
end my_log_level;

--------------------------------------------------------------------------------

procedure error_save_stack is
begin
  g_saved_stack(g_saved_stack.count + 1) := substr(scope || utl_last_error, 1, 1024);
end error_save_stack;

--------------------------------------------------------------------------------

procedure error (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default true  ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default true  ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  else
    g_params.delete;
  end if;
end warn;

function warn (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  else
    g_params.delete;
  end if;
  return v_log_id;
end warn;

--------------------------------------------------------------------------------

procedure info (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  else
    g_params.delete;
  end if;
end info;

function info (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  else
    g_params.delete;
  end if;
  return v_log_id;
end info;

--------------------------------------------------------------------------------

procedure log (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  else
    g_params.delete;
  end if;
end log;

function log (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  else
    g_params.delete;
  end if;
  return v_log_id;
end log;

--------------------------------------------------------------------------------

procedure debug (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  else
    g_params.delete;
  end if;
end debug;

function debug (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  else
    g_params.delete;
  end if;
  return v_log_id;
end debug;

--------------------------------------------------------------------------------

procedure trace (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default true  ,
  p_apex_env        in boolean  default true  ,
  p_cgi_env         in boolean  default true  ,
  p_console_env     in boolean  default true  ,
  p_user_env        in boolean  default true  ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  else
    g_params.delete;
  end if;
end trace;

function trace (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default true  ,
  p_apex_env        in boolean  default true  ,
  p_cgi_env         in boolean  default true  ,
  p_console_env     in boolean  default true  ,
  p_user_env        in boolean  default true  ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
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
  else
    g_params.delete;
  end if;
  return v_log_id;
end trace;

--------------------------------------------------------------------------------

procedure count (
  p_label in varchar2 default null )
is
  v_label t_128b;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    g_counters(v_label) := g_counters(v_label) + 1;
  else
    g_counters(v_label) := 1;
  end if;
end count;

--------------------------------------------------------------------------------

procedure count_reset (
  p_label in varchar2 default null )
is
  v_label t_128b;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    g_counters(v_label) := 0;
  else
    g_counters(v_label) := 0;
  end if;
end count_reset;

--------------------------------------------------------------------------------

procedure count_current (
  p_label   in varchar2 default null ,
  p_message in varchar2 default null )
is
  v_label  t_128b;
  v_log_id console_logs.log_id%type;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    if utl_logging_is_enabled (c_level_info) then
      v_log_id := utl_create_log_entry (
        p_level   => c_level_info,
        p_message => v_label || ': ' || to_char(g_counters(v_label)) ||
                     case when p_message is not null then ' - ' || p_message end
      );
    end if;
  else
    warn('Counter `' || v_label || '` does not exist.');
  end if;
end count_current;

--------------------------------------------------------------------------------

procedure count_end (
  p_label   in varchar2 default null ,
  p_message in varchar2 default null )
is
  v_label  t_128b;
  v_log_id console_logs.log_id%type;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    if utl_logging_is_enabled (c_level_info) then
      v_log_id := utl_create_log_entry (
        p_level   => c_level_info,
        p_message => v_label || ': ' || to_char(g_counters(v_label)) ||
                     case when p_message is not null then ' - ' || p_message end
    );
    end if;
    g_counters.delete(v_label);
  else
    warn('Counter `' || v_label || '` does not exist.');
  end if;
end count_end;

--------------------------------------------------------------------------------

function count_current (
  p_label in varchar2 default null )
return t_int
is
  v_label  t_128b;
  v_return t_int;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    v_return := g_counters(v_label);
  end if;
  return v_return;
end count_current;

--------------------------------------------------------------------------------

function count_end (
  p_label in varchar2 default null )
return t_int
is
  v_label  t_128b;
  v_return t_int;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    v_return := g_counters(v_label);
    g_counters.delete(v_label);
  end if;
  return v_return;
end count_end;

--------------------------------------------------------------------------------

procedure time (
  p_label in varchar2 default null )
is
begin
  g_timers(utl_normalize_label(p_label)) := localtimestamp;
end time;

--------------------------------------------------------------------------------

procedure time_reset (
  p_label in varchar2 default null )
is
begin
  time(p_label);
end time_reset;

--------------------------------------------------------------------------------

procedure time_current (
  p_label   in varchar2 default null ,
  p_message in varchar2 default null )
is
  v_label  t_128b;
  v_log_id console_logs.log_id%type;
begin
  v_label := utl_normalize_label(p_label);
  if g_timers.exists(v_label) then
    if utl_logging_is_enabled (c_level_info) then
      v_log_id := utl_create_log_entry (
        p_level   => c_level_info,
        p_message => v_label || ': ' || runtime (g_timers(v_label)) ||
                     case when p_message is not null then ' - ' || p_message end
      );
    end if;
  else
    warn('Timer `' || v_label || '` does not exist.');
  end if;
end time_current;

--------------------------------------------------------------------------------

procedure time_end (
  p_label   in varchar2 default null ,
  p_message in varchar2 default null )
is
  v_label  t_128b;
  v_log_id console_logs.log_id%type;
begin
  v_label := utl_normalize_label(p_label);
  if g_timers.exists(v_label) then
    if utl_logging_is_enabled (c_level_info) then
      v_log_id := utl_create_log_entry (
        p_level   => c_level_info,
        p_message => v_label || ': ' || runtime (g_timers(v_label)) ||
                     case when p_message is not null then ' - ' || p_message end
      );
    end if;
    g_timers.delete(v_label);
  else
    warn('Timer `' || v_label || '` does not exist.');
  end if;
end time_end;

--------------------------------------------------------------------------------

function time_current (
  p_label in varchar2 default null )
return varchar2
is
  v_label  t_128b;
  v_return t_64b;
begin
  v_label := utl_normalize_label(p_label);
  if g_timers.exists(v_label) then
    v_return :=  runtime(g_timers(v_label));
  end if;
  return v_return;
end time_current;

--------------------------------------------------------------------------------

function time_end (
  p_label in varchar2 default null )
return varchar2
is
  v_label  t_128b;
  v_return t_64b;
begin
  v_label := utl_normalize_label(p_label);
  if g_timers.exists(v_label) then
    v_return :=  runtime(g_timers(v_label));
    g_timers.delete(v_label);
  end if;
  return v_return;
end time_end;

--------------------------------------------------------------------------------

procedure table# (
  p_data_cursor       in sys_refcursor         ,
  p_comment           in varchar2 default null ,
  p_include_row_num   in boolean  default true ,
  p_max_rows          in integer  default 100  ,
  p_max_column_length in integer  default 1000 )
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
  p_expression in boolean  ,
  p_message    in varchar2 )
is
begin
  if not p_expression then
    raise_application_error(
      c_assert_error_code,
      c_assert_error_message || p_message,
      true);
  end if;
end assert;

--------------------------------------------------------------------------------

procedure assertf (
  p_expression in boolean               ,
  p_message    in varchar2              ,
  p0           in varchar2 default null ,
  p1           in varchar2 default null ,
  p2           in varchar2 default null ,
  p3           in varchar2 default null ,
  p4           in varchar2 default null ,
  p5           in varchar2 default null ,
  p6           in varchar2 default null ,
  p7           in varchar2 default null ,
  p8           in varchar2 default null ,
  p9           in varchar2 default null )
is
begin
  if not p_expression then
    raise_application_error(
      c_assert_error_code,
      format(
        c_assert_error_message || p_message,
        p0 => p0,
        p1 => p1,
        p2 => p2,
        p3 => p3,
        p4 => p4,
        p5 => p5,
        p6 => p6,
        p7 => p7,
        p8 => p8,
        p9 => p9),
      true);
  end if;
end assertf;

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
  v_message t_32kb := p_message;
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

procedure add_param (
  p_name  in varchar2 ,
  p_value in varchar2 )
is
  v_param t_attribute_value_row;
begin
  v_param.attribute := substr(p_name, 1, 128);
  v_param.value     := substr(p_value, 1, c_param_value_max_length);
  g_params(g_params.count + 1) := v_param;
end add_param;


function add_param (
  p_name  in varchar2 ,
  p_value in varchar2 )
return t_console is
begin
  add_param(p_name, p_value);

  return t_console();
end add_param;

--------------------------------------------------------------------------------

procedure add_param (
  p_name  in varchar2 ,
  p_value in number   )
is
  v_param t_attribute_value_row;
begin
  v_param.attribute := substr(p_name, 1, 128);
  v_param.value     := to_char(p_value);
  g_params(g_params.count + 1) := v_param;
end add_param;


function add_param (
  p_name  in varchar2 ,
  p_value in number   )
return t_console is
begin
  add_param(p_name, p_value);

  return t_console();
end add_param;

--------------------------------------------------------------------------------

procedure add_param (
  p_name  in varchar2 ,
  p_value in date     )
is
  v_param t_attribute_value_row;
begin
  v_param.attribute := substr(p_name, 1, 128);
  v_param.value     := to_char(p_value, 'yyyy-mm-dd hh24:mi:ss');
  g_params(g_params.count + 1) := v_param;
end add_param;


function add_param (
  p_name  in varchar2 ,
  p_value in date     )
return t_console is
begin
  add_param(p_name, p_value);

  return t_console();
end add_param;

--------------------------------------------------------------------------------

procedure add_param (
  p_name  in varchar2  ,
  p_value in timestamp )
is
  v_param t_attribute_value_row;
begin
  v_param.attribute := substr(p_name, 1, 128);
  v_param.value     := to_char(p_value, 'yyyy-mm-dd hh24:mi:ssxff');
  g_params(g_params.count + 1) := v_param;
end add_param;


function add_param (
  p_name  in varchar2  ,
  p_value in timestamp )
return t_console is
begin
  add_param(p_name, p_value);

  return t_console();
end add_param;

--------------------------------------------------------------------------------

procedure add_param (
  p_name  in varchar2                 ,
  p_value in timestamp with time zone )
is
  v_param t_attribute_value_row;
begin
  v_param.attribute := substr(p_name, 1, 128);
  v_param.value     := to_char(p_value, 'yyyy-mm-dd hh24:mi:ssxff tzr');
  g_params(g_params.count + 1) := v_param;
end add_param;


function add_param (
  p_name  in varchar2                 ,
  p_value in timestamp with time zone )
return t_console is
begin
  add_param(p_name, p_value);

  return t_console();
end add_param;

--------------------------------------------------------------------------------

procedure add_param (
  p_name  in varchar2                       ,
  p_value in timestamp with local time zone )
is
  v_param t_attribute_value_row;
begin
  v_param.attribute := substr(p_name, 1, 128);
  v_param.value     := to_char(p_value, 'yyyy-mm-dd hh24:mi:ssxff tzr');
  g_params(g_params.count + 1) := v_param;
end add_param;


function add_param (
  p_name  in varchar2                       ,
  p_value in timestamp with local time zone )
return t_console is
begin
  add_param(p_name, p_value);

  return t_console();
end add_param;

--------------------------------------------------------------------------------

procedure add_param (
  p_name  in varchar2               ,
  p_value in interval year to month )
is
  v_param t_attribute_value_row;
begin
  v_param.attribute := substr(p_name, 1, 128);
  v_param.value     := substr(to_char(p_value), 1, c_param_value_max_length);
  g_params(g_params.count + 1) := v_param;
end add_param;


function add_param (
  p_name  in varchar2               ,
  p_value in interval year to month )
return t_console is
begin
  add_param(p_name, p_value);

  return t_console();
end add_param;

--------------------------------------------------------------------------------

procedure add_param (
  p_name  in varchar2               ,
  p_value in interval day to second )
is
  v_param t_attribute_value_row;
begin
  v_param.attribute := substr(p_name, 1, 128);
  v_param.value     := substr(to_char(p_value), 1, c_param_value_max_length);
  g_params(g_params.count + 1) := v_param;
end add_param;


function add_param (
  p_name  in varchar2               ,
  p_value in interval day to second )
return t_console is
begin
  add_param(p_name, p_value);

  return t_console();
end add_param;

--------------------------------------------------------------------------------

procedure add_param (
  p_name  in varchar2 ,
  p_value in boolean  )
is
  v_param t_attribute_value_row;
begin
  v_param.attribute := substr(p_name, 1, 128);
  v_param.value     := to_string(p_value);
  g_params(g_params.count + 1) := v_param;
end add_param;


function add_param (
  p_name  in varchar2 ,
  p_value in boolean  )
return t_console is
begin
  add_param(p_name, p_value);

  return t_console();
end add_param;

--------------------------------------------------------------------------------

procedure add_param (
  p_name  in varchar2 ,
  p_value in clob     )
is
  v_param t_attribute_value_row;
begin
  v_param.attribute := substr(p_name, 1, 128);
  v_param.value     := substr(p_value, 1, c_param_value_max_length);
  g_params(g_params.count + 1) := v_param;
end add_param;


function add_param (
  p_name  in varchar2 ,
  p_value in clob     )
return t_console is
begin
  add_param(p_name, p_value);

  return t_console();
end add_param;

--------------------------------------------------------------------------------

procedure add_param (
  p_name  in varchar2 ,
  p_value in xmltype  )
is
  v_param t_attribute_value_row;
begin
  v_param.attribute := substr(p_name, 1, 128);
  v_param.value     := case when p_value is not null then substr(p_value.getclobval(), 1, c_param_value_max_length) else null end;
  g_params(g_params.count + 1) := v_param;
end add_param;


function add_param (
  p_name  in varchar2 ,
  p_value in xmltype  )
return t_console is
begin
  add_param(p_name, p_value);

  return t_console();
end add_param;

--------------------------------------------------------------------------------

procedure action (
  p_action in varchar2 )
is
begin
  sys.dbms_application_info.set_action (
    p_action );
end action;

--------------------------------------------------------------------------------

procedure module (
  p_module in varchar2,
  p_action in varchar2 default null
)
is
begin
  sys.dbms_application_info.set_module(
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
  v_log_id          number;
  v_constraint_name t_256b;
  v_app_id          t_int := v('APP_ID');
  v_app_page_id     t_int := v('APP_PAGE_ID');
  --
  function extract_constraint_name(
    p_sqlerrm in varchar2)
  return varchar2 is
  begin
    return regexp_substr(p_sqlerrm, '\(\S+?\.(\S+?)\)', 1, 1, 'i', 1);
  end;
  --
  function ascii_art (
    p_type in varchar2 ) -- html, md
  return varchar2 is
    v_return t_1kb;
    v_troll  t_1kb := q'[
                \|||/
                (o o)
    ,-------ooO--(_)------------.
    | Ooops, there was an ERROR |
    | Application ID: #APP_ID## |
    | Log ID: #LOG_ID########## |
    '----------------Ooo--------'
               |__|__|
                || ||
               ooO Ooo   ]' || c_lf;
  begin
    if g_conf_enable_ascii_art then
      v_return :=
        case p_type when 'html' then '<pre>' when 'md' then c_lflf||'```' end             ||
        replace(replace(v_troll,
          '#APP_ID##'        , rpad( v_app_id                             ,  9, ' ') ),
          '#LOG_ID##########', rpad( nvl(to_char(v_log_id), 'this.log_id'), 17, ' ') )  ||
        case p_type when 'html' then '</pre>' when 'md' then '```' end          ;
    end if;
    return v_return;
  end ascii_art;
  --
  function create_apex_lang_message (
    p_constraint_name in varchar2
  ) return varchar2
  is
    pragma autonomous_transaction;
    v_message_text t_1kb :=
      'DEVELOPER TODO: Change the message in APEX > Application Builder > Shared Components > Text Messages for constraint ' ||
      p_constraint_name || '.';
  begin
    apex_lang.create_message(
      p_application_id => v_app_id,
      p_name           => p_constraint_name,
      p_language       => nvl(apex_util.get_preference('FSP_LANGUAGE_PREFERENCE'), 'en'),
      p_message_text   => v_message_text);
    commit;
    return v_message_text;
  end create_apex_lang_message;
  --
  function to_md_li_pre (
    p_text in varchar2)
  return varchar2 is
    v_fences t_32b := '    ```';
  begin
    return
      case when p_text is null
        then null
        else c_lf || v_fences || c_lf || to_md_code_block(p_text) || c_lf || v_fences
      end;
  end to_md_li_pre;
  --
  function log_message (
    p_text in varchar2 )
  return clob is
    v_clob  clob;
    v_cache t_32kb;
  begin
    clob_append ( v_clob, v_cache, p_text                   || c_lflf                                              );
    clob_append ( v_clob, v_cache, '## Technical Info'      || c_lflf                                              );
    clob_append ( v_clob, v_cache, '1. is_internal_error: ' || to_string(p_error.is_internal_error)        || c_lf );
    clob_append ( v_clob, v_cache, '2. apex_error_code: '   || p_error.apex_error_code                     || c_lf );
    clob_append ( v_clob, v_cache, '3. original message: '  || p_error.message                             || c_lf );
    clob_append ( v_clob, v_cache, '4. ora_sqlcode: '       || p_error.ora_sqlcode                         || c_lf );
    clob_append ( v_clob, v_cache, '5. ora_sqlerrm: '       || utl_replace_linebreaks(p_error.ora_sqlerrm) || c_lf );
    clob_append ( v_clob, v_cache, '6. component.type: '    || p_error.component.type                      || c_lf );
    clob_append ( v_clob, v_cache, '7. component.id: '      || p_error.component.id                        || c_lf );
    clob_append ( v_clob, v_cache, '8. component.name: '    || p_error.component.name                      || c_lf );
    clob_append ( v_clob, v_cache, '9. error_backtrace: '   || to_md_li_pre(p_error.error_backtrace)       || c_lf );
    clob_append ( v_clob, v_cache, '10. error_statement: '  || to_md_li_pre(p_error.error_statement)       || c_lf );
    clob_flush_cache ( v_clob, v_cache );
    return v_clob;
  end log_message;
  --
begin
  v_result := apex_error.init_error_result (p_error => p_error);

  -- If it's an internal error raised by APEX, like an invalid statement or code
  -- which can't be executed, the error text might contain security sensitive
  -- information. To avoid this security problem we can rewrite the error to a
  -- generic error message and log the original error message for further
  -- investigation by the help desk.
  if p_error.is_internal_error then

    -- Mask all errors that are not common runtime errors (Access Denied errors
    -- raised by application / page authorization and all errors regarding
    -- session and session state).
    if not p_error.is_common_runtime_error then

      -- Log error and return log ID as reference.
      v_log_id := error (
        p_message         => log_message('Unexpected internal application error.') ,
        p_call_stack      => false                                                                            ,
        p_apex_env        => true                                                                             ,
        p_user_scope      => 'APEX BACKEND ERROR HANDLER: App ' || v_app_id || ', page ' || v_app_page_id     ,
        p_user_error_code => p_error.ora_sqlcode                                                              ,
        p_user_call_stack => '#### Error Backtrace' || c_lflf || p_error.error_backtrace                        );

      -- Change the message to the generic error message which doesn't expose
      -- any sensitive information.
      v_result.message :=
        case when v_result.display_location = apex_error.c_on_error_page then ascii_art('html') end ||
        'An unexpected internal application error has occurred. ' ||
        'Please get in contact with your Oracle APEX support team and provide ' ||
        '"App ID ' || to_char(v_app_id) || ', Log ID ' || to_char(v_log_id) ||
        '" for further investigation.';
      v_result.additional_info := null;

    end if;

  else

    -- Always show the error as inline error.
    --
    -- NOTE: If you have created manual tabular forms (using the package
    --       apex_item/htmldb_item in the SQL statement) you should still use
    --       "On error page" on that pages to avoid loosing entered data.
    v_result.display_location :=
      case when v_result.display_location = apex_error.c_on_error_page
        then apex_error.c_inline_in_notification
        else v_result.display_location
      end;

    -- NOTE: If you want to have friendlier ORA error messages, you can also
    --       define a text message with the name pattern APEX.ERROR.ORA-number
    --       There is no need to implement custom code for that.
    --
    -- If it's a constraint violation like
    --
    -- * ORA-00001: unique constraint violated
    -- * ORA-02091: transaction rolled back (-> can hide a deferred constraint)
    -- * ORA-02290: check constraint violated
    -- * ORA-02291: integrity constraint violated - parent key not found
    -- * ORA-02292: integrity constraint violated - child record found
    --
    -- We try to get a friendly error message from APEX text messages. If we
    -- don't find the constraint name there we create a new text message, that
    -- has to be changed by the developers.
    if p_error.ora_sqlcode in (-1, -2091, -2290, -2291, -2292) then
      v_constraint_name := extract_constraint_name(p_error.ora_sqlerrm);
      v_result.message := apex_lang.message( v_constraint_name );

      if v_result.message = v_constraint_name then

        -- * Idea by Roel Hartman:
        --   https://roelhartman.blogspot.com/2021/02/stop-using-validations-for-checking.html
        -- * Also see this video by Anton and Neelesh:
        --   https://www.insum.ca/episode-22-error-handling/
        v_result.message := create_apex_lang_message (v_constraint_name);

        -- Log a permanent error, so developers get information that they need
        -- to change the text message.
        error (
          p_message         => log_message (v_result.message)                                               ,
          p_permanent       => true                                                                         ,
          p_call_stack      => false                                                                        ,
          p_apex_env        => true                                                                         ,
          p_user_scope      => 'APEX BACKEND ERROR HANDLER: App ' || v_app_id || ', page ' || v_app_page_id ,
          p_user_error_code => p_error.ora_sqlcode                                                          ,
          p_user_call_stack => '#### Error Backtrace' || c_lflf || p_error.error_backtrace                    );

      end if;

    end if;

    -- If an ORA error has been raised, for example a
    -- raise_application_error(-20xxx, '...') in a table trigger or in a PL/SQL
    -- package called by a process and we haven't found the error in our lookup
    -- table, then we just want to see the actual error text and not the full
    -- error stack with all the ORA error numbers.
    if p_error.ora_sqlcode is not null and v_result.message = p_error.message then
      v_result.message := apex_error.get_first_ora_error_text (p_error => p_error);
    end if;

    -- If no associated page item/tabular form column has been set, we can use
    -- apex_error.auto_set_associated_item to automatically guess the affected
    -- error field by examine the ORA error for constraint names or column
    -- names.
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
  v_level           t_int;
  v_message         t_32kb;
  v_user_scope      t_32kb;
  v_user_call_stack t_32kb;
  v_user_agent      t_32kb;
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
  p_level            in integer default null ,
  p_check_interval   in integer default null ,
  p_enable_ascii_art in boolean default null )
is
  v_conf console_conf%rowtype;
begin
  assert (
    c_console_owner = sys_context('USERENV','SESSION_USER'),
    'Only the owner of the package console is allowed to change the configuration.');
  v_conf := utl_get_conf; -- this will handle the defaults if we don't have configured console yet.
  v_conf.conf_sysdate     := sysdate;
  v_conf.conf_user        := substrb(coalesce(sys_context('USERENV','OS_USER'), sys_context('USERENV','SESSION_USER')), 1, 64);
  v_conf.level_id         := coalesce(p_level, v_conf.level_id);
  v_conf.level_name       := level_name(v_conf.level_id);
  v_conf.check_interval   := coalesce(p_check_interval, v_conf.check_interval);
  v_conf.enable_ascii_art := to_string(coalesce(p_enable_ascii_art, to_bool(v_conf.enable_ascii_art)));
  assert (
    v_conf.level_id between c_level_error and c_level_trace,
    'Level needs to be 1 (error), 2 (warning), 3 (info), 4 (debug) or 5 (trace).');
  assertf (
    v_conf.check_interval between c_check_interval_default and c_check_interval_max,
    'Check interval needs to be between %s and %s (seconds). ' ||
    'Values between %s and %s seconds can only be set per session with the procedure init.',
    c_check_interval_default,
    c_check_interval_max,
    c_check_interval_min,
    c_check_interval_default);
  utl_set_conf(v_conf);
  utl_set_session_conf;
end conf;

--------------------------------------------------------------------------------

procedure init (
  p_client_identifier in varchar2                                  ,
  p_level             in integer  default c_level_info             ,
  p_duration          in integer  default c_duration_default       ,
  p_check_interval    in integer  default c_check_interval_default ,
  p_call_stack        in boolean  default false                    ,
  p_user_env          in boolean  default false                    ,
  p_apex_env          in boolean  default false                    ,
  p_cgi_env           in boolean  default false                    ,
  p_console_env       in boolean  default false                    )
is
  v_prefs t_client_prefs_row;
  v_conf  console_conf%rowtype;
begin
  assert (
    p_level between c_level_error and c_level_trace,
    'Level needs to be 1 (error), 2 (warning), 3 (info), 4 (debug) or 5 (trace). ' ||
    'NOTE: Level 1 (error) will be always logged and needs no explicit call to the init method.' );
  assert (
    p_client_identifier is not null,
    'Client identifier must not be null.');
  assertf (
    p_duration between c_duration_min and c_duration_max,
    'Duration needs to be between %s and %s (minutes).',
    c_duration_min,
    c_duration_max);
  assertf (
    p_check_interval between c_check_interval_min and c_check_interval_max,
    'Check interval needs to be between %s and %s (seconds).',
    c_check_interval_min,
    c_check_interval_max);
  assert ( p_call_stack  is not null, 'Call stack needs to be true or false (not null).'  );
  assert ( p_user_env    is not null, 'User env needs to be true or false (not null).'    );
  assert ( p_apex_env    is not null, 'APEX env needs to be true or false (not null).'    );
  assert ( p_cgi_env     is not null, 'CGI env needs to be true or false (not null).'     );
  assert ( p_console_env is not null, 'Console env needs to be true or false (not null).' );
  --
  v_prefs.client_identifier := p_client_identifier;
  v_prefs.level_id          := p_level;
  v_prefs.level_name        := level_name(p_level);
  v_prefs.call_stack        := to_string(p_call_stack);
  v_prefs.user_env          := to_string(p_user_env);
  v_prefs.apex_env          := to_string(p_apex_env);
  v_prefs.cgi_env           := to_string(p_cgi_env);
  v_prefs.console_env       := to_string(p_console_env);
  v_prefs.check_interval    := p_check_interval;
  v_prefs.exit_sysdate      := sysdate + 1/24/60 * p_duration;
  utl_set_client_prefs(
    utl_get_clean_client_prefs_csv(
      p_client_identifier_to_remove => v_prefs.client_identifier,
      p_client_prefs_to_append      => v_prefs
    )
  );
  -- If we want to monitor our own session, wee need to load the configuration
  -- data from the context or table into the cache (package variables).
  -- Otherwise we need to wait until the cache duration is over (which defaults
  -- to 10 seconds) and the package reloads the configuration from the context
  -- or table on next call of a public logging method.
  if p_client_identifier = g_conf_client_identifier then
    utl_set_session_conf;
  end if;
end init;

procedure init (
  p_level          in integer default c_level_info             ,
  p_duration       in integer default c_duration_default       ,
  p_check_interval in integer default c_check_interval_default ,
  p_call_stack     in boolean default false                    ,
  p_user_env       in boolean default false                    ,
  p_apex_env       in boolean default false                    ,
  p_cgi_env        in boolean default false                    ,
  p_console_env    in boolean default false                    )
is
begin
  init (
    p_client_identifier => g_conf_client_identifier ,
    p_level             => p_level                  ,
    p_duration          => p_duration               ,
    p_check_interval    => p_check_interval         ,
    p_call_stack        => p_call_stack             ,
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
  p_client_identifier in varchar2 )
is
  v_conf console_conf%rowtype;
begin
  assert(p_client_identifier is not null, 'Client identifier must not be null.');
  utl_set_client_prefs(
    utl_get_clean_client_prefs_csv(
      p_client_identifier_to_remove => p_client_identifier
    )
  );
  -- If we monitor our own session, wee need to load the configuration
  -- data from the context or table into the cache (package variables).
  -- Otherwise we need to wait until the cache duration is over (which defaults
  -- to 10 seconds) and the package reloads the configuration from the context
  -- or table on next call of a public logging method.
  if p_client_identifier = g_conf_client_identifier then
    utl_set_session_conf;
  end if;
end exit_;

--------------------------------------------------------------------------------

procedure exit (
  p_client_identifier in varchar2 default my_client_identifier )
is
begin
  exit_(p_client_identifier);
end exit;

--------------------------------------------------------------------------------

procedure exit_all is
begin
  utl_set_client_prefs(null);
  utl_set_session_conf;
end exit_all;

--------------------------------------------------------------------------------

function version return varchar2 is
begin
  return c_version;
end version;

--------------------------------------------------------------------------------

procedure generate_param_trace (
  p_program in varchar2              ,
  p_level   in pls_integer default 3 )
is
  v_program      t_512b := substrb(replace(upper(p_program), ' ', '_'), 1, 512);
  v_object_name  t_128b := substrb(nvl(regexp_substr(v_program, '(.*+\.)?(.*)', 1, 1, 'i', 2), '-'), 1, 128);
  v_package_name t_128b := substrb(nvl(regexp_substr(v_program, '(.*)\.'      , 1, 1, 'i', 1), '-'), 1, 128);
  --
  c_return_value constant t_32b  := 'YOUR_RETURN_VALUE';
  v_object_is_a_function boolean := false;
  --
  cursor cur_args(
    p_object_name  in t_128b,
    p_package_name in t_128b default null)
  is
    select nvl(argument_name, c_return_value) argument_name,
           data_type,
           in_out
      from user_arguments
     where object_name            = p_object_name
       and nvl(package_name, '-') = p_package_name
       and data_level = 0
     order by position;
  --
  type t_args_tab is table of cur_args%rowtype index by pls_integer;
  v_args_in  t_args_tab;
  v_args_out t_args_tab;
  --
  procedure get_arguments
  is
    v_args t_args_tab;
  begin
    open cur_args(v_object_name, v_package_name);
    fetch cur_args bulk collect into v_args;
    for i in 1..v_args.count
    loop
      if v_args(i).in_out in ('IN', 'IN/OUT') then
        v_args_in(v_args_in.count + 1) := v_args(i);
      end if;
      if v_args(i).in_out in ('OUT', 'IN/OUT') then
        v_args_out(v_args_out.count + 1) := v_args(i);
      end if;
      if v_args(i).argument_name = c_return_value then
        v_object_is_a_function := true;
      end if;
    end loop;
  end get_arguments;
  --
  function params_proc_name(p_arg_type in varchar2) return varchar2 is
  begin
    return 'console_add_' || p_arg_type || '_params';
  end params_proc_name;
  --
  function params_proc_call (p_in_out in t_4b) return t_128b is
    v_return t_128b;
  begin
    if p_in_out = 'in'  and v_args_in.count  = 0
    or p_in_out = 'out' and v_args_out.count = 0 then
      v_return := format('--there are no %s parameters: ', upper(p_in_out));
    end if;
    v_return := v_return || params_proc_name(p_in_out);
    return v_return;
  end params_proc_call;
  --
  procedure gen_params_proc (
    p_in_out in t_4b       ,
    p_args   in t_args_tab )
  is
  begin
    if p_args.count > 0 then
      printf('  procedure %s is', params_proc_name(p_in_out));
      print ('  begin');
      for i in 1..p_args.count
      loop
        printf(
          q'[    %0console.add_param('%1', %1);]',
          case when p_args(i).data_type in (
            'VARCHAR2',
            'NUMBER',
            'DATE',
            'TIMESTAMP',
            'TIMESTAMP WITH TIME ZONE',
            'TIMESTAMP WITH LOCAL TIME ZONE',
            'INTERVAL YEAR TO MONTH',
            'INTERVAL DAY TO SECOND',
            'PL/SQL BOOLEAN',
            'CLOB',
            'OPAQUE/XMLTYPE')
            then null
            else format('--unsupported data type %s: ', p_args(i).data_type )
          end,
          lower(p_args(i).argument_name)
        );
      end loop;
      printf('  end %s;', params_proc_name(p_in_out));
    end if;
  end gen_params_proc;
  --
  function console_log_method(p_level in pls_integer) return varchar2 is
  begin
    return case p_level
             when 1 then 'error'
             when 2 then 'warn'
             when 3 then 'info'
             when 4 then 'debug'
             when 5 then 'trace'
           end;
  end console_log_method;
  --
begin
  get_arguments;

  print   ('');
  print   ('--------------------------------------------------------');
  print   ('-- Signature not recoverable with user_arguments'        );
  print   ('-- We start with declare for easier formatting'          );
  printf  ('-- Your Program : %s'      , v_program                   );
  printf  ('-- Package Name : %s'      , v_package_name              );
  printf  ('-- Object Name  : %s'      , v_object_name               );
  print   ('--------------------------------------------------------');
  print   ('declare'                                                 );

  gen_params_proc('in' , v_args_in );
  gen_params_proc('out', v_args_out);

  print   ('begin'                                                   );
  printf  ('  %s;'                     , params_proc_call('in')      );
  printf  ('  console.%s(''ENTER'');'  , console_log_method(p_level) );
  print   ('  --------------------'                                  );
  print   ('  -- YOUR CODE HERE'                                     );
  print   ('  --------------------'                                  );
  printf  ('  %s;'                     , params_proc_call('out')     );
  printf  ('  console.%s(''LEAVE'');'  , console_log_method(p_level) );

  if v_object_is_a_function then
    print ('  ----------------------'                                );
    print ('  -- YOUR RETURN HERE'                                   );
    print ('  ----------------------'                                );
  end if;

  print   ('exception'                                               );
  print   ('  when others then'                                      );
  printf  ('    %s;'                   , params_proc_call('out')     );
  print   ('    console.error;'                                      );
  print   ('    raise;'                                              );
  printf  ('end %s;'                   , lower(v_object_name)        );
  print   ('/'                                                       );

end generate_param_trace;

--------------------------------------------------------------------------------

function split_to_table (
  p_string in varchar2,
  p_sep    in varchar2 default ','
) return t_vc2_tab pipelined is
  v_array t_vc2_tab_i;
begin
  if p_string is not null then
    v_array := split(p_string, p_sep);
    for i in 1 .. v_array.count loop
        pipe row ( v_array(i) );
    end loop;
  end if;
end split_to_table;

--------------------------------------------------------------------------------

function split (
  p_string in varchar2,
  p_sep    in varchar2 default ','
) return t_vc2_tab_i is
  v_str        t_32kb;
  v_idx        t_int;
  v_sep_length t_int;
  v_return     t_vc2_tab_i;
begin
  if p_string is not null then
    if p_sep is null then
      for i in 1 .. length(p_string) loop
        v_return(v_return.count + 1) := substr(p_string, i, 1);
      end loop;
    else
      v_str := p_string;
      v_sep_length := length(p_sep);
      loop
        v_idx := instr(v_str, p_sep);
        if v_idx > 0 then
          v_return(v_return.count + 1) := substr(v_str, 1, v_idx - 1);
          v_str := substr(v_str, v_idx + v_sep_length);
        else
          v_return(v_return.count + 1) := v_str;
          exit;
        end if;
      end loop;
    end if;
  end if;
  return v_return;
end split;

--------------------------------------------------------------------------------

function join (
  p_table in t_vc2_tab_i,
  p_sep   in varchar2 default ','
) return varchar2 is
  v_return t_32kb;
begin
  for i in 1 .. p_table.count loop
    v_return := v_return || p_sep || p_table(i);
  end loop;
  return v_return;
end join;

--------------------------------------------------------------------------------

function to_yn (
  p_bool in boolean )
return varchar2 is
begin
  return case when p_bool then 'Y' else 'N' end;
end to_yn;

--------------------------------------------------------------------------------

function to_string (
  p_bool in boolean )
return varchar2 is
begin
  return case when p_bool then 'true' else 'false' end;
end to_string;

--------------------------------------------------------------------------------

function to_bool (
  p_string in varchar2 )
return boolean is
begin
  return
    case
      when upper(trim(p_string)) in ('TRUE', 'Y', 'YES', '1')
        then true
      when upper(trim(p_string)) in ('FALSE', 'N', 'NO', '0')
        then false
      else null
    end;
end to_bool;

--------------------------------------------------------------------------------

function to_html_table (
  p_data_cursor       in sys_refcursor         ,
  p_comment           in varchar2 default null ,
  p_include_row_num   in boolean  default true ,
  p_max_rows          in integer  default 100  ,
  p_max_column_length in integer  default 1000 )
return clob is
  v_data_cursor        sys_refcursor := p_data_cursor;
  v_cursor_id          integer;
  v_clob               clob;
  v_cache              t_32kb;
  v_data_count         t_int := 0;
  v_col_count          t_int;
  v_desc_tab           sys.dbms_sql.desc_tab3;
  v_buffer_varchar2    t_32kb;
  v_buffer_clob        clob;
  v_buffer_xmltype     xmltype;
  v_buffer_long_length t_int;
  --
  procedure close_cursor ( p_cursor_id in out integer ) is
  begin
    if sys.dbms_sql.is_open(p_cursor_id) then
      sys.dbms_sql.close_cursor(p_cursor_id);
    end if;
  exception
    when invalid_cursor then null;
  end close_cursor;
  --
  function escape ( p_text in varchar2 ) return varchar2 is
  begin
    return replace(replace(replace(p_text,
      c_ampersand, c_html_ampersand    ),
      '<'        , c_html_less_then    ),
      '>'        , c_html_greater_then );
  end;
  --
  procedure describe_columns is
  begin
    sys.dbms_sql.describe_columns3(v_cursor_id, v_col_count, v_desc_tab);
    for i in 1..v_col_count loop
      if v_desc_tab(i).col_type = c_clob then
        sys.dbms_sql.define_column(v_cursor_id, i, v_buffer_clob);
      elsif v_desc_tab(i).col_type = c_xmltype then
        sys.dbms_sql.define_column(v_cursor_id, i, v_buffer_xmltype);
      elsif v_desc_tab(i).col_type = c_long then
        sys.dbms_sql.define_column_long(v_cursor_id, i);
      elsif v_desc_tab(i).col_type in (c_raw, c_long_raw, c_blob, c_bfile) then
        null; --> we ignore binary data types
      else
        sys.dbms_sql.define_column(v_cursor_id, i, v_buffer_varchar2, p_max_column_length);
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
      exit when sys.dbms_sql.fetch_rows(v_cursor_id) = 0 or v_data_count = p_max_rows;
      v_data_count := v_data_count + 1;
      clob_append(v_clob, v_cache, c_lf || '<tr><!--- row ' || to_char(v_data_count) || ' -->' || c_lf);
      if p_include_row_num then
        clob_append(v_clob, v_cache, '<td headers="row_num">' || to_char(v_data_count) || '</td>' || c_lf);
      end if;
      for i in 1..v_col_count loop
        clob_append(v_clob, v_cache, '<td headers="' || lower(v_desc_tab(i).col_name) || '">');
        --
        if v_desc_tab(i).col_type = c_clob then
          sys.dbms_sql.column_value(v_cursor_id, i, v_buffer_clob);
          clob_append(
            v_clob,
            v_cache,
            escape(substr(v_buffer_clob, 1, p_max_column_length))
            || case when length(v_buffer_clob) > p_max_column_length then '...' end
          );
        --
        elsif v_desc_tab(i).col_type = c_xmltype then
          sys.dbms_sql.column_value(v_cursor_id, i, v_buffer_xmltype);
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
          sys.dbms_sql.column_value_long(v_cursor_id, i, p_max_column_length, 0, v_buffer_varchar2, v_buffer_long_length);
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
          sys.dbms_sql.column_value(v_cursor_id, i, v_buffer_varchar2);
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
  v_cursor_id := sys.dbms_sql.to_cursor_number(v_data_cursor);
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

function to_md_code_block (
  p_text in varchar2 )
return varchar2 is
begin
  return
    '    ' ||
    rtrim(
      trim( replace(replace(p_text, c_crlf, c_lf), c_lf, c_lf||'    ') ),
      c_lf
    );
end to_md_code_block;

--------------------------------------------------------------------------------

function to_md_tab_header (
  p_key   in varchar2 default 'Attribute' ,
  p_value in varchar2 default 'Value'     )
return varchar2 is
  v_key   t_32kb;
  v_value t_32kb;
begin
  v_key   := utl_escape_md_tab_text(p_key);
  v_value := utl_escape_md_tab_text(p_value);
  return '| ' ||
    case when nvl(length(v_key),   0) < 30 then rpad(nvl(v_key  ,' '), 30, ' ') else v_key   end || ' | ' ||
    case when nvl(length(v_value), 0) < 43 then rpad(nvl(v_value,' '), 43, ' ') else v_value end || ' |'  || c_lf ||
    '| ------------------------------ | ------------------------------------------- |' || c_lf;
end to_md_tab_header;

--------------------------------------------------------------------------------

function to_md_tab_data (
  p_key              in varchar2               ,
  p_value            in varchar2               ,
  p_value_max_length in integer  default 1000  ,
  p_show_null_values in boolean  default false )
return varchar2 is
  v_key   t_32kb;
  v_value t_32kb;
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
end to_md_tab_data;

--------------------------------------------------------------------------------

function to_unibar (
  p_value                  in number            ,
  p_scale                  in number default 1  ,
  p_width_block_characters in number default 25 ,
  p_fill_scale             in number default 0  )
return varchar2 deterministic is
  v_return              t_1kb;
  v_value_one_character number;
begin
  if p_value is not null then
  -- calculate the value of one character
    v_value_one_character := p_scale / p_width_block_characters;

  -- create textbar: full block characters
    for i in 1..floor(p_value / v_value_one_character) loop
      v_return := v_return || unistr('\2588');
    end loop;

  -- create textbar: last character - can be between 0 and 8(rounded), because there
  -- are block character available in unicode for 1/8, 1/4, 3/8, 1/2, 5/8, 3/4, 7/8 and 1;
    case round((p_value / v_value_one_character - floor(p_value / v_value_one_character)) / 0.125)
      when 1 then -- 1/8 = char U+258F
        v_return := v_return || unistr('\258F');
      when 2 then -- 2/8 = char U+258E
        v_return := v_return || unistr('\258E');
      when 3 then -- 3/8 = char U+258D
        v_return := v_return || unistr('\258D');
      when 4 then -- 4/8 = char U+258C
        v_return := v_return || unistr('\258C');
      when 5 then -- 5/8 = char U+258B
        v_return := v_return || unistr('\258B');
      when 6 then -- 6/8 = char U+258A
        v_return := v_return || unistr('\258A');
      when 7 then -- 7/8 = char U+2589
        v_return := v_return || unistr('\2589');
      when 8 then -- 8/8 = char U+2588
        v_return := v_return || unistr('\2588');
      else
        null;
    end case;

  -- fill up scale with shade
    if p_fill_scale = 1 then
      for i in 1..( p_width_block_characters - nvl(length(v_return), 0) ) loop
        v_return := v_return || unistr('\2591');
      end loop;
    end if;
  end if;

  return v_return;
exception
  when value_error then
    return unistr('\221E');
end to_unibar;

--------------------------------------------------------------------------------

procedure print ( p_message in varchar2 ) is
begin
  sys.dbms_output.put_line(p_message);
end print;

--------------------------------------------------------------------------------

procedure printf (
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
is
begin
  sys.dbms_output.put_line(
    console.format(
      p_message => p_message ,
      p0        => p0        ,
      p1        => p1        ,
      p2        => p2        ,
      p3        => p3        ,
      p4        => p4        ,
      p5        => p5        ,
      p6        => p6        ,
      p7        => p7        ,
      p8        => p8        ,
      p9        => p9        ));
end printf;

--------------------------------------------------------------------------------

function runtime ( p_start in timestamp ) return varchar2 is
  v_runtime t_32b;
begin
  v_runtime := to_char(localtimestamp - p_start);
  return substr(v_runtime, instr(v_runtime,':')-2, 15);
end runtime;

--------------------------------------------------------------------------------

function runtime_seconds ( p_start in timestamp ) return number is
  v_runtime interval day to second;
begin
  v_runtime := localtimestamp - p_start;
  return
    extract(hour   from v_runtime) * 3600 +
    extract(minute from v_runtime) *   60 +
    extract(second from v_runtime)        ;
end runtime_seconds;

--------------------------------------------------------------------------------

function runtime_milliseconds ( p_start in timestamp ) return number is
begin
  return runtime_seconds(p_start) * 1000;
end runtime_milliseconds;

--------------------------------------------------------------------------------

function level_name (p_level in integer) return varchar2 deterministic is
begin
  return case p_level
    when 1 then 'error'
    when 2 then 'warning'
    when 3 then 'info'
    when 4 then 'debug'
    when 5 then 'trace'
    else null
  end;
end level_name;

--------------------------------------------------------------------------------

function scope return varchar2 is
  v_return     t_32kb;
  v_subprogram t_32kb;
begin
  if sys.utl_call_stack.dynamic_depth > 0 then
    --ignore 1, is always this function (scope) itself
    for i in 2 .. sys.utl_call_stack.dynamic_depth
    loop
      v_subprogram := sys.utl_call_stack.concatenate_subprogram( sys.utl_call_stack.subprogram(i) );
      --exclude console package from the scope
      if instr ( upper(v_subprogram), 'CONSOLE.' ) = 0 then
        v_return := v_return
          || case when sys.utl_call_stack.owner(i) is not null then sys.utl_call_stack.owner(i) || '.' end
          || v_subprogram
          || case when sys.utl_call_stack.unit_line(i) is not null then ', line ' || sys.utl_call_stack.unit_line(i) end;
      end if;
      exit when v_return is not null;
    end loop;
  end if;
  return v_return;
end scope;

--------------------------------------------------------------------------------

function call_stack return varchar2
is
  v_return     t_32kb;
  v_subprogram t_32kb;
begin

  if g_saved_stack.count > 0 then
    v_return := v_return || '#### Saved Error Stack' || c_lflf;
    for i in 1 .. g_saved_stack.count
    loop
      v_return := v_return || '- ' || g_saved_stack (i) || c_lf;
    end loop;
    v_return := v_return || c_lf;
  end if;

  if sys.utl_call_stack.dynamic_depth > 1 then
    v_return := v_return || '#### Call Stack' || c_lflf;
    --ignore 1, is always this function (call_stack) itself
    for i in 2 .. sys.utl_call_stack.dynamic_depth
    loop
      v_subprogram := sys.utl_call_stack.concatenate_subprogram ( sys.utl_call_stack.subprogram(i) );
      --exclude console package from the call stack
      if instr( upper(v_subprogram), 'CONSOLE.' ) = 0 then
        v_return := v_return
          || '- '
          || case when sys.utl_call_stack.owner(i) is not null then sys.utl_call_stack.owner(i) || '.' end
          || v_subprogram
          || case when sys.utl_call_stack.unit_line(i) is not null then ', line ' || sys.utl_call_stack.unit_line(i) end
          || c_lf;
      end if;
    end loop;
    v_return := v_return || c_lf;
  end if;

  if sys.utl_call_stack.error_depth > 0 then
    v_return := v_return || '#### Error Stack' || c_lflf;
    for i in 1 .. sys.utl_call_stack.error_depth
    loop
      v_return := v_return
        || '- ORA-'
        || trim(to_char(sys.utl_call_stack.error_number(i), '00009')) || ' '
        || utl_replace_linebreaks(sys.utl_call_stack.error_msg(i)) || c_lf;
    end loop;
    v_return := v_return || c_lf;
  end if;

  if sys.utl_call_stack.backtrace_depth > 0 then
    v_return := v_return || '#### Error Backtrace' || c_lflf;
    for i in 1 .. sys.utl_call_stack.backtrace_depth
    loop
      v_return := v_return
        || '- '
        || coalesce( sys.utl_call_stack.backtrace_unit(i), '__anonymous_block' )
        || ', line ' || sys.utl_call_stack.backtrace_line(i) || c_lf;
    end loop;
    v_return := v_return || c_lf;
  end if;

  return v_return || chr(10);
end call_stack;

--------------------------------------------------------------------------------

function apex_env return clob
is
  v_clob        clob;
  v_cache       t_32kb;
  v_value       t_32kb;
  v_app_id      t_num;
  v_app_page_id t_num;
  v_app_session t_64b;
  --
begin
  $if not $$apex_installed $then
  null;
  $else

  --https://jeffkemponoracle.com/2015/11/apex-5-application-context/
  --https://joelkallman.blogspot.com/2016/09/correlating-apex-sessions-to-database.html
  --sys_context('APEX$SESSION','APP_USER')
  --sys_context('APEX$SESSION','WORKSPACE_ID')
  v_app_id      := to_number(v(                   'APP_ID'      ));
  v_app_page_id := to_number(v(                   'APP_PAGE_ID' ));
  v_app_session := sys_context(  'APEX$SESSION' , 'APP_SESSION' );

  clob_append(v_clob, v_cache, '#### APEX Environment' || c_lflf);

  clob_append(v_clob, v_cache, 'APEX Session: ' || v_app_session || c_lflf);

  clob_append(v_clob, v_cache, '##### Application Items' ||
    case when v_app_id is not null then ' - APP_ID ' || to_char(v_app_id) end || c_lflf ||
    to_md_tab_header('Item Name'));

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
  clob_append(v_clob, v_cache, '##### Page Items' ||
    case when g_conf_level < c_level_debug and v_app_page_id is not null then
      ' - APP_PAGE_ID ' || to_char(v_app_page_id)
    end || c_lflf ||
    to_md_tab_header('Item Name'));

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
end apex_env;

--------------------------------------------------------------------------------

function cgi_env return varchar2
is
  v_return t_32kb;
begin
  v_return := '#### CGI Environment' || c_lflf || to_md_tab_header;
  for i in 1 .. nvl(sys.owa.num_cgi_vars, 0) loop
    v_return := v_return ||
      to_md_tab_data(
        p_key   => sys.owa.cgi_var_name(i) ,
        p_value => sys.owa.cgi_var_val (i) );
  end loop;
  v_return := v_return || c_lf;
  return v_return;
exception
  when value_error then
    --> we simply return here what we already have and forget about the rest...
    return v_return;
end cgi_env;

--------------------------------------------------------------------------------

function console_env return varchar2
is
  v_return t_32kb;
  v_index  t_128b;
  --
  procedure append_row (p_key in varchar2, p_value in varchar2) is
  begin
    v_return := v_return || to_md_tab_data(p_key, p_value, p_show_null_values => true);
  end append_row;
  --
begin
  v_return := '#### Console Environment' || c_lflf || to_md_tab_header;
  append_row('c_version',                       to_char( c_version                              ));
  append_row('localtimestamp',                  to_char( localtimestamp,          c_date_format ));
  append_row('sysdate',                         to_char( sysdate,                 c_date_format ));
  append_row('g_conf_check_sysdate',            to_char( g_conf_check_sysdate,    c_date_format ));
  append_row('g_conf_exit_sysdate',             to_char( g_conf_exit_sysdate,     c_date_format ));
  append_row('g_conf_client_identifier',                 g_conf_client_identifier                );
  append_row('g_conf_level',                    to_char( g_conf_level                           ));
  append_row('level_name(g_conf_level)',     level_name( g_conf_level                           ));
  append_row('g_conf_check_interval',           to_char( g_conf_check_interval                  ));
  append_row('g_conf_enable_ascii_art',       to_string( g_conf_enable_ascii_art                ));
  append_row('g_conf_call_stack',             to_string( g_conf_call_stack                      ));
  append_row('g_conf_user_env',               to_string( g_conf_user_env                        ));
  append_row('g_conf_apex_env',               to_string( g_conf_apex_env                        ));
  append_row('g_conf_cgi_env',                to_string( g_conf_cgi_env                         ));
  append_row('g_conf_console_env',            to_string( g_conf_console_env                     ));
  append_row('g_counters.count',                to_char( g_counters.count                       ));
  append_row('g_timers.count',                  to_char( g_timers.count                         ));
  append_row('g_saved_stack.count',             to_char( g_saved_stack.count                    ));
  append_row('g_prev_error_msg', utl_replace_linebreaks( g_prev_error_msg                       ));

  v_return := v_return || c_lf;

  if g_timers.count > 0 then
    v_return := v_return || '##### Running Timers' || c_lflf || to_md_tab_header('Label', 'Start Time (localtimestamp)');
    v_index := g_timers.first;
    loop
      exit when v_index is null;
      append_row(v_index, to_char(g_timers(v_index), c_timestamp_format));
      v_index := g_timers.next(v_index);
    end loop;
    v_return := v_return || c_lf;
  end if;

  if g_counters.count > 0 then
    v_return := v_return || '##### Running Counters' || c_lflf || to_md_tab_header('Label', 'Current Count');
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
end console_env;

--------------------------------------------------------------------------------

function user_env return varchar2
is
  v_return t_32kb;
  invalid_user_env_key exception;
  pragma exception_init(invalid_user_env_key, -2003);
  --
  procedure append_row (p_key in varchar2) is
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
  v_return := '#### User Environment' || c_lflf || to_md_tab_header;
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
end user_env;

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
      sys.dbms_lob.writeappend(p_clob, length(p_cache), p_cache);
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
      sys.dbms_lob.writeappend(p_clob, length(p_text), p_text);
    end if;
  end if;
end clob_append;

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
      sys.dbms_lob.writeappend(p_clob, length(p_cache), p_cache);
    end if;
    p_cache := null;
  end if;
end clob_flush_cache;

--------------------------------------------------------------------------------

function status return t_attribute_value_tab pipelined is
  v_row t_attribute_value_row;
begin
  if g_conf_check_sysdate < sysdate then
    utl_set_session_conf;
  end if;

  v_row.attribute := 'c_version'               ; v_row.value :=                to_char( c_version                              ); pipe row(v_row);
  v_row.attribute := 'localtimestamp'          ; v_row.value :=                to_char( localtimestamp,          c_date_format ); pipe row(v_row);
  v_row.attribute := 'sysdate'                 ; v_row.value :=                to_char( sysdate,                 c_date_format ); pipe row(v_row);
  v_row.attribute := 'g_conf_check_sysdate'    ; v_row.value :=                to_char( g_conf_check_sysdate,    c_date_format ); pipe row(v_row);
  v_row.attribute := 'g_conf_exit_sysdate'     ; v_row.value :=                to_char( g_conf_exit_sysdate,     c_date_format ); pipe row(v_row);
  v_row.attribute := 'g_conf_client_identifier'; v_row.value :=                         g_conf_client_identifier                ; pipe row(v_row);
  v_row.attribute := 'g_conf_level'            ; v_row.value :=                to_char( g_conf_level                           ); pipe row(v_row);
  v_row.attribute := 'level_name(g_conf_level)'; v_row.value :=             level_name( g_conf_level                           ); pipe row(v_row);
  v_row.attribute := 'g_conf_check_interval'   ; v_row.value :=                to_char( g_conf_check_interval                  ); pipe row(v_row);
  v_row.attribute := 'g_conf_enable_ascii_art' ; v_row.value :=              to_string( g_conf_enable_ascii_art                ); pipe row(v_row);
  v_row.attribute := 'g_conf_call_stack'       ; v_row.value :=              to_string( g_conf_call_stack                      ); pipe row(v_row);
  v_row.attribute := 'g_conf_user_env'         ; v_row.value :=              to_string( g_conf_user_env                        ); pipe row(v_row);
  v_row.attribute := 'g_conf_apex_env'         ; v_row.value :=              to_string( g_conf_apex_env                        ); pipe row(v_row);
  v_row.attribute := 'g_conf_cgi_env'          ; v_row.value :=              to_string( g_conf_cgi_env                         ); pipe row(v_row);
  v_row.attribute := 'g_conf_console_env'      ; v_row.value :=              to_string( g_conf_console_env                     ); pipe row(v_row);
  v_row.attribute := 'g_counters.count'        ; v_row.value :=                to_char( g_counters.count                       ); pipe row(v_row);
  v_row.attribute := 'g_timers.count'          ; v_row.value :=                to_char( g_timers.count                         ); pipe row(v_row);
  v_row.attribute := 'g_saved_stack.count'     ; v_row.value :=                to_char( g_saved_stack.count                    ); pipe row(v_row);
  v_row.attribute := 'g_prev_error_msg'        ; v_row.value := utl_replace_linebreaks( g_prev_error_msg                       ); pipe row(v_row);
end status;

--------------------------------------------------------------------------------

function conf
return t_attribute_value_tab pipelined is
  v_row  t_attribute_value_row;
  v_conf console_conf%rowtype;
begin
  v_conf := utl_get_conf;
  v_row.attribute := 'conf_sysdate'    ; v_row.value := to_char( v_conf.conf_sysdate, c_date_format ); pipe row(v_row);
  v_row.attribute := 'conf_user'       ; v_row.value :=          v_conf.conf_user                    ; pipe row(v_row);
  v_row.attribute := 'level_id'        ; v_row.value := to_char( v_conf.level_id                    ); pipe row(v_row);
  v_row.attribute := 'level_name'      ; v_row.value :=          v_conf.level_name                   ; pipe row(v_row);
  v_row.attribute := 'check_interval'  ; v_row.value := to_char( v_conf.check_interval              ); pipe row(v_row);
  v_row.attribute := 'enable_ascii_art'; v_row.value :=          v_conf.enable_ascii_art             ; pipe row(v_row);
  v_row.attribute := 'client_prefs'    ; v_row.value :=          v_conf.client_prefs                 ; pipe row(v_row);
end conf;

--------------------------------------------------------------------------------

function client_prefs
return t_client_prefs_tab pipelined is
  v_list  t_client_prefs_tab_i;
begin
  v_list := utl_get_client_prefs_tab;
  for i in 1 .. v_list.count loop
    pipe row(v_list(i));
  end loop;
end client_prefs;

--------------------------------------------------------------------------------

procedure purge (
  p_min_level in integer default c_level_info,
  p_min_days  in number  default 30 )
is
  pragma autonomous_transaction;
begin
  assert (
    p_min_level in (1,2,3,4,5),
    'Minimum level must be 1 (error), 2 (warning), 3 (info), 4 (debug) or 5 (trace).');
  assert (
    c_console_owner = sys_context('USERENV','SESSION_USER'),
    'Only the owner of the package console is allowed to purge log entries.');
  delete from console_logs
    where level_id >= p_min_level
      and permanent = 'N'
      and log_time <= localtimestamp - p_min_days;
  commit;
end purge;

--------------------------------------------------------------------------------

procedure purge_all is
begin
  purge(
    p_min_level => 1,
    p_min_days  => -1 -- to be sure we delete everything (localtimestamp - -1 is the same time tomorrow)
  );
end purge_all;

--------------------------------------------------------------------------------

procedure purge_job_create (
  p_repeat_interval in varchar2 default 'FREQ=DAILY;BYHOUR=1;' ,
  p_min_level       in integer  default c_level_info           ,
  p_min_days        in number   default 30                     )
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
          job_name        => i.job_name                                                                   ,
          job_type        => 'PLSQL_BLOCK'                                                                ,
          job_action      => 'begin console.purge(p_min_level=>#MIN_LEVEL#,p_min_days=>#MIN_DAYS#); end;' ,
          start_date      => sysdate                                                                      ,
          repeat_interval => '#REPEAT_INTERVAL#'                                                          ,
          enabled         => true                                                                         ,
          auto_drop       => false                                                                        ,
          comments        => 'Purge CONSOLE log entries.'                                                 );
      end loop;
    end;
  ]',
  '#CONSOLE_JOB_NAME#', c_console_job_name ),
  '#REPEAT_INTERVAL#' , p_repeat_interval  ),
  '#MIN_LEVEL#'       , p_min_level        ),
  '#MIN_DAYS#'        , p_min_days         );
end purge_job_create;

--------------------------------------------------------------------------------

procedure purge_job_drop is
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
end purge_job_drop;

--------------------------------------------------------------------------------

procedure purge_job_enable is
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
end purge_job_enable;

--------------------------------------------------------------------------------

procedure purge_job_disable is
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
end purge_job_disable;

--------------------------------------------------------------------------------

procedure purge_job_run is
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
end purge_job_run;


--------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS
--------------------------------------------------------------------------------

function utl_escape_md_tab_text (p_text in varchar2) return varchar2 is
begin
  return replace(replace(replace(replace(p_text,
    c_crlf,   ' '),
    c_lf,     ' '),
    c_cr,     ' '),
    '|', '&#124;');
end utl_escape_md_tab_text;

--------------------------------------------------------------------------------

function utl_last_error return varchar2 is
  v_return t_32kb;
begin
  if sys.utl_call_stack.error_depth > 0 and sys.utl_call_stack.backtrace_depth > 0 then
    if sys.utl_call_stack.error_number(1) != 6512 and sys.utl_call_stack.error_msg(1) != coalesce(g_prev_error_msg, 'null') then
      --Get the last backtrace line number and also the error message
      v_return := ' (line ' || to_char(sys.utl_call_stack.backtrace_line(sys.utl_call_stack.backtrace_depth)) ||
        ', ORA-' || trim(to_char(sys.utl_call_stack.error_number(1), '00009')) || ' ' ||
        utl_replace_linebreaks(sys.utl_call_stack.error_msg(1)) || ')';
      --Set the new error message as the last error message.
      g_prev_error_msg := sys.utl_call_stack.error_msg(1);
    else
      --Get only the last backtrace line number
      v_return := ' (line ' || to_char(sys.utl_call_stack.backtrace_line(sys.utl_call_stack.backtrace_depth)) || ')';
    end if;
  end if;

  return v_return;
end utl_last_error;

--------------------------------------------------------------------------------

function utl_logging_is_enabled (
  p_level in integer )
return boolean is
begin
  if g_conf_check_sysdate < sysdate then
    utl_set_session_conf;
  end if;
  return g_conf_level >= p_level or sqlcode != 0;
end utl_logging_is_enabled;

--------------------------------------------------------------------------------

function utl_normalize_label (p_label in varchar2) return varchar2 is
begin
  return coalesce(substr(p_label, 1, 128), c_default_label);
end utl_normalize_label;

--------------------------------------------------------------------------------

function utl_replace_linebreaks (
  p_text         in varchar2             ,
  p_replace_with in varchar2 default ' ' )
return varchar2 is
begin
  return replace(replace(replace(p_text,
    c_crlf, p_replace_with),
    c_lf,   p_replace_with),
    c_cr,   p_replace_with);
end utl_replace_linebreaks;

--------------------------------------------------------------------------------

/* HOW TO CHECK THE RESULT CACHE
select id, name, cache_id, type, status, invalidations, scan_count
  from v$result_cache_objects
 where name like '%CONSOLE%'
   and status != 'Invalid';
*/
function utl_get_conf
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
    -- set defaults
    v_row.conf_id          := c_conf_id;
    v_row.conf_sysdate     := sysdate;
    v_row.conf_user        := 'autodefault';
    v_row.level_id         := c_level_error;
    v_row.level_name       := level_name(c_level_error);
    v_row.check_interval   := c_check_interval_default;
    v_row.enable_ascii_art := to_string(c_enable_ascii_art);
    return v_row;
end utl_get_conf;

--------------------------------------------------------------------------------

procedure utl_set_conf (
  p_conf in console_conf%rowtype )
is
  pragma autonomous_transaction;
begin
  update console_conf set row = p_conf where conf_id = c_conf_id;
  if sql%rowcount = 0 then
    insert into console_conf values p_conf;
  end if;
  commit;
end utl_set_conf;

--------------------------------------------------------------------------------

procedure utl_set_client_prefs (
  p_prefs in varchar2 )
is
  pragma autonomous_transaction;
  procedure update_client_prefs is
  begin
    update console_conf set client_prefs = p_prefs where conf_id = c_conf_id;
  end;
begin
  assert(lengthb(p_prefs) <= 4000, 'Sorry, we cannot save your client preferencs - seems you have too many session in debug mode.');
  update_client_prefs;
  if sql%rowcount = 0 then
    utl_set_conf(utl_get_conf); -- utl_get_conf handles not existing conf with default values
    update_client_prefs;
  end if;
  commit;
end utl_set_client_prefs;

--------------------------------------------------------------------------------

function utl_get_client_prefs (
  p_all_prefs_csv     in varchar2 ,
  p_client_identifier in varchar2 )
return t_client_prefs_row is
  v_all_prefs_csv   t_32kb := p_all_prefs_csv;
  v_csv             t_32kb;
  v_prefs           t_client_prefs_row;
  v_boolean_options t_int;
  v_start           t_int;
  v_stop            t_int;
begin
  if v_all_prefs_csv is not null then
    v_all_prefs_csv := replace(v_all_prefs_csv, c_cr, c_lf);
    v_start := instr(v_all_prefs_csv, p_client_identifier||',');
    v_stop  := instr(v_all_prefs_csv, c_lf, v_start);
    v_csv   := substr(v_all_prefs_csv, v_start, v_stop - v_start);
    --too slow: also see tests/performance.sql
    --v_csv   := regexp_substr(p_all_prefs_csv, '^'||p_client_identifier||',.*$', 1, 1, 'im');
    if v_csv is not null then
      v_prefs.exit_sysdate := utl_csv_get_exit_sysdate(v_csv);
      -- For performance reasons we will proceed the other columns only, if needed.
      -- This function is called every time a session is initializing the package console.
      if v_prefs.exit_sysdate >= sysdate then
        --v_prefs.client_identifier := utl_csv_get_client_identifier ( v_csv );
        v_boolean_options         := utl_csv_get_boolean_options   ( v_csv );
        v_prefs.level_id          := utl_csv_get_level             ( v_csv );
        v_prefs.check_interval    := utl_csv_get_check_interval    ( v_csv );
        v_prefs.call_stack        := to_string ( bitand ( v_boolean_options, c_call_stack  ) = c_call_stack  );
        v_prefs.user_env          := to_string ( bitand ( v_boolean_options, c_user_env    ) = c_user_env    );
        v_prefs.apex_env          := to_string ( bitand ( v_boolean_options, c_apex_env    ) = c_apex_env    );
        v_prefs.cgi_env           := to_string ( bitand ( v_boolean_options, c_cgi_env     ) = c_cgi_env     );
        v_prefs.console_env       := to_string ( bitand ( v_boolean_options, c_console_env ) = c_console_env );
        v_prefs.level_name        := level_name ( v_prefs.level_id );
      end if;
    end if;
  end if;
  return v_prefs;
end utl_get_client_prefs;

--------------------------------------------------------------------------------

function utl_get_client_prefs_tab return t_client_prefs_tab_i is
  v_tab   t_client_prefs_tab_i;
  v_conf  console_conf%rowtype;
  v_prefs t_32kb;
  v_pos   t_int := 1;
  v_len   t_int;
  v_lf    t_int;
begin
  v_conf := utl_get_conf;
  v_prefs := replace(replace(replace(replace(v_conf.client_prefs,
    c_crlf, c_lf),
    c_cr  , c_lf),
    c_lflf, c_lf),
    c_lflf, c_lf);
  v_len := length(v_prefs);
  loop
    v_lf := nvl(instr(v_prefs, c_lf, v_pos), 0);
    exit when v_lf = 0;
    if v_lf > v_pos then
      v_tab(v_tab.count + 1) := utl_csv_to_client_prefs(substr(v_prefs, v_pos, v_lf - v_pos));
    end if;
    v_pos := v_lf + 1;
  end loop;
  return v_tab;
end utl_get_client_prefs_tab;

--------------------------------------------------------------------------------

function utl_get_clean_client_prefs_csv (
  p_client_identifier_to_remove in varchar2           default null ,
  p_client_prefs_to_append      in t_client_prefs_row default null )
return varchar2 is
  v_prefs t_32kb;
  v_tab   t_client_prefs_tab_i;
begin
  v_tab := utl_get_client_prefs_tab;
  for i in 1 .. v_tab.count loop
    --filter out invalid client pefs
    if  v_tab(i).client_identifier is not null
    and v_tab(i).level_id is not null
    and v_tab(i).call_stack is not null
    and v_tab(i).user_env is not null
    and v_tab(i).cgi_env is not null
    and v_tab(i).user_env is not null
    and v_tab(i).console_env is not null
    and v_tab(i).check_interval is not null
    and v_tab(i).exit_sysdate is not null
    and v_tab(i).exit_sysdate      >= sysdate
    and v_tab(i).client_identifier != nvl(p_client_identifier_to_remove, 'NULL_VALUE_DETECTED')
    then
      v_prefs := v_prefs || utl_client_prefs_to_csv(v_tab(i));
    end if;
  end loop;
  if p_client_prefs_to_append.client_identifier is not null then
    v_prefs := v_prefs || utl_client_prefs_to_csv(p_client_prefs_to_append);
  end if;
  return v_prefs;
end utl_get_clean_client_prefs_csv;

--------------------------------------------------------------------------------

function utl_remove_stale_client_prefs (
  p_all_prefs_csv     in varchar2 ,
  p_client_identifier in varchar2 )
return varchar2 is
  v_return t_32kb := p_all_prefs_csv;
begin
  return v_return;
end utl_remove_stale_client_prefs;

--------------------------------------------------------------------------------

function utl_csv_get_client_identifier (
  p_csv in varchar2 )
return varchar2 is
  v_stop t_int;
begin
  --csv format: client_identifier,level,boolean_options,check_interval,exit_sysdate
  v_stop := instr(p_csv, ',', -1, 4) - 1;
  return substrb(substr(p_csv, 1, v_stop), 1, 64);
end;

--------------------------------------------------------------------------------

function utl_csv_get_exit_sysdate (
  p_csv in varchar2 )
return date is
  v_return date;
begin
  --csv format: client_identifier,level,boolean_options,check_interval,exit_sysdate
  v_return := nvl(to_date(
    substr(
      p_csv,
      instr(p_csv, ',', -1, 1) + 1 -- first comma from the end + 1
    ) default null on conversion error,
    c_date_format_short
  ), sysdate - 1);
  return v_return;
end utl_csv_get_exit_sysdate;

--------------------------------------------------------------------------------

function utl_csv_get_check_interval (
  p_csv in varchar2 )
return integer is
  v_return t_int;
  v_start  t_int;
  v_stop   t_int;
begin
  --csv format: client_identifier,level,boolean_options,check_interval,exit_sysdate
  v_start := instr(p_csv, ',', -1, 2) + 1;
  v_stop  := instr(p_csv, ',', -1, 1);
  v_return := to_number(
    substr(
      p_csv,
      v_start,
      v_stop - v_start
    ) default c_check_interval_default on conversion error
  );
  return case when v_return not between c_check_interval_min and c_check_interval_max then c_check_interval_default else v_return end;
end utl_csv_get_check_interval;

--------------------------------------------------------------------------------

function utl_csv_get_boolean_options (
  p_csv in varchar2 )
return integer is
  v_start t_int;
  v_stop  t_int;
begin
  --csv format: client_identifier,level,boolean_options,check_interval,exit_sysdate
  v_start := instr(p_csv, ',', -1, 3) + 1;
  v_stop  := instr(p_csv, ',', -1, 2);
  return to_number (
    substr(
      p_csv,
      v_start,
      v_stop - v_start
    ) default 0 on conversion error
  );
end utl_csv_get_boolean_options;

--------------------------------------------------------------------------------

function utl_csv_get_level (
  p_csv in varchar2 )
return integer is
  v_return t_int;
  v_start  t_int;
  v_stop   t_int;
begin
  --csv format: client_identifier,level,boolean_options,check_interval,exit_sysdate
  v_start := instr(p_csv, ',', -1, 4) + 1;
  v_stop  := instr(p_csv, ',', -1, 3);
  v_return := to_number(
    substr(
      p_csv,
      v_start,
      v_stop - v_start
    ) default c_level_error on conversion error
  );
  return case when v_return not between c_level_error and c_level_trace then c_level_error else v_return end;
end utl_csv_get_level;

--------------------------------------------------------------------------------

function utl_csv_to_client_prefs (
  p_csv in varchar2)
return t_client_prefs_row is
  v_return          t_client_prefs_row;
  v_boolean_options t_int;
begin
  --csv format: client_identifier,level,boolean_options,check_interval,exit_sysdate
  v_boolean_options          := utl_csv_get_boolean_options   ( p_csv );
  v_return.exit_sysdate      := utl_csv_get_exit_sysdate      ( p_csv );
  v_return.client_identifier := utl_csv_get_client_identifier ( p_csv );
  v_return.level_id          := utl_csv_get_level             ( p_csv );
  v_return.check_interval    := utl_csv_get_check_interval    ( p_csv );
  v_return.call_stack        := to_string ( bitand ( v_boolean_options, c_call_stack  ) = c_call_stack  );
  v_return.user_env          := to_string ( bitand ( v_boolean_options, c_user_env    ) = c_user_env    );
  v_return.apex_env          := to_string ( bitand ( v_boolean_options, c_apex_env    ) = c_apex_env    );
  v_return.cgi_env           := to_string ( bitand ( v_boolean_options, c_cgi_env     ) = c_cgi_env     );
  v_return.console_env       := to_string ( bitand ( v_boolean_options, c_console_env ) = c_console_env );
  v_return.level_name        := level_name ( v_return.level_id );
  return v_return;
end utl_csv_to_client_prefs;

--------------------------------------------------------------------------------

function utl_client_prefs_to_csv (
  p_client_prefs in t_client_prefs_row )
return varchar2 is
  v_return t_32kb;
begin
  --csv format: client_identifier,level,boolean_options,check_interval,exit_sysdate
  return
    p_client_prefs.client_identifier                                             || ',' ||
    to_char(p_client_prefs.level_id)                                             || ',' ||
    to_char(
      case when p_client_prefs.call_stack  = 'true' then c_call_stack  else 0 end +
      case when p_client_prefs.user_env    = 'true' then c_user_env    else 0 end +
      case when p_client_prefs.apex_env    = 'true' then c_apex_env    else 0 end +
      case when p_client_prefs.cgi_env     = 'true' then c_cgi_env     else 0 end +
      case when p_client_prefs.console_env = 'true' then c_console_env else 0 end ) || ',' ||
    to_char(p_client_prefs.check_interval)                                       || ',' ||
    to_char(p_client_prefs.exit_sysdate, c_date_format_short)                    || c_lf;
end utl_client_prefs_to_csv;

--------------------------------------------------------------------------------

procedure utl_set_client_identifier is
begin
  g_conf_client_identifier := sys_context('USERENV', 'CLIENT_IDENTIFIER');
  if g_conf_client_identifier is null or g_conf_client_identifier = ':' then
    g_conf_client_identifier := c_client_id_prefix || sys.dbms_session.unique_session_id;
    sys.dbms_session.set_identifier(g_conf_client_identifier);
  end if;
end utl_set_client_identifier;

--------------------------------------------------------------------------------

procedure utl_set_session_conf is
  v_conf  console_conf%rowtype;
  v_prefs t_client_prefs_row;
begin
  v_conf  := utl_get_conf;
  v_prefs := utl_get_client_prefs(v_conf.client_prefs, g_conf_client_identifier);

  --If we have no real exit sysdate, we set it to 24 hours.
  --Session conf will be re-evaluated at least every 10 seconds.
  g_conf_exit_sysdate     := coalesce ( v_prefs.exit_sysdate         , sysdate + 1           );
  g_conf_check_interval   := coalesce ( v_prefs.check_interval       , v_conf.check_interval );
  g_conf_level            := coalesce ( v_prefs.level_id             , v_conf.level_id       );
  --
  g_conf_call_stack       := coalesce ( to_bool(v_prefs.call_stack)  , false                 );
  g_conf_user_env         := coalesce ( to_bool(v_prefs.user_env)    , false                 );
  g_conf_apex_env         := coalesce ( to_bool(v_prefs.apex_env)    , false                 );
  g_conf_cgi_env          := coalesce ( to_bool(v_prefs.cgi_env)     , false                 );
  g_conf_console_env      := coalesce ( to_bool(v_prefs.console_env) , false                 );
  --
  g_conf_enable_ascii_art := to_bool(v_conf.enable_ascii_art);
  --
  g_conf_check_sysdate    := least(g_conf_exit_sysdate, sysdate + 1/24/60/60 * g_conf_check_interval);

end utl_set_session_conf;

--------------------------------------------------------------------------------

function utl_create_log_entry (
  p_level           in integer                ,
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type
is
  pragma autonomous_transaction;
  v_row   console_logs%rowtype;
  v_cache t_32kb;
begin
  v_row.scope :=
    case
      when p_user_scope is not null then substrb(p_user_scope, 1, 256)
      else substrb(scope, 1, 256)
    end;

  -- This is the very first (possible) assignment to the row.message variable,
  -- so we can do it without our clob_append method.
  v_row.message :=
    case
      when p_message is not null then p_message || c_lflf
      when sqlcode != 0 then sqlerrm || c_lflf
      else null
    end;

  -- Add params, if any
  if g_params.count > 0 then
    clob_append(v_row.message, v_cache, '#### Parameters' || c_lflf || to_md_tab_header('Parameter Name'));
    for i in 1 .. g_params.count loop
      clob_append(v_row.message, v_cache, to_md_tab_data(g_params(i).attribute, g_params(i).value, c_param_value_max_length));
    end loop;
    clob_append(v_row.message, v_cache, c_lf);
    g_params.delete;

  end if;

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
    v_row.call_stack := substrb(call_stack, 1, 4000);
    if p_level = 1 then
      --We finally logged the saved stack, so we need to reset it.
      g_saved_stack.delete;
      g_prev_error_msg := null;
    end if;
  end if;

  if p_apex_env or g_conf_apex_env then
    clob_append(v_row.message, v_cache, apex_env);
  end if;

  if p_cgi_env or g_conf_cgi_env then
    clob_append(v_row.message, v_cache, cgi_env);
  end if;

  if p_console_env or g_conf_console_env then
    clob_append(v_row.message, v_cache, console_env);
  end if;

  if p_user_env or g_conf_user_env then
    clob_append(v_row.message, v_cache, user_env);
  end if;

  clob_flush_cache(v_row.message, v_cache);

  v_row.log_time          := localtimestamp;
  v_row.level_id          := p_level;
  v_row.level_name        := level_name(p_level);
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

  insert into console_logs values v_row returning log_id into v_row.log_id;
  commit;

  return v_row.log_id;
end utl_create_log_entry;

--------------------------------------------------------------------------------

--package inizialization
begin
  utl_set_client_identifier;
  utl_set_session_conf;
end console;
/

prompt - Type T_CONSOLE (body)
create or replace type body t_console as
  constructor function t_console 
  return self as result is
  begin
    self.dummy_attribute := 1;
    return;
  end;


  member function add_param(
    self in t_console  , 
    p_name in varchar2 , 
    p_value in varchar2) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console  , 
    p_name in varchar2 , 
    p_value in varchar2) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;


  member function add_param(
    self in t_console  , 
    p_name in varchar2 , 
    p_value in number  ) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console  , 
    p_name in varchar2 , 
    p_value in number  ) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in date   ) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in date   ) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console   , 
    p_name in varchar2  , 
    p_value in timestamp) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console   , 
    p_name in varchar2  , 
    p_value in timestamp) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console                  , 
    p_name in varchar2                 , 
    p_value in timestamp with time zone) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console                  ,
    p_name in varchar2                 , 
    p_value in timestamp with time zone) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console                        , 
    p_name in varchar2                       , 
    p_value in timestamp with local time zone) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console                        , 
    p_name in varchar2                       , 
    p_value in timestamp with local time zone) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console                , 
    p_name in varchar2               , 
    p_value in interval year to month) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console                , 
    p_name in varchar2               , 
    p_value in interval year to month) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console                , 
    p_name in varchar2               , 
    p_value in interval day to second) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console                , 
    p_name in varchar2               , 
    p_value in interval day to second) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in boolean) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in boolean) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in clob   ) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in clob   ) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in xmltype) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in xmltype) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  
end;
/
declare
  v_count pls_integer;
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count = 0 then
    begin
      -- without execute immediate this script will raise an error when the package console is not valid
      select count(*) into v_count from user_scheduler_jobs where job_name = 'CONSOLE_PURGE';
      if v_count = 0 then
        dbms_output.put_line('- Job CONSOLE_PURGE not found, run creation command with the defaults (purge entries of level info after 30 days)');
        execute immediate 'begin console.purge_job_create; end;';
      else
        dbms_output.put_line('- Job CONSOLE_PURGE found, no action required');
      end if;
    exception
      when others then
        dbms_output.put_line('A T T E N T I O N  -  A N  E R R O R  O C C U R E D');
        dbms_output.put_line('- Unable to check/create the purge job. You can purge old log entries with the procedures console.purge and purge_all by yourself.');
        dbms_output.put_line('- You can also try to create the purge job by youself with this code: begin console.purge_job_create; end;');
        dbms_output.put_line('- The oracle error on check/create the purge job was: ' || sqlerrm);
    end;
  end if;
end;
/


-- check for errors in package console
declare
  procedure check_errors (
    p_object_name in varchar2 )
  is
    v_count pls_integer;
  begin
    select count(*)
      into v_count
      from user_errors
     where name = p_object_name;
    if v_count > 0 then
      dbms_output.put_line('- Type ' || p_object_name || ' has errors :-(');
      for i in (
          select name || case when type like '%BODY' then ' body' end || ', ' ||
                 'line ' || line || ', ' ||
                 'column ' || position || ', ' ||
                 attribute  || ': ' ||
                 text as message
            from user_errors
           where name = p_object_name
           order by name, line, position )
      loop
          dbms_output.put_line('- ' || i.message);
      end loop;
    end if;
  end check_errors;
begin
  check_errors ('CONSOLE');
  check_errors ('T_CONSOLE');
end;
/

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
    execute immediate replace( q'[
      -- We are doing a direct insert to create a log entry independent of the current log level.
      declare
        v_row console_logs%rowtype;
      begin
        v_row.log_time    := localtimestamp;
        v_row.level_id    := 3;
        v_row.level_name  := console.level_name(3);
        v_row.permanent   := 'Y';
        v_row.scope       := 'Library Installation';
        v_row.message     := '{o,o} CONSOLE v#CONSOLE_VERSION# installed';
        insert into console_logs values v_row;
        commit;
      end;]', '#CONSOLE_VERSION#', v_console_version);
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




