#########################################################################
##
#W  Makefile              GAP documentation                Heiko Dietrich 
##
#H  $Id: Makefile,v 1.1 2007/05/08 07:47:21 gap Exp $
##

##
##  Extract the chapter files from manual.tex by taking lines containing
##  the string 'Input' and stripping off everything except the filename.
##
DOCU := $(shell grep Input manual.tex | sed 's:\\Input{\([a-z]*\)}:\1.tex:')

AUXFILES = manual.bbl manual.idx manual.blg manual.lab \
	   manual.aux manual.log manual.ind manual.ilg \
	   manual.toc

MANUALINDEX = ../../../doc/manualindex 
CONVERT = ../../../etc/convert.pl 

all: manual.dvi manual.ps manual.pdf html

html: manual.dvi
	mkdir -p ../htm
	echo "Creating HTML documentation"
	$(CONVERT) -c -n cubefree . ../htm

manual.dvi: manual.tex manual.bib $(DOCU)
	tex manual
	bibtex manual
	tex manual
	tex manual
	$(MANUALINDEX) manual
	tex manual
	@echo 
	@echo Processed chapters:
	@echo $(DOCU)
	@echo 

manual.pdf: manual.dvi
	pdftex manual.tex
	pdftex manual.tex

manual.ps: manual.dvi
	dvips -D300 -o manual.ps manual

clean:
	rm -f $(AUXFILES)
	rm -f *~

spotless: clean
	rm -rf ../htm manual.dvi manual.ps manual.pdf manual.six

