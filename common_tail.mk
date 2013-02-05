.PHONY: debug-% help

# Usage message
help:
	@echo 'Usage: '
	@echo
	@echo '    make              -- build the executable ($(PROJ))       '
	@echo			     
	@echo '    make Q=""         -- print full commands and their output:'
	@echo '                         "gcc -Wall -c foo.c -o foo.o"        '
	@echo '                         instead of "CC foo.o"                '
	@echo			     
	@echo '    make shared       -- build a shared library               '
	@echo '                         ($(SHAREDNAME))'
	@echo			     
	@echo '    make static       -- build a static library               '
	@echo '                         ($(STATICNAME))'
	@echo			     
	@echo '    make tests        -- compile the test suite               '
	@echo '                         ($(TESTS))'
	@echo			     
	@echo '    make test         -- compile and run the test suite       '
	@echo			     
	@echo '    make foo_test_run -- compile and run the tests in         '
	@echo '                         foo_test.c or foo_test.$(CXX_EXT)    '
	@echo			     
	@echo '    make clean        -- clean up the build		     '
	@echo			     
	@echo '    make debug-SRC    -- print everything that make 	     '
	@echo '                         knows about the variable $$(SRC)     '
	@echo '                         (works for any variable name)        '
	@echo
	@echo '    make check-syntax -- Ask the compiler for all warnings    '
	@echo '                         and errors (use with flymake-mode)   '
	@echo
	@echo '    make lint         -- Run external linters (splint, cpplint.py,'
	@echo '                         cppcheck) to find code problems      '
	@echo
	@echo '    make avr-all      -- Build code for ATmega AVR chips      '
	@echo
	@echo '    make flash        -- program an AVR via an ISP            '
	@echo
	@echo '    make flash-eeprom -- Upload an AVR EEPROM image via an ISP'
	@echo
ifdef CM4_PROJ
	@echo '    make cm4-all      -- Build code for ARM Cortex-M4 chips    '
	@echo
	@echo '    make flash        -- program a Cortex-M4 via an ISP        '
	@echo
endif
ifdef CM4_EEPROM
	@echo '    make flash-eeprom -- Upload an EEPROM image via an ISP     '
	@echo
endif

# Print debug information about any variable
debug-%:
	@echo '$*=$($*)'
	@echo '  origin = $(origin $*)'
	@echo '  flavor = $(flavor $*)'
	@echo '   value = $(value  $*)'

