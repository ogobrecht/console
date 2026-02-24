create or replace package body console_test_helpers as

procedure enable_all_logging as
begin
   console.conf(p_level => 4);
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
   console.debug('debug');
   console.log('info');
   console.warn('warning');
   console.error('error');
end log_all_levels;

end console_test_helpers;
/
