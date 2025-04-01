$ErrorActionPreference = "Stop"

# === Paramètres ===
$CsvPath = "C:\Scripts\users.csv"
$DomaineDN = (Get-ADDomain).DistinguishedName

# === Chargement des données CSV ===
if (-not (Test-Path $CsvPath)) {
    Write-Error "❌ Fichier CSV introuvable : $CsvPath"
    exit 1
}

$Utilisateurs = Import-Csv -Path $CsvPath -Delimiter ','

foreach ($user in $Utilisateurs) {
    $prenom = $user.first_name.Trim()
    $nom = $user.last_name.Trim()
    $baseSam = ($prenom.Substring(0,1) + $nom).ToLower()
    $sam = $baseSam
    $i = 1

    # === Vérification d’unicité du samAccountName ===
    while (Get-ADUser -Filter { SamAccountName -eq $sam } -ErrorAction SilentlyContinue) {
        $sam = "$baseSam$i"
        $i++
    }

    $email = "$sam@tssr.local"
    $ouDN = "OU=$($user.Service),OU=$($user.Site),$DomaineDN"

    Write-Host "🧍 Création de $prenom $nom → $sam ($ouDN)" -ForegroundColor Cyan

    try {
        New-ADUser `
            -Name "$prenom $nom" `
            -GivenName $prenom `
            -Surname $nom `
            -SamAccountName $sam `
            -UserPrincipalName $email `
            -EmailAddress $email `
            -AccountPassword (ConvertTo-SecureString $user.MotDePasse -AsPlainText -Force) `
            -Path $ouDN `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "✅ Utilisateur $sam créé." -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Erreur création $prenom $nom : $_" -ForegroundColor Red
    }
}
