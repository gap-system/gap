#############################################################################
##
#F  FromTheLeftCollector_Power  . . . . . . . . . . . . . . . . . . . . . .  
##
#BindGlobal( "FromTheLeftCollector_Power", function( coll, w, e )
#
#    if e < 0 then
#        w := FromTheLeftCollector_Inverse( coll, w );
#        e := -e;
#    fi;
#
#    return BinaryPower( coll, w, e );
#end );
#
#############################################################################
##
#F  ProductAutomorphisms  . . . . . . . . . . . . . . . . . . . . . . . . .  
##
#BindGlobal( "ProductAutomorphisms", function( coll, alpha, beta )
#    local   ngens,  gamma,  i,  w,  ev,  g;
#    ngens := NumberGeneratorsOfRws( coll );
#    gamma := [];
#    for i in [1..ngens] do
#        if IsBound( alpha[i] ) then
#            w := alpha[i];
#            ev := ListWithIdenticalEntries( ngens, 0 );
#            for g in [1,3..Length(w)-1] do
#                if w[g+1] <> 0 then
#                    CollectWordOrFail( coll, ev,
#                            FromTheLeftCollector_Power( 
#                                    coll, beta[ w[g] ], w[g+1] ) );
#                fi;
#            od;
#            gamma[i] := ObjByExponents( coll, ev );
#        fi;
#    od;
#    return gamma;
#end );

#############################################################################
##
#F  PowerAutomorphism . . . . . . . . . . . . . . . . . . . . . . . . . . .  
##
#BindGlobal( "PowerAutomorphism", function( coll, g, e )
#    local   n,  a,  power,  h,  ipower;
#    
#    n := NumberGeneratorsOfRws( coll );
#    
#    # initialise automorphism
#    a := [];
#    power := [];
#    for h in [g+1..n] do
#        if e > 0 then 
#            if IsBound( coll![ PC_CONJUGATES][h] ) and
#                       IsBound( coll![ PC_CONJUGATES ][h][g] ) then
#                a[h] := coll![ PC_CONJUGATES ][h][g];
#            else
#                a[h] := [h,1];
#            fi;
#        else
#            if IsBound( coll![ PC_CONJUGATESINVERSE ][h] ) and
#                       IsBound( coll![ PC_CONJUGATESINVERSE ][h][g] ) then
#                a[h] := coll![ PC_CONJUGATESINVERSE ][h][g];
#            else
#                a[h] := [h,1];
#            fi;
#        fi;
#        power[h] := [h,1];    
#    od;
#    if e < 0 then
#        e := -e;
#    fi;
#
#    while e > 0 do
#        if e mod 2 = 1 then
#            power := ProductAutomorphisms( coll, power, a );
#        fi;
#        e := Int( e / 2 );
#        if e > 0 then
#            a := ProductAutomorphisms( coll, a, a );
#        fi;
#    od;
#    ipower := [];
#    for h in [g+1..n] do
#        ipower[h] := FromTheLeftCollector_Inverse( coll, power[h] );
#    od;
#
#    return [ power, ipower ];
#end );
#
