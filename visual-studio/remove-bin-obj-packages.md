Visual Studio :arrow_right: Tools :arrow_right: External tools

## Remove bin, obj and package folders

- Title: `Remove bin, obj, packages`
- Command: `C:\Program Files\Git\git-bash.exe`
- Arguments: `-c "find . -name obj -type d -exec rm -rf {} +; find . -name bin -type d -exec rm -rf {} +; find . -name packages -type d -exec rm -rf {} +;"
- Initial directory: `$(SolutionDir)`


## Remove .vs folder
- Title: `Remove .vs`
- Command: `C:\Program Files\Git\git-bash.exe`
- Arguments: `-c "find . -name .vs -type d -exec rm -rf {} +;"
- Initial directory: `$(SolutionDir)`
