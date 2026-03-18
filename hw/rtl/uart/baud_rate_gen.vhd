library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity baud_rate_gen is
    Port (
        clk      : in  STD_LOGIC; -- Horloge système (100 MHz)
        rst      : in  STD_LOGIC; -- Reset asynchrone
        baud_sel : in  STD_LOGIC; -- Sélecteur: '1' = 115200 bauds, '0' = 9600 bauds
        tick_x16 : out STD_LOGIC  -- L'impulsion générée 16 fois plus vite que le baud rate
    );
end baud_rate_gen;

architecture Behavioral of baud_rate_gen is
    -- Le compteur doit pouvoir aller jusqu'à 650 (donc on prévoit un entier jusqu'à 1023)
    signal counter : integer range 0 to 1023 := 0;
    
    -- Signal pour stocker la limite dynamique
    signal limit   : integer range 0 to 1023;
begin

    -- ==============================================================================
    -- AIGUILLAGE DE LA LIMITE (Totalement synchrone avec le reste, pas de boucle)
    -- Calcul = (100 MHz / (Baud Rate * 16)) - 1
    -- ==============================================================================
    limit <= 53 when baud_sel = '1' else 650;

    -- ==============================================================================
    -- COMPTEUR SYNCHRONE
    -- ==============================================================================
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= 0;
            tick_x16 <= '0';
        elsif rising_edge(clk) then
            -- Dès que le compteur atteint la limite, on le remet à 0 et on génère un tick
            if counter >= limit then
                counter <= 0;
                tick_x16 <= '1'; -- Le tick dure exactement 1 seul cycle d'horloge 100MHz
            else
                counter <= counter + 1;
                tick_x16 <= '0'; -- Le reste du temps, le signal est plat (sans glitch)
            end if;
        end if;
    end process;

end Behavioral;