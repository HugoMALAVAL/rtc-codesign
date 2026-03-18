library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity setting_fsm is
    Port (
        clk          : in  STD_LOGIC;
        rst          : in  STD_LOGIC;
        mode_reglage : in  STD_LOGIC; -- SW(14)
        btn_l_pulse  : in  STD_LOGIC; -- Navigation Gauche (Precedent)
        btn_r_pulse  : in  STD_LOGIC; -- Navigation Droite (Suivant)
        
        -- Sortie du curseur : 0=HR, 1=MIN, 2=SEC, 3=DAY, 4=MTH, 5=YR
        sel_state    : out STD_LOGIC_VECTOR(2 downto 0) 
    );
end setting_fsm;

architecture Behavioral of setting_fsm is
    signal current_sel : integer range 0 to 5 := 0;
begin

    process(clk, rst)
    begin
        if rst = '1' then
            current_sel <= 0;
            
        elsif rising_edge(clk) then
            if mode_reglage = '0' then
                -- Si on sort du mode reglage, le curseur revient aux Heures par defaut
                current_sel <= 0; 
            else
                -- Navigation vers la Droite (Suivant)
                if btn_r_pulse = '1' then
                    if current_sel = 5 then
                        current_sel <= 0; -- Boucle de l'annee vers les heures
                    else
                        current_sel <= current_sel + 1;
                    end if;
                    
                -- Navigation vers la Gauche (Precedent)
                elsif btn_l_pulse = '1' then
                    if current_sel = 0 then
                        current_sel <= 5; -- Boucle des heures vers l'annee
                    else
                        current_sel <= current_sel - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Conversion de l'entier en vecteur de bits pour le Top_Level
    sel_state <= std_logic_vector(to_unsigned(current_sel, 3));

end Behavioral;