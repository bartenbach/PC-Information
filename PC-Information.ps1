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

Write-Host "PC Information - Jonathon Ament, Blake Bartenbach - Copyright 2016" -foregroundcolor "white"

function Handle-NoRPC {
  Write-Host "---------------------------------------------------" -foregroundcolor "yellow"
  Write-Host "Error...No connection could be made to [$computer]..." -foregroundcolor "red"
  Write-Host "Error...Please try again..." -foregroundcolor "red"
  Write-Host "---------------------------------------------------" -foregroundcolor "yellow"
  $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  clear
  Main
}

function Handle-BadUser {
  Write-Host "---------------------------------------------------" -foregroundcolor "yellow"
  Write-Host "Error...Access Denied using [%user%]..." -foregroundcolor "red"
  Write-Host "Error...Please try again..." -foregroundcolor "red"
  Write-Host "---------------------------------------------------" -foregroundcolor "yellow"
  $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  clear
  Get-Username
}

function Handle-Nocon {
  Write-Host "---------------------------------------------------" -foregroundcolor "yellow"
  Write-Host "Error...Invalid Operating System..." -foregroundcolor "red"
  Write-Host "Error...No actions were made..." -foregroundcolor "red"
  Write-Host "---------------------------------------------------" -foregroundcolor "yellow"
  $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  clear
  Main
}

function init {
  $OS = Get-WmiObject -Computer $env:computername -Class Win32_OperatingSystem
  if ($OS.caption -like "*Windows*") {
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
  } else {
    Handle-Nocon
  }
}

function Main {
  init
  $computer = Get-PCName
  Write-Host "Checking connection [Computer: $computer ]..." -foregroundcolor "green"

 # Check connection
 # wmic $cstring $ustring $pstring OS Get csname

 # if (%errorlevel% == -2147023174) { 
 #	 Handle-NoRPC
 # } elseif (%errorlevel% == -2147024891) {
 #   Handle-BadUser
 # }

  Write-Host "Getting data [Computer: $computer]..." -foregroundcolor "green"

  $system = get-wmiobject win32_operatingsystem | select-object -expand csname
  $manufacturer = get-wmiobject win32_computersystem | select-object -expand manufacturer
  $model = get-wmiobject win32_computersystem | select-object -expand model
  $serialnumber = get-wmiobject win32_bios | select-object -expand serialnumber
  $biosversion = get-wmiobject win32_bios | select-object -expand smbiosbiosversion
  $totalphysicalmemory = get-wmiobject win32_computersystem | select-object -expand totalphysicalmemory
  $cpu = get-wmiobject win32_processor | select-object -expand name
  $osname = (get-wmiobject -class win32_operatingsystem | select-object -expand name).split("|")[0]
  $osarchitecture = get-wmiobject -class win32_operatingsystem | select-object -expand osarchitecture
  $sp = get-wmiobject -class win32_operatingsystem | select-object -expand servicepackmajorversion
  $username = get-wmiobject -class win32_computersystem | select-object -expand username
  $printers = get-wmiobject -class win32_printer | select-object -expand name

  # formatting
  $memory = [Math]::round($totalphysicalmemory/1024/1024/1024)

  Write-Host "done!" -foregroundcolor "green"
  display
  $nothing = read-host
}

function Get-PCName {
  Write-Host "Please enter a PC Name or IP. !!YOU MUST HAVE ADMIN RIGHTS ON REMOTE PC!!" -foregroundcolor "green"
  $computer = Read-Host -prompt "[Enter a PC name or IP Address Here]"
  Write-Host "---------------------------------------------------" -foregroundcolor "green"
  
  if ([string]::IsNullOrEmpty($computer)) {
	return $env:computername
  } else {
	return "/node:" + $computer
  }
}

# This is sketchy
function Get-Temperature {
  $t = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi"
  $currentTempKelvin = $t.CurrentTemperature / 10
  $currentTempCelsius = $currentTempKelvin - 273.15
  $currentTempFahrenheit = (9/5) * $currentTempCelsius + 32
  return "Temperature:          " + $currentTempCelsius.ToString() + " Celsius"
}

function Get-Uptime {
   $os = Get-WmiObject win32_operatingsystem
   $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
   $Display = "Uptime:               " `
       + $Uptime.Days + " days, " + $Uptime.Hours + " hours, " + $Uptime.Minutes + " minutes" 
   Write-Output $Display
}

function display {
  Write-Host "---------------------------------------------------"
  Write-Host "COMPUTER:"
  Write-Host "System Name:          $system"
  Write-Host "Manufacturer:         $manufacturer"
  Write-Host "Model:                $model"
  Write-Host "Serial Number:        $serialnumber"
  Write-Host "BIOS Version:         $biosversion"
  Write-Host ""
  Write-Host "SPECS:"
  Write-Host "Total RAM:            $memory GB"
  Write-Host "CPU:	              $cpu"
  Write-Host ""
  Write-Host "O/S:"
  Write-Host "Operating System:     $osname $osarchitecture"
  Write-Host "Service Pack:         $sp"
  Write-Host ""
  Write-Host "PRINTER(S):           $printers"
  Write-Host ""
  Write-Host "USER INFORMATION:"
  Write-Host "Domain\Username:      $username"
  Write-Host ""
  Get-Uptime
  Write-Host ""
  Write-Host "NETWORK PROPERTIES:"
  GETMAC /S $computer
  NSLOOKUP $computer
  Write-Host "---------------------------------------------------"
  Write-Host ""
}

function generateFile {
  $file="%~dp0%computer%.txt"
  echo ------------------------------ > $file
  echo COMPUTER: >>   $file
  echo System Name:   $system >> $file
  echo Manufacturer:  $manufacturer >> $file
  echo Model:         $model >> $file
  echo Serial Number: $serialnumber >> $file
  echo BIOS Version:  $biosversion >> $file
  echo ------------------------------ >> $file
  echo ------------------------------ >> $file
  echo SPECS: >> $file
  echo Total RAM:     $totalphysicalmemory >> $file
  echo CPU:	       $cpu >> $file
  echo ------------------------------ >> $file
  echo ------------------------------ >> $file
  echo O/S: >> $file
  echo System:        $osname, $osarchitecture >> $file
  echo Service Pack:  $sp >> $file
  echo Printers:      $printers >> $file
  echo ------------------------------ >> $file
  echo ------------------------------ >> $file
  echo USER INFORMATION: >> $file
  echo Domain\User:   $username >> $file
  echo ------------------------------ >> $file
  echo ------------------------------ >> $file
  echo NETWORK PROPERTIES: >> $file
  GETMAC /S $computer >> $file
  NSLOOKUP $computer >> $file
  echo ------------------------------ >> $file

  Write-Host "File created at %file%"
  $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Main