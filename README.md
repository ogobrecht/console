# Oracle Instrumentation Console

An instrumentation tool for Oracle developers. Save to install on production and
mostly API compatible with the [JavaScript
console](https://developers.google.com/web/tools/chrome-devtools/console/api).

## Features

- Easy to install - works with or without a context
- Easy to use
  - Save to run in production without configuration
    - Errors are always logged
    - Minimal resource consumption
    - Logging can be switched on when needed for specific sessions identified by
      the client identifier without recompilation (no, there is no way to enable
      logging for all sessions, for good reasons and if a session has no client
      identifier, console is setting one for you)
  - API compatible with the [JavaScript Console
    API](https://developers.google.com/web/tools/chrome-devtools/console/api),
    this means, the same method names are provided, the parameters differs a
    little bit to fit our needs in a PL/SQL environment (not all methods makes
    sense in PL/SQL and therefore these five are not implemented: dir, dirxml,
    group, groupCollapsed, groupEnd)
    - [X] console.error (level 1=error)
    - [X] console.warn (level 2=warning)
    - [X] console.info (level 3=info)
    - [X] console.log (level 3=info)
    - [X] console.debug (level 4=verbose)
    - [X] console.trace (level 3=info)
    - [ ] console.table (level 3=info)
    - [ ] console.count
    - [ ] console.countReset (level 3=info)
    - [ ] console.time
    - [ ] console.timeEnd (level 3=info)
    - [X] console.assert (level 1=error, if failed)
    - [X] console.clear
  - Additional method to log permanent messages like installation or upgrade
    notes with the level zero, which is not affected when the purge job clears
    the log
    - [X] console.permanent (level 0)
  - Additional method as an alias for dbms_application_info.set_action to be
    friendly to the DBA and monitoring teams. The module is usually set by the
    application (for example APEX is setting the module)
    - [X] console.action
  - Additional methods to manage logging mode of sessions and to see the current
    status of the package console
    - [X] console.init
    - [X] console.stop
    - [X] console.my_client_identifier
    - [X] console.my_log_level
    - [X] console.context_available_yn
    - [X] console.version

For an overview of the public API methods please see the [docs for the package console](docs/console.md).

## Roadmap

- [ ] API compatibility with the JavaScript console (with exceptions)
- [ ] APEX plug-in to be able to track client side browser errors
- [ ] Provide an APEX custom error function to be able to log internal APEX errors

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
    - For performance reasons this is recommended, but it will work without a context
    - Start SQL*Plus and connect to a privileged user
    - Run `@install/create_context.sql "CONSOLE_INSTALL_SCHEMA"`
    - Maybe your DBA needs to do that for you once
3. Optional: Grant rights to client schema
    - When installed in a central tools schema you may want to grant execute
      rights on the package and select rights on the views to public or other
      schemas
    - Start SQL*Plus and connect to your CONSOLE install schema
    - Run `@install/grant_rights.sql "CLIENT_SCHEMA"`
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
    - Run `@uninstall/drop_context.sql "CONSOLE_INSTALL_SCHEMA"`
    - Maybe your DBA needs to do that for you
3. Drop synonyms in client schemas
    - You know, if you created synonyms and how they were named...
