@echo off
@cls
echo /-----------------------------------------------/
echo /                                               /
echo /   Mapeando drive compartilhado da equipe      /
echo /                                               /
echo /-----------------------------------------------/
echo .

if "%1"=="" goto erro
if "%1"=="apagar" goto apagar

goto mapeamento

:erro 
echo .
echo Digite o nome da pasta que foi compartilhada no formato \\MAQUINA\PASTA
goto :feito

:apagar
net use Z: /delete
goto feito

:mapeamento
net use Z: "%1" /persistent:yes

:feito
