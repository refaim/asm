@echo off
G:\games\DOSBox-0.63\dosbox.exe %CD%\%1.exe -noconsole -exit
del /q stdout.txt 2>nul
