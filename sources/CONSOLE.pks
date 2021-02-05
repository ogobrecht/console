create or replace package console authid definer is

c_name    constant varchar2 ( 30 byte ) := 'Oracle Instrumentation Console'       ;
c_version constant varchar2 ( 10 byte ) := '0.7.2'                                ;
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
  p_message         clob                   ,
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
  p_message         clob                   ,
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
  p_message         clob                   ,
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
  p_message         clob                   ,
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

function extract_constraint_name (
  p_sqlerrm varchar2 )
return varchar2;
/**

Exracts the constraint name out of a SQL error message.

Used to find user friendly error messages for violated constraints in the table
CONSOLE_CONSTRAINT_MESSAGES.

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

function  get_call_stack return varchar2;
function  get_scope return varchar2;
function  logging_enabled ( p_level integer ) return boolean;
function  read_row_from_sessions ( p_client_identifier varchar2 ) return console_sessions%rowtype result_cache;
function  to_bool ( p_string varchar2 ) return boolean;
function  to_yn ( p_bool boolean ) return varchar2;
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
