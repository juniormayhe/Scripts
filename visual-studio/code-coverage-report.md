@echo off
echo Generates code coverage analysis to coveragereport folder.
echo ATTENTION! Run this within solution folder
echo.
echo Your Xunit projects must have defined test category. To have test category defined for the whole test assembly,
echo In your Xunit project add a Properties\AssemblyInfo.cs with:
echo    using Xunit;
echo   [assembly: AssemblyTrait("Category", "Unit")]
echo.
echo Installing dotnet tool if not present...
dotnet tool install --global dotnet-reportgenerator-globaltool > nul
echo removing code coverage temporary files...
rmdir coveragereport /s /q
rmdir TestResults /s /q
echo.
echo testing...
dotnet test MySolution.sln --filter Category=Unit --configuration Release --logger:trx --results-directory TestResults/ --collect:"XPlat Code Coverage" --settings tests/coverlet.runsettings --no-restore
echo.
echo generating report...
reportgenerator -reports:TestResults/**/coverage.opencover.xml -targetdir:coveragereport -reporttypes:Html
echo.
echo done!
.\coveragereport\index.htm
