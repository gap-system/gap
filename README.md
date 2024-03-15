[![Build Status](https://github.com/gap-system/gap/workflows/CI/badge.svg?branch=stable-4.13)](https://github.com/gap-system/gap/actions?query=workflow%3ACI+branch%3Astable-4.13)
[![Code Coverage](https://codecov.io/gh/gap-system/gap/branch/stable-4.13/graphs/badge.svg)](https://codecov.io/gh/gap-system/gap/branch/stable-4.13)
[![ref](https://img.shields.io/badge/docs-ref-blue)](https://gap-system.github.io/gap/doc/ref/chap0_mj.html)
[![dev](https://img.shields.io/badge/docs-dev-blue)](https://gap-system.github.io/gap/doc/dev/chap0_mj.html)
[![hpc](https://img.shields.io/badge/docs-hpc-blue)](https://gap-system.github.io/gap/doc/hpc/chap0_mj.html)
[![tut](https://img.shields.io/badge/docs-tut-blue)](https://gap-system.github.io/gap/doc/tut/chap0_mj.html)

# What is GAP?

GAP is a system for computational discrete algebra, with particular emphasis
on computational group theory. GAP provides a programming language, a library
of thousands of functions implementing algebraic algorithms written in the GAP
language as well as large data libraries of algebraic objects. For a more
detailed overview, see
  <https://www.gap-system.org/Overview/overview.html>.
For a description of the mathematical capabilities, see
  <https://www.gap-system.org/Overview/Capabilities/capabilities.html>.

GAP is used in research and teaching for studying groups and their
representations, rings, vector spaces, algebras, combinatorial structures, and
more. The system, including source, is distributed freely. You can study and
easily modify or extend it for your special use.


# How to obtain GAP?

## Download a stable release version

The latest stable release of the GAP system, including all currently
redistributed GAP packages, can be obtained from
  <https://www.gap-system.org/Releases/index.html>.
Afterwards, follow the instructions in the file `INSTALL.md` in the GAP root
directory.


# Using a GAP development version

Alternatively, you can compile the latest development version of GAP. However,
most users should instead use the latest official release instead as described
in the previous section.

If you really want to use a development version of GAP, start by cloning the
GAP source repository using git:

    git clone https://github.com/gap-system/gap


## Installing required dependencies

In this case, you need to have some more software dependencies installed than
with a stable release in order to compile GAP. In particular, you need at
least these:

* a C compiler, e.g. GCC or Clang
* a C++ compiler
* GNU Make
* GNU Autoconf

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

On macOS, you can install the dependencies in several ways:

 * using Homebrew: `brew install autoconf gmp readline`
 * using Fink: `fink install autoconf2.6 gmp5 readline7`
 * using MacPorts: `port install autoconf gmp readline`

On other operating systems, you will need to figure out equivalent commands
to install the required dependencies.


## Building GAP

Then to build GAP, first run this command to generate the `configure` script:

    ./autogen.sh

Afterwards you can proceed as described in `INSTALL.md`. If you are on macOS,
we recommend that you take a look at section "GAP for macOS" of `INSTALL.md`
for a few additional hints.


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

    ./gap

You can also find development versions of some of the GAP packages on
<https://github.com/gap-packages> resp. on <https://gap-packages.github.io>.


# We welcome contributions

The GAP Project welcomes contributions from everyone, in the shape of code,
documentation, blog posts, or other. For contributions to this repository,
please read the [contributor guidelines](CONTRIBUTING.md). Additional information:
- [Developer guidelines](DEVELOPING.md)
- [Notes on the build system](README.buildsys.md)

To keep up to date on GAP news (discussion of problems, release announcements,
bug fixes), you can subscribe to the
[GAP forum](https://www.gap-system.org/Contacts/Forum/forum.html) and
[GAP development](https://lists.uni-kl.de/gap/info/gap) mailing lists,
notifications on GitHub, and chat with us on [Slack](https://gap-system.org/slack).

If you have any questions about working with GAP, you can ask them on
[GAP forum](https://www.gap-system.org/Contacts/Forum/forum.html) (requires subscription)
or [GAP support](https://www.gap-system.org/Contacts/People/supportgroup.html) mailing lists.

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
<https://www.gnu.org/licenses/gpl.html>.
