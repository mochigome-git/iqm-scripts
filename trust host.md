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
