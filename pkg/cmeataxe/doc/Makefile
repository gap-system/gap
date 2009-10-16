manual: manual.dvi

manual.dvi: 	cmeataxe.msk \
		manual.bib Makefile
	../../../etc/buildman.pe -f buildman.config
	tex manual
	bibtex manual
	tex manual
	../../../doc/manualindex manual
	tex manual
	tex manual
	dvips -D300 manual -o manual.ps

clean:
	rm -f cmeataxe.tex manual.aux manual.bbl \
        manual.blg manual.dvi manual.idl manual.idx manual.ilg manual.ind \
        manual.lab manual.log manual.ps manual.six manual.toc

