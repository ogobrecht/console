declare
  v_count pls_integer;
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_SESSIONS';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_SESSIONS not found, run creation command');
    execute immediate q'{
      create table console_sessions (
        init_by              varchar2 (64 byte)            ,
        init_sysdate         date                not null  ,
        exit_sysdate         date                not null  ,
        client_identifier    varchar2 (64 byte)  not null  ,
        log_level            number   ( 1,0)     not null  ,
        log_cache_size       number   ( 4,0)     not null  ,
        conf_check_interval  number   ( 2,0)     not null  ,
        call_stack           varchar2 ( 1 byte)  not null  ,
        user_env             varchar2 ( 1 byte)  not null  ,
        apex_env             varchar2 ( 1 byte)  not null  ,
        cgi_env              varchar2 ( 1 byte)  not null  ,
        console_env          varchar2 ( 1 byte)  not null  ,
        --
        constraint  console_sessions_pk   primary key ( client_identifier        )  ,
        constraint  console_sessions_ck1  check       ( log_level in (0,1,2,3,4) )  ,
        constraint  console_sessions_ck2  check       ( call_stack  in ('Y','N') )  ,
        constraint  console_sessions_ck3  check       ( user_env    in ('Y','N') )  ,
        constraint  console_sessions_ck4  check       ( apex_env    in ('Y','N') )  ,
        constraint  console_sessions_ck5  check       ( cgi_env     in ('Y','N') )  ,
        constraint  console_sessions_ck6  check       ( console_env in ('Y','N') )
      ) organization index
    }';
  else
    dbms_output.put_line('- Table CONSOLE_SESSIONS found, no action required');
  end if;

end;
/

comment on table  console_sessions                      is 'Holds the sessions that are initialized for debugging. Used to manage the global context.';
comment on column console_sessions.init_by              is 'The user who initiated the logging.';
comment on column console_sessions.init_sysdate         is 'The logging start date for the nominated client identifier.';
comment on column console_sessions.exit_sysdate         is 'The planned logging end date for the nominated client identifier.';
comment on column console_sessions.client_identifier    is 'The client identifier provided by the application or console itself.';
comment on column console_sessions.log_level            is 'The defined log level. Any session not listed here has the default log level of 1 (error).';
comment on column console_sessions.conf_check_interval  is 'The number of seconds a session in logging mode looks for a changed configuration and flushes the cached log entries. Defaults to 10.';
comment on column console_sessions.log_cache_size       is 'The number of log entries to cache before they are written down into the log table, if not already written by the end of the cache duration. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shered environments like APEX.';
comment on column console_sessions.call_stack           is 'Should the call_stack be included.';
comment on column console_sessions.user_env             is 'Should the user environment be included.';
comment on column console_sessions.apex_env             is 'Should the APEX environment be included.';
comment on column console_sessions.cgi_env              is 'Should the CGI environment be included.';
comment on column console_sessions.console_env          is 'Should the console environment be included.';



