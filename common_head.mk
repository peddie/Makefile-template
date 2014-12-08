ifdef VERBOSE
Q =
endif
Q ?= @

all: $(PROJ)
.PHONY: all

# Detect the native OS
UNAME_OS=$(shell uname -s)

# What's the extension on C++ files?  .cc is the Google default, but
# lots of people use .cpp instead.
CXX_EXT ?= cc

C_SRC = $(filter %.c,$(SRC))
CXX_SRC = $(filter %.$(CXX_EXT),$(SRC))

CUSTOM_C_SRC = $(filter %.c,$(CUSTOM_SRC))
CUSTOM_CXX_SRC = $(filter %.$(CXX_EXT),$(CUSTOM_SRC))

C_HDR = $(filter %.h,$(SRC))
CXX_HDR = $(filter %.hh,$(SRC))

_TARGET_STEM ?= $(shell $(CC) -dumpmachine | perl -pe "s/(\w+)-.*/\1/")
_TARGET_NAMES ?= 1

ifneq (0, $(_TARGET_NAMES))
OBJECT_FILE_SUFFIX ?= o.$(_TARGET_STEM)
ASMNAME ?= lst.$(_TARGET_STEM)
else
OBJECT_FILE_SUFFIX ?= o
ASMNAME ?= lst
endif

C_ASM ?= $(C_SRC:%.c=%.$(ASMNAME))
C_OBJ ?= $(C_SRC:%.c=%.$(OBJECT_FILE_SUFFIX))
CUSTOM_C_OBJ ?= $(CUSTOM_C_SRC:%.c=%.$(OBJECT_FILE_SUFFIX))
C_DEPS ?= $(C_SRC:%.c=%.d)

CXX_ASM ?= $(CXX_SRC:%.$(CXX_EXT)=%.$(ASMNAME))
CXX_OBJ ?= $(CXX_SRC:%.$(CXX_EXT)=%.$(OBJECT_FILE_SUFFIX))
CUSTOM_CXX_OBJ ?= $(CUSTOM_CXX_SRC:%.c=%.$(OBJECT_FILE_SUFFIX))
CXX_DEPS ?= $(CXX_SRC:%.$(CXX_EXT)=%.d)

ASM ?= $(C_ASM) $(CXX_ASM)
OBJ ?= $(C_OBJ) $(CXX_OBJ)
DEPS ?= $(C_DEPS) $(CXX_DEPS)

ifeq ("$(UNAME_OS)","Darwin")
CLANGIN = 22
endif
ifneq (,$(findstring clang,$(CC)))
CLANGIN = 222
endif

# Here we remove all paths from the given object and source file
# names; you can echo these in commands and get slightly tidier output.
SRC_SHORT = $(notdir $(SRC))
ASM_SHORT = $(notdir $(ASM))
OBJ_SHORT = $(notdir $(OBJ))

# So make recognizes dependency files
SUFFIXES += .d

# Generate sweet mixed assembly/C listing files
ASMFLAGS ?= -fverbose-asm -Wa,-L,-alchsdn=
