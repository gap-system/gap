
DeclareCategoryKernel("IsPartialPerm", IsMultiplicativeElementWithInverse 
and IsAssociativeElement, IS_PPERM);

DeclareCategoryCollections( "IsPartialPerm" );
DeclareCategoryCollections( "IsPartialPermCollection" );

BIND_GLOBAL("PartialPermFamily", NewFamily("PartialPermFamily",
 IsPartialPerm, CanEasilySortElements, CanEasilySortElements));

DeclareRepresentation( "IsPPerm2Rep", IsInternalRep, [] );
DeclareRepresentation( "IsPPerm4Rep", IsInternalRep, [] );

BIND_GLOBAL("TYPE_PPERM2", NewType(PartialPermFamily,
 IsPartialPerm and IsPPerm2Rep));

BIND_GLOBAL("TYPE_PPERM4", NewType(PartialPermFamily,
 IsPartialPerm and IsPPerm4Rep));


