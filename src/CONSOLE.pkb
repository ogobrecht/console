create or replace package body console is

--------------------------------------------------------------------------------
-- CONSTANTS, TYPES, GLOBALS
--------------------------------------------------------------------------------

c_tab             constant varchar2( 1 byte) := chr(9);
c_cr              constant varchar2( 1 byte) := chr(13);
c_lf              constant varchar2( 1 byte) := chr(10);
c_crlf            constant varchar2( 2 byte) := chr(13) || chr(10);
c_at              constant varchar2( 1 byte) := '@';
c_hash            constant varchar2( 1 byte) := '#';
c_slash           constant varchar2( 1 byte) := '/';
c_anonymous_block constant varchar2(30 byte) := '__anonymous_block';
c_vc_max_size     constant pls_integer := 32767;

subtype vc16    is varchar2(   16 char);
subtype vc32    is varchar2(   32 char);
subtype vc64    is varchar2(   64 char);
subtype vc128   is varchar2(  128 char);
subtype vc255   is varchar2(  255 char);
subtype vc500   is varchar2(  500 char);
subtype vc1000  is varchar2( 1000 char);
subtype vc2000  is varchar2( 2000 char);
subtype vc4000  is varchar2( 4000 char);
subtype vc_max  is varchar2(32767 char);

--------------------------------------------------------------------------------
-- PRIVATE METHODS (forward declarations)
--------------------------------------------------------------------------------

$if not $$utils_public $then

procedure create_entry (
  p_level      integer,
  p_message    clob,
  p_trace      boolean,
  p_user_agent varchar2
);

function logging_enabled return boolean;

--------------------HELPER FUNCTIONS FROM STEVEN--------------------
function backtrace_to      return varchar2;
function backtrace_to_line return pls_integer;
--
function call_stack (
  include_anon_block_in   in boolean default false,
  use_line_breaks_in      in boolean default false,
  trace_pkg_in            in varchar2 default null
) return varchar2;
--
function show_summary return varchar2;
--
function show_call_stack_at  (p_depth in pls_integer default 1) return varchar2;
function show_call_stack                                        return varchar2;
--
function show_error_stack_at (p_depth in pls_integer default 1) return varchar2;
function show_error_stack                                       return varchar2;
--
function show_backtrace_at   (p_depth in pls_integer default 1) return varchar2;
function show_backtrace                                         return varchar2;
--------------------HELPER FUNCTIONS FROM STEVEN--------------------

$end

--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------

procedure permanent (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
begin
  create_entry (
    p_level      => c_level_permanent,
    p_message    => p_message,
    p_trace      => p_trace,
    p_user_agent => p_user_agent);
end permanent;

--------------------------------------------------------------------------------

procedure error (
  p_message    clob     default null,
  p_trace      boolean  default true,
  p_user_agent varchar2 default null
) is
begin
  create_entry (
    p_level      => c_level_error,
    p_message    => p_message,
    p_trace      => p_trace,
    p_user_agent => p_user_agent);
  clear;
end error;

--------------------------------------------------------------------------------

procedure warn (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
begin
  create_entry (
    p_level      => c_level_warning,
    p_message    => p_message,
    p_trace      => p_trace,
    p_user_agent => p_user_agent);
end warn;

--------------------------------------------------------------------------------

procedure info (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
begin
  create_entry (
    p_level      => c_level_info,
    p_message    => p_message,
    p_trace      => p_trace,
    p_user_agent => p_user_agent);
end info;

--------------------------------------------------------------------------------

procedure log (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
begin
  create_entry (
    p_level      => c_level_info,
    p_message    => p_message,
    p_trace      => p_trace,
    p_user_agent => p_user_agent);
end log;

--------------------------------------------------------------------------------

procedure debug (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
begin
  create_entry (
    p_level      => c_level_verbose,
    p_message    => p_message,
    p_trace      => p_trace,
    p_user_agent => p_user_agent);
end debug;

--------------------------------------------------------------------------------

procedure trace(
  p_message    clob     default null,
  p_user_agent varchar2 default null
) is
begin
  create_entry (
    p_level      => c_level_info,
    p_message    => nvl(p_message, 'console.trace()'),
    p_trace      => true,
    p_user_agent => p_user_agent);
end trace;

--------------------------------------------------------------------------------

procedure assert(
  p_expression in boolean,
  p_message    in varchar2
) is
begin
  if not p_expression then
    raise_application_error(-20000, p_message);
  end if;
end assert;

--------------------------------------------------------------------------------

procedure init(
  p_action varchar2
) is
begin
  dbms_application_info.set_action(p_action);
end init;

--------------------------------------------------------------------------------

procedure clear is
begin
  dbms_application_info.set_action(null);
end;

--------------------------------------------------------------------------------
-- PUBLIC HELPER METHODS
--------------------------------------------------------------------------------

/*

Some Useful Links
-----------------

- [DBMS_SESSION: Managing Sessions From a Connection Pool in Oracle
  Databases](https://oracle-base.com/articles/misc/dbms_session)


*/

function get_unique_session_id return varchar2 is
begin
  return dbms_session.unique_session_id;
end get_unique_session_id;

--------------------------------------------------------------------------------

function get_unique_session_id (
  p_sid     integer,
  p_serial  integer,
  p_inst_id integer default 1) return varchar2
is
  v_inst_id integer;
  v_return  vc16;
begin
  v_inst_id := coalesce(p_inst_id, 1); -- param default 1 does not mean the user cannot provide null ;-)
  if p_sid is null or p_serial is null then
    raise_application_error (
      -20000,
      'You need to specify at least p_sid and p_serial to calculate a unique session ID.');
  else
    v_return := ltrim(to_char(p_sid,     '000x'))
             || ltrim(to_char(p_serial,  '000x'))
             || ltrim(to_char(v_inst_id, '0000'));
  end if;
  return v_return;
end get_unique_session_id;

--------------------------------------------------------------------------------

function get_sid_serial_inst_id (p_unique_session_id varchar2) return varchar2 is
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

procedure set_module(
  p_module varchar2,
  p_action varchar2 default null
) is
begin
  dbms_application_info.set_module(p_module, p_action);
end set_module;

--------------------------------------------------------------------------------

procedure set_action(
  p_action varchar2
) is
begin
  dbms_application_info.set_action(p_action);
end set_action;

--------------------------------------------------------------------------------
-- PRIVATE METHODS
--------------------------------------------------------------------------------

procedure create_entry (
  p_level      integer,
  p_message    clob,
  p_trace      boolean,
  p_user_agent varchar2
) is
  pragma autonomous_transaction;
  v_call_stack varchar2(4000  char);
begin
  if p_level <= c_level_error or logging_enabled then
    if p_trace then
      v_call_stack :=
        substr(
          call_stack(
            include_anon_block_in  => true,
            use_line_breaks_in     => false,
            trace_pkg_in           => $$plsql_unit
          ),
          1,
          4000)
          --> only for tests
          || chr(10) || chr (10) || show_summary || console.show_call_stack || console.show_error_stack || console.show_backtrace
        ;
    end if;
    --FIXME decide, if we want this or not: dbms_output.put_line(p_message);
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
end create_entry;

--------------------------------------------------------------------------------

function logging_enabled return boolean
is
begin
  return true; --FIXME: implement
end logging_enabled;

--------------------HELPER FUNCTIONS FROM STEVEN--------------------
--https://blogs.oracle.com/oraclemagazine/sophisticated-call-stack-analysis
function backtrace_to
  return varchar2
is
begin
  return    utl_call_stack.backtrace_unit (
                utl_call_stack.error_depth)
          || ' line '
          || utl_call_stack.backtrace_line (
                utl_call_stack.error_depth);
end;
--------------------
function backtrace_to_line
  return pls_integer
is
begin
  return utl_call_stack.backtrace_line (
            utl_call_stack.error_depth);
end;
--------------------
function call_stack (
  include_anon_block_in   in boolean default false,
  use_line_breaks_in      in boolean default false,
  trace_pkg_in            in varchar2 default null)
  return varchar2
is
  l_subprogram       varchar2 (32767);
  l_add_subprogram   boolean;
  l_return           varchar2 (32767);
begin
  -- 1 is always this function, so ignore it.
  for i in reverse 2 .. utl_call_stack.dynamic_depth
  loop
      l_subprogram :=
        utl_call_stack.concatenate_subprogram (
            utl_call_stack.subprogram (i));
      l_add_subprogram :=
        not (    l_return is null
              and not include_anon_block_in
              and l_subprogram = c_anonymous_block);

      if l_add_subprogram and trace_pkg_in is not null
      then
        l_add_subprogram :=
            instr (upper (l_subprogram),
                  upper (trace_pkg_in) || '.') = 0;
      end if;

      if l_add_subprogram
      then
        l_return :=
              l_return
            || case when use_line_breaks_in then chr (10) end
            || case when l_return is not null then ' --> ' end
            || l_subprogram
            || ' ('
            || to_char (utl_call_stack.unit_line (i))
            || ')';
      end if;
  end loop;

  return l_return;
end;
--------------------
function show_summary return varchar2
is
begin
  return
    '## UTL_CALL_STACK Summary ' || chr(10)
    || chr(10)
    || '- dynamic depth: '   || utl_call_stack.dynamic_depth   || chr(10)
    || '- error depth: '     || utl_call_stack.error_depth     || chr(10)
    || '- backtrace depth: ' || utl_call_stack.backtrace_depth || chr(10)
    || chr(10)
    || '### DBMS_UTILITY.FORMAT_CALL_STACK' || chr(10)
    || chr(10)
    || '```' || chr(10)
    || dbms_utility.format_call_stack
    || '```' || chr(10)
    || chr(10)
    ||
  case when sqlcode <> 0 then
    '### DBMS_UTILITY.FORMAT_ERROR_STACK' || chr(10)
    || chr(10)
    || '```' || chr(10)
    || dbms_utility.format_error_stack
    || '```' || chr(10)
    || chr(10)
    || '### DBMS_UTILITY.FORMAT_ERROR_BACKTRACE' || chr(10)
    || chr(10)
    || '```' || chr(10)
    || dbms_utility.format_error_backtrace
    || '```' || chr(10)
    || chr(10)
  end;
end;
--------------------
function show_call_stack_at (p_depth in pls_integer default 1) return varchar2 is
  l_names utl_call_stack.unit_qualified_name;
  l_name  varchar2 (32767);
begin
  return '### Call Stack at Depth ' || p_depth || chr(10)
    || chr(10)
    || '- owner: '                  || utl_call_stack.owner                  (p_depth) || chr(10)
    || '- concatenate subprogram: ' || utl_call_stack.concatenate_subprogram (utl_call_stack.subprogram (p_depth)) || chr(10)
    || '- lexical depth: '          || utl_call_stack.lexical_depth          (p_depth) || chr(10)
    || '- unit line: '              || utl_call_stack.unit_line              (p_depth) || chr(10)
    || '- current edition: '        || utl_call_stack.current_edition        (p_depth) || chr(10)
    || chr(10);
end;
--------------------
function show_call_stack return varchar2 is
  v_return varchar2(32767);
begin
  v_return := '## DBMS_UTILITY.FORMAT_CALL_STACK' || chr(10)
    || chr(10)
    || '```' || chr(10)
    || dbms_utility.format_call_stack
    || '```' || chr(10)
    || chr(10);

  for i in 1 .. utl_call_stack.dynamic_depth
  loop
    v_return := v_return || show_call_stack_at (i);
  end loop;
  return v_return;
end;
--------------------
function show_error_stack_at (p_depth in pls_integer default 1) return varchar2 is
begin
  return '### Error Stack at Depth ' || p_depth || chr(10)
  || chr(10)
  || '- error number: ' || utl_call_stack.error_number (p_depth) || chr(10)
  || '- error msg: '    || utl_call_stack.error_msg    (p_depth) || chr(10)
  || chr(10);
end;
--------------------
function show_error_stack return varchar2 is
  v_return varchar2(32767);
begin
  v_return := '## DBMS_UTILITY.FORMAT_ERROR_STACK' || chr(10)
    || chr(10)
    || '```' || chr(10)
    || dbms_utility.format_error_stack
    || '```' || chr(10)
    || chr(10);

  for i in 1 .. utl_call_stack.error_depth
  loop
    v_return := v_return || show_error_stack_at (i);
  end loop;
  return v_return;
end;
--------------------
function show_backtrace_at (p_depth in pls_integer default 1) return varchar2 is
begin
  return '### Error Backtrace at Depth ' || p_depth || chr(10)
    || chr(10)
    || '- backtrace unit: '|| utl_call_stack.backtrace_unit (p_depth) || chr(10)
    || '- backtrace line: '|| utl_call_stack.backtrace_line (p_depth) || chr(10)
    || chr(10);
end;
--------------------
function show_backtrace return varchar2 is
  v_return varchar2(32767);
begin
  v_return := '## DBMS_UTILITY.FORMAT_ERROR_BACKTRACE' || chr(10)
    || chr(10)
    || '```' || chr(10)
    || dbms_utility.format_error_backtrace
    || '```' || chr(10)
    || chr(10);

  for i in 1 .. utl_call_stack.backtrace_depth
  loop
    v_return := v_return || show_backtrace_at (i);
  end loop;
  return v_return;
end;
--------------------HELPER FUNCTIONS FROM STEVEN--------------------

end console;
/
