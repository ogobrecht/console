create or replace package body console is

--------------------------------------------------------------------------------
-- CONSTANTS, TYPES, GLOBALS
--------------------------------------------------------------------------------

c_tab          constant varchar2(1) := chr(9);
c_cr           constant varchar2(1) := chr(13);
c_lf           constant varchar2(1) := chr(10);
c_crlf         constant varchar2(2) := chr(13) || chr(10);
c_at           constant varchar2(1) := '@';
c_hash         constant varchar2(1) := '#';
c_slash        constant varchar2(1) := '/';
c_vc2_max_size constant pls_integer := 32767;

--------------------------------------------------------------------------------
-- UTILITIES (forward declarations, only compiled when not public)
--------------------------------------------------------------------------------

$if not $$utils_public $then



$end


--------------------------------------------------------------------------------
-- UTILITIES
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- MAIN CODE
--------------------------------------------------------------------------------

function logging_enabled return boolean
is
begin
  return true; --FIXME: implement
end logging_enabled;

--------------------------------------------------------------------------------

function call_stack return varchar2
is
begin
  return 'dummy'; --FIXME: implement
end call_stack;

--------------------------------------------------------------------------------

procedure log_internal (
  p_level      integer,
  p_message    clob,
  p_trace      boolean,
  p_user_agent varchar2)
is
  pragma autonomous_transaction;
  v_call_stack varchar2(1000 char);
begin
  if p_level <= c_level_error or logging_enabled then
    if p_trace then
      v_call_stack := substr(call_stack, 1, 1000);
    end if;
    dbms_output.put_line(p_message);
    insert into console_logs (
      log_level,
      message,
      call_stack,
      module,
      action,
      client_info,
      session_user,
      unique_session_id,
      client_identifier,
      ip_address,
      host,
      os_user,
      os_user_agent,
      instance,
      instance_name,
      service_name,
      sid,
      sessionid)
    values (
      p_level,
      p_message,
      v_call_stack,
      sys_context('USERENV', 'MODULE'),
      sys_context('USERENV', 'ACTION'),
      sys_context('USERENV', 'CLIENT_INFO'),
      sys_context('USERENV', 'SESSION_USER'),
      dbms_session.unique_session_id,
      sys_context('USERENV', 'CLIENT_IDENTIFIER'),
      sys_context('USERENV', 'IP_ADDRESS'),
      sys_context('USERENV', 'HOST'),
      sys_context('USERENV', 'OS_USER'),
      substr(p_user_agent, 1, 200),
      sys_context('USERENV', 'INSTANCE'),
      sys_context('USERENV', 'INSTANCE_NAME'),
      sys_context('USERENV', 'SERVICE_NAME'),
      sys_context('USERENV', 'SID'),
      sys_context('USERENV', 'SESSIONID'));
    commit;
  end if;
end;

--------------------------------------------------------------------------------

procedure permanent (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null)
is
begin
  log_internal (c_level_permanent, p_message, p_trace, p_user_agent);
end;

--------------------------------------------------------------------------------

procedure error (
  p_message    clob,
  p_trace      boolean  default true,
  p_user_agent varchar2 default null)
is
begin
  log_internal (c_level_error, p_message, p_trace, p_user_agent);
end;

--------------------------------------------------------------------------------

procedure warn (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null)
is
begin
  log_internal (c_level_warning  , p_message, p_trace, p_user_agent);
end;

--------------------------------------------------------------------------------

procedure info (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null)
is
begin
  log_internal (c_level_info, p_message, p_trace, p_user_agent);
end;

--------------------------------------------------------------------------------

procedure log (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null)
is
begin
  log_internal (c_level_info, p_message, p_trace, p_user_agent);
end;

--------------------------------------------------------------------------------

procedure debug (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null)
is
begin
  log_internal (c_level_verbose, p_message, p_trace, p_user_agent);
end;

--------------------------------------------------------------------------------

function get_my_unique_session_id return varchar2
is
begin
  return dbms_session.unique_session_id;
end get_my_unique_session_id;

--------------------------------------------------------------------------------

function get_unique_session_id (
  p_sid     integer,
  p_serial  integer,
  p_inst_id integer default 1) return varchar2
is
  v_inst_id    integer;
  v_return vc16;
begin
  v_inst_id := coalesce(p_inst_id, 1); -- param default 1 does not mean the user cannot provide a null ;-)
  if p_sid is null or p_serial is null then
    raise_application_error (
      -20000,
      'You need to specify at least p_sid and p_serial to calculate the unique session ID.');
  else
    v_return := ltrim(to_char(p_sid,     '000x'))
             || ltrim(to_char(p_serial,  '000x'))
             || ltrim(to_char(v_inst_id, '0000'));
  end if;
  return v_return;
end get_unique_session_id;

--------------------------------------------------------------------------------

function get_sid_serial_inst_id (p_unique_session_id varchar2) return varchar2
is
  v_return vc32;
begin
  if p_unique_session_id is null then
    raise_application_error (
      -20000,
      'You need to specify p_unique_session_id to calculate the sid, serial and host_id.');
  elsif length(p_unique_session_id) != 12 then
    raise_application_error (
      -20000,
      'We use here typically a 12 character long unique session identifier like it is provided by DBMS_SESSION.UNIQUE_SESSION_ID.');
  else
    v_return := to_char(to_number(substr(p_unique_session_id, 1, 4), '000x')) || ', '
             || to_char(to_number(substr(p_unique_session_id, 5, 4), '000x')) || ', '
             || to_char(to_number(substr(p_unique_session_id, 9, 4), '0000'));
  end if;
  return v_return;
end get_sid_serial_inst_id;

--------------------------------------------------------------------------------

end console;
/
