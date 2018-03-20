[![Build Status](https://travis-ci.org/gap-system/gap.svg?branch=master)](https://travis-ci.org/gap-system/gap) [![Code Coverage](https://codecov.io/github/gap-system/gap/coverage.svg?branch=master&token=)](https://codecov.io/gh/gap-system/gap)

# What is GAP?

GAP is a system for computational discrete algebra, with particular emphasis on
computational group theory. GAP provides a programming language, a library of
thousands of functions implementing algebraic algorithms written in the GAP
language as well as large data libraries of algebraic objects. See also the
[overview](https://www.gap-system.org/Overview/overview.html) and the description of
the [mathematical capabilities](https://www.gap-system.org/Overview/Capabilities/capabilities.html).

GAP is used in research and teaching for studying groups and their representations,
rings, vector spaces, algebras, combinatorial structures, and more.
The system, including source, is distributed freely. You can study and easily
modify or extend it for your special use.


# How to obtain GAP?

## Download a stable release version

The latest stable release of the GAP system together with all currently redistributed
[GAP packages](https://www.gap-system.org/Packages/packages.html) can be obtained from our
[downloads page](https://www.gap-system.org/Releases/index.html).
For installation instructions see [here](https://www.gap-system.org/Download/install.html).

Afterwards, follow the instructions in the file `INSTALL.md` in the GAP rot directory.


# Using a GAP development version

Alternatively, you can compile the latest development version of GAP. However, most
users should instead use the latest official release instead.

If you want to do so, you can clone the GAP source repository using git:

    git clone https://github.com/gap-system/gap


## Installing required dependencies

In this case, you need to have some more software dependencies installed than
with a stable release in order to compiler GAP. In particular, you need at
least these:

* a C compiler, e.g. GCC or Clang
* GNU Make
* GNU Autoconf (we recommend 2.69 or later)
* GNU Libtool
* Development headers for GMP, the GNU Multiple Precision Arithmetic Library
* optional: Development headers for GNU Readline

On Ubuntu or Debian, you can install these with the following command:

    sudo apt install build-essential autoconf libtool libgmp-dev libreadline-dev

On OS X, you can install the dependencies in several ways:

 * using Homebrew: `brew install autoconf libtool gmp readline`
 * using Fink: `fink install autoconf2.6 libtool2 gmp5 readline7`
 * using MacPorts: `port install autoconf libtool gmp readline`

On other operating systems, you will need to figure out equivalent commands
to install the required dependencies.


## Building GAP

Then to build GAP, first run this command to generate the `configure` script:

    ./autogen.sh

Afterwards you can proceed similar to what is described in `INSTALL.md`, in
particular enter the following commands to compile GAP itself (for OS X users,
see below for a few additional hints):

    ./configure
    make

For OS X users you may ned to tell GAP where it can find these dependencies.

For Homebrew, use these commands:

    ./configure --with-readline=/usr/local/opt/readline
    make

For Fink, use these commands:

    ./configure CPPFLAGS=-I/sw/include LDFLAGS=-L/sw/lib
    make

For MacPorts, use these commands:

    ./configure CPPFLAGS=-I/opt/local/include LDFLAGS=-L/opt/local/lib
    make


## Obtaining the GAP package distribution

In contrast to the GAP stable releases, the development version does not come
bundled with all the GAP packages. Therefore, if you do not have a GAP package
archive yet, we recommend that you bootstrap the stable versions of packages
by executing one of the following commands. Whether you choose to
`bootstrap-pkg-minimal` or `bootstrap-pkg-full` depends on your needs for
development.

    make bootstrap-pkg-minimal

or

    make bootstrap-pkg-full

In the latter case please note that `make bootstrap-pkg-full` only unpacks packages
but does not build those of them that require compilation. You can change to the
`pkg` directory and then call `../bin/BuildPackages.sh` from there to build as many
packages as possible.

If everything goes well, you should be able to start GAP by executing

    sh bin/gap.sh

You can also find development versions of some of the GAP packages on
<https://github.com/gap-packages> resp. on <http://gap-packages.github.io>.


# We welcome contributions

The GAP Project welcomes contributions from everyone, in the shape of code,
documentation, blog posts, or other. For contributions to this repository,
please read the [guidelines](CONTRIBUTING.md).

To keep up to date on GAP news (discussion of problems, release announcements,
bug fixes), you can subscribe to the
[GAP forum](https://www.gap-system.org/Contacts/Forum/forum.html) and
[GAP development](https://mail.gap-system.org/mailman/listinfo/gap) mailing lists,
notifications on GitHub, and follow us on [Twitter](https://twitter.com/gap_system).

If you have any questions about working with GAP, you can ask them on
[GAP forum](https://www.gap-system.org/Contacts/Forum/forum.html) (requires subscription)
or [GAP Support](https://www.gap-system.org/Contacts/People/supportgroup.html) mailing lists.

Please tell us about your use of GAP in research or teaching. We maintain a
[bibliography of publications citing GAP](https://www.gap-system.org/Doc/Bib/bib.html).
Please [help us](https://www.gap-system.org/Contacts/publicationfeedback.html)
keeping it up to date.


# License

GAP is free software; you can redistribute it and/or modify it under the terms
of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version. For details, please refer to the GAP reference manual, as well as the
file `LICENSE` in the root directory of the GAP distribution or see
<http://www.gnu.org/licenses/gpl.html>.
