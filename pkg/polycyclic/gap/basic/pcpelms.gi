#############################################################################
##
#W  pcpelms.gi                   Polycyc                         Bettina Eick
##

InstallGlobalFunction( PcpElementConstruction, 
function( coll, list, word )
    local   elm;
    elm := rec( collector := coll,
                exponents := Immutable(list),
                word      := Immutable(word),
                name      := "g" );

    # objectify and return
    return Objectify( coll![PC_PCP_ELEMENTS_TYPE], elm );
end );

#############################################################################
##
## Functions to create pcp elements by exponent vectors or words.
## In the NC versions we assume that elements are in normal form.
## In the other versions we collect before we return an element.
## 
InstallGlobalFunction( PcpElementByExponentsNC,
function( coll, list )
    local   i,  word;
    word := ObjByExponents( coll, list );
    return PcpElementConstruction( coll, list, word );
end );

InstallGlobalFunction( PcpElementByExponents, function( coll, list )
    local h, k;

    if Length(list) > NumberOfGenerators(coll) then
        Error( "more exponents than generators" );
    fi;

    h := ObjByExponents( coll, list );
    k := list * 0;
    while CollectWordOrFail( coll, k, h ) = fail do od;
    return PcpElementByExponentsNC( coll, k );
end ); 

InstallGlobalFunction( PcpElementByGenExpListNC, 
function( coll, word )
    local   list,  i;
    list := ExponentsByObj( coll, word );
    word := ObjByExponents( coll, list );
    return PcpElementConstruction( coll, list, word );
end );

InstallGlobalFunction( PcpElementByGenExpList, function( coll, word )
    local k;
    k := [1..coll![PC_NUMBER_OF_GENERATORS]] * 0;
    while CollectWordOrFail( coll, k, word ) = fail do od;
    return PcpElementByExponentsNC( coll, k );
end );

#############################################################################
##
#A Basic attributes of pcp elements - for IsPcpElementRep
##
InstallMethod( Collector, 
        "for pcp groups",
        [ IsPcpGroup ],
        G -> Collector( One(G) ) );


InstallMethod( Collector, 
        "for pcp elements", 
        [ IsPcpElementRep ],
        g -> g!.collector );

InstallMethod( Exponents, 
        "for pcp elements",
        [ IsPcpElementRep ],
        g -> g!.exponents );

InstallMethod( NameTag, 
        "for pcp elements",
        [ IsPcpElementRep ],
        g -> g!.name );

InstallMethod( GenExpList,
        "for pcp elements",
        [ IsPcpElementRep ],
        g -> g!.word );

InstallMethod( Depth,
        "for pcp elements",
        [ IsPcpElementRep ],

function( elm )

    if Length(elm!.word) = 0 then
        return elm!.collector![PC_NUMBER_OF_GENERATORS] + 1;
    else
        return elm!.word[1]; 
    fi;
end );

InstallMethod( TailOfElm,
        "for pcp elements",
        [ IsPcpElement and IsPcpElementRep ],
        
function( elm )
    if Length( elm!.word ) = 0 then
        return 0;
    else
        return elm!.word[ Length(elm!.word) - 1 ];
    fi;
end );

InstallMethod( LeadingExponent,
        "for pcp elements",
        [ IsPcpElementRep ],

function( elm )
    if Length(elm!.word) = 0 then
        return fail;
    else
        return elm!.word[2]; 
    fi;
end );

##  Note, that inverses of generators with relative order > 0 are not treated
##  as inverses as they should never appear here with a negative exponent.
IsGeneratorOrInverse := function( elm )
    return Length(elm!.word) = 2 and 
           (elm!.word[2] = 1 or elm!.word[2] = -1);
end;

##
## Is elm the power of a generator modulo depth d?
## If so, then return the power, otherwise return fail;
##
IsPowerOfGenerator := function( elm, d )
    if Length( elm!.word ) = 0 or 
       (Length( elm!.word ) > 2 and elm!.word[3] <= d) then
        return fail;
    fi;
    return elm!.word[2];
end;

#############################################################################
##
#F FactorOrder( g )
## 
InstallMethod( FactorOrder, true, [IsPcpElement], 0,
function( g )
    if Length( g!.word ) = 0 then return fail; fi;
    return RelativeOrders( Collector(g) )[Depth(g)];
end );

#############################################################################
##
#F RelativeOrderPcp( g )
## 
InstallMethod( RelativeOrderPcp, true, [IsPcpElement], 0,
function( g )
    local r, l;
    if Length( g!.word ) = 0 then return fail; fi;
    r := FactorOrder( g );

    # the infinite case
    if r = 0 then return 0; fi;

    # the finite case
    l := LeadingExponent( g );
    if l = 1 then 
       return r; 
    elif IsBound( g!.normed ) and g!.normed then
        return r / LeadingExponent(g);
    elif IsPrime( r ) then 
        return r; 
    else
        return r / Gcd( r, l );
    fi;
end );
RelativeOrder := function( g ) return RelativeOrderPcp(g); end;

#############################################################################
##
#F RelativeIndex( g )
## 
InstallMethod( RelativeIndex, true, [IsPcpElement], 0,
function( g )
    local r, l;
    if Length( g!.word ) = 0 then return fail; fi;
    r := FactorOrder( g );
    l := LeadingExponent( g );

    if IsBound( g!.normed ) and g!.normed then
        return l;
    elif r > 0 then
        return Gcd( r, l );
    else
        return AbsInt( l );
    fi;
end );

#############################################################################
##
#F Order( g )
##
InstallMethod( Order, true, [IsPcpElement], 0,
function( g )
    local o, r;
    o := 1;
    while g <> g^0 do
        r := RelativeOrderPcp( g );
        if r = 0 then return infinity; fi;
        o := o*r;
        g := g^r;
    od;
    return o;
end );

#############################################################################
##
#F NormingExponent( g ) . . . . . . . . .returns f such that g^f is normed
##
## Note that g is normed, if the LeadingExponent of g is its RelativeIndex.
## 
NormingExponent := function( g )
    local r, l, e;
    r := FactorOrder( g );
    l := LeadingExponent( g );
    if IsBool( l ) then
        return 1;
    elif r = 0 and l < 0 then  
        return -1;
    elif r = 0 then 
        return 1;
    elif IsPrime( r ) then
        return l^-1 mod r;
    else
        e := Gcdex( r, l );     # = RelativeIndex
        return e.coeff2 mod r;  # l * c2 = e mod r
    fi;
end;

#############################################################################
##
#F NormedPcpElement( g )
## 
NormedPcpElement := function( g )
    local h;
    h := g^NormingExponent( g );
    h!.normed := true;
    return h;
end;

#############################################################################
##
#M Print pcp elements
##
InstallMethod( PrintObj, 
               "for pcp elements", 
               true, 
               [IsPcpElement], 
               0,
function( elm )
    local g, l, e, d;
    g := NameTag( elm );
    e := Exponents( elm );
    d := Depth( elm );
    if d > Length( e ) then
        Print("id");
    elif e[d] = 1 then
        Print(Concatenation(g,String(d)));
    else
        Print(Concatenation(g,String(d)),"^",e[d]);
    fi;
    for l in [d+1..Length(e)] do
        if e[l] = 1 then
            Print("*",Concatenation(g,String(l)));
        elif e[l] <> 0 then
            Print("*",Concatenation(g,String(l)),"^",e[l]);
        fi;
    od;
end );
 
#############################################################################
##
#M g * h 
## 
InstallMethod( \*,
               "for pcp elements", 
               IsIdenticalObj,
               [IsPcpElement, IsPcpElement], 
               20,
function( g1, g2 )
    local e, f;

    if TailOfElm( g1 ) < Depth( g2 ) then
        e := Exponents( g1 ) + Exponents( g2 );

    else
        e  := ShallowCopy( Exponents( g1 ) );
        f  := GenExpList( g2 );
        while CollectWordOrFail( Collector( g1 ), e, f ) = fail do
            e  := ShallowCopy( Exponents( g1 ) );
        od;
    fi;
    
    return PcpElementByExponentsNC( Collector( g1 ), e );
end );
       
#############################################################################
##
#M Inverse
## 
InstallMethod( Inverse,
               "for pcp elements", 
               true, 
               [IsPcpElement], 
               0,
function( g )
    local   clt,  k;
    
    clt := Collector( g );
    if IsGeneratorOrInverse( g ) and RelativeOrderPcp(g) = 0 then
        if LeadingExponent( g ) = 1 then
            k := clt![PC_INVERSES][ Depth(g) ];
        else
            k := clt![PC_GENERATORS][ Depth(g) ];
        fi;

    else

        k := FromTheLeftCollector_Inverse( clt, GenExpList(g) );
    fi;

    return PcpElementByGenExpListNC( Collector(g), k );
end );

InstallMethod( INV,
               "for pcp elements", 
               true, 
               [IsPcpElement], 
               0,
function( g )
    local   clt,  k;

    clt := Collector( g );
    if IsGeneratorOrInverse( g ) and RelativeOrderPcp(g) = 0 then
        if LeadingExponent( g ) = 1 then
            k := clt![PC_INVERSES][ Depth(g) ];
        else
            k := clt![PC_GENERATORS][ Depth(g) ];
        fi;

    else

        k := FromTheLeftCollector_Inverse( clt, GenExpList(g) );
    fi;

    return PcpElementByGenExpListNC( Collector(g), k );
end );

#############################################################################
##
#M \^
## 
InstallMethod( \^,
               "for a pcp element and an integer", 
               true, 
               [IsPcpElement, IsInt], 
               SUM_FLAGS + 10,
function( g, d )
    local   res;

    # first catch the trivial cases
    if d = 0 then 
        return PcpElementByExponentsNC( Collector(g), 0*Exponents(g) ); 
    elif d = 1 then 
        return g;
    elif d = -1 then
        return Inverse(g);
    fi;

#    # use collector function
#    c := Collector(g);
#    k := FromTheLeftCollector_Power(c, ObjByExponents(c, Exponents(g)), d);
#    return PcpElementByGenExpListNC( c, k );

    # set up for computation
    if d < 0 then
        g := Inverse(g);
        d := -d;
    fi;

    # compute power
    res := g^0;
    while d > 0 do
        if d mod 2 = 1 then   res := res * g;   fi;

        d := QuoInt( d, 2 );
        if d <> 0 then   g := g * g;    fi;
    od;

    return res;
end );

InstallMethod( \^,
               "for two pcp elements",
               IsIdenticalObj,
               [IsPcpElement, IsPcpElement], 
               0,
function( h, g )
    local   clt,  conj;
    
    clt := Collector( g );
    if IsGeneratorOrInverse( h ) and IsGeneratorOrInverse( g ) then
        
        if Depth( g ) = Depth( h ) then 

            conj := h;
        
        elif Depth( g ) < Depth( h ) then
            
            conj := GetConjugateNC( clt, 
                            Depth( h ) * LeadingExponent( h ),
                            Depth( g ) * LeadingExponent( g ) );

            conj := PcpElementByGenExpListNC( clt, conj );

        elif Depth( g ) > Depth( h ) then
            #  h^g = g^-1 * h * g

            conj := ShallowCopy( Exponents( g^-1 ) );
            while CollectWordOrFail( clt, conj, 
                    [ Depth(h), LeadingExponent( h ), 
                      Depth(g), LeadingExponent( g ) ] ) = fail do
                
                conj := ShallowCopy( Exponents( g^-1 ) );
            od;

            conj := PcpElementByExponentsNC( clt, conj );
        fi;

    elif Depth(g) = TailOfElm(g) and Depth( g ) < Depth( h ) then

        ##
        ## nicht klar ob dies etwas bringt
        ##
        g := [ Depth(g), LeadingExponent(g) ];
        conj := ShallowCopy( Exponents( h ) );
        while CollectWordOrFail( clt, conj, g ) = fail do
            conj := ShallowCopy( Exponents( h ) );
        od;

        conj[ g[1] ] := 0;
        conj := PcpElementByExponentsNC( clt, conj );

    else
        conj := g^-1 * h * g;
    fi;

    return conj;

end );


InstallMethod( GetCommutatorNC, 
        "for from the left collector",
        true,
        [ IsFromTheLeftCollectorRep, IsInt, IsInt ],
        0,
function( coll, h, g )

    if g > 0 then
        if h > 0 then
            if IsBound( coll![PC_COMMUTATORS][h] ) and
               IsBound( coll![PC_COMMUTATORS][h][g] ) then
                return coll![PC_COMMUTATORS][h][g];
            else
                return fail;
            fi;
        else
            h := -h;
            if IsBound( coll![PC_INVERSECOMMUTATORS][h] ) and
               IsBound( coll![PC_INVERSECOMMUTATORS][h][g] ) then
                return coll![PC_INVERSECOMMUTATORS][h][g];
            else
                return fail;
            fi;
        fi;
    else
        g := -g;
        if h > 0 then
            if IsBound( coll![PC_COMMUTATORSINVERSE][h] ) and
               IsBound( coll![PC_COMMUTATORSINVERSE][h][g] ) then
                return coll![PC_COMMUTATORSINVERSE][h][g];
            else
                return fail;
            fi;
        else
            h := -h;
            if IsBound( coll![PC_INVERSECOMMUTATORSINVERSE][h] ) and
               IsBound( coll![PC_INVERSECOMMUTATORSINVERSE][h][g] ) then
                return coll![PC_INVERSECOMMUTATORSINVERSE][h][g];
            else
                return fail;
            fi;
        fi;

    fi;
end );

#############################################################################
##
#M Comm
## 
InstallMethod( Comm,
               "for two pcp elements",
               IsIdenticalObj,
               [ IsPcpElement, IsPcpElement ],
               0,
function( h, g )
    local   clt,  conj,  ev;
    
    clt := Collector( g );

    if IsGeneratorOrInverse( h ) and IsGeneratorOrInverse( g ) then

        if Depth( g ) = Depth( h ) then return g^0; fi;


        if Depth( g ) < Depth( h ) then

            ##  Do we know the commutator?

            conj := GetCommutatorNC( clt, Depth( h ) * LeadingExponent( h ),
                                          Depth( g ) * LeadingExponent( g ) );
            if conj  <> fail then
                return conj;
            fi;

            ##  [h,g] = h^-1 h^g

            conj := GetConjugateNC( clt, Depth( h ) * LeadingExponent( h ),
                                         Depth( g ) * LeadingExponent( g ) );

            ev := ShallowCopy( Exponents( h^-1 ) );
            while CollectWordOrFail( clt, ev, conj ) = fail do
                ev := ShallowCopy( Exponents( h^-1 ) );
            od;

            return PcpElementByExponentsNC( clt, ev );
        fi;

        if Depth( g ) > Depth( h ) and RelativeOrderPcp( g ) = 0 then
            ##  [h,g] = (g^-1)^h * g

            conj := GetConjugateNC( clt, Depth( g ) *  -LeadingExponent( g ),
                                         Depth( h ) *   LeadingExponent( h ) );
        
            ev := ExponentsByObj( clt, conj );
            while CollectWordOrFail( clt, ev, GenExpList(g) ) = fail do
                ev := ExponentsByObj( clt, conj );
            od;

            return PcpElementByExponentsNC( clt, ev );
        fi;

    fi;

    return PcpElementByGenExpListNC( clt,
                   FromTheLeftCollector_Solution( clt,
                   GenExpList(g*h),GenExpList(h*g) ) );
    
end );
               


#############################################################################
##
#M One
## 
InstallMethod( One, "for pcp elements", true, [IsPcpElement], 0,
function( g ) return g^0; end );

#############################################################################
##
#M \=
## 
InstallMethod( \=,
               "for pcp elements", 
               IsIdenticalObj,
               [IsPcpElement, IsPcpElement],
               0,
function( g, h )
    return Exponents( g ) = Exponents( h );
end );

#############################################################################
##
#M \<
## 
InstallMethod( \<,
               "for pcp elements", 
               IsIdenticalObj, 
               [IsPcpElement, IsPcpElement],
               0,
function( g, h )
    return Exponents( g ) > Exponents( h );
end );

