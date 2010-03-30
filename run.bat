@echo off
g:\home\utils\dosbox\dosbox.exe %CD%\%1.exe -noconsole -exit
del /q stdout.txt stderr.txt 2>nul
