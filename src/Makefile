#############################################################################
##
#W  Makefile                    GAP source                   Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the definitions and actions to compile and  link  GAP.
##
##  To compile and link GAP you simply enter
##
##      make
##
##  for a list of targets  of the form  '<vendor>-<cpu>-<system>-<compiler>',
##  such as 'sun-sparc-sunos-gcc2',  which is the target for a Sun 4  machine
##  running the SunOS operating system with the GNU C compiler version 2.
##
##  Choose the best matching target and enter
##
##      make  <target>
##
##  e.g., enter 'make sun-sparc-sunos-gcc2',  to compile all the source files
##  and produce an executable file 'gap'.
##
##  Note  that  the  targets  are  listed  according  to   preference,  e.g.,
##  'sun-sparc-sunos-gcc2' is listed before 'sun-sparc-sunos-cc' because  the
##  GNU  C compiler produces faster code on Sun 4 machines than native 'cc'.
##
##  If no target matches precisely, use 'bsd' (if  your UNIX is more Berkely)
##  or 'usg' (if your UNIX is more  System  V).   If compilation  of the file
##  'system.c'  fails or  the command line editing does not work,  remove the
##  file 'system.o' and try the other target.
##
##  To specify additional compiler and linker options enter
##
##      make  <target>  COPTS=<compiler-options>  LOPTS=<linker-options>
##
##  e.g., enter 'make sun-sparc-sunos-gcc2 COPTS=-g LOPTS=-g' to compile  GAP
##  with debugging information.
##
##  To compile  GAP on a  DOS machine you need DJGPP version 1.11m5 or higher
##  (available from     'ftp.informatik.rwth-aachen.de').    DJGPP    must be
##  installed in  the directory '\DJGPP\',  because the  linkage script looks
##  for the DOS extender 'GO32.EXE' in  '\DJGPP\BIN\'.  If you have installed
##  DJGPP differently you have to change this below.
##
##  To compile GAP on an  IBM PC compatible under  OS/2 you must comment  out
##  the line 'SHELL = /bin/sh' below.
##
SHELL = /bin/sh


#############################################################################
##

#F  Targets . . . . .  targets of the form <vendor>-<cpu>-<system>-<compiler>
##
##  Following are the targets that the user can specify.
##
##  Each target first changes to the appropriate  object  files  subdirectory
##  '../bin/<vendor>-<cpu>-<system>/' (and creates this directory if needed).
##  Then it calls 'make' recursively, passing the system dependent  flags  in
##  'LFLAGS' (for the linker),  'CFLAGS' (for the compiler for all packages),
##  'CFLAGS_SIG' (for 'system' and 'stats'), and 'CFLAGS_SYS' (for 'system').
##
unknown:
	@echo "usage: 'make <target>' where target is one of"
	@echo "'dec-alpha-OSF32-gcc2'      for DECalpha under OSF 3.2 with GNU cc 2"
	@echo "'dec-mips-ultrix-cc'        for DECstation under Ultrix with cc"
	@echo "'hp-hppa1.1-hpux-gcc2'      for HP9000 under HP-UX with GNU cc 2"
	@echo "'ibm-i386-freebsd2.0-gcc2'  for IBM PC under FreeBSD 2.x with GNU cc 2"
	@echo "                            (GNU cc 2.6 comes with FreeBSD 2.0)"
	@echo "'ibm-i386-linux-gcc2'       for IBM PC under Linux with GNU cc 2"
	@echo "'ibm-i386-nextstep-cc'      for IBM PC under NeXTSTEP 3.x with GNU cc 2"
	@echo "                            (GNU cc 2.5.8 comes with NeXTSTEP 3.3)"
	@echo "'sun-sparc-sunos-gcc2'      fur Sun Sparc under SunOS with GCC 2"
	@echo "'sun-sparc-solaris-gcc2'    fur Sun Sparc under Solaris with GCC 2"
	@echo ""
	@echo "  targets are listed according to preference, i.e.,"
	@echo "    'sun-sparc-sunos-gcc2' is better than 'sun-sparc-sunos-cc'."
	@echo ""
	@echo "  additional C compiler and linker flags can be passed with"
	@echo "    'make <target> COPTS=<compiler-opts> LOPTS=<linker-opts>',"
	@echo "    i.e., 'make sun-sparc-sunos-gcc2 COPTS=-g LOPTS=-g.'"


#############################################################################
##

#F  dec-alpha-OSF32-gcc2
##
##
##  For the DEC alpha  we have to pass  the SYS_IS_64BIT define to all files,
##  not just system.c,  as it  effects  the types in  system.h otherwise it's
##  pretty standard
##
dec-alpha-OSF32-gcc2:
	@(if test ! -d ../bin; then mkdir ../bin; fi; \
	  cd ../bin; \
	  if test ! -d dec-alpha-OSF32; then \
		mkdir dec-alpha-OSF32; \
          fi; \
	  cd dec-alpha-OSF32; \
	  $(MAKE) -f ../../src/Makefile gap \
	    SRC="../../src" \
	    CC="cc" \
	    LFLAGS="$(LOPTS)" \
	    CFLAGS="$(COPTS) -O2 -DSYS_IS_64BIT" \
	    CFLAGS_SIG="-DSYS_HAS_SIGNALS" \
	    CFLAGS_SYS="$(COPTS) -DSYS_IS_BSD -DSYS_HAS_STACK_ALIGN=4 \
	               -DSYS_HAS_ANSI=1" )


#############################################################################
##
#F  dec-mips-ultrix-cc
##
##  Ultrix 4.2 is a almost ANSI (but does not support 'const')
##
dec-mips-ultrix-cc:
	@(if test ! -d ../bin; then mkdir ../bin; fi; \
	  cd ../bin; \
	  if test ! -d dec-mips-ultrix; then \
	      mkdir dec-mips-ultrix; \
	  fi; \
	  cd dec-mips-ultrix; \
	  $(MAKE) -f ../../src/Makefile gap \
	    SRC="../../src" \
	    CC="cc" \
	    LFLAGS="$(LOPTS)" \
	    CFLAGS="$(COPTS) -O2 -Olimit 1000" \
	    CFLAGS_SIG="-DSYS_HAS_SIGNALS" \
	    CFLAGS_SYS="$(COPTS) -DSYS_IS_BSD -DSYS_HAS_STACK_ALIGN=4 \
	               -DSYS_HAS_ANSI=1" )


#############################################################################
##
#F  hp-hppa1.1-hpux-gcc2
##
##  HP-UX is almost ANSI
## 'sys/times.h' claims 'times' returns 'clock_t' (how shall it return -1?)
##
hp-hppa1.1-hpux-gcc2:
	@(if test ! -d ../bin; then mkdir ../bin; fi; \
	  cd ../bin; \
	  if test ! -d hp-hppa1.1-hpux; then \
		mkdir hp-hppa1.1-hpux; \
          fi; \
	  cd hp-hppa1.1-hpux; \
	  $(MAKE) -f ../../src/Makefile gap \
	    SRC="../../src" \
	    CC="gcc" \
	    LFLAGS="$(LOPTS)" \
	    CFLAGS="$(COPTS) -O2" \
	    CFLAGS_SIG="-DSYS_HAS_SIGNALS" \
	    CFLAGS_SYS="$(COPTS) -DSYS_IS_USG -DSYS_HAS_STACK_ALIGN=4 \
	               -DSYS_HAS_ANSI=1 -DSYS_HAS_CONST=const \
	               -DSYS_HAS_STDIO_PROTO -DSYS_HAS_READ_PROTO \
	               -DSYS_HAS_IOCTL_PROTO -DSYS_HAS_SIGNAL_PROTO \
	               -DSYS_HAS_TIME_PROTO  -DSYS_HAS_MISC_PROTO" )


#############################################################################
##
#F  ibm-i386-freebsd2.0-gcc2
##
##  'stdio.h' claims 'fgets' has second argument 'size_t' (ANSI says 'int')
##  'unistd.h' claims 'read' has third argument 'size_t' (UNIX says 'int')
##  'sys/ioctl.h' claims 'ioctl' has third argument '...' (UNIX says 'char*')
##  'sys/signal.h' claims 'kill' has first argument 'pid_t' (UNIX says 'int')
##
ibm-i386-freebsd2.0-gcc2:
	@(if test ! -d ../bin; then mkdir ../bin; fi; \
	  cd ../bin; \
	  if test ! -d ibm-i386-freebsd2.0; then \
	      mkdir ibm-i386-freebsd2.0; \
	  fi; \
	  cd ibm-i386-freebsd2.0; \
	  $(MAKE) -f ../../src/Makefile gap \
	    SRC="../../src" \
	    CC="gcc -ansi -Wall -g" \
	    LFLAGS="$(LOPTS)" \
	    CFLAGS="$(COPTS) -O2" \
	    CFLAGS_SIG="-DSYS_HAS_SIGNALS" \
	    CFLAGS_SYS="$(COPTS) -DSYS_IS_BSD -DSYS_HAS_STACK_ALIGN=2 \
	               -DSYS_HAS_STDIO_PROTO -DSYS_HAS_READ_PROTO \
	               -DSYS_HAS_IOCTL_PROTO -DSYS_HAS_SIGNAL_PROTO" )


#############################################################################
##
#F  ibm-i386-linux-gcc2
##
##  Linux with GNU CC version 2.x.y
##
##  'stdio.h' claims 'fgets' has second argument 'size_t' (ANSI says 'int')
##  'unistd.h' claims 'read' has third argument 'size_t' (UNIX says 'int')
##  'unistd.h' has 'sbrk' with argument 'ptrdiff_t'
##  -D_POSIX_SOURCE is needed to prevent -ansi losing 'popen', 'pclose',
##   and 'fileno'
##  'sys/signal.h' claims 'kill' has first argument 'pid_t' (UNIX says 'int')
##  'sys/times.h' claims 'times' has return value 'clock_t'
##
ibm-i386-linux-gcc2:
	@(if test ! -d ../bin; then mkdir ../bin; fi; \
	  cd ../bin; \
	  if test ! -d ibm-i386-linux; then \
		mkdir ibm-i386-linux; \
	  fi; \
	  cd ibm-i386-linux; \
	  $(MAKE) -f ../../src/Makefile gap \
	    SRC="../../src" \
	    CC="gcc -ansi -Wall -g" \
	    LFLAGS="$(LOPTS)" \
	    CFLAGS="$(COPTS) -O2" \
	    CFLAGS_SIG="-DSYS_HAS_SIGNALS" \
	    CFLAGS_SYS="$(COPTS) -DSYS_IS_USG -DSYS_HAS_STACK_ALIGN=2 \
	               -DSYS_HAS_STDIO_PROTO -DSYS_HAS_READ_PROTO \
		       -DSYS_HAS_MISC_PROTO  -D_POSIX_SOURCE \
	               -DSYS_HAS_SIGNAL_PROTO -DSYS_HAS_TIME_PROTO" )


#############################################################################
##
#F  ibm-i386-nextstep-cc
##
ibm-i386-nextstep-cc: next-i386-nextstep-cc



#############################################################################
##
#F  next-any-nextstep-cc
##
##  NeXTSTEP 3.3 with compiler
##  "NeXT Computer, Inc. version cc-437.2.6, gcc version 2.5.8"
##
next-any-nextstep-cc:
	@(if test ! -d ../bin; then mkdir ../bin; fi; \
	  cd ../bin; \
	  if test ! -d next-$(ADIR)-nextstep$(EXTDIR);  then \
	      mkdir next-$(ADIR)-nextstep$(EXTDIR); \
	  fi; \
	  cd next-$(ADIR)-nextstep$(EXTDIR); \
	  $(MAKE) -f ../../src/Makefile gap \
	    SRC="../../src" \
	    CC="cc -g" \
	    LFLAGS="$(LOPTS) $(ARCH)" \
	    CFLAGS="$(COPTS) -DCOUNT_BAGS -O2 $(ARCH)" \
	    CFLAGS_SIG="-DSYS_HAS_SIGNALS" \
	    CFLAGS_SYS="$(COPTS) -DSYS_IS_MACH -DSYS_HAS_STACK_ALIGN=4 \
	      -DSYS_HAS_ANSI=1 -D_POSIX_SOURCE -DSYS_HAS_READ_PROTO \
	      $(ARCH)" )

next-i386-nextstep-cc:
	$(MAKE) -f Makefile next-any-nextstep-cc \
		COPTS="$(COPTS)" LOPTS="$(LOPTS)" \
		ARCH="-arch i386"  \
		ADIR="i386"

next-m68k-nextstep-cc:
	$(MAKE) -f Makefile next-any-nextstep-cc \
		COPTS="$(COPTS)" LOPTS="$(LOPTS)" \
		ARCH="-arch m68k"  \
		ADIR="m68k"

next-i386m68k-nextstep-cc:
	$(MAKE) -f Makefile next-any-nextstep-cc \
		COPTS="$(COPTS)" LOPTS="$(LOPTS)" \
		ARCH="-arch i386 -arch m68k"  \
		ADIR="i386m68k"

next-i386-nextstep-cc-prof:
	$(MAKE) -f Makefile next-any-nextstep-cc \
		COPTS="$(COPTS) -pg" LOPTS="$(LOPTS) -pg" \
		ARCH="-arch i386"  \
		ADIR="i386" EXTDIR="-prof"


#############################################################################
##
#F  sun-sparc-solaris-gcc2
##
##  From: Burkhard.Hofling@maths.anu.edu.au (Burkhard Hofling)
##
sun-sparc-solaris-gcc2:
	@(if test ! -d ../bin; then mkdir ../bin; fi; \
	  cd ../bin; \
	  if test ! -d sun-sparc-solaris-gcc2; then \
		mkdir sun-sparc-solaris-gcc2; \
	  fi; \
	  cd sun-sparc-solaris-gcc2; \
	  $(MAKE) -f ../../src/Makefile gap \
            SRC="../../src" \
	    CC="gcc" \
	    LFLAGS="$(LOPTS)" \
	    CFLAGS="$(COPTS) -DSPARC -O2" \
	    CFLAGS_SIG="-DSYS_HAS_SIGNALS" \
	    CFLAGS_SYS="$(COPTS) -DSYS_IS_USG -DSYS_HAS_TIME_PROTO \
                       -DSYS_HAS_IOCTL_PROTO -DSYS_HAS_STDIO_PROTO \
                       -DSYS_HAS_ANSI=1 -DSYS_HAS_CONST=const \
                       -DSYS_HAS_MISC_PROTO\
                       -DSYS_HAS_READ_PROTO -DSYS_HAS_SIGNAL_PROTO" )


#############################################################################
##
#F  sun-sparc-sunos-gcc2
##
##  From: Burkhard.Hofling@maths.anu.edu.au (Burkhard Hofling)
##
sun-sparc-sunos-gcc2:
	@(if test ! -d ../bin; then mkdir ../bin; fi; \
	  cd ../bin; \
	  if test ! -d sun-sparc-sunos-gcc2; then \
		mkdir sun-sparc-sunos-gcc2; \
          fi; \
	  cd sun-sparc-sunos-gcc2; \
	  $(MAKE) -f ../../src/Makefile gap \
            SRC="../../src" \
	    CC="gcc" \
	    LFLAGS="$(LOPTS)" \
	    CFLAGS="$(COPTS) -O2" \
	    CFLAGS_SIG="-DSYS_HAS_SIGNALS" \
	    CFLAGS_SYS="$(COPTS) -DSYS_IS_USG -DSYS_HAS_TIME_PROTO \
                       -DSYS_HAS_READ_PROTO -DSYS_HAS_SIGNAL_PROTO" )


#############################################################################
##

#F  Linkage . . . . . . . . . . . . . . . . . . . . . .  commands to link GAP
##
##  Following are the commands to link GAP.  The targets below should not  be
##  used directly, they should only be addressed by the  recursive  calls  of
##  'make' from above.
##
OBJECTS =   system.o   scanner.o  gasman.o         \
	    objects.o  gvars.o                     \
	    calls.o    opers.o                     \
	    ariths.o   records.o  lists.o          \
	    bool.o                                 \
	    integer.o  rational.o cyclotom.o       \
	    finfield.o permutat.o                  \
	    precord.o                              \
	    listfunc.o listoper.o                  \
	    plist.o    set.o      vector.o         \
	    blister.o  range.o    string.o         \
            objfgelm.o objscoll.o objpcgel.o       \
            sctable.o  costab.o                    \
	    dt.o       dteval.o                    \
            objcftl.o                              \
	    code.o     vars.o                      \
	    exprs.o    stats.o    funcs.o          \
	    intrprtr.o read.o     gap.o

gap:        $(OBJECTS)
	$(CC) $(LFLAGS)     -o gap              $(OBJECTS)


#############################################################################
##
#F  Compilations  . . . . . . . . . . .  compilations of the various packages
##
##  Following are the dependencies between the various packages of  GAP,  and
##  the commands needed to compile them (those must  be  given,  because  the
##  implicit rules work only if the source is in the same directory).
##
system.o:   $(SRC)/system.c   $(SRC)/system.h
	$(CC) $(CFLAGS_SYS) $(CFLAGS_SIG)  -o system.o      -c $(SRC)/system.c

scanner.o:  $(SRC)/scanner.c  $(SRC)/scanner.h                          \
	    $(SRC)/system.h
	$(CC) $(CFLAGS)  -o scanner.o     -c $(SRC)/scanner.c

gasman.o:   $(SRC)/gasman.c   $(SRC)/gasman.h                           \
	    $(SRC)/system.h
	$(CC) $(CFLAGS)  -o gasman.o      -c $(SRC)/gasman.c

objects.o:  $(SRC)/objects.c  $(SRC)/objects.h                          \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	                      $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o objects.o     -c $(SRC)/objects.c

gvars.o:    $(SRC)/gvars.c    $(SRC)/gvars.h                            \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h                                            \
	    $(SRC)/calls.h                                              \
	    $(SRC)/lists.h                                              \
	    $(SRC)/plist.h    $(SRC)/string.h                           \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o gvars.o       -c $(SRC)/gvars.c

calls.o:    $(SRC)/calls.c    $(SRC)/calls.h                            \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	                      $(SRC)/opers.h                            \
	    $(SRC)/lists.h                                              \
	    $(SRC)/bool.h                                               \
	    $(SRC)/listfunc.h                                           \
	    $(SRC)/plist.h                                              \
	    $(SRC)/code.h     $(SRC)/vars.h                             \
	    $(SRC)/stats.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o calls.o       -c $(SRC)/calls.c

opers.o:    $(SRC)/opers.c    $(SRC)/opers.h                            \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/ariths.h   $(SRC)/calls.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/plist.h    $(SRC)/blister.h  $(SRC)/string.h         \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o opers.o       -c $(SRC)/opers.c

ariths.o:   $(SRC)/ariths.c   $(SRC)/ariths.h                           \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o ariths.o      -c $(SRC)/ariths.c

records.o:  $(SRC)/records.c  $(SRC)/records.h                          \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/plist.h    $(SRC)/string.h                           \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o records.o     -c $(SRC)/records.c

lists.o:    $(SRC)/lists.c    $(SRC)/lists.h                            \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/records.h                          \
	    $(SRC)/bool.h                                               \
	    $(SRC)/precord.h                                            \
	    $(SRC)/plist.h    $(SRC)/range.h                            \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o lists.o       -c $(SRC)/lists.c

bool.o:     $(SRC)/bool.c     $(SRC)/bool.h                             \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h                                             \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o bool.o        -c $(SRC)/bool.c

integer.o:  $(SRC)/integer.c  $(SRC)/integer.h                          \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h                                             \
	    $(SRC)/bool.h                                               \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o integer.o     -c $(SRC)/integer.c

rational.o: $(SRC)/rational.c $(SRC)/rational.h                         \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h                                             \
	    $(SRC)/bool.h                                               \
	    $(SRC)/integer.h                                            \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o rational.o    -c $(SRC)/rational.c

cyclotom.o: $(SRC)/cyclotom.c $(SRC)/cyclotom.h                         \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/integer.h                                            \
	    $(SRC)/plist.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o cyclotom.o    -c $(SRC)/cyclotom.c

finfield.o: $(SRC)/finfield.c $(SRC)/finfield.h                         \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/integer.h                                            \
	    $(SRC)/plist.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o finfield.o    -c $(SRC)/finfield.c

permutat.o: $(SRC)/permutat.c $(SRC)/permutat.h                         \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/integer.h                                            \
	    $(SRC)/plist.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o permutat.o    -c $(SRC)/permutat.c

precord.o:  $(SRC)/precord.c  $(SRC)/precord.h                          \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/plist.h                                              \
	    $(SRC)/string.h                                             \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o precord.o     -c $(SRC)/precord.c

listfunc.o: $(SRC)/listfunc.c $(SRC)/listfunc.h                         \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	                      $(SRC)/permutat.h                         \
	    $(SRC)/plist.h    $(SRC)/set.h                              \
	    $(SRC)/range.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o listfunc.o    -c $(SRC)/listfunc.c

listoper.o: $(SRC)/listoper.c $(SRC)/listoper.h                         \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h                                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/plist.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o listoper.o    -c $(SRC)/listoper.c

plist.o:    $(SRC)/plist.c    $(SRC)/plist.h                            \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/range.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o plist.o       -c $(SRC)/plist.c

set.o:      $(SRC)/set.c      $(SRC)/set.h                              \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/listfunc.h                                           \
	    $(SRC)/plist.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o set.o         -c $(SRC)/set.c

vector.o:   $(SRC)/vector.c   $(SRC)/vector.h                           \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/integer.h                                            \
	    $(SRC)/plist.h                                              \
	    $(SRC)/range.h                                              \
	    $(SRC)/listoper.h                                           \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o vector.o      -c $(SRC)/vector.c

blister.o:  $(SRC)/blister.c  $(SRC)/blister.h                          \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/plist.h    $(SRC)/set.h                              \
	    $(SRC)/range.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o blister.o     -c $(SRC)/blister.c

range.o:    $(SRC)/range.c    $(SRC)/range.h                            \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/plist.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o range.o       -c $(SRC)/range.c

string.o:   $(SRC)/string.c   $(SRC)/string.h                           \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/plist.h                                              \
	    $(SRC)/range.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o string.o      -c $(SRC)/string.c

objfgelm.o: ${SRC}/objfgelm.c $(SRC)/objfgelm.h                         \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h                                              \
	    $(SRC)/lists.h    $(SRC)/plist.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o objfgelm.o    -c $(SRC)/objfgelm.c

objscoll.o: ${SRC}/objscoll.c $(SRC)/objscoll.h                         \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h                                              \
	    $(SRC)/lists.h    $(SRC)/plist.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o objscoll.o    -c $(SRC)/objscoll.c

objpcgel.o: ${SRC}/objpcgel.c $(SRC)/objpcgel.h $(SRC)/objfgelm.h       \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h                                              \
	    $(SRC)/lists.h    $(SRC)/plist.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o objpcgel.o    -c $(SRC)/objpcgel.c

sctable.o:  $(SRC)/sctable.c  $(SRC)/sctable.h                          \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h                                              \
	    $(SRC)/lists.h    $(SRC)/plist.h                            \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o sctable.o     -c $(SRC)/sctable.c

costab.o:   $(SRC)/costab.c   $(SRC)/costab.h                           \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h                                              \
	    $(SRC)/lists.h    $(SRC)/plist.h                            \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o costab.o      -c $(SRC)/costab.c

objcftl.o:  $(SRC)/objcftl.c  $(SRC)/objcftl.h  $(SRC)/dt.h             \
            $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
            $(SRC)/objects.h  $(SRC)/plist.h    $(SRC)/gvars.h          \
            $(SRC)/calls.h    $(SRC)/records.h  $(SRC)/precord.h        \
            $(SRC)/gap.h      $(SRC)/bool.h
	$(CC) $(CFLAGS)  -o objcftl.o          -c $(SRC)/objcftl.c


dt.o:       $(SRC)/dt.c       $(SRC)/dt.h                               \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/bool.h     $(SRC)/calls.h          \
	    $(SRC)/integer.h  $(SRC)/gvars.h                            \
	    $(SRC)/plist.h    $(SRC)/lists.h    $(SRC)/listfunc.h       \
	    $(SRC)/precord.h  $(SRC)/records.h                          \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o dt.o          -c $(SRC)/dt.c

dteval.o:   $(SRC)/dteval.c   $(SRC)/dteval.h                           \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/bool.h     $(SRC)/calls.h          \
	    $(SRC)/integer.h  $(SRC)/gvars.h    $(SRC)/plist.h          \
	    $(SRC)/lists.h    $(SRC)/listfunc.h $(SRC)/precord.h        \
	    $(SRC)/records.h                                            \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o dteval.o      -c $(SRC)/dteval.c

code.o:     $(SRC)/code.c     $(SRC)/code.h                             \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h                                            \
	    $(SRC)/calls.h                                              \
	    $(SRC)/records.h                                            \
	    $(SRC)/integer.h                                            \
	    $(SRC)/plist.h                                              \
	    $(SRC)/funcs.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o code.o        -c $(SRC)/code.c

vars.o:     $(SRC)/vars.c     $(SRC)/vars.h                             \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h                                              \
	    $(SRC)/records.h  $(SRC)/lists.h                            \
	    $(SRC)/bool.h                                               \
	    $(SRC)/plist.h                                              \
	    $(SRC)/string.h                                             \
	    $(SRC)/code.h                                               \
	    $(SRC)/exprs.h    $(SRC)/stats.h                            \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o vars.o        -c $(SRC)/vars.c

exprs.o:    $(SRC)/exprs.c    $(SRC)/exprs.h                            \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/ariths.h   $(SRC)/records.h  $(SRC)/lists.h          \
	    $(SRC)/bool.h                                               \
	                      $(SRC)/permutat.h                         \
	    $(SRC)/plist.h                                              \
	    $(SRC)/range.h    $(SRC)/string.h                           \
	    $(SRC)/code.h     $(SRC)/vars.h                             \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o exprs.o       -c $(SRC)/exprs.c

stats.o:    $(SRC)/stats.c    $(SRC)/stats.h                            \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/intrprtr.h $(SRC)/ariths.h         \
	    $(SRC)/code.h     $(SRC)/vars.h                             \
	    $(SRC)/exprs.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS) $(CFLAGS_SIG)  -o stats.o    -c $(SRC)/stats.c

funcs.o:    $(SRC)/funcs.c    $(SRC)/funcs.h                            \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h                                            \
	    $(SRC)/calls.h                                              \
	    $(SRC)/lists.h                                              \
	    $(SRC)/plist.h                                              \
	    $(SRC)/code.h     $(SRC)/vars.h                             \
	    $(SRC)/exprs.h    $(SRC)/stats.h                            \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o funcs.o       -c $(SRC)/funcs.c

intrprtr.o: $(SRC)/intrprtr.c $(SRC)/intrprtr.h                         \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/records.h  $(SRC)/lists.h          \
	    $(SRC)/bool.h                                               \
	                      $(SRC)/permutat.h                         \
	    $(SRC)/plist.h                                              \
	    $(SRC)/range.h    $(SRC)/string.h                           \
	    $(SRC)/code.h     $(SRC)/vars.h                             \
	    $(SRC)/funcs.h                                              \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o intrprtr.o    -c $(SRC)/intrprtr.c

read.o:     $(SRC)/read.c     $(SRC)/read.h                             \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h                                              \
	    $(SRC)/records.h  $(SRC)/lists.h                            \
	    $(SRC)/plist.h                                              \
	    $(SRC)/string.h                                             \
	    $(SRC)/intrprtr.h                                           \
	    $(SRC)/gap.h
	$(CC) $(CFLAGS)  -o read.o        -c $(SRC)/read.c

gap.o:      $(SRC)/gap.c      $(SRC)/gap.h                              \
	    $(SRC)/system.h   $(SRC)/scanner.h  $(SRC)/gasman.h         \
	    $(SRC)/objects.h  $(SRC)/gvars.h                            \
	    $(SRC)/calls.h    $(SRC)/opers.h                            \
	    $(SRC)/ariths.h   $(SRC)/records.h  $(SRC)/lists.h          \
	    $(SRC)/bool.h                                               \
	    $(SRC)/integer.h  $(SRC)/rational.h $(SRC)/cyclotom.h       \
	    $(SRC)/finfield.h $(SRC)/permutat.h                         \
	    $(SRC)/listfunc.h $(SRC)/listoper.h                         \
	    $(SRC)/plist.h    $(SRC)/set.h      $(SRC)/vector.h         \
	    $(SRC)/blister.h  $(SRC)/range.h    $(SRC)/string.h         \
            $(SRC)/objfgelm.h $(SRC)/objscoll.h $(SRC)/sctable.h        \
            $(SRC)/costab.h                                             \
	    $(SRC)/code.h     $(SRC)/vars.h                             \
	    $(SRC)/exprs.h    $(SRC)/stats.h    $(SRC)/funcs.h          \
	    $(SRC)/intrprtr.h $(SRC)/read.h
	$(CC) $(CFLAGS)  -o gap.o         -c $(SRC)/gap.c


#############################################################################
##

#E  Makefile  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



