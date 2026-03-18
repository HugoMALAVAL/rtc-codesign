# Hardware Subsystem — `hw/`

Implémentation VHDL d'une horloge temps réel (RTC) pilotable par UART, ciblant la carte **Digilent Nexys A7-100T** (FPGA Xilinx Artix-7, horloge système 100 MHz).

---

## Table des matières

1. [Structure du répertoire](#1-structure-du-répertoire)
2. [Architecture générale](#2-architecture-générale)
3. [Modules RTL](#3-modules-rtl)
   - 3.1 [Sous-système UART](#31-sous-système-uart)
   - 3.2 [Sous-système RTC](#32-sous-système-rtc)
   - 3.3 [Protocole de communication](#33-protocole-de-communication)
   - 3.4 [Affichage et utilitaires](#34-affichage-et-utilitaires)
4. [Protocole de trame](#4-protocole-de-trame)
5. [Tableau de commandes](#5-tableau-de-commandes)
6. [Mapping des entrées/sorties](#6-mapping-des-entréessorties)
7. [Testbenches](#7-testbenches)
8. [Simulation sous Vivado](#8-simulation-sous-vivado)
9. [Synthèse et implémentation](#9-synthèse-et-implémentation)

---

## 1. Structure du répertoire

```
hw/
├── rtl/
│   ├── uart/
│   │   ├── baud_rate_gen.vhd       # Générateur de tempo (tick × 16)
│   │   ├── synchronizer.vhd        # Bouclier anti-métastabilité (2 FF)
│   │   ├── rx_uart.vhd             # Récepteur UART (FSM 4 états)
│   │   ├── tx_uart.vhd             # Émetteur UART (FSM 4 états)
│   │   └── uart_transceiver.vhd    # Wrapper transceiver standalone (test)
│   ├── rtc/
│   │   ├── clock_divider.vhd       # CE_1ms et CE_1s depuis 100 MHz
│   │   ├── rtc_time.vhd            # Compteur heure/minute/seconde
│   │   ├── rtc_date.vhd            # Compteur jour/mois/année (avec bissextile)
│   │   ├── rtc_alarm.vhd           # Comparateur d'alarme
│   │   ├── alarm_fsm.vhd           # FSM RGB : IDLE→RED→ROTATING→GREEN
│   │   ├── setting_fsm.vhd         # Navigation curseur mode réglage
│   │   ├── debouncer.vhd           # Anti-rebond (front montant unique)
│   │   └── debouncer_repeat.vhd    # Anti-rebond avec auto-répétition
│   ├── protocol/
│   │   └── protocol_decoder.vhd    # Décodeur de trame + CRC XOR
│   └── display/
│       ├── display.vhd             # Top affichage 7 segments (8 digits)
│       ├── clock_divider.vhd       # (partagé)
│       ├── counter_4b_E.vhd        # Compteur de balayage 4 bits
│       ├── mux_16x1x4bit.vhd       # Multiplexeur 12 entrées × 4 bits
│       ├── transcoder_7segs.vhd    # Transcodeur BCD → 7 segments
│       ├── transcoder_4v16.vhd     # Transcodeur binaire → anode active-low
│       ├── register_4b.vhd         # Registre 4 bits
│       ├── register_8b.vhd         # Registre 8 bits
│       └── Tregister_1b.vhd        # Bascule T (clignotement DP)
├── tb/
│   ├── uart_tb.vhd                 # Test UART niveau bit (uart_transceiver)
│   ├── rtc_tb.vhd                  # Test RTC : time + date
│   └── protocol_tb.vhd             # Test décodeur de protocole
├── vivado/
│   ├── project.xpr
│   ├── constraints.xdc
│   └── block_design/
└── README.md
```

---

## 2. Architecture générale

Le top-level `Top_Level_RTC` assemble tous les sous-modules en mode purement structurel.

```
Top_Level_RTC
├── U_CLOCK      clock_divider          CE_1ms, CE_1s
├── U_DEB_UP     debouncer_repeat       BTN_UP (anti-rebond + auto-repeat)
├── U_DEB_DN     debouncer_repeat       BTN_DN
├── U_DEB_L      debouncer              BTN_L  (front unique)
├── U_DEB_R      debouncer              BTN_R
├── U_FSM_SET    setting_fsm            Curseur réglage (0=HR … 5=YR)
├── U_BAUD       baud_rate_gen          Tick × 16 (baud_sel depuis PC)
├── U_SYNC       synchronizer           Anti-métastabilité sur RXD
├── U_RX         rx_uart                Réception octet UART
├── U_TX         tx_uart                Émission octet UART
├── U_PROTOCOL   protocol_decoder       Décodage trame + génération réponse
├── U_RTC        rtc_time               Horloge HH:MM:SS
├── U_DATE       rtc_date               Calendrier JJ/MM/AA
├── U_ALARM      rtc_alarm              Comparateur alarme + FSM RGB
│   └── AFSM     alarm_fsm
└── U_DISPLAY    display                Balayage 7 segments × 8 digits
    ├── U0       counter_4b_E
    ├── U1       transcoder_4v16
    ├── U2/U3    register_4b (× 2)
    ├── U5       mux_16x1x4bit
    ├── U6       transcoder_7segs
    ├── U7       register_8b
    └── U8       Tregister_1b
```

---

## 3. Modules RTL

### 3.1 Sous-système UART

| Module | Description |
|--------|-------------|
| `baud_rate_gen` | Génère un tick à 16 × le baud rate. Limite = 53 → **115 200 bauds** (`baud_sel='1'`) ; limite = 650 → **9 600 bauds** (`baud_sel='0'`). Calcul : `f_clk / (baud × 16) − 1`. |
| `synchronizer` | Double bascule D initialisée à `'1'` (repos UART). Élimine la métastabilité sur le signal RXD asynchrone. |
| `rx_uart` | FSM 4 états : `IDLE → START_BIT → DATA_BITS → STOP_BIT`. Échantillonnage au centre de chaque bit (tick no 7 pour le start, tick no 15 pour les data/stop). Format **8N1**, LSB en premier. |
| `tx_uart` | FSM 4 états : `IDLE → START_BIT → DATA_BITS → STOP_BIT`. Signal `tx_busy` actif pendant toute la trame. |
| `uart_transceiver` | Wrapper structurel autonome regroupant baud_rate_gen + synchronizer + rx_uart + tx_uart + protocol_decoder. Utilisé pour les tests standalone et la validation en loopback. |

### 3.2 Sous-système RTC

| Module | Description |
|--------|-------------|
| `clock_divider` | Divise 100 MHz en `CE_1ms` (compteur mod 100 000) et `CE_1s` (compteur mod 100 000 000). Les CE sont des impulsions d'**1 seul cycle**. |
| `rtc_time` | Compteur HH:MM:SS. Priorité d'écriture : `UART_SET_EN` > `MODE_REGLAGE` > incrément libre. Génère `CE_DDU` lors du rollover 23:59:59 → 00:00:00. |
| `rtc_date` | Compteur JJ/MM/AA avec calcul dynamique de `max_day` (logique bissextile : `year mod 4 = 0`). Avance sur `CE_DDU`. Valeur par défaut au reset : **24/02/26**. |
| `rtc_alarm` | Comparateur combinatoire 6 champs (SSU, SST, MMU, MMT, HHU, HHT). Génère `ALARM_OUT` (niveau) et pilote la FSM RGB. Alarme désactivée via `al_hht = "11"` (valeur impossible). |
| `alarm_fsm` | FSM Moore 4 états. `IDLE (noir) → RED 6 s → ROTATING 8 s (rotation RGB) → GREEN 5 s → IDLE`. |
| `setting_fsm` | Compteur mod 6 piloté par BTN_L/BTN_R en mode réglage. Valeurs : 0=HR, 1=MIN, 2=SEC, 3=DAY, 4=MTH, 5=YR. |
| `debouncer` | Filtre 10 ms (1 000 000 cycles). Génère une impulsion d'**1 cycle** sur le front montant. |
| `debouncer_repeat` | Même filtre 10 ms, puis auto-répétition après 500 ms (délai) à 5 Hz (200 ms). |

### 3.3 Protocole de communication

| Module | Description |
|--------|-------------|
| `protocol_decoder` | FSM 10 états : `IDLE → READ_CMD → READ_LEN → READ_PAYLOAD → READ_CRC → VERIFY_CRC → PROCESS_CMD → SEND_RESP → WAIT_TX_PULSE → WAIT_TX_DONE`. CRC = XOR de tous les octets CMD + LEN + payload. Payload max 15 octets. Génère `rx_valid_pulse` (clignotant LED15) à chaque trame valide. Envoie `CMD_ALARM_EVENT (0x0A)` spontanément sur front montant de l'alarme. |

### 3.4 Affichage et utilitaires

Le module `display` effectue un **balayage à 1 kHz** des 8 afficheurs 7 segments. Le point décimal (`DP`) clignote à 1 Hz via la bascule T. Les chiffres `"1111"` éteignent le digit correspondant (code « non affiché »).

---

## 4. Protocole de trame

Toutes les trames (PC → FPGA et FPGA → PC) suivent le même format :

```
┌──────┬──────┬──────┬────────────────────────┬─────┐
│ SOF  │ CMD  │ LEN  │    PAYLOAD (0–15 B)    │ CRC │
│ 0x55 │ 1 B  │ 1 B  │       LEN octets       │ 1 B │
└──────┴──────┴──────┴────────────────────────┴─────┘
```

**Calcul du CRC** : XOR glissant de CMD, LEN, et de chaque octet de payload.

```
CRC = CMD ^ LEN ^ payload[0] ^ payload[1] ^ ... ^ payload[N-1]
```

**Réponses :**
- Trame valide, commande SET → `ACK (0x08)`, 1 octet.
- Trame valide, commande GET → réponse complète `[SOF | CMD | LEN | data... | CRC]`.
- CRC invalide → `NACK (0x09)`, 1 octet.

---

## 5. Tableau de commandes

| Code | Nom | LEN TX | Payload TX | LEN RX | Payload RX |
|------|-----|--------|------------|--------|------------|
| `0x01` | `CMD_GET_ALL`     | 0 | — | 6 | sec, min, hr, day, month, year |
| `0x02` | `CMD_SET_ALL`     | 6 | sec, min, hr, day, month, year | — | ACK |
| `0x03` | `CMD_GET_ALARM`   | 0 | — | 3 | al_sec, al_min, al_hr |
| `0x04` | `CMD_SET_ALARM`   | 3 | al_sec, al_min, al_hr | — | ACK |
| `0x05` | `CMD_GET_BAUD`    | 0 | — | 1 | baud_sel (0=9600, 1=115200) |
| `0x06` | `CMD_SET_BAUD`    | 1 | baud_sel | — | ACK |
| `0x07` | `CMD_STATUS`      | 0 | — | 1 | status_byte |
| `0x08` | `ACK`             | — | — | — | — |
| `0x09` | `NACK`            | — | — | — | — |
| `0x0A` | `CMD_ALARM_EVENT` | FPGA→PC spontané | — | 0 | — |
| `0x0B` | `CMD_SET_AL_EN`   | 1 | bit0 : 1=ON, 0=OFF | — | ACK |
| `0x11` | `CMD_GET_TIME`    | 0 | — | 3 | sec, min, hr |
| `0x12` | `CMD_SET_TIME`    | 3 | sec, min, hr | — | ACK |
| `0x13` | `CMD_GET_DATE`    | 0 | — | 3 | day, month, year |
| `0x14` | `CMD_SET_DATE`    | 3 | day, month, year | — | ACK |

**Status byte** (CMD_STATUS, bits) :

```
Bit 7–4 : réservés (0)
Bit 3   : ALARM_RINGING  — 1 si l'alarme sonne en ce moment
Bit 2   : MODE_REGLAGE   — état de SW(14)
Bit 1   : SW(15)         — source alarme (1=switches, 0=PC)
Bit 0   : ALARM_EN       — alarme activée/désactivée
```

---

## 6. Mapping des entrées/sorties

| Signal Top-Level | Ressource Nexys A7 | Description |
|------------------|--------------------|-------------|
| `CLK100MHZ`      | Horloge système W5 | 100 MHz |
| `RST_BTN`        | Bouton CENTER (U18)| Reset asynchrone actif haut |
| `BTN_UP`         | Bouton UP (T18)    | Incrément réglage |
| `BTN_DN`         | Bouton DOWN (U17)  | Décrément réglage / toggle alarme |
| `BTN_L`          | Bouton LEFT (W19)  | Navigation curseur ← |
| `BTN_R`          | Bouton RIGHT (T17) | Navigation curseur → |
| `SW(14)`         | Interrupteur 14    | `MODE_REGLAGE` (1 = actif) |
| `SW(15)`         | Interrupteur 15    | Source alarme (1 = switches, 0 = PC) |
| `SW(13:0)`       | Interrupteurs 0–13 | Alarme hardware : `[13:11]`=min dizaines, `[10:7]`=min unités, `[6:4]`=sec dizaines, `[3:0]`=sec unités |
| `UART_RXD`       | USB-UART C4        | Réception PC → FPGA |
| `UART_TXD`       | USB-UART D4        | Émission FPGA → PC |
| `SEG[6:0]`       | 7 segments         | Segments A–G |
| `AN[7:0]`        | Anodes             | Sélection digit (actif bas) |
| `LED_RGB[2:0]`   | LED RGB LD16       | Alarme (R=rouge, G=vert, rotation) |
| `LED15`          | LED LD15           | Clignotement sur réception UART valide |
| `LED17_G`        | LED LD17 (vert)    | État ALARM_EN |

---

## 7. Testbenches

### `uart_tb.vhd` — `uart_transceiver_tb`

**Entité testée :** `uart_transceiver` (wrapper standalone : baud_rate_gen + synchronizer + rx_uart + tx_uart + protocol_decoder).

**Méthode :** simulation **au niveau bit**. La procédure `send_to_fpga` génère une trame UART complète (start bit + 8 data bits LSB-first + stop bit) en pilotant directement le signal `UART_RXD` avec une période de bit de **8 680 ns** (≈ 115 200 bauds).

```vhdl
-- Extrait de la procédure :
UART_RXD <= '0';            -- start bit
wait for bit_period;
for i in 0 to 7 loop
    UART_RXD <= data(i);    -- LSB first
    wait for bit_period;
end loop;
UART_RXD <= '1';            -- stop bit
wait for bit_period;
```

| # | Octet envoyé | Hex | Description |
|---|--------------|-----|-------------|
| 1 | `'E'` | `0x45` | Lettre ASCII E |
| 2 | `'X'` | `0x58` | Lettre ASCII X |

> **Observation attendue dans Vivado :** `UART_TXD` reproduit la séquence reçue après le délai de traitement (loopback via `protocol_decoder`). La LED `CRC_OK_LED` monte si le décodeur reconnaît une trame valide — ici les octets seuls ne constituent pas une trame complète, le comportement attendu est `NACK` ou retour à `IDLE` après timeout.

---

### `rtc_tb.vhd`

**Entités testées :** `rtc_time` et `rtc_date` (instanciés ensemble, `CE_DDU` câblé en direct).

**Méthode :** les impulsions `CE_1s` sont générées manuellement pour accélérer la simulation (pas de `clock_divider`). Des procédures VHDL encapsulent chaque action.

| # | Scénario | Résultat attendu |
|---|----------|-----------------|
| T1 | 5 × `CE_1s` depuis le reset | `00:00:05` |
| T2 | `UART_SET_EN` → `10:30:00` + 1 `CE_1s` | `10:30:01` |
| T3 | Mode réglage, `BTN_UP` sur HR (×2) | `12:30:01` |
| T4 | Mode réglage, `BTN_DN` sur MIN | `12:29:01` |
| T5 | Chargement `23:59:58`, 3 × `CE_1s` | `00:00:01` + `CE_DDU='1'` détecté |
| T6 | Date UART `18/03/26` | `18/03/26` |
| T7 | Rollover heure → `CE_DDU` | `19/03/26` |
| T8 | Fin février non-bissextile (`28/02/25`) | `01/03/25` |
| T8b | Fin février bissextile (`28/02/24`) | `29/02/24` |
| T9 | Fin d'année (`31/12/26`) | `01/01/27` |
| T10 | Mode réglage date BTN_UP/DN | Navigation curseur jour/mois |

---

### `protocol_tb.vhd`

**Entité testée :** `protocol_decoder`.

**Méthode :** injection directe d'octets via `rx_data / rx_done` (pas de simulation UART complète). Le signal `tx_busy` est simulé par un compteur interne (25 cycles par octet émis). Les octets de réponse sont capturés dans `resp_buf[]` et comparés aux valeurs attendues.

| # | Commande | Frame envoyée (hex) | Réponse attendue |
|---|----------|---------------------|-----------------|
| T1 | `GET_ALL` | `55 01 00 01` | `55 01 06 38 22 0C 12 03 1A 1A` (10 B) |
| T2 | `GET_TIME` | `55 11 00 11` | `55 11 03 38 22 0C 04` (7 B) |
| T3 | `SET_TIME` (10:45:30) | `55 12 03 1E 2D 0A 28` | `ACK (0x08)` + `set_time_en='1'` |
| T4 | CRC invalide | `55 01 00 FF` | `NACK (0x09)` |
| T5 | `STATUS` | `55 07 00 07` | `55 07 01 00 06` (5 B) |
| T6 | `SET_ALARM` (07:00:30) | `55 04 03 1E 00 07 1E` | `ACK` + `set_al_en='1'` |
| T7 | `SET_AL_EN` (ON) | `55 0B 01 01 0B` | `ACK` + `out_al_en_val='1'` |
| T8 | `SET_BAUD` (9600) | `55 06 01 00 07` | `ACK` + `out_baud_sel='0'` |

> **Calcul des CRC** : CMD `XOR` LEN `XOR` payload[0] `XOR` ... — détaillés en tête de fichier.

---

## 8. Simulation sous Vivado

### Prérequis

- Vivado 2020.2 ou supérieur
- Ouvrir `vivado/project.xpr`

### Ajouter les sources de simulation

Dans le projet Vivado, les fichiers `tb/*.vhd` doivent être ajoutés en tant que **sources de simulation** (pas de synthèse).

```
Flow Navigator → Add Sources → Add or create simulation sources
→ Sélectionner tb/uart_tb.vhd, tb/rtc_tb.vhd, tb/protocol_tb.vhd
```

### Lancer une simulation

```
Flow Navigator → Simulation → Run Simulation → Run Behavioral Simulation
```

Sélectionner le testbench à simuler via **Simulation Settings → Simulation top module name**.

| Testbench | Top module |
|-----------|-----------|
| `uart_tb.vhd` | `uart_transceiver_tb` |
| `rtc_tb.vhd` | `rtc_tb` |
| `protocol_tb.vhd` | `protocol_tb` |

### Durées de simulation recommandées

| Testbench | Durée conseillée | Raison |
|-----------|-----------------|--------|
| `uart_transceiver_tb` | `500 µs` | 2 trames UART complètes + délai de réponse |
| `rtc_tb` | `10 µs` | CE_1s manuels, simulation rapide |
| `protocol_tb` | `50 µs` | Temps de traitement FSM + émission réponses |

### Signaux à surveiller (waveform)

**UART :**
```
CLK100MHZ, RST_BTN, UART_RXD, UART_TXD
```

**RTC :**
```
clk, rst, ce_1s, out_hr, out_min, out_sec,
out_day, out_month, out_year, ce_ddu
```

**Protocol :**
```
clk, rst, rx_data, rx_done, tx_data, tx_start, tx_busy,
crc_ok_led, set_time_en, out_hr, out_min, out_sec
```

---

## 9. Synthèse et implémentation

```
Flow Navigator → Run Synthesis
Flow Navigator → Run Implementation
Flow Navigator → Generate Bitstream
```

Le fichier de contraintes `vivado/constraints.xdc` définit les affectations de broches et les contraintes de timing pour la Nexys A7-100T.

Après génération du bitstream :

```
Flow Navigator → Open Hardware Manager → Program Device
```

### Validation sur carte

1. Connecter la carte via USB (port UART `J2`).
2. Ouvrir un terminal série (ex. : PuTTY, minicom) à **115 200 bauds, 8N1**.
3. Exemple de commande `GET_ALL` à envoyer en binaire : `55 01 00 01`.
4. La carte répond avec 10 octets contenant l'heure et la date courantes.
5. LED15 clignote (3 fois) à chaque trame valide reçue.
6. LED17 (vert) indique l'état de l'alarme (activée/désactivée).

---

*Dernière mise à jour : mars 2026* \
*Hugo MALAVAL*