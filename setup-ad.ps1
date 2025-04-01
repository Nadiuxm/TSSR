$ErrorActionPreference = "Stop"

# === VARIABLES PERSONNALISABLES ===
$Domaine = "tssr.local"
$NomNetbios = "ADDLAB"
$DSRMPassword = ConvertTo-SecureString "test@1234" -AsPlainText -Force
$ScriptOU = "C:\Scripts\ou.ps1"

# === INSTALLATION DU ROLE ADDS ===
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools | Out-Null

# === AJOUT DE ou.ps1 AU DEMARRAGE (RunOnce) AVEC EXECUTIONPOLICY BYPASS ===
if (Test-Path $ScriptOU) {
    $RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    $Cmd = 'powershell.exe -ExecutionPolicy Bypass -File "C:\Scripts\ou.ps1"'
    New-ItemProperty -Path $RunOnceKey -Name "RunOU" -PropertyType String -Value $Cmd -Force
} else {
    Write-Error "Le script $ScriptOU est introuvable. Place-le avant d’exécuter setup-ad.ps1."
    exit 1
}

# === PROMOTION EN CONTROLEUR DE DOMAINE + CREATION FORET ===
Install-ADDSForest `
    -DomainName $Domaine `
    -DomainNetbiosName $NomNetbios `
    -SafeModeAdministratorPassword $DSRMPassword `
    -InstallDns `
    -NoRebootOnCompletion:$false `
    -Force:$true
