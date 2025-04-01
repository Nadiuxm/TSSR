$ErrorActionPreference = "Stop"

Write-Host "🏗️ Création des OU (avec vérification si déjà existantes)..." -ForegroundColor Cyan

# DN du domaine (ex : DC=tssr,DC=local)
$DomaineDN = (Get-ADDomain).DistinguishedName

# Liste des sites (ajoute ici autant que tu veux)
$Sites = @("Tours", "Bordeaux")

# Liste des sous-OU (sans accents)
$SousOU = @(
    "Direction",
    "Comptabilite",
    "Ressources-humaines",
    "Service-informatique",
    "Logistique",
    "Coordination",
    "Regies"
)

foreach ($site in $Sites) {
    $OUDN = "OU=$site,$DomaineDN"

    # Créer l'OU principale si elle n'existe pas
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$site'" -SearchBase $DomaineDN -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $site -Path $DomaineDN -ProtectedFromAccidentalDeletion $true
        Write-Host "✅ OU $site créée." -ForegroundColor Green
    } else {
        Write-Host "⏩ OU $site existe déjà, on passe." -ForegroundColor Yellow
    }

    # Créer les sous-OU dans chaque site
    foreach ($sou in $SousOU) {
        $SousOUDN = "OU=$sou,OU=$site,$DomaineDN"
        if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$sou'" -SearchBase $OUDN -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $sou -Path $OUDN -ProtectedFromAccidentalDeletion $true
            Write-Host "  ➕ Sous-OU $sou ajoutée à $site" -ForegroundColor Gray
        } else {
            Write-Host "  ⏩ Sous-OU $sou déjà existante dans $site" -ForegroundColor DarkGray
        }
    }
}

Write-Host "`n🎉 Arborescence des OU créée (ou mise à jour) avec succès !" -ForegroundColor Cyan

# === Lancer automatiquement le script d'import des utilisateurs ===
$ScriptImport = "C:\Scripts\import-users.ps1"

if (Test-Path $ScriptImport) {
    Write-Host "`n📦 Lancement de l'import des utilisateurs..." -ForegroundColor Cyan
    powershell.exe -ExecutionPolicy Bypass -File $ScriptImport
} else {
    Write-Host "`n⚠️ Script import-users.ps1 introuvable à l'emplacement : $ScriptImport" -ForegroundColor Red
}
