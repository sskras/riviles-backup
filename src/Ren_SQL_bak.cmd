@echo off

: SPDX-License-Identifier: BlueOak-1.0.0
: SPDX-FileCopyrightText: 2018 Srđan Stanišić <https://www.linkedin.com/in/srdjanstanisic/> | MiViLiSNet
: SPDX-FileCopyrightText: 2025 Olegas Malikovas <olegasm_at_gmail_point_com>> | v1p3r
:
: Via: https://mivilisnet.wordpress.com/2019/04/25/rotating-sql-backup-files/


: Rotate MS SQL database backup files.


:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

net stop mssql$sqlexpress
rem XCOPY c:\RIV_GAMA\*.* c:\Backup\RIV_GAMA\ /E /Y /R
XCOPY "c:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\*.*" c:\Backup\data\ /E /Y /R
XCOPY "c:\Db\*.*" c:\Backup\Db\ /E /Y /R
robocopy c:\Backup\Db\ c:\Backup\Euremsta\ EUREMSTAEUR* /mov
net start mssql$sqlexpress
rem *pause

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

rem cls

rem ----- the parameters section ---------

rem the path to DB backup files
rem set BkpLoc=c:\Backup\Db
set BkpLoc=c:\Backup\Euremsta
set BkpLoc2=\\192.168.11.11\Backup\srv\Euremsta
rem the name of the backup file
set BkpFile1=EUREMSTAEUR_Data.mdf
set BkpFile2=EUREMSTAEUR_Log.ldf
rem the fixed part of the new filename
set NoviFajl1=EUREMSTAEUR_Data
set NoviFajl2=EUREMSTAEUR_Log
rem the new extension
set NovaExt1=.mdf
set NovaExt2=.ldf
rem the number of files/days to keep in backup
set BrojFajlova=7

rem --------*********** DON'T TOUCH *************----------------------

rem First, we need to return current date using the WMIC command. The format will be YYYYMMDD
for /f "usebackq tokens=1,2 delims=.,=- " %%i in (`wmic os get localdatetime /value`) do @(
	if %%i==LocalDateTime set tmpdate=%%j
	)

rem We need to extract only the date part and to drop the rest (the time refference)
set mydate=%tmpdate:~0,8%

rem We're composing the path to old file and the name of new one
set YeOldeFile1=%BkpLoc%\%BkpFile1%
set DatumFile1=%NoviFajl1%%mydate%%NovaExt1%
set YeOldeFile2=%BkpLoc%\%BkpFile2%
set DatumFile2=%NoviFajl2%%mydate%%NovaExt2%

rem We will rename here old file into the new name
ren %YeOldeFile1% %DatumFile1%
ren %YeOldeFile2% %DatumFile2%

rem copy c:\backup ir Riv_gama to NAS
robocopy c:\Backup\ \\192.168.11.11\Backup\srv\ /E /MIR /XA:H /R:10 /W:10
robocopy c:\Riv_gama\ \\192.168.11.11\Backup\srv\ /E /MIR /XA:H /R:10 /W:10

rem As the final step, we wil delete all files older then BROJFAJLOVA
forfiles /P %BkpLoc% /M *.%NovaExt% /D -%BrojFajlova% /C "cmd /c del @file"
forfiles /P %BkpLoc2% /M *.%NovaExt% /D -%BrojFajlova% /C "cmd /c del @file"

rem echo off
