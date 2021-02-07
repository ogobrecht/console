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
  v_utils_public   varchar2(5) := 'FALSE'; -- Make utilities public available (for testing or other usages).
begin

  --Basic settings
  execute immediate 'alter session set plsql_warnings = ''enable:all,disable:5004,disable:6005,disable:6006,disable:6010,disable:6027''';
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
    || 'UTILS_PUBLIC:'   || v_utils_public   || '''';

end;
/

declare
  v_count pls_integer;
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_CONSTRAINT_MESSAGES';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_CONSTRAINT_MESSAGES not found, run creation command');
    execute immediate q'{
      create table console_constraint_messages (
        constraint_name  varchar2 (128 byte)  not null  ,
        message          varchar2 (512 byte)  not null  ,
        --
        constraint  console_constraint_messages_pk  primary key (constraint_name)
      ) organization index
    }';
  else
    dbms_output.put_line('- Table CONSOLE_CONSTRAINT_MESSAGES found, no action required');
  end if;
end;
/

comment on table  console_constraint_messages                 is 'Lookup user friendly error messages for your constraints.';
comment on column console_constraint_messages.constraint_name is 'Name of the constraint, primary key.';
comment on column console_constraint_messages.message         is 'Your friendly error message, when the constraint is violated.';




declare
  v_count pls_integer;
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_LEVELS';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_LEVELS not found, run creation command');
    execute immediate q'{
      create table console_levels (
        id    number   ( 1,0)     not null  ,
        name  varchar2 (10 byte)  not null  ,
        --
        constraint  console_levels_pk  primary key (id)                 ,
        constraint  console_levels_uk  unique      (name)               ,
        constraint  console_levels_ck  check       (id in (0,1,2,3,4))
      ) organization index
    }';
  else
    dbms_output.put_line('- Table CONSOLE_LEVELS found, no action required');
  end if;
end;
/

--will not run, when called in the same block as the table creation
declare
  v_count pls_integer;
begin
  select count(*) into v_count from console_levels;
  if v_count = 0 then
    insert into console_levels (id, name) values (0, 'Permanent');
    insert into console_levels (id, name) values (1, 'Error');
    insert into console_levels (id, name) values (2, 'Warning');
    insert into console_levels (id, name) values (3, 'Info');
    insert into console_levels (id, name) values (4, 'Verbose');
    commit;
  end if;
end;
/

comment on table  console_levels      is 'Catalog table for the log levels.';
comment on column console_levels.id   is 'ID of the level, primary key, manual managed.';
comment on column console_levels.name is 'Name of the level.';




declare
  v_count pls_integer;
  --
  procedure create_index (p_column_list varchar2, p_postfix varchar2) is
  begin
    with t as (
      select listagg(column_name, ', ') within group(order by column_position) as index_column_list
        from user_ind_columns
      where table_name = 'CONSOLE_SESSIONS'
      group by index_name
    )
    select count(*)
      into v_count
      from t
    where index_column_list = p_column_list;
    if v_count = 0 then
      dbms_output.put_line('- Index for CONSOLE_SESSIONS column list ' || p_column_list || ' not found, run creation command');
      execute immediate 'create index CONSOLE_SESSIONS_' || p_postfix || ' on CONSOLE_SESSIONS (' || p_column_list || ')';
    else
      dbms_output.put_line('- Index for CONSOLE_SESSIONS column list ' || p_column_list || ' found, no action required');
    end if;
  end;
  --
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_SESSIONS';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_SESSIONS not found, run creation command');
    execute immediate q'{
      create table console_sessions (
        client_identifier  varchar2 (64 byte)  not null  ,
        log_level          number   ( 1,0)     not null  ,
        start_date         date                not null  ,
        end_date           date                not null  ,
        cache_size         number   ( 4,0)     not null  ,
        cache_duration     number   ( 2,0)     not null  ,
        user_env           varchar2 ( 1 byte)  not null  ,
        apex_env           varchar2 ( 1 byte)  not null  ,
        cgi_env            varchar2 ( 1 byte)  not null  ,
        console_env        varchar2 ( 1 byte)  not null  ,
        --
        constraint  console_sessions_pk   primary key  (client_identifier)                    ,
        constraint  console_sessions_fk   foreign key  (log_level) references console_levels  ,
        constraint  console_sessions_ck1  check        (user_env    in ('Y','N'))             ,
        constraint  console_sessions_ck2  check        (apex_env    in ('Y','N'))             ,
        constraint  console_sessions_ck3  check        (cgi_env     in ('Y','N'))             ,
        constraint  console_sessions_ck4  check        (console_env in ('Y','N'))
      ) organization index
    }';
  else
    dbms_output.put_line('- Table CONSOLE_SESSIONS found, no action required');
  end if;

    create_index ('END_DATE', 'IX1');

end;
/

comment on table  console_sessions                   is 'Holds the sessions that are initialized for debugging. Used to manage the global context.';
comment on column console_sessions.client_identifier is 'The client identifier provided by the application or console itself.';
comment on column console_sessions.log_level         is 'The defined log level. Any session not listed here has the default log level of 1 (error).';
comment on column console_sessions.start_date        is 'The logging start date for the nominated client identifier.';
comment on column console_sessions.end_date          is 'The logging end date for the nominated client identifier.';
comment on column console_sessions.cache_duration    is 'The number of seconds a session in logging mode looks for a changed configuration and flushes the cached log entries. Defaults to 10.';
comment on column console_sessions.cache_size        is 'The number of log entries to cache before they are written down into the log table, if not already written by the end of the cache duration. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shered environments like APEX.';
comment on column console_sessions.user_env          is 'Should the user environment be included.';
comment on column console_sessions.apex_env          is 'Should the APEX environment be included.';
comment on column console_sessions.cgi_env           is 'Should the CGI environment be included.';
comment on column console_sessions.console_env       is 'Should the console environment be included.';




declare
  v_count pls_integer;
  --
  procedure create_index (p_column_list varchar2, p_postfix varchar2) is
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
      execute immediate 'create index CONSOLE_LOGS_' || p_postfix || ' on CONSOLE_LOGS (' || p_column_list || ')';
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
        log_id             number   (   *,0)               generated by default  on null   as identity,
        log_time           timestamp with local time zone  default systimestamp  not null  ,
        log_level          number   (   1,0)                                     not null  ,
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
        constraint  console_logs_fk  foreign key (log_level)  references console_levels
      )
    }';
  else
    dbms_output.put_line('- Table CONSOLE_LOGS found, no action required');
  end if;

  create_index ('LOG_TIME, LOG_LEVEL', 'IX1');
  create_index ('CLIENT_IDENTIFIER', 'IX2');

end;
/

comment on table  console_logs                   is 'Table for log entries of the package CONSOLE. Column names are mostly driven by the attribute names of SYS_CONTEXT(''USERENV'') and DBMS_SESSION for easier mapping and clearer context.';
comment on column console_logs.log_id            is 'Primary key based on a sequence.';
comment on column console_logs.log_time          is 'Log entry timestamp.';
comment on column console_logs.log_level         is 'Log entry level. Can be 0 (permanent), 1 (error), 2 (warning), 3 (info) or 4 (verbose).';
comment on column console_logs.scope             is 'The current unit/module in which the log was generated (OWNER.PACKAGE.MODULE.SUBMODULE, line number). Couls also be an external scope provided by the user.';
comment on column console_logs.message           is 'The log message itself and in case of an error or trace the call stack informaton.';
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




prompt - Package CONSOLE (spec)
create or replace package console authid definer is

c_name    constant varchar2 ( 30 byte ) := 'Oracle Instrumentation Console'       ;
c_version constant varchar2 ( 10 byte ) := '0.9.0'                                ;
c_url     constant varchar2 ( 40 byte ) := 'https://github.com/ogobrecht/console' ;
c_license constant varchar2 ( 10 byte ) := 'MIT'                                  ;
c_author  constant varchar2 ( 20 byte ) := 'Ottmar Gobrecht'                      ;

c_permanent constant pls_integer := 0 ;
c_error     constant pls_integer := 1 ;
c_warning   constant pls_integer := 2 ;
c_info      constant pls_integer := 3 ;
c_verbose   constant pls_integer := 4 ;


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
-- PUBLIC CONSTANTS, TYPES, GLOBALS
--------------------------------------------------------------------------------
c_identifier_length   constant pls_integer := 128;
subtype t_identifier  is varchar2 (c_identifier_length char);

--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------

procedure permanent (p_message clob);
/**

Log a message with the level 0 (permanent). These messages will not be deleted
on cleanup.

**/

--------------------------------------------------------------------------------

procedure error (
  p_message         clob     default null  ,
  p_trace           boolean  default true  ,
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
  p_trace           boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return integer;
/**

Log a message with the level 1 (error).

This is an overloaded function which returns the `log_id` as a reference for
further investigation by a support team. It can be used for example in an [APEX
error handling
function](https://docs.oracle.com/en/database/oracle/application-express/20.2/aeapi/Example-of-an-Error-Handling-Function.html#GUID-2CD75881-1A59-4787-B04B-9AAEC14E1A82).

**/

--------------------------------------------------------------------------------

procedure warn (
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
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

--------------------------------------------------------------------------------

procedure info (
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
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

--------------------------------------------------------------------------------

procedure log(
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
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

--------------------------------------------------------------------------------

procedure debug (
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  );
/**

Log a message with the level 4 (verbose).

**/

--------------------------------------------------------------------------------

procedure trace (
  p_message         clob     default null  ,
  p_trace           boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  );
/**

Logs a call stack with the level 3 (info).

**/

--------------------------------------------------------------------------------

procedure time (
  p_label varchar2 default null );
/**

Starts a new timer. Call `console.time_end([label]) to stop the timer and get or
log the elapsed time.

EXAMPLE 1

```sql
--Set you own session in logging mode (defaults: level 3[info] for the next 60 minutes).
exec console.init;

begin
  console.time('myLabel');

  --Do your stuff here.
  for i in 1 .. 100000 loop
    null;
  end loop;

  --Log the time (if log level >= 3:info).
  console.time_end('myLabel');
end;
{{/}}

--Stop logging mode of your own session.
exec console.stop;
```

EXAMPLE 2

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

  --Return the runtime (no logging, therefore log level does not matter).
  dbms_output.put_line(v_my_label || console.time_end(v_my_label) );
end;
{{/}}
```

**/

procedure time_end (
  p_label varchar2 default null );

function time_end (
  p_label varchar2 default null )
return varchar2;

--------------------------------------------------------------------------------

procedure count (
  p_label varchar2 default null );
/**

Starts a new counter. Call `console.count_end([label]) to stop the counter and get or
log the count value.

EXAMPLE 1

```sql
--Set you own session in logging mode (defaults: level 3=info for the next 60 minutes).
exec console.init;

begin
  --Do your stuff here.
  for i in 1 .. 1000 loop
    if mod(i, 3) = 0 then
      console.count('myLabel');
    end if;
  end loop;

  --Log your count value (if log level >= 3:info).
  console.count_end('myLabel');
end;
{{/}}

--Stop logging mode of your own session.
exec console.stop;
```

EXAMPLE 2

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

  --Return your count value (no logging, therefore log level does not matter).
  dbms_output.put_line(v_my_label || console.count_end(v_my_label) );
end;
{{/}}
```

**/

procedure count_end (
  p_label varchar2 default null );

function count_end (
  p_label varchar2 default null )
return varchar2;

--------------------------------------------------------------------------------

procedure assert (
  p_expression boolean,
  p_message    varchar2
);
/**

If the given expression evaluates to false, an error is raised with the given message.

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
-- PUBLIC HELPER METHODS
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

procedure action (
  p_action varchar2
);
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

function my_client_identifier return varchar2;
/**

Returns the current session identifier of the own session. This information is cached in a
package variable and determined on package initialization.

```sql
select console.context_available_yn from dual;
```

**/

--------------------------------------------------------------------------------

function my_log_level return integer;
/**

Returns the current log level of the own session. This information is cached in a
package variable for performance reasons and reevaluated every 10 seconds.

```sql
select console.context_available_yn from dual;
```

**/

--------------------------------------------------------------------------------

procedure init (
  p_client_identifier varchar2                , -- The client identifier provided by the application or console itself.
  p_log_level         integer  default c_info , -- Level 2 (warning), 3 (info) or 4 (verbose).
  p_log_duration      integer  default 60     , -- The number of minutes the session should be in logging mode. Allowed values: 1 to 1440 minutes (24 hours).
  p_cache_size        integer  default 0      , -- The number of log entries to cache before they are written down into the log table, if not already written by the end of the cache duration. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shered environments like APEX. Allowed values: 0 to 100 records.
  p_cache_duration    integer  default 10     , -- The number of seconds a session in logging mode looks for a changed configuration and flushes the cached log entries. Allowed values: 1 to 10 seconds.
  p_user_env          boolean  default false  , -- Should the user environment be included.
  p_apex_env          boolean  default false  , -- Should the APEX environment be included.
  p_cgi_env           boolean  default false  , -- Should the CGI environment be included.
  p_console_env       boolean  default false    -- Should the console environment be included.
);
/**

Starts the logging for a specific session.

To avoid spoiling the context with very long input the p_client_identifier parameter is
truncated after 64 characters before using it.

For easier usage there is an overloaded procedure available which uses always
your own client identifier.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDET ONLY FOR
MANAGING LOGGING MODES OF SESSIONS.

EXAMPLES

```sql
-- Dive into your own session with the default level of 3 (info) and the
-- default duration of 60 (minutes).
exec console.init;

-- With level 4 (verbose) for the next 15 minutes.
exec console.init(4, 15);

-- Using a constant for the level
exec console.init(console.c_verbose, 90);

-- Debug an APEX session...
exec console.init('APEX:8805903776765', 4, 90);

-- ... with the defaults
exec console.init('APEX:8805903776765');

-- Debug another session
begin
  console.init(
    p_client_identifier => 'APEX:8805903776765',
    p_log_level         => console.c_verbose,
    p_log_duration      => 15
  );
end;
{{/}}
```

**/

procedure init (
  p_log_level      integer default c_info , -- Level 2 (warning), 3 (info) or 4 (verbose).
  p_log_duration   integer default 60     , -- The number of minutes the session should be in logging mode. Allowed values: 1 to 1440 minutes (24 hours).
  p_cache_size     integer default 0      , -- The number of log entries to cache before they are written down into the log table, if not already written by the end of the cache duration. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shered environments like APEX. Allowed values: 0 to 100 records.
  p_cache_duration integer default 10     , -- The number of seconds a session in logging mode looks for a changed configuration and flushes the cached log entries. Allowed values: 1 to 10 seconds.
  p_user_env       boolean default false  , -- Should the user environment be included.
  p_apex_env       boolean default false  , -- Should the APEX environment be included.
  p_cgi_env        boolean default false  , -- Should the CGI environment be included.
  p_console_env    boolean default false    -- Should the console environment be included.
);

--------------------------------------------------------------------------------

procedure clear (
  p_client_identifier varchar2 default my_client_identifier -- client_identifier or unique_session_id
);
/**

Clears the cached log entries (if any).

This procedure is useful when you have initialized your own session with a cache
size greater then zero (for example 1000) and you take a look at the log entries
with the pipelined function `console.view_log_cache` during development. By
clearing the cache you can avoid spoiling your CONSOLE_LOGS table with entries
you dont need longer.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDET ONLY FOR
MANAGING LOGGING MODES OF SESSIONS.

**/

procedure stop (
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

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDET ONLY FOR
MANAGING LOGGING MODES OF SESSIONS.

**/

--------------------------------------------------------------------------------

function context_available_yn return varchar2;
/**

Checks the availability of the global context. Returns `Y`, if available and `N`
if not.

If the global context is not available we simulate it by using a package
variable. In this case you can only set your own session in logging mode with a
level of 2 (warning) or higher, because other sessions are not able to read the
package variable value in your session - this works only with a global
accessible context.

```sql
select console.context_available_yn from dual;
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

function extract_constraint_name ( p_sqlerrm varchar2 ) return varchar2;
/**

Exracts the constraint name out of a SQL error message.

Used to find user friendly error messages for violated constraints in the table
CONSOLE_CONSTRAINT_MESSAGES.

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

function get_call_stack return varchar2;
/**

Returns the current call stack.

Calls to the package CONSOLE are omitted.

EXAMPLE 1

```sql
set serveroutput on

create or replace package pkg1 is
  procedure do_stuff;
end;
{{/}}

create or replace package body pkg1 is
  procedure do_stuff is
    procedure sub1 is
      procedure sub2 is
        procedure sub3 is
        begin
          dbms_output.put_line(console.get_call_stack);
        end;
      begin
        sub3;
      end;
    begin
      sub2;
    end;
  begin
    sub1;
  end;
end;
{{/}}

begin
  pkg1.do_stuff;
end;
{{/}}
```

The example above will output:

```
- CALL STACK
  - PLAYGROUND.PKG1.DO_STUFF.SUB1.SUB2.SUB3, line 7
  - PLAYGROUND.PKG1.DO_STUFF.SUB1.SUB2, line 10
  - PLAYGROUND.PKG1.DO_STUFF.SUB1, line 13
  - PLAYGROUND.PKG1.DO_STUFF, line 16
  - anonymous_block, line 2
```

EXAMPLE 2

```sql
set serveroutput on

create or replace package pkg1 is
  procedure do_stuff;
end;
{{/}}

create or replace package body pkg1 is
  procedure do_stuff is
    procedure sub1 is
      procedure sub2 is
        procedure sub3 is
        begin
          raise_application_error (-20999, 'Demo');
        end;
      begin
        sub3;
      end;
    begin
      sub2;
    end;
  begin
    sub1;
  end;
end;
{{/}}

begin
  pkg1.do_stuff;
exception
  when others then
    dbms_output.put_line(console.get_call_stack);
  raise;
end;
{{/}}
```

The example above will output:

```
- ERROR STACK
  - ORA-20999 Demo
  - ORA-06512 at "PLAYGROUND.PKG1", line 7
  - ORA-06512 at "PLAYGROUND.PKG1", line 10
  - ORA-06512 at "PLAYGROUND.PKG1", line 13
  - ORA-06512 at "PLAYGROUND.PKG1", line 16
- ERROR BACKTRACE
  - PLAYGROUND.PKG1, line 7
  - PLAYGROUND.PKG1, line 10
  - PLAYGROUND.PKG1, line 13
  - PLAYGROUND.PKG1, line 16
  - anonymous_block, line 2
- CALL STACK
  - anonymous_block, line 5
```

**/


--------------------------------------------------------------------------------

function get_scope return varchar2;
/**

Returns the current call stack entry.

Calls to the package CONSOLE are omitted.

EXAMPLE 1

```sql
set serveroutput on
begin
  dbms_output.put_line(console.get_scope);
end;
{{/}}
```

The example above will output `anonymous_block, line 2`.

EXAMPLE 2

```sql
set serveroutput on

create or replace package pkg1 is
  procedure do_stuff;
end;
{{/}}

create or replace package body pkg1 is
  procedure do_stuff is
    procedure sub1 is
      procedure sub2 is
        procedure sub3 is
        begin
          dbms_output.put_line(console.get_scope);
        end;
      begin
        sub3;
      end;
    begin
      sub2;
    end;
  begin
    sub1;
  end;
end;
{{/}}

begin
  pkg1.do_stuff;
end;
{{/}}
```

The example above will output `PLAYGROUND.PKG1.DO_STUFF.SUB1.SUB2.SUB3, line 7`.

**/


--------------------------------------------------------------------------------

function to_bool ( p_string varchar2 ) return boolean;
/**

Converts a string to a boolean value.

Returns true when the uppercased, trimmed input is `Y`, `YES`, `1` or `TRUE`. In
all other cases (also on null) false is returned.

**/

--------------------------------------------------------------------------------

function to_yn ( p_bool boolean ) return varchar2;
/**

Converts a boolean value to a string.

Returns `Y` when the input is true and `N` if the input is false or null.

**/

--------------------------------------------------------------------------------


function get_constraint_message (
  p_constraint_name varchar2 )
return console_constraint_messages.message%type result_cache;
/**

Returns a user friendly error message for a constraint name.

The messages are looked up from the table CONSOLE_CONSTRAINT_MESSAGES.

**/

--------------------------------------------------------------------------------

$if $$apex_installed $then

function apex_error_handling (
  p_error in apex_error.t_error )
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

$end

--------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS (only visible when ccflag `utils_public` is set to true)
--------------------------------------------------------------------------------

$if $$utils_public $then

function  logging_enabled ( p_level integer ) return boolean;
function  read_row_from_sessions ( p_client_identifier varchar2 ) return console_sessions%rowtype result_cache;
function  util_normalize_label (p_label varchar2) return varchar2;
procedure check_context_availability;
procedure clear_all_context;
procedure clear_context ( p_client_identifier varchar2 );
procedure flush_log_cache;
procedure load_session_configuration;
procedure set_client_identifier;
--
function create_log_entry (
  p_level           integer,
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type;
procedure create_log_entry (
  p_level           integer,
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  );

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

c_tab                constant varchar2 ( 1 byte) := chr(9);
c_cr                 constant varchar2 ( 1 byte) := chr(13);
c_lf                 constant varchar2 ( 1 byte) := chr(10);
c_lflf               constant varchar2 ( 2 byte) := chr(10) || chr(10);
c_crlf               constant varchar2 ( 2 byte) := chr(13) || chr(10);
c_sep                constant varchar2 ( 1 byte) := ',';
c_at                 constant varchar2 ( 1 byte) := '@';
c_hash               constant varchar2 ( 1 byte) := '#';
c_slash              constant varchar2 ( 1 byte) := '/';
c_default_label      constant varchar2 (64 byte) := 'Default';
c_anon_block_ora     constant varchar2 (20 byte) := '__anonymous_block';
c_anonymous_block    constant varchar2 (20 byte) := 'anonymous_block';
c_client_id_prefix   constant varchar2 ( 6 byte) := '{o,o} ';
c_console_pkg_name   constant varchar2 (60 byte) := upper($$plsql_unit) || '.';
c_ctx_namespace      constant varchar2 (30 byte) := $$plsql_unit || '_' || substr(user, 1, 30 - length($$plsql_unit));
c_ctx_test_attribute constant varchar2 (15 byte) := 'TEST';
c_ctx_date_format    constant varchar2 (16 byte) := 'yyyymmddhh24miss';
c_ctx_log_level      constant varchar2 (15 byte) := 'LOG_LEVEL';
c_ctx_end_date       constant varchar2 (15 byte) := 'END_DATE';
c_ctx_cache_size     constant varchar2 (15 byte) := 'CACHE_SIZE';
c_ctx_cache_duration constant varchar2 (15 byte) := 'CACHE_DURATION';
c_ctx_user_env       constant varchar2 (15 byte) := 'USER_ENV';
c_ctx_apex_env       constant varchar2 (15 byte) := 'APEX_ENV';
c_ctx_cgi_env        constant varchar2 (15 byte) := 'CGI_ENV';
c_ctx_console_env    constant varchar2 (15 byte) := 'CONSOLE_ENV';
c_vc_max_size        constant pls_integer        := 32767;

subtype vc16    is varchar2 (   16 char);
subtype vc32    is varchar2 (   32 char);
subtype vc64    is varchar2 (   64 char);
subtype vc128   is varchar2 (  128 char);
subtype vc255   is varchar2 (  255 char);
subtype vc500   is varchar2 (  500 char);
subtype vc1000  is varchar2 ( 1000 char);
subtype vc2000  is varchar2 ( 2000 char);
subtype vc4000  is varchar2 ( 4000 char);
subtype vc_max  is varchar2 (32767 char);

g_conf_context_available      boolean;
g_conf_cache_valid_until_date date;
g_conf_client_identifier      varchar2 (64 byte);
g_conf_log_level              pls_integer;
g_conf_start_date             date;
g_conf_end_date               date;
g_conf_cache_size             integer;
g_conf_cache_duration         integer;
g_conf_user_env               boolean;
g_conf_apex_env               boolean;
g_conf_cgi_env                boolean;
g_conf_console_env            boolean;

type tab_timers is table of timestamp index by t_identifier;
type tab_counters is table of pls_integer index by t_identifier;
g_timers tab_timers;
g_counters tab_counters;

-------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS (forward declarations)
--------------------------------------------------------------------------------

$if not $$utils_public $then

function  logging_enabled ( p_level integer ) return boolean;
function  read_row_from_sessions ( p_client_identifier varchar2 ) return console_sessions%rowtype result_cache;
function  util_normalize_label (p_label varchar2) return varchar2;
procedure check_context_availability;
procedure clear_all_context;
procedure clear_context ( p_client_identifier varchar2 );
procedure flush_log_cache;
procedure load_session_configuration;
procedure set_client_identifier;
--
function create_log_entry (
  p_level           integer,
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return console_logs.log_id%type;
procedure create_log_entry (
  p_level           integer,
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  );

$end

--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------

procedure permanent (
  p_message clob )
is
begin
  create_log_entry (
    p_level      => c_permanent ,
    p_message    => p_message   );
end permanent;

--------------------------------------------------------------------------------

procedure error (
  p_message         clob     default null  ,
  p_trace           boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  create_log_entry (
    p_level           => c_error           ,
    p_message         => p_message         ,
    p_trace           => p_trace           ,
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
  p_trace           boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return integer is
begin
  return create_log_entry (
    p_level           => c_error           ,
    p_message         => p_message         ,
    p_trace           => p_trace           ,
    p_apex_env        => p_apex_env        ,
    p_cgi_env         => p_cgi_env         ,
    p_console_env     => p_console_env     ,
    p_user_env        => p_user_env        ,
    p_user_agent      => p_user_agent      ,
    p_user_scope      => p_user_scope      ,
    p_user_error_code => p_user_error_code ,
    p_user_call_stack => p_user_call_stack );
end;

--------------------------------------------------------------------------------

procedure warn (
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  if logging_enabled (c_warning) then
    create_log_entry (
      p_level           => c_warning         ,
      p_message         => p_message         ,
      p_trace           => p_trace           ,
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

--------------------------------------------------------------------------------

procedure info (
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  if logging_enabled (c_info) then
    create_log_entry (
      p_level           => c_info            ,
      p_message         => p_message         ,
      p_trace           => p_trace           ,
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

--------------------------------------------------------------------------------

procedure log (
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  if logging_enabled (c_info) then
    create_log_entry (
      p_level           => c_info            ,
      p_message         => p_message         ,
      p_trace           => p_trace           ,
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

--------------------------------------------------------------------------------

procedure debug (
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  if logging_enabled (c_verbose) then
    create_log_entry (
      p_level           => c_verbose         ,
      p_message         => p_message         ,
      p_trace           => p_trace           ,
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

--------------------------------------------------------------------------------

procedure trace (
  p_message         clob     default null  ,
  p_trace           boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  if logging_enabled (c_info) then
    create_log_entry (
      p_level           => c_info            ,
      p_message         => p_message         ,
      p_trace           => p_trace           ,
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

procedure time (
  p_label varchar2 default null )
is
begin
  g_timers(util_normalize_label(p_label)) := localtimestamp;
end time;

procedure time_end (
  p_label varchar2 default null )
is
  v_label t_identifier;
begin
  v_label := util_normalize_label(p_label);
  if g_timers.exists(v_label) then
    if logging_enabled (c_info) then
      create_log_entry (
        p_level   => c_info,
        p_message => v_label || ': ' || get_runtime (g_timers(v_label)) );
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
  v_label  t_identifier;
  v_return varchar2(50);
begin
  v_label := util_normalize_label(p_label);
  if g_timers.exists(v_label) then
    v_return :=  get_runtime(g_timers(v_label));
    g_timers.delete(v_label);
  else
    v_return := 'Timer `' || v_label || '` does not exist.';
  end if;
  return v_return;
end time_end;

--------------------------------------------------------------------------------

procedure count (
  p_label varchar2 default null )
is
  v_label t_identifier;
begin
  v_label := util_normalize_label(p_label);
  if g_counters.exists(v_label) then
    g_counters(v_label) := g_counters(v_label) + 1;
  else
    g_counters(v_label) := 1;
  end if;
end count;

procedure count_end (
  p_label varchar2 default null )
is
  v_label t_identifier;
begin
  v_label := util_normalize_label(p_label);
  if g_counters.exists(v_label) then
    if logging_enabled (c_info) then
      create_log_entry (
        p_level   => c_info,
        p_message => v_label || ': ' || to_char(g_counters(v_label)) );
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
  v_label   t_identifier;
  v_return  varchar2(50);
begin
  v_label := util_normalize_label(p_label);
  if g_counters.exists(v_label) then
    v_return := to_char(g_counters(v_label));
    g_counters.delete(v_label);
  else
    v_return := 'Counter `' || v_label || '` does not exist.';
  end if;
  return v_return;
end count_end;


--------------------------------------------------------------------------------
-- PUBLIC HELPER METHODS
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

procedure action (
  p_action varchar2 )
is
begin
  dbms_application_info.set_action (
    p_action );
end action;

--------------------------------------------------------------------------------

function my_client_identifier return varchar2 is
begin
  return g_conf_client_identifier;
end;

--------------------------------------------------------------------------------

function my_log_level return integer is
begin
  return g_conf_log_level;
end my_log_level;

--------------------------------------------------------------------------------

procedure init (
  p_client_identifier varchar2                ,
  p_log_level         integer  default c_info ,
  p_log_duration      integer  default 60     ,
  p_cache_size        integer  default 0      ,
  p_cache_duration    integer  default 10     ,
  p_user_env          boolean  default false  ,
  p_apex_env          boolean  default false  ,
  p_cgi_env           boolean  default false  ,
  p_console_env       boolean  default false  )
is
  pragma autonomous_transaction;
  v_row         console_sessions%rowtype;
  v_count       pls_integer;
  --
  procedure set_context (
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
      error ( 'Context not available, package var g_conf_context_available tells us it is ?!?' );
  end;
  --
begin
  assert ( p_log_level      in (2, 3, 4),       'Level needs to be 2 (warning), 3 (info) or 4 (verbose). ' ||
                                                'Level 1 (error) and 0 (permanent) are always logged '     ||
                                                'without a call to the init method.'                       );
  assert ( p_log_duration   between 1 and 1440, 'Duration needs to be between 1 and 1440 (minutes).'       );
  assert ( p_cache_size     between 0 and  100, 'Cache size needs to be between 1 and 100 (log entries).'  );
  assert ( p_cache_duration between 1 and   10, 'Cache duration needs to be between 1 and 10 (seconds).'   );
  assert ( p_user_env       is not null,        'User env needs to be true or false (not null).'           );
  assert ( p_apex_env       is not null,        'APEX env needs to be true or false (not null).'           );
  assert ( p_cgi_env        is not null,        'CGI env needs to be true or false (not null).'            );
  assert ( p_console_env    is not null,        'Console env needs to be true or false (not null).'        );
  --
  v_row.client_identifier := substrb ( p_client_identifier, 1, 64 );
  v_row.log_level         := p_log_level;
  v_row.start_date        := localtimestamp;
  v_row.end_date          := localtimestamp + 1/24/60 * p_log_duration;
  v_row.cache_size        := p_cache_size;
  v_row.cache_duration    := p_cache_duration;
  v_row.user_env          := to_yn ( p_user_env    );
  v_row.apex_env          := to_yn ( p_apex_env    );
  v_row.cgi_env           := to_yn ( p_cgi_env     );
  v_row.console_env       := to_yn ( p_console_env );
  --
  select count(*) into v_count from console_sessions where client_identifier = p_client_identifier;
  if v_count = 0 then
    insert into console_sessions values v_row;
  else
    update console_sessions set row = v_row
     where client_identifier = v_row.client_identifier;
  end if;
  commit;
  --
  if g_conf_context_available then
    set_context ( c_ctx_log_level      , to_char ( v_row.log_level      )                     , p_client_identifier );
    set_context ( c_ctx_end_date       , to_char ( v_row.end_date       , c_ctx_date_format ) , p_client_identifier );
    set_context ( c_ctx_cache_size     , to_char ( v_row.cache_size     )                     , p_client_identifier );
    set_context ( c_ctx_cache_duration , to_char ( v_row.cache_duration )                     , p_client_identifier );
    set_context ( c_ctx_user_env       , to_char ( v_row.user_env       )                     , p_client_identifier );
    set_context ( c_ctx_apex_env       , to_char ( v_row.apex_env       )                     , p_client_identifier );
    set_context ( c_ctx_cgi_env        , to_char ( v_row.cgi_env        )                     , p_client_identifier );
    set_context ( c_ctx_console_env    , to_char ( v_row.console_env    )                     , p_client_identifier );
  end if;

  -- If we want to monitor our own session, wee need to load the configuration
  -- data from the context or table into the cache (package variables).
  -- Otherwise we need to wait until the cache duration is over (which defaults
  -- to 10 seconds) and the package reloads the configuration from the context
  -- or table on next call of a public logging method.
  if p_client_identifier = g_conf_client_identifier then
    load_session_configuration;
  end if;
end init;

procedure init (
  p_log_level      integer default c_info ,
  p_log_duration   integer default 60     ,
  p_cache_size     integer default 0      ,
  p_cache_duration integer default 10     ,
  p_user_env       boolean default false  ,
  p_apex_env       boolean default false  ,
  p_cgi_env        boolean default false  ,
  p_console_env    boolean default false  )
is
begin
  init (
    p_client_identifier => g_conf_client_identifier ,
    p_log_level         => p_log_level              ,
    p_log_duration      => p_log_duration           ,
    p_cache_duration    => p_cache_duration         ,
    p_cache_size        => p_cache_size             ,
    p_user_env          => p_user_env               ,
    p_apex_env          => p_apex_env               ,
    p_cgi_env           => p_cgi_env                ,
    p_console_env       => p_console_env            );
end init;

--------------------------------------------------------------------------------

procedure clear (
  p_client_identifier varchar2 default my_client_identifier )
is
begin
  null; -- FIXME implement
end;

--------------------------------------------------------------------------------

procedure stop (
  p_client_identifier varchar2 default my_client_identifier )
is
  pragma autonomous_transaction;
begin
  delete from console_sessions where client_identifier = p_client_identifier;
  commit;
  clear_context( p_client_identifier );
  -- If we monitor our own session, wee need to load the configuration
  -- data from the context or table into the cache (package variables).
  -- Otherwise we need to wait until the cache duration is over (which defaults
  -- to 10 seconds) and the package reloads the configuration from the context
  -- or table on next call of a public logging method.
  if p_client_identifier = g_conf_client_identifier then
    load_session_configuration;
    flush_log_cache;
  end if;
end;

--------------------------------------------------------------------------------

function context_available_yn return varchar2 is
begin
  return case when g_conf_context_available then 'Y' else 'N' end;
end;

--------------------------------------------------------------------------------

function version return varchar2 is
begin
  return c_version;
end;

--------------------------------------------------------------------------------

function extract_constraint_name(p_sqlerrm varchar2) return varchar2 is
begin
  return regexp_substr(p_sqlerrm, '\(\S+?\.(\S+?)\)', 1, 1, 'i', 1);
end;

--------------------------------------------------------------------------------

function get_runtime (p_start timestamp) return varchar2 is
  v_runtime varchar2(32);
begin
  v_runtime := to_char(localtimestamp - p_start);
  return substr(v_runtime, instr(v_runtime,':')-2, 15);
end get_runtime;

--------------------------------------------------------------------------------

function get_constraint_message (p_constraint_name varchar2) return console_constraint_messages.message%type result_cache is
v_message console_constraint_messages.message%type;
begin
  for i in (
    select message
      from console_constraint_messages
     where constraint_name = p_constraint_name )
  loop
    v_message := i.message;
  end loop;
  return v_message;
end;

--------------------------------------------------------------------------------

$if $$apex_installed $then

function apex_error_handling (
  p_error in apex_error.t_error )
return apex_error.t_error_result
is
  v_result          apex_error.t_error_result;
  v_reference_id    number;
  v_constraint_name varchar2(255);
  v_message         clob;
begin
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
        case when p_error.additional_info is not null then p_error.message || c_lf end ||
        case when p_error.error_statement is not null then p_error.error_statement || c_lf end;
        --FIXME what about other attributes like p_error.component?
      v_reference_id := error (
        p_message         => v_message               ,
        p_trace           => false                   ,
        p_user_error_code => p_error.ora_sqlcode     ,
        p_user_call_stack => p_error.error_backtrace );
      -- Change the message to the generic error message which doesn't expose
      -- any sensitive information.
      v_result.message := 'An unexpected internal application error has occurred. ' ||
                          'Please get in contact with your Oracle APEX support team and provide ' ||
                          'reference# ' || to_char(v_reference_id, '999G999G999G999G990') ||
                          ' for further investigation.';
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
      v_result.message := get_constraint_message( extract_constraint_name( p_error.ora_sqlerrm ));
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

$end

--------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS
--------------------------------------------------------------------------------

function util_normalize_label (p_label varchar2) return varchar2 is
begin
  return coalesce(substrb(p_label, 1, c_identifier_length), c_default_label);
end;

--------------------------------------------------------------------------------

function get_scope return varchar2 is
  v_return     vc_max;
  v_subprogram vc_max;
begin
  if utl_call_stack.dynamic_depth > 0 then
    --ignore 1, is always this function (get_call_stack) itself
    for i in 2 .. utl_call_stack.dynamic_depth
    loop
      --the replace changes `__anonymous_block` to `anonymous_block`
      v_subprogram := replace (
        utl_call_stack.concatenate_subprogram( utl_call_stack.subprogram(i) ),
        c_anon_block_ora,
        c_anonymous_block);
      --exclude console package from the call stack
      if instr ( upper(v_subprogram), c_console_pkg_name ) = 0 then
        v_return := v_return
          || case when utl_call_stack.owner(i) is not null then utl_call_stack.owner(i) || '.' end
          || v_subprogram || ', line ' || utl_call_stack.unit_line(i)
          || chr(10);
      end if;
      exit when v_return is not null;
    end loop;
  end if;
  return v_return;
end get_scope;

--------------------------------------------------------------------------------

function get_call_stack return varchar2
is
  v_return     vc_max;
  v_subprogram vc_max;
begin

  if utl_call_stack.error_depth > 0 then
    v_return := v_return || '- ERROR STACK' || chr(10);
    for i in 1 .. utl_call_stack.error_depth
    loop
      v_return := v_return
        || '  - ORA-'
        || trim(to_char(utl_call_stack.error_number(i), '00009')) || ' '
        || utl_call_stack.error_msg(i)
        || chr(10);
    end loop;
  end if;

  if utl_call_stack.backtrace_depth > 0 then
    v_return := v_return || '- ERROR BACKTRACE' || chr(10);
    for i in 1 .. utl_call_stack.backtrace_depth
    loop
      v_return := v_return
        || '  - '
        || coalesce( utl_call_stack.backtrace_unit(i), c_anonymous_block )
        || ', line ' || utl_call_stack.backtrace_line(i)
        || chr (10);
    end loop;
  end if;

  if utl_call_stack.dynamic_depth > 0 then
    v_return := v_return || '- CALL STACK' || chr(10);
    --ignore 1, is always this function (get_call_stack) itself
    for i in 2 .. utl_call_stack.dynamic_depth
    loop
      --the replace changes `__anonymous_block` to `anonymous_block`
      v_subprogram := replace(
        utl_call_stack.concatenate_subprogram ( utl_call_stack.subprogram(i) ),
        c_anon_block_ora,
        c_anonymous_block);
      --exclude console package from the call stack
      if instr( upper(v_subprogram), c_console_pkg_name ) = 0 then
        v_return := v_return
          || '  - '
          || case when utl_call_stack.owner(i) is not null then utl_call_stack.owner(i) || '.' end
          || v_subprogram || ', line ' || utl_call_stack.unit_line(i)
          || chr(10);
      end if;
    end loop;
  end if;

  return v_return;
end get_call_stack;

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

function to_yn (
  p_bool boolean )
return varchar2 is
begin
  return case when p_bool then 'Y' else 'N' end;
end;

--------------------------------------------------------------------------------

function logging_enabled (
  p_level integer )
return boolean is
begin
  if g_conf_cache_valid_until_date < sysdate then
    load_session_configuration;
  end if;
  return g_conf_log_level >= p_level or sqlcode != 0;
end logging_enabled;

--------------------------------------------------------------------------------

function create_log_entry (
  p_level           integer,
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
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
  v_row console_logs%rowtype;
begin
  v_row.scope := case
    when p_user_scope is not null then substrb(p_user_scope, 1, 256)
    else substrb(get_scope, 1, 256)
    end;
  v_row.message := case
    when p_message is not null then p_message
    when sqlcode != 0 then sqlerrm
    else null
    end;
  v_row.error_code := case
    when p_user_error_code is not null then p_user_error_code
    when sqlcode != 0 then sqlcode
    else null
    end;
  v_row.call_stack := case
    when p_user_call_stack is not null then substrb(p_user_call_stack, 1, 4000)
    when p_trace then substrb(get_call_stack, 1, 4000)
    else null
    end;
  if p_apex_env then
    null; --FIXME implement
  end if;
  if p_cgi_env then
    null; --FIXME implement
  end if;
  if p_console_env then
    null; --FIXME implement
  end if;
  if p_user_env then
    null; --FIXME implement
  end if;

  v_row.log_level         := p_level;
  v_row.session_user      := substrb ( sys_context ( 'USERENV', 'SESSION_USER'      ), 1, 32 );
  v_row.module            := substrb ( sys_context ( 'USERENV', 'MODULE'            ), 1, 48 );
  v_row.action            := substrb ( sys_context ( 'USERENV', 'ACTION'            ), 1, 32 );
  v_row.client_info       := substrb ( sys_context ( 'USERENV', 'CLIENT_INFO'       ), 1, 64 );
  v_row.client_identifier := substrb ( sys_context ( 'USERENV', 'CLIENT_IDENTIFIER' ), 1, 64 );
  v_row.ip_address        := substrb ( sys_context ( 'USERENV', 'IP_ADDRESS'        ), 1, 48 );
  v_row.host              := substrb ( sys_context ( 'USERENV', 'HOST'              ), 1, 64 );
  v_row.os_user           := substrb ( sys_context ( 'USERENV', 'OS_USER'           ), 1, 64 );
  v_row.os_user_agent     := substrb ( p_user_agent, 1, 200 );
  v_row.log_time          := systimestamp;

  insert into console_logs values v_row returning log_id into v_row.log_id;
  commit;
  return v_row.log_id;
end create_log_entry;

procedure create_log_entry (
  p_level           integer,
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
  v_log_id integer;
begin
  v_log_id := create_log_entry (
    p_level           => p_level           ,
    p_message         => p_message         ,
    p_trace           => p_trace           ,
    p_apex_env        => p_apex_env        ,
    p_cgi_env         => p_cgi_env         ,
    p_console_env     => p_console_env     ,
    p_user_env        => p_user_env        ,
    p_user_agent      => p_user_agent      ,
    p_user_scope      => p_user_scope      ,
    p_user_error_code => p_user_error_code ,
    p_user_call_stack => p_user_call_stack );
end;

--------------------------------------------------------------------------------

procedure flush_log_cache is
begin
  null; --FIXME implement
end;

--------------------------------------------------------------------------------

procedure clear_context (
  p_client_identifier varchar2 )
is
begin
  if g_conf_context_available then
    sys.dbms_session.clear_context(c_ctx_namespace, p_client_identifier);
  end if;
end clear_context;

--------------------------------------------------------------------------------

procedure clear_all_context is
begin
  if g_conf_context_available then
    sys.dbms_session.clear_all_context(c_ctx_namespace);
  end if;
end clear_all_context;

--------------------------------------------------------------------------------

/* HOW TO CHECK THE RESULT CACHE
select id, name, cache_id, type, status, invalidations, scan_count
  from v$result_cache_objects
 where name like '%CONSOLE%'
   and status != 'Invalid';
*/
function read_row_from_sessions (
  p_client_identifier varchar2 )
return console_sessions%rowtype result_cache is
  v_row console_sessions%rowtype;
begin
  for i in (
    select *
      from console_sessions
     where client_identifier = p_client_identifier
       and end_date >= sysdate)
  loop
    v_row := i;
  end loop;
  return v_row;
end read_row_from_sessions;

--------------------------------------------------------------------------------

procedure set_client_identifier is
begin
  g_conf_client_identifier := sys_context('USERENV', 'CLIENT_IDENTIFIER');
  if g_conf_client_identifier is null or g_conf_client_identifier = ':' then
    g_conf_client_identifier := c_client_id_prefix || dbms_session.unique_session_id;
    dbms_session.set_identifier(g_conf_client_identifier);
  end if;
end set_client_identifier;

--------------------------------------------------------------------------------

procedure check_context_availability is
begin
  sys.dbms_session.set_context(c_ctx_namespace, c_ctx_test_attribute, 'test');
  g_conf_context_available := true;
exception
  when insufficient_privileges then
    g_conf_context_available := false;
end check_context_availability;

--------------------------------------------------------------------------------

procedure load_session_configuration is
  v_row console_sessions%rowtype;
begin
  if g_conf_context_available then
    g_conf_end_date       := to_date   ( sys_context ( c_ctx_namespace, c_ctx_end_date       ) , c_ctx_date_format );
    g_conf_log_level      := to_number ( sys_context ( c_ctx_namespace, c_ctx_log_level      ) );
    g_conf_cache_size     := to_number ( sys_context ( c_ctx_namespace, c_ctx_cache_size     ) );
    g_conf_cache_duration := to_number ( sys_context ( c_ctx_namespace, c_ctx_cache_duration ) );
    g_conf_user_env       := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_user_env       ) );
    g_conf_apex_env       := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_apex_env       ) );
    g_conf_cgi_env        := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_cgi_env        ) );
    g_conf_console_env    := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_console_env    ) );
  else
    v_row := read_row_from_sessions (g_conf_client_identifier);
    --
    g_conf_end_date       :=           v_row.end_date        ;
    g_conf_log_level      :=           v_row.log_level       ;
    g_conf_cache_size     :=           v_row.cache_size      ;
    g_conf_cache_duration :=           v_row.cache_duration  ;
    g_conf_user_env       := to_bool ( v_row.user_env       );
    g_conf_apex_env       := to_bool ( v_row.apex_env       );
    g_conf_cgi_env        := to_bool ( v_row.cgi_env        );
    g_conf_console_env    := to_bool ( v_row.console_env    );
  end if;

  --handle nulls
  if g_conf_end_date is null then
     --We have no real conf until now, so we fake 24 hours.
     --Conf will be rechecked at least every 10 seconds.
    g_conf_end_date := sysdate + 1;
  elsif g_conf_end_date < sysdate then
    clear_context(g_conf_client_identifier);
  end if;
  g_conf_cache_valid_until_date := least(g_conf_end_date, sysdate + 1/24/60/60*10);
  --
  if g_conf_log_level is null then
    g_conf_log_level := 1;
  end if;
  --
  if g_conf_cache_size is null then
    g_conf_cache_size := 0;
  end if;
  --
  if g_conf_cache_duration is null then
    g_conf_cache_duration := 10;
  end if;

end load_session_configuration;

--------------------------------------------------------------------------------

--package inizialization
begin
  set_client_identifier;
  check_context_availability;
  load_session_configuration;
end console;
/

-- check for errors in package console and for existing context
declare
  v_count                pls_integer;
  v_context_available_yn varchar2(1 byte);
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count > 0 then
    dbms_output.put_line('- Package CONSOLE has errors :-(');
  else
    execute immediate 'select console.context_available_yn from dual' into v_context_available_yn;
    if v_context_available_yn = 'Y' then
      dbms_output.put_line('- Context available :-)');
    else
      dbms_output.put_line('- CONTEXT NOT AVAILABLE :-(');
      dbms_output.put_line('-  | No worries - you can still start with the instrumentation of your code.');
      dbms_output.put_line('-  | Until you have a context, console uses a table as the config storage for the sessions.');
      dbms_output.put_line('-  | When you (or your DBA) have the context created then simply reconnect and check the availability:');
      dbms_output.put_line('-  | select console.context_available_yn from dual;');
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
  v_count                pls_integer;
  v_context_available_yn varchar2( 1 byte);
  v_console_version      varchar2(10 byte);
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count = 0 then
    -- without execute immediate this script will raise an error when the package console is not valid
    execute immediate 'select console.version from dual' into v_console_version;
    execute immediate q'[begin console.permanent('{o,o} CONSOLE v]' || v_console_version || q'[ installed'); end;]';
    dbms_output.put_line('  .___.  ');
    dbms_output.put_line('  {o,o}  ');
    dbms_output.put_line('  /)__)   Hopefully you have now sharper debugging eyes with');
    dbms_output.put_line('  -"-"-   CONSOLE v' || v_console_version);
  end if;
end;
/
prompt




