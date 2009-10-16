#############################################################################
##
#W  tmdbattr.g                  GAP table library               Thomas Breuer
##
#H  @(#)$Id: tmdbattr.g,v 1.1 2008/01/08 10:49:28 gap Exp $
##
#Y  Copyright (C)  2007,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains
##  - the global record `TomLibData',
##    whose components are used to define the database id enumerator
##    `TomLibData.IdEnumerator' and its database attributes
##    (see the GAP package `Browse' for technical details) and
##  - the Browse application `BrowseTomLibInfo',
##    showing an overview of the GAP library of tables of marks.
##
Revision.tmdbattr_g :=
    "@(#)$Id: tmdbattr.g,v 1.1 2008/01/08 10:49:28 gap Exp $";


#############################################################################
##
#V  TomLibData
##
##  We introduce a new global variable for ``database aspects''.
##
BindGlobal( "TomLibData", rec() );


#############################################################################
##
##  Provide utilities for the computation of database attribute values.
##  They allow one to access table data without actually creating the tables.
##
TomLibData.MyIdFunc:= function( arg ); end;

TomLibData.TABLE_ACCESS_FUNCTIONS:= [
  rec(),
  rec( # These global variables are used in the data files.
       LIBTOMKNOWN := rec( LOADSTATUS := rec(), UNLOAD := false,
                           MAX := infinity ),
       SetActualLibFileName := TomLibData.MyIdFunc,
       AFLT := TomLibData.MyIdFunc,
       ACLT := TomLibData.MyIdFunc,
       LIBTOM := TomLibData.MyIdFunc,
     ) ];

TomLibData.SaveTableAccessFunctions := function()
  local name;

  if TomLibData.TABLE_ACCESS_FUNCTIONS[1] <> rec() then
    Info( InfoTom, 2, "access functions were already saved" );
    return;
  fi;
  for name in RecNames( TomLibData.TABLE_ACCESS_FUNCTIONS[2] ) do
    TomLibData.TABLE_ACCESS_FUNCTIONS[1].( name ):= [ ValueGlobal( name ) ];
    if IsReadOnlyGlobal( name ) then
      Add( TomLibData.TABLE_ACCESS_FUNCTIONS[1].( name ), "readonly" );
      MakeReadWriteGlobal( name );
    fi;
    UnbindGlobal( name );
    ASS_GVAR( name, TomLibData.TABLE_ACCESS_FUNCTIONS[2].( name ) );
  od;
end;

TomLibData.RestoreTableAccessFunctions := function()
  local name;

  if TomLibData.TABLE_ACCESS_FUNCTIONS[1] = rec() then
    Info( InfoTom, 2, "access functions were not saved" );
    return;
  fi;
  for name in RecNames( TomLibData.TABLE_ACCESS_FUNCTIONS[2] ) do
    UnbindGlobal( name );
    ASS_GVAR( name, TomLibData.TABLE_ACCESS_FUNCTIONS[1].( name )[1] );
    if Length( TomLibData.TABLE_ACCESS_FUNCTIONS[1].( name ) ) = 2 then
      MakeReadOnlyGlobal( name );
    fi;
    Unbind( TomLibData.TABLE_ACCESS_FUNCTIONS[1].( name ) );
  od;
end;


#############################################################################
##
#F  TomLibData.ComputeTableInfoByScanningLibraryFiles( <pairs> )
##
##  The argument <A>pairs</A> must be a list of pairs
##  <C>[ <A>nam</A>, <A>fun</A> ]</C>
##  where <A>nam</A> is the name of a function to be reassigned during the
##  reread process (such as <C>"LIBTOM"</C>),
##  and <A>fun</A> is the intended value.
##
TomLibData.ComputeTableInfoByScanningLibraryFiles :=
    function( pairs )
    local pair, name;

    # Disable the table library access.
    TomLibData.SaveTableAccessFunctions();

    # Define appropriate access functions.
    for pair in pairs do
      ASS_GVAR( pair[1], pair[2] );
    od;

    # Clear the cache.
    TomLibData.TableInfo:= rec();

    # Loop over the library files.
    for name in LIBTOMLIST.files do
      ReadPackage( "tomlib", Concatenation( "data/", name, ".tom" ) );
    od;

    # Restore the ordinary table library access.
    TomLibData.RestoreTableAccessFunctions();
end;


#############################################################################
##
#F  TomLibData.PrepareAttributeComputation()
##
TomLibData.PrepareAttributeComputation:= function()
    if not IsBound( TomLibData.TableInfo ) then
      TomLibData.ComputeTableInfoByScanningLibraryFiles( [
        [ "LIBTOM", function( arg )
              TomLibData.TableInfo.( arg[1] ):= rec(
                SubsTom:= arg[2],
                MarksTom:= arg[3],
                OrdersTom:= arg[5] );
            end ] ] );
    fi;
end;


#############################################################################
##
##  Create the database id enumerator to which the database attributes refer.
##
TomLibData.IdEnumerator:= DatabaseIdEnumerator( rec(
    identifiers:= Set( AllLibTomNames() ),
    entry:= function( idenum, id ) return TableOfMarks( id ); end,
    isSorted:= true,
    viewLabel:= "G",
    viewSort:= function( nam1, nam2 )
      return BrowseData.SplitStringIntoNumbersAndNonnumbers( nam1 )
             <= BrowseData.SplitStringIntoNumbersAndNonnumbers( nam2 );
    end,
    align:= "tl",
  ) );;


#############################################################################
##
#V  TomLibData.IdEnumerator.attributes.Size
##
DatabaseAttributeAdd( TomLibData.IdEnumerator, rec(
  identifier:= "Size",
  description:= "group orders of GAP library tables of marks",
  type:= "values",
  viewLabel:= "|G|",
  align:= "tr",
  create:= function( attr, id )
    local r, i;

    TomLibData.PrepareAttributeComputation();
    if IsBound( TomLibData.TableInfo.( id ) ) then
      r:= TomLibData.TableInfo.( id );
      if IsList( r.OrdersTom ) then
        return r.OrdersTom[ Length( r.OrdersTom ) ];
      elif IsList( r.SubsTom ) and IsList( r.MarksTom ) then
        i:= Length( r.SubsTom );
        return r.MarksTom[1][1] /
               r.MarksTom[i][ Position( r.SubsTom[i], 1 ) ];
      fi;
    fi;
    return fail;
    end,
  viewSort:= BrowseData.CompareAsNumbersAndNonnumbers,
  sortParameters:= [ "add counter on categorizing", "yes" ],
  ) );


#############################################################################
##
#V  TomLibData.IdEnumerator.attributes.NrClasses
##
DatabaseAttributeAdd( TomLibData.IdEnumerator, rec(
  identifier:= "NrClasses",
  description:= "numbers of classes of GAP library tables of marks",
  type:= "values",
  viewLabel:= "# classes",
  align:= "tr",
  create:= function( attr, id )
    local r;

    TomLibData.PrepareAttributeComputation();
    if IsBound( TomLibData.TableInfo.( id ) ) then
      r:= TomLibData.TableInfo.( id );
      if IsList( r.SubsTom ) then
        return Length( r.SubsTom );
      fi;
    fi;
    return fail;
    end,
  viewSort:= BrowseData.CompareAsNumbersAndNonnumbers,
  sortParameters:= [ "add counter on categorizing", "yes" ],
  ) );


#############################################################################
##
#V  TomLibData.IdEnumerator.attributes.Filename
##
DatabaseAttributeAdd( TomLibData.IdEnumerator, rec(
  identifier:= "Filename",
  description:= "filenames of GAP library tables of marks",
  type:= "values",
  align:= "tl",
  create:= function( attr, id )
    local pos;

    pos:= Position( LIBTOMLIST.names, LowercaseString( id ) );
    if pos = fail then
      return fail;
    fi;
    return Concatenation( LIBTOMLIST.files[ LIBTOMLIST.positions[ pos ][1] ],
               ".tom" );
    end,
  sortParameters:= [ "add counter on categorizing", "yes" ],
  ) );


#############################################################################
##
#V  TomLibData.IdEnumerator.attributes.FusionsFrom
##
DatabaseAttributeAdd( TomLibData.IdEnumerator, rec(
  identifier:= "FusionsFrom",
  description:= "fusions from other tables of marks to the given one",
  type:= "values",
  align:= "tl",
  categoryValue:= function( val )
    if IsEmpty( val ) then
      return "(no fusions to these tables)";
    fi;
    return List( val, x -> Concatenation( "fusions from ", x ) );
  end,
  create:= function( attr, id )
    # Make sure that no tables of marks are constructed here!
    return DuplicateFreeList( List( NotifiedFusionsToLibTom( id ),
                                    x -> x[1] ) );
    end,
  viewValue:= x -> rec( rows:= x, align:= "tl" ),
  viewLabel:= "fusions -> G",
  sortParameters:= [ "add counter on categorizing", "yes",
                     "split rows on categorizing", "yes" ],
  ) );


#############################################################################
##
#V  TomLibData.IdEnumerator.attributes.FusionsTo
##
DatabaseAttributeAdd( TomLibData.IdEnumerator, rec(
  identifier:= "FusionsTo",
  description:= "fusions from the given table of marks to other ones",
  type:= "values",
  align:= "tl",
  categoryValue:= function( val )
    if IsEmpty( val ) then
      return "(no fusions from these tables)";
    fi;
    return List( val, x -> Concatenation( "fusions to ", x ) );
  end,
  create:= function( attr, id )
    # Make sure that no tables of marks are constructed here!
    return DuplicateFreeList( List( NotifiedFusionsOfLibTom( id ),
                                    x -> x[1] ) );
    end,
  viewValue:= x -> rec( rows:= x, align:= "tl" ),
  viewLabel:= "fusions G ->",
  sortParameters:= [ "add counter on categorizing", "yes",
                     "split rows on categorizing", "yes" ],
  ) );


#############################################################################
##
#F  BrowseTomLibInfo()
##
BindGlobal( "BrowseTomLibInfo", function()
    NCurses.BrowseGeneric( 
      BrowseTableFromDatabaseIdEnumerator( TomLibData.IdEnumerator,
          [ "self" ],
          [ "Size", "NrClasses", "FusionsFrom", "FusionsTo", "Filename" ],
          t -> BrowseData.HeaderWithRowCounter( t,
                 "GAP Tables of Marks Library Overview", t.work.m ) ) );
    end );


#############################################################################
##
##  Add the Browse application to the list shown by `BrowseGapData'.
##
BrowseGapDataAdd( "Overview of the GAP Library of Tables of Marks",
    BrowseTomLibInfo, false,
    "an overview of the GAP library of tables of marks" );


#############################################################################
##
#E

