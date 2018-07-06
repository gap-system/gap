The GAP 4 package `mockpkg`
===========================

This is a mock package to be used to test GAP library code
related to GAP packages, for example to validate `PackageInfo.g`
files.

It also has a manual written in `gapmacro.tex` format. This
format is obsolete, being superseded by GAPDoc; however, it
is still used by some packages, and hence we would like to
ensure that we are still able to render their documentation
using the "screen" online help viewer. This is why we use 
this manual to test for the code from `lib/helpt2t.g{d,i}`
which converts `gapmacro.tex`-based manuals into plain text.

If you make changes in the TeX source for this manual, you
need to run the `doc/make_doc` script to regenerate some
derived files that are used by the help system and are kept
under version control.

