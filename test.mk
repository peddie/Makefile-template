CXX_EXT ?= cc

C_TESTS_SRC = $(filter %.c,$(TESTS_SRC))
CXX_TESTS_SRC = $(filter %.$(CXX_EXT),$(TESTS_SRC))

C_TESTS = $(C_TESTS_SRC:%.c=%)
CXX_TESTS = $(CXX_TESTS_SRC:%.$(CXX_EXT)=%)

C_TESTS_ASM ?= $(C_TESTS_SRC:%.c=%.$(ASMNAME))
C_TESTS_OBJ ?= $(C_TESTS_SRC:%.c=%.o)
C_TESTS_DEPS ?= $(C_TESTS_SRC:%.c=%.d)

CXX_TESTS_ASM ?= $(CXX_TESTS_SRC:%.$(CXX_EXT)=%.$(ASMNAME))
CXX_TESTS_OBJ ?= $(CXX_TESTS_SRC:%.$(CXX_EXT)=%.o)
CXX_TESTS_DEPS ?= $(CXX_TESTS_SRC:%.$(CXX_EXT)=%.d)

TESTS_ASM ?= $(C_TESTS_ASM) $(CXX_TESTS_ASM)
TESTS_OBJ ?= $(C_TESTS_OBJ) $(CXX_TESTS_OBJ)
TESTS ?= $(C_TESTS) $(CXX_TESTS)
TESTS_RUN ?= $(C_TESTS:%=%_run) $(CXX_TESTS:%=%_run)

C_TESTS_INCLUDE ?=
ifdef GTEST_DIR
CXX_TESTS_INCLUDE ?= $(GTEST_DIR)
endif

C_TESTS_LINK ?= check
ifdef GTEST_DIR
CXX_TESTS_LINK ?= gtest
endif

.PHONY: tests test $(TESTS_RUN)

tests : $(TESTS)

test : $(TESTS_RUN)

# Build the tests.  This rule isn't a great idea, but it works for
# now.  It assumes that test program "foo_test.c" contains '#include
# "foo.c"' in order to be able to test static functions.
.SECONDEXPANSION:
$(C_TESTS): %_test : %_test.o $$(filter-out $$(*:%=%.o),$(filter-out $(PROJ:%=%.o),$(C_OBJ)))
	@echo LD $@
	$(Q)$(CC) $+ $(LDFLAGS) $(C_TESTS_LINK:%=-l%) -o $@

$(CXX_TESTS): %_test : %_test.o $$(filter-out $$(*:%=%.o),$(filter-out $(PROJ:%=%.o),$(CXX_OBJ)))
	@echo LD $@
	$(Q)$(CXX) $+ $(LDFLAGS) $(CXX_TESTS_LINK:%=-l%) -o $@

$(TESTS_RUN): %_test_run: %_test %_test.c %.c $$(filter-out $$(*:%=%.c),$(filter-out $(PROJ:%=%.c),$(SRC)))
	@echo TEST $*
	$(Q)./$*_test

# Generate object files; output assembly listings alongside.  
$(C_TESTS_OBJ) : %.o : %.c 
	@echo CC $(notdir $<)
	$(Q)$(CC) $(CFLAGS) $(C_TESTS_INCLUDE:%=-I%) $(ASMFLAGS)$(^:%.c=%.$(ASMNAME)) -c $< -o $@

$(CXX_TESTS_OBJ) : %.o : %.$(CXX_EXT)
	@echo CXX $(notdir $<)
	$(Q)$(CXX) $(CXXFLAGS) $(CXX_TESTS_INCLUDE:%=-I%) $(ASMFLAGS)$(^:%.$(CXX_EXT)=%.$(ASMNAME)) -c $< -o $@
