prompt
declare
  v_count           pls_integer;
  v_console_version varchar2(10 byte);
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count = 0 then
    -- without execute immediate this script will raise an error when the package console is not valid
    execute immediate 'select console.version from dual' into v_console_version;
    execute immediate q'[begin console.permanent('{o,o} CONSOLE v]' || v_console_version || q'[ installed'); end;]';
    dbms_output.put_line('>           ');
    dbms_output.put_line('>   .___.   ');
    dbms_output.put_line('>   {o,o}   ');
    dbms_output.put_line('>   /)__)   Hopefully you have now sharper debugging eyes with');
    dbms_output.put_line('>   -"-"-   CONSOLE v' || v_console_version);
    dbms_output.put_line('>           ');
  end if;
end;
/
prompt


