.PHONY: all clean

APPNAME = line
OBJS = line.obj graphic.obj

TASM = tasm.exe
TLINK = tlink.bat

TFLAGS = /ml /t /w2 /i..
LFLAGS = /C /d

all: clean $(APPNAME).exe

$(APPNAME).exe: $(OBJS)
	$(TLINK) $(LFLAGS) $(OBJS)

$(APPNAME).obj: $(APPNAME).asm
	$(TASM) $(TFLAGS) $(APPNAME).asm

graphic.obj: ..\\graphic.asm
	$(TASM) $(TFLAGS) ..\\graphic.asm

clean:
	del /q $(APPNAME).exe $(APPNAME).map $(OBJS) 2>nul
