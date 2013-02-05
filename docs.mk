# Stock doxygen targets.
ifdef DOC_DIR
ifneq "$(wildcard $(DOC_DIR) )" ""
docs:
	$(Q)cd $(DOC_DIR); doxygen
	$(Q)x-www-browser $(DOC_DIR)/html/index.html

docs-clean:
	@echo DOC-CLEAN $(DOC_DIR)
	$(Q)rm -rf $(DOC_DIR)/html $(DOC_DIR)/latex

doc: docs
doc-clean: docs-clean

.PHONY: docs docs-clean doc doc-clean

endif
endif
