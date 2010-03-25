@echo off
set OLDPATH=%PATH%
set PATH=C:/TASM/BIN;%PATH%
mingw32-make %*
set PATH=%OLDPATH%
