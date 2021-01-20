set define off
set feedback off
set serveroutput on
whenever sqlerror exit sql.sqlcode rollback

--https://blogs.oracle.com/oraclemagazine/sophisticated-call-stack-analysis
--https://oracle-base.com/articles/12c/utl-call-stack-12cr1

prompt TEST TRACE
exec console.init;

prompt - Create test package PKG1
create or replace package pkg1 is
  procedure do_stuff;
end;
/
create or replace package body pkg1 is
  procedure do_stuff is
    procedure sub1 is
      procedure sub2 is
        procedure sub3 is
        begin
          console.trace;
        end;
      begin
        sub3;
      end;
    begin
      sub2;
    end;
  begin
    sub1;
  end;
end;
/
prompt - Call the test package
begin
  pkg1.do_stuff;
end;
/

prompt TEST ERROR
prompt - Create package PKG2 procedure PROC3
create or replace package pkg2 is
  procedure proc1;
  procedure proc2;
end;
/
create or replace package body pkg2 is
  procedure proc1 is
    procedure nested_in_proc1 is
    begin
      raise value_error;
    end;
  begin
    nested_in_proc1;
  end;
  procedure proc2 is
  begin
    proc1;
  exception
    when others then
      raise no_data_found;
  end;
end;
/
create or replace procedure proc3 is
begin
  pkg2.proc2;
end;
/
prompt - Call the test package
begin
  proc3;
exception
  when others then
    console.error;
end;
/

prompt - FINISHED
