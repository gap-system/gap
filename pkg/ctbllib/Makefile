#############################################################################
##
#W  Makefile            GAP character table library             Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file is the make file for packing the distribution of the library,
##  and other administrational tasks.
##
##  1. Targets
##  ----------
##
##     The "toc" target:
##       - creates the file `data/ctprimar.tbl'
##
##     The "manual" target:
##       - creates the `tex' files from the `msk' files,
##         and uses them to create the file `manual.pdf'.
##
##     The "test" target:
##       - creates the file `tst/docxpl.tst' from the manual files,
##         creates the file `tst/ctbldeco.tst' from `doc/ctbldeco.xpl',
##         and runs the tests in the testfiles listed in `tst/testall.g'
##         and in `tst/hardtest.tst'.
##
##     The "dist" target:
##       - creates the archive files (`tar.gz' and `zoo')
##         of the package distribution.
##
##     The "clean" target:
##       - removes the archive files created by `make dist',
##         the file `tst/docxpl.tst'
##         and all dependent documentation files;
##         these files are created automatically by `make dist' if necessary.
##
##     The "periphery" target:
##       - tests whether the information related to the character table
##         library is complete/consistent;
##         the exact meaning is documented in the script 'etc/periphery'.
##
#T     The "webrefresh" target:
#T       - copies the current versions of the files `gap/atlasprm.g'
#T         and all files in `htm/data' to the `HOMEPAGE' directory;
#T         this target defines which files belong to the ``web services''
#T         part of the package (see the corresponding manual section),
#T         links to these files are contained in `index.html'.
##
##     The "release" target:
##       - copies the two archive files (`tar.gz' and `zoo' format),
##         compiled manual files (`manual.pdf' and the files
##         `htm/*.htm'), and `index.html', `PackageInfo.g', `README' to the
##         `HOMEPAGE' directory.
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
##  3. Contents of the development version of the package
##  -----------------------------------------------------
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
##     `ctbltoc'
##         directory containing the stuff for the WWW table of contents
##         (not part of the distribution)
##
##     `data'
##         directory for the data files and the current table of contents
##
##     `dec'
##         directory for the stuff needed for the (web) database
##         of decomposition matrices
##
##     `dev'
##         directory for the development environment of the package
##         (This directory is not part of the distribution.)
##
##     `doc'
##         directory for the documentation,
##         plus the file `ctbldiff.tex'
##
##     `etc'
##         directory containing the following files:
##         `ctoc'       (directory with programs to convert CAS format
##                       data files to GAP readable format),
##         `dehist'     (removes the history lines from data files),
##         `periphery'  (checks peripheral information),
##         `posttth'    (corrects `tth' output for `ctbldiff.tex').
##
##     `gap3'
##         directory containing the GAP 3 code of the interface
##
##     `gap4'
##         directory containing the GAP 4 code of the interface
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
##     `irrats'
##         directory containing the stuff for common ATLAS irrationalities
##         (not part of the distribution)
##
##     `tst'
##         directory containing test files and related data
##
##
##  4. What is to do for keeping the package up to date?
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
##       and that `index.html', `README' are consistent.
##
##     - If new functionality has been added,
##       check that examples and tests for all new variants are provided.
##
##     - Update the database attribute files `data/grp*.dat'.
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
##       read `tst/testinst.g' and `testall.g';
##       in GAP 3, call `ReadTest( "gap3/ctbllib.tst" )'.
##
##     - Prepare `ctbldiff.tex' for the release.
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
VERSION = 1r1p3

PKGNAME = ctbllib

ARCHIVE = $(PKGNAME)/$(PKGNAME)$(VERSION)

#GAP = gap4dev
GAP = ~sam/gap/4.0/bin/i686-pc-linux-gnu-gcc/gap -b -l ~sam/gap/4.0/

HOMEPAGE = /usr/local/www-homes/Thomas.Breuer/$(PKGNAME)

OBJECTST = $(PKGNAME)/dlnames/*.g* \
           $(PKGNAME)/doc/ctbldiff.pdf \
           $(PKGNAME)/doc/ambigfus.pdf \
           $(PKGNAME)/doc/ctblcons.pdf \
           $(PKGNAME)/doc/ctbldeco.pdf \
           $(PKGNAME)/doc/ctblj4.pdf \
           $(PKGNAME)/doc/ctblpope.pdf \
           $(PKGNAME)/doc/ctocenex.pdf \
           $(PKGNAME)/doc/multfree.pdf \
           $(PKGNAME)/doc/multfre2.pdf \
           $(PKGNAME)/doc/o8p2s3_o8p5s3.pdf \
           $(PKGNAME)/doc/probgen.pdf \
           $(PKGNAME)/doc/manual.lab \
           $(PKGNAME)/doc/manual.six \
           $(PKGNAME)/doc/manual.tex \
           $(PKGNAME)/doc/manual.toc \
           $(PKGNAME)/doc/ctbllibr.tex \
           $(PKGNAME)/doc/ctblothe.tex \
           $(PKGNAME)/doc/introduc.tex \
           $(PKGNAME)/doc/construc.tex \
           $(PKGNAME)/doc/manual.css \
           `find $(PKGNAME)/doc -maxdepth 1 -name "*.txt" -print` \
           `find $(PKGNAME)/doc -maxdepth 1 -name "*.html" -print` \
           `find $(PKGNAME)/doc -maxdepth 1 -name "*.xml" -print` \
           `find $(PKGNAME)/htm -maxdepth 1 -name "*.htm" -print` \
           `find $(PKGNAME)/htm -maxdepth 1 -name "*.png" -print` \
           `find $(PKGNAME)/data -name "*.tbl" -print` \
           `find $(PKGNAME)/data -name "grp_*.dat" -print` \
           $(PKGNAME)/gap3/ctadmin.g \
           $(PKGNAME)/gap4/construc.g? \
           $(PKGNAME)/gap4/ctadmin.tb? \
           $(PKGNAME)/gap4/ctblothe.g? \
           $(PKGNAME)/gap4/test.g? \
           $(PKGNAME)/init.g \
           $(PKGNAME)/read.g \
           $(PKGNAME)/PackageInfo.g \
           $(PKGNAME)/README \
           $(PKGNAME)/tst/testall.g \
           $(PKGNAME)/tst/testinst.g \
           `find $(PKGNAME)/tst -name "*.tst" -print` \
           $(PKGNAME)/tst/multfree.dat \
           $(PKGNAME)/tst/multfre2.dat \
           $(PKGNAME)/tst/hamilcyc.g \
           $(PKGNAME)/tst/multfree.g \
           $(PKGNAME)/tst/o8p2s3_o8p5s3.g \
           $(PKGNAME)/tst/probgen.g

OBJECTSB = $(PKGNAME)/doc/manual.pdf

OBJECTS = $(OBJECTST) $(OBJECTSB)


#############################################################################
##
##  Targets
##
periphery:
	etc/periphery

toc: dev/maketbl.g
	@( echo 'LoadPackage( "ctbllib" );; ReadPackage( "ctbllib", "dev/maketbl.g" );; CTblLibRecomputeTOC();;' | $(GAP) -A -N )

mainmanual:
	@( cd doc; echo 'Read( "makedocrel.g" );' \
          | $(GAP) -o 500m -A -N -q > /dev/null )
	@( grep -e "exceeded\|undefined" doc/main.log; exit 0 )

manual: mainmanual
	etc/processxpl ambigfus
	etc/processxpl ctblcons
	etc/processxpl ctbldeco
	etc/processxpl ctblj4
	etc/processxpl ctblpope
	etc/processxpl ctocenex
	etc/processxpl multfree
	etc/processxpl multfre2
	etc/processxpl o8p2s3_o8p5s3
	etc/processxpl probgen
	@( cd doc; tex ctbldiff; pdftex ctbldiff )
	@( tth -u < doc/ctbldiff.tex > tmp; \
           etc/posttth tmp htm/ctbldiff.htm; \
           rm tmp )
	@( grep -e "exceeded\|undefined" doc/*.log; exit 0 )

tst/docxpl.tst: tst/docxpl.hea
	etc/makexpl

tst/ambigfus.tst: xpl/ambigfus.xpl
	etc/processxpl ambigfus

tst/ctblcons.tst: xpl/ctblcons.xpl
	etc/processxpl ctblcons

tst/ctbldeco.tst: xpl/ctbldeco.xpl
	etc/processxpl ctbldeco

tst/ctblj4.tst: xpl/ctblj4.xpl
	etc/processxpl ctblj4

tst/ctblpope.tst: xpl/ctblpope.xpl
	etc/processxpl ctblpope

tst/multfree.tst: xpl/multfree.xpl
	etc/processxpl multfree

tst/multfre2.tst: xpl/multfre2.xpl
	etc/processxpl multfre2

tst/ctocenex.tst: xpl/ctocenex.xpl
	etc/processxpl ctocenex

tst/o8p2s3_o8p5s3.tst: xpl/o8p2s3_o8p5s3.xpl
	etc/processxpl o8p2s3_o8p5s3

tst/probgen.tst: xpl/probgen.xpl
	etc/processxpl probgen

test: tst/docxpl.tst tst/ambigfus.tst tst/ctblcons.tst tst/ctbldeco.tst \
      tst/ctblj4.tst tst/ctblpope.tst tst/multfree.tst tst/multfre2.tst \
      tst/ctocenex.tst tst/o8p2s3_o8p5s3.tst tst/probgen.tst
	( cd tst; echo 'Read( "testall.g" ); ReadTest( "hardtest.tst" ); \
           Exec( "date -u +../dev/log/test_%Y-%m-%d-%H-%M | \
                  xargs -n 1 cp test.out" ); \
           Exec( "rm test.out" );' \
          | $(GAP) -o 500m -A -N -q >& test.out & )

testcons:
	( cd dev; $(GAP) -o 500m -b -A -N < testcons.g >& /dev/null & )

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

dist: doc/manual.pdf doc/manual.lab doc/manual.six doc/manual.css \
      tst/docxpl.tst tst/ambigfus.tst tst/ctblcons.tst tst/ctbldeco.tst \
      tst/ctblj4.tst tst/ctblpope.tst tst/multfree.tst tst/multfre2.tst \
      tst/ctocenex.tst tst/o8p2s3_o8p5s3 tst/probgen.tst \
      commb commt
	@( cd ..; \
        echo $(OBJECTST) | xargs -n 1 $(PKGNAME)/commt $(ARCHIVE).zoo; \
        echo $(OBJECTSB) | xargs -n 1 $(PKGNAME)/commb $(ARCHIVE).zoo; \
        zoo PE $(ARCHIVE).zoo )
	rm commt commb
	@( cd ..; tar cvzpf $(ARCHIVE).tar.gz $(OBJECTS) )
# before packing the distribution, apply dehist!

clean:
	rm -f ../$(ARCHIVE).zoo ../$(ARCHIVE).tar.gz \
           tst/docxpl.tst
	( cd tst; rm -f ambigfus.tst ctblcons.tst ctbldeco.tst ctblj4.tst \
          ctblpope.tst ctocenex.tst docxpl.tst multfree.tst multfre2.tst \
          multfree.g o8p2s3_o8p5s3.tst o8p2s3_o8p5s3.g \
          probgen.tst probgen.g )
	( cd doc; rm -f construc.tex ctbllibr.tex ctblothe.tex introduc.tex \
	 ambigfus.* ctblcons.* ctbldeco.* ctblj4.* ctblpope.* ctocenex.* \
         multfree.* multfre2.* o8p2s3_o8p5s3.* probgen.* \
         ctbldiff.log \
         ctbldiff.pdf manual.aux manual.bbl manual.blg manual.idl \
         manual.idx manual.ilg manual.ind manual.lab manual.log manual.pdf \             manual.six manual.toc )
	( cd htm; rm -f *.png \
         ambigfus.htm ctblcons.htm ctbldeco.htm ctblj4.htm ctblpope.htm \
         ctocenex.htm multfree.htm multfre2.htm o8p2s3_o8p5s3.htm \
         probgen.htm ctbldiff.htm )

webrefresh:
	( if ! test -d $(HOMEPAGE)/htm; then mkdir $(HOMEPAGE)/htm; fi )

release: webrefresh \
         index.html PackageInfo.g README \
         doc/manual.pdf doc/ctbldiff.pdf \
         ../$(ARCHIVE).zoo ../$(ARCHIVE).tar.gz \
         htm/chapters.htm
	( cp index.html PackageInfo.g README \
          ../$(ARCHIVE).zoo ../$(ARCHIVE).tar.gz \
          $(HOMEPAGE); \
          cp htm/*.htm htm/*.png $(HOMEPAGE)/htm; \
          cp doc/manual.pdf doc/ctbldiff.pdf $(HOMEPAGE)/doc )

webrefreshsub:
	( cp tst/multfree.g $(HOMEPAGE)/multfree ; \
          cp doc/ambigfus.pdf $(HOMEPAGE)/doc; \
          cp doc/ctbldeco.pdf $(HOMEPAGE)/doc; \
          cp doc/ctblpope.pdf $(HOMEPAGE)/doc; \
          cp doc/ctocenex.pdf $(HOMEPAGE)/doc; \
          cp doc/o8p2s3_o8p5s3.pdf $(HOMEPAGE)/doc; \
          cp doc/probgen.pdf $(HOMEPAGE)/doc; \
          cp doc/multfree.pdf $(HOMEPAGE)/doc; \
          cp doc/multfre2.pdf $(HOMEPAGE)/doc )

#T multfre2: needs replacement of multfre2.dat, multfree.g into directory data,
#T           replacement of multfre2.pdf in doc, multfre2.htm in htm
#T and what about probgen.g, o8p2s3_o8p5s3.g? (cf. \URL call in probgen.xpl!)

#############################################################################
##
#E

