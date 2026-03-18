library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tx_uart is
    Port (
        clk      : in  STD_LOGIC; -- Horloge système 100 MHz
        rst      : in  STD_LOGIC; -- Reset asynchrone
        tx_start : in  STD_LOGIC; -- Impulsion pour démarrer l'envoi
        din      : in  STD_LOGIC_VECTOR (7 downto 0); -- L'octet à envoyer
        tick_x16 : in  STD_LOGIC; -- Le métronome (générateur de baud rate)
        tx       : out STD_LOGIC; -- La ligne physique de transmission
        tx_busy  : out STD_LOGIC  -- Drapeau à '1' pendant que l'envoi est en cours
    );
end tx_uart;

architecture Behavioral of tx_uart is

    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state : state_type := IDLE;

    signal tick_cnt : integer range 0 to 15 := 0;
    signal bit_cnt  : integer range 0 to 7 := 0;
    signal tx_reg   : std_logic_vector(7 downto 0) := (others => '0');

begin

    process(clk, rst)
    begin
        if rst = '1' then
            state    <= IDLE;
            tick_cnt <= 0;
            bit_cnt  <= 0;
            tx_reg   <= (others => '0');
            tx       <= '1'; -- Ligne UART au repos = état HAUT
            tx_busy  <= '0';
            
        elsif rising_edge(clk) then
            case state is
            
                -- =========================================================
                -- ETAT 1 : ATTENTE (IDLE)
                -- =========================================================
                when IDLE =>
                    tx <= '1';
                    tx_busy <= '0';
                    tick_cnt <= 0;
                    bit_cnt <= 0;
                    
                    -- Si le système principal demande un envoi
                    if tx_start = '1' then
                        tx_reg  <= din;      -- On sauvegarde la donnée à envoyer
                        tx_busy <= '1';      -- On prévient qu'on est occupé
                        state   <= START_BIT;
                    end if;

                -- =========================================================
                -- ETAT 2 : ENVOI DU BIT DE START
                -- =========================================================
                when START_BIT =>
                    tx <= '0'; -- Le bit de Start est toujours à '0'
                    
                    if tick_x16 = '1' then
                        if tick_cnt = 15 then -- On a attendu la durée totale d'un bit (16 ticks)
                            tick_cnt <= 0;
                            state <= DATA_BITS;
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;
                    end if;

                -- =========================================================
                -- ETAT 3 : ENVOI DES 8 BITS DE DONNÉES (LSB First)
                -- =========================================================
                when DATA_BITS =>
                    tx <= tx_reg(bit_cnt); -- On envoie le bit actuel sur la ligne
                    
                    if tick_x16 = '1' then
                        if tick_cnt = 15 then
                            tick_cnt <= 0;
                            if bit_cnt = 7 then -- Si on vient d'envoyer le dernier bit
                                state <= STOP_BIT;
                            else
                                bit_cnt <= bit_cnt + 1; -- Bit suivant
                            end if;
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;
                    end if;

                -- =========================================================
                -- ETAT 4 : ENVOI DU BIT DE STOP
                -- =========================================================
                when STOP_BIT =>
                    tx <= '1'; -- Le bit de Stop est toujours à '1'
                    
                    if tick_x16 = '1' then
                        if tick_cnt = 15 then
                            state <= IDLE; -- Fin de l'envoi, on retourne attendre
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;