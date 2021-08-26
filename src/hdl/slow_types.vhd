library ieee;
use ieee.std_logic_1164.all;

package slow_types is

subtype std3_t is std_logic_vector(2 downto 0);
type std3_array is array(natural range <>) of std3_t;

subtype std4_t is std_logic_vector(3 downto 0);
type std4_array is array(natural range <>) of std4_t;

subtype std8_t is std_logic_vector(7 downto 0);
type std8_array is array(natural range <>) of std8_t;

subtype std32_t is std_logic_vector(31 downto 0);
type std32_array is array(natural range <>) of std32_t;

constant DCARD_MONITOR      : std_logic_vector(2 downto 0) := "011";

end slow_types;

package body slow_types is

end slow_types;

