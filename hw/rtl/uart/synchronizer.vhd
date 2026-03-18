library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity synchronizer is
    Port (
        clk      : in  STD_LOGIC; -- Horloge système (100 MHz)
        rst      : in  STD_LOGIC; -- Reset asynchrone
        async_in : in  STD_LOGIC; -- Le signal RX brut venant du PC
        sync_out : out STD_LOGIC  -- Le signal RX propre et synchronisé
    );
end synchronizer;

architecture Behavioral of synchronizer is
    -- Déclaration des deux bascules D (registres) en série
    -- On les initialise à '1' car l'état de repos (IDLE) d'une ligne UART est '1'
    signal q1 : STD_LOGIC := '1';
    signal q2 : STD_LOGIC := '1';
begin

    process(clk, rst)
    begin
        if rst = '1' then
            q1 <= '1';
            q2 <= '1';
        elsif rising_edge(clk) then
            -- Première bascule : Elle "attrape" le signal asynchrone.
            -- Elle risque d'entrer en métastabilité.
            q1 <= async_in;
            
            -- Deuxième bascule : Elle lit la sortie de la première.
            -- Elle a eu un cycle d'horloge complet (10ns) pour se stabiliser.
            -- Le signal en sortie est pur et synchrone.
            q2 <= q1;
        end if;
    end process;

    -- Assignation de la sortie
    sync_out <= q2;

end Behavioral;