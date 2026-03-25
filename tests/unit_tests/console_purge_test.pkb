create or replace package body console_purge_test as

function purge_job_count
   return number
is
   l_count number;
begin
   select count(*) into l_count
     from user_scheduler_jobs
    where job_name = 'CONSOLE_PURGE';

   return l_count;
end purge_job_count;


function purge_job_enabled
   return varchar2
is
   l_enabled user_scheduler_jobs.enabled%type;
begin
   select enabled into l_enabled
     from user_scheduler_jobs
    where job_name = 'CONSOLE_PURGE';

   return upper(l_enabled);
exception
   when no_data_found then
      return null;
end purge_job_enabled;


function purge_job_repeat_interval
   return varchar2
is
   l_repeat_interval user_scheduler_jobs.repeat_interval%type;
begin
   select repeat_interval into l_repeat_interval
     from user_scheduler_jobs
    where job_name = 'CONSOLE_PURGE';

   return upper(l_repeat_interval);
exception
   when no_data_found then
      return null;
end purge_job_repeat_interval;


function purge_job_action
   return varchar2
is
   l_job_action user_scheduler_jobs.job_action%type;
begin
   select job_action into l_job_action
     from user_scheduler_jobs
    where job_name = 'CONSOLE_PURGE';

   return upper(l_job_action);
exception
   when no_data_found then
      return null;
end purge_job_action;


procedure purge_old_logs as
   l_actual_logs_count number;
begin
   console_test_helpers.log_all_levels();
   commit;

   console.purge(
      p_min_level => console.c_level_error,
      p_min_days  => -1 );

   select count(*) into l_actual_logs_count
     from console_logs;

   ut.expect(l_actual_logs_count).to_equal(0);
end purge_old_logs;


procedure keep_permanent_logging as
   l_actual_logs_count number;
begin
   console.log('Test permanent', p_permanent => true);
   commit;

   console.purge(
      p_min_level => console.c_level_error,
      p_min_days  => -1 );

   select count(*) into l_actual_logs_count
     from console_logs;

   ut.expect(l_actual_logs_count).to_equal(1);
end keep_permanent_logging;


procedure purge_deletes_by_level as
   l_remaining_count number;
   l_error_count     number;
begin
   console_test_helpers.log_all_levels();
   commit;

   console.purge(
      p_min_level => console.c_level_warning,
      p_min_days  => -1 );

   select count(*) into l_remaining_count
     from console_logs;

   select count(*) into l_error_count
     from console_logs
    where level_id = console.c_level_error;

   ut.expect(l_remaining_count).to_equal(1);
   ut.expect(l_error_count).to_equal(1);
end purge_deletes_by_level;


procedure purge_respects_min_days as
   l_recent_count number;
begin
   console.log('recent-log');
   commit;

   console.purge(
      p_min_level => console.c_level_error,
      p_min_days  => 1 );

   select count(*) into l_recent_count
     from console_logs
    where message like '%recent-log%';

   ut.expect(l_recent_count).to_equal(1);
end purge_respects_min_days;


procedure purge_all_deletes_everything as
   l_actual_logs_count number;
begin
   console_test_helpers.log_all_levels();
   commit;

   console.purge_all;

   select count(*) into l_actual_logs_count
     from console_logs;

   ut.expect(l_actual_logs_count).to_equal(0);
end purge_all_deletes_everything;


procedure purge_all_keeps_permanent as
   l_total_count     number;
   l_permanent_count number;
begin
   console.log('normal entry');
   console.log('permanent entry', p_permanent => true);
   commit;

   console.purge_all;

   select count(*) into l_total_count
     from console_logs;

   select count(*) into l_permanent_count
     from console_logs
    where permanent = 'Y';

   ut.expect(l_total_count).to_equal(1);
   ut.expect(l_permanent_count).to_equal(1);
end purge_all_keeps_permanent;


procedure purge_rejects_level_too_high as
begin
   console.purge(
      p_min_level => 99,
      p_min_days  => -1 );
end purge_rejects_level_too_high;


procedure purge_rejects_level_too_low as
begin
   console.purge(
      p_min_level => 0,
      p_min_days  => -1 );
end purge_rejects_level_too_low;


procedure purge_accepts_level_error as
   l_count number;
begin
   console.error('boundary-test');
   commit;

   console.purge(
      p_min_level => console.c_level_error,
      p_min_days  => -1 );

   select count(*) into l_count
     from console_logs;

   ut.expect(l_count).to_equal(0);
end purge_accepts_level_error;


procedure purge_accepts_level_trace as
   l_count number;
begin
   console.conf(p_level => 5);
   console.trace('boundary-test');
   commit;

   console.purge(
      p_min_level => console.c_level_trace,
      p_min_days  => -1 );

   select count(*) into l_count
     from console_logs
    where message like '%boundary-test%';

   ut.expect(l_count).to_equal(0);
end purge_accepts_level_trace;


procedure purge_job_create_creates_job as
begin
   console.purge_job_create;

   ut.expect(purge_job_count).to_equal(1);
   ut.expect(purge_job_enabled).to_equal('TRUE');
end purge_job_create_creates_job;


procedure purge_job_create_skips_if_exists as
begin
   console.purge_job_create;
   console.purge_job_create;

   ut.expect(purge_job_count).to_equal(1);
end purge_job_create_skips_if_exists;


procedure purge_job_create_with_custom_parameters as
   l_repeat_interval varchar2(4000);
   l_job_action      varchar2(4000);
begin
   console.purge_job_create(
      p_repeat_interval => 'FREQ=HOURLY;',
      p_min_level       => 2,
      p_min_days        => 7 );

   l_repeat_interval := purge_job_repeat_interval;
   l_job_action := purge_job_action;

   ut.expect(l_repeat_interval).to_be_like('%FREQ=HOURLY%');
   ut.expect(l_job_action).to_be_like('%P_MIN_LEVEL=>2%');
   ut.expect(l_job_action).to_be_like('%P_MIN_DAYS=>7%');
end purge_job_create_with_custom_parameters;


procedure purge_job_disable_disables_job as
begin
   console.purge_job_create;
   console.purge_job_disable;

   ut.expect(purge_job_enabled).to_equal('FALSE');
end purge_job_disable_disables_job;


procedure purge_job_enable_enables_job as
begin
   console.purge_job_create;
   console.purge_job_disable;
   console.purge_job_enable;

   ut.expect(purge_job_enabled).to_equal('TRUE');
end purge_job_enable_enables_job;


procedure purge_job_drop_removes_job as
begin
   console.purge_job_create;
   console.purge_job_drop;

   ut.expect(purge_job_count).to_equal(0);
end purge_job_drop_removes_job;


procedure purge_job_run_executes_job as
   l_logs_before number;
   l_logs_after  number;
begin
   console.purge_job_create(
      p_repeat_interval => 'FREQ=YEARLY;BYMONTH=12;BYMONTHDAY=31;BYHOUR=23;BYMINUTE=59;BYSECOND=59;',
      p_min_level       => 1,
      p_min_days        => -1 );

   console_test_helpers.log_all_levels();
   commit;

   select count(*) into l_logs_before
     from console_logs;

   console.purge_job_run;

   select count(*) into l_logs_after
     from console_logs;

   ut.expect(l_logs_before).to_be_greater_than(0);
   ut.expect(l_logs_after).to_equal(0);
end purge_job_run_executes_job;


procedure purge_job_drop_without_existing_job as
begin
   console.purge_job_drop;

   ut.expect(purge_job_count).to_equal(0);
end purge_job_drop_without_existing_job;


procedure purge_job_enable_without_existing_job as
begin
   console.purge_job_enable;

   ut.expect(purge_job_count).to_equal(0);
end purge_job_enable_without_existing_job;


procedure purge_job_disable_without_existing_job as
begin
   console.purge_job_disable;

   ut.expect(purge_job_count).to_equal(0);
end purge_job_disable_without_existing_job;


procedure purge_job_run_without_existing_job as
begin
   console.purge_job_run;

   ut.expect(purge_job_count).to_equal(0);
end purge_job_run_without_existing_job;

end console_purge_test;
/
