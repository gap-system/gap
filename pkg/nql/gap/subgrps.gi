############################################################################
##
#W  subgrps.gi			The NQL-package			René Hartung
##
#H   @(#)$Id: subgrps.gi,v 1.1 2010/03/17 13:03:40 gap Exp $
##
Revision.("nql/gap/subgrps_gi"):=
  "@(#)$Id: subgrps.gi,v 1.1 2010/03/17 13:03:40 gap Exp $";

############################################################################
##
#M IndexInWholeGroup
##
InstallMethod( IndexInWholeGroup,
  "for a subgroup of an LpGroup", true,
  [ IsSubgroupLpGroup ], 0,
  function( H )
  local Tab;
  Tab := CosetTableInWholeGroup( H );
  if Length( Tab ) = 0 then 
    return( 1 );
  else
    return( Length( Tab[1] ) );
  fi;
  end);

InstallMethod( IndexInWholeGroup, 
  "for a full L-presented group", true, 
  [ IsSubgroupLpGroup and IsWholeFamily ], 0, 
  function( G )
  SetCosetTableInWholeGroup( G, 
      ListWithIdenticalEntries( 2 * Length( GeneratorsOfGroup( G ) ), [ 1 ] ) );
  return( 1 );
  end);

############################################################################
##
#M  IndexOp
##
InstallMethod( IndexOp,
  "for an LpGroup and a subgroup of an LpGroup", true, 
  [ IsSubgroupLpGroup, IsSubgroupLpGroup ], 0, 
  function( G, H )

  if IsIdenticalObj( G, H ) then return( 1 ); fi;
  
  if HasParent( H ) and IsIdenticalObj( Parent( H ), G ) then 
    return( IndexInWholeGroup( H ) );
  else
    if not IsSubset( G, H ) then 
      Error( "<H> must be a subgroup of <G>" );
    fi;
    return( IndexInWholeGroup( H ) / IndexInWholeGroup( G ) );
  fi;
  end);

############################################################################
##
#M CosetTableInWholeGroup
##
InstallMethod( CosetTableInWholeGroup,
  "for a subgroup of an LpGroup", true, 
  [ IsSubgroupLpGroup ], 1, 
  function( H )
  local G,	# the parent of <H>
	sig,	# the iterating endomorphism
	Tab,	# the current coset-table
	ind,	# the current index
	phi, 	# permutation representation 
	map,	# commuting map
	img, 	# images of the iterated relators
	Sym, 	# symmetric group on <ind> letters
	Maps, 	# a whole bunch of mappings <F> -> <Sym>
	g,h,	# an FpGroup and its subgroup
	fam,	# ElementsFamily of <g>
	rels, 	# finitely many relators for <g>
	prd,	# `periodicity' of <map>
	U,V,	# Source and Range for <map>
	i,j,l; 	# loop variables

  # the parent LpGroup
  G := Parent( H );
  if Length( EndomorphismsOfLpGroup( G ) ) > 1 then 
    TryNextMethod();
  elif Length( EndomorphismsOfLpGroup( G ) ) = 0 then 
    # catch the trivial case
    g := FreeGroupOfLpGroup( G ) / Concatenation( FixedRelatorsOfLpGroup( G ),
                                   IteratedRelatorsOfLpGroup( G ) );
    fam := ElementsFamily( FamilyObj( g ) );
    h := Subgroup( g, List( GeneratorsOfGroup( H ), 
                   x -> ElementOfFpGroup( fam, UnderlyingElement( x ) ) ) );
    return( CosetTableInWholeGroup( h ) );
  fi;

  sig := EndomorphismsOfLpGroup( G )[1];

  # find an FpGroup which has <H> as a finite ind. subgroup and maps onto <G>
  l := NQL_TCSTART;
  repeat
    g   := Source( EpimorphismFromFpGroup( G , l ) );
    fam := ElementsFamily( FamilyObj( g ) );
    h   := Subgroup( g, List( GeneratorsOfGroup( H ), 
                     x -> ElementOfFpGroup( fam, UnderlyingElement( x ) ) ) );
   
    Info( InfoNQL, 1, "Trying FpGroup with ", l, " iterations..." );

    # call usual Todd-Coxeter algorithm for this finitely presented group
    Tab := NQL_CosetEnumerator( h );

    if Tab <> fail then 
      if Length( Tab ) = 0 or Length( Tab[1] ) = 0 then 
        Info( InfoNQL, 1, "Coset-enumeration succeeded: the index is 1" ); 
      else
        Info( InfoNQL, 1, "Coset-enumeration succeeded: the index is ", 
                          Length( Tab[1] ) ); 
      fi;
    fi;
    
    l := l + 1;
  until Tab <> fail;

  if Length( Tab ) = 0 or Length( Tab[1] ) = 0 then return( Tab ); fi;

  ind := Length( Tab[1] );;
  Sym := SymmetricGroup( ind );

  # proof that all relator-tables are closed or enforce coincidences
  phi := GroupHomomorphismByImagesNC( FreeGroupOfLpGroup( G ), Sym,
 			  FreeGeneratorsOfLpGroup( G ),
                          List( Tab{[ 1, 3 .. Length(Tab)-1 ]}, PermList ) );

  # check if <Tab> is a already a coset-table; otherwise enforce coincidences
  Maps := [ phi ];;
  img  := FreeGeneratorsOfLpGroup( G );
  j    := 1;
  prd  := 0;
  repeat 
    img := List( img, x -> Image( sig, x ) );
    j := j + 1;;

    Add( Maps, GroupHomomorphismByImagesNC( FreeGroupOfLpGroup( G ), Sym,
                                  FreeGeneratorsOfLpGroup( G ),
                                  List( img, x -> Image( phi, x ) ) ) );

    if ForAny( IteratedRelatorsOfLpGroup( G ), 
       x -> not IsOne( Image( Maps[j], x ) ) ) then 
 
      Info( InfoNQL, 1, "An iterated relator yields a coincidence..." );
    
      Tab := NQL_EnforceCoincidences( Tab, H, Maps[ Length( Maps ) ] );
      
      if Length( Tab ) = 0 then return( Tab ); fi;

      ind := Length( Tab[1] );
      Info( InfoNQL, 1, "  -> the index is ", ind );
 
      # continue with the new coset-table setting
      Sym := SymmetricGroup( ind );
      j := 0;;
      prd := 0;;
      phi := GroupHomomorphismByImagesNC( FreeGroupOfLpGroup( G ), Sym, 
                             FreeGeneratorsOfLpGroup( G ), 
                             List( Tab{[ 1, 3 .. Length(Tab)-1 ]}, PermList ) );
      Maps := [ phi ]; 
      img  := FreeGeneratorsOfLpGroup( G );
    fi;

    for i in [ 1 .. j-1 ] do 
      U := Image( Maps[i] );
      V := Image( Maps[j] );
      map := GroupHomomorphismByImages( U, V, 
	                      MappingGeneratorsImages( Maps[i] )[2],
	                      MappingGeneratorsImages( Maps[j] )[2] );

      if map <> fail then 
        prd := j-i; break;
      fi;
    od;
  until prd > 0;

  SetIndexInWholeGroup( H, ind );
  return( Tab );
  end );

InstallMethod( CosetTableInWholeGroup,
  "for a subgroup of an LpGroup", true, 
  [ IsSubgroupLpGroup ], 0, 
  function( H )
  local G,	# the parent of <H>
	g,h,	# an FpGroup and its subgroup
	fam,	# ElementsFamily of <g>
	rels, 	# finitely many relators for <g>
	Tab,	# the current coset-table
	ind,	# the current index
	phi, 	# permutation representation 
	map,	# commuting map
	img, 	# vertices of the tree in End(F)
	Img, 	# vertices of the tree in <Sym>^rk(F)
	Sym, 	# symmetric group on <ind> letters
	stack,	# current stack
	Stack,	# new stack
	ModTab,	# modified the coset-table by enforcing coincidences
	i,j,l,k;# loop variables

  # initialization
  G := Parent( H );

  # find an FpGroup which has <H> as a f.i.-subgroup and maps onto <G>
  l := NQL_TCSTART;
  repeat
    g   := Source( EpimorphismFromFpGroup( G, l ) );
    fam := ElementsFamily( FamilyObj( g ) );
    h   := Subgroup( g, List( GeneratorsOfGroup( H ), 
                     x -> ElementOfFpGroup( fam, UnderlyingElement( x ) ) ) );
   
    Info( InfoNQL, 1, "Trying FpGroup with ", l, " iterations..." );

    # call usual Todd-Coxeter algorithm for this finitely presented group
    Tab := NQL_CosetEnumerator( h );

    if Tab <> fail then 
      if Length( Tab ) = 0 or Length( Tab[1] ) = 0 then 
        Info( InfoNQL, 1, "Coset-enumeration succeeded: the index is 1" );
      else
        Info( InfoNQL, 1, "Coset-enumeration succeeded: the index is ", 
                          Length( Tab[1] ) );
      fi;
    fi;
    
    l := l + 1;
  until Tab <> fail;

  # catch trivial case
  if Length( Tab ) = 0 or Length( Tab[1] ) = 0 then return( Tab ); fi;

  # prove or disprove that all relator-tables are closed 
  ind    := Length( Tab[1] );;
  Sym    := SymmetricGroup( ind );
  phi    := GroupHomomorphismByImagesNC( FreeGroupOfLpGroup( G ), Sym,
 			  FreeGeneratorsOfLpGroup( G ),
                          List( Tab{[ 1, 3 .. Length(Tab)-1 ]}, PermList ) );
  img    := [ List( FreeGeneratorsOfLpGroup( G ), x -> Image( phi, x ) ) ];
  stack  := [ FreeGeneratorsOfLpGroup( G ) ];
  ModTab := false;
  l := 0;;
  repeat 
    l := l + 1;
    Stack := [];

    for i in [ 1 .. Length( stack ) ] do
      for k in [ 1 .. Length( EndomorphismsOfLpGroup(G) ) ] do 
        Img := List( stack[i], x -> Image( EndomorphismsOfLpGroup(G)[k], x ) );
        map := GroupHomomorphismByImagesNC( FreeGroupOfLpGroup( G ), Sym,
                                            FreeGeneratorsOfLpGroup( G ), 
                                            List( Img, x -> Image( phi, x ) ) );

        # check if a relator yields a coincidence
        if ForAny( IteratedRelatorsOfLpGroup( G ), 
                   x -> not IsOne( Image( map, x ) ) ) then 

          Info( InfoNQL, 1, "An iterated relator yields a coincidence..." );

          # enforce this coincidence 
          Tab := NQL_EnforceCoincidences( Tab, H, map );

          if Length( Tab ) = 0 or Length( Tab[1] ) = 0 then
            Info( InfoNQL, 1, "  -> the index is 1 ");
            return( Tab );
          else 
            Info( InfoNQL, 1, " -> the index is ", Length( Tab[1] ) );
          fi;

          ModTab := true;

          # continue with the new coset-table
          ind   := Length( Tab[1] );
          Sym   := SymmetricGroup( ind );
          phi   := GroupHomomorphismByImagesNC( FreeGroupOfLpGroup( G ), Sym, 
                            FreeGeneratorsOfLpGroup( G ), 
                            List( Tab{[ 1, 3 .. Length(Tab)-1 ]}, PermList ) );
          stack := [ FreeGeneratorsOfLpGroup( G ) ];
          img   := [ List( FreeGeneratorsOfLpGroup(G), x -> Image( phi, x ) ) ];
          break;
        fi;

        if ForAll( img, x -> GroupHomomorphismByImages( Group( x ), Sym, x,
                             List( Img, y -> Image( phi, y ) ) ) = fail ) then
          Add( img, List( Img, y -> Image( phi, y ) ) );
          Add( Stack, Img );
        fi;
      od;
      if ModTab then ModTab := false; break; fi;
    od;

    stack := Stack;
  until IsEmpty( stack );

  SetIndexInWholeGroup( H, ind );
  return( Tab );
  end );

############################################################################
##
#M CosetTable 
##
InstallMethod( CosetTable,
  "for an LpGroup and a subgroup of an LpGroup", true,
  [ IsLpGroup, IsSubgroupLpGroup ], 0,
  function( G, H )
  
  if HasParent( H ) and IsIdenticalObj( Parent( H ), G ) then
    return( CosetTableInWholeGroup( H ) );
  else
    Error("not implemented yet in <nql/gap/subgrps.gi>");
  fi;
  end);


############################################################################
##
#M TraceCosetTableLpGroup
##
InstallMethod( TraceCosetTableLpGroup,
  "for a coset-table, an element of an LpGroup, and a coset number", true,
  [ IsList, IsElementOfLpGroup, IsPosInt ], 0, 
  function( Tab, elm, p )
  return( TraceCosetTableLpGroup( Tab, UnderlyingElement( elm ), p ) );
  end);

InstallMethod( TraceCosetTableLpGroup,
  "for a coset-table, an element of the free group, and a coset number", true,
  [ IsList, IsElementOfFreeGroup, IsPosInt ], 0,
  function( Tab, elm, p )
   local i, j, e, pos, ex;
   ex := ExtRepOfObj( elm );
   for i in [ 1, 3 .. Length(ex)-1 ] do
     # exponent of this generator
     e := ex[i+1];
     # choose position in the coset table g_1, g_1^{-1}, g_2, g_2^{-1} ...
     if e < 0 then
       pos := 2 * ex[i];
       e := -e;
     else
       pos := 2 * ex[i] - 1;
     fi;
     # walk along the coset table as often as |e|
     for j in [ 1 .. e ] do
       p := Tab[pos][p];
     od;
   od;
   return( p );
  end);

############################################################################
##
#M \in 
##
InstallMethod( \in,
  "for an element of an LpGroup and a subgroup of an LpGroup", IsElmsColls,
  [ IsElementOfLpGroup, IsSubgroupLpGroup ], 0,
  function( g, U )
    local Tab;

    if not HasCosetTableInWholeGroup( U ) then 
      Info( InfoWarning, 1, "IN using coset enumeration for a subgroup of",
                            " an LpGroup" );
    fi;
   
    Tab := CosetTableInWholeGroup( U );
    return( TraceCosetTableLpGroup( Tab, g, 1 ) = 1 );
  end);


############################################################################
##
#M \=
##
InstallMethod( \=,
  "for two subgroups of an LpGroup", IsIdenticalObj,
  [ IsSubgroupLpGroup, IsSubgroupLpGroup ], 0,
  function( U, H )

  # compute a coset table first
  if IndexInWholeGroup( U ) = fail or IndexInWholeGroup( H ) = fail then 
    return( fail );
  fi;

  return( IndexInWholeGroup( U ) = IndexInWholeGroup( H ) and 
          IsSubset( U, H ) and IsSubset( H, U ) );
  end);

############################################################################
##
#M  IsSubSet
##
InstallMethod( IsSubset,
  "for two subgroups of an LpGroup", IsIdenticalObj, 
  [ IsSubgroupLpGroup, IsSubgroupLpGroup ], 0,
  function( G, H )
  return( ForAll( GeneratorsOfGroup( H ), x -> x in G ) );
  end);


############################################################################
##
#M IsNormalOp
##
InstallMethod( IsNormalOp,
  "for two subgroups of an LpGroup", IsIdenticalObj,
  [ IsSubgroupLpGroup, IsSubgroupLpGroup ], 0,
  function( G, H )
    return( ForAll( GeneratorsOfGroup( G ), g ->
            ForAll( GeneratorsOfGroup( H ), h -> h ^ g in H ) ) );
  end);

############################################################################
##
#M NaturalHomomorphismByNormalSubgroupNCOrig
##
InstallMethod( NaturalHomomorphismByNormalSubgroupNCOrig,
  "for a normal subgroup of an LpGroup of finite index", IsIdenticalObj,
  [ IsSubgroupLpGroup, IsSubgroupLpGroup ], 0, 
  function( G, N )
    local i, img, Tab, ind, hom;;  

    if not IsNormal( G, N ) then 
      Error("<N> must be normal in <G>");
    fi;
   
    if IndexInWholeGroup( G ) > 1 then
      Error("not implemented yet in <nql/gap/subgrps.gi>");
    fi;

    Tab := CosetTableInWholeGroup( N );
    ind := Index( G, N );
    img := ListWithIdenticalEntries( Length( GeneratorsOfGroup( G ) ), 0 );
    for i in [ 1 .. Length( GeneratorsOfGroup( G ) )] do 
      img[i] := PermList( Tab[ 2 * i - 1 ] );
    od;

    hom := GroupGeneralMappingByImages( G, SymmetricGroup( ind ), 
                                        GeneratorsOfGroup( G ), img );

    SetKernelOfMultiplicativeGeneralMapping( hom, N );
    return( hom );
  end);

############################################################################
##
#F SubgroupLpGroupByCosetTable
##
InstallMethod( SubgroupLpGroupByCosetTable,
  "for an LpGroup-family and a coset table", true,
  [ IsFamily, IsList ], 0,
  function( fam, Tab )
  local U;

  U := Objectify( NewType( fam, IsGroup and IsAttributeStoringRep ), rec() );

  SetParent( U, fam!.wholeGroup );
  SetCosetTableInWholeGroup( U, Tab );
 
  if Length( Tab ) = 0 then 
    SetIndexInWholeGroup( U, 1 );
  else 
    SetIndexInWholeGroup( U, Length( Tab[1] ) );
  fi;

  return( U );
  end);

InstallMethod( SubgroupLpGroupByCosetTable, 
  "for an LpGroup and a coset table", true,
  [ IsLpGroup, IsList ], 0, 
  function( G, Tab )
  return( SubgroupLpGroupByCosetTable( FamilyObj( G ), Tab ) );
  end);

############################################################################
##
#M GeneratorsOfMagmaWithInverses
##
InstallMethod( GeneratorsOfMagmaWithInverses,
  "for a subgroup of an LpGroup with a coset table", true, 
  [ IsSubgroupLpGroup and HasCosetTableInWholeGroup ], 0, 
  function( H )
  local Tab, 	# the coset table
	ind, 	# the index
	trans,	# the Schreier transversal
	gens,	# the Schreier generators
	t,	# a transversal
	Alph,	# the underlying alphabet
	fam,	# ElementsFamily of <H>
	x,i,j;  # loop variables

  # initialization 
  Tab  := CosetTableInWholeGroup( H );
  Alph := Concatenation( FreeGeneratorsOfWholeGroup( H ), 
          List( FreeGeneratorsOfWholeGroup( H ), x -> x ^ -1 ) );

  if Length( Tab ) = 0 then 
    return( GeneratorsOfGroup( Parent( H ) ) );
  fi;
  ind := Length( Tab[1] );

  # the Schreier transversal
  trans    := ListWithIdenticalEntries( ind, 0 );
  trans[1] := One( FreeGroupOfWholeGroup( H ) );

  # generators by Schreier's theorem.
  gens := [];;

  repeat
    for i in [ 1 .. ind ] do
      if trans[i] <> 0 then 
        for x in Alph do 
          t := trans[i] * x;
          j := TraceCosetTableLpGroup( Tab, x, i );
          if trans[j] = 0 then 
            trans[j] := t;
          elif t <> trans[j] then 
            Add( gens, t * trans[j]^-1 );
          fi;
        od;
      fi;
    od;
  until ForAll( trans, x -> x <> 0 );

  # convert to elements of the LpGroup
  fam := ElementsFamily( FamilyObj( Parent( H ) ) );
  return( List( gens, x -> ElementOfLpGroup( fam, x ) ) );
  end);

############################################################################
##
#F NQL_EnforceCoincidences
##
InstallGlobalFunction( NQL_EnforceCoincidences,
  function( tab, H, map )
  local i, j, ind, G, Tab, co, c, Entries, pos, l, Bij, coinc, img;

  # IndexCosetTab
  if Length( tab ) = 0 then 
    ind := 1;;
  else
    ind := Length( tab[1] );
  fi;

  # compute the coincidences
  G   := Parent( H );
  img := List( IteratedRelatorsOfLpGroup( G ), 
               x -> Image( map, x ) );
  coinc := [];
  for i in [ 1 .. Length( img ) ] do 
    if not IsOne( img[i] ) then 
      for j in [ 1 .. ind ] do 
        c := [ j ^ img[i], j ];
        if c[1] < c[2] and 
           not c in coinc then 
          Add( coinc, c );
        elif c[1] > c[2] and 
             not Reversed( c ) in coinc then 
          Add( coinc, Reversed( c ) );
        fi;
      od;
    fi;
  od;

  # enforce coincidences
  Tab := MutableCopyMat( tab );
  Entries := [ 1 .. Length( Tab[1] ) ];
  while IsBound( coinc[1] ) do 
    co := Remove( coinc, Length( coinc ) );

    for i in [ 1 .. Length( Tab ) ] do
      for j in [ 1 .. Length( Tab[1] ) ] do
        if Tab[i][j] = co[2] then Tab[i][j] := co[1]; fi;
      od;
    od;

    pos := Position( Entries, co[2] );
    if pos <> fail then 
      Remove( Entries, pos );
    fi;

    for i in [ 1 .. Length( Tab ) ] do 
      if Tab[i][ co[1] ] > Tab[i][ co[2] ] then 
        c := [ Tab[i][ co[2] ], Tab[i][ co[1] ] ];
      elif Tab[i][ co[1] ] < Tab[i][ co[2] ] then 
        c := [ Tab[i][ co[1] ], Tab[i][ co[2] ] ];
      fi;
    
      if ( c <> co ) and not ( c in coinc ) then
        Add( coinc, c ); 
      fi;
    od;
  od;
   
  # renumbering of the cosets
  Tab := List( [ 1 .. Length( Tab ) ], x -> Tab[x]{Entries} );

  Bij := AsSSortedList( Tab[1] );

  for i in [ 1 .. Length( Tab ) ] do 
    for j in [ 1 .. Length( Tab[1] ) ] do 
      Tab[i][j] := Position( Bij, Tab[i][j] );
    od;
  od;

  StandardizeTable( Tab );;

  return( Tab );
  end);

############################################################################;
##
#F LowIndexSubgroupsLpGroupByFpGroup
##
InstallMethod( LowIndexSubgroupsLpGroupByFpGroup,
  "for an LpGroup, a positive integers, and the index", true,
  [ IsLpGroup, IsPosInt, IsPosInt ], 0,
  function( G, its, ind )
  local g, LIS, fam, it, U;
 
  # elements family of the LpGroup <G>
  fam := ElementsFamily( FamilyObj( G ) );

  # catch the trivial case
  if Length( EndomorphismsOfLpGroup( G ) ) = 0 then
    g := FreeGroupOfLpGroup( G ) / Concatenation( FixedRelatorsOfLpGroup( G ),
         IteratedRelatorsOfLpGroup( G ) );
    LIS := LowIndexSubgroupsFpGroup( g, ind );
    return( List( LIS, x -> Subgroup( G,  List( GeneratorsOfGroup( x ), 
                  y -> ElementOfLpGroup( fam, UnderlyingElement( y ) ) ) ) ) );
  fi;

  # define the FpGroup w.r.t. words of length at most <its> in the monoid
  g   := Source( EpimorphismFromFpGroup( G, its ) );
  it  := LowIndexSubgroupsFpGroupIterator( g, ind );
  LIS := [];;
  while not IsDoneIterator( it ) do 
    U := NextIterator( it );
    U := Subgroup( G, List( GeneratorsOfGroup( U ), 
              x -> ElementOfLpGroup( fam, UnderlyingElement( x ) ) ) );

    if not ( U in LIS ) then Add( LIS, U ); fi;
  od;
  return( LIS );
  end);

InstallOtherMethod( LowIndexSubgroupsLpGroupByFpGroup,
  "for an LpGroup and a positive integer", true, 
  [ IsLpGroup, IsPosInt ], 0, 
  function( G, ind )
  return( LowIndexSubgroupsLpGroupByFpGroup( G, 2, ind ) );
  end);

############################################################################
##
#M DerivedSubgroup
##
InstallMethod( DerivedSubgroup,
  "for an LpGroup", true, 
  [ IsLpGroup ], 0,
  G -> Kernel( NqEpimorphismNilpotentQuotient( G, 1 ) ) );

############################################################################
##
#M NilpotentQuotientIterator
##
InstallMethod( NilpotentQuotientIterator, 
  "for an LpGroup", true, 
  [ IsLpGroup ], 0, 
  function( G )
  local filter, it, NextIterator, IsDoneIterator, ShallowCopyIT;

  NextIterator := function( iter )
    local H;
      iter!.class := iter!.class + 1;;
      H := NilpotentQuotient( iter!.group, iter!.class );
      if NilpotencyClassOfGroup( H ) < iter!.class then 
        iter!.max := iter!.class;
        Error( "exhausted the iterator <iter>" );
      fi;
      return( H );
    end;
 
  IsDoneIterator := function( iter )
      return( iter!.max > 0 );   
    end;

  ShallowCopyIT := function( iter )
    return( rec( group := iter!.group,
                 class := iter!.class, 
                 max   := iter!.max ) );
    end;

  filter := IsIteratorByFunctions and IsAttributeStoringRep and IsMutable;

  it := rec( NextIterator := NextIterator, IsDoneIterator := IsDoneIterator,
             ShallowCopy := ShallowCopyIT );

  it!.group := G;
  it!.class := 0;
  it!.max   := 0;

  return( Objectify( NewType( IteratorsFamily, filter ), it ) );
  end);

############################################################################
##
#M NqEpimorphismNilpotentQuotientIterator
##
InstallMethod( NqEpimorphismNilpotentQuotientIterator, 
  "for an LpGroup", true, 
  [ IsLpGroup ], 0, 
  function( G )
  local filter, it, NextIterator, IsDoneIterator, ShallowCopyIT;

  NextIterator := function( iter )
    local epi;
      iter!.class := iter!.class + 1;;
      epi := NqEpimorphismNilpotentQuotient( iter!.group, iter!.class );
      if NilpotencyClassOfGroup( Range( epi ) ) < iter!.class then 
        iter!.max := iter!.class;
        Error( "exhausted the iterator <iter>" );
      fi;
      return( epi );
    end;
 
  IsDoneIterator := function( iter )
      return( iter!.max > 0 );   
    end;

  ShallowCopyIT := function( iter )
    return( rec( group := iter!.group,
                 class := iter!.class, 
                 max   := iter!.max ) );
    end;

  filter := IsIteratorByFunctions and IsAttributeStoringRep and IsMutable;

  it := rec( NextIterator := NextIterator, IsDoneIterator := IsDoneIterator,
             ShallowCopy := ShallowCopyIT );

  it!.group := G;
  it!.class := 0;
  it!.max   := 0;

  return( Objectify( NewType( IteratorsFamily, filter ), it ) );
  end);

############################################################################
##
#M LowerCentralSeriesIterator
##
InstallMethod( LowerCentralSeriesIterator, 
  "for an LpGroup", true, 
  [ IsLpGroup ], 0, 
  function( G )
  local filter, it, NextIterator, IsDoneIterator, ShallowCopyIT;

  NextIterator := function( iter )
    local epi;
      iter!.class := iter!.class + 1;;
      epi := NqEpimorphismNilpotentQuotient( iter!.group, iter!.class );
      if NilpotencyClassOfGroup( Range( epi ) ) < iter!.class then 
        iter!.max := iter!.class;
        Error( "exhausted the iterator <iter>" );
      fi;
      return( Kernel( epi ) );
    end;
 
  IsDoneIterator := function( iter )
      return( iter!.max > 0 );   
    end;

  ShallowCopyIT := function( iter )
    return( rec( group := iter!.group,
                 class := iter!.class, 
                 max   := iter!.max ) );
    end;

  filter := IsIteratorByFunctions and IsAttributeStoringRep and IsMutable;

  it := rec( NextIterator := NextIterator, IsDoneIterator := IsDoneIterator,
             ShallowCopy := ShallowCopyIT );

  it!.group := G;
  it!.class := 0;
  it!.max   := 0;

  return( Objectify( NewType( IteratorsFamily, filter ), it ) );
  end);

############################################################################
##
#M Size
##
############################################################################
InstallMethod( Size, 
   "for an LpGroup", true, 
   [ IsLpGroup ], 0,  
   G -> IndexInWholeGroup( Subgroup( G, [] ) ) );

############################################################################
##
#M LowIndexSubgroupsLpGroupIterator
##
InstallMethod( LowIndexSubgroupsLpGroupIterator,
  "for an LpGroup and two positive integers", true, 
  [ IsLpGroup, IsPosInt, IsPosInt ], 0,
  function( G, its, ind )
  local NextIT, IsDoneIT, ShallowCopyIT, filter, it, g;

  # initialization
  g := Source( EpimorphismFromFpGroup( G, its ) );

  NextIT := function( iter )
    local G, fam, U, IT;
    
    G := iter!.lpgrp;
    IT := iter!.fpiter;

    fam := ElementsFamily( FamilyObj( G ) );

    repeat 
      if IsDoneIterator( IT ) then break; fi;
      U := Subgroup( G, List( GeneratorsOfGroup( NextIterator( IT ) ),
            x -> ElementOfLpGroup( fam, UnderlyingElement( x ) ) ) );
      if  not ( U in iter!.lis ) then  return( U ); fi;
    until false;
    return( fail );
  end;

  IsDoneIT := function( iter )
   return( IsDoneIterator( iter!.fpiter ) );
  end;

  ShallowCopyIT := function( iter )
    return( rec( lpgrp  := iter!.lpgrp, 
                 lis    := iter!.lis,
                 fpiter := iter!.fpiter ) );
  end;


  filter := IsIteratorByFunctions and IsAttributeStoringRep and IsMutable;

  it := rec( NextIterator := NextIT, IsDoneIterator := IsDoneIT,
             ShallowCopy := ShallowCopyIT );

  it!.lpgrp := G;
  it!.lis := [];
  it!.fpiter := LowIndexSubgroupsFpGroupIterator( g, ind );

  return( Objectify( NewType( IteratorsFamily, filter ), it ) );
  end);
