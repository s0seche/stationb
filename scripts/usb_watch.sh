#!/bin/bash
# ============================================================
# usb_watch.sh — Détection clé USB (DÉSACTIVÉ pour tests)
# ============================================================
# Pour activer, décommenter le bloc ci-dessous
# et lancer : bash scripts/usb_watch.sh &
#
# SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
#
# echo "[USB] Surveillance des clés USB activée..."
# while true; do
#   inotifywait -e create /media /mnt 2>/dev/null | while read path event dir; do
#     MOUNT_POINT="$path$dir"
#     echo "[USB] Clé USB détectée : $MOUNT_POINT"
#     bash "$SCRIPT_DIR/main.sh" all "$MOUNT_POINT"
#   done
# done

echo "[USB] Détection USB désactivée (mode test)"
echo "[USB] Pour scanner un dossier : ./main.sh all /chemin/vers/dossier"
