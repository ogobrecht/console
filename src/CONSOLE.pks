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
- Go into the project root directory and use SQL*Plus (or another tool which can
  run SQL scripts)

The installation itself is splitted into two mandatory and two optional steps:

1. Create a context with a privileged user
    - `1_create_context.sql`
    - Maybe your DBA needs to do that for you once
2. Install the tool itself in your desired target schema
    - `2_install_console.sql`
    - User needs the rights to create a package, a table and views
    - Do this step on every new release of the tool
3. Optional: When installed in a central tools schema you may want to grant
   execute rights on the package and select rights on the views to public or
   other schemas
    - `3_grant_rights.sql`
4. Optional: When you want to use it in another schema you may want to create
   synonyms there for easier access
    - `4_create_synonyms.sql`

UNINSTALLATION

Hopefully you will never need this...

FIXME: Create uninstall scripts

**/


--------------------------------------------------------------------------------
-- CONSTANTS, TYPES
--------------------------------------------------------------------------------
subtype vc16    is varchar2(   16 char);
subtype vc32    is varchar2(   32 char);
subtype vc64    is varchar2(   64 char);
subtype vc128   is varchar2(  128 char);
subtype vc256   is varchar2(  256 char);
subtype vc500   is varchar2(  500 char);
subtype vc1000  is varchar2( 1000 char);
subtype vc2000  is varchar2( 2000 char);
subtype vc4000  is varchar2( 4000 char);
subtype vcmax   is varchar2(32767 char);

--------------------------------------------------------------------------------
-- MAIN LOGGING METHODS
--------------------------------------------------------------------------------
procedure permanent (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null);
/**

Log a message with the level 0 (permanent). These messages will not be deleted
on cleanup.

**/

procedure error (
  p_message    clob,
  p_trace      boolean  default true,
  p_user_agent varchar2 default null);
/**

Log a message with the level 1 (error).

**/

procedure warn (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null);
/**

Log a message with the level 2 (warning).

**/

procedure info(
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null);
/**

Log a message with the level 3 (info).

**/

procedure log(
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null);
/**

Log a message with the level 3 (info).

**/

procedure debug (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null);
/**

Log a message with the level 4 (verbose).

**/

--------------------------------------------------------------------------------
-- HELPER METHODS
--------------------------------------------------------------------------------

function get_my_unique_session_id return varchar2;
/**

Get the unique session id for debugging of the own session.

Returns the ID provided by DBMS_SESSION.UNIQUE_SESSION_ID.

**/


function get_unique_session_id (
  p_sid     integer,
  p_serial  integer,
  p_inst_id integer default 1) return varchar2;
/**

Get the unique session id for debugging of another session.

Calculates the ID provided out of the three parameters:

```sql
v_session_id := ltrim(to_char(p_sid,     '000X'))
             || ltrim(to_char(p_serial,  '000X'))
             || ltrim(to_char(p_inst_id, '0000'));
```

This method to calculate the unique session ID is not documented by Oracle. It
seems to work, but we have no guarantee, that it is working forever or under all
circumstances.

The first two parts seems to work, the part three for the inst_id is only a
guess and should work from zero to nine. But above I have no experience. Does
anybody have a RAC running with more then nine instances? Please let me know -
maybe I need to calculate here also with a hex format mask...

**/

function get_sid_serial_inst_id (p_unique_session_id varchar2) return varchar2;

/**

Calculates the sid, serial and inst_id out of a unique session ID as it is
provided by DBMS_SESSION.UNIQUE_SESSION_ID.

**/

--------------------------------------------------------------------------------
-- INTERNAL UTILITIES (only visible when ccflag `utils_public` is set to true)
--------------------------------------------------------------------------------

$if $$utils_public $then
  -- currently no private utils existing
$end

end console;
/
