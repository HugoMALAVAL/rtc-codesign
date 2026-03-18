library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    Generic (
        -- 10 ms a 100 MHz = 1 000 000 cycles
        DEBOUNCE_TIME : integer := 1000000 
    );
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        btn_in    : in  STD_LOGIC;  -- Le bouton physique brut
        btn_pulse : out STD_LOGIC   -- L'impulsion propre d'1 seul cycle
    );
end debouncer;

architecture Behavioral of debouncer is
    signal count : integer range 0 to DEBOUNCE_TIME := 0;
    
    -- Registres pour la synchronisation (anti-metastabilite)
    signal btn_sync_1, btn_sync_2 : STD_LOGIC := '0';
    
    -- Registres pour l'etat stable et la detection de front
    signal btn_stable      : STD_LOGIC := '0';
    signal btn_stable_prev : STD_LOGIC := '0';
begin
    process(clk, rst)
    begin
        if rst = '1' then
            count <= 0;
            btn_sync_1 <= '0';
            btn_sync_2 <= '0';
            btn_stable <= '0';
            btn_stable_prev <= '0';
            btn_pulse <= '0';
        elsif rising_edge(clk) then
            -- 1. Synchronisation (Bouclier CDC comme pour l'UART)
            btn_sync_1 <= btn_in;
            btn_sync_2 <= btn_sync_1;

            -- 2. Filtre Anti-Rebond (Temporisation)
            if btn_sync_2 /= btn_stable then
                if count = DEBOUNCE_TIME - 1 then
                    btn_stable <= btn_sync_2;
                    count <= 0;
                else
                    count <= count + 1;
                end if;
            else
                count <= 0;
            end if;

            -- 3. Detecteur de front montant (Edge Detector)
            btn_stable_prev <= btn_stable;
            if btn_stable = '1' and btn_stable_prev = '0' then
                btn_pulse <= '1'; -- Genere un Tick strict !
            else
                btn_pulse <= '0';
            end if;
        end if;
    end process;
end Behavioral;