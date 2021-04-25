# Getting Started

After you have [installed the console objects](installation.md) you can start to
use it to instrument your code.

## Minimal - Log Only Errors

> Use `console.error` only at the outermost method of your logic and
> `console.error_save_stack` in the nested ones.

There is a general problem with logging errors: You can easily spoil your log
table with many entries from every nested method call to try to get the most
detailed information. On the other hand if you handle the errors only in the
outermost methods of your business logic then you loose context information
because the error backtrace from Oracle tells you only the package names and
line numbers where the error was bubbling up in your code.

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

### Init Log Level

CONSOLE runs per default only in log level `error` (1). In this level all calls
to log methods in levels warning, info, debug and trace are simply ignored. This
is fine for production as you can leave your instrumentation calls unchanged but
if you want CONSOLE to really log those levels then you have to call
[console.init](package-console.md#procedure-init) to change the log level for
your own or other sessions.

Please note that you should not use `console.init` in your business logic. It is
a helper method and should only used in scripts to change the log level for
sessions.

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
only for a specific user.

For your own session in a development IDE you don't need to care about how your
session is identified.

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
- [console.assert](package-console.md#procedure-assert)
- [console.format](package-console.md#function-format)

Also see additional methods in the [API overview](api-overview.md)

### Viewing Log Entries

CONSOLE brings a [pipelined function to view the last
entries](package-console.md#function-view_last). This function is especially
useful, if you use the possibility to cache log entries in the packages state
(works only for your own development session) as this function views the entries
from the cache and the log table `CONSOLE_LOGS` in descending order:

```sql
--init logging for own session
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

### Exit Log Level

If you finished your debugging work you might want to exit the current log level
and go back to the default level. You can do this by calling
[console.exit](package-console.md#procedure-exit). If you provide no client
identifier, then CONSOLE tries to exit your own session.

If you don't do it by yourself the daily cleanup job from CONSOLE will exit
stale sessions from the table `CONSOLE_SESSIONS`.

## Configure Default Log Level

Some people use the levels `error`, `warning` and `info` in production for the
operations team and levels `debug` and `trace` for debugging purposes. To
support such use cases you can configure the default log level of CONSOLE for
all sessions from `error` to `warning` or `info` by using the
[console.conf](package-console.md#procedure-conf) procedure.

EXAMPLE

```sql
--set all sessions to level warning
exec console.conf(p_level => console.c_level_warning);
```

## Configure Different Log Levels for Specific PL/SQL Units

If you have new package and you want only set the log level for this package to
another level then the global default one then you can do this by using the
[console.conf](package-console.md#procedure-conf) procedure.

EXAMPLE

```sql
--set all session to level info and two new packages to debug
begin
  console.conf(
    p_level             => console.c_level_info                       ,
    p_check_interval    => 10                                         ,
    p_units_level_debug => 'MY_SCHEMA.SOME_API,MY_SCHEMA.ANOTHER_API' );
end;
{{/}}
```
