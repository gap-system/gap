ACLOCAL_AMFLAGS = -I m4

SUBDIRS = 

BINARCHDIR = bin/$(GAPARCH)
GAPINSTALLLIB = $(abs_top_srcdir)/$(BINARCHDIR)/io.so

lib_LTLIBRARIES = io.la

io_la_SOURCES = src/io.c
io_la_CPPFLAGS = $(GAP_CPPFLAGS) -DCONFIG_H
# Note that the latter is only for GAP 4.4.12
io_la_LDFLAGS = -module -avoid-version
if SYS_IS_CYGWIN
io_la_LDFLAGS += -no-undefined -version-info 0:0:0 -Wl,$(GAPROOT)/bin/$(GAPARCH)/gap.dll
endif

all-local: io.la install-libLTLIBRARIES
	$(mkdir_p) $(top_srcdir)/$(BINARCHDIR)
if SYS_IS_CYGWIN
	cp $(libdir)/io.dll $(GAPINSTALLLIB)
else
	cp $(libdir)/io.so $(GAPINSTALLLIB)
endif
	@echo "SUCCESS!"

distclean-local:
	rm -rf bin/*
	(cd doc ; ./clean)

doc:	doc/manual.six

doc/manual.six: doc/main.xml doc/io.xml VERSION
	($(GAPROOT)/bin/gap.sh makedoc.g)

archive: doc
	(cd .. ; tar czvf io-`cat io/VERSION`.tar.gz --exclude ".svn" --exclude bin --exclude test --exclude ".git" --exclude ".libs" --exclude lib --exclude io.la --exclude io_la-io.lo --exclude .deps --exclude autom4te.cache --exclude .gitignore --exclude config.log --exclude stamp-h1 --exclude pkgconfig.h --exclude libtool --exclude config.status io)

WEBPOS=/scratch/neunhoef/mywebpage.pub/Computer/Software/Gap/io

towww: archive
	echo '<?xml version="1.0" encoding="ISO-8859-1"?>' >${WEBPOS}.version
	echo '<mixer>' >>${WEBPOS}.version
	cat VERSION >>${WEBPOS}.version
	echo '</mixer>' >>${WEBPOS}.version
	cp PackageInfo.g ${WEBPOS}
	cp README ${WEBPOS}/README.io
	cp doc/manual.pdf ${WEBPOS}/io.pdf
	cp ../io-`cat VERSION`.tar.gz ${WEBPOS}
	@echo
	@echo Now please adjust the archive link in 
	@echo "    " ${WEBPOS}.mixer !

