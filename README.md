<random change!>
[![Build Status](https://travis-ci.org/gap-system/gap.svg?branch=master)](https://travis-ci.org/gap-system/gap) [![Code Coverage](https://codecov.io/github/gap-system/gap/coverage.svg?branch=master&token=)](https://codecov.io/gh/gap-system/gap)

# What is GAP?

GAP is a system for computational discrete algebra, with particular emphasis on
Computational Group Theory. GAP provides a programming language, a library of
thousands of functions implementing algebraic algorithms written in the GAP
language as well as large data libraries of algebraic objects. See also the
[overview](https://www.gap-system.org/Overview/overview.html) and the description of
the [mathematical capabilities](https://www.gap-system.org/Overview/Capabilities/capabilities.html).

GAP is used in research and teaching for studying groups and their representations,
rings, vector spaces, algebras, combinatorial structures, and more.
The system, including source, is distributed freely. You can study and easily
modify or extend it for your special use.

In July 2008, GAP was awarded the ACM/SIGSAM Richard Dimick Jenks Memorial Prize
for Excellence in Software Engineering applied to Computer Algebra.

# How to obtain GAP?

The latest stable release of the GAP system together with all currently redistributed
[GAP packages](https://www.gap-system.org/Packages/packages.html) can be obtained from our
[downloads page](https://www.gap-system.org/Releases/index.html).
For installation instructions see [here](https://www.gap-system.org/Download/install.html).

You can compile the current development version of GAP from this repository.
For this to work, the following dependencies need to be installed first:
* GNU autoconf >= 2.69

To build GAP, enter the following commands:
```
# ./autogen.sh
# ./configure
# make
```

Now, if you do not have a GAP package archive yet, we recommend that you
bootstrap the stable versions of packages by executing on of the the following
commands. Whether you choose to `bootstrap-pkg-minimal` or `bootstrap-pkg-full`
depends on your needs for development.

```
# make bootstrap-pkg-minimal
```

or

```
# make bootstrap-pkg-full
```

(in the latter case please that `make bootstrap-pkg-full` only unpacks packages
but does not build those of them that require compilation).

If everything goes well, you should be able to start GAP by executing
```
# sh bin/gap.sh
```

You can also find development versions of some of the GAP packages
on [GitHub](https://github.com/gap-system) and [Bitbucket](https://bitbucket.org/gap-system).

# We welcome contributions

The GAP Project welcomes contributions from everyone, in the shape of code,
documentation, blog posts, or other. For contributions to this repository,
please read the [guidelines](CONTRIBUTING.md).

To keep up to date on GAP news (discussion of problems, release announcements,
bug fixes), you can subscribe to the
[GAP forum](https://www.gap-system.org/Contacts/Forum/forum.html) and
[GAP development](https://mail.gap-system.org/mailman/listinfo/gap) mailing lists,
notifications on github, and follow us on [Twitter](https://twitter.com/gap_system).

If you have any questions about working with GAP, you can ask them on
[GAP forum](https://www.gap-system.org/Contacts/Forum/forum.html) (requires subscription)
or [GAP Support](https://www.gap-system.org/Contacts/People/supportgroup.html) mailing lists.

Please tell us about your use of GAP in research or teaching. We maintain a
[bibliography of publications citing GAP](https://www.gap-system.org/Doc/Bib/bib.html).
Please [help us](https://www.gap-system.org/Contacts/publicationfeedback.html)
keeping it up to date.
