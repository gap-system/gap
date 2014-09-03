#############################################################################
##
#W  quogphom.gi			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##

#############################################################################
#############################################################################
##
##  Creating hom cosets and quotient groups
##
#############################################################################
#############################################################################

#############################################################################
##
#M  HomCosetFamily( <hom> )
##
InstallMethod(HomCosetFamily,"for homomorphisms",true,[IsGroupHomomorphism],0, 
function(hom)
local fam,filt;

  if IsPermGroup( Range( hom ) ) then 
      filt:=IsHomCosetToPermRep;
  # KEEP THIS COMMENT:  The order of 'elif' is very important,
  # since an additive group may also be a matrix group.
  elif IsAdditiveGroup( Range( hom ) ) then
      filt:=IsHomCosetToAdditiveEltRep;
  elif IsFFEMatrixGroup( Range( hom ) ) then
      filt:=IsHomCosetToMatrixRep;
  elif IsFpGroup( Range( hom ) ) then
      filt:=IsHomCosetToFpRep;
  elif IsDirectProductElementCollection( Range( hom ) ) then
      filt:=IsHomCosetToTupleRep;
  else 
      filt:=IsHomCosetToObjectRep;
  fi;

  if IsPermGroup(Source(hom)) then
    filt:=filt and IsHomCosetOfPerm;
  elif IsFFEMatrixGroup(Source(hom)) then
    filt:=filt and IsHomCosetOfMatrix;
  elif IsFpGroup(Source(hom)) then
    filt:=filt and IsHomCosetOfFp;
  elif IsAdditiveGroup(Source(hom)) then
    filt:=filt and IsHomCosetOfAdditiveElt;
  elif IsDirectProductElementCollection(Source(hom)) then
    filt:=filt and IsHomCosetOfTuple;
  fi;

  fam:=NewFamily("HomCosetFamily",filt);
  fam!.homomorphism:=hom;
  fam!.defaultType:=NewType(fam,filt);
  return fam;

end);

#############################################################################
##
#F  HomCoset( <hom>, <elt> )
##
InstallGlobalFunction( HomCoset, 
    [ IsGroupHomomorphism, IsAssociativeElement ], 
    function( hom, elt )
	local fam, Rec;

	fam:=HomCosetFamily(hom);
	Rec := rec( Homomorphism := hom, SourceElt := elt );
        return Objectify( fam!.defaultType, Rec );
    end );

#############################################################################
##
#F  HomCosetWithImage( <hom>, <srcElt>, <imgElt> )
##
InstallGlobalFunction( HomCosetWithImage, 
    function( hom, srcElt, imgElt )
        local ret;
	ret := HomCoset( hom, srcElt );
	SetImageElt( ret, imgElt );
	return ret;
    end );


#############################################################################
##
#M  QuotientGroupHom( <hom> )
##
InstallMethod( QuotientGroupHom, "for group homomorphisms", true,
    [ IsGroupHomomorphism ], 0,
    function( hom )
        local grp, genimages, gensource;

        if IsCompositionMappingRep(hom) and
           IsBound(hom!.map2) then
            genimages := MappingGeneratorsImages(hom!.map2)[2];
        else genimages := fail;
        fi;
        # gdc - Actually, GAP doesn't define ImagesSource() for comp. maps.
        # But perhaps it should.
        if not HasImagesSource( hom ) and IsAdditiveGroup( Range(hom) )
           and not IsQuotientToAdditiveGroup( Range(hom) ) then
             if genimages <> fail then
                 SetImagesSource( hom, AdditiveGroup( genimages ) );
             else
                 # GAP4r1 Image(hom) needs patch when range is AdditiveGroup()
                 SetImagesSource( hom,
                     AdditiveGroup( List( GeneratorsOfGroup(Source(hom)),
                                    g->ImageElm(hom,g) ) ) );
             fi;

        fi;
        if genimages <> fail then
            gensource := GeneratorsOfGroup( Source( hom ) );
            grp := Group( List( [1..Length(gensource)],
                                function(i)
                                  return HomCosetWithImage
                                               (hom,gensource[i],genimages[i]);
                                end ) );
        else
            grp := Group( List( GeneratorsOfGroup( Source( hom ) ), 
	                        gen -> HomCoset( hom, gen ) ) );
        fi;
        if HasImagesSource( hom ) then
            UseIsomorphismRelation( ImagesSource(hom), grp );
        fi;
        UseFactorRelation( Source( hom ), fail, grp );
        UseSubsetRelationNC( Range( hom ), grp );
        SetQuotientGroup( Source(hom), grp );
        return grp;
    end );

#############################################################################
##
#F  QuotientGroupByHomomorphism( <hom> )
##
InstallGlobalFunction( QuotientGroupByHomomorphism, 
function( hom )
    return QuotientGroupHom( hom );
end );


#############################################################################
##
#F  QuotientGroupByImages( <srcGroup>, <rangeGroup>, <srcGens>, <imgGens> )
##
##  GAP defines GroupHomomorphismByImages as composition of
##  map to word in generators of source group, followed by map
##  taking word to image group and evaluating word there.
##  GAP delays finding strong gen. set and computing first mapping
##  until it's needed.  Our HomCoset does the same.  It should
##  not call upon the homomorphism until it's needed.
##
InstallGlobalFunction( QuotientGroupByImages, 
function( srcGroup, rangeGroup, srcGens, imgGens )
    local quoGroup, i;

    quoGroup := QuotientGroupHom( GroupHomomorphismByImages
                                  ( srcGroup, rangeGroup, srcGens, imgGens ) );
    for i in [1..Length( srcGens )] do
        SetImageElt( quoGroup.(i), imgGens[i] );
    od;
    UseFactorRelation( srcGroup, fail, quoGroup );
    UseSubsetRelationNC( rangeGroup, quoGroup );
    return quoGroup;    
end );

#############################################################################
##
#F  QuotientGroupByImagesNC( <srcGroup>, <rangeGroup>, <srcGens>, <imgGens> )
##
InstallGlobalFunction( QuotientGroupByImagesNC, 
function( srcGroup, rangeGroup, srcGens, imgGens )
    local quoGroup, i;

    quoGroup := QuotientGroupHom( GroupHomomorphismByImagesNC
                                  ( srcGroup, rangeGroup, srcGens, imgGens ) );
    for i in [1..Length( srcGens )] do
        SetImageElt( quoGroup.(i), imgGens[i] );
    od;
    UseFactorRelation( srcGroup, fail, quoGroup );
    UseSubsetRelationNC( rangeGroup, quoGroup );
    return quoGroup;    
end );


#############################################################################
##
#F  QuotientSubgroupNC( <M>, <gens> )
##
##  gdc - Consider setting new homomorphism for grp with Source() as grp.
##        However, in current representation, this would mean that an
##        element of the subgroup and an element of the group cannot
##        be multiplied together.  How does GAP handle these issues?
#InstallGlobalFunction( QuotientSubgroupNC,
#function( M, gens )
#    local grp;
#    grp := SubgroupNC( M, gens );
#    SetIsAssociative( grp, true );
#    return grp;
#end );


#############################################################################
#############################################################################
##
##  Basic access functions
##
#############################################################################
#############################################################################

#############################################################################
##
#F  IsTrivialHomCoset( <hcoset> )
##
InstallGlobalFunction( IsTrivialHomCoset,
    function( hcoset )
        if IsHomCoset( hcoset ) then
            return IsOne( hcoset ) and IsTrivialHomCoset( SourceElt(hcoset) );
        else 
	    return IsOne( hcoset );
        fi;
    end );

#############################################################################
##
#M  Homomorphism( <hcoset> ) for hom cosets
##
InstallMethod( Homomorphism, "for hom cosets", true,
    [ IsHomCoset ], 0, hcoset -> hcoset!.Homomorphism );

#############################################################################
##
#M  Homomorphism( <Q> ) for quotient groups
##
InstallMethod( Homomorphism, "for quotient groups", true,
    [ IsHomQuotientGroup ], 0, Q -> Homomorphism( Q.1 ) );

#############################################################################
##
#M  Source( <Q> ) for quotient groups
##
InstallMethod( Source, "for quotient groups", true,
    [ IsHomQuotientGroup ], 0, Q -> Source( Homomorphism( One( Q ) ) ) );

#############################################################################
##
#M  Range( <Q> ) for quotient groups
##
InstallMethod( Range, "for quotient groups", true,
    [ IsHomQuotientGroup ], 0, Q -> Range( Homomorphism( One( Q ) ) ) );

#############################################################################
##
#M  ImagesSource( <Q> ) for quotient groups
##
##  NOTE:  Image(quotientGroup) will call ImagesSource(quotientGroup)
##
InstallMethod( ImagesSource, "for quotient groups", true,
    [ IsHomQuotientGroup ], 0, Q -> Image( Homomorphism( One( Q ) ) ) );

InstallOtherMethod( ONE, "for quotient groups", true,
    [ IsHomQuotientGroup ], 2*SUM_FLAGS, Q -> ONE( Q.1 ) );
#T good idea/necessary?

#############################################################################
##
#M  SourceElt( <Q> ) for hom cosets
##
InstallMethod( SourceElt, "for hom cosets", true,
    [ IsHomCoset ], 0, hcoset -> hcoset!.SourceElt );

#############################################################################
##
#M  ImageElt( <Q> ) for hom cosets
##
##  ImageElt is attribute of hcoset -- It will be cached.
##
InstallMethod( ImageElt, "for hom cosets", true,
    [ IsHomCoset ], 0, function(hcoset)
    local img;
    img := ImageElm( Homomorphism( hcoset ), SourceElt( hcoset ) );
    if img = fail then Error("hom coset with invalid image"); fi;
    return img;
end );



#############################################################################
#############################################################################
##
##  Basic operations
##
#############################################################################
#############################################################################

StringImType := function( hcoset ) 
    if IsHomCosetToPerm( hcoset ) then
        return "perm";
    elif IsHomCosetToMatrix( hcoset ) then
	return "matrix";
    elif IsHomCosetToFp( hcoset ) then
	return "word";
    elif IsHomCosetToTuple( hcoset ) then
	return "tuple";
    else
	return "element";
    fi;
end;

#############################################################################
##
#M  ViewObj( <hcoset> ) for hom cosets
##
InstallMethod( ViewObj, "for hom coset", true,
    [ IsHomCoset ], 0,
    function( hcoset )
        Print("( "); 
	if HasImageElt( hcoset ) then
	    View( ImageElt( hcoset ) );
	else
	    View( StringImType( hcoset ) );
	    # place holder if image not known
	fi;
	Print(" <- ");
	ViewObj( SourceElt( hcoset ) ); Print(" )");
    end );

#############################################################################
##
#M  PrintObj( <hcoset> ) for hom cosets
##
InstallMethod( PrintObj, "for hom coset", true,
    [ IsHomCoset ], 0,
    function( hcoset )
        Print("( "); 
	if HasImageElt( hcoset ) then
	    PrintObj( ImageElt( hcoset ) );
	else
	    Print( StringImType( hcoset ) );
	fi;
	Print(" <- ");
	PrintObj( SourceElt( hcoset ) ); Print(" )");
    end );

#############################################################################
##
#M  EQ( <hcoset1>, <hcoset2> ) for hom cosets
##
InstallMethod( EQ, "for hom cosets", IsIdenticalObj,
    [ IsHomCoset, IsHomCoset ], 0,
    function( hcoset1, hcoset2 )
        return  EQ( ImageElt(hcoset1), ImageElt(hcoset2) );
    end );

# I think this is a bad idea. Scott
#############################################################################
##
#M  EQ( <hcoset>, <mat> ) for hom coset matrix rep or add. rep. and identity
##
InstallMethod( EQ, "for hom coset matrix rep or add. rep. and identity", true,
    [ IsHomCosetToMatrix, IsMatrix and IsOne ], 0,
    function( hcoset, mat )
        return IsOne(SourceElt(hcoset));
    end );
#############################################################################
##
#M  EQ( <mat>, <hcoset> ) for identity and hom coset matrix rep or add. rep.
##
InstallMethod( EQ, "for hom coset matrix rep or add. rep. and identity", true,
    [ IsMatrix and IsOne, IsHomCosetToMatrix ], 0,
    function( mat, hcoset )
        return IsOne(SourceElt(hcoset));
    end );


#############################################################################
##
#M  LT( <hcoset1>, <hcoset2> ) for hom cosets
##
InstallMethod( LT, "for hom cosets",IsIdenticalObj,
    [ IsHomCoset, IsHomCoset ], 0,
    function( hcoset1, hcoset2 )
    	return LT( ImageElt(hcoset1), ImageElt(hcoset2) );
    end );

#############################################################################
##
#M  ONE( <hcoset> ) for hom cosets
##
InstallMethod( ONE, "for hom coset", true,
    [ IsHomCoset ], 0,
    function( hcoset )
	local one;
        one := HomCoset( Homomorphism( hcoset ), ONE( SourceElt(hcoset) ) );
	SetImageElt( one, ONE( Range( Homomorphism( hcoset ) ) ) );
	return one;
    end );

#############################################################################
##
#M  One( <hcoset> ) for hom cosets
##
InstallMethod( One, "for hom coset", true,
    [ IsHomCoset ], 0,
    function( hcoset )
	local one;
        one := HomCoset( Homomorphism( hcoset ), One( SourceElt(hcoset) ) );
	SetImageElt( one, One( Range( Homomorphism( hcoset ) ) ) );
	return one;
    end );
#############################################################################
##
#M  ONE( <hcoset> ) for hom coset in additive rep
##
InstallMethod( ONE, "for hom coset in additive rep", true,
    [ IsHomCosetToAdditiveElt ], 2*SUM_FLAGS,
    function( hcoset )
     return HomCosetWithImage( Homomorphism(hcoset),
                               One( SourceElt(hcoset) ), Zero( ImageElt(hcoset) ) );
    end );
#############################################################################
##
#M  One( <hcoset> ) for hom coset in additive rep
##
InstallMethod( One, "for hom coset in additive rep", true,
    [ IsHomCosetToAdditiveElt ], 2*SUM_FLAGS,
    function( hcoset )
     return HomCosetWithImage( Homomorphism(hcoset),
                               One( SourceElt(hcoset) ), Zero( ImageElt(hcoset) ) );
    end );

#############################################################################
##
#M  PROD( <zero>, <hcoset> ) for zero * additive hom coset rep
##
InstallMethod( PROD, "for zero * additive hom coset rep", true,
    [ IsZeroCyc, IsHomCosetToAdditiveElt ], SUM_FLAGS,
    function( zero, hcoset ) return ZERO(hcoset); end );

#############################################################################
##
#M  PROD( <hcoset>, <zero> ) for additive hom coset rep * zero
##
InstallMethod( PROD, "for additive hom coset rep * zero", true,
    [ IsHomCosetToAdditiveElt, IsZeroCyc ], SUM_FLAGS,
    function( hcoset, zero ) return ZERO(hcoset); end );

#############################################################################
##
#M  ZERO( <hcoset> ) for additive hom coset
##
InstallMethod( ZeroSameMutability, "for additive hom coset", true,
    [ IsOrdinaryMatrix and IsHomCosetToAdditiveElt ], 0, hcoset -> ONE(hcoset) );

#############################################################################
##
#M  ZeroOp( <hcoset> ) for additive hom coset
##
InstallMethod( ZeroMutable, "for additive hom coset", true,
    [ IsObject and IsAdditiveElement and IsOrdinaryMatrix and IsHomCosetToAdditiveElt ], 0, 
    hcoset -> One(hcoset) );


##
##  Install default method and identical specialized methods that will
##    will have a higher score to beat out GAP's methods.
##
PROD_HOM_COSET :=
function( hcoset1, hcoset2 )
    local ret;
    ret := HomCoset( Homomorphism( hcoset1 ), 
	    SourceElt(hcoset1) * SourceElt(hcoset2) );
    if HasImageElt( hcoset1 ) and HasImageElt( hcoset2 ) then
        if IsHomCosetToAdditiveElt( hcoset1 ) then
            SetImageElt( ret, ImageElt( hcoset1 ) + ImageElt( hcoset2 ) );
        else SetImageElt( ret, ImageElt( hcoset1 ) * ImageElt( hcoset2 ) );
        fi;
    fi;
    return ret;
end;

#############################################################################
##
#M  PROD( <hcoset1>, <hcoset2> ) for hom cosets
##
InstallMethod( PROD, "for hom cosets", IsIdenticalObj,
    [ IsHomCoset, IsHomCoset ], 0, PROD_HOM_COSET );

# the following methods are needed because hom cosets are *also*
# permutations and we don't want to fall in the permutation multiplicationb
# routine. Alternatively the method above could be ranked higher.
#############################################################################
##
#M  PROD( <hcoset1>, <hcoset2> ) for hom cosets to matrix groups
##
InstallMethod( PROD, "for hom cosets to matrix groups", IsIdenticalObj,
    [ IsHomCosetToMatrix, IsHomCosetToMatrix ], 0, PROD_HOM_COSET );
#############################################################################
##
#M  PROD( <hcoset1>, <hcoset2> ) for hom cosets to permutation group
##
InstallMethod( PROD, "for hom cosets to permutation groups", IsIdenticalObj,
    [ IsHomCosetToPerm, IsHomCosetToPerm ], 0, PROD_HOM_COSET );

#############################################################################
##
#M  PROD( <hcoset1>, <hcoset2> ) for hom cosets to additive groups
##
InstallMethod( PROD, "for hom cosets to additive groups", IsIdenticalObj,
    [ IsHomCosetToAdditiveElt, IsHomCosetToAdditiveElt ], 0, PROD_HOM_COSET );

#############################################################################
##
#M  PROD( <v>, <hcoset> ) for vector and hom coset
##
InstallMethod( PROD, "for vector and hom coset", true,
    [ IsRowVector and IsRingElementList, IsHomCoset ], 0,
    function( v, hcoset ) return v * ImageElt(hcoset); end );

#############################################################################
##
#M  PROD( <hcoset>, <v> ) for hom coset and vector 
##
InstallMethod( PROD, "for hom coset and vector", true,
    [ IsHomCoset, IsVector and IsRingElementList ], 0,
    function( hcoset, v ) return ImageElt(hcoset) * v; end );
##  gdc - Should we protect against 3*hcoset, Z(3)*hcoset, hcoset*3, etc.
##        by signalling an error?
##     3*hcoset is well-defined for IsHomCosetToAddRep, but not for some others.


##
##  We identify \+ and \* if it's an additive group.
##

#############################################################################
##
#M  SUM( <hcoset1>, <hcoset2> ) for hom cosets to additive groups
##
InstallMethod( SUM, "for hom cosets to additive groups", IsIdenticalObj,
    # specialization needed to beat SUM of IsHomCosetOfMatrix 
    [ IsMatrix and IsHomCosetOfMatrix and IsHomCosetToAdditiveElt,
      IsMatrix and IsHomCosetOfMatrix and IsHomCosetToAdditiveElt ],
    0, PROD_HOM_COSET );

#############################################################################
##
#M  SUM( <hcoset1>, <hcoset2> ) for hom cosets to additive groups
##
InstallMethod( SUM, "for hom cosets to additive groups", IsIdenticalObj,
    [ IsHomCosetToAdditiveElt, IsHomCosetToAdditiveElt ], 0, PROD_HOM_COSET );

#############################################################################
##
#M  DIFF( <hcoset1>, <hcoset2> ) for hom cosets to additive groups
##
InstallMethod( DIFF, "for hom cosets to additive groups", IsIdenticalObj,
    # specialization needed to beat DIFF of IsHomCosetOfMatrix 
    [ IsHomCosetOfMatrix and IsHomCosetToAdditiveElt,
      IsHomCosetOfMatrix and IsHomCosetToAdditiveElt ], 0,
    function(hcoset1, hcoset2)
        return hcoset1 + (- hcoset2); #Note \+ and \* are same in this context
    end );

#############################################################################
##
#M  DIFF( <hcoset1>, <hcoset2> ) for hom cosets to additive groups
##
InstallMethod( DIFF, "for hom cosets to additive groups", IsIdenticalObj,
    [ IsHomCosetToAdditiveElt, IsHomCosetToAdditiveElt ], 0,
    function(hcoset1, hcoset2)
        return hcoset1 + (- hcoset2); #Note \+ and \* are same in this context
    end );

#############################################################################
##
#M  AdditiveInverseOp( <hcoset> ) unary minus for hom coset in additive rep 
##
InstallMethod( AdditiveInverseOp, "unary minus for hom coset in additive rep", true,
    [ IsHomCosetToAdditiveElt ], 0,
    hcoset -> HomCosetWithImage( Homomorphism( hcoset ),
                             INV(SourceElt(hcoset)), AINV(ImageElt(hcoset)) ) );

#############################################################################
##
#M  AINV( <hcoset> ) unary minus for hom coset in additive rep 
##
InstallMethod( AdditiveInverseOp, "unary minus for hom coset in additive rep", true,
    [ IsHomCosetToAdditiveElt ], 0,
    hcoset -> HomCosetWithImage( Homomorphism( hcoset ),
                             INV(SourceElt(hcoset)), AINV(ImageElt(hcoset)) ) );

#############################################################################
##
#M  INV( <hcoset> ) unary minus for hom coset in additive rep
##
InstallMethod( INV, "unary minus for hom coset in additive rep", true,
    [ IsHomCosetToAdditiveElt ], 0,
    hcoset -> HomCosetWithImage( Homomorphism( hcoset ),
                             INV(SourceElt(hcoset)), AINV(ImageElt(hcoset)) ) );
#############################################################################
##
#M  Inverse( <hcoset> ) unary minus for hom coset in additive rep
##
InstallMethod( Inverse, "for unary hom coset in additive rep", true,
    [ IsHomCosetToAdditiveElt ], 0,
    hcoset -> HomCosetWithImage( Homomorphism( hcoset ),
                             Inverse(SourceElt(hcoset)), AINV(ImageElt(hcoset)) ) );


#############################################################################
##
#M  QUO( <hcoset1>, <hcoset2> ) for hom cosets
##
InstallMethod( QUO, "for hom cosets", IsIdenticalObj,
    [ IsHomCoset, IsHomCoset ], 0,
    function( hcoset1, hcoset2 )
	local ret;
	ret := HomCoset( Homomorphism( hcoset1 ), 
		SourceElt(hcoset1) / SourceElt(hcoset2) );
	if HasImageElt( hcoset1 ) and HasImageElt( hcoset2 ) then
            if IsHomCosetToAdditiveElt( hcoset1 ) then
                SetImageElt( ret, ImageElt( hcoset1 ) - ImageElt( hcoset2 ) );
            else SetImageElt( ret, ImageElt( hcoset1 ) / ImageElt( hcoset2 ) );
            fi;
	fi;
        return ret;
    end );


##
##  Install default method and identical specialized methods that will
##    will have a higher score to beat out GAP's methods.
##
INV_HOM_COSET :=
    function( hcoset )
	local ret;
        ret := HomCoset( Homomorphism( hcoset ), INV( SourceElt(hcoset) ) );
	if HasImageElt( hcoset ) then
            if IsHomCosetToAdditiveElt( hcoset ) then
                SetImageElt( ret, AINV( ImageElt( hcoset ) ) );
	    else SetImageElt( ret, INV( ImageElt( hcoset ) ) );
            fi;
	fi;
	return ret;
    end;

#############################################################################
##
#M  INV( <hcoset> ) unary minus for hom coset
##
InstallMethod( INV, "unary minus for hom coset", true,
    [ IsHomCoset ], 0, INV_HOM_COSET );

#############################################################################
##
#M  INV( <hcoset> ) for hom cosets to matrix groups
##
InstallMethod( INV, "for hom cosets to matrix groups", true,
    [ IsHomCosetToMatrix ], 0, INV_HOM_COSET );

#############################################################################
##
#M  INV( <hcoset> ) for hom cosets to permutation groups
##
InstallMethod( INV, "for hom cosets to permutation groups", true,
    [ IsHomCosetToPerm ], 0, INV_HOM_COSET );

#############################################################################
##
#M  INV( <hcoset> ) for hom cosets to additive groups
##
InstallMethod( INV, "for hom cosets to additive groups", true,
    [ IsHomCosetToAdditiveElt ], 0, INV_HOM_COSET );

#############################################################################
##
#M  Inverse( <hcoset> ) for hom coset
##
InstallMethod( Inverse, "for hom coset", true,
    [ IsHomCoset ], 0,
    function( hcoset )
        return INV( hcoset );
    end );

#############################################################################
##
#M  POW( <hcoset1>, <hcoset2> ) for hom cosets
##
InstallMethod( POW, "for hom cosets", IsIdenticalObj,
    [ IsHomCoset, IsHomCoset ], 
    # the higher rank is to override a default method for permutations etc.
    1,
    function( hcoset1, hcoset2 )
        local ret;
	if Homomorphism( hcoset1 ) <> Homomorphism( hcoset2 ) then
	    Error( "cosets in different quotient groups" );
	fi;
	ret := HomCoset( Homomorphism( hcoset1 ), 
		SourceElt(hcoset1) ^ SourceElt(hcoset2) );
	if HasImageElt( hcoset1 ) and HasImageElt( hcoset2 ) then
            if IsHomCosetToAdditiveElt( hcoset1 ) then
                SetImageElt( ret, ImageElt( hcoset1 ) * ImageElt( hcoset2 ) );
	    else SetImageElt( ret, ImageElt( hcoset1 ) ^ ImageElt( hcoset2 ) );
            fi;
	fi;
        return ret;
    end );

#############################################################################
##
#M  POW( <hcoset>, <int> ) for hom cosets to integer power
##
InstallMethod( POW, "for hom cosets to integer power", true,
    [ IsHomCoset, IsInt ], 
    # the higher rank is to override a default method for permutations etc.
    1,
    function( hcoset, int )
        local ret;
	ret := HomCoset( Homomorphism( hcoset ), SourceElt(hcoset) ^ int );
	if HasImageElt( hcoset ) then
            if IsHomCosetToAdditiveElt( hcoset ) then
                SetImageElt( ret, int * ImageElt( hcoset ) );
	    else SetImageElt( ret, ImageElt( hcoset ) ^ int );
            fi;
	fi;
        return ret;
    end );

#############################################################################
##
#M  COMM( <hcoset1>, <hcoset2> ) for hom cosets
##
InstallMethod( COMM, "for hom cosets", IsIdenticalObj,
    [ IsHomCoset, IsHomCoset ], 0,
    function( hcoset1, hcoset2 )
        local ret;
	ret := HomCoset( Homomorphism( hcoset1 ), 
		COMM( SourceElt(hcoset1), SourceElt(hcoset2) ) );
	if HasImageElt( hcoset1 ) and HasImageElt( hcoset2 ) then
            if IsHomCosetToAdditiveElt( hcoset1 ) then
                SetImageElt( ret, ZERO( ImageElt( hcoset1 ) ) );
	    else SetImageElt( ret, COMM( ImageElt( hcoset1 ),
                                         ImageElt( hcoset2 ) ) );
            fi;
	fi;
        return ret;
    end );

#############################################################################
##
#M  Order( <hcoset> ) for hom coset
##
InstallMethod( Order, "for hom coset", true,
    [ IsHomCoset ], NICE_FLAGS,
    function( hcoset )
        return Order( ImageElt(hcoset) );
    end );

#############################################################################
##
#M  Order( <hcoset> ) for hom coset in additive rep
##
InstallMethod( Order, "for hom coset in additive rep", true,
    [ IsHomCosetToAdditiveElt ], NICE_FLAGS,
    function( hcoset )
        if IsZero(ImageElt(hcoset)) then return 1;
        #BUG: This won't work if image is hom coset add rep over Z(9), e.g.
        #GAP needs better support for additive matrix groups.
        # In this case, GAP should store field size in additive group,
        #   just as GAP does for IsFFEMatrixGroup.
        elif IsMatrix(ImageElt(hcoset)) then
          hcoset:= DefaultFieldOfMatrix( ImageElt( hcoset ) );
          if hcoset = fail then
            TryNextMethod();
          else
            return Size( hcoset );
          fi;
        else TryNextMethod();
        fi;
    end );

#############################################################################
##
#M  CanonicalElt( <hcoset> )
##
InstallMethod( CanonicalElt, "for hom cosets", true,
    [ IsRightCoset and IsHomCoset ], 0,
    function( hcoset )
        local quoGroup;
	Info( InfoQuotientGroup, 2, "Stripping to find canonical element" );
	quoGroup := QuotientGroupHom( Homomorphism( hcoset ) );
	ChainSubgroup( quoGroup );  # compute a chain if necessary
	return  SourceElt( Sift( quoGroup, hcoset ) )^(-1) *
		SourceElt( hcoset );

    end );


#############################################################################
#############################################################################
##
##  Functions for specific types of image
##
#############################################################################
#############################################################################

#############################################################################
##
#M  POW( <int>, <hcoset> ) for integer and perm hom coset
##
InstallMethod( POW, "for integer and perm hom coset", true,
    [ IsInt, IsHomCosetToPerm ], 0,
    function( int, hcoset )
        return POW( int, ImageElt(hcoset) );
    end );

#############################################################################
##
#M  QUO( <int>, <hcoset> ) for integer and perm hom coset
##
InstallMethod( QUO, "for integer and perm hom coset", true,
    [ IsInt, IsHomCosetToPerm ], 0,
    function( int, hcoset )
        return QUO( int, ImageElt(hcoset) );
    end );

##  gdc - IsVector( matrix ) => true;  But IsRingElementList(matrix) => false
#############################################################################
##
#M  POW( <vec>, <hcoset> ) for vector and matrix hom coset
##
InstallMethod( POW, "for vector and matrix hom coset", true,
    [ IsVector and IsRingElementList,
      IsMatrix and IsHomCosetToMatrix and IsRingElementTable ], 0,
    function( vec, hcoset )
        return POW( vec, ImageElt(hcoset) );
    end );

#############################################################################
##
#M  SUM( <hcoset1>, <hcoset2> ) for two matrix hom cosets
##
InstallMethod( SUM, "for two matrix hom cosets", true,
    [ IsMatrix and IsHomCosetToMatrix and IsHomCosetOfMatrix,
      IsMatrix and IsHomCosetToMatrix and IsHomCosetOfMatrix ], 0,
    function( hcoset1, hcoset2 )
        local ret;
        if Homomorphism( hcoset1 ) <> Homomorphism( hcoset2 ) then
            Error( "cosets in different quotient groups" );
        fi;
        ret := HomCoset( Homomorphism( hcoset1 ),
                SourceElt(hcoset1) + SourceElt(hcoset2) );
        if HasImageElt( hcoset1 ) and HasImageElt( hcoset2 ) then
            SetImageElt( ret, ImageElt( hcoset1 ) + ImageElt( hcoset2 ) );
        fi;
        return ret;
    end );

#############################################################################
##
#M  DIFF( <hcoset1>, <hcoset2> ) for two matrix hom cosets
##
InstallMethod( DIFF, "for two matrix hom cosets", true,
    [ IsHomCosetToMatrix and IsHomCosetOfMatrix,
      IsHomCosetToMatrix and IsHomCosetOfMatrix ], 0,
    function( hcoset1, hcoset2 )
        local ret;
        if Homomorphism( hcoset1 ) <> Homomorphism( hcoset2 ) then
            Error( "cosets in different quotient groups" );
        fi;
        ret := HomCoset( Homomorphism( hcoset1 ),
                SourceElt(hcoset1) - SourceElt(hcoset2) );
        if HasImageElt( hcoset1 ) and HasImageElt( hcoset2 ) then
            SetImageElt( ret, ImageElt( hcoset1 ) - ImageElt( hcoset2 ) );
        fi;
        return ret;
    end );

#############################################################################
##
#M  SmallestMovedPointPerm( <hcoset> ) for hom coset to permutation
##
InstallMethod( SmallestMovedPointPerm, "for hom coset to permutation", true,
    [ IsPerm and IsHomCosetToPerm ], 0,
    function( hcoset )
        return SmallestMovedPointPerm( ImageElt(hcoset) );
    end );

#############################################################################
##
#M  LargestMovedPointPerm( <hcoset> ) for hom coset to permutation
##
InstallMethod( LargestMovedPointPerm, "for hom coset to permutation", true,
    [ IsPerm and IsHomCosetToPerm ], 0,
    function( hcoset )
        return LargestMovedPointPerm( ImageElt(hcoset) );
    end );

#############################################################################
##
#M  ELM_LIST( <hcoset>, <i> ) for hom coset to matrix
##
InstallMethod( ELM_LIST, "for hom coset to matrix", true,
    [ IsMatrix and IsHomCosetToMatrix, IsInt ], 0,
    function( hcoset, i )
	return ELM_LIST( ImageElt( hcoset ), i );
    end );

#############################################################################
##
#M  Length( <hcoset> ) for hom coset to matri
##
InstallMethod( Length, "for hom coset to matrix", true,
    [ IsMatrix and IsHomCosetToMatrix ], 0,
    function( hcoset )
	return Length( ImageElt( hcoset ) );
    end );

#############################################################################
##
##  Length( <hcoset> ) for hom coset to fp 
##
##InstallMethod( Length, "for hom coset to fp", true,
##   [ IsWord and IsHomCosetToFp ], 0,
##    function( hcoset )
##	return Length( ImageElt( hcoset ) );
##   end );

#############################################################################
##
#M  Length( <hcoset> ) for hom coset to tuple
##
InstallMethod( Length, "for hom coset to tuple", true,
    [ IsDirectProductElement and IsHomCosetToTuple ], 0,
    function( hcoset )
	return Length( ImageElt( hcoset ) );
    end );

#############################################################################
##
#M  DefaultFieldOfMatrix( <hcoset> ) for hom coset to matrix
##
InstallMethod( DefaultFieldOfMatrix, "for hom coset", true,
    [ IsMatrix and IsHomCoset ], 0,
    hcoset -> DefaultFieldOfMatrix( ImageElt( hcoset ) ) );


# SourceElt() will not be valid, but ImageElt() will be correct.
GroupFromAdditiveGroup := function( addGrp )
    local hom;
    hom := GroupHomomorphismByFunction( addGrp, addGrp, x->x );
    return Group( List( GeneratorsOfAdditiveGroup(addGrp),
                         g -> HomCoset( hom, g ) ) );
end;


#############################################################################
##
#M  ImagesSet( <quoGroup> ) to overcome bad family relation in default
##     (When quotient groups inherit families, this will be cleaner.)
##
InstallMethod( ImagesSet,
    "for general mapping, and quotient group with bad family relation",
    true,
    [ IsGeneralMapping, IsHomQuotientGroup ], -8,
    function( map, grp )
        return ImagesSet( map, Image(Homomorphism(grp)) );
    end );
    
    
    InstallMethod( PreOrbishProcessing, [IsHomQuotientGroup], 
            function(G)
        local g,h;
        g := G;
        while IsHomQuotientGroup(g) do
            h := Homomorphism(One(g));
            g := Group(List(GeneratorsOfGroup(g), x->Image(h, SourceElt(x))));
        od;
        return g;
    end);
#E

