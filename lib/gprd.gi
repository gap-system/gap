#############################################################################
##
#W  gprd.gi                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.4  1997/02/13 10:38:20  ahulpke
#H  Added 'Embedding' and 'Projection' for semidirect products
#H
#H  Revision 4.3  1996/12/19 09:59:01  htheisse
#H  added revision lines
#H
#H  Revision 4.2  1996/10/30 15:46:33  htheisse
#H  fixed errors with group products
#H
#H  Revision 4.1  1996/10/30 15:17:01  htheisse
#H  added products of permutation groups
#H
##
Revision.gprd_gi :=
    "@(#)$Id$";

DirectProduct := function( arg )
    local   D,  i;
    
    D := arg[ 1 ];
    for i  in [ 2 .. Length( arg ) ]  do
        D := DirectProduct2( D, arg[ i ] );
    od;
    return D;
end;

InstallOtherMethod( Embedding, true,
        [ IsProductGroups, IsPosRat and IsInt ], 0,
    function( D, i )
    local   embs;
    
    embs := Embeddings( D );
    if not IsBound( embs[ i ] )  then
        embs[ i ] := EmbeddingOp( D, i );
    fi;
    return embs[ i ];
end );

InstallMethod( Embeddings, true, [ IsProductGroups ], 0, P -> [  ] );

InstallOtherMethod( Projection, true,
        [ IsProductGroups, IsPosRat and IsInt ], 0,
    function( D, i )
    local   pros;
    
    pros := Projections( D );
    if not IsBound( pros[ i ] )  then
        pros[ i ] := ProjectionOp( D, i );
    fi;
    return pros[ i ];
end );

InstallMethod( Projections, true, [ IsProductGroups ], 0, P -> [  ] );

# method for semidirect products
InstallOtherMethod( Projection, true,
        [ IsSemidirectProductGroups ], 0,
    function( D )
    
    return Projections( D )[1];
end );

#############################################################################
##

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
