create or replace package console_config_test as
--%suite(Console config and init)
--%rollback(manual)

--%beforeall(console_test_helpers.enable_all_logging)

--%beforeeach(console.exit_all, console_test_helpers.truncate_console_logs)

--%context(Init)

--%test(Init rejects invalid level)
--%throws(-20777)
procedure init_rejects_invalid_level;

--%test(Init rejects null client identifier)
--%throws(-20777)
procedure init_rejects_null_client_identifier;

--%test(Init rejects duration out of range)
--%throws(-20777)
procedure init_rejects_duration_out_of_range;

--%test(Init rejects check interval out of range)
--%throws(-20777)
procedure init_rejects_check_interval_out_of_range;

--%test(Init rejects null call stack flag)
--%throws(-20777)
procedure init_rejects_null_call_stack_flag;

--%test(Init rejects null user_env flag)
--%throws(-20777)
procedure init_rejects_null_user_env_flag;

--%test(Init rejects null apex_env flag)
--%throws(-20777)
procedure init_rejects_null_apex_env_flag;

--%test(Init rejects null cgi_env flag)
--%throws(-20777)
procedure init_rejects_null_cgi_env_flag;

--%test(Init rejects null console_env flag)
--%throws(-20777)
procedure init_rejects_null_console_env_flag;

--%test(Init accepts maximum client identifier length)
procedure init_accepts_max_client_identifier_length;

--%test(Init rejects client identifier that is too long)
--%throws(-6502)
procedure init_rejects_too_long_client_identifier;

--%test(Init sets session conf for own client)
procedure init_sets_session_conf_for_own_client;

--%test(Init sets prefs for other client)
procedure init_sets_prefs_for_other_client;

--%endcontext

end console_config_test;
/
