
GAP=gap

FILES=  dev.xml cvshints.xml documentation.xml pkgdist.xml newcode.xml \
	structure.xml testing.xml todo.xml updates.xml website.xml

default: all

all: manual.pdf

manual.pdf: ${FILES}
	${GAP} makedocrelx.g

clean:
	rm -f chap*.html chap*.txt dev.aux dev.bbl dev.blg dev.brf dev.idx \
	      dev.ilg dev.ind dev.log dev.pnr dev.tex dev.toc \
	      manual.{ps,pdf,dvi,six}
