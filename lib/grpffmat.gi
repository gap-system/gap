#############################################################################
##
#W  grpffmat.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for matrix groups over finite field.
##
Revision.grpffmat_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  FieldOfMatrixGroup( <ffe-mat-grp> )
##
InstallMethod( FieldOfMatrixGroup,
    true,
    [ IsFFEMatrixGroup ],
    0,

function( grp )
    local   gens,  deg,  i,  j,  char;

    gens := GeneratorsOfGroup(grp);
    deg  := 1;
    for i  in gens  do
        for j  in i  do
            deg := LcmInt( deg, DegreeFFE(j) );
        od;
    od;
    if 0 < Length(gens)  then
        char := Characteristic(gens[1][1]);
    else
        char := Characteristic(One(grp)[1]);
    fi;
    return GF(char^deg);
end );


#############################################################################
##
#M  NiceMonomorphism( <ffe-mat-grp> )
##
InstallMethod( NiceMonomorphism,
    "orbit on vectors",
    true,
    [ IsFFEMatrixGroup ],
    0,

function( grp )
    local   field,  dim,  xset,  nice;

    # construct
    field  := FieldOfMatrixGroup(grp);
    dim    := DimensionOfMatrixGroup(grp);
    xset   := ExternalSubset( grp, field^dim, One(grp) );
    SetBase( xset, One(grp) );

    nice := OperationHomomorphism(xset);
    SetIsInjective( nice, true );
    return nice;

end );


#############################################################################
##

#E  grpffmat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
