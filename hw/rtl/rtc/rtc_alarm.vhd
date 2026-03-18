library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rtc_alarm is
    Port ( RST   : in STD_LOGIC;
           CLK   : in STD_LOGIC;
           CE_1s : in STD_LOGIC;
           
           SSU, SST, MMU, MMT, HHU : in STD_LOGIC_VECTOR (3 downto 0);
           HHT : in STD_LOGIC_VECTOR (1 downto 0); 
           
           SSU_ALARM, SST_ALARM, MMU_ALARM, MMT_ALARM, HHU_ALARM : in STD_LOGIC_VECTOR (3 downto 0);
           HHT_ALARM : in STD_LOGIC_VECTOR (1 downto 0); 
           
           RGB : out STD_LOGIC_VECTOR (2 downto 0);
           
           -- NOUVEAU : Sortie pour prévenir le Top Level que ça sonne !
           ALARM_OUT : out STD_LOGIC
           );
end rtc_alarm;

architecture behavioral of rtc_alarm is
    signal ALARM_sig : STD_LOGIC;
begin   
    ALARM_sig <= '1' when (SSU = SSU_ALARM) and (SST = SST_ALARM) and
                          (MMU = MMU_ALARM) and (MMT = MMT_ALARM) and
                          (HHU = HHU_ALARM) and (HHT = HHT_ALARM)
                     else '0';
                     
    ALARM_OUT <= ALARM_sig; -- On copie le signal vers la sortie

    AFSM : entity work.alarm_fsm PORT MAP (
        CLK => CLK, RST => RST, CE_1s => CE_1s,
        ALARM => ALARM_sig, RGB => RGB
    );              
end behavioral;