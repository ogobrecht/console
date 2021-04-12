# Oracle Instrumentation Console

    .___.
    {o,o}   An instrumentation tool for Oracle developers
    /)__)   focused on easy installation and usage
    -"-"-   combined with nice features.

*This is currently version 1.0-beta3. Feedback and help is welcome.*

**A T T E N T I O N: As long as we are in beta state you should always run the
uninstallation script (`@uninstall/drop_console_objects.sql`) before you install
a new version. An existing context does not need to be dropped.**

## Easy to Install

- Works with or without a context.
- Has a single installation script (can be installed on apex.oracle.com via "SQL
  Workshop > SQL Scripts").
- If you cannot wait to test it out: Open SQLcl, connect to your desired install
    schema and call
    `@https://raw.githubusercontent.com/ogobrecht/console/main/install/create_console_objects.sql`.
    After some seconds you should be ready to go...
- Docs: [Installation](docs/installation.md),
  [uninstallation](docs/uninstallation.md).

## Easy to Use

- Save to run in production without configuration
  - Errors are always logged.
  - Minimal resource consumption.
  - Logging can be switched on when needed for specific sessions identified by
    the client identifier without recompilation (no, there is no way to enable
    logging for all sessions, for good reasons and if a session has no client
    identifier, console is setting one for you).
- Mostly API compatible with the [JavaScript Console
  API](https://developers.google.com/web/tools/chrome-devtools/console/api).
  Also see the [API overview](docs/api-overview.md) and for more details on the
  methods including examples the [documentation for the package
  console](docs/package-console.md).
- Docs: [Getting started](docs/getting-started.md).

## Nice Features

- The instrumentation console can help you to avoid log spoiling by only logging
  errors in your outermost package methods without loosing context details with
  the help of
  [console.error_save_stack](docs/package-console.md#procedure-error_save_stack)
  in the nested methods. This might be the most powerful feature...
- Has an optional [APEX plug-in](install/apex_plugin.sql) to log JavaScript
  errors in your client frontends. If you use another frontend technologies then
  have a look at the [JavScript sources for the APEX
  plug-in](sources/apex_plugin_console.js) as a template for an own
  implementation.
- Has an optional [APEX error handling
  function](docs/package-console.md#function-apex_error_handling) to log also
  internal errors of the APEX engine.
- No need to provide manually a scope for your log entries - console does this
  automatically for you. If needed, you can overwrite the default scope.
- Brings some useful helper functions - have a look at the [API
  overview](docs/api-overview.md).

## Dependencies

Oracle DB >= 12.1
