# We prefer C99 with GNU extensions
DEFAULT_WARNFLAGS ?= -Wall -Wextra -std=gnu99 -Wimplicit \
             -Wshadow -Wswitch-default -Wswitch-enum -Wundef \
             -Wuninitialized -Wpointer-arith -Wstrict-prototypes \
             -Wmissing-prototypes -Wcast-align -Wformat=2 \
             -Wimplicit-function-declaration -Wredundant-decls \
             -Wformat-security 

# And for C++:
# http://stackoverflow.com/questions/399850/best-compiler-warning-level-for-c-c-compilers
DEFAULT_CXXWARNFLAGS ?= -Wall -Weffc++ -std=gnu++11 -pedantic  \
    -Wextra  -Waggregate-return -Wcast-align \
    -Wcast-qual  -Wchar-subscripts  -Wcomment -Wconversion \
    -Wdisabled-optimization -Wfloat-equal  -Wformat  -Wformat=2 \
    -Wformat-nonliteral -Wformat-security -Wformat-y2k \
    -Wimport  -Winit-self  -Winline -Winvalid-pch   \
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

ifndef NO_WERROR
WARNFLAGS = $(DEFAULT_WARNFLAGS) -Werror -pedantic-errors
CXXWARNFLAGS = $(DEFAULT_CXXWARNFLAGS) -Werror -pedantic-errors
else
WARNFLAGS = $(DEFAULT_WARNFLAGS)
CXXWARNFLAGS = $(DEFAULT_CXXWARNFLAGS)
endif

INCLUDES = $(INCLUDENAMES:%=-I%) $(OTHERINCLUDE)
LIBS = $(LIBNAMES:%=-l%) $(LIBDIRS:%=-L%) $(OTHERLIB)

# Collect all our flags for the compiler to use
CFLAGS = $(WARNFLAGS) $(OPTFLAGS) $(SECFLAGS) $(INCLUDES) $(DBGFLAGS) $(DEPFLAGS) $(USERFLAGS) $(USERCFLAGS)
CXXFLAGS = $(CXXWARNFLAGS) $(OPTFLAGS) $(SECFLAGS) $(INCLUDES) $(DBGFLAGS) $(DEPFLAGS) $(USERFLAGS) $(USERCXXFLAGS)
LDFLAGS = $(LDWARNFLAGS) $(LDOPTFLAGS) $(LDSECFLAGS) $(LIBS) $(LDDBGFLAGS) $(USERFLAGS) $(USERLDFLAGS)
LDLIBFLAGS = $(LDWARNFLAGS) $(LDOPTFLAGS) $(LDLIB) $(LIBS) $(LDDBGFLAGS) $(USERFLAGS) $(USERLDFLAGS)

.PHONY: all
all: $(PROJ)

# Build the project
.SECONDEXPANSION:
$(PROJ): % : $$(findstring $$(*:%=%.o),$(OBJ)) $(filter-out $(PROJ:%=%.o),$(OBJ))
	@echo LD $@
ifneq (,$(CXX_SRC))
	$(Q)$(CXX) $^ $(LDFLAGS) -o $@
else
	$(Q)$(CC) $^ $(LDFLAGS) -o $@
endif

.SECONDEXPANSION:
$(AVRPROJ): %.elf : $$(findstring $$(*:%=%.o),$(OBJ)) $(filter-out $(PROJ:%=%.o),$(OBJ))
	@echo LD $@
ifneq (,$(CXX_SRC))
	$(Q)$(CXX) $^ $(LDFLAGS) -o $@
else
	$(Q)$(CC) $^ $(LDFLAGS) -o $@
endif

.SECONDEXPANSION:
$(CM4_PROJ): %.elf : $$(findstring $$(*:%=%.o),$(OBJ)) $(filter-out $(PROJ:%=%.o),$(OBJ))
	@echo LD $@
ifneq (,$(CXX_SRC))
	$(Q)$(CXX) $^ $(LDFLAGS) -o $@
else
	$(Q)$(CC) $^ $(LDFLAGS) -o $@
endif

# Generate object files; output assembly listings alongside.  esden
# tells me that it's hard to get a real GCC on OS X, so avoid the
# worst of the non-portability.
$(CUSTOM_C_OBJ) : %.o : %.c
	@echo CC \(CUSTOM\) $(notdir $<)
ifeq ("$(UNAME_OS)","Darwin")
	$(Q)$(CC) $(CUSTOM_CFLAGS) -c $< -o $@
else
	$(Q)$(CC) $(CUSTOM_CFLAGS) $(ASMFLAGS)$(^:%.c=%.$(ASMNAME)) -c $< -o $@
endif

$(filter-out $(CUSTOM_C_OBJ), $(C_OBJ)) : %.o : %.c # $(C_HDR)
	@echo CC $(notdir $<)
ifeq ("$(UNAME_OS)","Darwin")
	$(Q)$(CC) $(CFLAGS) -c $< -o $@
else
	$(Q)$(CC) $(CFLAGS) $(ASMFLAGS)$(^:%.c=%.$(ASMNAME)) -c $< -o $@
endif

$(CUSTOM_CXX_OBJ) : %.o : %.$(CXX_EXT)
	@echo CXX \(CUSTOM\) $(notdir $<)
ifeq ("$(UNAME_OS)","Darwin")
	$(Q)$(CXX) $(CUSTOM_CXXFLAGS) -c $< -o $@
else
	$(Q)$(CXX) $(CUSTOM_CXXFLAGS) $(ASMFLAGS)$(^:%.$(CXX_EXT)=%.$(ASMNAME)) -c $< -o $@
endif

$(filter-out $(CUSTOM_CXX_OBJ), $(CXX_OBJ)) : %.o : %.$(CXX_EXT) # $(CXX_HDR)
	@echo CXX $(notdir $<)
ifeq ("$(UNAME_OS)","Darwin")
	$(Q)$(CXX) $(CXXFLAGS) -c $< -o $@
else
	$(Q)$(CXX) $(CXXFLAGS) $(ASMFLAGS)$(^:%.$(CXX_EXT)=%.$(ASMNAME)) -c $< -o $@
endif

$(OBJ) : $(HDR)
