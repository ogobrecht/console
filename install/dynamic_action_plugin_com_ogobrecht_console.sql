prompt --application/set_environment
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
 
prompt APPLICATION 100 - P-Track
--
-- Application Export:
--   Application:     100
--   Name:            P-Track
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
prompt --application/shared_components/plugins/dynamic_action/com_ogobrecht_console
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
,p_version_identifier=>'0.28.0'
,p_about_url=>'https://github.com/ogobrecht/console'
,p_files_version=>5
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '766172206F7261436F6E736F6C65203D207B7D3B0D0A6F7261436F6E736F6C652E696E6974203D2066756E6374696F6E202829207B0D0A202020202F2F205361766520746865206F726967696E616C206572726F72206D6574686F640D0A202020206F72';
wwv_flow_api.g_varchar2_table(2) := '61436F6E736F6C652E6572726F72203D20636F6E736F6C652E6572726F723B0D0A202020202F2F205265646566696E6520636F6E736F6C652E6572726F72206D6574686F642077697468206120637573746F6D2066756E6374696F6E0D0A20202020636F';
wwv_flow_api.g_varchar2_table(3) := '6E736F6C652E6572726F72203D2066756E6374696F6E20286D65737361676529207B0D0A2020202020202020617065782E7365727665722E706C7567696E280D0A2020202020202020202020206F7261436F6E736F6C652E61706578506C7567696E4964';
wwv_flow_api.g_varchar2_table(4) := '2C0D0A2020202020202020202020207B0D0A202020202020202020202020202020207830313A20274572726F72272C0D0A202020202020202020202020202020207830323A206D6573736167652C0D0A20202020202020202020202020202020705F6465';
wwv_flow_api.g_varchar2_table(5) := '6275673A202476282770646562756727290D0A2020202020202020202020207D2C0D0A2020202020202020202020207B0D0A20202020202020202020202020202020737563636573733A2066756E6374696F6E202864617461537472696E6729207B0D0A';
wwv_flow_api.g_varchar2_table(6) := '20202020202020202020202020202020202020206966202864617461537472696E6720213D2027535543434553532729207B0D0A2020202020202020202020202020202020202020202020206F7261436F6E736F6C652E6572726F7228274F7261636C65';
wwv_flow_api.g_varchar2_table(7) := '20496E737472756D656E746174696F6E20436F6E736F6C653A20414A41582063616C6C2068616420736572766572207369646520504C2F53514C206572726F723A2027202B2064617461537472696E67202B20272E27293B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(8) := '202020202020202020207D0D0A202020202020202020202020202020207D2C0D0A202020202020202020202020202020206572726F723A2066756E6374696F6E20287868722C207374617475732C206572726F725468726F776E29207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(9) := '2020202020202020202020202020206F7261436F6E736F6C652E6572726F7228274F7261636C6520496E737472756D656E746174696F6E20436F6E736F6C653A20414A41582063616C6C207465726D696E617465642077697468206572726F72733A2027';
wwv_flow_api.g_varchar2_table(10) := '202B206572726F725468726F776E202B20272E27293B0D0A202020202020202020202020202020207D2C0D0A2020202020202020202020202020202064617461547970653A202774657874270D0A2020202020202020202020207D0D0A20202020202020';
wwv_flow_api.g_varchar2_table(11) := '20293B0D0A20202020202020202F2F2043616C6C20746865206F726967696E616C20636F6E736F6C652E6C6F672066756E6374696F6E2E0D0A20202020202020206F7261436F6E736F6C652E6572726F722E6170706C7928636F6E736F6C652C20617267';
wwv_flow_api.g_varchar2_table(12) := '756D656E7473293B0D0A202020207D3B0D0A7D3B';
null;
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
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
