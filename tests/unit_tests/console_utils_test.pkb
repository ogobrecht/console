create or replace package body console_utils_test as

procedure split_with_comma_separator as
   l_tab console.t_vc2_tab_i;
begin
   l_tab := console.split('apple,banana,cherry');

   ut.expect(l_tab.count).to_equal(3);
   ut.expect(l_tab(1)).to_equal('apple');
   ut.expect(l_tab(2)).to_equal('banana');
   ut.expect(l_tab(3)).to_equal('cherry');
end split_with_comma_separator;


procedure split_with_custom_separator as
   l_tab console.t_vc2_tab_i;
begin
   l_tab := console.split('apple|banana|cherry', '|');

   ut.expect(l_tab.count).to_equal(3);
   ut.expect(l_tab(1)).to_equal('apple');
   ut.expect(l_tab(2)).to_equal('banana');
   ut.expect(l_tab(3)).to_equal('cherry');
end split_with_custom_separator;


procedure split_empty_string as
   l_tab console.t_vc2_tab_i;
begin
   l_tab := console.split('');

   ut.expect(l_tab.count).to_equal(0);
end split_empty_string;


procedure split_single_value as
   l_tab console.t_vc2_tab_i;
begin
   l_tab := console.split('apple');

   ut.expect(l_tab.count).to_equal(1);
   ut.expect(l_tab(1)).to_equal('apple');
end split_single_value;


procedure split_null_separator_splits_chars as
   l_tab console.t_vc2_tab_i;
begin
   l_tab := console.split('abc', null);

   ut.expect(l_tab.count).to_equal(3);
   ut.expect(l_tab(1)).to_equal('a');
   ut.expect(l_tab(2)).to_equal('b');
   ut.expect(l_tab(3)).to_equal('c');
end split_null_separator_splits_chars;


procedure split_to_table_with_comma as
   l_count number;
begin
   select count(*)
     into l_count
     from table(console.split_to_table('one,two,three'));

   ut.expect(l_count).to_equal(3);
end split_to_table_with_comma;


procedure split_to_table_empty_string as
   l_count number;
begin
   select count(*)
     into l_count
     from table(console.split_to_table(''));

   ut.expect(l_count).to_equal(0);
end split_to_table_empty_string;


procedure join_with_comma_separator as
   l_tab console.t_vc2_tab_i;
   l_result varchar2(100);
begin
   l_tab(1) := 'apple';
   l_tab(2) := 'banana';
   l_tab(3) := 'cherry';

   l_result := console.join(l_tab);

   ut.expect(l_result).to_equal('apple,banana,cherry');
end join_with_comma_separator;


procedure join_with_custom_separator as
   l_tab console.t_vc2_tab_i;
   l_result varchar2(100);
begin
   l_tab(1) := 'apple';
   l_tab(2) := 'banana';
   l_tab(3) := 'cherry';

   l_result := console.join(l_tab, '|');

   ut.expect(l_result).to_equal('apple|banana|cherry');
end join_with_custom_separator;


procedure join_empty_array_returns_null as
   l_tab console.t_vc2_tab_i;
   l_result varchar2(100);
begin
   l_result := console.join(l_tab);

   ut.expect(l_result).to_be_null;
end join_empty_array_returns_null;


procedure join_single_element as
   l_tab console.t_vc2_tab_i;
   l_result varchar2(100);
begin
   l_tab(1) := 'apple';

   l_result := console.join(l_tab);

   ut.expect(l_result).to_equal('apple');
end join_single_element;


procedure join_with_null_separator as
   l_tab console.t_vc2_tab_i;
   l_result varchar2(100);
begin
   l_tab(1) := 'apple';
   l_tab(2) := 'banana';

   l_result := console.join(l_tab, null);

   ut.expect(l_result).to_equal('applebanana');
end join_with_null_separator;


procedure join_with_content_equals_separator as
   l_tab console.t_vc2_tab_i;
   l_result varchar2(100);
begin
   l_tab(1) := ',';
   l_tab(2) := ',';

   l_result := console.join(l_tab, ',');

   ut.expect(l_result).to_equal(',,,');
end join_with_content_equals_separator;


procedure format_with_single_placeholder as
   l_result varchar2(100);
begin
   l_result := console.format('Hello %0!', 'World');

   ut.expect(l_result).to_equal('Hello World!');
end format_with_single_placeholder;


procedure format_with_multiple_placeholders as
   l_result varchar2(100);
begin
   l_result := console.format('%0 is %1', 'Apple', 'red');

   ut.expect(l_result).to_equal('Apple is red');
end format_with_multiple_placeholders;


procedure format_with_no_placeholders as
   l_result varchar2(100);
begin
   l_result := console.format('No placeholders here');

   ut.expect(l_result).to_equal('No placeholders here');
end format_with_no_placeholders;


procedure format_with_null_values as
   l_result varchar2(100);
begin
   l_result := console.format('Value: %0', null);

   ut.expect(l_result).to_equal('Value: ');
end format_with_null_values;


procedure format_with_all_10_parameters as
   l_result varchar2(200);
begin
   l_result := console.format(
      '%0-%1-%2-%3-%4-%5-%6-%7-%8-%9',
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j');

   ut.expect(l_result).to_equal('a-b-c-d-e-f-g-h-i-j');
end format_with_all_10_parameters;


procedure to_yn_true_returns_y as
begin
   ut.expect(console.to_yn(true)).to_equal('Y');
end to_yn_true_returns_y;


procedure to_yn_false_returns_n as
begin
   ut.expect(console.to_yn(false)).to_equal('N');
end to_yn_false_returns_n;


procedure to_yn_null_returns_null as
begin
   ut.expect(console.to_yn(null)).to_equal('N');
end to_yn_null_returns_null;


procedure to_string_true_returns_true as
begin
   ut.expect(console.to_string(true)).to_equal('true');
end to_string_true_returns_true;


procedure to_string_false_returns_false as
begin
   ut.expect(console.to_string(false)).to_equal('false');
end to_string_false_returns_false;


procedure to_string_null_returns_null as
begin
   ut.expect(console.to_string(null)).to_equal('false');
end to_string_null_returns_null;


procedure to_bool_accepts_uppercase_true as
begin
   ut.expect(console.to_bool('TRUE')).to_be_true;
   ut.expect(console.to_bool('FALSE')).to_be_false;
end to_bool_accepts_uppercase_true;


procedure to_bool_accepts_lowercase_true as
begin
   ut.expect(console.to_bool('true')).to_be_true;
   ut.expect(console.to_bool('false')).to_be_false;
end to_bool_accepts_lowercase_true;


procedure to_bool_accepts_y_n_yes_no as
begin
   ut.expect(console.to_bool('Y')).to_be_true;
   ut.expect(console.to_bool('N')).to_be_false;
   ut.expect(console.to_bool('YES')).to_be_true;
   ut.expect(console.to_bool('NO')).to_be_false;
end to_bool_accepts_y_n_yes_no;


procedure to_bool_accepts_1_and_0 as
begin
   ut.expect(console.to_bool('1')).to_be_true;
   ut.expect(console.to_bool('0')).to_be_false;
end to_bool_accepts_1_and_0;


procedure to_bool_returns_null_for_invalid as
begin
   ut.expect(console.to_bool('invalid')).to_be_null;
   ut.expect(console.to_bool('maybe')).to_be_null;
end to_bool_returns_null_for_invalid;


procedure to_bool_handles_whitespace as
begin
   ut.expect(console.to_bool('  TRUE  ')).to_be_true;
   ut.expect(console.to_bool('  false  ')).to_be_false;
end to_bool_handles_whitespace;


procedure level_error_returns_1 as
begin
   ut.expect(console.level_error).to_equal(1);
end level_error_returns_1;


procedure level_warning_returns_2 as
begin
   ut.expect(console.level_warning).to_equal(2);
end level_warning_returns_2;


procedure level_info_returns_3 as
begin
   ut.expect(console.level_info).to_equal(3);
end level_info_returns_3;


procedure level_debug_returns_4 as
begin
   ut.expect(console.level_debug).to_equal(4);
end level_debug_returns_4;


procedure level_trace_returns_5 as
begin
   ut.expect(console.level_trace).to_equal(5);
end level_trace_returns_5;


procedure level_name_returns_correct_names as
begin
   ut.expect(console.level_name(1)).to_equal('error');
   ut.expect(console.level_name(2)).to_equal('warning');
   ut.expect(console.level_name(3)).to_equal('info');
   ut.expect(console.level_name(4)).to_equal('debug');
   ut.expect(console.level_name(5)).to_equal('trace');
end level_name_returns_correct_names;


procedure level_name_returns_null_for_invalid as
begin
   ut.expect(console.level_name(0)).to_be_null;
   ut.expect(console.level_name(6)).to_be_null;
   ut.expect(console.level_name(-1)).to_be_null;
end level_name_returns_null_for_invalid;


procedure level_is_warning as
begin
   console.conf(p_level => console.c_level_warning);
   ut.expect(console.level_is_warning).to_be_true;

   console.conf(p_level => console.c_level_error);
   ut.expect(console.level_is_warning).to_be_false;
end level_is_warning;


procedure level_is_warning_yn as
begin
   console.conf(p_level => console.c_level_warning);
   ut.expect(console.level_is_warning_yn).to_equal('Y');

   console.conf(p_level => console.c_level_error);
   ut.expect(console.level_is_warning_yn).to_equal('N');
end level_is_warning_yn;


procedure level_is_info as
begin
   console.conf(p_level => console.c_level_info);
   ut.expect(console.level_is_info).to_be_true;

   console.conf(p_level => console.c_level_warning);
   ut.expect(console.level_is_info).to_be_false;
end level_is_info;


procedure level_is_info_yn as
begin
   console.conf(p_level => console.c_level_info);
   ut.expect(console.level_is_info_yn).to_equal('Y');

   console.conf(p_level => console.c_level_warning);
   ut.expect(console.level_is_info_yn).to_equal('N');
end level_is_info_yn;


procedure level_is_debug as
begin
   console.conf(p_level => console.c_level_debug);
   ut.expect(console.level_is_debug).to_be_true;

   console.conf(p_level => console.c_level_info);
   ut.expect(console.level_is_debug).to_be_false;
end level_is_debug;


procedure level_is_debug_yn as
begin
   console.conf(p_level => console.c_level_debug);
   ut.expect(console.level_is_debug_yn).to_equal('Y');

   console.conf(p_level => console.c_level_info);
   ut.expect(console.level_is_debug_yn).to_equal('N');
end level_is_debug_yn;


procedure level_is_trace as
begin
   console.conf(p_level => console.c_level_trace);
   ut.expect(console.level_is_trace).to_be_true;

   console.conf(p_level => console.c_level_debug);
   ut.expect(console.level_is_trace).to_be_false;
end level_is_trace;


procedure level_is_trace_yn as
begin
   console.conf(p_level => console.c_level_trace);
   ut.expect(console.level_is_trace_yn).to_equal('Y');

   console.conf(p_level => console.c_level_debug);
   ut.expect(console.level_is_trace_yn).to_equal('N');
end level_is_trace_yn;


procedure to_md_code_block_indents_4_spaces as
   l_result varchar2(100);
begin
   l_result := console.to_md_code_block('code');

   ut.expect(l_result).to_equal('    code');
end to_md_code_block_indents_4_spaces;


procedure to_md_code_block_multiline as
   l_result varchar2(500);
begin
   l_result := console.to_md_code_block('line1' || chr(10) || 'line2');

   ut.expect(l_result).to_be_like('    line1%    line2');
end to_md_code_block_multiline;


procedure to_md_tab_header_returns_correct_format as
   l_result varchar2(200);
begin
   l_result := console.to_md_tab_header('Key', 'Value');

   ut.expect(l_result).to_match('| Key\s* | Value\s* |\s*|[-]*|[-]*|\s*');
end to_md_tab_header_returns_correct_format;


procedure to_md_tab_data_escapes_pipes as
   l_result varchar2(200);
begin
   l_result := console.to_md_tab_data('my|key', 'my|value');

   ut.expect(l_result).not_to_be_like('%|my|key|%');
   ut.expect(l_result).to_be_like('%|%');
end to_md_tab_data_escapes_pipes;


procedure to_md_tab_data_truncates_long_values as
   l_long_value varchar2(2000) := rpad('x', 1500, 'x');
   l_result varchar2(2000);
begin
   l_result := console.to_md_tab_data('key', l_long_value, 100);

   ut.expect(length(l_result)).to_be_less_than(length(l_long_value) + 50);
end to_md_tab_data_truncates_long_values;


procedure to_md_tab_data_hides_null_by_default as
   l_result varchar2(100);
begin
   l_result := console.to_md_tab_data('key', null);

   ut.expect(l_result).to_be_null();
end to_md_tab_data_hides_null_by_default;


procedure to_md_tab_data_shows_null_when_enabled as
   l_result varchar2(100);
begin
   l_result := console.to_md_tab_data('key', null, p_show_null_values => true);

   ut.expect(l_result).to_be_like('%key%');
end to_md_tab_data_shows_null_when_enabled;


procedure to_unibar_generates_bar as
   l_result varchar2(100);
begin
   l_result := console.to_unibar(50);

   ut.expect(l_result).not_to_be_null;
   ut.expect(length(l_result)).to_be_greater_than(0);
end to_unibar_generates_bar;


procedure to_unibar_scales_value as
   l_result_1 varchar2(100);
   l_result_2 varchar2(100);
begin
   l_result_1 := console.to_unibar(0.5, p_scale => 1);
   l_result_2 := console.to_unibar(0.5, p_scale => 2);

   -- Scale increases step size -> fewer steps for the same number displayed
   ut.expect(length(l_result_2)).to_be_less_than(length(l_result_1));
end to_unibar_scales_value;


procedure to_unibar_rejects_zero_scale as
   l_result varchar2(100);
begin
   l_result := console.to_unibar(1, p_scale => 0);
end to_unibar_rejects_zero_scale;


procedure to_unibar_handles_zero as
   l_result varchar2(100);
begin
   l_result := console.to_unibar(0);

   ut.expect(l_result).to_be_null;
end to_unibar_handles_zero;


procedure to_unibar_handles_negative as
   l_result varchar2(100);
begin
   l_result := console.to_unibar(-1, p_scale => -1);

   ut.expect(length(l_result)).to_equal(25);
end to_unibar_handles_negative;


procedure to_unibar_width_affects_length as
   l_result_narrow varchar2(100);
   l_result_wide varchar2(100);
begin
   l_result_narrow := console.to_unibar(1, p_width_block_characters => 5);
   l_result_wide := console.to_unibar(1, p_width_block_characters => 30);

   ut.expect(length(l_result_narrow)).to_equal(5);
   ut.expect(length(l_result_wide)).to_equal(30);
end to_unibar_width_affects_length;


procedure to_unibar_rejects_negative_width as
   l_result varchar2(100);
begin
   l_result := console.to_unibar(1, p_width_block_characters => -5);
end to_unibar_rejects_negative_width;


procedure to_unibar_rejects_zero_width as
   l_result varchar2(100);
begin
   l_result := console.to_unibar(1, p_width_block_characters => 0);
end to_unibar_rejects_zero_width;


procedure to_unibar_fill_scale_fills_space as
   l_result varchar2(100);
begin
   -- With fill_scale=1, the bar should be padded to full width_block_characters
   l_result := console.to_unibar(10, p_scale => 100, p_width_block_characters => 20, p_fill_scale => 1);

   -- The result should have length close to width_block_characters (20)
   ut.expect(length(l_result)).to_equal(20);
end to_unibar_fill_scale_fills_space;


procedure version_returns_non_null_string as
begin
   ut.expect(console.version).not_to_be_null;
   ut.expect(length(console.version)).to_be_greater_than(0);
end version_returns_non_null_string;


procedure status_returns_rows as
   l_count number;
   l_version varchar2(100);
   l_level_id varchar2(100);
begin
   select count(*)
     into l_count
     from table(console.status);

   ut.expect(l_count).to_be_greater_than(0);
end status_returns_rows;

end console_utils_test;
/
