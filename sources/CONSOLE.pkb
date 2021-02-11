create or replace package body console is

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS, TYPES, GLOBALS
--------------------------------------------------------------------------------

insufficient_privileges exception;
pragma exception_init (insufficient_privileges, -1031);

c_identifier_length   constant pls_integer := 128;
subtype t_identifier  is varchar2 (c_identifier_length char);

c_tab                          constant varchar2 ( 1 byte) := chr(9);
c_cr                           constant varchar2 ( 1 byte) := chr(13);
c_lf                           constant varchar2 ( 1 byte) := chr(10);
c_lflf                         constant varchar2 ( 2 byte) := chr(10) || chr(10);
c_crlf                         constant varchar2 ( 2 byte) := chr(13) || chr(10);
c_sep                          constant varchar2 ( 1 byte) := ',';
c_at                           constant varchar2 ( 1 byte) := '@';
c_hash                         constant varchar2 ( 1 byte) := '#';
c_slash                        constant varchar2 ( 1 byte) := '/';
c_ampersand                    constant varchar2 ( 1 byte) := chr(26);
c_html_ampersand               constant varchar2 ( 5 byte) := chr(26) || 'amp;';
c_html_less_then               constant varchar2 ( 4 byte) := chr(26) || 'lt;';
c_html_greater_then            constant varchar2 ( 4 byte) := chr(26) || 'gt;';
c_default_label                constant varchar2 (64 byte) := 'Default';
c_anon_block_ora               constant varchar2 (20 byte) := '__anonymous_block';
c_anonymous_block              constant varchar2 (20 byte) := 'anonymous_block';
c_client_id_prefix             constant varchar2 ( 6 byte) := '{o,o} ';
c_console_pkg_name             constant varchar2 (60 byte) := upper($$plsql_unit) || '.';
c_ctx_namespace                constant varchar2 (30 byte) := $$plsql_unit || '_' || substr(user, 1, 30 - length($$plsql_unit));
c_ctx_test_attribute           constant varchar2 (15 byte) := 'TEST';
c_ctx_date_format              constant varchar2 (16 byte) := 'yyyymmddhh24miss';
c_ctx_log_level                constant varchar2 (15 byte) := 'LOG_LEVEL';
c_ctx_end_date                 constant varchar2 (15 byte) := 'END_DATE';
c_ctx_cache_size               constant varchar2 (15 byte) := 'CACHE_SIZE';
c_ctx_cache_duration           constant varchar2 (15 byte) := 'CACHE_DURATION';
c_ctx_user_env                 constant varchar2 (15 byte) := 'USER_ENV';
c_ctx_apex_env                 constant varchar2 (15 byte) := 'APEX_ENV';
c_ctx_cgi_env                  constant varchar2 (15 byte) := 'CGI_ENV';
c_ctx_console_env              constant varchar2 (15 byte) := 'CONSOLE_ENV';
c_vc_max_size                  constant pls_integer        := 32767;

-- numeric type identfiers
c_number                       constant pls_integer := 2;   -- float
c_binary_float                 constant pls_integer := 100;
c_binary_double                constant pls_integer := 101;
-- string type identfiers
c_char                         constant pls_integer := 96;  -- nchar
c_varchar2                     constant pls_integer := 1;   -- nvarchar2
c_long                         constant pls_integer := 8;
c_clob                         constant pls_integer := 112; -- nclob
c_xmltype                      constant pls_integer := 109; -- anydata, anydataset, anytype, object type, varray, nested table
c_rowid                        constant pls_integer := 69;
c_urowid                       constant pls_integer := 208;
-- binary type identfiers
c_raw                          constant pls_integer := 23;
c_long_raw                     constant pls_integer := 24;
c_blob                         constant pls_integer := 113;
c_bfile                        constant pls_integer := 114;
-- date type identfiers
c_date                         constant pls_integer := 12;
c_timestamp                    constant pls_integer := 180;
c_timestamp_tz                 constant pls_integer := 181;
c_timestamp_ltz                constant pls_integer := 231;
-- interval type identfiers
c_interval_year_to_month       constant pls_integer := 182;
c_interval_day_to_second       constant pls_integer := 183;
-- cursor type identfiers
c_ref                          constant pls_integer := 111;
c_ref_cursor                   constant pls_integer := 102; -- same identfiers for strong and weak ref cursor

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

g_conf_context_available      boolean;
g_conf_cache_valid_until_date date;
g_conf_client_identifier      varchar2 (64 byte);
g_conf_log_level              pls_integer;
g_conf_start_date             date;
g_conf_end_date               date;
g_conf_cache_size             integer;
g_conf_cache_duration         integer;
g_conf_user_env               boolean;
g_conf_apex_env               boolean;
g_conf_cgi_env                boolean;
g_conf_console_env            boolean;

type tab_timers is table of timestamp index by t_identifier;
type tab_counters is table of pls_integer index by t_identifier;
g_timers tab_timers;
g_counters tab_counters;

-------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS (forward declarations)
--------------------------------------------------------------------------------

$if not $$utils_public $then

function  utl_logging_enabled ( p_level integer ) return boolean;
function  utl_normalize_label (p_label varchar2) return varchar2;
function  utl_read_row_from_sessions ( p_client_identifier varchar2 ) return console_sessions%rowtype result_cache;
procedure utl_check_context_availability;
procedure utl_clear_all_context;
procedure utl_clear_context ( p_client_identifier varchar2 );
procedure utl_flush_log_cache;
procedure utl_load_session_configuration;
procedure utl_set_client_identifier;
--
function utl_create_log_entry (
  p_level           integer                ,
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return integer;
procedure utl_create_log_entry (
  p_level           integer                ,
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  );

$end

--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------

function my_client_identifier return varchar2 is
begin
  return g_conf_client_identifier;
end;

--------------------------------------------------------------------------------

function my_log_level return integer is
begin
  return g_conf_log_level;
end my_log_level;

--------------------------------------------------------------------------------

procedure permanent (
  p_message clob )
is
begin
  utl_create_log_entry (
    p_level   => c_permanent ,
    p_message => p_message   );
end permanent;

--------------------------------------------------------------------------------

procedure error (
  p_message         clob     default null  ,
  p_trace           boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  utl_create_log_entry (
    p_level           => c_error           ,
    p_message         => p_message         ,
    p_trace           => p_trace           ,
    p_apex_env        => p_apex_env        ,
    p_cgi_env         => p_cgi_env         ,
    p_console_env     => p_console_env     ,
    p_user_env        => p_user_env        ,
    p_user_agent      => p_user_agent      ,
    p_user_scope      => p_user_scope      ,
    p_user_error_code => p_user_error_code ,
    p_user_call_stack => p_user_call_stack );
end error;

function error (
  p_message         clob     default null  ,
  p_trace           boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return integer is
begin
  return utl_create_log_entry (
    p_level           => c_error           ,
    p_message         => p_message         ,
    p_trace           => p_trace           ,
    p_apex_env        => p_apex_env        ,
    p_cgi_env         => p_cgi_env         ,
    p_console_env     => p_console_env     ,
    p_user_env        => p_user_env        ,
    p_user_agent      => p_user_agent      ,
    p_user_scope      => p_user_scope      ,
    p_user_error_code => p_user_error_code ,
    p_user_call_stack => p_user_call_stack );
end;

--------------------------------------------------------------------------------

procedure warn (
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  if utl_logging_enabled (c_warning) then
    utl_create_log_entry (
      p_level           => c_warning         ,
      p_message         => p_message         ,
      p_trace           => p_trace           ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
end warn;

--------------------------------------------------------------------------------

procedure info (
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  if utl_logging_enabled (c_info) then
    utl_create_log_entry (
      p_level           => c_info            ,
      p_message         => p_message         ,
      p_trace           => p_trace           ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
end info;

--------------------------------------------------------------------------------

procedure log (
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  if utl_logging_enabled (c_info) then
    utl_create_log_entry (
      p_level           => c_info            ,
      p_message         => p_message         ,
      p_trace           => p_trace           ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
end log;

--------------------------------------------------------------------------------

procedure debug (
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  if utl_logging_enabled (c_verbose) then
    utl_create_log_entry (
      p_level           => c_verbose         ,
      p_message         => p_message         ,
      p_trace           => p_trace           ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
end debug;

--------------------------------------------------------------------------------

procedure assert (
  p_expression boolean  ,
  p_message    varchar2 )
is
begin
  if not p_expression then
    raise_application_error(-20777, 'Assertion failed: ' || p_message, true);
  end if;
end assert;

--------------------------------------------------------------------------------

procedure trace (
  p_message         clob     default null  ,
  p_trace           boolean  default true  ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
begin
  if utl_logging_enabled (c_info) then
    utl_create_log_entry (
      p_level           => c_info            ,
      p_message         => p_message         ,
      p_trace           => p_trace           ,
      p_apex_env        => p_apex_env        ,
      p_cgi_env         => p_cgi_env         ,
      p_console_env     => p_console_env     ,
      p_user_env        => p_user_env        ,
      p_user_agent      => p_user_agent      ,
      p_user_scope      => p_user_scope      ,
      p_user_error_code => p_user_error_code ,
      p_user_call_stack => p_user_call_stack );
  end if;
end trace;

--------------------------------------------------------------------------------

procedure count (
  p_label varchar2 default null )
is
  v_label t_identifier;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    g_counters(v_label) := g_counters(v_label) + 1;
  else
    g_counters(v_label) := 1;
  end if;
end count;

procedure count_end (
  p_label varchar2 default null )
is
  v_label t_identifier;
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    if utl_logging_enabled (c_info) then
      utl_create_log_entry (
        p_level   => c_info,
        p_message => v_label || ': ' || to_char(g_counters(v_label)) );
    end if;
    g_counters.delete(v_label);
  else
    warn('Counter `' || v_label || '` does not exist.');
  end if;
end count_end;

function count_end (
  p_label varchar2 default null )
return varchar2
is
  v_label   t_identifier;
  v_return  varchar2(50);
begin
  v_label := utl_normalize_label(p_label);
  if g_counters.exists(v_label) then
    v_return := to_char(g_counters(v_label));
    g_counters.delete(v_label);
  else
    v_return := 'Counter `' || v_label || '` does not exist.';
  end if;
  return v_return;
end count_end;

--------------------------------------------------------------------------------

procedure time (
  p_label varchar2 default null )
is
begin
  g_timers(utl_normalize_label(p_label)) := localtimestamp;
end time;

procedure time_end (
  p_label varchar2 default null )
is
  v_label t_identifier;
begin
  v_label := utl_normalize_label(p_label);
  if g_timers.exists(v_label) then
    if utl_logging_enabled (c_info) then
      utl_create_log_entry (
        p_level   => c_info,
        p_message => v_label || ': ' || get_runtime (g_timers(v_label)) );
    end if;
    g_timers.delete(v_label);
  else
    warn('Timer `' || v_label || '` does not exist.');
  end if;
end time_end;

function time_end (
  p_label varchar2 default null )
return varchar2
is
  v_label  t_identifier;
  v_return varchar2(50);
begin
  v_label := utl_normalize_label(p_label);
  if g_timers.exists(v_label) then
    v_return :=  get_runtime(g_timers(v_label));
    g_timers.delete(v_label);
  else
    v_return := 'Timer `' || v_label || '` does not exist.';
  end if;
  return v_return;
end time_end;

--------------------------------------------------------------------------------

procedure clear (
  p_client_identifier varchar2 default my_client_identifier )
is
begin
  null; -- FIXME implement
end;


--------------------------------------------------------------------------------
-- PUBLIC HELPER METHODS
--------------------------------------------------------------------------------

$if $$apex_installed $then

function apex_error_handling (
  p_error in apex_error.t_error )
return apex_error.t_error_result
is
  v_result          apex_error.t_error_result;
  v_reference_id    number;
  v_constraint_name varchar2(255);
  v_message         clob;
  --
  function extract_constraint_name(p_sqlerrm varchar2) return varchar2 is
  begin
    return regexp_substr(p_sqlerrm, '\(\S+?\.(\S+?)\)', 1, 1, 'i', 1);
  end;
  --
  procedure create_apex_lang_message ( p_constraint_name varchar2 ) is
    pragma autonomous_transaction;
  begin
    apex_lang.create_message(
      p_application_id => v('APP_ID'),
      p_name           => p_constraint_name,
      p_language       => apex_util.get_preference('FSP_LANGUAGE_PREFERENCE'),
      p_message_text   => 'FIXME: Create message for constraint ' || p_constraint_name);
    commit;
  end;
  --
begin
  v_result := apex_error.init_error_result (p_error => p_error);

  -- If it's an internal error raised by APEX, like an invalid statement or
  -- code which can't be executed, the error text might contain security sensitive
  -- information. To avoid this security problem we can rewrite the error to
  -- a generic error message and log the original error message for further
  -- investigation by the help desk.
  if p_error.is_internal_error then
    -- mask all errors that are not common runtime errors (Access Denied
    -- errors raised by application / page authorization and all errors
    -- regarding session and session state)
    if not p_error.is_common_runtime_error then
      -- log error for example with an autonomous transaction and return
      -- v_reference_id as reference#
      v_message :=
        case when p_error.message is not null then p_error.message || c_lf end ||
        case when p_error.additional_info is not null then p_error.message || c_lf end ||
        case when p_error.error_statement is not null then p_error.error_statement || c_lf end;
        --FIXME what about other attributes like p_error.component?
      v_reference_id := error (
        p_message         => v_message               ,
        p_trace           => false                   ,
        p_user_error_code => p_error.ora_sqlcode     ,
        p_user_call_stack => p_error.error_backtrace );
      -- Change the message to the generic error message which doesn't expose
      -- any sensitive information.
      v_result.message := 'An unexpected internal application error has occurred. ' ||
                          'Please get in contact with your Oracle APEX support team and provide ' ||
                          'reference# ' || to_char(v_reference_id, '999G999G999G999G990') ||
                          ' for further investigation.';
      v_result.additional_info := null;
    end if;
  else
    -- Always show the error as inline error
    -- Note: If you have created manual tabular forms (using the package
    --       apex_item/htmldb_item in the SQL statement) you should still
    --       use "On error page" on that pages to avoid loosing entered data
    v_result.display_location :=
      case when v_result.display_location = apex_error.c_on_error_page
        then apex_error.c_inline_in_notification
        else v_result.display_location
      end;

    --
    -- Note: If you want to have friendlier ORA error messages, you can also define
    --       a text message with the name pattern APEX.ERROR.ORA-number
    --       There is no need to implement custom code for that.
    --

    -- If it's a constraint violation like
    --
    --   -) ORA-00001: unique constraint violated
    --   -) ORA-02091: transaction rolled back (-> can hide a deferred constraint)
    --   -) ORA-02290: check constraint violated
    --   -) ORA-02291: integrity constraint violated - parent key not found
    --   -) ORA-02292: integrity constraint violated - child record found
    --
    -- we try to get a friendly error message from our constraint lookup configuration.
    -- If we don't find the constraint in our lookup table we fallback to
    -- the original ORA error message.
    if p_error.ora_sqlcode in (-1, -2091, -2290, -2291, -2292) then
      v_constraint_name :=  extract_constraint_name(p_error.ora_sqlerrm);
      v_result.message := apex_lang.message( v_constraint_name );
      if v_result.message = v_constraint_name then
        --Idea by Roel Hartman: https://roelhartman.blogspot.com/2021/02/stop-using-validations-for-checking.html
        create_apex_lang_message (v_constraint_name);
      end if;
    end if;

    -- If an ORA error has been raised, for example a raise_application_error(-20xxx, '...')
    -- in a table trigger or in a PL/SQL package called by a process and we
    -- haven't found the error in our lookup table, then we just want to see
    -- the actual error text and not the full error stack with all the ORA error numbers.
    if p_error.ora_sqlcode is not null and v_result.message = p_error.message then
      v_result.message := apex_error.get_first_ora_error_text (p_error => p_error);
    end if;

    -- If no associated page item/tabular form column has been set, we can use
    -- apex_error.auto_set_associated_item to automatically guess the affected
    -- error field by examine the ORA error for constraint names or column names.
    if v_result.page_item_name is null and v_result.column_alias is null then
      apex_error.auto_set_associated_item (
        p_error        => p_error,
        p_error_result => v_result );
    end if;
  end if;

  return v_result;
end apex_error_handling;

$end

--------------------------------------------------------------------------------

procedure action (
  p_action varchar2 )
is
begin
  dbms_application_info.set_action (
    p_action );
end action;

procedure module (
  p_module varchar2,
  p_action varchar2 default null
)
is
begin
  dbms_application_info.set_module(
    p_module ,
    p_action );
end module;

--------------------------------------------------------------------------------

procedure init (
  p_client_identifier varchar2                ,
  p_log_level         integer  default c_info ,
  p_log_duration      integer  default 60     ,
  p_cache_size        integer  default 0      ,
  p_cache_duration    integer  default 10     ,
  p_user_env          boolean  default false  ,
  p_apex_env          boolean  default false  ,
  p_cgi_env           boolean  default false  ,
  p_console_env       boolean  default false  )
is
  pragma autonomous_transaction;
  v_row         console_sessions%rowtype;
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
      error ( 'Context not available, package var g_conf_context_available tells us it is ?!?' );
  end;
  --
begin
  assert ( p_log_level      in (2, 3, 4),       'Level needs to be 2 (warning), 3 (info) or 4 (verbose). ' ||
                                                'Level 1 (error) and 0 (permanent) are always logged '     ||
                                                'without a call to the init method.'                       );
  assert ( p_log_duration   between 1 and 1440, 'Duration needs to be between 1 and 1440 (minutes).'       );
  assert ( p_cache_size     between 0 and  100, 'Cache size needs to be between 1 and 100 (log entries).'  );
  assert ( p_cache_duration between 1 and   10, 'Cache duration needs to be between 1 and 10 (seconds).'   );
  assert ( p_user_env       is not null,        'User env needs to be true or false (not null).'           );
  assert ( p_apex_env       is not null,        'APEX env needs to be true or false (not null).'           );
  assert ( p_cgi_env        is not null,        'CGI env needs to be true or false (not null).'            );
  assert ( p_console_env    is not null,        'Console env needs to be true or false (not null).'        );
  --
  v_row.client_identifier := substrb ( p_client_identifier, 1, 64 );
  v_row.log_level         := p_log_level;
  v_row.start_date        := localtimestamp;
  v_row.end_date          := localtimestamp + 1/24/60 * p_log_duration;
  v_row.cache_size        := p_cache_size;
  v_row.cache_duration    := p_cache_duration;
  v_row.user_env          := to_yn ( p_user_env    );
  v_row.apex_env          := to_yn ( p_apex_env    );
  v_row.cgi_env           := to_yn ( p_cgi_env     );
  v_row.console_env       := to_yn ( p_console_env );
  --
  select count(*) into v_count from console_sessions where client_identifier = p_client_identifier;
  if v_count = 0 then
    insert into console_sessions values v_row;
  else
    update console_sessions set row = v_row
     where client_identifier = v_row.client_identifier;
  end if;
  commit;
  --
  if g_conf_context_available then
    set_context ( c_ctx_log_level      , to_char ( v_row.log_level      )                     , p_client_identifier );
    set_context ( c_ctx_end_date       , to_char ( v_row.end_date       , c_ctx_date_format ) , p_client_identifier );
    set_context ( c_ctx_cache_size     , to_char ( v_row.cache_size     )                     , p_client_identifier );
    set_context ( c_ctx_cache_duration , to_char ( v_row.cache_duration )                     , p_client_identifier );
    set_context ( c_ctx_user_env       , to_char ( v_row.user_env       )                     , p_client_identifier );
    set_context ( c_ctx_apex_env       , to_char ( v_row.apex_env       )                     , p_client_identifier );
    set_context ( c_ctx_cgi_env        , to_char ( v_row.cgi_env        )                     , p_client_identifier );
    set_context ( c_ctx_console_env    , to_char ( v_row.console_env    )                     , p_client_identifier );
  end if;

  -- If we want to monitor our own session, wee need to load the configuration
  -- data from the context or table into the cache (package variables).
  -- Otherwise we need to wait until the cache duration is over (which defaults
  -- to 10 seconds) and the package reloads the configuration from the context
  -- or table on next call of a public logging method.
  if p_client_identifier = g_conf_client_identifier then
    utl_load_session_configuration;
  end if;
end init;

procedure init (
  p_log_level      integer default c_info ,
  p_log_duration   integer default 60     ,
  p_cache_size     integer default 0      ,
  p_cache_duration integer default 10     ,
  p_user_env       boolean default false  ,
  p_apex_env       boolean default false  ,
  p_cgi_env        boolean default false  ,
  p_console_env    boolean default false  )
is
begin
  init (
    p_client_identifier => g_conf_client_identifier ,
    p_log_level         => p_log_level              ,
    p_log_duration      => p_log_duration           ,
    p_cache_duration    => p_cache_duration         ,
    p_cache_size        => p_cache_size             ,
    p_user_env          => p_user_env               ,
    p_apex_env          => p_apex_env               ,
    p_cgi_env           => p_cgi_env                ,
    p_console_env       => p_console_env            );
end init;

--------------------------------------------------------------------------------

procedure stop (
  p_client_identifier varchar2 default my_client_identifier )
is
  pragma autonomous_transaction;
begin
  delete from console_sessions where client_identifier = p_client_identifier;
  commit;
  utl_clear_context( p_client_identifier );
  -- If we monitor our own session, wee need to load the configuration
  -- data from the context or table into the cache (package variables).
  -- Otherwise we need to wait until the cache duration is over (which defaults
  -- to 10 seconds) and the package reloads the configuration from the context
  -- or table on next call of a public logging method.
  if p_client_identifier = g_conf_client_identifier then
    utl_load_session_configuration;
    utl_flush_log_cache;
  end if;
end;

--------------------------------------------------------------------------------

function context_available_yn return varchar2 is
begin
  return to_yn(g_conf_context_available);
end;

--------------------------------------------------------------------------------

function version return varchar2 is
begin
  return c_version;
end;

--------------------------------------------------------------------------------

function to_html (
  p_data_cursor        sys_refcursor         ,
  p_comment            varchar2 default null ,
  p_max_rows           integer  default 100  ,
  p_max_column_length  integer  default 1000 )
return clob is
  v_data_cursor        sys_refcursor := p_data_cursor;
  v_cursor_id          integer;
  v_clob               clob;
  v_cache              varchar2 (32767 char);
  v_data_count         pls_integer := 0;
  v_col_count          pls_integer;
  v_desc_tab           dbms_sql.desc_tab3;
  v_buffer_varchar2    varchar2(32767 char);
  v_buffer_clob        clob;
  v_buffer_xmltype     xmltype;
  v_buffer_long        long;
  v_buffer_long_length pls_integer;
  --
  procedure close_cursor ( p_cursor_id in out integer ) is
  begin
    if dbms_sql.is_open(p_cursor_id) then
      dbms_sql.close_cursor(p_cursor_id);
    end if;
  exception
    when invalid_cursor then null;
  end close_cursor;
  --
  function escape ( p_text varchar2 ) return varchar2 is
  begin
    return replace(replace(replace(p_text,
      c_ampersand, c_html_ampersand    ),
      '<'        , c_html_less_then    ),
      '>'        , c_html_greater_then );
  end;
  --
  procedure describe_columns is
  begin
    dbms_sql.describe_columns3(v_cursor_id, v_col_count, v_desc_tab);
    for i in 1..v_col_count loop
      if v_desc_tab(i).col_type = c_clob then
        dbms_sql.define_column(v_cursor_id, i, v_buffer_clob);
      elsif v_desc_tab(i).col_type = c_xmltype then
        dbms_sql.define_column(v_cursor_id, i, v_buffer_xmltype);
      elsif v_desc_tab(i).col_type = c_long then
        dbms_sql.define_column_long(v_cursor_id, i);
      elsif v_desc_tab(i).col_type in (c_raw, c_long_raw, c_blob, c_bfile) then
        null; --> we ignore binary data types
      else
        dbms_sql.define_column(v_cursor_id, i, v_buffer_varchar2, p_max_column_length);
      end if;
    end loop;
  end describe_columns;
  --
  procedure create_header is
  begin
    clob_append(v_clob, v_cache, '<tr>' || c_lf);
    for i in 1..v_col_count loop
      clob_append(v_clob, v_cache, '<th id="' || lower(v_desc_tab(i).col_name) || '">'
      || initcap(replace(v_desc_tab(i).col_name, '_', ' ')) || '</th>' || c_lf);
    end loop;
    clob_append(v_clob, v_cache, '</tr>' || c_lf);
  end create_header;
  --
  procedure create_data is
  begin
    loop
      exit when dbms_sql.fetch_rows(v_cursor_id) = 0 or v_data_count = p_max_rows;
      v_data_count := v_data_count + 1;
      clob_append(v_clob, v_cache, '<tr><!-- begin row ' || to_char(v_data_count) || ' -->' || c_lf);

      for i in 1..v_col_count loop
        clob_append(v_clob, v_cache, '<td headers="' || lower(v_desc_tab(i).col_name) || '">');

        if v_desc_tab(i).col_type = c_clob then
          dbms_sql.column_value(v_cursor_id, i, v_buffer_clob);
          clob_append(
            v_clob,
            v_cache,
            escape(substr(v_buffer_clob, 1, p_max_column_length))
            || case when length(v_buffer_clob) > p_max_column_length then '...' end
          );

        elsif v_desc_tab(i).col_type = c_xmltype then
          dbms_sql.column_value(v_cursor_id, i, v_buffer_xmltype);
          if v_buffer_xmltype is not null then
            v_buffer_clob := v_buffer_xmltype.getclobval();
            clob_append(
              v_clob,
              v_cache,
              escape(substr(v_buffer_clob, 1, p_max_column_length))
              || case when length(v_buffer_clob) > p_max_column_length then '...' end
            );
          end if;

        elsif v_desc_tab(i).col_type = c_long then
          dbms_sql.column_value_long(v_cursor_id, i, p_max_column_length, 0, v_buffer_varchar2, v_buffer_long_length);
            clob_append(
              v_clob,
              v_cache,
              escape(v_buffer_varchar2)
              || case when v_buffer_long_length > p_max_column_length then '...' end
            );

        elsif v_desc_tab(i).col_type in (c_raw, c_long_raw, c_blob, c_bfile) then
          clob_append(v_clob, v_cache, 'Binary data type skipped - not supported for HTML');

        else
          dbms_sql.column_value(v_cursor_id, i, v_buffer_varchar2);
          clob_append(v_clob, v_cache, escape(v_buffer_varchar2));
        end if;

        clob_append(v_clob, v_cache, '</td>' || c_lf);
      end loop;

      clob_append(v_clob, v_cache, '</tr><!-- end row ' || to_char(v_data_count) || ' -->' || c_lf);
    end loop;
  end create_data;
  --
begin
  v_cursor_id := dbms_sql.to_cursor_number(v_data_cursor);
  describe_columns;
  if p_comment is not null then
    clob_append(v_clob, v_cache, escape(p_comment) || c_lflf);
  end if;
  clob_append(v_clob, v_cache, '<table>' || c_lf);
  create_header;
  create_data;
  clob_append(v_clob, v_cache, '</table>' || c_lf);
  clob_flush_cache(v_clob, v_cache);
  close_cursor(v_cursor_id);
  return v_clob;
end to_html;

--------------------------------------------------------------------------------

function to_bool (
  p_string varchar2 )
return boolean is
begin
  return
    case when upper(trim(p_string)) in ('Y', 'YES', '1', 'TRUE')
      then true
      else false
    end;
end;

--------------------------------------------------------------------------------

function to_yn (
  p_bool boolean )
return varchar2 is
begin
  return case when p_bool then 'Y' else 'N' end;
end;

--------------------------------------------------------------------------------

function get_runtime ( p_start timestamp ) return varchar2 is
  v_runtime varchar2(32);
begin
  v_runtime := to_char(localtimestamp - p_start);
  return substr(v_runtime, instr(v_runtime,':')-2, 15);
end get_runtime;

--------------------------------------------------------------------------------

function get_runtime_seconds ( p_start timestamp ) return number is
begin
  return extract(second from (localtimestamp - p_start));
end get_runtime_seconds;

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
      v_subprogram := replace (
        utl_call_stack.concatenate_subprogram( utl_call_stack.subprogram(i) ),
        c_anon_block_ora,
        c_anonymous_block);
      --exclude console package from the call stack
      if instr ( upper(v_subprogram), c_console_pkg_name ) = 0 then
        v_return := v_return
          || case when utl_call_stack.owner(i) is not null then utl_call_stack.owner(i) || '.' end
          || v_subprogram || ', line ' || utl_call_stack.unit_line(i)
          || chr(10);
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
    v_return := v_return || '- ERROR STACK' || chr(10);
    for i in 1 .. utl_call_stack.error_depth
    loop
      v_return := v_return
        || '  - ORA-'
        || trim(to_char(utl_call_stack.error_number(i), '00009')) || ' '
        || utl_call_stack.error_msg(i)
        || chr(10);
    end loop;
  end if;

  if utl_call_stack.backtrace_depth > 0 then
    v_return := v_return || '- ERROR BACKTRACE' || chr(10);
    for i in 1 .. utl_call_stack.backtrace_depth
    loop
      v_return := v_return
        || '  - '
        || coalesce( utl_call_stack.backtrace_unit(i), c_anonymous_block )
        || ', line ' || utl_call_stack.backtrace_line(i)
        || chr (10);
    end loop;
  end if;

  if utl_call_stack.dynamic_depth > 0 then
    v_return := v_return || '- CALL STACK' || chr(10);
    --ignore 1, is always this function (get_call_stack) itself
    for i in 2 .. utl_call_stack.dynamic_depth
    loop
      --the replace changes `__anonymous_block` to `anonymous_block`
      v_subprogram := replace(
        utl_call_stack.concatenate_subprogram ( utl_call_stack.subprogram(i) ),
        c_anon_block_ora,
        c_anonymous_block);
      --exclude console package from the call stack
      if instr( upper(v_subprogram), c_console_pkg_name ) = 0 then
        v_return := v_return
          || '  - '
          || case when utl_call_stack.owner(i) is not null then utl_call_stack.owner(i) || '.' end
          || v_subprogram || ', line ' || utl_call_stack.unit_line(i)
          || chr(10);
      end if;
    end loop;
  end if;

  return v_return;
end get_call_stack;

--------------------------------------------------------------------------------

procedure clob_append (
  p_clob  in out nocopy clob     ,
  p_cache in out nocopy varchar2 ,
  p_text  in            varchar2 )
is
begin
  p_cache := p_cache || p_text;
exception
  when value_error then
    if p_clob is null then
      p_clob := p_cache;
    else
      dbms_lob.writeappend(p_clob, length(p_cache), p_cache);
    end if;
    p_cache := p_text;
end clob_append;

--------------------------------------------------------------------------------

procedure clob_flush_cache (
  p_clob  in out nocopy clob     ,
  p_cache in out nocopy varchar2 )
is
begin
  if p_cache is not null then
    if p_clob is null then
      p_clob := p_cache;
    else
      dbms_lob.writeappend(p_clob, length(p_cache), p_cache);
    end if;
    p_cache := null;
  end if;
end clob_flush_cache;


--------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS
--------------------------------------------------------------------------------

function utl_logging_enabled (
  p_level integer )
return boolean is
begin
  if g_conf_cache_valid_until_date < sysdate then
    utl_load_session_configuration;
  end if;
  return g_conf_log_level >= p_level or sqlcode != 0;
end utl_logging_enabled;

--------------------------------------------------------------------------------

function utl_normalize_label (p_label varchar2) return varchar2 is
begin
  return coalesce(substrb(p_label, 1, c_identifier_length), c_default_label);
end;

--------------------------------------------------------------------------------

/* HOW TO CHECK THE RESULT CACHE
select id, name, cache_id, type, status, invalidations, scan_count
  from v$result_cache_objects
 where name like '%CONSOLE%'
   and status != 'Invalid';
*/
function utl_read_row_from_sessions (
  p_client_identifier varchar2 )
return console_sessions%rowtype result_cache is
  v_row console_sessions%rowtype;
begin
  for i in (
    select *
      from console_sessions
     where client_identifier = p_client_identifier
       and end_date >= sysdate)
  loop
    v_row := i;
  end loop;
  return v_row;
end utl_read_row_from_sessions;

--------------------------------------------------------------------------------

procedure utl_check_context_availability is
begin
  sys.dbms_session.set_context(c_ctx_namespace, c_ctx_test_attribute, 'test');
  g_conf_context_available := true;
exception
  when insufficient_privileges then
    g_conf_context_available := false;
end utl_check_context_availability;

--------------------------------------------------------------------------------

procedure utl_clear_all_context is
begin
  if g_conf_context_available then
    sys.dbms_session.clear_all_context(c_ctx_namespace);
  end if;
end utl_clear_all_context;

--------------------------------------------------------------------------------

procedure utl_clear_context (
  p_client_identifier varchar2 )
is
begin
  if g_conf_context_available then
    sys.dbms_session.clear_context(c_ctx_namespace, p_client_identifier);
  end if;
end utl_clear_context;

--------------------------------------------------------------------------------

procedure utl_flush_log_cache is
begin
  null; --FIXME implement
end;

--------------------------------------------------------------------------------

procedure utl_load_session_configuration is
  v_row console_sessions%rowtype;
begin
  if g_conf_context_available then
    g_conf_end_date       := to_date   ( sys_context ( c_ctx_namespace, c_ctx_end_date       ) , c_ctx_date_format );
    g_conf_log_level      := to_number ( sys_context ( c_ctx_namespace, c_ctx_log_level      ) );
    g_conf_cache_size     := to_number ( sys_context ( c_ctx_namespace, c_ctx_cache_size     ) );
    g_conf_cache_duration := to_number ( sys_context ( c_ctx_namespace, c_ctx_cache_duration ) );
    g_conf_user_env       := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_user_env       ) );
    g_conf_apex_env       := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_apex_env       ) );
    g_conf_cgi_env        := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_cgi_env        ) );
    g_conf_console_env    := to_bool   ( sys_context ( c_ctx_namespace, c_ctx_console_env    ) );
  else
    v_row := utl_read_row_from_sessions (g_conf_client_identifier);
    --
    g_conf_end_date       :=           v_row.end_date        ;
    g_conf_log_level      :=           v_row.log_level       ;
    g_conf_cache_size     :=           v_row.cache_size      ;
    g_conf_cache_duration :=           v_row.cache_duration  ;
    g_conf_user_env       := to_bool ( v_row.user_env       );
    g_conf_apex_env       := to_bool ( v_row.apex_env       );
    g_conf_cgi_env        := to_bool ( v_row.cgi_env        );
    g_conf_console_env    := to_bool ( v_row.console_env    );
  end if;

  --handle nulls
  if g_conf_end_date is null then
     --We have no real conf until now, so we fake 24 hours.
     --Conf will be rechecked at least every 10 seconds.
    g_conf_end_date := sysdate + 1;
  elsif g_conf_end_date < sysdate then
    utl_clear_context(g_conf_client_identifier);
  end if;
  g_conf_cache_valid_until_date := least(g_conf_end_date, sysdate + 1/24/60/60*10);
  --
  if g_conf_log_level is null then
    g_conf_log_level := 1;
  end if;
  --
  if g_conf_cache_size is null then
    g_conf_cache_size := 0;
  end if;
  --
  if g_conf_cache_duration is null then
    g_conf_cache_duration := 10;
  end if;

end utl_load_session_configuration;

--------------------------------------------------------------------------------

procedure utl_set_client_identifier is
begin
  g_conf_client_identifier := sys_context('USERENV', 'CLIENT_IDENTIFIER');
  if g_conf_client_identifier is null or g_conf_client_identifier = ':' then
    g_conf_client_identifier := c_client_id_prefix || dbms_session.unique_session_id;
    dbms_session.set_identifier(g_conf_client_identifier);
  end if;
end utl_set_client_identifier;

--------------------------------------------------------------------------------

function utl_create_log_entry (
  p_level           integer                ,
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
return integer
is
  pragma autonomous_transaction;
  v_row           console_logs%rowtype;
  v_message_cache varchar2(32767);
begin
  v_row.scope :=
    case
      when p_user_scope is not null then substrb(p_user_scope, 1, 256)
      else substrb(get_scope, 1, 256)
    end;

  -- This is the very first (possible) assignment to the message row variable,
  -- so we can do it without our message_append method, especially as we might
  -- have a clob in the parameter p_message. Doing it this way we do not need a
  -- message_append method which can work with a clob.
  v_row.message :=
    case
      when p_message is not null then p_message
      when sqlcode != 0 then sqlerrm
      else null
    end;

  v_row.error_code :=
    case
      when p_user_error_code is not null then p_user_error_code
      when sqlcode != 0 then sqlcode
      else null
    end;

  v_row.call_stack :=
    case
      when p_user_call_stack is not null then substrb(p_user_call_stack, 1, 4000)
      when p_trace then substrb(get_call_stack, 1, 4000)
      else null
    end;

  if p_apex_env then
    null; --FIXME implement
  end if;

  if p_cgi_env then
    null; --FIXME implement
  end if;

  if p_console_env then
    null; --FIXME implement
  end if;

  if p_user_env then
    null; --FIXME implement
  end if;

  v_row.log_level         := p_level;
  v_row.session_user      := substrb ( sys_context ( 'USERENV', 'SESSION_USER'      ), 1, 32 );
  v_row.module            := substrb ( sys_context ( 'USERENV', 'MODULE'            ), 1, 48 );
  v_row.action            := substrb ( sys_context ( 'USERENV', 'ACTION'            ), 1, 32 );
  v_row.client_info       := substrb ( sys_context ( 'USERENV', 'CLIENT_INFO'       ), 1, 64 );
  v_row.client_identifier := substrb ( sys_context ( 'USERENV', 'CLIENT_IDENTIFIER' ), 1, 64 );
  v_row.ip_address        := substrb ( sys_context ( 'USERENV', 'IP_ADDRESS'        ), 1, 48 );
  v_row.host              := substrb ( sys_context ( 'USERENV', 'HOST'              ), 1, 64 );
  v_row.os_user           := substrb ( sys_context ( 'USERENV', 'OS_USER'           ), 1, 64 );
  v_row.os_user_agent     := substrb ( p_user_agent, 1, 200 );
  v_row.log_time          := systimestamp;

  insert into console_logs values v_row returning log_id into v_row.log_id;
  commit;

  return v_row.log_id;
end utl_create_log_entry;

procedure utl_create_log_entry (
  p_level           integer                ,
  p_message         clob     default null  ,
  p_trace           boolean  default false ,
  p_apex_env        boolean  default false ,
  p_cgi_env         boolean  default false ,
  p_console_env     boolean  default false ,
  p_user_env        boolean  default false ,
  p_user_agent      varchar2 default null  ,
  p_user_scope      varchar2 default null  ,
  p_user_error_code integer  default null  ,
  p_user_call_stack varchar2 default null  )
is
  v_log_id integer;
begin
  v_log_id := utl_create_log_entry (
    p_level           => p_level           ,
    p_message         => p_message         ,
    p_trace           => p_trace           ,
    p_apex_env        => p_apex_env        ,
    p_cgi_env         => p_cgi_env         ,
    p_console_env     => p_console_env     ,
    p_user_env        => p_user_env        ,
    p_user_agent      => p_user_agent      ,
    p_user_scope      => p_user_scope      ,
    p_user_error_code => p_user_error_code ,
    p_user_call_stack => p_user_call_stack );
end;

--------------------------------------------------------------------------------

--package inizialization
begin
  utl_set_client_identifier;
  utl_check_context_availability;
  utl_load_session_configuration;
end console;
/
