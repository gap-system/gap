#############################################################################
##
#W  collect.gi                 Polycyclic                       Werner Nickel
##

#############################################################################
##
#M  FromTheLeftCollector( <pos int> )
##
##  This function constructs a basic from-the-left collector.  A
##  from-the-left collector is a positional object.  The components defined
##  in this function are the ingredients used by the simple from-the-left
##  collector. 
##
InstallMethod( FromTheLeftCollector, 
        "for positive integer",
        [ IsInt ], 

function( nrgens )
    local   pcp;
    
    if nrgens < 0 then 
        return Error( "number of generators must not be negative" );
    fi;

    pcp := [];
    pcp[ PC_NUMBER_OF_GENERATORS ]     := nrgens;
    pcp[ PC_GENERATORS ]               := List( [1..nrgens], i -> [i, 1] );
    pcp[ PC_INVERSES ]                 := List( [1..nrgens], i -> [i,-1] );
    pcp[ PC_COMMUTE ]                  := [];
    pcp[ PC_POWERS ]                   := [];
    pcp[ PC_INVERSEPOWERS ]            := [];
    pcp[ PC_EXPONENTS ]                := [];
    pcp[ PC_CONJUGATES ]               := List( [1..nrgens], i -> [] );
    pcp[ PC_INVERSECONJUGATES ]        := List( [1..nrgens], i -> [] );
    pcp[ PC_CONJUGATESINVERSE ]        := List( [1..nrgens], i -> [] );
    pcp[ PC_INVERSECONJUGATESINVERSE ] := List( [1..nrgens], i -> [] );

    pcp[ PC_COMMUTATORS ]               := List( [1..nrgens], i -> [] );
    pcp[ PC_INVERSECOMMUTATORS ]        := List( [1..nrgens], i -> [] );
    pcp[ PC_COMMUTATORSINVERSE ]        := List( [1..nrgens], i -> [] );
    pcp[ PC_INVERSECOMMUTATORSINVERSE ] := List( [1..nrgens], i -> [] );

    pcp[ PC_DEEP_THOUGHT_POLS ]        := [];
    pcp[ PC_DEEP_THOUGHT_BOUND ]       := 666666;
    
    # Initialise the various stacks.
    pcp[ PC_STACK_SIZE ]               := 1024 * nrgens;
    pcp[ PC_WORD_STACK ]               := 
      ListWithIdenticalEntries( pcp[ PC_STACK_SIZE], 0 );
    pcp[ PC_WORD_EXPONENT_STACK ]      := 
      ListWithIdenticalEntries( pcp[ PC_STACK_SIZE], 0 );
    pcp[ PC_SYLLABLE_STACK ]           := 
      ListWithIdenticalEntries( pcp[ PC_STACK_SIZE], 0 );
    pcp[ PC_EXPONENT_STACK ]           := 
      ListWithIdenticalEntries( pcp[ PC_STACK_SIZE], 0 );
    pcp[ PC_STACK_POINTER ]            := 0;
    pcp[ PC_PCP_ELEMENTS_FAMILY ]      := 
          NewFamily( "ElementsFamily<<coll>>", IsPcpElement, IsPcpElement );
    pcp[ PC_PCP_ELEMENTS_TYPE ]        := 
          NewType( pcp![PC_PCP_ELEMENTS_FAMILY], IsPcpElementRep );

    return Objectify( NewType( FromTheLeftCollectorFamily,
                   IsFromTheLeftCollectorRep and IsMutable ), pcp );
end );

InstallMethod( FromTheLeftCollector,
        "for free groups",
        [ IsFreeGroup and IsWholeFamily ],

        F -> FromTheLeftCollector( Length( GeneratorsOfGroup( F ) ) )
);

#############################################################################
##
##  Functions to view and print a from-the-left collector.
##
#M  ViewObj( <coll> )
##
InstallMethod( ViewObj, 
        "for from-the-left collector",
        [ IsFromTheLeftCollectorRep ],

function( coll )
    
    Print( "<<from the left collector with ",
           coll![PC_NUMBER_OF_GENERATORS ],
           " generators>>" );
end );

##
#M  PrintObj( <coll> )
##
InstallMethod( PrintObj, 
        "for from-the-left collector",
        [ IsFromTheLeftCollectorRep ],
function( coll )
    
    Print( "<<from the left collector with ",
           coll![PC_NUMBER_OF_GENERATORS ],
           " generators>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
##
##  Setter and getter functions for from-the-left collectors:
##         NumberOfGenerators
##         SetRelativeOrder/NC, RelativeOrders
##         SetPower/NC, GetPower/NC
##         SetConjugate/NC, GetConjugateNC
##         SetCommutator
##
##  The NC functions  do not perform any checks.  The NC  setters do not copy
##  the argument before it is inserted  into the collector.  They also do not
##  outdate  the collector.  The  NC getter  functions do  not copy  the data
##  returned from the collector.
##

##
#F NumberOfGenerators( <coll> )
##
InstallGlobalFunction( NumberOfGenerators, 
  coll -> coll![PC_NUMBER_OF_GENERATORS] );

##
#M  SetRelativeOrder( <coll>, <gen>, <order> )
##
InstallMethod( SetRelativeOrderNC,
        "for from-the-left collector",
        [ IsFromTheLeftCollectorRep and IsMutable, IsPosInt, IsInt ],

function( coll, g, order )

    if order = 0 then 
        Unbind( coll![ PC_EXPONENTS ][g] );
        Unbind( coll![ PC_POWERS ][g] );
    else
        coll![ PC_EXPONENTS ][g] := order;
    fi;
end );

InstallMethod( SetRelativeOrder,
        "for from-the-left collector",
        [ IsFromTheLeftCollectorRep and IsMutable, IsPosInt, IsInt ],

function( coll, g, order )
    local   n;
    
    if order < 0 then
        Error( "relatve order must be non-negative" );
    fi;

    n := coll![ PC_NUMBER_OF_GENERATORS ];
    if g < 1 or g > n then
        Error( "Generator ", g, " out of range (1-", n, ")" );
    fi;
    
    SetRelativeOrderNC( coll, g, order );
    OutdatePolycyclicCollector( coll );
end );

#############################################################################
##
#M RelativeOrders( <coll> )
##
InstallMethod( RelativeOrders,
        "from-the-left collector",
        [ IsFromTheLeftCollectorRep ],

function( coll ) 
    local n, r, i;
    n := coll![PC_NUMBER_OF_GENERATORS];
    r := ShallowCopy( coll![PC_EXPONENTS] );
    for i in [1..n] do
        if not IsBound( r[i] ) then
            r[i] := 0;
        fi;
    od;
    return r;
end );

##
#M  SetPower( <coll>, <gen>, <word> )
##
InstallMethod( SetPowerNC,
        "for from-the-left collector, word as list",
        [ IsFromTheLeftCollectorRep and IsMutable, IsPosInt, IsList ], 

function( pcp, g, w )

    if Length(w) mod 2 <> 0 then
        Error( "List has odd length: not a generator exponent list" );
    fi;
    if w = [] then 
        Unbind( pcp![ PC_POWERS ][g] );
    else
        pcp![ PC_POWERS ][g] := w;
    fi;
end );

InstallMethod( SetPower,
        "for from-the-left collector, word as list",
        [ IsFromTheLeftCollectorRep and IsMutable, IsPosInt, IsList ], 

function( pcp, g, w )
    local   n,  i,  rhs;
    
    if not IsBound( pcp![ PC_EXPONENTS ][g] ) or 
                    pcp![ PC_EXPONENTS ][g] = 0 then
        Error( "relative order unknown of generator ", g );
    fi;
    
    n := pcp![ PC_NUMBER_OF_GENERATORS ];
    if g < 1 or g > n then
        Error( "Generator ", g, " out of range (1-", n, ")" );
    fi;

    rhs := [];
    for i in [1,3..Length(w)-1] do
        if not IsInt(w[i]) or not IsInt(w[i+1]) then
            Error( "List of integers expected" );
        fi;
        if w[i] <= g or w[i] > n then
            Error( "Generator ", w[i], " in rhs out of range (1-", n, ")" );
        fi;

        if w[i+1] <> 0 then
            Add( rhs, w[i] ); Add( rhs, w[i+1] );
        fi;
    od;
    
    SetPowerNC( pcp, g, rhs );
    OutdatePolycyclicCollector( pcp );
end );    

InstallMethod( SetPower,
        "from-the-left collector, word",
         [ IsFromTheLeftCollectorRep and IsMutable, IsPosInt, IsWord ], 

function( pcp, g, w )
     SetPower( pcp, g, ExtRepOfObj(w) );
end );

##
#M  GetPower( <coll>, <gen> )
##
InstallMethod( GetPowerNC,
        "from-the-left collector",
        [ IsFromTheLeftCollectorRep, IsPosInt ],

function( coll, g )

    if IsBound( coll![PC_POWERS][g] ) then
        return coll![PC_POWERS][g];
    fi;

    #  return the identity.
    return [];
end );

InstallMethod( GetPower,
        "from-the-left collector",
        [ IsFromTheLeftCollectorRep, IsPosInt ],

function( coll, g )

    if IsBound( coll![PC_POWERS][g] ) then
        return ShallowCopy( coll![PC_POWERS][g] );
    fi;

    #  return the identity.
    return [];
end );

##
#M  SetConjugate( <coll>, <gen>, <gen>, <word> )
##
InstallMethod( SetConjugateNC,
        "for from-the-left collector, words as lists",
        [ IsFromTheLeftCollectorRep and IsMutable, IsInt, IsInt, IsList ],

function( coll, h, g, w )
        
    if Length(w) mod 2 <> 0 then
        Error( "List has odd length: not a generator exponent list" );
    fi;
    if g > 0 then
        if h > 0 then
            if w = coll![ PC_GENERATORS ][h] then
                Unbind( coll![ PC_CONJUGATES ][h][g] );
            else
                coll![ PC_CONJUGATES ][h][g] := w;
            fi;
        else
            if w = coll![ PC_INVERSES ][-h] then
                Unbind( coll![ PC_INVERSECONJUGATES ][-h][g] );
            else
                coll![ PC_INVERSECONJUGATES ][-h][g] := w;
            fi;
        fi;
    else    
        if h > 0 then 
            if w = coll![ PC_GENERATORS ][h] then
                Unbind( coll![ PC_CONJUGATESINVERSE ][h][-g] );
            else
                coll![ PC_CONJUGATESINVERSE ][h][-g] := w;
            fi;	
        else
            if w = coll![ PC_INVERSES ][-h] then
                Unbind( coll![ PC_INVERSECONJUGATESINVERSE ][-h][-g] );
            else
                coll![ PC_INVERSECONJUGATESINVERSE ][-h][-g] := w;
            fi;
        fi;
    fi;
end );

InstallMethod( SetConjugate,
        "for from-the-left collector, words as lists",
        [ IsFromTheLeftCollectorRep and IsMutable, IsInt, IsInt, IsList ],

function( coll, h, g, w )
    local   i,  rhs;
    
    if AbsInt( h ) <= AbsInt( g ) then
        Error( "Left generator not smaller than right generator" );
    fi;
    if AbsInt( h ) > coll![ PC_NUMBER_OF_GENERATORS ] then
        Error( "Left generators too large" );
    fi;
    if AbsInt( g ) < 1 then
        Error( "Right generators too small" );
    fi;
    
    # check the conjugate and copy it
    rhs := [];
    for i in [1,3..Length(w)-1] do
        if not IsInt(w[i]) or not IsInt(w[i+1]) then
            Error( "List of integers expected" );
        fi;
        
        if w[i] <= g or w[i] > coll![PC_NUMBER_OF_GENERATORS ] then
            Error( "Generator in word out of range" );
        fi;

        if w[i+1] <> 0 then
            Add( rhs, w[i] ); Add( rhs, w[i+1] );
        fi;
    od;
    
    SetConjugateNC( coll, h, g, rhs );
    OutdatePolycyclicCollector( coll );
end );

InstallMethod( SetConjugate,
        "from-the-left collector, words",
        [ IsFromTheLeftCollectorRep and IsMutable, IsInt, IsInt, IsWord ],

function( coll, h, g, w )
    SetConjugate( coll, h, g, ExtRepOfObj( w ) );
end );

##
#M  GetConjugate( <coll>, <h>, <g> )
##
InstallMethod( GetConjugateNC,
        "from the left collector",
        [ IsFromTheLeftCollectorRep, IsInt, IsInt ],

function( coll, h, g )

    if g > 0 then
        if h > 0 then
            if IsBound( coll![PC_CONJUGATES][h] ) and
               IsBound( coll![PC_CONJUGATES][h][g] ) then
                return coll![PC_CONJUGATES][h][g];
            else
                return coll![PC_GENERATORS][h];
            fi;
        else
            h := -h;
            if IsBound( coll![PC_INVERSECONJUGATES][h] ) and
               IsBound( coll![PC_INVERSECONJUGATES][h][g] ) then
                return coll![PC_INVERSECONJUGATES][h][g];
            else
                return coll![PC_INVERSES][h];
            fi;
        fi;
    else
        g := -g;
        if h > 0 then
            if IsBound( coll![PC_CONJUGATESINVERSE][h] ) and
               IsBound( coll![PC_CONJUGATESINVERSE][h][g] ) then
                return coll![PC_CONJUGATESINVERSE][h][g];
            else
                return coll![PC_GENERATORS][h];
            fi;
        else
            h := -h;
            if IsBound( coll![PC_INVERSECONJUGATESINVERSE][h] ) and
               IsBound( coll![PC_INVERSECONJUGATESINVERSE][h][g] ) then
                return coll![PC_INVERSECONJUGATESINVERSE][h][g];
            else
                return coll![PC_INVERSES][h];
            fi;
        fi;

    fi;
end );

InstallMethod( GetConjugate,
        "from the left collector",
        [ IsFromTheLeftCollectorRep, IsInt, IsInt ],

function( coll, h, g )

    if AbsInt( h ) <= AbsInt( g ) then
        Error( "Left generator not smaller than right generator" );
    fi;
    if AbsInt( h ) > coll![ PC_NUMBER_OF_GENERATORS ] then
        Error( "Left generators too large" );
    fi;
    if AbsInt( g ) < 1 then
        Error( "Right generators too small" );
    fi;

    return ShallowCopy( GetConjugateNC( coll, h, g ) );
end );

##
#M  SetCommutator( <coll>, <h>, <g>, <comm> )
##
InstallMethod( SetCommutator,
        "for from-the-left collector, words as lists",
        [ IsFromTheLeftCollectorRep and IsMutable, IsInt, IsInt, IsList ],

function( coll, h, g, comm )
    local   i,  conj;
    
    if AbsInt( h ) <= AbsInt( g ) then
        Error( "Left generator not smaller than right generator" );
    fi;
    if AbsInt( h ) > coll![ PC_NUMBER_OF_GENERATORS ] then
        Error( "Left generators too large" );
    fi;
    if AbsInt( g ) < 1 then
        Error( "Right generators too small" );
    fi;
    
    for i in [1,3..Length(comm)-1] do
        if not IsInt(comm[i]) or not IsInt(comm[i+1]) then
            Error( "List of integers expected" );
        fi;
        if comm[i] <= g or comm[i] > coll![PC_NUMBER_OF_GENERATORS ] then
            Error( "Generator in word out of range" );
        fi;
    od;
    
    # h^g = h * [h,g]
    conj := [ h, 1 ];
    Append( conj, comm );
    SetConjugateNC( coll, h, g, conj );
    OutdatePolycyclicCollector( coll );
end );

InstallMethod( SetCommutator,
        "from-the-left collector, words",
        [ IsFromTheLeftCollectorRep and IsMutable, IsInt, IsInt, IsWord ],

function( coll, h, g, w )
    SetCommutator( coll, h, g, ExtRepOfObj( w ) );
end );

#############################################################################
##
##  The following two conversion functions convert the two main
##  representations of elements into each other:  exponent lists and
##  generator exponent lists.
##

##
#M  ObjByExponents( <coll>, <exponent list> )
##
InstallMethod( ObjByExponents,
        true,
        [ IsFromTheLeftCollectorRep, IsList ],
        0,
        function( coll, exps ) 
    local   w,  i;

    if Length(exps) > NumberOfGenerators(coll) then
        return Error( "more exponents than generators" );
    fi;

    w := [];
    for i in [1..Length(exps)] do
        if exps[i] <> 0 then
            Add( w, i );
            Add( w, exps[i] );
        fi;
    od;
    return w;
end );

##
#M  ExponentsByObj( <coll>, <gen-exp list>
##
InstallMethod( ExponentsByObj,
        "from-the-left collector, gen-exp-list",
        [ IsFromTheLeftCollectorRep, IsList ],
function( coll, word )
    local exp, i;
    exp := [1..coll![PC_NUMBER_OF_GENERATORS]] * 0;
    for i in [1,3..Length(word)-1] do
        exp[word[i]] := word[i+1];
    od;
    return exp;
end );


#############################################################################
##
##  The following functions implement part of the fundamental arithmetic
##  based on from-the-left collector collectors.  These functions are 
##
##  FromTheLeftCollector_Solution, 
##  FromTheLeftCollector_Inverse.
##

##
#F  FromTheLeftCollector_Solution( <coll>, <u>, <v> )
##                                           solve the equation u x = v for x
##
BindGlobal( "FromTheLeftCollector_Solution", function( coll, u, v )
    local   e,  n,  x,  i,  g,  uu;

    n := coll![ PC_NUMBER_OF_GENERATORS ];
    u := ExponentsByObj( coll, u );
    v := ExponentsByObj( coll, v );

    x := [];
    for i in [1..n] do
        e := v[i] - u[i];
        if IsBound(coll![ PC_EXPONENTS ][i]) and e < 0 then
            e := e + coll![ PC_EXPONENTS ][i];
        fi;
        if e <> 0 then
            g := ShallowCopy( coll![ PC_GENERATORS ][i] ); g[2] := e;
            Append( x, g );

            uu := ShallowCopy( u );
            while CollectWordOrFail( coll, u, g ) = fail do 
                u := ShallowCopy( uu );
            od;
        fi;
    od;

    return x;
end );
                                
##
#F  FromTheLeftCollector_Inverse( <coll>, <w> )
##                                    inverse of a word wrt a pc presentation
##
BindGlobal( "FromTheLeftCollector_Inverse", function( coll, w )
    
    Info( InfoFromTheLeftCollector, 3, "computing an inverse" );
    return FromTheLeftCollector_Solution( coll, w, [] );
end );

#############################################################################
##
##  The following functions are used to complete a fresh from-the-left
##  collector.  The are mainly called from UpdatePolycyclicCollector().
##
##  The functions are:
##      FromTheLeftCollector_SetCommute
##      FromTheLeftCollector_CompleteConjugate
##      FromTheLeftCollector_CompletePowers
##      FromTheLeftCollector_SetNilpotentCommute
##      FromTheLeftCollector_SetWeights

##
#F  FromTheLeftCollector_SetCommute( <coll> )
##
InstallGlobalFunction( FromTheLeftCollector_SetCommute, 
  function( coll )
    local   com,  cnj,  icnj,  cnji,  icnji,  n,  g,  again,  h;
    
    Info( InfoFromTheLeftCollector, 1, "Computing commute array" );

    n     := coll![ PC_NUMBER_OF_GENERATORS ];
    cnj   := coll![ PC_CONJUGATES ];
    icnj  := coll![ PC_INVERSECONJUGATES ];
    cnji  := coll![ PC_CONJUGATESINVERSE ];
    icnji := coll![ PC_INVERSECONJUGATESINVERSE ];
    ##
    ##    Commute[i] is the smallest j >= i such that a_i,...,a_n
    ##    commute with a_(j+1),...,a_n.
    ##
    com := ListWithIdenticalEntries( n, n );
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
            if IsBound(  cnj[h][g] ) or IsBound(  icnj[h][g] ) or 
               IsBound( cnji[h][g] ) or IsBound( icnji[h][g] ) then
                again := false;
            else
                h := h-1;
            fi;
        od;

        if h = g+1 and 
           not (IsBound(  cnj[h][g] ) or IsBound(  icnj[h][g] ) or 
                IsBound( cnji[h][g] ) or IsBound( icnji[h][g] ) ) then
            com[g] := g;
        else    
            com[g] := h;
        fi;
    od;
    
    coll![ PC_COMMUTE ] := com;
end );

##
#F  FromTheLeftCollector_CompleteConjugate
##
##        # The following approach only works if the presentation is
##        # nilpotent. 
##        # [b,a^-1] = a * [a,b] * a^-1;
##        cnj := coll![ PC_CONJUGATES ][j][i];
##        comm := cnj{[3..Length(cnj)]};
##        # compute [a,b] * a^-1
##        comm := FromTheLeftCollector_Inverse( coll, comm );
##        ev := ExponentsByObj( coll, comm );
##        CollectWordOrFail( coll, ev, [ i, -1 ] );
##        # wipe out a, prepend b
##        ev[i] := 0;  ev[j] := 1;
##        
                    
InstallGlobalFunction( FromTheLeftCollector_CompleteConjugate, 
  function( coll )
    local   G,  gens,  n,  i,  missing,  j,  images;
    
    Info( InfoFromTheLeftCollector, 1, "Completing conjugate relations" );

    G := PcpGroupByCollectorNC( coll );
    gens := GeneratorsOfGroup( G );

    n := coll![ PC_NUMBER_OF_GENERATORS ];
    for i in [n,n-1..1 ] do
        Info( InfoFromTheLeftCollector, 2,
              "Conjugating by generator ", i );
        
        # Does generator i have infinite order?
        if not IsBound( coll![ PC_EXPONENTS ][i] ) then
            missing := false;
            for j in [n,n-1..i+1] do
                if IsBound( coll![ PC_CONJUGATES ][j][i] ) and 
                   not IsBound( coll![ PC_CONJUGATESINVERSE ][j][i] ) then
                    missing := true;
                    break;
                fi;
            od;

            if missing then
                Info( InfoFromTheLeftCollector, 2,
                      "computing images for generator ", i );
                # fill in the missing conjugate relations
                images := [];
                # build the images under conjugation
                for j in [i+1..n] do
                    if IsBound( coll![PC_CONJUGATES][j][i] ) then
                        Add( images, PcpElementByGenExpListNC( coll, 
                                     coll![PC_CONJUGATES][j][i] ) );
                    else
                        Add( images, gens[j] );
                    fi;
                od;
                Info( InfoFromTheLeftCollector, 2, 
                      "images for generator ", i, " done" );

                images := CgsParallel( images, gens{[i+1..n]} );

                Info( InfoFromTheLeftCollector, 2, "canonical coll done" );
                # is conjugation an epimorphism ?
                if images[1] <> gens{[i+1..n]} then
                    Error( "group presentation is not polycyclic" );
                fi;
                images := images[2];
                for j in [n,n-1..i+1] do
                    if IsBound( coll![ PC_CONJUGATES ][j][i] ) and 
                       not IsBound( coll![ PC_CONJUGATESINVERSE ][j][i] ) then
                        coll![ PC_CONJUGATESINVERSE ][j][i] := 
                          ObjByExponents( coll, images[j-i]!.exponents );
                    fi;
                od;
            fi;
        fi;
           
        Info( InfoFromTheLeftCollector, 2,
              "computing inverses of conjugate relations" );

        # now fill in the other missing conjugate relations
        for j in [n,n-1..i+1] do
            if not IsBound( coll![ PC_EXPONENTS ][j] ) then

                if IsBound( coll![ PC_CONJUGATES ][j][i] ) and 
                   not IsBound( coll![ PC_INVERSECONJUGATES ][j][i] ) then
                    coll![ PC_INVERSECONJUGATES ][j][i] := 
                      FromTheLeftCollector_Inverse( coll,
                              coll![ PC_CONJUGATES ][j][i] );
                fi;
                if IsBound( coll![ PC_CONJUGATESINVERSE ][j][i] ) and
                   not IsBound( coll![ PC_INVERSECONJUGATESINVERSE ][j][i] ) then
                    coll![ PC_INVERSECONJUGATESINVERSE ][j][i] := 
                      FromTheLeftCollector_Inverse( coll,
                              coll![ PC_CONJUGATESINVERSE ][j][i] ); 
                fi;
                
            fi;
        od;
    od;
end );

##
#F  FromTheLeftCollector_CompletePowers( <coll> )
##
InstallGlobalFunction( FromTheLeftCollector_CompletePowers, 
  function( coll )
    local   n,  i;
    
    Info( InfoFromTheLeftCollector, 1, "Completing power relations" );

    n := coll![ PC_NUMBER_OF_GENERATORS ];
    coll![ PC_INVERSEPOWERS ] := [];
    for i in [n,n-1..1] do
        if IsBound( coll![ PC_POWERS ][i] ) then
            coll![ PC_INVERSEPOWERS ][i] :=
              FromTheLeftCollector_Inverse( coll, coll![ PC_POWERS ][i] );
        fi;
    od;
end );

##
#F  FromTheLeftCollector_SetNilpotentCommute( <coll> )
##
BindGlobal( "FromTheLeftCollector_SetNilpotentCommute",  function( coll )
    local   n,  wt,  cl,  ncomm,  g,  h;

    # number of generators
    n  := coll![PC_NUMBER_OF_GENERATORS];

    # class and weights of collector
    wt := coll![PC_WEIGHTS];
    cl := wt[ Length(wt) ];
    
    ncomm := [1..n];
    for g in [1..n] do
        if 3*wt[g] > cl then
            break;
        fi;
        h := coll![PC_COMMUTE][g];
        while g < h and 2*wt[h] + wt[g] > cl do h := h-1; od;
        ncomm[g] := h;
    od;

    # set the avector
    coll![PC_NILPOTENT_COMMUTE] := ncomm;
end );

##
#F  FromTheLeftCollector_SetWeights( <coll> )
##
BindGlobal( "FromTheLeftCollector_SetWeights", function( cc )
    local   astart,  class,  ngens,  weights,  h,  g,  cnj,  i;

    ngens   := cc![ PC_NUMBER_OF_GENERATORS ];

    if ngens = 0 then return fail; fi;

    weights := [1..ngens] * 0 + 1;

    ##  wt: <gens> --> Z such that
    ##      -- wt is increasing
    ##      -- wt(j) + wt(i) <= wt(g) for j > i and all g in the rhs
    ##         commutator relations [j,i]
 
    ##  Run through the (positive) commutator relations and make the weight
    ##  of each generator of a rhs large enough.
    for h in [1..ngens] do
        for g in [1..h-1] do
            cnj := GetConjugateNC( cc, h, g );
            if cnj[1] <> h or cnj[2] <> 1 then 
                ##  The conjugate relation is not a commutator.
                return fail;
            fi;
            for i in [3,5..Length(cnj)-1] do
                if weights[cnj[i]] < weights[g] + weights[h] then
                    weights[cnj[i]] := weights[g] + weights[h];
                fi;
            od;
        od;
    od;
    cc![PC_WEIGHTS] := weights;
    
    class := weights[ Length(weights) ];
    astart := 1; 
    while 2 * weights[ astart ] <= class do astart := astart+1; od;
    cc![PC_ABELIAN_START] := astart;

    return true;
end );

InstallMethod( IsWeightedCollector,
        "from-the-left collector",
        [ IsPolycyclicCollector and IsFromTheLeftCollectorRep and IsMutable ],

function( coll )

    if FromTheLeftCollector_SetWeights( coll ) <> fail then
        SetFeatureObj( coll, IsWeightedCollector, 
                true and USE_COMBINATORIAL_COLLECTOR );

        return true and USE_COMBINATORIAL_COLLECTOR;
    fi;
    return false;
end );

############################################################################
##
#F  IsPcpNormalFormObj ( <ftl>, <w> )
##
## checks whether <w> is in normal form.
## 
InstallGlobalFunction( IsPcpNormalFormObj,
  function( ftl, w )
  local k; # loop variable
  
  if not IsSortedList( w{[1,3..Length(w)-1]} ) then 
    return false;
  fi;
  for k in [1,3..Length(w)-1] do
    if IsBound( ftl![ PC_EXPONENTS ][ w[k] ]) and 
      ( not w[k+1] < ftl![ PC_EXPONENTS ][ w[k] ] or
        not w[k+1] >= 0 ) then 
      return false;
    fi;
  od;

  return true;
  end);

############################################################################
##
#P  IsPolycyclicPresentation( <ftl> )
## 
## checks whether the input-presentation is a polycyclic presentation, i.e.
## whether the right-hand-sides of the relations are normal.
##
InstallMethod( IsPolycyclicPresentation, 
  "FromTheLeftCollector", 
  [ IsFromTheLeftCollectorRep ], 0, 
  function( ftl )
  local n, 	# number of generators of <ftl>
	i,j;	# loop variables

  n := ftl![ PC_NUMBER_OF_GENERATORS ];

  # check power relations
  for i in [1..n] do
    if IsBound( ftl![ PC_POWERS ][i] ) and 
       not IsPcpNormalFormObj( ftl, ftl![ PC_POWERS ][i]) then 
       Info( InfoFromTheLeftCollector, 1, "bad power relation g",i,"^",ftl![ PC_EXPONENTS ][i],
            " = ", ftl![ PC_POWERS ][i] );
      return false;
    fi;
  od;
  
  # check conjugacy relations
  for i in [ 1 .. n ] do 
    for j in [ i+1 .. n ] do
      if IsBound( ftl![ PC_CONJUGATES ][j][i] ) and
         not IsPcpNormalFormObj( ftl, ftl![ PC_CONJUGATES ][j][i] ) then
        Info( InfoFromTheLeftCollector, 1, "bad conjugacy relation g",j,"^g",i,
              " = ", ftl![ PC_CONJUGATES ][j][i] );
        return false;
      elif IsBound( ftl![ PC_INVERSECONJUGATES ][j][i] ) and
         not IsPcpNormalFormObj( ftl, ftl![ PC_INVERSECONJUGATES ][j][i] ) then
        Info( InfoFromTheLeftCollector, 1, "bad conjugacy relation g",j,"^-g",i,
              " = ", ftl![ PC_INVERSECONJUGATES ][j][i] );
        return false;
      elif IsBound( ftl![ PC_CONJUGATESINVERSE ][j][i] ) and
        not IsPcpNormalFormObj( ftl, ftl![ PC_CONJUGATESINVERSE ][j][i] ) then
        Info( InfoFromTheLeftCollector, 1, "bad conjugacy relation -g",j,"^g",i,
              " = ", ftl![ PC_CONJUGATESINVERSE ][j][i] );
        return false;
      elif IsBound( ftl![ PC_INVERSECONJUGATESINVERSE ][j][i] ) and
        not IsPcpNormalFormObj( ftl, ftl![PC_INVERSECONJUGATESINVERSE][j][i] ) then
        Info( InfoFromTheLeftCollector, 1, "bad conjugacy relation -g",j,"^-g",i,
              " = ", ftl![ PC_INVERSECONJUGATESINVERSE ][j][i] );
        return false;
      fi;
    od;
  od;

  # check commutator relations
  for i in [ 1 .. n ] do 
    for j in [ i+1 .. n ] do 
      if IsBound( ftl![ PC_COMMUTATORS ][j][i] ) and
         not IsPcpNormalFormObj( ftl, ftl![ PC_COMMUTATORS ][j][i] ) then
        return false;
      elif IsBound( ftl![ PC_INVERSECOMMUTATORS ][j][i] ) and
         not IsPcpNormalFormObj( ftl, ftl![ PC_INVERSECOMMUTATORS ][j][i] ) then
        return false;
      elif IsBound( ftl![ PC_COMMUTATORSINVERSE ][j][i] ) and
        not IsPcpNormalFormObj( ftl, ftl![ PC_COMMUTATORSINVERSE ][j][i] ) then
        return false;
      elif IsBound( ftl![ PC_INVERSECOMMUTATORSINVERSE ][j][i] ) and
        not IsPcpNormalFormObj( ftl, ftl![PC_INVERSECOMMUTATORSINVERSE][j][i] ) then
        return false;
      fi;
    od;
  od;

  return true;
  end);

#############################################################################
##
##  Complete a modified from-the-left collector so that it can be used by
##  the collection routines.  Also check here if a combinatorial collector
##  can be used.
##
#M  UpdatePolycyclicCollector( <coll> )
##
InstallMethod( UpdatePolycyclicCollector,
        "FromTheLeftCollector",
        [ IsFromTheLeftCollectorRep ],
function( coll )

    if not IsPolycyclicPresentation( coll ) then
       Error("the input presentation is not a polcyclic presentation");
    fi;
    
    FromTheLeftCollector_SetCommute( coll );

    ## We have to declare the collector up to date now because the following
    ## functions need to collect and are careful enough.
    SetFeatureObj( coll, IsUpToDatePolycyclicCollector, true );

    FromTheLeftCollector_CompleteConjugate( coll );
    FromTheLeftCollector_CompletePowers( coll );
    
    if IsWeightedCollector( coll ) then
        FromTheLeftCollector_SetNilpotentCommute( coll );
    fi;

end );

#############################################################################
##
#M  IsConfluent . . . . . . . . . . . . . . . . . . . polycyclic presentation
##
##  This method checks the confluence (or consistency) of a polycyclic
##  presentation.  It implements the checks from Sims: Computation
##  with Finitely Presented Groups, p. 424:
##
##		k (j i) = (k j) i               k > j > i
##		j^m i   = j^(m-1) (j i)		j > i,        j in I
##		j * i^m = (j i) * i^(m-1)	j > i,        i in I
##		i^m i   = i i^m			              i in I
##		      j = (j -i) i 		j > i,    i not in I
##		      i = -j (j i)		j > i,    j not in I
##		     -i = -j (j -i)             j > i,  i,j not in I
##
if not IsBound( InfoConsistency ) then 
    BindGlobal( "InfoConsistency", function( arg ) end );
fi;
InstallMethod( IsConfluent,
        "FromTheLeftCollector",
        [ IsFromTheLeftCollectorRep ],

function( coll )
    local   n,  k,  j,  i,  ev1,  w,  ev2;
    
    n := coll![ PC_NUMBER_OF_GENERATORS ];

    # k (j i) = (k j) i
    for k in [n,n-1..1] do
        for j in [k-1,k-2..1] do
            for i in [j-1,j-2..1] do
                InfoConsistency( "checking ", k, " ", j, " ", i, "\n" );
                ev1 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev1, [j,1,i,1] );
                w := ObjByExponents( coll, ev1 );
                ev1 := ExponentsByObj( coll, [k,1] );
                CollectWordOrFail( coll, ev1, w );
                
                ev2 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev2, [k,1,j,1,i,1] );
                
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
            if IsBound(coll![ PC_EXPONENTS ][j]) then
                InfoConsistency( "checking ", j, "^m ", i, "\n" );
                ev1 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev1, [j, coll![ PC_EXPONENTS ][j]-1, 
                                               j, 1, i,1] );
                
                ev2 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev2, [j,1,i,1] );
                w := ObjByExponents( coll, ev2 );
                ev2 := ExponentsByObj( coll, [j,coll![ PC_EXPONENTS ][j]-1] );
                CollectWordOrFail( coll, ev2, w );

                if ev1 <> ev2 then
                    Print( "Inconsistency at ", j, "^m ", i, "\n" );
                    return false;
                fi;
            fi;
        od;
    od;
    
    # j * i^m = (j i) * i^(m-1)
    for i in [n,n-1..1] do
        if IsBound(coll![ PC_EXPONENTS ][i]) then
            for j in [n,n-1..i+1] do
                InfoConsistency( "checking ", j, " ", i, "^m\n" );
                ev1 := ExponentsByObj( coll, [j,1] );
                if IsBound( coll![ PC_POWERS ][i] ) then
                    CollectWordOrFail( coll, ev1, coll![ PC_POWERS ][i] );
                fi;
                
                ev2 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev2,
                        [ j,1,i,coll![ PC_EXPONENTS ][i] ] );
                
                if ev1 <> ev2 then
                    Print( "Inconsistency at ", j, " ", i, "^m\n" );
                    return false;
                fi;
            od;
        fi;
    od;
    
    # i^m i = i i^m
    for i in [n,n-1..1] do
        if IsBound( coll![ PC_EXPONENTS ][i] ) then
            ev1 := ListWithIdenticalEntries( n, 0 );
            CollectWordOrFail( coll, ev1, [ i,coll![ PC_EXPONENTS ][i]+1 ] );
            
            ev2 := ExponentsByObj( coll, [i,1] );
            if IsBound( coll![ PC_POWERS ][i] ) then
                CollectWordOrFail( coll, ev2, coll![ PC_POWERS ][i] );
            fi;
            
            if ev1 <> ev2 then
                Print( "Inconsistency at ", i, "^(m+1)\n" );
                return false;
            fi;
        fi;
    od;
        
    # j = (j -i) i 
    for i in [n,n-1..1] do
        if not IsBound( coll![ PC_EXPONENTS ][i] ) then
            for j in [i+1..n] do
                InfoConsistency( "checking ", j, " ", -i, " ", i, "\n" );
                ev1 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev1, [j,1,i,-1,i,1] );
                ev1[j] := ev1[j] - 1;
                if ev1 <> ListWithIdenticalEntries( n, 0 ) then
                    Print( "Inconsistency at ", j, " ", -i, " ", i, "\n" );
                    return false;
                fi;
            od;
        fi;
    od;
    
    # i = -j (j i)
    for j in [n,n-1..1] do
        if not IsBound( coll![ PC_EXPONENTS ][j] ) then
            for i in [j-1,j-2..1] do
                InfoConsistency( "checking ", -j, " ", j, " ", i, "\n" );
                ev1 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev1, [ j,1,i,1 ] );
                w := ObjByExponents( coll, ev1 );
                ev1 := ExponentsByObj( coll, [j,-1] );
                CollectWordOrFail( coll, ev1, w );
                
                if ev1 <> ExponentsByObj( coll, [i,1] ) then
                    Print( "Inconsistency at ", -j, " ", j, " ", i, "\n" );
                    return false;
                fi;
                
                # -i = -j (j -i)
                if not IsBound( coll![ PC_EXPONENTS ][i] ) then
                    InfoConsistency( "checking ", -j, " ", j, " ", -i, "\n" );
                    ev1 := ListWithIdenticalEntries( n, 0 );
                    CollectWordOrFail( coll, ev1, [ j,1,i,-1 ] );
                    w := ObjByExponents( coll, ev1 );
                    ev1 := ExponentsByObj( coll, [j,-1] );
                    CollectWordOrFail( coll, ev1, w );
                    
                    if ExponentsByObj( coll, [i,-1] ) 
                       <> ev1 then
                        Print( "Inconsistency at ", 
                               -j, " ", j, " ", -i, "\n" );
                        return false;
                    fi;
                fi;
            od;
        fi;
    od;

    return true;
end );

