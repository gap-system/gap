#############################################################################
##
#W  grpmat.gi                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for matrix groups.
##
Revision.grpmat_gi :=
    "@(#)$Id$";


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


#############################################################################
##
#M  One( <mat-grp> )
##
InstallOtherMethod( One, true, [ IsMatrixGroup ], 0,
    grp -> IdentityMat( DimensionOfMatrixGroup( grp ),
                        DefaultFieldOfMatrixGroup( grp ) ) );


#############################################################################
##
#M  NiceMonomorphism( <mat-grp> )
##
InstallMethod( NiceMonomorphism, true, [ IsMatrixGroup and IsFinite ], 0,
    function( grp )
    local   nice;
    
    nice := SparseOperationHomomorphism( grp, One( grp ) );
    SetIsInjective( nice, true );
    return nice;
end );


#############################################################################
##

#E  grpmat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
