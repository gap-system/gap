#############################################################################
##
#W  brmindeg.g           GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2007,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains a Browse application for showing the minimal degree
##  data in a table.
##


#############################################################################
##
#F  BrowseMinimalDegrees( [<groupnames>] )
##
##  <#GAPDoc Label="BrowseMinimalDegrees">
##  <ManSection>
##  <Func Name="BrowseMinimalDegrees" Arg='[groupnames]'/>
##  
##  <Returns>
##  the list of info records for the clicked representations.
##  </Returns>
##  <Description>
##  If the &GAP; package <Package>Browse</Package> (see <Cite Key="Browse"/>)
##  is loaded then this function is available.
##  It opens a browse table whose rows correspond to the groups for which the
##  <Package>ATLAS</Package> of Group Representations contains
##  some information about minimal degrees,
##  whose columns correspond to the characteristics that occur,
##  and whose entries are the known minimal degrees.
##  <P/>
##  <Example><![CDATA[
##  gap> if IsBound( BrowseMinimalDegrees ) then
##  >   down:= NCurses.keys.DOWN;;  DOWN:= NCurses.keys.NPAGE;;
##  >   right:= NCurses.keys.RIGHT;;  END:= NCurses.keys.END;;
##  >   enter:= NCurses.keys.ENTER;;  nop:= [ 14, 14, 14 ];;
##  >   # just scroll in the table
##  >   BrowseData.SetReplay( Concatenation( [ DOWN, DOWN, DOWN,
##  >          right, right, right ], "sedddrrrddd", nop, nop, "Q" ) );
##  >   BrowseMinimalDegrees();;
##  >   # restrict the table to the groups with minimal ordinary degree 6
##  >   BrowseData.SetReplay( Concatenation( "scf6",
##  >        [ down, down, right, enter, enter ] , nop, nop, "Q" ) );
##  >   BrowseMinimalDegrees();;
##  >   BrowseData.SetReplay( false );
##  > fi;
##  ]]></Example>
##  <P/>
##  If an argument <A>groupnames</A> is given then it must be a list of
##  group names of the <Package>ATLAS</Package> of Group Representations;
##  the browse table is then restricted to the rows corresponding to these
##  group names and to the columns that are relevant for these groups.
##  A perhaps interesting example is the subtable with the data concerning
##  sporadic simple groups and their covering groups,
##  which has been published in <Cite Key="Jan05"/>.
##  This table can be shown as follows.
##  <P/>
##  <Example><![CDATA[
##  gap> if IsBound( BrowseMinimalDegrees ) then
##  >   # just scroll in the table
##  >   BrowseData.SetReplay( Concatenation( [ DOWN, DOWN, DOWN, END ],
##  >          "rrrrrrrrrrrrrr", nop, nop, "Q" ) );
##  >   BrowseMinimalDegrees( BibliographySporadicSimple.groupNamesJan05 );;
##  > fi;
##  ]]></Example>
##  <P/>
##  The browse table does not contain rows for the groups
##  <M>6.M_{22}</M>, <M>12.M_{22}</M>, <M>6.Fi_{22}</M>.
##  Note that in spite of the title of <Cite Key="Jan05"/>, the entries in
##  Table 1 of this paper are in fact the minimal degrees of faithful
##  <E>irreducible</E> representations, and in the above three cases,
##  these degrees are larger than the minimal degrees of faithful
##  representations.
##  The underlying data of the browse table is about the minimal faithful
##  (but not necessarily irreducible) degrees.
##  <P/>
##  The return value of <Ref Func="BrowseMinimalDegrees"/> is the list of
##  <Ref Func="OneAtlasGeneratingSetInfo"/> values for those representations
##  that have been <Q>clicked</Q> in visual mode.
##  <P/>
##  The variant without arguments of this function is also available
##  in the menu shown by <Ref Func="BrowseGapData" BookName="Browse"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "BrowseMinimalDegrees", function( arg )
    local data, name, char, lastj, labelsrow, mat, src, i, entry, pos, j,
          perm, info, file, parse, keys, modes, newactions, showaction, mode,
          table, result;

    if Length( arg ) = 0 then
      data:= MinimalRepresentationInfoData.datalist;
    elif Length( arg ) = 1 and IsList( arg[1] ) then
      data:= [];
      for name in arg[1] do
        Append( data, Filtered( MinimalRepresentationInfoData.datalist,
                                x -> x[1] = name ) );
      od;
      if IsEmpty( data ) then
        return [];
      fi;
    else
      Error( "usage: BrowseMinimalDegrees( [<groupnames>] )" );
    fi;

    char:= Set( List( Filtered( data, x -> x[2][1] = "Characteristic" ),
                      x -> x[2][2] ) );
    lastj:= Length( char ) + 1;
    labelsrow:= [];
    mat:= [];
    src:= [];
    for i in [ 1 .. Length( data ) ] do
      entry:= data[i];
      pos:= Position( labelsrow, entry[1] );
      if pos = fail then
        pos:= Length( labelsrow ) + 1;
        labelsrow[ pos ]:= entry[1];
        mat[ pos ]:= [];
        src[ pos ]:= [];
      fi;
      if   entry[2][1] = "Characteristic" and IsInt( entry[3] ) then
        j:= Position( char, entry[2][2] );
        if OneAtlasGeneratingSetInfo( labelsrow[ pos ],
               Characteristic, entry[2][2], Dimension, entry[3] ) = fail then
          mat[ pos ][j]:= String( entry[3] );
        else
          mat[ pos ][j]:= rec( rows:= [ [ NCurses.attrs.BOLD, true,
                  NCurses.ColorAttr( "blue", -1 ), true,
                  String( entry[3] ) ] ], align:= "r" );
        fi;
        if not IsBound( src[ pos ][j] ) then
          src[ pos ][j]:= [];
        fi;
        AddSet( src[ pos ][j], entry[4] );
      elif entry[2] = "NrMovedPoints" then
        if OneAtlasGeneratingSetInfo( labelsrow[ pos ],
               NrMovedPoints, entry[3] ) = fail then
          mat[ pos ][ lastj ]:= String( entry[3] );
        else
          mat[ pos ][ lastj ]:= rec( rows:= [ [ NCurses.attrs.BOLD, true,
                  NCurses.ColorAttr( "blue", -1 ), true,
                  String( entry[3] ) ] ], align:= "r" );
        fi;
        if not IsBound( src[ pos ][ lastj ] ) then
          src[ pos ][ lastj ]:= [];
        fi;
        AddSet( src[ pos ][ lastj ], entry[4] );
      fi;
    od;

    if Length( arg ) = 0 then
      # Sort the rows.
      perm:= Sortex( List( labelsrow,
                       BrowseData.SplitStringIntoNumbersAndNonnumbers ) );
#T really better than BrowseData.CompareAsNumbersAndNonnumbers?

      labelsrow:= Permuted( labelsrow, perm );
      mat:= Permuted( mat, perm );
      src:= Permuted( src, perm );
    fi;

    # Fill missing entries with a question mark.
    for i in [ 1 .. Length( mat ) ] do
      info:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                    x -> x[1] = labelsrow[i] );
      for j in [ 1 .. Length( char ) ] do
        if not IsBound( mat[i][j] ) then
          if char[j] = 0 or ( IsList( info ) and IsBound( info[3].size )
                              and info[3].size mod char[j] = 0 ) then
            mat[i][j]:= "?";
          fi;
        fi;
      od;
      # perm. degree
      if not IsBound( mat[i][ lastj ] ) then
        mat[i][ lastj ]:= "?";
      fi;
    od;

    # Load the bibliographic data.
    file:= Filename( DirectoriesPackageLibrary( "atlasrep", "bibl" ),
                     "mindegbib.xml" );
    parse:= ParseBibXMLextFiles( file );
    keys:= List( parse.entries,
                 e -> RecBibXMLEntry( e, "Text", parse.strings ).Label );

    # Construct the extended modes if necessary.
    if not IsBound( BrowseData.defaults.work.customizedModes.brmindeg ) then
      # Create a shallow copy of each default mode for `Browse', and add
      # new actions to those modes where an entry is selected:
      # - vb: Show BibTeX format of the selected entry in a pager
      # - vh: Show HTML format of the selected entry in a pager
      # - vt: Show text format of the selected entry in a pager
      modes:= List( BrowseData.defaults.work.availableModes,
                    BrowseData.ShallowCopyMode );
      BrowseData.defaults.work.customizedModes.brmindeg:= modes;
      newactions:= [ [ "vb", "BibTeX" ],
                     [ "vh", "HTML" ],
                     [ "vt", "Text" ] ];
      showaction:= pair -> [ [ pair[1] ],
        rec( helplines:= [ Concatenation( "show ", pair[2],
                             " format of bibl. info" ),
                           "for the selected entry in a pager" ],
             action:= function( t )
               local row, col, disp, i, pos;

               if t.dynamic.selectedEntry <> [ 0, 0 ] then
                 row:= t.dynamic.indexRow[ t.dynamic.selectedEntry[1] ] / 2;
                 col:= t.dynamic.indexCol[ t.dynamic.selectedEntry[2] ] / 2;
                 if IsBound( src[ row ][ col ] ) then
                   disp:= [];
                   for i in src[ row ][ col ] do
                     pos:= Position( keys, i );
                     if pos <> fail then
                       Add( disp, parse.entries[ pos ] );
                     fi;
                   od;
                   if not IsEmpty( disp ) then
                     NCurses.hide_panel( t.dynamic.statuspanel );
                     NCurses.Pager( JoinStringsWithSeparator( List( disp,
                       e -> BrowseData.SimplifiedString(
                            StringBibXMLEntry( e, pair[2],
                              parse.strings ) ) ), "\n" ) );
                     NCurses.show_panel( t.dynamic.statuspanel );
                   fi;
                 fi;
               fi;
               t.dynamic.changed:= true;
             end ) ];
      newactions:= List( newactions, showaction );
      for mode in modes do
        if mode.name in [ "select_entry", "select_row_and_entry",
                          "select_column_and_entry" ] then
          BrowseData.SetActions( mode, newactions );
        fi;
      od;
    else
      modes:= BrowseData.defaults.work.customizedModes.brmindeg;
    fi;

    # Construct the browse table.
    table:= rec(
      work:= rec(
        availableModes:= modes,
        align:= "ct",
        header:= t -> BrowseData.HeaderWithRowCounter( t,
                          "Minimal Degrees of Representations",
                          Length( mat ) ),
        footer:= rec(
          # Show the sources of the data.
          select_entry:= function( t )
            local entry, e, pos;

            entry:= "";
            if   t.dynamic.selectedEntry <> [ 0, 0 ] then
              e:= src[ t.dynamic.indexRow[ t.dynamic.selectedEntry[1] ] / 2 ];
              pos:= t.dynamic.indexCol[ t.dynamic.selectedEntry[2] ] / 2;
              if IsBound( e[ pos ] ) and not IsEmpty( e[ pos ] ) then
                entry:= Concatenation( "source: ",
                            JoinStringsWithSeparator( e[ pos ], ", " ) );
              fi;
            fi;
            return [ entry ];
          end ),
        footerLength:= rec(
          select_entry:= 1 ),
        CategoryValues:= function( t, i, j )
          local val;

          val:= t.work.main[ i/2 ][ j/2 ];
          if   NCurses.IsAttributeLine( val ) then
            val:= NCurses.SimpleString( val );
          else
            val:= Concatenation( List( val.rows, NCurses.SimpleString ) );
          fi;
          if   2 * Length( char ) < j then
            return [ Concatenation( "min. perm. degree = ", val ) ];
          else
            return [ Concatenation( "char. ", String( char[ j/2 ] ), ": ",
                         val ) ];
          fi;
        end,

        main:= mat,
        labelsRow:= List( labelsrow,
                          x -> [ rec( rows:= [ x ], align:= "l" ) ] ),
        labelsCol:= [ Concatenation( List( char,
                          x -> rec( rows:= [ String( x ) ], align:= "r" ) ),
                        [ "perm. degree" ] ) ],
        sepLabelsRow:= "|",
        sepLabelsCol:= "|",
        sepRow:= "-",
        sepCol:= Concatenation( [ "| " ],
                     List( [ 1 .. Length( char ) ], x -> " | " ), [ " |" ] ),

        SpecialGrid:= BrowseData.SpecialGridLineDraw,
        Click:= rec(
          select_entry:= rec(
            helplines:= [ "add the representation to the result list" ],
            action:= function( t )
              local i, j, entry;

              if t.dynamic.selectedEntry <> [ 0, 0 ] then
                i:= t.dynamic.indexRow[ t.dynamic.selectedEntry[1] ] / 2;
                j:= t.dynamic.indexCol[ t.dynamic.selectedEntry[2] ] / 2;
                if IsBound( mat[i][j] ) then
                  entry:= mat[i][j];
                  if IsRecord( entry ) then
                    entry:= First( entry.rows[1], IsString );
                  fi;
                  if j <= Length( char ) then
                    info:= OneAtlasGeneratingSetInfo( labelsrow[i],
                              Characteristic, char[j],
                              Dimension, Int( entry ) );
                  else
                    info:= OneAtlasGeneratingSetInfo( labelsrow[i],
                              NrMovedPoints, Int( entry ) );
                  fi;
                  if not info in t.dynamic.Return then
                    Add( t.dynamic.Return, info );
                  fi;
                fi;
              fi;
            end ),
        ),
      ),
      dynamic:= rec(
        sortFunctionsForColumns:= List( [ 0 .. Length( char ) ],
            x -> BrowseData.CompareLenLex ),
        Return:= [],
        activeModes:= [ First( modes, x -> x.name = "browse" ) ],
      ),
    );

    # Show the browse table.
    result:= NCurses.BrowseGeneric( table );

    # Construct the return value.
    return result;
    end );


#############################################################################
##
##  Add the Browse application to the list shown by `BrowseGapData'.
##
BrowseGapDataAdd( "Minimal Degrees of Representations",
    BrowseMinimalDegrees, true, "\
the list of known minimal degrees for the groups of the \
Atlas of Group Representations, \
shown in a browse table with one column for each characteristic \
plus a column for the minimal permutation degree; \
available representations are shown in boldface blue, \
clicking on the table cell of such a representation adds the \
info record for it to the result list; \
the inputs vb, vh, vt open a pager showing the bibliographic sources \
of the selected entry if available; \
try ?BrowseMinimalDegrees for details" );


#############################################################################
##
#E

