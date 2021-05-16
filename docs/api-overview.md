<!-- nav -->

[Index](README.md)
| [Installation](installation.md)
| [Getting Started](getting-started.md)
| [API Overview](api-overview.md)
| [Package Console](package-console.md)
| [Changelog](changelog.md)
| [Uninstallation](uninstallation.md)

<!-- navstop -->

# API Overview - Package CONSOLE

For a more detailed overview of the public API methods including examples please
see the [package console methods](package-console.md). You can also use the
links on the method names below.

The console API is inspired by the [JavaScript Console
API](https://developers.google.com/web/tools/chrome-devtools/console/api). This
means, we have mostly the same log levels and method names. The parameters
differs a little bit to fit our needs in PL/SQL. Not all methods making sense in
a PL/SQL instrumentation tool (we have no direct screen) and therefore these six
are not implemented: dir, dirxml, group, groupCollapsed, groupEnd and countReset
(instead we have count_end and we ignore the line number, where the count
occurred). For the two \*_end methods we use snake case instead of camel case
for readability. As table is a keyword in SQL we named our method table#. The
log level verbose is splitted into debug and trace.

We have five log levels:

- Level 1: Error
- Level 2: Warning
- Level 3: Info
- Level 4: Debug (instead of verbose in JS console)
- Level 5: Trace (not existing in JS console)

One pipelined function for viewing the log entries:

- [console.view_last](package-console.md#function-view_last) - for me this is
  the standard way: `select * from console.view_last(20)` is showing the last 20
  entries in descending order from the cache AND the log table (if not enough in
  the cache or cache is disabled)

The main instrumentation methods:

- [console.error_save_stack](package-console.md#procedure-error_save_stack):
  Does only save the current scope in an internal stack until the `error`
  procedure is called which outputs then the saved stack. This is possibly the
  most powerful feature which can save you useless log entries from nested
  methods. You need only to call `console.error` in the outermost method of you
  logic and you don't loose details.
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

Additional instrumentation methods:

- [console.action](package-console.md#procedure-action) &
  [module](package-console.md#procedure-module): Aliases for
  dbms_application_info.set_action and set_module to be friendly to the DBA and
  monitoring teams. The module is usually set by the application (for example
  APEX is setting the module, and often also the action).
- [console.apex_error_handling](package-console.md#function-apex_error_handling):
  Log internal APEX errors (only available, if APEX is installed, also see the
  [APEX
  docs](https://docs.oracle.com/en/database/oracle/application-express/20.2/aeapi/Example-of-an-Error-Handling-Function.html#GUID-2CD75881-1A59-4787-B04B-9AAEC14E1A82)).
- [console.apex_plugin_render](package-console.md#function-apex_plugin_render) &
  [apex_plugin_ajax](package-console.md#function-apex_plugin_ajax): Methods for
  the APEX plugin (only available, if APEX is installed).

Additional methods to manage logging mode of sessions and to see the current
status of the package console:

- [console.conf](package-console.md#procedure-conf)
- [console.init](package-console.md#procedure-init) &
  [exit](package-console.md#procedure-exit) &
  [exit_stale](package-console.md#procedure-exit_stale)
- [console.my_client_identifier](package-console.md#function-my_client_identifier)
  & [my_log_level](package-console.md#function-my_log_level)
- [console.context_is_available](package-console.md#function-context_is_available)
  &
  [context_is_available_yn](package-console.md#function-context_is_available_yn)
- [console.level_is_warning](package-console.md#function-level_is_warning)
  &
  [level_is_warning_yn](package-console.md#function-level_is_warning_yn)
- [console.level_is_info](package-console.md#function-level_is_info) &
  [level_is_info_yn](package-console.md#function-level_is_info_yn)
- [console.level_is_debug](package-console.md#function-level_is_debug)
  &
  [level_is_debug_yn](package-console.md#function-level_is_debug_yn)
- [console.level_is_trace](package-console.md#function-level_is_trace)
  &
  [level_is_trace_yn](package-console.md#function-level_is_trace_yn)
- [console.version](package-console.md#function-version)
- [console.view_status](package-console.md#function-view_status)
- [console.view_cache](package-console.md#function-view_cache) &
  [flush_cache](package-console.md#procedure-flush_cache)
- [console.clear](package-console.md#procedure-clear)

Additional housekeeping methods:

- [console.purge](package-console.md#procedure-purge) &
  [purge_all](package-console.md#procedure-purge_all)
- [console.cleanup_job_create](package-console.md#procedure-cleanup_job_create)
  & [cleanup_job_run](package-console.md#procedure-cleanup_job_run) &
  [cleanup_job_disable](package-console.md#procedure-cleanup_job_disable) &
  [cleanup_job_enable](package-console.md#procedure-cleanup_job_enable) &
  [cleanup_job_drop](package-console.md#procedure-cleanup_job_drop)

Additional helper methods (mostly used by console internally) which might also
helpful for you:

- [console.split_to_table](package-console.md#function-split_to_table) &
  [split](package-console.md#function-split) &
  [join](package-console.md#function-join)
- [console.to_yn](package-console.md#function-to_yn) &
  [to_string](package-console.md#function-to_string) &
  [to_bool](package-console.md#function-to_bool)
- [console.to_html_table](package-console.md#function-to_html_table)
- [console.to_md_tab_header](package-console.md#function-to_md_tab_header) &
  [to_md_tab_data](package-console.md#function-to_md_tab_data)
- [console.to_unibar](package-console.md#function-to_unibar)
- [console.get_runtime](package-console.md#function-get_runtime) &
  [get_runtime_seconds](package-console.md#function-get_runtime_seconds) &
  [get_runtime_milliseconds](package-console.md#function-get_runtime_milliseconds)
- [console.get_level_name](package-console.md#function-get_level_name)
- [console.get_scope](package-console.md#function-get_scope) &
  [get_calling_unit](package-console.md#function-get_calling_unit) &
  [get_call_stack](package-console.md#function-get_call_stack)
- [console.get_apex_env](package-console.md#function-get_apex_env) &
  [get_cgi_env](package-console.md#function-get_cgi_env) &
  [get_console_env](package-console.md#function-get_console_env) &
  [get_user_env](package-console.md#function-get_user_env)
- [console.clob_append](package-console.md#procedure-clob_append) &
  [clob_flush_cache](package-console.md#procedure-clob_flush_cache)
- [console.print](package-console.md#procedure-print)
