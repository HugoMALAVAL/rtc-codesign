library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Une entité de testbench est toujours vide
entity baud_rate_gen_tb is
end baud_rate_gen_tb;

architecture Behavioral of baud_rate_gen_tb is

    -- Déclaration du composant à tester (UUT - Unit Under Test)
    component baud_rate_gen
        Port (
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            baud_sel : in  STD_LOGIC;
            tick_x16 : out STD_LOGIC
        );
    end component;

    -- Signaux internes pour simuler les entrées/sorties
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal baud_sel : std_logic := '0';
    signal tick_x16 : std_logic;

    -- Définition de la période de l'horloge (100 MHz = 10 ns)
    constant clk_period : time := 10 ns;

begin

    -- Instanciation de notre module
    uut: baud_rate_gen port map (
        clk      => clk,
        rst      => rst,
        baud_sel => baud_sel,
        tick_x16 => tick_x16
    );

    -- Processus de génération de l'horloge infinie (100 MHz)
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Processus de test (Le scénario)
    stimulus_process: process
    begin
        -- 1. Initialisation et Reset
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;

        -- 2. Test à 115200 bauds (baud_sel = '1')
        -- On s'attend à avoir un tick_x16 tous les ~54 cycles d'horloge (540 ns)
        baud_sel <= '1';
        wait for 3000 ns; -- On laisse tourner pour voir plusieurs impulsions

        -- 3. Test à 9600 bauds (baud_sel = '0')
        -- On s'attend à avoir un tick_x16 tous les ~651 cycles d'horloge (6510 ns)
        baud_sel <= '0';
        wait for 20000 ns; -- On laisse tourner plus longtemps car c'est plus lent

        -- Fin de la simulation
        wait;
    end process;

end Behavioral;