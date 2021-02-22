create or replace package console authid definer is

c_name    constant varchar2 ( 30 byte ) := 'Oracle Instrumentation Console'       ;
c_version constant varchar2 ( 10 byte ) := '0.22.1'                               ;
c_url     constant varchar2 ( 40 byte ) := 'https://github.com/ogobrecht/console' ;
c_license constant varchar2 ( 10 byte ) := 'MIT'                                  ;
c_author  constant varchar2 ( 20 byte ) := 'Ottmar Gobrecht'                      ;

c_level_permanent constant pls_integer := 0 ;
c_level_error     constant pls_integer := 1 ;
c_level_warning   constant pls_integer := 2 ;
c_level_info      constant pls_integer := 3 ;
c_level_verbose   constant pls_integer := 4 ;

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

--------------------------------------------------------------------------------

**/

procedure permanent ( p_message clob );
/**

Log a message with the level 0 (permanent). These messages will not be deleted
on cleanup.

**/

--------------------------------------------------------------------------------

procedure error (
  p_message         clob     default null  ,
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
  p_call_stack      boolean  default true  ,
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
                  --raise_application_error(-20999, 'Test error with' || chr(10) || 'line break.');
                  raise value_error;
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

**/


--------------------------------------------------------------------------------

procedure warn (
  p_message         clob     default null  ,
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

--------------------------------------------------------------------------------

procedure info (
  p_message         clob     default null  ,
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

--------------------------------------------------------------------------------

procedure log(
  p_message         clob     default null  ,
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

--------------------------------------------------------------------------------

procedure debug (
  p_message         clob     default null  ,
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

Log a message with the level 4 (verbose).

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

procedure trace (
  p_message         clob     default null  ,
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

Logs a call stack with the level 3 (info).

**/

--------------------------------------------------------------------------------

procedure count ( p_label varchar2 default null );
/**

Starts a new counter with a value of one or adds one to an existent counter.

Call `console.count_end('yourLabel')` to stop the counter and get or log the count
value.

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

function level_permanent return integer; /** Returns the number code for the level 0 permanent. **/
function level_error     return integer; /** Returns the number code for the level 1 error.     **/
function level_warning   return integer; /** Returns the number code for the level 2 warning.   **/
function level_info      return integer; /** Returns the number code for the level 3 info.      **/
function level_verbose   return integer; /** Returns the number code for the level 4 verbose.   **/

function level_is_warning return boolean; /** Returns true when the level is greater than or equal warning, otherwise false. **/
function level_is_info    return boolean; /** Returns true when the level is greater than or equal info, otherwise false.    **/
function level_is_verbose return boolean; /** Returns true when the level is greater than or equal verbose, otherwise false. **/
function level_is_warning_yn return varchar2; /** Returns 'Y' when the level is greater than or equal warning, otherwise 'N'. **/
function level_is_info_yn    return varchar2; /** Returns 'Y' when the level is greater than or equal info, otherwise 'N'.    **/
function level_is_verbose_yn return varchar2; /** Returns 'Y' when the level is greater than or equal verbose, otherwise 'N'. **/


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

$end

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

procedure init (
  p_client_identifier varchar2                      , -- The client identifier provided by the application or console itself.
  p_level             integer  default c_level_info , -- Level 2 (warning), 3 (info) or 4 (verbose).
  p_duration          integer  default 60           , -- The number of minutes the session should be in logging mode. Allowed values: 1 to 1440 minutes (24 hours).
  p_cache_size        integer  default 0            , -- The number of log entries to cache before they are written down into the log table. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shared environments like APEX. Allowed values: 0 to 1000 records.
  p_check_interval    integer  default 10           , -- The number of seconds a session in logging mode looks for a changed configuration. Allowed values: 1 to 60 seconds.
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

-- With level 4 (verbose) for the next 15 minutes.
exec console.init(4, 15);

-- Using a constant for the level
exec console.init(console.c_level_verbose, 90);

-- Debug an APEX session...
exec console.init('APEX:8805903776765', 4, 90);

-- ... with the defaults
exec console.init('APEX:8805903776765');

-- Debug another session
begin
  console.init(
    p_client_identifier => 'APEX:8805903776765',
    p_level             => console.c_level_verbose,
    p_duration          => 15
  );
end;
{{/}}
```

**/

procedure init (
  p_level          integer default c_level_info , -- Level 2 (warning), 3 (info) or 4 (verbose).
  p_duration       integer default 60           , -- The number of minutes the session should be in logging mode. Allowed values: 1 to 1440 minutes (24 hours).
  p_cache_size     integer default 0            , -- The number of log entries to cache before they are written down into the log table. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shared environments like APEX. Allowed values: 0 to 1000 records.
  p_check_interval integer default 10           , -- The number of seconds a session in logging mode looks for a changed configuration. Allowed values: 1 to 60 seconds.
  p_call_stack     boolean default false        , -- Should the call stack be included.
  p_user_env       boolean default false        , -- Should the user environment be included.
  p_apex_env       boolean default false        , -- Should the APEX environment be included.
  p_cgi_env        boolean default false        , -- Should the CGI environment be included.
  p_console_env    boolean default false          -- Should the console environment be included.
);

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

--------------------------------------------------------------------------------

function get_level_name(p_level integer) return varchar2 deterministic;
/*

Returns the level name for a given level id and null, if the level is not
between 0 and 4.

*/

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

function  get_scope return varchar2;
/**

Get the current scope (method, line number) from the call stack.

Is used internally by console to automatically provide the scope attribute for a
log entry.

**/

--------------------------------------------------------------------------------

function  get_call_stack return varchar2;
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

procedure flush_cache;
/**

Flushes the log cache and writes down the entries to the log table.

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
  p_level          => c_level_verbose ,
  p_duration       => 90              ,
  p_cache_size     => 1000            ,
  p_check_interval => 30              );

--test some business logic
begin
  --your code here;

  console_log('test', p_user_env => true);
end;
{{/}}

--check current log cache
select * from console.view_cache();
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
  p_level          => c_level_verbose ,
  p_duration       => 90              ,
  p_cache_size     => 10              ,
  p_check_interval => 30              );

--test some business logic
begin
  --your code here;

  console_log('test', p_user_env => true);
end;
{{/}}

--check current log cache
select * from console.view_last(50);
```

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
-- PRIVATE HELPER METHODS (only visible when ccflag `utils_public` is set to true)
--------------------------------------------------------------------------------

$if $$utils_public $then

function  utl_escape_md_tab_text (p_text varchar2) return varchar2;
function  utl_get_error return varchar2;
function  utl_logging_is_enabled (p_level integer) return boolean;
function  utl_normalize_label (p_label varchar2) return varchar2;
function  utl_read_row_from_sessions (p_client_identifier varchar2) return console_sessions%rowtype result_cache;
function  utl_replace_linebreaks (p_text varchar2, p_replace_with varchar2 default ' ') return varchar2;
procedure utl_check_context_availability;
procedure utl_clear_all_context;
procedure utl_clear_context (p_client_identifier varchar2);
procedure utl_load_session_configuration;
procedure utl_set_client_identifier;
--
function utl_create_log_entry (
  p_level           integer                ,
  p_message         clob     default null  ,
  p_call_stack      boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return integer;
procedure utl_create_log_entry (
  p_level           integer                ,
  p_message         clob     default null  ,
  p_call_stack      boolean  default false ,
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
