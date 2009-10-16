
# compute basis of maximal order
o := OrderMaximal( f );
b := List( Basis( o ), EltToList );

# print it to file
PrintTo(outt," KANTVars := [ \n");
for i in [1..Length(b)] do
    AppendTo(outt,b[i],",\n");
od;
AppendTo(outt,"];");

