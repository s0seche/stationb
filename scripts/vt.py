#!/usr/bin/env python3
# ============================================================
# vt.py — Scan VirusTotal via hash SHA256
# Lit la clé API depuis config/.env
# ============================================================
import os
import sys
import hashlib
import requests
import shutil
from datetime import datetime
from pathlib import Path

# ── Chargement de la clé API depuis config/.env ──────────────
SCRIPT_DIR = Path(os.environ.get("SCRIPT_DIR", Path(__file__).resolve().parent.parent))
ENV_FILE = SCRIPT_DIR / "config" / ".env"

def load_env(filepath):
    env = {}
    if not filepath.exists():
        return env
    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, _, val = line.partition("=")
                env[key.strip()] = val.strip()
    return env

env = load_env(ENV_FILE)
API_KEY = env.get("VT_API_KEY", "")

# ── Config ───────────────────────────────────────────────────
folder_scan = sys.argv[1] if len(sys.argv) > 1 else str(Path.home() / "Desktop" / "analyse_file")
VT_URL = "https://www.virustotal.com/api/v3/files/"
QUARANTINE_DIR = SCRIPT_DIR / "quarantine"
QUARANTINE_DIR.mkdir(exist_ok=True)

headers = {"x-apikey": API_KEY}

def sha256sum(filename):
    h = hashlib.sha256()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def check_hash_virustotal(hash_):
    if not API_KEY:
        print("[VT] ERREUR: Clé API VirusTotal non configurée dans config/.env")
        return None
    url = VT_URL + hash_
    try:
        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            stats = data.get("data", {}).get("attributes", {}).get("last_analysis_stats", {})
            return {
                "malicious": stats.get("malicious", 0),
                "suspicious": stats.get("suspicious", 0),
                "stats": stats
            }
        elif response.status_code == 404:
            return {"malicious": 0, "suspicious": 0, "stats": {}}
        else:
            print(f"[VT] Erreur API: {response.status_code}")
            return None
    except Exception as e:
        print(f"[VT] Erreur réseau: {e}")
        return None

def quarantine_file(filepath):
    dest = QUARANTINE_DIR / Path(filepath).name
    shutil.move(filepath, dest)
    print(f"[VT] QUARANTAINE: {filepath} → {dest}")

def main():
    print(f"[VT] Démarrage du scan sur : {folder_scan}")
    print(f"[VT] Date : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    infected = False

    for root, _, files in os.walk(folder_scan):
        for filename in files:
            filepath = os.path.join(root, filename)
            file_hash = sha256sum(filepath)
            print(f"[VT] Vérification hash {file_hash} du fichier {filename}")

            result = check_hash_virustotal(file_hash)
            if result is None:
                continue

            if result["malicious"] > 0:
                print(f"[VT] INFECTE: {filename} ({result['malicious']} détections)")
                quarantine_file(filepath)
                infected = True
            elif result["suspicious"] > 0:
                print(f"[VT] SUSPECT: {filename} ({result['suspicious']} détections suspectes)")
            else:
                print(f"[VT] CLEAN: {filename}")

    if not infected:
        print("[VT] STATUS:CLEAN")
    else:
        print("[VT] STATUS:INFECTED")

if __name__ == "__main__":
    main()
