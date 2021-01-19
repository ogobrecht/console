create or replace package console authid definer is

c_name    constant varchar2(30 char) := 'Oracle Instrumentation Console';
c_version constant varchar2(10 char) := '0.3.1';
c_url     constant varchar2(40 char) := 'https://github.com/ogobrecht/console';
c_license constant varchar2(10 char) := 'MIT';
c_author  constant varchar2(20 char) := 'Ottmar Gobrecht';

c_level_permanent constant integer := 0;
c_level_error     constant integer := 1;
c_level_warning   constant integer := 2;
c_level_info      constant integer := 3;
c_level_verbose   constant integer := 4;


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
  and unzip it or clone the repository
- Go into the project subdirectory named install and use SQL*Plus (or another
  tool which can run SQL scripts)

The installation itself is splitted into two mandatory and two optional steps:

1. Create a context with a privileged user
    - `create_context.sql`
    - Maybe your DBA needs to do that for you once
2. Install the tool itself in your desired target schema
    - `create_console_objects.sql`
    - User needs the rights to create a package, a table and views
    - Do this step on every new release of the tool
3. Optional: When installed in a central tools schema you may want to grant
   execute rights on the package and select rights on the views to public or
   other schemas
    - `grant_rights_to_client_schema.sql`
4. Optional: When you want to use it in another schema you may want to create
   synonyms there for easier access
    - `create_synonyms_in_client_schema.sql`

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
procedure permanent (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 0 (permanent). These messages will not be deleted
on cleanup.

**/

procedure error (
  p_message    clob     default null,
  p_trace      boolean  default true,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 1 (error) and call also `console.clear` to reset
the session action attribute.

**/

procedure warn (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 2 (warning).

**/

procedure info(
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 3 (info).

**/

procedure log(
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 3 (info).

**/

procedure debug (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 4 (verbose).

**/

procedure trace(
  p_message    clob     default null,
  p_user_agent varchar2 default null
);
/**

Logs a call stack with the level 3 (info).

**/

procedure assert(
  p_expression in boolean,
  p_message    in varchar2
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

procedure action(
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

procedure init(
  p_session  varchar2 default dbms_session.unique_session_id, -- client_identifier or unique_session_id
  p_level    integer  default c_level_info,                   -- 2 (warning), 3 (info) or 4 (verbose)
  p_duration integer  default 60                               -- duration in minutes
);
/**

Starts the logging for a specific session.

To avoid spoiling the context with very long input the p_session parameter is
truncated after 64 characters before using it.

EXAMPLES

```sql
-- dive into your own session
exec console.init(dbms_session.unique_session_id);

-- debug an APEX session
exec console.init('APEX:8805903776765', console.c_level_verbose, 90);

-- debug another session identified by sid and serial
begin
  console.init(
    p_session  => console.get_unique_session_id(
                    p_sid     => 33312,
                    p_serial  => 4920
                  ),
    p_level    => console.c_level_verbose,
    p_duration => 15
  );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure clear(
  p_session  varchar2 default dbms_session.unique_session_id -- client_identifier or unique_session_id
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

function get_unique_session_id
  return varchar2;
/**

Get the unique session id for debugging of the own session.

Returns the ID provided by DBMS_SESSION.UNIQUE_SESSION_ID.

**/

--------------------------------------------------------------------------------

function get_unique_session_id (
  p_sid     integer,
  p_serial  integer,
  p_inst_id integer default 1
) return varchar2;
/**

Get the unique session id for debugging of another session.

Calculates the ID out of three parameters:

```sql
v_session_id := ltrim(to_char(p_sid,     '000x'))
             || ltrim(to_char(p_serial,  '000x'))
             || ltrim(to_char(p_inst_id, '0000'));
```

This method to calculate the unique session ID is not documented by Oracle. It
seems to work, but we have no guarantee, that it is working forever or under all
circumstances.

The first two parts seems to work, the part three for the inst_id is only a
guess and should work fine from zero to nine. But above I have no experience.
Does anybody have a RAC running with more then nine instances? Please let me
know - maybe I need to calculate here also with a hex format mask...

Hint: When checking in a session, if the logging is enabled or when we create a
log entry, we always use DBMS_SESSION.UNIQUE_SESSION_ID. All the helper methods
here to calculate the unique session id are only existing for the purpose to
start the logging of another session and to set the global context in a way the
targeted session can compare against with with DBMS_SESSION.UNIQUE_SESSION_ID or
SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'). Unfortunately the unique session id
is not provided in the (g)v$session views (the client_identifier is) - so we
need to calculate it by ourselfes. It is worth to note that the schema were the
console package is installed does not need any higher privileges and does
therefore not read from the (g)v$session view. In other words: When you want to
debug another session you need to have a way to find the target session - for
APEX this is easy - the client identifier is set by APEX and can be calculated
by looking at your session id in the browser URL. For a specific, non shared
session you can use the (g)v$session view to calculate the unique session ID by
providing at least sid and serial.

**/

--------------------------------------------------------------------------------

function get_sid_serial_inst_id (
  p_unique_session_id varchar2
) return varchar2;
/**

Calculates the sid, serial and inst_id out of a unique session ID as it is
provided by DBMS_SESSION.UNIQUE_SESSION_ID.

Is for informational purposes and to map a recent log entry back to a maybe
running session.

The same as with `get_unique_session_id`: I have no idea if the calculation is
correct. It works currently and is implementes in this way:

```sql
v_sid_serial_inst_id :=
     to_char(to_number(substr(p_unique_session_id, 1, 4), '000x')) || ', '
  || to_char(to_number(substr(p_unique_session_id, 5, 4), '000x')) || ', '
  || to_char(to_number(substr(p_unique_session_id, 9, 4), '0000'));
```

**/

--------------------------------------------------------------------------------

function get_call_stack return varchar2;
/**

Gets the current call stack and if an error was raised also the error stack and
the error backtrace. Is used internally by the console methods error and trace
and also, if you set on other console methods the parameter p_trace to true.

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

function context_available_yn return varchar2;

--------------------------------------------------------------------------------
-- INTERNAL UTILITIES (only visible when ccflag `utils_public` is set to true)
--------------------------------------------------------------------------------

$if $$utils_public $then

procedure create_log_entry (
  p_level      integer,
  p_message    clob,
  p_trace      boolean,
  p_user_agent varchar2
);

function logging_enabled(
  p_level   integer
) return boolean;

function get_context return varchar2;

procedure set_context(p_value varchar2);

procedure clear_context;


$end

end console;
/
