#############################################################################
##
##  fleftr.g                 Polycyclic Groups                  Werner Nickel
##
##  This file contains a collector from the left for polcyyclic
##  presentations based on Leedham-Green & Soicher with additional
##  features in an attempt to handle large exponents in the words to
##  be collected. 
##

if not IsBound( ComputeCommute ) then
    ComputeCommute := function( arg )
        Error( "ComputeCommute() undefined. Read polycyc.g!" );
    end;
fi;

#############################################################################
##
#F  WordExpVector . . . . . . . . . . . . . . . . . . exponent vector to word
##
WordExpVector := function( pcp, ev )
    local   w,  i;
    
    w := [];
    for i in [1..Length(ev)] do
        if ev[i] <> 0 then
            Add( w, i ); Add( w, ev[i] );
        fi;
    od;
    return w;
end;

#############################################################################
##
#F  ExpVectorWord . . . . . . . . . . . . . . . . . . word to exponent vector
##
ExpVectorWord := function( pcp, w )
    local   ev,  i;
    
    ev := [1..Length(pcp.Generators)] * 0;
    for i in [1,3..Length(w)-1]  do
        ev[ w[i] ] := w[i+1];
    od;
    return ev;
end;

Collect := "to be defined later";

#############################################################################
##
#F  SolvePc . . . . . . . . . . . . . . . .  solve the equation u x = v for x
##
SolvePc := function( pcp, u, v )
    local   n,  x,  i;
    
    n := Length( pcp.Generators );
    x := [1..n] * 0;
    u := ExpVectorWord( pcp, u );
    v := ExpVectorWord( pcp, v );
    for i in [1..n] do
        x[i] := v[i] - u[i];
        if IsBound(pcp.Exponent[i]) and x[i] < 0 then
            x[i] := x[i] + pcp.Exponent[i];
        fi;
        if x[i] <> 0 then
            Collect( pcp, u, [ i,x[i] ] );
        fi;
    od;

    return WordExpVector( pcp, x );
end;

#############################################################################
##
#F  InvertPc  . . . . . . . . . . . . . . . invert word wrt a pc presentation
##
InvertPc := function( pcp, w )
    
    return SolvePc( pcp, w, [] );
end;

#############################################################################
##
#F  PowerPc . . . . . . . . . . . . . . power of a word wrt a pc presentation
##
PowerPc := function( pcp, w, e )
    local   x,  ex,  result;
    
    result := [1..Length(pcp.Generators)] * 0;
    
    if e < 0 then
        w := InvertPc( pcp, w );
        e := -e;
    fi;
    
    x  := w;
    ex := ExpVectorWord( pcp, x );
    while e > 0 do
        if e mod 2 = 1 then 
            Collect( pcp, result, x ); 
        fi;
        e := Int( e / 2 );
        if e > 0 then 
            Collect( pcp, ex, x ); x := WordExpVector( pcp, ex );
        fi;
    od;
    return WordExpVector( pcp, result );
end;

#############################################################################
##
#F  ImageAutomorphism . . . . . . . . . image of a word under an automorphism
##
ImageAutomorphism := function( pcp, w, a )
    local   ev,  g;
    
    ev := [1..Length(pcp.Generators)] * 0;
    for g in [1,3..Length(w)-1] do
        Collect( pcp, ev, PowerPc( pcp, a[w[g]], w[g+1] ) );
    od;
    return WordExpVector( pcp, ev );
end;

#############################################################################
##
#F  PowerAutomorphism . . . . . . . .  raise automorphism to the power of 2^e
##
PowerAutomorphism := function( pcp, g, e )
    local   n,  a,  power,  h,  aa,  ipower;
    
    n := Length(pcp.Generators);
    
    # initialise automorphism
    a := [];
    power := [];
    for h in [g+1..n] do
        if e > 0 then 
            if IsBound( pcp.Conjugate[h][g] ) then
                a[h] := pcp.Conjugate[h][g];
            else
                a[h] := [h,1];
            fi;
        else
            if IsBound( pcp.ConjugateInverse[h][g] ) then
                a[h] := pcp.ConjugateInverse[h][g];
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
            for h in [g+1..n] do 
                power[h] := ImageAutomorphism( pcp, power[h], a );
            od;
        fi;
        e := Int( e / 2 );
        if e > 0 then
            aa := [];
            for h in [g+1..n] do
                aa[h] := ImageAutomorphism( pcp, a[h], a );
            od;
            a := aa;
        fi;
    od;
    ipower := [];
    for h in [g+1..n] do ipower[h] := InvertPc( pcp, power[h] ); od;

    return [ power, ipower ];
end;

#############################################################################
##
#V  StackSize . . . . . . . . . . . . . . . . . . . size of collection stacks
#V  WordStack . . . . . . . . . . . . . . . . . . . . . stack for conjugates 
#V  WordExponentStack . . . . . . . stack for exponents of entry in WordStack
#V  GeneratorStack  . . . . . .  stack for positions in an entry in WordStack
#V  GeneratorExponentStack  . . . . .  exponent of position in GeneratorStack
#V  StP . . . . . . . . . . . . . . . . . . . . . . . . . . . . stack pointer
##
StackSize              := 1024;
WordStack              := [1..StackSize] * 0;
WordExponentStack      := [1..StackSize] * 0;
GeneratorStack         := [1..StackSize] * 0;
GeneratorExponentStack := [1..StackSize] * 0;
StP                    := 0;

#############################################################################
##
#F  CollectRecursive  . . . . . . . . . . . . . . . . collector from the left
##
CollectRecursive := function( pcp, ev, w )
    local   com,  pow,  exp,  wst,  west,  gst,  gest,  bottom,  g,  
            cnj,  icnj,  h;
    
    if w = [] then return; fi;
    
    if IsBound( pcp.Commute ) then
        com := pcp.Commute;
    else
        com := ComputeCommute( pcp );
    fi;
    
    pow := pcp.Power;
    exp := pcp.Exponent;
    
    # initialise the 4 stacks needed for collection from the left
    wst  := WordStack;              
    west := WordExponentStack;      
    gst  := GeneratorStack;
    gest := GeneratorExponentStack; 
    
    bottom    := StP;
    StP       := StP + 1;
    wst[StP]  := w;
    west[StP] := 1;
    gst[StP]  := 1;
    gest[StP] := w[2];

    # collect      
    while StP > bottom do
        
        if gest[StP] = 0 then
            # initialise gest
            gst[StP] := gst[StP] + 2;
            if gst[StP] > Length(wst[StP]) then
                west[StP] := west[StP] - 1;
                if west[StP] = 0 then
                    StP := StP - 1;
                else
                    gst[StP]  := 1;
                    gest[StP] := wst[StP][ gst[StP]+1 ];
                fi;
            else
                gest[StP] := wst[StP][ gst[StP]+1 ];
            fi;
        else
            
            # get next generator
            g := wst[StP][ gst[StP] ];
            
            if g = com[g] then
                # move generator directly to its correct position
                ev[g] := ev[g] + gest[StP];
                gest[StP] := 0;
            else
                cnj := PowerAutomorphism( pcp, g, gest[StP] );
                icnj := cnj[2]; cnj := cnj[1];
                ev[g] := ev[g] + gest[StP];
                gest[StP] := 0;
                # move generator across the exponent vector
                for h in [com[g],com[g]-1..g+1] do
                    if ev[h] <> 0 then
                        StP := StP + 1;
                        if ev[h] > 0 and IsBound( cnj[h] ) then
                            if Length( cnj[h] ) = 1 then
                                wst[StP]  := [cnj[h][1][1],
                                              cnj[h][1][2]*ev[h]]; 
                                west[StP] := 1;
                            elif ev[h] > pcp.PowerLimit then
                                wst[StP]  := PowerPc( pcp, cnj[h], ev[h] );
                                west[StP] := 1;
                            else
                                wst[StP]  := cnj[h];
                                west[StP] := ev[h];
                            fi;
                        elif ev[h] < 0 and IsBound( icnj[h] ) then
                            if Length( cnj[h] ) = 1 then
                                wst[StP]  := [cnj[h][1][1],
                                              cnj[h][1][2]*ev[h]]; 
                                west[StP] := 1;
                            elif -ev[h] > pcp.PowerLimit then
                                wst[StP]  := PowerPc( pcp, icnj[h], -ev[h] );
                                west[StP] := 1;
                            else
                                wst[StP]  := icnj[h];
                                west[StP] := -ev[h];
                            fi;
                        else
                            wst[StP]  := [ h,ev[h] ];
                            west[StP] := 1;
                        fi;
                        if wst[StP] = [] then # if Power(..) is trivial
                            # happens only if pcp is inconsistent
                            StP := StP-1;     
                        else
                            gst[StP]  := 1; gest[StP] := wst[StP][2];
                        fi;
                        ev[h] := 0;    
                    fi;
                od;
            fi;
            
            # reduce exponent if necessary
            if IsBound( exp[g] ) and ev[g] >= exp[g] then
                ev[g] := ev[g] - exp[g];
                if IsBound( pow[g] ) then
                    StP := StP + 1;
                    wst[StP]  := pow[g]; west[StP] := 1;
                    gst[StP]  := 1;      gest[StP] := wst[StP][2];
                fi;
            fi;
        fi;
    od;

    return;
end;

Collect := CollectRecursive;

#############################################################################
##
#F  ReducedFormPc  . . . . . .  reduced form of a word wrt a pc presentation
##
ReducedFormPc := function( pcp, w )
    local   ev;
    
    ev := [1..Length(pcp.Generators)] * 0;
    Collect( pcp, ev, w );
    return WordExpVector(pcp, ev );
end;

#############################################################################
##
#F  CommPc  . . . . . . . . . . commutator of two words wrt a pc presentation
##
##    We have that v u [u,v] = u v.  Therefore, computing [u,v] can be
##    done by solving the equation v u x = u v for x.
##
CommPc := function( pcp, u, v )
    local   vu,  uv;
    
    # v u
    vu := ExpVectorWord( pcp, v );
    Collect( pcp, vu, u );
    vu := WordExpVector( pcp, vu );
    
    # u v
    uv := ExpVectorWord( pcp, u );
    Collect( pcp, uv, v );
    uv := WordExpVector( pcp, uv );
    
    return SolvePc( pcp, vu, uv );
end;

#############################################################################
##
#F  CommPc2 . . . . . . . . . . commutator of two words wrt a pc presentation
##
##    [ u, v ] satisfies the equation  v u [ u, v ] = u v.
##    Therefore, we solve the equation  v u  x  = u v for x.
##
CommPc2 := function( pcp, u, v )
    local   u1,  u2,  v1,  v2,  n,  x,  i;
    
    u1 := ExpVectorWord( pcp, u );  u2 := Copy( u1 );
    v1 := ExpVectorWord( pcp, v );  v2 := Copy( v1 );
    
    n := Length( pcp.Generators );
    x := [];
    for i in [1..n] do
        x[i] := u2[i] + v2[i] - (v1[i] + u1[i]);
        if IsBound(pcp.Exponent[i]) then
            while x[i] < 0 do
                x[i] := x[i] + pcp.Exponent[i];
            od;
            if x[i] >= pcp.Exponent[i] then
                x[i] := x[i] - pcp.Exponen[i];
            fi;
        fi;
        #  v1 u1 * x = u2 v2
        if x[i] <> 0 then
            Collect( pcp, u1, [ i,x[i] ] );
        fi;
        if u1[i] <> 0 then
            Collect( pcp, v1, [ i,u1[i] ] );
        fi;
        if v2[i] <> 0 then
            Collect( pcp, u2, [ i,v2[i] ] );
        fi;
    od;
    
    return WordExpVector( pcp, x );
end;

#############################################################################
##
#F  EngelCommPc . . . . . . .  compute an Engel word wrt to a pc presentation
##
EngelCommPc := function( pcp, n, u, v )
    local   i;
    
    for i in [1..n] do
        u := CommPc( pcp, u, v );
    od;
    return u;
end;
