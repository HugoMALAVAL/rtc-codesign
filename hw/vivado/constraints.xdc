## -----------------------------------------------------------------------------
## Horloge système (100 MHz)
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { CLK100MHZ }];

## -----------------------------------------------------------------------------
## Boutons de Contrôle (Croix directionnelle + Reset)
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN N17    IOSTANDARD LVCMOS33 } [get_ports { RST_BTN }]; # BTNC (Reset)
set_property -dict { PACKAGE_PIN M18    IOSTANDARD LVCMOS33 } [get_ports { BTN_UP }];  # BTNU (+1 / Date)
set_property -dict { PACKAGE_PIN P18    IOSTANDARD LVCMOS33 } [get_ports { BTN_DN }];  # BTND (-1 / Toggle Alarme)
set_property -dict { PACKAGE_PIN P17    IOSTANDARD LVCMOS33 } [get_ports { BTN_L }];   # BTNL (Navigation Gauche)
set_property -dict { PACKAGE_PIN M17    IOSTANDARD LVCMOS33 } [get_ports { BTN_R }];   # BTNR (Navigation Droite)

## -----------------------------------------------------------------------------
## Communication Série (USB-UART Bridge)
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports { UART_RXD }];
set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports { UART_TXD }];

## -----------------------------------------------------------------------------
## Interrupteurs (SW) - Configuration Alarme & Réglages
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN J15    IOSTANDARD LVCMOS33 } [get_ports { SW[0] }];
set_property -dict { PACKAGE_PIN L16    IOSTANDARD LVCMOS33 } [get_ports { SW[1] }];
set_property -dict { PACKAGE_PIN M13    IOSTANDARD LVCMOS33 } [get_ports { SW[2] }];
set_property -dict { PACKAGE_PIN R15    IOSTANDARD LVCMOS33 } [get_ports { SW[3] }];
set_property -dict { PACKAGE_PIN R17    IOSTANDARD LVCMOS33 } [get_ports { SW[4] }];
set_property -dict { PACKAGE_PIN T18    IOSTANDARD LVCMOS33 } [get_ports { SW[5] }];
set_property -dict { PACKAGE_PIN U18    IOSTANDARD LVCMOS33 } [get_ports { SW[6] }];
set_property -dict { PACKAGE_PIN R13    IOSTANDARD LVCMOS33 } [get_ports { SW[7] }];
set_property -dict { PACKAGE_PIN T8     IOSTANDARD LVCMOS33 } [get_ports { SW[8] }]; 
set_property -dict { PACKAGE_PIN U8     IOSTANDARD LVCMOS33 } [get_ports { SW[9] }]; 
set_property -dict { PACKAGE_PIN R16    IOSTANDARD LVCMOS33 } [get_ports { SW[10] }];
set_property -dict { PACKAGE_PIN T13    IOSTANDARD LVCMOS33 } [get_ports { SW[11] }];
set_property -dict { PACKAGE_PIN H6     IOSTANDARD LVCMOS33 } [get_ports { SW[12] }];
set_property -dict { PACKAGE_PIN U12    IOSTANDARD LVCMOS33 } [get_ports { SW[13] }];
set_property -dict { PACKAGE_PIN U11    IOSTANDARD LVCMOS33 } [get_ports { SW[14] }]; # Mode Réglage
set_property -dict { PACKAGE_PIN V10    IOSTANDARD LVCMOS33 } [get_ports { SW[15] }]; # Aiguilleur PC (0) / Local (1)

## -----------------------------------------------------------------------------
## LED 15 - Statut de Communication
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN V11    IOSTANDARD LVCMOS33 } [get_ports { LED15 }]; # LED Verte - CRC OK

## -----------------------------------------------------------------------------
## LED RGB (LD16) - Animation Alarme
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN R12    IOSTANDARD LVCMOS33 } [get_ports { LED_RGB[0] }]; # Blue
set_property -dict { PACKAGE_PIN M16    IOSTANDARD LVCMOS33 } [get_ports { LED_RGB[1] }]; # Green
set_property -dict { PACKAGE_PIN N15    IOSTANDARD LVCMOS33 } [get_ports { LED_RGB[2] }]; # Red

## -----------------------------------------------------------------------------
## LED RGB (LD17) - Statut ON/OFF Alarme (NOUVEAU)
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN G14    IOSTANDARD LVCMOS33 } [get_ports { LED17_G }]; # Green part of LD17

## -----------------------------------------------------------------------------
## Afficheurs 7-Segments (Multiplexés)
## -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN T10    IOSTANDARD LVCMOS33 } [get_ports { SEG[0] }]; # CA
set_property -dict { PACKAGE_PIN R10    IOSTANDARD LVCMOS33 } [get_ports { SEG[1] }]; # CB
set_property -dict { PACKAGE_PIN K16    IOSTANDARD LVCMOS33 } [get_ports { SEG[2] }]; # CC
set_property -dict { PACKAGE_PIN K13    IOSTANDARD LVCMOS33 } [get_ports { SEG[3] }]; # CD
set_property -dict { PACKAGE_PIN P15    IOSTANDARD LVCMOS33 } [get_ports { SEG[4] }]; # CE
set_property -dict { PACKAGE_PIN T11    IOSTANDARD LVCMOS33 } [get_ports { SEG[5] }]; # CF
set_property -dict { PACKAGE_PIN L18    IOSTANDARD LVCMOS33 } [get_ports { SEG[6] }]; # CG

set_property -dict { PACKAGE_PIN J17    IOSTANDARD LVCMOS33 } [get_ports { AN[0] }];
set_property -dict { PACKAGE_PIN J18    IOSTANDARD LVCMOS33 } [get_ports { AN[1] }];
set_property -dict { PACKAGE_PIN T9     IOSTANDARD LVCMOS33 } [get_ports { AN[2] }];
set_property -dict { PACKAGE_PIN J14    IOSTANDARD LVCMOS33 } [get_ports { AN[3] }];
set_property -dict { PACKAGE_PIN P14    IOSTANDARD LVCMOS33 } [get_ports { AN[4] }];
set_property -dict { PACKAGE_PIN T14    IOSTANDARD LVCMOS33 } [get_ports { AN[5] }];
set_property -dict { PACKAGE_PIN K2     IOSTANDARD LVCMOS33 } [get_ports { AN[6] }];
set_property -dict { PACKAGE_PIN U13    IOSTANDARD LVCMOS33 } [get_ports { AN[7] }];