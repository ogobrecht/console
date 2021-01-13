timing start test_console
set define off
set feedback off
set serveroutput on
whenever sqlerror exit sql.sqlcode rollback

prompt
prompt Test Console
prompt ================================================================================

prompt Test different levels:
begin
  console.permanent ('permanent');
  console.error     ('error');
  console.warn      ('warn', p_trace => true);
  console.info      ('info', p_user_agent => 'dummy');
  console.log       ('log');
  console.debug     ('debug');
  console.trace     ();
  raise_application_error(-20000, 'Test exception');
exception
  when others then
    console.error;
    --> I know, I know, never do that without a final raise...
    --> But we want only test our logging procedure without killing the script run...
end;
/

prompt
timing stop
prompt ================================================================================
prompt Test Console Finished :-)
prompt

exit
