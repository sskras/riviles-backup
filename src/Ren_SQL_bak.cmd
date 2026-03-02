@echo off

rem Batch file for SQL Express DB files rotation
rem version 1.00 (28.11.2018.)
rem Copyright (C) Srdjan Stanisic
rem
rem SQL Express will make a daily backup file with the same name
rem That file will raise in time, as a new backup is appended to existing set
rem This batch file will daily rename this original backup file to a new name with date in it
rem With this trick, we will keep the backup files smaller
rem We will keep N files (or backups for N days)
rem Older files will be deleted
rem 

cls

rem ----- the parameters section ---------

rem the path to DB backup files
set BkpLoc=G:\DB_backup
rem the name of the backup file
set BkpFile=uptivity_backup.bak
rem the fixed part of the new filename
set NoviFajl=uptivity
rem the new extension
set NovaExt=.bak
rem the number of files/days to keep in backup
set BrojFajlova=15

rem --------*********** DON'T TOUCH *************----------------------

rem First, we need to return current date using the WMIC command. The format will be YYYYMMDD
for /f "usebackq tokens=1,2 delims=.,=- " %%i in (`wmic os get localdatetime /value`) do @(
	if %%i==LocalDateTime set tmpdate=%%j
	)

rem We need to extract only the date part and to drop the rest (the time refference)
set mydate=%tmpdate:~0,8%

rem We're composing the path to old file and the name of new one
set YeOldeFile=%BkpLoc%\%BkpFile%
set DatumFile=%NoviFajl%%mydate%%NovaExt%

rem We will rename here ye olde file into the new name
ren %YeOldeFile% %DatumFile%

rem As the final step, we wil delete all files older then BROJFAJLOVA
forfiles /P %BkpLoc% /M *.%NovaExt% /D -%BrojFajlova% /C "cmd /c del @file"
