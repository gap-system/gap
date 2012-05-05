JOBS=4
GMP=yes
WARD=../ward
SCONS=bin/scons
DEBUG=debugguards=1 cflags=-DTRACK_CREATOR

all opt: $(WARD)/bin/ward
	$(SCONS) -j $(JOBS) debug=0 ward=$(WARD) gmp=$(GMP)

gapdebug: $(WARD)/bin/ward
	$(SCONS) -j $(JOBS) debug=0 ward=$(WARD) gmp=$(GMP) $(DEBUG)

debug: $(WARD)/bin/ward
	$(SCONS) -j $(JOBS) debug=1 ward=$(WARD) gmp=$(GMP) $(DEBUG)

opt32 32: $(WARD)/bin/ward
	$(SCONS) -j $(JOBS) debug=0 abi=32 ward=$(WARD) gmp=$(GMP)

gapdebug32: $(WARD)/bin/ward
	$(SCONS) -j $(JOBS) debug=0 abi=32 ward=$(WARD) gmp=$(GMP) $(DEBUG)

debug32: $(WARD)/bin/ward
	$(SCONS) -j $(JOBS) debug=1 abi=32 ward=$(WARD) gmp=$(GMP) $(DEBUG)

opt64 64: $(WARD)/bin/ward
	$(SCONS) -j $(JOBS) debug=0 abi=64 ward=$(WARD) gmp=$(GMP)

gapdebug64: $(WARD)/bin/ward
	$(SCONS) -j $(JOBS) debug=0 abi=64 ward=$(WARD) gmp=$(GMP) $(DEBUG)

debug64: $(WARD)/bin/ward
	$(SCONS) -j $(JOBS) debug=1 abi=64 ward=$(WARD) gmp=$(GMP) $(DEBUG)

clean:
	$(SCONS) -c preprocess=dummy

distclean:
	$(SCONS) -c preprocess=dummy; rm -rf extern/lib/* extern/include/* extern/32bit extern/64bit bin/current/*

$(WARD)/bin/ward:
	@echo "Building Ward."
	@cd ward; sh build.sh >/dev/null 2>/dev/null
	@echo "Ward build completed."

