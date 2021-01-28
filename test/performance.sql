set serveroutput on verify off feedback off

--configure logger
exec logger.set_level(logger.g_error);

--warm up logger and console
begin
  for i in 1 .. 10 loop
    logger.log ('test');
    console.log ('test');
  end loop;
end;
/

prompt 100.000 LOG CALLS IN LEVEL ERROR (how many time you loose by do nothing)
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
prompt TIMESTAMP VERSUS DATE - 100.000 CALLS
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

prompt
prompt DATE VERSUS GET_TIME - 100.000 CALLS
declare
  v_iterator pls_integer := 100000;
  v_start    timestamp;
  v_end_date date        := sysdate               + 1/24/60*10;
  v_end_time pls_integer := dbms_utility.get_time + 100 * 10; /* current time + 10 seconds */
  v_rt_date  number;
  v_rt_time  number;
  function get_runtime (p_start timestamp) return number is begin return extract(second from (localtimestamp - p_start)); end;
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if sysdate <= v_end_date then null; end if;
  end loop;
  v_rt_date := get_runtime(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if dbms_utility.get_time <= v_end_time then null; end if;
  end loop;
  v_rt_time := get_runtime(v_start);
  --
  dbms_output.put_line( '- date        : ' || trim(to_char(v_rt_date, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- get_time    : ' || trim(to_char(v_rt_time, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- factor      : ' || trim(to_char(v_rt_date/v_rt_time, '0.0')));
end;
/

prompt
prompt BOOLEAN VERSUS INTEGER - 100.000 CALLS
declare
  v_iterator pls_integer := 100000;
  v_start    timestamp;
  v_boolean  boolean     := true;
  v_integer  pls_integer := 1;
  v_rt_bool  number;
  v_rt_int   number;
  function get_runtime (p_start timestamp) return number is begin return extract(second from (localtimestamp - p_start)); end;
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if v_boolean then null; end if;
  end loop;
  v_rt_bool := get_runtime(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if v_integer = 1 then null; end if;
  end loop;
  v_rt_int := get_runtime(v_start);
  --
  dbms_output.put_line( '- boolean     : ' || trim(to_char(v_rt_bool, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- integer     : ' || trim(to_char(v_rt_int, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- factor      : ' || trim(to_char(v_rt_bool/v_rt_int, '0.0')));
end;
/