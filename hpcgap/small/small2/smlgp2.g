#############################################################################
##
#W  smlgp2.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the reading and selection functions for the groups of
##  size up to 1000 except 512, 768 and size a product of more then 3 primes
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("small2","2.0");

#############################################################################
##
#F SMALL_AVAILABLE_FUNCS[ 2 ]
##
SMALL_AVAILABLE_FUNCS[ 2 ] := function( size )
    local pos, numbs;

    if size > 1000 or size in [ 512, 768 ] then 
        return fail;
    fi;

    pos := PositionSet( [ 256, 384, 576, 640, 864, 896, 960 ], size );
    if pos <> fail then
        # the groups are split into files with 2500 groups each
        numbs := [ 56092, 20169, 8681, 21541, 4725, 19349, 11394 ];
        return rec( func   := 10, 
                    lib    := 2,
                    number := numbs[ pos ] );
    fi;

    if size in [  64,  96, 128, 160, 192, 240, 288, 320, 336, 400, 416, 432,
                 448, 480, 486, 504, 544, 600, 624, 648, 672, 704, 720, 729,
                 800, 816, 832, 880, 912, 928, 936, 972 ] then
        # every of these sizes is contained in a seperate file
        return rec( func := 8,
                    lib  := 2 );
    fi;

    # the other sizes are collected into 24 files
    return rec( func := 9,
                lib  := 2,
                file := PositionSorted( [ 80, 144, 200, 224, 272, 324, 352,
                          378, 444, 496, 528, 560, 608, 666, 702, 736, 756,
                          784, 810, 840, 888, 930, 984, 1000 ], size ) );
end;

#############################################################################
##
#F  CODE_SMALL_GROUP_FUNCS[ 8 .. 9 ]( size, i, inforec )
##
##  fetches the code of the group [ size, i ] from the library data and 
##  loads the data if necessary
CODE_SMALL_GROUP_FUNCS[ 8 ] := function( size, i, inforec )
    local g;

    if not IsBound( SMALL_GROUP_LIB[ size ] ) then
        if inforec.func = 8 then
            ReadSmallLib( "sml", inforec.lib, size, [ ] );
        else
            ReadSmallLib( "col", inforec.lib, inforec.file, [ ] );
        fi;
    fi;

    if i > Length( SMALL_GROUP_LIB[ size ] ) then
        Error( "there are just ", Length( SMALL_GROUP_LIB[ size ] ),
               " groups of size ", size );
    fi;

    return SMALL_GROUP_LIB[ size ][ i ];
end;
CODE_SMALL_GROUP_FUNCS[ 9 ] := CODE_SMALL_GROUP_FUNCS[ 8 ];

#############################################################################
##
#F  CODE_SMALL_GROUP_FUNCS[ 10 ]( size, i, inforec )
##
CODE_SMALL_GROUP_FUNCS[ 10 ] := function( size, i, inforec )
    local g, file, pos;

    if i > inforec.number then
        Error( "there are just ", inforec.number, " groups of size ", size );
    fi;

    if not IsBound( SMALL_GROUP_LIB[ size ] ) then
        SMALL_GROUP_LIB[ size ] := AtomicList([ ]);
    fi;

    file := QuoInt( i + 2499, 2500 );
    pos  := i - ( file - 1 ) * 2500;
    if not IsBound( SMALL_GROUP_LIB[ size ][ file ] ) then
        ReadSmallLib( "sml", inforec.lib, size, [ file ] );
    fi;

    return SMALL_GROUP_LIB[ size ][ file ][ pos ];
end;

#############################################################################
##
#F  SMALL_GROUP_FUNCS[ 8 .. 10 ]( size, i, inforec )
##
##
SMALL_GROUP_FUNCS[ 8 ] := function( size, i, inforec )
    local code;

    code := CODE_SMALL_GROUP_FUNCS[ inforec.func ]( size, i, inforec );
    if IsInt( code ) then
        return PcGroupCode( code, size );
    fi;
    return GroupByGenerators( code );
end;
SMALL_GROUP_FUNCS[ 9 ] := SMALL_GROUP_FUNCS[ 8 ];
SMALL_GROUP_FUNCS[ 10 ] := SMALL_GROUP_FUNCS[ 8 ];

#############################################################################
##                            
#F SELECT_SMALL_GROUPS_FUNCS[8..10]( funcs, vals, inforec, all, id, idList )
##     
SELECT_SMALL_GROUPS_FUNCS[ 8 ] := function( size, funcs, vals, inforec, all,
                                            id, idList )
    local cand, i, j, evalfuncs, evalvals, func, val, prop, g, ok, result,
          expand, intersection, difference, union, p, tmp, os;

    # to mention, which groups will fullfill the properties, lists of this
    # structure are used: [ 1, -3, 5, 8, -11 ] means [ 1,2,3, 5, 8,9,10,11]

    expand := function( cand )
        local res, i;

        res := [];
        for i in [ 1 .. Length( cand ) ] do
            if cand[ i ] > 0 then 
                Add( res, cand[ i ] );
            else
                Append( res, [ cand[ i - 1 ] + 1 .. -cand[ i ] ] );
            fi;
        od;
        return res;
    end;

    intersection := function( l1, l2 )
        local p1, p2, s1, s2, e1, e2, rs, re, res;

        res := [ ];
        p1 := 1; p2 := 1;
        while p1 <= Length( l1 ) and p2 <= Length( l2 ) do
            if not IsBound( s1 ) then
                s1 := l1[ p1 ];
                if IsBound( l1[ p1 + 1 ] ) and l1[ p1 + 1 ] < 0 then
                    e1 := - l1[ p1 + 1 ];
                    p1 := p1 + 1;
                else
                    e1 := s1;
                fi;
            fi;
            if not IsBound( s2 ) then
                s2 := l2[ p2 ];
                if IsBound( l2[ p2 + 1 ] ) and l2[ p2 + 1 ] < 0 then
                    e2 := - l2[ p2 + 1 ];
                    p2 := p2 + 1;
                else
                    e2 := s2;
                fi;
            fi;
            if e1 < s2 then
                p1 := p1 + 1; Unbind( s1 );
            elif e2 < s1 then
                p2 := p2 + 1; Unbind( s2 );
            else
                rs := Maximum( s1, s2 );
                re := Minimum( e1, e2 );
                Add( res, rs );
                if re <> rs then
                    Add( res, -re );
                fi;
                if e1 < e2 then
                    p1 := p1 + 1; Unbind( s1 );
                else
                    p2 := p2 + 1; Unbind( s2 );
                fi;
            fi;
        od;
        return res;
    end;

    difference := function( l1, l2 )
        local p1, p2, s1, s2, e1, e2, re, res;

        res := [ ];
        p1 := 1; p2 := 1;
        while p1 <= Length( l1 ) do
            if not IsBound( s1 ) then
                s1 := l1[ p1 ];
                if IsBound( l1[ p1 + 1 ] ) and l1[ p1 + 1 ] < 0 then
                    e1 := - l1[ p1 + 1 ];
                    p1 := p1 + 1;
                else
                    e1 := s1;
                fi;
            fi;
            if not IsBound( s2 ) then
                if IsBound( l2[ p2 ] ) then
                    s2 := l2[ p2 ];
                    if IsBound( l2[ p2 + 1 ] ) and l2[ p2 + 1 ] < 0 then
                        e2 := - l2[ p2 + 1 ];
                        p2 := p2 + 1;
                    else
                        e2 := s2;
                    fi;
                else
                    s2 := AbsInt( l1[ Length( l1 ) ] ) + 1;
                    e2 := s2;
                fi;
            fi;

            if s1 < s2 then
                Add( res, s1 );
                re := Minimum( e1, s2 - 1 );
                if re > s1 then
                    Add( res, -re );
                fi;
                if e1 <= e2 then
                    p1 := p1 + 1; Unbind( s1 );
                else
                    s1 := e2 + 1; p2 := p2 + 1; Unbind( s2 );
                fi;
            else # s2 <= s1
                if e1 <= e2 then
                    p1 := p1 + 1; Unbind( s1 );
                else # e2 < e1
                    s1 := Maximum( e2 + 1, s1 ); p2 := p2 + 1; Unbind( s2 );
                fi;
            fi;
        od;
        return res;
    end;

    union := function( l1, l2 )
        local p1, p2, s1, s2, e1, e2, rs, re, res;

        res := [ ];
        p1 := 1; p2 := 1;
        while true do
            if not IsBound( s1 ) then
                if IsBound( l1[ p1 ] ) then
                    s1 := l1[ p1 ];
                    p1 := p1 + 1;
                    if IsBound( l1[ p1 ] ) and l1[ p1 ] < 0 then
                        e1 := - l1[ p1 ];
                        p1 := p1 + 1;
                    else 
                        e1 := s1;
                    fi;
                fi;
            fi;
            if not IsBound( s2 ) then
                if IsBound( l2[ p2 ] ) then
                    s2 := l2[ p2 ];
                    p2 := p2 + 1;
                    if IsBound( l2[ p2 ] ) and l2[ p2 ] < 0 then
                        e2 := - l2[ p2 ];
                        p2 := p2 + 1;
                    else
                        e2 := s2;
                    fi;
                fi;
            fi;
            if not IsBound( s1 ) and not IsBound( s2 ) then
                return res;
            fi;
            if not IsBound( s1 ) then
                rs := s2; re := e2; Unbind( s2 );
            elif not IsBound( s2 ) then
                rs := s1; re := e1; Unbind( s1 );
            elif e1 < s2 - 1 then
                rs := s1; re := e1; Unbind( s1 );
            elif e2 < s1 - 1 then
                rs := s2; re := e2; Unbind( s2 );
            elif e1 < e2 then
                if s1 < s2 then
                    s2 := s1;
                fi;
                Unbind( s1 );
            else
                if s2 < s1 then
                    s1 := s2;
                fi;
                Unbind( s2 );
            fi;
            if IsBound( rs ) then
                Add( res, rs );
                if re <> rs then
                    Add( res, -re );
                fi;
                Unbind( rs );
            fi;
        od;
    end;

    if not IsBound( inforec.number ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ inforec.func ]( size, inforec);
    fi;

    if not IsBound( PROPERTIES_SMALL_GROUPS[ size ] ) then 
        ReadSmallLib( "prop", inforec.lib, size, [ ] );
    fi;
    
    atomic PROPERTIES_SMALL_GROUPS[ size ] do
    
    cand := [ 1, -inforec.number ];

    evalfuncs := [ ];
    evalvals := [ ];
    for i in [ 1 .. Length( funcs ) ] do
        func := funcs[ i ];
        val := vals[ i ];
        
        if func in [ IsAbelian, IsNilpotent,IsNilpotentGroup,IsSupersolvable,
                     IsSupersolvableGroup, IsSolvable, IsSolvableGroup ] then
            if not val in [ [ true ], [ false ] ] then
               Error("SelectSmallGroups: Use Test-Funcs with true or false");
            fi;
            if ( func = IsAbelian and not
               IsBound( PROPERTIES_SMALL_GROUPS[ size ].isAbelian ) ) or
               ( func in [ IsNilpotent, IsNilpotentGroup ] and not
               IsBound( PROPERTIES_SMALL_GROUPS[ size ].isNilpotent)) or
               ( func in [ IsSupersolvable, IsSupersolvableGroup ] and not
               IsBound( PROPERTIES_SMALL_GROUPS[ size ].isSupersolvable )) or
               ( func in [ IsSolvable, IsSolvableGroup ] and not
               IsBound( PROPERTIES_SMALL_GROUPS[ size ].isSolvable )) then
                 if val = [ false ] then
                   if all then
                     return [ ];
                   fi;
                   return fail;
                 # else
                    # all groups of this size have the property
                 fi;
            else
                if func = IsAbelian then
                    prop := PROPERTIES_SMALL_GROUPS[ size ].isAbelian;
                elif func in [ IsNilpotent, IsNilpotentGroup ] then
                    prop := PROPERTIES_SMALL_GROUPS[ size ].isNilpotent;
                elif func in [ IsSupersolvable, IsSupersolvableGroup ] then
                    prop := PROPERTIES_SMALL_GROUPS[ size ].isSupersolvable;
                else
                    prop := PROPERTIES_SMALL_GROUPS[ size ].isSolvable;
                fi;
                if val = [ true ] then
                    cand := intersection( cand, prop );
                else
                    cand := difference( cand, prop );
                fi;
            fi;

        elif func in [ PClassPGroup, LGLength ] then
            tmp := [ ];
            for j in val do
                p := Position(
                      PROPERTIES_SMALL_GROUPS[ size ].lgLength.lgLength, j );
                if p <> fail then
                    tmp := union( tmp,
                         PROPERTIES_SMALL_GROUPS[ size ].lgLength.pos[ p ] );
                fi;
            od;
            cand := intersection( cand, tmp );

        elif func in [ RankPGroup, FrattinifactorSize,FrattinifactorId ] then
            if PROPERTIES_SMALL_GROUPS[ size ].frattFacs.frattFacs = [ ] then
                # the data has to be uncompressed, and all groups of size
                # size are frattinifree
                PROPERTIES_SMALL_GROUPS[ size ].frattFacs.frattFacs :=
                    List( [ 1 .. inforec.number ], x -> [ size, x ] );
                PROPERTIES_SMALL_GROUPS[ size ].frattFacs.pos := 
                    List( [ 1 .. inforec.number ], x -> [ x ] );
            elif IsInt( PROPERTIES_SMALL_GROUPS[ size ].
                                             frattFacs.frattFacs[ 1 ] ) then
                # the data from the library files has to be uncompressed
                os := Product( Set( FactorsInt( size ) ) );
                os := DivisorsInt( size / os ) * os;
                p := Length( os );
                tmp := [ ];
                for j in [ 1 .. Length( PROPERTIES_SMALL_GROUPS[ size ].
                                                  frattFacs.frattFacs ) ] do
                    Add( tmp, [ os[ PROPERTIES_SMALL_GROUPS[ size ].frattFacs
                     .frattFacs[ j ] mod p ], QuoInt( PROPERTIES_SMALL_GROUPS
                     [ size ].frattFacs.frattFacs[ j ], p ) ] );
                od;
                PROPERTIES_SMALL_GROUPS[ size ].frattFacs.frattFacs := tmp;
                PROPERTIES_SMALL_GROUPS[ size ].frattFacs.pos[ 1 ] := [ 1,
                       -PROPERTIES_SMALL_GROUPS[ size ].frattFacs.pos[ 1 ] ];
                for j in [ 2 .. Length( PROPERTIES_SMALL_GROUPS[ size ].
                                                  frattFacs.frattFacs ) ] do
                    PROPERTIES_SMALL_GROUPS[ size ].frattFacs.pos[ j ] := [
                      -PROPERTIES_SMALL_GROUPS[size].frattFacs.pos[j-1][2]+1,
                       -PROPERTIES_SMALL_GROUPS[ size ].frattFacs.pos[ j ] ];
                od;
                for j in [ -PROPERTIES_SMALL_GROUPS[ size ].frattFacs.pos[
                    Length( PROPERTIES_SMALL_GROUPS[size].frattFacs.pos )][2]
                        + 1 .. inforec.number ] do
                    Add( PROPERTIES_SMALL_GROUPS[ size ].frattFacs.frattFacs,
                         [ size, j ] );
                    Add( PROPERTIES_SMALL_GROUPS[size].frattFacs.pos,[ j ] );
                od;
            fi;

            if func = RankPGroup then
                if not IsPrimePowerInt( size ) then 
                    Error( "SelectSmallGroups with RankPGroup: size ", 
                           size, " is no primepower" );
                else
                    func := FrattinifactorSize;
                    j := FactorsInt( size )[ 1 ];
                    val := List( val, x -> j^x );
                fi;
            fi;
            tmp := [ ];
            if func = FrattinifactorId then
                for j in val do
                    p := Position(
                      PROPERTIES_SMALL_GROUPS[size].frattFacs.frattFacs, j );
                    if p <> fail then
                        tmp := union( tmp,
                          PROPERTIES_SMALL_GROUPS[ size ].frattFacs.pos[p] );
                    fi;
                od;
            else
                # func = FrattinifactorSize
                for j in [ 1 .. Length( PROPERTIES_SMALL_GROUPS[size].
                                                   frattFacs.frattFacs ) ] do
                    if PROPERTIES_SMALL_GROUPS[size].
                                    frattFacs.frattFacs[ j ][ 1 ] in val then
                        tmp := union( tmp, PROPERTIES_SMALL_GROUPS[size].
                                                        frattFacs.pos[ j ] );
                    fi;
                od;
            fi;
            cand := intersection( cand, tmp );

        else
            Add( evalfuncs, func );
            Add( evalvals, val );
        fi;
    od;
    if evalfuncs = [ ] and all and id then
        return List( expand( cand ), x -> [ size, x ] );
    fi;

    result := [];
    for i in expand( cand ) do
        if idList = fail or i in idList then
            g := SMALL_GROUP_FUNCS[ inforec.func ]( size, i, inforec );
            SetIdGroup( g, [ size, i ] );
            ok := true;
            for j in [ 1 .. Length( evalfuncs ) ] do
                ok := ok and ( evalfuncs[ j ]( g ) in evalvals[ j ] );
            od;
            if all and id and ok then
                Add( result, [ size, i ] );
            elif all and ok then
                Add( result, g );
            elif ok then
                return g;
            fi;
        fi;
    od;

    if all then
        return result;
    else
        return fail;
    fi;
    
    od; # atomic PROPERTIES_SMALL_GROUPS[ size ] do
end;

SELECT_SMALL_GROUPS_FUNCS[ 9 ] := SELECT_SMALL_GROUPS_FUNCS[ 8 ];
SELECT_SMALL_GROUPS_FUNCS[ 10 ] := SELECT_SMALL_GROUPS_FUNCS[ 8 ];

#############################################################################
## 
#F  NUMBER_SMALL_GROUPS_FUNCS[ 8 .. 9 ]( size, inforec )
## 
NUMBER_SMALL_GROUPS_FUNCS[ 8 ] := function( size, inforec )
   
    if not IsBound( SMALL_GROUP_LIB[ size ] ) then
        CODE_SMALL_GROUP_FUNCS[ inforec.func ]( size, 1, inforec );
    fi;

    inforec.number := Length( SMALL_GROUP_LIB[ size ] );
    return inforec;
end;
NUMBER_SMALL_GROUPS_FUNCS[ 9 ] := NUMBER_SMALL_GROUPS_FUNCS[ 8 ];
