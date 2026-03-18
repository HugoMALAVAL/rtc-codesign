#!/usr/bin/env bash
# =============================================================================
# run.sh — Lanceur de l'interface Python RTC Monitor
# Compatible : Linux, macOS, Windows (Git Bash / WSL)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN="$SCRIPT_DIR/src/rtc_host.py"
VENV="$SCRIPT_DIR/.venv"

# --- 1. Vérification Python ---
if ! command -v python3 &>/dev/null; then
    echo "[ERREUR] python3 introuvable. Installez Python 3.10+."
    exit 1
fi

PY_VER=$(python3 -c "import sys; print(sys.version_info >= (3,10))")
if [ "$PY_VER" != "True" ]; then
    echo "[AVERTISSEMENT] Python 3.10+ recommandé."
fi

# --- 2. Création du venv si absent ---
if [ ! -d "$VENV" ]; then
    echo "[INFO] Création de l'environnement virtuel..."
    python3 -m venv "$VENV"
fi

# --- 3. Activation du venv ---
if [ -f "$VENV/bin/activate" ]; then
    # Linux / macOS / Git Bash
    source "$VENV/bin/activate"
elif [ -f "$VENV/Scripts/activate" ]; then
    # Windows natif (peu probable ici, mais par sécurité)
    source "$VENV/Scripts/activate"
fi

# --- 4. Installation des dépendances ---
pip install --quiet --upgrade pip
pip install --quiet -r "$SCRIPT_DIR/requirements.txt"

# --- 5. Vérification tkinter (non installable via pip) ---
if ! python3 -c "import tkinter" &>/dev/null; then
    echo "[ERREUR] tkinter est absent."
    echo "  → Ubuntu/Debian : sudo apt install python3-tk"
    echo "  → Fedora        : sudo dnf install python3-tkinter"
    echo "  → macOS (brew)  : brew install python-tk"
    exit 1
fi

# --- 6. Lancement ---
echo "[INFO] Démarrage de RTC Monitor..."
python3 "$MAIN"