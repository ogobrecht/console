set define off feedback off
whenever sqlerror exit sql.sqlcode rollback

prompt TEST COMPILER FLAGS

prompt - Show unset compiler flags as errors. This will result in errors like prompt "PLW-06003: unknown inquiry directive '$$UTILS_PUBLIC'".
alter session set plsql_warnings = 'ENABLE:6003';

prompt - SET COMPILER FLAGS TO APEX_INSTALLED:FALSE, UTILS_PUBLIC:FALSE
alter session set plsql_ccflags = 'apex_installed:false, utils_public:false';
prompt - Compile package console (spec)
@sources/CONSOLE.pks
prompt - Compile package console (body)
@sources/CONSOLE.pkb

prompt - SET COMPILER FLAGS: APEX_INSTALLED:TRUE, UTILS_PUBLIC:FALSE
alter session set plsql_ccflags = 'apex_installed:true, utils_public:false';
prompt - Compile package console (spec)
@sources/CONSOLE.pks
prompt - Compile package console (body)
@sources/CONSOLE.pkb

prompt - SET COMPILER FLAGS TO APEX_INSTALLED:FALSE, UTILS_PUBLIC:TRUE
alter session set plsql_ccflags = 'apex_installed:false, utils_public:true';
prompt - Compile package console (spec)
@sources/CONSOLE.pks
prompt - Compile package console (body)
@sources/CONSOLE.pkb

prompt - SET COMPILER FLAGS: APEX_INSTALLED:TRUE, UTILS_PUBLIC:TRUE
alter session set plsql_ccflags = 'apex_installed:true, utils_public:true';
prompt - Compile package console (spec)
@sources/CONSOLE.pks
prompt - Compile package console (body)
@sources/CONSOLE.pkb

prompt - F I N I S H E D -> run install for correct flags
@install/create_console_objects.sql

