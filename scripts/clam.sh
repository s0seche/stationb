#!/bin/bash

# clam.sh — Scan ClamAV avec quarantaine

SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
QUARANTINE_DIR="$SCRIPT_DIR/quarantine"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$QUARANTINE_DIR" "$LOG_DIR"

folder_scan="${1:-/home/$USER/Desktop/analyse_file}"

echo "[CLAM] Démarrage du scan sur : $folder_scan"
echo "[CLAM] Date : $(date)"

clamscan -r --infected --move="$QUARANTINE_DIR" "$folder_scan" 2>&1
status=$?

case $status in
  0) echo "[CLAM] STATUS:CLEAN" ;;
  1) echo "[CLAM] STATUS:INFECTED" ;;
  2) echo "[CLAM] STATUS:ERROR" ;;
esac

exit $status
