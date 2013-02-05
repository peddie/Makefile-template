### Standard Makefile template
### Copyright (C) Matthew Peddie <peddie@alum.mit.edu>
###
### This file is hereby placed in the public domain, or, if your legal
### system doesn't recognize this concept, you may consider it
### licensed under the WTFPL version 2.0 or any BSD license you
### choose.
###
### This file should be all you need to configure a basic project;
### obviously for more complex projects, you'll need to edit the other
### files as well.  It supports only one project at a time.  Type
### ``make help'' for usage help.

# What's the executable called?
PROJ = 

# What C or C++ files must we compile to make the executable?
SRC ?= 

# What additional headers are needed as dependencies?
HDR ?= 

# What directories must we include?
INCLUDENAMES ?= # e.g. ../mathlib; the makefile will add the -I
OTHERINCLUDE ?= 

# With what libraries should we link?
LIBNAMES ?= # e.g. m gsl atlas; the makefile will add the -l
LIBDIRS ?= # e.g. ../; the makefile will add the -L
OTHERLIB ?=

# You can add custom compiler and linker flags here.  USERFLAGS gets
# used by all compiler and linker calls, except when creating a static
# lib.  The others are specific to their stage.
USERFLAGS ?=
USERCFLAGS ?=
USERCXXFLAGS ?=
USERLDFLAGS ?=

# Unit tests?
TESTS_SRC ?= 

# What's the extension on C++ files?  .cc is the Google default, but
# lots of people use .cpp instead.
CXX_EXT = cc

MKFILE_DIR ?= /home/peddie/programming/Makefile/

include $(MKFILE_DIR)common_head.mk
include $(MKFILE_DIR)native.mk
include $(MKFILE_DIR)build.mk
include $(MKFILE_DIR)test.mk
include $(MKFILE_DIR)syntax.mk
include $(MKFILE_DIR)clean.mk
include $(MKFILE_DIR)docs.mk
include $(MKFILE_DIR)common_tail.mk
