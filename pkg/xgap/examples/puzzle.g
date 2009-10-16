#############################################################################
##
#W  puzzle.g                    GAP library                     Thomas Breuer
##
#H  @(#)$Id: puzzle.g,v 1.4 2000/09/26 17:34:34 gap Exp $
##
#Y  Copyright (C)  1998,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##


#############################################################################
##
#F  Puzzle( <m>, <n>[, <options>] )
##
##  `Puzzle' returns a sheet that shows a $<m> \times <n>$ rectangle
##  with $<m><n> - 1$ numbered squares and one free square indicated by
##  a red box in the lower right corner.
##  Clicking on a numbered square in the same row or column as the red box
##  will move the squares between the red box and the pointer towards the
##  place of the red box, and put the red box under the pointer.
##  The aim is to rearrange the numbered squares such that they are ordered.
##
##  If the optional argument <options> is present then it must be a record
##  with the following components.
##  \beginitems
##  `b' (default 30) &
##     the dimension of the squares,
##
##  `l' (default 2) &
##     the width of the separating lines,
##
##  `font' (default `FONTS.normal') &
##     the font chosen for the text, and
##
##  `color' (default `COLORS.red') &
##     the color chosen for the free square).
##  \enditems
##
##  The puzzle provides also an example for the effects caused by 
##  `FastUpdate' (see~"FastUpdate").
##  For a sheet <sheet> returned by `Puzzle',
##  call `FastUpdate( <sheet>, true )', move the red box in <sheet>,
##  and you will notice that you can make moved numbers disappear;
##  this is due to the fact that after the text has been moved to the
##  place of the red box, this box is moved away, and the system thinks
##  that nothings needs to be drawn in this place.
##  (Note that {\XGAP} does not support the idea that a graphic object
##  lies (partially) above or under another graphic object.)
##  The correct status of <sheet> can be recovered by calling
##  `FastUpdate( <sheet>, false )'.
##
BindGlobal( "Puzzle", function( arg )

    local m,        # number of rows
          n,        # number of columns
          options,  # options record
          b,        # dimension of squares
          l,        # line width
          bl,       # `b + l'
          font,     # font chosen for text (numbers)
          red,      # the colour of the free square
          hori,     # width of the sheet
          vert,     # height of the sheet
          sheet,    # graphic sheet containing the puzzle
          i,        # loop over rows
          j,        # loop over columns
          free,     # the red box
          boxpos,   # list with position of the free square
          pi,       # random permutation
          matrix,   # matrix containing the text objects
          x;        # random element in `numbers'

    # Get and check the arguments.
    if   Length( arg ) = 2 and IsPosInt( arg[1] ) and IsPosInt( arg[2] ) then
      m:= arg[1];
      n:= arg[2];
      options:= rec( b:= 30,
                     l:= 2,
                     font:= FONTS.normal,
                     color:= COLORS.red );
    elif Length( arg ) = 3 and IsPosInt( arg[1] ) and IsPosInt( arg[2] )
                           and IsRecord( arg[3] ) then
      m:= arg[1];
      n:= arg[2];
      options:= arg[3];
    else
      Error( "usage: Puzzle( <m>, <n>[, <options>] )" );
    fi;

    b    := options.b;
    l    := options.l;
    bl   := b + l;
    font := options.font;
    red  := options.color;

    # Compute the dimensions of the sheet.
    if b mod 2 = 1 then
      b:= b + 1;
    fi;
    hori := n * bl + l;
    vert := m * bl + l;

    # Construct the sheet
    sheet := GraphicSheet(
                 Concatenation( String( m ), "x", String( n ), " puzzle" ), 
                 hori,
                 vert );

    # Draw the horizontal and vertical ``lines''.
    for i in [ 0 .. m ] do
      Box( sheet, 0, i * bl - 1, hori, l );
    od;
    for j in [ 0 .. n ] do
      Box( sheet, j * bl - 1, 0, l, vert );
    od;

    # Draw a red box in the lower right corner square.
    free:= Box( sheet, ( n - 1 ) * bl + l - 1,
                       ( m - 1 ) * bl + l - 1, b, b );
    Recolor( free, red );
    boxpos:= [ m, n ];

    # Choose an initial numbering of the squares except the free one.
    pi:= Random( AlternatingGroup( m * n - 1 ) );
    matrix:= [];
    x:= 1;
    for i in [ 0 .. m-1 ] do
      matrix[ i+1 ]:= [];
      for j in [ 0 .. n - 1 - QuoInt( i, m-1 ) ] do
        matrix[ i+1 ][ j+1 ]:= Text( sheet, font,
                                     j * bl + b/2,
                                     i * bl + b/2,
                                     String( x^pi ) );
        x:= x + 1;
      od;
    od;

    # Clicking the left mouse button in a square of the puzzle will
    # move the free square to this position.
    InstallCallback( sheet, "LeftPBDown", function( sheet, x, y )

        local i, j, k, z;

        # Compute in which square the cursor is.
        i:= QuoInt( y - l, bl ) + 1;
        j:= QuoInt( x - l, bl ) + 1;

        if i = boxpos[1] then

          k:= boxpos[2];

          # The free square is in the same row as the cursor.
          # Move the texts between the two towards the cursor.
          if j < k then

            for z in [ k-1, k-2 .. j ] do
              matrix[i][ z+1 ]:= matrix[i][z];
              MoveDelta( matrix[i][ z+1 ], bl, 0 );
            od;

          elif k < j then

            for z in [ k, k+1 .. j-1 ] do
              matrix[i][z]:= matrix[i][ z+1 ];
              MoveDelta( matrix[i][z], - bl, 0 );
            od;

          fi;

          # Put the free square under the cursor.
          MoveDelta( free, bl * ( j - k ), 0 );
          Unbind( matrix[i][j] );
          boxpos[2]:= j;

        elif j = boxpos[2] then

          k:= boxpos[1];

          # The free square is in the same column as the cursor.
          # Move the texts between the two towards the cursor.
          if i < k then

            for z in [ k-1, k-2 .. i ] do
              matrix[ z+1 ][j]:= matrix[z][j];
              MoveDelta( matrix[ z+1 ][j], 0, bl );
            od;

          elif k < i then

            for z in [ k, k+1 .. i-1 ] do
              matrix[z][j]:= matrix[ z+1 ][j];
              MoveDelta( matrix[z][j], 0, - bl );
            od;

          fi;

          # Put the free square under the cursor.
          MoveDelta( free, 0, bl * ( i - k ) );
          Unbind( matrix[i][j] );
          boxpos[1]:= i;

        fi;
    end );

    # Return the sheet.
    return sheet;
end );


#############################################################################
##
#E

