set define on
set serveroutput on
set verify off
set feedback off
set linesize 120
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback
column logfile noprint new_val logfile
select to_char(sysdate,'yyyymmdd_hh24miss') || '_create_console_objects.log' as logfile from dual;
spool &logfile

prompt
prompt Oracle Instrumentation Console: Create Database Objects
prompt ================================================================================

prompt (1) Set install log to &logfile

prompt (2) Set compiler flags
@set_ccflags.sql

prompt (3) Create or alter table CONSOLE_LOGS
@CONSOLE_LOGS.sql

prompt (4) Create or replace package CONSOLE (spec)
@CONSOLE.pks
show errors

prompt (5) Create or replace package CONSOLE (body)
@CONSOLE.pkb
show errors

prompt ================================================================================
prompt Finished
prompt
