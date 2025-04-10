create or replace package console_test as
   --%suite(Console package)
   --%rollback(manual)

   --%beforeall
   procedure enable_all_logging;

   --%beforeeach
   procedure truncate_console_logs;


   --%context(Basic logging)

   --%test(Basic logging (DEBUG))
   procedure basic_logging_debug;

   --%test(Basic logging (INFO))
   procedure basic_logging_info;

   --%test(Basic logging (WARNING))
   procedure basic_logging_warning;

   --%test(Basic logging (ERROR))
   procedure basic_logging_error;

   --%endcontext


   --%context(Logging parameters)

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