#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 {VT|clam|all}"
  exit 1
fi

scan_clam() {
  echo "Lancement du scan Clam AV"
  ./clam.sh | tee clam_output.txt
}

scan_vt() {
  echo "Lancement du scan VirusTotal"
  python3 vt.py | tee vt_output.txt
}

synthese() {
  clear
  echo
  echo "Rapport clam AV :"
  echo
  grep "FOUND" clam_output.txt | \
  awk -F: '{ 
    n = split($1, arr, "/"); 
    virus = $2; 
    gsub(/^ /, "", virus); 
    print arr[n] " : INFECTÉ (" virus ")"
  }' || echo "Aucune détection Clam AV."
  echo 
  echo "Rapport virusTotal :"
  echo
  awk '
    /Vérification hash/ { file=$NF }
    /INFECTE/ && file != "" { print file " : INFECTÉ"; file="" }
  ' vt_output.txt || echo "Aucune détection VirusTotal."

}

case "$1" in
  VT)
    scan_vt
    ;;
  clam)
    scan_clam
    ;;
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