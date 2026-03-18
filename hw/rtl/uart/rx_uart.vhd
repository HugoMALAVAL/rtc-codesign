library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rx_uart is
    Port (
        clk      : in  STD_LOGIC; -- Horloge système (100 MHz)
        rst      : in  STD_LOGIC; -- Reset asynchrone
        rx       : in  STD_LOGIC; -- Ligne de réception (Déjà synchronisée par notre bouclier !)
        tick_x16 : in  STD_LOGIC; -- Impulsion x16 générée par baud_rate_gen
        dout     : out STD_LOGIC_VECTOR (7 downto 0); -- L'octet reconstitué
        rx_done  : out STD_LOGIC  -- Drapeau (1 cycle) indiquant qu'un octet est prêt
    );
end rx_uart;

architecture Behavioral of rx_uart is

    -- Les 4 états exigés par le cahier des charges
    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state : state_type := IDLE;

    -- Compteurs internes
    signal tick_cnt : integer range 0 to 15 := 0; -- Compte les ticks (0 à 15 pour faire 16)
    signal bit_cnt  : integer range 0 to 7 := 0;  -- Compte les 8 bits de données
    
    -- Registre interne pour stocker l'octet en cours de réception
    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');

begin

    process(clk, rst)
    begin
        if rst = '1' then
            state    <= IDLE;
            tick_cnt <= 0;
            bit_cnt  <= 0;
            shift_reg<= (others => '0');
            dout     <= (others => '0');
            rx_done  <= '0';
            
        elsif rising_edge(clk) then
            -- rx_done doit être une impulsion d'un seul cycle d'horloge. 
            -- On le force à 0 par défaut, il ne passera à 1 qu'à la toute fin.
            rx_done <= '0'; 

            case state is
            
                -- =========================================================
                -- ETAT 1 : ATTENTE (IDLE)
                -- =========================================================
                when IDLE =>
                    tick_cnt <= 0;
                    bit_cnt  <= 0;
                    -- Si on détecte un front descendant sur RX (début d'un message)
                    if rx = '0' then
                        state <= START_BIT;
                    end if;

                -- =========================================================
                -- ETAT 2 : VERIFICATION DU BIT DE START (La règle d'or)
                -- =========================================================
                when START_BIT =>
                    -- On n'avance que si le générateur de baud rate donne le top
                    if tick_x16 = '1' then
                        if tick_cnt = 7 then -- On est pile au milieu du bit de Start
                            if rx = '0' then 
                                -- C'est un vrai bit de Start ! On lance la lecture.
                                tick_cnt <= 0;
                                state <= DATA_BITS;
                            else
                                -- Fausse alerte (glitch/parasite), on retourne en veille
                                state <= IDLE;
                            end if;
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;
                    end if;

                -- =========================================================
                -- ETAT 3 : LECTURE DES 8 BITS DE DONNÉES (Format 8N1)
                -- =========================================================
                when DATA_BITS =>
                    if tick_x16 = '1' then
                        if tick_cnt = 15 then -- On a attendu 16 ticks (milieu du bit suivant)
                            tick_cnt <= 0;
                            
                            -- Le protocole UART envoie le bit de poids faible (LSB) en premier
                            shift_reg(bit_cnt) <= rx; 
                            
                            if bit_cnt = 7 then -- Si on a lu le 8ème bit
                                bit_cnt <= 0;
                                state <= STOP_BIT;
                            else
                                bit_cnt <= bit_cnt + 1;
                            end if;
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;
                    end if;

                -- =========================================================
                -- ETAT 4 : LE BIT DE STOP
                -- =========================================================
                when STOP_BIT =>
                    if tick_x16 = '1' then
                        if tick_cnt = 15 then -- On attend d'être au milieu du bit de Stop
                            -- La réception est un succès total !
                            dout <= shift_reg; -- On sort l'octet
                            rx_done <= '1';    -- On lève le drapeau pour avertir le Top Level
                            state <= IDLE;     -- On retourne attendre le prochain message
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;