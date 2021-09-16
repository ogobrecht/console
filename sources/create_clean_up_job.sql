declare
  v_count pls_integer;
begin
  select count(*)
    into v_count
    from user_errors
   where name = 'CONSOLE';
  if v_count = 0 then
    -- without execute immediate this script will raise an error when the package console is not valid
    select count(*) into v_count from user_scheduler_jobs where job_name = 'CONSOLE_PURGE';
    if v_count = 0 then
      dbms_output.put_line('- Job CONSOLE_PURGE not found, run creation command with the defaults (purge entries of level info after 30 days)');
      execute immediate 'begin console.purge_job_create; end;';
    else
      dbms_output.put_line('- Job CONSOLE_PURGE found, no action required');
    end if;
  end if;
end;
/

