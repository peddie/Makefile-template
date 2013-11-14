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

.PHONY: lint lint-c lint-cc sparse
lint: lint-c lint-cc

# Where does the compiler search for #includes?
COMPILER_INCLUDE_DIRS ?= $(shell echo | cpp -v |& perl -0pe "s/.*\#include.*search starts here:(.*)\#include.*search starts here:(.*)End of search list..*/\1 \2/gms; s/\n/ /gms")

CXX_INCLUDE_DIRS ?= $(COMPILER_INCLUDE_DIRS) $(shell $(CXX) -print-file-name=include)
CXX_INCLUDES ?= $(foreach include,$(CXX_INCLUDE_DIRS),-I$(include))

CC_INCLUDE_DIRS ?= $(COMPILER_INCLUDE_DIRS) $(shell $(CC) -print-file-name=include)
CC_INCLUDES ?= $(foreach include,$(CC_INCLUDE_DIRS),-I$(include))

# Google's C++ linter (not too bad for C either)
GOOGLE_CPPLINT ?= $(shell if [ `which cpplint.py` ]; then echo cpplint.py; elif [ `which cpplint` ]; then echo cpplint; fi;)

# cppcheck -- warning, this can be quite slow!
CPPCHECK ?= $(shell if [ `which cppcheck` ]; then echo cppcheck; fi;)
CPPCHECK_FLAGS ?= --enable=all --std=c++11 --force

# The venerable splint.
SPLINT ?= $(shell if [ `which splint` ]; then echo splint; fi;)
SPLINT_FLAGS ?= +posixlib -warnposix

# sparse
SPARSE ?= $(shell if [ `which cgcc` ]; then echo cgcc; fi;)
SPARSE_FLAGS ?= -Wsparse-all -Wno-declaration-after-statement -fsyntax-only

# Final configuration
CXX_LINT ?= $(CPPCHECK) $(GOOGLE_CPPLINT)
C_LINT ?= $(SPLINT)

lint-c:
ifneq (,$(findstring .c,$(C_CHK_SOURCES)))
	@echo LINT $(notdir $(C_CHK_SOURCES))
	$(Q)$(SHELL) -c 'for linter in $(C_LINT) ;\
            do \
              if echo $${linter} | grep -q cpplint ;\
              then \
                $${linter} $(C_CHK_SOURCES) 2>&1 | perl -pe "s/^(.*\.c:\d+:)\s+(.*)$$/\1 warning: \2/" ;\
              elif echo $${linter} | grep -q splint ;\
              then \
                $${linter} $(SPLINT_FLAGS) $(CC_INCLUDES) $(C_CHK_SOURCES) ;\
              else \
                $${linter} $(INCLUDES) $(C_CHK_SOURCES) ;\
              fi \
            done'
endif

lint-cc:
ifneq (,$(findstring .$(CXX_EXT),$(CXX_CHK_SOURCES)))
	@echo LINT $(notdir $(CXX_CHK_SOURCES))
	$(Q)$(SHELL) -c 'for linter in $(CXX_LINT) ;\
            do \
              if echo $${linter} | grep -q cpplint ;\
              then \
                $${linter} $(CXX_CHK_SOURCES) 2>&1 | perl -pe "s/^(.*\.$(CXX_EXT):\d+:)\s+(.*)$$/\1 warning: \2/" ;\
              elif echo $${linter} | grep -q cppcheck ;\
              then \
                $${linter} $(CPPCHECK_FLAGS) $(CXX_INCLUDES) $(INCLUDES) $(CXX_CHK_SOURCES) 2>&1 >/dev/null | perl -pe "s/\[(\S+\.$(CXX_EXT)):(\d+)\]:/\1:\2: warning:/; s/^\(information\).*$$//";\
              else \
                $${linter} $(INCLUDES) $(CXX_CHK_SOURCES) ;\
              fi \
            done'
endif

ifneq (,$(C_OBJ))
# bit of a hack, this
sparse:
	@echo SPARSE \(CGCC\) $(notdir $(C_OBJ))
	$(Q)$(MAKE) CC='$(SPARSE) $(SPARSE_FLAGS)' $(C_OBJ)
else
sparse:
	@echo "sparse (cgcc) is only for C (not C++) code!"
endif
