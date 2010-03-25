@echo off
G:\games\DOSBox-0.63\dosbox.exe %CD%\line.exe -noconsole -exit
del /q stdout.txt 2>nul
