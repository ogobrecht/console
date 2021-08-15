create or replace package console authid definer is

c_name    constant varchar2 ( 30 byte ) := 'Oracle Instrumentation Console'       ;
c_version constant varchar2 ( 20 byte ) := '1.0-beta8'                            ;
c_url     constant varchar2 ( 40 byte ) := 'https://github.com/ogobrecht/console' ;
c_license constant varchar2 (  5 byte ) := 'MIT'                                  ;
c_author  constant varchar2 ( 15 byte ) := 'Ottmar Gobrecht'                      ;

c_level_error   constant pls_integer := 1 ;
c_level_warning constant pls_integer := 2 ;
c_level_info    constant pls_integer := 3 ;
c_level_debug   constant pls_integer := 4 ;
c_level_trace   constant pls_integer := 5 ;

/**

Oracle Instrumentation Console
==============================

An instrumentation tool for Oracle developers. Save to install on production and
mostly API compatible with the [JavaScript
console](https://developers.google.com/web/tools/chrome-devtools/console/api).

For more infos have a look at the [project page on
GitHub](https://github.com/ogobrecht/console).

**/


--------------------------------------------------------------------------------
-- PUBLIC TYPES
--------------------------------------------------------------------------------

subtype t_vc1   is varchar2 (    1 char);
subtype t_vc32  is varchar2 (   32 char);
subtype t_vc64  is varchar2 (   64 char);
subtype t_vc128 is varchar2 (  128 char);
subtype t_vc256 is varchar2 (  256 char);
subtype t_vc1k  is varchar2 ( 1024 char);
subtype t_vc4k  is varchar2 ( 4096 char);
subtype t_vc32k is varchar2 (32767 char);

type t_key_value_row is record(
  key    t_vc128 ,
  value  t_vc4k  );
type t_key_value_tab   is table of t_key_value_row;
type t_key_value_tab_i is table of t_key_value_row index by pls_integer;
type t_logs_tab        is table of console_logs%rowtype;
type t_vc2_tab         is table of t_vc32k;
type t_vc2_tab_i       is table of t_vc32k index by pls_integer;


--------------------------------------------------------------------------------
-- PUBLIC CONSOLE METHODS
--------------------------------------------------------------------------------

function my_client_identifier return varchar2;
/**

Returns the current session identifier of the own session. This information is cached in a
package variable and determined on package initialization.

```sql
select console.my_client_identifier from dual;
```

**/

--------------------------------------------------------------------------------

function my_log_level return integer;
/**

Returns the current log level of the own session. This information is cached in a
package variable for performance reasons and re-evaluated every 10 seconds.

```sql
select console.my_log_level from dual;
```

**/

--------------------------------------------------------------------------------

function view_last (p_log_rows in integer default 100) return t_logs_tab pipelined;
/**

View the last log entries from the log cache and the log table (if not enough in
the cache) in descending order.

The entries without a log_id are from the cache, the others from the log table.

EXAMPLE

```sql
--init logging for own session
exec console.init(
  p_level          => c_level_debug ,
  p_duration       => 90            ,
  p_cache_size     => 10            ,
  p_check_interval => 30            );

--test some business logic
begin
  --your code here;

  console.log('test', p_user_env => true);
end;
{{/}}

--view last cache and log entries
select * from console.view_last(50);
```

**/

--------------------------------------------------------------------------------

procedure error_save_stack;
/**

Saves the error stack, so that you are able to handle the error on the most
outer point in your code without loosing detail information of the original
error nested deeper in your code.

With this method we try to prevent log spoiling  - if you use it right you can
have ONE log entry for your errors with the saved details where the error
occured.

EXAMPLE

```sql
set define off
set feedback off
set serveroutput on
set linesize 120
set pagesize 40
column call_stack heading "Call Stack" format a120
whenever sqlerror exit sql.sqlcode rollback

prompt TEST ERROR_SAVE_STACK

prompt - compile package spec
create or replace package some_api is
  procedure do_stuff;
end;
{{/}}

prompt - compile package body
create or replace package body some_api is
------------------------------------------------------------------------------
    procedure do_stuff is
    --------------------------------------
        procedure sub1 is
        --------------------------------------
            procedure sub2 is
            --------------------------------------
                procedure sub3 is
                begin
                  console.assert(1 = 2, 'Demo');
                exception --sub3
                  when others then
                    console.error_save_stack;
                    raise;
                end;
            --------------------------------------
            begin
              sub3;
            exception --sub2
              when others then
                console.error_save_stack;
                raise;
            end;
        --------------------------------------
        begin
          sub2;
        exception --sub1
          when others then
            console.error_save_stack;
            raise no_data_found;
        end;
    --------------------------------------
    begin
      sub1;
    exception --do_stuff
      when others then
        console.error;
        raise;
    end;
------------------------------------------------------------------------------
end;
{{/}}

prompt - call the package
begin
  some_api.do_stuff;
exception
  when others then
    null; --> I know, I know, never do that without a final raise...
          --> But we want only test our logging without killing the script run...
end;
{{/}}

prompt - FINISHED, selecting now the call stack from the last log entry...

select call_stack from console_logs order by log_id desc fetch first row only;
```

EXAMPLE OUTPUT

```bash
TEST ERROR_SAVE_STACK
- compile package spec
- compile package body
- call the package
- FINISHED, selecting now the call stack from the last log entry...

Call Stack
------------------------------------------------------------------------------------------------------------------------
{{#}}### Saved Error Stack

- PLAYGROUND.SOME_API.DO_STUFF.SUB1.SUB2.SUB3, line 14 (line 11, ORA-20777 Assertion failed: Demo)
- PLAYGROUND.SOME_API.DO_STUFF.SUB1.SUB2, line 22 (line 19)
- PLAYGROUND.SOME_API.DO_STUFF.SUB1, line 30 (line 27)
- PLAYGROUND.SOME_API.DO_STUFF, line 38 (line 35, ORA-01403 no data found)

{{#}}### Call Stack

- PLAYGROUND.SOME_API.DO_STUFF, line 38
- __anonymous_block, line 2

{{#}}### Error Stack

- ORA-01403 no data found
- ORA-06512 at "PLAYGROUND.SOME_API", line 31
- ORA-20777 Assertion failed: Test assertion with line break.
- ORA-06512 at "PLAYGROUND.SOME_API", line 23
- ORA-06512 at "PLAYGROUND.SOME_API", line 15
- ORA-06512 at "PLAYGROUND.CONSOLE", line 750
- ORA-06512 at "PLAYGROUND.SOME_API", line 11
- ORA-06512 at "PLAYGROUND.SOME_API", line 19
- ORA-06512 at "PLAYGROUND.SOME_API", line 27

{{#}}### Error Backtrace

- PLAYGROUND.SOME_API, line 31
- PLAYGROUND.SOME_API, line 23
- PLAYGROUND.SOME_API, line 15
- PLAYGROUND.CONSOLE, line 750
- PLAYGROUND.SOME_API, line 11
- PLAYGROUND.SOME_API, line 19
- PLAYGROUND.SOME_API, line 27
- PLAYGROUND.SOME_API, line 35
```

**/

--------------------------------------------------------------------------------

procedure error (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default true  ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  );
/**

Log a message with the level 1 (error).

**/

function error (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default true  ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 1 (error). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure warn (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  );
/**

Log a message with the level 2 (warning).

**/

function warn (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 2 (warning). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure info (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  );
/**

Log a message with the level 3 (info).

**/

function info (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 3 (info). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure log(
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  );
/**

Log a message with the level 3 (info).

**/

function log(
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 3 (info). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure debug (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  );
/**

Log a message with the level 4 (debug).

**/

function debug (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 4 (debug). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure trace (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default true  ,
  p_apex_env        in boolean  default true  ,
  p_cgi_env         in boolean  default true  ,
  p_console_env     in boolean  default true  ,
  p_user_env        in boolean  default true  ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  );
/**

Log a message with the level 5 (trace).

**/

function trace (
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default true  ,
  p_apex_env        in boolean  default true  ,
  p_cgi_env         in boolean  default true  ,
  p_console_env     in boolean  default true  ,
  p_user_env        in boolean  default true  ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;
/**

Log a message with the level 5 (trace). Returns the log ID.

**/

--------------------------------------------------------------------------------

procedure count ( p_label in varchar2 default null );
/**

Starts a new counter with a value of one or adds one to an existent counter.

Call `console.count_end('yourLabel')` to stop the counter and get or log the count
value.

**/

procedure count_log ( p_label in varchar2 default null );
/**

Logs a counter, if current log level >= 3 (info).

Can be called multiple times - use `console.count_end` to stop a counter and get or
log the counter value.

**/

procedure count_end ( p_label in varchar2 default null );
/**

Stops a counter and logs the result, if current log level >= 3 (info).

EXAMPLE

```sql
--Set your own session in logging mode (defaults: level 3=info for the next 60 minutes).
exec console.init;

begin
  --Do your stuff here.
  for i in 1 .. 1000 loop
    if mod(i, 3) = 0 then
      console.count('myLabel');
    end if;
  end loop;

  --Log your count value.
  console.count_end('myLabel');
end;
{{/}}

--Stop logging mode of your own session.
exec console.exit;
```

**/

function count_end ( p_label in varchar2 default null ) return varchar2;
/**

Stops a counter and returns the result.

Does not depend on a log level, can be used anywhere to count things.

EXAMPLE

```sql
set serveroutput on

declare
  v_my_label constant varchar2(20) := 'My label: ';
begin
  --do your stuff here
  for i in 1 .. 1000 loop
    if mod(i, 3) = 0 then
      console.count(v_my_label);
    end if;
  end loop;

  --Return your count value.
  dbms_output.put_line(v_my_label || console.count_end(v_my_label) );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure time ( p_label in varchar2 default null );
/**

Starts a new timer.

Call `console.time_end('yourLabel')` to stop the timer and get or log the elapsed
time.

**/

procedure time_log ( p_label in varchar2 default null );
/**

Logs the elapsed time, if current log level >= 3 (info).

Can be called multiple times - use `console.time_end` to stop a timer and get or
log the elapsed time.

EXAMPLE

```sql
--Set you own session in logging mode with the defaults: level 3(info) for the next 60 minutes.
exec console.init;

begin
  console.time('myLabel');

  --Do your stuff here.
  for i in 1 .. 100000 loop
    null;
  end loop;

  --Log the elapsed time.
  console.time_log('myLabel');

  --Do other things.
  --Your code here...

  --Log the elapsed time.
  console.time_log('myLabel');

end;
{{/}}

--Stop logging mode of your own session.
exec console.exit;
```

**/

procedure time_end ( p_label in varchar2 default null );
/**

Stops a timer and logs the result, if current log level >= 3 (info).

EXAMPLE

```sql
--Set you own session in logging mode with the defaults: level 3(info) for the next 60 minutes.
exec console.init;

begin
  console.time('myLabel');

  --Do your stuff here.
  for i in 1 .. 100000 loop
    null;
  end loop;

  --Log the time.
  console.time_end('myLabel');
end;
{{/}}

--Stop logging mode of your own session.
exec console.exit;
```

**/

function time_end ( p_label in varchar2 default null ) return varchar2;
/**

Stops a timer and returns the result.

Does not depend on a log level, can be used anywhere to measure runtime.

EXAMPLE

```sql
set serveroutput on

declare
  v_my_label constant varchar2(20) := 'My label: ';
begin
  console.time(v_my_label);

  --do your stuff here
  for i in 1 .. 100000 loop
    null;
  end loop;

  --Return the runtime.
  dbms_output.put_line(v_my_label || console.time_end(v_my_label) );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------
procedure table# (
  p_data_cursor       in sys_refcursor         ,
  p_comment           in varchar2 default null ,
  p_include_row_num   in boolean  default true ,
  p_max_rows          in integer  default 100  ,
  p_max_column_length in integer  default 1000 );
/**

Logs a cursor as a HTML table with the level 3 (info).

Using a cursor for the table method is very flexible, but opening a cursor can
produce unnecessary work for your system when you are not in the log level info.
Therefore please check your current log level before you open the cursor.

EXAMPLE

```sql
declare
  v_dataset sys_refcursor;
begin
  -- Your business logic here...

  -- Debug code
  if console.level_is_info then
    open v_dataset for
      select table_name,
             tablespace_name,
             logging,
             num_rows,
             last_analyzed,
             partitioned,
             has_identity
        from user_tables;
    console.table#(v_dataset);
  end if;

  -- Your business logic here...
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure assert (
  p_expression in boolean,
  p_message    in varchar2
);
/**

If the given expression evaluates to false, an error is raised with the given
message.

EXAMPLE

```sql
declare
  x number := 5;
  y number := 3;
begin
  console.assert(
    x < y,
    'X should be less then Y (x=' || to_char(x) || ', y=' || to_char(y) || ')'
  );
exception
  when others then
    console.error;
    raise;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure add_param ( p_name in varchar2, p_value in varchar2                       );
/**

Add a parameter to the package internal parameter collection which will be
included in the next log call (error, warn, info, log, debug or trace)

The procedure is overloaded to support different parameter types.

VARCHAR and CLOB parameters are shortened to 2000 characters and additionally
escaped for Markdown table columns (replacing all line endings with whitespace
and the pipe character with `&#124;`). If you need your full parameter text then
please use the `p_message` CLOB parameter in the log methods error, warn, info,
log, debug and trace to do your own parameter handling.

```sql
procedure add_param ( p_name in varchar2, p_value in varchar2                       );
procedure add_param ( p_name in varchar2, p_value in number                         );
procedure add_param ( p_name in varchar2, p_value in date                           );
procedure add_param ( p_name in varchar2, p_value in timestamp                      );
procedure add_param ( p_name in varchar2, p_value in timestamp with time zone       );
procedure add_param ( p_name in varchar2, p_value in timestamp with local time zone );
procedure add_param ( p_name in varchar2, p_value in interval year to month         );
procedure add_param ( p_name in varchar2, p_value in interval day to second         );
procedure add_param ( p_name in varchar2, p_value in boolean                        );
procedure add_param ( p_name in varchar2, p_value in clob                           );
procedure add_param ( p_name in varchar2, p_value in xmltype                        );
```

EXAMPLE

```sql
--create demo procedure
create or replace procedure demo_proc (
  p_01  varchar2                       ,
  p_02  number                         ,
  p_03  date                           ,
  p_04  timestamp                      ,
  p_05  timestamp with time zone       ,
  p_06  timestamp with local time zone ,
  p_07  interval year to month         ,
  p_08  interval day to second         ,
  p_09  boolean                        ,
  p_10 clob                            ,
  p_11 xmltype                         )
is
begin
  raise_application_error(-20999, 'Test Error.');
exception
  when others then
    console.add_param('p_01', p_01);
    console.add_param('p_02', p_02);
    console.add_param('p_03', p_03);
    console.add_param('p_04', p_04);
    console.add_param('p_05', p_05);
    console.add_param('p_06', p_06);
    console.add_param('p_07', p_07);
    console.add_param('p_08', p_08);
    console.add_param('p_09', p_09);
    console.add_param('p_10', p_10);
    console.add_param('p_11', p_11);
    console.error('Ooops, something went wrong');
    raise;
end demo_proc;
{{/}}

--run demo procedure
begin
  demo_proc (
    p_01 => 'test vc2'                             ,
    p_02 => 1.23                                   ,
    p_03 => sysdate                                ,
    p_04 => systimestamp                           ,
    p_05 => systimestamp                           ,
    p_06 => localtimestamp                         ,
    p_07 => interval '4-2' year to month           ,
    p_08 => interval '7 6:12:42.123' day to second ,
    p_09 => true                                   ,
    p_10 => to_clob('test clob')                   ,
    p_11 => xmltype('<test_xml/>')                 );
end;
{{/}}
```

**/

procedure add_param ( p_name in varchar2, p_value in number                         );
procedure add_param ( p_name in varchar2, p_value in date                           );
procedure add_param ( p_name in varchar2, p_value in timestamp                      );
procedure add_param ( p_name in varchar2, p_value in timestamp with time zone       );
procedure add_param ( p_name in varchar2, p_value in timestamp with local time zone );
procedure add_param ( p_name in varchar2, p_value in interval year to month         );
procedure add_param ( p_name in varchar2, p_value in interval day to second         );
procedure add_param ( p_name in varchar2, p_value in boolean                        );
procedure add_param ( p_name in varchar2, p_value in clob                           );
procedure add_param ( p_name in varchar2, p_value in xmltype                        );

--------------------------------------------------------------------------------

function format (
  p_message in varchar2              ,
  p0        in varchar2 default null ,
  p1        in varchar2 default null ,
  p2        in varchar2 default null ,
  p3        in varchar2 default null ,
  p4        in varchar2 default null ,
  p5        in varchar2 default null ,
  p6        in varchar2 default null ,
  p7        in varchar2 default null ,
  p8        in varchar2 default null ,
  p9        in varchar2 default null )
return varchar2;
/**

Formats a message with the following rules:

1. Replace all occurrences of `%0` .. `%9` by id with the corresponding
   parameters `p0` .. `p9`
2. Replace `%n` with new lines (line feed character)
3. Replace all occurrences of `%s` in positional order with the corresponding
   parameters using sys.utl_lms.format_message - also see the [Oracle
   docs](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/UTL_LMS.html#GUID-88FFBFB6-FCA4-4951-884B-B0275BD5DF44).

**/

--------------------------------------------------------------------------------

procedure action ( p_action in varchar2 );
/**

An alias for dbms_application_info.set_action.

Use the given action to set the session action attribute (in memory operation,
does not log anything). This attribute is then visible in the system session
views, the user environment and will be logged within all console logging
methods.

When you set the action attribute with `console.action` you should also reset it
when you have finished your work to prevent wrong info in the system and your
logging for subsequent method calls.

EXAMPLE

```sql
begin
  console.action('My process/task');
  -- do your stuff here...
  console.action(null);
exception
  when others then
    console.error('something went wrong');
    console.action(null);
    raise;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure module (
  p_module in varchar2,
  p_action in varchar2 default null
);
/**

An alias for dbms_application_info.set_module.

Use the given module and action to set the session module and action attributes
(in memory operation, does not log anything). These attributes are then visible
in the system session views, the user environment and will be logged within all
console logging methods.

Please note that your app framework may set the module and you should consider
to only set the action attribute with the `action` (see below).

**/

--------------------------------------------------------------------------------

function level_error     return integer; /** Returns the number code for the level 1 error.     **/
function level_warning   return integer; /** Returns the number code for the level 2 warning.   **/
function level_info      return integer; /** Returns the number code for the level 3 info.      **/
function level_debug     return integer; /** Returns the number code for the level 4 debug.     **/
function level_trace     return integer; /** Returns the number code for the level 5 trace.     **/

function level_is_warning return boolean; /** Returns true when the level is greater than or equal warning, otherwise false. **/
function level_is_info    return boolean; /** Returns true when the level is greater than or equal info, otherwise false.    **/
function level_is_debug   return boolean; /** Returns true when the level is greater than or equal debug, otherwise false.   **/
function level_is_trace   return boolean; /** Returns true when the level is greater than or equal trace, otherwise false.   **/

function level_is_warning_yn return varchar2; /** Returns 'Y' when the level is greater than or equal warning, otherwise 'N'. **/
function level_is_info_yn    return varchar2; /** Returns 'Y' when the level is greater than or equal info, otherwise 'N'.    **/
function level_is_debug_yn   return varchar2; /** Returns 'Y' when the level is greater than or equal debug, otherwise 'N'.   **/
function level_is_trace_yn   return varchar2; /** Returns 'Y' when the level is greater than or equal trace, otherwise 'N'.   **/


--------------------------------------------------------------------------------
-- PUBLIC HELPER METHODS
--------------------------------------------------------------------------------

$if $$apex_installed $then

function apex_error_handling ( p_error in apex_error.t_error )
return apex_error.t_error_result;
/**

You can register this example APEX error handler function to log APEX internal
errors.

To do so go into the Application Builder into your app > Edit Application
Properties > Error Handling > Error Handling Function. You can then provide here
`console.apex_error_handling`.

For more info see the [official
docs](https://docs.oracle.com/en/database/oracle/application-express/20.2/aeapi/Example-of-an-Error-Handling-Function.html#GUID-2CD75881-1A59-4787-B04B-9AAEC14E1A82).

The implementation code (see package body) is taken from the docs and aligned
for CONSOLE as a starting point. If this does not fit your needs then simply
reimplement an own function and use that instead.

**/

function apex_plugin_render (
  p_dynamic_action in apex_plugin.t_dynamic_action ,
  p_plugin         in apex_plugin.t_plugin         )
return apex_plugin.t_dynamic_action_render_result;
/**

Used for the APEX plugin to capture frontend JavaScript errors.

If you plan to use the plugin make sure you have either console installed in
your APEX parsing schema or a synonym named `console` for it as this function is
referenced in the plug-in as a callback to `console.apex_plugin_render`.

**/
function apex_plugin_ajax (
  p_dynamic_action in apex_plugin.t_dynamic_action ,
  p_plugin         in apex_plugin.t_plugin         )
return apex_plugin.t_dynamic_action_ajax_result;
/**

Used for the APEX plugin to capture frontend JavaScript errors.

If you plan to use the plugin make sure you have either console installed in
your APEX parsing schema or a synonym named `console` for it as this function is
referenced in the plug-in as a callback to `console.apex_plugin_ajax`.

**/

$end

--------------------------------------------------------------------------------

procedure conf (
  p_level               in integer  default c_level_error , -- Level 1 (error), 2 (warning), 3 (info), 4 (debug) or 5 (trace).
  p_check_interval      in integer  default 10            , -- The number of seconds a session looks for a changed configuration. Allowed values: 1 to 60 seconds.
  p_units_level_warning in varchar2 default null          , -- A comma separated list of unit names which should have log level warning. Example: p_units_level_warning => 'OWNER.UNIT,SCHEMA2.PACKAGE3'
  p_units_level_info    in varchar2 default null          , -- Same as p_units_level_warning for level info.
  p_units_level_debug   in varchar2 default null          , -- Same as p_units_level_warning for level debug.
  p_units_level_trace   in varchar2 default null          , -- Same as p_units_level_warning for level trace.
  p_enable_ascii_art    in boolean  default true            -- Currently used to have more fun with the APEX error handling messages. But who knows...
);
/**

Set the global console configuration.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING GLOBAL PREFERENCES.

EXAMPLE

```sql
--set all sessions to level warning
exec console.conf(p_level => console.c_level_warning);

--set all session to level info and two new packages to debug
begin
  console.conf(
    p_level             => console.c_level_info,
    p_check_interval    => 10,
    p_units_level_debug => 'MY_SCHEMA.SOME_API,MY_SCHEMA.ANOTHER_API'
  );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

procedure conf_level (
  p_level in integer default c_level_error  -- Level 1 (error), 2 (warning), 3 (info), 4 (debug) or 5 (trace).
);
/**

Set the global level.

A shortcut for the procedure `console.conf` to only set the level without
interfering other settings.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING GLOBAL PREFERENCES.

EXAMPLE

```sql
--set all sessions to level warning
exec console.conf_level(2);

--same with using a constant
exec console.conf_level(console.c_level_warning);
```

**/

--------------------------------------------------------------------------------

procedure conf_check_interval (
  p_check_interval in integer default 10 -- The number of seconds a session looks for a changed configuration. Allowed values: 1 to 60 seconds.
);
/**

Set the global check interval.

A shortcut for the procedure `console.conf` to only set the check interval
without interfering other settings.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING GLOBAL PREFERENCES.

EXAMPLE

```sql
--set all sessions to a check interval of 30 seconds
exec console.conf_check_interval(30);
```

**/

--------------------------------------------------------------------------------

procedure conf_units (
  p_units_level_warning in varchar2 default null , -- A comma separated list of unit names which should have log level warning. Example: p_units_level_warning => 'OWNER.UNIT,SCHEMA2.PACKAGE3'
  p_units_level_info    in varchar2 default null , -- Same as p_units_level_warning for level info.
  p_units_level_debug   in varchar2 default null , -- Same as p_units_level_warning for level debug.
  p_units_level_trace   in varchar2 default null   -- Same as p_units_level_warning for level trace.
);
/**

Set the global levels for code units under special observation.

A shortcut for the procedure `console.conf` to only set unit levels without
interfering other settings.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING GLOBAL PREFERENCES.

EXAMPLE

```sql
--special observation of two new packages
exec console.conf_units(p_units_level_debug => 'MY_SCHEMA.NEW_FANCY_API,MY_SCHEMA.ANOTHER_API');
```

**/

--------------------------------------------------------------------------------

procedure conf_ascii_art (
  p_enable_ascii_art in boolean  default true -- Currently used to have more fun with the APEX error handling messages. But who knows...
);
/**

Set the global ascii art status.

A shortcut for the procedure `console.conf` to only set the ascii art status
without interfering other settings.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING GLOBAL PREFERENCES.

EXAMPLE

```sql
--enable the usage of ascii art
exec console.conf_ascii_art(true);

--disable the usage of ascii art
exec console.conf_ascii_art(false);
```

**/

--------------------------------------------------------------------------------

procedure init (
  p_client_identifier in varchar2                      , -- The client identifier provided by the application or console itself.
  p_level             in integer  default c_level_info , -- Level 2 (warning), 3 (info), 4 (debug) or 5 (trace).
  p_duration          in integer  default 60           , -- The number of minutes the session should be in logging mode. Allowed values: 1 to 1440 minutes (24 hours).
  p_cache_size        in integer  default 0            , -- The number of log entries to cache before they are written down into the log table. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shared environments like APEX. Allowed values: 0 to 1000 records.
  p_check_interval    in integer  default 10           , -- The number of seconds a session looks for a changed configuration. Allowed values: 1 to 60 seconds.
  p_call_stack        in boolean  default false        , -- Should the call stack be included.
  p_user_env          in boolean  default false        , -- Should the user environment be included.
  p_apex_env          in boolean  default false        , -- Should the APEX environment be included.
  p_cgi_env           in boolean  default false        , -- Should the CGI environment be included.
  p_console_env       in boolean  default false          -- Should the console environment be included.
);
/**

Init/set the preferences for a specific session/client_identifier and duration.

To avoid spoiling the context with very long input the parameter
p_client_identifier is truncated after 64 characters before using it.

For easier usage there is an overloaded procedure available which uses always
your own session/client_identifier.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING CLIENT PREFERENCES.

EXAMPLES

```sql
-- Dive into your own session with the default log level of 3 (info) and the
-- default duration of 60 (minutes).
exec console.init;

-- With level 4 (debug) for the next 15 minutes.
exec console.init(4, 15);

-- Using a constant for the level
exec console.init(console.c_level_debug, 90);

-- Debug an APEX session...
exec console.init('OGOBRECHT:8805903776765', 4, 90);

-- ...with named parameters
begin
  console.init(
    p_client_identifier => 'OGOBRECHT:8805903776765',
    p_level             => console.c_level_debug,
    p_duration          => 15
  );
end;
{{/}}
```

**/

procedure init (
  p_level          in integer default c_level_info , -- Level 2 (warning), 3 (info), 4 (debug) or 5 (trace).
  p_duration       in integer default 60           , -- The number of minutes the session should be in logging mode. Allowed values: 1 to 1440 minutes (24 hours).
  p_cache_size     in integer default 0            , -- The number of log entries to cache before they are written down into the log table. Errors are flushing always the cache. If greater then zero and no errors occur you can loose log entries in shared environments like APEX. Allowed values: 0 to 1000 records.
  p_check_interval in integer default 10           , -- The number of seconds a session in logging mode looks for a changed configuration. Allowed values: 1 to 60 seconds.
  p_call_stack     in boolean default false        , -- Should the call stack be included.
  p_user_env       in boolean default false        , -- Should the user environment be included.
  p_apex_env       in boolean default false        , -- Should the APEX environment be included.
  p_cgi_env        in boolean default false        , -- Should the CGI environment be included.
  p_console_env    in boolean default false          -- Should the console environment be included.
);
/**
An overloaded procedure for easier initialization of the own
session/client_identifier in an development IDE.
**/

procedure exit (
  p_client_identifier in varchar2 default my_client_identifier -- The client identifier provided by the application or console itself.
);
/**

Exit/unset the preferences for a specific session/client_identifier.

If you exit/unset your own client preferencs then this has an immediate effect
as we can unset the preferences in our package state. If you exit another
session/client_identifier then it can take some seconds until the other
session/client_identifier is reloading the configuration from the context (if
available) or the client_prefs table. The default check interval for a changed
configuration is ten seconds.

Exit/unset the preferences means also the cached log entries will be flushed to
the logging table CONSOLE_LOGS. If you do not need the cached entries you can
delete them in advance by calling the `clear` procedure.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING CLIENT PREFERENCES.

**/

procedure exit_stale;
/**

Exit/unset the preferences for all sessions in the table console_client_prefs
which have a exit date in the past for at least one hour.

This procedure is used by the cleanup job (job name is CONSOLE_CLEANUP) which
runs per default at 1 o'clock after midnight.

DO NOT USE THIS PROCEDURE IN YOUR BUSINESS LOGIC. IT IS INTENDED ONLY FOR
MANAGING CLIENT PREFERENCES.

**/

--------------------------------------------------------------------------------

function context_is_available return boolean;
/**

Checks the availability of the global context. Returns true, if available and
false if not.

```sql
begin
  if not console.context_is_available then
    dbms_output.put_line('I need to speak with my DBA :-(');
  end if;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function context_is_available_yn return varchar2;
/**

Checks the availability of the global context. Returns `Y`, if available and `N`
if not.

```sql
select case when console.context_is_available_yn = 'N'
         then 'I need to speak with my DBA :-('
         else 'We have a global context :-)'
       end as "Test context availability"
  from dual;
```

**/


--------------------------------------------------------------------------------

function version return varchar2;
/**

Returns the version information from the console package.


```sql
select console.version from dual;
```

**/

--------------------------------------------------------------------------------

function split_to_table (
  p_string in varchar2,            -- The string to split into a table.
  p_sep    in varchar2 default ',' -- The separator.
) return t_vc2_tab pipelined;
/**

Splits a string into a (pipelined) SQL table of varchar2.

If the separator is null the string will be splitted into its characters.

EXAMPLE

```sql
select * from console.split_to_table('1,2,3');
```

| COLUMN_VALUE |
|--------------|
| 1            |
| 2            |
| 3            |

**/

--------------------------------------------------------------------------------

function split (
  p_string in varchar2,            -- The string to split into an array.
  p_sep    in varchar2 default ',' -- The separator.
) return t_vc2_tab_i;
/**

Splits a string into a PL/SQL associative array.

If the separator is null the string will be splitted into its characters.

EXAMPLE

```sql
set serveroutput on
declare
  v_array console.t_vc2_tab_i;
begin
  v_array := console.split('A,B,C');
  for i in 1 .. v_array.count loop
    console.print(i||': '||v_array(i));
  end loop;
end;
{{/}}

1: A
2: B
3: C
```

**/

--------------------------------------------------------------------------------

function join (
  p_table in t_vc2_tab_i,           -- The PL/SQL array to join into a string.
  p_sep   in varchar2 default ',' -- The separator.
) return varchar2;
/**

Joins a PL/SQL associative array into a string.

**/

--------------------------------------------------------------------------------

function to_yn ( p_bool in boolean ) return varchar2;
/**

Converts a boolean value to a string.

Returns `Y` when the input is true and `N` if the input is false or null.

**/

--------------------------------------------------------------------------------

function to_string ( p_bool in boolean ) return varchar2;
/**

Converts a boolean value to a string.

Returns `true` when the input is true and `false` if the input is false or null.

**/

--------------------------------------------------------------------------------

function to_bool ( p_string in varchar2 ) return boolean;
/**

Converts a string to a boolean value.

Returns true when the uppercased, trimmed input is `Y`, `YES`, `1` or `TRUE`. In
all other cases (also on null) false is returned.

**/

--------------------------------------------------------------------------------

function to_html_table (
  p_data_cursor       in sys_refcursor         ,
  p_comment           in varchar2 default null ,
  p_include_row_num   in boolean  default true ,
  p_max_rows          in integer  default 100  ,
  p_max_column_length in integer  default 1000 )
return clob;
/**

Helper to convert a cursor to a HTML table.

Note: As this helper is designed to work always it does not check your log
level. And if it would check, it would not help for the opening of the cursor,
which is done before. To save work for your database in cases you are not in
logging mode you should check the log level before open the cursor. Please see the
examples below.

EXAMPLES 1 - Open cursor in advance

```sql
declare
  v_dataset sys_refcursor;
begin
  -- Your business logic here.

  -- Debug code
  if console.level_is_info then
    open v_dataset for select * from user_tables;
    console.info(console.to_html_table(v_dataset));
  end if;
end;
{{/}}
```

EXAMPLES 2 - Open cursor in for loop

```sql
begin
  -- Your business logic here.

  -- Debug code
  if console.my_log_level >= console.c_level_info then
    for i in (
      select console.to_html_table(cursor(select * from user_tables)) as html
        from dual )
    loop
      console.info(i.html);
    end loop;
  end if;
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function to_md_code_block (
  p_text in varchar2 )
return varchar2;
/**

Converts the given text to a Markdown code block by indent each line with four
spaces.

**/

--------------------------------------------------------------------------------

function to_md_tab_header (
  p_key   in varchar2 default 'Attribute' ,
  p_value in varchar2 default 'Value'     )
return varchar2;
/**

Converts the given key and value strings to a Markdown table header.

`to_md_tab_header` will return the following Markdown table header:

```md
| Attribute                      | Value                                       |
| ------------------------------ | ------------------------------------------- |
```

**/

function to_md_tab_data (
  p_key              in varchar2               ,
  p_value            in varchar2               ,
  p_value_max_length in integer  default 1000  ,
  p_show_null_values in boolean  default false )
return varchar2;
/**

Converts the given key and value strings to a Markdown table data row.

EXAMPLE

`to_md_tab_header('CLIENT_IDENTIFIER', '{o,o} 4C8E71DF0001')` will return the
following Markdown table row:

```md
| CLIENT_IDENTIFIER              | {o,o} 4C8E71DF0001                          |

```

**/

function to_unibar (
  p_value                   in number            ,
  p_scale                   in number default 1  ,
  p_width_block_characters  in number default 25 ,
  p_fill_scale              in number default 0
) return varchar2 deterministic;
/**

Returns a text bar consisting of unicode block characters.

You can build simple text based bar charts with it. Not all fonts implement
clean block characters, so the result depends a little bit on the font. The
unicode block characters can have eight different widths from 1/8 up to 8/8 -
together with the default width of a bar char of 25 characters you can show bar
charts with a precision of 0.5 percent - that is not bad for a text based bar
chart...

EXAMPLE

```sql
column textbar format a30

select 'Some text'       as description, 0.84 as value, console.to_unibar(0.84) as textbar from dual union all
select 'Some other text' as description, 0.75 as value, console.to_unibar(0.75) as textbar from dual union all
select 'Bla bla bla'     as description, 0.54 as value, console.to_unibar(0.54) as textbar from dual;
```

RESULT

```
DESCRIPTION          VALUE TEXTBAR
--------------- ---------- ------------------------------
Some text              .84 █████████████████████
Some other text        .75 ██████████████████▊
Bla bla bla            .54 █████████████▌
```

**/

--------------------------------------------------------------------------------

procedure print ( p_message in varchar2 );
/**

An alias for dbms_output.put_line.

Writing dbms_output.put_line is very annoying for me...

**/

--------------------------------------------------------------------------------

procedure printf (
  p_message in varchar2              ,
  p0        in varchar2 default null ,
  p1        in varchar2 default null ,
  p2        in varchar2 default null ,
  p3        in varchar2 default null ,
  p4        in varchar2 default null ,
  p5        in varchar2 default null ,
  p6        in varchar2 default null ,
  p7        in varchar2 default null ,
  p8        in varchar2 default null ,
  p9        in varchar2 default null );
/**

A shorthand for

```
begin
  console.print(console.format('A string with %s %s.', 'dynamic', 'content'));
  --is equivalent to
  console.printf('A string with %s %s.', 'dynamic', 'content');
end;
{{/}}
```

Also see [console.format](#function-format)

**/

--------------------------------------------------------------------------------

function  runtime ( p_start in timestamp ) return varchar2;
/**

Returns a string in the format hh24:mi:ss.ff6 (for example 00:00:01.123456).

Is internally used by the `time_end` method and uses `localtimestamp` to compare
with `p_start`.

EXAMPLE

```sql
set serveroutput on
declare
  v_start timestamp := localtimestamp;
begin

  --do your stuff here

  dbms_output.put_line('Runtime: ' || console.runtime(v_start));
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function runtime_seconds ( p_start in timestamp ) return number;
/**

Subtracts the start `localtimestamp` from the current `localtimestamp` and
returns the exracted seconds.

EXAMPLE

```sql
set serveroutput on
declare
  v_start timestamp := localtimestamp;
begin

  --do your stuff here

  dbms_output.put_line (
    'Runtime (seconds): ' || to_char(console.runtime_seconds(v_start)) );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function runtime_milliseconds ( p_start in timestamp ) return number;
/**

Subtracts the start `localtimestamp` from the current `localtimestamp` and
returns the exracted milliseconds.

EXAMPLE

```sql
set serveroutput on
declare
  v_start timestamp := localtimestamp;
begin

  --do your stuff here

  dbms_output.put_line (
    'Runtime (milliseconds): ' || to_char(console.runtime_milliseconds(v_start)) );
end;
{{/}}
```

**/

--------------------------------------------------------------------------------

function level_name (p_level in integer) return varchar2 deterministic;
/**

Returns the level name for a given level id and null, if the level is not
between 0 and 4.

**/

--------------------------------------------------------------------------------

function scope return varchar2;
/**

Get the current scope (method, line number) from the call stack.

Is used internally by console to automatically provide the scope attribute for a
log entry.

**/

--------------------------------------------------------------------------------

function calling_unit return varchar2;
/**

Get the calling unit (OWNER.UNIT) from the call stack.

Is used internally by console to check if unit is configured for current log
level.

**/

--------------------------------------------------------------------------------

function call_stack return varchar2;
/**

Get the current call stack (and error stack/backtrace, if available).

Is used internally by console to provide the call stack for a log entry when
requested by one of the logging methods (which is the default for error and
trace).

**/

--------------------------------------------------------------------------------

function apex_env return clob;
/**

Get the current APEX environment.

Is used internally by console to provide the APEX environment for a log entry
when requested by one of the logging methods.

**/

--------------------------------------------------------------------------------

function cgi_env return varchar2;
/**

Get the current CGI environment.

Is used internally by console to provide the CGI environment for a log entry
when requested by one of the logging methods.

**/

--------------------------------------------------------------------------------

function user_env return varchar2;
/**

Get the current user environment.

Is used internally by console to provide the user environment for a log entry
when requested by one of the logging methods.

**/

--------------------------------------------------------------------------------

function console_env return varchar2;
/**

Get the current console environment.

Is used internally by console to provide the console environment for a log entry
when requested by one of the logging methods.

**/

--------------------------------------------------------------------------------
procedure clob_append (
  p_clob  in out nocopy clob     ,
  p_cache in out nocopy varchar2 ,
  p_text  in            varchar2 );
/**

High performance clob concatenation. Also see clob_flush_cache below.

Is used internally by console for the table method (and other things). Do not
forget a final flush cache call when you use it in your own code.

EXAMPLE

```sql
set serveroutput on feedback off
declare
  v_start  timestamp := localtimestamp;
  v_clob   clob;
  v_cache  varchar2(32767 char);
begin
  for i in 1..100000 loop
    console.clob_append(v_clob, v_cache, 'a');
  end loop;
  console.clob_flush_cache(v_clob, v_cache);
  dbms_output.put_line('Runtime (seconds): ' || to_char(console.runtime_seconds(v_start)));
  dbms_output.put_line('Lenght CLOB      : ' || length(v_clob));
end;
{{/}}
```

**/

procedure clob_append (
  p_clob  in out nocopy clob     ,
  p_cache in out nocopy varchar2 ,
  p_text  in            clob     );
/**

High performance clob concatenation.

Overloaded method for appending a clob. Also see clob_append above with p_text
beeing a varchar2 parameter and clob_flush_cache below.

**/

procedure clob_flush_cache (
  p_clob  in out nocopy clob     ,
  p_cache in out nocopy varchar2 );
/**

Flushes finally the cache in a high performance clob concatenation.

Also see clob_append above.

**/

--------------------------------------------------------------------------------

function view_cache return t_logs_tab pipelined;
/**

View the content of the log cache.

EXAMPLE

```sql
--init logging for own session
exec console.init(
  p_level          => c_level_debug ,
  p_duration       => 90            ,
  p_cache_size     => 1000          ,
  p_check_interval => 30            );

--test some business logic
begin
  --your code here;

  console.log('test', p_user_env => true);
end;
{{/}}

--check current cache entries
select * from console.view_cache();
```

**/

--------------------------------------------------------------------------------

procedure flush_cache;
/**

Flushes the log cache and writes down the entries to the log table.

**/

--------------------------------------------------------------------------------

procedure clear ( p_client_identifier in varchar2 default my_client_identifier );
/**

Clears the cached log entries (if any).

This procedure is useful when you have initialized your own session with a cache
size greater then zero (for example 1000) and you take a look at the log entries
with the pipelined function `console.view_cache` or
`console.view_last([numRows])` during development. By clearing the cache you can
avoid spoiling your CONSOLE_LOGS table with entries you do not need anymore.

**/

--------------------------------------------------------------------------------

function view_status return t_key_value_tab pipelined;
/**

View the current package status (config, number entries cache/timer/counter,
version etc.).

EXAMPLE

```sql
select * from console.view_status();
```

**/

--------------------------------------------------------------------------------
procedure purge (
  p_min_level in integer default c_level_info, -- Delete log entries greater or equal the given level.
  p_min_days  in number  default 30 );         -- Delete log entries older than the given minimum days.
/**

Deletes log entries for the given condition.

Deletion is only allowed for the owner of the package console.

EXAMPLES

```sql
--> default: all level info, debug and trace older than 30 days
exec console.purge;

--> all three examples are equivalent
exec console.purge(3, 0.25);
exec console.purge(console.c_level_info, 0.25);
exec console.purge(p_min_level => console.c_level_info, p_min_days => 0.25);
```

**/

procedure purge_all;
/**

Deletes all log entries except level permanent.

Deletion is only allowed for the owner of the package console.

EXAMPLE

```sql
exec console.purge_all;
```

**/

procedure cleanup_job_create (
  p_repeat_interval in varchar2 default 'FREQ=DAILY;BYHOUR=1;' , -- See the Oracle docs: https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/scheduling-jobs-with-oracle-scheduler.html#GUID-10B1E444-8330-4EC9-85F8-9428D749F7D5
  p_min_level       in integer  default c_level_info           , -- Delete log entries greater or equal the given level.
  p_min_days        in number   default 30                       -- Delete log entries older than the given minimum days.
);
/**
Creates a cleanup job which deletes old log entries from console_logs and stale
debug sessions from console_client_prefs.
**/
procedure cleanup_job_drop;    /** Drops the cleanup job (if it exists).    **/
procedure cleanup_job_enable;  /** Enables the cleanup job (if it exists).  **/
procedure cleanup_job_disable; /** Disables the cleanup job (if it exists). **/
procedure cleanup_job_run;     /** Runs the cleanup job (if it exists).     **/

--------------------------------------------------------------------------------
-- PRIVATE HELPER METHODS (only visible when ccflag `utils_public` is set to true)
--------------------------------------------------------------------------------

$if $$utils_public $then

function utl_escape_md_tab_text (p_text varchar2) return varchar2;
function utl_last_error return varchar2;
function utl_logging_is_enabled (p_level integer) return boolean;
function utl_normalize_label (p_label varchar2) return varchar2;
function utl_read_client_prefs (p_client_identifier varchar2) return console_client_prefs%rowtype result_cache;
function utl_read_global_conf return console_global_conf%rowtype result_cache;
function utl_replace_linebreaks (p_text varchar2, p_replace_with varchar2 default ' ') return varchar2;
procedure utl_ctx_check_availability;
procedure utl_ctx_clear (p_client_identifier varchar2);
procedure utl_ctx_clear_all;
procedure utl_ctx_set (p_attribute varchar2, p_value varchar2, p_client_identifier varchar2);
procedure utl_load_session_configuration;
procedure utl_set_client_identifier;
--
function utl_create_log_entry (
  p_level           in integer                ,
  p_message         in clob     default null  ,
  p_permanent       in boolean  default false ,
  p_call_stack      in boolean  default false ,
  p_apex_env        in boolean  default false ,
  p_cgi_env         in boolean  default false ,
  p_console_env     in boolean  default false ,
  p_user_env        in boolean  default false ,
  p_user_agent      in varchar2 default null  ,
  p_user_scope      in varchar2 default null  ,
  p_user_error_code in integer  default null  ,
  p_user_call_stack in varchar2 default null  )
return console_logs.log_id%type;

$end

end console;
/
