#############################################################################
##
#W  ctdbattr.g                  GAP table library               Thomas Breuer
##
#H  @(#)$Id: ctdbattr.g,v 1.1 2008/11/14 17:14:00 gap Exp $
##
#Y  Copyright (C)  2007,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations for the database id enumerator
##  `CTblLibData.IdEnumerator' and its database attributes.
##  See the GAP package `Browse' for technical details.
##  Among others, this makes the data for the attribute
##  `GroupInfoForCharacterTable' available.
##
##  The component `reverseEval' is used only by the function
##  `CharacterTableForGroupInfo', it is not needed by the database attribute
##  handling mechanism.
##
Revision.ctdbattr_g :=
    "@(#)$Id: ctdbattr.g,v 1.1 2008/11/14 17:14:00 gap Exp $";


#############################################################################
##
#V  CTblLibData
##
##  We introduce a new global variable for the database aspects.
##  Using <Ref Var="LIBTABLE"/> also for this purpose would have had the
##  disadvantage that replacing the global settings in the functions
##  <Ref Func="CTblLibData.SaveTableAccessFunctions"/> and
##  <Ref Func="CTblLibData.RestoreTableAccessFunctions"/> would become more
##  complicated.
##
BindGlobal( "CTblLibData", rec() );


#############################################################################
##
##  Provide utilities for the computation of database attribute values.
##  They allow one to access table data without actually creating the tables.
##

# a special component ...
CTblLibData.attributesRelevantForGroupInfoForCharacterTable:= [];

CTblLibData.prepare:= function( attr )
  CTblLibData.unload:= LIBTABLE.unload;
  LIBTABLE.unload:= false;
end;

CTblLibData.cleanup:= function( attr )
  LIBTABLE.unload:= CTblLibData.unload;
  Unbind( CTblLibData.unload );
end;

CTblLibData.MyIdFunc:= function( arg ); end;

CTblLibData.TABLE_ACCESS_FUNCTIONS:= [
  rec(),
  rec( 
       # These functions are used in the data files.
       LIBTABLE := rec( LOADSTATUS := rec(), clmelab := [], clmexsp := [] ),
       SET_TABLEFILENAME := CTblLibData.MyIdFunc,
       GALOIS := CTblLibData.MyIdFunc,
       TENSOR := CTblLibData.MyIdFunc,
       EvalChars := CTblLibData.MyIdFunc,
       ALF := CTblLibData.MyIdFunc,
       ACM := CTblLibData.MyIdFunc,
       ARC := CTblLibData.MyIdFunc,
       NotifyNameOfCharacterTable := CTblLibData.MyIdFunc,
       ALN := CTblLibData.MyIdFunc,
       MBT := CTblLibData.MyIdFunc,
       MOT := CTblLibData.MyIdFunc,
      ) ];

CTblLibData.SaveTableAccessFunctions := function()
  local name;

  if CTblLibData.TABLE_ACCESS_FUNCTIONS[1] <> rec() then
    Info( InfoCharacterTable, 2, "functions were already saved" );
    return;
  fi;

Print( "#I  before save!\n" );
  for name in RecNames( CTblLibData.TABLE_ACCESS_FUNCTIONS[2] ) do
    CTblLibData.TABLE_ACCESS_FUNCTIONS[1].( name ):= [ ValueGlobal( name ) ];
    if IsReadOnlyGlobal( name ) then
      Add( CTblLibData.TABLE_ACCESS_FUNCTIONS[1].( name ), "readonly" );
      MakeReadWriteGlobal( name );
    fi;
    UnbindGlobal( name );
    ASS_GVAR( name, CTblLibData.TABLE_ACCESS_FUNCTIONS[2].( name ) );
  od;
end;

CTblLibData.RestoreTableAccessFunctions := function()
  local name;

  if CTblLibData.TABLE_ACCESS_FUNCTIONS[1] = rec() then
    Info( InfoCharacterTable, 2, "cannot restore without saving" );
    return;
  fi;

  for name in RecNames( CTblLibData.TABLE_ACCESS_FUNCTIONS[2] ) do
    UnbindGlobal( name );
    ASS_GVAR( name, CTblLibData.TABLE_ACCESS_FUNCTIONS[1].( name )[1] );
    if Length( CTblLibData.TABLE_ACCESS_FUNCTIONS[1].( name ) ) = 2 then
      MakeReadOnlyGlobal( name );
    fi;
    Unbind( CTblLibData.TABLE_ACCESS_FUNCTIONS[1].( name ) );
  od;
Print( "#I  after restore!\n" );
end;


#############################################################################
##
##  The argument <A>pairs</A> must be a list of pairs
##  <C>[ <A>nam</A>, <A>fun</A> ]</C>
##  where <A>nam</A> is the name of a function to be reassigned during the
##  reread process (such as <C>"MOT"</C>, <C>"ARC"</C>),
##  and <A>fun</A> is the corresponding value.
##
CTblLibData.ComputeCharacterTableInfoByScanningLibraryFiles :=
    function( pairs )
    local filenames, pair, name;

    # Remember the names of all character table library files.
    filenames:= LIBLIST.files;

    # Disable the table library access.
    CTblLibData.SaveTableAccessFunctions();

    # Define appropriate access functions.
    for pair in pairs do
      ASS_GVAR( pair[1], pair[2] );
    od;

    # Clear the cache.
    CTblLibData.CharacterTableInfo:= rec();

    # Loop over the library files.
    for name in filenames do
Print( "#I  processing file ", name, ".tbl\n" );
      ReadPackage( "ctbllib", Concatenation( "data/", name, ".tbl" ) );
    od;

    # Restore the ordinary table library access.
    CTblLibData.RestoreTableAccessFunctions();
end;


#############################################################################
##
##  Create the database id enumerator to which the database attributes refer.
##
CTblLibData.IdEnumerator:= DatabaseIdEnumerator( rec(
    identifiers:= Set( AllCharacterTableNames() ),
    isSorted:= true,
    entry:= function( idenum, id ) return CharacterTable( id ); end,
    version:= LIBLIST.lastupdated,
    update:= ReturnTrue,
# replace this ...!
    viewSort:= BrowseData.CompareAsNumbersAndNonnumbers,
    align:= "lt",
  ) );;


#############################################################################
##
#V  CTblLibData.IdEnumerator.attributes.Size
##
DatabaseAttributeAdd( CTblLibData.IdEnumerator, rec(
  identifier:= "Size",
  description:= "sizes of GAP library character tables",
  type:= "values",
  name:= "Size",
  dataDefault:= fail,
  neededAttributes:= [],
  prepareAttributeComputation:= function( attr )
    CTblLibData.prepare( attr );
    CTblLibData.ComputeCharacterTableInfoByScanningLibraryFiles( [
      [ "MOT", function( arg )
          local record;
            record:= rec( InfoText := arg[2],
                          SizesCentralizers := arg[3],
                    #     ComputedPowerMaps := arg[4],
                    #     Irr:= arg[5],
                    # otherwise GAP explodes ...
                    #     AutomorphismsOfTable := arg[6],
                         );
            if IsBound( arg[7] ) then
              record.ConstructionInfoCharacterTable:= arg[7];
            fi;
            CTblLibData.CharacterTableInfo.( arg[1] ):= record;
          end ] ] );
#   ARC:= function( arg )
#     if   arg[2] = "maxes" then
#       CTblLibData.CharacterTableInfo.( arg[1] ).Maxes:= arg[3];
#     fi;
    end,
  cleanupAfterAttributeComputation:= function( attr )
    CTblLibData.cleanup( attr );
    Unbind( CTblLibData.CharacterTableInfo );
    end,
  create:= function( attr, id )
    local r, other;

    if IsBound( CTblLibData.CharacterTableInfo.( id ) ) then
      r:= CTblLibData.CharacterTableInfo.( id );
      if IsList( r.SizesCentralizers ) then
        return r.SizesCentralizers[1];
      elif IsBound( r.ConstructionInfoCharacterTable )
         and IsList( r.ConstructionInfoCharacterTable ) then
        if r.ConstructionInfoCharacterTable[1] in
                [ "ConstructDirectProduct", "ConstructIsoclinic" ]
           and Length( r.ConstructionInfoCharacterTable[2] ) = 1
           and Length( r.ConstructionInfoCharacterTable[2][1] ) = 1
           and IsString( r.ConstructionInfoCharacterTable[2][1][1] ) then
          other:= LibInfoCharacterTable(
                    r.ConstructionInfoCharacterTable[2][1][1] ).firstName;
          if IsBound( CTblLibData.CharacterTableInfo.( other ) ) then
            other:= CTblLibData.CharacterTableInfo.( other );
Print( "transfer from ", r.ConstructionInfoCharacterTable[2][1], " to ", id, "\n" );
            return other.SizesCentralizers[1];
          fi;
#        elif r.ConstructionInfoCharacterTable[1] in
#                [ "ConstructPermuted" ] then
#          other:= LibInfoCharacterTable(
#                    r.ConstructionInfoCharacterTable[2][1] ).firstName;
#          if IsBound( CTblLibData.CharacterTableInfo.( other ) ) then
#            other:= CTblLibData.CharacterTableInfo.( other );
#Print( "transfer from ", r.ConstructionInfoCharacterTable[2][1], " to ", id, "\n" );
#            return other.SizesCentralizers[1];
#-> need not be a list!
#          fi;
        fi;
      fi;
Print( "hard test for ", id, "\n" );
        return Size( CharacterTable( id ) );
    else
Error( "strange id: ", id );
    fi;
    end,
  check:= ReturnTrue,

  viewSort:= BrowseData.CompareAsNumbersAndNonnumbers,
#T better use BrowseData.CompareLenLex!
  sortParameters:= [ "add counter on categorizing", "yes" ],
  widthCol:= 25,
  ) );
#T do not prepend `"size "' on categorizing?


#############################################################################
##
#V  CTblLibData.IdEnumerator.attributes.atlas
##
if LoadPackage( "atlasrep" ) = true then
Add( CTblLibData.attributesRelevantForGroupInfoForCharacterTable, "atlas" );
DatabaseAttributeAdd( CTblLibData.IdEnumerator, rec(
  identifier:= "atlas",
  description:= "mapping between the GAP char. table library and Atlas groups",
  type:= "pairs",
  datafile:= Filename( DirectoriesPackageLibrary( "ctbllib", "data" ),
                       "grp_atlas.dat" ),
  dataDefault:= [],
  isSorted:= true,
  eval:= function( attr, l )
           local result, entry;

           result:= [];
           for entry in l do
             if Length( entry ) = 1 then
               Add( result, [ "AtlasGroup", entry ] );
             else
               Add( result, [ "AtlasSubgroup", entry ] );
             fi;
           od;
           return result;
         end,
  reverseEval:= function( attr, info )
           local pos, entry;
  
           if ( info[1] = "AtlasGroup" and Length( info[2] ) = 1 ) or
              ( info[1] = "AtlasSubgroup" and Length( info[2] ) = 2 ) then
             if not IsBound( attr.data )  then
               Read( attr.datafile );
             fi;
             for entry in Concatenation( attr.data.automatic,
                                         attr.data.nonautomatic ) do
               if info[2] in entry[2] then
                 return entry[1];
               fi;
             od; 
           fi; 
           return fail;
         end,
#T hier!
  neededAttributes:= [],
  prepareAttributeComputation:= CTblLibData.prepare,
  cleanupAfterAttributeComputation:= CTblLibData.cleanup,
  create:= function( attr, id )
    local tbl, result, entry, r, super, pos, prog;

    # Delegate to a better table where appropriate.
    tbl:= CharacterTable( id );
    if HasConstructionInfoCharacterTable( tbl ) and
       IsList( ConstructionInfoCharacterTable( tbl ) ) and
       ConstructionInfoCharacterTable( tbl )[1] = "ConstructPermuted" and
       Length( ConstructionInfoCharacterTable( tbl )[2] ) = 1 then
      tbl:= CharacterTable( ConstructionInfoCharacterTable( tbl )[2][1] );
    fi;
    result:= [];

    # Check whether the name belongs to an Atlas group.
    entry:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                   l -> l[1] = Identifier( tbl ) );
    if entry <> fail then
      Add( result, [ entry[1] ] );
    fi;
    # Check whether the name belongs to a maximal subgroup of an Atlas group
    # such that a representation of the group and a straight line program
    # for the subgroup exist.
    for r in ComputedClassFusions( tbl ) do
      if Length( ClassPositionsOfKernel( r.map ) ) = 1 then
        super:= CharacterTable( r.name );
        if super <> fail and HasMaxes( super ) then
          entry:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                         l -> l[1] = r.name );
          if entry <> fail then
            pos:= Position( Maxes( super ), Identifier( tbl ) );
            if pos <> fail then
              prog:= AtlasProgram( entry[1], "maxes", pos );
              if prog <> fail and
                 OneAtlasGeneratingSetInfo( entry[1], prog.standardization )
                   <> fail then
                Add( result, [ entry[1], pos ] );
              fi;
            fi;
          fi;
        fi;
      fi;
    od;
    if IsEmpty( result ) then
      return attr.dataDefault;
    else
      return result;
    fi;
    end,
  string:= CTblLibGroupDataString,
  check:= ReturnTrue,
  ) );
fi;


#############################################################################
##
#V  CTblLibData.IdEnumerator.attributes.basic
##
Add( CTblLibData.attributesRelevantForGroupInfoForCharacterTable, "basic" );
DatabaseAttributeAdd( CTblLibData.IdEnumerator, rec(
  identifier:= "basic",
  description:= "mapping between the GAP libraries of char. tables and basic groups",
  type:= "pairs",
  datafile:= Filename( DirectoriesPackageLibrary( "ctbllib", "data" ),
                       "grp_basic.dat" ),
  dataDefault:= [],
  isSorted:= true,
  neededAttributes:= [],
  prepareAttributeComputation:= CTblLibData.prepare,
  cleanupAfterAttributeComputation:= CTblLibData.cleanup,
  create:= function( attr, id )
    local tbl, result, type, nsg, simp;

    tbl:= CharacterTable( id );
    result:= [];
    if   IsSimpleCharacterTable( tbl ) then
      type:= IsomorphismTypeInfoFiniteSimpleGroup( tbl );
      if   type.series = "A" then
        Add( result, [ "AlternatingGroup", [ type.parameter ] ] );
#T if n = 5 then add PSL(2,5), PSL(2,4), ...
#T An for n = 3, 4 ?
      elif type.series = "B" and IsEvenInt( type.parameter[2] ) then
        Add( result, [ "PSp", [ 2 * type.parameter[1], type.parameter[2] ] ] );
      elif type.series = "C" then
        Add( result, [ "PSp", [ 2 * type.parameter[1], type.parameter[2] ] ] );
      elif type.series = "L" then
        Add( result, [ "PSL", type.parameter ] );
      elif type.series = "2A" then
        Add( result, [ "PSU", [ type.parameter[1] + 1, type.parameter[2] ] ] );
      elif type.series = "2B" then
        Add( result, [ "SuzukiGroup", [ type.parameter ] ] );
      elif type.series = "2G" then
        Add( result, [ "ReeGroup", [ type.parameter ] ] );
      elif type.series = "Spor" then
        if   type.name = "M(11)" then
          Add( result, [ "MathieuGroup", [ 11 ] ] );
        elif type.name = "M(12)" then
          Add( result, [ "MathieuGroup", [ 12 ] ] );
        elif type.name = "M(22)" then
          Add( result, [ "MathieuGroup", [ 22 ] ] );
        elif type.name = "M(23)" then
          Add( result, [ "MathieuGroup", [ 23 ] ] );
        elif type.name = "M(24)" then
          Add( result, [ "MathieuGroup", [ 24 ] ] );
        fi;
#T more series?
      fi;
    elif IsAlmostSimpleCharacterTable( tbl ) then
      nsg:= ClassPositionsOfMinimalNormalSubgroups( tbl )[1];
      simp:= CharacterTablesOfNormalSubgroupWithGivenImage( tbl, nsg );
      if not IsEmpty( simp ) then
        simp:= simp[1][1];
        type:= IsomorphismTypeInfoFiniteSimpleGroup( simp );
        if   type.series = "A" and
             ( type.parameter <> 6
               or not 8 in OrdersClassRepresentatives( tbl ) ) then
          Add( result, [ "SymmetricGroup", [ type.parameter ] ] );
#T Sn for n = 2, 3, 4 ?
        fi;
      fi;
      if Size( tbl ) = 720 and NrConjugacyClasses( tbl ) = 8 then
        Add( result, [ "MathieuGroup", [ 10 ] ] );
      fi;
    fi;
    if Size( tbl ) = 72 and NrConjugacyClasses( tbl ) = 6 then
      Add( result, [ "MathieuGroup", [ 9 ] ] );
    fi;
    if IsDihedralCharacterTable( tbl ) then
      Add( result, [ "DihedralGroup", [ Size( tbl ) ] ] );
    fi;
    if not IsEmpty( result ) then
      return result;
    fi;
    return attr.dataDefault;
    end,
#T reverseEval function?
  string:= CTblLibGroupDataString,
  check:= ReturnTrue,
  ) );


#############################################################################
##
#V  CTblLibData.IdEnumerator.attributes.perf
##
Add( CTblLibData.attributesRelevantForGroupInfoForCharacterTable, "perf" );
DatabaseAttributeAdd( CTblLibData.IdEnumerator, rec(
  identifier:= "perf",
  description:= "mapping between the GAP libraries of char. tables and perfect groups",
  type:= "pairs",
  datafile:= Filename( DirectoriesPackageLibrary( "ctbllib", "data" ),
                       "grp_perf.dat" ),
  dataDefault:= [],
  isSorted:= true,
  eval:= function( attr, l )
           return List( l, val -> [ "PerfectGroup", val ] );
         end,
  reverseEval:= function( attr, info )
           local pos, entry;

           if info[1] = "PerfectGroup" then
             if not IsBound( attr.data )  then
               Read( attr.datafile );
             fi;
             for entry in Concatenation( attr.data.automatic,
                                         attr.data.nonautomatic ) do
               if info[2] in entry[2] then
                 return entry[1];
               fi;
             od;
           fi;
           return fail;
         end,
  neededAttributes:= [],
  prepareAttributeComputation:= CTblLibData.prepare,
  cleanupAfterAttributeComputation:= CTblLibData.cleanup,
  create:= function( attr, id )
      local tbl, result, n, nr, pos, type, i, G;

      tbl:= CharacterTable( id );
      result:= [];
      if IsPerfectCharacterTable( tbl ) then
        n:= Size( tbl );
        nr:= NumberPerfectLibraryGroups( n );
        if nr <> 0 then
          if   NumberPerfectGroups( n ) = 1 then
            # If there is only one perfect group of this order
            # (and we believe this) then we assign the table name to it.
            pos:= 1;
          elif IsSimpleCharacterTable( tbl ) then
            # If the table is simple then compare isomorphism types.
            type:= IsomorphismTypeInfoFiniteSimpleGroup( tbl );
            for i in [ 1 .. nr ] do
              G:= Image( IsomorphismPermGroup( PerfectGroup( n, i ) ) );
              if IsSimpleGroup( G ) and
                 IsomorphismTypeInfoFiniteSimpleGroup( G ) = type then
                pos:= i;
                break;
              fi;
            od;
          else
            # Do the hard test.
            for i in [ 1 .. nr ] do
              G:= Image( IsomorphismPermGroup( PerfectGroup( n, i ) ) );
              if NrConjugacyClasses( G ) = NrConjugacyClasses( tbl ) and
                 IsRecord( TransformingPermutationsCharacterTables(
                           CharacterTable( G ), tbl ) ) then
                pos:= i;
                break;
              fi;
            od;
          fi;
          Add( result, [ n, pos ] );
        fi;
      fi;
      if IsEmpty( result ) then
        return attr.dataDefault;
      fi;
      return result;
    end,
  string:= CTblLibGroupDataString,
  check:= ReturnTrue,
  ) );


#############################################################################
##
#V  CTblLibData.IdEnumerator.attributes.prim
##
Add( CTblLibData.attributesRelevantForGroupInfoForCharacterTable, "prim" );
DatabaseAttributeAdd( CTblLibData.IdEnumerator, rec(
  identifier:= "prim",
  description:= "mapping between the GAP libraries of char. tables and prim. groups",
  type:= "pairs",
  datafile:= Filename( DirectoriesPackageLibrary( "ctbllib", "data" ),
                       "grp_prim.dat" ),
  dataDefault:= [],
  isSorted:= true,
  eval:= function( attr, l )
      return List( l[2], val -> [ "PrimitiveGroup", val ] );
    end,
  reverseEval:= function( attr, info )
           local pos, entry;

           if info[1] = "PrimitiveGroup" then
             if not IsBound( attr.data )  then
               Read( attr.datafile );
             fi;
             for entry in Concatenation( attr.data.automatic,
                                         attr.data.nonautomatic ) do
               if info[2] in entry[2][2] then
                 return entry[1];
               fi;
             od;
           fi;
           return fail; 
         end,
  neededAttributes:= [],
  prepareAttributeComputation:= function( attr )
    local result, i;

    CTblLibData.unload:= LIBTABLE.unload;
    LIBTABLE.unload:= false;

    # Reading library files causes frequent calls to `Factorial',
    # for numbers up to the largest primitive degree of the library.
    # The speedup gained by caching these numbers is remarkable,
    # at the cost of storing the values.
    LIBTABLE.FactorialCACHE:= [];
    LIBTABLE.OldFactorial:= Factorial;
    MakeReadWriteGlobal( "Factorial" );
    UnbindGlobal( "Factorial" );
    BindGlobal( "Factorial", function( n )
        if n < 0 then
          Error( "<n> must be nonnegative" );
        elif IsBound( LIBTABLE.FactorialCACHE[n] ) then
          return LIBTABLE.FactorialCACHE[n];
        else
          return LIBTABLE.OldFactorial( n );
        fi;
    end );

    result:= 1;
    for i in [ 1 ..  PRIMRANGE[ Length( PRIMRANGE ) ] ] do
      result:= result * i;
      LIBTABLE.FactorialCACHE[i]:= result;
    od;
    end,

  cleanupAfterAttributeComputation:= function( attr )
    LIBTABLE.unload:= CTblLibData.unload;
    Unbind( CTblLibData.unload );

    UnbindGlobal( "Factorial" );
    BindGlobal( "Factorial", LIBTABLE.OldFactorial );
    Unbind( LIBTABLE.OldFactorial );
    Unbind( LIBTABLE.FactorialCACHE );
    end,

  create:= function( attr, id )
    local tbl, nsg, n, solvmin, deg, cand, result, type, G, simp, outinfo,
          info, facttbl, der, socle, soclefact, tbls, tblpos, cand2, try,
          comment1, fuscand, s, pos, comment2;

    # Delegate to a better table where appropriate.
    tbl:= CharacterTable( id );
    if HasConstructionInfoCharacterTable( tbl ) and
       IsList( ConstructionInfoCharacterTable( tbl ) ) and
       ConstructionInfoCharacterTable( tbl )[1] = "ConstructPermuted" and
       Length( ConstructionInfoCharacterTable( tbl )[2] ) = 1 then
      tbl:= CharacterTable( ConstructionInfoCharacterTable( tbl )[2][1] );
    fi;

    # Let $G$ be a primitive permutation group of degree $n$
    # that contains a *solvable* minimal normal subgroup $N$.
    # Then we have $|N| = n$, $|G|$ divides $|N|!$, $G$ is centerless,
    # $N$ is the unique minimal normal subgroup of $G$,
    # and $G$ is a split extension of $N$.
    # (Proof:
    # Let $M$ be a core-free maximal subgroup of index $n$ in $G$.
    # Then $M \cap N$ is invariant under $M$ and (since $N$ is abelian)
    # under $N$, and because $N$ is not contained in $M$, we have $G = M N$,
    # so $M \cap N$ is normal in $G$ and hence $|M \cap N| = 1$.
    # This implies $n = [G:M] = |N|$, and clearly $G$ embeds into $Sym(n)$.
    # If $G$ would contain a nontrivial central subgroup $Z$ of prime order
    # then $|M \cap Z| = 1$ holds, which implies that $M$ is normal in $G$,
    # a contradiction.
    # Obviously $G$ cannot contain another *solvable* minimal normal
    # subgroup.  Suppose there is a nonsolvable minimal normal subgroup $T$,
    # say.  Then $T$ commutes with $N$, so $T \cap M$ is normal in $M$ and
    # commutes with $N$, hence is normal in $G$ and thus trivial --but this
    # implies that $G$ is a split extension of $T$ with $M$, hence the order
    # of $T$ is the prime power $n$, a contradiction.)
    # So we can immediately exclude tables with nontrivial centre,
    # as well as tables with a minimal normal subgroup $N$ of prime power
    # order that is either *larger* than the largest degree in the library
    # of primitive groups
    # or *too small* in the sense that the group order does not divide the
    # factorial of the order of $N$.
    # Also note that for tables with a minimal normal subgroup $N$
    # of prime power order, the only possible degree is $|N|$,
    # and the table must admit a class fusion from the factor modulo $N$,
    # corresponding to the embedding of the point stabilizer
    # (so nonsplit extensions may be excluded using the character table).
    if 1 < Length( ClassPositionsOfCentre( tbl ) ) then
      return attr.dataDefault;
    fi;
    nsg:= List( ClassPositionsOfMinimalNormalSubgroups( tbl ),
                x -> Sum( SizesConjugacyClasses( tbl ){ x } ) );
    n:= Size( tbl );
    solvmin:= Filtered( nsg, IsPrimePowerInt );
    if   Length( solvmin ) >= 1 and Length( nsg ) > 1 then
      # A primitive group containing a solvable minimal subgroup cannot
      # contain another minimal normal subgroup.
      return attr.dataDefault;
    elif Length( solvmin ) = 1 then
      # We know the possible degree.
      deg:= solvmin[1];
      if deg > PRIMRANGE[ Length( PRIMRANGE ) ]
         or Factorial( deg ) mod n <> 0 then
        return attr.dataDefault;
      fi;
      # Use only those invariants that are already stored for the groups
      # in the GAP library of primitive groups;
      # for example, do not force computing the number of conjugacy classes.
      cand:= AllPrimitiveGroups( NrMovedPoints, deg,
                 Size, n,
                 IsSimple, IsSimple( tbl ),
                 IsSolvable, IsSolvable( tbl ),
                 IsPerfect, IsPerfect( tbl ) );
    else
      # Use only those invariants that are already stored for the groups
      # in the GAP library of primitive groups;
      # for example, do not force computing the number of conjugacy classes.
      cand:= AllPrimitiveGroups( Size, n,
                 IsSimple, IsSimple( tbl ),
                 IsSolvable, IsSolvable( tbl ),
                 IsPerfect, IsPerfect( tbl ) );
    fi;
    if cand = [] then
      return attr.dataDefault;
    fi;
    result:= [];
    if   IsSimple( tbl ) then
      # The isomorphism type of simple tables can be determined.
      # Simply assign the name to the simple group.
      type:= IsomorphismTypeInfoFiniteSimpleGroup( tbl );
      for G in cand do
        if IsomorphismTypeInfoFiniteSimpleGroup( G ) = type then
          Add( result, [ NrMovedPoints( G ), PrimitiveIdentification( G ) ] );
        fi;
      od;
      return [ "simple group", result ];
    elif IsPerfect( tbl ) and NumberPerfectGroups( n ) = 1 then
      # If there is a unique perfect group of this order then we are done.
      for G in cand do
        Add( result, [ NrMovedPoints( G ), PrimitiveIdentification( G ) ] );
      od;
      return [ "unique perfect group of its order", result ];
    elif IsAlmostSimpleCharacterTable( tbl ) then
      # Determine the isomorphism type of the socle.
      # If the character table library provides enough information about the
      # automorphic extensions of this group then try to determine the
      # isomorphism type of the almost simple group.
      nsg:= ClassPositionsOfMinimalNormalSubgroups( tbl )[1];
      simp:= CharacterTablesOfNormalSubgroupWithGivenImage( tbl, nsg );
      if not IsEmpty( simp )
         and HasExtensionInfoCharacterTable( simp[1][1] ) then
        simp:= simp[1][1];
        type:= IsomorphismTypeInfoFiniteSimpleGroup( simp );
        # The following list contains pairs `[ <nam>, <indices> ]'
        # where <nam> runs over the suffixes of the names of
        # full automorphism groups of simple groups that occur in the
        # character table library, and <indices> is a list of orders of
        # socle factors for which the isomorphism type of the extension
        # is uniquely determined by these orders.
        outinfo:= [
                    [ "2",      [ 2 ] ],
                    [ "3",      [ 3 ] ],
                    [ "4",      [ 2, 4 ] ],
                    [ "2^2",    [ 4 ] ],
                    [ "5",      [ 5 ] ],
                    [ "6",      [ 2, 3, 6 ] ],
                    [ "3.2",    [ 2, 3, 6 ] ],
                    [ "(2x4)",  [ 8 ] ],
                    [ "D8",     [ 8 ] ],
                    [ "D12",    [ 3, 4, 12 ] ],
                    [ "(2xD8)", [ 16 ] ],
                    [ "(3xS3)", [ 2, 9, 18 ] ],
                    [ "5:4",    [ 2, 4, 5, 10, 20 ] ],
                    [ "S4",     [ 3, 6, 8, 12, 24 ] ],
                  ];
        info:= ExtensionInfoCharacterTable( simp )[2];
        info:= First( outinfo, x -> x[1] = info );
        facttbl:= tbl / nsg;
        if   info = fail then
          Print( "#E problem: is the table of ", id,
                 " really almost simple?\n ");
        elif    Size( tbl ) / Size( simp ) in info[2]
             or ( info[1] = "(2x4)" and Size( tbl ) / Size( simp ) = 4
                                    and not IsCyclic( facttbl ) )
             or ( info[1] = "D8" and Size( tbl ) / Size( simp ) = 4
                                 and IsCyclic( facttbl ) )
             or ( info[1] = "D12" and Size( tbl ) / Size( simp ) = 6
                                  and IsCyclic( facttbl ) )
             or ( info[1] = "(3xS3)" and Size( tbl ) / Size( simp ) = 6 )
             or ( info[1] = "S4" and Size( tbl ) / Size( simp ) = 4
                                 and IsCyclic( facttbl ) ) then
          # We can identify the group.
          for G in cand do
            if IsAlmostSimpleGroup( G ) then
              der:= DerivedSeriesOfGroup( G );
              socle:= der[ Length( der ) ];
              soclefact:= G / socle;
              if type = IsomorphismTypeInfoFiniteSimpleGroup( socle ) and
                 ( Size( tbl ) / Size( simp ) in info[2] or
                   ( info[1] = "(2x4)" and not IsCyclic( soclefact ) ) or
                   ( info[1] = "D8" and IsCyclic( soclefact ) ) or
                   ( info[1] = "D12" and IsCyclic( soclefact ) ) or
                   ( info[1] = "(3xS3)" and IsCyclic( soclefact )
                                        and IsCyclic( facttbl ) ) or
                   ( info[1] = "(3xS3)" and not IsCyclic( soclefact )
                                        and not IsCyclic( facttbl ) ) or
                   ( info[1] = "S4" and IsCyclic( soclefact ) ) ) then
                Add( result, [ NrMovedPoints( G ),
                               PrimitiveIdentification( G ) ] );
              fi;
            fi;
          od;
          return [ Concatenation( "unique almost simple group with the ",
                                  "given socle and socle factor" ),
                   result ];
        else
          # Try to identify the extension of the socle by excluding
          # all but one of the possibilities
          # if we have all tables for these possibilities.
          outinfo:= [
                      [ "2^2",    [ [ 2, [ "2_1", "2_2", "2_3" ] ] ] ],
                      [ "(2x4)",  [ [ 2, [ "2_1", "2_2", "2_3" ] ],
                                    [ 4, [ "2^2", "4_1", "4_2" ] ] ] ],
                      [ "D8",     [ [ 2, [ "2_1", "2_2", "2_3" ] ],
                                    [ 4, [ "4", "(2^2)_{122}",
                                           "(2^2)_{133}" ] ] ] ],
                      [ "D12",    [ [ 2, [ "2_1", "2_2", "2_3" ] ],
                                    [ 6, [ "6", "3.2_2", "3.2_3" ] ] ] ],
                      [ "(3xS3)", [ [ 3, [ "3_1", "3_2", "3_3" ] ] ] ],
                      [ "S4",     [ [ 2, [ "2_1", "2_2" ] ],
                                    [ 4, [ "4", "(2^2)_{111}",
                                           "(2^2)_{122}" ] ] ] ],
                    ];
          info:= First( outinfo, x -> x[1] = info[1] );
          if info <> fail then
            info:= First( info[2], x -> x[1] = Size( tbl ) / Size( simp ) );
            if info <> fail then
              tbls:= List( info[2],
                           s -> CharacterTable( Concatenation(
                                    Identifier( simp ), ".", s ) ) );
              if ForAll( tbls, IsCharacterTable ) then
                tblpos:= First( [ 1 .. Length( tbls ) ],
                                i -> TransformingPermutationsCharacterTables(
                                         tbl, tbls[i] ) <> fail );
                cand2:= [];
                for G in cand do
                  if IsAlmostSimpleGroup( G ) then
                    try:= FindTableForGroup( G, tbls, tblpos );
                    if try = true then
                      Add( result, [ NrMovedPoints( G ),
                                     PrimitiveIdentification( G ) ] );
                    elif try = fail then
                      Add( cand2, G );
                    fi;
                  fi;
                od;
                if cand2 = [] then
                  return [ Concatenation( "almost simple group with the ",
                               "given socle and socle factor that fits" ),
                           result ];
                else
#T inhomogeneous: some groups are detected, others are not ...
#T (problem for the comment string ...)
                  result:= [];
                fi;
              fi;
            fi;
          fi;
        fi;
      else
        # There are some cases where the table of the socle is not available,
        # and where the almost simple group is determined by its order.
        if Identifier( tbl ) in [ "O12+(2).2", "O12-(2).2" ] then
          for G in cand do
            if IsAlmostSimpleGroup( G ) then
              der:= DerivedSeriesOfGroup( G );
              socle:= der[ Length( der ) ];
              soclefact:= G / socle;
              type:= IsomorphismTypeInfoFiniteSimpleGroup( socle );
              if ( Identifier( tbl ) = "O12+(2).2" and
                   type.series = "D" and type.parameter = [ 6, 2 ] ) or
                 ( Identifier( tbl ) = "O12-(2).2" and
                   type.series = "2D" and type.parameter = [ 6, 2 ] ) then
                Add( result, [ NrMovedPoints( G ),
                               PrimitiveIdentification( G ) ] );
              fi;
            fi;
          od;
          return [ Concatenation( "unique almost simple group with the ",
                                  "given socle and socle factor" ),
                   result ];
        fi;
      fi;
    fi;

    cand:= Filtered( cand, G -> IsAlmostSimpleCharacterTable( tbl )
                                = IsAlmostSimpleGroup( G ) );

    # Now deal with the case that the given character table belongs to
    # a group $G$ with a unique minimal normal subgroup $N$ of prime power
    # $p^d$, such that $G$ is a *split* extension of $N$, with complement $C$.
    # (This can be concluded from stored fusions from $C$ to $G$ and
    # from $G$ onto $C$, such that the image of the embedding intersects
    # the kernel of the projection trivially.)
    # Then $C$ is maximal in $G$, so $G$ acts primitively on the cosets
    # of $C$.
    # (Note that for any maximal subgroup $M$ of $G$ that properly contains
    # $C$, the intersection $M \cap N$ is not trivial, so $M$ and thus also
    # $G = M N$ normalizes $M \cap N$, a contradiction to the minimality of
    # $N$.)
    # So if there is a unique primitive group of degree $|N|$ and of order
    # $|G|$ then it must belong to the given table --we do not check this!
    comment1:= "";
    nsg:= ClassPositionsOfMinimalNormalSubgroups( tbl )[1];
    if IsPrimePowerInt( Sum( SizesConjugacyClasses( tbl ){ nsg } ) ) then
      # The minimal normal subgroup is elementary abelian.
      fuscand:= First( ComputedClassFusions( tbl ),
                       r -> ClassPositionsOfKernel( r.map ) = nsg );
      if fuscand <> fail then
        s:= CharacterTable( fuscand.name );
        if s <> fail then
          fuscand:= First( ComputedClassFusions( s ),
                           r -> r.name = Identifier( tbl ) );
          if fuscand = fail then
            if IsEmpty( PossibleClassFusions( s, tbl ) ) then
              # The table is a nonsplit extension, hence not primitive.
              return attr.dataDefault;
            fi;
          fi;
          pos:= Filtered( [ 1 .. Length( cand ) ],
                    i -> Size( tbl ) / Size( s ) = NrMovedPoints( cand[i] ) );
          if fuscand <> fail and Intersection( fuscand.map, nsg ) = [ 1 ]
                             and Length( pos ) = 1 then
            # The table belongs to a split extension,
            # so we have shown that it belongs to a primitive group.
            # Furthermore, there is a unique primitive group of the relevant
            # degree that may fit to the table.
            G:= cand[ pos[1] ];
            cand:= cand{ Difference( [ 1 .. Length( cand ) ], pos ) };
            Add( result, [ NrMovedPoints( G ),
                           PrimitiveIdentification( G ) ] );
            comment1:= "prim. group on solv. minimal normal subgroup";
          fi;
        fi;
else
Print( "#E factor fusion missing on ", tbl, "\n" );
      fi;
    fi;

    comment2:= "";
    if not IsEmpty( cand ) then
      if n <= 10^7 then
        for G in cand do
          # Do the hard test.
          Info( InfoCharacterTable, 2,
                "hard test for ", tbl, " (order ", n, ")" );
          if NrConjugacyClasses( G ) = NrConjugacyClasses( tbl ) and
             IsRecord( TransformingPermutationsCharacterTables(
                       CharacterTable( G ), tbl ) ) then
            Add( result, [ NrMovedPoints( G ), PrimitiveIdentification( G ) ] );
            comment2:= "hard test";
          fi;
        od;
      else
      Info( InfoCharacterTable, 2,
            "omit hard test for ", Identifier( tbl ), " (order ", n, ")" );
      fi;
    fi;
    if not IsEmpty( result ) then
      if comment1 <> "" and comment2 <> "" then
        comment1:= Concatenation( comment1, "/", comment2 );
      elif comment1 = "" then
        comment1:= comment2;
      fi;
      return [ comment1, result ];
    fi;

    return fail;
    end,

  string:= CTblLibGroupDataString,

  check:= function( id )
    local pos, entry, tbl, degrees, nsg, result, cand, nam, subtbl, fus, deg,
          i;

    pos:= Position( CTblLibData.GROUPINFO.prim.data[1], id );
    if pos = fail then
      return true;
    fi;
    entry:= CTblLibData.GROUPINFO.prim.data[3][ pos ];
    tbl:= CharacterTable( id );
    if tbl = fail then
      Print( "#I  no character table for `", id, "'\n" );
      return false;
    elif ForAny( entry, pair -> Size( PrimitiveGroup( pair[1], pair[2] ) )
                                <> Size( tbl ) ) then
      Print( "#I  different sizes for `", id, "'\n" );
      return false;
    fi;
    degrees:= Set( List( entry, pair -> pair[1] ) );
    nsg:= ClassPositionsOfNormalSubgroups( tbl );
    result:= true;
    if HasMaxes( tbl ) then
      # Delegate where appropriate.
      if HasConstructionInfoCharacterTable( tbl ) and
         IsList( ConstructionInfoCharacterTable( tbl ) ) and
         ConstructionInfoCharacterTable( tbl )[1] = "ConstructPermuted" and
         Length( ConstructionInfoCharacterTable( tbl )[2] ) = 1 then
        tbl:= CharacterTable( ConstructionInfoCharacterTable( tbl )[2][1] );
      fi;
      # If the tables of all maximal subgroups are known then check that
      # the primitive degrees are exactly the indices of the core-free
      # maximal subgroups (without multiplicity).
      cand:= [];
      for nam in Maxes( tbl ) do
        subtbl:= CharacterTable( nam );
        if subtbl = fail then
          Print( "#I  no character table for `", id, "'\n" );
          result:= false;
        else
          fus:= GetFusionMap( subtbl, tbl );
          if fus = fail then
            Print( "#I  no fusion `", nam, "' -> `", id, "'\n" );
            result:= false;
          elif ClassPositionsOfKernel( fus ) = [ 1 ]
               and Number( nsg, n -> IsSubset( Set( fus ), n ) ) = 1 then
            deg:= Size( tbl ) / Size( subtbl );
            if deg <= PRIMRANGE[ Length( PRIMRANGE ) ] then
              if deg in degrees then
                AddSet( cand, deg );
              else
                Print( "#E  maximal subgroup `", Identifier( subtbl ),
                       "' should yield degree ", deg, "\n" );
                result:= false;
              fi;
            fi;
          fi;
        fi;
      od;
      if degrees <> cand then
        Print( "#E  different prim. degrees for `", id, "'\n" );
        result:= false;
      fi;
    else
      # The indices of known core-free maximal subgroups yield primitive
      # degrees.
      for i in [ 1 .. 100 ] do
        subtbl:= CharacterTable( Concatenation( id, "M", String(i) ) );
        if subtbl <> fail then
          fus:= GetFusionMap( subtbl, tbl );
          if fus <> fail and ClassPositionsOfKernel( fus ) = [ 1 ]
                  and Number( nsg, n -> IsSubset( Set( fus ), n ) ) = 1 then
            deg:= Size( tbl ) / Size( subtbl );
            if deg <= PRIMRANGE[ Length( PRIMRANGE ) ]
               and not deg in degrees then
              Print( "#E  maximal subgroup `", Identifier( subtbl ),
                     "' should yield degree ", deg, "\n" );
              result:= false;
            fi;
          fi;
        fi;
      od;
    fi;
    return result;
  end,
  ) );


#############################################################################
##
#V  CTblLibData.IdEnumerator.attributes.small
##
Add( CTblLibData.attributesRelevantForGroupInfoForCharacterTable, "small" );
DatabaseAttributeAdd( CTblLibData.IdEnumerator, rec(
  identifier:= "small",
  description:= "mapping between the GAP libraries of char. tables and small groups",
  type:= "pairs",
  datafile:= Filename( DirectoriesPackageLibrary( "ctbllib", "data" ),
                       "grp_small.dat" ),
  dataDefault:= [],
  isSorted:= true,
  eval:= function( attr, l )
      return List( l, val -> [ "SmallGroup", val ] );
    end,
  reverseEval:= function( attr, info )
           local pos, entry;

           if info[1] = "SmallGroup" then
             if not IsBound( attr.data )  then
               Read( attr.datafile );
             fi;
             for entry in Concatenation( attr.data.automatic,
                                         attr.data.nonautomatic ) do
               if info[2] in entry[2] then
                 return entry[1];
               fi;
             od;
           fi;
           return fail;
         end,
  neededAttributes:= [ "trans", "tom" ],

  prepareAttributeComputation:= function( attr )
      CTblLibData.unload:= LIBTABLE.unload;
      LIBTABLE.unload:= false;

      LIBTABLE.IsEquiv:= function( G, tbl )
        return IsRecord( TransformingPermutationsCharacterTables(
                             CharacterTable( G ), tbl ) );
      end;
    end,

  cleanupAfterAttributeComputation:= function( attr )
      LIBTABLE.unload:= CTblLibData.unload;
      Unbind( CTblLibData.unload );

      Unbind( LIBTABLE.IsEquiv );
    end,

  create:= function( attr, id )
    local tbl, n, cand, result;

    tbl:= CharacterTable( id );
    n:= Size( tbl );
    if   n in [ 512, 1024, 1536 ] then
      # We have no `GroupId' value.
      return attr.dataDefault;
    elif n in [ 768, 1152, 1920 ] then
      # For these orders, the access to the library groups takes too long.
      if IsPerfect( tbl ) then
        cand:= List( [ 1 ..  NumberPerfectLibraryGroups( n ) ],
            i -> Image( IsomorphismPermGroup( PerfectGroup( n, i ) ) ) );
        result:= List( Filtered( cand,
                          G -> NrConjugacyClasses( G )
                                = NrConjugacyClasses( tbl ) and
                               LIBTABLE.IsEquiv( G, tbl ) ),
                       IdGroup );
      else
        # Perhaps the library of transitive groups contains the group.
        result:= [];
        if IsBound( CTblLibData.IdEnumerator.attributes.trans ) then
          result:= DatabaseAttributeValueDefault(
                       CTblLibData.IdEnumerator.attributes.trans, id );
        fi;
        if IsEmpty( result ) and
           IsBound( CTblLibData.IdEnumerator.attributes.tom ) then
          # Perhaps the library of tables of marks contains the group.
          result:= DatabaseAttributeValueDefault(
                       CTblLibData.IdEnumerator.attributes.tom, id );
        fi;
        if IsEmpty( result ) then
          Info( InfoCharacterTable, 2,
                "omitting order ", n, " table ", tbl );
          return attr.dataDefault;
        fi;
        return Set( List( result,
                          p -> IdGroup( CallFuncList( ValueGlobal( p[1] ),
                                                      p[2] ) ) ) );
      fi;
    elif n <= 2000 then
      result:= IdsOfAllSmallGroups( Size, n,
                   IsAbelian, IsAbelian( tbl ),
                   IsNilpotentGroup, IsNilpotent( tbl ),
                   IsSupersolvableGroup, IsSupersolvable( tbl ),
                   IsSolvableGroup, IsSolvable( tbl ),
                   IsSimple, IsSimple( tbl ),
                   IsPerfect, IsPerfect( tbl ),
                   NrConjugacyClasses, NrConjugacyClasses( tbl ),
                   G -> LIBTABLE.IsEquiv( G, tbl ), true );
      # This is necessary in a loop over several tables.
      UnloadSmallGroupsData();
      if not IsEmpty( result ) then
        return result;
      fi;
    fi;
    return attr.dataDefault;
    end,
  string:= CTblLibGroupDataString,
  check:= ReturnTrue,
  ) );


#############################################################################
##
#V  CTblLibData.IdEnumerator.attributes.tom
##
Add( CTblLibData.attributesRelevantForGroupInfoForCharacterTable, "tom" );
DatabaseAttributeAdd( CTblLibData.IdEnumerator, rec(
  identifier:= "tom",
  description:= "mapping between the GAP libraries of char. tables and tables of marks",
  type:= "pairs",
  datafile:= Filename( DirectoriesPackageLibrary( "ctbllib", "data" ),
                       "grp_tom.dat" ),
  dataDefault:= [ "not found", [] ],
  isSorted:= true,
  attributeValue:= function( attr, id )
      local pos;

      pos:= Position( TOM_TBL_INFO[2], LowercaseString( id ) );
#T sorted list?
      if pos <> fail then
        return [ [ "TomGroup", [ TOM_TBL_INFO[1][ pos ] ] ] ];
      fi;
      return DatabaseAttributeValueDefault( attr, id );
    end,
  eval:= function( attr, l )
      return List( l[2], val -> [ "TomGroup", val ] );
    end,
  reverseEval:= function( attr, info )
           local pos, entry;

           if info[1] = "TomGroup" then
             if Length( info[2] ) = 1 then
               pos:= Position( TOM_TBL_INFO[1], LowercaseString( info[2][1] ) );
               if pos <> fail then
                 return TOM_TBL_INFO[2][ pos ];
               fi;
             else
               if not IsBound( attr.data )  then
                 Read( attr.datafile );
               fi;
               for entry in Concatenation( attr.data.automatic,
                                           attr.data.nonautomatic ) do
                 if info[2] in entry[2][2] then
                   return entry[1];
                 fi;
               od;
             fi;
           fi;
           return fail;
         end,
  neededAttributes:= [],
  prepareAttributeComputation:= CTblLibData.prepare,
  cleanupAfterAttributeComputation:= CTblLibData.cleanup,
  create:= function( attr, id )
    local tbl, r, super, tom, mx, pos, i, G, orders;

    tbl:= CharacterTable( id );
    if HasFusionToTom( tbl ) then
      # We need not store this, the `extract' function deals with it.
      return attr.dataDefault;
    fi;
    # Check for a stored fusion into a table that knows it table of marks.
    for r in ComputedClassFusions( tbl ) do
      if Length( ClassPositionsOfKernel( r.map ) ) = 1 then
        super:= CharacterTable( r.name );
        if super <> fail and HasFusionToTom( super ) then
          # Identify the subgroup.
          tom:= TableOfMarks( super );
          if HasMaxes( super ) and id in Maxes( super ) then
            mx:= MaximalSubgroupsTom( tom );
            if Sum( SizesConjugacyClasses( super ){ Set( r.map ) } )
                 = Size( tbl ) then
              pos:= Filtered( [ 1 .. Length( mx[2] ) ], i -> mx[2][i] = 1 );
            else
              pos:= Filtered( [ 1 .. Length( mx[2] ) ],
                        i -> mx[2][i] = Size( super ) / Size( tbl ) );
            fi;
            if Length( pos ) = 1 then
              # Omit the check.
              return [ "unique max. subgroup of the right order",
                       [ [ Identifier( tom ), mx[1][ pos[1] ] ] ] ];
            else
              for i in pos do
                G:= RepresentativeTom( tom, i );
#T provide a utility that compares invariants?
                if NrConjugacyClasses( G ) = NrConjugacyClasses( tbl ) and
                   IsRecord( TransformingPermutationsCharacterTables(
                                 CharacterTable( G ), tbl ) ) then
                  return [ "hard test (max. subgroup)",
                           [ [ Identifier( tom ), i ] ] ];
                fi;
              od;
            fi;
          else
            # Loop over all classes of subgroups of the right order.
            orders:= OrdersTom( tom );
            pos:= Filtered( [ 1 .. Length( orders ) ],
                      i -> orders[i] = Size( tbl ) );
            for i in pos do
              G:= RepresentativeTom( tom, i );
              if NrConjugacyClasses( G ) = NrConjugacyClasses( tbl ) and
                 IsRecord( TransformingPermutationsCharacterTables(
                               CharacterTable( G ), tbl ) ) then
                return [ "hard test", [ [ Identifier( tom ), i ] ] ];
              fi;
            od;
          fi;
        fi;
      fi;
    od;
    return attr.dataDefault;
    end,
  string:= CTblLibGroupDataString,
  check:= ReturnTrue,
  ) );


#############################################################################
##
#V  CTblLibData.IdEnumerator.attributes.trans
##
Add( CTblLibData.attributesRelevantForGroupInfoForCharacterTable, "trans" );
DatabaseAttributeAdd( CTblLibData.IdEnumerator, rec(
  identifier:= "trans",
  description:= "mapping between the GAP libraries of char. tables and trans. groups",
  type:= "pairs",
  datafile:= Filename( DirectoriesPackageLibrary( "ctbllib", "data" ),
                       "grp_trans.dat" ),
  dataDefault:= [],
  isSorted:= true,
  eval:= function( attr, l )
           return List( l, val -> [ "TransitiveGroup", val ] );
         end,
  reverseEval:= function( attr, info )
           local entry;

           if info[1] = "TransitiveGroup" then
             if not IsBound( attr.data )  then
               Read( attr.datafile );
             fi;
             for entry in Concatenation( attr.data.automatic,
                                         attr.data.nonautomatic ) do
               if info[2] in entry[2] then
                 return entry[1];
               fi;
             od;
           fi;
           return fail;
         end,
  neededAttributes:= [],
  prepareAttributeComputation:= CTblLibData.prepare,
  cleanupAfterAttributeComputation:= CTblLibData.cleanup,
  create:= function( attr, id )
    local tbl, result, G;

    tbl:= CharacterTable( id );
    result:= [];
    # Just check the obvious invariants;
    # do not try `PermChars' for excluding some tables,
    # computing the irreducibles is faster in most cases.
    for G in AllTransitiveGroups(
                 NrMovedPoints, [ 2 .. TRANSDEGREES ],
                 Size, Size( tbl ),
                 AbelianInvariants, AbelianInvariants( tbl ),
                 NrConjugacyClasses, NrConjugacyClasses( tbl ) ) do
      if IsRecord( TransformingPermutationsCharacterTables(
                   CharacterTable( G ), tbl ) ) then
        Add( result, [ NrMovedPoints( G ), TransitiveIdentification( G ) ] );
      fi;
    od;
    if IsEmpty( result ) then
      return attr.dataDefault;
    fi;
    return result;
    end,
  string:= CTblLibGroupDataString,
  check:= ReturnTrue,
  ) );

#T -> add a database attribute HasGroupInfo... composed from the above ones ?


#############################################################################
##
# t:= BrowseTableFromDatabaseIdEnumerator( CTblLibData.IdEnumerator,
#   [ "self" ], [ "Size" ], [ "GAP Character Table Library Overview" ], [] );;

# better for header:
# t -> BrowseData.HeaderWithRowCounter( t, header, t.work.m ),

# 
# NCurses.BrowseGeneric( t );

# Example:
#
# datafile -> (read) data, perhaps commented -> (eval) real attr. value
# identifier -> (compute.create) data, perhaps commented
#
# data entry, perhaps commented -> (compute.string) string for the file, with comment
#
# (where does the default value enter the game:
# in compute.string, return empty if the data entry is not wanted)
#
# -> check must have access to the comments!


# # relics from old code:
# CTblLibIndices[1]:= rec( idenumerator:= CTblLibIdEnumerator,
#                          invariant:= Identifier,
#                          name:= "Identifier",
#                          sort:= \< );
# #T other sort function? (A5 before A10) -> needed for Browse?
# #T ``shortcut'' for computation from identifier list!
# CTblLibIndices[2]:= rec( idenumerator:= CTblLibIdEnumerator,
#                          invariant:= Size,
#                          name:= "Size",
#                          sort:= \< );
# CTblLibIndices[3]:= rec( idenumerator:= CTblLibIdEnumerator,
#                          invariant:= IsAbelian,
#                          name:= "IsAbelian",
#                          sort:= \< );
#
# RecomputeDatabaseIndex( CTblLibIndices[1] );
# RecomputeDatabaseIndex( CTblLibIndices[2] );
# RecomputeDatabaseIndex( CTblLibIndices[3] );

##
##  Examples:
##
##  The attribute <Ref Attr="GroupInfoForCharacterTable"/>, which provides
##  an interface from the &GAP; Character Table Library
##  to several group libraries that are available in &GAP;.
##  The interface to each such library is realized as a database attribute
##  of its own.
##  (The main reason why not <E>one</E> common database attribute was chosen
##  for this purpose is that the functions to compute the values are
##  specific to the group libraries.
##
##  The function <Ref Func="AllCharacterTableNames"/> supports database
##  attributes that are defined for the database id enumerator
##  <Ref Var="CTblLibData.IdEnumerator"/>.
##  This means that besides the properties <Ref Prop="IsSimple"/> and
##  <Ref Prop="IsSporadicSimple"/>, also other database attributes are
##  handled efficiently.
##  This means that if one intends to use certain &GAP; attributes
##  frequently as arguments of <Ref Func="AllCharacterTableNames"/> then one
##  can provide a cache for these values by creating a database attribute.
##  (Note that this might require a lot of memory.)
##  The values can be saved to a file but this is not necessary.
##  <!-- the database attribute exists first of all in memory -->

#T -> function that does this? DatabaseAttributeAdd( ..., Size ) ?
#T    DatabaseAttributeByFunction ?
#T -> example: derive HasGroupInfo... from the various database attributes!
#T    (used to be shown with Browse!)

##
##  Database attributes for the following &GAP; attributes are handled in a
##  special way in the sense that their values can be computed cheaper than
##  by first creating the character table in question and then computing the
##  value from it.
##  <Ref Attr="Size"/>, ...

#T -> more?

##  If the &GAP; package <Package>Browse</Package> is available then
##  one can use database attributes also for data overviews,
##  see <Ref Func="..."/>.

# compute browse table with BrowseTableFromDatabaseIdEnumerator,

# perhaps add the construction to the global list ... that is shown as the
# menu by ...


#############################################################################
##
#E

