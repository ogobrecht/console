prompt ORACLE INSTRUMENTATION CONSOLE: INSTALL APEX PLUG-IN
prompt - application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback

--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
  wwv_flow_api.import_begin (
    p_version_yyyy_mm_dd     => '2016.08.24'      ,
    p_release                => '5.1.4.00.08'     ,
    p_default_workspace_id   => 100000            ,
    p_default_application_id => 100               ,
    p_default_id_offset      => 34698863762663877 , --FIXME: was this available in APEX 5.1.4?
    p_default_owner          => 'PLAYGROUND_DATA' );
end;
/

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE'; --FIXME: was this available in APEX 5.1.4?
end;
/

prompt - application/shared_components/plugins/dynamic_action/com_ogobrecht_console
begin
  wwv_flow_api.create_plugin (
    p_id                        => wwv_flow_api.id(36295154520053378)     ,
    p_plugin_type               => 'DYNAMIC ACTION'                       ,
    p_name                      => 'COM.OGOBRECHT.CONSOLE'                ,
    p_display_name              => 'Oracle Instrumentation Console'       ,
    p_category                  => 'COMPONENT'                            , --FIXME: was this available in APEX 5.1.4?
    p_supported_ui_types        => 'DESKTOP:JQM_SMARTPHONE'               ,
    p_api_version               => 2                                      ,
    p_render_function           => 'console.apex_plugin_render'           ,
    p_ajax_function             => 'console.apex_plugin_ajax'             ,
    p_substitute_attributes     => true                                   ,
    p_subscribe_plugin_settings => true                                   ,
    p_version_identifier        => '#CONSOLE_VERSION#'                    ,
    p_about_url                 => 'https://github.com/ogobrecht/console' ,
    p_files_version             => #FILE_VERSION#                         );
end;
/


begin
  wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
#CONSOLE_JS_FILE#end;
/

begin
  wwv_flow_api.create_plugin_file(
    p_id           => wwv_flow_api.id(36299187405943315)                           ,
    p_plugin_id    => wwv_flow_api.id(36295154520053378)                           ,
    p_file_name    => 'console.js'                                                 ,
    p_mime_type    => 'application/javascript'                                     ,
    p_file_charset => 'utf-8'                                                      ,
    p_file_content => wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table) );
end;
/


begin
  wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
#CONSOLE_JS_FILE_MIN#end;
/

begin
  wwv_flow_api.create_plugin_file(
    p_id           => wwv_flow_api.id(37195131994077352)                           ,
    p_plugin_id    => wwv_flow_api.id(36295154520053378)                           ,
    p_file_name    => 'console.min.js'                                             ,
    p_mime_type    => 'application/javascript'                                     ,
    p_file_charset => 'utf-8'                                                      ,
    p_file_content => wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table) );
end;
/


begin
  wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
#CONSOLE_JS_FILE_MIN_MAP#end;
/

begin
  wwv_flow_api.create_plugin_file(
    p_id           => wwv_flow_api.id(37195419621077377)                           ,
    p_plugin_id    => wwv_flow_api.id(36295154520053378)                           ,
    p_file_name    => 'console.min.js.map'                                         ,
    p_mime_type    => 'application/octet-stream'                                   ,
    p_file_charset => 'utf-8'                                                      ,
    p_file_content => wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table) );
end;
/


prompt - application/end_environment
begin
  wwv_flow_api.import_end(
    p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false) ,
    p_is_component_import  => true                                                              ); -- do we need this for APEX 5.1.4, or was it the default? Works without in 20.2
commit;
end;
/

set verify on feedback on define on
prompt - FINISHED
