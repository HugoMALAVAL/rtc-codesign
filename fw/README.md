# Firmware Subsystem — `fw/`

Application Zephyr RTOS pour la carte **STM32F746G-DISCO**, implémentant une horloge temps réel avec interface graphique LVGL 9 et pilotage par UART binaire.

---

## Table des matières

1. [Structure du répertoire](#1-structure-du-répertoire)
2. [Vue d'ensemble](#2-vue-densemble)
3. [Matériel requis](#3-matériel-requis)
4. [Dépendances logicielles](#4-dépendances-logicielles)
5. [Configuration du projet](#5-configuration-du-projet)
6. [Device Tree — `boards/app.overlay`](#6-device-tree--boardsappoverlay)
7. [Architecture logicielle](#7-architecture-logicielle)
8. [Protocole UART binaire](#8-protocole-uart-binaire)
9. [Interface graphique LVGL](#9-interface-graphique-lvgl)
10. [Compilation et flash](#10-compilation-et-flash)
11. [Débogage via RTT](#11-débogage-via-rtt)

---

## 1. Structure du répertoire

```
fw/
├── src/
│   └── main.c              # Application complète (unique fichier source)
├── boards/
│   └── app.overlay         # Surcharge Device Tree : PCF8563 sur I2C1
├── prj.conf                # Configuration Kconfig (Zephyr 4.2)
├── CMakeLists.txt          # Build system
└── README.md
```

> **Note :** l'application tient en un seul fichier `main.c`, ce qui simplifie la compilation et la lecture du code.

---

## 2. Vue d'ensemble

```
STM32F746G-DISCO
│
├── LCD LTDC 480×272 ──── LVGL 9 ──── Horloge analogique + panneau de contrôle
├── Écran tactile ──────── INPUT ───── Bouton ON/OFF alarme
├── UART (USB-UART) ────── Protocole binaire ── ↔ Nexys A7 (hw/) ou PC (sw/)
└── I2C1 ───────────────── PCF8563 ─── RTC physique (OPTIONNEL)
```

**Mode de fonctionnement :**

| Condition | Mode | Comportement |
|-----------|------|-------------|
| PCF8563 détecté | **Hardware** | Heure lue/écrite sur le RTC physique |
| PCF8563 absent | **Virtuel** | Horloge logicielle en RAM, incrémentée par le worker |

Dans les deux cas, l'interface UART reste **identique** — le programme Python (`sw/`) ou le FPGA (`hw/`) n'a pas à gérer la différence.

---

## 3. Matériel requis

| Composant | Rôle | Obligatoire |
|-----------|------|-------------|
| STM32F746G-DISCO | Carte principale | ✅ |
| PCF8563 (adresse I2C `0x51`) | RTC basse consommation | ❌ (fallback logiciel) |
| Câble USB-micro (CN14) | Flash + UART vers PC/FPGA | ✅ |
| J-Link ou ST-Link intégré | Débogage RTT | ✅ |

**Brochage I2C1 (si PCF8563 branché) :**

| Signal | Broche STM32F746G-DISCO |
|--------|------------------------|
| SDA    | PB9 (Arduino D14)      |
| SCL    | PB8 (Arduino D15)      |
| VCC    | 3.3 V                  |
| GND    | GND                    |

---

## 4. Dépendances logicielles

| Outil / Bibliothèque | Version | Notes |
|----------------------|---------|-------|
| Zephyr RTOS | **4.2** | West workspace |
| LVGL | **9.x** | Intégré dans Zephyr (`CONFIG_LVGL=y`) |
| West | ≥ 1.2 | Gestionnaire de build Zephyr |
| Arm GNU Toolchain | ≥ 13 | `arm-zephyr-eabi` |
| J-Link RTT Viewer | Toute version | Logs de débogage (optionnel) |

---

## 5. Configuration du projet

### `prj.conf`

| Section | Options clés | Description |
|---------|-------------|-------------|
| I2C / RTC | `CONFIG_I2C=y` `CONFIG_RTC_PCF8563=y` | Driver PCF8563, non fatal si absent |
| UART | `CONFIG_UART_INTERRUPT_DRIVEN=y` `CONFIG_UART_CONSOLE=n` | Mode binaire silencieux — la console Zephyr est désactivée pour ne pas parasiter le protocole |
| Debug | `CONFIG_LOG_BACKEND_RTT=y` `CONFIG_LOG_DEFAULT_LEVEL=3` | Logs redirigés vers Segger RTT (niveau INFO) |
| Affichage | `CONFIG_DISPLAY=y` `CONFIG_INPUT=y` | LTDC + tactile |
| LVGL | `CONFIG_LV_Z_MEM_POOL_SIZE=32768` `CONFIG_LV_COLOR_DEPTH_16=y` | Pool 32 kB, 16 bpp RGB565 |
| Fonts | `MONTSERRAT_10/12/14/20/32` | Tailles utilisées dans l'UI |
| FPU | `CONFIG_FPU=y` `CONFIG_FPU_SHARING=y` | Requis pour `cosf/sinf` dans le dessin des aiguilles |
| Kernel | `CONFIG_MAIN_STACK_SIZE=4096` `CONFIG_HEAP_MEM_POOL_SIZE=16384` | Stacks et heap |

> ⚠️ `CONFIG_UART_CONSOLE=n` et `CONFIG_CONSOLE=n` sont **critiques** : sans eux, Zephyr enverrait ses messages de boot sur l'UART et corromprait la communication binaire avec le PC/FPGA.

---

## 6. Device Tree — `boards/app.overlay`

Le fichier `boards/app.overlay` est placé dans le dossier `boards/` pour être automatiquement pris en compte par West lors du build (nommage selon la board cible : `stm32f746g_disco.overlay` ou via `app.overlay` générique).

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
        rtc = &pcf8563;   /* DEVICE_DT_GET(DT_ALIAS(rtc)) dans main.c */
    };
};
```

L'alias `rtc` est résolu dans `main.c` par `DEVICE_DT_GET(DT_ALIAS(rtc))`. Si le PCF8563 est physiquement absent, `device_is_ready()` retourne `false` et l'application bascule automatiquement en **mode virtuel**.

---

## 7. Architecture logicielle

### Threads et synchronisation

```
┌─────────────────────────────────────────────────────────────┐
│  ISR UART  (contexte interruption)                          │
│   uart_cb() → process_uart_rx() → k_sem_give(&cmd_sem)     │
│   Flags atomiques : atomic_set(&ui_rx_flash, 1)            │
└────────────────────┬────────────────────────────────────────┘
                     │ k_sem
┌────────────────────▼────────────────────────────────────────┐
│  Thread worker  (priorité préemptive 5)                     │
│   • process_command() — traitement UART                     │
│   • sw_clock_tick() toutes les 1 000 ms (si RTC absent)     │
│   • Lecture RTC → k_msgq_put(&ui_time_q)                    │
│   • Vérification alarme toutes les 500 ms                   │
│   Mutex : alarm_mutex, sw_clock_mutex, uart_tx_mutex        │
└────────────────────┬────────────────────────────────────────┘
                     │ k_msgq / atomic_t
┌────────────────────▼────────────────────────────────────────┐
│  Thread main  (boucle LVGL, 10 ms)                         │
│   ui_update() → lv_task_handler()                           │
│   Lecture k_msgq_get(&ui_time_q) → mise à jour widgets      │
│   atomic_cas() pour LEDs RX/TX et flags alarme              │
└─────────────────────────────────────────────────────────────┘
```

### Choix de conception importants

**`k_msgq` pour l'heure (anti torn-read)**

L'heure est transmise du worker vers main via une message queue (`ui_time_q`, taille 2). Ceci garantit qu'un `struct ui_time_msg` est copié **atomiquement** — il est impossible de lire une heure partiellement mise à jour. L'ancienne approche (6 `volatile` + un flag `ui_dirty`) permettait au compilateur de réordonner les écritures.

**`atomic_t` + `atomic_cas()` pour les flags flash**

Les flags `ui_rx_flash`, `ui_tx_flash`, `ui_alarm_evt` sont des `atomic_t`. La séquence test-and-clear dans `ui_update()` utilise `atomic_cas(&flag, 1, 0)`, qui est atomique en une instruction Cortex-M7 — contrairement à un `if (volatile_flag) { volatile_flag = false; }` où l'ISR peut lever le flag entre les deux instructions.

**Mutex `alarm_mutex`**

Les variables `al_on/sec/min/hour` sont accédées depuis trois contextes : le worker (commandes UART), le thread main (callback tactile LVGL), et la boucle de vérification. Le mutex garantit la cohérence.

**Horloge virtuelle**

Quand le PCF8563 est absent, `sw_clock` est incrémentée par `sw_clock_tick()` dans le worker. Les fonctions `rtc_get_virtual()` et `rtc_set_virtual()` abstraient complètement cette dualité — `process_command()` n'a pas connaissance du mode actif.

---

## 8. Protocole UART binaire

Le firmware implémente le **même protocole** que le FPGA (`hw/`) et le logiciel PC (`sw/`), assurant une compatibilité totale.

### Format de trame

```
┌──────┬──────┬──────┬────────────────────────┬─────┐
│ SOF  │ CMD  │ LEN  │   PAYLOAD (0–15 B)     │ CRC │
│ 0x55 │ 1 B  │ 1 B  │      LEN octets        │ 1 B │
└──────┴──────┴──────┴────────────────────────┴─────┘
CRC = CMD ^ LEN ^ payload[0] ^ ... ^ payload[N-1]
```

### Commandes supportées

| Code | Commande | LEN RX | Payload attendu | Réponse |
|------|----------|--------|-----------------|---------|
| `0x01` | `CMD_GET_ALL` | 0 | — | `SOF 01 06 sec min hr day mon yr CRC` |
| `0x02` | `CMD_SET_ALL` | 6 | sec, min, hr, day, month, year | ACK |
| `0x03` | `CMD_GET_ALARM` | 0 | — | `SOF 03 03 al_sec al_min al_hr CRC` |
| `0x04` | `CMD_SET_ALARM` | 3 | al_sec, al_min, al_hr | ACK |
| `0x05` | `CMD_GET_BAUD` | 0 | — | `SOF 05 01 01 CRC` (fixe 115200) |
| `0x06` | `CMD_SET_BAUD` | 1 | baud_sel | ACK (ignoré côté STM32) |
| `0x07` | `CMD_GET_STATUS` | 0 | — | `SOF 07 01 status CRC` |
| `0x0A` | `CMD_ALARM_EVT` | — | Émis spontanément par le fw | — |
| `0x0B` | `CMD_TOGGLE_AL` | 1 | 0=OFF, 1=ON | ACK |
| `0x11` | `CMD_GET_TIME` | 0 | — | `SOF 11 03 sec min hr CRC` |
| `0x12` | `CMD_SET_TIME` | 3 | sec, min, hr | ACK |
| `0x13` | `CMD_GET_DATE` | 0 | — | `SOF 13 03 day mon yr CRC` |
| `0x14` | `CMD_SET_DATE` | 3 | day, month, year (2 chiffres) | ACK |

**Status byte (CMD_GET_STATUS) :**

```
Bit 1 : RTC_VIRTUAL  — 1 si le PCF8563 est absent (horloge logicielle active)
Bit 0 : ALARM_EN     — 1 si l'alarme est activée
```

**Convention date/année :** l'année est transmise sur **2 chiffres** (ex. : `26` pour 2026). Le firmware applique l'offset interne `tm_year + 100` pour la struct Zephyr `rtc_time` (base 1900).

### FSM de réception

```
IDLE ──(SOF=0x55)──► READ_CMD ──► READ_LEN ──► READ_PAYLOAD ──► READ_CRC
                                      │ (len=0)                      │
                                      └──────────────────────────────┘
                                                                      │
                              CRC OK → k_sem_give → process_command()
                              CRC KO → send_nack()
```

La FSM tourne dans le contexte **ISR** (`uart_cb`). `process_command()` est appelée dans le **worker thread** via le sémaphore `cmd_sem`, ce qui évite les traitements longs en contexte d'interruption.

---

## 9. Interface graphique LVGL

### Disposition écran 480×272

```
┌──────────────────────────────────────────────────┐  ← topbar 28px
│  ⚙ RTC  STM32F746G              RX ● TX ●       │
├────────────────────────┬─────────────────────────┤
│                        │  14:25:38               │  ← Montserrat 32
│    Horloge analogique  │  24/03/2026             │  ← Montserrat 14
│       240×244          │  ✓ PCF8563 OK           │  ← Montserrat 10
│                        │  ─────────────          │
│   Aiguilles :          │  🔔 ALARME              │
│   • Heure  : blanche   │  07:00:30               │  ← Montserrat 20
│   • Minute : teal      │  ┌─────────────────┐    │
│   • Seconde: orange    │  │  🔔  ON         │    │  ← Bouton tactile
│   (grise si virtuel)   │  └─────────────────┘    │
│                        │                         │
│                        │  ⚠ ALARME !             │  ← Clignotant 3s
└────────────────────────┴─────────────────────────┘
```

### Indicateurs visuels

| Élément | État normal | État alarme / erreur |
|---------|-------------|---------------------|
| Bordure horloge | Teal `#00D4AA` (HW) / Orange `#FF6B35` (virtuel) | Rouge `#FF0000` pendant la secousse |
| Trotteuse | Orange `#FF6B35` (HW) | Grise `#888888` (virtuel) |
| Label statut | `✓ PCF8563 OK` en teal | `⚠ RTC virtuel` en orange |
| LED RX | Off | Flash teal 80 ms à chaque octet reçu |
| LED TX | Off | Flash rouge 80 ms à chaque octet émis |
| Animation alarme | — | Secousse ±10 px, 8 cycles × 60 ms |

---

## 10. Compilation et flash

### Prérequis

Avoir un workspace West fonctionnel avec Zephyr 4.2 :

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

Si l'overlay est dans `boards/` avec le bon nom (`stm32f746g_disco.overlay`), il est pris automatiquement :

```bash
west build -b stm32f746g_disco
```

### Flash

```bash
west flash
```

ou via OpenOCD / STM32CubeProgrammer si le ST-Link intégré est utilisé.

### Nettoyer

```bash
west build -t clean
# ou supprimer le dossier build/
rm -rf build/
```

---

## 11. Débogage via RTT

Les logs sont redirigés vers **Segger RTT** (pas vers l'UART, qui est réservé au protocole binaire).

### Avec JLinkRTTViewer

1. Connecter le ST-Link/J-Link à la carte.
2. Ouvrir JLinkRTTViewer, sélectionner `STM32F746IG`, interface SWD, 4 MHz.
3. Les logs apparaissent dans le terminal RTT.

### Avec OpenOCD

```bash
openocd -f interface/stlink.cfg -f target/stm32f7x.cfg \
        -c "rtt setup 0x20000000 0x40000 \"SEGGER RTT\"" \
        -c "rtt start" \
        -c "rtt server start 19021 0"
# Puis dans un autre terminal :
telnet localhost 19021
```

### Niveaux de log

Le niveau par défaut est `INFO` (`CONFIG_LOG_DEFAULT_LEVEL=3`). Passer à `DEBUG` (niveau 4) dans `prj.conf` pour voir les commandes UART traitées :

```kconfig
CONFIG_LOG_DEFAULT_LEVEL=4
```

### Messages attendus au démarrage

```
[INF] rtc_app: === RTC App starting ===
[INF] rtc_app: UART ready
[INF] rtc_app: RTC PCF8563 ready — hardware mode    ← si branché
[WRN] rtc_app: RTC absent — virtual clock active (set via UART)  ← sinon
[INF] rtc_app: Display ready
[INF] rtc_app: UI created — RTC mode: HARDWARE (PCF8563)
[INF] rtc_app: Worker started - rtc_available=1
```

---

*Dernière mise à jour : mars 2026* \
*Hugo MALAVAL*