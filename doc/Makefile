#############################################################################
##
#W  Makefile                    GAP autodoc                  Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##

default: all

all: ref/manual.dvi prg/manual.dvi tut/manual.dvi ext/manual.dvi ._htm \
	build/._all
	echo "The Makefile is obsolete. Call 'make_doc'".

build/._all: \
	build/config.alg build/config.coll build/config.groups build/config.grplib \
	build/config.grppc build/config.linalg build/config.mapping \
	build/config.number build/config.oper build/config.ratfun build/config.rings \
	build/algebra.msk build/alglie.msk build/blist.msk build/boolean.msk \
	build/coll.msk build/combinat.msk build/cyclotom.msk build/domain.msk \
	build/fieldfin.msk build/fields.msk build/groups.msk build/grpfp.msk \
	build/grphomom.msk build/grplib.msk build/grpoper.msk build/grppc.msk \
	build/grpperm.msk build/grpprod.msk build/integers.msk build/lists.msk \
	build/mapping.msk build/matint.msk build/matrix.msk build/module.msk \
	build/numtheor.msk build/padics.msk build/permutat.msk \
	build/ratfun.msk build/record.msk build/rings.msk build/string.msk \
	build/vector.msk build/vspc.msk
	(cd build;make all)

ref/manual.dvi: build/._all
	(cd ref;bibtex manual;tex manual)

prg/manual.dvi:
	(cd prg;tex manual;bibtex manual;tex manual)

tut/manual.dvi:
	(cd tut;tex manual;bibtex manual;tex manual)

ext/manual.dvi:
	(cd ext;tex manual;bibtex manual;tex manual)

._htm: ref/manual.dvi prg/manual.dvi tut/manual.dvi ext/manual.dvi
	(cd htm; make all)
	touch ._htm
