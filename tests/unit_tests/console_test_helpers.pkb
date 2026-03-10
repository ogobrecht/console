create or replace package body console_test_helpers as

function time_string_to_seconds (
   p_time_string in varchar2 )
   return number
is
begin
   return
      to_number(substr(p_time_string, 1, 2)) * 3600 +
      to_number(substr(p_time_string, 4, 2)) * 60 +
      to_number(substr(p_time_string, 7, 2)) +
      to_number(substr(p_time_string, 10, 6)) / 1000000;
end time_string_to_seconds;


procedure enable_all_logging as
begin
   console.conf(p_level => console.c_level_trace);
end enable_all_logging;

procedure truncate_console_logs as
begin

   delete from console_logs;
   commit;

end truncate_console_logs;


procedure clear_client_prefs as
begin
   update console_conf
      set client_prefs = null
    where conf_id = 'CONF';
   commit;
end clear_client_prefs;


procedure log_all_levels as
begin
   console.trace('trace');
   console.debug('debug');
   console.info('info');
   console.warn('warning');
   console.error('error');
end log_all_levels;

end console_test_helpers;
/
