#############################################################################
##
#W  grphoms.gi                   Polycyc                         Bettina Eick
##

#############################################################################
##
## Functions to deal with homomorphisms to and from pcp groups.
##

BindGlobal( "GroupGeneralMappingByImages_for_pcp", function( G, H, gens, imgs )
    local mapi, filter, type, hom, pcgs, p, l, obj_args;
 
    hom  := rec( );
    if Length( gens ) <> Length( imgs ) then
        Error("gens and imgs must have same length");
    fi;

    mapi := [Immutable(gens), Immutable(imgs)];

    filter := IsGroupGeneralMappingByImages
            and HasSource and HasRange and HasMappingGeneratorsImages;

	if IsPcpGroup(G) then
        hom!.igs_gens_to_imgs := IgsParallel( gens, imgs );
        filter := IsFromPcpGHBI;
	elif IsPcGroup( G ) and IsPrimeOrdersPcgs(Pcgs(G))  then
		filter := filter and IsPcGroupGeneralMappingByImages;
		pcgs  := CanonicalPcgsByGeneratorsWithImages( Pcgs(G), mapi[1], mapi[2] );
		hom.sourcePcgs       := pcgs[1];
		hom.sourcePcgsImages := pcgs[2];
		if pcgs[1]=Pcgs(G) then
			filter := filter and IsTotal;
		fi;
	elif IsPcgs( gens )  then
		filter := filter and IsGroupGeneralMappingByPcgs;
		hom.sourcePcgs       := mapi[1];
		hom.sourcePcgsImages := mapi[2];
    elif IsSubgroupFpGroup(G) then
	  if HasIsWholeFamily(G) and IsWholeFamily(G) 
		# total on free generators
		and Set(FreeGeneratorsOfFpGroup(G))=Set(List(gens,UnderlyingElement))
		then
		  l:=List(gens,UnderlyingElement);
		  p:=List(l,i->Position(FreeGeneratorsOfFpGroup(G),i));
		  # test for duplicate generators, same images
		  if Length(gens)=Length(FreeGeneratorsOfFpGroup(G)) or
			ForAll([1..Length(gens)],x->imgs[x]=imgs[Position(l,l[x])]) then
			filter := filter and IsFromFpGroupStdGensGeneralMappingByImages;
			hom.genpositions:=p;
		  else
			filter := filter and IsFromFpGroupGeneralMappingByImages;
		  fi;
	  else
		filter := filter and IsFromFpGroupGeneralMappingByImages;
	  fi;
    elif IsPermGroup(G) then 
        filter := filter and IsPermGroupGeneralMappingByImages;
    fi;

	if IsPcpGroup(H) then
        hom!.igs_imgs_to_gens := IgsParallel( imgs, gens );
        filter := filter and IsToPcpGHBI;
    elif IsSubgroupFpGroup(H) then 
        filter := filter and IsToFpGroupGeneralMappingByImages;
    elif IsPcGroup(H) then 
        filter := filter and IsToPcGroupGeneralMappingByImages;
    elif IsPermGroup(H) then 
        filter := filter and IsToPermGroupGeneralMappingByImages;
    fi;

   obj_args := [
	 hom,
	 , # Here the type will be inserted
	 Source, G,
	 Range, H,
	 MappingGeneratorsImages, mapi ];

  if HasGeneratorsOfGroup(G) 
     and IsIdenticalObj(GeneratorsOfGroup(G),mapi[1]) then
    Append(obj_args, [PreImagesRange, G]);
    filter := filter and IsTotal and HasPreImagesRange;
  fi;

  if HasGeneratorsOfGroup(H) 
     and IsIdenticalObj(GeneratorsOfGroup(H),mapi[2]) then
    Append(obj_args, [ImagesSource, H]);
    filter := filter and IsSurjective and HasImagesSource;
  fi;

  obj_args[2] := 
    NewType( GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                                    ElementsFamily( FamilyObj( H ) ) ),
             filter );

  CallFuncList(ObjectifyWithAttributes, obj_args);

    return hom;
end );

#############################################################################
##
#M GGMBI( G, H ) . . . . . . . . . . . . . . . . . . . for G and H pcp groups
##
InstallMethod( GroupGeneralMappingByImages,
               "for pcp group, pcp group, list, list",
               true, [IsPcpGroup, IsPcpGroup, IsList, IsList], 0,
               GroupGeneralMappingByImages_for_pcp );

#############################################################################
##
#M GGMBI( G, H ) . . . . . . . . . . . . . . . . . . . . . .  for G pcp group
##
InstallMethod( GroupGeneralMappingByImages,
               "for pcp group, group, list, list",
               true, [IsPcpGroup, IsGroup, IsList, IsList], 0,
               GroupGeneralMappingByImages_for_pcp );

#############################################################################
##
#M GGMBI( G, H ) . . . . . . . . . . . . . . . . . . . . . .  for H pcp group
##
InstallMethod( GroupGeneralMappingByImages,
               "for group, pcp group, list, list",
               true, [IsGroup, IsPcpGroup, IsList, IsList], 0,
               GroupGeneralMappingByImages_for_pcp );


#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
               "for PcpGHBI",
               [ IsFromPcpGHBI], 
function( hom )
	local C, gens, imgs, i, j, a, b, mapi;

	if IsTrivial(Range(hom)) then
		return Range(hom);
	fi;

    gens := hom!.igs_gens_to_imgs[1];
    imgs := hom!.igs_gens_to_imgs[2];

    C := TrivialSubgroup(Range(hom)); # the cokernel

    # check relators 
    for i in [1..Length( gens )] do
        if RelativeOrderPcp( gens[i] ) > 0 then
            a := gens[i]^RelativeOrderPcp( gens[i] );
            a := MappedVector(ExponentsByIgs(gens, a), imgs);
            b := imgs[i]^RelativeOrderPcp( gens[i] );
			C := ClosureSubgroupNC(C, a/b);
        fi;
        for j in [1..i-1] do
            a := gens[i] ^ gens[j];
            a := MappedVector(ExponentsByIgs(gens, a), imgs);
            b := imgs[i] ^ imgs[j];
			C := ClosureSubgroupNC(C, a/b);

            if RelativeOrderPcp( gens[i] ) = 0 then 
                a := gens[i] ^ (gens[j]^-1);
                a := MappedVector(ExponentsByIgs(gens, a), imgs);
                b := imgs[i] ^ (imgs[j]^-1);
				C := ClosureSubgroupNC(C, a/b);
            fi;
        od;
    od;

	# we still need to test any additional generators. This matters
	# for generalized mappings which are not total or not single valued,
	# such as the "inverse" of a non-surjective / non-injective group
	# homomorphism.
	mapi := MappingGeneratorsImages( hom );
	for i in [1..Length(mapi[1])] do
		a := mapi[1][i];
		a := MappedVector(ExponentsByIgs(gens, a), imgs);
		b := mapi[2][i];
		C := ClosureSubgroupNC(C, a/b);
	od;

	C := NormalClosure(ImagesSource(hom),C);
	return C;
end );


# The above code relies on a ImagesSource method for GHBIs
# which avoids ImagesSet etc.; this is the case in GAP 4.5
# but not in 4.4 and earlier, so we add one there.
if not CompareVersionNumbers( GAPInfo.Version, "4.5.0") then
  InstallMethod( ImagesSource, "for GHBI", true,
      [ IsGroupGeneralMappingByImages ], 0,
      hom -> SubgroupNC( Range( hom ), MappingGeneratorsImages(hom)[2] ) );
fi;


## The following two methods for IsTotal and IsSurjective are obsolete;
## indeed, the default methods in GAP do almost the same thing, except
## they use "IsSubset" instead of "=", use SubgroupNC instead of
## Subgroup, and the subgroups are computed via ImagesSource /
## PreImagesRange. (For this to be true in GAP 4.4, we need the new
## ImagesSource method in GAP 4.5 for GHBIs, see above.

# InstallMethod( IsTotal,
#                "for FromPcpGHBI",
#                [IsFromPcpGHBI], 0,
# function(hom) 
#     return Subgroup(Source(hom),MappingGeneratorsImages(hom)[1])
#            = Source(hom);
# end );
# 
# InstallMethod( IsSurjective,
#                "for ToPcpGHBI",
#                [IsToPcpGHBI], 0,
# function(hom) 
#     return Subgroup(Range(hom),MappingGeneratorsImages(hom)[2])
#            = Range(hom);
# end );

#############################################################################
##
#M  Images
##
InstallMethod( ImagesRepresentative,
               "for FromPcpGHBI",
               FamSourceEqFamElm,
               [ IsFromPcpGHBI, IsMultiplicativeElementWithInverse ], 
function( hom, elm )
    local e;
    if Length(hom!.igs_gens_to_imgs[1]) = 0 then return One(Range(hom)); fi;
    e := ExponentsByIgs( hom!.igs_gens_to_imgs[1], elm );
    if e = fail then return fail; fi;
    return MappedVector( e, hom!.igs_gens_to_imgs[2] );
end );

# TODO: Also implement ImagesSet methods, like we have PreImagesSet methods ?
# Any particular reason for / against each?

#############################################################################
##
#M  PreImages
##
InstallMethod( PreImagesRepresentative,
               "for ToPcpGHBI",
               FamRangeEqFamElm,
               [ IsToPcpGHBI, IsMultiplicativeElementWithInverse ], 
function( hom, elm )
    local e;
    if Length(hom!.igs_imgs_to_gens[1]) = 0 then return One(hom!.Source); fi;
    e := ExponentsByIgs(hom!.igs_imgs_to_gens[1], elm);
    if e = fail then return fail; fi;
    return MappedVector(e, hom!.igs_imgs_to_gens[2]);
end );

InstallMethod( PreImagesSet,
               "for PcpGHBI",
               CollFamRangeEqFamElms,
               [ IsFromPcpGHBI and IsToPcpGHBI, IsPcpGroup ],
function( hom, U )
    local prei, kern;
    prei := List( Igs(U), x -> PreImagesRepresentative(hom,x) );
    if fail in prei then
    	TryNextMethod();
		# Potential solution: Intersect U with ImagesSource(hom)
		# and then compute the preimage of that.
		#gens := GeneratorsOfGroup( Intersection( ImagesSource(hom), U ) );
        #prei := List( gens, x -> PreImagesRepresentative(hom,x) );
    fi;
    kern := Igs( KernelOfMultiplicativeGeneralMapping( hom ) );
    return SubgroupByIgs( Source(hom), kern, prei );
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
               "for PcpGHBI",
               [ IsFromPcpGHBI and IsToPcpGHBI], 
function( hom )
    local A, a, B, b, D, u, kern, i, g;
    
    # set up
    A := Source(hom);
    a := MappingGeneratorsImages(hom)[1];
    B := Range(hom);
    b := MappingGeneratorsImages(hom)[2];
    D := DirectProduct(B,A);
    u := Cgs(Subgroup(D, List([1..Length(a)], x ->
          Image(Embedding(D,1),b[x])*Image(Embedding(D,2),a[x]))));

    # filter kernel gens
    kern := [];
    for i in [1..Length(u)] do
        g := Image(Projection(D,1),u[i]);
        if g = One(B) then 
            Add(kern, Image(Projection(D,2),u[i]));
        fi;
    od;

    # create group
    return Subgroup( Source(hom), kern);
end );

# TODO: Add KernelOfMultiplicativeGeneralMapping method for IsToPcpGHBI
# Slower than the one above but more general.

#############################################################################
##
#M  IsInjective( <hom> )
##
InstallMethod( IsInjective,
               "for PcpGHBI",
               [ IsFromPcpGHBI and IsToPcpGHBI], 
function( hom )
    return Size( KernelOfMultiplicativeGeneralMapping(hom) ) = 1;
end );

#############################################################################
##
#M  KnowsHowToDecompose( <G>, <gens> )
##
InstallMethod( KnowsHowToDecompose,
               "pcp group and generators: always true",
               IsIdenticalObj,
               [ IsPcpGroup, IsList ], 0,
               ReturnTrue);
