set serveroutput on verify off feedback off

--configure logger and console
exec logger.set_level(logger.g_error);
exec console.conf(p_level => console.c_level_error, p_check_interval => 10);
--exec console.conf(p_level => console.c_level_error, p_check_interval => 10, p_units_level_info => 'PLAYGROUND_DATA.SOME_API');

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
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    null;
  end loop;
  v_rt_null := console.runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    logger.log('test');
  end loop;
  v_rt_logger := console.runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    console.log('test');
  end loop;
  v_rt_console := console.runtime_seconds(v_start);
  --
  console.printf( '- empty loop     : %s seconds  (it does not really matter)' , trim(to_char(v_rt_null,    '0.000000'))         );
  console.printf( '- logger.log     : %s seconds '                             , trim(to_char(v_rt_logger,  '0.000000'))         );
  console.printf( '- console.log    : %s seconds '                             , trim(to_char(v_rt_console, '0.000000'))         );
  console.printf( '- factor         : %s'                                      , trim(to_char(v_rt_logger/v_rt_console, '90.0')) );
end;
/

prompt
prompt 100.000 COUNT CALLS IN LEVEL ERROR (how many time you loose by counting)
declare
  v_iterator pls_integer := 100000;
  v_start    timestamp;
  v_rt_log   number;
  v_rt_count number;
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    console.log('test');
  end loop;
  v_rt_log := console.runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    console.count('test');
  end loop;
  v_rt_count := console.runtime_seconds(v_start);
  console.printf( '- count result   : %s'         , (to_char(console.count_end('test')))       );
  console.printf( '- console.log    : %s seconds' , trim(to_char(v_rt_log,   '0.000000'))      );
  console.printf( '- console.count  : %s seconds' , trim(to_char(v_rt_count, '0.000000'))      );
  console.printf( '- factor         : %s'         , trim(to_char(v_rt_log/v_rt_count, '90.0')) );
end;
/

prompt
prompt 100.000 TIME CALLS IN LEVEL ERROR (how many time you loose by measuring time)
declare
  v_iterator pls_integer := 100000;
  v_start    timestamp;
  v_rt_log   number;
  v_rt_time  number;
  v_result   varchar2(100);
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    console.log('test');
  end loop;
  v_rt_log := console.runtime_seconds(v_start);
  --
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    console.time('test');
  end loop;
  v_rt_time := console.runtime_seconds(v_start);
  console.printf( '- console.log    : %s seconds' , trim(to_char(v_rt_log,  '0.000000'))      );
  console.printf( '- console.time   : %s seconds' , trim(to_char(v_rt_time, '0.000000'))      );
  console.printf( '- factor         : %s'         , trim(to_char(v_rt_log/v_rt_time, '90.0')) );
end;
/

prompt
prompt 1.000 LOG CALLS IN LEVEL INFO (how many time you loose by do logging)
declare
  v_iterator   pls_integer := 1000;
  v_start      timestamp;
  v_scope      varchar2(1000);
  v_rt_logger  number;
  v_rt_console number;
begin
  --configure and warm up logger and console
  logger.set_level(logger.g_debug);
  console.init(
    p_level          => console.c_level_info ,
    p_duration       => 90                   ,
    p_cache_size     => 0                    ,
    p_check_interval => 30                   );
  for i in 1 .. 10 loop
    logger.log ('warm up ' || to_char(i));
    console.log ('warm up ' || to_char(i));
  end loop;
  -- test logger
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    logger.log('test ' || to_char(i), p_extra => 'Test performance with clob column used');
  end loop;
  v_rt_logger := console.runtime_seconds(v_start);
  -- test console
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    console.log('test ' || to_char(i));
  end loop;
  console.flush_cache;
  v_rt_console := console.runtime_seconds(v_start);
  -- print results
  console.printf( '- logger.log     : %s seconds' , trim(to_char(v_rt_logger,  '0.000000'))         );
  console.printf( '- console.log    : %s seconds' , trim(to_char(v_rt_console, '0.000000'))         );
  console.printf( '- factor         : %s'         , trim(to_char(v_rt_logger/v_rt_console, '90.0')) );
  --configure logger and console
  logger.set_level(logger.g_error);
  console.exit;
end;
/

prompt
prompt 1.000 FORMAT CALLS (how many time you loose by formatting strings)
declare
  v_iterator   pls_integer := 1000;
  v_start      timestamp;
  v_rt_logger  number;
  v_rt_console number;
  v_test       varchar2 (1000);
begin
  -- test logger
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    v_test := logger.sprintf('Lorem ipsum %s1. Must be %s2, %s3, %s4 or test', 1, 2, 3, 4, 5, 6, 7, 8, 9);
  end loop;
  v_rt_logger := console.runtime_seconds(v_start);
  -- test console
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    v_test := console.format('Lorem ipsum %0. Must be %1, %2, %3 or test', 0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
  end loop;
  v_rt_console := console.runtime_seconds(v_start);
  -- print results
  console.printf( '- logger.sprintf : %s seconds' , trim(to_char(v_rt_logger,  '0.000000'))         );
  console.printf( '- console.format : %s seconds' , trim(to_char(v_rt_console, '0.000000'))         );
  console.printf( '- factor         : %s'         , trim(to_char(v_rt_logger/v_rt_console, '90.0')) );
end;
/

prompt
prompt 1.000 SCOPE CALLS (how many time you loose by fetching the scope from the call stack)
declare
  v_iterator pls_integer := 1000;
  v_start    timestamp;
  v_scope    varchar2(1000);
  v_rt       number;
begin
  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    v_scope := console.scope;
  end loop;
  v_rt := console.runtime_seconds(v_start);
  --
  console.printf( '- scope          : %s seconds', trim(to_char(v_rt, '0.000000')));
end;
/

prompt
prompt RUNTIME: EXTRACT CLIENT PREFS OUT OF 4000 BYTE - REGEX > SUBSTR COMPARISON
declare
  v_iterator   pls_integer := 1; --try also 10, 100, 1000, 10000, 100000
  v_start      timestamp;
  v_temp       console.t_32kb;
  v_rt_regex   number;
  v_rt_substr  number;
  v_start_pos  pls_integer;
  v_stop_pos   pls_integer;
  v_haystack   console.t_4kb;
  v_needle     console.t_64b := '{o,o} 88217AE40002';
begin
  -- build the haystack of around 4000 byte
  select listagg('{o,o} '||lpad(level,2,'0')||'217AE40002,3,0,0,10,210927083239', chr(10))
    into v_haystack
    from dual
    connect by level <= 95; --try also smaller sizes like 5 or 10

  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    v_temp := regexp_substr(v_haystack,'^'||v_needle||',.*$', 1, 1, 'im');
  end loop;
  v_rt_regex := console.runtime_seconds(v_start);
  console.printf( '- regex result   : %s', v_temp );

  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    v_haystack := replace(v_haystack, chr(13), chr(10));
    v_start_pos := instr(v_haystack, v_needle||',');
    v_stop_pos  := instr(v_haystack, chr(10), v_start_pos);
    v_temp      := substr(v_haystack, v_start_pos, v_stop_pos - v_start_pos);
  end loop;
  v_rt_substr := console.runtime_seconds(v_start);
  console.printf( '- substr result  : %s', v_temp );

  console.printf( '- regex          : %s seconds' , trim(to_char(v_rt_regex,   '0.000000'))         );
  console.printf( '- substr         : %s seconds' , trim(to_char(v_rt_substr,  '0.000000'))         );
  console.printf( '- factor r/s     : %s'         , trim(to_char(v_rt_regex/v_rt_substr, '90.0'))   );

end;
/

--prompt
--prompt 1.000 INIT PACKAGE CALLS
--declare
--  v_iterator   pls_integer := 1000;
--  v_start      timestamp;
--  v_rt         number;
--  v_result     varchar2(100);
--  v_log_cache  console.t_logs_tab;
--begin
--  v_start := localtimestamp;
--  for i in 1 .. v_iterator loop
--    v_log_cache := new console.t_logs_tab();
--    console.utl_set_client_identifier;
--    console.utl_set_session_conf;
--  end loop;
--  v_rt := console.runtime_seconds(v_start);
--  console.printf( '- runtime all    : %s seconds', trim(to_char(v_rt,      '0.000000000')));
--  console.printf( '- per call       : %s seconds', trim(to_char(v_rt/1000, '0.000000000')));
--end;
--/

--prompt
--prompt TIMESTAMP > DATE - 100.000 CALLS
--declare
--  v_iterator pls_integer := 100000;
--  v_start    timestamp;
--  v_end_time timestamp   := systimestamp + 1/24/60*10;
--  v_end_date date        := sysdate      + 1/24/60*10;
--  v_rt_time  number;
--  v_rt_date  number;
--begin
--  v_start := localtimestamp;
--  for i in 1 .. v_iterator loop
--    if systimestamp <= v_end_time then null; end if;
--  end loop;
--  v_rt_time := console.runtime_seconds(v_start);
--  --
--  v_start := localtimestamp;
--  for i in 1 .. v_iterator loop
--    if sysdate <= v_end_date then null; end if;
--  end loop;
--  v_rt_date := console.runtime_seconds(v_start);
--  --
--  console.printf( '- timestamp      : %s seconds' , trim(to_char(v_rt_time, '0.000000'))       );
--  console.printf( '- date           : %s seconds' , trim(to_char(v_rt_date, '0.000000'))       );
--  console.printf( '- factor         : %s'         , trim(to_char(v_rt_time/v_rt_date, '90.0')) );
--end;
--/

--prompt
--prompt DATE > GET_TIME - 100.000 CALLS
--declare
--  v_iterator pls_integer := 100000;
--  v_start    timestamp;
--  v_end_date date        := sysdate               + 1/24/60*10;
--  v_end_time pls_integer := dbms_utility.get_time + 100 * 10; --current time + 10 seconds
--  v_rt_date  number;
--  v_rt_time  number;
--begin
--  v_start := localtimestamp;
--  for i in 1 .. v_iterator loop
--    if sysdate <= v_end_date then null; end if;
--  end loop;
--  v_rt_date := console.runtime_seconds(v_start);
--  --
--  v_start := localtimestamp;
--  for i in 1 .. v_iterator loop
--    if dbms_utility.get_time <= v_end_time then null; end if;
--  end loop;
--  v_rt_time := console.runtime_seconds(v_start);
--  --
--  console.printf( '- date           : %s seconds' , trim(to_char(v_rt_date, '0.000000'))       );
--  console.printf( '- get_time       : %s seconds' , trim(to_char(v_rt_time, '0.000000'))       );
--  console.printf( '- factor         : %s'         , trim(to_char(v_rt_date/v_rt_time, '90.0')) );
--end;
--/

--prompt
--prompt BOOLEAN > INTEGER - 100.000 CALLS
--declare
--  v_iterator pls_integer := 100000;
--  v_start    timestamp;
--  v_boolean  boolean     := true;
--  v_integer  pls_integer := 1;
--  v_rt_bool  number;
--  v_rt_int   number;
--begin
--  v_start := localtimestamp;
--  for i in 1 .. v_iterator loop
--    if v_boolean then null; end if;
--  end loop;
--  v_rt_bool := console.runtime_seconds(v_start);
--  --
--  v_start := localtimestamp;
--  for i in 1 .. v_iterator loop
--    if v_integer = 1 then null; end if;
--  end loop;
--  v_rt_int := console.runtime_seconds(v_start);
--  --
--  console.printf( '- boolean        : %s seconds' , trim(to_char(v_rt_bool, '0.000000'))      );
--  console.printf( '- integer        : %s seconds' , trim(to_char(v_rt_int,  '0.000000'))      );
--  console.printf( '- factor         : %s'         , trim(to_char(v_rt_bool/v_rt_int, '90.0')) );
--end;
--/

--prompt
--prompt RUNTIME: REGEX > EXTRACT > SUBSTR - 100.000 CALLS
--declare
--  v_iterator   pls_integer := 100000;
--  v_start      timestamp;
--  v_temp       varchar2(20);
--  v_rt_extract number;
--  v_rt_regex   number;
--  v_rt_substr  number;
--  --
--  function util_runtime_regex (p_start timestamp) return varchar2 is
--  begin
--    return regexp_substr(to_char(localtimestamp - p_start), '\d{2}:\d{2}:\d{2}\.\d{6}');
--  end util_runtime_regex;
--  --
--  function util_runtime_extract (p_start timestamp) return varchar2 is
--    v_runtime interval day to second (6);
--  begin
--    v_runtime := localtimestamp - p_start;
--    return
--      trim(to_char(extract(hour   from v_runtime), '00'       )) || ':' ||
--      trim(to_char(extract(minute from v_runtime), '00'       )) || ':' ||
--      trim(to_char(extract(second from v_runtime), '00D000000')) ;
--  end util_runtime_extract;
--  --
--  function util_runtime_substr (p_start timestamp) return varchar2 is
--    v_runtime varchar2(32);
--  begin
--    v_runtime := to_char(localtimestamp - p_start);
--    return substr(v_runtime, instr(v_runtime,':')-2, 15);
--  end util_runtime_substr;
--  --
--begin
--  v_start := localtimestamp;
--  for i in 1 .. v_iterator loop
--    v_temp := util_runtime_regex(v_start);
--  end loop;
--  v_rt_regex := console.runtime_seconds(v_start);
--  --
--  v_start := localtimestamp;
--  for i in 1 .. v_iterator loop
--    v_temp := util_runtime_extract(v_start);
--  end loop;
--  v_rt_extract := console.runtime_seconds(v_start);
--  --
--  v_start := localtimestamp;
--  for i in 1 .. v_iterator loop
--    v_temp := util_runtime_substr(v_start);
--  end loop;
--  v_rt_substr := console.runtime_seconds(v_start);
--  --
--  console.printf( '- regex          : %s seconds' , trim(to_char(v_rt_regex,   '0.000000'))         );
--  console.printf( '- exract         : %s seconds' , trim(to_char(v_rt_extract, '0.000000'))         );
--  console.printf( '- substr         : %s seconds' , trim(to_char(v_rt_substr,  '0.000000'))         );
--  console.printf( '- factor r/s     : %s'         , trim(to_char(v_rt_regex/v_rt_substr, '90.0'))   );
--  console.printf( '- factor e/s     : %s'         , trim(to_char(v_rt_extract/v_rt_substr, '90.0')) );
--end;
--/

