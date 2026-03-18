library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top_Level_RTC is
    Port (
        CLK100MHZ : in  STD_LOGIC;
        RST_BTN   : in  STD_LOGIC;
        BTN_UP    : in  STD_LOGIC;
        BTN_DN    : in  STD_LOGIC;
        BTN_L     : in  STD_LOGIC;
        BTN_R     : in  STD_LOGIC;
        SW        : in  STD_LOGIC_VECTOR(15 downto 0);
        
        UART_RXD  : in  STD_LOGIC;
        UART_TXD  : out STD_LOGIC;
        
        SEG       : out STD_LOGIC_VECTOR(6 downto 0);
        AN        : out STD_LOGIC_VECTOR(7 downto 0);
        LED_RGB   : out STD_LOGIC_VECTOR(2 downto 0);
        LED15     : out STD_LOGIC;
        
        LED17_G   : out STD_LOGIC 
    );
end Top_Level_RTC;

architecture Structural of Top_Level_RTC is

    signal tick_1ms, tick_1s : std_logic;
    signal ce_ddu_sig        : std_logic;
    
    signal ssu_sig, sst_sig, mmu_sig, mmt_sig, hhu_sig : std_logic_vector(3 downto 0);
    signal hht_sig  : std_logic_vector(1 downto 0);
    signal ddu_sig, ddt_sig, mtu_sig, mtt_sig, yyu_sig, yyt_sig : std_logic_vector(3 downto 0);

    signal disp_ad0, disp_ad1, disp_ad2, disp_ad3 : std_logic_vector(3 downto 0);
    signal disp_bd0, disp_bd1, disp_bd2, disp_bd3 : std_logic_vector(3 downto 0);
    
    signal pulse_up, pulse_dn, pulse_l, pulse_r : std_logic;
    signal sel_state : std_logic_vector(2 downto 0);
    signal show_date : std_logic;
    signal blink_tog : std_logic := '0';
    signal b_hr, b_min, b_sec, b_day, b_mth, b_yr : std_logic;
    
    signal tick_uart     : std_logic;
    signal rx_clean      : std_logic;
    signal rx_data_sig   : std_logic_vector(7 downto 0);
    signal rx_done_sig   : std_logic;
    signal tx_data_sig   : std_logic_vector(7 downto 0);
    signal tx_start_sig  : std_logic;
    signal tx_busy_sig   : std_logic;
    
    signal uart_set_en_sig      : std_logic;
    signal uart_hr_sig          : integer range 0 to 23;
    signal uart_min_sig         : integer range 0 to 59;
    signal uart_sec_sig         : integer range 0 to 59;
    
    signal uart_set_date_en_sig : std_logic;
    signal uart_day_sig         : integer range 1 to 31;
    signal uart_month_sig       : integer range 1 to 12;
    signal uart_year_sig        : integer range 0 to 99;
    
    signal cur_hr_sig   : integer range 0 to 23;
    signal cur_min_sig  : integer range 0 to 59;
    signal cur_sec_sig  : integer range 0 to 59;
    signal cur_day_sig  : integer range 1 to 31;
    signal cur_month_sig: integer range 1 to 12;
    signal cur_year_sig : integer range 0 to 99;

    -- Signaux d'Alarme
    signal alarm_en_state    : std_logic := '0'; 
    signal uart_set_al_en    : std_logic;
    signal uart_al_hr        : integer range 0 to 23;
    signal uart_al_min       : integer range 0 to 59;
    signal uart_al_sec       : integer range 0 to 59;
    
    signal pc_al_hr          : integer range 0 to 23 := 0;
    signal pc_al_min         : integer range 0 to 59 := 0;
    signal pc_al_sec         : integer range 0 to 59 := 0;
    signal sw_al_hr          : integer range 0 to 23 := 0;
    signal sw_al_min         : integer range 0 to 59 := 0;
    signal sw_al_sec         : integer range 0 to 59 := 0;
    signal final_al_hr       : integer range 0 to 23 := 0;
    signal final_al_min      : integer range 0 to 59 := 0;
    signal final_al_sec      : integer range 0 to 59 := 0;
    
    signal al_ssu, al_sst, al_mmu, al_mmt, al_hhu : std_logic_vector(3 downto 0);
    signal al_hht : std_logic_vector(1 downto 0);
    
    -- Nouveaux Signaux Globaux
    signal alarm_ringing_sig : std_logic;
    signal pc_baud_sel_sig   : std_logic;
    signal status_byte_sig   : std_logic_vector(7 downto 0);
    
    signal rx_valid_pulse_sig: std_logic;
    signal uart_al_en_cmd    : std_logic;
    signal uart_al_en_val    : std_logic;
    signal blink_cnt         : integer range 0 to 7 := 0;
    signal ms_cnt            : integer range 0 to 200 := 0;
    signal led15_reg         : std_logic := '0';

begin

    U_CLOCK : entity work.clock_divider port map ( CLK => CLK100MHZ, RST => RST_BTN, CE_1ms => tick_1ms, CE_1s => tick_1s );

    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if tick_1s = '1' then blink_tog <= not blink_tog; end if;
        end if;
    end process;

    U_DEB_UP : entity work.debouncer_repeat port map ( clk => CLK100MHZ, rst => RST_BTN, btn_in => BTN_UP, btn_pulse => pulse_up );
    U_DEB_DN : entity work.debouncer_repeat port map ( clk => CLK100MHZ, rst => RST_BTN, btn_in => BTN_DN, btn_pulse => pulse_dn );
    U_DEB_L  : entity work.debouncer        port map ( clk => CLK100MHZ, rst => RST_BTN, btn_in => BTN_L,  btn_pulse => pulse_l );
    U_DEB_R  : entity work.debouncer        port map ( clk => CLK100MHZ, rst => RST_BTN, btn_in => BTN_R,  btn_pulse => pulse_r );

    U_FSM_SET : entity work.setting_fsm port map ( clk => CLK100MHZ, rst => RST_BTN, mode_reglage => SW(14), btn_l_pulse => pulse_l, btn_r_pulse => pulse_r, sel_state => sel_state );

    U_BAUD: entity work.baud_rate_gen 
        port map ( clk => CLK100MHZ, rst => RST_BTN, baud_sel => pc_baud_sel_sig, tick_x16 => tick_uart );
        
    U_SYNC: entity work.synchronizer port map ( clk => CLK100MHZ, rst => RST_BTN, async_in => UART_RXD, sync_out => rx_clean );
    U_RX: entity work.rx_uart port map ( clk => CLK100MHZ, rst => RST_BTN, rx => rx_clean, tick_x16 => tick_uart, dout => rx_data_sig, rx_done => rx_done_sig );
    U_TX: entity work.tx_uart port map ( clk => CLK100MHZ, rst => RST_BTN, tick_x16 => tick_uart, tx => UART_TXD, tx_busy => tx_busy_sig, tx_start => tx_start_sig, din => tx_data_sig );

    U_PROTOCOL: entity work.protocol_decoder
        port map (
            clk => CLK100MHZ, rst => RST_BTN, rx_data => rx_data_sig, rx_done => rx_done_sig,
            tx_data => tx_data_sig, tx_start => tx_start_sig, tx_busy => tx_busy_sig, 
            
            crc_ok_led => open, -- Connecté manuellement plus bas
            rx_valid_pulse => rx_valid_pulse_sig, 
            
            set_time_en => uart_set_en_sig, out_hr => uart_hr_sig, out_min => uart_min_sig, out_sec => uart_sec_sig,
            set_date_en => uart_set_date_en_sig, out_day => uart_day_sig, out_month => uart_month_sig, out_year => uart_year_sig,
            
            set_al_en => uart_set_al_en, out_al_hr => uart_al_hr, out_al_min => uart_al_min, out_al_sec => uart_al_sec,
            out_al_en_cmd => uart_al_en_cmd, 
            out_al_en_val => uart_al_en_val,
            
            in_hr => cur_hr_sig, in_min => cur_min_sig, in_sec => cur_sec_sig,
            in_day => cur_day_sig, in_month => cur_month_sig, in_year => cur_year_sig,
            in_al_hr => final_al_hr, in_al_min => final_al_min, in_al_sec => final_al_sec,
            
            in_status_byte => status_byte_sig,
            out_baud_sel   => pc_baud_sel_sig
        );

    U_RTC : entity work.rtc_time
        port map (
            CLK => CLK100MHZ, RST => RST_BTN, CE_1s => tick_1s, MODE_REGLAGE => SW(14), SEL_STATE => sel_state,
            BTN_UP_PULSE => pulse_up, BTN_DN_PULSE => pulse_dn,
            UART_SET_EN => uart_set_en_sig, UART_HR => uart_hr_sig, UART_MIN => uart_min_sig, UART_SEC => uart_sec_sig,
            OUT_HR => cur_hr_sig, OUT_MIN => cur_min_sig, OUT_SEC => cur_sec_sig,
            SSU => ssu_sig, SST => sst_sig, MMU => mmu_sig, MMT => mmt_sig, HHU => hhu_sig, HHT => hht_sig, CE_DDU => ce_ddu_sig
        );

    U_DATE : entity work.rtc_date
        port map (
            CLK => CLK100MHZ, RST => RST_BTN, CE_DDU => ce_ddu_sig, MODE_REGLAGE => SW(14), SEL_STATE => sel_state,
            BTN_UP_PULSE => pulse_up, BTN_DN_PULSE => pulse_dn,
            UART_SET_EN => uart_set_date_en_sig, UART_DAY => uart_day_sig, UART_MONTH => uart_month_sig, UART_YEAR => uart_year_sig,
            OUT_DAY => cur_day_sig, OUT_MONTH => cur_month_sig, OUT_YEAR => cur_year_sig,
            DDU => ddu_sig, DDT => ddt_sig, MTU => mtu_sig, MTT => mtt_sig, YYU => yyu_sig, YYT => yyt_sig
        );

    -- =====================================================================
    -- 1. CLIGNOTANT LED 15 (RÉCEPTION VALIDÉE)
    -- =====================================================================
    process(CLK100MHZ, RST_BTN)
    begin
        if RST_BTN = '1' then
            blink_cnt <= 0;
            ms_cnt <= 0;
            led15_reg <= '0';
        elsif rising_edge(CLK100MHZ) then
            if rx_valid_pulse_sig = '1' then
                blink_cnt <= 5;   -- 6 états : ON-OFF-ON-OFF-ON-OFF
                ms_cnt <= 0;
                led15_reg <= '1'; -- On allume de suite
            elsif blink_cnt > 0 then
                if tick_1ms = '1' then
                    if ms_cnt = 166 then 
                        ms_cnt <= 0;
                        blink_cnt <= blink_cnt - 1;
                        led15_reg <= not led15_reg;
                    else
                        ms_cnt <= ms_cnt + 1;
                    end if;
                end if;
            elsif blink_cnt = 0 then
                led15_reg <= '0';
            end if;
        end if;
    end process;
    LED15 <= led15_reg;

    -- =====================================================================
    -- 2. GESTION DE L'ALARME (PC + BOUTON) ET STATUT
    -- =====================================================================
    status_byte_sig <= "0000" & alarm_ringing_sig & SW(14) & SW(15) & alarm_en_state;

    process(CLK100MHZ, RST_BTN)
    begin
        if RST_BTN = '1' then
            alarm_en_state <= '0';
        elsif rising_edge(CLK100MHZ) then
            if SW(14) = '0' and pulse_dn = '1' then
                alarm_en_state <= not alarm_en_state; -- Toggle physique
            elsif uart_al_en_cmd = '1' then
                alarm_en_state <= uart_al_en_val;     -- Ordre UART (0x0B)
            end if;
        end if;
    end process;
    LED17_G <= alarm_en_state;

    process(CLK100MHZ, RST_BTN)
    begin
        if RST_BTN = '1' then
            pc_al_hr <= 0; pc_al_min <= 0; pc_al_sec <= 0;
        elsif rising_edge(CLK100MHZ) then
            if uart_set_al_en = '1' then
                pc_al_hr <= uart_al_hr; pc_al_min <= uart_al_min; pc_al_sec <= uart_al_sec;
            end if;
        end if;
    end process;

    process(SW)
        variable t_min, t_sec : integer;
    begin
        t_min := to_integer(unsigned(SW(13 downto 11))) * 10 + to_integer(unsigned(SW(10 downto 7)));
        t_sec := to_integer(unsigned(SW(6 downto 4))) * 10 + to_integer(unsigned(SW(3 downto 0)));
        if t_min > 59 then sw_al_min <= 59; else sw_al_min <= t_min; end if;
        if t_sec > 59 then sw_al_sec <= 59; else sw_al_sec <= t_sec; end if;
    end process;
    sw_al_hr <= 0; 

    final_al_hr  <= sw_al_hr  when SW(15) = '1' else pc_al_hr;
    final_al_min <= sw_al_min when SW(15) = '1' else pc_al_min;
    final_al_sec <= sw_al_sec when SW(15) = '1' else pc_al_sec;

    al_ssu <= std_logic_vector(to_unsigned(final_al_sec mod 10, 4));
    al_sst <= std_logic_vector(to_unsigned(final_al_sec / 10, 4));
    al_mmu <= std_logic_vector(to_unsigned(final_al_min mod 10, 4));
    al_mmt <= std_logic_vector(to_unsigned(final_al_min / 10, 4));
    al_hhu <= std_logic_vector(to_unsigned(final_al_hr mod 10, 4));
    al_hht <= std_logic_vector(to_unsigned(final_al_hr / 10, 2)) when alarm_en_state = '1' else "11";

    U_ALARM : entity work.rtc_alarm
        port map (
            CLK => CLK100MHZ, RST => RST_BTN, CE_1s => tick_1s,
            SSU => ssu_sig, SST => sst_sig, MMU => mmu_sig, MMT => mmt_sig, HHU => hhu_sig, HHT => hht_sig,
            HHT_ALARM => al_hht, HHU_ALARM => al_hhu, MMT_ALARM => al_mmt, MMU_ALARM => al_mmu, SST_ALARM => al_sst, SSU_ALARM => al_ssu,
            RGB => LED_RGB,
            ALARM_OUT => alarm_ringing_sig
        );

    -- =====================================================================
    -- 3. LE MULTIPLEXEUR INTELLIGENT ET AFFICHEUR
    -- =====================================================================
    show_date <= '1' when (SW(14) = '0' and BTN_UP = '1') or (SW(14) = '1' and sel_state >= "011") else '0';

    b_hr  <= '1' when SW(14)='1' and sel_state="000" and blink_tog='1' else '0';
    b_min <= '1' when SW(14)='1' and sel_state="001" and blink_tog='1' else '0';
    b_sec <= '1' when SW(14)='1' and sel_state="010" and blink_tog='1' else '0';
    b_day <= '1' when SW(14)='1' and sel_state="011" and blink_tog='1' else '0';
    b_mth <= '1' when SW(14)='1' and sel_state="100" and blink_tog='1' else '0';
    b_yr  <= '1' when SW(14)='1' and sel_state="101" and blink_tog='1' else '0';

    disp_bd3 <= "1111" when (show_date='1' and b_day='1') or (show_date='0' and b_hr='1') else ddt_sig when show_date='1' else ("00" & hht_sig); 
    disp_bd2 <= "1111" when (show_date='1' and b_day='1') or (show_date='0' and b_hr='1') else ddu_sig when show_date='1' else hhu_sig;         
    disp_bd1 <= "1111"; 
    disp_bd0 <= "1111"  when (show_date='1' and b_mth='1') else mtt_sig when show_date='1' else "1111"; 
    
    disp_ad3 <= "1111"  when (show_date='1' and b_mth='1') or (show_date='0' and b_min='1') else mtu_sig when show_date='1' else mmt_sig;          
    disp_ad2 <= "1111"  when (show_date='0' and b_min='1') else "1111"  when show_date='1' else mmu_sig;          
    disp_ad1 <= "1111"  when (show_date='1' and b_yr='1') or (show_date='0' and b_sec='1') else yyt_sig when show_date='1' else sst_sig;          
    disp_ad0 <= "1111"  when (show_date='1' and b_yr='1') or (show_date='0' and b_sec='1') else yyu_sig when show_date='1' else ssu_sig;          
    
    U_DISPLAY : entity work.display
        port map ( CLK => CLK100MHZ, CE_1ms => tick_1ms, CE_1s => tick_1s, AD0 => disp_ad0, AD1 => disp_ad1, AD2 => disp_ad2, AD3 => disp_ad3, BD0 => disp_bd0, BD1 => disp_bd1, BD2 => disp_bd2, BD3 => disp_bd3, AN => AN, SEG => SEG, DP => open );

end Structural;