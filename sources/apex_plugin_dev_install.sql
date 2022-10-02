prompt ORACLE INSTRUMENTATION CONSOLE: PREPARE APEX PLUG-IN INSTALLATION
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback

prompt - set app ID, workspace ID and schema for app with alias PLAYGROUND
declare
  v_app_found boolean := false;
begin
  for i in (
    select application_id,
           workspace_id,
           owner
      from apex_applications
     where alias = 'PLAYGROUND' )
  loop
    v_app_found := true;
    apex_application_install.set_application_id ( p_application_id => i.application_id );
    apex_application_install.set_workspace_id   ( p_workspace_id   => i.workspace_id   );
    apex_application_install.set_schema         ( p_schema         => i.owner          );
  end loop;
  if not v_app_found then
    raise_application_error(-20999, 'You need to have an application with the alias set to PLAYGROUND.');
  end if;
end;
/

prompt - call the plugin install script
@install/apex_plugin.sql

