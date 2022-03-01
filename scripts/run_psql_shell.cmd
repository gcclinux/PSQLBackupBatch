@echo off
REM "Tested on Windows 10 only"
REM "PostgreSQL PSQL login script for Windows"

@color 0a

SET server=localhost
SET /P server="Server [%server%]: "

SET database=postgres
SET /P database="Database [%database%]: "

SET port=5432
SET /P port="Port [%port%]: "

SET username=postgres
SET /P username="Username [%username%]: "

"..\DBMS\PostgreSql\psql.exe" -E -h %server% -U %username% -d %database% -p %port%

pause
