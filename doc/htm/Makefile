#############################################################################
##
#W  Makefile                    GAP autodoc                  Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
BUILD = ../../etc/convert.pl

default: all

all: ref/chapters.htm ext/chapters.htm tut/chapters.htm prg/chapters.htm

ref/chapters.htm: ../ref/manual.dvi
	$(BUILD) -c ../ref ref

ext/chapters.htm: ../ext/manual.dvi
	$(BUILD) -c ../ext ext

tut/chapters.htm: ../tut/manual.dvi
	$(BUILD) -c ../tut tut

prg/chapters.htm: ../prg/manual.dvi
	$(BUILD) -c ../prg prg

../ref/manual.dvi:
	(cd ../ref;tex manual)

../ext/manual.dvi:
	(cd ../ext;tex manual)

../tut/manual.dvi:
	(cd ../tut;tex manual)

../prg/manual.dvi:
	(cd ../prg;tex manual)

