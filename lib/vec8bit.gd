#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file should possibly be called vec8bit.g  (see also vecmat.gd)
##  It provides some things that the kernel needs from the library
##

#############################################################################
##
#V  PRIMES_COMPACT_FIELDS    primes for which a compact representation exists
##
BIND_GLOBAL("PRIMES_COMPACT_FIELDS",SSortedList(
  [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,
  101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,
  193,197,199,211,223,227,229,233,239,241,251] ));
MakeImmutable(PRIMES_COMPACT_FIELDS);

#############################################################################
##
#R  Is8BitVectorRep( <obj> ) . . . compressed vector over GFQ (3 <= q <= 256)
##
##  <#GAPDoc Label="Is8BitVectorRep">
##  <ManSection>
##  <Filt Name="Is8BitVectorRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="Is8BitVectorRep"/> describes
##  a vector object (see <Ref Filt="IsVectorObj"/>) with entries in a
##  finite field with <M>q</M> elements, for <M>3 \leq q \leq 256</M>.
##  The base domain of <A>obj</A> is not necessarily the smallest field that
##  contains all matrix entries.
##  <P/>
##  <Ref Filt="Is8BitVectorRep"/> implies <Ref Filt="IsCopyable"/>,
##  thus vector objects in this representation can be mutable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  <Ref Filt="Is8BitVectorRep"/> is a subrepresentation of
##  <Ref Filt="IsDataObjectRep"/>, the entries are packed into bytes.
##
DeclareRepresentation( "Is8BitVectorRep",
        IsDataObjectRep and IsVectorObj
    and IsCopyable
    and IsNoImmediateMethodsObject
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain);


#############################################################################
##
#F  TYPE_VEC8BIT( <q>, <mut> ) . .  computes type of compressed GF(q) vectors
##
##  Normally called by the kernel, caches results in TYPES_VEC8BIT
##
DeclareGlobalFunction( "TYPE_VEC8BIT" );
DeclareGlobalFunction( "TYPE_VEC8BIT_LOCKED" );


#############################################################################
##
#M  IsConstantTimeAccessList( <obj> )
#M  IsSmallList( <obj> )
#M  IsListDefault( <obj> )
##
##  All compressed GF(q) vectors are small and constant-time access,
##  and support the default list arithmetic (multiplication and addition).
##

InstallTrueMethod( IsConstantTimeAccessList, IsList and Is8BitVectorRep );
InstallTrueMethod( IsSmallList, IsList and Is8BitVectorRep );
InstallTrueMethod( IsListDefault, IsList and Is8BitVectorRep );
