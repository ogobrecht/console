set define off
set feedback off
set serveroutput on
whenever sqlerror exit sql.sqlcode rollback

prompt TEST CONSOLE
prompt - some basic testing, unit tests will follow later...
begin
  console.init(p_level => console.c_level_info);
  --apex_session.attach(100,64,12793951927384);
  console.log('APEX Page 64', p_apex_env => true);
  --apex_session.attach(100,200,12793951927384);
  console.log('APEX Page 200', p_apex_env => true);
  console.init(p_level => console.c_level_trace);
  console.time;
  console.time      ('Test time');
  console.count;
  console.count;
  console.count;
  console.count     ('Test count');
  console.count     ('Test count');
  console.count_log ('Test count');
  console.count_end ('Test count');
  console.error     ('error');
  console.warn      ('warn');
  console.info      ('info');
  console.info      ('info permanent', p_permanent => true);
  console.info      ('info', p_user_agent => 'dummy');
  console.log       ('log', p_user_scope => 'testus');
  console.debug     ('debug');
  console.trace     ('trace');
  console.trace     ();
  console.log       (p_cgi_env => true);
  console.log       (p_user_env => true);
  console.log       (p_console_env => true);
  console.log       (p_apex_env => true);
  console.log       (p_apex_env => true, p_cgi_env => true, p_console_env => true, p_user_env => true);
  console.time_log;
  console.time_end;
  console.log       (console.time_end('Test time'));
  console.exit;
  console.purge_job_run;
  raise_application_error(-20000, 'Test exception');
exception
  when others then
    console.error;
    --> I know, I know, never do that without a final raise...
    --> But we want only test our logging procedure without killing the script run...
end;
/

prompt - FINISHED
