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

prompt Set compiler flags to apex_installed:false, utils_public:false
alter session set plsql_ccflags = 'apex_installed:false, utils_public:false';
prompt Compile package console (spec)
@src/CONSOLE.pks
show errors
prompt Compile package console (body)
@src/CONSOLE.pkb
show errors

prompt

prompt Set compiler flags: apex_installed:true, utils_public:false
alter session set plsql_ccflags = 'apex_installed:true, utils_public:false';
prompt Compile package console (spec)
@src/CONSOLE.pks
show errors
prompt Compile package console (body)
@src/CONSOLE.pkb
show errors

prompt

prompt Set compiler flags to apex_installed:false, utils_public:true
alter session set plsql_ccflags = 'apex_installed:false, utils_public:true';
prompt Compile package console (spec)
@src/CONSOLE.pks
show errors
prompt Compile package console (body)
@src/CONSOLE.pkb
show errors

prompt

prompt Set compiler flags: apex_installed:true, utils_public:true
alter session set plsql_ccflags = 'apex_installed:true, utils_public:true';
prompt Compile package console (spec)
@src/CONSOLE.pks
show errors
prompt Compile package console (body)
@src/CONSOLE.pkb
show errors

prompt

rem Compile with correct flags
@2_install_console.sql

prompt
timing stop
prompt ================================================================================
prompt Test Compiler Flags Done :-)
prompt
