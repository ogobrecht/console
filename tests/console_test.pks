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


   --%context(Parameter Logging)

   --%test(varchar2 parameter)
   procedure varchar2_parameter;

   --%test(number parameter)
   procedure number_parameter;

   --%test(date parameter)
   procedure date_parameter;

   --%test(timestamp parameter)
   procedure timestamp_parameter;

   --%test(timestamp with time zone parameter)
   procedure timestamp_with_time_zone_parameter;

   --%test(timestamp with local time zone parameter)
   procedure timestamp_with_local_time_zone_parameter;

   --%test(interval year to month parameter)
   procedure interval_ym_parameter;

   --%test(interval day to second parameter)
   procedure interval_ds_parameter;

   --%test(boolean parameter)
   procedure boolean_parameter;

   --%test(clob parameter)
   procedure clob_parameter;

   --%test(xmltype parameter)
   procedure xmltype_parameter;

   --%endcontext

end console_test;
/