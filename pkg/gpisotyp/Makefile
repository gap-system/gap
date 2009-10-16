#############################################################################
##
#W  Makefile               GAP 4 package `gpisotyp'             Thomas Breuer
##
#H  @(#)$Id: Makefile,v 1.4 2004/09/14 15:10:04 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file is the make file for packing the distribution of the package.
##
##  1. Targets
##  ----------
##
##     The "manual" target:
##       - creates the `tex' files from the `msk' files,
##         and uses them to create the files `manual.dvi' and `manual.pdf'.
##
##     The "test" target:
##       - creates the file `tst/docxpl.tst' from the manual files,
##         and runs its tests and the ones in `tst/gpisotyp.tst' in GAP.
##
##     The "dist" target:
##       - creates the archive files (`tgz' and `zoo')
##         of the package distribution.
##
##     The "clean" target:
##       - removes the archive files created by `make dist',
##         the file `tst/docxpl.tst',
##         and all dependent documentation files;
##         these files are created automatically by `make dist' if necessary.
##
##     The "webrefresh" target:
##       - copies archive files, compiled manual files, `doc/index.html',
##         and `README' to the `HOMEPAGE' directory.
##
##
##  2. Contents of the development version of the package
##  -----------------------------------------------------
##     (The contents of the distribution is defined by the lists `OBJECTST'
##     and `OBJECTSB' below,
##     which includes files that are created by `make dist'
##     and therefore are not kept under CVS.)
##
##     `CVS'
##         directory used by the `cvs' program
##
##     `Makefile'
##         this file
##
##     `README'
##         the `README' file referenced by the GAP HTML pages
##
##     `TODO'
##         a file that lists ideas to be implemented in forthcoming releases
##
##     `doc'
##         directory for the package documentation
##
##     `etc'
##         directory containing the following scripts:
##         `makexpl'    (creates `tst/docxpl.tst' from the manual files)
##
##     `gap'
##         directory containing the GAP code of the interface
##
##     `htm'
##         directory containing the HTML version of the manual
##
##     `init.g' and `read.g'
##         files that are read by GAP when the package is loaded
##
##     `tst'
##         directory containing test files and related data
##
##
##  3. What is to do for keeping the package up to date?
##  ----------------------------------------------------
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
##       and that `index.html' and `README' are consistent.
##
##     - If new functionality has been added,
##       check that examples and tests for all new variants are provided.
##
##
##  4. What is to do additionally in the case of a new release?
##  -----------------------------------------------------------
##
##     - Make sure that the tests in `tst/hardtest.tst' work.
##
##     - Make sure that the version numbers are correct and consistent
##       in this Makefile, `init.g', `README', `doc/index.html',
##       `doc/manual.tex', and `WWW/Share/gpisotyp.input'.
##
##     - Create the archives with the "dist" target.
##       Be careful to create the manual w.r.t. the current release of GAP,
##       in order to have correct cross-references.
##
##     - Update the homepage of the package
##       (including manual, archives, README).
##
##     - Make the necessary changes in the CVS files of the GAP html pages,
##       that is,
##       update `WWW/Share/gpisotyp.input',
##       perhaps update also `Info4/share.input' and `WWW/Share/Makefile'.
##
##     - Put the archive `gpisotyp.zoo' and `README' (as `README.gpisotyp')
##       to the St Andrews `ftp' directory.
##
##     - Notify the release to CVS, using
##       `cvs tag v<version>r<revision>p<level>'.
##
VERSION = 1r0

PKGNAME = gpisotyp

ARCHIVE = $(PKGNAME)/$(PKGNAME)$(VERSION)

GAP = gap4dev

HOMEPAGE = /usr/local/www-homes/Thomas.Breuer/$(PKGNAME)

OBJECTSD = $(PKGNAME)/doc/manual.pdf \
           $(PKGNAME)/doc/manual.six \
           `find gpisotyp/doc -name "*.tex" -print` \
           `find gpisotyp/htm -name "*.htm" -print`

OBJECTST = $(PKGNAME)/doc/manual.pdf \
           $(PKGNAME)/doc/manual.six \
           `find gpisotyp/doc -name "*.tex" -print` \
           `find gpisotyp/gap -name "*.g*" -print` \
           `find gpisotyp/htm -name "*.htm" -print` \
           $(PKGNAME)/init.g \
           $(PKGNAME)/read.g \
           $(PKGNAME)/tst/testall.g \
           `find gpisotyp/tst -name "*.tst" -print`

OBJECTSB = $(PKGNAME)/doc/manual.dvi

OBJECTS = $(OBJECTST) $(OBJECTSB)

manual: doc/gpisotyp.msk \
        doc/manual.bib
	@( cd doc; ../../../etc/buildman.pe -f buildman.config; \
           tex manual; bibtex manual; tex manual; \
           ../../../doc/manualindex manual; \
           tex manual; tex manual; \
           pdftex manual; \
           ../../../etc/convert.pl -t -c -n GpIsoTyp . ../htm )
	@( fgrep "undefined" doc/*.log; exit 0 )

tst/docxpl.tst: tst/docxpl.hea
	etc/makexpl

test: tst/docxpl.tst
	( cd tst; if test -f test.out; then mv test.out test.old; fi; \
	echo 'Read( "testall.g" );' | \
	$(GAP) -A -N -q > test.out & )

commb:
	( echo 'zoo ahc $$1 $$2 <<EOF' > commb; \
          echo '!BINARY!' >> commb; \
          echo '/END' >> commb; \
          echo 'EOF' >> commb; \
          chmod +x commb )

commt:
	( echo 'zoo ahc $$1 $$2 <<EOF' > commt; \
          echo '!TEXT!' >> commt; \
          echo '/END' >> commt; \
          echo 'EOF' >> commt; \
          chmod +x commt )

dist: manual doc/manual.dvi doc/manual.pdf doc/manual.six \
      tst/docxpl.tst \
      commb commt
	@( cd ..; \
        echo $(OBJECTST) | xargs -n 1 $(PKGNAME)/commt $(ARCHIVE).zoo; \
        echo $(OBJECTSB) | xargs -n 1 $(PKGNAME)/commb $(ARCHIVE).zoo; \
        zoo PE $(ARCHIVE).zoo )
	rm commt commb
	@( cd ..; tar cvzf $(ARCHIVE).tgz $(OBJECTS) )
	@( fgrep "exceeded" doc/manual.log; exit 0 )
	@( cd ..; tar cvzf $(ARCHIVE)doc.tar.gz $(OBJECTSD) )

clean:
	rm -f $(PKGNAME)*.tgz $(PKGNAME)*.zoo tst/docxpl.tst
	( cd doc; rm -f gpisotyp.tex stdnames.tex \
          manual.aux manual.bbl manual.blg manual.dvi manual.idl manual.idx \
          manual.ilg manual.ind manual.lab manual.log manual.pdf manual.six \
          manual.toc )

webrefresh: $(PKGNAME)$(VERSION).zoo $(PKGNAME)$(VERSION).tar \
            $(PKGNAME)$(VERSION).tgz \
            doc/manual.dvi doc/manual.pdf \
            htm/chapters.htm
	( cp doc/index.html doc/manual.dvi doc/manual.pdf $(HOMEPAGE); \
          cp htm/*.htm $(HOMEPAGE)/htm; \
	  cp $(PKGNAME)$(VERSION).zoo $(PKGNAME)$(VERSION).tar \
             $(PKGNAME)$(VERSION).tgz $(HOMEPAGE); \
          cp README $(HOMEPAGE) )


#############################################################################
##
#E

