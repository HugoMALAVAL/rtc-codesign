library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity protocol_decoder is
    Port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        rx_data    : in  STD_LOGIC_VECTOR(7 downto 0);
        rx_done    : in  STD_LOGIC;
        tx_data    : out STD_LOGIC_VECTOR(7 downto 0);
        tx_start   : out STD_LOGIC;
        tx_busy    : in  STD_LOGIC;
        
        -- Sorties pour les LEDs
        crc_ok_led     : out STD_LOGIC;
        rx_valid_pulse : out STD_LOGIC; -- Impulsion d'1 cycle pour le clignotant
        
        -- ECRITURE (SET)
        set_time_en   : out STD_LOGIC;
        out_hr        : out integer range 0 to 23; 
        out_min       : out integer range 0 to 59; 
        out_sec       : out integer range 0 to 59;
        
        set_date_en   : out STD_LOGIC;
        out_day       : out integer range 1 to 31; 
        out_month     : out integer range 1 to 12; 
        out_year      : out integer range 0 to 99;
        
        set_al_en     : out STD_LOGIC;
        out_al_hr     : out integer range 0 to 23; 
        out_al_min    : out integer range 0 to 59; 
        out_al_sec    : out integer range 0 to 59;
        
        out_al_en_cmd : out STD_LOGIC; -- Ordre du PC pour ON/OFF Alarme
        out_al_en_val : out STD_LOGIC; -- Valeur (1 = ON, 0 = OFF)
        
        -- LECTURE (GET)
        in_hr         : in integer range 0 to 23; 
        in_min        : in integer range 0 to 59; 
        in_sec        : in integer range 0 to 59;
        
        in_day        : in integer range 1 to 31; 
        in_month      : in integer range 1 to 12; 
        in_year       : in integer range 0 to 99;
        
        in_al_hr      : in integer range 0 to 23; 
        in_al_min     : in integer range 0 to 59; 
        in_al_sec     : in integer range 0 to 59;
        
        -- STATUS ET BAUD RATE
        in_status_byte: in STD_LOGIC_VECTOR(7 downto 0);
        out_baud_sel  : out STD_LOGIC
    );
end protocol_decoder;

architecture Behavioral of protocol_decoder is
    type state_type is (IDLE, READ_CMD, READ_LEN, READ_PAYLOAD, READ_CRC, VERIFY_CRC, PROCESS_CMD, SEND_RESP, WAIT_TX_PULSE, WAIT_TX_DONE);
    signal state : state_type := IDLE;
    
    signal cmd_reg     : std_logic_vector(7 downto 0) := (others => '0');
    signal len_reg     : integer range 0 to 255 := 0;
    signal payload_cnt : integer range 0 to 255 := 0;
    signal calc_crc    : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_crc      : std_logic_vector(7 downto 0) := (others => '0');
    
    type payload_array is array (0 to 15) of std_logic_vector(7 downto 0);
    signal payload_buf : payload_array := (others => (others => '0'));
    
    signal tx_buf : payload_array := (others => (others => '0'));
    signal tx_len : integer range 0 to 15 := 0;
    signal tx_cnt : integer range 0 to 15 := 0;

    signal reg_baud_sel       : std_logic := '1';
    signal prev_alarm_ringing : std_logic := '0';

    -- Commandes du cahier des charges
    constant SOF_BYTE        : std_logic_vector(7 downto 0) := x"55";
    constant CMD_GET_ALL     : std_logic_vector(7 downto 0) := x"01";
    constant CMD_SET_ALL_C   : std_logic_vector(7 downto 0) := x"02"; 
    constant CMD_GET_ALARM   : std_logic_vector(7 downto 0) := x"03";
    constant CMD_SET_ALARM   : std_logic_vector(7 downto 0) := x"04";
    constant CMD_GET_BAUD    : std_logic_vector(7 downto 0) := x"05";
    constant CMD_SET_BAUD    : std_logic_vector(7 downto 0) := x"06";
    constant CMD_STATUS      : std_logic_vector(7 downto 0) := x"07";
    constant CMD_ALARM_EVENT : std_logic_vector(7 downto 0) := x"0A"; 
    constant CMD_SET_AL_EN   : std_logic_vector(7 downto 0) := x"0B"; 
    
    -- Commandes Bonus
    constant CMD_GET_TIME    : std_logic_vector(7 downto 0) := x"11"; 
    constant CMD_SET_TIME    : std_logic_vector(7 downto 0) := x"12"; 
    constant CMD_GET_DATE    : std_logic_vector(7 downto 0) := x"13"; 
    constant CMD_SET_DATE    : std_logic_vector(7 downto 0) := x"14"; 
    constant ACK_BYTE        : std_logic_vector(7 downto 0) := x"08";
    constant NACK_BYTE       : std_logic_vector(7 downto 0) := x"09";

begin
    out_baud_sel <= reg_baud_sel;

    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE; tx_start <= '0'; crc_ok_led <= '0'; rx_valid_pulse <= '0';
            set_time_en <= '0'; set_date_en <= '0'; set_al_en <= '0'; out_al_en_cmd <= '0';
            out_hr <= 0; out_min <= 0; out_sec <= 0;
            out_day <= 1; out_month <= 1; out_year <= 0;
            out_al_hr <= 0; out_al_min <= 0; out_al_sec <= 0;
            reg_baud_sel <= '1'; calc_crc <= (others => '0'); 
            payload_cnt <= 0; tx_cnt <= 0; tx_len <= 0;
            prev_alarm_ringing <= '0';
            
        elsif rising_edge(clk) then
            -- Remise à zéro des impulsions par défaut
            tx_start <= '0'; set_time_en <= '0'; set_date_en <= '0'; 
            set_al_en <= '0'; rx_valid_pulse <= '0'; out_al_en_cmd <= '0';
            
            -- Mise à jour du détecteur de front de l'alarme
            prev_alarm_ringing <= in_status_byte(3); 

            case state is
                when IDLE =>
                    -- 1. Le PC nous parle
                    if rx_done = '1' and rx_data = SOF_BYTE then 
                        state <= READ_CMD; 
                        
                    -- 2. Le FPGA prévient le PC que l'alarme vient de sonner (Front montant)
                    elsif in_status_byte(3) = '1' and prev_alarm_ringing = '0' then
                        tx_buf(0) <= SOF_BYTE; 
                        tx_buf(1) <= CMD_ALARM_EVENT; 
                        tx_buf(2) <= x"00"; 
                        tx_buf(3) <= CMD_ALARM_EVENT xor x"00";
                        tx_len <= 4;
                        tx_cnt <= 0;
                        state <= SEND_RESP;
                    end if;

                when READ_CMD =>
                    if rx_done = '1' then cmd_reg <= rx_data; calc_crc <= rx_data; state <= READ_LEN; end if;

                when READ_LEN =>
                    if rx_done = '1' then
                        if unsigned(rx_data) > 15 then state <= IDLE; 
                        else
                            len_reg <= to_integer(unsigned(rx_data)); calc_crc <= calc_crc xor rx_data; payload_cnt <= 0;
                            if unsigned(rx_data) > 0 then state <= READ_PAYLOAD; else state <= READ_CRC; end if;
                        end if;
                    end if;

                when READ_PAYLOAD =>
                    if rx_done = '1' then
                        payload_buf(payload_cnt) <= rx_data; calc_crc <= calc_crc xor rx_data;
                        if payload_cnt = len_reg - 1 then state <= READ_CRC; else payload_cnt <= payload_cnt + 1; end if;
                    end if;

                when READ_CRC =>
                    if rx_done = '1' then rx_crc <= rx_data; state <= VERIFY_CRC; end if;

                when VERIFY_CRC =>
                    if calc_crc = rx_crc then 
                        crc_ok_led <= '1'; 
                        rx_valid_pulse <= '1'; -- On lance le clignotant
                        state <= PROCESS_CMD;
                    else 
                        crc_ok_led <= '0'; 
                        tx_buf(0) <= NACK_BYTE; tx_len <= 1; tx_cnt <= 0; state <= SEND_RESP; 
                    end if;

                when PROCESS_CMD =>
                    tx_buf(0) <= ACK_BYTE; tx_len <= 1;

                    -- === SETTERS ===
                    if cmd_reg = CMD_SET_ALL_C and len_reg = 6 then
                        if unsigned(payload_buf(0)) < 60 and unsigned(payload_buf(1)) < 60 and unsigned(payload_buf(2)) < 24 and 
                           unsigned(payload_buf(3)) >= 1 and unsigned(payload_buf(3)) <= 31 and unsigned(payload_buf(4)) >= 1 and unsigned(payload_buf(4)) <= 12 and unsigned(payload_buf(5)) <= 99 then
                            out_sec <= to_integer(unsigned(payload_buf(0))); out_min <= to_integer(unsigned(payload_buf(1))); out_hr <= to_integer(unsigned(payload_buf(2)));
                            out_day <= to_integer(unsigned(payload_buf(3))); out_month <= to_integer(unsigned(payload_buf(4))); out_year <= to_integer(unsigned(payload_buf(5)));
                            set_time_en <= '1'; set_date_en <= '1';
                        end if;
                        
                    elsif cmd_reg = CMD_SET_TIME and len_reg = 3 then
                        if unsigned(payload_buf(0)) < 60 and unsigned(payload_buf(1)) < 60 and unsigned(payload_buf(2)) < 24 then
                            out_sec <= to_integer(unsigned(payload_buf(0))); out_min <= to_integer(unsigned(payload_buf(1))); out_hr <= to_integer(unsigned(payload_buf(2)));
                            set_time_en <= '1'; 
                        end if;
                        
                    elsif cmd_reg = CMD_SET_DATE and len_reg = 3 then
                        if unsigned(payload_buf(0)) >= 1 and unsigned(payload_buf(0)) <= 31 and unsigned(payload_buf(1)) >= 1 and unsigned(payload_buf(1)) <= 12 and unsigned(payload_buf(2)) <= 99 then
                            out_day <= to_integer(unsigned(payload_buf(0))); out_month <= to_integer(unsigned(payload_buf(1))); out_year <= to_integer(unsigned(payload_buf(2)));
                            set_date_en <= '1'; 
                        end if;

                    elsif cmd_reg = CMD_SET_ALARM and len_reg = 3 then
                        if unsigned(payload_buf(0)) < 60 and unsigned(payload_buf(1)) < 60 and unsigned(payload_buf(2)) < 24 then
                            out_al_sec <= to_integer(unsigned(payload_buf(0))); out_al_min <= to_integer(unsigned(payload_buf(1))); out_al_hr <= to_integer(unsigned(payload_buf(2)));
                            set_al_en <= '1'; 
                        end if;

                    elsif cmd_reg = CMD_SET_BAUD and len_reg = 1 then
                        reg_baud_sel <= payload_buf(0)(0); 

                    elsif cmd_reg = CMD_SET_AL_EN and len_reg = 1 then
                        out_al_en_val <= payload_buf(0)(0);
                        out_al_en_cmd <= '1';

                    -- === GETTERS ===
                    elsif cmd_reg = CMD_GET_ALL and len_reg = 0 then
                        tx_buf(0) <= SOF_BYTE; tx_buf(1) <= CMD_GET_ALL; tx_buf(2) <= x"06";
                        tx_buf(3) <= std_logic_vector(to_unsigned(in_sec, 8)); tx_buf(4) <= std_logic_vector(to_unsigned(in_min, 8)); tx_buf(5) <= std_logic_vector(to_unsigned(in_hr, 8));
                        tx_buf(6) <= std_logic_vector(to_unsigned(in_day, 8)); tx_buf(7) <= std_logic_vector(to_unsigned(in_month, 8)); tx_buf(8) <= std_logic_vector(to_unsigned(in_year, 8));
                        tx_buf(9) <= CMD_GET_ALL xor x"06" xor std_logic_vector(to_unsigned(in_sec, 8)) xor std_logic_vector(to_unsigned(in_min, 8)) xor std_logic_vector(to_unsigned(in_hr, 8)) xor 
                                     std_logic_vector(to_unsigned(in_day, 8)) xor std_logic_vector(to_unsigned(in_month, 8)) xor std_logic_vector(to_unsigned(in_year, 8));
                        tx_len <= 10;
                        
                    elsif cmd_reg = CMD_GET_TIME and len_reg = 0 then
                        tx_buf(0) <= SOF_BYTE; tx_buf(1) <= CMD_GET_TIME; tx_buf(2) <= x"03";
                        tx_buf(3) <= std_logic_vector(to_unsigned(in_sec, 8)); tx_buf(4) <= std_logic_vector(to_unsigned(in_min, 8)); tx_buf(5) <= std_logic_vector(to_unsigned(in_hr, 8));
                        tx_buf(6) <= CMD_GET_TIME xor x"03" xor std_logic_vector(to_unsigned(in_sec, 8)) xor std_logic_vector(to_unsigned(in_min, 8)) xor std_logic_vector(to_unsigned(in_hr, 8));
                        tx_len <= 7;
                        
                    elsif cmd_reg = CMD_GET_DATE and len_reg = 0 then
                        tx_buf(0) <= SOF_BYTE; tx_buf(1) <= CMD_GET_DATE; tx_buf(2) <= x"03";
                        tx_buf(3) <= std_logic_vector(to_unsigned(in_day, 8)); tx_buf(4) <= std_logic_vector(to_unsigned(in_month, 8)); tx_buf(5) <= std_logic_vector(to_unsigned(in_year, 8));
                        tx_buf(6) <= CMD_GET_DATE xor x"03" xor std_logic_vector(to_unsigned(in_day, 8)) xor std_logic_vector(to_unsigned(in_month, 8)) xor std_logic_vector(to_unsigned(in_year, 8));
                        tx_len <= 7;

                    elsif cmd_reg = CMD_GET_ALARM and len_reg = 0 then
                        tx_buf(0) <= SOF_BYTE; tx_buf(1) <= CMD_GET_ALARM; tx_buf(2) <= x"03";
                        tx_buf(3) <= std_logic_vector(to_unsigned(in_al_sec, 8)); tx_buf(4) <= std_logic_vector(to_unsigned(in_al_min, 8)); tx_buf(5) <= std_logic_vector(to_unsigned(in_al_hr, 8));
                        tx_buf(6) <= CMD_GET_ALARM xor x"03" xor std_logic_vector(to_unsigned(in_al_sec, 8)) xor std_logic_vector(to_unsigned(in_al_min, 8)) xor std_logic_vector(to_unsigned(in_al_hr, 8));
                        tx_len <= 7;

                    elsif cmd_reg = CMD_GET_BAUD and len_reg = 0 then
                        tx_buf(0) <= SOF_BYTE; tx_buf(1) <= CMD_GET_BAUD; tx_buf(2) <= x"01";
                        tx_buf(3) <= "0000000" & reg_baud_sel;
                        tx_buf(4) <= CMD_GET_BAUD xor x"01" xor ("0000000" & reg_baud_sel);
                        tx_len <= 5;

                    elsif cmd_reg = CMD_STATUS and len_reg = 0 then
                        tx_buf(0) <= SOF_BYTE; tx_buf(1) <= CMD_STATUS; tx_buf(2) <= x"01";
                        tx_buf(3) <= in_status_byte;
                        tx_buf(4) <= CMD_STATUS xor x"01" xor in_status_byte;
                        tx_len <= 5;
                    end if;
                    
                    tx_cnt <= 0;
                    state <= SEND_RESP;

                when SEND_RESP =>
                    if tx_busy = '0' then tx_data <= tx_buf(tx_cnt); tx_start <= '1'; state <= WAIT_TX_PULSE; end if;

                when WAIT_TX_PULSE =>
                    tx_start <= '0'; state <= WAIT_TX_DONE;

                when WAIT_TX_DONE =>
                    if tx_busy = '0' then
                        if tx_cnt = tx_len - 1 then state <= IDLE;
                        else tx_cnt <= tx_cnt + 1; state <= SEND_RESP; end if;
                    end if;

                when others => state <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;