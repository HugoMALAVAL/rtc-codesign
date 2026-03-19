# Hardware Subsystem — `hw/`

VHDL implementation of a UART-controlled real-time clock (RTC), targeting the **Digilent Nexys A7-100T** board (Xilinx Artix-7 FPGA, 100 MHz system clock).

---

## Table of Contents

1. [Directory Structure](#1-directory-structure)
2. [General Architecture](#2-general-architecture)
3. [RTL Modules](#3-rtl-modules)
   - 3.1 [UART Subsystem](#31-uart-subsystem)
   - 3.2 [RTC Subsystem](#32-rtc-subsystem)
   - 3.3 [Communication Protocol](#33-communication-protocol)
   - 3.4 [Display and Utilities](#34-display-and-utilities)
4. [Frame Protocol](#4-frame-protocol)
5. [Command Table](#5-command-table)
6. [I/O Mapping](#6-io-mapping)
7. [Testbenches](#7-testbenches)
8. [Simulation in Vivado](#8-simulation-in-vivado)
9. [Synthesis and Implementation](#9-synthesis-and-implementation)

---

## 1. Directory Structure

```
hw/
├── rtl/
│   ├── uart/
│   │   ├── baud_rate_gen.vhd       # Baud rate generator (tick × 16)
│   │   ├── synchronizer.vhd        # 2-FF metastability shield
│   │   ├── rx_uart.vhd             # UART receiver (4-state FSM)
│   │   ├── tx_uart.vhd             # UART transmitter (4-state FSM)
│   │   └── uart_transceiver.vhd    # Standalone transceiver wrapper (test)
│   ├── rtc/
│   │   ├── clock_divider.vhd       # CE_1ms and CE_1s from 100 MHz
│   │   ├── rtc_time.vhd            # Hours/minutes/seconds counter
│   │   ├── rtc_date.vhd            # Day/month/year counter (leap year logic)
│   │   ├── rtc_alarm.vhd           # Alarm comparator
│   │   ├── alarm_fsm.vhd           # RGB FSM: IDLE→RED→ROTATING→GREEN
│   │   ├── setting_fsm.vhd         # Cursor navigation in settings mode
│   │   ├── debouncer.vhd           # Single rising-edge debouncer
│   │   └── debouncer_repeat.vhd    # Debouncer with auto-repeat
│   ├── protocol/
│   │   └── protocol_decoder.vhd    # Frame decoder + XOR CRC
│   └── display/
│       ├── display.vhd             # 7-segment display top (8 digits)
│       ├── clock_divider.vhd       # (shared)
│       ├── counter_4b_E.vhd        # 4-bit scan counter
│       ├── mux_16x1x4bit.vhd       # 12-input × 4-bit multiplexer
│       ├── transcoder_7segs.vhd    # BCD to 7-segment transcoder
│       ├── transcoder_4v16.vhd     # Binary to active-low anode transcoder
│       ├── register_4b.vhd         # 4-bit register
│       ├── register_8b.vhd         # 8-bit register
│       └── Tregister_1b.vhd        # T flip-flop (decimal point blinking)
├── tb/
│   ├── uart_tb.vhd                 # UART bit-level test (uart_transceiver)
│   ├── rtc_tb.vhd                  # RTC test: time + date
│   └── protocol_tb.vhd             # Protocol decoder test
├── vivado/
│   ├── project.xpr
│   ├── constraints.xdc
│   └── block_design/
└── README.md
```

---

## 2. General Architecture

The `Top_Level_RTC` top-level entity assembles all sub-modules in purely structural mode.

```
Top_Level_RTC
├── U_CLOCK      clock_divider          CE_1ms, CE_1s
├── U_DEB_UP     debouncer_repeat       BTN_UP (debounce + auto-repeat)
├── U_DEB_DN     debouncer_repeat       BTN_DN
├── U_DEB_L      debouncer              BTN_L  (single edge)
├── U_DEB_R      debouncer              BTN_R
├── U_FSM_SET    setting_fsm            Settings cursor (0=HR … 5=YR)
├── U_BAUD       baud_rate_gen          Tick × 16 (baud_sel from PC)
├── U_SYNC       synchronizer           Metastability shield on RXD
├── U_RX         rx_uart                UART byte reception
├── U_TX         tx_uart                UART byte transmission
├── U_PROTOCOL   protocol_decoder       Frame decoding + response generation
├── U_RTC        rtc_time               HH:MM:SS clock
├── U_DATE       rtc_date               DD/MM/YY calendar
├── U_ALARM      rtc_alarm              Alarm comparator + RGB FSM
│   └── AFSM     alarm_fsm
└── U_DISPLAY    display                7-segment scan × 8 digits
    ├── U0       counter_4b_E
    ├── U1       transcoder_4v16
    ├── U2/U3    register_4b (× 2)
    ├── U5       mux_16x1x4bit
    ├── U6       transcoder_7segs
    ├── U7       register_8b
    └── U8       Tregister_1b
```

---

## 3. RTL Modules

### 3.1 UART Subsystem

| Module | Description |
|--------|-------------|
| `baud_rate_gen` | Generates a tick at 16× the baud rate. Limit = 53 → **115,200 baud** (`baud_sel='1'`); limit = 650 → **9,600 baud** (`baud_sel='0'`). Formula: `f_clk / (baud × 16) − 1`. |
| `synchronizer` | Dual D flip-flop initialized to `'1'` (UART idle state). Eliminates metastability on the asynchronous RXD signal. |
| `rx_uart` | 4-state FSM: `IDLE → START_BIT → DATA_BITS → STOP_BIT`. Mid-bit sampling (tick #7 for start, tick #15 for data/stop). **8N1** format, LSB first. |
| `tx_uart` | 4-state FSM: `IDLE → START_BIT → DATA_BITS → STOP_BIT`. `tx_busy` signal asserted for the entire frame duration. |
| `uart_transceiver` | Standalone structural wrapper combining baud_rate_gen + synchronizer + rx_uart + tx_uart + protocol_decoder. Used for standalone testing and loopback validation. |

### 3.2 RTC Subsystem

| Module | Description |
|--------|-------------|
| `clock_divider` | Divides 100 MHz into `CE_1ms` (mod-100,000 counter) and `CE_1s` (mod-100,000,000 counter). Clock enables are **single-cycle** pulses. |
| `rtc_time` | HH:MM:SS counter. Write priority: `UART_SET_EN` > `MODE_REGLAGE` > free increment. Asserts `CE_DDU` on the 23:59:59 → 00:00:00 rollover. |
| `rtc_date` | DD/MM/YY counter with dynamic `max_day` computation (leap year logic: `year mod 4 = 0`). Advances on `CE_DDU`. Reset default: **24/02/26**. |
| `rtc_alarm` | 6-field combinational comparator (SSU, SST, MMU, MMT, HHU, HHT). Asserts `ALARM_OUT` (level) and drives the RGB FSM. Alarm disabled by setting `al_hht = "11"` (impossible value). |
| `alarm_fsm` | Moore FSM, 4 states. `IDLE (off) → RED 6 s → ROTATING 8 s (RGB rotation) → GREEN 5 s → IDLE`. |
| `setting_fsm` | Mod-6 counter driven by BTN_L/BTN_R in settings mode. Values: 0=HR, 1=MIN, 2=SEC, 3=DAY, 4=MTH, 5=YR. |
| `debouncer` | 10 ms filter (1,000,000 cycles). Generates a **single-cycle** pulse on rising edge. |
| `debouncer_repeat` | Same 10 ms filter, then auto-repeat after 500 ms delay at 5 Hz (200 ms period). |

### 3.3 Communication Protocol

| Module | Description |
|--------|-------------|
| `protocol_decoder` | 10-state FSM: `IDLE → READ_CMD → READ_LEN → READ_PAYLOAD → READ_CRC → VERIFY_CRC → PROCESS_CMD → SEND_RESP → WAIT_TX_PULSE → WAIT_TX_DONE`. CRC = XOR of all CMD + LEN + payload bytes. Max payload: 15 bytes. Asserts `rx_valid_pulse` (LED15 blink) on each valid frame. Spontaneously sends `CMD_ALARM_EVENT (0x0A)` on the alarm rising edge. |

### 3.4 Display and Utilities

The `display` module performs a **1 kHz scan** across 8 seven-segment displays. The decimal point (`DP`) blinks at 1 Hz via the T flip-flop. A nibble of `"1111"` blanks the corresponding digit.

---

## 4. Frame Protocol

All frames (PC → FPGA and FPGA → PC) follow the same format:

```
┌──────┬──────┬──────┬────────────────────────┬─────┐
│ SOF  │ CMD  │ LEN  │    PAYLOAD (0–15 B)    │ CRC │
│ 0x55 │ 1 B  │ 1 B  │       LEN bytes        │ 1 B │
└──────┴──────┴──────┴────────────────────────┴─────┘
```

**CRC calculation**: rolling XOR of CMD, LEN, and each payload byte.

```
CRC = CMD ^ LEN ^ payload[0] ^ payload[1] ^ ... ^ payload[N-1]
```

**Responses:**
- Valid frame, SET command → `ACK (0x08)`, 1 byte.
- Valid frame, GET command → full response `[SOF | CMD | LEN | data... | CRC]`.
- Invalid CRC → `NACK (0x09)`, 1 byte.

---

## 5. Command Table

| Code | Name | TX LEN | TX Payload | RX LEN | RX Payload |
|------|------|--------|------------|--------|------------|
| `0x01` | `CMD_GET_ALL`     | 0 | — | 6 | sec, min, hr, day, month, year |
| `0x02` | `CMD_SET_ALL`     | 6 | sec, min, hr, day, month, year | — | ACK |
| `0x03` | `CMD_GET_ALARM`   | 0 | — | 3 | al_sec, al_min, al_hr |
| `0x04` | `CMD_SET_ALARM`   | 3 | al_sec, al_min, al_hr | — | ACK |
| `0x05` | `CMD_GET_BAUD`    | 0 | — | 1 | baud_sel (0=9600, 1=115200) |
| `0x06` | `CMD_SET_BAUD`    | 1 | baud_sel | — | ACK |
| `0x07` | `CMD_STATUS`      | 0 | — | 1 | status_byte |
| `0x08` | `ACK`             | — | — | — | — |
| `0x09` | `NACK`            | — | — | — | — |
| `0x0A` | `CMD_ALARM_EVENT` | FPGA→PC spontaneous | — | 0 | — |
| `0x0B` | `CMD_SET_AL_EN`   | 1 | bit0: 1=ON, 0=OFF | — | ACK |
| `0x11` | `CMD_GET_TIME`    | 0 | — | 3 | sec, min, hr |
| `0x12` | `CMD_SET_TIME`    | 3 | sec, min, hr | — | ACK |
| `0x13` | `CMD_GET_DATE`    | 0 | — | 3 | day, month, year |
| `0x14` | `CMD_SET_DATE`    | 3 | day, month, year | — | ACK |

**Status byte (CMD_STATUS, bits):**

```
Bits 7–4 : reserved (0)
Bit  3   : ALARM_RINGING  — 1 if alarm is currently ringing
Bit  2   : MODE_REGLAGE   — SW(14) state
Bit  1   : SW(15)         — alarm source (1=switches, 0=PC)
Bit  0   : ALARM_EN       — alarm enabled/disabled
```

---

## 6. I/O Mapping

| Top-Level Signal | Nexys A7 Resource | Description |
|------------------|-------------------|-------------|
| `CLK100MHZ`      | System clock W5   | 100 MHz |
| `RST_BTN`        | CENTER button (U18) | Active-high asynchronous reset |
| `BTN_UP`         | UP button (T18)   | Settings increment |
| `BTN_DN`         | DOWN button (U17) | Settings decrement / alarm toggle |
| `BTN_L`          | LEFT button (W19) | Cursor navigate ← |
| `BTN_R`          | RIGHT button (T17)| Cursor navigate → |
| `SW(14)`         | Switch 14         | `MODE_REGLAGE` (1 = active) |
| `SW(15)`         | Switch 15         | Alarm source (1 = switches, 0 = PC) |
| `SW(13:0)`       | Switches 0–13     | Hardware alarm: `[13:11]`=min tens, `[10:7]`=min units, `[6:4]`=sec tens, `[3:0]`=sec units |
| `UART_RXD`       | USB-UART C4       | PC → FPGA reception |
| `UART_TXD`       | USB-UART D4       | FPGA → PC transmission |
| `SEG[6:0]`       | 7-segment         | Segments A–G |
| `AN[7:0]`        | Anodes            | Digit select (active low) |
| `LED_RGB[2:0]`   | RGB LED LD16      | Alarm indicator (R=red, G=green, rotating) |
| `LED15`          | LED LD15          | Blinks on valid UART frame received |
| `LED17_G`        | LED LD17 (green)  | ALARM_EN state |

---

## 7. Testbenches

### `uart_tb.vhd` — `uart_transceiver_tb`

**Entity under test:** `uart_transceiver` (standalone wrapper: baud_rate_gen + synchronizer + rx_uart + tx_uart + protocol_decoder).

**Method:** **bit-level** simulation. The `send_to_fpga` procedure generates a complete UART frame (start bit + 8 data bits LSB-first + stop bit) by directly driving the `UART_RXD` signal with a bit period of **8,680 ns** (≈ 115,200 baud).

```vhdl
-- Procedure excerpt:
UART_RXD <= '0';            -- start bit
wait for bit_period;
for i in 0 to 7 loop
    UART_RXD <= data(i);    -- LSB first
    wait for bit_period;
end loop;
UART_RXD <= '1';            -- stop bit
wait for bit_period;
```

| # | Byte sent | Hex | Description |
|---|-----------|-----|-------------|
| 1 | `'E'` | `0x45` | ASCII letter E |
| 2 | `'X'` | `0x58` | ASCII letter X |

> **Expected in Vivado:** `UART_TXD` echoes the received sequence after processing (loopback via `protocol_decoder`). `CRC_OK_LED` goes high if the decoder recognizes a valid frame — here individual bytes do not form a complete frame, so the expected behavior is `NACK` or return to `IDLE` after timeout.

---

### `rtc_tb.vhd`

**Entities under test:** `rtc_time` and `rtc_date` (instantiated together, `CE_DDU` directly wired).

**Method:** `CE_1s` pulses are generated manually to speed up simulation (no `clock_divider`). VHDL procedures encapsulate each action.

| # | Scenario | Expected result |
|---|----------|----------------|
| T1 | 5 × `CE_1s` from reset | `00:00:05` |
| T2 | `UART_SET_EN` → `10:30:00` + 1 `CE_1s` | `10:30:01` |
| T3 | Settings mode, `BTN_UP` on HR (×2) | `12:30:01` |
| T4 | Settings mode, `BTN_DN` on MIN | `12:29:01` |
| T5 | Load `23:59:58`, 3 × `CE_1s` | `00:00:01` + `CE_DDU='1'` detected |
| T6 | UART date `18/03/26` | `18/03/26` |
| T7 | Hour rollover → `CE_DDU` | `19/03/26` |
| T8 | End of non-leap February (`28/02/25`) | `01/03/25` |
| T8b | End of leap February (`28/02/24`) | `29/02/24` |
| T9 | End of year (`31/12/26`) | `01/01/27` |
| T10 | Date settings mode BTN_UP/DN | Day/month cursor navigation |

---

### `protocol_tb.vhd`

**Entity under test:** `protocol_decoder`.

**Method:** bytes injected directly via `rx_data / rx_done` (no full UART simulation). `tx_busy` is simulated by an internal counter (25 cycles per emitted byte). Response bytes are captured in `resp_buf[]` and compared to expected values.

| # | Command | Frame sent (hex) | Expected response |
|---|---------|-----------------|------------------|
| T1 | `GET_ALL` | `55 01 00 01` | `55 01 06 38 22 0C 12 03 1A 1A` (10 B) |
| T2 | `GET_TIME` | `55 11 00 11` | `55 11 03 38 22 0C 04` (7 B) |
| T3 | `SET_TIME` (10:45:30) | `55 12 03 1E 2D 0A 28` | `ACK (0x08)` + `set_time_en='1'` |
| T4 | Invalid CRC | `55 01 00 FF` | `NACK (0x09)` |
| T5 | `STATUS` | `55 07 00 07` | `55 07 01 00 06` (5 B) |
| T6 | `SET_ALARM` (07:00:30) | `55 04 03 1E 00 07 1E` | `ACK` + `set_al_en='1'` |
| T7 | `SET_AL_EN` (ON) | `55 0B 01 01 0B` | `ACK` + `out_al_en_val='1'` |
| T8 | `SET_BAUD` (9600) | `55 06 01 00 07` | `ACK` + `out_baud_sel='0'` |

> **CRC calculation:** CMD `XOR` LEN `XOR` payload[0] `XOR` ... — detailed in the file header.

---

## 8. Simulation in Vivado

### Prerequisites

- Vivado 2020.2 or later
- Open `vivado/project.xpr`

### Adding simulation sources

In the Vivado project, `tb/*.vhd` files must be added as **simulation sources** (not synthesis sources).

```
Flow Navigator → Add Sources → Add or create simulation sources
→ Select tb/uart_tb.vhd, tb/rtc_tb.vhd, tb/protocol_tb.vhd
```

### Running a simulation

```
Flow Navigator → Simulation → Run Simulation → Run Behavioral Simulation
```

Select the testbench to simulate via **Simulation Settings → Simulation top module name**.

| Testbench | Top module |
|-----------|-----------|
| `uart_tb.vhd` | `uart_transceiver_tb` |
| `rtc_tb.vhd` | `rtc_tb` |
| `protocol_tb.vhd` | `protocol_tb` |

### Recommended simulation durations

| Testbench | Duration | Reason |
|-----------|----------|--------|
| `uart_transceiver_tb` | `500 µs` | 2 complete UART frames + response delay |
| `rtc_tb` | `10 µs` | Manual CE_1s pulses, fast simulation |
| `protocol_tb` | `50 µs` | FSM processing time + response emission |

### Signals to monitor (waveform)

**UART:**
```
CLK100MHZ, RST_BTN, UART_RXD, UART_TXD
```

**RTC:**
```
clk, rst, ce_1s, out_hr, out_min, out_sec,
out_day, out_month, out_year, ce_ddu
```

**Protocol:**
```
clk, rst, rx_data, rx_done, tx_data, tx_start, tx_busy,
crc_ok_led, set_time_en, out_hr, out_min, out_sec
```

---

## 9. Synthesis and Implementation

```
Flow Navigator → Run Synthesis
Flow Navigator → Run Implementation
Flow Navigator → Generate Bitstream
```

The constraints file `vivado/constraints.xdc` defines pin assignments and timing constraints for the Nexys A7-100T.

After bitstream generation:

```
Flow Navigator → Open Hardware Manager → Program Device
```

### On-board validation

1. Connect the board via USB (UART port `J2`).
2. Open a serial terminal (e.g. PuTTY, minicom) at **115,200 baud, 8N1**.
3. Example `GET_ALL` command to send in binary: `55 01 00 01`.
4. The board responds with 10 bytes containing the current time and date.
5. LED15 blinks (3 times) on each valid frame received.
6. LED17 (green) indicates the alarm state (enabled/disabled).

---

*Last updated: March 2026* \
*Hugo MALAVAL*