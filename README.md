Makefile tools
==============

This git repository existed originally to keep most of the makefile
stuff I know about in a single place -- I didn't want to keep having
to rebuild the same thing.  Also it's a handy place to store things
like compiler flags, especially for different platforms, and things
like flashing commands for the AVR.  

Installation
------------

        cp Makefile <other project directory>

Fill in the necessary variables, like `PROJ` and `SRC` (these are
probably the minimum).

Then edit the `MKFILE_DIR` variable to point to this git repository,
or export `MKFILE_DIR` in your `.bashrc`.

Usage
-----

Type `make help` for an overview.

The example `Makefile` shows many of the features.  You're expected to
define source files in `SRC`, headers with stems different from source
file names in `HDR`, etc. (for example, I have a project with
compile-time configs in `config.h`, but there's no `config.c`, so I
say `HDR = config.h`).

`TESTS_SRC` currently assumes each file given in it is a standalone
test file, which #includes the C file with the same stem
(i.e. `foo_test.c` contains `#include "foo.c"`) and wants to be linked
with all source files that don't have the same stem as something in
`$(PROJ)`.  I know it's a bit of a hack, but it's pretty easy.

You can define `NO_WERROR` to any value you like, and the make system
will stop treating warnings as errors.

`INCLUDENAMES` and `LIBNAMES` are meant for standard library and
header arguments, e.g. `-I../../mylib -I/usr/local/foo` and `-lfoo
-lbar` become `INCLUDENAMES = ../../mylib /usr/local/foo` and
`LIBNAMES = foo bar`.

`LIBDIRS` does the same thing as `INCLUDENAMES` but with `-L` instead
of `-I`.

`OTHERINCLUDE` and `OTHERLIB` are just passed directly to the
compiler.

The `USERxFLAGS` variables let you pass in flags directly to the
compiler if you want.  I think the names are self-explanatory, except
`USERFLAGS` gets passed to the C compiler, the C++ compiler and
whatever gets called for linking (C compiler by default, unless there
are C++ source files found).

`CXX_EXT` can be used to change the file extension for C++ files.  The
Google standard is `.cc`, but a lot of people use `.cpp`, and I've
also seen `.C` for some reason.

I think most of the features should work fine with the `-j` flag for
parallel builds.

If you have only one thing defined in `$(PROJ)`, then `make shared`
and `make static` will build libraries linking all the object files
EXCEPT for the one with the same stem as `$(PROJ)`.  It's assumed that
this is your main program driver, so all the functionality you'd
export is contained in the other modules.

Features
------------

- Requires almost no work to start using it for basic projects
- Should work for both C and C++.
- Includes recommended warnings and security flags
- Includes commented out development flags, such as for profiling or
  mudflap checking
- Generates nice assembly listings
- Easy integration of external linters (`splint`, `cpplint.py`)
- Emacs flymake-mode integration
- Handy debug mode -- `make debug-OBJ` to learn about `$(OBJ)`
- Well documented, including `make help`
- Permissive license (Public Domain / WTFPL / BSD)
- AVR support
- Multiple targets

Misfeatures and Bugs
------------

- C++ vs. C detection is entirely based on the file extension, which
  is perhaps a bad idea.
- Multiple target support is entirely based on matching file names,
  which is perhaps a bad idea.
- Test support is mostly based on matching filenames too.
- Multiple architecture support is a bit hacky and doesn't work for
  tests.
- Multiple library targets don't really do the reasonable thing.
- Not so portable.

Coming Soon
------------
- Install and uninstall targets for libraries
- Better cross-compile support (ARM Cortex M{3,4} and A{8,9,15}
- Support for literate programming/documentation build
- Clang/BSD/OS X portability
- Correct dependency tracking
- Temporary directories for dependencies, objects and assembly listings
- Easy addition of custom code generation stages
