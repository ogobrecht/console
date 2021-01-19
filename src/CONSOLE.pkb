create or replace package body console is

--------------------------------------------------------------------------------
-- CONSTANTS, TYPES, GLOBALS
--------------------------------------------------------------------------------

c_tab               constant varchar2 ( 1 byte) := chr(9);
c_cr                constant varchar2 ( 1 byte) := chr(13);
c_lf                constant varchar2 ( 1 byte) := chr(10);
c_crlf              constant varchar2 ( 2 byte) := chr(13) || chr(10);
c_sep               constant varchar2 ( 1 byte) := ',';
c_at                constant varchar2 ( 1 byte) := '@';
c_hash              constant varchar2 ( 1 byte) := '#';
c_slash             constant varchar2 ( 1 byte) := '/';
c_anon_block_orig   constant varchar2 (20 byte) := '__anonymous_block';
c_anonymous_block   constant varchar2 (20 byte) := 'anonymous_block';
c_context_namespace constant varchar2 (30 byte) := $$plsql_unit || '_' || substr(user, 1, 30 - length($$plsql_unit));
c_context_attribute constant varchar2 (30 byte) := 'CONSOLE_CONFIGURATION';
c_context_test_attr constant varchar2 (30 byte) := 'TEST_CONTEXT_AVAILABILITY';
c_date_format       constant varchar2 (16 byte) := 'yyyymmddhh24miss';
c_vc_max_size       constant pls_integer        := 32767;

subtype vc16    is varchar2 (   16 char);
subtype vc32    is varchar2 (   32 char);
subtype vc64    is varchar2 (   64 char);
subtype vc128   is varchar2 (  128 char);
subtype vc255   is varchar2 (  255 char);
subtype vc500   is varchar2 (  500 char);
subtype vc1000  is varchar2 ( 1000 char);
subtype vc2000  is varchar2 ( 2000 char);
subtype vc4000  is varchar2 ( 4000 char);
subtype vc_max  is varchar2 (32767 char);

insufficient_privileges exception;
pragma exception_init (insufficient_privileges, -1031);

g_context varchar2 (4000 byte);

--------------------------------------------------------------------------------
-- PRIVATE METHODS (forward declarations)
--------------------------------------------------------------------------------

$if not $$utils_public $then

procedure create_log_entry (
  p_level      integer,
  p_message    clob,
  p_trace      boolean,
  p_user_agent varchar2
);

function logging_enabled(
  p_level   integer
) return boolean;

function get_context return varchar2;

procedure set_context(p_value varchar2);

procedure clear_context;

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
  create_log_entry (
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
  create_log_entry (
    p_level      => c_level_error,
    p_message    => p_message,
    p_trace      => p_trace,
    p_user_agent => p_user_agent);
  dbms_application_info.set_action(null);
end error;

--------------------------------------------------------------------------------

procedure warn (
  p_message    clob,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
begin
  create_log_entry (
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
  create_log_entry (
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
  create_log_entry (
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
  create_log_entry (
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
  create_log_entry (
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
    raise_application_error(-20000, 'Assertion failed: ' || p_message);
  end if;
end assert;

--------------------------------------------------------------------------------

procedure action(
  p_action varchar2
) is
begin
  dbms_application_info.set_action(p_action);
end action;

--------------------------------------------------------------------------------

procedure init(
  p_session  varchar2 default dbms_session.unique_session_id,
  p_level    integer  default c_level_info,
  p_duration integer  default 60
) is
  v_session vc64 := substr(p_session, 1, 64);
  v_context vc4000;
begin
  if p_level not in (2, 3, 4) then
    raise_application_error(-20000,
      'Level needs to be 2 (warning), 3 (info) or 4 (verbose). Level 1 (error) and 0 (permanent) are always logged without a call to the init method.');
  elsif p_duration < 1 then
    raise_application_error(-20000,
      'Duration needs to be greater or equal 1 (minute).');
  else
    v_context := get_context;
    if instr(v_context, p_session) > 0 then
      null; -- FIXME implement edit of session
    else
      set_context (v_context
        || to_char(sysdate + 1/24/60 * p_duration, c_date_format)
        || c_sep
        || to_char(p_level)
        || c_sep
        || v_session
        || c_lf
      );
    end if;
  end if;
end init;

--------------------------------------------------------------------------------

procedure clear(
  p_session  varchar2 default dbms_session.unique_session_id -- client_identifier or unique_session_id
) is
begin
  null;
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

function get_call_stack return varchar2 is
  v_return     vc_max;
  v_subprogram vc_max;
begin

  if utl_call_stack.error_depth > 0 then
    v_return := v_return || '- ERROR STACK' || chr (10);
    for i in 1 .. utl_call_stack.error_depth
    loop
      v_return := v_return
        || '  - ORA-'
        || trim(to_char(utl_call_stack.error_number(i), '00009')) || ' '
        || utl_call_stack.error_msg(i)
        || chr (10);
    end loop;
  end if;

  if utl_call_stack.backtrace_depth > 0 then
    v_return := v_return || '- ERROR BACKTRACE' || chr (10);
    for i in 1 .. utl_call_stack.backtrace_depth
    loop
      v_return := v_return
        || '  - '
        || coalesce(utl_call_stack.backtrace_unit(i), c_anonymous_block)
        || ', line ' || utl_call_stack.backtrace_line(i)
        || chr (10);
    end loop;
  end if;

  if utl_call_stack.dynamic_depth > 0 then
    v_return := v_return || '- CALL STACK' || chr (10);
    --ignore 1, is always this function (get_call_stack) itself
    for i in 2 .. utl_call_stack.dynamic_depth
    loop
      --the replace changes `__anonymous_block` to `anonymous_block`
      v_subprogram := replace(
        utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(i)),
        c_anon_block_orig,
        c_anonymous_block
      );
      --exclude console package from the call stack
      if instr(upper(v_subprogram), upper($$plsql_unit)||'.') = 0 then
        v_return := v_return
          || '  - '
          || case when utl_call_stack.owner(i) is not null then utl_call_stack.owner(i) || '.' end
          || v_subprogram || ', line ' || utl_call_stack.unit_line (i)
          || chr (10);
      end if;
    end loop;
  end if;

  return v_return;
end;

--------------------------------------------------------------------------------

function context_available_yn return varchar2 is
begin
  sys.dbms_session.set_context(c_context_namespace, c_context_test_attr, 'Check context availability');
  return 'Y';
exception
  when others then
    return 'N';
end;

--------------------------------------------------------------------------------
-- PRIVATE METHODS
--------------------------------------------------------------------------------

procedure create_log_entry (
  p_level      integer,
  p_message    clob,
  p_trace      boolean,
  p_user_agent varchar2
) is
  pragma autonomous_transaction;
  v_call_stack console_logs.call_stack%type;
  v_sqlerrm vc255 := case when sqlcode != 0 then substr(sqlerrm,1 , 255) end;
begin
  if p_level <= c_level_error or logging_enabled (p_level) then
    if p_trace then
      v_call_stack := substr(get_call_stack, 1, 2000);
    end if;
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
      sessionid
    )
    values (
      p_level,
      coalesce(p_message, to_clob(v_sqlerrm)),
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
      sys_context('USERENV', 'SESSIONID')
    );
    commit;
  end if;
end create_log_entry;

--------------------------------------------------------------------------------

function logging_enabled(
  p_level   integer
) return boolean is
  v_context       vc4000;
  v_start         pls_integer;
  --
  function is_enabled (
    p_session varchar2,
    p_level pls_integer
  ) return boolean is
    v_level         pls_integer;
    v_date          date;
  begin
    v_start := instr(v_context, p_session);
    if v_start > 0 then
      --example entry: 20210117202241,4,APEX:8805903776765
      begin
        v_level := to_number(substr(v_context, v_start -  2,  1 ));
        v_date  := to_date  (substr(v_context, v_start - 17, 14 ), c_date_format);
      exception
        when others then
          null; -- I know, I know - never do this - but here it is ok if we cannot convert
      end;
    end if;
    return v_level >= p_level and v_date > sysdate;
  end;
  --
begin
  v_context := get_context;
  return is_enabled(sys_context('USERENV', 'CLIENT_IDENTIFIER'), p_level)
      or is_enabled(dbms_session.unique_session_id, p_level);
end logging_enabled;

function get_context return varchar2 is
begin
  if context_available_yn = 'Y' then
    return sys_context(c_context_namespace, c_context_attribute, 4000);
  else
    return g_context;
  end if;
end;

procedure set_context(p_value varchar2) is
begin
  assert(
    lengthb(p_value) <= 4000,
    'console.set_context(p_value varchar2) was called with a value longer then 4000 byte (this is an internal call of console.init). Do you really need that much sessions in logging mode? The Average session entry needs 30 to 40 byte, that means you could have around 100 sessions in logging mode.'
  );
  sys.dbms_session.set_context(c_context_namespace, c_context_attribute, p_value);
exception
  when insufficient_privileges then
    g_context := p_value;
  when others then
    error;
    raise;
end;

procedure clear_context is
begin
  sys.dbms_session.clear_context(
    namespace => c_context_namespace,
    attribute => c_context_attribute
  );
exception
  when insufficient_privileges then
    g_context := null;
end;

end console;
/
