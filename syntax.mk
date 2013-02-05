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

# TODO: add sparse/cgcc support
C_LINT ?= $(shell if [ `which splint` ]; then echo splint; fi;)
GOOGLE_CPPLINT ?= $(shell if [ `which cpplint.py` ]; then echo cpplint.py; elif [ `which cpplint` ]; then echo cpplint; fi;)
CPPCHECK ?= $(shell if [ `which cppcheck` ]; then echo cppcheck; fi;)
CXX_LINT ?= $(GOOGLE_CPPLINT) $(CPPCHECK)

SPLINT_FLAGS ?= +posixlib -warnposix

lint-c:
ifneq (,$(findstring .c,$(C_CHK_SOURCES)))
	@echo LINT $(notdir $(C_CHK_SOURCES))
	$(Q)$(C_LINT) $(SPLINT_FLAGS) $(INCLUDES) $(C_CHK_SOURCES)
endif

lint-cc:
ifneq (,$(findstring .$(CXX_EXT),$(CXX_CHK_SOURCES)))
	@echo LINT $(notdir $(CXX_CHK_SOURCES))
	$(Q)$(CXX_LINT) $(INCLUDES) $(CXX_CHK_SOURCES)
endif
