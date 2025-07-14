### Config on remote machine
### Enable WinRM service on remote machine
```
winrm quickconfig
```
🟢 If not already configured, you’ll see:
```
WinRM is not set up to receive requests on this machine.
Do you want to enable the WinRM service? [y/n]
```

Type y to allow:
- Start the WinRM service.
- Set it to auto-start.
- Create a firewall exception for TCP port 5985 (HTTP).

### ✅Fix if the network connection is Public
#### Show network connection list
```
Get-NetConnectionProfile
```
#### Change target network from Public network to Private
```
Set-NetConnectionProfile -Name "network name" -NetworkCategory Private
```

### Add Remote IP to TrustedHosts

#### Single machine
```
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.100.0.50"
```

#### Multiple machines
```
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"  # Trust all (⚠️ less secure)
```

#### Verify
```
Get-Item WSMan:\localhost\Client\TrustedHosts
```

#### Test connection
```
Test-WSMan 192.100.0.50
```
