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
13. GAP for OS X
14. Expert Windows Installation

These are the installation instructions for the GAP source distribution
on Unix (which covers Linux and OS X), and for the GAP binary distribution
for Windows.

Alternative installation methods which aim to simplify the installation
mostly by offering precompiled binaries are:

* GAP installer for Homebrew (package manager for OS X)
* BOB - a tool to download and build GAP and its packages from source
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

Installing the GAP distribution with all the packages and full data
libraries takes about 1.6 GB of disk space and (except on Windows) will
require a C compiler (gcc is recommended) to be installed on your system.
To get maximum benefit from GAP and from various packages, we recommend
that in addition a C++ compiler is available, and it may be useful
to install a number of other free software libraries (and their associated
development tools) although they are not required for basic operation. See
<https://www.gap-system.org/Download/tools.html> for more details.

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

You can get archives for the GAP distribution from the GAP website
<https://www.gap-system.org>. You need to download one of the archives
named in the format

	gap4rXpY_<timestamp>.<archive_type>

for GAP 4.X.Y. The `<timestamp>` is updated whenever there is a change
to the GAP system or any package.

If you use Unix (including OS X), you can use the `.tar.gz`, `.tar.bz2` or
`.zip` archives containing the GAP source distribution. Such archives will
unpack into a directory named `gap4rX`.

If you use Windows, then use the `.exe` installer which contains binaries
for GAP and some packages and provides the standard installation procedure.


3 Unpacking
===========

The exact method of unpacking will vary dependently on the operating system
and the type of archive used.

Unix (including OS X)
---------------------

Under Unix style operating systems (such as Linux and OS X), unpack the
archive `gap4rXpY_<timestamp>` in whatever place you want GAP to reside.

(If you unpack the archive as root user under Unix, make sure that you
issue the command `umask 022` before, to ensure that users will have
permissions to read the files.)

Windows
-------

If you are using the `.exe` installer, simply download and run it. It will
offer a standard installation procedure, during which you will be able to
select installation path.

Note that the path to the GAP directory should not contain spaces.
For example, you may install it in a directory named like `C:\gap4rX`
(default), `D:\gap4rXpY` or `C:\Math\GAP\gap4rX`, but you must not install
it in a directory named like `C:\Users\alice\My Documents\gap4rX` or
`C:\Program files\gap4rX` etc.


4 Compilation
=============

For the Windows version the unpacking process will already have put
binaries in place. Under Unix you will have to compile such a binary
yourself. (OS X users: please see section "GAP for OS X" below for
additional information about compilation)

Change to the directory `gap4rX` (which you just created by unpacking).
To get started quickly you may simply build GAP with default settings
by issuing the two commands

    ./configure
    make

(note that on BSD systems you have to call `gmake` instead of `make`).

Both will produce a lot of text output. You should end up with a shell
script `bin/gap.sh` which you can use to start GAP. If you want, you can
copy this script later to a directory that is listed in your search path.

OS X users please note that this script must be started from within the
Terminal Application. It is not possible to start GAP by clicking this
script.

If you get strange error messages from these commands, make sure that you
got the Unix version of GAP (i.e. not the `-win.zip` format archive) and that
you extracted the archive on the same machine on which you compile. See
also the section "Known Problems of the Configure Process" below.


5 Configure options
===================

There are several options to the build process which you can specify at the
configure step. The following paragraphs describe these options; a brief
description of each is also available via

    ./configure --help

GMP
---

GAP 4 uses the external library GMP (see <http://www.gmplib.org>) for large
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
in `PREFIX/includes`, and the library itself in `PREFIX/lib`.

For historical reasons, you may also pass `--with-gmp=system`, which is
simply ignored by GAP (i.e., the default behavior described above is used).

Readline
--------

GAP optionally also uses the external library GNU Readline (see
<http://www.gnu.org/software/readline>) for better command line
editing. GAP will use this library by default if it is available on
your system. You can configure Readline use as follows:

    ./configure --with-readline=yes|no|"path"

If the argument you supply is `yes`, then GAP will look in standard locations
for a Readline installed on your system. Or you can specify a path to a
Readline installation. If the supplied argument is `no` then readline support
will not be used.

Note that `--with-readline` is equivalent to `--with-readline=yes` and
`--without-readline` is equivalent to `--with-readline=no`.

There was an annoying bug in the readline library on OS X which made
pasting text very slow. If you have that version of the readline library,
this delay be avoided by pressing a key (e.g. space) during the paste, or
you may prefer to build GAP without readline to avoid this issue entirely.

Build 32-bit vs. 64-bit binaries
--------------------------------

GAP will attempt to build in 32-bit mode on 32-bit machines and in 64-bit
mode on 64-bit machines. On a 64-bit machine, you can tell GAP to build in
32-bit instead, if you wish. In that case, GMP will also be built in 32-bit
mode. You can configure the build mode as follows:

    ./configure ABI=32

or

    ./configure ABI=64


The value of the argument determines the build mode GAP will attempt to
use. Note that building in 64-bit mode on a 32-bit architecture is not
supported.

It is possible (on a 64-bit machine) to have builds in both 32- and 64-bit
modes using "out of tree builds". For details, please refer to the file
`README.buildsys.md`.


6 Testing the installation
==========================

You are now at a point where you can start GAP for the first time. Unix
users (including those on OS X) should type

    ./bin/gap.sh

Windows users should start GAP with the batch file

    C:\gap4rX\bin\gap.bat

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
to have installed only the binary (or used the wrong path on Windows).

If GAP starts but you get error messages for the commands you issued, the
files in the `lib` directory are likely to be corrupt or incomplete. Make
sure that you used the proper archive and that extraction proceeded without
errors.

Especially try the command line editing and history facilities, because
they are probably the most machine dependent feature of GAP. Enter a few
commands and then make sure that `Ctrl-P` redisplays the last command, that
`Ctrl-E` moves the cursor to the end of the line, that `Ctrl-B` moves the
cursor back one character, and that `Ctrl-D` deletes single characters. So,
after entering the above commands, typing

    Ctrl-P  Ctrl-E  Ctrl-B  Ctrl-B  Ctrl-B  Ctrl-B  Ctrl-D  2  Return

should give the following lines:

    gap> Factors( 10^42 + 2 );
    [ 2, 3, 433, 953, 128400049, 3145594690908701990242740067 ]

If you want to run a quick test of your GAP installation (though this is
not required), you can read in a test script that exercises some GAP's
capabilities. The test requires about 1 GB of memory and should run in
under a minute on an up-to-date desktop computer. You will get a large
number of lines with output about the progress of the tests, for example:

    gap> Read( Filename( DirectoriesLibrary( "tst" ), "testinstall.g" ) );
    You should start GAP4 using `gap -A -x 80 -r -m 100m -o 1g -K 2g'.

    Architecture: SOMETHING-SOMETHING-gcc-default64

    testing: ..../gap4rX/tst/testinstall/alghom.tst
         105 msec for alghom.tst
    testing: ..../gap4rX/tst/testinstall/algmat.tst
        1216 msec for algmat.tst
    [ further lines deleted ]
    testing: ..../gap4rX/tst/testinstall/zmodnze.tst
          90 msec for zmodnze.tst
    -----------------------------------
    total     52070 msec

    #I  No errors detected while testing

GAP will exit after this test with the corresponding exit code (this is
useful for automated testing). If you want to run a more advanced check
(this is not required and may take up to an hour), you can start a new
GAP session and read `teststandard.g` which is an extended test script
performing all tests from the `tst` directory.

    gap> Read( Filename( DirectoriesLibrary( "tst" ), "teststandard.g" ) );

The test requires about 1 GB of memory and runs about one hour on an
Intel Core 2 Duo / 2.53 GHz machine, and produces an output similar to the
`testinstall.g` test.

Windows users should note that the Command Prompt user interface provided
by Microsoft might not offer history scrolling or cut and paste with the
mouse. To get a better environment, use scripts `gap.bat` or `gaprxvt.bat`
to start GAP instead of `gapcmd.bat`.


7 Packages
==========

The GAP distribution already contains all the GAP packages which we
redistribute in the `gap4rX/pkg` directory, and for packages that consist
only of GAP code no further installation is necessary.

Some packages however contain external binaries that will require separate
compilation. (If you use Windows you may not be able to use external
binaries anyhow, except for those packages whose binaries for Windows are
included in their distribution, so you may skip the rest of this section.)
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
compilation on Unix systems (including Linux and OS X) with sufficiently
many libraries, headers and tools available. To use it, change to the
`gap4rX/pkg` directory and execute the script like this:

    ../bin/BuildPackages.sh

If you have problems with package installations please contact the package
authors as listed in the packages README file. Many GAP packages have their
own development repositories and issue trackers, details of which could be
found at <https://gap-packages.github.io/>.


8 Finish Installation and Cleanup
=================================

Congratulations, your installation is finished.

Once the installation is complete, we would like to ask you to send us a
short note to <support@gap-system.org>, telling us about the installation.
(This is just a courtesy; we like to know how many people are using GAP and
get feedback regarding difficulties (hopefully none) that users may have
had with installation.)

We also suggest that you subscribe to our GAP Forum mailing list; see the
GAP web pages for details. Whenever there is a bug fix or new release of
GAP this is where it is announced. The GAP Forum also deals with user
questions of a general nature; bug reports and other problems you have
while installing and/or using GAP should be sent to <support@gap-system.org>.

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

The manual is also available in pdf format. In the full distribution these
files are included in the directory `gap4rX/doc` in the subdirectories
`tut` (a beginner's tutorial), `ref` (the reference manual) and `changes`
(changes from earlier versions).

If you want to use these manual files with the help system from your GAP
session you may check (or make sure) that your system provides some
additional software like [xpdf](http://www.foolabs.com/xpdf/) or
[acroread](http://www.adobe.com/products/acrobat/readstep.html).

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

You either started only the binary or did not edit the shell script/batch
file to give the correct library path. You must start the binary with the
command line option

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
extending the workspace is impossible. Start GAP with more memory or use
the `-a` option to pre-allocate initially a large piece of workspace.

### GAP is not able to allocate memory above a certain limit

In a 32-bit mode GAP is unable to use over 4 GB of memory. In fact, since
some address space is needed for system purposes, it is likely that GAP
sessions will be limited to 3 GB or even less.

Depending on the operating system, it also might be necessary to compile
the GAP binary statically (i.e. to include all system libraries) to avoid
collisions with system libraries located by default at an address within
the workspace. (Under Linux for example, 1 GB is a typical limit.) You can
compile a static binary using make static.

### Recompilation fails or the new binary crashes.

Call make clean and restart the configure / make process completely from
scratch. (It is possible that the operating system and/or compiler got
upgraded in the meantime and so the existing .o files cannot be used any
longer.

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

Problems specific to Windows

### The ^-key or "-key cannot be entered.

This is a problem if you are running a keyboard driver for some non-english
languages. These drivers catch the ^ character to produce the French
circumflex accent and do not pass it properly to GAP. No fix is known. (One
can type POW(a,b) for a^b.)

### Cut and Paste does not work

You might want to try different shells, starting each of the three .bat
files in the `bin` directory: `gap.bat`. `gaprxvt.bat` and `gapcmd.bat`.
Also, <https://www.gap-system.org/Faq/faq.html#4> might give a remedy.

### GAP does not work in the remote desktop

GAP can not be started in the Windows Command Prompt shell (via `gapcmd.bat`)
in the remote desktop. To start GAP in the remote desktop, use scripts
`gap.bat` or `gaprxvt.bat` which should work in such setting.

### You get an error message about the `cygwin1.dll`

GAP comes with a version of this dynamic library. If you have another
version installed (use "Find"), delete the older one (and probably copy the
newer one in both places).

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
that might affect the compilation (in particular `CC`, `LD`, `CFLAGS`,
`LDFLAGS` and `CPPFLAGS`) are set and reset them using `unsetenv`.


12 Optimization and Compiler Options
====================================

Because of the large variety of different versions of Unix and different
compilers it is possible that the configure process will not chose best
possible optimisation level, but you might need to tell make about it.

If you want to compile GAP with further compiler options (for example
specific processor optimisations) you will have to assign them to the
variables CFLAGS, CPPFLAGS and LDFLAGS, then re-run configure and make.

If there are several compiler options or if they contain spaces you might
have to enclose them by quotes depending on the shell you are
using.

The configure process also introduces some default compiler options. You can
eliminate these by assigning the replacement options to the variable `CFLAGS`.

The recommended C compiler for GAP is the GNU C compiler gcc. The clang
compiler appears to compile GAP correctly but, just as for gcc, some
versions have problems with the GMP library. If you cannot build GAP -
with or without GMP - using a particular compiler, you may wish to try
another compiler or different version of the same compiler.

If you do wish to use another compiler, you should run the command
`make clean` in the GAP root directory, set the environment variable `CC` to
the name of your preferred compiler and then rerun configure and make.

We also recommend that you install a C++ compiler before compiling GAP;
while GAP itself does not need it, there are GAP packages which do
require a C++ compiler.


13 GAP for OS X
===============

Currently we provide no precompiler binary distribution for OS X. However,
since OS X is an operating system in the Unix family, you can follow the
Unix installation guidelines to compile GAP; then you will be able to use
all features of GAP as well as all packages. However for installation you
might need a basic knowledge of Unix.

The following are a couple of notes and remarks about this:

First, note that you should get the Unix type GAP archives, i.e. one of
`.zip`, `.tar.gz` or `.tar.bz2` archives, but not the `-win.zip` archive
(you won't be able to compile the program as given in the `-win.zip` archive).

Next, you will need a compiler and build tools like `make`. These tools are
included in the "Xcode" application which is not installed by default on a
new Mac. On all recent versions of OS X, you can install it for free via
the App Store. For older versions for OS X, you may need to register with
Apple as a developer and download it from <http://developer.apple.com>.

To compile and run GAP you will have to open the Terminal application and
type the necessary Unix commands into its window. The Terminal application
can be found in the Utilities folder in the Applications folder.
Now simply follow the Unix installation instructions to compile and start
GAP and then it will run in this Terminal window.


14 Expert Windows Installation
==============================

Instead of using the `.exe` installer, you may use the `-win.zip archive`,
which you may unpack with an appropriate extractor. The content of the
latter archive is identical to the content of the former one, except that
there is no installation procedure and you may have to edit the `*.bat`
files yourself.

The `-win.zip archive` already contains `*.bat` files which will work if GAP
is installed in the standard location, which is `C:\gap4rX`. To install GAP
there, the archive must be extracted to the main directory of the `C:` drive.
(If you do not have permissions or sufficient free space to create directories
there, see the section "Expert Windows Installation" below). Make sure that
you specify extraction to the `C:\` folder (with no extra directory name --
the directory `gap4rX` is part of the archive) to avoid extraction
in a wrong place or in a separate directory.

After extraction you can start GAP with one of the following files:

    C:\gap4rX\bin\gap.bat       (recommended)
    C:\gap4rX\bin\gaprxvt.bat
    C:\gap4rX\bin\gapcmd.bat

The `gap.bat` file will start GAP in the `mintty` shell. It allows for
convenient copying and pasting (e.g. using mouse) and flexible customisation.
Using its "Options" menu, accessible by the right-click on the pictogram in
its top left corner, you may adjust the font and colour scheme as you prefer.
Note that `gap.bat` will open two windows - one actually running GAP and an
auxiliary one, which may be minimised but should not be closed (otherwise the
GAP session will be terminated).

If you need to install GAP in a non-standard directory under Windows, we advice
to use the Windows `.exe` installers which will adjust all paths in batch files
during the installation. Whenever you use a Windows installer or install GAP f
rom the `-win.zip` archive, you should avoid paths with spaces, e.g. do not use
`C:\My Programs\gap4rX`. If you need to install GAP on another logical drive,
say `E:`, the easiest way would be just to use `E:\gap4rX`.

If you need to edit a `*.bat` file to specify the path to your GAP installation
manually, you will have to replace substrings `/c/gap4rX/` by the actual path
to the GAP root directory in the Unix format, and substrings `C:\gap4rX\` by
the actual path to the GAP root directory in the Windows format. Please avoid
introducing new line breaks when editing (i.e. do not use a text editor which
automatically wraps long lines).

Please contact <support@gap-system.org> if you need further information.


Wishing you fun and success using GAP,

The GAP Group
