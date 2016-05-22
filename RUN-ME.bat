@echo off
mode con:cols=120 lines=60

powershell Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Confirm:$false
powershell .\PC-Information.ps1
powershell Set-ExecutionPolicy Default -Scope CurrentUser -Confirm:$false