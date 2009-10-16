
# compute orders
om := OrderMaximal( f );
oe := OrderEquationOrder( om );
os := OrderShort( om ); 
if os = false then os:=om; fi;
os := OrderSimplify(OrderLLL(os)); 

# compute units
un := Concatenation( [OrderTorsionUnit(os)], OrderUnitsFund( os ) );
un := List( un, x -> EltToList( EltMove( x, oe ) ) );

# compute elements with norm
nr := OrderNormEquation( os, norm, "all", "abs" );
nr := List( nr, x -> EltToList( EltMove( x, oe ) ) );

# print units
PrintTo(outt," KANTVars := [ \n");
for i in [1..Length(un)] do
    AppendTo(outt,un[i],",\n");
od;
AppendTo(outt,"];");

# print norm elements
AppendTo(outt," KANTVart := [ \n");
for i in [1..Length(nr)] do
    AppendTo(outt,nr[i],",\n");
od;
AppendTo(outt,"];");

