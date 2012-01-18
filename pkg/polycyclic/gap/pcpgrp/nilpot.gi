############################################################################
##
#W  nilpot.gi                   Polycyc                         Bettina Eick
#W                                                             Werner Nickel
##
##  This file defines special functions for nilpotent groups. The 
##  corresponding methods are usually defined with the general methods
##  for pcp groups in other files.
##

#############################################################################
##
#F MinimalGeneratingSet( G )
##
MinimalGeneratingSetNilpotentPcpGroup := function( G )
    return GeneratorsOfPcp( Pcp( G, DerivedSubgroup(G), "snf" ) );
end;

#############################################################################
##
#F PcpNextStepCentralizer( gens, cent, pcp )
##
PcpNextStepCentralizer := function( gens, cent, pcp )
    local   pcpros,  rels,  i,  g,  newgens,  matrix,  notcentral,  h,  
            pcpgens,  comm,  null,  j,  elm,  r,  l;

    pcpgens := GeneratorsOfPcp( pcp );
    pcpros  := RelativeOrdersOfPcp( pcp );

    ##  Get the relations in this factor group.
    rels := [];
    for i in [1..Length(pcpgens)] do
        if pcpros[i] > 0 then
            r := ExponentsByPcp( pcp, pcpgens[i]^pcpros[i] );
            r[i] := -pcpros[i];
            Add( rels, r );
        fi;
    od;

    for g in gens do
#Print("start gen ",g,"\n");
        if Length( cent ) = 0 then return []; fi;

        newgens := [];
        matrix  := [];
        notcentral := [];
        for h in cent do
            comm := ExponentsByPcp( pcp, Comm( h, g ) );
            if comm = 0 * comm  then
                Add( newgens, h );
            else
                Add( notcentral, h );
                Add( matrix, comm );
            fi;
        od;
#Print("  got matrix \n");

        if Length( matrix ) > 0  then
    
            # add the relations to the matrix.
            Append( matrix, rels );

            # get nullspace
            null := PcpNullspaceIntMat( matrix );
#Print("  solved matrix \n");

            # calculate elements corresponding to null
            l := Length( notcentral );
            for j  in [1..Length(null)]  do
                elm := MappedVector( null[j]{[1..l]}, notcentral );
                if elm <> elm^0 then
                    Add( newgens, elm );
                fi;
            od;
        fi;
        cent := newgens;
    od;
    return cent;
end;

#############################################################################
##
#F CentralizeByCentralSeries( G, gens, ser )
##
CentralizeByCentralSeries := function( G, gens, ser )
    local  cent, i, pcp;

    cent := ShallowCopy( GeneratorsOfPcp( Pcp( ser[1], ser[2] ) ) );
    for i in [2..Length(ser)-1] do
        pcp  := Pcp( ser[i], ser[i+1] );
        cent := PcpNextStepCentralizer( gens, cent, pcp );
        Append( cent, GeneratorsOfPcp( pcp ) );
    od;
    Append( cent, GeneratorsOfGroup( ser[Length(ser)] ) );
    return cent;
end;

#############################################################################
##
#F Centre( G )
##
CentreNilpotentPcpGroup := function(G)
    local  ser, gens, cent;
    if Length(Igs(G)) = 0 then return G; fi;
    ser  := LowerCentralSeriesOfGroup(G);
    gens := Reversed(GeneratorsOfPcp( Pcp( ser[1], ser[2] ) ));
    cent := CentralizeByCentralSeries( G, gens, ser );
    return Subgroup( G, cent );
end;

#############################################################################
##
#F Centralizer
##
CentralizerNilpotentPcpGroup := function( G, g )
    local sers, cent, U;
    if Length(Igs(G)) = 0 then return G; fi;
    if IsPcpElement(g) then 
        if not g in G then TryNextMethod(); fi;
        sers := LowerCentralSeriesOfGroup(G);
        cent := CentralizeByCentralSeries( G, [g], sers );
    elif IsPcpGroup(g) then 
        if not IsSubgroup( G, g ) then TryNextMethod(); fi;
        SetIsNilpotentGroup( g, true );
        sers := LowerCentralSeriesOfGroup(G);
        cent := CentralizeByCentralSeries( G, MinimalGeneratingSet(g), sers );
    fi;
    return Subgroup( G, cent );
end;

#############################################################################
##
#F UpperCentralSeriesNilpotentPcpGroup( G )
##
UpperCentralSeriesNilpotentPcpGroup := function( G )
    local ser, gens, C, upp;

    ser  := LowerCentralSeriesOfGroup(G);
    gens := GeneratorsOfPcp( Pcp( ser[1], ser[2] ) );
    C    := TrivialSubgroup( G );
    upp  := [C];
    while IndexNC( G, C ) > 1 do
        ser := ModuloSeries( ser, C );
        C   := CentralizeByCentralSeries( G, gens, ser );
        C   := Subgroup( G, C );
        Add( upp, C );
    od;
    upp[ Length(upp) ] := G;
    return Reversed( upp );
end;

