#############################################################################
##
#W  smallgen.gi            GAP 4 package `genus'                Thomas Breuer
##
#H  @(#)$Id: smallgen.gi,v 1.4 2002/05/24 15:06:47 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.( "pkg/genus/smallgen_gi" ) :=
    "@(#)$Id: smallgen.gi,v 1.4 2002/05/24 15:06:47 gap Exp $";


#############################################################################
##
#F  WeakTestGeneration( <C>, <g>, <G> )
##
InstallGlobalFunction( WeakTestGeneration, function( C, g, G )

    local tbl, card, orbs, orders, nccl, i, d;

    tbl:= CharacterTable( G );
    card:= CardinalityOfHom( C, g, tbl );

    if   CardinalityOfHom( C, g, tbl )
           < Size( tbl ) / Length( ClassPositionsOfCentre( tbl ) ) then

      # $|\Epi_{<C>}(<g>,<G>)|$ is a multiple of $|<G>|/|Z(<G>)|$,
      # and we compute $|\Hom_{<C>}(<g>,<G>)|$.
      Info( InfoSignature, 3,
            "WeakTestGeneration: |Hom| too small" );
      return false;

    elif g = 0 and NongenerationByScottCriterion( tbl, C ) then

      # Scott's criterion of nongeneration is used if $<g> = 0$.
      Info( InfoSignature, 3,
            "WeakTestGeneration: Scott yields nongen." );
      return false;

    elif g = 0 and IsAbelian( G ) then

      # Scott's criterion also covers the criterion whether all
      # classes of <C> except one are contained in a proper normal subgroup.
      # This *decides* the question of generation for the case that <G> is
      # abelian and $\Hom_{<C>}(<g>,<G>)$ is nonempty.)
      Info( InfoSignature, 3,
            "WeakTestGeneration: Scott for abelian gp. yields generation" );
      return true;

    fi;

    # If <C> covers all maximal cyclic subgroups of <G> then we have
    # $\Epi_{<C>}( <g>, <G> ) = \Hom_{<C>}( <g>, <G> )$.
    orbs:= [ 1 ];
    orders:= OrdersClassRepresentatives( tbl );
    nccl:= Length( orders );
    for i in C do
      for d in DivisorsInt( orders[i] ) do
        UniteSet( orbs, ClassOrbit( tbl, PowerMap( tbl, d, i ) ) );
      od;
    od;
    if Length( orbs ) = nccl then
      Info( InfoSignature, 3,
            "WeakTestGeneration: classes cover max. cycl. subgps" );
      return true;
    fi;

#T use also char. theoretic criteria!
#T    if IsNecessarilyGeneratingTuple( tbl, C, G.permchars, G.maxes ) then
#T      InfoSignature3( "#I WeakTestGeneration: yes (perm. chars.)\n" );
#T      return true;
#T    fi;

    # No more weak criterion yields nongeneration.
    return fail;
end );


#############################################################################
##
#F  HardTestGeneration( <C>, <g>, <G>[, <single>] )
##
InstallGlobalFunction( HardTestGeneration, function( arg )
    local C, g, G, single,
          r,
          n,
          id,
          sigma,
          rep_cen,
          iter_cen,
          R,
          i, j,
          max,
          choice,
          tuple,
          NextElementTuple,
          tup,
          prod,
          hypgens,
          elms,
          counter,
          commprod,
          result;

    # Get and check the arguments.
    if   Length( arg ) = 3 then
      C:= arg[1];
      g:= arg[2];
      G:= arg[3];
      single:= false;
    elif Length( arg ) = 4 and IsBool( arg[4] ) then
      C:= arg[1];
      g:= arg[2];
      G:= arg[3];
      single:= arg[4];
      if g > 0 then
        Error( "HardTestGeneration: representatives not yet implemented for g > 0!!\n" );
      fi;
    else
      Error( "usage: HardTestGeneration( <C>, <g>, <G>, <single> )" );
    fi;

    r  := Length( C );
    n  := Size( G );
    id := One( G );
    result:= [];

    # Loop over orbits under `G'-conjugation.
    sigma:= List( ConjugacyClasses( G ){ C }, Representative );
    rep_cen:= List( sigma, g -> Centralizer( G, g ) );
    if 0 < r then
      iter_cen:= [ rep_cen[1] ];
      R:= [ [ id ] ];
    else
      iter_cen:= [];
      R:= [];
    fi;
    for i in [ 2 .. r-1 ] do
      R[i]:= List( DoubleCosets( G, rep_cen[i], iter_cen[i-1] ),
                   Representative );
      iter_cen[i]:= Centralizer( iter_cen[i-1], sigma[i]^R[i][1] );
    od;
    if 1 < r then
      R[r]:= List( DoubleCosets( G, rep_cen[r], iter_cen[r-1] ),
                   Representative );
    fi;
    max:= List( R, Length );
    choice:= List( [ 1 .. r ], i -> 1 );
    tuple:= List( [ 1 .. r ], i -> sigma[i]^R[i][1] );

    # Provide a function that returns
    # either the next element tuple or `fail'.
    NextElementTuple:= function()
        local pos, i, j;

        # Go to the last position that can be increased.
        pos:= r;
        while 1 < pos and choice[ pos ] = max[ pos ] do
          pos:= pos - 1;
        od;
        if pos <= 1 then
          return fail;
        fi;

        # Adjust the data of the counter.
        choice[ pos ]:= choice[ pos ] + 1;
        tuple[ pos ]:= sigma[ pos ]^R[ pos ][ choice[ pos ] ];

        if pos < r then

          iter_cen[ pos ]:= Centralizer( iter_cen[ pos-1 ],
                                sigma[ pos ]^R[ pos ][ choice[ pos ] ] );
          pos:= pos + 1;
          while pos <= r do
            R[ pos ]:= List( DoubleCosets( G, rep_cen[ pos ],
                                           iter_cen[ pos-1 ] ),
                             Representative );
            tuple[ pos ]:= sigma[ pos ]^R[ pos ][1];
            choice[ pos ]:= 1;
            max[ pos ]:= Length( R[ pos ] );
            iter_cen[ pos ]:= Centralizer( iter_cen[ pos-1 ],
                                  sigma[ pos ]^R[ pos ][1] );
            pos:= pos + 1;
          od;

        fi;

        # Return the next tuple.
        return tuple;
    end;

    # Loop over the element tuples.
    tup:= tuple;
    while tup <> fail do

      # Form the product.
      prod:= id;
      for i in [ 1 .. r ] do
        prod:= prod * tup[i];
      od;

      # Check for homomorphism and surjectivity.
      if g = 0 then

        if prod = id and Size( Subgroup( G, tup ) ) = n then

          Info( InfoSignature, 3,
                "HardTestGeneration: successful!" );
          hypgens:= List( [ 1 .. 2*g ], x -> id );
          Add( result, Concatenation( hypgens, tup ) );
          if single then
            return result;
          fi;

        fi;

      else

        if   prod = id and Length( GeneratorsOfGroup( G ) ) <= g then

          Info( InfoSignature, 3,
                "HardTestGeneration: successful!" );
          hypgens:= Concatenation( List( GeneratorsOfGroup( G ),
                                         gen -> [ gen, id ] ) );
          Append( hypgens, List( [ Length( hypgens ) + 1 .. 2*g ],
                                 x -> id ) );
          Add( result, Concatenation( hypgens, tup ) );
          if single then
            return result;
          fi;

        elif prod = id and IsAbelian( G ) and Length( GeneratorsOfGroup( G ) ) <= 2*g then

          Info( InfoSignature, 3,
                "HardTestGeneration: successful!" );
          hypgens:= ShallowCopy( GeneratorsOfGroup( G ) );
          Append( hypgens, List( [ Length( hypgens ) + 1 .. 2*g ],
                                 x -> id ) );
          Add( result, Concatenation( hypgens, tup ) );
          if single then
            return result;
          fi;

        else

          # Very hard case:
          # Check generation together with `g' commutators.
          elms:= Elements( G );
          counter:= List( [ 1 .. 2*g ], x -> 1 );
          counter[1]:= 0;
          repeat
            i:= 1;
            while i <= 2*g and counter[i] = n do
              counter[i]:= 1;
              i:= i+1;
            od;
            if i <= 2*g then

              counter[i]:= counter[i] + 1;
              commprod:= id;
              for j in [ 1 .. g ] do
                commprod:= commprod * Comm( elms[ counter[ 2*j-1 ] ], elms[ counter[ 2*j ] ] );
              od;
              if     commprod * prod = id
                 and Size( Subgroup( G, Concatenation( tup, elms{ counter } ) ) ) = n then

                Info( InfoSignature, 3,
                      "HardTestGeneration: successful! (very hard)" );
                hypgens:= elms{ counter };
                Add( result, Concatenation( hypgens, tup ) );
                if single then
                  return result;
                fi;

              fi;

            fi;
          until i > 2*g;

        fi;

      fi;

      tup:= NextElementTuple();

    od;

    return result;
end );


#############################################################################
##
#F  RepresentativesEpimorphisms( <signature>, <G>[, <arec>] )
##
##  First the conjugacy classes of <G> are computed.
##  Then all possible class structures $C = ( C_1, C_2, \ldots, C_r )$
##  are checked for a surface kernel epimorphism with image of $c_i$ in
##  class $C_i$.
##
##  We restrict the search to the class structures where the elements of
##  class $C_i$ have order $m_i$,
##  and for $m_i = m_{i+1}$, we consider only the case that $C_i$ comes
##  not after $C_{i+1}$ in the fixed ordering of classes.
##
InstallGlobalFunction( RepresentativesEpimorphisms, function( arg )
    local signature,    # first argument
          G,            # second argument
          arec,
          single,       # component of the optional argument
          action,       # component of the optional argument
          noreps,       # component of the optional argument
          g0,
          r,
          m,
          ccl,
          nccl,
          orders,
          images,
          i,             # loop variable
          new,
          orb,
          epi,
          max,
          counter,
          NextClassStructure,
          C,
          weak,
          test;

    # Get and check the arguments.
    single:= false;
    action:= fail;
    if   Length( arg ) = 2 and IsCompactSignature( arg[1] )
                           and IsGroup( arg[2] ) then
      signature:= arg[1];
      G:= arg[2];
      arec:= rec();
    elif Length( arg ) = 3 and IsCompactSignature( arg[1] )
                           and IsGroup( arg[2] )
                           and IsRecord( arg[3] ) then
      signature:= arg[1];
      G:= arg[2];
      arec:= arg[3];
    else
      Error("usage: RepresentativesEpimorphisms(<signature>,<G>[,<arec>])");
    fi;
    single:= IsBound( arec.single ) and arec.single = true;
    if IsBound( arec.action ) and IsPermGroup( arec.action ) then
      action:= arec.action;
    else
      action:= fail;
    fi;
    noreps:= IsBound( arec.noreps ) and arec.noreps = true;

    g0 := GenusOfSignature( signature );
    m  := PeriodsOfSignature( signature );
    r  := Length( m );
#T discard abelian `G' if `r = 1' !!
#T more general: check whether the signature is admissible for `G'
#T (compatibility of abelian invariants not only for each class
#T structure but for the signature itself!!)

    # Compute the conjugacy classes and element orders.
    ccl:= ConjugacyClasses( G );
    nccl:= Length( ccl );
    orders:= List( ccl, x -> Order( Representative( x ) ) );

    # Determine the positions of image classes for each elliptic generator.
    images:= List( [ 1 .. r ],
                   i -> Filtered( [ 1 .. nccl ],
                                  j -> orders[j] = m[i] ) );

    # If there is no image possible for some elliptic generators,
    # no epimorphism is possible.
    if ForAny( images, x -> Length( x ) = 0 ) then
      Info( InfoSignature, 2,
            "RepresentativesEpimorphisms: incompatible element orders" );
      return [];
    fi;

    # Exclude classes that do not belong to class structures that are
    # the first in their orbit under `action'.
    if action <> fail then
      i:= 1;
      while i <= r and Size( action ) <> 1 do
        new:= [];
        while Length( images[i] ) <> 0 do
          Add( new, images[i][1] );
          orb:= Orbit( action, images[i][1], OnPoints );
          action:= Stabilizer( action, images[i][1] );
          SubtractSet( images[i], orb );
        od;
        images[i]:= new;
        i:= i+1;
      od;
    fi;

    # Initialize the result.
    epi:= [];

    # Install a counter for the local function that follows.
    max:= List( images, Length );
    counter:= List( images, x -> 1 );
    if 0 < r then
      counter[r]:= 0;
    fi;

    # Provide a function that returns
    # either the next possible class structure or `fail'.
    if r = 0 then

      NextClassStructure:= function()
          if counter <> fail then
            counter:= fail;
            return [];
          else
            return fail;
          fi;
      end;

    else

      NextClassStructure:= function()
          local i, j;

          for i in [ r, r-1 .. 1 ] do
            if counter[i] = max[i] then

              # Reset position `i'.
              counter[i]:= 1;

            else

              # Increase the counter at position `i'.
              counter[i]:= counter[i] + 1;

              # Increase higher positions if necessary.
              j:= i;
              while j < r and m[j] = m[j+1] do
                if counter[j+1] < counter[j] then
                  counter[j+1]:= counter[j];
                fi;
                j:= j+1;
              od;

              # Return the next class structure.
              return List( [ 1 .. r ], i -> images[i][ counter[i] ] );

            fi;
          od;
          return fail;
      end;

    fi;

    # Loop over the possible class structures.
    C:= NextClassStructure();
    while C <> fail do

      # Test the tuples for epimorphisms.
      weak:= WeakTestGeneration( C, g0, G );
      if weak <> false then
        if noreps and ( weak = true ) then
          Add( epi, rec( signature := signature,
                         group     := G,
                         classes   := C ) );
          if single then
            return epi;
          fi;
        else
          test:= HardTestGeneration( C, g0, G, single );
          if test <> fail then
            Append( epi, List( test, imgs -> rec( signature := signature,
                           group     := G,
                           classes   := C,
                           images    := imgs ) ) );
            if single then
              return epi;
            fi;
          fi;
        fi;
      fi;

      C:= NextClassStructure();

    od;

    # Return the result.
    Info( InfoSignature, 1,
          "RepresentativesEpimorphisms returns ", epi );
    return epi;
end );


#############################################################################
##
#F  AdmissibleGroups( <g>, <n>, <sign> )
##
InstallGlobalFunction( AdmissibleGroups, function( g, n, sign )

    local periods,
          grps;      # list of groups, result

    periods:= sign{ [ 2 .. Length( sign ) ] };

    # If one of the periods is `n' then the group is necessarily cyclic.
    if n in periods then
      return [ CyclicGroup( n ) ];
    fi;

    # The signature $[ 0, 2, 2(g+1), 2(g+1) ]$ allows for even $g$
    # only the group $2 \times 2(g+1)$.
    if sign = [ 0, 2, 2*(g+1), 2*(g+1) ] then
      return [ AbelianGroup( [ 2, 2*(g+1) ] ) ];
    fi;

    # From now on, we use the groups in the library.
    Info( InfoSignature, 3,
          "use group library" );

    if   n > 4*g+4 then
      grps:= AllGroups( Size, n, IsAbelian, false );
    elif n > 4*g+2 then
      grps:= AllGroups( Size, n, IsCyclic, false );
    else
      grps:= AllGroups( Size, n );
    fi;

    # The elementary divisors of $\Gamma$ and $G$ must be compatible.
    grps:= Filtered( grps, G -> IsCompatibleAbelianInvariants(
                        AbelianInvariants( sign ),
                        AbelianInvariants( CommutatorFactorGroup( G ) ) ) );

    # Return the groups.
    return grps;
end );


#############################################################################
##
#F  EichlerCharactersInfo( <g> )
##
##  is a list of pairs $[ G, \chi ]$ where $\chi$ is a character of the group
##  $G$ that comes from a Riemann surface of genus <g>.
##  (We must have $<g> \geq 2$.)
##
##  The pairs are ordered w.r.t. descending orbit genus $g_0$,
##  ascending group order $n$,
##
InstallGlobalFunction( EichlerCharactersInfo, function( g )

    local info,    # result list
          g0,      # loop over the orbit genus of the signatures
          n,       # loop over the group orders
          sign,    # loop over the signatures
          G,       # loop over the groups
          ccl;     # conjugacy classes of `G'

    # Initialize the result list.
    info:= [];

    # Loop over $0 \leq g_0 \leq g-1, in reversed order.
    for g0 in [ g-1, g-2 .. 0 ] do

      Info( InfoSignature, 1,
            "EichlerCharactersInfo: g = ", g, ", g0 = ", g0 );

      # Loop over the possible orders $n$ of automorphism groups,
      # i.e., $2 \leq n \leq 84 (g-1)$.
      for n in [ 2 .. 84*(g-1) ] do

        Info( InfoSignature, 1,
              "EichlerCharactersInfo: n = ", n );

        # For each such $n$, loop over all signatures
        # $(g_0; m_1, m_2, \ldots, m_r)$ such that
        # $g-1 = n (g_0-1)
        #     + \frac{n}{2} \sum_{i=1}^r \left( 1 - \frac{1}{m_i} \right)$,
        # $0 \leq g_0 < g$,
        # and all $m_i$ divide $n$.
        for sign in AdmissibleSignatures( g, g0, n ) do

          Info( InfoSignature, 1,
                "EichlerCharactersInfo: signature = ", sign );

          # For each order $n$ and each signature,
          # loop over all groups $G$ of order $n$, up to isomorphism.
          for G in AdmissibleGroups( g, n, sign ) do

            Info( InfoSignature, 1,
                  "EichlerCharactersInfo: G = ", G );

            # For each signature and each group $G$,
            # loop over all class structures $C = (C_1, C_2, \ldots, C_r)$
            # of $G$ where $C_i$ consists of elements of order $m_i$.
            # We need to consider only ordered tuples.

            Append( info, RepresentativesEpimorphisms( sign, G ) );
#T use action of Out(G)

          od;

        od;

      od;

    od;

    # Return the result list.
    return info;
end );


#############################################################################
##
#E

