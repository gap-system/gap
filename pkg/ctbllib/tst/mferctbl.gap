#############################################################################
##
#W  mferctbl.gap    character tables of mult.-free endom. rings Thomas Breuer
#W                                                            Juergen Mueller
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the following {\GAP} objects.
##
##  `MULTFREEINFO'
##      is the global variable that encodes the character tables of the
##      endomorphism rings of the faithful multiplicity-free permutation
##      modules of the sporadic simple groups and their cyclic and
##      bicyclic extensions.
##
##  `MultFreeEndoRingCharacterTables'
##      is a function that can be used for computing more detailed data
##      about the endomorphism rings from the compact information
##      stored in `MULTFREEINFO'.
##

#############################################################################
##
##  Print the banner if wanted.
##
if not ( GAPInfo.CommandLineOptions.q or GAPInfo.CommandLineOptions.b ) then
  Print(
"---------------------------------------------------------------------------\n",
"Loading the database of character tables of endomorphism rings of\n",
"multiplicity-free permutation modules of the sporadic simple groups and\n",
"their cyclic and bicyclic extensions, compiled by T. Breuer and J. Mueller.\n",
"---------------------------------------------------------------------------\n"
  );
fi;

#############################################################################
##
#V  MULTFREEINFO
##
##  `MULTFREEINFO' is an immutable record.
##  Its components are the `Identifier' values of the {\GAP} character
##  tables of the sporadic simple groups and their automorphism groups.
##  The value of the component corresponding to the group $G$, say,
##  is a list containing in the first position a string denoting the name of
##  $G$ in {\LaTeX} format, and in each of the remaining positions a triple
##  `[ <const>, <subgroup>, <ctbl> ]'
##  where <const> is a list of positive integers, <subgroup> is a string
##  that denotes the name of a subgroup $H$ of $G$, in {\LaTeX} format,
##  and <ctbl> is either the matrix of irreducible characters of the
##  endomorphism ring of the permutation module $(1_H)^G$ or `fail'
##  (indicating that the character table is not yet known).
##  The sum of irreducible characters of $G$ at the positions in <const>
##  is a multiplicity-free permutation character of $G$ that is induced from
##  the trivial character of $H$.
##
##  The ordering of the entries corresponds to the ordering in~\cite{BL96},
##  for the scope of the latter paper.
##
BindGlobal( "MULTFREEINFO", rec() );

#############################################################################
##
#F  CollapsedAdjacencyMatricesFromCharacterTable( <mat> )
##
##  Let $X$ be the character table of an endomorphism algebra.
##  The collapsed adjacency matrix of the orbital graph that corresponds to
##  the $j$-th column of $X$ is given by $X^{-1} \cdot D_j \cdot X$, where
##  $D_j$ is the diagonal matrix whose diagonal is the $j$-th column of $X$.
##
BindGlobal( "CollapsedAdjacencyMatricesFromCharacterTable", function( mat )
    local tr,itr;

    if mat=fail then ## only for 2.B
        return fail;
    fi;
    tr:=TransposedMat(mat);
    itr:=Inverse(tr);
    return List([1..Length(mat)],
                j->tr*List([1..Length(mat)],i->mat[i][j]*itr[i]));
end );

#############################################################################
##
#F  MultFreeEndoRingCharacterTables( <name> )
##
##  For a string <name> that is the name of a sporadic simple group,
##  or a cyclic or bicyclic extension of a sporadic simple group,
##  `MultFreeEndoRingCharacterTables' returns a list of records that describe
##  the character tables of the endomorphism rings of the faithful
##  multiplicity-free permutation modules of this group,
##  in a format that is similar to the classification shown in~\cite{BL96}.
##
##  If <name> is the string `\"all\"' then `MultFreeEndoRingCharacterTables'
##  returns the list of records for all sporadic simple groups and their
##  cyclic or bicyclic extensions.
##
##  Each entry in the result list has the following components.
##  \beginitems
##  group &
##     {\LaTeX} format of <name>,
##
##  name &
##     <name>,
##
##  character &
##     the permutation character,
##
##  rank &
##     the rank of the character,
##
##  subgroup &
##     a string that is a name (in {\LaTeX} format) of the subgroup
##     from whose trivial character the permutation character is induced,
##
##  ctbl &
##     the matrix of irreducible characters of the endomorphism ring,
##     where the rows are labelled by the irreducible constituents of the
##     permutation character and the columns are labelled by the orbits of
##     the subgroup on its right cosets, which are ordered according to
##     their lengths.
##
##  mats &
##     the collapsed adjacency matrices, and
##
##  ATLAS &
##     a string that describes (in {\LaTeX} format) the constituents of the
##     permutation character, relative to the perfect group involved;
##     the format is described in the section~"ref:PermCharInfoRelative"
##     in the {\GAP} Reference Manual.
##  \enditems
##
##  In the one case where the character table is not (yet) known,
##  the components `ctbl' and `mats' have the value `fail'.
##
DeclareGlobalFunction( "MultFreeEndoRingCharacterTables" );

InstallGlobalFunction( MultFreeEndoRingCharacterTables, function( name )
    local alternat,  # list of alternative names
          result,    # the result list
          tbl,       # character table with `Identifier' value `name'
          group,     # value of the `group' component of each result entry
          len,       # length of the list stored for `name'
          chars,     # list of the permutation characters for `name'
          dername,   # name of derived subgroup
          tblsimp,   # character table of the derived subgroup of `tbl'
          info,      # list of `ATLAS' values
          i,         # loop over the permutation characters
          entry,     # one entry in the record for `name'
          pos;       # position in `alternative'

    alternat:= [ [ "Fi24'" ], [ "F3+" ] ];

    result:= [];
    if IsBound( MULTFREEINFO.( name ) ) then
      if 9 < Length( name ) and name{ [ 1 .. 9 ] } = "Isoclinic" then
        tbl:= CharacterTableIsoclinic(
                  CharacterTable( name{ [ 11 .. Length( name )-1 ] } ) );
      else
        tbl:= CharacterTable( name );
      fi;
      group:= MULTFREEINFO.( name )[1];
      len:= Length( MULTFREEINFO.( name ) );
      chars:= List( MULTFREEINFO.( name ){ [ 2 .. len ] },
                    x -> Sum( Irr( tbl ){ x[1] } ) );
      if Number( name, c -> c = '.' ) = 2 then
        if 9 < Length( name ) and name{ [ 1 .. 9 ] } = "Isoclinic" then
          dername:= name{ [ 11 .. Length( name )-1 ] };
        else
          dername:= name;
        fi;
        i:= Position( dername, '.' );
        dername:= dername{ [ 1 .. Position( dername, '.', i )-1 ] };
        tblsimp:= CharacterTable( dername );
        if 9 < Length( name ) and name{ [ 1 .. 9 ] } = "Isoclinic" then
          StoreFusion( tblsimp, GetFusionMap( tblsimp,
              CharacterTable( name{ [ 11 .. Length( name )-1 ] } ) ), tbl );
        fi;
        info:= PermCharInfoRelative( tblsimp, tbl, chars ).ATLAS;
      elif '.' in name then
        dername:= name{ [ 1 .. Position( name, '.' )-1 ] };
        if Int( dername ) = fail then
          tblsimp:= CharacterTable( dername );
          info:= PermCharInfoRelative( tblsimp, tbl, chars ).ATLAS;
        else
          info:= PermCharInfo( tbl, chars ).ATLAS;
        fi;
      else
        info:= PermCharInfo( tbl, chars ).ATLAS;
      fi;
      for i in [ 2 .. len ] do
        entry:= MULTFREEINFO.( name )[i];
        Add( result, rec( group     := group,
                          name      := name,
                          character := chars[ i-1 ],
                          charnmbs  := entry[1],
                          rank      := Length( entry[1] ),
                          subgroup  := entry[2],
                          ATLAS     := info[ i-1 ],
                          ctbl      := entry[3],
                          mats      :=
                CollapsedAdjacencyMatricesFromCharacterTable( entry[3] ) ) );
      od;
    elif name = "all" then
      for name in RecNames( MULTFREEINFO ) do
        Append( result, MultFreeEndoRingCharacterTables( name ) );
      od;
    else
      pos:= Position( alternat[1], name );
      if pos = fail then
        Error( "<name> must be the name of a ",
               "(cyclic or bicyclic extension of a)\n",
               "sporadic simple group, or the string \"all\"" );
      else
        return MultFreeEndoRingCharacterTables( alternat[2][ pos ] );
      fi;
    fi;
    return result;
end );

#############################################################################
##
#F  LinearCombinationString( <F>, <vectors>, <strings>, <multstring>, <val> )
##
BindGlobal( "LinearCombinationString",
    function( F, vectors, strings, multstring, val )
    local V, B, coeff, str, i;

    V:= VectorSpace( F, vectors );
    B:= Basis( V, vectors );
    coeff:= Coefficients( B, val );
    if coeff = fail then
      return fail;
    elif IsZero( coeff ) then
      return String( val );
    fi;

    str:= "";
    for i in [ 1 .. Length( coeff ) ] do
      if coeff[i] > 0 then
        if str <> "" then
          Append( str, "+" );
        fi;
        if coeff[i] = 1 and strings[i] = "" then
          Append( str, "1" );
        elif coeff[i] <> 1 then
          Append( str, String( coeff[i] ) );
          if strings[i] <> "" then
            Append( str, multstring );
          fi;
        fi;
        Append( str, strings[i] );
      elif coeff[i] < 0 then
        if coeff[i] = -1 then
          Append( str, "-" );
        else
          Append( str, String( coeff[i] ) );
          if strings[i] <> "" then
            Append( str, multstring );
          fi;
        fi;
        Append( str, strings[i] );
      fi;
    od;
    return str;
end );

#############################################################################
##
#F  Cubic( <irrat> )
##
##  The database contains nonquadratic irrationalities,
##  which are either cubic or quartic.
##  The function `Cubic' deals with these few cases.
##
Cubic:=function( irrat )
    local bas, str, dsp, atlas, display;

    if Conductor( irrat ) = 9 and irrat = ComplexConjugate( irrat ) then
        bas:= [ 1, EY(9), GaloisCyc( EY(9), 2 ) ];
        str:= [ "1", "y9", "y9*2" ];
        dsp:= [ "1", "EY(9)", "GaloisCyc(EY(9),2)" ];
    elif Conductor( irrat ) = 19 and irrat = ComplexConjugate( irrat ) then
        bas:= [ EC(19), GaloisCyc( EC(19), 2 ), GaloisCyc( EC(19), 4 ) ];
        str:= [ "c19", "c19*2", "c19*4" ];
        dsp:= [ "EC(19)", "GaloisCyc(EC(19),2)", "GaloisCyc(EC(19),4)" ];
    elif Conductor( irrat ) = 33 then
        bas:= [1, EV(33), GaloisCyc(EV(33),5), GaloisCyc(EV(33),7)];
        str:= [ "1", "v33", "v33*5", "v33*7" ];
        dsp:= [ "1", "EV(33)", "GaloisCyc(EV(33),5)", "GaloisCyc(EV(33),7)"];
    else
        Error( "this should not occur" );
    fi;

    atlas   := LinearCombinationString( Rationals, bas, str, "",  irrat );
    display := LinearCombinationString( Rationals, bas, dsp, "*", irrat );

    return rec( value:= irrat, ATLAS := atlas, display := display );
end;

#############################################################################
##
#F  CharacterLabels( <tbl> )
#F  CharacterLabels( <tbl2>, <tbl>] )
##
BindGlobal( "CharacterLabels", function( arg )
    local tbl, tbl2, tblfustbl2, irr, alp, degreeset, irreds, chi,
          nccl2, irr2, irreds2, irrnam2, rest, i, j, chi2, k, pos, result;

    if Length( arg ) = 1 and IsCharacterTable( arg[1] ) then
      tbl:= arg[1];
      tbl2:= false;
    elif Length( arg ) = 2 and ForAll( arg, IsCharacterTable ) then
      tbl:= arg[2];
      tbl2:= arg[1];
      tblfustbl2:= GetFusionMap( tbl, tbl2 );
      if tblfustbl2 = fail or Size( tbl2 ) <> 2 * Size( tbl ) then
        Error( "<tbl> must be of index 2 in <tbl2>, with stored fusion" );
      fi;
    else
      Error( "usage: CharacterLabels( [<tbl2>, ]<tbl> )" );
    fi;

    irr:= Irr( tbl );
    alp:= [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
            "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
            "w", "x", "y", "z" ];
    degreeset:= Set( List( irr, DegreeOfCharacter ) );

    # `irreds[i]' contains all irreducibles of `tbl' of the `i'-th degree.
    irreds:= List( degreeset, x -> [] );
    for chi in irr do
      Add( irreds[ Position( degreeset, chi[1] ) ], chi );
    od;

    # Extend the alphabet if necessary.
    while Length( alp ) < Maximum( List( irreds, Length ) ) do
      alp:= Concatenation( alp,
                List( alp, x -> Concatenation( "(", x, "')" ) ) );
    od;

    if tbl2 <> false then

      # Construct relative names for the irreducibles of `tbl2'.
      nccl2:= NrConjugacyClasses( tbl2 );
      irr2:= Irr( tbl2 );
      irreds2:= [];
      irrnam2:= [];
      rest:= List( irr2, x -> x{ tblfustbl2 } );
      for i in [ 1 .. Length( irreds ) ] do

        for j in [ 1 .. Length( irreds[i] ) ] do

          chi2:= irr2{ Filtered( [ 1 .. nccl2 ],
                       k -> rest[k] = irreds[i][j] ) };
          if Length( chi2 ) = 2 then

            # The `j'-th character of the `i'-th degree of `tbl' extends.
            Append( irreds2, chi2 );
            Add( irrnam2, Concatenation( String( chi2[1][1] ), alp[j], "^+" ) );
            Add( irrnam2, Concatenation( String( chi2[1][1] ), alp[j], "^-" ) );

          else

            # The `j'-th character of the `i'-th degree of `tbl' fuses
            # with another character of `tbl', of the same degree.
            for k in [ 1 .. nccl2 ] do
              if     rest[k][1] = 2 * degreeset[i]
                 and ScalarProduct( tbl, rest[k], irreds[i][j] ) <> 0 then
                pos:= Position( irreds2, irr2[k] );
                if pos = fail then
                  Add( irreds2, irr2[k] );
                  Add( irrnam2, Concatenation( String( degreeset[i] ), alp[j] ) );
                else
                  Append( irrnam2[ pos ], alp[j] );
                fi;
              fi;
            od;

          fi;

        od;

      od;

      result:= List( irr2, chi -> irrnam2[ Position( irreds2, chi ) ] );

    else
      result:= List( irr, chi -> Concatenation( String( chi[1] ),
        alp[ Position( irreds[ Position( degreeset, chi[1] ) ], chi ) ] ) );
    fi;

    return result;
end );

#############################################################################
##
#V  DisplayStringLabelledMatrixDefaults
##
BindGlobal( "DisplayStringLabelledMatrixDefaults", rec(
    format    := "GAP",
    rowlabels := [],
    rowalign  := [ "t" ],
    rowsep    := [ , "-" ],
    collabels := [],
    colalign  := [ "l" ],
    colsep    := [ , "|" ],
    legend    := "",
    header    := ""
    ) );

#############################################################################
##
#F  DisplayStringLabelledMatrix( <matrix>, <inforec> )
##
##  <inforec> must be a record;
##  the following components are supported
##  \beginitems
##  `header'
##      (default nothing)
##
##  `rowlabels'
##      list of row labels (default nothing)
##
##  `rowalign'
##      list of vertical alignments ("top", "bottom", "center";
##      default top alignment)
##      the first is for the column labels!
##
##  `rowsep'
##      list of strings that separate rows
##      the first is for the row above the column labels,
##      the second is for the row below the column labels!
##      default separate column labels from the other lines by a line
##
##  `collabels'
##      list of column labels (default nothing)
##
##  `colalign'
##      list of horizontal alignments ("left", "right", "center";
##      default left alignment of label, right alignment of the rest)
##      the first is for the row labels!
##
##  `colsep'
##      list of strings that separate columns
##      the first is for the column before the row labels,
##      the second is for the column after the row labels!
##      default separate row labels from the other columns with a pipe
##
##  `legend'
##
##  `format'
##      one of `\"GAP\"', `\"HTML\"', or `\"LaTeX\"' (default `\"GAP\"').
##  \enditems
##
##  improved version, better than the one in `mferctbl'!
##
BindGlobal( "DisplayStringLabelledMatrix", function( matrix, inforec )
    local header, rowlabels, collabels, legend, format,       # options
          inforec2, name,
          ncols, colwidth, row, i, len, fmat, max, fcollabels,
          openmat, openrow, align1, opencol, closecol, closerow, closemat,
          str, j;

    # Get the parameters.
    inforec2:= ShallowCopy( DisplayStringLabelledMatrixDefaults );
    for name in RecNames( inforec ) do
      inforec2.( name ):= inforec.( name );
    od;
    inforec:= inforec2;

    if inforec.format = "GAP" then

      # Compute the column widths (used in GAP format only).
      ncols:= Length( matrix[1] );
      if IsEmpty( inforec.collabels ) then
        colwidth:= ListWithIdenticalEntries( ncols, 0 );
      else
        colwidth:= List( inforec.collabels, Length );
#T may be non-dense list
      fi;
      for row in matrix do
        for i in [ 1 .. ncols ] do
          len:= Length( row[i] );
          if colwidth[i] < len then
            colwidth[i]:= len;
          fi;
        od;
      od;
      matrix:= List( matrix,
                 row -> List( [ 1 .. ncols ],
                            i -> FormattedString( row[i], colwidth[i] ) ) );
#T alignment!

      # Inspect the row labels.
      if not IsEmpty( inforec.rowlabels ) then
        max:= Maximum( List( inforec.rowlabels, Length ) ) + 1;
        inforec.rowlabels:= List( inforec.rowlabels, x -> FormattedString( x, -max ) );
#T label alignment!
      else
        max:= 0;
      fi;

      # Set the parameters.
      if IsBound( inforec.colsep[1] ) then
        Append( fcollabels, inforec.colsep[1] );
      fi;
      fcollabels:= FormattedString( "", max );
      if IsBound( inforec.colsep[2] ) then
        Append( fcollabels, inforec.colsep[2] );
      fi;
      for i in [ 1 .. ncols ] do
        Append( fcollabels, " " );
        if IsBound( inforec.collabels[i] ) then
          Append( fcollabels,
                  FormattedString( inforec.collabels[i], colwidth[i] ) );
        else
          Append( fcollabels,
                  FormattedString( "", colwidth[i] ) );
        fi;
        if IsBound( inforec.colsep[ i+2 ] ) then
          Append( fcollabels, inforec.colsep[ i+2 ] );
          Append( fcollabels, " " );
        fi;
      od;
      Append( fcollabels, "\n" );
      openmat:= Concatenation( ListWithIdenticalEntries( max + Sum( colwidth ) + Length( colwidth ) + 1, '-' ), "\n" );
      openrow:= ShallowCopy( inforec.rowlabels );
      for i in [ 1 .. Length( matrix ) + 2 ] do
        if not IsBound( openrow[i] ) then
          openrow[i]:= "";
        fi;
        if IsBound( inforec.colsep[1] ) then
          openrow[i]:= Concatenation( inforec.colsep[1], openrow[i] );
        fi;
        if IsBound( inforec.colsep[2] ) then
          openrow[i]:= Concatenation( openrow[i], inforec.colsep[2] );
        fi;
      od;
      opencol  := List( matrix[1], x -> " " );
      closecol := [];
      for i in [ 1 .. ncols ] do
        if IsBound( inforec.colsep[ i+2 ] ) then
          closecol[i]:= inforec.colsep[ i+2 ];
        else
          closecol[i]:= "";
        fi;
      od;
      closerow := List( matrix, x -> "\n" );
      closemat := "";

    elif inforec.format = "HTML" then

      # Translate alignment values from LaTeX to HTML.
      inforec.colalign:= ShallowCopy( inforec.colalign );
      for i in [ 1 .. Length( inforec.colalign ) ] do
        if IsBound( inforec.colalign[i] ) then
          if   inforec.colalign[i] = "l" then
            inforec.colalign[i]:= "left";
          elif inforec.colalign[i] = "r" then
            inforec.colalign[i]:= "right";
          elif inforec.colalign[i] = "c" then
            inforec.colalign[i]:= "center";
          fi;
        fi;
      od;

      inforec.rowalign:= ShallowCopy( inforec.rowalign );
      for i in [ 1 .. Length( inforec.rowalign ) ] do
        if IsBound( inforec.rowalign[i] ) then
          if   inforec.rowalign[i] = "l" then
            inforec.rowalign[i]:= "left";
          elif inforec.rowalign[i] = "r" then
            inforec.rowalign[i]:= "right";
          elif inforec.rowalign[i] = "c" then
            inforec.rowalign[i]:= "center";
          fi;
        fi;
      od;

      # Set the parameters.
      ncols:= Length( matrix[1] );
      fcollabels:= "\n<table align=\"center\"";
      if not IsEmpty( inforec.colsep ) then
        Append( fcollabels, " border=2" );
      fi;
      if not IsEmpty( inforec.collabels ) then
        Append( fcollabels, ">\n<tr>\n" );
        if not IsEmpty( inforec.rowlabels ) then
          Append( fcollabels, "<td>\n</td>\n" );
        fi;
        for i in [ 1 .. ncols ] do
          Append( fcollabels, "<td align=\"" );
          if IsBound( inforec.colalign[ i+1 ] ) then
            Append( fcollabels, inforec.colalign[ i+1 ] );
          else
            Append( fcollabels, "right" );
          fi;
          Append( fcollabels, "\">" );
          if IsBound( inforec.collabels[i] ) then
            Append( fcollabels, inforec.collabels[i] );
          fi;
          Append( fcollabels, "</td>\n" );
        od;
        Append( fcollabels, "</tr>\n" );
      fi;

      openmat:= "";

      if IsEmpty( inforec.rowlabels ) then
        openrow:= List( matrix, x -> "<tr>\n" );
      else
        if IsBound( inforec.colalign[1] ) then
          align1:= inforec.colalign[1];
        else
          align1:= "right";
        fi;
        openrow:= List( inforec.rowlabels,
                        x -> Concatenation( "<tr>\n<td align=\"", align1, "\">", x, "</td>\n" ) );
        for i in [ 1 .. Length( matrix ) ] do
          if not IsBound( openrow[i] ) then
            openrow[i]:= Concatenation( "<tr>\n<td align=\"", align1, "\"></td>\n" );
          fi;
        od;
      fi;

      opencol:= [];
      for i in [ 1 .. ncols ] do
        if IsBound( inforec.colalign[ i+1 ] ) then
          opencol[i]:= Concatenation( "<td align=\"", inforec.colalign[ i+1 ], "\">\n" );
        else
          opencol[i]:= "<td align=\"right\">\n";
        fi;
      od;
      closecol:= List( matrix[1], x -> "</td>\n" );
      closerow:= List( matrix, x -> "</tr>\n" );
      closemat:= "</table>\n";

    elif inforec.format = "LaTeX" then

      # Set the parameters.
      ncols:= Length( matrix[1] );
      fcollabels:= "\\begin{tabular}{";
      if IsBound( inforec.colsep[1] ) then
        Append( fcollabels, inforec.colsep[1] );
      fi;
      if IsBound( inforec.colalign[1] ) then
        Append( fcollabels, inforec.colalign[1] );
      elif not IsEmpty( inforec.rowlabels ) then
        Append( fcollabels, "l" );
      fi;
      for i in [ 1 .. ncols ] do
        if IsBound( inforec.colsep[ i+1 ] ) then
          Append( fcollabels, inforec.colsep[ i+1 ] );
        fi;
        if IsBound( inforec.colalign[ i+1 ] ) then
          Append( fcollabels, inforec.colalign[ i+1 ] );
        else
          Append( fcollabels, "r" );
        fi;
      od;
      if IsBound( inforec.colsep[ ncols+2 ] ) then
        Append( fcollabels, inforec.colsep[ ncols+2 ] );
      fi;
      Append( fcollabels, "}" );
      if IsBound( inforec.rowsep[1] ) then
        if inforec.rowsep[1] = "=" then
          Append( fcollabels, " \\hline\\hline" );
        else
          Append( fcollabels, " \\hline" );
        fi;
      fi;
      Append( fcollabels, "\n" );
      if not IsEmpty( inforec.collabels ) then
        for i in [ 1 .. ncols ] do
          if 1 < i or not IsEmpty( inforec.rowlabels ) then
            Append( fcollabels, " & " );
          fi;
          if IsBound( inforec.collabels[i] ) then
            Append( fcollabels, inforec.collabels[i] );
          fi;
          Append( fcollabels, "\n" );
        od;
        Append( fcollabels, " \\rule[-7pt]{0pt}{20pt} \\\\" );
        if IsBound( inforec.rowsep[2] ) then
          if inforec.rowsep[2] = "=" then
            Append( fcollabels, " \\hline\\hline" );
          else
            Append( fcollabels, " \\hline" );
          fi;
        fi;
        Append( fcollabels, "\n" );
      fi;

      openmat:= "";

      openrow:= ShallowCopy( inforec.rowlabels );
      for i in [ 1 .. Length( matrix ) ] do
        if not IsBound( openrow[i] ) then
            openrow[i]:= "";
        else
            openrow[i]:= Concatenation( "$", openrow[i], "$" );
        fi;
      od;

      closerow:= [];
      for i in [ 1 .. Length( matrix ) ] do
        if IsBound( inforec.rowsep[ i+2 ] ) then
          if inforec.rowsep[ i+2 ] = "=" then
            closerow[i]:= " \\\\ \\hline\\hline\n";
          else
            closerow[i]:= " \\\\ \\hline\n";
          fi;
        else
          closerow[i]:= " \\\\\n";
        fi;
      od;

      opencol:= List( matrix[1], x -> " & " );
      if IsEmpty( inforec.rowlabels ) then
        opencol[1]:= "";
      fi;
      closecol:= List( matrix[1], x -> "" );

      closemat:= "\\rule[-7pt]{0pt}{5pt}\\end{tabular}\n";

    else
      Error( "<inforec>.format must be one of `\"GAP\"', `\"HTML\"', `\"LaTeX\"'" );
    fi;

    # Put the string for the matrix together.
    str:= ShallowCopy( inforec.header );
    Append( str, fcollabels );
    Append( str, openmat );
    for i in [ 1 .. Length( matrix ) ] do
      row:= matrix[i];
      Append( str, openrow[i] );
      for j in [ 1 .. ncols ] do
        Append( str, opencol[j] );
        Append( str, row[j] );
        Append( str, closecol[j] );
      od;
      Append( str, closerow[i] );
    od;
    Append( str, closemat );
    Append( str, inforec.legend );

    # Return the string.
    return str;
end );

#############################################################################
##
#F  DisplayMultFreeEndoRingCharacterTable( <record> )
##
BindGlobal( "DisplayMultFreeEndoRingCharacterTable", function( record )
    local   name,  subname,  pos,  header,  mat,  triples,  legend,
            row,  mrow,  entry,  l,  triple,  tbl,  simpname,  tbl2,
            charlabels,  rowlabels,  collabels,  str;

    name:=record.group;
    if name[1] = '$' then
      name:= name{ [ 2 .. Length( name ) - 1 ] };
    fi;
    subname:= record.subgroup;
    if subname[1] = '$' then
      subname:= subname{ [ 2 .. Length( subname ) - 1 ] };
    fi;
    pos:= PositionSublist( subname, "\\leq" );
    if pos <> fail then
      subname:= Concatenation( subname{ [ 1 .. pos-1 ] }, "< ",
                               subname{ [ pos+5 .. Length( subname ) ] } );
    fi;
    pos:= PositionSublist( subname, "\\rightarrow" );
    if pos <> fail then
      subname:= Concatenation( subname{ [ 1 .. pos-1 ] }, "---> ",
                               subname{ [ pos+12 .. Length( subname ) ] } );
    fi;

    header:= Concatenation( "G = ", name, ", H = ", subname, "\n\n" );

    if IsMatrix( record.ctbl ) then

      mat:= [];
      triples:= [];
      legend:= "";
      for row in record.ctbl do
        mrow:= [];
        for entry in row do
          l:= Quadratic( entry );
          if IsRecord( l ) then
            Add( mrow, l.ATLAS );
          else
            l:= Cubic( entry );
            if not IsRecord( l ) then
              Error( "entry <l> not expected" );
            fi;
            Add( mrow, l.ATLAS );
          fi;
          if not IsInt( entry ) then
            AddSet( triples, [ l.ATLAS, l.display ] );
          fi;
        od;
        Add( mat, mrow );
      od;
      for triple in triples do
        Append( legend, "\n" );
        Append( legend, triple[1] );
        Append( legend, " = " );
        Append( legend, triple[2] );
      od;
#T better legend: only smallest multiple of several
#T (example: see first table of M12.2, multiples of r3 and r5)

      tbl:= CharacterTable( record.name );
      if '.' in record.name then
          simpname:= record.name{ [ 1 .. Position( record.name, '.' )-1 ] };
          if Int(simpname)=fail then
              tbl2:= tbl;
              tbl:= CharacterTable( simpname );
              charlabels:= CharacterLabels( tbl2, tbl );
          else
              charlabels:= CharacterLabels( tbl );
          fi;
      else
        charlabels:= CharacterLabels( tbl );
      fi;
      rowlabels:= charlabels{ record.charnmbs };
      collabels:= List( [ 1 .. record.rank ],
                        i -> Concatenation( "O_", String( i ) ) );
      str:= DisplayStringLabelledMatrix( mat,
                rec( header    := header,
                     rowlabels := rowlabels,
                     collabels := collabels,
                     legend    := legend,
                     format    := "GAP"      ) );
    else
      str:= Concatenation( header, "(character table not yet known)" );
    fi;
    Print( str, "\n" );
end );

#############################################################################
##
#F  MultFreeFromTOM( <name> )
##
##  For a string <name> that is a valid name for a table of marks in the
##  {\GAP} library of tables of marks, `MultFreeFromTOM' returns
##  the list of pairs $[ \pi, G ]$ where $\pi$ is a multiplicity free
##  permutation character of the group for <name>,
##  and $G$ is the corresponding permutation group,
##  as computed from the table of marks of this group.
##
##  If there is no table of marks for <name> or if the class fusion of the
##  character table for <name> into the table of marks is not unique then
##  `fail' is returned.
##
BindGlobal( "MultFreeFromTOM", function( name )
    local tom,      # the table of marks
          G,        # the underlying group
          t,        # the character table
          fus,      # fusion map from 't' to 'tom'
          perms,    # list of perm. characters
          multfree, # list of mult. free characters and perm. groups
          i,        # loop over `perms'
          H,        # point stabilizer
          tr,       # right transversal of `H' in `G'
          P;        # permutation action of `G' on the cosets of `H'

    tom:= TableOfMarks( name );
    if tom <> fail then

      G:= UnderlyingGroup( tom );
      t:= CharacterTable( name );
      fus:= FusionCharTableTom( t, tom );

      if ForAll( fus, IsInt ) then
        perms:= PermCharsTom( fus, tom );
        multfree:= [];
        for i in [ 1 .. Length( perms ) ] do
          if ForAll( Irr( t ),
                     chi -> ScalarProduct( t, chi, perms[i] ) <= 1 ) then
            H:= RepresentativeTom( tom, i );
            tr:= RightTransversal( G, H );
            P:= Action( G, tr, OnRight );
            Add( multfree, [ Character( t, perms[i] ), P ] );
          fi;
        od;
      else
        Print( "#E  fusion is not unique!\n" );
        multfree:= fail;
      fi;

    else
      multfree:= fail;
    fi;

    return multfree;
end );

#############################################################################
##
#F  OrbitAndTransversal( <gens>, <pt> )
##
##  Let <gens> be a list of permutations, and <pt> be a positive integer.
##  `OrbitAndTransversal' returns a record that describes the orbit of <pt>
##  under the group generated by <gens>, as follows.
##  The component `orb' is the orbit itself,
##  the component `from' is the list of predecessors,
##  the component `use' is the list of positions of generators used
##
OrbitAndTransversal := function( gens, pt )
    local orb,   # the orbit of `pt'
          sort,  # a sorted copy of `orb', for faster lookup
          from,  # list of points
          use,
          i,
          j,
          img;

    # Initialize the lists.
    orb  := [ pt ];
    sort := [ pt ];
    from := [ fail ];
    use  := [ fail ];

    # Compute the orbit.
    for i in orb do
      for j in [ 1 .. Length( gens ) ] do
        img:= i^gens[j];
        if not img in sort then
          Add( orb, img );
          AddSet( sort, img );
          Add( from, i );
          Add( use, j );
        fi;
      od;
    od;

    # Return the result.
    return rec( orb  := orb,
                from := from,
                use  := use,
                gens := gens );
    end;

#############################################################################
##
#F  RepresentativeFromTransversal( <orbitinfo>, <gens>, <pt> )
##
##  Let <orbitinfo> be a record returned by `OrbitAndTransversal', and <pt>
##  be a point in the orbit `<orbitinfo>.orb'.
##  `RepresentativeFromTransversal' returns an element in the group generated
##  by `<orbitinfo>.gens' that maps `<orbitinfo>.orb[1]' to <pt>.
##
RepresentativeFromTransversal := function( record, gens, pt2 )
    local orb, from, use, rep, pos;

    orb  := record.orb;
    from := record.from;
    use  := record.use;
    rep  := ();

    while pt2 <> orb[1] do
      pos:= Position( orb, pt2 );
      rep:= gens[ use[ pos ] ] * rep;
      pt2:= from[ pos ];
    od;

    return rep;
    end;

#############################################################################
##
#F  CollapsedAdjacencyMatricesInfo( <G>[, <order>][, <S>] )
##
##  Let <G> be a transitive permutations group,
##  $\omega$ the smallest point moved by <G>,
##  and $S$ the stabilizer of $\omega$ in <G>.
##  `CollapsedAdjacencyMatricesInfo' returns a record describing the
##  collapsed adjacency matrices of the permutation module.
##  The components are
##  `mats'
##      the collapsed adjacency matrices,
##
##  `points'
##      a list of representatives of the orbits of $S$ on the set of the
##      points moved by <G>,
##
##  `representatives' :
##      a list of elements in <G> such that the $i$-th entry maps $\omega$
##      to the $i$-th entry in the `points' list,
##
##  The order of <G> can be given as the optional argument <order>,
##  and the group $S$ can be given as the optional argument <S>.
##
CollapsedAdjacencyMatricesInfo := function( arg )
    local G,size,stab,points,gens,orbs,record,reps,mats,r,i,j,k,img;

    # Get and check the arguments.
    if   Length( arg ) = 1 and IsPermGroup( arg[1] ) then
      G    := arg[1];
      size := Size( G );
    elif Length( arg ) = 2 and IsPermGroup( arg[1] )
                           and IsPosInt( arg[2] ) then
      G    := arg[1];
      size := arg[2];
    elif Length( arg ) = 2 and IsPermGroup( arg[1] )
                           and IsPermGroup( arg[2] ) then
      G    := arg[1];
      size := Size( G );
      stab := arg[2];
    elif Length( arg ) = 3 and IsPermGroup( arg[1] )
                           and IsPosInt( arg[2] )
                           and IsPermGroup( arg[3] ) then
      G    := arg[1];
      size := arg[2];
      stab := arg[3];
    fi;
    points:= MovedPoints( G );
    if not IsBound( stab ) then
      stab:= Stabilizer( G, points[1] );
    fi;

    # Compute the orbits of the point stabilizer, and sort them.
    gens:= GeneratorsOfGroup( G );
    orbs:= List( Orbits( stab, points ), Set );
    SortParallel( List( orbs, Length ), orbs );

    # Compute representatives ...
    record:= OrbitAndTransversal( gens, orbs[1][1] );
    reps:= List( orbs,
                 x -> RepresentativeFromTransversal( record, gens, x[1] ) );

    # Compute the collapsed adjacency matrices.
    mats:= [];
    r:= Length( orbs );
    for i in [ 1 .. r ] do
      mats[i]:= [];
      for j in [ 1 .. r ] do
        mats[i][j]:= [];
      od;
      for k in [1 .. r] do
        img:= OnTuples( orbs[i], reps[k] );
        for j in [ 1 .. r ] do
          mats[i][j][k]:= Number( Intersection( orbs[j], img ) );
        od;
      od;
    od;

    # Return the result.
    return rec( mats            := mats,
                points          := List( orbs, x -> x[1] ),
                representatives := reps );
    end;

#############################################################################
##

MULTFREEINFO.("M11"):= ["$M_{11}$",
##
[[1,2],"$A_6.2_3$",
 [[1,10],
  [1,-1]]],
##
[[1,2,5],"$A_6 \\leq A_6.2_3$",
 [[1,1,20],
  [1,1,-2],
  [1,-1,0]]],
##
[[1,5],"$L_2(11)$",
 [[1,11],
  [1,-1]]],
##
[[1,5,6,7,9,10],"$11:5 \\leq L_2(11)$",
 [[1,11,11,11,55,55],
  [1,-1,-1,11,-5,-5],
  [1,(-5-3*ER(-11))/2,(-5+3*ER(-11))/2,-1,-5,10],
  [1,(-5+3*ER(-11))/2,(-5-3*ER(-11))/2,-1,-5,10],
  [1,3,3,-1,-5,-1],
  [1,-1,-1,-1,7,-5]]],
##
[[1,2,8],"$3^2:Q_8.2$",
 [[1,18,36],
  [1,7,-8],
  [1,-2,1]]],
##
[[1,2,8,10],"$3^2:8 \\leq 3^2:Q_8.2$",
 [[1,1,36,72],
  [1,1,14,-16],
  [1,1,-4,2],
  [1,-1,0,0]]],
##
[[1,2,5,8],"$A_5.2$",
 [[1,15,20,30],
  [1,-7,-2,8],
  [1,-3,8,-6],
  [1,2,-2,-1]]]];

MULTFREEINFO.("M12"):= ["$M_{12}$",
##
[[1,2],"$M_{11}$",
 [[1,11],
  [1,-1]]],
##
[[1,3],"$M_{11}$",
 [[1,11],
  [1,-1]]],
##
[[1,2,3,8,11],"$L_2(11) \\leq M_{11}$",
 [[1,11,11,55,66],
  [1,-1,11,-5,-6],
  [1,11,-1,-5,-6],
  [1,-1,-1,7,-6],
  [1,-1,-1,-5,6]]],
##
[[1,2,7],"$A_6.2^2$",
 [[1,20,45],
  [1,8,-9],
  [1,-2,1]]],
##
[[1,2,3,7,8],"$A_6.2_1 \\leq A_6.2^2$",
 [[1,1,40,45,45],
  [1,-1,0,15,-15],
  [1,1,16,-9,-9],
  [1,1,-4,1,1],
  [1,-1,0,-3,3]]],
##
[[1,2,7,11],"$A_6.2_2 \\leq A_6.2^2$",
 [[1,1,40,90],
  [1,1,16,-18],
  [1,1,-4,2],
  [1,-1,0,0]]],
##
[[1,3,7],"$A_6.2^2$",
 [[1,20,45],
  [1,8,-9],
  [1,-2,1]]],
##
[[1,2,3,7,8],"$A_6.2_1 \\leq A_6.2^2$",
 [[1,1,40,45,45],
  [1,1,16,-9,-9],
  [1,-1,0,15,-15],
  [1,1,-4,1,1],
  [1,-1,0,-3,3]]],
##
[[1,3,7,11],"$A_6.2_2 \\leq A_6.2^2$",
 [[1,1,40,90],
  [1,1,16,-18],
  [1,1,-4,2],
  [1,-1,0,0]]],
##
[[1,4,5,6,11],"$L_2(11)$",
 [[1,11,11,55,66],
  [1,(-5-3*ER(-11))/2,(-5+3*ER(-11))/2,10,-6],
  [1,(-5+3*ER(-11))/2,(-5-3*ER(-11))/2,10,-6],
  [1,3,3,-1,-6],
  [1,-1,-1,-5,6]]],
##
[[1,2,7,8,12],"$3^2.2.S_4$",
 [[1,12,27,72,108],
  [1,-4,15,-24,12],
  [1,1,5,6,-13],
  [1,5,-3,-6,3],
  [1,-3,-3,2,3]]],
##
[[1,2,6,7,8,10,12,13],"$3^2:2.A_4 \\leq 3^2.2.S_4$",
 [[1,1,24,27,27,72,72,216],
  [1,1,-8,15,15,-24,-24,24],
  [1,-1,0,3,-3,16,-16,0],
  [1,1,2,5,5,6,6,-26],
  [1,1,10,-3,-3,-6,-6,6],
  [1,-1,0,-9,9,0,0,0],
  [1,1,-6,-3,-3,2,2,6],
  [1,-1,0,3,-3,-6,6,0]]],
##
[[1,3,7,8,12],"$3^2.2.S_4$",
 [[1,12,27,72,108],
  [1,-4,15,-24,12],
  [1,1,5,6,-13],
  [1,5,-3,-6,3],
  [1,-3,-3,2,3]]],
##
[[1,3,6,7,8,9,12,13],"$3^2:2.A_4 \\leq 3^2.2.S_4$",
 [[1,1,24,27,27,72,72,216],
  [1,1,-8,15,15,-24,-24,24],
  [1,-1,0,3,-3,16,-16,0],
  [1,1,2,5,5,6,6,-26],
  [1,1,10,-3,-3,-6,-6,6],
  [1,-1,0,-9,9,0,0,0],
  [1,1,-6,-3,-3,2,2,6],
  [1,-1,0,3,-3,-6,6,0]]]];

MULTFREEINFO.("J1"):= ["$J_1$",
##
[[1,2,3,4,6],"$L_2(11)$",
 [[1,11,12,110,132],
  [1,(-7-ER(5))/2,(-3+3*ER(5))/2,(5+7*ER(5))/2,(3-9*ER(5))/2],
  [1,(-7+ER(5))/2,(-3-3*ER(5))/2,(5-7*ER(5))/2,(3+9*ER(5))/2],
  [1,4,-2,5,-8],
  [1,1,4,-10,4]]],
##
[[1,2,3,4,7,8,9,10,11,12,15],"$2^3.7.3$",
 [[1,8,28,56,56,56,168,168,168,168,168],
  [1,-2-ER(5),1+3*ER(5),1+4*ER(5),-11-ER(5),(23-7*ER(5))/2,6*ER(5),
   (-33+3*ER(5))/2,(27+9*ER(5))/2,-6-6*ER(5),(15-15*ER(5))/2],
  [1,-2+ER(5),1-3*ER(5),1-4*ER(5),-11+ER(5),(23+7*ER(5))/2,-6*ER(5),
   (-33-3*ER(5))/2,(27-9*ER(5))/2,-6+6*ER(5),(15+15*ER(5))/2],
  [1,2,11,-4,4,-2,-24,-6,12,18,-12],
  [1,-2-ER(5),-7,1+4*ER(5),-4+4*ER(5),-4-ER(5),3,3-9*ER(5),3-3*ER(5),
   18+3*ER(5),-12+3*ER(5)],
  [1,-2+ER(5),-7,1-4*ER(5),-4-4*ER(5),-4+ER(5),3,3+9*ER(5),3+3*ER(5),
   18-3*ER(5),-12-3*ER(5)],
  [1,-EC(19)-2*GaloisCyc(EC(19),2)-2*GaloisCyc(EC(19),4),
   2*GaloisCyc(EC(19),4),4*EC(19)-GaloisCyc(EC(19),2),
   -EC(19)+2*GaloisCyc(EC(19),2)-2*GaloisCyc(EC(19),4),
   7*EC(19)+7*GaloisCyc(EC(19),2)+6*GaloisCyc(EC(19),4),
   -6*EC(19)-2*GaloisCyc(EC(19),2)-GaloisCyc(EC(19),4),
   3*EC(19)+GaloisCyc(EC(19),2)+2*GaloisCyc(EC(19),4),
   -EC(19)+2*GaloisCyc(EC(19),2)-5*GaloisCyc(EC(19),4),
   5*EC(19)+4*GaloisCyc(EC(19),2)+8*GaloisCyc(EC(19),4),
   -9*EC(19)-10*GaloisCyc(EC(19),2)-7*GaloisCyc(EC(19),4)],
  [1,-2*EC(19)-2*GaloisCyc(EC(19),2)-GaloisCyc(EC(19),4),
   2*GaloisCyc(EC(19),2),-EC(19)+4*GaloisCyc(EC(19),4),
   2*EC(19)-2*GaloisCyc(EC(19),2)-GaloisCyc(EC(19),4),
   7*EC(19)+6*GaloisCyc(EC(19),2)+7*GaloisCyc(EC(19),4),
   -2*EC(19)-GaloisCyc(EC(19),2)-6*GaloisCyc(EC(19),4),
   EC(19)+2*GaloisCyc(EC(19),2)+3*GaloisCyc(EC(19),4),
   2*EC(19)-5*GaloisCyc(EC(19),2)-GaloisCyc(EC(19),4),
   4*EC(19)+8*GaloisCyc(EC(19),2)+5*GaloisCyc(EC(19),4),
   -10*EC(19)-7*GaloisCyc(EC(19),2)-9*GaloisCyc(EC(19),4)],
  [1,-2*EC(19)-GaloisCyc(EC(19),2)-2*GaloisCyc(EC(19),4),2*EC(19),
   4*GaloisCyc(EC(19),2)-GaloisCyc(EC(19),4),
   -2*EC(19)-GaloisCyc(EC(19),2)+2*GaloisCyc(EC(19),4),
   6*EC(19)+7*GaloisCyc(EC(19),2)+7*GaloisCyc(EC(19),4),
   -EC(19)-6*GaloisCyc(EC(19),2)-2*GaloisCyc(EC(19),4),
   2*EC(19)+3*GaloisCyc(EC(19),2)+GaloisCyc(EC(19),4),
   -5*EC(19)-GaloisCyc(EC(19),2)+2*GaloisCyc(EC(19),4),
   8*EC(19)+5*GaloisCyc(EC(19),2)+4*GaloisCyc(EC(19),4),
   -7*EC(19)-9*GaloisCyc(EC(19),2)-10*GaloisCyc(EC(19),4)],
  [1,3,1,1,4,9,15,-4,-14,-1,-15],
  [1,-3,1,1,4,3,-9,14,-8,-7,3]]]];

MULTFREEINFO.("M22"):= ["$M_{22}$",
##
[[1,2],"$L_3(4)$",
 [[1,21],
  [1,-1]]],
##
[[1,2,5],"$2^4:A_6$",
 [[1,16,60],
  [1,-6,5],
  [1,2,-3]]],
##
[[1,2,5,7,9],"$2^4:A_5 \\leq 2^4:A_6$",
 [[1,5,96,120,240],
  [1,5,-36,10,20],
  [1,5,12,-6,-12],
  [1,-1,0,12,-12],
  [1,-1,0,-8,8]]],
##
[[1,2,7],"$A_7$",
 [[1,70,105],
  [1,-18,17],
  [1,2,-3]]],
##
[[1,2,7],"$A_7$",
 [[1,70,105],
  [1,-18,17],
  [1,2,-3]]],
##
[[1,2,5,7],"$2^4:S_5$",
 [[1,30,40,160],
  [1,-3,18,-16],
  [1,9,-2,-8],
  [1,-3,-2,4]]],
##
[[1,2,5,6,7],"$2^3:L_3(2)$",
 [[1,7,42,112,168],
  [1,-4,9,24,-30],
  [1,4,9,-8,-6],
  [1,-3,2,-8,8],
  [1,1,-6,4,0]]],
##
[[1,2,5,7,12],"$A_6.2_3$",
 [[1,30,45,180,360],
  [1,8,-21,48,-36],
  [1,16,3,-16,-4],
  [1,-2,9,8,-16],
  [1,-2,-3,-4,8]]],
##
[[1,2,5,7,8,9],"$L_2(11)$",
 [[1,55,55,66,165,330],
  [1,15,-25,-6,45,-30],
  [1,13,13,-18,-3,-6],
  [1,-5,7,6,9,-18],
  [1,-7,-3,-6,1,14],
  [1,5,-3,6,-11,2]]]];

MULTFREEINFO.("J2"):= ["$J_2$",
##
[[1,6,7],"$U_3(3)$",
 [[1,36,63],
  [1,6,-7],
  [1,-4,3]]],
##
[[1,7,10,11],"$3.A_6.2_2$",
 [[1,36,108,135],
  [1,-4,-12,15],
  [1,8,-4,-5],
  [1,-4,8,-5]]],
##
[[1,2,3,6,10,12],"$2^{1+4}_{-}:A_5$",
 [[1,10,32,32,80,160],
  [1,-5,2-6*ER(5),2+6*ER(5),20,-20],
  [1,-5,2+6*ER(5),2-6*ER(5),20,-20],
  [1,5,-8,-8,10,0],
  [1,3,4,4,-4,-8],
  [1,-2,-1,-1,-4,7]]],
##
[[1,6,7,10,12,13],"$2^{2+4}.(3 \\times S_3)$",
 [[1,12,32,96,192,192],
  [1,7,-8,16,-28,12],
  [1,-3,12,6,-18,2],
  [1,5,4,-2,10,-18],
  [1,0,-1,-12,0,12],
  [1,-3,-4,6,6,-6]]],
##
[[1,7,10,11,12,13,18],"$A_4 \\times A_5$",
 [[1,15,20,24,180,240,360],
  [1,5,10,-6,0,20,-30],
  [1,1,6,10,-16,-12,10],
  [1,-5,0,4,20,0,-20],
  [1,6,-4,0,9,-12,0],
  [1,-3,2,-6,0,-12,18],
  [1,-1,-4,0,-12,16,0]]]];

MULTFREEINFO.("M23"):= ["$M_{23}$",
##
[[1,2],"$M_{22}$",
 [[1,22],
  [1,-1]]],
##
[[1,2,5],"$L_3(4).2_2$",
 [[1,112,140],
  [1,-26,25],
  [1,2,-3]]],
##
[[1,2,5],"$2^4:A_7$",
 [[1,112,140],
  [1,-26,25],
  [1,2,-3]]],
##
[[1,2,5,9],"$A_8$",
 [[1,15,210,280],
  [1,-8,49,-42],
  [1,4,1,-6],
  [1,-3,-6,8]]],
##
[[1,2,5,16],"$M_{11}$",
 [[1,165,330,792],
  [1,-65,100,-36],
  [1,19,16,-36],
  [1,-3,-6,8]]]];

MULTFREEINFO.("HS"):= ["$HS$",
##
[[1,2,3],"$M_{22}$",
 [[1,22,77],
  [1,-8,7],
  [1,2,-3]]],
##
[[1,7],"$U_3(5).2$",
 [[1,175],
  [1,-1]]],
##
[[1,2,5,7],"$U_3(5) \\leq U_3(5).2$",
 [[1,1,175,175],
  [1,-1,35,-35],
  [1,-1,-5,5],
  [1,1,-1,-1]]],
##
[[1,7],"$U_3(5).2$",
 [[1,175],
  [1,-1]]],
##
[[1,2,6,7],"$U_3(5) \\leq U_3(5).2$",
 [[1,1,175,175],
  [1,-1,35,-35],
  [1,-1,-5,5],
  [1,1,-1,-1]]],
##
[[1,2,3,7,13],"$L_3(4).2_1$",
 [[1,42,105,280,672],
  [1,12,-45,80,-48],
  [1,22,5,-20,-8],
  [1,-2,17,16,-32],
  [1,-2,-3,-4,8]]],
##
[[1,3,4,7,9],"$A_8.2$",
 [[1,28,105,336,630],
  [1,-12,25,16,-30],
  [1,8,15,-24,0],
  [1,6,-5,28,-30],
  [1,-2,-5,-4,10]]],
##
[[1,2,3,4,5,6,7,9,10],"$A_8 \\leq A_8.2$",
 [[1,1,28,28,105,105,336,336,1260],
  [1,-1,0,0,-35,35,-112,112,0],
  [1,1,-12,-12,25,25,16,16,-60],
  [1,1,8,8,15,15,-24,-24,0],
  [1,-1,-10,10,15,-15,-12,12,0],
  [1,-1,10,-10,15,-15,-12,12,0],
  [1,1,6,6,-5,-5,28,28,-60],
  [1,1,-2,-2,-5,-5,-4,-4,20],
  [1,-1,0,0,-5,5,8,-8,0]]],
##
[[1,2,3,4,7,9,10,13,18],"$4^3:L_3(2)$",
 [[1,28,64,112,336,448,896,896,1344],
  [1,-7,-36,42,-84,168,-224,56,84],
  [1,13,14,32,6,28,16,-164,54],
  [1,13,4,22,36,-32,-64,56,-36],
  [1,-5,20,2,6,52,16,16,-108],
  [1,3,4,2,-34,-12,16,16,4],
  [1,-7,-6,12,6,-12,16,-4,-6],
  [1,5,-10,-8,6,12,16,-4,-18],
  [1,-2,4,-8,6,-2,-19,-4,24]]],
##
[[1,2,3,5,7,10,13,16,22],"$M_{11}$",
 [[1,55,132,165,495,660,792,1320,1980],
  [1,5,52,-85,195,-140,72,-280,180],
  [1,-20,37,40,45,85,-138,-80,30],
  [1,-19,-12,-21,27,84,72,-24,-108],
  [1,7,4,37,63,-44,24,40,-132],
  [1,-4,13,-16,-3,-11,-18,56,-18],
  [1,12,-11,-8,13,21,-26,0,-2],
  [1,6,13,4,-23,9,22,-24,-8],
  [1,-4,-7,4,-3,-11,2,-4,22]]],
##
[[1,2,3,6,7,10,13,16,22],"$M_{11}$",
 [[1,55,132,165,495,660,792,1320,1980],
  [1,5,52,-85,195,-140,72,-280,180],
  [1,-20,37,40,45,85,-138,-80,30],
  [1,-19,-12,-21,27,84,72,-24,-108],
  [1,7,4,37,63,-44,24,40,-132],
  [1,-4,13,-16,-3,-11,-18,56,-18],
  [1,12,-11,-8,13,21,-26,0,-2],
  [1,6,13,4,-23,9,22,-24,-8],
  [1,-4,-7,4,-3,-11,2,-4,22]]],
##
[[1,3,4,7,9,13,16,17,18],"$4.2^4:S_5$",
 [[1,30,80,128,480,640,960,1536,1920],
  [1,15,20,-32,60,80,0,96,-240],
  [1,15,20,8,60,-20,0,-144,60],
  [1,-3,14,40,-48,68,36,-48,-60],
  [1,5,-10,8,0,20,-60,16,20],
  [1,7,4,0,-28,-32,16,32,0],
  [1,-5,10,-12,-10,10,-20,-4,30],
  [1,-5,0,8,20,-20,0,16,-20],
  [1,0,-10,-7,0,10,30,-24,0]]]];

MULTFREEINFO.("J3"):= ["$J_3$",
##
[[1,4,5,6,10,11,12,13],"$L_2(16).2$",
 [[1,85,120,510,680,1360,1360,2040],
  [1,13,12,-30,-40,28-36*ER(5),28+36*ER(5),-12],
  [1,13,12,-30,-40,28+36*ER(5),28-36*ER(5),-12],
  [1,-17,-18,0,0,68,68,-102],
  [1,13,-6,6,32,-8,-8,-30],
  [1,-4-ER(17),-6+2*ER(17),-11-5*ER(17),-2+6*ER(17),-8,-8,38-2*ER(17)],
  [1,-4+ER(17),-6-2*ER(17),-11+5*ER(17),-2-6*ER(17),-8,-8,38+2*ER(17)],
  [1,-5,12,24,-4,-8,-8,-12]]]];

MULTFREEINFO.("M24"):= ["$M_{24}$",
##
[[1,2],"$M_{23}$",
 [[1,23],
  [1,-1]]],
##
[[1,2,7],"$M_{22}.2$",
 [[1,44,231],
  [1,20,-21],
  [1,-2,1]]],
##
[[1,2,7,9],"$2^4:A_8$",
 [[1,30,280,448],
  [1,-15,70,-56],
  [1,7,4,-12],
  [1,-3,-6,8]]],
##
[[1,7,14],"$M_{12}.2$",
 [[1,495,792],
  [1,35,-36],
  [1,-9,8]]],
##
[[1,2,7,14,17],"$M_{12} \\leq M_{12}.2$",
 [[1,1,495,495,1584],
  [1,-1,-165,165,0],
  [1,1,35,35,-72],
  [1,1,-9,-9,16],
  [1,-1,3,-3,0]]],
##
[[1,7,9,14],"$2^6:3.S_6$",
 [[1,90,240,1440],
  [1,21,10,-32],
  [1,-9,20,-12],
  [1,-1,-12,12]]],
##
[[1,7,9,14,18],"$2^6:3.A_6 \\leq 2^6:3.S_6$",
 [[1,1,180,480,2880],
  [1,1,42,20,-64],
  [1,1,-18,40,-24],
  [1,1,-2,-24,24],
  [1,-1,0,0,0]]],
##
[[1,2,7,9,17],"$L_3(4).3.2_2$",
 [[1,63,210,630,1120],
  [1,39,-30,150,-160],
  [1,17,3,-37,16],
  [1,-3,23,3,-24],
  [1,-3,-9,3,8]]],
##
[[1,2,7,8,9,17,18],"$L_3(4).3 \\leq L_3(4).3.2_2$",
 [[1,1,63,63,420,1260,2240],
  [1,1,39,39,-60,300,-320],
  [1,1,17,17,6,-74,32],
  [1,-1,-21,21,0,0,0],
  [1,1,-3,-3,46,6,-48],
  [1,1,-3,-3,-18,6,16],
  [1,-1,3,-3,0,0,0]]],
##
[[1,7,9,14,19],"$2^6:(L_3(2) \\times S_3)$",
 [[1,42,56,1008,2688],
  [1,19,10,42,-72],
  [1,9,-10,-48,48],
  [1,-3,10,-24,16],
  [1,-3,-4,18,-12]]],
##
[[1,7,8,9,14,17,19,20],
"$2^6:(L_3(2) \\times 3) \\leq 2^6:(L_3(2) \\times S_3)$",
 [[1,1,56,56,84,2016,2688,2688],
  [1,1,10,10,38,84,-72,-72],
  [1,-1,-14,14,0,0,-168,168],
  [1,1,-10,-10,18,-96,48,48],
  [1,1,10,10,-6,-48,16,16],
  [1,-1,10,-10,0,0,-24,24],
  [1,1,-4,-4,-6,36,-12,-12],
  [1,-1,-4,4,0,0,32,-32]]],
##
[[1,7,9,14,17,18,19,20,23,24,26],
"$2^6:(7:3 \\times S_3) \\leq 2^6:(L_3(2) \\times S_3)$",
 [[1,7,168,168,224,224,2688,2688,8064,8064,8064],
  [1,7,76,76,40,40,-72,-72,-216,-216,336],
  [1,7,36,36,-40,-40,48,48,144,144,-384],
  [1,7,-12,-12,40,40,16,16,48,48,-192],
  [1,-1,12,-12,-8,8,0,0,-288,288,0],
  [1,-1,-24,24,-32,32,0,0,0,0,0],
  [1,7,-12,-12,-16,-16,-12,-12,-36,-36,144],
  [1,-1,12,-12,-8,8,112,-112,48,-48,0],
  [1,-1,12,-12,-8,8,-48,48,48,-48,0],
  [1,-1,-4,4,8,-8,60,60,-60,-60,0],
  [1,-1,-4,4,8,-8,-32,-32,32,32,0]]]];

MULTFREEINFO.("McL"):= ["$McL$",
##
[[1,2,4],"$U_4(3)$",
 [[1,112,162],
  [1,-28,27],
  [1,2,-3]]],
##
[[1,2,4,9],"$M_{22}$",
 [[1,330,462,1232],
  [1,-120,147,-28],
  [1,30,27,-58],
  [1,-3,-6,8]]],
##
[[1,2,4,9],"$M_{22}$",
 [[1,330,462,1232],
  [1,-120,147,-28],
  [1,30,27,-58],
  [1,-3,-6,8]]],
##
[[1,2,4,9,14],"$U_3(5)$",
 [[1,252,750,2625,3500],
  [1,-126,300,-525,350],
  [1,54,90,-15,-130],
  [1,-18,12,51,-46],
  [1,4,-10,-15,20]]],
##
[[1,4,12,14,15],"$3^{1+4}:2S_5$",
 [[1,90,1215,2430,11664],
  [1,35,225,-45,-216],
  [1,-1,-3,-69,72],
  [1,10,-25,30,-16],
  [1,-10,15,30,-36]]],
##
[[1,4,9,14,15,20],"$2.A_8$",
 [[1,210,2240,5040,6720,8064],
  [1,45,260,90,-540,144],
  [1,39,-28,72,60,-144],
  [1,-5,60,-60,60,-56],
  [1,-15,-10,90,-30,-36],
  [1,3,-28,-36,-12,72]]]];

MULTFREEINFO.("He"):= ["$He$",
##
[[1,2,3,6,9],"$S_4(4).2$",
 [[1,136,136,425,1360],
  [1,-18-14*ER(-7),-18+14*ER(-7),75,-40],
  [1,-18+14*ER(-7),-18-14*ER(-7),75,-40],
  [1,10,10,5,-26],
  [1,-4,-4,-9,16]]],
##
[[1,2,3,6,7,8,9],"$S_4(4) \\leq S_4(4).2$",
 [[1,1,272,272,425,425,2720],
  [1,1,-36-28*ER(-7),-36+28*ER(-7),75,75,-80],
  [1,1,-36+28*ER(-7),-36-28*ER(-7),75,75,-80],
  [1,1,20,20,5,5,-52],
  [1,-1,0,0,-5*ER(17),5*ER(17),0],
  [1,-1,0,0,5*ER(17),-5*ER(17),0],
  [1,1,-8,-8,-9,-9,32]]],
##
[[1,2,3,6,9,12,14],"$2^2.L_3(4).S_3$",
 [[1,105,720,840,840,1344,4480],
  [1,35,-120,-70-70*ER(-7),-70+70*ER(-7),224,0],
  [1,35,-120,-70+70*ER(-7),-70-70*ER(-7),224,0],
  [1,21,6,42,42,0,-112],
  [1,7,48,-28,-28,0,0],
  [1,-14,6,7,7,35,-42],
  [1,0,-15,0,0,-21,35]]],
##
[[1,2,3,6,7,8,9,12,14,15],"$2^2.L_3(4).3 \\leq 2^2.L_3(4).S_3$",
 [[1,1,105,105,1344,1344,1440,1680,1680,8960],
  [1,1,35,35,224,224,-240,-140-140*ER(-7),-140+140*ER(-7),0],
  [1,1,35,35,224,224,-240,-140+140*ER(-7),-140-140*ER(-7),0],
  [1,1,21,21,0,0,12,84,84,-224],
  [1,-1,-5*ER(17),5*ER(17),-64,64,0,0,0,0],
  [1,-1,5*ER(17),-5*ER(17),-64,64,0,0,0,0],
  [1,1,7,7,0,0,96,-56,-56,0],
  [1,1,-14,-14,35,35,12,14,14,-84],
  [1,1,0,0,-21,-21,-30,0,0,70],
  [1,-1,0,0,21,-21,0,0,0,0]]]];

MULTFREEINFO.("Ru"):= ["$Ru$",
##
[[1,5,6],"${^2F_4(2)^{\\prime}}.2$",
 [[1,1755,2304],
  [1,-65,64],
  [1,15,-16]]],
##
[[1,4,5,6,7],"${^2F_4(2)^{\\prime}} \\leq {^2F_4(2)^{\\prime}}.2$",
 [[1,1,2304,2304,3510],
  [1,-1,144,-144,0],
  [1,1,64,64,-130],
  [1,1,-16,-16,30],
  [1,-1,-16,16,0]]],
##
[[1,6,8,14,15,16,21,23,25,32],"$(2^2 \\times Sz(8)):3$",
 [[1,455,3640,5824,29120,29120,58240,87360,87360,116480],
  [1,-9,392,-208,816,352,-224,-1728,1056,-448],
  [1,39,-104,64,192,256,-512,192,384,-512],
  [1,-9,72,192,256,-288,-64,192,-224,-128],
  [1,23-2*ER(6),16-14*ER(6),-92+24*ER(6),68+28*ER(6),
  -64+76*ER(6),208+148*ER(6),216-84*ER(6),-192-72*ER(6),-184-104*ER(6)],
  [1,23+2*ER(6),16+14*ER(6),-92-24*ER(6),68-28*ER(6),
  -64-76*ER(6),208-148*ER(6),216+84*ER(6),-192+72*ER(6),-184+104*ER(6)],
  [1,-25,-40,-16,-80,-160,160,0,480,-320],
  [1,23,40,64,-256,32,64,-192,96,128],
  [1,-1,-64,-16,112,-64,-32,-288,-96,448],
  [1,-22,20,-16,-56,167,-116,153,-159,28]]]];

MULTFREEINFO.("Suz"):= ["$Suz$",
##
[[1,4,5],"$G_2(4)$",
 [[1,416,1365],
  [1,20,-21],
  [1,-16,15]]],
##
[[1,3,4,9,15],"$3.U_4(3):2$",
 [[1,280,486,8505,13608],
  [1,80,-54,405,-432],
  [1,-28,90,189,-252],
  [1,20,18,-75,36],
  [1,-8,-10,9,8]]],
##
[[1,2,3,4,9,10,11,15],"$3.U_4(3) \\leq 3.U_4(3):2$",
 [[1,1,486,486,560,8505,8505,27216],
  [1,-1,162,-162,0,-945,945,0],
  [1,1,-54,-54,160,405,405,-864],
  [1,1,90,90,-56,189,189,-504],
  [1,1,18,18,40,-75,-75,72],
  [1,-1,18,-18,0,63,-63,0],
  [1,-1,-18,18,0,-45,45,0],
  [1,1,-10,-10,-16,9,9,16]]],
##
[[1,2,3,9,11,12],"$U_5(2)$",
 [[1,891,1980,2816,6336,20736],
  [1,243,-180,512,-576,0],
  [1,-99,330,176,-264,-144],
  [1,33,30,8,96,-168],
  [1,-27,-30,32,24,0],
  [1,9,6,-40,-48,72]]],
##
[[1,2,4,6,9,12,16,17,27],"$2^{1+6}_-.U_4(2)$",
 [[1,54,360,1728,5120,9216,17280,46080,55296],
  [1,-27,90,432,800,-1152,-2160,-1440,3456],
  [1,21,30,276,-160,768,120,-1440,384],
  [1,3,-60,132,200,48,-60,360,-624],
  [1,15,48,12,128,-144,276,-96,-240],
  [1,-9,24,-36,80,144,-108,48,-144],
  [1,-11,10,48,-80,-64,80,80,-64],
  [1,9,6,0,-64,0,-144,192,0],
  [1,0,-12,-18,8,-9,36,-96,90]]],
##
[[1,3,4,5,9,11,12,15,17,27,28,30,33],"$2^{4+6}:3A_6$",
 [[1,60,480,1536,1920,6144,6144,20480,23040,23040,46080,92160,184320],
  [1,-15,30,336,120,1104,-96,-1120,-2160,-360,2880,-5040,4320],
  [1,27,84,216,336,-192,864,1472,72,864,-1440,-2880,576],
  [1,15,-60,-156,300,96,1104,-1120,-180,-720,720,1440,-1440],
  [1,21,90,-24,48,216,-96,-112,-360,576,-96,744,-1008],
  [1,-15,30,-96,120,96,-96,320,0,-360,0,0,0],
  [1,-3,18,24,-96,264,96,-16,360,-144,-288,-72,-144],
  [1,7,-36,116,76,48,-96,112,172,-96,240,240,-784],
  [1,15,36,-12,12,-96,-48,-160,252,-144,144,-288,288],
  [1,6,0,6,-42,-24,24,128,-180,-144,9,144,72],
  [1,-9,12,36,12,-48,0,-112,-36,0,-144,144,144],
  [1,-5,0,-16,-20,-24,24,40,40,120,240,-120,-280],
  [1,3,-24,-24,12,24,-24,-40,0,72,-144,-72,216]]]];

MULTFREEINFO.("ON"):= ["$ON$",
##
[[1,2,7,8,11],"$L_3(7).2$",
 [[1,5586,6384,52136,58653],
  [1,196,-106,161,-252],
  [1,-21,111,161,-252],
  [1,42,48,-280,189],
  [1,-56,-64,56,63]]],
##
[[1,2,7,8,10,11,18],"$L_3(7) \\leq L_3(7).2$",
 [[1,1,11172,12768,52136,52136,117306],
  [1,1,392,-212,161,161,-504],
  [1,1,-42,222,161,161,-504],
  [1,1,84,96,-280,-280,378],
  [1,-1,0,0,-343,343,0],
  [1,1,-112,-128,56,56,126],
  [1,-1,0,0,152,-152,0]]],
##
[[1,2,7,9,11],"$L_3(7).2$",
 [[1,5586,6384,52136,58653],
  [1,196,-106,161,-252],
  [1,-21,111,161,-252],
  [1,42,48,-280,189],
  [1,-56,-64,56,63]]],
##
[[1,2,7,9,10,11,18],"$L_3(7) \\leq L_3(7).2$",
 [[1,1,11172,12768,52136,52136,117306],
  [1,1,392,-212,161,161,-504],
  [1,1,-42,222,161,161,-504],
  [1,1,84,96,-280,-280,378],
  [1,-1,0,0,-343,343,0],
  [1,1,-112,-128,56,56,126],
  [1,-1,0,0,152,-152,0]]]];

MULTFREEINFO.("Co3"):= ["$Co_3$",
##
[[1,5],"$McL.2$",
 [[1,275],
  [1,-1]]],
##
[[1,2,4,5],"$McL \\leq McL.2$",
 [[1,1,275,275],
  [1,-1,55,-55],
  [1,-1,-5,5],
  [1,1,-1,-1]]],
##
[[1,2,5,9,15],"$HS$",
 [[1,352,1100,4125,5600],
  [1,-176,440,-825,560],
  [1,76,134,-15,-196],
  [1,-26,20,75,-70],
  [1,4,-10,-15,20]]],
##
[[1,2,4,5,9,13,15,24],"$M_{23}$",
 [[1,253,506,1771,7590,8855,14168,15456],
  [1,55,-286,847,-330,-2695,3080,-672],
  [1,-85,-86,147,870,105,-280,-672],
  [1,1,146,343,-330,455,56,-672],
  [1,10,-61,97,-105,80,-250,228],
  [1,-22,31,21,15,-120,-82,156],
  [1,28,11,1,75,-40,-52,-24],
  [1,-4,-5,-15,-21,24,44,-24]]],
##
[[1,5,13,15,20,31],"$3^5:(2 \\times M_{11})$",
 [[1,495,2673,32076,40095,53460],
  [1,35,741,2268,-1305,-1740],
  [1,-55,123,-324,495,-240],
  [1,35,93,-324,-225,420],
  [1,35,-15,0,207,-228],
  [1,-9,-15,44,-57,36]]],
##
[[1,2,4,5,9,13,15,20,22,24,28,31],"$3^5:M_{11} \\leq 3^5:(2 \\times M_{11})$",
 [[1,1,495,495,2673,2673,32076,32076,40095,40095,53460,53460],
  [1,-1,165,-165,1485,-1485,10692,-10692,4455,-4455,5940,-5940],
  [1,-1,-135,135,345,-345,-108,108,2655,-2655,-3660,3660],
  [1,1,35,35,741,741,2268,2268,-1305,-1305,-1740,-1740],
  [1,-1,15,-15,315,-315,-108,108,-945,945,-360,360],
  [1,1,-55,-55,123,123,-324,-324,495,495,-240,-240],
  [1,1,35,35,93,93,-324,-324,-225,-225,420,420],
  [1,1,35,35,-15,-15,0,0,207,207,-228,-228],
  [1,-1,33,-33,9,-9,-108,108,135,-135,36,-36],
  [1,-1,-27,27,21,-21,-108,108,63,-63,228,-228],
  [1,-1,-3,3,-27,27,108,-108,-81,81,-108,108],
  [1,1,-9,-9,-15,-15,44,44,-57,-57,36,36]]],
##
[[1,5,14,15,20,27,29],"$2.S_6(2)$",
 [[1,630,1920,8960,30240,48384,80640],
  [1,147,-288,1232,1260,2016,-4368],
  [1,-45,120,-40,540,-216,-360],
  [1,75,0,80,180,-576,240],
  [1,3,72,116,-252,72,-12],
  [1,15,0,-100,0,144,-60],
  [1,-18,-33,32,0,-54,72]]]];

MULTFREEINFO.("Co2"):= ["$Co_2$",
##
[[1,4,6],"$U_6(2).2$",
 [[1,891,1408],
  [1,63,-64],
  [1,-9,8]]],
##
[[1,2,4,6,7],"$U_6(2) \\leq U_6(2).2$",
 [[1,1,891,891,2816],
  [1,-1,297,-297,0],
  [1,1,63,63,-128],
  [1,1,-9,-9,16],
  [1,-1,-3,3,0]]],
##
[[1,4,5,6,8,15,17,28,36,39,44],"$U_5(2).2 \\leq U_6(2).2$",
 [[1,176,495,5346,8448,8910,14256,142560,253440,427680,684288],
  [1,176,495,378,-384,630,1008,10080,-11520,30240,-31104],
  [1,-16,15,1026,-768,270,-1296,4320,7680,-4320,-6912],
  [1,176,495,-54,48,-90,-144,-1440,1440,-4320,3888],
  [1,-16,15,378,384,-810,432,4320,-3840,-4320,3456],
  [1,8,-9,378,288,126,504,-1008,576,0,-864],
  [1,8,-9,-54,-288,414,360,576,-576,-1296,864],
  [1,-16,15,-54,-48,-90,144,0,480,0,-432],
  [1,-16,15,26,32,70,-96,-80,-320,80,288],
  [1,8,-9,-54,96,30,-24,192,192,-144,-288],
  [1,8,-9,26,-64,-50,-24,-128,-128,176,192]]],
##
[[1,2,3,4,5,6,7,8,15,16,17,19,21,28,35,36,39,42,44,48],
"$U_5(2) \\leq U_6(2).2$",
 [[1,1,176,176,495,495,5346,5346,8910,8910,14256,14256,16896,142560,
   142560,253440,253440,427680,427680,1368576],
  [1,-1,176,-176,495,-495,1782,-1782,-2970,2970,4752,-4752,0,-47520,47520,
   0,0,142560,-142560,0],
  [1,-1,-16,16,15,-15,1782,-1782,1350,-1350,-432,432,0,-12960,12960,
   -30720,30720,-12960,12960,0],
  [1,1,176,176,495,495,378,378,630,630,1008,1008,-768,10080,10080,
   -11520,-11520,30240,30240,-62208],
  [1,1,-16,-16,15,15,1026,1026,270,270,-1296,-1296,-1536,4320,4320,
   7680,7680,-4320,-4320,-13824],
  [1,1,176,176,495,495,-54,-54,-90,-90,-144,-144,96,-1440,-1440,1440,1440,
   -4320,-4320,7776],
  [1,-1,176,-176,495,-495,-18,18,30,-30,-48,48,0,480,-480,0,0,-1440,1440,0],
  [1,1,-16,-16,15,15,378,378,-810,-810,432,432,768,4320,4320,-3840,-3840,
   -4320,-4320,6912],
  [1,1,8,8,-9,-9,378,378,126,126,504,504,576,-1008,-1008,576,576,0,0,-1728],
  [1,-1,-16,16,15,-15,270,-270,-162,162,-432,432,0,-864,864,1536,-1536,
   -864,864,0],
  [1,1,8,8,-9,-9,-54,-54,414,414,360,360,-576,576,576,-576,-576,
   -1296,-1296,1728],
  [1,-1,-16,16,15,-15,-18,18,350,-350,368,-368,0,-960,960,1280,-1280,
   -960,960,0],
  [1,-1,8,-8,-9,9,270,-270,54,-54,216,-216,0,864,-864,0,0,432,-432,0],
  [1,1,-16,-16,15,15,-54,-54,-90,-90,144,144,-96,0,0,480,480,0,0,-864],
  [1,-1,8,-8,-9,9,-18,18,-138,138,120,-120,0,-192,192,0,0,-432,432,0],
  [1,1,-16,-16,15,15,26,26,70,70,-96,-96,64,-80,-80,-320,-320,80,80,576],
  [1,1,8,8,-9,-9,-54,-54,30,30,-24,-24,192,192,192,192,192,-144,-144,-576],
  [1,-1,-16,16,15,-15,-18,18,-18,18,0,0,0,144,-144,-192,192,144,-144,0],
  [1,1,8,8,-9,-9,26,26,-50,-50,-24,-24,-128,-128,-128,-128,-128,176,176,384],
  [1,-1,8,-8,-9,9,-18,18,54,-54,-72,72,0,0,0,0,0,144,-144,0]]],
##
[[1,4,6,14,17],"$2^{10}:M_{22}:2$",
 [[1,462,2464,21120,22528],
  [1,-21,532,-960,448],
  [1,87,64,120,-272],
  [1,-21,28,120,-128],
  [1,3,-20,-48,64]]],
##
[[1,2,4,6,7,14,17,20],"$2^{10}:M_{22} \\leq 2^{10}:M_{22}:2$",
 [[1,1,924,2464,2464,22528,22528,42240],
  [1,-1,0,1232,-1232,-5632,5632,0],
  [1,1,-42,532,532,448,448,-1920],
  [1,1,174,64,64,-272,-272,240],
  [1,-1,0,182,-182,368,-368,0],
  [1,1,-42,28,28,-128,-128,240],
  [1,1,6,-20,-20,64,64,-96],
  [1,-1,0,-10,10,-16,16,0]]],
##
[[1,2,4,7,14,18],"$McL$",
 [[1,275,2025,7128,15400,22275],
  [1,-165,945,-2376,3080,-1485],
  [1,91,369,504,-56,-909],
  [1,-45,105,24,-280,195],
  [1,19,9,-72,-56,99],
  [1,-5,-15,24,40,-45]]],
##
[[1,4,6,15,17],"$2^{1+8}:S_6(2)$",
 [[1,1008,1260,14336,40320],
  [1,-234,225,1088,-1080],
  [1,108,135,-64,-180],
  [1,18,-27,80,-72],
  [1,-18,9,-64,72]]],
##
[[1,4,6,14,17,27,33],"$HS.2$",
 [[1,3850,4125,44352,61600,132000,231000],
  [1,-14,1365,-2016,7504,-6000,-840],
  [1,490,285,-2016,-560,2640,-840],
  [1,-86,285,576,-416,480,-840],
  [1,178,21,288,-176,-624,312],
  [1,10,-35,64,160,160,-360],
  [1,-30,5,-96,-80,-80,280]]],
##
[[1,2,4,6,7,14,17,18,20,27,33,38],"$HS \\leq HS.2$",
 [[1,1,3850,3850,4125,4125,61600,61600,88704,231000,231000,264000],
  [1,-1,770,-770,2475,-2475,24640,-24640,0,46200,-46200,0],
  [1,1,-14,-14,1365,1365,7504,7504,-4032,-840,-840,-12000],
  [1,1,490,490,285,285,-560,-560,-4032,-840,-840,5280],
  [1,-1,-70,70,675,-675,1120,-1120,0,-4200,4200,0],
  [1,1,-86,-86,285,285,-416,-416,1152,-840,-840,960],
  [1,1,178,178,21,21,-176,-176,576,312,312,-1248],
  [1,-1,-190,190,75,-75,-320,320,0,600,-600,0],
  [1,-1,122,-122,99,-99,-416,416,0,408,-408,0],
  [1,1,10,10,-35,-35,160,160,128,-360,-360,320],
  [1,1,-30,-30,5,5,-80,-80,-192,280,280,-160],
  [1,-1,2,-2,-21,21,64,-64,0,-72,72,0]]]];

MULTFREEINFO.("Fi22"):= ["$Fi_{22}$",
##
[[1,3,7],"$2.U_6(2)$",
 [[1,693,2816],
  [1,63,-64],
  [1,-9,8]]],
##
[[1,3,9],"$O_7(3)$",
 [[1,3159,10920],
  [1,279,-280],
  [1,-9,8]]],
##
[[1,3,9],"$O_7(3)$",
 [[1,3159,10920],
  [1,279,-280],
  [1,-9,8]]],
##
[[1,7,9,13],"$O_8^+(2):S_3$",
 [[1,1575,22400,37800],
  [1,171,-64,-108],
  [1,-9,224,-216],
  [1,-9,-64,72]]],
##
[[1,4,7,8,9,13,15],"$O_8^+(2):3 \\leq O_8^+(2):S_3$",
 [[1,1,1575,1575,22400,22400,75600],
  [1,-1,225,-225,800,-800,0],
  [1,1,171,171,-64,-64,-216],
  [1,-1,-63,63,224,-224,0],
  [1,1,-9,-9,224,224,-432],
  [1,1,-9,-9,-64,-64,144],
  [1,-1,9,-9,-64,64,0]]],
##
[[1,3,7,9,13,14,17],"$O_8^+(2):2 \\leq O_8^+(2):S_3$",
 [[1,2,1575,3150,22400,44800,113400],
  [1,-1,315,-315,2240,-2240,0],
  [1,2,171,342,-64,-128,-324],
  [1,2,-9,-18,224,448,-648],
  [1,2,-9,-18,-64,-128,216],
  [1,-1,-45,45,80,-80,0],
  [1,-1,27,-27,-64,64,0]]],
##
[[1,2,3,5,7,10,11,17],"$2^{10}:M_{22}$",
 [[1,154,1024,3696,4928,11264,42240,78848],
  [1,-77,-320,924,1232,-1408,-5280,4928],
  [1,49,-176,546,-532,1184,-960,-112],
  [1,-35,160,294,-364,-400,120,224],
  [1,37,88,186,248,32,120,-712],
  [1,13,-32,6,-28,-112,120,32],
  [1,-17,-20,24,32,32,120,-172],
  [1,1,16,-30,-4,32,-96,80]]],
##
[[1,3,5,7,9,10,13,17,25,28],"$2^6:S_6(2)$",
 [[1,135,1260,2304,8640,10080,45360,143360,241920,241920],
  [1,-15,210,624,-960,1680,1260,8960,-1680,-10080],
  [1,-27,126,-288,216,1008,-2268,-1792,6048,-3024],
  [1,57,246,120,840,96,1368,-1408,120,-1440],
  [1,3,-60,192,192,312,-576,-256,-960,1152],
  [1,21,30,-96,-168,240,180,-256,-672,720],
  [1,27,36,0,0,-144,-432,512,0,0],
  [1,-15,66,48,-96,-48,-36,-256,48,288],
  [1,-9,0,-36,72,0,0,224,-252,0],
  [1,3,-24,12,-24,-12,72,-112,228,-144]]],
##
[[1,4,5,9,10,26,31,32,39,45,53],"${^2F_4(2)^{\\prime}}$",
 [[1,1755,11700,14976,83200,83200,140400,187200,374400,449280,2246400],
  [1,-405,900,-576,-3200,-3200,-10800,14400,-14400,17280,0],
  [1,-189,1980,-576,5440,5440,4320,-7200,-14400,13824,-8640],
  [1,171,612,-864,832,832,1008,3456,3744,-576,-9216],
  [1,99,540,576,-320,-320,-1440,-1440,2880,2304,-2880],
  [1,75,-60,192,-128,-128,624,384,-576,384,-768],
  [1,27,36,-144,-608,256,0,-288,-144,0,864],
  [1,27,36,-144,256,-608,0,-288,-144,0,864],
  [1,-21,132,96,64,64,-48,192,-288,-960,768],
  [1,27,-108,0,256,256,-432,0,0,0,0],
  [1,-45,-36,0,-32,-32,144,0,288,288,-576]]]];

MULTFREEINFO.("HN"):= ["$HN$",
##
[[1,2,3,4,5,8,10,11,12,18,20,23],"$A_{12}$",
 [[1,462,2520,2520,10395,16632,30800,69300,166320,166320,311850,362880],
  [1,-198,360*ER(5),-360*ER(5),2475,792,4400,-9900,-7920*ER(5),7920*ER(5),
   -14850,17280],
  [1,-198,-360*ER(5),360*ER(5),2475,792,4400,-9900,7920*ER(5),-7920*ER(5),
   -14850,17280],
  [1,132,-540,-540,1485,-1188,1100,4950,-5940,-5940,0,6480],
  [1,12,120,120,495,1332,-2200,300,-1080,-1080,-900,2880],
  [1,82,240,240,515,-88,400,900,640,640,-1650,-1920],
  [1,62,-120,-120,155,632,400,-300,80,80,1050,-1920],
  [1,-48,60*ER(5),-60*ER(5),225,-108,-100,-150,180*ER(5),-180*ER(5),900,-720],
  [1,-48,-60*ER(5),60*ER(5),225,-108,-100,-150,-180*ER(5),180*ER(5),900,-720],
  [1,12,30,30,-45,-18,50,-150,-270,-270,450,180],
  [1,-18,0,0,-45,72,80,180,0,0,-270,0],
  [1,12,-20,-20,5,-68,-100,-50,180,180,-200,80]]],
[[1,2,3,4,5,8,9,10,11,12,18,20,23,24,32,39,40,41,47],"$A_{11} \\leq A_{12}$",
 [[1,11,2772,2772,16632,20790,30240,30240,83160,99792,103950,362880,369600,
   831600,1247400,1995840,1995840,2494800,3991680],
  [1,11,-1188,-1188,792,4950,-4320*ER(5),4320*ER(5),3960,4752,24750,17280,
   52800,-118800,-59400,95040*ER(5),-95040*ER(5),-118800,190080],
  [1,11,-1188,-1188,792,4950,4320*ER(5),-4320*ER(5),3960,4752,24750,17280,
   52800,-118800,-59400,-95040*ER(5),95040*ER(5),-118800,190080],
  [1,11,792,792,-1188,2970,-6480,-6480,-5940,-7128,14850,6480,13200,59400,0,
   -71280,-71280,0,71280],
  [1,11,72,72,1332,990,1440,1440,6660,7992,4950,2880,-26400,3600,-3600,
   -12960,-12960,-7200,31680],
  [1,11,492,492,-88,1030,2880,2880,-440,-528,5150,-1920,4800,10800,-6600,
   7680,7680,-13200,-21120],
  [1,-1,-168,168,1428,1050,0,0,2100,-3528,-1050,-10080,0,0,25200,0,0,
   -25200,10080],
  [1,11,372,372,632,310,-1440,-1440,3160,3792,1550,-1920,4800,-3600,4200,
   960,960,8400,-21120],
  [1,11,-288,-288,-108,450,-720*ER(5),720*ER(5),-540,-648,2250,-720,-1200,
   -1800,3600,-2160*ER(5),2160*ER(5),7200,-7920],
  [1,11,-288,-288,-108,450,720*ER(5),-720*ER(5),-540,-648,2250,-720,-1200,
   -1800,3600,2160*ER(5),-2160*ER(5),7200,-7920],
  [1,11,72,72,-18,-90,360,360,-90,-108,-450,180,600,-1800,1800,-3240,-3240,
   3600,1980],
  [1,11,-108,-108,72,-90,0,0,360,432,-450,0,960,2160,-1080,0,0,-2160,0],
  [1,11,72,72,-68,10,-240,-240,-340,-408,50,80,-1200,-600,-800,2160,2160,
   -1600,880],
  [1,-1,-72,72,180,90,0,0,468,-648,-90,1440,0,0,-720,0,0,720,-1440],
  [1,-1,72,-72,68,250,0,0,100,-168,-250,-480,0,0,-1200,0,0,1200,480],
  [1,-1,12,-12,208,-50,0,0,-400,192,50,320,0,0,400,0,0,-400,-320],
  [1,-1,36,-36,-144,-18,0,0,144,0,18,576,0,0,1008,0,0,-1008,-576],
  [1,-1,-48,48,-102,150,0,0,-150,252,-150,-180,0,0,0,0,0,0,180],
  [1,-1,-8,8,-12,-150,0,0,100,-88,150,-480,0,0,-400,0,0,400,480]]],
##
[[1,5,8,9,10,17,18,20,24],"$2.HS.2$",
 [[1,1408,2200,5775,35200,123200,277200,354816,739200],
  [1,208,-50,525,2200,-2800,-6300,2016,4200],
  [1,-112,300,75,1000,-2200,3600,-864,-1800],
  [1,208,100,-525,1000,1400,0,2016,-4200],
  [1,128,200,375,0,1600,0,-2304,0],
  [1,-47,-50,0,250,350,0,-504,0],
  [1,28,-50,75,-50,-100,450,396,-750],
  [1,-32,40,15,-80,80,-360,576,-240],
  [1,16,4,-45,-56,-136,0,-288,504]]],
##
[[1,4,5,9,11,12,18,19,21,22,25,26,32,34,35,36,37,41,49],"$U_3(8).3_1$",
 [[1,1539,14364,25536,25536,25536,68096,131328,229824,229824,612864,612864,
   612864,612864,689472,787968,787968,5515776,5515776],
  [1,-81,3024,-1344,-4704,-1344,7616,1728,-12096,-12096,-12096,-12096,28224,
   28224,54432,-67392,36288,-108864,72576],
  [1,-261,1764,336,2436,336,896,5328,3024,3024,-25536,-25536,-8736,-8736,
   15372,17568,24768,22176,-28224],
  [1,99,924,-1344,2016,-1344,896,-3072,1344,1344,8064,8064,8064,8064,14112,
   10368,-1152,-8064,-48384],
  [1,99,684,-624,-144,-624,-64,1728,-216+1800*ER(5),-216-1800*ER(5),
   3744-2400*ER(5),3744+2400*ER(5),-4416,-4416,-1008,-1152,4608,-2304,576],
  [1,99,684,-624,-144,-624,-64,1728,-216-1800*ER(5),-216+1800*ER(5),
   3744+2400*ER(5),3744-2400*ER(5),-4416,-4416,-1008,-1152,4608,-2304,576],
  [1,9,414,336,366,336,716,-72,-216,-216,204,204,-276,-276,-558,1908,
   -1692,-7524,6336],
  [1,19,364,336,-644,336,-224,-1072,-336,-336,224,224,-896,-896,1652,
   128,-672,5376,-3584],
  [1,-81,-36,36,-144,36,-424,-72,-486-450*ER(5),-486+450*ER(5),
   324-900*ER(5),324+900*ER(5),504,504,-648,1728,1728,-3024,216],
  [1,-81,-36,36,-144,36,-424,-72,-486+450*ER(5),-486-450*ER(5),
   324+900*ER(5),324-900*ER(5),504,504,-648,1728,1728,-3024,216],
  [1,-45,-180,144+48*ER(-19),48,144-48*ER(-19),320,0,288,288,576,576,
   -576-384*ER(-19),-576+384*ER(-19),720,-576,576,-576,-1152],
  [1,-45,-180,144-48*ER(-19),48,144+48*ER(-19),320,0,288,288,576,576,
   -576+384*ER(-19),-576-384*ER(-19),720,-576,576,-576,-1152],
  [1,19,44,96,176,96,-704,128,384,384,64,64,64,64,592,-832,-192,-1344,896],
  [1,54,9,126,126,126,116,153,-351,-351,54,54,549,549,-1053,-567,918,1971,
   -2484],
  [1,54,-81,-54+75*ER(-10),-84,-54-75*ER(-10),56,-297,189,189,-216,-216,
   -81+225*ER(-10),-81-225*ER(-10),27,513,378,-1269,1026],
  [1,54,-81,-54-75*ER(-10),-84,-54+75*ER(-10),56,-297,189,189,-216,-216,
   -81-225*ER(-10),-81+225*ER(-10),27,513,378,-1269,1026],
  [1,-26,109,-24,-194,-24,136,353,609,609,-106,-106,559,559,-733,-127,
   -342,-129,-1124],
  [1,9,-66,-24,-54,-24,-4,528,-336,-336,-36,-36,-36,-36,702,468,
   -972,396,-144],
  [1,-26,29,-84,86,-84,16,-247,-111,-111,-146,-146,-101,-101,-173,
   -367,-222,1191,596]]]];

MULTFREEINFO.("Ly"):= ["$Ly$",
##
[[1,4,11,12,14],"$G_2(5)$",
 [[1,19530,968750,2034375,5812500],
  [1,549,11375,3075,-15000],
  [1,234,-70,-1755,1590],
  [1,49,-625,1575,-1000],
  [1,-126,350,-525,300]]],
##
[[1,4,11,12,15],"$3.McL.2$",
 [[1,15400,534600,1871100,7185024],
  [1,-325,10125,-2025,-7776],
  [1,-10,-60,2805,-2736],
  [1,175,125,-525,224],
  [1,-100,-150,-525,774]]],
##
[[1,4,10,11,12,13,15,16],"$3.McL \\leq 3.McL.2$",
 [[1,1,30800,534600,534600,3742200,7185024,7185024],
  [1,1,-650,10125,10125,-4050,-7776,-7776],
  [1,-1,0,1800,-1800,0,3024,-3024],
  [1,1,-20,-60,-60,5610,-2736,-2736],
  [1,1,350,125,125,-1050,224,224],
  [1,-1,0,-675,675,0,3024,-3024],
  [1,1,-200,-150,-150,-1050,774,774],
  [1,-1,0,0,0,0,-2376,2376]]]];

MULTFREEINFO.("Th"):= ["$Th$",
##
[[1,3,7,8,19,21,25,32,37,39,41],"${^3D_4(2)}.3$",
 [[1,17199,45864,179712,1304576,2201472,5031936,8128512,8805888,
   11741184,105670656],
  [1,-2457,6552,0,46592,0,-179712,-290304,0,419328,0],
  [1,459,2340,-7776,-7840,-34992,76896,12960,101088,90144,-233280],
  [1,1323,2772,-4320,16352,15120,6048,72576,-75600,56448,-90720],
  [1,-441,504,-288,4256,4032,7056,-6048,1008,-7056,-3024],
  [1,-117,612,1440,-928,-5040,3168,-864,-7200,288,8640],
  [1,403,492,960,112,2640,-1392,-144,6000,-2032,-7040],
  [1,99,-36,-288,-2224,1872,2736,-3888,-3312,1584,3456],
  [1,-117,180,-288,-928,144,-2016,1728,1008,-576,864],
  [1,99,-36,-288,800,-1152,-288,-864,-288,-1440,3456],
  [1,-45,-180,288,224,288,288,864,288,1440,-3456]]],
##
[[1,8,17,18,25,32,37,38,39,42,46],"$2^5.L_5(2)$",
 [[1,248,59520,2064384,2064384,2539520,6666240,35553280,63995904,63995904,
   106659840],
  [1,59,2820,-31248,-31248,44720,-1680,202720,-16128,174384,-344400],
  [1,-31,930,-1008+3780*ER(-6),-1008-3780*ER(-6),-4960,-13020,8680,
   -31248,15624,26040],
  [1,-31,930,-1008-3780*ER(-6),-1008+3780*ER(-6),-4960,-13020,8680,
   -31248,15624,26040],
  [1,39,1000,2352,2352,5680,5600,-5600,-22848,-3696,15120],
  [1,23,120,1584,1584,1520,-8160,-7520,16704,5904,-11760],
  [1,-13,12,-144,-144,1520,-1680,6880,4608,-17424,6384],
  [1,14,-150,1557,1557,-1720,750,9850,-4383,-171,-7305],
  [1,23,120,-1440,-1440,-1504,912,-1472,4608,-3168,3360],
  [1,-17,160,224,224,-480,1680,-2240,3584,2464,-5600],
  [1,-1,-240,-288,-288,800,-240,-2240,-4608,3744,3360]]]];

MULTFREEINFO.("Fi23"):= ["$Fi_{23}$",
##
[[1,2,6],"$2.Fi_{22}$",
 [[1,3510,28160],
  [1,351,-352],
  [1,-9,8]]],
##
[[1,6,8],"$O_8^+(3).3.2$",
 [[1,28431,109200],
  [1,279,-280],
  [1,-81,80]]],
##
[[1,5,6,8,9],"$O_8^+(3).3 \\leq O_8^+(3).3.2$",
 [[1,1,28431,28431,218400],
  [1,-1,-351,351,0],
  [1,1,279,279,-560],
  [1,1,-81,-81,160],
  [1,-1,81,-81,0]]],
##
[[1,2,6,8,10],"$O_8^+(3).2_2 \\leq O_8^+(3).3.2$",
 [[1,2,28431,56862,327600],
  [1,-1,3159,-3159,0],
  [1,2,279,558,-840],
  [1,2,-81,-162,240],
  [1,-1,-9,9,0]]],
##
[[1,2,3,6,7,8,10,14,20,24,38,40,42],"$S_8(2)$",
 [[1,2295,13056,24192,107100,261120,1285200,2203200,3046400,3290112,
   12337920,30844800,32901120],
  [1,-135,3984,-3024,22050,1920,94500,-129600,324800,-193536,498960,
   226800,-846720],
  [1,-459,-1632,1512,10710,11424,-64260,55080,-38080,-102816,308448,
   -385560,205632],
  [1,225,1464,1008,5670,-3840,10080,42120,32480,44352,-7560,-105840,-20160],
  [1,189,-768,-1728,4230,2784,-9180,-22680,-12160,42336,36288,-6480,-32832],
  [1,315,384,-1152,180,7680,-13680,17280,5120,-4608,-17280,51840,-46080],
  [1,-135,816,144,2250,1920,-4500,-10800,8000,-3456,-23760,-10800,40320],
  [1,189,-48,792,630,2784,5220,-1080,-4960,-864,-432,-1080,-1152],
  [1,-9,-372,252,1260,-1176,-1260,1080,-280,-2016,-5292,11340,-3528],
  [1,21,240,-216,366,-576,900,504,-3424,-1344,1008,3096,-576],
  [1,-63,-48,-72,18,336,684,432,-64,144,-432,-648,-288],
  [1,-9,60,144,-144,-96,-720,-216,-64,576,1188,1296,-2016],
  [1,45,-48,-72,-90,-96,36,-216,800,-288,-432,-1944,2304]]],
##
[[1,2,3,6,7,10,13,14,19,20,24,26,38,41,42,60],"$2^{11}.M_{23}$",
 [[1,506,23552,28336,113344,129536,971520,1036288,1813504,4533760,
   8290304,21762048,31088640,31653888,36270080,58032128],
  [1,209,-208,7546,5236,29744,116160,85888,250096,43120,-377344,-990528,
   865920,1462272,-985600,-512512],
  [1,-187,-2080,4774,10780,-10648,-62040,44704,61600,-206360,154880,
   -192192,770880,-473088,234080,-335104],
  [1,149,1112,3346,4816,9584,35160,-8192,62776,-7280,25856,67872,-98880,
   -150528,56000,-1792],
  [1,-43,1664,1246,-4844,-3088,2760,23392,3136,-2240,2816,61824,27840,
   -86016,-209440,180992],
  [1,41,-688,826,-2996,3536,-6960,9088,784,-7280,18944,49728,-21120,
   43008,-4480,-82432],
  [1,-85,-40,1204,784,-2080,-6960,-992,7336,7840,-16480,13440,-12480,6720,
   5600,-3808],
  [1,77,464,646,2116,-568,2760,4192,-6704,17560,8576,5664,13440,-5376,
   -3040,-39808],
  [1,-61,-640,364,1456,-64,-480,-512,-896,-2240,16640,-10752,-15360,
   10752,-17920,19712],
  [1,23,-580,124,-620,-1108,2760,5704,100,-260,-3520,-11832,-15720,-3648,
   22880,5696],
  [1,53,-208,526,-380,728,-840,-1472,-2000,1000,-2944,-5856,4800,
   -5376,320,11648],
  [1,11,422,-104,124,476,-2100,1468,814,1000,1844,-9132,-7800,168,4940,7868],
  [1,-31,176,178,-404,-136,816,-560,-656,-584,1664,-2112,480,1536,2576,-2944],
  [1,-25,-28,-32,304,368,168,640,-932,-944,-3232,2208,1056,-1344,800,992],
  [1,29,80,22,196,-280,168,-224,-176,-2888,-640,2208,-1536,3840,-928,128],
  [1,2,-55,-86,-74,-37,-75,-197,499,1000,575,264,975,-939,-955,-898]]]];

MULTFREEINFO.("Co1"):= ["$Co_1$",
##
[[1,3,6,10],"$Co_2$",
 [[1,4600,46575,47104],
  [1,1000,-2025,1024],
  [1,76,243,-320],
  [1,-20,-45,64]]],
##
[[1,4,7,16,20],"$3.Suz.2$",
 [[1,5346,22880,405405,1111968],
  [1,1026,-2080,12285,-11232],
  [1,378,800,-315,-864],
  [1,-54,80,405,-432],
  [1,26,-80,-315,368]]],
##
[[1,2,4,7,11,16,20,22],"$3.Suz \\leq 3.Suz.2$",
 [[1,1,5346,5346,45760,405405,405405,2223936],
  [1,-1,-1782,1782,0,45045,-45045,0],
  [1,1,1026,1026,-4160,12285,12285,-22464],
  [1,1,378,378,1600,-315,-315,-1728],
  [1,-1,-270,270,0,-819,819,0],
  [1,1,-54,-54,160,405,405,-864],
  [1,1,26,26,-160,-315,-315,736],
  [1,-1,18,-18,0,45,-45,0]]],
##
[[1,6,10,16,25,32],"$2^{11}:M_{24}$",
 [[1,3542,48576,1457280,2637824,4145152],
  [1,539,2244,15840,-17920,-704],
  [1,-133,1956,-4320,3584,-1088],
  [1,167,-24,-720,2624,-2048],
  [1,-49,-24,1224,896,-2048],
  [1,-1,-24,-360,-640,1024]]],
##
[[1,3,6,10,14,26,32],"$Co_3$",
 [[1,11178,37950,257600,1536975,2608200,3934656],
  [1,4698,-1650,56000,111375,-113400,-57024],
  [1,1506,198,4256,-14289,13608,-5280],
  [1,258,1830,-1120,1455,-2520,96],
  [1,306,-330,-1120,495,-2520,3168],
  [1,-54,30,320,-945,-1080,1728],
  [1,-6,-18,-64,399,648,-960]]],
##
[[1,3,6,7,10,12,16,29,32,37,46],"$2^{1+8}_+.O_8^+(2)$",
 [[1,270,12600,34560,60480,491520,573440,2419200,4838400,12386304,25804800],
  [1,-135,3150,8640,-7560,-61440,89600,-302400,302400,774144,-806400],
  [1,75,1680,240,4788,-7680,14336,38640,55440,-53760,-53760],
  [1,63,180,3096,-1620,14592,10400,26280,-30240,39168,-61920],
  [1,-45,840,-720,-1260,7680,8960,-15120,5040,-32256,26880],
  [1,-27,-270,1296,1080,-2688,3200,-4320,-8640,-6912,17280],
  [1,45,450,360,1080,1920,-2560,-3600,0,2304,0],
  [1,-35,250,240,-360,-640,-800,800,0,-256,800],
  [1,21,114,-192,-72,-768,512,192,-2880,1536,1536],
  [1,15,-60,120,-180,0,-160,-120,1440,-1536,480],
  [1,-9,-36,-72,108,192,32,72,0,576,-864]]]];

MULTFREEINFO.("J4"):= ["$J_4$",
##
[[1,8,11,14,19,20,21],"$2^{11}:M_{24}$",
 [[1,15180,28336,3400320,32643072,54405120,82575360],
  [1,825,1166,14520,19008,10560,-46080],
  [1,517,-990,-1496,32560,-23936,-6656],
  [1,-253,0,7084,0,-28336,21504],
  [1,66-17*ER(33),99+19*ER(33),-1166-154*ER(33),-1056+992*ER(33),
   -2552-328*ER(33),4608-512*ER(33)],
  [1,66+17*ER(33),99-19*ER(33),-1166+154*ER(33),-1056-992*ER(33),
   -2552+328*ER(33),4608+512*ER(33)],
  [1,-55,-66,440,0,3520,-3840]]],
##
[[1,8,11,14,19,20,21,29,30,45,51],"$2^{11}:M_{23} \\leq 2^{11}:M_{24}$",
 [[1,23,121440,242880,680064,81607680,82575360,130572288,652861440,
   1305722880,1899233280],
  [1,23,6600,13200,27984,348480,-46080,76032,380160,253440,-1059840],
  [1,23,4136,8272,-23760,-35904,-6656,130240,651200,-574464,-153088],
  [1,23,-2024,-4048,0,170016,21504,0,0,-680064,494592],
  [1,23,528-136*ER(33),1056-272*ER(33),2376+456*ER(33),
   -27984-3696*ER(33),4608-512*ER(33),-4224+3968*ER(33),
   -21120+19840*ER(33),-61248-7872*ER(33),105984-11776*ER(33)],
  [1,23,528+136*ER(33),1056+272*ER(33),2376-456*ER(33),
   -27984+3696*ER(33),4608+512*ER(33),-4224-3968*ER(33),
   -21120-19840*ER(33),-61248+7872*ER(33),105984+11776*ER(33)],
  [1,23,-440,-880,-1584,10560,-3840,0,0,84480,-88320],
  [1,-1,528,-528,0,0,-12288,16896,-16896,0,12288],
  [1,-1,352,-352,0,0,21504,0,0,0,-21504],
  [1,-1,-352,352,0,0,1792,9856,-9856,0,-1792],
  [1,-1,0,0,0,0,-3840,-10560,10560,0,3840]]]];

MULTFREEINFO.("F3+"):= ["$F_{3+}$",
##
[[1,3,4],"$Fi_{23}$",
 [[1,31671,275264],
  [1,351,-352],
  [1,-81,80]]],
##
[[1,2,3,4,5,8,11,13,16,20,24,26,27,29,38,41,45],"$O_{10}^-(2)$",
 [[1,25245,104448,1570800,12773376,45957120,67858560,107233280,193881600,
   263208960,579059712,1085736960,5147197440,5428684800,7238246400,
   12634030080,17371791360],
  [1,-5049,-13056,157080,798336,2010624,-3392928,-1340416,4847040,-3290112,
   -18095616,27143424,80424960,-67858560,-90478080,-39481344,108573696],
  [1,1755,16752,145740,145152,-145920,1955016,4102784,1639440,-1983744,
   2370816,16284240,-10730496,30119040,-7197120,-44706816,7983360],
  [1,3195,5664,27300,-266112,798720,-302400,546560,2311200,2419200,
   2161152,-393120,-5376000,5443200,-22377600,21288960,-6289920],
  [1,-1485,8544,56100,-57024,337920,178200,1168640,-1782000,1468800,
   -3269376,1568160,5913600,1425600,1900800,7050240,-15966720],
  [1,2079,-2256,26400,-14256,489984,28512,-256960,-712800,-1237248,
   2318976,1012176,3480576,-498960,-665280,2073600,-6044544],
  [1,819,1776,10020,55296,26304,129816,-75520,179280,262656,161856,
   20304,561408,-544320,665280,-587520,-867456],
  [1,-189,-2688,19380,16848,-37056,-132840,-65152,6480,69120,22464,
   456192,-652800,-149040,501120,456192,-508032],
  [1,-45,3072,14340,-1728,-30720,26136,111104,-2160,-100224,66816,
   -120960,-316416,-855360,17280,635904,552960],
  [1,-639,-708,2730,-16632,34944,15120,-6832,57780,-30240,-67536,
   -9828,-84000,-68040,279720,-66528,-39312],
  [1,171,912,1596,-6912,-6528,-21816,-2944,23760,-6912,1152,-34128,
   167424,124416,63936,-152064,-152064],
  [1,279,-816,3000,-5616,384,4752,2240,-21600,24192,14976,-54864,36096,
   19440,-60480,-172800,210816],
  [1,-315,588,1110,4752,10320,-4320,-10720,-19980,8640,-2736,-25380,
   -58080,77760,-50760,-82080,151200],
  [1,387,48,-780,3456,12480,-7560,7424,3024,-6912,-17856,-5616,-74496,
   -15552,63936,-6912,44928],
  [1,-99,-276,30,3456,-1776,-1728,7424,5940,-6912,1584,-20196,36960,
   19440,-11880,16416,-48384],
  [1,63,48,192,-432,-3072,6048,-8128,-864,-6912,-12672,9936,-12288,
   19440,-29376,55296,-17280],
  [1,-45,48,-780,-1728,-480,-1080,2240,-2160,8640,12384,15120,-1920,
   -38880,17280,-17280,8640]]],
##
[[1,3,4,11,12,16,17,19,22,24,29,30,32,39,40,44,45,59],"$3^7.O_7(3)$",
 [[1,1120,49140,275562,816480,21228480,57316896,62178597,286584480,
   429876720,2901667860,5158520640,6964002864,15475561920,
   9183300480,9183300480,23213342880,52230021480],
  [1,-40,3900,31266,-29160,56160,1617408,2814669,-463320,4801680, 32411340,
   -30326400,77787216,40940640,-40940640,-40940640,-37528920,-10235160],
  [1,392,7644,20034,76104,812448,471744,85293,5798520,2240784,15125292,
   28304640,-9552816,-19105632,-15326496,-15326496,11144952,-4776408],
  [1,200,2220,2322,13320,64800,-53568,73629,104760,343440,-811620,
   -1244160,1271376,-2838240,349920,349920,4908600,-2536920],
  [1,224,2772,3402,18144,108864,54432,-37179,272160,81648,-591948,
   -326592,-244944,3592512,839808,839808,-2776032,-1837080],
  [1,-40,300,3186,-360,-1440,-41472,190269,-117720,265680,43740,777600,
   104976,-1049760,1049760,1049760,-2536920,262440],
  [1,32,-636,3834,3744,-29952,121824,114453,21600,-364176,-144828,
   388800,128304,373248,186624,186624,1220832,-2210328],
  [1,152,1224,1134,6264,6048,-20736,-16767,3240,-241056,190512,-155520,
   303264,-1065312,69984,69984,-849528,1697112],
  [1,-64,468,-1782,1728,-22464,33696,9477,67392,50544,-63180,-202176,
   -151632,-202176,0,0,-202176,682344],
  [1,-40,732,2754,-3816,5472,20736,-8019,-7128,11664,164268,-217728,
   -221616,-116640,116640,116640,106920,29160],
  [1,104,588,-270,936,-3168,5184,3645,-53352,22032,4860,62208,-128304,
   116640,-116640,-116640,126360,75816],
  [1,56,-84,882,504,-14112,-24192,3645,35784,3024,74844,-72576,-81648,
   163296,23328,23328,68040,-204120],
  [1,14,-294,1134,882,-5544,9072,-16767,-7938,27216,-44226,68040,102060,
   -81648,2916,2916,-78246,20412],
  [1,-28,0,-378,756,0,0,-3159,-9828,0,58968,0,0,0,-112752,213840,29484,
   -176904],
  [1,-28,0,-378,756,0,0,-3159,-9828,0,58968,0,0,0,213840,-112752,
   29484,-176904],
  [1,44,36,-486,-1188,216,2592,-2187,10692,-1944,-2916,19440,58320,
   -33048,46656,46656,-32076,-110808],
  [1,-40,300,162,-360,-1440,-5184,-243,3240,-6480,-46980,51840,50544,
   38880,-38880,-38880,3240,-9720],
  [1,0,-140,42,0,2240,-224,2917,0,-1680,-10220,-20160,-27216,2240,
   -23040,-23040,0,98280]]]];

MULTFREEINFO.("B"):= ["$B$",
##
[[1,3,5,13,15],"$2.{}^2E_6(2).2$",
 [[1,3968055,23113728,2370830336,11174042880],
  [1,228735,-709632,14483456,-14002560],
  [1,50895,133056,124928,-308880],
  [1,1935,-4032,-31744,33840],
  [1,-945,1728,14336,-15120]]],
##
[[1,2,3,5,7,13,15,17],"$2.{}^2E_6(2) \\leq 2.{}^2E_6(2).2$",
 [[1,1,3968055,3968055,46227456,2370830336,2370830336,22348085760],
  [1,-1,566865,-566865,0,84672512,-84672512,0],
  [1,1,228735,228735,-1419264,14483456,14483456,-28005120],
  [1,1,50895,50895,266112,124928,124928,-617760],
  [1,-1,28665,-28665,0,-114688,114688,0],
  [1,1,1935,1935,-8064,-31744,-31744,67680],
  [1,1,-945,-945,3456,14336,14336,-30240],
  [1,-1,-135,135,0,512,-512,0]]],
##
[[1,3,5,8,13,15,28,30,37,40],"$2^{1+22}.Co_2$",
[[1,93150,7286400,262310400,4196966400,9646899200,470060236800,
  537211699200,4000762036224,6685301145600],
 [1,-2025,772200,-5702400,42768000,290816000,-2714342400,5474304000,
  8833204224,-11921817600],
 [1,10287,215424,3777840,25974432,35514368,607533696,100362240,
  -42467328,-730920960],
 [1,-2025,99000,356400,-5702400,8806400,0,45619200,-191102976,141926400],
 [1,495,48960,-334800,1631520,2769920,-9636480,-12441600,-2359296,20321280],
 [1,3375,28800,356400,1015200,-870400,-6652800,4147200,-14155776,16128000],
 [1,1095,1560,7200,-113280,81920,107520,-921600,2555904,-1720320],
 [1,-425,9400,-3600,-57600,-115200,358400,-76800,1409024,-1523200],
 [1,135,-360,-12960,17280,-40960,138240,414720,-884736,368640],
 [1,-153,-936,8640,1152,32768,-129024,-207360,294912,0]]],
##
[[1,2,3,5,7,8,9,12,13,15,17,23,27,30,32,40,41,54,63,68,77,81,83],"$Fi_{23}$",
 [[1,412896,86316516,195747435,8537488128,23478092352,33816182400,
   113778447552,160533964800,504245392560,1044084577536,1152560897280,
   1584771233760,5282570779200,7888639030272,12678169870080,
   21514470082560,43028940165120,50712679480320,133120783635840,
   190172548051200,262954634342400,283991005089792],
  [1,-137632,18115812,-10472085,-1159411968,1449264960,3757353600,
   1404672192,-5945702400,39426594480,-21483221760,-4743048960,
   -110868769440,65216923200,-292171815936,573908924160,-796832225280,
   531221483520,1460859079680,-2739110774400,-782603078400,
   3246353510400,-1168687263744],
  [1,82016,8890596,5701995,457037568,327742272,1297296000,
   -1788671808,-511948800,12027702960,-9527341824,6966984960,
   30484602720,28447848000,58091185152,118446831360,158430504960,
   -222361251840,239651343360,190079809920,-857327328000,28598169600,
   218194808832],
  [1,41888,3232548,-43605,123026688,57841344,314160000,183218112,
   258508800,1991288880,1252323072,-1021697280,4906012320,
   -3514104000,3727696896,12802648320,10166446080,20332892160,
   7936220160,8210885760,47791814400,-25333862400,-90188550144],
  [1,-32032,2275812,414315,-77223168,-2312640,179625600,-32332608,
   35481600,1084693680,550851840,-432034560,-2400567840,1235995200,
   -300174336,4718165760,-4534548480,-8511713280,-1053803520,
   12753417600,10828857600,-17953689600,3908653056],
  [1,10208,704484,1589355,10679040,46398528,-9609600,57081024,
   -167270400,224426160,533820672,271607040,-9741600,916660800,
   2067158016,-1656357120,-679311360,1892782080,3994721280,
   -5895711360,1568160000,-10005811200,6838013952],
  [1,-17248,900900,-1508949,-20097792,43902144,32672640,-21155904,
   63866880,185985072,-186810624,778242816,-259829856,-2109032640,
   -1909619712,-643458816,1675634688,1177473024,3238050816,
   -155675520,-44478720,-6826659840,4981616640],
  [1,-3232,324324,103275,-2453760,15121728,-12297600,-15494976,
   74188800,87499440,-219034368,-142145280,29121120,499867200,
   -274627584,-544631040,-5806080,592220160,722856960,813214080,
   -13996800,-1025740800,-578285568],
  [1,14816,725796,-43605,16743168,-7316928,31920000,14841792,
   4147200,110118960,-61012224,62588160,198033120,197640000,
   -366363648,5218560,-75479040,-452874240,-1233239040,-1778474880,
   666144000,148377600,2518290432],
  [1,6896,132516,699435,736128,11096352,4502400,-38864448,20044800,
   -21727440,115105536,171953280,32315760,217339200,-118153728,
   122446080,-322237440,661893120,-489991680,959091840,-1020988800,
   174182400,-479582208],
  [1,-11632,475812,111915,-9283968,-491040,17673600,7584192,
   -18662400,32946480,-61205760,-22584960,-74323440,-10756800,
   200600064,-34179840,269982720,836075520,-664312320,-183254400,
   -1004918400,593510400,125024256],
  [1,7328,246564,-43605,3421440,1729728,4502400,-11866176,-6912000,
   5609520,-1790208,-28857600,-1265760,-80222400,35030016,-96802560,
   -145152000,-11612160,83082240,268168320,-170553600,212889600,-59609088],
  [1,-1120,89892,-181845,-172800,3172032,-3638400,6934464,-6912000,
   12798000,19554048,-7568640,3745440,-43200,-48356352,-17729280,
   18524160,-16035840,-61793280,98133120,-116640000,190771200,-74649600],
  [1,3408,69284,147755,295040,2450528,-169600,6681024,5913600,
   -1900240,-8656128,8992640,-2385200,-15211200,36246016,7220480,
   -39797760,-41656320,-22725120,16717440,9264000,80076800,-41576448],
  [1,-4576,126756,2475,-1324800,-949824,1061760,-254016,1935360,
   -841680,6983424,3168000,10755360,2721600,1741824,-31921920,
   -5806080,-58060800,36449280,-18264960,41644800,94187520,-83349504],
  [1,2864,51876,-26325,316800,-507744,309120,1197504,691200,
   -2857680,2467584,-777600,-4879440,5417280,-5515776,518400,
   14515200,11612160,15137280,9797760,-15085440,-21934080,-10450944],
  [1,1088,39204,25515,138240,-300672,-1065600,-1498176,-460800,
   2430000,-1928448,3732480,-3810240,648000,5308416,933120,
   14100480,-9953280,-9953280,-18195840,27993600,27648000,-35831808],
  [1,-2128,19620,-40149,67968,706464,186240,-627264,-414720,
   -2332368,-1292544,-307584,-943056,2928960,787968,6269184,
   7216128,-6967296,-2225664,-16744320,22654080,-8663040,-276480],
  [1,-1232,15524,37675,19840,-69472,-233600,-576,76800,-292560,
   472832,-1668480,588720,-1924800,-2025984,4348160,-1582080,
   5468160,-919040,-1537920,-7036800,-17100800,23365632],
  [1,944,1188,15147,-79488,61344,63360,36288,-709632,-452304,
   -850176,134784,854064,938304,-1866240,518400,-746496,-1658880,
   2198016,3825792,6065280,-4534272,-3815424],
  [1,560,1188,-12501,-51840,12960,-68736,-129600,248832,73008,
   200448,-335232,518832,-720576,898560,1237248,-1410048,995328,
   -1893888,-4053888,-1316736,-2764800,8570880],
  [1,-16,-5724,8235,17280,50976,78720,-46656,138240,114480,532224,
   -293760,-481680,25920,-262656,-1416960,2903040,-1658880,-69120,
   -3058560,51840,6082560,-2709504],
  [1,-400,-1116,-5589,26496,-71136,-7296,119232,-82944,86832,
   -352512,508032,-42768,191808,290304,-311040,-1741824,995328,
   705024,4572288,-1026432,-700416,-3151872]]]];

MULTFREEINFO.("M"):= ["$M$",
##
[[1,2,4,5,9,14,21,34,35],"$2.B$",
 [[1,27143910000,11707448673375,2031941058560000,91569524834304000,
   1102935324621312000,1254793905192960000,30434513446055706624,
   64353605265653760000],
  [1,2887650000,-249094652625,62147133440000,-487071940608000,
   11733354517248000,-6674435665920000,80942854909722624,-85576602746880000],
  [1,468855000,43747806375,3348961280000,-19026247680000,202389851664000,
   283334578560000,-369446834405376,-100644526080000],
  [1,236547000,-7678186425,1090251008000,12019625164800,37209562790400,
   -33800576832000,-142176425803776,125665005312000],
  [1,41967000,-749446425,55559168000,-273228595200,-288778089600,
   -419582592000,-275830603776,1202568192000],
  [1,13224600,618611175,5297868800,38198476800,-92343888000,76571827200,
   352155009024,-380511129600],
  [1,2693304,-33756345,-91334656,973209600,-457228800,2516811264,5350883328,
   -8261277696],
  [1,70200,2168775,-14694400,-121651200,261273600,-307929600,-1086898176,
   1267660800],
  [1,-81000,-1913625,14336000,110592000,-244944000,279936000,1003290624,
   -1161216000]]]];

MULTFREEINFO.("M12.2"):= ["$M_{12}.2$",
##
[[1,2,3],"$M_{11}$",
 [[1,11,12],
  [1,11,-12],
  [1,-1,0]]],
##
[[1,3,9,12],"$L_2(11).2$",
 [[1,22,55,66],
  [1,10,-5,-6],
  [1,-2,7,-6],
  [1,-2,-5,6]]],
##
[[1,2,3,7,8],"$A_6.2^2$",
 [[1,20,30,36,45],
  [1,20,-30,-36,45],
  [1,8,0,0,-9],
  [1,-2,-2*ER(5),2*ER(5),1],
  [1,-2,2*ER(5),-2*ER(5),1]]],
##
[[1,2,3,7,8,12,13],"$A_6.2_2 \\leq A_6.2^2$",
 [[1,1,36,36,40,60,90],
  [1,1,-36,-36,40,-60,90],
  [1,1,0,0,16,0,-18],
  [1,1,2*ER(5),2*ER(5),-4,-4*ER(5),2],
  [1,1,-2*ER(5),-2*ER(5),-4,4*ER(5),2],
  [1,-1,-6,6,0,0,0],
  [1,-1,6,-6,0,0,0]]],
##
[[1,4,5,12],"$L_2(11).2$",
 [[1,22,55,66],
  [1,-5,10,-6],
  [1,6,-1,-6],
  [1,-2,-5,6]]],
##
[[1,2,3,7,8,9,10,14,15],"$3^2.2.S_4$",
 [[1,4,12,27,36,72,72,108,108],
  [1,-4,12,27,-36,-72,72,-108,108],
  [1,0,-4,15,0,0,-24,0,12],
  [1,-ER(5),1,5,2*ER(5),4*ER(5),6,-5*ER(5),-13],
  [1,ER(5),1,5,-2*ER(5),-4*ER(5),6,5*ER(5),-13],
  [1,3,5,-3,6,0,-6,-9,3],
  [1,-3,5,-3,-6,0,-6,9,3],
  [1,1,-3,-3,-6,8,2,-3,3],
  [1,-1,-3,-3,6,-8,2,3,3]]],
##
[[1,2,3,5,6,7,8,9,10,11,14,15,16,17],"$3^2:2.A_4 \\leq 3^2.2.S_4$",
 [[1,1,8,24,27,27,36,36,72,72,72,72,216,216],
  [1,1,-8,24,27,27,-36,-36,72,72,-72,-72,-216,216],
  [1,1,0,-8,15,15,0,0,-24,-24,0,0,0,24],
  [1,-1,0,0,3,-3,12,-12,16,-16,8,-8,0,0],
  [1,-1,0,0,3,-3,-12,12,16,-16,-8,8,0,0],
  [1,1,-2*ER(5),2,5,5,2*ER(5),2*ER(5),6,6,4*ER(5),4*ER(5),-10*ER(5),-26],
  [1,1,2*ER(5),2,5,5,-2*ER(5),-2*ER(5),6,6,-4*ER(5),-4*ER(5),10*ER(5),-26],
  [1,1,6,10,-3,-3,6,6,-6,-6,0,0,-18,6],
  [1,1,-6,10,-3,-3,-6,-6,-6,-6,0,0,18,6],
  [1,-1,0,0,-9,9,0,0,0,0,0,0,0,0],
  [1,1,2,-6,-3,-3,-6,-6,2,2,8,8,-6,6],
  [1,1,-2,-6,-3,-3,6,6,2,2,-8,-8,6,6],
  [1,-1,0,0,3,-3,2*ER(3),-2*ER(3),-6,6,-6*ER(3),6*ER(3),0,0],
  [1,-1,0,0,3,-3,-2*ER(3),2*ER(3),-6,6,6*ER(3),-6*ER(3),0,0]]],
##
[[1,4,5,7,8,12,18],"$(2^2 \\times A_5).2$",
 [[1,15,20,60,60,120,120],
  [1,6,-7,15,-12,3,-6],
  [1,-5,4,4,-12,-8,16],
  [1,1+2*ER(5),-2,-4*ER(5),8-2*ER(5),-12,4+4*ER(5)],
  [1,1-2*ER(5),-2,4*ER(5),8+2*ER(5),-12,4-4*ER(5)],
  [1,3,8,0,0,0,-12],
  [1,-2,-2,-5,0,10,-2]]],
##
[[1,4,5,7,8,10,12,13,15,18,21],"$(2 \\times A_5).2 \\leq (2^2 \\times A_5).2$",
 [[1,1,15,15,40,60,60,120,120,120,240],
  [1,1,6,6,-14,15,15,-6,-6,-24,6],
  [1,1,-5,-5,8,4,4,16,16,-24,-16],
  [1,1,1+2*ER(5),1+2*ER(5),-4,-4*ER(5),-4*ER(5),4+4*ER(5),4+4*ER(5),
   16-4*ER(5),-24],
  [1,1,1-2*ER(5),1-2*ER(5),-4,4*ER(5),4*ER(5),4-4*ER(5),4-4*ER(5),
   16+4*ER(5),-24],
  [1,-1,7,-7,0,12,-12,8,-8,0,0],
  [1,1,3,3,16,0,0,-12,-12,0,0],
  [1,-1,-5,5,0,0,0,20,-20,0,0],
  [1,-1,3,-3,0,-12,12,0,0,0,0],
  [1,1,-2,-2,-4,-5,-5,-2,-2,0,20],
  [1,-1,-2,2,0,3,-3,-10,10,0,0]]],
[[1,3,7,8,9,12,15,18],"$M_8.(S_4 \\times 2)$",
 [[1,6,16,24,64,96,96,192],
  [1,-3,-8,6,16,-12,24,-24],
  [1,2-ER(5),2+2*ER(5),1-3*ER(5),6+2*ER(5),8,-6+2*ER(5),-14-2*ER(5)],
  [1,2+ER(5),2-2*ER(5),1+3*ER(5),6-2*ER(5),8,-6-2*ER(5),-14+2*ER(5)],
  [1,-3,4,6,4,-12,-12,12],
  [1,3,4,0,-8,-12,12,0],
  [1,1,-4,-6,4,-4,-4,12],
  [1,-2,-1,0,-8,8,2,0]]],
##
[[1,3,6,7,8,9,12,13,15,16,17,18,19],
 "$M_8.(A_4 \\times 2) \\leq M_8.(S_4 \\times 2)$",
 [[1,1,12,16,16,48,64,64,96,96,192,192,192],
  [1,1,-6,-8,-8,12,16,16,24,24,-24,-24,-24],
  [1,-1,0,8,-8,0,16,-16,8,-8,16,0,-16],
  [1,1,4-2*ER(5),2+2*ER(5),2+2*ER(5),2-6*ER(5),6+2*ER(5),6+2*ER(5),
   -6+2*ER(5),-6+2*ER(5),-14-2*ER(5),16,-14-2*ER(5)],
  [1,1,4+2*ER(5),2-2*ER(5),2-2*ER(5),2+6*ER(5),6-2*ER(5),6-2*ER(5),
   -6-2*ER(5),-6-2*ER(5),-14+2*ER(5),16,-14+2*ER(5)],
  [1,1,-6,4,4,12,4,4,-12,-12,12,-24,12],
  [1,1,6,4,4,0,-8,-8,12,12,0,-24,0],
  [1,-1,0,4,-4,0,-8,8,12,-12,-24,0,24],
  [1,1,2,-4,-4,-12,4,4,-4,-4,12,-8,12],
  [1,-1,0,-2-2*ER(3),2+2*ER(3),0,4+2*ER(3),-4-2*ER(3),
   -6+6*ER(3),6-6*ER(3),-6,0,6],
  [1,-1,0,-2+2*ER(3),2-2*ER(3),0,4-2*ER(3),-4+2*ER(3),
   -6-6*ER(3),6+6*ER(3),-6,0,6],
  [1,1,-4,-1,-1,0,-8,-8,2,2,0,16,0],
  [1,-1,0,-1,1,0,-8,8,2,-2,16,0,-16]]],
[[1,4,6,7,8,12,15,18],"$4^2:D_{12}.2$",
 [[1,6,16,24,64,96,96,192],
  [1,-3,7,6,10,-21,-12,12],
  [1,-3,-4,6,-12,12,-12,12],
  [1,2-ER(5),2+2*ER(5),1-3*ER(5),-10-2*ER(5),-6+2*ER(5),8,2+2*ER(5)],
  [1,2+ER(5),2-2*ER(5),1+3*ER(5),-10+2*ER(5),-6-2*ER(5),8,2-2*ER(5)],
  [1,3,4,0,4,12,-12,-12],
  [1,1,-4,-6,4,-4,-4,12],
  [1,-2,-1,0,4,2,8,-12]]],
##
[[1,4,6,7,8,9,10,11,12,14,15,18,20],"$4^2:(6 \\times 2) \\leq 4^2:D_{12}.2$",
 [[1,1,12,16,16,48,64,64,96,96,192,192,192],
  [1,1,-6,7,7,12,10,10,-12,-12,12,-42,12],
  [1,1,-6,-4,-4,12,-12,-12,-12,-12,12,24,12],
  [1,1,4-2*ER(5),2+2*ER(5),2+2*ER(5),2-6*ER(5),-10-2*ER(5),-10-2*ER(5),
   8,8,2+2*ER(5),-12+4*ER(5),2+2*ER(5)],
  [1,1,4+2*ER(5),2-2*ER(5),2-2*ER(5),2+6*ER(5),-10+2*ER(5),-10+2*ER(5),
   8,8,2-2*ER(5),-12-4*ER(5),2-2*ER(5)],
  [1,-1,0,8,-8,0,8,-8,0,0,24,0,-24],
  [1,-1,0,-4,4,0,-4,4,-24,24,12,0,-12],
  [1,-1,0,-4,4,0,-4,4,12,-12,12,0,-12],
  [1,1,6,4,4,0,4,4,-12,-12,-12,24,-12],
  [1,-1,0,4,-4,0,-12,12,0,0,-12,0,12],
  [1,1,2,-4,-4,-12,4,4,-4,-4,12,-8,12],
  [1,1,-4,-1,-1,0,4,4,8,8,-12,4,-12],
  [1,-1,0,-1,1,0,8,-8,0,0,-12,0,12]]]];

MULTFREEINFO.("M22.2"):= ["$M_{22}.2$",
##
[[1,3],"$L_3(4).2_2$",
 [[1,21],
  [1,-1]]],
##
[[1,2,3,4],"$L_3(4) \\leq L_3(4).2_2$",
 [[1,1,21,21],
  [1,-1,21,-21],
  [1,1,-1,-1],
  [1,-1,-1,1]]],
##
[[1,3,9],"$2^4:S_6$",
 [[1,16,60],
  [1,-6,5],
  [1,2,-3]]],
##
[[1,2,3,4,9,10,13,14,17,18],"$2^4:A_5 \\leq 2^4:S_6$",
 [[1,1,5,5,96,96,120,120,240,240],
  [1,-1,-5,5,-96,96,-120,120,-240,240],
  [1,1,5,5,-36,-36,10,10,20,20],
  [1,-1,-5,5,36,-36,-10,10,-20,20],
  [1,1,5,5,12,12,-6,-6,-12,-12],
  [1,-1,-5,5,-12,12,6,-6,12,-12],
  [1,1,-1,-1,0,0,12,12,-12,-12],
  [1,-1,1,-1,0,0,-12,12,12,-12],
  [1,-1,1,-1,0,0,8,-8,-8,8],
  [1,1,-1,-1,0,0,-8,-8,8,8]]],
##
[[1,2,3,4,9,10],"$2^4:A_6 \\leq 2^4:S_6$",
 [[1,1,16,16,60,60],
  [1,-1,-16,16,-60,60],
  [1,1,-6,-6,5,5],
  [1,-1,6,-6,-5,5],
  [1,1,2,2,-3,-3],
  [1,-1,-2,2,3,-3]]],
##
[[1,3,9,13,18],"$2^4:S_5 \\leq 2^4:S_6$",
 [[1,5,96,120,240],
  [1,5,-36,10,20],
  [1,5,12,-6,-12],
  [1,-1,0,12,-12],
  [1,-1,0,-8,8]]],
##
[[1,2,3,4,13,14],"$A_7$",
 [[1,15,35,70,105,126],
  [1,-15,-35,70,105,-126],
  [1,-7,13,-18,17,-6],
  [1,7,-13,-18,17,6],
  [1,3,3,2,-3,-6],
  [1,-3,-3,2,-3,6]]],
##
[[1,3,9,13],"$2^5:S_5$",
 [[1,30,40,160],
  [1,-3,18,-16],
  [1,9,-2,-8],
  [1,-3,-2,4]]],
##
[[1,2,3,4,9,10,13,14],"$2^4:S_5 \\leq 2^5:S_5$",
 [[1,1,30,30,40,40,160,160],
  [1,-1,-30,30,-40,40,-160,160],
  [1,1,-3,-3,18,18,-16,-16],
  [1,-1,3,-3,-18,18,16,-16],
  [1,1,9,9,-2,-2,-8,-8],
  [1,-1,-9,9,2,-2,8,-8],
  [1,1,-3,-3,-2,-2,4,4],
  [1,-1,3,-3,2,-2,-4,4]]],
##
[[1,3,4,9,13,16],"$2^4:(A_5 \\times 2) \\leq 2^5:S_5$",
 [[1,1,40,40,60,320],
  [1,1,18,18,-6,-32],
  [1,-1,-20,20,0,0],
  [1,1,-2,-2,18,-16],
  [1,1,-2,-2,-6,8],
  [1,-1,2,-2,0,0]]],
##
[[1,3,9,11,13],"$2^3:L_3(2) \\times 2$",
 [[1,7,42,112,168],
  [1,-4,9,24,-30],
  [1,4,9,-8,-6],
  [1,-3,2,-8,8],
  [1,1,-6,4,0]]],
##
[[1,2,3,4,9,10,11,12,13,14],"$2^3:L_3(2) \\leq 2^3:L_3(2) \\times 2$",
 [[1,1,7,7,42,42,112,112,168,168],
  [1,-1,-7,7,-42,42,-112,112,-168,168],
  [1,1,-4,-4,9,9,24,24,-30,-30],
  [1,-1,4,-4,-9,9,-24,24,30,-30],
  [1,1,4,4,9,9,-8,-8,-6,-6],
  [1,-1,-4,4,-9,9,8,-8,6,-6],
  [1,1,-3,-3,2,2,-8,-8,8,8],
  [1,-1,3,-3,-2,2,8,-8,-8,8],
  [1,1,1,1,-6,-6,4,4,0,0],
  [1,-1,-1,1,6,-6,-4,4,0,0]]],
##
[[1,3,9,13,20],"$A_6.2^2$",
 [[1,30,45,180,360],
  [1,8,-21,48,-36],
  [1,16,3,-16,-4],
  [1,-2,9,8,-16],
  [1,-2,-3,-4,8]]],
##
[[1,2,3,4,9,10,13,14,20,21],"$A_6.2_3 \\leq A_6.2^2$",
 [[1,1,30,30,45,45,180,180,360,360],
  [1,-1,-30,30,-45,45,-180,180,-360,360],
  [1,1,8,8,-21,-21,48,48,-36,-36],
  [1,-1,-8,8,21,-21,-48,48,36,-36],
  [1,1,16,16,3,3,-16,-16,-4,-4],
  [1,-1,-16,16,-3,3,16,-16,4,-4],
  [1,1,-2,-2,9,9,8,8,-16,-16],
  [1,-1,2,-2,-9,9,-8,8,16,-16],
  [1,1,-2,-2,-3,-3,-4,-4,8,8],
  [1,-1,2,-2,3,-3,4,-4,-8,8]]],
##
[[1,3,4,9,10,12,13,16,18,20],"$A_6.2_2 \\leq A_6.2^2$",
 [[1,1,30,30,45,45,180,180,360,360],
  [1,1,8,8,-21,-21,48,48,-36,-36],
  [1,-1,20,-20,15,-15,0,0,-60,60],
  [1,1,16,16,3,3,-16,-16,-4,-4],
  [1,-1,12,-12,-9,9,0,0,36,-36],
  [1,-1,-2,2,5,-5,28,-28,8,-8],
  [1,1,-2,-2,9,9,8,8,-16,-16],
  [1,-1,-2,2,-7,7,0,0,-16,16],
  [1,-1,-2,2,5,-5,-12,12,8,-8],
  [1,1,-2,-2,-3,-3,-4,-4,8,8]]],
##
[[1,4,9,13,16,18],"$L_2(11).2$",
 [[1,55,55,66,165,330],
  [1,-25,15,-6,45,-30],
  [1,13,13,-18,-3,-6],
  [1,7,-5,6,9,-18],
  [1,-3,-7,-6,1,14],
  [1,-3,5,6,-11,2]]],
##
[[1,2,3,4,9,10,13,14,15,16,17,18],"$L_2(11) \\leq L_2(11).2$",
 [[1,1,55,55,55,55,66,66,165,165,330,330],
  [1,-1,-55,-55,55,55,-66,66,-165,165,-330,330],
  [1,-1,25,-15,-25,15,6,-6,-45,45,30,-30],
  [1,1,-25,15,-25,15,-6,-6,45,45,-30,-30],
  [1,1,13,13,13,13,-18,-18,-3,-3,-6,-6],
  [1,-1,-13,-13,13,13,18,-18,3,-3,6,-6],
  [1,1,7,-5,7,-5,6,6,9,9,-18,-18],
  [1,-1,-7,5,7,-5,-6,6,-9,9,18,-18],
  [1,-1,3,7,-3,-7,6,-6,-1,1,-14,14],
  [1,1,-3,-7,-3,-7,-6,-6,1,1,14,14],
  [1,-1,3,-5,-3,5,-6,6,11,-11,-2,2],
  [1,1,-3,5,-3,5,6,6,-11,-11,2,2]]]];

MULTFREEINFO.("J2.2"):= ["$J_2.2$",
##
[[1,5,7],"$U_3(3).2$",
 [[1,36,63],
  [1,6,-7],
  [1,-4,3]]],
##
[[1,2,5,6,7,8],"$U_3(3) \\leq U_3(3).2$",
 [[1,1,36,36,63,63],
  [1,-1,-36,36,-63,63],
  [1,1,6,6,-7,-7],
  [1,-1,-6,6,7,-7],
  [1,1,-4,-4,3,3],
  [1,-1,4,-4,-3,3]]],
##
[[1,7,10,12],"$3.A_6.2^2$",
 [[1,36,108,135],
  [1,-4,-12,15],
  [1,8,-4,-5],
  [1,-4,8,-5]]],
##
[[1,2,7,8,10,11,12,13],"$3.A_6.2_2 \\leq 3.A_6.2^2$",
 [[1,1,36,36,108,108,135,135],
  [1,-1,-36,36,108,-108,-135,135],
  [1,1,-4,-4,-12,-12,15,15],
  [1,-1,4,-4,-12,12,-15,15],
  [1,1,8,8,-4,-4,-5,-5],
  [1,-1,-8,8,-4,4,5,-5],
  [1,1,-4,-4,8,8,-5,-5],
  [1,-1,4,-4,8,-8,5,-5]]],
##
[[1,4,7,8,10,12,17],"$3.A_6.2_3 \\leq 3.A_6.2^2$",
 [[1,1,36,36,135,135,216],
  [1,-1,-12,12,15,-15,0],
  [1,1,-4,-4,15,15,-24],
  [1,-1,8,-8,15,-15,0],
  [1,1,8,8,-5,-5,-8],
  [1,1,-4,-4,-5,-5,16],
  [1,-1,0,0,-9,9,0]]],
##
[[1,3,5,10,14],"$2^{1+4}_{-}:S_5$",
 [[1,10,64,80,160],
  [1,-5,4,20,-20],
  [1,5,-16,10,0],
  [1,3,8,-4,-8],
  [1,-2,-2,-4,7]]],
##
[[1,3,5,8,10,12,13,14,23,25,26,27],"$2^{1+4}_-:5:4 \\leq 2^{1+4}_{-}:S_5$",
 [[1,5,20,40,64,80,80,160,160,320,320,640],
  [1,5,-10,-20,4,20,20,-20,-20,20,80,-80],
  [1,5,10,20,-16,10,10,0,0,-80,40,0],
  [1,-1,8,-8,0,-24,-8,-32,32,0,32,0],
  [1,5,6,12,8,-4,-4,-8,-8,40,-16,-32],
  [1,-1,6,-6,-4,8,-16,28,4,4,8,-32],
  [1,-1,-2,2,20,16,-8,-12,12,-20,-8,0],
  [1,5,-4,-8,-2,-4,-4,7,7,-10,-16,28],
  [1,-1,-4,4,6,-12,4,13,-1,-6,8,-12],
  [1,-1,-4,4,-8,2,-10,-8,-8,8,8,16],
  [1,-1,2+ER(6),-2-ER(6),-2+2*ER(6),2-ER(6),8-ER(6),
   -2,-2-6*ER(6),2-2*ER(6),-10+2*ER(6),4+6*ER(6)],
  [1,-1,2-ER(6),-2+ER(6),-2-2*ER(6),2+ER(6),8+ER(6),
   -2,-2+6*ER(6),2+2*ER(6),-10-2*ER(6),4-6*ER(6)]]],
##
[[1,5,7,10,14,16],"$2^{2+4}.(S_3 \\times S_3)$",
 [[1,12,32,96,192,192],
  [1,7,-8,16,12,-28],
  [1,-3,12,6,2,-18],
  [1,5,4,-2,-18,10],
  [1,0,-1,-12,12,0],
  [1,-3,-4,6,-6,6]]],
##
[[1,2,5,6,7,8,10,11,14,15,16,17],
"$2^{2+4}.(3 \\times S_3) \\leq 2^{2+4}.(S_3 \\times S_3)$",
 [[1,1,12,12,32,32,96,96,192,192,192,192],
  [1,-1,12,-12,32,-32,-96,96,-192,-192,192,192],
  [1,1,7,7,-8,-8,16,16,-28,12,-28,12],
  [1,-1,7,-7,-8,8,-16,16,28,-12,-28,12],
  [1,1,-3,-3,12,12,6,6,-18,2,-18,2],
  [1,-1,-3,3,12,-12,-6,6,18,-2,-18,2],
  [1,1,5,5,4,4,-2,-2,10,-18,10,-18],
  [1,-1,5,-5,4,-4,2,-2,-10,18,10,-18],
  [1,1,0,0,-1,-1,-12,-12,0,12,0,12],
  [1,-1,0,0,-1,1,12,-12,0,-12,0,12],
  [1,1,-3,-3,-4,-4,6,6,6,-6,6,-6],
  [1,-1,-3,3,-4,4,-6,6,-6,6,6,-6]]],
##
[[1,5,7,9,10,14,15,16,20],
"$2^{2+4}.(S_3 \\times 3) \\leq 2^{2+4}.(S_3 \\times S_3)$",
 [[1,1,24,32,32,192,192,192,384],
  [1,1,14,-8,-8,32,12,12,-56],
  [1,1,-6,12,12,12,2,2,-36],
  [1,-1,0,-8,8,0,-12,12,0],
  [1,1,10,4,4,-4,-18,-18,20],
  [1,1,0,-1,-1,-24,12,12,0],
  [1,-1,0,7,-7,0,-12,12,0],
  [1,1,-6,-4,-4,12,-6,-6,12],
  [1,-1,0,0,0,0,16,-16,0]]],
##
[[1,7,10,12,14,16,21],"$(A_4 \\times A_5).2$",
 [[1,15,20,24,180,240,360],
  [1,5,10,-6,0,20,-30],
  [1,1,6,10,-16,-12,10],
  [1,-5,0,4,20,0,-20],
  [1,6,-4,0,9,-12,0],
  [1,-3,2,-6,0,-12,18],
  [1,-1,-4,0,-12,16,0]]],
##
[[1,2,7,8,10,11,12,13,14,15,16,17,20,21],
"$A_4 \\times A_5 \\leq (A_4 \\times A_5).2$",
 [[1,1,15,15,20,20,24,24,180,180,240,240,360,360],
  [1,-1,-15,15,20,-20,24,-24,180,-180,-240,240,-360,360],
  [1,1,5,5,10,10,-6,-6,0,0,20,20,-30,-30],
  [1,-1,-5,5,10,-10,-6,6,0,0,-20,20,30,-30],
  [1,1,1,1,6,6,10,10,-16,-16,-12,-12,10,10],
  [1,-1,-1,1,6,-6,10,-10,-16,16,12,-12,-10,10],
  [1,1,-5,-5,0,0,4,4,20,20,0,0,-20,-20],
  [1,-1,5,-5,0,0,4,-4,20,-20,0,0,20,-20],
  [1,1,6,6,-4,-4,0,0,9,9,-12,-12,0,0],
  [1,-1,-6,6,-4,4,0,0,9,-9,12,-12,0,0],
  [1,1,-3,-3,2,2,-6,-6,0,0,-12,-12,18,18],
  [1,-1,3,-3,2,-2,-6,6,0,0,12,-12,-18,18],
  [1,-1,1,-1,-4,4,0,0,-12,12,-16,16,0,0],
  [1,1,-1,-1,-4,-4,0,0,-12,-12,16,16,0,0]]],
##
[[1,3,10,11,12,14,21,23],"$(A_5 \\times D_{10}).2$",
 [[1,12,25,50,120,200,300,300],
  [1,-6,-5,20,30,-10,-60,30],
  [1,-2,11,8,-6,18,-8,-22],
  [1,6,-5,0,18,10,0,-30],
  [1,4,5,-10,0,0,-20,20],
  [1,3,1,8,-6,-22,12,3],
  [1,-4,1,-6,8,-8,12,-4],
  [1,-1,-5,0,-10,10,0,5]]],
##
[[1,8,10,11,12,13,14,16,21,23,26,27],"$5^2:(4 \\times S_3)$",
 [[1,15,25,75,100,150,150,150,150,300,300,600],
  [1,-3,-13,27,-12,-30,6,-6,6,36,12,-24],
  [1,1,11,19,16,10,-18,-18,-18,20,-8,-16],
  [1,9,-5,-5,0,10,30,-10,-10,20,-40,0],
  [1,7,5,7,-20,-2,6,-6,-6,-28,28,8],
  [1,-3,7,7,-12,10,6,14,26,-4,-28,-24],
  [1,6,1,-6,16,-15,-3,12,12,0,12,-36],
  [1,-3,-5,3,4,18,6,18,-18,-12,12,-24],
  [1,-1,1,-13,-12,6,-10,-2,-2,28,12,-8],
  [1,2,-5,2,0,3,-19,4,4,-8,-12,28],
  [1,-3,1+ER(6),-3,4-ER(6),-6-4*ER(6),6,-6+5*ER(6),-4*ER(6),
   -6+2*ER(6),-3*ER(6),12+4*ER(6)],
  [1,-3,1-ER(6),-3,4+ER(6),-6+4*ER(6),6,-6-5*ER(6),4*ER(6),
   -6-2*ER(6),3*ER(6),12-4*ER(6)]]]];

MULTFREEINFO.("HS.2"):= ["$HS.2$",
##
[[1,3,5],"$M_{22}.2$",
 [[1,22,77],
  [1,-8,7],
  [1,2,-3]]],
##
[[1,2,3,4,5,6],"$M_{22} \\leq M_{22}.2$",
 [[1,1,22,22,77,77],
  [1,-1,-22,22,-77,77],
  [1,1,-8,-8,7,7],
  [1,-1,8,-8,-7,7],
  [1,1,2,2,-3,-3],
  [1,-1,-2,2,3,-3]]],
##
[[1,2,10,11],"$U_3(5).2$",
 [[1,50,126,175],
  [1,-50,-126,175],
  [1,6,-6,-1],
  [1,-6,6,-1]]],
##
[[1,2,3,4,9,10,11],"$U_3(5) \\leq U_3(5).2$",
 [[1,1,50,50,175,175,252],
  [1,1,-50,-50,175,175,-252],
  [1,-1,-20,20,35,-35,0],
  [1,-1,20,-20,35,-35,0],
  [1,-1,0,0,-5,5,0],
  [1,1,6,6,-1,-1,-12],
  [1,1,-6,-6,-1,-1,12]]],
##
[[1,10,11,14,19,21,22,25,26,29,31,34,35,37,39],"$5^{1+2}_+:[2^5]$",
 [[1,50,125,250,250,500,1000,1000,1000,2000,2000,2000,4000,4000,4000],
  [1,6,-7,118,30,60,-56,120,32,-112,-112,-112,128,128,-224],
  [1,-6,5,130,-30,-60,40,-120,-40,80,80,80,-160,-160,160],
  [1,14,-7,-2,30,12,72,-40,32,16,16,80,64,-128,-160],
  [1,6,13,-2,10,60,-56,-40,-8,48,-112,48,-32,-32,96],
  [1,9,8,-2,0,-18,37,45,-58,-34,-34,20,-16,2,40],
  [1,-6,13,-2,40,-18,-8,20,-8,96,26,-30,-116,52,-60],
  [1,14,13,-2,-10,-8,-8,0,72,-24,36,-60,-56,-8,40],
  [1,-1,-22,-2,10,32,7,-5,-8,-64,56,20,-116,52,40],
  [1,-2,-3,-2,-22,4,-40,56,8,32,32,64,-16,-64,-48],
  [1,-10,5,-2,-14,-4,40,-8,40,-16,-64,32,-32,64,-32],
  [1,-6,3+6*ER(5),-2,-2*ER(5),12+4*ER(5),12-4*ER(5),-8*ER(5),-8-8*ER(5),
   -4-12*ER(5),16+16*ER(5),-40+8*ER(5),44+4*ER(5),-48+16*ER(5),20-20*ER(5)],
  [1,-6,3-6*ER(5),-2,2*ER(5),12-4*ER(5),12+4*ER(5),8*ER(5),-8+8*ER(5),
   -4+12*ER(5),16-16*ER(5),-40-8*ER(5),44-4*ER(5),-48-16*ER(5),20+20*ER(5)],
  [1,-2,-3,-2,14,-32,-40,-16,8,-40,-4,28,56,8,24],
  [1,5,-10,-2,-14,-4,-5,-23,-20,44,-4,-28,28,64,-32]]],
##
[[1,3,5,10,19],"$L_3(4).2^2$",
 [[1,42,105,280,672],
  [1,12,-45,80,-48],
  [1,22,5,-20,-8],
  [1,-2,17,16,-32],
  [1,-2,-3,-4,8]]],
##
[[1,3,4,5,6,10,13,17,19],"$L_3(4).2_3 \\leq L_3(4).2^2$",
 [[1,1,42,42,105,105,560,672,672],
  [1,1,12,12,-45,-45,160,-48,-48],
  [1,-1,-28,28,-35,35,0,-112,112],
  [1,1,22,22,5,5,-40,-8,-8],
  [1,-1,-18,18,15,-15,0,48,-48],
  [1,1,-2,-2,17,17,32,-32,-32],
  [1,-1,2,-2,15,-15,0,-32,32],
  [1,-1,2,-2,-5,5,0,8,-8],
  [1,1,-2,-2,-3,-3,-8,8,8]]],
##
[[1,2,3,4,5,6,10,11,19,20],"$L_3(4).2_1 \\leq L_3(4).2^2$",
 [[1,1,42,42,105,105,280,280,672,672],
  [1,-1,-42,42,105,-105,280,-280,672,-672],
  [1,1,12,12,-45,-45,80,80,-48,-48],
  [1,-1,-12,12,-45,45,80,-80,-48,48],
  [1,1,22,22,5,5,-20,-20,-8,-8],
  [1,-1,-22,22,5,-5,-20,20,-8,8],
  [1,1,-2,-2,17,17,16,16,-32,-32],
  [1,-1,2,-2,17,-17,16,-16,-32,32],
  [1,1,-2,-2,-3,-3,-4,-4,8,8],
  [1,-1,2,-2,-3,3,-4,4,8,-8]]],
##
[[1,5,7,10,14],"$A_8.2 \\times 2$",
 [[1,28,105,336,630],
  [1,-12,25,16,-30],
  [1,8,15,-24,0],
  [1,6,-5,28,-30],
  [1,-2,-5,-4,10]]],
##
[[1,3,5,7,9,10,14,16],"$A_8 \\times 2 \\leq A_8.2 \\times 2$",
 [[1,1,56,105,105,336,336,1260],
  [1,-1,0,-35,35,-112,112,0],
  [1,1,-24,25,25,16,16,-60],
  [1,1,16,15,15,-24,-24,0],
  [1,-1,0,15,-15,-12,12,0],
  [1,1,12,-5,-5,28,28,-60],
  [1,1,-4,-5,-5,-4,-4,20],
  [1,-1,0,-5,5,8,-8,0]]],
##
[[1,4,5,7,9,10,14,17],"$A_8.2 \\leq A_8.2 \\times 2$",
 [[1,1,56,105,105,336,336,1260],
  [1,-1,0,35,-35,-112,112,0],
  [1,1,-24,25,25,16,16,-60],
  [1,1,16,15,15,-24,-24,0],
  [1,-1,0,-15,15,-12,12,0],
  [1,1,12,-5,-5,28,28,-60],
  [1,1,-4,-5,-5,-4,-4,20],
  [1,-1,0,5,-5,8,-8,0]]],
##
[[1,2,5,6,7,8,10,11,14,15],"$A_8.2 \\leq A_8.2 \\times 2$",
 [[1,1,28,28,105,105,336,336,630,630],
  [1,-1,-28,28,-105,105,-336,336,630,-630],
  [1,1,-12,-12,25,25,16,16,-30,-30],
  [1,-1,12,-12,-25,25,-16,16,-30,30],
  [1,1,8,8,15,15,-24,-24,0,0],
  [1,-1,-8,8,-15,15,24,-24,0,0],
  [1,1,6,6,-5,-5,28,28,-30,-30],
  [1,-1,-6,6,5,-5,-28,28,-30,30],
  [1,1,-2,-2,-5,-5,-4,-4,10,10],
  [1,-1,2,-2,5,-5,4,-4,10,-10]]],
##
[[1,3,5,7,10,14,16,19,26],"$4^3:(L_3(2) \\times 2)$",
 [[1,28,64,112,336,448,896,896,1344],
  [1,-7,-36,42,-84,168,-224,56,84],
  [1,13,14,32,6,28,16,-164,54],
  [1,13,4,22,36,-32,-64,56,-36],
  [1,-5,20,2,6,52,16,16,-108],
  [1,3,4,2,-34,-12,16,16,4],
  [1,-7,-6,12,6,-12,16,-4,-6],
  [1,5,-10,-8,6,12,16,-4,-18],
  [1,-2,4,-8,6,-2,-19,-4,24]]],
##
[[1,2,3,4,5,6,7,8,10,11,14,15,16,17,19,20,26,27],
"$4^3:L_3(2) \\leq 4^3:(L_3(2) \\times 2)$",
 [[1,1,28,28,64,64,112,112,336,336,448,448,896,896,896,896,1344,1344],
  [1,-1,28,-28,-64,64,-112,112,-336,336,-448,448,-896,896,-896,896,
   1344,-1344],
  [1,1,-7,-7,-36,-36,42,42,-84,-84,168,168,56,-224,-224,56,84,84],
  [1,-1,-7,7,36,-36,-42,42,84,-84,-168,168,-56,-224,224,56,84,-84],
  [1,1,13,13,14,14,32,32,6,6,28,28,-164,16,16,-164,54,54],
  [1,-1,13,-13,-14,14,-32,32,-6,6,-28,28,164,16,-16,-164,54,-54],
  [1,1,13,13,4,4,22,22,36,36,-32,-32,56,-64,-64,56,-36,-36],
  [1,-1,13,-13,-4,4,-22,22,-36,36,32,-32,-56,-64,64,56,-36,36],
  [1,1,-5,-5,20,20,2,2,6,6,52,52,16,16,16,16,-108,-108],
  [1,-1,-5,5,-20,20,-2,2,-6,6,-52,52,-16,16,-16,16,-108,108],
  [1,1,3,3,4,4,2,2,-34,-34,-12,-12,16,16,16,16,4,4],
  [1,-1,3,-3,-4,4,-2,2,34,-34,12,-12,-16,16,-16,16,4,-4],
  [1,1,-7,-7,-6,-6,12,12,6,6,-12,-12,-4,16,16,-4,-6,-6],
  [1,-1,-7,7,6,-6,-12,12,-6,6,12,-12,4,16,-16,-4,-6,6],
  [1,1,5,5,-10,-10,-8,-8,6,6,12,12,-4,16,16,-4,-18,-18],
  [1,-1,5,-5,10,-10,8,-8,-6,6,-12,12,4,16,-16,-4,-18,18],
  [1,1,-2,-2,4,4,-8,-8,6,6,-2,-2,-4,-19,-19,-4,24,24],
  [1,-1,-2,2,-4,4,8,-8,-6,6,2,-2,4,-19,19,-4,24,-24]]],
##
[[1,2,3,4,5,6,9,10,11,16,17,19,20,22,23,34,35],"$M_{11}$",
 [[1,12,55,110,132,165,330,396,495,660,660,792,792,1320,1320,1980,1980],
  [1,-12,55,-110,132,165,-330,-396,495,660,-660,-792,792,-1320,1320,
   -1980,1980],
  [1,-8,5,60,52,-85,-20,96,195,-140,-40,-288,72,320,-280,-120,180],
  [1,8,5,-60,52,-85,20,-96,195,-140,40,288,72,-320,-280,120,180],
  [1,7,-20,35,37,40,55,-54,45,85,-140,72,-138,70,-80,-45,30],
  [1,-7,-20,-35,37,40,-55,54,45,85,140,-72,-138,-70,-80,45,30],
  [1,0,-19,0,-12,-21,0,0,27,84,0,0,72,0,-24,0,-108],
  [1,4,7,26,4,37,-50,36,63,-44,28,72,24,-8,40,-108,-132],
  [1,-4,7,-26,4,37,50,-36,63,-44,-28,-72,24,8,40,108,-132],
  [1,-5,-4,15,13,-16,-5,-30,-3,-11,20,0,-18,-10,56,15,-18],
  [1,5,-4,-15,13,-16,5,30,-3,-11,-20,0,-18,10,56,-15,-18],
  [1,-1,12,11,-11,-8,15,26,13,21,-12,-8,-26,-58,0,27,-2],
  [1,1,12,-11,-11,-8,-15,-26,13,21,12,8,-26,58,0,-27,-2],
  [1,5,6,5,13,4,15,-10,-23,9,30,-20,22,-10,-24,-15,-8],
  [1,-5,6,-5,13,4,-15,10,-23,9,-30,20,22,10,-24,15,-8],
  [1,-ER(5),-4,-ER(5),-7,4,7*ER(5),2*ER(5),-3,-11,4*ER(5),4*ER(5),
   2,2*ER(5),-4,-17*ER(5),22],
  [1,ER(5),-4,ER(5),-7,4,-7*ER(5),-2*ER(5),-3,-11,-4*ER(5),-4*ER(5),
   2,-2*ER(5),-4,17*ER(5),22]]],
##
[[1,5,7,10,14,19,22,25,26],"$2^{1+6}_+:S_5$",
 [[1,30,80,128,480,640,960,1536,1920],
  [1,15,20,-32,60,80,0,96,-240],
  [1,15,20,8,60,-20,0,-144,60],
  [1,-3,14,40,-48,68,36,-48,-60],
  [1,5,-10,8,0,20,-60,16,20],
  [1,7,4,0,-28,-32,16,32,0],
  [1,-5,10,-12,-10,10,-20,-4,30],
  [1,-5,0,8,20,-20,0,16,-20],
  [1,0,-10,-7,0,10,30,-24,0]]],
##
[[1,2,5,6,7,8,10,11,14,15,19,20,22,23,24,25,26,27],"$4.2^4:S_5 \\leq 2^{1+6}_+:\
S_5$",
 [[1,1,30,30,80,80,128,128,480,480,640,640,960,960,1536,1536,1920,1920],
  [1,-1,30,-30,80,-80,-128,128,480,-480,640,-640,960,-960,-1536,1536,
   1920,-1920],
  [1,1,15,15,20,20,-32,-32,60,60,80,80,0,0,96,96,-240,-240],
  [1,-1,15,-15,20,-20,32,-32,60,-60,80,-80,0,0,-96,96,-240,240],
  [1,1,15,15,20,20,8,8,60,60,-20,-20,0,0,-144,-144,60,60],
  [1,-1,15,-15,20,-20,-8,8,60,-60,-20,20,0,0,144,-144,60,-60],
  [1,1,-3,-3,14,14,40,40,-48,-48,68,68,36,36,-48,-48,-60,-60],
  [1,-1,-3,3,14,-14,-40,40,-48,48,68,-68,36,-36,48,-48,-60,60],
  [1,1,5,5,-10,-10,8,8,0,0,20,20,-60,-60,16,16,20,20],
  [1,-1,5,-5,-10,10,-8,8,0,0,20,-20,-60,60,-16,16,20,-20],
  [1,1,7,7,4,4,0,0,-28,-28,-32,-32,16,16,32,32,0,0],
  [1,-1,7,-7,4,-4,0,0,-28,28,-32,32,16,-16,-32,32,0,0],
  [1,1,-5,-5,10,10,-12,-12,-10,-10,10,10,-20,-20,-4,-4,30,30],
  [1,-1,-5,5,10,-10,12,-12,-10,10,10,-10,-20,20,4,-4,30,-30],
  [1,-1,-5,5,0,0,-8,8,20,-20,-20,20,0,0,-16,16,-20,20],
  [1,1,-5,-5,0,0,8,8,20,20,-20,-20,0,0,16,16,-20,-20],
  [1,1,0,0,-10,-10,-7,-7,0,0,10,10,30,30,-24,-24,0,0],
  [1,-1,0,0,-10,10,7,-7,0,0,10,-10,30,-30,24,-24,0,0]]]];

MULTFREEINFO.("J3.2"):= ["$J_3.2$",
##
[[1,4,6,10,13,15,16],"$L_2(16).4$",
 [[1,85,120,510,680,2040,2720],
  [1,13,12,-30,-40,-12,56],
  [1,-17,-18,0,0,-102,136],
  [1,13,-6,6,32,-30,-16],
  [1,-4-ER(17),-6+2*ER(17),-11-5*ER(17),-2+6*ER(17),38-2*ER(17),-16],
  [1,-4+ER(17),-6-2*ER(17),-11+5*ER(17),-2-6*ER(17),38+2*ER(17),-16],
  [1,-5,12,24,-4,-12,-16]]],
##
[[1,5,10,12,13,14,15,16,18,20,22,24,25,27,29],"$3^2.3^{1+2}:8.2$",
 [[1,81,243,243,972,972,1944,1944,1944,1944,1944,1944,3888,3888,3888],
  [1,21,-17,63,-78,22,164,-16,44,24,-16,164,-232,-152,8],
  [1,21,3,-5,46,42,-44,-64,-28,40,96,12,-24,8,-104],
  [1,8+ER(17),22-3*ER(17),13-2*ER(17),-12-8*ER(17),8+4*ER(17),
   -60-12*ER(17),-20+12*ER(17),16+8*ER(17),24,-64-8*ER(17),
   -16+8*ER(17),24-8*ER(17),-8+24*ER(17),64-16*ER(17)],
  [1,4-3*ER(17),3+2*ER(17),-22+3*ER(17),12+8*ER(17),8-4*ER(17),
   -10-10*ER(17),72+8*ER(17),-28+12*ER(17),-28+12*ER(17),
   -6+2*ER(17),46+6*ER(17),10-6*ER(17),-94-14*ER(17),32-16*ER(17)],
 [1,8-ER(17),22+3*ER(17),13+2*ER(17),-12+8*ER(17),8-4*ER(17),
   -60+12*ER(17),-20-12*ER(17),16-8*ER(17),24,-64+8*ER(17),
   -16-8*ER(17),24+8*ER(17),-8-24*ER(17),64+16*ER(17)],
  [1,4+3*ER(17),3-2*ER(17),-22-3*ER(17),12-8*ER(17),8+4*ER(17),
   -10+10*ER(17),72-8*ER(17),-28-12*ER(17),-28-12*ER(17),
   -6-2*ER(17),46-6*ER(17),10+6*ER(17),-94+14*ER(17),32+16*ER(17)],
  [1,9,-3,13,4,-12,28,32,80,-80,12,-60,84,-28,-80],
  [1,-3-2*EY(9)-GaloisCyc(EY(9),2),6-4*EY(9)-14*GaloisCyc(EY(9),2),
   1-3*EY(9)+9*GaloisCyc(EY(9),2),10-22*EY(9)-8*GaloisCyc(EY(9),2),
   27*EY(9)+12*GaloisCyc(EY(9),2),40+6*EY(9)-12*GaloisCyc(EY(9),2),
   14+10*EY(9)+8*GaloisCyc(EY(9),2),-34+3*EY(9)-27*GaloisCyc(EY(9),2),
   19+34*EY(9)+20*GaloisCyc(EY(9),2),-30+7*EY(9)-4*GaloisCyc(EY(9),2),
   -12-30*EY(9)-3*GaloisCyc(EY(9),2),-6+18*EY(9)+54*GaloisCyc(EY(9),2),
   38-36*EY(9)-24*GaloisCyc(EY(9),2),-44-8*EY(9)-10*GaloisCyc(EY(9),2)],
  [1,-3+EY(9)+2*GaloisCyc(EY(9),2),6-10*EY(9)+4*GaloisCyc(EY(9),2),
   1+12*EY(9)+3*GaloisCyc(EY(9),2),10+14*EY(9)+22*GaloisCyc(EY(9),2),
   -15*EY(9)-27*GaloisCyc(EY(9),2),40-18*EY(9)-6*GaloisCyc(EY(9),2),
   14-2*EY(9)-10*GaloisCyc(EY(9),2),-34-30*EY(9)-3*GaloisCyc(EY(9),2),
   19-14*EY(9)-34*GaloisCyc(EY(9),2),-30-11*EY(9)-7*GaloisCyc(EY(9),2),
   -12+27*EY(9)+30*GaloisCyc(EY(9),2),-6+36*EY(9)-18*GaloisCyc(EY(9),2),
   38+12*EY(9)+36*GaloisCyc(EY(9),2),-44-2*EY(9)+8*GaloisCyc(EY(9),2)],
  [1,-3+EY(9)-GaloisCyc(EY(9),2),6+14*EY(9)+10*GaloisCyc(EY(9),2),
   1-9*EY(9)-12*GaloisCyc(EY(9),2),10+8*EY(9)-14*GaloisCyc(EY(9),2),
   -12*EY(9)+15*GaloisCyc(EY(9),2),40+12*EY(9)+18*GaloisCyc(EY(9),2),
   14-8*EY(9)+2*GaloisCyc(EY(9),2),-34+27*EY(9)+30*GaloisCyc(EY(9),2),
   19-20*EY(9)+14*GaloisCyc(EY(9),2),-30+4*EY(9)+11*GaloisCyc(EY(9),2),
   -12+3*EY(9)-27*GaloisCyc(EY(9),2),-6-54*EY(9)-36*GaloisCyc(EY(9),2),
   38+24*EY(9)-12*GaloisCyc(EY(9),2),-44+10*EY(9)+2*GaloisCyc(EY(9),2)],
  [1,3,-15,-5,-8,-48,-8,8,8,40,24,-24,-24,8,40],
  [1,-9,-12,13,22,42,-26,14,-1,-44,21,-33,-78,26,64],
  [1,-7,-15,-15,12,12,12,-72,48,0,-36,36,36,-12,0],
  [1,-9,13,3,-48,-8,-16,-16,-16,-24,56,32,32,16,-16]]]];

MULTFREEINFO.("McL.2"):= ["$McL.2$",
##
[[1,3,7],"$U_4(3).2_3$",
 [[1,112,162],
  [1,-28,27],
  [1,2,-3]]],
##
[[1,2,3,4,7,8],"$U_4(3) \\leq U_4(3).2_3$",
 [[1,1,112,112,162,162],
  [1,-1,-112,112,162,-162],
  [1,1,-28,-28,27,27],
  [1,-1,28,-28,27,-27],
  [1,1,2,2,-3,-3],
  [1,-1,-2,2,-3,3]]],
##
[[1,2,3,4,7,8,14,15],"$M_{22}$",
 [[1,22,176,330,462,672,1155,1232],
  [1,-22,-176,330,462,-672,-1155,1232],
  [1,-13,76,-120,147,-168,105,-28],
  [1,13,-76,-120,147,168,-105,-28],
  [1,7,26,30,27,12,-45,-58],
  [1,-7,-26,30,27,-12,45,-58],
  [1,4,-4,-3,-6,-12,12,8],
  [1,-4,4,-3,-6,12,-12,8]]],
##
[[1,4,7,14,24],"$U_3(5).2$",
 [[1,252,750,2625,3500],
  [1,-126,300,-525,350],
  [1,54,90,-15,-130],
  [1,-18,12,51,-46],
  [1,4,-10,-15,20]]],
##
[[1,2,3,4,7,8,14,15,24,25],"$U_3(5) \\leq U_3(5).2$",
 [[1,1,252,252,750,750,2625,2625,3500,3500],
  [1,-1,252,-252,-750,750,2625,-2625,-3500,3500],
  [1,-1,-126,126,-300,300,-525,525,-350,350],
  [1,1,-126,-126,300,300,-525,-525,350,350],
  [1,1,54,54,90,90,-15,-15,-130,-130],
  [1,-1,54,-54,-90,90,-15,15,130,-130],
  [1,1,-18,-18,12,12,51,51,-46,-46],
  [1,-1,-18,18,-12,12,51,-51,46,-46],
  [1,1,4,4,-10,-10,-15,-15,20,20],
  [1,-1,4,-4,10,-10,-15,15,-20,20]]],
##
[[1,7,20,24,26],"$3^{1+4}:4S_5$",
 [[1,90,1215,2430,11664],
  [1,35,225,-45,-216],
  [1,-1,-3,-69,72],
  [1,10,-25,30,-16],
  [1,-10,15,30,-36]]],
##
[[1,2,7,8,20,21,24,25,26,27],"$3^{1+4}:2S_5 \\leq 3^{1+4}:4S_5$",
 [[1,1,90,90,1215,1215,2430,2430,11664,11664],
  [1,-1,90,-90,1215,-1215,2430,-2430,11664,-11664],
  [1,1,35,35,225,225,-45,-45,-216,-216],
  [1,-1,35,-35,225,-225,-45,45,-216,216],
  [1,1,-1,-1,-3,-3,-69,-69,72,72],
  [1,-1,-1,1,-3,3,-69,69,72,-72],
  [1,1,10,10,-25,-25,30,30,-16,-16],
  [1,-1,10,-10,-25,25,30,-30,-16,16],
  [1,1,-10,-10,15,15,30,30,-36,-36],
  [1,-1,-10,10,15,-15,30,-30,-36,36]]],
##
[[1,6,7,20,24,26,27,31],"$3^{1+4}:2S_5 \\leq 3^{1+4}:4S_5$",
 [[1,1,180,1215,1215,4860,11664,11664],
  [1,-1,0,45,-45,0,864,-864],
  [1,1,70,225,225,-90,-216,-216],
  [1,1,-2,-3,-3,-138,72,72],
  [1,1,20,-25,-25,60,-16,-16],
  [1,1,-20,15,15,60,-36,-36],
  [1,-1,0,45,-45,0,-36,36],
  [1,-1,0,-27,27,0,0,0]]],
##
[[1,7,14,24,26,30],"$2.S_8$",
 [[1,210,2240,5040,6720,8064],
  [1,45,260,90,-540,144],
  [1,39,-28,72,60,-144],
  [1,-5,60,-60,60,-56],
  [1,-15,-10,90,-30,-36],
  [1,3,-28,-36,-12,72]]],
##
[[1,2,7,8,14,15,24,25,26,27,30,31],"$2.A_8 \\leq 2.S_8$",
 [[1,1,210,210,2240,2240,5040,5040,6720,6720,8064,8064],
  [1,-1,-210,210,-2240,2240,5040,-5040,-6720,6720,-8064,8064],
  [1,1,45,45,260,260,90,90,-540,-540,144,144],
  [1,-1,-45,45,-260,260,90,-90,540,-540,-144,144],
  [1,1,39,39,-28,-28,72,72,60,60,-144,-144],
  [1,-1,-39,39,28,-28,72,-72,-60,60,144,-144],
  [1,1,-5,-5,60,60,-60,-60,60,60,-56,-56],
  [1,-1,5,-5,-60,60,-60,60,-60,60,56,-56],
  [1,1,-15,-15,-10,-10,90,90,-30,-30,-36,-36],
  [1,-1,15,-15,10,-10,90,-90,30,-30,36,-36],
  [1,1,3,3,-28,-28,-36,-36,-12,-12,72,72],
  [1,-1,-3,3,28,-28,-36,36,12,-12,-72,72]]]];

MULTFREEINFO.("He.2"):= ["$He.2$",
##
[[1,3,5,9],"$S_4(4).4$",
 [[1,272,425,1360],
  [1,-36,75,-40],
  [1,20,5,-26],
  [1,-8,-9,16]]],
##
[[1,3,5,8,11,15],"$2^2.L_3(4).D_{12}$",
 [[1,105,720,1344,1680,4480],
  [1,35,-120,224,-140,0],
  [1,21,6,0,84,-112],
  [1,7,48,0,-56,0],
  [1,-14,6,35,14,-42],
  [1,0,-15,-21,0,35]]],
##
[[1,3,5,7,8,11,15,17],"$2^2.L_3(4).S_3 \\leq 2^2.L_3(4).D_{12}$",
 [[1,1,210,1344,1344,1440,3360,8960],
  [1,1,70,224,224,-240,-280,0],
  [1,1,42,0,0,12,168,-224],
  [1,-1,0,-64,64,0,0,0],
  [1,1,14,0,0,96,-112,0],
  [1,1,-28,35,35,12,28,-84],
  [1,1,0,-21,-21,-30,0,70],
  [1,-1,0,21,-21,0,0,0]]],
##
[[1,3,5,7,8,11,15,18],"$2^2.L_3(4).6 \\leq 2^2.L_3(4).D_{12}$",
 [[1,1,210,1344,1344,1440,3360,8960],
  [1,1,70,224,224,-240,-280,0],
  [1,1,42,0,0,12,168,-224],
  [1,-1,0,64,-64,0,0,0],
  [1,1,14,0,0,96,-112,0],
  [1,1,-28,35,35,12,28,-84],
  [1,1,0,-21,-21,-30,0,70],
  [1,-1,0,-21,21,0,0,0]]]];

MULTFREEINFO.("Suz.2"):= ["$Suz.2$",
##
[[1,7,9],"$G_2(4).2$",
 [[1,416,1365],
  [1,20,-21],
  [1,-16,15]]],
##
[[1,2,7,8,9,10],"$G_2(4) \\leq G_2(4).2$",
 [[1,1,416,416,1365,1365],
  [1,-1,416,-416,-1365,1365],
  [1,1,20,20,-21,-21],
  [1,-1,20,-20,21,-21],
  [1,1,-16,-16,15,15],
  [1,-1,-16,16,-15,15]]],
##
[[1,5,7,14,23],"$3.U_4(3).2^2$",
 [[1,280,486,8505,13608],
  [1,80,-54,405,-432],
  [1,-28,90,189,-252],
  [1,20,18,-75,36],
  [1,-8,-10,9,8]]],
##
[[1,2,5,6,7,8,14,15,23,24],"$3.U_4(3).2_3^{\\prime} \\leq 3.U_4(3).2^2$",
 [[1,1,280,280,486,486,8505,8505,13608,13608],
  [1,-1,-280,280,486,-486,-8505,8505,-13608,13608],
  [1,1,80,80,-54,-54,405,405,-432,-432],
  [1,-1,-80,80,-54,54,-405,405,432,-432],
  [1,1,-28,-28,90,90,189,189,-252,-252],
  [1,-1,28,-28,90,-90,-189,189,252,-252],
  [1,1,20,20,18,18,-75,-75,36,36],
  [1,-1,-20,20,18,-18,75,-75,-36,36],
  [1,1,-8,-8,-10,-10,9,9,8,8],
  [1,-1,8,-8,-10,10,-9,9,-8,8]]],
##
[[1,3,5,7,14,16,18,23],"$3.U_4(3).2_3 \\leq 3.U_4(3).2^2$",
 [[1,1,486,486,560,8505,8505,27216],
  [1,-1,-162,162,0,945,-945,0],
  [1,1,-54,-54,160,405,405,-864],
  [1,1,90,90,-56,189,189,-504],
  [1,1,18,18,40,-75,-75,72],
  [1,-1,-18,18,0,-63,63,0],
  [1,-1,18,-18,0,45,-45,0],
  [1,1,-10,-10,-16,9,9,16]]],
##
[[1,4,5,7,14,17,19,23],"$3.U_4(3).2_1 \\leq 3.U_4(3).2^2$",
 [[1,1,486,486,560,8505,8505,27216],
  [1,-1,-162,162,0,945,-945,0],
  [1,1,-54,-54,160,405,405,-864],
  [1,1,90,90,-56,189,189,-504],
  [1,1,18,18,40,-75,-75,72],
  [1,-1,-18,18,0,-63,63,0],
  [1,-1,18,-18,0,45,-45,0],
  [1,1,-10,-10,-16,9,9,16]]],
##
[[1,2,3,4,5,6,7,8,14,15,16,17,18,19,23,24],"$3.U_4(3) \\leq 3.U_4(3).2^2$",
 [[1,1,1,1,486,486,486,486,560,560,8505,8505,8505,8505,27216,27216],
  [1,-1,1,-1,-486,486,-486,486,560,-560,-8505,8505,8505,-8505,-27216,27216],
  [1,1,-1,-1,-162,-162,162,162,0,0,-945,-945,945,945,0,0],
  [1,-1,-1,1,162,-162,-162,162,0,0,945,-945,945,-945,0,0],
  [1,1,1,1,-54,-54,-54,-54,160,160,405,405,405,405,-864,-864],
  [1,-1,1,-1,54,-54,54,-54,160,-160,-405,405,405,-405,864,-864],
  [1,1,1,1,90,90,90,90,-56,-56,189,189,189,189,-504,-504],
  [1,-1,1,-1,-90,90,-90,90,-56,56,-189,189,189,-189,504,-504],
  [1,1,1,1,18,18,18,18,40,40,-75,-75,-75,-75,72,72],
  [1,-1,1,-1,-18,18,-18,18,40,-40,75,-75,-75,75,-72,72],
  [1,1,-1,-1,-18,-18,18,18,0,0,63,63,-63,-63,0,0],
  [1,-1,-1,1,18,-18,-18,18,0,0,-63,63,-63,63,0,0],
  [1,1,-1,-1,18,18,-18,-18,0,0,-45,-45,45,45,0,0],
  [1,-1,-1,1,-18,18,18,-18,0,0,45,-45,45,-45,0,0],
  [1,1,1,1,-10,-10,-10,-10,-16,-16,9,9,9,9,16,16],
  [1,-1,1,-1,10,-10,10,-10,-16,16,-9,9,9,-9,-16,16]]],
##
[[1,4,5,14,19,21],"$U_5(2).2$",
 [[1,891,1980,2816,6336,20736],
  [1,243,-180,512,-576,0],
  [1,-99,330,176,-264,-144],
  [1,33,30,8,96,-168],
  [1,-27,-30,32,24,0],
  [1,9,6,-40,-48,72]]],
##
[[1,2,3,4,5,6,14,15,18,19,20,21],"$U_5(2) \\leq U_5(2).2$",
 [[1,1,891,891,1980,1980,2816,2816,6336,6336,20736,20736],
  [1,-1,891,-891,1980,-1980,-2816,2816,6336,-6336,20736,-20736],
  [1,-1,243,-243,-180,180,-512,512,-576,576,0,0],
  [1,1,243,243,-180,-180,512,512,-576,-576,0,0],
  [1,1,-99,-99,330,330,176,176,-264,-264,-144,-144],
  [1,-1,-99,99,330,-330,-176,176,-264,264,-144,144],
  [1,1,33,33,30,30,8,8,96,96,-168,-168],
  [1,-1,33,-33,30,-30,-8,8,96,-96,-168,168],
  [1,-1,-27,27,-30,30,-32,32,24,-24,0,0],
  [1,1,-27,-27,-30,-30,32,32,24,24,0,0],
  [1,-1,9,-9,6,-6,40,-40,-48,48,72,-72],
  [1,1,9,9,6,6,-40,-40,-48,-48,72,72]]],
##
[[1,4,7,11,14,21,26,27,38],"$2^{1+6}_-.U_4(2).2$",
 [[1,54,360,1728,5120,9216,17280,46080,55296],
  [1,-27,90,432,800,-1152,-2160,-1440,3456],
  [1,21,30,276,-160,768,120,-1440,384],
  [1,3,-60,132,200,48,-60,360,-624],
  [1,15,48,12,128,-144,276,-96,-240],
  [1,-9,24,-36,80,144,-108,48,-144],
  [1,-11,10,48,-80,-64,80,80,-64],
  [1,9,6,0,-64,0,-144,192,0],
  [1,0,-12,-18,8,-9,36,-96,90]]],
##
[[1,2,3,4,7,8,11,12,14,15,20,21,25,26,27,28,38,39],
 "$2^{1+6}_-.U_4(2) \\leq 2^{1+6}_-.U_4(2).2$",
 [[1,1,54,54,360,360,1728,1728,5120,5120,9216,9216,17280,17280,
   46080,46080,55296,55296],
  [1,-1,54,-54,-360,360,-1728,1728,5120,-5120,-9216,9216,17280,-17280,
   -46080,46080,-55296,55296],
  [1,-1,-27,27,-90,90,-432,432,800,-800,1152,-1152,-2160,2160,1440,-1440,
   -3456,3456],
  [1,1,-27,-27,90,90,432,432,800,800,-1152,-1152,-2160,-2160,-1440,-1440,
   3456,3456],
  [1,1,21,21,30,30,276,276,-160,-160,768,768,120,120,-1440,-1440,384,384],
  [1,-1,21,-21,-30,30,-276,276,-160,160,-768,768,120,-120,1440,-1440,-384,384],
  [1,1,3,3,-60,-60,132,132,200,200,48,48,-60,-60,360,360,-624,-624],
  [1,-1,3,-3,60,-60,-132,132,200,-200,-48,48,-60,60,-360,360,624,-624],
  [1,1,15,15,48,48,12,12,128,128,-144,-144,276,276,-96,-96,-240,-240],
  [1,-1,15,-15,-48,48,-12,12,128,-128,144,-144,276,-276,96,-96,240,-240],
  [1,-1,-9,9,-24,24,36,-36,80,-80,-144,144,-108,108,-48,48,144,-144],
  [1,1,-9,-9,24,24,-36,-36,80,80,144,144,-108,-108,48,48,-144,-144],
  [1,-1,-11,11,-10,10,-48,48,-80,80,64,-64,80,-80,-80,80,64,-64],
  [1,1,-11,-11,10,10,48,48,-80,-80,-64,-64,80,80,80,80,-64,-64],
  [1,1,9,9,6,6,0,0,-64,-64,0,0,-144,-144,192,192,0,0],
  [1,-1,9,-9,-6,6,0,0,-64,64,0,0,-144,144,-192,192,0,0],
  [1,1,0,0,-12,-12,-18,-18,8,8,-9,-9,36,36,-96,-96,90,90],
  [1,-1,0,0,12,-12,18,-18,8,-8,9,-9,36,-36,96,-96,-90,90]]],
##
[[1,5,6,14,19,21,22,23,33,48],"$3^5:(M_{11} \\times 2)$",
 [[1,165,891,2916,5346,17820,32076,40095,53460,80190],
  [1,65,291,36,-594,1020,-1764,3195,-540,-1710],
  [1,-55,99,-540,198,1980,-1188,-1485,-1980,2970],
  [1,35,111,-48,198,-120,408,-75,-360,-150],
  [1,-25,39,0,-162,120,432,-135,0,-270],
  [1,11,-33,144,54,264,72,-99,-216,-198],
  [1,-19,27,36,90,-36,-180,-9,180,-90],
  [1,21,27,36,-110,-36,-180,-369,340,270],
  [1,5,-21,-60,18,60,12,15,180,-210],
  [1,-1,-9,0,-18,-72,0,81,-144,162]]],
##
[[1,5,7,9,14,19,21,23,27,38,40,44,47],"$2^{4+6}:3S_6$",
 [[1,60,480,1536,1920,6144,6144,20480,23040,23040,46080,92160,184320],
  [1,-15,30,336,120,-96,1104,-1120,-360,-2160,2880,-5040,4320],
  [1,27,84,216,336,864,-192,1472,864,72,-1440,-2880,576],
  [1,15,-60,-156,300,1104,96,-1120,-720,-180,720,1440,-1440],
  [1,21,90,-24,48,-96,216,-112,576,-360,-96,744,-1008],
  [1,-15,30,-96,120,-96,96,320,-360,0,0,0,0],
  [1,-3,18,24,-96,96,264,-16,-144,360,-288,-72,-144],
  [1,7,-36,116,76,-96,48,112,-96,172,240,240,-784],
  [1,15,36,-12,12,-48,-96,-160,-144,252,144,-288,288],
  [1,6,0,6,-42,24,-24,128,-144,-180,9,144,72],
  [1,-9,12,36,12,0,-48,-112,0,-36,-144,144,144],
  [1,-5,0,-16,-20,24,-24,40,120,40,240,-120,-280],
  [1,3,-24,-24,12,-24,24,-40,72,0,-144,-72,216]]],
##
[[1,2,5,6,7,8,9,10,14,15,18,19,20,21,23,24,27,28,38,39,40,41,44,45,47,48],
 "$2^{4+6}:3A_6 \\leq 2^{4+6}:3S_6$",
 [[1,1,60,60,480,480,1536,1536,1920,1920,6144,6144,6144,6144,20480,20480,
  23040,23040,23040,23040,46080,46080,92160,92160,184320,184320],
  [1,-1,-60,60,-480,480,1536,-1536,1920,-1920,-6144,6144,6144,-6144,
  -20480,20480,-23040,23040,23040,-23040,46080,-46080,-92160,92160,
  -184320,184320],
  [1,1,-15,-15,30,30,336,336,120,120,-96,-96,1104,1104,-1120,-1120,
  -360,-360,-2160,-2160,2880,2880,-5040,-5040,4320,4320],
  [1,-1,15,-15,-30,30,336,-336,120,-120,96,-96,1104,-1104,1120,-1120,
  360,-360,-2160,2160,2880,-2880,5040,-5040,-4320,4320],
  [1,1,27,27,84,84,216,216,336,336,864,864,-192,-192,1472,1472,864,864,
  72,72,-1440,-1440,-2880,-2880,576,576],
  [1,-1,-27,27,-84,84,216,-216,336,-336,-864,864,-192,192,-1472,1472,
  -864,864,72,-72,-1440,1440,2880,-2880,-576,576],
  [1,1,15,15,-60,-60,-156,-156,300,300,1104,1104,96,96,-1120,-1120,
  -720,-720,-180,-180,720,720,1440,1440,-1440,-1440],
  [1,-1,-15,15,60,-60,-156,156,300,-300,-1104,1104,96,-96,1120,-1120,
  720,-720,-180,180,720,-720,-1440,1440,1440,-1440],
  [1,1,21,21,90,90,-24,-24,48,48,-96,-96,216,216,-112,-112,576,576,
  -360,-360,-96,-96,744,744,-1008,-1008],
  [1,-1,-21,21,-90,90,-24,24,48,-48,96,-96,216,-216,112,-112,-576,576,
  -360,360,-96,96,-744,744,1008,-1008],
  [1,-1,15,-15,-30,30,-96,96,120,-120,96,-96,96,-96,-320,320,360,-360,
  0,0,0,0,0,0,0,0],
  [1,1,-15,-15,30,30,-96,-96,120,120,-96,-96,96,96,320,320,-360,-360,
  0,0,0,0,0,0,0,0],
  [1,-1,3,-3,-18,18,24,-24,-96,96,-96,96,264,-264,16,-16,144,-144,
  360,-360,-288,288,72,-72,144,-144],
  [1,1,-3,-3,18,18,24,24,-96,-96,96,96,264,264,-16,-16,-144,-144,360,360,
  -288,-288,-72,-72,-144,-144],
  [1,1,7,7,-36,-36,116,116,76,76,-96,-96,48,48,112,112,-96,-96,172,172,
  240,240,240,240,-784,-784],
  [1,-1,-7,7,36,-36,116,-116,76,-76,96,-96,48,-48,-112,112,96,-96,
  172,-172,240,-240,-240,240,784,-784],
  [1,1,15,15,36,36,-12,-12,12,12,-48,-48,-96,-96,-160,-160,-144,-144,
  252,252,144,144,-288,-288,288,288],
  [1,-1,-15,15,-36,36,-12,12,12,-12,48,-48,-96,96,160,-160,144,-144,
  252,-252,144,-144,288,-288,-288,288],
  [1,1,6,6,0,0,6,6,-42,-42,24,24,-24,-24,128,128,-144,-144,-180,-180,
  9,9,144,144,72,72],
  [1,-1,-6,6,0,0,6,-6,-42,42,-24,24,-24,24,-128,128,144,-144,-180,180,
  9,-9,-144,144,-72,72],
  [1,1,-9,-9,12,12,36,36,12,12,0,0,-48,-48,-112,-112,0,0,-36,-36,
  -144,-144,144,144,144,144],
  [1,-1,9,-9,-12,12,36,-36,12,-12,0,0,-48,48,112,-112,0,0,-36,36,
  -144,144,-144,144,-144,144],
  [1,1,-5,-5,0,0,-16,-16,-20,-20,24,24,-24,-24,40,40,120,120,40,40,
  240,240,-120,-120,-280,-280],
  [1,-1,5,-5,0,0,-16,16,-20,20,-24,24,-24,24,-40,40,-120,120,40,-40,
  240,-240,120,-120,280,-280],
  [1,1,3,3,-24,-24,-24,-24,12,12,-24,-24,24,24,-40,-40,72,72,0,0,
  -144,-144,-72,-72,216,216],
  [1,-1,-3,3,24,-24,-24,24,12,-12,24,-24,24,-24,40,-40,-72,72,0,0,
  -144,144,72,-72,-216,216]]]];

MULTFREEINFO.("ON.2"):= ["$ON.2$",
##
[[1,2,3,4,7,8,9,12,13],"$L_3(7).2$",
 [[1,456,5586,6384,11172,32928,52136,58653,78204],
  [1,-456,5586,6384,-11172,-32928,52136,58653,-78204],
  [1,49,196,-106,238,-28,161,-252,-259],
  [1,-49,196,-106,-238,28,161,-252,259],
  [1,-21*ER(2),-21,111,84*ER(2),105*ER(2),161,-252,-168*ER(2)],
  [1,21*ER(2),-21,111,-84*ER(2),-105*ER(2),161,-252,168*ER(2)],
  [1,0,42,48,0,0,-280,189,0],
  [1,4*ER(7),-56,-64,-26*ER(7),80*ER(7),56,63,-58*ER(7)],
  [1,-4*ER(7),-56,-64,26*ER(7),-80*ER(7),56,63,58*ER(7)]]],
##
[[1,2,3,4,7,8,9,10,11,12,13,20,21],"$L_3(7) \\leq L_3(7).2$",
 [[1,1,912,11172,11172,11172,12768,32928,32928,52136,52136,117306,156408],
  [1,1,-912,-11172,-11172,11172,12768,-32928,-32928,52136,52136,
   117306,-156408],
  [1,1,98,238,238,392,-212,-28,-28,161,161,-504,-518],
  [1,1,-98,-238,-238,392,-212,28,28,161,161,-504,518],
  [1,1,-42*ER(2),84*ER(2),84*ER(2),-42,222,105*ER(2),105*ER(2),
   161,161,-504,-336*ER(2)],
  [1,1,42*ER(2),-84*ER(2),-84*ER(2),-42,222,-105*ER(2),-105*ER(2),
   161,161,-504,336*ER(2)],
  [1,1,0,0,0,84,96,0,0,-280,-280,378,0],
  [1,-1,0,-84,84,0,0,-294,294,-343,343,0,0],
  [1,-1,0,84,-84,0,0,294,-294,-343,343,0,0],
  [1,1,8*ER(7),-26*ER(7),-26*ER(7),-112,-128,80*ER(7),80*ER(7),
   56,56,126,-116*ER(7)],
  [1,1,-8*ER(7),26*ER(7),26*ER(7),-112,-128,-80*ER(7),-80*ER(7),
   56,56,126,116*ER(7)],
  [1,-1,0,114,-114,0,0,-96,96,152,-152,0,0],
  [1,-1,0,-114,114,0,0,96,-96,152,-152,0,0]]]];

MULTFREEINFO.("Fi22.2"):= ["$Fi_{22}.2$",
##
[[1,5,13],"$2.U_6(2).2$",
 [[1,693,2816],
  [1,63,-64],
  [1,-9,8]]],
##
[[1,2,5,6,13,14],"$2.U_6(2) \\leq 2.U_6(2).2$",
 [[1,1,693,693,2816,2816],
  [1,-1,-693,693,2816,-2816],
  [1,1,63,63,-64,-64],
  [1,-1,-63,63,-64,64],
  [1,1,-9,-9,8,8],
  [1,-1,9,-9,8,-8]]],
##
[[1,2,5,6,17,18],"$O_7(3)$",
 [[1,364,1080,3159,10920,12636],
  [1,-364,-1080,3159,10920,-12636],
  [1,84,-120,279,-280,36],
  [1,-84,120,279,-280,-36],
  [1,12,24,-9,8,-36],
  [1,-12,-24,-9,8,36]]],
##
[[1,13,17,25],"$O_8^+(2):S_3 \\times 2$",
 [[1,1575,22400,37800],
  [1,171,-64,-108],
  [1,-9,224,-216],
  [1,-9,-64,72]]],
##
[[1,2,13,14,17,18,25,26],"$O_8^+(2):S_3 \\leq O_8^+(2):S_3 \\times 2$",
 [[1,1,1575,1575,22400,22400,37800,37800],
  [1,-1,1575,-1575,-22400,22400,37800,-37800],
  [1,1,171,171,-64,-64,-108,-108],
  [1,-1,171,-171,64,-64,-108,108],
  [1,1,-9,-9,224,224,-216,-216],
  [1,-1,-9,9,-224,224,-216,216],
  [1,1,-9,-9,-64,-64,72,72],
  [1,-1,-9,9,64,-64,72,-72]]],
##
[[1,8,13,15,17,25,29],"$O_8^+(2):3 \\times 2 \\leq O_8^+(2):S_3 \\times 2$",
 [[1,1,1575,1575,22400,22400,75600],
  [1,-1,225,-225,-800,800,0],
  [1,1,171,171,-64,-64,-216],
  [1,-1,-63,63,-224,224,0],
  [1,1,-9,-9,224,224,-432],
  [1,1,-9,-9,-64,-64,144],
  [1,-1,9,-9,64,-64,0]]],
##
[[1,7,13,16,17,25,30],"$O_8^+(2):S_3 \\leq O_8^+(2):S_3 \\times 2$",
 [[1,1,1575,1575,22400,22400,75600],
  [1,-1,-225,225,-800,800,0],
  [1,1,171,171,-64,-64,-216],
  [1,-1,63,-63,-224,224,0],
  [1,1,-9,-9,224,224,-432],
  [1,1,-9,-9,-64,-64,144],
  [1,-1,-9,9,64,-64,0]]],
##
[[1,5,13,17,25,27,33],"$O_8^+(2):2 \\times 2 \\leq O_8^+(2):S_3 \\times 2$",
 [[1,2,1575,3150,22400,44800,113400],
  [1,-1,315,-315,2240,-2240,0],
  [1,2,171,342,-64,-128,-324],
  [1,2,-9,-18,224,448,-648],
  [1,2,-9,-18,-64,-128,216],
  [1,-1,-45,45,80,-80,0],
  [1,-1,27,-27,-64,64,0]]],
##
[[1,2,7,8,13,14,15,16,17,18,25,26,29,30],
"$O_8^+(2):3 \\leq O_8^+(2):S_3 \\times 2$",
 [[1,1,1,1,1575,1575,1575,1575,22400,22400,22400,22400,75600,75600],
  [1,-1,1,-1,-1575,1575,-1575,1575,22400,-22400,22400,-22400,75600,-75600],
  [1,1,-1,-1,-225,-225,225,225,800,800,-800,-800,0,0],
  [1,-1,-1,1,225,-225,-225,225,800,-800,-800,800,0,0],
  [1,1,1,1,171,171,171,171,-64,-64,-64,-64,-216,-216],
  [1,-1,1,-1,-171,171,-171,171,-64,64,-64,64,-216,216],
  [1,-1,-1,1,-63,63,63,-63,224,-224,-224,224,0,0],
  [1,1,-1,-1,63,63,-63,-63,224,224,-224,-224,0,0],
  [1,1,1,1,-9,-9,-9,-9,224,224,224,224,-432,-432],
  [1,-1,1,-1,9,-9,9,-9,224,-224,224,-224,-432,432],
  [1,1,1,1,-9,-9,-9,-9,-64,-64,-64,-64,144,144],
  [1,-1,1,-1,9,-9,9,-9,-64,64,-64,64,144,-144],
  [1,-1,-1,1,9,-9,-9,9,-64,64,64,-64,0,0],
  [1,1,-1,-1,-9,-9,9,9,-64,-64,64,64,0,0]]],
##
[[1,2,5,6,13,14,17,18,25,26,27,28,33,34],
"$O_8^+(2):2 \\leq O_8^+(2):S_3 \\times 2$",
 [[1,1,2,2,1575,1575,3150,3150,22400,22400,44800,44800,113400,113400],
  [1,-1,2,-2,-1575,1575,-3150,3150,22400,-22400,44800,-44800,-113400,113400],
  [1,1,-1,-1,315,315,-315,-315,2240,2240,-2240,-2240,0,0],
  [1,-1,-1,1,-315,315,315,-315,2240,-2240,-2240,2240,0,0],
  [1,1,2,2,171,171,342,342,-64,-64,-128,-128,-324,-324],
  [1,-1,2,-2,-171,171,-342,342,-64,64,-128,128,324,-324],
  [1,1,2,2,-9,-9,-18,-18,224,224,448,448,-648,-648],
  [1,-1,2,-2,9,-9,18,-18,224,-224,448,-448,648,-648],
  [1,1,2,2,-9,-9,-18,-18,-64,-64,-128,-128,216,216],
  [1,-1,2,-2,9,-9,18,-18,-64,64,-128,128,-216,216],
  [1,1,-1,-1,-45,-45,45,45,80,80,-80,-80,0,0],
  [1,-1,-1,1,45,-45,-45,45,80,-80,-80,80,0,0],
  [1,1,-1,-1,27,27,-27,-27,-64,-64,64,64,0,0],
  [1,-1,-1,1,-27,27,27,-27,-64,64,64,-64,0,0]]],
##
[[1,5,6,7,13,16,17,25,27,28,30,33,34],
"$O_8^+(2):2 \\leq O_8^+(2):S_3 \\times 2$",
 [[1,1,2,2,1575,1575,3150,3150,22400,22400,44800,44800,226800],
  [1,1,-1,-1,315,315,-315,-315,2240,2240,-2240,-2240,0],
  [1,-1,-1,1,315,-315,315,-315,-2240,2240,-2240,2240,0],
  [1,-1,2,-2,-225,225,450,-450,-800,800,1600,-1600,0],
  [1,1,2,2,171,171,342,342,-64,-64,-128,-128,-648],
  [1,-1,2,-2,63,-63,-126,126,-224,224,448,-448,0],
  [1,1,2,2,-9,-9,-18,-18,224,224,448,448,-1296],
  [1,1,2,2,-9,-9,-18,-18,-64,-64,-128,-128,432],
  [1,1,-1,-1,-45,-45,45,45,80,80,-80,-80,0],
  [1,-1,-1,1,-45,45,-45,45,-80,80,-80,80,0],
  [1,-1,2,-2,-9,9,18,-18,64,-64,-128,128,0],
  [1,1,-1,-1,27,27,-27,-27,-64,-64,64,64,0],
  [1,-1,-1,1,27,-27,27,-27,64,-64,64,-64,0]]],
##
[[1,3,5,9,13,19,21,33],"$2^{10}:M_{22}.2$",
 [[1,154,1024,3696,4928,11264,42240,78848],
  [1,-77,-320,924,1232,-1408,-5280,4928],
  [1,49,-176,546,-532,1184,-960,-112],
  [1,-35,160,294,-364,-400,120,224],
  [1,37,88,186,248,32,120,-712],
  [1,13,-32,6,-28,-112,120,32],
  [1,-17,-20,24,32,32,120,-172],
  [1,1,16,-30,-4,32,-96,80]]],
##
[[1,2,3,4,5,6,9,10,13,14,19,20,21,22,33,34],
"$2^{10}:M_{22} \\leq 2^{10}:M_{22}.2$",
 [[1,1,154,154,1024,1024,3696,3696,4928,4928,11264,11264,42240,42240,
  78848,78848],
  [1,-1,-154,154,1024,-1024,3696,-3696,-4928,4928,-11264,11264,
   42240,-42240,-78848,78848],
  [1,1,-77,-77,-320,-320,924,924,1232,1232,-1408,-1408,-5280,-5280,4928,4928],
  [1,-1,77,-77,-320,320,924,-924,-1232,1232,1408,-1408,-5280,5280,-4928,4928],
  [1,1,49,49,-176,-176,546,546,-532,-532,1184,1184,-960,-960,-112,-112],
  [1,-1,-49,49,-176,176,546,-546,532,-532,-1184,1184,-960,960,112,-112],
  [1,1,-35,-35,160,160,294,294,-364,-364,-400,-400,120,120,224,224],
  [1,-1,35,-35,160,-160,294,-294,364,-364,400,-400,120,-120,-224,224],
  [1,1,37,37,88,88,186,186,248,248,32,32,120,120,-712,-712],
  [1,-1,-37,37,88,-88,186,-186,-248,248,-32,32,120,-120,712,-712],
  [1,1,13,13,-32,-32,6,6,-28,-28,-112,-112,120,120,32,32],
  [1,-1,-13,13,-32,32,6,-6,28,-28,112,-112,120,-120,-32,32],
  [1,1,-17,-17,-20,-20,24,24,32,32,32,32,120,120,-172,-172],
  [1,-1,17,-17,-20,20,24,-24,-32,32,-32,32,120,-120,172,-172],
  [1,1,1,1,16,16,-30,-30,-4,-4,32,32,-96,-96,80,80],
  [1,-1,-1,1,16,-16,-30,30,4,-4,-32,32,-96,96,-80,80]]],
##
[[1,5,9,13,17,19,25,33,46,52],"$2^7:S_6(2)$",
 [[1,135,1260,2304,8640,10080,45360,143360,241920,241920],
  [1,-15,210,624,-960,1680,1260,8960,-1680,-10080],
  [1,-27,126,-288,216,1008,-2268,-1792,6048,-3024],
  [1,57,246,120,840,96,1368,-1408,120,-1440],
  [1,3,-60,192,192,312,-576,-256,-960,1152],
  [1,21,30,-96,-168,240,180,-256,-672,720],
  [1,27,36,0,0,-144,-432,512,0,0],
  [1,-15,66,48,-96,-48,-36,-256,48,288],
  [1,-9,0,-36,72,0,0,224,-252,0],
  [1,3,-24,12,-24,-12,72,-112,228,-144]]],
##
[[1,2,5,6,9,10,13,14,17,18,19,20,25,26,33,34,46,47,52,53],
"$2^6:S_6(2) \\leq 2^7:S_6(2)$",
 [[1,1,135,135,1260,1260,2304,2304,8640,8640,10080,10080,45360,45360,
   143360,143360,241920,241920,241920,241920],
  [1,-1,135,-135,-1260,1260,2304,-2304,8640,-8640,-10080,10080,
   -45360,45360,143360,-143360,241920,241920,-241920,-241920],
  [1,1,-15,-15,210,210,624,624,-960,-960,1680,1680,1260,1260,8960,8960,
   -10080,-1680,-1680,-10080],
  [1,-1,-15,15,-210,210,624,-624,-960,960,-1680,1680,-1260,1260,
   8960,-8960,-10080,-1680,1680,10080],
  [1,1,-27,-27,126,126,-288,-288,216,216,1008,1008,-2268,-2268,
   -1792,-1792,-3024,6048,6048,-3024],
  [1,-1,-27,27,-126,126,-288,288,216,-216,-1008,1008,2268,-2268,
   -1792,1792,-3024,6048,-6048,3024],
  [1,1,57,57,246,246,120,120,840,840,96,96,1368,1368,-1408,-1408,
   -1440,120,120,-1440],
  [1,-1,57,-57,-246,246,120,-120,840,-840,-96,96,-1368,1368,-1408,1408,
   -1440,120,-120,1440],
  [1,1,3,3,-60,-60,192,192,192,192,312,312,-576,-576,-256,-256,1152,
   -960,-960,1152],
  [1,-1,3,-3,60,-60,192,-192,192,-192,-312,312,576,-576,-256,256,1152,
   -960,960,-1152],
  [1,1,21,21,30,30,-96,-96,-168,-168,240,240,180,180,-256,-256,720,
   -672,-672,720],
  [1,-1,21,-21,-30,30,-96,96,-168,168,-240,240,-180,180,-256,256,720,
   -672,672,-720],
  [1,1,27,27,36,36,0,0,0,0,-144,-144,-432,-432,512,512,0,0,0,0],
  [1,-1,27,-27,-36,36,0,0,0,0,144,-144,432,-432,512,-512,0,0,0,0],
  [1,1,-15,-15,66,66,48,48,-96,-96,-48,-48,-36,-36,-256,-256,288,48,48,288],
  [1,-1,-15,15,-66,66,48,-48,-96,96,48,-48,36,-36,-256,256,288,48,-48,-288],
  [1,1,-9,-9,0,0,-36,-36,72,72,0,0,0,0,224,224,0,-252,-252,0],
  [1,-1,-9,9,0,0,-36,36,72,-72,0,0,0,0,224,-224,0,-252,252,0],
  [1,1,3,3,-24,-24,12,12,-24,-24,-12,-12,72,72,-112,-112,-144,228,228,-144],
  [1,-1,3,-3,24,-24,12,-12,-24,24,12,-12,-72,72,-112,112,-144,228,-228,144]]],
##
[[1,7,9,17,19,49,58,68,75,88],"${^2F_4(2)^{\\prime}}.2$",
 [[1,1755,11700,14976,140400,166400,187200,374400,449280,2246400],
  [1,-405,900,-576,-10800,-6400,14400,-14400,17280,0],
  [1,-189,1980,-576,4320,10880,-7200,-14400,13824,-8640],
  [1,171,612,-864,1008,1664,3456,3744,-576,-9216],
  [1,99,540,576,-1440,-640,-1440,2880,2304,-2880],
  [1,75,-60,192,624,-256,384,-576,384,-768],
  [1,27,36,-144,0,-352,-288,-144,0,864],
  [1,-21,132,96,-48,128,192,-288,-960,768],
  [1,27,-108,0,-432,512,0,0,0,0],
  [1,-45,-36,0,144,-64,0,288,288,-576]]]];

MULTFREEINFO.("HN.2"):= ["$HN.2$",
##
[[1,3,4,6,9,13,15,20,24,27],"$S_{12}$",
 [[1,462,5040,10395,16632,30800,69300,311850,332640,362880],
  [1,-198,0,2475,792,4400,-9900,-14850,0,17280],
  [1,132,-1080,1485,-1188,1100,4950,0,-11880,6480],
  [1,12,240,495,1332,-2200,300,-900,-2160,2880],
  [1,82,480,515,-88,400,900,-1650,1280,-1920],
  [1,62,-240,155,632,400,-300,1050,160,-1920],
  [1,-48,0,225,-108,-100,-150,900,0,-720],
  [1,12,60,-45,-18,50,-150,450,-540,180],
  [1,-18,0,-45,72,80,180,-270,0,0],
  [1,12,-40,5,-68,-100,-50,-200,360,80]]],
##
[[1,3,4,6,9,11,13,15,20,24,27,29,36,47,49,51,63],"$S_{11} \\leq S_{12}$",
 [[1,11,2772,2772,16632,20790,60480,83160,99792,103950,362880,369600,
   831600,1247400,2494800,3991680,3991680],
  [1,11,-1188,-1188,792,4950,0,3960,4752,24750,17280,52800,-118800,
   -59400,-118800,190080,0],
  [1,11,792,792,-1188,2970,-12960,-5940,-7128,14850,6480,13200,59400,
   0,0,71280,-142560],
  [1,11,72,72,1332,990,2880,6660,7992,4950,2880,-26400,3600,-3600,-7200,
   31680,-25920],
  [1,11,492,492,-88,1030,5760,-440,-528,5150,-1920,4800,10800,-6600,
   -13200,-21120,15360],
  [1,-1,-168,168,1428,1050,0,2100,-3528,-1050,-10080,0,0,25200,-25200,
   10080,0],
  [1,11,372,372,632,310,-2880,3160,3792,1550,-1920,4800,-3600,4200,
   8400,-21120,1920],
  [1,11,-288,-288,-108,450,0,-540,-648,2250,-720,-1200,-1800,3600,
   7200,-7920,0],
  [1,11,72,72,-18,-90,720,-90,-108,-450,180,600,-1800,1800,3600,1980,-6480],
  [1,11,-108,-108,72,-90,0,360,432,-450,0,960,2160,-1080,-2160,0,0],
  [1,11,72,72,-68,10,-480,-340,-408,50,80,-1200,-600,-800,-1600,880,4320],
  [1,-1,-72,72,180,90,0,468,-648,-90,1440,0,0,-720,720,-1440,0],
  [1,-1,72,-72,68,250,0,100,-168,-250,-480,0,0,-1200,1200,480,0],
  [1,-1,12,-12,208,-50,0,-400,192,50,320,0,0,400,-400,-320,0],
  [1,-1,36,-36,-144,-18,0,144,0,18,576,0,0,1008,-1008,-576,0],
  [1,-1,-48,48,-102,150,0,-150,252,-150,-180,0,0,0,0,180,0],
  [1,-1,-8,8,-12,-150,0,100,-88,150,-480,0,0,-400,400,480,0]]],
##
[[1,6,9,11,13,18,20,24,29],"$4.HS.2$",
 [[1,1408,2200,5775,35200,123200,277200,354816,739200],
  [1,208,-50,525,2200,-2800,-6300,2016,4200],
  [1,-112,300,75,1000,-2200,3600,-864,-1800],
  [1,208,100,-525,1000,1400,0,2016,-4200],
  [1,128,200,375,0,1600,0,-2304,0],
  [1,-47,-50,0,250,350,0,-504,0],
  [1,28,-50,75,-50,-100,450,396,-750],
  [1,-32,40,15,-80,80,-360,576,-240],
  [1,16,4,-45,-56,-136,0,-288,504]]],
##
[[1,2,6,7,9,10,11,12,13,14,18,19,20,21,24,25,29,30],"$2.HS.2 \\leq 4.HS.2$",
 [[1,1,1408,1408,2200,2200,5775,5775,35200,35200,123200,123200,
   277200,277200,354816,354816,739200,739200],
  [1,-1,-1408,1408,2200,-2200,-5775,5775,35200,-35200,-123200,123200,
   277200,-277200,354816,-354816,-739200,739200],
  [1,1,208,208,-50,-50,525,525,2200,2200,-2800,-2800,-6300,-6300,
   2016,2016,4200,4200],
  [1,-1,-208,208,-50,50,-525,525,2200,-2200,2800,-2800,-6300,6300,
   2016,-2016,-4200,4200],
  [1,1,-112,-112,300,300,75,75,1000,1000,-2200,-2200,3600,3600,-864,-864,
   -1800,-1800],
  [1,-1,112,-112,300,-300,-75,75,1000,-1000,2200,-2200,3600,-3600,
   -864,864,1800,-1800],
  [1,1,208,208,100,100,-525,-525,1000,1000,1400,1400,0,0,2016,2016,
   -4200,-4200],
  [1,-1,-208,208,100,-100,525,-525,1000,-1000,-1400,1400,0,0,2016,-2016,
   4200,-4200],
  [1,1,128,128,200,200,375,375,0,0,1600,1600,0,0,-2304,-2304,0,0],
  [1,-1,-128,128,200,-200,-375,375,0,0,-1600,1600,0,0,-2304,2304,0,0],
  [1,1,-47,-47,-50,-50,0,0,250,250,350,350,0,0,-504,-504,0,0],
  [1,-1,47,-47,-50,50,0,0,250,-250,-350,350,0,0,-504,504,0,0],
  [1,1,28,28,-50,-50,75,75,-50,-50,-100,-100,450,450,396,396,-750,-750],
  [1,-1,-28,28,-50,50,-75,75,-50,50,100,-100,450,-450,396,-396,750,-750],
  [1,1,-32,-32,40,40,15,15,-80,-80,80,80,-360,-360,576,576,-240,-240],
  [1,-1,32,-32,40,-40,-15,15,-80,80,-80,80,-360,360,576,-576,240,-240],
  [1,1,16,16,4,4,-45,-45,-56,-56,-136,-136,0,0,-288,-288,504,504],
  [1,-1,-16,16,4,-4,45,-45,-56,56,136,-136,0,0,-288,288,-504,504]]],
##
[[1,4,6,9,11,13,18,19,20,22,24,29,33],"$2.HS.2 \\leq 4.HS.2$",
 [[1,1,1408,1408,4400,11550,35200,35200,246400,354816,354816,554400,1478400],
  [1,-1,352,-352,0,0,4400,-4400,0,22176,-22176,0,0],
  [1,1,208,208,-100,1050,2200,2200,-5600,2016,2016,-12600,8400],
  [1,1,-112,-112,600,150,1000,1000,-4400,-864,-864,7200,-3600],
  [1,1,208,208,200,-1050,1000,1000,2800,2016,2016,0,-8400],
  [1,1,128,128,400,750,0,0,3200,-2304,-2304,0,0],
  [1,1,-47,-47,-100,0,250,250,700,-504,-504,0,0],
  [1,-1,-53,53,0,0,350,-350,0,-504,504,0,0],
  [1,1,28,28,-100,150,-50,-50,-200,396,396,900,-1500],
  [1,-1,72,-72,0,0,100,-100,0,-504,504,0,0],
  [1,1,-32,-32,80,30,-80,-80,160,576,576,-720,-480],
  [1,1,16,16,8,-90,-56,-56,-272,-288,-288,0,1008],
  [1,-1,-8,8,0,0,-100,100,0,216,-216,0,0]]],
##
[[1,4,6,11,15,20,22,26,31,36,40,42,43,51,67],"$U_3(8).6$",
 [[1,1539,14364,25536,51072,68096,131328,459648,689472,787968,
   787968,1225728,1225728,5515776,5515776],
  [1,-81,3024,-4704,-2688,7616,1728,-24192,54432,-67392,36288,
   -24192,56448,-108864,72576],
  [1,-261,1764,2436,672,896,5328,6048,15372,17568,24768,-51072,
   -17472,22176,-28224],
  [1,99,924,2016,-2688,896,-3072,2688,14112,10368,-1152,16128,16128,
   -8064,-48384],
  [1,99,684,-144,-1248,-64,1728,-432,-1008,-1152,4608,7488,-8832,-2304,576],
  [1,9,414,366,672,716,-72,-432,-558,1908,-1692,408,-552,-7524,6336],
  [1,19,364,-644,672,-224,-1072,-672,1652,128,-672,448,-1792,5376,-3584],
  [1,-81,-36,-144,72,-424,-72,-972,-648,1728,1728,648,1008,-3024,216],
  [1,-45,-180,48,288,320,0,576,720,-576,576,1152,-1152,-576,-1152],
  [1,19,44,176,192,-704,128,768,592,-832,-192,128,128,-1344,896],
  [1,54,9,126,252,116,153,-702,-1053,-567,918,108,1098,1971,-2484],
  [1,54,-81,-84,-108,56,-297,378,27,513,378,-432,-162,-1269,1026],
  [1,-26,109,-194,-48,136,353,1218,-733,-127,-342,-212,1118,-129,-1124],
  [1,9,-66,-54,-48,-4,528,-672,702,468,-972,-72,-72,396,-144],
  [1,-26,29,86,-168,16,-247,-222,-173,-367,-222,-292,-202,1191,596]]],
];

MULTFREEINFO.("F3+.2"):= ["$F_{3+}.2$",
##
[[1,5,7],"$Fi_{23} \\times 2$",
 [[1,31671,275264],
  [1,351,-352],
  [1,-81,80]]],
##
[[1,2,5,6,7,8],"$Fi_{23} \\leq Fi_{23} \\times 2$",
 [[1,1,31671,31671,275264,275264],
  [1,-1,31671,-31671,-275264,275264],
  [1,1,351,351,-352,-352],
  [1,-1,351,-351,352,-352],
  [1,1,-81,-81,80,80],
  [1,-1,-81,81,-80,80]]],
##
[[1,4,5,7,10,15,21,26,28,37,44,48,51,54,73,75,83],"$O_{10}^-(2).2$",
[ [ 1, 25245, 104448, 1570800, 12773376, 45957120, 67858560, 107233280, 
      193881600, 263208960, 579059712, 1085736960, 5147197440, 5428684800, 
      7238246400, 12634030080, 17371791360 ], 
  [ 1, -5049, -13056, 157080, 798336, 2010624, -3392928, -1340416, 4847040, 
      -3290112, -18095616, 27143424, 80424960, -67858560, -90478080, 
      -39481344, 108573696 ], 
  [ 1, 1755, 16752, 145740, 145152, -145920, 1955016, 4102784, 1639440, 
      -1983744, 2370816, 16284240, -10730496, 30119040, -7197120, -44706816, 
      7983360 ], 
  [ 1, 3195, 5664, 27300, -266112, 798720, -302400, 546560, 2311200, 2419200, 
      2161152, -393120, -5376000, 5443200, -22377600, 21288960, -6289920 ], 
  [ 1, -1485, 8544, 56100, -57024, 337920, 178200, 1168640, -1782000, 
      1468800, -3269376, 1568160, 5913600, 1425600, 1900800, 7050240, 
      -15966720 ], 
  [ 1, 2079, -2256, 26400, -14256, 489984, 28512, -256960, -712800, -1237248, 
      2318976, 1012176, 3480576, -498960, -665280, 2073600, -6044544 ], 
  [ 1, 819, 1776, 10020, 55296, 26304, 129816, -75520, 179280, 262656, 
      161856, 20304, 561408, -544320, 665280, -587520, -867456 ], 
  [ 1, -189, -2688, 19380, 16848, -37056, -132840, -65152, 6480, 69120, 
      22464, 456192, -652800, -149040, 501120, 456192, -508032 ], 
  [ 1, -45, 3072, 14340, -1728, -30720, 26136, 111104, -2160, -100224, 66816, 
      -120960, -316416, -855360, 17280, 635904, 552960 ], 
  [ 1, -639, -708, 2730, -16632, 34944, 15120, -6832, 57780, -30240, -67536, 
      -9828, -84000, -68040, 279720, -66528, -39312 ], 
  [ 1, 171, 912, 1596, -6912, -6528, -21816, -2944, 23760, -6912, 1152, 
      -34128, 167424, 124416, 63936, -152064, -152064 ], 
  [ 1, 279, -816, 3000, -5616, 384, 4752, 2240, -21600, 24192, 14976, -54864, 
      36096, 19440, -60480, -172800, 210816 ], 
  [ 1, -315, 588, 1110, 4752, 10320, -4320, -10720, -19980, 8640, -2736, 
      -25380, -58080, 77760, -50760, -82080, 151200 ], 
  [ 1, 387, 48, -780, 3456, 12480, -7560, 7424, 3024, -6912, -17856, -5616, 
      -74496, -15552, 63936, -6912, 44928 ], 
  [ 1, -99, -276, 30, 3456, -1776, -1728, 7424, 5940, -6912, 1584, -20196, 
      36960, 19440, -11880, 16416, -48384 ], 
  [ 1, 63, 48, 192, -432, -3072, 6048, -8128, -864, -6912, -12672, 9936, 
      -12288, 19440, -29376, 55296, -17280 ], 
  [ 1, -45, 48, -780, -1728, -480, -1080, 2240, -2160, 8640, 12384, 15120, 
      -1920, -38880, 17280, -17280, 8640 ] ] ],
##
[[1,2,3,4,5,6,7,8,9,10,15,16,21,22,25,26,28,29,36,37,
  44,45,48,49,50,51,54,55,72,73,75,76,83,84],
"$O_{10}^-(2) \\leq O_{10}^-(2).2$",
[ [ 1, 1, 25245, 25245, 104448, 104448, 1570800, 1570800, 12773376, 12773376, 
      45957120, 45957120, 67858560, 67858560, 107233280, 107233280, 
      193881600, 193881600, 263208960, 263208960, 579059712, 579059712, 
      1085736960, 1085736960, 5147197440, 5147197440, 5428684800, 5428684800, 
      7238246400, 7238246400, 12634030080, 12634030080, 17371791360, 
      17371791360 ], 
  [ 1, -1, 25245, -25245, 104448, -104448, 1570800, -1570800, 12773376, 
      -12773376, 45957120, -45957120, 67858560, -67858560, 107233280, 
      -107233280, 193881600, -193881600, 263208960, -263208960, 579059712, 
      -579059712, 1085736960, -1085736960, 5147197440, -5147197440, 
      5428684800, -5428684800, 7238246400, -7238246400, 12634030080, 
      -12634030080, 17371791360, -17371791360 ], 
  [ 1, -1, -5049, 5049, -13056, 13056, 157080, -157080, 798336, -798336, 
      2010624, -2010624, -3392928, 3392928, -1340416, 1340416, 4847040, 
      -4847040, -3290112, 3290112, -18095616, 18095616, 27143424, -27143424, 
      80424960, -80424960, -67858560, 67858560, -90478080, 90478080, 
      -39481344, 39481344, 108573696, -108573696 ], 
  [ 1, 1, -5049, -5049, -13056, -13056, 157080, 157080, 798336, 798336, 
      2010624, 2010624, -3392928, -3392928, -1340416, -1340416, 4847040, 
      4847040, -3290112, -3290112, -18095616, -18095616, 27143424, 27143424, 
      80424960, 80424960, -67858560, -67858560, -90478080, -90478080, 
      -39481344, -39481344, 108573696, 108573696 ], 
  [ 1, 1, 1755, 1755, 16752, 16752, 145740, 145740, 145152, 145152, -145920, 
      -145920, 1955016, 1955016, 4102784, 4102784, 1639440, 1639440, 
      -1983744, -1983744, 2370816, 2370816, 16284240, 16284240, -10730496, 
      -10730496, 30119040, 30119040, -7197120, -7197120, -44706816, 
      -44706816, 7983360, 7983360 ], 
  [ 1, -1, 1755, -1755, 16752, -16752, 145740, -145740, 145152, -145152, 
      -145920, 145920, 1955016, -1955016, 4102784, -4102784, 1639440, 
      -1639440, -1983744, 1983744, 2370816, -2370816, 16284240, -16284240, 
      -10730496, 10730496, 30119040, -30119040, -7197120, 7197120, -44706816, 
      44706816, 7983360, -7983360 ], 
  [ 1, 1, 3195, 3195, 5664, 5664, 27300, 27300, -266112, -266112, 798720, 
      798720, -302400, -302400, 546560, 546560, 2311200, 2311200, 2419200, 
      2419200, 2161152, 2161152, -393120, -393120, -5376000, -5376000, 
      5443200, 5443200, -22377600, -22377600, 21288960, 21288960, -6289920, 
      -6289920 ], 
  [ 1, -1, 3195, -3195, 5664, -5664, 27300, -27300, -266112, 266112, 798720, 
      -798720, -302400, 302400, 546560, -546560, 2311200, -2311200, 2419200, 
      -2419200, 2161152, -2161152, -393120, 393120, -5376000, 5376000, 
      5443200, -5443200, -22377600, 22377600, 21288960, -21288960, -6289920, 
      6289920 ], 
  [ 1, -1, -1485, 1485, 8544, -8544, 56100, -56100, -57024, 57024, 337920, 
      -337920, 178200, -178200, 1168640, -1168640, -1782000, 1782000, 
      1468800, -1468800, -3269376, 3269376, 1568160, -1568160, 5913600, 
      -5913600, 1425600, -1425600, 1900800, -1900800, 7050240, -7050240, 
      -15966720, 15966720 ], 
  [ 1, 1, -1485, -1485, 8544, 8544, 56100, 56100, -57024, -57024, 337920, 
      337920, 178200, 178200, 1168640, 1168640, -1782000, -1782000, 1468800, 
      1468800, -3269376, -3269376, 1568160, 1568160, 5913600, 5913600, 
      1425600, 1425600, 1900800, 1900800, 7050240, 7050240, -15966720, 
      -15966720 ], 
  [ 1, 1, 2079, 2079, -2256, -2256, 26400, 26400, -14256, -14256, 489984, 
      489984, 28512, 28512, -256960, -256960, -712800, -712800, -1237248, 
      -1237248, 2318976, 2318976, 1012176, 1012176, 3480576, 3480576, 
      -498960, -498960, -665280, -665280, 2073600, 2073600, -6044544, 
      -6044544 ], 
  [ 1, -1, 2079, -2079, -2256, 2256, 26400, -26400, -14256, 14256, 489984, 
    -489984, 28512, -28512, -256960, 256960, -712800, 712800, -1237248, 
    1237248, 2318976, -2318976, 1012176, -1012176, 3480576, -3480576, 
    -498960, 498960, -665280, 665280, 2073600, -2073600, -6044544, 6044544 ],
  [ 1, 1, 819, 819, 1776, 1776, 10020, 10020, 55296, 55296, 26304, 26304, 
      129816, 129816, -75520, -75520, 179280, 179280, 262656, 262656, 161856, 
      161856, 20304, 20304, 561408, 561408, -544320, -544320, 665280, 665280, 
      -587520, -587520, -867456, -867456 ], 
  [ 1, -1, 819, -819, 1776, -1776, 10020, -10020, 55296, -55296, 26304, 
      -26304, 129816, -129816, -75520, 75520, 179280, -179280, 262656, 
      -262656, 161856, -161856, 20304, -20304, 561408, -561408, -544320, 
      544320, 665280, -665280, -587520, 587520, -867456, 867456 ], 
  [ 1, -1, -189, 189, -2688, 2688, 19380, -19380, 16848, -16848, -37056, 
      37056, -132840, 132840, -65152, 65152, 6480, -6480, 69120, -69120, 
      22464, -22464, 456192, -456192, -652800, 652800, -149040, 149040, 
      501120, -501120, 456192, -456192, -508032, 508032 ], 
  [ 1, 1, -189, -189, -2688, -2688, 19380, 19380, 16848, 16848, -37056, 
      -37056, -132840, -132840, -65152, -65152, 6480, 6480, 69120, 69120, 
      22464, 22464, 456192, 456192, -652800, -652800, -149040, -149040, 
      501120, 501120, 456192, 456192, -508032, -508032 ], 
  [ 1, 1, -45, -45, 3072, 3072, 14340, 14340, -1728, -1728, -30720, -30720, 
      26136, 26136, 111104, 111104, -2160, -2160, -100224, -100224, 66816, 
      66816, -120960, -120960, -316416, -316416, -855360, -855360, 17280, 
      17280, 635904, 635904, 552960, 552960 ], 
  [ 1, -1, -45, 45, 3072, -3072, 14340, -14340, -1728, 1728, -30720, 30720, 
      26136, -26136, 111104, -111104, -2160, 2160, -100224, 100224, 66816, 
      -66816, -120960, 120960, -316416, 316416, -855360, 855360, 17280, 
      -17280, 635904, -635904, 552960, -552960 ], 
  [ 1, -1, -639, 639, -708, 708, 2730, -2730, -16632, 16632, 34944, -34944, 
      15120, -15120, -6832, 6832, 57780, -57780, -30240, 30240, -67536, 
      67536, -9828, 9828, -84000, 84000, -68040, 68040, 279720, -279720, 
      -66528, 66528, -39312, 39312 ], 
  [ 1, 1, -639, -639, -708, -708, 2730, 2730, -16632, -16632, 34944, 34944, 
      15120, 15120, -6832, -6832, 57780, 57780, -30240, -30240, -67536, 
      -67536, -9828, -9828, -84000, -84000, -68040, -68040, 279720, 279720, 
      -66528, -66528, -39312, -39312 ], 
  [ 1, 1, 171, 171, 912, 912, 1596, 1596, -6912, -6912, -6528, -6528, -21816, 
      -21816, -2944, -2944, 23760, 23760, -6912, -6912, 1152, 1152, -34128, 
      -34128, 167424, 167424, 124416, 124416, 63936, 63936, -152064, -152064, 
      -152064, -152064 ], 
  [ 1, -1, 171, -171, 912, -912, 1596, -1596, -6912, 6912, -6528, 6528, 
      -21816, 21816, -2944, 2944, 23760, -23760, -6912, 6912, 1152, -1152, 
      -34128, 34128, 167424, -167424, 124416, -124416, 63936, -63936, 
      -152064, 152064, -152064, 152064 ], 
  [ 1, 1, 279, 279, -816, -816, 3000, 3000, -5616, -5616, 384, 384, 4752, 
      4752, 2240, 2240, -21600, -21600, 24192, 24192, 14976, 14976, -54864, 
      -54864, 36096, 36096, 19440, 19440, -60480, -60480, -172800, -172800, 
      210816, 210816 ], 
  [ 1, -1, 279, -279, -816, 816, 3000, -3000, -5616, 5616, 384, -384, 4752, 
      -4752, 2240, -2240, -21600, 21600, 24192, -24192, 14976, -14976, 
      -54864, 54864, 36096, -36096, 19440, -19440, -60480, 60480, -172800, 
      172800, 210816, -210816 ], 
  [ 1, -1, -315, 315, 588, -588, 1110, -1110, 4752, -4752, 10320, -10320, 
      -4320, 4320, -10720, 10720, -19980, 19980, 8640, -8640, -2736, 2736, 
      -25380, 25380, -58080, 58080, 77760, -77760, -50760, 50760, -82080, 
      82080, 151200, -151200 ], 
  [ 1, 1, -315, -315, 588, 588, 1110, 1110, 4752, 4752, 10320, 10320, -4320, 
      -4320, -10720, -10720, -19980, -19980, 8640, 8640, -2736, -2736, 
      -25380, -25380, -58080, -58080, 77760, 77760, -50760, -50760, -82080, 
      -82080, 151200, 151200 ], 
  [ 1, 1, 387, 387, 48, 48, -780, -780, 3456, 3456, 12480, 12480, -7560, 
      -7560, 7424, 7424, 3024, 3024, -6912, -6912, -17856, -17856, -5616, 
      -5616, -74496, -74496, -15552, -15552, 63936, 63936, -6912, -6912, 
      44928, 44928 ], 
  [ 1, -1, 387, -387, 48, -48, -780, 780, 3456, -3456, 12480, -12480, -7560, 
      7560, 7424, -7424, 3024, -3024, -6912, 6912, -17856, 17856, -5616, 
      5616, -74496, 74496, -15552, 15552, 63936, -63936, -6912, 6912, 44928, 
      -44928 ], 
  [ 1, -1, -99, 99, -276, 276, 30, -30, 3456, -3456, -1776, 1776, -1728, 
      1728, 7424, -7424, 5940, -5940, -6912, 6912, 1584, -1584, -20196, 
      20196, 36960, -36960, 19440, -19440, -11880, 11880, 16416, -16416, 
      -48384, 48384 ], 
  [ 1, 1, -99, -99, -276, -276, 30, 30, 3456, 3456, -1776, -1776, -1728, 
      -1728, 7424, 7424, 5940, 5940, -6912, -6912, 1584, 1584, -20196, 
      -20196, 36960, 36960, 19440, 19440, -11880, -11880, 16416, 16416, 
      -48384, -48384 ], 
  [ 1, 1, 63, 63, 48, 48, 192, 192, -432, -432, -3072, -3072, 6048, 6048, 
      -8128, -8128, -864, -864, -6912, -6912, -12672, -12672, 9936, 9936, 
      -12288, -12288, 19440, 19440, -29376, -29376, 55296, 55296, -17280, 
      -17280 ], 
  [ 1, -1, 63, -63, 48, -48, 192, -192, -432, 432, -3072, 3072, 6048, -6048, 
      -8128, 8128, -864, 864, -6912, 6912, -12672, 12672, 9936, -9936, 
      -12288, 12288, 19440, -19440, -29376, 29376, 55296, -55296, -17280, 
      17280 ], 
  [ 1, 1, -45, -45, 48, 48, -780, -780, -1728, -1728, -480, -480, -1080, 
      -1080, 2240, 2240, -2160, -2160, 8640, 8640, 12384, 12384, 15120, 
      15120, -1920, -1920, -38880, -38880, 17280, 17280, -17280, -17280, 
      8640, 8640 ], 
  [ 1, -1, -45, 45, 48, -48, -780, 780, -1728, 1728, -480, 480, -1080, 1080, 
    2240, -2240, -2160, 2160, 8640, -8640, 12384, -12384, 15120, -15120, 
    -1920, 1920, -38880, 38880, 17280, -17280, -17280, 17280, 8640, -8640]]],
##
[[1,5,7,21,23,28,30,34,41,44,54,56,60,74,81,83,108],"$3^7.O_7(3).2$",
[ [ 1, 1120, 49140, 275562, 816480, 21228480, 57316896, 62178597, 286584480, 
      429876720, 2901667860, 5158520640, 6964002864, 15475561920, 
      18366600960, 23213342880, 52230021480 ], 
  [ 1, -40, 3900, 31266, -29160, 56160, 1617408, 2814669, -463320, 4801680, 
      32411340, -30326400, 77787216, 40940640, -81881280, -37528920, 
      -10235160 ], 
  [ 1, 392, 7644, 20034, 76104, 812448, 471744, 85293, 5798520, 2240784, 
    15125292, 28304640, -9552816, -19105632, -30652992, 11144952, -4776408 ], 
  [ 1, 200, 2220, 2322, 13320, 64800, -53568, 73629, 104760, 343440, 
      -811620, -1244160, 1271376, -2838240, 699840, 4908600, -2536920 ], 
  [ 1, 224, 2772, 3402, 18144, 108864, 54432, -37179, 272160, 81648, -591948, 
      -326592, -244944, 3592512, 1679616, -2776032, -1837080 ], 
  [ 1, -40, 300, 3186, -360, -1440, -41472, 190269, -117720, 265680, 43740, 
      777600, 104976, -1049760, 2099520, -2536920, 262440 ], 
  [ 1, 32, -636, 3834, 3744, -29952, 121824, 114453, 21600, -364176, -144828, 
      388800, 128304, 373248, 373248, 1220832, -2210328 ], 
  [ 1, 152, 1224, 1134, 6264, 6048, -20736, -16767, 3240, -241056, 190512, 
      -155520, 303264, -1065312, 139968, -849528, 1697112 ], 
  [ 1, -64, 468, -1782, 1728, -22464, 33696, 9477, 67392, 50544, -63180, 
      -202176, -151632, -202176, 0, -202176, 682344 ], 
  [ 1, -40, 732, 2754, -3816, 5472, 20736, -8019, -7128, 11664, 164268, 
      -217728, -221616, -116640, 233280, 106920, 29160 ], 
  [ 1, 104, 588, -270, 936, -3168, 5184, 3645, -53352, 22032, 4860, 62208, 
      -128304, 116640, -233280, 126360, 75816 ], 
  [ 1, 56, -84, 882, 504, -14112, -24192, 3645, 35784, 3024, 74844, -72576, 
      -81648, 163296, 46656, 68040, -204120 ], 
  [ 1, 14, -294, 1134, 882, -5544, 9072, -16767, -7938, 27216, -44226, 68040, 
      102060, -81648, 5832, -78246, 20412 ], 
  [ 1, -28, 0, -378, 756, 0, 0, -3159, -9828, 0, 58968, 0, 0, 0, 101088, 
      29484, -176904 ], 
  [ 1, 44, 36, -486, -1188, 216, 2592, -2187, 10692, -1944, -2916, 19440, 
      58320, -33048, 93312, -32076, -110808 ], 
  [ 1, -40, 300, 162, -360, -1440, -5184, -243, 3240, -6480, -46980, 51840, 
      50544, 38880, -77760, 3240, -9720 ], 
  [ 1, 0, -140, 42, 0, 2240, -224, 2917, 0, -1680, -10220, -20160, -27216, 
      2240, -46080, 0, 98280 ] ] ] ];

MULTFREEINFO.("2.M12"):=["$2.M_{12}$",
##
[ [ 1, 2, 18 ],
"$M_{11} \\rightarrow (M_{12},1)$",
 [[1,1,22],
  [1,1,-2],
  [1,-1,0]] ],
##
[ [ 1, 3, 18 ],
"$M_{11} \\rightarrow (M_{12},2)$",
 [[1,1,22],
  [1,1,-2],
  [1,-1,0]] ],
##
[ [ 1, 2, 3, 7, 8, 18, 24 ],
"$A_6.2_1 \\rightarrow (M_{12},5)$",
 [[1,1,2,40,40,90,90],
  [1,1,-2,0,0,30,-30],
  [1,1,2,16,16,-18,-18],
  [1,1,2,-4,-4,2,2],
  [1,1,-2,0,0,-6,6],
  [1,-1,0,-20,20,0,0],
  [1,-1,0,2,-2,0,0]] ],
##
[ [ 1, 2, 3, 7, 8, 18, 24 ],
"$A_6.2_1 \\rightarrow (M_{12},8)$",
 [[1,1,2,40,40,90,90],
  [1,1,2,16,16,-18,-18],
  [1,1,-2,0,0,30,-30],
  [1,1,2,-4,-4,2,2],
  [1,1,-2,0,0,-6,6],
  [1,-1,0,-20,20,0,0],
  [1,-1,0,2,-2,0,0]] ],
##
[ [ 1, 2, 7, 8, 12, 22, 23 ],
"$3^2.2.S_4 \\rightarrow (M_{12},11)$",
 [[1,1,24,54,72,72,216],
  [1,1,-8,30,-24,-24,24],
  [1,1,2,10,6,6,-26],
  [1,1,10,-6,-6,-6,6],
  [1,1,-6,-6,2,2,6],
  [1,-1,0,0,-6*ER(-2),6*ER(-2),0],
  [1,-1,0,0,6*ER(-2),-6*ER(-2),0]] ],
##
[ [ 1, 3, 7, 8, 12, 22, 23 ],
"$3^2.2.S_4 \\rightarrow (M_{12},13)$",
 [[1,1,24,54,72,72,216],
  [1,1,-8,30,-24,-24,24],
  [1,1,2,10,6,6,-26],
  [1,1,10,-6,-6,-6,6],
  [1,1,-6,-6,2,2,6],
  [1,-1,0,0,-6*ER(-2),6*ER(-2),0],
  [1,-1,0,0,6*ER(-2),-6*ER(-2),0]] ],
##
[ [ 1, 2, 7, 8, 12, 18, 20, 21, 24 ],
"$3^2.2.S_4 \\rightarrow (M_{12},11)$",
 [[1,1,12,12,54,72,72,108,108],
  [1,1,-4,-4,30,-24,-24,12,12],
  [1,1,1,1,10,6,6,-13,-13],
  [1,1,5,5,-6,-6,-6,3,3],
  [1,1,-3,-3,-6,2,2,3,3],
  [1,-1,8,-8,0,0,0,-36,36],
  [1,-1,3,-3,0,-6*ER(-5),6*ER(-5),9,-9],
  [1,-1,3,-3,0,6*ER(-5),-6*ER(-5),9,-9],
  [1,-1,-3,3,0,0,0,-3,3]] ],
##
[ [ 1, 3, 7, 8, 12, 18, 20, 21, 24 ],
"$3^2.2.S_4 \\rightarrow (M_{12},13)$",
 [[1,1,12,12,54,72,72,108,108],
  [1,1,-4,-4,30,-24,-24,12,12],
  [1,1,1,1,10,6,6,-13,-13],
  [1,1,5,5,-6,-6,-6,3,3],
  [1,1,-3,-3,-6,2,2,3,3],
  [1,-1,8,-8,0,0,0,-36,36],
  [1,-1,3,-3,0,-6*ER(-5),6*ER(-5),9,-9],
  [1,-1,3,-3,0,6*ER(-5),-6*ER(-5),9,-9],
  [1,-1,-3,3,0,0,0,-3,3]] ],
##
[ [ 1, 2, 6, 7, 8, 10, 12, 13, 18, 20, 21, 22, 23, 24 ],
"$3^2:2.A_4 \\rightarrow (M_{12},12)$",
 [[1,1,1,1,24,24,54,54,72,72,72,72,216,216],
  [1,1,1,1,-8,-8,30,30,-24,-24,-24,-24,24,24],
  [1,1,-1,-1,0,0,-6,6,-16,16,-16,16,0,0],
  [1,1,1,1,2,2,10,10,6,6,6,6,-26,-26],
  [1,1,1,1,10,10,-6,-6,-6,-6,-6,-6,6,6],
  [1,1,-1,-1,0,0,18,-18,0,0,0,0,0,0],
  [1,1,1,1,-6,-6,-6,-6,2,2,2,2,6,6],
  [1,1,-1,-1,0,0,-6,6,6,-6,6,-6,0,0],
  [1,-1,1,-1,-16,16,0,0,0,0,0,0,72,-72],
  [1,-1,1,-1,-6,6,0,0,6*ER(-5),-6*ER(-5),-6*ER(-5),6*ER(-5),-18,18],
  [1,-1,1,-1,-6,6,0,0,-6*ER(-5),6*ER(-5),6*ER(-5),-6*ER(-5),-18,18],
  [1,-1,-1,1,0,0,0,0,-6*ER(-2),-6*ER(-2),6*ER(-2),6*ER(-2),0,0],
  [1,-1,-1,1,0,0,0,0,6*ER(-2),6*ER(-2),-6*ER(-2),-6*ER(-2),0,0],
  [1,-1,1,-1,6,-6,0,0,0,0,0,0,6,-6]] ],
##
[ [ 1, 3, 6, 7, 8, 9, 12, 13, 18, 20, 21, 22, 23, 24 ], 
 "$3^2:2.A_4 \\rightarrow (M_{12},14)$",
 [[1,1,1,1,24,24,54,54,72,72,72,72,216,216],
  [1,1,1,1,-8,-8,30,30,-24,-24,-24,-24,24,24],
  [1,1,-1,-1,0,0,-6,6,-16,16,-16,16,0,0],
  [1,1,1,1,2,2,10,10,6,6,6,6,-26,-26],
  [1,1,1,1,10,10,-6,-6,-6,-6,-6,-6,6,6],
  [1,1,-1,-1,0,0,18,-18,0,0,0,0,0,0],
  [1,1,1,1,-6,-6,-6,-6,2,2,2,2,6,6],
  [1,1,-1,-1,0,0,-6,6,6,-6,6,-6,0,0],
  [1,-1,1,-1,-16,16,0,0,0,0,0,0,72,-72],
  [1,-1,1,-1,-6,6,0,0,6*ER(-5),-6*ER(-5),-6*ER(-5),6*ER(-5),-18,18],
  [1,-1,1,-1,-6,6,0,0,-6*ER(-5),6*ER(-5),6*ER(-5),-6*ER(-5),-18,18],
  [1,-1,-1,1,0,0,0,0,-6*ER(-2),-6*ER(-2),6*ER(-2),6*ER(-2),0,0],
  [1,-1,-1,1,0,0,0,0,6*ER(-2),6*ER(-2),-6*ER(-2),-6*ER(-2),0,0],
  [1,-1,1,-1,6,-6,0,0,0,0,0,0,6,-6]] ] ];

MULTFREEINFO.("2.M22"):=["$2.M_{22}$",
##
[ [ 1, 2, 5, 7, 9, 17, 18, 21 ],
"$2^4:A_5 \\rightarrow (M_{22},3)$",
 [[1,1,10,96,96,120,120,480],
  [1,1,10,-36,-36,10,10,40],
  [1,1,10,12,12,-6,-6,-24],
  [1,1,-2,0,0,12,12,-24],
  [1,1,-2,0,0,-8,-8,16],
  [1,-1,0,-4*ER(-11),4*ER(-11),10,-10,0],
  [1,-1,0,4*ER(-11),-4*ER(-11),10,-10,0],
  [1,-1,0,0,0,-12,12,0]] ],
##
[ [ 1, 2, 7, 15, 16 ],
"$A_7 \\rightarrow (M_{22},4)$",
 [[1,1,105,105,140],
  [1,1,17,17,-36],
  [1,1,-3,-3,4],
  [1,-1,15,-15,0],
  [1,-1,-7,7,0]] ],
##
[ [ 1, 2, 7, 15, 16 ],
"$A_7 \\rightarrow (M_{22},5)$",
 [[1,1,105,105,140],
  [1,1,17,17,-36],
  [1,1,-3,-3,4],
  [1,-1,15,-15,0],
  [1,-1,-7,7,0]] ],
##
[ [ 1, 2, 5, 6, 7, 16, 21 ],
"$2^3:L_3(2) \\rightarrow (M_{22},7)$",
 [[1,1,14,84,112,112,336],
  [1,1,-8,18,24,24,-60],
  [1,1,8,18,-8,-8,-12],
  [1,1,-6,4,-8,-8,16],
  [1,1,2,-12,4,4,0],
  [1,-1,0,0,-14,14,0],
  [1,-1,0,0,8,-8,0]] ] ];

MULTFREEINFO.("3.M22"):=["$3.M_{22}$",
##
[ [ 1, 2, 5, 7, 9, 13, 14, 21, 22, 23, 24, 27, 28 ],
"$2^4:A_5 \\rightarrow (M_{22},3)$",
[ [ 1, 1, 1, 15, 96, 96, 96, 120, 120, 120, 240, 240, 240 ], 
  [ 1, 1, 1, 15, -36, -36, -36, 10, 10, 10, 20, 20, 20 ], 
  [ 1, 1, 1, 15, 12, 12, 12, -6, -6, -6, -12, -12, -12 ], 
  [ 1, 1, 1, -3, 0, 0, 0, 12, 12, 12, -12, -12, -12 ], 
  [ 1, 1, 1, -3, 0, 0, 0, -8, -8, -8, 8, 8, 8 ], 
  [ 1, E(3), E(3)^2, 0, -24, -24*E(3), -24*E(3)^2, 40, 40*E(3), 40*E(3)^2, 
      20, 20*E(3), 20*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, -24, -24*E(3)^2, -24*E(3), 40, 40*E(3)^2, 40*E(3), 
      20, 20*E(3)^2, 20*E(3) ], 
  [ 1, E(3), E(3)^2, 0, 9+ER(33), (9+ER(33))*E(3), (9+ER(33))*E(3)^2,
    3+3*EB(33), (3+3*EB(33))*E(3), (3+3*EB(33))*E(3)^2,
    9-3*ER(33), (9-3*ER(33))*E(3), (9-3*ER(33))*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, 9-ER(33), (9-ER(33))*E(3)^2, (9-ER(33))*E(3),
    -3*EB(33), -3*EB(33)*E(3)^2, -3*EB(33)*E(3), 
    9+3*ER(33), (9+3*ER(33))*E(3)^2, (9+3*ER(33))*E(3) ],
  [ 1, E(3), E(3)^2, 0, 9-ER(33), (9-ER(33))*E(3), (9-ER(33))*E(3)^2,
    -3*EB(33), -3*EB(33)*E(3), -3*EB(33)*E(3)^2,
    9+3*ER(33), (9+3*ER(33))*E(3), (9+3*ER(33))*E(3)^2 ],
  [ 1, E(3)^2, E(3), 0, 9+ER(33), (9+ER(33))*E(3)^2, (9+ER(33))*E(3),
    3+3*EB(33), (3+3*EB(33))*E(3)^2, (3+3*EB(33))*E(3),
    9-3*ER(33), (9-3*ER(33))*E(3)^2, (9-3*ER(33))*E(3) ],
  [ 1, E(3), E(3)^2, 0, -6, -6*E(3), -6*E(3)^2, -5, -5*E(3), -5*E(3)^2, -10, 
      -10*E(3), -10*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, -6, -6*E(3)^2, -6*E(3), -5, -5*E(3)^2, -5*E(3), -10, 
      -10*E(3)^2, -10*E(3) ] ] ] ,
##
[ [ 1, 2, 5, 7, 13, 14, 21, 22, 23, 24 ],
 "$2^4:S_5 \\rightarrow (M_{22},6)$",
[ [ 1, 1, 1, 30, 30, 30, 120, 160, 160, 160 ], 
  [ 1, 1, 1, -3, -3, -3, 54, -16, -16, -16 ], 
  [ 1, 1, 1, 9, 9, 9, -6, -8, -8, -8 ],
  [ 1, 1, 1, -3, -3, -3, -6, 4, 4, 4 ], 
  [ 1, E(3), E(3)^2, 15, 15*E(3)^2, 15*E(3), 0, 20, 20*E(3), 20*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 15, 15*E(3), 15*E(3)^2, 0, 20, 20*E(3)^2, 20*E(3) ], 
  [ 1, E(3), E(3)^2, -2-EB(33), (-2-EB(33))*E(3)^2, (-2-EB(33))*E(3),
    0, 4*EB(33), 4*EB(33)*E(3), 4*EB(33)*E(3)^2 ], 
  [ 1, E(3)^2, E(3), -1+EB(33), (-1+EB(33))*E(3), (-1+EB(33))*E(3)^2,
    0, -2-2*ER(33), (-2-2*ER(33))*E(3)^2, (-2-2*ER(33))*E(3) ],
  [ 1, E(3), E(3)^2, -1+EB(33), (-1+EB(33))*E(3)^2, (-1+EB(33))*E(3),
    0, -2-2*ER(33), (-2-2*ER(33))*E(3), (-2-2*ER(33))*E(3)^2 ],
  [ 1, E(3)^2, E(3), -2-EB(33),  (-2-EB(33))*E(3),  (-2-EB(33))*E(3)^2,
    0, 4*EB(33), 4*EB(33)*E(3)^2, 4*EB(33)*E(3) ] ] ],
##
[ [ 1, 2, 5, 6, 7, 13, 14, 19, 20, 21, 22, 23, 24 ],
 "$2^3:L_3(2) \\rightarrow (M_{22},7)$",
[ [ 1, 1, 1, 7, 7, 7, 42, 42, 42, 168, 168, 168, 336 ], 
  [ 1, 1, 1, -4, -4, -4, 9, 9, 9, -30, -30, -30, 72 ], 
  [ 1, 1, 1, 4, 4, 4, 9, 9, 9, -6, -6, -6, -24 ], 
  [ 1, 1, 1, -3, -3, -3, 2, 2, 2, 8, 8, 8, -24 ], 
  [ 1, 1, 1, 1, 1, 1, -6, -6, -6, 0, 0, 0, 12 ], 
  [ 1, E(3), E(3)^2, 5, 5*E(3)^2, 5*E(3), 18, 18*E(3)^2, 18*E(3), 24, 
      24*E(3), 24*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 5, 5*E(3), 5*E(3)^2, 18, 18*E(3), 18*E(3)^2, 24, 
      24*E(3)^2, 24*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 0, 0, 0, -7, -7*E(3)^2, -7*E(3), 14, 14*E(3), 14*E(3)^2, 
      0 ], 
  [ 1, E(3)^2, E(3), 0, 0, 0, -7, -7*E(3), -7*E(3)^2, 14, 14*E(3)^2, 
      14*E(3), 0 ], 
  [ 1, E(3), E(3)^2, -1-EB(33), (-1-EB(33))*E(3)^2, (-1-EB(33))*E(3),
    2+EB(33), (2+EB(33))*E(3)^2, (2+EB(33))*E(3),
    -9+ER(33), (-9+ER(33))*E(3), (-9+ER(33))*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), EB(33), EB(33)*E(3), EB(33)*E(3)^2,
    1-EB(33), (1-EB(33))*E(3), (1-EB(33))*E(3)^2,
    -9-ER(33), (-9-ER(33))*E(3)^2, (-9-ER(33))*E(3), 0 ], 
  [ 1, E(3), E(3)^2, EB(33), EB(33)*E(3)^2, EB(33)*E(3),
    1-EB(33), (1-EB(33))*E(3)^2, (1-EB(33))*E(3),
    -9-ER(33), (-9-ER(33))*E(3), (-9-ER(33))*E(3)^2, 0 ],  
  [ 1, E(3)^2, E(3), -1-EB(33), (-1-EB(33))*E(3), (-1-EB(33))*E(3)^2,
    2+EB(33), (2+EB(33))*E(3), (2+EB(33))*E(3)^2,
    -9+ER(33), (-9+ER(33))*E(3)^2, (-9+ER(33))*E(3), 0 ] ] ],
##
[ [ 1, 2, 5, 7, 8, 9, 13, 14, 21, 22, 23, 24, 25, 26, 27, 28 ],
"$L_2(11) \\rightarrow (M_{22},9)$",
[ [ 1, 1, 1, 55, 55, 55, 66, 66, 66, 165, 165, 165, 165, 330, 330, 330 ], 
  [ 1, 1, 1, -25, -25, -25, -6, -6, -6, 45, 45, 45, 45, -30, -30, -30 ], 
  [ 1, 1, 1, 13, 13, 13, -18, -18, -18, -3, -3, -3, 39, -6, -6, -6 ], 
  [ 1, 1, 1, 7, 7, 7, 6, 6, 6, 9, 9, 9, -15, -18, -18, -18 ], 
  [ 1, 1, 1, -3, -3, -3, -6, -6, -6, 1, 1, 1, -21, 14, 14, 14 ], 
  [ 1, 1, 1, -3, -3, -3, 6, 6, 6, -11, -11, -11, 15, 2, 2, 2 ], 
  [ 1, E(3), E(3)^2, 20, 20*E(3)^2, 20*E(3), -24, -24*E(3), -24*E(3)^2, 45, 
      45*E(3), 45*E(3)^2, 0, -30, -30*E(3), -30*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 20, 20*E(3), 20*E(3)^2, -24, -24*E(3)^2, -24*E(3), 45, 
      45*E(3)^2, 45*E(3), 0, -30, -30*E(3)^2, -30*E(3) ], 
  [ 1, E(3), E(3)^2, 4*EB(33), 4*EB(33)*E(3)^2, 4*EB(33)*E(3),
    9+ER(33), (9+ER(33))*E(3), (9+ER(33))*E(3)^2,
    12-ER(33), (12-ER(33))*E(3), (12-ER(33))*E(3)^2, 0,
    3+ER(33), (3+ER(33))*E(3), (3+ER(33))*E(3)^2 ],
  [ 1, E(3)^2, E(3), -2-2*ER(33), (-2-2*ER(33))*E(3), (-2-2*ER(33))*E(3)^2,
    9-ER(33), (9-ER(33))*E(3)^2, (9-ER(33))*E(3), 
    12+ER(33), (12+ER(33))*E(3)^2, (12+ER(33))*E(3),  0,
    3-ER(33), (3-ER(33))*E(3)^2, (3-ER(33))*E(3) ],
  [ 1, E(3), E(3)^2, -2-2*ER(33), (-2-2*ER(33))*E(3)^2, (-2-2*ER(33))*E(3),
    9-ER(33), (9-ER(33))*E(3), (9-ER(33))*E(3)^2,
    12+ER(33), (12+ER(33))*E(3), (12+ER(33))*E(3)^2, 0,
    3-ER(33), (3-ER(33))*E(3), (3-ER(33))*E(3)^2 ],
  [ 1, E(3)^2, E(3), -2+2*ER(33), (-2+2*ER(33))*E(3), (-2+2*ER(33))*E(3)^2,
    9+ER(33), (9+ER(33))*E(3)^2, (9+ER(33))*E(3),
    12-ER(33), (12-ER(33))*E(3)^2, (12-ER(33))*E(3), 0,
    3+ER(33), (3+ER(33))*E(3)^2, (3+ER(33))*E(3) ],
  [ 1, E(3), E(3)^2, 0, 0, 0, 0, 0, 0, -11, -11*E(3), -11*E(3)^2, 0, -22, 
      -22*E(3), -22*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, 0, 0, 0, 0, 0, -11, -11*E(3)^2, -11*E(3), 0, -22, 
      -22*E(3)^2, -22*E(3) ], 
  [ 1, E(3), E(3)^2, 0, 0, 0, -6, -6*E(3), -6*E(3)^2, -5, -5*E(3), -5*E(3)^2, 
      0, 20, 20*E(3), 20*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, 0, 0, -6, -6*E(3)^2, -6*E(3), -5, -5*E(3)^2, -5*E(3), 
      0, 20, 20*E(3)^2, 20*E(3) ] ] ] ];

MULTFREEINFO.("4.M22"):=["$4.M_{22}$"];

MULTFREEINFO.("6.M22"):=["$6.M_{22}$",
##
[ [1,2,5,7,9, 17,18,21, 24,25,32,33,34,35,38,39, 52,53,54,55,56,57],
 "$2^4:A_5 \\rightarrow (2.M_{22},1), (3.M_{22},1)$",
[[1,1,1,1,1,1,30,96,96,96,96,96,96,120,120,120,120,120,120,480,480,480],
 [1,1,1,1,1,1,30,-36,-36,-36,-36,-36,-36,10,10,10,10,10,10,40,40,40],
 [1,1,1,1,1,1,30,12,12,12,12,12,12,-6,-6,-6,-6,-6,-6,-24,-24,-24],
 [1,1,1,1,1,1,-6,0,0,0,0,0,0,12,12,12,12,12,12,-24,-24,-24],
 [1,1,1,1,1,1,-6,0,0,0,0,0,0,-8,-8,-8,-8,-8,-8,16,16,16],
 [ 1, -1, 1, -1, 1, -1, 0, 4*ER(-11), 4*ER(-11), 4*ER(-11),
  -4*ER(-11), -4*ER(-11), -4*ER(-11), -10, 10, -10, 10, -10, 10, 0, 0, 0 ] ,
 [ 1, -1, 1, -1, 1, -1, 0, -4*ER(-11), -4*ER(-11), -4*ER(-11),
  4*ER(-11), 4*ER(-11), 4*ER(-11), -10, 10, -10, 10, -10, 10, 0, 0, 0 ] , 
 [ 1, -1, 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 0, 12, -12, 12, -12, 12, -12, 
   0, 0, 0 ], 
 [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 0, -24, -24*E(3), -24*E(3)^2, -24, 
   -24*E(3), -24*E(3)^2, 40, 40*E(3), 40*E(3)^2, 40, 40*E(3), 40*E(3)^2, 
   40, 40*E(3), 40*E(3)^2 ], 
 [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 0, -24, -24*E(3)^2, -24*E(3), -24, 
   -24*E(3)^2, -24*E(3), 40, 40*E(3)^2, 40*E(3), 40, 40*E(3)^2, 40*E(3), 
   40, 40*E(3)^2, 40*E(3) ], 
 [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 0, 
   9+ER(33), (9+ER(33))*E(3), (9+ER(33))*E(3)^2,
   9+ER(33), (9+ER(33))*E(3), (9+ER(33))*E(3)^2, 
   3+3*EB(33), (3+3*EB(33))*E(3), (3+3*EB(33))*E(3)^2,
   3+3*EB(33), (3+3*EB(33))*E(3), (3+3*EB(33))*E(3)^2,       
   18-6*ER(33), (18-6*ER(33))*E(3), (18-6*ER(33))*E(3)^2 ],
 [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 0,                         
   9-ER(33), (9-ER(33))*E(3)^2, (9-ER(33))*E(3),
   9-ER(33), (9-ER(33))*E(3)^2, (9-ER(33))*E(3),                    
   -3*EB(33), -3*EB(33)*E(3)^2, -3*EB(33)*E(3),
   -3*EB(33), -3*EB(33)*E(3)^2, -3*EB(33)*E(3),
   18+6*ER(33), (18+6*ER(33))*E(3)^2, (18+6*ER(33))*E(3) ],
 [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 0,                 
   9-ER(33), (9-ER(33))*E(3), (9-ER(33))*E(3)^2,     
   9-ER(33), (9-ER(33))*E(3), (9-ER(33))*E(3)^2,     
   -3*EB(33), -3*EB(33)*E(3), -3*EB(33)*E(3)^2,
   -3*EB(33), -3*EB(33)*E(3), -3*EB(33)*E(3)^2,
   18+6*ER(33), (18+6*ER(33))*E(3), (18+6*ER(33))*E(3)^2 ],
 [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 0,                          
   9+ER(33), (9+ER(33))*E(3)^2, (9+ER(33))*E(3),
   9+ER(33), (9+ER(33))*E(3)^2, (9+ER(33))*E(3),
   3+3*EB(33), (3+3*EB(33))*E(3)^2, (3+3*EB(33))*E(3),        
   3+3*EB(33), (3+3*EB(33))*E(3)^2, (3+3*EB(33))*E(3),                     
   18-6*ER(33), (18-6*ER(33))*E(3)^2,(18-6*ER(33))*E(3) ],
 [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 0, -6, -6*E(3), -6*E(3)^2, -6, -6*E(3), 
   -6*E(3)^2, -5, -5*E(3), -5*E(3)^2, -5, -5*E(3), -5*E(3)^2, -20, 
   -20*E(3), -20*E(3)^2 ], 
 [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 0, -6, -6*E(3)^2, -6*E(3), -6, 
   -6*E(3)^2, -6*E(3), -5, -5*E(3)^2, -5*E(3), -5, -5*E(3)^2, -5*E(3), 
   -20, -20*E(3)^2, -20*E(3) ], 
 [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 0,
   (10-4*EV(33)-6*GaloisCyc(EV(33),7))*E(3),
   (10-4*EV(33)-6*GaloisCyc(EV(33),7))*E(3)^2,
    10-4*EV(33)-6*GaloisCyc(EV(33),7),
  -(10-4*EV(33)-6*GaloisCyc(EV(33),7))*E(3),
  -(10-4*EV(33)-6*GaloisCyc(EV(33),7))*E(3)^2,
  -(10-4*EV(33)-6*GaloisCyc(EV(33),7)),
  5*EB(33), -5*EB(33)*E(3),  5*EB(33)*E(3)^2,
 -5*EB(33),  5*EB(33)*E(3), -5*EB(33)*E(3)^2, 0, 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 0, 
    (-10+6*EV(33)+4*GaloisCyc(EV(33),7))*E(3),                         
     -10+6*EV(33)+4*GaloisCyc(EV(33),7),
    (-10+6*EV(33)+4*GaloisCyc(EV(33),7))*E(3)^2,                         
   -(-10+6*EV(33)+4*GaloisCyc(EV(33),7))*E(3),                         
   -(-10+6*EV(33)+4*GaloisCyc(EV(33),7)),
   -(-10+6*EV(33)+4*GaloisCyc(EV(33),7))*E(3)^2,                         
   -5-5*EB(33),  (5+5*EB(33))*E(3)^2, (-5-5*EB(33))*E(3), 
    5+5*EB(33), (-5-5*EB(33))*E(3)^2,  (5+5*EB(33))*E(3), 0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 0, 
    (10-6*EV(33)-4*GaloisCyc(EV(33),7))*E(3), 
    (10-6*EV(33)-4*GaloisCyc(EV(33),7))*E(3)^2, 
     10-6*EV(33)-4*GaloisCyc(EV(33),7),
   -(10-6*EV(33)-4*GaloisCyc(EV(33),7))*E(3), 
   -(10-6*EV(33)-4*GaloisCyc(EV(33),7))*E(3)^2, 
   -(10-6*EV(33)-4*GaloisCyc(EV(33),7)),
    -5-5*EB(33),  (5+5*EB(33))*E(3), (-5-5*EB(33))*E(3)^2,
     5+5*EB(33), (-5-5*EB(33))*E(3),  (5+5*EB(33))*E(3)^2, 0, 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 0, 
    (-10+4*EV(33)+6*GaloisCyc(EV(33),7))*E(3),
     -10+4*EV(33)+6*GaloisCyc(EV(33),7),
    (-10+4*EV(33)+6*GaloisCyc(EV(33),7))*E(3)^2,
   -(-10+4*EV(33)+6*GaloisCyc(EV(33),7))*E(3),
   -(-10+4*EV(33)+6*GaloisCyc(EV(33),7)),
   -(-10+4*EV(33)+6*GaloisCyc(EV(33),7))*E(3)^2,
    5*EB(33), -5*EB(33)*E(3)^2,  5*EB(33)*E(3),
   -5*EB(33),  5*EB(33)*E(3)^2, -5*EB(33)*E(3), 0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 0, 
   -6*ER(-3),  9+3*ER(-3), -9+3*ER(-3), 6*ER(-3), -9-3*ER(-3),  9-3*ER(-3),
    3, -3*E(3), 3*E(3)^2, -3, 3*E(3), -3*E(3)^2, 0, 0, 0 ],
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 0, 
    6*ER(-3),  9-3*ER(-3), -9-3*ER(-3), -6*ER(-3), -9+3*ER(-3), 9+3*ER(-3),
    3, -3*E(3)^2, 3*E(3), -3, 3*E(3)^2, -3*E(3), 0, 0, 0 ] ] ],
##
[[1,2,5,6,7, 16,21, 24,25,30,31,32,33,34,35, 62,63],
 "$2^3:L_3(2) \\rightarrow (2.M_{22},4), (3.M_{22},3)$",
[ [ 1, 1, 1, 1, 1, 1, 14, 14, 14, 84, 84, 84, 336, 336, 336, 336, 336 ], 
  [ 1, 1, 1, 1, 1, 1, -8, -8, -8, 18, 18, 18, -60, -60, -60, 72, 72 ], 
  [ 1, 1, 1, 1, 1, 1, 8, 8, 8, 18, 18, 18, -12, -12, -12, -24, -24 ], 
  [ 1, 1, 1, 1, 1, 1, -6, -6, -6, 4, 4, 4, 16, 16, 16, -24, -24 ], 
  [ 1, 1, 1, 1, 1, 1, 2, 2, 2, -12, -12, -12, 0, 0, 0, 12, 12 ], 
  [ 1, -1, 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, -42 ], 
  [ 1, -1, 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -24, 24 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 10, 10*E(3), 10*E(3)^2, 36, 36*E(3), 
      36*E(3)^2, 48, 48*E(3), 48*E(3)^2, 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 10, 10*E(3)^2, 10*E(3), 36, 36*E(3)^2, 
      36*E(3), 48, 48*E(3)^2, 48*E(3), 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 0, 0, 0, -14, -14*E(3), -14*E(3)^2, 28, 
      28*E(3), 28*E(3)^2, 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 0, 0, 0, -14, -14*E(3)^2, -14*E(3), 28, 
      28*E(3)^2, 28*E(3), 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2,
   -1-ER(33), (-1-ER(33))*E(3), (-1-ER(33))*E(3)^2,
   3+ER(33), (3+ER(33))*E(3), (3+ER(33))*E(3)^2, 
   -18+2*ER(33), (-18+2*ER(33))*E(3), (-18+2*ER(33))*E(3)^2, 0, 0 ],
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 
   -1+ER(33), (-1+ER(33))*E(3)^2, (-1+ER(33))*E(3),
   3-ER(33), (3-ER(33))*E(3)^2, (3-ER(33))*E(3),
   -18-2*ER(33), (-18-2*ER(33))*E(3)^2, (-18-2*ER(33))*E(3), 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 
   -1+ER(33), (-1+ER(33))*E(3), (-1+ER(33))*E(3)^2,
    3-ER(33), (3-ER(33))*E(3), (3-ER(33))*E(3)^2,
   -18-2*ER(33), (-18-2*ER(33))*E(3), (-18-2*ER(33))*E(3)^2, 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 
   -1-ER(33), (-1-ER(33))*E(3)^2, (-1-ER(33))*E(3),
    3+ER(33), (3+ER(33))*E(3)^2, (3+ER(33))*E(3),
   -18+2*ER(33), (-18+2*ER(33))*E(3)^2, (-18+2*ER(33))*E(3), 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 0,0,0,0,0,0,0,0,0,0,0], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 0,0,0,0,0,0,0,0,0,0,0] ] ] ];

MULTFREEINFO.("12.M22"):=["$12.M_{22}$"];

MULTFREEINFO.("2.J2"):=["$2.J_2$",
##
[ [ 1, 6, 7, 25, 26 ],
"$U_3(3) \\rightarrow (J_2,1)$",
 [[1,1,36,36,126],
  [1,1,6,6,-14],
  [1,1,-4,-4,6],
  [1,-1,-6*ER(-1),6*ER(-1),0],
  [1,-1,6*ER(-1),-6*ER(-1),0]] ] ];

MULTFREEINFO.("2.HS"):=["$2.HS$",
##
[ [ 1, 2, 5, 7, 26, 27 ],
"$U_3(5) \\rightarrow (HS,3)$",
 [[1,1,1,1,350,350],
  [1,1,-1,-1,-70,70],
  [1,1,-1,-1,10,-10],
  [1,1,1,1,-2,-2],
  [1,-1,-ER(-1),ER(-1),0,0],
  [1,-1,ER(-1),-ER(-1),0,0]] ],
##
[ [ 1, 2, 6, 7, 26, 27 ],
"$U_3(5) \\rightarrow (HS,5)$",
 [[1,1,1,1,350,350],
  [1,1,-1,-1,-70,70],
  [1,1,-1,-1,10,-10],
  [1,1,1,1,-2,-2],
  [1,-1,-ER(-1),ER(-1),0,0],
  [1,-1,ER(-1),-ER(-1),0,0]] ],
##
[ [ 1, 2, 3, 4, 5, 6, 7, 9, 10, 26, 27, 30, 31 ],
"$A_8 \\rightarrow (HS,8)$",
 [[1,1,1,1,56,56,210,210,336,336,336,336,2520],
  [1,1,-1,-1,0,0,-70,70,-112,-112,112,112,0],
  [1,1,1,1,-24,-24,50,50,16,16,16,16,-120],
  [1,1,1,1,16,16,30,30,-24,-24,-24,-24,0],
  [1,1,-1,-1,-20,20,30,-30,-12,-12,12,12,0],
  [1,1,-1,-1,20,-20,30,-30,-12,-12,12,12,0],
  [1,1,1,1,12,12,-10,-10,28,28,28,28,-120],
  [1,1,1,1,-4,-4,-10,-10,-4,-4,-4,-4,40],
  [1,1,-1,-1,0,0,-10,10,8,8,-8,-8,0],
  [1,-1,ER(-1),-ER(-1),0,0,0,0,-42*ER(-1),42*ER(-1),42,-42,0],
  [1,-1,-ER(-1),ER(-1),0,0,0,0,42*ER(-1),-42*ER(-1),42,-42,0],
  [1,-1,ER(-1),-ER(-1),0,0,0,0,8*ER(-1),-8*ER(-1),-8,8,0],
  [1,-1,-ER(-1),ER(-1),0,0,0,0,-8*ER(-1),8*ER(-1),-8,8,0]] ],
##
[ [ 1, 2, 3, 5, 7, 10, 13, 16, 22, 25, 26, 27, 28, 29, 37, 38 ],
"$M_{11} \\rightarrow (HS,10)$",
 [[1,1,110,132,132,165,165,660,660,792,792,990,1320,1320,1980,1980],
  [1,1,10,52,52,-85,-85,-140,-140,72,72,390,-280,-280,180,180],
  [1,1,-40,37,37,40,40,85,85,-138,-138,90,-80,-80,30,30],
  [1,1,-38,-12,-12,-21,-21,84,84,72,72,54,-24,-24,-108,-108],
  [1,1,14,4,4,37,37,-44,-44,24,24,126,40,40,-132,-132],
  [1,1,-8,13,13,-16,-16,-11,-11,-18,-18,-6,56,56,-18,-18],
  [1,1,24,-11,-11,-8,-8,21,21,-26,-26,26,0,0,-2,-2],
  [1,1,12,13,13,4,4,9,9,22,22,-46,-24,-24,-8,-8],
  [1,1,-8,-7,-7,4,4,-11,-11,2,2,-6,-4,-4,22,22],
  [1,-1,0,-33,33,0,0,-165,165,198,-198,0,0,0,0,0],
  [1,-1,0,-28,28,35*ER(-1),-35*ER(-1),-40,40,-72,72,0,
   40*ER(-1),-40*ER(-1),-120*ER(-1),120*ER(-1)],
  [1,-1,0,-28,28,-35*ER(-1),35*ER(-1),-40,40,-72,72,0,
   -40*ER(-1),40*ER(-1),120*ER(-1),-120*ER(-1)],
  [1,-1,0,-13,13,20*ER(-1),-20*ER(-1),35,-35,18,-18,0,
   -20*ER(-1),20*ER(-1),60*ER(-1),-60*ER(-1)],
  [1,-1,0,-13,13,-20*ER(-1),20*ER(-1),35,-35,18,-18,0,
   20*ER(-1),-20*ER(-1),-60*ER(-1),60*ER(-1)],
  [1,-1,0,7,-7,0,0,-5,5,-2,2,0,40*ER(-1),-40*ER(-1),20*ER(-1),-20*ER(-1)],
  [1,-1,0,7,-7,0,0,-5,5,-2,2,0,-40*ER(-1),40*ER(-1),-20*ER(-1),20*ER(-1)]] ],
##
[ [ 1, 2, 3, 6, 7, 10, 13, 16, 22, 25, 26, 27, 28, 29, 37, 38 ],
"$M_{11} \\rightarrow (HS,11)$",
 [[1,1,110,132,132,165,165,660,660,792,792,990,1320,1320,1980,1980],
  [1,1,10,52,52,-85,-85,-140,-140,72,72,390,-280,-280,180,180],
  [1,1,-40,37,37,40,40,85,85,-138,-138,90,-80,-80,30,30],
  [1,1,-38,-12,-12,-21,-21,84,84,72,72,54,-24,-24,-108,-108],
  [1,1,14,4,4,37,37,-44,-44,24,24,126,40,40,-132,-132],
  [1,1,-8,13,13,-16,-16,-11,-11,-18,-18,-6,56,56,-18,-18],
  [1,1,24,-11,-11,-8,-8,21,21,-26,-26,26,0,0,-2,-2],
  [1,1,12,13,13,4,4,9,9,22,22,-46,-24,-24,-8,-8],
  [1,1,-8,-7,-7,4,4,-11,-11,2,2,-6,-4,-4,22,22],
  [1,-1,0,-33,33,0,0,-165,165,198,-198,0,0,0,0,0],
  [1,-1,0,-28,28,35*ER(-1),-35*ER(-1),-40,40,-72,72,0,
   40*ER(-1),-40*ER(-1),-120*ER(-1),120*ER(-1)],
  [1,-1,0,-28,28,-35*ER(-1),35*ER(-1),-40,40,-72,72,0,
   -40*ER(-1),40*ER(-1),120*ER(-1),-120*ER(-1)],
  [1,-1,0,-13,13,20*ER(-1),-20*ER(-1),35,-35,18,-18,0,
   -20*ER(-1),20*ER(-1),60*ER(-1),-60*ER(-1)],
  [1,-1,0,-13,13,-20*ER(-1),20*ER(-1),35,-35,18,-18,0,
   20*ER(-1),-20*ER(-1),-60*ER(-1),60*ER(-1)],
  [1,-1,0,7,-7,0,0,-5,5,-2,2,0,40*ER(-1),-40*ER(-1),20*ER(-1),-20*ER(-1)],
  [1,-1,0,7,-7,0,0,-5,5,-2,2,0,-40*ER(-1),40*ER(-1),-20*ER(-1),20*ER(-1)]]]];

MULTFREEINFO.("3.J3"):=["$3.J_3$"];

MULTFREEINFO.("3.McL"):=["$3.McL$",
##
[ [ 1, 4, 9, 14, 15, 20, 41, 42, 45, 46, 47, 48, 57, 58 ],
"$2.A_8 \\rightarrow (McL,6)$",
[ [1,1,1,630,2240,2240,2240,5040,5040,5040,8064,8064,8064,20160],
  [ 1, 1, 1, 135, 260, 260, 260, 90, 90, 90, 144, 144, 144, -1620], 
  [ 1, 1, 1, 117, -28, -28, -28, 72, 72, 72, -144, -144, -144, 180 ], 
  [ 1, 1, 1, -15, 60, 60, 60, -60, -60, -60, -56, -56, -56, 180 ], 
  [ 1, 1, 1, -45, -10, -10, -10, 90, 90, 90, -36, -36, -36, -90 ], 
  [ 1, 1, 1, 9, -28, -28, -28, -36, -36, -36, 72, 72, 72, -36 ], 
  [ 1, E(3), E(3)^2, 0, 80, 80*E(3), 80*E(3)^2, 90, 90*E(3), 90*E(3)^2, 144, 
      144*E(3), 144*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 0, 80, 80*E(3)^2, 80*E(3), 90, 90*E(3)^2, 90*E(3), 144, 
      144*E(3)^2, 144*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 0, 0, 0, 0, -120, -120*E(3), -120*E(3)^2, 64, 64*E(3), 
      64*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 0, 0, 0, 0, -120, -120*E(3)^2, -120*E(3), 64, 64*E(3)^2, 
      64*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 0, 35, 35*E(3), 35*E(3)^2, 0, 0, 0, -126, -126*E(3), 
      -126*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 0, 35, 35*E(3)^2, 35*E(3), 0, 0, 0, -126, -126*E(3)^2, 
      -126*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 0, -55, -55*E(3), -55*E(3)^2, 45, 45*E(3), 45*E(3)^2, 9, 
      9*E(3), 9*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 0, -55, -55*E(3)^2, -55*E(3), 45, 45*E(3)^2, 45*E(3), 9, 
      9*E(3)^2, 9*E(3), 0 ] ] ] ];

MULTFREEINFO.("2.Ru"):=["$2.Ru$",
##
[ [ 1, 4, 5, 6, 7, 37, 38, 43, 44 ],
"$^2F_4(2)^\\prime \\rightarrow (Ru,2)$",
 [[1,1,1,1,2304,2304,2304,2304,7020],
  [1,1,-1,-1,-144,-144,144,144,0],
  [1,1,1,1,64,64,64,64,-260],
  [1,1,1,1,-16,-16,-16,-16,60],
  [1,1,-1,-1,16,16,-16,-16,0],
  [1,-1,ER(-1),-ER(-1),-576*ER(-1),576*ER(-1),-576,576,0],
  [1,-1,-ER(-1),ER(-1),576*ER(-1),-576*ER(-1),-576,576,0],
  [1,-1,ER(-1),-ER(-1),4*ER(-1),-4*ER(-1),4,-4,0],
  [1,-1,-ER(-1),ER(-1),-4*ER(-1),4*ER(-1),4,-4,0]] ] ];

MULTFREEINFO.("2.Suz"):=["$2.Suz$",
##
[ [ 1, 2, 3, 9, 11, 12, 45, 46, 50, 51 ],
"$U_5(2) \\rightarrow (Suz,4)$",
 [[1,1,891,891,2816,2816,3960,12672,20736,20736],
  [1,1,243,243,512,512,-360,-1152,0,0],
  [1,1,-99,-99,176,176,660,-528,-144,-144],
  [1,1,33,33,8,8,60,192,-168,-168],
  [1,1,-27,-27,32,32,-60,48,0,0],
  [1,1,9,9,-40,-40,12,-96,72,72],
  [1,-1,-99*ER(-3),99*ER(-3),352,-352,0,0,-288*ER(-3),288*ER(-3)],
  [1,-1,99*ER(-3),-99*ER(-3),352,-352,0,0,288*ER(-3),-288*ER(-3)],
  [1,-1,-9*ER(-3),9*ER(-3),-8,8,0,0,72*ER(-3),-72*ER(-3)],
  [1,-1,9*ER(-3),-9*ER(-3),-8,8,0,0,-72*ER(-3),72*ER(-3)]] ] ];

MULTFREEINFO.("3.Suz"):=["$3.Suz$",
##
[ [ 1, 4, 5, 44, 45, 52, 53 ],
"$G_2(4) \\rightarrow (Suz,1)$",
 [[1,1,1,416,416,416,4095],
  [1,1,1,20,20,20,-63],
  [1,1,1,-16,-16,-16,45],
  [1,E(3),E(3)^2,-52-52*ER(-3),-52+52*ER(-3),104,0],
  [1,E(3)^2,E(3),-52+52*ER(-3),-52-52*ER(-3),104,0],
  [1,E(3),E(3)^2,2+2*ER(-3),2-2*ER(-3),-4,0],
  [1,E(3)^2,E(3),2-2*ER(-3),2+2*ER(-3),-4,0]] ],
##
[ [ 1, 2, 3, 9, 11, 12, 46, 47, 50, 51, 62, 63, 78, 79 ],
"$U_5(2) \\rightarrow (Suz,4)$",
[ [1,1,1,891,891,891,2816,2816,2816,5940,19008,20736,20736,20736], 
  [ 1, 1, 1, 243, 243, 243, 512, 512, 512, -540, -1728, 0, 0, 0 ], 
  [ 1, 1, 1, -99, -99, -99, 176, 176, 176, 990, -792, -144, -144, -144 ], 
  [ 1, 1, 1, 33, 33, 33, 8, 8, 8, 90, 288, -168, -168, -168 ], 
  [ 1, 1, 1, -27, -27, -27, 32, 32, 32, -90, 72, 0, 0, 0 ], 
  [ 1, 1, 1, 9, 9, 9, -40, -40, -40, 18, -144, 72, 72, 72 ], 
  [ 1, E(3), E(3)^2, -297, -297*E(3), -297*E(3)^2, 704, 704*E(3), 704*E(3)^2, 
      0, 0, -1728, -1728*E(3), -1728*E(3)^2 ], 
  [ 1, E(3)^2, E(3), -297, -297*E(3)^2, -297*E(3), 704, 704*E(3)^2, 704*E(3), 
      0, 0, -1728, -1728*E(3)^2, -1728*E(3) ], 
  [ 1, E(3), E(3)^2, 99, 99*E(3), 99*E(3)^2, 176, 176*E(3), 176*E(3)^2, 0, 0, 
      144, 144*E(3), 144*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 99, 99*E(3)^2, 99*E(3), 176, 176*E(3)^2, 176*E(3), 0, 0, 
      144, 144*E(3)^2, 144*E(3) ], 
  [ 1, E(3), E(3)^2, -45, -45*E(3), -45*E(3)^2, 32, 32*E(3), 32*E(3)^2, 0, 0, 
      288, 288*E(3), 288*E(3)^2 ], 
  [ 1, E(3)^2, E(3), -45, -45*E(3)^2, -45*E(3), 32, 32*E(3)^2, 32*E(3), 0, 0, 
      288, 288*E(3)^2, 288*E(3) ], 
  [ 1, E(3), E(3)^2, 3, 3*E(3), 3*E(3)^2, -16, -16*E(3), -16*E(3)^2, 0, 0, 
      -48, -48*E(3), -48*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 3, 3*E(3)^2, 3*E(3), -16, -16*E(3)^2, -16*E(3), 0, 0, 
      -48, -48*E(3)^2, -48*E(3) ] ] ],
##
[ [1,2,4,6,9,12,16,17,27,44,45,48,49,52,53,68,69,70,71,82,83,88,89],
"$2_-^{1+6}.U_4(2) \\rightarrow (Suz,5)$",
[ [ 1, 1, 1, 54, 54, 54, 1080, 1728, 1728, 1728, 5120, 5120, 5120, 9216, 
      9216, 9216, 17280, 17280, 17280, 55296, 55296, 55296, 138240 ], 
  [ 1, 1, 1, -27, -27, -27, 270, 432, 432, 432, 800, 800, 800, -1152, -1152, 
      -1152, -2160, -2160, -2160, 3456, 3456, 3456, -4320 ], 
  [ 1, 1, 1, 21, 21, 21, 90, 276, 276, 276, -160, -160, -160, 768, 768, 768, 
      120, 120, 120, 384, 384, 384, -4320 ], 
  [ 1, 1, 1, 3, 3, 3, -180, 132, 132, 132, 200, 200, 200, 48, 48, 48, -60, 
      -60, -60, -624, -624, -624, 1080 ], 
  [ 1, 1, 1, 15, 15, 15, 144, 12, 12, 12, 128, 128, 128, -144, -144, -144, 
      276, 276, 276, -240, -240, -240, -288 ], 
  [ 1, 1, 1, -9, -9, -9, 72, -36, -36, -36, 80, 80, 80, 144, 144, 144, -108, 
      -108, -108, -144, -144, -144, 144 ], 
  [ 1, 1, 1, -11, -11, -11, 30, 48, 48, 48, -80, -80, -80, -64, -64, -64, 80, 
      80, 80, -64, -64, -64, 240 ], 
  [ 1, 1, 1, 9, 9, 9, 18, 0, 0, 0, -64, -64, -64, 0, 0, 0, -144, -144, -144, 
      0, 0, 0, 576 ], 
  [ 1, 1, 1, 0, 0, 0, -36, -18, -18, -18, 8, 8, 8, -9, -9, -9, 36, 36, 36, 
      90, 90, 90, -288 ], 
  [ 1, E(3), E(3)^2, 27, 27*E(3), 27*E(3)^2, 0, 648, 648*E(3), 648*E(3)^2, 
      -640, -640*E(3), -640*E(3)^2, 2304, 2304*E(3), 2304*E(3)^2, -2160, 
      -2160*E(3), -2160*E(3)^2, 6912, 6912*E(3), 6912*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 27, 27*E(3)^2, 27*E(3), 0, 648, 648*E(3)^2, 648*E(3), 
      -640, -640*E(3)^2, -640*E(3), 2304, 2304*E(3)^2, 2304*E(3), -2160, 
      -2160*E(3)^2, -2160*E(3), 6912, 6912*E(3)^2, 6912*E(3), 0 ], 
  [ 1, E(3), E(3)^2, -18, -18*E(3), -18*E(3)^2, 0, 288, 288*E(3), 288*E(3)^2, 
      -640, -640*E(3), -640*E(3)^2, -576, -576*E(3), -576*E(3)^2, 1440, 
      1440*E(3), 1440*E(3)^2, 1152, 1152*E(3), 1152*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), -18, -18*E(3)^2, -18*E(3), 0, 288, 288*E(3)^2, 288*E(3), 
      -640, -640*E(3)^2, -640*E(3), -576, -576*E(3)^2, -576*E(3), 1440, 
      1440*E(3)^2, 1440*E(3), 1152, 1152*E(3)^2, 1152*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 15, 15*E(3), 15*E(3)^2, 0, 156, 156*E(3), 156*E(3)^2, 
      320, 320*E(3), 320*E(3)^2, 384, 384*E(3), 384*E(3)^2, 600, 600*E(3), 
      600*E(3)^2, -384, -384*E(3), -384*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 15, 15*E(3)^2, 15*E(3), 0, 156, 156*E(3)^2, 156*E(3), 
      320, 320*E(3)^2, 320*E(3), 384, 384*E(3)^2, 384*E(3), 600, 600*E(3)^2, 
      600*E(3), -384, -384*E(3)^2, -384*E(3), 0 ], 
  [ 1, E(3), E(3)^2, -12, -12*E(3), -12*E(3)^2, 0, 102, 102*E(3), 102*E(3)^2, 
      140, 140*E(3), 140*E(3)^2, -192, -192*E(3), -192*E(3)^2, -210, 
      -210*E(3), -210*E(3)^2, 48, 48*E(3), 48*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), -12, -12*E(3)^2, -12*E(3), 0, 102, 102*E(3)^2, 102*E(3), 
      140, 140*E(3)^2, 140*E(3), -192, -192*E(3)^2, -192*E(3), -210, 
      -210*E(3)^2, -210*E(3), 48, 48*E(3)^2, 48*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 10, 10*E(3), 10*E(3)^2, 0, 36, 36*E(3), 36*E(3)^2, -80, 
      -80*E(3), -80*E(3)^2, -16, -16*E(3), -16*E(3)^2, -100, -100*E(3), 
      -100*E(3)^2, -304, -304*E(3), -304*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 10, 10*E(3)^2, 10*E(3), 0, 36, 36*E(3)^2, 36*E(3), -80, 
      -80*E(3)^2, -80*E(3), -16, -16*E(3)^2, -16*E(3), -100, -100*E(3)^2, 
      -100*E(3), -304, -304*E(3)^2, -304*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 6, 6*E(3), 6*E(3)^2, 0, -24, -24*E(3), -24*E(3)^2, 32, 
      32*E(3), 32*E(3)^2, -48, -48*E(3), -48*E(3)^2, 24, 24*E(3), 24*E(3)^2, 
      192, 192*E(3), 192*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 6, 6*E(3)^2, 6*E(3), 0, -24, -24*E(3)^2, -24*E(3), 32, 
      32*E(3)^2, 32*E(3), -48, -48*E(3)^2, -48*E(3), 24, 24*E(3)^2, 24*E(3), 
      192, 192*E(3)^2, 192*E(3), 0 ], 
  [ 1, E(3), E(3)^2, -6, -6*E(3), -6*E(3)^2, 0, -12, -12*E(3), -12*E(3)^2, 
      -16, -16*E(3), -16*E(3)^2, 48, 48*E(3), 48*E(3)^2, 12, 12*E(3), 
      12*E(3)^2, -48, -48*E(3), -48*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), -6, -6*E(3)^2, -6*E(3), 0, -12, -12*E(3)^2, -12*E(3), 
      -16, -16*E(3)^2, -16*E(3), 48, 48*E(3)^2, 48*E(3), 12, 12*E(3)^2, 
      12*E(3), -48, -48*E(3)^2, -48*E(3), 0 ] ] ],
##
[ [ 1, 3, 4, 5, 9, 11, 12, 15, 17, 27, 28, 30, 33, 50, 51, 62, 63, 78, 79, 82,
  83, 94, 95, 96, 97, 104, 105 ],
"$2^{4+6}:3.A_6 \\rightarrow (Suz,6)$",
[ [ 1, 1, 1, 180, 480, 480, 480, 4608, 5760, 6144, 6144, 6144, 18432, 20480, 
      20480, 20480, 46080, 46080, 46080, 69120, 69120, 92160, 92160, 92160, 
      184320, 184320, 184320 ], 
  [ 1, 1, 1, -45, 30, 30, 30, 1008, 360, 1104, 1104, 1104, -288, -1120, 
      -1120, -1120, 2880, 2880, 2880, -6480, -1080, -5040, -5040, -5040, 
      4320, 4320, 4320 ], 
  [ 1, 1, 1, 81, 84, 84, 84, 648, 1008, -192, -192, -192, 2592, 1472, 1472, 
      1472, -1440, -1440, -1440, 216, 2592, -2880, -2880, -2880, 576, 576, 
      576 ], 
  [ 1, 1, 1, 45, -60, -60, -60, -468, 900, 96, 96, 96, 3312, -1120, -1120, 
      -1120, 720, 720, 720, -540, -2160, 1440, 1440, 1440, -1440, -1440, 
      -1440 ], 
  [ 1, 1, 1, 63, 90, 90, 90, -72, 144, 216, 216, 216, -288, -112, -112, -112, 
      -96, -96, -96, -1080, 1728, 744, 744, 744, -1008, -1008, -1008 ], 
  [ 1, 1, 1, -45, 30, 30, 30, -288, 360, 96, 96, 96, -288, 320, 320, 320, 0, 
      0, 0, 0, -1080, 0, 0, 0, 0, 0, 0 ], 
  [ 1, 1, 1, -9, 18, 18, 18, 72, -288, 264, 264, 264, 288, -16, -16, -16, 
      -288, -288, -288, 1080, -432, -72, -72, -72, -144, -144, -144 ], 
  [ 1, 1, 1, 21, -36, -36, -36, 348, 228, 48, 48, 48, -288, 112, 112, 112, 
      240, 240, 240, 516, -288, 240, 240, 240, -784, -784, -784 ], 
  [ 1, 1, 1, 45, 36, 36, 36, -36, 36, -96, -96, -96, -144, -160, -160, -160, 
      144, 144, 144, 756, -432, -288, -288, -288, 288, 288, 288 ], 
  [ 1, 1, 1, 18, 0, 0, 0, 18, -126, -24, -24, -24, 72, 128, 128, 128, 9, 9, 
      9, -540, -432, 144, 144, 144, 72, 72, 72 ], 
  [ 1, 1, 1, -27, 12, 12, 12, 108, 36, -48, -48, -48, 0, -112, -112, -112, 
      -144, -144, -144, -108, 0, 144, 144, 144, 144, 144, 144 ], 
  [ 1, 1, 1, -15, 0, 0, 0, -48, -60, -24, -24, -24, 72, 40, 40, 40, 240, 240, 
      240, 120, 360, -120, -120, -120, -280, -280, -280 ], 
  [ 1, 1, 1, 9, -24, -24, -24, -72, 36, 24, 24, 24, -72, -40, -40, -40, -144, 
      -144, -144, 0, 216, -72, -72, -72, 216, 216, 216 ], 
  [ 1, E(3), E(3)^2, 0, 60, 60*E(3), 60*E(3)^2, 0, 0, 432, 432*E(3), 
      432*E(3)^2, 0, -1120, -1120*E(3), -1120*E(3)^2, 2880, 2880*E(3), 
      2880*E(3)^2, 0, 0, 720, 720*E(3), 720*E(3)^2, 1440, 1440*E(3), 
      1440*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, 60, 60*E(3)^2, 60*E(3), 0, 0, 432, 432*E(3)^2, 
      432*E(3), 0, -1120, -1120*E(3)^2, -1120*E(3), 2880, 2880*E(3)^2, 
      2880*E(3), 0, 0, 720, 720*E(3)^2, 720*E(3), 1440, 1440*E(3)^2, 
      1440*E(3) ], 
  [ 1, E(3), E(3)^2, 0, 60, 60*E(3), 60*E(3)^2, 0, 0, 288, 288*E(3), 
      288*E(3)^2, 0, 320, 320*E(3), 320*E(3)^2, 0, 0, 0, 0, 0, 1440, 
      1440*E(3), 1440*E(3)^2, -2880, -2880*E(3), -2880*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, 60, 60*E(3)^2, 60*E(3), 0, 0, 288, 288*E(3)^2, 
      288*E(3), 0, 320, 320*E(3)^2, 320*E(3), 0, 0, 0, 0, 0, 1440, 
      1440*E(3)^2, 1440*E(3), -2880, -2880*E(3)^2, -2880*E(3) ], 
  [ 1, E(3), E(3)^2, 0, -36, -36*E(3), -36*E(3)^2, 0, 0, 240, 240*E(3), 
      240*E(3)^2, 0, 32, 32*E(3), 32*E(3)^2, -192, -192*E(3), -192*E(3)^2, 0, 
      0, -240, -240*E(3), -240*E(3)^2, 288, 288*E(3), 288*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, -36, -36*E(3)^2, -36*E(3), 0, 0, 240, 240*E(3)^2, 
      240*E(3), 0, 32, 32*E(3)^2, 32*E(3), -192, -192*E(3)^2, -192*E(3), 0, 
      0, -240, -240*E(3)^2, -240*E(3), 288, 288*E(3)^2, 288*E(3) ], 
  [ 1, E(3), E(3)^2, 0, 24, 24*E(3), 24*E(3)^2, 0, 0, 0, 0, 0, 0, 320, 
      320*E(3), 320*E(3)^2, 144, 144*E(3), 144*E(3)^2, 0, 0, 0, 0, 0, 576, 
      576*E(3), 576*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, 24, 24*E(3)^2, 24*E(3), 0, 0, 0, 0, 0, 0, 320, 
      320*E(3)^2, 320*E(3), 144, 144*E(3)^2, 144*E(3), 0, 0, 0, 0, 0, 576, 
      576*E(3)^2, 576*E(3) ], 
  [ 1, E(3), E(3)^2, 0, -24, -24*E(3), -24*E(3)^2, 0, 0, -48, -48*E(3), 
      -48*E(3)^2, 0, -16, -16*E(3), -16*E(3)^2, 0, 0, 0, 0, 0, 432, 432*E(3), 
      432*E(3)^2, 144, 144*E(3), 144*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, -24, -24*E(3)^2, -24*E(3), 0, 0, -48, -48*E(3)^2, 
      -48*E(3), 0, -16, -16*E(3)^2, -16*E(3), 0, 0, 0, 0, 0, 432, 432*E(3)^2, 
      432*E(3), 144, 144*E(3)^2, 144*E(3) ], 
  [ 1, E(3), E(3)^2, 0, 24, 24*E(3), 24*E(3)^2, 0, 0, 0, 0, 0, 0, -128, 
      -128*E(3), -128*E(3)^2, -192, -192*E(3), -192*E(3)^2, 0, 0, 0, 0, 0, 
      128, 128*E(3), 128*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, 24, 24*E(3)^2, 24*E(3), 0, 0, 0, 0, 0, 0, -128, 
      -128*E(3)^2, -128*E(3), -192, -192*E(3)^2, -192*E(3), 0, 0, 0, 0, 0, 
      128, 128*E(3)^2, 128*E(3) ], 
  [ 1, E(3), E(3)^2, 0, -6, -6*E(3), -6*E(3)^2, 0, 0, -30, -30*E(3), 
      -30*E(3)^2, 0, 2, 2*E(3), 2*E(3)^2, 108, 108*E(3), 108*E(3)^2, 0, 0, 
      -270, -270*E(3), -270*E(3)^2, -342, -342*E(3), -342*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 0, -6, -6*E(3)^2, -6*E(3), 0, 0, -30, -30*E(3)^2, 
      -30*E(3), 0, 2, 2*E(3)^2, 2*E(3), 108, 108*E(3)^2, 108*E(3), 0, 0, 
      -270, -270*E(3)^2, -270*E(3), -342, -342*E(3)^2, -342*E(3) ] ] ] ];

MULTFREEINFO.("6.Suz"):=["$6.Suz$",
##
[ [1,2,3,9,11,12, 45,46,50,51, 79,80,83,84,95,96,111,112, 
  153,154,157,158,159,160,177,178],
"$U_5(2) \\rightarrow (2.Suz,1), (3.Suz,2)$",
[ [ 1, 1, 1, 1, 1, 1, 891, 891, 891, 891, 891, 891, 2816, 2816, 2816, 2816, 
      2816, 2816, 11880, 20736, 20736, 20736, 20736, 20736, 20736, 38016 ], 
  [ 1, 1, 1, 1, 1, 1, 243, 243, 243, 243, 243, 243, 512, 512, 512, 512, 512, 
      512, -1080, 0, 0, 0, 0, 0, 0, -3456 ], 
  [ 1, 1, 1, 1, 1, 1, -99, -99, -99, -99, -99, -99, 176, 176, 176, 176, 176, 
      176, 1980, -144, -144, -144, -144, -144, -144, -1584 ], 
  [ 1, 1, 1, 1, 1, 1, 33, 33, 33, 33, 33, 33, 8, 8, 8, 8, 8, 8, 180, -168, 
      -168, -168, -168, -168, -168, 576 ], 
  [ 1, 1, 1, 1, 1, 1, -27, -27, -27, -27, -27, -27, 32, 32, 32, 32, 32, 32, 
      -180, 0, 0, 0, 0, 0, 0, 144 ], 
  [ 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, -40, -40, -40, -40, -40, -40, 36, 72, 
      72, 72, 72, 72, 72, -288 ],
  [1,-1,1,-1,1,-1,-99*ER(-3),99*ER(-3),-99*ER(-3),99*ER(-3),99*ER(-3),
   -99*ER(-3),-352,-352,352,352,-352,352,0,-288*ER(-3),-288*ER(-3),
   288*ER(-3),288*ER(-3),288*ER(-3),-288*ER(-3),0],
  [1,-1,1,-1,1,-1,99*ER(-3),-99*ER(-3),99*ER(-3),-99*ER(-3),-99*ER(-3),
   99*ER(-3),-352,-352,352,352,-352,352,0,288*ER(-3),288*ER(-3),
   -288*ER(-3),-288*ER(-3),-288*ER(-3),288*ER(-3),0],
  [1,-1,1,-1,1,-1,-9*ER(-3),9*ER(-3),-9*ER(-3),9*ER(-3),9*ER(-3),
  -9*ER(-3),8,8,-8,-8,8,-8,0,72*ER(-3),72*ER(-3),-72*ER(-3),-72*ER(-3),
  -72*ER(-3),72*ER(-3),0],
  [1,-1,1,-1,1,-1,9*ER(-3),-9*ER(-3),9*ER(-3),-9*ER(-3),-9*ER(-3),
   9*ER(-3),8,8,-8,-8,8,-8,0,-72*ER(-3),-72*ER(-3),72*ER(-3),72*ER(-3),
   72*ER(-3),-72*ER(-3),0 ],
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -297*E(3), -297*E(3), -297, -297, 
      -297*E(3)^2, -297*E(3)^2, 704, 704*E(3)^2, 704, 704*E(3)^2, 704*E(3), 
      704*E(3), 0, -1728*E(3)^2, -1728*E(3), -1728*E(3), -1728*E(3)^2, -1728, 
      -1728, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -297*E(3)^2, -297*E(3)^2, -297, -297, 
      -297*E(3), -297*E(3), 704, 704*E(3), 704, 704*E(3), 704*E(3)^2, 
      704*E(3)^2, 0, -1728*E(3), -1728*E(3)^2, -1728*E(3)^2, -1728*E(3), 
      -1728, -1728, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 99*E(3), 99*E(3), 99, 99, 99*E(3)^2, 
      99*E(3)^2, 176, 176*E(3)^2, 176, 176*E(3)^2, 176*E(3), 176*E(3), 0, 
      144*E(3)^2, 144*E(3), 144*E(3), 144*E(3)^2, 144, 144, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 99*E(3)^2, 99*E(3)^2, 99, 99, 99*E(3), 
      99*E(3), 176, 176*E(3), 176, 176*E(3), 176*E(3)^2, 176*E(3)^2, 0, 
      144*E(3), 144*E(3)^2, 144*E(3)^2, 144*E(3), 144, 144, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -45*E(3), -45*E(3), -45, -45, 
      -45*E(3)^2, -45*E(3)^2, 32, 32*E(3)^2, 32, 32*E(3)^2, 32*E(3), 32*E(3), 
      0, 288*E(3)^2, 288*E(3), 288*E(3), 288*E(3)^2, 288, 288, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -45*E(3)^2, -45*E(3)^2, -45, -45, 
      -45*E(3), -45*E(3), 32, 32*E(3), 32, 32*E(3), 32*E(3)^2, 32*E(3)^2, 0, 
      288*E(3), 288*E(3)^2, 288*E(3)^2, 288*E(3), 288, 288, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 3*E(3), 3*E(3), 3, 3, 3*E(3)^2, 
      3*E(3)^2, -16, -16*E(3)^2, -16, -16*E(3)^2, -16*E(3), -16*E(3), 0, 
      -48*E(3)^2, -48*E(3), -48*E(3), -48*E(3)^2, -48, -48, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 3*E(3)^2, 3*E(3)^2, 3, 3, 3*E(3), 
      3*E(3), -16, -16*E(3), -16, -16*E(3), -16*E(3)^2, -16*E(3)^2, 0, 
      -48*E(3), -48*E(3)^2, -48*E(3)^2, -48*E(3), -48, -48, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, -297*E(3)-594*E(3)^2, 
      297*E(3)+594*E(3)^2, -297*E(3)+297*E(3)^2, 297*E(3)-297*E(3)^2, 
      -594*E(3)-297*E(3)^2, 594*E(3)+297*E(3)^2, -1408, -1408*E(3)^2, 1408, 
      1408*E(3)^2, -1408*E(3), 1408*E(3), 0, 6912*E(3)+3456*E(3)^2, 
      -3456*E(3)-6912*E(3)^2, 3456*E(3)+6912*E(3)^2, -6912*E(3)-3456*E(3)^2, 
      3456*E(3)-3456*E(3)^2, -3456*E(3)+3456*E(3)^2, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), -594*E(3)-297*E(3)^2, 
      594*E(3)+297*E(3)^2, 297*E(3)-297*E(3)^2, -297*E(3)+297*E(3)^2, 
      -297*E(3)-594*E(3)^2, 297*E(3)+594*E(3)^2, -1408, -1408*E(3), 1408, 
      1408*E(3), -1408*E(3)^2, 1408*E(3)^2, 0, 3456*E(3)+6912*E(3)^2, 
      -6912*E(3)-3456*E(3)^2, 6912*E(3)+3456*E(3)^2, -3456*E(3)-6912*E(3)^2, 
      -3456*E(3)+3456*E(3)^2, 3456*E(3)-3456*E(3)^2, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, -63*E(3)-126*E(3)^2, 
      63*E(3)+126*E(3)^2, -63*E(3)+63*E(3)^2, 63*E(3)-63*E(3)^2, 
      -126*E(3)-63*E(3)^2, 126*E(3)+63*E(3)^2, -160, -160*E(3)^2, 160, 
      160*E(3)^2, -160*E(3), 160*E(3), 0, -576*E(3)-288*E(3)^2, 
      288*E(3)+576*E(3)^2, -288*E(3)-576*E(3)^2, 576*E(3)+288*E(3)^2, 
      -288*E(3)+288*E(3)^2, 288*E(3)-288*E(3)^2, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), -126*E(3)-63*E(3)^2, 
      126*E(3)+63*E(3)^2, 63*E(3)-63*E(3)^2, -63*E(3)+63*E(3)^2, 
      -63*E(3)-126*E(3)^2, 63*E(3)+126*E(3)^2, -160, -160*E(3), 160, 
      160*E(3), -160*E(3)^2, 160*E(3)^2, 0, -288*E(3)-576*E(3)^2, 
      576*E(3)+288*E(3)^2, -576*E(3)-288*E(3)^2, 288*E(3)+576*E(3)^2, 
      288*E(3)-288*E(3)^2, -288*E(3)+288*E(3)^2, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 33*E(3)+66*E(3)^2, 
      -33*E(3)-66*E(3)^2, 33*E(3)-33*E(3)^2, -33*E(3)+33*E(3)^2, 
      66*E(3)+33*E(3)^2, -66*E(3)-33*E(3)^2, -88, -88*E(3)^2, 88, 88*E(3)^2, 
      -88*E(3), 88*E(3), 0, -48*E(3)-24*E(3)^2, 24*E(3)+48*E(3)^2, 
      -24*E(3)-48*E(3)^2, 48*E(3)+24*E(3)^2, -24*E(3)+24*E(3)^2, 
      24*E(3)-24*E(3)^2, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 66*E(3)+33*E(3)^2, 
      -66*E(3)-33*E(3)^2, -33*E(3)+33*E(3)^2, 33*E(3)-33*E(3)^2, 
      33*E(3)+66*E(3)^2, -33*E(3)-66*E(3)^2, -88, -88*E(3), 88, 88*E(3), 
      -88*E(3)^2, 88*E(3)^2, 0, -24*E(3)-48*E(3)^2, 48*E(3)+24*E(3)^2, 
      -48*E(3)-24*E(3)^2, 24*E(3)+48*E(3)^2, 24*E(3)-24*E(3)^2, 
      -24*E(3)+24*E(3)^2, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, -3*E(3)-6*E(3)^2, 3*E(3)+6*E(3)^2, 
      -3*E(3)+3*E(3)^2, 3*E(3)-3*E(3)^2, -6*E(3)-3*E(3)^2, 6*E(3)+3*E(3)^2, 
      20, 20*E(3)^2, -20, -20*E(3)^2, 20*E(3), -20*E(3), 0, 24*E(3)+12*E(3)^2,
      -12*E(3)-24*E(3)^2, 12*E(3)+24*E(3)^2, -24*E(3)-12*E(3)^2, 
      12*E(3)-12*E(3)^2, -12*E(3)+12*E(3)^2, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), -6*E(3)-3*E(3)^2, 6*E(3)+3*E(3)^2, 
      3*E(3)-3*E(3)^2, -3*E(3)+3*E(3)^2, -3*E(3)-6*E(3)^2, 3*E(3)+6*E(3)^2, 
      20, 20*E(3), -20, -20*E(3), 20*E(3)^2, -20*E(3)^2, 0, 12*E(3)+24*E(3)^2,
      -24*E(3)-12*E(3)^2, 24*E(3)+12*E(3)^2, -12*E(3)-24*E(3)^2, 
      -12*E(3)+12*E(3)^2, 12*E(3)-12*E(3)^2, 0 ] ] ] ];

MULTFREEINFO.("3.ON"):=["$3.ON$",
##
[ [ 1, 2, 7, 8, 11, 37, 38, 51, 52, 53, 54 ],
"$L_3(7):2 \\rightarrow (ON,1)$",
[[1,1,1,5586,5586,5586,19152,58653,58653,58653,156408],
[1,1,1,196,196,196,-318,-252,-252,-252,483],
[1,1,1,-21,-21,-21,333,-252,-252,-252,483],
[1,1,1,42,42,42,144,189,189,189,-840],
[1,1,1,-56,-56,-56,-192,63,63,63,168],
[1,E(3),E(3)^2,798,798*E(3),798*E(3)^2,0,2793,2793*E(3),2793*E(3)^2,0],
[1,E(3)^2,E(3),798,798*E(3)^2,798*E(3),0,2793,2793*E(3)^2,2793*E(3),0],
[1,E(3),E(3)^2,54,54*E(3),54*E(3)^2,0,-183,-183*E(3),-183*E(3)^2,0],
[1,E(3)^2,E(3),54,54*E(3)^2,54*E(3),0,-183,-183*E(3)^2,-183*E(3),0],
[1,E(3),E(3)^2,-56,-56*E(3),-56*E(3)^2,0,147,147*E(3),147*E(3)^2,0],
[1,E(3)^2,E(3),-56,-56*E(3)^2,-56*E(3),0,147,147*E(3)^2,147*E(3),0]] ],
##
[ [ 1, 2, 7, 9, 11, 35, 36, 51, 52, 53, 54 ],
"$L_3(7):2 \\rightarrow (ON,3)$",
[[1,1,1,5586,5586,5586,19152,58653,58653,58653,156408],
[1,1,1,196,196,196,-318,-252,-252,-252,483],
[1,1,1,-21,-21,-21,333,-252,-252,-252,483],
[1,1,1,42,42,42,144,189,189,189,-840],
[1,1,1,-56,-56,-56,-192,63,63,63,168],
[1,E(3),E(3)^2,798,798*E(3),798*E(3)^2,0,2793,2793*E(3),2793*E(3)^2,0],
[1,E(3)^2,E(3),798,798*E(3)^2,798*E(3),0,2793,2793*E(3)^2,2793*E(3),0],
[1,E(3),E(3)^2,54,54*E(3),54*E(3)^2,0,-183,-183*E(3),-183*E(3)^2,0],
[1,E(3)^2,E(3),54,54*E(3)^2,54*E(3),0,-183,-183*E(3)^2,-183*E(3),0],
[1,E(3),E(3)^2,-56,-56*E(3),-56*E(3)^2,0,147,147*E(3),147*E(3)^2,0],
[1,E(3)^2,E(3),-56,-56*E(3)^2,-56*E(3),0,147,147*E(3)^2,147*E(3),0]] ],
##
[ [ 1, 2, 7, 8, 10, 11, 18, 37, 38, 51, 52, 53, 54, 59, 60 ],
"$L_3(7) \\rightarrow (ON,2)$",
[ [ 1, 1, 1, 1, 1, 1, 11172, 11172, 11172, 38304, 117306, 117306, 117306, 
      156408, 156408 ], 
  [ 1, 1, 1, 1, 1, 1, 392, 392, 392, -636, -504, -504, -504, 483, 483 ], 
  [ 1, 1, 1, 1, 1, 1, -42, -42, -42, 666, -504, -504, -504, 483, 483 ], 
  [ 1, 1, 1, 1, 1, 1, 84, 84, 84, 288, 378, 378, 378, -840, -840 ], 
  [ 1, -1, 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 0, -1029, 1029 ], 
  [ 1, 1, 1, 1, 1, 1, -112, -112, -112, -384, 126, 126, 126, 168, 168 ], 
  [ 1, -1, 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 0, 456, -456 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 1596, 1596*E(3), 1596*E(3)^2, 0, 5586, 
      5586*E(3), 5586*E(3)^2, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 1596, 1596*E(3)^2, 1596*E(3), 0, 5586, 
      5586*E(3)^2, 5586*E(3), 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 108, 108*E(3), 108*E(3)^2, 0, -366, 
      -366*E(3), -366*E(3)^2, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 108, 108*E(3)^2, 108*E(3), 0, -366, 
      -366*E(3)^2, -366*E(3), 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -112, -112*E(3), -112*E(3)^2, 0, 294, 
      294*E(3), 294*E(3)^2, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -112, -112*E(3)^2, -112*E(3), 0, 294, 
      294*E(3)^2, 294*E(3), 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ], 
##
[ [ 1, 2, 7, 9, 10, 11, 18, 35, 36, 51, 52, 53, 54, 59, 60 ],
"$L_3(7) \\rightarrow (ON,4)$",
[ [ 1, 1, 1, 1, 1, 1, 11172, 11172, 11172, 38304, 117306, 117306, 117306, 
      156408, 156408 ], 
  [ 1, 1, 1, 1, 1, 1, 392, 392, 392, -636, -504, -504, -504, 483, 483 ], 
  [ 1, 1, 1, 1, 1, 1, -42, -42, -42, 666, -504, -504, -504, 483, 483 ], 
  [ 1, 1, 1, 1, 1, 1, 84, 84, 84, 288, 378, 378, 378, -840, -840 ], 
  [ 1, -1, 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 0, -1029, 1029 ], 
  [ 1, 1, 1, 1, 1, 1, -112, -112, -112, -384, 126, 126, 126, 168, 168 ], 
  [ 1, -1, 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 0, 456, -456 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 1596, 1596*E(3), 1596*E(3)^2, 0, 5586, 
      5586*E(3), 5586*E(3)^2, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 1596, 1596*E(3)^2, 1596*E(3), 0, 5586, 
      5586*E(3)^2, 5586*E(3), 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 108, 108*E(3), 108*E(3)^2, 0, -366, 
      -366*E(3), -366*E(3)^2, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 108, 108*E(3)^2, 108*E(3), 0, -366, 
      -366*E(3)^2, -366*E(3), 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -112, -112*E(3), -112*E(3)^2, 0, 294, 
      294*E(3), 294*E(3)^2, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -112, -112*E(3)^2, -112*E(3), 0, 294, 
      294*E(3)^2, 294*E(3), 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ] ];

MULTFREEINFO.("2.Fi22"):=["$2.Fi_{22}$",
##
[ [ 1, 3, 9, 66, 73 ],
"$O_7(3) \\rightarrow (Fi_{22},2)$",
 [[1,1,3159,3159,21840],
  [1,1,279,279,-560],
  [1,1,-9,-9,16],
  [1,-1,351,-351,0],
  [1,-1,-9,9,0]] ],
##
[ [ 1, 3, 9, 66, 74 ],
"$O_7(3) \\rightarrow (Fi_{22},3)$",
 [[1,1,3159,3159,21840],
  [1,1,279,279,-560],
  [1,1,-9,-9,16],
  [1,-1,351,-351,0],
  [1,-1,-9,9,0]] ],
##
[ [ 1, 7, 9, 13, 73, 76 ],
"$O_8^+(2):S_3 \\rightarrow (Fi_{22},4)$",
 [[1,1,3150,22400,22400,75600],
  [1,1,342,-64,-64,-216],
  [1,1,-18,224,224,-432],
  [1,1,-18,-64,-64,144],
  [1,-1,0,-280,280,0],
  [1,-1,0,80,-80,0]] ],
##
[ [ 1, 7, 9, 13, 74, 77 ],
"$O_8^+(2):S_3 \\rightarrow (Fi_{22},4)$",
 [[1,1,3150,22400,22400,75600],
  [1,1,342,-64,-64,-216],
  [1,1,-18,224,224,-432],
  [1,1,-18,-64,-64,144],
  [1,-1,0,-280,280,0],
  [1,-1,0,80,-80,0]] ],
##
[ [ 1, 4, 7, 8, 9, 13, 15, 73, 74, 76, 77 ],
"$O_8^+(2):3 \\rightarrow (Fi_{22},5)$",
 [[1,1,1,1,3150,3150,22400,22400,22400,22400,151200],
  [1,1,-1,-1,-450,450,-800,800,-800,800,0],
  [1,1,1,1,342,342,-64,-64,-64,-64,-432],
  [1,1,-1,-1,126,-126,-224,224,-224,224,0],
  [1,1,1,1,-18,-18,224,224,224,224,-864],
  [1,1,1,1,-18,-18,-64,-64,-64,-64,288],
  [1,1,-1,-1,-18,18,64,-64,64,-64,0],
  [1,-1,-1,1,0,0,-280,-280,280,280,0],
  [1,-1,1,-1,0,0,280,-280,-280,280,0],
  [1,-1,-1,1,0,0,80,80,-80,-80,0],
  [1,-1,1,-1,0,0,-80,80,80,-80,0]] ],
##
[ [ 1, 3, 7, 9, 13, 14, 17, 66, 73, 76, 80 ],
"$O_8^+(2):2 \\rightarrow (Fi_{22},6)$",
 [[1,1,2,2,3150,6300,22400,22400,44800,44800,226800],
  [1,1,-1,-1,630,-630,2240,2240,-2240,-2240,0],
  [1,1,2,2,342,684,-64,-64,-128,-128,-648],
  [1,1,2,2,-18,-36,224,224,448,448,-1296],
  [1,1,2,2,-18,-36,-64,-64,-128,-128,432],
  [1,1,-1,-1,-90,90,80,80,-80,-80,0],
  [1,1,-1,-1,54,-54,-64,-64,64,64,0],
  [1,-1,1,-1,0,0,-2800,2800,2800,-2800,0],
  [1,-1,-2,2,0,0,-280,280,-560,560,0],
  [1,-1,-2,2,0,0,80,-80,160,-160,0],
  [1,-1,1,-1,0,0,8,-8,-8,8,0]] ],
##
[ [ 1, 3, 7, 9, 13, 14, 17, 66, 74, 77, 80 ],
"$O_8^+(2):2 \\rightarrow (Fi_{22},6)$",
 [[1,1,2,2,3150,6300,22400,22400,44800,44800,226800],
  [1,1,-1,-1,630,-630,2240,2240,-2240,-2240,0],
  [1,1,2,2,342,684,-64,-64,-128,-128,-648],
  [1,1,2,2,-18,-36,224,224,448,448,-1296],
  [1,1,2,2,-18,-36,-64,-64,-128,-128,432],
  [1,1,-1,-1,-90,90,80,80,-80,-80,0],
  [1,1,-1,-1,54,-54,-64,-64,64,64,0],
  [1,-1,1,-1,0,0,-2800,2800,2800,-2800,0],
  [1,-1,-2,2,0,0,-280,280,-560,560,0],
  [1,-1,-2,2,0,0,80,-80,160,-160,0],
  [1,-1,1,-1,0,0,8,-8,-8,8,0]] ] ];

MULTFREEINFO.("3.Fi22"):=["$3.Fi_{22}$",
##
[ [ 1, 7, 9, 13, 66, 67, 74, 75, 80, 81 ],
"$O_8^+(2):S_3 \\rightarrow (Fi_{22},4)$",
[[1,1,1,1575,1575,1575,37800,37800,37800,67200],
[1,1,1,171,171,171,-108,-108,-108,-192],
[1,1,1,-9,-9,-9,-216,-216,-216,672],
[1,1,1,-9,-9,-9,72,72,72,-192],
[1,E(3),E(3)^2,375,375*E(3),375*E(3)^2,1800,1800*E(3),1800*E(3)^2,0],
[1,E(3)^2,E(3),375,375*E(3)^2,375*E(3),1800,1800*E(3)^2,1800*E(3),0],
[1,E(3),E(3)^2,39,39*E(3),39*E(3)^2,-216,-216*E(3),-216*E(3)^2,0],
[1,E(3)^2,E(3),39,39*E(3)^2,39*E(3),-216,-216*E(3)^2,-216*E(3),0],
[1,E(3),E(3)^2,-21,-21*E(3),-21*E(3)^2,84,84*E(3),84*E(3)^2,0],
[1,E(3)^2,E(3),-21,-21*E(3)^2,-21*E(3),84,84*E(3)^2,84*E(3),0]] ],
##
[ [ 1, 4, 7, 8, 9, 13, 15, 78, 79, 88, 89 ],
"$O_8^+(2):3 \\rightarrow (Fi_{22},5)$",
[ [ 1, 1, 1, 3, 1575, 1575, 1575, 4725, 67200, 67200, 226800 ], 
  [ 1, 1, 1, -3, -225, -225, -225, 675, -2400, 2400, 0 ], 
  [ 1, 1, 1, 3, 171, 171, 171, 513, -192, -192, -648 ], 
  [ 1, 1, 1, -3, 63, 63, 63, -189, -672, 672, 0 ], 
  [ 1, 1, 1, 3, -9, -9, -9, -27, 672, 672, -1296 ], 
  [ 1, 1, 1, 3, -9, -9, -9, -27, -192, -192, 432 ], 
  [ 1, 1, 1, -3, -9, -9, -9, 27, 192, -192, 0 ], 
  [ 1, E(3), E(3)^2, 0, 75, 75*E(3), 75*E(3)^2, 0, 0, 0, 0 ], 
  [ 1, E(3)^2, E(3), 0, 75, 75*E(3)^2, 75*E(3), 0, 0, 0, 0 ], 
  [ 1, E(3), E(3)^2, 0, -21, -21*E(3), -21*E(3)^2, 0, 0, 0, 0 ], 
  [ 1, E(3)^2, E(3), 0, -21, -21*E(3)^2, -21*E(3), 0, 0, 0, 0 ] ] ],
##
[ [ 1, 4, 7, 8, 9, 13, 15, 66, 67, 68, 69, 74, 75, 80, 81, 84, 85 ],
"$O_8^+(2):3 \\rightarrow (Fi_{22},5)$",
[ [ 1, 1, 1, 1, 1, 1, 1575, 1575, 1575, 1575, 1575, 1575, 67200, 67200, 
      75600, 75600, 75600 ], 
  [ 1, -1, 1, -1, 1, -1, 225, 225, 225, -225, -225, -225, 2400, -2400, 0, 0, 
      0 ], 
  [ 1, 1, 1, 1, 1, 1, 171, 171, 171, 171, 171, 171, -192, -192, -216, -216, 
      -216 ],
  [ 1, -1, 1, -1, 1, -1, -63, -63, -63, 63, 63, 63, 672, -672, 0, 0, 0 ], 
  [ 1, 1, 1, 1, 1, 1, -9, -9, -9, -9, -9, -9, 672, 672, -432, -432, -432 ], 
  [ 1, 1, 1, 1, 1, 1, -9, -9, -9, -9, -9, -9, -192, -192, 144, 144, 144 ], 
  [ 1, -1, 1, -1, 1, -1, 9, 9, 9, -9, -9, -9, -192, 192, 0, 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 375, 375*E(3), 375*E(3)^2, 375, 
      375*E(3), 375*E(3)^2, 0, 0, 3600, 3600*E(3), 3600*E(3)^2 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 375, 375*E(3)^2, 375*E(3), 375, 
      375*E(3)^2, 375*E(3), 0, 0, 3600, 3600*E(3)^2, 3600*E(3) ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 105, 105*E(3), 105*E(3)^2, -105, 
      -105*E(3), -105*E(3)^2, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 105, 105*E(3)^2, 105*E(3), -105, 
      -105*E(3)^2, -105*E(3), 0, 0, 0, 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 39, 39*E(3), 39*E(3)^2, 39, 39*E(3), 
      39*E(3)^2, 0, 0, -432, -432*E(3), -432*E(3)^2 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 39, 39*E(3)^2, 39*E(3), 39, 39*E(3)^2, 
      39*E(3), 0, 0, -432, -432*E(3)^2, -432*E(3) ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -21, -21*E(3), -21*E(3)^2, -21, 
      -21*E(3), -21*E(3)^2, 0, 0, 168, 168*E(3), 168*E(3)^2 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -21, -21*E(3)^2, -21*E(3), -21, 
      -21*E(3)^2, -21*E(3), 0, 0, 168, 168*E(3)^2, 168*E(3) ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), -15, -15*E(3), -15*E(3)^2, 15, 
      15*E(3), 15*E(3)^2, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, -15, -15*E(3)^2, -15*E(3), 15, 
      15*E(3)^2, 15*E(3), 0, 0, 0, 0, 0 ] ] ],
##
[ [ 1, 3, 7, 9, 13, 14, 17, 66, 67, 74, 75, 78, 79, 80, 81, 88, 89 ],
"$O_8^+(2):2 \\rightarrow (Fi_{22},6)$",
[ [ 1, 1, 1, 2, 2, 2, 1575, 1575, 1575, 3150, 3150, 3150, 67200, 113400, 
      113400, 113400, 134400 ], 
  [ 1, 1, 1, -1, -1, -1, 315, 315, 315, -315, -315, -315, 6720, 0, 0, 0, 
      -6720 ], 
  [ 1, 1, 1, 2, 2, 2, 171, 171, 171, 342, 342, 342, -192, -324, -324, -324, 
      -384 ], [ 1, 1, 1, 2, 2, 2, -9, -9, -9, -18, -18, -18, 672, -648, -648, 
      -648, 1344 ], 
  [ 1, 1, 1, 2, 2, 2, -9, -9, -9, -18, -18, -18, -192, 216, 216, 216, -384 ], 
  [ 1, 1, 1, -1, -1, -1, -45, -45, -45, 45, 45, 45, 240, 0, 0, 0, -240 ], 
  [ 1, 1, 1, -1, -1, -1, 27, 27, 27, -27, -27, -27, -192, 0, 0, 0, 192 ], 
  [ 1, E(3), E(3)^2, 2, 2*E(3), 2*E(3)^2, 375, 375*E(3), 375*E(3)^2, 750, 
      750*E(3), 750*E(3)^2, 0, 5400, 5400*E(3), 5400*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 2, 2*E(3)^2, 2*E(3), 375, 375*E(3)^2, 375*E(3), 750, 
      750*E(3)^2, 750*E(3), 0, 5400, 5400*E(3)^2, 5400*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 2, 2*E(3), 2*E(3)^2, 39, 39*E(3), 39*E(3)^2, 78, 
      78*E(3), 78*E(3)^2, 0, -648, -648*E(3), -648*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 2, 2*E(3)^2, 2*E(3), 39, 39*E(3)^2, 39*E(3), 78, 
      78*E(3)^2, 78*E(3), 0, -648, -648*E(3)^2, -648*E(3), 0 ], 
  [ 1, E(3), E(3)^2, -1, -E(3), -E(3)^2, 75, 75*E(3), 75*E(3)^2, -75, 
      -75*E(3), -75*E(3)^2, 0, 0, 0, 0, 0 ], 
  [ 1, E(3)^2, E(3), -1, -E(3)^2, -E(3), 75, 75*E(3)^2, 75*E(3), -75, 
      -75*E(3)^2, -75*E(3), 0, 0, 0, 0, 0 ], 
  [ 1, E(3), E(3)^2, 2, 2*E(3), 2*E(3)^2, -21, -21*E(3), -21*E(3)^2, -42, 
      -42*E(3), -42*E(3)^2, 0, 252, 252*E(3), 252*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 2, 2*E(3)^2, 2*E(3), -21, -21*E(3)^2, -21*E(3), -42, 
      -42*E(3)^2, -42*E(3), 0, 252, 252*E(3)^2, 252*E(3), 0 ], 
  [ 1, E(3), E(3)^2, -1, -E(3), -E(3)^2, -21, -21*E(3), -21*E(3)^2, 21, 
      21*E(3), 21*E(3)^2, 0, 0, 0, 0, 0 ], 
  [ 1, E(3)^2, E(3), -1, -E(3)^2, -E(3), -21, -21*E(3)^2, -21*E(3), 21, 
      21*E(3)^2, 21*E(3), 0, 0, 0, 0, 0 ] ] ],
##
[[1,3,5,7,9,10,13,17,25,28,66,67,74,75,78,79,80,81,88,89,90,91,104,105],
"$2^6:S_6(2) \\rightarrow (Fi_{22},8)$",
[ [ 1, 1, 1, 135, 135, 135, 1260, 1260, 1260, 2304, 2304, 2304, 8640, 8640, 
      8640, 30240, 45360, 45360, 45360, 241920, 241920, 241920, 430080, 
      725760 ], 
  [ 1, 1, 1, -15, -15, -15, 210, 210, 210, 624, 624, 624, -960, -960, -960, 
      5040, 1260, 1260, 1260, -1680, -1680, -1680, 26880, -30240 ], 
  [ 1, 1, 1, -27, -27, -27, 126, 126, 126, -288, -288, -288, 216, 216, 216, 
      3024, -2268, -2268, -2268, 6048, 6048, 6048, -5376, -9072 ], 
  [ 1, 1, 1, 57, 57, 57, 246, 246, 246, 120, 120, 120, 840, 840, 840, 288, 
      1368, 1368, 1368, 120, 120, 120, -4224, -4320 ], 
  [ 1, 1, 1, 3, 3, 3, -60, -60, -60, 192, 192, 192, 192, 192, 192, 936, 
      -576, -576, -576, -960, -960, -960, -768, 3456 ], 
  [ 1, 1, 1, 21, 21, 21, 30, 30, 30, -96, -96, -96, -168, -168, -168, 720, 
      180, 180, 180, -672, -672, -672, -768, 2160 ], 
  [ 1, 1, 1, 27, 27, 27, 36, 36, 36, 0, 0, 0, 0, 0, 0, -432, -432, -432, 
      -432, 0, 0, 0, 1536, 0 ], 
  [ 1, 1, 1, -15, -15, -15, 66, 66, 66, 48, 48, 48, -96, -96, -96, -144, 
      -36, -36, -36, 48, 48, 48, -768, 864 ], 
  [ 1, 1, 1, -9, -9, -9, 0, 0, 0, -36, -36, -36, 72, 72, 72, 0, 0, 0, 0, 
      -252, -252, -252, 672, 0 ], 
  [ 1, 1, 1, 3, 3, 3, -24, -24, -24, 12, 12, 12, -24, -24, -24, -36, 72, 72, 
      72, 228, 228, 228, -336, -432 ], 
  [ 1, E(3), E(3)^2, 75, 75*E(3), 75*E(3)^2, 420, 420*E(3), 420*E(3)^2, 384, 
      384*E(3), 384*E(3)^2, 1920, 1920*E(3), 1920*E(3)^2, 0, 5040, 
      5040*E(3), 5040*E(3)^2, 13440, 13440*E(3), 13440*E(3)^2, 0, 0 ], 
  [ 1, E(3)^2, E(3), 75, 75*E(3)^2, 75*E(3), 420, 420*E(3)^2, 420*E(3), 384, 
      384*E(3)^2, 384*E(3), 1920, 1920*E(3)^2, 1920*E(3), 0, 5040, 
      5040*E(3)^2, 5040*E(3), 13440, 13440*E(3)^2, 13440*E(3), 0, 0 ], 
  [ 1, E(3), E(3)^2, 39, 39*E(3), 39*E(3)^2, 108, 108*E(3), 108*E(3)^2, 0, 
      0, 0, 192, 192*E(3), 192*E(3)^2, 0, -144, -144*E(3), -144*E(3)^2, 
      -1536, -1536*E(3), -1536*E(3)^2, 0, 0 ], 
  [ 1, E(3)^2, E(3), 39, 39*E(3)^2, 39*E(3), 108, 108*E(3)^2, 108*E(3), 0, 
      0, 0, 192, 192*E(3)^2, 192*E(3), 0, -144, -144*E(3)^2, -144*E(3), 
      -1536, -1536*E(3)^2, -1536*E(3), 0, 0 ], 
  [ 1, E(3), E(3)^2, -15, -15*E(3), -15*E(3)^2, 90, 90*E(3), 90*E(3)^2, 144, 
      144*E(3), 144*E(3)^2, -240, -240*E(3), -240*E(3)^2, 0, 180, 180*E(3), 
      180*E(3)^2, -240, -240*E(3), -240*E(3)^2, 0, 0 ], 
  [ 1, E(3)^2, E(3), -15, -15*E(3)^2, -15*E(3), 90, 90*E(3)^2, 90*E(3), 144, 
      144*E(3)^2, 144*E(3), -240, -240*E(3)^2, -240*E(3), 0, 180, 
      180*E(3)^2, 180*E(3), -240, -240*E(3)^2, -240*E(3), 0, 0 ], 
  [ 1, E(3), E(3)^2, 9, 9*E(3), 9*E(3)^2, -42, -42*E(3), -42*E(3)^2, 120, 
      120*E(3), 120*E(3)^2, 72, 72*E(3), 72*E(3)^2, 0, -504, -504*E(3), 
      -504*E(3)^2, 504, 504*E(3), 504*E(3)^2, 0, 0 ], 
  [ 1, E(3)^2, E(3), 9, 9*E(3)^2, 9*E(3), -42, -42*E(3)^2, -42*E(3), 120, 
      120*E(3)^2, 120*E(3), 72, 72*E(3)^2, 72*E(3), 0, -504, -504*E(3)^2, 
      -504*E(3), 504, 504*E(3)^2, 504*E(3), 0, 0 ], 
  [ 1, E(3), E(3)^2, -15, -15*E(3), -15*E(3)^2, 42, 42*E(3), 42*E(3)^2, -48, 
      -48*E(3), -48*E(3)^2, 48, 48*E(3), 48*E(3)^2, 0, -252, -252*E(3), 
      -252*E(3)^2, 336, 336*E(3), 336*E(3)^2, 0, 0 ], 
  [ 1, E(3)^2, E(3), -15, -15*E(3)^2, -15*E(3), 42, 42*E(3)^2, 42*E(3), -48, 
      -48*E(3)^2, -48*E(3), 48, 48*E(3)^2, 48*E(3), 0, -252, -252*E(3)^2, 
      -252*E(3), 336, 336*E(3)^2, 336*E(3), 0, 0 ], 
  [ 1, E(3), E(3)^2, 15, 15*E(3), 15*E(3)^2, 0, 0, 0, -36, -36*E(3), 
      -36*E(3)^2, -120, -120*E(3), -120*E(3)^2, 0, 0, 0, 0, 420, 420*E(3), 
      420*E(3)^2, 0, 0 ], 
  [ 1, E(3)^2, E(3), 15, 15*E(3)^2, 15*E(3), 0, 0, 0, -36, -36*E(3)^2, 
      -36*E(3), -120, -120*E(3)^2, -120*E(3), 0, 0, 0, 0, 420, 420*E(3)^2, 
      420*E(3), 0, 0 ], 
  [ 1, E(3), E(3)^2, -3, -3*E(3), -3*E(3)^2, -18, -18*E(3), -18*E(3)^2, 0, 
      0, 0, 24, 24*E(3), 24*E(3)^2, 0, 108, 108*E(3), 108*E(3)^2, -192, 
      -192*E(3), -192*E(3)^2, 0, 0 ], 
  [ 1, E(3)^2, E(3), -3, -3*E(3)^2, -3*E(3), -18, -18*E(3)^2, -18*E(3), 0, 
      0, 0, 24, 24*E(3)^2, 24*E(3), 0, 108, 108*E(3)^2, 108*E(3), -192, 
      -192*E(3)^2, -192*E(3), 0, 0 ] ] ],
##
[ [1,4,5,9,10,26,31,32,39,45,53,
   74,75,78,79,82,83,104,105,106,107,140,141,142,143],
 "$^2F_4(2)^\\prime \\rightarrow (Fi_{22},9)$",
[ [ 1, 1, 1, 1755, 1755, 1755, 11700, 11700, 11700, 44928, 140400, 140400, 
      140400, 187200, 187200, 187200, 249600, 249600, 449280, 449280, 
      449280, 1123200, 2246400, 2246400, 2246400 ], 
  [ 1, 1, 1, -405, -405, -405, 900, 900, 900, -1728, -10800, -10800, -10800, 
      14400, 14400, 14400, -9600, -9600, 17280, 17280, 17280, -43200, 0, 0, 
      0 ], [ 1, 1, 1, -189, -189, -189, 1980, 1980, 1980, -1728, 4320, 4320, 
      4320, -7200, -7200, -7200, 16320, 16320, 13824, 13824, 13824, -43200, 
      -8640, -8640, -8640 ], 
  [ 1, 1, 1, 171, 171, 171, 612, 612, 612, -2592, 1008, 1008, 1008, 3456, 
      3456, 3456, 2496, 2496, -576, -576, -576, 11232, -9216, -9216, -9216 ],
  [ 1, 1, 1, 99, 99, 99, 540, 540, 540, 1728, -1440, -1440, -1440, -1440, 
      -1440, -1440, -960, -960, 2304, 2304, 2304, 8640, -2880, -2880, -2880 ]
    , [ 1, 1, 1, 75, 75, 75, -60, -60, -60, 576, 624, 624, 624, 384, 384, 
      384, -384, -384, 384, 384, 384, -1728, -768, -768, -768 ], 
  [ 1, 1, 1, 27, 27, 27, 36, 36, 36, -432, 0, 0, 0, -288, -288, -288, 768, 
      -1824, 0, 0, 0, -432, 864, 864, 864 ], 
  [ 1, 1, 1, 27, 27, 27, 36, 36, 36, -432, 0, 0, 0, -288, -288, -288, -1824, 
      768, 0, 0, 0, -432, 864, 864, 864 ], 
  [ 1, 1, 1, -21, -21, -21, 132, 132, 132, 288, -48, -48, -48, 192, 192, 
      192, 192, 192, -960, -960, -960, -864, 768, 768, 768 ], 
  [ 1, 1, 1, 27, 27, 27, -108, -108, -108, 0, -432, -432, -432, 0, 0, 0, 
      768, 768, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, 1, 1, -45, -45, -45, -36, -36, -36, 0, 144, 144, 144, 0, 0, 0, -96, 
      -96, 288, 288, 288, 864, -576, -576, -576 ], 
  [ 1, E(3), E(3)^2, 219, 219*E(3), 219*E(3)^2, 180, 180*E(3), 180*E(3)^2, 
      0, -1680, -1680*E(3), -1680*E(3)^2, 2880, 2880*E(3), 2880*E(3)^2, 0, 
      0, 6144, 6144*E(3), 6144*E(3)^2, 0, 3840, 3840*E(3), 3840*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 219, 219*E(3)^2, 219*E(3), 180, 180*E(3)^2, 180*E(3), 
      0, -1680, -1680*E(3)^2, -1680*E(3), 2880, 2880*E(3)^2, 2880*E(3), 0, 
      0, 6144, 6144*E(3)^2, 6144*E(3), 0, 3840, 3840*E(3)^2, 3840*E(3) ], 
  [ 1, E(3), E(3)^2, 75, 75*E(3), 75*E(3)^2, 900, 900*E(3), 900*E(3)^2, 0, 
      1200, 1200*E(3), 1200*E(3)^2, 0, 0, 0, 0, 0, -1920, -1920*E(3), 
      -1920*E(3)^2, 0, 9600, 9600*E(3), 9600*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 75, 75*E(3)^2, 75*E(3), 900, 900*E(3)^2, 900*E(3), 0, 
      1200, 1200*E(3)^2, 1200*E(3), 0, 0, 0, 0, 0, -1920, -1920*E(3)^2, 
      -1920*E(3), 0, 9600, 9600*E(3)^2, 9600*E(3) ], 
  [ 1, E(3), E(3)^2, -117, -117*E(3), -117*E(3)^2, -156, -156*E(3), 
      -156*E(3)^2, 0, 1872, 1872*E(3), 1872*E(3)^2, 2496, 2496*E(3), 
      2496*E(3)^2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, E(3)^2, E(3), -117, -117*E(3)^2, -117*E(3), -156, -156*E(3)^2, 
      -156*E(3), 0, 1872, 1872*E(3)^2, 1872*E(3), 2496, 2496*E(3)^2, 
      2496*E(3), 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, E(3), E(3)^2, 51, 51*E(3), 51*E(3)^2, 12, 12*E(3), 12*E(3)^2, 0, 672, 
      672*E(3), 672*E(3)^2, -480, -480*E(3), -480*E(3)^2, 0, 0, 768, 
      768*E(3), 768*E(3)^2, 0, -1536, -1536*E(3), -1536*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 51, 51*E(3)^2, 51*E(3), 12, 12*E(3)^2, 12*E(3), 0, 672, 
      672*E(3)^2, 672*E(3), -480, -480*E(3)^2, -480*E(3), 0, 0, 768, 
      768*E(3)^2, 768*E(3), 0, -1536, -1536*E(3)^2, -1536*E(3) ], 
  [ 1, E(3), E(3)^2, -69, -69*E(3), -69*E(3)^2, 180, 180*E(3), 180*E(3)^2, 
      0, -240, -240*E(3), -240*E(3)^2, 0, 0, 0, 0, 0, 384, 384*E(3), 
      384*E(3)^2, 0, -1920, -1920*E(3), -1920*E(3)^2 ], 
  [ 1, E(3)^2, E(3), -69, -69*E(3)^2, -69*E(3), 180, 180*E(3)^2, 180*E(3), 
      0, -240, -240*E(3)^2, -240*E(3), 0, 0, 0, 0, 0, 384, 384*E(3)^2, 
      384*E(3), 0, -1920, -1920*E(3)^2, -1920*E(3) ], 
  [ 1, E(3), E(3)^2, -21, -21*E(3), -21*E(3)^2, -60, -60*E(3), -60*E(3)^2, 
      0, -48, -48*E(3), -48*E(3)^2, -192, -192*E(3), -192*E(3)^2, 0, 0, 192, 
      192*E(3), 192*E(3)^2, 0, 1344, 1344*E(3), 1344*E(3)^2 ], 
  [ 1, E(3)^2, E(3), -21, -21*E(3)^2, -21*E(3), -60, -60*E(3)^2, -60*E(3), 
      0, -48, -48*E(3)^2, -48*E(3), -192, -192*E(3)^2, -192*E(3), 0, 0, 192, 
      192*E(3)^2, 192*E(3), 0, 1344, 1344*E(3)^2, 1344*E(3) ], 
  [ 1, E(3), E(3)^2, 27, 27*E(3), 27*E(3)^2, -12, -12*E(3), -12*E(3)^2, 0, 
      -144, -144*E(3), -144*E(3)^2, 192, 192*E(3), 192*E(3)^2, 0, 0, -576, 
      -576*E(3), -576*E(3)^2, 0, -576, -576*E(3), -576*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 27, 27*E(3)^2, 27*E(3), -12, -12*E(3)^2, -12*E(3), 0, 
      -144, -144*E(3)^2, -144*E(3), 192, 192*E(3)^2, 192*E(3), 0, 0, -576, 
      -576*E(3)^2, -576*E(3), 0, -576, -576*E(3)^2, -576*E(3) ] ] ] ];

MULTFREEINFO.("6.Fi22"):=["$6.Fi_{22}$",
##
[ [ 1, 7, 9, 13, 73, 76, 115, 116, 123, 124, 129, 130, 219, 220 ],
"$O_8^+(2):S_3 \\rightarrow (2.Fi_{22},3), (3.Fi_{22},1)$",
[ [ 1, 1, 1, 1, 1, 1, 3150, 3150, 3150, 67200, 67200, 75600, 75600, 75600 ], 
  [ 1, 1, 1, 1, 1, 1, 342, 342, 342, -192, -192, -216, -216, -216 ], 
  [ 1, 1, 1, 1, 1, 1, -18, -18, -18, 672, 672, -432, -432, -432 ], 
  [ 1, 1, 1, 1, 1, 1, -18, -18, -18, -192, -192, 144, 144, 144 ], 
  [ 1, -1, 1, -1, 1, -1, 0, 0, 0, 840, -840, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, 0, 0, 0, -240, 240, 0, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 750, 750*E(3)^2, 750*E(3), 0, 0, 3600, 
      3600*E(3)^2, 3600*E(3) ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 750, 750*E(3), 750*E(3)^2, 0, 0, 3600, 
      3600*E(3), 3600*E(3)^2 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 78, 78*E(3)^2, 78*E(3), 0, 0, -432, 
      -432*E(3)^2, -432*E(3) ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 78, 78*E(3), 78*E(3)^2, 0, 0, -432, 
      -432*E(3), -432*E(3)^2 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -42, -42*E(3)^2, -42*E(3), 0, 0, 168, 
      168*E(3)^2, 168*E(3) ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -42, -42*E(3), -42*E(3)^2, 0, 0, 168, 
      168*E(3), 168*E(3)^2 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 0, 0, 0, 0, 0, 0, 0, 0 ] ] ],
##
[ [ 1, 7, 9, 13, 74, 77, 115, 116, 123, 124, 129, 130, 221, 222 ],
"$O_8^+(2):S_3 \\rightarrow (2.Fi_{22},4), (3.Fi_{22},1)$",
[ [ 1, 1, 1, 1, 1, 1, 3150, 3150, 3150, 67200, 67200, 75600, 75600, 75600 ], 
  [ 1, 1, 1, 1, 1, 1, 342, 342, 342, -192, -192, -216, -216, -216 ], 
  [ 1, 1, 1, 1, 1, 1, -18, -18, -18, 672, 672, -432, -432, -432 ], 
  [ 1, 1, 1, 1, 1, 1, -18, -18, -18, -192, -192, 144, 144, 144 ], 
  [ 1, -1, 1, -1, 1, -1, 0, 0, 0, 840, -840, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, 0, 0, 0, -240, 240, 0, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 750, 750*E(3)^2, 750*E(3), 0, 0, 3600, 
      3600*E(3)^2, 3600*E(3) ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 750, 750*E(3), 750*E(3)^2, 0, 0, 3600, 
      3600*E(3), 3600*E(3)^2 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 78, 78*E(3)^2, 78*E(3), 0, 0, -432, 
      -432*E(3)^2, -432*E(3) ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 78, 78*E(3), 78*E(3)^2, 0, 0, -432, 
      -432*E(3), -432*E(3)^2 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -42, -42*E(3)^2, -42*E(3), 0, 0, 168, 
      168*E(3)^2, 168*E(3) ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -42, -42*E(3), -42*E(3)^2, 0, 0, 168, 
      168*E(3), 168*E(3)^2 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 0, 0, 0, 0, 0, 0, 0, 0 ] ] ],
##
[ [ 1,4,7,8,9,13,15, 73,74,76,77, 127,128,137,138, 231,232],
"$O_8^+(2):3 \\rightarrow (2.Fi_{22},5), (3.Fi_{22},2)$", 
[ [ 1, 1, 1, 1, 1, 1, 3, 3, 3150, 3150, 3150, 9450, 67200, 67200, 67200, 
      67200, 453600 ], 
  [ 1, 1, 1, 1, 1, 1, -3, -3, -450, -450, -450, 1350, 2400, 2400, -2400, 
      -2400, 0 ], 
  [ 1, 1, 1, 1, 1, 1, 3, 3, 342, 342, 342, 1026, -192, -192, -192, -192, 
      -1296 ], 
  [ 1, 1, 1, 1, 1, 1, -3, -3, 126, 126, 126, -378, 672, 672, -672, -672, 0 ], 
  [ 1, 1, 1, 1, 1, 1, 3, 3, -18, -18, -18, -54, 672, 672, 672, 672, -2592 ], 
  [ 1, 1, 1, 1, 1, 1, 3, 3, -18, -18, -18, -54, -192, -192, -192, -192, 864 ],
  [ 1, 1, 1, 1, 1, 1, -3, -3, -18, -18, -18, 54, -192, -192, 192, 192, 0 ], 
  [ 1, -1, 1, -1, 1, -1, -3, 3, 0, 0, 0, 0, -840, 840, -840, 840, 0 ], 
  [ 1, -1, 1, -1, 1, -1, 3, -3, 0, 0, 0, 0, -840, 840, 840, -840, 0 ], 
  [ 1, -1, 1, -1, 1, -1, -3, 3, 0, 0, 0, 0, 240, -240, 240, -240, 0 ], 
  [ 1, -1, 1, -1, 1, -1, 3, -3, 0, 0, 0, 0, 240, -240, -240, 240, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 0, 0, 150, 150*E(3), 150*E(3)^2, 0, 0, 
      0, 0, 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 0, 0, 150, 150*E(3)^2, 150*E(3), 0, 0, 
      0, 0, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 0, 0, -42, -42*E(3), -42*E(3)^2, 0, 0, 
      0, 0, 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 0, 0, -42, -42*E(3)^2, -42*E(3), 0, 0, 
      0, 0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]]],
##
[ [1,4,7,8,9,13,15, 73,74,76,77,
   115,116,117,118,123,124,129,130,133,134, 219,220,221,222],
"$O_8^+(2):3 \\rightarrow (2.Fi_{22},5), (3.Fi_{22},3)$",
[ [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3150, 3150, 3150, 3150, 3150, 3150, 
      67200, 67200, 67200, 67200, 151200, 151200, 151200 ], 
  [ 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1, -450, 450, -450, 450, -450, 
      450, -2400, 2400, 2400, -2400, 0, 0, 0 ], 
  [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 342, 342, 342, 342, 342, 342, -192, 
      -192, -192, -192, -432, -432, -432 ], 
  [ 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1, 126, -126, 126, -126, 126, 
      -126, -672, 672, 672, -672, 0, 0, 0 ], 
  [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -18, -18, -18, -18, -18, -18, 672, 
      672, 672, 672, -864, -864, -864 ], 
  [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -18, -18, -18, -18, -18, -18, -192, 
      -192, -192, -192, 288, 288, 288 ], 
  [ 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1, -18, 18, -18, 18, -18, 18, 192, 
      -192, -192, 192, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 840, 840, 
      -840, -840, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 0, 0, 0, 0, 0, 0, -840, 840, 
      -840, 840, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, -240, -240, 
      240, 240, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 0, 0, 0, 0, 0, 0, 240, -240, 
      240, -240, 0, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 1, E(3), E(3)^2, 1, E(3), E(3)^2, 750, 
      750*E(3), 750*E(3)^2, 750, 750*E(3), 750*E(3)^2, 0, 0, 0, 0, 7200, 
      7200*E(3), 7200*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 1, E(3)^2, E(3), 1, E(3)^2, E(3), 750, 
      750*E(3)^2, 750*E(3), 750, 750*E(3)^2, 750*E(3), 0, 0, 0, 0, 7200, 
      7200*E(3)^2, 7200*E(3) ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -1, -E(3), -E(3)^2, -1, -E(3), -E(3)^2, 
      -210, 210*E(3), -210*E(3)^2, 210, -210*E(3), 210*E(3)^2, 0, 0, 0, 0, 0, 
      0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -1, -E(3)^2, -E(3), -1, -E(3)^2, -E(3), 
      -210, 210*E(3)^2, -210*E(3), 210, -210*E(3)^2, 210*E(3), 0, 0, 0, 0, 0, 
      0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 1, E(3), E(3)^2, 1, E(3), E(3)^2, 78, 
      78*E(3), 78*E(3)^2, 78, 78*E(3), 78*E(3)^2, 0, 0, 0, 0, -864, 
      -864*E(3), -864*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 1, E(3)^2, E(3), 1, E(3)^2, E(3), 78, 
      78*E(3)^2, 78*E(3), 78, 78*E(3)^2, 78*E(3), 0, 0, 0, 0, -864, 
      -864*E(3)^2, -864*E(3) ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 1, E(3), E(3)^2, 1, E(3), E(3)^2, -42, 
      -42*E(3), -42*E(3)^2, -42, -42*E(3), -42*E(3)^2, 0, 0, 0, 0, 336, 
      336*E(3), 336*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 1, E(3)^2, E(3), 1, E(3)^2, E(3), -42, 
      -42*E(3)^2, -42*E(3), -42, -42*E(3)^2, -42*E(3), 0, 0, 0, 0, 336, 
      336*E(3)^2, 336*E(3) ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -1, -E(3), -E(3)^2, -1, -E(3), -E(3)^2, 
   30, -30*E(3), 30*E(3)^2, -30, 30*E(3), -30*E(3)^2, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -1, -E(3)^2, -E(3), -1, -E(3)^2, 
      -E(3), 30, -30*E(3)^2, 30*E(3), -30, 30*E(3)^2, -30*E(3), 0, 0, 0, 0, 
      0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, -1, E(3), -E(3)^2, 1, -E(3), E(3)^2, 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), -1, E(3)^2, -E(3), 1, -E(3)^2, E(3), 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ],
##
[ [1,3,7,9,13,14,17, 66,73,76,80,
   115,116,123,124,127,128,129,130,137,138, 219,220,231,232],
"$O_8^+(2):2 \\rightarrow (2.Fi_{22},6), (3.Fi_{22},4)$",
[ [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3150, 3150, 3150, 6300, 6300, 6300, 
      67200, 67200, 134400, 134400, 226800, 226800, 226800 ], 
  [ 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1, 630, 630, 630, -630, -630, 
      -630, 6720, 6720, -6720, -6720, 0, 0, 0 ], 
  [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 342, 342, 342, 684, 684, 684, -192, 
      -192, -384, -384, -648, -648, -648 ], 
  [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, -18, -18, -18, -36, -36, -36, 672, 
      672, 1344, 1344, -1296, -1296, -1296 ], 
  [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, -18, -18, -18, -36, -36, -36, -192, 
      -192, -384, -384, 432, 432, 432 ], 
  [ 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1, -90, -90, -90, 90, 90, 90, 240, 
      240, -240, -240, 0, 0, 0 ], 
  [ 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1, 54, 54, 54, -54, -54, -54, 
      -192, -192, 192, 192, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 0, 0, 0, 0, 0, 0, 8400, -8400, 
      -8400, 8400, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, 2, -2, 2, -2, 2, -2, 0, 0, 0, 0, 0, 0, 840, -840, 
      1680, -1680, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, 2, -2, 2, -2, 2, -2, 0, 0, 0, 0, 0, 0, -240, 240, 
      -480, 480, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 0, 0, 0, 0, 0, 0, -24, 24, 24, 
      -24, 0, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 2, 2*E(3), 2*E(3)^2, 2, 2*E(3), 
      2*E(3)^2, 750, 750*E(3), 750*E(3)^2, 1500, 1500*E(3)^2, 1500*E(3), 0, 
      0, 0, 0, 10800, 10800*E(3), 10800*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 2, 2*E(3)^2, 2*E(3), 2, 2*E(3)^2, 
      2*E(3), 750, 750*E(3)^2, 750*E(3), 1500, 1500*E(3), 1500*E(3)^2, 0, 0, 
      0, 0, 10800, 10800*E(3)^2, 10800*E(3) ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 2, 2*E(3), 2*E(3)^2, 2, 2*E(3), 
      2*E(3)^2, 78, 78*E(3), 78*E(3)^2, 156, 156*E(3)^2, 156*E(3), 0, 0, 0, 
      0, -1296, -1296*E(3), -1296*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 2, 2*E(3)^2, 2*E(3), 2, 2*E(3)^2, 
      2*E(3), 78, 78*E(3)^2, 78*E(3), 156, 156*E(3), 156*E(3)^2, 0, 0, 0, 0, 
      -1296, -1296*E(3)^2, -1296*E(3) ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -1, -E(3), -E(3)^2, -1, -E(3), -E(3)^2, 
      150, 150*E(3), 150*E(3)^2, -150, -150*E(3)^2, -150*E(3), 0, 0, 0, 0, 0, 
      0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -1, -E(3)^2, -E(3), -1, -E(3)^2, -E(3), 
      150, 150*E(3)^2, 150*E(3), -150, -150*E(3), -150*E(3)^2, 0, 0, 0, 0, 0, 
      0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 2, 2*E(3), 2*E(3)^2, 2, 2*E(3), 
      2*E(3)^2, -42, -42*E(3), -42*E(3)^2, -84, -84*E(3)^2, -84*E(3), 0, 0, 
      0, 0, 504, 504*E(3), 504*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 2, 2*E(3)^2, 2*E(3), 2, 2*E(3)^2, 
      2*E(3), -42, -42*E(3)^2, -42*E(3), -84, -84*E(3), -84*E(3)^2, 0, 0, 0, 
      0, 504, 504*E(3)^2, 504*E(3) ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -1, -E(3), -E(3)^2, -1, -E(3), -E(3)^2, 
      -42, -42*E(3), -42*E(3)^2, 42, 42*E(3)^2, 42*E(3), 0, 0, 0, 0, 0, 0, 0 ]
    , [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -1, -E(3)^2, -E(3), -1, -E(3)^2, 
      -E(3), -42, -42*E(3)^2, -42*E(3), 42, 42*E(3), 42*E(3)^2, 0, 0, 0, 0, 
      0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 2, -2*E(3), 2*E(3)^2, -2, 2*E(3), 
      -2*E(3)^2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 2, -2*E(3)^2, 2*E(3), -2, 2*E(3)^2, 
      -2*E(3), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, -1, E(3), -E(3)^2, 1, -E(3), E(3)^2, 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), -1, E(3)^2, -E(3), 1, -E(3)^2, E(3), 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ],
##
[ [1,3,7,9,13,14,17, 66,74,77,80, 
   115,116,123,124,127,128,129,130,137,138, 221,222,231,232],
"$O_8^+(2):2 \\rightarrow (2.Fi_{22},7), (3.Fi_{22},4)$",
[ [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3150, 3150, 3150, 6300, 6300, 6300, 
      67200, 67200, 134400, 134400, 226800, 226800, 226800 ], 
  [ 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1, 630, 630, 630, -630, -630, 
      -630, 6720, 6720, -6720, -6720, 0, 0, 0 ], 
  [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 342, 342, 342, 684, 684, 684, -192, 
      -192, -384, -384, -648, -648, -648 ], 
  [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, -18, -18, -18, -36, -36, -36, 672, 
      672, 1344, 1344, -1296, -1296, -1296 ], 
  [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, -18, -18, -18, -36, -36, -36, -192, 
      -192, -384, -384, 432, 432, 432 ], 
  [ 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1, -90, -90, -90, 90, 90, 90, 240, 
      240, -240, -240, 0, 0, 0 ], 
  [ 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1, 54, 54, 54, -54, -54, -54, 
      -192, -192, 192, 192, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 0, 0, 0, 0, 0, 0, 8400, -8400, 
      -8400, 8400, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, 2, -2, 2, -2, 2, -2, 0, 0, 0, 0, 0, 0, 840, -840, 
      1680, -1680, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, 2, -2, 2, -2, 2, -2, 0, 0, 0, 0, 0, 0, -240, 240, 
      -480, 480, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 0, 0, 0, 0, 0, 0, -24, 24, 24, 
      -24, 0, 0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 2, 2*E(3), 2*E(3)^2, 2, 2*E(3), 
      2*E(3)^2, 750, 750*E(3), 750*E(3)^2, 1500, 1500*E(3)^2, 1500*E(3), 0, 
      0, 0, 0, 10800, 10800*E(3), 10800*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 2, 2*E(3)^2, 2*E(3), 2, 2*E(3)^2, 
      2*E(3), 750, 750*E(3)^2, 750*E(3), 1500, 1500*E(3), 1500*E(3)^2, 0, 0, 
      0, 0, 10800, 10800*E(3)^2, 10800*E(3) ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 2, 2*E(3), 2*E(3)^2, 2, 2*E(3), 
      2*E(3)^2, 78, 78*E(3), 78*E(3)^2, 156, 156*E(3)^2, 156*E(3), 0, 0, 0, 
      0, -1296, -1296*E(3), -1296*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 2, 2*E(3)^2, 2*E(3), 2, 2*E(3)^2, 
      2*E(3), 78, 78*E(3)^2, 78*E(3), 156, 156*E(3), 156*E(3)^2, 0, 0, 0, 0, 
      -1296, -1296*E(3)^2, -1296*E(3) ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -1, -E(3), -E(3)^2, -1, -E(3), -E(3)^2, 
      150, 150*E(3), 150*E(3)^2, -150, -150*E(3)^2, -150*E(3), 0, 0, 0, 0, 0, 
      0, 0 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -1, -E(3)^2, -E(3), -1, -E(3)^2, -E(3), 
      150, 150*E(3)^2, 150*E(3), -150, -150*E(3), -150*E(3)^2, 0, 0, 0, 0, 0, 
      0, 0 ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, 2, 2*E(3), 2*E(3)^2, 2, 2*E(3), 
      2*E(3)^2, -42, -42*E(3), -42*E(3)^2, -84, -84*E(3)^2, -84*E(3), 0, 0, 
      0, 0, 504, 504*E(3), 504*E(3)^2 ], 
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), 2, 2*E(3)^2, 2*E(3), 2, 2*E(3)^2, 
      2*E(3), -42, -42*E(3)^2, -42*E(3), -84, -84*E(3), -84*E(3)^2, 0, 0, 0, 
      0, 504, 504*E(3)^2, 504*E(3) ], 
  [ 1, E(3), E(3)^2, 1, E(3), E(3)^2, -1, -E(3), -E(3)^2, -1, -E(3), -E(3)^2, 
    -42, -42*E(3), -42*E(3)^2, 42, 42*E(3)^2, 42*E(3), 0, 0, 0, 0, 0, 0, 0 ],
  [ 1, E(3)^2, E(3), 1, E(3)^2, E(3), -1, -E(3)^2, -E(3), -1, -E(3)^2, 
      -E(3), -42, -42*E(3)^2, -42*E(3), 42, 42*E(3), 42*E(3)^2, 0, 0, 0, 0, 
      0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, 2, -2*E(3), 2*E(3)^2, -2, 2*E(3), 
      -2*E(3)^2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), 2, -2*E(3)^2, 2*E(3), -2, 2*E(3)^2, 
      -2*E(3), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3), E(3)^2, -1, E(3), -E(3)^2, -1, E(3), -E(3)^2, 1, -E(3), E(3)^2, 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -E(3)^2, E(3), -1, E(3)^2, -E(3), -1, E(3)^2, -E(3), 1, -E(3)^2, E(3), 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ] ];

MULTFREEINFO.("2.Co1"):=["$2.Co_1$",
##
[ [ 1, 3, 6, 10, 102, 104, 107 ],
"$Co_2 \\rightarrow (Co_1,1)$",
 [[1,1,4600,4600,47104,47104,93150],
  [1,1,1000,1000,1024,1024,-4050],
  [1,1,76,76,-320,-320,486],
  [1,1,-20,-20,64,64,-90],
  [1,-1,-2300,2300,-11776,11776,0],
  [1,-1,-350,350,704,-704,0],
  [1,-1,10,-10,-16,16,0]] ],
##
[ [ 1, 3, 6, 10, 14, 26, 32, 102, 104, 107, 114, 118 ],
"$Co_3 \\rightarrow (Co_1,5)$",
 [[1,1,11178,11178,75900,257600,257600,1536975,1536975,
   3934656,3934656,5216400],
  [1,1,4698,4698,-3300,56000,56000,111375,111375,-57024,-57024,-226800],
  [1,1,1506,1506,396,4256,4256,-14289,-14289,-5280,-5280,27216],
  [1,1,258,258,3660,-1120,-1120,1455,1455,96,96,-5040],
  [1,1,306,306,-660,-1120,-1120,495,495,3168,3168,-5040],
  [1,1,-54,-54,60,320,320,-945,-945,1728,1728,-2160],
  [1,1,-6,-6,-36,-64,-64,399,399,-960,-960,1296],
  [1,-1,-7452,7452,0,-128800,128800,-512325,512325,-655776,655776,0],
  [1,-1,-2772,2772,0,-19600,19600,2475,-2475,64944,-64944,0],
  [1,-1,-732,732,0,560,-560,5115,-5115,-8976,8976,0],
  [1,-1,-84,84,0,560,-560,-1365,1365,1392,-1392,0],
  [1,-1,36,-36,0,-160,160,315,-315,-288,288,0]] ] ];

MULTFREEINFO.("3.F3+"):=["$3.F_{3+}$",
##
[ [ 1, 3, 4, 109, 110, 113, 114 ], "$Fi_{23} \\rightarrow (F_{3+},1)$",
[ [ 1, 1, 1, 31671, 31671, 31671, 825792 ],
  [ 1, 1, 1, 351, 351, 351, -1056 ],
  [ 1, 1, 1, -81, -81, -81, 240 ], 
  [ 1, E(3), E(3)^2, 3519, 3519*E(3), 3519*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 3519, 3519*E(3)^2, 3519*E(3), 0 ], 
  [ 1, E(3), E(3)^2, -9, -9*E(3), -9*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), -9, -9*E(3)^2, -9*E(3), 0 ] ] ],
##
[ [ 1,2,3,4,5,8,11,13,16,20,24,26,27,29,38,41,45,
  109,110,111,112,113,114,117,118,119,120,123,124,125,
  126,129,130,137,138,153,154,177,178,183,184,187,188],
"$O_{10}^-(2) \\rightarrow (F_{3+},2)$",
[ [ 1, 1, 1, 104448, 104448, 104448, 1570800, 1570800, 1570800, 107233280, 
      107233280, 107233280, 67858560, 67858560, 67858560, 12773376, 12773376, 
      12773376, 1085736960, 1085736960, 1085736960, 5428684800, 5428684800, 
      5428684800, 7238246400, 7238246400, 7238246400, 1737179136, 
      17371791360, 17371791360, 17371791360, 5147197440, 5147197440, 
      5147197440, 581644800, 37902090240, 263208960, 263208960, 263208960, 
      45957120, 45957120, 45957120, 75735 ], 
  [ 1, 1, 1, -13056, -13056, -13056, 157080, 157080, 157080, -1340416, 
      -1340416, -1340416, -3392928, -3392928, -3392928, 798336, 798336, 
      798336, 27143424, 27143424, 27143424, -67858560, -67858560, -67858560, 
      -90478080, -90478080, -90478080, -54286848, 108573696, 108573696, 
      108573696, 80424960, 80424960, 80424960, 14541120, -118444032, 
      -3290112, -3290112, -3290112, 2010624, 2010624, 2010624, -15147 ], 
  [ 1, 1, 1, 16752, 16752, 16752, 145740, 145740, 145740, 4102784, 4102784, 
      4102784, 1955016, 1955016, 1955016, 145152, 145152, 145152, 16284240, 
      16284240, 16284240, 30119040, 30119040, 30119040, -7197120, -7197120, 
      -7197120, 7112448, 7983360, 7983360, 7983360, -10730496, -10730496, 
      -10730496, 4918320, -134120448, -1983744, -1983744, -1983744, -145920, 
      -145920, -145920, 5265 ], 
  [ 1, 1, 1, 5664, 5664, 5664, 27300, 27300, 27300, 546560, 546560, 546560, 
      -302400, -302400, -302400, -266112, -266112, -266112, -393120, -393120, 
      -393120, 5443200, 5443200, 5443200, -22377600, -22377600, -22377600, 
      6483456, -6289920, -6289920, -6289920, -5376000, -5376000, -5376000, 
      6933600, 63866880, 2419200, 2419200, 2419200, 798720, 798720, 798720, 
      9585 ], 
  [ 1, 1, 1, 8544, 8544, 8544, 56100, 56100, 56100, 1168640, 1168640, 
      1168640, 178200, 178200, 178200, -57024, -57024, -57024, 1568160, 
      1568160, 1568160, 1425600, 1425600, 1425600, 1900800, 1900800, 1900800, 
      -9808128, -15966720, -15966720, -15966720, 5913600, 5913600, 5913600, 
      -5346000, 21150720, 1468800, 1468800, 1468800, 337920, 337920, 337920, 
      -4455 ], 
  [ 1, 1, 1, -2256, -2256, -2256, 26400, 26400, 26400, -256960, -256960, 
      -256960, 28512, 28512, 28512, -14256, -14256, -14256, 1012176, 1012176, 
      1012176, -498960, -498960, -498960, -665280, -665280, -665280, 6956928, 
      -6044544, -6044544, -6044544, 3480576, 3480576, 3480576, -2138400, 
      6220800, -1237248, -1237248, -1237248, 489984, 489984, 489984, 6237 ], 
  [ 1, 1, 1, 1776, 1776, 1776, 10020, 10020, 10020, -75520, -75520, -75520, 
      129816, 129816, 129816, 55296, 55296, 55296, 20304, 20304, 20304, 
      -544320, -544320, -544320, 665280, 665280, 665280, 485568, -867456, 
      -867456, -867456, 561408, 561408, 561408, 537840, -1762560, 262656, 
      262656, 262656, 26304, 26304, 26304, 2457 ], 
  [ 1, 1, 1, -2688, -2688, -2688, 19380, 19380, 19380, -65152, -65152, 
      -65152, -132840, -132840, -132840, 16848, 16848, 16848, 456192, 456192, 
      456192, -149040, -149040, -149040, 501120, 501120, 501120, 67392, 
      -508032, -508032, -508032, -652800, -652800, -652800, 19440, 1368576, 
      69120, 69120, 69120, -37056, -37056, -37056, -567 ], 
  [ 1, 1, 1, 3072, 3072, 3072, 14340, 14340, 14340, 111104, 111104, 111104, 
      26136, 26136, 26136, -1728, -1728, -1728, -120960, -120960, -120960, 
      -855360, -855360, -855360, 17280, 17280, 17280, 200448, 552960, 552960, 
      552960, -316416, -316416, -316416, -6480, 1907712, -100224, -100224, 
      -100224, -30720, -30720, -30720, -135 ], 
  [ 1, 1, 1, -708, -708, -708, 2730, 2730, 2730, -6832, -6832, -6832, 15120, 
      15120, 15120, -16632, -16632, -16632, -9828, -9828, -9828, -68040, 
      -68040, -68040, 279720, 279720, 279720, -202608, -39312, -39312, 
      -39312, -84000, -84000, -84000, 173340, -199584, -30240, -30240, 
      -30240, 34944, 34944, 34944, -1917 ], 
  [ 1, 1, 1, 912, 912, 912, 1596, 1596, 1596, -2944, -2944, -2944, -21816, 
      -21816, -21816, -6912, -6912, -6912, -34128, -34128, -34128, 124416, 
      124416, 124416, 63936, 63936, 63936, 3456, -152064, -152064, -152064, 
      167424, 167424, 167424, 71280, -456192, -6912, -6912, -6912, -6528, 
      -6528, -6528, 513 ], 
  [ 1, 1, 1, -816, -816, -816, 3000, 3000, 3000, 2240, 2240, 2240, 4752, 
      4752, 4752, -5616, -5616, -5616, -54864, -54864, -54864, 19440, 19440, 
      19440, -60480, -60480, -60480, 44928, 210816, 210816, 210816, 36096, 
      36096, 36096, -64800, -518400, 24192, 24192, 24192, 384, 384, 384, 837 ]
    , [ 1, 1, 1, 588, 588, 588, 1110, 1110, 1110, -10720, -10720, -10720, 
      -4320, -4320, -4320, 4752, 4752, 4752, -25380, -25380, -25380, 77760, 
      77760, 77760, -50760, -50760, -50760, -8208, 151200, 151200, 151200, 
      -58080, -58080, -58080, -59940, -246240, 8640, 8640, 8640, 10320, 
      10320, 10320, -945 ], 
  [ 1, 1, 1, 48, 48, 48, -780, -780, -780, 7424, 7424, 7424, -7560, -7560, 
      -7560, 3456, 3456, 3456, -5616, -5616, -5616, -15552, -15552, -15552, 
      63936, 63936, 63936, -53568, 44928, 44928, 44928, -74496, -74496, 
      -74496, 9072, -20736, -6912, -6912, -6912, 12480, 12480, 12480, 1161 ], 
  [ 1, 1, 1, -276, -276, -276, 30, 30, 30, 7424, 7424, 7424, -1728, -1728, 
      -1728, 3456, 3456, 3456, -20196, -20196, -20196, 19440, 19440, 19440, 
      -11880, -11880, -11880, 4752, -48384, -48384, -48384, 36960, 36960, 
      36960, 17820, 49248, -6912, -6912, -6912, -1776, -1776, -1776, -297 ], 
  [ 1, 1, 1, 48, 48, 48, 192, 192, 192, -8128, -8128, -8128, 6048, 6048, 
      6048, -432, -432, -432, 9936, 9936, 9936, 19440, 19440, 19440, -29376, 
      -29376, -29376, -38016, -17280, -17280, -17280, -12288, -12288, -12288, 
      -2592, 165888, -6912, -6912, -6912, -3072, -3072, -3072, 189 ], 
  [ 1, 1, 1, 48, 48, 48, -780, -780, -780, 2240, 2240, 2240, -1080, -1080, 
      -1080, -1728, -1728, -1728, 15120, 15120, 15120, -38880, -38880, 
      -38880, 17280, 17280, 17280, 37152, 8640, 8640, 8640, -1920, -1920, 
      -1920, -6480, -51840, 8640, 8640, 8640, -480, -480, -480, -135 ], 
  [ 1, E(3), E(3)^2, 35904, 35904*E(3), 35904*E(3)^2, 392700, 392700*E(3), 
      392700*E(3)^2, 16755200, 16755200*E(3), 16755200*E(3)^2, 8482320, 
      8482320*E(3), 8482320*E(3)^2, -798336, -798336*E(3), -798336*E(3)^2, 
      101787840, 101787840*E(3), 101787840*E(3)^2, 339292800, 339292800*E(3), 
      339292800*E(3)^2, -226195200, -226195200*E(3), -226195200*E(3)^2, 0, 
      542868480, 542868480*E(3), 542868480*E(3)^2, -160849920, 
      -160849920*E(3), -160849920*E(3)^2, 0, 0, -8225280, -8225280*E(3), 
      -8225280*E(3)^2, 2872320, 2872320*E(3), 2872320*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 35904, 35904*E(3)^2, 35904*E(3), 392700, 392700*E(3)^2, 
      392700*E(3), 16755200, 16755200*E(3)^2, 16755200*E(3), 8482320, 
      8482320*E(3)^2, 8482320*E(3), -798336, -798336*E(3)^2, -798336*E(3), 
      101787840, 101787840*E(3)^2, 101787840*E(3), 339292800, 
      339292800*E(3)^2, 339292800*E(3), -226195200, -226195200*E(3)^2, 
      -226195200*E(3), 0, 542868480, 542868480*E(3)^2, 542868480*E(3), 
      -160849920, -160849920*E(3)^2, -160849920*E(3), 0, 0, -8225280, 
      -8225280*E(3)^2, -8225280*E(3), 2872320, 2872320*E(3)^2, 2872320*E(3), 
      0 ], 
  [ 1, E(3), E(3)^2, -8160, -8160*E(3), -8160*E(3)^2, 89760, 89760*E(3), 
      89760*E(3)^2, -694144, -694144*E(3), -694144*E(3)^2, -1332936, 
      -1332936*E(3), -1332936*E(3)^2, -413424, -413424*E(3), -413424*E(3)^2, 
      10178784, 10178784*E(3), 10178784*E(3)^2, -20599920, -20599920*E(3), 
      -20599920*E(3)^2, 35544960, 35544960*E(3), 35544960*E(3)^2, 0, 
      19388160, 19388160*E(3), 19388160*E(3)^2, -36765696, -36765696*E(3), 
      -36765696*E(3)^2, 0, 0, 4465152, 4465152*E(3), 4465152*E(3)^2, 933504, 
      933504*E(3), 933504*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), -8160, -8160*E(3)^2, -8160*E(3), 89760, 89760*E(3)^2, 
      89760*E(3), -694144, -694144*E(3)^2, -694144*E(3), -1332936, 
      -1332936*E(3)^2, -1332936*E(3), -413424, -413424*E(3)^2, -413424*E(3), 
      10178784, 10178784*E(3)^2, 10178784*E(3), -20599920, -20599920*E(3)^2, 
      -20599920*E(3), 35544960, 35544960*E(3)^2, 35544960*E(3), 0, 19388160, 
      19388160*E(3)^2, 19388160*E(3), -36765696, -36765696*E(3)^2, 
      -36765696*E(3), 0, 0, 4465152, 4465152*E(3)^2, 4465152*E(3), 933504, 
      933504*E(3)^2, 933504*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 11208, 11208*E(3), 11208*E(3)^2, 84000, 84000*E(3), 
      84000*E(3)^2, 1937600, 1937600*E(3), 1937600*E(3)^2, 703080, 
      703080*E(3), 703080*E(3)^2, 90720, 90720*E(3), 90720*E(3)^2, 5103000, 
      5103000*E(3), 5103000*E(3)^2, 5896800, 5896800*E(3), 5896800*E(3)^2, 
      18295200, 18295200*E(3), 18295200*E(3)^2, 0, -8346240, -8346240*E(3), 
      -8346240*E(3)^2, 13009920, 13009920*E(3), 13009920*E(3)^2, 0, 0, 
      665280, 665280*E(3), 665280*E(3)^2, 49920, 49920*E(3), 49920*E(3)^2, 0 ]
    , 
  [ 1, E(3)^2, E(3), 11208, 11208*E(3)^2, 11208*E(3), 84000, 84000*E(3)^2, 
      84000*E(3), 1937600, 1937600*E(3)^2, 1937600*E(3), 703080, 
      703080*E(3)^2, 703080*E(3), 90720, 90720*E(3)^2, 90720*E(3), 5103000, 
      5103000*E(3)^2, 5103000*E(3), 5896800, 5896800*E(3)^2, 5896800*E(3), 
      18295200, 18295200*E(3)^2, 18295200*E(3), 0, -8346240, -8346240*E(3)^2, 
      -8346240*E(3), 13009920, 13009920*E(3)^2, 13009920*E(3), 0, 0, 665280, 
      665280*E(3)^2, 665280*E(3), 49920, 49920*E(3)^2, 49920*E(3), 0 ], 
  [ 1, E(3), E(3)^2, -3984, -3984*E(3), -3984*E(3)^2, 32340, 32340*E(3), 
      32340*E(3)^2, -142912, -142912*E(3), -142912*E(3)^2, -299376, 
      -299376*E(3), -299376*E(3)^2, 0, 0, 0, 1496880, 1496880*E(3), 
      1496880*E(3)^2, -1995840, -1995840*E(3), -1995840*E(3)^2, -1663200, 
      -1663200*E(3), -1663200*E(3)^2, 0, 1197504, 1197504*E(3), 
      1197504*E(3)^2, 2188032, 2188032*E(3), 2188032*E(3)^2, 0, 0, -495936, 
      -495936*E(3), -495936*E(3)^2, 14784, 14784*E(3), 14784*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), -3984, -3984*E(3)^2, -3984*E(3), 32340, 32340*E(3)^2, 
      32340*E(3), -142912, -142912*E(3)^2, -142912*E(3), -299376, 
      -299376*E(3)^2, -299376*E(3), 0, 0, 0, 1496880, 1496880*E(3)^2, 
      1496880*E(3), -1995840, -1995840*E(3)^2, -1995840*E(3), -1663200, 
      -1663200*E(3)^2, -1663200*E(3), 0, 1197504, 1197504*E(3)^2, 
      1197504*E(3), 2188032, 2188032*E(3)^2, 2188032*E(3), 0, 0, -495936, 
      -495936*E(3)^2, -495936*E(3), 14784, 14784*E(3)^2, 14784*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 4440, 4440*E(3), 4440*E(3)^2, 24240, 24240*E(3), 
      24240*E(3)^2, 261440, 261440*E(3), 261440*E(3)^2, 91368, 91368*E(3), 
      91368*E(3)^2, -23328, -23328*E(3), -23328*E(3)^2, 68040, 68040*E(3), 
      68040*E(3)^2, -1412640, -1412640*E(3), -1412640*E(3)^2, -1740960, 
      -1740960*E(3), -1740960*E(3)^2, 0, -2021760, -2021760*E(3), 
      -2021760*E(3)^2, -1026048, -1026048*E(3), -1026048*E(3)^2, 0, 0, 1728, 
      1728*E(3), 1728*E(3)^2, -42240, -42240*E(3), -42240*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 4440, 4440*E(3)^2, 4440*E(3), 24240, 24240*E(3)^2, 
      24240*E(3), 261440, 261440*E(3)^2, 261440*E(3), 91368, 91368*E(3)^2, 
      91368*E(3), -23328, -23328*E(3)^2, -23328*E(3), 68040, 68040*E(3)^2, 
      68040*E(3), -1412640, -1412640*E(3)^2, -1412640*E(3), -1740960, 
      -1740960*E(3)^2, -1740960*E(3), 0, -2021760, -2021760*E(3)^2, 
      -2021760*E(3), -1026048, -1026048*E(3)^2, -1026048*E(3), 0, 0, 1728, 
      1728*E(3)^2, 1728*E(3), -42240, -42240*E(3)^2, -42240*E(3), 0 ], 
  [ 1, E(3), E(3)^2, -1104, -1104*E(3), -1104*E(3)^2, 7860, 7860*E(3), 
      7860*E(3)^2, -53056, -53056*E(3), -53056*E(3)^2, 32400, 32400*E(3), 
      32400*E(3)^2, 67392, 67392*E(3), 67392*E(3)^2, 81648, 81648*E(3), 
      81648*E(3)^2, -51840, -51840*E(3), -51840*E(3)^2, -833760, 
      -833760*E(3), -833760*E(3)^2, 0, -461376, -461376*E(3), -461376*E(3)^2, 
      215808, 215808*E(3), 215808*E(3)^2, 0, 0, 292032, 292032*E(3), 
      292032*E(3)^2, 106944, 106944*E(3), 106944*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), -1104, -1104*E(3)^2, -1104*E(3), 7860, 7860*E(3)^2, 
      7860*E(3), -53056, -53056*E(3)^2, -53056*E(3), 32400, 32400*E(3)^2, 
      32400*E(3), 67392, 67392*E(3)^2, 67392*E(3), 81648, 81648*E(3)^2, 
      81648*E(3), -51840, -51840*E(3)^2, -51840*E(3), -833760, 
      -833760*E(3)^2, -833760*E(3), 0, -461376, -461376*E(3)^2, -461376*E(3), 
      215808, 215808*E(3)^2, 215808*E(3), 0, 0, 292032, 292032*E(3)^2, 
      292032*E(3), 106944, 106944*E(3)^2, 106944*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 1704, 1704*E(3), 1704*E(3)^2, 4800, 4800*E(3), 
      4800*E(3)^2, 36800, 36800*E(3), 36800*E(3)^2, -57240, -57240*E(3), 
      -57240*E(3)^2, 14688, 14688*E(3), 14688*E(3)^2, -171720, -171720*E(3), 
      -171720*E(3)^2, 194400, 194400*E(3), 194400*E(3)^2, 237600, 
      237600*E(3), 237600*E(3)^2, 0, 17280, 17280*E(3), 17280*E(3)^2, 
      -168960, -168960*E(3), -168960*E(3)^2, 0, 0, -95040, -95040*E(3), 
      -95040*E(3)^2, 49920, 49920*E(3), 49920*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 1704, 1704*E(3)^2, 1704*E(3), 4800, 4800*E(3)^2, 
      4800*E(3), 36800, 36800*E(3)^2, 36800*E(3), -57240, -57240*E(3)^2, 
      -57240*E(3), 14688, 14688*E(3)^2, 14688*E(3), -171720, -171720*E(3)^2, 
      -171720*E(3), 194400, 194400*E(3)^2, 194400*E(3), 237600, 
      237600*E(3)^2, 237600*E(3), 0, 17280, 17280*E(3)^2, 17280*E(3), 
      -168960, -168960*E(3)^2, -168960*E(3), 0, 0, -95040, -95040*E(3)^2, 
      -95040*E(3), 49920, 49920*E(3)^2, 49920*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 336, 336*E(3), 336*E(3)^2, 4260, 4260*E(3), 4260*E(3)^2, 
      -70336, -70336*E(3), -70336*E(3)^2, 58320, 58320*E(3), 58320*E(3)^2, 
      -23328, -23328*E(3), -23328*E(3)^2, 42768, 42768*E(3), 42768*E(3)^2, 
      142560, 142560*E(3), 142560*E(3)^2, 73440, 73440*E(3), 73440*E(3)^2, 0, 
      -513216, -513216*E(3), -513216*E(3)^2, -37632, -37632*E(3), 
      -37632*E(3)^2, 0, 0, -70848, -70848*E(3), -70848*E(3)^2, 49344, 
      49344*E(3), 49344*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 336, 336*E(3)^2, 336*E(3), 4260, 4260*E(3)^2, 4260*E(3), 
      -70336, -70336*E(3)^2, -70336*E(3), 58320, 58320*E(3)^2, 58320*E(3), 
      -23328, -23328*E(3)^2, -23328*E(3), 42768, 42768*E(3)^2, 42768*E(3), 
      142560, 142560*E(3)^2, 142560*E(3), 73440, 73440*E(3)^2, 73440*E(3), 0, 
      -513216, -513216*E(3)^2, -513216*E(3), -37632, -37632*E(3)^2, 
      -37632*E(3), 0, 0, -70848, -70848*E(3)^2, -70848*E(3), 49344, 
      49344*E(3)^2, 49344*E(3), 0 ], 
  [ 1, E(3), E(3)^2, -1104, -1104*E(3), -1104*E(3)^2, 5340, 5340*E(3), 
      5340*E(3)^2, -4672, -4672*E(3), -4672*E(3)^2, -9936, -9936*E(3), 
      -9936*E(3)^2, -2160, -2160*E(3), -2160*E(3)^2, -45360, -45360*E(3), 
      -45360*E(3)^2, 174960, 174960*E(3), 174960*E(3)^2, 43200, 43200*E(3), 
      43200*E(3)^2, 0, -158976, -158976*E(3), -158976*E(3)^2, -58368, 
      -58368*E(3), -58368*E(3)^2, 0, 0, 13824, 13824*E(3), 13824*E(3)^2, 
      -14016, -14016*E(3), -14016*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), -1104, -1104*E(3)^2, -1104*E(3), 5340, 5340*E(3)^2, 
      5340*E(3), -4672, -4672*E(3)^2, -4672*E(3), -9936, -9936*E(3)^2, 
      -9936*E(3), -2160, -2160*E(3)^2, -2160*E(3), -45360, -45360*E(3)^2, 
      -45360*E(3), 174960, 174960*E(3)^2, 174960*E(3), 43200, 43200*E(3)^2, 
      43200*E(3), 0, -158976, -158976*E(3)^2, -158976*E(3), -58368, 
      -58368*E(3)^2, -58368*E(3), 0, 0, 13824, 13824*E(3)^2, 13824*E(3), 
      -14016, -14016*E(3)^2, -14016*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 912, 912*E(3), 912*E(3)^2, 2568, 2568*E(3), 2568*E(3)^2, 
      -16768, -16768*E(3), -16768*E(3)^2, 6696, 6696*E(3), 6696*E(3)^2, 864, 
      864*E(3), 864*E(3)^2, -27216, -27216*E(3), -27216*E(3)^2, -33696, 
      -33696*E(3), -33696*E(3)^2, 43200, 43200*E(3), 43200*E(3)^2, 0, 324864, 
      324864*E(3), 324864*E(3)^2, 70656, 70656*E(3), 70656*E(3)^2, 0, 0, 
      13824, 13824*E(3), 13824*E(3)^2, -9984, -9984*E(3), -9984*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 912, 912*E(3)^2, 912*E(3), 2568, 2568*E(3)^2, 2568*E(3), 
      -16768, -16768*E(3)^2, -16768*E(3), 6696, 6696*E(3)^2, 6696*E(3), 864, 
      864*E(3)^2, 864*E(3), -27216, -27216*E(3)^2, -27216*E(3), -33696, 
      -33696*E(3)^2, -33696*E(3), 43200, 43200*E(3)^2, 43200*E(3), 0, 324864, 
      324864*E(3)^2, 324864*E(3), 70656, 70656*E(3)^2, 70656*E(3), 0, 0, 
      13824, 13824*E(3)^2, 13824*E(3), -9984, -9984*E(3)^2, -9984*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 192, 192*E(3), 192*E(3)^2, -492, -492*E(3), -492*E(3)^2, 
      512, 512*E(3), 512*E(3)^2, -7344, -7344*E(3), -7344*E(3)^2, -3456, 
      -3456*E(3), -3456*E(3)^2, 5184, 5184*E(3), 5184*E(3)^2, 31104, 
      31104*E(3), 31104*E(3)^2, -34560, -34560*E(3), -34560*E(3)^2, 0, 
      -55296, -55296*E(3), -55296*E(3)^2, 24576, 24576*E(3), 24576*E(3)^2, 0, 
      0, 13824, 13824*E(3), 13824*E(3)^2, 1536, 1536*E(3), 1536*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 192, 192*E(3)^2, 192*E(3), -492, -492*E(3)^2, -492*E(3), 
      512, 512*E(3)^2, 512*E(3), -7344, -7344*E(3)^2, -7344*E(3), -3456, 
      -3456*E(3)^2, -3456*E(3), 5184, 5184*E(3)^2, 5184*E(3), 31104, 
      31104*E(3)^2, 31104*E(3), -34560, -34560*E(3)^2, -34560*E(3), 0, 
      -55296, -55296*E(3)^2, -55296*E(3), 24576, 24576*E(3)^2, 24576*E(3), 0, 
      0, 13824, 13824*E(3)^2, 13824*E(3), 1536, 1536*E(3)^2, 1536*E(3), 0 ], 
  [ 1, E(3), E(3)^2, -240, -240*E(3), -240*E(3)^2, -60, -60*E(3), -60*E(3)^2, 
      5696, 5696*E(3), 5696*E(3)^2, 3024, 3024*E(3), 3024*E(3)^2, -864, 
      -864*E(3), -864*E(3)^2, -14256, -14256*E(3), -14256*E(3)^2, -38880, 
      -38880*E(3), -38880*E(3)^2, 4320, 4320*E(3), 4320*E(3)^2, 0, 95040, 
      95040*E(3), 95040*E(3)^2, 17664, 17664*E(3), 17664*E(3)^2, 0, 0, -1728, 
      -1728*E(3), -1728*E(3)^2, 3264, 3264*E(3), 3264*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), -240, -240*E(3)^2, -240*E(3), -60, -60*E(3)^2, -60*E(3), 
      5696, 5696*E(3)^2, 5696*E(3), 3024, 3024*E(3)^2, 3024*E(3), -864, 
      -864*E(3)^2, -864*E(3), -14256, -14256*E(3)^2, -14256*E(3), -38880, 
      -38880*E(3)^2, -38880*E(3), 4320, 4320*E(3)^2, 4320*E(3), 0, 95040, 
      95040*E(3)^2, 95040*E(3), 17664, 17664*E(3)^2, 17664*E(3), 0, 0, -1728, 
      -1728*E(3)^2, -1728*E(3), 3264, 3264*E(3)^2, 3264*E(3), 0 ], 
  [ 1, E(3), E(3)^2, 30, 30*E(3), 30*E(3)^2, -330, -330*E(3), -330*E(3)^2, 
      -2404, -2404*E(3), -2404*E(3)^2, 1404, 1404*E(3), 1404*E(3)^2, 2376, 
      2376*E(3), 2376*E(3)^2, 12474, 12474*E(3), 12474*E(3)^2, 4860, 
      4860*E(3), 4860*E(3)^2, 9180, 9180*E(3), 9180*E(3)^2, 0, -52380, 
      -52380*E(3), -52380*E(3)^2, -26616, -26616*E(3), -26616*E(3)^2, 0, 0, 
      -6588, -6588*E(3), -6588*E(3)^2, -2676, -2676*E(3), -2676*E(3)^2, 0 ], 
  [ 1, E(3)^2, E(3), 30, 30*E(3)^2, 30*E(3), -330, -330*E(3)^2, -330*E(3), 
      -2404, -2404*E(3)^2, -2404*E(3), 1404, 1404*E(3)^2, 1404*E(3), 2376, 
      2376*E(3)^2, 2376*E(3), 12474, 12474*E(3)^2, 12474*E(3), 4860, 
      4860*E(3)^2, 4860*E(3), 9180, 9180*E(3)^2, 9180*E(3), 0, -52380, 
      -52380*E(3)^2, -52380*E(3), -26616, -26616*E(3)^2, -26616*E(3), 0, 0, 
      -6588, -6588*E(3)^2, -6588*E(3), -2676, -2676*E(3)^2, -2676*E(3),0]]]];

MULTFREEINFO.("2.B"):=["$2.B$",
##
[ [ 1,2,3,5,7,8,9,12,13,15,17,23,27,30,32,40,41,54,63,68,77,81,83,
  185,186,187,188,189,194,195,196,203,208,220],
"$Fi_{23} \\rightarrow (B,4)$",
 fail ] ];

MULTFREEINFO.("2.M12.2"):=["$2.M_{12}.2$",
##
[[1,2,3,26,27],"$M_{11} \\rightarrow (M_{12}.2,1)$",
[ [ 1, 1, 12, 12, 22 ], 
  [ 1, 1, -12, -12, 22 ],
  [ 1, 1, 0, 0, -2 ], 
  [ 1, -1, ER(12), -ER(12), 0 ],
  [ 1, -1, -ER(12), ER(12), 0 ] ] ],
##
[[1,3,9,12,26,27,33],"$L_2(11).2 \\rightarrow (M_{12}.2,2)$",
[ [ 1, 1, 22, 22, 55, 55, 132 ], 
  [ 1, 1, 10, 10, -5, -5, -12 ], 
  [ 1, 1, -2, -2, 7, 7, -12 ], 
  [ 1, 1, -2, -2, -5, -5, 12 ], 
  [ 1, -1, 10+2*ER(3), -10-2*ER(3), 5-10*ER(3), -5+10*ER(3), 0 ],
  [ 1, -1, 10-2*ER(3), -10+2*ER(3), 5+10*ER(3), -5-10*ER(3), 0 ],
  [ 1, -1, -2, 2, -1, 1, 0 ] ] ],
##
[[1,3,9,12,26,27,32],"$L_2(11).2 \\rightarrow (M_{12}.2,2)$",
[ [ 1, 1, 22, 22, 55, 55, 132 ], 
  [ 1, 1, 10, 10, -5, -5, -12 ],
  [ 1, 1, -2, -2, 7, 7, -12 ], 
  [ 1, 1, -2, -2, -5, -5, 12 ], 
  [ 1, -1, 10-2*ER(3), -10+2*ER(3), 5+10*ER(3), -5-10*ER(3), 0 ],
  [ 1, -1, 10+2*ER(3), -10-2*ER(3), 5-10*ER(3), -5+10*ER(3), 0 ],
  [ 1, -1, -2, 2, -1, 1, 0 ] ] ] ];

MULTFREEINFO.("Isoclinic(2.M12.2)"):=["$(2.M_{12}.2)^*$",
##
[[1,2,3,26,27],"$M_{11} \\rightarrow (M_{12}.2,1)$",
[ [ 1, 1, 12, 12, 22 ],
  [ 1, 1, -12, -12, 22 ],
  [ 1, 1, 0, 0, -2 ] ,
  [ 1, -1, EI(12), -EI(12), 0 ],
  [ 1, -1, -EI(12), EI(12), 0 ] ] ] ];

MULTFREEINFO.("2.M22.2"):=["$2.M_{22}.2$",
##
[[1,3,9,13,18,30,33],"$2^4:S_5 \\rightarrow (M_{22}.2,6)$",
[ [ 1, 1, 10, 120, 120, 192, 480 ], 
  [ 1, 1, 10, 10, 10, -72, 40 ], 
  [ 1, 1, 10, -6, -6, 24, -24 ],
  [ 1, 1, -2, 12, 12, 0, -24 ], 
  [ 1, 1, -2, -8, -8, 0, 16 ], 
  [ 1, -1, 0, 10, -10, 0, 0 ], 
  [ 1, -1, 0, -12, 12, 0, 0 ] ] ],
##
[[1,3,9,13,18,30,32],"$2^4:S_5 \\rightarrow (M_{22}.2,6)$",
[ [ 1, 1, 10, 120, 120, 192, 480 ], 
  [ 1, 1, 10, 10, 10, -72, 40 ], 
  [ 1, 1, 10, -6, -6, 24, -24 ],
  [ 1, 1, -2, 12, 12, 0, -24 ], 
  [ 1, 1, -2, -8, -8, 0, 16 ], 
  [ 1, -1, 0, 10, -10, 0, 0 ], 
  [ 1, -1, 0, -12, 12, 0, 0 ] ] ],
##
[[1,2,3,4,13,14,26,27,28,29],"$A_7 \\rightarrow (M_{22}.2,7)$",
[ [ 1, 1, 15, 15, 35, 35, 105, 105, 140, 252 ],
  [ 1, 1, -15, -15, -35, -35, 105, 105, 140, -252 ],
  [ 1, 1, -7, -7, 13, 13, 17, 17, -36, -12 ], 
  [ 1, 1, 7, 7, -13, -13, 17, 17, -36, 12 ], 
  [ 1, 1, 3, 3, 3, 3, -3, -3, 4, -12 ], 
  [ 1, 1, -3, -3, -3, -3, -3, -3, 4, 12 ],
  [ 1, -1, 3*ER(5), -3*ER(5), ER(5), -ER(5), -15, 15, 0, 0 ],
  [ 1, -1, -3*ER(5), 3*ER(5), -ER(5), ER(5), -15, 15, 0, 0 ],
  [ 1, -1, 1, -1, -7, 7, 7, -7, 0, 0 ],
  [ 1, -1, -1, 1, 7, -7, 7, -7, 0, 0 ] ] ],
##
[[1,3,9,11,13,29,33],"$2^3:L_3(2) \\times 2 \\rightarrow (M_{22}.2,11)$",
[ [ 1, 1, 14, 84, 112, 112, 336 ], 
  [ 1, 1, -8, 18, 24, 24, -60 ],
  [ 1, 1, 8, 18, -8, -8, -12 ], 
  [ 1, 1, -6, 4, -8, -8, 16 ], 
  [ 1, 1, 2, -12, 4, 4, 0 ], 
  [ 1, -1, 0, 0, 14, -14, 0 ], 
  [ 1, -1, 0, 0, -8, 8, 0 ] ] ],
##
[[1,3,9,11,13,28,32],"$2^3:L_3(2) \\times 2 \\rightarrow (M_{22}.2,11)$",
[ [ 1, 1, 14, 84, 112, 112, 336 ],
  [ 1, 1, -8, 18, 24, 24, -60 ], 
  [ 1, 1, 8, 18, -8, -8, -12 ], 
  [ 1, 1, -6, 4, -8, -8, 16 ], 
  [ 1, 1, 2, -12, 4, 4, 0 ], 
  [ 1, -1, 0, 0, 14, -14, 0 ], 
  [ 1, -1, 0, 0, -8, 8, 0 ] ] ],
##
[[1,2,3,4,9,10,11,12,13,14,28,29,32,33],
"$2^3:L_3(2) \\rightarrow (M_{22}.2,12)$",
[ [ 1, 1, 1, 1, 14, 14, 84, 84, 112, 112, 112, 112, 336, 336 ], 
  [ 1, 1, -1, -1, -14, 14, 84, -84, 112, 112, -112, -112, -336, 336 ], 
  [ 1, 1, 1, 1, -8, -8, 18, 18, 24, 24, 24, 24, -60, -60 ], 
  [ 1, 1, -1, -1, 8, -8, 18, -18, 24, 24, -24, -24, 60, -60 ], 
  [ 1, 1, 1, 1, 8, 8, 18, 18, -8, -8, -8, -8, -12, -12 ], 
  [ 1, 1, -1, -1, -8, 8, 18, -18, -8, -8, 8, 8, 12, -12 ], 
  [ 1, 1, 1, 1, -6, -6, 4, 4, -8, -8, -8, -8, 16, 16 ], 
  [ 1, 1, -1, -1, 6, -6, 4, -4, -8, -8, 8, 8, -16, 16 ], 
  [ 1, 1, 1, 1, 2, 2, -12, -12, 4, 4, 4, 4, 0, 0 ], 
  [ 1, 1, -1, -1, -2, 2, -12, 12, 4, 4, -4, -4, 0, 0 ], 
  [ 1, -1, 1, -1, 0, 0, 0, 0, 14, -14, -14, 14, 0, 0 ], 
  [ 1, -1, -1, 1, 0, 0, 0, 0, 14, -14, 14, -14, 0, 0 ], 
  [ 1, -1, 1, -1, 0, 0, 0, 0, -8, 8, 8, -8, 0, 0 ], 
  [ 1, -1, -1, 1, 0, 0, 0, 0, -8, 8, -8, 8, 0, 0 ] ] ],
##
[[1,4,9,13,16,18,26,27,29,36],"$L_2(11).2 \\rightarrow (M_{22}.2,16)$",
[ [ 1, 1, 55, 55, 55, 55, 132, 165, 165, 660 ], 
  [ 1, 1, 15, 15, -25, -25, -12, 45, 45, -60 ], 
  [ 1, 1, 13, 13, 13, 13, -36, -3, -3, -12 ], 
  [ 1, 1, -5, -5, 7, 7, 12, 9, 9, -36 ], 
  [ 1, 1, -7, -7, -3, -3, -12, 1, 1, 28 ], 
  [ 1, 1, 5, 5, -3, -3, 12, -11, -11, 4 ],
  [ 1, -1, 10+3*ER(5), -10-3*ER(5), 10+3*ER(5), -10-3*ER(5), 
    0, -15+12*ER(5), 15-12*ER(5), 0 ],
  [ 1, -1, 10-3*ER(5), -10+3*ER(5), 10-3*ER(5), -10+3*ER(5),
    0, -15-12*ER(5), 15+12*ER(5), 0 ],
  [ 1, -1, 9, -9, -13, 13, 0, 3, -3, 0 ], 
  [ 1, -1, -5, 5, 1, -1, 0, 3, -3, 0 ] ] ],
##
[[1,4,9,13,16,18,26,27,28,37],"$L_2(11).2 \\rightarrow (M_{22}.2,16)$",
[ [ 1, 1, 55, 55, 55, 55, 132, 165, 165, 660 ], 
  [ 1, 1, 15, 15, -25, -25, -12, 45, 45, -60 ], 
  [ 1, 1, 13, 13, 13, 13, -36, -3, -3, -12 ], 
  [ 1, 1, -5, -5, 7, 7, 12, 9, 9, -36 ], 
  [ 1, 1, -7, -7, -3, -3, -12, 1, 1, 28 ], 
  [ 1, 1, 5, 5, -3, -3, 12, -11, -11, 4 ], 
  [ 1, -1, 10-3*ER(5), -10+3*ER(5), 10-3*ER(5), -10+3*ER(5),
    0, -15-12*ER(5), 15+12*ER(5), 0 ],
  [ 1, -1, 10+3*ER(5), -10-3*ER(5), 10+3*ER(5), -10-3*ER(5),
    0, -15+12*ER(5), 15-12*ER(5), 0 ],
  [ 1, -1, 9, -9, -13, 13, 0, 3, -3, 0 ], 
  [ 1, -1, -5, 5, 1, -1, 0, 3, -3, 0 ] ] ] ];

MULTFREEINFO.("Isoclinic(2.M22.2)"):=["$(2.M_{22}.2)^*$",
##
[[1,2,3,4,13,14,26,27,28,29],"$A_7 \\rightarrow (M_{22}.2,7)$",
[ [ 1, 1, 15, 15, 35, 35, 105, 105, 140, 252 ], 
  [ 1, 1, -15, -15, -35, -35, 105, 105, 140, -252 ], 
  [ 1, 1, -7, -7, 13, 13, 17, 17, -36, -12 ], 
  [ 1, 1, 7, 7, -13, -13, 17, 17, -36, 12 ], 
  [ 1, 1, 3, 3, 3, 3, -3, -3, 4, -12 ], 
  [ 1, 1, -3, -3, -3, -3, -3, -3, 4, 12 ],
  [ 1, -1, 3*EI(5), -3*EI(5), EI(5), -EI(5), -15, 15, 0, 0 ],
  [ 1, -1, -3*EI(5), 3*EI(5), -EI(5), EI(5), -15, 15, 0, 0 ],
  [ 1, -1, E(4), -E(4), -7*E(4), 7*E(4), 7, -7, 0, 0 ], 
  [ 1, -1, -E(4), E(4), 7*E(4), -7*E(4), 7, -7, 0, 0 ] ] ],
##
[[1,2,3,4,9,10,11,12,13,14,28,29,32,33],
"$2^3:L_3(2) \\rightarrow (M_{22}.2,12)$",
[ [ 1, 1, 1, 1, 14, 14, 84, 84, 112, 112, 112, 112, 336, 336 ], 
  [ 1, 1, -1, -1, 14, -14, 84, -84, 112, 112, -112, -112, -336, 336 ], 
  [ 1, 1, 1, 1, -8, -8, 18, 18, 24, 24, 24, 24, -60, -60 ], 
  [ 1, 1, -1, -1, -8, 8, 18, -18, 24, 24, -24, -24, 60, -60 ], 
  [ 1, 1, 1, 1, 8, 8, 18, 18, -8, -8, -8, -8, -12, -12 ], 
  [ 1, 1, -1, -1, 8, -8, 18, -18, -8, -8, 8, 8, 12, -12 ], 
  [ 1, 1, 1, 1, -6, -6, 4, 4, -8, -8, -8, -8, 16, 16 ], 
  [ 1, 1, -1, -1, -6, 6, 4, -4, -8, -8, 8, 8, -16, 16 ], 
  [ 1, 1, 1, 1, 2, 2, -12, -12, 4, 4, 4, 4, 0, 0 ], 
  [ 1, 1, -1, -1, 2, -2, -12, 12, 4, 4, -4, -4, 0, 0 ], 
  [ 1, -1, E(4), -E(4), 0, 0, 0, 0, 14, -14, 14*E(4), -14*E(4), 0, 0 ], 
  [ 1, -1, -E(4), E(4), 0, 0, 0, 0, 14, -14, -14*E(4), 14*E(4), 0, 0 ], 
  [ 1, -1, E(4), -E(4), 0, 0, 0, 0, -8, 8, -8*E(4), 8*E(4), 0, 0 ], 
  [ 1, -1, -E(4), E(4), 0, 0, 0, 0, -8, 8, 8*E(4), -8*E(4), 0, 0 ] ] ] ];

MULTFREEINFO.("3.M22.2"):=["$3.M_{22}.2$",
##
[[1,3,9,13,18,22,26,27,29],"$2^4:S_5 \\rightarrow (M_{22}.2,6)$",
[ [ 1, 2, 15, 96, 120, 192, 240, 240, 480 ], 
  [ 1, 2, 15, -36, 10, -72, 20, 20, 40 ], 
  [ 1, 2, 15, 12, -6, 24, -12, -12, -24 ], 
  [ 1, 2, -3, 0, 12, 0, 24, -12, -24 ],
  [ 1, 2, -3, 0, -8, 0, -16, 8, 16 ], 
  [ 1, -1, 0, -24, 40, 24, -40, 20, -20 ], 
  [ 1, -1, 0, 9+ER(33), 3+3*EB(33), -9-ER(33), -3-3*EB(33),
    9-3*ER(33), -9+3*ER(33) ],
  [ 1, -1, 0, 9-ER(33), -3*EB(33), -9+ER(33), 3*EB(33),
    9+3*ER(33), -9-3*ER(33) ],
  [ 1, -1, 0, -6, -5, 6, 5, -10, 10 ] ] ],
##
[[1,3,9,13,22,26,27],"$2^5:S_5 \\rightarrow (M_{22}.2,8)$",
[ [ 1, 2, 30, 60, 120, 160, 320 ],
  [ 1, 2, -3, -6, 54, -16, -32 ], 
  [ 1, 2, 9, 18, -6, -8, -16 ], 
  [ 1, 2, -3, -6, -6, 4, 8 ], 
  [ 1, -1, 15, -15, 0, 20, -20 ],
  [ 1, -1, -2-EB(33), 2+EB(33), 0, -2+2*ER(33), 2-2*ER(33) ],
  [ 1, -1, -1+EB(33), 1-EB(33), 0, -2-2*ER(33), 2+2*ER(33) ] ] ],
##
[[1,3,4,9,13,16,22,26,27,29],
"$2^4:(A_5 \\times 2) \\rightarrow (M_{22}.2,10)$",
[ [ 1, 1, 2, 2, 60, 120, 120, 120, 320, 640 ],
  [ 1, 1, 2, 2, -6, 54, -12, 54, -32, -64 ],
  [ 1, -1, 2, -2, 0, 60, 0, -60, 0, 0 ], 
  [ 1, 1, 2, 2, 18, -6, 36, -6, -16, -32 ], 
  [ 1, 1, 2, 2, -6, -6, -12, -6, 8, 16 ], 
  [ 1, -1, 2, -2, 0, -6, 0, 6, 0, 0 ], 
  [ 1, 1, -1, -1, 30, 0, -30, 0, 40, -40 ],
  [ 1, 1, -1, -1, -3-ER(33), 0, 3+ER(33), 0, -4+4*ER(33), 4-4*ER(33) ],
  [ 1, 1, -1, -1, -3+ER(33), 0, 3-ER(33), 0, -4-4*ER(33), 4+4*ER(33) ],
  [ 1, -1, -1, 1, 0, 0, 0, 0, 0, 0 ] ] ],
##
[[1,3,9,11,13,22,25,26,27],
"$2^3:L_3(2) \\times 2 \\rightarrow (M_{22}.2,11)$",
[ [ 1, 2, 7, 14, 42, 84, 168, 336, 336 ], 
  [ 1, 2, -4, -8, 9, 18, -30, -60, 72 ],
  [ 1, 2, 4, 8, 9, 18, -6, -12, -24 ], 
  [ 1, 2, -3, -6, 2, 4, 8, 16, -24 ], 
  [ 1, 2, 1, 2, -6, -12, 0, 0, 12 ], 
  [ 1, -1, 5, -5, 18, -18, 24, -24, 0 ], 
  [ 1, -1, 0, 0, -7, 7, 14, -14, 0 ], 
  [ 1, -1, -1-EB(33), 1+EB(33), 2+EB(33), -2-EB(33), -9+ER(33), 9-ER(33), 0 ], 
  [ 1, -1, EB(33), -EB(33), 1-EB(33), -1+EB(33), -9-ER(33), 9+ER(33), 0 ] ] ],
##
[[1,4,9,13,16,18,22,26,27,28,29],"$L_2(11).2 \\rightarrow (M_{22}.2,16)$",
[ [ 1, 2, 55, 66, 110, 132, 165, 165, 330, 330, 660 ], 
  [ 1, 2, -25, -6, -50, -12, 45, 45, 90, -30, -60 ], 
  [ 1, 2, 13, -18, 26, -36, -3, 39, -6, -6, -12 ], 
  [ 1, 2, 7, 6, 14, 12, 9, -15, 18, -18, -36 ], 
  [ 1, 2, -3, -6, -6, -12, 1, -21, 2, 14, 28 ], 
  [ 1, 2, -3, 6, -6, 12, -11, 15, -22, 2, 4 ], 
  [ 1, -1, 20, -24, -20, 24, 45, 0, -45, -30, 30 ], 
  [ 1, -1, 4*EB(33), 9+ER(33), -4*EB(33), -9-ER(33),
    12-ER(33), 0, -12+ER(33), 3+ER(33), -3-ER(33) ],
  [ 1, -1, -2-2*ER(33), 9-ER(33), 2+2*ER(33), -9+ER(33),
    12+ER(33), 0, -12-ER(33), 3-ER(33), -3+ER(33) ],
  [ 1, -1, 0, 0, 0, 0, -11, 0, 11, -22, 22 ], 
  [ 1, -1, 0, -6, 0, 6, -5, 0, 5, 20, -20 ] ] ] ];

MULTFREEINFO.("4.M22.2"):=["$4.M_{22}.2$"];

MULTFREEINFO.("Isoclinic(4.M22.2)"):=["$(4.M_{22}.2)^*$"];

MULTFREEINFO.("6.M22.2"):=["$6.M_{22}.2$",
##
[[1,3,9,13,18,30,33,38,42,43,45,52,53,54],
"$2^4:S_5 \\rightarrow (M_{22}.2,6)$",
[ [ 1, 1, 2, 2, 30, 120, 120, 192, 192, 192, 240, 240, 480, 960 ], 
  [ 1, 1, 2, 2, 30, 10, 10, -72, -72, -72, 20, 20, 40, 80 ], 
  [ 1, 1, 2, 2, 30, -6, -6, 24, 24, 24, -12, -12, -24, -48 ], 
  [ 1, 1, 2, 2, -6, 12, 12, 0, 0, 0, 24, 24, -24, -48 ], 
  [ 1, 1, 2, 2, -6, -8, -8, 0, 0, 0, -16, -16, 16, 32 ], 
  [ 1, -1, -2, 2, 0, -10, 10, 0, 0, 0, 20, -20, 0, 0 ], 
  [ 1, -1, -2, 2, 0, 12, -12, 0, 0, 0, -24, 24, 0, 0 ], 
  [ 1, 1, -1, -1, 0, 40, 40, -48, 24, 24, -40, -40, 40, -40 ], 
  [ 1, 1, -1, -1, 0, 3+3*EB(33), 3+3*EB(33), 18+2*ER(33), -9-ER(33),
    -9-ER(33), -3-3*EB(33), -3-3*EB(33), 18-6*ER(33), -18+6*ER(33) ],
  [ 1, 1, -1, -1, 0, -3*EB(33), -3*EB(33), 18-2*ER(33), -9+ER(33),
    -9+ER(33), 3*EB(33), 3*EB(33), 18+6*ER(33), -18-6*ER(33) ],
  [ 1, 1, -1, -1, 0, -5, -5, -12, 6, 6, 5, 5, -20, 20 ], 
  [ 1, -1, 1, -1, 0, 5*EB(33), -5*EB(33), 0, -15-ER(33),
    15+ER(33), 5*EB(33), -5*EB(33), 0, 0 ],             
  [ 1, -1, 1, -1, 0, -5-5*EB(33), 5+5*EB(33), 0, -15+ER(33),
    15-ER(33), -5-5*EB(33), 5+5*EB(33), 0, 0 ], 
  [ 1, -1, 1, -1, 0, 3, -3, 0, 18, -18, 3, -3, 0, 0 ] ] ],
##
[[1,3,9,13,18,30,32,38,42,43,45,52,53,54],
"$2^4:S_5 \\rightarrow (M_{22}.2,6)$",
[ [ 1, 1, 2, 2, 30, 120, 120, 192, 192, 192, 240, 240, 480, 960 ], 
  [ 1, 1, 2, 2, 30, 10, 10, -72, -72, -72, 20, 20, 40, 80 ], 
  [ 1, 1, 2, 2, 30, -6, -6, 24, 24, 24, -12, -12, -24, -48 ], 
  [ 1, 1, 2, 2, -6, 12, 12, 0, 0, 0, 24, 24, -24, -48 ], 
  [ 1, 1, 2, 2, -6, -8, -8, 0, 0, 0, -16, -16, 16, 32 ], 
  [ 1, -1, -2, 2, 0, -10, 10, 0, 0, 0, 20, -20, 0, 0 ], 
  [ 1, -1, -2, 2, 0, 12, -12, 0, 0, 0, -24, 24, 0, 0 ], 
  [ 1, 1, -1, -1, 0, 40, 40, -48, 24, 24, -40, -40, 40, -40 ], 
  [ 1, 1, -1, -1, 0, 3+3*EB(33), 3+3*EB(33), 18+2*ER(33), -9-ER(33),
    -9-ER(33), -3-3*EB(33), -3-3*EB(33), 18-6*ER(33), -18+6*ER(33) ],
  [ 1, 1, -1, -1, 0, -3*EB(33), -3*EB(33), 18-2*ER(33), -9+ER(33),
    -9+ER(33), 3*EB(33), 3*EB(33), 18+6*ER(33), -18-6*ER(33) ],
  [ 1, 1, -1, -1, 0, -5, -5, -12, 6, 6, 5, 5, -20, 20 ], 
  [ 1, -1, 1, -1, 0, 5*EB(33), -5*EB(33), 0, -15-ER(33),
    15+ER(33), 5*EB(33), -5*EB(33), 0, 0 ],             
  [ 1, -1, 1, -1, 0, -5-5*EB(33), 5+5*EB(33), 0, -15+ER(33),
    15-ER(33), -5-5*EB(33), 5+5*EB(33), 0, 0 ], 
  [ 1, -1, 1, -1, 0, 3, -3, 0, 18, -18, 3, -3, 0, 0 ] ] ],
##
[[1,3,9,11,13,29,33,38,41,42,43,57],
"$2^3:L_3(2) \\times 2 \\rightarrow (M_{22}.2,11)$",
[ [ 1, 1, 2, 2, 14, 28, 84, 168, 336, 336, 336, 672 ], 
  [ 1, 1, 2, 2, -8, -16, 18, 36, -60, 72, 72, -120 ], 
  [ 1, 1, 2, 2, 8, 16, 18, 36, -12, -24, -24, -24 ], 
  [ 1, 1, 2, 2, -6, -12, 4, 8, 16, -24, -24, 32 ], 
  [ 1, 1, 2, 2, 2, 4, -12, -24, 0, 12, 12, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, 42, -42, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, -24, 24, 0 ], 
  [ 1, 1, -1, -1, 10, -10, 36, -36, 48, 0, 0, -48 ], 
  [ 1, 1, -1, -1, 0, 0, -14, 14, 28, 0, 0, -28 ], 
  [ 1, 1, -1, -1, -1-ER(33), 1+ER(33), 3+ER(33), -3-ER(33),
    -18+2*ER(33), 0, 0, 18-2*ER(33) ],        
  [ 1, 1, -1, -1, -1+ER(33), 1-ER(33), 3-ER(33), -3+ER(33),
    -18-2*ER(33), 0, 0, 18+2*ER(33) ],
  [ 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ],
##
[[1,3,9,11,13,28,32,38,41,42,43,57],
"$2^3:L_3(2) \\times 2 \\rightarrow (M_{22}.2,11)$",
[ [ 1, 1, 2, 2, 14, 28, 84, 168, 336, 336, 336, 672 ], 
  [ 1, 1, 2, 2, -8, -16, 18, 36, -60, 72, 72, -120 ], 
  [ 1, 1, 2, 2, 8, 16, 18, 36, -12, -24, -24, -24 ], 
  [ 1, 1, 2, 2, -6, -12, 4, 8, 16, -24, -24, 32 ], 
  [ 1, 1, 2, 2, 2, 4, -12, -24, 0, 12, 12, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, 42, -42, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, -24, 24, 0 ], 
  [ 1, 1, -1, -1, 10, -10, 36, -36, 48, 0, 0, -48 ], 
  [ 1, 1, -1, -1, 0, 0, -14, 14, 28, 0, 0, -28 ], 
  [ 1, 1, -1, -1, -1-ER(33), 1+ER(33), 3+ER(33), -3-ER(33),
    -18+2*ER(33), 0, 0, 18-2*ER(33) ],        
  [ 1, 1, -1, -1, -1+ER(33), 1-ER(33), 3-ER(33), -3+ER(33),
    -18-2*ER(33), 0, 0, 18+2*ER(33) ],
  [ 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ],
##
[[1,4,9,13,16,18,26,27,29,36,38,42,43,44,45,49,50,51,55,56],
"$L_2(11).2 \\rightarrow (M_{22}.2,16)$",
[ [ 1, 1, 2, 2, 55, 55, 110, 110, 132, 132, 132, 165, 165, 165, 165, 330, 
    330, 660, 660, 660 ],
  [ 1, 1, 2, 2, -25, -25, -50, -50, -12, -12, -12, 45, 45, 45, 45, 90, 90, 
      -60, -60, -60 ], 
  [ 1, 1, 2, 2, 13, 13, 26, 26, -36, -36, -36, 39, 39, -3, -3, -6, 
      -6, -12, -12, -12 ], 
  [ 1, 1, 2, 2, 7, 7, 14, 14, 12, 12, 12, -15, -15, 9, 9, 18, 18, -36, -36, 
      -36 ], 
  [ 1, 1, 2, 2, -3, -3, -6, -6, -12, -12, -12, -21, -21, 1, 1, 2, 2, 28, 28, 
      28 ], 
  [ 1, 1, 2, 2, -3, -3, -6, -6, 12, 12, 12, 15, 15, -11, -11, -22, 
      -22, 4, 4, 4 ],
  [ 1, -1, 2, -2, 10+3*ER(5), -10-3*ER(5), -20-6*ER(5), 20+6*ER(5),
    0, 0, 0, -30-9*ER(5), 30+9*ER(5), 15-12*ER(5), -15+12*ER(5), 
    -30+24*ER(5), 30-24*ER(5), 0, 0, 0 ],
  [ 1, -1, 2, -2, 10-3*ER(5), -10+3*ER(5), -20+6*ER(5), 20-6*ER(5),
    0, 0, 0, -30+9*ER(5), 30-9*ER(5), 15+12*ER(5), -15-12*ER(5), 
    -30-24*ER(5), 30+24*ER(5), 0, 0, 0 ],
  [ 1, -1, 2, -2, -13, 13, 26, -26, 0, 0, 0, -27, 27, -3, 3, 6, -6, 0, 0, 0 ],
  [ 1, -1, 2, -2, 1, -1, -2, 2, 0, 0, 0, 15, -15, -3, 3, 6, -6, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 20, 20, -20, -20, 24, -48, 24, 0, 0, 45, 45, -45, -45,
   -60, 30, 30 ], 
  [ 1, 1, -1, -1, -2+2*ER(33), -2+2*ER(33), 2-2*ER(33), 2-2*ER(33),
    -9-ER(33), 18+2*ER(33), -9-ER(33), 0, 0, 12-ER(33), 12-ER(33),
    -12+ER(33), -12+ER(33), 6+2*ER(33), -3-ER(33), -3-ER(33) ],
  [ 1, 1, -1, -1, -2-2*ER(33), -2-2*ER(33), 2+2*ER(33), 2+2*ER(33),
    -9+ER(33), 18-2*ER(33), -9+ER(33), 0, 0, 12+ER(33), 12+ER(33), 
    -12-ER(33), -12-ER(33), 6-2*ER(33), -3+ER(33), -3+ER(33) ],
  [ 1, 1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -11, -11, 11, 11, -44, 22, 22 ], 
  [ 1, 1, -1, -1, 0, 0, 0, 0, 6, -12, 6, 0, 0, -5, -5, 5, 5, 40, -20, -20 ],  
  [ 1, -1, -1, 1, 10, -10, 10, -10, -12*ER(-7), 0, 
    12*ER(-7), 0, 0, 15, -15, 15, -15, 0, -30, 30 ],
  [ 1, -1, -1, 1, 10, -10, 10, -10, 12*ER(-7), 0, 
    -12*ER(-7), 0, 0, 15, -15, 15, -15, 0, -30, 30 ],
  [ 1, -1, -1, 1, -4, 4, -4, 4, 0, 0, 0, 0, 0, 15, -15, 15, -15, 0, 54, -54 ],
  [ 1, -1, -1, 1, -2+4*ER(3), 2-4*ER(3), -2+4*ER(3), 2-4*ER(3),
    0, 0, 0, 0, 0, -9-4*ER(3), 9+4*ER(3), -9-4*ER(3), 
    9+4*ER(3), 0, -6+12*ER(3), 6-12*ER(3) ],
  [ 1, -1, -1, 1, -2-4*ER(3), 2+4*ER(3), -2-4*ER(3), 2+4*ER(3), 
    0, 0, 0, 0, 0, -9+4*ER(3), 9-4*ER(3), -9+4*ER(3), 
    9-4*ER(3), 0, -6-12*ER(3), 6+12*ER(3) ] ] ],
##
[[1,4,9,13,16,18,26,27,28,37,38,42,43,44,45,49,50,51,55,56],
"$L_2(11).2 \\rightarrow (M_{22}.2,16)$",
[ [ 1, 1, 2, 2, 55, 55, 110, 110, 132, 132, 132, 165, 165, 165, 165, 330, 
      330, 660, 660, 660 ],
  [ 1, 1, 2, 2, -25, -25, -50, -50, -12, -12, -12, 45, 45, 45, 45, 90, 90, 
      -60, -60, -60 ], 
  [ 1, 1, 2, 2, 13, 13, 26, 26, -36, -36, -36, 39, 39, -3, -3, -6, -6, -12, 
      -12, -12 ], 
  [ 1, 1, 2, 2, 7, 7, 14, 14, 12, 12, 12, -15, -15, 9, 9, 18, 18, -36, -36, 
      -36 ], 
  [ 1, 1, 2, 2, -3, -3, -6, -6, -12, -12, -12, -21, -21, 1, 1, 2, 2, 28, 
      28, 28 ], 
  [ 1, 1, 2, 2, -3, -3, -6, -6, 12, 12, 12, 15, 15, -11, -11, -22, -22, 4, 
      4, 4 ], 
  [ 1, -1, -2, 2, -10+3*ER(5), 10-3*ER(5), 20-6*ER(5), 
    -20+6*ER(5), 0, 0, 0, 30-9*ER(5), -30+9*ER(5), 15+12*ER(5), 
    -15-12*ER(5), 30+24*ER(5), -30-24*ER(5), 0, 0, 0 ],
  [ 1, -1, -2, 2, -10-3*ER(5), 10+3*ER(5), 20+6*ER(5), 
    -20-6*ER(5), 0, 0, 0, 30+9*ER(5), -30-9*ER(5), 15-12*ER(5), 
    -15+12*ER(5), 30-24*ER(5), -30+24*ER(5), 0, 0, 0 ],
  [ 1, -1, -2, 2, 13, -13, -26, 26, 0, 0, 0, 27, -27, -3, 3, -6, 6, 0, 0, 0 ] ,
  [ 1, -1, -2, 2, -1, 1, 2, -2, 0, 0, 0, -15, 15, -3, 3, -6, 6, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 20, 20, -20, -20, 24, -48, 24, 0, 0, 45, 45, -45, -45, 
    -60, 30, 30 ], 
  [ 1, 1, -1, -1, -2+2*ER(33), -2+2*ER(33), 2-2*ER(33), 2-2*ER(33),
   -9-ER(33), 18+2*ER(33), -9-ER(33), 0, 0, 12-ER(33), 12-ER(33),
   -12+ER(33), -12+ER(33), 6+2*ER(33), -3-ER(33), -3-ER(33) ],
  [ 1, 1, -1, -1, -2-2*ER(33), -2-2*ER(33), 2+2*ER(33), 2+2*ER(33), 
   -9+ER(33), 18-2*ER(33), -9+ER(33), 0, 0, 12+ER(33), 12+ER(33),
   -12-ER(33), -12-ER(33),  6-2*ER(33), -3+ER(33), -3+ER(33) ],
  [ 1, 1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -11, -11, 11, 11, -44, 22, 22 ],
  [ 1, 1, -1, -1, 0, 0, 0, 0, 6, -12, 6, 0, 0, -5, -5, 5, 5, 40, -20, -20 ], 
  [ 1, -1, 1, -1, -10, 10, -10, 10, -12*ER(-7), 0, 
    12*ER(-7), 0, 0, 15, -15, -15, 15, 0, 30, -30 ],
  [ 1, -1, 1, -1, -10, 10, -10, 10, 12*ER(-7), 0, 
    -12*ER(-7), 0, 0, 15, -15, -15, 15, 0, 30, -30 ],
  [ 1, -1, 1, -1, 4, -4, 4, -4, 0, 0, 0, 0, 0, 15, -15, -15, 15, 0, -54, 54 ],
  [ 1, -1, 1, -1, 2-4*ER(3), -2+4*ER(3), 2-4*ER(3), 
    -2+4*ER(3), 0, 0, 0, 0, 0, -9-4*ER(3), 9+4*ER(3), 
    9+4*ER(3), -9-4*ER(3), 0, 6-12*ER(3), -6+12*ER(3) ],
  [ 1, -1, 1, -1, 2+4*ER(3), -2-4*ER(3), 2+4*ER(3), 
    -2-4*ER(3), 0, 0, 0, 0, 0, -9+4*ER(3), 9-4*ER(3), 
    9-4*ER(3), -9+4*ER(3), 0, 6+12*ER(3), -6-12*ER(3) ] ] ] ];

MULTFREEINFO.("Isoclinic(6.M22.2)"):=["$(6.M_{22}.2)^*$"];

MULTFREEINFO.("12.M22.2"):=["$12.M_{22}.2$"];

MULTFREEINFO.("Isoclinic(12.M22.2)"):=["$(12.M_{22}.2)^*$"];

MULTFREEINFO.("2.J2.2"):=["$2.J_2.2$"];

MULTFREEINFO.("Isoclinic(2.J2.2)"):=["$(2.J_2.2)^*$",
##
[[1,5,7,31],"$U_3(3).2 \\rightarrow (J_2.2),1)$",
[ [ 1, 1, 72, 126 ],
  [ 1, 1, 12, -14 ], 
  [ 1, 1, -8, 6 ],
  [ 1, -1, 0, 0 ]]],
##
[[1,5,7,31],"$U_3(3).2 \\rightarrow (J_2.2),1)$",
[ [ 1, 1, 72, 126 ],
  [ 1, 1, 12, -14 ],
  [ 1, 1, -8, 6 ],
  [ 1, -1, 0, 0 ]]],
##
[[1,4,7,8,10,12,17,29,30,31,37,38],"$3.A_6.2_3 \\rightarrow (J_2.2),5)$",
[ [ 1, 1, 2, 36, 36, 36, 36, 135, 135, 216, 216, 270 ], 
  [ 1, 1, -2, -12, -12, 12, 12, 15, 15, 0, 0, -30 ],
  [ 1, 1, 2, -4, -4, -4, -4, 15, 15, -24, -24, 30 ], 
  [ 1, 1, -2, 8, 8, -8, -8, 15, 15, 0, 0, -30 ], 
  [ 1, 1, 2, 8, 8, 8, 8, -5, -5, -8, -8, -10 ], 
  [ 1, 1, 2, -4, -4, -4, -4, -5, -5, 16, 16, -10 ], 
  [ 1, 1, -2, 0, 0, 0, 0, -9, -9, 0, 0, 18 ],
  [ 1,-1,0,12*ER(-2),-12*ER(-2),12,-12,45,-45,-36*ER(-2),36*ER(-2),0 ],
  [ 1,-1,0,-12*ER(-2),12*ER(-2),12,-12,45,-45,36*ER(-2),-36*ER(-2),0 ],
  [ 1, -1, 0, 0, 0, -12, 12, 9, -9, 0, 0, 0 ],
  [ 1, -1, 0, 2*ER(-7), -2*ER(-7), 2, -2, -5, 5, 4*ER(-7), -4*ER(-7), 0 ],
  [ 1, -1, 0, -2*ER(-7), 2*ER(-7), 2, -2, -5, 5, -4*ER(-7), 4*ER(-7), 0 ]]]];

MULTFREEINFO.("2.HS.2"):=["$2.HS.2$",
##
[[1,3,5,7,9,10,14,16,42,44],"$A_8 \\times 2 \\rightarrow (HS.2,10)$",
[ [ 1, 1, 2, 112, 210, 210, 336, 336, 672, 2520 ], 
  [ 1, 1, -2, 0, -70, 70, 112, 112, -224, 0 ], 
  [ 1, 1, 2, -48, 50, 50, 16, 16, 32, -120 ], 
  [ 1, 1, 2, 32, 30, 30, -24, -24, -48, 0 ], 
  [ 1, 1, -2, 0, 30, -30, 12, 12, -24, 0 ], 
  [ 1, 1, 2, 24, -10, -10, 28, 28, 56, -120 ], 
  [ 1, 1, 2, -8, -10, -10, -4, -4, -8, 40 ], 
  [ 1, 1, -2, 0, -10, 10, -8, -8, 16, 0 ], 
  [ 1, -1, 0, 0, 0, 0, 42, -42, 0, 0 ],
  [ 1, -1, 0, 0, 0, 0, -8, 8, 0, 0 ] ] ],
##
[[1,4,5,7,9,10,14,17,42,44],"$A_8.2 \\rightarrow (HS.2,11)$",
[ [ 1, 1, 2, 112, 210, 210, 336, 336, 672, 2520 ], 
  [ 1, 1, -2, 0, -70, 70, 112, 112, -224, 0 ], 
  [ 1, 1, 2, -48, 50, 50, 16, 16, 32, -120 ], 
  [ 1, 1, 2, 32, 30, 30, -24, -24, -48, 0 ], 
  [ 1, 1, -2, 0, 30, -30, 12, 12, -24, 0 ], 
  [ 1, 1, 2, 24, -10, -10, 28, 28, 56, -120 ], 
  [ 1, 1, 2, -8, -10, -10, -4, -4, -8, 40 ], 
  [ 1, 1, -2, 0, -10, 10, -8, -8, 16, 0 ], 
  [ 1, -1, 0, 0, 0, 0, 42, -42, 0, 0 ],
  [ 1, -1, 0, 0, 0, 0, -8, 8, 0, 0 ] ] ] ];

MULTFREEINFO.("Isoclinic(2.HS.2)"):=["$(2.HS.2)^*$"];

MULTFREEINFO.("3.J3.2"):=["$3.J_3.2$"];

MULTFREEINFO.("3.McL.2"):=["$3.M^cL.2$",
##
[[1,7,14,24,26,30,42,44,45,50],"$2.S_8 \\rightarrow (M^cL.2,9)$",
[ [ 1, 2, 630, 2240, 4480, 5040, 8064, 10080, 16128, 20160 ], 
  [ 1, 2, 135, 260, 520, 90, 144, 180, 288, -1620 ], 
  [ 1, 2, 117, -28, -56, 72, -144, 144, -288, 180 ], 
  [ 1, 2, -15, 60, 120, -60, -56, -120, -112, 180 ], 
  [ 1, 2, -45, -10, -20, 90, -36, 180, -72, -90 ], 
  [ 1, 2, 9, -28, -56, -36, 72, -72, 144, -36 ], 
  [ 1, -1, 0, 80, -80, 90, 144, -90, -144, 0 ], 
  [ 1, -1, 0, 0, 0, -120, 64, 120, -64, 0 ], 
  [ 1, -1, 0, 35, -35, 0, -126, 0, 126, 0 ], 
  [ 1, -1, 0, -55, 55, 45, 9, -45, -9, 0 ] ] ] ];

MULTFREEINFO.("2.Suz.2"):=["$2.Suz.2$",
##
[[1,4,5,14,19,21,71,75],"$U_5(2).2 \\rightarrow (Suz.2,8)$",
[ [ 1, 1, 1782, 2816, 2816, 3960, 12672, 41472 ], 
  [ 1, 1, 486, 512, 512, -360, -1152, 0 ], 
  [ 1, 1, -198, 176, 176, 660, -528, -288 ], 
  [ 1, 1, 66, 8, 8, 60, 192, -336 ],
  [ 1, 1, -54, 32, 32, -60, 48, 0 ], 
  [ 1, 1, 18, -40, -40, 12, -96, 144 ],
  [ 1, -1, 0, 352, -352, 0, 0, 0 ], 
  [ 1, -1, 0, -8, 8, 0, 0, 0 ] ] ],
##
[[1,4,5,14,19,21,71,75],"$U_5(2).2 \\rightarrow (Suz.2,8)$",
[ [ 1, 1, 1782, 2816, 2816, 3960, 12672, 41472 ],
  [ 1, 1, 486, 512, 512, -360, -1152, 0 ],
  [ 1, 1, -198, 176, 176, 660, -528, -288 ],
  [ 1, 1, 66, 8, 8, 60, 192, -336 ], 
  [ 1, 1, -54, 32, 32, -60, 48, 0 ],
  [ 1, 1, 18, -40, -40, 12, -96, 144 ], 
  [ 1, -1, 0, 352, -352, 0, 0, 0 ],
  [ 1, -1, 0, -8, 8, 0, 0, 0 ] ] ],
##
[[1,5,6,14,19,21,22,23,33,48,71,75,89,90],
"$3^5:(M_{11} \\times 2) \\rightarrow (Suz.2,12)$",
[ [ 1, 1, 330, 1782, 5832, 10692, 17820, 17820, 32076, 32076, 80190, 80190, 
      80190, 106920 ], 
  [ 1, 1, 130, 582, 72, -1188, 1020, 1020, -1764, -1764, -1710, -1710, 6390, 
      -1080 ], 
  [ 1, 1, -110, 198, -1080, 396, 1980, 1980, -1188, -1188, 2970, 2970, -2970, 
      -3960 ], 
  [ 1, 1, 70, 222, -96, 396, -120, -120, 408, 408, -150, -150, -150, -720 ], 
  [ 1, 1, -50, 78, 0, -324, 120, 120, 432, 432, -270, -270, -270, 0 ], 
  [ 1, 1, 22, -66, 288, 108, 264, 264, 72, 72, -198, -198, -198, -432 ],
  [ 1, 1, -38, 54, 72, 180, -36, -36, -180, -180, -90, -90, -18, 360 ], 
  [ 1, 1, 42, 54, 72, -220, -36, -36, -180, -180, 270, 270, -738, 680 ], 
  [ 1, 1, 10, -42, -120, 36, 60, 60, 12, 12, -210, -210, 30, 360 ], 
  [ 1, 1, -2, -18, 0, -36, -72, -72, 0, 0, 162, 162, 162, -288 ], 
  [ 1, -1, 0, 0, 0, 0, 1980, -1980, 1782, -1782, 0, 0, 0, 0 ], 
  [ 1, -1, 0, 0, 0, 0, 180, -180, -378, 378, 0, 0, 0, 0 ], 
  [ 1, -1, 0, 0, 0, 0, -36, 36, 54, -54, -216*ER(-2), 216*ER(-2), 0, 0 ],
  [ 1, -1, 0, 0, 0, 0, -36, 36, 54, -54, 216*ER(-2), -216*ER(-2), 0, 0 ] ] ],
##
[[1,5,6,14,19,21,22,23,33,48,71,75,89,90],
"$3^5:(M_{11} \\times 2) \\rightarrow (Suz.2,12)$",
[ [ 1, 1, 330, 1782, 5832, 10692, 17820, 17820, 32076, 32076, 80190, 80190,
      80190, 106920 ],
  [ 1, 1, 130, 582, 72, -1188, 1020, 1020, -1764, -1764, -1710, -1710, 6390,
      -1080 ],
  [ 1, 1, -110, 198, -1080, 396, 1980, 1980, -1188, -1188, 2970, 2970, -2970,
      -3960 ],
  [ 1, 1, 70, 222, -96, 396, -120, -120, 408, 408, -150, -150, -150, -720 ],
  [ 1, 1, -50, 78, 0, -324, 120, 120, 432, 432, -270, -270, -270, 0 ],
  [ 1, 1, 22, -66, 288, 108, 264, 264, 72, 72, -198, -198, -198, -432 ],
  [ 1, 1, -38, 54, 72, 180, -36, -36, -180, -180, -90, -90, -18, 360 ],
  [ 1, 1, 42, 54, 72, -220, -36, -36, -180, -180, 270, 270, -738, 680 ],
  [ 1, 1, 10, -42, -120, 36, 60, 60, 12, 12, -210, -210, 30, 360 ],
  [ 1, 1, -2, -18, 0, -36, -72, -72, 0, 0, 162, 162, 162, -288 ],
  [ 1, -1, 0, 0, 0, 0, 1980, -1980, 1782, -1782, 0, 0, 0, 0 ],
  [ 1, -1, 0, 0, 0, 0, 180, -180, -378, 378, 0, 0, 0, 0 ],
  [ 1, -1, 0, 0, 0, 0, -36, 36, 54, -54, -216*ER(-2), 216*ER(-2), 0, 0 ],
  [ 1, -1, 0, 0, 0, 0, -36, 36, 54, -54, 216*ER(-2), -216*ER(-2), 0, 0 ]]]];

MULTFREEINFO.("Isoclinic(2.Suz.2)"):=["$(2.Suz.2)^*$"];

MULTFREEINFO.("3.Suz.2"):=["$3.Suz.2$",
##
[[1,7,9,69,73],"$G_2(4).2 \\rightarrow (Suz.2,1)$",
[ [ 1, 2, 416, 832, 4095 ], 
  [ 1, 2, 20, 40, -63 ], 
  [ 1, 2, -16, -32, 45 ], 
  [ 1, -1, 104, -104, 0 ], 
  [ 1, -1, -4, 4, 0 ] ] ],
##
[[1,4,5,14,19,21,70,72,78,86],"$U_5(2).2 \\rightarrow (Suz.2,8)$",
[ [ 1, 2, 891, 1782, 2816, 5632, 5940, 19008, 20736, 41472 ], 
  [ 1, 2, 243, 486, 512, 1024, -540, -1728, 0, 0 ], 
  [ 1, 2, -99, -198, 176, 352, 990, -792, -144, -288 ], 
  [ 1, 2, 33, 66, 8, 16, 90, 288, -168, -336 ], 
  [ 1, 2, -27, -54, 32, 64, -90, 72, 0, 0 ], 
  [ 1, 2, 9, 18, -40, -80, 18, -144, 72, 144 ], 
  [ 1, -1, -297, 297, 704, -704, 0, 0, -1728, 1728 ], 
  [ 1, -1, 99, -99, 176, -176, 0, 0, 144, -144 ], 
  [ 1, -1, -45, 45, 32, -32, 0, 0, 288, -288 ], 
  [ 1, -1, 3, -3, -16, 16, 0, 0, -48, 48 ] ] ],
##
[[1,4,7,11,14,21,26,27,38,69,71,73,81,82,88,91],
"$2^{1+6}_-.U_4(2).2 \\rightarrow (Suz.2,10)$",
[ [ 1, 2, 54, 108, 1080, 1728, 3456, 5120, 9216, 10240, 17280, 18432, 34560, 
      55296, 110592, 138240 ], 
  [ 1, 2, -27, -54, 270, 432, 864, 800, -1152, 1600, -2160, -2304, -4320, 
      3456, 6912, -4320 ], 
  [ 1, 2, 21, 42, 90, 276, 552, -160, 768, -320, 120, 1536, 240, 384, 768, 
      -4320 ], 
  [ 1, 2, 3, 6, -180, 132, 264, 200, 48, 400, -60, 96, -120, -624, -1248, 
      1080 ], 
  [ 1, 2, 15, 30, 144, 12, 24, 128, -144, 256, 276, -288, 552, -240, -480, 
      -288 ], 
  [ 1, 2, -9, -18, 72, -36, -72, 80, 144, 160, -108, 288, -216, -144, -288, 
      144 ], 
  [ 1, 2, -11, -22, 30, 48, 96, -80, -64, -160, 80, -128, 160, -64,-128,240], 
  [ 1, 2, 9, 18, 18, 0, 0, -64, 0, -128, -144, 0, -288, 0, 0, 576 ], 
  [ 1, 2, 0, 0, -36, -18, -36, 8, -9, 16, 36, -18, 72, 90, 180, -288 ], 
  [ 1, -1, 27, -27, 0, 648, -648, -640, 2304, 640, -2160, -2304, 2160, 6912, 
      -6912, 0 ], 
  [ 1, -1, -18, 18, 0, 288, -288, -640, -576, 640, 1440, 576, -1440, 1152, 
      -1152, 0 ], 
  [ 1, -1, 15, -15, 0, 156, -156, 320, 384, -320, 600, -384, -600,-384,384,0], 
  [ 1, -1, -12, 12, 0, 102, -102, 140, -192, -140, -210, 192, 210, 
      48, -48, 0 ], 
  [ 1, -1, 10, -10, 0, 36, -36, -80, -16, 80, -100, 16, 100, -304, 304, 0 ], 
  [ 1, -1, 6, -6, 0, -24, 24, 32, -48, -32, 24, 48, -24, 192, -192, 0 ], 
  [ 1, -1, -6, 6, 0, -12, 12, -16, 48, 16, 12, -48, -12, -48, 48, 0 ] ] ],
##
[[1,5,7,9,14,19,21,23,27,38,40,44,47,72,78,86,88,94,95,99],
"$2^{4+6}:3S_6 \\rightarrow (Suz.2,13)$",
[ [ 1, 2, 180, 480, 960, 4608, 5760, 6144, 12288, 18432, 20480, 40960, 46080, 
      69120, 69120, 92160, 92160, 184320, 184320, 368640 ], 
  [ 1, 2, -45, 30, 60, 1008, 360, 1104, 2208, -288, -1120, -2240, 2880, 
      -6480, -1080, 5760, -5040, -10080, 4320, 8640 ], 
  [ 1, 2, 81, 84, 168, 648, 1008, -192, -384, 2592, 1472, 2944, -1440, 216, 
      2592, -2880, -2880, -5760, 576, 1152 ], 
  [ 1, 2, 45, -60, -120, -468, 900, 96, 192, 3312, -1120, -2240, 720, -540, 
      -2160, 1440, 1440, 2880, -1440, -2880 ], 
  [ 1, 2, 63, 90, 180, -72, 144, 216, 432, -288, -112, -224, -96, -1080, 
      1728, -192, 744, 1488, -1008, -2016 ], 
  [ 1, 2, -45, 30, 60, -288, 360, 96, 192, -288, 320, 640, 0, 0, -1080, 0, 0, 
      0, 0, 0 ], 
  [ 1, 2, -9, 18, 36, 72, -288, 264, 528, 288, -16, -32, -288, 1080, -432, 
      -576, -72, -144, -144, -288 ], 
  [ 1, 2, 21, -36, -72, 348, 228, 48, 96, -288, 112, 224, 240, 516, -288, 
      480, 240, 480, -784, -1568 ], 
  [ 1, 2, 45, 36, 72, -36, 36, -96, -192, -144, -160, -320, 144, 756, -432, 
      288, -288, -576, 288, 576 ], 
  [ 1, 2, 18, 0, 0, 18, -126, -24, -48, 72, 128, 256, 9, -540, -432, 18, 144, 
      288, 72, 144 ], 
  [ 1, 2, -27, 12, 24, 108, 36, -48, -96, 0, -112, -224, -144, -108, 0, -288, 
      144, 288, 144, 288 ], 
  [ 1, 2, -15, 0, 0, -48, -60, -24, -48, 72, 40, 80, 240, 120, 360, 480, 
      -120, -240, -280, -560 ], 
  [ 1, 2, 9, -24, -48, -72, 36, 24, 48, -72, -40, -80, -144, 0, 216, -288, 
      -72, -144, 216, 432 ], 
  [ 1, -1, 0, 60, -60, 0, 0, 432, -432, 0, -1120, 1120, 2880, 0, 0, -2880, 
      720, -720, 1440, -1440 ], 
  [ 1, -1, 0, 60, -60, 0, 0, 288, -288, 0, 320, -320, 0, 0, 0, 0, 1440, 
      -1440, -2880, 2880 ], 
  [ 1, -1, 0, -36, 36, 0, 0, 240, -240, 0, 32, -32, -192, 0, 0, 192, -240, 
      240, 288, -288 ], 
  [ 1, -1, 0, 24, -24, 0, 0, 0, 0, 0, 320, -320, 144, 0, 0, -144, 0, 0, 576, 
      -576 ], 
  [ 1, -1, 0, -24, 24, 0, 0, -48, 48, 0, -16, 16, 0, 0, 0, 0, 432, -432, 144, 
      -144 ],
  [ 1, -1, 0, 24, -24, 0, 0, 0, 0, 0, -128, 128, -192, 0, 0, 192, 
      0, 0, 128, -128 ], 
  [ 1, -1, 0, -6, 6, 0, 0, -30, 30, 0, 2, -2, 108, 0, 0, -108, -270, 270, 
      -342, 342 ] ] ] ];

MULTFREEINFO.("6.Suz.2"):=["$6.Suz.2$",
##
[[1,4,5,14,19,21,71,75,109,111,117,125,146,148,149,158],
"$U_5(2).2 \\rightarrow (Suz.2,8)$",
[ [ 1, 1, 2, 2, 1782, 1782, 1782, 2816, 2816, 5632, 5632, 11880, 38016, 
      41472, 41472, 41472 ], 
  [ 1, 1, 2, 2, 486, 486, 486, 512, 512, 1024, 1024, -1080, -3456, 0, 0, 0 ], 
  [ 1, 1, 2, 2, -198, -198, -198, 176, 176, 352, 352, 1980, -1584, -288, 
      -288, -288 ], 
  [ 1, 1, 2, 2, 66, 66, 66, 8, 8, 16, 16, 180, 576, -336, -336, -336 ], 
  [ 1, 1, 2, 2, -54, -54, -54, 32, 32, 64, 64, -180, 144, 0, 0, 0 ], 
  [ 1, 1, 2, 2, 18, 18, 18, -40, -40, -80, -80, 36, -288, 144, 144, 144 ], 
  [ 1, -1, 2, -2, 0, 0, 0, -352, 352, -704, 704, 0, 0, 0, 0, 0 ], 
  [ 1, -1, 2, -2, 0, 0, 0, 8, -8, 16, -16, 0, 0, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 297, 297, -594, 704, 704, -704, -704, 0, 0, 1728, 1728, 
      -3456 ], 
  [ 1, 1, -1, -1, -99, -99, 198, 176, 176, -176, -176, 0, 0, -144, -144, 288], 
  [ 1, 1, -1, -1, 45, 45, -90, 32, 32, -32, -32, 0, 0, -288, -288, 576 ], 
  [ 1, 1, -1, -1, -3, -3, 6, -16, -16, 16, 16, 0, 0, 48, 48, -96 ], 
  [ 1, -1, -1, 1, 891, -891, 0, -1408, 1408, 1408, -1408, 0, 0, -10368, 
      10368, 0 ], 
  [ 1, -1, -1, 1, 189, -189, 0, -160, 160, 160, -160, 0, 0, 864, -864, 0 ], 
  [ 1, -1, -1, 1, -99, 99, 0, -88, 88, 88, -88, 0, 0, 72, -72, 0 ], 
  [ 1, -1, -1, 1, 9, -9, 0, 20, -20, -20, 20, 0, 0, -36, 36, 0 ] ] ],
##
[[1,4,5,14,19,21,71,75,109,111,117,125,146,148,149,158],
"$U_5(2).2 \\rightarrow (Suz.2,8)$",
[ [ 1, 1, 2, 2, 1782, 1782, 1782, 2816, 2816, 5632, 5632, 11880, 38016, 
      41472, 41472, 41472 ], 
  [ 1, 1, 2, 2, 486, 486, 486, 512, 512, 1024, 1024, -1080, -3456, 0, 0, 0 ], 
  [ 1, 1, 2, 2, -198, -198, -198, 176, 176, 352, 352, 1980, -1584, -288, 
      -288, -288 ], 
  [ 1, 1, 2, 2, 66, 66, 66, 8, 8, 16, 16, 180, 576, -336, -336, -336 ], 
  [ 1, 1, 2, 2, -54, -54, -54, 32, 32, 64, 64, -180, 144, 0, 0, 0 ], 
  [ 1, 1, 2, 2, 18, 18, 18, -40, -40, -80, -80, 36, -288, 144, 144, 144 ], 
  [ 1, -1, 2, -2, 0, 0, 0, -352, 352, -704, 704, 0, 0, 0, 0, 0 ], 
  [ 1, -1, 2, -2, 0, 0, 0, 8, -8, 16, -16, 0, 0, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 297, 297, -594, 704, 704, -704, -704, 0, 0, 1728, 1728, 
      -3456 ], 
  [ 1, 1, -1, -1, -99, -99, 198, 176, 176, -176, -176, 0, 0, -144, -144,288], 
  [ 1, 1, -1, -1, 45, 45, -90, 32, 32, -32, -32, 0, 0, -288, -288, 576 ], 
  [ 1, 1, -1, -1, -3, -3, 6, -16, -16, 16, 16, 0, 0, 48, 48, -96 ], 
  [ 1, -1, -1, 1, 891, -891, 0, -1408, 1408, 1408, -1408, 0, 0, -10368, 
      10368, 0 ], 
  [ 1, -1, -1, 1, 189, -189, 0, -160, 160, 160, -160, 0, 0, 864, -864, 0 ], 
  [ 1, -1, -1, 1, -99, 99, 0, -88, 88, 88, -88, 0, 0, 72, -72, 0 ], 
  [ 1, -1, -1, 1, 9, -9, 0, 20, -20, -20, 20, 0, 0, -36, 36, 0 ] ] ] ];

MULTFREEINFO.("Isoclinic(6.Suz.2)"):=["$(6.Suz.2)^*$"];

MULTFREEINFO.("3.ON.2"):=["$3.ON.2$"];

MULTFREEINFO.("2.Fi22.2"):=["$2.Fi_{22}.2$",
##
[[1,2,5,6,17,18,113,114,118],"$O_7(3) \\rightarrow (Fi_{22}.2,3)$",
[ [ 1, 1, 728, 1080, 1080, 3159, 3159, 21840, 25272 ], 
  [ 1, 1, -728, -1080, -1080, 3159, 3159, 21840, -25272 ],
  [ 1, 1, 168, -120, -120, 279, 279, -560, 72 ], 
  [ 1, 1, -168, 120, 120, 279, 279, -560, -72 ], 
  [ 1, 1, 24, 24, 24, -9, -9, 16, -72 ], 
  [ 1, 1, -24, -24, -24, -9, -9, 16, 72 ],
  [ 1, -1, 0, 120*ER(-3), -120*ER(-3), 351, -351, 0, 0 ],
  [ 1, -1, 0, -120*ER(-3), 120*ER(-3), 351, -351, 0, 0 ],
  [ 1, -1, 0, 0, 0, -9, 9, 0, 0 ] ] ],
##
[[1,2,13,14,17,18,25,26,118,121],"$O_8^+(2):S_3 \\rightarrow (Fi_{22}.2,5)$",
[ [ 1, 1, 2, 3150, 3150, 22400, 22400, 44800, 75600, 75600 ], 
  [ 1, 1, -2, 3150, -3150, 22400, 22400, -44800, -75600, 75600 ], 
  [ 1, 1, 2, 342, 342, -64, -64, -128, -216, -216 ], 
  [ 1, 1, -2, 342, -342, -64, -64, 128, 216, -216 ], 
  [ 1, 1, 2, -18, -18, 224, 224, 448, -432, -432 ], 
  [ 1, 1, -2, -18, 18, 224, 224, -448, 432, -432 ],
  [ 1, 1, 2, -18, -18, -64, -64, -128, 144, 144 ], 
  [ 1, 1, -2, -18, 18, -64, -64, 128, -144, 144 ], 
  [ 1, -1, 0, 0, 0, 280, -280, 0, 0, 0 ], 
  [ 1, -1, 0, 0, 0, -80, 80, 0, 0, 0 ] ] ],
##
[[1,8,13,15,17,25,29,118,121],
"$O_8^+(2):3 \\times 2 \\rightarrow (Fi_{22}.2,6)$",
[ [ 1, 1, 2, 3150, 3150, 22400, 22400, 44800, 151200 ], 
  [ 1, 1, -2, -450, 450, 800, 800, -1600, 0 ], 
  [ 1, 1, 2, 342, 342, -64, -64, -128, -432 ], 
  [ 1, 1, -2, 126, -126, 224, 224, -448, 0 ], 
  [ 1, 1, 2, -18, -18, 224, 224, 448, -864 ], 
  [ 1, 1, 2, -18, -18, -64, -64, -128, 288 ], 
  [ 1, 1, -2, -18, 18, -64, -64, 128, 0 ], 
  [ 1, -1, 0, 0, 0, -280, 280, 0, 0 ], 
  [ 1, -1, 0, 0, 0, 80, -80, 0, 0 ] ] ],
##
[[1,2,5,6,13,14,17,18,25,26,27,28,33,34,113,114,118,121,126,127],
"$O_8^+(2):2 \\rightarrow (Fi_{22}.2,10)$",
[ [ 1, 1, 2, 2, 2, 2, 2, 3150, 3150, 6300, 6300, 22400, 22400, 44800, 44800, 
      44800, 44800, 44800, 226800, 226800 ], 
  [ 1, 1, 2, 2, -2, -2, -2, 3150, -3150, 6300, -6300, 22400, 22400, 44800, 
      44800, -44800, -44800, -44800, 226800, -226800 ], 
  [ 1, 1, -1, -1, 2, -1, -1, 630, 630, -630, -630, 2240, 2240, -2240, -2240, 
      4480, -2240, -2240, 0, 0 ], 
  [ 1, 1, -1, -1, -2, 1, 1, 630, -630, -630, 630, 2240, 2240, -2240, -2240, 
      -4480, 2240, 2240, 0, 0 ], 
  [ 1, 1, 2, 2, 2, 2, 2, 342, 342, 684, 684, -64, -64, -128, -128, -128, 
      -128, -128, -648, -648 ], 
  [ 1, 1, 2, 2, -2, -2, -2, 342, -342, 684, -684, -64, -64, -128, -128, 128, 
      128, 128, -648, 648 ], 
  [ 1, 1, 2, 2, 2, 2, 2, -18, -18, -36, -36, 224, 224, 448, 448, 448, 448, 
      448, -1296, -1296 ], 
  [ 1, 1, 2, 2, -2, -2, -2, -18, 18, -36, 36, 224, 224, 448, 448, -448, -448, 
      -448, -1296, 1296 ], 
  [ 1, 1, 2, 2, 2, 2, 2, -18, -18, -36, -36, -64, -64, -128, -128, -128, 
      -128, -128, 432, 432 ], 
  [ 1, 1, 2, 2, -2, -2, -2, -18, 18, -36, 36, -64, -64, -128, -128, 128, 128, 
      128, 432, -432 ], 
  [ 1, 1, -1, -1, 2, -1, -1, -90, -90, 90, 90, 80, 80, -80, -80, 160, -80, 
      -80, 0, 0 ], 
  [ 1, 1, -1, -1, -2, 1, 1, -90, 90, 90, -90, 80, 80, -80, -80, -160, 80, 80, 
      0, 0 ], 
  [ 1, 1, -1, -1, 2, -1, -1, 54, 54, -54, -54, -64, -64, 64, 64, -128, 64, 
      64, 0, 0 ], 
  [ 1, 1, -1, -1, -2, 1, 1, 54, -54, -54, 54, -64, -64, 64, 64, 128, -64, 
      -64, 0, 0 ], 
  [ 1, -1, 1, -1, 0, ER(-3), -ER(-3), 0, 0, 0, 0, -2800, 2800, 
      2800, -2800, 0, 2800*ER(-3), -2800*ER(-3), 0, 0 ], 
  [ 1, -1, 1, -1, 0, -ER(-3), ER(-3), 0, 0, 0, 0, -2800, 2800, 
      2800, -2800, 0, -2800*ER(-3), 2800*ER(-3), 0, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, 0, 0, -280, 280, -560, 560, 0, 0, 0, 0, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, 0, 0, 80, -80, 160, -160, 0, 0, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 0, ER(-3), -ER(-3), 0, 0, 0, 0, 8, -8, -8, 8, 0, 
      -8*ER(-3), 8*ER(-3), 0, 0 ],
  [ 1, -1, 1, -1, 0, -ER(-3), ER(-3), 0, 0, 0, 0, 8, -8, -8, 8, 0, 
      8*ER(-3), -8*ER(-3), 0, 0 ] ] ],
##
[[1,7,9,17,19,49,58,68,75,88,128,129,146],
"${^2F_4(2)^{\\prime}}.2 \\rightarrow (Fi_{22}.2,16)$",
[ [ 1, 1, 3510, 23400, 29952, 166400, 166400, 280800, 374400, 374400, 374400, 
      898560, 4492800 ], 
  [ 1, 1, -810, 1800, -1152, -6400, -6400, -21600, 28800, -14400, -14400, 
      34560, 0 ], 
  [ 1, 1, -378, 3960, -1152, 10880, 10880, 8640, -14400, -14400, -14400, 
      27648, -17280 ], 
  [ 1, 1, 342, 1224, -1728, 1664, 1664, 2016, 6912, 3744, 3744,-1152,-18432],
  [ 1, 1, 198, 1080, 1152, -640, -640, -2880, -2880, 2880, 2880, 4608,-5760], 
  [ 1, 1, 150, -120, 384, -256, -256, 1248, 768, -576, -576, 768, -1536 ], 
  [ 1, 1, 54, 72, -288, -352, -352, 0, -576, -144, -144, 0, 1728 ], 
  [ 1, 1, -42, 264, 192, 128, 128, -96, 384, -288, -288, -1920, 1536 ], 
  [ 1, 1, 54, -216, 0, 512, 512, -864, 0, 0, 0, 0, 0 ], 
  [ 1, 1, -90, -72, 0, -64, -64, 288, 0, 288, 288, 576, -1152 ], 
  [ 1, -1, 0, 0, 0, 800+720*ER(3), -800-720*ER(3), 0, 0, 
      1800-720*ER(3), -1800+720*ER(3), 0, 0 ], 
  [ 1, -1, 0, 0, 0, 800-720*ER(3), -800+720*ER(3), 0, 0, 
      1800+720*ER(3), -1800-720*ER(3), 0, 0 ],
  [ 1, -1, 0, 0, 0, -64, 64, 0, 0, -144, 144, 0, 0 ] ] ],
##
[[1,7,9,17,19,49,58,68,75,88,128,129,146],
"${^2F_4(2)^{\\prime}}.2 \\rightarrow (Fi_{22}.2,16)$",
[ [ 1, 1, 3510, 23400, 29952, 166400, 166400, 280800, 374400, 374400, 374400,
      898560, 4492800 ],
  [ 1, 1, -810, 1800, -1152, -6400, -6400, -21600, 28800, -14400, -14400,
      34560, 0 ],
  [ 1, 1, -378, 3960, -1152, 10880, 10880, 8640, -14400, -14400, -14400,
      27648, -17280 ],
  [ 1, 1, 342, 1224, -1728, 1664, 1664, 2016, 6912, 3744, 3744,-1152,-18432],
  [ 1, 1, 198, 1080, 1152, -640, -640, -2880, -2880, 2880, 2880, 4608,-5760],
  [ 1, 1, 150, -120, 384, -256, -256, 1248, 768, -576, -576, 768, -1536 ],
  [ 1, 1, 54, 72, -288, -352, -352, 0, -576, -144, -144, 0, 1728 ],
  [ 1, 1, -42, 264, 192, 128, 128, -96, 384, -288, -288, -1920, 1536 ],
  [ 1, 1, 54, -216, 0, 512, 512, -864, 0, 0, 0, 0, 0 ],
  [ 1, 1, -90, -72, 0, -64, -64, 288, 0, 288, 288, 576, -1152 ],
  [ 1, -1, 0, 0, 0, 800-720*ER(3), -800+720*ER(3), 0, 0,
      1800+720*ER(3), -1800-720*ER(3), 0, 0 ],
  [ 1, -1, 0, 0, 0, 800+720*ER(3), -800-720*ER(3), 0, 0,
      1800-720*ER(3), -1800+720*ER(3), 0, 0 ],
  [ 1, -1, 0, 0, 0, -64, 64, 0, 0, -144, 144, 0, 0 ] ] ] ];

MULTFREEINFO.("Isoclinic(2.Fi22.2)"):=["$(2.Fi_{22}.2)^*$",
##
[[1,2,5,6,17,18,113,114,118],"$O_7(3) \\rightarrow (Fi_{22}.2),3)$",
[ [ 1, 1, 728, 1080, 1080, 3159, 3159, 21840, 25272 ], 
  [ 1, 1, -728, -1080, -1080, 3159, 3159, 21840, -25272 ],
  [ 1, 1, 168, -120, -120, 279, 279, -560, 72 ], 
  [ 1, 1, -168, 120, 120, 279, 279, -560, -72 ], 
  [ 1, 1, 24, 24, 24, -9, -9, 16, -72 ],
  [ 1, 1, -24, -24, -24, -9, -9, 16, 72 ], 
  [ 1, -1, 0, 120*ER(3), -120*ER(3), -351, 351, 0, 0 ],
  [ 1, -1, 0, -120*ER(3), 120*ER(3), -351, 351, 0, 0 ],
  [ 1, -1, 0, 0, 0, 9, -9, 0, 0 ] ] ],
##
[[1,2,13,14,17,18,25,26,118,121],
"$O_8^+(2):S_3 \\rightarrow (Fi_{22}.2),5)$",
[ [ 1, 1, 2, 3150, 3150, 22400, 22400, 44800, 75600, 75600 ], 
  [ 1, 1, -2, 3150, -3150, 22400, 22400, -44800, 75600, -75600 ], 
  [ 1, 1, 2, 342, 342, -64, -64, -128, -216, -216 ], 
  [ 1, 1, -2, 342, -342, -64, -64, 128, -216, 216 ], 
  [ 1, 1, 2, -18, -18, 224, 224, 448, -432, -432 ], 
  [ 1, 1, -2, -18, 18, 224, 224, -448, -432, 432 ], 
  [ 1, 1, 2, -18, -18, -64, -64, -128, 144, 144 ], 
  [ 1, 1, -2, -18, 18, -64, -64, 128, 144, -144 ], 
  [ 1, -1, 0, 0, 0, -280, 280, 0, 0, 0 ], 
  [ 1, -1, 0, 0, 0, 80, -80, 0, 0, 0 ] ] ],
##
[[1,7,13,16,17,25,30,118,121],"$O_8^+(2):S_3 \\rightarrow (Fi_{22}.2),7)$",
[ [ 1, 1, 2, 3150, 3150, 22400, 22400, 44800, 151200 ], 
  [ 1, 1, -2, -450, 450, 800, 800, -1600, 0 ], 
  [ 1, 1, 2, 342, 342, -64, -64, -128, -432 ], 
  [ 1, 1, -2, 126, -126, 224, 224, -448, 0 ], 
  [ 1, 1, 2, -18, -18, 224, 224, 448, -864 ], 
  [ 1, 1, 2, -18, -18, -64, -64, -128, 288 ], 
  [ 1, 1, -2, -18, 18, -64, -64, 128, 0 ],
  [ 1, -1, 0, 0, 0, -280, 280, 0, 0 ], 
  [ 1, -1, 0, 0, 0, 80, -80, 0, 0 ] ] ],
##
[[1,2,5,6,13,14,17,18,25,26,27,28,33,34,113,114,118,121,126,127],
"$O_8^+(2):2 \\rightarrow (Fi_{22}.2),10)$",
[ [ 1, 1, 2, 2, 2, 2, 2, 3150, 3150, 6300, 6300, 22400, 22400, 44800, 44800, 
      44800, 44800, 44800, 226800, 226800 ], 
  [ 1, 1, 2, 2, -2, -2, -2, 3150, -3150, 6300, -6300, 22400, 22400, 44800, 
      44800, -44800, -44800, -44800, 226800, -226800 ], 
  [ 1, 1, -1, -1, 2, -1, -1, 630, 630, -630, -630, 2240, 2240, -2240, -2240, 
      4480, -2240, -2240, 0, 0 ], 
  [ 1, 1, -1, -1, -2, 1, 1, 630, -630, -630, 630, 2240, 2240, -2240, -2240, 
      -4480, 2240, 2240, 0, 0 ], 
  [ 1, 1, 2, 2, 2, 2, 2, 342, 342, 684, 684, -64, -64, -128, -128, -128, 
      -128, -128, -648, -648 ], 
  [ 1, 1, 2, 2, -2, -2, -2, 342, -342, 684, -684, -64, -64, -128, -128, 128, 
      128, 128, -648, 648 ], 
  [ 1, 1, 2, 2, 2, 2, 2, -18, -18, -36, -36, 224, 224, 448, 448, 448, 448, 
      448, -1296, -1296 ], 
  [ 1, 1, 2, 2, -2, -2, -2, -18, 18, -36, 36, 224, 224, 448, 448, -448, -448, 
      -448, -1296, 1296 ], 
  [ 1, 1, 2, 2, 2, 2, 2, -18, -18, -36, -36, -64, -64, -128, -128, -128, 
      -128, -128, 432, 432 ], 
  [ 1, 1, 2, 2, -2, -2, -2, -18, 18, -36, 36, -64, -64, -128, -128, 128, 128, 
      128, 432, -432 ], 
  [ 1, 1, -1, -1, 2, -1, -1, -90, -90, 90, 90, 80, 80, -80, -80, 160, -80, 
      -80, 0, 0 ], 
  [ 1, 1, -1, -1, -2, 1, 1, -90, 90, 90, -90, 80, 80, -80, -80, -160, 80, 80, 
      0, 0 ], 
  [ 1, 1, -1, -1, 2, -1, -1, 54, 54, -54, -54, -64, -64, 64, 64, -128, 64, 
      64, 0, 0 ], 
  [ 1, 1, -1, -1, -2, 1, 1, 54, -54, -54, 54, -64, -64, 64, 64, 128, -64, 
      -64, 0, 0 ], 
  [ 1, -1, 1, -1, 0, ER(3), -ER(3), 0, 0, 0, 0,
      -2800, 2800, 2800, -2800, 0, 2800*ER(3), -2800*ER(3), 0, 0 ], 
  [ 1, -1, 1, -1, 0,  -ER(3), ER(3), 0, 0, 0, 0,
      -2800, 2800, 2800, -2800, 0, -2800*ER(3), 2800*ER(3), 0, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, 0, 0, -280, 280, -560, 560, 0, 0, 0, 0, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, 0, 0, 80, -80, 160, -160, 0, 0, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 0, ER(3), -ER(3), 0, 0, 0, 0, 
       8, -8, -8, 8, 0, -8*ER(3), 8*ER(3), 0, 0 ], 
  [ 1, -1, 1, -1, 0, -ER(3), ER(3), 0, 0, 0, 0,
       8, -8, -8, 8, 0, 8*ER(3), -8*ER(3), 0, 0 ] ] ],
##
[[1,5,6,7,13,16,17,25,27,28,30,33,34,113,114,118,121,126,127],
"$O_8^+(2):2 \\rightarrow (Fi_{22}.2),11)$",
[ [ 1, 1, 2, 2, 2, 2, 2, 3150, 3150, 6300, 6300, 22400, 22400, 44800, 44800, 
      44800, 44800, 44800, 453600 ], 
  [ 1, 1, -1, -1, -1, -1, 2, 630, 630, -630, -630, 2240, 2240, 4480, -2240, 
      -2240, -2240, -2240, 0 ], 
  [ 1, 1, 1, 1, -1, -1, -2, 630, -630, 630, -630, 2240, 2240, -4480, -2240, 
      -2240, 2240, 2240, 0 ], 
  [ 1, 1, -2, -2, 2, 2, -2, -450, 450, 900, -900, 800, 800, -1600, 1600, 
      1600, -1600, -1600, 0 ], 
  [ 1, 1, 2, 2, 2, 2, 2, 342, 342, 684, 684, -64, -64, -128, -128, -128, 
      -128, -128, -1296 ], 
  [ 1, 1, -2, -2, 2, 2, -2, 126, -126, -252, 252, 224, 224, -448, 448, 448, 
      -448, -448, 0 ],
  [ 1, 1, 2, 2, 2, 2, 2, -18, -18, -36, -36, 224, 224, 448, 448, 448, 448, 
      448, -2592 ], 
  [ 1, 1, 2, 2, 2, 2, 2, -18, -18, -36, -36, -64, -64, -128, -128, -128, 
      -128, -128, 864 ], 
  [ 1, 1, -1, -1, -1, -1, 2, -90, -90, 90, 90, 80, 80, 160, -80, -80, -80, 
      -80, 0 ],
  [ 1, 1, 1, 1, -1, -1, -2, -90, 90, -90, 90, 80, 80, -160, -80, -80, 80,
      80, 0 ],
  [ 1, 1, -2, -2, 2, 2, -2, -18, 18, 36, -36, -64, -64, 128, -128, -128, 128, 
      128, 0 ],
  [ 1, 1, -1, -1, -1, -1, 2, 54, 54, -54, -54, -64, -64, -128, 64, 64, 64, 
      64, 0 ],
  [ 1, 1, 1, 1, -1, -1, -2, 54, -54, 54, -54, -64, -64, 128, 64, 64, -64, 
      -64, 0 ], 
  [ 1, -1, ER(3), -ER(3), -1, 1, 0, 0, 0, 0, 0, 2800, -2800, 0, 2800, -2800, 
      2800*ER(3), -2800*ER(3), 0 ],
  [ 1, -1, -ER(3), ER(3), -1, 1, 0, 0, 0, 0, 0, 2800, -2800, 0, 2800, -2800, 
      -2800*ER(3), 2800*ER(3), 0 ],
  [ 1, -1, 0, 0, 2, -2, 0, 0, 0, 0, 0, 280, -280, 0, -560, 560, 0, 0, 0 ], 
  [ 1, -1, 0, 0, 2, -2, 0, 0, 0, 0, 0, -80, 80, 0, 160, -160, 0, 0, 0 ],
  [ 1, -1, ER(3), -ER(3), -1, 1, 0, 0, 0, 0, 0, 
       -8, 8, 0, -8, 8, -8*ER(3), 8*ER(3), 0 ],
  [ 1, -1, -ER(3), ER(3), -1, 1, 0, 0, 0, 0, 0, 
       -8, 8, 0, -8, 8, 8*ER(3), -8*ER(3), 0 ] ] ] ];

MULTFREEINFO.("3.Fi22.2"):=["$3.Fi_{22}.2$",
##
[[1,13,17,25,113,117,120],
"$O_8^+(2):S_3 \\times 2 \\rightarrow (Fi_{22}.2,4)$",
[ [ 1, 2, 1575, 3150, 37800, 67200, 75600 ], 
  [ 1, 2, 171, 342, -108, -192, -216 ], 
  [ 1, 2, -9, -18, -216, 672, -432 ], 
  [ 1, 2, -9, -18, 72, -192, 144 ], 
  [ 1, -1, 375, -375, 1800, 0, -1800 ], 
  [ 1, -1, 39, -39, -216, 0, 216 ],
  [ 1, -1, -21, 21, 84, 0, -84 ] ] ],
##
[[1,8,13,15,17,25,29,113,114,117,120,122],
"$O_8^+(2):3 \\times 2 \\rightarrow (Fi_{22}.2,6)$",
[ [ 1, 1, 2, 2, 1575, 1575, 3150, 3150, 67200, 67200, 75600, 151200 ], 
  [ 1, -1, 2, -2, 225, -225, 450, -450, 2400, -2400, 0, 0 ], 
  [ 1, 1, 2, 2, 171, 171, 342, 342, -192, -192, -216, -432 ], 
  [ 1, -1, 2, -2, -63, 63, -126, 126, 672, -672, 0, 0 ], 
  [ 1, 1, 2, 2, -9, -9, -18, -18, 672, 672, -432, -864 ], 
  [ 1, 1, 2, 2, -9, -9, -18, -18, -192, -192, 144, 288 ], 
  [ 1, -1, 2, -2, 9, -9, 18, -18, -192, 192, 0, 0 ], 
  [ 1, 1, -1, -1, 375, 375, -375, -375, 0, 0, 3600, -3600 ], 
  [ 1, -1, -1, 1, 105, -105, -105, 105, 0, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 39, 39, -39, -39, 0, 0, -432, 432 ], 
  [ 1, 1, -1, -1, -21, -21, 21, 21, 0, 0, 168, -168 ], 
  [ 1, -1, -1, 1, -15, 15, 15, -15, 0, 0, 0, 0 ] ] ],
##
[[1,7,13,16,17,25,30,119,124],"$O_8^+(2):S_3 \\rightarrow (Fi_{22}.2,7)$",
[ [ 1, 2, 3, 1575, 3150, 4725, 67200, 67200, 226800 ], 
  [ 1, 2, -3, -225, -450, 675, -2400, 2400, 0 ], 
  [ 1, 2, 3, 171, 342, 513, -192, -192, -648 ], 
  [ 1, 2, -3, 63, 126, -189, -672, 672, 0 ], 
  [ 1, 2, 3, -9, -18, -27, 672, 672, -1296 ], 
  [ 1, 2, 3, -9, -18, -27, -192, -192, 432 ], 
  [ 1, 2, -3, -9, -18, 27, 192, -192, 0 ],
  [ 1, -1, 0, 75, -75, 0, 0, 0, 0 ], 
  [ 1, -1, 0, -21, 21, 0, 0, 0, 0 ] ] ],
##
[[1,7,13,16,17,25,30,113,114,117,120,122],
"$O_8^+(2):S_3 \\rightarrow (Fi_{22}.2,7)$",
[ [ 1, 1, 2, 2, 1575, 1575, 3150, 3150, 67200, 67200, 75600, 151200 ], 
  [ 1, -1, 2, -2, 225, -225, 450, -450, 2400, -2400, 0, 0 ], 
  [ 1, 1, 2, 2, 171, 171, 342, 342, -192, -192, -216, -432 ], 
  [ 1, -1, 2, -2, -63, 63, -126, 126, 672, -672, 0, 0 ], 
  [ 1, 1, 2, 2, -9, -9, -18, -18, 672, 672, -432, -864 ], 
  [ 1, 1, 2, 2, -9, -9, -18, -18, -192, -192, 144, 288 ], 
  [ 1, -1, 2, -2, 9, -9, 18, -18, -192, 192, 0, 0 ], 
  [ 1, 1, -1, -1, 375, 375, -375, -375, 0, 0, 3600, -3600 ], 
  [ 1, -1, -1, 1, 105, -105, -105, 105, 0, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 39, 39, -39, -39, 0, 0, -432, 432 ], 
  [ 1, 1, -1, -1, -21, -21, 21, 21, 0, 0, 168, -168 ], 
  [ 1, -1, -1, 1, -15, 15, 15, -15, 0, 0, 0, 0 ] ] ],
##
[[1,5,13,17,25,27,33,113,117,119,120,124],
"$O_8^+(2):2 \\times 2 \\rightarrow (Fi_{22}.2,8)$",
[ [ 1, 2, 2, 4, 1575, 3150, 3150, 6300, 67200, 113400, 134400, 226800 ], 
  [ 1, 2, -1, -2, 315, 630, -315, -630, 6720, 0, -6720, 0 ], 
  [ 1, 2, 2, 4, 171, 342, 342, 684, -192, -324, -384, -648 ], 
  [ 1, 2, 2, 4, -9, -18, -18, -36, 672, -648, 1344, -1296 ], 
  [ 1, 2, 2, 4, -9, -18, -18, -36, -192, 216, -384, 432 ], 
  [ 1, 2, -1, -2, -45, -90, 45, 90, 240, 0, -240, 0 ], 
  [ 1, 2, -1, -2, 27, 54, -27, -54, -192, 0, 192, 0 ], 
  [ 1, -1, 2, -2, 375, -375, 750, -750, 0, 5400, 0, -5400 ], 
  [ 1, -1, 2, -2, 39, -39, 78, -78, 0, -648, 0, 648 ], 
  [ 1, -1, -1, 1, 75, -75, -75, 75, 0, 0, 0, 0 ], 
  [ 1, -1, 2, -2, -21, 21, -42, 42, 0, 252, 0, -252 ], 
  [ 1, -1, -1, 1, -21, 21, 21, -21, 0, 0, 0, 0 ] ] ],
##
[[1,5,9,13,17,19,25,33,46,52,113,117,119,120,124,125,132],
"$2^7:S_6(2) \\rightarrow (Fi_{22}.2,14)$",
[ [ 1, 2, 135, 270, 1260, 2304, 2520, 4608, 8640, 17280, 30240, 45360, 90720, 
      241920, 430080, 483840, 725760 ], 
  [ 1, 2, -15, -30, 210, 624, 420, 1248, -960, -1920, 5040, 1260, 2520, 
      -1680, 26880, -3360, -30240 ], 
  [ 1, 2, -27, -54, 126, -288, 252, -576, 216, 432, 3024, -2268, -4536, 6048, 
      -5376, 12096, -9072 ], 
  [ 1, 2, 57, 114, 246, 120, 492, 240, 840, 1680, 288, 1368, 2736, 120, 
      -4224, 240, -4320 ], 
  [ 1, 2, 3, 6, -60, 192, -120, 384, 192, 384, 936, -576, -1152, -960, -768, 
      -1920, 3456 ], 
  [ 1, 2, 21, 42, 30, -96, 60, -192, -168, -336, 720, 180, 360, -672, -768, 
      -1344, 2160 ], 
  [ 1, 2, 27, 54, 36, 0, 72, 0, 0, 0, -432, -432, -864, 0, 1536, 0, 0 ], 
  [ 1, 2, -15, -30, 66, 48, 132, 96, -96, -192, -144, -36, -72, 48, -768, 96, 
      864 ], 
  [ 1, 2, -9, -18, 0, -36, 0, -72, 72, 144, 0, 0, 0, -252, 672, -504, 0 ], 
  [ 1, 2, 3, 6, -24, 12, -48, 24, -24, -48, -36, 72, 144, 228, -336, 456, 
      -432 ], 
  [ 1, -1, 75, -75, 420, 384, -420, -384, 1920, -1920, 0, 5040, -5040, 13440, 
      0, -13440, 0 ], 
  [ 1, -1, 39, -39, 108, 0, -108, 0, 192, -192, 0, -144, 144, -1536, 0, 1536, 
      0 ], 
  [ 1, -1, -15, 15, 90, 144, -90, -144, -240, 240, 0, 180, -180, -240, 0, 
      240, 0 ], 
  [ 1, -1, 9, -9, -42, 120, 42, -120, 72, -72, 0, -504, 504, 504, 0, -504,0],
  [ 1, -1, -15, 15, 42, -48, -42, 48, 48, -48, 0, -252, 252, 336, 0, 
      -336, 0 ], 
  [ 1, -1, 15, -15, 0, -36, 0, 36, -120, 120, 0, 0, 0, 420, 0, -420, 0 ], 
  [ 1, -1, -3, 3, -18, 0, 18, 0, 24, -24, 0, 108, -108, -192, 0, 192, 0 ] ] ],
##
[[1,7,9,17,19,49,58,68,75,88,117,119,121,132,133,150,151],
"${^2F_4(2)^{\\prime}}.2 \\rightarrow (Fi_{22}.2,16)$",
[ [ 1, 2, 1755, 3510, 11700, 23400, 44928, 140400, 187200, 280800, 374400, 
      499200, 449280, 898560, 1123200, 2246400, 4492800 ], 
  [ 1, 2, -405, -810, 900, 1800, -1728, -10800, 14400, -21600, 28800, -19200, 
      17280, 34560, -43200, 0, 0 ], 
  [ 1, 2, -189, -378, 1980, 3960, -1728, 4320, -7200, 8640, -14400, 32640, 
      13824, 27648, -43200, -8640, -17280 ], 
  [ 1, 2, 171, 342, 612, 1224, -2592, 1008, 3456, 2016, 6912, 4992, -576, 
      -1152, 11232, -9216, -18432 ], 
  [ 1, 2, 99, 198, 540, 1080, 1728, -1440, -1440, -2880, -2880, -1920, 2304, 
      4608, 8640, -2880, -5760 ], 
  [ 1, 2, 75, 150, -60, -120, 576, 624, 384, 1248, 768, -768, 384, 768, 
      -1728, -768, -1536 ], 
  [ 1, 2, 27, 54, 36, 72, -432, 0, -288, 0, -576, -1056, 0, 0, -432, 864, 
      1728 ],
  [ 1, 2, -21, -42, 132, 264, 288, -48, 192, -96, 384, 384, -960, 
      -1920, -864, 768, 1536 ], 
  [ 1, 2, 27, 54, -108, -216, 0, -432, 0, -864, 0, 1536, 0, 0, 0, 0, 0 ], 
  [ 1, 2, -45, -90, -36, -72, 0, 144, 0, 288, 0, -192, 288, 576, 864, -576, 
      -1152 ], 
  [ 1, -1, 219, -219, 180, -180, 0, -1680, 2880, 1680, -2880, 0, 6144, -6144, 
      0, 3840, -3840 ], 
  [ 1, -1, 75, -75, 900, -900, 0, 1200, 0, -1200, 0, 0, -1920, 1920, 0, 9600, 
      -9600 ], 
  [ 1, -1, -117, 117, -156, 156, 0, 1872, 2496, -1872, -2496, 0, 0, 0,0,0,0],
  [ 1, -1, 51, -51, 12, -12, 0, 672, -480, -672, 480, 0, 768, -768, 
      0, -1536, 1536 ], 
  [ 1, -1, -69, 69, 180, -180, 0, -240, 0, 240, 0, 0, 384, -384, 0, -1920, 
      1920 ], 
  [ 1, -1, -21, 21, -60, 60, 0, -48, -192, 48, 192, 0, 192, -192, 
      0, 1344, -1344 ], 
  [ 1, -1, 27, -27, -12, 12, 0, -144, 192, 144, -192, 0, -576, 576, 0, -576, 
      576 ] ] ] ];

MULTFREEINFO.("6.Fi22.2"):=["$6.Fi_{22}.2$",
##
[[1,8,13,15,17,25,29,118,121,151,152,155,158,160,203,204],
"$O_8^+(2):3 \\times 2 \\rightarrow (Fi_{22}.2,6)$",
[ [ 1, 1, 2, 2, 2, 2, 2, 3150, 3150, 6300, 6300, 67200, 67200, 134400, 
      151200, 302400 ], 
  [ 1, 1, 2, 2, -2, -2, -2, -450, 450, 900, -900, 2400, 2400, -4800, 0, 0 ], 
  [ 1, 1, 2, 2, 2, 2, 2, 342, 342, 684, 684, -192, -192, -384, -432, -864 ], 
  [ 1, 1, 2, 2, -2, -2, -2, 126, -126, -252, 252, 672, 672, -1344, 0, 0 ], 
  [ 1, 1, 2, 2, 2, 2, 2, -18, -18, -36, -36, 672, 672, 1344, -864, -1728 ], 
  [ 1, 1, 2, 2, 2, 2, 2, -18, -18, -36, -36, -192, -192, -384, 288, 576 ], 
  [ 1, 1, 2, 2, -2, -2, -2, -18, 18, 36, -36, -192, -192, 384, 0, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, 0, 0, 840, -840, 0, 0, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, 0, 0, -240, 240, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 2, -1, -1, 750, 750, -750, -750, 0, 0, 0, 7200, -7200 ], 
  [ 1, 1, -1, -1, -2, 1, 1, -210, 210, -210, 210, 0, 0, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 2, -1, -1, 78, 78, -78, -78, 0, 0, 0, -864, 864 ], 
  [ 1, 1, -1, -1, 2, -1, -1, -42, -42, 42, 42, 0, 0, 0, 336, -336 ], 
  [ 1, 1, -1, -1, -2, 1, 1, 30, -30, 30, -30, 0, 0, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 0, -ER(-3), ER(-3), 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 0, ER(-3), -ER(-3), 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ],
##
[[1,7,9,17,19,49,58,68,75,88,
  128,129,146, 155,157,159,170,171,188,189, 228,229],
"${^2F_4(2)^{\\prime}}.2 \\rightarrow (Fi_{22}.2,16)$",
[ [ 1, 1, 2, 2, 3510, 7020, 23400, 46800, 89856, 280800, 374400, 374400, 
      374400, 499200, 499200, 561600, 898560, 1123200, 1123200, 1797120, 
      4492800, 8985600 ], 
  [ 1, 1, 2, 2, -810, -1620, 1800, 3600, -3456, -21600, 28800, 28800, 28800, 
      -19200, -19200, -43200, 34560, -43200, -43200, 69120, 0, 0 ], 
  [ 1, 1, 2, 2, -378, -756, 3960, 7920, -3456, 8640, -14400, -14400, -14400, 
      32640, 32640, 17280, 27648, -43200, -43200, 55296, -17280, -34560 ], 
  [ 1, 1, 2, 2, 342, 684, 1224, 2448, -5184, 2016, 6912, 6912, 6912, 4992, 
      4992, 4032, -1152, 11232, 11232, -2304, -18432, -36864 ], 
  [ 1, 1, 2, 2, 198, 396, 1080, 2160, 3456, -2880, -2880, -2880, -2880, 
      -1920, -1920, -5760, 4608, 8640, 8640, 9216, -5760, -11520 ], 
  [ 1, 1, 2, 2, 150, 300, -120, -240, 1152, 1248, 768, 768, 768, -768, -768, 
      2496, 768, -1728, -1728, 1536, -1536, -3072 ], 
  [ 1, 1, 2, 2, 54, 108, 72, 144, -864, 0, -576, -576, -576, -1056, -1056, 0, 
      0, -432, -432, 0, 1728, 3456 ], 
  [ 1, 1, 2, 2, -42, -84, 264, 528, 576, -96, 384, 384, 384, 384, 384, -192, 
      -1920, -864, -864, -3840, 1536, 3072 ], 
  [ 1, 1, 2, 2, 54, 108, -216, -432, 0, -864, 0, 0, 0, 1536, 1536, -1728, 0, 
      0, 0, 0, 0, 0 ], 
  [ 1, 1, 2, 2, -90, -180, -72, -144, 0, 288, 0, 0, 0, -192, -192, 576, 576, 
      864, 864, 1152, -1152, -2304 ], 
  [ 1, -1, 2, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
    2400+2160*ER(3), -2400-2160*ER(3), 0, 0,
    5400-2160*ER(3), -5400+2160*ER(3), 0, 0, 0 ], 
  [ 1, -1, 2, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
    2400-2160*ER(3), -2400+2160*ER(3), 0, 0,
    5400+2160*ER(3), -5400-2160*ER(3), 0, 0, 0 ], 
  [ 1, -1, 2, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, -192, 192, 0, 0, -432, 432, 0, 
      0, 0 ], 
  [ 1, 1, -1, -1, 438, -438, 360, -360, 0, -3360, 5760, -2880, -2880, 0, 0, 
      3360, 12288, 0, 0, -12288, 7680, -7680 ], 
  [ 1, 1, -1, -1, 150, -150, 1800, -1800, 0, 2400, 0, 0, 0, 0, 0, -2400, 
      -3840, 0, 0, 3840, 19200, -19200 ], 
  [ 1, 1, -1, -1, -234, 234, -312, 312, 0, 3744, 4992, -2496, -2496, 0, 0, 
      -3744, 0, 0, 0, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 102, -102, 24, -24, 0, 1344, -960, 480, 480, 0, 0, -1344, 
      1536, 0, 0, -1536, -3072, 3072 ], 
  [ 1, 1, -1, -1, -138, 138, 360, -360, 0, -480, 0, 0, 0, 0, 0, 480, 768, 0, 
      0, -768, -3840, 3840 ], 
  [ 1, 1, -1, -1, -42, 42, -120, 120, 0, -96, -384, 192, 192, 0, 0, 96, 384, 
      0, 0, -384, 2688, -2688 ], 
  [ 1, 1, -1, -1, 54, -54, -24, 24, 0, -288, 384, -192, -192, 0, 0, 288, 
      -1152, 0, 0, 1152, -1152, 1152 ], 
  [ 1, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 
    120*ER(-39), -120*ER(-39), 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
  [ 1, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0,
    -120*ER(-39), 120*ER(-39), 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ],
##
[[1,7,9,17,19,49,58,68,75,88,
  128,129,146,155,157,159,170,171,188,189,228,229],
"${^2F_4(2)^{\\prime}}.2 \\rightarrow (Fi_{22}.2,16)$",
[ [ 1, 1, 2, 2, 3510, 7020, 23400, 46800, 89856, 280800, 374400, 374400, 
      374400, 499200, 499200, 561600, 898560, 1123200, 1123200, 1797120, 
      4492800, 8985600 ], 
  [ 1, 1, 2, 2, -810, -1620, 1800, 3600, -3456, -21600, 28800, 28800, 28800, 
      -19200, -19200, -43200, 34560, -43200, -43200, 69120, 0, 0 ], 
  [ 1, 1, 2, 2, -378, -756, 3960, 7920, -3456, 8640, -14400, -14400, -14400, 
      32640, 32640, 17280, 27648, -43200, -43200, 55296, -17280, -34560 ], 
  [ 1, 1, 2, 2, 342, 684, 1224, 2448, -5184, 2016, 6912, 6912, 6912, 4992, 
      4992, 4032, -1152, 11232, 11232, -2304, -18432, -36864 ], 
  [ 1, 1, 2, 2, 198, 396, 1080, 2160, 3456, -2880, -2880, -2880, -2880, 
      -1920, -1920, -5760, 4608, 8640, 8640, 9216, -5760, -11520 ], 
  [ 1, 1, 2, 2, 150, 300, -120, -240, 1152, 1248, 768, 768, 768, -768, -768, 
      2496, 768, -1728, -1728, 1536, -1536, -3072 ], 
  [ 1, 1, 2, 2, 54, 108, 72, 144, -864, 0, -576, -576, -576, -1056, -1056, 0, 
      0, -432, -432, 0, 1728, 3456 ], 
  [ 1, 1, 2, 2, -42, -84, 264, 528, 576, -96, 384, 384, 384, 384, 384, -192, 
      -1920, -864, -864, -3840, 1536, 3072 ], 
  [ 1, 1, 2, 2, 54, 108, -216, -432, 0, -864, 0, 0, 0, 1536, 1536, -1728, 0, 
      0, 0, 0, 0, 0 ], 
  [ 1, 1, 2, 2, -90, -180, -72, -144, 0, 288, 0, 0, 0, -192, -192, 576, 576, 
      864, 864, 1152, -1152, -2304 ], 
  [ 1, -1, 2, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
    2400-2160*ER(3), -2400+2160*ER(3), 0, 0,
    5400+2160*ER(3), -5400-2160*ER(3), 0, 0, 0 ], 
  [ 1, -1, 2, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
    2400+2160*ER(3), -2400-2160*ER(3), 0, 0,
    5400-2160*ER(3), -5400+2160*ER(3), 0, 0, 0 ], 
  [ 1, -1, 2, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, -192, 192, 0, 0, -432, 432, 0, 
      0, 0 ], 
  [ 1, 1, -1, -1, 438, -438, 360, -360, 0, -3360, 5760, -2880, -2880, 0, 0, 
      3360, 12288, 0, 0, -12288, 7680, -7680 ], 
  [ 1, 1, -1, -1, 150, -150, 1800, -1800, 0, 2400, 0, 0, 0, 0, 0, -2400, 
      -3840, 0, 0, 3840, 19200, -19200 ], 
  [ 1, 1, -1, -1, -234, 234, -312, 312, 0, 3744, 4992, -2496, -2496, 0, 0, 
      -3744, 0, 0, 0, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 102, -102, 24, -24, 0, 1344, -960, 480, 480, 0, 0, -1344, 
      1536, 0, 0, -1536, -3072, 3072 ], 
  [ 1, 1, -1, -1, -138, 138, 360, -360, 0, -480, 0, 0, 0, 0, 0, 480, 768, 0, 
      0, -768, -3840, 3840 ], 
  [ 1, 1, -1, -1, -42, 42, -120, 120, 0, -96, -384, 192, 192, 0, 0, 96, 384, 
      0, 0, -384, 2688, -2688 ], 
  [ 1, 1, -1, -1, 54, -54, -24, 24, 0, -288, 384, -192, -192, 0, 0, 288, 
      -1152, 0, 0, 1152, -1152, 1152 ], 
  [ 1, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 
    120*ER(-39), -120*ER(-39), 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
  [ 1, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0,
    -120*ER(-39), 120*ER(-39), 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ] ];

MULTFREEINFO.("Isoclinic(6.Fi22.2)"):=["$(6.Fi_{22}.2)^*$",
##
[[1,7,13,16,17,25,30,118,121,157,162,209],
"$O_8^+(2):S_3 \\rightarrow (Fi_{22}.2,7)$",
[ [ 1, 1, 2, 2, 6, 3150, 6300, 9450, 67200, 67200, 134400, 453600 ], 
  [ 1, 1, 2, 2, -6, -450, -900, 1350, 2400, 2400, -4800, 0 ], 
  [ 1, 1, 2, 2, 6, 342, 684, 1026, -192, -192, -384, -1296 ], 
  [ 1, 1, 2, 2, -6, 126, 252, -378, 672, 672, -1344, 0 ], 
  [ 1, 1, 2, 2, 6, -18, -36, -54, 672, 672, 1344, -2592 ], 
  [ 1, 1, 2, 2, 6, -18, -36, -54, -192, -192, -384, 864 ], 
  [ 1, 1, 2, 2, -6, -18, -36, 54, -192, -192, 384, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, -840, 840, 0, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 240, -240, 0, 0 ], 
  [ 1, 1, -1, -1, 0, 150, -150, 0, 0, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 0, -42, 42, 0, 0, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ],
##
[[1,7,13,16,17,25,30,118,121,157,162,209],
"$O_8^+(2):S_3 \\rightarrow (Fi_{22}.2,7)$",
[ [ 1, 1, 2, 2, 6, 3150, 6300, 9450, 67200, 67200, 134400, 453600 ], 
  [ 1, 1, 2, 2, -6, -450, -900, 1350, 2400, 2400, -4800, 0 ], 
  [ 1, 1, 2, 2, 6, 342, 684, 1026, -192, -192, -384, -1296 ], 
  [ 1, 1, 2, 2, -6, 126, 252, -378, 672, 672, -1344, 0 ], 
  [ 1, 1, 2, 2, 6, -18, -36, -54, 672, 672, 1344, -2592 ], 
  [ 1, 1, 2, 2, 6, -18, -36, -54, -192, -192, -384, 864 ], 
  [ 1, 1, 2, 2, -6, -18, -36, 54, -192, -192, 384, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, -840, 840, 0, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 240, -240, 0, 0 ], 
  [ 1, 1, -1, -1, 0, 150, -150, 0, 0, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 0, -42, 42, 0, 0, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ],
##
[[1,7,13,16,17,25,30,118,121,151,152,155,158,160,203,204],
"$O_8^+(2):S_3 \\rightarrow (Fi_{22}.2,7)$",
[ [ 1, 1, 2, 2, 2, 2, 2, 3150, 3150, 6300, 6300, 67200, 67200, 134400, 
      151200, 302400 ], 
  [ 1, 1, 2, 2, -2, -2, -2, -450, 450, 900, -900, 2400, 2400, -4800, 0, 0 ], 
  [ 1, 1, 2, 2, 2, 2, 2, 342, 342, 684, 684, -192, -192, -384, -432, -864 ], 
  [ 1, 1, 2, 2, -2, -2, -2, 126, -126, -252, 252, 672, 672, -1344, 0, 0 ], 
  [ 1, 1, 2, 2, 2, 2, 2, -18, -18, -36, -36, 672, 672, 1344, -864, -1728 ], 
  [ 1, 1, 2, 2, 2, 2, 2, -18, -18, -36, -36, -192, -192, -384, 288, 576 ], 
  [ 1, 1, 2, 2, -2, -2, -2, -18, 18, 36, -36, -192, -192, 384, 0, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, 0, 0, 840, -840, 0, 0, 0 ], 
  [ 1, -1, -2, 2, 0, 0, 0, 0, 0, 0, 0, -240, 240, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 2, -1, -1, 750, 750, -750, -750, 0, 0, 0, 7200, -7200 ], 
  [ 1, 1, -1, -1, -2, 1, 1, -210, 210, -210, 210, 0, 0, 0, 0, 0 ], 
  [ 1, 1, -1, -1, 2, -1, -1, 78, 78, -78, -78, 0, 0, 0, -864, 864 ], 
  [ 1, 1, -1, -1, 2, -1, -1, -42, -42, 42, 42, 0, 0, 0, 336, -336 ], 
  [ 1, 1, -1, -1, -2, 1, 1, 30, -30, 30, -30, 0, 0, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 0, -ER(-3), ER(-3), 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, -1, 1, -1, 0, ER(-3), -ER(-3), 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ] ] ];

MULTFREEINFO.("3.F3+.2"):=["$3.F_{3+}.2$",
##
[[1,5,7,184,186],"$Fi_{23} \\times 2 \\rightarrow (F_{3+}.2,1)$",
[ [ 1, 2, 31671, 63342, 825792 ], 
  [ 1, 2, 351, 702, -1056 ], 
  [ 1, 2, -81, -162, 240 ],
  [ 1, -1, 3519, -3519, 0 ],
  [ 1, -1, -9, 9, 0 ] ] ],
##
[[1,4,5,7,10,15,21,26,28,37,44,48,51,54,73,75,83,
  184,185,186,188,189,191,192,194,198,206,218,221,223],
 "$O_{10}^-(2).2 \\rightarrow (F_{3+}.2,3)$",
[ [ 1, 2, 75735, 104448, 208896, 1570800, 3141600, 12773376, 25546752, 
      45957120, 67858560, 91914240, 107233280, 135717120, 214466560, 
      263208960, 526417920, 581644800, 1085736960, 1737179136, 2171473920, 
      5147197440, 5428684800, 7238246400, 10294394880, 10857369600, 
      14476492800, 17371791360, 34743582720, 37902090240 ], 
  [ 1, 2, -15147, -13056, -26112, 157080, 314160, 798336, 1596672, 2010624, 
      -3392928, 4021248, -1340416, -6785856, -2680832, -3290112, -6580224, 
      14541120, 27143424, -54286848, 54286848, 80424960, -67858560, 
      -90478080, 160849920, -135717120, -180956160, 108573696, 217147392, 
      -118444032 ], 
  [ 1, 2, 5265, 16752, 33504, 145740, 291480, 145152, 290304, -145920, 
      1955016, -291840, 4102784, 3910032, 8205568, -1983744, -3967488, 
      4918320, 16284240, 7112448, 32568480, -10730496, 30119040, -7197120, 
      -21460992, 60238080, -14394240, 7983360, 15966720, -134120448 ], 
  [ 1, 2, 9585, 5664, 11328, 27300, 54600, -266112, -532224, 798720, -302400, 
      1597440, 546560, -604800, 1093120, 2419200, 4838400, 6933600, -393120, 
      6483456, -786240, -5376000, 5443200, -22377600, -10752000, 10886400, 
      -44755200, -6289920, -12579840, 63866880 ], 
  [ 1, 2, -4455, 8544, 17088, 56100, 112200, -57024, -114048, 337920, 178200, 
      675840, 1168640, 356400, 2337280, 1468800, 2937600, -5346000, 1568160, 
      -9808128, 3136320, 5913600, 1425600, 1900800, 11827200, 2851200, 
      3801600, -15966720, -31933440, 21150720 ], 
  [ 1, 2, 6237, -2256, -4512, 26400, 52800, -14256, -28512, 489984, 28512, 
      979968, -256960, 57024, -513920, -1237248, -2474496, -2138400, 1012176, 
      6956928, 2024352, 3480576, -498960, -665280, 6961152, -997920, 
      -1330560, -6044544, -12089088, 6220800 ], 
  [ 1, 2, 2457, 1776, 3552, 10020, 20040, 55296, 110592, 26304, 129816, 
      52608, -75520, 259632, -151040, 262656, 525312, 537840, 20304, 485568, 
      40608, 561408, -544320, 665280, 1122816, -1088640, 1330560, -867456, 
      -1734912, -1762560 ], 
  [ 1, 2, -567, -2688, -5376, 19380, 38760, 16848, 33696, -37056, -132840, 
      -74112, -65152, -265680, -130304, 69120, 138240, 19440, 456192, 67392, 
      912384, -652800, -149040, 501120, -1305600, -298080, 1002240, -508032, 
      -1016064, 1368576 ], 
  [ 1, 2, -135, 3072, 6144, 14340, 28680, -1728, -3456, -30720, 26136, 
      -61440, 111104, 52272, 222208, -100224, -200448, -6480, -120960, 
      200448, -241920, -316416, -855360, 17280, -632832, -1710720, 34560, 
      552960, 1105920, 1907712 ], 
  [ 1, 2, -1917, -708, -1416, 2730, 5460, -16632, -33264, 34944, 15120, 
      69888, -6832, 30240, -13664, -30240, -60480, 173340, -9828, -202608, 
      -19656, -84000, -68040, 279720, -168000, -136080, 559440, -39312, 
      -78624, -199584 ], 
  [ 1, 2, 513, 912, 1824, 1596, 3192, -6912, -13824, -6528, -21816, -13056, 
      -2944, -43632, -5888, -6912, -13824, 71280, -34128, 3456, -68256, 
      167424, 124416, 63936, 334848, 248832, 127872, -152064, -304128, 
      -456192 ], 
  [ 1, 2, 837, -816, -1632, 3000, 6000, -5616, -11232, 384, 4752, 768, 2240, 
      9504, 4480, 24192, 48384, -64800, -54864, 44928, -109728, 36096, 19440, 
      -60480, 72192, 38880, -120960, 210816, 421632, -518400 ], 
  [ 1, 2, -945, 588, 1176, 1110, 2220, 4752, 9504, 10320, -4320, 20640, 
      -10720, -8640, -21440, 8640, 17280, -59940, -25380, -8208, -50760, 
      -58080, 77760, -50760, -116160, 155520, -101520, 151200, 302400, 
      -246240 ], 
  [ 1, 2, 1161, 48, 96, -780, -1560, 3456, 6912, 12480, -7560, 24960, 7424, 
      -15120, 14848, -6912, -13824, 9072, -5616, -53568, -11232, -74496, 
      -15552, 63936, -148992, -31104, 127872, 44928, 89856, -20736 ], 
  [ 1, 2, -297, -276, -552, 30, 60, 3456, 6912, -1776, -1728, -3552, 7424, 
      -3456, 14848, -6912, -13824, 17820, -20196, 4752, -40392, 36960, 19440, 
      -11880, 73920, 38880, -23760, -48384, -96768, 49248 ], 
  [ 1, 2, 189, 48, 96, 192, 384, -432, -864, -3072, 6048, -6144, -8128, 
      12096, -16256, -6912, -13824, -2592, 9936, -38016, 19872, -12288, 
      19440, -29376, -24576, 38880, -58752, -17280, -34560, 165888 ], 
  [ 1, 2, -135, 48, 96, -780, -1560, -1728, -3456, -480, -1080, -960, 2240, 
      -2160, 4480, 8640, 17280, -6480, 15120, 37152, 30240, -1920, -38880, 
      17280, -3840, -77760, 34560, 8640, 17280, -51840 ], 
  [ 1, -1, 0, 35904, -35904, 392700, -392700, -798336, 798336, 2872320, 
      8482320, -2872320, 16755200, -8482320, -16755200, -8225280, 8225280, 0, 
      101787840, 0, -101787840, -160849920, 339292800, -226195200, 160849920, 
      -339292800, 226195200, 542868480, -542868480, 0 ], 
  [ 1, -1, 0, -8160, 8160, 89760, -89760, -413424, 413424, 933504, -1332936, 
      -933504, -694144, 1332936, 694144, 4465152, -4465152, 0, 10178784, 0, 
      -10178784, -36765696, -20599920, 35544960, 36765696, 20599920, 
      -35544960, 19388160, -19388160, 0 ], 
  [ 1, -1, 0, 11208, -11208, 84000, -84000, 90720, -90720, 49920, 703080, 
      -49920, 1937600, -703080, -1937600, 665280, -665280, 0, 5103000, 0, 
      -5103000, 13009920, 5896800, 18295200, -13009920, -5896800, -18295200, 
      -8346240, 8346240, 0 ], 
  [ 1, -1, 0, -3984, 3984, 32340, -32340, 0, 0, 14784, -299376, -14784, 
      -142912, 299376, 142912, -495936, 495936, 0, 1496880, 0, -1496880, 
      2188032, -1995840, -1663200, -2188032, 1995840, 1663200, 1197504, 
      -1197504, 0 ], 
  [ 1, -1, 0, 4440, -4440, 24240, -24240, -23328, 23328, -42240, 91368, 
      42240, 261440, -91368, -261440, 1728, -1728, 0, 68040, 0, -68040, 
      -1026048, -1412640, -1740960, 1026048, 1412640, 1740960, -2021760, 
      2021760, 0 ], 
  [ 1, -1, 0, -1104, 1104, 7860, -7860, 67392, -67392, 106944, 32400, 
      -106944, -53056, -32400, 53056, 292032, -292032, 0, 81648, 0, -81648, 
      215808, -51840, -833760, -215808, 51840, 833760, -461376, 461376, 0 ], 
  [ 1, -1, 0, 1704, -1704, 4800, -4800, 14688, -14688, 49920, -57240, -49920, 
      36800, 57240, -36800, -95040, 95040, 0, -171720, 0, 171720, -168960, 
      194400, 237600, 168960, -194400, -237600, 17280, -17280, 0 ], 
  [ 1, -1, 0, 336, -336, 4260, -4260, -23328, 23328, 49344, 58320, -49344, 
      -70336, -58320, 70336, -70848, 70848, 0, 42768, 0, -42768, -37632, 
      142560, 73440, 37632, -142560, -73440, -513216, 513216, 0 ], 
  [ 1, -1, 0, -1104, 1104, 5340, -5340, -2160, 2160, -14016, -9936, 14016, 
      -4672, 9936, 4672, 13824, -13824, 0, -45360, 0, 45360, -58368, 174960, 
      43200, 58368, -174960, -43200, -158976, 158976, 0 ], 
  [ 1, -1, 0, 912, -912, 2568, -2568, 864, -864, -9984, 6696, 9984, -16768, 
      -6696, 16768, 13824, -13824, 0, -27216, 0, 27216, 70656, -33696, 43200, 
      -70656, 33696, -43200, 324864, -324864, 0 ], 
  [ 1, -1, 0, 192, -192, -492, 492, -3456, 3456, 1536, -7344, -1536, 512, 
      7344, -512, 13824, -13824, 0, 5184, 0, -5184, 24576, 31104, -34560, 
      -24576, -31104, 34560, -55296, 55296, 0 ], 
  [ 1, -1, 0, -240, 240, -60, 60, -864, 864, 3264, 3024, -3264, 5696, -3024, 
      -5696, -1728, 1728, 0, -14256, 0, 14256, 17664, -38880, 4320, -17664, 
      38880, -4320, 95040, -95040, 0 ], 
  [ 1, -1, 0, 30, -30, -330, 330, 2376, -2376, -2676, 1404, 2676, -2404, 
      -1404, 2404, -6588, 6588, 0, 12474, 0, -12474, -26616, 4860, 9180, 
      26616, -4860, -9180, -52380, 52380, 0 ] ] ] ];

MakeImmutable( MULTFREEINFO );

#############################################################################
##
#E

