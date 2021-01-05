set define off feedback off
whenever sqlerror exit sql.sqlcode rollback

prompt
prompt Uninstalling Oracle Instrumentation Console
prompt ============================================================
prompt Drop package console if exists (body)
BEGIN
  FOR i IN (SELECT object_type,
                   object_name
              FROM user_objects
             WHERE object_type = 'PACKAGE BODY'
               AND object_name = 'CONSOLE') 
  LOOP
    EXECUTE IMMEDIATE 'drop ' || i.object_type || ' ' || i.object_name;
  END LOOP;
END;
/
prompt Drop package console if exists (spec)
BEGIN
  FOR i IN (SELECT object_type,
                   object_name
              FROM user_objects
             WHERE object_type = 'PACKAGE'
               AND object_name = 'CONSOLE') 
  LOOP
    EXECUTE IMMEDIATE 'drop ' || i.object_type || ' ' || i.object_name;
  END LOOP;
END;
/
prompt Drop table console_logs if exists
BEGIN
  FOR i IN (SELECT table_name
              FROM user_tables
             WHERE table_name = 'CONSOLE_LOGS')
  LOOP
    EXECUTE IMMEDIATE 'drop table ' || i.table_name;
  END LOOP;
END;
/
prompt ============================================================
prompt Uninstallation Done
prompt