@echo off
ECHO PC	Information - Jonathon Ament - Copyright 2013
mode con:cols=79 lines=37

if %os%==Windows_NT goto WINNT
goto NOCON

:WINNT
CLS
# set variables
set system=
set manufacturer=
set model=
set serialnumber=
set biosversion=
set totalphysicalmemory=
set cpu=
set printers=
set osarchitecture=
set osname=
set sp=
set domain=
set username=
set cstring=
set ustring=
set pstring=

# Get Computer Name / IP Address
echo Please enter a PC Name or IP. !!YOU MUST HAVE ADMIN RIGHTS ON REMOTE PC!!
set computer=%computername%
set /p computer=[Enter a PC name or IP Address Here] 
echo ----------------

# Check If Remote Machine
IF NOT %computer% == %computername% goto remote
goto start

:#OTE
# It's A Remote Machine
set cstring=/node:"%computer%"

:USERNAME
# Get Username

# TO REENABLE username and password, REMOVE "goto start" BELOW THIS LINE.  Otherwise program assumes credentials of logged in individual.
goto start
echo ----------------
echo Type a Username and press Enter (!!MUST BE ADMIN ON REMOTE SYSTEM!!)
set user=%username%
set /p user=[Press Enter To Use Your Username - %username%]
echo ----------------

# Check If Other Username
IF NOT %user% == %username% goto newuser

:NEWUSER
# It's A Different User
set ustring=/user:"%user%"

:PASSWORD
# Get Password
echo ----------------
echo Type in a Password and press Enter (with or without DOMAIN)
set pass=
set /p pass=
echo ----------------

# Check if password was entered
IF [%pass%] == [] goto nopass
set pstring=/password:"%pass%"
goto start

:NOPASS
# No password entered
set pstring=

:START
CLS
echo Checking connection [Computer: %computer%]...
echo Please Wait....

# Check connection
wmic %cstring% %ustring% %pstring% OS Get csname

IF %errorlevel% == -2147023174 goto norpc
IF %errorlevel% == -2147024891 goto baduser

echo Getting data [Computer: %computer%]...
echo Please Wait....

# Get Computer Name
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% OS Get csname /value') do SET system=%%A

# Get Computer Manufacturer
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% ComputerSystem Get Manufacturer /value') do SET manufacturer=%%A

# Get Computer Model
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% ComputerSystem Get Model /value') do SET model=%%A

# Get Computer Serial Number
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% Bios Get SerialNumber /value') do SET serialnumber=%%A

# Get Computer BIOS Version
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% Bios Get SMBIOSBIOSVersion /value') do SET biosversion=%%A

# Get Computer Total Physical Memory
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% COMPUTERSYSTEM Get TotalPhysicalMemory /value') do SET totalphysicalmemory=%%A

# Get Computer CPU
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% CPU GET NAME /value') do SET cpu=%%A

# Get Computer OS
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% os get Name /value') do SET osname=%%A
FOR /F "tokens=1 delims='|'" %%A in ("%osname%") do SET osname=%%A

# Get Computer OS Architecture
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% OS GET OSArchitecture /value') do SET osarchitecture=%%A

# Get Computer OS SP
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% OS GET ServicePackMajorVersion /value') do SET sp=%%A

# Get Computer Username
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% COMPUTERSYSTEM Get Username /value') do SET username=%%A

# Get Computer Printers
FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% PRINTER GET Name /value') do SET printers=%%A

# Get Computer Memory in Gigabytes
FOR /F "usebackq tokens=1" %%A in (`powershell [Math]::round^(%totalphysicalmemory%/1024/1024/1024^)`) do SET memory=%%A

echo done!

CLS

# Display everything on screen
echo ------------------------------
echo COMPUTER:
echo System Name:      %system%
echo Manufacturer:     %manufacturer%
echo Model:            %model%
echo Serial Number:    %serialnumber%
echo BIOS Version:     %biosversion%
echo.
echo SPECS:
echo Total RAM:        %memory%GB
echo CPU:	          %cpu%
echo.
echo O/S:
echo Operating System: %osname%, %osarchitecture%
echo Service Pack:     %sp%
echo.
echo PRINTER(S):       %printers%
echo.
echo USER INFORMATION:
echo Domain\Username:  %username%
echo.
echo NETWORK PROPERTIES:
GETMAC /S %computer%
NSLOOKUP %computer%
echo ------------------------------
echo.

GOTO CONTINUEPROGRAM

# Generate file
SET file="%~dp0%computer%.txt"
echo ------------------------------ > %file%
echo COMPUTER: >>   %file%
echo System Name:   %system% >> %file%
echo Manufacturer:  %manufacturer% >> %file%
echo Model:         %model% >> %file%
echo Serial Number: %serialnumber% >> %file%
echo BIOS Version:  %biosversion% >> %file%
echo ------------------------------ >> %file%
echo ------------------------------ >> %file%
echo SPECS: >> %file%
echo Total RAM:     %totalphysicalmemory% >> %file%
echo CPU:	       %cpu% >> %file%
echo ------------------------------ >> %file%
echo ------------------------------ >> %file%
echo O/S: >> %file%
echo System:        %osname%, %osarchitecture% >> %file%
echo Service Pack:  %sp% >> %file%
echo Printers:      %printers% >> %file%
echo ------------------------------ >> %file%
echo ------------------------------ >> %file%
echo USER INFORMATION: >> %file%
echo Domain\User:   %username% >> %file%
echo ------------------------------ >> %file%
echo ------------------------------ >> %file%
echo NETWORK PROPERTIES: >> %file%
GETMAC /S %computer% >> %file%
NSLOOKUP %computer% >> %file%
echo ------------------------------ >> %file%



echo File created at %file%

:CONTINUEPROGRAM

# Request user to push any key to continue
pause

goto WINNT

:NORPC
echo ----------------
echo Error...No connection could be made to [%computer%]...
echo Error...Please try again...
echo ----------------
pause
cls
goto winnt

:BADUSER
echo ----------------
echo Error...Access Denied using [%user%]...
echo Error...Please try again...
echo ----------------
pause
cls
goto username

:NOCON
echo ----------------
echo Error...Invalid Operating System...
echo Error...No actions were made...
echo ----------------
pause
goto END

:END
