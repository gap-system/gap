#########################################################################
##
#W  Makefile              GAP documentation                  Bettina Eick
##
DOCU := $(shell grep Input manual.tex | sed 's:\\Input{\([a-z]*\)}:\1.tex:')

AUXFILES = manual.bbl manual.idx manual.blg manual.lab \
	   manual.aux manual.log manual.ind manual.ilg

MANUALINDEX = ../../../doc/manualindex 
CONVERT = ../../../etc/convert.pl 


all: manual.dvi manual.ps manual.pdf html

html: manual.dvi
	mkdir -p ../htm
	echo "Creating HTML documentation"
	$(CONVERT) -c -n Polycyclic . ../htm

manual.dvi: manual.tex finlie.bib $(DOCU)
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

