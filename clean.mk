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
# Clean up shared library
	$(Q)rm -f $(LIBNAME).so
# Clean up static library
	$(Q)rm -f $(LIBNAME).a
# Clean up unit tests
	$(Q)rm -f $(TESTS) $(TESTS_OBJ) $(TESTS_ASM)
# Clean up AVR stuff
	$(Q)rm -f $(AVR_HEX) $(AVRPROJ) $(AVR_EEPROM) $(AVR_EXT_LISTING)
# Clean up dependency files
	$(Q)find . -name "*.d" | xargs rm -f
# Clean up counter files for coverage information
	$(Q)find . -name "*.gcda" | xargs rm -f 
	$(Q)find . -name "*.gcno" | xargs rm -f 
