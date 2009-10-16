
GAP=gap4

gapdoc:
	@echo 'RequirePackage("gapdoc"); MakeGAPDocDoc( "./", "nqman", [], "nq" );;' | $(GAP) -q -T

clean:
	@rm -f nqman.aux nqman.bbl nqman.blg nqman.idx nqman.ilg nqman.ind\
	   nqman.log nqman.pnr nqman.tex nqman.toc nqman.brf
	@rm -f *~
	@rm -f test/nqman.tst test/diffs

spotless: clean
	@rm -f manual.dvi manual.html manual.pdf manual.ps manual.six
	@rm -f chap*.html chap*.txt
