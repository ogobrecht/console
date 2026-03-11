create or replace package body console_test as

function fetch_logs return sys_refcursor as
   l_logs sys_refcursor;
begin

   open l_logs for select * from console_logs;

   return l_logs;

end fetch_logs;


procedure verify_log_id_exists(
   p_log_id in console_logs.log_id%type )
as
   l_count number;
begin
   ut.expect(p_log_id).not_to_be_null;

   select count(*)
     into l_count
     from console_logs
    where log_id = p_log_id;

   ut.expect(l_count).to_equal(1);
end verify_log_id_exists;


procedure basic_logging_debug as
   l_log_message clob := 'Just a small test (DEBUG)';
   l_client_identifier varchar2(100) := 'TEST_IDENTIFIER';
   l_log_line number;

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   dbms_session.set_identifier(l_client_identifier);

   l_log_line := $$plsql_line + 1;
   console.debug(l_log_message);
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_debug() as level_id,
         console.level_name(p_level => console.level_debug()) as level_name,
         'N' as permanent,
         user || '.CONSOLE_TEST.BASIC_LOGGING_DEBUG, line ' || to_char(l_log_line) as scope,
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
   l_log_line number;

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   dbms_session.set_identifier(l_client_identifier);

   l_log_line := $$plsql_line + 1;
   console.info(l_log_message);
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_info() as level_id,
         console.level_name(p_level => console.level_info()) as level_name,
         'N' as permanent,
         user || '.CONSOLE_TEST.BASIC_LOGGING_INFO, line ' || to_char(l_log_line) as scope,
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
   l_log_line number;

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   dbms_session.set_identifier(l_client_identifier);

   l_log_line := $$plsql_line + 1;
   console.warn(l_log_message);
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_warning() as level_id,
         console.level_name(p_level => console.level_warning()) as level_name,
         'N' as permanent,
         user || '.CONSOLE_TEST.BASIC_LOGGING_WARNING, line ' || to_char(l_log_line) as scope,
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
   l_log_line number;

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin

   dbms_session.set_identifier(l_client_identifier);

   l_log_line := $$plsql_line + 1;
   console.error(l_log_message);
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_error() as level_id,
         console.level_name(p_level => console.level_error()) as level_name,
         'N' as permanent,
         user || '.CONSOLE_TEST.BASIC_LOGGING_ERROR, line ' || to_char(l_log_line) as scope,
         l_log_message || chr(10) || chr(10) as message,
         to_number(null) as error_code,
         'console_test' as action,
         'basic_logging_error' as client_info,
         l_client_identifier as client_identifier
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).exclude('LOG_ID,LOG_TIME,SESSION_USER,MODULE,IP_ADDRESS,HOST,OS_USER,OS_USER_AGENT,CALL_STACK');

end basic_logging_error;


procedure basic_logging_trace as
   l_log_message clob := 'Just a small test (TRACE)';
   l_client_identifier varchar2(100) := 'TEST_IDENTIFIER_TRACE';
   l_log_line number;
   l_actual_message clob;
   l_actual_call_stack clob;

   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;
begin
   console.conf(p_level => console.c_level_trace);
   dbms_session.set_identifier(l_client_identifier);

   l_log_line := $$plsql_line + 1;
   console.trace(l_log_message);
   l_actual_logs := fetch_logs();
   open l_expected_logs for
      select
         console.level_trace() as level_id,
         console.level_name(p_level => console.level_trace()) as level_name,
         'N' as permanent,
         user || '.CONSOLE_TEST.BASIC_LOGGING_TRACE, line ' || to_char(l_log_line) as scope,
         'console_test' as action,
         'basic_logging_trace' as client_info,
         l_client_identifier as client_identifier
      from
         dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).include('LEVEL_ID,LEVEL_NAME,PERMANENT,SCOPE,ACTION,CLIENT_INFO,CLIENT_IDENTIFIER');

   select message, call_stack
     into l_actual_message, l_actual_call_stack
     from console_logs
    where client_identifier = l_client_identifier
      and level_id = console.level_trace();

   ut.expect(l_actual_message).to_be_like('Just a small test (TRACE)%');
   ut.expect(l_actual_call_stack).to_be_like('#### Call Stack%BASIC_LOGGING_TRACE, line ' || to_char(l_log_line) || '%');
   ut.expect(l_actual_message).to_be_like('%#### CGI Environment%');
   ut.expect(l_actual_message).to_be_like('%#### Console Environment%');
   ut.expect(l_actual_message).to_be_like('%#### User Environment%');
end basic_logging_trace;


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


procedure dont_log_trace as
   l_log_count number;
begin
   console.conf(p_level => console.c_level_debug);
   console.trace('trace should not be logged');

   select count(*)
     into l_log_count
     from console_logs;

   ut.expect(l_log_count).to_equal(0);
end dont_log_trace;


procedure error_always_logged_regardless_of_level as
   l_error_count number;
   l_total_count number;
begin
   for l_level in console.c_level_error .. console.c_level_trace
   loop
      console.conf(p_level => l_level);
      console.error('error-level-' || to_char(l_level));
   end loop;

   select count(*)
     into l_error_count
     from console_logs
    where level_id = console.level_error()
      and message like 'error-level-%';

   select count(*)
     into l_total_count
     from console_logs
    where message like 'error-level-%';

   ut.expect(l_error_count).to_equal(5);
   ut.expect(l_total_count).to_equal(5);
end error_always_logged_regardless_of_level;


procedure log_message_larger_than_4000_is_stored as
   l_log_message   clob;
   l_stored_message clob;
begin
   l_log_message := 'START-' || rpad('X', 4500, 'X') || '-END';

   console.info(l_log_message);

   select message
     into l_stored_message
     from console_logs
    where level_id = console.level_info();

   ut.expect(dbms_lob.getlength(l_stored_message)).to_be_greater_than(4000);
   ut.expect(l_stored_message).to_be_like('START-%');
   ut.expect(l_stored_message).to_be_like('%-END%');
end log_message_larger_than_4000_is_stored;


procedure error_function_returns_log_id as
   l_log_id console_logs.log_id%type;
begin
   l_log_id := console.error('error function test');

   verify_log_id_exists(l_log_id);
end error_function_returns_log_id;


procedure warn_function_returns_log_id as
   l_log_id console_logs.log_id%type;
begin
   l_log_id := console.warn('warn function test');

   verify_log_id_exists(l_log_id);
end warn_function_returns_log_id;


procedure info_function_returns_log_id as
   l_log_id console_logs.log_id%type;
begin
   l_log_id := console.info('info function test');

   verify_log_id_exists(l_log_id);
end info_function_returns_log_id;


procedure log_function_returns_log_id as
   l_log_id console_logs.log_id%type;
begin
   l_log_id := console.log('log function test');

   verify_log_id_exists(l_log_id);
end log_function_returns_log_id;


procedure debug_function_returns_log_id as
   l_log_id console_logs.log_id%type;
begin
   l_log_id := console.debug('debug function test');

   verify_log_id_exists(l_log_id);
end debug_function_returns_log_id;


procedure trace_function_returns_log_id as
   l_log_id console_logs.log_id%type;
begin
   console.conf(p_level => console.c_level_trace);
   l_log_id := console.trace('trace function test');

   verify_log_id_exists(l_log_id);
end trace_function_returns_log_id;


procedure logging_is_autonomous_transaction as
   l_actual_logs sys_refcursor;
   l_expected_logs sys_refcursor;

   l_log_message constant varchar2(20) := 'fk4jq5i943ertfkl5';
begin
   console.log(l_log_message);
   rollback;

   l_actual_logs := fetch_logs();

   open l_expected_logs for
      select console.level_info() as level_id
      from dual;

   ut.expect(l_actual_logs).to_equal(l_expected_logs).include('LEVEL_ID').unordered();

end logging_is_autonomous_transaction;


procedure error_save_stack_captures_error as
   l_call_stack clob;
begin
   begin
      raise_application_error(-20999, 'stack-capture-test');
   exception
      when others then
         console.error_save_stack;
   end;

   console.error('error save stack captures raised error');

   select call_stack
     into l_call_stack
     from console_logs
    where level_id = console.level_error()
      and message like 'error save stack captures raised error%';

   ut.expect(l_call_stack).to_be_like('%#### Saved Error Stack%');
   ut.expect(l_call_stack).to_be_like('%20999%');
end error_save_stack_captures_error;


procedure error_save_stack_multiple_saves as
   l_call_stack clob;
begin
   begin
      raise_application_error(-20998, 'stack-multiple-1');
   exception
      when others then
         console.error_save_stack;
   end;

   begin
      raise_application_error(-20997, 'stack-multiple-2');
   exception
      when others then
         console.error_save_stack;
   end;

   console.error('error save stack keeps multiple saved errors');

   select call_stack
     into l_call_stack
     from console_logs
    where level_id = console.level_error()
      and message like 'error save stack keeps multiple saved errors%';

   ut.expect(l_call_stack).to_be_like('%#### Saved Error Stack%');
   ut.expect(l_call_stack).to_be_like('%20998%');
   ut.expect(l_call_stack).to_be_like('%20997%');
end error_save_stack_multiple_saves;


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