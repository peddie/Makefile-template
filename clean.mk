# Remove executable, object and assembly files
.PHONY: clean

clean:
	@echo CLEAN $(PROJ) $(OBJ_SHORT:%.o=%) $(TESTS)
# Clean up executable
	$(Q)rm -f $(PROJ)
# Clean up object files
	$(Q)rm -f $(OBJ)
# Clean up assembly listings
	$(Q)rm -f $(ASM)
ifdef LIBNAME
# Clean up shared library
	$(Q)rm -f $(LIBNAME).so
# Clean up static library
	$(Q)rm -f $(LIBNAME).a
endif
ifdef USERCLEAN
	$(Q)rm -fr $(USERCLEAN)
endif
ifdef TESTS_SRC
# Clean up unit tests
	$(Q)rm -f $(TESTS) $(TESTS_OBJ) $(TESTS_ASM)
endif
ifdef AVRPROJ
# Clean up AVR stuff
	$(Q)rm -f $(AVR_HEX) $(AVRPROJ) $(AVR_EEPROM) $(AVR_EXT_LISTING)
endif
ifdef CM4_PROJ
# Clean up CM4 stuff
	$(Q)rm -f $(CM4_IMAGES) $(CM4_EXT_LISTING)
endif
# Clean up dependency files
	$(Q)find . -name "*.d" | xargs rm -f
# Clean up counter files for coverage information
	$(Q)find . -name "*.gcda" | xargs rm -f
	$(Q)find . -name "*.gcno" | xargs rm -f
