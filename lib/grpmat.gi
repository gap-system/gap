#############################################################################
##
#W  grpmat.gi                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for matrix groups.
##
Revision.grpmat_gi :=
    "@(#)$Id$";

InstallMethod( KnowsHowToDecompose, "matrix groups", true,
        [ IsMatrixGroup, IsList ], 0, ReturnFalse );

#############################################################################
##
#M  DefaultFieldOfMatrixGroup( <mat-grp> )
##
InstallMethod( DefaultFieldOfMatrixGroup,
    "using 'FieldOfMatrixGroup'",
    true,
    [ IsMatrixGroup ],
    0,
    FieldOfMatrixGroup );

InstallMethod( DefaultFieldOfMatrixGroup, "from generators in char 0", true,
        [ IsMatrixGroup and HasGeneratorsOfGroup ], 0,
    function( grp )
    if not IsEmpty( GeneratorsOfGroup( grp ) )
       and IsCyc( GeneratorsOfGroup( grp )[ 1 ][ 1 ][ 1 ] )  then
        return Cyclotomics;
    else
        TryNextMethod();
    fi;
end );

InstallMethod( DefaultFieldOfMatrixGroup, "from one in char 0", true,
        [ IsMatrixGroup and HasOne ], 1,
    function( grp )
    if IsCyc( One( grp )[ 1 ][ 1 ] )  then  return Cyclotomics;
                                      else  TryNextMethod();  fi;
end );

InstallOtherMethod( DefaultFieldOfMatrixGroup,
        "from source of nice monomorphism", true,
        [ IsMatrixGroup and HasNiceMonomorphism ], 0,
    grp -> DefaultFieldOfMatrixGroup( Source( NiceMonomorphism( grp ) ) ) );


#############################################################################
##
#M  DimensionOfMatrixGroup( <mat-grp> )
##
InstallMethod( DimensionOfMatrixGroup, "from generators", true,
    [ IsMatrixGroup and HasGeneratorsOfGroup ], 0,
    function( grp )
    if not IsEmpty( GeneratorsOfGroup( grp ) )  then
        return Length( GeneratorsOfGroup( grp )[ 1 ] );
    else
        TryNextMethod();
    fi;
end );

InstallMethod( DimensionOfMatrixGroup, "from one", true,
    [ IsMatrixGroup and HasOne ], 1,
    grp -> Length( One( grp ) ) );

InstallOtherMethod( DimensionOfMatrixGroup,
        "from source of nice monomorphism", true,
        [ IsMatrixGroup and HasNiceMonomorphism ], 0,
    grp -> DimensionOfMatrixGroup( Source( NiceMonomorphism( grp ) ) ) );


#############################################################################
##
#M  One( <mat-grp> )
##
InstallOtherMethod( One, true, [ IsMatrixGroup ], 0,
    grp -> IdentityMat( DimensionOfMatrixGroup( grp ),
                        DefaultFieldOfMatrixGroup( grp ) ) );

InstallOtherMethod( One, "from source of nice monomorphism", true,
        [ IsMatrixGroup and HasNiceMonomorphism ], 0,
    grp -> One( Source( NiceMonomorphism( grp ) ) ) );


#############################################################################
##
#M  IsomorphismPermGroup( <mat-grp> )
##
InstallMethod( IsomorphismPermGroup, true, [ IsMatrixGroup and IsFinite ], 0,
    function( grp )
    local   nice;
    
    nice := SparseOperationHomomorphism( grp, One( grp ) );
    SetRange( nice, Image( nice ) );
    SetIsBijective( nice, true );
    SetBaseOfGroup( UnderlyingExternalSet( nice ), One( grp ) );
    SetFilterObj( nice, IsOperationHomomorphismByBase );
    return nice;
end );

#############################################################################
##
#M  NiceMonomorphism( <mat-grp> )
##
InstallMethod( NiceMonomorphism, true, [ IsMatrixGroup and IsFinite ], 0,
        IsomorphismPermGroup );
#    function( grp )
#    local   nice;
#    
#    nice := IsomorphismPermGroup( grp );
#    SetNiceMonomorphism( grp, nice );
#    if IsSolvableGroup( Image( nice ) )  then
#        nice := nice * IsomorphismPcGroup( Image( nice ) );
#        SetNiceMonomorphism( grp, nice );
#    fi;
#    return nice;
#end );

#############################################################################
##
#M  ViewObj(<G>)
##
InstallMethod(ViewObj,"matrix group",true,[IsMatrixGroup],0,
function(G)
local gens;
  gens:=GeneratorsOfGroup(G);
  if Length(gens)>0 and Length(gens)*Length(gens[1])^2/VIEWLEN>8 then
    Print("<matrix group");
    if HasSize(G) then
      Print(" of size ",Size(G));
    fi;
    Print(" with ",Length(GeneratorsOfGroup(G)),
          " generators>");
  else
    Print("Group(");
    ViewObj(GeneratorsOfGroup(G));
    Print(")");
  fi;
end);


#############################################################################
##
#E  grpmat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
