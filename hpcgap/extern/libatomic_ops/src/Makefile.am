AM_CFLAGS=@PICFLAG@
AM_CPPFLAGS = -I$(top_builddir)/src -I$(top_srcdir)/src

include_HEADERS = atomic_ops.h atomic_ops_stack.h atomic_ops_malloc.h
lib_LTLIBRARIES = libatomic_ops.la libatomic_ops_gpl.la
if NEED_ASM
libatomic_ops_la_SOURCES = atomic_ops.c atomic_ops_sysdeps.S
else
libatomic_ops_la_SOURCES = atomic_ops.c
endif
libatomic_ops_la_LDFLAGS = -version-info 1:3:0 -no-undefined

libatomic_ops_gpl_la_SOURCES = atomic_ops_stack.c atomic_ops_malloc.c
libatomic_ops_gpl_la_LDFLAGS = -version-info 1:3:0 -no-undefined
libatomic_ops_gpl_la_LIBADD = libatomic_ops.la

EXTRA_DIST = Makefile.msft atomic_ops/sysdeps/README \
        atomic_ops/generalize-arithm.template \
        atomic_ops/generalize-small.template \
        atomic_ops/sysdeps/ao_t_is_int.template \
        atomic_ops/sysdeps/gcc/generic-arithm.template \
        atomic_ops/sysdeps/gcc/generic-small.template \
        atomic_ops/sysdeps/loadstore/acquire_release_volatile.template \
        atomic_ops/sysdeps/loadstore/atomic_load.template \
        atomic_ops/sysdeps/loadstore/atomic_store.template \
        atomic_ops/sysdeps/loadstore/ordered_loads_only.template \
        atomic_ops/sysdeps/loadstore/ordered_stores_only.template \
        atomic_ops/sysdeps/sunc/sparc.S

BUILT_SOURCES = atomic_ops/generalize-arithm.h \
        atomic_ops/generalize-small.h \
        atomic_ops/sysdeps/ao_t_is_int.h \
        atomic_ops/sysdeps/gcc/generic-arithm.h \
        atomic_ops/sysdeps/gcc/generic-small.h \
        atomic_ops/sysdeps/loadstore/acquire_release_volatile.h \
        atomic_ops/sysdeps/loadstore/atomic_load.h \
        atomic_ops/sysdeps/loadstore/atomic_store.h \
        atomic_ops/sysdeps/loadstore/char_acquire_release_volatile.h \
        atomic_ops/sysdeps/loadstore/char_atomic_load.h \
        atomic_ops/sysdeps/loadstore/char_atomic_store.h \
        atomic_ops/sysdeps/loadstore/int_acquire_release_volatile.h \
        atomic_ops/sysdeps/loadstore/int_atomic_load.h \
        atomic_ops/sysdeps/loadstore/int_atomic_store.h \
        atomic_ops/sysdeps/loadstore/ordered_loads_only.h \
        atomic_ops/sysdeps/loadstore/ordered_stores_only.h \
        atomic_ops/sysdeps/loadstore/short_acquire_release_volatile.h \
        atomic_ops/sysdeps/loadstore/short_atomic_load.h \
        atomic_ops/sysdeps/loadstore/short_atomic_store.h

#Private Headers
privatedir=${includedir}/
nobase_private_HEADERS = atomic_ops/ao_version.h \
          atomic_ops/generalize.h \
          $(BUILT_SOURCES) \
        \
          atomic_ops/sysdeps/all_acquire_release_volatile.h \
          atomic_ops/sysdeps/all_aligned_atomic_load_store.h \
          atomic_ops/sysdeps/all_atomic_load_store.h \
          atomic_ops/sysdeps/all_atomic_only_load.h \
          atomic_ops/sysdeps/emul_cas.h \
          atomic_ops/sysdeps/generic_pthread.h \
          atomic_ops/sysdeps/ordered.h \
          atomic_ops/sysdeps/ordered_except_wr.h \
          atomic_ops/sysdeps/read_ordered.h \
          atomic_ops/sysdeps/standard_ao_double_t.h \
          atomic_ops/sysdeps/test_and_set_t_is_ao_t.h \
          atomic_ops/sysdeps/test_and_set_t_is_char.h \
        \
          atomic_ops/sysdeps/armcc/arm_v6.h \
        \
          atomic_ops/sysdeps/gcc/aarch64.h \
          atomic_ops/sysdeps/gcc/alpha.h \
          atomic_ops/sysdeps/gcc/arm.h \
          atomic_ops/sysdeps/gcc/avr32.h \
          atomic_ops/sysdeps/gcc/cris.h \
          atomic_ops/sysdeps/gcc/generic.h \
          atomic_ops/sysdeps/gcc/hexagon.h \
          atomic_ops/sysdeps/gcc/hppa.h \
          atomic_ops/sysdeps/gcc/ia64.h \
          atomic_ops/sysdeps/gcc/m68k.h \
          atomic_ops/sysdeps/gcc/mips.h \
          atomic_ops/sysdeps/gcc/powerpc.h \
          atomic_ops/sysdeps/gcc/s390.h \
          atomic_ops/sysdeps/gcc/sh.h \
          atomic_ops/sysdeps/gcc/sparc.h \
          atomic_ops/sysdeps/gcc/x86.h \
        \
          atomic_ops/sysdeps/hpc/hppa.h \
          atomic_ops/sysdeps/hpc/ia64.h \
        \
          atomic_ops/sysdeps/ibmc/powerpc.h \
        \
          atomic_ops/sysdeps/icc/ia64.h \
        \
          atomic_ops/sysdeps/loadstore/double_atomic_load_store.h \
        \
          atomic_ops/sysdeps/msftc/arm.h \
          atomic_ops/sysdeps/msftc/common32_defs.h \
          atomic_ops/sysdeps/msftc/x86.h \
          atomic_ops/sysdeps/msftc/x86_64.h \
        \
          atomic_ops/sysdeps/sunc/sparc.h \
          atomic_ops/sysdeps/sunc/x86.h

atomic_ops/generalize-small.h: atomic_ops/generalize-small.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? > $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g $? >> $@

atomic_ops/generalize-arithm.h: atomic_ops/generalize-arithm.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? > $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? >> $@

atomic_ops/sysdeps/ao_t_is_int.h: atomic_ops/sysdeps/ao_t_is_int.template
	mkdir -p `dirname $@`
	sed -e s:_XBAR::g $? > $@
	sed -e s:XBAR:full:g $? >> $@
	sed -e s:XBAR:acquire:g $? >> $@
	sed -e s:XBAR:release:g $? >> $@
	sed -e s:XBAR:write:g $? >> $@
	sed -e s:XBAR:read:g $? >> $@

atomic_ops/sysdeps/gcc/generic-arithm.h: \
        atomic_ops/sysdeps/gcc/generic-arithm.template
	mkdir -p `dirname $@`
	sed -e s:_XBAR::g -e s:XGCCBAR:RELAXED:g \
		-e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? > $@
	sed -e s:_XBAR::g -e s:XGCCBAR:RELAXED:g \
		-e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? >> $@
	sed -e s:_XBAR::g -e s:XGCCBAR:RELAXED:g \
		-e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? >> $@
	sed -e s:_XBAR::g -e s:XGCCBAR:RELAXED:g \
		-e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? >> $@
	sed -e s:XBAR:acquire:g -e s:XGCCBAR:ACQUIRE:g \
		-e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? >> $@
	sed -e s:XBAR:acquire:g -e s:XGCCBAR:ACQUIRE:g \
		-e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? >> $@
	sed -e s:XBAR:acquire:g -e s:XGCCBAR:ACQUIRE:g \
		-e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? >> $@
	sed -e s:XBAR:acquire:g -e s:XGCCBAR:ACQUIRE:g \
		-e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? >> $@
	sed -e s:XBAR:release:g -e s:XGCCBAR:RELEASE:g \
		-e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? >> $@
	sed -e s:XBAR:release:g -e s:XGCCBAR:RELEASE:g \
		-e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? >> $@
	sed -e s:XBAR:release:g -e s:XGCCBAR:RELEASE:g \
		-e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? >> $@
	sed -e s:XBAR:release:g -e s:XGCCBAR:RELEASE:g \
		-e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? >> $@
	sed -e s:XBAR:full:g -e s:XGCCBAR:SEQ_CST:g \
		-e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? >> $@
	sed -e s:XBAR:full:g -e s:XGCCBAR:SEQ_CST:g \
		-e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? >> $@
	sed -e s:XBAR:full:g -e s:XGCCBAR:SEQ_CST:g \
		-e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? >> $@
	sed -e s:XBAR:full:g -e s:XGCCBAR:SEQ_CST:g \
		-e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? >> $@

atomic_ops/sysdeps/gcc/generic-small.h: \
        atomic_ops/sysdeps/gcc/generic-small.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? > $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? >> $@

atomic_ops/sysdeps/loadstore/ordered_loads_only.h: \
        atomic_ops/sysdeps/loadstore/ordered_loads_only.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? > $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g $? >> $@

atomic_ops/sysdeps/loadstore/ordered_stores_only.h: \
        atomic_ops/sysdeps/loadstore/ordered_stores_only.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? > $@
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? >> $@
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? >> $@
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? >> $@
	sed -e s:XSIZE:double:g -e s:XCTYPE:AO_double_t:g $? >> $@

atomic_ops/sysdeps/loadstore/acquire_release_volatile.h: \
        atomic_ops/sysdeps/loadstore/acquire_release_volatile.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? > $@

atomic_ops/sysdeps/loadstore/char_acquire_release_volatile.h: \
        atomic_ops/sysdeps/loadstore/acquire_release_volatile.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? > $@

atomic_ops/sysdeps/loadstore/int_acquire_release_volatile.h: \
        atomic_ops/sysdeps/loadstore/acquire_release_volatile.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? > $@

atomic_ops/sysdeps/loadstore/short_acquire_release_volatile.h: \
        atomic_ops/sysdeps/loadstore/acquire_release_volatile.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? > $@

atomic_ops/sysdeps/loadstore/atomic_load.h: \
        atomic_ops/sysdeps/loadstore/atomic_load.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? > $@

atomic_ops/sysdeps/loadstore/char_atomic_load.h: \
        atomic_ops/sysdeps/loadstore/atomic_load.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? > $@

atomic_ops/sysdeps/loadstore/int_atomic_load.h: \
        atomic_ops/sysdeps/loadstore/atomic_load.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? > $@

atomic_ops/sysdeps/loadstore/short_atomic_load.h: \
        atomic_ops/sysdeps/loadstore/atomic_load.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? > $@

atomic_ops/sysdeps/loadstore/atomic_store.h: \
        atomic_ops/sysdeps/loadstore/atomic_store.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE_::g -e s:XCTYPE:AO_t:g $? > $@

atomic_ops/sysdeps/loadstore/char_atomic_store.h: \
        atomic_ops/sysdeps/loadstore/atomic_store.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:char:g -e s:XCTYPE:unsigned/**/char:g $? > $@

atomic_ops/sysdeps/loadstore/int_atomic_store.h: \
        atomic_ops/sysdeps/loadstore/atomic_store.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:int:g -e s:XCTYPE:unsigned:g $? > $@

atomic_ops/sysdeps/loadstore/short_atomic_store.h: \
        atomic_ops/sysdeps/loadstore/atomic_store.template
	mkdir -p `dirname $@`
	sed -e s:XSIZE:short:g -e s:XCTYPE:unsigned/**/short:g $? > $@
