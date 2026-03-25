create or replace package console_test as
--%suite(Console package)
--%rollback(manual)

--%beforeeach(console_test_helpers.truncate_console_logs, console_test_helpers.enable_all_logging)


--%context(Basic logging)

--%test(Basic logging (DEBUG))
procedure basic_logging_debug;

--%test(Basic logging (INFO))
procedure basic_logging_info;

--%test(Basic logging (WARNING))
procedure basic_logging_warning;

--%test(Basic logging (ERROR))
procedure basic_logging_error;

--%test(Basic logging (TRACE))
procedure basic_logging_trace;

--%test(Don't log DEBUG)
procedure dont_log_debug;

--%test(Don't log INFO)
procedure dont_log_info;

--%test(Don't log WARNING)
procedure dont_log_warning;

--%test(Don't log TRACE)
procedure dont_log_trace;

--%test(Error is always logged regardless of level)
procedure error_always_logged_regardless_of_level;

--%test(Log null message creates entry)
procedure log_null_message_creates_entry;

--%test(Log message larger than 4000 chars is stored)
procedure log_message_larger_than_4000_is_stored;

--%test(Logging as autonomous transaction)
procedure logging_is_autonomous_transaction;

--%endcontext

--%context(Logging functions returning log_id)

--%test(Error function returns log_id)
procedure error_function_returns_log_id;

--%test(Warn function returns log_id)
procedure warn_function_returns_log_id;

--%test(Info function returns log_id)
procedure info_function_returns_log_id;

--%test(Log function returns log_id)
procedure log_function_returns_log_id;

--%test(Debug function returns log_id)
procedure debug_function_returns_log_id;

--%test(Trace function returns log_id)
procedure trace_function_returns_log_id;

--%endcontext

--%context(Error Stack)

--%test(Error save stack captures raised error)
procedure error_save_stack_captures_error;

--%test(Error save stack keeps multiple saved errors)
procedure error_save_stack_multiple_saves;

--%endcontext


--%context(Console Parameters)

--%test(Permanent logging)
procedure permanent_logging;

--%test(Include Call Stack)
procedure include_call_stack;

--%test(Custom User Agent)
procedure custom_user_agent;

--%test(Custom User Scope)
procedure custom_user_scope;

--%test(Custom User Error Code)
procedure custom_user_error_code;

--%test(Custom User Call Stack)
procedure custom_user_call_stack;

--%endcontext

end console_test;
/