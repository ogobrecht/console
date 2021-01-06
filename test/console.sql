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
  console.permanent('- test level permanent'                    );
  console.error    ('- test level error'                        );
  console.warn     ('- test level warning'                      );
  console.info     ('- test level info', p_user_agent => 'dummy');
  console.log      ('- test log(level info)'                    );
  console.debug    ('- test level verbose'                      );
end;
/

prompt
timing stop
prompt ================================================================================
prompt Test Console Done :-)
prompt
