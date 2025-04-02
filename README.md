Prérequis :
- Windows serveur 2022 ou 2025
- Machine Nommé
- IP fixe

Lancer :
```
Invoke-WebRequest -Uri "https://github.com/Nadiuxm/TSSR/archive/refs/heads/main.zip" -OutFile "$env:USERPROFILE\Downloads\main.zip"
```

Créer un dossier Scripts à la racine du C et extraire le contenu de l'archive dedans.

Lancer powershell **EN MODE ADMINISTRATEUR**
```
powershell -ExecutionPolicy Bypass -File "C:\Scripts\setup-ad.ps1"
```
Attendre le redémarrage et loggez vous en admin.

Allez vous faire un café !
