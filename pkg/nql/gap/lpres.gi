############################################################################
##
#W  lpres.gi			The NQL-package			René Hartung
##
#H   @(#)$Id: lpres.gi,v 1.9 2010/03/17 13:03:41 gap Exp $
##
## Based on Alexander Hulpke's and Volkmar Felsch's construction of
## finitely presented groups ("GAPDIR/lib/grpfp.gi").
##
Revision.("nql/gap/lpres_gi"):=
  "@(#)$Id: lpres.gi,v 1.9 2010/03/17 13:03:41 gap Exp $";


############################################################################
##
#M  ElementOfLpGroup
##
InstallMethod( ElementOfLpGroup,
   "for a family of L-presented group elements, and an assoc. word", true,
   [ IsElementOfLpGroupFamily, IsAssocWordWithInverse ],
   function( fam, elm )
     return Objectify(fam!.defaultType, [Immutable(elm)]);
   end);

############################################################################
##
#M  PrintObj( <elm> ) 
## 
InstallMethod( PrintObj,
  "for an element of an L-presented group", true,
  [IsElementOfLpGroup and IsPackedElementDefaultRep], 0,
  function(obj)
    Print(obj![1]);
  end);

############################################################################
##
#M  ViewObj( <elm> ) 
## 
InstallMethod( ViewObj,
  "for an element of an L-presented group", true,
  [IsElementOfLpGroup and IsPackedElementDefaultRep], 0,
  function(obj)
    View(obj![1]);
  end);

############################################################################
##
#M  String( <elm> ) 
## 
InstallMethod( String,
  "for an element of an L-presented group", true,
  [IsElementOfLpGroup and IsPackedElementDefaultRep], 0,
  obj-> String(obj![1]));

############################################################################
##
#M  LaTeXObj( <elm> ) 
## 
InstallMethod( LaTeXObj,
  "for an element of an L-presented group", true,
  [IsElementOfLpGroup and IsPackedElementDefaultRep], 0,
  obj->LaTeXObj(obj![1]));

############################################################################
##
#M  UnderlyingElement( <elm> ) 
## 
InstallMethod( UnderlyingElement,
  "for an element of an L-presented group", true,
  [IsElementOfLpGroup and IsPackedElementDefaultRep], 0,
   obj -> obj![1]);

############################################################################
##
#M  ExtRepOfObj( <elm> )
## 
InstallMethod( ExtRepOfObj,
  "for an element of an L-presented group", true,
  [IsElementOfLpGroup and IsPackedElementDefaultRep], 0,
  obj -> ExtRepOfObj(obj![1]));

############################################################################
##
#M  Length ( <elm> )
##
InstallOtherMethod( Length, 
  "for an element of an L-presented group", true,
  [ IsElementOfLpGroup and IsPackedElementDefaultRep ], 0,
  x->Length(UnderlyingElement(x)));

############################################################################
##
#M  InverseOp ( <elm> ) 
## 
InstallMethod( InverseOp,
  "for an element of an L-presented group", true,
  [IsElementOfLpGroup], 0,
  obj->ElementOfLpGroup(FamilyObj(obj),Inverse(UnderlyingElement(obj))));

############################################################################
##
#M  One( <fam> )
##
InstallOtherMethod( One,
  "for a family of L-presented group elements", true,
  [IsElementOfLpGroupFamily],0,
  fam->ElementOfLpGroup(fam,One(fam!.freeGroup)));

############################################################################
##
#M  One( <elm> )
##
InstallMethod( One, 
  "for an L-presented group element", true,
  [IsElementOfLpGroup], 0, 
  obj->One(FamilyObj(obj)));

#a^0 calls OneOp
InstallMethod( OneOp, 
  "for an L-presented group element", true,
  [IsElementOfLpGroup],0,
  obj -> One(FamilyObj(obj)));

#############################################################################
##
#M  \*( <elm1>, <elm2> )  . . . . . for two elements of an L-presented group 
##
InstallMethod( \*, 
   "for two L-presented group elements", IsIdenticalObj, 
    [ IsElementOfLpGroup, IsElementOfLpGroup ], 0,
    function( left, right )
    local fam,k;

    fam:= FamilyObj( left );
    return ElementOfLpGroup( fam,
           UnderlyingElement( left ) * UnderlyingElement( right ) );
    end);

############################################################################
##
#M  MappedWord ( word, gens, imgs )
## 
## replaces each occurence of a generators from <gens> in <word> by its 
## image in <imgs>.
##
InstallOtherMethod( MappedWord,
   "for LpGroup elements", true,
   [ IsElementOfLpGroup, IsList, IsList ], 0,
   function(x,gens1,gens2)
   if not IsElementOfLpGroupCollection(gens1) then
     return(fail);
   else
     return(MappedWord(UnderlyingElement(x),
                       List(gens1,UnderlyingElement),gens2));
   fi;
   end);

############################################################################
##
#M  GeneratorsOfGroup( <F> )  . . . . . . . . . . . for an L-presented group
##
InstallMethod( GeneratorsOfGroup, 
   "for whole family of L-presented groups", true,
   [ IsLpGroup and IsGroupOfFamily ], 0,
   function( F )
   local Fam;	
   Fam:= ElementsFamily( FamilyObj( F ) );
   return List( FreeGeneratorsOfLpGroup( F ), g -> ElementOfLpGroup( Fam, g ) );
   end );

############################################################################
##
#M  Display( <G> ) . . . . . . . . . . . . . . . . . . .  display an LpGroup
##
InstallMethod( Display,
   "for L-presented groups", true,
   [ IsLpGroup and IsGroupOfFamily ], 0,
   function( G )
   local   gens,       # generators o the free group
           rels,       # relators of <G>
           endos,      # endomorphisms of <G>
           itrels,     # iterated relators of <G>
           n,          # number of relators, endomorphisms and it. relators
           i;          # loop variable

   # generators of the L-presentation
   gens := FreeGeneratorsOfLpGroup( G );
   Print( "generators = ", gens, "\n" );

   # fixed relators of the L-presentation
   rels := FixedRelatorsOfLpGroup( G );
   n := Length( rels );
   Print( "fixed relators = [" );
   if n > 0 then
     Print( "\n ", rels[1] );
     for i in [ 2 .. n ] do
       Print( ",\n ", rels[i] );
     od;
   fi;
   Print( " ]\n" );

   # the endomorphisms of the L-presentation
   endos:=EndomorphismsOfLpGroup(G);
   Print( "endomorphism = [" );
   n:=Length(endos);
   if n > 0 then 
     Print( "\n" );
     ViewObj(endos[1]);
     for i in [2..n] do 
       Print( ",\n" );
       ViewObj(endos[i]);
     od;
   fi;
   Print( " ]\n" );
 
   # iterated relators of the L-presentation
   itrels:=IteratedRelatorsOfLpGroup(G);
   Print( "iterated relators = [" );
   n:=Length(itrels);
   if n > 0 then
     Print( "\n", itrels[1] );
     for i in [2..n] do
       Print( ",\n", itrels[i]);
     od;
   fi;
   Print( " ]\n" );
   end );

############################################################################
##
#M  FreeGeneratorsOfLpGroup ( G )
##
InstallMethod( FreeGeneratorsOfLpGroup,
   "for an L-presented group", true,
   [ IsLpGroup and IsGroupOfFamily ], 0,
   G -> GeneratorsOfGroup( FreeGroupOfLpGroup (G)));

############################################################################
##
#M  FreeGeneratorsOfWholeGroup
##
InstallMethod( FreeGeneratorsOfWholeGroup, 
  "for a subgroup of an L-presented group", true,
  [ IsSubgroupLpGroup ], 0, 
  G -> GeneratorsOfGroup( ElementsFamily( FamilyObj( G ) )!.freeGroup ) );

############################################################################
##
#M  FreeGroupOfLpGroup( F ) . . underlying free group of an L-presented group
##
InstallMethod( FreeGroupOfLpGroup, 
   "for an L-presented group", true,
   [ IsLpGroup and IsGroupOfFamily ], 0,
   G -> ElementsFamily( FamilyObj( G ) )!.freeGroup );

############################################################################
##
#M  FreeGroupOfWholeGroup 
##
InstallMethod( FreeGroupOfWholeGroup,
  "for a subgroup of an L-presented group", true,
  [ IsSubgroupLpGroup ], 0,
  G -> ElementsFamily( FamilyObj( G ) )!.freeGroup );

############################################################################
##
#M  FixedRelatorsOfLpGroup( F )
##
InstallMethod( FixedRelatorsOfLpGroup,
    "for an L-presented group", true,
    [ IsLpGroup and IsGroupOfFamily ], 0,
    G -> ElementsFamily( FamilyObj( G ) )!.relators );

############################################################################
##
#M  IteratedRelatorsOfLpGroup( F )
##
InstallMethod( IteratedRelatorsOfLpGroup,
    "for an L-presented group", true,
    [ IsLpGroup and IsGroupOfFamily ], 0,
    G -> ElementsFamily( FamilyObj( G ) )!.itrels );

############################################################################
##
#M  EndomorphismsOfLpGroup( F )
##
InstallMethod( EndomorphismsOfLpGroup,
    "for an L-presented group", true,
    [ IsLpGroup and IsGroupOfFamily ], 0,
    G -> ElementsFamily( FamilyObj( G ) )!.endos );

#############################################################################
##
#M  ViewObj(<G>)
##
InstallMethod( ViewObj,
   "for a subgroup of an L-presented group", true,
   [ IsSubgroupLpGroup ], 1,
   function( G )
     if IsGroupOfFamily( G ) then
       Print("<");;
       if HasIsInvariantLPresentation( G ) then 
         if IsInvariantLPresentation( G )  then 
           Print("invariant ");
         else
           Print("non-invariant ");
         fi;
       fi;
       Print("LpGroup");
       if HasSize( G ) then
         Print(" of size ", Size( G ) );
       fi;
       if Length(GeneratorsOfGroup(G)) > GAPInfo.ViewLength * 10 then
         Print(" with ",Length(GeneratorsOfGroup(G))," generators>");
       else
         Print(" on the generators ",GeneratorsOfGroup(G),">");
       fi;
     else
       Print( "Group(" );
       if HasGeneratorsOfGroup( G ) then 
         if not IsBound( G!.gensWordLengthSum ) then 
           G!.gensWordLengthSum := Sum( List( GeneratorsOfGroup( G ), 
                                   x -> Length( UnderlyingElement( x ) ) ) );
         fi;
         if G!.gensWordLengthSum <= GAPInfo.ViewLength * 30 then 
           Print( GeneratorsOfGroup( G ) );
         else
           Print( "<subgroup of L-presented group with ", 
                  Length( GeneratorsOfGroup( G ) ), " generators>" );;
         fi;
       else
         Print("<subgroup of L-presented group, no generators known>");
       fi;
       Print( ")" );
     fi;
   end);

############################################################################
##
#F  LPresentedGroup ( <F> , <rels> , <Endos> , <itrels> ) 
##
InstallGlobalFunction( LPresentedGroup,
    function( F, rels, endos, itrels)
    local G,	# new object of an L-presentation
	  fam,  # new family of an L-presentation
	  gens; # generators of our group

    # Create a new family.
    fam := NewFamily( "FamilyElementsLpGroup", IsElementOfLpGroup );

    # Create the default type for the elements.
    fam!.defaultType := NewType( fam, IsPackedElementDefaultRep );

    fam!.freeGroup := F;
    fam!.relators := Immutable( rels );
    fam!.endos    := Immutable( endos );
    fam!.itrels   := Immutable( itrels );

    # Create the group.
    G := Objectify(
         NewType( CollectionsFamily( fam ),
            IsSubgroupLpGroup and IsWholeFamily and IsAttributeStoringRep ),
         rec() );

    # Mark <G> to be the 'whole group' of its elements
    FamilyObj( G )!.wholeGroup := G;
    SetFilterObj( G, IsGroupOfFamily );
    
    # an ascending L-presentation is an invariant L-presentation
    if IsAscendingLPresentation( G ) then
      SetIsInvariantLPresentation( G, true );
      SetEmbeddingOfAscendingSubgroup( G, GroupHomomorphismByImagesNC( G, G,
                    GeneratorsOfGroup(G), GeneratorsOfGroup(G)));
    fi;

    # Create generators of the group.
    gens:= List( GeneratorsOfGroup( F ), g -> ElementOfLpGroup( fam, g ) );
    SetGeneratorsOfGroup( G, gens );
    if IsEmpty( gens ) then
      SetOne( G, ElementOfLpGroup( fam, One( F ) ) );
    fi;

    return G;
    end);

############################################################################
##
#P  IsAscendingLPresentationt( <G> )
##
InstallMethod( IsAscendingLPresentation,
  "for L-presented groups",
  [ IsLpGroup ], 0,
  G -> IsEmpty(FixedRelatorsOfLpGroup(G)) );

############################################################################
##
#P  IsInvariantLPresentation( <G> )
##
InstallMethod( IsInvariantLPresentation,
  "for ascending L-presentations",
  [ IsLpGroup and IsAscendingLPresentation ], 0,
  G -> true);

InstallMethod( IsInvariantLPresentation,
  "compare the L-presentation with an underlying invariant L-presentation",
  [ IsLpGroup ], 1,
  function( G )

  if Length( FixedRelatorsOfLpGroup( G ) ) = 
     Length( FixedRelatorsOfLpGroup(UnderlyingInvariantLPresentation(G))) then
    return(true);
  else 
    TryNextMethod();
  fi;
  end);

# check whether the endomorphism of the free group induce endomorphisms of
# the multiplier and if we can extend the quotient system
# (this method may determine whether the group is NOT invariantly L-presented)
InstallMethod( IsInvariantLPresentation,
  "using the nilpotent quotient algorithm", true,
  [ IsLpGroup ], 0,
  function( G )
  local g,	# a copy of the original LpGroup <g>
	H;	# nilpotent quotients of <g>
  
  Info( InfoWarning, 1, "using the nilpotent quotient algorithm" );
  g:= LPresentedGroup( FreeGroupOfLpGroup(G), 
                       FixedRelatorsOfLpGroup(G),
                       EndomorphismsOfLpGroup(G),
                       IteratedRelatorsOfLpGroup(G) );
  
  # try the nilpotent quotient algorithm assuming that <G> is invariant
  SetIsInvariantLPresentation( g, true );

  H := NilpotentQuotient( g );
  if H = fail then 
    return(false);
  fi;
  end);

############################################################################
##
#M IsFinitelyGeneratedGroup
##
InstallMethod( IsFinitelyGeneratedGroup,
  "for a subgroup of an L-presented group", true,
  [ IsSubgroupLpGroup ], 0, 
  function( U )

    if HasGeneratorsOfGroup( U ) and IsList( GeneratorsOfGroup( U ) ) then
      return( true );
    fi;
  
    # try to compute the index of <U> in its (finitely generated) parent
    if IndexInWholeGroup( U ) < infinity then 
      return( true );
    else
      TryNextMethod();
    fi;
    end);

############################################################################
##
#A  UnderlyingAscendingLPresentation( <G> )
##
InstallMethod( UnderlyingAscendingLPresentation,
  "for an arbitrary LpGroup", true,
  [ IsLpGroup ], 0, 
  G -> LPresentedGroup( FreeGroupOfLpGroup(G), [], EndomorphismsOfLpGroup(G),
   	   	        IteratedRelatorsOfLpGroup(G)) );

############################################################################
##
#A  UnderlyingInvariantLPresentation( <G> )
##
InstallMethod( UnderlyingInvariantLPresentation,
  "for invariant L-presented groups", true,
  [ IsLpGroup and HasIsInvariantLPresentation and IsInvariantLPresentation ],0,
  G -> G);

InstallMethod( UnderlyingInvariantLPresentation,
  "for an arbitrary L-presented group", true,
  [ IsLpGroup ], 1,
  function( G )
  local rels,	# all possible combinations of fixed relators of <G>
	bool,	# a boolean
	i,x,	# a loop variable
	endo,	# an endomorphism of the LpGroup <G>
	itrels,	# iterated relators of the LpGroup <G>
	F,	# the underlying free group of the LpGroup <G>
	W,	# elements of the free monoid of free group endos
	R,	# finitely many of our relations
	H;	# an underlying invariant L-presentation

  # all combinations of the fixed relators - sorted by length
  rels:= Combinations( ShallowCopy(FixedRelatorsOfLpGroup( G )) );
  Sort( rels, function( a,b ) return( Length(a) > Length(b)); end);

  # the underlying free group for a conjugacy check (FGA)
  F := FreeGroupOfLpGroup( G );
  itrels := IteratedRelatorsOfLpGroup( G );

  # generators of a f.g. subgroup of <F>
  W := NQL_WordsOfLengthAtMostN( EndomorphismsOfLpGroup(G), 3 );
  if Length(W) >= 30 then
    W := W{[1..30]};
  fi;
  R := Flat( List( W, e-> List( itrels, x-> x^e )));

  for i in [1..Length(rels)] do
    bool:=true;
    for endo in EndomorphismsOfLpGroup(G) do
      for x in rels[i] do 
        if not x^endo in Group( Concatenation(rels[i],R) ) and
           not ForAny( Concatenation(rels[i],R),
                       z -> IsConjugate(F,x^endo,z) ) then
          bool:=false; break;
        fi;
      od;
      if not bool then break; fi;
    od;
    if bool then 
      if Length(rels[i]) = Length( FixedRelatorsOfLpGroup( G ))  then 
        if HasIsInvariantLPresentation( G )  then 
          ResetFilterObj( G, IsInvariantLPresentation ); 
        fi;
        SetIsInvariantLPresentation( G, true);
        return( G );
      fi;
      H:=LPresentedGroup( FreeGroupOfLpGroup( G ),
                          rels[i], 
                          EndomorphismsOfLpGroup( G ),
                          IteratedRelatorsOfLpGroup( G ) );
      SetIsInvariantLPresentation(H,true);
      return( H );
    fi;
  od;
  
  TryNextMethod();
  end);

InstallMethod( UnderlyingInvariantLPresentation,
  "for an arbitrary L-presented group", true,
  [ IsLpGroup ], 0, 
  UnderlyingAscendingLPresentation );
   
############################################################################
##
#M  EpimorphismFromFpGroup ( <LpGroup>, <n> )
##
##  returns an epimorphism from a finitely presented group G that is obtained 
##  from <LpGroup> by applying the endomorphisms at most <n> times into the 
##  L-presented group <LpGroup>
##
InstallMethod( EpimorphismFromFpGroup,
  "for an L-presented group and a positive integer", true,
  [ IsLpGroup, IsPosInt ], 0,
  function (L, n)
  local G, 	# the finitely presented group
  	F, 	# free group for <G>
	rels,	# relators for <G>
 	Endos,	# set endomorphisms that acts on the iterated relations
	sig;	# loop variable
   
  F    := FreeGroupOfLpGroup( L );
  rels := ShallowCopy( FixedRelatorsOfLpGroup( L ) );

  # all words in the free monoid of length at most <n>
  Endos := NQL_WordsOfLengthAtMostN( EndomorphismsOfLpGroup( L ), n );

  # apply the endomorphisms
  for sig in Endos do 
    Append( rels, List( IteratedRelatorsOfLpGroup(L), x-> Image( sig, x ) ) );;
  od;
  
  # the finitely presented group 
  G := F/rels;
  return( GroupHomomorphismByImagesNC( G, L, GeneratorsOfGroup( G ),
	   			             GeneratorsOfGroup( L ) ) );
  end);

############################################################################
##
#M  SplitExtensionByAutomorphismsLpGroup ( <G>, <H>, <auts> )
##
## returns the split extension of <G> by <H> where the action of each 
## generator of <H> on <G> is given by an automorphisms <aut>: <H> -> <G> 
## in the list <auts>.
##
InstallMethod( SplitExtensionByAutomorphismsLpGroup,
  "for an LpGroup, an FpGroup and a list of automorphisms", true,
  [ IsLpGroup, IsFpGroup, IsList] , 0,
  function( G, H, auts )
  local gensG,	# generators of <G> 
  	gensH,	# generators of <H> 
	F,	# free group of the split extension of <G> by <H>
	FgensG,	# generators of the free group corr. to those of <G>
	FgensH,	# generators of the free group corr. to those of <H>
	endo,	# an endomorphism
	map,	# MappingGeneratorsImages of <end>
	endos,	# endomorphisms of the L-presentation of the split extension
	itrels,	# iterated relators of the split extension
	rels,	# fixed relators of the split extension
	act,	# action of an automorphism
	i;	# loop variable

  gensG:=FreeGeneratorsOfLpGroup(G);
  gensH:=FreeGeneratorsOfFpGroup(H);

  # construct the free group on the union of gensG and gensH
  F:=FreeGroup(Concatenation(List(gensG,String),List(gensH,String)));
  FgensG:=GeneratorsOfGroup(F){[1..Length(gensG)]};
  FgensH:=GeneratorsOfGroup(F){[Length(gensG)+1..Length(GeneratorsOfGroup(F))]};

  # build the iterated relators as union of both itrels
  itrels:=Concatenation(
          List(IteratedRelatorsOfLpGroup(G),x->MappedWord(x,gensG,FgensG)),
          List(RelatorsOfFpGroup(H),x->MappedWord(x,gensH,FgensH)));

  # build the new endomorphisms
  endos:=[];
  for endo in EndomorphismsOfLpGroup(G) do 
    map:=ShallowCopy(MappingGeneratorsImages(endo));
    map[1]:=List(map[1],x->MappedWord(x,gensG,FgensG));
    map[2]:=List(map[2],x->MappedWord(x,gensG,FgensG));
    Append(map[1],FgensH);
    Append(map[2],FgensH);
    Add(endos,GroupHomomorphismByImagesNC(F,F,map[1],map[2]));
  od;
  
  # build the fixed relations as union of the fixed relation and the action of
  # the automorphism
  rels:=List(FixedRelatorsOfLpGroup(G),x->MappedWord(x,gensG,FgensG));

  # add the action of the automorphisms
  if not Length(auts)=Length(gensH) then 
    return(fail);
  fi;
  for i in [1..Length(auts)] do 
    act:=List(gensG,x->MappedWord(x,gensG,GeneratorsOfGroup(G)));
    act:=List(act,x->x^auts[i]);
    act:=List([1..Length(act)],x->FgensG[x]^FgensH[i]/MappedWord(act[x],
				GeneratorsOfGroup(G),FgensG));
    Append(rels,act);
  od;

  return(LPresentedGroup(F,rels,endos,itrels));
  end);

############################################################################
##
#M  SplitExtensionByAutomorphismsLpGroup ( <G>, <H>, <auts> )
##
## returns the split extension of <G> by <H> where the action of each 
## generator of <H> on <G> is given by an automorphisms <aut>: <H> -> <G> 
## in the list <auts>.
##
InstallMethod(SplitExtensionByAutomorphismsLpGroup,
  "for L-presented groups and a list of automorphism", true,
  [ IsLpGroup, IsLpGroup, IsList ], 0,
  function( G, H, auts )
  local gensG,	# generators of <G> 
  	gensH,	# generators of <H> 
	F,	# free group of the split extension of <G> by <H>
	FgensG,	# generators of the free group corr. to those of <G>
	FgensH,	# generators of the free group corr. to those of <H>
	endo,	# an endomorphism
	map,	# MappingGeneratorsImages of <end>
	endos,	# endomorphisms of the L-presentation of the split extension
	itrels,	# iterated relators of the split extension
	rels,	# fixed relators of the split extension
	act,	# action of an automorphism
	i;	# loop variable

  gensG:=FreeGeneratorsOfLpGroup(G);
  gensH:=FreeGeneratorsOfLpGroup(H);

  # construct the free group on the union of gensG and gensH
  F:=FreeGroup(Concatenation(List(gensG,String),List(gensH,String)));
  FgensG:=GeneratorsOfGroup(F){[1..Length(gensG)]};
  FgensH:=GeneratorsOfGroup(F){[Length(gensG)+1..Length(GeneratorsOfGroup(F))]};

  # build the iterated relators as union of both itrels
  itrels:=Concatenation(
          List(IteratedRelatorsOfLpGroup(G),x->MappedWord(x,gensG,FgensG)),
          List(IteratedRelatorsOfLpGroup(H),x->MappedWord(x,gensH,FgensH)));

  # build the new endomorphisms
  endos:=[];
  for endo in EndomorphismsOfLpGroup(G) do 
    map:=ShallowCopy(MappingGeneratorsImages(endo));
    map[1]:=List(map[1],x->MappedWord(x,gensG,FgensG));
    map[2]:=List(map[2],x->MappedWord(x,gensG,FgensG));
    Append(map[1],FgensH);
    Append(map[2],FgensH);
    Add(endos,GroupHomomorphismByImagesNC(F,F,map[1],map[2]));
  od;
  for endo in EndomorphismsOfLpGroup(H) do 
    map:=ShallowCopy(MappingGeneratorsImages(endo));
    map[1]:=List(map[1],x->MappedWord(x,gensH,FgensH));
    map[2]:=List(map[2],x->MappedWord(x,gensH,FgensH));
    map[1]:=Concatenation(FgensG,map[1]);
    map[2]:=Concatenation(FgensG,map[2]);
    Add(endos,GroupHomomorphismByImagesNC(F,F,map[1],map[2]));
  od;
  
  # build the fixed relations as union of the fixed relation and the action of
  # the automorphism
  rels:=Concatenation(
          List(FixedRelatorsOfLpGroup(G),x->MappedWord(x,gensG,FgensG)),
          List(FixedRelatorsOfLpGroup(H),x->MappedWord(x,gensH,FgensH)));

  # add the action of the automorphisms
  if not Length(auts)=Length(gensH) then 
    return(fail);
  fi;
  for i in [1..Length(auts)] do 
    act:=List(gensG,x->MappedWord(x,gensG,GeneratorsOfGroup(G)));
    act:=List(act,x->x^auts[i]);
    act:=List([1..Length(act)],x->FgensG[x]^FgensH[i]/MappedWord(act[x],
				GeneratorsOfGroup(G),FgensG));
    Append(rels,act);
  od;

  return(LPresentedGroup(F,rels,endos,itrels));
  end);

#############################################################################
##
#M  \= ( <elm1>, <elm2> )  . . . . . for two elements of an L-presented group 
##
InstallMethod( \=, 
   "for elements of an L-presented group", IsIdenticalObj, 
   [ IsElementOfLpGroup, IsElementOfLpGroup ], 0,
   function( left, right )
   local epi, 		# epimorphism onto a nilpotent quotient of the group
	 Grp,		# the LpGroup of <left>
   	 truth,	 	# the TRUTH ;)		
	 c;		# class of the nilpotent quotient 

   if UnderlyingElement(left) = UnderlyingElement(right) then 
     return(true);
   else
     # use the nilpotent quotient algorithm and seek for a quotient 
     # where both elements differ
     Info( InfoWarning, 1, "EQ using a nilpotent quotient algorithm" );

     # recover the group from the element
     Grp:=CollectionsFamily(FamilyObj(left))!.wholeGroup;
  
     c:=1;
     while true do 
       epi:=NqEpimorphismNilpotentQuotient(Grp,c);
       if left^epi <> right^epi then 
         return(false);
       elif HasLargestNilpotentQuotient(Grp) then 
         Info(InfoWarning,1,"EQ fails (found a maximal nilpotent quotient)");
         TryNextMethod();
       fi;
       c:=c+1;
     od;
   fi;
   end );

############################################################################
##
#M  Random( <LpGroup> ) .  .  .  .  .  .  .  . a random element in <LpGroup>
##
InstallOtherMethod( Random,
  "for LpGroups", true,
  [ IsLpGroup ], 0,
  G -> ElementOfLpGroup( ElementsFamily( FamilyObj( G ) ), 
                         Random( FreeGroupOfLpGroup( G ) ) ) );

############################################################################
##
#M  AsLpGroup ( <FpGroup> )  .  .  .  .  .  .  for finitely presented groups
##
InstallOtherMethod( AsLpGroup, 
  "for FpGroups ", true,
  [ IsFpGroup ], 0,
  function( FpGroup )
  local Lp;	# the LpGroup
  
  Lp := LPresentedGroup( FreeGroupOfFpGroup( FpGroup ), [], 
                         [ IdentityMapping( FreeGroupOfFpGroup( FpGroup ) ) ], 
                         RelatorsOfFpGroup( FpGroup ) );

  if HasIsFinite( FpGroup ) then
    SetIsFinite( Lp, IsFinite( FpGroup) );
  fi;
  if HasSize( FpGroup ) then 
    SetSize( Lp, Size( FpGroup ) );
  fi;
  SetIsFinitelyPresentable( Lp, true );

  return( Lp );
  end);

############################################################################
##
#M  AsLpGroup ( <FreeGroup> )  .  .  .  .  .  .  .  .  .  .  for free groups
##
InstallOtherMethod( AsLpGroup,
  "for free groups", true,
  [ IsFreeGroup ], 0,
  function( G )
  local Lp;

  Lp := LPresentedGroup( G, [], [ IdentityMapping( G ) ], [] );
  SetIsFinitelyPresentable( Lp, true );

  return( Lp );
  end);

############################################################################
##
#M  AsLpGroup ( <Grp> )  .  .  for arbitrary groups using IsomorphismFpGroup
##
InstallOtherMethod( AsLpGroup,
  "for arbitrary groups using IsomorphismFpGroup", true,
  [ IsGroup ], 0,
  function( G ) 
  local Lp;	# the isomorphic LpGroup

  Lp := AsLpGroup( Range( IsomorphismFpGroup( G ) ) );
  SetIsFinitelyPresentable( Lp, true);

  if HasIsFinite( G ) then 
    SetIsFinite( Lp, IsFinite( G ) );
  fi;
  if HasSize( G ) then 
    SetSize( Lp, Size( G ) );
  fi;
  
  return( Lp );
  end);
  
############################################################################
##
#M  IsomorphismLpGroup( <Grp> ) .  .  .  .  .  .  .  .  for arbitrary groups
##
InstallMethod( IsomorphismLpGroup,
  "for an arbitrary group", true,
  [ IsGroup ], 0,
  function( F )
  local G, 	# the LpGroup obtained from `AsLpGroup'
	mapi,	# MappingGeneratorsImages of the IsomorphismFpGroup
	iso;	# the isomorphism from <F> to <G>

  G   := AsLpGroup( F );

  if Length( GeneratorsOfGroup( F ) ) <> Length( GeneratorsOfGroup( G ) ) then
    # the LpGroup is obtained from <IsomorphismFpGroup>
    mapi := MappingGeneratorsImages( IsomorphismFpGroup( F ) );
    iso  := IsomorphismLpGroup( Range( IsomorphismFpGroup( F ) ) );
    iso  := GroupHomomorphismByImagesNC( Source( IsomorphismFpGroup( F ) ),
                              AsLpGroup( Range( IsomorphismFpGroup( F ) ) ),
                              mapi[1], List( mapi[2], x -> x ^ iso ) );
  else
    iso := GroupHomomorphismByImagesNC( F, G, GeneratorsOfGroup( F ),
                                        GeneratorsOfGroup( G ) );
  fi;

  SetIsInjective( iso, true );
  SetIsSurjective( iso, true );

  return( iso );
  end); 
