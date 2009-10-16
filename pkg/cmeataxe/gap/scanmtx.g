#############################################################################
##
#W  scanmtx.g      share packages 'atlasrep' and 'meataxe'      Thomas Breuer
##
#H  @(#)$Id: scanmtx.g,v 1.1 2000/04/19 09:10:34 gap Exp $
##
#Y  Copyright (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains interface routines for reading and writing {\MeatAxe}
##  text format and straight line programs used in the {\ATLAS} of Group
##  Representations.
##
if IsBound( Revision ) then
  Revision.( "atlasrep/gap/scanmtx_g" ) :=
    "@(#)$Id: scanmtx.g,v 1.1 2000/04/19 09:10:34 gap Exp $";
  Revision.( "meataxe/gap/scanmtx_g" ) :=
    "@(#)$Id: scanmtx.g,v 1.1 2000/04/19 09:10:34 gap Exp $";
fi;


#############################################################################
##
#V  InfoCMeatAxe
##
##  If the info level of `InfoCMeatAxe' is at least $1$ then information
##  about `fail' results of C-{\MeatAxe} functions is printed.
##  The default level is $0$, no information is printed on this level.
##
DeclareInfoClass( "InfoCMeatAxe" );


#############################################################################
##
#F  FFList( <F> )
#V  FFLists
##
##  `FFList' is a utility program for the conversion of vectors and matrices
##  from {\MeatAxe} format to {\GAP} format and vice versa.
##  It is used by `ScanMeatAxeFile' (see~"ScanMeatAxeFile")
##  and `MeatAxeString' (see~"MeatAxeString").
##
##  For a finite field <F>, `FFList' returns a list <l>
##  giving the correspondence between the {\MeatAxe} numbering and the {\GAP}
##  numbering of the elements in <F>.
##
##  The element of <F> corresponding to {\MeatAxe} number <n> is
##  `<l>[ <n>+1 ]',
##  and the {\MeatAxe} number of the field element <z> is
##  `Position( <l>, <z> ) - 1'.
##
##  The global variable `FFLists' is used to store the information
##  about <F> once it has been computed.
##
DeclareGlobalFunction( "FFList" );
DeclareGlobalVariable( "FFLists",
    "list of info to translate FFE orderings between GAP and MeatAxe" );

InstallFlushableValue( FFLists, [] );


#############################################################################
##
#f  FFList( <F> )
##
##  (This program was originally written by Meinolf Geck.)
##
InstallGlobalFunction( FFList, function( F )

    local sizeF,
          p,
          dim,
          elms,
          root,
          powers,
          i,
          pow;

    sizeF:= Size( F );

    if not IsBound( FFLists[ sizeF ] ) then

      p:= Characteristic( F );
      dim:= DegreeOverPrimeField( F );
      elms:= List( Cartesian( List( [ 1 .. dim ], i -> [ 0 .. p-1 ] ) ),
                   Reversed );
      root:= PrimitiveRoot( F );
      pow:= One( root );
      powers:= [ pow ];
      for i in [ 2 .. dim ] do
        pow:= pow * root;
        powers[i]:= pow;
      od;
      FFLists[ sizeF ]:= elms * powers;

    fi;

    return FFLists[ sizeF ];
end );


#############################################################################
##
#F  ScanMeatAxeFile( <filename> )
#F  ScanMeatAxeFile( <string>, "string" )
##
##  Let <filename> be the name of a {\GAP} readable file (see~"ref:Filename"
##  in the {\GAP} Reference Manual) that contains a matrix or a permutation
##  or a list of permutations in {\MeatAxe} text format (see the section
##  about the program `zcv' in the {\MeatAxe} manual~\cite{Rin98}).
##  `ScanMeatAxeFile' returns the corresponding {\GAP} matrix
##  or list of permutations, respectively.
#T supports both the ``old'' and the ``new'' text file format!
##
##  In the second form, the first argument <string> must be a string as
##  obtained by reading a file in {\MeatAxe} text format as a text stream
##  (see~"ref:InputTextFile" in the {\GAP} Reference Manual),
##  and the second argument the string `\"string\"'.
##  Also in this case, `ScanMeatAxeFile' returns the corresponding {\GAP}
##  matrix or list of permutations, respectively.
##
DeclareGlobalFunction( "ScanMeatAxeFile" );

InstallGlobalFunction( ScanMeatAxeFile, function( arg )

    local filename,
          file,
          line,
          lline,
          header,
          mode,
          degree,
          result,
          all,
          string,
          pos,
          pos2,
          offset,
          j,
          imgs,
          i,
          F,
          nrows,
          fflist,
          digits,
          ncols,
          one;

    if Length( arg ) = 1 then

      filename:= arg[1];
      file:= InputTextFile( filename );
      if file = fail then
        Error( "cannot create input stream for file <filename>" );
      fi;

      InfoRead1( "#I  reading `", filename, "'\n" );
      line:= ReadLine( file );
      if line = fail then
        CloseStream( file );
        return fail;
      fi;
      all:= ReadAll( file );
      CloseStream( file );
      InfoRead1( "#I  reading `", filename, "' done\n" );

    elif Length( arg ) = 2 and IsString( arg[1] ) and arg[2] = "string" then

      string:= arg[1];
      pos:= Position( string, '\n' );
      if pos = fail then
        return fail;
      fi;
      line:= string{ [ 1 .. pos-1 ] };
      all:= string{ [ pos+1 .. Length( string ) ] };

    else
      Error( "usage: ScanMeatAxeFile( <filename> )" );
    fi;

    # From the first line, determine whether a matrix or a permutation
    # is to be read.
    if '#' in line then
      line:= line{ [ 1 .. Position( line, '#' ) ] };
    fi;
    lline:= List( SplitString( line, "", " \n" ), Int );
    if fail in lline then

      # A header of new type occurs;
      # remove everything before a leading `"'.
      header:= SplitString( line, "", " \n" );
      pos:= First( header, x -> not IsEmpty( x ) and x[1] = '\"' );
      if pos <> fail then
        header:= header{ [ pos .. Length( header ) ] };
      fi;
      if Length( header ) = 2 and header[1] = "permutation" then

        line:= [ 12, 1,, 1 ];
        if 7 < Length( header[2] ) and header[2]{ [ 1 .. 7 ] } = "degree=" then
          degree:= Int( header[2]{ [ 8 .. Length( header[2] ) ] } );
          line[3]:= degree;
        fi;

      elif Length( header ) = 4 and header[1] = "matrix" then

        line:= [ 6 ];
        if 6 < Length( header[2] ) and header[2]{ [ 1 .. 6 ] } = "field=" then
          line[2]:= Int( header[2]{ [ 7 .. Length( header[2] ) ] } );
          if IsInt( line[2] ) and line[2] < 10 then
            line[1]:= 1;
          fi;
        fi;
        if 5 < Length( header[3] ) and header[3]{ [ 1 .. 5 ] } = "rows=" then
          line[3]:= Int( header[3]{ [ 6 .. Length( header[3] ) ] } );
        fi;
        if 5 < Length( header[4] ) and header[4]{ [ 1 .. 5 ] } = "cols=" then
          line[4]:= Int( header[4]{ [ 6 .. Length( header[4] ) ] } );
        fi;

      fi;

      if fail in line or Number( line ) <> 4 then
        Error( "corrupted (new) MeatAxe file header" );
      fi;

    else

      # The header is of old type, consisting of four integers.
      if Length( lline ) = 3 and lline[1] = 12 then

        # We may be dealing with permutations of a degree requiring
        # (at least) six digits, for example the header for a permutation
        # on $100000$ points can be `12     1100000     1'.
        line:= String( lline[2] );
        if line[1] = '1' then
          lline[4]:= lline[3];
          lline[3]:= Int( line{ [ 2 .. Length( line ) ] } );
          lline[2]:= 1;
        fi;

      fi;

      if Length( lline ) <> 4 then
        Error( "corrupted (old) MeatAxe file header" );
      fi;
      line:= lline;

    fi;

    # Remove comment parts.
    while '#' in all do
      pos:= Position( all, '#' );
      pos2:= Position( all, '\n', pos );
      if pos2 = fail then
        pos2:= Length( all ) + 1;
      fi;
      all:= Concatenation( all{ [ 1 .. pos-1 ] },
                           all{ [ pos2 .. Length( all ) ] } );
    od;

    mode:= line[1];
    if mode = 12 then

      # a list of permutations (in free format)
      degree:= line[3];
      result:= [];
      all:= SplitString( all, "", " \n" );
      if Length( all ) <> degree * line[4] then
        Error( "corrupted file" );
      fi;
      offset:= 0;
      for j in [ 1 .. line[4] ] do
        imgs:= [];
        for i in [ 1 .. degree ] do
          imgs[i]:= Int( all[ i + offset ] );
        od;
        Add( result, PermList( imgs ) );
      od;

    elif mode = 1 then

      # a matrix (in fixed format)
      nrows:= line[3];
      ncols:= line[4];
      result:= [];
      pos:= 1;
      fflist:= FFList( GF( line[2] ) );
      digits:= "0123456789";
      for i in [ 1 .. nrows ] do
        result[i]:= [];
        for j in [ 1 .. ncols ] do
          while all[ pos ] in " \n" do
            pos:= pos + 1;
          od;
          result[i][j]:= fflist[ Position( digits, all[ pos ] ) ];
          pos:= pos + 1;
        od;
      od;

    elif mode = 5 then

      # an integer matrix (in free format), to be reduced mod a prime
      nrows:= line[3];
      ncols:= line[4];
      result:= [];
      all:= SplitString( all, "", " \n" );
      if Length( all ) <> nrows * ncols then
        Error( "corrupted file" );
      fi;
      pos:= 0;
      for i in [ 1 .. nrows ] do
        result[i]:= [];
        for j in [ 1 .. ncols ] do
          pos:= pos + 1;
          result[i][j]:= Int( all[ pos ] );
        od;
      od;
      result:= result * One( GF( line[2] ) );

    elif mode in [ 3, 4, 6 ] then

      # a matrix (in free format)
      nrows:= line[3];
      ncols:= line[4];
      result:= [];
      fflist:= FFList( GF( line[2] ) );
      all:= SplitString( all, "", " \n" );
      if Length( all ) <> nrows * ncols then
        Error( "corrupted file" );
      fi;
      pos:= 0;
      for i in [ 1 .. nrows ] do
        result[i]:= [];
        for j in [ 1 .. ncols ] do
          pos:= pos + 1;
          result[i][j]:= fflist[ Int( all[ pos ] ) + 1 ];
        od;
      od;

    elif mode = 2 then

      # a permutation, to be converted to a matrix
      F:= GF( line[2] );
      nrows:= line[3];
      result:= NullMat( nrows, line[4], F );
      all:= SplitString( all, "", " \n" );
      if Length( all ) <> nrows then
        Error( "corrupted file" );
      fi;
      one:= One( F );
      for i in [ 1 .. nrows ] do
        j:= Int( all[i] );
        result[i][j]:= one;
      od;

    else
      Error( "unknown mode" );
    fi;

    return result;
end );


#############################################################################
##
#O  MeatAxeString( <mat>, <q> )
#O  MeatAxeString( <perms>, <degree> )
#O  MeatAxeString( <perm>, <q>, <dims> )
##
##  In the first form, for a matrix <mat> whose entries lie in the finite
##  field with <q> elements, `MeatAxeString' returns a string that encodes
##  <mat> as a matrix over `GF(<q>)', in {\MeatAxe} text format.
##
##  In the second form, for a nonempty list <perms> of permutations that move
##  only points up to the positive integer <degree>,
##  `MeatAxeString' returns a string that encodes <perms> as permutations of
##  degree <degree>, in {\MeatAxe} text format.
##
##  In the third form, for a permutation <perm> with largest moved point $n$,
##  say, a prime power <q>, and a list <dims> of length $2$ containing two
##  positive integers larger than or equal to $n$,
##  `MeatAxeString' returns a string that encodes <perm> as a matrix over
##  `GF(<q>)', of dimensions <dims>, whose first $n$ rows and columns
##  describe the permutation matrix corresponding to <perm>,
##  and the remaining rows and columns are zero.
#T The strings are in *old* format!
##
DeclareOperation( "MeatAxeString", [ IsTable, IsPosInt ] );
DeclareOperation( "MeatAxeString",
    [ IsPermCollection and IsList, IsPosInt ] );
DeclareOperation( "MeatAxeString", [ IsPerm, IsPosInt, IsList ] );


#############################################################################
##
#M  MeatAxeString( <mat>, <q> )
##
InstallMethod( MeatAxeString,
    "for matrix over a finite field, and field order",
    [ IsTable and IsFFECollColl, IsPosInt ],
    function( mat, q )

    local nrows, ncols, mode, str, fflist, values, linelen, nol, row,
          i, j, k;

    # Check that `mat' is rectangular.
    if not IsMatrix( mat ) then
      Error( "<mat> must be a matrix" );
    fi;
    nrows:= Length( mat );
    ncols:= Length( mat[1] );

    # Start with the header line.
    # We try to keep the files as small as possible by using the (old)
    # mode `1' whenever possible.
    if q < 10 then
      mode:= "1";
    else
      mode:= "6";
    fi;
#T can GAP *read* these modes??
    str:= ShallowCopy( mode );          # mode,
    Append( str, " " );
    Append( str, String( q ) );         # field size,
    Append( str, " " );
    Append( str, String( nrows ) );     # number of rows,
    Append( str, " " );
    Append( str, String( ncols ) );     # number of columns
    Append( str, "\n" );

    # Add the matrix entries.
    fflist:= FFList( GF(q) );
    if mode = "1" then

      # Set the parameters for filling lines in the fixed format
      values:= "0123456789";
      linelen:= 80;
      nol:= Int( ncols / linelen );

      for row in mat do
        i:= 1;
        for j in [ 0 .. nol-1 ] do
          for k in [ 1 .. linelen ] do
            Add( str, values[ Position( fflist, row[i] ) ] );
            i:= i + 1;
          od;
          Add( str, '\n' );
        od;
        for i in [ nol * linelen + 1 .. ncols ] do
          Add( str, values[ Position( fflist, row[i] ) ] );
        od;
        Add( str, '\n' );
      od;

    else

      # free format
      if IsInt( mat[1][1] ) then

        for row in mat do
          for i in row do
            Append( str, String( i ) );
            Add( str, '\n' );
          od;
        od;

      else

        values:= List( [ 0 .. q-1 ], String );
        for row in mat do
          for i in row do
            Append( str, values[ Position( fflist, i ) ] );
            Add( str, '\n' );
          od;
        od;

      fi;

    fi;

    # Return the result.
    return str;
    end );


#############################################################################
##
#M  MeatAxeString( <perms>, <degree> )
##
InstallMethod( MeatAxeString,
    "for list of permutations, and degree",
    [ IsPermCollection and IsList, IsPosInt ],
    function( perms, degree )

    local str, perm, i;

    # Start with the header line.
    str:= "12 1 ";
    Append( str, String( degree ) );
    Append( str, " " );
    Append( str, String( Length( perms ) ) );
    Append( str, "\n" );

    # Add the images.
    for perm in perms do
      for i in [ 1 .. degree ] do
        Append( str, String( i ^ perm ) );
        Add( str, '\n' );
      od;
    od;
    Add( str, '\n' );

    # Return the result.
    return str;
    end );


#############################################################################
##
#M  MeatAxeString( <perm>, <q>, <dims> )
##
InstallMethod( MeatAxeString,
    "for permutation, field order, and dimensions",
    [ IsPerm, IsPosInt, IsList ],
    function( perm, q, dims )

    local str, i;

    # Start with the header line.
    # (The mode is `2': a permutation, to be converted to a matrix.)
    str:= "2 ";                         # mode,
    Append( str, String( q ) );         # field size,
    Append( str, " " );
    Append( str, String( dims[1] ) );   # number of rows,
    Append( str, " " );
    Append( str, String( dims[2] ) );   # number of columns
    Append( str, "\n" );

    # Add the images.
    for i in [ 1 .. dims[1] ] do
      Append( str, String( i ^ perm ) );
      Add( str, '\n' );
    od;
    Add( str, '\n' );

    # Return the result.
    return str;
    end );


#############################################################################
##
#F  ScanStraightLineProgram( <filename> )
#F  ScanStraightLineProgram( <string>, "string" )
##
##  Let <filename> be the name of a file that contains a straight line
##  program in the sense that it consists only of lines in the following
##  form.
##  \beginitems
##  \item{}
##  `\# <anything>' &
##      lines starting with a hash sign `\#' are ignored,
##
##  `inp <n>' &
##      means that there are <n> inputs, referred to via the labels
##      `1', `2', $\ldots$, <n>,
##
##  `inp <k> <a1> <a2> ... <ak>' &
##      means that the next <k> inputs are referred to via the labels
##      <a1>, <a2>, ..., <ak>,
##
##  `cjr <a> <b>' &
##      means that <a> is replaced by `<b>^(-1) <a> <b>',
##
##  `cj <a> <b> <c>' &
##      means that <c> is defined as `<b>^(-1) <a> <b>',
##
##  `com <a> <b> <c>' &
##      means that <c> is defined as `<a>^(-1) <b>^(-1) <a> <b>',
##
##  `iv <a> <b>' &
##      means that <b> is defined as `<a>^(-1)',
##
##  `mu <a> <b> <c>' &
##      means that <c> is defined as `<a>*<b>',
##
##  `pwr <a> <b> <c>' &
##      means that <c> is defined to be `<b>^<a>', and
##
##  `cp <a> <b>' &
##      means that <b> is defined as a copy of <a>,
##
##  `oup <l>' &
##      means that there are <l> outputs, stored in the labels `1', `2',
##      $\ldots$, <l>,
##
##  `oup <l> <b1> <b2> ... <bl>' &
##      means that the next <l> outputs are stored in the labels
##      <b1>, <b2>, ... <bl>.
##  \enditems
##
##  Each of the labels <a>, <b>, <c> can be any nonempty sequence of digits
##  and alphabet characters,
##  except that the first argument of `pwr' must denote an integer.
##
##  If the `inp' or `oup' statement is missing then the input or output,
##  respectively, is assumed to be given by the labels `1' and `2'.
##  There can be multiple `inp' lines at the beginning of the program
##  and multiple `oup' lines at the end of the program,
##  but at most one `inp' and at most one `oup' line that does not specify
##  the labels.
##
##  `ScanStraightLineProgram' returns the corresponding {\GAP} straight line
##  program (see~"ref:IsStraightLineProgram" in the {\GAP} Reference Manual).
##
##  In the second form, the first argument <string> must be a string as
##  obtained by reading a file in {\MeatAxe} text format as a text stream
##  (see~"ref:InputTextFile" in the {\GAP} Reference Manual),
##  and the second argument the string `\"string\"'.
##  Also in this case, `ScanStraightLineProgram' returns the corresponding
##  {\GAP} straight line program.
##
DeclareGlobalFunction( "ScanStraightLineProgram" );

InstallGlobalFunction( ScanStraightLineProgram, function( arg )

    local filename,
          data,
          file,
          line,
          labels,
          i,
          lines,
          output,
          a, b, c,
          result;

    # Get and check the input.
    if   Length( arg ) = 1 and IsString( arg[1] ) then
      filename:= arg[1];
    elif Length( arg ) = 2 and IsString( arg[1] ) and arg[2] = "string" then
      data:= List( SplitString( arg[1], "", "\n" ),
                   line -> SplitString( line, "", " " ) );
    else
      Error( "usage: ScanStraightLineProgram( <filename>[, \"string\"] )" );
    fi;

    # Read the data if necessary.
    if not IsBound( data ) then

      file:= InputTextFile( filename );
      if file = fail then
        Error( "cannot create input stream for file <filename>" );
      fi;

      data:= [];
      InfoRead1( "#I  reading `", filename, "'\n" );
      line:= ReadLine( file );
      while line <> fail do
        if not IsEmpty( line ) then
          line:= SplitString( line, "", " \n" );
          if not IsEmpty( line ) then
            Add( data, line );
          fi;
        fi;
        line:= ReadLine( file );
      od;
      CloseStream( file );
      InfoRead1( "#I  reading `", filename, "' done\n" );

    fi;

    # Determine the labels that occur.
    labels:= [];
    if data[1][1] <> "inp" then

      # There is no `inp' line.
      # The default input is given by the labels `1' and `2'.
      labels:=[ "1", "2" ];

    fi;
    for line in data do
      if line[1] = "inp" then
        if Length( line ) = 2 and Int( line[2] ) <> fail then
          Append( labels, List( [ 1 .. Int( line[2] ) ], String ) );
        elif Int( line[2] ) = Length( line ) + 2 then
          Append( labels, line{ [ 3 .. Length( line ) ] } );
        else
          Error( "corrupted line `", line, "'\n" );
        fi;
      elif line[1] = "pwr" then
        for i in [ 3 .. Length( line ) ] do
          if not line[i] in labels then
            Add( labels, line[i] );
          fi;
        od;
      elif line[1][1] <> '#' then
        for i in [ 2 .. Length( line ) ] do
          if not line[i] in labels then
            Add( labels, line[i] );
          fi;
        od;
      fi;
    od;

    # Translate the lines.
    lines:= [];
    output:= [];
    for line in data do
      if line[1] = "oup" then

        Add( output, line );

      elif line[1] <> "inp" and line[1][1] <> '#' then

        if   line[1] = "mu" and Length( line ) = 4 then
          a:= Position( labels, line[2] );
          b:= Position( labels, line[3] );
          c:= Position( labels, line[4] );
          Add( lines, [ [ a, 1, b, 1 ], c ] );
        elif line[1] = "iv" and Length( line ) = 3 then
          a:= Position( labels, line[2] );
          b:= Position( labels, line[3] );
          Add( lines, [ [ a, -1 ], b ] );
        elif line[1] = "pwr" and Length( line ) = 4 then
          a:= Int( line[2] );
          b:= Position( labels, line[3] );
          c:= Position( labels, line[4] );
          Add( lines, [ [ b, a ], c ] );
        elif line[1] = "cjr" and Length( line ) = 3 then
          a:= Position( labels, line[2] );
          b:= Position( labels, line[3] );
          Add( lines, [ [ b, -1, a, 1, b, 1 ], a ] );
        elif line[1] = "cp" and Length( line ) = 3 then
          a:= Position( labels, line[2] );
          b:= Position( labels, line[3] );
          Add( lines, [ [ a, 1 ], b ] );
        elif line[1] = "cj" and Length( line ) = 4 then
          a:= Int( line[2] );
          b:= Position( labels, line[3] );
          c:= Position( labels, line[4] );
          Add( lines, [ [ b, -1, a, 1, b, 1 ], c ] );
        elif line[1] = "com" and Length( line ) = 4 then
          a:= Int( line[2] );
          b:= Position( labels, line[3] );
          c:= Position( labels, line[4] );
          Add( lines, [ [ a, -1, b, -1, a, 1, b, 1 ], c ] );
        else
          Error( "strange line ", line, "\n" );
        fi;

      fi;
    od;

    # Specify the output.
    if IsEmpty( output ) then

      # The default output is given by the labels `1' and `2'.
      Add( lines, [ [ 1, 1 ], [ 2, 1 ] ] );

    else

      # The `oup' lines list the input labels.
      result:= [];
      for line in output do
        if Length( line ) = 2 and Int( line[2] ) <> fail then
          Append( result, List( [ 1 .. Int( line[2] ) ],
                          x -> [ Position( labels, String( x ) ), 1 ] ) );
        elif Length( line ) = Int( line[2] ) + 2 then
          Append( result, List( line{ [ 3 .. Length( line ) ] },
                          x -> [ Position( labels, x ), 1 ] ) );
        else
          Error( "corrupted line `", line, "'\n" );
        fi;
      od;
      Add( lines, result );

    fi;

    # Construct and return the program.
    return StraightLineProgramNC( lines );
end );


#############################################################################
##
#F  ScanStraightLineProgramX( <filename>, <tbl>, <classnames>, <gensnames> )
##
##  <filename> has the same meaning as in `ScanStraightLineProgram'.
##  <tbl> must be the ordinary character table of a group $G$, say,
##  with classes sorted as in the {\ATLAS} of Finite Groups~\cite{CCN85},
##  <classnames> must be the list of class names of <tbl> in {\ATLAS} format
##  (see~"ref:ClassNames" in the {\GAP} Reference Manual),
##  and <gensnames> must be the list of class names of the
##  standard generators of $G$.
##  If the file with name <filename> contains the program to compute class
##  representatives of $G$ then `ScanStraightLineProgramX' returns
##  the corresponding {\GAP} straight line program whose return value is the
##  list of class representatives of $G$ that is compatible with <tbl>.
##
##  In the `<groupname>G<n>-cycW<m>' files of the {\ATLAS} of Group
##  Representations
##  (see~"Filenames Used in the Atlas of Group Representations"),
##  conjugacy class representatives are defined only for representatives of
##  Galois families of maximally cyclic subgroups.
##  Representatives of the other classes can then be obtained by taking
##  suitable powers, but note that these representatives are not defined by
##  the program in the file, in this sense they are not ``standard''.
##
DeclareGlobalFunction( "ScanStraightLineProgramX" );

InstallGlobalFunction( ScanStraightLineProgramX,
    function( filename, tbl, classnames, gensnames )

    local file,
          data,
          line,
          labels,
          i,
          lines,
          output,
          a, b, c,
          result,
          nccl,
          orders,
          primes,
          known,
          unchanged,
          p,
          map,
          img,
          len,
          pos,
          orb,
          k,
          j,
          e;

    # Check the input.
    if not ( IsString( filename ) and IsOrdinaryTable( tbl )
                                  and IsList( classnames )
                                  and IsList( gensnames ) ) then
      Error( "usage: ScanStraightLineProgramX",
             "( <filename>, <tbl>, <cl>, <gens> )" );
    fi;

    # Read the data.
    file:= InputTextFile( filename );
    if file = fail then
      Error( "cannot create input stream for file <filename>" );
    fi;
    data:= [];
    InfoRead1( "#I  reading `", filename, "'\n" );
    line:= ReadLine( file );
    while line <> fail do
      if not IsEmpty( line ) then
        line:= SplitString( line, "", " \n" );
        if not IsEmpty( line ) then
          Add( data, line );
        fi;
      fi;
      line:= ReadLine( file );
    od;
    CloseStream( file );
    InfoRead1( "#I  reading `", filename, "' done\n" );

    # Determine the labels that occur.
    labels:= [];
    if data[1][1] <> "inp" then

      # There is no `inp' line.
      # The default input is given by the labels `1' and `2'.
      labels:=[ "1", "2" ];

    fi;
    for line in data do
      if line[1] = "inp" then
        if Length( line ) = 2 and Int( line[2] ) <> fail then
          Append( labels, List( [ 1 .. Int( line[2] ) ], String ) );
        elif Int( line[2] ) = Length( line ) + 2 then
          Append( labels, line{ [ 3 .. Length( line ) ] } );
        else
          Error( "corrupted line `", line, "'\n" );
        fi;
      elif line[1] = "pwr" then
        for i in [ 3 .. Length( line ) ] do
          if not line[i] in labels then
            Add( labels, line[i] );
          fi;
        od;
      elif line[1][1] <> '#' then
        for i in [ 2 .. Length( line ) ] do
          if not line[i] in labels then
            Add( labels, line[i] );
          fi;
        od;
      fi;
    od;

    # Translate the lines.
    lines:= [];
    output:= [];
    for line in data do
      if line[1] = "oup" then

        Add( output, line );

      elif line[1] <> "inp" and line[1][1] <> '#' then

        if   line[1] = "mu" and Length( line ) = 4 then
          a:= Position( labels, line[2] );
          b:= Position( labels, line[3] );
          c:= Position( labels, line[4] );
          Add( lines, [ [ a, 1, b, 1 ], c ] );
        elif line[1] = "iv" and Length( line ) = 3 then
          a:= Position( labels, line[2] );
          b:= Position( labels, line[3] );
          Add( lines, [ [ a, -1 ], b ] );
        elif line[1] = "pwr" and Length( line ) = 4 then
          a:= Int( line[2] );
          b:= Position( labels, line[3] );
          c:= Position( labels, line[4] );
          Add( lines, [ [ b, a ], c ] );
        elif line[1] = "cjr" and Length( line ) = 3 then
          a:= Position( labels, line[2] );
          b:= Position( labels, line[3] );
          Add( lines, [ [ b, -1, a, 1, b, 1 ], a ] );
        elif line[1] = "cp" and Length( line ) = 3 then
          a:= Position( labels, line[2] );
          b:= Position( labels, line[3] );
          Add( lines, [ [ a, 1 ], b ] );
        elif line[1] = "cj" and Length( line ) = 4 then
          a:= Int( line[2] );
          b:= Position( labels, line[3] );
          c:= Position( labels, line[4] );
          Add( lines, [ [ b, -1, a, 1, b, 1 ], c ] );
        elif line[1] = "com" and Length( line ) = 4 then
          a:= Int( line[2] );
          b:= Position( labels, line[3] );
          c:= Position( labels, line[4] );
          Add( lines, [ [ a, -1, b, -1, a, 1, b, 1 ], c ] );
        else
          Error( "strange line ", line, "\n" );
        fi;

      fi;
    od;

    # The program shall return conjugacy class representatives.
    result:= [];

    # Construct the list of class representatives form the labels.
    if not ForAll( labels,
                   str -> str in classnames or Int( str ) <> fail ) then
      Info( InfoCMeatAxe, 1,
            "not all class representatives available" );
            return fail;
    fi;

    # Insert the standard generators.
#T this assumes that the generators have not been overwritten!
    for i in [ 1 .. Length( gensnames ) ] do
      pos:= Position( classnames, gensnames[i] );
      if pos = fail then
        Info( InfoCMeatAxe, 1,
              "names of standard generators not among class names" );
        return fail;
      fi;
      result[ pos ]:= [ i, 1 ];
    od;

    # Insert other labels that are available.
    nccl:= Length( classnames );
    for i in [ 1 .. nccl ] do
      if classnames[i] in labels then
        result[i]:= [ Position( labels, classnames[i] ), 1 ];
      fi;
    od;

    # Use power maps to fill missing entries.
    orders:= OrdersClassRepresentatives( tbl );
    primes:= Set( Factors( Size( tbl ) ) );
    known:= Filtered( [ 1 .. nccl ], x -> IsBound( result[x] ) );
    SortParallel( - orders{ known }, known );
    repeat
      unchanged:= true;
      for p in primes do
        map:= PowerMap( tbl, p );
        for i in known do
          img:= map[i];
          if not img in known then
            len:= Length( labels ) + 1;
            labels[ len ]:= classnames[ img ];
            if classnames[i] in labels then
              pos:= Position( labels, classnames[i] );
            else
              pos:= Position( gensnames, classnames[i] );
            fi;
            Add( lines, [ [ pos, p ], len ] );
            result[ img ]:= [ len, 1 ];
            Add( known, img );
            unchanged:= false;
          fi;
        od;
      od;
    until unchanged;

    # Use Galois conjugacy to fill missing entries.
    for i in Difference( [ 1 .. nccl ], known ) do
      if not IsBound( result[i] ) then
        orb:= ClassOrbit( tbl, i );
        k:= First( orb, x -> x in known );
        if k = fail then
          Info( InfoCMeatAxe, 1,
                "representatives of classes in ", orb, " are missing" );
          return fail;
        fi;
        for j in orb do
          if not j in known then

            # Find a *small* power that maps k to j.
            e:= 1;
            repeat
              e:= e+1;
              if orders[k] mod e <> 0 then
                if PowerMap( tbl, e, k ) = j then
                  result[j]:= [ result[k][1], e ];
                fi;
              fi;
            until IsBound( result[j] );

          fi;
        od;
      fi;
    od;

    # Add the line that specifies the output list.
    Add( lines, result );

    # Construct and return the program.
    return StraightLineProgramNC( lines );
end );


#############################################################################
##
#F  AtlasStringOfStraightLineProgram( <prog> )
##
##  For a straight line program <prog> (see~"ref:IsStraightLineProgram" in
##  the {\GAP} Reference Manual), `AtlasStringOfStraightLineProgram' returns
##  a string describing the format of an equivalent straight line program
##  as used in the {\ATLAS} of Group Representations, that is,
##  the lines are of the form described in~"ScanStraightLineProgram".
##
DeclareGlobalFunction( "AtlasStringOfStraightLineProgram" );

InstallGlobalFunction( AtlasStringOfStraightLineProgram, function( prog )

    local str,            # string, result
          resused,        # maximal label currently used in the program
          i,
          translateword,
          line,
          lastresult;

    # Write the line of inputs.
    str:= "inp ";
    resused:= NrInputsOfStraightLineProgram( prog );
    Append( str, String( resused ) );
    Add( str, '\n' );

    # function to translate a word into a series of simple operations
    translateword:= function( word, respos )

      local used,  # maximal label, including intermediate results
            new,
            i;

      if resused < respos then
        resused:= respos;
      fi;
      used:= resused;

      if Length( word ) = 2 then

        # The word describes a simple powering.
        if word[2] = -1 then
          Append( str,
                  Concatenation( "iv ", String( word[1] ),
                                 " ", String( respos ), "\n" ) );
        elif 0 <= word[2] then
          Append( str,
                  Concatenation( "pwr ", String( word[2] ),
                                 " ", String( word[1] ),
                                 " ", String( respos ), "\n" ) );
        else
          used:= used + 1;
          Append( str,
                  Concatenation( "iv ", String( word[1] ),
                                 " ", String( used ), "\n" ) );
          Append( str,
                  Concatenation( "pwr ", String( -word[i] ),
                                 " ", String( used ),
                                 " ", String( respos ), "\n" ) );
        fi;

      else

        # Get rid of the powerings.
        new:= [];
        for i in [ 2, 4 .. Length( word ) ] do
          if word[i] = 1 then
            Add( new, word[ i-1 ] );
          elif 0 < word[i] then
            used:= used + 1;
            Append( str,
                    Concatenation( "pwr ", String( word[i] ),
                                   " ", String( word[ i-1 ] ),
                                   " ", String( used ), "\n" ) );
            Add( new, used );
          else
            used:= used + 1;
            Append( str,
                    Concatenation( "iv ", String( word[ i-1 ] ),
                                   " ", String( used ), "\n" ) );
            if word[i] < -1 then
              used:= used + 1;
              Append( str,
                      Concatenation( "pwr ", String( -word[i] ),
                                     " ", String( used-1 ),
                                     " ", String( used ), "\n" ) );
            fi;
            Add( new, used );
          fi;
        od;

        # Now form the product of the elements in `new'.
        if Length( new ) = 1 then
          if new[1] <> respos then
            Append( str,
                    Concatenation( "pwr 1 ", String( new[1] ),
                                   " ", String( respos ), "\n" ) );
          fi;
        elif Length( new ) = 2 then
          Append( str,
                  Concatenation( "mu ", String( new[1] ),
                                 " ", String( new[2] ),
                                 " ", String( respos ), "\n" ) );
        else
          used:= used + 1;
          Append( str,
                  Concatenation( "mu ", String( new[1] ),
                                 " ", String( new[2] ),
                                 " ", String( used ), "\n" ) );
          for i in [ 3 .. Length( new )-1 ] do
            used:= used + 1;
            Append( str,
                    Concatenation( "mu ", String( used - 1 ),
                                   " ", String( new[i] ),
                                   " ", String( used ), "\n" ) );
          od;
          used:= used + 1;
          Append( str,
                  Concatenation( "mu ", String( used - 1 ),
                                 " ", String( new[ Length( new ) ] ),
                                 " ", String( respos ), "\n" ) );
        fi;

      fi;
    end;

    # Loop over the lines.
    for line in LinesOfStraightLineProgram( prog ) do

      if ForAll( line, IsList ) then

        # The list describes the return values.
        lastresult:= "oup ";
        Append( lastresult, String( Length( line ) ) );
        if ForAny( [ 1 .. Length( line ) ], i -> line[i] <> [ i, 1 ] ) then
          for i in [ 1 .. Length( line ) ] do
            Add( lastresult, ' ' );
            if Length( line[i] ) = 2 and line[i][2] = 1 then
              Append( lastresult, String( line[i][1] ) );
            else
              resused:= resused + 1;
              translateword( line[i], resused );
              Append( lastresult, String( resused ) );
            fi;
          od;
        fi;
        Add( lastresult, '\n' );

        # Write the output statement.
        Append( str, lastresult );

        # Return the result.
        return str;

      else

        # Separate word and position where to put the result,
        # and translate the line into a sequence of simple steps.
        if ForAll( line, IsInt ) then
          resused:= resused + 1;
          lastresult:= resused;
          translateword( line, resused );
        else
          lastresult:= line[2];
          translateword( line[1], lastresult );
        fi;

      fi;
    od;

    # Write the output statement.
    Append( str, "oup 1 " );
    Append( str, String( lastresult ) );
    Add( str, '\n' );

    # Return the result;
    return str;
end );


#############################################################################
##
#E

