declare
  v_count pls_integer;
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_CLIENT_PREFS';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_CLIENT_PREFS not found, run creation command');
    execute immediate q'{
      create table console_client_prefs (
        client_identifier varchar2 (64 byte)  not null  ,
        init_by           varchar2 (64 byte)            ,
        init_sysdate      date                not null  ,
        exit_sysdate      date                not null  ,
        level_id          number   ( 1,0)     not null  ,
        level_name        varchar2 (10 byte)  not null  ,
        cache_size        number   ( 4,0)     not null  ,
        check_interval    number   ( 2,0)     not null  ,
        call_stack        varchar2 ( 1 byte)  not null  ,
        user_env          varchar2 ( 1 byte)  not null  ,
        apex_env          varchar2 ( 1 byte)  not null  ,
        cgi_env           varchar2 ( 1 byte)  not null  ,
        console_env       varchar2 ( 1 byte)  not null  ,
        --
        constraint  console_client_prefs_pk   primary key ( client_identifier          )  ,
        constraint  console_client_prefs_ck1  check       ( call_stack  in ('Y','N')   )  ,
        constraint  console_client_prefs_ck2  check       ( user_env    in ('Y','N')   )  ,
        constraint  console_client_prefs_ck3  check       ( apex_env    in ('Y','N')   )  ,
        constraint  console_client_prefs_ck4  check       ( cgi_env     in ('Y','N')   )  ,
        constraint  console_client_prefs_ck5  check       ( console_env in ('Y','N')   )  ,
        --
        constraint  console_client_prefs_ck6  check       ( level_id   in (1, 2, 3, 4, 5)                                                          )  ,
        constraint  console_client_prefs_ck7  check       ( level_name =  decode(level_id, 1,'error', 2,'warning', 3,'info', 4,'debug', 5,'trace') )  ,
        --
        constraint  console_client_prefs_ck8  check       ( check_interval between 1 and 60 )
      ) organization index
    }';
  else
    dbms_output.put_line('- Table CONSOLE_CLIENT_PREFS found, no action required');
  end if;

end;
/

comment on table  console_client_prefs                   is 'Holds the sessions that are initialized for debugging. Used to manage the global context.';
comment on column console_client_prefs.init_by           is 'The user who initiated the logging.';
comment on column console_client_prefs.init_sysdate      is 'The logging start date for the nominated client identifier.';
comment on column console_client_prefs.exit_sysdate      is 'The planned logging end date for the nominated client identifier.';
comment on column console_client_prefs.client_identifier is 'The client identifier provided by the application or console itself (this is the primary key).';
comment on column console_client_prefs.level_id          is 'The defined log level ID. Any session not listed here has the configured global log level defined in CONSOLE_GLOBAL_CONF.';
comment on column console_client_prefs.level_name        is 'The defined log level name.';
comment on column console_client_prefs.check_interval    is 'The number of seconds a session looks for a changed configuration. Defaults to 10.';
comment on column console_client_prefs.cache_size        is 'The number of log entries to cache before they are written down into the log table. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shared environments like APEX.';
comment on column console_client_prefs.call_stack        is 'Should the call_stack be included.';
comment on column console_client_prefs.user_env          is 'Should the user environment be included.';
comment on column console_client_prefs.apex_env          is 'Should the APEX environment be included.';
comment on column console_client_prefs.cgi_env           is 'Should the CGI environment be included.';
comment on column console_client_prefs.console_env       is 'Should the console environment be included.';



