-- =============================================================================
-- rtc_tb.vhd
-- Testbench des modules RTC : rtc_time et rtc_date
--
-- Les impulsions CE_1s sont générées artificiellement (tous les 50 cy) pour
-- accélérer la simulation (pas besoin du vrai clock_divider).
--
-- Plan de tests :
--   -- rtc_time --------------------------------------------------------------
--   T1  : Incrément libre sur CE_1s (0:00:00 ? 0:00:05)
--   T2  : Écriture via UART_SET_EN (réglage à 10:30:00)
--   T3  : Mode réglage BTN_UP sur les heures (HR : 10 ? 11)
--   T4  : Mode réglage BTN_DN sur les minutes (MIN : 30 ? 29)
--   T5  : Rollover 23:59:58 ? 00:00:01 + vérification CE_DDU
--   -- rtc_date --------------------------------------------------------------
--   T6  : Écriture via UART_SET_EN (réglage à 18/03/26)
--   T7  : Incrément via CE_DDU (18 ? 19 mars)
--   T8  : Fin de mois de février non bissextile (28/02/25 ? 01/03/25)
--   T9  : Fin d'année (31/12/26 ? 01/01/27 ? year = 27)
-- =============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rtc_tb is
end rtc_tb;

architecture Behavioral of rtc_tb is

    constant CLK_PERIOD : time := 10 ns;

    -- -- Ports partagés -------------------------------------------------------
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '1';
    signal ce_1s        : std_logic := '0';

    -- -- Ports rtc_time -------------------------------------------------------
    signal mode_reglage : std_logic := '0';
    signal sel_state    : std_logic_vector(2 downto 0) := "000";
    signal btn_up       : std_logic := '0';
    signal btn_dn       : std_logic := '0';

    signal uart_set_en  : std_logic := '0';
    signal uart_hr      : integer range 0 to 23 := 0;
    signal uart_min     : integer range 0 to 59 := 0;
    signal uart_sec     : integer range 0 to 59 := 0;

    signal out_hr       : integer range 0 to 23;
    signal out_min      : integer range 0 to 59;
    signal out_sec      : integer range 0 to 59;

    signal ssu, sst, mmu, mmt, hhu : std_logic_vector(3 downto 0);
    signal hht   : std_logic_vector(1 downto 0);
    signal ce_ddu : std_logic;   -- Signal de sortie rtc_time ? entrée rtc_date

    -- -- Ports rtc_date -------------------------------------------------------
    signal uart_date_en  : std_logic := '0';
    signal uart_day      : integer range 1  to 31 := 1;
    signal uart_month    : integer range 1  to 12 := 1;
    signal uart_year     : integer range 0  to 99 := 0;

    signal out_day       : integer range 1  to 31;
    signal out_month     : integer range 1  to 12;
    signal out_year      : integer range 0  to 99;

    signal ddu, ddt, mtu, mtt, yyu, yyt : std_logic_vector(3 downto 0);

begin

    -- =========================================================================
    -- Horloge
    -- =========================================================================
    clk <= not clk after CLK_PERIOD / 2;

    -- =========================================================================
    -- Instanciation rtc_time
    -- =========================================================================
    U_TIME : entity work.rtc_time
        port map (
            CLK          => clk,
            RST          => rst,
            CE_1s        => ce_1s,
            MODE_REGLAGE => mode_reglage,
            SEL_STATE    => sel_state,
            BTN_UP_PULSE => btn_up,
            BTN_DN_PULSE => btn_dn,
            UART_SET_EN  => uart_set_en,
            UART_HR      => uart_hr,
            UART_MIN     => uart_min,
            UART_SEC     => uart_sec,
            OUT_HR       => out_hr,
            OUT_MIN      => out_min,
            OUT_SEC      => out_sec,
            SSU          => ssu,
            SST          => sst,
            MMU          => mmu,
            MMT          => mmt,
            HHU          => hhu,
            HHT          => hht,
            CE_DDU       => ce_ddu
        );

    -- =========================================================================
    -- Instanciation rtc_date
    -- =========================================================================
    U_DATE : entity work.rtc_date
        port map (
            CLK          => clk,
            RST          => rst,
            CE_DDU       => ce_ddu,
            MODE_REGLAGE => mode_reglage,
            SEL_STATE    => sel_state,
            BTN_UP_PULSE => btn_up,
            BTN_DN_PULSE => btn_dn,
            UART_SET_EN  => uart_date_en,
            UART_DAY     => uart_day,
            UART_MONTH   => uart_month,
            UART_YEAR    => uart_year,
            OUT_DAY      => out_day,
            OUT_MONTH    => out_month,
            OUT_YEAR     => out_year,
            DDU          => ddu,
            DDT          => ddt,
            MTU          => mtu,
            MTT          => mtt,
            YYU          => yyu,
            YYT          => yyt
        );

    -- =========================================================================
    -- Processus de stimulation
    -- =========================================================================
    stim_proc : process

        -- -----------------------------------------------------------------------
        -- pulse_ce1s : génère une impulsion CE_1s d'1 cycle d'horloge
        -- -----------------------------------------------------------------------
        procedure pulse_ce1s is
        begin
            wait until rising_edge(clk);
            ce_1s <= '1';
            wait until rising_edge(clk);
            ce_1s <= '0';
            wait for CLK_PERIOD * 3;  -- Laisser le temps au registre de se mettre à jour
        end procedure;

        -- -----------------------------------------------------------------------
        -- pulse_btn_up / pulse_btn_dn : impulsions boutons (1 cycle)
        -- -----------------------------------------------------------------------
        procedure pulse_btn_up is
        begin
            wait until rising_edge(clk);
            btn_up <= '1';
            wait until rising_edge(clk);
            btn_up <= '0';
            wait for CLK_PERIOD * 3;
        end procedure;

        procedure pulse_btn_dn is
        begin
            wait until rising_edge(clk);
            btn_dn <= '1';
            wait until rising_edge(clk);
            btn_dn <= '0';
            wait for CLK_PERIOD * 3;
        end procedure;

        -- -----------------------------------------------------------------------
        -- set_time_uart : positionne l'heure via l'interface UART (1 cycle EN)
        -- -----------------------------------------------------------------------
        procedure set_time_uart (h, m, s : integer) is
        begin
            wait until rising_edge(clk);
            uart_hr     <= h;
            uart_min    <= m;
            uart_sec    <= s;
            uart_set_en <= '1';
            wait until rising_edge(clk);
            uart_set_en <= '0';
            wait for CLK_PERIOD * 5;
        end procedure;

        -- -----------------------------------------------------------------------
        -- set_date_uart : positionne la date via l'interface UART
        -- -----------------------------------------------------------------------
        procedure set_date_uart (d, mo, y : integer) is
        begin
            wait until rising_edge(clk);
            uart_day    <= d;
            uart_month  <= mo;
            uart_year   <= y;
            uart_date_en <= '1';
            wait until rising_edge(clk);
            uart_date_en <= '0';
            wait for CLK_PERIOD * 5;
        end procedure;

        -- -----------------------------------------------------------------------
        -- check_time : assertion sur l'heure courante (affiche erreur si écart)
        -- -----------------------------------------------------------------------
        procedure check_time (exp_h, exp_m, exp_s : integer; label : string) is
        begin
            wait for CLK_PERIOD;  -- Un cycle de stabilisation
            if out_hr = exp_h and out_min = exp_m and out_sec = exp_s then
                report "[PASS] " & label &
                       " : " & integer'image(out_hr) &
                       "h"   & integer'image(out_min) &
                       "m"   & integer'image(out_sec) & "s" severity note;
            else
                report "[FAIL] " & label &
                       " | Attendu "  & integer'image(exp_h) & "h" &
                       integer'image(exp_m) & "m" & integer'image(exp_s) & "s" &
                       " | Recu "     & integer'image(out_hr) & "h" &
                       integer'image(out_min) & "m" & integer'image(out_sec) & "s"
                       severity error;
            end if;
        end procedure;

        -- -----------------------------------------------------------------------
        -- check_date
        -- -----------------------------------------------------------------------
        procedure check_date (exp_d, exp_mo, exp_y : integer; label : string) is
        begin
            wait for CLK_PERIOD;
            if out_day = exp_d and out_month = exp_mo and out_year = exp_y then
                report "[PASS] " & label &
                       " : " & integer'image(out_day)   & "/" &
                       integer'image(out_month) & "/" &
                       integer'image(out_year) severity note;
            else
                report "[FAIL] " & label &
                       " | Attendu "  & integer'image(exp_d) & "/" &
                       integer'image(exp_mo) & "/" & integer'image(exp_y) &
                       " | Recu "     & integer'image(out_day) & "/" &
                       integer'image(out_month) & "/" & integer'image(out_year)
                       severity error;
            end if;
        end procedure;

    begin
        -- -----------------------------------------------------------------------
        -- Reset (les valeurs de départ de rtc_time/date sont 00:00:00 et 24/02/26)
        -- -----------------------------------------------------------------------
        rst <= '1';
        wait for CLK_PERIOD * 20;
        rst <= '0';
        wait for CLK_PERIOD * 10;

        report "===================================================";
        report " RTC TESTBENCH - DEBUT";
        report "===================================================";

        -- -----------------------------------------------------------------------
        -- T1 : Incrément libre (mode_reglage=0, uart_set_en=0)
        --      Après reset, sec=0. On envoie 5 CE_1s ? sec doit valoir 5.
        -- -----------------------------------------------------------------------
        report "--- T1 : Increment libre ---";
        for i in 1 to 5 loop
            pulse_ce1s;
        end loop;
        check_time(0, 0, 5, "T1 - apres 5 CE_1s");

        -- -----------------------------------------------------------------------
        -- T2 : Écriture UART (réglage à 10:30:00)
        -- -----------------------------------------------------------------------
        report "--- T2 : Ecriture UART_SET_EN ---";
        set_time_uart(10, 30, 0);
        check_time(10, 30, 0, "T2 - apres UART SET 10:30:00");

        -- Un CE_1s pour vérifier que l'incrément reprend bien depuis la nouvelle valeur
        pulse_ce1s;
        check_time(10, 30, 1, "T2 - apres 1 CE_1s depuis 10:30:00");

        -- -----------------------------------------------------------------------
        -- T3 : Mode réglage BTN_UP sur les heures (SEL_STATE="000")
        -- -----------------------------------------------------------------------
        report "--- T3 : Mode reglage BTN_UP (heures) ---";
        mode_reglage <= '1';
        sel_state    <= "000";   -- Curseur sur les heures
        wait for CLK_PERIOD * 5;

        -- Appui BTN_UP : HR 10 ? 11
        pulse_btn_up;
        check_time(11, 30, 1, "T3 - apres BTN_UP (HR=11)");

        -- Appui BTN_UP encore : HR 11 ? 12
        pulse_btn_up;
        check_time(12, 30, 1, "T3 - apres 2e BTN_UP (HR=12)");

        mode_reglage <= '0';
        wait for CLK_PERIOD * 5;

        -- -----------------------------------------------------------------------
        -- T4 : Mode réglage BTN_DN sur les minutes (SEL_STATE="001")
        -- -----------------------------------------------------------------------
        report "--- T4 : Mode reglage BTN_DN (minutes) ---";
        mode_reglage <= '1';
        sel_state    <= "001";   -- Curseur sur les minutes
        wait for CLK_PERIOD * 5;

        -- MIN est à 30 ; appui BTN_DN : 30 ? 29
        pulse_btn_dn;
        check_time(12, 29, 1, "T4 - apres BTN_DN (MIN=29)");

        mode_reglage <= '0';
        wait for CLK_PERIOD * 5;

        -- -----------------------------------------------------------------------
        -- T5 : Rollover 23:59:58 ? 00:00:01 + test du signal CE_DDU
        -- -----------------------------------------------------------------------
        report "--- T5 : Rollover 23:59:58 -> 00:00:01 ---";
        set_time_uart(23, 59, 58);
        check_time(23, 59, 58, "T5 - chargement 23:59:58");

        pulse_ce1s;
        check_time(23, 59, 59, "T5 - apres CE_1s #1 (23:59:59)");

        pulse_ce1s;  -- ? 00:00:00, CE_DDU doit monter pendant cette impulsion
        check_time(0, 0, 0,  "T5 - apres CE_1s #2 (00:00:00)");

        pulse_ce1s;
        check_time(0, 0, 1,  "T5 - apres CE_1s #3 (00:00:01)");

        -- -----------------------------------------------------------------------
        -- T6 : Réglage de la date via UART (18/03/26)
        -- -----------------------------------------------------------------------
        report "--- T6 : Ecriture date UART 18/03/26 ---";
        set_date_uart(18, 3, 26);
        check_date(18, 3, 26, "T6 - date UART 18/03/26");

        -- -----------------------------------------------------------------------
        -- T7 : Avancement d'un jour via CE_DDU (18 ? 19 mars)
        --      On utilise le rollover heure pour générer CE_DDU.
        --      Méthode plus directe : set_time_uart à 23:59:59 puis pulse_ce1s.
        -- -----------------------------------------------------------------------
        report "--- T7 : Avancement date via CE_DDU ---";
        set_time_uart(23, 59, 59);
        pulse_ce1s;   -- ? 00:00:00 + CE_DDU='1' ? date passe à 19/03/26
        wait for CLK_PERIOD * 10;
        check_date(19, 3, 26, "T7 - 23:59:59->00:00:00, day 18->19");

        -- -----------------------------------------------------------------------
        -- T8 : Fin de février non bissextile (28/02/25 ? 01/03/25)
        --      year=25 ? 25 mod 4 = 1 ? 0 ? février = 28 jours
        -- -----------------------------------------------------------------------
        report "--- T8 : Fin de fevrier non bissextile (28/02/25) ---";
        set_date_uart(28, 2, 25);
        check_date(28, 2, 25, "T8 - date UART 28/02/25");

        set_time_uart(23, 59, 59);
        pulse_ce1s;   -- ? CE_DDU : 28/02/25 ? 01/03/25
        wait for CLK_PERIOD * 10;
        check_date(1, 3, 25, "T8 - 28/02/25 -> 01/03/25");

        -- Vérification de l'année bissextile : year=24 ? 24 mod 4 = 0 ? 29 jours
        report "--- T8b : Annee bissextile (28/02/24) ---";
        set_date_uart(28, 2, 24);
        set_time_uart(23, 59, 59);
        pulse_ce1s;   -- ? CE_DDU : 28/02/24 ? 29/02/24 (année bissextile !)
        wait for CLK_PERIOD * 10;
        check_date(29, 2, 24, "T8b - 28/02/24 -> 29/02/24 (bissextile)");

        -- -----------------------------------------------------------------------
        -- T9 : Fin d'année (31/12/26 ? 01/01/27)
        -- -----------------------------------------------------------------------
        report "--- T9 : Fin d'annee (31/12/26 -> 01/01/27) ---";
        set_date_uart(31, 12, 26);
        set_time_uart(23, 59, 59);
        pulse_ce1s;
        wait for CLK_PERIOD * 10;
        check_date(1, 1, 27, "T9 - 31/12/26 -> 01/01/27");

        -- -----------------------------------------------------------------------
        -- T10 : Mode réglage date BTN_UP (curseur sur le jour, SEL_STATE="011")
        -- -----------------------------------------------------------------------
        report "--- T10 : Mode reglage date BTN_UP/DN ---";
        set_date_uart(15, 6, 26);
        mode_reglage <= '1';
        sel_state    <= "011";   -- Curseur sur le jour
        wait for CLK_PERIOD * 5;

        pulse_btn_up;
        check_date(16, 6, 26, "T10 - BTN_UP jour (15->16)");

        pulse_btn_dn;
        check_date(15, 6, 26, "T10 - BTN_DN jour (16->15)");

        sel_state <= "100";  -- Curseur sur le mois
        wait for CLK_PERIOD * 5;
        pulse_btn_up;
        check_date(15, 7, 26, "T10 - BTN_UP mois (6->7)");

        mode_reglage <= '0';
        wait for CLK_PERIOD * 5;

        -- -----------------------------------------------------------------------
        report "===================================================";
        report " RTC TESTBENCH - FIN";
        report "===================================================";
        report "SIMULATION TERMINEE" severity failure;
        wait;
    end process;

    -- =========================================================================
    -- Processus de surveillance CE_DDU
    -- (signale chaque front montant pour faciliter le débogage)
    -- =========================================================================
    ce_ddu_monitor : process
    begin
        loop
            wait until rising_edge(clk);
            if ce_ddu = '1' then
                report "[INFO] CE_DDU = '1' detecte (changement de jour)";
            end if;
        end loop;
    end process;

end Behavioral;