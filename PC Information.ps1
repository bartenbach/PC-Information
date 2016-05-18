# PC Information
#
# Copyright (C) <2016>  <Johnathon Ament, Blake Bartenbach>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

Write-Host "PC Information - Jonathon Ament, Blake Bartenbach - Copyright 2016" -foregroundcolor "green"

if (%os%==Windows_NT) {
	echo "It works!"
	Handle-WinNT
} else {
	Handle-Nocon
}
	
function Handle-WinNT {
  $system=
  $manufacturer=
  $model=
  $serialnumber=
  $biosversion=
  $totalphysicalmemory=
  $cpu=
  $printers=
  $osarchitecture=
  $osname=
  $sp=
  $domain=
  $username=
  $cstring=
  $ustring=
  $pstring
}

function Get-PCName {
  echo Please enter a PC Name or IP. !!YOU MUST HAVE ADMIN RIGHTS ON REMOTE PC!!
  $computer=%computername%
  set /p computer=[Enter a PC name or IP Address Here] 
  echo ----------------
}

if (%computer% != %computername%) { 
  Handle-Remote
} else {
  Main
}

function Handle-Remote {
  $cstring=/node:"%computer%"
}

function Get-Username {
  # Get Username
  # TO REENABLE username and password, REMOVE "goto start" BELOW THIS LINE.  Otherwise program assumes credentials of logged in individual.
  goto start
  #echo ----------------
  #echo Type a Username and press Enter (!!MUST BE ADMIN ON REMOTE SYSTEM!!)
  #set user=%username%
  #set /p user=[Press Enter To Use Your Username - %username%]
  #echo ----------------

  # Check If Other Username
  if (%user% != %username%) {
    $ustring=/user:"%user%"
  }
}

function Get-Password {
  echo ----------------
  echo Type in a Password and press Enter (with or without DOMAIN)
  $pass=
  set /p pass=
  echo ----------------
}

# Check if password was entered
if ([%pass%]::IsNullOrEmpty) { 
	$pstring=''
} else {
	$pstring=/password:"%pass%"
	Main
}

function Main {
  cls
  echo Checking connection [Computer: %computer%]...
  echo Please Wait....

  # Check connection
  wmic %cstring% %ustring% %pstring% OS Get csname

  if (%errorlevel% == -2147023174) { 
	Handle-NoRPC
  } elseif (%errorlevel% == -2147024891) {
	Handle-BadUser
  }

  echo Getting data [Computer: %computer%]...
  echo Please Wait....

  # Get Computer Name
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% OS Get csname /value') do SET system=%%A
  $system = wmic $cstring $ustring $pstring os get csname /value

  # Get Computer Manufacturer
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% ComputerSystem Get Manufacturer /value') do SET manufacturer=%%A
  $manufacturer = wmic $cstring $ustring $pstring computersystem get manufacturer /value

  # Get Computer Model
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% ComputerSystem Get Model /value') do SET model=%%A
  $model = wmic $cstring $ustring $pstring computersystem get model /value

  # Get Computer Serial Number
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% Bios Get SerialNumber /value') do SET serialnumber=%%A
  $serialnumber = wmic $cstring $ustring $pstring bios get serialnumber /value

  # Get Computer BIOS Version
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% Bios Get SMBIOSBIOSVersion /value') do SET biosversion=%%A
  $biosversion = wmic $cstring $ustring $pstring bios get smbiosbiosversion /value

  # Get Computer Total Physical Memory
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% COMPUTERSYSTEM Get TotalPhysicalMemory /value') do SET totalphysicalmemory=%%A
  $totalphysicalmemory = wmic $cstring $ustring $pstring computersystem get totalphysicalmemory /value

  # Get Computer CPU
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% CPU GET NAME /value') do SET cpu=%%A
  $cpu = wmic $cstring $ustring $pstring cpu get name /value

  # Get Computer OS
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% os get Name /value') do SET osname=%%A
  #FOR /F "tokens=1 delims='|'" %%A in ("%osname%") do SET osname=%%A
  $osname = wmic $cstring $ustring $pstring os get name /value

  # Get Computer OS Architecture
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% OS GET OSArchitecture /value') do SET osarchitecture=%%A
  $osarchitecture = wmic $cstring $ustring $pstring os get osarchitecture /value

  # Get Computer OS SP
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% OS GET ServicePackMajorVersion /value') do SET sp=%%A
  $sp = wmic $cstring $ustring $pstring os get servicepackmajoreversion /value

  # Get Computer Username
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% COMPUTERSYSTEM Get Username /value') do SET username=%%A
  $username = wmic $cstring $ustring $pstring computersystem get username /value

  # Get Computer Printers
  #FOR /F "tokens=2 delims='='" %%A in ('wmic %cstring% %ustring% %pstring% PRINTER GET Name /value') do SET printers=%%A
  $printers = wmic $cstring $ustring $pstring printer get name /value

  # Get Computer Memory in Gigabytes
  #FOR /F "usebackq tokens=1" %%A in (`powershell [Math]::round^(%totalphysicalmemory%/1024/1024/1024^)`) do SET memory=%%A
  $memory = [Math]::round($totalphysicalmemory/1024/1024/1024)
  #TODO ^ combine

  echo done!
  clear
}

# Display everything on screen
function display {
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
}

function generateFile {
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
  $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Handle-NoRPC {
  echo ----------------
  echo Error...No connection could be made to [%computer%]...
  echo Error...Please try again...
  echo ----------------
  $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  cls
  goto winnt
}

function Handle-BadUser {
  echo ----------------
  echo Error...Access Denied using [%user%]...
  echo Error...Please try again...
  echo ----------------
  $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  cls
  goto username
}

function Handle-Nocon {
  echo ----------------
  echo Error...Invalid Operating System...
  echo Error...No actions were made...
  echo ----------------
  $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
