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
  console.permanent('- test level permanent' );
  console.error    ('- test level error'     );
  console.warn     ('- test level warn'      );
  console.debug    ('- test level debug'     );
  console.log      ('- test log(level debug)');
end;
/

prompt
timing stop
prompt ================================================================================
prompt Test Console Done :-)
prompt
