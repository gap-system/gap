#############################################################################
##
#W  gprd.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.5  1997/01/16 10:46:24  fceller
#H  renamed 'NewConstructor' to 'NewOperation',
#H  renamed 'NewOperationFlags1' to 'NewConstructor'
#H
#H  Revision 4.4  1997/01/13 16:39:58  htheisse
#H  made `Embeddings' and `Projections' mutable
#H
#H  Revision 4.3  1996/12/19 09:59:00  htheisse
#H  added revision lines
#H
#H  Revision 4.2  1996/10/30 15:46:31  htheisse
#H  fixed errors with group products
#H
#H  Revision 4.1  1996/10/30 15:16:59  htheisse
#H  added products of permutation groups
#H
##
Revision.gprd_gd :=
    "@(#)$Id$";

IsProductGroups := NewCategory( "IsProductGroups", IsGroup );
Embeddings := NewAttribute( "Embeddings", IsProductGroups, "mutable" );

EmbeddingOp := NewOperation( "Embedding",
    [ IsProductGroups, IsPosRat and IsInt ] );
#T 1997/01/16 fceller was old 'NewConstructor'

Projections := NewAttribute( "Projections", IsProductGroups, "mutable" );

ProjectionOp := NewOperation( "Projection",
    [ IsProductGroups, IsPosRat and IsInt ] );
#T 1997/01/16 fceller was old 'NewConstructor'

IsDirectProductGroups := NewCategory( "IsDirectProductGroups",
                                 IsProductGroups );
DirectProduct := NewOperationArgs( "DirectProduct" );
DirectProduct2 := NewOperation( "DirectProduct2", [ IsGroup, IsGroup ] );

IsSubdirectProductGroups := NewCategory( "IsSubdirectProductGroups",
                                    IsProductGroups );
SubdirectProduct := NewOperation( "SubdirectProduct",
    [ IsGroup, IsGroup, IsGroupHomomorphism, IsGroupHomomorphism ] );

WreathProduct := NewOperation( "WreathProduct",
    [ IsGroup, IsGroup, IsGroupHomomorphism ] );

WreathProductProductAction := NewOperationArgs( "WreathProductProductAction" );

#############################################################################
##

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
