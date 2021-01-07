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

An instrumentation tool for Oracle developers. Save to install on production and mostly API compatible with the [JavaScript console](https://developers.google.com/web/tools/chrome-devtools/console/api).

DEPENDENCIES

Oracle DB >= 18.x??? will mainly depend on the call stack facilities of the release, we will see...

INSTALLATION

- Download the [latest version](https://github.com/ogobrecht/oracle-instrumentation-console/releases/latest) and unzip it or clone the repository
- Go into the project root directory and use SQL*Plus (or another tool which can run SQL scripts)

The installation itself is splitted into two mandatory and two optional steps:

1. Create a context with a privileged user
    - `1_create_context.sql`
    - Maybe your DBA needs to do that for you once
2. Install the tool itself in your desired target schema
    - `2_install_console.sql`
    - User needs the rights to create a package, a table and views
    - Do this step on every new release of the tool
3. Optional: When installed in a central tools schema you may want to grant execute rights on the package and select rights on the views to public or other schemas
    - `3_grant_rights.sql`
4. Optional: When you want to use it in another schema you may want to create synonyms there for easier access
    - `4_create_synonyms.sql`

UNINSTALLATION

Hopefully you will never need this...

FIXME: Create uninstall scripts

**/


--------------------------------------------------------------------------------
-- CONSTANTS, TYPES
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- MAIN METHODS
--------------------------------------------------------------------------------
procedure permanent (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null);
/** Log a message with the level 0 (permanent). These messages will not be deleted on cleanup. **/

procedure error (
  p_message    clob,
  p_trace      boolean  default true,
  p_user_agent varchar2 default null);
/** Log a message with the level 1 (error). **/

procedure warn (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null);
/** Log a message with the level 2 (warning). **/

procedure info(
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null);
/** Log a message with the level 3 (info). **/

procedure log(
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null);
/** Log a message with the level 3 (info). **/

procedure debug (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null);
/** Log a message with the level 4 (verbose). **/

--------------------------------------------------------------------------------
-- UTILITIES (only compiled when public)
--------------------------------------------------------------------------------

$if $$utils_public $then



$end

end console;
/
