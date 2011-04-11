#############################################################################
##
#W  Makefile                    GAP autodoc                  Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
##

BUILD = ../../etc/buildman.pe

default: ._all

all:
	rm -f ._*
	make ._all

test: 
	$(BUILD) -f config.testall

._all: ../ref/manual.dvi ../new/manual.dvi ../prog/manual.dvi 
	touch ._all

../ref/manual.dvi: ._coll ._basic ._groups ._grppc ._rings ._number \
	._mapping ._oper ._ratfun ._grplib ._alg ._linalg ._fp \
	._install ._environ ._options ._system ._relation ._rws ._trans \
	._fpsemi ._tom ._ctbl ._orders ../ref/obsolete.tex
	(cd ../ref;tex manual)
	fgrep "undefined" ../ref/manual.log

../new/manual.dvi: ._new ._grpchain
	(cd ../new; tex manual)

../prog/manual.dvi: ._prog
	(cd ../prg; tex manual)

._system: config.system streams.msk
	$(BUILD) -f config.system
	touch ._system

._coll: config.coll coll.msk lists.msk string.msk record.msk domain.msk\
	blist.msk combinat.msk boolean.msk
	$(BUILD) -f config.coll
	touch ._coll

._basic: config.basic addmagma.msk magma.msk monoid.msk semigrp.msk
	$(BUILD) -f  config.basic
	touch ._basic

._groups: config.groups groups.msk grpprod.msk grpmat.msk
	$(BUILD) -f config.groups
	touch ._groups

._grppc: config.grppc grppc.msk pcgs.msk
	$(BUILD) -f config.grppc
	touch ._grppc

._fp: config.fp word.msk wordass.msk grpfp.msk pres.msk
	$(BUILD) -f config.fp
	touch ._fp

._rings: config.rings rings.msk module.msk fields.msk fieldfin.msk \
	fldabnum.msk vspc.msk
	$(BUILD) -f config.rings
	touch ._rings

._linalg: config.linalg vspc.msk vector.msk matrix.msk matint.msk
	$(BUILD) -f config.linalg
	touch ._linalg

._number: config.number integers.msk numtheor.msk rational.msk cyclotom.msk \
	unknown.msk padics.msk fldabnum.msk
	$(BUILD) -f config.number
	touch ._number

._mapping: config.mapping mapping.msk grphomom.msk
	$(BUILD) -f config.mapping
	touch ._mapping

._oper: config.oper grpoper.msk grpperm.msk permutat.msk
	$(BUILD) -f config.oper
	touch ._oper

._options: config.options options.msk
	$(BUILD) -f config.options
	touch ._options

._orders: config.orders orders.msk
	$(BUILD) -f config.orders
	touch ._orders

._ratfun: config.ratfun ratfun.msk algfld.msk
	$(BUILD) -f config.ratfun
	touch ._ratfun

._grplib: config.grplib grplib.msk
	$(BUILD) -f config.grplib
	touch ._grplib

._alg: config.alg algebra.msk algfp.msk alglie.msk mgmring.msk
	$(BUILD) -f config.alg
	touch ._alg

._environ: config.environ language.msk debug.msk objects.msk types.msk mloop.msk function.msk process.msk hash2.msk
	$(BUILD) -f config.environ
	touch ._environ

._install: config.install install.msk run.msk gappkg.msk \
	refcover.msk tutcover.msk prgcover.msk extcover.msk ficover.msk\
	newcover.msk copyrigh.msk
	$(BUILD) -f config.install
	mv ../ref/newcover.tex ../new/newcover.tex
	touch ._install

._relation: config.relation relation.msk
	$(BUILD) -f config.relation
	touch ._relation

._rws: config.rws rws.msk
	$(BUILD) -f config.rws
	touch ._rws

._trans: config.trans trans.msk
	$(BUILD) -f config.trans
	touch ._trans

._fpsemi: config.fpsemi fpsemi.msk
	$(BUILD) -f config.fpsemi
	touch ._fpsemi

._tom: config.tom tom.msk
	$(BUILD) -f config.tom
	touch ._tom

._ctbl: config.ctbl ctbl.msk ctblfuns.msk ctblmaps.msk \
        ctblmono.msk
	$(BUILD) -f config.ctbl
	touch ._ctbl

._grpchain: config.grpchain quogphom.msk gptransv.msk \
        grpchain.msk
	$(BUILD) -f config.grpchain
	touch ._grpchain

._prog: config.prog intrfc.msk
	$(BUILD) -f config.prog
	touch ._prog

._new: config.new streams.msk
	$(BUILD) -f config.new
	touch ._new

