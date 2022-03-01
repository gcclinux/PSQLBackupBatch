@echo off

REM "Created by Ricardo @ Wagemaker"
REM "Date: 18-02-2022"
REM "Version: 01"
REM "Tested on Windows 10 only"

title "PostgreSQL Backup Script"
CMD /C EXIT 0
@color 0a

if not exist "%APPDATA%\postgresql\" (
  mkdir "%APPDATA%\postgresql\"
  IF %ERRORLEVEL% NEQ 0 (
    echo Error while creating %APPDATA%\postgresql folder
    pause
    exit 1
  )
)

SET pgpass=%APPDATA%\postgresql\pgpass.conf

if "%1" == "-interactive" (goto manual)
if "%1" == "/i" (goto manual)
if "%1" == "/r" (goto prep)
if "%1" == "/h" (goto help)
if [%1] == [] (goto help)
echo Invalid method: %1
exit

:prep
SET server=%2
SET username=%3
SET database=%4
SET port=%5
SET password=%6
SET target=%7
SET format=%8
(goto auto)

:help
echo ...
echo #### Commands Example ####
echo ...
echo "PS> run_backup.cmd /r [ server_name ] [ db_user ] [ db_name ] [ port ] [db_password] [ %UserProfile%\Documents | PATH ] [ dump | sql | tar ]"
echo "PS> run_backup.cmd /h (help menu)"
echo "PS> run_backup.cmd /i (interactive)"
echo "PS> run_backup.cmd -interactive"
echo ...
pause
exit

:manual
echo ----------------------------
SET server=localhost
SET /P server="Server [%server%]: "

SET database=postgres
SET /P database="Database [%database%]: "

SET port=5432
SET /P port="Port [%port%]: "

SET username=postgres
SET /P username="Username [%username%]: "

SET password=password
SET /P password="Password [%password%]: "

SET target=%UserProfile%\Documents
SET /P target="Target [%target%]: "

SET format=dump
SET /P format="File format [dump|sql|tar]: "

:auto
if not exist "%target%\JSQLBackups\" (
  mkdir "%target%\JSQLBackups\"
  IF %ERRORLEVEL% NEQ 0 (
    echo Error while creating %target%\JSQLBackups
    pause
    exit 1
  )
)

SET target=%target%\JSQLBackups

echo %server%:%port%:%database%:%username%:%password%> %pgpass%

FOR /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined MyDate set MyDate=%%x
SET DATE=%MyDate:~0,4%%MyDate:~4,2%%MyDate:~6,2%
SET TIME=%MyDate:~8,2%%MyDate:~10,2%%MyDate:~12,2%

if not exist "%target%\%DATE%\" (
  mkdir "%target%\%DATE%"
  IF %ERRORLEVEL% NEQ 0 (
    echo Error while creating %target%\%DATE% FOLDER
    pause
    exit 1
  )
)

SET target=%target%\%DATE%

echo ""
echo "Listing all tables in %database%"
echo ""
"..\DBMS\PostgreSql\psql.exe" -h %server% -U %username% -d %database% -p %port% -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE'"

if "%format%"=="sql" (goto start1)
if "%format%"=="dump" (goto start2)
if "%format%"=="tar" (goto start3)

echo Invalid method: %format%
(goto :eof)

:start1
echo "Backing up in SQL format"
"..\DBMS\PostgreSql\pg_dump.exe" -h %server% -U %username% -d %database% -p %port% -f %target%\%TIME%_%server%-%database%.sql
(goto start4)

:start2
echo "Backing up in DUMP format"
"..\DBMS\PostgreSql\pg_dump.exe" -h %server% -U %username% -d %database% -p %port% -Fc -f %target%\%TIME%_%server%-%database%.dump
(goto start4)

:start3
echo "Backing up in TAR format"
"..\DBMS\PostgreSql\pg_dump.exe" -h %server% -U %username% -d %database% -p %port% -Ft -f %target%\%TIME%_%server%-%database%.tar
(goto start4)

:start4
echo "Backup completed Successfully"
echo "Deleting password file"
del /Q %pgpass%
pause
exit 0

:eof
pause
