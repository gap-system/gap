# compute factors of poly defined by coeffs over Q_f
o := Order( f );
ox := PolyAlg( o );

for i in [1..Length(coeffs)] do
    coeffs[i] := Elt( o, coeffs[i] );
od;

pol := Poly( ox, coeffs );
faktoren := PolyFactor( pol );
zeit := time;

# print it to file
PrintTo(outt," KANTVars := [ \n");
for i in [1..Length(faktoren)] do
    for j in [1..faktoren[i][2]] do
        AppendTo(outt,PolyToList( faktoren[i][1] ),",\n");
    od;
od;
AppendTo(outt,zeit);
AppendTo(outt,"];");
