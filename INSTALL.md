GAP INSTALLATION INSTRUCTIONS
=============================

1. Installation Overview
2. Getting the Archive
3. Unpacking
4. Compilation
5. Configure options
6. Testing the installation
7. Packages
8. Finish Installation and Cleanup
9. The Documentation
10. If Things Go Wrong
11. Known Problems of the Configure Process
12. Optimisation and Compiler Options
13. GAP for macOS

These are the installation instructions for the GAP source distribution
on Unix (which covers Linux and macOS), and for the GAP binary distribution
for Windows.

Alternative installation methods which aim to simplify the installation
mostly by offering precompiled binaries are:

* GAP installer for Homebrew (package manager for macOS)
* Docker image for GAP and most of the packages
* the rsync-based binary distribution for Linux

Note, however, that these are updated independently and may not yet provide
the latest GAP release. Further details are available on the GAP website
here: <https://www.gap-system.org/Download/alternatives.html>.


1 Installation Overview
=======================

The GAP source distribution is designed to be installed in a similar
way on a wide range of operating systems and to allow for considerable
customisation of the installation to meet specific system needs. As a
result, it may differ from what you would expect under your particular
operating system. In particular, it does not include an automatic installer
program.

Installing the GAP distribution with all the packages and full data libraries
will require (except on Windows) both a C and a C++ compiler (gcc or clang
is recommended) to be installed on your system. Please also consult
section "Installing required dependencies" in the file `README.md`.

To get maximum benefit from GAP and from various packages, we recommend
to install a number of other free software libraries (and their associated
development tools) although they are not required for basic operation.
See <https://www.gap-system.org/Download/tools.html> for more details.

The installation consists of five easy steps:

1. Get the archive suitable for your system
2. Unpack the archive in the directory where you wish to install GAP
   If you are reading this file as part of a GAP installation, you have
   probably already done this.
3. Compile the kernel (unless a binary has been provided already)
4. Test the installation
5. Compile the packages that require it.
   (some of them will only work under Unix).

Installation will always install the new version of GAP. If you are
worried about losing the old version, you can keep an existing installation
of GAP in another directory, it will not be overwritten. Make sure, however,
to adjust any links or scripts so that you run the latest version.

Section "The Documentation" below contains information about the manual,
where to find and how to print it. Section "If Things Go Wrong" below lists
common problems with the installation.


2 Getting the Archive
=====================

You can get archives for the GAP distribution from the GAP website at
<https://www.gap-system.org/Releases/>. If you use Unix (including macOS),
you need to download the GAP source distribution, that is, a file named

    gap-4.X.Y.tar.bz2

for GAP 4.X.Y. Alternatively, you can also use the `.tar.gz` or `.zip`
archives.

If you use Windows, then download the Windows installer which contains binaries
for GAP and some packages and provides the standard installation procedure.


3 Unpacking
===========

The exact method of unpacking will vary dependently on the operating system
and the type of archive used.

Unix (including macOS)
----------------------

Under Unix style operating systems (such as Linux and macOS), unpack the
archive `gap-4.X.Y.tar.bz2` in whatever place you want GAP to reside.
It will expand into a directory named `gap-4.X.Y`.

(If you unpack the archive as root user under Unix, make sure that you
issue the command `umask 022` before, to ensure that users will have
permissions to read the files.)

Windows
-------

If you are using the Windows installer, simply download and run it.
It will offer a standard installation procedure, during which you will
be able to select an installation path. You can either install for all
users, or just the current user.


4 Compilation
=============

For the Windows version the installer will already have put
binaries in place and nothing else needs to be done.

Under Unix you will have to compile such a binary yourself as described
in this section. This also covers macOS, but please first review section
"GAP for macOS" below for additional information about compilation
specific to macOS.

Prerequisites
-------------

In order to compile GAP, you need at least these:

* a C compiler, e.g. GCC or Clang
* a C++ compiler
* GNU Make

In addition, we recommend that you install at least the following optional
dependencies (if you do not, GAP will either build its own copies of these,
slowing down the compilation process, or omit certain features):
* Development headers for GMP, the GNU Multiple Precision Arithmetic Library
* Development headers for zlib
* Development headers for GNU Readline

On Ubuntu or Debian, you can install these with the following command:

    sudo apt-get install build-essential autoconf libgmp-dev libreadline-dev zlib1g-dev

On Fedora:

    sudo dnf install gcc gcc-c++ make autoconf gmp gmp-devel readline readline-devel zlib zlib-devel

On Alpine:

    sudo apk add build-base autoconf gmp-dev readline-dev zlib-dev

On macOS, please follow the instructions in section "GAP for macOS" below.

On other operating systems, you will need to figure out equivalent commands
to install the required dependencies.

Note that several of the packages bundled with GAP have additional
prerequisites. Here is an incomplete list of GAP packages and their requirements
(excluding GMP, which many packages require):

- 4ti2Interface
  - Debian/Ubuntu: 4ti2
  - Homebrew: (not currently available)
- alnuth
  - Debian/Ubuntu: pari-gp
  - Homebrew: pari
- browse
  - Debian/Ubuntu: libncurses-dev
  - Homebrew: ncurses
- CddInterface
  - Debian/Ubuntu: libcdd-dev
  - Homebrew: cddlib
- curlInterface
  - Debian/Ubuntu: libcurl4-openssl-dev
  - Homebrew: curl
- float
  - Debian/Ubuntu: libfplll-dev libmpc-dev libmpfi-dev libmpfr-dev
  - Homebrew: fplll libmpc mpfi mpfr
- singular
  - Debian/Ubuntu: singular
  - Homebrew: singular
- ZeroMQInterface
  - Debian/Ubuntu: libzmq3-dev
  - Homebrew: zmq


Compilation
-----------

Change to the directory `gap-4.X.Y` (which you just created by unpacking).
To get started quickly you may simply build GAP with default settings
by issuing the two commands

    ./configure
    make

(note that on BSD systems you have to call `gmake` instead of `make`).

Both will produce a lot of text output. You should end up with an executable
called `gap` which you can use to start GAP. You can create a symbolic link
to it in a directory that is listed in your `PATH` environment variable.

macOS users please note that this script must be started from within the
Terminal Application. It is not possible to start GAP by clicking this
script.

If you get strange error messages from these commands, make sure that
you extracted the archive on the same machine on which you compile. See
also the section "Known Problems of the Configure Process" below.

Note that starting with GAP 4.12, there is experimental support for installing
GAP via `make install`. By default this attempts to install GAP into the
`/usr` prefix, but this can be adjusted via the `--prefix` option for
`configure`. This feature is still quite new and has not received extensive
testing yet, and we mainly recommend it for use by people who wish to package
GAP for a Linux distribution or similar. Note also that `make install` at this
time only installs GAP itself; GAP packages still must be installed manually
(which in many cases just means copying them into a suitable directory, e.g.
`<GAPPREFIX>/share/gap/pkg/` -- we are still working on a good solution for
packages that require compilation).


5 Configure options
===================

There are several options to the build process which you can specify at the
configure step. The following paragraphs describe these options; a brief
description of each is also available via

    ./configure --help

GMP
---

GAP 4 uses the external library GMP (see <https://gmplib.org>) for large
integer arithmetic, replacing the built-in code used in previous versions
and achieving a significant speed-up in related computations. There is a
version of GMP included with the GAP archive you downloaded and this will
be used if GAP does not find a version of GMP already installed on your
system. You can configure which GMP GAP uses as follows:

    ./configure --with-gmp=builtin|PREFIX

If this option is *not* given, GAP will try to find a suitable version of GMP
can be found using the specified CPPFLAGS, CFLAGS and LDFLAGS. If not,
it will fallback to compiling its own version of GMP.

You can force GAP to build its own copy of GMP by passing `--with-gmp=builtin`.
Finally, you pass a prefix path where GAP should search for a copy of GMP;
i.e., `--with-gmp=PREFIX` instructs GAP to search for the header file `gmp.h`
in `PREFIX/include`, and the library itself in `PREFIX/lib`.

For historical reasons, you may also pass `--with-gmp=system`, which is
simply ignored by GAP (i.e., the default behavior described above is used).

Readline
--------

GAP optionally also uses the external library GNU Readline (see
<https://www.gnu.org/software/readline>) for better command line
editing. GAP will use this library by default if it is available on
your system. You can specify whether to use GNU Readline or not
and possibly select an alternate version as follows:

    ./configure --with-readline=yes|no|"path"

If the argument you supply is `yes`, then GAP will look in standard locations
for a Readline installed on your system. Or you can specify a path to a
Readline installation. If the supplied argument is `no` then readline support
will not be used.

Note that `--with-readline` is equivalent to `--with-readline=yes` and
`--without-readline` is equivalent to `--with-readline=no`.

Build 32-bit vs. 64-bit binaries
--------------------------------

GAP will attempt to build in 32-bit mode on 32-bit machines and in 64-bit
mode on 64-bit machines. On a 64-bit machine, you can tell GAP to build in
32-bit instead, if you know what you are doing. Note that we recommend
*against* doing this for regular use, as these days the 64 bit version is
much better tested and generally faster.

If you wish to force GAP in 32-bit mode, you can do so by invoking

    ./configure ABI=32
    make

The value of the argument determines the build mode GAP will attempt to
use. Note that building in 64-bit mode on a 32-bit architecture is not
supported.

It is possible (on a 64-bit machine) to have builds in both 32- and 64-bit
modes using "out of tree builds". For details, please refer to the file
`README.buildsys.md`.


6 Testing the installation
==========================

You are now at a point where you can start GAP for the first time. Unix
users (including those on macOS) should type

    ./gap

Windows users should start GAP using the GAP icon in the start menu.

GAP should start up with its banner and after a little while give you a
command prompt

    gap>

Try a few commands to see if the compilation succeeded.

    gap> 2 * 3 + 4;
    10
    gap> Factorial( 30 );
    265252859812191058636308480000000
    gap> m11 := Group((1,2,3,4,5,6,7,8,9,10,11),(3,7,11,8)(4,10,5,6));;
    gap> Size( m11 );
    7920
    gap> Length( ConjugacyClasses( m11 ) );
    10
    gap> Factors( 10^42 + 1 );
    [ 29, 101, 281, 9901, 226549, 121499449, 4458192223320340849 ]

If you get the error message `hmm, I cannot find lib/init.g` you are likely
to have installed only the binary (or have a broken installation on Windows).

If GAP starts but you get error messages for the commands you issued, the
files in the `lib` directory are likely to be corrupt or incomplete. Make
sure that you used the proper archive and that extraction proceeded without
errors.

If you want to run a quick test of your GAP installation (though this is
not required), you can read in a test script that exercises some GAP's
capabilities. To run this test, we recommend to use a computer with at
least 1 GB of memory; on an up-to-date desktop computer, it should
complete in about a minute. You will get a large number of lines with
output about the progress of the tests, for example:

    gap> Read( Filename( DirectoriesLibrary( "tst" ), "testinstall.g" ) );
    Architecture: SOMETHING-SOMETHING-gcc-default64

    testing: ..../gap-4.X.Y/tst/testinstall/alghom.tst
          84 ms (55 ms GC) and 2.90MB allocated for alghom.tst
    testing: ..../gap-4.X.Y/tst/testinstall/algmat.tst
         839 ms (114 ms GC) and 219MB allocated for algmat.tst
    [ further lines deleted ]
    testing: ..../gap-4.X.Y/tst/testinstall/zmodnze.tst
         127 ms (119 ms GC) and 1.29MB allocated for zmodnze.tst
    -----------------------------------
    total     62829 ms (24136 ms GC) and 8.61GB allocated
                  0 failures in 252 files

    #I  No errors detected while testing

GAP will exit after this test with the corresponding exit code (this is
useful for automated testing). If you want to run a more advanced check
(this is not required and may take up to an hour), you can start a new
GAP session and read `teststandard.g` which is an extended test script
performing all tests from the `tst` directory.

    gap> Read( Filename( DirectoriesLibrary( "tst" ), "teststandard.g" ) );

It takes significantly longer to complete than `testinstall.g`,
but otherwise produces output similar to the `testinstall.g` test.


7 Packages
==========

The GAP distribution already contains all the GAP packages which we
redistribute in the `gap-4.X.Y/pkg` directory, and for packages that consist
only of GAP code no further installation is necessary.

Some packages however contain external binaries that will require separate
compilation. (If you use the Windows installer these binaries are already
compiled for you, so you may skip the rest of this section.)
You can skip this compilation now and do it later -- GAP will work fine,
but the capabilities of the affected packages won't be available.

In general, each package contains a `README` file that contains information
about the package and the necessary installation. Typically, for a package
that requires compilation, the installation steps consist of changing to
the packages directory and issuing the commands `./configure && make` in
the packages directory. This has to be done separately for every package,
and their `README` files should tell exactly which commands to use.

To help with this tedious process, we ship a shell script called
`bin/BuildPackages.sh` that will compile most of the packages that require
compilation on Unix systems (including Linux and macOS) with sufficiently
many libraries, headers and tools available. To use it, change to the
`gap-4.X.Y/pkg` directory and execute the script like this:

    ../bin/BuildPackages.sh

If you have problems with package installations please contact the package
authors as listed in the packages `README` file. Many GAP packages have their
own development repositories and issue trackers, details of which could be
found at <https://gap-packages.github.io/>.


8 Finish Installation and Cleanup
=================================

Congratulations, your installation is finished.

Once the installation is complete, you may wish to subscribe to the
[GAP forum mailing list](https://www.gap-system.org/Contacts/Forum/forum.html),
which provides help with user questions of a general nature. You can also
chat with us on [Slack](https://gap-system.org/slack). Bug reports and other
problems you have while installing and/or using GAP should be reported via
our [issue tracker](https://github.com/gap-system/gap/issues) or sent via
email to <support@gap-system.org>.

If you are new to GAP, you might want to read through the following two
sections for information about the documentation.


9 The Documentation
====================

The GAP documentation is distributed in various "books". The standard
distribution contains two of them. GAP packages (see Chapter "GAP Packages"
of the GAP Reference manual and, in particular, the Section "Loading a GAP
Package") provide their own documentation in their own `doc` directories.

All documentation will be available automatically within every GAP session
(see Section "Help" of the GAP Tutorial and Chapter "The Help System" in
the GAP Reference manual).

There also is (if installed) an HTML version of some books that can be
viewed with an HTML browser, see Section "Changing the Help Viewer" of the
GAP Reference manual.

The manual is also available in PDF format. In the full distribution these
files are included in the directory `gap-4.X.Y/doc` in the subdirectories
`tut` (a beginner's tutorial), `ref` (the reference manual), and `hpc` (HPC-GAP
reference manual).

If you want to use these manual files with the help system from your GAP
session you may check (or make sure) that your system provides some
additional software like [xpdf](https://www.foolabs.com/xpdf/) or
[acroread](https://www.adobe.com/products/acrobat/readstep.html).

To complete beginners, we suggest you read (parts of) the tutorial first
for an introduction to GAP 4. Then start to use the system with extensive
use of the help system (see Section "Help" of the GAP Tutorial and Chapter
"The Help System" in the GAP Reference manual).

As some of the manuals are quite large, you should not immediately print
them. If you start using GAP it can be helpful to print the tutorial (and
probably the first chapters of the reference manual). There is no
compelling reason to print the whole of the reference manual, better use
the help system which provides useful search features.


10 If Things Go Wrong
=====================

This section lists a few common problems when installing or running GAP and
their remedies. Also see the FAQ list on the GAP web pages at
<https://www.gap-system.org/Faq/faq.html>.

### GAP starts with a warning `hmm, I cannot find lib/init.g`

This means that GAP cannot find its library. That can happen if you copied or
moved the `gap` executable out of its original directory. You may be able
to fix this by passing it the command line option

    -l <path>

where `<path>` is the path to the GAP home directory (see Section "Command
Line Options" of the GAP Reference manual).

### When starting, GAP produces error messages about undefined variables.

You might have a `.gaprc` file in your home directory that was used by
GAP 4.4 but is not compatible with later releases. See section "The gap.ini
and gaprc files" in Section "Running GAP" of the GAP Reference manual.

### GAP stops with an error message `exceeded the permitted memory`.

Your job required more memory than is permitted by default (this is a
safety feature to avoid single jobs wrecking a multi-user system.) You can
type `return;` to continue, if the error message happens repeatedly it might
be better to start the job anew and use the command line option `-o` to set a
higher memory limit.

### GAP stops with an error message: `cannot extend the workspace any more`.

Your calculation exceeded the available memory. Most likely you asked GAP
to do something which required more memory than you have (as listing all
elements of S_15 for example). You can use the command line option `-g` (see
Section "Command Line Options" of the GAP Reference manual) to display how
much memory GAP uses. If this is below what your machine has available
extending the workspace is impossible. Start GAP with more memory using the
`-o` option.

### GAP is not able to allocate memory above a certain limit

In a 32-bit mode GAP is unable to use over 4 GB of memory. In fact, since
some address space is needed for system purposes, it is likely that GAP
sessions will be limited to 3 GB or even less. There are other factors
which can reduce this limit even further.

We therefore recommend to always build and use GAP in 64-bit mode.

### A calculation runs into an error `no method found`.

GAP is not able to execute a certain operation with the given arguments.
Besides the possibility of bugs in the library this means two things:
Either GAP truly is incapable of coping with this task (the objects might
be too complicated for the existing algorithms or there might be no
algorithm that can cope with the input). Another possibility is that GAP
does not know that the objects have certain nice properties (like being
finite) which are required for the available algorithms. See section
"ApplicableMethod" and "KnownPropertiesOfObject" of the GAP Reference
manual.

### The ^-key or "-key cannot be entered.

This is a problem if you are running a keyboard driver for some non-english
languages. These drivers catch the ^ character to produce the French circumflex
accent and do not pass it properly to GAP. For macOS users, as a workaround
please refer to the section "GAP for macOS" below for information on
how to install readline and section 5 on how to recompile GAP, for Windows no
fix is known. (One can type `POW(a,b)` for `a^b`.)

## Problems specific to Windows

Rather than use the Windows installer, another option is to use the
"Windows Subsystem for Linux" (<https://learn.microsoft.com/en-us/windows/wsl/install>),
also known as WSL. This can be found in the "Microsoft Store" in Windows,
where you will find installers for a selection of Linux distributions (Ubuntu
is the standard, and best supported). After installing a linux distribution you
can then follow the guidance for building and using GAP in Linux inside WSL.

The main advantage of using WSL is that the Windows installer does not support
adding new packages which require compiling kernel modules. Also, GAP is
slightly faster in WSL.

We also support building GAP using 'Cygwin', which is a Unix wrapper for
Windows. Cygwin is used for making Windows release. Almost all packages are
supported in the Windows releases. By default the Windows release reads and
writes files from the user's "Documents" directory.

### Something else went wrong

If all these remedies fail or you encountered a bug please send a mail to
<support@gap-system.org>. Please give:

* a (short, if possible) self-contained excerpt of a GAP session containing
  both input and output that illustrates your problem (including comments
  of why you think it is a bug); and
* state the type of machine, the operating system, which compiler you used
  (if any), and the version of GAP you are using (the line from the GAP
  banner starting with

        GAP, Version 4.X.Y...

  when GAP starts up, supplies the information required).


11 Known Problems of the Configure Process
==========================================

The configure script respects compiler settings given in environment
variables. However such settings may conflict with the automatic
configuration process. If configure produces strange error messages about
not being able to run the compiler, check whether environment variables
that might affect the compilation (in particular `CC`, `CXX`, `CPP`, `LD`,
`CFLAGS`, `CXXFLAGS`, `CPPFLAGS` and `LDFLAGS`) are set and reset them using
`unsetenv`.


12 Optimization and Compiler Options
====================================

Because of the large variety of different versions of Unix and different
compilers it is possible that the configure process will not chose best
possible optimisation level, but you might need to tell `make` about it.

If you want to compile GAP with further compiler options (for example
specific processor optimisations) you will have to assign them to the
variables `CFLAGS`, `CXXFLAGS`, `CPPFLAGS` and `LDFLAGS`, then re-run
`configure` and `make`.

If there are several compiler options or if they contain spaces you might
have to enclose them by quotes depending on the shell you are
using.

The configure process also introduces some default compiler options. You can
eliminate these by assigning the replacement options to the variable `CFLAGS`.

The recommended C/C++ compiler for GAP is the GNU C compiler gcc version 4.8
or later. The Clang compiler version 3.0 and later also should work fine.
If you use another compiler, please let us know your experience with using
it to compile GAP.

If you do wish to use GAP with a specific compiler, you can set the environment
variables `CC` resp. `CXX` to the name of your preferred C resp. C++ compiler
and then rerun `configure` and `make`.

As an example, here is how one can configure GAP to compile with Clang 5
(assuming it is installed on your system), with custom compiler flags and
debug mode enabled:

    ./configure CC=clang-5.0 CXX=clang++-5.0 CFLAGS="-g -Og" CXXFLAGS="-g -Og" --enable-debug


13 GAP for macOS
================

Currently we provide no precompiled binary distribution for macOS. However,
since macOS is an operating system in the Unix family, you can follow the
Unix installation guidelines to compile GAP; then you will be able to use
all features of GAP as well as all packages. However for installation you
might need a basic knowledge of Unix.

The following are a couple of notes and remarks about this:

To compile and run GAP you will have to open the Terminal application and
type the necessary Unix commands into its window. The Terminal application
can be found in the `Utilities` folder in the `Applications` folder.

Next, you will need a compiler and build tools like `make`. These tools are
included in the "Xcode" application which is not installed by default on a
new Mac. On all recent versions of macOS, you can install the required tools
by entering the following command into a terminal prompt (note that it will
show a graphical prompt asking for confirmation, and may also require you
to enter an administrator password).

     xcode-select --install

If you are using a macOS package manager, we recommend installing a few for
faster compilation and a better user experience:

 * using Homebrew: `brew install gmp readline`
 * using Fink: `fink install gmp readline7`
 * using MacPorts: `port install gmp readline`

Now simply follow the Unix installation instructions to compile and start
GAP and then it will run in this Terminal window.
