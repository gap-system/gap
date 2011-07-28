CC=gcc
CFLAGS=-g $(COPTS)
# CFLAGS=-DDEBUG -O0 -g
#May be needed for Solaris:
# LIBS= -lsocket -lnsl

RANLIB=ranlib

LIBOBJS=mpi.o master.o parse.o cmd.o slave.o utils.o sendrecv.o spawn2.o
LIBOBJS=mpi.o master.o parse.o cmd.o slave.o utils.o sendrecv.o \
	send-nonblock.o recv-cache.o

execute: hello_mpi
	./hello_mpi

# Under solaris, end-user application will need:  libmpi.a -lsocket -lnsl -lrt
libmpi.a: ${LIBOBJS}
	rm -f libmpi.a
	if ( uname | grep "IRIX64" > /dev/null ) ; then \
	      ar -crs libmpi.a ${LIBOBJS} ${ARLIBS}; \
	else \
	      ar qc libmpi.a ${LIBOBJS} ${ARLIBS}; \
	fi
	- ${RANLIB} libmpi.a


hello_mpi: hello_mpi.o libmpi.a
	if ( uname -sr | grep "SunOS 5" > /dev/null ) && \
	    [ "x${LIBS}" = "x" ] ; then \
	      make LIBS="-lsocket -lnsl -lrt -lpthread" hello_mpi; \
	elif \
	    [ "x${LIBS}" = "x" ] ; then \
	      make LIBS="-lpthread" hello_mpi; \
	else \
	  ${CC} -o hello_mpi -O0 -g hello_mpi.o libmpi.a ${LIBS}; \
	fi

dist:
	dir=./`basename $$PWD`; cd ..; \
	  tar cvf $$dir/mpinu.tar \
	  $$dir/*.[ch] \
	  $$dir/procgroup \
	  $$dir/README \
	  $$dir/INTERNALS \
	  $$dir/Makefile
dist-all:
	dir=./`basename $$PWD`; cd .. ; \
	  echo ${PWD} $$PWD $$dir ; \
	  rm -f $$dir/mpinu.tar* $$dir/mpinu-all.tar* ; \
	  tar cvf $$dir/mpinu-all.tar $$dir/* ; \
	  gzip $$dir/mpinu-all.tar

clean:
	rm -f *.o libmpi.a core hello_mpi checkpoint
