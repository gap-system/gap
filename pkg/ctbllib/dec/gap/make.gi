##############################################################################
##
#W  make.gi                                                      Thomas Breuer
##
#H  @(#)$Id: make.gi,v 1.4 2010/01/27 15:43:41 gap Exp $
##
#Y  Copyright  (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementations of {\GAP} functions that are needed
##  for the automatic construction of the database of decomposition matrices
##  from the {\GAP} character table library.
##


##############################################################################
##
#F  DecMatNames()
##
InstallGlobalFunction( DecMatNames, function()
    local result, simpnames, siz, cov, out, entry, i, j, tbl, pos,
          outint, list, a, covname, outname;

    Print( "#I  DecMatNames:  computing the names info for the database\n" );
    result:= [];

    simpnames:= AllCharacterTableNames( IsSimple, true );

    for i in [ 1 .. Length( simpnames ) ] do

      tbl:= CharacterTable( simpnames[i] );
      if not HasExtensionInfoCharacterTable( tbl ) then
        Print( "#E  no `ExtensionInfoCharacterTable' for `", simpnames[i],
               "'\n" );
        siz := "infinity";
        cov := "?";
        out := "?";
      else
        siz := Size( tbl );
        cov := ExtensionInfoCharacterTable( tbl )[1];
        out := ExtensionInfoCharacterTable( tbl )[2];
      fi;

      if   simpnames[i] in DecMatNamesSpecialCases[1] then
        pos:= Position( DecMatNamesSpecialCases[1], simpnames[i] );
        covname:= DecMatNamesSpecialCases[2][ pos ];
        Print( "#E  choosing `", covname, "' as cover for `", simpnames[i],
               "'\n" );
      elif ForAll( cov, x -> x in "0123456789" ) then
        if Length( cov ) = 0 then
          covname:= simpnames[i];
        else
          covname:= Concatenation( cov, ".", simpnames[i] );
          ConvertToStringRep( covname );
        fi;
      else
        Print( "#E  unknown noncyclic Schur cover for `", simpnames[i],
               "'\n" );
        covname:= simpnames[i];
      fi;

      pos:= Position( DecMatNamesSpecialCases2[1], covname );
      if pos <> fail then
        Print( "#E  replacing `", covname, "' by " );
        covname:= DecMatNamesSpecialCases2[2][ pos ];
        Print( "`", covname, "' \n" );
      fi;

      outint:= Int( out );
      entry:= [ [ simpnames[i], siz, covname ] ];
      if outint = 0 then
        list:= [ [], [] ];
      elif outint <> fail then
        list:= Difference( DivisorsInt( outint ), [ 1 ] );
        list:= [ List( list, String ), list ];
      elif out = "2^2" then
        list:= [ [ "2_1", "2_2", "2_3" ], [ 2, 2, 2 ] ];
      elif out = "3.2" then
        list:= [ [ "3", "2" ], [ 3, 2 ] ];
      elif out = "(3xS3)" then                   # U3(8)
        list:= [ [ "3_1", "3_2", "3_3", "2", "6" ], [ 3, 3, 3, 2, 6 ] ];
      elif out = "(2x4)" then                    # L2(81)
        list:= [ [ "2_1", "2_2", "2_3", "4_1", "4_2" ], [ 2, 2, 2, 4, 4 ] ];
      elif out = "D12" then                      # L3(4)
        list:= [ [ "2_1", "2_2", "2_3", "3", "6" ], [ 2, 2, 2, 3, 6 ] ];
      elif out = "D8" then                       # U4(3)
        list:= [ [ "2_1", "2_2", "2_3", "4" ], [ 2, 2, 2, 4 ] ];
      elif out = "S4" then                       # O8+(3)
        list:= [ [ "2_1", "2_2", "3", "4" ], [ 2, 2, 3, 4 ] ];
      elif out = "(2xD8)" then                   # L4(9)
#T add this to the list of special cases!
        list:= [ [], [] ];
      elif out = "5:4" then                      # U5(4)
#T add this to the list of special cases!
        list:= [ [], [] ];
      else
        Error( "unknown `out' value ", out );
      fi;

      for j in [ 1 .. Length( list[1] ) ] do
        outname:= Concatenation( covname, ".", list[1][j] );
        pos:= Position( DecMatNamesSpecialCases2[1], outname );
        if pos <> fail then
          Print( "#E  replacing `", outname, "' by " );
          outname:= DecMatNamesSpecialCases2[2][ pos ];
          Print( "`", outname, "' \n" );
          if outname <> fail and LibInfoCharacterTable( outname ) = fail then
            Error( "how to replace nonexistent extension ", outname, "?" );
          fi;
        fi;

        if outname <> fail then
          Add( entry, [ Concatenation( simpnames[i], ".", list[1][j] ),
                        siz * list[2][j], outname ] );
        fi;
      od;

      Add( result, entry );
    od;

    SortParallel( List( result, x -> x[1][2] ), result );
    Print( "#I  DecMatNames:  done\n" );
    return result;
end );


##############################################################################
##
#F  DecMatHeadingString( <simpname>, <p> )
##
InstallGlobalFunction( DecMatHeadingString, function( name, p )
    # preamble and header line
    return Concatenation( [
        "\\documentclass{article}\n",
        "\\pagestyle{empty}   % no page numbers\n",
        "\\textwidth15cm\n",
        "\\textheight 47\\baselineskip\n",
        "\\begin{document}\n",
        "\\mathversion{bold}  % for the heading only\n",
        "\\vspace*{-20pt}\n",
        "{\\LARGE $", name, "\\pmod{", String( p ), "}$}\n",
        "\\mathversion{normal}\n\n",
      ] );
end );


##############################################################################
##
#F  DecMatAppendMatrices( <str>, <decmatspos>, <mtbl>, <ordlabels>,
#F                        <modlabels>, <offset> )
##
InstallGlobalFunction( DecMatAppendMatrices,
    function( str, decmatspos, mtbl, ordlabels, modlabels, offset )
    local mtblblocks, ordtbl, irr, mirr, cen, cenker, kernels, i,
          ulc, blirr, blker, d,
          hlines, j, options, degliststr, len, freecols,
          ncols, ndigits, cols, start,
          ii, irrvals, special, nsg, n, fact, bl, factfus, factirr, inv,
          blocknr, k, r, rowportions;

    mtblblocks:= BlocksInfo( mtbl );
    ordtbl:= OrdinaryCharacterTable( mtbl );
    irr:= Irr( ordtbl );
    irrvals:= List( irr, ValuesOfClassFunction );
    mirr:= Irr( mtbl );
    cen:= Filtered( [ 1 .. NrConjugacyClasses( ordtbl ) ],
                    i -> SizesConjugacyClasses( ordtbl )[i] <= 2 );
    cenker:= chi -> Intersection( ClassPositionsOfKernel( chi ), cen );
    kernels:= Set( List( irr, cenker ) );

    for i in decmatspos do

      special:= false;

      # Check whether the block splits in a factor group.
      # (This happens only if the group is of type $m.G.a$ where
      # $a \geq 2$ acts nontrivially on $m$,
      # so $m \in \{ 3, 4, 6, 12 \}$.
      # Moreover we must have that the characteristic divides $m$.
      # In this case, check the maximal factor group on which $a$ acts
      # trivially and which contains some but not all ordinary irreducibles
      # in the block.
      if IsList( i ) then
        ii:= i[1];
      else
        ii:= i;
      fi;

      if 2 in SizesConjugacyClasses( ordtbl ){ cen }
         and Length( mtblblocks[ii].modchars ) > 1
         and Sum( SizesConjugacyClasses( ordtbl ){ cen } )
                  mod UnderlyingCharacteristic( mtbl ) = 0 then

        nsg:= Filtered( ClassPositionsOfNormalSubgroups( ordtbl ),
                        n -> IsSubset( cen, n ) );
        nsg:= Filtered( nsg, n -> ForAny( irr{ mtblblocks[ii].ordchars },
                 chi -> IsSubset( ClassPositionsOfKernel( chi ), n ) )
                              and ForAny( irr{ mtblblocks[ii].ordchars },
                 chi -> not IsSubset( ClassPositionsOfKernel( chi ), n ) ) );

        for n in nsg do

          fact:= CharacterTableFactorGroup( ordtbl, n );
          bl:= PrimeBlocks( fact, UnderlyingCharacteristic( mtbl ) ).block;

          # Get the positions of the contained irreducibles in the
          # list of irreducibles of the factor group.
          factfus:= GetFusionMap( ordtbl, fact );
          factirr:= List( Irr( fact ), chi -> chi{ factfus } );
          factirr:= List( factirr, chi -> Position( irrvals, chi ) );
          inv:= InverseMap( factirr );
          blocknr:= List( mtblblocks[ii].ordchars, x -> 0 );
          for j in [ 1 .. Length( mtblblocks[ii].ordchars ) ] do
            k:= mtblblocks[ii].ordchars[j];
            if IsBound( inv[k] ) then
              blocknr[j]:= bl[ inv[k] ];
            fi;
          od;
          if Length( Set( blocknr ) ) > 2 then
            if Length( Set( blocknr ) ) > 3 then
              Error( "what?" );
            fi;
            special:= true;
            break;
          fi;
        od;

      fi;

      # Prepare the upper left corner.
      ulc:= "\\mbox{\\bf Block";
      if IsInt( i ) then
        Append( ulc, " " );
        Append( ulc, String( i + offset ) );
        if special then
          Append( ulc, "$_1$, " );
          Append( ulc, String( i + offset ) );
          Append( ulc, "$_2$" );
        fi;
      elif IsList( i ) and Length( i ) = 2 then
        Append( ulc, "s " );
        Append( ulc, String( i[1] + offset ) );
        if special then
          Append( ulc, "$_1$, " );
          Append( ulc, String( i + offset ) );
          Append( ulc, "$_2$" );
        fi;
        Append( ulc, ", " );
        Append( ulc, String( i[2] + offset ) );
        if special then
          Append( ulc, "$_1$, " );
          Append( ulc, String( i + offset ) );
          Append( ulc, "$_2$" );
        fi;
        i:= i[1];
      elif IsList( i ) and Length( i ) = 4 then
        Append( ulc, "s " );
        Append( ulc, String( i[1] + offset ) );
        Append( ulc, ", " );
        Append( ulc, String( i[2] + offset ) );
        Append( ulc, ", " );
        Append( ulc, String( i[3] + offset ) );
        Append( ulc, ", " );
        Append( ulc, String( i[4] + offset ) );
        i:= i[1];
      else
        Error( "strange value of <i>" );
      fi;
      Append( ulc, ":}" );

      # Check where horizontal lines must be added.
      blirr:= irr{ mtblblocks[i].ordchars };
      blker:= List( blirr, x -> Position( kernels, cenker( x ) ) );
      hlines:= [];
      if Length( Set( blker ) ) > 1 then
        for j in [ 2 .. Length( blker ) ] do
          if blker[j-1] <> blker[j] then
            Add( hlines, j-1 );
          fi;
        od;
      fi;

      # Compute the maximal number of columns.
      # Consider
      # 1. ordinary degrees
      # 2. length of ordinary labels (nontrivial upward extension only)
      # 3. length of Brauer labels (nontrivial upward extension only)

      # 1. Let $d$ be the maximal number of digits in an ordinary degree.
      #    Then we allow `DecMatColsPerPage - Int( ( d - 2 ) / 4 )' columns.
      d:= LogInt( Maximum( List( blirr, Degree ) ), 10 ) + 1;
      d:= Int( ( d - 2 ) / 4 );
      if d < 0 then
        d:= 0;
      fi;
      ncols:= DecMatColsPerPage - d;

      # 2. For each 5 digits in subscript, subtract one column.
      #    (count the digit characters, plus signs, commas,
      # and `\ast' occurrences)
      ndigits:= Maximum( List( ordlabels{ mtblblocks[i].ordchars },
                               x -> Number( x, y -> y in "0123456789t" )
                                + Number( x, y -> y = ',' ) / 2
                                + Number( x, y -> y = '+' ) * 3/2 ) );
      ncols:= ncols - Int( ndigits / 5 );
      if ncols <= 0 then
        Error( "not enough space for a single column!" );
      fi;

      # 3. There are `ncols * 5' digits free for the columns,
      #    and each `\varphi' plus intercolumn space need 3 digits space.
      cols:= [];
      j:= 1;
      while j <= Length( mtblblocks[i].modchars ) do

        # Loop over column parts of the matrix.
        start:= j;
        ndigits:= ncols * 5;
        while ndigits >= 0 and j < Length( mtblblocks[i].modchars ) do
          j:= j+1;
          ndigits:= ndigits - 3
                     - Number( modlabels[ mtblblocks[i].modchars[j] ],
                               y -> y in "0123456789t" )
                     - Number( modlabels[ mtblblocks[i].modchars[j] ],
                               y -> y = ',' ) / 2
                     - Number( modlabels[ mtblblocks[i].modchars[j] ],
                               y -> y = '+' ) * 3/2;
        od;
        if ndigits < 0 then
          Add( cols, [ start .. j-1 ] );
        else
          Add( cols, [ start .. j ] );
          j:= j+1;
        fi;

      od;

      ncols:= cols;

      # Put the options together.
      options:= rec( rowlabels := ordlabels{ mtblblocks[i].ordchars },
                     collabels := modlabels{ mtblblocks[i].modchars },
                     nrows     := DecMatRowsPerPage,
                     ncols     := ncols,
                     ulc       := ulc,
                     hlines    := hlines );

      Append( str, "\n\\vspace*{10pt}\n" );

      # Add the matrix.
      if special then
        Append( str, DecMatLaTeXStringDecompositionMatrix( mtbl, i, options,
                                                           blocknr ) );
      else
        Append( str, LaTeXStringDecompositionMatrix( mtbl, i, options ) );
      fi;

      # Make the list of degrees of Brauer characters.
      n:= Length( mtblblocks[i].modchars );
      r:= DecMatRowsPerPage;
      k:= Int( n / r );
      rowportions:= List( [ 1 .. k ], x -> [ 1 .. r ] + (x-1)*r );
      if k*r < n then
        Add( rowportions, [ k*r+1 .. n ] );
      fi;

      degliststr:= "";
      if ndigits >= 25 then

        # The decomposition matrix and the list of degrees
        # fit one beside the other.

        Unbind( str[ Length( str ) ] );
        Unbind( str[ Length( str ) ] );
        Unbind( str[ Length( str ) ] );
        Append( str, "\\hspace{20pt}" );

        degliststr:= "\\begin{array}{rcl}\n";
        for j in mtblblocks[i].modchars{ rowportions[1] } do
          Append( degliststr, "    " );
          Append( degliststr, modlabels[j] );
          Append( degliststr, " & = & " );
          Append( degliststr, String( mirr[j][1] ) );
          Append( degliststr, "_{" );
          Append( degliststr, String( Number( [ 1 .. j ],
                                      x -> mirr[x][1] = mirr[j][1] ) ) );
          Append( degliststr, "} \\\\\n" );
        od;
        len:= Length( degliststr );
        for j in [ len-3 .. len ] do
          Unbind( degliststr[j] );
        od;
        Append( degliststr, "\n\\end{array}\n\\]\n\n" );

        rowportions:= rowportions{ [ 2 .. Length( rowportions ) ] };

      fi;

      if Length( rowportions ) mod 2 = 1 then
        r:= rowportions[ Length( rowportions ) ];
        rowportions[ Length( rowportions ) ]:=
            [ r[1] .. r[1]+Int( (Length(r)-1)/2 ) ];
        Add( rowportions, [ r[1]+Int( (Length(r)-1)/2 )+1
                            .. r[ Length( r ) ] ] );
      fi;

      for r in [ 1, 3 .. Length( rowportions ) - 1 ] do

        Append( degliststr, "\\[\n\\begin{array}{rcl}\n" );
        for j in mtblblocks[i].modchars{ rowportions[r] } do
          Append( degliststr, "    " );
          Append( degliststr, modlabels[j] );
          Append( degliststr, " & = & " );
          Append( degliststr, String( mirr[j][1] ) );
          Append( degliststr, "_{" );
          Append( degliststr, String( Number( [ 1 .. j ],
                                      x -> mirr[x][1] = mirr[j][1] ) ) );
          Append( degliststr, "} \\\\\n" );
        od;
        len:= Length( degliststr );
        for j in [ len-3 .. len ] do
          Unbind( degliststr[j] );
        od;
        Append( degliststr, "\n\\end{array}\n\\hspace{40pt}\n" );
        Append( degliststr, "\\begin{array}{rcl}\n" );
        for j in mtblblocks[i].modchars{ rowportions[ r+1 ] } do
          Append( degliststr, "    " );
          Append( degliststr, modlabels[j] );
          Append( degliststr, " & = & " );
          Append( degliststr, String( mirr[j][1] ) );
          Append( degliststr, "_{" );
          Append( degliststr, String( Number( [ 1 .. j ],
                                      x -> mirr[x][1] = mirr[j][1] ) ) );
          Append( degliststr, "} \\\\\n" );
        od;
        len:= Length( degliststr );
        for j in [ len-3 .. len ] do
          Unbind( degliststr[j] );
        od;
        Append( degliststr, "\n\\end{array}\n\\]\n\n" );

      od;

      Append( str, degliststr );

    od;
end );


##############################################################################
##
#F  DecMatLinesPortions( <entry>, <p> )
##
InstallGlobalFunction( DecMatLinesPortions, function( entry, p )
    local str, tbl, mtbl, mult, divisors, irr, nccl, portions, i, m, pos,
          mtblblocks, pos2, decmatspos, k, l, chi, conj, ppart, ordlabels,
          modlabels, fus, proj, offset, projchars, set, j,
          mirr, inv, options, poss, partner, linesportions,
          line, widths, width1, width2, classes;
    
    # Distribute the irreducibles according to their kernels
    # (modulo the `p'-part of the multiplier).
    tbl:= CharacterTable( entry[3] );
    if tbl = fail then
      return fail;
    fi;
    
    mtbl:= tbl mod p;
    if not HasIrr( mtbl ) then
      return fail;
    fi;
    
    mult:= Size( tbl ) / entry[2];
    ppart:= Product( Filtered( Factors( mult ), i -> i = p ) );
    divisors:= DivisorsInt( mult / ppart );
    if mult / ppart = 12 then
      # we have ppart = 1
      divisors:= [ 1, 2, 4, 3, 6, 12 ];
    else
      divisors:= ppart * divisors;
    fi;
    
    irr:= List( Irr( tbl ), ValuesOfClassFunction );
    mirr:= List( Irr( mtbl ), ValuesOfClassFunction );
    nccl:= Length( irr );
    classes:= SizesConjugacyClasses( tbl );
    portions:= [];
    for i in [ 2 .. Length( divisors ) ] do
    
      m:= mult / divisors[i];
    
      # The `i'-th portion consists of those characters with number of
      # classes in the kernel divisible by `m' and dividing `m*ppart'.
      portions[ divisors[i] ]:= Filtered( [ 1 .. nccl ],
          j -> m * ppart
                  mod Sum( classes{ ClassPositionsOfKernel( irr[j] ) } ) = 0
          and Sum( classes{ ClassPositionsOfKernel( irr[j] ) } ) mod m = 0 );
    
    od;
    portions[ divisors[1] ]:= Filtered( [ 1 .. nccl ],
        j -> Sum( classes{ ClassPositionsOfKernel( irr[j] ) } )
                 >= mult / ppart );
    
    # Compute the {\ATLAS} labels of the irreducibles.
    # (This is nontrivial only for characters of 3.G, 4.G, 6.G, 12.G.)
    ordlabels:= AtlasLabelsOfIrreducibles( tbl, "short" );
    if ordlabels = fail then
      Print( "#E  no Atlas labels for ", Identifier( tbl ), "\n" );
      ordlabels:= List( [ 1 .. NrConjugacyClasses( tbl ) ],
                        i -> Concatenation( "X_{", String( i ), "}" ) );
    fi;
    modlabels:= AtlasLabelsOfIrreducibles( mtbl, "short" );
    if modlabels = fail then
      Print( "#E  no Atlas labels for ", Identifier( mtbl ), "\n" );
      modlabels:= List( [ 1 .. NrConjugacyClasses( mtbl ) ],
                        i -> Concatenation( "Y_{", String( i ), "}" ) );
    fi;

    # concatenate labels with degrees
    for i in [ 1 .. Length( ordlabels ) ] do
      ordlabels[i]:= Concatenation( String( irr[i][1] ),
                                    "_{",
                                    String( Number( [ 1 .. i ],
                                              x -> irr[x][1] = irr[i][1] ) ),
                                    "} = ",
                                    ordlabels[i] );
    od;
    
    # prepare blocks information
    decmatspos:= [];
    
    # 1. first portion, i.e., characters of the simple group
    
    #T Make code up to here a function of its own!
    
    # Construct the lines of the information block.
    
    pos:= 0;
    pos2:= 1;
    mtblblocks:= BlocksInfo( mtbl );
    
    linesportions:= [];
    widths:= [];
    
    for k in [ 1 .. Length( divisors ) ] do
    
      l:= divisors[k];
      linesportions[k]:= [];
      line:= "";
      Add( linesportions[k], line );
    
      if l = 1 then
        Append( line, "G:\n" );
      else
        Append( line, String( l ) );
        Append( line, ".G:\n" );
      fi;
    
      pos2:= pos+1;
      while     pos2 <= Length( mtblblocks )
            and IsSubset( portions[l], mtblblocks[ pos2 ].ordchars ) do
        pos2:= pos2 + 1;
      od;
      pos2:= pos2 - 1;
    
      for i in [ pos + 1 .. pos2 ] do
    
        width1:= LogInt( i, 10 ) + 1;
        width2:= 0;
        chi:= irr[ mtblblocks[i].ordchars[ Length( mtblblocks[i].ordchars ) ] ];
    
        # number of the complex conjugate block
        conj:= List( chi, x -> GaloisCyc( x, -1 ) );
        conj:= Position( irr, conj );
        conj:= First( [ 1 .. Length( mtblblocks ) ],
                      j -> conj in mtblblocks[j].ordchars );
    
        # number(s) of the partner block(s); except for $12.M_{22} \bmod 11$,
        # this is done using `GaloisPartnersOfIrreducibles'
        if l > 2 then
          if l = 12 and p = 11 and Identifier( tbl ) = "12.M22" then
            partner:= [ -1 ];
          else
            partner:= GaloisPartnersOfIrreducibles( tbl, [ chi ], l )[1];
          fi;
          partner:= List( partner,
                          p -> Position( irr, List( chi,
                                                x -> GaloisCyc( x, p ) ) ) );
          partner:= List( partner, p -> First( [ 1 .. Length( mtblblocks ) ],
                      j -> p in mtblblocks[j].ordchars ) );
        else
          partner:= [ i ];
        fi;
    
        if    i <= Minimum( partner )
           or Conductor( chi{ ClassPositionsOfCentre( tbl ) } ) <= 2 then
    
          # Print *full* information if we are in G or 2.G
          # (so no partner need to be considered)
          # or if the block is the first relative to its partner block(s).
          Append( line, " \& " );
          Append( line, String( i ) );
          if conj < i then
    
            # In this case, *additionally* print complex conjugacy information
            # if the block is complex conjugate to an earlier block.
            Append( line, " = \\overline{" );
            Append( line, String( conj ) );
            Append( line, "}" );
            width1:= width1 +  LogInt( conj, 10 ) + 2;
    
          fi;
          Append( line, " \& " );
          Append( line, String( mtblblocks[i].defect ) );
          Append( line, " \& " );
          if Length( mtblblocks[i].ordchars ) = 1 then
    
            # defect zero block, print the labels of the two characters
            # (note that degree and index must coincide for the ordinary
            # and the Brauer character, so we print it only once)
            Append( line, ordlabels[ mtblblocks[i].ordchars[1] ] );
            Append( line, ", " );
            j:= mtblblocks[i].modchars[1];
            Append( line, modlabels[j] );
            width2:= width2 + LogInt( mirr[j][1], 10 ) + 1;
    
          else
    
            # print dimension of the decomposition matrix
            if Minimum( partner ) <= i then
              Add( decmatspos, i );
            else
              Add( decmatspos, Concatenation( [ i ], partner ) );
            fi;
            Append( line, String( Length( mtblblocks[i].ordchars ) ) );
            Append( line, " \\times " );
            Append( line, String( Length( mtblblocks[i].modchars ) ) );
    
          fi;
    
        else
    
          # Just print the relative information if the block is the partner
          # of an earlier block
          # (and thus the {\ATLAS} does not print the characters).
          if Length( partner ) = 1 then
            Append( line, " \& " );
            Append( line, String( i ) );
            Append( line, " = " );
            Append( line, String( partner[1] ) );
            Append( line, "\\ast \& \&" );
          else
            poss:= Position( partner, Minimum( partner ) );
            if   poss = 1 then
              poss:= 5;
            elif poss = 2 then
              poss:= 7;
            else
              poss:= 11;
            fi;
            Append( line, " \& " );
            Append( line, String( i ) );
            Append( line, " = " );
            Append( line, String( Minimum( partner ) ) );
            Append( line, "\\ast " );
            Append( line, String( poss ) );
            Append( line, " \& \&" );
          fi;
          width1:= width1 + LogInt( partner[1], 10 ) + 2;
    
        fi;
    
        line:= "";
        Add( linesportions[k], line );
        Add( widths, [ width1, width2 ] );
    
      od;
    
      Unbind( linesportions[k][ Length( linesportions[k] ) ] );
      pos:= pos2;
    
    od;
    
    return rec( linesportions := linesportions,
                widths        := widths,
                divisors      := divisors,
                decmatspos    := decmatspos,
                mtbl          := mtbl,
                ordlabels     := ordlabels,
                modlabels     := modlabels );
end );


##############################################################################
##
#F  DecMatInfoString( <linesportions>, <widths>, <divisors> )
##
InstallGlobalFunction( DecMatInfoString,
    function( linesportions, widths, divisors )
    local rows,        # number of rows in the info part
          i, k,        # loop variables
          str,         # output string
          beginarray,  # {\LaTeX} code for begin of an array
          endarray,    # {\LaTeX} code for end of an array
          colstr,
          port,
          pos,
          rows1,
          rows2;

    # Count the lines.
    rows:= 0;
    for i in linesportions do
      rows:= rows + Length( i );
    od;
    Print( "#I  no. of rows in info block: ", rows, "\n" );
    if rows <> Length( widths ) then
      Error( "widths and rows incompatible!" );
    fi;

    # Put the output string together.
    str:= "";

    beginarray:= Concatenation(
         "\\begin{array}[t]{|r|c|c|c|}\n\\hline\n",
         " \& \\mbox{\\rm blocks} \& \\mbox{\\rm defect} \& ",
         "\\mbox{\\rm matrix}\n",
         "\\rule[-7pt]{0pt}{20pt} \\\\\n",
         "\\hline\n" );
    endarray:= "\\end{array}\n";

    # Formatting:
    # If there are at least 10 rows and the degrees of defect zero characters
    # have at most 5 digits then force two-column output.
    # Each column has at most `DecMatRowsPerPage' rows.

    colstr:= function( no )

        local i;

        Append( str, beginarray );
        for i in [ 1 .. no ] do
          if pos = 1 then
            Append( str, "\\hline\n" );
          elif i = 1 then
            Append( str, "\\hline\n" );
            if port = 1 then
              Append( str, "\\phantom{G:}\n" );
            else
              Append( str, Concatenation( "\\phantom{",
                  String( divisors[ port ] ), ".G:}\n" ) );
            fi;
          fi;
          Append( str, linesportions[ port ][ pos ] );
          if pos = 1 or i = 1 then
            Append( str, "\n\\rule[0pt]{0pt}{13pt}" );
          fi;
          if pos = Length( linesportions[ port ] ) or i = no then
            Append( str, "\n\\rule[-7pt]{0pt}{5pt}" );
          fi;
          Append( str, " \\\\\n" );
          if pos = Length( linesportions[ port ] ) then
            Append( str, "\\hline\n" );
            port:= port+1;
            pos:= 1;
          else
            pos:= pos + 1;
          fi;
        od;
        Append( str, endarray );
    end;

    port:= 1;  # position in the list of portions
    pos:= 1;   # position in the current portion

    while rows > 2 * DecMatRowsPerPage do

      Append( str, "\\[\n" );
      colstr( DecMatRowsPerPage );
      rows:= rows - DecMatRowsPerPage;

      if Maximum( List( widths{ [ 1 .. DecMatRowsPerPage ] }, x -> x[1] ) ) +
         Maximum( List( widths{ [ 1 .. DecMatRowsPerPage ] }, x -> x[2] ) ) +
         Maximum( List( widths{ [ DecMatRowsPerPage + 1
                                .. 2 * DecMatRowsPerPage ] }, x -> x[1] ) ) +
         Maximum( List( widths{ [ DecMatRowsPerPage + 1
                                .. 2 * DecMatRowsPerPage ] }, x -> x[2] ) )
         <= DecMatInfoWidth then

        # two-column output on full pages
        Append( str, " \\hspace{20pt}\n" );
        colstr( DecMatRowsPerPage );
        rows:= rows - DecMatRowsPerPage;
        widths:= widths{ [ DecMatRowsPerPage+1 .. Length( widths ) ] };

      fi;

      widths:= widths{ [ DecMatRowsPerPage+1 .. Length( widths ) ] };
      Append( str, "\\]\n\n" );

    od;

    if rows > 0 then

      Append( str, "\\[\n" );

      if rows < 10 then

        # one-column output on a part of a page
        colstr( rows );

      else

        rows2:= Int( rows/2 );
        rows1:= rows - rows2;

        if Maximum( List( widths{ [ 1 .. rows1 ] }, x -> x[1] ) ) +
           Maximum( List( widths{ [ 1 .. rows1 ] }, x -> x[2] ) ) +
           Maximum( List( widths{ [ rows1 + 1 .. rows ] }, x -> x[1] ) ) +
           Maximum( List( widths{ [ rows1 + 1 .. rows ] }, x -> x[2] ) )
             <= DecMatInfoWidth then

          # check for two-column output on a part of a page
          colstr( rows1 );
          Append( str, " \\hspace{20pt}\n" );
          colstr( rows2 );

        elif rows <= DecMatRowsPerPage then

          # one-column output on at most one page
          colstr( rows );

        else

          # one-column output on a page and part of a page
          colstr( DecMatRowsPerPage );
          Append( str, "\\]\n\n\\[\n" );
          colstr( rows - DecMatRowsPerPage );

        fi;

      fi;

      Append( str, "\\]\n" );

    fi;


    # Return the info.
    return str;
end );


##############################################################################
##
#F  DecMatTreatSpecialCases( <simple>, <entry>, <p>, <info> )
##
##  for $L_3(4)$ and $U_4(3)$
##
InstallGlobalFunction( DecMatTreatSpecialCases,
    function( simple, entry, p, info )
    local entry2, info2, offset, offset2, offset3, i, line, pos, pos2, pos3,
          substr, no, newline, k;

    entry2:= ShallowCopy( entry );
    entry2[3]:= ShallowCopy( entry[3] );
    entry2[3][4]:= '2';
    info2:= DecMatLinesPortions( entry2, p );
    if info2 = fail then
      return;
    fi;

    if   simple = "U4(3)" and p = 2 then

      # Compute the offset of block numbers for the second table.
      # (for `DecMatAppendMatrices')
      offset:= Length( info.linesportions[2] );

      # Adjust `divisors' and `linesportions' components
      # (for `DecMatInfoString')
      info.linesportions[2][1]:= Concatenation( "12_1",
          info.linesportions[2][1]{ [ 3
                       .. Length( info.linesportions[2][1] ) ] } );
      info2.linesportions[2][1]:= Concatenation( "12_2",
          info2.linesportions[2][1]{ [ 3
                       .. Length( info2.linesportions[2][1] ) ] } );
      Add( info.linesportions, info2.linesportions[2] );
      Append( info.widths, info2.widths{ [ 1
                       .. Length( info2.linesportions[2] ) ]
                       + Length( info2.linesportions[1] ) } );
      info.divisors:= ShallowCopy( info.divisors );
      Add( info.divisors, 12 );

      for i in [ 1 .. Length( info2.linesportions[2] ) ] do
        line:= info2.linesportions[2][i];
        pos:= Position( line, '&' ) + 2;
        pos2:= Position( line, '&', pos ) - 2;
        substr:= line{ [ pos .. pos2 ] };
        no:= Int( substr );
        if no = fail then
          pos3:= Position( substr, '=' );
          no:= Int( substr{ [ 1 .. pos3-2 ] } );
          newline:= Concatenation( line{ [ 1 .. pos-1 ] },
              String( no + offset ), " = " );
          substr:= substr{ [ pos3+2 ..Length( substr ) ] };
          pos3:= Position( substr, '\\' );
          no:= Int( substr{ [ 1 .. pos3-1 ] } );
          Append( newline, String( no + offset ) );
          Append( newline, substr{ [ pos3 .. Length( substr ) ] } );
          Append( newline, line{ [ pos2+1 .. Length( line ) ] } );
          info2.linesportions[2][i]:= newline;
        else
          info2.linesportions[2][i]:= Concatenation( line{ [ 1 .. pos-1 ] },
              String( no + offset ), line{ [ pos2+1 .. Length( line ) ] } );
        fi;
      od;

      # Bind components for the second call of `DecMatAppendMatrices'.
      info.mtbl2:= info2.mtbl;
      info.offset:= offset;
      info.decmatspos2:= Difference( info2.decmatspos,
                             [ 1 .. Length( info2.linesportions[1] ) ] );
      info.ordlabels2:= info2.ordlabels;
      info.modlabels2:= info2.modlabels;

    elif simple = "U4(3)" and p = 3 then

      offset:= 0;  # second half belongs to different groups
                   # but same blocks ...

      info.linesportions[1][1]:= Concatenation( "3_1",
          info.linesportions[1][1]{ [ 2
                  .. Length( info.linesportions[1][1] ) ] } );
      info2.linesportions[1][1]:= Concatenation( "3_2",
          info2.linesportions[1][1]{ [ 2
                  .. Length( info2.linesportions[1][1] ) ] } );
      info.linesportions[2][1]:= Concatenation( "6_1",
          info.linesportions[2][1]{ [ 2
                  .. Length( info.linesportions[2][1] ) ] } );
      info2.linesportions[2][1]:= Concatenation( "6_2",
          info2.linesportions[2][1]{ [ 2
                  .. Length( info2.linesportions[2][1] ) ] } );
      info.linesportions[3][1]:= Concatenation( "12_1",
          info.linesportions[3][1]{ [ 3
                  .. Length( info.linesportions[3][1] ) ] } );
      info2.linesportions[3][1]:= Concatenation( "12_2",
          info2.linesportions[3][1]{ [ 3
                  .. Length( info2.linesportions[3][1] ) ] } );

      Append( info.linesportions, info2.linesportions );
      Append( info.widths, info2.widths );
      info.divisors:= ShallowCopy( info.divisors );
      Append( info.divisors, info2.divisors );

      # Bind components for the second call of `DecMatAppendMatrices'.
      info.mtbl2:= info2.mtbl;
      info.offset:= offset;
      info.decmatspos2:= info2.decmatspos;
      info.ordlabels2:= info2.ordlabels;
      info.modlabels2:= info2.modlabels;

    elif simple = "U4(3)" and p in [ 5, 7 ] then

      # Compute the offset of block numbers for the second table.
      # (for `DecMatAppendMatrices')
      offset:= Sum( List( info.linesportions{ [ 4 .. 6 ] }, Length ) );

      # Adjust `divisors' and `linesportions' components
      # (for `DecMatInfoString')
      info.linesportions[4][1]:= Concatenation( "3_1",
          info.linesportions[4][1]{ [ 2 ..
               Length( info.linesportions[4][1] ) ] } );
      info.linesportions[5][1]:= Concatenation( "6_1",
          info.linesportions[5][1]{ [ 2 ..
               Length( info.linesportions[5][1] ) ] } );
      info.linesportions[6][1]:= Concatenation( "12_1",
          info.linesportions[6][1]{ [ 3 ..
               Length( info.linesportions[6][1] ) ] } );
      info2.linesportions[4][1]:= Concatenation( "3_2",
          info2.linesportions[4][1]{ [ 2 ..
               Length( info2.linesportions[4][1] ) ] } );
      info2.linesportions[5][1]:= Concatenation( "6_2",
          info2.linesportions[5][1]{ [ 2 ..
               Length( info2.linesportions[5][1] ) ] } );
      info2.linesportions[6][1]:= Concatenation( "12_2",
          info2.linesportions[6][1]{ [ 3 ..
               Length( info2.linesportions[6][1] ) ] } );
      Append( info.linesportions, info2.linesportions{ [ 4 .. 6 ] } );
      Append( info.widths, info2.widths{ [ Sum( info2.linesportions{[1..3]},
                                             Length )+1
               .. Sum( info2.linesportions{ [ 1 .. 6 ] }, Length ) ] } );
      info.divisors:= ShallowCopy( info.divisors );
      Append( info.divisors, [ 3, 6, 12 ] );

      for k in [ 4 .. 6 ] do
        for i in [ 1 .. Length( info2.linesportions[k] ) ] do
          line:= info2.linesportions[k][i];
          pos:= Position( line, '&' ) + 2;
          pos2:= Position( line, '&', pos ) - 2;
          substr:= line{ [ pos .. pos2 ] };
          no:= Int( substr );
          if no = fail then
            pos3:= Position( substr, '=' );
            no:= Int( substr{ [ 1 .. pos3-2 ] } );
            newline:= Concatenation( line{ [ 1 .. pos-1 ] },
                String( no + offset ), " = " );
            substr:= substr{ [ pos3+2 ..Length( substr ) ] };
            if Length( substr ) >= 10
               and substr{ [ 1 .. 10 ] } = "\\overline{" then
              # case " & n = \overline{m} & ..." where
              # substr = "\overline{m}"
              pos3:= Position( substr, '}' );
              no:= Int( substr{ [ 11 .. pos3-1 ] } );
              Append( newline, "\\overline{" );
              Append( newline, String( no + offset ) );
              Append( newline, substr{ [ pos3 .. Length( substr ) ] } );
              Append( newline, line{ [ pos2+1 .. Length( line ) ] } );
            else
              # case " & n = m\ast k & ..." where
              # substr = "m\ast k"
              pos3:= Position( substr, '\\' );
              no:= Int( substr{ [ 1 .. pos3-1 ] } );
              Append( newline, String( no + offset ) );
              Append( newline, substr{ [ pos3 .. Length( substr ) ] } );
              Append( newline, line{ [ pos2+1 .. Length( line ) ] } );
            fi;
            info2.linesportions[k][i]:= newline;
          else
            info2.linesportions[k][i]:= Concatenation( line{ [ 1 .. pos-1 ] },
                String( no + offset ), line{ [ pos2+1 .. Length( line ) ] } );
          fi;
        od;
      od;

      # Bind components for the second call of `DecMatAppendMatrices'.
      info.mtbl2:= info2.mtbl;
      info.offset:= offset;
      offset:= Sum( List( info.linesportions{ [ 1 .. 3 ] }, Length ) );
      info.decmatspos2:= Filtered( info2.decmatspos,
                             i -> ( IsInt( i ) and i > offset )
                                or ( IsList( i ) and i[1] > offset ) );
      info.ordlabels2:= info2.ordlabels;
      info.modlabels2:= info2.modlabels;

    elif simple = "L3(4)" and p = 2 then

      offset:= 0;  # second half belongs to different groups
                   # but same blocks ...

      info.linesportions[1][1]:= Concatenation( "4_1",
          info.linesportions[1][1]{ [ 2
                 .. Length( info.linesportions[1][1] ) ] } );
      info2.linesportions[1][1]:= Concatenation( "4_2",
          info2.linesportions[1][1]{ [ 2
                 .. Length( info2.linesportions[1][1] ) ] } );
      info.linesportions[2][1]:= Concatenation( "12_1",
          info.linesportions[2][1]{ [ 3
                 .. Length( info.linesportions[2][1] ) ] } );
      info2.linesportions[2][1]:= Concatenation( "12_2",
          info2.linesportions[2][1]{ [ 3
                 .. Length( info2.linesportions[2][1] ) ] } );

      Append( info.linesportions, info2.linesportions );
      Append( info.widths, info2.widths );
      info.divisors:= ShallowCopy( info.divisors );
      Append( info.divisors, info2.divisors );

      # Bind components for the second call of `DecMatAppendMatrices'.
      info.mtbl2:= info2.mtbl;
      info.offset:= offset;
      info.decmatspos2:= info2.decmatspos;
      info.ordlabels2:= info2.ordlabels;
      info.modlabels2:= info2.modlabels;

    elif simple = "L3(4)" and p = 3 then

      # Compute the offset of block numbers for the second table.
      # (for `DecMatAppendMatrices')
      offset:= Length( info.linesportions[3] );

      # Adjust `divisors' and `linesportions' components
      # (for `DecMatInfoString')
      info.linesportions[3][1]:= Concatenation( "12_1",
          info.linesportions[3][1]{ [ 3
                .. Length( info.linesportions[3][1] ) ] } );
      info2.linesportions[3][1]:= Concatenation( "12_2",
          info2.linesportions[3][1]{ [ 3
                 .. Length( info2.linesportions[3][1] ) ] } );
      Add( info.linesportions, info2.linesportions[3] );
      Append( info.widths, info2.widths{ [ 1
                   .. Length( info2.linesportions[3] ) ]
                   + Length( info2.linesportions[1] )
                   + Length( info2.linesportions[2] ) } );
      info.divisors:= ShallowCopy( info.divisors );
      Add( info.divisors, 12 );

      for i in [ 1 .. Length( info2.linesportions[3] ) ] do
        line:= info2.linesportions[3][i];
        pos:= Position( line, '&' ) + 2;
        pos2:= Position( line, '&', pos ) - 2;
        substr:= line{ [ pos .. pos2 ] };
        no:= Int( substr );
        if no = fail then
          pos3:= Position( substr, '=' );
          no:= Int( substr{ [ 1 .. pos3-2 ] } );
          newline:= Concatenation( line{ [ 1 .. pos-1 ] },
              String( no + offset ), " = " );
          substr:= substr{ [ pos3+2 ..Length( substr ) ] };
          pos3:= Position( substr, '\\' );
          no:= Int( substr{ [ 1 .. pos3-1 ] } );
          Append( newline, String( no + offset ) );
          Append( newline, substr{ [ pos3 .. Length( substr ) ] } );
          Append( newline, line{ [ pos2+1 .. Length( line ) ] } );
          info2.linesportions[3][i]:= newline;
        else
          info2.linesportions[3][i]:= Concatenation( line{ [ 1 .. pos-1 ] },
              String( no + offset ), line{ [ pos2+1 .. Length( line ) ] } );
        fi;
      od;

      # Bind components for the second call of `DecMatAppendMatrices'.
      info.mtbl2:= info2.mtbl;
      info.offset:= offset;
      info.decmatspos2:= Difference( info2.decmatspos,
                             [ 1 .. Length( info2.linesportions[1] )
                                  + Length( info2.linesportions[2] ) ] );
      info.ordlabels2:= info2.ordlabels;
      info.modlabels2:= info2.modlabels;

    elif simple = "L3(4)" and p in [ 5, 7 ] then

      # make four parts, as follows
      # 1. G, 2.G, 4_1.G
      # 2. 4_2.G
      # 3. 3.G, 6.G, 12_1.G
      # 4. 12_2.G

      # Adjust `divisors' and `linesportions' components
      # (for `DecMatInfoString')
      info.linesportions[3][1]:= Concatenation( "4_1",
          info.linesportions[3][1]{ [ 2 ..
               Length( info.linesportions[3][1] ) ] } );
      info.linesportions[6][1]:= Concatenation( "12_1",
          info.linesportions[6][1]{ [ 3 ..
               Length( info.linesportions[6][1] ) ] } );
      info2.linesportions[3][1]:= Concatenation( "4_2",
          info2.linesportions[3][1]{ [ 2 ..
               Length( info2.linesportions[3][1] ) ] } );
      info2.linesportions[6][1]:= Concatenation( "12_2",
          info2.linesportions[6][1]{ [ 3 ..
               Length( info2.linesportions[6][1] ) ] } );

      info.widths:= Concatenation(
         info.widths{ [ 1 .. Sum( info.linesportions{[1..3]}, Length ) ] },
         info2.widths{ [ Sum( info2.linesportions{[1..2]}, Length )+1 ..
                         Sum( info2.linesportions{[1..3]}, Length ) ] },
         info.widths{ [ Sum( info.linesportions{[1..3]}, Length )+1 ..
                        Sum( info.linesportions{[1..6]}, Length ) ] },
         info2.widths{ [ Sum( info2.linesportions{[1..5]}, Length )+1 ..
                         Sum( info2.linesportions{[1..6]}, Length ) ] } );

      info.divisors:= [ 1, 2, 4, 4, 3, 6, 12, 12 ];

      # correct 4_2.G part
      offset:= Sum( List( info.linesportions{ [ 3 ] }, Length ) );

      for k in [ 3 ] do
        for i in [ 1 .. Length( info2.linesportions[k] ) ] do
          line:= info2.linesportions[k][i];
          pos:= Position( line, '&' ) + 2;
          pos2:= Position( line, '&', pos ) - 2;
          substr:= line{ [ pos .. pos2 ] };
          no:= Int( substr );
          if no = fail then
            pos3:= Position( substr, '=' );
            no:= Int( substr{ [ 1 .. pos3-2 ] } );
            newline:= Concatenation( line{ [ 1 .. pos-1 ] },
                String( no + offset ), " = " );
            substr:= substr{ [ pos3+2 ..Length( substr ) ] };
            if Length( substr ) >= 10
               and substr{ [ 1 .. 10 ] } = "\\overline{" then
              # case " & n = \overline{m} & ..." where
              # substr = "\overline{m}"
              pos3:= Position( substr, '}' );
              no:= Int( substr{ [ 11 .. pos3-1 ] } );
              Append( newline, "\\overline{" );
              Append( newline, String( no + offset ) );
              Append( newline, substr{ [ pos3 .. Length( substr ) ] } );
              Append( newline, line{ [ pos2+1 .. Length( line ) ] } );
            else
              # case " & n = m\ast k & ..." where
              # substr = "m\ast k"
              pos3:= Position( substr, '\\' );
              no:= Int( substr{ [ 1 .. pos3-1 ] } );
              Append( newline, String( no + offset ) );
              Append( newline, substr{ [ pos3 .. Length( substr ) ] } );
              Append( newline, line{ [ pos2+1 .. Length( line ) ] } );
            fi;
            info2.linesportions[k][i]:= newline;
          else
            info2.linesportions[k][i]:= Concatenation( line{ [ 1 .. pos-1 ] },
                String( no + offset ), line{ [ pos2+1 .. Length( line ) ] } );
          fi;
        od;
      od;

      # correct 3.G, 6.G, 12_1.G
      offset2:= Sum( List( info2.linesportions{ [ 3 ] }, Length ) );

      for k in [ 4 .. 6 ] do
        for i in [ 1 .. Length( info.linesportions[k] ) ] do
          line:= info.linesportions[k][i];
          pos:= Position( line, '&' ) + 2;
          pos2:= Position( line, '&', pos ) - 2;
          substr:= line{ [ pos .. pos2 ] };
          no:= Int( substr );
          if no = fail then
            pos3:= Position( substr, '=' );
            no:= Int( substr{ [ 1 .. pos3-2 ] } );
            newline:= Concatenation( line{ [ 1 .. pos-1 ] },
                String( no + offset2 ), " = " );
            substr:= substr{ [ pos3+2 ..Length( substr ) ] };
            if Length( substr ) >= 10
               and substr{ [ 1 .. 10 ] } = "\\overline{" then
              # case " & n = \overline{m} & ..." where
              # substr = "\overline{m}"
              pos3:= Position( substr, '}' );
              no:= Int( substr{ [ 11 .. pos3-1 ] } );
              Append( newline, "\\overline{" );
              Append( newline, String( no + offset2 ) );
              Append( newline, substr{ [ pos3 .. Length( substr ) ] } );
              Append( newline, line{ [ pos2+1 .. Length( line ) ] } );
            else
              # case " & n = m\ast k & ..." where
              # substr = "m\ast k"
              pos3:= Position( substr, '\\' );
              no:= Int( substr{ [ 1 .. pos3-1 ] } );
              Append( newline, String( no + offset2 ) );
              Append( newline, substr{ [ pos3 .. Length( substr ) ] } );
              Append( newline, line{ [ pos2+1 .. Length( line ) ] } );
            fi;
            info.linesportions[k][i]:= newline;
          else
            info.linesportions[k][i]:= Concatenation( line{ [ 1 .. pos-1 ] },
                String( no + offset2 ), line{ [ pos2+1 .. Length( line ) ] } );
          fi;
        od;
      od;

      # correct 12_2.G
      offset3:= Sum( List( info.linesportions{ [ 3, 6 ] }, Length ) );

      for k in [ 6 ] do
        for i in [ 1 .. Length( info2.linesportions[k] ) ] do
          line:= info2.linesportions[k][i];
          pos:= Position( line, '&' ) + 2;
          pos2:= Position( line, '&', pos ) - 2;
          substr:= line{ [ pos .. pos2 ] };
          no:= Int( substr );
          if no = fail then
            pos3:= Position( substr, '=' );
            no:= Int( substr{ [ 1 .. pos3-2 ] } );
            newline:= Concatenation( line{ [ 1 .. pos-1 ] },
                String( no + offset3 ), " = " );
            substr:= substr{ [ pos3+2 ..Length( substr ) ] };
            if Length( substr ) >= 10 and
               substr{ [ 1 .. 10 ] } = "\\overline{" then
              # case " & n = \overline{m} & ..." where
              # substr = "\overline{m}"
              pos3:= Position( substr, '}' );
              no:= Int( substr{ [ 11 .. pos3-1 ] } );
              Append( newline, "\\overline{" );
              Append( newline, String( no + offset3 ) );
              Append( newline, substr{ [ pos3 .. Length( substr ) ] } );
              Append( newline, line{ [ pos2+1 .. Length( line ) ] } );
            else
              # case " & n = m\ast k & ..." where
              # substr = "m\ast k"
              pos3:= Position( substr, '\\' );
              no:= Int( substr{ [ 1 .. pos3-1 ] } );
              Append( newline, String( no + offset3 ) );
              Append( newline, substr{ [ pos3 .. Length( substr ) ] } );
              Append( newline, line{ [ pos2+1 .. Length( line ) ] } );
            fi;
            info2.linesportions[k][i]:= newline;
          else
            info2.linesportions[k][i]:= Concatenation( line{ [ 1 .. pos-1 ] },
                String( no + offset3 ), line{ [ pos2+1 .. Length( line ) ] } );
          fi;
        od;
      od;

      # Bind components for the second, third,
      # fourth call of `DecMatAppendMatrices'.
      info.mtbl2:= info2.mtbl;
      info.mtbl3:= info.mtbl;
      info.mtbl4:= info2.mtbl;
      info.offset:= offset;
      info.offset3:= offset2;
      info.offset4:= offset3;

      offset:= Sum( List( info.linesportions{ [ 1 .. 2 ] }, Length ) );
      offset2:= Sum( List( info2.linesportions{ [ 1 .. 3 ] }, Length ) );
      info.decmatspos2:= Filtered( info2.decmatspos,
          i -> ( IsInt( i ) and i > offset and i <= offset2 )
                 or ( IsList( i ) and i[1] > offset and i[1] <= offset2 ) );
      offset:= Sum( List( info.linesportions{ [ 1 .. 3 ] }, Length ) );
      info.decmatspos3:= Filtered( info.decmatspos,
                             i -> ( IsInt( i ) and i > offset )
                                or ( IsList( i ) and i[1] > offset ) );
      offset:= Sum( List( info2.linesportions{ [ 1 .. 5 ] }, Length ) );
      info.decmatspos4:= Filtered( info2.decmatspos,
                             i -> ( IsInt( i ) and i > offset )
                                or ( IsList( i ) and i[1] > offset ) );
      offset:= Sum( List( info.linesportions{ [ 1 .. 3 ] }, Length ) );
      info.decmatspos:= Filtered( info.decmatspos,
                             i -> ( IsInt( i ) and i <= offset )
                                or ( IsList( i ) and i[1] <= offset ) );

      info.linesportions:= Concatenation( info.linesportions{ [ 1 .. 3 ] },
                                          info2.linesportions{ [ 3 ] },
                                          info.linesportions{ [ 4 .. 6 ] },
                                          info2.linesportions{ [ 6 ] } );

      info.ordlabels2:= info2.ordlabels;
      info.ordlabels3:= info.ordlabels;
      info.ordlabels4:= info2.ordlabels;
      info.modlabels2:= info2.modlabels;
      info.modlabels3:= info.modlabels;
      info.modlabels4:= info2.modlabels;

    fi;
end );


##############################################################################
##
#F  DecMatMakePage( <entry>, <p>, <dirname> )
##
InstallGlobalFunction( DecMatMakePage, function( entry, p, dirname )
    local str, info, info2, filename, output;

    # Start with the heading.
    str:= DecMatHeadingString( DecMatName( entry[1], "LaTeX" ), p );

    # Append the info block.
    info:= DecMatLinesPortions( entry, p );
    if info = fail then
      Print( "#E  ", entry[1], ": no ", p, "-modular table\n" );
      return false;
    fi;

    # special cases L3(4) and U4(3)
    if     Length( entry[1] ) >= 5
       and entry[1]{ [ 1 .. 5 ] } in [ "L3(4)", "U4(3)" ] then
      DecMatTreatSpecialCases( entry[1]{ [ 1 .. 5 ] }, entry, p, info );
    fi;

    info2:= DecMatInfoString( info.linesportions, info.widths, info.divisors );

    Append( str, info2 );

    # Append the nontrivial decomposition matrices.
    DecMatAppendMatrices( str, info.decmatspos, info.mtbl,
                          info.ordlabels, info.modlabels, 0 );

    # special cases L3(4) and U4(3) again
    if IsBound( info.mtbl2 ) then
      DecMatAppendMatrices( str, info.decmatspos2, info.mtbl2,
                            info.ordlabels2, info.modlabels2, info.offset );
    fi;
    if IsBound( info.mtbl3 ) then
      DecMatAppendMatrices( str, info.decmatspos3, info.mtbl3,
                            info.ordlabels3, info.modlabels3, info.offset3 );
      DecMatAppendMatrices( str, info.decmatspos4, info.mtbl4,
                            info.ordlabels4, info.modlabels4, info.offset4 );
    fi;

    # Append the end of the file.
    Append( str, "\n\\end{document}\n" );

    # Print the string to a file.
    filename:= Concatenation( entry[1], "mod", String( p ) );
    Exec( Concatenation( "if test ! -d \"", dirname,
                         "\";  then mkdir \"", dirname, "\";  fi" ) );
    FileString( Concatenation( dirname, "current.tex" ), str );
    Exec( Concatenation( "date >> \"", dirname, "current.tex\"" ) );

    # Run `pdflatex'
    Exec( Concatenation( "cd \"", dirname, "\"; pdflatex current" ) );
    Exec( Concatenation( "echo \"", filename, "\" >> erfull.log" ) );
    Exec( Concatenation( "grep erfull \"", dirname,
          "current.log\" >> erfull.log" ) );
    Exec( Concatenation( "cd \"", dirname, "\"; mv current.pdf \"",
                         filename, ".pdf\"" ) );

    # Remove intermediate files.
    Exec( Concatenation( "cd \"", dirname, "\"; ",
                         "rm -rf current.aux current.log current.tex" ) );

    return true;
end );


##############################################################################
##
#F  DecMatMakeGroup( <name> )
#F  DecMatMakeGroup( <entrylist> )
##
InstallGlobalFunction( DecMatMakeGroup, function( entrylist )
    local dirname, groupdirname, entry, p, issymm, primes, str, output, table,
          row, found, filename;

    # The directory is named after the simple group.
    dirname:= DirectoriesPackageLibrary( "ctbllib", "dec" );
    dirname:= Filename( dirname, "tex" );
    groupdirname:= Concatenation( dirname, "/", entrylist[1][1] );
    dirname:= Concatenation( groupdirname, "/" );

    # Create the files for all upward extensions and all primes.
    for entry in entrylist do
      for p in Set( Factors( entry[2] ) ) do
        if DecMatMakePage( entry, p, dirname ) then
          Print( "#I  ", entry[1], " mod ", p, " done\n" );
        fi;
      od;
    od;

    # Add alternative format for symmetric groups
    # (full decomposition matrix, labelled by partitions)
    issymm:= ( entrylist[1][1][1] = 'A' or entrylist[1][1][1] = 'a' )
       and Int(entrylist[1][1]{ [ 2..Length( entrylist[1][1] ) ] }) <> fail;

    if issymm then
      for p in Set( Factors( entrylist[2][2] ) ) do
        DecMatMakeSym( entrylist[2][1], p, dirname );
      od;
    fi;

    # Create the HTML index file.
    if IsExistingFile( groupdirname ) then

      str:= HTMLHeader( "Decomposition Matrices",
                        "../../decmats.css",
                        "Decomposition Matrices",
                        DecMatName( entrylist[1][1], "HTML" ) );
      primes:= [];
      for p in Set( Factors( entrylist[1][2] ) ) do
        if ForAny( entrylist, entry -> 
                     IsExistingFile( Concatenation( dirname, entry[1],
                                       "mod", String( p ), ".pdf" ) ) ) then
          Add( primes, p );
        else
          Print( "#E  files for ", entrylist[1][1], "mod", String( p ),
                 " missing\n" );
        fi;
      od;

      if not IsEmpty( primes ) then
        # first line: available primes
        table:= [ Concatenation( [ "G" ],
                      List( primes,
                            p -> Concatenation( "p = ", String( p ) ) ) ) ];
        for entry in entrylist do
          # show available PDF files
#T add also HTML files??
          row:= [ DecMatName( entry[1], "HTML" ) ];
          found:= false;
          for p in primes do
            filename:= Concatenation( dirname, entry[1], "mod", String( p ),
                                      ".pdf" );
            if IsExistingFile( filename ) then
              Add( row, Concatenation(
                "<a href=\"", String( entry[1] ), "mod", String( p ), ".pdf",
                "\">", DecMatName( entry[1], "HTML" ), "mod", String( p ),
                ".pdf", "</a>" ) );
              found:= true;
            else
              Print( "#I  missing link for ", entry[1], " mod ", p, "\n" );
              Add( row, "" );
            fi;
          od;
          if found then
            Add( table, row );
          fi;
        od;
        if issymm then
          entry:= entrylist[2];
          row:= [ DecMatName( entry[1], "HTML" ) ];
          found:= false;
          for p in primes do
            filename:= Concatenation( dirname, entry[1], "partmod",
                                      String( p ), ".pdf" );
            if IsExistingFile( filename ) then
              Add( row, Concatenation(
                "<a href=\"", String( entry[1] ), "partmod", String( p ),
                ".pdf",
                "\">", DecMatName( entry[1], "HTML" ), "partmod", String( p ),
                ".pdf", "</a>" ) );
              found:= true;
            else
              Add( row, "" );
              Print( "#I  missing link for ", entry[1], " mod ", p, "\n" );
            fi;
          od;
          if found then
            Add( table, row );
          fi;
        fi;
        Append( str, HTMLStandardTable( fail, table, "datatable",
                         List( table[1], x -> "pleft" ) ) );
      fi;

      Append( str, HTMLFooter() );
      PrintToIfChanged( Concatenation( entrylist[1][1], "/index.html" ), str );
    fi;
end );


##############################################################################
##
#F  DecMatMakeAll( )
#F  DecMatMakeAll( <names> )
#F  DecMatMakeAll( <names>, <from> )
##
InstallGlobalFunction( DecMatMakeAll, function( arg )
    local names, pos, i, entry;

    if Length( arg ) = 2 then
      names:= arg[1];
      pos:= arg[2];
    elif Length( arg ) = 1 then
      names:= arg[1];
      pos:= 1;
    else
      names:= DecMatNames();
      pos:= 1;
    fi;

    for i in [ pos .. Length( names ) ] do
      entry:= names[i];
      Print( "#I  ", Ordinal( i ), " group: ", entry[1], "\n" );
      DecMatMakeGroup( entry );
      Print( "\n" );
    od;
end );


##############################################################################
##
#F  DecMatHTMLTableString( <names> )
##
InstallGlobalFunction( DecMatHTMLTableString, function( names )
    local n, k, rowportions;

    names:= Filtered( List( names, x -> x[1][1] ),
                x -> IsExistingFile( Concatenation( "tex/", x ) ) );

    # Sort the names in such a way that names differing by number substrings
    # are ordered according to the numbers;
    # e.g., `A5' shall precede `A10'.
    Sort( names, BrowseData.CompareAsNumbersAndNonnumbers );

    n:= Length( names );
    Print( "#I  There are ", n, " groups in the database\n" );

    k:= Int( n / 10 );
    rowportions:= List( [ 1 .. k ], x -> [ 1 .. 10 ] + (x-1)*10 );
    if k*10 < n then
      Add( rowportions, [ k*10+1 .. n ] );
    fi;

    return HTMLStandardTable( fail, List( rowportions,
               r -> List( r, i -> Concatenation( "<a href=\"tex/",
                                    String( names[i] ), "\">",
                                    DecMatName( names[i], "HTML" ),
                                    "</a>" ) ) ),
            "datatable",
            List( rowportions[1], i -> "pleft" ) );
end );


#############################################################################
##
#F  DecMatLaTeXStringDecompositionMatrix( <modtbl>[, <blocknr>][, <options>] )
##
InstallGlobalFunction( DecMatLaTeXStringDecompositionMatrix, function( arg )
    local modtbl,        # Brauer character table, first argument
          blocknr,       # number of the block, optional second argument
          options,       # record with labels, optional third argument
          decmat,        # decomposition matrix
          block,         # block information on 'modtbl'
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
          val,           # one value in the matrix
          fblock, vals, first, second, third, firstcol, secondcol;

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

#T start new
    elif Length( arg ) = 4 and IsBrauerTable( arg[1] )
                           and IsInt( arg[2] )
                           and IsRecord( arg[3] )
                           and IsList( arg[4] ) then

      blocknr := arg[2];
      options := arg[3];
      fblock  := arg[4];
#T end new

    elif not( Length( arg ) = 1 and IsBrauerTable( arg[1] ) ) then
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

#T start new
if IsBound( fblock ) then
vals:= Difference( fblock, [ 0 ] );
if Length( vals ) <> 2 then
  Error( "what?" );
fi;
first:= Filtered( [ 1 .. Length( decmat ) ], i -> fblock[i] = vals[1] );
second:= Filtered( [ 1 .. Length( decmat ) ], i -> fblock[i] = vals[2] );
third:= Filtered( [ 1 .. Length( decmat ) ], i -> fblock[i] = 0 );
fi;
#T end new

    # Choose default labels if necessary.
    rowportions:= [ [ 1 .. Length( decmat ) ] ];
    colportions:= [ [ 1 .. Length( decmat[1] ) ] ];

    phi:= "{\\tt Y}";
    chi:= "{\\tt X}";

    hlines:= [];
    ulc:= "";

    if IsBound( options ) then

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

    fi;

#T start old
    Add( hlines, Length( decmat ) );
#T end old
#T start new
if IsBound( fblock ) then
    hlines:= [ second[ Length( second ) ], third[ Length( third ) ] ];
fi;
#T end new

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

#T start new
if IsBound( fblock ) then
firstcol:= Filtered( [ 1 .. Length( decmat[1] ) ],
                     i -> ForAll( decmat{ second }, row -> row[i] = 0 ) );
secondcol:= Filtered( [ 1 .. Length( decmat[1] ) ],
                      i -> ForAll( decmat{ first }, row -> row[i] = 0 ) );
if Union( firstcol, secondcol ) <> [ 1 .. Length( decmat[1] ) ] then
  Error( "fishy ..." );
fi;
if Length( rowportions ) > 1 or Length( colportions ) > 1 then
  Error( "formatting problem ..." );
fi;
fi;
#T end new

    # Construct the string.
    str:= "";

    for r in rowportions do

      for k in colportions do

        # Append the header of the array.
        Append( str,  "\\[\n" );
        Append( str,  "\\begin{array}{r|" );
#T start old
#T        for i in k do
#T          Add( str, 'r' );
#T        od;
#T end old
#T start new
if IsBound( fblock ) then
        for i in firstcol do
          Add( str, 'r' );
        od;
        Add( str, 'c' );
        for i in secondcol do
          Add( str, 'r' );
        od;
else
        for i in k do
          Add( str, 'r' );
        od;
fi;
#T end new
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
#T start old
#T        for i in collabels{ k } do
#T end old
#T start new
if IsBound( fblock ) then
        for i in collabels{ firstcol } do
          Append( str, " & " );
          Append( str, String( i ) );
          Append( str, "\n" );
        od;
        Append( str, " & " );
        for i in collabels{ secondcol } do
#T end new
          Append( str, " & " );
          Append( str, String( i ) );
          Append( str, "\n" );
        od;
else
        for i in collabels{ k } do
          Append( str, " & " );
          Append( str, String( i ) );
          Append( str, "\n" );
        od;
fi;
        Append( str, " \\rule[-7pt]{0pt}{20pt} \\\\ \\hline\n" );

        # Append the matrix itself.
#T start old
#T        for i in r do
#T end old
#T start new
        for i in first do
#T end new

          # The first column contains the numbers of ordinary irreducibles.
          Append( str, String( rowlabels[i] ) );

#T start old
#T          for val in decmat[i]{ k } do
#T end old
          for val in decmat[i]{ firstcol } do
            Append( str, " & " );
            if val = 0 then
              Append( str, "." );
            else
              Append( str, String( val ) );
            fi;
          od;
          Append( str, " & \\vline " );
          for val in decmat[i]{ secondcol } do
            Append( str, " & " );
            if val = 0 then
              Append( str, "." );
            else
Error( "nonzero?" );
              Append( str, String( val ) );
            fi;
          od;

#T start old
#T          if i = r[1] or i-1 in hlines then
#T            Append( str, " \\rule[0pt]{0pt}{13pt}" );
#T          fi;
#T          if i = r[ Length( r ) ] or i in hlines then
#T            Append( str, " \\rule[-7pt]{0pt}{5pt}" );
#T          fi;
#T start old
#T start new
          if i in hlines then
            Append( str, " \\rule[-7pt]{0pt}{5pt}" );
          fi;
#T end new

          Append( str, " \\\\\n" );

          if i in hlines then
            Append( str, "\\hline\n" );
          fi;

        od;
#T start new
        Append( str, "\\cline{2-" );
        Append( str, String( Length( decmat[1] )+2 ) );
        Append( str, "}\n" );
        for i in second do

          # The first column contains the numbers of ordinary irreducibles.
          Append( str, String( rowlabels[i] ) );

          for val in decmat[i]{ firstcol } do
            Append( str, " & " );
            if val = 0 then
              Append( str, "." );
            else
Error( "nonzero??" );
              Append( str, String( val ) );
            fi;
          od;
          Append( str, " & \\vline " );
          for val in decmat[i]{ secondcol } do
            Append( str, " & " );
            if val = 0 then
              Append( str, "." );
            else
              Append( str, String( val ) );
            fi;
          od;

          if i-1 in hlines then
            Append( str, " \\rule[0pt]{0pt}{13pt}" );
          fi;
          if i in hlines then
            Append( str, " \\rule[-7pt]{0pt}{5pt}" );
          fi;
          if i = second[ Length( second ) ] then
            Append( str, " \\rule[-7pt]{0pt}{5pt}" );
          fi;

          Append( str, " \\\\\n" );

          if i in hlines then
            Append( str, "\\hline\n" );
          fi;

        od;
        for i in third do

          # The first column contains the numbers of ordinary irreducibles.
          Append( str, String( rowlabels[i] ) );

          for val in decmat[i]{ firstcol } do
            Append( str, " & " );
            if val = 0 then
              Append( str, "." );
            else
              Append( str, String( val ) );
            fi;
          od;
          Append( str, " & " );
          for val in decmat[i]{ secondcol } do
            Append( str, " & " );
            if val = 0 then
              Append( str, "." );
            else
              Append( str, String( val ) );
            fi;
          od;

#T start new
if IsBound( third ) then
          if i = third[1] then
            Append( str, " \\rule[0pt]{0pt}{13pt}\n" );
          fi;
fi;
#T end new
          if i-1 in hlines then
            Append( str, " \\rule[0pt]{0pt}{13pt}" );
          fi;
          if i in hlines then
            Append( str, " \\rule[-7pt]{0pt}{5pt}" );
          fi;

          Append( str, " \\\\\n" );

          if i in hlines then
            Append( str, "\\hline\n" );
          fi;

        od;
#T end new

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


##############################################################################
##
#F  DecMatMakeSym( <Sn>, <p>, <dirname> )
##
InstallGlobalFunction( DecMatMakeSym, function( Sn, p, dirname )
    local n, ordtbl, modtbl, dec, charparam, rowlabels, i, j, coll,
          lb, pair, collabels, firstnonzero, perm, str, options,
          filename, output;

    n:= Int( Sn{ [ 2 .. Position( Sn, '.' )-1 ] } );
    if n = fail then
      return false;
    fi;

    # Compute the decomposition matrix.
    ordtbl:= CharacterTable( Concatenation( "S", String( n ) ) );
    if ordtbl = fail then
      Print( "#E  ", Sn, ".2: no ordinary table\n" );
      return false;
    fi;
    modtbl:= CharacterTable( ordtbl, p );
    if modtbl = fail then
      Print( "#E  ", Sn, ".2: no ", p, "-modular table\n" );
      return false;
    fi;

    dec:= ShallowCopy( DecompositionMatrix( modtbl ) );

    # Compute the character parameters.
    charparam:= - List( CharacterParameters( ordtbl ), x -> x[2] );

    # Sort both lists.
    SortParallel( charparam, dec );
    charparam:= - charparam;

    # Transform the partitions to strings.
    rowlabels:= [];
    for i in [ 1 .. Length( charparam ) ] do
      coll:= Collected( charparam[i] );
      lb:= "";
      for pair in coll do
        Append( lb, String( pair[1] ) );
        Append( lb, "^{" );
        Append( lb, String( pair[2] ) );
        Append( lb, "}" );
      od;
      rowlabels[i]:= lb;
    od;

    # Permute the columns in order to make the matrix lower triangular.
    collabels:= List( [ 1 .. Length( dec[1] ) ],
                      i -> Concatenation( "\\varphi_{", String(i), "}" ) );
    firstnonzero:= List( [ 1 .. Length( dec[1] ) ],
                         j -> First( [ 1 .. Length( dec ) ],
                                     i -> dec[i][j] <> 0 ) );
    perm:= Sortex( firstnonzero );
    collabels:= Permuted( collabels, perm );
    dec:= List( dec, x -> Permuted( x, perm ) );

    # Start with the heading.
    str:= DecMatHeadingString( DecMatName( Sn, "LaTeX" ), p );
    Append( str, "\n\\vspace*{10pt}\n" );

    # Put the options together.
    options:= rec( decmat    := dec,
                   rowlabels := rowlabels,
                   collabels := collabels,
                   nrows     := DecMatRowsPerPage,
                   ncols     := DecMatColsPerPage - 1 );

    # Append the decomposition matrix.
    Append( str, LaTeXStringDecompositionMatrix( modtbl, options ) );

    # Append the end of the file.
    Append( str, "\n\\end{document}\n" );

    # Print the string to a file.
    filename:= Concatenation( Sn, "partmod", String( p ) );
    Exec( Concatenation( "if test ! -d \"", dirname,
                         "\";  then mkdir \"", dirname, "\";  fi" ) );
    FileString( Concatenation( dirname, "current.tex" ), str );
    Exec( Concatenation( "date >> \"", dirname, "current.tex\"" ) );

    # Run `pdflatex'
    Exec( Concatenation( "cd \"", dirname, "\"; pdflatex current" ) );
    Exec( Concatenation( "echo \"", filename, "\" >> erfull.log" ) );
    Exec( Concatenation( "grep erfull \"", dirname,
                         "current.log\" >> erfull.log" ) );
    Exec( Concatenation( "cd \"", dirname, "\"; mv current.pdf \"",
                         filename, ".pdf\"" ) );

    # Remove intermediate files.
    Exec( Concatenation( "cd \"", dirname, "\"; ",
                         "rm -rf current.aux current.log current.tex" ) );

    return true;
end );


##############################################################################
##
#E

