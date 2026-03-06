@echo off
powershell.exe -Command "Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File ""%~dp0setupScripts/setupWin.ps1""' -Verb RunAs"
