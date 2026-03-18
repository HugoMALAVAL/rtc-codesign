library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer_repeat is
    Generic (
        CLK_FREQ    : integer := 100000000; -- Frequence de la Nexys A7 (100 MHz)
        DEBOUNCE_MS : integer := 10;        -- 10 ms pour filtrer les rebonds metalliques
        WAIT_MS     : integer := 500;       -- 500 ms (0.5s) avant de declencher l'auto-repetition
        REPEAT_MS   : integer := 200        -- 200 ms (5 Hz) de vitesse de defilement continu
    );
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        btn_in    : in  STD_LOGIC;  -- Le bouton physique de la carte
        btn_pulse : out STD_LOGIC   -- L'impulsion propre qui ira au RTC
    );
end debouncer_repeat;

architecture Behavioral of debouncer_repeat is
    -- Calcul automatique des limites de compteurs selon la frequence
    constant COUNT_DEBOUNCE : integer := (CLK_FREQ / 1000) * DEBOUNCE_MS;
    constant COUNT_WAIT     : integer := (CLK_FREQ / 1000) * WAIT_MS;
    constant COUNT_REPEAT   : integer := (CLK_FREQ / 1000) * REPEAT_MS;

    -- Signaux pour la synchronisation et le filtrage pur
    signal sync_1, sync_2 : STD_LOGIC := '0';
    signal btn_stable     : STD_LOGIC := '0';
    signal debounce_cnt   : integer range 0 to COUNT_DEBOUNCE := 0;

    -- Machine a etats pour gerer le clic vs le maintien
    type state_type is (IDLE, FIRST_PULSE, WAITING, REPEATING);
    signal state : state_type := IDLE;
    signal timer : integer range 0 to COUNT_WAIT := 0;

begin
    process(clk, rst)
    begin
        if rst = '1' then
            sync_1 <= '0';
            sync_2 <= '0';
            btn_stable <= '0';
            debounce_cnt <= 0;
            state <= IDLE;
            timer <= 0;
            btn_pulse <= '0';
            
        elsif rising_edge(clk) then
            -- ==========================================
            -- 1. SYNCHRONISATION ET ANTI-REBOND
            -- ==========================================
            sync_1 <= btn_in;
            sync_2 <= sync_1;

            if sync_2 = '1' then
                if debounce_cnt < COUNT_DEBOUNCE then
                    debounce_cnt <= debounce_cnt + 1;
                else
                    btn_stable <= '1'; -- Le bouton est vraiment appuye
                end if;
            else
                debounce_cnt <= 0;
                btn_stable <= '0';     -- Le bouton est vraiment relache
            end if;

            -- ==========================================
            -- 2. LOGIQUE D'AUTO-REPETITION (FSM)
            -- ==========================================
            btn_pulse <= '0'; -- Par defaut, on n'envoie aucune impulsion
            
            case state is
                when IDLE =>
                    timer <= 0;
                    if btn_stable = '1' then
                        state <= FIRST_PULSE;
                    end if;

                when FIRST_PULSE =>
                    btn_pulse <= '1'; -- On envoie 1 impulsion de 10ns (+1)
                    state <= WAITING;

                when WAITING =>
                    if btn_stable = '0' then
                        state <= IDLE; -- L'utilisateur a juste fait un clic court
                    else
                        -- L'utilisateur maintient, on attend 0.5 seconde...
                        if timer < COUNT_WAIT then
                            timer <= timer + 1;
                        else
                            timer <= 0;
                            state <= REPEATING;
                            btn_pulse <= '1'; -- Envoi de la premiere impulsion auto
                        end if;
                    end if;

                when REPEATING =>
                    if btn_stable = '0' then
                        state <= IDLE; -- L'utilisateur relache le bouton
                    else
                        -- Mode Turbo : On tourne en boucle toutes les 200 ms
                        if timer < COUNT_REPEAT then
                            timer <= timer + 1;
                        else
                            timer <= 0;
                            btn_pulse <= '1'; -- Envoi de l'impulsion auto (+1)
                        end if;
                    end if;
            end case;
            
        end if;
    end process;
end Behavioral;