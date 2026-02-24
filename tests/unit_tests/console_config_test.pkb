create or replace package body console_config_test as

procedure init_rejects_invalid_level as
begin
   console.init(
      p_client_identifier => 'TEST_INIT_INVALID_LEVEL',
      p_level             => 0);
end init_rejects_invalid_level;


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

   console.exit(l_other_client_id);
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

end console_config_test;
/
