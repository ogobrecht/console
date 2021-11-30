<!-- nav -->

[Index](README.md)
| [Installation](installation.md)
| [Introduction](introduction.md)
| [API Overview](api-overview.md)
| [Package Console](package-console.md)
| [Changelog](changelog.md)
| [Uninstallation](uninstallation.md)

<!-- navstop -->

# Changelog

## v1.1.1 (2021-11-30)

- Helper `generate_param_trace`: append object name to the generated code, improve docs

## v1.1.0 (2021-11-28)

- New helper `generate_param_trace` to generate code for tracing parameters - thanks to github.com/vincimaroda for the idea

## v1.0.1 (2021-10-12)

- Fix #11: Package CONSOLE does not compile under 12.2 with error message like "no function t_attribute_value_row..."

## v1.0.0 (2021-10-04)

- Remove context - we work now with a single record conf table with result cache
  enabled to simplify the configuration and minify the overhead introduced by
  console
  - Rename conf table from `CONSOLE_GLOBAL_CONF` to `CONSOLE_CONF`
  - Rename purge job from `CONSOLE_CLEANUP` to `CONSOLE_PURGE`
- Remove the possibility to cache log entries because you can potentially loose
  log entries - this impacts the possibility to extend the logs with own tables
  by using the overloaded log functions (which are returning the log ID)
- Streamline API method names:
  - Rename `view_client_prefs` to `client_prefs`
  - Rename `view_status` to `status`
  - Rename `count_log` & `time_log` to `count_current` & `time_current`
  - New procedures `count_reset` and `time_reset`
  - New function overloads for the procedures `count_current` and `time_current`
- New helper method `assertf` which supports formatted messages (a short form of
  `console.assert([boolean expression], console.format(...))`)
- New helper method `exit_all` to exit/unset all client preferences in one go
- New pipelined function `conf` to show the global configuration as an attribute
  and value list
- Change helper functions to_yn, to_string and to_bool to return null on invalid
  input
- Minimum database version is now 12.2

## v1.0-beta8 (2021-08-15)

- More overloads to procedure `add_param`
- Improved docs
- ASCII art only on APEX error page
- Aligned header levels in generated Markdown
- Change sequence cache for table `console_logs` from default 20 to 1000
- Fix: Only owner of package `console` is allowed to purge entries and change
  global config
- Fix: Call stack - include line info only if not null
- Fix: Function `to_md_code_block` - wrap input in fences only if not null

## v1.0-beta7 (2021-06-09)

- New overloaded procedure `add_param` to collect parameters before the call to
  one of the log methods error, warn, info, log, debug and trace
- New procedure `printf`
- Rename table column `CONSOLE_LOGS.LOG_SYSTIME` to `CONSOLE_LOGS.LOG_TIME` and
  change the data type from `timstamp` to `timestamp with local time zone`
- Remove prefix `get_` from all helper functions after reading [Stevens article
  about naming
  conventions](https://www.insum.ca/feuertip-11-what-makes-an-effective-naming-convention/)

## v1.0-beta6 (2021-05-16)

- Rename table CONSOLE_CONF to CONSOLE_GLOBAL_CONF
- Rename table CONSOLE_SESSIONS to CONSOLE_CLIENT_PREFS
- Allow all levels for global configuration
- New shortcuts for global configuration (conf_level, conf_units,
  conf_check_interval...)
- New helpers `split_to_table`, `split` & `join`
- Fix script for install log entry
- Fix configure multiple units for specific level

## v1.0-beta5 (2021-05-02)

- Fix table CONSOLE_CONF (remove `organization index`)
- New parameter for conf method
- Add missing table comments
- Improved APEX error handler function
- Improved docs

## v1.0-beta4 (2021-04-25)

- Add the ability to set specific PL/SQL units (packages, functions, procedures)
  to a different log level, if you want to monitor for example new code in all
  sessions (see [console.conf](package-console.md#procedure-conf))

## v1.0-beta3 (2021-04-12)

- New global configuration to be able to set the default log level and the conf
  check interval to other values than 1 and 10 seconds (see
  [console.conf](package-console.md#procedure-conf))
- Fixed: Saved call stack shows line numbers from the method console.assert
  instead of the calling code
- Some code refactoring

## v1.0-beta2 (2021-04-04)

First improvements after user feedback - thank you Dietmar (@daust):

- Splitting level verbose into debug and trace (we have now error, warning,
  info, debug and trace)
- Remove method permanent (is now a attribute in all log methods)
- Overload all log messages (procedure and function returning log_id)
- Improved docs to reflect the changes

## v1.0-beta1 (2021-03-14)

- First official beta version for collecting feedback from other users.

## countless alpha and beta versions with many api changes ;-)

- The CONSOLE was in heavy development. Therefore I did not update the
  changelog.

## v0.1-alpha (2021-01-05)

- First functional code.
