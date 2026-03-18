library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alarm_fsm is
    Port (
        CLK   : in STD_LOGIC;
        RST   : in STD_LOGIC;
        CE_1s : in STD_LOGIC;
        ALARM : in STD_LOGIC;
        RGB   : out STD_LOGIC_VECTOR (2 downto 0)
    );
end alarm_fsm;

architecture behavior of alarm_fsm is
    type state_type is (IDLE, RED, ROTATING, GREEN);
    signal current_state, next_state: state_type;
    signal cnt, cnt_reg: UNSIGNED(2 downto 0);
    signal RGB_int, RGB_reg: STD_LOGIC_VECTOR(2 downto 0);
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            current_state <= IDLE;
            cnt_reg       <= (others => '0');
            RGB_reg       <= "000";
        elsif rising_edge(CLK) then
            current_state <= next_state;
            cnt_reg       <= cnt;
            RGB_reg       <= RGB_int;
        end if;
    end process;

    process(ALARM, CE_1s, current_state, cnt_reg, RGB_reg)
    begin
        next_state <= current_state;
        cnt        <= cnt_reg;
        RGB_int    <= RGB_reg;

        case current_state is
            when IDLE =>
                RGB_int <= "000";
                if CE_1s = '1' then cnt <= cnt_reg + 1; end if;
                if ALARM = '1' then
                    next_state <= RED;
                else
                    next_state <= IDLE;
                end if;

            when RED =>
                RGB_int <= "100"; -- Rouge
                if CE_1s = '1' then cnt <= cnt_reg + 1; end if;
                if cnt_reg = "110" then 
                    next_state <= ROTATING;
                    cnt <= (others => '0');
                    RGB_int <= "100";
                end if;

            when ROTATING =>
                if CE_1s = '1' then
                    cnt <= cnt_reg + 1;
                    RGB_int <= RGB_reg(1 downto 0) & RGB_reg(2); -- Rotation
                end if;
                if cnt_reg = "111" then
                    next_state <= GREEN;
                    cnt <= (others => '0');
                end if;

            when GREEN =>
                RGB_int <= "010"; -- Vert
                if CE_1s = '1' then cnt <= cnt_reg + 1; end if;
                if cnt_reg = "101" then
                    next_state <= IDLE;
                    cnt <= (others => '0');
                end if;
                
            when others =>
                next_state <= IDLE;
                RGB_int <= "000";
        end case;
    end process;

    -- CORRIGÉ : La Nexys A7 a des LEDs RGB actives à l'état HAUT !
    RGB <= RGB_reg; 

end behavior;