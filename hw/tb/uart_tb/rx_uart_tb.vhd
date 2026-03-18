library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rx_uart_tb is
end rx_uart_tb;

architecture Behavioral of rx_uart_tb is

    -- Déclaration du composant à tester (UUT)
    component rx_uart
        Port (
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            rx       : in  STD_LOGIC;
            tick_x16 : in  STD_LOGIC;
            dout     : out STD_LOGIC_VECTOR (7 downto 0);
            rx_done  : out STD_LOGIC
        );
    end component;

    -- Signaux internes
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal rx       : std_logic := '1'; -- Ligne UART au repos ('1')
    signal tick_x16 : std_logic := '0';
    signal dout     : std_logic_vector(7 downto 0);
    signal rx_done  : std_logic;

    -- Constantes de temps
    constant clk_period : time := 10 ns; -- 100 MHz
    
    -- Pour 115200 bauds, un bit dure environ 8.68 microsecondes (8680 ns)
    constant bit_period : time := 8680 ns; 
    
    -- Compteur interne pour simuler le baud_rate_gen (limite 53 pour 115200 bauds)
    signal tick_counter : integer := 0;

begin

    -- Instanciation du récepteur
    uut: rx_uart port map (
        clk      => clk,
        rst      => rst,
        rx       => rx,
        tick_x16 => tick_x16,
        dout     => dout,
        rx_done  => rx_done
    );

    -- 1. Génération de l'horloge 100 MHz
    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- 2. Génération du tick_x16 (Simule le baud_rate_gen à 115200 bauds)
    tick_process : process(clk)
    begin
        if rising_edge(clk) then
            if tick_counter = 53 then
                tick_counter <= 0;
                tick_x16 <= '1';
            else
                tick_counter <= tick_counter + 1;
                tick_x16 <= '0';
            end if;
        end if;
    end process;

    -- 3. Le Scénario de Test
    stimulus_process: process
    
        -- ====================================================================
        -- PROCEDURE MAGIQUE : Simule l'envoi d'un octet par le PC
        -- ====================================================================
        procedure send_byte(data : std_logic_vector(7 downto 0)) is
        begin
            -- Envoi du bit de Start ('0')
            rx <= '0';
            wait for bit_period;
            
            -- Envoi des 8 bits de données (Le LSB en premier, bit 0 -> bit 7)
            for i in 0 to 7 loop
                rx <= data(i);
                wait for bit_period;
            end loop;
            
            -- Envoi du bit de Stop ('1')
            rx <= '1';
            wait for bit_period;
        end procedure;
        -- ====================================================================

    begin
        -- Initialisation
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Test 1 : On envoie la lettre 'A' (Code ASCII Hexa : x"41" / Binaire : 01000001)
        send_byte(x"41");
        
        -- On attend un peu entre les deux messages
        wait for 20 us;

        -- Test 2 : On envoie la lettre 'Z' (Code ASCII Hexa : x"5A" / Binaire : 01011010)
        send_byte(x"5A");

        -- Fin de la simulation
        wait;
    end process;

end Behavioral;