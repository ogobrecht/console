timing start test_ccflags
set define off feedback off
whenever sqlerror exit sql.sqlcode rollback

prompt
prompt Test Compiler Flags
prompt ================================================================================

prompt Show unset compiler flags as errors. This will result in errors like
prompt "PLW-06003: unknown inquiry directive '$$UTILS_PUBLIC'".
alter session set plsql_warnings = 'ENABLE:6003';

prompt
prompt (1) SET COMPILER FLAGS TO APEX_INSTALLED:FALSE, UTILS_PUBLIC:FALSE
alter session set plsql_ccflags = 'apex_installed:false, utils_public:false';
prompt Compile package console (spec)
@src/CONSOLE.pks
show errors
prompt Compile package console (body)
@src/CONSOLE.pkb
show errors

prompt

prompt (2) SET COMPILER FLAGS: APEX_INSTALLED:TRUE, UTILS_PUBLIC:FALSE
alter session set plsql_ccflags = 'apex_installed:true, utils_public:false';
prompt Compile package console (spec)
@src/CONSOLE.pks
show errors
prompt Compile package console (body)
@src/CONSOLE.pkb
show errors

prompt

prompt (3) SET COMPILER FLAGS TO APEX_INSTALLED:FALSE, UTILS_PUBLIC:TRUE
alter session set plsql_ccflags = 'apex_installed:false, utils_public:true';
prompt Compile package console (spec)
@src/CONSOLE.pks
show errors
prompt Compile package console (body)
@src/CONSOLE.pkb
show errors

prompt

prompt (4) SET COMPILER FLAGS: APEX_INSTALLED:TRUE, UTILS_PUBLIC:TRUE
alter session set plsql_ccflags = 'apex_installed:true, utils_public:true';
prompt Compile package console (spec)
@src/CONSOLE.pks
show errors
prompt Compile package console (body)
@src/CONSOLE.pkb
show errors

prompt

rem (5) COMPILE WITH CORRECT FLAGS
@install/create_console_objects.sql

prompt
timing stop
prompt ================================================================================
prompt Test Compiler Flags Finished :-)
prompt

exit
