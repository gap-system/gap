#############################################################################
##
#W  rwspcftl.g                  GAP Library                     Werner Nickel
##
##
Revision.rwspcftl_gi :=
    "@(#)$Id$";


#############################################################################
##
##  First we need a new representation for a power-conjugate collector, which
##  will  implement the  generic collector  for  groups given by a polycyclic
##  presentation.
##
#R  IsFromTheLeftCollectorRep( <obj> )  . . . . . . . . . . . . . . . . . . .
##
IsFromTheLeftCollectorRep :=
  NewRepresentation( "IsFromTheLeftCollectorRep",
          IsPowerConjugateCollector and IsMutable, [] );
          
FromTheLeftCollectorFamily := NewFamily( "FromTheLeftCollector",
                                      IsFromTheLeftCollectorRep );
                                      
#############################################################################
##  
#P  The following property is used to dispatch between a GAP level collector
#P  and the kernel collector.           . . . . . . . . . . . . . . . . . . .
##
UseKernelCollector := NewProperty( "UseKernelCollector",
                              IsFromTheLeftCollectorRep  );
SetUseKernelCollector := Setter( UseKernelCollector );

#############################################################################
##
##  Next the  operation for creating a from the left collector is defined.
##
#O  FromTheLeftCollector. . . . . . . . . . . . . . . . . . . . . . . . . . .
##
FromTheLeftCollector := NewOperation( "FromTheLeftCollector", [IsObject] );

##
#M  FromTheLeftCollector( <pos int> ) . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( FromTheLeftCollector, 
        true, 
        [ IsInt and IsPosRat ], 
        0,
        function( nrgens )
    local   pcp;
    
    pcp := [];
    pcp[ PC_NUMBER_OF_GENERATORS ]     := nrgens;
    pcp[ PC_GENERATORS ]               := List( [1..nrgens], i -> [i,  1] );
    pcp[ PC_INVERSES ]                 := List( [1..nrgens], i -> [i,0-1] );
    pcp[ PC_COMMUTE ]                  := [];
    pcp[ PC_POWERS ]                   := [];
    pcp[ PC_INVERSEPOWERS ]            := [];
    pcp[ PC_EXPONENTS ]                := [];
    pcp[ PC_CONJUGATES ]               := List( [1..nrgens], i -> [] );
    pcp[ PC_INVERSECONJUGATES ]        := List( [1..nrgens], i -> [] );
    pcp[ PC_CONJUGATESINVERSE ]        := List( [1..nrgens], i -> [] );
    pcp[ PC_INVERSECONJUGATESINVERSE ] := List( [1..nrgens], i -> [] );
    pcp[ PC_DEEP_THOUGHT_POLS ]        := [];
    pcp[ PC_DEEP_THOUGHT_BOUND ]       := 666666;
    
    # Initialise the various stacks.
    pcp[ PC_STACK_SIZE ]               := 16 * nrgens;
    pcp[ PC_WORD_STACK ]               := [1..pcp[ PC_STACK_SIZE]] * 0;
    pcp[ PC_WORD_EXPONENT_STACK ]      := [1..pcp[ PC_STACK_SIZE]] * 0;
    pcp[ PC_SYLLABLE_STACK ]           := [1..pcp[ PC_STACK_SIZE]] * 0;
    pcp[ PC_EXPONENT_STACK ]           := [1..pcp[ PC_STACK_SIZE]] * 0;
    pcp[ PC_STACK_POINTER ]            := 0;

    return Objectify( NewType( FromTheLeftCollectorFamily,
                   IsFromTheLeftCollectorRep ), pcp );
end );

#############################################################################
##
#M  PrintObj( <pcc> ) . . . . . . . . . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( PrintObj, 
        true,
        [ IsFromTheLeftCollectorRep ],
        0,
        function( pcc )
    
    Print( "<<from the left collector with ",
           pcc![PC_NUMBER_OF_GENERATORS ],
           " generators>>" );
end );

#############################################################################
##
#M  SetPower( <pcc>, <gen>, <word> )  . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( SetPowerNC,
        true,
        [ IsFromTheLeftCollectorRep, IsInt and IsPosRat, IsList ], 
        0,
        function( pcp, g, w )
    
    if w = [] then 
        Unbind( pcp![ PC_POWERS ][g] );
    else
        pcp![ PC_POWERS ][g] := w;
    fi;
    
    OutdatePolycyclicCollector( pcp );
end );

InstallMethod( SetPower,
        true,
        [ IsFromTheLeftCollectorRep, IsInt and IsPosRat, IsList ], 
        0,
        function( pcp, g, w )
    local   n,  i;
    
    n := pcp![ PC_NUMBER_OF_GENERATORS ];
    if g < 1 or g > n then
        Error( "Generator out of range" );
    fi;
    for i in [1..Length(w)] do
        if not IsInt(w[i]) then
            Error( "List of integers expected" );
        fi;
        if i mod 2 = 1 and (w[i] <= g or w[i] > n) then
            Error( "Generator in word out of range" );
        fi;
    od;
    
    SetPowerNC( pcp, g, w );
end );    

#############################################################################
##
#F  SetCommutator . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( SetCommutator,
        true,
        [ IsFromTheLeftCollectorRep, IsInt, IsInt, IsList ],
        0,
        function( pcp, h, g, comm )
    local   i,  conj;
    
    if AbsInt( h ) <= AbsInt( g ) then
        Error( "Left generator not smaller than right generator" );
    fi;
    if AbsInt( h ) > pcp![ PC_NUMBER_OF_GENERATORS ] then
        Error( "Left generators too large" );
    fi;
    if AbsInt( g ) < 1 then
        Error( "Right generators too small" );
    fi;
    
    for i in [1..Length(comm)] do
        if not IsInt(comm[i]) then
            Error( "List of integers expected" );
        fi;
        if i mod 2 = 1 then  # check generators
            if comm[i] <= g or comm[i] > pcp![PC_NUMBER_OF_GENERATORS ] then
                Error( "Generator in word out of range" );
            fi;
        fi;
    od;
    
    # h^g = h * [h,g]
    conj := [ h, 1 ];
    for i in comm do conj[ Length(conj)+1 ] := i; od;
    SetConjugateNC( pcp, h, g, conj );
end );

#############################################################################
##
#M  SetConjugate( <pcc>, <gen>, <gen>, <word> ) . . . . . . . . . . . . . . .
##
InstallMethod( SetConjugateNC,
        true,
        [ IsFromTheLeftCollectorRep, IsInt, IsInt, IsList ],
        0,
        function( pcp, h, g, w )
        
    if g > 0 then
        if h > 0 then
            if w = pcp![ PC_GENERATORS ][h] then
                Unbind( pcp![ PC_CONJUGATES ][h][g] );
            else
                pcp![ PC_CONJUGATES ][h][g] := w;
            fi;
        else
            if w = pcp![ PC_INVERSES ][-h] then
                Unbind( pcp![ PC_INVERSECONJUGATES ][-h][g] );
            else
                pcp![ PC_INVERSECONJUGATES ][-h][g] := w;
            fi;
        fi;
    else    
        if h > 0 then 
            if w = pcp![ PC_GENERATORS ][h] then
                Unbind( pcp![ PC_CONJUGATESINVERSE ][h][-g] );
            else
                pcp![ PC_CONJUGATESINVERSE ][h][-g] := w;
            fi;
        else
            if w = pcp![ PC_INVERSES ][-h] then
                Unbind( pcp![ PC_INVERSECONJUGATESINVERSE ][-h][-g] );
            else
                pcp![ PC_INVERSECONJUGATESINVERSE ][-h][-g] := w;
            fi;
        fi;
    fi;
    OutdatePolycyclicCollector( pcp );
end );

InstallMethod( SetConjugate,
        true,
        [ IsFromTheLeftCollectorRep, IsInt, IsInt, IsList ],
        0,
        function( pcp, h, g, w )
    local   i;
    
    if AbsInt( h ) <= AbsInt( g ) then
        Error( "Left generator not smaller than right generator" );
    fi;
    if AbsInt( h ) > pcp![ PC_NUMBER_OF_GENERATORS ] then
        Error( "Left generators too large" );
    fi;
    if AbsInt( g ) < 1 then
        Error( "Right generators too small" );
    fi;
    
    for i in [1..Length(w)] do
        if not IsInt(w[i]) then
            Error( "List of integers expected" );
        fi;
        if i mod 2 = 1 then  # check generators
            if w[i] <= g or w[i] > pcp![PC_NUMBER_OF_GENERATORS ] then
                Error( "Generator in word out of range" );
            fi;
        fi;
    od;
    
    SetConjugateNC( pcp, h, g, w );
end );

#############################################################################
##
#M  SetRelativeOrder( <pcc>, <gen>, <order> ) . . . . . . . . . . . . . . . .
##
InstallMethod( SetRelativeOrderNC,
        true,
        [ IsFromTheLeftCollectorRep, IsInt and IsPosRat, IsInt and IsPosRat ],
        0,
        function( pcp, g, order )
    
    pcp![ PC_EXPONENTS ][g] := order;
end );

InstallMethod( SetRelativeOrder,
        true,
        [ IsFromTheLeftCollectorRep, IsInt and IsPosRat, IsInt and IsPosRat ],
        0,
        function( pcp, g, order )
    
    if g < 1 or g > pcp![ PC_NUMBER_OF_GENERATORS ] then
        Error( "Generator out of reange" );
    fi;
    
    SetRelativeOrderNC( pcp, g, order );
end );

    
InstallMethod( GeneratorsOfRws,
        true,
        [ IsFromTheLeftCollectorRep ],
        0,
        function( pcc )
    
    return pcc![ PC_GENERATORS ];
end );


#############################################################################
##
#F  FromTheLeftCollector_SetCommute . . . . . . . . . . . . . . . . . . . . .
##
FromTheLeftCollector_SetCommute := function( pcp )
    local   com,  cnj,  n,  g,  again,  h;
    
    n   := pcp![ PC_NUMBER_OF_GENERATORS ];
    cnj := pcp![ PC_CONJUGATES ];
    ##
    ##    Commute[i] is the smallest j >= i such that a_i,...,a_n
    ##    commute with a_(j+1),...,a_n.
    ##
    com := [1..n] * 0 + n;
    for g in [n-1,n-2..1] do
        ##
        ##    After the following loop two cases can occur :
        ##    a) h > g+1. In this case h is the first generator among
        ##       a_n,...,a_(j+1) with which g does not commute.
        ##    b) h = g+1. Then Commute[g+1] = g+1 follows and g
        ##       commutes with all generators a_(g+2),..,a_n. So it
        ##       has to be checked whether a_g and a_(g+1) commute.
        ##       If that is the case, then Commute[g] = g. If not
        ##       then Commute[g] = g+1 = h.
        ##
        again := true;
        h := n;
        while again and h > com[g+1] do
            if IsBound( cnj[h][g] ) then
                again := false;
            else
                h := h-1;
            fi;
        od;

        if h = g+1 and not IsBound( cnj[h][g] ) then
            com[g] := g;
        else    
            com[g] := h;
        fi;
    od;
    
    pcp![ PC_COMMUTE ] := com;
end;

FromTheLeftCollector_Inverse := "still to come";

#############################################################################
##
#F  FromTheLeftCollector_ExponentSums . . . . . . . . . . . . . . . . . . . .
##
FromTheLeftCollector_ExponentSums := function( u, a, z )
    local   sums,  i,  g;
    
    sums := [a..z] * 0;
    z := z - a + 1;
    for i in [1,3..Length(u)-1] do
        g := u[i] - a + 1;
        if g >= 1 and g <= z then
            sums[ g ] := sums[ g ] + u[ i+1 ];
        fi;
    od;
    return sums;
end;

            
#############################################################################
##
#F  FromTheLeftCollector_CompleteConjugate  . . . . . . . . . . . . . . . . .
##
FromTheLeftCollector_CompleteConjugate := function( pcp )
    local   n,  i,  j,  cnj,  comm,  ev;
    
    n := pcp![ PC_NUMBER_OF_GENERATORS ];
    for i in [n,n-1..1 ] do
        for j in [n,n-1..i+1] do
            
            if IsBound( pcp![ PC_CONJUGATES ][j][i] ) then
                if not IsBound( pcp![ PC_CONJUGATESINVERSE ][j][i] ) then
                    # This only works if the presentation is nilpotent.
                    # [b,a^-1] = a * [a,b] * a^-1;
                    cnj := pcp![ PC_CONJUGATES ][j][i];
                    comm := cnj{[3..Length(cnj)]};
                    # compute [a,b] * a^-1
                    comm := FromTheLeftCollector_Inverse( pcp, comm );
                    ev := FromTheLeftCollector_ExponentSums( comm, 1, n );
                    CollectWordOrFail( pcp, ev, [ i, -1 ] );
                    # wipe out a, prepend b
                    ev[i] := 0;  ev[j] := 1;
                    pcp![ PC_CONJUGATESINVERSE ][j][i] := 
                      ObjByExponents(pcp, ev);
                fi;
                if not IsBound( pcp![ PC_INVERSECONJUGATES ][j][i] ) then
                    pcp![ PC_INVERSECONJUGATES ][j][i] := 
                      FromTheLeftCollector_Inverse( pcp,
                              pcp![ PC_CONJUGATES ][j][i] );
                fi;
                if not IsBound( pcp![ PC_INVERSECONJUGATESINVERSE ][j][i] ) then
                    pcp![ PC_INVERSECONJUGATESINVERSE ][j][i] := 
                      FromTheLeftCollector_Inverse( pcp,
                              pcp![ PC_CONJUGATESINVERSE ][j][i] ); 
                fi;
            fi;
        od;
    od;
end;

#############################################################################
##
#F  FromTheLeftCollector_CompletePowers . . . . . . . . . . . . . . . . . . .
##
FromTheLeftCollector_CompletePowers := function( pcp )
    local   n,  i;
    
    n := pcp![ PC_NUMBER_OF_GENERATORS ];
    pcp![ PC_INVERSEPOWERS ] := [];
    for i in [n,n-1..1] do
        if IsBound( pcp![ PC_POWERS ][i] ) then
            pcp![ PC_INVERSEPOWERS ][i] :=
              FromTheLeftCollector_Inverse( pcp, pcp![ PC_POWERS ][i] );
        fi;
    od;
end;

#############################################################################
##
#M  UpdatePolycyclicCollector . . . . . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( UpdatePolycyclicCollector,
        "FromTheLeftCollector",
        true,
        [ IsFromTheLeftCollectorRep ],
        0,
        function( pcp )
    
    FromTheLeftCollector_SetCommute( pcp );

    ## We have to declare the collector up to date now because the following
    ## functions need to collect and are careful enough.
    SetFeatureObj( pcp, IsUpToDatePolycyclicCollector, true );

    FromTheLeftCollector_CompleteConjugate( pcp );
    FromTheLeftCollector_CompletePowers( pcp );
    
end );


#############################################################################
##
#M  CollectWordOrFail . . . . . . . . . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( CollectWordOrFail,
        "FromTheLeftCollector (outdated)",
        true, 
        [ IsFromTheLeftCollectorRep,
          IsList, IsList ],
        0,
        function( pcp, ev, w )

    Error( "Collector is out of date" );
end );

InstallMethod( CollectWordOrFail,
        "FromTheLeftCollector",
        true, 
        [ IsFromTheLeftCollectorRep and IsUpToDatePolycyclicCollector and
          UseKernelCollector, 
          IsList, IsList ],
        0,
        function( pcp, ev, w )

    CollectPolycyclic( pcp, ev, w );
end );

InstallMethod( CollectWordOrFail,
        "FromTheLeftCollector",
        true, 
        [ IsFromTheLeftCollectorRep and IsUpToDatePolycyclicCollector,
          IsList, IsList ],
        0,
        function( pcp, ev, w )
    
    local   pow,  exp,  com,  wst,  west,  sst,  est,  bottom,  stp,  
            g,  cnj,  icnj,  h;
    
    if Length( w ) = 0 then return; fi;
    
    pow := pcp![ PC_POWERS ];
    exp := pcp![ PC_EXPONENTS ];
    com := pcp![ PC_COMMUTE ];
    
    wst  := pcp![ PC_WORD_STACK ];
    west := pcp![ PC_WORD_EXPONENT_STACK ];
    sst  := pcp![ PC_SYLLABLE_STACK ];
    est := pcp![ PC_EXPONENT_STACK ];
    
    bottom    := pcp![ PC_STACK_POINTER ];
    stp       := bottom + 1;
    wst[stp]  := w;
    west[stp] := 1;
    sst[stp]  := 1;
    est[stp] := w[ 2 ];

    # collect
    while stp > bottom do
        
        if est[stp] = 0 then
            # initialise est
            sst[stp] := sst[stp] + 1;
            if sst[stp] > Length(wst[stp])/2 then
                west[stp] := west[stp] - 1;
                if west[stp] = 0 then
                    stp := stp - 1;
                else
                    sst[stp] := 1;
                    est[stp] := wst[stp][2];
                fi;
            else
                est[stp] := wst[stp][ 2*sst[stp] ];
            fi;
        else
            
            if DebugPcc then
                Print( wst{[1..stp]}, "\n", 
                       west{[1..stp]}, "\n", 
                       sst{[1..stp]}, "\n",
                       est{[1..stp]}, "\n\n" );
            fi;
            # get next generator
            g := wst[stp][ 2*sst[stp]-1 ];
            
            if g = com[g] then
                # move generator directly to its correct position
                ev[g] := ev[g] + est[stp];
                est[stp] := 0;
            else
                if est[stp] > 0 then
                    est[stp] := est[stp] - 1;
                    ev[g] := ev[g] + 1;
                    cnj   := pcp![ PC_CONJUGATES ];
                    icnj  := pcp![ PC_INVERSECONJUGATES ];
                else
                    est[stp] := est[stp] + 1;
                    ev[g] := ev[g] - 1;
                    cnj   := pcp![ PC_CONJUGATESINVERSE ];
                    icnj  := pcp![ PC_INVERSECONJUGATESINVERSE ];
                fi;
                # move generator across the exponent vector
                for h in [com[g],com[g]-1..g+1] do
                    if ev[h] <> 0 then
                        stp := stp+1;
                        if stp > pcp![ PC_STACK_SIZE ] then
                            return fail;
                        fi;
                        if ev[h] > 0 then
                            if IsBound( cnj[h][g] ) then
                                wst[stp]  := cnj[h][g];
                                west[stp] := ev[h];
                            else
                                wst[stp]  := pcp![ PC_GENERATORS ][h];
                                west[stp] := ev[h];
                            fi;
                        else
                            if IsBound( icnj[h][g] ) then
                                wst[stp]  := icnj[h][g];
                                west[stp] := -ev[h];
                            else
                                wst[stp]  := pcp![ PC_INVERSES ][h];
                                west[stp] := -ev[h];
                            fi;
                        fi;
                        sst[stp]  := 1;
                        est[stp] := wst[stp][ 2 ];
                        ev[h] := 0;    
                    fi;
                od;
            fi;
            
            # reduce exponent if necessary
            if IsBound( exp[g] ) and ev[g] >= exp[g] then
                ev[g] := ev[g] - exp[g];
                if IsBound( pow[g] ) then
                    stp := stp+1;
                    if stp > pcp![ PC_STACK_SIZE ] then
                        return fail;
                    fi;
                    wst[stp]  := pow[g];
                    west[stp] := 1;
                    sst[stp]  := 1;
                    est[stp] := wst[stp][ 2 ];
                fi;
            fi;
        fi;
    od;
end );
        

#############################################################################
##
#M  ObjByExponents  . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( ObjByExponents,
        true,
        [ IsFromTheLeftCollectorRep, IsList ],
        0,
        function( pcp, exps ) 
    local   w,  i;

    w := [];
    for i in [1..Length(exps)] do
        if exps[i] <> 0 then
            Add( w, i );
            Add( w, exps[i] );
        fi;
    od;
    return w;
end );



#############################################################################
##
#F  FromTheLeftCollector_Solution . . . . .  solve the equation u x = v for x
##
FromTheLeftCollector_Solution := function( pcp, u, v )
    local   e,  n,  x,  i,  g;
    
    n := pcp![ PC_NUMBER_OF_GENERATORS ];
    u := FromTheLeftCollector_ExponentSums( u, 1, n );
    v := FromTheLeftCollector_ExponentSums( v, 1, n );
    
    x := [];
    for i in [1..n] do
        e := v[i] - u[i];
        if IsBound(pcp![ PC_EXPONENTS ][i]) and e < 0 then
            e := e + pcp![ PC_EXPONENTS ][i];
        fi;
        if e <> 0 then
            g := ShallowCopy( pcp![ PC_GENERATORS ][i] ); g[2] := e;
            Append( x, g );
            CollectWordOrFail( pcp, u, g );
        fi;
    od;

    return x;
end;
                                
#############################################################################
##
#F  FromTheLeftCollector_Inverse  . . inverse of a word wrt a pc presentation
##
FromTheLeftCollector_Inverse := function( pcp, w )
    
    return FromTheLeftCollector_Solution( pcp, w, [] );
end;

#############################################################################
##
#F  FromTheLeftCollector_Power  . . . . . . . . . . . . . . . . . . . . . .  
##
FromTheLeftCollector_Power := function( pcp, w, e )

    if e < 0 then
        w := FromTheLeftCollector_Inverse( pcp, w );
        e := -e;
    fi;

    return BinaryPower( pcp, w, e );
end;

#############################################################################
##
#F  ProductAutomorphisms  . . . . . . . . . . . . . . . . . . . . . . . . .  
##
ProductAutomorphisms := function( pcp, alpha, beta )
    local   ngens,  gamma,  i,  w,  ev,  g;

    ngens := NumberGeneratorsOfRws( pcp );
    gamma := [];
    for i in [1..ngens] do
        if IsBound( alpha[i] ) then
            w := alpha[i];
            ev := [1..ngens] * 0;
            for g in [1,3..Length(w)-1] do
                if w[g+1] <> 0 then
                    CollectWordOrFail( pcp, ev,
                            FromTheLeftCollector_Power( 
                                    pcp, beta[ w[g] ], w[g+1] ) );
                fi;
            od;
            gamma[i] := ObjByExponents( pcp, ev );
        fi;
    od;
    return gamma;
end;

#############################################################################
##
#F  PowerAutomorphism . . . . . . . . . . . . . . . . . . . . . . . . . . .  
##
PowerAutomorphism := function( pcp, g, e )
    local   n,  a,  power,  h,  ipower;
    
    n := NumberGeneratorsOfRws( pcp );
    
    # initialise automorphism
    a := [];
    power := [];
    for h in [g+1..n] do
        if e > 0 then 
            if IsBound( pcp![ PC_CONJUGATES][h] ) and
                       IsBound( pcp![ PC_CONJUGATES ][h][g] ) then
                a[h] := pcp![ PC_CONJUGATES ][h][g];
            else
                a[h] := [h,1];
            fi;
        else
            if IsBound( pcp![ PC_CONJUGATESINVERSE ][h] ) and
                       IsBound( pcp![ PC_CONJUGATESINVERSE ][h][g] ) then
                a[h] := pcp![ PC_CONJUGATESINVERSE ][h][g];
            else
                a[h] := [h,1];
            fi;
        fi;
        power[h] := [h,1];    
    od;
    if e < 0 then
        e := -e;
    fi;

    while e > 0 do
        if e mod 2 = 1 then
            power := ProductAutomorphisms( pcp, power, a );
        fi;
        e := Int( e / 2 );
        if e > 0 then
            a := ProductAutomorphisms( pcp, a, a );
        fi;
    od;
    ipower := [];
    for h in [g+1..n] do
        ipower[h] := FromTheLeftCollector_Inverse( pcp, power[h] );
    od;

    if DebugPcc then
        Print( "Returning from PowerAutomorphism with\n" );
        Print( "        ", power, "\n" );
        Print( "        ", ipower, "\n" );
    fi;
    return [ power, ipower ];
end;



#############################################################################
##
#M  IsConfluent . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
##
if not IsBound( InfoConsistency ) then
    InfoConsistency := function( arg ) end;
fi;
InstallMethod( IsConfluent,
        "FromTheLeftCollector",
        true,
        [ IsFromTheLeftCollectorRep ],
        0,
        function( pcp )
    local   n,  k,  j,  i,  ev1,  w,  ev2;
    
    n := pcp![ PC_NUMBER_OF_GENERATORS ];

    # k (j i) = (k j) i
    for k in [n,n-1..1] do
        for j in [k-1,k-2..1] do
            for i in [j-1,j-2..1] do
                InfoConsistency( "checking ", k, " ", j, " ", i, "\n" );
                ev1 := [1..n] * 0;
                CollectWordOrFail( pcp, ev1, [j,1,i,1] );
                w := ObjByExponents( pcp, ev1 );
                ev1 := FromTheLeftCollector_ExponentSums( [k,1], 1, n );
                CollectWordOrFail( pcp, ev1, w );
                
                ev2 := [1..n] * 0;
                CollectWordOrFail( pcp, ev2, [k,1,j,1,i,1] );
                
                if ev1 <> ev2 then
                    Print( "Inconsistency at ", k, " ", j, " ", i, "\n" );
                    return false;
                fi;
            od;
        od;
    od;
    
    # j^m i = j^(m-1) (j i)
    for j in [n,n-1..1] do
        for i in [j-1,j-2..1] do
            if IsBound(pcp![ PC_EXPONENTS ][j]) then
                InfoConsistency( "checking ", j, "^m ", i, "\n" );
                ev1 := [1..n] * 0;
                CollectWordOrFail( pcp, ev1, [j,pcp![ PC_EXPONENTS ][j], i,1] );
                
                ev2 := [1..n] * 0;
                CollectWordOrFail( pcp, ev2, [j,1,i,1] );
                w := ObjByExponents( pcp, ev2 );
                ev2 := FromTheLeftCollector_ExponentSums( 
                               [j,pcp![ PC_EXPONENTS ][j]-1], 1, n );
                CollectWordOrFail( pcp, ev2, w );
                
                if ev1 <> ev2 then
                    Print( "Inconsistency at ", j, "^m ", i, "\n" );
                    return false;
                fi;
            fi;
        od;
    od;
    
    # j * i^m = (j i) * i^(m-1)
    for j in [n,n-1..1] do
        if IsBound(pcp![ PC_EXPONENTS ][i]) then
            for i in [j-1,j-2..1] do
                InfoConsistency( "checking ", j, " ", i, "^m\n" );
                ev1 := FromTheLeftCollector_ExponentSums( [j,1], 1, n );
                if IsBound( pcp![ PC_POWERS ][i] ) then
                    CollectWordOrFail( pcp, ev1, pcp![ PC_POWERS ][i] );
                fi;
                
                ev2 := [1..n] * 0;
                CollectWordOrFail( pcp, ev2,
                        [ j,1,i,pcp![ PC_EXPONENTS ][i] ] );
                
                if ev1 <> ev2 then
                    Print( "Inconsistency at ", j, " ", i, "^m\n" );
                    return false;
                fi;
            od;
        fi;
    od;
    
    # i^m i = i i^m
    for i in [n,n-1..1] do
        if IsBound( pcp![ PC_EXPONENTS ][i] ) then
            ev1 := [1..n] * 0;
            CollectWordOrFail( pcp, ev1, [ i,pcp![ PC_EXPONENTS ][i]+1 ] );
            
            ev2 := FromTheLeftCollector_ExponentSums( [i,1], 1, n );
            if IsBound( pcp![ PC_POWERS ][i] ) then
                CollectWordOrFail( pcp, ev2, pcp![ PC_POWERS ][i] );
            fi;
            
            if ev1 <> ev2 then
                Print( "Inconsistency at ", i, "^(m+1)\n" );
                return false;
            fi;
        fi;
    od;
        
    # j = (j -i) i 
    for i in [n,n-1..1] do
        if not IsBound( pcp![ PC_EXPONENTS ][i] ) then
            for j in [i+1..n] do
                InfoConsistency( "checking ", j, " ", -i, " ", i, "\n" );
                ev1 := [1..n] * 0;
                CollectWordOrFail( pcp, ev1, [j,1,i,-1,i,1] );
                ev1[j] := ev1[j] - 1;
                if ev1 <> [1..n] * 0 then
                    Print( "Inconsistency at ", j, " ", -i, " ", i, "\n" );
                    return false;
                fi;
            od;
        fi;
    od;
    
    # i = -j (j i)
    for j in [n,n-1..1] do
        if not IsBound( pcp![ PC_EXPONENTS ][j] ) then
            for i in [j-1,j-2..1] do
                InfoConsistency( "checking ", -j, " ", j, " ", i, "\n" );
                ev1 := [1..n] * 0;
                CollectWordOrFail( pcp, ev1, [ j,1,i,1 ] );
                w := ObjByExponents( pcp, ev1 );
                ev1 := FromTheLeftCollector_ExponentSums( [j,-1], 1, n );
                CollectWordOrFail( pcp, ev1, w );
                
                if ev1 <> FromTheLeftCollector_ExponentSums( [i,1], 1, n ) then
                    Print( "Inconsistency at ", -j, " ", j, " ", i, "\n" );
                    return false;
                fi;
                
                if not IsBound( pcp![ PC_EXPONENTS ][i] ) then
                    InfoConsistency( "checking ", -j, " ", j, " ", -i, "\n" );
                    ev1 := [1..n] * 0;
                    CollectWordOrFail( pcp, ev1, [ j,1,i,-1 ] );
                    w := ObjByExponents( pcp, ev1 );
                    ev1 := FromTheLeftCollector_ExponentSums( [j,-1], 1, n );
                    CollectWordOrFail( pcp, ev1, w );
                    
                    if ev1 <> FromTheLeftCollector_ExponentSums(
                               [i,-1], 1, n ) then
                        Print( "Inconsistency at ", -j, " ", j, " ", -i, "\n" );
                        return false;
                    fi;
                fi;
            od;
        fi;
    od;
    return true;
end );


#############################################################################
##
#F  UseDeepThought  . . . . . . . . . . . . . . . . . initialise Deep Thought
##
UseDeepThought := function( pcp, dtbound, max )

    local   reps,  avec,  pr,  i;
    
    if dtbound < 1 then
        dtbound := 1;
    fi;

    reps := [];
    avec := pcp![ PC_COMMUTE ] + 1;
    pr   := pcp![ PC_CONJUGATES ];

    if  max >= Length(pr)  then
        max := Length(pr);
    fi;

    for  i in [dtbound..Length(pr)]  do
        if  i >= max  then
            max := Length(pr);
        fi;
        reps[i] := calcrepsn( i, avec, pr, max );
    od;
    max := 1;
    for  i in [1..Length(reps)]  do
        if  IsRecord(reps[i])  then
            max := i;
        fi;
    od;
    for  i in [1..max]  do
        if  not IsRecord(reps[i])  then
            reps[i] := 1;
        fi;
    od;
    pcp![ PC_DEEP_THOUGHT_POLS ] := reps;
    pcp![ PC_DEEP_THOUGHT_BOUND ] := dtbound;
end;

#############################################################################
##
#F  SetDeepThoughtBoundary  . . .  set the generator from which on DT is used
##
SetDeepThoughtBound := function( pcp, n )

    pcp![ PC_DEEP_THOUGHT_BOUND ] := n;
end;
