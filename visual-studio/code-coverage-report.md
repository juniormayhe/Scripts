```batch
@echo off
echo [92mGenerates code coverage analysis to coveragereport folder [0m
echo [92mATTENTION! Run this within solution folder [0m
echo.
echo Your Xunit projects must have defined test category. To have test category defined for the whole test assembly,
echo In your Xunit project add a Properties\AssemblyInfo.cs with:
echo [93m    using Xunit;[0m
echo [93m   [assembly: AssemblyTrait("Category", "Unit")][0m
echo.
echo [92mInstalling dotnet tool if not present... [0m
dotnet tool install --global dotnet-reportgenerator-globaltool > nul
echo removing code coverage temporary files...
rmdir coveragereport /s /q
rmdir TestResults /s /q
echo.
echo [92mRunning tests... [0m
dotnet test MySolution.sln --filter Category=Unit --configuration Release --logger:trx --results-directory TestResults/ --collect:"XPlat Code Coverage" --settings tests/coverlet.runsettings --no-restore
echo.
echo [92mGenerating report... [0m
reportgenerator -reports:TestResults/**/coverage.opencover.xml -targetdir:coveragereport -reporttypes:Html
echo.
echo [92mDone! [0m
START /B .\coveragereport\index.htm

```
In DOS or Notepad++, escape symbol for Windows 10 and above can be entered with `ALT` + `027` or `CTRL` + `[`.
- Green color = `^[[92m` (in notepad++ displays `ESC[92m`)
- Default color = `^[[0m` 
