# command to execute
# powershell -ExecutionPolicy Bypass -File "S:\scripts\iqm-initiator_storepass.ps1"

# Only run once to create the encrypted password file
$securePassword = Read-Host "Enter password for futec" -AsSecureString
$securePassword | ConvertFrom-SecureString | Set-Content -Path "$env:USERPROFILE\secure_password.txt"

# Keep the window open
Read-Host "Press Enter to exit"
