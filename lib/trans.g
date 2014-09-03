
DeclareCategoryKernel("IsTransformation",
        IsMultiplicativeElementWithInverse and IsAssociativeElement,
        IS_TRANS);

DeclareCategoryCollections( "IsTransformation" );
DeclareCategoryCollections( "IsTransformationCollection" );

BIND_GLOBAL("TransformationFamily", NewFamily("TransformationFamily",
 IsTransformation, CanEasilySortElements, CanEasilySortElements));

DeclareRepresentation( "IsTrans2Rep", IsInternalRep, [] );
DeclareRepresentation( "IsTrans4Rep", IsInternalRep, [] );

BIND_GLOBAL("TYPE_TRANS2", NewType(TransformationFamily,
 IsTransformation and IsTrans2Rep));

BIND_GLOBAL("TYPE_TRANS4", NewType(TransformationFamily,
 IsTransformation and IsTrans4Rep));

