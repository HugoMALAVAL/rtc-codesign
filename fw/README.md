# Firmware Subsystem — `fw/`

Zephyr RTOS application for the **STM32F746G-DISCO** board, implementing a real-time clock with an LVGL 9 graphical interface and binary UART control.

---

## Table of Contents

1. [Directory Structure](#1-directory-structure)
2. [Overview](#2-overview)
3. [Hardware Requirements](#3-hardware-requirements)
4. [Software Dependencies](#4-software-dependencies)
5. [Project Configuration](#5-project-configuration)
6. [Device Tree — `boards/app.overlay`](#6-device-tree--boardsappoverlay)
7. [Software Architecture](#7-software-architecture)
8. [Binary UART Protocol](#8-binary-uart-protocol)
9. [LVGL Graphical Interface](#9-lvgl-graphical-interface)
10. [Build and Flash](#10-build-and-flash)
11. [Debugging via RTT](#11-debugging-via-rtt)

---

## 1. Directory Structure

```
fw/
├── src/
│   └── main.c              # Complete application (single source file)
├── boards/
│   └── app.overlay         # Device Tree override: PCF8563 on I2C1
├── prj.conf                # Kconfig configuration (Zephyr 4.2)
├── CMakeLists.txt          # Build system
└── README.md
```

> **Note:** the application is contained in a single `main.c` file, which simplifies compilation and code readability.

---

## 2. Overview

```
STM32F746G-DISCO
│
├── LCD LTDC 480×272 ──── LVGL 9 ──── Analog clock + control panel
├── Touchscreen ────────── INPUT ───── Alarm ON/OFF button
├── UART (USB-UART) ────── Binary protocol ── ↔ Nexys A7 (hw/) or PC (sw/)
└── I2C1 ───────────────── PCF8563 ─── Physical RTC (OPTIONAL)
```

**Operating modes:**

| Condition | Mode | Behavior |
|-----------|------|----------|
| PCF8563 detected | **Hardware** | Time read/written to physical RTC |
| PCF8563 absent | **Virtual** | Software clock in RAM, incremented by worker thread |

In both cases, the **UART interface remains identical** — the Python application (`sw/`) or the FPGA (`hw/`) does not need to handle the difference.

---

## 3. Hardware Requirements

| Component | Role | Required |
|-----------|------|----------|
| STM32F746G-DISCO | Main board | ✅ |
| PCF8563 (I²C address `0x51`) | Low-power RTC | ❌ (software fallback) |
| USB micro cable (CN14) | Flash + UART to PC/FPGA | ✅ |
| On-board J-Link or ST-Link | RTT debugging | ✅ |

**I2C1 pinout (if PCF8563 connected):**

| Signal | STM32F746G-DISCO pin |
|--------|----------------------|
| SDA    | PB9 (Arduino D14)    |
| SCL    | PB8 (Arduino D15)    |
| VCC    | 3.3 V                |
| GND    | GND                  |

---

## 4. Software Dependencies

| Tool / Library | Version | Notes |
|----------------|---------|-------|
| Zephyr RTOS | **4.2** | West workspace |
| LVGL | **9.x** | Integrated in Zephyr (`CONFIG_LVGL=y`) |
| West | ≥ 1.2 | Zephyr build manager |
| Arm GNU Toolchain | ≥ 13 | `arm-zephyr-eabi` |
| J-Link RTT Viewer | Any | Debug logs (optional) |

---

## 5. Project Configuration

### `prj.conf`

| Section | Key options | Description |
|---------|-------------|-------------|
| I2C / RTC | `CONFIG_I2C=y` `CONFIG_RTC_PCF8563=y` | PCF8563 driver, non-fatal if absent |
| UART | `CONFIG_UART_INTERRUPT_DRIVEN=y` `CONFIG_UART_CONSOLE=n` | Silent binary mode — Zephyr console disabled to avoid polluting the protocol |
| Debug | `CONFIG_LOG_BACKEND_RTT=y` `CONFIG_LOG_DEFAULT_LEVEL=3` | Logs redirected to Segger RTT (INFO level) |
| Display | `CONFIG_DISPLAY=y` `CONFIG_INPUT=y` | LTDC + touchscreen |
| LVGL | `CONFIG_LV_Z_MEM_POOL_SIZE=32768` `CONFIG_LV_COLOR_DEPTH_16=y` | 32 kB pool, 16 bpp RGB565 |
| Fonts | `MONTSERRAT_10/12/14/20/32` | Sizes used in the UI |
| FPU | `CONFIG_FPU=y` `CONFIG_FPU_SHARING=y` | Required for `cosf/sinf` in clock hand drawing |
| Kernel | `CONFIG_MAIN_STACK_SIZE=4096` `CONFIG_HEAP_MEM_POOL_SIZE=16384` | Stacks and heap |

> ⚠️ `CONFIG_UART_CONSOLE=n` and `CONFIG_CONSOLE=n` are **critical**: without them, Zephyr would send boot messages over UART and corrupt the binary communication with the PC/FPGA.

---

## 6. Device Tree — `boards/app.overlay`

The `boards/app.overlay` file is placed in the `boards/` folder to be automatically picked up by West during the build (named after the target board: `stm32f746g_disco.overlay` or via the generic `app.overlay`).

```dts
&i2c1 {
    status = "okay";
    clock-frequency = <I2C_BITRATE_STANDARD>;   /* 100 kHz */

    pcf8563: pcf8563@51 {
        compatible = "nxp,pcf8563";
        reg = <0x51>;
        status = "okay";
    };
};

/ {
    aliases {
        rtc = &pcf8563;   /* DEVICE_DT_GET(DT_ALIAS(rtc)) in main.c */
    };
};
```

The `rtc` alias is resolved in `main.c` via `DEVICE_DT_GET(DT_ALIAS(rtc))`. If the PCF8563 is physically absent, `device_is_ready()` returns `false` and the application automatically switches to **virtual mode**.

---

## 7. Software Architecture

### Threads and Synchronization

```
┌─────────────────────────────────────────────────────────────┐
│  UART ISR  (interrupt context)                              │
│   uart_cb() → process_uart_rx() → k_sem_give(&cmd_sem)      │
│   Atomic flags: atomic_set(&ui_rx_flash, 1)                 │
└────────────────────┬────────────────────────────────────────┘
                     │ k_sem
┌────────────────────▼────────────────────────────────────────┐
│  Worker thread  (preemptive priority 5)                     │
│   • process_command() — UART command handling               │
│   • sw_clock_tick() every 1,000 ms (if RTC absent)          │
│   • RTC read → k_msgq_put(&ui_time_q)                       │
│   • Alarm check every 500 ms                                │
│   Mutexes: alarm_mutex, sw_clock_mutex, uart_tx_mutex       │
└────────────────────┬────────────────────────────────────────┘
                     │ k_msgq / atomic_t
┌────────────────────▼────────────────────────────────────────┐
│  Main thread  (LVGL loop, 10 ms)                            │
│   ui_update() → lv_task_handler()                           │
│   k_msgq_get(&ui_time_q) → widget update                    │
│   atomic_cas() for RX/TX LEDs and alarm flags               │
└─────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

**`k_msgq` for time data (anti torn-read)**

Time is passed from the worker to main via a message queue (`ui_time_q`, size 2). This guarantees that a `struct ui_time_msg` is copied **atomically** — it is impossible to read a partially updated time. The previous approach (6 `volatile` variables + a `ui_dirty` flag) allowed the compiler to reorder writes.

**`atomic_t` + `atomic_cas()` for flash flags**

Flags `ui_rx_flash`, `ui_tx_flash`, `ui_alarm_evt` are `atomic_t`. The test-and-clear sequence in `ui_update()` uses `atomic_cas(&flag, 1, 0)`, which is atomic in a single Cortex-M7 instruction — unlike `if (volatile_flag) { volatile_flag = false; }` where the ISR can re-assert the flag between the two instructions.

**`alarm_mutex`**

Variables `al_on/sec/min/hour` are accessed from three contexts: the worker (UART commands), the main thread (LVGL touch callback), and the alarm check loop. The mutex guarantees consistency.

**Virtual clock**

When the PCF8563 is absent, `sw_clock` is incremented by `sw_clock_tick()` in the worker thread. The `rtc_get_virtual()` and `rtc_set_virtual()` functions completely abstract this duality — `process_command()` has no knowledge of the active mode.

---

## 8. Binary UART Protocol

The firmware implements the **same protocol** as the FPGA (`hw/`) and the PC software (`sw/`), ensuring full cross-compatibility.

### Frame Format

```
┌──────┬──────┬──────┬────────────────────────┬─────┐
│ SOF  │ CMD  │ LEN  │   PAYLOAD (0–15 B)     │ CRC │
│ 0x55 │ 1 B  │ 1 B  │      LEN bytes         │ 1 B │
└──────┴──────┴──────┴────────────────────────┴─────┘
CRC = CMD ^ LEN ^ payload[0] ^ ... ^ payload[N-1]
```

### Supported Commands

| Code | Command | RX LEN | Expected payload | Response |
|------|---------|--------|-----------------|---------|
| `0x01` | `CMD_GET_ALL` | 0 | — | `SOF 01 06 sec min hr day mon yr CRC` |
| `0x02` | `CMD_SET_ALL` | 6 | sec, min, hr, day, month, year | ACK |
| `0x03` | `CMD_GET_ALARM` | 0 | — | `SOF 03 03 al_sec al_min al_hr CRC` |
| `0x04` | `CMD_SET_ALARM` | 3 | al_sec, al_min, al_hr | ACK |
| `0x05` | `CMD_GET_BAUD` | 0 | — | `SOF 05 01 01 CRC` (fixed 115200) |
| `0x06` | `CMD_SET_BAUD` | 1 | baud_sel | ACK (ignored on STM32 side) |
| `0x07` | `CMD_GET_STATUS` | 0 | — | `SOF 07 01 status CRC` |
| `0x0A` | `CMD_ALARM_EVT` | — | Spontaneously emitted by fw | — |
| `0x0B` | `CMD_TOGGLE_AL` | 1 | 0=OFF, 1=ON | ACK |
| `0x11` | `CMD_GET_TIME` | 0 | — | `SOF 11 03 sec min hr CRC` |
| `0x12` | `CMD_SET_TIME` | 3 | sec, min, hr | ACK |
| `0x13` | `CMD_GET_DATE` | 0 | — | `SOF 13 03 day mon yr CRC` |
| `0x14` | `CMD_SET_DATE` | 3 | day, month, year (2 digits) | ACK |

**Status byte (CMD_GET_STATUS):**

```
Bit 1 : RTC_VIRTUAL  — 1 if PCF8563 is absent (software clock active)
Bit 0 : ALARM_EN     — 1 if alarm is enabled
```

**Date/year convention:** year is transmitted as **2 digits** (e.g. `26` for 2026). The firmware applies the internal offset `tm_year + 100` for the Zephyr `rtc_time` struct (1900 base).

### Reception FSM

```
IDLE ──(SOF=0x55)──► READ_CMD ──► READ_LEN ──► READ_PAYLOAD ──► READ_CRC
                                      │ (len=0)                      │
                                      └──────────────────────────────┘
                                                                      │
                              CRC OK → k_sem_give → process_command()
                              CRC KO → send_nack()
```

The FSM runs in **ISR context** (`uart_cb`). `process_command()` is called in the **worker thread** via the `cmd_sem` semaphore, avoiding long processing in interrupt context.

---

## 9. LVGL Graphical Interface

### Screen layout (480×272)

```
┌──────────────────────────────────────────────────┐  ← topbar 28px
│  ⚙ RTC  STM32F746G              RX ● TX ●       │
├────────────────────────┬─────────────────────────┤
│                        │  14:25:38               │  ← Montserrat 32
│    Analog clock        │  24/03/2026             │  ← Montserrat 14
│       240×244          │  ✓ PCF8563 OK           │  ← Montserrat 10
│                        │  ─────────────          │
│   Hands:               │  🔔 ALARM               │
│   • Hour   : white     │  07:00:30               │  ← Montserrat 20
│   • Minute : teal      │  ┌─────────────────┐    │
│   • Second : orange    │  │  🔔  ON         │    │  ← Touch button
│   (gray if virtual)    │  └─────────────────┘    │
│                        │                         │
│                        │  ⚠ ALARM!               │  ← Blinking 3s
└────────────────────────┴─────────────────────────┘
```

### Visual indicators

| Element | Normal state | Alarm / error state |
|---------|-------------|---------------------|
| Clock border | Teal `#00D4AA` (HW) / Orange `#FF6B35` (virtual) | Red `#FF0000` during shake |
| Second hand | Orange `#FF6B35` (HW) | Gray `#888888` (virtual) |
| Status label | `✓ PCF8563 OK` in teal | `⚠ RTC virtual` in orange |
| RX LED | Off | Teal flash 80 ms on each byte received |
| TX LED | Off | Red flash 80 ms on each byte sent |
| Alarm animation | — | Shake ±10 px, 8 cycles × 60 ms |

---

## 10. Build and Flash

### Prerequisites

A working West workspace with Zephyr 4.2:

```bash
west init ~/zephyrproject
cd ~/zephyrproject
west update
```

### Build

```bash
cd fw/
west build -b stm32f746g_disco -- -DOVERLAY_CONFIG=app.overlay
```

If the overlay is in `boards/` with the correct name (`stm32f746g_disco.overlay`), it is picked up automatically:

```bash
west build -b stm32f746g_disco
```

### Flash

```bash
west flash
```

or via OpenOCD / STM32CubeProgrammer if using the on-board ST-Link.

### Clean

```bash
west build -t clean
# or remove the build directory
rm -rf build/
```

---

## 11. Debugging via RTT

Logs are redirected to **Segger RTT** (not to UART, which is reserved for the binary protocol).

### With JLinkRTTViewer

1. Connect the ST-Link/J-Link to the board.
2. Open JLinkRTTViewer, select `STM32F746IG`, SWD interface, 4 MHz.
3. Logs appear in the RTT terminal.

### With OpenOCD

```bash
openocd -f interface/stlink.cfg -f target/stm32f7x.cfg \
        -c "rtt setup 0x20000000 0x40000 \"SEGGER RTT\"" \
        -c "rtt start" \
        -c "rtt server start 19021 0"
# Then in another terminal:
telnet localhost 19021
```

### Log levels

Default level is `INFO` (`CONFIG_LOG_DEFAULT_LEVEL=3`). Switch to `DEBUG` (level 4) in `prj.conf` to see processed UART commands:

```kconfig
CONFIG_LOG_DEFAULT_LEVEL=4
```

### Expected boot messages

```
[INF] rtc_app: === RTC App starting ===
[INF] rtc_app: UART ready
[INF] rtc_app: RTC PCF8563 ready — hardware mode    ← if connected
[WRN] rtc_app: RTC absent — virtual clock active (set via UART)  ← otherwise
[INF] rtc_app: Display ready
[INF] rtc_app: UI created — RTC mode: HARDWARE (PCF8563)
[INF] rtc_app: Worker started - rtc_available=1
```

---

*Last updated: March 2026* \
*Hugo MALAVAL*