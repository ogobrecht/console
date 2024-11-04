create or replace type body t_console as
  constructor function t_console 
  return self as result is
  begin
    self.dummy_attribute := 1;
    return;
  end;


  member function add_param(
    self in t_console  , 
    p_name in varchar2 , 
    p_value in varchar2) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console  , 
    p_name in varchar2 , 
    p_value in varchar2) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;


  member function add_param(
    self in t_console  , 
    p_name in varchar2 , 
    p_value in number  ) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console  , 
    p_name in varchar2 , 
    p_value in number  ) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in date   ) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in date   ) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console   , 
    p_name in varchar2  , 
    p_value in timestamp) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console   , 
    p_name in varchar2  , 
    p_value in timestamp) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console                  , 
    p_name in varchar2                 , 
    p_value in timestamp with time zone) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console                  ,
    p_name in varchar2                 , 
    p_value in timestamp with time zone) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console                        , 
    p_name in varchar2                       , 
    p_value in timestamp with local time zone) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console                        , 
    p_name in varchar2                       , 
    p_value in timestamp with local time zone) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console                , 
    p_name in varchar2               , 
    p_value in interval year to month) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console                , 
    p_name in varchar2               , 
    p_value in interval year to month) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console                , 
    p_name in varchar2               , 
    p_value in interval day to second) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console                , 
    p_name in varchar2               , 
    p_value in interval day to second) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in boolean) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in boolean) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in clob   ) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in clob   ) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  

  member function add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in xmltype) 
  return t_console is
  begin
    console.add_param(p_name, p_value);

    return t_console();
  end add_param;


  member procedure add_param(
    self in t_console , 
    p_name in varchar2, 
    p_value in xmltype) 
  is
  begin
    console.add_param(p_name, p_value);
  end add_param;
  
end;
/