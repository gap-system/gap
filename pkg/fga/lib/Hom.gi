#############################################################################
##
#W  Hom.gi                   FGA package                    Christian Sievers
##
##  Methods for homomorphisms of free groups
##
#H  @(#)$Id: Hom.gi,v 1.7 2011/09/20 11:45:46 gap Exp $
##
#Y  2003 - 2010
##
Revision.("fga/lib/Hom_gi") :=
    "@(#)$Id: Hom.gi,v 1.7 2011/09/20 11:45:46 gap Exp $";


InstallMethod( PreImagesRepresentative,
    "for homomorphisms of free groups",
    FamRangeEqFamElm,
    [ IsGroupGeneralMappingByImages, IsElementOfFreeGroup ],
    function( hom, x )
    local w, mgi;
    mgi := MappingGeneratorsImages( hom );
    w := AsWordLetterRepInGenerators( x, ImagesSource(hom) );
    if w = fail then
        return fail;
    fi;
    return Product( w, i -> mgi[1][AbsInt(i)]^SignInt(i),
                    One(Source(hom)));
    end );

InstallMethod( ImagesRepresentative,
    "for homomorphisms of free groups",
    FamSourceEqFamElm,
    [ IsGroupGeneralMappingByImages, IsElementOfFreeGroup ],
    23,
    function( hom, x )
    local w, mgi;
    mgi := MappingGeneratorsImages( hom );
    if mgi[1]=[] then return One(Range(hom)); fi;
    
    w := AsWordLetterRepInGenerators( x, Group( mgi[1] ));
    if w = fail then
        return fail;
    fi;
    return Product( w, i -> mgi[2][AbsInt(i)]^SignInt(i),
                    One(Range(hom)));
    end );

InstallMethod( IsSingleValued,
   "for group general mappings of free groups",
   [ IsFromFpGroupGeneralMappingByImages and HasMappingGeneratorsImages ],
   function( hom )
   local mgi, g, imgs;
   mgi := MappingGeneratorsImages( hom );

   if mgi[1]=[] then return true; fi; # map on trivial group

   g := Group( mgi[1] );
   if not IsFreeGroup( g ) then
      TryNextMethod();
   fi;
   if Size( mgi[1] ) = RankOfFreeGroup( g ) then
      return true;
   fi;

   # write free generators in given generators and
   # compute corresponding images:
   imgs := List( FreeGeneratorsOfGroup( g ), fgen -> 
                   Product( AsWordLetterRepInGenerators( fgen, g ),
	                    i -> mgi[2][AbsInt(i)]^SignInt(i),
		            One(Range(hom)) ));

   # check if all given generator/image pairs agree with the
   # map given by free generators and computed images:
   return ForAll( [ 1 .. Size( mgi[1] ) ], n -> 
                    mgi[2][n] =
                    Product( 
		      AsWordLetterRepInFreeGenerators( mgi[1][n], g ),
		      i -> imgs[AbsInt(i)]^SignInt(i),
		      One(Range(hom)) ));
   end );


#############################################################################
##
#E
