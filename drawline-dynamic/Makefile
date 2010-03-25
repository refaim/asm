.PHONY: all clean

TASM = tasm.exe
TLINK = tlink.exe

TFLAGS = /ml /t /w2
LFLAGS = /C /d

all: line.exe

line.exe: line.obj
	$(TLINK) $(LFLAGS) line.obj

line.obj: line.asm
	$(TASM) $(TFLAGS) line.asm

clean:
	del /q line.exe line.map line.obj 2>nul
