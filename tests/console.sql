set define off
set feedback off
set serveroutput on
whenever sqlerror exit sql.sqlcode rollback

prompt TEST CONSOLE
prompt - Test different levels
begin
  console.init(p_log_level => console.c_level_info);
  --apex_session.attach(100,64,12793951927384);
  console.log('APEX Page 64', p_apex_env => true);
  --apex_session.attach(100,200,12793951927384);
  console.log('APEX Page 200', p_apex_env => true);
  console.init(p_log_level => console.c_level_verbose);
  console.time;
  console.time      ('Test time');
  console.count;
  console.count;
  console.count;
  console.count     ('Test count');
  console.permanent ('permanent');
  console.error     ('error');
  console.warn      ('warn');
  console.info      ('info', p_user_agent => 'dummy');
  console.log       ('log');
  console.debug     ('debug');
  console.trace     ('who is calling us?');
  console.trace     ();
  console.log       (p_cgi_env => true);
  console.log       (p_user_env => true);
  console.log       (p_console_env => true);
  console.log       (p_apex_env => true);
  console.log       (p_apex_env => true, p_cgi_env => true, p_console_env => true, p_user_env => true);
  console.time_end;
  console.log       (console.time_end('Test CONSOLE'));
  console.exit;
  raise_application_error(-20000, 'Test exception');
exception
  when others then
    console.error;
    --> I know, I know, never do that without a final raise...
    --> But we want only test our logging procedure without killing the script run...
end;
/

prompt - FINISHED
