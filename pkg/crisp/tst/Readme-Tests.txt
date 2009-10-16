############################################################################
##
##  Readme-Tests.txt                CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: Readme-Tests.txt,v 1.4 2005/07/19 14:02:24 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
To run these test files, simply read the file "all.g" into GAP using `Read'
(not `ReadTest'). Their output is for information only, and can safely be
ignored. If one of the tests discovers an error, it will print an error 
message and stop. Please report any such error(s) to the author, preferably
by e-mail to b.hoefling@tu-bs.de.

You may also read individual test files into GAP after setting the following
boolean variables to `true' or `false'.

PRINT_METHODS - if true, relevant methods are printed using TraceMethods
FAST_TEST     - if true, run only small examples
DO_TIMING     - if true, measures the time required for different algorithms

FAST_TEST and DO_TIMING only affect the files whose names start with
`timing_'. Note that these files require that the package `format' is present.
PRINT_METHODS only affects the other test files.

Note that, in order to get reasonably reliable timings, one should start
GAP using the -N command line option. This ensures that all required library 
files are properly loaded before times are taken.

The following table lists the available test files and their content.

Readme-Tests.txt        -- this file
all.g                   -- runs all of the following test files
basis.g                 -- tests methods for Basis
boundary.g              -- tests methods for Boundary
char.g                  -- tests methods for Characteristic
classes.g               -- tests constructions of classes and immediate methods
in.g                    -- tests methods for IsMemberOp
injectors.g             -- tests methods for InjectorOp
normals.g               -- tests algorithms for normal subgroups
print.g                 -- tests methods for PrintObj and ViewObj
projectors.g            -- tests methods for ProjectorOp
radicals.g              -- tests methods for RadicalOp
residuals.g             -- tests methods for ResidualOp
samples.g               -- file containing sample groups and sample classes
timing_injectors.g      -- tests algorithms for InjectorOp
timing_normals.g        -- tests algorithms for NormalSubgroups
timing_normpro.g        -- tests algorithms for NormalizerOfPronormalSubgroup
timing_projectors.g     -- tests algorithms for ProjectorOp
timing_projectors_mod.g -- as timing_projectors, but uses a different library
                           method for the centralizer, which produced wrong
                           results in GAP 4.2.5
timing_radicals.g       -- tests algorithms for RadicalOp
timing_residuals.g      -- tests algorithms for ResidualOp


############################################################################
##
#E
##
