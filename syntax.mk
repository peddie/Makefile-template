.PHONY: check-syntax-c check-syntax-cc check-syntax

CXX_EXT ?= cc

check-syntax: check-syntax-c check-syntax-cc $(EXTRA_CHECKS)

ifdef CHK_SOURCES
C_CHK_SOURCES = $(filter %.c,$(CHK_SOURCES))
CXX_CHK_SOURCES = $(filter %.$(CXX_EXT),$(CHK_SOURCES))
else
C_CHK_SOURCES = $(C_SRC)
CXX_CHK_SOURCES = $(CXX_SRC)
endif

check-syntax-c:
ifneq (,$(findstring .c,$(C_CHK_SOURCES)))
	@echo SYNTAX_CHECK $(notdir $(C_CHK_SOURCES))
	$(Q)$(CC) -fsyntax-only $(CFLAGS) $(C_CHK_SOURCES)
endif
ifneq (,$(findstring .c,$(C_TESTS_SRC)))
	@echo SYNTAX_CHECK $(C_TESTS_SRC)
	$(Q)$(CC) -fsyntax-only $(WARNFLAGS) $(INCLUDES) $(C_TESTS_SRC)
endif

check-syntax-cc:
ifneq (,$(findstring .$(CXX_EXT),$(CXX_CHK_SOURCES)))
	@echo SYNTAX_CHECK $(notdir $(CXX_CHK_SOURCES))
	$(Q)$(CXX) -fsyntax-only $(CXXFLAGS) $(CXX_CHK_SOURCES)
endif
ifneq (,$(findstring .$(CXX_EXT),$(CXX_TESTS_SRC)))
	@echo SYNTAX_CHECK $(CXX_TESTS_SRC)
	$(Q)$(CXX) -fsyntax-only $(WARNFLAGS) $(INCLUDES) $(CXX_TESTS_SRC)
endif

.PHONY: lint lint-c lint-cc
lint: lint-c lint-cc

# Where does the compiler search for #includes?
COMPILER_INCLUDE_DIRS ?= $(shell echo | cpp -v |& perl -0pe "s/.*\#include.*search starts here:(.*)\#include.*search starts here:(.*)End of search list..*/\1 \2/gms; s/\n/ /gms")

CXX_INCLUDE_DIRS ?= $(COMPILER_INCLUDE_DIRS) $(shell $(CXX) -print-file-name=include)
CXX_INCLUDES ?= $(foreach include,$(CXX_INCLUDE_DIRS),-I$(include))

CC_INCLUDE_DIRS ?= $(COMPILER_INCLUDE_DIRS) $(shell $(CC) -print-file-name=include)
CC_INCLUDES ?= $(foreach include,$(CC_INCLUDE_DIRS),-I$(include))

# Google's C++ linter (not too bad for C either)
GOOGLE_CPPLINT ?= $(shell if [ `which cpplint.py` ]; then echo cpplint.py; elif [ `which cpplint` ]; then echo cpplint; fi;)

# cppcheck -- warning, this can be quite slow, so we don't include it
# by default!
CPPCHECK ?= $(shell if [ `which cppcheck` ]; then echo cppcheck; fi;)
CPPCHECK_FLAGS ?= --enable=all --std=c++11 --force

# The venerable splint.  It's infuriating and fragile, so we don't
# include it by default
SPLINT ?= $(shell if [ `which splint` ]; then echo splint; fi;)
SPLINT_FLAGS ?= +posixlib -warnposix

# sparse
SPARSE ?= $(shell if [ `which cgcc` ]; then echo cgcc; fi;)
SPARSE_FLAGS ?= -Wsparse-all -Wno-declaration-after-statement -fsyntax-only

# Overload these to specify more built-in tests.
C_LINT_TARGETS ?= cpplint-c sparse
CXX_LINT_TARGETS ?= cpplint-cc

# Allow the user to tack on additional targets.
.PHONY: $(C_LINT_TARGETS) $(CXX_LINT_TARGETS) $(USER_C_LINT_TARGETS)
# Final configuration
lint-c: $(C_LINT_TARGETS) $(USER_C_LINT_TARGETS)
lint-cc: $(CXX_LINT_TARGETS) $(USER_CXX_LINT_TARGETS)

# C linting
ifneq (,$(findstring .c,$(C_CHK_SOURCES)))

cpplint-c:
ifneq (,$(GOOGLE_CPPLINT))
	@echo CPPLINT $(notdir $(C_CHK_SOURCES))
	$(Q)$(GOOGLE_CPPLINT) --filter=-readability/casting $(C_CHK_SOURCES) 2>&1 | perl -pe "s/^(.*\.c:\d+:)\s+(.*)$$/\1 warning: \2/"
else
	@echo "'cpplint.py' not found on your $$PATH!"
endif

splint:
ifneq (,$(SPLINT))
	@echo SPLINT $(notdir $(C_CHK_SOURCES))
	$(Q)$(SPLINT) $(SPLINT_FLAGS) $(CC_INCLUDES) $(INCLUDES) $(C_CHK_SOURCES)
else
	@echo "'splint' not found on your $$PATH!"
endif

sparse:
ifneq (,$(SPARSE))
ifneq (,$(C_OBJ))
# bit of a hack, this
	@echo SPARSE \(CGCC\) $(notdir $(C_OBJ))
	$(Q)$(MAKE) CC='$(SPARSE) $(SPARSE_FLAGS)' $(C_OBJ)
else
	@echo "sparse (cgcc) is only for C (not C++) code!"
endif
else
	@echo "'cgcc' not found on your $$PATH!"
endif

endif  # C_CHK_SOURCES

ifneq (,$(findstring .$(CXX_EXT),$(CXX_CHK_SOURCES)))

cpplint-cc:
ifneq (,$(GOOGLE_CPPLINT))
	@echo CPPLINT $(notdir $(CXX_CHK_SOURCES))
	$(Q)$(GOOGLE_CPPLINT) $(CXX_CHK_SOURCES) 2>&1 | perl -pe "s/^(.*\.$(CXX_EXT):\d+:)\s+(.*)$$/\1 warning: \2/"
else
	@echo "'cpplint.py' not found on your $$PATH!"
endif

cppcheck:
ifneq (,$(CPPCHECK))
	@echo CPPCHECK $(notdir $(CXX_CHK_SOURCES))
	$(Q)$(CPPCHECK) $(CPPCHECK_FLAGS) $(CXX_INCLUDES) $(INCLUDES) $(CXX_CHK_SOURCES) 2>&1 >/dev/null | perl -pe "s/\[(\S+\.$(CXX_EXT)):(\d+)\]:/\1:\2: warning:/; s/^\(information\).*$$//"
else
	@echo "'cppcheck' not found on your $$PATH!"
endif

endif  # CXX_CHK_SOURCES
