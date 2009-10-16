#############################################################################
##
#W  Makefile			GAP source			 Frank Celler
##
#H  @(#)$Id: Makefile,v 4.22 2008/04/21 17:02:49 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,	RWTH Aachen,  Germany
##
##  This file creates the `configure' scripts using `autoconf'.
##
CC=cc

SOURCE=\
ariths		blister		bool		c_meths1	c_type1	\
c_oper1         c_filt1   	c_random \
calls		code		compiler	compstat	costab	\
cyclotom	dt		dteval		exprs		finfield\
funcs		gap		gasman		gmpints		gvars	\
integer		intrprtr	listfunc	listoper	lists	\
objcftl		objects		objfgelm	objpcgel	objscoll\
objccoll	opers		permutat	plist		precord	\
range		rational	read		records		saveload\
scanner		sctable		set		stats		streams	\
string		sysfiles	system		tietze		vars	\
vecgf2		vec8bit         vector		vecffe		weakptr	\
iostream	macfloat


default: configure.out ../configure

configure.out: configure.in aclocal.m4 config.hin
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
	@echo '$$(GAPMPI_OBJ)' >> Makegap.in
	@echo >> Makegap.in
	@echo >> Makegap.in
	@echo '# compile and link GAP' >> Makegap.in
	@echo 'gap: $$(OBJECTS) $$(ITANIUMOBJ)' >> Makegap.in
	@echo '	$$(CC)  $$(GMP_CFLAGS) $$(CFLAGS) $$(LDFLAGS) -o gap $$(OBJECTS) $$(ITANIUMOBJ) -lm $$(MPILIBS) $$(EXTOBJS) $$(GMP_LIBS) @LIBS@' >> Makegap.in
	@echo >> Makegap.in
	@echo '# dependencies are automatically generated' >> Makegap.in
	@(for i in `eval 'echo $(SOURCE)'`; do \
	    $(CC) -MM -MG -I .. -DUSE_PRECOMPILED ../src/$$i.c; \
	    echo '	$$(CC) -I. -I../.. -DCONFIG_H $$(GMP_CFLAGS) $$(CFLAGS)' -o $$i.o -c ../src/$$i.c; \
	    echo ; \
	done \
	) | sed -e 's:../src:@srcdir@:g' | sed -e 's:extern:../extern:g' >> Makegap.in
	@cat Makegap.bottom >> Makegap.in
