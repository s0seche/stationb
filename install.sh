#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║    INSTALLATION STATION BLANCHE      ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── 1. Dépendances système
echo "[1/4] Installation des dépendances système..."
sudo apt update -qq
sudo apt install -y \
  clamav \
  clamav-daemon \
  python3 \
  python3-pip \
  python3-venv \
  inotify-tools \
  libnss3 \
  libatk1.0-0t64 \
  libatk-bridge2.0-0t64 \
  libcups2t64 \
  libdrm2 \
  libxkbcommon0 \
  libxcomposite1 \
  libxdamage1 \
  libxfixes3 \
  libxrandr2 \
  libgbm1 \
  libasound2t64

echo "[1/4] ✓ Dépendances système installées"

# ── 2. Mise à jour base ClamAV 
echo ""
echo "[2/4] Mise à jour de la base de signatures ClamAV..."
sudo freshclam
echo "[2/4] ✓ Base ClamAV à jour"

# ── 3. Environnement Python (venv)
echo ""
echo "[3/4] Création de l'environnement Python virtuel..."
python3 -m venv "$SCRIPT_DIR/venv"
source "$SCRIPT_DIR/venv/bin/activate"
pip install --upgrade pip -q
pip install requests -q
deactivate
echo "[3/4] ✓ venv créé avec les dépendances Python"

# ── 4. Dépendances Node.js (Electron)
echo ""
echo "[4/4] Installation des dépendances Node.js..."
if ! command -v node &>/dev/null; then
  echo "Node.js non trouvé. Installation..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
fi
cd "$SCRIPT_DIR/app" && npm install -q
echo "[4/4] ✓ Dépendances Node.js installées"

# ── Permissions 
chmod +x "$SCRIPT_DIR/main.sh"
chmod +x "$SCRIPT_DIR/scripts/"*.sh
chmod +x "$SCRIPT_DIR/scripts/"*.py

# ── Config .enV
echo ""
if [ ! -f "$SCRIPT_DIR/config/.env" ] || ! grep -q "VT_API_KEY=." "$SCRIPT_DIR/config/.env"; then
  echo "  Clé API VirusTotal manquante."
  echo "   Renseigne-la dans : config/.env"
  echo "   VT_API_KEY=ta_clé_ici"
fi

echo ""
echo "╔══════════════════════════════════════╗"
echo "║         INSTALLATION TERMINÉE        ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "  Lancer la GUI  : cd app && npm start"
echo "  Lancer en CLI  : ./main.sh all /dossier"
echo ""
