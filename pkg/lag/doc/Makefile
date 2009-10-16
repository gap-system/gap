manual: manual.dvi manual.pdf htm tidy

lag.tex: 	lag.msk ../lib/lag.gd ../lib/lag.gi config.lag Makefile
	@echo "*** Building TeX file ..."
	../../../etc/buildman.pe -f config.lag

manual.bbl: 	lag.tex manual.bib
	@echo "*** Creating bibliography ..."
	tex manual
	bibtex manual

manual.ind: 	lag.tex
	@echo "*** Creating index ..."
	tex manual
	../../../doc/manualindex manual

manual.lab: 	lag.tex manual.tex
	@echo "*** Creating manual.lab ..."
	tex manual

manual.toc: 	lag.tex manual.tex
	@echo "*** Creating manual.toc ..."
	tex manual

manual.dvi: 	lag.tex manual.tex manual.bbl manual.ind
	@echo "*** Creating manual.dvi ..."
	tex manual
	tex manual

manual.pdf: 	lag.tex manual.tex manual.bbl manual.ind
	@echo "*** Creating manual.pdf ..."
	pdftex manual
	pdftex manual

manual.ps: 	manual.dvi
	@echo "*** Creating manual.ps ..."
	dvips manual -o

htm: 	manual.dvi manual.bbl manual.lab manual.toc
	@echo "*** Creating HTML version ..."
	mkdir -p ../htm
	../../../etc/convert.pl -t -c -n LAG . ../htm

tidy:
	@echo "*** Tidying up ..."
	rm -f manual.aux manual.blg manual.idl manual.idx manual.ilg manual.log

clean: 	tidy
	rm -f manual.toc manual.lab manual.ind manual.bbl manual.dvi manual.six

