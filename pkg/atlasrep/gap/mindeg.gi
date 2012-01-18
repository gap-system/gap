#############################################################################
##
#W  mindeg.gi            GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2007,   Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file contains declarations for dealing with information about
##  permutation and matrix representations of minimal degree
##  for selected groups.
##


#############################################################################
##
#F  MinimalPermutationRepresentationInfo( <grpname>, <mode> )
##
if IsPackageMarkedForLoading( "ctbllib", "" ) then

InstallGlobalFunction( MinimalPermutationRepresentationInfo,
    function( grpname, mode )
    local result, addvalue, parse, ordtbl, identifier, value, s, cand, maxes,
          indices, perms, corefreepos, cand1, other, minpos, cand2min, tom,
          faith, mincand, minsubmindeg, subname, subtbl, pi, submindeg, fus,
          n, N, l;

    # Initialize the result values.
    result:= rec( value:= "unknown",
                  source:= [] );
    addvalue:= function( val, src )
      if result.value = "unknown" then
        result.value:= val;
      elif result.value <> val then
        Error( "inconsistent minimal degrees" );
      fi;
      AddSet( result.source, src );
    end;

    # `"A<n>"' and `"A<n>.2"' yield <n>.
    parse:= ParseForwards( grpname, [ "A", IsDigitChar ] );
    if parse <> fail then
      parse:= Int( parse[2] );
      if parse < 3 then
        addvalue( 1, "computed (alternating group)" );
      else
        addvalue( Int( parse ), "computed (alternating group)" );
      fi;
      if mode = "one" then
        return result;
      fi;
    fi;
    parse:= ParseForwards( grpname, [ "A", IsDigitChar, ".2" ] );
    if parse <> fail then
      parse:= Int( parse[2] );
      if parse < 2 then
        Error( grpname, " makes no sense" );
      else
        addvalue( Int( parse ), "computed (symmetric group)" );
      fi;
      if mode = "one" then
        return result;
      fi;
    fi;

    # `"L2(<q>)"' yields $<q>+1$ if $<q> \not\in \{ 2, 3, 5, 7, 9, 11 \}$.
    parse:= ParseForwards( grpname, [ "L2(", IsDigitChar, ")" ] );
    if parse <> fail then
      parse:= Int( parse[2] );
      if   parse in [ 2, 3, 5, 7, 11 ] then
        addvalue( parse, "computed (PSL(2,q))" );
      elif parse = 9 then
        addvalue( 6, "computed (PSL(2,q))" );
      else
        addvalue( parse + 1, "computed (PSL(2,q))" );
      fi;
      if mode = "one" then
        return result;
      fi;
    fi;

    # Use information from the character table from the library.
    ordtbl:= CharacterTable( grpname );
    if IsCharacterTable( ordtbl ) then
      if     HasConstructionInfoCharacterTable( ordtbl )
         and IsList( ConstructionInfoCharacterTable( ordtbl ) )
         and ConstructionInfoCharacterTable( ordtbl )[1]
                 = "ConstructPermuted"
         and Length( ConstructionInfoCharacterTable( ordtbl )[2] ) = 1 then
        # Delegate to another table for which more information is available.
        identifier:= ConstructionInfoCharacterTable( ordtbl )[2][1];
        value:= MinimalRepresentationInfo( identifier, NrMovedPoints );
        if value <> fail then
          addvalue( value.value, Concatenation( "computed (char. table of ",
                                   identifier, ")" ) );
          if mode = "one" then
            return result;
          fi;
        fi;
      else

        # If the first maximal subgroup is known and core-free
        # then take its index. (This happens for simple tables.)
        # (Here we need not assume that the permutation representation of
        # minimal degree is transitive.)
        s:= CharacterTable( Concatenation( Identifier( ordtbl ), "M1" ) );
        if s <> fail and
           Length( ClassPositionsOfKernel( TrivialCharacter( s )^ordtbl ) )
               = 1 then
          addvalue( Size( ordtbl ) / Size( s ), "computed (char. table)" );
          if mode = "one" then
            return result;
          fi;
        fi;

        # If all tables of maximal subgroups are available then inspect them.
        if HasMaxes( ordtbl ) then
          maxes:= List( Maxes( ordtbl ), CharacterTable );
          indices:= List( maxes, s -> Size( ordtbl ) / Size( s ) );
          if IsSimpleCharacterTable( ordtbl ) then
            # just a shortcut ...
            addvalue( Minimum( indices ), "computed (char. table)" );
            if mode = "one" then
              return result;
            fi;
          fi;
          perms:= List( maxes, s -> TrivialCharacter( s ) ^ ordtbl );
          corefreepos:= Filtered( [ 1 .. Length( perms ) ],
              i -> Length( ClassPositionsOfKernel( perms[i] ) ) = 1 );

          # If the maximal subgroups of largest order are core-free
          # then we are done.
          if not IsEmpty( corefreepos ) then
            cand1:= Minimum( indices{ corefreepos } );
            if Minimum( indices ) = cand1 then
              addvalue( cand1, "computed (char. table)" );
              if mode = "one" then
                return result;
              fi;
            fi;
          fi;

          # If the group has a unique minimal normal subgroup
          # (so the minimal permutation representation is transitive)
          # that is simple and maximal
          # then all candidate subgroups in this normal subgroup
          # are admissible also inside this subgroup;
          # so the candidate indices for point stabilizers inside this
          # normal subgroup are minimal degree times index.
          other:= Difference( [ 1 .. Length( maxes ) ], corefreepos );
          if     Length( other ) = 1
             and IsSimpleCharacterTable( maxes[ other[1] ] ) then
            minpos:= ClassPositionsOfMinimalNormalSubgroups( ordtbl );
            if Length( minpos ) = 1 and
               ClassPositionsOfKernel( TrivialCharacter( maxes[ other[1] ]
                                       )^ordtbl ) = minpos[1] then
              cand2min:= MinimalRepresentationInfo(
                             Identifier( maxes[ other[1] ] ), NrMovedPoints );
              if IsRecord( cand2min ) then
                addvalue( Minimum( cand1,
                                   indices[ other[1] ] * cand2min.value ),
                          "computed (char. table)" );
                if mode = "one" then
                  return result;
                fi;
              fi;
            fi;
          fi;
        fi;
      fi;

      # If the table of marks is known and the minimal permutation
      # representation is transitive then we can compute directly.
      if HasFusionToTom( ordtbl ) and
         Length( ClassPositionsOfMinimalNormalSubgroups( ordtbl ) ) = 1 then
        tom:= TableOfMarks( ordtbl );
        if tom <> fail then
          if IsSimpleCharacterTable( ordtbl ) then
            maxes:= MaximalSubgroupsTom( tom );
            addvalue( Minimum( maxes[2] ), "computed (table of marks)" );
            if mode = "one" then
              return result;
            fi;
          else
            faith:= Filtered( PermCharsTom( ordtbl, tom ),
                        x -> Length( ClassPositionsOfKernel( x ) ) = 1 );
            addvalue( Minimum( List( faith, x -> x[1] ) ),
                      "computed (table of marks)" );
            if mode = "one" then
              return result;
            fi;
          fi;
        fi;
      fi;

      # If we have a subgroup with known minimal degree $n$
      # and a core-free subgroup of index $n$,
      # then $n$ is the minimal degree of $G$.
      mincand:= infinity;
      minsubmindeg:= Maximum( Set( Factors( Size( ordtbl ) ) ) );
      for subname in NamesOfFusionSources( ordtbl ) do
        subtbl:= CharacterTable( subname );
        if subtbl <> fail and IsOrdinaryTable( subtbl ) and
           Length( ClassPositionsOfKernel( GetFusionMap( subtbl, ordtbl ) ) )
               = 1 then
          pi:= TrivialCharacter( subtbl ) ^ ordtbl;
          if Length( ClassPositionsOfKernel( pi ) ) = 1 then
            if pi[1] < mincand then
              mincand:= pi[1];
            fi;
          fi;
          submindeg:= MinimalRepresentationInfo( subname, NrMovedPoints );
          if submindeg <> fail and minsubmindeg < submindeg.value then
            minsubmindeg:= submindeg.value;
          fi;
          if mincand = minsubmindeg then
            addvalue( minsubmindeg, "computed (subgroup tables)" );
            if mode = "one" then
              return result;
            fi;
          fi;
        fi;
      od;

      # If we have a subgroup with known minimal degree $n$
      # and a faithful permutation representation of degree $n$ for $G$
      # then $n$ is the minimal degree of $G$.
      if OneAtlasGeneratingSetInfo( grpname, NrMovedPoints, minsubmindeg )
             <> fail then
        addvalue( minsubmindeg,
                  "computed (subgroup tables, known repres.)" );
        if mode = "one" then
          return result;
        fi;
      fi;

      # If the factor group of $G$ modulo its unique minimal normal subgroup
      # $N$ is simple and has minimal degree $n$,
      # and if we know a subgroup $U$ of index $n |N|$ that intersects $N$
      # trivially then the minimal degree is $n |N|$.
      minpos:= ClassPositionsOfMinimalNormalSubgroups( ordtbl );
      if Length( minpos ) = 1 then
        fus:= First( ComputedClassFusions( ordtbl ),
                     r -> ClassPositionsOfKernel( r.map ) = minpos[1] );
        if fus <> fail then
          n:= MinimalRepresentationInfo( fus.name, NrMovedPoints );
          if n <> fail then
            N:= Sum( SizesConjugacyClasses( ordtbl ){ minpos[1] } );
            for subname in NamesOfFusionSources( ordtbl ) do
              subtbl:= CharacterTable( subname );
              if subtbl <> fail and IsOrdinaryTable( subtbl ) and
                 Size( ordtbl ) = Size( subtbl ) * n.value then
                fus:= GetFusionMap( subtbl, ordtbl );
                if Length( ClassPositionsOfKernel( fus ) ) = 1 then
                  for l in ClassPositionsOfDirectProductDecompositions(
                               subtbl ) do
                    if ForAny( l,
                         x -> Sum( SizesConjugacyClasses( subtbl ){ x } )
                                = Size( subtbl ) / N 
                              and Intersection( fus{ x }, minpos[1] )
                                    = [ 1 ] ) then
                      addvalue( N * n.value, "computed (factor table)" );
                      if mode = "one" then
                        return result;
                      fi;
                    fi;
                  od;
                fi;
              fi;
            od;
          fi;
        fi;
      fi;
    fi;

    return result;
    end );

fi;


#############################################################################
##
#F  MinimalRepresentationInfo( <grpname>, NrMovedPoints[, <mode>] )
#F  MinimalRepresentationInfo( <grpname>, Characteristic, <p>[, <mode>] )
#F  MinimalRepresentationInfo( <grpname>, Size, <q>[, <mode>] )
##
InstallGlobalFunction( MinimalRepresentationInfo, function( arg )
    local grpname, info, conditions, known, result, mode, p, ordtbl, minpos,
          faith, Norder, modtbl, min, q, pos, cont;

    if   Length( arg ) = 0 then
      Error( "usage: ",
             "MinimalRepresentationInfo( <grpname>[, <conditions>] )" );
    fi;
    grpname:= arg[1];
    if not IsString( grpname ) then
      return fail;
    fi;
    if IsBound( MinimalRepresentationInfoData.( grpname ) ) then
      info:= MinimalRepresentationInfoData.( grpname );
    else
      info:= fail;
    fi;
    conditions:= arg{ [ 2 .. Length( arg ) ] };

    known:= fail;
    result:= fail;
    mode:= "cache";
    if not IsEmpty( conditions ) and
       IsString( conditions[ Length( conditions ) ] ) then
      mode:= conditions[ Length( conditions ) ];
      Unbind( conditions[ Length( conditions ) ] );
    fi;

    if conditions = [ NrMovedPoints ] then

      # MinimalRepresentationInfo( <grpname>, NrMovedPoints )
      if info <> fail and IsBound( info.NrMovedPoints ) then
        known:= info.NrMovedPoints;
      fi;
      if mode = "lookup" or ( mode = "cache" and known <> fail ) then
        return known;
      fi;
      if IsBound( GAPInfo.PackagesLoaded.ctbllib ) then
        # This works only if the package `CTblLib' is available.
        if   mode = "recompute" then
          result:= MinimalPermutationRepresentationInfo( grpname, "all" );
        elif known = fail then
          result:= MinimalPermutationRepresentationInfo( grpname, "one" );
        fi;
      fi;
      if result = fail or IsEmpty( result.source ) then
        # We cannot compute the value, take the stored value.
        result:= known;
      else
        # Store the computed value, and compare it with the known one.
        SetMinimalRepresentationInfo( grpname, "NrMovedPoints",
                                      result.value, result.source );
      fi;

    elif Length( conditions ) = 2 and conditions[1] = Characteristic then

      # MinimalRepresentationInfo( <grpname>, Characteristic, <p> )
      p:= conditions[2];
      if info <> fail and IsBound( info.Characteristic )
                      and IsBound( info.Characteristic.( p ) ) then
        known:= info.Characteristic.( p );
      fi;
      if mode = "lookup" or ( mode = "cache" and known <> fail ) then
        return known;
      fi;
      if known = fail or mode = "recompute" then
        # For groups with a unique minimal normal subgroup
        # whose order is not a power of the characteristic,
        # a faithful matrix representation of minimal degree is irreducible.
        # (Consider a faithful reducible representation $\rho$ in block
        # diagonal form.
        # If the restriction to the minimal normal subgroup $N$ is trivial
        # on the two factors then the restriction of $\rho$ to $N$ is a group
        # of triangular matrices, i.e., a $p$-group.)
        ordtbl:= CharacterTable( grpname );
        if ordtbl <> fail then
          minpos:= ClassPositionsOfMinimalNormalSubgroups( ordtbl );
          if Length( minpos ) = 1 then
            if p = 0 or Size( ordtbl ) mod p <> 0 then
              # Consider the ordinary character table.
              # Take the smallest degree of a faithful irreducible character.
              faith:= Filtered( Irr( ordtbl ),
                          x -> Length( ClassPositionsOfKernel( x ) ) = 1 );
              result:= rec( value:= Minimum( List( faith, x -> x[1] ) ),
                            source:= [ "computed (char. table)" ] );
            elif IsPrimeInt( p ) then
              Norder:= Sum( SizesConjugacyClasses( ordtbl ){ minpos[1] } );
              if not ( IsPrimePowerInt( Norder ) and Norder mod p = 0 ) then
                # Consider the Brauer table.
                modtbl:= ordtbl mod p;
                if modtbl <> fail then
                  faith:= Filtered( Irr( modtbl ),
                            x -> Length( ClassPositionsOfKernel( x ) ) = 1 );
                  result:= rec( value:= Minimum( List( faith, x -> x[1] ) ),
                                source:= [ "computed (char. table)" ] );
                fi;
              fi;
            fi;
          else
            # If the minimal nontrivial irreducible representation is
            # faithful then this irreducible is minimal.
            if p = 0 or Size( ordtbl ) mod p <> 0 then
              faith:= Filtered( Irr( ordtbl ),
                          x -> Length( ClassPositionsOfKernel( x ) ) = 1 );
              if not IsEmpty( faith ) then
                min:= Minimum( List( faith, x -> x[1] ) );
                if ForAll( Irr( ordtbl ),
                           x -> x[1] >= min or Set( x ) = [ 1 ] ) then
                  result:= rec( value:= min,
                                source:= [ "computed (char. table)" ] );
                fi;
              fi;
            elif IsPrimeInt( p ) then
              minpos:= List( ClassPositionsOfNormalSubgroups( ordtbl ),
                             x -> Sum( SizesConjugacyClasses( ordtbl ){ x } ) );
              if not ForAny( minpos,
                             x -> IsPrimePowerInt( x ) and x mod p = 0 ) then
                # Consider the Brauer table.
                modtbl:= ordtbl mod p;
                if modtbl <> fail then
                  faith:= Filtered( Irr( modtbl ),
                            x -> Length( ClassPositionsOfKernel( x ) ) = 1 );
                  if not IsEmpty( faith ) then
                    min:= Minimum( List( faith, x -> x[1] ) );
                    if ForAll( Irr( modtbl ),
                               x -> x[1] >= min or Set( x ) = [ 1 ] ) then
                      result:= rec( value:= min,
                                    source:= [ "computed (char. table)" ] );
                    fi;
                  fi;
                fi;
              fi;
            fi;
          fi;
        fi;
      fi;
      if result = fail then
        # We cannot compute the value, take the stored value.
        result:= known;
      else
        SetMinimalRepresentationInfo( grpname, [ "Characteristic", p ],
                                      result.value, result.source );
      fi;

    elif Length( conditions ) = 2 and conditions[1] = Size then

      # MinimalRepresentationInfo( <grpname>, Size, <q> )
      q:= conditions[2];
      p:= SmallestRootInt( q );
      if info <> fail and IsBound( info.CharacteristicAndSize )
                      and IsBound( info.CharacteristicAndSize.( p ) ) then
        info:= info.CharacteristicAndSize.( p );
        pos:= Position( info.sizes, q );
        if pos <> fail then
          known:= rec( value:= info.dimensions[ pos ],
                       source:= info.sources[ pos ] );
        elif info.complete.value then
          cont:= Filtered( [ 1 .. Length( info.sizes ) ],
                   i -> LogInt( q, p ) mod LogInt( info.sizes[i], p ) = 0 );
          known:= rec( value:= Minimum( info.dimensions{ cont } ),
                       source:= [ "computed (stored data)" ] );
        fi;
      fi;
      if mode = "lookup" or ( mode = "cache" and known <> fail ) then
        return known;
      fi;
      if known = fail or mode = "recompute" then
        # For groups with a unique minimal normal subgroup
        # whose order is not a power of the characteristic,
        # a faithful matrix representation of minimal degree is irreducible
        # (over a given field).
        ordtbl:= CharacterTable( grpname );
        if IsPosInt( q ) and IsPrimePowerInt( q ) and ordtbl <> fail then
          minpos:= ClassPositionsOfMinimalNormalSubgroups( ordtbl );
          if Length( minpos ) = 1 then
            if Size( ordtbl ) mod p <> 0 then
              # Consider the ordinary character table.
              # Take the smallest degree of a faithful irreducible character,
              # over the given field.
              faith:= Filtered( Irr( ordtbl ),
                          x -> Length( ClassPositionsOfKernel( x ) ) = 1 );
              faith:= RealizableBrauerCharacters( faith, q );
              result:= rec( value:= Minimum( List( faith, x -> x[1] ) ),
                            source:= [ "computed (char. table)" ] );
            else
              Norder:= Sum( SizesConjugacyClasses( ordtbl ){ minpos[1] } );
              if not ( IsPrimePowerInt( Norder ) and Norder mod p = 0 ) then
                # Consider the Brauer table.
                modtbl:= ordtbl mod p;
                if modtbl <> fail then
                  faith:= Filtered( Irr( modtbl ),
                            x -> Length( ClassPositionsOfKernel( x ) ) = 1 );
                  faith:= RealizableBrauerCharacters( faith, q );
                  if faith <> fail then
                    result:= rec( value:= Minimum( List( faith, x -> x[1] ) ),
                                  source:= [ "computed (char. table)" ] );
                  fi;
                fi;
              fi;
            fi;
          fi;
        fi;
      fi;
      if result = fail then
        # We cannot compute the value, take the stored value.
        result:= known;
      else
        SetMinimalRepresentationInfo( grpname, [ "Size", q ],
                                      result.value, result.source );
      fi;

    fi;

    return result;
    end );


#############################################################################
##
#F  SetMinimalRepresentationInfo( <grpname>, <op>, <value>, <source> )
##
InstallGlobalFunction( SetMinimalRepresentationInfo,
    function( grpname, op, value, source )
    local compare, info, p, q, pos;

    compare:= function( value, source, valuestored, sourcestored, type )
      if value <> valuestored then
        Print( "#E  ", type, ": incompatible minimum for `",
               grpname, "'\n" );
        return false;
      fi;
      UniteSet( sourcestored, source );
      return true;
    end;

    if IsString( source ) then
      source:= [ source ];
    fi;
    if not IsBound( MinimalRepresentationInfoData.( grpname ) ) then
      MinimalRepresentationInfoData.( grpname ):= rec();
    fi;
    info:= MinimalRepresentationInfoData.( grpname );
    if op = "NrMovedPoints" then
      if IsBound( info.NrMovedPoints ) then
        info:= info.NrMovedPoints;
        return compare( value, source,
                        info.value, info.source, "NrMovedPoints" );
      else
        info.NrMovedPoints:= rec( value:= value, source:= source );
        return true;
      fi;
    elif IsList( op ) and Length( op ) = 2
                      and op[1] = "Characteristic"
                      and ( op[2] = 0 or IsPrimeInt( op[2] ) ) then
      if not IsBound( info.Characteristic ) then
        info.Characteristic:= rec();
      fi;
      info:= info.Characteristic;
      p:= String( op[2] );
      if IsBound( info.( p ) ) then
        info:= info.( p );
        return compare( value, source,
                        info.value, info.source, "Characteristic" );
      else
        info.( p ):= rec( value:= value, source:= source );
        return true;
      fi;
    elif IsList( op ) and Length( op ) = 3
                      and op[1] = "Characteristic"
                      and IsPrimeInt( op[2] )
                      and op[3] = "complete" then
      if not IsBound( info.CharacteristicAndSize ) then
        info.CharacteristicAndSize:= rec();
      fi;
      info:= info.CharacteristicAndSize;
      p:= String( op[2] );
      if not IsBound( info.( p ) ) then
        info.( p ):= rec( sizes:= [], dimensions:= [], sources:= [] );
      fi;
      info.( p ).complete:= rec( value:= value, source:= source );
      return true;
    elif IsList( op ) and Length( op ) = 2
                      and op[1] = "Size"
                      and IsInt( op[2] ) and IsPrimePowerInt( op[2] ) then
#T change IsPrimePowerInt to include an IsInt test!
      if not IsBound( info.CharacteristicAndSize ) then
        info.CharacteristicAndSize:= rec();
      fi;
      info:= info.CharacteristicAndSize;
      q:= op[2];
      p:= String( SmallestRootInt( q ) );
      if not IsBound( info.( p ) ) then
        info.( p ):= rec( sizes:= [], dimensions:= [], sources:= [],
                          complete:= rec( value:= false, source:= "" ) );
      fi;
      info:= info.( p );
      pos:= Position( info.sizes, q );
      if pos <> fail then
        # Compare the stored and the computed value.
        return compare( value, source,
                   info.dimensions[ pos ], info.sources[ pos ], "Size" );
      elif ForAll( [ 1 .. Length( info.sizes ) ],
                   i -> not ( q = info.sizes[i] ^ LogInt( q, info.sizes[i] )
                              and info.dimensions[i] = value ) ) then
        Add( info.sizes, q );
        Add( info.dimensions, value );
        Add( info.sources, source );
        return true;
      fi;
    else
      Error( "do not known how to store this info: <value>, <source>" );
    fi;
    end );


#############################################################################
##
#F  ComputedMinimalRepresentationInfo()
##
InstallGlobalFunction( ComputedMinimalRepresentationInfo, function()
    local oldvalue, info, grpname, ordtbl, size, p, modtbl, sizes, q, r,
          entry, newvalue, diff, comp, char;

    # Save the stored list.
    oldvalue:= MinimalRepresentationInfoData;
    MakeReadWriteGlobal( "MinimalRepresentationInfoData" );
    MinimalRepresentationInfoData:= rec();

    # Add non-computed data.
    for entry in Filtered( oldvalue.datalist,
                           e -> e[4]{ [ 1 .. 4 ] } <> "comp" ) do
      SetMinimalRepresentationInfo( entry[1], entry[2], entry[3],
                                    [ entry[4] ] );
    od;

    # Recompute the data.
    for info in AtlasOfGroupRepresentationsInfo.GAPnames do
      grpname:= info[1];
      MinimalRepresentationInfo( grpname, NrMovedPoints, "recompute" );
      ordtbl:= CharacterTable( grpname );
      MinimalRepresentationInfo( grpname, Characteristic, 0, "recompute" );
      if IsBound( info[3].size ) then
        size:= info[3].size;
        for p in Set( Factors( size ) ) do
          MinimalRepresentationInfo( grpname, Characteristic, p,
                                     "recompute" );
          if ordtbl <> fail then
            modtbl:= ordtbl mod p;
            if modtbl <> fail then
              sizes:= Set( List( Irr( modtbl ),
                             phi -> SizeOfFieldOfDefinition( phi, p ) ) );
#T is this a reasonable approach?
              for q in Filtered( sizes, IsInt ) do
                MinimalRepresentationInfo( grpname, Size, q, "recompute" );
              od;
              if IsBound( MinimalRepresentationInfoData.( grpname ) ) then
                r:= MinimalRepresentationInfoData.( grpname );
                if IsBound( r.CharacteristicAndSize ) then
                  r:= r.CharacteristicAndSize;
                  if not fail in sizes then
#T can one not do better?
                    SetMinimalRepresentationInfo( grpname,
                      [ "Characteristic", p, "complete" ], true,
                      [ "computed (char. table)" ] );
                  fi;
                fi;
              fi;
            fi;
          fi;
        od;
      fi;
    od;

    # Print information about differences.
    newvalue:= MinimalRepresentationInfoData;
    newvalue.datalist:= oldvalue.datalist;
    diff:= Difference( RecNames( oldvalue ), RecNames( newvalue ) );
    if not IsEmpty( diff ) then
      Print( "#E  missing min. repr. components:\n", diff, "\n" );
    fi;
    diff:= Intersection( Difference( RecNames( newvalue ),
                                     RecNames( oldvalue ) ),
                         List( AtlasOfGroupRepresentationsInfo.GAPnames,
                               x -> x[1] ) );
    if not IsEmpty( diff ) then
      Print( "#I  new min. repr. components:\n", diff, "\n" );
    fi;
    for comp in Intersection( RecNames( newvalue ), RecNames( oldvalue ) ) do
      if oldvalue.( comp ) <> newvalue.( comp ) then
        Print( "#I  min. repr. differences for ", comp, "\n" );
        if IsBound( oldvalue.( comp ).NrMovedPoints ) and
           IsBound( newvalue.( comp ).NrMovedPoints ) and
           oldvalue.( comp ).NrMovedPoints.source
             <> newvalue.( comp ).NrMovedPoints.source then
          Print( "#I  (different `source' components for NrMovedPoints:\n",
                 "#I  ", oldvalue.( comp ).NrMovedPoints.source, "\n",
                 "#I   -> ", newvalue.( comp ).NrMovedPoints.source, ")\n" );
        fi;
        if IsBound( oldvalue.( comp ).Characteristic ) and
           IsBound( newvalue.( comp ).Characteristic ) then
          for char in Intersection(
                          RecNames( oldvalue.( comp ).Characteristic ),
                          RecNames( newvalue.( comp ).Characteristic ) ) do
            if oldvalue.( comp ).Characteristic.( char ).source
                 <> newvalue.( comp ).Characteristic.( char ).source then
              Print( "#I  (different `source' components for characteristic ",
                     char, ":\n",
                     "#I  ", oldvalue.( comp ).Characteristic.( char ).source,
                     "\n#I   -> ",
                     newvalue.( comp ).Characteristic.( char ).source,
                     ")\n" );
            fi;
          od;
        fi;
      fi;
    od;

    # Reinstall the old value.
    MinimalRepresentationInfoData:= oldvalue;
    MakeReadOnlyGlobal( "MinimalRepresentationInfoData" );

    # Return the new value.
    return newvalue;
    end );


#############################################################################
##
#F  StringOfMinimalRepresentationInfoData( <record> )
##
InstallGlobalFunction( StringOfMinimalRepresentationInfoData,
    function( record )
    local lines, grpname, info, src, infoc, p, i, result, line;

    lines:= [];
    for grpname in Intersection( RecNames( record ),
                       List( AtlasOfGroupRepresentationsInfo.GAPnames,
                             x -> x[1] ) ) do
      info:= record.( grpname );
      if IsBound( info.NrMovedPoints ) then
        for src in info.NrMovedPoints.source do
          Add( lines, [ src{ [ 1 .. 4 ] } = "comp",
                        Concatenation(
                            "[\"", grpname,
                            "\",\"NrMovedPoints\",",
                            String( info.NrMovedPoints.value ),
                            ",\"", src, "\"],\n" ) ] );
        od;
      fi;
      if IsBound( info.Characteristic ) then
        infoc:= info.Characteristic;
        for p in List( Set( List( RecNames( infoc ), Int ) ), String ) do
          for src in infoc.( p ).source do
            Add( lines, [ src{ [ 1 .. 4 ] } = "comp",
                          Concatenation(
                              "[\"", grpname,
                              "\",[\"Characteristic\",", String( p ), "],",
                              String( infoc.( p ).value ),
                              ",\"", src, "\"],\n" ) ] );
          od;
        od;
      fi;
      if IsBound( info.CharacteristicAndSize ) then
        infoc:= info.CharacteristicAndSize;
        for p in List( Set( List( RecNames( infoc ), Int ) ), String ) do
          for i in [ 1 .. Length( infoc.( p ).sizes ) ] do
            for src in infoc.( p ).sources[i] do
              Add( lines, [ src{ [ 1 .. 4 ] } = "comp",
                            Concatenation(
                                "[\"", grpname,
                                "\",[\"Size\",", String( infoc.( p ).sizes[i] ),
                                "],", String( infoc.( p ).dimensions[i] ),
                                ",\"", src, "\"],\n" ) ] );
            od;
          od;
          if infoc.( p ).complete.value then
            for src in infoc.( p ).complete.source do
              Add( lines, [ src{ [ 1 .. 4 ] } = "comp",
                            Concatenation(
                                "[\"", grpname,
                                "\",[\"Characteristic\",", String( p ),
                                ",\"complete\"],true,\"",
                                src, "\"],\n" ) ] );
            od;
          fi;
        od;
      fi;
    od;

    result:= "\nMinimalRepresentationInfoData.datalist:= [\n";
    Append( result, "# non-computed values\n" );
    for line in List( Filtered( lines, l -> not l[1] ), l -> l[2] ) do
      Append( result, line );
    od;
    Append( result, "\n" );
    Append( result, "# computed values\n" );
    for line in List( Filtered( lines, l -> l[1] ), l -> l[2] ) do
      Append( result, line );
    od;
    Append( result, "];;\n\n" );
    Append( result,
            "for entry in MinimalRepresentationInfoData.datalist do\n" );
    Append( result,
            "  CallFuncList( SetMinimalRepresentationInfo, entry );\n" );
    Append( result, "od;\n" );

    return result;
    end );


#############################################################################
##
#E

