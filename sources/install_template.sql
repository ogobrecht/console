set define on
set serveroutput on
set verify off
set feedback off
set linesize 120
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback

prompt ORACLE INSTRUMENTATION CONSOLE: CREATE DATABASE OBJECTS
prompt - Project page https://github.com/ogobrecht/console
@set_ccflags.sql
@CONSOLE_CONSTRAINT_MESSAGES.sql
@CONSOLE_LEVELS.sql
@CONSOLE_SESSIONS.sql
@CONSOLE_LOGS.sql
prompt - Package CONSOLE (spec)
@CONSOLE.pks
prompt - Package CONSOLE (body)
@CONSOLE.pkb
@show_errors.sql
@log_installed_version.sql

