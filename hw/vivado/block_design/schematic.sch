# File saved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 threadsafe
# 
# non-default properties - (restore without -noprops)
property -colorscheme classic
property attrcolor #000000
property attrfontsize 8
property autobundle 1
property backgroundcolor #ffffff
property boxcolor0 #000000
property boxcolor1 #000000
property boxcolor2 #000000
property boxinstcolor #000000
property boxpincolor #000000
property buscolor #008000
property closeenough 5
property createnetattrdsp 2048
property decorate 1
property elidetext 40
property fillcolor1 #ffffcc
property fillcolor2 #dfebf8
property fillcolor3 #f0f0f0
property gatecellname 2
property instattrmax 30
property instdrag 15
property instorder 1
property marksize 12
property maxfontsize 24
property maxzoom 10
property netcolor #19b400
property objecthighlight0 #ff00ff
property objecthighlight1 #ffff00
property objecthighlight2 #00ff00
property objecthighlight3 #0095ff
property objecthighlight4 #8000ff
property objecthighlight5 #ffc800
property objecthighlight7 #00ffff
property objecthighlight8 #ff00ff
property objecthighlight9 #ccccff
property objecthighlight10 #0ead00
property objecthighlight11 #cefc00
property objecthighlight12 #9e2dbe
property objecthighlight13 #ba6a29
property objecthighlight14 #fc0188
property objecthighlight15 #02f990
property objecthighlight16 #f1b0fb
property objecthighlight17 #fec004
property objecthighlight18 #149bff
property objecthighlight19 #0000ff
property overlaycolor #19b400
property pbuscolor #000000
property pbusnamecolor #000000
property pinattrmax 20
property pinorder 2
property pinpermute 0
property portcolor #000000
property portnamecolor #000000
property ripindexfontsize 4
property rippercolor #000000
property rubberbandcolor #000000
property rubberbandfontsize 24
property selectattr 0
property selectionappearance 2
property selectioncolor #0000ff
property sheetheight 44
property sheetwidth 68
property showmarks 1
property shownetname 0
property showpagenumbers 1
property showripindex 1
property timelimit 1
#
module new Top_Level_RTC work:Top_Level_RTC:NOFILE -nosplit
load symbol OBUF hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol IBUF hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol BUFG hdi_primitives BUF pin O output pin I input fillcolor 1
load symbol rtc_alarm work:rtc_alarm:NOFILE HIERBOX pin CE_1s input.left pin CLK100MHZ_IBUF_BUFG input.left pin RST_BTN_IBUF input.left pinBus LED_RGB_OBUF output.right [2:0] pinBus status_byte_sig input.left [0:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol baud_rate_gen work:baud_rate_gen:NOFILE HIERBOX pin CLK100MHZ_IBUF_BUFG input.left pin RST_BTN_IBUF input.left pin pc_baud_sel_sig input.left pin tick_x16 output.right boxcolor 1 fillcolor 2 minwidth 13%
load symbol clock_divider work:clock_divider:NOFILE HIERBOX pin CE_1ms output.right pin CE_1s output.right pin CE_1s_reg_0 output.right pin CLK100MHZ_IBUF_BUFG input.left pin RST_BTN_IBUF input.left pin blink_tog input.left boxcolor 1 fillcolor 2 minwidth 13%
load symbol rtc_date work:rtc_date:NOFILE HIERBOX pin BTN_UP_IBUF input.left pin CE_DDU input.left pin CLK100MHZ_IBUF_BUFG input.left pin Q[6]_i_13 input.left pin Q[6]_i_15 input.left pin Q[6]_i_8 input.left pin Q[6]_i_8_0 input.left pin Q[6]_i_9_0 input.left pin Q_reg[6]_i_14_0 input.left pin Q_reg[6]_i_14_1 input.left pin Q_reg[6]_i_23_0 input.left pin Q_reg[6]_i_37_0 input.left pin Q_reg[6]_i_40 input.left pin RST_BTN_IBUF input.left pin btn_pulse input.left pin btn_pulse_reg output.right pin counter_reg[0] output.right pin counter_reg[1] output.right pin day_reg[0]_0 output.right pin day_reg[0]_1 input.left pin day_reg[1]_0 output.right pin day_reg[1]_1 output.right pin day_reg[4]_1 output.right pin month_reg[0]_0 output.right pin month_reg[1]_0 output.right pin month_reg[1]_1 output.right pin month_reg[2]_0 output.right pin month_reg[2]_1 output.right pin month_reg[3]_0 output.right pin month_reg[3]_2 output.right pin month_reg[3]_3 output.right pin tx_buf_reg[5][5] input.left pin uart_set_date_en_sig input.left pin year_reg[0]_0 output.right pin year_reg[1]_0 output.right pin year_reg[3]_0 output.right pin year_reg[5]_0 output.right pin year_reg[5]_1 input.left pin year_reg[6]_1 output.right pin year_reg[6]_2 output.right pin year_reg[6]_3 input.left pinBus D output.right [0:0] pinBus E input.left [0:0] pinBus Q output.right [3:0] pinBus Q[6]_i_3 input.left [0:0] pinBus SW_IBUF input.left [0:0] pinBus counter input.left [1:0] pinBus day_reg[4]_0 output.right [4:0] pinBus day_reg[4]_2 input.left [4:0] pinBus ddt_sig output.right [1:0] pinBus ddu_sig output.right [1:0] pinBus disp_ad0 output.right [0:0] pinBus disp_ad3 output.right [1:0] pinBus disp_bd0 input.left [0:0] pinBus hht_sig input.left [0:0] pinBus hhu_sig input.left [1:0] pinBus mmt_sig input.left [2:0] pinBus mmu_sig input.left [0:0] pinBus month_reg[3]_1 output.right [1:0] pinBus month_reg[3]_4 input.left [0:0] pinBus month_reg[3]_5 input.left [3:0] pinBus mtu_sig output.right [0:0] pinBus sst_sig input.left [0:0] pinBus tx_buf_reg[9][3] input.left [1:0] pinBus tx_buf_reg[9][3]_0 input.left [1:0] pinBus tx_buf_reg[9][3]_1 input.left [1:0] pinBus year_reg[5]_2 input.left [2:0] pinBus year_reg[6]_0 output.right [6:0] pinBus year_reg[6]_4 input.left [3:0] pinBus yyt_sig output.right [2:0] pinBus yyu_sig output.right [1:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol debouncer_repeat work:debouncer_repeat:NOFILE HIERBOX pin CLK100MHZ_IBUF_BUFG input.left pin RST_BTN_IBUF input.left pin btn_in input.left pin btn_pulse output.right pin btn_pulse_reg_0 output.right pin sec_reg[5] input.left boxcolor 1 fillcolor 2 minwidth 13%
load symbol debouncer work:debouncer:NOFILE HIERBOX pin CLK100MHZ_IBUF_BUFG input.left pin RST_BTN_IBUF input.left pin btn_in input.left pin btn_pulse output.right pin btn_pulse_reg_0 output.right pin current_sel_reg[0] input.left pinBus SW_IBUF input.left [0:0] pinBus sel_state input.left [0:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol debouncer_0 work:debouncer_0:NOFILE HIERBOX pin CLK100MHZ_IBUF_BUFG input.left pin RST_BTN_IBUF input.left pin btn_in input.left pin btn_pulse output.right boxcolor 1 fillcolor 2 minwidth 13%
load symbol debouncer_repeat_1 work:debouncer_repeat_1:NOFILE HIERBOX pin BTN_UP_IBUF input.left pin CLK100MHZ_IBUF_BUFG input.left pin RST_BTN_IBUF input.left pin btn_pulse output.right pin btn_pulse_reg_0 output.right pin btn_pulse_reg_1 output.right pin year_reg[6] input.left pinBus SW_IBUF input.left [0:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol display work:display:NOFILE HIERBOX pin CE_1ms input.left pin CLK100MHZ_IBUF_BUFG input.left pin Q[6]_i_2 input.left pin Q[6]_i_5 input.left pin Q_reg[6] input.left pin Q_reg[6]_0 input.left pin Q_reg[6]_1 input.left pin Q_reg[6]_2 input.left pin Q_reg[6]_3 input.left pin Q_reg[6]_4 input.left pin Q_reg[6]_5 input.left pinBus AN_OBUF output.right [7:0] pinBus Q output.right [6:0] pinBus counter_reg[1] output.right [1:0] pinBus disp_ad0 input.left [1:0] pinBus disp_ad1 input.left [1:0] pinBus disp_ad3 input.left [0:0] pinBus disp_bd0 input.left [0:0] pinBus mmu_sig input.left [0:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol setting_fsm work:setting_fsm:NOFILE HIERBOX pin BTN_UP_IBUF input.left pin CE_1s input.left pin CLK100MHZ_IBUF_BUFG input.left pin Q[6]_i_2 input.left pin Q[6]_i_3 input.left pin Q[6]_i_4_0 input.left pin Q_reg[6]_i_23 input.left pin Q_reg[6]_i_35 input.left pin Q_reg[6]_i_37 input.left pin Q_reg[6]_i_37_0 input.left pin Q_reg[6]_i_39 input.left pin Q_reg[6]_i_68 input.left pin RST_BTN_IBUF input.left pin blink_tog input.left pin blink_tog_reg_0 output.right pin blink_tog_reg_1 output.right pin blink_tog_reg_2 output.right pin blink_tog_reg_3 output.right pin blink_tog_reg_4 output.right pin blink_tog_reg_5 output.right pin blink_tog_reg_6 output.right pin blink_tog_reg_7 output.right pin blink_tog_reg_8 output.right pin blink_tog_reg_9 output.right pin btn_pulse input.left pin btn_pulse_reg_0 output.right pin counter_reg[0] output.right pin counter_reg[0]_0 output.right pin counter_reg[0]_1 output.right pin counter_reg[0]_2 output.right pin current_sel_reg[0]_3 input.left pin current_sel_reg[2]_1 input.left pin hr_reg[4] input.left pin min_reg[5] input.left pin month_reg[3] input.left pin month_reg[3]_0 input.left pin sec_reg[5] input.left pin uart_set_date_en_sig input.left pin uart_set_en_sig input.left pin year_reg[6]_0 input.left pin year_reg[6]_1 input.left pinBus E output.right [0:0] pinBus Q input.left [0:0] pinBus Q[6]_i_10_0 input.left [0:0] pinBus Q[6]_i_24_0 input.left [0:0] pinBus Q[6]_i_24_1 input.left [0:0] pinBus Q[6]_i_29_0 input.left [0:0] pinBus Q[6]_i_29_1 input.left [0:0] pinBus Q[6]_i_4 input.left [0:0] pinBus SW_IBUF input.left [0:0] pinBus blink_tog_reg output.right [1:0] pinBus btn_pulse_reg output.right [0:0] pinBus current_sel_reg[0]_0 output.right [0:0] pinBus current_sel_reg[0]_1 output.right [0:0] pinBus current_sel_reg[0]_2 output.right [0:0] pinBus current_sel_reg[2]_0 output.right [0:0] pinBus day_reg[0] output.right [0:0] pinBus ddt_sig input.left [1:0] pinBus ddu_sig input.left [1:0] pinBus disp_bd0 output.right [0:0] pinBus hht_sig input.left [0:0] pinBus hhu_sig input.left [1:0] pinBus mmt_sig input.left [2:0] pinBus mtu_sig input.left [0:0] pinBus sst_sig input.left [2:0] pinBus ssu_sig input.left [2:0] pinBus year_reg[6] output.right [0:0] pinBus yyt_sig input.left [2:0] pinBus yyu_sig input.left [1:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol protocol_decoder work:protocol_decoder:NOFILE HIERBOX pin CE_1ms input.left pin CE_1ms_reg output.right pin CE_1ms_reg_0 output.right pin CE_1ms_reg_1 output.right pin CLK100MHZ_IBUF_BUFG input.left pin FSM_sequential_state_reg[0]_0 input.left pin FSM_sequential_state_reg[1]_0 input.left pin FSM_sequential_state_reg[2]_0 input.left pin LED15_OBUF input.left pin LED17_G_OBUF input.left pin RST_BTN_IBUF input.left pin SW[11] output.right pin SW[11]_0 output.right pin SW[12] output.right pin SW[4] output.right pin SW[4]_0 output.right pin SW[4]_1 output.right pin SW[5] output.right pin alarm_en_state_reg input.left pin blink_cnt_reg[2] input.left pin blink_cnt_reg[2]_0 input.left pin blink_cnt_reg[2]_1 input.left pin btn_pulse input.left pin cmd_reg_reg[1]_0 output.right pin cmd_reg_reg[2]_0 output.right pin hr_reg[3] input.left pin min_reg[2] input.left pin month_reg[2] input.left pin month_reg[3] input.left pin out_al_en_val_reg_0 output.right pin payload_buf_reg[4][0]_0 input.left pin payload_cnt_reg[0]_0 input.left pin pc_al_min_reg[1] output.right pin pc_al_min_reg[1]_0 output.right pin pc_al_sec_reg[1] output.right pin pc_al_sec_reg[1]_0 output.right pin pc_al_sec_reg[1]_1 output.right pin pc_baud_sel_sig output.right pin prev_alarm_ringing output.right pin rx_done input.left pin rx_valid_pulse_reg_0 output.right pin sec_reg[2] input.left pin tx_buf_reg[5][6]_0 input.left pin tx_buf_reg[6][0]_0 input.left pin tx_buf_reg[6][0]_1 input.left pin tx_buf_reg[6][1]_0 input.left pin tx_buf_reg[6][1]_1 input.left pin tx_buf_reg[6][2]_0 input.left pin tx_buf_reg[6][2]_1 input.left pin tx_buf_reg[6][3]_0 input.left pin tx_buf_reg[6][3]_1 input.left pin tx_buf_reg[6][4]_0 input.left pin tx_busy_sig input.left pin tx_len_reg[0]_0 input.left pin tx_start_sig output.right pin uart_set_date_en_sig output.right pin uart_set_en_sig output.right pin year_reg[5] input.left pinBus D output.right [1:0] pinBus E output.right [0:0] pinBus Q output.right [1:0] pinBus SW_IBUF input.left [15:0] pinBus al_hht output.right [1:0] pinBus al_mmt output.right [1:0] pinBus al_mmu output.right [3:0] pinBus al_sst output.right [1:0] pinBus al_ssu output.right [0:0] pinBus ms_cnt_reg[7] output.right [7:0] pinBus ms_cnt_reg[7]_0 input.left [7:0] pinBus out_al_hr_reg[4]_0 output.right [4:0] pinBus out_al_min_reg[5]_0 output.right [5:0] pinBus out_al_sec_reg[5]_0 output.right [5:0] pinBus out_day_reg[4]_0 output.right [4:0] pinBus out_hr_reg[3]_0 output.right [2:0] pinBus out_hr_reg[4]_0 output.right [1:0] pinBus out_min_reg[2]_0 output.right [2:0] pinBus out_min_reg[5]_0 output.right [2:0] pinBus out_sec_reg[5]_0 output.right [3:0] pinBus out_year_reg[5]_0 output.right [2:0] pinBus out_year_reg[6]_0 output.right [3:0] pinBus payload_buf_reg[3][7]_0 input.left [7:0] pinBus rx_valid_pulse_reg_1 output.right [0:0] pinBus set_date_en_reg_0 output.right [3:0] pinBus status_byte_sig input.left [0:0] pinBus tx_buf_reg[3][4]_0 input.left [4:0] pinBus tx_buf_reg[3][5]_0 input.left [5:0] pinBus tx_buf_reg[4][5]_0 input.left [5:0] pinBus tx_buf_reg[4][5]_1 input.left [5:0] pinBus tx_buf_reg[5][4]_0 input.left [4:0] pinBus tx_buf_reg[5][4]_1 input.left [4:0] pinBus tx_buf_reg[5][5]_0 input.left [0:0] pinBus tx_buf_reg[6][5]_0 input.left [5:0] pinBus tx_buf_reg[7][3]_0 input.left [3:0] pinBus tx_buf_reg[8][6]_0 input.left [6:0] pinBus tx_buf_reg[9][5]_0 input.left [5:0] pinBus tx_data_reg[6]_0 output.right [6:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol rtc_time work:rtc_time:NOFILE HIERBOX pin BTN_UP_IBUF input.left pin CE_1s input.left pin CE_1s_reg output.right pin CE_DDU output.right pin CE_DDU_reg_0 output.right pin CLK100MHZ_IBUF_BUFG input.left pin Q[6]_i_13_0 input.left pin Q[6]_i_13_1 input.left pin Q_reg[6]_i_35_0 input.left pin Q_reg[6]_i_40 input.left pin RST_BTN_IBUF input.left pin btn_pulse input.left pin counter_reg[1] output.right pin hr_reg[0]_0 output.right pin hr_reg[1]_0 output.right pin hr_reg[1]_1 output.right pin hr_reg[2]_0 output.right pin hr_reg[3]_0 output.right pin hr_reg[4]_0 output.right pin hr_reg[4]_1 output.right pin hr_reg[4]_2 output.right pin min_reg[2]_0 output.right pin prev_alarm_ringing input.left pin prev_alarm_ringing_i_2_0 input.left pin prev_alarm_ringing_i_2_1 input.left pin prev_alarm_ringing_i_2_2 input.left pin prev_alarm_ringing_i_2_3 input.left pin prev_alarm_ringing_i_2_4 input.left pin prev_alarm_ringing_i_2_5 input.left pin prev_alarm_ringing_i_5_1 input.left pin prev_alarm_ringing_i_7_1 input.left pin prev_alarm_ringing_reg output.right pin sec_reg[2]_0 output.right pin sec_reg[4]_0 input.left pin sec_reg[5]_1 output.right pin tx_buf_reg[6][4] input.left pin tx_len[3]_i_9_0 input.left pin tx_len[3]_i_9_1 input.left pin tx_len[3]_i_9_2 input.left pin tx_len[3]_i_9_3 input.left pin uart_set_en_sig input.left pin year_reg[6] input.left pinBus D input.left [2:0] pinBus E input.left [0:0] pinBus Q output.right [4:0] pinBus Q[6]_i_4 input.left [1:0] pinBus Q[6]_i_4_0 input.left [0:0] pinBus SW[14] output.right [0:0] pinBus SW_IBUF input.left [1:0] pinBus al_hht input.left [1:0] pinBus al_mmt input.left [1:0] pinBus al_mmu input.left [3:0] pinBus al_sst input.left [1:0] pinBus al_ssu input.left [0:0] pinBus disp_ad3 input.left [0:0] pinBus hht_sig output.right [0:0] pinBus hhu_sig output.right [1:0] pinBus hr_reg[4]_3 input.left [1:0] pinBus hr_reg[4]_4 input.left [0:0] pinBus min_reg[2]_1 input.left [2:0] pinBus min_reg[3]_0 output.right [1:0] pinBus min_reg[5]_0 output.right [5:0] pinBus min_reg[5]_1 input.left [2:0] pinBus min_reg[5]_2 input.left [0:0] pinBus mmt_sig output.right [2:0] pinBus prev_alarm_ringing_i_5_0 input.left [2:0] pinBus prev_alarm_ringing_i_6_0 input.left [4:0] pinBus prev_alarm_ringing_i_7_0 input.left [2:0] pinBus sec_reg[2]_1 input.left [1:0] pinBus sec_reg[5]_0 output.right [5:0] pinBus sec_reg[5]_2 input.left [3:0] pinBus sst_sig output.right [2:0] pinBus ssu_sig output.right [2:0] pinBus status_byte_sig output.right [0:0] pinBus tx_buf_reg[9][2] input.left [1:0] pinBus tx_buf_reg[9][4] input.left [2:0] pinBus tx_buf_reg[9][5] input.left [3:0] pinBus year_reg[5] output.right [3:0] pinBus yyt_sig input.left [0:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol rx_uart work:rx_uart:NOFILE HIERBOX pin CLK100MHZ_IBUF_BUFG input.left pin FSM_sequential_state_reg[1]_0 output.right pin RST_BTN_IBUF input.left pin dout_reg[2]_0 output.right pin dout_reg[6]_0 output.right pin rx_clean input.left pin rx_done output.right pin rx_done_reg_0 output.right pin rx_done_reg_1 output.right pin tick_x16 input.left pinBus Q input.left [1:0] pinBus dout output.right [7:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol synchronizer work:synchronizer:NOFILE HIERBOX pin CLK100MHZ_IBUF_BUFG input.left pin RST_BTN_IBUF input.left pin UART_RXD_IBUF input.left pin rx_clean output.right boxcolor 1 fillcolor 2 minwidth 13%
load symbol tx_uart work:tx_uart:NOFILE HIERBOX pin CLK100MHZ_IBUF_BUFG input.left pin RST_BTN_IBUF input.left pin tick_x16 input.left pin tx output.right pin tx_busy_sig output.right pin tx_start_sig input.left pinBus din input.left [6:0] boxcolor 1 fillcolor 2 minwidth 13%
load symbol FDCE hdi_primitives GEN pin Q output.right pin C input.clk.left pin CE input.left pin CLR input.left pin D input.left fillcolor 1
load symbol FDRE hdi_primitives GEN pin Q output.right pin C input.clk.left pin CE input.left pin D input.left pin R input.left fillcolor 1
load port BTN_DN input -pg 1 -lvl 0 -x 0 -y 4660
load port BTN_L input -pg 1 -lvl 0 -x 0 -y 5390
load port BTN_R input -pg 1 -lvl 0 -x 0 -y 5360
load port BTN_UP input -pg 1 -lvl 0 -x 0 -y 5500
load port CLK100MHZ input -pg 1 -lvl 0 -x 0 -y 5430
load port LED15 output -pg 1 -lvl 11 -x 9300 -y 4930
load port LED17_G output -pg 1 -lvl 11 -x 9300 -y 2610
load port RST_BTN input -pg 1 -lvl 0 -x 0 -y 5570
load port UART_RXD input -pg 1 -lvl 0 -x 0 -y 6130
load port UART_TXD output -pg 1 -lvl 11 -x 9300 -y 6260
load portBus AN output [7:0] -attr @name AN[7:0] -pg 1 -lvl 11 -x 9300 -y 5000
load portBus LED_RGB output [2:0] -attr @name LED_RGB[2:0] -pg 1 -lvl 11 -x 9300 -y 5560
load portBus SEG output [6:0] -attr @name SEG[6:0] -pg 1 -lvl 11 -x 9300 -y 5770
load portBus SW input [15:0] -attr @name SW[15:0] -pg 1 -lvl 0 -x 0 -y 6160
load inst AN_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5000
load inst AN_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5070
load inst AN_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5140
load inst AN_OBUF[3]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5210
load inst AN_OBUF[4]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5280
load inst AN_OBUF[5]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5350
load inst AN_OBUF[6]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5420
load inst AN_OBUF[7]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5490
load inst BTN_DN_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 750 -y 4660
load inst BTN_L_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 4 -x 1360 -y 5500
load inst BTN_R_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 3 -x 750 -y 5360
load inst BTN_UP_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 5500
load inst CLK100MHZ_IBUF_BUFG_inst BUFG hdi_primitives -attr @cell(#000000) BUFG -pg 1 -lvl 2 -x 260 -y 5430
load inst CLK100MHZ_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 1 -x 40 -y 5430
load inst LED15_OBUF_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 4930
load inst LED17_G_OBUF_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 2610
load inst LED_RGB_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5560
load inst LED_RGB_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5630
load inst LED_RGB_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5700
load inst RST_BTN_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 5570
load inst SEG_OBUF[0]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5770
load inst SEG_OBUF[1]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5840
load inst SEG_OBUF[2]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5910
load inst SEG_OBUF[3]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 5980
load inst SEG_OBUF[4]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 6050
load inst SEG_OBUF[5]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 6120
load inst SEG_OBUF[6]_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 6190
load inst SW_IBUF[0]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 5640
load inst SW_IBUF[10]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 6410
load inst SW_IBUF[11]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 6480
load inst SW_IBUF[12]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 6550
load inst SW_IBUF[13]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 6620
load inst SW_IBUF[14]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 6690
load inst SW_IBUF[15]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 6760
load inst SW_IBUF[1]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 5710
load inst SW_IBUF[2]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 5780
load inst SW_IBUF[3]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 5850
load inst SW_IBUF[4]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 5920
load inst SW_IBUF[5]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 5990
load inst SW_IBUF[6]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 6060
load inst SW_IBUF[7]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 6200
load inst SW_IBUF[8]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 6270
load inst SW_IBUF[9]_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 6340
load inst UART_RXD_IBUF_inst IBUF hdi_primitives -attr @cell(#000000) IBUF -pg 1 -lvl 2 -x 260 -y 6130
load inst UART_TXD_OBUF_inst OBUF hdi_primitives -attr @cell(#000000) OBUF -pg 1 -lvl 10 -x 9100 -y 6260
load inst U_ALARM rtc_alarm work:rtc_alarm:NOFILE -autohide -attr @cell(#000000) rtc_alarm -pinBusAttr LED_RGB_OBUF @name LED_RGB_OBUF[2:0] -pinBusAttr status_byte_sig @name status_byte_sig -pg 1 -lvl 9 -x 8820 -y 5760
load inst U_BAUD baud_rate_gen work:baud_rate_gen:NOFILE -autohide -attr @cell(#000000) baud_rate_gen -pg 1 -lvl 3 -x 750 -y 5450
load inst U_CLOCK clock_divider work:clock_divider:NOFILE -autohide -attr @cell(#000000) clock_divider -pg 1 -lvl 4 -x 1360 -y 5190
load inst U_DATE rtc_date work:rtc_date:NOFILE -autohide -attr @cell(#000000) rtc_date -pinBusAttr D @name D -pinBusAttr E @name E -pinBusAttr Q @name Q[3:0] -pinBusAttr Q[6]_i_3 @name Q[6]_i_3 -pinBusAttr SW_IBUF @name SW_IBUF -pinBusAttr counter @name counter[1:0] -pinBusAttr day_reg[4]_0 @name day_reg[4]_0[4:0] -pinBusAttr day_reg[4]_2 @name day_reg[4]_2[4:0] -pinBusAttr ddt_sig @name ddt_sig[1:0] -pinBusAttr ddu_sig @name ddu_sig[1:0] -pinBusAttr disp_ad0 @name disp_ad0 -pinBusAttr disp_ad3 @name disp_ad3[1:0] -pinBusAttr disp_bd0 @name disp_bd0 -pinBusAttr hht_sig @name hht_sig -pinBusAttr hhu_sig @name hhu_sig[1:0] -pinBusAttr mmt_sig @name mmt_sig[2:0] -pinBusAttr mmu_sig @name mmu_sig -pinBusAttr month_reg[3]_1 @name month_reg[3]_1[1:0] -pinBusAttr month_reg[3]_4 @name month_reg[3]_4 -pinBusAttr month_reg[3]_5 @name month_reg[3]_5[3:0] -pinBusAttr mtu_sig @name mtu_sig -pinBusAttr sst_sig @name sst_sig -pinBusAttr tx_buf_reg[9][3] @name tx_buf_reg[9][3][1:0] -pinBusAttr tx_buf_reg[9][3]_0 @name tx_buf_reg[9][3]_0[1:0] -pinBusAttr tx_buf_reg[9][3]_1 @name tx_buf_reg[9][3]_1[1:0] -pinBusAttr year_reg[5]_2 @name year_reg[5]_2[2:0] -pinBusAttr year_reg[6]_0 @name year_reg[6]_0[6:0] -pinBusAttr year_reg[6]_4 @name year_reg[6]_4[3:0] -pinBusAttr yyt_sig @name yyt_sig[2:0] -pinBusAttr yyu_sig @name yyu_sig[1:0] -pg 1 -lvl 8 -x 7880 -y 4140
load inst U_DEB_DN debouncer_repeat work:debouncer_repeat:NOFILE -autohide -attr @cell(#000000) debouncer_repeat -pg 1 -lvl 4 -x 1360 -y 4610
load inst U_DEB_L debouncer work:debouncer:NOFILE -autohide -attr @cell(#000000) debouncer -pinBusAttr SW_IBUF @name SW_IBUF -pinBusAttr sel_state @name sel_state -pg 1 -lvl 5 -x 2660 -y 5350
load inst U_DEB_R debouncer_0 work:debouncer_0:NOFILE -autohide -attr @cell(#000000) debouncer_0 -pg 1 -lvl 4 -x 1360 -y 5370
load inst U_DEB_UP debouncer_repeat_1 work:debouncer_repeat_1:NOFILE -autohide -attr @cell(#000000) debouncer_repeat_1 -pinBusAttr SW_IBUF @name SW_IBUF -pg 1 -lvl 3 -x 750 -y 5740
load inst U_DISPLAY display work:display:NOFILE -autohide -attr @cell(#000000) display -pinBusAttr AN_OBUF @name AN_OBUF[7:0] -pinBusAttr Q @name Q[6:0] -pinBusAttr counter_reg[1] @name counter_reg[1][1:0] -pinBusAttr disp_ad0 @name disp_ad0[1:0] -pinBusAttr disp_ad1 @name disp_ad1[1:0] -pinBusAttr disp_ad3 @name disp_ad3 -pinBusAttr disp_bd0 @name disp_bd0 -pinBusAttr mmu_sig @name mmu_sig -pg 1 -lvl 9 -x 8820 -y 5360
load inst U_FSM_SET setting_fsm work:setting_fsm:NOFILE -autohide -attr @cell(#000000) setting_fsm -pinBusAttr E @name E -pinBusAttr Q @name Q -pinBusAttr Q[6]_i_10_0 @name Q[6]_i_10_0 -pinBusAttr Q[6]_i_24_0 @name Q[6]_i_24_0 -pinBusAttr Q[6]_i_24_1 @name Q[6]_i_24_1 -pinBusAttr Q[6]_i_29_0 @name Q[6]_i_29_0 -pinBusAttr Q[6]_i_29_1 @name Q[6]_i_29_1 -pinBusAttr Q[6]_i_4 @name Q[6]_i_4 -pinBusAttr SW_IBUF @name SW_IBUF -pinBusAttr blink_tog_reg @name blink_tog_reg[1:0] -pinBusAttr btn_pulse_reg @name btn_pulse_reg -pinBusAttr current_sel_reg[0]_0 @name current_sel_reg[0]_0 -pinBusAttr current_sel_reg[0]_1 @name current_sel_reg[0]_1 -pinBusAttr current_sel_reg[0]_2 @name current_sel_reg[0]_2 -pinBusAttr current_sel_reg[2]_0 @name current_sel_reg[2]_0 -pinBusAttr day_reg[0] @name day_reg[0] -pinBusAttr ddt_sig @name ddt_sig[1:0] -pinBusAttr ddu_sig @name ddu_sig[1:0] -pinBusAttr disp_bd0 @name disp_bd0 -pinBusAttr hht_sig @name hht_sig -pinBusAttr hhu_sig @name hhu_sig[1:0] -pinBusAttr mmt_sig @name mmt_sig[2:0] -pinBusAttr mtu_sig @name mtu_sig -pinBusAttr sst_sig @name sst_sig[2:0] -pinBusAttr ssu_sig @name ssu_sig[2:0] -pinBusAttr year_reg[6] @name year_reg[6] -pinBusAttr yyt_sig @name yyt_sig[2:0] -pinBusAttr yyu_sig @name yyu_sig[1:0] -pg 1 -lvl 6 -x 4500 -y 3780
load inst U_PROTOCOL protocol_decoder work:protocol_decoder:NOFILE -autohide -attr @cell(#000000) protocol_decoder -pinBusAttr D @name D[1:0] -pinBusAttr E @name E -pinBusAttr Q @name Q[1:0] -pinBusAttr SW_IBUF @name SW_IBUF[15:0] -pinBusAttr al_hht @name al_hht[1:0] -pinBusAttr al_mmt @name al_mmt[1:0] -pinBusAttr al_mmu @name al_mmu[3:0] -pinBusAttr al_sst @name al_sst[1:0] -pinBusAttr al_ssu @name al_ssu -pinBusAttr ms_cnt_reg[7] @name ms_cnt_reg[7][7:0] -pinBusAttr ms_cnt_reg[7]_0 @name ms_cnt_reg[7]_0[7:0] -pinBusAttr out_al_hr_reg[4]_0 @name out_al_hr_reg[4]_0[4:0] -pinBusAttr out_al_min_reg[5]_0 @name out_al_min_reg[5]_0[5:0] -pinBusAttr out_al_sec_reg[5]_0 @name out_al_sec_reg[5]_0[5:0] -pinBusAttr out_day_reg[4]_0 @name out_day_reg[4]_0[4:0] -pinBusAttr out_hr_reg[3]_0 @name out_hr_reg[3]_0[2:0] -pinBusAttr out_hr_reg[4]_0 @name out_hr_reg[4]_0[1:0] -pinBusAttr out_min_reg[2]_0 @name out_min_reg[2]_0[2:0] -pinBusAttr out_min_reg[5]_0 @name out_min_reg[5]_0[2:0] -pinBusAttr out_sec_reg[5]_0 @name out_sec_reg[5]_0[3:0] -pinBusAttr out_year_reg[5]_0 @name out_year_reg[5]_0[2:0] -pinBusAttr out_year_reg[6]_0 @name out_year_reg[6]_0[3:0] -pinBusAttr payload_buf_reg[3][7]_0 @name payload_buf_reg[3][7]_0[7:0] -pinBusAttr rx_valid_pulse_reg_1 @name rx_valid_pulse_reg_1 -pinBusAttr set_date_en_reg_0 @name set_date_en_reg_0[3:0] -pinBusAttr status_byte_sig @name status_byte_sig -pinBusAttr tx_buf_reg[3][4]_0 @name tx_buf_reg[3][4]_0[4:0] -pinBusAttr tx_buf_reg[3][5]_0 @name tx_buf_reg[3][5]_0[5:0] -pinBusAttr tx_buf_reg[4][5]_0 @name tx_buf_reg[4][5]_0[5:0] -pinBusAttr tx_buf_reg[4][5]_1 @name tx_buf_reg[4][5]_1[5:0] -pinBusAttr tx_buf_reg[5][4]_0 @name tx_buf_reg[5][4]_0[4:0] -pinBusAttr tx_buf_reg[5][4]_1 @name tx_buf_reg[5][4]_1[4:0] -pinBusAttr tx_buf_reg[5][5]_0 @name tx_buf_reg[5][5]_0 -pinBusAttr tx_buf_reg[6][5]_0 @name tx_buf_reg[6][5]_0[5:0] -pinBusAttr tx_buf_reg[7][3]_0 @name tx_buf_reg[7][3]_0[3:0] -pinBusAttr tx_buf_reg[8][6]_0 @name tx_buf_reg[8][6]_0[6:0] -pinBusAttr tx_buf_reg[9][5]_0 @name tx_buf_reg[9][5]_0[5:0] -pinBusAttr tx_data_reg[6]_0 @name tx_data_reg[6]_0[6:0] -pg 1 -lvl 5 -x 2660 -y 2840
load inst U_RTC rtc_time work:rtc_time:NOFILE -autohide -attr @cell(#000000) rtc_time -pinBusAttr D @name D[2:0] -pinBusAttr E @name E -pinBusAttr Q @name Q[4:0] -pinBusAttr Q[6]_i_4 @name Q[6]_i_4[1:0] -pinBusAttr Q[6]_i_4_0 @name Q[6]_i_4_0 -pinBusAttr SW[14] @name SW[14] -pinBusAttr SW_IBUF @name SW_IBUF[1:0] -pinBusAttr al_hht @name al_hht[1:0] -pinBusAttr al_mmt @name al_mmt[1:0] -pinBusAttr al_mmu @name al_mmu[3:0] -pinBusAttr al_sst @name al_sst[1:0] -pinBusAttr al_ssu @name al_ssu -pinBusAttr disp_ad3 @name disp_ad3 -pinBusAttr hht_sig @name hht_sig -pinBusAttr hhu_sig @name hhu_sig[1:0] -pinBusAttr hr_reg[4]_3 @name hr_reg[4]_3[1:0] -pinBusAttr hr_reg[4]_4 @name hr_reg[4]_4 -pinBusAttr min_reg[2]_1 @name min_reg[2]_1[2:0] -pinBusAttr min_reg[3]_0 @name min_reg[3]_0[1:0] -pinBusAttr min_reg[5]_0 @name min_reg[5]_0[5:0] -pinBusAttr min_reg[5]_1 @name min_reg[5]_1[2:0] -pinBusAttr min_reg[5]_2 @name min_reg[5]_2 -pinBusAttr mmt_sig @name mmt_sig[2:0] -pinBusAttr prev_alarm_ringing_i_5_0 @name prev_alarm_ringing_i_5_0[2:0] -pinBusAttr prev_alarm_ringing_i_6_0 @name prev_alarm_ringing_i_6_0[4:0] -pinBusAttr prev_alarm_ringing_i_7_0 @name prev_alarm_ringing_i_7_0[2:0] -pinBusAttr sec_reg[2]_1 @name sec_reg[2]_1[1:0] -pinBusAttr sec_reg[5]_0 @name sec_reg[5]_0[5:0] -pinBusAttr sec_reg[5]_2 @name sec_reg[5]_2[3:0] -pinBusAttr sst_sig @name sst_sig[2:0] -pinBusAttr ssu_sig @name ssu_sig[2:0] -pinBusAttr status_byte_sig @name status_byte_sig -pinBusAttr tx_buf_reg[9][2] @name tx_buf_reg[9][2][1:0] -pinBusAttr tx_buf_reg[9][4] @name tx_buf_reg[9][4][2:0] -pinBusAttr tx_buf_reg[9][5] @name tx_buf_reg[9][5][3:0] -pinBusAttr year_reg[5] @name year_reg[5][3:0] -pinBusAttr yyt_sig @name yyt_sig -pg 1 -lvl 7 -x 6450 -y 3040
load inst U_RX rx_uart work:rx_uart:NOFILE -autohide -attr @cell(#000000) rx_uart -pinBusAttr Q @name Q[1:0] -pinBusAttr dout @name dout[7:0] -pg 1 -lvl 4 -x 1360 -y 3700
load inst U_SYNC synchronizer work:synchronizer:NOFILE -autohide -attr @cell(#000000) synchronizer -pg 1 -lvl 3 -x 750 -y 5610
load inst U_TX tx_uart work:tx_uart:NOFILE -autohide -attr @cell(#000000) tx_uart -pinBusAttr din @name din[6:0] -pg 1 -lvl 4 -x 1360 -y 5580
load inst alarm_en_state_reg FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 3420
load inst blink_cnt_reg[0] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 3570
load inst blink_cnt_reg[1] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 3990
load inst blink_cnt_reg[2] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 4190
load inst blink_tog_reg FDRE hdi_primitives -attr @cell(#000000) FDRE -pg 1 -lvl 3 -x 750 -y 5180
load inst led15_reg_reg FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 4820
load inst ms_cnt_reg[0] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 80
load inst ms_cnt_reg[1] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 230
load inst ms_cnt_reg[2] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 380
load inst ms_cnt_reg[3] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 530
load inst ms_cnt_reg[4] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 680
load inst ms_cnt_reg[5] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 830
load inst ms_cnt_reg[6] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 980
load inst ms_cnt_reg[7] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 1140
load inst pc_al_hr_reg[0] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 1300
load inst pc_al_hr_reg[1] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 1450
load inst pc_al_hr_reg[2] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 1600
load inst pc_al_hr_reg[3] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 1750
load inst pc_al_hr_reg[4] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 1900
load inst pc_al_min_reg[0] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 2060
load inst pc_al_min_reg[1] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 2210
load inst pc_al_min_reg[2] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 2360
load inst pc_al_min_reg[3] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 2510
load inst pc_al_min_reg[4] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 2660
load inst pc_al_min_reg[5] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 2810
load inst pc_al_sec_reg[0] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 2960
load inst pc_al_sec_reg[1] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 3110
load inst pc_al_sec_reg[2] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 3260
load inst pc_al_sec_reg[3] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 4340
load inst pc_al_sec_reg[4] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 4490
load inst pc_al_sec_reg[5] FDCE hdi_primitives -attr @cell(#000000) FDCE -pg 1 -lvl 4 -x 1360 -y 5020
load net <const0> -ground -pin blink_tog_reg R
load net <const1> -power -pin alarm_en_state_reg CE -pin blink_cnt_reg[0] CE -pin blink_cnt_reg[1] CE -pin blink_cnt_reg[2] CE -pin blink_tog_reg CE -pin led15_reg_reg CE
load net AN[0] -attr @rip(#000000) 0 -port AN[0] -pin AN_OBUF[0]_inst O
load net AN[1] -attr @rip(#000000) 1 -port AN[1] -pin AN_OBUF[1]_inst O
load net AN[2] -attr @rip(#000000) 2 -port AN[2] -pin AN_OBUF[2]_inst O
load net AN[3] -attr @rip(#000000) 3 -port AN[3] -pin AN_OBUF[3]_inst O
load net AN[4] -attr @rip(#000000) 4 -port AN[4] -pin AN_OBUF[4]_inst O
load net AN[5] -attr @rip(#000000) 5 -port AN[5] -pin AN_OBUF[5]_inst O
load net AN[6] -attr @rip(#000000) 6 -port AN[6] -pin AN_OBUF[6]_inst O
load net AN[7] -attr @rip(#000000) 7 -port AN[7] -pin AN_OBUF[7]_inst O
load net AN_OBUF[0] -attr @rip(#000000) AN_OBUF[0] -pin AN_OBUF[0]_inst I -pin U_DISPLAY AN_OBUF[0]
load net AN_OBUF[1] -attr @rip(#000000) AN_OBUF[1] -pin AN_OBUF[1]_inst I -pin U_DISPLAY AN_OBUF[1]
load net AN_OBUF[2] -attr @rip(#000000) AN_OBUF[2] -pin AN_OBUF[2]_inst I -pin U_DISPLAY AN_OBUF[2]
load net AN_OBUF[3] -attr @rip(#000000) AN_OBUF[3] -pin AN_OBUF[3]_inst I -pin U_DISPLAY AN_OBUF[3]
load net AN_OBUF[4] -attr @rip(#000000) AN_OBUF[4] -pin AN_OBUF[4]_inst I -pin U_DISPLAY AN_OBUF[4]
load net AN_OBUF[5] -attr @rip(#000000) AN_OBUF[5] -pin AN_OBUF[5]_inst I -pin U_DISPLAY AN_OBUF[5]
load net AN_OBUF[6] -attr @rip(#000000) AN_OBUF[6] -pin AN_OBUF[6]_inst I -pin U_DISPLAY AN_OBUF[6]
load net AN_OBUF[7] -attr @rip(#000000) AN_OBUF[7] -pin AN_OBUF[7]_inst I -pin U_DISPLAY AN_OBUF[7]
load net BTN_DN -port BTN_DN -pin BTN_DN_IBUF_inst I
netloc BTN_DN 1 0 3 NJ 4660 NJ 4660 NJ
load net BTN_DN_IBUF -pin BTN_DN_IBUF_inst O -pin U_DEB_DN btn_in
netloc BTN_DN_IBUF 1 3 1 NJ 4660
load net BTN_L -port BTN_L -pin BTN_L_IBUF_inst I
netloc BTN_L 1 0 4 NJ 5390 NJ 5390 520J 5540 1170J
load net BTN_L_IBUF -pin BTN_L_IBUF_inst O -pin U_DEB_L btn_in
netloc BTN_L_IBUF 1 4 1 2360J 5420n
load net BTN_R -port BTN_R -pin BTN_R_IBUF_inst I
netloc BTN_R 1 0 3 NJ 5360 NJ 5360 NJ
load net BTN_R_IBUF -pin BTN_R_IBUF_inst O -pin U_DEB_R btn_in
netloc BTN_R_IBUF 1 3 1 1010J 5360n
load net BTN_UP -port BTN_UP -pin BTN_UP_IBUF_inst I
netloc BTN_UP 1 0 2 NJ 5500 NJ
load net BTN_UP_IBUF -pin BTN_UP_IBUF_inst O -pin U_DATE BTN_UP_IBUF -pin U_DEB_UP BTN_UP_IBUF -pin U_FSM_SET BTN_UP_IBUF -pin U_RTC BTN_UP_IBUF
netloc BTN_UP_IBUF 1 2 6 560 5320 NJ 5320 2440J 5240 3610 4970 5380 4170 7090J
load net CLK100MHZ -port CLK100MHZ -pin CLK100MHZ_IBUF_inst I
netloc CLK100MHZ 1 0 1 NJ 5430
load net CLK100MHZ_IBUF -pin CLK100MHZ_IBUF_BUFG_inst I -pin CLK100MHZ_IBUF_inst O
netloc CLK100MHZ_IBUF 1 1 1 NJ 5430
load net CLK100MHZ_IBUF_BUFG -pin CLK100MHZ_IBUF_BUFG_inst O -pin U_ALARM CLK100MHZ_IBUF_BUFG -pin U_BAUD CLK100MHZ_IBUF_BUFG -pin U_CLOCK CLK100MHZ_IBUF_BUFG -pin U_DATE CLK100MHZ_IBUF_BUFG -pin U_DEB_DN CLK100MHZ_IBUF_BUFG -pin U_DEB_L CLK100MHZ_IBUF_BUFG -pin U_DEB_R CLK100MHZ_IBUF_BUFG -pin U_DEB_UP CLK100MHZ_IBUF_BUFG -pin U_DISPLAY CLK100MHZ_IBUF_BUFG -pin U_FSM_SET CLK100MHZ_IBUF_BUFG -pin U_PROTOCOL CLK100MHZ_IBUF_BUFG -pin U_RTC CLK100MHZ_IBUF_BUFG -pin U_RX CLK100MHZ_IBUF_BUFG -pin U_SYNC CLK100MHZ_IBUF_BUFG -pin U_TX CLK100MHZ_IBUF_BUFG -pin alarm_en_state_reg C -pin blink_cnt_reg[0] C -pin blink_cnt_reg[1] C -pin blink_cnt_reg[2] C -pin blink_tog_reg C -pin led15_reg_reg C -pin ms_cnt_reg[0] C -pin ms_cnt_reg[1] C -pin ms_cnt_reg[2] C -pin ms_cnt_reg[3] C -pin ms_cnt_reg[4] C -pin ms_cnt_reg[5] C -pin ms_cnt_reg[6] C -pin ms_cnt_reg[7] C -pin pc_al_hr_reg[0] C -pin pc_al_hr_reg[1] C -pin pc_al_hr_reg[2] C -pin pc_al_hr_reg[3] C -pin pc_al_hr_reg[4] C -pin pc_al_min_reg[0] C -pin pc_al_min_reg[1] C -pin pc_al_min_reg[2] C -pin pc_al_min_reg[3] C -pin pc_al_min_reg[4] C -pin pc_al_min_reg[5] C -pin pc_al_sec_reg[0] C -pin pc_al_sec_reg[1] C -pin pc_al_sec_reg[2] C -pin pc_al_sec_reg[3] C -pin pc_al_sec_reg[4] C -pin pc_al_sec_reg[5] C
netloc CLK100MHZ_IBUF_BUFG 1 2 7 500 5280 970 4090 1920 4070 4030 4830 5300 4190 7650 5470 8530
load net LED15 -port LED15 -pin LED15_OBUF_inst O
netloc LED15 1 10 1 NJ 4930
load net LED15_OBUF -pin LED15_OBUF_inst I -pin U_PROTOCOL LED15_OBUF -pin led15_reg_reg Q
netloc LED15_OBUF 1 4 6 2020 4880 3190J 5550 5540J 5510 7550J 5450 8450J 5150 9020J
load net LED17_G -port LED17_G -pin LED17_G_OBUF_inst O
netloc LED17_G 1 10 1 NJ 2610
load net LED17_G_OBUF -pin LED17_G_OBUF_inst I -pin U_PROTOCOL LED17_G_OBUF -pin alarm_en_state_reg Q
netloc LED17_G_OBUF 1 4 6 1640 2610 NJ 2610 NJ 2610 NJ 2610 NJ 2610 NJ
load net LED_RGB[0] -attr @rip(#000000) 0 -port LED_RGB[0] -pin LED_RGB_OBUF[0]_inst O
load net LED_RGB[1] -attr @rip(#000000) 1 -port LED_RGB[1] -pin LED_RGB_OBUF[1]_inst O
load net LED_RGB[2] -attr @rip(#000000) 2 -port LED_RGB[2] -pin LED_RGB_OBUF[2]_inst O
load net LED_RGB_OBUF[0] -attr @rip(#000000) LED_RGB_OBUF[0] -pin LED_RGB_OBUF[0]_inst I -pin U_ALARM LED_RGB_OBUF[0]
load net LED_RGB_OBUF[1] -attr @rip(#000000) LED_RGB_OBUF[1] -pin LED_RGB_OBUF[1]_inst I -pin U_ALARM LED_RGB_OBUF[1]
load net LED_RGB_OBUF[2] -attr @rip(#000000) LED_RGB_OBUF[2] -pin LED_RGB_OBUF[2]_inst I -pin U_ALARM LED_RGB_OBUF[2]
load net RST_BTN -port RST_BTN -pin RST_BTN_IBUF_inst I
netloc RST_BTN 1 0 2 NJ 5570 NJ
load net RST_BTN_IBUF -pin RST_BTN_IBUF_inst O -pin U_ALARM RST_BTN_IBUF -pin U_BAUD RST_BTN_IBUF -pin U_CLOCK RST_BTN_IBUF -pin U_DATE RST_BTN_IBUF -pin U_DEB_DN RST_BTN_IBUF -pin U_DEB_L RST_BTN_IBUF -pin U_DEB_R RST_BTN_IBUF -pin U_DEB_UP RST_BTN_IBUF -pin U_FSM_SET RST_BTN_IBUF -pin U_PROTOCOL RST_BTN_IBUF -pin U_RTC RST_BTN_IBUF -pin U_RX RST_BTN_IBUF -pin U_SYNC RST_BTN_IBUF -pin U_TX RST_BTN_IBUF -pin alarm_en_state_reg CLR -pin blink_cnt_reg[0] CLR -pin blink_cnt_reg[1] CLR -pin blink_cnt_reg[2] CLR -pin led15_reg_reg CLR -pin ms_cnt_reg[0] CLR -pin ms_cnt_reg[1] CLR -pin ms_cnt_reg[2] CLR -pin ms_cnt_reg[3] CLR -pin ms_cnt_reg[4] CLR -pin ms_cnt_reg[5] CLR -pin ms_cnt_reg[6] CLR -pin ms_cnt_reg[7] CLR -pin pc_al_hr_reg[0] CLR -pin pc_al_hr_reg[1] CLR -pin pc_al_hr_reg[2] CLR -pin pc_al_hr_reg[3] CLR -pin pc_al_hr_reg[4] CLR -pin pc_al_min_reg[0] CLR -pin pc_al_min_reg[1] CLR -pin pc_al_min_reg[2] CLR -pin pc_al_min_reg[3] CLR -pin pc_al_min_reg[4] CLR -pin pc_al_min_reg[5] CLR -pin pc_al_sec_reg[0] CLR -pin pc_al_sec_reg[1] CLR -pin pc_al_sec_reg[2] CLR -pin pc_al_sec_reg[3] CLR -pin pc_al_sec_reg[4] CLR -pin pc_al_sec_reg[5] CLR
netloc RST_BTN_IBUF 1 2 7 540 5560 990 5280 1660 5300 3910 4950 5480 4450 7590 5810 NJ
load net SEG[0] -attr @rip(#000000) 0 -port SEG[0] -pin SEG_OBUF[0]_inst O
load net SEG[1] -attr @rip(#000000) 1 -port SEG[1] -pin SEG_OBUF[1]_inst O
load net SEG[2] -attr @rip(#000000) 2 -port SEG[2] -pin SEG_OBUF[2]_inst O
load net SEG[3] -attr @rip(#000000) 3 -port SEG[3] -pin SEG_OBUF[3]_inst O
load net SEG[4] -attr @rip(#000000) 4 -port SEG[4] -pin SEG_OBUF[4]_inst O
load net SEG[5] -attr @rip(#000000) 5 -port SEG[5] -pin SEG_OBUF[5]_inst O
load net SEG[6] -attr @rip(#000000) 6 -port SEG[6] -pin SEG_OBUF[6]_inst O
load net SEG_OBUF[0] -attr @rip(#000000) Q[0] -pin SEG_OBUF[0]_inst I -pin U_DISPLAY Q[0]
load net SEG_OBUF[1] -attr @rip(#000000) Q[1] -pin SEG_OBUF[1]_inst I -pin U_DISPLAY Q[1]
load net SEG_OBUF[2] -attr @rip(#000000) Q[2] -pin SEG_OBUF[2]_inst I -pin U_DISPLAY Q[2]
load net SEG_OBUF[3] -attr @rip(#000000) Q[3] -pin SEG_OBUF[3]_inst I -pin U_DISPLAY Q[3]
load net SEG_OBUF[4] -attr @rip(#000000) Q[4] -pin SEG_OBUF[4]_inst I -pin U_DISPLAY Q[4]
load net SEG_OBUF[5] -attr @rip(#000000) Q[5] -pin SEG_OBUF[5]_inst I -pin U_DISPLAY Q[5]
load net SEG_OBUF[6] -attr @rip(#000000) Q[6] -pin SEG_OBUF[6]_inst I -pin U_DISPLAY Q[6]
load net SW[0] -attr @rip(#000000) SW[0] -port SW[0] -pin SW_IBUF[0]_inst I
load net SW[10] -attr @rip(#000000) SW[10] -port SW[10] -pin SW_IBUF[10]_inst I
load net SW[11] -attr @rip(#000000) SW[11] -port SW[11] -pin SW_IBUF[11]_inst I
load net SW[12] -attr @rip(#000000) SW[12] -port SW[12] -pin SW_IBUF[12]_inst I
load net SW[13] -attr @rip(#000000) SW[13] -port SW[13] -pin SW_IBUF[13]_inst I
load net SW[14] -attr @rip(#000000) SW[14] -port SW[14] -pin SW_IBUF[14]_inst I
load net SW[15] -attr @rip(#000000) SW[15] -port SW[15] -pin SW_IBUF[15]_inst I
load net SW[1] -attr @rip(#000000) SW[1] -port SW[1] -pin SW_IBUF[1]_inst I
load net SW[2] -attr @rip(#000000) SW[2] -port SW[2] -pin SW_IBUF[2]_inst I
load net SW[3] -attr @rip(#000000) SW[3] -port SW[3] -pin SW_IBUF[3]_inst I
load net SW[4] -attr @rip(#000000) SW[4] -port SW[4] -pin SW_IBUF[4]_inst I
load net SW[5] -attr @rip(#000000) SW[5] -port SW[5] -pin SW_IBUF[5]_inst I
load net SW[6] -attr @rip(#000000) SW[6] -port SW[6] -pin SW_IBUF[6]_inst I
load net SW[7] -attr @rip(#000000) SW[7] -port SW[7] -pin SW_IBUF[7]_inst I
load net SW[8] -attr @rip(#000000) SW[8] -port SW[8] -pin SW_IBUF[8]_inst I
load net SW[9] -attr @rip(#000000) SW[9] -port SW[9] -pin SW_IBUF[9]_inst I
load net SW_IBUF[0] -attr @rip(#000000) 0 -pin SW_IBUF[0]_inst O -pin U_PROTOCOL SW_IBUF[0]
load net SW_IBUF[10] -attr @rip(#000000) 10 -pin SW_IBUF[10]_inst O -pin U_PROTOCOL SW_IBUF[10]
load net SW_IBUF[11] -attr @rip(#000000) 11 -pin SW_IBUF[11]_inst O -pin U_PROTOCOL SW_IBUF[11]
load net SW_IBUF[12] -attr @rip(#000000) 12 -pin SW_IBUF[12]_inst O -pin U_PROTOCOL SW_IBUF[12]
load net SW_IBUF[13] -attr @rip(#000000) 13 -pin SW_IBUF[13]_inst O -pin U_PROTOCOL SW_IBUF[13]
load net SW_IBUF[14] -pin SW_IBUF[14]_inst O -pin U_DATE SW_IBUF[0] -pin U_DEB_L SW_IBUF[0] -pin U_DEB_UP SW_IBUF[0] -pin U_FSM_SET SW_IBUF[0] -pin U_PROTOCOL SW_IBUF[14] -pin U_RTC SW_IBUF[0]
load net SW_IBUF[15] -pin SW_IBUF[15]_inst O -pin U_PROTOCOL SW_IBUF[15] -pin U_RTC SW_IBUF[1]
load net SW_IBUF[1] -attr @rip(#000000) 1 -pin SW_IBUF[1]_inst O -pin U_PROTOCOL SW_IBUF[1]
load net SW_IBUF[2] -attr @rip(#000000) 2 -pin SW_IBUF[2]_inst O -pin U_PROTOCOL SW_IBUF[2]
load net SW_IBUF[3] -attr @rip(#000000) 3 -pin SW_IBUF[3]_inst O -pin U_PROTOCOL SW_IBUF[3]
load net SW_IBUF[4] -attr @rip(#000000) 4 -pin SW_IBUF[4]_inst O -pin U_PROTOCOL SW_IBUF[4]
load net SW_IBUF[5] -attr @rip(#000000) 5 -pin SW_IBUF[5]_inst O -pin U_PROTOCOL SW_IBUF[5]
load net SW_IBUF[6] -attr @rip(#000000) 6 -pin SW_IBUF[6]_inst O -pin U_PROTOCOL SW_IBUF[6]
load net SW_IBUF[7] -attr @rip(#000000) 7 -pin SW_IBUF[7]_inst O -pin U_PROTOCOL SW_IBUF[7]
load net SW_IBUF[8] -attr @rip(#000000) 8 -pin SW_IBUF[8]_inst O -pin U_PROTOCOL SW_IBUF[8]
load net SW_IBUF[9] -attr @rip(#000000) 9 -pin SW_IBUF[9]_inst O -pin U_PROTOCOL SW_IBUF[9]
load net UART_RXD -port UART_RXD -pin UART_RXD_IBUF_inst I
netloc UART_RXD 1 0 2 NJ 6130 NJ
load net UART_RXD_IBUF -pin UART_RXD_IBUF_inst O -pin U_SYNC UART_RXD_IBUF
netloc UART_RXD_IBUF 1 2 1 520J 5660n
load net UART_TXD -port UART_TXD -pin UART_TXD_OBUF_inst O
netloc UART_TXD 1 10 1 NJ 6260
load net UART_TXD_OBUF -pin UART_TXD_OBUF_inst I -pin U_TX tx
netloc UART_TXD_OBUF 1 4 6 1980J 5890 NJ 5890 NJ 5890 NJ 5890 NJ 5890 9020J
load net U_CLOCK_n_0 -pin U_CLOCK CE_1s_reg_0 -pin blink_tog_reg D
netloc U_CLOCK_n_0 1 2 3 560 5300 NJ 5300 1620
load net U_DATE_n_0 -pin U_DATE month_reg[1]_0 -pin U_PROTOCOL tx_buf_reg[6][1]_0
netloc U_DATE_n_0 1 4 5 2260 2710 NJ 2710 NJ 2710 NJ 2710 8130
load net U_DATE_n_17 -pin U_DATE month_reg[2]_0 -pin U_PROTOCOL tx_buf_reg[6][2]_0
netloc U_DATE_n_17 1 4 5 2340 2730 NJ 2730 NJ 2730 NJ 2730 8310
load net U_DATE_n_18 -pin U_DATE month_reg[3]_0 -pin U_PROTOCOL tx_buf_reg[6][3]_0
netloc U_DATE_n_18 1 4 5 2360 2750 NJ 2750 NJ 2750 NJ 2750 8430
load net U_DATE_n_19 -attr @rip(#000000) D[0] -pin U_DATE D[0] -pin U_PROTOCOL tx_buf_reg[5][5]_0[0]
netloc U_DATE_n_19 1 4 5 2120 4700 3830J 4710 5820J 5010 7150J 5070 8370
load net U_DATE_n_20 -pin U_DATE year_reg[6]_1 -pin U_PROTOCOL tx_buf_reg[5][6]_0
netloc U_DATE_n_20 1 4 5 2160 4720 3810J 4730 5500J 5030 7130J 5090 8270
load net U_DATE_n_21 -attr @rip(#000000) month_reg[3]_1[1] -pin U_DATE month_reg[3]_1[1] -pin U_PROTOCOL tx_buf_reg[9][5]_0[3]
load net U_DATE_n_22 -attr @rip(#000000) month_reg[3]_1[0] -pin U_DATE month_reg[3]_1[0] -pin U_PROTOCOL tx_buf_reg[9][5]_0[1]
load net U_DATE_n_23 -pin U_DATE year_reg[0]_0 -pin U_PROTOCOL tx_buf_reg[6][0]_1
netloc U_DATE_n_23 1 4 5 2440 3850 3490J 3110 4780J 2810 NJ 2810 8230
load net U_DATE_n_24 -pin U_DATE year_reg[5]_0 -pin U_PROTOCOL year_reg[5]
netloc U_DATE_n_24 1 4 5 2460 4050 3950J 3730 5260J 4890 7510J 4990 8290
load net U_DATE_n_25 -pin U_DATE year_reg[3]_0 -pin U_DEB_UP year_reg[6]
netloc U_DATE_n_25 1 2 7 580 5870 NJ 5870 NJ 5870 NJ 5870 NJ 5870 NJ 5870 8430
load net U_DATE_n_31 -pin U_DATE year_reg[6]_2 -pin U_FSM_SET Q_reg[6]_i_35 -pin U_RTC Q_reg[6]_i_35_0
netloc U_DATE_n_31 1 5 4 4290 4690 6160 4930 7190J 5030 8230
load net U_DATE_n_32 -pin U_DATE btn_pulse_reg -pin U_PROTOCOL month_reg[2]
netloc U_DATE_n_32 1 4 5 2420 2670 NJ 2670 NJ 2670 NJ 2670 8650
load net U_DATE_n_33 -pin U_DATE month_reg[3]_2 -pin U_PROTOCOL month_reg[3]
netloc U_DATE_n_33 1 4 5 2460 2690 NJ 2690 NJ 2690 NJ 2690 8450
load net U_DATE_n_34 -pin U_DATE month_reg[2]_1 -pin U_FSM_SET year_reg[6]_0
netloc U_DATE_n_34 1 5 4 3730 5470 5620J 5450 7510J 5410 8410
load net U_DATE_n_39 -pin U_DATE day_reg[0]_0 -pin U_RTC year_reg[6]
netloc U_DATE_n_39 1 6 3 6260 2990 NJ 2990 8190
load net U_DATE_n_41 -pin U_DATE month_reg[1]_1 -pin U_DISPLAY Q[6]_i_2
netloc U_DATE_n_41 1 8 1 8590 4510n
load net U_DATE_n_42 -pin U_DATE counter_reg[0] -pin U_DISPLAY Q_reg[6]_5
netloc U_DATE_n_42 1 8 1 8650 4250n
load net U_DATE_n_43 -pin U_DATE counter_reg[1] -pin U_DISPLAY Q_reg[6]_1
netloc U_DATE_n_43 1 8 1 8610 4270n
load net U_DATE_n_47 -pin U_DATE month_reg[0]_0 -pin U_FSM_SET Q[6]_i_3
netloc U_DATE_n_47 1 5 4 4150 3190 5040J 2890 NJ 2890 8410
load net U_DATE_n_48 -pin U_DATE day_reg[1]_0 -pin U_FSM_SET Q[6]_i_2
netloc U_DATE_n_48 1 5 4 4170 3210 5060J 2910 NJ 2910 8350
load net U_DATE_n_49 -pin U_DATE day_reg[1]_1 -pin U_FSM_SET Q[6]_i_4_0
netloc U_DATE_n_49 1 5 4 4190 3230 5080J 2930 NJ 2930 8150
load net U_DATE_n_50 -pin U_DATE year_reg[1]_0 -pin U_FSM_SET Q_reg[6]_i_68
netloc U_DATE_n_50 1 5 4 4130 3650 5940J 4150 7070J 4090 8170
load net U_DATE_n_51 -pin U_DATE month_reg[3]_3 -pin U_FSM_SET Q_reg[6]_i_39
netloc U_DATE_n_51 1 5 4 4210 3250 5100J 2950 NJ 2950 8210
load net U_DATE_n_52 -pin U_DATE day_reg[4]_1 -pin U_FSM_SET Q_reg[6]_i_37
netloc U_DATE_n_52 1 5 4 4270 3270 5140J 2970 NJ 2970 8390
load net U_DEB_DN_n_0 -pin U_DEB_DN btn_pulse_reg_0 -pin U_FSM_SET sec_reg[5]
netloc U_DEB_DN_n_0 1 4 2 1640J 4860 3050
load net U_DEB_L_n_0 -pin U_DEB_L btn_pulse_reg_0 -pin U_FSM_SET current_sel_reg[0]_3
netloc U_DEB_L_n_0 1 5 1 3030 4250n
load net U_DEB_UP_n_0 -pin U_DATE year_reg[6]_3 -pin U_DEB_UP btn_pulse_reg_0
netloc U_DEB_UP_n_0 1 3 5 NJ 5790 NJ 5790 NJ 5790 NJ 5790 7630
load net U_DEB_UP_n_2 -pin U_DATE year_reg[5]_1 -pin U_DEB_UP btn_pulse_reg_1 -pin U_RTC sec_reg[4]_0
netloc U_DEB_UP_n_2 1 3 5 NJ 5810 NJ 5810 NJ 5810 6140 4810 7310J
load net U_FSM_SET_n_1 -attr @rip(#000000) E[0] -pin U_FSM_SET E[0] -pin U_RTC hr_reg[4]_4[0]
netloc U_FSM_SET_n_1 1 6 1 6000 3470n
load net U_FSM_SET_n_11 -pin U_DISPLAY Q_reg[6]_2 -pin U_FSM_SET counter_reg[0]_0
netloc U_FSM_SET_n_11 1 6 3 5560 5550 7390J 5530 8590J
load net U_FSM_SET_n_12 -pin U_DATE Q[6]_i_8_0 -pin U_DISPLAY Q[6]_i_5 -pin U_FSM_SET blink_tog_reg_0 -pin U_RTC Q[6]_i_13_1
netloc U_FSM_SET_n_12 1 6 3 5580 4270 7690 4930 8510
load net U_FSM_SET_n_13 -pin U_DISPLAY Q_reg[6]_4 -pin U_FSM_SET counter_reg[0]_1
netloc U_FSM_SET_n_13 1 6 3 5180 5590 7450J 5570 8630J
load net U_FSM_SET_n_14 -pin U_DISPLAY Q_reg[6] -pin U_FSM_SET counter_reg[0]_2
netloc U_FSM_SET_n_14 1 6 3 5680 5530 7370J 5490 8510J
load net U_FSM_SET_n_15 -pin U_FSM_SET blink_tog_reg_1 -pin U_RTC Q[6]_i_13_0
netloc U_FSM_SET_n_15 1 6 1 5500 3190n
load net U_FSM_SET_n_16 -pin U_DATE Q_reg[6]_i_40 -pin U_FSM_SET blink_tog_reg_2
netloc U_FSM_SET_n_16 1 6 2 5500 4430 NJ
load net U_FSM_SET_n_17 -pin U_FSM_SET blink_tog_reg_3 -pin U_RTC Q_reg[6]_i_40
netloc U_FSM_SET_n_17 1 6 1 5840 3250n
load net U_FSM_SET_n_18 -pin U_DATE Q[6]_i_13 -pin U_FSM_SET blink_tog_reg_4
netloc U_FSM_SET_n_18 1 6 2 5840 4310 NJ
load net U_FSM_SET_n_19 -pin U_DATE Q[6]_i_15 -pin U_FSM_SET blink_tog_reg_5
netloc U_FSM_SET_n_19 1 6 2 5820 4330 NJ
load net U_FSM_SET_n_2 -attr @rip(#000000) current_sel_reg[0]_1[0] -pin U_FSM_SET current_sel_reg[0]_1[0] -pin U_RTC min_reg[5]_2[0]
netloc U_FSM_SET_n_2 1 6 1 5760 3530n
load net U_FSM_SET_n_20 -pin U_DATE Q_reg[6]_i_14_0 -pin U_FSM_SET blink_tog_reg_6
netloc U_FSM_SET_n_20 1 6 2 5780 4350 NJ
load net U_FSM_SET_n_21 -pin U_DATE Q[6]_i_9_0 -pin U_FSM_SET blink_tog_reg_7
netloc U_FSM_SET_n_21 1 6 2 5800 4290 NJ
load net U_FSM_SET_n_22 -pin U_DATE Q_reg[6]_i_14_1 -pin U_FSM_SET blink_tog_reg_8
netloc U_FSM_SET_n_22 1 6 2 5320 4370 NJ
load net U_FSM_SET_n_23 -pin U_DATE Q[6]_i_8 -pin U_FSM_SET blink_tog_reg_9
netloc U_FSM_SET_n_23 1 6 2 5240 4250 NJ
load net U_FSM_SET_n_3 -attr @rip(#000000) current_sel_reg[2]_0[0] -pin U_FSM_SET current_sel_reg[2]_0[0] -pin U_RTC E[0]
netloc U_FSM_SET_n_3 1 6 1 5720 3130n
load net U_FSM_SET_n_4 -attr @rip(#000000) current_sel_reg[0]_2[0] -pin U_DATE E[0] -pin U_FSM_SET current_sel_reg[0]_2[0]
netloc U_FSM_SET_n_4 1 6 2 5280 4210 NJ
load net U_FSM_SET_n_5 -attr @rip(#000000) btn_pulse_reg[0] -pin U_DATE month_reg[3]_4[0] -pin U_FSM_SET btn_pulse_reg[0]
netloc U_FSM_SET_n_5 1 6 2 5220 4670 NJ
load net U_FSM_SET_n_6 -pin U_DATE day_reg[0]_1 -pin U_FSM_SET btn_pulse_reg_0
netloc U_FSM_SET_n_6 1 6 2 4780 4530 NJ
load net U_FSM_SET_n_7 -pin U_DISPLAY Q_reg[6]_3 -pin U_FSM_SET counter_reg[0]
netloc U_FSM_SET_n_7 1 6 3 5200 5570 7410J 5550 8610J
load net U_PROTOCOL_n_103 -attr @rip(#000000) rx_valid_pulse_reg_1[0] -pin U_PROTOCOL rx_valid_pulse_reg_1[0] -pin ms_cnt_reg[0] CE -pin ms_cnt_reg[1] CE -pin ms_cnt_reg[2] CE -pin ms_cnt_reg[3] CE -pin ms_cnt_reg[4] CE -pin ms_cnt_reg[5] CE -pin ms_cnt_reg[6] CE -pin ms_cnt_reg[7] CE
netloc U_PROTOCOL_n_103 1 3 3 1170 1060 NJ 1060 3110
load net U_PROTOCOL_n_13 -pin U_DATE tx_buf_reg[5][5] -pin U_PROTOCOL cmd_reg_reg[1]_0
netloc U_PROTOCOL_n_13 1 5 3 3450 3170 4840J 2870 7670J
load net U_PROTOCOL_n_15 -attr @rip(#000000) D[1] -pin U_PROTOCOL D[1] -pin U_RTC sec_reg[2]_1[1]
load net U_PROTOCOL_n_16 -attr @rip(#000000) D[0] -pin U_PROTOCOL D[0] -pin U_RTC sec_reg[2]_1[0]
load net U_PROTOCOL_n_21 -attr @rip(#000000) out_min_reg[2]_0[2] -pin U_PROTOCOL out_min_reg[2]_0[2] -pin U_RTC min_reg[2]_1[2]
load net U_PROTOCOL_n_22 -attr @rip(#000000) out_min_reg[2]_0[1] -pin U_PROTOCOL out_min_reg[2]_0[1] -pin U_RTC min_reg[2]_1[1]
load net U_PROTOCOL_n_23 -attr @rip(#000000) out_min_reg[2]_0[0] -pin U_PROTOCOL out_min_reg[2]_0[0] -pin U_RTC min_reg[2]_1[0]
load net U_PROTOCOL_n_32 -attr @rip(#000000) out_year_reg[5]_0[2] -pin U_DATE year_reg[5]_2[2] -pin U_PROTOCOL out_year_reg[5]_0[2]
load net U_PROTOCOL_n_33 -attr @rip(#000000) out_year_reg[5]_0[1] -pin U_DATE year_reg[5]_2[1] -pin U_PROTOCOL out_year_reg[5]_0[1]
load net U_PROTOCOL_n_34 -attr @rip(#000000) out_year_reg[5]_0[0] -pin U_DATE year_reg[5]_2[0] -pin U_PROTOCOL out_year_reg[5]_0[0]
load net U_PROTOCOL_n_43 -pin U_PROTOCOL CE_1ms_reg -pin blink_cnt_reg[2] D
netloc U_PROTOCOL_n_43 1 3 3 1150 4900 NJ 4900 3170
load net U_PROTOCOL_n_44 -pin U_PROTOCOL CE_1ms_reg_0 -pin blink_cnt_reg[1] D
netloc U_PROTOCOL_n_44 1 3 3 1130 4920 NJ 4920 3150
load net U_PROTOCOL_n_45 -pin U_PROTOCOL CE_1ms_reg_1 -pin blink_cnt_reg[0] D
netloc U_PROTOCOL_n_45 1 3 3 1170 3870 1880J 3990 3130
load net U_PROTOCOL_n_48 -pin U_PROTOCOL SW[4] -pin U_RTC prev_alarm_ringing_i_2_3
netloc U_PROTOCOL_n_48 1 5 2 NJ 2990 6200
load net U_PROTOCOL_n_49 -pin U_PROTOCOL SW[4]_0 -pin U_RTC prev_alarm_ringing_i_2_1
netloc U_PROTOCOL_n_49 1 5 2 NJ 3010 6220
load net U_PROTOCOL_n_50 -pin U_PROTOCOL SW[5] -pin U_RTC prev_alarm_ringing_i_5_1
netloc U_PROTOCOL_n_50 1 5 2 NJ 3050 5360
load net U_PROTOCOL_n_51 -pin U_PROTOCOL SW[4]_1 -pin U_RTC prev_alarm_ringing_i_2_5
netloc U_PROTOCOL_n_51 1 5 2 NJ 3030 6180
load net U_PROTOCOL_n_52 -pin U_PROTOCOL pc_al_sec_reg[1] -pin U_RTC prev_alarm_ringing_i_2_4
netloc U_PROTOCOL_n_52 1 5 2 3290 3470 5960J
load net U_PROTOCOL_n_53 -pin U_PROTOCOL pc_al_sec_reg[1]_0 -pin U_RTC prev_alarm_ringing_i_2_0
netloc U_PROTOCOL_n_53 1 5 2 3550 3430 6140J
load net U_PROTOCOL_n_54 -pin U_PROTOCOL pc_al_sec_reg[1]_1 -pin U_RTC prev_alarm_ringing_i_2_2
netloc U_PROTOCOL_n_54 1 5 2 3670 3450 5980J
load net U_PROTOCOL_n_57 -pin U_PROTOCOL pc_al_min_reg[1] -pin U_RTC tx_len[3]_i_9_2
netloc U_PROTOCOL_n_57 1 5 2 3310 3570 6100J
load net U_PROTOCOL_n_58 -pin U_PROTOCOL SW[11] -pin U_RTC tx_len[3]_i_9_3
netloc U_PROTOCOL_n_58 1 5 2 NJ 3070 4880
load net U_PROTOCOL_n_59 -pin U_PROTOCOL pc_al_min_reg[1]_0 -pin U_RTC tx_len[3]_i_9_0
netloc U_PROTOCOL_n_59 1 5 2 3350 3530 5740J
load net U_PROTOCOL_n_60 -pin U_PROTOCOL SW[11]_0 -pin U_RTC tx_len[3]_i_9_1
netloc U_PROTOCOL_n_60 1 5 2 3370 3550 4920J
load net U_PROTOCOL_n_61 -pin U_PROTOCOL SW[12] -pin U_RTC prev_alarm_ringing_i_7_1
netloc U_PROTOCOL_n_61 1 5 2 3430 3490 4960J
load net U_PROTOCOL_n_64 -pin U_PROTOCOL rx_valid_pulse_reg_0 -pin led15_reg_reg D
netloc U_PROTOCOL_n_64 1 3 3 1110 4940 NJ 4940 2950
load net U_PROTOCOL_n_65 -pin U_PROTOCOL out_al_en_val_reg_0 -pin alarm_en_state_reg D
netloc U_PROTOCOL_n_65 1 3 3 1110 4070 1700J 4030 3050
load net U_PROTOCOL_n_67 -attr @rip(#000000) ms_cnt_reg[7][6] -pin U_PROTOCOL ms_cnt_reg[7][6] -pin ms_cnt_reg[6] D
load net U_PROTOCOL_n_69 -attr @rip(#000000) ms_cnt_reg[7][4] -pin U_PROTOCOL ms_cnt_reg[7][4] -pin ms_cnt_reg[4] D
load net U_PROTOCOL_n_70 -attr @rip(#000000) ms_cnt_reg[7][3] -pin U_PROTOCOL ms_cnt_reg[7][3] -pin ms_cnt_reg[3] D
load net U_PROTOCOL_n_8 -pin U_PROTOCOL cmd_reg_reg[2]_0 -pin U_RTC tx_buf_reg[6][4]
netloc U_PROTOCOL_n_8 1 5 2 3930 3510 5900J
load net U_RTC_n_1 -pin U_PROTOCOL tx_len_reg[0]_0 -pin U_RTC prev_alarm_ringing_reg
netloc U_RTC_n_1 1 4 4 2320 3930 3750J 3610 5920J 4110 6810
load net U_RTC_n_2 -pin U_PROTOCOL tx_buf_reg[6][4]_0 -pin U_RTC hr_reg[4]_0
netloc U_RTC_n_2 1 4 4 2340 3910 3730J 3590 6080J 4090 6850
load net U_RTC_n_20 -attr @rip(#000000) year_reg[5][3] -pin U_PROTOCOL tx_buf_reg[9][5]_0[5] -pin U_RTC year_reg[5][3]
load net U_RTC_n_21 -attr @rip(#000000) year_reg[5][2] -pin U_PROTOCOL tx_buf_reg[9][5]_0[4] -pin U_RTC year_reg[5][2]
load net U_RTC_n_22 -attr @rip(#000000) year_reg[5][1] -pin U_PROTOCOL tx_buf_reg[9][5]_0[2] -pin U_RTC year_reg[5][1]
load net U_RTC_n_23 -attr @rip(#000000) year_reg[5][0] -pin U_PROTOCOL tx_buf_reg[9][5]_0[0] -pin U_RTC year_reg[5][0]
load net U_RTC_n_24 -pin U_PROTOCOL tx_buf_reg[6][3]_1 -pin U_RTC hr_reg[3]_0
netloc U_RTC_n_24 1 4 4 2100 4760 3710J 4770 5020J 5070 6870
load net U_RTC_n_25 -pin U_PROTOCOL tx_buf_reg[6][2]_1 -pin U_RTC hr_reg[2]_0
netloc U_RTC_n_25 1 4 4 2400 2770 NJ 2770 NJ 2770 6850
load net U_RTC_n_26 -pin U_PROTOCOL tx_buf_reg[6][1]_1 -pin U_RTC hr_reg[1]_0
netloc U_RTC_n_26 1 4 4 2380 3890 3570J 3150 4820J 2850 6790
load net U_RTC_n_30 -pin U_FSM_SET min_reg[5] -pin U_RTC sec_reg[5]_1
netloc U_RTC_n_30 1 5 3 4270 5370 NJ 5370 6770
load net U_RTC_n_31 -pin U_PROTOCOL sec_reg[2] -pin U_RTC sec_reg[2]_0
netloc U_RTC_n_31 1 4 4 2440 2790 NJ 2790 NJ 2790 6770
load net U_RTC_n_38 -pin U_PROTOCOL min_reg[2] -pin U_RTC min_reg[2]_0
netloc U_RTC_n_38 1 4 4 2380 2650 NJ 2650 NJ 2650 6950
load net U_RTC_n_41 -pin U_PROTOCOL hr_reg[3] -pin U_RTC hr_reg[4]_1
netloc U_RTC_n_41 1 4 4 2280 2630 NJ 2630 NJ 2630 6750
load net U_RTC_n_44 -pin U_DATE Q_reg[6]_i_23_0 -pin U_FSM_SET Q_reg[6]_i_23 -pin U_RTC hr_reg[4]_2
netloc U_RTC_n_44 1 5 3 4290 3670 5860J 4390 7190
load net U_RTC_n_46 -pin U_FSM_SET year_reg[6]_1 -pin U_RTC CE_DDU_reg_0
netloc U_RTC_n_46 1 5 3 3750 5490 5640J 5470 6910
load net U_RTC_n_47 -pin U_DISPLAY Q_reg[6]_0 -pin U_RTC counter_reg[1]
netloc U_RTC_n_47 1 7 2 7570 5510 8550J
load net U_RTC_n_49 -pin U_PROTOCOL tx_buf_reg[6][0]_0 -pin U_RTC hr_reg[0]_0
netloc U_RTC_n_49 1 4 4 2420 3870 3530J 3130 4800J 2830 6810
load net U_RTC_n_50 -pin U_FSM_SET hr_reg[4] -pin U_RTC CE_1s_reg
netloc U_RTC_n_50 1 5 3 4150 5350 NJ 5350 6890
load net U_RTC_n_51 -pin U_DATE Q_reg[6]_i_37_0 -pin U_FSM_SET Q_reg[6]_i_37_0 -pin U_RTC hr_reg[1]_1
netloc U_RTC_n_51 1 5 3 4250 3690 5000J 4410 7210
load net U_RX_n_0 -pin U_PROTOCOL payload_buf_reg[4][0]_0 -pin U_RX rx_done_reg_0
netloc U_RX_n_0 1 4 1 1840 3250n
load net U_RX_n_11 -pin U_PROTOCOL payload_cnt_reg[0]_0 -pin U_RX dout_reg[6]_0
netloc U_RX_n_11 1 4 1 1820 3270n
load net U_RX_n_12 -pin U_PROTOCOL FSM_sequential_state_reg[2]_0 -pin U_RX FSM_sequential_state_reg[1]_0
netloc U_RX_n_12 1 4 1 1680 2930n
load net U_RX_n_13 -pin U_PROTOCOL FSM_sequential_state_reg[0]_0 -pin U_RX rx_done_reg_1
netloc U_RX_n_13 1 4 1 1720 2890n
load net U_RX_n_2 -pin U_PROTOCOL FSM_sequential_state_reg[1]_0 -pin U_RX dout_reg[2]_0
netloc U_RX_n_2 1 4 1 1700 2910n
load net al_hht[0] -attr @rip(#000000) al_hht[0] -pin U_PROTOCOL al_hht[0] -pin U_RTC al_hht[0]
load net al_hht[1] -attr @rip(#000000) al_hht[1] -pin U_PROTOCOL al_hht[1] -pin U_RTC al_hht[1]
load net al_mmt[0] -attr @rip(#000000) al_mmt[0] -pin U_PROTOCOL al_mmt[0] -pin U_RTC al_mmt[0]
load net al_mmt[1] -attr @rip(#000000) al_mmt[1] -pin U_PROTOCOL al_mmt[1] -pin U_RTC al_mmt[1]
load net al_mmu[0] -attr @rip(#000000) al_mmu[0] -pin U_PROTOCOL al_mmu[0] -pin U_RTC al_mmu[0]
load net al_mmu[1] -attr @rip(#000000) al_mmu[1] -pin U_PROTOCOL al_mmu[1] -pin U_RTC al_mmu[1]
load net al_mmu[2] -attr @rip(#000000) al_mmu[2] -pin U_PROTOCOL al_mmu[2] -pin U_RTC al_mmu[2]
load net al_mmu[3] -attr @rip(#000000) al_mmu[3] -pin U_PROTOCOL al_mmu[3] -pin U_RTC al_mmu[3]
load net al_sst[0] -attr @rip(#000000) al_sst[0] -pin U_PROTOCOL al_sst[0] -pin U_RTC al_sst[0]
load net al_sst[1] -attr @rip(#000000) al_sst[1] -pin U_PROTOCOL al_sst[1] -pin U_RTC al_sst[1]
load net al_ssu[0] -attr @rip(#000000) al_ssu[0] -pin U_PROTOCOL al_ssu[0] -pin U_RTC al_ssu[0]
netloc al_ssu[0] 1 5 2 4030 3370 5000J
load net blink_cnt_reg_n_0_[0] -pin U_PROTOCOL blink_cnt_reg[2] -pin blink_cnt_reg[0] Q
netloc blink_cnt_reg_n_0_[0] 1 4 1 1740 3050n
load net blink_cnt_reg_n_0_[1] -pin U_PROTOCOL blink_cnt_reg[2]_0 -pin blink_cnt_reg[1] Q
netloc blink_cnt_reg_n_0_[1] 1 4 1 1800 3070n
load net blink_cnt_reg_n_0_[2] -pin U_PROTOCOL blink_cnt_reg[2]_1 -pin blink_cnt_reg[2] Q
netloc blink_cnt_reg_n_0_[2] 1 4 1 1860 3090n
load net blink_tog -pin U_CLOCK blink_tog -pin U_FSM_SET blink_tog -pin blink_tog_reg Q
netloc blink_tog 1 3 3 1190 5140 NJ 5140 3870
load net ce_ddu_sig -pin U_DATE CE_DDU -pin U_RTC CE_DDU
netloc ce_ddu_sig 1 7 1 7650 3270n
load net counter[0] -attr @rip(#000000) counter_reg[1][0] -pin U_DATE counter[0] -pin U_DISPLAY counter_reg[1][0] -pin U_FSM_SET Q[6]_i_4[0] -pin U_RTC Q[6]_i_4[0]
load net counter[1] -attr @rip(#000000) counter_reg[1][1] -pin U_DATE counter[1] -pin U_DISPLAY counter_reg[1][1] -pin U_RTC Q[6]_i_4[1]
load net cur_day_sig[0] -attr @rip(#000000) day_reg[4]_0[0] -pin U_DATE day_reg[4]_0[0] -pin U_FSM_SET Q[6]_i_24_0[0] -pin U_PROTOCOL tx_buf_reg[3][4]_0[0] -pin U_RTC tx_buf_reg[9][4][0]
load net cur_day_sig[1] -attr @rip(#000000) day_reg[4]_0[1] -pin U_DATE day_reg[4]_0[1] -pin U_PROTOCOL tx_buf_reg[3][4]_0[1]
load net cur_day_sig[2] -attr @rip(#000000) day_reg[4]_0[2] -pin U_DATE day_reg[4]_0[2] -pin U_PROTOCOL tx_buf_reg[3][4]_0[2] -pin U_RTC tx_buf_reg[9][4][1]
load net cur_day_sig[3] -attr @rip(#000000) day_reg[4]_0[3] -pin U_DATE day_reg[4]_0[3] -pin U_PROTOCOL tx_buf_reg[3][4]_0[3]
load net cur_day_sig[4] -attr @rip(#000000) day_reg[4]_0[4] -pin U_DATE day_reg[4]_0[4] -pin U_PROTOCOL tx_buf_reg[3][4]_0[4] -pin U_RTC tx_buf_reg[9][4][2]
load net cur_hr_sig[0] -attr @rip(#000000) Q[0] -pin U_FSM_SET Q[6]_i_24_1[0] -pin U_PROTOCOL tx_buf_reg[5][4]_1[0] -pin U_RTC Q[0]
load net cur_hr_sig[1] -attr @rip(#000000) Q[1] -pin U_DATE tx_buf_reg[9][3]_1[0] -pin U_PROTOCOL tx_buf_reg[5][4]_1[1] -pin U_RTC Q[1]
load net cur_hr_sig[2] -attr @rip(#000000) Q[2] -pin U_PROTOCOL tx_buf_reg[5][4]_1[2] -pin U_RTC Q[2]
load net cur_hr_sig[3] -attr @rip(#000000) Q[3] -pin U_DATE tx_buf_reg[9][3]_1[1] -pin U_PROTOCOL tx_buf_reg[5][4]_1[3] -pin U_RTC Q[3]
load net cur_hr_sig[4] -attr @rip(#000000) Q[4] -pin U_PROTOCOL tx_buf_reg[5][4]_1[4] -pin U_RTC Q[4]
load net cur_min_sig[0] -attr @rip(#000000) min_reg[5]_0[0] -pin U_FSM_SET Q[0] -pin U_PROTOCOL tx_buf_reg[4][5]_0[0] -pin U_RTC min_reg[5]_0[0]
load net cur_min_sig[1] -attr @rip(#000000) min_reg[5]_0[1] -pin U_DATE tx_buf_reg[9][3][0] -pin U_PROTOCOL tx_buf_reg[4][5]_0[1] -pin U_RTC min_reg[5]_0[1]
load net cur_min_sig[2] -attr @rip(#000000) min_reg[5]_0[2] -pin U_PROTOCOL tx_buf_reg[4][5]_0[2] -pin U_RTC min_reg[5]_0[2]
load net cur_min_sig[3] -attr @rip(#000000) min_reg[5]_0[3] -pin U_DATE tx_buf_reg[9][3][1] -pin U_PROTOCOL tx_buf_reg[4][5]_0[3] -pin U_RTC min_reg[5]_0[3]
load net cur_min_sig[4] -attr @rip(#000000) min_reg[5]_0[4] -pin U_PROTOCOL tx_buf_reg[4][5]_0[4] -pin U_RTC min_reg[5]_0[4]
load net cur_min_sig[5] -attr @rip(#000000) min_reg[5]_0[5] -pin U_PROTOCOL tx_buf_reg[4][5]_0[5] -pin U_RTC min_reg[5]_0[5]
load net cur_month_sig[0] -attr @rip(#000000) Q[0] -pin U_DATE Q[0] -pin U_FSM_SET Q[6]_i_10_0[0] -pin U_PROTOCOL tx_buf_reg[7][3]_0[0] -pin U_RTC tx_buf_reg[9][2][0]
load net cur_month_sig[1] -attr @rip(#000000) Q[1] -pin U_DATE Q[1] -pin U_PROTOCOL tx_buf_reg[7][3]_0[1]
load net cur_month_sig[2] -attr @rip(#000000) Q[2] -pin U_DATE Q[2] -pin U_PROTOCOL tx_buf_reg[7][3]_0[2] -pin U_RTC tx_buf_reg[9][2][1]
load net cur_month_sig[3] -attr @rip(#000000) Q[3] -pin U_DATE Q[3] -pin U_PROTOCOL tx_buf_reg[7][3]_0[3]
load net cur_sec_sig[0] -attr @rip(#000000) sec_reg[5]_0[0] -pin U_FSM_SET Q[6]_i_29_1[0] -pin U_PROTOCOL tx_buf_reg[6][5]_0[0] -pin U_RTC sec_reg[5]_0[0]
load net cur_sec_sig[1] -attr @rip(#000000) sec_reg[5]_0[1] -pin U_DATE tx_buf_reg[9][3]_0[0] -pin U_PROTOCOL tx_buf_reg[6][5]_0[1] -pin U_RTC sec_reg[5]_0[1]
load net cur_sec_sig[2] -attr @rip(#000000) sec_reg[5]_0[2] -pin U_PROTOCOL tx_buf_reg[6][5]_0[2] -pin U_RTC sec_reg[5]_0[2]
load net cur_sec_sig[3] -attr @rip(#000000) sec_reg[5]_0[3] -pin U_DATE tx_buf_reg[9][3]_0[1] -pin U_PROTOCOL tx_buf_reg[6][5]_0[3] -pin U_RTC sec_reg[5]_0[3]
load net cur_sec_sig[4] -attr @rip(#000000) sec_reg[5]_0[4] -pin U_PROTOCOL tx_buf_reg[6][5]_0[4] -pin U_RTC sec_reg[5]_0[4]
load net cur_sec_sig[5] -attr @rip(#000000) sec_reg[5]_0[5] -pin U_PROTOCOL tx_buf_reg[6][5]_0[5] -pin U_RTC sec_reg[5]_0[5]
load net cur_year_sig[0] -attr @rip(#000000) year_reg[6]_0[0] -pin U_DATE year_reg[6]_0[0] -pin U_FSM_SET Q[6]_i_29_0[0] -pin U_PROTOCOL tx_buf_reg[8][6]_0[0] -pin U_RTC tx_buf_reg[9][5][0]
load net cur_year_sig[1] -attr @rip(#000000) year_reg[6]_0[1] -pin U_DATE year_reg[6]_0[1] -pin U_PROTOCOL tx_buf_reg[8][6]_0[1]
load net cur_year_sig[2] -attr @rip(#000000) year_reg[6]_0[2] -pin U_DATE year_reg[6]_0[2] -pin U_PROTOCOL tx_buf_reg[8][6]_0[2] -pin U_RTC tx_buf_reg[9][5][1]
load net cur_year_sig[3] -attr @rip(#000000) year_reg[6]_0[3] -pin U_DATE year_reg[6]_0[3] -pin U_PROTOCOL tx_buf_reg[8][6]_0[3]
load net cur_year_sig[4] -attr @rip(#000000) year_reg[6]_0[4] -pin U_DATE year_reg[6]_0[4] -pin U_PROTOCOL tx_buf_reg[8][6]_0[4] -pin U_RTC tx_buf_reg[9][5][2]
load net cur_year_sig[5] -attr @rip(#000000) year_reg[6]_0[5] -pin U_DATE year_reg[6]_0[5] -pin U_PROTOCOL tx_buf_reg[8][6]_0[5] -pin U_RTC tx_buf_reg[9][5][3]
load net cur_year_sig[6] -attr @rip(#000000) year_reg[6]_0[6] -pin U_DATE year_reg[6]_0[6] -pin U_PROTOCOL tx_buf_reg[8][6]_0[6]
load net ddt_sig[0] -attr @rip(#000000) ddt_sig[0] -pin U_DATE ddt_sig[0] -pin U_FSM_SET ddt_sig[0]
load net ddt_sig[1] -attr @rip(#000000) ddt_sig[1] -pin U_DATE ddt_sig[1] -pin U_FSM_SET ddt_sig[1]
load net ddu_sig[2] -attr @rip(#000000) ddu_sig[0] -pin U_DATE ddu_sig[0] -pin U_FSM_SET ddu_sig[0]
load net ddu_sig[3] -attr @rip(#000000) ddu_sig[1] -pin U_DATE ddu_sig[1] -pin U_FSM_SET ddu_sig[1]
load net disp_ad0[1] -attr @rip(#000000) disp_ad0[0] -pin U_DATE disp_ad0[0] -pin U_DISPLAY disp_ad0[0]
netloc disp_ad0[1] 1 8 1 8570 4430n
load net disp_ad0[2] -attr @rip(#000000) blink_tog_reg[0] -pin U_FSM_SET blink_tog_reg[0] -pin U_RTC Q[6]_i_4_0[0]
load net disp_ad0[3] -attr @rip(#000000) blink_tog_reg[1] -pin U_DISPLAY disp_ad0[1] -pin U_FSM_SET blink_tog_reg[1]
load net disp_ad1[1] -attr @rip(#000000) SW[14][0] -pin U_DISPLAY disp_ad1[0] -pin U_RTC SW[14][0]
load net disp_ad1[3] -attr @rip(#000000) year_reg[6][0] -pin U_DISPLAY disp_ad1[1] -pin U_FSM_SET year_reg[6][0]
load net disp_ad3[1] -attr @rip(#000000) disp_ad3[0] -pin U_DATE disp_ad3[0] -pin U_DISPLAY disp_ad3[0]
load net disp_ad3[2] -attr @rip(#000000) disp_ad3[1] -pin U_DATE disp_ad3[1] -pin U_RTC disp_ad3[0]
load net disp_bd0[3] -attr @rip(#000000) disp_bd0[0] -pin U_DATE disp_bd0[0] -pin U_DISPLAY disp_bd0[0] -pin U_FSM_SET disp_bd0[0]
netloc disp_bd0[3] 1 6 3 5460J 4970 7430 5650 NJ
load net disp_bd2[0] -attr @rip(#000000) day_reg[0][0] -pin U_DATE Q[6]_i_3[0] -pin U_FSM_SET day_reg[0][0]
netloc disp_bd2[0] 1 6 2 4960 4230 NJ
load net hht_sig[1] -attr @rip(#000000) hht_sig[0] -pin U_DATE hht_sig[0] -pin U_FSM_SET hht_sig[0] -pin U_RTC hht_sig[0]
netloc hht_sig[1] 1 5 3 4110 5310 NJ 5310 7050
load net hhu_sig[2] -attr @rip(#000000) hhu_sig[0] -pin U_DATE hhu_sig[0] -pin U_FSM_SET hhu_sig[0] -pin U_RTC hhu_sig[0]
load net hhu_sig[3] -attr @rip(#000000) hhu_sig[1] -pin U_DATE hhu_sig[1] -pin U_FSM_SET hhu_sig[1] -pin U_RTC hhu_sig[1]
load net mmt_sig[0] -attr @rip(#000000) mmt_sig[0] -pin U_DATE mmt_sig[0] -pin U_FSM_SET mmt_sig[0] -pin U_RTC mmt_sig[0]
load net mmt_sig[1] -attr @rip(#000000) mmt_sig[1] -pin U_DATE mmt_sig[1] -pin U_FSM_SET mmt_sig[1] -pin U_RTC mmt_sig[1]
load net mmt_sig[2] -attr @rip(#000000) mmt_sig[2] -pin U_DATE mmt_sig[2] -pin U_FSM_SET mmt_sig[2] -pin U_RTC mmt_sig[2]
load net mmu_sig[1] -attr @rip(#000000) min_reg[3]_0[0] -pin U_DISPLAY mmu_sig[0] -pin U_RTC min_reg[3]_0[0]
load net mmu_sig[3] -attr @rip(#000000) min_reg[3]_0[1] -pin U_DATE mmu_sig[0] -pin U_RTC min_reg[3]_0[1]
load net ms_cnt_reg_n_0_[0] -attr @rip(#000000) 0 -pin U_PROTOCOL ms_cnt_reg[7]_0[0] -pin ms_cnt_reg[0] Q
load net ms_cnt_reg_n_0_[1] -attr @rip(#000000) 1 -pin U_PROTOCOL ms_cnt_reg[7]_0[1] -pin ms_cnt_reg[1] Q
load net ms_cnt_reg_n_0_[2] -attr @rip(#000000) 2 -pin U_PROTOCOL ms_cnt_reg[7]_0[2] -pin ms_cnt_reg[2] Q
load net ms_cnt_reg_n_0_[3] -attr @rip(#000000) 3 -pin U_PROTOCOL ms_cnt_reg[7]_0[3] -pin ms_cnt_reg[3] Q
load net ms_cnt_reg_n_0_[4] -attr @rip(#000000) 4 -pin U_PROTOCOL ms_cnt_reg[7]_0[4] -pin ms_cnt_reg[4] Q
load net ms_cnt_reg_n_0_[5] -attr @rip(#000000) 5 -pin U_PROTOCOL ms_cnt_reg[7]_0[5] -pin ms_cnt_reg[5] Q
load net ms_cnt_reg_n_0_[6] -attr @rip(#000000) 6 -pin U_PROTOCOL ms_cnt_reg[7]_0[6] -pin ms_cnt_reg[6] Q
load net ms_cnt_reg_n_0_[7] -attr @rip(#000000) 7 -pin U_PROTOCOL ms_cnt_reg[7]_0[7] -pin ms_cnt_reg[7] Q
load net mtu_sig[2] -attr @rip(#000000) mtu_sig[0] -pin U_DATE mtu_sig[0] -pin U_FSM_SET mtu_sig[0]
netloc mtu_sig[2] 1 5 4 4250 5390 NJ 5390 NJ 5390 8190
load net p_1_in[0] -attr @rip(#000000) ms_cnt_reg[7][0] -pin U_PROTOCOL ms_cnt_reg[7][0] -pin ms_cnt_reg[0] D
load net p_1_in[1] -attr @rip(#000000) ms_cnt_reg[7][1] -pin U_PROTOCOL ms_cnt_reg[7][1] -pin ms_cnt_reg[1] D
load net p_1_in[2] -attr @rip(#000000) ms_cnt_reg[7][2] -pin U_PROTOCOL ms_cnt_reg[7][2] -pin ms_cnt_reg[2] D
load net p_1_in[5] -attr @rip(#000000) ms_cnt_reg[7][5] -pin U_PROTOCOL ms_cnt_reg[7][5] -pin ms_cnt_reg[5] D
load net p_1_in[7] -attr @rip(#000000) ms_cnt_reg[7][7] -pin U_PROTOCOL ms_cnt_reg[7][7] -pin ms_cnt_reg[7] D
load net p_1_in_0[0] -attr @rip(#000000) set_date_en_reg_0[0] -pin U_DATE month_reg[3]_5[0] -pin U_PROTOCOL set_date_en_reg_0[0]
load net p_1_in_0[1] -attr @rip(#000000) set_date_en_reg_0[1] -pin U_DATE month_reg[3]_5[1] -pin U_PROTOCOL set_date_en_reg_0[1]
load net p_1_in_0[2] -attr @rip(#000000) set_date_en_reg_0[2] -pin U_DATE month_reg[3]_5[2] -pin U_PROTOCOL set_date_en_reg_0[2]
load net p_1_in_0[3] -attr @rip(#000000) set_date_en_reg_0[3] -pin U_DATE month_reg[3]_5[3] -pin U_PROTOCOL set_date_en_reg_0[3]
load net p_1_in_1[0] -attr @rip(#000000) out_hr_reg[3]_0[0] -pin U_PROTOCOL out_hr_reg[3]_0[0] -pin U_RTC D[0]
load net p_1_in_1[1] -attr @rip(#000000) out_hr_reg[3]_0[1] -pin U_PROTOCOL out_hr_reg[3]_0[1] -pin U_RTC D[1]
load net p_1_in_1[3] -attr @rip(#000000) out_hr_reg[3]_0[2] -pin U_PROTOCOL out_hr_reg[3]_0[2] -pin U_RTC D[2]
load net pc_al_hr[0] -attr @rip(#000000) 0 -pin U_PROTOCOL tx_buf_reg[5][4]_0[0] -pin U_RTC prev_alarm_ringing_i_6_0[0] -pin pc_al_hr_reg[0] Q
load net pc_al_hr[1] -attr @rip(#000000) 1 -pin U_PROTOCOL tx_buf_reg[5][4]_0[1] -pin U_RTC prev_alarm_ringing_i_6_0[1] -pin pc_al_hr_reg[1] Q
load net pc_al_hr[2] -attr @rip(#000000) 2 -pin U_PROTOCOL tx_buf_reg[5][4]_0[2] -pin U_RTC prev_alarm_ringing_i_6_0[2] -pin pc_al_hr_reg[2] Q
load net pc_al_hr[3] -attr @rip(#000000) 3 -pin U_PROTOCOL tx_buf_reg[5][4]_0[3] -pin U_RTC prev_alarm_ringing_i_6_0[3] -pin pc_al_hr_reg[3] Q
load net pc_al_hr[4] -attr @rip(#000000) 4 -pin U_PROTOCOL tx_buf_reg[5][4]_0[4] -pin U_RTC prev_alarm_ringing_i_6_0[4] -pin pc_al_hr_reg[4] Q
load net pc_al_min[0] -attr @rip(#000000) 0 -pin U_PROTOCOL tx_buf_reg[4][5]_1[0] -pin pc_al_min_reg[0] Q
load net pc_al_min[1] -attr @rip(#000000) 1 -pin U_PROTOCOL tx_buf_reg[4][5]_1[1] -pin pc_al_min_reg[1] Q
load net pc_al_min[2] -attr @rip(#000000) 2 -pin U_PROTOCOL tx_buf_reg[4][5]_1[2] -pin pc_al_min_reg[2] Q
load net pc_al_min[3] -pin U_PROTOCOL tx_buf_reg[4][5]_1[3] -pin U_RTC prev_alarm_ringing_i_7_0[0] -pin pc_al_min_reg[3] Q
load net pc_al_min[4] -pin U_PROTOCOL tx_buf_reg[4][5]_1[4] -pin U_RTC prev_alarm_ringing_i_7_0[1] -pin pc_al_min_reg[4] Q
load net pc_al_min[5] -pin U_PROTOCOL tx_buf_reg[4][5]_1[5] -pin U_RTC prev_alarm_ringing_i_7_0[2] -pin pc_al_min_reg[5] Q
load net pc_al_sec[0] -attr @rip(#000000) 0 -pin U_PROTOCOL tx_buf_reg[3][5]_0[0] -pin pc_al_sec_reg[0] Q
load net pc_al_sec[1] -attr @rip(#000000) 1 -pin U_PROTOCOL tx_buf_reg[3][5]_0[1] -pin pc_al_sec_reg[1] Q
load net pc_al_sec[2] -attr @rip(#000000) 2 -pin U_PROTOCOL tx_buf_reg[3][5]_0[2] -pin pc_al_sec_reg[2] Q
load net pc_al_sec[3] -pin U_PROTOCOL tx_buf_reg[3][5]_0[3] -pin U_RTC prev_alarm_ringing_i_5_0[0] -pin pc_al_sec_reg[3] Q
load net pc_al_sec[4] -pin U_PROTOCOL tx_buf_reg[3][5]_0[4] -pin U_RTC prev_alarm_ringing_i_5_0[1] -pin pc_al_sec_reg[4] Q
load net pc_al_sec[5] -pin U_PROTOCOL tx_buf_reg[3][5]_0[5] -pin U_RTC prev_alarm_ringing_i_5_0[2] -pin pc_al_sec_reg[5] Q
load net pc_baud_sel_sig -pin U_BAUD pc_baud_sel_sig -pin U_PROTOCOL pc_baud_sel_sig
netloc pc_baud_sel_sig 1 2 4 580 5400 950J 5460 1620J 5520 2990
load net prev_alarm_ringing -pin U_PROTOCOL prev_alarm_ringing -pin U_RTC prev_alarm_ringing
netloc prev_alarm_ringing 1 5 2 3650 3410 4940J
load net pulse_dn -pin U_DEB_DN btn_pulse -pin U_FSM_SET month_reg[3] -pin U_PROTOCOL alarm_en_state_reg
netloc pulse_dn 1 4 2 2060 4840 3890
load net pulse_l -pin U_DEB_L btn_pulse -pin U_FSM_SET btn_pulse
netloc pulse_l 1 5 1 3950 4230n
load net pulse_r -pin U_DEB_L current_sel_reg[0] -pin U_DEB_R btn_pulse -pin U_FSM_SET current_sel_reg[2]_1
netloc pulse_r 1 4 2 1640 5260 3070
load net pulse_up -pin U_DATE btn_pulse -pin U_DEB_DN sec_reg[5] -pin U_DEB_UP btn_pulse -pin U_FSM_SET month_reg[3]_0 -pin U_PROTOCOL btn_pulse -pin U_RTC btn_pulse
netloc pulse_up 1 3 5 1050 4720 1960 4450 3850 5010 5700 4490 NJ
load net rx_clean -pin U_RX rx_clean -pin U_SYNC rx_clean
netloc rx_clean 1 3 1 930 3790n
load net rx_data_sig[0] -attr @rip(#000000) dout[0] -pin U_PROTOCOL payload_buf_reg[3][7]_0[0] -pin U_RX dout[0]
load net rx_data_sig[1] -attr @rip(#000000) dout[1] -pin U_PROTOCOL payload_buf_reg[3][7]_0[1] -pin U_RX dout[1]
load net rx_data_sig[2] -attr @rip(#000000) dout[2] -pin U_PROTOCOL payload_buf_reg[3][7]_0[2] -pin U_RX dout[2]
load net rx_data_sig[3] -attr @rip(#000000) dout[3] -pin U_PROTOCOL payload_buf_reg[3][7]_0[3] -pin U_RX dout[3]
load net rx_data_sig[4] -attr @rip(#000000) dout[4] -pin U_PROTOCOL payload_buf_reg[3][7]_0[4] -pin U_RX dout[4]
load net rx_data_sig[5] -attr @rip(#000000) dout[5] -pin U_PROTOCOL payload_buf_reg[3][7]_0[5] -pin U_RX dout[5]
load net rx_data_sig[6] -attr @rip(#000000) dout[6] -pin U_PROTOCOL payload_buf_reg[3][7]_0[6] -pin U_RX dout[6]
load net rx_data_sig[7] -attr @rip(#000000) dout[7] -pin U_PROTOCOL payload_buf_reg[3][7]_0[7] -pin U_RX dout[7]
load net rx_done_sig -pin U_PROTOCOL rx_done -pin U_RX rx_done
netloc rx_done_sig 1 4 1 1880 3290n
load net sel_state[0] -attr @rip(#000000) current_sel_reg[0]_0[0] -pin U_DEB_L sel_state[0] -pin U_FSM_SET current_sel_reg[0]_0[0]
netloc sel_state[0] 1 4 3 2440 5500 3130J 5610 4760
load net sst_sig[0] -attr @rip(#000000) sst_sig[0] -pin U_DATE sst_sig[0] -pin U_FSM_SET sst_sig[0] -pin U_RTC sst_sig[0]
load net sst_sig[1] -attr @rip(#000000) sst_sig[1] -pin U_FSM_SET sst_sig[1] -pin U_RTC sst_sig[1]
load net sst_sig[2] -attr @rip(#000000) sst_sig[2] -pin U_FSM_SET sst_sig[2] -pin U_RTC sst_sig[2]
load net ssu_sig[1] -attr @rip(#000000) ssu_sig[0] -pin U_FSM_SET ssu_sig[0] -pin U_RTC ssu_sig[0]
load net ssu_sig[2] -attr @rip(#000000) ssu_sig[1] -pin U_FSM_SET ssu_sig[1] -pin U_RTC ssu_sig[1]
load net ssu_sig[3] -attr @rip(#000000) ssu_sig[2] -pin U_FSM_SET ssu_sig[2] -pin U_RTC ssu_sig[2]
load net state[0] -attr @rip(#000000) Q[0] -pin U_PROTOCOL Q[0] -pin U_RX Q[0]
load net state[1] -attr @rip(#000000) Q[1] -pin U_PROTOCOL Q[1] -pin U_RX Q[1]
load net status_byte_sig[3] -attr @rip(#000000) status_byte_sig[0] -pin U_ALARM status_byte_sig[0] -pin U_PROTOCOL status_byte_sig[0] -pin U_RTC status_byte_sig[0]
netloc status_byte_sig[3] 1 4 5 2080 4820 3570J 5030 4940J 5090 7110 5830 NJ
load net tick_1ms -pin U_CLOCK CE_1ms -pin U_DISPLAY CE_1ms -pin U_PROTOCOL CE_1ms
netloc tick_1ms 1 4 5 1780 5200 3150J 5590 4800J 5650 6790J 5710 8490
load net tick_1s -pin U_ALARM CE_1s -pin U_CLOCK CE_1s -pin U_FSM_SET CE_1s -pin U_RTC CE_1s
netloc tick_1s 1 4 5 NJ 5220 3210 5090 4900 5770 NJ 5770 NJ
load net tick_uart -pin U_BAUD tick_x16 -pin U_RX tick_x16 -pin U_TX tick_x16
netloc tick_uart 1 3 1 1030 3810n
load net tx_busy_sig -pin U_PROTOCOL tx_busy_sig -pin U_TX tx_busy_sig
netloc tx_busy_sig 1 4 1 2040 3770n
load net tx_data_sig[0] -attr @rip(#000000) tx_data_reg[6]_0[0] -pin U_PROTOCOL tx_data_reg[6]_0[0] -pin U_TX din[0]
load net tx_data_sig[1] -attr @rip(#000000) tx_data_reg[6]_0[1] -pin U_PROTOCOL tx_data_reg[6]_0[1] -pin U_TX din[1]
load net tx_data_sig[2] -attr @rip(#000000) tx_data_reg[6]_0[2] -pin U_PROTOCOL tx_data_reg[6]_0[2] -pin U_TX din[2]
load net tx_data_sig[3] -attr @rip(#000000) tx_data_reg[6]_0[3] -pin U_PROTOCOL tx_data_reg[6]_0[3] -pin U_TX din[3]
load net tx_data_sig[4] -attr @rip(#000000) tx_data_reg[6]_0[4] -pin U_PROTOCOL tx_data_reg[6]_0[4] -pin U_TX din[4]
load net tx_data_sig[5] -attr @rip(#000000) tx_data_reg[6]_0[5] -pin U_PROTOCOL tx_data_reg[6]_0[5] -pin U_TX din[5]
load net tx_data_sig[6] -attr @rip(#000000) tx_data_reg[6]_0[6] -pin U_PROTOCOL tx_data_reg[6]_0[6] -pin U_TX din[6]
load net tx_start_sig -pin U_PROTOCOL tx_start_sig -pin U_TX tx_start_sig
netloc tx_start_sig 1 3 3 1150 5730 NJ 5730 3090
load net uart_al_hr[0] -attr @rip(#000000) out_al_hr_reg[4]_0[0] -pin U_PROTOCOL out_al_hr_reg[4]_0[0] -pin pc_al_hr_reg[0] D
load net uart_al_hr[1] -attr @rip(#000000) out_al_hr_reg[4]_0[1] -pin U_PROTOCOL out_al_hr_reg[4]_0[1] -pin pc_al_hr_reg[1] D
load net uart_al_hr[2] -attr @rip(#000000) out_al_hr_reg[4]_0[2] -pin U_PROTOCOL out_al_hr_reg[4]_0[2] -pin pc_al_hr_reg[2] D
load net uart_al_hr[3] -attr @rip(#000000) out_al_hr_reg[4]_0[3] -pin U_PROTOCOL out_al_hr_reg[4]_0[3] -pin pc_al_hr_reg[3] D
load net uart_al_hr[4] -attr @rip(#000000) out_al_hr_reg[4]_0[4] -pin U_PROTOCOL out_al_hr_reg[4]_0[4] -pin pc_al_hr_reg[4] D
load net uart_al_min[0] -attr @rip(#000000) out_al_min_reg[5]_0[0] -pin U_PROTOCOL out_al_min_reg[5]_0[0] -pin pc_al_min_reg[0] D
load net uart_al_min[1] -attr @rip(#000000) out_al_min_reg[5]_0[1] -pin U_PROTOCOL out_al_min_reg[5]_0[1] -pin pc_al_min_reg[1] D
load net uart_al_min[2] -attr @rip(#000000) out_al_min_reg[5]_0[2] -pin U_PROTOCOL out_al_min_reg[5]_0[2] -pin pc_al_min_reg[2] D
load net uart_al_min[3] -attr @rip(#000000) out_al_min_reg[5]_0[3] -pin U_PROTOCOL out_al_min_reg[5]_0[3] -pin pc_al_min_reg[3] D
load net uart_al_min[4] -attr @rip(#000000) out_al_min_reg[5]_0[4] -pin U_PROTOCOL out_al_min_reg[5]_0[4] -pin pc_al_min_reg[4] D
load net uart_al_min[5] -attr @rip(#000000) out_al_min_reg[5]_0[5] -pin U_PROTOCOL out_al_min_reg[5]_0[5] -pin pc_al_min_reg[5] D
load net uart_al_sec[0] -attr @rip(#000000) out_al_sec_reg[5]_0[0] -pin U_PROTOCOL out_al_sec_reg[5]_0[0] -pin pc_al_sec_reg[0] D
load net uart_al_sec[1] -attr @rip(#000000) out_al_sec_reg[5]_0[1] -pin U_PROTOCOL out_al_sec_reg[5]_0[1] -pin pc_al_sec_reg[1] D
load net uart_al_sec[2] -attr @rip(#000000) out_al_sec_reg[5]_0[2] -pin U_PROTOCOL out_al_sec_reg[5]_0[2] -pin pc_al_sec_reg[2] D
load net uart_al_sec[3] -attr @rip(#000000) out_al_sec_reg[5]_0[3] -pin U_PROTOCOL out_al_sec_reg[5]_0[3] -pin pc_al_sec_reg[3] D
load net uart_al_sec[4] -attr @rip(#000000) out_al_sec_reg[5]_0[4] -pin U_PROTOCOL out_al_sec_reg[5]_0[4] -pin pc_al_sec_reg[4] D
load net uart_al_sec[5] -attr @rip(#000000) out_al_sec_reg[5]_0[5] -pin U_PROTOCOL out_al_sec_reg[5]_0[5] -pin pc_al_sec_reg[5] D
load net uart_day_sig[0] -attr @rip(#000000) out_day_reg[4]_0[0] -pin U_DATE day_reg[4]_2[0] -pin U_PROTOCOL out_day_reg[4]_0[0]
load net uart_day_sig[1] -attr @rip(#000000) out_day_reg[4]_0[1] -pin U_DATE day_reg[4]_2[1] -pin U_PROTOCOL out_day_reg[4]_0[1]
load net uart_day_sig[2] -attr @rip(#000000) out_day_reg[4]_0[2] -pin U_DATE day_reg[4]_2[2] -pin U_PROTOCOL out_day_reg[4]_0[2]
load net uart_day_sig[3] -attr @rip(#000000) out_day_reg[4]_0[3] -pin U_DATE day_reg[4]_2[3] -pin U_PROTOCOL out_day_reg[4]_0[3]
load net uart_day_sig[4] -attr @rip(#000000) out_day_reg[4]_0[4] -pin U_DATE day_reg[4]_2[4] -pin U_PROTOCOL out_day_reg[4]_0[4]
load net uart_hr_sig[2] -attr @rip(#000000) out_hr_reg[4]_0[0] -pin U_PROTOCOL out_hr_reg[4]_0[0] -pin U_RTC hr_reg[4]_3[0]
load net uart_hr_sig[4] -attr @rip(#000000) out_hr_reg[4]_0[1] -pin U_PROTOCOL out_hr_reg[4]_0[1] -pin U_RTC hr_reg[4]_3[1]
load net uart_min_sig[3] -attr @rip(#000000) out_min_reg[5]_0[0] -pin U_PROTOCOL out_min_reg[5]_0[0] -pin U_RTC min_reg[5]_1[0]
load net uart_min_sig[4] -attr @rip(#000000) out_min_reg[5]_0[1] -pin U_PROTOCOL out_min_reg[5]_0[1] -pin U_RTC min_reg[5]_1[1]
load net uart_min_sig[5] -attr @rip(#000000) out_min_reg[5]_0[2] -pin U_PROTOCOL out_min_reg[5]_0[2] -pin U_RTC min_reg[5]_1[2]
load net uart_sec_sig[1] -attr @rip(#000000) out_sec_reg[5]_0[0] -pin U_PROTOCOL out_sec_reg[5]_0[0] -pin U_RTC sec_reg[5]_2[0]
load net uart_sec_sig[3] -attr @rip(#000000) out_sec_reg[5]_0[1] -pin U_PROTOCOL out_sec_reg[5]_0[1] -pin U_RTC sec_reg[5]_2[1]
load net uart_sec_sig[4] -attr @rip(#000000) out_sec_reg[5]_0[2] -pin U_PROTOCOL out_sec_reg[5]_0[2] -pin U_RTC sec_reg[5]_2[2]
load net uart_sec_sig[5] -attr @rip(#000000) out_sec_reg[5]_0[3] -pin U_PROTOCOL out_sec_reg[5]_0[3] -pin U_RTC sec_reg[5]_2[3]
load net uart_set_al_en -attr @rip(#000000) E[0] -pin U_PROTOCOL E[0] -pin pc_al_hr_reg[0] CE -pin pc_al_hr_reg[1] CE -pin pc_al_hr_reg[2] CE -pin pc_al_hr_reg[3] CE -pin pc_al_hr_reg[4] CE -pin pc_al_min_reg[0] CE -pin pc_al_min_reg[1] CE -pin pc_al_min_reg[2] CE -pin pc_al_min_reg[3] CE -pin pc_al_min_reg[4] CE -pin pc_al_min_reg[5] CE -pin pc_al_sec_reg[0] CE -pin pc_al_sec_reg[1] CE -pin pc_al_sec_reg[2] CE -pin pc_al_sec_reg[3] CE -pin pc_al_sec_reg[4] CE -pin pc_al_sec_reg[5] CE
netloc uart_set_al_en 1 3 3 1090 5100 NJ 5100 3010
load net uart_set_date_en_sig -pin U_DATE uart_set_date_en_sig -pin U_FSM_SET uart_set_date_en_sig -pin U_PROTOCOL uart_set_date_en_sig
netloc uart_set_date_en_sig 1 5 3 3550 5430 NJ 5430 7330
load net uart_set_en_sig -pin U_FSM_SET uart_set_en_sig -pin U_PROTOCOL uart_set_en_sig -pin U_RTC uart_set_en_sig
netloc uart_set_en_sig 1 5 2 3510 5450 5600
load net uart_year_sig[2] -attr @rip(#000000) out_year_reg[6]_0[0] -pin U_DATE year_reg[6]_4[0] -pin U_PROTOCOL out_year_reg[6]_0[0]
load net uart_year_sig[3] -attr @rip(#000000) out_year_reg[6]_0[1] -pin U_DATE year_reg[6]_4[1] -pin U_PROTOCOL out_year_reg[6]_0[1]
load net uart_year_sig[4] -attr @rip(#000000) out_year_reg[6]_0[2] -pin U_DATE year_reg[6]_4[2] -pin U_PROTOCOL out_year_reg[6]_0[2]
load net uart_year_sig[6] -attr @rip(#000000) out_year_reg[6]_0[3] -pin U_DATE year_reg[6]_4[3] -pin U_PROTOCOL out_year_reg[6]_0[3]
load net yyt_sig[0] -attr @rip(#000000) yyt_sig[0] -pin U_DATE yyt_sig[0] -pin U_FSM_SET yyt_sig[0]
load net yyt_sig[1] -attr @rip(#000000) yyt_sig[1] -pin U_DATE yyt_sig[1] -pin U_FSM_SET yyt_sig[1] -pin U_RTC yyt_sig[0]
load net yyt_sig[3] -attr @rip(#000000) yyt_sig[2] -pin U_DATE yyt_sig[2] -pin U_FSM_SET yyt_sig[2]
load net yyu_sig[2] -attr @rip(#000000) yyu_sig[0] -pin U_DATE yyu_sig[0] -pin U_FSM_SET yyu_sig[0]
load net yyu_sig[3] -attr @rip(#000000) yyu_sig[1] -pin U_DATE yyu_sig[1] -pin U_FSM_SET yyu_sig[1]
load netBundle @SW 16 SW[15] SW[14] SW[13] SW[12] SW[11] SW[10] SW[9] SW[8] SW[7] SW[6] SW[5] SW[4] SW[3] SW[2] SW[1] SW[0] -autobundled
netbloc @SW 1 0 2 NJ 6160 220
load netBundle @AN 8 AN[7] AN[6] AN[5] AN[4] AN[3] AN[2] AN[1] AN[0] -autobundled
netbloc @AN 1 10 1 9280 5000n
load netBundle @LED_RGB 3 LED_RGB[2] LED_RGB[1] LED_RGB[0] -autobundled
netbloc @LED_RGB 1 10 1 9280 5560n
load netBundle @SEG 7 SEG[6] SEG[5] SEG[4] SEG[3] SEG[2] SEG[1] SEG[0] -autobundled
netbloc @SEG 1 10 1 9280 5770n
load netBundle @LED_RGB_OBUF 3 LED_RGB_OBUF[2] LED_RGB_OBUF[1] LED_RGB_OBUF[0] -autobundled
netbloc @LED_RGB_OBUF 1 9 1 9060 5560n
load netBundle @cur_month_sig 4 cur_month_sig[3] cur_month_sig[2] cur_month_sig[1] cur_month_sig[0] -autobundled
netbloc @cur_month_sig 1 4 5 2260 4110 4010 4990 5420 4870 7550J 4970 8330
load netBundle @cur_day_sig 5 cur_day_sig[4] cur_day_sig[3] cur_day_sig[2] cur_day_sig[1] cur_day_sig[0] -autobundled
netbloc @cur_day_sig 1 4 5 2240 4130 4050 4930 6120 4850 7270J 4950 8150
load netBundle @ddt_sig 2 ddt_sig[1] ddt_sig[0] -autobundled
netbloc @ddt_sig 1 5 4 4070 5270 NJ 5270 NJ 5270 8390
load netBundle @ddu_sig 2 ddu_sig[3] ddu_sig[2] -autobundled
netbloc @ddu_sig 1 5 4 4090 5290 NJ 5290 NJ 5290 8350
load netBundle @disp_ad3 2 disp_ad3[2] disp_ad3[1] -autobundled
netbloc @disp_ad3 1 6 3 6240 5630 NJ 5630 8470
load netBundle @U_DATE_n_ 2 U_DATE_n_21 U_DATE_n_22 -autobundled
netbloc @U_DATE_n_ 1 4 5 2140 4740 3790J 4750 5160J 5050 7090J 5110 8310
load netBundle @cur_year_sig 7 cur_year_sig[6] cur_year_sig[5] cur_year_sig[4] cur_year_sig[3] cur_year_sig[2] cur_year_sig[1] cur_year_sig[0] -autobundled
netbloc @cur_year_sig 1 4 5 2200 4170 3310 5050 5120 4910 7230J 5010 8250
load netBundle @yyt_sig 3 yyt_sig[3] yyt_sig[1] yyt_sig[0] -autobundled
netbloc @yyt_sig 1 5 4 4190 5510 5520 4950 7170J 5050 8130
load netBundle @yyu_sig 2 yyu_sig[3] yyu_sig[2] -autobundled
netbloc @yyu_sig 1 5 4 4230 5530 5660J 5490 7350J 5430 8170
load netBundle @AN_OBUF 8 AN_OBUF[7] AN_OBUF[6] AN_OBUF[5] AN_OBUF[4] AN_OBUF[3] AN_OBUF[2] AN_OBUF[1] AN_OBUF[0] -autobundled
netbloc @AN_OBUF 1 9 1 9040 5000n
load netBundle @SEG_OBUF 7 SEG_OBUF[6] SEG_OBUF[5] SEG_OBUF[4] SEG_OBUF[3] SEG_OBUF[2] SEG_OBUF[1] SEG_OBUF[0] -autobundled
netbloc @SEG_OBUF 1 9 1 9040 5510n
load netBundle @counter 2 counter[1] counter[0] -autobundled
netbloc @counter 1 5 5 4170 4850 5880 4510 7610 5690 8510J 5710 9020
load netBundle @disp_ad0 2 disp_ad0[3] disp_ad0[2] -autobundled
netbloc @disp_ad0 1 6 3 4860 5610 7470J 5590 8210J
load netBundle @U_PROTOCOL_n_ 2 U_PROTOCOL_n_15 U_PROTOCOL_n_16 -autobundled
netbloc @U_PROTOCOL_n_ 1 5 2 NJ 2930 4760
load netBundle @state 2 state[1] state[0] -autobundled
netbloc @state 1 3 3 1130 3890 1820J 4010 3070
load netBundle @al_hht 2 al_hht[1] al_hht[0] -autobundled
netbloc @al_hht 1 5 2 3510 3290 5080J
load netBundle @al_mmt 2 al_mmt[1] al_mmt[0] -autobundled
netbloc @al_mmt 1 5 2 3470 3310 5060J
load netBundle @al_mmu 4 al_mmu[3] al_mmu[2] al_mmu[1] al_mmu[0] -autobundled
netbloc @al_mmu 1 5 2 3390 3330 5040J
load netBundle @al_sst 2 al_sst[1] al_sst[0] -autobundled
netbloc @al_sst 1 5 2 4130 3350 5020J
load netBundle @p_1_in,U_PROTOCOL_n_ 8 p_1_in[7] U_PROTOCOL_n_67 p_1_in[5] U_PROTOCOL_n_69 U_PROTOCOL_n_70 p_1_in[2] p_1_in[1] p_1_in[0] -autobundled
netbloc @p_1_in,U_PROTOCOL_n_ 1 3 3 1190 1220 NJ 1220 3030
load netBundle @uart_al_hr 5 uart_al_hr[4] uart_al_hr[3] uart_al_hr[2] uart_al_hr[1] uart_al_hr[0] -autobundled
netbloc @uart_al_hr 1 3 3 1170 1980 NJ 1980 2970
load netBundle @uart_al_min 6 uart_al_min[5] uart_al_min[4] uart_al_min[3] uart_al_min[2] uart_al_min[1] uart_al_min[0] -autobundled
netbloc @uart_al_min 1 3 3 1130 3650 1980J 3970 3030
load netBundle @uart_al_sec 6 uart_al_sec[5] uart_al_sec[4] uart_al_sec[3] uart_al_sec[2] uart_al_sec[1] uart_al_sec[0] -autobundled
netbloc @uart_al_sec 1 3 3 1070 5120 NJ 5120 2970
load netBundle @uart_day_sig 5 uart_day_sig[4] uart_day_sig[3] uart_day_sig[2] uart_day_sig[1] uart_day_sig[0] -autobundled
netbloc @uart_day_sig 1 5 3 3770 5110 NJ 5110 7070J
load netBundle @p_1_in_1 3 p_1_in_1[3] p_1_in_1[1] p_1_in_1[0] -autobundled
netbloc @p_1_in_1 1 5 2 3410J 3090 4860
load netBundle @uart_hr_sig 2 uart_hr_sig[4] uart_hr_sig[2] -autobundled
netbloc @uart_hr_sig 1 5 2 3630 4790 6020J
load netBundle @U_PROTOCOL_n__1 3 U_PROTOCOL_n_21 U_PROTOCOL_n_22 U_PROTOCOL_n_23 -autobundled
netbloc @U_PROTOCOL_n__1 1 5 2 3450 3390 4980J
load netBundle @uart_min_sig 3 uart_min_sig[5] uart_min_sig[4] uart_min_sig[3] -autobundled
netbloc @uart_min_sig 1 5 2 3590 4810 6040J
load netBundle @uart_sec_sig 4 uart_sec_sig[5] uart_sec_sig[4] uart_sec_sig[3] uart_sec_sig[1] -autobundled
netbloc @uart_sec_sig 1 5 2 3270 5070 4980J
load netBundle @U_PROTOCOL_n__2 3 U_PROTOCOL_n_32 U_PROTOCOL_n_33 U_PROTOCOL_n_34 -autobundled
netbloc @U_PROTOCOL_n__2 1 5 3 3330 3710 5340J 4830 7290J
load netBundle @uart_year_sig 4 uart_year_sig[6] uart_year_sig[4] uart_year_sig[3] uart_year_sig[2] -autobundled
netbloc @uart_year_sig 1 5 3 3690 5250 NJ 5250 7530J
load netBundle @p_1_in_0 4 p_1_in_0[3] p_1_in_0[2] p_1_in_0[1] p_1_in_0[0] -autobundled
netbloc @p_1_in_0 1 5 3 3290 5210 NJ 5210 7210J
load netBundle @tx_data_sig 7 tx_data_sig[6] tx_data_sig[5] tx_data_sig[4] tx_data_sig[3] tx_data_sig[2] tx_data_sig[1] tx_data_sig[0] -autobundled
netbloc @tx_data_sig 1 3 3 1190 5710 NJ 5710 3110
load netBundle @cur_hr_sig 5 cur_hr_sig[4] cur_hr_sig[3] cur_hr_sig[2] cur_hr_sig[1] cur_hr_sig[0] -autobundled
netbloc @cur_hr_sig 1 4 4 2220 4150 3990 5130 NJ 5130 7010
load netBundle @hhu_sig 2 hhu_sig[3] hhu_sig[2] -autobundled
netbloc @hhu_sig 1 5 3 4130 5330 NJ 5330 7030
load netBundle @mmu_sig 2 mmu_sig[3] mmu_sig[1] -autobundled
netbloc @mmu_sig 1 7 2 7250 5670 8650J
load netBundle @cur_min_sig 6 cur_min_sig[5] cur_min_sig[4] cur_min_sig[3] cur_min_sig[2] cur_min_sig[1] cur_min_sig[0] -autobundled
netbloc @cur_min_sig 1 4 4 2280 4090 3970 5150 NJ 5150 6950
load netBundle @mmt_sig 3 mmt_sig[2] mmt_sig[1] mmt_sig[0] -autobundled
netbloc @mmt_sig 1 5 3 4330 5190 NJ 5190 6990
load netBundle @cur_sec_sig 6 cur_sec_sig[5] cur_sec_sig[4] cur_sec_sig[3] cur_sec_sig[2] cur_sec_sig[1] cur_sec_sig[0] -autobundled
netbloc @cur_sec_sig 1 4 4 2180 4190 3130 5170 NJ 5170 6930
load netBundle @sst_sig 3 sst_sig[2] sst_sig[1] sst_sig[0] -autobundled
netbloc @sst_sig 1 5 3 4310 5230 NJ 5230 6970
load netBundle @ssu_sig 3 ssu_sig[3] ssu_sig[2] ssu_sig[1] -autobundled
netbloc @ssu_sig 1 5 3 4210 5410 NJ 5410 6830
load netBundle @U_RTC_n_ 4 U_RTC_n_20 U_RTC_n_21 U_RTC_n_22 U_RTC_n_23 -autobundled
netbloc @U_RTC_n_ 1 4 4 2300 3950 3930J 3630 6060J 4130 6750
load netBundle @rx_data_sig 8 rx_data_sig[7] rx_data_sig[6] rx_data_sig[5] rx_data_sig[4] rx_data_sig[3] rx_data_sig[2] rx_data_sig[1] rx_data_sig[0] -autobundled
netbloc @rx_data_sig 1 4 1 1760 3230n
load netBundle @disp_ad1 2 disp_ad1[3] disp_ad1[1] -autobundled
netbloc @disp_ad1 1 6 3 5440J 4990 7490 5610 NJ
load netBundle @SW_IBUF 16 SW_IBUF[15] SW_IBUF[14] SW_IBUF[13] SW_IBUF[12] SW_IBUF[11] SW_IBUF[10] SW_IBUF[9] SW_IBUF[8] SW_IBUF[7] SW_IBUF[6] SW_IBUF[5] SW_IBUF[4] SW_IBUF[3] SW_IBUF[2] SW_IBUF[1] SW_IBUF[0] -autobundled
netbloc @SW_IBUF 1 2 6 480 5890 NJ 5890 1940 5280 3930 4910 5100 4470 7710J
load netBundle @ms_cnt_reg_n_0_ 8 ms_cnt_reg_n_0_[7] ms_cnt_reg_n_0_[6] ms_cnt_reg_n_0_[5] ms_cnt_reg_n_0_[4] ms_cnt_reg_n_0_[3] ms_cnt_reg_n_0_[2] ms_cnt_reg_n_0_[1] ms_cnt_reg_n_0_[0] -autobundled
netbloc @ms_cnt_reg_n_0_ 1 4 1 2040 80n
load netBundle @pc_al_sec 6 pc_al_sec[5] pc_al_sec[4] pc_al_sec[3] pc_al_sec[2] pc_al_sec[1] pc_al_sec[0] -autobundled
netbloc @pc_al_sec 1 4 3 1620 5080 3170J 5570 5140
load netBundle @pc_al_min 6 pc_al_min[5] pc_al_min[4] pc_al_min[3] pc_al_min[2] pc_al_min[1] pc_al_min[0] -autobundled
netbloc @pc_al_min 1 4 3 1900 4800 3230J 4890 4940
load netBundle @pc_al_hr 5 pc_al_hr[4] pc_al_hr[3] pc_al_hr[2] pc_al_hr[1] pc_al_hr[0] -autobundled
netbloc @pc_al_hr 1 4 3 2000 4780 3250J 4870 5400
levelinfo -pg 1 0 40 260 750 1360 2660 4500 6450 7880 8820 9100 9300
pagesize -pg 1 -db -bbox -sgen -130 0 9440 6800
show
fullfit
#
# initialize ictrl to current module Top_Level_RTC work:Top_Level_RTC:NOFILE
ictrl init topinfo |
