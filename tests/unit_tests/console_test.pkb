create or replace package body console_test as

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
         user || '.CONSOLE_TEST.BASIC_LOGGING_DEBUG, line 24' as scope,
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
         user || '.CONSOLE_TEST.BASIC_LOGGING_INFO, line 57' as scope,
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
         user || '.CONSOLE_TEST.BASIC_LOGGING_WARNING, line 89' as scope,
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
         user || '.CONSOLE_TEST.BASIC_LOGGING_ERROR, line 121' as scope,
         l_log_message || chr(10) || chr(10) as message,
         to_number(null) as error_code,
         'console_test' as action,
         'basic_logging_error' as client_info,
         l_client_identifier as client_identifier
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).exclude('LOG_ID,LOG_TIME,SESSION_USER,MODULE,IP_ADDRESS,HOST,OS_USER,OS_USER_AGENT,CALL_STACK');

end basic_logging_error;


procedure dont_log_debug as
   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin
   console.conf(p_level => console.c_level_info);
   console_test_helpers.log_all_levels();

   l_actual_logs := fetch_logs();

   open l_expected_logs for
      select console.level_info() as level_id
      from dual

      union

      select console.level_warning() as level_id
      from dual

      union

      select console.level_error() as level_id
      from dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).include('LEVEL_ID').unordered();

end dont_log_debug;


procedure dont_log_info as
   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin
   console.conf(p_level => console.c_level_warning);
   console_test_helpers.log_all_levels();

   l_actual_logs := fetch_logs();

   open l_expected_logs for
      select console.level_warning() as level_id
      from dual

      union

      select console.level_error() as level_id
      from dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).include('LEVEL_ID').unordered();

end dont_log_info;


procedure dont_log_warning as
   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin
   console.conf(p_level => console.c_level_error);
   console_test_helpers.log_all_levels();

   l_actual_logs := fetch_logs();

   open l_expected_logs for
      select console.level_error() as level_id
      from dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).include('LEVEL_ID').unordered();

end dont_log_warning;


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

end console_test;
/