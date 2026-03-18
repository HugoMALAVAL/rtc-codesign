library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
    Port (
        CLK    : in  std_logic;
        RST    : in  std_logic;
        CE_1ms : out std_logic;
        CE_1s  : out std_logic
    );
end clock_divider;

architecture Behavioral of clock_divider is
    -- Constantes pour horloge 100 MHz
    constant MAX_1MS : integer := 100000;
    constant MAX_1S  : integer := 100000000;
    
    signal counter_ms : integer range 0 to MAX_1MS := 0;
    signal counter_s  : integer range 0 to MAX_1S := 0;
begin
    process(CLK, RST)
    begin
      if RST = '1' then
          counter_ms <= 0;
          counter_s  <= 0;
          CE_1ms     <= '0';
          CE_1s      <= '0';
      elsif rising_edge(CLK) then
          -- Gestion de la milliseconde
          if counter_ms = MAX_1MS - 1 then
              counter_ms <= 0;
              CE_1ms <= '1';
          else
              counter_ms <= counter_ms + 1;
              CE_1ms <= '0';
          end if;
          
          -- Gestion de la seconde
          if counter_s = MAX_1S - 1 then
              counter_s <= 0;
              CE_1s <= '1';
          else
              counter_s <= counter_s + 1;
              CE_1s <= '0';
          end if;
      end if;
    end process;
end Behavioral;