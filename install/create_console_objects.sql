--DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT src/build.js
set define on
set serveroutput on
set verify off
set feedback off
set linesize 120
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback

prompt ORACLE INSTRUMENTATION CONSOLE: CREATE DATABASE OBJECTS
prompt - Project page https://github.com/ogobrecht/console
prompt - Set compiler flags
DECLARE
  v_apex_installed VARCHAR2(5) := 'FALSE'; -- Do not change (is set dynamically).
  v_utils_public   VARCHAR2(5) := 'TRUE'; -- Make utilities public available (for testing or other usages).
BEGIN
  FOR i IN (SELECT 1
              FROM all_objects
             WHERE object_type = 'SYNONYM'
               AND object_name = 'APEX_EXPORT')
  LOOP
    v_apex_installed := 'TRUE';
  END LOOP;

  -- Show unset compiler flags as errors (results for example in errors like "PLW-06003: unknown inquiry directive '$$UTILS_PUBLIC'")
  EXECUTE IMMEDIATE 'alter session set plsql_warnings = ''ENABLE:6003''';
  -- Finally set compiler flags
  EXECUTE IMMEDIATE 'alter session set plsql_ccflags = '''
    || 'APEX_INSTALLED:' || v_apex_installed || ','
    || 'UTILS_PUBLIC:'   || v_utils_public   || '''';
END;
/

declare
  v_count pls_integer;
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_LEVELS';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_LEVELS not found, run creation command');
    execute immediate q'{
      create table console_levels (
        id    number   (1,0)      not null  ,
        name  varchar2 (10 byte)  not null  ,
        --
        constraint console_levels_pk primary key (id)                  ,
        constraint console_levels_uk unique      (name)                ,
        constraint console_levels_ck check       (id in (0,1,2,3,4))
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
        log_level          number   (1,0)      not null  ,
        start_date         date                not null  ,
        end_date           date                not null  ,
        cache_size         number   (4,0)      not null  ,
        cache_duration     number   (2,0)      not null  ,
        user_env           varchar2 (1 byte)   not null  ,
        apex_env           varchar2 (1 byte)   not null  ,
        cgi_env            varchar2 (1 byte)   not null  ,
        console_env        varchar2 (1 byte)   not null  ,
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
        log_id             integer                                               generated by default on null as identity,
        log_time           timestamp with local time zone  default systimestamp  not null  ,
        log_level          number (1,0)                                          not null  ,
        scope              varchar2 (1000 byte)                                            ,
        message            clob                                                            ,
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
        constraint console_logs_fk foreign key (log_level) references console_levels
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
comment on column console_logs.scope             is 'The current unit/module in which the log was generated (OWNER.PACKAGE.MODULE.SUBMODULE, line number).';
comment on column console_logs.message           is 'The log message itself and in case of an error or trace the call stack informaton.';
comment on column console_logs.call_stack        is 'The call_stack and in case of an error also the error stack and error backtrace.';
comment on column console_logs.session_user      is 'The name of the session user (the user who logged on). This may change during the duration of a database session as Real Application Security sessions are attached or detached. For enterprise users, returns the schema. For other users, returns the database user name. If a Real Application Security session is currently attached to the database session, returns user XS$NULL.';
comment on column console_logs.module            is 'The application name (module). Can be set by an application using the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.action            is 'The action/position in the module (application name). Can be set through the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.client_info       is 'The client information. Can be set by an application using the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.client_identifier is 'The client identifier. Can be set by an application using the DBMS_SESSION.SET_IDENTIFIER procedure, the OCI attribute OCI_ATTR_CLIENT_IDENTIFIER, or Oracle Dynamic Monitoring Service (DMS). This attribute is used by various database components to identify lightweight application users who authenticate as the same database user.';
comment on column console_logs.ip_address        is 'IP address of the machine from which the client is connected. If the client and server are on the same machine and the connection uses IPv6 addressing, then it is set to ::1.';
comment on column console_logs.host              is 'Name of the host machine from which the client is connected.';
comment on column console_logs.os_user           is 'Operating system user name of the client process that initiated the database session.';
comment on column console_logs.os_user_agent     is 'Operating system user agent (web browser engine). This information will only be available, if we overwrite the console.error method of the client browser and bring these errors back to the server. For APEX we will have a plug-in in the future to do this.';




prompt - Package CONSOLE (spec)
create or replace package console authid definer is

c_name    constant varchar2(30 byte) := 'Oracle Instrumentation Console';
c_version constant varchar2(10 byte) := '0.4.2';
c_url     constant varchar2(40 byte) := 'https://github.com/ogobrecht/console';
c_license constant varchar2(10 byte) := 'MIT';
c_author  constant varchar2(20 byte) := 'Ottmar Gobrecht';

c_permanent constant integer := 0;
c_error     constant integer := 1;
c_warning   constant integer := 2;
c_info      constant integer := 3;
c_verbose   constant integer := 4;


/**

Oracle Instrumentation Console
==============================

An instrumentation tool for Oracle developers. Save to install on production and
mostly API compatible with the [JavaScript
console](https://developers.google.com/web/tools/chrome-devtools/console/api).

DEPENDENCIES

Oracle DB >= 12.1

INSTALLATION

- Download the [latest
  version](https://github.com/ogobrecht/oracle-instrumentation-console/releases/latest)
  and unzip it or [clone the repository](https://github.com/ogobrecht/console)
- `cd` into the root of the project

The installation itself is splitted into one mandatory and three optional steps:

1. Install CONSOLE itself
    - Start SQL*Plus and connect to your desired install schema
    - Run `@install/create_console_objects.sql`
    - User needs the rights to create a package, a table and views
    - Do this step on every new release of CONSOLE
2. Optional: Create a context
    - Start SQL*Plus and connect to a privileged user
    - Run `@install/create_context.sql "CONSOLE_INSTALL_SCHEMA"`
    - Maybe your DBA needs to do that for you once
3. Optional: Grant rights to client schema
    - When installed in a central tools schema you may want to grant execute
      rights on the package and select rights on the views to public or other
      schemas
    - Start SQL*Plus and connect to your CONSOLE install schema
    - Run `@install/grant_rights_to_client_schema.sql "CLIENT_SCHEMA"`
4. Optional: Create synonyms in client schema
    - When you want to use it in another schema you may want to create synonyms
      there for easier access
    - Start SQL*Plus and connect to your client schema
    - Run`@install/create_synonyms_in_client_schema.sql`

UNINSTALLATION

Hopefully you will never need this...

FIXME: Create uninstall scripts

**/


--------------------------------------------------------------------------------
-- CONSTANTS, TYPES
--------------------------------------------------------------------------------


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
  p_message    clob     default null,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 1 (error) and call also `console.clear` to reset
the session action attribute.

**/

--------------------------------------------------------------------------------
procedure warn (
  p_message    clob,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 2 (warning).

**/

--------------------------------------------------------------------------------
procedure info (
  p_message    clob,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 3 (info).

**/

--------------------------------------------------------------------------------
procedure log(
  p_message    clob,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 3 (info).

**/

--------------------------------------------------------------------------------

procedure debug (
  p_message    clob,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 4 (verbose).

**/

--------------------------------------------------------------------------------
procedure trace (
  p_message    clob     default null,
  p_user_agent varchar2 default null
);
/**

Logs a call stack with the level 3 (info).

**/

--------------------------------------------------------------------------------

procedure assert (
  p_expression boolean,
  p_message    varchar2
);
/**

If the given expression evaluates to false an error is raised with the given message.

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

The action is automatically cleared in the method `console.error`.

EXAMPLE

```sql
begin
  console.action('My process/task');
  -- do your stuff here...
  console.action(null);
exception
  when others then
    console.error('something went wrong'); --also clears action
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

procedure init (
  p_client_identifier varchar2               , -- The client identifier provided by the application or console itself.
  p_log_level         integer default c_info , -- Level 2 (warning), 3 (info) or 4 (verbose).
  p_log_duration      integer default 60     , -- The number of minutes the session should be in logging mode. Allowed values: 1 to 1440 minutes (24 hours).
  p_cache_size        integer default 0      , -- The number of log entries to cache before they are written down into the log table, if not already written by the end of the cache duration. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shered environments like APEX. Allowed values: 0 to 100 records.
  p_cache_duration    integer default 10     , -- The number of seconds a session in logging mode looks for a changed configuration and flushes the cached log entries. Allowed values: 1 to 10 seconds.
  p_user_env          boolean default false  , -- Should the user environment be included.
  p_apex_env          boolean default false  , -- Should the APEX environment be included.
  p_cgi_env           boolean default false  , -- Should the CGI environment be included.
  p_console_env       boolean default false    -- Should the console environment be included.
);
/**

Starts the logging for a specific session.

To avoid spoiling the context with very long input the p_client_identifier parameter is
truncated after 64 characters before using it.

For easier usage there is an overloaded procedure available which uses always
your own client identifier.

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

Stops the logging for a specific session and clears the info in the global
context for it.

Please note that we always log the levels errors and permanent to keep a record
of things that are going wrong.

EXAMPLE

```sql
begin
  console.('My process/task');

  -- your stuff here...

  console.clear;
exception
  when others then
    console.error('something went wrong'); -- calls also console.clear
    raise;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------
-- PUBLIC HELPER METHODS
--------------------------------------------------------------------------------

function get_call_stack return varchar2;
/**

Returns the current call stack and if an error was raised also the error stack
and the error backtrace. Is used internally by the console methods error and
trace and also, if you set on other console methods the parameter p_trace to
true. The stacks are represented in a Markdown compatible list style.

The console package itself is excluded from the trace as you normally would
trace you business logic and not your instrumentation code.

```sql
set serveroutput on
begin
  dbms_output.put_line(console.get_call_stack);
end;
{{/}}
```

The code above will output `- Call Stack: __anonymous_block (2)`

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

function version return varchar2;
/**

returns the version information from the console package.


```sql
select console.version from dual;
```

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

function to_bool (
  p_string varchar2)
return boolean;
/**

A helper to convert a string into a boolean. When the trimmed, uppercased input
is in `Y`, `YES, `1`, `TRUE`, then it returns true. In all other cases (also
NULL) false is returned.

```sql
begin
  if console.to_bool('yEs') then
    dbms_output.put_line('TRUE');
  else
    dbms_output.put_line('FALSE');
  end if;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function to_yn (
  p_bool boolean)
return varchar2;
/**

A helper to convert a boolean into a string. When the input is true then `Y` is
returned. In all other cases (also NULL) `N` is returned.

```sql
begin
  dbms_output.put_line(console.to_yn(true));
end;
{{/}}
```

**/

--------------------------------------------------------------------------------
-- INTERNAL UTILITIES (only visible when ccflag `utils_public` is set to true)
--------------------------------------------------------------------------------

$if $$utils_public $then

function read_row_from_sessions (
  p_client_identifier varchar2 )
return console_sessions%rowtype result_cache;

procedure set_client_identifier;

procedure check_context_availability;

procedure load_session_configuration;

function logging_enabled (p_level integer) return boolean;

procedure create_log_entry (
  p_level      integer                ,
  p_message    clob     default null  ,
  p_trace      boolean  default false ,
  p_user_agent varchar2 default null  );

procedure clear_context (p_client_identifier varchar2 );

procedure clear_all_context;

$end

end console;
/

prompt - Package CONSOLE (body)
create or replace package body console is

--------------------------------------------------------------------------------
-- CONSTANTS, TYPES, GLOBALS
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
c_anon_block_ora     constant varchar2 (20 byte) := '__anonymous_block';
c_anonymous_block    constant varchar2 (20 byte) := 'anonymous_block';
c_client_id_prefix   constant varchar2 ( 5 byte) := '{o,o}';
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

g_conf_context_available boolean;
g_conf_valid_until_date  date;
g_conf_client_identifier varchar2 (64 byte);
g_conf_log_level         pls_integer;
g_conf_start_date        date;
g_conf_end_date          date;
g_conf_cache_size        integer;
g_conf_cache_duration    integer;
g_conf_user_env          boolean;
g_conf_apex_env          boolean;
g_conf_cgi_env           boolean;
g_conf_console_env       boolean;

--------------------------------------------------------------------------------
-- PRIVATE METHODS (forward declarations)
--------------------------------------------------------------------------------

$if not $$utils_public $then

function read_row_from_sessions (
  p_client_identifier varchar2 )
return console_sessions%rowtype result_cache;

procedure set_client_identifier;

procedure check_context_availability;

procedure load_session_configuration;

function logging_enabled (p_level integer) return boolean;

procedure create_log_entry (
  p_level      integer                ,
  p_message    clob     default null  ,
  p_trace      boolean  default false ,
  p_user_agent varchar2 default null  );

procedure clear_context (p_client_identifier varchar2 );

procedure clear_all_context;

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
  p_message    clob     default null ,
  p_user_agent varchar2 default null )
is
begin
  create_log_entry (
    p_level      => c_error      ,
    p_message    => p_message    ,
    p_trace      => true         ,
    p_user_agent => p_user_agent );
end error;

--------------------------------------------------------------------------------

procedure warn (
  p_message    clob                  ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_warning) then
    create_log_entry (
      p_level      => c_warning    ,
      p_message    => p_message    ,
      p_user_agent => p_user_agent );
  end if;
end warn;

--------------------------------------------------------------------------------

procedure info (
  p_message    clob                  ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_info) then
    create_log_entry (
      p_level      => c_info       ,
      p_message    => p_message    ,
      p_user_agent => p_user_agent );
  end if;
end info;

--------------------------------------------------------------------------------

procedure log (
  p_message    clob                  ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_info) then
    create_log_entry (
      p_level      => c_info       ,
      p_message    => p_message    ,
      p_user_agent => p_user_agent );
  end if;
end log;

--------------------------------------------------------------------------------

procedure debug (
  p_message    clob                  ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_verbose) then
    create_log_entry (
      p_level      => c_verbose    ,
      p_message    => p_message    ,
      p_user_agent => p_user_agent );
  end if;
end debug;

--------------------------------------------------------------------------------

procedure trace (
  p_message    clob     default null ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_info) then
    create_log_entry (
      p_level      => c_info       ,
      p_message    => p_message    ,
      p_trace      => true         ,
      p_user_agent => p_user_agent );
  end if;
end trace;

--------------------------------------------------------------------------------

procedure assert (
  p_expression boolean  ,
  p_message    varchar2 )
is
begin
  if not p_expression then
    raise_application_error(-20000, 'Assertion failed: ' || p_message, true);
  end if;
end assert;

--------------------------------------------------------------------------------

procedure action (
  p_action varchar2 )
is
begin
  dbms_application_info.set_action(p_action);
end action;

--------------------------------------------------------------------------------

function my_client_identifier return varchar2 is
begin
  return g_conf_client_identifier;
end;

--------------------------------------------------------------------------------

procedure init (
  p_client_identifier varchar2               ,
  p_log_level         integer default c_info ,
  p_log_duration      integer default 60     ,
  p_cache_size        integer default 0      ,
  p_cache_duration    integer default 10     ,
  p_user_env          boolean default false  ,
  p_apex_env          boolean default false  ,
  p_cgi_env           boolean default false  ,
  p_console_env       boolean default false  )
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
      error('Context not available, package var g_conf_context_available tells us it is ?!?');
  end;
  --
begin
  assert ( p_log_level      in (2, 3, 4),       'Level needs to be 2 (warning), 3 (info) or 4 (verbose). Level 1 (error) and 0 (permanent) are always logged without a call to the init method.');
  assert ( p_log_duration   between 1 and 1440, 'Duration needs to be between 1 and 1440 (minutes).');
  assert ( p_cache_size     between 0 and  100, 'Cache size needs to be between 1 and 100 (log entries).');
  assert ( p_cache_duration between 1 and   10, 'Cache duration needs to be between 1 and 10 (seconds).');
  assert ( p_user_env       is not null,        'User env needs to be true or false (not null).');
  assert ( p_apex_env       is not null,        'APEX env needs to be true or false (not null).');
  assert ( p_cgi_env        is not null,        'CGI env needs to be true or false (not null).');
  assert ( p_console_env    is not null,        'Console env needs to be true or false (not null).');
  --
  v_row.client_identifier := substrb(p_client_identifier, 1, 64);
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
    update
      console_sessions
    set
      log_level      = v_row.log_level,
      end_date       = v_row.end_date,
      cache_duration = v_row.cache_duration,
      cache_size     = v_row.cache_size,
      user_env       = v_row.user_env,
      apex_env       = v_row.apex_env,
      cgi_env        = v_row.cgi_env,
      console_env    = v_row.console_env
    where
      client_identifier = v_row.client_identifier;
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
-- PUBLIC HELPER METHODS
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
      v_subprogram := replace(
        utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(i)),
        c_anon_block_ora,
        c_anonymous_block
      );
      --exclude console package from the call stack
      if instr(upper(v_subprogram), upper($$plsql_unit)||'.') = 0 then
        v_return := v_return
          || case when utl_call_stack.owner(i) is not null then utl_call_stack.owner(i) || '.' end
          || v_subprogram || ', line ' || utl_call_stack.unit_line (i)
          || chr (10);
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
    v_return := v_return || '- ERROR STACK' || chr (10);
    for i in 1 .. utl_call_stack.error_depth
    loop
      v_return := v_return
        || '  - ORA-'
        || trim(to_char(utl_call_stack.error_number(i), '00009')) || ' '
        || utl_call_stack.error_msg(i)
        || chr (10);
    end loop;
  end if;

  if utl_call_stack.backtrace_depth > 0 then
    v_return := v_return || '- ERROR BACKTRACE' || chr (10);
    for i in 1 .. utl_call_stack.backtrace_depth
    loop
      v_return := v_return
        || '  - '
        || coalesce(utl_call_stack.backtrace_unit(i), c_anonymous_block)
        || ', line ' || utl_call_stack.backtrace_line(i)
        || chr (10);
    end loop;
  end if;

  if utl_call_stack.dynamic_depth > 0 then
    v_return := v_return || '- CALL STACK' || chr (10);
    --ignore 1, is always this function (get_call_stack) itself
    for i in 2 .. utl_call_stack.dynamic_depth
    loop
      --the replace changes `__anonymous_block` to `anonymous_block`
      v_subprogram := replace(
        utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(i)),
        c_anon_block_ora,
        c_anonymous_block
      );
      --exclude console package from the call stack
      if instr(upper(v_subprogram), upper($$plsql_unit)||'.') = 0 then
        v_return := v_return
          || '  - '
          || case when utl_call_stack.owner(i) is not null then utl_call_stack.owner(i) || '.' end
          || v_subprogram || ', line ' || utl_call_stack.unit_line (i)
          || chr (10);
      end if;
    end loop;
  end if;

  return v_return;
end get_call_stack;

--------------------------------------------------------------------------------

function my_log_level return integer is
begin
  return g_conf_log_level;
end my_log_level;

--------------------------------------------------------------------------------

function context_available_yn return varchar2 is
begin
  return case when g_conf_context_available then 'Y' else 'N' end;
end;

--------------------------------------------------------------------------------

function to_bool (
  p_string varchar2)
return boolean is
begin
  return
    case when upper(p_string) in ('Y', 'YES', '1', 'TRUE')
      then true
      else false
    end;
end;

--------------------------------------------------------------------------------

function to_yn (
  p_bool boolean)
return varchar2 is
begin
  return case when p_bool then 'Y' else 'N' end;
end;

--------------------------------------------------------------------------------

function version return varchar2 is
begin
  return c_version;
end;

--------------------------------------------------------------------------------
-- PRIVATE METHODS
--------------------------------------------------------------------------------

function logging_enabled (
  p_level integer )
return boolean is
begin
  if g_conf_valid_until_date < sysdate then
    load_session_configuration;
  end if;
  return g_conf_log_level >= p_level or sqlcode != 0;
end logging_enabled;

--------------------------------------------------------------------------------

procedure create_log_entry (
  p_level      integer,
  p_message    clob     default null  ,
  p_trace      boolean  default false ,
  p_user_agent varchar2 default null  )
is
  pragma autonomous_transaction;
  v_message    clob;
  v_call_stack vc4000;
  v_scope   console_logs.scope%type;
begin
  v_scope := substrb(get_scope, 1, 1000);
  if p_message is not null then
    v_message := p_message;
  elsif sqlcode != 0 then
    v_message := sqlerrm;
  end if;
  if p_trace then
    v_call_stack := substrb(get_call_stack, 1, 4000);
  end if;
  insert into console_logs (
    log_level,
    scope,
    message,
    call_stack,
    session_user,
    module,
    action,
    client_info,
    client_identifier,
    ip_address,
    host,
    os_user,
    os_user_agent
  )
  values (
    p_level,
    v_scope,
    v_message,
    v_call_stack,
    substrb( sys_context('USERENV', 'SESSION_USER')     , 1, 32),
    substrb( sys_context('USERENV', 'MODULE')           , 1, 48),
    substrb( sys_context('USERENV', 'ACTION')           , 1, 32),
    substrb( sys_context('USERENV', 'CLIENT_INFO')      , 1, 64),
    substrb( sys_context('USERENV', 'CLIENT_IDENTIFIER'), 1, 64),
    substrb( sys_context('USERENV', 'IP_ADDRESS')       , 1, 48),
    substrb( sys_context('USERENV', 'HOST')             , 1, 64),
    substrb( sys_context('USERENV', 'OS_USER')          , 1, 64),
    substrb(p_user_agent, 1, 200)
  );
  commit;
end create_log_entry;

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
    sys.dbms_session.clear_all_context (c_ctx_namespace);
  end if;
end clear_all_context;

--------------------------------------------------------------------------------

/* HOW TO CHECK RESULT CACHE
select id, name, cache_id, type, status, invalidations, scan_count
  from v$result_cache_objects
 where name like '%CONSOLE%'
   and status != 'Invalid';
*/
function read_row_from_sessions (p_client_identifier varchar2)
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
  if g_conf_client_identifier is null then
    g_conf_client_identifier := c_client_id_prefix || dbms_session.unique_session_id;
    dbms_session.set_identifier (g_conf_client_identifier);
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
  end if;
  g_conf_valid_until_date := least(g_conf_end_date, sysdate + 1/24/60/60*10);
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




