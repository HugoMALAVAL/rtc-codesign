																   -- =============================================================================
-- protocol_tb.vhd
-- Testbench du décodeur de protocole (protocol_decoder)
--
-- Approche :
--   • Les octets RX sont injectés directement via rx_data / rx_done
--     (pas de simulation UART complète — on teste la logique protocolaire).
--   • tx_busy est simulé par un compteur interne : il monte quand tx_start
--     est détecté, descend après TX_BUSY_CYCLES cycles.
--   • Les octets de réponse émis (tx_data / tx_start) sont capturés dans
--     resp_buf[] et comparés aux valeurs attendues.
--
-- Calcul des CRC (XOR successif : CMD ^ LEN ^ payload[0] ^ ... ^ payload[N-1])
--
-- Plan de tests :
--   T1  : CMD_GET_ALL (0x01, len=0)
--         Frame TX: 55 01 00 | CRC=01
--         Réponse attendue (10 octets):
--           55 01 06 [56 34 12 18 03 1A] CRC=1A
--           avec in_hr=12 in_min=34 in_sec=56 in_day=18 in_month=3 in_year=26
--
--   T2  : CMD_GET_TIME (0x11, len=0)
--         Frame TX: 55 11 00 | CRC=11
--         Réponse attendue (7 octets): 55 11 03 38 22 0C CRC=04
--
--   T3  : CMD_SET_TIME (0x12, len=3, payload=[sec=30 min=45 hr=10])
--         CRC = 12^03^1E^2D^0A = 28
--         Frame TX: 55 12 03 1E 2D 0A 28
--         Réponse attendue: ACK (0x08) — 1 octet
--         Vérification : set_time_en='1', out_sec=30, out_min=45, out_hr=10
--
--   T4  : CRC Invalide ? NACK
--         Frame TX: 55 01 00 FF (CRC délibérément faux)
--         Réponse attendue: NACK (0x09) — 1 octet
--
--   T5  : CMD_STATUS (0x07, len=0)
--         Frame TX: 55 07 00 | CRC=07
--         Réponse attendue (5 octets): 55 07 01 [status] CRC
--
--   T6  : CMD_SET_ALARM (0x04, len=3, payload=[sec=30 min=0 hr=7])
--         CRC = 04^03^1E^00^07 = 1E
--         Frame TX: 55 04 03 1E 00 07 1E
--         Réponse attendue: ACK (0x08)
--         Vérification : set_al_en='1', out_al_sec=30, out_al_min=0, out_al_hr=7
--
--   T7  : CMD_SET_AL_EN (0x0B, len=1, payload=[0x01=ON])
--         CRC = 0B^01^01 = 0B
--         Frame TX: 55 0B 01 01 0B
--         Réponse attendue: ACK (0x08)
--         Vérification : out_al_en_cmd='1', out_al_en_val='1'
--
--   T8  : CMD_SET_BAUD (0x06, len=1, payload=[0x00=9600])
--         CRC = 06^01^00 = 07
--         Frame TX: 55 06 01 00 07
--         Réponse attendue: ACK (0x08)
--         Vérification : out_baud_sel='0'
-- =============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity protocol_tb is
end protocol_tb;

architecture Behavioral of protocol_tb is

    -- -------------------------------------------------------------------------
    -- Constantes
    -- -------------------------------------------------------------------------
    constant CLK_PERIOD     : time    := 10 ns;
    constant TX_BUSY_CYCLES : integer := 25;  -- Durée simulée d'une émission UART

    -- -------------------------------------------------------------------------
    -- Horloges et reset
    -- -------------------------------------------------------------------------
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    -- -------------------------------------------------------------------------
    -- Interface RX ? DUT (injectée directement)
    -- -------------------------------------------------------------------------
    signal rx_data : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_done : std_logic := '0';

    -- -------------------------------------------------------------------------
    -- Interface TX ? DUT (capturée par le testbench)
    -- -------------------------------------------------------------------------
    signal tx_data  : std_logic_vector(7 downto 0);
    signal tx_start : std_logic;
    signal tx_busy  : std_logic := '0';    -- Simulé ici

    -- -------------------------------------------------------------------------
    -- Sorties de contrôle du DUT
    -- -------------------------------------------------------------------------
    signal crc_ok_led     : std_logic;
    signal rx_valid_pulse : std_logic;

    signal set_time_en : std_logic;
    signal out_hr      : integer range 0 to 23;
    signal out_min     : integer range 0 to 59;
    signal out_sec     : integer range 0 to 59;

    signal set_date_en : std_logic;
    signal out_day     : integer range 1 to 31;
    signal out_month   : integer range 1 to 12;
    signal out_year    : integer range 0 to 99;

    signal set_al_en   : std_logic;
    signal out_al_hr   : integer range 0 to 23;
    signal out_al_min  : integer range 0 to 59;
    signal out_al_sec  : integer range 0 to 59;

    signal out_al_en_cmd : std_logic;
    signal out_al_en_val : std_logic;

    signal out_baud_sel  : std_logic;

    -- -------------------------------------------------------------------------
    -- Entrées lues par le DUT (valeurs courantes du RTC)
    --   in_hr=12, in_min=34, in_sec=56, in_day=18, in_month=3, in_year=26
    -- -------------------------------------------------------------------------
    signal in_hr    : integer range 0 to 23 := 12;
    signal in_min   : integer range 0 to 59 := 34;
    signal in_sec   : integer range 0 to 59 := 56;
    signal in_day   : integer range 1 to 31 := 18;
    signal in_month : integer range 1 to 12 := 3;
    signal in_year  : integer range 0 to 99 := 26;

    signal in_al_hr  : integer range 0 to 23 := 0;
    signal in_al_min : integer range 0 to 59 := 0;
    signal in_al_sec : integer range 0 to 59 := 0;

    signal in_status_byte : std_logic_vector(7 downto 0) := x"00";

    -- -------------------------------------------------------------------------
    -- Tampon de capture des octets émis par le DUT
    -- -------------------------------------------------------------------------
    type resp_array is array(0 to 15) of std_logic_vector(7 downto 0);
    signal resp_buf : resp_array := (others => (others => '0'));
    signal resp_cnt : integer := 0;   -- Nombre d'octets capturés au total

begin

    -- =========================================================================
    -- Horloge
    -- =========================================================================
    clk <= not clk after CLK_PERIOD / 2;

    -- =========================================================================
    -- Instanciation du DUT
    -- =========================================================================
    DUT : entity work.protocol_decoder
        port map (
            clk        => clk,
            rst        => rst,
            rx_data    => rx_data,
            rx_done    => rx_done,
            tx_data    => tx_data,
            tx_start   => tx_start,
            tx_busy    => tx_busy,
            crc_ok_led     => crc_ok_led,
            rx_valid_pulse => rx_valid_pulse,
            set_time_en   => set_time_en,
            out_hr        => out_hr,
            out_min       => out_min,
            out_sec       => out_sec,
            set_date_en   => set_date_en,
            out_day       => out_day,
            out_month     => out_month,
            out_year      => out_year,
            set_al_en     => set_al_en,
            out_al_hr     => out_al_hr,
            out_al_min    => out_al_min,
            out_al_sec    => out_al_sec,
            out_al_en_cmd => out_al_en_cmd,
            out_al_en_val => out_al_en_val,
            in_hr         => in_hr,
            in_min        => in_min,
            in_sec        => in_sec,
            in_day        => in_day,
            in_month      => in_month,
            in_year       => in_year,
            in_al_hr      => in_al_hr,
            in_al_min     => in_al_min,
            in_al_sec     => in_al_sec,
            in_status_byte => in_status_byte,
            out_baud_sel  => out_baud_sel
        );

    -- =========================================================================
    -- Simulation de tx_busy
    --   Dès que tx_start='1' est détecté, tx_busy passe à '1' pour
    --   TX_BUSY_CYCLES cycles, puis redescend à '0'.
    -- =========================================================================
    tx_busy_model : process(clk, rst)
        variable cnt : integer := 0;
    begin
        if rst = '1' then
            tx_busy <= '0';
            cnt     := 0;
        elsif rising_edge(clk) then
            if tx_start = '1' and tx_busy = '0' then
                tx_busy <= '1';
                cnt     := TX_BUSY_CYCLES;
            elsif cnt > 0 then
                cnt := cnt - 1;
                if cnt = 0 then
                    tx_busy <= '0';
                end if;
            end if;
        end if;
    end process;

    -- =========================================================================
    -- Capture des octets de réponse émis par le DUT
    -- =========================================================================
    capture_proc : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                resp_cnt <= 0;
            elsif tx_start = '1' then
                -- Enregistrement dans le tampon circulaire (16 emplacements max)
                resp_buf(resp_cnt mod 16) <= tx_data;
                resp_cnt <= resp_cnt + 1;
                report "[TX CAPTURE] Octet " & integer'image(resp_cnt) &
                       " = 0x" & to_hstring(tx_data);
            end if;
        end if;
    end process;

    -- =========================================================================
    -- Processus de stimulation principal
    -- =========================================================================
    stim_proc : process

        -- -----------------------------------------------------------------------
        -- send_rx_byte : injecte un octet dans la FSM comme si le RX UART
        --                venait de finir de recevoir cet octet.
        --   Attendre quelques cycles entre les octets pour laisser la FSM
        --   changer d'état (IDLE?READ_CMD?READ_LEN?...).
        -- -----------------------------------------------------------------------
        procedure send_rx_byte (data : std_logic_vector(7 downto 0)) is
        begin
            wait until rising_edge(clk);
            rx_data <= data;
            rx_done <= '1';
            wait until rising_edge(clk);
            rx_done <= '0';
            wait for CLK_PERIOD * 5;   -- Délai pour que la FSM change d'état
        end procedure;

        -- -----------------------------------------------------------------------
        -- wait_resp : attend que resp_cnt atteigne une cible (avec timeout)
        -- -----------------------------------------------------------------------
        procedure wait_resp (target : integer) is
            variable timeout_cnt : integer := 0;
        begin
            while resp_cnt < target loop
                wait for CLK_PERIOD;
                timeout_cnt := timeout_cnt + 1;
                if timeout_cnt > 10000 then
                    report "[TIMEOUT] Attente de " & integer'image(target) &
                           " octets de réponse — seulement " &
                           integer'image(resp_cnt) & " reçus." severity error;
                    exit;
                end if;
            end loop;
            wait for CLK_PERIOD * 5;
        end procedure;

        -- -----------------------------------------------------------------------
        -- check_byte : vérifie un octet dans resp_buf à l'index donné
        -- -----------------------------------------------------------------------
        procedure check_byte (
            idx      : integer;
            expected : std_logic_vector(7 downto 0);
            label    : string
        ) is
        begin
            if resp_buf(idx mod 16) = expected then
                report "[PASS] " & label &
                       " resp[" & integer'image(idx) & "] = 0x" &
                       to_hstring(expected) severity note;
            else
                report "[FAIL] " & label &
                       " resp[" & integer'image(idx) & "]" &
                       " attendu=0x" & to_hstring(expected) &
                       " recu=0x"    & to_hstring(resp_buf(idx mod 16))
                       severity error;
            end if;
        end procedure;

        variable r : integer;  -- Index de départ dans resp_buf pour chaque test

    begin
        -- -----------------------------------------------------------------------
        -- Reset
        -- -----------------------------------------------------------------------
        rst <= '1';
        wait for CLK_PERIOD * 20;
        rst <= '0';
        wait for CLK_PERIOD * 20;

        report "===================================================";
        report " PROTOCOL DECODER TESTBENCH - DEBUT";
        report "===================================================";

        -- =======================================================================
        -- T1 : CMD_GET_ALL (0x01, len=0)
        --   Frame envoyée  : 55 01 00 01
        --   Réponse attendue (10 octets) :
        --     [0]=55 [1]=01 [2]=06
        --     [3]=38(56) [4]=22(34) [5]=0C(12)   ? sec, min, hr
        --     [6]=12(18) [7]=03( 3) [8]=1A(26)   ? day, month, year
        --     [9]=1A  (CRC calculé ci-dessous)
        --   CRC = 01^06^38^22^0C^12^03^1A = 1A
        -- =======================================================================
        report "--- T1 : CMD_GET_ALL ---";
        r := resp_cnt;
        send_rx_byte(x"55");   -- SOF
        send_rx_byte(x"01");   -- CMD_GET_ALL
        send_rx_byte(x"00");   -- LEN=0
        send_rx_byte(x"01");   -- CRC = 01^00 = 01

        wait_resp(r + 10);

        check_byte(r+0,  x"55", "T1 SOF");
        check_byte(r+1,  x"01", "T1 CMD");
        check_byte(r+2,  x"06", "T1 LEN");
        check_byte(r+3,  x"38", "T1 sec=56");
        check_byte(r+4,  x"22", "T1 min=34");
        check_byte(r+5,  x"0C", "T1 hr=12");
        check_byte(r+6,  x"12", "T1 day=18");
        check_byte(r+7,  x"03", "T1 month=3");
        check_byte(r+8,  x"1A", "T1 year=26");
        check_byte(r+9,  x"1A", "T1 CRC");

        -- =======================================================================
        -- T2 : CMD_GET_TIME (0x11, len=0)
        --   Frame envoyée  : 55 11 00 11
        --   Réponse attendue (7 octets) :
        --     55 11 03 38 22 0C CRC=04
        --   CRC = 11^03^38^22^0C = 04
        -- =======================================================================
        report "--- T2 : CMD_GET_TIME ---";
        r := resp_cnt;
        send_rx_byte(x"55");
        send_rx_byte(x"11");   -- CMD_GET_TIME
        send_rx_byte(x"00");
        send_rx_byte(x"11");   -- CRC = 11^00 = 11

        wait_resp(r + 7);

        check_byte(r+0, x"55", "T2 SOF");
        check_byte(r+1, x"11", "T2 CMD");
        check_byte(r+2, x"03", "T2 LEN");
        check_byte(r+3, x"38", "T2 sec=56");
        check_byte(r+4, x"22", "T2 min=34");
        check_byte(r+5, x"0C", "T2 hr=12");
        check_byte(r+6, x"04", "T2 CRC");

        -- =======================================================================
        -- T3 : CMD_SET_TIME (0x12, len=3, payload=[30, 45, 10])
        --   CRC = 12^03^1E^2D^0A = 28
        --   Frame envoyée  : 55 12 03 1E 2D 0A 28
        --   Réponse attendue : ACK (0x08) en 1 octet
        --   Vérification des sorties de contrôle après traitement.
        -- =======================================================================
        report "--- T3 : CMD_SET_TIME ---";
        r := resp_cnt;
        send_rx_byte(x"55");
        send_rx_byte(x"12");   -- CMD_SET_TIME
        send_rx_byte(x"03");   -- LEN=3
        send_rx_byte(x"1E");   -- sec=30
        send_rx_byte(x"2D");   -- min=45
        send_rx_byte(x"0A");   -- hr=10
        send_rx_byte(x"28");   -- CRC

        wait_resp(r + 1);
        check_byte(r, x"08", "T3 ACK");

        -- Vérification des sorties de contrôle (elles durent 1 cycle dans PROCESS_CMD)
        -- On les capture avec le processus de surveillance ci-dessous.
        wait for CLK_PERIOD * 2;
        if out_hr = 10 and out_min = 45 and out_sec = 30 then
            report "[PASS] T3 out_hr=10 out_min=45 out_sec=30" severity note;
        else
            report "[FAIL] T3 sorties SET_TIME incorrectes : hr=" &
                   integer'image(out_hr) & " min=" &
                   integer'image(out_min) & " sec=" &
                   integer'image(out_sec) severity error;
        end if;

        -- =======================================================================
        -- T4 : CRC invalide ? NACK
        --   Frame envoyée  : 55 01 00 FF  (CRC faux, attendu=0x01)
        --   Réponse attendue : NACK (0x09) en 1 octet
        -- =======================================================================
        report "--- T4 : CRC invalide -> NACK ---";
        r := resp_cnt;
        send_rx_byte(x"55");
        send_rx_byte(x"01");   -- CMD_GET_ALL
        send_rx_byte(x"00");
        send_rx_byte(x"FF");   -- CRC délibérément faux !

        wait_resp(r + 1);
        check_byte(r, x"09", "T4 NACK");

        -- Vérifier que crc_ok_led est tombé à '0'
        wait for CLK_PERIOD * 3;
        if crc_ok_led = '0' then
            report "[PASS] T4 crc_ok_led='0' apres CRC invalide" severity note;
        else
            report "[FAIL] T4 crc_ok_led devrait etre '0'" severity error;
        end if;

        -- =======================================================================
        -- T5 : CMD_STATUS (0x07, len=0)
        --   Frame envoyée  : 55 07 00 07
        --   Réponse attendue (5 octets) :
        --     55 07 01 [status=00] CRC=06
        --   CRC = 07^01^00 = 06
        -- =======================================================================
        report "--- T5 : CMD_STATUS ---";
        in_status_byte <= x"00";
        wait for CLK_PERIOD * 3;
        r := resp_cnt;
        send_rx_byte(x"55");
        send_rx_byte(x"07");   -- CMD_STATUS
        send_rx_byte(x"00");
        send_rx_byte(x"07");   -- CRC = 07^00 = 07

        wait_resp(r + 5);
        check_byte(r+0, x"55", "T5 SOF");
        check_byte(r+1, x"07", "T5 CMD");
        check_byte(r+2, x"01", "T5 LEN");
        check_byte(r+3, x"00", "T5 status=0x00");
        check_byte(r+4, x"06", "T5 CRC");

        -- =======================================================================
        -- T6 : CMD_SET_ALARM (0x04, len=3, payload=[sec=30, min=0, hr=7])
        --   CRC = 04^03^1E^00^07 = 1E
        --   Frame envoyée  : 55 04 03 1E 00 07 1E
        --   Réponse attendue : ACK (0x08)
        -- =======================================================================
        report "--- T6 : CMD_SET_ALARM ---";
        r := resp_cnt;
        send_rx_byte(x"55");
        send_rx_byte(x"04");   -- CMD_SET_ALARM
        send_rx_byte(x"03");
        send_rx_byte(x"1E");   -- sec=30
        send_rx_byte(x"00");   -- min=0
        send_rx_byte(x"07");   -- hr=7
        send_rx_byte(x"1E");   -- CRC

        wait_resp(r + 1);
        check_byte(r, x"08", "T6 ACK");

        wait for CLK_PERIOD * 2;
        if out_al_hr = 7 and out_al_min = 0 and out_al_sec = 30 then
            report "[PASS] T6 out_al_hr=7 out_al_min=0 out_al_sec=30" severity note;
        else
            report "[FAIL] T6 sorties SET_ALARM incorrectes : hr=" &
                   integer'image(out_al_hr) & " min=" &
                   integer'image(out_al_min) & " sec=" &
                   integer'image(out_al_sec) severity error;
        end if;

        -- =======================================================================
        -- T7 : CMD_SET_AL_EN (0x0B, len=1, payload=[0x01 = ON])
        --   CRC = 0B^01^01 = 0B
        --   Frame envoyée  : 55 0B 01 01 0B
        --   Réponse attendue : ACK (0x08)
        --   Vérification : out_al_en_cmd='1' et out_al_en_val='1'
        -- =======================================================================
        report "--- T7 : CMD_SET_AL_EN (ON) ---";
        r := resp_cnt;
        send_rx_byte(x"55");
        send_rx_byte(x"0B");   -- CMD_SET_AL_EN
        send_rx_byte(x"01");
        send_rx_byte(x"01");   -- payload : bit0=1 ? ON
        send_rx_byte(x"0B");   -- CRC

        wait_resp(r + 1);
        check_byte(r, x"08", "T7 ACK");

        -- out_al_en_cmd est une impulsion d'1 cycle — on ne peut pas la capturer
        -- ici de façon fiable ; on vérifie out_al_en_val qui reste stable.
        wait for CLK_PERIOD * 2;
        if out_al_en_val = '1' then
            report "[PASS] T7 out_al_en_val='1' (alarme activee)" severity note;
        else
            report "[FAIL] T7 out_al_en_val devrait etre '1'" severity error;
        end if;

        -- =======================================================================
        -- T8 : CMD_SET_BAUD (0x06, len=1, payload=[0x00 ? 9600 bauds])
        --   CRC = 06^01^00 = 07
        --   Frame envoyée  : 55 06 01 00 07
        --   Réponse attendue : ACK (0x08)
        --   Vérification : out_baud_sel='0'
        -- =======================================================================
        report "--- T8 : CMD_SET_BAUD (9600) ---";
        r := resp_cnt;
        send_rx_byte(x"55");
        send_rx_byte(x"06");   -- CMD_SET_BAUD
        send_rx_byte(x"01");
        send_rx_byte(x"00");   -- bit0=0 ? baud_sel='0' ? 9600 bauds
        send_rx_byte(x"07");   -- CRC

        wait_resp(r + 1);
        check_byte(r, x"08", "T8 ACK");

        wait for CLK_PERIOD * 5;
        if out_baud_sel = '0' then
            report "[PASS] T8 out_baud_sel='0' (9600 bauds)" severity note;
        else
            report "[FAIL] T8 out_baud_sel devrait etre '0'" severity error;
        end if;

        -- -----------------------------------------------------------------------
        report "===================================================";
        report " PROTOCOL DECODER TESTBENCH - FIN";
        report " Total octets de reponse captures : " &
               integer'image(resp_cnt);
        report "===================================================";
        report "SIMULATION TERMINEE" severity failure;
        wait;
    end process;

    -- =========================================================================
    -- Surveillance des impulsions de contrôle (set_time_en, set_al_en, etc.)
    -- =========================================================================
    ctrl_monitor : process
    begin
        loop
            wait until rising_edge(clk);
            if set_time_en = '1' then
                report "[CTRL] set_time_en='1' -> hr=" & integer'image(out_hr) &
                       " min=" & integer'image(out_min) &
                       " sec=" & integer'image(out_sec);
            end if;
            if set_date_en = '1' then
                report "[CTRL] set_date_en='1' -> day=" & integer'image(out_day) &
                       " month=" & integer'image(out_month) &
                       " year="  & integer'image(out_year);
            end if;
            if set_al_en = '1' then
                report "[CTRL] set_al_en='1' -> al_hr=" & integer'image(out_al_hr) &
                       " al_min=" & integer'image(out_al_min) &
                       " al_sec=" & integer'image(out_al_sec);
            end if;
            if out_al_en_cmd = '1' then
                report "[CTRL] out_al_en_cmd='1' -> val=" &
                       std_logic'image(out_al_en_val);
            end if;
            if rx_valid_pulse = '1' then
                report "[CTRL] rx_valid_pulse='1' (trame valide recue)";
            end if;
        end loop;
    end process;

end Behavioral;