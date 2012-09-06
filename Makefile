### Standard Makefile template
### Copyright (C) Matthew Peddie <peddie@alum.mit.edu>
###
### This file is hereby placed in the public domain, or, if your legal
### system doesn't recognize this concept, you may consider it
### licensed under the WTFPL version 2.0 or any BSD license you
### choose.
###
### Features:
###
###    - C++ autodetect (just add .cc files to $(SRC) and it will
###      do the right thing
###    - interspersed C(++)/assembly listings for all source files
###    - loads of warnings
###    - great default optimization, security and debug settings
###    - syntax checking target for emacs' flymake-mode
###
### This section should be all you need to configure a basic project;
### obviously for more complex projects, you'll need to edit the
### bottom section as well.  It supports only one project at a time.
### Type ``make help'' for usage help.

# What's the executable called?
PROJ = 

# What C or C++ files must we compile to make the executable?
SRC ?= 

# What additional headers are needed as dependencies?
HDR ?= 

# What directories must we include?
INCLUDENAMES ?= # e.g. ../mathlib; the makefile will add the -I
OTHERINCLUDE ?= 

# With what libraries should we link?
LIBNAMES ?= # e.g. m gsl atlas; the makefile will add the -l
LIBDIRS ?= # e.g. ../; the makefile will add the -L
OTHERLIB ?=

# You can add custom compiler and linker flags here.  USERFLAGS gets
# used by all compiler and linker calls, except when creating a static
# lib.  The others are specific to their stage.
USERFLAGS ?=
USERCFLAGS ?=
USERCXXFLAGS ?=
USERLDFLAGS ?=

###### Shouldn't have to configure this section ######

LIBNAME ?= lib$(PROJ)

C_SRC = $(filter %.c,$(SRC))
CXX_SRC = $(filter %.cc,$(SRC))

C_HDR = $(filter %.h,$(SRC))
CXX_HDR = $(filter %.hh,$(SRC))

ASMNAME ?= lst

# Default setting for object files is just .c -> .o
C_ASM ?= $(C_SRC:%.c=%.$(ASMNAME))
C_OBJ ?= $(C_SRC:%.c=%.o)
C_DEPS ?= $(C_SRC:%.c=%.d)

CXX_ASM ?= $(CXX_SRC:%.cc=%.$(ASMNAME))
CXX_OBJ ?= $(CXX_SRC:%.cc=%.o)
CXX_DEPS ?= $(CXX_SRC:%.cc=%.d)

ASM ?= $(C_ASM) $(CXX_ASM)
OBJ ?= $(C_OBJ) $(CXX_OBJ)
DEPS ?= $(C_DEPS) $(CXX_DEPS)

# Here we remove all paths from the given object and source file
# names; you can echo these in commands and get slightly tidier output.
SRC_SHORT = $(notdir $(SRC))
ASM_SHORT = $(notdir $(ASM))
OBJ_SHORT = $(notdir $(OBJ))

INCLUDES = $(INCLUDENAMES:%=-I%) $(OTHERINCLUDE)
LIBS = $(LIBNAMES:%=-l%) $(LIBDIRS:%=-L%) $(OTHERLIB)

# GCC by default (easy to override from outside the makefile)
CC ?= gcc 
CPP ?= g++
AR ?= ar

# Quiet commands unless overridden
Q ?= @

# Generate sweet mixed assembly/C listing files
ASMFLAGS ?= -fverbose-asm -Wa,-L,-alhsn=

# Second-level optimizations that don't increase binary size (O2 or
# above required for -D_FORTIFY_SOURCE=2 below); optimize for this
# machine architecture, including sse4.1; try using the vectorizer to
# speed up array code (gcc 4.5+, I think?); build object files for use
# by the link-time optimizer (gcc 4.5+, I think, but only really works
# in 4.6+)
#
# Feel free to change -Os to something else, but it's my understanding
# that on modern processors, instruction cache size and memory latency
# are as important in determining performance as heavy optimizations
# in -O3, so you might as well go for -Os.
# 
# I'm told that -march=native sometimes misses stuff, so if you really
# need speed, you might either look at the assembly or add
# -msse{4.1,4.2}, -mavx or whatever is appropriate for your chip.
OPTFLAGS ?= -Os -march=native -ftree-vectorize -flto

# Mega-warnings by default.  For many explanations, see
# http://stackoverflow.com/questions/3375697/useful-gcc-flags-for-c

# We prefer C99 with GNU extensions
WARNFLAGS ?= -Wall -Wextra -std=gnu99 \
             -Wshadow -Wswitch-default -Wswitch-enum -Wundef \
             -Wuninitialized -Wpointer-arith -Wstrict-prototypes \
             -Wmissing-prototypes -Wcast-align -Wformat=2 \
             -Wimplicit-function-declaration -Wredundant-decls \
             -Wformat-security -Werror -pedantic-errors

# And for C++:
# http://stackoverflow.com/questions/399850/best-compiler-warning-level-for-c-c-compilers
CXXWARNFLAGS ?= -Wall -Weffc++ -std=gnu++11 -pedantic  \
    -pedantic-errors -Wextra  -Waggregate-return -Wcast-align \
    -Wcast-qual  -Wchar-subscripts  -Wcomment -Wconversion \
    -Wdisabled-optimization \
    -Werror -Wfloat-equal  -Wformat  -Wformat=2 \
    -Wformat-nonliteral -Wformat-security  \
    -Wformat-y2k \
    -Wimplicit  -Wimport  -Winit-self  -Winline \
    -Winvalid-pch   \
    -Wunsafe-loop-optimizations  -Wlong-long -Wmissing-braces \
    -Wmissing-field-initializers -Wmissing-format-attribute   \
    -Wmissing-include-dirs -Wmissing-noreturn \
    -Wpacked  -Wpadded -Wparentheses  -Wpointer-arith \
    -Wredundant-decls -Wreturn-type \
    -Wsequence-point  -Wshadow -Wsign-compare  -Wstack-protector \
    -Wstrict-aliasing -Wstrict-aliasing=2 -Wswitch  -Wswitch-default \
    -Wswitch-enum -Wtrigraphs  -Wuninitialized \
    -Wunknown-pragmas  -Wunreachable-code -Wunused \
    -Wunused-function  -Wunused-label  -Wunused-parameter \
    -Wunused-value  -Wunused-variable  -Wvariadic-macros \
    -Wvolatile-register-var  -Wwrite-strings

# Include debug symbols; trap on signed integer overflows; install
# mudflaps for runtime checks on arrays (including malloced ones);
# generate profiling hooks and output gmon.out (mudflaps and profiling
# are mutually exclusive; uncomment as needed)
DBGFLAGS ?= -g -ftrapv # -fmudflap -pg

# Build position-independent executables; fortify with array checks;
# protect stack against smashing (intentional or accidental)
SECFLAGS ?= -fPIE -D_FORTIFY_SOURCE=2 -fstack-protector

# Dependency generation, commented out due to massive headache
DEPFLAGS ?= # -MMD

# Run the link-time optimizer; rearrange some stuff to save code size
LDOPTFLAGS ?= -flto # -Wl,--gc-sections
LDWARNFLAGS ?=
# Include debug symbols; use the mudflaps library for runtime checks
LDDBGFLAGS ?= -g # -lmudflap 

# Link as a position-independent executable; mark ELF sections
# read-only where applicable; resolve all dynamic symbols at initial
# load of program and (in combination with relro) mark PLT read-only
LDSECFLAGS ?= -pie -Wl,-z,relro -Wl,-z,now
# Generate position-independent code in a shared library (relocations
# performed when the library is loaded)
LDLIB ?= -fPIC
ARFLAGS ?= rcs

# Collect all our flags for the compiler to use
CFLAGS = $(WARNFLAGS) $(OPTFLAGS) $(SECFLAGS) $(INCLUDES) $(DBGFLAGS) $(DEPFLAGS) $(USERFLAGS) $(USERCFLAGS)
CXXFLAGS = $(CXXWARNFLAGS) $(OPTFLAGS) $(SECFLAGS) $(INCLUDES) $(DBGFLAGS) $(DEPFLAGS) $(USERFLAGS) $(USERCXXFLAGS)
LDFLAGS = $(LDWARNFLAGS) $(LDOPTFLAGS) $(LDSECFLAGS) $(LIBS) $(LDDBGFLAGS) $(USERFLAGS) $(USERLDFLAGS)
LDLIBFLAGS = $(LDWARNFLAGS) $(LDOPTFLAGS) $(LDLIB) $(LIBS) $(LDDBGFLAGS) $(USERFLAGS) $(USERLDFLAGS)

all: $(PROJ)
.PHONY: all

# Build the project
$(PROJ): $(OBJ)
	@echo LD $@
ifneq (,$(CXX_SRC))
	$(Q)$(CXX) $+ $(LDFLAGS) -o $@
else
	$(Q)$(CC) $+ $(LDFLAGS) -o $@
endif

$(LIBNAME).so : $(OBJ)
	@echo LDLIB $(LIBNAME).so
ifneq (,$(CXX_SRC))
	$(Q)$(CXX) $+ $(LDLIBFLAGS) -shared -Wl,-soname,$(@) -o $(@)
else
	$(Q)$(CC) $+ $(LDLIBFLAGS) -shared -Wl,-soname,$(@) -o $(@)
endif

$(LIBNAME).a : $(OBJ)
	@echo AR $@
	$(Q)$(AR) $(ARFLAGS) $(@) $+

.PHONY: shared static
shared: $(LIBNAME).so
static: $(LIBNAME).a

# Generate object files; output assembly listings alongside.  
$(C_OBJ) : %.o : %.c $(C_HDR)
	@echo CC $(notdir $<)
	$(Q)$(CC) $(CFLAGS) $(ASMFLAGS)$(+:%.c=%.$(ASMNAME)) -c $+ -o $@

$(CXX_OBJ) : %.o : %.cc $(CXX_HDR)
	@echo CXX $(notdir $<)
	$(Q)$(CXX) $(CXXFLAGS) $(ASMFLAGS)$(+:%.cc=%.$(ASMNAME)) -c $+ -o $@

.PHONY: check-syntax-c check-syntax-cc check-syntax 

check-syntax: check-syntax-c check-syntax-cc

check-syntax-c:
ifneq (,$(findstring .c,$(C_SRC)))
	@echo SYNTAX_CHECK $(C_SRC)
	$(Q)$(CC) -fsyntax-only $(WARNFLAGS) $(INCLUDES) $(C_SRC)
endif

check-syntax-cc:
ifneq (,$(findstring .cc,$(CXX_SRC)))
	@echo SYNTAX_CHECK $(CXX_SRC)
	$(Q)$(CXX) -fsyntax-only $(CXXWARNFLAGS) $(INCLUDES) $(CXX_SRC)
endif

# Remove executable, object and assembly files
.PHONY: clean

clean:
	@echo CLEAN $(PROJ) $(OBJ_SHORT:%.o=%)
# Clean up executable
	$(Q)rm -f $(PROJ)
# Clean up object files
	$(Q)rm -f $(OBJ)
# Clean up assembly listings
	$(Q)rm -f $(ASM)
# Clean up shared library
	$(Q)rm -f $(LIBNAME).so
# Clean up static library
	$(Q)rm -f $(LIBNAME).a
# Clean up dependency files
	$(Q)find . -name "*.d" | xargs rm -f
# Clean up counter files for coverage information
	$(Q)find . -name "*.gcda" | xargs rm -f 
	$(Q)find . -name "*.gcno" | xargs rm -f 

# Print debug information about any variable
debug-%:
	@echo '$*=$($*)'
	@echo '  origin = $(origin $*)'
	@echo '  flavor = $(flavor $*)'
	@echo '   value = $(value  $*)'

# Usage message
help:
	@echo 'Usage: '
	@echo
	@echo '    make             -- build the executable ($(PROJ))        '
	@echo			    
	@echo '    make Q=""        -- print full commands and their output: '
	@echo '                        "gcc -Wall -c foo.c -o foo.o"         '
	@echo '                        instead of "CC foo.o"                 '
	@echo			    
	@echo '    make shared      -- build a shared library ($(LIBNAME).so)'
	@echo			    
	@echo '    make static      -- build a static library ($(LIBNAME).a) '
	@echo			    
	@echo '    make clean       -- clean up the build		     '
	@echo
	@echo '    make debug-SRC   -- print everything that make 	     '
	@echo '                        knows about the variable $$(SRC)      '
	@echo '                        (works for any variable name)         '
	@echo
	@echo '    make check-syntax   -- Ask the compiler for all warnings  '
	@echo '                           and errors (use with flymake-mode) '
