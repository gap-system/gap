#############################################################################
##
#W  Makefile             GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file is the make file for packing the distribution of the package,
##  and other administrational tasks.
##
##  1. Targets
##  ----------
##
##     The "manual" target:
##       - creates the manual form the source files,
##         by reading 'doc/makedocrel.g' into GAP;
##         at the same time, the file `tst/docxpl.tst' is updated.
##
##     The "test" target:
##       - runs the tests in the test files listed in `tst/testall.g'
##         and in `tst/hardtest.tst'.
##
##     The "update" target:
##       - runs GAP with input `dev/update.g', which archives outdated files,
##         fetches nonavailable server files, and updates `gap/atlasprm.g'.
##
##     The "dist" target:
##       - creates the archive files (`tar.gz' and `zoo')
##         of the package distribution.
##
##     The "clean" target:
##       - removes the archive files created by `make dist',
##         the file `tst/docxpl.tst',
##         and all dependent documentation files;
##         these files are created automatically by `make dist' if necessary.
##
##     The "webrefresh" target:
##       - copies the current versions of the files `gap/atlasprm.g'
##         and all files in `htm/data' to the `HOMEPAGE' directory;
##         this target defines which files belong to the ``web services''
##         part of the package (see the corresponding manual section),
##         links to these files are contained in `index.html'.
##
##     The "release" target:
##       - copies the two archive files (`tar.gz' and `zoo' format),
##         compiled manual files (`manual.pdf' and the files `doc/*.html' and
##         `doc/*.txt', and `manual.six' ...),
##         and `index.html', `PackageInfo.g', `README' to the
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
##     `datagens'
##         directory for the group generators of the database
##         (containing at least the file `dummy')
##
##     `dataword'
##         directory for the straight line programs of the database
##         (containing at least the file `dummy')
##
##     `dev'
##         directory for the development environment of the package
##         (This directory is not part of the distribution.)
##
##     `doc'
##         directory for the package documentation
##
##     `etc'
##         directory containing the following scripts:
##         `maketoc'    (creates the server's current table of contents),
##         `mtog'       (converts a Magma format data file to GAP format),
##
##     `gap'
##         directory containing the GAP code of the interface
##
##     `htm'
##         directory containing HTML data about the table of contents
##         (Note that the HTML version of the manual is in `doc'.)
##
##     `index.html'
##         the homepage of the package
##
##     `init.g' and `read.g'
##         files that are read by GAP when the package is loaded
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
##     - Run the tests in the test files using the "test" target.
##       Make sure that all test files are mentioned in `tst/testall.g'.
##
##     - Make sure that the addresses of servers stored in the file
##       `gap/atlasprm.g' and in the package documentation are correct.
##
##     - Use the "update" target regularly to make sure that the table of
##       contents stored in the file `gap/atlasprm.g' is up to date.
##       Whenever `gap/atlasprm.g' or `htm/data/changes.htm' grows,
##       put the current versions to the package homepage using the
##       "webrefresh" target.
##
##     - Make sure that the files `gap/scanmtx.gd' and `scanmtx.gi'
##       in the `atlasrep' package coincide with the corresponding files
##       in the `cmeataxe' package.
##
##     - Make sure that the links in the file `index.html' are correct,
##       and that `index.html' and `README' are consistent.
##
##     - Make sure that `index.html' and Rob's webpages link to the current
##       documentation.
##
##     - If new functionality has been added,
##       check that examples and tests for all new variants are provided.
##
##
##  5. What is to do additionally in the case of a new release?
##  -----------------------------------------------------------
##
##     - Use the "test" target to make sure that also the tests in
##       `tst/hardtest.tst' work.
##
##     - Make sure that version numbers and release dates are correct
##       and consistent in
##       - this Makefile (variable `VERSION'),
##       - `README' (only version number),
##       - `index.html' (date, version number, archive names),
##       - `doc/main.xml' (entities `VERSIONNUMBER', `RELEASEMONTH',
##          `RELEASEYEAR'),
##       - the manual section about citing the package, and
##       - `PackageInfo.g' (components `MyVersion', `Date').
##
##     - Update the sizes of the archive files mentioned in `index.html',
##       and the numbers/sizes of data files in the manual.
##
##     - Create the archives with the "dist" target.
##       Be careful to create the manual w.r.t. the current release of GAP,
##       in order to have correct cross-references.
##       Create also a new starter archive.
##
##     - Test the archives:  Unpack them into a new directory,
##       read `tst/testinst.g' and `tst/testall.g'.
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
VERSION = 1r5p0

PKGNAME = atlasrep

ARCHIVE = $(PKGNAME)/$(PKGNAME)$(VERSION)

#GAP = gap4dev
GAP = ~sam/gap/4.0/bin/i686-pc-linux-gnu-gcc/32-bit/gap -b -l ~sam/gap/4.0/

HOMEPAGE = /usr/local/www-homes/Thomas.Breuer/$(PKGNAME)

OBJECTST = $(PKGNAME)/bibl/Atlas1bib.xml \
           $(PKGNAME)/bibl/Atlas2bib.xml \
           $(PKGNAME)/bibl/ABCbiblbib.xml \
           $(PKGNAME)/bibl/ABCapp2bib.xml \
           $(PKGNAME)/bibl/mindegbib.xml \
           $(PKGNAME)/doc/manual.css \
           $(PKGNAME)/doc/manual.lab \
           $(PKGNAME)/doc/manual.six \
           `find $(PKGNAME)/doc -maxdepth 1 -name "*.txt" -print` \
           `find $(PKGNAME)/doc -maxdepth 1 -name "*.html" -print` \
           `find $(PKGNAME)/doc -maxdepth 1 -name "*.xml" -print` \
           $(PKGNAME)/datagens/dummy \
           $(PKGNAME)/dataword/dummy \
           $(PKGNAME)/etc/maketoc \
           `find $(PKGNAME)/gap -maxdepth 1 -name "*.g*" -print` \
           $(PKGNAME)/init.g \
           $(PKGNAME)/read.g \
           $(PKGNAME)/PackageInfo.g \
           $(PKGNAME)/README \
           $(PKGNAME)/tst/testall.g \
           $(PKGNAME)/tst/testinst.g \
           `find $(PKGNAME)/tst -name "*.tst" -print`

OBJECTSB = $(PKGNAME)/doc/manual.pdf

OBJECTS = $(OBJECTST) $(OBJECTSB)


#############################################################################
##
##  Targets
##
manual: doc/main.xml doc/introduc.xml doc/tutorial.xml doc/interfac.xml \
        doc/atlasrep.xml doc/extend.xml doc/utils.xml doc/technica.xml \
        doc/manualbib.xml
	@( cd doc; echo 'Read( "makedocrel.g" );' \
          | $(GAP) -o 500m -A -N -q > /dev/null )
	@( grep -e "exceeded\|undefined" doc/main.log; exit 0 )

test: manual
	( cd tst; echo 'Read( "testall.g" ); ReadTest( "hardtest.tst" ); \
           Exec( "date -u +../dev/log/test_%Y-%m-%d-%H-%M | \
                  xargs -n 1 cp test.out" ); \
           Exec( "rm test.out" );' \
          | $(GAP) -o 500m -A -N -q > test.out & )

update:
	( cd dev; $(GAP) -A < update.g > /dev/null & )

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
      commb commt
	@( cd ..; \
           chmod 1777 $(PKGNAME)/datagens; \
           chmod 1777 $(PKGNAME)/dataword; \
           echo $(OBJECTST) | xargs -n 1 $(PKGNAME)/commt $(ARCHIVE).zoo; \
           echo $(OBJECTSB) | xargs -n 1 $(PKGNAME)/commb $(ARCHIVE).zoo; \
           zoo PE $(ARCHIVE).zoo )
	rm commt commb
	@( cd ..; tar cvzpf $(ARCHIVE).tar.gz $(OBJECTS) )

clean:
	rm -f ../$(ARCHIVE).zoo ../$(ARCHIVE).tar.gz \
           tst/docxpl.tst
	( cd doc; rm -f \
          chap*.html chap*.txt main.aux main.bbl main.blg main.brf \
          main.idx main.ilg main.ind main.log main.pnr main.tex main.toc \
          manual.dvi manual.lab manual.pdf manual.ps manual.six )

webrefresh: ../atlasrepdata.tar.gz
	@( cd $(HOMEPAGE); \
           if ! ( test -d htm ); then mkdir htm ; fi; \
           if ! ( test -d htm/data ); then mkdir htm/data ; fi \
           if ! ( test -d bibl ); then mkdir bibl; fi )
	@( cp -u htm/data/*.htm $(HOMEPAGE)/htm/data ; \
           cp -u atlasrep.css $(HOMEPAGE) ; \
           cp -u gap/atlasprm.g $(HOMEPAGE) ; \
           cp -u bibl/index.html $(HOMEPAGE)/bibl \
           cp -u bibl/Atlasbib.html $(HOMEPAGE)/bibl \
           cp -u bibl/ABCbibl.html $(HOMEPAGE)/bibl \
           cp -u bibl/Atlas1bib.xml $(HOMEPAGE)/bibl \
           cp -u bibl/Atlas2bib.xml $(HOMEPAGE)/bibl \
           cp -u bibl/ABCbiblbib.xml $(HOMEPAGE)/bibl \
           cp -u bibl/ABCapp2bib.xml $(HOMEPAGE)/bibl \
           cp -u ../atlasrepdata.tar.gz $(HOMEPAGE) )

release: webrefresh \
        index.html atlasrep.css PackageInfo.g README \
        doc/manual.pdf doc/manual.css \
        ../$(ARCHIVE).zoo ../$(ARCHIVE).tar.gz
	( cp index.html atlasrep.css PackageInfo.g README \
          ../$(ARCHIVE).zoo ../$(ARCHIVE).tar.gz \
          $(HOMEPAGE); \
          cp doc/manual.pdf $(HOMEPAGE)/doc \
          cp doc/*.html $(HOMEPAGE)/doc \
          cp doc/*.txt $(HOMEPAGE)/doc \
          cp doc/manual.css $(HOMEPAGE)/doc )


#############################################################################
##
#E

