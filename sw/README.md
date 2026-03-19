# Software Subsystem — `sw/`

Python GUI for simultaneous control of the **Nexys A7 (FPGA)** and the **STM32F746G-DISCO (Zephyr)** via the shared binary UART protocol.

---

## Table of Contents

1. [Directory Structure](#1-directory-structure)
2. [Overview](#2-overview)
3. [Requirements](#3-requirements)
4. [Installation and Launch](#4-installation-and-launch)
5. [Graphical Interface](#5-graphical-interface)
6. [UART Protocol](#6-uart-protocol)
7. [Features in Detail](#7-features-in-detail)
8. [CSV Export](#8-csv-export)
9. [Watchdog and Auto-Reconnect](#9-watchdog-and-auto-reconnect)
10. [Portability Notes](#10-portability-notes)

---

## 1. Directory Structure

```
sw/
├── src/
│   └── rtc_host.py       # Complete application (single file)
├── requirements.txt      # Python dependencies
├── run.sh                # Launch script (Linux / macOS / Git Bash)
└── README.md
```

---

## 2. Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      rtc_host.py                                │
│                                                                 │
│   ┌────────────────────┐      ┌────────────────────┐            │
│   │  FPGA Panel        │      │    STM32 Panel     │            │
│   │  📡 Nexys A7       │      │  ⚙️ Zephyr RTOS   │            │
│   │  Time / Date       │      │  Time / Date       │            │
│   │  Alarm / Baud      │      │  Alarm / RTC mode  │            │
│   └────────┬───────────┘      └────────┬───────────┘            │
│            │ pyserial                  │ pyserial               │
└────────────┼───────────────────────────┼────────────────────────┘
             │ UART 115200 (COM/ttyUSB)  │ UART 115200 (COM/ttyUSB)
             ▼                           ▼
      Nexys A7 (hw/)             STM32F746G-DISCO (fw/)
```

The application controls **two independent targets** on two separate serial ports. All commands use the same binary protocol as the firmware (`hw/` and `fw/`), enabling cross-validation and real-time drift measurement between the two systems.

---

## 3. Requirements

| Component | Minimum version | Notes |
|-----------|----------------|-------|
| Python | **3.10+** | Must include `tkinter` (standard) |
| pyserial | **3.5+** | `pip install pyserial` |
| tkinter | Bundled with Python | On Linux: `sudo apt install python3-tk` |
| winsound | Built-in Windows | Alarm sound; absent on Linux/macOS (silently ignored) |

**Serial ports required:**
- One port for the Nexys A7 (via on-board FTDI USB-UART)
- One port for the STM32F746G-DISCO (via CN14, USB micro)

Both devices can be connected **independently** — the application works with either one if the other is absent.

---

## 4. Installation and Launch

### Method 1 — Automatic script (recommended)

```bash
chmod +x run.sh
./run.sh
```

The script:
1. Checks that Python 3.10+ is available.
2. Creates a `.venv/` virtual environment if absent.
3. Installs dependencies (`pyserial`).
4. Verifies that `tkinter` is present.
5. Launches `src/rtc_host.py`.

### Method 2 — Manual installation

```bash
python3 -m venv .venv
source .venv/bin/activate          # Linux/macOS
# .venv\Scripts\activate           # Windows PowerShell

pip install -r requirements.txt
python3 src/rtc_host.py
```

### Windows (without Git Bash)

```bat
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python src\rtc_host.py
```

---

## 5. Graphical Interface

### Window layout (1250 × 950 px)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  📡 FPGA (Nexys A7)             ┃  ⚙️ STM32 (Zephyr RTOS)                   │
│  14:25:38  (green)              ┃  14:25:40  (cyan)                          │
│  24/03/2026                     ┃  24/03/2026                                │
│  🔔 Alarm: 07:00:00             ┃  🔔 Alarm: 07:00:00   ✅ PCF8563          │
├─────────────────────────────────┴────────────────────────────────────────────┤
│  Hardware Connections (UART)                                                 │
│  FPGA COM: [COM3 ▼] [Connect FPGA]   ●Disconnected                           │
│  STM32 COM:[COM4 ▼] [Connect STM32]  ●Disconnected   [🔄 Refresh]            │
├──────────────────────────────────────────────────────────────────────────────┤
│  Master Control Panel                          │  📉 Drift / Latency         │
│  [GET TIME] [GET DATE] [GET ALARM] [GET ALL]   │                             │
│  [STATUS FPGA] [STATUS STM32]                  │   Real-time graph           │
│  [🔔 ALARM ON] [🔕 ALARM OFF] [GET BAUD]      │   Zephyr/I2C overhead       │
│  Time  : [HH] [MM] [SS] [SET FPGA] [SET STM32]│                              │
│  Date  : [DD] [MM] [YY] [SET FPGA] [SET STM32]│  [💾 Export CSV]            │
│  Alarm : [HH] [MM] [SS] [SET FPGA] [SET STM32]│                              │
│  SET ALL: [SET FPGA] [SET STM32] [SET BOTH]                                  │
│  [⚙️ Sync PC Time] [☑ Auto-Refresh LCD]                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│  Unified Serial Monitor (Rx/Tx)                         [🧹 Clear logs]     │
│  [FPGA-TX]  55 01 00 01  -> (GET TIME)                                       │
│  [FPGA-RX]  55 11 03 0E 19 0E 14  <- (Time)                                  │
│  [STM32-TX] 55 11 00 11  -> (GET TIME)                                       │
│  [STM32-RX] 55 11 03 28 19 0E 24  <- (Time)                                  │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Serial monitor color codes

| Tag | Color | Usage |
|-----|-------|-------|
| `fpga_tx` | Light green `#a2d149` | Frames sent to FPGA |
| `fpga_rx` | Bright green `#00ff00` | Frames received from FPGA |
| `stm32_tx` | Dark cyan `#009999` | Frames sent to STM32 |
| `stm32_rx` | Bright cyan `#00ffff` | Frames received from STM32 |
| `sys` | White | System messages |
| `alert` | Red `#ff3333` | NACK, alarm triggered |
| `warn` | Orange `#ffaa00` | Watchdog, port lost |

---

## 6. UART Protocol

The application implements **exactly** the same protocol as `hw/` and `fw/`.

### Frame Format

```
┌──────┬──────┬──────┬────────────────────────┬─────┐
│ SOF  │ CMD  │ LEN  │   PAYLOAD (0–15 B)     │ CRC │
│ 0x55 │ 1 B  │ 1 B  │      LEN bytes         │ 1 B │
└──────┴──────┴──────┴────────────────────────┴─────┘
CRC = CMD ^ LEN ^ payload[0] ^ ... ^ payload[N-1]
```

### Commands Used

| Code | Name | Direction | Payload |
|------|------|-----------|---------|
| `0x01` | `CMD_GET_ALL` | PC → target | — |
| `0x02` | `CMD_SET_ALL` | PC → target | sec, min, hr, day, month, year |
| `0x03` | `CMD_GET_ALARM` | PC → target | — |
| `0x04` | `CMD_SET_ALARM` | PC → target | al_sec, al_min, al_hr |
| `0x05` | `CMD_GET_BAUD` | PC → target | — |
| `0x06` | `CMD_SET_BAUD` | PC → target | 0x01=115200, 0x00=9600 |
| `0x07` | `CMD_GET_STATUS` | PC → target | — |
| `0x0A` | `CMD_ALARM_EVT` | target → PC | Spontaneous (alarm triggered) |
| `0x0B` | `CMD_TOGGLE_AL` | PC → target | 0x01=ON, 0x00=OFF |
| `0x11` | `CMD_GET_TIME` | PC → target | — |
| `0x12` | `CMD_SET_TIME` | PC → target | sec, min, hr |
| `0x13` | `CMD_GET_DATE` | PC → target | — |
| `0x14` | `CMD_SET_DATE` | PC → target | day, month, year (2 digits) |

### Status byte decoding

**FPGA (`CMD_GET_STATUS` 0x07):**

| Bit | Meaning |
|-----|---------|
| 3 | `ALARM_RINGING` — alarm currently ringing |
| 2 | `MODE_REGLAGE` — SW(14) raised on Nexys A7 |
| 1 | `SW15` — alarm source (1=switches, 0=PC) |
| 0 | `ALARM_EN` — alarm enabled |

**STM32 (`CMD_GET_STATUS` 0x07):**

| Bit | Meaning |
|-----|---------|
| 1 | `RTC_VIRTUAL` — 1 if PCF8563 absent (RAM clock) |
| 0 | `ALARM_EN` — alarm enabled |

---

## 7. Features in Detail

### Connection and port selection

At startup, the list of available ports is automatically populated. Click **Connect FPGA** / **Connect STM32** to open the port at **115,200 baud**. Connecting to the FPGA automatically triggers a `CMD_GET_STATUS` to initialize the `hw_switch_local` state.

### Auto-Refresh LCD

Checking **Auto-Refresh LCD** enables polling every **500 ms**:
- `CMD_GET_TIME` + `CMD_GET_STATUS` sent to FPGA.
- `CMD_GET_TIME` sent to STM32.
- Polling frames do **not** appear in the serial monitor (anti-spam filter).
- Round-trip latencies are measured and plotted in the drift graph.

### PC → FPGA & STM32 Time Sync

The **⚙️ Sync PC Time** button sends `CMD_SET_ALL` to both targets simultaneously using the PC system time (`datetime.datetime.now()`). The drift graph is reset after synchronization.

### SET BOTH (Simultaneous)

Sends `CMD_SET_ALL` to both targets in a single action, then resets the graph to measure drift from a common reference state.

### FPGA Status Window

The **STATUS FPGA** button sends `CMD_GET_STATUS` and opens a popup decoding the alarm state and the position of switch SW15 (local or PC alarm source).

### STM32 Status Window

The **STATUS STM32** button opens a popup showing the alarm state and whether the STM32 is running with the **physical PCF8563** or in **virtual RTC mode** (RAM clock).

### SET ALARM with hardware conflict

If the Nexys A7 SW15 switch is raised (alarm controlled by local switches), sending a `CMD_SET_ALARM` to the FPGA shows a warning asking for confirmation before sending the command.

### Alarm sound

When a `CMD_ALARM_EVT (0x0A)` is received:
- From FPGA: `winsound.Beep(1500 Hz, 800 ms)`.
- From STM32: `winsound.Beep(750 Hz, 800 ms)`.
- On Linux/macOS: no sound (`winsound` module absent, `HAS_SOUND=False`).

---

## 8. CSV Export

The **💾 Export Measurements** button saves latency data collected during Auto-Refresh into a `.csv` file (`;` separator, Excel-compatible).

### File format

```
Elapsed time (s);FPGA latency (ms);STM32 latency (ms);RTOS overhead (ms)
0.5;8.3;12.1;3.8
1.0;8.1;11.9;3.8
...
```

**Column description:**

| Column | Description |
|--------|-------------|
| Elapsed time | Seconds since start or last synchronization |
| FPGA latency | FPGA round-trip time for `CMD_GET_TIME` (ms) |
| STM32 latency | STM32 round-trip time for `CMD_GET_TIME` (ms) |
| RTOS overhead | Difference STM32 − FPGA (Zephyr + I²C overhead) |

> Export is only available if Auto-Refresh has collected at least one data point. A warning is shown otherwise.

---

## 9. Watchdog and Auto-Reconnect

A watchdog checks every **2 seconds** that each serial port responds by calling `getCTS()`. Cases handled:

- Cable physically unplugged.
- Port masked by a VM (Windows loses access rights → `OSError`).
- Device removed by the device manager.

On port loss:
1. The port is cleanly closed.
2. Auto-Refresh is disabled.
3. An **automatic reconnection** attempt is launched every **3 seconds** as long as the port reappears in the system list.

Watchdog events appear in the serial monitor in **orange**.

---

## 10. Portability Notes

| OS | Status | Notes |
|----|--------|-------|
| Windows 10/11 | ✅ Full | `winsound` alarm sound available |
| Linux (Ubuntu/Debian) | ✅ | Install `python3-tk`; no sound |
| macOS | ✅ | Install `python-tk` via Homebrew; no sound |

**Port names:**

| OS | FPGA (FTDI) | STM32 (ST-Link) |
|----|-------------|-----------------|
| Windows | `COM3`, `COM4`... | `COM5`, `COM6`... |
| Linux | `/dev/ttyUSB0` | `/dev/ttyACM0` |
| macOS | `/dev/tty.usbserial-*` | `/dev/tty.usbmodem*` |

On Linux, add your user to the `dialout` group if access is denied:

```bash
sudo usermod -aG dialout $USER
# Then log out and back in (or: newgrp dialout)
```

---

*Last updated: March 2026* \
*Hugo MALAVAL*