# Test file for pickling/unpickling:

# Preparations:
x := X(Rationals);
InstallMethod( EQ, [ IsStraightLineProgram, IsStraightLineProgram ],
  function(a,b) 
    return LinesOfStraightLineProgram(a) = LinesOfStraightLineProgram(b) and
           NrInputsOfStraightLineProgram(a) = NrInputsOfStraightLineProgram(b);
  end );
InstallMethod( PrintObj,
    "for element in Z/pZ (ModulusRep)",
    [ IsZmodpZObj and IsModulusRep ],
    function( x )
    Print( "ZmodnZObj( ", x![1], ", ", Characteristic( x ), " )" );
    end );
InstallMethod( String,
    "for element in Z/pZ (ModulusRep)",
    [ IsZmodpZObj and IsModulusRep ],
    function( x )
      return Concatenation( "ZmodnZObj(", String(x![1]), ",",
      String(Characteristic( x )), ")" );
    end );


# Build up a variety of different GAP objects in a list:
l := [

false,
true,
fail,
SuPeRfail,
0,
-1,
1,
1234567123512636523123561311223123123123234234234,
"Max",
'M',
E(4),
E(4)+E(4)^3,
StraightLineProgram([[1,1,2,1,1,-1],[3,1,2,-1]],2),
Z(2),
Z(2)^0,
0*Z(2),
Z(2^3),
Z(2^3)^0,
0*Z(2^3),
Z(3),
Z(3)^0,
0*Z(3),
Z(3^5),
Z(3^5)^0,
0*Z(3^5),
Z(257),
0*Z(257),
Z(257)^0,
Z(257^4),
0*Z(257^4),
Z(257^4)^0,
Z(65537),
Z(65537)^0,
0*Z(65537),
Z(65537^2),
Z(65537^2)^0,
0*Z(65537^2),
(1,2,3,4),
,,,,   # a gap
x^2+x+1,
x^-3+1+x^4,
(x+1)/(x+2),
rec( a := 1, b := "Max" ),
rec( c := 3, d := "Till" ),

];

MakeImmutable(l[Length(l)]);

v := [Z(5),0*Z(5),Z(5)^2];
ConvertToVectorRep(v,5);
Add(l,v);
vecpos := Length(l);
w := ShallowCopy(v);
MakeImmutable(w);
Add(l,w);
vv := [Z(7),0*Z(7),Z(7)^2];
ConvertToVectorRep(vv,7^2);
Add(l,vv);
ww := ShallowCopy(vv);
MakeImmutable(ww);
Add(l,ww);
vvv := [Z(2),0*Z(2)];
ConvertToVectorRep(vvv,2);
Add(l,vvv);
www := ShallowCopy(vvv);
MakeImmutable(www);
Add(l,www);

# compressed matrices:
m := [[Z(5),0*Z(5),Z(5)^2]];
ConvertToMatrixRep(m,5);
Add(l,m);
n := MutableCopyMat(m);
ConvertToMatrixRep(n,5);
MakeImmutable(n);
Add(l,n);
mm := [[Z(7),0*Z(7),Z(7)^2]];
ConvertToMatrixRep(mm,7^2);
Add(l,mm);
nn := MutableCopyMat(mm);
ConvertToMatrixRep(nn,7^2);
MakeImmutable(nn);
Add(l,nn);
mmm := [[Z(2),0*Z(2)]];
ConvertToMatrixRep(mmm,2);
Add(l,mmm);
nnn := MutableCopyMat(mmm);
ConvertToMatrixRep(nnn,2);
MakeImmutable(nnn);
Add(l,nnn);

# Finally self-references:
r := rec( l := l, x := 1 );
r.r := r;
Add(l,l);
Add(l,r);

s := "";
f := IO_WrapFD(-1,false,s);
if IO_Pickle(f,l) <> IO_OK then Error(1); fi;
if IO_Pickle(f,"End") <> IO_OK then Error(2); fi;
IO_Close(f);

Print("Bytes pickled: ",Length(s),"\n");

f := IO_WrapFD(-1,s,false);
ll := IO_Unpickle(f);
for i in [1..Length(l)-2] do
    if not( (not(IsBound(l[i])) and not(IsBound(ll[i]))) or
       (IsBound(l[i]) and IsBound(ll[i]) and l[i] = ll[i]) ) then
        Error(3);
    fi;
od;
if not(IsIdenticalObj(ll,ll[Length(ll)-1])) then Error(4); fi;
if not(IsIdenticalObj(ll,ll[Length(ll)].l)) then Error(5); fi;
if not(IsIdenticalObj(ll[Length(ll)],ll[Length(ll)].r)) then Error(6); fi;
if ll[Length(ll)].x <> l[Length(l)].x then Error(7); fi;
if not(IsMutable(ll[vecpos-2])) then Error(8); fi;
if IsMutable(ll[vecpos-1]) then Error(9); fi;
if not(Is8BitVectorRep(ll[vecpos])) then Error(10); fi;
if not(IsMutable(ll[vecpos])) then Error(11); fi;
if not(Is8BitVectorRep(ll[vecpos+1])) then Error(12); fi;
if IsMutable(ll[vecpos+1]) then Error(13); fi;
if not(Is8BitVectorRep(ll[vecpos+2])) then Error(14); fi;
if not(IsMutable(ll[vecpos+2])) then Error(15); fi;
if not(Is8BitVectorRep(ll[vecpos+3])) then Error(16); fi;
if IsMutable(ll[vecpos+3]) then Error(17); fi;
if not(IsGF2VectorRep(ll[vecpos+4])) then Error(18); fi;
if not(IsMutable(ll[vecpos+4])) then Error(19); fi;
if not(IsGF2VectorRep(ll[vecpos+5])) then Error(20); fi;
if IsMutable(ll[vecpos+5]) then Error(21); fi;
if not(Is8BitMatrixRep(ll[vecpos+6])) then Error(22); fi;
if not(IsMutable(ll[vecpos+6])) or not(IsMutable(ll[vecpos+6][1])) then 
    Error(23); 
fi;
if not(Is8BitMatrixRep(ll[vecpos+7])) then Error(24); fi;
if IsMutable(ll[vecpos+7]) or IsMutable(ll[vecpos+7]) then Error(25); fi;
if not(Is8BitMatrixRep(ll[vecpos+8])) then Error(26); fi;
if not(IsMutable(ll[vecpos+8])) or not(IsMutable(ll[vecpos+8])) then 
    Error(27); 
fi;
if not(Is8BitMatrixRep(ll[vecpos+9])) then Error(28); fi;
#if IsMutable(ll[vecpos+9]) or IsMutable(ll[vecpos+9][1]) then Error(29); fi;
if not(IsGF2MatrixRep(ll[vecpos+10])) then Error(30); fi;
if not(IsMutable(ll[vecpos+10])) or not(IsMutable(ll[vecpos+10][1])) then 
    Error(31); 
fi;
if not(IsGF2MatrixRep(ll[vecpos+11])) then Error(32); fi;
#if IsMutable(ll[vecpos+11]) or IsMutable(ll[vecpos+11][1]) then Error(33); fi;

ee := IO_Unpickle(f);
if ee <> "End" then Error(34); fi;

if IO_Unpickle(f) <> IO_Nothing then Error(35); fi;

IO_Close(f);

Print("Unpickling OK.\n");

