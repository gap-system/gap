# Make file for partition backtrack programs, Sun/3 or Sun/4 Unix.
#
COMPILE = gcc
DEFINES = -DINT_SIZE=32
COMPOPT = -c -O2
INCLUDES =
LINKOPT = -v
LINKNAME = -o
OBJ = o
#CPUTIME = cputime.o
BOUNDS =
#
# Special CPU time function for Unix, Sun/3 or Sun/4
#cputime.o : cputime.c
#	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) cputime.c
#
#
#
all:   setstab cent inter desauto generate commut cjrndper orblist fndelt compgrp orbdes randobj wtdist
#
# Invoke linker -- setstab
setstab:  setstab.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) compcrep.$(OBJ) compsg.$(OBJ) copy.$(OBJ) cparstab.$(OBJ) csetstab.$(OBJ) cstborb.$(OBJ) cstrbas.$(OBJ) cuprstab.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) inform.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) optsvec.$(OBJ) orbit.$(OBJ) orbrefn.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) ptstbref.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) readpar.$(OBJ) readper.$(OBJ) readpts.$(OBJ) rprique.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME)
	$(COMPILE) $(LINKNAME) setstab $(LINKOPT) setstab.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) compcrep.$(OBJ) compsg.$(OBJ) copy.$(OBJ) cparstab.$(OBJ) csetstab.$(OBJ) cstborb.$(OBJ) cstrbas.$(OBJ) cuprstab.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) inform.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) optsvec.$(OBJ) orbit.$(OBJ) orbrefn.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) ptstbref.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) readpar.$(OBJ) readper.$(OBJ) readpts.$(OBJ) rprique.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME) $(BOUNDS)
#
# Invoke linker -- cent
cent:  cent.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) ccent.$(OBJ) chbase.$(OBJ) compcrep.$(OBJ) compsg.$(OBJ) copy.$(OBJ) cparstab.$(OBJ) cstborb.$(OBJ) cstrbas.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) inform.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) optsvec.$(OBJ) orbit.$(OBJ) orbrefn.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) ptstbref.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) readper.$(OBJ) rprique.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME)
	$(COMPILE) $(LINKNAME) cent $(LINKOPT) cent.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) ccent.$(OBJ) chbase.$(OBJ) compcrep.$(OBJ) compsg.$(OBJ) copy.$(OBJ) cparstab.$(OBJ) cstborb.$(OBJ) cstrbas.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) inform.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) optsvec.$(OBJ) orbit.$(OBJ) orbrefn.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) ptstbref.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) readper.$(OBJ) rprique.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME) $(BOUNDS)
#
# Invoke linker -- inter
inter:  inter.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) cinter.$(OBJ) compcrep.$(OBJ) compsg.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) cstrbas.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) inform.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) optsvec.$(OBJ) orbit.$(OBJ) orbrefn.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) ptstbref.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) rprique.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME)
	$(COMPILE) $(LINKNAME) inter $(LINKOPT) inter.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) cinter.$(OBJ) compcrep.$(OBJ) compsg.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) cstrbas.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) inform.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) optsvec.$(OBJ) orbit.$(OBJ) orbrefn.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) ptstbref.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) rprique.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME) $(BOUNDS)
#
# Invoke linker -- desauto
desauto:  desauto.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) cdesauto.$(OBJ) chbase.$(OBJ) cmatauto.$(OBJ) code.$(OBJ) compcrep.$(OBJ) compsg.$(OBJ) copy.$(OBJ) cparstab.$(OBJ) cstborb.$(OBJ) cstrbas.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) field.$(OBJ) inform.$(OBJ) matrix.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) optsvec.$(OBJ) orbit.$(OBJ) orbrefn.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) ptstbref.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readdes.$(OBJ) readgrp.$(OBJ) readper.$(OBJ) rprique.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME)
	$(COMPILE) $(LINKNAME) desauto $(LINKOPT) desauto.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) cdesauto.$(OBJ) chbase.$(OBJ) cmatauto.$(OBJ) code.$(OBJ) compcrep.$(OBJ) compsg.$(OBJ) copy.$(OBJ) cparstab.$(OBJ) cstborb.$(OBJ) cstrbas.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) field.$(OBJ) inform.$(OBJ) matrix.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) optsvec.$(OBJ) orbit.$(OBJ) orbrefn.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) ptstbref.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readdes.$(OBJ) readgrp.$(OBJ) readper.$(OBJ) rprique.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME) $(BOUNDS)
#
# Invoke linker -- generate
generate:  generate.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) inform.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) optsvec.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) relator.$(OBJ) stcs.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME)
	$(COMPILE) $(LINKNAME) generate $(LINKOPT) generate.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) inform.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) optsvec.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) relator.$(OBJ) stcs.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME) $(BOUNDS)
#
# Invoke linker -- commut
commut:  commut.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) ccommut.$(OBJ)  chbase.$(OBJ)  copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) new.$(OBJ)  oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ)  randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) storage.$(OBJ)  token.$(OBJ) util.$(OBJ)
	$(COMPILE) $(LINKNAME) commut $(LINKOPT) commut.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) ccommut.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(BOUNDS)
#
# Invoke linker -- cjrndper
cjrndper: cjrndper.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) code.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) field.$(OBJ) matrix.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readdes.$(OBJ) readgrp.$(OBJ) readpar.$(OBJ) readper.$(OBJ) readpts.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ)
	$(COMPILE) $(LINKNAME) cjrndper $(LINKOPT) cjrndper.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) code.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) field.$(OBJ) matrix.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readdes.$(OBJ) readgrp.$(OBJ) readpar.$(OBJ) readper.$(OBJ) readpts.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(BOUNDS)
#
# Invoke linker -- orblist
orblist: orblist.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readdes.$(OBJ) readgrp.$(OBJ) readpar.$(OBJ) readpts.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ)
	$(COMPILE) $(LINKNAME) orblist $(LINKOPT) orblist.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) readpar.$(OBJ) readpts.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(BOUNDS)
#
# Invoke linker -- fndelt
fndelt:  fndelt.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) readper.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ)
	$(COMPILE) $(LINKNAME) fndelt $(LINKOPT) fndelt.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) readper.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(BOUNDS)
#
# Invoke linker -- compgrp
compgrp:  compgrp.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) readpar.$(OBJ) readper.$(OBJ) readpts.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ)
	$(COMPILE) $(LINKNAME) compgrp $(LINKOPT) compgrp.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readgrp.$(OBJ) readpar.$(OBJ) readper.$(OBJ) readpts.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(BOUNDS)
#
# Invoke linker -- orbdes
orbdes:  orbdes.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) code.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) field.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readdes.$(OBJ) readgrp.$(OBJ) readper.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ)
	$(COMPILE) $(LINKNAME) orbdes $(LINKOPT) orbdes.$(OBJ) addsgen.$(OBJ) bitmanp.$(OBJ) chbase.$(OBJ) code.$(OBJ) copy.$(OBJ) cstborb.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) field.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) randschr.$(OBJ) readdes.$(OBJ) readgrp.$(OBJ) readper.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(BOUNDS)
#
# Invoke linker -- randobj
randobj:  randobj.$(OBJ) bitmanp.$(OBJ) copy.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) readpar.$(OBJ) readpts.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ)
	$(COMPILE) $(LINKNAME) randobj $(LINKOPT) randobj.$(OBJ) bitmanp.$(OBJ) copy.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) new.$(OBJ) oldcopy.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) randgrp.$(OBJ) readpar.$(OBJ) readpts.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME) $(BOUNDS)
#
# Invoke linker -- wtdist
wtdist:  wtdist.$(OBJ) bitmanp.$(OBJ) code.$(OBJ) copy.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) field.$(OBJ) new.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) readdes.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ)
	$(COMPILE) $(LINKNAME) wtdist $(LINKOPT) wtdist.$(OBJ) bitmanp.$(OBJ) code.$(OBJ) copy.$(OBJ) errmesg.$(OBJ) essentia.$(OBJ) factor.$(OBJ) field.$(OBJ) new.$(OBJ) partn.$(OBJ) permgrp.$(OBJ) permut.$(OBJ) primes.$(OBJ) readdes.$(OBJ) storage.$(OBJ) token.$(OBJ) util.$(OBJ) $(CPUTIME) $(BOUNDS)
#
#
# Invoke compiler
addsgen.$(OBJ) : group.h extname.h essentia.h permgrp.h permut.h cstborb.h addsgen.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) addsgen.c 
bitmanp.$(OBJ) : group.h extname.h bitmanp.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) bitmanp.c 
ccent.$(OBJ) : group.h extname.h compcrep.h compsg.h cparstab.h errmesg.h inform.h new.h orbrefn.h permut.h randgrp.h storage.h ccent.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) ccent.c 
ccommut.$(OBJ) : group.h extname.h addsgen.h copy.h chbase.h new.h permgrp.h permut.h storage.h ccommut.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) ccommut.c 
cdesauto.$(OBJ) : group.h extname.h code.h compcrep.h compsg.h errmesg.h matrix.h storage.h cdesauto.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) cdesauto.c 
cent.$(OBJ) : group.h extname.h groupio.h ccent.h errmesg.h permgrp.h readgrp.h readper.h storage.h token.h util.h cent.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) cent.c 
chbase.$(OBJ) : group.h extname.h addsgen.h cstborb.h errmesg.h essentia.h factor.h new.h permgrp.h permut.h randgrp.h storage.h repinimg.h settoinv.h chbase.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) chbase.c 
cinter.$(OBJ) : group.h extname.h compcrep.h compsg.h errmesg.h orbrefn.h cinter.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) cinter.c 
cjrndper.$(OBJ) : group.h extname.h groupio.h code.h copy.h errmesg.h matrix.h new.h permut.h readdes.h randgrp.h readgrp.h readpar.h readper.h readpts.h storage.h token.h util.h cjrndper.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) cjrndper.c 
cmatauto.$(OBJ) : group.h extname.h code.h compcrep.h compsg.h errmesg.h matrix.h storage.h cmatauto.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) cmatauto.c 
code.$(OBJ) : group.h extname.h errmesg.h storage.h code.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) code.c 
commut.$(OBJ) : group.h extname.h groupio.h ccommut.h errmesg.h factor.h permgrp.h readgrp.h readper.h storage.h token.h util.h commut.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) commut.c 
compcrep.$(OBJ) : group.h extname.h cputime.h chbase.h cstrbas.h errmesg.h inform.h new.h optsvec.h orbit.h orbrefn.h partn.h permgrp.h permut.h rprique.h storage.h compcrep.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) compcrep.c 
compgrp.$(OBJ) : group.h extname.h groupio.h errmesg.h permgrp.h permut.h readgrp.h util.h compgrp.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) compgrp.c 
compsg.$(OBJ) : group.h extname.h cputime.h addsgen.h chbase.h copy.h cstrbas.h errmesg.h inform.h new.h optsvec.h orbit.h orbrefn.h partn.h permgrp.h permut.h ptstbref.h rprique.h storage.h compsg.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) compsg.c 
copy.$(OBJ) : group.h extname.h essentia.h storage.h copy.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) copy.c 
cparstab.$(OBJ) : group.h extname.h compcrep.h compsg.h errmesg.h orbrefn.h cparstab.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) cparstab.c 
csetstab.$(OBJ) : group.h extname.h compcrep.h compsg.h errmesg.h orbrefn.h csetstab.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) csetstab.c 
cstborb.$(OBJ) : group.h extname.h errmesg.h essentia.h factor.h storage.h cstborb.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) cstborb.c 
cstrbas.$(OBJ) : group.h extname.h chbase.h cstborb.h inform.h new.h orbrefn.h permgrp.h ptstbref.h optsvec.h storage.h cstrbas.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) cstrbas.c 
cuprstab.$(OBJ) : group.h extname.h compcrep.h compsg.h errmesg.h orbrefn.h cuprstab.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) cuprstab.c 
desauto.$(OBJ) : group.h extname.h groupio.h cdesauto.h errmesg.h permgrp.h readdes.h readgrp.h readper.h storage.h token.h util.h desauto.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) desauto.c 
errmesg.$(OBJ) : group.h extname.h errmesg.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) errmesg.c 
essentia.$(OBJ) : group.h extname.h essentia.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) essentia.c 
factor.$(OBJ) : group.h extname.h errmesg.h factor.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) factor.c 
field.$(OBJ) : group.h extname.h errmesg.h new.h storage.h field.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) field.c 
fndelt.$(OBJ) : group.h extname.h groupio.h errmesg.h new.h oldcopy.h permut.h readgrp.h readper.h randgrp.h util.h fndelt.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) fndelt.c 
generate.$(OBJ) : group.h extname.h groupio.h enum.h storage.h cputime.h errmesg.h new.h readgrp.h randschr.h stcs.h util.h generate.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) generate.c 
inform.$(OBJ) : group.h extname.h groupio.h cputime.h readgrp.h inform.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) inform.c 
inter.$(OBJ) : group.h extname.h groupio.h cinter.h errmesg.h permgrp.h readgrp.h readper.h token.h util.h inter.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) inter.c 
matrix.$(OBJ) : group.h extname.h errmesg.h storage.h matrix.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) matrix.c 
new.$(OBJ) : group.h extname.h errmesg.h partn.h storage.h new.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) new.c 
oldcopy.$(OBJ) : group.h extname.h storage.h oldcopy.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) oldcopy.c 
optsvec.$(OBJ) : group.h extname.h cstborb.h essentia.h new.h permut.h permgrp.h storage.h optsvec.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) optsvec.c 
orbdes.$(OBJ) : group.h extname.h groupio.h chbase.h errmesg.h new.h oldcopy.h permut.h readdes.h readgrp.h storage.h util.h orbdes.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) orbdes.c 
orbit.$(OBJ) : group.h extname.h cstborb.h orbit.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) orbit.c 
orblist.$(OBJ) : group.h extname.h groupio.h addsgen.h chbase.h cstborb.h errmesg.h factor.h new.h randgrp.h readgrp.h readpar.h readpts.h storage.h util.h orblist.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) orblist.c 
orbrefn.$(OBJ) : group.h extname.h errmesg.h partn.h storage.h orbrefn.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) orbrefn.c 
partn.$(OBJ) : group.h extname.h storage.h permgrp.h partn.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) partn.c 
permgrp.$(OBJ) : group.h extname.h copy.h errmesg.h essentia.h new.h permut.h storage.h permgrp.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) permgrp.c 
permut.$(OBJ) : group.h extname.h factor.h errmesg.h new.h storage.h repimg.h repinimg.h settoinv.h enum.h permut.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) permut.c 
primes.$(OBJ) : group.h extname.h primes.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) primes.c 
ptstbref.$(OBJ) : group.h extname.h partn.h cstrbas.h errmesg.h ptstbref.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) ptstbref.c 
randgrp.$(OBJ) : group.h extname.h new.h permut.h randgrp.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) randgrp.c 
randobj.$(OBJ) : group.h extname.h groupio.h errmesg.h randgrp.h readpar.h readpts.h storage.h token.h util.h randobj.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) randobj.c 
randschr.$(OBJ) : group.h extname.h groupio.h addsgen.h cstborb.h errmesg.h essentia.h factor.h new.h oldcopy.h permgrp.h permut.h randgrp.h storage.h token.h randschr.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) randschr.c 
readdes.$(OBJ) : group.h extname.h groupio.h code.h errmesg.h new.h token.h readdes.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) readdes.c 
readgrp.$(OBJ) : group.h extname.h groupio.h chbase.h cstborb.h errmesg.h essentia.h factor.h permut.h permgrp.h randschr.h storage.h token.h readgrp.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) readgrp.c 
readpar.$(OBJ) : group.h extname.h groupio.h storage.h token.h errmesg.h readpar.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) readpar.c 
readper.$(OBJ) : group.h extname.h groupio.h errmesg.h essentia.h readgrp.h storage.h token.h readper.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) readper.c 
readpts.$(OBJ) : group.h extname.h groupio.h storage.h token.h errmesg.h readpts.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) readpts.c 
relator.$(OBJ) : group.h extname.h enum.h errmesg.h new.h permut.h stcs.h storage.h relator.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) relator.c 
rprique.$(OBJ) : group.h extname.h storage.h rprique.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) rprique.c 
setstab.$(OBJ) : group.h extname.h groupio.h cparstab.h csetstab.h cuprstab.h errmesg.h permgrp.h readgrp.h readpar.h readper.h readpts.h token.h util.h setstab.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) setstab.c 
stcs.$(OBJ) : group.h extname.h groupio.h enum.h repimg.h addsgen.h cstborb.h errmesg.h essentia.h factor.h new.h oldcopy.h permgrp.h permut.h randschr.h relator.h storage.h token.h stcs.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) stcs.c 
storage.$(OBJ) : group.h extname.h errmesg.h storage.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) storage.c 
token.$(OBJ) : group.h extname.h groupio.h errmesg.h token.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) token.c 
util.$(OBJ) : group.h extname.h util.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) util.c 
wtdist.$(OBJ) : group.h extname.h groupio.h errmesg.h field.h readdes.h storage.h token.h util.h wt.h swt.h wtdist.c
	$(COMPILE) $(COMPOPT) $(INCLUDES) $(DEFINES) wtdist.c 
