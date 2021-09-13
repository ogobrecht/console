<!-- nav -->

[Index](README.md)
| [Installation](installation.md)
| [Getting Started](getting-started.md)
| [API Overview](api-overview.md)
| [Package Console](package-console.md)
| [Changelog](changelog.md)
| [Uninstallation](uninstallation.md)

<!-- navstop -->

# Getting Started

After you have [installed the console objects](installation.md) you can start to
use it to instrument your code.

<!-- toc -->

- [Minimal - Log Only Errors](#minimal---log-only-errors)
- [Debugging During Development or Analyzing Problems](#debugging-during-development-or-analyzing-problems)
- [Configure Default Log Level (set global configuration)](#configure-default-log-level-set-global-configuration)
- [Configure Different Log Levels for Specific PL/SQL Units](#configure-different-log-levels-for-specific-plsql-units)
- [View Console Status](#view-console-status)
- [APEX Backend - Error Handling Function](#apex-backend---error-handling-function)
- [APEX Frontend - Track User JavaScript Errors](#apex-frontend---track-user-javascript-errors)

<!-- tocstop -->

## Minimal - Log Only Errors

> Use `console.error` only at the outermost method of your logic and
> `console.error_save_stack` in the nested ones.

There is a general problem with logging errors: You can easily spoil your log
table with many entries from every nested method call to try to get the most
detailed information. On the other hand if you handle the errors only in the
outermost methods of your business logic then you loose context information
because the error backtrace from Oracle tells you only the package names and
line numbers where the error was bubbling up in your code - the method names are
missing in the backtrace.

We try to bridge this gap with a special helper method called
[console.error_save_stack](package-console.md#procedure-error_save_stack). This
procedure does not log the error. Instead it saves the call stack information
(which includes the names of nested methods) until you finally call
[console.error](package-console.md#procedure-error).

Here an example script to illustrate this. You can play around with it - have a
look at the calls of `console.error_save_stack` and the one, outermost
`console.error`:

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
/

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
/

prompt - call the package
begin
  some_api.do_stuff;
exception
  when others then
    null; --> I know, I know, never do that without a final raise...
          --> But we want only test our logging without killing the script run...
end;
/

prompt - FINISHED, selecting now the call stack from the last log entry...

select call_stack from console_logs order by log_id desc fetch first row only;
```

If you run this script you will get for the call stack information the following
output - compare the different sections (saved error stack is the info collected
by the console package, the other three are the default information from Oracle
in case of errors):

```bash
TEST ERROR_SAVE_STACK
- compile package spec
- compile package body
- call the package
- FINISHED, selecting now the call stack from the last log entry...

Call Stack
------------------------------------------------------------------------------------------------------------------------
## Saved Error Stack

- PLAYGROUND_DATA.SOME_API.DO_STUFF.SUB1.SUB2.SUB3, line 14 (line 11, ORA-20777 Assertion failed: Demo)
- PLAYGROUND_DATA.SOME_API.DO_STUFF.SUB1.SUB2, line 22 (line 19)
- PLAYGROUND_DATA.SOME_API.DO_STUFF.SUB1, line 30 (line 27)
- PLAYGROUND_DATA.SOME_API.DO_STUFF, line 38 (line 35, ORA-01403 no data found)

## Call Stack

- PLAYGROUND_DATA.SOME_API.DO_STUFF, line 38
- anonymous_block, line 2

## Error Stack

- ORA-01403 no data found
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 31
- ORA-20777 Assertion failed: Demo
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 23
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 15
- ORA-06512 at "PLAYGROUND_DATA.CONSOLE", line 750
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 11
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 19
- ORA-06512 at "PLAYGROUND_DATA.SOME_API", line 27

## Error Backtrace

- PLAYGROUND_DATA.SOME_API, line 31
- PLAYGROUND_DATA.SOME_API, line 23
- PLAYGROUND_DATA.SOME_API, line 15
- PLAYGROUND_DATA.CONSOLE, line 750
- PLAYGROUND_DATA.SOME_API, line 11
- PLAYGROUND_DATA.SOME_API, line 19
- PLAYGROUND_DATA.SOME_API, line 27
- PLAYGROUND_DATA.SOME_API, line 35
```

## Debugging During Development or Analyzing Problems

> Log certain information with different log methods. Enable logging with
> `console.init`.

### Init Log Level (set client preferences)

CONSOLE runs per default only in log level `error` (level 1, you can change this
with [console.conf](package-console.md#procedure-conf)). In this level `error`
all calls to log methods in levels warning (2), info (3), debug (4) and trace
(5) are simply ignored. This is fine for production as you can leave your
instrumentation calls unchanged but if you want CONSOLE to really log those
levels then you have to call [console.init](package-console.md#procedure-init)
to change the log level (and other preferences) for your own or other
sessions/client identifiers.

Please note that you should not use `console.init` in your business logic. It is
a helper method and should only used in scripts to manage the preferences for
specific client identifiers.

Some examples:

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

-- ...with named parameters (there are more availabe, checkout the docs)
begin
  console.init(
    p_client_identifier => 'OGOBRECHT:8805903776765',
    p_level             => console.c_level_debug,
    p_duration          => 15
  );
end;
/
```

A session is identified by the client identifier. This information can be found
in many adminstrative view from Oracle (for example in the v$session view). Some
applications like APEX providing a unique identifier for a user. This is good,
otherwise in a shared environment it would be impossible to change the log level
for a specific end user without impacting other end users as the
sessions/resources are shared.

For your own dedicated session in a development IDE you don't need to care about
how your session is identified.

What can you do if you want to debug a session from another user, if a session
has no client identifier set?

CONSOLE takes care of this on package initialization - it simply sets a unique
identifier, if the session has none.

The only thing you need to do is to figure out which client identifier the user
has. If you have no access to adminstrative views like v$session, then you need
to get the client identifier from the user environment and write it somewhere in
the user interface - in APEX for example this would be very easy. You could for
example write this in the footer of every page by calling
`sys_context('USERENV', 'CLIENT_IDENTIFIER')` or
[console.my_client_identifier](package-console.md#function-my_client_identifier).
If you use the APEX plug-in to log frontend errors then you could do this in
pure JavaScript in the frontend, as the plug-in provides the information under
`window.oic.clientIdentifier`.

### Log Methods

As CONSOLE was designed for easy usage it shares many methods names with the
JavaScript console:

- [console.error_save_stack](package-console.md#procedure-error_save_stack)
- [console.error](package-console.md#procedure-error) (level error)
- [console.warn](package-console.md#procedure-warn) (level warning)
- [console.info](package-console.md#procedure-info) &
  [log](package-console.md#procedure-log) (level info)
- [console.debug](package-console.md#procedure-debug) (level debug)
- [console.trace](package-console.md#procedure-trace) (level trace)
- [console.count](package-console.md#procedure-count)
- [console.count_log](package-console.md#procedure-count_log) &
  [count_end](package-console.md#procedure-count_end) (level info)
- [console.time](package-console.md#procedure-time)
- [console.time_log](package-console.md#procedure-time_log) &
  [console.time_end](package-console.md#procedure-time_end) (level info)
- [console.table#](package-console.md#procedure-table) (level info)
- [console.assert](package-console.md#procedure-assert) &
  [console.assertf](package-console.md#procedure-assertf)
- [console.format](package-console.md#function-format)

Also see additional methods in the [API overview](api-overview.md)

### Viewing Log Entries

CONSOLE brings a [pipelined function to view the last
entries](package-console.md#function-view_last). This function is especially
useful, if you use the possibility to cache log entries in the packages state
(works only for your own development session) as this function views the entries
from the cache and the log table `CONSOLE_LOGS` in descending order:

```sql
--init preferences for own session/client_identifier
exec console.init(
  p_level          => c_level_debug ,
  p_duration       => 90            , -- in minutes
  p_cache_size     => 1000          , -- number of entries to cache in the package state
  p_check_interval => 30            );-- in seconds, how often console looks for a changed configuration

--test some business logic
begin
  --your code here;

  console.log('test', p_user_env => true);
end;
/

--view last cache and log entries
select * from console.view_last(50);
```

### Exit Log Level (unset client preferences)

If you finished your debugging work you might want to exit/unset the current
preferences and go back to the global preferences/configuration. You can do this
by calling [console.exit](package-console.md#procedure-exit). If you provide no
client identifier, then CONSOLE tries to exit your own session.

If you don't do it by yourself the daily cleanup job from CONSOLE will exit
stale sessions.

## Configure Default Log Level (set global configuration)

Some people use the levels `error`, `warning` and `info` in production for the
operations team and levels `debug` and `trace` for debugging purposes. To
support such use cases you can configure the default log level (and other
options) of CONSOLE for all sessions from `error` to `warning` or `info` by
using the [console.conf](package-console.md#procedure-conf) procedure.

EXAMPLE

```sql
--set global log level to warning
exec console.conf(p_level => console.c_level_warning);
```

There are more parameters to the [conf
procedure](package-console.md#procedure-conf).

## Configure Different Log Levels for Specific PL/SQL Units

If you have a new package and you want only set the log level for this package
to another level then the global one, you can do this by using the
[console.conf](package-console.md#procedure-conf) procedure.

EXAMPLE

```sql
--set global log level to info and for two new packages to debug
begin
  console.conf(
    p_level             => console.c_level_info                       ,
    p_units_level_debug => 'MY_SCHEMA.SOME_API,MY_SCHEMA.ANOTHER_API' );
end;
{{/}}
```

## View Console Status

Console ships with a pipelined function which shows its status in the current
session. You can use it for your own session or place it somewhere in an
frontend (like an APEX report) to see its status in an user session.

An example:

```sql
select * from table(console.view_status);
```

| KEY                          | VALUE               |
|------------------------------|---------------------|
| c_version                    | 1.0-beta5           |
| g_conf_context_is_available  | N                   |
| c_ctx_namespace              | CONSOLE_PLAYGROUND  |
| g_conf_check_sysdate         | 2021-05-02 13:06:55 |
| g_conf_exit_sysdate          | 2021-05-03 13:06:45 |
| g_conf_client_identifier     | {o,o} 1EA16A180002  |
| g_conf_level                 | 1                   |
| level_name(g_conf_level) | error               |
| g_conf_cache_size            | 0                   |
| g_conf_check_interval        | 10                  |
| g_conf_call_stack            | N                   |
| g_conf_user_env              | N                   |
| g_conf_apex_env              | N                   |
| g_conf_cgi_env               | N                   |
| g_conf_console_env           | N                   |
| g_conf_enable_ascii_art      | Y                   |
| g_conf_units_level(2)        |                     |
| g_conf_units_level(3)        |                     |
| g_conf_units_level(4)        |                     |
| g_conf_units_level(5)        |                     |
| g_counters.count             | 0                   |
| g_timers.count               | 0                   |
| g_log_cache.count            | 0                   |
| g_saved_stack.count          | 0                   |
| g_prev_error_msg             |                     |

## APEX Backend - Error Handling Function

If you have APEX installed, CONSOLE ships with an error handling function. You
can register this function in your app under Application Builder > Edit
Application Properties > Error Handling > Error Handling Function:
`console.apex_error_handling`.

For more info see the [official
docs](https://docs.oracle.com/en/database/oracle/application-express/20.2/aeapi/Example-of-an-Error-Handling-Function.html#GUID-2CD75881-1A59-4787-B04B-9AAEC14E1A82).

The error handling function logs the technical error to the table CONSOLE_LOGS
and writes a friendly message to the end user. It uses the APEX text message
feature for the user friendly messages in case of constraint violations as
described in [this video](https://www.insum.ca/episode-22-error-handling/) by
Anton and Neelesh of Insum, which is based on an idea by Roel Hartman in [this
blog
post](https://roelhartman.blogspot.com/2021/02/stop-using-validations-for-checking.html).

The community rocks...

## APEX Frontend - Track User JavaScript Errors

For APEX you can use the provided plug-in to log frontend JavaScript errors in
the end users browser.

You need to make sure console is either installed in the app parsing schema or
you have a synonym called `console` created in the parsing schema which points
to the package console.

Then you can install the plug-in under `install/apex_plugin.sql` and create a
Dynamic Action on page zero (for all pages):

- Event: Page Load
- Action: Oracle Instrumentation Console [Plug-In]
- No further customization needed (it loads only one JavaScript file)

If you are interested what the plug-in is doing then have a look under
`sources/apex_plugin_console.js`. This is currently a minimal implementation and
can be improved in the future.
