
om := OrderMaximal( f );
oe := OrderEquationOrder( om );
os := OrderShort(om); if os = false then os:=om; fi;
os := OrderSimplify(OrderLLL(os)); 

un := Concatenation( [OrderTorsionUnit(os)], OrderUnitsFund( os ) );
un := List( un, x -> EltToList( EltMove( x, oe ) ) );

# print units
PrintTo(outt," KANTVars := [ \n");
for i in [1..Length(un)] do
    AppendTo(outt,un[i],",\n");
od;
AppendTo(outt,"]; \n \n");

# print exponents
AppendTo(outt," KANTVart := [ \n");
for i in [1..Length(elms)] do
    a := Elt( oe, elms[i] );
    b := EltMove( a, os );
    c := EltUnitDecompose( b, "expons" );
    AppendTo(outt,c,",\n");
od;
AppendTo(outt,"]; \n \n");

