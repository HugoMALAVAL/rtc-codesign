library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_4b_E is
    Port (
        clk : in STD_LOGIC;
        CE  : in STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end counter_4b_E;

architecture Behavioral of counter_4b_E is
    signal counter : unsigned(3 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if CE = '1' then
                if counter = to_unsigned(7, 4) then
                    counter <= (others => '0');
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;
    
    Q <= std_logic_vector(counter);
end Behavioral;
