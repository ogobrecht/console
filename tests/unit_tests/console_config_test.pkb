create or replace package body console_config_test as

procedure init_rejects_level_too_low as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_INVALID_LEVEL',
      p_level             => 0);
end init_rejects_level_too_low;


procedure init_rejects_level_too_high as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_LEVEL_TOO_HIGH',
      p_level             => 6);
end init_rejects_level_too_high;


procedure init_rejects_null_client_identifier as
begin
   console.init(
      p_client_identifier => null,
      p_level             => console.c_level_info);
end init_rejects_null_client_identifier;


procedure init_rejects_duration_out_of_range as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_DURATION_RANGE',
      p_level             => console.c_level_info,
      p_duration          => console.c_duration_max + 1);
end init_rejects_duration_out_of_range;


procedure init_rejects_check_interval_out_of_range as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_CHECK_INTERVAL_RANGE',
      p_level             => console.c_level_info,
      p_check_interval    => console.c_check_interval_max + 1);
end init_rejects_check_interval_out_of_range;


procedure init_rejects_null_call_stack_flag as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_NULL_CALLSTACK',
      p_level             => console.c_level_info,
      p_call_stack        => null,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);
end init_rejects_null_call_stack_flag;


procedure init_rejects_null_user_env_flag as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_NULL_USER_ENV',
      p_level             => console.c_level_info,
      p_call_stack        => true,
      p_user_env          => null,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);
end init_rejects_null_user_env_flag;


procedure init_rejects_null_apex_env_flag as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_NULL_APEX_ENV',
      p_level             => console.c_level_info,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => null,
      p_cgi_env           => true,
      p_console_env       => true);
end init_rejects_null_apex_env_flag;


procedure init_rejects_null_cgi_env_flag as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_NULL_CGI_ENV',
      p_level             => console.c_level_info,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => null,
      p_console_env       => true);
end init_rejects_null_cgi_env_flag;


procedure init_rejects_null_console_env_flag as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_NULL_CONSOLE_ENV',
      p_level             => console.c_level_info,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => null);
end init_rejects_null_console_env_flag;


procedure init_sets_session_conf_for_own_client as
   l_my_client_id console.t_64b := console.my_client_identifier;
   l_level        varchar2(100);
   l_check_int    varchar2(100);
   l_call_stack   varchar2(10);
   l_user_env     varchar2(10);
   l_apex_env     varchar2(10);
   l_cgi_env      varchar2(10);
   l_console_env  varchar2(10);
   l_client_id    varchar2(100);
begin
   console.init(
      p_client_identifier => l_my_client_id,
      p_level             => console.c_level_debug,
      p_duration          => 10,
      p_check_interval    => console.c_check_interval_min,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => false,
      p_cgi_env           => false,
      p_console_env       => true);

   select value into l_level
     from table(console.status)
    where attribute = 'g_conf_level';

   select value into l_check_int
     from table(console.status)
    where attribute = 'g_conf_check_interval';

   select value into l_call_stack
     from table(console.status)
    where attribute = 'g_conf_call_stack';

   select value into l_user_env
     from table(console.status)
    where attribute = 'g_conf_user_env';

   select value into l_apex_env
     from table(console.status)
    where attribute = 'g_conf_apex_env';

   select value into l_cgi_env
     from table(console.status)
    where attribute = 'g_conf_cgi_env';

   select value into l_console_env
     from table(console.status)
    where attribute = 'g_conf_console_env';

   select value into l_client_id
     from table(console.status)
    where attribute = 'g_conf_client_identifier';

   ut.expect(l_level).to_equal(to_char(console.c_level_debug));
   ut.expect(l_check_int).to_equal(to_char(console.c_check_interval_min));
   ut.expect(l_call_stack).to_equal('true');
   ut.expect(l_user_env).to_equal('true');
   ut.expect(l_apex_env).to_equal('false');
   ut.expect(l_cgi_env).to_equal('false');
   ut.expect(l_console_env).to_equal('true');
   ut.expect(l_client_id).to_equal(l_my_client_id);
end init_sets_session_conf_for_own_client;


procedure init_sets_prefs_for_other_client as
   l_other_client_id console.t_64b := 'TEST_OTHER_CLIENT';
   l_pref console.t_client_prefs_row;
begin
   console.init(
      p_client_identifier => l_other_client_id,
      p_level             => console.c_level_trace,
      p_duration          => 5,
      p_check_interval    => console.c_check_interval_max,
      p_call_stack        => true,
      p_user_env          => false,
      p_apex_env          => true,
      p_cgi_env           => false,
      p_console_env       => true);

   select *
     into l_pref
     from table(console.client_prefs)
    where client_identifier = l_other_client_id;

   ut.expect(l_pref.level_id).to_equal(console.c_level_trace);
   ut.expect(l_pref.level_name).to_equal('trace');
   ut.expect(l_pref.check_interval).to_equal(console.c_check_interval_max);
   ut.expect(l_pref.call_stack).to_equal('true');
   ut.expect(l_pref.user_env).to_equal('false');
   ut.expect(l_pref.apex_env).to_equal('true');
   ut.expect(l_pref.cgi_env).to_equal('false');
   ut.expect(l_pref.console_env).to_equal('true');
   ut.expect(l_pref.exit_sysdate).to_be_greater_or_equal(sysdate);
end init_sets_prefs_for_other_client;


procedure init_accepts_max_client_identifier_length as
   l_max_client_id varchar2(64) := rpad('M', 64, 'M');
   l_saved_id      varchar2(100);
begin
   console.init(
      p_client_identifier => l_max_client_id,
      p_level             => console.c_level_info,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);

   select client_identifier
     into l_saved_id
     from table(console.client_prefs)
    where client_identifier = l_max_client_id;

   ut.expect(l_saved_id).to_equal(l_max_client_id);
end init_accepts_max_client_identifier_length;


procedure init_rejects_too_long_client_identifier as
begin
   console.init(
      p_client_identifier => rpad('M', 65, 'M'),
      p_level             => console.c_level_info,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);
end init_rejects_too_long_client_identifier;


procedure init_deduplicates_client_identifier as
   l_client_id varchar2(64) := 'TEST_DUPLICATE_CLIENT';
   l_count     number;
begin
   console.init(
      p_client_identifier => l_client_id,
      p_level             => console.c_level_info,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);

   console.init(
      p_client_identifier => l_client_id,
      p_level             => console.c_level_debug,
      p_call_stack        => false,
      p_user_env          => false,
      p_apex_env          => true,
      p_cgi_env           => false,
      p_console_env       => true);

  select count(*) into l_count
    from table(console.client_prefs)
   where client_identifier = l_client_id;

  ut.expect(l_count).to_equal(1);
end init_deduplicates_client_identifier;


procedure init_handles_multiple_clients_independently as
   l_client_a varchar2(64) := 'TEST_MULTI_CLIENT_A';
   l_client_b varchar2(64) := 'TEST_MULTI_CLIENT_B';
   l_pref_a console.t_client_prefs_row;
   l_pref_b console.t_client_prefs_row;
begin
   console.init(
      p_client_identifier => l_client_a,
      p_level             => console.c_level_warning,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);

   console.init(
      p_client_identifier => l_client_b,
      p_level             => console.c_level_trace,
      p_call_stack        => false,
      p_user_env          => false,
      p_apex_env          => false,
      p_cgi_env           => false,
      p_console_env       => false);

   select *
     into l_pref_a
     from table(console.client_prefs)
    where client_identifier = l_client_a;

   select *
     into l_pref_b
     from table(console.client_prefs)
    where client_identifier = l_client_b;

   ut.expect(l_pref_a.level_id).to_equal(console.c_level_warning);
   ut.expect(l_pref_a.call_stack).to_equal('true');

   ut.expect(l_pref_b.level_id).to_equal(console.c_level_trace);
   ut.expect(l_pref_b.call_stack).to_equal('false');

end init_handles_multiple_clients_independently;


procedure init_rejects_duration_below_min as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_DURATION_MIN',
      p_level             => console.c_level_info,
      p_duration          => console.c_duration_min - 1);
end init_rejects_duration_below_min;


procedure init_rejects_check_interval_below_min as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_CHECK_INTERVAL_MIN',
      p_level             => console.c_level_info,
      p_check_interval    => console.c_check_interval_min - 1);
end init_rejects_check_interval_below_min;


procedure init_accepts_min_and_max_duration as
   l_client_min varchar2(64) := 'TEST_INIT_DURATION_MIN_OK';
   l_client_max varchar2(64) := 'TEST_INIT_DURATION_MAX_OK';
   l_count      number;
begin
   console.init(
      p_client_identifier => l_client_min,
      p_level             => console.c_level_info,
      p_duration          => console.c_duration_min,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);

   console.init(
      p_client_identifier => l_client_max,
      p_level             => console.c_level_info,
      p_duration          => console.c_duration_max,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);

   select count(*) into l_count
     from table(console.client_prefs)
    where client_identifier in (l_client_min, l_client_max);

   ut.expect(l_count).to_equal(2);
end init_accepts_min_and_max_duration;


procedure init_accepts_min_and_max_check_interval as
   l_client_min varchar2(64) := 'TEST_INIT_CKINT_MIN_OK';
   l_client_max varchar2(64) := 'TEST_INIT_CKINT_MAX_OK';
   l_count      number;
begin
   console.init(
      p_client_identifier => l_client_min,
      p_level             => console.c_level_info,
      p_check_interval    => console.c_check_interval_min,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);

   console.init(
      p_client_identifier => l_client_max,
      p_level             => console.c_level_info,
      p_check_interval    => console.c_check_interval_max,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);

   select count(*) into l_count
     from table(console.client_prefs)
    where client_identifier in (l_client_min, l_client_max);

   ut.expect(l_count).to_equal(2);
end init_accepts_min_and_max_check_interval;


procedure init_updates_level_for_existing_client as
   l_client_id varchar2(64) := 'TEST_UPDATE_LEVEL';
   l_pref console.t_client_prefs_row;
begin
   -- Initial init with level info
   console.init(
      p_client_identifier => l_client_id,
      p_level             => console.c_level_info,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);

   -- Update with level debug
   console.init(
      p_client_identifier => l_client_id,
      p_level             => console.c_level_debug,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);

   select *
     into l_pref
     from table(console.client_prefs)
    where client_identifier = l_client_id;

   ut.expect(l_pref.level_id).to_equal(console.c_level_debug);
   ut.expect(l_pref.level_name).to_equal('debug');
end init_updates_level_for_existing_client;


procedure init_without_client_identifier_uses_own_session as
   l_my_client_id console.t_64b := console.my_client_identifier;
   l_level        varchar2(100);
begin
   -- Call overloaded init without p_client_identifier
   console.init(
      p_level             => console.c_level_debug,
      p_duration          => 10,
      p_check_interval    => console.c_check_interval_min,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => false,
      p_cgi_env           => false,
      p_console_env       => true);

   select value into l_level
     from table(console.status)
    where attribute = 'g_conf_level';

   ut.expect(l_level).to_equal(to_char(console.c_level_debug));
end init_without_client_identifier_uses_own_session;


procedure init_sets_correct_exit_sysdate as
   l_other_client_id console.t_64b := 'TEST_EXIT_DATE';
   l_pref console.t_client_prefs_row;
   l_before timestamp(6);
   l_after timestamp(6);
begin
   l_before := systimestamp;

   console.init(
      p_client_identifier => l_other_client_id,
      p_level             => console.c_level_info,
      p_duration          => 10,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);

   l_after := systimestamp;

   select *
     into l_pref
     from table(console.client_prefs)
    where client_identifier = l_other_client_id;

   -- exit_sysdate should be approximately 10 minutes from now
   -- Check that it's between (now + 9 minutes) and (now + 11 minutes)
   ut.expect(l_pref.exit_sysdate).to_be_between(
      l_before + 9/1440,
      l_after  + 11/1440);
end init_sets_correct_exit_sysdate;


procedure init_cleans_stale_client_prefs as
   l_stale_client constant varchar2(64) := 'STALE_PREF';
   l_fresh_client constant varchar2(64) := 'FRESH_PREF';
   l_stale_csv    varchar2(4000);
   l_stale_count  number;
   l_fresh_count  number;
begin
   l_stale_csv :=
      l_stale_client || ',' ||
      to_char(console.c_level_info) || ',' ||
      '22' || ',' ||
      to_char(console.c_check_interval_default) || ',' ||
      to_char(sysdate - 1, 'yymmddhh24miss') || chr(10);

   update console_conf
      set client_prefs = l_stale_csv
    where conf_id = 'CONF';
   commit;

   console.init(
      p_client_identifier => l_fresh_client,
      p_level             => console.c_level_info,
      p_duration          => 10,
      p_check_interval    => console.c_check_interval_default,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => false,
      p_cgi_env           => false,
      p_console_env       => true);

   select count(*)
     into l_stale_count
     from table(console.client_prefs)
    where client_identifier = l_stale_client;

   select count(*)
     into l_fresh_count
     from table(console.client_prefs)
    where client_identifier = l_fresh_client;

   ut.expect(l_stale_count).to_equal(0);
   ut.expect(l_fresh_count).to_equal(1);
end init_cleans_stale_client_prefs;


procedure conf_rejects_level_too_low as
begin
   console.conf(p_level => 0);
end conf_rejects_level_too_low;


procedure conf_rejects_level_too_high as
begin
   console.conf(p_level => 6);
end conf_rejects_level_too_high;


procedure conf_rejects_check_interval_too_low as
begin
   console.conf(p_check_interval => 9);
end conf_rejects_check_interval_too_low;


procedure conf_rejects_check_interval_too_high as
begin
   console.conf(p_check_interval => 61);
end conf_rejects_check_interval_too_high;


procedure conf_accepts_min_level as
   l_level varchar2(100);
begin
   console.conf(p_level => console.c_level_error);

   select value into l_level
     from table(console.conf)
    where attribute = 'level_id';

   ut.expect(l_level).to_equal(to_char(console.c_level_error));
end conf_accepts_min_level;


procedure conf_accepts_max_level as
   l_level varchar2(100);
begin
   console.conf(p_level => console.c_level_trace);

   select value into l_level
     from table(console.conf)
    where attribute = 'level_id';

   ut.expect(l_level).to_equal(to_char(console.c_level_trace));
end conf_accepts_max_level;


procedure conf_accepts_min_check_interval as
   l_check_int varchar2(100);
begin
   console.conf(p_check_interval => console.c_check_interval_default);

   select value into l_check_int
     from table(console.conf)
    where attribute = 'check_interval';

   ut.expect(l_check_int).to_equal(to_char(console.c_check_interval_default));
end conf_accepts_min_check_interval;


procedure conf_accepts_max_check_interval as
   l_check_int varchar2(100);
begin
   console.conf(p_check_interval => console.c_check_interval_max);

   select value into l_check_int
     from table(console.conf)
    where attribute = 'check_interval';

   ut.expect(l_check_int).to_equal(to_char(console.c_check_interval_max));
end conf_accepts_max_check_interval;


procedure conf_sets_default_values_when_none_exist as
   l_count      number;
   l_level      varchar2(100);
   l_check_int  varchar2(100);
begin
   delete from console_conf;
   commit;
   console.conf();

   -- Verify defaults are set
   select value into l_level
     from table(console.conf)
    where attribute = 'level_id';

   select value into l_check_int
     from table(console.conf)
    where attribute = 'check_interval';

   -- Defaults should be set
   ut.expect(l_level).not_to_be_null;
   ut.expect(l_check_int).not_to_be_null;
   -- Check_interval default is c_check_interval_default (10)
   ut.expect(l_check_int).to_equal(to_char(console.c_check_interval_default));
end conf_sets_default_values_when_none_exist;


procedure conf_partial_update_preserves_other_values as
   l_level      varchar2(100);
   l_check_int  varchar2(100);
begin
   -- Set initial values
   console.conf(
      p_level           => console.c_level_warning,
      p_check_interval  => 15);

   -- Update only level, check_interval should remain
   console.conf(p_level => console.c_level_debug);

   select value into l_level
     from table(console.conf)
    where attribute = 'level_id';

   select value into l_check_int
     from table(console.conf)
    where attribute = 'check_interval';

   ut.expect(l_level).to_equal(to_char(console.c_level_debug));
   ut.expect(l_check_int).to_equal('15');
end conf_partial_update_preserves_other_values;


procedure conf_sets_conf_user_correctly as
   l_conf_user varchar2(100);
   l_session_user varchar2(100);
begin
   console.conf(p_level => console.c_level_info);

   select value into l_conf_user
     from table(console.conf)
    where attribute = 'conf_user';

   -- Verify conf_user is set (should be OS_USER or SESSION_USER)
   ut.expect(l_conf_user).not_to_be_null;
   ut.expect(length(l_conf_user)).to_be_greater_than(0);
end conf_sets_conf_user_correctly;


procedure exit_all_on_empty_client_prefs as
   l_count number;
begin
   select count(*)
     into l_count
     from table(console.client_prefs);

   ut.expect(l_count).to_equal(0);

   console.exit_all();

   select count(*)
     into l_count
     from table(console.client_prefs);

   ut.expect(l_count).to_equal(0);
end exit_all_on_empty_client_prefs;


procedure exit_all_on_multiple_client_prefs as
   l_count number;
begin
   console.init('CLIENT_A', p_level => console.c_level_info, p_call_stack => true, p_user_env => true, p_apex_env => true, p_cgi_env => true, p_console_env => true);
   console.init('CLIENT_B', p_level => console.c_level_debug, p_call_stack => true, p_user_env => true, p_apex_env => true, p_cgi_env => true, p_console_env => true);
   console.init('CLIENT_C', p_level => console.c_level_trace, p_call_stack => true, p_user_env => true, p_apex_env => true, p_cgi_env => true, p_console_env => true);

   select count(*)
     into l_count
     from table(console.client_prefs);

   ut.expect(l_count).to_equal(3);

   console.exit_all();

   select count(*)
     into l_count
     from table(console.client_prefs);

   ut.expect(l_count).to_equal(0);
end exit_all_on_multiple_client_prefs;


procedure exit_on_empty_client_prefs as
   l_count number;
begin
   select count(*)
     into l_count
     from table(console.client_prefs);

   ut.expect(l_count).to_equal(0);

   console.exit('NON_EXISTENT_CLIENT');

   select count(*)
     into l_count
     from table(console.client_prefs);

   ut.expect(l_count).to_equal(0);
end exit_on_empty_client_prefs;


procedure exit_single_client_when_multiple_active as
   l_count number;
   l_exists_a number;
   l_exists_b number;
begin
   console.init('EXIT_TEST_A', p_level => console.c_level_info, p_call_stack => true, p_user_env => true, p_apex_env => true, p_cgi_env => true, p_console_env => true);
   console.init('EXIT_TEST_B', p_level => console.c_level_debug, p_call_stack => true, p_user_env => true, p_apex_env => true, p_cgi_env => true, p_console_env => true);

   select count(*)
     into l_count
     from table(console.client_prefs);

   ut.expect(l_count).to_equal(2);

   console.exit('EXIT_TEST_A');

   select count(*)
     into l_exists_b
     from table(console.client_prefs)
    where client_identifier = 'EXIT_TEST_B';

   ut.expect(l_exists_b).to_equal(1);
end exit_single_client_when_multiple_active;


procedure exit_with_default_parameter as
   l_my_client_id console.t_64b := console.my_client_identifier;
   l_exists number;
begin
   console.init(
      p_client_identifier => l_my_client_id,
      p_level             => console.c_level_debug,
      p_call_stack        => true,
      p_user_env          => true,
      p_apex_env          => true,
      p_cgi_env           => true,
      p_console_env       => true);

   select count(*)
     into l_exists
     from table(console.client_prefs)
    where client_identifier = l_my_client_id;

   ut.expect(l_exists).to_equal(1);

   console.exit();

   select count(*)
     into l_exists
     from table(console.client_prefs)
    where client_identifier = l_my_client_id;

   ut.expect(l_exists).to_equal(0);
end exit_with_default_parameter;


procedure exit_rejects_null_client_identifier as
begin
   console.exit(null);
end exit_rejects_null_client_identifier;

end console_config_test;
/
