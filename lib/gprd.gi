#############################################################################
##
#W  gprd.gi                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.7  1997/04/16 14:04:31  beick
#H  Added generic direct products of groups
#H
#H  Revision 4.6  1997/03/25 10:14:51  ahulpke
#H  'DirectProduct' may take a list of groups as agrument
#H
#H  Revision 4.5  1997/03/10 15:43:14  beick
#H  removed new catagory for products of groups, added products of pc groups
#H
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
local D,grps,i;
    
    if IsList(arg[1]) then
      grps:=arg[1];
    else
      grps:=arg;
    fi;
    D := grps[ 1 ];
    for i  in [ 2 .. Length( grps ) ]  do
        D := DirectProduct2( D, grps[ i ] );
    od;
    return D;
end;

#############################################################################
##
#M  DirectProduct2( <G>, <H> )
##
InstallMethod( DirectProduct2, true, [IsGroup, IsGroup], 0,
function( G, H )
    local fam, gensG, idG, gensH, idH, gens, D;
    gensG := GeneratorsOfGroup( G );
    idG   := One( G );
    gensH := GeneratorsOfGroup( H );
    idH   := One( H );
    gens  := Concatenation( 
             List( gensG, x -> Tuple( [x,idH] ) ),
             List( gensH, x -> Tuple( [idG,x] ) ) );
    D     := Group( gens );
    if HasSize( G ) and HasSize( H ) then 
        SetSize( D, Size(G)*Size(H) );
    fi;
    if HasIsSolvableGroup( G ) and HasIsSolvableGroup( H ) then
        SetIsSolvableGroup( D, IsSolvableGroup( G ) and IsSolvableGroup( H ) );
    fi;
    SetDirectProductInfo( D, rec( groups := [G, H] ) );
    return D;
end );        

#############################################################################
##
#M \in( <tuple>, <G> )
##
InstallMethod( \in, true, [IsTuple, IsGroup and HasDirectProductInfo], 0,
function( g, G )
    local n, info;
    n := Length( g );
    info := DirectProductInfo( G );
    return ForAll( [1..n], x -> g[x] in info.groups[x] );
end );
    
#############################################################################
##
#M  Size( <D> )
##
InstallMethod( Size, true, [IsGroup and HasDirectProductInfo], 0,
function( D )
    return Product( List( DirectProductInfo( D ).groups, x -> Size(x) ) );
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
