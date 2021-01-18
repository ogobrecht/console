-- check for errors in package console and for existing context
declare
  v_count pls_integer;
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count > 0 then
    dbms_output.put_line('- Package CONSOLE has errors :-(');
  else
    -- check for existing context by init logging for the current session
    begin
      console.init;
      dbms_output.put_line('- Context writeable :-)');
    exception
      when others then
        dbms_output.put_line('- CONTEXT NOT AVAILABLE :-(');
        dbms_output.put_line('-  | No worries - you can still start with the instrumentation of your code.');
        dbms_output.put_line('-  | Errors (level 1) are always logged, also without a context.');
        dbms_output.put_line('-  | You will not be able to set other session in logging modes with level 2 (warning) or higher.');
        dbms_output.put_line('-  | But you will be able to do this for your own session.');
        dbms_output.put_line('-  | When you (or your DBA) have the context created then simply recheck the availability:');
        dbms_output.put_line('-  | select console.context_available_yn from dual;');
    end;
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
