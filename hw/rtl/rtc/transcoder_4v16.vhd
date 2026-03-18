library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity transcoder_4v16 is
    Port (
        A : in  STD_LOGIC_VECTOR(3 downto 0);
        O : out STD_LOGIC_VECTOR(15 downto 0)
    );
end transcoder_4v16;

architecture Behavioral of transcoder_4v16 is
begin
    process(A)
    begin
        O <= (others => '1'); --Tout eteint par défaut (actif bas)

        case A is
            when "0000" => O(0)  <= '0';
            when "0001" => O(1)  <= '0';
            when "0010" => O(2)  <= '0';
            when "0011" => O(3)  <= '0';
            when "0100" => O(4)  <= '0';
            when "0101" => O(5)  <= '0';
            when "0110" => O(6)  <= '0';
            when "0111" => O(7)  <= '0';
            when others => O <= (others => '1');
        end case;
    end process;
end Behavioral;
