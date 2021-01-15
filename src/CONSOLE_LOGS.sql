--FOR DEVELOPMENT ONLY - UNCOMMENT THE NEXT TWO LINES TEMPORARELY WHEN YOU NEED IT
--begin for i in (select 1 from user_tables where table_name = 'CONSOLE_LOGS') loop execute immediate 'drop table console_logs purge'; end loop; end;
--/

declare
  v_table_name        varchar2(  30 char) := 'CONSOLE_LOGS';
  v_index_column_list varchar2(1000 char) := 'LOG_TIME, LOG_LEVEL';
  v_count             pls_integer;
begin

  --create table
  select count(*) into v_count from user_tables where table_name = v_table_name;
  if v_count = 0 then
    dbms_output.put_line('- Table ' || v_table_name || ' not found, run creation command');
    execute immediate replace(q'{
      create table #TABLE_NAME# (
        log_id             integer                                               generated by default on null as identity,
        log_time           timestamp with local time zone  default systimestamp  not null  ,
        log_level          integer                                                         ,
        action             varchar2(  64 char)                                             ,
        message            clob                                                            ,
        call_stack         varchar2(4000 char)                                             ,
        module             varchar2(  64 char)                                             ,
        client_info        varchar2(  64 char)                                             ,
        session_user       varchar2(  32 char)                                             ,
        unique_session_id  varchar2(  16 char)                                             ,
        client_identifier  varchar2(  64 char)                                             ,
        ip_address         varchar2(  32 char)                                             ,
        host               varchar2(  64 char)                                             ,
        os_user            varchar2(  64 char)                                             ,
        os_user_agent      varchar2( 200 char)                                             ,
        instance           integer                                                         ,
        instance_name      varchar2(  32 char)                                             ,
        service_name       varchar2(  64 char)                                             ,
        sid                integer                                                         ,
        sessionid          varchar2(  64 char)                                             ,
        --
        constraint #TABLE_NAME#_check_level check (log_level in (0,1,2,3,4))
      )
    }','#TABLE_NAME#', v_table_name);
  else
    dbms_output.put_line('- Table ' || v_table_name || ' found, no action required');
  end if;

  --create index
  with t as (
    select listagg(column_name, ', ') within group(order by column_position) as index_column_list
      from user_ind_columns
     where table_name = v_table_name
  )
  select count(*)
    into v_count
    from t
   where index_column_list = v_index_column_list;
  if v_count = 0 then
    dbms_output.put_line('- Index for column list ' || v_index_column_list || ' not found, run creation command');
    execute immediate replace(replace('
      create index #TABLE_NAME#_ix on #TABLE_NAME# (#INDEX_COLUMN_LIST#)
    ',
    '#TABLE_NAME#',        v_table_name),
    '#INDEX_COLUMN_LIST#', v_index_column_list);
  else
    dbms_output.put_line('- Index for column list ' || v_index_column_list || ' found, no action required');
  end if;

end;
/

prompt - Create table comments
comment on table console_logs                    is 'Table for log entries of the package CONSOLE. Column names are mostly driven by the attribute names of SYS_CONTEXT(''USERENV'') and DBMS_SESSION for easier mapping and clearer context.';
comment on column console_logs.log_id            is 'Primary key based on a sequence.';
comment on column console_logs.log_time          is 'Log entry timestamp.';
comment on column console_logs.log_level         is 'Log entry level. Can be 0 (permanent), 1 (error), 2 (warning), 3 (info) or 4 (verbose).';
comment on column console_logs.action            is 'The action/position in the module (application name). Can be set through the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.message           is 'The log message.';
comment on column console_logs.call_stack        is 'The call_stack. Will only be provided on log level 1 (call of console.error) or on demand by providing p_trace => true to the other logging methods.';
comment on column console_logs.module            is 'The application name (module). Can be set by an application using the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.client_info       is 'The client information. Can be set by an application using the DBMS_APPLICATION_INFO package or OCI.';
comment on column console_logs.session_user      is 'The name of the session user (the user who logged on). This may change during the duration of a database session as Real Application Security sessions are attached or detached. For enterprise users, returns the schema. For other users, returns the database user name. If a Real Application Security session is currently attached to the database session, returns user XS$NULL.';
comment on column console_logs.unique_session_id is 'An identifier that is unique for all sessions currently connected to the database. Provided by DBMS_SESSION.UNIQUE_SESSION_ID. Is constructed by sid, serial# and inst_id from (g)v$session (undocumented, there is no official way to construct this ID by yourself, but we need to do this to identify a session).';
comment on column console_logs.client_identifier is 'The client identifier. Can be set by an application using the DBMS_SESSION.SET_IDENTIFIER procedure, the OCI attribute OCI_ATTR_CLIENT_IDENTIFIER, or Oracle Dynamic Monitoring Service (DMS). This attribute is used by various database components to identify lightweight application users who authenticate as the same database user.';
comment on column console_logs.ip_address        is 'IP address of the machine from which the client is connected. If the client and server are on the same machine and the connection uses IPv6 addressing, then it is set to ::1.';
comment on column console_logs.host              is 'Name of the host machine from which the client is connected.';
comment on column console_logs.os_user           is 'Operating system user name of the client process that initiated the database session.';
comment on column console_logs.os_user_agent     is 'Operating system user agent (web browser engine). This information will only be available, if we overwrite the console.error method of the client browser and bring these errors back to the server. For APEX we will have a plug-in in the future to do this.';
comment on column console_logs.instance          is 'The instance identification number of the current instance.';
comment on column console_logs.instance_name     is 'The name of the instance.';
comment on column console_logs.service_name      is 'The name of the service to which a given session is connected.';
comment on column console_logs.sid               is 'The session ID. Is not unique, the same id can be shown on different instances, which are different sessions.';
comment on column console_logs.sessionid         is 'The auditing session identifier. You cannot use this attribute in distributed SQL statements.';



