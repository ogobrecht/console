declare
  v_count pls_integer;
begin
  select count(*) into v_count from user_tables where table_name = 'CONSOLE_CONSTRAINT_MESSAGES';
  if v_count = 0 then
    dbms_output.put_line('- Table CONSOLE_CONSTRAINT_MESSAGES not found, run creation command');
    execute immediate q'{
      create table console_constraint_messages (
        constraint_name  varchar2 (128 byte)  not null  ,
        message          varchar2 (512 byte)  not null  ,
        --
        constraint console_constraint_messages_pk primary key (constraint_name)
      ) organization index
    }';
  else
    dbms_output.put_line('- Table CONSOLE_CONSTRAINT_MESSAGES found, no action required');
  end if;
end;
/

comment on table  console_constraint_messages                 is 'Lookup user friendly error messages for your constraints.';
comment on column console_constraint_messages.constraint_name is 'Name of the constraint, primary key.';
comment on column console_constraint_messages.message         is 'Your friendly error message, when the constraint is violated.';



