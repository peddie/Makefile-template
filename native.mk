LIBNAME ?= $(PROJ:%=lib%)

# GCC by default (easy to override from outside the makefile)
CC ?= gcc 
CPP ?= g++
AR ?= ar

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

# Include debug symbols; trap on signed integer overflows; install
# mudflaps for runtime checks on arrays (including malloced ones);
# generate profiling hooks and output gmon.out (mudflaps and profiling
# are mutually exclusive; uncomment as needed).  
# 
# TODO: mixing in mudflaps or profiling should really just be another
# target.
DBGFLAGS ?= -g -ftrapv # -fmudflap -pg

# Build position-independent executables; fortify with array checks;
# protect stack against smashing (intentional or accidental)
ifeq (x86_64,$(shell uname -m))
SECFLAGS ?= -fPIC -D_FORTIFY_SOURCE=2 -fstack-protector-all
else
SECFLAGS ?= -fPIE -D_FORTIFY_SOURCE=2 -fstack-protector-all
endif

# Dependency generation, commented out due to massive headache
DEPFLAGS ?= # -MMD

# Run the link-time optimizer; rearrange some stuff to save code size
ifeq ("$(UNAME_OS)","Darwin")
LDOPTFLAGS ?= -flto
else
LDOPTFLAGS ?= -flto -Wl,--gc-sections
endif
LDWARNFLAGS ?=
# Include debug symbols; use the mudflaps library for runtime checks
LDDBGFLAGS ?= -g # -lmudflap 

# Link as a position-independent executable; mark ELF sections
# read-only where applicable; resolve all dynamic symbols at initial
# load of program and (in combination with relro) mark PLT read-only
#
# TODO: -pie fails on x86_64 sometimes.  Why?
ifeq ("$(UNAME_OS)","Darwin")
LDSECFLAGS ?= -pie
else
LDSECFLAGS ?= -pie -Wl,-z,relro -Wl,-z,now
endif
# Generate position-independent code in a shared library (relocations
# performed when the library is loaded)
LDLIBFLAGS ?= -fPIC
ARFLAGS ?= rcs

SHAREDNAME ?= $(LIBNAME:%=%.so)
STATICNAME ?= $(LIBNAME:%=%.a)

$(SHAREDNAME) : lib%.so : %.o $(filter-out $(LIBNAME:lib%=%.o),$(OBJ))
	@echo LDLIB $@
ifneq (,$(CXX_SRC))
	$(Q)$(CXX) $+ $(LDLIBFLAGS) -shared -Wl,-soname,$(@) -o $(@)
else
	$(Q)$(CC) $+ $(LDLIBFLAGS) -shared -Wl,-soname,$(@) -o $(@)
endif

$(STATICNAME) : lib%.a : %.o $(filter-out $(LIBNAME:lib%=%.o),$(OBJ))
	@echo AR $@
	$(Q)$(AR) $(ARFLAGS) $(@) $+

.PHONY: shared static
shared: $(SHAREDNAME)
static: $(STATICNAME)

