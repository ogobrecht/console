declare
  v_count pls_integer;
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_CONF';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_CONF not found, run creation command');
    execute immediate q'{
      create table console_conf (
        conf_id           varchar2 (16 byte)  not null  ,
        conf_by           varchar2 (64 byte)            ,
        conf_sysdate      date                not null  ,
        level_id          number   ( 1,0)     not null  ,
        level_name        varchar2 (10 byte)  not null  ,
        check_interval    number   ( 2,0)     not null  ,
        --
        constraint  console_conf_pk   primary key ( conf_id                 )  ,
        constraint  console_conf_ck1  check       ( conf_id = 'GLOBAL_CONF' )  ,
        --
        constraint  console_conf_ck2  check ( level_id   in (1, 2, 3)                                          )  ,
        constraint  console_conf_ck3  check ( level_name =  decode(level_id, 1,'error', 2,'warning', 3,'info') )  ,
        --
        constraint  console_conf_ck4  check ( check_interval between 10 and 60 )
      ) organization index
    }';
  else
    dbms_output.put_line('- Table CONSOLE_CONF found, no action required');
  end if;

end;
/

comment on table  console_conf                is 'Holds the global console configuration in a single record.';
comment on column console_conf.conf_id        is 'The primary key - is secured by a check constraint which allows only one record in the table.';
comment on column console_conf.conf_by        is 'The user who configured the console the last time.';
comment on column console_conf.conf_sysdate   is 'The date when the console was configured the last time.';
comment on column console_conf.level_id       is 'The defined global log level ID.';
comment on column console_conf.level_name     is 'The defined log level name.';
comment on column console_conf.check_interval is 'The number of seconds a session looks for a changed configuration.';


