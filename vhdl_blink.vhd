-- (c)EMARD
-- License=BSD

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vhdl_blink is
  generic
  (
    bits: integer := 23
  );
  port
  (
    clk: in std_logic;  -- main clock input from 25MHz clock source
    led: out std_logic
  );
end;

architecture Behavioral of vhdl_blink is
    signal R_blink: std_logic_vector(bits-1 downto 0);
begin
    process(clk)
    begin
      if rising_edge(clk) then
        R_blink <= R_blink+1;
      end if;
    end process;
    led <= R_blink(R_blink'high);
end Behavioral;
