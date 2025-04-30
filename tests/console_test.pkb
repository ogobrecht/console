create or replace package body console_test as

c_parameters_heading constant varchar2(100) := '#### Parameters\s*\| Parameter Name\s*\| Value\s*\|\s\| -* \| -* \|';

procedure enable_all_logging as
begin
   console.conf(p_level => 4);
end enable_all_logging;

procedure truncate_console_logs as
begin

   -- execute immediate 'truncate table console_logs';
   delete from console_logs;

end truncate_console_logs;


function fetch_logs return sys_refcursor as
   l_logs sys_refcursor;
begin

   open l_logs for select * from console_logs;

   return l_logs;

end fetch_logs;


procedure basic_logging_debug as
   l_log_message clob := 'Just a small test (DEBUG)';
   l_client_identifier varchar2(100) := 'TEST_IDENTIFIER';

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   dbms_session.set_identifier(l_client_identifier);

   console.debug(l_log_message);
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_debug() as level_id,
         console.level_name(p_level => console.level_debug()) as level_name,
         'N' as permanent,
         user || '.CONSOLE_TEST.BASIC_LOGGING_DEBUG, line 40' as scope,
         l_log_message || chr(10) || chr(10) as message,
         to_number(null) as error_code,
         null as call_stack,
         'console_test' as action,
         'basic_logging_debug' as client_info,
         l_client_identifier as client_identifier
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).exclude('LOG_ID,LOG_TIME,SESSION_USER,MODULE,IP_ADDRESS,HOST,OS_USER,OS_USER_AGENT');


end basic_logging_debug;


procedure basic_logging_info as
   l_log_message clob := 'Just a small test (INFO)';
   l_client_identifier varchar2(100) := 'TEST_IDENTIFIER_INFO';

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   dbms_session.set_identifier(l_client_identifier);

   console.info(l_log_message);
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_info() as level_id,
         console.level_name(p_level => console.level_info()) as level_name,
         'N' as permanent,
         user || '.CONSOLE_TEST.BASIC_LOGGING_INFO, line 73' as scope,
         l_log_message || chr(10) || chr(10) as message,
         to_number(null) as error_code,
         null as call_stack,
         'console_test' as action,
         'basic_logging_info' as client_info,
         l_client_identifier as client_identifier
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).exclude('LOG_ID,LOG_TIME,SESSION_USER,MODULE,IP_ADDRESS,HOST,OS_USER,OS_USER_AGENT');

end basic_logging_info;


procedure basic_logging_warning as
   l_log_message clob := 'Just a small test (WARNING)';
   l_client_identifier varchar2(100) := 'TEST_IDENTIFIER_WARNING';

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   dbms_session.set_identifier(l_client_identifier);

   console.warn(l_log_message);
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_warning() as level_id,
         console.level_name(p_level => console.level_warning()) as level_name,
         'N' as permanent,
         user || '.CONSOLE_TEST.BASIC_LOGGING_WARNING, line 105' as scope,
         l_log_message || chr(10) || chr(10) as message,
         to_number(null) as error_code,
         null as call_stack,
         'console_test' as action,
         'basic_logging_warning' as client_info,
         l_client_identifier as client_identifier
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).exclude('LOG_ID,LOG_TIME,SESSION_USER,MODULE,IP_ADDRESS,HOST,OS_USER,OS_USER_AGENT');

end basic_logging_warning;


procedure basic_logging_error as
   l_log_message clob := 'Just a small test (ERROR)';
   l_client_identifier varchar2(100) := 'TEST_IDENTIFIER_ERROR';

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   dbms_session.set_identifier(l_client_identifier);

   console.error(l_log_message);
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_error() as level_id,
         console.level_name(p_level => console.level_error()) as level_name,
         'N' as permanent,
         user || '.CONSOLE_TEST.BASIC_LOGGING_ERROR, line 137' as scope,
         l_log_message || chr(10) || chr(10) as message,
         to_number(null) as error_code,
         'console_test' as action,
         'basic_logging_error' as client_info,
         l_client_identifier as client_identifier
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).exclude('LOG_ID,LOG_TIME,SESSION_USER,MODULE,IP_ADDRESS,HOST,OS_USER,OS_USER_AGENT,CALL_STACK');

end basic_logging_error;


procedure permanent_logging as
   l_log_message clob := 'Permanent Log';

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   console.info(
      l_log_message
      ,p_permanent => true
   );
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_info() as level_id,
         console.level_name(p_level => console.level_info()) as level_name,
         'Y' as permanent
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).include('LEVEL_ID,LEVEL_NAME,PERMANENT');

end permanent_logging;


procedure include_call_stack as
   l_log_message clob := 'Include Call Stack';

   l_actual_call_stack varchar2(4000);
   l_expected_call_stack varchar2(4000) := '#### Call Stack%INCLUDE_CALL_STACK%';
begin

   console.info(
      l_log_message
      ,p_call_stack => true
   );
   select call_stack
   into l_actual_call_stack
   from console_logs;

   ut.expect(l_actual_call_stack).to_be_like(l_expected_call_stack);

end include_call_stack;


procedure custom_user_agent as
   l_log_message clob := 'Custom User Agent';
   l_user_agent varchar2(200) := 'myuseragent';

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   console.info(
      l_log_message
      ,p_user_agent => l_user_agent
   );
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_info() as level_id,
         console.level_name(p_level => console.level_info()) as level_name,
         l_user_agent as os_user_agent
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).include('LEVEL_ID,LEVEL_NAME,OS_USER_AGENT');

end custom_user_agent;


procedure custom_user_scope as
   l_log_message clob := 'Custom User Scope';
   l_user_scope varchar2(200) := 'myuserscope';

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   console.info(
      l_log_message
      ,p_user_scope => l_user_scope
   );
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_info() as level_id,
         console.level_name(p_level => console.level_info()) as level_name,
         l_user_scope as scope
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).include('LEVEL_ID,LEVEL_NAME,SCOPE');

end custom_user_scope;


procedure custom_user_error_code as
   l_log_message clob := 'Custom User Error Code';
   l_user_error_code integer := 988;

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   console.info(
      l_log_message
      ,p_user_error_code => l_user_error_code
   );
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_info() as level_id,
         console.level_name(p_level => console.level_info()) as level_name,
         l_user_error_code as error_code
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).include('LEVEL_ID,LEVEL_NAME,ERROR_CODE');

end custom_user_error_code;


procedure custom_user_call_stack as
   l_log_message clob := 'Custom User Call Stack';
   l_user_call_stack varchar2(300) := 'Some call stack';

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   console.info(
      l_log_message,
      p_user_call_stack => l_user_call_stack
   );
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_info() as level_id,
         console.level_name(p_level => console.level_info()) as level_name,
         l_user_call_stack as call_stack
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).include('LEVEL_ID,LEVEL_NAME,CALL_STACK');

end custom_user_call_stack;


procedure varchar2_parameter as

   l_parameter_name varchar2(100) := 'Test varchar2_parameter';
   l_parameter_value varchar2(100) := 'Some test';
   l_expected_logging_message_pattern console_logs.message%type := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || l_parameter_value || '\s*\|\s*';
   l_actual_logging_message console_logs.message%type;

begin

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end varchar2_parameter;


procedure truncated_varchar2_parameter as

   l_parameter_name varchar2(100) := 'truncated_varchar2_parameter';
   l_parameter_value varchar2(4000) := 'Some test';
   l_expected_logging_message_pattern console_logs.message%type;
   l_actual_logging_message console_logs.message%type;

begin

   l_parameter_value := rpad('test', 3004, 'u');
   l_expected_logging_message_pattern := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || 'test(u){1996}' || '\s*\|\s*';

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end truncated_varchar2_parameter;


procedure number_parameter as

   l_parameter_name varchar2(100) := 'Test number_parameter';
   l_parameter_value number := 1855;
   l_expected_logging_message_pattern console_logs.message%type := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || l_parameter_value || '\s*\|\s*';
   l_actual_logging_message console_logs.message%type;

begin

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end number_parameter;


procedure date_parameter as

   l_parameter_name varchar2(100) := 'Test date_parameter';
   l_parameter_value date := to_date('29.02.2024', 'dd.mm.yyyy');
   l_expected_logging_message_pattern console_logs.message%type := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || to_char(l_parameter_value, 'yyyy-mm-dd hh24:mi:ss') || '\s*\|\s*';
   l_actual_logging_message console_logs.message%type;

begin

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end date_parameter;


procedure timestamp_parameter as

   l_parameter_name varchar2(100) := 'Test timestamp_parameter';
   l_parameter_value timestamp := to_timestamp('29.02.2024 12:31:56.126988774', 'dd.mm.yyyy hh24:mi:ss.ff9');
   l_expected_logging_message_pattern console_logs.message%type := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || to_char(l_parameter_value, 'yyyy-mm-dd hh24:mi:ss.ff9') || '\s*\|\s*';
   l_actual_logging_message console_logs.message%type;

begin

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end timestamp_parameter;


procedure timestamp_with_time_zone_parameter as

   l_parameter_name varchar2(100) := 'Test timestamp_with_time_zone_parameter';
   l_parameter_value timestamp with time zone := to_timestamp_tz('29.02.2024 15:37:56.166988794 UTC', 'dd.mm.yyyy hh24:mi:ss.FF9 tzr');
   l_expected_logging_message_pattern console_logs.message%type := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || to_char(l_parameter_value, 'yyyy-mm-dd hh24:mi:ss.ff9 tzr') || '\s*\|\s*';
   l_actual_logging_message console_logs.message%type;

begin

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end timestamp_with_time_zone_parameter;


procedure timestamp_with_local_time_zone_parameter as

   l_parameter_name varchar2(100) := 'Test timestamp_with_local_time_zone_parameter';
   l_parameter_value timestamp with local time zone;
   l_hours_offset number := 12;
   l_expected_logging_message_pattern console_logs.message%type;
   l_actual_logging_message console_logs.message%type;

begin
   execute immediate q'[ALTER SESSION SET TIME_ZONE = 'UTC']';
   l_parameter_value := to_timestamp_tz('29.02.2024 15:37:56.166988794 UTC', 'dd.mm.yyyy hh24:mi:ss.FF9 tzr');
   l_expected_logging_message_pattern := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || to_char(l_parameter_value + numtodsinterval(12, 'HOUR'), 'yyyy-mm-dd hh24:mi:ss.ff9') || ' \+' || to_char(l_hours_offset) || ':00' || '\s*\|\s*';
   execute immediate q'[ALTER SESSION SET TIME_ZONE = '+]' || to_char(l_hours_offset) || q'[:00']';
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end timestamp_with_local_time_zone_parameter;


procedure interval_ym_parameter as

   l_parameter_name varchar2(100) := 'Test interval_ym_parameter';
   l_parameter_value interval year to month := interval '1-2' year to month;
   l_expected_logging_message_pattern console_logs.message%type := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || '\+01-02' || '\s*\|\s*';
   l_actual_logging_message console_logs.message%type;

begin

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end interval_ym_parameter;


procedure interval_ds_parameter as

   l_parameter_name varchar2(100) := 'Test interval_ds_parameter';
   l_parameter_value interval day to second := interval '10 18:30:15.12' day to second;
   l_expected_logging_message_pattern console_logs.message%type := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || '\+10 18:30:15.120000' || '\s*\|\s*';
   l_actual_logging_message console_logs.message%type;

begin

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end interval_ds_parameter;


procedure boolean_parameter as

   l_parameter_name varchar2(100) := 'Test boolean_parameter';
   l_parameter_value boolean := true;
   l_expected_logging_message_pattern console_logs.message%type := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || 'true' || '\s*\|\s*';
   l_actual_logging_message console_logs.message%type;

begin

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end boolean_parameter;


procedure clob_parameter as

   l_parameter_name varchar2(100) := 'Test clob_parameter';
   l_parameter_value clob := 'Some large value';
   l_expected_logging_message_pattern console_logs.message%type := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || l_parameter_value || '\s*\|\s*';
   l_actual_logging_message console_logs.message%type;

begin

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end clob_parameter;


procedure truncated_clob_parameter as

   l_parameter_name varchar2(100) := 'truncated_clob_parameter';
   l_parameter_value clob := 'Some test';
   l_expected_logging_message_pattern console_logs.message%type;
   l_actual_logging_message console_logs.message%type;

begin

   l_parameter_value := rpad('test', 3004, 'u');
   l_expected_logging_message_pattern := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || 'test(u){1996}' || '\s*\|\s*';

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end truncated_clob_parameter;


procedure xmltype_parameter as

   l_parameter_name varchar2(100) := 'Test xmltype_parameter';
   l_parameter_value xmltype := xmltype.createxml('<test>Test value</test>');
   l_expected_logging_message_pattern console_logs.message%type := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || l_parameter_value.getclobval() || '\s*\|\s*';
   l_actual_logging_message console_logs.message%type;

begin

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end xmltype_parameter;


procedure truncated_xmltype_parameter as

   l_parameter_name varchar2(100) := 'truncated_xmltype_parameter';
   l_parameter_value xmltype;
   l_expected_logging_message_pattern console_logs.message%type;
   l_actual_logging_message console_logs.message%type;
   l_xml_filler varchar2(10) := '<test/>';

begin

   l_parameter_value := xmltype.createxml('<root>' || rpad(l_xml_filler, length(l_xml_filler) * 500, l_xml_filler) || '</root>');

   l_expected_logging_message_pattern := '.*' || c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' || '<root>(' || l_xml_filler || '){284}' || substr(l_xml_filler, 1, 6) || '\s*\|\s*';

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);

end truncated_xmltype_parameter;


procedure long_parameter_name as

   l_parameter_name varchar2(200) := 'very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_long_parameter_name';
   l_parameter_value varchar2(100) := 'Small value';
   l_expected_logging_message_pattern console_logs.message%type := '.*' || c_parameters_heading || '\s\| ' || substr(l_parameter_name, 1, 128) || '\s*\| ' || l_parameter_value || '\s*\|\s*';
   l_actual_logging_message console_logs.message%type;

begin

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   select message
   into l_actual_logging_message
   from console_logs;

   ut.expect(l_actual_logging_message).to_match(l_expected_logging_message_pattern);
end long_parameter_name;

end console_test;
/