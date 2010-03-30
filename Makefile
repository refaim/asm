.PHONY: all clean

DOSBOX_BIN = "G:\\home\\utils\\dosbox\\dosbox.exe"
TASM_PATH = C:\\TASM\\BIN

SRC_PATH = $(shell cd)
SRC_DRIVE = $(firstword $(subst :, ,$(SRC_PATH)))
TASM_DRIVE = $(firstword $(subst :, ,$(TASM_PATH)))
OUTPUT_FILE = output

DOSBOX = $(DOSBOX_BIN) nul -noconsole $(MOUNTS) -c$(1) -c exit $(SUFFIX)
MOUNTS =\
-c "mount $(TASM_DRIVE) $(TASM_DRIVE):\"\
-c "mount $(SRC_DRIVE) $(SRC_DRIVE):\"\
-c "$(SRC_DRIVE):"\
-c "cd $(SRC_PATH)"
SUFFIX = && type $(OUTPUT_FILE) && del $(OUTPUT_FILE) stdout.txt stderr.txt 2>nul

TFLAGS = /ml /t /w2
define tasm
	$(call DOSBOX, "$(TASM_PATH)\\tasm.exe $(TFLAGS) $$^ > $(OUTPUT_FILE)")
endef

LFLAGS = /C /d
define tlink
	$(call DOSBOX, "$(TASM_PATH)\\tlink.exe $(LFLAGS) $$^ > $(OUTPUT_FILE)")
endef

COMMON_LIBNAMES = libvideo libmisc
COMMON_LIB_OBJS = $(foreach LIB, $(COMMON_LIBNAMES), $(LIB).obj)
LIBNAMES = $(COMMON_LIBNAMES) librand
LIB_OBJS = $(foreach LIB, $(LIBNAMES), $(LIB).obj)

APPNAMES = lstatic ldynamic sapper
sapper_LIBS = librand.obj

APPS = $(foreach APP, $(APPNAMES), $(APP).exe)
APP_OBJS = $(foreach APP, $(APPNAMES), $(APP).obj $(APP).map)

OBJS = $(APPS) $(APP_OBJS) $(LIB_OBJS)

define exe_template
$(1).exe: $(1).obj $(COMMON_LIB_OBJS) $$(value $(1)_LIBS)
	@echo Linking $$@
	@$(tlink)
endef

define obj_template                                   
$(1).obj: $(1).asm
	@echo Assembling $$@
	@$(tasm)
endef

all: $(APPS)

clean:
	@echo Cleaning
	@del /q $(OBJS) $(wildcard make*-?.bat) 2>nul

$(foreach APP, $(APPNAMES), $(eval $(call exe_template, $(APP))))
$(foreach APP, $(APPNAMES) $(LIBNAMES), $(eval $(call obj_template, $(APP))))
