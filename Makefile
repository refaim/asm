.PHONY: all clean

DOSBOX_BIN = "G:\\games\\DOSBox-0.63\\dosbox.exe"
TASM_PATH = C:\\TASM\\BIN

SRC_PATH = $(shell cd)
SRC_DRIVE = $(firstword $(subst :, ,$(SRC_PATH)))
TASM_DRIVE = $(firstword $(subst :, ,$(TASM_PATH)))

OUT = output

DOSBOX = $(DOSBOX_BIN) nul $(MOUNTS) -c$(1) $(PARAMS) $(SUFFIX)
MOUNTS = -c "mount $(TASM_DRIVE) $(TASM_DRIVE):\" -c "mount $(SRC_DRIVE) $(SRC_DRIVE):\" -c "$(SRC_DRIVE):" -c "cd $(SRC_PATH)"
PARAMS = -c exit -noconsole
SUFFIX = && type $(OUT) && del $(OUT) stdout.txt 2>nul

TFLAGS = /ml /t /w2
define tasm
	$(call DOSBOX, "$(TASM_PATH)\\tasm.exe $(TFLAGS) $^ > $(OUT)")
endef

LFLAGS = /C /d
define tlink
	$(call DOSBOX, "$(TASM_PATH)\\tlink.exe $(LFLAGS) $^ > $(OUT)")
endef

APPNAMES = lstatic ldynamic sapper
APPS = $(foreach APP, $(APPNAMES), $(APP).exe)
APP_OBJS = $(foreach APP, $(APPNAMES), $(APP).obj)
APP_MISC = $(foreach APP, $(APPNAMES), $(APP).lst $(APP).map)

LIBNAMES = glib
LIB_OBJS = $(foreach LIB, $(LIBNAMES), $(LIB).obj)
LIB_MISC = $(foreach LIB, $(LIBNAMES), $(LIB).lst $(LIB).map)

OBJS = $(APPS) $(APP_OBJS) $(APP_MISC) $(LIB_OBJSC) $(LIB_MISC)

all: $(APPS)

clean:
	del /q $(OBJS) 2>nul

%.exe: %.obj $(LIB_OBJS)
	echo Linking $@
	$(tlink)

%.obj: %.asm
	echo Assembling $@
	$(tasm)
