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

C_HDR = $(filter %.h,$(SRC))
CXX_HDR = $(filter %.hh,$(SRC))

ASMNAME ?= lst

# Default setting for object files is just .c -> .o
C_ASM ?= $(C_SRC:%.c=%.$(ASMNAME))
C_OBJ ?= $(C_SRC:%.c=%.o)
C_DEPS ?= $(C_SRC:%.c=%.d)

CXX_ASM ?= $(CXX_SRC:%.$(CXX_EXT)=%.$(ASMNAME))
CXX_OBJ ?= $(CXX_SRC:%.$(CXX_EXT)=%.o)
CXX_DEPS ?= $(CXX_SRC:%.$(CXX_EXT)=%.d)

ASM ?= $(C_ASM) $(CXX_ASM)
OBJ ?= $(C_OBJ) $(CXX_OBJ)
DEPS ?= $(C_DEPS) $(CXX_DEPS)

# Here we remove all paths from the given object and source file
# names; you can echo these in commands and get slightly tidier output.
SRC_SHORT = $(notdir $(SRC))
ASM_SHORT = $(notdir $(ASM))
OBJ_SHORT = $(notdir $(OBJ))

# Generate sweet mixed assembly/C listing files
ASMFLAGS ?= -fverbose-asm -Wa,-L,-alchsdn=

