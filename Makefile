JOBS=4
GMP=yes
WARD=../ward
SCONS=bin/scons
CFLAGS=
DEBUG=debugguards=1 cflags=-DTRACK_CREATOR
ZMQ=no
COMPILER=
BUILD=$(SCONS) -j $(JOBS) ward=$(WARD) gmp=$(GMP) zmq=$(ZMQ) \
	cflags=$(CFLAGS) compiler=$(COMPILER)

all opt: $(WARD)/bin/ward
	$(BUILD) debug=0

gapdebug: $(WARD)/bin/ward
	$(BUILD) debug=0 $(DEBUG) 

debug: $(WARD)/bin/ward
	$(BUILD) debug=1 $(DEBUG) 

opt32 32: $(WARD)/bin/ward
	$(BUILD) debug=0 abi=32 

gapdebug32: $(WARD)/bin/ward
	$(BUILD) debug=0 abi=32 $(DEBUG) 

debug32: $(WARD)/bin/ward
	$(BUILD) debug=1 abi=32 $(DEBUG) 

opt64 64: $(WARD)/bin/ward
	$(BUILD) debug=0 abi=64 

gapdebug64: $(WARD)/bin/ward
	$(BUILD) debug=0 abi=64 $(DEBUG) 

debug64: $(WARD)/bin/ward
	$(BUILD) debug=1 abi=64 $(DEBUG) 

clean:
	$(SCONS) -c preprocess=dummy

distclean:
	$(SCONS) -c preprocess=dummy; rm -rf extern/lib/* extern/include/* extern/32bit extern/64bit bin/current/*

$(WARD)/bin/ward:
	@echo "Building Ward."
	@cd ward; sh build.sh >/dev/null 2>/dev/null
	@echo "Ward build completed."

