##############################################################################
##
##    This file contains a collector from the left for polycyclic
##    presentations.  The collector is based on the paper by
##    Leedham-Green & Soicher on 'Collection from the Left and Other
##    Strategies'. 
##

##    imported functions
if not IsBound( ComputeCommute ) then
    ComputeCommute := function( arg )
        Error( "ComputeCommute() undefined. Read polycyc.g!" );
    end;
fi;

CollectSimple := function( pcp, ev, w )
    local   com,  pow,  exp,  stp,  wst,  west,  gst,  gest,  g,  cnj,  
            icnj,  h;
    
    if w = [] then return; fi;
    
    if IsBound( pcp.Commute ) then
        com := pcp.Commute;
    else
        com := ComputeCommute( pcp );
    fi;
    
    pow := pcp.Power;
    exp := pcp.Exponent;
    
    # initialise the 4 stacks needed for collection from the left
    stp  := 1;
    wst  := [ w ];
    west := [ 1 ];
    gst  := [ 1 ];
    gest := [ w[2] ];
    
    # collect
    while stp > 0 do
        
        if gest[stp] = 0 then
            # initialise gest
            gst[stp] := gst[stp] + 2;
            if gst[stp] > Length(wst[stp]) then
                west[stp] := west[stp] - 1;
                if west[stp] = 0 then
                    stp := stp - 1;
                else
                    gst[stp] := 1;
                    gest[stp] := wst[stp][2];
                fi;
            else
                gest[stp] := wst[stp][ gst[stp] + 1 ];
            fi;
        else
            
            # get next generator
            g := wst[stp][ gst[stp] ];
            
            if g = com[g] then
                # move generator directly to its correct position
                ev[g] := ev[g] + gest[stp];
                gest[stp] := 0;
            else
                if gest[stp] > 0 then
                    gest[stp] := gest[stp] - 1;
                    ev[g] := ev[g] + 1;
                    cnj   := pcp.Conjugate;
                    icnj  := pcp.InverseConjugate;
                else
                    gest[stp] := gest[stp] + 1;
                    ev[g] := ev[g] - 1;
                    cnj   := pcp.ConjugateInverse;
                    icnj  := pcp.InverseConjugateInverse;
                fi;
                # move generator across the exponent vector
                for h in [com[g],com[g]-1..g+1] do
                    if ev[h] <> 0 then
                        if ev[h] > 0 then
                            if IsBound( cnj[h][g] ) then
                                stp := stp+1;
                                wst[stp]  := cnj[h][g];
                                west[stp] := ev[h];
                            else
                                stp := stp+1;
                                wst[stp]  := [ h,ev[h] ];
                                west[stp] := 1;
                            fi;
                        else
                            if IsBound( icnj[h][g] ) then
                                stp := stp+1;
                                wst[stp]  := icnj[h][g];
                                west[stp] := -ev[h];
                            else
                                stp := stp+1;
                                wst[stp]  := [ h,ev[h] ];
                                west[stp] := 1;
                            fi;
                        fi;
                        gst[stp]  := 1; gest[stp] := wst[stp][2];
                        ev[h] := 0;    
                    fi;
                od;
            fi;
            
            # reduce exponent if necessary
            if IsBound( exp[g] ) and ev[g] >= exp[g] then
                ev[g] := ev[g] - exp[g];
                if IsBound( pow[g] ) then
                    stp := stp+1;
                    wst[stp]  := pow[g]; west[stp] := 1;
                    gst[stp]  := 1;      gest[stp] := wst[stp][2];
                fi;
            fi;
        fi;
    od;
    return;
end;

Collect := CollectSimple;
