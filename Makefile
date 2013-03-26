JOBS=4
GMP=yes
WARD=../ward
SCONS=bin/scons
CFLAGS=
DEBUG=debugguards=1 cflags=-DTRACK_CREATOR
ZMQ=no
COMPILER=
CPP_COMPILER=
BUILD=$(SCONS) -j $(JOBS) ward=$(WARD) gmp=$(GMP) zmq=$(ZMQ) \
	cflags=$(CFLAGS) compiler=$(COMPILER) cpp_compiler=$(CPP_COMPILER)

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

config:
	$(BUILD) config

config32:
	$(BUILD) abi=32 config

config64:
	$(BUILD) abi=64 config

clean:
	$(SCONS) -c preprocess=dummy compiler=$(COMPILER)

distclean:
	-rm -rf bin/current/*
	$(SCONS) -c preprocess=dummy compiler=$(COMPILER); rm -rf extern/lib/* extern/include/* extern/32bit extern/64bit bin/current/*

$(WARD)/bin/ward:
	@test -z "$(WARD)" || echo "Building Ward."
	@test -z "$(WARD)" || (cd $(WARD); sh build.sh >/dev/null 2>/dev/null)
	@test -z "$(WARD)" || echo "Ward build completed."

.PHONY: all opt gapdebug debug
.PHONY: opt32 32 gapdebug32 debug32
.PHONY: opt64 64 gapdebug64 debug64
.PHONY: clean distclean
