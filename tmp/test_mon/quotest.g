#############################################
## Testing generic quotients of semigroups
## check that this doesn't trip on fp semigroups
###########################################
## O4 test. Note, O4 and M4 have only Rees congruences
a := Transformation([1,1,3,4]);
b := Transformation([2,2,3,4]);
c := Transformation([1,2,2,4]);
d := Transformation([1,3,3,4]);
e := Transformation([1,2,3,3]);
f := Transformation([1,2,4,4]);

O4 := Semigroup([a,b,c,d,e,f]);
eO4 := Elements(O4);
congO4 := SemigroupCongruenceByGeneratingPairs(O4, [[eO4[5],eO4[8]]]);
QO4 := O4/congO4;
One(eO4[2]); 														# Transformation( [ 1 .. 4 ] ) 
QO4gens := GeneratorsOfSemigroup(QO4);
eqo4 := Elements(QO4); 
time;																		# 6030
Size(QO4);															#	13

M4 := Monoid([a,b,c,d,e,f]);
eM4 := Elements(M4);
congM4 := SemigroupCongruenceByGeneratingPairs(M4, [[eM4[6],eM4[9]]]);
QM4 := M4/congM4;
One(a);					
One(QM4);
One(eM4[2]);												
eqm4 := Elements(QM4);
time;																		# 720
Size(QM4);															# 2
One(eqm4[2]);

# SemigroupCongruenceIteratorData test
EquivalenceRelationPartition(congO4);
e := EquivalenceClassOfElement(congO4, Transformation([1,1,1,1]));
it:= Iterator(e);
IsDoneIterator(it);											# false
NextIterator(it);												# Transformation( [ 1, 1, 1, 1 ] )

en := Enumerator(e);
Length(en);

######################################################################
#
#	TestswithIsReesCongruence and IsReesCongruenceSemigroup
#
######################################################################

# a small example
f := FreeSemigroup( "a" , "b" , "c" );;
x := GeneratorsOfSemigroup( f );;
a := x[1];; b:=x[2];; c:=x[3];;
r := [ [a*a,a] , [b*b,b] , [c*c,c] ];;
s := Abelianization( f/r );;
x := GeneratorsOfSemigroup( s );;
a:=x[1];; b:=x[2];; c:=x[3];;
IsFinite(s);
cong := ANonReesCongruenceOfSemigroup( s );
EquivalenceRelationPartition( cong );
# [ [ a, b, a*b ], [ c*b, c*a, a*c*b ] ]
IsReesCongruenceSemigroup( s );
# false

