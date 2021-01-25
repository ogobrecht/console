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
c_anon_block_ora     constant varchar2 (20 byte) := '__anonymous_block';
c_anonymous_block    constant varchar2 (20 byte) := 'anonymous_block';
c_client_id_prefix   constant varchar2 ( 5 byte) := '{o,o}';
c_ctx_namespace      constant varchar2 (30 byte) := $$plsql_unit || '_' || substr(user, 1, 30 - length($$plsql_unit));
c_ctx_test_attribute constant varchar2 (15 byte) := 'TEST';
c_ctx_date_format    constant varchar2 (16 byte) := 'yyyymmddhh24miss';
c_ctx_level          constant varchar2 (15 byte) := 'LEVEL';
c_ctx_end_date       constant varchar2 (15 byte) := 'END_DATE';
c_ctx_cache_duration constant varchar2 (15 byte) := 'CACHE_DURATION';
c_ctx_cache_size     constant varchar2 (15 byte) := 'CACHE_SIZE';
c_ctx_user_env       constant varchar2 (15 byte) := 'USER_ENV';
c_ctx_apex_env       constant varchar2 (15 byte) := 'APEX_ENV';
c_ctx_cgi_env        constant varchar2 (15 byte) := 'CGI_ENV';
c_ctx_console_env    constant varchar2 (15 byte) := 'CONSOLE_ENV';
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

g_conf_client_identifier varchar2 (64 byte);
g_conf_context_available boolean := false; -- initial value, will be reevaluated on package initialization
g_conf_level             pls_integer := 1;
g_conf_valid_until       date        := sysdate;
g_conf_user_env          boolean;
g_conf_apex_env          boolean;
g_conf_cgi_env           boolean;
g_conf_console_env       boolean;

--------------------------------------------------------------------------------
-- PRIVATE METHODS (forward declarations)
--------------------------------------------------------------------------------

$if not $$utils_public $then

procedure check_context_availability;

function logging_enabled (p_level integer) return boolean;

procedure create_log_entry (
  p_level      integer                ,
  p_message    clob     default null  ,
  p_trace      boolean  default false ,
  p_user_agent varchar2 default null  );

function get_context (p_attribute varchar2) return varchar2;

procedure clear_context (p_client_identifier varchar2 );

procedure clear_all_context;


$end

--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------

procedure permanent (
  p_message clob )
is
begin
  create_log_entry (
    p_level      => c_permanent ,
    p_message    => p_message   );
end permanent;

--------------------------------------------------------------------------------

procedure error (
  p_message    clob     default null ,
  p_user_agent varchar2 default null )
is
begin
  create_log_entry (
    p_level      => c_error      ,
    p_message    => p_message    ,
    p_trace      => true         ,
    p_user_agent => p_user_agent );
end error;

--------------------------------------------------------------------------------

procedure warn (
  p_message    clob                  ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_warning) then
    create_log_entry (
      p_level      => c_warning    ,
      p_message    => p_message    ,
      p_user_agent => p_user_agent );
  end if;
end warn;

--------------------------------------------------------------------------------

procedure info (
  p_message    clob                  ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_info) then
    create_log_entry (
      p_level      => c_info       ,
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
  if logging_enabled (c_info) then
    create_log_entry (
      p_level      => c_info       ,
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
  if logging_enabled (c_verbose) then
    create_log_entry (
      p_level      => c_verbose    ,
      p_message    => p_message    ,
      p_user_agent => p_user_agent );
  end if;
end debug;

--------------------------------------------------------------------------------

procedure trace (
  p_message    clob     default null ,
  p_user_agent varchar2 default null )
is
begin
  if logging_enabled (c_info) then
    create_log_entry (
      p_level      => c_info       ,
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
  p_client_id      varchar2               ,
  p_level          integer default c_info ,
  p_duration       integer default 60     ,
  p_cache_duration integer default 10     ,
  p_cache_size     integer default 0      ,
  p_user_env       boolean default false  ,
  p_apex_env       boolean default false  ,
  p_cgi_env        boolean default false  ,
  p_console_env    boolean default false  )
is
  pragma autonomous_transaction;
  v_session     varchar2 (64 byte) := substrb(p_client_id, 1, 64);
  v_user_env    varchar2 (1 byte);
  v_apex_env    varchar2 (1 byte);
  v_cgi_env     varchar2 (1 byte);
  v_console_env varchar2 (1 byte);
  v_end_date    date;
  v_count       pls_integer;
  --
  procedure set_context (
  p_attribute         varchar2 ,
  p_value             varchar2 ,
  p_client_identifier varchar2 )
  is
  begin
    sys.dbms_session.set_context(
      namespace => c_ctx_namespace     ,
      attribute => p_attribute         ,
      value     => p_value             ,
      client_id => p_client_identifier );
  exception
    when insufficient_privileges then
      error('Context not available, package var g_conf_context_available tells us it is ?!?');
  end;
  --
begin
  assert(p_level          in (2, 3, 4),       'Level needs to be 2 (warning), 3 (info) or 4 (verbose). Level 1 (error) and 0 (permanent) are always logged without a call to the init method.');
  assert(p_duration       between 1 and 1440, 'Duration needs to be between 1 and 1440 (minutes).');
  assert(p_cache_duration between 1 and   10, 'Cache duration needs to be between 1 and 10 (seconds).');
  assert(p_cache_size     between 0 and  100, 'Cache size needs to be between 1 and 100 (log entries).');
  assert(p_user_env       is not null,        'User env needs to be true or false(not null).');
  assert(p_apex_env       is not null,        'APEX env needs to be true or false(not null).');
  assert(p_cgi_env        is not null,        'CGI env needs to be true or false(not null).');
  assert(p_console_env    is not null,        'Console env needs to be true or false(not null).');
  --
  v_user_env    := case when p_user_env    then 'Y' else 'N' end;
  v_apex_env    := case when p_apex_env    then 'Y' else 'N' end;
  v_cgi_env     := case when p_cgi_env     then 'Y' else 'N' end;
  v_console_env := case when p_console_env then 'Y' else 'N' end;
  v_end_date    := localtimestamp + 1/24/60 * p_duration;
  --
  select count(*) into v_count from console_sessions where client_identifier = p_client_id;
  if v_count = 0 then
    insert into console_sessions (
      client_identifier,
      log_level,
      start_date,
      end_date,
      cache_duration,
      cache_size,
      user_env,
      apex_env,
      cgi_env,
      console_env
    ) values (
      p_client_id,
      p_level,
      localtimestamp ,
      v_end_date,
      p_cache_duration,
      p_cache_size,
      v_user_env,
      v_apex_env,
      v_cgi_env,
      v_console_env
    );
  else
    update
      console_sessions
    set
      log_level      = p_level,
      end_date       = v_end_date,
      cache_duration = p_cache_duration,
      cache_size     = p_cache_size,
      user_env       = v_user_env,
      apex_env       = v_apex_env,
      cgi_env        = v_cgi_env,
      console_env    = v_console_env
    where
      client_identifier = p_client_id;
  end if;
  commit;
  --
  if g_conf_context_available then
    set_context ( c_ctx_level         , to_char(p_level)                      , p_client_id );
    set_context ( c_ctx_end_date      , to_char(v_end_date, c_ctx_date_format), p_client_id );
    set_context ( c_ctx_cache_duration, to_char(p_cache_duration)             , p_client_id );
    set_context ( c_ctx_cache_size    , to_char(p_cache_size)                 , p_client_id );
    set_context ( c_ctx_user_env      , to_char(v_user_env)                   , p_client_id );
    set_context ( c_ctx_apex_env      , to_char(v_apex_env)                   , p_client_id );
    set_context ( c_ctx_cgi_env       , to_char(v_cgi_env)                    , p_client_id );
    set_context ( c_ctx_console_env   , to_char(v_console_env)                , p_client_id );
  else
    null;
  end if;
end init;

procedure init (
  p_level          integer default c_info ,
  p_duration       integer default 60     ,
  p_cache_duration integer default 10     ,
  p_cache_size     integer default 0      ,
  p_user_env       boolean default false  ,
  p_apex_env       boolean default false  ,
  p_cgi_env        boolean default false  ,
  p_console_env    boolean default false  )
is
begin
  init(
    p_client_id      => g_conf_client_identifier ,
    p_level          => p_level                  ,
    p_duration       => p_duration               ,
    p_cache_duration => p_cache_duration         ,
    p_cache_size     => p_cache_size             ,
    p_user_env       => p_user_env               ,
    p_apex_env       => p_apex_env               ,
    p_cgi_env        => p_cgi_env                ,
    p_console_env    => p_console_env            );
end init;

--------------------------------------------------------------------------------

procedure clear (
  p_client_id varchar2 default my_client_identifier )
is
begin
  null; -- FIXME implement
end;

--------------------------------------------------------------------------------
-- PUBLIC HELPER METHODS
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
        c_anon_block_ora,
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

function get_call_stack return varchar2
is
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
        c_anon_block_ora,
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
  return case when g_conf_context_available then 'Y' else 'N' end;
end;

--------------------------------------------------------------------------------

function version return varchar2 is
begin
  return c_version;
end;

--------------------------------------------------------------------------------
-- PRIVATE METHODS
--------------------------------------------------------------------------------

function logging_enabled (
  p_level integer )
return boolean is
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
  p_message    clob     default null  ,
  p_trace      boolean  default false ,
  p_user_agent varchar2 default null  )
is
  pragma autonomous_transaction;
  v_message    clob;
  v_call_stack vc4000;
  v_scope   console_logs.scope%type;
begin
  v_scope := substrb(get_scope, 1, 1000);
  if p_message is not null then
    v_message := p_message;
  elsif sqlcode != 0 then
    v_message := sqlerrm;
  end if;
  if p_trace then
    v_call_stack := substrb(get_call_stack, 1, 4000);
  end if;
  insert into console_logs (
    log_level,
    scope,
    message,
    call_stack,
    session_user,
    module,
    action,
    client_info,
    client_identifier,
    ip_address,
    host,
    os_user,
    os_user_agent
  )
  values (
    p_level,
    v_scope,
    v_message,
    v_call_stack,
    substrb( sys_context('USERENV', 'SESSION_USER')     , 1, 32),
    substrb( sys_context('USERENV', 'MODULE')           , 1, 48),
    substrb( sys_context('USERENV', 'ACTION')           , 1, 32),
    substrb( sys_context('USERENV', 'CLIENT_INFO')      , 1, 64),
    substrb( sys_context('USERENV', 'CLIENT_IDENTIFIER'), 1, 64),
    substrb( sys_context('USERENV', 'IP_ADDRESS')       , 1, 48),
    substrb( sys_context('USERENV', 'HOST')             , 1, 64),
    substrb( sys_context('USERENV', 'OS_USER')          , 1, 64),
    substrb(p_user_agent, 1, 200)
  );
  commit;
end create_log_entry;

--------------------------------------------------------------------------------

function get_context (
  p_attribute varchar2 )
return varchar2 is
begin
  if g_conf_context_available then
    return sys_context(c_ctx_namespace, p_attribute);
  else
    return null; --FIXME implement
  end if;
end;

--------------------------------------------------------------------------------

procedure clear_context (
  p_client_identifier varchar2 )
is
begin
  if g_conf_context_available then
    sys.dbms_session.clear_context(c_ctx_namespace, p_client_identifier);
  end if;
exception
  when insufficient_privileges then
    error('Context not available, package var g_conf_context_available tells us it is ?!?');
end;

--------------------------------------------------------------------------------

procedure clear_all_context is
begin
  if g_conf_context_available then
    sys.dbms_session.clear_all_context (c_ctx_namespace);
  end if;
exception
  when insufficient_privileges then
    error('Context not available, package var g_conf_context_available tells us it is ?!?');
end;

--------------------------------------------------------------------------------

procedure check_context_availability is
begin
  -- check only, if needed
  if not g_conf_context_available then
    sys.dbms_session.set_context(c_ctx_namespace, c_ctx_test_attribute, 'test');
    g_conf_context_available := true;
  end if;
exception
  when insufficient_privileges then
    g_conf_context_available := false;
end;

--------------------------------------------------------------------------------

procedure set_client_identifier is
begin
  g_conf_client_identifier := sys_context('USERENV', 'CLIENT_IDENTIFIER');
  if g_conf_client_identifier is null then
    g_conf_client_identifier := c_client_id_prefix || dbms_session.unique_session_id;
    dbms_session.set_identifier (g_conf_client_identifier);
  end if;
end;

--------------------------------------------------------------------------------

-- package inizialization
begin
  set_client_identifier;
  check_context_availability;
end console;
/
