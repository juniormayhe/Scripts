## install a font
https://www.nerdfonts.com/

## install chocolatey and oh my posh
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install oh-my-posh
```

## Create a Microsoft.PowerShell_profile.ps1 file
```
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted
notepad $PROFILE
```
paste the content:
```
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/juniormayhe/Scripts/master/oh-my-posh/juniormayhe.omp.json' | Invoke-Expression
```

## Set Microsoft.PowerShell_profile.ps1 as unrestricted if needed
```
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted
```

# Change terminal fonts
Windows terminal > settings > Profiles > Defaults > Appearance > Text > Font face
