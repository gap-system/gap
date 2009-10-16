
# compute orders
om  := OrderMaximal( f );
oe := OrderEquationOrder( om );
os := false;
os := OrderShort( om );
if os = false then os:=om; fi;
os := OrderSimplify(OrderLLL(os));

# compute units
un := Concatenation( [OrderTorsionUnit(os)], OrderUnitsFund( os ) );
un := List( un, x -> EltToList( EltMove( x, oe ) ) );

# print them
PrintTo(outt," KANTVars := [ \n");
for i in [1..Length(un)] do
    AppendTo(outt,un[i],",\n");
od;
AppendTo(outt,"];");

