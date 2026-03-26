create or replace package console_utils_test as

--%suite(Console utility functions)
--%rollback(manual)

--%beforeall(console_test_helpers.enable_all_logging)

--%beforeeach(console_test_helpers.truncate_console_logs)

--%context(String Functions - split and split_to_table)

--%test(Split with comma separator)
procedure split_with_comma_separator;

--%test(Split with custom separator)
procedure split_with_custom_separator;

--%test(Split empty string)
procedure split_empty_string;

--%test(Split single value)
procedure split_single_value;

--%test(Split null separator splits into characters)
procedure split_null_separator_splits_chars;

--%test(Split to table with comma separator)
procedure split_to_table_with_comma;

--%test(Split to table empty string returns no rows)
procedure split_to_table_empty_string;

--%endcontext

--%context(String Functions - join)

--%test(Join with comma separator)
procedure join_with_comma_separator;

--%test(Join with custom separator)
procedure join_with_custom_separator;

--%test(Join empty array returns null)
procedure join_empty_array_returns_null;

--%test(Join single element)
procedure join_single_element;

--%test(Join with null separator)
procedure join_with_null_separator;

--%test(Join with content equals separator)
procedure join_with_content_equals_separator;

--%endcontext

--%context(String Functions - format)

--%test(Format with single placeholder)
procedure format_with_single_placeholder;

--%test(Format with multiple placeholders)
procedure format_with_multiple_placeholders;

--%test(Format with no placeholders)
procedure format_with_no_placeholders;

--%test(Format with null values)
procedure format_with_null_values;

--%test(Format with all 10 parameters)
procedure format_with_all_10_parameters;

--%endcontext

--%context(Boolean Conversion Functions)

--%test(To yn converts true to Y)
procedure to_yn_true_returns_y;

--%test(To yn converts false to N)
procedure to_yn_false_returns_n;

--%test(To yn converts null to N)
procedure to_yn_null_returns_n;

--%test(To string converts true to true)
procedure to_string_true_returns_true;

--%test(To string converts false to false)
procedure to_string_false_returns_false;

--%test(To string converts null to false)
procedure to_string_null_returns_false;

--%test(To bool accepts uppercase TRUE)
procedure to_bool_accepts_uppercase_true;

--%test(To bool accepts lowercase true)
procedure to_bool_accepts_lowercase_true;

--%test(To bool accepts Y N YES NO)
procedure to_bool_accepts_y_n_yes_no;

--%test(To bool accepts 1 and 0)
procedure to_bool_accepts_1_and_0;

--%test(To bool returns null for invalid input)
procedure to_bool_returns_null_for_invalid;

--%test(To bool handles whitespace)
procedure to_bool_handles_whitespace;

--%endcontext

--%context(Assert Functions)

--%test(Assert true does not raise an error)
procedure assert_true_does_nothing;

--%test(Assert false raises assertion error)
--%throws(console.e_assert_error)
procedure assert_false_raises_error;

--%test(Assert false includes message)
procedure assert_false_includes_message;

--%test(Assert null raises assertion error)
--%throws(console.e_assert_error)
procedure assert_null_raises_error;

--%test(Assertf true does not raise an error)
procedure assertf_true_does_nothing;

--%test(Assertf false includes formatted message)
procedure assertf_false_raises_with_formatted_message;

--%endcontext

--%context(Level Functions)

--%test(Level error returns 1)
procedure level_error_returns_1;

--%test(Level warning returns 2)
procedure level_warning_returns_2;

--%test(Level info returns 3)
procedure level_info_returns_3;

--%test(Level debug returns 4)
procedure level_debug_returns_4;

--%test(Level trace returns 5)
procedure level_trace_returns_5;

--%test(Level name returns correct names)
procedure level_name_returns_correct_names;

--%test(Level name returns null for invalid level)
procedure level_name_returns_null_for_invalid;

--%endcontext

--%context(Level Comparison Functions)

--%test(Level is warning checks against 2)
procedure level_is_warning;

--%test(Level is warning yn returns Y or N)
procedure level_is_warning_yn;

--%test(Level is info checks against 3)
procedure level_is_info;

--%test(Level is info yn returns Y or N)
procedure level_is_info_yn;

--%test(Level is debug checks against 4)
procedure level_is_debug;

--%test(Level is debug yn returns Y or N)
procedure level_is_debug_yn;

--%test(Level is trace checks against 5)
procedure level_is_trace;

--%test(Level is trace yn returns Y or N)
procedure level_is_trace_yn;

--%endcontext

--%context(Markdown Formatting Functions)

--%test(To md code block indents with 4 spaces)
procedure to_md_code_block_indents_4_spaces;

--%test(To md code block multiline)
procedure to_md_code_block_multiline;

--%test(To md tab header returns correct format)
procedure to_md_tab_header_returns_correct_format;

--%test(To md tab data escapes pipes)
procedure to_md_tab_data_escapes_pipes;

--%test(To md tab data truncates long values)
procedure to_md_tab_data_truncates_long_values;

--%test(To md tab data hides null values by default)
procedure to_md_tab_data_hides_null_by_default;

--%test(To md tab data shows null values when enabled)
procedure to_md_tab_data_shows_null_when_enabled;

--%endcontext

--%context(Output Functions)

--%test(Print outputs to dbms_output)
procedure print_outputs_to_dbms_output;

--%test(Printf formats and outputs to dbms_output)
procedure printf_formats_and_outputs;

--%endcontext

--%context(Session Info Functions)

--%test(Action sets session action)
procedure action_sets_session_action;

--%test(Module sets session module and action)
procedure module_sets_session_module;

--%test(Action truncates values that are too long)
procedure action_truncates_too_long_value;

--%test(Module truncates module and action when too long)
procedure module_truncates_too_long_values;

--%test(Action and module keep exact max lengths)
procedure action_and_module_keep_exact_max_lengths;

--%test(My client identifier returns current id)
procedure my_client_identifier_returns_current_id;

--%test(My log level returns current level)
procedure my_log_level_returns_current_level;

--%endcontext

--%context(HTML Table Functions)

--%test(To html table returns table tags)
procedure to_html_table_returns_table_tags;

--%test(To html table includes column headers)
procedure to_html_table_includes_column_headers;

--%test(To html table includes comment)
procedure to_html_table_includes_comment;

--%test(To html table includes row numbers)
procedure to_html_table_includes_row_numbers;

--%test(To html table excludes row numbers)
procedure to_html_table_excludes_row_numbers;

--%test(To html table escapes HTML special characters)
procedure to_html_table_escapes_html_special_chars;

--%test(To html table shows values from multiple cursor rows)
procedure to_html_table_shows_multiple_rows_values;

--%test(To html table supports number and varchar2 columns)
procedure to_html_table_supports_number_and_varchar2_columns;

--%test(To html table supports date and timestamp columns)
procedure to_html_table_supports_date_and_timestamp_columns;

--%test(To html table supports clob and xmltype columns)
procedure to_html_table_supports_clob_and_xmltype_columns;

--%test(To html table handles binary columns)
procedure to_html_table_handles_binary_columns;

--%test(To html table has one header per cursor column)
procedure to_html_table_has_expected_header_count;

--%test(To html table has one row per cursor row)
procedure to_html_table_has_expected_row_count;

--%test(Table hash logs HTML table output)
procedure table_hash_logs_result;

--%endcontext

--%context(Environment Functions)

--%test(Scope returns caller info)
procedure scope_returns_caller_info;

--%test(User env returns markdown section)
procedure user_env_returns_markdown;

--%test(Console env returns version information)
procedure console_env_returns_version;

--%test(Console env includes running timers)
procedure console_env_includes_running_timers;

--%test(Call stack returns formatted output)
procedure call_stack_returns_formatted_output;

--%test(CGI env returns heading)
procedure cgi_env_returns_heading;

--%endcontext

--%context(CLOB Utility Functions)

--%test(Clob append accumulates text)
procedure clob_append_accumulates_text;

--%test(Clob flush cache clears cache)
procedure clob_flush_cache_clears_cache;

--%test(Clob append handles cache overflow)
procedure clob_append_handles_overflow;

--%test(Clob append ignores null values)
procedure clob_append_ignores_null_values;

--%endcontext

--%context(Unicode Bar Function)

--%test(To unibar generates bar with default width)
procedure to_unibar_generates_bar;

--%test(To unibar scales value correctly)
procedure to_unibar_scales_value;

--%test(To unibar scale cannot be 0)
--%throws(console.e_assert_error)
procedure to_unibar_rejects_zero_scale;

--%test(To unibar handles zero value)
procedure to_unibar_handles_zero;

--%test(To unibar handles negative value)
procedure to_unibar_handles_negative;

--%test(To unibar width block characters affects bar length)
procedure to_unibar_width_affects_length;

--%test(To unibar rejects negative width block characters)
--%throws(console.e_assert_error)
procedure to_unibar_rejects_negative_width;

--%test(To unibar rejects zero width block characters)
--%throws(console.e_assert_error)
procedure to_unibar_rejects_zero_width;

--%test(To unibar fill scale fills remaining space)
procedure to_unibar_fill_scale_fills_space;

--%endcontext

--%context(Version and Status Functions)

--%test(Version returns non null string)
procedure version_returns_non_null_string;

--%test(Status returns rows)
procedure status_returns_rows;

--%endcontext

end console_utils_test;
/
