set define off
alter session set plsql_ccflags = 'apex_installed:false, utils_public:true';
prompt - Compile package console (spec)
@sources/CONSOLE.pks
prompt - Compile package console (body)
@sources/CONSOLE.pkb

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