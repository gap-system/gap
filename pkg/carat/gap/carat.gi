#############################################################################
##
#W  carat.gi               Interface to Carat                   Franz G"ahler
##
#Y  Copyright (C) 1999,      Franz G"ahler,        ITAP, Stuttgart University
##
##  Input/Output routines for interfacing with Carat data files
##


#############################################################################
##
#F  CaratTmpFile( name ) . . . . . returns file 'name' in Carat tmp directory
##
InstallGlobalFunction( CaratTmpFile, function( name )
    # if Carat temporary directory has disappeared, recreate it
    if not IsDirectoryPath( CARAT_TMP_DIR![1] ) then
        MakeReadWriteGlobal( "CARAT_TMP_DIR" );
        UnbindGlobal( "CARAT_TMP_DIR" );
        BindGlobal( "CARAT_TMP_DIR", DirectoryTemporary() );
    fi;
    return Filename( CARAT_TMP_DIR, name );
end );


#############################################################################
##
#F  CaratReadLine( input )  . . . . . . . . . . read line and discard comment
##
CaratReadLine := function( input )
    local str, pos;
    str := ReadLine( input );
    if str = fail then
        return fail;
    fi;
    pos := Position( str, '%' );
    if pos <> fail then
        return str{[1..pos-1]};
    else
        return str;
    fi;
end;


#############################################################################
##
#F  CaratNextNumber( str, start )  next number in string after position start
##

# this is a hack needed in CaratNextNumber, CaratReadNumbers
CaratReadPosition := 1;

CaratNextNumber := function( str, start )

    local len, pos1, pos2;

    len  := Length( str );
    pos1 := start;
    while pos1 <= len and not IsDigitChar( str[pos1] ) do
        pos1 := pos1 + 1;
    od;
    if pos1 > len then
        return fail;
    elif pos1 > 1 and str[pos1-1] = '-' then
        pos1 := pos1 - 1;
    fi;

    pos2 := pos1 + 1;
    while pos2 <= len and IsDigitChar( str[pos2] ) do
        pos2 := pos2 + 1;
    od;
    CaratReadPosition := pos2;

    return Int( str{[pos1..pos2-1]} );

end;
 

#############################################################################
##
#F  CaratReadNumbers( input, ntot )  . . . . . . read ntot numbers from input
##
CaratReadNumbers := function( input, ntot )

    local res, nread, str, n;

    res := [];
    nread := 0;

    while nread < ntot do

        str := ReadLine( input );
        n := CaratNextNumber( str, 1 );
        while n <> fail do
            Add( res, n );
            nread := nread + 1;
            n := CaratNextNumber( str, CaratReadPosition );
        od;

    od;
    return res;

end; 


#############################################################################
##
#F  CaratReadMatrixScalar( input, dim ) . . . . read scalar matrix from input
##
CaratReadMatrixScalar := function( input, dim )
    local lst;
    lst := CaratReadNumbers( input, 1 );
    return lst[1] * IdentityMat( dim );
end;


#############################################################################
##
#F  CaratReadMatrixDiagonal( input, dim ) . . read diagonal matrix from input
##
CaratReadMatrixDiagonal := function( input, dim )
    local lst, mat, i;
    lst := CaratReadNumbers( input, dim );
    mat := List( [1..dim], i -> List( [1..dim], j -> 0 ) );
    for i in [1..dim] do 
        mat[i][i] := lst[i];
    od;
    return mat;
end;


#############################################################################
##
#F  CaratReadMatrixSymmetric( input, dim ) . read symmetric matrix from input
##
CaratReadMatrixSymmetric := function( input, dim )
    local lst, mat, pos, i, j;
    lst := CaratReadNumbers( input, dim*(dim+1)/2 );
    mat := [];
    pos := 1;
    for i in [1..dim] do
        Add( mat, lst{[pos..pos+i-1]} );
        pos := pos + i;
    od;
    for i in [1..dim-1] do
        for j in [i+1..dim] do
            mat[i][j] := mat[j][i];
        od;
    od;
    return mat;
end;


#############################################################################
##
#F  CaratReadMatrixFull( input, n, m ) . . . . . . read nxm matrix from input
##
CaratReadMatrixFull := function( input, n, m )
    local lst;
    lst := CaratReadNumbers( input, n*m );
    return List( [1..n], i -> lst{[ (i-1)*m+1 .. i*m ]});
end;


#############################################################################
##
#F  CaratReadMatrix( input, str )  . . read matrix with header str from input
##
CaratReadMatrix := function( input, str )

    local n, den, pos, m;

    n   := CaratNextNumber( str, 1 );

    # is matrix rational?
    pos := Position( str, '/' );
    if pos <> fail then
        den := CaratNextNumber( str, pos + 1 );
    else
        den := 1;
    fi;

    # matrix format with 'x'
    pos := Position( str, 'x' );
    if pos <> fail then
        m := CaratNextNumber( str, pos + 1 );
        if m > 0 then
            return CaratReadMatrixFull( input, n, m ) / den;
        else
            return CaratReadMatrixSymmetric( input, n ) / den;
        fi;
    fi;

    # matrix format with 'd'
    pos := Position( str, 'd' );
    if pos <> fail then
        m := CaratNextNumber( str, pos + 1 );
        if m = 1 then
            return CaratReadMatrixDiagonal( input, n ) / den;
        else
            return CaratReadMatrixScalar( input, n ) / den;
        fi;

    fi;

    # full square matrix
    return CaratReadMatrixFull( input, n, n ) / den;

end;


#############################################################################
##
#F  CaratReadMatrices( input, n ) . .. . . . . . . read n matrices from input
##
CaratReadMatrices := function( input, n )

    local res, i, str;

    res := [];
    for i in [1..n] do
        str := CaratReadLine( input );
        Add( res, CaratReadMatrix( input, str ) );
    od;
    return res;

end;        


#############################################################################
##
#F  CaratReadMatrixFile( filename )  . . . . . . . . . read Carat matrix file
##
InstallGlobalFunction( CaratReadMatrixFile, function( filename )

    local input, str, pos, n, res, i;

    input := InputTextFile( filename );
    str   := CaratReadLine( input );
    pos   := Position( str, '#' );

    # several matrices
    if pos <> fail then
        n   := CaratNextNumber( str, pos + 1 );
        res := CaratReadMatrices( input, n );

    # just one matrix
    else
        res := CaratReadMatrix( input, str );
    fi;

    CloseStream( input );
    return res;

end ); 


#############################################################################
##
##  A bravais record is a record with components
##
##  generators:   generators of the group
##  formspace:    basis of space of invariant forms (optional)
##  centerings:   basis of centering matrices (optional)
##  normalizer:   additional generators of normalizer in GL(n,Z) (optional)
##  centralizer:  additional generators of centralizer in GL(n,Z) (optional)
##  size:         size of the group
##


#############################################################################
##
#F  CaratReadBravaisRecord( input, str )  . . . . . read Carat Bravais record
##
CaratReadBravaisRecord := function( input, str )

    local res, pos, n, line;

    res := rec();

    # read group generators
    pos := Position( str, 'g' );

    # normal Bravais file format
    if pos <> fail then
        n := CaratNextNumber( str, pos + 1 );
        res.generators := CaratReadMatrices( input, n );

    # just generators, matrix file format
    # could the size also be given?
    else
        n := CaratNextNumber( str, 2 );
        res.generators := CaratReadMatrices( input, n );
        return res;
    fi;

    # read form space basis
    pos := Position( str, 'f' );
    if pos <> fail then
        n := CaratNextNumber( str, pos + 1 );
        res.formspace := CaratReadMatrices( input, n );
    fi;

    # read centering matrices
    pos := Position( str, 'z' );
    if pos <> fail then
        n := CaratNextNumber( str, pos + 1 );
        res.centerings := CaratReadMatrices( input, n );
    fi;

    # read normalizer generators
    pos := Position( str, 'n' );
    if pos <> fail then
        n := CaratNextNumber( str, pos + 1 );
        res.normalizer := CaratReadMatrices( input, n );
    fi;

    # read centralizer generators
    pos := Position( str, 'c' );
    if pos <> fail then
        n := CaratNextNumber( str, pos + 1 );
        res.centralizer := CaratReadMatrices( input, n );
    fi;

    # read size of the group; is optional, but not announced in the header
    line := ReadLine( input );
    if line <> fail then
        pos := Position( line, '=' );
        res.size := CaratNextNumber( line, pos + 1 );
    fi;

    return res;

end;


#############################################################################
##
#F  CaratReadBravaisFile( filename )  . . . . . . . . read Carat Bravais file
##
InstallGlobalFunction( CaratReadBravaisFile, function( filename )

    local input, str, res;

    input := InputTextFile( filename );
    str   := CaratReadLine( input );
    res   := CaratReadBravaisRecord( input, str );

    CloseStream( input );
    return res;

end ); 


#############################################################################
##
#F  CaratReadMultiBravaisFile( filename ) . . . read Carat Multi-Bravais file
##
InstallGlobalFunction( CaratReadMultiBravaisFile, function( filename )

    local input, str, res;

    input := InputTextFile( filename );
    str   := CaratReadLine( input );
    res   := rec( info := [], groups := [] );

    # read comments until first Bravais record starts
    while Length( str ) < 2 or str{[1..2]} <> "#g" do
        Add( res.info, str );
        str := CaratReadLine( input );
    od;

    # read the Bravais records
    while str <> fail and Length( str ) >= 2 and str{[1..2]} = "#g" do
        Add( res.groups, CaratReadBravaisRecord( input, str ) );
        str := CaratReadLine( input );
    od;

    CloseStream( input );
    return res;

end ); 


#############################################################################
##
#F  CaratWriteMatrix( output, mat )  . . . . . . write Carat matrix to stream
##
CaratWriteMatrix := function( output, mat )

    local d, str, i, j;

    # for simplicity, we always write in full format
    d := DimensionsMat( mat );
    if d[1]=d[2] then
        str := String( d[1] );
    else
        str := Concatenation( String( d[1] ), "x", String( d[2] ) );
    fi;

    WriteLine( output, str );
    for i in [1..d[1]] do
        str := "";
        Append( str, String( mat[i][1] ) );
        for j in [2..d[2]] do
            Append( str, " " );
            Append( str, String( mat[i][j] ) );
        od;
        WriteLine( output, str );
    od;

end;


#############################################################################
##
#F  CaratWriteMatrixFile( filename, data )  . write Carat matrix data to file
##
InstallGlobalFunction( CaratWriteMatrixFile, function( filename, data )

    local output, header, mat;

    output := OutputTextFile( filename, false );

    # one matrix
    if IsMatrix( data ) then
        CaratWriteMatrix( output, data );

    # list of matrices
    else
        header := Concatenation( "#", String( Length( data ) ) );
        WriteLine( output, header );
        for mat in data do
            CaratWriteMatrix( output, mat );
        od;
    fi;
    CloseStream( output );

end );


#############################################################################
##
#F  CaratFactorString( n )  . . . . factorization of n in Carat string format
##
CaratFactorString := function( n )

    local fac, set, ExpStr, str, p;

    fac := FactorsInt( n );
    set := Set( fac );

    ExpStr := function( n )
        return String( Number( fac, x -> x = n ) );
    end;

    str := Concatenation( String( set[1] ), "^", ExpStr( set[1] ) ); 

    for p in set{[2..Length(set)]} do
         str := Concatenation( str, " * ", String( p ), "^", ExpStr( p ) );
    od;

    str := Concatenation( str, " = ", String( n ) );

    return str;

end;


#############################################################################
##
#F  CaratWriteBravaisFile( filename, data )  write Carat Bravais rec. to file
##
InstallGlobalFunction( CaratWriteBravaisFile, function( filename, data )

    local output, header, len, i;

    # first construct the header with its different entries

    header := "#";

    if IsBound( data.generators ) then
        len    := Length( data.generators );
        header := Concatenation( header, "g", String( len ), " " );
    fi;

    if IsBound( data.formspace ) then
        len    := Length( data.formspace );
        header := Concatenation( header, "f", String( len ), " " );
    fi;

    if IsBound( data.centerings ) then
        len    := Length( data.centerings );
        header := Concatenation( header, "z", String( len ), " " );
    fi;

    if IsBound( data.normalizer ) then
        len    := Length( data.normalizer );
        header := Concatenation( header, "n", String( len ), " " );
    fi;

    if IsBound( data.centralizer ) then
        len    := Length( data.centralizer );
        header := Concatenation( header, "c", String( len ), " " );
    fi;

    # open file and write the header
    output := OutputTextFile( filename, false );
    WriteLine( output, header );

    # write all componentes of the data

    if IsBound( data.generators ) then
        for i in [1..Length( data.generators )] do
            CaratWriteMatrix( output, data.generators[i] );
        od;
    fi;

    if IsBound( data.formspace ) then
        for i in [1..Length( data.formspace )] do
            CaratWriteMatrix( output, data.formspace[i] );
        od;
    fi;

    if IsBound( data.centerings ) then
        for i in [1..Length( data.centerings )] do
            CaratWriteMatrix( output, data.centerings[i] );
        od;
    fi;

    if IsBound( data.normalizer ) then
        for i in [1..Length( data.normalizer )] do
            CaratWriteMatrix( output, data.normalizer[i] );
        od;
    fi;

    if IsBound( data.centralizer ) then
        for i in [1..Length( data.centralizer )] do
            CaratWriteMatrix( output, data.centralizer[i] );
        od;
    fi;

    if IsBound( data.size ) then
        WriteLine( output, CaratFactorString( data.size ) );
    fi;

    CloseStream( output );

end );


#############################################################################
##
##  General purpose commands for working with Carat
##


#############################################################################
##
#F  CaratShowFile( filename )  . . . . . . . . . display contents of filename
##
InstallGlobalFunction( CaratShowFile, function( filename )
    local input;
    input := InputTextFile( filename );
    if input = fail then
        Error( Concatenation( "File ", filename, " not found." ) );
    fi;
    Print( ReadAll( input ) );
    CloseStream( input );
    return;
end );


#############################################################################
##
#F  CaratStringToWordList( string )  . . . . . .cut string into list of words
##
CaratStringToWordList := function( string )

    local seps, lst, str, pos1, pos2;

    seps := [ ' ', '\t', '\n' ];
    lst  := [];
    str  := string;
    pos1 := Position( str, First( str, x -> not x in seps ) );
    while pos1 <> fail do
        str := str{[pos1..Length(str)]};
        pos2 := Position( str, First( str, x -> x in seps ) );
        if pos2 = fail then
            pos2 := Length( str ) + 1;
        fi;
        Add( lst, str{[1..pos2-1]} );
        str := str{[pos2..Length(str)]};
        pos1 := Position( str, First( str, x -> not x in seps ) );
    od;
    return lst;

end;


#############################################################################
##
#F  CaratCommand( cmd, args, outfile )  exec cmd with args, output to outfile
##
InstallGlobalFunction( CaratCommand, function( command, args, outfile )

    local program, output, err;

    # find executable
    program := Filename( CARAT_BIN_DIR, command );    
    if program = fail then
        Error( Concatenation( "Carat program ", command, " not found." ) );
    fi;

    # execute command
    output := OutputTextFile( outfile, false );
    err    := Process( DirectoryCurrent(), program, InputTextNone(), 
                       output, CaratStringToWordList( args ) );
    CloseStream( output );

    # did it work?
    if err = 2 and args <> "-h" then   # we used wrong arguments
        CaratShowFile( outfile );      # contains usage advice
    fi;
    if err < 0 and args <> "-h" then
        Error( Concatenation( "Carat program ", command,
                              " failed with error code ", String(err) ) );
    fi;

end );


#############################################################################
##
#F  CaratHelp( command )  . . . . . . . display online help for Carat command
##
InstallGlobalFunction( CaratHelp, function( command )
    CaratCommand( command, "-h", "*stdout*" );
end );




