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


#############################################################################
##
#M  DimensionOfMatrixGroup( <mat-grp> )
##
InstallMethod( DimensionOfMatrixGroup,
    true,
    [ IsMatrixGroup ],
    0,

function( grp )
    local   gens;

    gens := GeneratorsOfGroup(grp);
    if 0 < Length(gens)  then
        return Length(gens[1]);
    else
        return Length(One(grp));
    fi;
end );


#############################################################################
##

#E  grpmat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
