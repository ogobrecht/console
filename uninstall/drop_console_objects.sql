set define off feedback off
whenever sqlerror exit sql.sqlcode rollback
-- FIXME: complete script

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
prompt By intention we do not drop the table console_logs because of potential data loss.
prompt ============================================================
prompt Uninstallation Done
prompt