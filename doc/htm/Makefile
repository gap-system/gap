#############################################################################
##
#W  Makefile                    GAP autodoc                  Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
##
BUILD = ../../etc/convert.pl -u
BUILDIE = ../../etc/convert.pl -t

default: all

all: ref/chapters.htm ext/chapters.htm tut/chapters.htm prg/chapters.htm new/chapters.htm\
	theindex.htm

ref/chapters.htm: ../ref/manual.dvi ../../etc/convert.pl
	$(BUILD) -c ../ref ref

ext/chapters.htm: ../ext/manual.dvi ../../etc/convert.pl
	$(BUILD) -c ../ext ext

tut/chapters.htm: ../tut/manual.dvi ../../etc/convert.pl
	$(BUILD) -c ../tut tut

prg/chapters.htm: ../prg/manual.dvi ../../etc/convert.pl
	$(BUILD) -c ../prg prg

new/chapters.htm: ../new/manual.dvi ../../etc/convert.pl
	$(BUILD) -c ../new new

theindex.htm: ref/chapters.htm tut/chapters.htm ext/chapters.htm \
	prg/chapters.htm new/chapters.htm ../../etc/convert.pl
	chmod 755 allhtmlindex
	chmod 755 onehtmlindex
	./allhtmlindex

../ref/manual.dvi:
	(cd ../ref;tex manual)

../ext/manual.dvi:
	(cd ../ext;tex manual)

../tut/manual.dvi:
	(cd ../tut;tex manual)

../prg/manual.dvi:
	(cd ../prg;tex manual)

../new/manual.dvi:
	(cd ../new;tex manual)

ieversion: ../tut/manual.dvi ../ref/manual.dvi ../ext/manual.dvi ../prg/manual.dvi ../new/manual.dvi
	$(BUILDIE) -c ../tut tut
	$(BUILDIE) -c ../ref ref
	$(BUILDIE) -c ../ext ext
	$(BUILDIE) -c ../prg prg
	$(BUILDIE) -c ../new new
	./allhtmlindex

clean:
	rm -f indx*.htm ref/*.htm tut/*.htm prg/*.htm ext/*.htm new/*.htm



