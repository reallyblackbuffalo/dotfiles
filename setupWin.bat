@echo off
powershell.exe -Command "Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -WorkingDir ""%~dp0"" -File ""%~dp0/setupScripts/setupWin.ps1""' -Verb RunAs"
