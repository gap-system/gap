##############################################################################
##
##    Makefile                      NQ                         Werner Nickel
##
##    $Id: Makefile,v 1.32 2003/10/11 23:08:31 werner Exp $
##

##    GNU cc has the integer data type long long.  It can be used for
##    exponents of words by setting the variable LONGLONG to -DLONGLONG.
LONGLONG = -DLONGLONG

CC=gcc
#OPTS = -g -pg $(LONGLONG) $(COPTS)
OPTS = -O3 $(LONGLONG) $(COPTS)
CFLAGS = $(OPTS) -DVERSION='"2.0 January 2003"'

OBJ = consistency.o pc.o relations.o word.o system.o time.o \
      addgen.o tails.o eliminate.o engel.o glimt.o instances.o \
      presentation.o mem.o pcarith.o collect.o combicol.o trmetab.o gap.o

nq : nq.o $(OBJ)
	$(CC) $(CFLAGS) nq.o $(OBJ) -L$(GNU_MP_LIB) -o nq -lgmp -static

glimt.o: glimt.c
	$(CC) $(CFLAGS) -I$(GNU_MP_INC) -c glimt.c
clean :
	rm -f *.o nq *~

spotless : clean
	rm -f config.h
