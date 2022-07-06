#############################################################################
##
#A  listindex.tst               GAP 4.0 library                   Steve Linton
##
##
##
##
#@local foo,l,o,r,res,s,t,x
gap> START_TEST("listindex.tst");

# custom list implementation, pretending to have infinite length
gap> r := NewCategory("ListTestObject",IsList and HasLength and HasIsFinite);
<Category "ListTestObject">
gap> InstallMethod(Length,[r],l->infinity);
gap> InstallMethod(IsFinite,[r],ReturnFalse);

#
gap> InstallOtherMethod(\[\],[r,IsObject],function(l,ix)
>     if ix = 123456789 then return; fi;
>     return ix;
> end);
gap> InstallOtherMethod(\[\]\:\=,[r and IsMutable,IsObject, IsObject],function(l,ix,x) 
>     Print("Assign ",ix," ",x,"\n");
> end);
gap> InstallOtherMethod(Unbind\[\],[r and IsMutable,IsObject],function(l,ix) 
>     Print("Unbind ",ix,"\n");
> end);
gap> InstallOtherMethod(IsBound\[\],[r and IsMutable,IsObject],function(l,ix) 
>     Print("IsBound ",ix,"\n");
>     return false;
> end);
gap> InstallOtherMethod(GetWithDefault, [r and IsMutable, IsInt, IsObject], function(a,ix,d)
>     Print("GetWithDefault ", ix, ":", d, "\n");
>     return d;
> end);

#
gap> InstallOtherMethod(\[\,\],[r,IsPosInt,IsPosInt],function(l,i,j)
>     Print("ELM_MAT [",i,",",j,"]\n");
>     if i = 123456789 then return; fi;
>     return [i,j];
> end);
gap> InstallOtherMethod(\[\,\]\:\=,[r and IsMutable,IsPosInt,IsPosInt, IsObject],function(l,i,j,x)
>     Print("ASS_MAT [",i,",",j,"] := ",x,"\n");
> end);
gap> InstallOtherMethod(Unbind\[\],[r and IsMutable,IsPosInt,IsPosInt],function(l,i,j) 
>     Print("Unbind [",i,",",j,"]\n");
> end);
gap> InstallOtherMethod(IsBound\[\],[r and IsMutable,IsPosInt,IsPosInt],function(l,i,j) 
>     Print("IsBound [",i,",",j,"]\n");
>     return false;
> end);

#
gap> t := NewType(ListsFamily, r and IsMutable and IsPositionalObjectRep);;
gap> o := Objectify(t,[]);;
gap> o[1];
1
gap> o[-17];
-17
gap> o[Z(3)];
Z(3)
gap> o["abc"];
"abc"
gap> o[[1,2]];
[ 1, 2 ]
gap> o[3,4];
ELM_MAT [3,4]
[ 3, 4 ]
gap> MatElm(o, 5, 6);
ELM_MAT [5,6]
[ 5, 6 ]
gap> o[123456789];
Error, List access method must return a value
gap> o[123456789,4];
ELM_MAT [123456789,4]
Error, Matrix access method must return a value
gap> MatElm(o, 123456789, 6);
ELM_MAT [123456789,6]
Error, Matrix access method must return a value
gap> o[2] := 3;
Assign 2 3
3
gap> o[2^200] := fail;
Assign 1606938044258990275541962092341162602522202993782792835301376 fail
fail
gap> o[E(4)] := "i";
Assign E(4) i
"i"
gap> o[[12,34,56]] := 99;
Assign [ 12, 34, 56 ] 99
99
gap> o[3,4] := 42;
ASS_MAT [3,4] := 42
42
gap> SetMatElm(o, 5, 6, 23);
ASS_MAT [5,6] := 23
gap> Unbind(o[1]);
Unbind 1
gap> Unbind(o[-17]);
Unbind -17
gap> Unbind(o[Z(3)]);
Unbind Z(3)
gap> Unbind(o[[1,2]]);
Unbind [ 1, 2 ]
gap> Unbind(o[3,4]);
Unbind [3,4]
gap> Unbind(o["abc"]);
Unbind abc
gap> IsBound(o[1]);
IsBound 1
false
gap> IsBound(o[-17]);
IsBound -17
false
gap> IsBound(o[Z(3)]);
IsBound Z(3)
false
gap> IsBound(o[[1,2]]);
IsBound [ 1, 2 ]
false
gap> IsBound(o[3,4]);
IsBound [3,4]
false
gap> IsBound(o["abc"]);
IsBound abc
false
gap> GetWithDefault(o, 2, "abc");
GetWithDefault 2:abc
"abc"
gap> foo := function(a)
>     return[ a[2,3],
>             o[4,5],
>             function()
>         return [a[6,7], o[8,9]];
>     end];
> end;
function( a ) ... end
gap> Print(foo,"\n");
function ( a )
    return [ a[2, 3], o[4, 5], function (  )
          return [ a[6, 7], o[8, 9] ];
  end ];
end
gap> res := foo(o);
ELM_MAT [2,3]
ELM_MAT [4,5]
[ [ 2, 3 ], [ 4, 5 ], function(  ) ... end ]
gap> res[3]();
ELM_MAT [6,7]
ELM_MAT [8,9]
[ [ 6, 7 ], [ 8, 9 ] ]
gap> s := [];; Add(s, 1); s;
[ 1 ]
gap> Add(s, 4); s;
[ 1, 4 ]
gap> s := [];; Add(s,1,3); s;
[ ,, 1 ]
gap> s := [];; Add(s,1,1); s;
[ 1 ]
gap> s := [];; Add(s, ' ',1); s;
" "
gap> s := [];; Add(s, ' ',2); s;
[ , ' ' ]
gap> s := [];; Add(s, 0, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Add' on 3 arguments
gap> s;
[  ]
gap> s := [];; Add(s, 0, -1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Add' on 3 arguments
gap> s := [];; GetWithDefault(s, 0, -1);
Error, GetWithDefault: <pos> must be a positive small integer (not the integer\
 0)
gap> s := [];; GetWithDefault(s, "cheese", -1);
Error, GetWithDefault: <pos> must be a positive small integer (not a list (str\
ing))
gap> t := [];; GetWithDefault(t, 1, -1);
-1
gap> t := [6];; GetWithDefault(t, 1, -1);
6
gap> t := [6];; GetWithDefault(t, 2, -1);
-1
gap> t := "cheese";; GetWithDefault(t, 2, -1);
'h'
gap> t := "cheese";; GetWithDefault(t, 7, -1);
-1
gap> t := BlistList([1..5], [2]);; GetWithDefault(t, 2, -1);
true
gap> t := BlistList([1..5], [2]);; GetWithDefault(t, 6, -1);
-1
gap> l := [];; Append(l, [1]); l;
[ 1 ]
gap> l := [];; Append(l, "cheese"); l;
"cheese"
gap> l := [true];; Append(l, "cheese"); l;
[ true, 'c', 'h', 'e', 'e', 's', 'e' ]
gap> l := [true];; Append(l, [true]); l;
[ true, true ]
gap> l := [true];; Append(l, [1,2,3]); l;
[ true, 1, 2, 3 ]
gap> l := [true];; Append(l, []); l;
[ true ]
gap> l := [true];; Append(l, "cheese"); l;
[ true, 'c', 'h', 'e', 'e', 's', 'e' ]
gap> l := "cheese";; Append(l, [1,2,3]); l;
[ 'c', 'h', 'e', 'e', 's', 'e', 1, 2, 3 ]
gap> l := "cheese";; Append(l, "core"); l;
"cheesecore"
gap> l := "cheese";; Append(l, [true]); l;
[ 'c', 'h', 'e', 'e', 's', 'e', true ]
gap> l := "cheese";; Append(l, []); l;
"cheese"
gap> Append(l, l); l;
"cheesecheese"
gap> l := "chee";; Append(l, l); l;
"cheechee"
gap> l := "cheeseXX";; Append(l, l); l;
"cheeseXXcheeseXX"
gap> l := [true];; Append(l, l); l;
[ true, true ]
gap> Append(l,l); l;
[ true, true, true, true ]
gap> l := [];; Append(l,l); l;
[  ]
gap> l := [1,2,3,4];; Append(l,l); l;
[ 1, 2, 3, 4, 1, 2, 3, 4 ]
gap> Append(Immutable([1,2,3]), [1,2,3]);
Error, FuncAPPEND_LIST_INTR: <list1> must be a mutable list (not an immutable \
plain list of cyclotomics)
gap> Append([1,2,3], () );
Error, FuncAPPEND_LIST_INTR: <list2> must be a small list (not a permutation (\
small))
gap> Append( () , [1,2,3] );
Error, FuncAPPEND_LIST_INTR: <list1> must be a mutable list (not a permutation\
 (small))
gap> s;
[  ]

#
gap> s := [1,2,3];; l := [4,5,6];;
gap> CopyListEntries(s,1,1,l,1,1,1); l;
[ 1, 5, 6 ]
gap> CopyListEntries(s,2,2,l,2,2,1); l;
[ 1, 2, 6 ]
gap> CopyListEntries(s,8,2,l,1,1,2); l;
[ ,, 6 ]
gap> CopyListEntries(s,3,-1,l,1,1,2); l;
[ 3, 2, 6 ]
gap> CopyListEntries(s,3,-1,l,6,-1,2); l;
[ 3, 2, 6,, 2, 3 ]
gap> CopyListEntries(s,3,-1,l,4,-3,2); l;
[ 2, 2, 6, 3, 2, 3 ]

#
gap> l := [1,2,3,4,5];;
gap> CopyListEntries(l,2,2,l,2,2,2); l;
[ 1, 2, 3, 4, 5 ]
gap> CopyListEntries(l,2,2,l,1,2,2); l;
[ 2, 2, 4, 4, 5 ]
gap> l := [1,2,3,4,5];;
gap> CopyListEntries(l,2,2,l,3,2,2); l;
[ 1, 2, 2, 4, 4 ]
gap> l := [1,2,3,4,5];;
gap> CopyListEntries(l,1,1,l,3,2,2); l;
[ 1, 2, 1, 4, 2 ]
gap> l := [1,2,3,4,5];;
gap> CopyListEntries([],1,1,l,1,1,5); l;
[  ]
gap> l := [1,2,3,4,5];;
gap> CopyListEntries([],1,1,l,1,1,6); l;
[  ]
gap> l := [1,2,3,4,5];;
gap> CopyListEntries([1,,,,,,7],1,1,l,1,1,6); l;
[ 1 ]

#
gap> CopyListEntries();
Error, Function: number of arguments must be 7 (not 0)
gap> CopyListEntries("abc",3,-1,l,4,-3,2);
Error, COPY_LIST_ENTRIES: <fromlst> must be a plain list (not a list (string))
gap> CopyListEntries(s,3,-1,"abc",4,-3,2);
Error, COPY_LIST_ENTRIES: <tolst> must be a mutable plain list (not a list (st\
ring))
gap> CopyListEntries(s,3,-1,Immutable([1,2,3]),4,-3,2);
Error, COPY_LIST_ENTRIES: <tolst> must be a mutable plain list (not an immutab\
le plain list of cyclotomics)
gap> CopyListEntries(s, "cheese", 1, l, 1, 1, 2);
Error, CopyListEntries: <fromind> must be a small integer (not a list (string)\
)
gap> CopyListEntries(s, 1, "cheese", l, 1, 1, 2);
Error, CopyListEntries: <fromstep> must be a small integer (not a list (string\
))
gap> CopyListEntries(s, 1, 1, l, "cheese", 1, 2);
Error, CopyListEntries: <toind> must be a small integer (not a list (string))
gap> CopyListEntries(s, 1, 1, l, 1, "cheese", 2);
Error, CopyListEntries: <tostep> must be a small integer (not a list (string))
gap> CopyListEntries(s, 1, 1, l, 1, 1, "cheese");
Error, CopyListEntries: <n> must be a small integer (not a list (string))
gap> CopyListEntries(s,0,1,l,1,1,2);
Error, CopyListEntries: list indices must be positive integers
gap> CopyListEntries(s,1,-1,l,1,1,2);
Error, CopyListEntries: list indices must be positive integers
gap> CopyListEntries(s,1,1,l,1,-1,2);
Error, CopyListEntries: list indices must be positive integers
gap> CopyListEntries(s,1,1,l,0,1,2);
Error, CopyListEntries: list indices must be positive integers

#
gap> x := [1,3,4];;
gap> \[\](x,-1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `[]' on 2 arguments
gap> \[\](x,2);
3
gap> \[\](x,100);
Error, List Element: <list>[100] must have an assigned value
gap> \[\](x,(1,2,3));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `[]' on 2 arguments
gap> \[\]\:\=(x,2,1);
gap> x;
[ 1, 1, 4 ]
gap> \[\]\:\=(x,-1,1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `[]:=' on 3 arguments
gap> \[\]\:\=(x,5,1);
gap> x;
[ 1, 1, 4,, 1 ]
gap> \[\]\:\=(x,(1,2,3),1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `[]:=' on 3 arguments

# Indexing into plain lists
gap> l := [,[,4]];
[ , [ , 4 ] ]
gap> l[0,1];  # row is out of bounds
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `MatElm' on 3 arguments
gap> l[1,1];  # row is in bounds but missing
Error, Matrix Element: <mat>[1] must have an assigned value
gap> l[2,1];  # row is there but entry is missing
Error, Matrix Element: <mat>[2,1] must have an assigned value
gap> l[3,1];  # row is out of bounds
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `MatElm' on 3 arguments
gap> l[2,0];  # column is out of bounds
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `MatElm' on 3 arguments
gap> l[2,2];  # OK
4
gap> l[2,3];  # column is out of bounds
Error, List Element: <list>[3] must have an assigned value
gap> l[2,2] := 4;
4
gap> l;
[ , [ , 4 ] ]
gap> l[0,1] := 3; # error, row out of bounds
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `SetMatElm' on 4 arguments
gap> l[1,1] := 3; # error, row is missing
Error, Matrix Assignment: <mat>[1] must have an assigned value
gap> l[2,1] := 3; # OK
3
gap> l[3,1] := 3; # error, row out of bounds
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `SetMatElm' on 4 arguments
gap> l;
[ , [ 3, 4 ] ]
gap> l[2,1];
3
gap> MakeImmutable(l[2]);;
gap> l[2,1] := 2;;
Error, List Assignment: <list> must be a mutable list
gap> l;
[ , [ 3, 4 ] ]

# that's all, folks
gap> STOP_TEST( "listindex.tst", 1);
