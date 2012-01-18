#############################################################################
##
#W   abelaut.gd                  Polycyc                         Bettina Eick
##

# APEndos form a ring. In order to allow the operations One and Inverse,
# we make them Scalars. 
DeclareCategory( "IsAPEndo", IsScalar );
#            IsMultiplicativeElement and IsAdditiveElementWithInverse );
DeclareCategoryFamily( "IsAPEndo" );
DeclareCategoryCollections( "IsAPEndo" );
APEndoFamily := NewFamily( "APEndoFam", IsAPEndo, IsAPEndo );
DeclareRepresentation( "IsAPEndoRep", IsComponentObjectRep, 
            ["mat", "dim", "exp", "prime"] );

DeclareGlobalFunction( "APEndoNC" );
DeclareGlobalFunction( "APEndo" );


