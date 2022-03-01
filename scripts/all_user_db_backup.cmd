@echo off
cd %~dp0
cls

REM "CHANGE TARGET LOCATION IF DESIRABLE"
SET target=%UserProfile%\Documents

if not exist "%target%\JSQLBackups\" (
  mkdir "%target%\JSQLBackups\"
  if "!errorlevel!" NEQ "0" (
    echo Error while creating %target%\JSQLBackups folder
    pause
    exit 1
  )
)
REM "SETTINGS NEW FOLDER"
SET target=%target%\JSQLBackups

rem "CRIATING DATE FOLDER AND TIME FOR BACKUP FILE"
FOR /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined MyDate set MyDate=%%x
SET DATE=%MyDate:~0,4%%MyDate:~4,2%%MyDate:~6,2%
SET TIME=%MyDate:~8,2%%MyDate:~10,2%%MyDate:~12,2%

if not exist "%target%\%DATE%\" (
  mkdir "%target%\%DATE%\"
  if "!errorlevel!" NEQ "0" (
    echo Error while creating %target%\%DATE% folder
    pause
    exit 1
  )
)
REM "SETTINGS NEW TARGET DATE BASED FOLDER"
SET target=%target%\%DATE%
SET PGPASSWORD=<PassWord>
