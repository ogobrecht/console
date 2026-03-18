set serveroutput on verify off feedback off

alter session set plsql_ccflags = 'apex_installed:false, utils_public:true';
prompt - Compile package console (spec)
@sources/CONSOLE.pks
prompt - Compile package console (body)
@sources/CONSOLE.pkb

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
prompt 100.000 LOG CALLS IN LEVEL ERROR (how much time you loose by do nothing)
declare
   l_iterator   pls_integer := 100000;
   l_start      timestamp;
   l_rt_null    number;
   l_rt_logger  number;
   l_rt_console number;
begin
   l_start := localtimestamp;
   for i in 1 .. l_iterator
   loop
      null;
   end loop;
   l_rt_null := console.runtime_seconds(l_start);
   --
   l_start := localtimestamp;
   for i in 1 .. l_iterator loop
      logger.log('test');
   end loop;
   l_rt_logger := console.runtime_seconds(l_start);
   --
   l_start := localtimestamp;
   for i in 1 .. l_iterator loop
      console.log('test');
   end loop;
   l_rt_console := console.runtime_seconds(l_start);
   --
   console.printf( '- empty loop     : %s seconds  (it does not really matter)' , trim(to_char(l_rt_null,    '0.000000'))         );
   console.printf( '- logger.log     : %s seconds '                             , trim(to_char(l_rt_logger,  '0.000000'))         );
   console.printf( '- console.log    : %s seconds '                             , trim(to_char(l_rt_console, '0.000000'))         );
   console.printf( '- factor         : %s'                                      , trim(to_char(l_rt_logger/l_rt_console, '90.0')) );
end;
/

prompt
prompt 100.000 COUNT CALLS IN LEVEL ERROR (how much time you loose by counting)
declare
   l_iterator pls_integer := 100000;
   l_start    timestamp;
   l_rt_log   number;
   l_rt_count number;
begin
   l_start := localtimestamp;
   for i in 1 .. l_iterator loop
      console.log('test');
   end loop;
   l_rt_log := console.runtime_seconds(l_start);
   --
   l_start := localtimestamp;
   for i in 1 .. l_iterator loop
      console.count('test');
   end loop;
   l_rt_count := console.runtime_seconds(l_start);
   console.printf( '- count result   : %s'         , (to_char(console.count_end('test')))       );
   console.printf( '- console.log    : %s seconds' , trim(to_char(l_rt_log,   '0.000000'))      );
   console.printf( '- console.count  : %s seconds' , trim(to_char(l_rt_count, '0.000000'))      );
   console.printf( '- factor         : %s'         , trim(to_char(l_rt_log/l_rt_count, '90.0')) );
end;
/

prompt
prompt 100.000 TIME CALLS IN LEVEL ERROR (how much time you loose by measuring time)
declare
   l_iterator pls_integer := 100000;
   l_start    timestamp;
   l_rt_log   number;
   l_rt_time  number;
   l_result   varchar2(100);
begin
   l_start := localtimestamp;
   for i in 1 .. l_iterator loop
      console.log('test');
   end loop;
   l_rt_log := console.runtime_seconds(l_start);
   --
   l_start := localtimestamp;
   for i in 1 .. l_iterator loop
      console.time('test');
   end loop;
   l_rt_time := console.runtime_seconds(l_start);
   console.printf( '- console.log    : %s seconds' , trim(to_char(l_rt_log,  '0.000000'))      );
   console.printf( '- console.time   : %s seconds' , trim(to_char(l_rt_time, '0.000000'))      );
   console.printf( '- factor         : %s'         , trim(to_char(l_rt_log/l_rt_time, '90.0')) );
end;
/

prompt
prompt 1.000 LOG CALLS IN LEVEL INFO (how much time you loose by do logging)
declare
   l_iterator   pls_integer := 1000;
   l_start      timestamp;
   l_scope      varchar2(1000);
   l_rt_logger  number;
   l_rt_console number;
begin
   --configure and warm up logger and console
   logger.set_level(logger.g_debug);
   console.init(
      p_level          => console.c_level_info ,
      p_duration       => 90                   ,
      p_check_interval => 30                   );
   for i in 1 .. 10 loop
      logger.log ('warm up ' || to_char(i));
      console.log ('warm up ' || to_char(i));
   end loop;
   -- test logger
   l_start := localtimestamp;
   for i in 1 .. l_iterator loop
      logger.log('test ' || to_char(i), p_extra => 'Test performance with clob column used');
   end loop;
   l_rt_logger := console.runtime_seconds(l_start);
   -- test console
   l_start := localtimestamp;
   for i in 1 .. l_iterator loop
      console.log('test ' || to_char(i));
   end loop;
   l_rt_console := console.runtime_seconds(l_start);
   -- print results
   console.printf( '- logger.log     : %s seconds' , trim(to_char(l_rt_logger,  '0.000000'))         );
   console.printf( '- console.log    : %s seconds' , trim(to_char(l_rt_console, '0.000000'))         );
   console.printf( '- factor         : %s'         , trim(to_char(l_rt_logger/l_rt_console, '90.0')) );
   --configure logger and console
   logger.set_level(logger.g_error);
   console.exit;
end;
/

prompt
prompt 1.000 FORMAT CALLS (how much time you loose by formatting strings)
declare
   l_iterator   pls_integer := 1000;
   l_start      timestamp;
   l_rt_logger  number;
   l_rt_console number;
   l_test       varchar2 (1000);
begin
   -- test logger
   l_start := localtimestamp;
   for i in 1 .. l_iterator
   loop
      l_test := logger.sprintf('Lorem ipsum %s1. Must be %s2, %s3, %s4 or test', 1, 2, 3, 4, 5, 6, 7, 8, 9);
   end loop;
   l_rt_logger := console.runtime_seconds(l_start);
   -- test console
   l_start := localtimestamp;
   for i in 1 .. l_iterator
   loop
      l_test := console.format('Lorem ipsum %0. Must be %1, %2, %3 or test', 0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
   end loop;
   l_rt_console := console.runtime_seconds(l_start);
   -- print results
   console.printf( '- logger.sprintf : %s seconds' , trim(to_char(l_rt_logger,  '0.000000'))         );
   console.printf( '- console.format : %s seconds' , trim(to_char(l_rt_console, '0.000000'))         );
   console.printf( '- factor         : %s'         , trim(to_char(l_rt_logger/l_rt_console, '90.0')) );
end;
/

prompt
prompt 10.000 SCOPE CALLS (how much time you loose by fetching the scope from the call stack)
declare
   l_iterator pls_integer := 10000;
   l_start    timestamp;
   l_scope    varchar2(1000);
   l_rt       number;
begin
   l_start := localtimestamp;
   for i in 1 .. l_iterator
   loop
      l_scope := console.scope;
   end loop;
   l_rt := console.runtime_seconds(l_start);
   --
   console.printf( '- scope          : %s seconds', trim(to_char(l_rt, '0.000000')));
end;
/

prompt
prompt RUNTIME: EXTRACT CLIENT PREFS OUT OF 4000 BYTE - REGEX > SUBSTR COMPARISON
declare
   l_iterator   pls_integer := 1; --try also 10, 100, 1000, 10000, 100000
   l_start      timestamp;
   l_temp       console.t_32kb;
   l_rt_regex   number;
   l_rt_substr  number;
   l_start_pos  pls_integer;
   l_stop_pos   pls_integer;
   l_haystack   console.t_4kb;
   l_needle     console.t_64b := '{o,o} 88217AE40002';
begin
   -- build the haystack of around 4000 byte
   select listagg('{o,o} ' || lpad(level,2,'0') || '217AE40002,3,0,10,210927083239', chr(10))
     into l_haystack
     from dual
   connect by level <= 100; --try also smaller sizes like 5 or 10

   l_start := localtimestamp;
   for i in 1 .. l_iterator loop
      l_temp := regexp_substr(l_haystack,'^' || l_needle || ',.*$', 1, 1, 'im');
   end loop;
   l_rt_regex := console.runtime_seconds(l_start);
   console.printf( '- regex result   : %s', l_temp );

   l_start := localtimestamp;
   for i in 1 .. l_iterator loop
      l_haystack := replace(l_haystack, chr(13), chr(10));
      l_start_pos := instr(l_haystack, l_needle || ',');
      l_stop_pos  := instr(l_haystack, chr(10), l_start_pos);
      l_temp      := substr(l_haystack, l_start_pos, l_stop_pos - l_start_pos);
   end loop;
   l_rt_substr := console.runtime_seconds(l_start);
   console.printf( '- substr result  : %s', l_temp );

   console.printf( '- regex          : %s seconds' , trim(to_char(l_rt_regex,   '0.000000'))         );
   console.printf( '- substr         : %s seconds' , trim(to_char(l_rt_substr,  '0.000000'))         );
   console.printf( '- factor r/s     : %s'         , trim(to_char(l_rt_regex/l_rt_substr, '90.0'))   );
end;
/

prompt
prompt 10.000 INIT PACKAGE CALLS
declare
  l_iterator   pls_integer := 10000;
  l_start      timestamp;
  l_rt         number;
  l_result     varchar2(100);
begin
  l_start := localtimestamp;
  for i in 1 .. l_iterator loop
     console.utl_set_client_identifier;
     console.utl_set_session_conf;
  end loop;
  l_rt := console.runtime_seconds(l_start);
  console.printf( '- runtime all    : %s seconds', trim(to_char(l_rt,      '0.000000000')));
  console.printf( '- per call       : %s seconds', trim(to_char(l_rt/l_iterator, '0.000000000')));
end;
/
--
--prompt
--prompt TIMESTAMP > DATE - 100.000 CALLS
--declare
--   l_iterator pls_integer := 100000;
--   l_start    timestamp;
--   l_end_time timestamp   := systimestamp + 1/24/60*10;
--   l_end_date date        := sysdate      + 1/24/60*10;
--   l_rt_time  number;
--   l_rt_date  number;
--begin
--   l_start := localtimestamp;
--   for i in 1 .. l_iterator loop
--      if systimestamp <= l_end_time then null; end if;
--   end loop;
--   l_rt_time := console.runtime_seconds(l_start);
--   --
--   l_start := localtimestamp;
--   for i in 1 .. l_iterator loop
--      if sysdate <= l_end_date then null; end if;
--   end loop;
--   l_rt_date := console.runtime_seconds(l_start);
--   --
--   console.printf( '- timestamp      : %s seconds' , trim(to_char(l_rt_time, '0.000000'))       );
--   console.printf( '- date           : %s seconds' , trim(to_char(l_rt_date, '0.000000'))       );
--   console.printf( '- factor         : %s'         , trim(to_char(l_rt_time/l_rt_date, '90.0')) );
--end;
--/
--
--prompt
--prompt DATE > GET_TIME - 100.000 CALLS
--declare
--   l_iterator pls_integer := 100000;
--   l_start    timestamp;
--   l_end_date date        := sysdate               + 1/24/60*10;
--   l_end_time pls_integer := dbms_utility.get_time + 100 * 10; --current time + 10 seconds
--   l_rt_date  number;
--   l_rt_time  number;
--begin
--   l_start := localtimestamp;
--   for i in 1 .. l_iterator loop
--      if sysdate <= l_end_date then null; end if;
--   end loop;
--   l_rt_date := console.runtime_seconds(l_start);
--   --
--   l_start := localtimestamp;
--   for i in 1 .. l_iterator loop
--      if dbms_utility.get_time <= l_end_time then null; end if;
--   end loop;
--   l_rt_time := console.runtime_seconds(l_start);
--   --
--   console.printf( '- date           : %s seconds' , trim(to_char(l_rt_date, '0.000000'))       );
--   console.printf( '- get_time       : %s seconds' , trim(to_char(l_rt_time, '0.000000'))       );
--   console.printf( '- factor         : %s'         , trim(to_char(l_rt_date/l_rt_time, '90.0')) );
--end;
--/
--
--prompt
--prompt BOOLEAN > INTEGER - 100.000 CALLS
--declare
--   l_iterator pls_integer := 100000;
--   l_start    timestamp;
--   l_boolean  boolean     := true;
--   l_integer  pls_integer := 1;
--   l_rt_bool  number;
--   l_rt_int   number;
--begin
--   l_start := localtimestamp;
--   for i in 1 .. l_iterator loop
--      if l_boolean then null; end if;
--   end loop;
--   l_rt_bool := console.runtime_seconds(l_start);
--   --
--   l_start := localtimestamp;
--   for i in 1 .. l_iterator loop
--      if l_integer = 1 then null; end if;
--   end loop;
--   l_rt_int := console.runtime_seconds(l_start);
--   --
--   console.printf( '- boolean        : %s seconds' , trim(to_char(l_rt_bool, '0.000000'))      );
--   console.printf( '- integer        : %s seconds' , trim(to_char(l_rt_int,  '0.000000'))      );
--   console.printf( '- factor         : %s'         , trim(to_char(l_rt_bool/l_rt_int, '90.0')) );
--end;
--/
--
--prompt
--prompt RUNTIME: REGEX > EXTRACT > SUBSTR - 100.000 CALLS
--declare
--   l_iterator   pls_integer := 100000;
--   l_start      timestamp;
--   l_temp       varchar2(20);
--   l_rt_extract number;
--   l_rt_regex   number;
--   l_rt_substr  number;
--   --
--   function util_runtime_regex (p_start timestamp) return varchar2 is
--   begin
--      return regexp_substr(to_char(localtimestamp - p_start), '\d{2}:\d{2}:\d{2}\.\d{6}');
--   end util_runtime_regex;
--   --
--   function util_runtime_extract (p_start timestamp) return varchar2 is
--      l_runtime interval day to second (6);
--   begin
--      l_runtime := localtimestamp - p_start;
--      return
--         trim(to_char(extract(hour   from l_runtime), '00'       )) || ':' ||
--         trim(to_char(extract(minute from l_runtime), '00'       )) || ':' ||
--         trim(to_char(extract(second from l_runtime), '00D000000')) ;
--   end util_runtime_extract;
--   --
--   function util_runtime_substr (p_start timestamp) return varchar2 is
--      l_runtime varchar2(32);
--   begin
--      l_runtime := to_char(localtimestamp - p_start);
--      return substr(l_runtime, instr(l_runtime,':')-2, 15);
--   end util_runtime_substr;
--  --
--begin
--   l_start := localtimestamp;
--   for i in 1 .. l_iterator loop
--      l_temp := util_runtime_regex(l_start);
--   end loop;
--   l_rt_regex := console.runtime_seconds(l_start);
--   --
--   l_start := localtimestamp;
--   for i in 1 .. l_iterator loop
--      l_temp := util_runtime_extract(l_start);
--   end loop;
--   l_rt_extract := console.runtime_seconds(l_start);
--   --
--   l_start := localtimestamp;
--   for i in 1 .. l_iterator loop
--      l_temp := util_runtime_substr(l_start);
--   end loop;
--   l_rt_substr := console.runtime_seconds(l_start);
--   --
--   console.printf( '- regex          : %s seconds' , trim(to_char(l_rt_regex,   '0.000000'))         );
--   console.printf( '- exract         : %s seconds' , trim(to_char(l_rt_extract, '0.000000'))         );
--   console.printf( '- substr         : %s seconds' , trim(to_char(l_rt_substr,  '0.000000'))         );
--   console.printf( '- factor r/s     : %s'         , trim(to_char(l_rt_regex/l_rt_substr, '90.0'))   );
--   console.printf( '- factor e/s     : %s'         , trim(to_char(l_rt_extract/l_rt_substr, '90.0')) );
--end;
--/
--