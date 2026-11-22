@echo off
set "GODOT=F:\github\tools\Godot_v4.4.1-stable_win64.exe"
if not exist "%GODOT%" goto nogodot
start "" "%GODOT%" --path "%~dp0."
exit /b 0
:nogodot
echo [MiniLifeWorld] Godot engine not found: %GODOT%
pause
exit /b 1
