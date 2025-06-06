# List nuget dependencies

oneliner in Powershell

```powershell
mkdir -p c:\temp -Force; rm c:\temp\packages.txt -ErrorAction SilentlyContinue;dotnet nuget why .\MySolution.sln Newtonsoft.Json | Out-File -FilePath c:\temp\packages.txt -Encoding Unicode; echo "-----------------" >> c:\temp\packages.txt ;dotnet list package --include-transitive >> c:\temp\packages.txt ; code c:\temp\packages.txt
```
