library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ruby_rtl_package is

  function to_bit( v:integer  ; n:natural) return std_logic;

  function to_uint(v:std_logic; n:natural) return unsigned;

  function to_int( v:std_logic; n:natural) return signed;
  function to_int( v:integer  ; n:natural) return signed;
  function to_int(v : signed; n:natural) return signed;

  function to_bv(v: unsigned;n : natural) return std_logic_vector;
  function to_bv(v: integer ;n : natural) return std_logic_vector;

end package;

package body ruby_rtl_package is

  function to_bit(v:integer;n:natural) return std_logic is
  begin
    if v=0 then
      return '0';
    else
      return '1';
    end if;
  end function;

  function to_uint(v : std_logic; n:natural) return unsigned is
    variable ret : unsigned(n-1 downto 0) := (others=>'0');
  begin
    ret(0):=v;
    return ret;
  end function;

  function to_int(v : std_logic; n:natural) return signed is
    variable ret : signed(n-1 downto 0) := (others=>'0');
  begin
    ret(0):=v;
    return ret;
  end function;

  function to_int(v : integer; n:natural) return signed is
    variable ret : signed(n-1 downto 0) := (others=>'0');
  begin
    ret:=to_signed(v,n);
    return ret;
  end function;

  function to_int(v : signed; n:natural) return signed is
    variable ret : signed(n-1 downto 0) := (others=>'0');
  begin
    ret:=resize(v,n);
    return ret;
  end function;

  function to_bv(v: unsigned;n : natural) return std_logic_vector is
    variable resize_v : unsigned(n-1 downto 0);
    variable tmp : std_logic_vector(n-1 downto 0);
  begin
    resize_v:=resize(v,n);
    tmp := std_logic_vector(resize_v);
    return tmp;
  end function;

  function to_bv(v: integer ;n : natural) return std_logic_vector is
    variable s1 : signed(n-1 downto 0);
    variable tmp : std_logic_vector(n-1 downto 0);
  begin
    s1:=to_signed(v,n);
    tmp:=std_logic_vector(s1);
    return tmp;
  end function;

end package body;
