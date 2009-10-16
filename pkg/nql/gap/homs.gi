############################################################################
##
#W homs.gi			NQL				René Hartung
##
#H   @(#)$Id: homs.gi,v 1.3 2009/02/13 07:41:48 gap Exp $
##
Revision.("nql/gap/homs_gi"):=
  "@(#)$Id: homs.gi,v 1.3 2009/02/13 07:41:48 gap Exp $";


############################################################################
##
#M  GroupGeneralMappingByImages( G, H, gens, imgs )
##
InstallMethod( GroupGeneralMappingByImages,
   "from an L-presented group into a Pcp group", 
   true, 
   [IsLpGroup,IsPcpGroup,IsList,IsList], 0,
   function ( G, H, gens, imgs)
   local filt,	# filter for the new type
	 type,	# type
	 hom;   # the homomorphism

   if Length(gens)<>Length(imgs) then 
     Error("gens and imgs must have same length");
   fi;

   filt:=IsGroupGeneralMappingByImages and IsTotal and 
         IsToPcpGHBI and HasSource and HasRange and 
         HasMappingGeneratorsImages;

   type:=NewType( GeneralMappingsFamily( ElementsFamily(FamilyObj(G)),
                  ElementsFamily( FamilyObj( H ) )), filt);

   hom:=rec();
   ObjectifyWithAttributes(hom, type,
                Source, G,
		Range, H,
		MappingGeneratorsImages, [gens,imgs]);
  
   return(hom);
   end);

############################################################################
##
#M  GroupHomomorphismByImagesNC ( <src> , <rng> , <img> )
##
## a method for homomorphism from an LpGroup to a PcpGroup.
##
InstallMethod( GroupHomomorphismByImagesNC,
        "for homs from LpGroups into PcpGroups",
        true,
        [ IsLpGroup, IsPcpGroup, IsList, IsList],0,
        function(G,H,gens,imgs)
        local hom;	

        if not GeneratorsOfGroup(G)=gens then 
          TryNextMethod();
        fi;
        if not Length(imgs)=Length(gens) then 
          TryNextMethod();
        fi;

        hom:=GroupGeneralMappingByImages(G,H,gens,imgs);

        SetIsMapping(hom,true); 
        return(hom);
        end);


############################################################################
##
#M  ImageElm ( <map> , <elm> )
##
## computes the image of the L-presented group element <elm> under the
## homomorphism <map> into a PcpGroup.
##
InstallMethod( ImageElm, 
   "from L-presented group into PcpGroups ",
   FamSourceEqFamElm,
   [ IsMapping and HasMappingGeneratorsImages, IsElementOfLpGroup ],1,
   function(map,elm)
   local img,		# build the result as product of the word
         i,		# loop variable
	 ExtElm; 	# external representation of the LpGroup element
   img:=One(Range(map));
   ExtElm:=ExtRepOfObj(UnderlyingElement(elm));
   for i in [1,3..Length(ExtElm)-1] do
     img:=img*(MappingGeneratorsImages(map)[2][ExtElm[i]]) ^ ExtElm[i+1];
   od;
   return(img);
   end);
