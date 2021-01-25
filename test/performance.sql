prompt 100.000 LOG CALLS IN LEVEL ERROR (log only errors)
set serveroutput on verify off feedback off
exec logger.set_level(logger.g_error);

declare
  v_iterator pls_integer := 100000;
  v_start    timestamp;
begin

  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    logger.log('test');
  end loop;
  dbms_output.put_line( '- logger.log: ' || to_char(extract(second from (localtimestamp - v_start)), '0.000000') || ' seconds' );

  v_start := localtimestamp;
  for i in 1 .. v_iterator loop
    console.log('test');
  end loop;
  dbms_output.put_line( '- console.log:' || to_char(extract(second from (localtimestamp - v_start)),'0.000000') || ' seconds' );

end;
/