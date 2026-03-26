create or replace package body console_timers_counters_test as

c_sleep_seconds     constant number := 0.1;
c_timer_tolerance   constant number := 0.2;

procedure count_increments_counter as
   l_result number;
begin
   console.count('test_counter');
   l_result := console.count_current('test_counter');

   ut.expect(l_result).to_equal(1);
   console.count_end('test_counter');
end count_increments_counter;


procedure count_initializes_to_null as
   l_result number;
begin
   l_result := console.count_current('new_counter');

   ut.expect(l_result).to_be_null();
   console.count_end('new_counter');
end count_initializes_to_null;


procedure count_multiple_increments as
   l_result number;
begin
   console.count('multi_counter');
   console.count('multi_counter');
   console.count('multi_counter');
   l_result := console.count_current('multi_counter');

   ut.expect(l_result).to_equal(3);
   console.count_end('multi_counter');
end count_multiple_increments;


procedure count_reset_sets_to_zero as
   l_result number;
begin
   console.count('reset_counter');
   console.count('reset_counter');
   console.count_reset('reset_counter');
   l_result := console.count_current('reset_counter');

   ut.expect(l_result).to_equal(0);
   console.count_end('reset_counter');
end count_reset_sets_to_zero;


procedure count_current_returns_value as
   l_log_count number;
begin
   console.count('current_counter');
   console.count('current_counter');

   console.count_current('current_counter');

   select count(*) into l_log_count
     from console_logs
    where message like '%current_counter%2%';

   ut.expect(l_log_count).to_equal(1);
   console.count_end('current_counter');
end count_current_returns_value;


procedure count_end_logs_and_deletes as
   l_result number;
   l_log_count number;
begin
   console.count('end_counter');
   console.count('end_counter');

   console.count_end('end_counter');
   l_result := console.count_current('end_counter');

   select count(*) into l_log_count
     from console_logs
    where message like '%end_counter%2%';

   ut.expect(l_result).to_be_null;
   ut.expect(l_log_count).to_equal(1);
end count_end_logs_and_deletes;


procedure count_end_function_returns_and_deletes as
   l_result number;
   l_check number;
begin
   console.count('func_end_counter');
   console.count('func_end_counter');
   console.count('func_end_counter');

   l_result := console.count_end('func_end_counter');

   ut.expect(l_result).to_equal(3);
   l_check := console.count_current('func_end_counter');
   ut.expect(l_check).to_be_null;
end count_end_function_returns_and_deletes;


procedure count_current_warns_if_not_exists as
   l_log_count number;
begin
   console.count_current('nonexistent_counter', 'test message');

   select count(*) into l_log_count
     from console_logs
    where message like '%nonexistent_counter%does not exist%';

   ut.expect(l_log_count).to_be_greater_than(0);
end count_current_warns_if_not_exists;


procedure count_end_warns_if_not_exists as
   l_log_count number;
begin
   console.count_end('nonexistent_counter_2', 'test message');

   select count(*) into l_log_count
     from console_logs
    where message like '%nonexistent_counter_2%does not exist%';

   ut.expect(l_log_count).to_be_greater_than(0);
end count_end_warns_if_not_exists;


procedure count_with_null_label as
   l_result number;
begin
   console.count(null);
   console.count(null);

   l_result := console.count_current(null);

   ut.expect(l_result).to_equal(2);
   console.count_end(null);
end count_with_null_label;


procedure count_end_with_message as
   l_log_count number;
begin
   console.count('msg_counter');
   console.count('msg_counter');

   console.count_end('msg_counter', 'Processing complete');

   select count(*) into l_log_count
     from console_logs
    where message like '%Processing complete%';

   ut.expect(l_log_count).to_be_greater_than(0);
end count_end_with_message;


procedure count_reset_creates_if_not_exists as
   l_result number;
begin
   console.count_reset('brand_new_counter');
   l_result := console.count_current('brand_new_counter');

   ut.expect(l_result).to_equal(0);
   console.count_end('brand_new_counter');
end count_reset_creates_if_not_exists;


procedure count_reset_with_null_label as
   l_result number;
begin
   console.count(null);
   console.count(null);
   console.count_reset(null);
   l_result := console.count_current(null);

   ut.expect(l_result).to_equal(0);
   console.count_end(null);
end count_reset_with_null_label;


procedure count_end_func_returns_null_if_not_exists as
   l_result    number;
   l_log_count number;
begin
   l_result := console.count_end('never_created_counter');

   select count(*) into l_log_count
     from console_logs
    where message like '%never_created_counter%does not exist%';

   ut.expect(l_result).to_be_null;
   ut.expect(l_log_count).to_equal(0);
end count_end_func_returns_null_if_not_exists;


procedure time_sets_timer as
   l_elapsed varchar2(100);
   l_elapsed_seconds number;
begin
   console.time('timer1');
   sys.dbms_session.sleep(c_sleep_seconds);
   l_elapsed := console.time_current('timer1');
   l_elapsed_seconds := console_test_helpers.time_string_to_seconds(l_elapsed);

   -- Format: hh24:mi:ss.ff6 (e.g., 00:00:01.123456)
   ut.expect(l_elapsed).to_match(console_test_helpers.c_time_format);
   ut.expect(l_elapsed_seconds).to_be_between(c_sleep_seconds, c_sleep_seconds + c_timer_tolerance);
   console.time_end('timer1');
end time_sets_timer;


procedure time_reset_restarts_timer as
   l_elapsed_1 varchar2(100);
   l_elapsed_2 varchar2(100);
   l_elapsed_1_seconds number;
   l_elapsed_2_seconds number;
begin
   console.time('reset_timer');
   sys.dbms_session.sleep(c_sleep_seconds);
   l_elapsed_1 := console.time_current('reset_timer');
   l_elapsed_1_seconds := console_test_helpers.time_string_to_seconds(l_elapsed_1);

   console.time_reset('reset_timer');
   sys.dbms_session.sleep(c_sleep_seconds / 2);
   l_elapsed_2 := console.time_current('reset_timer');
   l_elapsed_2_seconds := console_test_helpers.time_string_to_seconds(l_elapsed_2);

   -- Both should match format hh24:mi:ss.ff6
   ut.expect(l_elapsed_1).to_match(console_test_helpers.c_time_format);
   ut.expect(l_elapsed_2).to_match(console_test_helpers.c_time_format);
   ut.expect(l_elapsed_1_seconds).to_be_between(c_sleep_seconds, c_sleep_seconds + c_timer_tolerance);
   ut.expect(l_elapsed_2_seconds).to_be_between(c_sleep_seconds / 2, c_sleep_seconds / 2 + c_timer_tolerance);
   console.time_end('reset_timer');
end time_reset_restarts_timer;


procedure time_current_returns_elapsed as
   l_elapsed varchar2(100);
   l_elapsed_seconds number;
begin
   console.time('current_timer');
   sys.dbms_session.sleep(c_sleep_seconds);

   console.time_current('current_timer', 'Check elapsed');
   l_elapsed := console.time_current('current_timer');
   l_elapsed_seconds := console_test_helpers.time_string_to_seconds(l_elapsed);

   ut.expect(l_elapsed).to_match(console_test_helpers.c_time_format);
   ut.expect(l_elapsed_seconds).to_be_between(c_sleep_seconds, c_sleep_seconds + c_timer_tolerance);
   console.time_end('current_timer');
end time_current_returns_elapsed;


procedure time_current_called_multiple_times as
   l_elapsed_1 varchar2(100);
   l_elapsed_2 varchar2(100);
   l_elapsed_1_seconds number;
   l_elapsed_2_seconds number;
begin
   console.time('multi_call_timer');

   l_elapsed_1 := console.time_current('multi_call_timer');
   l_elapsed_1_seconds := console_test_helpers.time_string_to_seconds(l_elapsed_1);
   sys.dbms_session.sleep(c_sleep_seconds);
   l_elapsed_2 := console.time_current('multi_call_timer');
   l_elapsed_2_seconds := console_test_helpers.time_string_to_seconds(l_elapsed_2);

   -- Both should return the correct format
   ut.expect(l_elapsed_1).to_match(console_test_helpers.c_time_format);
   ut.expect(l_elapsed_2).to_match(console_test_helpers.c_time_format);
   ut.expect(l_elapsed_2_seconds - l_elapsed_1_seconds).to_be_between(c_sleep_seconds, c_sleep_seconds + c_timer_tolerance);
   -- Timer should still exist after multiple calls
   ut.expect(console.time_current('multi_call_timer')).to_match(console_test_helpers.c_time_format);
   console.time_end('multi_call_timer');
end time_current_called_multiple_times;


procedure time_end_logs_and_deletes as
   l_elapsed   varchar2(100);
   l_log_count number;
begin
   console.time('end_timer');

   console.time_end('end_timer', 'Processing ended');
   l_elapsed := console.time_current('end_timer');

   select count(*) into l_log_count
     from console_logs
    where message like '%end_timer%Processing ended%';

   ut.expect(l_elapsed).to_be_null;
   ut.expect(l_log_count).to_equal(1);
end time_end_logs_and_deletes;


procedure time_end_function_returns_and_deletes as
   l_elapsed varchar2(100);
   l_elapsed_seconds number;
   l_check varchar2(100);
begin
   console.time('func_end_timer');
   sys.dbms_session.sleep(c_sleep_seconds);

   l_elapsed := console.time_end('func_end_timer');
   l_elapsed_seconds := console_test_helpers.time_string_to_seconds(l_elapsed);

   -- Should return time format
   ut.expect(l_elapsed).to_match(console_test_helpers.c_time_format);
   ut.expect(l_elapsed_seconds).to_be_between(c_sleep_seconds, c_sleep_seconds + c_timer_tolerance);
   l_check := console.time_current('func_end_timer');
   ut.expect(l_check).to_be_null;
end time_end_function_returns_and_deletes;


procedure time_current_warns_if_not_exists as
   l_log_count number;
begin
   console.time_current('nonexistent_timer', 'test');

   select count(*) into l_log_count
     from console_logs
    where message like '%nonexistent_timer%does not exist%';

   ut.expect(l_log_count).to_be_greater_than(0);
end time_current_warns_if_not_exists;


procedure time_end_warns_if_not_exists as
   l_log_count number;
begin
   console.time_end('nonexistent_timer_2', 'test');

   select count(*) into l_log_count
     from console_logs
    where message like '%nonexistent_timer_2%does not exist%';

   ut.expect(l_log_count).to_be_greater_than(0);
end time_end_warns_if_not_exists;


procedure time_with_null_label as
   l_elapsed varchar2(100);
begin
   console.time(null);
   l_elapsed := console.time_current(null);

   ut.expect(l_elapsed).to_match(console_test_helpers.c_time_format);
   console.time_end(null);
end time_with_null_label;


procedure time_end_with_message as
   l_log_count number;
begin
   console.time('msg_timer');

   console.time_end('msg_timer', 'Task finished');

   select count(*) into l_log_count
     from console_logs
    where message like '%msg_timer:%Task finished%';

   ut.expect(l_log_count).to_equal(1);
end time_end_with_message;


procedure runtime_returns_formatted_time as
   l_start timestamp;
   l_result varchar2(100);
   l_result_seconds number;
begin
   l_start := localtimestamp - interval '2.5' second;

   l_result := console.runtime(l_start);
   l_result_seconds := console_test_helpers.time_string_to_seconds(l_result);

   -- Format should be hh24:mi:ss.ff6
   ut.expect(l_result).to_match(console_test_helpers.c_time_format);
   ut.expect(l_result_seconds).to_be_between(2.5, 2.6);
end runtime_returns_formatted_time;


procedure runtime_seconds_returns_positive as
   l_start timestamp;
   l_result number;
begin
   l_start := localtimestamp - interval '1.25' second;

   l_result := console.runtime_seconds(l_start);

   ut.expect(l_result).to_be_between(1.25, 1.35);
end runtime_seconds_returns_positive;


procedure runtime_milliseconds_returns_positive as
   l_start timestamp;
   l_result number;
begin
   l_start := localtimestamp - interval '0.75' second;

   l_result := console.runtime_milliseconds(l_start);

   ut.expect(l_result).to_be_between(750, 800);
end runtime_milliseconds_returns_positive;


procedure runtime_milliseconds_equals_seconds_times_1000 as
   l_start timestamp;
   l_seconds number;
   l_milliseconds number;
begin
   l_start := localtimestamp - interval '1.5' second;

   l_seconds := console.runtime_seconds(l_start);
   l_milliseconds := console.runtime_milliseconds(l_start);

   -- Milliseconds should be approximately seconds * 1000
   ut.expect(l_milliseconds).to_be_between(l_seconds * 1000, l_seconds * 1000 + 50);
end runtime_milliseconds_equals_seconds_times_1000;


procedure runtime_null_returns_null as
   l_formatted    varchar2(100);
   l_seconds      number;
   l_milliseconds number;
begin
   l_formatted    := console.runtime(null);
   l_seconds      := console.runtime_seconds(null);
   l_milliseconds := console.runtime_milliseconds(null);

   ut.expect(l_formatted).to_be_null;
   ut.expect(l_seconds).to_be_null;
   ut.expect(l_milliseconds).to_be_null;
end runtime_null_returns_null;

end console_timers_counters_test;
/
