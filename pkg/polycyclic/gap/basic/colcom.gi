
##  The elements of combinatorial collection from the left are:
##
##      the exponent vector:     contains the result of the collection process
##      
##      the word stack:          stacks words which need to be collected into
##                               the exponent vector
##      the word exponent stack: stacks the exponents corresponding to each
##                               word on the word stack
##      the syllable stack:      stacks indices into the words on the word
##                               stack.  This is necessary because words may
##                               have to be collected only partially before
##                               other words are put onto the word stack.
##      the exponent stack:      stacks exponents of the generator to which
##                               the corresponding entry on the syllable
##                               stack points.  This is needed because a
##                               power of generator in a word may have to be
##                               collected partially before new words are put
##                               on the stack.
##                               
##     the two commute arrays:   
##
##     the 4 conjugation arrays:
##     the exponent array:
##     the power array:
##
##  For this collector we need normed right hand sides in the presentation.


# Collect various statistics about the combinatorial collection process
# for debugging purposes.
Counter         := 0;
CompleteCommGen := 0;
WholeCommWord   := 0;
CommRestWord    := 0;
CommGen         := 0;
CombColl        := 0;
CombCollStack   := 0;
OrdColl         := 0;
StepByStep      := 0;
ThreeWtGen      := 0;
ThreeWtGenStack := 0;

Count_Length := 0;
Count_Weight := 0;

DisplayCombCollStats := function()
    
    Print( "Calls to combinatorial collector: ", Counter,         "\n" );
    Print( "Completely collected generators:  ", CompleteCommGen, "\n" );
    Print( "Whole words collected:            ", WholeCommWord,   "\n" );
    Print( "Rest of word collected:           ", CommRestWord,    "\n" );
    Print( "Commuting generator collected:    ", CommGen,         "\n" );
    Print( "Triple weight generators:         ", ThreeWtGen,      "\n" );
    Print( "    of those had to be stacked:   ", ThreeWtGenStack, "\n" );
    Print( "Step by step collection:          ", StepByStep,      "\n" );
    Print( "Combinatorial collection:         ", CombColl,        "\n" );
    Print( "    of those had to be stacked:   ", CombCollStack,   "\n" );
    Print( "Ordinary collection:              ", OrdColl,         "\n" );
end;

ClearCombCollStats := function()

    Counter         := 0;
    CompleteCommGen := 0;
    WholeCommWord   := 0;
    CommRestWord    := 0;
    CommGen         := 0;
    CombColl        := 0;
    CombCollStack   := 0;
    OrdColl         := 0;
    StepByStep      := 0;
    ThreeWtGen      := 0;
    ThreeWtGenStack := 0;
end;

 

CombinatorialCollectPolycyclicGap := function( coc, ev, w )
    local   com,  com2,  wt,  class,  wst,  west,  
            sst,  est,  bottom,  stp,  g,  cnj,  icnj,  h,  m,  i,  j,
            astart,  IsNormed,  InfoCombi,
            ngens, pow, exp,
            ReduceExponentVector,
            AddIntoExponentVector;

##   The following is more elegant since it avoids the if-statment but it
##   uses two divisions.
#    m := ev[h];
#    ev[h] := ev[h] mod exp[h];
#    m := (m - ev[h]) / exp[h];
ReduceExponentVector := function( ev, g )
    ##  We assume that all generators after g commute with g.
    local   h,  m,  u,  j;
    Info( InfoCombinatorialFromTheLeftCollector, 5,
          " Reducing ", ev, " from ", g );

    for h in [g..ngens] do
        if IsBound( exp[h] ) and (ev[h] < 0  or ev[h] >= exp[h]) then
            m := QuoInt( ev[h], exp[h] );      
            ev[h] := ev[h] - m * exp[h];
            if ev[h] < 0 then
                m := m - 1;
                ev[h] := ev[h] + exp[h];
            fi;
                
            if ev[h] < 0  or ev[h] >= exp[h] then 
                Error( "incorrect reduction of exponent vector" );
            fi;

            if IsBound( pow[h] ) then
                u := pow[h];
                for j in [1,3..Length(u)-1] do
                    ev[ u[j] ] := ev[ u[j] ] + u[j+1] * m;
                od;
            fi;
        fi;
    od;
end;

##  ev := ev * word^exp
##  We assume that all generators after g commute with g.
AddIntoExponentVector := function( ev, word, start, e )
    local   i,  h;
    Info( InfoCombinatorialFromTheLeftCollector, 5,
          " Adding ", word, "^", e, " from ", start );
    
    Count_Length := Count_Length + Length(word);
    if start <= Length(word) then
        Count_Weight := Count_Weight + word[start];
    fi;

    for i in [start,start+2..Length(word)-1] do
        h     := word[ i ];
        ev[h] := ev[h] + word[ i+1 ] * e;
        if IsBound( exp[h] ) and (ev[h] < 0 or ev[h] >= exp[h]) then
            ReduceExponentVector( ev, h );
        fi;
    od;
end;

   if Length(w) = 0 then return true; fi;

    InfoCombi := InfoCombinatorialFromTheLeftCollector;

    Counter := Counter + 1;
    Info( InfoCombi, 4, 
          "Entering combinatorial collector (", Counter, ") ",
           ev, " * ", w );
    
    ## Check if the word is normed
    IsNormed := true;
    for i in [3,5..Length(w)-1] do 
        if not w[i-2] < w[i] then IsNormed := false; break; fi;
    od;

    ##  The following variables are global because they are needed by the
    ##  two routines above.
    ngens := coc![PC_NUMBER_OF_GENERATORS];
    pow   := coc![ PC_POWERS ];
    exp   := coc![ PC_EXPONENTS ];

    ##  weight and commutator information
    wt     := coc![ PC_WEIGHTS ];
    class  := wt[ Length(wt) ];
    com    := coc![ PC_COMMUTE ];
    com2   := coc![ PC_NILPOTENT_COMMUTE ];
    astart := coc![ PC_ABELIAN_START ];
 
    ##  the four stacks
    wst   := coc![ PC_WORD_STACK ];
    west  := coc![ PC_WORD_EXPONENT_STACK ];
    sst   := coc![ PC_SYLLABLE_STACK ];
    est   := coc![ PC_EXPONENT_STACK ];

    ##  initialise
    bottom    := coc![ PC_STACK_POINTER ];
    stp       := bottom + 1;
    wst[stp]  := w;
    west[stp] := 1;
    sst[stp]  := 1;
    est[stp]  := w[ 2 ];

    # collect
    while stp > bottom do
        Info( InfoCombi, 5,
              " Next iteration: exponent vector ", ev );

        ##  Stack Management
        if est[stp] = 0 then
            ##  The current generator has been collected completely,
            ##  advance syllable pointer.
            sst[stp] := sst[stp] + 2;
            if sst[stp] <= Length(wst[stp]) then
                ##  Get the corresponding exponent.
                est[stp] := wst[stp][ sst[stp]+1 ];
            else
                ##  The current word has been collected completely,
                ##  reduce the wrd exponent.
                west[stp] := west[stp] - 1;
                if west[stp] > 0 then
                    ##  Initialise the syllable pointer and exponent
                    ##  counter. 
                    sst[stp] := 1;
                    est[stp] := wst[stp][2];
                else
                    ##  The current word/exponent pair has been collected
                    ##  completely, move down the stacks and clear stacks
                    ##  before going down.
                    wst[ stp ] := 0; west[ stp ] := 0;
                    sst[ stp ] := 0; est[  stp ] := 0;
                    stp := stp - 1;
                fi;
            fi;

        ##  Collection
        else    ## now move the next generator/word to the correct position
            
            g := wst[stp][ sst[stp] ];             ##  get generator number

            if est[stp] > 0 then
                cnj  := coc![PC_CONJUGATES];
                icnj := coc![PC_INVERSECONJUGATES];
            elif est[stp] < 0 then
                cnj  := coc![PC_CONJUGATESINVERSE];
                icnj := coc![PC_INVERSECONJUGATESINVERSE];
            else
                Error( "exponent stack has zero entry" );
            fi;

            ##  Check if there is a single commuting generator on the stack
            ##  and collect. 
            if Length( wst[stp] ) = 1 and com[g] = g then 
                CompleteCommGen := CompleteCommGen + 1;

                Info( InfoCombi, 5,
                      " collecting single generator ", g );
                ev[ g ] := ev[ g ] + west[stp] * wst[stp][ sst[stp]+1 ];
                
                west[ stp ] := 0; est[ stp ]  := 0; sst[ stp ]  := 1;
                
                ##  Do we need to reduce ev[ g ] ?
                if IsBound( exp[g] ) and 
                   ( ev[g] < 0  or ev[ g ] >= exp[ g ]) then
                    ReduceExponentVector( ev, g );
                fi;
                
            ##  Check if we can collect a whole commuting word into ev[].  We
            ##  can only do this if the word on the stack is normed.
            ##  Therefore, we cannot do this for the first word on the stack.
            elif (IsNormed or stp > 1) and sst[stp] = 1 and g = com[g] then
                WholeCommWord := WholeCommWord + 1;

                Info( InfoCombi, 5,  
                      " collecting a whole word ", 
                      wst[stp], "^", west[stp] );
                
                ##  Collect word ^ exponent in one go.
                AddIntoExponentVector( ev, wst[stp], sst[stp], west[stp] );
#                ReduceExponentVector( ev, g );
                
                ##  Adjust the stack.
                west[ stp ] := 0; 
                est[  stp ] := 0;
                sst[  stp ] := Length( wst[stp] ) - 1;
                
            elif (IsNormed or stp > 1) and g = com[g] then
                CommRestWord := CommRestWord + 1;

                Info( InfoCombi, 5,  
                      " collecting the rest of a word ",
                      wst[stp], "[", sst[stp], "]" );

                ##  Here we must only add the word from g onwards.
                AddIntoExponentVector( ev, wst[stp], sst[stp], 1 );
#                ReduceExponentVector( ev, g );
                
                # Adjust the stack.
                est[  stp ] := 0;
                sst[  stp ] := Length( wst[ stp ] ) - 1;
                
            elif g = com[g] then
                CommGen := CommGen + 1;

                Info( InfoCombi, 5,  
                      " collecting a commuting generators ",
                      g, "^", est[stp] );

                ##  move generator directly to its correct position ...
                ev[g] := ev[g] + est[stp];
                
                ##  ... and reduce if necessary.
                if IsBound( exp[g] ) and (ev[g] < 0 or ev[g] >= exp[g]) then
                    ReduceExponentVector( ev, g );
                fi;
                
                est[stp] := 0;
                
            elif (IsNormed or stp > 1) and 3*wt[g] > class then
                ThreeWtGen := ThreeWtGen + 1;

                Info( InfoCombi, 5,
                      " collecting generator ", g, " with w(g)=", wt[g],
                      " and exponent ", est[stp] );

                ##  Collect <g>^<e> without stacking commutators.  
                ##  This is step 6 in (Vaughan-Lee 1990).
                for h in Reversed( [ g+1 .. com[g] ] ) do
                    if ev[h] > 0 and IsBound( cnj[h][g] ) then
                        AddIntoExponentVector( ev, cnj[h][g], 
                                3, ev[h] * AbsInt(est[ stp ]) );
                    elif ev[h] < 0 and IsBound( icnj[h][g] ) then
                        AddIntoExponentVector( ev, icnj[h][g], 
                                3, -ev[h] * AbsInt(est[ stp ]) );
                    fi;
                od;
                ReduceExponentVector( ev, astart );
                
                ev[g] := ev[g] + est[ stp ];
                est[ stp ] := 0;
                
                ##  If the exponent is out of range, we have to stack up the
                ##  entries of the exponent vector because the rhs of the
                ##  power relation need not satisfy the weight condition.
                if IsBound( exp[g] ) and (ev[g] < 0 or ev[g] >= exp[g] ) then
                    m := QuoInt( ev[g], exp[g] );
                    ev[g] := ev[g] - m * exp[g];
                    if ev[g] < 0 then
                        m := m - 1;
                        ev[g] := ev[g] + exp[g];
                    fi;
                    if IsBound(pow[g]) then 
                        ##  Put entries of the exponent vector onto the stack 
                        ThreeWtGenStack := ThreeWtGenStack + 1;
                        for i in Reversed( [g+1 .. com[g]] ) do
                            if ev[i] <> 0 then
                                stp := stp + 1;
                                ##  Can we use gen[i] here and put ev[i] onto
                                ##  est[]?
                                wst[stp]  := [ i, ev[i] ];
                                west[stp] := 1;
                                sst[stp]  := 1;      
                                est[stp]  := wst[stp][ sst[stp] + 1 ];
                                ev[i] := 0;
                            fi;
                        od;
                        ##  m must be 1, otherwise we cannot add the power
                        ##  relation into the exponent vector.  Let´s check. 
                        if m <> 1 then
                            Error( "illegal add operation in collection" );
                        fi;
                        AddIntoExponentVector( ev, pow[g], 1, m );
                        ##  Start reducing from com[g] on because the entries
                        ##  before that have been put onto the stack and are
                        ##  now zero.
#                        ReduceExponentVector( ev, astart );
                    fi;
                fi;
                
            else                 ##  we have to move <gn> step by step
                StepByStep := StepByStep + 1;

                Info( InfoCombi, 5, " else-case, generator ", g );
                
                if est[ stp ] > 0 then
                    est[ stp ] := est[ stp ] - 1;
                    ev[ g ] := ev[ g ] + 1;
                else
                    est[ stp ] := est[ stp ] + 1;
                    ev[ g ] := ev[ g ] - 1;
                fi;
                
                if IsNormed or stp > 1 then
                    ##  Do combinatorial collection as far as possible.
                    CombColl := CombColl + 1;
                    for h in Reversed( [com2[g]+1..com[g]] ) do
                        if ev[h] > 0 and IsBound( cnj[h][g] ) then
                            AddIntoExponentVector( ev, cnj[h][g], 3, ev[h] );
                        elif ev[h] < 0 and IsBound( icnj[h][g] ) then
                            AddIntoExponentVector( ev, icnj[h][g], 3, -ev[h] );
                        fi;
                    od;
#                    ReduceExponentVector( ev, astart );
                    h := com2[g];
                else
                    h := com[g];
                fi;
                
                ##  Find the first position in v from where on ordinary
                ##  collection  has to be applied.
                while h > g do
                    if ev[h] <> 0 and IsBound( cnj[h][g] ) then
                        break;
                    fi;
                    h := h - 1;
                od;
                
                ##  Stack up this part of v if we run through the next 
                ##  for-loop or if a power relation will be applied 
                if g < h or 
                   IsBound( exp[g] ) and 
                   (ev[g] < 0 or ev[g] >= exp[g]) and IsBound(pow[g]) then

                    if h+1 <= com[g] then
                        CombCollStack := CombCollStack + 1;
                    fi;

                    for j in Reversed( [h+1..com[g]] ) do
                        if ev[j] <> 0 then
                            stp := stp + 1;
                            ##  Can we use gen[h] here and put ev[h] onto
                            ##  est[]?
                            wst[stp]  := [ j, ev[j] ];
                            west[stp] := 1;
                            sst[stp]  := 1;      
                            est[stp]  := wst[stp][ sst[stp] + 1 ];
                            ev[j] := 0;
                            Info( InfoCombi, 5,  
                                  "   Putting ", wst[ stp ], "^", west[stp],
                                  " onto the stack" );
                        fi;
                    od;
                fi;
                
                ##  We finish with ordinary collection from the left.
                if g <> h then
                    OrdColl := OrdColl + 1;
                fi;

                Info( InfoCombi, 5,
                      " Ordinary collection: g = ", g, ", h = ", h );
                while g < h do 
                    Info( InfoCombi, 5,  
                          "Executing while loop with h = ", h );
                    
                    if  ev[h] <> 0 then
                        stp := stp + 1;
                        if ev[h] > 0 and IsBound( cnj[h][g] ) then
                            wst[stp]  := cnj[h][g];
                            west[stp] := ev[h];
                        elif ev[h] < 0 and IsBound( icnj[h][g] ) then
                            wst[stp]  := icnj[h][g];
                            west[stp] := -ev[h];
                        else  ##  Can we use gen[h] here and put ev[h]
                              ##  onto est[]?
                            wst[stp]  := [ h, ev[h] ];
                            west[stp] := 1;
                        fi;
                        sst[stp]  := 1;      
                        est[stp]  := wst[stp][ sst[stp]+1 ];
                        ev[h] := 0;
                        Info( InfoCombi, 5, 
                              "   Putting ", wst[ stp ], "^", west[stp],
                               " onto the stack" );
                    fi;
                    
                    h := h - 1;
                od;
                
                ##  check that the exponent is not too big
                if IsBound( exp[g] ) and (ev[g] < 0 or ev[g] >= exp[g]) then
                    m := ev[g] / exp[g];
                    ev[g] := ev[g] - m * exp[g];
                    if ev[g] < 0 then
                        m := m - 1;
                        ev[g] := ev[g] + exp[g];
                    fi;

                    if IsBound( pow[g] ) then
                        stp := stp + 1;
                        wst[stp]  := pow[g];
                        west[stp] := m;
                        sst[stp]  := 1;      
                        est[stp]  := wst[stp][ sst[stp]+1 ];
                        Info( InfoCombi, 5, 
                              "   Putting ", wst[ stp ], "^", west[stp],
                               " onto the stack" );
                    fi;
                fi;
            fi;
        fi;
    od;
    return true;
end;




#############################################################################
##  
##  Methods for  CollectWordOrFail.
##
InstallMethod( CollectWordOrFail,
        "CombinatorialFromTheLeftCollector",
        true,
        [ IsFromTheLeftCollectorRep and IsUpToDatePolycyclicCollector
          and IsWeightedCollector,
          IsList, IsList ],
        0,
function( pcp, a, b )
    local   aa,  aaa;

    if DEBUG_COMBINATORIAL_COLLECTOR then
        aa  := ShallowCopy(a);
        aaa := ShallowCopy(a);
        CombinatorialCollectPolycyclicGap( pcp, a, b );
        CollectPolycyclicGap( pcp, aa, b );
        if aa <> a then
            Error( "combinatorial collection failed" );
        fi;
    else
        CombinatorialCollectPolycyclicGap( pcp, a, b );
    fi;
    return true;
end );  

