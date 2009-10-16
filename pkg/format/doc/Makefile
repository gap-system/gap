manual: manual.dvi

manual.dvi:	cover.tex examples.tex forms.tex gapmacro.tex intro.tex \
                manual.bbl manual.tex norm.tex resid.tex \
                addresses.tex others.tex \
                Makefile
	tex manual
	makeindex manual
	tex manual
