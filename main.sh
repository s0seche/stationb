#!/bin/bash

SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "$0")" && pwd)}"
LOG_DIR="$SCRIPT_DIR/logs"
VENV_DIR="$SCRIPT_DIR/venv"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/scan_$TIMESTAMP.log"

# Dossier à scanner 
FOLDER="${2:-$HOME/Desktop/analyse_file}"

log() { echo "$@" | tee -a "$LOG_FILE"; }

if [ $# -lt 1 ]; then
  echo "Usage: $0 {VT|clam|all} [dossier]"
  exit 1
fi

if [ -d "$VENV_DIR" ]; then
  source "$VENV_DIR/bin/activate"
fi

scan_clam() {
  log "=== SCAN CLAMAV ==="
  export SCRIPT_DIR
  bash "$SCRIPT_DIR/scripts/clam.sh" "$FOLDER" 2>&1 | tee -a "$LOG_FILE"
}

scan_vt() {
  log "=== SCAN VIRUSTOTAL ==="
  export SCRIPT_DIR
  python3 "$SCRIPT_DIR/scripts/vt.py" "$FOLDER" 2>&1 | tee -a "$LOG_FILE"
}

synthese() {
  log ""
  log "╔══════════════════════════════════════╗"
  log "║       RAPPORT STATION BLANCHE        ║"
  log "╚══════════════════════════════════════╝"
  log "Dossier scanné : $FOLDER"
  log "Date           : $(date)"
  log ""
  log "── Rapport ClamAV ──────────────────────"

  CLAM_INFECTED=$(grep "FOUND" "$LOG_FILE" | awk -F: '{n=split($1,arr,"/"); virus=$2; gsub(/^ /,"",virus); print arr[n] " : INFECTÉ (" virus ")"}')
  if [ -n "$CLAM_INFECTED" ]; then
    echo "$CLAM_INFECTED" | tee -a "$LOG_FILE"
  else
    log "Aucune détection ClamAV."
  fi

  log ""
  log "── Rapport VirusTotal ──────────────────"

  VT_INFECTED=$(grep "INFECTE:" "$LOG_FILE" | sed 's/\[VT\] INFECTE: //')
  if [ -n "$VT_INFECTED" ]; then
    echo "$VT_INFECTED" | tee -a "$LOG_FILE"
  else
    log "Aucune détection VirusTotal."
  fi

  log ""
  log "Log complet : $LOG_FILE"
}

# ── DETECTION CLE USB (désactivée pour tests) ────────────────
# Pour activer : décommenter la ligne suivante
# bash "$SCRIPT_DIR/scripts/usb_watch.sh" &

case "$1" in
  VT)   scan_vt ;;
  clam) scan_clam ;;
  all)
    scan_clam
    scan_vt
    synthese
    ;;
  *)
    echo "Argument invalide. Utilisez VT, clam ou all."
    exit 1
    ;;
esac
