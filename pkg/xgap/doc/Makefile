manual: manual.dvi manual.pdf htm tidy

gd: 	../lib/window.g ../lib/gobject.gd ../lib/sheet.gd \
	../lib/sheet.gd ../lib/color.gd ../lib/menu.gd \
	../lib/poset.gd ../lib/font.gd

msk: 		gd gobject.msk posetops.msk xgap.msk usercomm.msk Makefile
	@echo "*** Building TeX files ..."
	../../../etc/buildman.pe -f buildman.config

manual.bbl: 	msk diffgap3.tex graphs.tex install.tex savetime.tex \
		sgrplats.tex sglatsys.tex whatis.tex manual.bib
	@echo "*** Creating bibliography ..."
	tex manual
	bibtex manual

manual.ind: 	*.tex
	@echo "*** Creating index ..."
	tex manual
	../../../doc/manualindex manual

manual.lab: 	*.tex
	@echo "*** Creating manual.lab ..."
	tex manual

manual.toc: 	*.tex
	@echo "*** Creating manual.toc ..."
	tex manual

manual.dvi: 	*.tex manual.bbl manual.ind
	@echo "*** Creating manual.dvi ..."
	tex manual
	tex manual

manual.pdf: 	*.tex manual.bbl manual.ind
	@echo "*** Creating manual.pdf ..."
	pdftex manual
	pdftex manual

manual.ps: 	manual.dvi
	@echo "*** Creating manual.ps ..."
	dvips manual -o

htm: 	manual.dvi manual.bbl manual.lab manual.toc
	@echo "*** Creating HTML version ..."
	mkdir -p ../htm
	../../../etc/convert.pl -t -c -n XGAP . ../htm

tidy:
	@echo "*** Tidying up ..."
	rm -f manual.aux manual.blg manual.idl manual.idx manual.ilg manual.log

clean: 	tidy
	rm -f manual.toc manual.lab manual.ind manual.bbl manual.dvi manual.six

