# Oracle Instrumentation Console

An instrumentation tool for Oracle developers focused on easy installation and
usage.

*This is currently beta and in heavy development. Therefore I do not update the
[changelog](docs/changelog.md) until we have a stable version available. Also,
you should uninstall console before you install a new version. Feedback and help
is welcome.*

## Easy to install

- Works with or without a context.
- Has a single installation script (can be installed on apex.oracle.com via "SQL
  Workshop > SQL Scripts").
- If you cannot wait to test it out: Open SQLcl, connect to your desired install
    schema and call
    `@https://raw.githubusercontent.com/ogobrecht/console/main/install/create_console_objects.sql`.
    After some seconds you should be ready to go...

## Easy to use

- Save to run in production without configuration
  - Errors are always logged.
  - Minimal resource consumption.
  - Logging can be switched on when needed for specific sessions identified by
    the client identifier without recompilation (no, there is no way to enable
    logging for all sessions, for good reasons and if a session has no client
    identifier, console is setting one for you).
- Mostly API compatible with the [JavaScript Console
  API](https://developers.google.com/web/tools/chrome-devtools/console/api).
  This means, the same method names are provided. The parameters differs a
  little bit to fit our needs in PL/SQL. Not all methods making sense in a
  PL/SQL instrumentation tool (we have no direct screen) and therefore these six
  are not implemented: dir, dirxml, group, groupCollapsed, groupEnd and
  countReset (instead we have count_end and we ignore the line number, where the
  count occurred). For the two \*_end methods we use snake case instead of camel
  case for readability. As table is a keyword in SQL we named our method table#:
  - [X] [console.error](docs/console.md#error) (level 1=error)
  - [X] [console.warn](docs/console.md#warn) (level 2=warning)
  - [X] [console.info](docs/console.md#info) (level 3=info)
  - [X] [console.log](docs/console.md#log) (level 3=info)
  - [X] [console.debug](docs/console.md#debug) (level 4=verbose)
  - [X] [console.assert](docs/console.md#assert) (level 1=error, if failed)
  - [X] [console.table#](docs/console.md#table) (level 3=info)
  - [X] [console.trace](docs/console.md#trace) (level 3=info)
  - [x] [console.count](docs/console.md#count)
  - [x] [console.count_end](docs/console.md#count_end) (level 3=info)
  - [X] [console.time](docs/console.md#time)
  - [X] [console.time_end](docs/console.md#time_end) (level 3=info)
  - [X] [console.clear](docs/console.md#clear)
- Additional methods:
  - [X] [console.permanent](docs/console.md#permanent) (level 0=permanent): Log
    permanent messages like installation or upgrade notes with the level zero,
    which are not deleted when the purge job clears the log table.
  - [X] [console.apex_error_handling](docs/console.md#apex_error_handling): Log
    internal APEX errors (only available, if APEX is installed, also see the
    [APEX
    docs](https://docs.oracle.com/en/database/oracle/application-express/20.2/aeapi/Example-of-an-Error-Handling-Function.html#GUID-2CD75881-1A59-4787-B04B-9AAEC14E1A82)).
  - [ ] [console.apex_plugin_render](docs/console.md#apex_plugin_render),
    [apex_plugin_ajax](docs/console.md#apex_plugin_ajax): Methods for the APEX
    plugin (only available, if APEX is installed).
  - [X] [console.action](docs/console.md#action),
    [module](docs/console.md#module): Aliases for
    dbms_application_info.set_action and set_module to be friendly to the DBA
    and monitoring teams. The module is usually set by the application (for
    example APEX is setting the module, and often also the action).
- Additional methods to manage logging mode of sessions and to see the current
  status of the package console:
  - [X] [console.init](docs/console.md#init),  [exit](docs/console.md#exit) the
    logging mode for a specific session by the client identifier
  - [X] [console.my_client_identifier](docs/console.md#my_client_identifier),
    [my_log_level](docs/console.md#my_log_level)
  - [X] [console.context_is_available](docs/console.md#context_is_available),
    [context_is_available_yn](docs/console.md#context_is_available_yn)
  - [X] [console.level_is_warning](docs/console.md#level_is_warning),
    [level_is_warning_yn](docs/console.md#level_is_warning_yn)
  - [X] [console.level_is_info](docs/console.md#level_is_info),
    [level_is_info_yn](docs/console.md#level_is_info_yn)
  - [X] [console.level_is_verbose](docs/console.md#level_is_verbose),
    [level_is_verbose_yn](docs/console.md#level_is_verbose_yn)
  - [X] [console.version](docs/console.md#version)
  - [X] [console.view_last](docs/console.md#view_last)
  - [X] [console.view_cache](docs/console.md#view_cache),
    [flush_cache](docs/console.md#flush_cache)
  - [ ] `console.view_status`
  - [ ] `console.view_counters`,  `view_timers`
- Additional methods (mostly used by console internally) which might also
  helpful for you:
  - [X] [console.to_yn](docs/console.md#to_yn),
    [to_bool](docs/console.md#to_bool)
  - [X] [console.to_html_table](docs/console.md#to_html_table)
  - [X] [console.to_md_tab_header](docs/console.md#to_md_tab_header),
    [to_md_tab_data](docs/console.md#to_md_tab_data)
  - [X] [console.get_runtime](docs/console.md#get_runtime),
    [get_runtime_seconds](docs/console.md#get_runtime_seconds)
  - [X] [console.get_scope](docs/console.md#get_scope),
    [get_call_stack](docs/console.md#get_call_stack)
  - [X] [console.get_apex_env](docs/console.md#get_apex_env),
    [get_cgi_env](docs/console.md#get_cgi_env),
    [get_console_env](docs/console.md#get_console_env),
    [get_user_env](docs/console.md#get_user_env)
  - [X] [console.clob_append](docs/console.md#clob_append),
    [clob_flush_cache](docs/console.md#clob_flush_cache)

- Views for the logging entries of the table console_logs:
  - [ ] `console_logs`
  - [ ] `console_logs_last_10_minutes`
  - [ ] `console_logs_last_hour`
  - [ ] `console_logs_last_24_hours`

For a more detailed overview of the public API methods please see the [docs for
the package console](docs/console.md).

## Roadmap

- [X] API compatibility with the JavaScript console (with exceptions)
- [ ] APEX plug-in to be able to track client side browser errors
- [ ] Something else? Let us discuss your ideas - simply [open an
  issue](https://github.com/ogobrecht/console/issues/new) ...

## Dependencies

Oracle DB >= 12.1

## One Minute Installation

Open SQLcl, connect to your desired install schema and call
`@https://raw.githubusercontent.com/ogobrecht/console/main/install/create_console_objects.sql`

## Normal Installation

[Clone the repository](https://github.com/ogobrecht/console) or download the
[latest
version](https://github.com/ogobrecht/oracle-instrumentation-console/releases/latest)
and unzip it.

The installation itself is splitted into one mandatory and two or three optional
steps:

1. Install CONSOLE itself
    - Start SQL*Plus and connect to your desired install schema
    - Run `@install/create_console_objects.sql`
    - User needs the rights to create packages, tables and views
    - Do this step on every new release of CONSOLE
2. Optional: Create a context
    - For performance reasons this is recommended, but it will work without a
      context
    - Start SQL*Plus and connect to a privileged user
    - Run `@install/create_context.sql "YOUR_CONSOLE_INSTALL_SCHEMA"`
    - Maybe your DBA needs to do that for you once
3. Optional: Grant rights to client schema
    - When installed in a central tools schema you may want to grant execute
      rights on the package and select rights on the views to public or other
      schemas
    - Start SQL*Plus and connect to your CONSOLE install schema
    - Run `@install/grant_rights.sql "YOUR_CLIENT_SCHEMA"`
4. Optional: Create synonyms in client schema(s)
    - When you want to use it in another schema you may want to create synonyms
      there or public ones for easier access
    - Maybe you want also different names for your synonyms like `log` instead
      of `console`
    - As this step is very variable you should create a reusable script by
      yourself...

## Uninstallation

Hopefully you will never need it...

As with the installation the uninstallation is splitted into multiple steps:

1. Drop the CONSOLE objects
    - Start SQL*Plus and connect to your CONSOLE install schema
    - Run `@uninstall/drop_console_objects.sql`
2. Drop the context (if you have one)
    - Start SQL*Plus and connect to a privileged user
    - Run `@uninstall/drop_context.sql "YOUR_CONSOLE_INSTALL_SCHEMA"`
    - Maybe your DBA needs to do that for you
3. Drop synonyms in client schemas
    - You know, if you created synonyms and how they were named...
