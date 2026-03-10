create or replace package console_timers_counters_test as

--%suite(Console timers and counters)
--%rollback(manual)

--%beforeall(console_test_helpers.enable_all_logging)

--%beforeeach(console_test_helpers.truncate_console_logs)

--%context(Counter Functions)

--%test(Count increments counter)
procedure count_increments_counter;

--%test(Count initializes to null)
procedure count_initializes_to_null;

--%test(Count multiple increments)
procedure count_multiple_increments;

--%test(Count reset sets to zero)
procedure count_reset_sets_to_zero;

--%test(Count current returns value)
procedure count_current_returns_value;

--%test(Count end logs and deletes counter)
procedure count_end_logs_and_deletes;

--%test(Count end function returns and deletes)
procedure count_end_function_returns_and_deletes;

--%test(Count current warns if not exists)
procedure count_current_warns_if_not_exists;

--%test(Count end warns if not exists)
procedure count_end_warns_if_not_exists;

--%test(Count with null label)
procedure count_with_null_label;

--%test(Count end with message parameter)
procedure count_end_with_message;

--%test(Count reset creates counter if not exists)
procedure count_reset_creates_if_not_exists;

--%test(Count reset with null label)
procedure count_reset_with_null_label;

--%test(Count end function returns null if not exists)
procedure count_end_func_returns_null_if_not_exists;

--%endcontext

--%context(Timer Functions)

--%test(Time sets timer in correct format)
procedure time_sets_timer;

--%test(Time reset restarts timer)
procedure time_reset_restarts_timer;

--%test(Time current returns elapsed time)
procedure time_current_returns_elapsed;

--%test(Time current can be called multiple times)
procedure time_current_called_multiple_times;

--%test(Time end logs and deletes timer)
procedure time_end_logs_and_deletes;

--%test(Time end function returns and deletes)
procedure time_end_function_returns_and_deletes;

--%test(Time current warns if not exists)
procedure time_current_warns_if_not_exists;

--%test(Time end warns if not exists)
procedure time_end_warns_if_not_exists;

--%test(Time with null label)
procedure time_with_null_label;

--%test(Time end with message parameter)
procedure time_end_with_message;

--%endcontext

--%context(Runtime Functions)

--%test(Runtime returns formatted timestamp hh24:mi:ss.ff6)
procedure runtime_returns_formatted_time;

--%test(Runtime seconds returns positive number)
procedure runtime_seconds_returns_positive;

--%test(Runtime milliseconds returns positive number)
procedure runtime_milliseconds_returns_positive;

--%test(Runtime milliseconds equals seconds times 1000)
procedure runtime_milliseconds_equals_seconds_times_1000;

--%test(Runtime functions return null for null input)
procedure runtime_null_returns_null;

--%endcontext

end console_timers_counters_test;
/
