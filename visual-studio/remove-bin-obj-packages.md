Visual Studio :arrow_right: Tools :arrow_right: External tools

- Title: `Remove bin, obj, packages`
- Command: `C:\Program Files\Git\git-bash.exe`
- Arguments: `-c "echo 'removing bin, obj and packages folders...';find ../ -name obj -type d -exec rm -rf {} +; find ../ -name bin -type d -exec rm -rf {} +; find ../ -name packages -type d -exec rm -rf {} +;echo 'Done!';"`
