create or replace package body console_parameter_test as

function actual_log_message return console_logs.message%type as
   l_log_message console_logs.message%type;
begin
   select message
   into l_log_message
   from console_logs;

   return l_log_message;
end actual_log_message;


procedure varchar2_parameter as
   l_parameter_name varchar2(100) := 'Test varchar2_parameter';
   l_parameter_value varchar2(100) := 'Some test';
   l_expected_logging_message_pattern console_logs.message%type := '.*' || console_test_helpers.c_parameters_heading ||
      '\s\| ' || l_parameter_name || '\s*\| ' || l_parameter_value || '\s*\|\s*';
begin
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end varchar2_parameter;


procedure truncated_varchar2_parameter as
   l_parameter_name varchar2(100) := 'truncated_varchar2_parameter';
   l_parameter_value varchar2(4000) := 'Some test';
   l_expected_logging_message_pattern console_logs.message%type;
begin
   l_parameter_value := rpad('test', 3004, 'u');
   l_expected_logging_message_pattern := '.*' || console_test_helpers.c_parameters_heading || '\s\| ' ||
      l_parameter_name || '\s*\| ' || 'test(u){1996}' || '\s*\|\s*';

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end truncated_varchar2_parameter;


procedure number_parameter as
   l_parameter_name varchar2(100) := 'Test number_parameter';
   l_parameter_value number := 1855;
   l_expected_logging_message_pattern console_logs.message%type := '.*' ||
      console_test_helpers.c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' ||
      l_parameter_value || '\s*\|\s*';
begin
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end number_parameter;


procedure date_parameter as
   l_parameter_name varchar2(100) := 'Test date_parameter';
   l_parameter_value date := to_date('29.02.2024', 'dd.mm.yyyy');
   l_expected_logging_message_pattern console_logs.message%type := '.*' ||
      console_test_helpers.c_parameters_heading || '\s\| ' || l_parameter_name || '\s*\| ' ||
      to_char(l_parameter_value, 'yyyy-mm-dd hh24:mi:ss') || '\s*\|\s*';
begin
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end date_parameter;


procedure timestamp_parameter as
   l_parameter_name varchar2(100) := 'Test timestamp_parameter';
   l_parameter_value timestamp := to_timestamp('29.02.2024 12:31:56.126988774', 'dd.mm.yyyy hh24:mi:ss.ff9');
   l_expected_logging_message_pattern console_logs.message%type := '.*' || console_test_helpers.c_parameters_heading ||
      '\s\| ' || l_parameter_name || '\s*\| ' || to_char(l_parameter_value, 'yyyy-mm-dd hh24:mi:ss.ff9') || '\s*\|\s*';
begin
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end timestamp_parameter;


procedure timestamp_with_time_zone_parameter as
   l_parameter_name varchar2(100) := 'Test timestamp_with_time_zone_parameter';
   l_parameter_value timestamp with time zone := to_timestamp_tz('29.02.2024 15:37:56.166988794 UTC',
      'dd.mm.yyyy hh24:mi:ss.FF9 tzr');
   l_expected_logging_message_pattern console_logs.message%type := '.*' || console_test_helpers.c_parameters_heading ||
      '\s\| ' || l_parameter_name || '\s*\| ' || to_char(l_parameter_value, 'yyyy-mm-dd hh24:mi:ss.ff9 tzr') ||
      '\s*\|\s*';
begin
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end timestamp_with_time_zone_parameter;


procedure timestamp_with_local_time_zone_parameter as
   l_parameter_name varchar2(100) := 'Test timestamp_with_local_time_zone_parameter';
   l_parameter_value timestamp with local time zone;
   l_hours_offset number := 12;
   l_expected_logging_message_pattern console_logs.message%type;
begin
   execute immediate q'[ALTER SESSION SET TIME_ZONE = 'UTC']';

   l_parameter_value := to_timestamp_tz('29.02.2024 15:37:56.166988794 UTC', 'dd.mm.yyyy hh24:mi:ss.FF9 tzr');
   l_expected_logging_message_pattern := '.*' || console_test_helpers.c_parameters_heading || '\s\| ' ||
      l_parameter_name || '\s*\| ' || to_char(l_parameter_value + numtodsinterval(l_hours_offset, 'HOUR'),
      'yyyy-mm-dd hh24:mi:ss.ff9') || ' \+' || to_char(l_hours_offset) || ':00' || '\s*\|\s*';

   execute immediate q'[ALTER SESSION SET TIME_ZONE = '+]' || to_char(l_hours_offset) || q'[:00']';

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end timestamp_with_local_time_zone_parameter;


procedure interval_ym_parameter as
   l_parameter_name varchar2(100) := 'Test interval_ym_parameter';
   l_parameter_value interval year to month := interval '1-2' year to month;
   l_expected_logging_message_pattern console_logs.message%type := '.*' || console_test_helpers.c_parameters_heading ||
      '\s\| ' || l_parameter_name || '\s*\| ' || '\+01-02' || '\s*\|\s*';
begin
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end interval_ym_parameter;


procedure interval_ds_parameter as
   l_parameter_name varchar2(100) := 'Test interval_ds_parameter';
   l_parameter_value interval day to second := interval '10 18:30:15.12' day to second;
   l_expected_logging_message_pattern console_logs.message%type := '.*' || console_test_helpers.c_parameters_heading ||
      '\s\| ' || l_parameter_name || '\s*\| ' || '\+10 18:30:15.120000' || '\s*\|\s*';
begin
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end interval_ds_parameter;


procedure boolean_parameter as
   l_parameter_name varchar2(100) := 'Test boolean_parameter';
   l_parameter_value boolean := true;
   l_expected_logging_message_pattern console_logs.message%type := '.*' || console_test_helpers.c_parameters_heading ||
      '\s\| ' || l_parameter_name || '\s*\| ' || 'true' || '\s*\|\s*';
begin
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end boolean_parameter;


procedure clob_parameter as
   l_parameter_name varchar2(100) := 'Test clob_parameter';
   l_parameter_value clob := 'Some large value';
   l_expected_logging_message_pattern console_logs.message%type := '.*' || console_test_helpers.c_parameters_heading ||
      '\s\| ' || l_parameter_name || '\s*\| ' || l_parameter_value || '\s*\|\s*';
begin
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end clob_parameter;


procedure truncated_clob_parameter as
   l_parameter_name varchar2(100) := 'truncated_clob_parameter';
   l_parameter_value clob := 'Some test';
   l_expected_logging_message_pattern console_logs.message%type;
begin
   l_parameter_value := rpad('test', 3004, 'u');
   l_expected_logging_message_pattern := '.*' || console_test_helpers.c_parameters_heading || '\s\| ' ||
      l_parameter_name || '\s*\| ' || 'test(u){1996}' || '\s*\|\s*';

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end truncated_clob_parameter;


procedure xmltype_parameter as
   l_parameter_name varchar2(100) := 'Test xmltype_parameter';
   l_parameter_value xmltype := xmltype.createxml('<test>Test value</test>');
   l_expected_logging_message_pattern console_logs.message%type := '.*' || console_test_helpers.c_parameters_heading ||
      '\s\| ' || l_parameter_name || '\s*\| ' || l_parameter_value.getclobval() || '\s*\|\s*';
begin
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end xmltype_parameter;


procedure truncated_xmltype_parameter as
   l_parameter_name varchar2(100) := 'truncated_xmltype_parameter';
   l_parameter_value xmltype;
   l_expected_logging_message_pattern console_logs.message%type;
   l_xml_filler varchar2(10) := '<test/>';
begin
   l_parameter_value := xmltype.createxml('<root>' || rpad(l_xml_filler, length(l_xml_filler) * 500, l_xml_filler) ||
      '</root>');

   l_expected_logging_message_pattern := '.*' || console_test_helpers.c_parameters_heading || '\s\| ' ||
      l_parameter_name || '\s*\| ' || '<root>(' || l_xml_filler || '){284}' || substr(l_xml_filler, 1, 6) || '\s*\|\s*';

   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end truncated_xmltype_parameter;


procedure long_parameter_name as

   l_parameter_name varchar2(200) := 'very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_very_long_parameter_name';
   l_parameter_value varchar2(100) := 'Small value';
   l_expected_logging_message_pattern console_logs.message%type := '.*' || console_test_helpers.c_parameters_heading ||
      '\s\| ' || substr(l_parameter_name, 1, 128) || '\s*\| ' || l_parameter_value || '\s*\|\s*';
begin
   console.add_param(l_parameter_name, l_parameter_value);
   console.log('Parameter test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end long_parameter_name;


procedure three_parameters_classic as
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';
   l_parameter_3_name varchar2(100) := 'param_3';

   l_parameter_1_value varchar2(100) := 'Some random value';
   l_parameter_2_value number := 478465;
   l_parameter_3_value date := to_date('29.03.2025 13:45:08', 'dd.mm.yyyy hh24:mi:ss');

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| ' || l_parameter_1_value || '\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| ' || l_parameter_2_value || '\s*\|\s' ||
      '\| ' || l_parameter_3_name || '\s*\| ' || to_char(l_parameter_3_value, 'yyyy-mm-dd hh24:mi:ss') || '\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value);
   console.add_param(l_parameter_2_name, l_parameter_2_value);
   console.add_param(l_parameter_3_name, l_parameter_3_value);
   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end three_parameters_classic;


procedure three_parameters_builder_pattern as
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';
   l_parameter_3_name varchar2(100) := 'param_3';

   l_parameter_1_value varchar2(100) := 'Some random value again';
   l_parameter_2_value number := 4784645;
   l_parameter_3_value date := to_date('26.04.2025 11:42:08', 'dd.mm.yyyy hh24:mi:ss');

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| ' || l_parameter_1_value || '\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| ' || l_parameter_2_value || '\s*\|\s' ||
      '\| ' || l_parameter_3_name || '\s*\| ' || to_char(l_parameter_3_value, 'yyyy-mm-dd hh24:mi:ss') || '\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value)
      .add_param(l_parameter_2_name, l_parameter_2_value)
      .add_param(l_parameter_3_name, l_parameter_3_value);
   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end three_parameters_builder_pattern;

procedure parameter_builder_pattern_procedure_varchar2 is
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';

   l_parameter_1_value varchar2(100) := 'Some random value';
   l_parameter_2_value varchar2(100) := 'Another random value';

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| ' || l_parameter_1_value || '\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| ' || l_parameter_2_value || '\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value)
         .add_param(l_parameter_2_name, l_parameter_2_value);

   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end parameter_builder_pattern_procedure_varchar2;

---------------------------------------------------------------------------
procedure parameter_builder_pattern_procedure_number is
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';

   l_parameter_1_value number := 12345;
   l_parameter_2_value number := 67890;

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| ' || to_char(l_parameter_1_value) || '\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| ' || to_char(l_parameter_2_value) || '\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value)
         .add_param(l_parameter_2_name, l_parameter_2_value);

   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end parameter_builder_pattern_procedure_number;

---------------------------------------------------------------------------
procedure parameter_builder_pattern_procedure_date is
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';

   l_parameter_1_value date := to_date('01.01.2024', 'dd.mm.yyyy');
   l_parameter_2_value date := to_date('02.02.2024', 'dd.mm.yyyy');

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| ' || to_char(l_parameter_1_value, 'yyyy-mm-dd hh24:mi:ss') || '\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| ' || to_char(l_parameter_2_value, 'yyyy-mm-dd hh24:mi:ss') || '\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value)
         .add_param(l_parameter_2_name, l_parameter_2_value);

   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end parameter_builder_pattern_procedure_date;

---------------------------------------------------------------------------
procedure parameter_builder_pattern_procedure_timestamp is
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';

   l_parameter_1_value timestamp := to_timestamp('01.01.2024 10:20:30.123456', 'dd.mm.yyyy hh24:mi:ss.ff9');
   l_parameter_2_value timestamp := to_timestamp('02.02.2024 10:20:30.123456', 'dd.mm.yyyy hh24:mi:ss.ff9');

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| ' || to_char(l_parameter_1_value, 'yyyy-mm-dd hh24:mi:ss.ff9') || '\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| ' || to_char(l_parameter_2_value, 'yyyy-mm-dd hh24:mi:ss.ff9') || '\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value)
         .add_param(l_parameter_2_name, l_parameter_2_value);

   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end parameter_builder_pattern_procedure_timestamp;

---------------------------------------------------------------------------
procedure parameter_builder_pattern_procedure_timestamp_tz is
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';

   l_parameter_1_value timestamp with time zone := to_timestamp_tz('2024-01-01 10:20:30 +01:00', 'yyyy-mm-dd hh24:mi:ss tzh:tzm');
   l_parameter_2_value timestamp with time zone := to_timestamp_tz('2024-02-02 20:30:40 +02:00', 'yyyy-mm-dd hh24:mi:ss tzh:tzm');

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| ' || to_char(l_parameter_1_value, 'yyyy-mm-dd hh24:mi:ss.ff9 \tzh:tzm') || '\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| ' || to_char(l_parameter_2_value, 'yyyy-mm-dd hh24:mi:ss.ff9 \tzh:tzm') || '\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value)
         .add_param(l_parameter_2_name, l_parameter_2_value);

   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end parameter_builder_pattern_procedure_timestamp_tz;

---------------------------------------------------------------------------
procedure parameter_builder_pattern_procedure_timestamp_ltz is
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';

   l_parameter_1_value timestamp with local time zone;
   l_parameter_2_value timestamp with local time zone;
   l_hours_offset number := 12;

   l_expected_logging_message_pattern console_logs.message%type;
begin
   execute immediate q'[ALTER SESSION SET TIME_ZONE = 'UTC']';

   l_parameter_1_value := to_timestamp_tz('2024-01-01 10:20:30 UTC', 'yyyy-mm-dd hh24:mi:ss tzr');
   l_parameter_2_value := to_timestamp_tz('2024-02-02 20:30:40 UTC', 'yyyy-mm-dd hh24:mi:ss tzr');
   l_expected_logging_message_pattern :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| ' || to_char(l_parameter_1_value + numtodsinterval(l_hours_offset, 'HOUR'), 'yyyy-mm-dd hh24:mi:ss.ff9') ||
      ' \+' || to_char(l_hours_offset) || ':00' || '\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| ' || to_char(l_parameter_2_value + numtodsinterval(l_hours_offset, 'HOUR'), 'yyyy-mm-dd hh24:mi:ss.ff9') ||
      ' \+' || to_char(l_hours_offset) || ':00' || '\s*\|\s*';

   execute immediate q'[ALTER SESSION SET TIME_ZONE = '+]' || to_char(l_hours_offset) || q'[:00']';

   console.add_param(l_parameter_1_name, l_parameter_1_value)
         .add_param(l_parameter_2_name, l_parameter_2_value);

   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end parameter_builder_pattern_procedure_timestamp_ltz;


---------------------------------------------------------------------------
procedure parameter_builder_pattern_procedure_interval_ym is
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';

   l_parameter_1_value interval year to month := interval '1-2' year to month;
   l_parameter_2_value interval year to month := interval '3-4' year to month;

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| ' || '\+01-02' || '\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| ' || '\+03-04' || '\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value)
         .add_param(l_parameter_2_name, l_parameter_2_value);

   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end parameter_builder_pattern_procedure_interval_ym;

---------------------------------------------------------------------------
procedure parameter_builder_pattern_procedure_interval_ds is
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';

   l_parameter_1_value interval day to second := interval '1 2:3:4' day to second;
   l_parameter_2_value interval day to second := interval '5 6:7:8' day to second;

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| ' || '\+01 02:03:04.000000' || '\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| ' || '\+05 06:07:08.000000' || '\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value)
         .add_param(l_parameter_2_name, l_parameter_2_value);

   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end parameter_builder_pattern_procedure_interval_ds;

---------------------------------------------------------------------------
procedure parameter_builder_pattern_procedure_boolean is
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';

   l_parameter_1_value boolean := true;
   l_parameter_2_value boolean := false;

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| true\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| false\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value)
         .add_param(l_parameter_2_name, l_parameter_2_value);

   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end parameter_builder_pattern_procedure_boolean;

---------------------------------------------------------------------------
procedure parameter_builder_pattern_procedure_clob is
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';

   l_parameter_1_value clob := to_clob('Clob test content 1');
   l_parameter_2_value clob := to_clob('Clob test content 2');

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| Clob test content 1\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| Clob test content 2\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value)
         .add_param(l_parameter_2_name, l_parameter_2_value);

   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end parameter_builder_pattern_procedure_clob;

---------------------------------------------------------------------------
procedure parameter_builder_pattern_procedure_xmltype is
   l_parameter_1_name varchar2(100) := 'param_1';
   l_parameter_2_name varchar2(100) := 'param_2';

   l_parameter_1_value xmltype := xmltype('<test>value1</test>');
   l_parameter_2_value xmltype := xmltype('<test>value2</test>');

   l_expected_logging_message_pattern console_logs.message%type :=
      '.*' || console_test_helpers.c_parameters_heading || '\s' ||
      '\| ' || l_parameter_1_name || '\s*\| ' || l_parameter_1_value.getclobval() || '\s*\|\s' ||
      '\| ' || l_parameter_2_name || '\s*\| ' || l_parameter_2_value.getclobval() || '\s*\|\s*';
begin
   console.add_param(l_parameter_1_name, l_parameter_1_value)
         .add_param(l_parameter_2_name, l_parameter_2_value);

   console.log('Parameters test');

   ut.expect(actual_log_message()).to_match(l_expected_logging_message_pattern);
end parameter_builder_pattern_procedure_xmltype;

end console_parameter_test;
/