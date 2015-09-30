# We prefer C99 with GNU extensions
DEFAULT_WARNFLAGS ?= -Wall -Wextra -std=gnu99 -Wimplicit \
             -Wshadow -Wswitch-default -Wswitch-enum -Wundef \
             -Wuninitialized -Wpointer-arith -Wstrict-prototypes \
             -Wmissing-prototypes -Wcast-align -Wformat=2 \
             -Wimplicit-function-declaration -Wredundant-decls \
             -Wformat-security 

# And for C++:
# http://stackoverflow.com/questions/399850/best-compiler-warning-level-for-c-c-compilers
ifdef CLANGIN
DEFAULT_CXXWARNFLAGS ?= -Wall -Weffc++ -std=gnu++11 \
    -Wextra  -Waggregate-return -Wcast-align \
    -Wcast-qual  -Wchar-subscripts  -Wcomment -Wconversion \
    -Wdisabled-optimization -Wfloat-equal  -Wformat  -Wformat=2 \
    -Wformat-nonliteral -Wformat-security -Wformat-y2k \
    -Wimport  -Winit-self  -Winline -Winvalid-pch   \
    -Wlong-long -Wmissing-braces \
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
else
DEFAULT_CXXWARNFLAGS ?= -Wall -Weffc++ -std=gnu++11 \
    -Wextra  -Waggregate-return -Wcast-align \
    -Wcast-qual  -Wchar-subscripts  -Wcomment -Wconversion \
    -Wdisabled-optimization -Wfloat-equal  -Wformat  -Wformat=2 \
    -Wformat-nonliteral -Wformat-security -Wformat-y2k \
    -Wimport  -Winit-self  -Winline -Winvalid-pch   \
    -Wunsafe-loop-optimizations -Wlong-long -Wmissing-braces \
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
endif

ifndef NO_WERROR
WARNFLAGS ?= $(DEFAULT_WARNFLAGS) -Werror
CXXWARNFLAGS ?= $(DEFAULT_CXXWARNFLAGS) -Werror
else
WARNFLAGS ?= $(DEFAULT_WARNFLAGS)
CXXWARNFLAGS ?= $(DEFAULT_CXXWARNFLAGS)
endif


INCLUDES = $(INCLUDENAMES:%=-I%) $(OTHERINCLUDE)
LIBS = $(LIBNAMES:%=-l%) $(LIBDIRS:%=-L%) $(OTHERLIB)

# Collect all our flags for the compiler to use
CFLAGS = $(WARNFLAGS) $(OPTFLAGS) $(SECFLAGS) $(INCLUDES) $(DBGFLAGS) $(DEPFLAGS) $(USERFLAGS) $(USERCFLAGS)
CXXFLAGS = $(CXXWARNFLAGS) $(OPTFLAGS) $(SECFLAGS) $(INCLUDES) $(DBGFLAGS) $(DEPFLAGS) $(USERFLAGS) $(USERCXXFLAGS)
LDFLAGS = $(LDWARNFLAGS) $(LDOPTFLAGS) $(LDSECFLAGS) $(LIBS) $(LDDBGFLAGS) $(USERFLAGS) $(USERLDFLAGS)

.PHONY: all
all: $(PROJ)

# Build the project
.SECONDEXPANSION:
$(PROJ): % : $$(findstring $$(*:%=%.$(OBJECT_FILE_SUFFIX)),$(OBJ)) $(filter-out $(PROJ:%=%.$(OBJECT_FILE_SUFFIX)),$(OBJ))
	@echo LD $@
ifneq (,$(CXX_SRC))
	$(Q)$(CXX) $(filter %.$(OBJECT_FILE_SUFFIX) %.a %.so, $^) $(LDFLAGS) $(LDOUTPUTFLAGS)$(@).map -o $@
else
	$(Q)$(CC) $(filter %.$(OBJECT_FILE_SUFFIX) %.a %.so, $^) $(LDFLAGS) $(LDOUTPUTFLAGS)$(@).map -o $@
endif

.SECONDEXPANSION:
$(AVRPROJ): %.elf : $$(findstring $$(*:%=%.$(OBJECT_FILE_SUFFIX)),$(OBJ)) $(filter-out $(PROJ:%=%.$(OBJECT_FILE_SUFFIX)),$(OBJ))
	@echo LD $@
ifneq (,$(CXX_SRC))
	$(Q)$(CXX) $(filter %.$(OBJECT_FILE_SUFFIX) %.a %.so, $^) $(LDFLAGS) -o $@
else
	$(Q)$(CC)  $(filter %.$(OBJECT_FILE_SUFFIX) %.a %.so, $^) $(LDFLAGS) -o $@
endif

.SECONDEXPANSION:
$(CM4_PROJ): %.elf : $$(findstring $$(*:%=%.$(OBJECT_FILE_SUFFIX)),$(OBJ)) $(filter-out $(PROJ:%=%.$(OBJECT_FILE_SUFFIX)),$(OBJ))
	@echo LD $@
ifneq (,$(CXX_SRC))
	$(Q)$(CXX) $(filter %.$(OBJECT_FILE_SUFFIX) %.a %.so, $^) $(LDFLAGS) -o $@
else
	$(Q)$(CC) $(filter %.$(OBJECT_FILE_SUFFIX) %.a %.so, $^) $(LDFLAGS) -o $@
endif

# Generate object files; output assembly listings alongside.  esden
# tells me that it's hard to get a real GCC on OS X, so avoid the
# worst of the non-portability.
$(CUSTOM_C_OBJ) : %.$(OBJECT_FILE_SUFFIX) : %.c
	@echo CC \(CUSTOM\) $(notdir $<)
ifdef CLANGIN
	$(Q)$(CC) $(CUSTOM_CFLAGS) -c $< -o $@
else
	$(Q)$(CC) $(CUSTOM_CFLAGS) $(ASMFLAGS)$(@:%.$(OBJECT_FILE_SUFFIX)=%.$(ASMNAME)) -c $< -o $@
endif

$(filter-out $(CUSTOM_C_OBJ), $(C_OBJ)) : %.$(OBJECT_FILE_SUFFIX) : %.c # $(C_HDR)
	@echo CC $(notdir $<)
ifdef CLANGIN
	$(Q)$(CC) $(CFLAGS) -c $< -o $@
else
	$(Q)$(CC) $(CFLAGS) $(ASMFLAGS)$(@:%.$(OBJECT_FILE_SUFFIX)=%.$(ASMNAME)) -c $< -o $@
endif

$(CUSTOM_CXX_OBJ) : %.$(OBJECT_FILE_SUFFIX) : %.$(CXX_EXT)
	@echo CXX \(CUSTOM\) $(notdir $<)
ifdef CLANGIN
	$(Q)$(CXX) $(CUSTOM_CXXFLAGS) -c $< -o $@
else
	$(Q)$(CXX) $(CUSTOM_CXXFLAGS) $(ASMFLAGS)$(@:%.$(OBJECT_FILE_SUFFIX)=%.$(ASMNAME)) -c $< -o $@
endif

$(filter-out $(CUSTOM_CXX_OBJ), $(CXX_OBJ)) : %.$(OBJECT_FILE_SUFFIX) : %.$(CXX_EXT) # $(CXX_HDR)
	@echo CXX $(notdir $<)
ifdef CLANGIN
	$(Q)$(CXX) $(CXXFLAGS) -c $< -o $@
else
	$(Q)$(CXX) $(CXXFLAGS) $(ASMFLAGS)$(@:%.$(OBJECT_FILE_SUFFIX)=%.$(ASMNAME)) -c $< -o $@
endif

$(OBJ) : $(HDR)
