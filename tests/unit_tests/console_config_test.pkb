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
      p_level             => 5);
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


procedure clean_client_prefs_filters_stale_entries as
   l_valid console.t_client_prefs_row;
   l_stale console.t_client_prefs_row;
   l_cleaned varchar2(4000);
begin
   l_valid.client_identifier := 'KEEP_PREF';
   l_valid.level_id          := console.c_level_info;
   l_valid.level_name        := 'info';
   l_valid.call_stack        := 'true';
   l_valid.user_env          := 'true';
   l_valid.apex_env          := 'false';
   l_valid.cgi_env           := 'false';
   l_valid.console_env       := 'true';
   l_valid.check_interval    := console.c_check_interval_default;
   l_valid.exit_sysdate      := sysdate + 1;

   l_stale := l_valid;
   l_stale.client_identifier := 'STALE_PREF';
   l_stale.exit_sysdate      := sysdate - 1;

   console.utl_set_client_prefs(
      console.utl_client_prefs_to_csv(l_valid) ||
      console.utl_client_prefs_to_csv(l_stale));

   l_cleaned := console.utl_get_clean_client_prefs_csv;

   ut.expect(l_cleaned).to_be_like('%KEEP_PREF%');
   ut.expect(l_cleaned).not_to_be_like('%STALE_PREF%');
end clean_client_prefs_filters_stale_entries;


procedure clean_client_prefs_appends_new_entry as
   l_old console.t_client_prefs_row;
   l_new console.t_client_prefs_row;
   l_cleaned varchar2(4000);
begin
   l_old.client_identifier := 'OLD_PREF';
   l_old.level_id          := console.c_level_info;
   l_old.level_name        := 'info';
   l_old.call_stack        := 'true';
   l_old.user_env          := 'true';
   l_old.apex_env          := 'false';
   l_old.cgi_env           := 'false';
   l_old.console_env       := 'true';
   l_old.check_interval    := console.c_check_interval_default;
   l_old.exit_sysdate      := sysdate + 1;

   l_new := l_old;
   l_new.client_identifier := 'NEW_PREF';
   l_new.level_id          := console.c_level_debug;
   l_new.level_name        := 'debug';
   l_new.exit_sysdate      := sysdate + 2;

   console.utl_set_client_prefs(console.utl_client_prefs_to_csv(l_old));

   l_cleaned := console.utl_get_clean_client_prefs_csv(
      p_client_identifier_to_remove => l_old.client_identifier,
      p_client_prefs_to_append      => l_new);

   ut.expect(l_cleaned).to_be_like('%NEW_PREF%');
   ut.expect(l_cleaned).not_to_be_like('%OLD_PREF%');
end clean_client_prefs_appends_new_entry;


procedure client_prefs_csv_format as
   l_pref console.t_client_prefs_row;
   l_csv  varchar2(4000);
   l_expected varchar2(4000);
begin
   l_pref.client_identifier := 'CSV_TEST';
   l_pref.level_id          := console.c_level_info;
   l_pref.level_name        := 'info';
   l_pref.call_stack        := 'true';
   l_pref.user_env          := 'false';
   l_pref.apex_env          := 'true';
   l_pref.cgi_env           := 'true';
   l_pref.console_env       := 'false';
   l_pref.check_interval    := console.c_check_interval_default;
   l_pref.exit_sysdate      := to_date('2025-10-12 15:16:17', 'yyyy-mm-dd hh24:mi:ss');

   l_csv := console.utl_client_prefs_to_csv(l_pref);
   l_expected :=
      'CSV_TEST,' ||
      to_char(console.c_level_info) || ',' ||
      to_char(22) || ',' ||
      to_char(l_pref.check_interval) || ',' ||
      to_char(l_pref.exit_sysdate, 'yymmddhh24miss') || chr(10);

   ut.expect(l_csv).to_equal(l_expected);
end client_prefs_csv_format;


procedure clean_client_prefs_skips_null_client_identifier as
   l_pref console.t_client_prefs_row;
   l_cleaned varchar2(4000);
begin
   l_pref.client_identifier := null;
   l_pref.level_id          := console.c_level_info;
   l_pref.level_name        := 'info';
   l_pref.call_stack        := 'true';
   l_pref.user_env          := 'true';
   l_pref.apex_env          := 'true';
   l_pref.cgi_env           := 'true';
   l_pref.console_env       := 'true';
   l_pref.check_interval    := console.c_check_interval_default;
   l_pref.exit_sysdate      := sysdate + 1;

   l_cleaned := console.utl_get_clean_client_prefs_csv(
      p_client_prefs_to_append => l_pref);

   ut.expect(l_cleaned).to_be_null;
end clean_client_prefs_skips_null_client_identifier;

end console_config_test;
/
