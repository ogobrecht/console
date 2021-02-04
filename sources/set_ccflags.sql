-- select * from all_plsql_object_settings where name = 'CONSOLE';

prompt - Set compiler flags
declare
  v_apex_installed varchar2(5) := 'FALSE'; -- Do not change (is set dynamically).
  v_utils_public   varchar2(5) := 'FALSE'; -- Make utilities public available (for testing or other usages).
begin

  --Basic settings
  execute immediate 'alter session set plsql_warnings = ''enable:all,disable:5004,disable:6005,disable:6006,disable:6010,disable:6027''';
  execute immediate 'alter session set plscope_settings = ''identifiers:all''';
  execute immediate 'alter session set plsql_optimize_level = 3';

  for i in (select 1
              from all_objects
             where object_type = 'SYNONYM'
               and object_name = 'APEX_EXPORT')
  loop
    v_apex_installed := 'TRUE';
  end loop;

  execute immediate 'alter session set plsql_ccflags = '''
    || 'APEX_INSTALLED:' || v_apex_installed || ','
    || 'UTILS_PUBLIC:'   || v_utils_public   || '''';

end;
/
