# Software Subsystem — `sw/`

Interface graphique Python pour le contrôle simultané de la **Nexys A7 (FPGA)** et du **STM32F746G-DISCO (Zephyr)** via le protocole UART binaire partagé.

---

## Table des matières

1. [Structure du répertoire](#1-structure-du-répertoire)
2. [Vue d'ensemble](#2-vue-densemble)
3. [Prérequis](#3-prérequis)
4. [Installation et lancement](#4-installation-et-lancement)
5. [Interface graphique](#5-interface-graphique)
6. [Protocole UART](#6-protocole-uart)
7. [Fonctionnalités détaillées](#7-fonctionnalités-détaillées)
8. [Export CSV](#8-export-csv)
9. [Watchdog et reconnexion automatique](#9-watchdog-et-reconnexion-automatique)
10. [Notes de portabilité](#10-notes-de-portabilité)

---

## 1. Structure du répertoire

```
sw/
├── src/
│   └── rtc_host.py       # Application complète (fichier unique)
├── requirements.txt      # Dépendances Python
├── run.sh                # Script de lancement (Linux / macOS / Git Bash)
└── README.md
```

---

## 2. Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                      rtc_host.py                                │
│                                                                 │
│   ┌────────────────────┐     ┌────────────────────┐            │
│   │  Panneau FPGA      │     │  Panneau STM32     │            │
│   │  📡 Nexys A7       │     │  ⚙️ Zephyr RTOS    │            │
│   │  Heure / Date      │     │  Heure / Date      │            │
│   │  Alarme / Baud     │     │  Alarme / RTC mode │            │
│   └────────┬───────────┘     └────────┬───────────┘            │
│            │ pyserial                  │ pyserial               │
└────────────┼───────────────────────────┼────────────────────────┘
             │ UART 115200 (COM/ttyUSB)  │ UART 115200 (COM/ttyUSB)
             ▼                           ▼
      Nexys A7 (hw/)             STM32F746G-DISCO (fw/)
```

L'application pilote **deux cibles indépendantes** sur deux ports série distincts. Toutes les commandes utilisent le même protocole binaire que le firmware (`hw/` et `fw/`), ce qui permet la validation croisée et la mesure de dérive temporelle entre les deux systèmes.

---

## 3. Prérequis

| Composant | Version minimale | Notes |
|-----------|-----------------|-------|
| Python | **3.10+** | Inclure `tkinter` (standard) |
| pyserial | **3.5+** | `pip install pyserial` |
| tkinter | Inclus Python | Sous Linux : `sudo apt install python3-tk` |
| winsound | Built-in Windows | Son d'alarme ; absent sur Linux/macOS (ignoré silencieusement) |

**Ports série requis :**
- Un port pour la Nexys A7 (via USB-UART FTDI de la carte)
- Un port pour le STM32F746G-DISCO (via CN14, USB micro)

Les deux appareils peuvent être connectés **séparément** — l'application fonctionne avec l'un ou l'autre si l'un est absent.

---

## 4. Installation et lancement

### Méthode 1 — Script automatique (recommandé)

```bash
chmod +x run.sh
./run.sh
```

Le script :
1. Vérifie que Python 3.10+ est disponible.
2. Crée un virtualenv `.venv/` si absent.
3. Installe les dépendances (`pyserial`).
4. Vérifie la présence de `tkinter`.
5. Lance `src/rtc_host.py`.

### Méthode 2 — Installation manuelle

```bash
python3 -m venv .venv
source .venv/bin/activate          # Linux/macOS
# .venv\Scripts\activate           # Windows PowerShell

pip install -r requirements.txt
python3 src/rtc_host.py
```

### Windows (sans Git Bash)

```bat
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python src\rtc_host.py
```

---

## 5. Interface graphique

### Disposition de la fenêtre (1250 × 950 px)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  📡 FPGA (Nexys A7)             ┃  ⚙️ STM32 (Zephyr RTOS)                   │
│  14:25:38  (vert)               ┃  14:25:40  (cyan)                          │
│  24/03/2026                     ┃  24/03/2026                                │
│  🔔 Alarme: 07:00:00            ┃  🔔 Alarme: 07:00:00   ✅ PCF8563         │
├─────────────────────────────────┴──────────────────────────────────────────┤
│  Connexions Matérielles (UART)                                               │
│  FPGA COM: [COM3 ▼] [Connecter FPGA]  ●Déconnecté                          │
│  STM32 COM:[COM4 ▼] [Connecter STM32] ●Déconnecté   [🔄 Rafraîchir]        │
├──────────────────────────────────────────────────────────────────────────────┤
│  Panneau de Contrôle Master                    │  📉 Dérive / Latence        │
│  [GET TIME] [GET DATE] [GET ALARM] [GET ALL]   │                             │
│  [STATUS FPGA] [STATUS STM32]                  │   Graphique temps réel      │
│  [🔔 ALARME ON] [🔕 ALARME OFF] [GET BAUD]    │   Surcoût Zephyr/I2C        │
│  Heure  : [HH] [MM] [SS] [SET FPGA] [SET STM32]│                             │
│  Date   : [JJ] [MM] [AA] [SET FPGA] [SET STM32]│  [💾 Exporter CSV]         │
│  Alarme : [HH] [MM] [SS] [SET FPGA] [SET STM32]│                             │
│  SET ALL : [SET TOUT FPGA] [SET TOUT STM32] [SET AUX DEUX]                  │
│  [⚙️ Sync Heure PC] [☑ Auto-Refresh LCD]                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│  Moniteur Série Unifié (Rx/Tx)                          [🧹 Effacer logs]   │
│  [FPGA-TX]  55 01 00 01  -> (GET TIME)                                       │
│  [FPGA-RX]  55 11 03 0E 19 0E 14  <- (Heure)                                │
│  [STM32-TX] 55 11 00 11  -> (GET TIME)                                       │
│  [STM32-RX] 55 11 03 28 19 0E 24  <- (Heure)                                │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Codes couleur du moniteur série

| Tag | Couleur | Usage |
|-----|---------|-------|
| `fpga_tx` | Vert clair `#a2d149` | Trames envoyées vers FPGA |
| `fpga_rx` | Vert vif `#00ff00` | Trames reçues du FPGA |
| `stm32_tx` | Cyan foncé `#009999` | Trames envoyées vers STM32 |
| `stm32_rx` | Cyan vif `#00ffff` | Trames reçues du STM32 |
| `sys` | Blanc | Messages système |
| `alert` | Rouge `#ff3333` | NACK, alarme déclenchée |
| `warn` | Orange `#ffaa00` | Watchdog, port perdu |

---

## 6. Protocole UART

L'application implémente **exactement** le même protocole que `hw/` et `fw/`.

### Format de trame

```
┌──────┬──────┬──────┬────────────────────────┬─────┐
│ SOF  │ CMD  │ LEN  │   PAYLOAD (0–15 B)     │ CRC │
│ 0x55 │ 1 B  │ 1 B  │      LEN octets        │ 1 B │
└──────┴──────┴──────┴────────────────────────┴─────┘
CRC = CMD ^ LEN ^ payload[0] ^ ... ^ payload[N-1]
```

### Commandes utilisées

| Code | Nom | Direction | Payload |
|------|-----|-----------|---------|
| `0x01` | `CMD_GET_ALL` | PC → cible | — |
| `0x02` | `CMD_SET_ALL` | PC → cible | sec, min, hr, day, month, year |
| `0x03` | `CMD_GET_ALARM` | PC → cible | — |
| `0x04` | `CMD_SET_ALARM` | PC → cible | al_sec, al_min, al_hr |
| `0x05` | `CMD_GET_BAUD` | PC → cible | — |
| `0x06` | `CMD_SET_BAUD` | PC → cible | 0x01=115200, 0x00=9600 |
| `0x07` | `CMD_GET_STATUS` | PC → cible | — |
| `0x0A` | `CMD_ALARM_EVT` | cible → PC | Spontané (alarme déclenchée) |
| `0x0B` | `CMD_TOGGLE_AL` | PC → cible | 0x01=ON, 0x00=OFF |
| `0x11` | `CMD_GET_TIME` | PC → cible | — |
| `0x12` | `CMD_SET_TIME` | PC → cible | sec, min, hr |
| `0x13` | `CMD_GET_DATE` | PC → cible | — |
| `0x14` | `CMD_SET_DATE` | PC → cible | day, month, year (2 chiffres) |

### Décodage du status byte

**FPGA (`CMD_GET_STATUS` 0x07) :**

| Bit | Signification |
|-----|--------------|
| 3 | `ALARM_RINGING` — alarme en train de sonner |
| 2 | `MODE_REGLAGE` — SW(14) levé sur la Nexys A7 |
| 1 | `SW15` — source alarme (1=switches, 0=PC) |
| 0 | `ALARM_EN` — alarme activée |

**STM32 (`CMD_GET_STATUS` 0x07) :**

| Bit | Signification |
|-----|--------------|
| 1 | `RTC_VIRTUAL` — 1 si PCF8563 absent (horloge RAM) |
| 0 | `ALARM_EN` — alarme activée |

---

## 7. Fonctionnalités détaillées

### Connexion et sélection des ports

Au démarrage, la liste des ports disponibles est automatiquement peuplée. Cliquer **Connecter FPGA** / **Connecter STM32** pour ouvrir le port à **115 200 bauds**. La connexion au FPGA déclenche automatiquement un `CMD_GET_STATUS` pour initialiser l'état `hw_switch_local`.

### Auto-Refresh LCD

Cocher **Auto-Refresh LCD** active un polling toutes les **500 ms** :
- `CMD_GET_TIME` + `CMD_GET_STATUS` envoyés au FPGA.
- `CMD_GET_TIME` envoyé au STM32.
- Les trames de polling n'apparaissent **pas** dans le moniteur série (filtre anti-spam).
- Les latences aller-retour sont mesurées et tracées dans le graphique de dérive.

### Synchronisation PC → FPGA & STM32

Le bouton **⚙️ Sync Heure PC** envoie `CMD_SET_ALL` aux deux cibles simultanément avec l'heure système du PC (`datetime.datetime.now()`). Le graphique de dérive est réinitialisé après la synchronisation.

### SET AUX DEUX (SIMULTANÉ)

Envoie `CMD_SET_ALL` aux deux cibles en une seule action, puis réinitialise le graphique pour mesurer la dérive à partir d'un état de référence commun.

### Fenêtre Status FPGA

Le bouton **STATUS FPGA** envoie `CMD_GET_STATUS` et ouvre une popup décodant l'état de l'alarme et la position du switch SW15 (source alarme locale ou PC).

### Fenêtre Status STM32

Le bouton **STATUS STM32** ouvre une popup indiquant l'état de l'alarme et si le STM32 tourne avec le **PCF8563 physique** ou en **mode RTC virtuel** (horloge RAM).

### Gestion SET ALARM avec conflit matériel

Si le switch SW15 de la Nexys A7 est levé (alarme contrôlée par les switches locaux), l'envoi d'un `CMD_SET_ALARM` vers le FPGA affiche un avertissement demandant confirmation avant d'envoyer la commande.

### Son d'alarme

Quand un `CMD_ALARM_EVT (0x0A)` est reçu :
- Depuis le FPGA : `winsound.Beep(1500 Hz, 800 ms)`.
- Depuis le STM32 : `winsound.Beep(750 Hz, 800 ms)`.
- Sur Linux/macOS : pas de son (module `winsound` absent, `HAS_SOUND=False`).

---

## 8. Export CSV

Le bouton **💾 Exporter les Mesures** sauvegarde les mesures de latence collectées pendant l'Auto-Refresh dans un fichier `.csv` (séparateur `;`, compatible Excel français).

### Format du fichier

```
Temps Ecoule (s);Latence FPGA (ms);Latence STM32 (ms);Surcout RTOS (ms)
0,5;8,3;12,1;3,8
1,0;8,1;11,9;3,8
...
```

**Signification des colonnes :**

| Colonne | Description |
|---------|-------------|
| Temps écoulé | Secondes depuis le début ou la dernière synchronisation |
| Latence FPGA | Temps de réponse FPGA à `CMD_GET_TIME` (ms) |
| Latence STM32 | Temps de réponse STM32 à `CMD_GET_TIME` (ms) |
| Surcoût RTOS | Différence STM32 − FPGA (overhead Zephyr + I²C PCF8563) |

> L'export n'est disponible que si l'Auto-Refresh a collecté au moins un point. Un avertissement s'affiche sinon.

---

## 9. Watchdog et reconnexion automatique

Un watchdog vérifie toutes les **2 secondes** que chaque port série répond en appelant `getCTS()`. Cas gérés :

- Câble physiquement débranché.
- Port masqué par une VM (Windows perd les droits → `OSError`).
- Périphérique supprimé par le gestionnaire de périphériques.

En cas de perte de port :
1. Le port est fermé proprement.
2. L'Auto-Refresh est désactivé.
3. Une tentative de **reconnexion automatique** est lancée toutes les **3 secondes** tant que le port réapparaît dans la liste système.

Les événements watchdog apparaissent dans le moniteur série en **orange**.

---

## 10. Notes de portabilité

| OS | Statut | Notes |
|----|--------|-------|
| Windows 10/11 | ✅ Complet | Son d'alarme `winsound` disponible |
| Linux (Ubuntu/Debian) | ✅ | Installer `python3-tk` ; pas de son |
| macOS | ✅ | Installer `python-tk` via Homebrew ; pas de son |

**Noms de ports :**

| OS | FPGA (FTDI) | STM32 (ST-Link) |
|----|-------------|-----------------|
| Windows | `COM3`, `COM4`... | `COM5`, `COM6`... |
| Linux | `/dev/ttyUSB0` | `/dev/ttyACM0` |
| macOS | `/dev/tty.usbserial-*` | `/dev/tty.usbmodem*` |

Sur Linux, ajouter l'utilisateur au groupe `dialout` si accès refusé :

```bash
sudo usermod -aG dialout $USER
# Puis se reconnecter (ou newgrp dialout)
```

---

*Dernière mise à jour : mars 2026* \
*Hugo MALAVAL*