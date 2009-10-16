#############################################################################
##
#W  Makefile            GAP tables of marks library             Thomas Breuer
##
#H  @(#)$Id: Makefile,v 1.12 2008/11/26 09:58:34 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file is the make file for packing the distribution of the library,
##  and other administrational tasks.
##
##  1. Targets
##  ----------
##
##     The "testcons" target:
##       - runs the consistency checks in the file `dev/testcons.g'.
##
##     The "dist" target:
##       - creates the archive files (`tar.gz', and `zoo')
##         of the package distribution;
##         note that there are two archives, one (`tomlib.zoo') with the
##         basic material and the moderate sized tables,
##         and one (`tomlibxt.zoo') with the large tables of marks.
##
##     The "clean" target:
##       - removes the archive files created by `make dist'.
##
##
##  2. Contents of the distribution of the package
##  ----------------------------------------------
##
##     This is defined by the lists `OBJECTST' (all text files) and `OBJECTSB'
##     (all binary files) below, which includes files that are created by
##     `make dist' and therefore are not kept under CVS.
##
##
##  3. Contents of the development version of the tables of marks library
##  ---------------------------------------------------------------------
##
##     `CVS'
##         directory used by the `cvs' program
##
##     `Makefile'
##         this file
##
##     `PackageInfo.g'
##         the file with information used to load the package and to upgrade
##         the GAP webpages
##
##     `README'
##         the `README' file referenced by the GAP HTML pages
##
##     `TODO'
##         a file that lists ideas to be implemented in forthcoming releases
##
##     `data'
##         directory for the data files and the current table of contents
##
##     `dev'
##         directory for the development environment of the package
##         (This directory is not part of the distribution.)
##
##     `doc'
##         directory for the documentation,
##         plus the file `tomdiff.tex'
##
##     `gap'
##         directory containing the GAP code of the interface
##
##     `htm'
##         directory containing the HTML version of the manual
##
##     `index.html'
##         the homepage of the package
##
##     `init.g' and `read.g'
##         files that are read by GAP when the table library is loaded
##
##     `tst'
##         directory containing test files and related data
##
##
##  4. What is to do for keeping the tables of marks library up to date?
##  --------------------------------------------------------------------
##
##     - Create an up to date documentation using the "manual" target.
##       Check that all cross-references work.
##
##     - Create and run the testfiles using the "test" target.
##       Make sure that all testfiles are mentioned in `tst/testall.g'.
##
##     - Update the sizes of the archive files mentioned in `index.html'.
##
##     - Make sure that the links in the file `index.html' are correct,
##       and that `index.html', `README' are consistent.
##
##     - If new functionality has been added,
##       are examples and tests for all new variants provided?
##
##
##  5. What is to do additionally in the case of a new release?
##  -----------------------------------------------------------
##
##     - Use the "test" target to make sure that also the tests in
##       `tst/hardtest.tst' work.
##
##     - Make sure that the version numbers are correct and consistent
##       in this Makefile, `README', `index.html', `doc/manual.tex',
##       `doc/manual.bib', and `PackageInfo.g'.
##
##     - Create the archives with the "dist" target.
##       Be careful to create the manual w.r.t. the current release of GAP,
##       in order to have correct cross-references.
##
##     - Test the archives:  Unpack them into a new directory,
##       read `testall.g'.
##
##     - Prepare `tomdiff.tex' for the release.
##       Create an HTML version `tomdiff.html' using TtH.
##       Probably it is still necessary to run `pkg/ctbllib/etc/posttth'
##       in order to fix the output.
##       (Look at the <table> constructs!)
##
##     - Update the homepage of the package, using the "release" target
##       (including manual, archives, `README', `PackageInfo.g', ...).
##
##     - Notify the release to CVS, using
##       `cvs tag v<version>r<revision>p<level>'.
##
##     - Write an announcement to the GAP Forum.
##


#############################################################################
##
##  Global Variables
##
VERSION = 1r1p4

PKGNAME = tomlib

ARCHIVE = $(PKGNAME)/$(PKGNAME)$(VERSION)

ARCHIVEXT = $(PKGNAME)/$(PKGNAME)xt$(VERSION)

GAP = gap4dev

HOMEPAGE = /usr/local/www-homes/Thomas.Breuer/$(PKGNAME)

OBJLARGE = `find tomlib/data -name "*.tom" -size +9999999c -print`

OBJECTST = $(PKGNAME)/doc/tomdiff.pdf \
           `find $(PKGNAME)/htm -maxdepth 1 -name "*.htm" -print` \
           `find tomlib/data -name "*.tom" -size -10000000c -print` \
           $(PKGNAME)/gap/tmadmin.tm? \
           $(PKGNAME)/gap/tmstdrd.tom \
           $(PKGNAME)/gap/stdgen.g? \
           $(PKGNAME)/init.g \
           $(PKGNAME)/read.g \
           $(PKGNAME)/PackageInfo.g \
           $(PKGNAME)/README \
           $(PKGNAME)/tst/testall.g \
           `find tomlib/tst -name "*.tst" -print`


#############################################################################
##
##  Targets
##
manual: 
	@( cd doc; tex tomdiff; pdftex tomdiff )
	@( tth -u < doc/tomdiff.tex > tmp; \
           ../ctbllib/etc/posttth tmp htm/tomdiff.htm; \
           rm tmp )
	@( grep -e "exceeded\|undefined" doc/*.log; exit 0 )

test:
	( cd tst; echo 'Read( "testall.g" ); ReadTest( "hardtest.tst" ); \
           Exec( "date -u +../dev/log/test_%Y-%m-%d-%H-%M | \
                  xargs -n 1 cp test.out" ); \
           Exec( "rm test.out" );' \
          | $(GAP) -o 500m -A -N -q > test.out & )

testcons:
	( cd dev; $(GAP) -o 500m -b -A -N < testcons.g > /dev/null & )

commt:
	( echo 'zoo ahc $$1 $$2 <<EOF' > commt; \
          echo '!TEXT!' >> commt; \
          echo '/END' >> commt; \
          echo 'EOF' >> commt; \
          chmod +x commt )

dist: commt
	@( cd ..; \
        echo $(OBJECTST) | xargs -n 1 $(PKGNAME)/commt $(ARCHIVE).zoo; \
        zoo PE $(ARCHIVE).zoo )
	@( cd ..; \
        echo $(OBJLARGE) | xargs -n 1 $(PKGNAME)/commt $(ARCHIVEXT).zoo; \
        zoo PE $(ARCHIVEXT).zoo )
	rm commt
	@( cd ..; tar cvzf $(ARCHIVE).tar.gz $(OBJECTST) )
	@( cd ..; tar cvzf $(ARCHIVEXT).tar.gz $(OBJLARGE) )

clean:
	rm -f ../$(ARCHIVE).zoo ../$(ARCHIVEXT).zoo \
           ../$(ARCHIVE).tar.gz ../$(ARCHIVEXT).tar.gz \
           commt
	( cd doc; rm -f \
         tomdiff.dvi tomdiff.log tomdiff.pdf \
         )

webrefresh:
	( if ! test -d $(HOMEPAGE)/htm; then mkdir $(HOMEPAGE)/htm; fi )

release: webrefresh \
         index.html PackageInfo.g README \
         doc/tomdiff.pdf \
         ../$(ARCHIVE).zoo ../$(ARCHIVE).tar.gz \
         htm/chapters.htm
	( cp index.html PackageInfo.g README \
          ../$(ARCHIVE).zoo ../$(ARCHIVEXT).zoo ../$(ARCHIVE).tar.gz \
          ../$(ARCHIVEXT).tar.gz \
          $(HOMEPAGE); \
          cp htm/*.htm $(HOMEPAGE)/htm; \
          cp doc/tomdiff.pdf $(HOMEPAGE)/doc )


#############################################################################
##
#E

