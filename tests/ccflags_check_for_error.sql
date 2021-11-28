declare
  v_count pls_integer;
begin
  select count(*)
    into v_count
    from user_objects
   where status = 'INVALID'
     and object_name = 'CONSOLE';

  if v_count > 0 then
    dbms_output.put_line('C O N S O L E  H A S  E R R O R S');
    for i in (
      select '- ' || rpad(type, 13, ' ') || ' ' || lpad(line, 4, ' ') || ':' || lpad(position, 3, ' ') || '  ' || text as message
        from user_errors
       where name = 'CONSOLE'
       order by type, sequence )
    loop
      dbms_output.put_line(i.message);
    end loop;
    raise_application_error(-20999, 'CONSOLE has errors');
  end if;
end;
/

column "Name"      format a15
column "Line,Col"  format a10
column "Type"      format a10
column "Message"   format a80

select name || case when type like '%BODY' then ' body' end as "Name",
       line || ',' || position as "Line,Col",
       attribute               as "Type",
       text                    as "Message"
  from user_errors
 where name = 'CONSOLE'
 order by name, line, position;