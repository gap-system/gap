
                             The FactInt Package
                             ===================


                                  Abstract

FactInt is a GAP 4 package which provides routines for factoring integers, in
particular:

 - Pollard's p-1
 - Williams' p+1
 - Elliptic Curves Method (ECM)
 - Continued Fraction Algorithm (CFRAC)
 - Multiple Polynomial Quadratic Sieve (MPQS)

It also provides access to  Richard P. Brent's tables  of factors of integers
of the form b^k +/- 1.


                                Requirements

This Version of FactInt needs at least  version 4.4.9 of GAP and  version 1.0
of GAPDoc. It is completely written in the GAP language and does neither con-
tain nor require external binaries.


                                Installation

Like any other GAP package,  FactInt must be installed in the  pkg/ subdirec-
tory of the GAP distribution.  This is accomplished by extracting the distri-
bution file in this directory. By default, FactInt is autoloaded.  This means
that it is loaded automatically when you start GAP.

                                    ---

If you have problems with this package, wish to make comments or suggestions,
or if you find bugs, please send e-mail to

Stefan Kohl, stefan@mcs.st-and.ac.uk

