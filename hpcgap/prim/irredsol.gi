#############################################################################
##
#W  irredsol.gi                 GAP group library                  Mark Short
#W                                                           Burkhard Höfling
##
##
#Y  Copyright (C) 1993, Murdoch University, Perth, Australia
#Y  Copyright (C) 2001, Technische Universität, Braunschweig, Germany
##
##  This file contains the  functions and  data for the  irreducible solvable
##  matrix group library.  It contains  exactly one member  for each of  the
##  372  conjugacy  classes of  irreducible  solvable subgroups of  $GL(n,p)$
##  where $1 < n$, $p$ is a prime, and $p^n < 256$.  
##
##  By well known  theory, this data also  doubles as a  library of primitive
##  solvable permutation groups of non-prime degree <256. 
##
##  This file contains the data  from Mark Short's thesis,  plus  two  groups 
##  missing from that list, subsequently discovered by Alexander Hulpke.
##

#############################################################################
##
#F  IrreducibleSolvableGroup(<n>,<p>,<k>) . . . . . . old extraction function
##
InstallGlobalFunction( IrreducibleSolvableGroup, function ( n, p, k )

    Error ("This function is obsolete. Please see ",
        "`IrreducibleSolvableGroupMS' in the GAP manual");
end);

#############################################################################
##
#F  IrreducibleSolvableGroupMS(<n>,<p>,<k>) . . . . . extraction function
##
InstallGlobalFunction( IrreducibleSolvableGroupMS, function ( n, p, k )
    local
        desc,          # compact description of group
        guard,         # number of guardian of group
        gdgens,        # list of generators for that guardian
        len,           # length of this list
        numgen,        # number of generators of the group
        pos,           # marks position in desc where next normal form begins
        i, j,          # loop variables
        gens,          # the generators of the group
        idmat,         # the identity matrix of GL(n,p)
        mat,           # evolves from idmat into a generator of the group
        grp;           # group to be returned

    # Check for sensible input
    if not (n > 1 and p in Primes and p^n < 256) then
        Error( "n must be > 1, p must be prime, and p^n must be < 256" );
    fi;
    if k > Length( IrredSolGroupList[ n ][ p ] ) then
        Error( "there is no k-th group for this n and p" );
    fi;

    # Pick out a few important pieces of information
    desc  := IrredSolGroupList[ n ][ p ][ k ];
    gdgens := IrredSolJSGens[ n ][ p ][ desc[3] ];
    len := Length( gdgens );

    # Construct the generators
    gens := [ ];
    idmat := Immutable( IdentityMat( n, GF( p ) ) );
    for i in [1..(Length(desc)-3)/len] do
        mat := idmat;
        for j in [1..len] do
            mat := mat * ( gdgens[ j ] ^ desc[ 3 + len*(i-1) + j ] );
        od;
        gens[ i ] := mat;
    od;

    # Make the group and return it
    grp := GroupByGenerators( gens, idmat );
    SetSize( grp, desc[ 1 ] );
    if desc[ 2 ] = 0 then
        SetIsPrimitiveMatrixGroup (grp, true);
        SetMinimalBlockDimension (grp, n);
    else
        SetIsPrimitiveMatrixGroup (grp, false);
        SetMinimalBlockDimension (grp, desc[ 2 ]);
    fi;
    return grp;
end ); # IrreducibleSolvableGroupMS( n, p, k )


#############################################################################
##
#F  NumberIrreducibleSolvableGroups(<n>,<p>)
##
##  returns the number of conjugacy classes of irreducible solvable subgroups
##  of GL(n,p)
##
InstallGlobalFunction( NumberIrreducibleSolvableGroups, function ( n, p )
	return Length (IrredSolGroupList[ n ][ p ]);
end);
	
	

#############################################################################
##
#F  AllIrreducibleSolvableGroups(...)  
#F                                     select all irreducible solvable groups
##
InstallGlobalFunction (AllIrreducibleSolvableGroups, function ( arg )
    local
        dims,            # dimensions
        chars,           # characteristics
        sizes,           # sizes
        linprim,         # linearly primitive flag
        minblockdims,    # minimal block dimensions
        funs,            # other functions requested by caller
        vals,            # their values
        i,               # counter through arg
        nppairs,         # (n,p) pairs such that p^n < 256
        np,              # counter through nppairs
        n,               # n
        p,               # p
        grplist,         # list of groups to be returned
        k,               # counter through group descriptions for GL(n,p)
        desc,            # compact description of the kth group in GL(n,p)
        gp,              # the group itself
        passtest;        # boolean flag

    # Initialize a few things
    funs := [ ];
    vals := [ ];

    # Loop through the arguments
    for i in [1..Length(arg)/2] do

        # Special case for Dimension
        if arg[2*i-1] in [ Dimension, DimensionOfMatrixGroup, DegreeOfMatrixGroup] then
            if not IsList( arg[2*i] ) then
                arg[2*i] := [ arg[2*i] ];
            fi;
            dims := [ ];
            for n in arg[2*i] do
                if n in [ 2, 3, 4, 5, 6, 7 ] then
                    Add( dims, n );
                else
                    Print( "#W  AllIrreducibleSolvableGroups: ",
                           "n = ", n, " outside range of library\n" );
                fi;
            od;
            if dims = [ ] then
                Error( "all Dimension arguments outside range of library" );
            fi;

        # Special case for CharFFE
        elif arg[2*i-1] = Characteristic  then
            if not IsList( arg[2*i] ) then
                arg[2*i] := [ arg[2*i] ];
            fi;
            chars := [ ];
            for p in arg[2*i] do
                if p in [ 2, 3, 5, 7, 11, 13 ] then
                    Add( chars, p );
                else
                    Print( "#W  AllIrreducibleSolvableGroups: ",
                           "p = ", p, " outside range of library\n" );
                fi;
            od;
            if chars = [ ] then
                Error( "all Characteristic arguments outside range of library" );
            fi;

        # Special case for Size
        elif arg[2*i-1] = Size then
            if IsList( arg[2*i] ) then
                sizes := arg[2*i];
            else
                sizes := [ arg[2*i] ];
            fi;

        # Special case for IsPrimitiveMatrixGroup
        elif arg[2*i-1] in [ IsLinearlyPrimitive, IsPrimitiveMatrixGroup] then
            if IsBool( arg[2*i] ) then
                linprim := arg[2*i];
            else
                Error( "IsPrimitive argument must be boolean" );
            fi;

        # Special case for MinimalBlockDimension
        elif arg[2*i-1] = MinimalBlockDimension then
            if IsList( arg[2*i] ) then
                minblockdims := arg[2*i];
            else
                minblockdims := [ arg[2*i] ];
            fi;

        # General case
        elif IsFunction( arg[2*i-1] ) then
            Add( funs, arg[2*i-1] );
            Add( vals, arg[2*i] );
        else
            Error( "<fun",i,"> must be a function" );
        fi;
    od;

    # Find the allowable (n,p) pairs
    if not IsBound( dims ) and not IsBound( chars ) then
        nppairs := [ [2,2], [2,3], [2,5], [2,7], [2,11], [2,13],
                     [3,2], [3,3], [3,5],
                     [4,2], [4,3],
                     [5,2], [5,3],
                     [6,2],
                     [7,2] ];
    elif IsBound( dims ) and IsBound( chars ) then
        nppairs := [ ];
        for n in dims do
            for p in chars do
                if p^n < 256 then
                    Add( nppairs, [ n, p ] );
                else
                    Print( "#W  AllIrreducibleSolvableGroups: n = ", n,
                           ", p = ", p, " outside range of library\n" );
                fi;
            od;
        od;
        if nppairs = [ ] then
            Error( "none of the specified (n,p) pairs satisfy p^n < 256" );
        fi;
    else
        if not IsBound( dims ) then
            dims := [ 2, 3, 4, 5, 6, 7 ];
        else
            chars := [ 2, 3, 5, 7, 11, 13 ];
        fi;
        nppairs := [ ];
        for n in dims do
            for p in chars do
                if p^n < 256 then
                    Add( nppairs, [ n, p ] );
                fi;
            od;
        od;
    fi;

    # Make the list of groups
    grplist := [ ];

    # Loop through the allowable (n,p) pairs
    for np in nppairs do
        n := np[ 1 ];
        p := np[ 2 ];

        # Loop through the group descriptions
        for k in [1..Length( IrredSolGroupList[ n ][ p ] )] do
            gp := [ ];
            desc := IrredSolGroupList[ n ][ p ][ k ];

            # Check if the description satisfies the special case criteria.
            # If it does, create the group
            if     ( not IsBound( sizes ) or desc[1] in sizes )
               and ( not IsBound( linprim ) or (desc[2] = 0) = linprim )
               and ( not IsBound( minblockdims ) or desc[2] in minblockdims )
            then
                gp := IrreducibleSolvableGroupMS( n, p, k );
            fi;

            # Now see if the group (if created) satisfies the other criteria.
            # If it does, add it to the list
            if gp <> [ ] then
                passtest := true;
                i := 1;
                while passtest and i <= Length( funs ) do
                    passtest := funs[ i ]( gp ) = vals[ i ]
                                or ( IsList( vals[ i ] )
                                     and funs[ i ]( gp ) in vals[ i ] );
                    i := i + 1;
                od;
                if passtest then
                    Add( grplist, gp );
                fi;
            fi;
        od;
    od;

    return grplist;
end); # AllIrreducibleSolvableGroups( fun1, val1, fun2, val2, ... )
    

#############################################################################
##
#F  OneIrreducibleSolvableGroup(...)  
##                                     extract one irreducible solvable group
##
InstallGlobalFunction(OneIrreducibleSolvableGroup, function ( arg )
    local
        dims,            # dimensions
        chars,           # characteristics
        sizes,           # sizes
        linprim,         # linearly primitive flag
        minblockdims,    # minimal block dimensions
        funs,            # other functions requested by caller
        vals,            # their values
        i,               # counter through arg
        nppairs,         # (n,p) pairs such that p^n < 256
        np,              # counter through (n,p) pairs
        n,               # n
        p,               # p
        k,               # counter through group descriptions for GL(n,p)
        desc,            # compact description of the kth group in GL(n,p)
        gp,              # the group to be returned
        passtest;        # boolean flag

    # Initialize a few things
    funs := [ ];
    vals := [ ];

    # Loop through the arguments
    for i in [1..Length(arg)/2] do

        # Special case for Dimension
        if arg[2*i-1] in [ Dimension, DimensionOfMatrixGroup, DegreeOfMatrixGroup] then
            if not IsList( arg[2*i] ) then
                arg[2*i] := [ arg[2*i] ];
            fi;
            dims := [ ];
            for n in arg[2*i] do
                if n in [ 2, 3, 4, 5, 6, 7 ] then
                    Add( dims, n );
                else
                    Print( "#W  OneIrreducibleSolvableGroup: ",
                           "n = ", n, " outside range of library\n" );
                fi;
            od;
            if dims = [ ] then
                Error( "all Dimension arguments outside range of library" );
            fi;

        # Special case for CharFFE
        elif arg[2*i-1] = Characteristic  then
            if not IsList( arg[2*i] ) then
                arg[2*i] := [ arg[2*i] ];
            fi;
            chars := [ ];
            for p in arg[2*i] do
                if p in [ 2, 3, 5, 7, 11, 13 ] then
                    Add( chars, p );
                else
                    Print( "#W  OneIrreducibleSolvableGroup: ",
                           "p = ", p, " outside range of library\n" );
                fi;
            od;
            if chars = [ ] then
                Error( "all Characteristic arguments outside range of library" );
            fi;

        # Special case for Size
        elif arg[2*i-1] = Size then
            if IsList( arg[2*i] ) then
                sizes := arg[2*i];
            else
                sizes := [ arg[2*i] ];
            fi;

        # Special case for IsPrimitiveMatrixGroup
        elif arg[2*i-1] in [ IsLinearlyPrimitive, IsPrimitiveMatrixGroup] then
            if IsBool( arg[2*i] ) then
                linprim := arg[2*i];
            else
                Error( "IsPrimitiveMatrixGroup argument must be boolean" );
            fi;

        # Special case for MinimalBlockDimension
        elif arg[2*i-1] = MinimalBlockDimension then
            if IsList( arg[2*i] ) then
                minblockdims := arg[2*i];
            else
                minblockdims := [ arg[2*i] ];
            fi;

        # General case
        elif IsFunction( arg[2*i-1] ) then
            Add( funs, arg[2*i-1] );
            Add( vals, arg[2*i] );
        else
            Error( "<fun",i,"> must be a function" );
        fi;
    od;

    # Find the allowable (n,p) pairs
    if not IsBound( dims ) and not IsBound( chars ) then
        nppairs := [ [2,2], [2,3], [2,5], [2,7], [2,11], [2,13],
                     [3,2], [3,3], [3,5],
                     [4,2], [4,3],
                     [5,2], [5,3],
                     [6,2],
                     [7,2] ];
    elif IsBound( dims ) and IsBound( chars ) then
        nppairs := [ ];
        for n in dims do
            for p in chars do
                if p^n < 256 then
                    Add( nppairs, [ n, p ] );
                else
                    Print( "#W  OneIrreducibleSolvableGroup: n = ", n,
                           ", p = ", p, " outside range of library\n" );
                fi;
            od;
        od;
        if nppairs = [ ] then
            Error( "none of the specified (n,p) pairs satisfy p^n < 256" );
        fi;
    else
        if not IsBound( dims ) then
            dims := [ 2, 3, 4, 5, 6, 7 ];
        else
            chars := [ 2, 3, 5, 7, 11, 13 ];
        fi;
        nppairs := [ ];
        for n in dims do
            for p in chars do
                if p^n < 256 then
                    Add( nppairs, [ n, p ] );
                fi;
            od;
        od;
    fi;

    # Find the group.
    # Loop through the allowable (n,p) pairs
    for np in nppairs do
        n := np[ 1 ];
        p := np[ 2 ];

        # Loop through the group descriptions
        for k in [1..Length( IrredSolGroupList[ n ][ p ] )] do
            gp := [ ];
            desc := IrredSolGroupList[ n ][ p ][ k ];

            # Check if the description satisfies the special case criteria.
            # If it does, create the group
            if     ( not IsBound( sizes ) or desc[1] in sizes )
               and ( not IsBound( linprim ) or (desc[2] = 0) = linprim )
               and ( not IsBound( minblockdims ) or desc[2] in minblockdims )
            then
                gp := IrreducibleSolvableGroupMS( n, p, k );
            fi;

            # Now see if the group (if created) satisfies the other criteria.
            # If it does, return it
            if gp <> [ ] then
                passtest := true;
                i := 1;
                while passtest and i <= Length( funs ) do
                    passtest := funs[ i ]( gp ) = vals[ i ]
                                or ( IsList( vals[ i ] )
                                     and funs[ i ]( gp ) in vals[ i ] );
                    i := i + 1;
                od;
                if passtest then
                    return gp;
                fi;
            fi;
        od;
    od;

    return false;
end); # OneIrreducibleSolvableGroup( fun1, val1, fun2, val2, ... )

#############################################################################
##
#E
##

