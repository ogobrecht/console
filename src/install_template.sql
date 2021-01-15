set define on
set serveroutput on
set verify off
set feedback off
set linesize 120
set trimout on
set trimspool on
whenever sqlerror exit sql.sqlcode rollback

prompt ORACLE INSTRUMENTATION CONSOLE: CREATE DATABASE OBJECTS

prompt - Set compiler flags
@set_ccflags.sql

prompt - Create or alter table CONSOLE_LOGS
@CONSOLE_LOGS.sql

prompt - Create or replace package CONSOLE (spec)
@CONSOLE.pks

prompt - Create or replace package CONSOLE (body)
@CONSOLE.pkb

prompt - FINISHED
