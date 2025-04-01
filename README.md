Invoke-WebRequest -Uri "https://github.com/Nadiuxm/TSSR/archive/refs/heads/main.zip" -OutFile "$env:USERPROFILE\Downloads\main.zip"
powershell -ExecutionPolicy Bypass -File "C:\Scripts\setup-ad.ps1"
