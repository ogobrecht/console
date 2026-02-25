create or replace package console_config_test as
--%suite(Console config and init)
--%rollback(manual)

--%beforeall(console_test_helpers.enable_all_logging)

--%beforeeach(console_test_helpers.clear_client_prefs, console.exit_all, console_test_helpers.truncate_console_logs)

--%context(Init)

--%test(Init rejects invalid level)
--%throws(-20777)
procedure init_rejects_level_too_low;

--%test(Init rejects level too high)
--%throws(-20777)
procedure init_rejects_level_too_high;

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

--%test(Init deduplicates client preferences)
procedure init_deduplicates_client_identifier;

--%test(Init handles multiple clients independently)
procedure init_handles_multiple_clients_independently;

--%test(Init rejects duration below minimum)
--%throws(-20777)
procedure init_rejects_duration_below_min;

--%test(Init rejects check interval below minimum)
--%throws(-20777)
procedure init_rejects_check_interval_below_min;

--%test(Init accepts minimum and maximum duration)
procedure init_accepts_min_and_max_duration;

--%test(Init accepts minimum and maximum check interval)
procedure init_accepts_min_and_max_check_interval;

--%test(Init updates level for existing client)
procedure init_updates_level_for_existing_client;

--%test(Init without client identifier uses own session)
procedure init_without_client_identifier_uses_own_session;

--%test(Init sets correct exit sysdate)
procedure init_sets_correct_exit_sysdate;

--%endcontext

--%context(Client preferences)

--%test(Client prefs clean filters stale entries)
procedure clean_client_prefs_filters_stale_entries;

--%test(Client prefs clean appends new entry)
procedure clean_client_prefs_appends_new_entry;

--%test(Client prefs clean skips null client identifier)
procedure clean_client_prefs_skips_null_client_identifier;

--%test(Client prefs CSV format)
procedure client_prefs_csv_format;

--%endcontext

--%context(Conf - Global Configuration)

--%test(Conf rejects level too low)
--%throws(-20777)
procedure conf_rejects_level_too_low;

--%test(Conf rejects level too high)
--%throws(-20777)
procedure conf_rejects_level_too_high;

--%test(Conf rejects check interval too low)
--%throws(-20777)
procedure conf_rejects_check_interval_too_low;

--%test(Conf rejects check interval too high)
--%throws(-20777)
procedure conf_rejects_check_interval_too_high;

--%test(Conf accepts minimum level)
procedure conf_accepts_min_level;

--%test(Conf accepts maximum level)
procedure conf_accepts_max_level;

--%test(Conf accepts minimum check interval)
procedure conf_accepts_min_check_interval;

--%test(Conf accepts maximum check interval)
procedure conf_accepts_max_check_interval;

--%test(Conf sets default values when none exist)
procedure conf_sets_default_values_when_none_exist;

--%test(Conf partial update preserves other values)
procedure conf_partial_update_preserves_other_values;

--%test(Conf sets conf user correctly)
procedure conf_sets_conf_user_correctly;

--%endcontext

end console_config_test;
/
