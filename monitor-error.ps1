$logDir = "S:\www\IQM\Logfiles\DataConverterLog"
$errorPattern = "ImageCopy Retry Over"
$remoteComputer = "192.100.0.50"
$remoteUser = "futec"

# Keep track of last detection time
$lastHandledTime = [datetime]::MinValue


# Prerequisites on Target PC (only once):
# Enable-PSRemoting -Force
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
#   -Name "LocalAccountTokenFilterPolicy" -Value 1 -Type DWord -Force


while ($true) {
    Write-Host "`n[INFO] Checking logs at $(Get-Date)..."

    $cutoffTime = (Get-Date).AddMinutes(-10)
    $logFiles = Get-ChildItem -Path $logDir -Filter "DataConvert*.log" | Sort-Object LastWriteTime -Descending

    $errorDetected = $false

    foreach ($file in $logFiles) {
        if ($file.LastWriteTime -lt $cutoffTime) {
            continue
        }

        $lines = Get-Content $file.FullName

        foreach ($line in $lines) {
            if ($line -match '^\[(?<date>\d{4}/\d{2}/\d{2})\],\[(?<time>\d{2}:\d{2}:\d{2})' -and $line -match $errorPattern) {
                try {
                    $logTime = Get-Date "$($matches['date']) $($matches['time'])"
                } catch {
                    Write-Host "❌ Failed to parse datetime from log line: $line"
                    continue
                }


                if ($logTime -ge $cutoffTime -and $logTime -gt $lastHandledTime) {
                    Write-Host "`n[ALERT] Detected error at $logTime in file: $($file.Name)"
                    Write-Host "[ACTION] Updating registry on $remoteComputer"

                    try {
                        # Automatically load secure password from encrypted file
                        $encryptedPasswordPath = "$env:USERPROFILE\secure_password.txt"
                        if (-Not (Test-Path $encryptedPasswordPath)) {
                            Write-Host "❌ Encrypted password file not found: $encryptedPasswordPath"
                            exit 1
                        }

                        $securePass = Get-Content -Path $encryptedPasswordPath | ConvertTo-SecureString
                        $cred = New-Object System.Management.Automation.PSCredential ($remoteUser, $securePass)


                        Invoke-Command -ComputerName $remoteComputer -Credential $cred -ScriptBlock {
                            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
                                             -Name "LocalAccountTokenFilterPolicy" -Value 1 -Type DWord -Force
                            Write-Output "Registry key updated on $env:COMPUTERNAME"
                        }

                        $lastHandledTime = $logTime
                        $errorDetected = $true
                        break
                    }
                    catch {
                        Write-Host "❌ Failed to update registry: $_"
                    }
                }
            }
        }

        if ($errorDetected) { break }
    }

    Start-Sleep -Seconds 60  # Check every 60 seconds
}
