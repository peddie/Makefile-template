Makefile template
===========

This git repository exists only to keep most of the makefile stuff I
know about in a single place.  I use this template all the time; I
just copy it to a new project directory and fill in the blanks when I
need a Makefile.

Installation
------------

        cp Makefile <other project directory>

Features
------------

- Requires almost no work to start using it for basic projects
- Should work for both C and C++.
- Includes recommended warnings and security flags
- Includes commented out development flags, such as for profiling or
  mudflap checking
- Generates nice assembly listings
- Emacs flymake-mode integration
- Handy debug mode -- "make debug-OBJ" to learn about $(OBJ)
- Well documented, including "make help"
- Permissive license (Public Domain / WTFPL / BSD)

Misfeatures and Bugs
------------

- C++ vs. C detection is entirely based on the file extension, which
  is a bad idea.

Coming Soon
------------
- Install and uninstall targets for libraries
- Unit test and test coverage support
- Cross-compile support
- Easy integration of external linters (splint, cpplint.py)
- Rework to be an included file, so user defines only what he wants,
  and install doesn't involve copying
- Correct dependency tracking
- Temporary directories for dependencies, objects and assembly listings
- Multiple projects/targets
- Easy addition of custom code generation stages
