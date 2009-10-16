#############################################################################
##
#W  Makefile                 share package 'genus'              Thomas Breuer
##
#H  @(#)$Id: Makefile,v 1.6 2002/05/24 15:08:23 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file is the make file for packing the distribution of the package.
##
##  1. Targets
##  ----------
##
##     The "manual" target:
##       - creates the `tex' files from the `msk' files,
##         and uses them to create the files `manual.dvi' and `manual.ps'.
##
##     The "test" target:
##       - creates the file `tst/docxpl.tst' from the manual files,
##         and runs its tests and the ones in `tst/genus.tst' in GAP.
##
##     The "dist" target:
##       - creates the archive files (`tar', `tgz', and `zoo')
##         of the package distribution.
##
##     The "clean" target:
##       - removes the archive files created by `make dist',
##         the files `read.co' and `tst/docxpl.tst',
##         and all dependent documentation files;
##         these files are created automatically by `make dist' if necessary.
##
##
##  2. Contents of the development version of the package
##  -----------------------------------------------------
##     (The contents of the distribution is defined by the list `OBJECTS'
##     below, which includes files that are created by `make dist' and
##     therefore are not kept under CVS.)
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
##     `data'
##         directory containing the data of the classification for small
##         genera
##
##     `doc'
##         directory for the package documentation
##
##     `gap'
##         directory containing the GAP code
##
##     `htm'
##         directory containing the HTML version of the manual
##
##     `init.g', `read.g', and `banner.g'
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
##       `doc/manual.tex', and `WWW/Share/genus.input'.
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
##       update `WWW/Share/genus.input',
##       perhaps update also `Info4/share.input' and `WWW/Share/Makefile'.
##
##     - Put the archive `genus.zoo' and `README' (as `README.genus')
##       to the St Andrews `ftp' directory.
##
##     - Notify the release to CVS, using 
##       `cvs tag v<version>r<revision>p<level>'.
##
VERSION = 1r0

PKGNAME = genus

ARCHIVE = $(PKGNAME)/$(PKGNAME)$(VERSION)

GAP = gap4dev

HOMEPAGE = /usr/local/www-homes/Thomas.Breuer/$(PKGNAME)

OBJECTST = `find genus/data -name "*.g" -print` \
           $(PKGNAME)/doc/manual.ps \
           $(PKGNAME)/doc/manual.six \
           $(PKGNAME)/doc/errata.ps \
           `find genus/doc -name "*.tex" ! -name "errata.tex" -print` \
           `find genus/gap -name "*.g*" -print` \
           $(PKGNAME)/banner.g \
           $(PKGNAME)/init.g \
           $(PKGNAME)/read.g \
           $(PKGNAME)/read.co \
           `find genus/htm -name "*.htm" -print` \
           $(PKGNAME)/tst/testall.g \
           `find genus/tst -name "*.tst" -print`

OBJECTSB = $(PKGNAME)/doc/manual.dvi \
           $(PKGNAME)/doc/errata.dvi

OBJECTS = $(OBJECTST) $(OBJECTSB)

doc/defmax.tex:
	@( echo '% created automatically from data/loaddata.g' \
           > doc/defmax.tex; \
           fgrep 'BindGlobal( "MAXGENUS"' data/loaddata.g \
           | sed -e 's/ );/}/;s/BindGlobal( "MAXGENUS", /\\def\\MAXGENUS{/' \
           >> doc/defmax.tex )

manual:	doc/classify.msk doc/examples.msk doc/generate.msk doc/introduc.msk \
        doc/signatur.msk doc/manual.bib doc/errata.tex doc/defmax.tex
	@( cd doc; ../../../etc/buildman.pe -f buildman.config; \
           tex manual; bibtex manual; tex manual; \
           ../../../doc/manualindex manual; \
           tex manual; tex manual; \
           dvips -D300 manual -o manual.ps; \
           ../../../etc/convert.pl -t -c -n Genus . ../htm )
	@( cd doc; \
           latex errata; bibtex errata; latex errata; latex errata; \
           dvips -o errata.ps errata; \
           tth -t -Lerrata < errata.tex > ../htm/errata.htm )
	@( fgrep "undefined" doc/*.log; exit 0 )

read.co:
	( echo 'RequirePackage( "genus" ); \
	CreateCompletionFilesPkg( "genus" );' ) \
	| $(GAP) -q

tst/docxpl.tst: tst/docxpl.hea
	etc/makexpl

test: tst/docxpl.tst
	( cd tst; echo 'Read( "testall.g" )' | $(GAP) -A -N -q )

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

dist: manual doc/manual.dvi doc/manual.ps doc/manual.six \
      read.co tst/docxpl.tst \
      commb commt
	@( cd ..; \
        echo $(OBJECTST) | xargs -n 1 $(PKGNAME)/commt $(ARCHIVE).zoo; \
        echo $(OBJECTSB) | xargs -n 1 $(PKGNAME)/commb $(ARCHIVE).zoo; \
        zoo PE $(ARCHIVE).zoo )
	rm commt commb
	@( cd ..; tar cvzf $(ARCHIVE).tgz $(OBJECTS) )
	@( fgrep "exceeded" doc/*.log; exit 0 )

clean:
	rm genus*.tgz genus*.zoo read.co tst/docxpl.tst
	( cd doc; rm -f classify.tex examples.tex generate.tex introduc.tex \
         signatur.tex \
         manual.aux manual.bbl manual.blg manual.dvi manual.idl manual.idx \
         manual.ilg manual.ind manual.lab manual.log manual.ps manual.six \
         manual.toc \
         errata.dvi errata.log errata.ps )


#############################################################################
##
#E

