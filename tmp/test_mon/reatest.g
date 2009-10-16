#############################################################################
##
##                      SEMIGROUP ENUMERATOR
##
a:= Transformation([2, 3, 4, 1]);
b:= Transformation([2, 2, 3, 4]);
s:= Semigroup(a, b);
e:= Enumerator(s);
e[56];
Length(e);
Size(s);

s := Semigroup(Transformation([2,3,4,1]), Transformation([2,1,4,3]), 
Transformation([3,2,1,1])); 

it := Iterator(s);
itl := Iterator(s: Side := "left");
itr := Iterator(s: Side := "right");
while not IsDoneIterator(it) do
        n := NextIterator(it); nl := NextIterator(itl); nr :=
NextIterator(itr);
        Print("n = ", n," nl = ",nl," nr = ",nr,"\n\n");
od;


#############################################################################
##
##                      INFINITE EXAMPLE
##
s:= Semigroup(2,3);
i:= Iterator(s);

f:= function(n)
        local x, s, i;
        s:= Semigroup(2, 3);
        i:= Iterator(s);
        for x in i do
                if x>n then
                        return x;
                fi;
        od;
end;

f(10);
f(32);
f(478653297431789321);
FactorsInt(f(478653297431789321));

#############################################################################
##
##                      IDEAL EXAMPLES
##
a:= Transformation([2, 3, 4, 1]);
b:= Transformation([2, 2, 3, 4]);
s:= Semigroup(a, b);
id:= RightMagmaIdealByGenerators(s, [Transformation([1, 2, 3, 4])]);
enum:= Enumerator(id);
Length(enum);

s:= Semigroup(a, b);
id:= RightMagmaIdealByGenerators(s, [Transformation([1, 2, 3, 4])]);
iter:= Iterator(id);
n:= 0;
for x in iter do
        n:= n+1;
od;
n;

a:= Transformation([2, 3, 4, 1]);
b:= Transformation([2, 2, 3, 4]);
s:= Semigroup(a, b);
id:= LeftMagmaIdealByGenerators(s, [Transformation([1, 2, 3, 4])]);
enum:= Enumerator(id);
Length(enum);

s:= Semigroup(a, b);
id:= LeftMagmaIdealByGenerators(s, [Transformation([1, 2, 3, 4])]);
iter:= Iterator(id);
n:= 0;
for x in iter do
        n:= n+1;
od;
n;

a:= Transformation([2, 3, 4, 1]);
b:= Transformation([2, 2, 3, 4]);
s:= Semigroup(a, b);
id:= MagmaIdealByGenerators(s, [Transformation([1, 2, 3, 4])]);
enum:= Enumerator(id);
Length(enum);

s:= Semigroup(a, b);
id:= MagmaIdealByGenerators(s, [Transformation([1, 2, 3, 4])]);
iter:= Iterator(id);
n:= 0;
for x in iter do
        n:= n+1;
od;
n;

id:= RightMagmaIdealByGenerators(s, [Transformation([2, 2, 2, 2])]);
iter:= Iterator(id);
n:= 0;
for x in iter do
        n:= n+1;
od;
n;

a:= Transformation([2, 3, 4, 1]);
b:= Transformation([2, 2, 3, 4]);
s:= Semigroup(a, b);
id1:= RightMagmaIdealByGenerators(s, [Transformation([2, 2, 4, 4])]);
id2:= LeftMagmaIdealByGenerators(s, [Transformation([2, 2, 4, 4])]);
id3:= MagmaIdealByGenerators(s, [Transformation([2, 2, 4, 4])]);

Elements(id1);
Elements(id2);
Elements(id3);

Transformation([4, 4, 2, 2]) in id1;
Transformation([4, 4, 2, 2]) in id2;
Transformation([4, 4, 2, 2]) in id3;

Transformation([4, 4, 2, 1]) in id1;
Transformation([4, 4, 2, 1]) in id2;
Transformation([4, 4, 2, 1]) in id3;

#############################################################################
##
##                      GREENS RELATIONS EXAMPLES
##
a:= Transformation([2, 3, 4, 1]);
b:= Transformation([2, 2, 3, 4]);
s:= Semigroup(a, b);
R:= GreensRRelation(s);
L:= GreensLRelation(s);
J:= GreensJRelation(s);
H:= GreensHRelation(s);
D:= GreensDRelation(s);
c1:= EquivalenceClassOfElement(R, Transformation([2, 2, 4, 4]));;
c2:= EquivalenceClassOfElement(R, Transformation([3, 3, 2, 2]));;
c3:= EquivalenceClassOfElement(R, Transformation([4, 4, 4, 4]));;
c4:= EquivalenceClassOfElement(L, Transformation([1, 3, 3, 1]));;
c5:= EquivalenceClassOfElement(L, Transformation([2, 3, 3, 2]));;
c6:= EquivalenceClassOfElement(J, Transformation([2, 3, 3, 2]));;
c7:= EquivalenceClassOfElement(J, Transformation([1, 2, 2, 3]));;
c8:= EquivalenceClassOfElement(H, Transformation([3, 3, 2, 2]));;
c9:= EquivalenceClassOfElement(H, Transformation([3, 2, 2, 3]));;
c10:= EquivalenceClassOfElement(D, Transformation([2, 3, 3, 2]));;
c11:= EquivalenceClassOfElement(D, Transformation([1, 2, 2, 3]));;

IsGreensLessThanOrEqual(c1, c2);
IsGreensLessThanOrEqual(c2, c1);
IsGreensLessThanOrEqual(c1, c3);
IsGreensLessThanOrEqual(c3, c1);

elm:= Transformation([2, 2, 3, 3]);
elm in c1;
elm in c2;
elm in c3;
elm in c4;
elm in c5;
elm in c6;
elm in c7;
elm in c8;
elm in c9;
elm in c10;
elm in c11;

a:= Transformation([2, 3, 4, 1]);
b:= Transformation([2, 2, 3, 4]);
s:= Semigroup(a, b);
R:= GreensRRelation(s);
L:= GreensLRelation(s);
J:= GreensJRelation(s);
H:= GreensHRelation(s);
D:= GreensDRelation(s);
c1:= EquivalenceClassOfElement(R, Transformation([2, 2, 4, 4]));;
c2:= EquivalenceClassOfElement(L, Transformation([2, 2, 4, 4]));;
c3:= EquivalenceClassOfElement(J, Transformation([2, 2, 4, 4]));;
c4:= EquivalenceClassOfElement(H, Transformation([2, 2, 4, 4]));;
c5:= EquivalenceClassOfElement(D, Transformation([2, 2, 4, 4]));;

AsSSortedList(c1);
AsSSortedList(c2);
AsSSortedList(c3);
#AsSSortedList(c4);
#AsSSortedList(c5);
Size(c1);
Size(c2);
Size(c3);
#Size(c4);
#Size(c5);





