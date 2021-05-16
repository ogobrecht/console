declare
  v_count pls_integer;
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_GLOBAL_CONF';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_GLOBAL_CONF not found, run creation command');
    execute immediate q'{
      create table console_global_conf (
        conf_id              varchar2 (  16 byte)  not null  ,
        conf_by              varchar2 (  64 byte)            ,
        conf_sysdate         date                  not null  ,
        level_id             number   (   1,0)     not null  ,
        level_name           varchar2 (  10 byte)  not null  ,
        check_interval       number   (   2,0)     not null  ,
        units_level_warning  varchar2 (4000 byte)            ,
        units_level_info     varchar2 (4000 byte)            ,
        units_level_debug    varchar2 (4000 byte)            ,
        units_level_trace    varchar2 (4000 byte)            ,
        enable_ascii_art     varchar2 (   1 byte)  not null  ,
        --
        constraint  console_global_conf_pk   primary key ( conf_id )                                                                          ,
        constraint  console_global_conf_ck1  check ( conf_id = 'GLOBAL_CONF' )                                                                ,
        constraint  console_global_conf_ck2  check ( level_id in (1, 2, 3, 4, 5) )                                                            ,
        constraint  console_global_conf_ck3  check ( level_name = decode(level_id, 1,'error', 2,'warning', 3,'info', 4,'debug', 5,'trace') )  ,
        constraint  console_global_conf_ck4  check ( check_interval between 10 and 60 )                                                       ,
        constraint  console_global_conf_ck5  check ( enable_ascii_art in ('Y','N') )
      )
    }';
  else
    dbms_output.put_line('- Table CONSOLE_GLOBAL_CONF found, no action required');
  end if;

end;
/

comment on table  console_global_conf                     is 'Holds the global console configuration in a single record.';
comment on column console_global_conf.conf_id             is 'The primary key - is secured by a check constraint which allows only one record in the table.';
comment on column console_global_conf.conf_by             is 'The user who configured the console the last time.';
comment on column console_global_conf.conf_sysdate        is 'The date when the console was configured the last time.';
comment on column console_global_conf.level_id            is 'The defined global log level ID.';
comment on column console_global_conf.level_name          is 'The defined log level name.';
comment on column console_global_conf.check_interval      is 'The number of seconds a session looks for a changed configuration.';
comment on column console_global_conf.units_level_warning is 'A comma separated list of units configured for level warning.';
comment on column console_global_conf.units_level_info    is 'A comma separated list of units configured for level info.';
comment on column console_global_conf.units_level_debug   is 'A comma separated list of units configured for level debug.';
comment on column console_global_conf.units_level_trace   is 'A comma separated list of units configured for level trace.';
comment on column console_global_conf.enable_ascii_art    is 'Currently used to have more fun with the APEX error handling messages. But who knows...';


