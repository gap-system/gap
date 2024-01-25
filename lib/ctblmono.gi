#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Erzsébet Horváth.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the functions dealing with monomiality questions for
##  solvable groups.
##
##  1. Character Degrees and Derived Length
##  2. Primitivity of Characters
##  3. Testing Monomiality
##  4. Minimal Nonmonomial Groups
##


#############################################################################
##
##  1. Character Degrees and Derived Length
##


#############################################################################
##
#M  Alpha( <G> )  . . . . . . . . . . . . . . . . . . . . . . . . for a group
##
InstallMethod( Alpha,
    "for a group",
    [ IsGroup ],
    function( G )

    local irr,        # irreducible characters of `G'
          degrees,    # set of degrees of `irr'
          chars,      # at position <i> all in `irr' of degree `degrees[<i>]'
          chi,        # one character
          alpha,      # result list
          max,        # maximal derived length found up to now
          kernels,    # at position <i> the kernels of all in `chars[<i>]'
          minimal,    # list of minimal kernels
          relevant,   # minimal kernels of one degree
          k,          # one kernel
          ker,
          dl;         # list of derived lengths

    Info( InfoMonomial, 1, "Alpha called for group ", G );

    # Compute the irreducible characters and the set of their degrees;
    # we need all irreducibles so it is reasonable to compute the table.
    irr:= List( Irr( G ), ValuesOfClassFunction );
    degrees:= Set( irr, x -> x[1] );
    RemoveSet( degrees, 1 );

    # Distribute characters to degrees.
    chars:= List( degrees, x -> [] );
    for chi in irr do
      if chi[1] > 1 then
        Add( chars[ Position( degrees, chi[1], 0 ) ], chi );
      fi;
    od;

    # Initialize
    alpha:= [ 1 ];
    max:= 1;

    # Compute kernels (as position lists)
    kernels:= List( chars, x -> Set( x, ClassPositionsOfKernel ) );

    # list of all minimal elements found up to now
    minimal:= [];

    Info( InfoMonomial, 1,
          "Alpha: There are ", Length( degrees )+1, " different degrees." );

    for ker in kernels do

      # We may remove kernels that contain a (minimal) kernel
      # of a character of smaller or equal degree.

      # Make sure to consider minimal elements of the actual degree first.
      SortBy( ker, Length );

      relevant:= [];

      for k in ker do
        if ForAll( minimal, x -> not IsSubsetSet( k, x ) ) then

          # new minimal element found
          Add( relevant, k );
          Add( minimal,  k );

        fi;
      od;

      # Give the trivial kernel a chance to be found first when we
      # consider the next larger degree.
      SortBy( minimal, Length );

      # Compute the derived lengths
      for k in relevant do

        dl:= DerivedLength( FactorGroupNormalSubgroupClasses(
                         OrdinaryCharacterTable( G ), k ) );
        if dl > max then
          max:= dl;
        fi;

      od;

      Add( alpha, max );

    od;

    Info( InfoMonomial, 1, "Alpha returns ", alpha );
    return alpha;
    end );


#############################################################################
##
#M  Delta( <G> )  . . . . . . . . . . . . . . . . . . . . . . . . for a group
##
InstallMethod( Delta,
    "for a group",
    [ IsGroup ],
    function( G )

    local delta,  # result list
          alpha,  # `Alpha( <G> )'
          r;      # loop variable

    delta:= [ 1 ];
    alpha:= Alpha( G );
    for r in [ 2 .. Length( alpha ) ] do
      delta[r]:= alpha[r] - alpha[r-1];
    od;

    return delta;
    end );


#############################################################################
##
#M  IsBergerCondition( <chi> )  . . . . . . . . . . . . . . . for a character
##
InstallMethod( IsBergerCondition,
    "for a class function",
    [ IsClassFunction ],
    function( chi )

    local tbl,         # character table of <chi>
          values,      # values of `chi'
          ker,         # intersection of kernels of smaller degree
          deg,         # degree of <chi>
          psi,         # one irreducible character of $G$
          kerchi,      # kernel of <chi> (as group)
          isberger;    # result

    Info( InfoMonomial, 1,
          "IsBergerCondition called for character ",
          CharacterString( chi, "chi" ) );

    values:= ValuesOfClassFunction( chi );
    deg:= values[1];
    tbl:= UnderlyingCharacterTable( chi );

    if 1 < deg then

      # We need all characters of smaller degree,
      # so it is reasonable to compute the character table of the group
      ker:= [ 1 .. Length( values ) ];
      for psi in Irr( UnderlyingCharacterTable( chi ) ) do
        if DegreeOfCharacter( psi ) < deg then
          IntersectSet( ker, ClassPositionsOfKernel( psi ) );
        fi;
      od;

      # Check whether the derived group of this normal subgroup
      # lies in the kernel of `chi'.
      kerchi:= ClassPositionsOfKernel( values );
      if IsSubsetSet( kerchi, ker ) then

        # no need to compute subgroups
        isberger:= true;
      else
        isberger:= IsSubset( KernelOfCharacter( chi ),
                     DerivedSubgroup( NormalSubgroupClasses( tbl, ker ) ) );
      fi;

    else
      isberger:= true;
    fi;

    Info( InfoMonomial, 1, "IsBergerCondition returns ", isberger );
    return isberger;
    end );


#############################################################################
##
#M  IsBergerCondition( <G> )  . . . . . . . . . . . . . . . . . . for a group
##
InstallMethod( IsBergerCondition,
    "for a group",
    [ IsGroup ],
    function( G )

    local tbl,         # character table of `G'
          psi,         # one irreducible character of `G'
          isberger,    # result
          degrees,     # different character degrees of `G'
          kernels,     #
          pos,         #
          i,           # loop variable
          leftinters,  #
          left,        #
          right;       #

    Info( InfoMonomial, 1, "IsBergerCondition called for group ", G );

    tbl:= OrdinaryCharacterTable( G );

    if Size( G ) mod 2 = 1 then

      isberger:= true;

    else

      # Compute the intersections of kernels of characters of same degree
      degrees:= [];
      kernels:= [];
      for psi in List( Irr( G ), ValuesOfClassFunction ) do
        pos:= Position( degrees, psi[1], 0 );
        if pos = fail then
          Add( degrees, psi[1] );
          Add( kernels, ShallowCopy( ClassPositionsOfKernel( psi ) ) );
        else
          IntersectSet( kernels[ pos ], ClassPositionsOfKernel( psi ) );
        fi;
      od;
      SortParallel( degrees, kernels );

      # Let $1 = f_1 \leq f_2 \leq\ldots \leq f_n$ the distinct
      # irreducible degrees of `G'.
      # We must have for all $1 \leq i \leq n-1$ that
      # $$
      #    ( \bigcap_{\psi(1) \leq f_i}  \ker(\psi) )^{\prime} \leq
      #      \bigcap_{\chi(1) = f_{i+1}} \ker(\chi)
      # $$

      i:= 1;
      isberger:= true;
      leftinters:= kernels[1];

      while i < Length( degrees ) and isberger do

        # `leftinters' becomes $\bigcap_{\psi(1) \leq f_i} \ker(\psi)$.
        IntersectSet( leftinters, kernels[i] );
        if not IsSubsetSet( kernels[i+1], leftinters ) then

          # we have to compute the groups
          left:= DerivedSubgroup( NormalSubgroupClasses( tbl, leftinters ) );
          right:= NormalSubgroupClasses( tbl, kernels[i+1] );
          if not IsSubset( right, left ) then
            isberger:= false;
            Info( InfoMonomial, 1,
                  "IsBergerCondition:  violated for character of degree ",
                  degrees[i+1] );
          fi;

        fi;
        i:= i+1;
      od;

    fi;

    Info( InfoMonomial, 1, "IsBergerCondition returns ", isberger );
    return isberger;
    end );


#############################################################################
##
##  2. Primitivity of Characters
##


#############################################################################
##
#F  TestHomogeneous( <chi>, <N> )
##
##  This works also for reducible <chi>.
##
InstallGlobalFunction( TestHomogeneous, function( chi, N )

    local t,        # character table of `G'
          classes,  # class lengths of `t'
          values,   # values of <chi>
          cl,       # classes of `G' that form <N>
          norm,     # norm of the restriction of <chi> to <N>
          tn,       # table of <N>
          fus,      # fusion of conjugacy classes <N> in $G$
          rest,     # restriction of <chi> to <N>
          i,        # loop over characters of <N>
          scpr;     # one scalar product in <N>

    values:= ValuesOfClassFunction( chi );

    if IsList( N ) then
      cl:= N;
    else
      cl:= ClassPositionsOfNormalSubgroup( UnderlyingCharacterTable( chi ),
                                           N );
    fi;

    if Length( cl ) = 1 then
      return rec( isHomogeneous := true,
                  comment       := "restriction to trivial subgroup" );
    fi;

    t:= UnderlyingCharacterTable( chi );
    classes:= SizesConjugacyClasses( t );
    norm:= Sum( cl, c -> classes[c] * values[c]
                                    * GaloisCyc( values[c], -1 ), 0 );

    if norm = Sum( classes{ cl }, 0 ) then

      # The restriction is irreducible.
      return rec( isHomogeneous := true,
                  comment       := "restricts irreducibly" );

    else

      # `chi' restricts reducibly.
      # Compute the table of `N' if necessary,
      # and check the constituents of the restriction
      N:= NormalSubgroupClasses( t, cl );
      tn:= CharacterTable( N );
      fus:= FusionConjugacyClasses( tn, t );
      rest:= values{ fus };

      for i in Irr( tn ) do
        scpr:= ScalarProduct( tn, ValuesOfClassFunction( i ), rest );
        if scpr <> 0 then

          # Return info about the constituent.
          return rec( isHomogeneous := ( scpr * DegreeOfCharacter( i )
                                         = values[1] ),
                      comment       := "restriction checked",
                      character     := i,
                      multiplicity  := scpr  );

        fi;
      od;

    fi;
end );


#############################################################################
##
#M  TestQuasiPrimitive( <chi> ) . . . . . . . . . . . . . . . for a character
##
##  This works also for reducible <chi>.
##  Note that a representation affording <chi> maps the centre of <chi>
##  to scalar matrices.
##
InstallMethod( TestQuasiPrimitive,
    "for a character",
    [ IsCharacter ],
    function( chi )

    local values,   # list of character values
          t,        # character table of `chi'
          nsg,      # list of normal subgroups of `t'
          cen,      # centre of `chi'
          j,        # loop over normal subgroups
          testhom,  # test of homogeneous restriction
          test;     # result record

    Info( InfoMonomial, 1,
          "TestQuasiPrimitive called for character ",
          CharacterString( chi, "chi" ) );

    values:= ValuesOfClassFunction( chi );

    # Linear characters are primitive.
    if values[1] = 1 then
      test:= rec( isQuasiPrimitive := true,
                  comment          := "linear character" );
    else

      t:= UnderlyingCharacterTable( chi );

      # Compute the normal subgroups of `G' containing the centre of `chi'.

      # Note that `chi' restricts homogeneously to all normal subgroups
      # of `G' if (and only if) it restricts homogeneously to all those
      # normal subgroups containing the centre of `chi'.

      # {\em Proof:}
      # Let $N \unlhd G$ such that $Z(\chi) \not\leq N$.
      # We have to show that $\chi$ restricts homogeneously to $N$.
      # By our assumption $\chi_{N Z(\chi)}$ is homogeneous,
      # take $\vartheta$ the irreducible constituent.
      # Let $D$ a representation affording $\vartheta$ such that
      # the restriction to $N$ consists of block diagonal matrices
      # corresponding to the irreducible constituents.
      # $D( Z(\chi) )$ consists of scalar matrices,
      # thus $D( n^x ) = D( n )$ for $n\in N$, $x\in Z(\chi)$,
      # i.e., $Z(\chi)$ acts trivially on the irreducible constituents
      # of $\vartheta_N$,
      # i.e., every constituent of $\vartheta_N$ is invariant in $N Z(\chi)$,
      # i.e., $\vartheta$ (and thus $\chi$) restricts homogeneously to $N$.

      cen:= ClassPositionsOfCentre( values );
      nsg:= ClassPositionsOfNormalSubgroups( t );
      nsg:= Filtered( nsg, x -> IsSubsetSet( x, cen ) );

      test:= rec( isQuasiPrimitive := true,
                  comment          := "all restrictions checked" );

      for j in nsg do
        testhom:= TestHomogeneous( chi, j );
        if not testhom.isHomogeneous then

          # nonhomogeneous restriction found
          test:= rec( isQuasiPrimitive := false,
                      comment          := testhom.comment,
                      character        := testhom.character );
          break;
        fi;
      od;

    fi;

    Info( InfoMonomial, 1,
          "TestQuasiPrimitive returns `", test.isQuasiPrimitive, "'" );

    return test;
    end );


#############################################################################
##
#M  IsQuasiPrimitive( <chi> ) . . . . . . . . . . . . . . . . for a character
##
InstallMethod( IsQuasiPrimitive,
    "for a character",
    [ IsCharacter ],
    chi -> TestQuasiPrimitive( chi ).isQuasiPrimitive );


#############################################################################
##
#M  IsPrimitiveCharacter( <chi> ) . . . . . . . . . . . . . . for a character
##
##  Quasi-primitive irreducible characters of solvable groups are primitive,
##  see for example [Isa76, Thm. 11.33].
##
InstallMethod( IsPrimitiveCharacter,
    "for a class function",
    [ IsClassFunction ],
    function( chi )
    if not ( IsIrreducibleCharacter( chi ) and
             IsSolvableGroup( UnderlyingGroup( chi ) ) ) then
      TryNextMethod();
    fi;
    return TestQuasiPrimitive( chi ).isQuasiPrimitive;
    end );


#############################################################################
##
#M  IsPrimitive( <chi> )  . . . . . . . . . . . . . . . . . . for a character
##
InstallOtherMethod( IsPrimitive,
    "for a character",
    [ IsClassFunction ],
    IsPrimitiveCharacter );
#T really install this?


#############################################################################
##
#F  TestInducedFromNormalSubgroup( <chi>[, <N>] )
##
InstallGlobalFunction( TestInducedFromNormalSubgroup, function( arg )

    local sizeN,      # size of <N>
          sizefactor, # size of $G / <N>$
          values,     # values list of `chi'
          m,          # list of all maximal normal subgroups of $G$
          test,       # intermediate result
          tn,         # character table of <N>
          irr,        # irreducibles of `tn'
          i,          # loop variable
          scpr,       # one scalar product in <N>
          N,          # optional second argument
          cl,         # classes corresponding to `N'
          chi;        # first argument

    # check the arguments
    if Length( arg ) < 1 or Length( arg ) > 2
       or not IsCharacter( arg[1] ) then
      Error( "usage: TestInducedFromNormalSubgroup( <chi>[, <N>] )" );
    fi;

    chi:= arg[1];

    Info( InfoMonomial, 1,
          "TestInducedFromNormalSubgroup called with character ",
          CharacterString( chi, "chi" ) );

    if Length( arg ) = 1 then

      # `TestInducedFromNormalSubgroup( <chi> )'
      if DegreeOfCharacter( chi ) = 1 then

        return rec( isInduced:= false,
                    comment  := "linear character" );

      else

        # Get all maximal normal subgroups.
        m:= ClassPositionsOfMaximalNormalSubgroups(
                UnderlyingCharacterTable( chi ) );

        for N in m do

          test:= TestInducedFromNormalSubgroup( chi, N );
          if test.isInduced then
            return test;
          fi;

        od;

        return rec( isInduced := false,
                    comment   := "all maximal normal subgroups checked" );
      fi;

    else

      # `TestInducedFromNormalSubgroup( <chi>, <N> )'

      N:= arg[2];

      # 1. If the degree of <chi> is not divisible by the index of <N> in $G$
      #    then <chi> cannot be induced from <N>.
      # 2. If <chi> does not vanish outside <N> it cannot be induced from
      #    <N>.
      # 3. Provided that <chi> vanishes outside <N>,
      #    <chi> is induced from <N> if and only if the restriction of <chi>
      #    to <N> has an irreducible constituent with multiplicity 1.
      #
      #    Since the scalar product of the restriction with itself has value
      #    $G \: N$, multiplicity 1 means that there are $G \: N$ conjugates
      #    of this constituent, so <chi> is induced from each of them.
      #
      #    This gives another necessary condition that is easy to check.
      #    Namely, <N> must have more than $G \: <N>$ conjugacy classes if
      #    <chi> is induced from <N>.

      if IsList( N ) then
        sizeN:= Sum( SizesConjugacyClasses(
                         UnderlyingCharacterTable( chi ) ){ N }, 0 );
      elif IsGroup( N ) then
        sizeN:= Size( N );
      else
        Error( "<N> must be a group or a list" );
      fi;

      sizefactor:= Size( UnderlyingCharacterTable( chi ) ) / sizeN;

      if   DegreeOfCharacter( chi ) mod sizefactor <> 0 then

        return rec( isInduced := false,
                    comment   := "degree not divisible by index" );

      elif sizeN <= sizefactor then

        return rec( isInduced := false,
                    comment   := "<N> has too few conjugacy classes" );

      fi;

      values:= ValuesOfClassFunction( chi );

      if IsList( N ) then

        # Check whether the character vanishes outside <N>.
        for i in [ 2 .. Length( values ) ] do
          if not i in N and values[i] <> 0 then
            return rec( isInduced := false,
                        comment   := "<chi> does not vanish outside <N>" );
          fi;
        od;

        cl:= N;
        N:= NormalSubgroupClasses( UnderlyingCharacterTable( chi ), N );

      else

        # Check whether <N> has less conjugacy classes than its index is.
        if Length( ConjugacyClasses( N ) ) <= sizefactor then

          return rec( isInduced := false,
                      comment   := "<N> has too few conjugacy classes" );

        fi;

        cl:= ClassPositionsOfNormalSubgroup( UnderlyingCharacterTable( chi ),
                                             N );

        # Check whether the character vanishes outside <N>.
        for i in [ 2 .. Length( values ) ] do
          if not i in cl and values[i] <> 0 then
            return rec( isInduced := false,
                        comment   := "<chi> does not vanish outside <N>" );
          fi;
        od;

      fi;

      # Compute the restriction to <N>.
      chi:= values{ FusionConjugacyClasses( OrdinaryCharacterTable( N ),
                        UnderlyingCharacterTable( chi ) ) };

      # Check possible constituents.
      tn:= CharacterTable( N );
      irr:= Irr( N );
      for i in [ 1 .. NrConjugacyClasses( tn ) - sizefactor + 1 ] do

        scpr:= ScalarProduct( tn, ValuesOfClassFunction( irr[i] ), chi );

        if   1 < scpr then

          return rec( isInduced := false,
                      comment   := Concatenation(
                                     "constituent with multiplicity ",
                                     String( scpr ) ) );

        elif scpr = 1 then

          return rec( isInduced := true,
                      comment   := "induced from component \'.character\'",
                      character := irr[i] );

        fi;

      od;

      return rec( isInduced := false,
                  comment   := "all irreducibles of <N> checked" );

    fi;
end );


#############################################################################
##
#M  IsInducedFromNormalSubgroup( <chi> )  . . . . . . . . . . for a character
##
InstallMethod( IsInducedFromNormalSubgroup,
    "for a character",
    [ IsCharacter ],
    chi -> TestInducedFromNormalSubgroup( chi ).isInduced );


#############################################################################
##
##  3. Testing Monomiality
##


#############################################################################
##
#M  TestSubnormallyMonomial( <G> )  . . . . . . . . . . . . . . . for a group
##
InstallMethod( TestSubnormallyMonomial,
    "for a group",
    [ IsGroup ],
    function( G )

    local test,       # result record
          orbits,     # orbits of characters
          chi,        # loop over `orbits'
          found,      # decision is found
          i;          # loop variable

    Info( InfoMonomial, 1,
          "TestSubnormallyMonomial called for group ",
          GroupString( G, "G" ) );

    if IsNilpotentGroup( G ) then

      # Nilpotent groups are subnormally monomial.
      test:= rec( isSubnormallyMonomial:= true,
                  comment := "nilpotent group" );

    else

      # Check SM character by character,
      # one representative of each orbit under Galois conjugacy
      # and multiplication with linear characters only.

      orbits:= OrbitRepresentativesCharacters( Irr( G ) );

      # For each representative check whether it is SM.
      # (omit linear characters, i.e., first position)
      found:= false;
      i:= 2;
      while ( not found ) and i <= Length( orbits ) do

        chi:= orbits[i];
        if not TestSubnormallyMonomial( chi ).isSubnormallyMonomial then

          found:= true;
          test:= rec( isSubnormallyMonomial := false,
                      character             := chi,
                      comment               := "found non-SM character" );

        fi;
        i:= i+1;

      od;

      if not found then

        test:= rec( isSubnormallyMonomial := true,
                    comment               := "all irreducibles checked" );

      fi;

    fi;

    # Return the result.
    Info( InfoMonomial, 1,
          "TestSubnormallyMonomial returns with `",
          test.isSubnormallyMonomial, "'" );
    return test;
    end );


#############################################################################
##
#M  TestSubnormallyMonomial( <chi> )  . . . . . . . . . . . . for a character
##
InstallMethod( TestSubnormallyMonomial,
    "for a character",
    [ IsClassFunction ],
    function( chi )

    local test,       # result record
          testsm;     # local function for recursive check

    Info( InfoMonomial, 1,
          "TestSubnormallyMonomial called for character ",
          CharacterString( chi, "chi" ) );

    if   DegreeOfCharacter( chi ) = 1 then

      # Linear characters are subnormally monomial.
      test:= rec( isSubnormallyMonomial := true,
                  comment               := "linear character",
                  character             := chi );

    elif     HasIsSubnormallyMonomial( UnderlyingGroup( chi ) )
         and IsSubnormallyMonomial( UnderlyingGroup( chi ) ) then

      # If the group knows that it is subnormally monomial return this.
      test:= rec( isSubnormallyMonomial := true,
                  comment               := "subnormally monomial group",
                  character             := chi );

    elif IsNilpotentGroup( UnderlyingGroup( chi ) ) then

      # Nilpotent groups are subnormally monomial.
      test:= rec( isSubnormallyMonomial := true,
                  comment               := "nilpotent group",
                  character             := chi );

    else

      # We have to check recursively.

      # Given a character `chi' of the group $N$, and two classes lists
      # `forbidden' and `allowed' that describe all maximal normal
      # subgroups of $N$, where `forbidden' denotes all those normal
      # subgroups through that `chi' cannot be subnormally induced,
      # return either a linear character of a subnormal subgroup of $N$
      # from that `chi' is induced, or `false' if no such character exists.
      # If we reach a nilpotent group then we return a character of this
      # group, so the character is not necessarily linear.

      testsm:= function( chi, forbidden, allowed )

      local N,       # group of `chi'
            mns,     # max. normal subgroups
            forbid,  #
            n,       # one maximal normal subgroup
            cl,
            len,
            nt,
            fus,
            rest,
            deg,
            const,
            nallowed,
            nforbid,
            gp,
            fusgp,
            test;

      forbid:= ShallowCopy( forbidden );
      N:= UnderlyingGroup( chi );
      chi:= ValuesOfClassFunction( chi );
      len:= Length( chi );

      # Loop over `allowed'.
      for cl in allowed do

        if ForAll( [ 1 .. len ], x -> chi[x] = 0 or x in cl ) then

          # `chi' vanishes outside `n', so is induced from `n'.

          n:= NormalSubgroupClasses( OrdinaryCharacterTable( N ), cl );
          nt:= CharacterTable( n );

          # Compute a constituent of the restriction of `chi' to `n'.
          fus:= FusionConjugacyClasses( nt, OrdinaryCharacterTable( N ) );
          rest:= chi{ fus };
          deg:= chi[1] * Size( n ) / Size( N );
          const:= First( Irr( n ),
                     x ->     DegreeOfCharacter( x ) = deg
                          and ScalarProduct( nt, ValuesOfClassFunction( x ),
                                                 rest ) <> 0 );

          # Check termination.
          if   deg = 1 or IsNilpotentGroup( n ) then
            return const;
          elif Length( allowed ) = 0 then
            return false;
          fi;

          # Compute allowed and forbidden maximal normal subgroups of `n'.
          mns:= ClassPositionsOfMaximalNormalSubgroups( nt );
          nallowed:= [];
          nforbid:= [];
          for gp in mns do

            # A group is forbidden if it is the intersection of a group
            # in `forbid' with `n'.
            fusgp:= Set( fus{ gp } );
            if ForAny( forbid, x -> IsSubsetSet( x, fusgp ) ) then
              Add( nforbid, gp );
            else
              Add( nallowed, gp );
            fi;

          od;

          # Check whether `const' is subnormally induced from `n'.
          test:= testsm( const, nforbid, nallowed );
          if test <> false then
            return test;
          fi;

        fi;

        # Add `n' to the forbidden subgroups.
        Add( forbid, cl );

      od;

      # All allowed normal subgroups have been checked.
      return false;
      end;


      # Run the recursive search.
      # Here all maximal normal subgroups are allowed.
      test:= testsm( chi, [], ClassPositionsOfMaximalNormalSubgroups(
                                  UnderlyingCharacterTable( chi ) ) );

      # Prepare the output.
      if test = false then
        test:= rec( isSubnormallyMonomial := false,
                    comment   := "all subnormal subgroups checked" );
      elif DegreeOfCharacter( test ) = 1 then
        test:= rec( isSubnormallyMonomial := true,
                    comment   := "reduced to linear character",
                    character := test );
      else
        test:= rec( isSubnormallyMonomial := true,
                    comment   := "reduced to nilpotent subgroup",
                    character := test );
      fi;

    fi;

    Info( InfoMonomial, 1,
          "TestSubnormallyMonomial returns with `",
          test.isSubnormallyMonomial, "'" );
    return test;
    end );


#############################################################################
##
#M  IsSubnormallyMonomial( <G> )  . . . . . . . . . . . . . . . . for a group
#M  IsSubnormallyMonomial( <chi> )  . . . . . . . . . . . . . for a character
##
InstallMethod( IsSubnormallyMonomial,
    "for a group",
    [ IsGroup ],
    G -> TestSubnormallyMonomial( G ).isSubnormallyMonomial );

InstallMethod( IsSubnormallyMonomial,
    "for a character",
    [ IsClassFunction ],
    chi -> TestSubnormallyMonomial( chi ).isSubnormallyMonomial );


#############################################################################
##
#M  IsMonomialNumber( <n> ) . . . . . . . . . . . . .  for a positive integer
##
InstallMethod( IsMonomialNumber,
    "for a positive integer",
    [ IsPosInt ],
    function( n )

    local factors,   # list of prime factors of `n'
          collect,   # list of (prime divisor, exponent) pairs
          nu2,       # $\nu_2(n)$
          pair,      # loop over `collect'
          pair2,     # loop over `collect'
          ord;       # multiplicative order

    factors := Factors(Integers, n );
    collect := Collected( factors );

    # Get $\nu_2(n)$.
    if 2 in factors then
      nu2:= collect[1][2];
    else
      nu2:= 0;
    fi;

    # Check for minimal nonmonomial groups of type 1.
    if nu2 >= 2 then
      for pair in collect do
        if pair[1] mod 4 = 3 and pair[2] >= 3 then
          return false;
        fi;
      od;
    fi;

    # Check for minimal nonmonomial groups of type 2.
    if nu2 >= 3 then
      for pair in collect do
        if pair[1] mod 4 = 1 and pair[2] >= 3 then
          return false;
        fi;
      od;
    fi;

    # Check for minimal nonmonomial groups of type 3.
    for pair in collect do
      for pair2 in collect do
        if pair[1] <> pair2[1] and pair2[1] <> 2 then
          ord:= OrderMod( pair[1], pair2[1] );
          if ord mod 2 = 0 and ord < pair[2] then
            return false;
          fi;
        fi;
      od;
    od;

    # Check for minimal nonmonomial groups of type 4.
    if nu2 >= 4 then
      for pair in collect do
        if pair[1] <> 2 and nu2 >= 2* OrderMod( 2, pair[1] ) + 2 then
          return false;
        fi;
      od;
    fi;

    # Check for minimal nonmonomial groups of type 5.
    if nu2 >= 2 then
      for pair in collect do
        if pair[1] mod 4 = 1 and pair[2] >= 3 then
          for pair2 in collect do
            if pair2[1] <> 2 then
              ord:= OrderMod( pair[1], pair2[1] );
              if ord mod 2 = 1 and 2 * ord < pair[2] then
                return false;
              fi;
            fi;
          od;
        fi;
      od;
    fi;

    # None of the five cases can occur.
    return true;
    end );


#############################################################################
##
#M  TestMonomialQuick( <chi> )  . . . . . . . . . . . . . . . for a character
##
##  We assume that <chi> is an irreducible character.
##
InstallMethod( TestMonomialQuick,
    "for a character",
    [ IsClassFunction ],
    function( chi )

    local G,          # group of `chi'
          factsize,   # size of the kernel factor of `chi'
          codegree,   # codegree of `chi'
          pi,         # prime divisors of a Hall subgroup
          hall,       # size of `pi' Hall subgroup of kernel factor
          ker,        # kernel of `chi'
          t,          # character table of `G'
          grouptest;  # result of the call to `G / ker'

    Info( InfoMonomial, 1,
          "TestMonomialQuick called for character ",
          CharacterString( chi, "chi" ) );

    if   HasIsMonomialCharacter( chi ) then

      # The character knows about being monomial.
      Info( InfoMonomial, 1,
            "TestMonomialQuick returns with `",
            IsMonomialCharacter( chi ), "'" );
      return rec( isMonomial := IsMonomialCharacter( chi ),
                  comment    := "was already stored" );

    elif DegreeOfCharacter( chi ) = 1 then

      # Linear characters are monomial.
      Info( InfoMonomial, 1,
            "TestMonomialQuick returns with `true'" );
      return rec( isMonomial := true,
                  comment    := "linear character" );

    fi;

    G:= UnderlyingGroup( chi );

    if Size( G ) mod DegreeOfCharacter( chi ) <> 0 then
      Info( InfoMonomial, 1,
            "TestMonomialQuick returns with `false'" );
      return rec( isMonomial := false,
                  comment    := "degree does not divide group order" );
    fi;

    # The following criteria are applicable only to irreducible characters.
    # We do *not* check here that 'chi' is really an irreducible character.
    if TestMonomialQuick( G ).isMonomial = true then

      # The whole group is known to be monomial.
      Info( InfoMonomial, 1,
            "TestMonomialQuick returns with `true'" );
      return rec( isMonomial := true,
                  comment    := "whole group is monomial" );

    fi;

    chi := ValuesOfClassFunction( chi );

    # Replace `G' by the factor group modulo the kernel.
    ker:= ClassPositionsOfKernel( chi );
    if 1 < Length( ker ) then
      t:= CharacterTable( G );
      factsize:= Size( G ) / Sum( SizesConjugacyClasses( t ){ ker }, 0 );
    else
      factsize:= Size( G );
    fi;

    # Inspect the codegree.
    codegree := factsize / chi[1];
    if IsPrimePowerInt( codegree ) then

      # If the codegree is a prime power then the character is monomial,
      # by a result of Chillag, Mann, and Manz.
      # Here is a short proof due to M. I. Isaacs
      # (communicated by E. Horváth).
      #
      # Let $G$ be a finite group, $\chi\in Irr(G)$ with codegree $p^a$
      # for a prime $p$, and $P\in Syl_p(G)$.
      # Then there exists an irreducible character $\psi$ of $P$
      # with $\psi^G = \chi$.
      #
      # {\it Proof:}
      # Let $b$ be an integer such that $\chi(1) = [G : P] p^b$,
      # and consider $\chi_P = \sum_{\psi\in Irr(P)} a_{\psi} \psi$.
      # There exists $\psi$ with $a_{\psi} \not= 0$ and $\psi(1) \leq p^b$,
      # as otherwise $\chi(1)$ would be divisible by a larger power of $p$.
      # On the other hand, $\chi$ must be a constituent of $\psi^G$ and thus
      # $p^b \leq \psi(1)$.
      # So there is equality, and thus $\psi^G = \chi$.
      Info( InfoMonomial, 1,
            "TestMonomialQuick returns with `true'" );
      return rec( isMonomial := true,
                  comment    := "codegree is prime power" );
    fi;

    # If $G$ is solvable and $\pi$ is the set of primes dividing the codegree
    # then the character is induced from a $\pi$ Hall subgroup.
    # This follows from Theorem~(2D) in~\cite{Fon62}.
    if IsSolvableGroup( G ) then

      pi   := PrimeDivisors( codegree );
      hall := Product( Filtered( Factors(Integers, factsize ), x -> x in pi ), 1 );

      if factsize / hall = chi[1] then

        # The character is induced from a *linear* character
        # of the $\pi$ Hall group.
        Info( InfoMonomial, 1,
              "TestMonomialQuick returns with `true'" );
        return rec( isMonomial := true,
                    comment    := "degree is index of Hall subgroup" );

      elif IsMonomialNumber( hall ) then

        # The *order* of this Hall subgroup is monomial.
        Info( InfoMonomial, 1,
              "TestMonomialQuick returns with `true'" );
        return rec( isMonomial := true,
                    comment    := "induced from monomial Hall subgroup" );

      fi;

    fi;

    # Inspect the factor group modulo the kernel.
    if 1 < Length( ker ) then

      # For solvable 'G', checking 'factsize' for monomiality does not
      # help here because the divisor 'hall' has been checked above.

      if IsSubsetSet( ker, ClassPositionsOfSupersolvableResiduum(t) ) then

        # The factor group modulo the kernel is supersolvable.
        Info( InfoMonomial, 1,
              "TestMonomialQuick returns with `true'" );
        return rec( isMonomial:= true,
                    comment:= "kernel factor group is supersolvable" );

      fi;

      grouptest:= TestMonomialQuick( FactorGroupNormalSubgroupClasses(
                      OrdinaryCharacterTable( G ), ker ) );
#T This is not cheap!
      if grouptest.isMonomial = true then

        Info( InfoMonomial, 1,
              "#I  TestMonomialQuick returns with `true'" );
        return rec( isMonomial := true,
                    comment    := "kernel factor group is monomial" );

      fi;

    fi;

    # No more cheap tests are available.
    Info( InfoMonomial, 1,
          "TestMonomialQuick returns with `?'" );
    return rec( isMonomial := "?",
                comment    := "no decision by cheap tests" );
    end );


##############################################################################
##
#M  TestMonomialQuick( <G> )  . . . . . . . . . . . . . . . . . .  for a group
##
##  The following criteria are used for a group <G>.
##
##  o Nonsolvable groups are not monomial.
##  o If the group order is monomial then <G> is monomial.
##    (Note that monomiality of group orders is defined for solvable
##     groups only, so solvability has to be checked first.)
##  o Nilpotent groups are monomial.
##  o Abelian by supersolvable groups are monomial.
##  o Sylow abelian by supersolvable groups are monomial.
##    (Compute the Sylow subgroups of the supersolvable residuum,
##     and check whether they are abelian.)
##
InstallMethod( TestMonomialQuick,
    "for a group",
    [ IsGroup ],
    function( G )

#T if the table is known then call TestMonomialQuick( G.charTable ) !
#T (and implement this function ...)

    local test,       # the result record
          ssr;        # supersolvable residuum of `G'

    Info( InfoMonomial, 1,
          "TestMonomialQuick called for group ",
          GroupString( G, "G" ) );

    # If the group knows about being monomial return this.
    if   HasIsMonomialGroup( G ) then

      test:= rec( isMonomial := IsMonomialGroup( G ),
                  comment    := "was already stored" );

    elif not IsSolvableGroup( G ) then

      # Monomial groups are solvable.
      test:= rec( isMonomial := false,
                  comment    := "non-solvable group" );

    elif IsMonomialNumber( Size( G ) ) then

      # Every solvable group of this order is monomial.
      test:= rec( isMonomial := true,
                  comment    := "group order is monomial" );

    elif IsNilpotentGroup( G ) then

      # Nilpotent groups are monomial.
      test:= rec( isMonomial := true,
                  comment    := "nilpotent group" );

    else

      ssr:= SupersolvableResiduum( G );

      if IsTrivial( ssr ) then

        # Supersolvable groups are monomial.
        test:= rec( isMonomial := true,
                    comment    := "supersolvable group" );

      elif IsAbelian( ssr ) then

        # Abelian by supersolvable groups are monomial.
        test:= rec( isMonomial := true,
                    comment    := "abelian by supersolvable group" );

      elif ForAll( PrimeDivisors( Size( ssr ) ),
                   x -> IsAbelian( SylowSubgroup( ssr, x ) ) ) then

        # Sylow abelian by supersolvable groups are monomial.
        test:= rec( isMonomial := true,
                    comment    := "Sylow abelian by supersolvable group" );

      else

        # No more cheap tests are available.
        test:= rec( isMonomial := "?",
                    comment    := "no decision by cheap tests" );

      fi;

    fi;

    Info( InfoMonomial, 1,
          "TestMonomialQuick returns with `", test.isMonomial, "'" );
    return test;
    end );


#############################################################################
##
#M  TestMonomial( <chi> ) . . . . . . . . . . . . . . . . . . for a character
#M  TestMonomial( <chi>, <uselattice> ) . . .  for a character, and a Boolean
##
##  Called with an irreducible character <chi> as argument,
##  `TestMonomialQuick( <chi> )' is inspected first;
##  if this did not decide the question,
##  we test all those normal subgroups of $G$ to which <chi> restricts
##  nonhomogeneously whether the interesting character of the
##  inertia subgroup is monomial.
##  (If <chi> is quasiprimitive then it is nonmonomial.)
##  If <chi> is not irreducible, these tests are not applicable.
##
##  If <uselattice> is `true' or if the group of <chi> has order at most
##  `TestMonomialUseLattice' then the subgroup lattice is used
##  to decide the question if necessary.
##
BindGlobal( "TestMonomialFromLattice", function( chi )
    local G, H, source;

    G:= UnderlyingGroup( chi );

    # Loop over representatives of the conjugacy classes of subgroups.
    for H in List( ConjugacyClassesSubgroups( G ), Representative ) do
      if IndexNC( G, H ) = chi[1] then
        source:= First( LinearCharacters( H ), lambda -> lambda^G = chi );
        if source <> fail then
          return source;
        fi;
      fi;
    od;

    # Return the negative result.
    return fail;
end );

InstallMethod( TestMonomial,
    "for a character",
    [ IsClassFunction ],
    chi -> TestMonomial( chi, false ) );

InstallMethod( TestMonomial,
    "for a character, and a Boolean",
    [ IsClassFunction, IsBool ],
    function( chi, uselattice )
    local G,         # group of `chi'
          test,      # result record
          t,         # character table of `G'
          nsg,       # list of normal subgroups of `G'
          ker,       # kernel of `chi'
          isqp,      # is `chi' quasiprimitive
          i,         # loop over normal subgroups
          testhom,   # does `chi' restrict homogeneously
          theta,     # constituent of the restriction
          found,     # monomial character found
          found2,    # monomial character found
          T,         # inertia group of `theta'
          fus,       # fusion of conjugacy classes `T' in `G'
          deg,       # degree of `theta'
          rest,      # restriction of `chi' to `T'
          j,         # loop over irreducibles of `T'
          psi,       # character of `T'
          testmon;   # test for monomiality

    Info( InfoMonomial, 1, "TestMonomial called" );

    # Start with elementary tests for monomiality.
    if   HasIsMonomialCharacter( chi ) then
      # The character knows about being monomial.
      test:= rec( isMonomial := IsMonomialCharacter( chi ),
                  comment    := "was already stored" );
    elif IsIrreducibleCharacter( chi ) then
      test:= TestMonomialQuick( chi );
    elif DegreeOfCharacter( chi ) = 1 then
      # Linear characters are monomial.
      test:= rec( isMonomial := true,
                  comment    := "linear character" );
    elif Size( UnderlyingGroup( chi ) ) mod DegreeOfCharacter( chi ) <> 0 then
      test:= rec( isMonomial := false,
                  comment    := "degree does not divide group order" );
    else
      test:= rec( isMonomial:= "?" );
    fi;

    if test.isMonomial = "?" then

      G:= UnderlyingGroup( chi );

      if not IsSolvableGroup( G ) then
        Info( InfoMonomial, 1,
              "TestMonomial: nonsolvable group" );
        test:= rec( isMonomial := "?",
                    comment    := "no criterion for nonsolvable group" );
      elif not IsIrreducibleCharacter( chi ) then
        Info( InfoMonomial, 1,
              "TestMonomial: reducible character" );
        test:= rec( isMonomial := "?",
                    comment    := "no criterion for reducible character" );
      else

        # Loop over all normal subgroups of `G' to that <chi> restricts
        # nonhomogeneously.
        # (If there are no such normal subgroups then <chi> is
        # quasiprimitive hence not monomial.)
        t:= CharacterTable( G );
        ker:= ClassPositionsOfKernel( ValuesOfClassFunction( chi ) );
        nsg:= Filtered( ClassPositionsOfNormalSubgroups( t ),
                        x -> IsSubsetSet( x, ker ) );
        isqp:= true;

        i:= 1;
        found:= false;

        while not found and i <= Length( nsg ) do

          testhom:= TestHomogeneous( chi, nsg[i] );
          if not testhom.isHomogeneous then

            isqp:= false;

            # Take a constituent `theta' in a nonhomogeneous restriction.
            theta:= testhom.character;

            # We have $<chi>_N = e \sum_{i=1}^t \theta_i$.
            # <chi> is induced from an irreducible character of
            # $'T' = I_G(\theta_1)$ that restricts to $e \theta_1$,
            # so we have proved monomiality if $e = \theta(1) = 1$.
            if     testhom.multiplicity = 1
               and DegreeOfCharacter( theta ) = 1 then

              found:= true;
              test:= rec( isMonomial := true,
                          comment    := "induced from \'character\'",
                          character  := theta );

            else

              # Compute the inertia group `T'.
              T:= InertiaSubgroup( G, theta );
              if TestMonomialQuick( T ).isMonomial = true then

                # `chi' is induced from `T', and `T' is monomial.
                found:= true;
                test:= rec( isMonomial := true,
                            comment    := "induced from monomial subgroup",
                            subgroup   := T );
#T example?

              else

                # Check whether a character of `T' from that <chi>
                # is induced can be proved to be monomial.

                # First get all characters `psi' of `T'
                # from that <chi> is induced.
                t:= Irr( T );
                fus:= FusionConjugacyClasses( OrdinaryCharacterTable( T ),
                                              OrdinaryCharacterTable( G ) );
                deg:= DegreeOfCharacter( chi ) / Index( G, T );
                rest:= ValuesOfClassFunction( chi ){ fus };
                j:= 1;
                found2:= false;
                while not found2 and j <= Length(t) do
                  if     DegreeOfCharacter( t[j] ) = deg
                     and ScalarProduct( CharacterTable( T ),
                                        ValuesOfClassFunction( t[j] ),
                                        rest ) <> 0 then
                    psi:= t[j];
                    testmon:= TestMonomial( psi );
                    if testmon.isMonomial = true then
                      found:= true;
                      found2:= true;
                      test:= testmon;
                    fi;
                  fi;
                  j:= j+1;
                od;

              fi;

            fi;

          fi;

          i:= i+1;

        od;

        if isqp then

          # <chi> is quasiprimitive, for a solvable group this implies
          # primitivity,
          # for a nonlinear character this proves nonmonomiality.
          test:= rec( isMonomial := false,
                      comment    := "quasiprimitive character" );

        elif not found then

          # We have tried all suitable normal subgroups and always got
          # back that the character of the inertia subgroup was
          # (possibly) nonmonomial.
          test:= rec( isMonomial:= "?",
                      comment:= "all inertia subgroups checked, no result" );

        fi;

      fi;

      if test.isMonomial = "?" and
         ( uselattice or Size( G ) <= TestMonomialUseLattice ) then
        # Use explicit computations with the subgroup lattice,
        test:= TestMonomialFromLattice( chi );
        if test = fail then
          test:= rec( isMonomial := false,
                      comment    := "lattice checked" );
        else
          test:= rec( isMonomial := true,
                      comment    := "induced from \'character\'",
                      character  := test );
        fi;
      fi;

    fi;

    # Return the result.
    Info( InfoMonomial, 1,
          "TestMonomial returns with `", test.isMonomial, "'" );
    return test;
    end );


#############################################################################
##
#M  TestMonomial( <G> ) . . . . . . . . . . . . . . . . . . . . . for a group
#M  TestMonomial( <G>, <uselattice> ) . . . . . .  for a group, and a Boolean
##
##  Called with a group <G>, the program checks whether all representatives
##  of character orbits are monomial.
##
InstallMethod( TestMonomial,
    "for a group",
    [ IsGroup ],
    G -> TestMonomial( G, false ) );

InstallMethod( TestMonomial,
    "for a group, and a Boolean",
    [ IsGroup, IsBool ],
    function( G, uselattice )

    local test,      # result record
          found,     # monomial character found
          testmon,   # test for monomiality
          j,         # loop over irreducibles of `T'
          psi,       # character of `T'
          orbits,    # orbits of irreducibles of `T'
          poss;      # list of possibly nonmonomial characters

    Info( InfoMonomial, 1, "TestMonomial called for a group" );

    # elementary test for monomiality
    test:= TestMonomialQuick( G );

    if test.isMonomial = "?" then

      if Size( G ) mod 2 = 0 and ForAny( Delta( G ), x -> 1 < x ) then

        # For even order groups it is checked whether
        # the list `Delta( G )' contains an entry that is bigger
        # than one. (For monomial groups and for odd order groups
        # this is always less than one,
        # according to Taketa's Theorem and Berger's result).
        test:= rec( isMonomial := false,
                    comment    := "list Delta( G ) contains entry > 1" );

      else

        orbits:= OrbitRepresentativesCharacters( Irr( G ) );
        found:= false;
        j:= 2;
        poss:= [];
        while j <= Length( orbits ) do
          psi:= orbits[j];
          testmon:= TestMonomial( psi, uselattice ).isMonomial;
          if testmon = false then
            found:= true;
            break;
          elif testmon = "?" then
            Add( poss, psi );
          fi;
          j:= j+1;
        od;

        if found then

          # A nonmonomial character was found.
          test:= rec( isMonomial := false,
                      comment    := "nonmonomial character found",
                      character  := psi );

        elif IsEmpty( poss ) then

          # All checks answered `true'.
          test:= rec( isMonomial := true,
                      comment    := "all characters checked" );

        else

          # We give up.
          test:= rec( isMonomial := "?",
                      comment    := "(possibly) nonmon. characters found",
                      characters := poss );

        fi;

      fi;

    fi;

    # Return the result.
    Info( InfoMonomial, 1,
          "TestMonomial returns with `", test.isMonomial, "'" );
    return test;
    end );


#############################################################################
##
#M  IsMonomialGroup( <G> ) . . . . . . . . . . . . . . . . . . .  for a group
##
InstallMethod( IsMonomialGroup,
    "for a group",
    [ IsGroup ],
    G -> TestMonomial( G, true ).isMonomial );


#############################################################################
##
#M  IsMonomialCharacter( <chi> )  . . . . . . . . . . . . . . for a character
##
InstallMethod( IsMonomialCharacter,
    "for a character",
    [ IsClassFunction ],
    chi -> TestMonomial( chi, true ).isMonomial );


#############################################################################
##
#A  TestRelativelySM( <G> )
#A  TestRelativelySM( <chi> )
#F  TestRelativelySM( <G>, <N> )
#F  TestRelativelySM( <chi>, <N> )
##
##  The algorithm for a character <chi> and a normal subgroup <N>
##  proceeds as follows.
##  If <N> is abelian or has nilpotent factor then <chi> is relatively SM
##  with respect to <N>.
##  Otherwise we check whether <chi> restricts irreducibly to <N>; in this
##  case we also get a positive answer.
##  Otherwise a subnormal subgroup from that <chi> is induced must be
##  contained in a maximal normal subgroup of <N>.  So we get all maximal
##  normal subgroups containing <N> from that <chi> can be induced, take a
##  character that induces to <chi>, and check recursively whether it is
##  relatively subnormally monomial with respect to <N>.
##
##  For a group $G$ we consider only representatives of character orbits.
##
BindGlobal( "TestRelativelySMFun", function( arg )

    local test,      # result record
          G,         # argument, group
          chi,       # argument, character of `G'
          N,         # argument, normal subgroup of `G'
          n,         # classes in `N'
          t,         # character table of `G'
          nsg,       # list of normal subgroups of `G'
          newnsg,    # filtered list of normal subgroups
          orbits,    # orbits on `t.irreducibles'
          found,     # not relatively SM character found?
          i,         # loop over `nsg'
          j,         # loop over characters
          fus,       # fusion of conjugacy classes `N' in `G'
          norm,      # norm of restriction of `chi' to `N'
          isrelSM,   # is the constituent relatively SM?
          check,     #
          induced,   # is a subnormal subgroup found from where
                     # the actual character can be induced?
          k;         # loop over `newnsg'

    # step 1:
    # Check the arguments.
    if     Length( arg ) < 1 or 2 < Length( arg )
        or not ( IsGroup( arg[1] ) or IsCharacter( arg[1] ) ) then
      Error( "first argument must be a group or a character" );
    elif HasTestRelativelySM( arg[1] ) then
      return TestRelativelySM( arg[1] );
    fi;

    if IsGroup( arg[1] ) then
      G:= arg[1];
      Info( InfoMonomial, 1,
            "TestRelativelySM called with group ", GroupString( G, "G" ) );
    elif IsCharacter( arg[1] ) then
      G:= UnderlyingGroup( arg[1] );
      chi:= ValuesOfClassFunction( arg[1] );
      Info( InfoMonomial, 1,
            "TestRelativelySM called with character ",
            CharacterString( arg[1], "chi" ) );
    fi;

    # step 2:
    # Get the interesting normal subgroups.

    # We want to consider normal subgroups and factor groups.
    # If this test  yields a solution we can avoid to compute
    # the character table of `G'.
    # But if the character table of `G' is already known we use it
    # and store the factor groups.

    if   Length( arg ) = 1 then

      # If a normal subgroup <N> is abelian or has nilpotent factor group
      # then <G> is relatively SM w.r. to <N>, so consider only the other
      # normal subgroups.

      if HasOrdinaryCharacterTable( G ) then

        nsg:= ClassPositionsOfNormalSubgroups( CharacterTable( G ) );
        newnsg:= [];
        for n in nsg do
          if not CharacterTable_IsNilpotentFactor( CharacterTable( G ),
                     n ) then
            N:= NormalSubgroupClasses( CharacterTable( G ), n );
#T geht das?
#T        if IsSubset( n, centre ) and
            if not IsAbelian( N ) then
              Add( newnsg, N );
            fi;
          fi;
        od;
        nsg:= newnsg;

      else

        nsg:= NormalSubgroups( G );
        nsg:= Filtered( nsg, x -> not IsAbelian( x ) and
                                  not IsNilpotentGroup( G / x ) );

      fi;

    elif Length( arg ) = 2 then

      nsg:= [];

      if IsList( arg[2] ) then

        if not CharacterTable_IsNilpotentFactor( CharacterTable( G ),
                   arg[2] ) then
          N:= NormalSubgroupClasses( CharacterTable( G ), arg[2] );
          if not IsAbelian( N ) then
            nsg[1]:= N;
          fi;
        fi;

      elif IsGroup( arg[2] ) then

        N:= arg[2];
        if not IsAbelian( N ) and not IsNilpotentGroup( G / N ) then
          nsg[1]:= N;
        fi;

      else
        Error( "second argument must be normal subgroup or classes list" );
      fi;

    fi;

    # step 3:
    # Test whether all characters are relatively SM for all interesting
    # normal subgroups.

    if IsEmpty( nsg ) then

      test:= rec( isRelativelySM := true,
                  comment        :=
          "normal subgroups are abelian or have nilpotent factor group" );

    else

      t:= CharacterTable( G );
      if IsGroup( arg[1] ) then

        # Compute representatives of orbits of characters.
        orbits:= OrbitRepresentativesCharacters( Irr( t ) );
        orbits:= orbits{ [ 2 .. Length( orbits ) ] };

      else
        orbits:= [ chi ];
      fi;

      # Loop over all normal subgroups in `nsg' and all
      # irreducible characters in `orbits' until a not rel. SM
      # character is found.
      found:= false;
      i:= 1;
      while ( not found ) and i <= Length( nsg ) do

        N:= nsg[i];
        j:= 1;
        while ( not found ) and j <= Length( orbits ) do

#T use the kernel or centre here!!
#T if N does not contain the centre of chi then we need not test?
#T Isn't it sufficient to consider the factor modulo
#T the product of `N' and kernel of `chi'?
          chi:= orbits[j];

          # Is the restriction of `chi' to `N' irreducible?
          # This means we can choose $H = G$.
          n:= ClassPositionsOfNormalSubgroup( OrdinaryCharacterTable( G ),
                                              N );
          fus:= FusionConjugacyClasses( OrdinaryCharacterTable( N ),
                                        OrdinaryCharacterTable( G ) );
          norm:= Sum( n,
              c -> SizesConjugacyClasses( CharacterTable( G ) )[c] * chi[c]
                   * GaloisCyc( chi[c], -1 ), 0 );

          if norm = Size( N ) then

            test:= rec( isRelativelySM := true,
                        comment        := "irreducible restriction",
                        character      := Character( G, chi ) );

          else

            # If there is a subnormal subgroup $H$ from where <chi> is
            # induced then $H$ is contained in a maximal normal subgroup
            # of $G$ that contains <N>.

            # So compute all maximal subgroups ...
            newnsg:= ClassPositionsOfMaximalNormalSubgroups(
                         CharacterTable( G ) );

            # ... containing <N> ...
            newnsg:= Filtered( newnsg, x -> IsSubsetSet( x, n ) );

            # ... from where <chi> possibly can be induced.
            newnsg:= List( newnsg,
                           x -> TestInducedFromNormalSubgroup(
                                 Character( G, chi ),
                                 NormalSubgroupClasses( CharacterTable( G ),
                                                        x ) ) );

            induced:= false;
            k:= 1;
            while not induced and k <= Length( newnsg ) do

              check:= newnsg[k];
              if check.isInduced then

                # check whether the constituent is relatively SM w.r. to <N>
                isrelSM:= TestRelativelySM( check.character, N );
                if isrelSM.isRelativelySM then
                  induced:= true;
                fi;

              fi;
              k:= k+1;

            od;

            if induced then
              test:= rec( isRelativelySM := true,
                          comment := "suitable character found"
                         );
              if IsBound( isrelSM.character ) then
                test.character:= isrelSM.character;
              fi;
            else
              test:= rec( isRelativelySM := false,
                          comment := "all possibilities checked" );
            fi;

          fi;

          if not test.isRelativelySM then

            found:= true;
            test.character:= chi;
            test.normalSubgroup:= N;

          fi;

          j:= j+1;

        od;

        i:= i+1;

      od;

      if not found then

        # All characters are rel. SM w.r. to all normal subgroups.
        test:= rec( isRelativelySM := true,
                    comment        := "all possibilities checked" );
      fi;

    fi;

    Info( InfoMonomial, 1, "TestRelativelySM returns with `", test, "'" );
    return test;
end );

InstallMethod( TestRelativelySM,
    "for a character",
    [ IsClassFunction ],
    TestRelativelySMFun );

InstallMethod( TestRelativelySM,
    "for a group",
    [ IsGroup ],
    TestRelativelySMFun );

InstallOtherMethod( TestRelativelySM,
    "for a character, and an object",
    [ IsClassFunction, IsObject ],
    TestRelativelySMFun );

InstallOtherMethod( TestRelativelySM,
    "for a group, and an object",
    [ IsGroup, IsObject ],
    TestRelativelySMFun );


#############################################################################
##
#M  IsRelativelySM( <chi> )
#M  IsRelativelySM( <G> )
##
InstallMethod( IsRelativelySM,
    "for a character",
    [ IsClassFunction ],
    chi -> TestRelativelySM( chi ).isRelativelySM );

InstallOtherMethod( IsRelativelySM,
    "for a group",
    [ IsGroup ],
    G -> TestRelativelySM( G ).isRelativelySM );


#############################################################################
##
##  4. Minimal Nonmonomial Groups
##


#############################################################################
##
#M  IsMinimalNonmonomial( <G> ) . . . . . . . . . . .  for a (solvable) group
##
##  We use the classification by van der Waall.
##
InstallMethod( IsMinimalNonmonomial,
    "for a (solvable) group",
    [ IsGroup ],
    function( K )

    local F,          # Fitting subgroup
          factsize,   # index of `F' in `K'
          facts,      # prime factorization of the order of `F'
          p,          # prime dividing the order of `F'
          m,          # `F' is of order $p ^ m $
          syl,        # Sylow subgroup
          sylgen,     # one generator of `syl'
          gens,       # generators list
          C,          # centre of `K' in dihedral case
          fc,         # element in $F C$
          q;          # half of `factsize' in dihedral case

    # Check whether `K' is solvable.
    if not IsSolvableGroup( K ) then
      TryNextMethod();
    fi;

    # Compute the Fitting factor of the group.
    F:= FittingSubgroup( K );
    factsize:= Index( K, F );

    # The Fitting subgroup of a minimal nomonomial group is a $p$-group.
    facts:= Factors(Integers, Size( F ) );
    p:= Set( facts );
    if 1 < Length( p ) then
      return false;
    fi;
    p:= p[1];
    m:= Length( facts );

    # Check for the five possible structures.
    if   factsize = 4 then

      # If $K$ is minimal nonmonomial then
      # $K / F(K)$ is cyclic of order 4,
      # $F(K)$ is extraspecial of order $p^3$ and of exponent $p$
      # where $p \equiv -1 \pmod{4}$.

      if     IsPrimeInt( p )
         and p >= 3
         and ( p + 1 ) mod 4 = 0
         and m = 3
         and Centre( F ) = FrattiniSubgroup( F )
         and Size( Centre( F ) ) = p then

        # Check that the factor is cyclic and acts irreducibly.
        # For that, it is sufficient that the square acts
        # nontrivially.

        syl:= SylowSubgroup( K, 2 );
        if     IsCyclic( syl )
           and ForAny( GeneratorsOfGroup( syl ),
                       x ->     Order( x ) = 4
                            and ForAny( GeneratorsOfGroup( F ),
                                    y -> not IsOne( Comm( y, x^2 ) ) ) ) then
          SetIsMonomialGroup( K, false );
          return true;
        fi;

      fi;

    elif factsize = 8 then

      # If $K$ is minimal nonmonomial then
      # $K / F(K)$ is quaternion of order 8,
      # $F(K)$ is extraspecial of order $p^3$ and of exponent $p$
      # where $p \equiv 1 \pmod{4}$.

      if    IsPrimeInt( p )
         and p >= 5
         and ( p - 1 ) mod 4 = 0
         and m = 3
         and Centre( F ) = FrattiniSubgroup( F )
         and Size( Centre( F ) ) = p then

        # Check whether $K/F(K)$ is quaternion of order 8,
        # (i.e., is nonabelian with two *generators* of order 4 that do
        # not generate the same subgroup)
        # and that it acts irreducibly on $F$
        # For that, it is sufficient to show that the central involution
        # acts nontrivially.

        syl:= SylowSubgroup( K, 2 );
        gens:= Filtered( GeneratorsOfGroup( syl ), x -> Order( x ) = 4 );
        if     not IsAbelian( syl )
           and ForAny( gens,
                       x ->     x <> gens[1]
                            and x <> gens[1]^(-1)
                            and ForAny( GeneratorsOfGroup( F ),
                                    y -> not IsOne( Comm( y, x^2 ) ) ) ) then
          SetIsMonomialGroup( K, false );
          return true;
        fi;

      fi;

    elif factsize <> 2 and IsPrimeInt( factsize ) then

      # If $K$ is minimal nonmonomial then
      # $K / F(K)$ has order an odd prime $q$.
      # $F(K)$ is extraspecial of order $p^{2m+1}$ and of exponent $p$
      # where $2m$ is the order of $p$ modulo $q$.

      if    OrderMod( p, factsize ) = m-1
         and m mod 2 = 1
         and Centre( F ) = FrattiniSubgroup( F )
         and Size( Centre( F ) ) = p then

        # Furthermore, $F / Z(F)$ is a chief factor.
        # It is sufficient to show that the Fitting factor acts
        # trivially on $Z(F)$, and that there is no nontrivial
        # fixed point under the action on $F / Z(F)$.
        # These conditions are sufficient for our test.

        syl:= SylowSubgroup( K, factsize );
        sylgen:= First( GeneratorsOfGroup( syl ), g -> not IsOne( g ) );
        if     IsCentral( Centre( F ), syl )
           and ForAny( GeneratorsOfGroup( F ),
                       x ->     not x in Centre( F )
                            and not IsOne( Comm( x, sylgen ) ) )
          then
          SetIsMonomialGroup( K, false );
          return true;
        fi;

      fi;

    elif factsize mod 2 = 0 and IsPrimeInt( factsize / 2 ) then

      # If $K$ is minimal nonmonomial then
      # $K / F(K)$ is dihedral of order $2 q$ where $q$ is an odd prime.
      # Let $m$ denote the order of 2 mod $q$.
      # $F(K)$ is a central product of an extraspecial group $F$ of order
      # $2^{2m+1}$ (that is purely dihedral) with a cyclic group $C$
      # of order $2^{s+1}$.
      # We have $C = Z(K)$ and $F(K) = C_K( F/Z(F) )$.

      q:= factsize / 2;
      m:= OrderMod( 2, q );

      if m mod 2 = 1 then

        # Compute a Sylow $q$ subgroup $Q$, with generator $r$.
        syl:= SylowSubgroup( K, q );
        sylgen:= First( GeneratorsOfGroup( syl ), g -> not IsOne( g ) );

        # Show that the Fitting factor is dihedral.
        if not IsConjugate( K, sylgen, sylgen^-1 ) then
          return false;
        fi;

        # The centralizer of $Q$ is $Q \times C$.
        # Take an element $fc$ in $F(K) \setminus C$ with $f\in F$,
        # $c\in C$ (exists, since otherwise $Q$ would centralize $F(K)$),
        # and consider $[r,fc] = [r,f] \in F$.  This commutator cannot lie
        # in $Z = F \cap C$ since this would imply that $r^2$ fixes $f$,
        # because of odd order this means $r$ fixes $f$, a contradiction.
        # Thus we find $F$ as the normal closure of $[r,f]$,
        # of order $2^{2m+1}$.
        C:= SylowSubgroup( Centralizer( K, syl ), 2 );
        fc:= First( GeneratorsOfGroup( F ), x -> not x in C );
        F:= NormalClosure( K, Subgroup( K, [ Comm( sylgen, fc ) ] ) );

        if    Size( F ) <> 2^(2*m+1)
           or IsAbelian( F )
           or not IsCentral( K, C )
           or not IsCyclic( C )
           or Size( Intersection( F, C ) ) <> 2         then
          return false;
        fi;

        # Now $Q$ acts nontrivially on $F$, and because every nontrivial
        # irreducible 2-modular representation of $D_{2q}$ has degree
        # $2m$ we have necessarily $F / Z$ an irreducible module, thus
        # $F$ must be extraspecial.

        SetIsMonomialGroup( K, false );
        return true;

      fi;

    elif factsize mod 4 = 0 and IsPrimeInt( factsize / 4 ) then

      # $K / F(K)$ is a central extension of the dihedral group of order
      # $2 t$ where $t$ is an odd prime, such that all involutions lift to
      # elements of order 4.  $F(K)$ is an extraspecial $p$-group
      # for an odd prime $p$ with $p \equiv 1 \pmod{4}$.
      # Let $m$ denote the order of $p$ mod $t$, then $F(K)$ is of order
      # $p^{2m+1}$, and $m$ is odd.

      if    m mod 2 <> 0
         and ( p - 1 ) mod 4 = 0
         and OrderMod( p, factsize / 4 ) = ( m-1 ) / 2
         and Centre( F ) = FrattiniSubgroup( F )
         and Size( Centre( F ) ) = p then

        # Check whether the factor has the required isomorphism type,
        # i.e., whether it is of order $4t$ where $t$ is an odd prime,
        # and each element of order 4 inverts a generator of the
        # Sylow $t$ subgroup (then the presentation is satisfied).

        # Check whether the action of the factor on $F$ is irreducible.
        # Since every faithful representation is of the required
        # dimension we must only check that the central involution and
        # the generator of the Sylow $t$ subgroup both act nontrivially.

        syl:=  SylowSubgroup( K, factsize / 4 );
        sylgen:= First( GeneratorsOfGroup( syl ), g -> not IsOne( g ) );
        gens:= Filtered( GeneratorsOfGroup( SylowSubgroup( K, 2 ) ),
                         x -> Order( x ) = 4 );

        if     not IsEmpty( gens )
           and sylgen * gens[1] * sylgen = gens[1]
           and ForAny( GeneratorsOfGroup( F ),
                       x -> not IsOne( Comm( gens[1], x ) ) )
           and ForAny( GeneratorsOfGroup( F ),
                       x -> not IsOne( Comm( sylgen, x ) ) ) then

          SetIsMonomialGroup( K, false );
          return true;

        fi;

      fi;

    fi;

    # None of the structure conditions is satisfied.
    return false;
end );

InstallMethod( IsMinimalNonmonomial,
    "for a non-solvable group",
    [ IsGroup ],
    function( K )

    local info, q, p, f;

    if IsSolvableGroup(K) then
      TryNextMethod();
    fi;

    # Monomial groups are solvable. A minimal-nonmonomial group by
    # definition has every proper quotient and every proper subgroup
    # monomial, hence a non-solvable minimal-nonmonomial group must
    # have every proper subgroup and every proper quotient be solvable.
    # If [G,G] were proper, it would have to be solvable, and thus G
    # solvable, hence G is perfect. If G had any proper normal subgroups
    # then the quotient would have to be both perfect and solvable, so
    # G must be simple.
    if not IsSimpleGroup(K) then
      return false;
    fi;

    # Indeed, it must be minimal simple as classified by Corollary 1 in
    # Thompson's 1968 N-Groups paper, doi:10.1090/S0002-9904-1968-11953-6
    # * PSL(2,2^f) for f prime, and all such are minimal-non-M groups
    # * PSL(2,3^f) for f an odd prime, and all such are minimal-non-M groups
    # * PSL(2,p) for p a prime congruent to 2 or 3 mod 5, and all such are m-n-M
    # * PSL(3,3) which is NOT a minimal-non-M group (contains SL(2,3))
    # * Sz(2^f) for f an odd prime, and all such are minimal-non-M groups
    #
    # The minimal-non-M part follows from the fact that metabelian groups
    # are monomial groups.
    # * For PSL(2,q) Dickson classified their subgroups; the maximal ones are
    #   either metabelian (hence monomial) or non-solvable; but this latter case
    #   is ruled out here by being minimal simple; hence these groups are minimal
    #   non-monomial.
    # * For PSL(3,3) a subgroup isomorphic to SL(2,3) is not an M-group
    # * For Sz(q), Suzuki 1960 shows that maximal subgroups are either the
    #   normalizer H of a Sylow 2-group Q, or one of a few metabelian groups.
    #   The characters of H are calculated in section 11, page 126, and
    #   are all induced from the monomial group Q.
    #   As an induced character can only be irreducible if the original
    #   character was irreducible, and every irreducible of Q is induced
    #   from a linear, and induction from that subgroup of Q and then to
    #   H is the same as induction directly to H, we get that every
    #   character of H is induced from a linear character (q-1 from H itself,
    #   1 from Q, and 2 from a subgroup of Q). I.e., H is monomial.
    #
    info := IsomorphismTypeInfoFiniteSimpleGroup(K);
    if info.series = "A" then
      return info.parameter = 5; # A5 = PSL(2,4) is minimal non-monomial
    elif info.series = "L" then
      if info.parameter[1] = 2 then # GAP reports PSL(3,2)=PSL(2,7) as [2,7]
        q := info.parameter[2];
        p := SmallestRootInt(q);
        f := LogInt(q,p);
        if p = 2 and IsPrimeInt(f) then return true;
        elif p = 3 and IsOddInt(f) and IsPrimeInt(f) then return true;
        elif p = q and 0 = (p^2+1) mod 5 then return true;
        fi;
      fi;
    elif info.series = "2B" then
      q := info.parameter;
      f := LogInt(q,2);
      return IsPrimeInt(f);
    fi;
    return false;
end);


#############################################################################
##
#F  MinimalNonmonomialGroup( <p>, <factsize> )
##
InstallGlobalFunction( MinimalNonmonomialGroup, function( p, factsize )

    local K,          # free group
          Kgens,      # free generators of `K'
          rels,       # relators of `K'
          name,       # name of `K'
          t,          # number with suitable multiplicative order
          form,       # matrix of the commutator form
          x,          # indeterminate
          val,        # one entry in `form'
          i,          # loop
          j,          # loop
          v,          # coefficient vector
          rhs,        # right hand side of a relator when viewed as relation
          q,          # another name for `factsize'
          2m,         # exponent of size of Frattini factor of group $F$
          m,          # half of `2m'
          facts,      # factors of cylotomic polynomial
          coeff,      # coefficients vector of one factor in `facts'
          inv,        # inverse of first in `coeff'
          f,          # `GF(2)'
          s,          # exponent of centre (minus 1) in dihedral case
          W,          # part of matrix of an order 2 automorphism
          Winv,       # part of matrix of an order 2 automorphism
          Atr;        # transposed of $A$

    if   factsize = 4 then

      # $K / F(K)$ is cyclic of order 4,
      # $F(K)$ is extraspecial of order $p^3$ and of exponent $p$
      # where $p \equiv -1 \pmod{4}$.

      if not IsPrimeInt( p ) or p < 3 or ( p + 1 ) mod 4 <> 0 then
        Info( InfoMonomial, 1, "<p> must be a prime congruent 1 mod 4" );
        return fail;
      fi;

      K:= FreeGroup(IsSyllableWordsFamily, 5 );
      Kgens:= GeneratorsOfGroup( K );
      name:= Concatenation( String(p), "^(1+2):4" );
      rels:= [
                # the relators of the cyclic group
                Kgens[1]^2 / Kgens[2], Kgens[2]^2,

                # the relators of the extraspecial group
                Kgens[3]^p, Kgens[4]^p, Kgens[5]^p,
                Kgens[4]^Kgens[3] / ( Kgens[4] * Kgens[5]^-1 ),

                # the action of the cyclic group
                Kgens[3]^Kgens[1] / Kgens[4],
                Kgens[4]^Kgens[1] / Kgens[3]^-1,
                Kgens[3]^Kgens[2] / Kgens[3]^-1,
                Kgens[4]^Kgens[2] / Kgens[4]^-1    ];

    elif factsize = 8 then

      # $K / F(K)$ is quaternion of order 8,
      # $F(K)$ is extraspecial of order $p^3$ and of exponent $p$
      # where $p \equiv 1 \pmod{4}$.

      if not IsPrimeInt( p ) or p < 5 or ( p - 1 ) mod 4 <> 0 then
        Info( InfoMonomial, 1, "<p> must be a prime congruent 1 mod 4" );
        return fail;
      fi;

      # Choose $t$ with $t^2 \equiv -1 \pmod{p}$.
      t:= PrimitiveRootMod( p ) ^ ( (p-1)/4 );

      K:= FreeGroup(IsSyllableWordsFamily, 6 );
      Kgens:= GeneratorsOfGroup( K );
      name:= Concatenation( String(p), "^(1+2):Q8" );
      rels:= [
               # the relators of the quaternion group
               Kgens[1]^2 / Kgens[3], Kgens[2]^2 / Kgens[3], Kgens[3]^2,
               (Kgens[2]^Kgens[1] ) / ( Kgens[2]^-1 ),

               # the relators of the extraspecial group
               Kgens[4]^p, Kgens[5]^p, Kgens[6]^p,
               Kgens[5]^Kgens[4] / ( Kgens[5]*Kgens[6]^-1 ),

               # the action of the quaternion group
               Kgens[4]^Kgens[1] / Kgens[4]^t,
               Kgens[5]^Kgens[1] / Kgens[5]^( (1/t) mod p ),
               Kgens[4]^Kgens[2] / Kgens[5],
               Kgens[5]^Kgens[2] / Kgens[4]^-1,
               Kgens[4]^Kgens[3] / Kgens[4]^-1,
               Kgens[5]^Kgens[3] / Kgens[5]^-1  ];

    elif factsize <> 2 and IsPrimeInt( factsize ) then

      # $K / F(K)$ has order an odd prime $q$.
      # $F(K)$ is extraspecial of order $p^{2m+1}$ and of exponent $p$
      # where $2m$ is the order of $p$ modulo $q$,

      q:= factsize;
      2m:= OrderMod( p, q );

      if 2m = 0 or 2m mod 2 <> 0 then
        Info( InfoMonomial, 1,
              "order of <p> mod <factsize> must be nonzero and even" );
        return fail;
      fi;

      m:= 2m / 2;

      # The `q'-th cyclotomic polynomial splits over the field with
      # `p' elements into factors of degree `2*m'.
      facts:= Factors( CyclotomicPolynomial( GF(p), q ) );

      # Take the coefficients i$a_1, a_2, \ldots, a_{2m}, 1$ of a factor.
      coeff:= IntVecFFE(
          - CoefficientsOfLaurentPolynomial( facts[1] )[1] );

      # Compute the vector $\epsilon$.
      v:= [];
      v[ 2m-1 ]:= 1;
      for i in [ m .. 2m-2 ] do
        v[i]:= 0;
      od;
      for j in [ m-1, m-2 .. 1 ] do
        v[j]:= coeff[ j+2 ] - coeff[j];
        for i in [ 1 .. m-j-1 ] do
          v[j]:= v[j] + v[ m-i ] * coeff[ m+i+j+1 ];
        od;
        v[j]:= v[j] mod p;
      od;

      # Write down the presentation,
      K:= FreeGroup(IsSyllableWordsFamily, 2m+2 );
      Kgens:= GeneratorsOfGroup( K );
      name:= Concatenation( String(p), "^(1+", String( 2m ), "):",
                            String(q) );

      # power relators \ldots
      rels:= [ Kgens[1]^q ];
      if p = 2 then
        for j in [ 2 .. 2m+1 ] do
          Add( rels, Kgens[j]^p / Kgens[2m+2] );
        od;
        Add( rels, Kgens[ 2m+2 ]^p );
      else
        for j in [ 2 .. 2m+2 ] do
          Add( rels, Kgens[j]^p );
        od;
      fi;

      # \ldots action of the automorphism, \ldots
      for j in [ 2 .. 2m ] do
        Add( rels, Kgens[j]^Kgens[1] / Kgens[j+1] );
      od;
      rhs:= One( K );
      for j in [ 1 .. 2m ] do
        rhs:= rhs * Kgens[j+1]^Int( coeff[j] );
      od;

      Add( rels, Kgens[2m+1]^Kgens[1] / rhs );

      # \ldots and commutator relators.
      for i in [ 3 .. 2m+1 ] do
        for j in [ 2 .. i-1 ] do
          Add( rels, Kgens[i]^Kgens[j]
                     / ( Kgens[i] * Kgens[2m+2]^v[ 2m+j-i ] ) );
        od;
      od;

    elif factsize mod 2 = 0 and IsPrimeInt( factsize / 2 ) then

      # $K / F(K)$ is dihedral of order $2 q$ where $q$ is an odd prime.
      # Let $m$ denote the order of 2 mod $q$ (which is odd).
      # $F(K)$ is a central product of an extraspecial group $F$ of order
      # $2^{2m+1}$ (that is purely dihedral) with a cyclic group $C$
      # of order $2^{s+1}$.  Note that in this case the second argument
      # is $s+1$.
      # We have $C = Z(K)$ and $F(K) = C_K( F/Z(F) )$.

      s:= p-1;
      q:= factsize / 2;
      m:= OrderMod( 2, q );

      if m mod 2 = 0 then
        Info( InfoMonomial, 1, "order of 2 mod <factsize>/2 must be odd" );
        return fail;
      fi;

      # The first generator is $t$, the second is $r$,
      # generators 3 to $3+s-1$ are the powers of $t$ that are
      # not contained in $Z(K)$.
      K:= FreeGroup(IsSyllableWordsFamily, 2*m + s + 3 );
      Kgens:= GeneratorsOfGroup( K );
      name:= Concatenation( "2^(1+", String( 2*m ), ")" );
      if 0 < s then
        name:= Concatenation( "(", name, "Y", String( 2^(s+1) ), ")" );
      fi;
      name:= Concatenation( name, ":D", String( factsize ) );

      rels:= [];

      # $t^2$ is a generator of $Z(K)$.
      if s = 0 then

        # $t$ squares to $z$ or the identity, since for $s = 0$ we have
        # $Z(K) = \langle z \rangle$.
        # Here we choose the identity in order to get Dade\'s example.
        rels[1]:= Kgens[1]^2 / One( K );

      else

        # Describe the cyclic group spanned by $t^2$.
        rels[1]:= Kgens[1]^2 / Kgens[2];
        for i in [ 2 .. s ] do
          rels[i]:= Kgens[i]^2 / Kgens[i+1];
        od;
        rels[ s+1 ]:= Kgens[ s+1 ]^2 / Kgens[ 2*m+s+3 ];

      fi;

      # The $(s+2)$-nd generator is $r$, that of order $q$.
      rels[ s+2 ]:= Kgens[ s+2 ]^q;

      # $t$ inverts $r$.
      rels[ s+3 ]:= Kgens[ s+2 ] ^ Kgens[1] / Kgens[ s+2 ]^-1;

      # The remaining $2m+1$ generators form the extraspecial group $F$.
      for i in [ s+3 .. 2*m+s+3 ] do
        rels[ i+1 ]:= Kgens[ i ]^2;
      od;
      for i in [ 1 .. m ] do
        Add( rels, Kgens[ s+2+m+i ]^Kgens[ s+2+i ]
                   / ( Kgens[ s+2+m+i ] / Kgens[ 2*m+s+3 ] ) );
      od;

      # Describe the actions of $t$ and $r$ on $F$.
      # First we construct the matrices of the linear actions on the
      # Frattini factor of $F$.  (Note that because of even characteristic
      # the sign plays no role here.)
      f:= GF(2);
      facts:= Factors( CyclotomicPolynomial( f, q ) );
      coeff:= CoefficientsOfLaurentPolynomial( facts[1] )[1];

      Atr:= NullMat( m, m, f );
      for i in [ 1 .. m-1 ] do
        Atr[i+1][i]:= One( f );
      od;
      for i in [ 1 .. m ] do
        Atr[i][m]:= coeff[i];
      od;

      v:= Zero( f );
      v:= List( Atr, x -> v );
      v[1]:= One( f );
      W:= [ v ];
      for i in [ 2 .. m ] do
        v:= v * Atr;
        W[i]:= v;
      od;

      Winv:= W^-1;

      W     := List( W   , IntVecFFE );
      Winv  := List( Winv, IntVecFFE );
      coeff := IntVecFFE( coeff );

      # The action of $t$ is described by `W' and its inverse.
      for i in [ s+3 .. s+m+2 ] do
        rhs:= One( K );
        for j in [ 1 .. m ] do
          rhs:= rhs * Kgens[ s+2+m+j ]^W[i-s-2][j];
        od;
        Add( rels, Kgens[i] ^ Kgens[1] / rhs );
      od;
      for i in [ s+m+3 .. s+2*m+2 ] do
        rhs:= One( K );
        for j in [ 1 .. m ] do
          rhs:= rhs * Kgens[ s+2+j ]^Winv[i-s-m-2][j];
        od;
        Add( rels, Kgens[i] ^ Kgens[1] / rhs );
      od;

      # The action of $r$ is described by $A$ and its transposed inverse.
      # (first half)
      for i in [ s+3 .. s+m+1 ] do
        Add( rels, Kgens[i] ^ Kgens[s+2] / Kgens[i+1] );
      od;
      rhs:= One( K );
      for j in [ 1 .. m ] do
        rhs:= rhs * Kgens[ s+2+j ]^coeff[j];
      od;
      Add( rels, Kgens[ s+m+2 ] ^ Kgens[s+2] / rhs );

      # (second half)
      for i in [ s+m+3 .. s+2*m+1 ] do
        Add( rels, Kgens[i] ^ Kgens[s+2]
                   / ( Kgens[s+m+3]^coeff[i-s-m-1] * Kgens[i+1] ) );
      od;
      Add( rels, Kgens[ s+2*m+2 ] ^ Kgens[s+2] / Kgens[s+m+3] );

    elif factsize mod 4 = 0 and IsPrimeInt( factsize / 4 ) then

      # $K / F(K)$ is a central extension of the dihedral group of order
      # $2 t$ where $t$ is an odd prime, such that all involutions lift to
      # elements of order 4.  $F(K)$ is an extraspecial $p$-group
      # for an odd prime $p$ with $p \equiv 1 \pmod{4}$.
      # Let $m$ denote the order of $p$ mod $t$, then $F(K)$ is of order
      # $p^{2m+1}$, and $m$ is odd.

      t:= factsize / 4;
      m:= OrderMod( p, t );

      if m mod 2 = 0 or ( p - 1 ) mod 4 <> 0 then
        Info( InfoMonomial, 1,
              "order of <p> mod <t> must be odd, <p> congr. 1 mod 4" );
        return fail;
      fi;

      facts:= Factors( CyclotomicPolynomial( GF(p), t ) );
      coeff:= CoefficientsOfLaurentPolynomial( facts[1] )[1];
      inv:= Int( coeff[1]^-1 );
      coeff:= IntVecFFE( coeff );

      # The symplectic form (that will be used to define the
      # commutator form) is derived from the standard symplectic form
      # for the 2-dimensional vector space over $GF(p^{2m})$ by first
      # blowing up to the $2m$ dimensional vector space over $GF(p)$,
      # and then projecting onto $GF(p)$ (that is, the first component).

      # (We need only the lower triangle of the matrix of the form,
      # and this is nonzero only in the lower left square.)

      form:= [];
      for i in [ 1 .. m ] do
        form[i]:= [];
        for j in [ 1 .. m-i+1 ] do
          form[i][j]:= 0;
        od;
      od;
      form[1][1]:= -1;
      x:= Indeterminate( GF(p) );
      for i in [ 2 .. m ] do
        val:= CoefficientsOfLaurentPolynomial(
                  x^(i+m-2) mod facts[1] );
        val:= - Int( ShiftedCoeffs( val[1], val[2] )[1] );
        for j in [ i .. m ] do
          form[ m+i-j ][j]:= val;
        od;
      od;

      # Write down the presentation.
      K:= FreeGroup(IsSyllableWordsFamily, 2*m + 4 );
      Kgens:= GeneratorsOfGroup( K );
      name:= Concatenation( String(p), "^(1+", String( 2*m), "):2.D",
                            String( factsize/2 ) );

      # power relations,
      rels:= [ Kgens[1]^2 / Kgens[3], Kgens[2]^t / Kgens[3], Kgens[3]^2 ];
      for i in [ 4 .. 2*m+4 ] do
        Add( rels, Kgens[i]^p );
      od;

      # action of the Frattini factor,
      # first the order 4 element
      for i in [ 4 .. m+3 ] do
        Add( rels, Kgens[i]^Kgens[1] / Kgens[ i+m ]^-1 );
        Add( rels, Kgens[ i+m ]^Kgens[1] / Kgens[i] );
      od;
      Add( rels, Kgens[2] ^ Kgens[1] / Kgens[2]^-1 );

      # (The element of order $2t$ ...)
      for i in [ 4 .. m+2 ] do
        Add( rels, Kgens[i]^Kgens[2] / Kgens[i+1]^-1 );
      od;
      rhs:= One( K );
      for i in [ 1 .. m ] do
        rhs:= rhs * Kgens[ i+3 ]^coeff[i];
      od;
      Add( rels, Kgens[ m+3 ]^Kgens[2] / rhs );

      rhs:= One( K );
      for i in [ 1 .. m ] do
        rhs:= rhs * Kgens[ m+i+3 ]^( coeff[i+1] * inv );
      od;
      Add( rels, Kgens[ m+4 ]^Kgens[2] / rhs );

      for i in [ 5 .. m+3 ] do
        Add( rels, Kgens[ m+i ]^Kgens[2] / Kgens[ m+i-1 ]^-1 );
      od;

      # (The central involution of the Fitting factor inverts.)
      for i in [ 4 .. m+3 ] do
        Add( rels, Kgens[i]^Kgens[3] / Kgens[i]^-1 );
        Add( rels, Kgens[ i+m ]^Kgens[3] / Kgens[ i+m ]^-1 );
      od;

      # The extraspecial group is defined by the commutator form
      # constructed above.
      for i in [ m+1 .. 2*m ] do
        for j in [ 1 .. m ] do
          Add( rels, Kgens[i+3]^Kgens[j+3]
                     / ( Kgens[i+3] * Kgens[ 2*m + 4 ]^form[i-m][j] ) );
        od;
      od;

    else
      return fail;
    fi;

    K:= PolycyclicFactorGroup( K, rels );
    ConvertToStringRep( name );
    SetName( K, name );
    SetIsMinimalNonmonomial( K, true );

    return K;
end );
