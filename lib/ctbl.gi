#############################################################################
##
#W  ctbl.gi                     GAP library                     Thomas Breuer
#W                                                           & Goetz Pfeiffer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the implementations corresponding to the declarations
##  in `ctbl.gd'.
##
##  1. Some Remarks about Character Theory in GAP
##  2. Character Table Categories
##  3. The Interface between Character Tables and Groups
##  4. Operators for Character Tables
##  5. Attributes and Properties for Groups as well as for Character Tables
##  6. Attributes and Properties only for Character Tables
##  x. Operations Concerning Blocks
##  7. Other Operations for Character Tables
##  8. Creating Character Tables
##  9. Printing Character Tables
##  10. Constructing Character Tables from Others
##  11. Sorted Character Tables
##  12. Storing Normal Subgroup Information
##  13. Auxiliary Stuff
##
Revision.ctbl_gi :=
    "@(#)$Id$";


#############################################################################
##
##  1. Some Remarks about Character Theory in GAP
##


#############################################################################
##
##  2. Character Table Categories
##


#############################################################################
##
##  3. The Interface between Character Tables and Groups
##


#############################################################################
##
#F  ConnectGroupAndCharacterTable( <G>, <tbl>[, <arec>] )
#F  ConnectGroupAndCharacterTable( <G>, <tbl>, <bijection> )
##
InstallGlobalFunction( ConnectGroupAndCharacterTable, function( arg )

    local G, tbl, arec, ccl, compat;

    # Get and check the arguments.
    if   Length( arg ) = 2 and IsGroup( arg[1] )
                           and IsOrdinaryTable( arg[2] ) then
      arec:= rec();
    elif Length( arg ) = 3 and IsGroup( arg[1] )
                           and IsOrdinaryTable( arg[2] )
                           and ( IsRecord( arg[3] ) or IsList(arg[3]) ) then
      arec:= arg[3];
    else
      Error( "usage: ConnectGroupAndCharacterTable(<G>,<tbl>[,<arec>])" );
    fi;

    G   := arg[1];
    tbl := arg[2];

    if HasUnderlyingGroup( tbl ) then
      Error( "<tbl> has already underlying group" );
    elif HasOrdinaryCharacterTable( G ) then
      Error( "<G> has already a character table" );
    fi;

    ccl:= ConjugacyClasses( G );
#T How to exploit the known character table
#T if the conjugacy classes of <G> are not yet computed?

    if IsList( arec ) then
      compat:= arec;
    else
      compat:= CompatibleConjugacyClasses( G, ccl, tbl, arec );
    fi;

    if IsList( compat ) then

      # Permute the classes if necessary.
      if compat <> [ 1 .. Length( compat ) ] then
        ccl:= ccl{ compat };
      fi;

      # The identification is unique, store attribute values.
      SetUnderlyingGroup( tbl, G );
      SetOrdinaryCharacterTable( G, tbl );
      SetConjugacyClasses( tbl, ccl );
      SetIdentificationOfConjugacyClasses( tbl, compat );

      return true;

    else
      return false;
    fi;

    end );


#############################################################################
##
#M  CompatibleConjugacyClasses( <G>, <ccl>, <tbl>[, <arec>] )
##
InstallMethod( CompatibleConjugacyClasses,
    "three argument version, call `CompatibleConjugacyClassesDefault'",
    [ IsGroup, IsList, IsOrdinaryTable ],
    function( G, ccl, tbl )
    return CompatibleConjugacyClassesDefault( G, ccl, tbl, rec() );
    end );

InstallMethod( CompatibleConjugacyClasses,
    "four argument version, call `CompatibleConjugacyClassesDefault'",
    [ IsGroup, IsList, IsOrdinaryTable, IsRecord ],
    CompatibleConjugacyClassesDefault );


#############################################################################
##
#M  CompatibleConjugacyClasses( <tbl>[, <arec>] )
##
InstallMethod( CompatibleConjugacyClasses,
    "one argument version, call `CompatibleConjugacyClassesDefault'",
    [ IsOrdinaryTable ],
    function( tbl )
    return CompatibleConjugacyClassesDefault( false, false, tbl, rec() );
    end );

InstallMethod( CompatibleConjugacyClasses,
    "two argument version, call `CompatibleConjugacyClassesDefault'",
    [ IsOrdinaryTable, IsRecord ],
    function( tbl, arec )
    return CompatibleConjugacyClassesDefault( false, false, tbl, arec );
    end );


#############################################################################
##
#F  CompatibleConjugacyClassesDefault( <G>, <ccl>, <tbl>, <arec> )
#F  CompatibleConjugacyClassesDefault( false, false, <tbl>, <arec> )
##
InstallGlobalFunction( CompatibleConjugacyClassesDefault,
    function( G, ccl, tbl, arec )

    local natchar,     # natural character (if known)
          nccl,        # no. of conjugacy classes of `G'
          pi1,         # the partition of positions in `tbl'
          pi2,         # the partition of positions in `ccl'
          bijection,   # partial bijection currently known
          refine,      # function that does the refinement
          tbl_orders,  # element orders of classes in `tbl'
          reps,        # representatives of the classes in `ccl'
          fun1, fun2,  # functions returning invariants
          tbl_classes, # class lengths in `tbl'
          degree,      # degree of the natural character
          derpos,      # positions of classes in the derived subgroup
          primes,      # primedivisors of the group order
          powerclass,
          powerclasses,
          result,      # return value
          usesymm,     # local function to use table automorphisms
          usepowers,   # local function to use power maps
          usegalois,   # local function to use Galois conjugation
          sums,        # list of lengths of entries in `equpos'
          i,
          j,
          symm,        # group of symmetries that is still available
          ords,
          p;

    if IsBound( arec.natchar ) then
      natchar:= arec.natchar;
    fi;

    nccl:= NrConjugacyClasses( tbl );

    if ccl <> false and Length( ccl ) <> nccl then
      return fail;
    fi;

    # We set up two partitions `pi1' of the column positions in `tbl'
    # and `pi2' of the positions in `ccl'
    # such that the $i$-th entries correspond to each other.
    # These partitions are successively refined
    # until either the bijection is found or no more criteria are available.
    # Uniquely identified classes are removed from `pi1' and `pi2',
    # and inserted in `bijection'.
    if IsBound( arec.bijection ) then
      bijection:= ShallowCopy( arec.bijection );
      pi1:= [ Filtered( [ 1 .. nccl ], i -> not IsBound( bijection[i] ) ) ];
      pi2:= [ Difference( [ 1 .. nccl ], bijection ) ];
    else
      bijection:= [];
      pi1:= [ [ 1 .. nccl ] ];
      pi2:= [ [ 1 .. nccl ] ];
    fi;

    # the function that does the refinement,
    # the return value `false' means that the bijection is still ambiguous,
    # `true' means that either the bijection is unique or an inconsistency
    # was detected (in the former case, `result' holds the bijection,
    # in the latter case, `result' is `fail')
    refine:= function( fun1, fun2, range )

      local newpi1, newpi2,
            i, j,
            val1, val2,
            set,
            new1, new2;

      if G = false then
        fun2:= fun1;
      fi;

      for i in range do
        newpi1:= [];
        newpi2:= [];
        val1:= List( pi1[i], fun1 );
        set:= Set( val1 );
        if Length( set ) = 1 then
          new1:= [ pi1[i] ];
          new2:= [ pi2[i] ];
        else
          val2:= List( pi2[i], fun2 );
          if set <> Set( val2 ) then
            Info( InfoCharacterTable, 2,
                  "<G> and <tbl> do not fit together" );
            result:= fail;
            return true;
          fi;
          new1:= List( set, x -> [] );
          new2:= List( set, x -> [] );
          for j in [ 1 .. Length( val1 ) ] do
            Add( new1[ Position( set, val1[j] ) ], pi1[i][j] );
            Add( new2[ Position( set, val2[j] ) ], pi2[i][j] );
          od;
        fi;
        for j in [ 1 .. Length( set ) ] do
          if Length( new1[j] ) <> Length( new2[j] ) then
            Info( InfoCharacterTable, 2,
                  "<G> and <tbl> do not fit together" );
            result:= fail;
            return true;
          fi;
          if Length( new1[j] ) = 1 then
            bijection[ new1[j][1] ]:= new2[j][1];
          else
            Add( newpi1, new1[j] );
            Add( newpi2, new2[j] );
          fi;
        od;
        Append( pi1, newpi1 );
        Append( pi2, newpi2 );
        Unbind( pi1[i] );
        Unbind( pi2[i] );
      od;

      pi1:= Compacted( pi1 );
      pi2:= Compacted( pi2 );

      if IsEmpty( pi1 ) then
        Info( InfoCharacterTable, 2, "unique identification" );
        if G = false then
          result:= [];
        else
          result:= bijection;
        fi;
        return true;
      else
        return false;
      fi;
    end;

    # Use element orders.
    Info( InfoCharacterTable, 2,
          "using element orders to identify classes" );
    tbl_orders:= OrdersClassRepresentatives( tbl );
    if G <> false then
      reps:= List( ccl, Representative );
    fi;
    fun1:= ( i -> tbl_orders[i] );
    fun2:= ( i -> Order( reps[i] ) );
    if refine( fun1, fun2, [ 1 .. Length( pi1 ) ] ) then
      return result;
    fi;

    # Use class lengths.
    Info( InfoCharacterTable, 2,
          "using class lengths to identify classes" );
    tbl_classes:= SizesConjugacyClasses( tbl );
    fun1:= ( i -> tbl_classes[i] );
    fun2:= ( i -> Size( ccl[i] ) );
    if refine( fun1, fun2, [ 1 .. Length( pi1 ) ] ) then
      return result;
    fi;

    # Distinguish classes in the derived subgroup from others.
    derpos:= ClassPositionsOfDerivedSubgroup( tbl );
    if Length( derpos ) <> nccl then

      Info( InfoCharacterTable, 2,
            "using derived subgroup to identify classes" );
      fun1:= ( i -> i in derpos );
      fun2:= ( i -> reps[i] in DerivedSubgroup( G ) );
      if refine( fun1, fun2, [ 1 .. Length( pi1 ) ] ) then
        return result;
      fi;

    fi;

    # Use the natural character if it is prescribed.
    if IsBound( natchar ) then

      Info( InfoCharacterTable, 2,
            "using natural character to identify classes" );
      degree:= natchar[1];
      fun1:= ( i -> natchar[i] );
      if   IsPermGroup( G ) then
        fun2:= ( i -> degree - NrMovedPoints( reps[i] ) );
      elif IsMatrixGroup( G ) then
        fun2:= ( i -> TraceMat( reps[i] ) );
      elif G <> false then
        Info( InfoCharacterTable, 2,
              "<G> is no perm. or matrix group, ignore natural character" );
        fun1:= ReturnTrue;
        fun2:= ReturnTrue;
      fi;
      if refine( fun1, fun2, [ 1 .. Length( pi1 ) ] ) then
        return result;
      fi;

    fi;

    # Use power maps.
    primes:= Set( Factors( Size( tbl ) ) );

    # store power maps of the group, in order to identify the class
    # of the power only once.
    powerclasses:= [];
    powerclass:= function( i, p, choice )
      if not IsBound( powerclasses[p] ) then
        powerclasses[p]:= [];
      fi;
      if not IsBound( powerclasses[p][i] ) then
        powerclasses[p][i]:= First( choice, j -> reps[i]^p in ccl[j] );
      fi;
      return powerclasses[p][i];
    end;

    usepowers:= function( p )

      local pmap, i, img1, pos, j, img2, choice, no, copypi1, k, fun1, fun2;

      Info( InfoCharacterTable, 2, " (p = ", p, ")" );

      pmap:= PowerMap( tbl, p );

      # First consider classes whose image under the bijection is known
      # but for whose `p'-th power the image is not yet known.
      for i in [ 1 .. Length( bijection ) ] do
        img1:= pmap[i];
        if IsBound( bijection[i] ) and not IsBound( bijection[ img1 ] ) then
          pos:= 0;
          for j in [ 1 .. Length( pi1 ) ] do
            if img1 in pi1[j] then
              pos:= j;
              break;
            fi;
          od;
          if G = false then
            img2:= img1;
          else
            img2:= powerclass( bijection[i], p, pi2[ pos ] );
            if img2 = fail then
              result:= fail;
              return true;
            fi;
          fi;
          bijection[ img1 ]:= img2;
          RemoveSet( pi1[ pos ], img1 );
          RemoveSet( pi2[ pos ], img2 );
          if Length( pi1[ pos ] ) = 1 then
            bijection[ pi1[ pos ][1] ]:= pi2[ pos ][1];
            Unbind( pi1[ pos ] );
            Unbind( pi2[ pos ] );
            if IsEmpty( pi1 ) then
              Info( InfoCharacterTable, 2, "unique identification" );
              if G = false then
                result:= [];
              else
                result:= bijection;
              fi;
              return true;
            fi;
            pi1:= Compacted( pi1 );
            pi2:= Compacted( pi2 );
          fi;
        fi;
      od;

      # Next consider each set of nonidentified classes
      # together with its `p'-th powers.
      copypi1:= ShallowCopy( pi1 );
      for i in [ 1 .. Length( copypi1 ) ] do

        choice:= [];
        no:= 0;
        for j in Set( pmap{ copypi1[i] } ) do
          if IsBound( bijection[j] ) then
            AddSet( choice, bijection[j] );
            no:= no + 1;
          else
            pos:= 0;
            for k in [ 1 .. Length( pi1 ) ] do
              if j in pi1[k] then
                pos:= k;
                break;
              fi;
            od;
            if not IsSubset( choice, pi2[ pos ] ) then
              no:= no + 1;
              UniteSet( choice, pi2[ pos ] );
            fi;
          fi;
        od;

        if 1 < no then

          fun1:= function( j )
            local img;
            img:= pmap[j];
            if IsBound( bijection[ img ] ) then
              return AdditiveInverse( bijection[ img ] );
            else
              return First( [ 1 .. Length( pi1 ) ], k -> img in pi1[k] );
            fi;
          end;

          fun2:= function( j )
            local img;
            img:= powerclass( j, p, choice );
            if img in bijection then
              return AdditiveInverse( img );
            else
              return First( [ 1 .. Length( pi2 ) ], k -> img in pi2[k] );
            fi;
          end;

          if refine( fun1, fun2, [ Position( pi1, copypi1[i] ) ] ) then
            return true;
          fi;

        fi;

      od;

      return false;
    end;

    # Use symmetries of the table.
    # (There may be asymmetries because of the prescribed character,
    # so we start with the partition stabilizer of `pi1'.)
    symm:= AutomorphismsOfTable( tbl );
    if IsBound( natchar ) then
      for i in pi1 do
        symm:= Stabilizer( symm, i, OnSets );
      od;
    fi;

    # Sort `pi1' and `pi2' according to decreasing element order.
    # (catch automorphisms for long orbits, hope for powers
    # if ambiguities remain)
    ords:= List( pi1, x -> - tbl_orders[ x[1] ] );
    ords:= Sortex( ords );
    pi1:= Permuted( pi1, ords );
    pi2:= Permuted( pi2, ords );

    # If all points in a part of `pi1' are in the same orbit
    # under table automorphism,
    # we may separate one point from the others.
    usesymm:= function()
      local i, tuple;
      for i in [ 1 .. Length( pi1 ) ] do
        if not IsTrivial( symm ) then
          tuple:= pi1[i];
          if     1 < Length( tuple )
             and tuple = Set( Orbit( symm, tuple[1], OnPoints ) ) then

            Info( InfoCharacterTable, 2,
                  "found useful table automorphism" );
            symm:= Stabilizer( symm, tuple[1] );
            bijection[ tuple[1] ]:= pi2[i][1];
            RemoveSet( pi1[i], pi1[i][1] );
            RemoveSet( pi2[i], pi2[i][1] );
            if Length( pi1[i] ) = 1 then
              bijection[ pi1[i][1] ]:= pi2[i][1];
              Unbind( pi1[i] );
              Unbind( pi2[i] );
            fi;

          fi;
        fi;
      od;
      if IsEmpty( pi1 ) then
        Info( InfoCharacterTable, 2, "unique identification" );
        if G = false then
          result:= [];
        else
          result:= bijection;
        fi;
        return true;
      fi;
      pi1:= Compacted( pi1 );
      pi2:= Compacted( pi2 );

      return false;
    end;

    # Use Galois conjugacy of classes.
    usegalois:= function()

      local galoisfams, copypi1, i, list, fam, id, im, res, pos, fun1, fun2;

      galoisfams:= GaloisMat( TransposedMat( Irr( tbl ) ) ).galoisfams;
      galoisfams:= List( Filtered( galoisfams, IsList ), x -> x[1] );

      copypi1:= ShallowCopy( pi1 );

      for i in [ 1 .. Length( copypi1 ) ] do

        list:= copypi1[i];
        fam:= First( galoisfams, x -> IsSubset( x, list ) );
        if fam <> fail then
          id:= First( fam, j -> IsBound( bijection[j] ) );
          if id <> fail then

            Info( InfoCharacterTable, 2,
                  "found useful Galois automorphism" );
            im:= bijection[ id ];
            res:= PrimeResidues( tbl_orders[ id ] );
            RemoveSet( res, 1 );
            pos:= Position( pi1, copypi1[i] );
            fun1:= ( j -> First( res, k -> PowerMap( tbl, k, id ) = j ) );
            fun2:= ( j -> First( res,
                             k -> powerclass( im, k, pi2[ pos ] ) = j ) );
            if refine( fun1, fun2, [ pos ] ) then
              return true;
            fi;

          fi;
        fi;

      od;

      return false;
    end;

    repeat

      sums:= List( pi1, Length );

      Info( InfoCharacterTable, 2,
            "trying power maps to identify classes" );
      for p in primes do
        if usepowers( p ) then
          return result;
        fi;
      od;

      if usesymm() then
        return result;
      fi;

      if usegalois() then
        return result;
      fi;

    until sums = List( pi1, Length );

    # no identification yet ...
    Info( InfoCharacterTable, 2,
          "not identified classes: ", pi1 );
    if G = false then
      return pi1;
    else
      return fail;
    fi;
end );


#############################################################################
##
##  4. Operators for Character Tables
##


#############################################################################
##
#M  \mod( <ordtbl>, <p> ) . . . . . . . . . . . . . . . . . <p>-modular table
##
InstallMethod( \mod,
    "for ord. char. table, and pos. integer (call `BrauerTable')",
    [ IsOrdinaryTable, IsPosInt ],
    BrauerTable );


#############################################################################
##
#M  \*( <tbl1>, <tbl2> )  . . . . . . . . . . . . .  direct product of tables
##
InstallOtherMethod( \*,
    "for two nearly character tables (call `CharacterTableDirectProduct')",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ],
    CharacterTableDirectProduct );


#############################################################################
##
#M  \/( <tbl>, <list> )  . . . . . . . . .  character table of a factor group
##
InstallOtherMethod( \/,
    "for char. table, and positions list (call `CharacterTableFactorGroup')",
    [ IsNearlyCharacterTable, IsList and IsCyclotomicCollection ],
    CharacterTableFactorGroup );


#############################################################################
##
##  5. Attributes and Properties for Groups as well as for Character Tables
##


#############################################################################
##
#M  CharacterDegrees( <G> ) . . . . . . . . . . . . . . . . . . . for a group
#M  CharacterDegrees( <G>, <zero> ) . . . . . . . . . .  for a group and zero
##
##  The attribute delegates to the two-argument version.
##  The two-argument version delegates to `Irr'.
##
InstallMethod( CharacterDegrees,
    "for a group (call the two-argument version)",
    [ IsGroup ],
    G -> CharacterDegrees( G, 0 ) );

InstallMethod( CharacterDegrees,
    "for a group, and zero",
    [ IsGroup, IsZeroCyc ],
    function( G, zero )

    # Force a check whether the group is solvable.
    if not HasIsSolvableGroup( G ) and IsSolvableGroup( G ) then

      # There is a better method which is now applicable.
      return CharacterDegrees( G, 0 );
    fi;

    # For nonsolvable groups, there is just the brute force method.
    return Collected( List( Irr( G ), DegreeOfCharacter ) );
    end );

InstallMethod( CharacterDegrees,
    "for a group, and positive integer",
    [ IsGroup, IsPosInt ],
    function( G, p )
    if Size( G ) mod p = 0 then
      return CharacterDegrees( CharacterTable( G, p ) );
    else
      return CharacterDegrees( G, 0 );
    fi;
    end );


#############################################################################
##
#M  CharacterDegrees( <tbl> ) . . . . . . . . . . . . . for a character table
##
##  If the table knows its group and the irreducibles are not yet stored then
##  we try to avoid the computation of the irreducibles and therefore
##  delegate to the group.
##  Otherwise we use the irreducibles.
##
InstallMethod( CharacterDegrees,
    "for a character table",
    [ IsCharacterTable ],
    function( tbl )
    if HasUnderlyingGroup( tbl ) and not HasIrr( tbl ) then
      return CharacterDegrees( UnderlyingGroup( tbl ) );
    else
      return Collected( List( Irr( tbl ), DegreeOfCharacter ) );
    fi;
    end );


#############################################################################
##
#M  CharacterDegrees( <G> ) . . . . . for group handled via nice monomorphism
##
AttributeMethodByNiceMonomorphism( CharacterDegrees, [ IsGroup ] );


#############################################################################
##
#F  CommutatorLength( <tbl> ) . . . . . . . . . . . . . for a character table
##
InstallMethod( CommutatorLength,
    "for a character table",
    [ IsCharacterTable ],
    function( tbl )

    local nccl,
          irr,
          derived,
          commut,
          other,
          n,
          G_n,
          new,
          i;

    # Compute the classes that form the derived subgroup of $G$.
    irr:= Irr( tbl );
    nccl:= Length( irr );
    derived:= Intersection( List( LinearCharacters( tbl ),
                                  ClassPositionsOfKernel ) );
    commut:= Filtered( [ 1 .. nccl ],
                 i -> Sum( irr, chi -> chi[i] / chi[1] ) <> 0 );
    other:= Difference( derived, commut );

    # Loop.
    n:= 1;
    G_n:= derived;
    while not IsEmpty( other ) do
      new:= [];
      for i in other do
        if ForAny( derived, j -> ForAny( G_n,
            k -> ClassMultiplicationCoefficient( tbl, j, k, i ) <> 0 ) ) then
          Add( new, i );
        fi;
      od;
      n:= n+1;
      UniteSet( G_n, new );
      SubtractSet( other, new );
    od;

    return n;
    end );


#############################################################################
##
#M  CommutatorLength( <G> )  . . . . . . . . . . . . . . . . . .  for a group
##
InstallMethod( CommutatorLength,
    "for a group",
    [ IsGroup ],
    G -> CommutatorLength( CharacterTable( G ) ) );


#############################################################################
##
#M  Irr( <G> )  . . . . . . . . . . . . . . . . . . . . . . . . . for a group
##
##  Delegate to the two-argument version.
##
InstallMethod( Irr,
    "for a group (call the two-argument version)",
    [ IsGroup ],
    G -> Irr( G, 0 ) );


#############################################################################
##
#M  Irr( <G>, <0> )   . . . . . . . . . . . . . . . . .  for a group and zero
##
##  We compute the character table of <G> if it is not yet stored
##  (which must be done anyhow), and then check whether the table already
##  knows its irreducibles.
##  This method is successful if the method for computing the table (head)
##  automatically computes also the irreducibles.
##
InstallMethod( Irr,
    "partial method for a group, and zero",
    [ IsGroup, IsZeroCyc ], SUM_FLAGS,
    function( G, zero )
    local tbl;
    tbl:= OrdinaryCharacterTable( G );
    if HasIrr( tbl ) then
      return Irr( tbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Irr( <G>, <p> )   . . . . . . . . . . . . . . . . for a group and a prime
##
InstallMethod( Irr,
    "for a group, and a prime",
    [ IsGroup, IsPosInt ],
    function( G, p )
    return Irr( BrauerTable( G, p ) );
    end );


#############################################################################
##
#M  Irr( <modtbl> ) . . . . . . . . . . . . . for a <p>-solvable Brauer table
##
##  Compute the modular irreducibles from the ordinary irreducibles
##  using the Fong-Swan Theorem.
##
InstallMethod( Irr,
    "for a <p>-solvable Brauer table (use the Fong-Swan Theorem)",
    [ IsBrauerTable ],
    function( modtbl )

    local p,       # characteristic
          ordtbl,  # ordinary character table
          i,       # loop variable
          rest,    # restriction of characters to `p'-regular classes
          irr,     # list of Brauer characters
          cd,      # list of ordinary character degrees
          deg,     # one character degree
          chars,   # characters of a given degree
          dec;     # decomposition of ordinary characters
                   # into known Brauer characters

    p:= UnderlyingCharacteristic( modtbl );
    ordtbl:= OrdinaryCharacterTable( modtbl );

    if not IsPSolvableCharacterTable( ordtbl, p ) then
      TryNextMethod();
    fi;

    rest:= RestrictedClassFunctions( Irr( ordtbl ), modtbl );

    if Size( ordtbl ) mod p <> 0 then

      # Catch a trivial case.
      irr:= rest;

    else

      # Start with the linear characters.
      # (Choose the same succession as in the ordinary table,
      # in particular leave the trivial character at first position
      # if this is the case for `ordtbl'.)
      irr:= [];
      for i in rest do
        if DegreeOfCharacter( i ) = 1 and not i in irr then
          Add( irr, i );
        fi;
      od;
      cd:= Set( List( rest, DegreeOfCharacter ) );
      RemoveSet( cd, 1 );

      for deg in cd do
        chars:= Set( Filtered( rest, x -> DegreeOfCharacter( x ) = deg ) );
#T improve this!!!
        dec:= Decomposition( irr, chars, "nonnegative" );
        for i in [ 1 .. Length( dec ) ] do
          if dec[i] = fail then
            Add( irr, chars[i] );
          fi;
        od;
      od;

    fi;

    # Return the irreducible Brauer characters.
    return irr;
    end );


#############################################################################
##
#M  Irr( <ordtbl> ) . . . . . . . .  for an ord. char. table with known group
##
##  We must delegate this to the underlying group.
##  Note that the ordering of classes for the characters in the group
##  and the characters in the table may be different!
##  Note that <ordtbl> may have been obtained by sorting the classes of the
##  table stored as the `OrdinaryCharacterTable' value of $G$;
##  In this case, the attribute `ClassPermutation' of <ordtbl> is set.
##  (The `OrdinaryCharacterTable' value of $G$ itself does *not* have this.)
##
InstallMethod( Irr,
    "for an ord. char. table with known group (delegate to the group)",
    [ IsOrdinaryTable and HasUnderlyingGroup ],
    function( ordtbl )
    local irr, pi;
    irr:= Irr( UnderlyingGroup( ordtbl ) );
    if HasClassPermutation( ordtbl ) then
      pi:= ClassPermutation( ordtbl );
      irr:= List( irr, chi -> Character( ordtbl,
                Permuted( ValuesOfClassFunction( chi ), pi ) ) );
    fi;
    return irr;
    end );


#############################################################################
##
#M  IBr( <modtbl> ) . . . . . . . . . . . . . .  for a Brauer character table
#M  IBr( <G>, <p> ) . . . . . . . . . . . .  for a group, and a prime integer
##
InstallMethod( IBr,
    "for a Brauer table",
    [ IsBrauerTable ],
    Irr );

InstallMethod( IBr,
    "for a group, and a prime integer",
    [ IsGroup, IsPosInt ],
    function( G, p ) return Irr( G, p ); end );


#############################################################################
##
#M  LinearCharacters( <G> )
##
##  Delegate to the two-argument version, as for `Irr'.
##
InstallMethod( LinearCharacters,
    "for a group (call the two-argument version)",
    [ IsGroup ],
    G -> LinearCharacters( G, 0 ) );


#############################################################################
##
#M  LinearCharacters( <G>, 0 )
##
InstallMethod( LinearCharacters,
    "for a group, and zero",
    [ IsGroup, IsZeroCyc ],
    function( G, zero )
    local pi, img;

    if IsAbelian( G ) then
      return Irr( G, 0 );
    fi;

    pi:= NaturalHomomorphismByNormalSubgroup( G, DerivedSubgroup( G ) );
    img:= ImagesSource( pi );
    SetIsAbelian( img, true );
    return RestrictedClassFunctions( CharacterTable( img ),
               Irr( img, 0 ), pi );
#T related to `DxLinearCharacters'?
    end );


#############################################################################
##
#M  LinearCharacters( <G>, 0 )
##
InstallMethod( LinearCharacters,
    "for a group with known ordinary table, and zero",
    [ IsGroup and HasOrdinaryCharacterTable, IsZeroCyc ],
    function( G, zero )
    local tbl;
    tbl:= OrdinaryCharacterTable( G );
    if HasIrr( tbl ) then
      return LinearCharacters( tbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  LinearCharacters( <G>, <p> )
##
InstallMethod( LinearCharacters,
    "for a group, and positive integer",
    [ IsGroup, IsPosInt ],
    function( G, p )
    if not IsPrimeInt( p ) then
      Error( "<p> must be a prime" );
    fi;
    return Filtered( LinearCharacters( G, 0 ),
                     chi -> Conductor( chi ) mod p <> 0 );
    end );


#############################################################################
##
#M  LinearCharacters( <ordtbl> )  . . . . . . . . . . . for an ordinary table
##
InstallMethod( LinearCharacters,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    function( ordtbl )
    local lin, pi;
    if HasIrr( ordtbl ) then
      return Filtered( Irr( ordtbl ), chi -> chi[1] = 1 );
    elif HasUnderlyingGroup( ordtbl ) then
      lin:= LinearCharacters( UnderlyingGroup( ordtbl ) );
      if HasClassPermutation( ordtbl ) then
        pi:= ClassPermutation( ordtbl );
        lin:= List( lin, lambda -> Character( ordtbl,
                  Permuted( ValuesOfClassFunction( lambda ), pi ) ) );
      fi;
      return lin;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  LinearCharacters( <modtbl> )  . . . . . . . . . . . .  for a Brauer table
##
InstallMethod( LinearCharacters,
    "for a Brauer table",
    [ IsBrauerTable ],
    modtbl -> DuplicateFreeList( RestrictedClassFunctions(
                  LinearCharacters( OrdinaryCharacterTable( modtbl ) ),
                  modtbl ) ) );


#############################################################################
##
#M  OrdinaryCharacterTable( <G> ) . . . . . . . . . . . . . . . . for a group
#M  OrdinaryCharacterTable( <modtbl> )  . . . .  for a Brauer character table
##
##  In the first case, we setup the table object.
##  In the second case, we delegate to `OrdinaryCharacterTable' for the
##  group.
##
InstallMethod( OrdinaryCharacterTable,
    "for a group",
    [ IsGroup ],
    function( G )
    local tbl, ccl, idpos, bijection;

    # Make the object.
    tbl:= Objectify( NewType( NearlyCharacterTablesFamily,
                              IsOrdinaryTable and IsAttributeStoringRep ),
                     rec() );

    # Store the attribute values of the interface.
    SetUnderlyingGroup( tbl, G );
    SetUnderlyingCharacteristic( tbl, 0 );
    ccl:= ConjugacyClasses( G );
    idpos:= First( [ 1 .. Length( ccl ) ],
                   i -> Order( Representative( ccl[i] ) ) = 1 );
    if idpos = 1 then
      bijection:= [ 1 .. Length( ccl ) ];
    else
      ccl:= Concatenation( [ ccl[ idpos ] ], ccl{ [ 1 .. idpos-1 ] },
                           ccl{ [ idpos+1 .. Length( ccl ) ] } );
      bijection:= Concatenation( [ idpos ], [ 1 .. idpos-1 ],
                                 [ idpos+1 .. Length( ccl ) ] );
    fi;
    SetConjugacyClasses( tbl, ccl );
    SetIdentificationOfConjugacyClasses( tbl, bijection );

    # Return the table.
    return tbl;
    end );


##############################################################################
##
#M  AbelianInvariants( <tbl> )  . . . . . . . for an ordinary character table
##
##  For all Sylow $p$ subgroups of the factor of <tbl> by the normal subgroup
##  given by `ClassPositionsOfDerivedSubgroup( <tbl> )',
##  compute the abelian invariants by repeated factoring by a cyclic group
##  of maximal order.
##
InstallMethod( AbelianInvariants,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    function( tbl )

    local kernel,  # cyclic group to be factored out
          inv,     # list of invariants, result
          primes,  # list of prime divisors of actual size
          max,     # list of actual maximal orders, for `primes'
          pos,     # list of positions of maximal orders
          orders,  # list of representative orders
          i,       # loop over classes
          j;       # loop over primes

    # Do all computations modulo the derived subgroup.
    kernel:= ClassPositionsOfDerivedSubgroup( tbl );
    if 1 < Length( kernel ) then
      tbl:= tbl / kernel;
    fi;
#T cheaper to use only orders and power maps,
#T and to avoid computing several tables!
#T (especially avoid to compute the irreducibles of the original
#T table if they are not known!)

    inv:= [];

    while 1 < Size( tbl ) do

      # For all prime divisors $p$ of the size,
      # compute the element of maximal $p$ power order.
      primes:= Set( FactorsInt( Size( tbl ) ) );
      max:= List( primes, x -> 1 );
      pos:= [];
      orders:= OrdersClassRepresentatives( tbl );
      for i in [ 2 .. Length( orders ) ] do
        if IsPrimePowerInt( orders[i] ) then
          j:= 1;
          while orders[i] mod primes[j] <> 0 do
            j:= j+1;
          od;
          if orders[i] > max[j] then
            max[j]:= orders[i];
            pos[j]:= i;
          fi;
        fi;
      od;

      # Update the list of invariants.
      Append( inv, max );

      # Factor out the cyclic subgroup.
      tbl:= tbl / ClassPositionsOfNormalClosure( tbl, pos );

    od;

    return AbelianInvariantsOfList( inv );
#T if we call this function anyhow, we can also take factors by the largest
#T cyclic subgroup of the commutator factor group!
    end );


#############################################################################
##
#M  Exponent( <tbl> ) . . . . . . . . . . . . for an ordinary character table
##
InstallMethod( Exponent,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    tbl -> Lcm( OrdersClassRepresentatives( tbl ) ) );


#############################################################################
##
#M  IsAbelian( <tbl> )  . . . . . . . . . . . for an ordinary character table
##
InstallMethod( IsAbelian,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    tbl -> Size( tbl ) = NrConjugacyClasses( tbl ) );


#############################################################################
##
#M  IsCyclic( <tbl> ) . . . . . . . . . . . . for an ordinary character table
##
InstallMethod( IsCyclic,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    tbl -> Size( tbl ) in OrdersClassRepresentatives( tbl ) );


#############################################################################
##
#M  IsElementaryAbelian( <tbl> )  . . . . . . for an ordinary character table
##
InstallMethod( IsElementaryAbelian,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    tbl -> Size( tbl ) = 1 or
           ( IsAbelian( tbl ) and IsPrimeInt( Exponent( tbl ) ) ) );


#############################################################################
##
#M  IsFinite( <tbl> ) . . . . . . . . . . . . for an ordinary character table
##
InstallMethod( IsFinite,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    tbl -> IsInt( Size( tbl ) ) );


#############################################################################
##
#M  IsMonomialCharacterTable( <tbl> ) . . . . for an ordinary character table
##
InstallMethod( IsMonomialCharacterTable,
    "for an ordinary character table with underlying group",
    [ IsOrdinaryTable and HasUnderlyingGroup ],
    tbl -> IsMonomialGroup( UnderlyingGroup( tbl ) ) );


#############################################################################
##
#F  CharacterTable_IsNilpotentFactor( <tbl>, <N> )
##
InstallGlobalFunction( CharacterTable_IsNilpotentFactor, function( tbl, N )
    local series;
    series:= CharacterTable_UpperCentralSeriesFactor( tbl, N );
    return Length( series[ Length( series ) ] ) = NrConjugacyClasses( tbl );
    end );


#############################################################################
##
#F  CharacterTable_IsNilpotentNormalSubgroup( <tbl>, <N> )
##
InstallGlobalFunction( CharacterTable_IsNilpotentNormalSubgroup,
    function( tbl, N )

    local classlengths,  # class lengths
          orders,        # orders of class representatives
          ppow,          # list of classes of prime power order
          part,          # one pair `[ prime, exponent ]'
          classes;       # classes of p power order for a prime p

    # Take the classes of prime power order.
    classlengths:= SizesConjugacyClasses( tbl );
    orders:= OrdersClassRepresentatives( tbl );
    ppow:= Filtered( N, i -> IsPrimePowerInt( orders[i] ) );

    for part in Collected( FactorsInt( Sum( classlengths{ N }, 0 ) ) ) do

      # Check whether the Sylow p subgroup of `N' is normal in `N',
      # i.e., whether the number of elements of p-power is equal to
      # the size of a Sylow p subgroup.
      classes:= Filtered( ppow, i -> orders[i] mod part[1] = 0 );
      if part[1] ^ part[2] <> Sum( classlengths{ classes }, 0 ) + 1 then
        return false;
      fi;

    od;
    return true;
    end );


#############################################################################
##
#M  IsNilpotentCharacterTable( <tbl> )
##
InstallMethod( IsNilpotentCharacterTable,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    function( tbl )
    local series;
    series:= ClassPositionsOfUpperCentralSeries( tbl );
    return Length( series[ Length( series ) ] ) = NrConjugacyClasses( tbl );
    end );


#############################################################################
##
#M  IsPerfectCharacterTable( <tbl> )  . . . . for an ordinary character table
##
InstallMethod( IsPerfectCharacterTable,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    tbl -> Number( Irr( tbl ), chi -> chi[1] = 1 ) = 1 );


#############################################################################
##
#M  IsSimpleCharacterTable( <tbl> ) . . . . . for an ordinary character table
##
InstallMethod( IsSimpleCharacterTable,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    tbl -> Length( ClassPositionsOfNormalSubgroups( tbl ) ) = 2 );


#############################################################################
##
#M  IsSolvableCharacterTable( <tbl> ) . . . . for an ordinary character table
##
InstallMethod( IsSolvableCharacterTable,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    tbl -> IsPSolvableCharacterTable( tbl, 0 ) );


#############################################################################
##
#M  IsSporadicSimpleCharacterTable( <tbl> ) . for an ordinary character table
##
##  Note that by the classification of finite simple groups, the sporadic
##  simple groups are determined by their orders.
##
InstallMethod( IsSporadicSimpleCharacterTable,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    function( tbl )
    local info;

    if IsSimpleCharacterTable( tbl ) then
      info:= IsomorphismTypeInfoFiniteSimpleGroup( Size( tbl ) );
      return     info <> fail
             and IsBound( info.series )
             and info.series = "Spor";
    fi;
    return false;
    end );


#############################################################################
##
#M  IsSupersolvableCharacterTable( <tbl> )  . for an ordinary character table
##
InstallMethod( IsSupersolvableCharacterTable,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    tbl -> Size( ClassPositionsOfSupersolvableResiduum( tbl ) ) = 1 );


#############################################################################
##
#M  NrConjugacyClasses( <ordtbl> )  . . . . . for an ordinary character table
#M  NrConjugacyClasses( <modtbl> )  . . . . . .  for a Brauer character table
#M  NrConjugacyClasses( <G> )
##
##  We delegate from <tbl> to the underlying group in the general case.
##  If we know the centralizer orders or class lengths, however, we use them.
##
##  If the argument is a group, we can use the known class lengths of the
##  known ordinary character table.
##
InstallMethod( NrConjugacyClasses,
    "for an ordinary character table with underlying group",
    [ IsOrdinaryTable and HasUnderlyingGroup ],
    ordtbl -> NrConjugacyClasses( UnderlyingGroup( ordtbl ) ) );

InstallMethod( NrConjugacyClasses,
    "for a Brauer character table",
    [ IsBrauerTable ],
    modtbl -> Length( GetFusionMap( modtbl,
                                    OrdinaryCharacterTable( modtbl ) ) ) );

InstallMethod( NrConjugacyClasses,
    "for a character table with known centralizer orders",
    [ IsNearlyCharacterTable and HasSizesCentralizers ],
    tbl -> Length( SizesCentralizers( tbl ) ) );

InstallMethod( NrConjugacyClasses,
    "for a character table with known class lengths",
    [ IsNearlyCharacterTable and HasSizesConjugacyClasses ],
    tbl -> Length( SizesConjugacyClasses( tbl ) ) );

InstallMethod( NrConjugacyClasses,
    "for a group with known ordinary character table",
    [ IsGroup and HasOrdinaryCharacterTable ],
    function( G )
    local tbl;
    tbl:= OrdinaryCharacterTable( G );
    if HasNrConjugacyClasses( tbl ) then
      return NrConjugacyClasses( tbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Size( <tbl> ) . . . . . . . . . . . . . . . . . . . for a character table
#M  Size( <G> )
##
##  We delegate from <tbl> to the underlying group in the general case.
##  If we know the centralizer orders, however, we use them.
##
##  If the argument is a group, we can use the known size of the
##  known ordinary character table.
##
InstallMethod( Size,
    "for a character table with underlying group",
    [ IsCharacterTable and HasUnderlyingGroup ],
    tbl -> Size( UnderlyingGroup( tbl ) ) );

InstallMethod( Size,
    "for a character table with known centralizer orders",
    [ IsNearlyCharacterTable and HasSizesCentralizers ],
    tbl -> SizesCentralizers( tbl )[1] );

InstallMethod( Size,
    "for a group with known ordinary character table",
    [ IsGroup and HasOrdinaryCharacterTable ],
    function( G )
    local tbl;
    tbl:= OrdinaryCharacterTable( G );
    if HasSize( tbl ) then
      return Size( tbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
##  6. Attributes and Properties only for Character Tables
##

#############################################################################
##
#M  OrdersClassRepresentatives( <ordtbl> )  . for an ordinary character table
#M  OrdersClassRepresentatives( <modtbl> )  . .  for a Brauer character table
##
##  We delegate from <tbl> to the underlying group in the general case.
##  If we know the class lengths, however, we use them.
##
InstallMethod( OrdersClassRepresentatives,
    "for a Brauer character table (delegate to the ordinary table)",
    [ IsBrauerTable ],
    function( modtbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    return OrdersClassRepresentatives( ordtbl ){ GetFusionMap( modtbl,
               ordtbl ) };
    end );

InstallMethod( OrdersClassRepresentatives,
    "for a character table with known group",
    [ IsNearlyCharacterTable and HasUnderlyingGroup ],
    tbl -> List( ConjugacyClasses( tbl ),
                 c -> Order( Representative( c ) ) ) );

InstallMethod( OrdersClassRepresentatives,
    "for a character table, use known power maps",
    [ IsNearlyCharacterTable ],
    function( tbl )

    local pow, ord, p;

    # Compute the orders as determined by the known power maps.
    pow:= ComputedPowerMaps( tbl );
    if IsEmpty( pow ) then
      return fail;
    fi;
    ord:= ElementOrdersPowerMap( pow );
    if ForAll( ord, IsInt ) then
      return ord;
    fi;

    # If these maps do not suffice, compute the missing power maps
    # and then try again.
    for p in Set( Factors( Size( tbl ) ) ) do
      PowerMap( tbl, p );
    od;
    ord:= ElementOrdersPowerMap( ComputedPowerMaps( tbl ) );
    Assert( 2, ForAll( ord, IsInt ),
            "computed power maps should determine element orders" );

    return ord;
    end );


#############################################################################
##
#M  SizesCentralizers( <ordtbl> ) . . . . . . for an ordinary character table
#M  SizesCentralizers( <modtbl> ) . . . . . . .  for a Brauer character table
##
##  If we know the class lengths,
##  we prefer them to using a perhaps known group.
##
InstallMethod( SizesCentralizers,
    "for a Brauer character table",
    [ IsBrauerTable ],
    function( modtbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    return SizesCentralizers( ordtbl ){ GetFusionMap( modtbl, ordtbl ) };
    end );

InstallMethod( SizesCentralizers,
    "for a character table with known class lengths",
    [ IsNearlyCharacterTable and HasSizesConjugacyClasses ],
    RankFilter( HasUnderlyingGroup ),  # better than the method with group
    function( tbl )
    local classlengths, size;
    classlengths:= SizesConjugacyClasses( tbl );
    size:= Sum( classlengths, 0 );
    return List( classlengths, s -> size / s );
    end );

InstallMethod( SizesCentralizers,
    "for a character table with known group",
    [ IsNearlyCharacterTable and HasUnderlyingGroup ],
    function( tbl )
    local size;
    size:= Size( tbl );
    return List( ConjugacyClasses( tbl ), c -> size / Size( c ) );
    end );


#############################################################################
##
#M  SizesConjugacyClasses( <ordtbl> ) . . . . for an ordinary character table
#M  SizesConjugacyClasses( <modtbl> ) . . . . .  for a Brauer character table
##
##  If we know the centralizer orders,
##  we prefer them to using a perhaps known group.
##
InstallMethod( SizesConjugacyClasses,
    "for a Brauer character table",
    [ IsBrauerTable ],
    function( modtbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    return SizesConjugacyClasses( ordtbl ){ GetFusionMap( modtbl,
                                                          ordtbl ) };
    end );

InstallMethod( SizesConjugacyClasses,
    "for a character table with known centralizer sizes",
    [ IsNearlyCharacterTable and HasSizesCentralizers ],
    RankFilter( HasUnderlyingGroup ),  # better than the method with group
    function( tbl )
    local centsizes, size;
    centsizes:= SizesCentralizers( tbl );
    size:= centsizes[1];
    return List( centsizes, s -> size / s );
    end );

InstallMethod( SizesConjugacyClasses,
    "for a character table with known group",
    [ IsNearlyCharacterTable and HasUnderlyingGroup ],
    tbl -> List( ConjugacyClasses( tbl ), Size ) );


#############################################################################
##
#M  AutomorphismsOfTable( <tbl> ) . . . . . . . . . . . for a character table
##
InstallMethod( AutomorphismsOfTable,
    "for a character table",
    [ IsCharacterTable ],
    tbl -> TableAutomorphisms( tbl, Irr( tbl ) ) );


#############################################################################
##
#M  AutomorphismsOfTable( <modtbl> )  . . . for Brauer table & good reduction
##
##  The automorphisms may be stored already on the ordinary table.
##
InstallMethod( AutomorphismsOfTable,
    "for a Brauer table in the case of good reduction",
    [ IsBrauerTable ],
    function( modtbl )
    if Size( modtbl ) mod UnderlyingCharacteristic( modtbl ) = 0 then
      TryNextMethod();
    else
      return AutomorphismsOfTable( OrdinaryCharacterTable( modtbl ) );
    fi;
    end );


#############################################################################
##
#M  ClassNames( <tbl> )  . . . . . . . . . . class names of a character table
#M  ClassNames( <tbl>, \"ATLAS\" ) . . . . . class names of a character table
##
InstallMethod( ClassNames,
    [ IsNearlyCharacterTable ],
    tbl -> ClassNames( tbl, "default" ) );

InstallMethod( ClassNames,
    [ IsNearlyCharacterTable, IsString ],
    function( tbl, string )

    local i,        # loop variable
          alpha,    # alphabet
          lalpha,   # length of the alphabet
          number,   # at position <i> the current number of
                    # classes of order <i>
          unknown,  # number of next unknown element order
          names,    # list of classnames, result
          name,     # local function returning right combination of letters
          orders;   # list of representative orders

    if LowercaseString( string ) = "atlas" then

      alpha:= [ "A","B","C","D","E","F","G","H","I","J","K","L","M",
                "N","O","P","Q","R","S","T","U","V","W","X","Y","Z" ];

      name:= function( n )
        local m;
        if n <= lalpha then
          return alpha[n];
        else
          m:= (n-1) mod lalpha + 1;
          n:= ( n - m ) / lalpha;
          return Concatenation( alpha[m], String( n ) );
        fi;
      end;

    else

      alpha:= [ "a","b","c","d","e","f","g","h","i","j","k","l","m",
                "n","o","p","q","r","s","t","u","v","w","x","y","z" ];

      name:= function(n)
        local name;
        name:= "";
        while 0 < n do
          name:= Concatenation( alpha[ (n-1) mod lalpha + 1 ], name );
          n:= QuoInt( n-1, lalpha );
        od;
        return name;
      end;

    fi;

    lalpha:= Length( alpha );
    names:= [];

    if IsCharacterTable( tbl ) or HasOrdersClassRepresentatives( tbl ) then

      # A character table can be asked for representative orders,
      # also if they are not yet stored.
      orders:= OrdersClassRepresentatives( tbl );
      number:= [];
      unknown:= 1;
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        if IsInt( orders[i] ) then
          if not IsBound( number[ orders[i] ] ) then
            number[ orders[i] ]:= 1;
          fi;
          names[i]:= Concatenation( String( orders[i] ),
                                    name( number[ orders[i] ] ) );
          number[ orders[i] ]:= number[ orders[i] ] + 1;
        else
          names[i]:= Concatenation( "?", name( unknown ) );
          unknown:= unknown + 1;
        fi;
      od;

    else

      names[1]:= Concatenation( "1", alpha[1] );
      for i in [ 2 .. NrConjugacyClasses( tbl ) ] do
        names[i]:= Concatenation( "?", name( i-1 ) );
      od;

    fi;

    # Return the list of classnames.
    return names;
    end );


#############################################################################
##
#M  CharacterNames( <tbl> )  . . . . . . character names of a character table
##
InstallMethod( CharacterNames,
    [ IsNearlyCharacterTable ],
    tbl -> List( [ 1 .. NrConjugacyClasses( tbl ) ],
                 i -> Concatenation( "X.", String( i ) ) ) );


#############################################################################
##
#M  \.( <tbl>, <name> ) . . . . . . . . . position of a class with given name
##
##  If <name> is a class name of the character table <tbl> as computed by
##  `ClassNames', `<tbl>.<name>' is the position of the class with this name.
##
InstallMethod( \.,
    "for class names of a nearly character table",
    [ IsNearlyCharacterTable, IsInt ],
    function( tbl, name )
    local pos;
    name:= NameRNam( name );
    pos:= Position( ClassNames( tbl ), name );
    if pos = fail then
      TryNextMethod();
    else
      return pos;
    fi;
    end );


#############################################################################
##
#M  ClassParameters( <tbl> )
##
InstallMethod( ClassParameters,
    "for a Brauer table (if the ordinary table knows class parameters)",
    [ IsBrauerTable ],
    function( tbl )
    local ord;
    ord:= OrdinaryCharacterTable( tbl );
    if HasClassParameters( ord ) then
      return ClassParameters( ord ){ GetFusionMap( tbl, ord ) };
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  ClassPositionsOfNormalSubgroups( <tbl> )
##
InstallMethod( ClassPositionsOfNormalSubgroups,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    function( tbl )
    local kernels,  # list of kernels of irreducible characters
          normal,   # list of normal subgroups, result
          ker1,     # loop variable
          ker2,     # loop variable
          inter;    # intersection of two kernels

    # Get the kernels of irreducible characters.
    kernels:= Set( List( Irr( tbl ), ClassPositionsOfKernel ) );

    # Form all possible intersections of the kernels.
    normal:= ShallowCopy( kernels );
    for ker1 in normal do
      for ker2 in kernels do
        inter:= Intersection( ker1, ker2 );
        if not inter in normal then
          Add( normal, inter );
        fi;
      od;
    od;

    # Sort the list of normal subgroups (first lexicographically,
    # then --stable sort-- according to length and thus inclusion).
    normal:= SSortedList( normal );
    Sort( normal, function( x, y ) return Length(x) < Length(y); end );

    # Represent the lists as ranges if possible.
    # (It is not possible to do this earlier since the representation
    # as a range may get lost in the `Intersection' call.)
    for ker1 in normal do
      ConvertToRangeRep( ker1 );
    od;

    # Return the list of normal subgroups.
    return normal;
    end );


#############################################################################
##
#M  ClassPositionsOfMaximalNormalSubgroups( <tbl> )
##
##  *Note* that the maximal normal subgroups of a group <G> can be computed
##  easily if the character table of <G> is known.  So if you need the table
##  anyhow, you should compute it before computing the maximal normal
##  subgroups of the group.
##
InstallMethod( ClassPositionsOfMaximalNormalSubgroups,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    function( tbl )
    local normal,    # list of all kernels
          maximal,   # list of maximal kernels
          k;         # one kernel

    # Every normal subgroup is an intersection of kernels of characters,
    # so maximal normal subgroups are kernels of irreducible characters.
    normal:= Set( List( Irr( tbl ), ClassPositionsOfKernel ) );

    # Remove non-maximal kernels
    RemoveSet( normal, [ 1 .. NrConjugacyClasses( tbl ) ] );
    Sort( normal, function(x,y) return Length(x) > Length(y); end );
    maximal:= [];
    for k in normal do
      if ForAll( maximal, x -> not IsSubsetSet( x, k ) ) then

        # new maximal element found
        Add( maximal, k );

      fi;
    od;

    return maximal;
    end );


#############################################################################
##
#M  ClassPositionsOfMinimalNormalSubgroups( <tbl> )
##
##  *Note* that the minimal normal subgroups of a group <G> can be computed
##  easily if the character table of <G> is known.  So if you need the table
##  anyhow, you should compute it before computing the minimal normal
##  subgroups of the group.
##
InstallMethod( ClassPositionsOfMinimalNormalSubgroups,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    function( tbl )
    local normal,    # list of all kernels
          minimal,   # list of minimal kernels
          k;         # one kernel

    # Every normal subgroup is an intersection of kernels of characters,
    # so maximal normal subgroups are kernels of irreducible characters.
    normal:= Set( ClassPositionsOfNormalSubgroups( tbl ) );

    # Remove non-minimal kernels
    RemoveSet( normal, [ 1 ] );
    Sort( normal, function(x,y) return Length(x) < Length(y); end );
    minimal:= [];
    for k in normal do
      if ForAll( minimal, x -> not IsSubsetSet( k, x ) ) then

        # new minimal element found
        Add( minimal, k );

      fi;
    od;

    return minimal;
    end );


#############################################################################
##
#M  ClassPositionsOfAgemo( <tbl>, <p> )
##
InstallMethod( ClassPositionsOfAgemo,
    "for an ordinary table",
    [ IsOrdinaryTable, IsPosInt ],
    function( tbl, p )
    return ClassPositionsOfNormalClosure( tbl, Set( PowerMap( tbl, p ) ) );
    end );


#############################################################################
##
#M  ClassPositionsOfCentre( <tbl> )
##
InstallMethod( ClassPositionsOfCentre,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    function( tbl )
    local classes;
    classes:= SizesConjugacyClasses( tbl );
    return Filtered( [ 1 .. NrConjugacyClasses( tbl ) ],
                     x -> classes[x] = 1 );
    end );


#############################################################################
##
#M  ClassPositionsOfDirectProductDecompositions( <tbl> )
#M  ClassPositionsOfDirectProductDecompositions( <tbl>, <nclasses> )
##
BindGlobal( "DirectProductDecompositionsLocal",
    function( nsg, classes, size )

    local sizes, decomp, i, quot, pos;

    nsg:= Difference( nsg, [ [ 1 ] ] );
    sizes:= List( nsg, x -> Sum( classes{ x }, 0 ) );
    SortParallel( sizes, nsg );

    decomp:= [];
    for i in [ 1 .. Length( nsg ) ] do
      quot:= size / sizes[i];
      if quot < sizes[i] then
        break;
      fi;
      pos:= Position( sizes, quot );
      while pos <> fail do
        if Length( Intersection( nsg[i], nsg[ pos ] ) ) = 1 then
          Add( decomp, [ nsg[i], nsg[ pos ] ] );
        fi;
        pos:= Position( sizes, quot, pos );
      od;
    od;

    for i in decomp do
      ConvertToRangeRep( i[1] );
      ConvertToRangeRep( i[2] );
    od;

    return decomp;
end );

InstallMethod( ClassPositionsOfDirectProductDecompositions,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    tbl -> DirectProductDecompositionsLocal(
        ShallowCopy( ClassPositionsOfNormalSubgroups( tbl ) ),
        SizesConjugacyClasses( tbl ),
        Size( tbl ) ) );

InstallMethod( ClassPositionsOfDirectProductDecompositions,
    "for an ordinary table, and a list of positive integers",
    [ IsOrdinaryTable, IsList and IsCyclotomicCollection ],
    function( tbl, nclasses )
    local classes;
    classes:= SizesConjugacyClasses( tbl );
    return DirectProductDecompositionsLocal(
        Filtered( ClassPositionsOfNormalSubgroups( tbl ),
                      list -> IsSubset( nclasses, list ) ),
        classes,
        Sum( classes{ nclasses }, 0 ) );
    end );


#############################################################################
##
#M  ClassPositionsOfDerivedSubgroup( <tbl> )
##
##  The derived subgroup is the intersection of the kernels of all linear
##  characters.
##
InstallMethod( ClassPositionsOfDerivedSubgroup,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    function( tbl )
    local der,   # derived subgroup, result
          chi;   # one linear character

    der:= [ 1 .. NrConjugacyClasses( tbl ) ];
    for chi in LinearCharacters( tbl ) do
      IntersectSet( der, ClassPositionsOfKernel( chi ) );
    od;
    ConvertToRangeRep( der );
    return der;
    end );


#############################################################################
##
#M  ClassPositionsOfElementaryAbelianSeries( <tbl> )
##
InstallMethod( ClassPositionsOfElementaryAbelianSeries,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    function( tbl )
    local elab,         # el. ab. series, result
          nsg,          # list of normal subgroups of `tbl'
          actsize,      # size of actual normal subgroup
          classes,      # conjugacy class lengths
          next,         # next smaller normal subgroup
          nextsize;     # size of next smaller normal subgroup

    # The trivial group has too few normal subgroups.
    if Size( tbl ) = 1 then
      return [ [ 1 ] ];
    fi;

    # Sort normal subgroups according to decreasing number of classes.
    nsg:= ShallowCopy( ClassPositionsOfNormalSubgroups( tbl ) );

    elab:= [ [ 1 .. NrConjugacyClasses( tbl ) ] ];
    Unbind( nsg[ Length( nsg ) ] );

    actsize:= Size( tbl );
    classes:= SizesConjugacyClasses( tbl );

    repeat

      next:= nsg[ Length( nsg ) ];
      nextsize:= Sum( classes{ next }, 0 );
      Add( elab, next );
      Unbind( nsg[ Length( nsg ) ] );
      nsg:= Filtered( nsg, x -> IsSubset( next, x ) );

      if not IsPrimePowerInt( actsize / nextsize ) then
        # `tbl' is not the table of a solvable group.
        return fail;
      fi;

      actsize:= nextsize;

    until Length( nsg ) = 0;

    return elab;
    end );


#############################################################################
##
#M  ClassPositionsOfFittingSubgroup( <tbl> )
##
##  The Fitting subgroup is the maximal nilpotent normal subgroup, that is,
##  the product of all normal subgroups of prime power order.
##
InstallMethod( ClassPositionsOfFittingSubgroup,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    function( tbl )
    local nsg,      # all normal subgroups of `tbl'
          classes,  # class lengths
          ppord,    # classes in normal subgroups of prime power order
          n;        # one normal subgroup of `tbl'

    # Compute all normal subgroups.
    nsg:= ClassPositionsOfNormalSubgroups( tbl );

    # Take the union of classes in all normal subgroups of prime power order.
    classes:= SizesConjugacyClasses( tbl );
    ppord:= [ 1 ];
    for n in nsg do
      if IsPrimePowerInt( Sum( classes{n}, 0 ) ) then
        UniteSet( ppord, n );
      fi;
    od;

    # Return the normal closure.
    return ClassPositionsOfNormalClosure( tbl, ppord );
    end );


#############################################################################
##
#M  ClassPositionsOfLowerCentralSeries( <tbl> )
##
##  Let <tbl> the character table of the group $G$.
##  The lower central series $[ K_1, K_2, \ldots, K_n ]$ of $G$ is defined
##  by $K_1 = G$, and $K_{i+1} = [ K_i, G ]$.
##  `LowerCentralSeries( <tbl> )' is a list
##  $[ C_1, C_2, \ldots, C_n ]$ where $C_i$ is the set of positions of
##  $G$-conjugacy classes contained in $K_i$.
##
##  Given an element $x$ of $G$, then $g\in G$ is conjugate to $[x,y]$ for
##  an element $y\in G$ if and only if
##  $\sum_{\chi\in Irr(G)} \frac{|\chi(x)|^2 \overline{\chi(g)}}{\chi(1)}
##  \not= 0$, or equivalently, if the structure constant
##  $a_{x,\overline{x},g}$ is nonzero.
##
##  Thus $K_{i+1}$ consists of all classes $Cl(g)$ in $K_i$ for that there
##  is an $x\in K_i$ such that $a_{x,\overline{x},g}$ is nonzero.
##
InstallMethod( ClassPositionsOfLowerCentralSeries,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    function( tbl )
    local series,     # list of normal subgroups, result
          K,          # actual last element of `series'
          inv,        # list of inverses of classes of `tbl'
          mat,        # matrix of structure constants
          i, j,       # loop over `mat'
          running,    # loop not yet terminated
          new;        # next element in `series'

    series:= [];
    series[1]:= [ 1 .. NrConjugacyClasses( tbl ) ];
    K:= ClassPositionsOfDerivedSubgroup( tbl );
    if K = series[1] then
      return series;
    fi;
    series[2]:= K;

    # Compute the structure constants $a_{x,\overline{x},g}$ with $g$ and $x$
    # in $K_2$.
    # Put them into a matrix, the rows indexed by $g$, the columns by $x$.
    inv:= PowerMap( tbl, -1 );
    mat:= List( K, x -> [] );
    for i in [ 2 .. Length( K ) ] do
      for j in K do
        mat[i][j]:= ClassMultiplicationCoefficient( tbl, K[i], j, inv[j] );
      od;
    od;

    running:= true;

    while running do

      new:= [ 1 ];
      for i in [ 2 .. Length( mat ) ] do
        if ForAny( K, x -> mat[i][x] <> 0 ) then
          Add( new, i );
        fi;
      od;

      if Length( new ) = Length( K ) then
        running:= false;
      else
        mat:= mat{ new };
        K:= K{ new };
        Add( series, new );
      fi;

    od;

    return series;
    end );


#############################################################################
##
#F  CharacterTable_UpperCentralSeriesFactor( <tbl>, <N> )
##
InstallGlobalFunction( CharacterTable_UpperCentralSeriesFactor,
    function( tbl, N )

    local Z,      # result list
          n,      # number of conjugacy classes
          M,      # actual list of pairs kernel/centre of characters
          nextM,  # list of pairs in next iteration
          kernel, # kernel of a character
          centre, # centre of a character
          i,      # loop variable
          chi;    # loop variable

    n:= NrConjugacyClasses( tbl );
    N:= Set( N );

    # instead of the irreducibles store pairs $[ \ker(\chi), Z(\chi) ]$.
    # `Z' will be the list of classes forming $Z_1 = Z(G/N)$.
    M:= [];
    Z:= [ 1 .. n ];
    for chi in Irr( tbl ) do
      kernel:= ClassPositionsOfKernel( chi );
      if IsSubsetSet( kernel, N ) then
        centre:= ClassPositionsOfCentre( chi );
        AddSet( M, [ kernel, centre ] );
        IntersectSet( Z, centre );
      fi;
    od;

    Z:= [ Z ];
    i:= 0;

    repeat
      i:= i+1;
      nextM:= [];
      Z[i+1]:= [ 1 .. n ];
      for chi in M do
        if IsSubsetSet( chi[1], Z[i] ) then
          Add( nextM, chi );
          IntersectSet( Z[i+1], chi[2] );
        fi;
      od;
      M:= nextM;
    until Z[i+1] = Z[i];
    Unbind( Z[i+1] );

    return Z;
end );


#############################################################################
##
#M  ClassPositionsOfUpperCentralSeries( <tbl> )
##
InstallMethod( ClassPositionsOfUpperCentralSeries,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    tbl -> CharacterTable_UpperCentralSeriesFactor( tbl, [1] ) );


#############################################################################
##
#M  ClassPositionsOfSolvableResiduum( <tbl> )
##
InstallMethod( ClassPositionsOfSolvableResiduum,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    function( tbl )

    local nsg,       # list of all normal subgroups
          i,         # loop variable, position in `nsg'
          N,         # one normal subgroup
          posN,      # position of `N' in `nsg'
          size,      # size of `N'
          nextsize,  # size of largest normal subgroup contained in `N'
          classes;   # class lengths

    nsg:= ClassPositionsOfNormalSubgroups( tbl );

    # Go down a chief series, starting with the whole group,
    # until there is no step of prime order.
    i:= Length( nsg );
    nextsize:= Size( tbl );
    classes:= SizesConjugacyClasses( tbl );

    while 1 < i do

      posN:= i;
      N:= nsg[ posN ];
      size:= nextsize;

      # Get the largest normal subgroup contained in `N' \ldots
      i:= posN - 1;
      while not IsSubsetSet( N, nsg[ i ] ) do i:= i-1; od;

      # \ldots and its size.
      nextsize:= Sum( classes{ nsg[i] }, 0 );

      if not IsPrimePowerInt( size / nextsize ) then

        # The chief factor `N / nsg[i]' is not of prime power order,
        # i.e., `N' is the solvable residuum.
        return N;

      fi;

    od;

    # The group is solvable.
    return [ 1 ];
    end );


#############################################################################
##
#M  ClassPositionsOfSupersolvableResiduum( <tbl> )
##
InstallMethod( ClassPositionsOfSupersolvableResiduum,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    function( tbl )

    local nsg,       # list of all normal subgroups
          i,         # loop variable, position in `nsg'
          N,         # one normal subgroup
          posN,      # position of `N' in `nsg'
          size,      # size of `N'
          nextsize,  # size of largest normal subgroup contained in `N'
          classes;   # class lengths

    nsg:= ClassPositionsOfNormalSubgroups( tbl );

    # Go down a chief series, starting with the whole group,
    # until there is no step of prime order.
    i:= Length( nsg );
    nextsize:= Size( tbl );
    classes:= SizesConjugacyClasses( tbl );

    while 1 < i do

      posN:= i;
      N:= nsg[ posN ];
      size:= nextsize;

      # Get the largest normal subgroup contained in `N' \ldots
      i:= posN - 1;
      while not IsSubsetSet( N, nsg[ i ] ) do i:= i-1; od;

      # \ldots and its size.
      nextsize:= Sum( classes{ nsg[i] }, 0 );

      if not IsPrimeInt( size / nextsize ) then

        # The chief factor `N / nsg[i]' is not of prime order,
        # i.e., `N' is the supersolvable residuum.
        return N;

      fi;

    od;

    # The group is supersolvable.
    return [ 1 ];
    end );


#############################################################################
##
#M  ClassPositionsOfNormalClosure( <tbl>, <classes> )
##
InstallMethod( ClassPositionsOfNormalClosure,
    "for an ordinary table",
    [ IsOrdinaryTable, IsHomogeneousList and IsCyclotomicCollection ],
    function( tbl, classes )
    local closure,   # classes forming the normal closure, result
          chi,       # one irreducible character of `tbl'
          ker;       # classes forming the kernel of `chi'

    closure:= [ 1 .. NrConjugacyClasses( tbl ) ];
    for chi in Irr( tbl ) do
      ker:= ClassPositionsOfKernel( chi );
      if IsSubset( ker, classes ) then
        IntersectSet( closure, ker );
      fi;
    od;

    return closure;
    end );


#############################################################################
##
#M  Identifier( <tbl> ) . . . . . . . . . . . . . . . . for an ordinary table
##
##  Note that library tables have an `Identifier' value by construction.
##
InstallMethod( Identifier,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    function( tbl )

    # Construct an identifier that is unique in the current session.
    LARGEST_IDENTIFIER_NUMBER[1]:= LARGEST_IDENTIFIER_NUMBER[1] + 1;
    tbl:= Concatenation( "CT", String( LARGEST_IDENTIFIER_NUMBER[1] ) );
    ConvertToStringRep( tbl );
    return tbl;
    end );


#############################################################################
##
#M  Identifier( <tbl> ) . . . . . . . . . . . . . . . . .  for a Brauer table
##
InstallMethod( Identifier,
    "for a Brauer table",
    [ IsBrauerTable ],
    tbl -> Concatenation( Identifier( OrdinaryCharacterTable( tbl ) ),
                          "mod",
                          String( UnderlyingCharacteristic( tbl ) ) ) );


#############################################################################
##
#M  InverseClasses( <tbl> ) . . .  method for an ord. table with irreducibles
##
InstallMethod( InverseClasses,
    "for a character table with known irreducibles",
    [ IsCharacterTable and HasIrr ],
    function( tbl )
    local nccl,
          irreds,
          inv,
          isinverse,
          chi,
          remain,
          i, j;

    nccl:= NrConjugacyClasses( tbl );
    irreds:= Irr( tbl );
    inv:= [ 1 ];

    isinverse:= function( i, j )         # is `j' the inverse of `i' ?
    for chi in irreds do
      if not IsRat( chi[i] ) and chi[i] <> GaloisCyc( chi[j], -1 ) then
        return false;
      fi;
    od;
    return true;
    end;

    remain:= [ 2 .. nccl ];
    for i in [ 2 .. nccl ] do
      if i in remain then
        for j in remain do
          if isinverse( i, j ) then
            inv[i]:= j;
            inv[j]:= i;
            SubtractSet( remain, Set( [ i, j ] ) );
            break;
          fi;
        od;
      fi;
    od;

    return inv;
    end );


#############################################################################
##
#M  InverseClasses( <tbl> ) . . . . . . . . . .  method for a character table
##
##  Note that `PowerMap' may use `InverseClasses',
##  so `InverseClasses' must not call `PowerMap( <tbl>, -1 )'.
##
InstallMethod( InverseClasses,
    "for a character table",
    [ IsCharacterTable ],
    function( tbl )
    local orders;

    orders:= OrdersClassRepresentatives( tbl );
    return List( [ 1 .. Length( orders ) ],
                 i -> PowerMap( tbl, orders[i]-1, i ) );
    end );


#############################################################################
##
#M  RealClasses( <tbl> )  . . . . . . . . . . . . . . the real-valued classes
##
InstallMethod( RealClasses,
    "for a character table",
    [ IsCharacterTable ],
    function( tbl )
    local inv;
    inv:= InverseClasses( tbl );
    return Filtered( [ 1 .. NrConjugacyClasses( tbl ) ], i -> inv[i] = i );
    end );


#############################################################################
##
#M  ClassOrbit( <tbl>, <cc> ) . . . . . . . . .  classes of a cyclic subgroup
##
InstallMethod( ClassOrbit,
    "for a character table, and a positive integer",
    [ IsCharacterTable, IsPosInt ],
    function( tbl, cc )
    local i, oo, res;

    res:= [ cc ];
    oo:= OrdersClassRepresentatives( tbl )[cc];

    # find all generators of <cc>
    for i in [ 2 .. oo-1 ] do
       if GcdInt(i, oo) = 1 then
          AddSet( res, PowerMap( tbl, i, cc ) );
       fi;
    od;

    return res;
    end );


#############################################################################
##
#M  ClassRoots( <tbl> ) . . . . . . . . . . . .  nontrivial roots of elements
##
InstallMethod( ClassRoots,
    "for a character table",
    [ IsCharacterTable ],
    function( tbl )

    local i, nccl, orders, p, pmap, root;

    nccl   := NrConjugacyClasses( tbl );
    orders := OrdersClassRepresentatives( tbl );
    root   := List([1..nccl], x->[]);

    for p in Set( Factors( Size( tbl ) ) ) do
       pmap:= PowerMap( tbl, p );
       for i in [1..nccl] do
          if i <> pmap[i] and orders[i] <> orders[pmap[i]] then
             AddSet(root[pmap[i]], i);
          fi;
       od;
    od;

    return root;
    end );


#############################################################################
##
##  x. Operations Concerning Blocks
##


#############################################################################
##
#T  SameBlock( <tbl>, <p>, <omega1>, <omega2>, <relevant>, <exponents> )
#F  SameBlock( <p>, <omega1>, <omega2>, <relevant> )
##
##  See the comments for the `PrimeBlocksOp' method.
##
#T After the release of GAP 4.4, remove the six argument variant!
#T InstallGlobalFunction( SameBlock, function( p, omega1, omega2, relevant )
#T     local i, value;
InstallGlobalFunction( SameBlock, function( arg )
    local p, omega1, omega2, relevant, i, value;

    if Length( arg ) = 4 then
      p        := arg[1];
      omega1   := arg[2];
      omega2   := arg[3];
      relevant := arg[4];
    elif Length( arg ) = 6 then
      p        := arg[2];
      omega1   := arg[3];
      omega2   := arg[4];
      relevant := arg[5];
    else
      Error( "usage: SameBlock( <p>, <omega1>, <omega2>, <relevant> )" );
    fi;

    for i in relevant do
      value:= omega1[i] - omega2[i];
      if IsInt( value ) then
        if value mod p <> 0 then
          return false;
        fi;
      elif IsCyc( value ) then
        # This works even if the value is not an algebraic integer.
        if not IsZero( List( COEFFS_CYC( value ), x -> x mod p ) ) then
          return false;
        fi;
      else
        # maybe an unknown ...
        return false;
      fi;
    od;
    return true;
end );


#############################################################################
##
#M  PrimeBlocks( <tbl>, <p> )
##
InstallMethod( PrimeBlocks,
    "for an ordinary table, and a positive integer",
    [ IsOrdinaryTable, IsPosInt ],
    function( tbl, p )

    local known, erg;

    if not IsPrimeInt( p ) then
      Error( "<p> a prime" );
    fi;

    known:= ComputedPrimeBlockss( tbl );

    # Start storing only after the result has been computed.
    # This avoids errors if a calculation had been interrupted.
    if not IsBound( known[p] ) then
      erg:= PrimeBlocksOp( tbl, p );
      known[p]:= erg;
    fi;

    return known[p];
    end );


#############################################################################
##
#M  PrimeBlocksOp( <tbl>, <p> )
##
##  Following the proof in~\cite[p.~271]{Isa76},
##  two ordinary irreducible characters $\chi$, $\psi$ of a group $G$ lie in
##  the same $p$-block if and only if there is a positive integer $n$
##  such that $(\omega_{\chi}(g) - \omega_{\psi}(g))^n / p$ is an algebraic
##  integer.  (A sufficient value for $n$ is $\varphi(|g|)$.)
##
##  According to Feit, p.~150, it is sufficient to test $p$-regular classes.
##
##  H.~Pahlings mentioned that no ramification can occur for $p$-regular
##  classes, that is, one can always choose $n = 1$ for such classes.
##  Namely, if $g$ has order $m$ not divisible by $p$ then the ideal $p \Z$
##  splits into distinct prime ideals $Q_i$ (i.e., with exponent $1$ each)
##  in the ring $\Z[\zeta_m]$ of algebraic integers in the $m$-th cyclotomic
##  field (see, e.g., p.~78 and Theorem~24 on p.~72 in~\cite{Marcus77}).
##  So the ideal spanned by an algebraic integer $\alpha$ lies in the same
##  $Q_i$ as the ideal spanned by $\alpha^k$,
##  which implies that $\alpha^k \in p \Z[\zeta_m]$ holds if and only if
##  $\alpha \in p \Z[\zeta_m]$ holds.
##
##  (In the literature this fact is not mentioned, presumably because the
##  setup in~\cite[p.~271]{Isa76} does not mention that only $p$-regular
##  classes need to be considered, and the setup in Feit's book does not
##  mention the congruence modulo $p$ of some power of the difference of
##  central character values.)
##
##  The test must be performed only for one class in each Galois family
##  since each Galois automorphism fixes the ring of algebraic integers.
##
##  Each character $\chi$ for which $p$ does not divide $|G| / \chi(1)$
##  (a so-called *defect zero character*) forms a block of its own.
##
InstallMethod( PrimeBlocksOp,
    "for an ordinary table, and a positive integer",
    [ IsOrdinaryTable, IsPosInt ],
    function( tbl, p )
    local i, j, k,
          characters,
          nccl,
          classes,
          tbl_orders,
          primeblocks,
          blockreps,
          families,
          representatives,
          sameblock,
          central,
          found,
          ppart,
          inverse,
          d,
          filt,
          pos;

    characters:= List( Irr( tbl ), ValuesOfClassFunction );
    nccl:= Length( characters[1] );
    classes:= SizesConjugacyClasses( tbl );
    tbl_orders:= OrdersClassRepresentatives( tbl );

    # Compute a representative for each Galois family
    # of `p'-regular classes.
    families:= GaloisMat( TransposedMat( characters ) ).galoisfams;
#T better introduce attribute `RepCycSub' ?
    representatives:= Filtered( [ 2 .. nccl ],
                                x ->     families[x] <> 0
                                     and tbl_orders[x] mod p <> 0 );

    blockreps:= [];
    primeblocks:= rec( block            := [],
                       defect           := [],
                       height           := [],
                       relevant         := representatives,
                       centralcharacter := blockreps );

    # Compute the order of the Sylow `p' subgroup of `tbl'.
    ppart:= 1;
    d:= Size( tbl ) / p;
    while IsInt( d ) do
      ppart:= ppart * p;
      d:= d / p;
    od;

    # Distribute the characters into blocks.
    for i in [ 1 .. Length( characters ) ] do

      central:= [];                       # the central character
      for j in representatives do
        central[j]:= classes[j] * characters[i][j] / characters[i][1];
        if not IsCycInt( central[j] ) then
          Error( "central character ", i,
                 " is not an algebraic integer at class ", j );
        fi;
      od;

      if characters[i][1] mod ppart = 0 then

        # defect zero character (new?)
        pos:= Position( characters, characters[i] );
        if pos = i then
          Add( blockreps, central );
          primeblocks.block[i]:= Length( blockreps );
        else
          primeblocks.block[i]:= primeblocks.block[ pos ];
        fi;

      else

        j:= 1;
        found:= false;
        while j <= Length( blockreps ) and not found do
          if SameBlock( p, central, blockreps[j], representatives ) then
            primeblocks.block[i]:= j;
            found:= true;
          fi;
          j:= j + 1;
        od;
        if not found then
          Add( blockreps, central );
          primeblocks.block[i]:= Length( blockreps );
        fi;

      fi;

    od;

    # Compute the defects.
    inverse:= InverseMap( primeblocks.block );
    for i in inverse do
      if IsInt( i ) then
        Add( primeblocks.defect, 0 );    # defect zero character
        Info( InfoCharacterTable, 2,
              "defect 0: X[", i, "]" );
        primeblocks.height[i]:= 0;
      else
        d:= ppart;
        for j in i do
          d:= GcdInt( d, characters[j][1] );
        od;
        if d = ppart then
          d:= 0;
        else
          d:= Length( FactorsInt( ppart / d ) );              # the defect
        fi;
        Add( primeblocks.defect, d );

        # print defect and heights
        Info( InfoCharacterTable, 2,
              "defect ", d, ";" );

        for j in [ 0 .. d ] do
          filt:= Filtered( i, x -> GcdInt( ppart, characters[x][1] )
                                   = ppart / p^(d-j) );
          if not IsEmpty( filt ) then
            for k in filt do
              primeblocks.height[k]:= j;
            od;
            Info( InfoCharacterTable, 2,
                  "    height ", j, ": X", filt );
          fi;
        od;

      fi;
    od;

    # Return the result.
    return primeblocks;
    end );


#############################################################################
##
#M  ComputedPrimeBlockss( <tbl> )
##
InstallMethod( ComputedPrimeBlockss,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    tbl -> [] );


#############################################################################
##
#M  BlocksInfo( <modtbl> )
##
InstallMethod( BlocksInfo,
    "generic method for a Brauer character table",
    [ IsBrauerTable ],
    function( modtbl )

    local ordtbl, prime, modblocks, decinv, k, ilist, ibr, rest, pblocks,
          ordchars, decmat, nccmod, modchars;

    ordtbl    := OrdinaryCharacterTable( modtbl );
    prime     := UnderlyingCharacteristic( modtbl );
    modblocks := [];

    if Size( ordtbl ) mod prime <> 0 then

      # If characteristic and group order are coprime then all blocks
      # are trivial.
      # (We do not need the Brauer characters.)
      decinv:= [ [ 1 ] ];
      MakeImmutable( decinv );
      for k in [ 1 .. NrConjugacyClasses( ordtbl ) ] do

        ilist:= [ k ];
        MakeImmutable( ilist );

        modblocks[k]:= rec( defect   := 0,
                            ordchars := ilist,
                            modchars := ilist,
                            basicset := ilist,
                            decinv   := decinv );

      od;

    else

      # We use the irreducible Brauer characters.
      ibr      := Irr( modtbl );
      rest     := RestrictedClassFunctions( Irr( ordtbl ), modtbl );
      pblocks  := PrimeBlocks( ordtbl, prime );
      ordchars := InverseMap( pblocks.block );
      decmat   := Decomposition( ibr, rest, "nonnegative" );
      nccmod   := Length( decmat[1] );
      for k in [ 1 .. Length( ordchars ) ] do
        if IsInt( ordchars[k] ) then
          ordchars[k]:= [ ordchars[k] ];
        fi;
      od;
      MakeImmutable( ordchars );

      for k in [ 1 .. Length( pblocks.defect ) ] do

        modchars:= Filtered( [ 1 .. nccmod ],
                             j -> ForAny( ordchars[k],
                                          i -> decmat[i][j] <> 0 ) );
        MakeImmutable( modchars );

        modblocks[k]:= rec( defect   := pblocks.defect[k],
                            ordchars := ordchars[k],
                            modchars := modchars );

      od;

    fi;

    # Return the blocks information.
    return modblocks;
    end );


#############################################################################
##
#M  DecompositionMatrix( <modtbl> )
##
InstallMethod( DecompositionMatrix,
    "for a Brauer table",
    [ IsBrauerTable ],
    function( modtbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    return Decomposition( List( Irr( modtbl ), ValuesOfClassFunction ),
               RestrictedClassFunctions( ordtbl,
                   List( Irr( ordtbl ), ValuesOfClassFunction ), modtbl ),
               "nonnegative" );
    end );


#############################################################################
##
#M  DecompositionMatrix( <modtbl>, <blocknr> )
##
InstallMethod( DecompositionMatrix,
    "for a Brauer table, and a positive integer",
    [ IsBrauerTable, IsPosInt ],
    function( modtbl, blocknr )

    local ordtbl,    # corresponding ordinary table
          block,     # block information
          fus,       # class fusion from `modtbl' to `ordtbl'
          ordchars,  # restrictions of ord. characters in the block
          modchars;  # Brauer characters in the block

    block:= BlocksInfo( modtbl );

    if blocknr <= Length( block ) then
      block:= block[ blocknr ];
    else
      Error( "<blocknr> must be in the range [ 1 .. ",
             Length( block ), " ]" );
    fi;

    if not IsBound( block.decmat ) then

      if block.defect = 0 then
        block.decmat:= [ [ 1 ] ];
      else
        ordtbl:= OrdinaryCharacterTable( modtbl );
        fus:= GetFusionMap( modtbl, ordtbl );
        ordchars:= List( Irr( ordtbl ){ block.ordchars },
                         chi -> ValuesOfClassFunction( chi ){ fus } );
        modchars:= List( Irr( modtbl ){ block.modchars },
                         ValuesOfClassFunction );
        block.decmat:= Decomposition( modchars, ordchars, "nonnegative" );
      fi;
      MakeImmutable( block.decmat );

    fi;

    return block.decmat;
    end );


#############################################################################
##
#F  LaTeXStringDecompositionMatrix( <modtbl>[, <blocknr>][, <options>] )
##
InstallGlobalFunction( LaTeXStringDecompositionMatrix, function( arg )

    local modtbl,        # Brauer character table, first argument
          blocknr,       # number of the block, optional second argument
          options,       # record with labels, optional third argument
          decmat,        # decomposition matrix
          block,         # block information on `modtbl'
          collabels,     # indices of Brauer characters
          rowlabels,     # indices of ordinary characters
          phi,           # string used for Brauer characters
          chi,           # string used for ordinary irreducibles
          hlines,        # explicitly wanted horizontal lines
          ulc,           # text for the upper left corner
          r,
          k,
          n,
          rowportions,
          colportions,
          str,           # string containing the text
          i,             # loop variable
          val;           # one value in the matrix

    # Get and check the arguments.
    if   Length( arg ) = 2 and IsBrauerTable( arg[1] )
                           and IsRecord( arg[2] ) then

      options := arg[2];

    elif Length( arg ) = 2 and IsBrauerTable( arg[1] )
                           and IsInt( arg[2] ) then

      blocknr := arg[2];
      options := rec();

    elif Length( arg ) = 3 and IsBrauerTable( arg[1] )
                           and IsInt( arg[2] )
                           and IsRecord( arg[3] ) then

      blocknr := arg[2];
      options := arg[3];

    elif Length( arg ) = 1 and IsBrauerTable( arg[1] ) then

      options := rec();

    else
      Error( "usage: LatexStringDecompositionMatrix(",
             " <modtbl>[, <blocknr>][, <options>] )" );
    fi;

    # Compute the decomposition matrix.
    modtbl:= arg[1];
    if IsBound( options.decmat ) then
      decmat:= options.decmat;
    elif IsBound( blocknr ) then
      decmat:= DecompositionMatrix( modtbl, blocknr );
    else
      decmat:= DecompositionMatrix( modtbl );
    fi;

    # Choose default labels if necessary.
    rowportions:= [ [ 1 .. Length( decmat ) ] ];
    colportions:= [ [ 1 .. Length( decmat[1] ) ] ];

    phi:= "{\\tt Y}";
    chi:= "{\\tt X}";

    hlines:= [];
    ulc:= "";

    # Construct the labels if necessary.
    if IsBound( options.phi ) then
      phi:= options.phi;
    fi;
    if IsBound( options.chi ) then
      chi:= options.chi;
    fi;
    if IsBound( options.collabels ) then
      collabels:= options.collabels;
      if ForAll( collabels, IsInt ) then
        collabels:= List( collabels,
            i -> Concatenation( phi, "_{", String(i), "}" ) );
      fi;
    fi;
    if IsBound( options.rowlabels ) then
      rowlabels:= options.rowlabels;
      if ForAll( rowlabels, IsInt ) then
        rowlabels:= List( rowlabels,
            i -> Concatenation( chi, "_{", String(i), "}" ) );
      fi;
    fi;

    # Distribute to row and column portions if necessary.
    if IsBound( options.nrows ) then
      if IsInt( options.nrows ) then
        r:= options.nrows;
        n:= Length( decmat );
        k:= Int( n / r );
        rowportions:= List( [ 1 .. k ], i -> [ 1 .. r ] + (i-1)*r );
        if n > k*r then
          Add( rowportions, [ k*r + 1 .. n ] );
        fi;
      else
        rowportions:= options.nrows;
      fi;
    fi;
    if IsBound( options.ncols ) then
      if IsInt( options.ncols ) then
        r:= options.ncols;
        n:= Length( decmat[1] );
        k:= Int( n / r );
        colportions:= List( [ 1 .. k ], i -> [ 1 .. r ] + (i-1)*r );
        if n > k*r then
          Add( colportions, [ k*r + 1 .. n ] );
        fi;
      else
        colportions:= options.ncols;
      fi;
    fi;

    # Check for horizontal lines.
    if IsBound( options.hlines ) then
      hlines:= options.hlines;
    fi;

    # Check for text in the upper left corner.
    if IsBound( options.ulc ) then
      ulc:= options.ulc;
    fi;

    Add( hlines, Length( decmat ) );

    # Construct the labels if they are still missing.
    if not IsBound( collabels ) then

      if IsBound( blocknr ) then
        block     := BlocksInfo( modtbl )[ blocknr ];
        collabels := List( block.modchars, String );
      else
        collabels := List( [ 1 .. Length( decmat[1] ) ], String );
      fi;
      collabels:= List( collabels, i -> Concatenation( phi,"_{",i,"}" ) );

    fi;
    if not IsBound( rowlabels ) then

      if IsBound( blocknr ) then
        block     := BlocksInfo( modtbl )[ blocknr ];
        rowlabels := List( block.ordchars, String );
      else
        rowlabels := List( [ 1 .. Length( decmat ) ], String );
      fi;
      rowlabels:= List( rowlabels, i -> Concatenation( chi,"_{",i,"}" ) );

    fi;

    # Construct the string.
    str:= "";

    for r in rowportions do

      for k in colportions do

        # Append the header of the array.
        Append( str,  "\\[\n" );
        Append( str,  "\\begin{array}{r|" );
        for i in k do
          Add( str, 'r' );
        od;
        Append( str, "} \\hline\n" );

        # Append the text in the upper left corner.
        if not IsEmpty( ulc ) then
          if r = rowportions[1] and k = colportions[1] then
            Append( str, ulc );
          else
            Append( str, Concatenation( "(", ulc, ")" ) );
          fi;
        fi;

        # The first line contains the Brauer character numbers.
        for i in collabels{ k } do
          Append( str, " & " );
          Append( str, String( i ) );
          Append( str, "\n" );
        od;
        Append( str, " \\rule[-7pt]{0pt}{20pt} \\\\ \\hline\n" );

        # Append the matrix itself.
        for i in r do

          # The first column contains the numbers of ordinary irreducibles.
          Append( str, String( rowlabels[i] ) );

          for val in decmat[i]{ k } do
            Append( str, " & " );
            if val = 0 then
              Append( str, "." );
            else
              Append( str, String( val ) );
            fi;
          od;

          if i = r[1] or i-1 in hlines then
            Append( str, " \\rule[0pt]{0pt}{13pt}" );
          fi;
          if i = r[ Length( r ) ] or i in hlines then
            Append( str, " \\rule[-7pt]{0pt}{5pt}" );
          fi;

          Append( str, " \\\\\n" );

          if i in hlines then
            Append( str, "\\hline\n" );
          fi;

        od;

        # Append the tail of the array
        Append( str,  "\\end{array}\n" );
        Append( str,  "\\]\n\n" );

      od;

    od;

    Unbind( str[ Length( str ) ] );
    ConvertToStringRep( str );

    # Return the result.
    return str;
end );


#############################################################################
##
##  7. Other Operations for Character Tables
##


#############################################################################
##
#M  IsInternallyConsistent( <tbl> ) . . . . . for an ordinary character table
##
##  Check consistency of information in the head of the character table
##  <tbl>, and check if the first orthogonality relation is satisfied.
##
#T also check the interface between table and group if the classes are stored?
##
InstallMethod( IsInternallyConsistent,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    function( tbl )

    local flag,            # `true' if no inconsistency occurred yet
          centralizers,
          order,
          nccl,
          classes,
          orders,
          i, j,
          powermap,
          comp,
          characters,
          map,
          row,
          sum;

    flag:= true;

    # Check that `Size', `SizesCentralizers', `SizesConjugacyClasses'
    # are consistent.
    centralizers:= SizesCentralizers( tbl );
    order:= centralizers[1];
    if HasSize( tbl ) then
      if Size( tbl ) <> order then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl, "):\n",
              "#I  centralizer of identity not equal to group order" );
        flag:= false;
      fi;
    fi;

    nccl:= Length( centralizers );
    if HasSizesConjugacyClasses( tbl ) then
      classes:= SizesConjugacyClasses( tbl );
      if classes <> List( centralizers, x -> order / x ) then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl, "):\n",
              "#I  centralizers and class lengths inconsistent" );
        flag:= false;
      fi;
      if Length( classes ) <> nccl then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl, "):\n",
              "#I  number of classes and centralizers inconsistent" );
        flag:= false;
      fi;
    else
      classes:= List( centralizers, x -> order / x );
    fi;

    if Sum( classes, 0 ) <> order then
      Info( InfoWarning, 1,
            "IsInternallyConsistent(", tbl, "):\n",
            "#I  sum of class lengths not equal to group order" );
      flag:= false;
    fi;

    if HasOrdersClassRepresentatives( tbl ) then
      orders:= OrdersClassRepresentatives( tbl );
      if nccl <> Length( orders ) then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl, "):\n",
              "#I  number of classes and orders inconsistent" );
        flag:= false;
      else
        for i in [ 1 .. nccl ] do
          if centralizers[i] mod orders[i] <> 0 then
            Info( InfoWarning, 1,
                  "IsInternallyConsistent(", tbl, "):\n",
                  "#I  not all representative orders divide ",
                  "the corresponding centralizer order" );
            flag:= false;
          fi;
        od;
      fi;
    fi;

    if HasComputedPowerMaps( tbl ) then

      powermap:= ComputedPowerMaps( tbl );
      for map in Set( powermap ) do
        if nccl <> Length( map ) then
          Info( InfoWarning, 1,
                "IsInternallyConsistent(", tbl, "):\n",
                "#I  lengths of power maps and classes inconsistent" );
          flag:= false;
        fi;
      od;

      # If the power maps of all prime divisors of the order are stored,
      # check if they are consistent with the representative orders.
      if     IsBound( orders )
         and ForAll( Set( FactorsInt( order ) ), x -> IsBound(powermap[x]) )
         and orders <> ElementOrdersPowerMap( powermap ) then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl, "):\n",
              "#I  representative orders and power maps inconsistent" );
        flag:= false;
      fi;

      # Check that the composed power maps are consistent with the power maps
      # for primes.
      for i in [ 2 .. Length( powermap ) ] do
        if IsBound( powermap[i] ) and not IsPrimeInt( i ) then
          comp:= PowerMapByComposition( tbl, i );
          if comp <> fail and comp <> powermap[i] then
            Info( InfoWarning, 1,
                  "IsInternallyConsistent(", tbl, "):\n",
                  "#I  ", Ordinal( i ),
                  " power map inconsistent with composition from others" );
            flag:= false;
          fi;
        fi;
      od;

    fi;

    # From here on, we check the irreducible characters.
    if flag = false then
      Info( InfoWarning, 1,
            "IsInternallyConsistent(", tbl, "):\n",
            "#I  corrupted table, no test of orthogonality" );
      return false;
    fi;

    if HasIrr( tbl ) then
      characters:= List( Irr( tbl ), ValuesOfClassFunction );
      for i in [ 1 .. Length( characters ) ] do
        row:= [];
        for j in [ 1 .. Length( characters[i] ) ] do
          row[j]:= GaloisCyc( characters[i][j], -1 ) * classes[j];
        od;
        for j in [ 1 .. i ] do
          sum:= row * characters[j];
          if ( i = j and sum <> order ) or ( i <> j and sum <> 0 ) then
            flag:= false;
            Info( InfoWarning, 1,
                  "IsInternallyConsistent(", tbl, "):\n",
                  "#I  Scpr( ., X[", i, "], X[", j, "] ) = ", sum / order );
          fi;
        od;
      od;

      if centralizers <> Sum( characters,
                              x -> List( x, y -> y * GaloisCyc(y,-1) ),
                              0 ) then
        flag:= false;
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl, "):\n",
              "#I  centralizer orders inconsistent with irreducibles" );
      fi;

#T what about indicators, p-blocks, computability of power maps?
    fi;

    return flag;
    end );


#############################################################################
##
#M  IsInternallyConsistent( <tbl> ) . . . . . . . . . . .  for a Brauer table
##
##  Check consistency of information in the head of the character table
##  <tbl>,
##  and check necessary conditions on Galois conjugacy.
#T what about tensor products, indicators, p-blocks?
##
InstallMethod( IsInternallyConsistent,
    "for a Brauer table",
    [ IsBrauerTable ],
    function( tbl )

    local flag,            # `true' if no inconsistency occurred yet
          centralizers,
          order,
          nccl,
          classes,
          orders,
          i,
          chi,
          powermap,
          characters,
          prime,
          map;

    flag:= true;

    # Check that `Size', `SizesCentralizers', `SizesConjugacyClasses'
    # are consistent.
    centralizers:= SizesCentralizers( tbl );
    order:= centralizers[1];
    if HasSize( tbl ) then
      if Size( tbl ) <> order then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl, "):\n",
              "#I  centralizer of identity not equal to group order" );
        flag:= false;
      fi;
    fi;

    nccl:= Length( centralizers );
    if HasSizesConjugacyClasses( tbl ) then
      classes:= SizesConjugacyClasses( tbl );
      if classes <> List( centralizers, x -> order / x ) then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl, "):\n",
              "#I  centralizers and class lengths inconsistent" );
        flag:= false;
      fi;
    else
      classes:= List( centralizers, x -> order / x );
    fi;

    if HasOrdersClassRepresentatives( tbl ) then
      orders:= OrdersClassRepresentatives( tbl );
      if nccl <> Length( orders ) then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl, "):\n",
              "#I  number of classes and orders inconsistent" );
        flag:= false;
      else
        for i in [ 1 .. nccl ] do
          if centralizers[i] mod orders[i] <> 0 then
            Info( InfoWarning, 1,
                  "IsInternallyConsistent(", tbl, "):\n",
                  "#I  not all representative orders divide ",
                  "the corresponding centralizer order" );
            flag:= false;
            break;
          fi;
        od;
      fi;
    fi;

    if HasComputedPowerMaps( tbl ) then
      powermap:= ComputedPowerMaps( tbl );
      for map in Set( powermap ) do
        if nccl <> Length( map ) then
          Info( InfoWarning, 1,
                "IsInternallyConsistent(", tbl, "):\n",
                "#I  lengths of power maps and classes inconsistent" );
          flag:= false;
          break;
        fi;
      od;

      # If the power maps of all prime divisors of the order are stored,
      # check if they are consistent with the representative orders.
      if     IsBound( orders )
         and ForAll( Set( FactorsInt( order ) ), x -> IsBound(powermap[x]) )
         and orders <> ElementOrdersPowerMap( powermap ) then
        flag:= false;
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl, "):\n",
              "#I  representative orders and power maps inconsistent" );
      fi;

    fi;

    # From here on, we check the irreducible characters.
    if flag = false then
      Info( InfoWarning, 1,
            "IsInternallyConsistent(", tbl, "):\n",
            "#I  corrupted table, no test of irreducibles" );
      return false;
    fi;

    if HasIrr( tbl ) then
      prime:= UnderlyingCharacteristic( tbl );
      characters:= List( Irr( tbl ), ValuesOfClassFunction );
      for chi in characters do
        if not GaloisCyc( chi, -1 ) in characters then
          flag:= false;
          Info( InfoWarning, 1,
                "IsInternallyConsistent(", tbl, "):\n",
                "#I  irreducibles not closed under complex conjugation" );
          break;
        fi;
        if not GaloisCyc( chi, prime ) in characters then
          flag:= false;
          Info( InfoWarning, 1,
                "IsInternallyConsistent(", tbl, "):\n",
                "#I  irreducibles not closed under Frobenius map" );
          break;
        fi;
      od;
    fi;

    return flag;
    end );


#############################################################################
##
#M  IsPSolvableCharacterTable( <tbl>, <p> )
##
InstallMethod( IsPSolvableCharacterTable,
    "for ord. char. table, and zero (call `IsPSolvableCharacterTableOp')",
    [ IsOrdinaryTable, IsZeroCyc ],
    IsPSolvableCharacterTableOp );

InstallMethod( IsPSolvableCharacterTable,
    "for ord. char. table knowing `IsSolvableCharacterTable', and zero",
    [ IsOrdinaryTable and HasIsSolvableCharacterTable, IsZeroCyc ],
    function( tbl, zero )
    return IsSolvableCharacterTable( tbl );
    end );

InstallMethod( IsPSolvableCharacterTable,
    "for ord.char.table, and pos.int. (call `IsPSolvableCharacterTableOp')",
    [ IsOrdinaryTable, IsPosInt ],
    function( tbl, p )
    local known, erg;

    if not IsPrimeInt( p ) then
      Error( "<p> must be zero or a prime integer" );
    fi;

    known:= ComputedIsPSolvableCharacterTables( tbl );

    # Start storing only after the result has been computed.
    # This avoids errors if a calculation had been interrupted.
    if not IsBound( known[p] ) then
      erg:= IsPSolvableCharacterTableOp( tbl, p );
      known[p]:= erg;
    fi;

    return known[p];
    end );


#############################################################################
##
#M  IsPSolvableCharacterTableOp( <tbl>, <p> )
##
InstallMethod( IsPSolvableCharacterTableOp,
    "for an ordinary character table, an an integer",
    [ IsOrdinaryTable, IsInt ],
    function( tbl, p )
    local nsg,       # list of all normal subgroups
          i,         # loop variable, position in `nsg'
          n,         # one normal subgroup
          posn,      # position of `n' in `nsg'
          size,      # size of `n'
          nextsize,  # size of smallest normal subgroup containing `n'
          classes,   # class lengths
          facts;     # set of prime factors of a chief factor

    nsg:= ClassPositionsOfNormalSubgroups( tbl );

    # Go up a chief series, starting with the trivial subgroup
    i:= 1;
    nextsize:= 1;
    classes:= SizesConjugacyClasses( tbl );

    while i < Length( nsg ) do

      posn:= i;
      n:= nsg[ posn ];
      size:= nextsize;

      # Get the smallest normal subgroup containing `n' \ldots
      i:= posn + 1;
      while not IsSubsetSet( nsg[ i ], n ) do i:= i+1; od;

      # \ldots and its size.
      nextsize:= Sum( classes{ nsg[i] }, 0 );

      facts:= Set( FactorsInt( nextsize / size ) );
      if 1 < Length( facts ) and ( p = 0 or p in facts ) then

        # The chief factor `nsg[i] / n' is not a prime power,
        # and our `p' divides its order.
        return false;

      fi;

    od;
    return true;
    end );


#############################################################################
##
#M  ComputedIsPSolvableCharacterTables( <tbl> )
##
InstallMethod( ComputedIsPSolvableCharacterTables,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    tbl -> [] );


#############################################################################
##
#F  IsClassFusionOfNormalSubgroup( <subtbl>, <fus>, <tbl> )
##
InstallGlobalFunction( IsClassFusionOfNormalSubgroup,
    function( subtbl, fus, tbl )

    local classlen, subclasslen, sums, i;

    # Check the arguments.
    if not ( IsOrdinaryTable( subtbl ) and IsOrdinaryTable( tbl ) ) then
      Error( "<subtbl>, <tbl> must be an ordinary character tables" );
    elif not ( IsList( fus ) and ForAll( fus, IsPosInt ) ) then
      Error( "<fus> must be a list of positive integers" );
    fi;

    classlen:= SizesConjugacyClasses( tbl );
    subclasslen:= SizesConjugacyClasses( subtbl );
    sums:= ListWithIdenticalEntries( NrConjugacyClasses( tbl ), 0 );
    for i in [ 1 .. Length( fus ) ] do
      sums[ fus[i] ]:= sums[ fus[i] ] + subclasslen[i];
    od;
    for i in [ 1 .. Length( sums ) ] do
      if sums[i] <> 0 and sums[i] <> classlen[i] then
        return false;
      fi;
    od;

    return true;
end );


#############################################################################
##
#M  Indicator( <tbl>, <n> )
#M  Indicator( <modtbl>, 2 )
##
InstallMethod( Indicator,
    "for a character table, and a positive integer",
    [ IsCharacterTable, IsPosInt ],
    function( tbl, n )

    local known, erg;

    if IsBrauerTable( tbl ) and n <> 2 then
      TryNextMethod();
    fi;

    known:= ComputedIndicators( tbl );

    # Start storing only after the result has been computed.
    # This avoids errors if a calculation had been interrupted.
    if not IsBound( known[n] ) then
      erg:= IndicatorOp( tbl, Irr( tbl ), n );
      known[n]:= erg;
    fi;

    return known[n];
    end );


#############################################################################
##
#M  Indicator( <tbl>, <characters>, <n> )
##
InstallMethod( Indicator,
    "for a character table, a homogeneous list, and a positive integer",
    [ IsCharacterTable, IsHomogeneousList, IsPosInt ],
    IndicatorOp );


#############################################################################
##
#M  IndicatorOp( <ordtbl>, <characters>, <n> )
#M  IndicatorOp( <modtbl>, <characters>, 2 )
##
InstallMethod( IndicatorOp,
    "for an ord. character table, a hom. list, and a pos. integer",
    [ IsOrdinaryTable, IsHomogeneousList, IsPosInt ],
    function( tbl, characters, n )
    local principal, map;

    principal:= List( [ 1 .. NrConjugacyClasses( tbl ) ], x -> 1 );
    map:= PowerMap( tbl, n );
    return List( characters,
                 chi -> ScalarProduct( tbl, chi{ map }, principal ) );
    end );

InstallMethod( IndicatorOp,
    "for a Brauer character table and <n> = 2",
    [ IsBrauerTable, IsHomogeneousList, IsPosInt ],
    function( modtbl, ibr, n )
    local ordtbl,
          irr,
          ordindicator,
          fus,
          indicator,
          i,
          j,
          odd;

    if   n <> 2 then
      Error( "for Brauer table <modtbl> only for <n> = 2" );
    elif UnderlyingCharacteristic( modtbl ) = 2 then
      Error( "for Brauer table <modtbl> only in odd characteristic" );
    fi;

    ordtbl:= OrdinaryCharacterTable( modtbl );
    irr:= Irr( ordtbl );
    ordindicator:= Indicator( ordtbl, irr, 2 );
    fus:= GetFusionMap( modtbl, ordtbl );

    # compute indicators block by block
    indicator:= [];

    for i in BlocksInfo( modtbl ) do
      if not IsBound( i.decmat ) then
        i.decmat:= Decomposition( ibr{ i.modchars },
                         List( irr{ i.ordchars },
                               x -> x{ fus } ), "nonnegative" );
      fi;
      for j in [ 1 .. Length( i.modchars ) ] do
        if ForAny( ibr[ i.modchars[j] ],
                   x -> not IsInt(x) and GaloisCyc(x,-1) <> x ) then

          # indicator of a Brauer character is 0 iff it has
          # at least one nonreal value
          indicator[ i.modchars[j] ]:= 0;

        else

          # indicator is equal to the indicator of any real ordinary
          # character containing it as constituent, with odd multiplicity
          odd:= Filtered( [ 1 .. Length( i.decmat ) ],
                          x -> i.decmat[x][j] mod 2 <> 0 );
          odd:= List( odd, x -> ordindicator[ i.ordchars[x] ] );
          indicator[ i.modchars[j] ]:= First( odd, x -> x <> 0 );

        fi;
      od;
    od;

    return indicator;
    end );


#############################################################################
##
#M  ComputedIndicators( <tbl> )
##
InstallMethod( ComputedIndicators,
    "for a character table",
    [ IsCharacterTable ],
    tbl -> [] );


#############################################################################
##
#F  NrPolyhedralSubgroups( <tbl>, <c1>, <c2>, <c3>)  . # polyhedral subgroups
##
InstallGlobalFunction( NrPolyhedralSubgroups, function(tbl, c1, c2, c3)
    local orders, res, ord;

    orders:= OrdersClassRepresentatives( tbl );

    if orders[c1] = 2 then
       res:= ClassMultiplicationCoefficient(tbl, c1, c2, c3)
             * SizesConjugacyClasses( tbl )[c3];
       if orders[c2] = 2 then
          if orders[c3] = 2 then   # V4
             ord:= Length(Set([c1, c2, c3]));
             if ord = 2 then
                res:= res * 3;
             elif ord = 3 then
                res:= res * 6;
             fi;
             res:= res / 6;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "V4");
          elif orders[c3] > 2 then   # D2n
             ord:= orders[c3];
             if c1 <> c2 then
                res:= res * 2;
             fi;
             res:= res * Length(ClassOrbit(tbl,c3))/(ord*Phi(ord));
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res,
                        type:= Concatenation("D" ,String(2*ord)));
          fi;
       elif orders[c2] = 3 then
          if orders[c3] = 3 then   # A4
             res:= res * Length(ClassOrbit(tbl, c3)) / 24;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "A4");
          elif orders[c3] = 4 then   # S4
             res:= res / 24;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "S4");
          elif orders[c3] = 5 then   # A5
             res:= res * Length(ClassOrbit(tbl, c3)) / 120;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "A5");
          fi;
       fi;
    fi;
end );


#############################################################################
##
#M  ClassMultiplicationCoefficient( <ordtbl>, <c1>, <c2>, <c3> )
##
InstallMethod( ClassMultiplicationCoefficient,
    "for an ord. table, and three pos. integers",
    [ IsOrdinaryTable, IsPosInt, IsPosInt, IsPosInt ], 10,
    function( ordtbl, c1, c2, c3 )
    local res, chi, char, classes;

    res:= 0;
    for chi in Irr( ordtbl ) do
       char:= ValuesOfClassFunction( chi );
       res:= res + char[c1] * char[c2] * GaloisCyc(char[c3], -1) / char[1];
    od;
    classes:= SizesConjugacyClasses( ordtbl );
    return classes[c1] * classes[c2] * res / Size( ordtbl );
    end );


#############################################################################
##
#F  MatClassMultCoeffsCharTable( <tbl>, <class> )
##
InstallGlobalFunction( MatClassMultCoeffsCharTable, function( tbl, class )
    local nccl;

    nccl:= NrConjugacyClasses( tbl );
    return List( [ 1 .. nccl ],
                 j -> List( [ 1 .. nccl ],
                 k -> ClassMultiplicationCoefficient( tbl, class, j, k ) ) );
end );


#############################################################################
##
#F  ClassStructureCharTable(<tbl>,<classes>)  . gener. class mult. coefficent
##
InstallGlobalFunction( ClassStructureCharTable, function( tbl, classes )
    local exp;

    exp:= Length( classes ) - 2;
    if exp < 0 then
      Error( "length of <classes> must be at least 2" );
    fi;

    return Sum( Irr( tbl ),
                chi -> Product( chi{ classes }, 1 ) / ( chi[1] ^ exp ),
                0 )
           * Product( SizesConjugacyClasses( tbl ){ classes }, 1 )
           / Size( tbl );
end );


#############################################################################
##
##  8. Creating Character Tables
##


#############################################################################
##
#M  CharacterTable( <G> ) . . . . . . . . . . ordinary char. table of a group
#M  CharacterTable( <G>, <p> )  . . . . . characteristic <p> table of a group
#M  CharacterTable( <ordtbl>, <p> )
##
##  We delegate to `OrdinaryCharacterTable' or `BrauerTable'.
##
InstallMethod( CharacterTable,
    "for a group (delegate to `OrdinaryCharacterTable')",
    [ IsGroup ],
    OrdinaryCharacterTable );

InstallMethod( CharacterTable,
    "for a group, and a prime integer",
    [ IsGroup, IsInt ],
    function( G, p )
    if p = 0 then
      return OrdinaryCharacterTable( G );
    else
      return BrauerTable( OrdinaryCharacterTable( G ), p );
    fi;
    end );

InstallMethod( CharacterTable,
    "for an ordinary table, and a prime integer",
    [ IsOrdinaryTable, IsPosInt ],
    BrauerTable );


#############################################################################
##
#F  CharacterTableFromLibrary( <name>, <param1>, ... )
##
##  The `CharacterTable' methods for a string and optional parameters call
##  `CharacterTableFromLibrary'.
##  We bind this to a dummy function that signals an error.
##
BindGlobal( "CharacterTableFromLibrary", function( arg )
    Error( "sorry, the GAP Character Table Library is not installed" );
    end );


#############################################################################
##
#M  CharacterTable( <name> )  . . . . . . . . . library table with given name
#M  CharacterTable( <series>, <param> )
#M  CharacterTable( <series>, <param1>, <param2> )
##
##  These methods are used in the Character Table Library, where the function
##  `CharacterTableFromLibrary' is replaced by a meaningful function.
##
InstallMethod( CharacterTable,
    "for a string",
    [ IsString ],
    str -> CharacterTableFromLibrary( str ) );

InstallOtherMethod( CharacterTable,
    "for a string and an object",
    [ IsString, IsObject ],
    function( str, obj )
    return CharacterTableFromLibrary( str, obj );
    end );

InstallOtherMethod( CharacterTable,
    "for a string and two objects",
    [ IsString, IsObject, IsObject ],
    function( str, obj1, obj2 )
    return CharacterTableFromLibrary( str, obj1, obj2 );
    end );


#############################################################################
##
#M  BrauerTable( <ordtbl>, <p> )  . . . . . . . . . . . . . <p>-modular table
#M  BrauerTable( <G>, <p> )
##
##  Note that Brauer tables are stored in the ordinary table and not in the
##  group.
##
InstallMethod( BrauerTable,
    "for a group, and a prime (delegate to the ord. table of the group)",
    [ IsGroup, IsPosInt ],
    function( G, p )
    return BrauerTable( OrdinaryCharacterTable( G ), p );
    end );

InstallMethod( BrauerTable,
    "for an ordinary table, and a prime",
    [ IsOrdinaryTable, IsPosInt ],
    function( ordtbl, p )

    local known, erg;

    if not IsPrimeInt( p ) then
      Error( "<p> must be a prime" );
    fi;

    known:= ComputedBrauerTables( ordtbl );

    # Start storing only after the result has been computed.
    # This avoids errors if a calculation had been interrupted.
    if not IsBound( known[p] ) then
      erg:= BrauerTableOp( ordtbl, p );
      known[p]:= erg;
    fi;

    return known[p];
    end );


#############################################################################
##
#M  BrauerTableOp( <ordtbl>, <p> )  . . . . . . . . . . . . <p>-modular table
##
##  Note that we do not need a method for the first argument a group,
##  since `BrauerTable' delegates this to the ordinary table.
##
##  This is a ``last resort'' method that returns `fail' if <ordtbl> is not
##  <p>-solvable.
##  (It assumes that a method for library tables is of higher rank.)
##
InstallMethod( BrauerTableOp,
    "for ordinary character table, and positive integer",
    [ IsOrdinaryTable, IsPosInt ],
    function( tbl, p )
    local result, modtbls, id, fusions, pos, source;

    result:= fail;

    if IsPSolvableCharacterTable( tbl, p ) then
      return CharacterTableRegular( tbl, p );
    elif HasFactorsOfDirectProduct( tbl ) then
      modtbls:= List( FactorsOfDirectProduct( tbl ),
                      t -> BrauerTable( t, p ) );
      if not fail in modtbls then
        result:= CallFuncList( CharacterTableDirectProduct, modtbls );
        id:= Identifier( OrdinaryCharacterTable( result ) );
        ResetFilterObj( result, HasOrdinaryCharacterTable );
        SetOrdinaryCharacterTable( result, tbl );
        fusions:= ComputedClassFusions( result );
        pos:= PositionProperty( fusions, x -> x.name = id );
        fusions[ pos ]:= ShallowCopy( fusions[ pos ] );
        fusions[ pos ].name:= Identifier( tbl );
        MakeImmutable( fusions[ pos ] );

        # Adjust the identifier.
        ResetFilterObj( result, HasIdentifier );
        SetIdentifier( result,
            Concatenation( Identifier( tbl ), "mod", String( p ) ) );
      fi;
    elif HasSourceOfIsoclinicTable( tbl ) then
      # Compute the isoclinic table of the Brauer table of the source table,
      # i.e., use the alternative path in the commutative diagram that is
      # given by forming the Brauer table and the isoclinic table.
      source:= SourceOfIsoclinicTable( tbl );
#T sort w.r.t. class permutation!
      modtbls:= BrauerTable( source[1], p );
      if modtbls <> fail then
        return CharacterTableIsoclinic( modtbls, source[2], source[3], tbl );
      fi;
    fi;

    return result;
    end );


#############################################################################
##
#M  ComputedBrauerTables( <ordtbl> )  . . . . . . for an ord. character table
##
InstallMethod( ComputedBrauerTables,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    ordtbl -> [] );


#############################################################################
##
#F  CharacterTableRegular( <ordtbl>, <p> )  . restriction to <p>-reg. classes
##
InstallGlobalFunction( CharacterTableRegular,
    function( ordtbl, prime )

    local fusion,
          inverse,
          orders,
          i,
          regular,
          power;

    if not IsPrimeInt( prime ) then
      Error( "<prime> must be a prime" );
    elif IsBrauerTable( ordtbl ) then
      Error( "<ordtbl> is already a Brauer table" );
    fi;

    fusion:= [];
    inverse:= [];
    orders:= OrdersClassRepresentatives( ordtbl );
    for i in [ 1 .. Length( orders ) ] do
      if orders[i] mod prime <> 0 then
        Add( fusion, i );
        inverse[i]:= Length( fusion );
      fi;
    od;

    regular:= rec(
       Identifier                 := Concatenation( Identifier( ordtbl ),
                                         "mod", String( prime ) ),
       UnderlyingCharacteristic   := prime,
       Size                       := Size( ordtbl ),
       OrdersClassRepresentatives := orders{ fusion },
       SizesCentralizers          := SizesCentralizers( ordtbl ){ fusion },
       ComputedPowerMaps          := [],
       OrdinaryCharacterTable     := ordtbl
      );

    # Transfer known power maps.
    # (Missing power maps can be computed later.)
    power:= ComputedPowerMaps( ordtbl );
    for i in [ 1 .. Length( power ) ] do
      if IsBound( power[i] ) then
        regular.ComputedPowerMaps[i]:= inverse{ power[i]{ fusion } };
      fi;
    od;

    regular:= ConvertToCharacterTableNC( regular );
    StoreFusion( regular, rec( map:= fusion, type:= "choice" ), ordtbl );

    return regular;
    end );


#############################################################################
##
#F  ConvertToCharacterTable( <record> ) . . . . create character table object
#F  ConvertToCharacterTableNC( <record> ) . . . create character table object
##
InstallGlobalFunction( ConvertToCharacterTableNC, function( record )

    local names,    # list of component names
          i;        # loop over `SupportedCharacterTableInfo'

    names:= RecNames( record );

    # Make the object.
    if not IsBound( record.UnderlyingCharacteristic ) then
      Error( "<record> needs component `UnderlyingCharacteristic'" );
    elif record.UnderlyingCharacteristic = 0 then
      Objectify( NewType( NearlyCharacterTablesFamily,
                          IsOrdinaryTable and IsAttributeStoringRep ),
                 record );
    else
      Objectify( NewType( NearlyCharacterTablesFamily,
                          IsBrauerTable and IsAttributeStoringRep ),
                 record );
    fi;

    # Enter the properties and attributes.
    for i in [ 1, 4 .. Length( SupportedCharacterTableInfo ) - 2 ] do
      if     SupportedCharacterTableInfo[ i+1 ] in names
         and SupportedCharacterTableInfo[ i+1 ] <> "Irr" then
        Setter( SupportedCharacterTableInfo[i] )( record,
            record!.( SupportedCharacterTableInfo[ i+1 ] ) );
      fi;
    od;

    # Make the lists of character values into character objects.
    if "Irr" in names then
      SetIrr( record, List( record!.Irr,
                            chi -> Character( record, chi ) ) );
    fi;

    # Return the object.
    return record;
end );

InstallGlobalFunction( ConvertToCharacterTable, function( record )

    # Check the argument record.

    if not IsBound( record!.UnderlyingCharacteristic ) then
      Info( InfoCharacterTable, 1,
            "no underlying characteristic stored" );
      return fail;
    fi;

    # If a group is entered, check that the interface between group
    # and table is complete.
    if IsBound( record!.UnderlyingGroup ) then
      if not IsBound( record!.ConjugacyClasses ) then
        Info( InfoCharacterTable, 1,
              "group stored but no conjugacy classes!" );
        return fail;
      elif not IsBound( record!.IdentificationOfClasses ) then
        Info( InfoCharacterTable, 1,
              "group stored but no identification of classes!" );
        return fail;
      fi;
    fi;

#T more checks!

    # Call the no-check-function.
    return ConvertToCharacterTableNC( record );
end );


#############################################################################
##
#F  ConvertToLibraryCharacterTableNC( <record> )
##
InstallGlobalFunction( ConvertToLibraryCharacterTableNC, function( record )

    # Make the object.
    if IsBound( record.isGenericTable ) and record.isGenericTable then
      Objectify( NewType( NearlyCharacterTablesFamily,
                          IsGenericCharacterTableRep ),
                 record );
    else
      ConvertToCharacterTableNC( record );
      SetFilterObj( record, IsLibraryCharacterTableRep );
    fi;

    # Return the object.
    return record;
end );


#############################################################################
##
##  9. Printing Character Tables
##


#############################################################################
##
#M  ViewObj( <tbl> )  . . . . . . . . . . . . . . . . . for a character table
##
InstallMethod( ViewObj,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    function( tbl )
    Print( "CharacterTable( " );
    if HasUnderlyingGroup( tbl ) then
      View( UnderlyingGroup( tbl ) );
    else
      View( Identifier( tbl ) );
    fi;
    Print(  " )" );
    end );

InstallMethod( ViewObj,
    "for a Brauer table",
    [ IsBrauerTable ],
    function( tbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( tbl );
    Print( "BrauerTable( " );
    if HasUnderlyingGroup( ordtbl ) then
      View( UnderlyingGroup( ordtbl ) );
    else
      View( Identifier( ordtbl ) );
    fi;
    Print( ", ", UnderlyingCharacteristic( tbl ), " )" );
    end );


#############################################################################
##
#M  PrintObj( <tbl> ) . . . . . . . . . . . . . . . . . for a character table
##
InstallMethod( PrintObj,
    "for an ordinary table",
    [ IsOrdinaryTable ],
    function( tbl )
    if HasUnderlyingGroup( tbl ) then
      Print( "CharacterTable( ", UnderlyingGroup( tbl ), " )" );
    else
      Print( "CharacterTable( \"", Identifier( tbl ), "\" )" );
    fi;
    end );

InstallMethod( PrintObj,
    "for a Brauer table",
    [ IsBrauerTable ],
    function( tbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( tbl );
    if HasUnderlyingGroup( ordtbl ) then
      Print( "BrauerTable( ", UnderlyingGroup( ordtbl ), ", ",
             UnderlyingCharacteristic( tbl ), " )" );
    else
      Print( "BrauerTable( \"", Identifier( ordtbl ),
             "\", ", UnderlyingCharacteristic( tbl ), " )" );
    fi;
    end );


#############################################################################
##
#F  CharacterTableDisplayStringEntryDefault( <entry>, <data> )
##
InstallGlobalFunction( CharacterTableDisplayStringEntryDefault,
    function( entry, data )
    local irrstack, irrnames, i, val, name, n, letters, ll;

    if entry = 0 then
      return ".";
    elif IsCyc( entry ) and not IsInt( entry ) then

      # find shorthand for cyclo
      irrstack:= data.irrstack;
      irrnames:= data.irrnames;
      for i in [ 1 .. Length( irrstack ) ] do
        if entry = irrstack[i] then
          return irrnames[i];
        elif entry = -irrstack[i] then
          return Concatenation( "-", irrnames[i] );
        fi;
        val:= GaloisCyc( irrstack[i], -1 );
        if entry = val then
          return Concatenation( "/", irrnames[i] );
        elif entry = -val then
          return Concatenation( "-/", irrnames[i] );
        fi;
        val:= StarCyc( irrstack[i] );
        if entry = val then
          return Concatenation( "*", irrnames[i] );
        elif -entry = val then
          return Concatenation( "-*", irrnames[i] );
        fi;
        i:= i+1;
      od;
      Add( irrstack, entry );

      # Create a new name for the irrationality.
      name:= "";
      n:= Length( irrstack );
      letters:= data.letters;
      ll:= Length( letters );
      while 0 < n do
        name:= Concatenation( letters[(n-1) mod ll + 1], name );
        n:= QuoInt(n-1, ll);
      od;
      Add( irrnames, name );
      return irrnames[ Length( irrnames ) ];

    elif    ( IsList( entry ) and not IsString( entry ) )
         or IsUnknown( entry ) then
      return "?";
    else
      return String( entry );
    fi;
end );


#############################################################################
##
#F  CharacterTableDisplayStringEntryDataDefault( <tbl> )
##
InstallGlobalFunction( CharacterTableDisplayStringEntryDataDefault,
    tbl -> rec( irrstack := [],
                irrnames := [],
                letters  := [ "A","B","C","D","E","F","G","H","I","J","K",
                              "L","M","N","O","P","Q","R","S","T","U","V",
                              "W","X","Y","Z" ] ) );


#############################################################################
##
#F  CharacterTableDisplayPrintLegendDefault( <data> )
##
InstallGlobalFunction( CharacterTableDisplayPrintLegendDefault,
    function( data )
    local irrstack, irrnames, i, q;

    irrstack:= data.irrstack;
    if not IsEmpty( irrstack ) then
      irrnames:= data.irrnames;
      Print( "\n" );
    fi;
    for i in [1..Length(irrstack)] do
      Print( irrnames[i], " = ", irrstack[i], "\n" );
      q:= Quadratic( irrstack[i] );
      if q <> fail then
        Print( "  = ", q.display, " = ", q.ATLAS, "\n" );
      fi;
    od;
end );


#############################################################################
##
#M  Display( <tbl> )  . . . . . . . . . . . . .  for a nearly character table
#M  Display( <tbl>, <record> )
##
InstallMethod( Display,
    "for a nearly character table",
    [ IsNearlyCharacterTable ],
    function( tbl )
    Display( tbl, rec() );
    end );

InstallMethod( Display,
    "for a nearly character table with display options",
    [ IsNearlyCharacterTable and HasDisplayOptions ],
    function( tbl )
    Display( tbl, DisplayOptions( tbl ) );
    end );

InstallOtherMethod( Display,
    "for a nearly character table, and a list",
    [ IsNearlyCharacterTable, IsList ],
    function( tbl, list )
    Display( tbl, rec( chars:= list ) );
    end );

InstallOtherMethod( Display,
    "for a nearly character table, and a record",
    [ IsNearlyCharacterTable, IsRecord ],
    function( tbl, options )
    local i, j,              # loop variables
          chars,             # list of characters
          cnr,               # list of character numbers
          cletter,           # character name
          classes,           # list of classes
          powermap,          # list of primes
          centralizers,      # boolean
          cen,               # factorized centralizers
          fak,               # factorization
          prime,             # loop over primes
          primes,            # prime factors of order
          prin,              # column widths
          nam,               # classnames
          col,               # number of columns already printed
          acol,              # nuber of columns on next page
          len,               # width of next page
          ncols,             # total number of columns
          linelen,           # line length
          q,                 # quadratic cyc / powermap entry
          indicator,         # list of primes
          indic,             # indicators
          iw,                # width of indicator column
          colWidth,          # local function
          stringEntry,       # local function
          stringEntryData,   # data accessed by `stringEntry'
          printLegend,       # local function
          cc,                # column number
          charnames,         # list of character names
          charvals,          # matrix of strings of character values
          tbl_powermap,
          tbl_centralizers;

    # compute the width of column `col'
    colWidth:= function( col )
       local len, width;

       # the class name should fit into the column
       width:= Length( nam[col] );

       # the class names of power classes should fit into the column
       for i in powermap do
         len:= tbl_powermap[i][ col ];
         if IsInt( len ) then
           len:= Length( nam[ len ] );
           if len > width then
             width:= len;
           fi;
         fi;
       od;

       # each character value should fit into the column
       for i in [ 1 .. Length( cnr ) ] do
         len:= Length( charvals[i][ col ] );
         if len > width then
           width:= len;
         fi;
       od;

       # at least one blank should separate the column entries
       return width + 1;

    end;

    # function (of one or two arguments) to display a single entry
    if   IsBound( options.StringEntry ) then
      stringEntry:= options.StringEntry;
    else
      stringEntry:= CharacterTableDisplayStringEntryDefault;
    fi;
    if IsBound( options.StringEntryData ) then
      stringEntryData:= options.StringEntryData( tbl );
    else
      stringEntryData:= CharacterTableDisplayStringEntryDataDefault( tbl );
    fi;
    if IsBound( options.PrintLegend ) then
      printLegend:= options.PrintLegend;
    else
      printLegend:= CharacterTableDisplayPrintLegendDefault;
    fi;

    # default:
    # options
    cletter:= "X";

    # choice of characters
    if IsBound( options.chars ) then
       if IsCyclotomicCollection( options.chars ) then
          cnr:= options.chars;
          chars:= List( Irr( tbl ){ cnr }, ValuesOfClassFunction );
       elif IsInt( options.chars ) then
          cnr:= [ options.chars ];
          chars:= List( Irr( tbl ){ cnr }, ValuesOfClassFunction );
       elif IsHomogeneousList( options.chars ) then
          chars:= options.chars;
          cletter:= "Y";
          cnr:= [ 1 .. Length( chars ) ];
       else
          chars:= [];
       fi;
    else
      chars:= List( Irr( tbl ), ValuesOfClassFunction );
      cnr:= [ 1 .. Length( chars ) ];
    fi;

    if IsBound( options.letter ) and Length( options.letter ) = 1 then
       cletter:= options.letter;
    fi;

    # choice of classes
    if IsBound( options.classes ) then
      if IsInt( options.classes ) then
        classes:= [ options.classes ];
      else
        classes:= options.classes;
      fi;
    else
      classes:= [ 1 .. NrConjugacyClasses( tbl ) ];
    fi;

    # choice of power maps
    tbl_powermap:= ComputedPowerMaps( tbl );
    powermap:= Filtered( [ 2 .. Length( tbl_powermap ) ],
                         x -> IsBound( tbl_powermap[x] ) );
    if IsBound( options.powermap ) then
       if IsInt( options.powermap ) then
          IntersectSet( powermap, [ options.powermap ] );
       elif IsList( options.powermap ) then
          IntersectSet( powermap, options.powermap );
       elif options.powermap = false then
          powermap:= [];
       fi;
    fi;

    # print factorized centralizer orders?
    centralizers:=    not IsBound( options.centralizers )
                   or options.centralizers;

    # print Frobenius-Schur indicators?
    indicator:= [];
    if     IsBound( options.indicator )
       and not ( IsBound( options.chars ) and IsMatrix( options.chars ) ) then
       if options.indicator = true then
          indicator:= [2];
       elif IsRowVector( options.indicator ) then
          indicator:= Set( Filtered( options.indicator, IsPosInt ) );
       fi;
    fi;

    # (end of options handling)

    # line length
    linelen:= SizeScreen()[1] - 1;

    # prepare centralizers
    if centralizers then
       fak:= FactorsInt( Size( tbl ) );
       primes:= Set( fak );
       cen:= [];
       for prime in primes do
          cen[prime]:= [ Number( fak, x -> x = prime ) ];
       od;
    fi;

    # prepare classnames
    nam:= ClassNames( tbl );

    # prepare character names
    if HasCharacterNames( tbl ) and not IsBound( options.chars ) then
      charnames:= CharacterNames( tbl );
    else
      charnames:= [];
      for i in [ 1 .. Length( cnr ) ] do
        charnames[i]:= Concatenation( cletter, ".", String( cnr[i] ) );
      od;
    fi;

    # prepare indicator
    iw:= [0];
    if indicator <> [] and not HasComputedIndicators( tbl ) then
       indicator:= [];
    fi;
    if indicator <> [] then
       indic:= [];
       for i in indicator do
          if IsBound( ComputedIndicators( tbl )[i] ) then
            indic[i]:= [];
            for j in cnr do
              indic[i][j]:= ComputedIndicators( tbl )[i][j];
            od;

            if i = 2 then
              iw[i]:= 2;
            else
              iw[i]:= Maximum( Length(String(Maximum(Set(indic[i])))),
                               Length(String(Minimum(Set(indic[i])))),
                               Length(String(i)) )+1;
            fi;
            iw[1]:= iw[1] + iw[i];
          fi;
       od;
       iw[1]:= iw[1] + 1;
       indicator:= Filtered( indicator, x-> IsBound( indic[x] ) );
    fi;

    if Length( cnr ) = 0 then
      prin:= [ 3 ];
    else
      prin:= [ Maximum( List( charnames, Length ) ) + 3 ];
    fi;

    # prepare list for strings of character values
    charvals:= List( chars, x -> [] );

    # total number of columns
    ncols:= Length(classes) + 1;

    # number of columns already displayed
    col:= 1;

    # A character table has a name.
    Print( Identifier( tbl ), "\n" );

    while col < ncols do

       # determine number of cols for next page
       acol:= 0;
       if indicator <> [] then
          prin[1]:= prin[1] + iw[1];
       fi;
       len:= prin[1];
       while col+acol < ncols and len < linelen do
          acol:= acol + 1;
          if Length(prin) < col + acol then
             cc:= classes[ col + acol - 1 ];
             for i in [ 1 .. Length( cnr ) ] do
               charvals[i][ cc ]:= stringEntry( chars[i][ cc ],
                                                stringEntryData );
             od;
             prin[col + acol]:= colWidth( classes[col + acol - 1] );
          fi;
          len:= len + prin[col+acol];
       od;
       if len >= linelen then
          acol:= acol-1;
       fi;

       # Check whether we are able to print at least one column.
       if acol = 0 then
         Error( "line length too small (perhaps resize with `SizeScreen')" );
       fi;

       # centralizers
       if centralizers then
          Print( "\n" );
          tbl_centralizers:= SizesCentralizers( tbl );
          for i in [col..col+acol-1] do
             fak:= FactorsInt( tbl_centralizers[classes[i]] );
             for prime in Set( fak ) do
                cen[prime][i]:= Number( fak, x -> x = prime );
             od;
          od;
          for j in [1..Length(cen)] do
             if IsBound(cen[j]) then
                for i in [col..col+acol-1] do
                   if not IsBound(cen[j][i]) then
                      cen[j][i]:= ".";
                   fi;
                od;
             fi;
          od;

          for prime in primes do
             Print( FormattedString( prime, prin[1] ) );
             for j in [1..acol] do
               Print( FormattedString( cen[prime][col+j-1], prin[col+j] ) );
             od;
             Print( "\n" );
          od;
       fi;

       # class names
       Print( "\n" );
       Print( FormattedString( "", prin[1] ) );
       for i in [ 1 .. acol ] do
         Print( FormattedString( nam[classes[col+i-1]], prin[col+i] ) );
       od;

       # power maps
       for i in powermap do
          Print("\n");
          Print( FormattedString( Concatenation( String(i), "P" ),
                                  prin[1] ) );
          for j in [1..acol] do
             q:= tbl_powermap[i][classes[col+j-1]];
             if IsInt(q) then
                Print( FormattedString( nam[q], prin[col+j] ) );
             else
                Print( FormattedString( "?", prin[col+j] ) );
             fi;
          od;
       od;

       # empty column resp. indicators
       Print( "\n" );
       if indicator <> [] then
          prin[1]:= prin[1] - iw[1];
          Print( FormattedString( "", prin[1] ) );
          for i in indicator do
             Print( FormattedString( i, iw[i] ) );
          od;
       fi;

       # the characters
       for i in [1..Length(chars)] do

          Print( "\n" );

          # character name
          Print( FormattedString( charnames[i], -prin[1] ) );

          # indicators
          for j in indicator do
             if IsBound(indic[j][cnr[i]]) then
                if j = 2 then
                   if indic[j][cnr[i]] = 0 then
                      Print( FormattedString( "o", iw[j] ) );
                   elif indic[j][cnr[i]] = 1 then
                      Print( FormattedString( "+", iw[j] ) );
                   elif indic[j][cnr[i]] = -1 then
                      Print( FormattedString( "-", iw[j] ) );
                   fi;
                else
                   if indic[j][cnr[i]] = 0 then
                      Print( FormattedString( "0", iw[j] ) );
                   else
                      Print( FormattedString( stringEntry( indic[j][cnr[i]],
                                                           stringEntryData ),
                                              iw[j]) );
                   fi;
                fi;
             else
                Print( FormattedString( "", iw[j] ) );
             fi;
          od;
          if indicator <> [] then
            Print(" ");
          fi;
          for j in [ 1 .. acol ] do
            Print( FormattedString( charvals[i][ classes[col+j-1] ],
                                    prin[ col+j ] ) );
          od;
       od;
       col:= col + acol;
       Print("\n");

       # Indicators are printed only with the first portion of columns.
       indicator:= [];

    od;

    # print legend for cyclos
    printLegend( stringEntryData );

    end );
#T support also Cambridge format!


#############################################################################
##
#F  PrintCharacterTable( <tbl>, <varname> )
##
InstallGlobalFunction( PrintCharacterTable, function( tbl, varname )
    local i, info, j, class, comp;

    # Check the arguments.
    if not IsNearlyCharacterTable( tbl ) then
      Error( "<tbl> must be a nearly character table" );
    elif not IsString( varname ) then
      Error( "<varname> must be a string" );
    fi;

    # Print the preamble.
    Print( varname, ":= function()\n" );
    Print( "local tbl;\n" );
    Print( "tbl:=rec();\n" );

    # Print the values of supported attributes.
    for i in [ 3, 6 .. Length( SupportedCharacterTableInfo ) ] do
      if Tester( SupportedCharacterTableInfo[i-2] )( tbl ) then

        info:= SupportedCharacterTableInfo[i-2]( tbl );

        # The irreducible characters are stored via values lists.
        if SupportedCharacterTableInfo[ i-1 ] = "Irr" then
          info:= List( info, ValuesOfClassFunction );
        fi;

        # Be careful to print strings with enclosing double quotes.
        # (This holds also for *nonempty* strings not in `IsStringRep'.)
        Print( "tbl.", SupportedCharacterTableInfo[ i-1 ], ":=\n" );
        if     IsString( info )
           and ( IsEmptyString( info ) or not IsEmpty( info ) ) then
          info:= ReplacedString( info, "\"", "\\\"" );
          if '\n' in info then
            info:= SplitString( info, "\n" );
            Print( "Concatenation([\n" );
            for j in [ 1 .. Length( info ) - 1 ] do
              Print( "\"", info[j], "\\n\",\n" );
            od;
            Print( "\"", info[ Length( info ) ], "\"\n]);\n" );
          else
            Print( "\"", info, "\";\n" );
          fi;
        elif SupportedCharacterTableInfo[ i-1 ] = "ConjugacyClasses" then
          Print( "[\n" );
          for class in info do
            Print( "ConjugacyClass( tbl.UnderlyingGroup,\n",
                   Representative( class ), "),\n" );
          od;
          Print( "];\n" );
        else
          Print( info, ";\n" );
        fi;

      fi;
    od;

    # Print the values of supported components if available.
    if IsLibraryCharacterTableRep( tbl ) then

      for comp in SupportedLibraryTableComponents do
        if IsBound( tbl!.( comp ) ) then
          info:= tbl!.( comp );
#T           if   comp = "cliffordTable" then
#T             Print( "tbl.", comp, ":=\n\"",
#T                    PrintCliffordTable( tbl ), "\";\n" );
#T           elif     IsString( info )
#T                and ( IsEmptyString( info ) or not IsEmpty( info ) ) then
          if     IsString( info )
             and ( IsEmptyString( info ) or not IsEmpty( info ) ) then
            Print( "tbl.", comp, ":=\n\"",
                   info, "\";\n" );
          else
            Print( "tbl.", comp, ":=\n",
                   info, ";\n" );
          fi;
        fi;
      od;
      Print( "ConvertToLibraryCharacterTableNC(tbl);\n" );

    else
      Print( "ConvertToCharacterTableNC(tbl);\n" );
    fi;

    # Print the rest of the construction.
    Print( "return tbl;\n" );
    Print( "end;\n" );
    Print( varname, ":= ", varname, "();\n" );
end );


#############################################################################
##
##  10. Constructing Character Tables from Others
##


#############################################################################
##
#M  CharacterTableDirectProduct( <ordtbl1>, <ordtbl2> )
##
InstallMethod( CharacterTableDirectProduct,
    "for two ordinary character tables",
    IsIdenticalObj,
    [ IsOrdinaryTable, IsOrdinaryTable ],
    function( tbl1, tbl2 )
    local direct,        # table of the direct product, result
          ncc1,          # no. of classes in `tbl1'
          ncc2,          # no. of classes in `tbl2'
          i, j, k,       # loop variables
          vals1,         # list of `tbl1'
          vals2,         # list of `tbl2'
          vals_direct,   # corresponding list of the result
          powermap_k,    # `k'-th power map
          ncc2_i,        #
          fus;           # projection/embedding map

    direct:= ConvertToLibraryCharacterTableNC(
                 rec( UnderlyingCharacteristic := 0 ) );
    SetSize( direct, Size( tbl1 ) * Size( tbl2 ) );
    SetIdentifier( direct, Concatenation( Identifier( tbl1 ), "x",
                                          Identifier( tbl2 ) ) );
    SetSizesCentralizers( direct,
                      KroneckerProduct( [ SizesCentralizers( tbl1 ) ],
                                        [ SizesCentralizers( tbl2 ) ] )[1] );

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Compute class parameters, if present in both tables.
    if HasClassParameters( tbl1 ) and HasClassParameters( tbl2 ) then

      vals1:= ClassParameters( tbl1 );
      vals2:= ClassParameters( tbl2 );
      vals_direct:= [];
      for i in [ 1 .. ncc1 ] do
        for j in [ 1 .. ncc2 ] do
          vals_direct[ j + ncc2 * ( i - 1 ) ]:= [ vals1[i], vals2[j] ];
        od;
      od;
      SetClassParameters( direct, vals_direct );

    fi;

    # Compute element orders.
    vals1:= OrdersClassRepresentatives( tbl1 );
    vals2:= OrdersClassRepresentatives( tbl2 );
    vals_direct:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do
        vals_direct[ j + ncc2 * ( i - 1 ) ]:= Lcm( vals1[i], vals2[j] );
      od;
    od;
    SetOrdersClassRepresentatives( direct, vals_direct );

    # Compute power maps for all prime divisors of the result order.
    vals_direct:= ComputedPowerMaps( direct );
    for k in Union( FactorsInt( Size( tbl1 ) ),
                    FactorsInt( Size( tbl2 ) ) ) do
      powermap_k:= [];
      vals1:= PowerMap( tbl1, k );
      vals2:= PowerMap( tbl2, k );
      for i in [ 1 .. ncc1 ] do
        ncc2_i:= ncc2 * (i-1);
        for j in [ 1 .. ncc2 ] do
          powermap_k[ j + ncc2_i ]:= vals2[j] + ncc2 * ( vals1[i] - 1 );
        od;
      od;
      vals_direct[k]:= powermap_k;
    od;

    # Compute the irreducibles.
    SetIrr( direct, List( KroneckerProduct(
                                List( Irr( tbl1 ), ValuesOfClassFunction ),
                                List( Irr( tbl2 ), ValuesOfClassFunction ) ),
                          vals -> Character( direct, vals ) ) );

    # Form character parameters if they exist for the irreducibles
    # in both tables.
    if HasCharacterParameters( tbl1 ) and HasCharacterParameters( tbl2 ) then
      vals1:= CharacterParameters( tbl1 );
      vals2:= CharacterParameters( tbl2 );
      vals_direct:= [];
      for i in [ 1 .. ncc1 ] do
        for j in [ 1 .. ncc2 ] do
          vals_direct[ j + ncc2 * ( i - 1 ) ]:= [ vals1[i], vals2[j] ];
        od;
      od;
      SetCharacterParameters( direct, vals_direct );
    fi;

    # Store projections.
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( direct,
                 rec( map := fus, specification := "1" ),
                 tbl1 );

    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( direct,
                 rec( map := fus, specification := "2" ),
                 tbl2 );

    # Store embeddings.
    StoreFusion( tbl1,
                 rec( map := [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ],
                      specification := "1" ),
                 direct );

    StoreFusion( tbl2,
                 rec( map := [ 1 .. ncc2 ],
                      specification := "2" ),
                 direct );

    # Store the argument list as the value of `FactorsOfDirectProduct'.
    SetFactorsOfDirectProduct( direct, [ tbl1, tbl2 ] );

    # Return the table of the direct product.
    return direct;
    end );


#############################################################################
##
#M  CharacterTableDirectProduct( <modtbl>, <ordtbl> )
##
InstallMethod( CharacterTableDirectProduct,
    "for one Brauer table, and one ordinary character table",
    IsIdenticalObj,
    [ IsBrauerTable, IsOrdinaryTable ],
    function( tbl1, tbl2 )
    local ncc1,     # no. of classes in `tbl1'
          ncc2,     # no. of classes in `tbl2'
          ord,      # ordinary table of product,
          reg,      # Brauer table of product,
          fus,      # fusion map
          i, j;     # loop variables

    # Check that the result will in fact be a Brauer table.
    if Size( tbl2 ) mod UnderlyingCharacteristic( tbl1 ) = 0 then
      Error( "no direct product of Brauer table and p-singular ordinary" );
    fi;

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Make the ordinary and Brauer table of the product.
    ord:= CharacterTableDirectProduct( OrdinaryCharacterTable(tbl1), tbl2 );
    reg:= CharacterTableRegular( ord, UnderlyingCharacteristic( tbl1 ) );

    # Store the irreducibles.
    SetIrr( reg, List(
       KroneckerProduct( List( Irr( tbl1 ), ValuesOfClassFunction ),
                         List( Irr( tbl2 ), ValuesOfClassFunction ) ),
       vals -> Character( reg, vals ) ) );

    # Store projections and embeddings
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( reg, fus, tbl1 );

    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( reg, fus, tbl2 );

    StoreFusion( tbl1,
                 rec( map := [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ],
                      specification := "1" ),
                 reg );

    StoreFusion( tbl2,
                 rec( map := [ 1 .. ncc2 ],
                      specification := "2" ),
                 reg );

    # Return the table.
    return reg;
    end );


#############################################################################
##
#M  CharacterTableDirectProduct( <ordtbl>, <modtbl> )
##
InstallMethod( CharacterTableDirectProduct,
    "for one ordinary and one Brauer character table",
    IsIdenticalObj,
    [ IsOrdinaryTable, IsBrauerTable ],
    function( tbl1, tbl2 )
    local ncc1,     # no. of classes in `tbl1'
          ncc2,     # no. of classes in `tbl2'
          ord,      # ordinary table of product,
          reg,      # Brauer table of product,
          fus,      # fusion map
          i, j;     # loop variables

    # Check that the result will in fact be a Brauer table.
    if Size( tbl1 ) mod UnderlyingCharacteristic( tbl2 ) = 0 then
      Error( "no direct product of Brauer table and p-singular ordinary" );
    fi;

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Make the ordinary and Brauer table of the product.
    ord:= CharacterTableDirectProduct( tbl1, OrdinaryCharacterTable(tbl2) );
    reg:= CharacterTableRegular( ord, UnderlyingCharacteristic( tbl2 ) );

    # Store the irreducibles.
    SetIrr( reg, List(
       KroneckerProduct( List( Irr( tbl1 ), ValuesOfClassFunction ),
                         List( Irr( tbl2 ), ValuesOfClassFunction ) ),
       vals -> Character( reg, vals ) ) );

    # Store projections and embeddings
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( reg, fus, tbl1 );

    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( reg, fus, tbl2 );

    StoreFusion( tbl1,
                 rec( map := [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ],
                      specification := "1" ),
                 reg );

    StoreFusion( tbl2,
                 rec( map := [ 1 .. ncc2 ],
                      specification := "2" ),
                 reg );

    # Return the table.
    return reg;
    end );


#############################################################################
##
#M  CharacterTableDirectProduct( <modtbl1>, <modtbl2> )
##
InstallMethod( CharacterTableDirectProduct,
    "for two Brauer character tables",
    IsIdenticalObj,
    [ IsBrauerTable, IsBrauerTable ],
    function( tbl1, tbl2 )
    local ncc1,     # no. of classes in `tbl1'
          ncc2,     # no. of classes in `tbl2'
          ord,      # ordinary table of product,
          reg,      # Brauer table of product,
          fus,      # fusion map
          i, j;     # loop variables

    # Check that the result will in fact be a Brauer table.
    if    UnderlyingCharacteristic( tbl1 )
       <> UnderlyingCharacteristic( tbl2 ) then
      Error( "no direct product of Brauer tables in different char." );
    fi;

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Make the ordinary and Brauer table of the product.
    ord:= CharacterTableDirectProduct( OrdinaryCharacterTable( tbl1 ),
                                       OrdinaryCharacterTable( tbl2 ) );
    reg:= CharacterTableRegular( ord, UnderlyingCharacteristic( tbl1 ) );

    # Store the irreducibles.
    SetIrr( reg, List(
       KroneckerProduct( List( Irr( tbl1 ), ValuesOfClassFunction ),
                         List( Irr( tbl2 ), ValuesOfClassFunction ) ),
       vals -> Character( reg, vals ) ) );

    # Store projections.
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( reg,
                 rec( map := fus,
                      specification := "1" ),
                 tbl1 );
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( reg,
                 rec( map := fus,
                      specification := "2" ),
                 tbl2 );

    # Store embeddings.
    StoreFusion( tbl1,
                 rec( map := [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ],
                      specification := "1" ),
                 reg );

    StoreFusion( tbl2,
                 rec( map := [ 1 .. ncc2 ],
                      specification := "2" ),
                 reg );

    # Return the table.
    return reg;
    end );


#############################################################################
##
#F  CharacterTableHeadOfFactorGroupByFusion( <tbl>, <factorfusion> )
##
InstallGlobalFunction( CharacterTableHeadOfFactorGroupByFusion,
    function( tbl, factorfusion )
    local size,           # size of `tbl'
          tclasses,       # class lengths of `tbl'
          N,              # classes of the normal subgroup
          suborder,       # order of the normal subgroup
          nccf,           # no. of classes of `F'
          cents,          # centralizer orders of `F'
          i,              # loop over the classes
          F,              # table of the factor group, result
          inverse,        # inverse of `factorfusion'
          p,              # loop over prime divisors
          map;            # one computed power map of `F'

    # Compute the order of the normal subgroup.
    size:= Size( tbl );
    tclasses:= SizesConjugacyClasses( tbl );
    N:= Filtered( [ 1 .. Length( factorfusion ) ],
                  i -> factorfusion[i] = 1 );
    suborder:= Sum( tclasses{ N }, 0 );
    if size mod suborder <> 0 then
      Error( "the order of the kernel of <factorfusion> does not divide ",
             "the size of <tbl>" );
    fi;

    # Compute the centralizer orders of the factor group.
    # \[ |C_{G/N}(gN)\| = \frac{|G|/|N|}{|Cl_{G/N}(gN)|}
    #    = \frac{|G|:|N|}{\frac{1}{|N|}\sum_{x fus gN} |Cl_G(x)|}
    #    = \frac{|G|}{\sum_{x fus gN} |Cl_G(x)| \]
    nccf:= Maximum( factorfusion );
    cents:= ListWithIdenticalEntries( nccf, 0 );
    for i in [ 1 .. Length( factorfusion ) ] do
      cents[ factorfusion[i] ]:= cents[ factorfusion[i] ] + tclasses[i];
    od;
    for i in [ 1 .. nccf ] do
      cents[i]:= size / cents[i];
    od;
    if not ForAll( cents, IsInt ) then
      Error( "not all centralizer orders of the factor are well-defined" );
    fi;

    F:= Concatenation( Identifier( tbl ), "/", String( N ) );
    ConvertToStringRep( F );
    F:= rec(
             UnderlyingCharacteristic := 0,
             Size                     := size / suborder,
             Identifier               := F,
             SizesCentralizers        := cents,
             ComputedPowerMaps        := []
            );

    # Transfer known power maps of `tbl' to `F'.
    inverse:= ProjectionMap( factorfusion );
    for p in Set( Factors( F.Size ) ) do
      if IsBound( ComputedPowerMaps( tbl )[p] ) then
        map:= ComputedPowerMaps( tbl )[p];
        F.ComputedPowerMaps[p]:= factorfusion{ map{ inverse } };
      fi;
    od;

    # Convert the record into a library table.
    ConvertToLibraryCharacterTableNC( F );

    # Store the factor fusion on `tbl'.
    StoreFusion( tbl, rec( map:= factorfusion, type:= "factor" ), F );

    # Return the result.
    return F;
    end );


#############################################################################
##
#M  CharacterTableFactorGroup( <tbl>, <classes> )
##
InstallMethod( CharacterTableFactorGroup,
    "for an ordinary table, and a list of class positions",
    [ IsOrdinaryTable, IsList and IsCyclotomicCollection ],
    function( tbl, classes )
    local F,              # table of the factor group, result
          chi,            # loop over irreducibles
          ker,            # kernel of a `chi'
          factirr,        # irreducibles of `F'
          factorfusion,   # fusion from `tbl' to `F'
          inverse,        # inverse of `factorfusion'
          maps,           # computed power maps of `F'
          p;              # loop over prime divisors

    # Compute the irreducibles of the factor, and the factor fusion.
    factirr:= [];
    for chi in Irr( tbl ) do
      ker:= ClassPositionsOfKernel( chi );
      if IsSubset( ker, classes ) then
        Add( factirr, ValuesOfClassFunction( chi ) );
      fi;
    od;
    factirr:= CollapsedMat( factirr, [] );
    factorfusion := factirr.fusion;
    factirr      := factirr.mat;

    # Compute the table head.
    F:= CharacterTableHeadOfFactorGroupByFusion( tbl, factorfusion );

    # Set the irreducibles.
    SetIrr( F, List( factirr, chi -> Character( F, chi ) ) );

    # Transfer necessary power maps of `tbl' to `F'.
    inverse:= ProjectionMap( factorfusion );
    maps:= ComputedPowerMaps( F );
    for p in Set( Factors( Size( F ) ) ) do
      if not IsBound( maps[p] ) then
        maps[p]:= factorfusion{ PowerMap( tbl, p ){ inverse } };
      fi;
    od;

    # Return the result.
    return F;
    end );


#############################################################################
##
#M  CharacterTableIsoclinic( <ordtbl> ) . . . . . . . . for an ordinary table
##
InstallMethod( CharacterTableIsoclinic,
    "for an ordinary character table",
    [ IsOrdinaryTable ],
    function( tbl )
    local classes, half, kernel, orders, centre;

    # Identify the unique normal subgroup of index 2.
    half:= Size( tbl ) / 2;
    classes:= SizesConjugacyClasses( tbl );
    kernel:= Filtered( List( Filtered( Irr( tbl ),
                                       chi -> DegreeOfCharacter( chi ) = 1 ),
                             ClassPositionsOfKernel ),
                       ker -> Sum( classes{ ker }, 0 ) = half );

    # If there is more than one index 2 subgroup
    # and if there is a unique central subgroup $Z$ of order 2
    # then consider only those index 2 subgroups containing $Z$.
    if 1 < Length( kernel ) then
      orders:= OrdersClassRepresentatives( tbl );
      centre:= Filtered( [ 1 .. Length( classes ) ],
                         x -> classes[x] = 1 and orders[x] = 2 );
      if Length( centre ) = 1 then
        centre:= centre[1];
        kernel:= Filtered( kernel, ker -> centre in ker );
      fi;
    fi;
    if IsEmpty( kernel ) or 1 < Length( kernel ) then
      Error( "normal subgroup of index 2 not uniquely determined,\n",
             "use CharacterTableIsoclinic( <tbl>, <classes_of_nsg> )" );
    fi;

    # Delegate to the two-argument version.
    return CharacterTableIsoclinic( tbl, kernel[1] );
    end );


#############################################################################
##
#M  CharacterTableIsoclinic( <ordtbl>, <nsg> )
##
InstallMethod( CharacterTableIsoclinic,
    "for an ordinary character table, and a list of classes",
    [ IsOrdinaryTable, IsList and IsCyclotomicCollection ],
    function( tbl, nsg )
    local classes, orders, centre;

    # Get the unique central subgroup of order 2 in the normal subgroup.
    classes:= SizesConjugacyClasses( tbl );
    orders:= OrdersClassRepresentatives( tbl );
    centre:= Filtered( nsg, x -> classes[x] = 1 and orders[x] = 2 );
    if Length( centre ) <> 1 then
      Error( "central subgroup of order 2 not uniquely determined,\n",
             "use CharTableIsoclinic( <tbl>, <classes>, <centrepos> )" );
    fi;

    # Delegate to the three-argument version.
    return CharacterTableIsoclinic( tbl, nsg, centre[1] );
    end );


#############################################################################
##
#M  CharacterTableIsoclinic( <ordtbl>, <nsg>, <center> )
##
InstallMethod( CharacterTableIsoclinic,
    "for an ordinary character table, a list of classes, and a class pos.",
    [ IsOrdinaryTable, IsList and IsCyclotomicCollection, IsPosInt ],
    function( tbl, nsg, center )
    local centralizers,    # attribute of `tbl'
          classes,         # attribute of `tbl'
          orders,          # attribute of `tbl'
          size,            # attribute of `tbl'
          i,               # `E(4)'
          j,               # loop variable
          chi,             # one character
          values,          # values of `chi'
          class,
          map,
          linear,          # linear characters of `tbl'
          isoclinic,       # the isoclinic table, result
          outer,           # classes outside the index 2 subgroup
          nonfaith,        # characters of the factor group modulo `center'
          irreds,          # characters of `isoclinic'
          images,
          factorfusion,    # fusion onto factor modulo the central inv.
          p,               # loop over prime divisors of the size of `tbl'
          reg;             # restriction to regular classes

    centralizers:= SizesCentralizers( tbl );
    classes:= SizesConjugacyClasses( tbl );
    orders:= ShallowCopy( OrdersClassRepresentatives( tbl ) );
    size:= Size( tbl );

    # Check `nsg'.
    if Sum( classes{ nsg }, 0 ) <> size / 2 then
      Error( "normal subgroup described by <nsg> must have index 2" );
    fi;

    # Check `center'.
    if not center in nsg then
      Error( "<center> must lie in <nsg>" );
    fi;

    # Make the isoclinic table.
    isoclinic:= Concatenation( "Isoclinic(", Identifier( tbl ), ")" );
    ConvertToStringRep( isoclinic );

    isoclinic:= rec(
        UnderlyingCharacteristic   := 0,
        Identifier                 := isoclinic,
        Size                       := size,
        SizesCentralizers          := centralizers,
        SizesConjugacyClasses      := classes,
        OrdersClassRepresentatives := orders,
        ComputedClassFusions       := [],
        ComputedPowerMaps          := []             );

    # classes outside the normal subgroup
    outer:= Difference( [ 1 .. Length( classes ) ], nsg );

    # Adjust faithful characters in outer classes.
    nonfaith:= [];
    irreds:= [];
    i:= E(4);
    for chi in Irr( tbl ) do
      values:= ValuesOfClassFunction( chi );
      if values[ center ] = values[1] then
        Add( nonfaith, values );
      else
        values:= ShallowCopy( values );
        values{ outer }:= i * values{ outer };
      fi;
      Add( irreds, values );
    od;
    isoclinic.Irr:= irreds;

    # Get the fusion map onto the factor group modulo `[ 1, center ]'.
    factorfusion:= CollapsedMat( nonfaith, [] ).fusion;

    # Adjust the power maps.
    for p in Set( Factors( isoclinic.Size ) ) do

      map:= PowerMap( tbl, p );

      # For $`p' \bmod 4 = 1$, the map remains unchanged,
      # since $g^p = h$ and $(gi)^p = hi^p = hi$ then.
      if p mod 4 = 2 then

        # The squares lie in `nsg'; for $g^2 = h$,
        # we have $(gi)^2 = hz$, so we must take the other
        # preimage under the factorfusion, if exists.
        map:= ShallowCopy( map );
        for class in outer do
          images:= Filtered( Difference( nsg, [ map[class] ] ),
#T does this difference make sense?
              x -> factorfusion[x] = factorfusion[ map[ class ] ] );
          if Length( images ) = 1 then
            map[ class ]:= images[1];
            orders[ class ]:= 2 * orders[ images[1] ];
          fi;
        od;

      elif p mod 4 = 3 then

        # For $g^p = h$, we have $(gi)^p = hi^p = hiz$, so again
        # we must choose the other preimage under the
        # factorfusion, if exists; the `p'-th powers lie outside
        # `nsg' in this case.
        map:= ShallowCopy( map );
        for class in outer do
          images:= Filtered( Difference( outer, [ map[ class ] ] ),
#T does this difference make sense?
              x -> factorfusion[x] = factorfusion[ map[ class ] ] );
          if Length( images ) = 1 then
            map[ class ]:= images[1];
          fi;
        od;

      fi;

      isoclinic.ComputedPowerMaps[p]:= map;

    od;

    # Transfer those factor fusions that have `center' inside the kernel.
    for j in ComputedClassFusions( tbl ) do
      if j.map[ center ] = 1 then
        Add( isoclinic.ComputedClassFusions, j );
      fi;
    od;

    # Convert the record into a library table.
    ConvertToLibraryCharacterTableNC( isoclinic );
    SetSourceOfIsoclinicTable( isoclinic, [ tbl, nsg, center ] );
#T sorting w.r.t. class permutation!

    # Return the result.
    return isoclinic;
    end );


#############################################################################
##
#M  CharacterTableIsoclinic( <modtbl> ) . . . . . . . . .  for a Brauer table
#M  CharacterTableIsoclinic( <modtbl>, <nsg>, <centre> ) . for a Brauer table
##
##  For the isoclinic table of a Brauer table of the structure $2.G.2$,
##  we transfer the normal subgroup information to the regular classes,
##  and adjust the irreducibles.
##
InstallMethod( CharacterTableIsoclinic,
    "for a Brauer table",
    [ IsBrauerTable ],
    function( tbl )
    local isoclinic, source;

    # The normal subgroup and the central involution are uniquely determined.
    isoclinic:= CharacterTableIsoclinic( OrdinaryCharacterTable( tbl ) );
    source:= SourceOfIsoclinicTable( isoclinic );
    return CharacterTableIsoclinic( tbl, source[2], source[3] );
    end );

InstallMethod( CharacterTableIsoclinic,
    "for a Brauer table, a list of classes, and a class pos.",
    [ IsBrauerTable, IsList and IsCyclotomicCollection, IsPosInt ],
    function( tbl, nsg, centre )
    return CharacterTableIsoclinic( tbl, nsg, centre,
               CharacterTableIsoclinic( OrdinaryCharacterTable( tbl ),
                   nsg, centre ) );
    end );


#############################################################################
##
#M  CharacterTableIsoclinic( <modtbl>, <nsg>, <centre>, <ordiso> )
##
##  In some cases, we have already the ordinary isoclinic table,
##  and do not want to create it anew.
##
InstallOtherMethod( CharacterTableIsoclinic,
    "for a Brauer table, a list of classes, a class pos., an ord. table",
    [ IsBrauerTable, IsList and IsCyclotomicCollection, IsPosInt,
      IsOrdinaryTable ],
    function( modtbl, nsg, centre, ordiso )
    local p,
          reg,
          factorfusion,
          outer,
          irreducibles,
          i,
          chi,
          values;

    p:= UnderlyingCharacteristic( modtbl );
    reg:= CharacterTableRegular( ordiso, p );
    factorfusion:= GetFusionMap( reg, ordiso );
    nsg:= List( nsg, i -> Position( factorfusion, i ) );
    centre:= Position( factorfusion, centre );
    outer:= Difference( [ 1 .. NrConjugacyClasses( reg ) ], nsg );

    # Compute the irreducibles as for the ordinary isoclinic table.
    irreducibles:= [];
    i:= E(4);
    for chi in Irr( modtbl ) do
      values:= ValuesOfClassFunction( chi );
      if p <> 2 and values[ centre ] <> values[1] then
        values:= ShallowCopy( values );
        values{ outer }:= i * values{ outer };
      fi;
      Add( irreducibles, values );
    od;
    SetIrr( reg, List( irreducibles, vals -> Character( reg, vals ) ) );

    # Return the result.
    return reg;
    end );


#############################################################################
##
#F  CharacterTableOfNormalSubgroup( <tbl>, <classes> )
##
InstallGlobalFunction( CharacterTableOfNormalSubgroup,
    function( tbl, classes )
    local sizesclasses,   # class lengths of the result
          size,           # size of the result
          nccl,           # no. of classes
          orders,         # repr. orders of the result
          centralizers,   # centralizer orders of the result
          result,         # result table
          err,            # list of classes that must split
          inverse,        # inverse map of `classes'
          p,              # loop over primes
          irreducibles,   # list of irred. characters
          chi,            # loop over irreducibles of `tbl'
          char;           # one character values list for `result'

    if not IsOrdinaryTable( tbl ) then
      Error( "<tbl> must be an ordinary character table" );
    fi;

    sizesclasses:= SizesConjugacyClasses( tbl ){ classes };
    size:= Sum( sizesclasses );

    if Size( tbl ) mod size <> 0 then
      Error( "<classes> is not a normal subgroup" );
    fi;

    nccl:= Length( classes );
    orders:= OrdersClassRepresentatives( tbl ){ classes };
    centralizers:= List( sizesclasses, x -> size / x );

    result:= Concatenation( "Rest(", Identifier( tbl ), ",",
                            String( classes ), ")" );
    ConvertToStringRep( result );

    result:= rec(
        UnderlyingCharacteristic   := 0,
        Identifier                 := result,
        Size                       := size,
        SizesCentralizers          := centralizers,
        SizesConjugacyClasses      := sizesclasses,
        OrdersClassRepresentatives := orders,
        ComputedPowerMaps          := []             );

    err:= Filtered( [ 1 .. nccl ],
                    x-> centralizers[x] mod orders[x] <> 0 );
    if not IsEmpty( err ) then
      Info( InfoCharacterTable, 2,
            "CharacterTableOfNormalSubgroup: classes in " , err,
            " necessarily split" );
    fi;
    inverse:= InverseMap( classes );

    for p in [ 1 .. Length( ComputedPowerMaps( tbl ) ) ] do
      if IsBound( ComputedPowerMaps( tbl )[p] ) then
        result.ComputedPowerMaps[p]:=
            CompositionMaps( inverse,
                CompositionMaps( ComputedPowerMaps( tbl )[p], classes ) );
      fi;
    od;

    # Compute the irreducibles if known.
    irreducibles:= [];
    if HasIrr( tbl ) then

      for chi in Irr( tbl ) do
        char:= ValuesOfClassFunction( chi ){ classes };
        if     Sum( [ 1 .. nccl ],
                  i -> sizesclasses[i] * char[i] * GaloisCyc(char[i],-1), 0 )
               = size
           and not char in irreducibles then
          Add( irreducibles, char );
        fi;
      od;

    fi;

    if Length( irreducibles ) = nccl then

      result.Irr:= irreducibles;

      # Convert the record into a library table.
      ConvertToLibraryCharacterTableNC( result );

    else

      p:= Size( tbl ) / size;
      if IsPrimeInt( p ) and not IsEmpty( irreducibles ) then
        Info( InfoCharacterTable, 2,
              "CharacterTableOfNormalSubgroup: The table must have ",
              p * NrConjugacyClasses( tbl ) -
              ( p^2 - 1 ) * Length( irreducibles ), " classes\n",
              "#I   (now ", Length( classes ), ", after nec. splitting ",
              Length( classes ) + (p-1) * Length( err ), ")" );
      fi;

      Error( "tables in progress not yet supported" );
#T !!

    fi;

    # Store the fusion into `tbl'.
    StoreFusion( result, classes, tbl );

    # Return the result.
    return result;
end );


#############################################################################
##
##  11. Sorted Character Tables
##


#############################################################################
##
#F  PermutationToSortCharacters( <tbl>, <chars>, <degree>, <norm>, <galois> )
##
InstallGlobalFunction( PermutationToSortCharacters,
    function( tbl, chars, degree, norm, galois )
    local galoisfams, i, j, chi, listtosort, len;

    if IsEmpty( chars ) then
      return ();
    fi;

    # Rational characters shall precede irrational ones of same degree,
    # and the trivial character shall be the first one.
    # If `galois = true' then also each family of Galois conjugate
    # characters shall be put together.
    if galois = true then
      galois:= GaloisMat( chars ).galoisfams;
      if Length( galois ) <> Length( chars ) then
        galois:= false;
      else
        galoisfams:= [];
        for i in [ 1 .. Length( chars ) ] do
          if galois[i] = 1 then
            if ForAll( chars[i], x -> x = 1 ) then
              galoisfams[i]:= -1;
            else
              galoisfams[i]:= 0;
            fi;
          elif IsList( galois[i] ) then
            for j in galois[i][1] do
              galoisfams[j]:= i;
            od;
          fi;
        od;
      fi;
    else
      galoisfams:= [];
      for i in [ 1 .. Length( chars ) ] do
        chi:= ValuesOfClassFunction( chars[i] );
        if ForAll( chi, IsRat ) then
          if ForAll( chi, x -> x = 1 ) then
            galoisfams[i]:= -1;
          else
            galoisfams[i]:= 0;
          fi;
        else
          galoisfams[i]:= 1;
        fi;
      od;
    fi;

    # Compute the permutation.
    listtosort:= [];
    if degree and norm then
      for i in [ 1 .. Length( chars ) ] do
        listtosort[i]:= [ ScalarProduct( tbl, chars[i], chars[i] ),
                          chars[i][1],
                          galoisfams[i], i ];
      od;
    elif degree then
      for i in [ 1 .. Length( chars ) ] do
        listtosort[i]:= [ chars[i][1],
                          galoisfams[i], i ];
      od;
    elif norm then
      for i in [ 1 .. Length( chars ) ] do
        listtosort[i]:= [ ScalarProduct( chars[i], chars[i] ),
                          galoisfams[i], i ];
      od;
    else
      Error( "at least one of <degree> or <norm> must be `true'" );
    fi;
    Sort( listtosort );
    len:= Length( listtosort[1] );
    for i in [ 1 .. Length( chars ) ] do
      listtosort[i]:= listtosort[i][ len ];
    od;
    return Inverse( PermList( listtosort ) );
    end );


#############################################################################
##
#M  CharacterTableWithSortedCharacters( <tbl> )
##
InstallMethod( CharacterTableWithSortedCharacters,
    "for a character table",
    [ IsCharacterTable ],
    tbl -> CharacterTableWithSortedCharacters( tbl,
       PermutationToSortCharacters( tbl, Irr( tbl ), true, false, true ) ) );


#############################################################################
##
#M  CharacterTableWithSortedCharacters( <tbl>, <perm> )
##
InstallMethod( CharacterTableWithSortedCharacters,
    "for an ordinary character table, and a permutation",
    [ IsOrdinaryTable, IsPerm ],
    function( tbl, perm )
    local new, i;

    # Create the new table.
    new:= ConvertToLibraryCharacterTableNC(
                 rec( UnderlyingCharacteristic := 0 ) );

    # Set the supported attribute values that need not be permuted.
    for i in [ 3, 6 .. Length( SupportedCharacterTableInfo ) ] do
      if Tester( SupportedCharacterTableInfo[ i-2 ] )( tbl )
         and not ( "character" in SupportedCharacterTableInfo[i] ) then
        Setter( SupportedCharacterTableInfo[ i-2 ] )( new,
            SupportedCharacterTableInfo[ i-2 ]( tbl ) );
      fi;
    od;

    # Set the permuted attribute values.
    SetIrr( new, Permuted( List( Irr( tbl ),
        chi -> Character( new, ValuesOfClassFunction( chi ) ) ), perm ) );
    if HasCharacterParameters( tbl ) then
      SetCharacterParameters( new,
          Permuted( CharacterParameters( tbl ), perm ) );
    fi;

    # Return the table.
    return new;
    end );


#############################################################################
##
#M  SortedCharacters( <tbl>, <chars> )
##
InstallMethod( SortedCharacters,
    "for a character table, and a homogeneous list",
    [ IsNearlyCharacterTable, IsHomogeneousList ],
    function( tbl, chars )
    return Permuted( chars,
               PermutationToSortCharacters( tbl, chars, true, true, true ) );
    end );


#############################################################################
##
#M  SortedCharacters( <tbl>, <chars>, \"norm\" )
#M  SortedCharacters( <tbl>, <chars>, \"degree\" )
##
InstallMethod( SortedCharacters,
    "for a character table, a homogeneous list, and a string",
    [ IsNearlyCharacterTable, IsHomogeneousList, IsString ],
    function( tbl, chars, string )
    if string = "norm" then
      return Permuted( chars,
          PermutationToSortCharacters( tbl, chars, false, true, false ) );
    elif string = "degree" then
      return Permuted( chars,
          PermutationToSortCharacters( tbl, chars, true, false, false ) );
    else
      Error( "<string> must be \"norm\" or \"degree\"" );
    fi;
    end );


#############################################################################
##
#F  PermutationToSortClasses( <tbl>, <classes>, <orders>, <galois> )
##
InstallGlobalFunction( PermutationToSortClasses,
    function( tbl, classes, orders, galois )
    local nccl, fams, galoislist, i, j, listtosort, len;

    nccl:= NrConjugacyClasses( tbl );

    # Compute the values for the Galois conjugates if needed.
    if galois and HasIrr( tbl ) then
      fams:= GaloisMat( TransposedMat( Irr( tbl ) ) ).galoisfams;
      galoislist:= [];
      for i in [ 1 .. nccl ] do
        if   fams[i] = 1 then
          # Rational classes precede classes with irrationalities
          # of same element order and class length.
          galoislist[i]:= 0;
        elif IsList( fams[i] ) then
          # Classes in the same family get the same key.  (The relative
          # positions of the first class in each family are maintained.)
          for j in fams[i][1] do
            galoislist[j]:= i;
          od;
        fi;
      od;
    else
      galoislist:= ListWithIdenticalEntries( nccl, 0 );
    fi;

    # Compute the permutation.
    listtosort:= [];
    if classes and orders then
      classes:= SizesConjugacyClasses( tbl );
      orders:= OrdersClassRepresentatives( tbl );
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        listtosort[i]:= [ orders[i], classes[i], galoislist[i], i ];
      od;
    elif classes then
      classes:= SizesConjugacyClasses( tbl );
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        listtosort[i]:= [ classes[i], galoislist[i], i ];
      od;
    elif orders then
      orders:= OrdersClassRepresentatives( tbl );
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        listtosort[i]:= [ orders[i], galoislist[i], i ];
      od;
    elif galois then
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        listtosort[i]:= [ galoislist[i], i ];
      od;
    else
      Error( "<classes> or <orders> or <galois> must be `true'" );
    fi;
    Sort( listtosort );
    len:= Length( listtosort[1] );
    for i in [ 1 .. Length( listtosort ) ] do
      listtosort[i]:= listtosort[i][ len ];
    od;
#T better use `TransposedMat'?
    return Inverse( PermList( listtosort ) );
    end );


#############################################################################
##
#M  CharacterTableWithSortedClasses( <tbl> )
##
InstallMethod( CharacterTableWithSortedClasses,
    "for a character table",
    [ IsCharacterTable ],
    tbl -> CharacterTableWithSortedClasses( tbl,
               PermutationToSortClasses( tbl, true, true, true ) ) );


#############################################################################
##
#M  CharacterTableWithSortedClasses( <tbl>, \"centralizers\" )
#M  CharacterTableWithSortedClasses( <tbl>, \"representatives\" )
##
InstallMethod( CharacterTableWithSortedClasses,
    "for a character table, and string",
    [ IsCharacterTable, IsString ],
    function( tbl, string )
    if   string = "centralizers" then
      return CharacterTableWithSortedClasses( tbl,
                 PermutationToSortClasses( tbl, true, false, true ) );
    elif string = "representatives" then
      return CharacterTableWithSortedClasses( tbl,
                 PermutationToSortClasses( tbl, false, true, true ) );
    else
      Error( "<string> must be \"centralizers\" or \"representatives\"" );
    fi;
    end );


#############################################################################
##
#M  CharacterTableWithSortedClasses( <tbl>, <permutation> )
##
InstallMethod( CharacterTableWithSortedClasses,
    "for an ordinary character table, and a permutation",
    [ IsOrdinaryTable, IsPerm ],
    function( tbl, perm )

    local new, i, attr, fus, tblmaps, permmap, inverse, k;

    # Catch trivial cases.
    if 1^perm <> 1 then
      Error( "<perm> must fix the first class" );
    elif IsOne( perm ) then
      return tbl;
    fi;

    # Create the new table.
    new:= ConvertToLibraryCharacterTableNC(
                 rec( UnderlyingCharacteristic := 0 ) );

    # Set supported attributes that do not need adjustion.
    for i in [ 3, 6 .. Length( SupportedCharacterTableInfo ) ] do
      if Tester( SupportedCharacterTableInfo[ i-2 ] )( tbl )
         and not ( "class" in SupportedCharacterTableInfo[i] ) then
        Setter( SupportedCharacterTableInfo[ i-2 ] )( new,
            SupportedCharacterTableInfo[ i-2 ]( tbl ) );
      fi;
    od;

    # Set known attributes that must be adjusted by simply permuting.
    for attr in [ ClassParameters,
                  ConjugacyClasses,
                  IdentificationOfConjugacyClasses,
                  OrdersClassRepresentatives,
                  SizesCentralizers,
                  SizesConjugacyClasses,
                ] do
      if Tester( attr )( tbl ) then
        Setter( attr )( new, Permuted( attr( tbl ), perm ) );
      fi;
    od;

    # For each fusion, the map must be permuted.
    for fus in ComputedClassFusions( tbl ) do
      Add( ComputedClassFusions( new ),
           rec( name:= fus.name, map:= Permuted( fus.map, perm ) ) );
    od;

    # Each irreducible character must be permuted.
    if HasIrr( tbl ) then
      SetIrr( new,
          List( Irr( tbl ), chi -> Character( new,
                Permuted( ValuesOfClassFunction( chi ), perm ) ) ) );
    fi;

    # Power maps must be ``conjugated''.
    if HasComputedPowerMaps( tbl ) then

      tblmaps:= ComputedPowerMaps( tbl );
      permmap:= ListPerm( perm );
      inverse:= ListPerm( perm^(-1) );
      for k in [ Length( permmap ) + 1 .. NrConjugacyClasses( tbl ) ] do
        permmap[k]:= k;
        inverse[k]:= k;
      od;
      for k in [ 1 .. Length( tblmaps ) ] do
        if IsBound( tblmaps[k] ) then
          ComputedPowerMaps( new )[k]:= CompositionMaps( permmap,
              CompositionMaps( tblmaps[k], inverse ) );
        fi;
      od;

    fi;

    # The automorphisms of the sorted table are obtained by conjugation.
    if HasAutomorphismsOfTable( tbl ) then
      SetAutomorphismsOfTable( new, GroupByGenerators(
          List( GeneratorsOfGroup( AutomorphismsOfTable( tbl ) ),
                x -> x^perm ), () ) );
    fi;

    # The class permutation must be multiplied with the new permutation.
    if HasClassPermutation( tbl ) then
      SetClassPermutation( new, ClassPermutation( tbl ) * perm );
    else
      SetClassPermutation( new, perm );
    fi;

    # Return the new table.
    return new;
    end );


#############################################################################
##
#F  SortedCharacterTable( <tbl>, <kernel> )
#F  SortedCharacterTable( <tbl>, <normalseries> )
#F  SortedCharacterTable( <tbl>, <facttbl>, <kernel> )
##
InstallGlobalFunction( SortedCharacterTable, function( arg )
    local i, j, tbl, kernels, list, columns, rows, chi, F, facttbl, kernel,
          fus, nrfus, trans, ker, new;

    # Check the arguments.
    if not ( Length( arg ) in [ 2, 3 ] and IsOrdinaryTable( arg[1] ) and
             IsList( arg[ Length( arg ) ] ) and
             ( Length( arg ) = 2 or IsOrdinaryTable( arg[2] ) ) ) then
      Error( "usage: SortedCharacterTable( <tbl>, <kernel> ) resp.\n",
             "       SortedCharacterTable( <tbl>, <normalseries> ) resp.\n",
             "       SortedCharacterTable( <tbl>, <facttbl>, <kernel> )" );
    fi;

    tbl:= arg[1];

    if Length( arg ) = 2 then

      # Sort w.r.t. kernel or series of kernels.
      kernels:= arg[2];
      if IsEmpty( kernels ) then
        return tbl;
      fi;

      # Regard single kernel as special case of normal series.
      if IsInt( kernels[1] ) then
        kernels:= [ kernels ];
      fi;

      # permutation of classes:
      # `list[i] = k' if `i' is contained in `kernels[k]' but not
      # in `kernels[k-1]'; only the first position contains a zero
      # to ensure that the identity is not moved.
      # If class `i' is not contained in any of the kernels we have
      # `list[i] = infinity'.
      list:= [ 0 ];
      for i in [ 2 .. NrConjugacyClasses( tbl ) ] do
        list[i]:= infinity;
      od;
      for i in [ 1 .. Length( kernels ) ] do
        for j in kernels[i] do
          if not IsInt( list[j] ) then
            list[j]:= i;
          fi;
        od;
      od;
      columns:= Sortex( list );

      # permutation of characters:
      # `list[i] = -(k+1)' if `Irr( <tbl> )[i]' has `kernels[k]'
      # in its kernel but not `kernels[k+1]';
      # if the `i'--th irreducible contains none of `kernels' in its kernel,
      # we have `list[i] = -1',
      # for an irreducible with kernel containing
      # `kernels[ Length( kernels ) ]',
      # the value is `-(Length( kernels ) + 1)'.
      list:= [];
      if HasIrr( tbl ) then
        for chi in Irr( tbl ) do
          i:= 1;
          while     i <= Length( kernels )
                and ForAll( kernels[i], x -> chi[x] = chi[1] ) do
            i:= i+1;
          od;
          Add( list, -i );
        od;
        rows:= Sortex( list );
      else
        rows:= ();
      fi;

    else

      # Sort w.r.t. the table of a factor group.
      facttbl:= arg[2];
      kernel:= arg[3];
      fus:= ComputedClassFusions( tbl );
      nrfus:= Length( fus );
      F:= CharacterTableFactorGroup( tbl, kernel );
      trans:= TransformingPermutationsCharacterTables( F, facttbl );
      if trans = fail then
        Info( InfoCharacterTable, 2,
              "SortedCharacterTable: tables of factors not compatible" );
        return fail;
      fi;

      # permutation of classes:
      # `list[i] = k' if `i' maps to the `j'--th class of <F>, and
      # `trans.columns[j] = i'
      list:= OnTuples( GetFusionMap( tbl, F ), trans.columns );
      columns:= Sortex( list );

      # permutation of characters:
      # divide `Irr( <tbl> )' into two parts, those containing
      # the kernel of the factor fusion in their kernel (value 0),
      # and the others (value 1); do not forget to permute characters
      # of the factor group with `trans.rows'.
      if HasIrr( tbl ) then
        ker:= ClassPositionsOfKernel( GetFusionMap( tbl, F ) );
        list:= [];
        for chi in Irr( tbl ) do
          if ForAll( ker, x -> chi[x] = chi[1] ) then
            Add( list, 0 );
          else
            Add( list, 1 );
          fi;
        od;
        rows:= Sortex( list ) * trans.rows;
      else
        rows:= ();
      fi;

      if nrfus < Length( fus ) then
        # Delete the fusion to `F' on `tbl'.
        Unbind( fus[ Length( fus ) ] );
      fi;

    fi;

    # Sort and return.
    new:= CharacterTableWithSortedClasses( tbl, columns );
    new:= CharacterTableWithSortedCharacters( new, rows );
    return new;
end );


############################################################################
##
##  12. Storing Normal Subgroup Information
##


##############################################################################
##
#M  NormalSubgroupClassesInfo( <tbl> )
##
InstallMethod( NormalSubgroupClassesInfo,
    "default method, initialization",
    [ IsOrdinaryTable ],
    tbl -> rec( nsg        := [],
                nsgclasses := [],
                nsgfactors := [] ) );


##############################################################################
##
#M  ClassPositionsOfNormalSubgroup( <tbl>, <N> )
##
InstallGlobalFunction( ClassPositionsOfNormalSubgroup, function( tbl, N )

    local info,
          classes,    # result list
          found,      # `N' already found?
          pos,        # position in `info.nsg'
          G,          # underlying group of `tbl'
          ccl;        # conjugacy classes of `tbl'

    info:= NormalSubgroupClassesInfo( tbl );

    # Search for `N' in `info.nsg'.
    found:= false;
    pos:= 0;
    while ( not found ) and pos < Length( info.nsg ) do
      pos:= pos+1;
      if IsIdenticalObj( N, info.nsg[ pos ] ) then
        found:= true;
      fi;
    od;
    if not found then
      pos:= Position( info.nsg, N );
    fi;

    if pos = fail then

      # The group is not yet stored here, try `NormalSubgroups( G )'.
      G:= UnderlyingGroup( tbl );
      if HasNormalSubgroups( G ) then

        # Identify our normal subgroup.
        N:= NormalSubgroups( G )[ Position( NormalSubgroups( G ), N ) ];

      fi;

      ccl:= ConjugacyClasses( tbl );
      classes:= Filtered( [ 1 .. Length( ccl ) ],
                          x -> Representative( ccl[x] ) in N );

      Add( info.nsgclasses, classes );
      Add( info.nsg       , N       );
      pos:= Length( info.nsg );

    fi;

    return info.nsgclasses[ pos ];
end );


##############################################################################
##
#F  NormalSubgroupClasses( <tbl>, <classes> )
##
InstallGlobalFunction( NormalSubgroupClasses, function( tbl, classes )

    local info,
          pos,        # position of the group in the list of such groups
          G,          # underlying group of `tbl'
          ccl,        # `G'-conjugacy classes in our normal subgroup
          size,       # size of our normal subgroup
          candidates, # bound normal subgroups that possibly are our group
          group,      # the normal subgroup
          repres,     # list of representatives of conjugacy classes
          found,      # normal subgroup already identified
          i;          # loop over normal subgroups

    info:= NormalSubgroupClassesInfo( tbl );

    classes:= Set( classes );
    pos:= Position( info.nsgclasses, classes );
    if pos = fail then

      # The group is not yet stored here, try `NormalSubgroups( G )'.
      G:= UnderlyingGroup( tbl );

      if HasNormalSubgroups( G ) then

        # Identify our normal subgroup.
        ccl:= ConjugacyClasses( tbl ){ classes };
        size:= Sum( ccl, Size, 0 );
        candidates:= Filtered( NormalSubgroups( G ), x -> Size( x ) = size );
        if Length( candidates ) = 1 then
          group:= candidates[1];
        else

          repres:= List( ccl, Representative );
          found:= false;
          i:= 0;
          while not found do
            i:= i+1;
            if ForAll( repres, x -> x in candidates[i] ) then
              found:= true;
            fi;
          od;

          if not found then
            Error( "<classes> does not describe a normal subgroup" );
          fi;

          group:= candidates[i];

        fi;

      elif classes = [ 1 ] then

        group:= TrivialSubgroup( G );

      else

        # The group is not yet stored, we have to construct it.
        repres:= List( ConjugacyClasses( tbl ){ classes }, Representative );
        group := NormalClosure( G, SubgroupNC( G, repres ) );

      fi;

      MakeImmutable( classes );
      Add( info.nsgclasses, classes );
      Add( info.nsg       , group   );
      pos:= Length( info.nsg );

    fi;

    return info.nsg[ pos ];
end );


##############################################################################
##
#F  FactorGroupNormalSubgroupClasses( <tbl>, <classes> )
##
InstallGlobalFunction( FactorGroupNormalSubgroupClasses,
    function( tbl, classes )

    local info,
          f,     # the result
          pos;   # position in list of normal subgroups

    info:= NormalSubgroupClassesInfo( tbl );
    pos:= Position( info.nsgclasses, classes );

    if pos = fail then
      f:= UnderlyingGroup( tbl ) / NormalSubgroupClasses( tbl, classes );
      info.nsgfactors[ Length( info.nsgclasses ) ]:= f;
    elif IsBound( info.nsgfactors[ pos ] ) then
      f:= info.nsgfactors[ pos ];
    else
      f:= UnderlyingGroup( tbl ) / info.nsg[ pos ];
      info.nsgfactors[ pos ]:= f;
    fi;

    return f;
end );


############################################################################
##
##  13. Auxiliary Stuff
##


#T ############################################################################
#T ##
#T #F  Lattice( <tbl> ) . .  lattice of normal subgroups of a c.t.
#T ##
#T Lattice := function( tbl )
#T
#T     local i, j,       # loop variables
#T           nsg,        # list of normal subgroups
#T           len,        # length of `nsg'
#T           sizes,      # sizes of normal subgroups
#T           max,        # one maximal subgroup
#T           maxes,      # list of maximal contained normal subgroups
#T           actsize,    # actuel size of normal subgroups
#T           actmaxes,
#T           latt;       # the lattice record
#T
#T     # Compute normal subgroups and their sizes
#T     nsg:= ClassPositionsOfNormalSubgroups( tbl );
#T     len:= Length( nsg );
#T     sizes:= List( nsg, x -> Sum( tbl.classes{ x }, 0 ) );
#T     SortParallel( sizes, nsg );
#T
#T     # For each normal subgroup, compute the maximal contained ones.
#T     maxes:= [];
#T     i:= 1;
#T     while i <= len do
#T       actsize:= sizes[i];
#T       actmaxes:= Filtered( [ 1 .. i-1 ], x -> actsize mod sizes[x] = 0 );
#T       while i <= len and sizes[i] = actsize do
#T         max:= Filtered( actmaxes, x -> IsSubset( nsg[i], nsg[x] ) );
#T         for j in Reversed( max ) do
#T           SubtractSet( max, maxes[j] );
#T         od;
#T         Add( maxes, max );
#T         i:= i+1;
#T       od;
#T     od;
#T
#T     # construct the lattice record
#T     latt:= rec( domain          := tbl,
#T                 normalSubgroups := nsg,
#T                 sizes           := sizes,
#T                 maxes           := maxes,
#T                 XGAP            := rec( vertices := [ 1 .. len ],
#T                                         sizes    := sizes,
#T                                         maximals := maxes ),
#T                 operations      := PreliminaryLatticeOps );
#T
#T     # return the lattice record
#T     return latt;
#T end;


#############################################################################
##
#E

