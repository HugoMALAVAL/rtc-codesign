library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rtc_date is
    Port ( 
        CLK, RST, CE_DDU, MODE_REGLAGE : in STD_LOGIC;
        SEL_STATE    : in std_logic_vector(2 downto 0); 
        BTN_UP_PULSE, BTN_DN_PULSE : in std_logic; 
        
        UART_SET_EN  : in std_logic;
        UART_DAY     : in integer range 1 to 31;
        UART_MONTH   : in integer range 1 to 12;
        UART_YEAR    : in integer range 0 to 99;
        
        -- NOUVEAU : Sorties brutes pour la lecture UART
        OUT_DAY      : out integer range 1 to 31;
        OUT_MONTH    : out integer range 1 to 12;
        OUT_YEAR     : out integer range 0 to 99;
        
        DDU, DDT, MTU, MTT, YYU, YYT : out STD_LOGIC_VECTOR (3 downto 0)
    );
end rtc_date;

architecture behavioral of rtc_date is
    signal day : integer range 1 to 31 := 24; 
    signal month : integer range 1 to 12 := 2;
    signal year : integer range 0 to 99 := 26;
    signal max_day : integer range 28 to 31;
begin
    process(month, year)
    begin
        case month is
            when 4 | 6 | 9 | 11 => max_day <= 30;
            when 2 => if (year mod 4 = 0) then max_day <= 29; else max_day <= 28; end if;
            when others => max_day <= 31;
        end case;
    end process;

    process(CLK, RST)
    begin
        if RST = '1' then day <= 24; month <= 2; year <= 26;
        elsif rising_edge(CLK) then
            if UART_SET_EN = '1' then
                day <= UART_DAY; month <= UART_MONTH; year <= UART_YEAR;
            elsif MODE_REGLAGE = '0' then
                if CE_DDU = '1' then
                    if day = max_day then
                        day <= 1;
                        if month = 12 then month <= 1;
                            if year = 99 then year <= 0; else year <= year + 1; end if;
                        else month <= month + 1; end if;
                    else day <= day + 1; end if;
                end if;
            else
                if SEL_STATE = "011" then 
                    if BTN_UP_PULSE = '1' then if day >= max_day then day <= 1; else day <= day + 1; end if;
                    elsif BTN_DN_PULSE = '1' then if day = 1 then day <= max_day; else day <= day - 1; end if; end if;
                elsif SEL_STATE = "100" then 
                    if BTN_UP_PULSE = '1' then if month = 12 then month <= 1; else month <= month + 1; end if;
                    elsif BTN_DN_PULSE = '1' then if month = 1 then month <= 12; else month <= month - 1; end if; end if;
                elsif SEL_STATE = "101" then 
                    if BTN_UP_PULSE = '1' then if year = 99 then year <= 0; else year <= year + 1; end if;
                    elsif BTN_DN_PULSE = '1' then if year = 0 then year <= 99; else year <= year - 1; end if; end if;
                end if;
            end if;
            if day > max_day then day <= max_day; end if;
        end if;
    end process;

    DDU <= std_logic_vector(to_unsigned(day mod 10, 4)); DDT <= std_logic_vector(to_unsigned(day / 10, 4));
    MTU <= std_logic_vector(to_unsigned(month mod 10, 4)); MTT <= std_logic_vector(to_unsigned(month / 10, 4));
    YYU <= std_logic_vector(to_unsigned(year mod 10, 4)); YYT <= std_logic_vector(to_unsigned(year / 10, 4));

    -- Assignation des nouvelles sorties brutes
    OUT_DAY <= day; OUT_MONTH <= month; OUT_YEAR <= year;
end behavioral;