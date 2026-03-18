library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Tregister_1b is
    Port (
        clk : in STD_LOGIC;
        T   : in STD_LOGIC;
        Q   : out STD_LOGIC
    );
end Tregister_1b;

architecture Behavioral of Tregister_1b is
    signal state : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if T = '1' then
                state <= not state;
            else
                state <= state;
            end if;
        end if;
    end process;
    Q <= state;
end Behavioral;
