#############################################################################
##
#W  construc.gi           GAP 4 package `ctbllib'               Thomas Breuer
##
#H  @(#)$Id: construc.gi,v 1.22 2011/02/11 16:04:44 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  1. Character Tables of Groups of Structure $M.G.A$
##  2. Character Tables of Groups of Structure $G.S_3$
##  3. Character Tables of Groups of Structure $G.2^2$
##  4. Character Tables of Groups of Structure $2^2.G$
##  5. Character Tables of Subdirect Products of Index Two
##  6. Brauer Tables of Extensions by $p$-regular Automorphisms
##  7. Construction Functions used in the Character Table Library
##  8. Character Tables of Coprime Central Extensions
##  9. Miscellaneous
##
Revision.( "ctbllib/gap4/construc_gi" ) :=
    "@(#)$Id: construc.gi,v 1.22 2011/02/11 16:04:44 gap Exp $";


#############################################################################
##
##  1. Character Tables of Groups of Structure $M.G.A$
##


#############################################################################
##
#F  IrreducibleCharactersOfTypeMGA( <tblMG>, <tblGA>, <Mclasses>, <MGAfusGA>,
#F                                  <orbs> )
##
##  <Mclasses> is assumed to be the set of classes in <tblMG> that are mapped
##  to the identity in the factor group $G$
##  that is a normal subgroup of <tblGA>;
##  note that the table of $G$ is not needed at all in the construction.
##
BindGlobal( "IrreducibleCharactersOfTypeMGA",
    function( tblMG, tblGA, Mclasses, MGAfusGA, orbs )
    local irr, a, zero, chi, ind, i;

    irr:= List( Irr( tblGA ), chi -> CompositionMaps( chi, MGAfusGA ) );
    a:= Size( tblGA ) * Sum( SizesConjugacyClasses( tblMG ){ Mclasses }, 0 )
                      / Size( tblMG );
    zero:= Zero( MGAfusGA );
    for chi in Irr( tblMG ) do
      if not IsSubset( ClassPositionsOfKernel( chi ), Mclasses ) then
        ind:= ShallowCopy( zero );
        for i in [ 1 .. Length( orbs ) ] do
          if IsBound( orbs[i] ) then
            ind[i]:= Sum( chi{ orbs[i] }, 0 ) * ( a / Length( orbs[i] ) );
          fi;
        od;
        if not ind in irr then
          Add( irr, ind );
        fi;
      fi;
    od;

    return irr;
    end );


#############################################################################
##
#F  PossibleCharacterTablesOfTypeMGA( <tblMG>, <tblG>, <tblGA>, <orbs>,
#F      <identifier> )
##
InstallGlobalFunction( PossibleCharacterTablesOfTypeMGA,
    function( tblMG, tblG, tblGA, orbs, identifier )
    local MGfusG,        # factor fusion map from `tblMG' onto `tblG'
          GfusGA,        # subgroup fusion map from `tblG' into `tblGA'
          tblMGA,        # record for the desired table
          MGfusMGA,      # subgroup fusion map from `tblMG' into `tblMGA'
          factouter,     # positions of classes of `tblGA' outside `tblG'
          MGAfusGA,      # factor fusion map from `tblMGA' onto `tblGA'
          inner,         # inner classes of `tblMGA'
          outer,         # outer classes of `tblMGA'
          nccl,          # class number of `tblMG'
          classes,       # class lengths of `tblMG'
          i,             # loop variable
          primes,        # prime divisors of the order of `tblMGA'
          invMGAfusGA,   # inverse of `MGAfusGA'
          p,             # loop variable
          GAmapp,        # `p'-th power map of `tblGA'
          orders,        # element orders of `tblMGA'
          suborders,     # element orders of `tblMG'
          outerorders,   # outer part of the orders
          gcd,           # g.c.d. of the orders of `M' and `A'
          matautos,      # matrix automorphisms of the irred. of `tblMGA'
          tblrecord,     # record of `tblMGA' (power maps perhaps ambiguous)
          info,          # list of possible tables
          newinfo,       # list of possible tables for the next step
          pair,          # loop variable
          pow,           # one possible power map
          newmatautos,   # automorphisms respecting one more power map
          newtblMGA,     # intermediate table with one more unique power map
          oldfus;

    # Check the arguments.
    if not ForAll( [ tblMG, tblG, tblGA ], IsOrdinaryTable ) then
      Error( "<tblG>, <tblMG>, <tblGA> must be ordinary character tables" );
    fi;

    # Fetch the stored fusions.
    MGfusG:= GetFusionMap( tblMG, tblG );
    GfusGA:= GetFusionMap( tblG, tblGA );
    if MGfusG = fail or GfusGA = fail then
      Error( "fusions <tblMG> -> <tblG>, <tblG> -> <tblGA> must be stored" );
    fi;

    # Initialize the table record `tblMGA' of $m.G.a$.
    tblMGA:= rec( UnderlyingCharacteristic := 0,
                  Identifier := identifier,
                  Size := Size( tblMG ) * Size( tblGA ) / Size( tblG ),
                  ComputedPowerMaps := [] );

    # The class fusion of `tblMG' into `tblMGA' is given by `orbs'.
    MGfusMGA:= InverseMap( orbs );

    # Determine the outer classes of `tblGA'.
    factouter:= Difference( [ 1 .. NrConjugacyClasses( tblGA ) ], GfusGA );

    # Compute the fusion of `tblMGA' onto `tblGA'.
    MGAfusGA:= CompositionMaps( GfusGA, CompositionMaps( MGfusG, orbs ) );
    Append( MGAfusGA, factouter );

    # Distinguish inner and outer classes of `tblMGA'.
    inner:= [ 1 .. Maximum( MGfusMGA ) ];
    outer:= [ Maximum( MGfusMGA ) + 1 .. Length( MGAfusGA ) ];
    nccl:= Length( inner ) + Length( outer );

    # Compute the class lengths of `tblMGA'.
    tblMGA.SizesConjugacyClasses:= Concatenation( Zero( inner ),
        ( Size( tblMG ) / Size( tblG ) )
          * SizesConjugacyClasses( tblGA ){ factouter } );
    classes:= SizesConjugacyClasses( tblMG );
    for i in inner do
      tblMGA.SizesConjugacyClasses[i]:= Sum( classes{ orbs[i] } );
    od;

    # Compute the centralizer orders of `tblMGA'.
    tblMGA.SizesCentralizers:= List( tblMGA.SizesConjugacyClasses,
                                     x -> tblMGA.Size / x );

    # Compute the irreducible characters of `tblMGA'.
    tblMGA.Irr:= IrreducibleCharactersOfTypeMGA( tblMG, tblGA,
                     ClassPositionsOfKernel( MGfusG ), MGAfusGA, orbs );

    # Compute approximations for power maps of `tblMGA'.
    # (All $p$-th power maps for $p$ coprime to $|A|$ are uniquely
    # determined this way, since inner and outer part are kept separately.)
#T We know more:
#T If |A| is a prime and does not divide |M| then the action is
#T semiregular; we have a unique fixed point for any element in N
#T that has a p-th root outside N.
    primes:= Set( Factors( tblMGA.Size ) );
    invMGAfusGA:= InverseMap( MGAfusGA );

    for p in primes do

      # inner part: Transfer the map from `tblMG' to `tblMGA'.
      tblMGA.ComputedPowerMaps[p]:= CompositionMaps( MGfusMGA,
           CompositionMaps( PowerMap( tblMG, p ), orbs ) );

      # outer part: Use the map of `tblGA' for an approximation.
      GAmapp:= PowerMap( tblGA, p );
      for i in outer do
        tblMGA.ComputedPowerMaps[p][i]:=
            invMGAfusGA[ GAmapp[ MGAfusGA[i] ] ];
      od;

    od;

    # Enter the element orders.
    # (If $|A|$ and $|M|$ are coprime then the orders of outer elements
    # are uniquely determined; otherwise there may be ambiguities.)
    orders:= [];
    suborders:= OrdersClassRepresentatives( tblMG );
    for i in [ 1 .. Length( MGfusMGA ) ] do
      orders[ MGfusMGA[i] ]:= suborders[i];
    od;
    outerorders:= OrdersClassRepresentatives( tblGA ){ factouter };
    gcd:= Gcd( Size( tblMG ), Size( tblGA ) ) / Size( tblG );
    if gcd <> 1 then
      gcd:= DivisorsInt( gcd );
      outerorders:= List( outerorders, x -> gcd * x );
    fi;
    tblMGA.OrdersClassRepresentatives:= Concatenation( orders, outerorders );

    # Compute the automorphisms of the matrix of characters.
    if gcd = 1 then
      matautos:= [ tblMGA.SizesCentralizers,
                   tblMGA.OrdersClassRepresentatives ];
    else
      matautos:= [ tblMGA.SizesCentralizers ];
    fi;
    matautos:= MatrixAutomorphisms( tblMGA.Irr, matautos,
                   GroupByGenerators( [], () ) );

    # Convert the record to a character table object.
    # (Keep a record for the case that we need copies later.)
    tblrecord:= ShallowCopy( tblMGA );
    Unbind( tblrecord.ComputedPowerMaps );
    ConvertToCharacterTableNC( tblMGA );

    # Test and improve the (perhaps ambiguous) power maps
    # (and update the automorphisms if necessary) using characters.
    # Whenever several $p$-th power maps are possible then we branch,
    # so we end up with a list of possible character tables.
    info:= [ [ tblMGA, matautos ] ];
    for p in primes do

      newinfo:= [];
      for pair in info do
        tblMGA:= pair[1];
        matautos:= pair[2];
        pow:= ComputedPowerMaps( tblMGA )[p];
        pow:= PossiblePowerMaps( tblMGA, p, rec( powermap:= pow ) );
        if not IsEmpty( pow ) then

          # Consider representatives up to matrix automorphisms.
          for pow in RepresentativesPowerMaps( pow, matautos ) do
            newmatautos:= SubgroupProperty( matautos,
                       perm -> ForAll( [ 1 .. nccl ],
                                   i -> pow[ i^perm ] = pow[i]^perm ),
                       TrivialSubgroup( matautos ),
                       TrivialSubgroup( matautos ) );
            newtblMGA:= ConvertToLibraryCharacterTableNC(
                            ShallowCopy( tblrecord ) );
            SetComputedPowerMaps( newtblMGA,
                StructuralCopy( ComputedPowerMaps( tblMGA ) ) );
            ComputedPowerMaps( newtblMGA )[p]:= pow;
            Add( newinfo, [ newtblMGA, newmatautos ] );
          od;

        fi;
      od;

      # Hand over the list for the next step.
      info:= newinfo;

    od;

    # Here we have the final list of tables.
    for pair in info do

      tblMGA:= pair[1];
      SetAutomorphismsOfTable( tblMGA, pair[2] );
      StoreFusion( tblMGA, MGAfusGA, tblGA );
      oldfus:= ShallowCopy( ComputedClassFusions( tblMG ) );
      StoreFusion( tblMG, MGfusMGA, tblMGA );
      SetConstructionInfoCharacterTable( tblMGA,
          ConstructMGAInfo( tblMGA, tblMG, tblGA ) );
      if Length( oldfus ) < Length( ComputedClassFusions( tblMG ) ) then
        Unbind( ComputedClassFusions( tblMG )[
                    Length( ComputedClassFusions( tblMG ) ) ] );
      fi;
      SetInfoText( tblMGA,
          "constructed using `PossibleCharacterTablesOfTypeMGA'" );

      # Store the unique element orders if necessary.
      if gcd <> 1 then
        ResetFilterObj( tblMGA, HasOrdersClassRepresentatives );
        SetOrdersClassRepresentatives( tblMGA,
            ElementOrdersPowerMap( ComputedPowerMaps( tblMGA ) ) );
      fi;

    od;

    # Return the result list.
    return List( info, pair -> rec( table    := pair[1],
                                    MGfusMGA := MGfusMGA ) );
end );


#############################################################################
##
#F  BrauerTableOfTypeMGA( <modtblMG>, <modtblGA>, <ordtblMGA> )
##
InstallGlobalFunction( BrauerTableOfTypeMGA,
    function( modtblMG, modtblGA, ordtblMGA )
    local p, modtblMGA, MGfusMGA, MGAfusGA, orbs, i, kernel;

    # Fetch the underlying characteristic, and check the arguments.
    p:= UnderlyingCharacteristic( modtblMG );
    if UnderlyingCharacteristic( modtblGA ) <> p then
      Info( InfoCharacterTable, 1,
            "BrauerTableOfTypeMGA: UnderlyingCharacteristic values differ\n",
            "#I  for <modtblMG>, <modtblGA>" );
      return fail;
    elif not IsOrdinaryTable( ordtblMGA ) then
      Info( InfoCharacterTable, 1,
            "BrauerTableOfTypeMGA: <ordtblMGA> must be the ordinary table\n",
            "#I  of M.G.A" );
      return fail;
    fi;

    # We cannot assume that the ordinary table of `tblMGA' has the same
    # ordering of classes as is guaranteed for the table to be constructed.
    # (Consider the case of $M.G = 3.U.3$ and $G.A = U.6$, where the
    # outer classes of $U.2$ precede the outer classes of $U.3$.)
    modtblMGA:= CharacterTableRegular( ordtblMGA, p );

    # Compute the restriction of the action to the `p'-regular classes.
    MGfusMGA:= GetFusionMap( modtblMG, modtblMGA );
    if MGfusMGA = fail then
      Info( InfoCharacterTable, 1,
            "BrauerTableOfTypeMGA: the class fusion\n",
            "#I  OrdinaryCharacterTable( <modtblMG> ) -> <ordtblMGA> ",
            "must be stored" );
      return fail;
    fi;

    # Compute the irreducibles.
    MGAfusGA:= GetFusionMap( modtblMGA, modtblGA );
    orbs:= InverseMap( MGfusMGA );
    for i in [ 1 .. Length( orbs ) ] do
      if IsBound( orbs[i] ) and IsInt( orbs[i] ) then
        orbs[i]:= [ orbs[i] ];
      fi;
    od;
    kernel:= Filtered( [ 1 .. NrConjugacyClasses( modtblMG ) ],
                       i -> MGAfusGA[ MGfusMGA[i] ] = 1 );
    SetIrr( modtblMGA, List( IrreducibleCharactersOfTypeMGA( modtblMG, 
                                 modtblGA, kernel, MGAfusGA, orbs ),
                             x -> Character( modtblMGA, x ) ) );
    SetInfoText( modtblMGA, "constructed using `BrauerTableOfTypeMGA'" );

    # Return the result.
    return rec( table:= modtblMGA, MGfusMGA:= MGfusMGA );
end );


#############################################################################
##
#F  PossibleActionsForTypeMGA( <tblMG>, <tblG>, <tblGA> )
##
InstallGlobalFunction( PossibleActionsForTypeMGA,
    function( tblMG, tblG, tblGA )
    local tfustA,
          Mtfust,
          ker,
          index,
          inner,
          i,
          elms,
          cenMG,
          cenG,
          inv,
          factorbits,
          img,
          newelms,
          chars;

    # Check that the function is applicable.
    tfustA:= GetFusionMap( tblG, tblGA );
    if tfustA = fail then
      Error( "class fusion <tblG> -> <tblGA> must be stored on <tblG>" );
    fi;
    Mtfust:= GetFusionMap( tblMG, tblG );
    if Mtfust = fail then
      Error( "class fusion <tblMG> -> <tblG> must be stored on <tblMG>" );
    fi;
    index:= Size( tblGA ) / Size( tblG );
    if not IsPrimeInt( index ) then
      inner:= Set( tfustA );
      for i in Set( Factors( index ) ) do
        if ForAll( PowerMap( tblGA, index / i ), j -> j in inner ) then
          Error( "factor of <tblGA> by <tblG> must be cyclic" );
        fi;
      od;
    fi;

    # The automorphism must have order equal to the order of $A$.
    # We need to consider only one generator for each cyclic group of
    # the right order.
    elms:= Filtered( AsList( AutomorphismsOfTable( tblMG ) ),
                     x -> Order( x ) = index );
    elms:= Set( List( elms, SmallestGeneratorPerm ) );
    Info( InfoCharacterTable, 1,
          Length( elms ), " automorphism(s) of order ", index );

    # The automorphism respects the fusion of classes of $G$ into $G.A$.
    inv:= InverseMap( Mtfust );
    for i in [ 1 .. Length( inv ) ] do
      if IsInt( inv[i] ) then
        inv[i]:= [ inv[i] ];
      fi;
    od;
    factorbits:= Filtered( InverseMap( tfustA ), IsList );
    for i in [ 1 .. Length( inv ) ] do
      img:= First( factorbits, orb -> i in orb );
      if img = fail then
        img:= inv[i];
        newelms:= Filtered( elms, x -> OnSets( img, x ) = img );
      else
        img:= Union( inv{ Difference( img, [ i ] ) } );
        newelms:= Filtered( elms, x -> IsSubset( img, OnSets( inv[i], x ) ) );
      fi;
      if newelms <> elms then
        elms:= newelms;
        Info( InfoCharacterTable, 1,
              Length( elms ), " automorphism(s) mapping ",i," compatibly" );
      fi;
    od;

    # The automorphism must act semiregularly on those characters of $M.G$
    # that are not characters of $G$.
    # (Think of the case that the centres of $G$ and $M.G$ have orders
    # $2$ and $6$, respectively, and $A$ is of order $2$.)
    ker:= ClassPositionsOfKernel( Mtfust );
    chars:= Filtered( Irr( tblMG ),
                chi -> not IsSubset( ClassPositionsOfKernel( chi ), ker ) );
    elms:= Filtered( elms,
                     x -> Set( OrbitLengths( Group(x), chars, Permuted ) )
                          = [ index ] );
    Info( InfoCharacterTable, 1,
          Length( elms ), " automorphism(s) acting semiregularly" );

    # Form the orbits on the class positions.
    elms:= Set( List( elms, x -> Set( List( Orbits( Group(x),
                  [ 1 .. NrConjugacyClasses( tblMG ) ] ), Set ) ) ) );

    # Return the result.
    return elms;
end );


#############################################################################
##
#F  ConstructMGA( <tbl>, <subname>, <factname>, <plan>, <perm> )
##
InstallGlobalFunction( ConstructMGA,
    function( tbl, subname, factname, plan, perm )
    local factfus,  # factor fusion from `tbl' to `fact'
          subfus,   # subgroup fusion from `sub' to `tbl'
          proj,     # projection map of `subfus'
          irreds,   # list of irreducibles
          zero;     # list of zeros to be appended to the characters

    factfus  := First( tbl.ComputedClassFusions,
                       fus -> fus.name = factname ).map;
    factname := CharacterTableFromLibrary( factname );
    subname  := CharacterTableFromLibrary( subname );
    subfus   := First( ComputedClassFusions( subname ),
                       fus -> fus.name = tbl.Identifier ).map;
    proj    := ProjectionMap( subfus );
    irreds  := List( Irr( factname ),
                     x -> ValuesOfClassFunction( x ){ factfus } );
    zero    := Zero( [ Maximum( subfus ) + 1
                       .. Length( tbl.SizesCentralizers ) ] );
    Append( irreds, List( plan, entry ->
         Concatenation( Sum( Irr( subname ){ entry } ){ proj }, zero ) ) );
    tbl.Irr:= Permuted( irreds, perm );
end );


#############################################################################
##
##  2. Character Tables of Groups of Structure $G.S_3$
##


#############################################################################
##
#F  IrreducibleCharactersOfTypeGS3( <tbl>, <tblC>, <tblK>, <aut>,
#F     <tblfustblC>, <tblfustblK>, <tblCfustblKC>, <tblKfustblKC>, <outerC> )
##
BindGlobal( "IrreducibleCharactersOfTypeGS3",
    function( tbl, tblC, tblK, aut, tblfustblC, tblfustblK, tblCfustblKC,
              tblKfustblKC, outerC )
    local irreducibles,  # list of irreducible characters, result
          zero,          # zero vector on the classes of `tblC' \ `tbl'
          irrtbl,        # irreducible of `tbl'
          irrtblC,       # irreducible of `tblC'
          irrtblK,       # irreducible of `tblK'
          done,          # Boolean list, `true' for all processed characters
          outerKC,       # position of classes outside `tblK'
          k,             # order of the factor `tblK / tbl'
          c,             # order of the factor `tblC / tbl'
          p,             # characteristic of `tbl'
          r,             # ramification index
          i,             # loop over the irreducibles of `tblK'
          chi,           # currently processed character of `tblK'
          img,           # image of `chi' under `aut'
          rest,          # restriction of `chi' to `tbl' (via `tblfustblK')
          e,             # current ramification
          const,         # irreducible constituents of `rest'
          ext,           # extensions of an extendible constituent to `tblC'
          chitilde,      # one extension
          irr,           # one irreducible character
          j,             # loop over the classes of `tblK'
          sum;           # an induced character

    # Initializations.
    irreducibles:= [];
    zero:= 0 * outerC;
    irrtbl:= Irr( tbl );
    irrtblC:= Irr( tblC );
    irrtblK:= Irr( tblK );
    done:= BlistList( [ 1 .. Length( irrtblK ) ], [] );
    outerKC:= tblCfustblKC{ outerC };
    k:= Size( tblK ) / Size( tbl );
    c:= Size( tblC ) / Size( tbl );
    p:= UnderlyingCharacteristic( tbl );

    r:= RootInt( k );
    if r^2 <> k then
      r:= 1;
    fi;

    # Loop over the irreducibles of `tblK'.
    for i in [ 1 .. Length( irrtblK ) ] do
      if not done[i] then

        done[i]:= true;
        chi:= irrtblK[i];
        img:= Permuted( chi, aut );

        if img = chi then

          # `chi' extends.
          rest:= chi{ tblfustblK };
          e:= 1;
          if rest in irrtbl then
            # `rest' is invariant in `tblKC', so we take the values
            # of its extensions to `tblC' on the outer classes.
            const:= [ rest ];
          elif r <> 1 and rest / r in irrtbl then
            # `rest' is a multiple of an irreducible character of `tbl'.
            const:= [ rest / r ];
            e:= r;
          else
            # `rest' is a sum of `k' irreducibles of `tbl';
            # exactly one of them is fixed under the action of `tblC',
            # so we take the values of the extensions of this constituent
            # on the outer classes.
            const:= Filtered( irrtbl,
                        x -> x[1] = rest[1] / k and
                          Induced( tbl, tblK, [ x ], tblfustblK )[1] = chi );
            Assert( 1, Length( const ) = k,
                    "Strange number of constituents.\n" );
          fi;
          ext:= Filtered( irrtblC, x ->     x[1] = const[1][1]
                                        and x{ tblfustblC } in const );
          Assert( 1, ( p = c and Length( ext ) = 1 ) or
                     ( p <> c and Length( ext ) = c ),
                  "Extendible constituent is not unique.\n" );
          # We can handle only a few cases where $e \not= 1$:
          if   e <> 1 and e = c - 1 then
            # If $e = |C|-1$ then sum up all except one extension.
            ext:= List( ext, x -> Sum( ext ) - x );
          elif e <> 1 and e = c + 1 then
            # If $e = |C|+1$ then sum up all plus one extension.
            ext:= List( ext, x -> Sum( ext ) + x );
          elif e <> 1 then
            Error( "cannot handle a case where <e> > 1" );
          fi;
          for chitilde in ext do
            irr:= [];
            for j in [ 1 .. Length( tblKfustblKC ) ] do
              irr[ tblKfustblKC[j] ]:= chi[j];
            od;
            irr{ outerKC }:= chitilde{ outerC };
            Add( irreducibles, irr );
          od;

        else

          # `chi' induces irreducibly.
          irr:= [];
          done[ Position( irrtblK, img ) ]:= true;
          sum:= chi + img;
          for j in [ 3 .. c ] do
            img:= Permuted( img, aut );
            done[ Position( irrtblK, img ) ]:= true;
            sum:= sum + img;
          od;
          for j in [ 1 .. Length( tblKfustblKC ) ] do
            irr[ tblKfustblKC[j] ]:= sum[j];
          od;
          irr{ outerKC }:= zero;
          Add( irreducibles, irr );

        fi;

      fi;
    od;

    # Return the result.
    Assert( 1, Length( irreducibles ) = Length( irreducibles[1] ),
            Concatenation( "Not all irreducibles found (have ",
                String( Length( irreducibles ) ), " of ",
                String( Length( irreducibles[1] ) ), ")\n" ) );
    return irreducibles;
end );


#############################################################################
##
#F  CharacterTableOfTypeGS3( <tbl>, <tblC>, <tblK>, <aut>, <identifier> )
#F  CharacterTableOfTypeGS3( <modtbl>, <modtblC>, <modtblK>, <ordtblKC>,
#F                           <identifier> )
##
InstallGlobalFunction( CharacterTableOfTypeGS3,
    function( tbl, tblC, tblK, aut, identifier )
    local p,             # prime integer
          tblfustblC,    # class fusion from `tbl' into `tblC'
          tblfustblK,    # class fusion from `tbl' into `tblK'
          tblKfustblKC,  # class fusion from `tblK' into the desired table
          tblCfustblKC,  # class fusion from `tblC' into the desired table
          outer,         # positions of the classes of `tblC' \ `tbl'
          i,
          tblKC,
          classes,
          subclasses,
          k,
          orders,
          suborders,
          powermap,
          pow,
          oldfusC,
          oldfusK;

    # Fetch the underlying characteristic, and check the arguments.
    p:= UnderlyingCharacteristic( tbl );
    if    UnderlyingCharacteristic( tblC ) <> p
       or UnderlyingCharacteristic( tblK ) <> p then
      Error( "UnderlyingCharacteristic values differ for <tbl>, <tblC>, ",
             "<tblK>" );
    elif 0 < p and not IsOrdinaryTable( aut ) then
      Error( "enter the ordinary table of G.KC as the fourth argument" );
    elif 0 = p and not IsPerm( aut ) then
      Error( "enter a permutation as the fourth argument" );
    fi;

    # Fetch the stored fusions from `tbl'.
    tblfustblC:= GetFusionMap( tbl, tblC );
    tblfustblK:= GetFusionMap( tbl, tblK );
    if tblfustblC = fail or tblfustblK = fail then
      Error( "fusions <tbl> -> <tblC>, <tbl> -> <tblK> must be stored" );
    fi;
    outer:= Difference( [ 1 .. NrConjugacyClasses( tblC ) ], tblfustblC );

    if 0 < p then

      # We assume that the ordinary table of `tblKC' (given as the argument
      # `aut') has the same ordering of classes as is guaranteed for the
      # table to be constructed.
      tblKC:= CharacterTableRegular( aut, p );

      # Compute the restriction of the action to the `p'-regular classes.
      tblKfustblKC:= GetFusionMap( tblK, tblKC );
      if tblKfustblKC = fail then
        Error( "fusion <tblK> -> <tblKC> must be stored" );
      fi;
      aut:= Product( List( Filtered( InverseMap( tblKfustblKC ), IsList ),
                           x -> MappingPermListList( x,
                                    Concatenation( x{ [ 2 .. Length(x) ] },
                                                   [ x[1] ] ) ) ),
                     () );

      # Fetch fusions for the result.
      tblKfustblKC:= GetFusionMap( tblK, tblKC );
      tblCfustblKC:= GetFusionMap( tblC, tblKC );

    else

      # Compute the needed fusions into `tblKC'.
      tblKfustblKC:= InverseMap( Set( Orbits( Group( aut ),
                         [ 1 .. NrConjugacyClasses( tblK ) ] ) ) );
      tblCfustblKC:= CompositionMaps( tblKfustblKC,
          CompositionMaps( tblfustblK, InverseMap( tblfustblC ) ) );
      tblCfustblKC{ outer }:= [ 1 .. Length( outer ) ]
                              + Maximum( tblKfustblKC );

      # Initialize the record for the character table `tblKC'.
      tblKC:= rec( UnderlyingCharacteristic := 0,
                   Identifier := identifier,
                   Size := Size( tblK ) * Size( tblC ) / Size( tbl ) );

      # Compute class lengths and centralizer orders.
      classes:= ListWithIdenticalEntries( Maximum( tblCfustblKC ), 0 );
      subclasses:= SizesConjugacyClasses( tblK );
      for i in [ 1 .. Length( subclasses) ] do
        classes[ tblKfustblKC[i] ]:= classes[ tblKfustblKC[i] ]
                                     + subclasses[i];
      od;
      subclasses:= SizesConjugacyClasses( tblC );
      k:= Size( tblK ) / Size( tbl );
      for i in outer do
        classes[ tblCfustblKC[i] ]:= classes[ tblCfustblKC[i] ]
                                     + k * subclasses[i];
      od;
      tblKC.SizesConjugacyClasses:= classes;
      tblKC.SizesCentralizers:= List( classes, x -> tblKC.Size / x );

      # Compute element orders.
      orders:= [];
      suborders:= OrdersClassRepresentatives( tblK );
      for i in [ 1 .. Length( tblKfustblKC ) ] do
        orders[ tblKfustblKC[i] ]:= suborders[i];
      od;
      suborders:= OrdersClassRepresentatives( tblC );
      for i in outer do
        orders[ tblCfustblKC[i] ]:= suborders[i];
      od;
      tblKC.OrdersClassRepresentatives:= orders;

      # Convert the record to a table object.
      ConvertToLibraryCharacterTableNC( tblKC );

      # Put the power maps together.
      powermap:= ComputedPowerMaps( tblKC );
      for p in Set( Factors( Size( tblKC ) ) ) do
        pow:= InitPowerMap( tblKC, p );
        TransferDiagram( PowerMap( tblC, p ), tblCfustblKC, pow );
        TransferDiagram( PowerMap( tblK, p ), tblKfustblKC, pow );
        powermap[p]:= pow;
        Assert( 1, ForAll( pow, IsInt ),
                Concatenation( Ordinal( p ),
                               " power map not uniquely determined" ) );
      od;

    fi;

    # Compute the irreducibles.
    SetIrr( tblKC,
            List( IrreducibleCharactersOfTypeGS3( tbl, tblC, tblK, aut,
                      tblfustblC, tblfustblK, tblCfustblKC, tblKfustblKC,
                      outer ),
                  chi -> Character( tblKC, chi ) ) );

    if IsOrdinaryTable( tblKC ) then
      oldfusC:= ShallowCopy( ComputedClassFusions( tblC ) );
      StoreFusion( tblC, tblCfustblKC, tblKC );
      oldfusK:= ShallowCopy( ComputedClassFusions( tblK ) );
      StoreFusion( tblK, tblKfustblKC, tblKC );
      SetConstructionInfoCharacterTable( tblKC,
          ConstructGS3Info( tblC, tblK, tblKC ).list );
      if Length( oldfusC ) < Length( ComputedClassFusions( tblC ) ) then
        Unbind( ComputedClassFusions( tblC )[
                    Length( ComputedClassFusions( tblC ) ) ] );
      fi;
      if Length( oldfusK ) < Length( ComputedClassFusions( tblK ) ) then
        Unbind( ComputedClassFusions( tblK )[
                    Length( ComputedClassFusions( tblK ) ) ] );
      fi;
    fi;
    SetInfoText( tblKC, "constructed using `CharacterTableOfTypeGS3'" );

    # Return the result.
    return rec( table        := tblKC,
                tblCfustblKC := tblCfustblKC,
                tblKfustblKC := tblKfustblKC );
end );


#############################################################################
##
#F  PossibleActionsForTypeGS3( <tbl>, <tblC>, <tbl3> )
##
#T If the two stored fusions are not compatible then we get no solution.
#T So do we need a function that computes also compatible fusions if
#T necessary?
#T (The condition is that the orbits on the classes of <tbl> describe an
#T action of S_3.)
##
InstallGlobalFunction( PossibleActionsForTypeGS3, function( tbl, tblC, tblK )
    local tfustC, tfustK, c, elms, inner, linK, i, vals, c1, c2, newelms,
          inv, orbs, orb;

    # Check that the function is applicable.
    tfustC:= GetFusionMap( tbl, tblC );
    if tfustC = fail then
      Error( "class fusion <tbl> -> <tblC> must be stored on <tbl>" );
    fi;
    tfustK:= GetFusionMap( tbl, tblK );
    if tfustK = fail then
      Error( "class fusion <tbl> -> <tblK> must be stored on <tbl>" );
    fi;

    # The automorphism must have order `c'.
    c:= Size( tblC ) / Size( tbl );
    elms:= Filtered( AsList( AutomorphismsOfTable( tblK ) ),
                     x -> Order( x ) = c );
    Info( InfoCharacterTable, 1,
          Length( elms ), " automorphism(s) of order ", c );
    if Length( elms ) <= 1 then
      return elms;
    fi;

    # The automorphism must permute the outer cosets of `tblK'.
    inner:= Set( tfustK );
    linK:= Filtered( Irr( tblK ),
               chi -> IsSubset( ClassPositionsOfKernel( chi ), inner ) );
    linK:= Difference( linK, [ TrivialCharacter( tblK ) ] );
    elms:= Filtered( elms, x -> Permuted( linK[1], x ) = linK[2] );
    Info( InfoCharacterTable, 1,
          Length( elms ), " automorphism(s) permuting the cosets" );
    if Length( elms ) <= 1 then
      return elms;
    fi;

    # The automorphism respects the fusion of classes of `tbl' into `tblC'.
    for i in InverseMap( tfustC ) do
      if IsList( i ) then
        vals:= SortedList( tfustK{ i } );
        c1:= vals[1];
        c2:= vals[2];
        if c1 <> c2 then
          RemoveSet( vals, c1 );
          newelms:= Filtered( elms, x -> c1^x in vals );
          if newelms <> elms then
            elms:= newelms;
            Info( InfoCharacterTable, 1,
                  Length( elms ), " automorphism(s) fusing ", c1, " and ",
                  c2 );
            if Length( elms ) <= 1 then
              return elms;
            fi;
          fi;
        fi;
      fi;
    od;

    # Two inner classes that are not fused in `tblC'
    # cannot be conjugate in `tKC'.
    # (Note that the centralizer order in `tblC' is `c' times larger than
    # in `tbl', and this extra factor does not occur in the centralizer
    # order in `tblK'.)
    inv:= InverseMap( tfustK );
    orbs:= Union( List( elms, i -> Filtered( Orbits( Group( i ), inner ),
                                              orb -> Length( orb ) = c ) ) );
    orbs:= Filtered( orbs,
               x -> ( ForAll( inv{ x }, IsInt )
                      and Number( Set( tfustC{ inv{ x } } ) ) > 1 )
                 or ( ForAll( inv{ x }, IsList )
                      and ForAny( inv[ x[1] ],
                            y -> SizesCentralizers( tbl )[y]
                              < SizesCentralizers( tblC )[ tfustC[y] ] ) ) );
    for orb in orbs do
      c1:= orb[1];
      c2:= orb[2];
      newelms:= Filtered( elms, x -> c1^x <> c2 );
      if newelms <> elms then
        elms:= newelms;
        Info( InfoCharacterTable, 1,
              Length( elms ),
              " automorphism(s) not fusing ", c1, " and ", c2 );
        if Length( elms ) <= 1 then
          return elms;
        fi;
      fi;
    od;

    # Return the result.
    return elms;
end );


#############################################################################
##
##  3. Character Tables of Groups of Structure $G.2^2$
##


#############################################################################
##
#F  PossibleActionsForTypeGV4( <tblG>, <tblsG2> )
##
InstallGlobalFunction( PossibleActionsForTypeGV4,
    function( tblG, tblsG2 )
    local tfust2, perms, i, j, k, elms, fixedinG, domains, triples, elm,
          comp, nccl, filt2, filt3;

    # Check that the function is applicable.
    tfust2:= List( tblsG2, t2 -> GetFusionMap( tblG, t2 ) );
    if fail in tfust2 then
      Error( "class fusions <tblG> -> <tblsG2> must be stored on <tblG>" );
    fi;

    # For computing compatible actions on the tables in `tblsG2',
    # we rearrange these tables such that the fusions are sorted.
    perms:= [];
    for i in [ 1 .. 3 ] do
      perms[i]:= [];
      j:= 1;
      for k in [ 1 .. Length( tfust2[i] ) ] do
        if not IsBound( perms[i][ tfust2[i][k] ] ) then
          perms[i][ tfust2[i][k] ]:= j;
          j:= j+1;
        fi;
      od;
      for k in [ 1 .. NrConjugacyClasses( tblsG2[i] ) ] do
        if not IsBound( perms[i][k] ) then
          perms[i][k]:= j;
          j:= j+1;
        fi;
      od;
    od;
    perms:= List( perms, PermList );
    tfust2:= List( [ 1 .. 3 ], i -> OnTuples( tfust2[i], perms[i] ) );

    # The automorphisms must have order at most 2.
    elms:= List( tblsG2, t -> Filtered( AsList( AutomorphismsOfTable( t ) ),
                     x -> Order( x ) <= 2 ) );
    Info( InfoCharacterTable, 1,
          Product( List( elms, Length ) ),
          " triple(s) of automorphisms of order <= 2" );

    # Two classes of $G$ that are not conjugate in any $G.2_i$
    # are not conjugate in $G.2^2$.
    # (By the compatibility, we need to test nonconjugacy only in $G.2_1$.)
    fixedinG:= Intersection( List( tfust2,
                   x -> Filtered( InverseMap( x ), IsInt ) ) );
    elms[1]:= Filtered( elms[1],
                        x -> ForAll( tfust2[1]{ fixedinG },
                                     p -> p^( x^perms[1] ) = p ) );
    Info( InfoCharacterTable, 1,
          Product( List( elms, Length ) ),
          " triple(s) of automorphisms respecting inner classes" );

    # The automorphisms must act compatibly on `tblG', and
    # they must result in the same number of classes for $G.2^2$.
    # (Note that the class number corresponds to the number of cycles.)
    domains:= List( tblsG2, t -> [ 1 .. NrConjugacyClasses( t ) ] );
    triples:= [];
    for elm in elms[1] do
      comp:= CompositionMaps( InverseMap(
                 OrbitsPerms( [ elm^perms[1] ], domains[1] ) ), tfust2[1] );
      nccl:= 2 * NrConjugacyClasses( tblsG2[1] )
             - 3 * NrMovedPointsPerm( elm ) / 2;
      filt2:= Filtered( elms[2], x -> comp = CompositionMaps(
                     InverseMap( OrbitsPerms( [ x^perms[2] ], domains[2] ) ),
                     tfust2[2] )
                  and nccl = 2 * NrConjugacyClasses( tblsG2[2] )
                             - 3 * NrMovedPointsPerm( x ) / 2 );
      filt3:= Filtered( elms[3], x -> comp = CompositionMaps(
                     InverseMap( OrbitsPerms( [ x^perms[3] ], domains[3] ) ),
                     tfust2[3] )
                  and nccl = 2 * NrConjugacyClasses( tblsG2[3] )
                             - 3 * NrMovedPointsPerm( x ) / 2 );
      Append( triples, Cartesian( [ elm ], filt2, filt3 ) );
    od;
    Info( InfoCharacterTable, 1,
          Length( triples ),
          " triple(s) of automorphisms acting compatibly" );

    # Return the result.
    return triples;
end );


#############################################################################
##
#F  PossibleCharacterTablesOfTypeGV4( <tblG>, <tblsG2>, <acts>, <identifier>
#F                                    [, <tblGfustblsG2>] )
#F  PossibleCharacterTablesOfTypeGV4( <modtblG>, <modtblsG2>, <ordtblGV4> )
##
InstallGlobalFunction( PossibleCharacterTablesOfTypeGV4,
    function( arg )
    local tblG, tblsG2, ordtblGV4, GfusG2, acts, identifier, char, tblGV4,
          G2fusGV4, classes, cosets, G2fusGV4outer, i, k, tblfusordtbl, rest,
          defectzero, intrest, G2fusGV4inner, ncclinner, tblrec,
          subclasses, orders, suborders, map, powermap, p, pow, irr, ind,
          indirr, triv, done, bad, num2, ext, numinv, poss1, poss2, chi,
          todo, minus, nexttodo, poss, j;

    # Get and check the arguments.
    if   Length( arg ) = 3 and
       IsBrauerTable( arg[1] ) and IsList( arg[2] )
       and IsOrdinaryTable( arg[3] ) then
      tblG       := arg[1];
      tblsG2     := arg[2];
      ordtblGV4  := arg[3];
      GfusG2     := List( tblsG2, t -> GetFusionMap( tblG, t ) );
    elif Length( arg ) = 4 and
       IsOrdinaryTable( arg[1] ) and IsList( arg[2] ) and IsList( arg[3] )
       and IsString( arg[4] ) then
      tblG       := arg[1];
      tblsG2     := arg[2];
      acts       := arg[3];
      identifier := arg[4];
      GfusG2     := List( tblsG2, t -> GetFusionMap( tblG, t ) );
    elif Length( arg ) = 5 and
       IsCharacterTable( arg[1] ) and IsList( arg[2] ) and IsList( arg[3] )
       and IsString( arg[4] ) and IsList( arg[5] ) then
      tblG       := arg[1];
      tblsG2     := arg[2];
      acts       := arg[3];
      identifier := arg[4];
      GfusG2     := arg[5];
    else
      Error( "usage: PossibleCharacterTablesOfTypeGV4( <tlbG>, <tblsG2>, ",
             "<acts>, <identifier>[, <fusions>] ) or\n",
             "PossibleCharacterTablesOfTypeGV4( <modtlbG>, <modtblsG2>, ",
             "<ordtblGV4> )" );
    fi;

    if fail in GfusG2 then
      Error( "the class fusions <tblG> -> <tblsG2> must be stored" );
    fi;

    # Fetch the underlying characteristic.
    char:= UnderlyingCharacteristic( tblG );

    if 0 < char then

      # We assume that the ordinary table of `tblGV4' (given as an argument)
      # has the same ordering of classes as is guaranteed for the
      # table to be constructed.
      tblGV4:= CharacterTableRegular( ordtblGV4, char );

      # Fetch the three fusions.
      G2fusGV4:= List( tblsG2, t -> GetFusionMap( t, tblGV4 ) );
      if fail in G2fusGV4 then
        Error( "fusions <tblsG2> -> <tblGV4> must be stored" );
      fi;

      acts:= List( G2fusGV4,
                map -> Product( List( Filtered( InverseMap( map ), IsList ),
                                pair -> ( pair[1], pair[2] ) ), () ) );
      classes:= ShallowCopy( SizesConjugacyClasses( tblGV4 ) );
      cosets:= Intersection( G2fusGV4 );
      cosets:= List( G2fusGV4, map -> Difference( map, cosets ) );
      G2fusGV4outer:= List( G2fusGV4, ShallowCopy );
      for i in [ 1 .. 3 ] do
        for k in GfusG2[i] do
          Unbind( G2fusGV4outer[i][k] );
        od;
      od;

      # We will use that defect zero characters must occur.
      tblfusordtbl:= GetFusionMap( tblGV4, ordtblGV4 );
      rest:= List( Irr( ordtblGV4 ), x -> x{ tblfusordtbl } );
      defectzero:= Filtered( rest, x -> Size( tblGV4 ) / x[1] mod char <> 0 );
      intrest:= IntegralizedMat( rest );

    else

      if not ( Length( acts ) = 3 and ForAll( acts, IsPerm ) ) then
        Error( "<acts> must contain three permutations" );
      fi;

      # Construct the three fusions into $G.2^2$, via the three embeddings.
      # The classes of $G$ come first in each map; note that we must choose
      # the classes of $G$ compatibly in all three maps.
      G2fusGV4inner:= [];
      G2fusGV4inner[1]:= InverseMap( Set( Orbits( Group( acts[1] ),
          Set( GfusG2[1] ) ) ) );
      G2fusGV4inner[2]:= CompositionMaps( G2fusGV4inner[1],
          CompositionMaps( GfusG2[1], InverseMap( GfusG2[2] ) ) );
      G2fusGV4inner[3]:= CompositionMaps( G2fusGV4inner[1],
          CompositionMaps( GfusG2[1], InverseMap( GfusG2[3] ) ) );
      ncclinner:= Maximum( G2fusGV4inner[1] );

      G2fusGV4outer:= [];
      G2fusGV4outer[1]:= InverseMap( Set( Orbits( Group( acts[1] ),
          Difference( [ 1 .. NrConjugacyClasses( tblsG2[1] ) ],
              Set( GfusG2[1] ) ) ) ) ) + ncclinner;
      G2fusGV4outer[2]:= InverseMap( Set( Orbits( Group( acts[2] ),
          Difference( [ 1 .. NrConjugacyClasses( tblsG2[2] ) ],
              Set( GfusG2[2] ) ) ) ) ) + Maximum( G2fusGV4outer[1] );
      G2fusGV4outer[3]:= InverseMap( Set( Orbits( Group( acts[3] ),
          Difference( [ 1 .. NrConjugacyClasses( tblsG2[3] ) ],
              Set( GfusG2[3] ) ) ) ) ) + Maximum( G2fusGV4outer[2] );

      cosets:= List( G2fusGV4outer, Set );

      # Initialize the record for the character table `tblGV4'.
      tblrec:= rec( UnderlyingCharacteristic := 0,
                    Identifier               := identifier,
                    Size                     := 4 * Size( tblG ) );

      # Compute class lengths, centralizer orders, and element orders.
      G2fusGV4:= G2fusGV4inner + G2fusGV4outer;
      classes:= ListWithIdenticalEntries( Maximum( G2fusGV4[3] ), 0 );
      subclasses:= SizesConjugacyClasses( tblsG2[1] );
      orders:= [];
      suborders:= OrdersClassRepresentatives( tblsG2[1] );
      for i in [ 1 .. Length( G2fusGV4inner[1] ) ] do
        if IsBound( G2fusGV4inner[1][i] ) then
          classes[ G2fusGV4inner[1][i] ]:= classes[ G2fusGV4inner[1][i] ]
                                           + subclasses[i];
          orders[ G2fusGV4inner[1][i] ]:= suborders[i];
        fi;
      od;
      for k in [ 1 .. 3 ] do
        subclasses:= SizesConjugacyClasses( tblsG2[k] );
        suborders:= OrdersClassRepresentatives( tblsG2[k] );
        map:= G2fusGV4outer[k];
        for i in [ 1 .. Length( map ) ] do
          if IsBound( map[i] ) then
            classes[ map[i] ]:= classes[ map[i] ] + subclasses[i];
            orders[ map[i] ]:= suborders[i];
          fi;
        od;
      od;
      tblrec.SizesConjugacyClasses:= classes;
      tblrec.SizesCentralizers:= List( classes, x -> tblrec.Size / x );
      tblrec.OrdersClassRepresentatives:= orders;

      # Convert the record to a table object.
      tblGV4:= ConvertToCharacterTableNC( ShallowCopy( tblrec ) );

      # Put the power maps together.
      powermap:= ComputedPowerMaps( tblGV4 );
      for p in Set( Factors( Size( tblGV4 ) ) ) do
        pow:= InitPowerMap( tblGV4, p );
        for k in [ 1 .. 3 ] do
          TransferDiagram( PowerMap( tblsG2[k], p ), G2fusGV4[k], pow );
        od;
        powermap[p]:= pow;
        Assert( 1, ForAll( pow, IsInt ),
                Concatenation( Ordinal( p ),
                               " power map not uniquely determined" ) );
      od;
      tblrec.ComputedPowerMaps:= ComputedPowerMaps( tblGV4 );

    fi;

    # Compute the irreducibles, starting from the irreducibles of $G$.
    # First we compute the known extensions of the trivial character,
    # then add the characters which are induced from some table in `tblsG2',
    # then try to determine the extensions of the remaining characters.
    irr:= List( Irr( tblG ), ValuesOfClassFunction );
    ind:= List( tblsG2, t -> Induced( tblG, t, irr ) );
    indirr:= List( [ 1 .. NrConjugacyClasses( tblG ) ],
                   k -> List( [ 1 .. 3 ],
                              i -> ind[i][k] in Irr( tblsG2[i] ) ) );
    irr:= [];
    triv:= Position( Irr( tblG ), TrivialCharacter( tblG ) );

    if char = 2 then
      irr[ triv ]:= [ 0 * classes + 1 ];
    else
      irr[ triv ]:= List( [ 1 .. 4 ], i -> 0 * classes + 1 );
      irr[ triv ][3]{ cosets[1] }:= 0 * cosets[1] - 1;
      irr[ triv ][4]{ cosets[1] }:= 0 * cosets[1] - 1;
      irr[ triv ][2]{ cosets[2] }:= 0 * cosets[2] - 1;
      irr[ triv ][4]{ cosets[2] }:= 0 * cosets[2] - 1;
      irr[ triv ][2]{ cosets[3] }:= 0 * cosets[3] - 1;
      irr[ triv ][3]{ cosets[3] }:= 0 * cosets[3] - 1;
    fi;

    done:= [ triv ];
    bad:= [];
    for i in [ 1 .. NrConjugacyClasses( tblG ) ] do
      if not i in done then
        num2:= Number( indirr[i], x -> x = false );
        if   num2 = 2 then
          # This cannot happen, so the actions must be wrong.
          Info( InfoCharacterTable, 1,
                "PossibleCharacterTablesOfTypeGV4: contradiction, ",
                "imposs. inertia subgroup" );
          return [];
        elif num2 = 0 then
          # The character has inertia subgroup $G$.
          irr[i]:= Induced( tblsG2[1], tblGV4, [ ind[1][i] ], G2fusGV4[1] );
          AddSet( done, i );
          AddSet( done, Position( ind[1], ind[1][i], i ) );
          AddSet( done, Position( ind[2], ind[2][i], i ) );
          AddSet( done, Position( ind[3], ind[3][i], i ) );
        elif num2 = 1 then
          # The character has inertia subgroup one of the $G.2_k$.
          k:= Position( indirr[i], false );
          ext:= Filtered( Irr( tblsG2[k] ),
                    x -> x{ GfusG2[k] } = Irr( tblG )[i] );
          irr[i]:= Induced( tblsG2[k], tblGV4, ext, G2fusGV4[k] );
          k:= ( ( k+1 ) mod 3 ) + 1;
          AddSet( done, i );
          AddSet( done, Position( ind[k], ind[k][i], i ) );
        else
          # The character has inertia subgroup $G.2^2$.
          ext:= List( [ 1 .. 3 ], j -> Filtered( Irr( tblsG2[j] ),
                    x -> x{ GfusG2[j] } = Irr( tblG )[i] ) );
          numinv:= Number( [ 1 .. 3 ],
                           x -> Permuted( ext[x][1], acts[x] ) = ext[x][1] );
          ext:= ext[1];
          if numinv in [ 1, 2 ] then
            Info( InfoCharacterTable, 1,
                  "PossibleCharacterTablesOfTypeGV4: contradiction, ",
                  "impossible inertia subgroup" );
            return [];
          elif Permuted( ext[1], acts[1] ) <> ext[1] then
            # The character induces from any of the $G.2_i$.
            irr[i]:= Induced( tblsG2[1], tblGV4, ext{[1]}, G2fusGV4[1] );
            AddSet( done, i );
          else
            # In characteristic $2$, we get a unique extension.
            # Otherwise the character extends $4$-fold,
            # and we have two possibilities for combining the different
            # extensions to the tables in `tblsG2'.
            ext:= List( ext, chi -> CompositionMaps( chi,
                                         InverseMap( G2fusGV4[1] ) ) );
            if char = 2 then
              irr[i]:= ext;
              AddSet( done, i );
            else
              poss1:= [ ShallowCopy( ext[1] ),
                        ShallowCopy( ext[1] ),
                        ShallowCopy( ext[2] ),
                        ShallowCopy( ext[2] ) ];
              ext:= Filtered( Irr( tblsG2[2] ),
                        x -> x{ GfusG2[2] } = Irr( tblG )[i] );
              for k in [ 1 .. Length( G2fusGV4outer[2] ) ] do
                if IsBound( G2fusGV4outer[2][k] ) then
                  poss1{ [ 1 .. 4 ] }[ G2fusGV4outer[2][k] ]:=
                      ext[1][k] * [ 1, -1, 1, -1 ];
                fi;
              od;
              ext:= Filtered( Irr( tblsG2[3] ),
                        x -> x{ GfusG2[3] } = Irr( tblG )[i] );
              for k in [ 1 .. Length( G2fusGV4outer[3] ) ] do
                if IsBound( G2fusGV4outer[3][k] ) then
                  poss1{ [ 1 .. 4 ] }[ G2fusGV4outer[3][k] ]:=
                      ext[1][k] * [ 1, -1, -1, 1 ];
                fi;
              od;
              poss2:= List( poss1, ShallowCopy );
              for chi in poss2 do
                chi{ cosets[3] }:= - chi{ cosets[3] };
              od;
              if 0 < char and Size( tblGV4 ) / ext[1][1] mod char <> 0 then
                if   ForAll( poss1, x -> x in defectzero ) then
                  irr[i]:= poss1;
                elif ForAll( poss2, x -> x in defectzero ) then
                  irr[i]:= poss2;
                else
                  Error( "inconsistency involving defect zero characters" );
                fi;
                AddSet( done, i );
              elif 0 < char then
                # Check whether the possibilities are in the Z-span of the
                # restricted ordinary characters.
                if   SolutionIntMat( intrest.mat, IntegralizedMat(
                         [ poss1[1] ], intrest.inforec ).mat[1] ) = fail then
                  if SolutionIntMat( intrest.mat, IntegralizedMat(
                         [ poss2[1] ], intrest.inforec ).mat[1] ) = fail then
                    Error( "problem with combination of Brauer characters" );
                  fi;
                  irr[i]:= poss2;
                  AddSet( done, i );
                elif SolutionIntMat( intrest.mat, IntegralizedMat(
                         [ poss2[1] ], intrest.inforec ).mat[1] ) = fail then
                  if SolutionIntMat( intrest.mat, IntegralizedMat(
                         [ poss1[1] ], intrest.inforec ).mat[1] ) = fail then
                    Error( "problem with combination of Brauer characters" );
                  fi;
                  irr[i]:= poss1;
                  AddSet( done, i );
                else
                  irr[i]:= [ poss1, poss2 ];
                fi;
              else
                irr[i]:= [ poss1, poss2 ];
              fi;
            fi;
          fi;
        fi;
      fi;
    od;

    # Deal with the extension case.
    todo:= Difference( [ 1 .. NrConjugacyClasses( tblG ) ], done );
    if char = 0 then

      # For each set of four extensions of one character,
      # check the scalar products with the characters $\chi^{2-}$,
      # for all known irreducible (nonlinear) characters $\chi$.
      pow:= ComputedPowerMaps( tblGV4 )[2];
      minus:= Set( List( Union( Filtered( irr,
                                    x -> x[1] <> 1 and
                                         NestingDepthA( x ) = 2 ) ),
                         chi -> MinusCharacter( chi, pow, 2 ) ) );
      nexttodo:= todo;
      repeat
        todo:= ShallowCopy( nexttodo );
        for i in todo do
          # Try to exclude one of the two possibilities via scalar products.
          poss1:= NonnegIntScalarProducts( tblGV4, minus, irr[i][1][1] );
          poss2:= NonnegIntScalarProducts( tblGV4, minus, irr[i][2][1] );
          if   not poss1 and not poss2 then
            # Something must be wrong, for example the given actions.
            Info( InfoCharacterTable, 1,
                  "PossibleCharacterTablesOfTypeGV4: contradiction, ",
                  "incompat. scalar products" );
            return [];
          elif poss1 and not poss2 then
            irr[i]:= irr[i][1];
            UniteSet( minus,
                Set( List( irr[i], chi -> MinusCharacter( chi, pow, 2 ) ) ) );
            RemoveSet( nexttodo, i );
          elif poss2 and not poss1 then
            irr[i]:= irr[i][2];
            UniteSet( minus,
                Set( List( irr[i], chi -> MinusCharacter( chi, pow, 2 ) ) ) );
            RemoveSet( nexttodo, i );
          fi;
        od;

      until todo = nexttodo;

      # Form all combinations of extensions that are still possible.
      poss:= [ irr ];
      for i in todo do
        poss:= Concatenation( [ List( poss, ShallowCopy ),
                                List( poss, ShallowCopy ) ] );
        for j in [ 1 .. Length( poss ) / 2 ] do
          poss[j][i]:= irr[i][1];
        od;
        for j in [ Length( poss ) / 2 + 1 .. Length( poss ) ] do
          poss[j][i]:= irr[i][2];
        od;
      od;

      for i in [ 1 .. Length( poss ) ] do
        # Check that the irreducibles are closed under multiplication
        # with linear characters,
        # and that the power maps are admissible.
        # (Note that `PossiblePowerMaps' is not sufficient here,
        # we check whether all symmetrizations decompose.
        # An example where this excludes a candidate table is
        # `2.U4(3).(2^2)_{133}'.
        tblGV4:= ConvertToCharacterTableNC( ShallowCopy( tblrec ) );
        SetIrr( tblGV4, List( Concatenation( Compacted( poss[i] ) ),
                              chi -> Character( tblGV4, chi ) ) );
        if ForAll( Irr( tblGV4 ), x -> ForAll( LinearCharacters( tblGV4 ),
                   y -> y * x in Irr( tblGV4 ) ) )
           and ForAll( Set( Factors( Size( tblGV4 ) ) ),
                 p -> ForAll( Symmetrizations( tblGV4, Irr( tblGV4 ), p ),
                              x -> NonnegIntScalarProducts( tblGV4, Irr( tblGV4 ), x ) ) ) then
             #   p -> not IsEmpty( PossiblePowerMaps( tblGV4, p,
             #    rec( powermap:= ComputedPowerMaps( tblGV4 )[p] ) ) ) ) then
#T is it possible to detect this earlier?
          SetInfoText( tblGV4,
              "constructed using `PossibleCharacterTablesOfTypeGV4'" );
          AutomorphismsOfTable( tblGV4 );
          poss[i]:= rec( table:= tblGV4, G2fusGV4:= G2fusGV4 );
        else
          Unbind( poss[i] );
        fi;
      od;
      poss:= Compacted( poss );

    else

      # Brauer case: Test the decomposability of all combinations.
#T improve: consider blockwise, and perhaps for increasing degree
      poss:= [ irr ];
      for i in todo do
        poss:= Concatenation( [ List( poss, ShallowCopy ),
                                List( poss, ShallowCopy ) ] );
        for j in [ 1 .. Length( poss ) / 2 ] do
          poss[j][i]:= poss[j][i][1];
        od;
        for j in [ Length( poss ) / 2 + 1 .. Length( poss ) ] do
          poss[j][i]:= poss[j][i][2];
        od;
      od;

      for i in [ 1 .. Length( poss ) ] do
        poss[i]:= Concatenation( Compacted( poss[i] ) );
        if fail in Decomposition( poss[i], rest, "nonnegative" ) then
          Unbind( poss[i] );
        fi;
      od;
      poss:= Compacted( poss );

      for i in [ 1 .. Length( poss ) ] do
        tblGV4:= CharacterTableRegular( ordtblGV4, char );
        SetIrr( tblGV4, List( poss[i],
                              chi -> Character( tblGV4, chi ) ) );
        SetInfoText( tblGV4,
                     "constructed using `PossibleCharacterTablesOfTypeGV4'" );
        AutomorphismsOfTable( tblGV4 );
        poss[i]:= rec( table:= tblGV4, G2fusGV4:= G2fusGV4 );
      od;

    fi;

    return poss;
    end );


#############################################################################
##
#F  PossibleActionsForTypeGA( <tblG>, <tblGA> )
##
InstallGlobalFunction( PossibleActionsForTypeGA,
    function( tblG, tblGA )
    local tfustA, A, elms, i, newelms;

    # Check that the function is applicable.
    tfustA:= GetFusionMap( tblG, tblGA );
    if tfustA = fail then
      Error( "class fusion <tblG> -> <tblGA> must be stored on <tblG>" );
    fi;

    # The automorphism must have order dividing `A'.
    A:= Size( tblGA ) / Size( tblG );
    elms:= Filtered( AsList( AutomorphismsOfTable( tblG ) ),
                     x -> A mod Order( x ) = 0 );
    Info( InfoCharacterTable, 1,
          Length( elms ), " automorphism(s) of order dividing ", A );
    if Length( elms ) <= 1 then
      return elms;
    fi;

    # The automorphism respects the fusion of classes of `tblG' into `tblGA'.
    for i in InverseMap( tfustA ) do
      if IsList( i ) then
        newelms:= Filtered( elms, x -> OnSets( i, x ) = i and
                                       OnPoints( i[1], x ) <> i[1] );
      else
        newelms:= Filtered( elms, x -> OnPoints( i, x ) = i );
      fi;
      if newelms <> elms then
        elms:= newelms;
        Info( InfoCharacterTable, 1,
              Length( elms ), " automorphism(s) acting on ", i );
        if Length( elms ) <= 1 then
          return elms;
        fi;
      fi;
    od;

    # Return the result.
    return elms;
end );


#############################################################################
##
#F  ConstructMGAInfo( <tblmGa>, <tblmG>, <tblGa> )
##
InstallGlobalFunction( ConstructMGAInfo, function( tblmGa, tblmG, tblGa )
    local factfus,
          subfus,
          kernel,
          nccl,
          irr,
          plan,
          chi,
          rest,
          nonfaith,
          zero,
          proj,
          faithful,
          perm;

    factfus:= GetFusionMap( tblmGa, tblGa );
    subfus:= GetFusionMap( tblmG, tblmGa );
    if factfus = fail or subfus = fail then
      Error( "fusions <tblmG> -> <tblmGa> -> <tblGa> must be stored" );
    fi;

    kernel:= ClassPositionsOfKernel( factfus );

    nccl:= NrConjugacyClasses( tblmG );
    irr:= Irr( tblmG );
    plan:= [];
    for chi in Irr( tblmGa ) do
      if not IsSubset( ClassPositionsOfKernel( chi ), kernel ) then
        rest:= chi{ subfus };
        Add( plan, Filtered( [ 1 .. nccl ],
                       i -> ScalarProduct( tblmG, rest, irr[i] ) <> 0 ) );
      fi;
    od;

    nonfaith:= List( Irr( tblGa ), chi -> chi{ factfus } );
    zero:= Zero( [ Maximum( subfus ) + 1 .. NrConjugacyClasses( tblmGa ) ] );
    proj:= ProjectionMap( subfus );
    faithful:= List( plan,
        entry -> Concatenation( Sum( irr{ entry } ){ proj }, zero ) );
    perm:= Sortex( Concatenation( nonfaith, faithful ) ) /
           Sortex( ShallowCopy( Irr( tblmGa ) ) );

    return [ "ConstructMGA",
             Identifier( tblmG ), Identifier( tblGa ), plan, perm ];
end );


#############################################################################
##
#F  ConstructProj( <tbl>, <irrinfo> )
#F  ConstructProjInfo( <tbl>, <kernel> )
##
InstallGlobalFunction( ConstructProj, function( tbl, irrinfo )
    local i, j, factor, fus, mult, irreds, linear, omegasquare, I,
          d, name, factfus, proj, adjust, Adjust,
          ext, lin, chi, faith, nccl, partner, divs, prox, foll,
          vals;

    nccl:= Length( tbl.SizesCentralizers );
    factor:= CharacterTableFromLibrary( irrinfo[1][1] );
    fus:= First( tbl.ComputedClassFusions,
                 fus -> fus.name = irrinfo[1][1] ).map;
    mult:= tbl.SizesCentralizers[1] / Size( factor );
    irreds:= List( Irr( factor ), x -> ValuesOfClassFunction( x ){ fus } );
    linear:= Filtered( irreds, x -> x[1] = 1 );
    linear:= Filtered( linear, x -> ForAny( x, y -> y <> 1 ) );

    # some roots of unity
    omegasquare:= E(3)^2;
    I:= E(4);

    # Loop over the divisors of `mult' (a divisor of 12).
    # Note the succession for `mult = 12'!
    if mult <> 12 then
      divs:= Difference( DivisorsInt( mult ), [ 1 ] );
    else
      divs:= [ 2, 4, 3, 6, 12 ];
    fi;

    for d in divs do

      # Construct the faithful irreducibles for an extension by `d'.
      # For that, we split and adjust the portion of characters (stored
      # on the small table `factor') as if we would create this extension,
      # and then we blow up these characters to the whole table.

      name:= irrinfo[d][1];
      partner:= irrinfo[d][2];
      proj:= First( ProjectivesInfo( factor ), x -> x.name = name );
      faith:= List( proj.chars, y -> y{ fus } );
      proj:= ShallowCopy( proj.map );

      if name = tbl.Identifier then
        factfus:= [ 1 .. Length( tbl.SizesCentralizers ) ];
      else
        factfus:= First( tbl.ComputedClassFusions, x -> x.name = name ).map;
      fi;

      Add( proj, Length( factfus ) + 1 );    # for termination of loop
      adjust:= [];
      for i in [ 1 .. Length( proj ) - 1 ] do
        for j in [ proj[i] .. proj[i+1]-1 ] do
          adjust[ j ]:= proj[i];
        od;
      od;

      # Now we have to multiply the values on certain classes `j' with
      # roots of unity, depending on the value of `d':
#T Note that we do not have the factor fusion from d.G to G available,
#T since the only tables we have are those of mult.G and G,
#T together with the projective characters for the various intermediate
#T tables!

      Adjust:= [];
      for i in [ 1 .. d-1 ] do
        Adjust[i]:= Filtered( [ 1 .. Length( factfus ) ],
                              x -> adjust[ factfus[x] ] = factfus[x] - i );
      od;
#T this means to adjust also in many zero columns;
#T if d = 6 and a class has only 2 or 3 preimages, the second preimage class
#T need not be adjusted for the faithful characters ...

      # d =  2: classes in `Adjust[1]' multiply with `-1'
      # d =  3: classes in `Adjust[x]' multiply
      #                     with `E(3)^x' for the proxy cohort,
      #                     with `E(3)^(2*x)' for the follower cohort
      # d =  4: classes in `Adjust[x]' multiply
      #                     with `E(4)^x' for the proxy cohort,
      #                     with `(-E(4))^x' for the follower cohort,
      # d =  6: classes in `Adjust[x]' multiply with `(-E(3))^x'
      # d = 12: classes in `Adjust[x]' multiply with `(E(12)^7)^x'
      #
      # (*Note* that follower cohorts of classes never occur in projective
      #  ATLAS tables ... )

      # Determine proxy classes and follower classes:
      if Length( linear ) in [ 2, 5 ] then  # out in [ 3, 6 ]
        prox:= [];
        foll:= [];
        chi:= irreds[ Length( linear ) ];
        for i in [ 1 .. nccl ] do
          if chi[i] = omegasquare then
            Add( foll, i );
          else
            Add( prox, i );
          fi;
        od;
      elif Length( linear ) = 3 then        # out = 4
        prox:= [];
        foll:= [];
        chi:= irreds[2];
        for i in [ 1 .. nccl ] do
          if chi[i] = -I then Add( foll, i ); else Add( prox, i ); fi;
        od;
      else
        prox:= [ 1 .. nccl ];
        foll:= [];
      fi;

      if d = 2 then
        # special case without Galois partners
        for chi in faith do
          for i in Adjust[1] do chi[i]:= - chi[i]; od;
          Add( irreds, chi );
          for lin in linear do
            ext:= List( [ 1 .. nccl ], x -> lin[x] * chi[x] );
            if not ext in irreds then Add( irreds, ext ); fi;
          od;
        od;
      elif d = 12 then
        # special case with three Galois partners and `lin = []'
        vals:= [ E(12)^7, - omegasquare, - I, E(3), E(12)^11, -1,
                 -E(12)^7, omegasquare, I, -E(3), -E(12)^11 ];
        for j in [ 1 .. Length( faith ) ] do
          chi:= faith[j];
          for i in [ 1 .. 11 ] do
            chi{ Adjust[i] }:= vals[i] * chi{ Adjust[i] };
          od;
          Add( irreds, chi );
          for i in partner[j] do
            Add( irreds, List( chi, x -> GaloisCyc( x, i ) ) );
          od;
        od;
      else

        if d = 3 then
          Adjust{ [ 1, 2 ] }:= [ Union( Intersection( Adjust[1], prox ),
                                        Intersection( Adjust[2], foll ) ),
                                 Union( Intersection( Adjust[2], prox ),
                                        Intersection( Adjust[1], foll ) ) ];
          vals:= [ E(3), E(3)^2 ];
        elif d = 4 then
          Adjust{ [ 1, 3 ] }:= [ Union( Intersection( Adjust[1], prox ),
                                        Intersection( Adjust[3], foll ) ),
                                 Union( Intersection( Adjust[3], prox ),
                                        Intersection( Adjust[1], foll ) ) ];
          vals:= [ I, -1, -I ];
        elif d = 6 then
          vals:= [ -E(3), omegasquare, -1, E(3), - omegasquare ];
        fi;

        for j in [ 1 .. Length( faith ) ] do
          chi:= faith[j];
          for i in [ 1 .. d-1 ] do
            chi{ Adjust[i] }:= vals[i] * chi{ Adjust[i] };
          od;
          Add( irreds, chi );
          for lin in linear do
            ext:= List( [ 1 .. nccl ], x -> lin[x] * chi[x] );
            if not ext in irreds then Add( irreds, ext ); fi;
          od;
          chi:= List( chi, x -> GaloisCyc( x, partner[j] ) );
          Add( irreds, chi );
          for lin in linear do
            ext:= List( [ 1 .. nccl ], x -> lin[x] * chi[x] );
            if not ext in irreds then Add( irreds, ext ); fi;
          od;
        od;

      fi;
    od;
    tbl.Irr:= irreds;
end );


#############################################################################
##
#F  CharacterTableSortedWRTCentralExtension( <tbl>, <facttbl>, <kernel> )
##
BindGlobal( "CharacterTableSortedWRTCentralExtension",
    function( tbl, facttbl, kernel )
    local classes, orders, mult, faithpos, sort, powers, fusion, inv,
          mapping, i, preimorders, min, cand, count, first, j, divs,
          portions;

    # Check that the kernel is a central cyclic subgroup.
    classes:= SizesConjugacyClasses( tbl );
    orders:= OrdersClassRepresentatives( tbl );
    mult:= Sum( classes{ kernel } );
    faithpos:= First( kernel, i -> orders[i] = mult );
    if    12 mod mult <> 0
       or faithpos = fail
       or Length( kernel ) <> mult then
      Error( "only cyclic central ext. by a group of order dividing 12" );
    fi;

    # First sort the table w.r.t. the factor table.
    sort:= SortedCharacterTable( tbl, facttbl, kernel );
    if sort = fail then
      Error( "<tbl> and <facttbl> do not fit w.r.t. <kernel>" );
    fi;
    kernel:= [ 1 .. mult ];
    ResetFilterObj( sort, HasClassPermutation );

    # Permute the classes of the kernel such that the $i$-th class
    # is the $(i-1)$-th power of a generator class.
    orders:= OrdersClassRepresentatives( sort );
    faithpos:= First( kernel, i -> orders[i] = mult );
    powers:= List( [ 1 .. mult-1 ], i -> PowerMap( sort, i, faithpos ) );
    if powers <> [ 2 .. mult ] then
      sort:= CharacterTableWithSortedClasses( sort,
                 PermList( Concatenation( [ 1 ], powers ) ) );
      ResetFilterObj( sort, HasClassPermutation );
    fi;

    # Get the fusion to the factor group.
    fusion:= GetFusionMap( sort, facttbl );

    # Permute the classes such that the preimages of each class in the factor
    # group are ordered in such a way that
    # - the first preimage has minimal element order and among those classes
    #   with the minimal order has the fewest number of irrationalities,
    #   and for the classes where these two are minimal has more positive
    #   character values, and
    # - the $i$-th preimage is obtained by
    #   multiplying the first preimage with the root of unity on the $i$-th
    #   class of the kernel.
    # We assume that for the classes of the factor groups, the table is
    # already sorted compatibly.
    # So we have to consider only those cases where a full splitting occurs.
    classes:= SizesConjugacyClasses( sort );
    orders:= OrdersClassRepresentatives( sort );
    inv:= InverseMap( fusion );
    mapping:= [];
    for i in [ 1 .. Length( inv ) ] do
      if IsInt( inv[i] ) then
        Add( mapping, inv[i] );
      else
        preimorders:= orders{ inv[i] };
        min:= Minimum( preimorders );
        cand:= Filtered( inv[i], j -> orders[j] = min );
        if 1 < Length( cand ) then
          count:= List( cand,
                        j -> Number( Irr( sort ), x -> not IsInt( x[j] ) ) );
          min:= Minimum( count );
          cand:= cand{ Filtered( [ 1 .. Length( cand ) ],
                                 j -> count[j] = min ) };
          if 1 < Length( cand ) then
            count:= List( cand,
                          j -> Number( Irr( sort ), x -> IsNegInt( x[j] ) ) );
            min:= Minimum( count );
            cand:= cand{ Filtered( [ 1 .. Length( cand ) ],
                                   j -> count[j] = min ) };
          fi;
        fi;
        first:= cand[1];
        for j in [ 1 .. mult ] do
          Add( mapping, First( inv[i], k -> ForAll( Irr( sort ),
                            x -> x[k] * x[1] = x[j] * x[ first ] ) ) );
        od;
      fi;
    od;

    # Now distribute the irreducibles not having <kernel> in their kernels.
    # Note the succession for `mult = 12'!
    if mult <> 12 then
      divs:= DivisorsInt( mult );
    else
      divs:= [ 1, 2, 4, 3, 6, 12 ];
    fi;
    portions:= List( Reversed( divs ),
                 d -> Filtered( Irr( sort ),
                        x -> Length( Intersection( kernel,
                                       ClassPositionsOfKernel( x ) ) ) = d ) );
    ResetFilterObj( sort, HasIrr );
    SetIrr( sort, Concatenation( portions ) );

    # Sort the classes, and return a table without permutation.
    sort:= CharacterTableWithSortedClasses( sort, PermList( mapping ) );
    ResetFilterObj( sort, HasClassPermutation );

    return sort;
end );


InstallGlobalFunction( ConstructProjInfo, function( tbl, kernel )
    local fusions, fus, facttable,
          sort,
          mult,        # order of the central subgroup `kernel'
          faithpos,    # position of a cyclic generator of the kernel
          nsg,         # class positions of subgroups of `kernel'
          faith,       # corresponding group orders
          names,       # names of factors by these subgroups
          fusrec,      # loop over fusions
          faithchars,  # faithful characters for each subgroup
          chi,         # loop over irreducibles of `tbl'
          ker,         # kernel of `chi'
          proj,
          nccl,
          linear,
          partners,
          i,
          new,
          gal,
          rest,
          projectives,
          info;

    # Get the factor table.
    fusions:= ComputedClassFusions( tbl );
    fus:= First( fusions, x -> ClassPositionsOfKernel( x.map ) = kernel );
    facttable:= CharacterTable( fus.name );

    # Permute the classes and characters.
    tbl:= CharacterTableSortedWRTCentralExtension( tbl, facttable, kernel );
    kernel:= [ 1 .. Length( kernel ) ];
    faithpos:= 2;
    nsg:= Filtered( ClassPositionsOfNormalSubgroups( tbl ),
                    x -> IsSubset( kernel, x ) );
    faith:= List( nsg, l -> Length( kernel ) / Length( l ) );
    SortParallel( faith, nsg );
    if Length( kernel ) = 12 then
      nsg:= Permuted( nsg, (3,4) );
      faith:= Permuted( faith, (3,4) );
    fi;

    names:= [];
    fusions:= ComputedClassFusions( tbl );
    for i in [ 1 .. Length( nsg )-1 ] do
      fusrec:= First( fusions,
                      r -> ClassPositionsOfKernel( r.map ) = nsg[i] );
      if fusrec = fail then
        Error( "factor fusion with kernel ", nsg[i], " not stored" );
      fi;
      names[i]:= fusrec.name;
    od;
    names[ Length( nsg ) ]:= Identifier( tbl );

    # Distribute the irreducibles according to their kernels.
    # Take only those irreducibles
    # of  $3.G$ with value `E(3)' times the degree on the first nonid. class,
    # of  $4.G$ with value `E(4)' times the degree on the first nonid. class,
    # of  $6.G$ with value `E(6)^5' times the deg. on the first nonid. class,
    # of $12.G$ with value `E(12)^7' times the deg. on the first nonid. class,
    faithchars:= List( nsg, l -> [] );
    for chi in Irr( tbl ) do
      ker:= ClassPositionsOfKernel( chi );
      for i in [ 1 .. Length( nsg ) ] do
        if IsSubset( ker, nsg[i] ) then
          if      faith[i] <= 2
             or ( faith[i] =  3 and chi[ faithpos ] = E(3) * chi[1] )
             or ( faith[i] =  4 and chi[ faithpos ] = E(4) * chi[1] )
             or ( faith[i] =  6 and chi[ faithpos ] = E(6)^5 * chi[1] )
             or ( faith[i] = 12 and chi[ faithpos ] = E(12)^7 * chi[1] ) then
            Add( faithchars[i], chi );
            break;
          fi;
        fi;
      od;
    od;

    # Remove characters obtained by multiplication with linear characters
    # of the factor group,
    # and create the result info.
    fus:= First( fusions, x -> ClassPositionsOfKernel( x.map ) = kernel ).map;
    proj:= ProjectionMap( fus );
    nccl:= Length( proj );
    linear:= List( Filtered( faithchars[1], chi -> chi[1] = 1 ),
                   lambda -> lambda{ proj } );
    projectives:= [];
    info:= [ [ names[1], [] ] ];

    for i in [ 2 .. Length( nsg ) ] do

      new:= [];
      gal:= [];
      for chi in faithchars[i] do
        rest:= chi{ proj };
        if ForAll( linear, lambda -> not List( [ 1 .. nccl ],
               j -> lambda[j] * rest[j] ) in new ) then
          Add( new, rest );
          if 2 < faith[i] then
            partners:= GaloisPartnersOfIrreducibles( tbl, [ chi ], faith[i] );
            if faith[i] <> 12 then
              partners:= partners[1];
            fi;
            Append( gal, partners );
#T works for 12 ??
          fi;
        fi;
      od;
      info[ faith[i] ]:= [ names[i], gal ];
      Add( projectives, rec( name:= names[i], chars:= new ) );

    od;

    SetConstructionInfoCharacterTable( tbl, [ "ConstructProj", info ] );

    # Return the result.
    return rec( tbl         := tbl,
                projectives := projectives,
                info        := info         );
end );


#############################################################################
##
#F  ConstructDirectProduct( <tbl>, <factors>[, <permclasses>, <permchars>] )
##
InstallGlobalFunction( ConstructDirectProduct, function( arg )
    local tbl, factors, t, i;

    tbl:= arg[1];
    factors:= arg[2];
    t:= CallFuncList( CharacterTableFromLibrary, factors[1] );
    for i in [ 2 .. Length( factors ) ] do
      t:= CharacterTableDirectProduct( t,
              CallFuncList( CharacterTableFromLibrary, factors[i] ) );
    od;
    if 2 < Length( arg ) then
      t:= CharacterTableWithSortedClasses( t, arg[3] );
      t:= CharacterTableWithSortedCharacters( t, arg[4] );
      # We must keep the class permutation obtained this way
      # since it is contained in the `ConstructionInfo' data,
      # and hence Brauer tables derived from the factors will respect it.
    fi;
    TransferComponentsToLibraryTableRecord( t, tbl );
    if 1 < Length( factors ) then
      Append( tbl.ComputedClassFusions, ComputedClassFusions( t ) );
    fi;
end );


#############################################################################
##
#F  ConstructSubdirect( <tbl>, <factors>, <choice> )
##
InstallGlobalFunction( ConstructSubdirect, function( tbl, factors, choice  )
    local t, i;

    t:= CallFuncList( CharacterTableFromLibrary, factors[1] );
    for i in [ 2 .. Length( factors ) ] do
      t:= CharacterTableDirectProduct( t,
              CallFuncList( CharacterTableFromLibrary, factors[i] ) );
    od;
    t:= CharacterTableOfNormalSubgroup( t, choice );
    TransferComponentsToLibraryTableRecord( t, tbl );
end );


#############################################################################
##
#F  ConstructWreathSymmetric( <tbl>, <subname>, <n>
#F                            [, <permclasses>, <permchars>] )
##
InstallGlobalFunction( ConstructWreathSymmetric, function( arg )
    local tbl, sub, t;

    tbl:= arg[1];
    sub:= CallFuncList( CharacterTableFromLibrary, arg[2] );
    t:= CharacterTableWreathSymmetric( sub, arg[3] );
    if 3 < Length( arg ) then
      t:= CharacterTableWithSortedClasses( t, arg[4] );
      t:= CharacterTableWithSortedCharacters( t, arg[5] );
      if not IsBound( tbl.ClassPermutation ) then
        # Do *not* inherit the permutation from the construction!
        tbl.ClassPermutation:= ();
      fi;
    fi;
    TransferComponentsToLibraryTableRecord( t, tbl );
#   if 1 < Length( factors ) then
#     Append( tbl.ComputedClassFusions, ComputedClassFusions( t ) );
#   fi;
end );


#############################################################################
##
#F  ConstructIsoclinic( <tbl>, <factors>[, <nsg>[, <centre>]] 
#F                      [, <permclasses>, <permchars>] )
##
InstallGlobalFunction( ConstructIsoclinic, function( arg )
    local tbl, factors, t, i, fld, perms;

    tbl:= arg[1];
    factors:= arg[2];
    t:= CallFuncList( CharacterTableFromLibrary, factors[1] );
    for i in [ 2 .. Length( factors ) ] do
      t:= CharacterTableDirectProduct( t,
              CallFuncList( CharacterTableFromLibrary, factors[i] ) );
    od;
    t:= CallFuncList( CharacterTableIsoclinic,
            Concatenation( [ t ],
                Filtered( arg{ [ 3 .. Length( arg ) ] }, IsList ) ) );
    perms:= Filtered( arg, IsPerm );
    if Length( perms ) = 2 then
      t:= CharacterTableWithSortedClasses( t, perms[1] );
      t:= CharacterTableWithSortedCharacters( t, perms[2] );
    fi;
    TransferComponentsToLibraryTableRecord( t, tbl );
end );


#############################################################################
##
##  4. Character Tables of Groups of Structure $2^2.G$
##


#############################################################################
##
#F  PossibleCharacterTablesOfTypeV4G( <tblG>, <tbls2G>, <id>[, <fusions>] )
#F  PossibleCharacterTablesOfTypeV4G( <tblG>, <tbl2G>, <aut>, <id> )
##
InstallGlobalFunction( PossibleCharacterTablesOfTypeV4G, function( arg )
    local tblG, tbls2G, aut, identifier, tbls2GfustblG, tbl2G, tbl2GfustblG,
          invfus, fus, pow2, 2pow2, i, lst, int, j, powermaps, primes, inv,
          p, firstfus, testfus, oldfus, pos, classes, tblV4G, tblGprojtblV4G,
          irr, ker, irr1, irr2, faith, sortedfaith, parafus, indet, pointer,
          max, entry, descendants, result, choice, map, lirr1, lirr2, error,
          split;

    # Get and check the arguments.
    if   Length( arg ) = 3 and IsOrdinaryTable( arg[1] ) and IsList( arg[2] )
                           and IsString( arg[3] ) then
      tblG       := arg[1];
      tbls2G     := arg[2];
      aut        := fail;
      identifier := arg[3];

      # Get the three factor fusions.
      tbls2GfustblG:= List( tbls2G, t -> GetFusionMap( t, tblG ) );
      if fail in tbls2GfustblG then
        Error( "the factor fusions <tbls2G> -> <tblG> must be stored" );
      fi;

    elif Length( arg ) = 4 and IsOrdinaryTable( arg[1] )
                           and IsList( arg[2] )
                           and IsString( arg[3] )
                           and IsList( arg[4] ) then
      tblG          := arg[1];
      tbls2G        := arg[2];
      identifier    := arg[3];
      tbls2GfustblG := arg[4];

    elif Length( arg ) = 4 and IsOrdinaryTable( arg[1] )
                           and IsOrdinaryTable( arg[2] )
                           and IsPerm( arg[3] )
                           and IsString( arg[4] ) then
      tblG       := arg[1];
      tbl2G      := arg[2];
      aut        := arg[3];
      identifier := arg[4];

      # Get the three factor fusions.
      tbl2GfustblG:= GetFusionMap( tbl2G, tblG );
      if tbl2GfustblG = fail then
        Error( "the factor fusion to <tblG> must be stored" );
      fi;
      tbls2GfustblG:= List( [ 0 .. 2 ],
                            i -> OnTuples( tbl2GfustblG, aut^i ) );
      tbls2G:= ListWithIdenticalEntries( 3, tbl2G );

    else
      Error( "usage: PossibleCharacterTablesOfTypeV4G(<tbl>,<tbls>,<id>),\n",
          "PossibleCharacterTablesOfTypeV4G(<tbl>,<tbls>,<id>,<fusions>),\n",
          "PossibleCharacterTablesOfTypeV4G(<tblG>,<tbl2G>,<aut>,<id>)" );
    fi;

    # Construct the classes of $2^2.G$, via the three factor fusions.
    invfus:= List( tbls2GfustblG, InverseMap );
    fus:= [ [], [], [] ];
    pow2:= PowerMap( tblG, 2 );
    2pow2:= List( tbls2G, t -> PowerMap( t, 2 ) );

    for i in [ 1 .. NrConjugacyClasses( tblG ) ] do

      # Deal with the preimages of class `i' in `tblG'.
      lst:= Filtered( [ 1 .. 3 ], j -> IsList( invfus[j][i] ) );
      int:= Difference( [ 1 .. 3 ], lst );

      if   Length( lst ) = 0 then
        # no splitting
        for j in [ 1 .. 3 ] do
          fus[j][i]:= [ [ invfus[j][i] ] ];
        od;
      elif Length( lst ) = 1 then
        # exactly one splitting in step 1, so the other two split in step 2.
        fus[ lst[1] ][i]:= [ invfus[ lst[1] ][i] ];
        fus[ int[1] ][i]:= [ invfus[ int[1] ]{ [ i, i ] } ];
        fus[ int[2] ][i]:= [ invfus[ int[2] ]{ [ i, i ] } ];
      elif Length( lst ) = 3 then
        # splitting in all three cases, we have the problem of identifying!
        # (the first two fusions can be chosen,
        # the third leads in general to two possibilities)
        fus[1][i]:= [ invfus[1][i]{ [ 1, 1, 2, 2 ] } ];
        fus[2][i]:= [ invfus[2][i]{ [ 1, 2, 1, 2 ] } ];
        fus[3][i]:= [ invfus[3][i]{ [ 1, 2, 2, 1 ] },
                      invfus[3][i]{ [ 2, 1, 1, 2 ] } ];
      else
        # The tables do not fit together (`lst' must have length 0, 1, or 3)
        Info( InfoCharacterTable, 1,
              "PossibleCharacterTablesOfTypeV4G: inconsistent splitting\n",
              "#I  of classes at position ", i, " in ", tblG );
        return [];
      fi;

    od;

    # Initialize power maps using the first table,
    # and check the consistency with the power maps in the second table.
    powermaps:= [];
    primes:= Set( Factors( Size( tbls2G[1] ) ) );
    fus[1]:= Concatenation( Concatenation( fus[1] ) );
    inv:= InverseMap( fus[1] );
    for p in primes do
      powermaps[p]:= CompositionMaps( inv, CompositionMaps(
                         PowerMap( tbls2G[1], p ), fus[1] ) );
      PowerMap( tbls2G[2], p );
      PowerMap( tbls2G[3], p );
    od;
    fus[2]:= Concatenation( Concatenation( fus[2] ) );
    if not TestConsistencyMaps( powermaps, fus[2],
               ComputedPowerMaps( tbls2G[2] ) ) then
      Info( InfoCharacterTable, 1,
            "PossibleCharacterTablesOfTypeV4G: inconsistent power maps\n",
            "#I  of the first two factors" );
      return [];
    fi;

    # Try to resolve ambiguities using the power maps in the third factor.
    # For example, this check determines the class among the four preimages
    # that is fixed under the order three automorphisms (if there is one)
    # if the image in the factor group is a 2nd power of a fixed class.
#T Is this true?
    # And the case 2 image/preimage of a fixed class in case 2 under an odd
    # power map must be fixed.
    firstfus:= Concatenation( List( fus[3], x -> x[1] ) );
    testfus:= Parametrized( [ firstfus,
                  Concatenation( List( fus[3], x -> x[ Length( x ) ] ) ) ] );
    oldfus:= List( testfus, ShallowCopy );
    if not TestConsistencyMaps( powermaps, testfus,
               ComputedPowerMaps( tbls2G[3] ) ) then
      Info( InfoCharacterTable, 1,
            "PossibleCharacterTablesOfTypeV4G: inconsistent power maps\n",
            "#I  of the first and third factor" );
      return [];
    fi;
    for i in [ 1 .. Length( testfus ) ] do
      if IsInt( testfus[i] ) and IsList( oldfus[i] ) then
        pos:= PositionProperty( invfus[3],
                                x -> IsList( x ) and testfus[i] in x );
        if Length( fus[3][ pos ] ) = 2 then
          if testfus[i] = firstfus[i] then
            fus[3][ pos ]:= [ fus[3][ pos ][1] ];
          else
            fus[3][ pos ]:= [ fus[3][ pos ][2] ];
          fi;
        fi;
      fi;
    od;

    # Create the table head data of $2^2.G$, using the first fusion.
    classes:= [];
    inv:= CompositionMaps( inv, InverseMap( tbls2GfustblG[1] ) );
    for i in [ 1 .. NrConjugacyClasses( tblG ) ] do
      if IsInt( inv[i] )  then
        Add( classes, 4 * SizesConjugacyClasses( tblG )[i] );
      elif Length( inv[i] ) = 2  then
        Append( classes, 2 * SizesConjugacyClasses( tblG ){ [ i, i ] } );
      else
        Append( classes, SizesConjugacyClasses( tblG ){ [ i, i, i, i ] } );
      fi;
    od;
    tblV4G:= rec( Identifier:= identifier,
                  UnderlyingCharacteristic:= 0,
                  Size:= 2 * Size( tbls2G[1] ),
                  SizesConjugacyClasses:= classes,
                  ComputedPowerMaps:= powermaps,
                 );

    # Construct the first two portions of irreducible characters of $2^2.G$.
    tblGprojtblV4G:= ProjectionMap(
        CompositionMaps( tbls2GfustblG[1], fus[1] ) );
    irr:= List( Irr( tbls2G[1] ), chi -> chi{ fus[1] } );
    ker:= ClassPositionsOfKernel( tbls2GfustblG[1] );
    irr1:= Filtered( Irr( tbls2G[1] ),
                     chi -> chi[ ker[1] ] <> chi[ ker[2] ] );
    ker:= ClassPositionsOfKernel( tbls2GfustblG[2] );
    irr2:= Filtered( Irr( tbls2G[2] ),
                     chi -> chi[ ker[1] ] <> chi[ ker[2] ] );
    Append( irr, List( irr2, chi -> chi{ fus[2] } ) );

    # Take the third portion of irreducibles.
    ker:= ClassPositionsOfKernel( tbls2GfustblG[3] );
    faith:= Filtered( Irr( tbls2G[3] ),
                      chi -> chi[ ker[1] ] <> chi[ ker[2] ] );

    # Sort them such that those which distinguish most of the
    # possibilities come first.
    sortedfaith:= ShallowCopy( faith );
    parafus:= Parametrized( [
                  Concatenation( List( fus[3], x -> x[ 1 ] ) ),
                  Concatenation( List( fus[3], x -> x[ Length( x ) ] ) ) ] );
    testfus:= CompositionMaps( parafus, tblGprojtblV4G );
    indet:= List( faith,
              chi -> Indeterminateness( CompositionMaps( chi, testfus ) ) );
    SortParallel( - indet, sortedfaith );
    sortedfaith:= sortedfaith{ Filtered( [ 1 .. Length( sortedfaith ) ],
                                         i -> 1 < indet[i] ) };

    # Loop over the possible fusions onto the third factor table.
    # First filter out those for which the power maps are compatible.
    pointer:= [];
    max:= 0;
    for i in [ 1 .. Length( fus[3] ) ] do
      entry:= fus[3][i];
      if Length( entry ) = 1 then
        pointer[i]:= 0;
      else
        pointer[i]:= max + [ 1 .. Length( entry[1] ) ];
      fi;
      max:= max + Length( entry[1] );
    od;

    descendants:= function( parafus, pointer )
      local result, pos, entry, parafus1, pointer1, i, pos2;

      result:= [];
      pos:= PositionProperty( pointer, IsList );
      if pos = fail then
        if TestConsistencyMaps( powermaps, parafus,
               ComputedPowerMaps( tbls2G[3] ) ) then
          result[1]:= parafus;
        fi;
        return result;
      fi;

      for entry in fus[3][ pos ] do
        parafus1:= List( parafus, ShallowCopy );
        parafus1{ pointer[ pos ] }:= entry;
        if TestConsistencyMaps( powermaps, parafus1,
               ComputedPowerMaps( tbls2G[3] ) ) then
          pointer1:= ShallowCopy( pointer );
          for i in [ 1 .. Length( pointer ) ] do
            if IsList( pointer1[i] ) then
              pos2:= PositionProperty( parafus1{ pointer1[i] }, IsInt );
              if pos2 <> fail then
                if parafus1[ pointer1[i][ pos2 ] ] = fus[3][i][1][ pos2 ] then
                  parafus1{ pointer1[i] }:= fus[3][i][1];
                else
                  parafus1{ pointer1[i] }:= fus[3][i][2];
                fi;
                pointer1[i]:= 0;
              fi;
            fi;
          od;
          Append( result, descendants( parafus1, pointer1 ) );
        fi;
      od;

      return result;
    end;

    result:= [];
    for choice in descendants( parafus, pointer ) do

      map:= CompositionMaps( fus[1], ProjectionMap( choice ) );
      lirr1:= List( irr1, x -> CompositionMaps( x, map ) );
      map:= CompositionMaps( fus[2], ProjectionMap( choice ) );
      lirr2:= List( irr2, x -> CompositionMaps( x, map ) );

      # Compute tensor products of characters in `tbls2G[1]' and `tblsG2[2]',
      # in order to check the table; this takes place in `tbls2G[3]'.
      error:= false;
      for i in lirr1 do
        if not ForAll( lirr2,
                   j -> NonnegIntScalarProducts( tbls2G[3], sortedfaith,
                            Tensored( [ i ], [ j ] )[1] ) ) then
          error:= true;
          break;
        fi;
      od;

      if not error then
        # Create the table object.
        split:= ShallowCopy( tblV4G );
        split.ComputedClassFusions:= [
            rec( name:= Identifier( tbls2G[1] ), map:= fus[1],
                 specification:= "1" ),
            rec( name:= Identifier( tbls2G[2] ), map:= fus[2],
                 specification:= "2" ),
            rec( name:= Identifier( tbls2G[3] ), map:= choice,
                 specification:= "3" ) ];

        split:= ConvertToLibraryCharacterTableNC( split );
        SetIrr( split,
            List( Concatenation( irr, List( faith, chi -> chi{ choice } ) ),
                  chi -> Character( split, chi ) ) );
        SetConstructionInfoCharacterTable( split,
            ConstructV4GInfo( split, [ 1 .. 4 ] ) );

        # Add the table to the result list.
        SetInfoText( split,
            "constructed using `PossibleCharacterTablesOfTypeV4G'" );
        Add( result, split );
      fi;

    od;

    return result;
    end );


#############################################################################
##
#F  BrauerTableOfTypeV4G( <ordtblV4G>, <modtbls2G> )
#F  BrauerTableOfTypeV4G( <ordtblV4G>, <modtbl2G>, <aut>[, <ker>] )
##
InstallGlobalFunction( BrauerTableOfTypeV4G, function( arg )
    local ordtblV4G, modtbls2G, aut, ker, p, modtblV4G, fus, irr, i, modfus,
          chars;

    # Get the arguments.
    ordtblV4G:= arg[1];
    if Length( arg ) = 2 then
      # three nonsisomorphic factors
      modtbls2G:= arg[2];
    else
      # one factor, an automorphism of `ordtblV4G',
      # and perhaps a class position in the ord. table of `2.G'
      modtbls2G:= [ arg[2] ];
      aut:= arg[3];
      ker:= 2;
      if Length( arg ) = 4 then
        ker:= arg[4];
      fi;
    fi;

    # Construct the table head of the Brauer table.
    p:= UnderlyingCharacteristic( modtbls2G[1] );
    modtblV4G:= CharacterTableRegular( ordtblV4G, p );

    # Fetch the factor fusions and inflate the irreducible characters.
    fus:= List( modtbls2G, x -> GetFusionMap( modtblV4G, x ) );
    irr:= List( Irr( modtbls2G[1] ), x -> x{ fus[1] } );
    if p <> 2 then
      # (For `p = 2', we would run into an error in the `else' case.)
      if Length( arg ) = 2 then
        for i in [ 2 .. Length( modtbls2G ) ] do
          Append( irr, Filtered( List( Irr( modtbls2G[i] ),
                                       x -> x{ fus[i] } ),
                                 x -> not x in irr ) );
        od;
      else
        modfus:= GetFusionMap( modtblV4G, ordtblV4G );
        aut:= PermList( CompositionMaps( InverseMap( modfus ),
                  OnTuples( modfus, aut ) ) );
        ker:= Position( fus[1], Position( GetFusionMap( modtbls2G[1],
                  OrdinaryCharacterTable( modtbls2G[1] ) ), ker ) );
        chars:= List( Filtered( irr, x -> x[1] <> x[ ker ] ),
                      x -> Permuted( x, aut ) );
        Append( irr, chars );
        Append( irr, List( chars, x -> Permuted( x, aut ) ) );
      fi;
    fi;
    SetIrr( modtblV4G, List( irr, x -> Character( modtblV4G, x ) ) );
    SetInfoText( modtblV4G, "constructed using `BrauerTableOfTypeV4G'" );

    return modtblV4G;
end );


#############################################################################
##
#F  ConstructV4G( <tbl>, <facttbl>, <aut>[, <ker>] )
#F  ConstructV4G( <tbl>, <facttbls> )
##
InstallGlobalFunction( ConstructV4G, function( arg )
    local tbl, facttbls, aut, ker, fus, i, chars;

    tbl:= arg[1];
    if Length( arg ) = 2 then
      facttbls:= arg[2];
    else
      facttbls:= [ arg[2] ];
      aut:= arg[3];
      ker:= 2;
      if Length( arg ) = 4 then
        ker:= arg[4];
      fi;
    fi;

    fus:= List( facttbls, x -> First( tbl.ComputedClassFusions,
                                      fus -> fus.name = x ).map );
    facttbls:= List( facttbls, CharacterTableFromLibrary );
    tbl.Irr:= List( Irr( facttbls[1] ),
                    x -> ValuesOfClassFunction( x ){ fus[1] } );

    if Length( arg ) = 2 then
      for i in [ 2 .. Length( facttbls ) ] do
        Append( tbl.Irr, Filtered( List( Irr( facttbls[i] ),
                                 x -> ValuesOfClassFunction( x ){ fus[i] } ),
                             x -> not x in tbl.Irr ) );
      od;
    else
      ker:= Position( fus[1], ker );
      chars:= List( Filtered( tbl.Irr, x -> x[1] <> x[ ker ] ),
                    x -> Permuted( x, aut ) );
      Append( tbl.Irr, chars );
      Append( tbl.Irr, List( chars, x -> Permuted( x, aut ) ) );
    fi;
end );


#############################################################################
##
#F  ConstructV4GInfo( <tblV4G>, <kernel> )
##
##  We want the permutation to be a table automorphism,
##  because otherwise it is not clear that the induced action on p-regular
##  classes will work.
##  The permutation need not be unique.
##  If there are several possibilities then we prefer one that keeps the
##  ordering of the characters.
##
InstallGlobalFunction( ConstructV4GInfo, function( tblV4G, kernel )
    local faith, portions, permuted, pi, fusion, cand, cand2, list;

    faith:= Filtered( Irr( tblV4G ),
              chi -> not IsSubset( ClassPositionsOfKernel( chi ), kernel ) );
    portions:= List( Difference( kernel, [ 1 ] ),
                 i -> Filtered( faith,
                        chi -> i in ClassPositionsOfKernel( chi ) ) );
    permuted:= List( portions{ [ 2, 3, 1 ] }, Set );
    fusion:= First( ComputedClassFusions( tblV4G ),
                 x -> ClassPositionsOfKernel( x.map ) = kernel{ [ 1, 2 ] } );

    cand:= Filtered( Elements( AutomorphismsOfTable( tblV4G ) ),
                     x -> Order( x ) = 3 and kernel[2]^x = kernel[3]
                            and ForAll( [ 1 .. 3 ],
                                  i -> Set( List( portions[i],
                                              l -> Permuted( l, x ) ) )
                                       = permuted[i] ) );
    if Length( cand ) <> 1 then
      cand2:= Filtered( cand, x -> ForAll( [ 1 .. 3 ],
                i -> List( portions[i], l -> Permuted( l, x ) )
                       = portions[ ( i mod 3 ) + 1 ] ) );
      if not IsEmpty( cand2 ) then
        cand:= cand2;
      fi;
    fi;
    pi:= cand[1];

    list:= [ "ConstructV4G", fusion.name, pi ];
    if fusion.map[ kernel[3] ] <> 2 then
      Add( list, fusion.map[ kernel[3] ] );
    fi;

    return list;
end );


#############################################################################
##
#F  ConstructGS3( <tbls3>, <tbl2>, <tbl3>, <ind2>, <ind3>, <ext>, <perm> )
##
InstallGlobalFunction( ConstructGS3,
    function( tbls3, tbl2, tbl3, ind2, ind3, ext, perm )
    local fus2,       # fusion map `tbl2' in `tbls3'
          fus3,       # fusion map `tbl3' in `tbls3'
          proj2,      # projection $G.S3$ to $G.2$
          pos,        # position in `proj2'
          proj2i,     # inner part of projection $G.S3$ to $G.2$
          proj2o,     # outer part of projection $G.S3$ to $G.2$
          proj3,      # projection $G.S3$ to $G.3$
          zeroon2,    # zeros for part of $G.2 \setminus G$ in $G.S_3$
          irr,        # irreducible characters of `tbls3'
          irr3,       # irreducible characters of `tbl3'
          irr2,       # irreducible characters of `tbl2'
          i,          # loop over `ind2'
          pair,       # loop over `ind3' and `ext'
          chi,        # character
          chii,       # inner part of character
          chio;       # outer part of character

    tbl2:= CharacterTableFromLibrary( tbl2 );
    tbl3:= CharacterTableFromLibrary( tbl3 );

    fus2:= First( ComputedClassFusions( tbl2 ),
                  fus -> fus.name = tbls3.Identifier ).map;
    fus3:= First( ComputedClassFusions( tbl3 ),
                  fus -> fus.name = tbls3.Identifier ).map;

    proj2:= ProjectionMap( fus2 );
    pos:= First( [ 1 .. Length( proj2 ) ], x -> not IsBound( proj2[x] ) );
    proj2i:= proj2{ [ 1 .. pos-1 ] };
    pos:= First( [ pos .. Length( proj2 ) ], x -> IsBound( proj2[x] ) );
    proj2o:= proj2{ [ pos .. Length( proj2 ) ] };
    proj3:= ProjectionMap( fus3 );

    zeroon2:= Zero( Difference( [ 1 .. Length( tbls3.SizesCentralizers ) ],
                    fus3 ) );

    # Induce the characters given by `ind2' from `tbl2'.
    irr:= InducedLibraryCharacters( tbl2, tbls3, Irr( tbl2 ){ ind2 }, fus2 );

    # Induce the characters given by `ind3' from `tbl3'.
    irr3:= List( Irr( tbl3 ), ValuesOfClassFunction );
    Append( irr, List( ind3,
        pair -> Concatenation( Sum( irr3{ pair } ){ proj3 }, zeroon2 ) ) );

    # Put the extensions from `tbl' together.
    irr2:= List( Irr( tbl2 ), ValuesOfClassFunction );
    for pair in ext do
      chii:= irr3[ pair[1] ]{ proj3 };
      chio:= irr2[ pair[2] ]{ proj2o };
      Add( irr, Concatenation( chii,  chio ) );
      Add( irr, Concatenation( chii, -chio ) );
    od;

    # Permute the characters with `perm'.
    irr:= Permuted( irr, perm );

    # Store the irreducibles.
    tbls3.Irr:= irr;
end );


#############################################################################
##
#F  ConstructGS3Info( <tbl2>, <tbl3>, <tbls3> )
##
InstallGlobalFunction( ConstructGS3Info, function( tbl2, tbl3, tbls3 )
    local irr2,        # irreducible characters of `tbl2'
          irr3,        # irreducible characters of `tbl3'
          irrs3,       # irreducible characters of `tbls3'
          ind,         # list of induced characters
          ind2,        # positions of irreducible characters of `tbl2'
                       # inducing irreducibly to `tbls3'
          oldind,      # auxiliary list
          i,           # loop over positions in `ind'
          pos,         # position in `ind' or `irr3'
          ind3,        # positions of pairs of irreducible characters of
                       # `tbl3' inducing irreducibly to `tbls3'
          ext,         # list of pairs corresponding to irreducibles of
                       # `tbls3' that are extensions from `tbl2' and `tbl3'
          chi,         # loop over `irrs3'
          pos2,        # position in `irr2'
          rest,        # one restricted character
          irr,
          fus3,
          proj3,
          zeroon2,
          proj2,
          proj2o,
          pair,
          chii,
          chio,
          perm;

    irr2  := Irr( tbl2 );
    irr3  := Irr( tbl3 );
    irrs3 := Irr( tbls3 );

    ind:= Induced( tbl2, tbls3, Irr( tbl2 ) );
    ind2:= Filtered( [ 1 .. Length( ind ) ],
                     i -> Position( ind, ind[i] ) = i and ind[i] in irrs3 );
    oldind:= ind;

    ind:= Induced( tbl3, tbls3, Irr( tbl3 ) );
    ind3:= [];
    for i in [ 1 .. Length( ind ) ] do
      if ind[i] in irrs3 and not ind[i] in oldind then
        pos:= Position( ind, ind[i] );
        if pos <> i then
          Add( ind3, [ pos, i ] );
        fi;
      fi;
    od;

    ext:= [];
    for chi in irrs3 do
      rest:= Restricted( tbls3, tbl3, [ chi ] )[1];
      pos:= Position( irr3, rest );
      if pos <> fail and ForAll( ext, x -> x[1] <> pos ) then
        rest:= Restricted( tbls3, tbl2, [ chi ] )[1];
        pos2:= Position( irr2, rest );
        if pos2 <> fail then
          Add( ext, [ pos, pos2 ] );
        fi;
      fi;
    od;

    # Put the characters together, for computing the necessary permutation.
    # (Use the same code as in `ConstructGS3'.
    irr:= Induced( tbl2, tbls3, Irr( tbl2 ){ind2} );
    fus3:= GetFusionMap( tbl3, tbls3 );
    proj3:= ProjectionMap( fus3 );
    zeroon2:= Zero( Difference( [ 1 .. NrConjugacyClasses( tbls3 ) ],
                                fus3 ) );
    proj2:= ProjectionMap( GetFusionMap( tbl2, tbls3 ) );
    pos:= First( [ 1 .. Length( proj2 ) ], x -> not IsBound( proj2[x] ) );
    pos:= First( [ pos .. Length( proj2 ) ], x -> IsBound( proj2[x] ) );
    proj2o:= proj2{ [ pos .. Length( proj2 ) ] };
    Append( irr, List( ind3,
        pair -> Concatenation( Sum( irr3{ pair } ){ proj3 }, zeroon2 ) ) );
    for pair in ext do
      chii := irr3[pair[1]]{proj3};
      chio := irr2[pair[2]]{proj2o};
      Add( irr, Concatenation( chii, chio ) );
      Add( irr, Concatenation( chii, - chio ) );
    od;
    perm := Sortex( irr ) / Sortex( ShallowCopy( Irr( tbls3 ) ) );

    # Return the result.
    return rec( ind2:= ind2, ind3:= ind3, ext:= ext, perm := perm,
                list:= [ "ConstructGS3",
                         Identifier( tbl2 ), Identifier( tbl3 ),
                         ind2, ind3, ext, perm ] );
    end );


#############################################################################
##
#F  ConstructPermuted( <tbl>, <libnam>[, <prmclasses>, <prmchars>] )
##
InstallGlobalFunction( ConstructPermuted,
    function( arg )
    local tbl, t;

    tbl:= arg[1];

    # There may be fusions into `tbl',
    # so we must guarantee a trivial class permutation.
    if not IsBound( tbl.ClassPermutation ) then
      tbl.ClassPermutation:= ();
    fi;

    # Get the permuted table.
    t:= CallFuncList( CharacterTableFromLibrary, arg[2] );
    if 2 < Length( arg ) and not IsOne( arg[3] ) then
      t:= CharacterTableWithSortedClasses( t, arg[3] );
    fi;
    if 3 < Length( arg ) and not IsOne( arg[4] ) then
      t:= CharacterTableWithSortedCharacters( t, arg[4] );
    fi;

    # Store the components in `tbl'.
    TransferComponentsToLibraryTableRecord( t, tbl );

    # Remove attribute values that may contradict the compatibility
    # between several tables.
    Unbind( tbl.FusionToTom );
    end );


#############################################################################
##
#F  ConstructFactor( <tbl>, <libnam>, <kernel> )
##
InstallGlobalFunction( ConstructFactor, function( tbl, libnam, kernel )
    local t;

    # Construct the required table of the factor group.
    t:= CharacterTableFactorGroup( CallFuncList( CharacterTableFromLibrary,
                                                 libnam ),
                                   kernel );

    # Store the components in `tbl'.
    TransferComponentsToLibraryTableRecord( t, tbl );
end );


#############################################################################
##
#F  ConstructClifford( <tbl>, <cliffordtable> )
##
InstallGlobalFunction( ConstructClifford, function( tbl, cliffordtable )
    local i, j, n,
          AnzTi,
          tables,
          ct,        # list of lists of relevant characters,
                     # one for each inertia factor group
          clmexp,
          clmat,
          matsize,
          grps,
          newct,     # the list of irreducibles of `tbl'
          rowct,     # actual row
          colct,     # actual column
          eintr,
          chars,
          linear,
          chi,       # loop over a character list
          lin,
          new;

    # Get the character tables of the inertia groups,
    # and store the relevant list of characters.
    tables:= cliffordtable[2];
    AnzTi:= Length( tables );
    ct:= [];
    for i in [ 1 .. AnzTi ] do
      if tables[i][1] = "projectives" then
        eintr:= CharacterTableFromLibrary( tables[i][2] );
      else
        eintr:= CallFuncList( CharacterTableFromLibrary, tables[i] );
      fi;
      if eintr = fail then
        Error( "table of inertia factor group `", tables[i],
               "' not in the library" );
      fi;
      if tables[i][1] = "projectives" then

        # We must multiply the stored projectives with all linear characters
        # of the factor group in order to get the full list.
        chars:= First( ProjectivesInfo( eintr ),
                       x -> x.name = tables[i][3] ).chars;
        ct[i]:= [];
        linear:= List( Filtered( Irr( eintr ), x -> x[1] = 1 ),
                       ValuesOfClassFunction );
        n:= NrConjugacyClasses( eintr );
        for chi in chars do
          for lin in linear do
            new:= List( [ 1 .. n ], x -> chi[x] * lin[x] );
            if not new in ct[i] then
              Add( ct[i], new );
            fi;
          od;
        od;

      else
        ct[i]:= List( Irr( eintr ), ValuesOfClassFunction );
      fi;
    # tables[i]:= eintr;
    od;

    # Construct the matrix of irreducible characters.
    newct := List( tbl.SizesCentralizers, x -> [] );
    colct := 0;

    for i in cliffordtable[3] do

      # Get the necessary components of the `i'-th Clifford matrix,
      # and multiply it with the character tables of inertia factor groups.

      clmexp  := UnpackedCll( i );
      clmat   := clmexp.mat;
      matsize := Length( clmat );
      grps    := clmexp.inertiagrps;

      # Loop over the columns of the matrix.
      for n in [ 1 .. matsize ] do

        rowct := 0;
        colct := colct + 1;

        # Loop over the inertia factor groups.
        for j in [ 1 .. AnzTi ] do
          for chi in ct[j] do
            rowct:= rowct + 1;
            newct[rowct][colct]:= Sum( Filtered( [ 1 .. matsize ],
                                                 r -> grps[r] = j ),
#T this value is indep. of chi!
               x -> clmat[x][n] * chi[ clmexp.fusionclasses[x] ]);
#T Eventually it should be possible to handle tables where not all
#T classes belonging to a Clifford matrix are expected to be
#T subsequent ...
#T (add an indirection by the fusion)
          od;
        od;

      od;

    od;

    tbl.Irr := newct;
end );


#############################################################################
##
#F  IBrOfExtensionBySingularAutomorphism( <modtbl>, <perm> )
#F  IBrOfExtensionBySingularAutomorphism( <modtbl>, <orbits> )
#F  IBrOfExtensionBySingularAutomorphism( <modtbl>, <ordexttbl> )
##
InstallGlobalFunction( IBrOfExtensionBySingularAutomorphism,
    function( modtbl, ordexttbl )
    local ordtbl, p, fus, orbits, extirr, nccl, chi, comp, sum, i;

    ordtbl:= OrdinaryCharacterTable( modtbl );
    p:= UnderlyingCharacteristic( modtbl );

    # Get the fusion into `modexttbl' (without constructing `modexttbl').
    if   IsOrdinaryTable( ordexttbl ) then
      # Check the consistency of the arguments.
      if Size( ordexttbl ) <> p * Size( ordtbl ) then
        Error( "<ordexttbl> is not an index <p> extension of <ordtbl>" );
      fi;

      # Compute the action.
      fus:= GetFusionMap( ordtbl, ordexttbl );
      if   fus = fail then
        Error( "fusion from <ordtbl> to <ordexttbl> is not stored" );
      elif not Set( fus ) in ClassPositionsOfNormalSubgroups( ordexttbl ) then
        Error( "<ordtbl> is not normal in <ordexttbl>" );
      fi;
      fus:= CompositionMaps( fus, GetFusionMap( modtbl, ordtbl ) );

      # Compute the orbits of the automorphism on the classes of `modtbl'.
      orbits:= Compacted( InverseMap( fus ) );
    elif IsPerm( ordexttbl ) then
      orbits:= Set( List( Orbits( Group( ordexttbl ),
                            [ 1 .. NrConjugacyClasses( modtbl ) ] ), Set ) );
    elif IsList( ordexttbl ) then
      orbits:= ordexttbl;
    else
      Error( "<ordexttbl> must be a char. table, a permutation, or a list" );
    fi;

    # Compute the irreducibles.
    extirr:= [];
    nccl:= Length( orbits );
    for chi in Irr( modtbl ) do
      comp:= CompositionMaps( chi, orbits );
      if ForAny( comp, IsList ) then
        # The character is not invariant, so it does not extend.
        sum:= [];
        for i in [ 1 .. nccl ] do
          if IsList( comp[i] ) then
            sum[i]:= Sum( chi{ orbits[i] }, 0 );
          else
            sum[i]:= p * comp[i];
          fi;
        od;
        if not sum in extirr then
          Add( extirr, sum );
        fi;
      else
        # The character is invariant, so it extends uniquely.
        Add( extirr, comp );
      fi;
    od;

    # Return the result;
    return extirr;
end );


#############################################################################
##
##  5. Character Tables of Subdirect Products of Index Two
##
##  Besides the documented function
##  `CharacterTableOfIndexTwoSubdirectProduct',
##  we need the utilities `IrreducibleCharactersOfIndexTwoSubdirectProduct'
##  and `ClassFusionsForIndexTwoSubdirectProduct'.
##


#############################################################################
##
#F  IrreducibleCharactersOfIndexTwoSubdirectProduct( <irrH1xH2>, <irrG1xG2>,
#F      <H1xH2fusG>, <GfusG1xG2> )
##
##  We do not want to use the table head of the subdirect product because
##  this function is also called by `ConstructIndexTwoSubdirectProduct',
##  and there just a record is available from which the table is computed
##  later.
##
BindGlobal( "IrreducibleCharactersOfIndexTwoSubdirectProduct",
    function( irrH1xH2, irrG1xG2, H1xH2fusG, GfusG1xG2 )
    local H1xH2fusG1xG2, restpos, i, rest, pos, irr, zero, proj1, perm,
          proj2, chi, ind, j;

    H1xH2fusG1xG2:= CompositionMaps( GfusG1xG2, H1xH2fusG );

    # Compute which irreducibles of H1xH2 extend to G1xG2.
    restpos:= List( irrH1xH2, x -> [] );
    for i in [ 1 .. Length( irrG1xG2 ) ] do
      rest:= ValuesOfClassFunction( irrG1xG2[i] ){ H1xH2fusG1xG2 };
      pos:= Position( irrH1xH2, rest );
      if pos <> fail then
        Add( restpos[ pos ], i );
      fi;
    od;
    irr:= [];
    zero:= 0 * GfusG1xG2;
    proj1:= ProjectionMap( H1xH2fusG );
    perm:= Product( List( Filtered( InverseMap( H1xH2fusG ), IsList ),
                          l -> ( l[1], l[2] ) ), () );
    proj2:= [];
    for i in [ 1 .. Length( proj1 ) ] do
      if IsBound( proj1[i] ) then
        proj2[i]:= proj1[i]^perm;
      fi;
    od;
    for i in [ 1 .. Length( irrH1xH2 ) ] do
      if not IsEmpty( restpos[i] ) then
        # The i-th irreducible of H1xH2 extends to G1xG2.
        # Restrict these extensions to G.
        Append( irr, DuplicateFreeList( List( irrG1xG2{ restpos[i] },
                                              chi -> chi{ GfusG1xG2 } ) ) );
      else
        # The i-th irreducible character of H1xH2 has inertia subgroup one of
        # H1xG2 or G1xH2, so it induces irreducibly to G.
        # Compute the induced character (without using the table head).
        chi:= irrH1xH2[i];

        # The curly bracket operator works only for dense sublists.
        # ind:= ShallowCopy( zero ) + chi{ proj1 } + chi{ proj2 };
        ind:= ShallowCopy( zero );
        for j in [ 1 .. Length( proj1 ) ] do
          if IsBound( proj1[j] ) then
            ind[j]:= ind[j] + chi[ proj1[j] ];
          fi;
        od;
        for j in [ 1 .. Length( proj2 ) ] do
          if IsBound( proj2[j] ) then
            ind[j]:= ind[j] + chi[ proj2[j] ];
          fi;
        od;

        if not ind in irr then
          Add( irr, ind );
        fi;
      fi;
    od;

    return irr;
end );


#############################################################################
##
#F  ClassFusionsForIndexTwoSubdirectProduct( <tblH1>, <tblG1>, <tblH2>,
#F                                           <tblG2> )
##
##  It is assumed that all tables are either ordinary tables or Brauer tables
##  for the same characteristic.
##
##  Note that the components `GfusG1xG2', `Gclasses', `Gorders' refer only to
##  the classes inside the normal subgroup `<tblH1> * <tblH2>'.
##
DeclareGlobalFunction( "ClassFusionsForIndexTwoSubdirectProduct" );

InstallGlobalFunction( ClassFusionsForIndexTwoSubdirectProduct,
    function( tblH1, tblG1, tblH2, tblG2 )
    local p, H1classes, H2classes, H1orders, H2orders, H1fusG1, H2fusG2,
          inv1, inv2, ncclH2, ncclG2, H1xH2fusG, GfusG1xG2,
          Gclasses, Gorders, i1, i2, posG1xG2, len, pos,
          ordH1, ordG1, ordH2, ordG2, info, modGfusordG, modfus2,
          modG1xG2fusordG1xG2, modH1xH2fusordH1xH2;

    p:= UnderlyingCharacteristic( tblH1 );
    if p = 0 then

      H1classes:= SizesConjugacyClasses( tblH1 );
      H2classes:= SizesConjugacyClasses( tblH2 );
      H1orders:= OrdersClassRepresentatives( tblH1 );
      H2orders:= OrdersClassRepresentatives( tblH2 );
      H1fusG1:= GetFusionMap( tblH1, tblG1 );
      if H1fusG1 = fail then
        H1fusG1:= RepresentativesFusions( tblH1,
                      PossibleClassFusions( tblH1, tblG1 ), tblG1 );
        if Length( H1fusG1 ) <> 1 then
          Error( "fusion <tblH1> to <tblG1> is not determined" );
        fi;
      fi;
      H2fusG2:= GetFusionMap( tblH2, tblG2 );
      if H2fusG2 = fail then
        H2fusG2:= RepresentativesFusions( tblH2,
                      PossibleClassFusions( tblH2, tblG2 ), tblG2 );
        if Length( H2fusG2 ) <> 1 then
          Error( "fusion <tblH2> to <tblG2> is not determined" );
        fi;
      fi;
      inv1:= InverseMap( H1fusG1 );
      inv2:= InverseMap( H2fusG2 );
      ncclH2:= Length( H2classes );
      ncclG2:= NrConjugacyClasses( tblG2 );
      H1xH2fusG:= [];
      GfusG1xG2:= [];
      Gclasses:= [];
      Gorders:= [];
  
      for i1 in [ 1 .. Length( inv1 ) ] do
        if IsBound( inv1[ i1 ] ) then
          for i2 in [ 1 .. Length( inv2 ) ] do
            if IsBound( inv2[ i2 ] ) then
              posG1xG2:= ( i1 - 1 ) * ncclG2 + i2;
              if IsInt( inv1[ i1 ] ) then
                if IsInt( inv2[ i2 ] ) then
                  # no fusion
                  len:= Length( GfusG1xG2 ) + 1;
                  H1xH2fusG[ ( inv1[ i1 ] - 1 ) * ncclH2 + inv2[ i2 ] ]:= len;
                  GfusG1xG2[ len ]:= posG1xG2;
                  Gclasses[ len ]:= H1classes[ inv1[ i1 ] ]
                                    * H2classes[ inv2[ i2 ] ];
                  Gorders[ len ]:= LcmInt( H1orders[ inv1[ i1 ] ],
                                           H2orders[ inv2[ i2 ] ] );
                else
                  # fusion from H2 to G2
                  len:= Length( GfusG1xG2 ) + 1;
                  for pos in inv2[ i2 ] do
                    H1xH2fusG[ ( inv1[ i1 ] - 1 ) * ncclH2 + pos ]:= len;
                  od;
                  GfusG1xG2[ len ]:= posG1xG2;
                  Gclasses[ len ]:= 2 * H1classes[ inv1[ i1 ] ]
                                      * H2classes[ inv2[ i2 ][1] ];
                  Gorders[ len ]:= LcmInt( H1orders[ inv1[ i1 ] ],
                                           H2orders[ inv2[ i2 ][1] ] );
                fi;
              elif IsInt( inv2[ i2 ] ) then
                # fusion from H1 to G1
                len:= Length( GfusG1xG2 ) + 1;
                for pos in inv1[ i1 ] do
                  H1xH2fusG[ ( pos - 1 ) * ncclH2 + inv2[ i2 ] ]:= len;
                od;
                GfusG1xG2[ len ]:= posG1xG2;
                Gclasses[ len ]:= 2 * H1classes[ inv1[ i1 ][1] ]
                                    * H2classes[ inv2[ i2 ] ];
                Gorders[ len ]:= LcmInt( H1orders[ inv1[ i1 ][1] ],
                                         H2orders[ inv2[ i2 ] ] );
              else
                # fusion in both factors (get two classes)
                len:= Length( GfusG1xG2 ) + 1;
                H1xH2fusG[ ( inv1[ i1 ][1]-1 ) * ncclH2 + inv2[i2][1] ]:= len;
                H1xH2fusG[ ( inv1[ i1 ][2]-1 ) * ncclH2 + inv2[i2][2] ]:= len;
                GfusG1xG2[ len ]:= posG1xG2;
                Gclasses[ len ]:= 2 * H1classes[ inv1[ i1 ][1] ]
                                    * H2classes[ inv2[ i2 ][1] ];
                Gorders[ len ]:= LcmInt( H1orders[ inv1[ i1 ][1] ],
                                         H2orders[ inv2[ i2 ][1] ] );
                H1xH2fusG[ ( inv1[i1][1]-1 ) * ncclH2 + inv2[i2][2] ]:= len + 1;
                H1xH2fusG[ ( inv1[i1][2]-1 ) * ncclH2 + inv2[i2][1] ]:= len + 1;
                GfusG1xG2[ len + 1 ]:= posG1xG2;
                Gclasses[ len + 1 ]:= Gclasses[ len ];
                Gorders[ len + 1 ]:= Gorders[ len ];
              fi;
            fi;
          od;
        fi;
      od;

    else

      ordH1:= OrdinaryCharacterTable( tblH1 );
      ordG1:= OrdinaryCharacterTable( tblG1 );
      ordH2:= OrdinaryCharacterTable( tblH2 );
      ordG2:= OrdinaryCharacterTable( tblG2 );

      # Compute the maps for the underlying ordinary tables.
      info:= ClassFusionsForIndexTwoSubdirectProduct( ordH1, ordG1,
                                                      ordH2, ordG2 );

      # Compute the embeddings of `p'-regular classes of G, H1xH2, G1xG2,
      # without actually constructing these tables.
      modGfusordG:= Filtered( [ 1 .. Length( info.Gorders ) ],
                              i -> info.Gorders[i] mod p <> 0 );
      modfus2:= GetFusionMap( tblG2, ordG2 );
      modG1xG2fusordG1xG2:= Concatenation(
          List( GetFusionMap( tblG1, ordG1 ),
                i -> modfus2 + ( i - 1 ) * NrConjugacyClasses( ordG2 ) ) );
      modfus2:= GetFusionMap( tblH2, ordH2 );
      modH1xH2fusordH1xH2:= Concatenation(
          List( GetFusionMap( tblH1, ordH1 ),
                i -> modfus2 + ( i - 1 ) * NrConjugacyClasses( ordH2 ) ) );

      # Compute the maps for the Brauer tables.
      H1xH2fusG:= CompositionMaps( InverseMap( modGfusordG ),
                      CompositionMaps( info.H1xH2fusG, modH1xH2fusordH1xH2 ) );
      GfusG1xG2:= CompositionMaps( InverseMap( modG1xG2fusordG1xG2 ),
                      CompositionMaps( info.GfusG1xG2, modGfusordG ) );
      Gclasses:= info.Gclasses{ modGfusordG };
      Gorders:= info.Gorders{ modGfusordG };
    fi;

    return rec( H1xH2fusG:= H1xH2fusG,
                GfusG1xG2:= GfusG1xG2,
                Gclasses:= Gclasses,
                Gorders:= Gorders,
              );
end );


#############################################################################
##
#F  CharacterTableOfIndexTwoSubdirectProduct( <tblH1>, <tblG1>,
#F       <tblH2>, <tblG2>, <identifier> )
##
InstallGlobalFunction( CharacterTableOfIndexTwoSubdirectProduct,
    function( tblH1, tblG1, tblH2, tblG2, identifier )
    local char, ordtblG, permcols, info, H1fusG1, H2fusG2, H1xH2fusG,
          GfusG1xG2, Gclasses, H1xH2, G1xG2, H1fusG1xG2, H2fusG1xG2, nsg,
          outer, tblG, powermap, p, pow, i, j, irrH1xH2, irrG1xG2, fus,
          result;

    # Fetch the underlying characteristic, and check the arguments.
    char:= UnderlyingCharacteristic( tblH1 );
    if ForAny( [ tblG1, tblH2, tblG2 ],
               t -> UnderlyingCharacteristic( t ) <> char ) then
      Info( InfoCharacterTable, 1,
            "CharacterTableOfIndexTwoSubdirectProduct:\n",
            "#I  UnderlyingCharacteristic values of input tables differ" );
      return fail;
    fi;
    if char = 0 then
      if not IsString( identifier ) then
        Info( InfoCharacterTable, 1,
              "CharacterTableOfIndexTwoSubdirectProduct:\n",
              "#I  <identifier> must be a string" );
        return fail;
      fi;
    elif IsOrdinaryTable( identifier ) then
      ordtblG:= identifier;
      permcols:= ();
    elif IsList( identifier ) and Length( identifier ) = 2
         and IsOrdinaryTable( identifier[1] ) then
      ordtblG:= identifier[1];
      permcols:= identifier[2];
    else
      Info( InfoCharacterTable, 1,
            "CharacterTableOfIndexTwoSubdirectProduct:\n",
            "#I  <identifier> must be the ordinary table of the result" );
      return fail;
    fi;

    # Initialize auxiliary tables and fusions.
    info:= ClassFusionsForIndexTwoSubdirectProduct( tblH1, tblG1, tblH2,
                                                    tblG2 );
    H1fusG1:= GetFusionMap( tblH1, tblG1 );
    H2fusG2:= GetFusionMap( tblH2, tblG2 );
    H1xH2fusG:= info.H1xH2fusG;
    GfusG1xG2:= info.GfusG1xG2;

    if char = 0 then
      Gclasses:= info.Gclasses;

      # Compute the outer classes of G.
      # For that, determine the unique index two subgroup
      # that contains H1 and H2 but none of G1, G2.
      H1xH2:= CharacterTableDirectProduct( tblH1, tblH2 );
      G1xG2:= CharacterTableDirectProduct( tblG1, tblG2 );
      H1fusG1xG2:= CompositionMaps( GetFusionMap( tblG1, G1xG2 ), H1fusG1 );
      H2fusG1xG2:= CompositionMaps( GetFusionMap( tblG2, G1xG2 ), H2fusG2 );
      nsg:= Filtered( ClassPositionsOfNormalSubgroups( G1xG2 ),
                x ->     Sum( SizesConjugacyClasses( G1xG2 ){ x } )
                           = Size( G1xG2 ) / 2
                     and not IsSubset( x, GetFusionMap( tblG1, G1xG2 ) )
                     and not IsSubset( x, GetFusionMap( tblG2, G1xG2 ) )
                     and IsSubset( x, H1fusG1xG2 )
                     and IsSubset( x, H2fusG1xG2 ) );
      outer:= Difference( nsg[1],
                  ClassPositionsOfNormalClosure( G1xG2,
                      Union( H1fusG1xG2, H2fusG1xG2 ) ) );
      Append( GfusG1xG2, outer );
      Append( Gclasses, SizesConjugacyClasses( G1xG2 ){ outer } );

      # Initialize the record for the character table `tblG'.
      tblG:= rec(
                  UnderlyingCharacteristic := 0,
                  Identifier := identifier,
                  Size := 2 * Size( H1xH2 ),
                  SizesConjugacyClasses := Gclasses,
                  OrdersClassRepresentatives :=
                      OrdersClassRepresentatives( G1xG2 ){ GfusG1xG2 },
                );
      tblG.SizesCentralizers:= List( Gclasses, x -> tblG.Size / x );

      # Convert the record to a table object.
      ConvertToLibraryCharacterTableNC( tblG );

      # Put the power maps together.
      powermap:= ComputedPowerMaps( tblG );
      for p in Set( Factors( Size( tblG ) ) ) do
        pow:= InitPowerMap( tblG, p );
        TransferDiagram( pow, GfusG1xG2, PowerMap( G1xG2, p ) );
        TransferDiagram( PowerMap( H1xH2, p ), H1xH2fusG, pow );
        powermap[p]:= pow;
        Assert( 1, ForAll( pow, IsInt ),
                Concatenation( Ordinal( p ),
                               " power map not uniquely determined" ) );
      od;

      # Store the factor fusions.
      # (Note that the containment of classes modulo H1 and H2 can be decided
      # in the bigger group G1xG2.
      StoreFusion( tblG, CompositionMaps( GetFusionMap( G1xG2, tblG1 ),
                                          GfusG1xG2 ),
                   tblG1 );
      StoreFusion( tblG, CompositionMaps( GetFusionMap( G1xG2, tblG2 ),
                                          GfusG1xG2 ),
                   tblG2 );
      irrH1xH2:= Irr( H1xH2 );
      irrG1xG2:= Irr( G1xG2 );

      # Set the construction info,
      # in order to enable the computation of Brauer tables.
      SetConstructionInfoCharacterTable( tblG,
          [ "ConstructIndexTwoSubdirectProduct",
            Identifier( tblH1 ), Identifier( tblG1 ),
            Identifier( tblH2 ), Identifier( tblG2 ),
            outer, (), () ] );

    else

      # The table head is derived from the known ordinary table.
      # All we need to construct are the irreducibles.
      tblG:= CharacterTableRegular( ordtblG, char );

      # Rewrite the class permutation to the p-regular classes.
      fus:= GetFusionMap( tblG, ordtblG );
      permcols:= SortingPerm( OnTuples( fus, permcols^-1 ) )^-1;

      # Adjust the fusions to the sorted table head.
      H1xH2fusG:= OnTuples( H1xH2fusG, permcols );
      outer:= [];
      for i in [ 1 .. NrConjugacyClasses( tblG1 ) ] do
        for j in [ 1 .. NrConjugacyClasses( tblG2 ) ] do
          if not ( i in H1fusG1 or j in H2fusG2 ) then
            Add( outer, j + ( i - 1 ) * NrConjugacyClasses( tblG2 ) );
          fi;
        od;
      od;
      GfusG1xG2:= Permuted( Concatenation( GfusG1xG2, outer ), permcols );

      # Form the irreducibles of the subgroup and the supergroup.
      irrH1xH2:= KroneckerProduct( Irr( tblH1 ), Irr( tblH2 ) );
      irrG1xG2:= KroneckerProduct( Irr( tblG1 ), Irr( tblG2 ) );

    fi;

    SetInfoText( tblG,
        "constructed using `CharacterTableOfIndexTwoSubdirectProduct'" );

    # Compute the irreducibles.
    SetIrr( tblG, List( IrreducibleCharactersOfIndexTwoSubdirectProduct(
                            irrH1xH2, irrG1xG2, H1xH2fusG, GfusG1xG2 ),
                        chi -> Character( tblG, chi ) ) );

    # Return the result.
    result:= rec( table:= tblG );
    if char = 0 then
      result.H1fusG:= CompositionMaps( H1xH2fusG,
                                       GetFusionMap( tblH1, H1xH2 ) );
      result.H2fusG:= CompositionMaps( H1xH2fusG,
                                       GetFusionMap( tblH2, H1xH2 ) );
      result.outerfus:= outer;
    fi;
    return result;
end );


#############################################################################
##
#F  ConstructIndexTwoSubdirectProduct( <tbl>, <tblH1>, <tblG1>, <tblH2>,
#F      <tblG2>, <outerfus>, <permclasses>, <permchars> )
##
InstallGlobalFunction( ConstructIndexTwoSubdirectProduct,
    function( tbl, tblH1, tblG1, tblH2, tblG2, outerfus,
              permclasses, permchars )
    local info, irreds;

    tblH1:= CharacterTable( tblH1 );
    tblG1:= CharacterTable( tblG1 );
    tblH2:= CharacterTable( tblH2 );
    tblG2:= CharacterTable( tblG2 );
    info:= ClassFusionsForIndexTwoSubdirectProduct(
               tblH1, tblG1, tblH2, tblG2 );
    irreds:= IrreducibleCharactersOfIndexTwoSubdirectProduct(
                 KroneckerProduct( Irr( tblH1 ), Irr( tblH2 ) ),
                 KroneckerProduct( Irr( tblG1 ), Irr( tblG2 ) ),
                 info.H1xH2fusG, Concatenation( info.GfusG1xG2, outerfus ) );
    tbl.Irr:= Permuted( List( irreds, chi -> Permuted( chi, permclasses ) ),
                        permchars );
end );


#############################################################################
##
#F  ConstructIndexTwoSubdirectProductInfo( <tbl>[, <tblH1>, <tblG1>, 
#F      <tblH2>, <tblG2>] )
##
InstallGlobalFunction( ConstructIndexTwoSubdirectProductInfo,
    function( arg )
    local tbl, nsg, sizes, Gsize, result, i, j, k, r, fact1, fact2,
          name1, sub1, name2, sub2, cand, tblH1, tblG1, tblH2, tblG2,
          trans, rr;

    # Get and check the arguments.
    if Length( arg ) = 1 then

      tbl:= arg[1];
      # Check whether the table has the required structure.
      if not IsEmpty( ClassPositionsOfDirectProductDecompositions( tbl ) ) then
        # The structure is in fact better.
        Info( InfoCharacterTable, 2,
              "the table of `", Identifier( tbl ),
              "' is a nontrivial direct product" );
        return [];
      fi;
      nsg:= ClassPositionsOfNormalSubgroups( tbl );
      sizes:= List( nsg, x -> Sum( SizesConjugacyClasses( tbl ){ x } ) );
      Gsize:= Size( tbl ) / 2;
      result:= [];
      for i in Filtered( [ 1 .. Length( nsg ) ], x -> sizes[x] = Gsize ) do
        for j in [ 1 .. Length( nsg ) ] do
          if nsg[j] <> [ 1 ] then
# and IsSubset( nsg[i], nsg[j] ) !! (outside the k loop!)
            for k in [ 1 .. j-1 ] do
              if nsg[k] <> [ 1 ]
                 and Intersection( nsg[j], nsg[k] ) = [ 1 ]
                 and IsSubset( nsg[i], nsg[j] ) # move outside the k loop!
                 and IsSubset( nsg[i], nsg[k] )
                 and sizes[j] * sizes[k] = Gsize then

                # One decomposition has been found.
                r:= rec( kernels:= [ nsg[j], nsg[k] ],
                         kernelsizes:= [ sizes[j], sizes[k] ],
                         factors:= [ fail, fail ],
                         subgroups:= [ fail, fail ],
                       );

                # Try to derive the character tables of the ingredients.
                fact1:= First( ComputedClassFusions( tbl ),
                    r -> ClassPositionsOfKernel( r.map ) = nsg[j] );
                if fact1 <> fail then
                  r.factors[1]:= fact1.name;
                  fact1:= CharacterTable( fact1.name );
                fi;
                fact2:= First( ComputedClassFusions( tbl ),
                    r -> ClassPositionsOfKernel( r.map ) = nsg[k] );
                if fact2 <> fail then
                  r.factors[2]:= fact2.name;
                  fact2:= CharacterTable( fact2.name );
                fi;
                if fact1 <> fail and fact2 <> fail then
                  Unbind( rr );
                  for name1 in NamesOfFusionSources( fact1 ) do
                    sub1:= CharacterTable( name1 );
                    if sub1 <> fail and Size( sub1 ) = Size( fact1 ) / 2 then
                      for name2 in NamesOfFusionSources( fact2 ) do
                        sub2:= CharacterTable( name2 );
                        if sub2 <> fail and
                           Size( sub2 ) = Size( fact2 ) / 2 then
                          cand:= CharacterTableOfIndexTwoSubdirectProduct(
                                     sub1, fact1, sub2, fact2, "test" );
                          trans:= TransformingPermutationsCharacterTables(
                                      tbl, cand.table );
                          if trans <> fail then
                            rr:= ShallowCopy( r );
                            rr.subgroups:= [ name1, name2 ];
                            Add( result, rr );
                          fi;
                        fi;
                      od;
                    fi;
                  od;
                  if not IsBound( rr ) then
                    Add( result, r );
                  fi;
                else
                  Add( result, r );
                fi;
              fi;
            od;
          fi;
        od;
      od;
      return result;

    elif Length( arg ) = 5 then

      tblH1:= arg[2];
      tblG1:= arg[3];
      tblH2:= arg[4];
      tblG2:= arg[5];

      # Check the construction from the given tables.
      cand:= CharacterTableOfIndexTwoSubdirectProduct(
                 tblH1, tblG1, tblH2, tblG2, "test" );
      trans:= TransformingPermutationsCharacterTables( cand.table, arg[1] );
      if trans <> fail then
        return [ "ConstructIndexTwoSubdirectProduct",
                 Identifier( tblH1 ), Identifier( tblG1 ),
                 Identifier( tblH2 ), Identifier( tblG2 ),
                 cand.outerfus,
                 trans.columns, trans.rows ];
      fi;
      return fail;

    else
      Error( "usage: ConstructIndexTwoSubdirectProductInfo( <tbl>\n",
             "[, <tblH1>, <tblG1>, <tblH2>, <tblG2>] )" );
    fi;
end );


#############################################################################
##
##  8. Character Tables of Coprime Central Extensions
##


#############################################################################
##
#F  CharacterTableOfCommonCentralExtension( <tblG>, <tblmG>, <tblnG>, <id> )
##
InstallGlobalFunction( CharacterTableOfCommonCentralExtension,
    function( tblG, tblmG, tblnG, id )
    local mGfusG, nGfusG, m, n, M, invm, invn, i, ordersG, ordersmG,
          ordersnG, try, facttbl, factfusion, newinvm, newinvn, mnGfusmG,
          mnGfusnG, lenm, lenn, j, imod, jmod, cents, invmnGfusmG, pow, p,
          comp, tblmnG, ker, faithm, faithn, irr, centre, ordersmnG, zpos,
          needed, faithmn, partners, chi;

    # Check the arguments.
    mGfusG:= GetFusionMap( tblmG, tblG );
    nGfusG:= GetFusionMap( tblnG, tblG );
    if mGfusG = fail or nGfusG = fail then
      Error( "the fusions <tblmG>, <tblnG> ->> <tblG> must be stored" );
    fi;
    m:= Size( tblmG ) / Size( tblG );
    n:= Size( tblnG ) / Size( tblG );
    if   not IsPrimeInt( m ) then
      Error( "<tblmG> ->> <tblG> must be a prime order extension" );
    elif not IsPrimeInt( n ) then
      Error( "<tblnG> ->> <tblG> must be a prime order extension" );
    elif m = n then
      Error( "<tblmG>, <tblnG> ->> <tblG> must have coprime kernel" );
    elif not IsSubset( ClassPositionsOfCentre( tblmG ),
                       ClassPositionsOfKernel( mGfusG ) ) then
      Error( "<tblmG> must be a central extension of <tblG>" );
    elif not IsSubset( ClassPositionsOfCentre( tblnG ),
                       ClassPositionsOfKernel( nGfusG ) ) then
      Error( "<tblnG> must be a central extension of <tblG>" );
    fi;
    M:= m * n;

    # Compute compatible fusions from $mn.G$ to $m.G$ and $n.G$.
    invm:= InverseMap( mGfusG );
    invn:= InverseMap( nGfusG );
    for i in [ 1 .. Length( invm ) ] do
      if IsInt( invm[i] ) then
        invm[i]:= [ invm[i] ];
      fi;
      if IsInt( invn[i] ) then
        invn[i]:= [ invn[i] ];
      fi;
    od;

    # Note that $mn.G$ may have a cyclic central subgroup of order $M$
    # larger than $m n$.
    # We consider a largest possible cyclic central extension
    # because then more cohorts of faithful characters exist;
    # note that we have to compute only the characters in one family of
    # Galois conjugate cohorts, and derive the others in the end.
    # The second implication is that we can achieve the class ordering
    # relative to the smaller factor group, as in the {\ATLAS} tables in
    # the {\GAP} Character Table Library.
    ordersG:= OrdersClassRepresentatives( tblG );
    ordersmG:= OrdersClassRepresentatives( tblmG );
    ordersnG:= OrdersClassRepresentatives( tblnG );
    try:= Filtered( ClassPositionsOfCentre( tblG ),
                    x ->     ordersG[x] * m in ordersmG{ invm[x] }
                         and ordersG[x] * n in ordersnG{ invn[x] }
                         and Length( invm[x]  ) = m
                         and Length( invn[x]  ) = n );
    if 1 < Length( try ) then
      # Compute the fusions onto the smaller factor group.
      i:= Maximum( ordersG{ try } );
      facttbl:= tblG / [ try[ Position( ordersG{ try }, i ) ] ];
      factfusion:= GetFusionMap( tblG, facttbl );
      M:= M * Size( tblG ) / Size( facttbl );

      # Choose the class ordering w.r.t. the smaller factor group.
      # For that, replace the inverse maps by compositions with the
      # additional factor fusion, but be careful about compatible congurnces.
      newinvm:= [];
      newinvn:= [];
      for i in InverseMap( factfusion ) do
        if IsInt( i ) then
          Add( newinvm, invm[i] );
          Add( newinvn, invn[i] );
        else
          Add( newinvm, Concatenation( TransposedMat( invm{ i } ) ) );
          Add( newinvn, Concatenation( TransposedMat( invn{ i } ) ) );
        fi;
      od;
      invm:= newinvm;
      invn:= newinvn;
    fi;

    mnGfusmG:= [];
    mnGfusnG:= [];
    for i in [ 1 .. Length( invm ) ] do
      lenm:= Length( invm[i] );
      lenn:= Length( invn[i] );
      for j in [ 1 .. LcmInt( lenm, lenn ) ] do
        # Take only those parameter pairs that are compatible
        # with the fusions onto `tblmG' and `tblnG'.
        imod:= j mod lenm;  if imod = 0 then imod:= lenm; fi;
        Add( mnGfusmG, invm[i][ imod ] );
        jmod:= j mod lenn;  if jmod = 0 then jmod:= lenn; fi;
        Add( mnGfusnG, invn[i][ jmod ] );
      od;
    od;

    # Create the table head.
    cents:= [];
    invmnGfusmG:= InverseMap( mnGfusmG );
    for i in [ 1 .. Length( invmnGfusmG ) ] do
      if IsInt( invmnGfusmG[i] ) then
        cents[ invmnGfusmG[i] ]:= SizesCentralizers( tblmG )[i];
      else
        cents{ invmnGfusmG[i] }:= Length( invmnGfusmG[i] )
            * SizesCentralizers( tblmG ){ List( invmnGfusmG[i], x -> i ) };
      fi;
    od;

    pow:= [];
    for p in Set( Factors( cents[1] ) ) do
      pow[p]:= CompositionMaps( InverseMap( mnGfusmG ),
                   CompositionMaps( PowerMap( tblmG, p ), mnGfusmG ) );
      comp:= CompositionMaps( InverseMap( mnGfusnG ),
                 CompositionMaps( PowerMap( tblnG, p ), mnGfusnG ) );
      MeetMaps( pow[p], comp );
      Assert( 1, ForAll( pow[p], IsInt ) );
    od;

    tblmnG:= ConvertToLibraryCharacterTableNC( rec(
        Identifier                 := id,
        InfoText                   :=
            "constructed using `CharacterTableOfCommonCentralExtension'",
        Size                       := Size( tblmG ) * n,
        UnderlyingCharacteristic   := 0,
        SizesCentralizers          := cents,
        ComputedPowerMaps          := pow,
        OrdersClassRepresentatives := ElementOrdersPowerMap( pow ) ) );

    StoreFusion( tblmnG, mGfusG{ mnGfusmG }, tblG );
    StoreFusion( tblmnG, mnGfusmG, tblmG );
    StoreFusion( tblmnG, mnGfusnG, tblnG );

    # Transfer the known irreducibles.
    ker:= ClassPositionsOfKernel( mGfusG );
    faithm:= Filtered( Irr( tblmG ),
        chi -> not IsSubset( ClassPositionsOfKernel( chi ), ker ) );
    faithm:= List( faithm, chi -> Character( tblmnG, chi{ mnGfusmG } ) );
    ker:= ClassPositionsOfKernel( nGfusG );
    faithn:= Filtered( Irr( tblnG ),
        chi -> not IsSubset( ClassPositionsOfKernel( chi ), ker ) );
    faithn:= List( faithn, chi -> Character( tblmnG, chi{ mnGfusnG } ) );
    if m < n then
      irr:= List( Irr( tblmG ), chi -> Character( tblmnG, chi{ mnGfusmG } ) );
      Append( irr, faithn );
    else
      irr:= List( Irr( tblnG ), chi -> Character( tblmnG, chi{ mnGfusnG } ) );
      Append( irr, faithm );
    fi;

    # Fix a central class on which the values of missing characters
    # can be prescribed as the degree times a fixed root of unity.
    centre:= ClassPositionsOfCentre( tblmnG );
    ordersmnG:= OrdersClassRepresentatives( tblmnG );
    i:= Maximum( ordersmnG{ centre } );
    zpos:= First( centre, x ->     ordersmnG[x] = i
                               and ordersmG[ mnGfusmG[x] ] < ordersmnG[x]
                               and ordersnG[ mnGfusnG[x] ] < ordersmnG[x] );

    # We use a heuristic for finding the irreducibles in one cohort.
    needed:= ( NrConjugacyClasses( tblmnG ) - Length( irr ) ) / Phi( M );
    faithmn:= IrreduciblesForCharacterTableOfCommonCentralExtension( tblmnG,
                  irr, zpos, needed );

    # Create also the other cohorts.
    partners:= GaloisPartnersOfIrreducibles( tblmnG, faithmn, M );
    for i in [ 1 .. Length( faithmn ) ] do
      chi:= faithmn[i];
      Add( irr, chi );
      for j in partners[i] do
        Add( irr, Character( tblmnG, List( chi, x -> GaloisCyc( x, j ) ) ) );
      od;
    od;

    if Length( irr ) = NrConjugacyClasses( tblmnG ) then
      SetIrr( tblmnG, irr );
    fi;

    return rec( tblmnG       := tblmnG,
                IsComplete   := Length( irr ) = NrConjugacyClasses( tblmnG ),
                irreducibles := irr );
    end );


#############################################################################
##
#F  IrreduciblesForCharacterTableOfCommonCentralExtension(
#F      <tblmnG>, <factirreducibles>, <zpos>, <needed> )
##
InstallGlobalFunction( IrreduciblesForCharacterTableOfCommonCentralExtension,
    function( tblmnG, factirreducibles, zpos, needed )
    local id, z, root, cohorts, faithmn, reducibles, i, ten, red, galois,
          lll;

    id:= Identifier( tblmnG );
    Info( InfoCharacterTable, 1,
          id, ": need ", needed, " faithful irreducibles" );

    # Try to find the faithful irreducibles.
    # We restrict our interest to one faithful cohort for each factor,
    # and form tensor products.
    # The faithful cohort is determined by the values of the central class
    # `zpos' of maximal order whose image in both factor groups has smaller
    # element order.
    z:= OrdersClassRepresentatives( tblmnG )[ zpos ];
    root:= E( z );
    cohorts:= List( [ 1 .. z ],
                    i -> Filtered( factirreducibles,
                             x -> x[ zpos ] = x[1] * root^i ) );

    # Take those combinations of two cohorts such that the tensor products
    # lie in the target cohort.
    faithmn:= [];
    reducibles:= [];
    for i in [ 1 .. Int( z / 2 ) ] do
      if not IsEmpty( cohorts[i] ) and not IsEmpty( cohorts[ z+1-i ] ) then
        ten:= TensorAndReduce( tblmnG, cohorts[i], cohorts[ z+1-i ],
                  faithmn, needed );
        red:= ReducedX( tblmnG, ten, reducibles );
        reducibles:= red.remainders;
        if not IsEmpty( red.irreducibles ) then
          Info( InfoCharacterTable, 1,
                id, ": ", Length( red.irreducibles ),
                " found by tensoring" );
          Append( faithmn, red.irreducibles );
          if needed <= Length( faithmn ) then
            return faithmn;
          fi;
        fi;
      fi;
    od;

    # Use Galois conjugates of the found faithful irreducibles
    # to form tensor products that lie in the target cohort.
    for i in [ 1 .. Int( z / 2 ) ] do
      if GcdInt( i, z ) = 1 and not IsEmpty( faithmn )
                            and not IsEmpty( cohorts[ z+1-i ] ) then
        galois:= List( faithmn, x -> List( x, y -> GaloisCyc( y, i ) ) );
        ten:= TensorAndReduce( tblmnG, cohorts[ z+1-i ], galois,
                  faithmn, needed );
        red:= ReducedX( tblmnG, ten, reducibles );
        reducibles:= red.remainders;
        if not IsEmpty( red.irreducibles ) then
          Info( InfoCharacterTable, 1,
                id, ": ", Length( red.irreducibles ),
                " found by further tensoring" );
          Append( faithmn, red.irreducibles );
          if needed <= Length( faithmn ) then
            return faithmn;
          fi;
        fi;
      fi;
    od;

    # Use LLL.
    lll:= LLL( tblmnG, reducibles );
    if not IsEmpty( lll.irreducibles ) then
      Info( InfoCharacterTable, 1,
            id, ": ", Length( lll.irreducibles ), " found by LLL" );
      Append( faithmn, lll.irreducibles );
    fi;
    if needed <= Length( faithmn ) then
      return faithmn;
    fi;

#T The following code was not needed up to now.
# #T make sure that lll.remainders are orthogonal to lll.irreducibles!
# if ForAny( lll.remainders, x -> ForAny( lll.irreducibles, y ->
#            ScalarProduct( tblmnG, x, y ) <> 0 ) ) then
#   Error( "nonorthogonal LLL run!" );
# fi;
# 
#     # Use a combination of tensor products and LLL.
#     irreducibles:= faithmn;
#     while not IsEmpty( irreducibles ) do
# 
#       newirreducibles:=[];
# 
#       # Use tensor products with the newly found faithful irreducibles.
#       ten:= TensorAndReduce( tblmnG, factirreducibles, irreducibles,
#                              faithmn, needed );
#       Info( InfoCharacterTable, 1,
#             id, ": ", Length( ten.irreducibles ), " found by tensoring" );
#       Append( newirreducibles, ten.irreducibles );
#       Append( faithmn, ten.irreducibles );
#       if needed <= Length( faithmn ) then
#         return faithmn;
#       fi;
# 
#       # Use LLL.
#       lll:= LLL( tblmnG, ten.remainders );
#       Info( InfoCharacterTable, 1,
#             id, ": ", Length( lll.irreducibles ), " found by LLL" );
#       Append( newirreducibles, lll.irreducibles );
#       Append( faithmn, lll.irreducibles );
#       if needed <= Length( faithmn ) then
#         return faithmn;
#       fi;
# 
#       irreducibles:= newirreducibles;
# 
#     od;
# 
#     # Use orthogonal embeddings.
#     needed:= needed - Length( faithmn );
#     if 0 < needed then
#       mat:= MatScalarProducts( tblmnG, lll.remainders, lll.remainders );
#       emb:= OrthogonalEmbeddingsSpecialDimension( tblmnG, lll.remainders,
#                 mat, needed );
#       Info( InfoCharacterTable, 1,
#             id, ": ", Length( emb.irreducibles ),
#             " found by orth. embeddings" );
#       UniteSet( faithmn, emb.irreducibles );
#     fi;

    # Sort the irreducibles.
    faithmn:= SortedCharacters( tblmnG, faithmn, "degree" );

    # Return the irreducibles.
    return faithmn;
    end );


#############################################################################
##
##  9. Miscellaneous
##


#############################################################################
##
#F  ReducedX( <tbl>, <redresult>, <chars> )
##
##  In each step, we start with a record irr1/red1 and a list red.
##  After the step, we have a result record irr2/red2 and the list red1.
##
##  red1,irr1    red
##    |    |      |
##    |    --------
##    |        |
##  red1   irr2,red2
##    |      |    |
##    --------    |
##       |        |
##  red3,irr3   red2
##    |    |      |
##    |    --------
##    |        |
##  red3   irr4,red4
##
##
InstallGlobalFunction( ReducedX, function( tbl, redresult, chars )
    local irreducibles, help;

    irreducibles:= ShallowCopy( redresult.irreducibles );
    while not IsEmpty( redresult.irreducibles ) do
      help:= Reduced( tbl, redresult.irreducibles, chars );
      chars:= redresult.remainders;
      redresult:= help;
      Append( irreducibles, redresult.irreducibles );
    od;

    # Return the result.
    return rec( irreducibles := irreducibles,
                remainders   := Concatenation( redresult.remainders, chars ) );
    end );


#############################################################################
##
#F  TensorAndReduce( <tbl>, <chars1>, <chars2>, <irreducibles>, <needed> )
##
InstallGlobalFunction( TensorAndReduce,
    function( tbl, chars1, chars2, irreducibles, needed )
    local newirreducibles,
          reducibles,
          chi,           # loop over `chars1'
          psi,           # loop over `chars2'
          ten,           # one tensor product
          red;

    irreducibles:= ShallowCopy( irreducibles );
    newirreducibles:= [];
    reducibles:= [];
    for chi in chars1 do
      for psi in chars2 do
        ten:= Tensored( [ chi ], [ psi ] );
        ten:= ReducedOrdinary( tbl, irreducibles, ten );
        red:= ReducedX( tbl, ten, reducibles );
        Append( irreducibles, red.irreducibles );
        Append( newirreducibles, red.irreducibles );
        reducibles:= red.remainders;
        if needed <= Length( newirreducibles ) then
          return rec( irreducibles := newirreducibles,
                      remainders   := reducibles );
        fi;
      od;
    od;

    # Return the result.
    return rec( irreducibles := newirreducibles,
                remainders   := reducibles );
    end );

#T analogously: SymmetrizeAndReduce


#############################################################################
##
#E

