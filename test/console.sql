set define off
set feedback off
set serveroutput on
whenever sqlerror exit sql.sqlcode rollback

prompt TEST CONSOLE
prompt - Test different levels
begin
  console.init(p_level => 4);
  console.permanent ('permanent');
  console.error     ('error');
  console.warn      ('warn');
  console.info      ('info', p_user_agent => 'dummy');
  console.log       ('log');
  console.debug     ('debug');
  console.trace     ('who is calling us?');
  console.trace     ();
  raise_application_error(-20000, 'Test exception');
exception
  when others then
    console.error;
    --> I know, I know, never do that without a final raise...
    --> But we want only test our logging procedure without killing the script run...
end;
/

prompt - FINISHED
