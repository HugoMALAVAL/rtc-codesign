library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_transceiver_tb is
end uart_transceiver_tb;

architecture Behavioral of uart_transceiver_tb is

    -- Déclaration du composant principal (Notre "Boîte" qui contient tout l'UART)
    component uart_transceiver
        Port (
            CLK100MHZ : in  STD_LOGIC;
            RST_BTN   : in  STD_LOGIC;
            BAUD_SEL  : in  STD_LOGIC;
            UART_RXD  : in  STD_LOGIC;
            UART_TXD  : out STD_LOGIC
        );
    end component;

    -- Signaux internes
    signal CLK100MHZ : std_logic := '0';
    signal RST_BTN   : std_logic := '0';
    signal BAUD_SEL  : std_logic := '0';
    signal UART_RXD  : std_logic := '1'; -- Repos à '1'
    signal UART_TXD  : std_logic;

    -- Période de l'horloge 100 MHz
    constant clk_period : time := 10 ns;
    
    -- Durée d'un bit à 115200 bauds
    constant bit_period : time := 8680 ns;

begin

    -- Instanciation du Transceiver complet
    uut: uart_transceiver port map (
        CLK100MHZ => CLK100MHZ,
        RST_BTN   => RST_BTN,
        BAUD_SEL  => BAUD_SEL,
        UART_RXD  => UART_RXD,
        UART_TXD  => UART_TXD
    );

    -- 1. Génération de l'horloge 100 MHz
    clk_process : process
    begin
        CLK100MHZ <= '0'; wait for clk_period/2;
        CLK100MHZ <= '1'; wait for clk_period/2;
    end process;

    -- 2. Le Scénario de Test (Le PC qui parle au FPGA)
    stimulus_process: process
    
        -- Procédure pour simuler l'envoi d'un octet par le PC (sur la broche RX)
        procedure send_to_fpga(data : std_logic_vector(7 downto 0)) is
        begin
            UART_RXD <= '0'; -- Start bit
            wait for bit_period;
            
            for i in 0 to 7 loop
                UART_RXD <= data(i); -- Data bits (LSB first)
                wait for bit_period;
            end loop;
            
            UART_RXD <= '1'; -- Stop bit
            wait for bit_period;
        end procedure;

    begin
        -- Initialisation
        RST_BTN <= '1';
        BAUD_SEL <= '1'; -- On sélectionne la vitesse rapide (115200 bauds)
        wait for 100 ns;
        RST_BTN <= '0';
        wait for 100 ns;

        -- Test 1 : Le PC envoie la lettre 'E' (x"45" / 01000101)
        send_to_fpga(x"45");
        
        -- On attend suffisamment longtemps pour que le FPGA ait le temps de répondre
        wait for 200 us; 

        -- Test 2 : Le PC envoie la lettre 'X' (x"58" / 01011000)
        send_to_fpga(x"58");

        -- Fin de la simulation
        wait;
    end process;

end Behavioral;