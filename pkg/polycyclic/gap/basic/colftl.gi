CollectPolycyclicGap := function( pcp, ev, w )
    
    local   ngens,  pow,  exp,  com,  wst,  west,  sst,  est,  bottom,  
            stp,  g,  word,  exponent,  i,  h,  m,  u,  j,  cnj,  
            icnj,  hh;
    
    if Length( w ) = 0 then return true; fi;
    

    ngens := pcp![PC_NUMBER_OF_GENERATORS];

    pow := pcp![ PC_POWERS ];
    exp := pcp![ PC_EXPONENTS ];
    com := pcp![ PC_COMMUTE ];
    
    wst  := pcp![ PC_WORD_STACK ];
    west := pcp![ PC_WORD_EXPONENT_STACK ];
    sst  := pcp![ PC_SYLLABLE_STACK ];
    est  := pcp![ PC_EXPONENT_STACK ];
    
    bottom    := pcp![ PC_STACK_POINTER ];
    stp       := bottom + 1;
    wst[stp]  := w;
    west[stp] := 1;
    sst[stp]  := 1;
    est[stp]  := w[ 2 ];

    # collect
    while stp > bottom do
        
        if est[stp] = 0 then
            # initialise est
            sst[stp] := sst[stp] + 1;
            if sst[stp] > Length(wst[stp])/2 then
                west[stp] := west[stp] - 1;
                if west[stp] <= 0 then
                    ## clear stacks before going down
                    wst[  stp ] := 0;
                    west[ stp ] := 0;
                    sst[  stp ] := 0;
                    est[  stp ] := 0;

                    stp := stp - 1;
                else
                    sst[stp] := 1;
                    est[stp] := wst[stp][2];
                fi;
            else
                est[stp] := wst[stp][ 2*sst[stp] ];
            fi;
        else
            
            # get next generator
            g := wst[stp][ 2*sst[stp]-1 ];
            
            if stp > 1 and sst[stp] = 1 and g = com[g] then
                ## collect word ^ exponent in one go

                word      := wst[stp];
                exponent  := west[stp];
                ##  Add the word into ev
                for i in [1,3..Length(word)-1] do
                    h     := word[ i ];
                    ev[h] := ev[h] + word[ i+1 ] * exponent;
                od;

                ##  Now reduce.
                for h in [word[1]..ngens] do
                    if IsBound( exp[h] ) and ev[h] >= exp[h] then
                        m     := QuoInt( ev[h], exp[h] );
                        ev[h] := ev[h] mod exp[h];
                        
                        if IsBound( pow[h] ) then
                            u := pow[h];
                            for j in [1,3..Length(u)-1] do
                                ev[ u[j] ] := ev[ u[j] ] + u[j+1] * m;
                            od;
                        fi;
                    fi;
                od;

                west[ stp ] := 0;
                est[  stp ] := 0;
                sst[  stp ] := Length( word );

            elif g = com[g] then
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
                
                h := com[g];

                # Find first position where we need to collect
                while h > g do
                    if ev[h] <> 0 then
                        if ev[h] > 0 then
                            if IsBound(  cnj[h][g] ) then break; fi;
                        else
                            if IsBound( icnj[h][g] ) then break; fi;
                        fi;
                    fi;
                    h := h-1;
                od;


                # Put that part on the stack, if necessary
                if h > g or 
                   ( IsBound(exp[g]) 
                     and (ev[g] < 0 or ev[g] >= exp[g])
                     and IsBound(pow[g]) ) then

                    for hh in [com[g],com[g]-1..h+1] do
                        if ev[hh] <> 0 then
                            stp := stp+1;
                            if stp > pcp![ PC_STACK_SIZE ] then
                                return fail;
                            fi;
                            if ev[hh] > 0 then
                                wst[stp]  := pcp![ PC_GENERATORS ][hh];
                                west[stp] := ev[hh];
                            else
                                wst[stp]  := pcp![ PC_INVERSES ][hh];
                                west[stp] := -ev[hh];
                            fi;
                            sst[stp] := 1;
                            est[stp] := wst[stp][ 2 ];
                            ev[hh] := 0;
                        fi;
                    od;
                fi;

                
                # move generator across the exponent vector
                while h > g do
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
                        sst[stp] := 1;
                        est[stp] := wst[stp][ 2 ];
                        ev[h] := 0;    
                    fi;
                    h := h-1;
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
    return true;
end;

PrintCollectionStack := function( stp, wst, west, sst, est )

    while stp > 0 do
        Print( wst[stp], "^", west[stp], 
               " at ", sst[stp], " with exponent ", est[stp], "\n" );
        stp := stp - 1;
    od;
end;

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
        [ IsFromTheLeftCollectorRep and IsUpToDatePolycyclicCollector,
          IsList, IsList ],
        0,
function( pcp, a, b )

    if USE_LIBRARY_COLLECTOR then
        return CollectPolycyclicGap( pcp, a, b );
    else
        CollectPolycyclic( pcp, a, b );
        return true;
    fi;
end );  

InstallMethod( CollectWordOrFail,
        "FromTheLeftCollector",
        true, 
        [ IsFromTheLeftCollectorRep and IsUpToDatePolycyclicCollector and
          UseLibraryCollector,
          IsList, IsList ],
        0,
        CollectPolycyclicGap );

