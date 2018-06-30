#REM Generate file with timestamp within Command prompt / DOS
set mydate=%date:~10,4%%date:~4,2%%date:~7,2%
echo "hola mundo" > c:\temp\yourfile-%mydate%.log

#REM check the timestamp
dir c:\temp\*.log
