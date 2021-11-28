set define off
set feedback off
set serveroutput on
set linesize 240
whenever sqlerror exit sql.sqlcode rollback

prompt TEST COMPILER FLAGS
alter session set plsql_warnings = 'enable:all,disable:5004,disable:6005,disable:6006,disable:6009,disable:6010,disable:6027,disable:7207';
alter session set plscope_settings = 'identifiers:all';
alter session set plsql_optimize_level = 3;

prompt - SET COMPILER FLAGS TO APEX_INSTALLED:TRUE, UTILS_PUBLIC:TRUE
alter session set plsql_ccflags = 'apex_installed:true, utils_public:true';
prompt - Compile package console (spec)
@sources/CONSOLE.pks
prompt - Compile package console (body)
@sources/CONSOLE.pkb
@tests/ccflags_check_for_error

prompt - SET COMPILER FLAGS TO APEX_INSTALLED:TRUE, UTILS_PUBLIC:FALSE
alter session set plsql_ccflags = 'apex_installed:true, utils_public:false';
prompt - Compile package console (spec)
@sources/CONSOLE.pks
prompt - Compile package console (body)
@sources/CONSOLE.pkb
@tests/ccflags_check_for_error

prompt - SET COMPILER FLAGS TO APEX_INSTALLED:FALSE, UTILS_PUBLIC:TRUE
alter session set plsql_ccflags = 'apex_installed:false, utils_public:true';
prompt - Compile package console (spec)
@sources/CONSOLE.pks
prompt - Compile package console (body)
@sources/CONSOLE.pkb
@tests/ccflags_check_for_error

prompt - SET COMPILER FLAGS TO APEX_INSTALLED:FALSE, UTILS_PUBLIC:FALSE
alter session set plsql_ccflags = 'apex_installed:false, utils_public:false';
prompt - Compile package console (spec)
@sources/CONSOLE.pks
prompt - Compile package console (body)
@sources/CONSOLE.pkb
@tests/ccflags_check_for_error

prompt - F I N I S H E D -> run install for correct flags
@install/create_console_objects.sql

