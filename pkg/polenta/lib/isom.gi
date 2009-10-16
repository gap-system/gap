#############################################################################
##
#W isom.gi                 POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of 
## isommorphisms from matrix groups to pcp-presentations 
##
#H  @(#)$Id: isom.gi,v 1.7 2006/07/17 15:46:10 gap Exp $
##
#Y 2003
##

#############################################################################
##
#F POL_IsomorphismToMatrixGroup_infinite
##
POL_IsomorphismToMatrixGroup_infinite := function( arg )
    local CPCS, pcp, H, nat,G;
    G := arg[1];
    # calculate a constructive pc-sequence
    if Length( arg ) = 2 then
        CPCS := CPCS_PRMGroup( G, arg[2] );
    else
        CPCS := CPCS_PRMGroup( G );
    fi;
    if CPCS = fail then return fail; fi;
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Compute the relations of the polycyclic\n",
          "    presentation of the group ..." );
    pcp := POL_SetPcPresentation_infinite( CPCS );
    Info( InfoPolenta, 1,"finished." );
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Construct the polycyclic presented group ..." );
    if AssertionLevel() = 0 then
        H := PcpGroupByCollector( pcp );
    else
        H := PcpGroupByCollector( pcp );
    fi;
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Construct the ismorphism on the polycyclic\n",
          "    presented group ..." );
    nat := GroupHomomorphismByImagesNC( G, H, CPCS.pcs, AsList(Pcp(H)) );
    Info( InfoPolenta, 1,"finished."); 

    # add infos
    SetIsBijective( nat, true );
    SetIsMapping( nat, true );
    SetKernelOfMultiplicativeGeneralMapping( nat, TrivialSubgroup( G ) );
    SetIsIsomorphismByPolycyclicMatrixGroup( nat, true );

    nat!.CPCS := CPCS;
    return nat;
end;

#############################################################################
##
#F POL_IsomorphismToMatrixGroup_finite
##
POL_IsomorphismToMatrixGroup_finite := function( G )
    local CPCS, pcp, H, nat, gens, d, pcs, bound_derivedLength;

     Info( InfoPolenta, 1,"Determine a constructive polycyclic sequence\n",
           "    for the input group ...");
    # calculate a constructive pc-sequence
    gens := GeneratorsOfGroup( G );
    d := Length(gens[1][1]);
    # determine un upperbound for the derived length of G
    bound_derivedLength := d+2;
    CPCS := CPCS_finite_word( gens, bound_derivedLength );
    if CPCS = fail then return fail; fi;
    Info( InfoPolenta, 1, "finished." );
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Compute the relations of the polycyclic\n",
          "    presentation of the group ..." );
    pcp := POL_SetPcPresentation_finite( CPCS );
    Info( InfoPolenta, 1,"finished." );
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Construct the polycyclic presented group ..." );
    H := PcpGroupByCollector( pcp );
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, " " );

    # new generating set for G
    pcs := Reversed(CPCS.gens);
    Info( InfoPolenta, 1,"Construct the ismorphism on the polycyclic\n",
          "    presented group ..." );
    nat := GroupHomomorphismByImagesNC( G, H, pcs, AsList(Pcp(H)) );
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, " " );
 
    # add infos
    SetIsBijective( nat, true );
    SetIsMapping( nat, true );
    SetKernelOfMultiplicativeGeneralMapping( nat, true );
    SetIsIsomorphismByFinitePolycyclicMatrixGroup( nat, true );

    nat!.CPCS := CPCS;
    return nat;
end;

#############################################################################
##
#M Create isom to pcp group
##
InstallOtherMethod( IsomorphismPcpGroup, "for matrix groups (Polenta)", true,
[IsMatrixGroup], 0,
function( G ) 
    local test;
    test := POL_IsMatGroupOverFiniteField( G );
    if IsBool( test ) then
        TryNextMethod();
    elif test = 0 then
        return POL_IsomorphismToMatrixGroup_infinite( G ); 
    else
        return POL_IsomorphismToMatrixGroup_finite( G );
    fi;  
end);

InstallOtherMethod( IsomorphismPcpGroup, "for matrix groups (Polenta)", true,
[IsMatrixGroup, IsInt], 0,
function( G, p ) 
    local test;
    test := POL_IsMatGroupOverFiniteField( G );
    if IsBool( test ) then
        TryNextMethod();
    elif test = 0 then
        if not IsPrime(p) then
            Print( "Second argument must be a prime number.\n" );
            return fail;
        fi;  
        return POL_IsomorphismToMatrixGroup_infinite( G, p ); 
    else
        return POL_IsomorphismToMatrixGroup_finite( G );
    fi;  
end);


#############################################################################
##
#M Images under IsomorphismByPolycyclicMatrixGroup
##
InstallMethod( ImagesRepresentative, "for isom by matrix groups (Polenta)", true,
[IsIsomorphismByPolycyclicMatrixGroup, 
IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local H, e, CPCS;
    CPCS := nat!.CPCS;
    H := Range( nat );
    e := ExponentVector_CPCS_PRMGroup( h, CPCS );
    if e=fail then return fail; fi;
    if Length(e)=0 then return OneOfPcp( Pcp( H ) );fi;
    return MappedVector( e, Pcp(H) );
end);
 
InstallMethod( ImageElm, "for isom by matrix groups (Polenta)", true,
[IsIsomorphismByPolycyclicMatrixGroup, 
IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local H, e, CPCS;
    CPCS := nat!.CPCS;
    H := Range( nat );
    e := ExponentVector_CPCS_PRMGroup( h, CPCS );
    if e=fail then return fail; fi;
    if Length(e)=0 then return OneOfPcp( Pcp( H ) );fi;
    return MappedVector( e, Pcp(H) );
end);
 
InstallMethod( ImagesSet,"for isom by matrix groups (Polenta)", true,
[IsIsomorphismByPolycyclicMatrixGroup, IsCollection], 0,
function( nat, elms )
    local  H, e, CPCS,exps,h;
    CPCS := nat!.CPCS;
    H := Range( nat );
    exps := [];
    for h in elms do
        e := ExponentVector_CPCS_PRMGroup( h, CPCS );
        Add(exps, e );
    od;
    return List( exps, function(x)
                          if x=fail then return fail;
                          elif Length(e)=0 then return OneOfPcp( Pcp( H ) );
                          else return MappedVector( x, Pcp(H) );
                          fi;
                          end );
end);

#############################################################################
##
#M Images under IsomorphismByFinitePolycyclicMatrixGroup
##
InstallMethod( ImagesRepresentative, "for isom by finite matrix groups (Polenta)", 
true, [IsIsomorphismByFinitePolycyclicMatrixGroup, 
IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local H, e, CPCS;
    CPCS := nat!.CPCS;
    H := Range( nat );
    e := ExponentvectorPcgs_finite( CPCS, h );
    if e=fail then return fail; fi;
    if Length(e)=0 then return OneOfPcp( Pcp( H ) );fi;
    return MappedVector( e, Pcp(H) );
end);
 
InstallMethod( ImageElm, "for isom by finite matrix groups (Polenta)", true,
[IsIsomorphismByFinitePolycyclicMatrixGroup, 
IsMultiplicativeElementWithInverse], 0,
function( nat, h )
    local H, e, CPCS;
    CPCS := nat!.CPCS;
    H := Range( nat );
    e := ExponentvectorPcgs_finite( CPCS, h );
    if e=fail then return fail; fi;
    if Length(e)=0 then return OneOfPcp( Pcp( H ) );fi;
    return MappedVector( e, Pcp(H) );
end);
 
InstallMethod( ImagesSet,"for isom by finite matrix groups (Polenta)", true,
[IsIsomorphismByFinitePolycyclicMatrixGroup, IsCollection], 0,
function( nat, elms )
    local  H, e, CPCS,exps,h;
    CPCS := nat!.CPCS;
    H := Range( nat );
    exps := [];
    for h in elms do
        e := ExponentvectorPcgs_finite( CPCS, h );
        Add(exps, e );
    od;
    return List( exps, function(x)
                          if x=fail then return fail;
                          elif Length(e)=0 then return OneOfPcp( Pcp( H ) );
                          else return MappedVector( x, Pcp(H) );
                          fi;
                          end );
end);


#############################################################################
##
#E

