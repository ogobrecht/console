declare
  v_count pls_integer;
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_LEVELS';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_LEVELS not found, run creation command');
    execute immediate q'{
      create table console_levels (
        id    number   (1,0)      not null  ,
        name  varchar2 (10 byte)  not null  ,
        --
        constraint console_levels_pk primary key (id)                  ,
        constraint console_levels_uk unique      (name)                ,
        constraint console_levels_ck check       (id in (0,1,2,3,4))
      )
    }';
  else
    dbms_output.put_line('- Table CONSOLE_LEVELS found, no action required');
  end if;
end;
/

--will not run, when called in the same block as the table creation
declare
  v_count pls_integer;
begin
  select count(*) into v_count from console_levels;
  if v_count = 0 then
    insert into console_levels (id, name) values (0, 'Permanent');
    insert into console_levels (id, name) values (1, 'Error');
    insert into console_levels (id, name) values (2, 'Warning');
    insert into console_levels (id, name) values (3, 'Info');
    insert into console_levels (id, name) values (4, 'Verbose');
    commit;
  end if;
end;
/

comment on table  console_levels      is 'Catalog table for the log levels.';
comment on column console_levels.id   is 'ID of the level, primary key, manual managed.';
comment on column console_levels.name is 'Name of the level.';



