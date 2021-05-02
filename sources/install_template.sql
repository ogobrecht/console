set define on
set serveroutput on
set verify off
set feedback off
set linesize 240
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback

prompt ORACLE INSTRUMENTATION CONSOLE: CREATE DATABASE OBJECTS
prompt - Project page https://github.com/ogobrecht/console
@set_ccflags.sql
@CONSOLE_GLOBAL_CONF.sql
@CONSOLE_LOGS.sql
@CONSOLE_SESSIONS.sql
prompt - Package CONSOLE (spec)
@CONSOLE.pks
prompt - Package CONSOLE (body)
@CONSOLE.pkb
@create_clean_up_job.sql
@show_errors.sql
@log_installed_version.sql

