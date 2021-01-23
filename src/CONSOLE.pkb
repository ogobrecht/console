create or replace package body console is

--------------------------------------------------------------------------------
-- CONSTANTS, TYPES, GLOBALS
--------------------------------------------------------------------------------

insufficient_privileges exception;
pragma exception_init (insufficient_privileges, -1031);

c_tab                constant varchar2 ( 1 byte) := chr(9);
c_cr                 constant varchar2 ( 1 byte) := chr(13);
c_lf                 constant varchar2 ( 1 byte) := chr(10);
c_lflf               constant varchar2 ( 2 byte) := chr(10) || chr(10);
c_crlf               constant varchar2 ( 2 byte) := chr(13) || chr(10);
c_sep                constant varchar2 ( 1 byte) := ',';
c_at                 constant varchar2 ( 1 byte) := '@';
c_hash               constant varchar2 ( 1 byte) := '#';
c_slash              constant varchar2 ( 1 byte) := '/';
c_anon_block_orig    constant varchar2 (20 byte) := '__anonymous_block';
c_anonymous_block    constant varchar2 (20 byte) := 'anonymous_block';
c_ctx_namespace      constant varchar2 (30 byte) := $$plsql_unit || '_' || substr(user, 1, 30 - length($$plsql_unit));
--c_context_attribute constant varchar2 (30 byte) := 'CONSOLE_CONFIGURATION';
c_ctx_test_attribute constant varchar2 (30 byte) := 'TEST';
c_ctx_level          constant varchar2 (2 byte) := '.L';
c_ctx_valid_until    constant varchar2 (2 byte) := '.V';
c_ctx_flush_cache    constant varchar2 (2 byte) := '.F';
c_ctx_date_format    constant varchar2 (16 byte) := 'yyyymmddhh24miss';
c_vc_max_size        constant pls_integer        := 32767;

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

g_context                 varchar2 (4000 byte);
g_context_available       boolean;
g_conf_level              integer := 1;
g_conf_valid_until        date    := sysdate;
g_conf_client_identifier varchar2 (64 byte);

--------------------------------------------------------------------------------
-- PRIVATE METHODS (forward declarations)
--------------------------------------------------------------------------------

$if not $$utils_public $then

function logging_enabled (p_level integer) return boolean;

procedure create_log_entry (
  p_level      integer                ,
  p_message    clob     default null  ,
  p_trace      boolean  default false ,
  p_user_agent varchar2 default null  );

function get_context (p_attribute varchar2) return varchar2;

procedure set_context (p_attribute varchar2, p_value varchar2);

procedure clear_context;

$end

--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------

procedure permanent (p_message clob) is
begin
  if logging_enabled (c_level_permanent) then
    create_log_entry (
      p_level      => c_level_permanent ,
      p_message    => p_message         );
  end if;
end permanent;

--------------------------------------------------------------------------------

procedure error (
  p_message    clob     default null ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_level_error) then
    create_log_entry (
      p_level      => c_level_error ,
      p_message    => p_message     ,
      p_trace      => true          ,
      p_user_agent => p_user_agent  );
  end if;
end error;

--------------------------------------------------------------------------------

procedure warn (
  p_message    clob                  ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_level_warning) then
    create_log_entry (
      p_level      => c_level_warning ,
      p_message    => p_message       ,
      p_user_agent => p_user_agent    );
  end if;
end warn;

--------------------------------------------------------------------------------

procedure info (
  p_message    clob                  ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_level_info) then
    create_log_entry (
      p_level      => c_level_info ,
      p_message    => p_message    ,
      p_user_agent => p_user_agent );
  end if;
end info;

--------------------------------------------------------------------------------

procedure log (
  p_message    clob                  ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_level_info) then
    create_log_entry (
      p_level      => c_level_info ,
      p_message    => p_message    ,
      p_user_agent => p_user_agent );
  end if;
end log;

--------------------------------------------------------------------------------

procedure debug (
  p_message    clob                  ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_level_verbose) then
    create_log_entry (
      p_level      => c_level_verbose ,
      p_message    => p_message       ,
      p_user_agent => p_user_agent    );
  end if;
end debug;

--------------------------------------------------------------------------------

procedure trace (
  p_message    clob     default null ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_level_info) then
    create_log_entry (
      p_level      => c_level_info ,
      p_message    => p_message    ,
      p_trace      => true         ,
      p_user_agent => p_user_agent );
  end if;
end trace;

--------------------------------------------------------------------------------

procedure assert (
  p_expression boolean  ,
  p_message    varchar2 )
is
begin
  if not p_expression then
    raise_application_error(-20000, 'Assertion failed: ' || p_message, true);
  end if;
end assert;

--------------------------------------------------------------------------------

procedure action (
  p_action varchar2 )
is
begin
  dbms_application_info.set_action(p_action);
end action;

--------------------------------------------------------------------------------

function my_client_identifier return varchar2 is
begin
  return g_conf_client_identifier;
end;

--------------------------------------------------------------------------------

procedure init (
  p_session  varchar2                     ,
  p_level    integer default c_level_info ,
  p_duration integer default 60           )
is
  v_session vc64 := substr(p_session, 1, 64);
  v_context vc4000;
begin
  assert(p_level in (2, 3, 4), 'Level needs to be 2 (warning), 3 (info) or 4 (verbose). Level 1 (error) and 0 (permanent) are always logged without a call to the init method.');
  assert(p_duration > 1, 'Duration needs to be greater or equal 1 (minute).');
  set_context (p_session || c_ctx_level, to_char(p_level));
end init;

procedure init (
  p_level    integer default c_level_info ,
  p_duration integer default 60           )
is
begin
  init(
    p_session  => g_conf_client_identifier,
    p_level    => p_level,
    p_duration => p_duration
  );
end init;

--------------------------------------------------------------------------------

procedure clear (
  p_session  varchar2 default my_client_identifier
) is
begin
  null; -- FIXME implement
end;

--------------------------------------------------------------------------------
-- PUBLIC HELPER METHODS
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

function get_scope return varchar2 is
  v_return     vc_max;
  v_subprogram vc_max;
begin
  if utl_call_stack.dynamic_depth > 0 then
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
          || case when utl_call_stack.owner(i) is not null then utl_call_stack.owner(i) || '.' end
          || v_subprogram || ', line ' || utl_call_stack.unit_line (i)
          || chr (10);
      end if;
      exit when v_return is not null;
    end loop;
  end if;
  return v_return;
end get_scope;

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
end get_call_stack;

--------------------------------------------------------------------------------

function my_log_level return integer is
begin
  return g_conf_level;
end my_log_level;

--------------------------------------------------------------------------------

function context_available_yn return varchar2 is
begin
  return case when g_context_available then 'Y' else 'N' end;
end;

--------------------------------------------------------------------------------

function version return varchar2 is
begin
  return c_version;
end;

--------------------------------------------------------------------------------
-- PRIVATE METHODS
--------------------------------------------------------------------------------

function logging_enabled (p_level integer) return boolean is
begin
  if g_conf_level >= p_level and g_conf_valid_until >= sysdate or sqlcode != 0 then
    return true;
  else
    -- FIXME refresh cache
    return false;
  end if;
end logging_enabled;

--------------------------------------------------------------------------------

procedure create_log_entry (
  p_level      integer,
  p_message    clob     default null,
  p_trace      boolean  default false,
  p_user_agent varchar2 default null
) is
  pragma autonomous_transaction;
  v_message    clob;
  v_call_stack vc4000;
  v_scope   console_logs.scope%type;
begin
  v_scope := substr(get_scope, 1, 1000);
  if p_message is not null then
    v_message := p_message;
  elsif sqlcode != 0 then
    v_message := sqlerrm;
  end if;
  if p_trace then
    v_call_stack := substr(get_call_stack, 1, 4000);
  end if;
  insert into console_logs (
    log_level,
    scope,
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
    sid
  )
  values (
    p_level,
    v_scope,
    v_message,
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
    sys_context('USERENV', 'SID')
  );
  commit;
end create_log_entry;

--------------------------------------------------------------------------------

function get_context (p_attribute varchar2) return varchar2 is
begin
  if g_context_available then
    return sys_context(c_ctx_namespace, p_attribute);
  else
    return g_context;
  end if;
end;

procedure set_context (p_attribute varchar2, p_value varchar2) is
begin
  if g_context_available then
    sys.dbms_session.set_context(c_ctx_namespace, p_attribute, p_value);
  else
    g_context := p_value;
  end if;
end;


procedure clear_context is
begin
  null; -- FIXME implement
  /*
  sys.dbms_session.clear_context(
    namespace => c_ctx_namespace,
    attribute => c_context_attribute
  );
  */
exception
  when insufficient_privileges then
    g_context := null;
end;

-- package inizialization
begin

  -- set client identifier
  g_conf_client_identifier := sys_context('USERENV', 'CLIENT_IDENTIFIER');
  if g_conf_client_identifier is null then
    g_conf_client_identifier := dbms_session.unique_session_id;
    dbms_session.set_identifier (g_conf_client_identifier);
  end if;

  -- test context availability
  begin
    sys.dbms_session.set_context(c_ctx_namespace, c_ctx_test_attribute, 'test');
    g_context_available := true;
  exception
    when insufficient_privileges then
      g_context_available := false;
  end;

end console;
/
