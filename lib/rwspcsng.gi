#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file implement a single collector as representation of a polycyclic
##  collector with power/conjugate presentation.
##
##  As the  collector  needs access to  the  information as fast as  possible
##  single collectors are not record objects but list objects.  However, they
##  still support the required components via '.'.  The positions in the list
##  object are defined in the kernel and are exported as "SCP_something".
##


#############################################################################
##
#R  IsSingleCollectorRep( <obj> )
##
DeclareRepresentation( "IsSingleCollectorRep",
    IsPositionalObjectRep );


#############################################################################
##
#R  Is8BitsSingleCollectorRep( <obj> )
##
DeclareRepresentation( "Is8BitsSingleCollectorRep",
    IsSingleCollectorRep );


#############################################################################
##
#R  Is16BitsSingleCollectorRep( <obj> )
##
DeclareRepresentation( "Is16BitsSingleCollectorRep",
    IsSingleCollectorRep );


#############################################################################
##
#R  Is32BitsSingleCollectorRep( <obj> )
##
DeclareRepresentation( "Is32BitsSingleCollectorRep",
    IsSingleCollectorRep );


#############################################################################
##
#P  IsDefaultRhsTypeSingleCollector
##
##  This feature is set as soon as all right hand sides have the same type as
##  the one stored  in  the component 'defaultType'.   Calling  'ReduceRules'
##  will reduce all right hand sides and convert  them into an object of type
##  'defaultType'.
##
DeclareFilter( "IsDefaultRhsTypeSingleCollector" );


#############################################################################
##
#F  SingleCollector_CollectWord( <sc>, <v>, <w> )
##
##  'CollectWord' implements  a  single  collector  for a presentation  of  a
##  finite  polycyclic group.  The functions expects  a rewriting system <sc>
##  describing the polycyclic presentation, an exponent vector <v> and a word
##  <w> in the corresponding free group.  It collects <w> into <v>.
##
SingleCollector_CollectWordRunning := false;

BindGlobal( "SingleCollector_CollectWord", function( sc, v, w )

    local   cnj,        # <cnj>[g][h] contains g^h for g > h
            pow,        # <pow>[g] contains g^p
            gns,        # the group generators
            ro,         # <ro>[g] contains the relative order of g
            nw,         # stack of words to process
            lw,         # stack of number of syllabels in <nw>
            pw,         # stack of position of the in <nw> to look at
            ew,         # stack of unprocessed exponents at position <pw>
            ge,         # stack of global exponents of the words in <nw>
            sp,         # stack pointer
            gn,         # generator number
            inv,        # inverses
            i,          # loop variable
            start,      # last non-trivial entry in <v>
            tmp,        # temporary
            avc;        # g_i .. g_n commutes with g_avc[i]+1 .. g_n

    # the collector is not reentrant
    if SingleCollector_CollectWordRunning  then
        SingleCollector_CollectWordRunning := false;
        Error( "collector is not reentrant" );
    fi;
    #Print( "#I  using the GAP level single collector\n" );
    SingleCollector_CollectWordRunning := true;

    # <nw> contains the stack of words to insert
    nw := [];  nw[1] := w;

    # <lw> contains the number of syllables in <nw>
    lw := [];  lw[1] := NumberSyllables(nw[1]);

    # if we got the identity return
    if lw[1] = 0  then
        SingleCollector_CollectWordRunning := false;
        return true;
    fi;

    # get the array of conjugates, powers, orders and the avector
    gns := sc![SCP_RWS_GENERATORS];
    cnj := sc![SCP_CONJUGATES];
    pow := sc![SCP_POWERS];
    ro  := sc![SCP_RELATIVE_ORDERS];
    avc := sc![SCP_AVECTOR];

    # compute the inverses in case we need them
    inv := sc![SCP_INVERSES];

    # <pw> contains the position of the word in <nw> to look at
    pw := [];  pw[1] := 1;

    # <ew> contains the unprocessed exponents at position <pw>
    ew := [];  ew[1] := ExponentSyllable(nw[1],pw[1]);

    # <ge> contains the global exponent of the word
    ge := [];  ge[1] := 1;

    # <sp> is the stack pointer
    sp := 1;

    # <start> is the first non-trivial entry in <v>
    start := Length(v);

    # run until the stack is empty
    while 0 < sp  do

        # if <ew> is negative use inverse
        if ew[sp] < 0  then
            sp := sp+1;
            gn :=  GeneratorSyllable( nw[sp-1], pw[sp-1] );
            #Print( "#I  pushing INV(", gn, ")\n" );

            nw[sp] := inv[gn];
            lw[sp] := NumberSyllables(nw[sp]);
            pw[sp] := 1;
            ew[sp] := ExponentSyllable( nw[sp], pw[sp] );
            ge[sp] := -ew[sp-1];
            ew[sp-1] := 0;


        # if <ew> is zero get next syllable
        elif 0 = ew[sp]  then

            # if <pw> has reached <lw> get next & reduce globale exponent
            if pw[sp] = lw[sp]  then

                # if the globale exponent is greater one reduce it
                if 1 < ge[sp]  then
                    ge[sp] := ge[sp]-1;
                    pw[sp] := 1;
                    ew[sp] := ExponentSyllable( nw[sp], pw[sp] );

                # otherwise get the next word from the stack
                else
                    #Print( "#I  poping\n" );
                    sp := sp-1;
                fi;

            # otherwise set <ew> to exponent of next syllable
            else
                pw[sp] := pw[sp] + 1;
                ew[sp] := ExponentSyllable( nw[sp], pw[sp] );
            fi;

        # now move the next generator to the correct position
        else

            # get generator number
            gn := GeneratorSyllable( nw[sp], pw[sp] );

            # we can move <gn> directly to the correct position
            if avc[gn] = gn  then
                v[gn]  := v[gn] + ew[sp];
                ew[sp] := 0;
                if start <= gn  then start := gn;  fi;

            # we have to move <gn> step by step
            else
                ew[sp] := ew[sp] - 1;
                if start <= avc[gn]  then
                    tmp := start;
                else
                    tmp := avc[gn];
                fi;
                for i  in [ tmp, tmp-1 .. gn+1 ]  do
                    if 0 <> v[i]  then
                        #Print( "#I  pushing CONJ(",i,",",gn,")\n" );
                        sp := sp+1;
                        if IsBound(cnj[i][gn])  then
                            if 0 = NumberSyllables(cnj[i][gn])  then
                                nw[sp] := gns[i];
                            else
                                nw[sp] := cnj[i][gn];
                            fi;
                        else
                            nw[sp] := gns[i];
                        fi;
                        lw[sp] := NumberSyllables(nw[sp]);
                        pw[sp] := 1;
                        ew[sp] := ExponentSyllable( nw[sp], pw[sp] );
                        ge[sp] := v[i];
                        v[i] := 0;
                    fi;
                od;
                v[gn] := v[gn] + 1;
                if start <= avc[gn]  then start := gn;  fi;
            fi;

            # check that the exponent is not too big
            if ro[gn] <= v[gn]  then
                tmp := QuoInt( v[gn], ro[gn] );
                v[gn] := v[gn] - ro[gn]*tmp;
                if IsBound(pow[gn]) and 0 < NumberSyllables(nw[sp])  then
                    #Print( "#I  pushing POWER(",gn,")\n" );
                    sp := sp+1;
                    nw[sp] := pow[gn];
                    lw[sp] := NumberSyllables(nw[sp]);
                    pw[sp] := 1;
                    ew[sp] := ExponentSyllable( nw[sp], pw[sp] );
                    ge[sp] := tmp;
                fi;
            fi;
        fi;
    od;
    SingleCollector_CollectWordRunning := false;
    return true;

end );


#############################################################################
##
#F  SingleCollector_Solution( <sc>, <a>, <b> )
##
##  Solve the equation <a> X = <b>.
##
BindGlobal( "SingleCollector_Solution", function( sc, a, b )
    local   rod,  av,  bv,  x,  i,  dif,  y;

    # get the free group generators and relative orders
    rod := sc![SCP_RELATIVE_ORDERS];

    # write <a> as exponent vector
    av := ExponentSums( a, 1, sc![SCP_NUMBER_RWS_GENERATORS] );

    # write <b> as exponent vector
    bv := ExponentSums( b, 1, sc![SCP_NUMBER_RWS_GENERATORS] );

    # and build the solution in <x>
    x := [];

    # loop over all generators
    for i  in [ 1 .. sc![SCP_NUMBER_RWS_GENERATORS] ]  do
        dif := (bv[i] - av[i]) mod rod[i];
        if dif <> 0  then
            y := AssocWord( sc![SCP_DEFAULT_TYPE], [ i, dif ] );
            Add( x, i );
            Add( x, dif );
            CollectWord( sc, av, y );
        fi;
    od;

    # and return the solution <x>
    return AssocWord( sc![SCP_DEFAULT_TYPE], x );

end );


#############################################################################
##
#M  Rules( <sc> )
##
InstallMethod( Rules,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep ],
    0,

function( sc )
    local   rels,  gens,  ords,  i,  j;

    # first the power relators
    rels := [];
    gens := sc![SCP_RWS_GENERATORS];
    ords := sc![SCP_RELATIVE_ORDERS];
    for i  in [ 1 .. sc![SCP_NUMBER_RWS_GENERATORS] ]  do
        if IsBound( sc![SCP_POWERS][i])  then
            Add( rels, gens[i]^ords[i] / sc![SCP_POWERS][i] );
        else
            Add( rels, gens[i]^ords[i] );
        fi;
    od;

    # and now the non-trivial conjugates
    for i  in [ 2 .. sc![SCP_NUMBER_RWS_GENERATORS] ]  do
        for j  in [ 1 .. i-1 ]  do
            if IsBound(sc![SCP_CONJUGATES][i][j])  then
                Add( rels, gens[i]^gens[j] / sc![SCP_CONJUGATES][i][j] );
            else
                Add( rels, gens[i]^gens[j] / gens[i] );
            fi;
        od;
    od;

    # and return
    return rels;

end );


#############################################################################
##
#M  ReduceRules( <sc> )
##
InstallMethod( ReduceRules,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
        and IsMutable ],
    0,

function( sc )
    local   pow,  cnj,  rod,  gns,  n,  m,  i,  j,  l;

    # check all powers and conjugates
    pow := sc![SCP_POWERS];
    cnj := sc![SCP_CONJUGATES];
    rod := sc![SCP_RELATIVE_ORDERS];
    gns := sc![SCP_RWS_GENERATORS];
    n   := sc![SCP_NUMBER_RWS_GENERATORS];

    # return if there is nothing to reduce
    if n = 0  then
        SetFilterObj( sc, IsDefaultRhsTypeSingleCollector );
        OutdatePolycyclicCollector(sc);
        UpdatePolycyclicCollector(sc);
        return;
    fi;

    # start at the bottom
    if IsBound(pow[n])  then
        if 1 < NumberSyllables(pow[n])  then
            Error( "illegal power rule for generator ", n );
        fi;
        if n <> GeneratorSyllable( pow[n], 1 )  then
            Error( "illegal power rule for generator ", n );
        fi;
        m := ExponentSyllable(pow[n],1) mod rod[n];
        if m = 0  then
            Unbind(pow[n]);
        else
            pow[n] := gns[n]^m;
        fi;
    fi;

    # and work up the composition series
    for i  in [ n-1, n-2 .. 1 ]  do
        for j  in [ n, n-1 .. i+1 ]  do
            if IsBound(cnj[j][i])  then
                l := List( gns, x -> 0 );
                while CollectWordOrFail( sc, l, cnj[j][i] ) = fail  do
                    l := List( gns, x -> 0 );
                od;
                cnj[j][i] := ObjByVector( sc![SCP_DEFAULT_TYPE], l );
                if cnj[j][i] = gns[j]  then
                    Unbind(cnj[j][i]);
                fi;
            fi;
        od;
        if IsBound(pow[i])  then
            l := List( gns, x -> 0 );
            while CollectWordOrFail( sc, l, pow[i] ) = fail  do
                l := List( gns, x -> 0 );
            od;
            pow[i] := ObjByVector( sc![SCP_DEFAULT_TYPE], l );
            if 0 = NumberSyllables(pow[i])  then
                Unbind(pow[i]);
            fi;
        fi;
    od;

    # now all right hand sides have the default type
    SetFilterObj( sc, IsDefaultRhsTypeSingleCollector );

    # but we have to outdate the collector to force recomputation of avec
    OutdatePolycyclicCollector(sc);
    UpdatePolycyclicCollector(sc);

end );


#############################################################################
##
#M  SetConjugate( <sc>, <i>, <j>, <rhs> )
##
##  required: <i> > <j>
##
InstallMethod( SetConjugateANC,
    "pow conj single collector",
    IsIdenticalObjFamiliesColXXXXXXObj,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
        and IsMutable,
      IsInt,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,
function( sc, i, j, rhs )

    # if <i> and <j> commute unbind the entry
    if rhs = sc![SCP_RWS_GENERATORS][i]  then
        Unbind(sc![SCP_CONJUGATES][i][j]);

    # install the rhs
    else
        sc![SCP_CONJUGATES][i][j] := rhs;
        if not sc![SCP_IS_DEFAULT_TYPE](rhs)  then
            Print( "#W  Warning: mixed types in collector\n" );
            ResetFilterObj( sc, IsDefaultRhsTypeSingleCollector );
        fi;
    fi;

end );

BindGlobal( "SingleCollector_SetConjugateNC", function( sc, i, j, rhs )

    # if <i> and <j> commute unbind the entry
    if rhs = sc![SCP_RWS_GENERATORS][i]  then
        Unbind(sc![SCP_CONJUGATES][i][j]);

    # install the rhs
    else
        sc![SCP_CONJUGATES][i][j] := rhs;
        if not sc![SCP_IS_DEFAULT_TYPE](rhs)  then
            ResetFilterObj( sc, IsDefaultRhsTypeSingleCollector );
        fi;
    fi;

    # collector info must be updated
    OutdatePolycyclicCollector(sc);

end );


#############################################################################
InstallMethod( SetConjugateNC,
    IsIdenticalObjFamiliesColXXXXXXObj,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
        and IsMutable,
      IsInt,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,
    SingleCollector_SetConjugateNC );


#############################################################################
InstallMethod( SetConjugate,
    IsIdenticalObjFamiliesColXXXXXXObj,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
        and IsMutable,
      IsInt,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( sc, i, j, rhs )
    local   m,  n,  l;

    # check <i> and <j>
    if i <= 1  then
        Error( "<i> must be at least 2" );
    fi;
    if sc![SCP_NUMBER_RWS_GENERATORS] < i  then
        Error( "<i> must be at most ", sc![SCP_NUMBER_RWS_GENERATORS] );
    fi;
    if j <= 0  then
        Error( "<j> must be positive" );
    fi;
    if i <= j  then
        Error( "<j> must be at most ", i-1 );
    fi;

    # check that the rhs is non-trivial
    if 0 = NumberSyllables(rhs)  then
        Error( "right hand side is trivial" );
    fi;

    # check that the rhs lies underneath <j>
    m := sc![SCP_NUMBER_RWS_GENERATORS]+1;
    for l  in [ 1 .. NumberSyllables(rhs) ]  do
        n := GeneratorSyllable( rhs, l );
        if n < m  then m := n;  fi;
    od;
    if m <= j  then
        Error( "<rhs> contains illegal generator ", m );
    fi;

    # install the conjugate relator
    SingleCollector_SetConjugateNC( sc, i, j, rhs );

end );


#############################################################################
##
#M  SetPower( <sc>, <i>, <rhs> )
##
InstallMethod( SetPowerANC,
    "pow conj single collector",
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
        and IsMutable,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,
function( sc, i, rhs )
    # enter the rhs
    if 0 = NumberSyllables(rhs)  then
        Unbind(sc![SCP_POWERS][i]);
    else
        sc![SCP_POWERS][i] := rhs;
        if not sc![SCP_IS_DEFAULT_TYPE](rhs)  then
            Print( "#  Warning: mixed types in collector\n" );
            ResetFilterObj( sc, IsDefaultRhsTypeSingleCollector );
        fi;
    fi;

end );

BindGlobal( "SingleCollector_SetPowerNC", function( sc, i, rhs )

    # enter the rhs
    if 0 = NumberSyllables(rhs)  then
        Unbind(sc![SCP_POWERS][i]);
    else
        sc![SCP_POWERS][i] := rhs;
        if not sc![SCP_IS_DEFAULT_TYPE](rhs)  then
            ResetFilterObj( sc, IsDefaultRhsTypeSingleCollector );
        fi;
    fi;

    # collector info must be updated
    OutdatePolycyclicCollector(sc);

end );


#############################################################################
InstallMethod( SetPowerNC,
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
        and IsMutable,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,
    SingleCollector_SetPowerNC );


#############################################################################
InstallMethod( SetPower,
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
        and IsMutable,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( sc, i, rhs )
    local   fam,  m,  n,  l;

    # check the family (this cannot be done in install)
    fam := sc![SCP_UNDERLYING_FAMILY];
    if not IsIdenticalObj( FamilyObj(rhs), fam )  then
        Error( "<rhs> must lie in the group of <sc>" );
    fi;

    # check <i>
    if i <= 0  then
        Error( "<i> must be positive" );
    fi;
    if sc![SCP_NUMBER_RWS_GENERATORS] < i  then
        Error( "<i> must be at most ", sc![SCP_NUMBER_RWS_GENERATORS] );
    fi;

    # check that the rhs lies underneath <i>
    m := sc![SCP_NUMBER_RWS_GENERATORS]+1;
    for l  in [ 1 .. NumberSyllables(rhs) ]  do
        n := GeneratorSyllable( rhs, l );
        if n < m  then m := n;  fi;
    od;
    if m <= i  then
        Error( "<rhs> contains illegal generator ", m );
    fi;

    # enter the rhs
    SingleCollector_SetPowerNC( sc, i, rhs );

end );


#############################################################################
##
#M  GetConjugateNC  . . . . . . .  conjugate relation from a single collector
##
InstallMethod( GetConjugateNC,
        "finite pow-conj single collector",
        true,
        [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep,
          IsInt,
          IsInt ],
        0,
function( coll, h, g )

    if IsBound( coll![SCP_CONJUGATES][h] ) and
       IsBound( coll![SCP_CONJUGATES][h][g] ) then
        return coll![SCP_CONJUGATES][h][g];
    fi;

    # return the generators h.
    return coll![SCP_RWS_GENERATORS][h];
end );


#############################################################################
##
#M  GetPowerNC  . . . . . . . . . . .  power relation from a single collector
##
InstallMethod( GetPowerNC,
        true,
        [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep,
          IsInt ],
        0,
function( coll, g )

    if IsBound( coll![SCP_POWERS][g] ) then
        return coll![SCP_POWERS][g];
    fi;

    #  return the identity.
    return AssocWord( coll![SCP_DEFAULT_TYPE], [] );
end );

#############################################################################
##
#M  SetRelativeOrder( <sc>, <i>, <ord> )
##
BindGlobal( "SingleCollector_SetRelativeOrderNC", function( sc, i, ord )

    # store the new order
    sc![SCP_RELATIVE_ORDERS][i] := ord;

    # collector info must be updated
    OutdatePolycyclicCollector(sc);

end );


#############################################################################
InstallMethod( SetRelativeOrderNC,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
        and IsMutable,
      IsInt,
      IsInt ],
    0,
    SingleCollector_SetRelativeOrderNC );


#############################################################################
InstallMethod( SetRelativeOrder,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
        and IsMutable,
      IsInt,
      IsInt ],
    0,

function( sc, i, ord )

    if ord < 2  or ord = infinity  then
        Error( "<ord> order must be finite and greater 1" );
    fi;
    SingleCollector_SetRelativeOrderNC( sc, i, ord );

end );


#############################################################################
##
#M  UpdatePolycyclicCollector( <sc> )
##
##  The `Avector' routine was taken from the \package{NQ} package.
##
BindGlobal( "SingleCollector_MakeAvector", function( sc )
    local   com,  cnj,  n,  g,  again,  h;

    # number of generators
    n := sc![SCP_NUMBER_RWS_GENERATORS];

    # list of rhs
    cnj := sc![SCP_CONJUGATES];

    # <com>[i] is the smallest j >= i such that a_i,...,a_n commutes with
    # a_(j+1),...,a_n.
    com := ListWithIdenticalEntries( n, n );

    # After the while loop two cases can occur :
    #
    # a) h > g+1. In this case h is the first generator among
    #    a_n,...,a_(j+1) with which g does not commute.
    #
    # b) h = g+1. Then <com>[g+1] = g+1 follows and g commutes with all
    #    generators a_(g+2),..,a_n. So it has to be checked whether a_g and
    #    a_(g+1) commute.  If that is the case, then <com>[g] = g. If not
    #    then <com>[g] = g+1 = h.

    for g  in [ n-1, n-2 .. 1 ]  do
        again := true;
        h := n;
        while again and h > com[g+1]  do
            if IsBound(cnj[h][g])  then
                again := false;
            else
                h := h-1;
            fi;
        od;

        if h = g+1 and not IsBound(cnj[h][g]) then
            com[g] := g;
        else
            com[g] := h;
        fi;
    od;

    # set the avector
    sc![SCP_AVECTOR] := com;

end );

BindGlobal( "SingleCollector_MakeInverses", function( sc )
    local   n,  gn,  id,  i,invhint,j,ih,av;

    # start at the bottom
    n  := sc![SCP_NUMBER_RWS_GENERATORS];
    gn := sc![SCP_RWS_GENERATORS];
    id := One(sc![SCP_UNDERLYING_FAMILY]);
    invhint:=ValueOption("inversehints");
    for i  in [ n, n-1 .. 1 ]  do
      if invhint<>fail then
        ih:=[];
        for j in [1..Length(invhint[i])] do
          if invhint[i][j]<>0 then
            Add(ih,j);
            Add(ih,invhint[i][j]);
          fi;
        od;
        ih:=AssocWord(sc![SCP_DEFAULT_TYPE],ih); # claimed inverse
        # test that the inverses work. This can be abysmally slow for larger
        # primes.
        if AssertionLevel()>0 then
          av:=ExponentSums(gn[i],1,sc![SCP_NUMBER_RWS_GENERATORS]);
          CollectWord(sc,av,ih);
          if ForAny(av,x->not IsZero(x)) then
            Error("failed inverse hint");
            ih:=fail;
          fi;
        fi;
      else
        ih:=fail;
      fi;
      if ih<>fail then
        #if ih<>SingleCollector_Solution( sc, gn[i], id ) then
        #  Error("ugh!");
        #else
        #  Print("inversehint worked\n");
        #fi;
        sc![SCP_INVERSES][i] := ih;
      else
        sc![SCP_INVERSES][i] := SingleCollector_Solution( sc, gn[i], id );
      fi;
    od;
end );

InstallMethod( UpdatePolycyclicCollector,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep ],
    0,

function( sc )

    # update the avector
    SingleCollector_MakeAvector(sc);

    # 'MakeInverses' is very careful
    SetFilterObj( sc, IsUpToDatePolycyclicCollector );

    # construct the inverses
    SingleCollector_MakeInverses(sc);

end );


#############################################################################
##
#M  UpdatePolycyclicCollector( <sc> )
##
##
#############################################################################
##
#M  SingleCollector( <fgrp>, <orders> )
##


#############################################################################
InstallMethod( SingleCollector,
    true,
    [ IsFreeGroup and IsGroupOfFamily,
      IsList ],
    0,

function( fgrp, orders )
    local   gens;

    # check the orders
    gens := GeneratorsOfGroup(fgrp);
    if Length(orders) <> Length(gens)  then
        Error( "need ", Length(gens), " orders, not ", Length(orders) );
    fi;
    if ForAny( orders, x -> not IsInt(x) or x <= 0 )  then
        Error( "relative orders must be positive integers" );
    fi;

    # create a new single collector
    return SingleCollectorByGenerators(
        ElementsFamily(FamilyObj(fgrp)), gens, orders );

end );


#############################################################################
InstallMethod( SingleCollector,
    true,
    [ IsFreeGroup and IsGroupOfFamily,
      IsInt ],
    0,

function( fgrp, order )
    local   gens;

    # check the order
    if order <= 0  then
        Error( "relative order must be a positive integers" );
    fi;
    order := List( GeneratorsOfGroup(fgrp), x -> order );
    gens  := GeneratorsOfGroup(fgrp);

    # create a new object
    return SingleCollectorByGenerators(
        ElementsFamily(FamilyObj(fgrp)), gens, order );

end );


#############################################################################
InstallMethod( SingleCollector,
    true,
    [ IsList,
      IsList ],
    0,

function( gens, orders )

    # check the orders
    if Length(orders) <> Length(gens)  then
        Error( "need ", Length(gens), " orders, not ", Length(orders) );
    fi;
    if ForAny( orders, x -> not IsInt(x) or x <= 0 )  then
        Error( "relative orders must be positive integers" );
    fi;

    # create a new object
    return SingleCollectorByGenerators(
        ElementsFamily(FamilyObj(gens)), gens, orders );

end );


#############################################################################
InstallMethod( SingleCollector,
    true,
    [ IsList,
      IsInt ],
    0,

function( gens, order )

    # check the orders
    if order <= 0  then
        Error( "relative orders must be positive integers" );
    fi;
    order := List( gens, x -> order );

    # create a new object
    return SingleCollectorByGenerators(
        ElementsFamily(FamilyObj(gens)), gens, order );

end );


#############################################################################
##
#M  SingleCollectorByGenerators( <fam>, <gens>, <orders>
##
InstallMethod( SingleCollectorByGenerators,
    true,
    [ IsFamily,
      IsList,
      IsList ],
    0,

function( efam, gens, orders )
    local   i,  sc,  m,  bits,  type,  fam;

    # create the correct family
    fam := NewFamily( "PowerConjugateCollectorFamily",
                      IsPowerConjugateCollector );
    fam!.underlyingFamily := efam;

    # check the generators
    for i  in [ 1 .. Length(gens) ]  do
        if 1 <> NumberSyllables(gens[i])  then
            Error( gens[i], " must be a word of length 1" );
        elif 1 <> ExponentSyllable( gens[i], 1 )  then
            Error( gens[i], " must be a word of length 1" );
        elif i <> GeneratorSyllable( gens[i], 1 )  then
            Error( gens[i], " must be generator number ", i );
        fi;
    od;

    # construct a single collector as list object
    sc := [];

    # we need the family
    sc[SCP_UNDERLYING_FAMILY] := efam;

    # and the relative orders
    sc[SCP_RELATIVE_ORDERS] := ShallowCopy(orders);

    # and a default type
    if 0 = Length(gens)  then
        m := 1;
    else
        m := Maximum( sc[SCP_RELATIVE_ORDERS] );
    fi;
    i := 1;
    while i < 4 and sc[SCP_UNDERLYING_FAMILY]!.expBitsInfo[i] <= m  do
        i := i + 1;
    od;
    sc[SCP_DEFAULT_TYPE] := sc[SCP_UNDERLYING_FAMILY]!.types[i];

    # set the corresponding feature later
    if i = 1  then
        sc[SCP_IS_DEFAULT_TYPE] := Is8BitsAssocWord;
        sc[SCP_COLLECTOR] := 8Bits_SingleCollector;
        bits := Is8BitsSingleCollectorRep;
    elif i = 2  then
        sc[SCP_IS_DEFAULT_TYPE] := Is16BitsAssocWord;
        sc[SCP_COLLECTOR] := 16Bits_SingleCollector;
        bits := Is16BitsSingleCollectorRep;
    elif i = 3  then
        sc[SCP_IS_DEFAULT_TYPE] := Is32BitsAssocWord;
        sc[SCP_COLLECTOR] := 32Bits_SingleCollector;
        bits := Is32BitsSingleCollectorRep;
    else
        sc[SCP_IS_DEFAULT_TYPE] := IsInfBitsAssocWord;
        bits := IsSingleCollectorRep;
    fi;

    # the generators must have the default type
    gens := ShallowCopy(gens);
    for i  in [ 1 .. Length(gens) ]  do
        if not sc[SCP_IS_DEFAULT_TYPE](gens[i])  then
            # this generates words in syllable rep!
            gens[i] := AssocWord( sc[SCP_DEFAULT_TYPE],
                                  ExtRepOfObj(gens[i]) );
        fi;
    od;
    sc[SCP_RWS_GENERATORS] := gens;
    sc[SCP_NUMBER_RWS_GENERATORS] := Length(sc[SCP_RWS_GENERATORS]);

    # the rhs of the powers
    sc[SCP_POWERS] := [];

    # and the inverses of the generators
    sc[SCP_INVERSES] := [];

    # and the rhs of the conjugates
    sc[SCP_CONJUGATES] := List( sc[SCP_RWS_GENERATORS], x -> [] );

    # convert into a list object and set number of bits
    type := NewType( fam, IsSingleCollectorRep and bits and IsFinite
                          and IsMutable );
    Objectify( type, sc );
    SetFilterObj( sc, HasUnderlyingFamily      );
    SetFilterObj( sc, HasRelativeOrders        );
    SetFilterObj( sc, HasGeneratorsOfRws       );
    SetFilterObj( sc, HasNumberGeneratorsOfRws );

    # there are no right hand sides
    SetFilterObj( sc, IsDefaultRhsTypeSingleCollector );

    # we haven't computed the avector and the inverses
    OutdatePolycyclicCollector(sc);

    # and return
    return sc;

end );


#############################################################################
##
#M  NumberGeneratorsOfRws( <sc> )
##
InstallMethod( NumberGeneratorsOfRws,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep ],
    0,

function( sc )
    return sc![SCP_NUMBER_RWS_GENERATORS];
end );


#############################################################################
##
#M  GeneratorsOfRws( <sc> )
##
InstallMethod( GeneratorsOfRws,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep ],
    0,

function( sc )
    return sc![SCP_RWS_GENERATORS];
end );


#############################################################################
##
#M  UnderlyingFamily( <sc> )
##
InstallMethod( UnderlyingFamily,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep ],
    0,

function( sc )
    return sc![SCP_UNDERLYING_FAMILY];
end );


#############################################################################
##
#M  RelativeOrders( <sc> )
##
InstallMethod( RelativeOrders,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep ],
    0,

function( sc )
    return sc![SCP_RELATIVE_ORDERS];
end );


#############################################################################
##
#M  CollectWordOrFail( <sc>, <v>, <w> )
##


#############################################################################
InstallMethod( CollectWordOrFail,
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
      and IsUpToDatePolycyclicCollector,
      IsList,
      IsMultiplicativeElementWithInverse ],
    0,
    SingleCollector_CollectWord );


#############################################################################
InstallMethod( CollectWordOrFail,
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPowerConjugateCollector and IsFinite and Is8BitsSingleCollectorRep
      and IsDefaultRhsTypeSingleCollector and IsUpToDatePolycyclicCollector,
      IsList,
      Is8BitsAssocWord ],
    0,
    FinPowConjCol_CollectWordOrFail );


#############################################################################
InstallMethod( CollectWordOrFail,
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPowerConjugateCollector and IsFinite and Is16BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector and IsUpToDatePolycyclicCollector,
      IsList,
      Is16BitsAssocWord ],
    0,
    FinPowConjCol_CollectWordOrFail );


#############################################################################
InstallMethod( CollectWordOrFail,
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPowerConjugateCollector and IsFinite and Is32BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      IsList,
      Is32BitsAssocWord ],
    0,
    FinPowConjCol_CollectWordOrFail );


#############################################################################
##
#M  ShallowCopy( <sc> )
##
BindGlobal( "ShallowCopy_SingleCollector", function( sc )
    local   copy;

    # construct new single collector as list object
    copy := [];

    # we need the family
    copy[SCP_UNDERLYING_FAMILY] := sc![SCP_UNDERLYING_FAMILY];

    # and the relative orders
    copy[SCP_RELATIVE_ORDERS] := ShallowCopy(sc![SCP_RELATIVE_ORDERS]);

    # and a default type
    copy[SCP_DEFAULT_TYPE] := sc![SCP_DEFAULT_TYPE];
    copy[SCP_IS_DEFAULT_TYPE] := sc![SCP_IS_DEFAULT_TYPE];

    # the generators must have the default type
    copy[SCP_RWS_GENERATORS] := ShallowCopy(sc![SCP_RWS_GENERATORS]);
    copy[SCP_NUMBER_RWS_GENERATORS] := sc![SCP_NUMBER_RWS_GENERATORS];

    # the rhs of the powers
    copy[SCP_POWERS] := ShallowCopy(sc![SCP_POWERS]);

    # and the inverses of the generators
    copy[SCP_INVERSES] := ShallowCopy(sc![SCP_INVERSES]);

    # and the rhs of the conjugates
    copy[SCP_CONJUGATES] := List( sc![SCP_CONJUGATES], ShallowCopy );

    # and the avector
    if IsBound(sc![SCP_AVECTOR])  then
        copy[SCP_AVECTOR] := ShallowCopy(sc![SCP_AVECTOR]);
    fi;

    # and the collector to use
    copy[SCP_COLLECTOR] := sc![SCP_COLLECTOR];

    # convert into a list object
    copy := Objectify( TypeObj(sc), copy );
    SetFilterObj( copy, IsMutable );
    return copy;

end );

InstallMethod( ShallowCopy,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep ],
    0,
    ShallowCopy_SingleCollector );

#############################################################################
##
#M  NonTrivialRightHandSides( <sc> )
##
InstallMethod( NonTrivialRightHandSides,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep ],
    0,

function( sc )
    local   rels,  len,  i,  j;

    rels := [];
    len  := NumberGeneratorsOfRws(sc);
    for i  in [ 1 .. len ]  do
        if IsBound(sc![SCP_POWERS][i])  then
            Add( rels, [ i, sc![SCP_POWERS][i] ] );
        fi;
    od;
    for i  in [ 1 .. len ]  do
        for j  in [ 1 .. i-1 ]  do
            if IsBound(sc![SCP_CONJUGATES][i][j])  then
                Add( rels, [ i, j, sc![SCP_CONJUGATES][i][j] ] );
            fi;
        od;
    od;
    return rels;
end );


#############################################################################
##
#M  ObjByExponents( <sc>, <data> )
##
InstallMethod( ObjByExponents,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep,
      IsList ],
    0,

function( sc, data )
    return ObjByVector( sc![SCP_DEFAULT_TYPE], data );
end );


#############################################################################
##
#M  ViewObj( <sc> )
##


#############################################################################
InstallMethod( ViewObj,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep ],
    0,

function( sc )
    Print( "<<single collector>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    Print( "<<up-to-date single collector>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    true,
    [ IsPowerConjugateCollector and IsFinite
          and Is8BitsSingleCollectorRep ],
    0,

function( sc )
    Print( "<<single collector, 8 Bits>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    true,
    [ IsPowerConjugateCollector and IsFinite and Is8BitsSingleCollectorRep
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    Print( "<<up-to-date single collector, 8 Bits>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    true,
    [ IsPowerConjugateCollector and IsFinite
          and Is16BitsSingleCollectorRep ],
    0,

function( sc )
    Print( "<<single collector, 16 Bits>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    true,
    [ IsPowerConjugateCollector and IsFinite and Is16BitsSingleCollectorRep
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    Print( "<<up-to-date single collector, 16 Bits>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    true,
    [ IsPowerConjugateCollector and IsFinite
          and Is32BitsSingleCollectorRep ],
    0,

function( sc )
    Print( "<<single collector, 32 Bits>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    true,
    [ IsPowerConjugateCollector and IsFinite and Is32BitsSingleCollectorRep
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    Print( "<<up-to-date single collector, 32 Bits>>" );
end );


#############################################################################
##
#M  PrintObj( <sc> )
##


#############################################################################
InstallMethod( PrintObj,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep ],
    0,

function( sc )
    Print( "<<single collector>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    Print( "<<up-to-date single collector>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    true,
    [ IsPowerConjugateCollector and IsFinite
          and Is8BitsSingleCollectorRep ],
    0,

function( sc )
    Print( "<<single collector, 8 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    true,
    [ IsPowerConjugateCollector and IsFinite and Is8BitsSingleCollectorRep
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    Print( "<<up-to-date single collector, 8 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    true,
    [ IsPowerConjugateCollector and IsFinite
          and Is16BitsSingleCollectorRep ],
    0,

function( sc )
    Print( "<<single collector, 16 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    true,
    [ IsPowerConjugateCollector and IsFinite and Is16BitsSingleCollectorRep
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    Print( "<<up-to-date single collector, 16 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    true,
    [ IsPowerConjugateCollector and IsFinite
          and Is32BitsSingleCollectorRep ],
    0,

function( sc )
    Print( "<<single collector, 32 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    true,
    [ IsPowerConjugateCollector and IsFinite and Is32BitsSingleCollectorRep
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    Print( "<<up-to-date single collector, 32 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
##
#M  ReducedComm( <sc>, <left>, <right> )
##


#############################################################################
InstallMethod( ReducedComm,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is8BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is8BitsAssocWord,
      Is8BitsAssocWord ],
    0,
    FinPowConjCol_ReducedComm );


#############################################################################
InstallMethod( ReducedComm,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is16BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is16BitsAssocWord,
      Is16BitsAssocWord ],
    0,
    FinPowConjCol_ReducedComm );


#############################################################################
InstallMethod( ReducedComm,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is32BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is32BitsAssocWord,
      Is32BitsAssocWord ],
    0,
    FinPowConjCol_ReducedComm );


#############################################################################
##
#M  ReducedInverse( <sc>, <word> )
##
InstallMethod( ReducedInverse,
    IsIdenticalObjFamiliesRwsObj,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep,
      IsAssocWord ],
    0,

function( sc, word )
    return SingleCollector_Solution( sc, word,
               AssocWord( sc![SCP_DEFAULT_TYPE], [] ) );
end );


#############################################################################
##
#M  ReducedForm( <sc>, <word> )
##


#############################################################################
InstallMethod( ReducedForm,
    IsIdenticalObjFamiliesRwsObj,
    [ IsPowerConjugateCollector and IsFinite and Is8BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is8BitsAssocWord ],
    0,
    FinPowConjCol_ReducedForm );


#############################################################################
InstallMethod( ReducedForm,
    IsIdenticalObjFamiliesRwsObj,
    [ IsPowerConjugateCollector and IsFinite and Is16BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is16BitsAssocWord ],
    0,
    FinPowConjCol_ReducedForm );


#############################################################################
InstallMethod( ReducedForm,
    IsIdenticalObjFamiliesRwsObj,
    [ IsPowerConjugateCollector and IsFinite and Is32BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is32BitsAssocWord ],
    0,
    FinPowConjCol_ReducedForm );


#############################################################################
##
#M  ReducedLeftQuotient( <sc>, <left>, <right> )
##


#############################################################################
InstallMethod( ReducedLeftQuotient,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is8BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is8BitsAssocWord,
      Is8BitsAssocWord ],
    0,
    FinPowConjCol_ReducedLeftQuotient );


#############################################################################
InstallMethod( ReducedLeftQuotient,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is16BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is16BitsAssocWord,
      Is16BitsAssocWord ],
    0,
    FinPowConjCol_ReducedLeftQuotient );


#############################################################################
InstallMethod( ReducedLeftQuotient,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is32BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is32BitsAssocWord,
      Is32BitsAssocWord ],
    0,
    FinPowConjCol_ReducedLeftQuotient );


#############################################################################
##
#M  ReducedOne( <sc> )
##
InstallMethod( ReducedOne,
    true,
    [ IsPowerConjugateCollector and IsFinite and IsSingleCollectorRep ],
    0,

function( sc )
    return AssocWord( sc![SCP_DEFAULT_TYPE], [] );
end );


#############################################################################
##
#M  ReducedProduct( <sc>, <left>, <right> )
##


#############################################################################
InstallMethod( ReducedProduct,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is8BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is8BitsAssocWord,
      Is8BitsAssocWord ],
    0,
    FinPowConjCol_ReducedProduct );


#############################################################################
InstallMethod( ReducedProduct,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is16BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is16BitsAssocWord,
      Is16BitsAssocWord ],
    0,
    FinPowConjCol_ReducedProduct );


#############################################################################
InstallMethod( ReducedProduct,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is32BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is32BitsAssocWord,
      Is32BitsAssocWord ],
    0,
    FinPowConjCol_ReducedProduct );


#############################################################################
##
#M  ReducedPower( <sc>, <left>, <pow> )
##


#############################################################################
InstallMethod( ReducedPower,
    IsIdenticalObjFamiliesRwsObjXXX,
    [ IsPowerConjugateCollector and IsFinite and Is8BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is8BitsAssocWord,
      IsInt and IsSmallIntRep ],
    0,
    FinPowConjCol_ReducedPowerSmallInt );


#############################################################################
InstallMethod( ReducedPower,
    IsIdenticalObjFamiliesRwsObjXXX,
    [ IsPowerConjugateCollector and IsFinite and Is16BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is16BitsAssocWord,
      IsInt and IsSmallIntRep ],
    0,
    FinPowConjCol_ReducedPowerSmallInt );


#############################################################################
InstallMethod( ReducedPower,
    IsIdenticalObjFamiliesRwsObjXXX,
    [ IsPowerConjugateCollector and IsFinite and Is32BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is32BitsAssocWord,
      IsInt and IsSmallIntRep ],
    0,
    FinPowConjCol_ReducedPowerSmallInt );


#############################################################################
##
#M  ReducedQuotient( <sc>, <left>, <right> )
##


#############################################################################
InstallMethod( ReducedQuotient,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is8BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is8BitsAssocWord,
      Is8BitsAssocWord ],
    0,
    FinPowConjCol_ReducedQuotient );


#############################################################################
InstallMethod( ReducedQuotient,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is16BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is16BitsAssocWord,
      Is16BitsAssocWord ],
    0,
    FinPowConjCol_ReducedQuotient );


#############################################################################
InstallMethod( ReducedQuotient,
    IsIdenticalObjFamiliesRwsObjObj,
    [ IsPowerConjugateCollector and IsFinite and Is32BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector,
      Is32BitsAssocWord,
      Is32BitsAssocWord ],
    0,
    FinPowConjCol_ReducedQuotient );
