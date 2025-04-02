$ErrorActionPreference = "Stop"

# === VARIABLES PERSONNALISABLES ===
$Domaine = "tssr.local"
$NomNetbios = "ADDLAB"
$DSRMPassword = ConvertTo-SecureString "test@1234" -AsPlainText -Force
$ScriptOU = "C:\Scripts\ou.ps1"

# === INSTALLATION DU ROLE ADDS ===
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools | Out-Null

# === PLANIFICATION DE ou.ps1 AU DEMARRAGE SYSTEME (EXECUTIONPOLICY BYPASS) ===
if (Test-Path $ScriptOU) {
    $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\Scripts\ou.ps1"'
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

    Register-ScheduledTask -TaskName "OU-Auto-Run" -Action $Action -Trigger $Trigger -Principal $Principal -Force
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
