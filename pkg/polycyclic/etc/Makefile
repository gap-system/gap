#########################################################################
##
#W  Makefile                  Polycyclic                     Bettina Eick
#W                                                          Werner Nickel
##
#H  $Id: Makefile,v 1.18 2007/06/22 15:42:50 werner Exp $
##

WEBDIR   = /www/homepages/nickel/software/polycyclic

AUXFILES = manual.bbl manual.idx manual.blg manual.lab \
	   manual.aux manual.log manual.ind manual.ilg

OBSOLETE_DIRS = polycyclic/kant polycyclic/html polycyclic/cohom \
		polycyclic/gap/matgrp polycyclic/gap/misc	


##  current version
CURVER=2.2

default:
	@echo 'make submitted: checkout the submitted version and create the archives'
	@echo 'make webpages:  make the webpages on my machine'
	@echo 'make pre-release-2: checkout the second pre release and create the archives'
	@echo 'make pre-release-1: checkout the first pre release and create the archives'
	@echo 'make clean:         remove archives and temporarily checked out copies'


webpages: clean $(CURVER)
	# Copy everything into the web directory
	cp polycyclic/etc/index.html polycyclic/etc/style.css $(WEBDIR)

	cp polycyclic-$(CURVER).tar    $(WEBDIR)/polycyclic-$(CURVER).tar
	cp polycyclic-$(CURVER).tar.gz $(WEBDIR)/polycyclic-$(CURVER).tar.gz
	cp polycyclic/doc/manual.ps    $(WEBDIR)/polycyclic-manual.ps
	cp polycyclic/doc/manual.pdf   $(WEBDIR)/polycyclic-manual.pdf
	cp polycyclic/doc/manual.six   $(WEBDIR)/polycyclic-manual.six
	rm -rf $(WEBDIR)/polycyclic-htm
	cp -r polycyclic/htm           $(WEBDIR)/polycyclic-htm

	cp polycyclic/README           $(WEBDIR)/README
	cp polycyclic/PackageInfo.g    $(WEBDIR)/PackageInfo.g

	cp alnuth-1.0.tar              $(WEBDIR)/alnuth-1.0.tar
	cp alnuth-1.0.tar.gz           $(WEBDIR)/alnuth-1.0.tar.gz 
	cp alnuth/doc/manual.ps        $(WEBDIR)/alnuth-manual.ps
	cp alnuth/doc/manual.pdf       $(WEBDIR)/alnuth-manual.pdf
	rm -rf $(WEBDIR)/alnuth-htm
	cp -r alnuth/htm               $(WEBDIR)/alnuth-htm

	@echo '    Remember to make braunschweig !!'

2.2:
	cvs export -D 'June 22, 2007 18:00' -d polycyclic GAP/4.0/pkg/polycyclic;

	find polycyclic -name .cvsignore | xargs rm -f
	rm -fr $(OBSOLETE_DIRS)

	# Make the polycyclic manuals.  We have to move the doc directory
	# to the right place in order to cope with all those hard coded
	# path names. 
	mv polycyclic/doc ../doc-aux; 
	cd ../doc-aux; make spotless; make all; make clean; 
	mv ../doc-aux polycyclic/doc
	mv ../htm polycyclic/htm

	# Prepare the archives
	tar cf polycyclic-$(CURVER).tar polycyclic
	gzip < polycyclic-$(CURVER).tar > polycyclic-$(CURVER).tar.gz

	cvs export -D now -d alnuth GAP/4.0/pkg/alnuth

	# Make the AlNuTh manuals.    We have to move the doc directory
	# to the right place in order to cope with all those hard coded
	# path names. 
	mv alnuth/doc ../doc-aux; 
	cd ../doc-aux; make_doc
	mv ../doc-aux alnuth/doc
	mv ../htm alnuth/htm


	# Prepare the archives
	tar cf alnuth-1.0.tar alnuth
	gzip < alnuth-1.0.tar > alnuth-1.0.tar.gz


submitted: clean
	cvs export -D 'June 27, 2003 18:00' -d polycyclic GAP/4.0/pkg/polycyclic

	find polycyclic -name .cvsignore | xargs rm -f
	rm -fr polycyclic/kant polycyclic/cohom polycyclic/gap/matgrp polycyclic/gap/misc

	# Make the manuals
	cd polycyclic/doc; make spotless; make all; make clean

	# Prepare the archives
	tar cf polycyclic.tar polycyclic
	gzip < polycyclic.tar > polycyclic.tar.gz
	find polycyclic -type f | xargs zoo ah polycyclic.zoo

	cvs export -D 'June 27, 2003 18:00' -d kant GAP/4.0/pkg/kant

	# Make the KANT manuals
	cd kant/doc; tex manual; bibtex manual; tex manual; ../../../doc/manualindex manual; tex manual
	cd kant/doc; dvips  manual
	cd kant/doc; pdftex manual
	cd kant/doc; rm -f $(AUXFILES)

	tar cf kant.tar kant
	gzip < kant.tar > kant.tgz
	find kant -type f | xargs zoo ah kant.zoo 


pre-release-1: 
	cvs export -D 'April 18, 2000 0:00' -d polycyclic GAP/4.0/pkg/polycyclic

	find polycyclic -name .cvsignore -exec rm "{}" ";"
	rm -r polycyclic/kant polycyclic/gap/matgrp
	egrep -v '^matgrp|^misc' polycyclic/gap/README > /tmp/README
	mv /tmp/README polycyclic/gap/README
	egrep -v 'matgrp' polycyclic/read.g > /tmp/read.g
	mv /tmp/read.g polycyclic/read.g

	rm -f polycyclic.zoo polycyclic.tgz polycyclic.tar
	tar cf polycyclic.tar polycyclic
	find polycyclic -type f -exec zoo ah polycyclic.zoo "{}" ";"
	gzip < polycyclic.tar > polycyclic.tgz

pre-release-2: 
	cvs export -D 'December 1, 2000 0:00' -d polycyclic GAP/4.0/pkg/polycyclic

	find polycyclic -name .cvsignore -exec rm "{}" ";"
	rm -r polycyclic/kant polycyclic/gap/matgrp
	egrep -v '^matgrp|^misc' polycyclic/gap/README > /tmp/README
	mv /tmp/README polycyclic/gap/README
	egrep -v 'matgrp' polycyclic/read.g > /tmp/read.g
	mv /tmp/read.g polycyclic/read.g

	rm -f polycyclic.zoo polycyclic.tgz polycyclic.tar
	tar cf polycyclic.tar polycyclic
	find polycyclic -type f -exec zoo ah polycyclic.zoo "{}" ";"
	gzip < polycyclic.tar > polycyclic.tgz

clean:
	rm -fr polycyclic alnuth    
	rm -fr polycyclic-$(CURVER).tar.gz polycyclic-$(CURVER).tar 
	rm -fr alnuth-1.0.tar.gz alnuth-1.0.tar     

