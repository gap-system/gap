#############################################################################
##
#W  Makefile                    GAP source                       Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file creates the `configure' scripts using `autoconf'.
##
CC=cc

SOURCE=\
ariths		blister		bool		c_methse	c_type	\
calls		code		compiler	compstat	costab	\
cyclotom	dt		dteval		exprs		finfield\
funcs		gap		gasman		gvars		integer	\
intrprtr	listfunc	listoper	lists		objcftl	\
objects		objfgelm	objpcgel	objscoll	opers	\
permutat	plist		precord		range		rational\
read		records		saveload	scanner		sctable	\
set		stats		streams		string		sysfiles\
system		tietze		vars		vecgf2		vector	\
weakptr


default: configure.out ../configure

configure.out: configure.in aclocal.m4
	autoconf
	sed -e 's%^srcdir=$$%srcdir=../../src%' < configure > configure.out
	chmod 755 configure.out
	rm configure

../configure: ../configure.in
	( cd .. ; autoconf )

Makegap.in: AlwaysMakegap.in

AlwaysMakegap.in:
	@echo "creating 'Makegap.in'"
	@cp Makegap.top Makegap.in
	@echo >> Makegap.in
	@echo '# OBJECTS are generated from SOURCE' >> Makegap.in
	@echo -n "OBJECTS=" >> Makegap.in
	@eval 'for i in $(SOURCE); do echo -n "$$i.o "; done' >> Makegap.in
	@echo >> Makegap.in
	@echo >> Makegap.in
	@echo '# compile and link GAP' >> Makegap.in
	@echo 'gap: $$(OBJECTS)' >> Makegap.in
	@echo '	$$(CC) $$(CFLAGS) $$(LDFLAGS) -o gap $$(OBJECTS) @LIBS@' >> Makegap.in
	@echo >> Makegap.in
	@echo '# dependencies are automatically generated' >> Makegap.in
	@(for i in `eval 'echo $(SOURCE)'`; do \
	    $(CC) -MM -I ../src -DUSE_PRECOMPILED ../src/$$i.c; \
	    echo '	$$(CC) -I. -DCONFIG_H $$(CFLAGS)' -o $$i.o -c ../src/$$i.c; \
	    echo ; \
          done \
	) | sed -e 's:../src:@srcdir@:g' >> Makegap.in
