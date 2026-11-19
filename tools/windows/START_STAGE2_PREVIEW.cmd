@echo off
setlocal
cd /d "%~dp0"
set "APPDATA=%~dp0userdata"
if not exist "%APPDATA%" mkdir "%APPDATA%"
start "" "%~dp0runtime\Godot.exe" --main-pack "%~dp0MANJUSHAGE.pck" res://prototypes/stage2_playable.tscn
