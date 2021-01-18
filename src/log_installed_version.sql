prompt - Log the installed console version
declare
  v_count pls_integer;
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count = 0 then
    console.permanent('CONSOLE v' || console.c_version || ' installed');
  end if;
end;
/
