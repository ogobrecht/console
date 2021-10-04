declare
  v_count pls_integer;
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count = 0 then
    begin
      -- without execute immediate this script will raise an error when the package console is not valid
      select count(*) into v_count from user_scheduler_jobs where job_name = 'CONSOLE_PURGE';
      if v_count = 0 then
        dbms_output.put_line('- Job CONSOLE_PURGE not found, run creation command with the defaults (purge entries of level info after 30 days)');
        execute immediate 'begin console.purge_job_create; end;';
      else
        dbms_output.put_line('- Job CONSOLE_PURGE found, no action required');
      end if;
    exception
      when others then
        dbms_output.put_line('A T T E N T I O N  -  A N  E R R O R  O C C U R E D');
        dbms_output.put_line('- Unable to check/create the purge job. You can purge old log entries with the procedures console.purge and purge_all by yourself.');
        dbms_output.put_line('- You can also try to create the purge job by youself with this code: begin console.purge_job_create; end;');
        dbms_output.put_line('- The oracle error on check/create the purge job was: ' || sqlerrm);
    end;
  end if;
end;
/

