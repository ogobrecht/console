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

prompt
prompt 100.000 LOG CALLS IN LEVEL ERROR (how many time you loose by do nothing)
declare
  v_iterator   pls_integer := 100000;
  v_start      timestamp;
  v_rt_null    number;
  v_rt_logger  number;
  v_rt_console number;
begin
  --v_start := localtimestamp;
  --for i in 1 .. v_iterator loop
  --  null;
  --end loop;
  --v_rt_null := console.get_runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    logger.log('test');
  end loop;
  v_rt_logger := console.get_runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    console.log('test');
  end loop;
  v_rt_console := console.get_runtime_seconds(v_start);
  --
  --dbms_output.put_line( '- empty loop  : ' || trim(to_char(v_rt_null,    '0.000000')) || ' seconds (it does not really matter)' );
  dbms_output.put_line( '- logger.log  : ' || trim(to_char(v_rt_logger,  '0.000000')) || ' seconds' );
  dbms_output.put_line( '- console.log : ' || trim(to_char(v_rt_console, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- factor      : ' || trim(to_char(v_rt_logger/v_rt_console, '90.0')));
end;
/

--configure logger
exec logger.set_level(logger.g_debug);

--configure console
exec console.init;

--warm up logger and console
begin
  for i in 1 .. 10 loop
    logger.log ('test');
    console.log ('test');
  end loop;
end;
/

prompt
prompt 1000 LOG CALLS IN LEVEL INFO (how many time you loose by do logging)
declare
  v_iterator   pls_integer := 1000;
  v_start      timestamp;
  v_rt_logger  number;
  v_rt_console number;
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    logger.log('test');
  end loop;
  v_rt_logger := console.get_runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    console.log('test');
  end loop;
  v_rt_console := console.get_runtime_seconds(v_start);
  --
  dbms_output.put_line( '- logger.log  : ' || trim(to_char(v_rt_logger,  '0.000000')) || ' seconds' );
  dbms_output.put_line( '- console.log : ' || trim(to_char(v_rt_console, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- factor      : ' || trim(to_char(v_rt_logger/v_rt_console, '90.0')));
end;
/

prompt
prompt TIMESTAMP > DATE - 100.000 CALLS
declare
  v_iterator pls_integer := 100000;
  v_start    timestamp;
  v_end_time timestamp   := systimestamp + 1/24/60*10;
  v_end_date date        := sysdate      + 1/24/60*10;
  v_rt_time  number;
  v_rt_date  number;
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if systimestamp <= v_end_time then null; end if;
  end loop;
  v_rt_time := console.get_runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if sysdate <= v_end_date then null; end if;
  end loop;
  v_rt_date := console.get_runtime_seconds(v_start);
  --
  dbms_output.put_line( '- timestamp   : ' || trim(to_char(v_rt_time, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- date        : ' || trim(to_char(v_rt_date, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- factor      : ' || trim(to_char(v_rt_time/v_rt_date, '90.0')));
end;
/

prompt
prompt DATE > GET_TIME - 100.000 CALLS
declare
  v_iterator pls_integer := 100000;
  v_start    timestamp;
  v_end_date date        := sysdate               + 1/24/60*10;
  v_end_time pls_integer := dbms_utility.get_time + 100 * 10; /* current time + 10 seconds */
  v_rt_date  number;
  v_rt_time  number;
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if sysdate <= v_end_date then null; end if;
  end loop;
  v_rt_date := console.get_runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if dbms_utility.get_time <= v_end_time then null; end if;
  end loop;
  v_rt_time := console.get_runtime_seconds(v_start);
  --
  dbms_output.put_line( '- date        : ' || trim(to_char(v_rt_date, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- get_time    : ' || trim(to_char(v_rt_time, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- factor      : ' || trim(to_char(v_rt_date/v_rt_time, '90.0')));
end;
/

prompt
prompt BOOLEAN > INTEGER - 100.000 CALLS
declare
  v_iterator pls_integer := 100000;
  v_start    timestamp;
  v_boolean  boolean     := true;
  v_integer  pls_integer := 1;
  v_rt_bool  number;
  v_rt_int   number;
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if v_boolean then null; end if;
  end loop;
  v_rt_bool := console.get_runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    if v_integer = 1 then null; end if;
  end loop;
  v_rt_int := console.get_runtime_seconds(v_start);
  --
  dbms_output.put_line( '- boolean     : ' || trim(to_char(v_rt_bool, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- integer     : ' || trim(to_char(v_rt_int, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- factor      : ' || trim(to_char(v_rt_bool/v_rt_int, '90.0')));
end;
/

prompt
prompt RUNTIME: REGEX > EXTRACT > SUBSTR - 100.000 CALLS
declare
  v_iterator   pls_integer := 100000;
  v_start      timestamp;
  v_temp       varchar2(20);
  v_rt_extract number;
  v_rt_regex   number;
  v_rt_substr  number;
  --
  function util_runtime_regex (p_start timestamp) return varchar2 is
  begin
    return regexp_substr(to_char(localtimestamp - p_start), '\d{2}:\d{2}:\d{2}\.\d{6}');
  end util_runtime_regex;
  --
  function util_runtime_extract (p_start timestamp) return varchar2 is
    v_runtime interval day to second (6);
  begin
    v_runtime := localtimestamp - p_start;
    return
      trim(to_char(extract(hour   from v_runtime), '00'       )) || ':' ||
      trim(to_char(extract(minute from v_runtime), '00'       )) || ':' ||
      trim(to_char(extract(second from v_runtime), '00D000000')) ;
  end util_runtime_extract;
  --
  function util_runtime_substr (p_start timestamp) return varchar2 is
    v_runtime varchar2(32);
  begin
    v_runtime := to_char(localtimestamp - p_start);
    return substr(v_runtime, instr(v_runtime,':')-2, 15);
  end util_runtime_substr;
  --
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    v_temp := util_runtime_regex(v_start);
  end loop;
  v_rt_regex := console.get_runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    v_temp := util_runtime_extract(v_start);
  end loop;
  v_rt_extract := console.get_runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    v_temp := util_runtime_substr(v_start);
  end loop;
  v_rt_substr := console.get_runtime_seconds(v_start);
  --
  dbms_output.put_line( '- regex       : ' || trim(to_char(v_rt_regex,   '0.000000')) || ' seconds' );
  dbms_output.put_line( '- exract      : ' || trim(to_char(v_rt_extract, '0.000000')) || ' seconds' );
  dbms_output.put_line( '- substr      : ' || trim(to_char(v_rt_substr,  '0.000000')) || ' seconds' );
  dbms_output.put_line( '- factor r/s  : ' || trim(to_char(v_rt_regex/v_rt_substr, '90.0')));
  dbms_output.put_line( '- factor e/s  : ' || trim(to_char(v_rt_extract/v_rt_substr, '90.0')));
end;
/