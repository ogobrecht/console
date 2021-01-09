create or replace package console authid current_user is

c_name        constant varchar2(30 char) := 'Oracle Instrumentation Console';
c_version     constant varchar2(10 char) := '0.1.0';
c_url         constant varchar2(40 char) := 'https://github.com/ogobrecht/console';
c_license     constant varchar2(10 char) := 'MIT';
c_license_url constant varchar2(60 char) := 'https://github.com/ogobrecht/console/blob/main/LICENSE';
c_author      constant varchar2(20 char) := 'Ottmar Gobrecht';

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

Oracle DB >= 18.x??? will mainly depend on the call stack facilities of the
release, we will see...

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
  p_message    clob,
  p_trace      boolean  default true,
  p_user_agent varchar2 default null
);
/**

Log a message with the level 1 (error).

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

procedure assert(
  p_expression in boolean,
  p_message    in varchar2
);
/**

If the given expression evaluates to false an error is raised with the given message.

EXAMPLE

```sql
begin
  console.assert(5 < 3, 'test assertion');
exception
  when others then
    console.error('something went wrong');
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
-- INTERNAL UTILITIES (only visible when ccflag `utils_public` is set to true)
--------------------------------------------------------------------------------

$if $$utils_public $then

$end

end console;
/
