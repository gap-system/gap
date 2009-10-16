#############################################################################
##
#W  Makefile                    GAP source                       Frank Celler
##
#H  @(#)$Id: Makefile,v 1.2 1997/11/25 16:29:15 frank Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file creates the `configure' scripts using `autoconf'.
##
CC=cc

SOURCE=xcmds utils gapgraph gaptext pty popdial xgap selfile

default: configure.out ../configure

configure.out: configure.in
	autoconf
	sed -e 's%^srcdir=$$%srcdir=../../src.x11%' < configure > configure.out
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
	@echo '# compile and link XGAP' >> Makegap.in
	@echo 'xgap: $$(OBJECTS)' >> Makegap.in
	@echo '	$$(CC) -o xgap $$(OBJECTS) $$(CFLAGS) $$(LDFLAGS) $$(LIBS) $$(X_LIBS) $$(LOPTS)' >> Makegap.in
	@echo >> Makegap.in
	@echo '# dependencies are automatically generated' >> Makegap.in
	@(for i in `eval 'echo $(SOURCE)'`; do \
	    $(CC) -MM -I ../src.x11 ../src.x11/$$i.c; \
	    echo '	$$(CC) -I. $$(CFLAGS) $$(X_CFLAGS) $$(COPTS)' -o $$i.o -c ../src.x11/$$i.c; \
	    echo ; \
          done \
	) | sed -e 's:../src.x11:@srcdir@:g' >> Makegap.in
