library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ruby_rtl_package is

  function to_bit(v:integer;n:natural) return std_logic;
  function to_uint(v : std_logic; n:natural) return unsigned;
  function to_int(v : std_logic; n:natural) return signed;

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

end package body;
