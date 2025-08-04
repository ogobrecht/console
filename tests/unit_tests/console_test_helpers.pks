create or replace package console_test_helpers as

c_parameters_heading constant varchar2(100) := '#### Parameters\s*\| Parameter Name\s*\| Value\s*\|\s\| -* \| -* \|';

procedure enable_all_logging;

procedure truncate_console_logs;

procedure log_all_levels;

end console_test_helpers;
/
