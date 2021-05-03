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
    execute immediate replace( q'[
      -- We are doing a direct insert to create a log entry independent of the current log level.
      declare
        v_row console_logs%rowtype;
      begin
        v_row.log_systime := systimestamp;
        v_row.level_id    := 3;
        v_row.level_name  := console.get_level_name(3);
        v_row.permanent   := 'Y';
        v_row.scope       := 'Library Installation';
        v_row.message     := '{o,o} CONSOLE v#CONSOLE_VERSION# installed';
        insert into console_logs values v_row;
        commit;
      end;]', '#CONSOLE_VERSION#', v_console_version);
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


