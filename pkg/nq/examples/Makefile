
NQ=../bin/i686-pc-linux-gnu-gcc/nq -S 

all: G1.tst G2.tst G3.tst G4.tst G5.tst

clean:
	rm -f G?.tst  *~

spotless: clean
	rm -f G*.old

G1.tst: G1
	@ echo -n Testing example: $<
	@ $(NQ) $< 18 | grep -v "Time\|time\|size\|Machine\|Input" > $@
	@ if diff $<.out $@ > /dev/null; then                         \
	     echo " ok.";                                             \
	     rm $@;                                                   \
	else                                                          \
	     echo " results in an error.";                            \
	     echo Please mail the file $@;                            \
	     echo "    " to nickel@mathematik.tu-darmstadt.de;        \
	fi

G2.tst: G2
	@ echo -n Testing example: $<
	@ $(NQ) $< 11 | grep -v "Time\|time\|size\|Machine\|Input" > $@
	@ if diff $<.out $@ > /dev/null; then                         \
	     echo " ok.";                                             \
	     rm $@;                                                   \
	else                                                          \
	     echo " results in an error.";                            \
	     echo Please mail the file $@;                            \
	     echo "    " to nickel@mathematik.tu-darmstadt.de;        \
	fi

G3.tst: G3
	@ echo -n Testing example: $<
	@ $(NQ) $< 20 | grep -v "Time\|time\|size\|Machine\|Input" > $@
	@ if diff $<.out $@ > /dev/null; then                         \
	     echo " ok.";                                             \
	     rm $@;                                                   \
	else                                                          \
	     echo " results in an error.";                            \
	     echo Please mail the file $@;                            \
	     echo "    " to nickel@mathematik.tu-darmstadt.de;        \
	fi

G4.tst: G4
	@ echo -n Testing example: $<
	@ $(NQ) $< 12 | grep -v "Time\|time\|size\|Machine\|Input" > $@
	@ if diff $<.out $@ > /dev/null; then                         \
	     echo " ok.";                                             \
	     rm $@;                                                   \
	else                                                          \
	     echo " results in an error.";                            \
	     echo Please mail the file $@;                            \
	     echo "    " to nickel@mathematik.tu-darmstadt.de;        \
	fi

G5.tst: G5
	@ echo -n Testing example: $<
	@ $(NQ) $< 12 | grep -v "Time\|time\|size\|Machine\|Input" > $@
	@ if diff $<.out $@ > /dev/null; then                         \
	     echo " ok.";                                             \
	     rm $@;                                                   \
	else                                                          \
	     echo " results in an error.";                            \
	     echo Please mail the file $@;                            \
	     echo "    " to nickel@mathematik.tu-darmstadt.de;        \
	fi

test:
	@ for example in G?.[0-9]*; do                                   \
	    echo makeing test example `basename $$example`;              \
									 \
	    class=`echo $$example | awk -F. '{print $$2}'`;              \
	    output=`echo $$example | awk -F. '{print $$1}'`;             \
									 \
	    mv -f $$output.out $$output.old;                             \
	    echo "    $(NQ) $$example $$class > $$output.out";           \
	    $(NQ) $$example $$class                                      \
		| grep -v "Time\|time\|size\|Machine\|Input" > $$output.out;\
	done
