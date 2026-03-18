# UART-Based RTC Co-Design
### FPGA (VHDL) · STM32 Zephyr RTOS · Python GUI

> 4th-year Digital Circuit Design project — CPE Lyon (ESE, equiv. M1)  
> Full-stack hardware/software implementation: RTL design, embedded firmware, and host application.

---

## Overview

This project implements a complete real-time clock system across three layers of abstraction, connected through a shared binary UART protocol.

A custom RTC was designed from scratch in VHDL on a **Digilent Nexys A7 (Artix-7 100T)** FPGA, and compared in real time against an industrial-grade RTC solution running on a **STM32F746G-DISCO** under **Zephyr RTOS** with a PCF8563 I²C chip. A Python GUI controls both systems simultaneously, measures latency, and logs drift data.

```
┌─────────────────────────────────────────┐
│           Python GUI (sw/)              │
│  Dual serial control · Drift analysis   │
└───────────┬─────────────────┬───────────┘
            │ UART            │ UART
            ▼                 ▼
┌───────────────┐   ┌──────────────────────┐
│  Nexys A7     │   │  STM32F746G-DISCO    │
│  hw/          │   │  fw/                 │
│               │   │                      │
│  Custom RTC   │   │  Zephyr RTOS         │
│  UART IP      │   │  PCF8563 via I²C     │
│  VHDL         │   │  LVGL 9 display      │
└───────────────┘   └──────────────────────┘
```

---

## What was built

### `hw/` — FPGA / RTL (VHDL)

- **UART IP core** designed from scratch: baud rate generator (9600/115200), 2-FF synchronizer for metastability, RX/TX state machines with ×16 oversampling (8N1)
- **Protocol decoder FSM**: 10-state machine handling SOF → CMD → LEN → PAYLOAD → CRC → RESPONSE
- **RTC engine**: HH:MM:SS + DD/MM/YY counters with leap year logic, alarm comparator, RGB LED FSM (IDLE → RED → ROTATING → GREEN)
- **7-segment display**: 8-digit multiplexed at 1 kHz, blinking cursor in settings mode
- Anti-bounce with auto-repeat on buttons, navigation FSM for manual time setting
- VHDL testbenches for UART loopback, RTC rollover, and protocol CRC validation

### `fw/` — STM32F746G-DISCO / Zephyr RTOS (C)

- Same binary protocol as FPGA — fully cross-compatible
- Dual RTC mode: hardware PCF8563 (I²C) or software fallback clock in RAM, transparent to the host
- ISR-driven UART reception → worker thread processing via semaphore
- Thread-safe UI updates using `k_msgq` (no torn reads) and `atomic_cas` flags
- LVGL 9 analog clock face with custom canvas drawing (hand angles via `cosf/sinf`, FPU enabled)
- Alarm with touch button, shake animation, and spontaneous `ALARM_EVENT` frame to host

### `sw/` — Python / Tkinter

- Simultaneous control of both targets on two independent serial ports
- Real-time latency measurement: FPGA response time vs STM32+Zephyr+I²C overhead
- Drift graph (rolling 40-point canvas, cyan curve)
- CSV export for lab report analysis
- Port watchdog with automatic reconnection (handles VM port masking, cable unplug)
- PC time sync to both targets in one click

---

## Protocol

All three layers share the same framing:

```
┌──────┬──────┬──────┬────────────────────────┬─────┐
│ SOF  │ CMD  │ LEN  │   PAYLOAD (0–15 B)     │ CRC │
│ 0x55 │ 1 B  │ 1 B  │      LEN bytes         │ 1 B │
└──────┴──────┴──────┴────────────────────────┴─────┘
CRC = CMD ^ LEN ^ payload[0] ^ ... ^ payload[N-1]
```

15 commands implemented: `GET/SET TIME`, `GET/SET DATE`, `GET/SET ALL`, `GET/SET ALARM`, `TOGGLE ALARM`, `GET/SET BAUD`, `STATUS`, `ALARM_EVENT`.

---

## Stack

| Layer | Technology |
|-------|-----------|
| FPGA RTL | VHDL, Vivado 2020.2, Artix-7 100T |
| Embedded | C, Zephyr RTOS 4.2, STM32F746G |
| Display | LVGL 9, LTDC 480×272, PCF8563 I²C |
| Host | Python 3.10, Tkinter, pyserial |
| Tooling | Git, West, Segger RTT |

---

## Repository structure

```
├── hw/          # RTL sources, testbenches, Vivado project,         
    constraints
├── fw/          # Zephyr application, Device Tree overlay, Kconfig
├── sw/          # Python GUI, requirements, run script
└── reports/     # Lab reports (PDF)
```

Each subsystem has its own detailed README.

---

## Author

**Hugo Malaval** — CPE Lyon, 4th year ESE  
Incoming hardware security intern @ Infineon Technologies, Munich  
[LinkedIn](www.linkedin.com/in/hugo-malaval) · [GitHub](https://github.com/HugoMALAVAL)