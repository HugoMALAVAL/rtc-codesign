library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtc_time is
    Port (
        CLK          : in  std_logic;
        RST          : in  std_logic;
        CE_1s        : in  std_logic;
        MODE_REGLAGE : in  std_logic;
        SEL_STATE    : in  std_logic_vector(2 downto 0); 
        BTN_UP_PULSE : in  std_logic; 
        BTN_DN_PULSE : in  std_logic; 
        
        UART_SET_EN  : in  std_logic;
        UART_HR      : in  integer range 0 to 23;
        UART_MIN     : in  integer range 0 to 59;
        UART_SEC     : in  integer range 0 to 59;
        
        -- NOUVEAU : Sorties brutes pour la lecture UART (GET)
        OUT_HR       : out integer range 0 to 23;
        OUT_MIN      : out integer range 0 to 59;
        OUT_SEC      : out integer range 0 to 59;
        
        SSU, SST, MMU, MMT, HHU : out std_logic_vector(3 downto 0);
        HHT          : out std_logic_vector(1 downto 0);
        CE_DDU       : out std_logic
    );
end rtc_time;

architecture Behavioral of rtc_time is
    signal sec : integer range 0 to 59 := 0;
    signal min : integer range 0 to 59 := 0;
    signal hr  : integer range 0 to 23 := 0;
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            sec <= 0; min <= 0; hr <= 0; CE_DDU <= '0';
        elsif rising_edge(CLK) then
            CE_DDU <= '0'; 
            if UART_SET_EN = '1' then
                hr <= UART_HR; min <= UART_MIN; sec <= UART_SEC;
            elsif MODE_REGLAGE = '0' then
                if CE_1s = '1' then
                    if sec = 59 then
                        sec <= 0;
                        if min = 59 then
                            min <= 0;
                            if hr = 23 then hr <= 0; CE_DDU <= '1'; 
                            else hr <= hr + 1; end if;
                        else min <= min + 1; end if;
                    else sec <= sec + 1; end if;
                end if;
            else
                if SEL_STATE = "000" then
                    if BTN_UP_PULSE = '1' then if hr = 23 then hr <= 0; else hr <= hr + 1; end if;
                    elsif BTN_DN_PULSE = '1' then if hr = 0 then hr <= 23; else hr <= hr - 1; end if; end if;
                elsif SEL_STATE = "001" then 
                    if BTN_UP_PULSE = '1' then if min = 59 then min <= 0; else min <= min + 1; end if;
                    elsif BTN_DN_PULSE = '1' then if min = 0 then min <= 59; else min <= min - 1; end if; end if;
                elsif SEL_STATE = "010" then
                    if BTN_UP_PULSE = '1' then if sec = 59 then sec <= 0; else sec <= sec + 1; end if;
                    elsif BTN_DN_PULSE = '1' then if sec = 0 then sec <= 59; else sec <= sec - 1; end if; end if;
                end if;
            end if;
        end if;
    end process;

    SSU <= std_logic_vector(to_unsigned(sec mod 10, 4));
    SST <= std_logic_vector(to_unsigned(sec / 10, 4));
    MMU <= std_logic_vector(to_unsigned(min mod 10, 4));
    MMT <= std_logic_vector(to_unsigned(min / 10, 4));
    HHU <= std_logic_vector(to_unsigned(hr mod 10, 4));
    HHT <= std_logic_vector(to_unsigned(hr / 10, 2));

    -- Assignation des nouvelles sorties brutes
    OUT_HR <= hr; OUT_MIN <= min; OUT_SEC <= sec;
end Behavioral;