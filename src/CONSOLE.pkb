create or replace package body console is

------------------------------------------------------------------------------------------------------------------------
-- CONSTANTS, TYPES, GLOBALS
------------------------------------------------------------------------------------------------------------------------

c_tab          constant varchar2(1) := chr(9);
c_cr           constant varchar2(1) := chr(13);
c_lf           constant varchar2(1) := chr(10);
c_crlf         constant varchar2(2) := chr(13) || chr(10);
c_at           constant varchar2(1) := '@';
c_hash         constant varchar2(1) := '#';
c_slash        constant varchar2(1) := '/';
c_vc2_max_size constant pls_integer := 32767;

------------------------------------------------------------------------------------------------------------------------
-- UTILITIES (forward declarations, only compiled when not public)
------------------------------------------------------------------------------------------------------------------------

$if not $$utils_public $then



$end


------------------------------------------------------------------------------------------------------------------------
-- UTILITIES
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- MAIN CODE
------------------------------------------------------------------------------------------------------------------------

procedure log_internal (p_level integer, p_message clob) is
  pragma autonomous_transaction;
begin
  dbms_output.put_line(p_message);
  insert into console_logs (log_level, message) values (p_level, p_message);
  commit;
end;

procedure permanent (p_message clob) is
begin
  log_internal (c_level_permanent, p_message);
end;

procedure error (p_message clob) is
begin
  log_internal (c_level_error, p_message);
end;

procedure warn (p_message clob) is
begin
  log_internal (c_level_warn, p_message);
end;

procedure debug (p_message clob) is
begin
  log_internal (c_level_debug, p_message);
end;

procedure log (p_message clob) is
begin
  log_internal (c_level_debug, p_message);
end;

end console;
/
