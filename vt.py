import os
import hashlib
import requests

folder_scan = "/home/jb/Desktop/analyse_file"
API_KEY = ""
VT_URL = "https://www.virustotal.com/api/v3/files/"

headers = {
    "x-apikey": API_KEY
}

def sha256sum(filename): # Calcul des hash
    h = hashlib.sha256()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def check_hash_virustotal(hash_): # requete de test 
    url = VT_URL + hash_
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        data = response.json()
        stats = data.get("data", {}).get("attributes", {}).get("last_analysis_stats", {})
        if stats.get("malicious", 0) > 0:
            return True
    elif response.status_code == 404:
        print("Aucune détéction sur VT")
        # Hash non trouvé sur VT
        return False
    else:
        print(f"Erreur API VT: {response.status_code}")
    return False

def main():
    infecte = False
    for root, _, files in os.walk(folder_scan):
        for filename in files:
            filepath = os.path.join(root, filename)
            file_hash = sha256sum(filepath)
            print(f"Vérification hash {file_hash} du fichier {filename}")
            if check_hash_virustotal(file_hash):
                print("INFECTE")
                infecte = True

    if not infecte:
        print("Aucun fichier infecté détecté.")

if __name__ == "__main__":
    main()
