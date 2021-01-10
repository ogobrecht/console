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
end;
/

prompt
timing stop
prompt ================================================================================
prompt Test Console Finished :-)
prompt

exit
