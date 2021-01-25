set serveroutput on verify off feedback off
exec logger.set_level(logger.g_error);

prompt 100.000 LOG CALLS IN LEVEL ERROR (log only errors)
declare
  v_iterator   pls_integer := 100000;
  v_start      timestamp;
  v_rt_logger  number;
  v_rt_console number;
  function get_runtime (p_start timestamp) return number is begin return extract(second from (localtimestamp - p_start)); end;
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    logger.log('test');
  end loop;
  v_rt_logger := get_runtime(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    console.log('test');
  end loop;
  v_rt_console := get_runtime(v_start);
  --
  dbms_output.put_line( '- logger.log  : ' || trim(to_char(v_rt_logger,  '0.000000')) || ' seconds' );
  dbms_output.put_line( '- console.log : ' || trim(to_char(v_rt_console, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- factor      : ' || trim(to_char(v_rt_logger/v_rt_console, '0.0')));
end;
/

prompt
prompt 100.000 TIME COMPARISONS
declare
  v_iterator pls_integer := 100000;
  v_start    timestamp;
  v_end_time timestamp   := systimestamp + 1/24/60*10;
  v_end_date date        := sysdate      + 1/24/60*10;
  v_rt_time  number;
  v_rt_date  number;
  function get_runtime (p_start timestamp) return number is begin return extract(second from (localtimestamp - p_start)); end;
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if systimestamp <= v_end_time then null; end if;
  end loop;
  v_rt_time := get_runtime(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if sysdate <= v_end_date then null; end if;
  end loop;
  v_rt_date := get_runtime(v_start);
  --
  dbms_output.put_line( '- timestamp   : ' || trim(to_char(v_rt_time, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- date        : ' || trim(to_char(v_rt_date, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- factor      : ' || trim(to_char(v_rt_time/v_rt_date, '0.0')));
end;
/