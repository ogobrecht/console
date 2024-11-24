-- check for errors in package console
declare
  procedure check_errors (
    p_object_name in varchar2 )
  is
    v_count pls_integer;
  begin
    select count(*)
      into v_count
      from user_errors
     where name = p_object_name;
    if v_count > 0 then
      dbms_output.put_line('- Type ' || p_object_name || ' has errors :-(');
      for i in (
          select name || case when type like '%BODY' then ' body' end || ', ' ||
                 'line ' || line || ', ' ||
                 'column ' || position || ', ' ||
                 attribute  || ': ' ||
                 text as message
            from user_errors
           where name = p_object_name
           order by name, line, position )
      loop
          dbms_output.put_line('- ' || i.message);
      end loop;
    end if;
  end check_errors;
begin
  check_errors ('CONSOLE');
  check_errors ('T_CONSOLE');
end;
/
