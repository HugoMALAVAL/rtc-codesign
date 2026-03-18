library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tx_uart_tb is
end tx_uart_tb;

architecture Behavioral of tx_uart_tb is

    -- Déclaration du composant à tester (UUT)
    component tx_uart
        Port (
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            tx_start : in  STD_LOGIC;
            din      : in  STD_LOGIC_VECTOR (7 downto 0);
            tick_x16 : in  STD_LOGIC;
            tx       : out STD_LOGIC;
            tx_busy  : out STD_LOGIC
        );
    end component;

    -- Signaux internes
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal tx_start : std_logic := '0';
    signal din      : std_logic_vector(7 downto 0) := (others => '0');
    signal tick_x16 : std_logic := '0';
    signal tx       : std_logic;
    signal tx_busy  : std_logic;

    -- Période de l'horloge système (100 MHz)
    constant clk_period : time := 10 ns;
    
    -- Compteur interne pour générer le tick_x16 (simule 115200 bauds)
    signal tick_counter : integer := 0;

begin

    -- Instanciation de l'émetteur
    uut: tx_uart port map (
        clk      => clk,
        rst      => rst,
        tx_start => tx_start,
        din      => din,
        tick_x16 => tick_x16,
        tx       => tx,
        tx_busy  => tx_busy
    );

    -- 1. Génération de l'horloge 100 MHz
    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- 2. Génération du tick_x16 (Limite 53 pour 115200 bauds)
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
    begin
        -- Initialisation
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Test 1 : Demander l'envoi de la lettre 'B' (x"42" / Binaire : 01000010)
        din <= x"42";
        wait for 50 ns;
        
        -- On donne l'impulsion de départ !
        tx_start <= '1';
        wait for clk_period; -- Juste 1 cycle d'horloge
        tx_start <= '0';
        
        -- On attend que l'émetteur ait fini son travail
        -- On utilise wait until pour que la simulation patiente intelligemment
        wait until tx_busy = '0';
        wait for 10 us; -- Petite pause entre les envois

        -- Test 2 : Demander l'envoi de la lettre 'K' (x"4B" / Binaire : 01001011)
        din <= x"4B";
        wait for 50 ns;
        
        tx_start <= '1';
        wait for clk_period;
        tx_start <= '0';
        
        wait until tx_busy = '0';
        wait for 10 us;

        -- Fin de la simulation
        wait;
    end process;

end Behavioral;