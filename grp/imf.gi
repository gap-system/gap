#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Volkmar Felsch.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file  contains  the  library  functions  for  the  GAP  library  of
##  irreducible maximal finite integral matrix groups.
##


#############################################################################
##
#F  BaseShortVectors( <orbit> ) . . . . . . . . . . . . . . . . . . . . . . .
##
InstallGlobalFunction( "BaseShortVectors", function ( orbit )

    local base, count, dim, i, j, nums, vector;

    dim := Length( orbit[1] );
    base := ListWithIdenticalEntries( dim, 0 );
    nums := ListWithIdenticalEntries( dim, 0 );
    count := 0;
    i := 0;

    while count < dim do
        i := i + 1;
        vector := orbit[i];
        j := 0;
        while j < dim do
            j := j + 1;
            if vector[j] <> 0 then
                if nums[j] <> 0 then
                    vector := vector - vector[j] * base[j];
                else
                    base[j] := vector / vector[j];
                    nums[j] := i;
                    count := count + 1;
                    j := dim;
                fi;
            fi;
        od;
    od;

    base := List( nums, i -> orbit[i] );
    return [ nums, base^-1 ];
end );


#############################################################################
##
#F  DisplayImfInvariants( <dim>, <q> )  . . . . . . . . . . . . . . . . . . .
#F  DisplayImfInvariants( <dim>, <q>, <z> ) . . . . . . . . . . . . . . . . .
##
InstallGlobalFunction( "DisplayImfInvariants", function ( arg )

    local dim, dims, hyphens, linelength, q, qq, z;

    # load the imf main list if it is not yet available
    if not IsBound( IMFList ) then
        IMFLoad( 0 );
    fi;

    # get the arguments
    dim := arg[1];
    q := arg[2];
    if Length( arg ) > 2 then
        z := arg[3];
    else
        z := 1;
    fi;

    # get the range of dimensions to be handled
    if dim = 0 then
        dims := [ 1 .. IMFRec.maximalDimension ];
    else
        # check the given dimension for being in range
        if dim < 0 or IMFRec.maximalDimension < dim then
            Error( "dimension out of range" );
        fi;
        dims := [ dim ];
    fi;

    # loop over all dimensions in that range
    for dim in dims do

        # handle the cases q = 0 and q > 0 differently
        if q = 0 then

            linelength := Minimum( SizeScreen()[1], 76 );
            hyphens := Concatenation( List( [ 1 .. linelength - 5 ],
                i -> "-" ) );

            # loop over the Q-classes of dimension dim
            for qq in [ 1 .. IMFRec.numberQClasses[dim] ] do

                # print a line of separators
                Print( "#I ", hyphens, "\n" );

                # check the Z-class number for being in range
                if z < 0 or Length( IMFRec.bNumbers[dim][qq] ) < z then
                    Error( "Z-class number out of range" );
                fi;

                # display the specified Z-classes in the Q-class
                DisplayImfReps( dim, qq, z );
            od;

            # print a line of separators
            Print( "#I ", hyphens, "\n" );

        else

            # check the given Q-class number for being in range
            if q < 1 or IMFRec.numberQClasses[dim] < q then
                Error( "Q-class number out of range" );
            fi;

            # check the Z-class number for being in range
            if z < 0 or Length( IMFRec.bNumbers[dim][q] ) < z then
                Error( "Z-class number out of range" );
            fi;

            # display the specified Z-classes in the Q-class
            DisplayImfReps( dim, q, z );

        fi;
    od;

end );


#############################################################################
##
#F  DisplayImfReps( <dim>, <q>, <z> ) . . . . . . . . . . . . . . . . . . . .
##
InstallGlobalFunction( "DisplayImfReps", function ( dim, q, z )

    local bound, degree, degs, eldivs, i, leng, mult, n, norm, qmax, size,
          solvable, type, znums;

    # get the position numbers of the groups to be handled
    znums := IMFRec.bNumbers[dim][q];
    if z = 0 then
        z := 1;
        bound := Length( znums );
    else
        bound := z;
    fi;

    # loop over the classes to be displayed
    while z <= bound do

        n := znums[z];
        type := IMFList[dim].isomorphismType[n];
        size := IMFList[dim].size[n];
        solvable := IMFList[dim].isSolvable[n];
        eldivs := IMFList[dim].elementaryDivisors[n];
        degs := IMFList[dim].degrees[n];
        norm := IMFList[dim].minimalNorm[n];

        # print a class number
        if IMFRec.repsAreZReps[dim] then
            Print( "#I Z-class ", dim, ".", q, ".", z );
        else
            Print( "#I Q-class ", dim, ".", q );
        fi;

        # print solvability and group size
        if solvable then
            Print( ":  Solvable, size = " );
        else
            Print( ":  Size = " );
        fi;
        PrintFactorsInt( size );
        Print( "\n" );

        # print the isomorphism type
        Print( "#I   isomorphism type = " );
        Print( type, "\n" );

        # print the elementary divisors
        Print( "#I   elementary divisors = " );
        Print( eldivs[1] );
        if eldivs[2] > 1 then
            Print( "^", eldivs[2] );
        fi;
        leng := Length( eldivs );
        i := 3;
        while i < leng do
            Print( "*", eldivs[i] );
            if eldivs[i+1] > 1 then
                Print( "^", eldivs[i+1] );
            fi;
            i := i + 2;
        od;
        Print( "\n" );

        # print the orbit size
        Print( "#I   orbit size = " );
        if IsInt( degs ) then
            Print( degs );
            leng := 1;
        else
            leng := Length( degs );
            i := 0;
            while i < leng do
                i := i + 1;
                degree := degs[i];
                mult := 1;
                while i < leng and degs[i+1] = degree do
                    mult := mult + 1;
                    i := i + 1;
                od;
                if mult > 1 then  Print( mult, "*" );  fi;
                Print( degree );
                if i < leng then  Print( " + " );  fi;
            od;
        fi;

        # print the minimal norm
        Print( ", minimal norm = ", norm, "\n" );

        # print a message if the group is not imf in Q
        qmax := IMFRec.maximalQClasses[dim][q];
        if qmax <> q then
            Print( "#I   not maximal finite in GL(", dim,
                ",Q), rational imf class is ", dim, ".", qmax, "\n" );
        fi;

        z := z + 1;
    od;

end );


#############################################################################
##
#F  ImfInvariants( <dim>, <q> ) . . . . . . . . . . . . . . . . . . . . . . .
#F  ImfInvariants( <dim>, <q>, <z> )  . . . . . . . . . . . . . . . . . . . .
##
InstallGlobalFunction( "ImfInvariants", function ( arg )

    local dim, eldivs, flat, i, infrec, j, leng, n, q, qmax, sizes;

    # check the arguments and get the position number of the class to be
    # handled
    n := ImfPositionNumber( arg );
    dim := arg[1];
    q := arg[2];

    # get the size of the orbits of short vectors
    sizes := IMFList[dim].degrees[n];
    if IsInt( sizes ) then
        sizes := [ sizes ];
    fi;

    # get the elementary divisors
    flat := IMFList[dim].elementaryDivisors[n];
    leng := Length( flat );
    eldivs := [ ];
    i := 1;
    while i < leng do
        for j in [ 1 .. flat[i+1] ] do
            Add( eldivs, flat[i] );
        od;
        i := i + 2;
    od;

    # get the Q-class number of the corresponding rational imf class
    qmax := IMFRec.maximalQClasses[dim][q];

    # create the information record and return it
    infrec := rec(
        size := IMFList[dim].size[n],
        isSolvable := IMFList[dim].isSolvable[n],
        isomorphismType := IMFList[dim].isomorphismType[n],
        elementaryDivisors := eldivs,
        minimalNorm := IMFList[dim].minimalNorm[n],
        sizesOrbitsShortVectors := sizes );
    if qmax <> q then
        infrec.maximalQClass := qmax;
    fi;

    return infrec;
end );


#############################################################################
##
#F  IMFLoad( <dim> ) . . . . . . . . load a secondary file of the imf library
##
InstallGlobalFunction( "IMFLoad", function ( dim )

    local d, maxdim, name;

    # initialize the imf main list if it is not yet available
    if not IsBound( IMFList ) then
        name := "imf.grp";
        Info( InfoImf, 2, "loading secondary file ", name );
        ReadGrp( name );
    fi;

    # check whether we actually need to load a matrix file
    if dim > 0 and not IsBound( IMFList[dim].matrices ) then

        # load the file
        if dim < 10 then
            name := "imf1to9.grp";
        else
            name := Concatenation( "imf", String( dim ), ".grp" );
        fi;
        Info( InfoImf, 2, "loading secondary file ", name );
        ReadGrp( name );
    fi;

    return;
end );


#############################################################################
##
#F  ImfMatrixGroup( <dim>, <q> )  . . . . . . . . . . . . . . . . . . . . . .
#F  ImfMatrixGroup( <dim>, <q>, <z> ) . . . . . . . . . . . . . . . . . . . .
##
InstallGlobalFunction( "ImfMatrixGroup", function ( arg )

    local degrees, dim, form, gens, i, imfM, j, M, mats, n, name, q, qmax,
          reps, z;

    # check the arguments and get the position number of the class to be
    # handled
    n := ImfPositionNumber( arg );

    # get dimension, Q-class number, and Z-class number
    dim := arg[1];
    q := arg[2];
    z := arg[3];

    # load the appropriate imf matrix file if it is not yet available
    if not IsBound( IMFList[dim].matrices ) then
        IMFLoad( dim );
    fi;

    # construct the matrix group
    mats := IMFList[dim].matrices[n];
    gens := mats[2];
    M := Group( gens );

    # construct the group name
    if IMFRec.repsAreZReps[dim] then
        name := Concatenation( "ImfMatrixGroup(", String( dim ), ",",
            String( q ), ",", String( z ), ")" );
    else
        name := Concatenation( "ImfMatrixGroup(", String( dim ), ",",
            String( q ), ")" );
    fi;

    # get the associated Gram matrix
    form := List( mats[1], ShallowCopy );
    for i in [ 1 .. dim - 1 ] do
        for j in [ i + 1 .. dim ] do
            form[i][j] := form[j][i];
        od;
    od;

    # get the representatives and sizes of the orbits of short vectors
    reps := IMFList[dim].orbitReps[n];
    degrees := IMFList[dim].degrees[n];
    if IsInt( degrees ) then
        degrees := [ degrees ];
        reps := [ reps ];
    fi;

    # get the Q-class number of the corresponding rational imf class
    qmax := IMFRec.maximalQClasses[dim][q];

    # define an appropriate imf record
    imfM := rec( );
    imfM.isomorphismType := IMFList[dim].isomorphismType[n];
    imfM.elementaryDivisors := ElementaryDivisorsMat( form );
    imfM.form := form;
    imfM.minimalNorm := IMFList[dim].minimalNorm[n];
    imfM.repsOrbitsShortVectors := reps;
    imfM.sizesOrbitsShortVectors := degrees;
    if qmax <> q then
        imfM.maximalQClass := qmax;
    fi;

    # define some appropriate group attributes
    SetFilterObj( M, IsImfMatrixGroup );
    SetName( M, name );
    SetSize( M, IMFList[dim].size[n] );
    SetIsSolvableGroup( M, IMFList[dim].isSolvable[n] );
    SetImfRecord( M, imfM );

    return M;
end );


#############################################################################
##
#F  ImfNumberQClasses( <dim> )  . . . . . . . . . . . . . . . . . . . . . . .
##
InstallGlobalFunction( "ImfNumberQClasses", function ( dim )

    # load the imf main list if it is not yet available
    if not IsBound( IMFList ) then
        IMFLoad( 0 );
    fi;

    # check the given dimension for being in range
    if dim < 0 or IMFRec.maximalDimension < dim then
        Error( "dimension out of range" );
    fi;

    return IMFRec.numberQClasses[dim];
end );


#############################################################################
##
#F  ImfNumberQQClasses( <dim> ) . . . . . . . . . . . . . . . . . . . . . . .
##
InstallGlobalFunction( "ImfNumberQQClasses", function ( dim )

    # load the imf main list if it is not yet available
    if not IsBound( IMFList ) then
        IMFLoad( 0 );
    fi;

    # check the given dimension for being in range
    if dim < 0 or IMFRec.maximalDimension < dim then
        Error( "dimension out of range" );
    fi;

    return IMFRec.numberQQClasses[dim];
end );


#############################################################################
##
#F  ImfNumberZClasses( <dim>, <q> ) . . . . . . . . . . . . . . . . . . . . .
##
InstallGlobalFunction( "ImfNumberZClasses", function ( dim, q )

    local num;

    # load the imf main list if it is not yet available
    if not IsBound( IMFList ) then
        IMFLoad( 0 );
    fi;

    # check the dimension for being in range
    if dim < 1 or IMFRec.maximalDimension < dim then
        Error( "dimension out of range" );
    fi;

    # check the Q-class number for being in range
    if q < 1 or IMFRec.numberQClasses[dim] < q then
        Error( "Q-class number out of range" );
    fi;

    # return the number of class representatives in the given Q-class
    return Length( IMFRec.bNumbers[dim][q] );

end );


#############################################################################
##
#F  ImfPositionNumber( [ <dim>, <q> ] ) . . . . . . . . . . . . . . . . . . .
#F  ImfPositionNumber( [ <dim>, <q>, <z> ] )  . . . . . . . . . . . . . . . .
##
InstallGlobalFunction( "ImfPositionNumber", function ( args )

    local dim, n, q, z, znums;

    # load the imf main list if it is not yet available
    if not IsBound( IMFList ) then
        IMFLoad( 0 );
    fi;

    # check the dimension for being in range
    dim := args[1];
    if dim < 1 or IMFRec.maximalDimension < dim then
        Error( "dimension out of range" );
    fi;

    # check the Q-class number for being in range
    q := args[2];
    if q < 1 or IMFRec.numberQClasses[dim] < q then
        Error( "Q-class number out of range" );
    fi;
    znums := IMFRec.bNumbers[dim][q];

    # get the Z-class number and check it for being in range
    if Length( args ) = 2 then
        z := 1;
        args[3] := 1;
    else
        z := args[3];
        if z < 1 or Length( znums ) < z then
            Error( "Z-class number out of range" );
        fi;
    fi;

    # return the position number of the class to be handled
    return znums[z];

end );


#############################################################################
##
#F  IsomorphismPermGroupImfGroup( <M> ) . . . . . . . . . . . . . . . . . . .
#F  IsomorphismPermGroupImfGroup( <M>, <n> )  . . . . . . . . . . . . . . . .
##
InstallGlobalFunction( "IsomorphismPermGroupImfGroup", function ( arg )

    local base, degrees, gens, imfM, imfP, M, n, orbit, P, perms, phi,
          reps, vec;

    # check the given group for being an imf matrix group
    M := arg[1];
    if not IsImfMatrixGroup( M ) then
        Error( "the given group is not an imf matrix group" );
    fi;
    imfM := ImfRecord( M );

    # check the given orbit number for being in range
    degrees := imfM.sizesOrbitsShortVectors;
    reps := imfM.repsOrbitsShortVectors;
    if Length( arg ) = 1 then
        n := 1;
    else
        n := arg[2];
        if not n in [ 1 .. Length( reps ) ] then
            Error( "orbit number out of range" );
        fi;
    fi;

    # compute the specified orbit of short vectors
    gens := GeneratorsOfGroup( M );
    orbit := OrbitShortVectors( gens, reps[n] );

    # check the orbit size
    if Length( orbit ) <> degrees[n] then
        Error( "inconsistent orbit size" );
    fi;

    # construct the associated permutation group
    perms := List( gens, g -> PermList(
        List( orbit, vec -> PositionSorted( orbit, vec * g ) ) ) );
    P := Group( perms );

    # define an appropriate imf record
    imfP := rec( );

    # define some appropriate group attributes
    SetSize( P, Size( M ) );
    SetIsSolvableGroup( P, IsSolvableGroup( M ) );
    SetLargestMovedPoint( P, degrees[n] );
    SetImfRecord( P, imfP );
#   if IsBound( imfM.isomorphismType ) then
#       imfP.isomorphismType := imfM.isomorphismType;
#   fi;
#   imfP.matGroup := M;

    # compute the information which will be needed to reconvert permutations
    # to matrices
    base := BaseShortVectors( orbit );
    imfP.orbitShortVectors := orbit;
    imfP.baseVectorPositions := base[1];
    imfP.baseChangeMatrix := base[2];

    # construct the associated isomorphism from M to P
    phi := GroupHomomorphismByFunction(
        M,
        P,
        function ( mat )
            local imf;
            imf := ImfRecord( P );
            return PermList( List( imf.orbitShortVectors, v ->
                PositionSorted( imf.orbitShortVectors, v*mat ) ) );
        end,
        function ( perm )
            local imf;
            imf := ImfRecord( P );
            return imf.baseChangeMatrix * List( imf.baseVectorPositions, i ->
                imf.orbitShortVectors[i^perm] );
        end );
    SetIsBijective( phi, true );

    # if n = 1, save a nice monomorphism of M
    if n = 1 and not HasNiceMonomorphism( M ) then
         SetNiceMonomorphism( M, phi );
    fi;

    return phi;
end );


#############################################################################
##
#M  IsomorphismPermGroup( <M> )
##
InstallMethod( IsomorphismPermGroup,
    "imf matrix groups",
    [IsMatrixGroup and IsFinite and IsImfMatrixGroup],
    IsomorphismPermGroupImfGroup );


#############################################################################
##
#F  OrbitShortVectors( <gens>, <rep> )  . . . . . . . . . . . . . . . . . . .
##
InstallGlobalFunction( "OrbitShortVectors", function ( gens, rep )

    local generator, images, new, nextvec, null, orbit, vector;

    orbit := [ ];
    null := ListWithIdenticalEntries( Length( rep ), 0 );
    if rep > null then
        images := [ Immutable( rep ) ];
    else
        images := [ Immutable( -rep ) ];
    fi;
    while images <> [ ] do
        Append( orbit, images );
        new := [ ];
        for generator in gens do
            for vector in images do
                nextvec := vector * generator;
                if nextvec > null then
                    Add( new, nextvec );
                else
                    Add( new, -nextvec );
                fi;
            od;
        od;
        new := Set( new );
        SubtractSet( new, orbit );
        images := new;
    od;

    Append( orbit, -orbit );
    # The function Immutable in the following statement essentially speeds
    # up the function PositionSorted in IsomorphismPermGroupImfGroup.
    return Immutable( Set( orbit ) );
end );
