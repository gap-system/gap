# This is the Makefile for Guave binaries

# Set this to the location for Guave binaries
BINDIR = /usd5/gap/3.5/pkg/guave/bin

CC = gcc
CFLAGS = -O2 -Wall
FILES = leonconv

all :	$(FILES)

install :
	mkdir -p $(BINDIR)
	cp $(FILES) $(BINDIR)

clean :
	rm -f $(FILES)
