#############################################################################
##
#W  ctblmono.gi                 GAP library                     Thomas Breuer
#W                                                         & Erzsebet Horvath
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the functions dealing with monomiality questions for
##  solvable groups.
##
Revision.ctblmono_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  Alpha( <G> )  . . . . . . . . . . . . . . . . . . . . . . . . for a group
##
InstallMethod( Alpha,
    "method for a group",
    true,
    [ IsGroup ], 0,
    function( G )

    local irr,        # irreducible characters of 'G'
          degrees,    # set of degrees of 'irr'
          chars,      # at position <i> all in 'irr' of degree 'degrees[<i>]'
          chi,        # one character
          alpha,      # result list
          max,        # maximal derived length found up to now
          kernels,    # at position <i> the kernels of all in 'chars[<i>]'
          minimal,    # list of minimal kernels
          relevant,   # minimal kernels of one degree
          k,          # one kernel
          ker,
          dl;         # list of derived lengths

    Info( InfoMonomial, 1, "Alpha called for group ", G );

    # Compute the irreducible characters and the set of their degrees;
    # we need all irreducibles so it is reasonable to compute the table.
    irr:= List( Irr( G ), ValuesOfClassFunction );
    degrees:= Set( List( irr, x -> x[1] ) );
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
    kernels:= List( chars, x -> Set( List( x, KernelChar ) ) );

    # list of all minimal elements found up to now
    minimal:= [];

    Info( InfoMonomial, 1,
          "Alpha: There are ", Length( degrees )+1, " different degrees." );

    for ker in kernels do

      # We may remove kernels that contain a (minimal) kernel
      # of a character of smaller or equal degree.

      # Make sure to consider minimal elements of the actual degree first.
      Sort( ker, function(x,y) return Length(x) < Length(y); end );

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
      Sort( minimal, function(x,y) return Length(x) < Length(y); end );

      # Compute the derived lengths
      for k in relevant do

        dl:= Length( DerivedSeriesOfGroup(
                 FactorGroupNormalSubgroupClasses( G, k ) ) ) - 1;
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
    "method for a group",
    true,
    [ IsGroup ], 0,
    function( G )

    local delta,  # result list
          alpha,  # 'Alpha( <G> )'
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
#M  IsBergerCondition( <chi> )  . . . . . . . . .  for a character with group
##
InstallOtherMethod( IsBergerCondition,
    "method for a character with group",
    true,
    [ IsCharacter and IsClassFunctionWithGroup ], 0,
    function( chi )

    local G,           # group of <chi>
          values,      # values of 'chi'
          ker,         # intersection of kernels of smaller degree
          deg,         # degree of <chi>
          psi,         # one irreducible character of $G$
          kerchi,      # kernel of <chi> (as group)
          isberger;    # result

    Info( InfoMonomial, 1,
          "IsBergerCondition called for character ",
          CharacterString( chi ) );

    values:= ValuesOfClassFunction( chi );
    deg:= values[1];
    G:= UnderlyingGroup( chi );

    if 1 < deg then

      # We need all characters of smaller degree,
      # so it is reasonable to compute the character table of the group
      ker:= [ 1 .. Length( values ) ];
      for psi in Irr( UnderlyingCharacterTable( chi ) ) do
        if DegreeOfCharacter( psi ) < deg then
          IntersectSet( ker, KernelChar( psi ) );
        fi;
      od;

      # Check whether the derived group of this normal subgroup
      # lies in the kernel of 'chi'.
      kerchi:= KernelChar( values );
      if IsSubsetSet( kerchi, ker ) then

        # no need to compute subgroups
        isberger:= true;
      else
        isberger:= IsSubgroup( KernelOfCharacter( chi ),
                       DerivedSubgroup( NormalSubgroupClasses( G, ker ) ) );
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
    "method for a group",
    true,
    [ IsGroup ], 0,
    function( G )

    local psi,         # one irreducible character of $G$
          isberger,    # result
          degrees,     # different character degrees of 'G'
          kernels,     #
          pos,         #
          i,           # loop variable
          leftinters,  #
          left,        #
          right;       #

    Info( InfoMonomial, 1, "IsBergerCondition called for group ", G );

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
          Add( kernels, KernelChar( psi ) );
        else
          IntersectSet( kernels[ pos ], KernelChar( psi ) );
        fi;
      od;
      SortParallel( degrees, kernels );

      # Let $1 = f_1 \leq f_2 \leq\ldots \leq f_n$ the distinct
      # irreducible degrees of 'G'.
      # We must have for all $1 \leq i \leq n-1$ that
      # \[ ( \bigcap_{\psi(1) \leq f_i}  \ker(\psi) )^{\prime} \leq
      #      \bigcap_{\chi(1) = f_{i+1}} \ker(\chi) \]

      i:= 1;
      isberger:= true;
      leftinters:= kernels[1];

      while i < Length( degrees ) and isberger do

        # 'leftinters' becomes $\bigcap_{\psi(1) \leq f_i} \ker(\psi)$.
        IntersectSet( leftinters, kernels[i] );
        if not IsSubsetSet( kernels[i+1], leftinters ) then

          # we have to compute the groups
          left:= DerivedSubgroup( NormalSubgroupClasses( G, leftinters ) );
          right:= NormalSubgroupClasses( G, kernels[i+1] );
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
#F  TestHomogeneous( <chi>, <N> )
##
InstallGlobalFunction( TestHomogeneous, function( chi, N )

    local G,        # the group of <chi>
          t,        # character table of 'G'
          classes,  # class lengths of 't'
          values,   # values of <chi>
          cl,       # classes of 'G' that form <N>
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
      cl:= ClassesOfNormalSubgroup( UnderlyingGroup( chi ), N );
    fi;

    G:= UnderlyingGroup( chi );
    t:= CharacterTable( G );
    classes:= SizesConjugacyClasses( t );
    norm:= Sum( cl, c -> classes[c] * values[c]
                                    * GaloisCyc( values[c], -1 ), 0 );

    if norm = Sum( classes{ cl }, 0 ) then

      # The restriction is irreducible.
      return rec( isHomogeneous := true,
                  comment       := "restricts irreducibly" );

    else

      # 'chi' restricts reducibly.
      # Compute the table of 'N' if necessary,
      # and check the constituents of the restriction
      G:= UnderlyingGroup( chi );
      N:= NormalSubgroupClasses( G, cl );
      tn:= CharacterTable( N );
      fus:= FusionConjugacyClasses( N, G );
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
InstallMethod( TestQuasiPrimitive,
    "method for a character",
    true,
    [ IsCharacter ], 0,
    function( chi )

    local values,   # list of character values
          t,        # character table of 'chi'
          nsg,      # list of normal subgroups of 't'
          cen,      # centre of 'chi'
          allhomog, # are all restrictions up to now homogeneous?
          j,        # loop over normal subgroups
          testhom,  # test of homogeneous restriction
          test;     # result record

    Info( InfoMonomial, 1,
          "TestQuasiPrimitive called for character ",
          CharacterString( chi ) );

    values:= ValuesOfClassFunction( chi );

    # Linear characters are primitive.
    if values[1] = 1 then

      test:= rec( isQuasiPrimitive := true,
                  comment          := "linear character" );

    else

      t:= UnderlyingCharacterTable( chi );

      # Compute the normal subgroups of 'G' containing the centre of 'chi'.

      # Note that 'chi' restricts homogeneously to all normal subgroups
      # of 'G' if (and only if) it restricts homogeneously to all those
      # normal subgroups containing the centre of 'chi'.

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

      cen:= CentreChar( values );
      nsg:= NormalSubgroups( t );
#T !
      nsg:= Filtered( nsg, x -> IsSubsetSet( x, cen ) );

      allhomog:= true;
      j:= 1;

      while allhomog and j <= Length( nsg ) do

        testhom:= TestHomogeneous( chi, nsg[j] );
        if not testhom.isHomogeneous then

          # nonhomogeneous restriction found
          allhomog:= false;
          test:= rec( isQuasiPrimitive := false,
                      comment          := testhom.comment,
                      character        := testhom.character );

        fi;

        j:= j+1;

      od;

      if allhomog then
        test:= rec( isQuasiPrimitive := true,
                    comment          := "all restrictions checked" );
      fi;

    fi;

    Info( InfoMonomial, 1,
          "TestQuasiPrimitive returns '", test.isQuasiPrimitive, "'" );

    return test;
    end );


#############################################################################
##
#M  IsQuasiPrimitive( <chi> ) . . . . . . . . . . . . . . . . for a character
##
InstallMethod( IsQuasiPrimitive,
    "method for a character",
    true,
    [ IsCharacter ], 0,
    chi -> TestQuasiPrimitive( chi ).isQuasiPrimitive );


#############################################################################
##
#M  IsPrimitiveCharacter( <chi> ) . . . . . . . .  for a character with group
##
InstallMethod( IsPrimitiveCharacter,
    "method for a character with group",
    true,
    [ IsCharacter and IsClassFunctionWithGroup ], 0,
    function( chi )
    if not IsSolvableGroup( UnderlyingGroup( chi ) ) then
      TryNextMethod();
    fi;
    return TestQuasiPrimitive( chi ).isQuasiPrimitive;
    end );


#############################################################################
##
#F  TestInducedFromNormalSubgroup( <chi>, <N> )
#F  TestInducedFromNormalSubgroup( <chi> )
##
##  returns a record with information about whether the irreducible group
##  character <chi> of the group $G$ is induced from a proper normal subgroup
##  of $G$.
##
##  If <chi> is the only argument then it is checked whether there is a
##  maximal normal subgroup of $G$ from that <chi> is induced.
##
##  A second argument <N> must be a normal subgroup of $G$ or the list of
##  class positions of a normal subgroup of $G$.  Then it is checked
##  whether <chi> is induced from <N>.
##
##  The result contains always a component 'comment', a string.
##  The component 'isInduced' is 'true' or 'false', depending on whether
##  <chi> is induced.  In the 'true' case the component 'character'
##  contains a character of a maximal normal subgroup from that <chi> is
##  induced.
##
InstallGlobalFunction( TestInducedFromNormalSubgroup, function( arg )

    local sizeN,      # size of <N>
          sizefactor, # size of $G / <N>$
          values,     # values list of 'chi'
          m,          # list of all maximal normal subgroups of $G$
          test,       # intermediate result
          tn,         # character table of <N>
          irr,        # irreducibles of 'tn'
          i,          # loop variable
          scpr,       # one scalar product in <N>
          N,          # optional second argument
          cl,         # classes corresponding to 'N'
          chi;        # first argument

    # check the arguments
    if Length( arg ) < 1 or Length( arg ) > 2
       or not IsCharacter( arg[1] ) then
      Error( "usage: TestInducedFromNormalSubgroup( <chi>[, <N>] )" );
    fi;

    chi:= arg[1];

    Info( InfoMonomial, 1,
          "TestInducedFromNormalSubgroup called with character ",
          CharacterString( chi ) );

    if Length( arg ) = 1 then

      # 'TestInducedFromNormalSubgroup( <chi> )'
      if DegreeOfCharacter( chi ) = 1 then

        return rec( isInduced:= false,
                    comment  := "linear character" );

      else

        # Get all maximal normal subgroups.
        m:= MaximalNormalSubgroups( UnderlyingCharacterTable( chi ) );

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

      # 'TestInducedFromNormalSubgroup( <chi>, <N> )'

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
        N:= NormalSubgroupClasses( UnderlyingGroup( chi ), N );

      else

        # Check whether <N> has less conjugacy classes than its index is.
        if Length( ConjugacyClasses( N ) ) <= sizefactor then

          return rec( isInduced := false,
                      comment   := "<N> has too few conjugacy classes" );

        fi;

        cl:= ClassesOfNormalSubgroup( UnderlyingGroup( chi ), N );

        # Check whether the character vanishes outside <N>.
        for i in [ 2 .. Length( values ) ] do
          if not i in cl and values[i] <> 0 then
            return rec( isInduced := false,
                        comment   := "<chi> does not vanish outside <N>" );
          fi;
        od;

      fi;

      # Compute the restriction to <N>.
      chi:= values{ FusionConjugacyClasses( N, UnderlyingGroup( chi ) ) };

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
    "method for a character",
    true,
    [ IsCharacter ], 0,
    chi -> TestInducedFromNormalSubgroup( chi ).isInduced );


#############################################################################
##
#M  TestSubnormallyMonomial( <G> )  . . . . . . . . . . . . . . . for a group
##
InstallMethod( TestSubnormallyMonomial,
    "method for a group",
    true,
    [ IsGroup ], 0,
    function( G )

    local test,       # result record
          orbits,     # orbits of characters
          chi,        # loop over 'orbits'
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
          "TestSubnormallyMonomial returns with '",
          test.isSubnormallyMonomial, "'" );
    return test;
    end );


#############################################################################
##
#M  TestSubnormallyMonomial( <chi> )  . . . . . .  for a character with group
##
InstallOtherMethod( TestSubnormallyMonomial,
    "method for a character with group",
    true,
    [ IsCharacter and IsClassFunctionWithGroup ], 0,
    function( chi )

    local test,       # result record
          testsm;     # local function for recursive check

    Info( InfoMonomial, 1,
          "TestSubnormallyMonomial called for character ",
          CharacterString( chi ) );

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

      # Given a character 'chi' of the group $N$, and two classes lists
      # 'forbidden' and 'allowed' that describe all maximal normal
      # subgroups of $N$, where 'forbidden' denotes all those normal
      # subgroups through that 'chi' cannot be subnormally induced,
      # return either a linear character of a subnormal subgroup of $N$
      # from that 'chi' is induced, or 'false' if no such character exists.
      # If we reach a nilpotent group then we return a character of this
      # group, so the character is not necessarily linear.

      testsm:= function( chi, forbidden, allowed )

      local N,       # group of 'chi'
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

      # Loop over 'allowed'.
      for cl in allowed do

        if ForAll( [ 1 .. len ], x -> chi[x] = 0 or x in cl ) then

          # 'chi' vanishes outside 'n', so is induced from 'n'.

          n:= NormalSubgroupClasses( N, cl );
          nt:= CharacterTable( n );

          # Compute a constituent of the restriction of 'chi' to 'n'.
          fus:= FusionConjugacyClasses( n, N );
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

          # Compute allowed and forbidden maximal normal subgroups of 'n'.
          mns:= MaximalNormalSubgroups( nt );
          nallowed:= [];
          nforbid:= [];
          for gp in mns do

            # A group is forbidden if it is the intersection of a group
            # in 'forbid' with 'n'.
            fusgp:= Set( fus{ gp } );
            if ForAny( forbid, x -> IsSubsetSet( x, fusgp ) ) then
              Add( nforbid, gp );
            else
              Add( nallowed, gp );
            fi;

          od;

          # Check whether 'const' is subnormally induced from 'n'.
          test:= testsm( const, nforbid, nallowed );
          if test <> false then
            return test;
          fi;

        fi;

        # Add 'n' to the forbidden subgroups.
        Add( forbid, cl );

      od;

      # All allowed normal subgroups have been checked.
      return false;
      end;


      # Run the recursive search.
      # Here all maximal normal subgroups are allowed.
      test:= testsm( chi, [],
                 MaximalNormalSubgroups( UnderlyingCharacterTable( chi ) ) );

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
          "TestSubnormallyMonomial returns with '",
          test.isSubnormallyMonomial, "'" );
    return test;
    end );


#############################################################################
##
#M  IsSubnormallyMonomial( <G> )  . . . . . . . . . . . . . . . . for a group
#M  IsSubnormallyMonomial( <chi> )  . . . . . . .  for a character with group
##
InstallMethod( IsSubnormallyMonomial,
    "method for a group",
    true,
    [ IsGroup ], 0,
    G -> TestSubnormallyMonomial( G ).isSubnormallyMonomial );

InstallOtherMethod( IsSubnormallyMonomial,
    "method for a character with group",
    true,
    [ IsCharacter and IsClassFunctionWithGroup ], 0,
    chi -> TestSubnormallyMonomial( chi ).isSubnormallyMonomial );


#############################################################################
##
#M  IsMonomialNumber( <n> ) . . . . . . . . . . . . .  for a positive integer
##
InstallMethod( IsMonomialNumber,
    "method for a positive integer",
    true,
    [ IsPosInt ], 0,
    function( n )

    local factors,   # list of prime factors of 'n'
          collect,   # list of (prime divisor, exponent) pairs
          nu2,       # $\nu_2(n)$
          pair,      # loop over 'collect'
          pair2,     # loop over 'collect'
          ord;       # multiplicative order

    factors := FactorsInt( n );
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
#M  TestMonomialQuick( <chi> )  . . . . . . . . .  for a character with group
##
##  The following criteria are used for a character <chi>.
##
##  o Linear characters are monomial.
##  o If the group has the component 'isMonomial' with value 'true' then
##    <chi> is monomial.
##  o If the codegree is a prime power then the character is monomial.
##  o Let $\pi$ be the set of primes in the codegree of <chi>.
##    Then <chi> is induced from a Hall $\pi$ subgroup (Isaacs).
##  o The factor group modulo the kernel is checked for monomiality
##    by 'TestMonomialQuick'.
##
#T Was ist das Kriterium, nach dem etwas in 'Quick'getestet wird?
#T Verzicht auf teure Tafel-Berechnungen?
##
InstallMethod( TestMonomialQuick,
    "method for a character with group",
    true,
    [ IsCharacter and IsClassFunctionWithGroup ], 0,
    function( chi )

    local G,          # group of 'chi'
          factsize,   # size of the kernel factor of 'chi'
          codegree,   # codegree of 'chi'
          pi,         # prime divisors of a Hall subgroup
          hall,       # size of 'pi' Hall subgroup of kernel factor
          ker,        # kernel of 'chi'
          t,          # character table of 'G'
          grouptest;  # result of the call to 'G / ker'

    Info( InfoMonomial, 1,
          "TestMonomialQuick called for character ",
          CharacterString( chi ) );

    if   HasIsMonomialCharacter( chi ) then

      # The character knows about being monomial.
      Info( InfoMonomial, 1,
            "TestMonomialQuick returns with '",
            IsMonomialCharacter( chi ), "'" );
      return rec( isMonomial := IsMonomialCharacter( chi ),
                  comment    := "was already stored" );

    elif DegreeOfCharacter( chi ) = 1 then

      # Linear characters are monomial.
      Info( InfoMonomial, 1,
            "TestMonomialQuick returns with 'true'" );
      return rec( isMonomial := true,
                  comment    := "linear character" );

    elif TestMonomialQuick( UnderlyingGroup( chi ) ).isMonomial = true then
#T ?

      # The whole group is known to be monomial.
      Info( InfoMonomial, 1,
            "TestMonomialQuick returns with 'true'" );
      return rec( isMonomial := true,
                  comment    := "whole group is monomial" );

    fi;

    G   := UnderlyingGroup( chi );
    chi := ValuesOfClassFunction( chi );

    # Replace 'G' by the factor group modulo the kernel.
    ker:= KernelChar( chi );
    if 1 < Length( ker ) then
      t:= CharacterTable( G );
      factsize:= Size( G ) / Sum( SizesConjugacyClasses( t ){ ker }, 0 );
    else
      factsize:= Size( G );
    fi;

    # Inspect the codegree.
    codegree := factsize / chi[1];

    if IsPrimePowerInt( codegree ) then

      # If the codegree is a prime power then the character is monomial
      # (Chillag, Mann, Manz).
#T also if the group is not solvable?
      Info( InfoMonomial, 1,
            "TestMonomialQuick returns with 'true'" );
      return rec( isMonomial := true,
                  comment    := "codegree is prime power" );
    fi;

    # If $\pi$ is the set of primes dividing the codegree
    # then the character is induced from a $\pi$ Hall subgroup.
#T also if the group is not solvable?
    pi   := Set( FactorsInt( codegree ) );
    hall := Product( Filtered( FactorsInt( factsize ), x -> x in pi ), 1 );

    if factsize / hall = chi[1] then

      # The character is induced from a {\em linear} character
      # of the $\pi$ Hall group.
      Info( InfoMonomial, 1,
            "TestMonomialQuick returns with 'true'" );
      return rec( isMonomial := true,
                  comment    := "degree is index of Hall subgroup" );

    elif IsMonomialNumber( hall ) then

      # The {\em order} of this Hall subgroup is monomial.
      Info( InfoMonomial, 1,
            "TestMonomialQuick returns with 'true'" );
      return rec( isMonomial := true,
                  comment    := "induced from monomial Hall subgroup" );

    fi;

    # Inspect the factor group modulo the kernel.
    if 1 < Length( ker ) then

      if   IsMonomialNumber( factsize ) then

        # The order of the kernel factor group is monomial.
        # (For faithful characters this check has been done already.)
        Info( InfoMonomial, 1,
              "TestMonomialQuick returns with 'true'" );
        return rec( isMonomial := true,
                    comment    := "size of kernel factor is monomial" );

      elif IsSubsetSet( ker, SupersolvableResiduum( t ) ) then

        # The factor group modulo the kernel is supersolvable.
        Info( InfoMonomial, 1,
              "TestMonomialQuick returns with 'true'" );
        return rec( isMonomial:= true,
                    comment:= "kernel factor group is supersolvable" );
#T Is there more one can do without computing the factor group?

      fi;

      grouptest:= TestMonomialQuick(
                       FactorGroupNormalSubgroupClasses( G, ker ) );
#T This can help ??
      if grouptest.isMonomial = true then

        Info( InfoMonomial, 1,
              "#I  TestMonomialQuick returns with 'true'" );
        return rec( isMonomial := true,
                    comment    := "kernel factor group is monomial" );

      fi;

    fi;

    # No more cheap tests are available.
    Info( InfoMonomial, 1,
          "TestMonomialQuick returns with '?'" );
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
InstallOtherMethod( TestMonomialQuick,
    "method for a group",
    true,
    [ IsGroup ], 0,
    function( G )

#T if the table is known then call TestMonomialQuick( G.charTable ) !
#T (and implement this function ...)

    local test,       # the result record
          ssr;        # supersolvable residuum of 'G'

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

      elif ForAll( Set( FactorsInt( Size( ssr ) ) ),
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
          "TestMonomialQuick returns with '", test.isMonomial, "'" );
    return test;
    end );


#############################################################################
##
#M  TestMonomial( <chi> ) . . . . . . . . . . . .  for a character with group
##
InstallMethod( TestMonomial,
    "method for a character with group",
    true,
    [ IsCharacter and IsClassFunctionWithGroup ], 0,
    function( chi )

    local G,         # group of 'chi'
          test,      # result record
          t,         # character table of 'G'
          nsg,       # list of normal subgroups of 'G'
          ker,       # kernel of 'chi'
          isqp,      # is 'chi' quasiprimitive
          i,         # loop over normal subgroups
          testhom,   # does 'chi' restrict homogeneously
          theta,     # constituent of the restriction
          found,     # monomial character found
          found2,    # monomial character found
          T,         # inertia group of 'theta'
          fus,       # fusion of conjugacy classes 'T' in 'G'
          deg,       # degree of 'theta'
          rest,      # restriction of 'chi' to 'T'
          j,         # loop over irreducibles of 'T'
          psi,       # character of 'T'
          testmon,   # test for monomiality
          orbits,    # orbits of irreducibles of 'T'
          poss;      # list of possibly nonmonomial characters

    Info( InfoMonomial, 1, "TestMonomial called" );

    # elementary test for monomiality
    test:= TestMonomialQuick( chi );

    if test.isMonomial = "?" then

      G:= UnderlyingGroup( chi );

      if not IsSolvableGroup( G ) then
        Info( InfoMonomial, 1,
              "sorry, no implementation for nonsolvable groups" );
        TryNextMethod();
      fi;

      t:= CharacterTable( G );

      # Loop over all normal subgroups of 'G' to that <chi> restricts
      # nonhomogeneously.
      # (If there are no such normal subgroups then <chi> is
      # quasiprimitive hence not monomial.)
      ker:= KernelChar( ValuesOfClassFunction( chi ) );
      nsg:= Filtered( NormalSubgroups( t ), x -> IsSubsetSet( x, ker ) );
      isqp:= true;

      i:= 1;
      found:= false;

      while not found and i <= Length( nsg ) do

        testhom:= TestHomogeneous( chi, nsg[i] );
        if not testhom.isHomogeneous then

          isqp:= false;

          # Take a constituent 'theta' in a nonhomogeneous restriction.
          theta:= testhom.character;

          # We have $<chi>_N = e \sum_{i=1}^t \theta_i$.
          # <chi> is induced from an irreducible character of
          # $'T' = I_G(\theta_1)$ that restricts to $e \theta_1$,
          # so we have proved monomiality if $e = \theta(1) = 1$.
          if testhom.multiplicity = 1 and DegreeOfCharacter( theta ) = 1 then

            found:= true;
            test:= rec( isMonomial := true,
                        comment    := "induced from \'character\'",
                        character  := theta );

          else

            # Compute the inertia group 'T'.
            T:= InertiaSubgroup( G, theta );
            if TestMonomialQuick( T ).isMonomial = true then

              # 'chi' is induced from 'T', and 'T' is monomial.
              found:= true;
              test:= rec( isMonomial := true,
                          comment    := "induced from monomial subgroup",
                          subgroup   := T );

            else

              # Check whether a character of 'T' from that <chi>
              # is induced can be proved to be monomial.

              # First get all characters 'psi' of 'T'
              # from that <chi> is induced.
              t:= Irr( T );
              fus:= FusionConjugacyClasses( T, G );
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
        # primitivity, for a nonlinear character this proves
        # nonmonomiality.
        test:= rec( isMonomial := false,
                    comment    := "quasiprimitive character" );

      elif not found then

        # We have tried all suitable normal subgroups and always got
        # back that the character of the inertia subgroup was
        # (possibly) nonmonomial.
        # So we do not know whether <chi> is monomial.
        test:= rec( isMonomial:= "?",
                    comment:= "all inertia subgroups checked, no result" );
#T call a method that handles this case1

      fi;

    fi;

    Info( InfoMonomial, 1,
          "TestMonomial returns with '", test.isMonomial, "'" );
    return test;
    end );


#############################################################################
##
#M  TestMonomial( <G> ) . . . . . . . . . . . . . . . . . . . . . for a group
##
InstallOtherMethod( TestMonomial,
    "method for a group",
    true,
    [ IsGroup ], 0,
    function( G )

    local test,      # result record
          found,     # monomial character found
          testmon,   # test for monomiality
          j,         # loop over irreducibles of 'T'
          psi,       # character of 'T'
          orbits,    # orbits of irreducibles of 'T'
          poss;      # list of possibly nonmonomial characters

    Info( InfoMonomial, 1, "TestMonomial called for a group" );

    # elementary test for monomiality
    test:= TestMonomialQuick( G );

    if test.isMonomial = "?" then

      if Size( G ) mod 2 = 0 and ForAny( Delta( G ), x -> 1 < x ) then

        # For even order groups it is checked whether
        # the list 'Delta( G )' contains an entry that is bigger
        # than one. (For monomial groups and for odd order groups
        # this is always less than one, according to Taketa\'s Theorem
        # and Berger\'s result).

        test:= rec( isMonomial := false,
                    comment    := "list Delta( G ) contains entry > 1" );

      else

        orbits:= OrbitRepresentativesCharacters( Irr( G ) );
        found:= false;
        j:= 2;
        poss:= [];
        while ( not found ) and j <= Length( orbits ) do
          psi:= orbits[j];
          testmon:= TestMonomial( psi ).isMonomial;
          if testmon = false then
            found:= true;
          elif testmon = "?" then
            Add( poss, psi );
          fi;
          j:= j+1;
        od;

        if found then

          # nonmonomial character found
          test:= rec( isMonomial := false,
                      comment    := "nonmonomial character found",
                      character  := psi );

        elif Length( poss ) = 0 then

          # all checks answered 'true'
          test:= rec( isMonomial := true,
                      comment    := "all characters checked" );

        else

          test:= rec( isMonomial := "?",
                      comment    := "(possibly) nonmon. characters found",
                      characters := poss );

        fi;

      fi;

    fi;

    # Return the result.
    Info( InfoMonomial, 1,
          "TestMonomial returns with '", test.isMonomial, "'" );
    return test;
    end );


#############################################################################
##
#M  IsMonomialGroup( <G> ) . . . . . . . . . . . . . . . . . . .  for a group
##
InstallMethod( IsMonomialGroup,
    "method for a group",
    true, [ IsGroup ], 0,
    G -> TestMonomial( G ).isMonomial );


#############################################################################
##
#M  IsMonomialCharacter( <chi> ) . . . . . . . . . for a character with group
##
InstallMethod( IsMonomialCharacter,
    "method for a character with group",
    true,
    [ IsCharacter and IsClassFunctionWithGroup ], 0,
    chi -> TestMonomial( chi ).isMonomial );


#T #############################################################################
#T ##
#T #F  TestRelativelySM( <G> )
#T #F  TestRelativelySM( <chi> )
#T #F  TestRelativelySM( <G>, <N> )
#T #F  TestRelativelySM( <chi>, <N> )
#T ##
#T ##  The algorithm for a character <chi> and a normal subgroup <N>
#T ##  proceeds as follows.
#T ##  If <N> is abelian or has nilpotent factor then <chi> is relatively SM
#T ##  with respect to <N>.
#T ##  Otherwise we check whether <chi> restricts irreducibly to <N>; in this
#T ##  case we also get a positive answer.
#T ##  Otherwise a subnormal subgroup from that <chi> is induced must be
#T ##  contained in a maximal normal subgroup of <N>.  So we get all maximal
#T ##  normal subgroups containing <N> from that <chi> can be induced, take a
#T ##  character that induces to <chi>, and check recursively whether it is
#T ##  relatively subnormally monomial with respect to <N>.
#T ##
#T ##  For a group $G$ we consider only representatives of character orbits.
#T ##
#T TestRelativelySM := function( arg )
#T 
#T     local test,      # result record
#T           G,         # argument, group
#T           chi,       # argument, character of 'G'
#T           N,         # argument, normal subgroup of 'G'
#T           n,         # classes in 'N'
#T           t,         # character table of 'G'
#T           nsg,       # list of normal subgroups of 'G'
#T           newnsg,    # filtered list of normal subgroups
#T           orbits,    # orbits on 't.irreducibles'
#T           found,     # not relatively SM character found?
#T           i,         # loop over 'nsg'
#T           j,         # loop over characters
#T           fus,       # fusion of conjugacy classes 'N' in 'G'
#T           norm,      # norm of restriction of 'chi' to 'N'
#T           isrelSM,   # is the constituent relatively SM?
#T           check,     #
#T           induced,   # is a subnormal subgroup found from where
#T                      # the actual character can be induced?
#T           k;         # loop over 'newnsg'
#T 
#T     # step 1:
#T     # Check the arguments.
#T     if     Length( arg ) < 1 or 2 < Length( arg )
#T         or not ( IsGroup( arg[1] ) or IsCharacter( arg[1] ) ) then
#T       Error( "first argument must be group or character" );
#T     elif IsBound( arg[1].testRelativelySM ) then
#T       return arg[1].testRelativelySM;
#T #T Attribute ??
#T     fi;
#T 
#T     if IsGroup( arg[1] ) then
#T       G:= arg[1];
#T       Info( InfoMonomial, 1,
#T             "TestRelativelySM called with group ", GroupString( G, "G" ) );
#T     elif IsCharacter( arg[1] ) then
#T       G:= UnderlyingGroup( arg[1] );
#T       chi:= ValuesOfClassFunction( arg[1] );
#T       Info( InfoMonomial, 1,
#T             "TestRelativelySM called with character ",
#T             CharacterString( G ) );
#T     fi;
#T 
#T     # step 2:
#T     # Get the interesting normal subgroups.
#T 
#T     # We want to consider normal subgroups and factor groups.
#T     # If this test  yields a solution we can avoid to compute
#T     # the character table of 'G'.
#T     # But if the character table of 'G' is already known we use it
#T     # and store the factor groups.
#T 
#T     if   Length( arg ) = 1 then
#T 
#T       # If a normal subgroup <N> is abelian or has nilpotent factor group
#T       # then <G> is relatively SM w.r. to <N>, so consider only the other
#T       # normal subgroups.
#T 
#T       if IsBound( G.charTable ) then
#T 
#T         nsg:= NormalSubgroups( G.charTable );
#T         newnsg:= [];
#T         for n in nsg do
#T           if not CharTableOps.IsNilpotentFactor( G.charTable, n ) then
#T             N:= NormalSubgroupClasses( G, n );
#T #T geht das?
#T #T        if IsSubset( n, centre ) and
#T             if not IsAbelian( N ) then
#T               Add( newnsg, N );
#T             fi;
#T           fi;
#T         od;
#T         nsg:= newnsg;
#T 
#T       else
#T 
#T         nsg:= NormalSubgroups( G );
#T         nsg:= Filtered( nsg, x -> not IsAbelian( x ) and
#T                                   not IsNilpotent( G / x ) );
#T 
#T       fi;
#T 
#T     elif Length( arg ) = 2 then
#T 
#T       nsg:= [];
#T 
#T       if IsList( arg[2] ) then
#T 
#T         if not CharTableOps.IsNilpotentFactor( G.charTable, arg[2] ) then
#T           N:= NormalSubgroupClasses( arg[2] );
#T           if not IsAbelian( N ) then
#T             nsg[1]:= N;
#T           fi;
#T         fi;
#T 
#T       elif IsGroup( arg[2] ) then
#T 
#T         N:= arg[2];
#T         if not IsAbelian( N ) and not IsNilpotent( G / N ) then
#T           nsg[1]:= N;
#T         fi;
#T 
#T       else
#T         Error( "second argument must be normal subgroup or classes list" );
#T       fi;
#T 
#T     fi;
#T 
#T     # step 3:
#T     # Test whether all characters are relatively SM for all interesting
#T     # normal subgroups.
#T 
#T     if IsEmpty( nsg ) then
#T 
#T       test:= rec( isRelativelySM := true,
#T                   comment        :=
#T           "normal subgroups are abelian or have nilpotent factor group" );
#T 
#T     else
#T 
#T       t:= CharacterTable( G );
#T       if IsGroup( arg[1] ) then
#T 
#T         # Compute representatives of orbits of characters.
#T         orbits:= OrbitRepresentativesCharacters( Irr( t ) );
#T         orbits:= orbits{ [ 2 .. Length( orbits ) ] };
#T 
#T       else
#T         orbits:= [ chi ];
#T       fi;
#T 
#T       # Loop over all normal subgroups in 'nsg' and all
#T       # irreducible characters in 'orbits' until a not rel. SM
#T       # character is found.
#T       found:= false;
#T       i:= 1;
#T       while ( not found ) and i <= Length( nsg ) do
#T 
#T         N:= nsg[i];
#T         j:= 1;
#T         while ( not found ) and j <= Length( orbits ) do
#T 
#T #T use the kernel or centre here!!
#T #T if N does not contain the centre of chi then we need not test?
#T #T Isn't it sufficient to consider the factor modulo
#T #T the product of 'N' and kernel of 'chi'?
#T           chi:= orbits[j];
#T 
#T           # Is the restriction of 'chi' to 'N' irreducible?
#T           # This means we can choose $H = G$.
#T           n:= ClassesOfNormalSubgroup( G, N );
#T           fus:= FusionConjugacyClasses( N, G );
#T           norm:= Sum( n, c -> SizesConjugacyClasses( CharacterTable( G ) )[c] * chi[c]
#T                                         * GaloisCyc( chi[c], -1 ), 0 );
#T   
#T           if norm = Size( N ) then
#T 
#T             test:= rec( isRelativelySM := true,
#T                         comment        := "irreducible restriction",
#T                         character      := CharacterByValues( G, chi ) );
#T 
#T           else
#T 
#T             # If there is a subnormal subgroup $H$ from where <chi> is
#T             # induced then $H$ is contained in a maximal normal subgroup
#T             # of $G$ that contains <N>.
#T 
#T             # So compute all maximal subgroups ...
#T             newnsg:= MaximalNormalSubgroups( CharTable( G ) );
#T 
#T             # ... containing <N> ...
#T             newnsg:= Filtered( newnsg, x -> IsSubsetSet( x, n ) );
#T 
#T             # ... from where <chi> possibly can be induced.
#T             newnsg:= List( newnsg,
#T                            x -> TestInducedFromNormalSubgroup(
#T                                    CharacterByValues( G, chi ),
#T                                    NormalSubgroupClasses( G, x ) ) );
#T 
#T             induced:= false;
#T             k:= 1;
#T             while not induced and k <= Length( newnsg ) do
#T 
#T               check:= newnsg[k];
#T               if check.isInduced then
#T 
#T                 # check whether the constituent is relatively SM w.r. to <N>
#T                 isrelSM:= TestRelativelySM( check.character, N );
#T                 if isrelSM.isRelativelySM then
#T                   induced:= true;
#T                 fi;
#T 
#T               fi;
#T               k:= k+1;
#T 
#T             od;
#T 
#T             if induced then
#T               test:= rec( isRelativelySM := true,
#T                           comment := "suitable character found"
#T                          );
#T               if IsBound( isrelSM.character ) then
#T                 test.character:= isrelSM.character;
#T               fi;
#T             else
#T               test:= rec( isRelativelySM := false,
#T                           comment := "all possibilities checked" );
#T             fi;
#T 
#T           fi;
#T 
#T           if not test.isRelativelySM then
#T 
#T             found:= true;
#T             test.character:= chi;
#T             test.normalSubgroup:= N;
#T 
#T           fi;
#T 
#T           j:= j+1;
#T 
#T         od;
#T 
#T         i:= i+1;
#T 
#T       od;
#T 
#T       if not found then
#T 
#T         # All characters are rel. SM w.r. to all normal subgroups.
#T         test:= rec( isRelativelySM := true,
#T                     comment        := "all possibilities checked" );
#T       fi;
#T 
#T     fi;
#T 
#T     if Length( arg ) = 1 then
#T 
#T       # The result depends only on the group resp. character,
#T       # we may store it.
#T       arg[1].testRelativelySM:= test;
#T 
#T     fi;
#T 
#T     Info( InfoMonomial, 1, "TestRelativelySM returns with '", test, "'" );
#T     return test;
#T end;
#T 
#T 
#T #############################################################################
#T ##
#T #M  IsRelativelySM( <chi> )
#T #M  IsRelativelySM( <G> )
#T ##
#T IsRelativelySM := chi_or_G -> TestRelativelySM( chi_or_G ).isRelativelySM );


#############################################################################
##
#M  IsMinimalNonmonomial( <G> ) . . . . . . . . . . . . . . . . . for a group
##
InstallMethod( IsMinimalNonmonomial,
    "method for a group",
    true,
    [ IsGroup ], 0,
    function( K )

    local F,          # Fitting subgroup
          factsize,   # index of 'F' in 'K'
          facts,      # prime factorization of the order of 'F'
          p,          # prime dividing the order of 'F'
          m,          # 'F' is of order $p ^ m $
          syl,        # Sylow subgroup
          sylgen,     # one generator of 'syl'
          gens,       # generators list
          C,          # centre of 'K' in dihedral case
          fc,         # element in $F C$
          q;          # half of 'factsize' in dihedral case

    # Compute the Fitting factor of the group.
    F:= FittingSubgroup( K );
    factsize:= Index( K, F );

    # The Fitting subgroup of a minimal nomonomial group is a $p$-group.
    facts:= FactorsInt( Size( F ) );
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


#############################################################################
##
#F  MinimalNonmonomialGroup( <p>, <factsize> )
##
InstallGlobalFunction( MinimalNonmonomialGroup, function( p, factsize )

    local K,          # free group
          Kgens,      # free generators of 'K'
          rels,       # relators of 'K'
          name,       # name of 'K'
          t,          # number with suitable multiplicative order
          form,       # matrix of the commutator form
          x,          # indeterminate
          val,        # one entry in 'form'
          i,          # loop
          j,          # loop
          v,          # coefficient vector
          rhs,        # right hand side of a relator when viewed as relation
          q,          # another name for 'factsize'
          2m,         # exponent of size of Frattini factor of group $F$
          m,          # half of '2m'
          facts,      # factors of cylotomic polynomial
          coeff,      # coefficients vector of one factor in 'facts'
          inv,        # inverse of first in 'coeff'
          f,          # 'GF(2)'
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

      K:= FreeGroup( 5 );
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

      K:= FreeGroup( 6 );
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

      # The 'q'-th cyclotomic polynomial splits over the field with
      # 'p' elements into factors of degree '2*m'.
      facts:= Factors( CyclotomicPolynomial( GF(p), q ) );

      # Take the coefficients i$a_1, a_2, \ldots, a_{2m}, 1$ of a factor.
      coeff:= IntVecFFE(
          - CoefficientsOfUnivariateLaurentPolynomial( facts[1] )[1] );

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
      K:= FreeGroup( 2m+2 );
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
      K:= FreeGroup( 2*m + s + 3 );
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
      coeff:= CoefficientsOfUnivariateLaurentPolynomial( facts[1] )[1];

      Atr:= MutableNullMat( m, m, f );
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

      # The action of $t$ is described by 'W' and its inverse.
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
      coeff:= CoefficientsOfUnivariateLaurentPolynomial( facts[1] )[1];
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
        val:= CoefficientsOfUnivariateLaurentPolynomial(
                  x^(i+m-2) mod facts[1] );
        val:= - Int( ShiftedCoeffs( val[1], val[2] )[1] );
        for j in [ i .. m ] do
          form[ m+i-j ][j]:= val;
        od;
      od;

      # Write down the presentation.
      K:= FreeGroup( 2*m + 4 );
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
    return K;
end );


#############################################################################
##
#E  ctblmono.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



