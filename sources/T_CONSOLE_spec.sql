create or replace type t_console as object (
  dummy_attribute number                                                                                                        ,   
  constructor function t_console return self as result                                                                          ,
  member function add_param(self in t_console, p_name in varchar2, p_value in varchar2) return t_console                        ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in varchar2)                                        ,
  member function add_param(self in t_console, p_name in varchar2, p_value in number) return t_console                          ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in number)                                          ,
  member function add_param(self in t_console, p_name in varchar2, p_value in date) return t_console                            ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in date)                                            ,
  member function add_param(self in t_console, p_name in varchar2, p_value in timestamp) return t_console                       ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in timestamp)                                       ,
  member function add_param(self in t_console, p_name in varchar2, p_value in timestamp with time zone) return t_console        ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in timestamp with time zone)                        ,
  member function add_param(self in t_console, p_name in varchar2, p_value in timestamp with local time zone) return t_console  ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in timestamp with local time zone)                  ,
  member function add_param(self in t_console, p_name in varchar2, p_value in interval year to month) return t_console          ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in interval year to month)                          ,
  member function add_param(self in t_console, p_name in varchar2, p_value in interval day to second) return t_console          ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in interval day to second)                          ,
  member function add_param(self in t_console, p_name in varchar2, p_value in boolean) return t_console                         ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in boolean)                                         ,
  member function add_param(self in t_console, p_name in varchar2, p_value in clob) return t_console                            ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in clob)                                            ,
  member function add_param(self in t_console, p_name in varchar2, p_value in xmltype) return t_console                         ,
  member procedure add_param(self in t_console, p_name in varchar2, p_value in xmltype)
  
);
/