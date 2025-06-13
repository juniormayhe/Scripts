# List nuget dependencies

oneliner in Powershell

```powershell
mkdir -p c:\temp -Force; rm c:\temp\packages.txt -ErrorAction SilentlyContinue;dotnet nuget why .\MySolution.sln Newtonsoft.Json | Out-File -FilePath c:\temp\packages.txt -Encoding Unicode; echo "-----------------" >> c:\temp\packages.txt ;dotnet list package --include-transitive >> c:\temp\packages.txt ; code c:\temp\packages.txt
```

$PROFILE script

usage: 
- `package` list packages for first solution found
- `package <Package.Name>` explain where is the package in dependency graph and list packages

```powershell

function Invoke-PackageDiscovery {
    param(
        [Parameter(Mandatory = $false)]
        [string]$PackageName
    )
    
    try {
        # Find the first .sln file
        Write-Host "Searching for .sln file..." -ForegroundColor Yellow
        $slnFile = Get-ChildItem -Path . -Filter "*.sln" -Recurse | Select-Object -First 1
        if ($null -eq $slnFile) {
            Write-Error "No .sln file found in current directory or subdirectories."
            exit 1
        }
        $solutionPath = $slnFile.FullName
        Write-Host "Found solution: $solutionPath" -ForegroundColor Green

        # Create temp directory and clean up previous file
        $tempDir = "C:\temp"
        $outputFile = "$tempDir\packages.txt"
        
        if (!(Test-Path $tempDir)) {
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        }
        
        if (Test-Path $outputFile) {
            Remove-Item $outputFile -Force
        }

        # Initialize output file with UTF-8 encoding
        $null = New-Item -ItemType File -Path $outputFile -Force

        # If package name is provided, run dotnet nuget why
        if ($PackageName) {
            "-" * 80 | Out-File -FilePath $outputFile -Encoding UTF8 -Append
            "PACKAGE WHY:" | Out-File -FilePath $outputFile -Encoding UTF8 -Append
            "-" * 80 | Out-File -FilePath $outputFile -Encoding UTF8 -Append

            
            try {
                # Change to the solution directory first
                $solutionDir = Split-Path $solutionPath -Parent
                Push-Location $solutionDir
                
                # Set console output encoding to UTF-8
                $originalOutputEncoding = [Console]::OutputEncoding
                [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
                
                $whyOutput = & dotnet nuget why $PackageName 2>&1 | Out-String
                
                if ($LASTEXITCODE -eq 0 -and $whyOutput) {
                    $whyOutput | Out-File -FilePath $outputFile -Encoding UTF8 -Append
                } else {
                    "Error running dotnet nuget why: $whyOutput" | Out-File -FilePath $outputFile -Encoding UTF8 -Append
                }
                
                # Restore original encoding
                [Console]::OutputEncoding = $originalOutputEncoding
            } finally {
                Pop-Location
            }
            
            # Add separator
            "-" * 80 | Out-File -FilePath $outputFile -Encoding UTF8 -Append
            "PACKAGE LIST:" | Out-File -FilePath $outputFile -Encoding UTF8 -Append
            "-" * 80 | Out-File -FilePath $outputFile -Encoding UTF8 -Append
        }

        # Run dotnet list package
        
        try {
            # Change to the solution directory first
            $solutionDir = Split-Path $solutionPath -Parent
            Push-Location $solutionDir
            
            # Set console output encoding to UTF-8
            $originalOutputEncoding = [Console]::OutputEncoding
            [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
            
            $listOutput = & dotnet list package --include-transitive 2>&1 | Out-String
            
            if ($LASTEXITCODE -eq 0 -and $listOutput) {
                $listOutput | Out-File -FilePath $outputFile -Encoding UTF8 -Append
            } else {
                $errorMsg = "Error running dotnet list package. Exit code: $LASTEXITCODE"
                if ($listOutput) {
                    $errorMsg += "`nOutput: $listOutput"
                }
                $errorMsg | Out-File -FilePath $outputFile -Encoding UTF8 -Append
                Write-Warning $errorMsg
            }
            
            # Restore original encoding
            [Console]::OutputEncoding = $originalOutputEncoding
        } finally {
            Pop-Location
        }

        & code $outputFile

        Write-Host "Output saved to: $outputFile" -ForegroundColor Cyan

    } catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
        exit 1
    }
}

Set-Alias -Name package -Value Invoke-PackageDiscovery
```
