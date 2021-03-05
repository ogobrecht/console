prompt ORACLE INSTRUMENTATION CONSOLE: INSTALL APEX PLUG-IN
prompt - application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_200200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2020.10.01'
,p_release=>'20.2.0.00.20'
,p_default_workspace_id=>100000
,p_default_application_id=>100
,p_default_id_offset=>34698863762663877
,p_default_owner=>'PLAYGROUND_DATA'
);
end;
/

prompt - application 100 - Playground
--
-- Application Export:
--   Application:     100
--   Name:            Playground
--   Date and Time:   20:16 Monday March 1, 2021
--   Exported By:     OGOBRECHT
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 36295154520053378
--   Manifest End
--   Version:         20.2.0.00.20
--   Instance ID:     9947149746035591
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt - application/shared_components/plugins/dynamic_action/com_ogobrecht_console
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(36295154520053378)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.OGOBRECHT.CONSOLE'
,p_display_name=>'Oracle Instrumentation Console'
,p_category=>'NOTIFICATION'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_api_version=>2
,p_render_function=>'console.apex_plugin_render'
,p_ajax_function=>'console.apex_plugin_ajax'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'#VERSION#'
,p_about_url=>'https://github.com/ogobrecht/console'
,p_files_version=>7
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
#CONSOLE.JS#
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(36299187405943315)
,p_plugin_id=>wwv_flow_api.id(36295154520053378)
,p_file_name=>'console.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt - application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt - finished
