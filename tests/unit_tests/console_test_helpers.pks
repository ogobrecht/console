create or replace package console_test_helpers as

c_parameters_heading constant varchar2(100) := '#### Parameters\s*\| Parameter Name\s*\| Value\s*\|\s\| -* \| -* \|';

c_time_format constant varchar2(50) := '\d{2}:\d{2}:\d{2}\.\d{6}';

function time_string_to_seconds (
   p_time_string in varchar2 )
   return number;

procedure enable_all_logging;

procedure truncate_console_logs;

procedure clear_client_prefs;

procedure log_all_levels;

end console_test_helpers;
/
