set define off

@@unit_tests/console_test_helpers.pks
@@unit_tests/console_test_helpers.pkb
@@unit_tests/console_test.pks
@@unit_tests/console_test.pkb
@@unit_tests/console_parameter_test.pks
@@unit_tests/console_parameter_test.pkb
@@unit_tests/console_config_test.pks
@@unit_tests/console_config_test.pkb
@@unit_tests/console_utils_test.pks
@@unit_tests/console_utils_test.pkb
@@unit_tests/console_timers_counters_test.pks
@@unit_tests/console_timers_counters_test.pkb
@@unit_tests/console_purge_test.pks
@@unit_tests/console_purge_test.pkb

set serverout on

exec ut.run(a_color_console=>true);