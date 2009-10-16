
#T change: make the formats own records,
#T add ulc, add more than one labels line/column,
#T add pagebreaks

#T add alignment of the table itself (center on the page or so)
#T vertical alignment?


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
#E

