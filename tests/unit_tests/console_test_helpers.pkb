create or replace package body console_test_helpers as

procedure enable_all_logging as
begin
   console.conf(p_level => 4);
end enable_all_logging;

procedure truncate_console_logs as
begin

   -- execute immediate 'truncate table console_logs';
   delete from console_logs;

end truncate_console_logs;

end console_test_helpers;
/