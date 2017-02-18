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
$version = '0.0.1'

function Handle-NoConnection ([String]$Computer){
  $Host.UI.WriteErrorLine("Error: No connection could be made to [$Computer] -- Is the machine on?")
  $Pause = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  Exit
}

function Handle-InvalidOperatingSystem {
  $Host.UI.WriteErrorLine("Error: Invalid Operating System -- Is that a Windows machine?")
  $Pause = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  Exit
}

function Initialize {
  Write-Host "PC Information $version - Jonathon Ament, Blake Bartenbach - Copyright 2016" -foregroundcolor "DarkGray"
  Check-PowerShell-Version
  $OS = Get-WmiObject -Computer $env:computername -Class Win32_OperatingSystem
  if ($OS.caption -notlike "*Windows*") {
    Handle-InvalidOperatingSystem
  }
}

function Check-PowerShell-Version {
  if ($PSVersionTable.PSVersion.Major -lt 2) {
    Write-Warning "(You should probably update your PowerShell to the latest version or things might not work)"
  }
}

function Main {
  Clear
  Initialize
  $Computer = Get-ComputerName
  Check-Connection $Computer
  
  Write-Host "Getting data..." -ForegroundColor "green"
  
  $system =              Get-WmiObject -Class Win32_OperatingSystem             -ComputerName $Computer | Select-Object -Expand CsName
  $manufacturer =        Get-WmiObject -Class Win32_ComputerSystem              -ComputerName $Computer | Select-Object -Expand Manufacturer
  $model =               Get-WmiObject -Class Win32_ComputerSystem              -ComputerName $Computer | Select-Object -Expand Model
  $serialnumber =        Get-WmiObject -Class Win32_Bios                        -ComputerName $Computer | Select-Object -Expand SerialNumber
  $biosversion =         Get-WmiObject -Class Win32_Bios                        -ComputerName $Computer | Select-Object -Expand SmBiosBiosVersion
  $totalphysicalmemory = Get-WmiObject -Class Win32_ComputerSystem              -ComputerName $Computer | Select-Object -Expand TotalPhysicalMemory
  $cpu =                 Get-WmiObject -Class Win32_Processor                   -ComputerName $Computer | Select-Object -Expand Name
  $operatingsystem =     Get-WmiObject -Class Win32_OperatingSystem             -ComputerName $Computer | Select-Object -Expand Name
  $osarchitecture =      Get-WmiObject -Class Win32_OperatingSystem             -ComputerName $Computer | Select-Object -Expand OsArchitecture
  $sp =                  Get-WmiObject -Class Win32_OperatingSystem             -ComputerName $Computer | Select-Object -Expand ServicePackMajorVersion
  $username =            Get-WmiObject -Class Win32_ComputerSystem              -ComputerName $Computer | Select-Object -Expand Username
  $printers =            Get-WmiObject -Class Win32_Printer                     -ComputerName $Computer | Select-Object -Expand Name
  #$macaddress =          Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $Computer | Select-Object -Expand MacAddress
  $ip =                  Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where {$_.Ipaddress.length -gt 1} 
  
  # formatting
  $memory    = [Math]::round($totalphysicalmemory/1024/1024/1024)
  [String]$memoryString = [String]$memory + " GB"
  $processor = $cpu.split("|")[0]
  $osname = $operatingsystem.split("|")[0]
  $osname += " "
  $osname += $osarchitecture
  if ($sp -gt 0) {
    $osname += " SP" + $sp
  }
  
  Display-Result
  Output-To-File
  
  Write-Host "Press any key to exit..." -ForegroundColor "Green"
  $Pause = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Check-Connection([String]$Computer) {
  Write-Host "----------------------------------------------------------" -foregroundcolor "Green"
  Write-Host "Checking connection..." -ForegroundColor "green"
  $Connection = Test-Connection -ComputerName $Computer -Quiet
  if (!$Connection) {
	  Handle-NoConnection $Computer
  }
}

function Get-ComputerName {
  Write-Host "Enter PC name or IP Address (leave blank for localhost): " -NoNewLine -ForegroundColor "Green"
  $computer = Read-Host
  
  if ([string]::IsNullOrEmpty($computer)) {
	  return $env:computername
  } else {
	  return $computer
  }
}

function Get-Uptime {
  $os = Get-WmiObject win32_operatingsystem
  $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
  $days = $Uptime.Days
  $hours = $Uptime.Hours
  $minutes = $Uptime.Minutes
  return "$days days, $hours hours, $minutes minutes" 
}

function Format-Result([System.ConsoleColor]$color1, [String]$s, [System.ConsoleColor]$color2, [String]$info) {
  Write-Host $s -NoNewLine -ForegroundColor $color1
  Write-Host $info -ForegroundColor $color2
}

function Display-Result {
  Write-Host "----------------------------------------------------------" -foregroundcolor "Green"
  Write-Host "Computer" -ForegroundColor "Magenta"
  Format-Result Cyan "  System Name          " Cyan $system
  Format-Result Cyan "  Manufacturer         " Cyan $manufacturer
  Format-Result Cyan "  Model                " Cyan $model
  # serial number may not be available
  if (![string]$serialnumber.equals("System Serial Number")) {
    Format-Result Cyan "  Serial Number        " Cyan $serialnumber
  }
  Format-Result Cyan "  BIOS Version         " Cyan $biosversion
  Write-Host ""
  Write-Host "Specifications" -ForegroundColor "Magenta"
  Format-Result Cyan "  CPU                  " Cyan $processor
  Format-Result Cyan "  Total RAM            " Cyan $memoryString
  Format-Result Cyan "  Operating System     " Cyan $osname
  Format-Result Cyan "  Uptime               " Cyan (Get-Uptime)
  Write-Host ""
  Write-Host "Printers" -ForegroundColor "Magenta"
  Write-Host "  $printers" -foregroundcolor "Cyan"
  Write-Host ""
  Write-Host "User" -ForegroundColor "Magenta"
  Format-Result Cyan "  Domain\Username      " Cyan $username
  Write-Host ""
  Write-Host "Network" -ForegroundColor "Magenta"
  Format-Result Cyan "  IP                   " Cyan $ip.ipaddress[0]
  #Format-Result Cyan "  Mac                  " Cyan $macaddress
  Write-Host "---------------------------------------------------------" -foregroundcolor "Green"
  Write-Host ""
}

function Output-To-File {
  $file = "$HOME\Documents\PC-Information.log"
  
  if (!(Test-Path $file)) {
    New-Item -Path $file -Type File -Force >> $null
    Write-Host "Log file created at $file `n" -ForegroundColor "Yellow"
  }
  "----------------------------------------------------------" >> $file
  "Computer"                                                   >> $file
  "  System Name          " + $system                          >> $file
  "  Manufacturer         " + $manufacturer                    >> $file
  "  Model                " + $model                           >> $file
  # serial number may not be available
  if (![string]$serialnumber.equals("System Serial Number")) {
    "  Serial Number        " + $serialnumber                    >> $file
  }
  "  BIOS Version         " + $biosversion                     >> $file
  ""                                                           >> $file
  "Specifications"                                             >> $file
  "  CPU                  " + $processor                       >> $file
  "  Total RAM            " + $memoryString                    >> $file
  "  Operating System     " + $osname                          >> $file
  "  Uptime               " + (Get-Uptime)                     >> $file
  ""                                                           >> $file
  "Printers"                                                   >> $file
  "  $printers"                                                >> $file
  ""                                                           >> $file
  "User"                                                       >> $file
  "  Domain\Username      " + $username                        >> $file
  ""                                                           >> $file
  "Network"                                                    >> $file
  "  IP                   " + $ip.ipaddress[0]                 >> $file
  #"  Mac                  " $macaddress                        >> $file
  "---------------------------------------------------------"  >> $file
  ""                                                           >> $file

}

Main
