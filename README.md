# Station Blanche


## C'est quoi ?

Une station blanche, c'est un poste dédié à l'analyse de fichiers avant qu'ils entrent dans un réseau d'entreprise. L'idée est simple : on branche une clé USB (**ou on pointe vers un dossier**), on lance l'analyse, et on sait si les fichiers sont sains ou non avant de les copier sur un poste de travail.

Ce projet implémente cette logique avec deux moteurs d'analyse complémentaires :

- **ClamAV** — antivirus open source qui tourne en local. Rapide, pas besoin d'internet, détecte les signatures connues.
- **VirusTotal** — service cloud qui compare le hash SHA256 de chaque fichier contre une base de données de plus de 70 antivirus. Beaucoup plus puissant, mais nécessite une connexion internet et une clé API.
Cette méthode garantit que vos fichiers ne fuient pas et **restent en local **sur votre machine.

Quand un fichier est détecté comme infecté, il est automatiquement déplacé en **quarantaine** et un log est généré avec le détail du scan.

---

## Installation

Cloner le repo puis lancer le script d'installation, il s'occupe de tout :

```bash
git clone https://github.com/s0seche/stationb.git
cd stationb
chmod +x install.sh
./install.sh
```

Ce script installe automatiquement :
- ClamAV et sa base de signatures
- Python 3 avec un environnement virtuel (venv) + la lib `requests`
- Node.js et les dépendances Electron pour l'interface graphique

---

## Configuration

Avant de lancer l'outil, il faut renseigner ta clé API VirusTotal :

```bash
nano config/.env
```
Dans le fichier, remplis la ligne :
```
VT_API_KEY=ta_clé_ici
```

Tu peux obtenir une clé gratuite sur [virustotal.com](https://www.virustotal.com) en créant un compte.

> ⚠️ **Limitation importante de la clé gratuite (Community)**
>
> La clé community de VirusTotal est limitée à **4 requêtes par minute**. Si tu analyses un dossier avec beaucoup de fichiers, le scan VirusTotal va être très lent, voire échouer sur certains fichiers à cause du rate limiting.
>
> Pour une utilisation en production ou avec un volume important de fichiers, il faut passer sur un **abonnement VirusTotal Premium** qui lève ces restrictions. La clé community reste utile pour tester ou pour des scans ponctuels avec peu de fichiers.

---

## Lancer l'outil

### Interface graphique (recommandé)

```bash
cd app
npm start
```

Une fenêtre s'ouvre. Tu sélectionnes le dossier à analyser, tu choisis le type de scan, et tu cliques sur "Lancer l'analyse". La sortie s'affiche en temps réel dans le terminal intégré.

### Ligne de commande

Si tu préfères rester dans le terminal, tu peux utiliser directement `main.sh` depuis la racine du projet :

```bash
# Scan complet (ClamAV + VirusTotal)
./main.sh all /chemin/vers/dossier

# ClamAV uniquement (pas besoin de clé API)
./main.sh clam /chemin/vers/dossier

# VirusTotal uniquement
./main.sh VT /chemin/vers/dossier
```

---

## Activer la détection automatique de clé USB

Par défaut, la détection USB est désactivée pour faciliter les tests. Pour l'activer, ouvre le fichier `scripts/usb_watch.sh` et **décommente** le bloc de code (enlève les `#` devant chaque ligne du bloc) :

```bash
nano scripts/usb_watch.sh
```

Ensuite, lance le watcher en arrière-plan avant de démarrer l'outil :

```bash
bash scripts/usb_watch.sh &
```

Dès qu'une clé USB est branchée et montée, le scan se lance automatiquement sur son contenu.

---

## Structure du projet

```
stationb/
├── main.sh              # Point d'entrée CLI
├── install.sh           # Script d'installation
├── scripts/
│   ├── clam.sh          # Scan ClamAV
│   ├── vt.py            # Scan VirusTotal
│   └── usb_watch.sh     # Détection USB (désactivée par défaut)
├── app/
│   ├── main.js          # Process principal Electron
│   ├── preload.js       # Bridge sécurisé Electron
│   ├── index.html       # Interface graphique
│   └── package.json
├── config/
│   ├── .env             # Clé API — ne jamais commiter ce fichier
│   └── .env.example     # Modèle à copier
├── logs/                # Historique des scans (généré automatiquement)
└── quarantine/          # Fichiers infectés isolés (généré automatiquement)
```
