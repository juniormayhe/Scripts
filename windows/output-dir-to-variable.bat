for /f "delims=" %i in ('dir /b *.bak') do @set name=%i
echo %name%
