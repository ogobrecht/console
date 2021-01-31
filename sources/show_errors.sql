-- check for errors in package console and for existing context
declare
  v_count                pls_integer;
  v_context_available_yn varchar2(1 byte);
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count > 0 then
    dbms_output.put_line('- Package CONSOLE has errors :-(');
  else
    execute immediate 'select console.context_available_yn from dual' into v_context_available_yn;
    if v_context_available_yn = 'Y' then
      dbms_output.put_line('- Context available :-)');
    else
      dbms_output.put_line('- CONTEXT NOT AVAILABLE :-(');
      dbms_output.put_line('-  | No worries - you can still start with the instrumentation of your code.');
      dbms_output.put_line('-  | Until you have a context, console uses a table as the config storage for the sessions.');
      dbms_output.put_line('-  | When you (or your DBA) have the context created then simply reconnect and check the availability:');
      dbms_output.put_line('-  | select console.context_available_yn from dual;');
    end if;
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
