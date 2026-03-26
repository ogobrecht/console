set define on verify off feed off
whenever sqlerror exit failure
whenever oserror exit failure

define SCRIPT=&1
define ARGS=&2

-- The file tests/config.sql is Git ignored.
-- Create an own one with your connection details like so:
-- define CONNECT_STRING="user/pass@//host:port/service"
@tests/config.sql

conn &CONNECT_STRING

set serveroutput on size unlimited format wrapped
exec sys.dbms_java.set_output(2000000)
set lines 2000 trimout on trimspool on tab off appinfo on

@&SCRIPT &ARGS

-- force dbms_output, if last statement was cancelled
exec sys.dbms_output.put_line(null);
exit
