EXTRA_DIST=test_atomic_include.template list_atomic.template run_parallel.h \
        test_atomic_include.h list_atomic.c
# We distribute test_atomic_include.h and list_atomic.c, since it is hard
# to regenerate them on Windows without sed.

BUILT_SOURCES = test_atomic_include.h list_atomic.i list_atomic.o
CLEANFILES = list_atomic.i list_atomic.o

AM_CPPFLAGS = \
        -I$(top_builddir)/src -I$(top_srcdir)/src \
        -I$(top_builddir)/tests -I$(top_srcdir)/tests

CFLAGS += $(CFLAGS_EXTRA)

TESTS = test_atomic$(EXEEXT) test_atomic_generalized$(EXEEXT) \
        test_stack$(EXEEXT) test_malloc$(EXEEXT)
TEST_OBJS = test_atomic.o test_atomic_generalized-test_atomic.o \
        test_stack.o test_malloc.o
check_PROGRAMS = test_atomic test_atomic_generalized \
        test_stack test_malloc

if HAVE_PTHREAD_H
TESTS += test_atomic_pthreads$(EXEEXT)
TEST_OBJS += test_atomic_pthreads-test_atomic.o
check_PROGRAMS += test_atomic_pthreads
test_atomic_pthreads_SOURCES=$(test_atomic_SOURCES)
test_atomic_pthreads_CPPFLAGS=-DAO_USE_PTHREAD_DEFS $(AM_CPPFLAGS)
test_atomic_pthreads_LDADD=$(test_atomic_LDADD)
endif

test_atomic_SOURCES=test_atomic.c
test_atomic_LDADD = $(THREADDLLIBS) $(top_builddir)/src/libatomic_ops.la

test_atomic_generalized_SOURCES=$(test_atomic_SOURCES)
test_atomic_generalized_CPPFLAGS= \
        -DAO_PREFER_GENERALIZED -DAO_TEST_EMULATION $(AM_CPPFLAGS)
test_atomic_generalized_LDADD=$(test_atomic_LDADD)

test_stack_SOURCES=test_stack.c
test_stack_LDADD = $(THREADDLLIBS) \
        $(top_builddir)/src/libatomic_ops_gpl.la

test_malloc_SOURCES=test_malloc.c
test_malloc_LDADD = $(THREADDLLIBS) \
        $(top_builddir)/src/libatomic_ops_gpl.la

## In case of static libraries build, libatomic_ops.a is already referenced
## in dependency_libs attribute of libatomic_ops_gpl.la file.
if ENABLE_SHARED
test_malloc_LDADD += $(top_builddir)/src/libatomic_ops.la
test_stack_LDADD += $(top_builddir)/src/libatomic_ops.la
endif

# Run the tests directly (without test-driver):
.PHONY: check-without-test-driver
check-without-test-driver: $(TESTS)
	@echo "The following will print some 'Missing ...' messages"
	./test_atomic$(EXEEXT)
	./test_atomic_generalized$(EXEEXT)
	./test_stack$(EXEEXT)
	./test_malloc$(EXEEXT)
	test ! -f test_atomic_pthreads$(EXEEXT) || ./test_atomic_pthreads$(EXEEXT)

test_atomic_include.h: test_atomic_include.template
	mkdir -p `dirname $@`
	sed -e s:XX::g $? > $@
	sed -e s:XX:_release:g $? >> $@
	sed -e s:XX:_acquire:g $? >> $@
	sed -e s:XX:_read:g $? >> $@
	sed -e s:XX:_write:g $? >> $@
	sed -e s:XX:_full:g $? >> $@
	sed -e s:XX:_release_write:g $? >> $@
	sed -e s:XX:_acquire_read:g $? >> $@
	sed -e s:XX:_dd_acquire_read:g $? >> $@

list_atomic.c: list_atomic.template
	mkdir -p `dirname $@`
	echo "#include \"atomic_ops.h\"" > $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g -e s:XX::g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g -e s:XX:_release:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g -e s:XX:_acquire:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g -e s:XX:_read:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g -e s:XX:_write:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g -e s:XX:_full:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g -e s:XX:_release_write:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g -e s:XX:_acquire_read:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g -e s:XX:_dd_acquire_read:g $? >> $@
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g -e s:XX::g $? >> $@
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g -e s:XX:_release:g $? >> $@
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g -e s:XX:_acquire:g $? >> $@
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g -e s:XX:_read:g $? >> $@
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g -e s:XX:_write:g $? >> $@
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g -e s:XX:_full:g $? >> $@
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g -e s:XX:_release_write:g $? >> $@
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g -e s:XX:_acquire_read:g $? >> $@
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g -e s:XX:_dd_acquire_read:g $? >> $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g -e s:XX::g $? >> $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g -e s:XX:_release:g $? >> $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g -e s:XX:_acquire:g $? >> $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g -e s:XX:_read:g $? >> $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g -e s:XX:_write:g $? >> $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g -e s:XX:_full:g $? >> $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g -e s:XX:_release_write:g $? >> $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g -e s:XX:_acquire_read:g $? >> $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g -e s:XX:_dd_acquire_read:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g -e s:XX::g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g -e s:XX:_release:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g -e s:XX:_acquire:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g -e s:XX:_read:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g -e s:XX:_write:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g -e s:XX:_full:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g -e s:XX:_release_write:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g -e s:XX:_acquire_read:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g -e s:XX:_dd_acquire_read:g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g -e s:XX::g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g -e s:XX:_release:g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g -e s:XX:_acquire:g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g -e s:XX:_read:g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g -e s:XX:_write:g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g -e s:XX:_full:g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g -e s:XX:_release_write:g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g -e s:XX:_acquire_read:g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g -e s:XX:_dd_acquire_read:g $? >> $@

list_atomic.i: list_atomic.c
	mkdir -p `dirname $@`
	$(COMPILE) $? -E > $@

# Verify list_atomic.c syntax:
list_atomic.o: list_atomic.c
	$(COMPILE) -c -o $@ $?

# Just compile all tests (without linking and execution):
check-nolink-local: $(TEST_OBJS)
