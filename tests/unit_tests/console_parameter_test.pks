create or replace package console_parameter_test as
   --%suite(Console parameter logging)
   --%rollback(manual)

   --%beforeall(console_test_helpers.enable_all_logging)

   --%beforeeach(console_test_helpers.truncate_console_logs)

   --%context(Simple Parameter Logging)

   --%test(varchar2 parameter)
   procedure varchar2_parameter;

   --%test(Truncated varchar2 parameter)
   procedure truncated_varchar2_parameter;

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

   --%test(Truncated clob parameter)
   procedure truncated_clob_parameter;

   --%test(xmltype parameter)
   procedure xmltype_parameter;

   --%test(Truncated xmltype parameter)
   procedure truncated_xmltype_parameter;

   --%test(Parameter name length limit)
   procedure long_parameter_name;

   --%test(Three parameters - classic)
   procedure three_parameters_classic;

   --%endcontext

   --%context(Builder Pattern Parameters)

   --%test(Three parameters - builder pattern)
   procedure three_parameters_builder_pattern;

   --%test(Parameter builder pattern procedure varchar2)
   procedure parameter_builder_pattern_procedure_varchar2;

   --%test(Parameter builder pattern procedure number)
   procedure parameter_builder_pattern_procedure_number;

   --%test(Parameter builder pattern procedure date)
   procedure parameter_builder_pattern_procedure_date;

   --%test(Parameter builder pattern procedure timestamp)
   procedure parameter_builder_pattern_procedure_timestamp;

   --%test(Parameter builder pattern procedure timestamp with time zone)
   procedure parameter_builder_pattern_procedure_timestamp_tz;

   --%test(Parameter builder pattern procedure timestamp with local time zone)
   procedure parameter_builder_pattern_procedure_timestamp_ltz;

   --%test(Parameter builder pattern procedure interval year to month)
   procedure parameter_builder_pattern_procedure_interval_ym;

   --%test(Parameter builder pattern procedure interval ds)
   procedure parameter_builder_pattern_procedure_interval_ds;

   --%test(Parameter builder pattern procedure boolean)
   procedure parameter_builder_pattern_procedure_boolean;

   --%test(Parameter builder pattern procedure clob)
   procedure parameter_builder_pattern_procedure_clob;

   --%test(Parameter builder pattern procedure xmltype)
   procedure parameter_builder_pattern_procedure_xmltype;

   --%test(Parameter builder pattern function number)
   procedure parameter_builder_pattern_function_number;

   --%test(Parameter builder pattern function date)
   procedure parameter_builder_pattern_function_date;

   --%test(Parameter builder pattern function timestamp)
   procedure parameter_builder_pattern_function_timestamp;

   --%test(Parameter builder pattern function timestamp_tz)
   procedure parameter_builder_pattern_function_timestamp_tz;

   --%test(Parameter builder pattern function timestamp_ltz)
   procedure parameter_builder_pattern_function_timestamp_ltz;

   --%test(Parameter builder pattern function interval_ym)
   procedure parameter_builder_pattern_function_interval_ym;

   --%test(Parameter builder pattern function interval_ds)
   procedure parameter_builder_pattern_function_interval_ds;

   --%test(Parameter builder pattern function boolean)
   procedure parameter_builder_pattern_function_boolean;

   --%test(Parameter builder pattern function clob)
   procedure parameter_builder_pattern_function_clob;

   --%test(Parameter builder pattern function xmltype)
   procedure parameter_builder_pattern_function_xmltype;

   --%endcontext
end console_parameter_test;
/