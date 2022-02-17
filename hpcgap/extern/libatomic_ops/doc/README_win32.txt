Most of the atomic_ops functionality is available under Win32 with
the Microsoft tools, but the build process is more primitive than that on
Linux/Unix platforms.

To build:
1) Go to the src directory in the distribution.
2) Make sure the Microsoft command-line tools (e.g. nmake) are available.
3) Run "nmake -f Makefile.msft check".  This should build libatomic_ops_gpl.lib
and run some tests.
4) To compile applications, you will need to retain or copy the following
pieces from the resulting src directory contents:
        "atomic_ops.h" - Header file defining low-level primitives.  This
                         includes files from the following folder.
        "atomic_ops"- Subdirectory containing implementation header files.
        "atomic_ops_stack.h" - Header file describing almost lock-free stack.
        "atomic_ops_malloc.h" - Header file describing almost lock-free malloc.
        "libatomic_ops_gpl.lib" - Library containing implementation of the
                        above two (plus AO_pause() defined in atomic_ops.c).
                        The atomic_ops.h implementation is entirely in the
                        header files in Win32.

If the client defines AO_ASSUME_VISTA (before include atomic_ops.h), it should
make double_compare_and_swap_full available.

Note that the library is covered by the GNU General Public License, while
the top 2 of these pieces allow use in proprietary code.
