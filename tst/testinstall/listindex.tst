#############################################################################
##
#A  listindex.tst               GAP 4.0 library                   Steve Linton
##
##
##
##
gap> START_TEST("listindex.tst");
gap> r := NewCategory("ListTestObject",IsList and HasLength and HasIsFinite);
<Category "ListTestObject">

#
gap> InstallOtherMethod(\[\],[r,IsObject],function(l,ix) 
>     return ix;
> end);
gap> InstallOtherMethod(\[\]\:\=,[r and IsMutable,IsObject, IsObject],function(l,ix,x) 
>     Print ("Assign ",ix," ",x,"\n");
> end);
gap> InstallOtherMethod(Unbind\[\],[r and IsMutable,IsObject],function(l,ix) 
>     Print ("Unbind ",ix,"\n");
> end);
gap> InstallOtherMethod(IsBound\[\],[r and IsMutable,IsObject],function(l,ix) 
>     Print ("IsBound ",ix,"\n");
>     return false;
> end);
gap> InstallOtherMethod(GetWithDefault, [r and IsMutable, IsInt, IsObject], function(a,ix,d)
>     Print("GetWithDefault ", ix, ":", d, "\n");
>     return d;
> end);

#
gap> InstallOtherMethod(\[\],[r,IsPosInt,IsPosInt],function(l,i,j) 
>     return [i,j];
> end);
gap> InstallOtherMethod(\[\]\:\=,[r and IsMutable,IsPosInt,IsPosInt, IsObject],function(l,i,j,x) 
>     Print ("Assign [",i,"][",j,"] := ",x,"\n");
> end);
gap> InstallOtherMethod(Unbind\[\],[r and IsMutable,IsPosInt,IsPosInt],function(l,i,j) 
>     Print ("Unbind [",i,"][",j,"]\n");
> end);
gap> InstallOtherMethod(IsBound\[\],[r and IsMutable,IsPosInt,IsPosInt],function(l,i,j) 
>     Print ("IsBound [",i,"][",j,"]\n");
>     return false;
> end);

#
gap> InstallMethod(Length,[r],l->infinity);
gap> InstallMethod(IsFinite,[r],ReturnFalse);
gap> t := NewType(ListsFamily, r and IsMutable and IsPositionalObjectRep);;
gap> o := Objectify(t,[]);;
gap> o[1];
1
gap> o[-17];
-17
gap> o[Z(3)];
Z(3)
gap> o[[1,2]];
[ 1, 2 ]
gap> o[3,4];
[ 3, 4 ]
gap> o["abc"];
"abc"
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
gap> Unbind(o[1]);
Unbind 1
gap> Unbind(o[-17]);
Unbind -17
gap> Unbind(o[Z(3)]);
Unbind Z(3)
gap> Unbind(o[[1,2]]);
Unbind [ 1, 2 ]
gap> Unbind(o[3,4]);
Unbind [3][4]
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
IsBound [3][4]
false
gap> IsBound(o["abc"]);
IsBound abc
false
gap> GetWithDefault(o, 2, "abc");
GetWithDefault 2:abc
"abc"
gap> foo := function(a)
>     return[ a[4,5],
>             o[4,5],
>             function()
>         return [a[6,7], o[4,5]];
>     end];
> end;
function( a ) ... end
gap> Print(foo,"\n");
function ( a )
    return [ a[4, 5], o[4, 5], function (  )
          return [ a[6, 7], o[4, 5] ];
  end ];
end
gap> res := foo(o);
[ [ 4, 5 ], [ 4, 5 ], function(  ) ... end ]
gap> res[3]();
[ [ 6, 7 ], [ 4, 5 ] ]
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
Error, GetWithDefault: <pos> must be >= 0
gap> s := [];; GetWithDefault(s, "cheese", -1);
Error, GetWithDefault: <pos> must be an integer (not a list (string))
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
gap> Append(Immutable([1,2,3]), [1,2,3]);
Error, Append: <list1> must be a mutable list
gap> Append([1,2,3], () );
Error, AppendList: <list2> must be a small list (not a permutation (small))
gap> Append( () , [1,2,3] );
Error, Append: <list1> must be a mutable list
gap> s;
[  ]
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
gap> CopyListEntries("abc",3,-1,l,4,-3,2);
Error, COPY_LIST_ENTRIES: source must be a plain list not a list (string)
gap> CopyListEntries(s,3,-1,"abc",4,-3,2);
Error, COPY_LIST_ENTRIES: destination must be a mutable plain list not a list \
(string)
gap> CopyListEntries(s,3,-1,Immutable([1,2,3]),4,-3,2);
Error, COPY_LIST_ENTRIES: destination must be a mutable plain list not a list \
(plain,cyc,imm)
gap> CopyListEntries(s, "cheese", 1, l, 1, 1, 2);
Error, COPY_LIST_ENTRIES: argument 2  must be a small integer, not a list (str\
ing)
gap> CopyListEntries(s, 1, "cheese", l, 1, 1, 2);
Error, COPY_LIST_ENTRIES: argument 3  must be a small integer, not a list (str\
ing)
gap> CopyListEntries(s, 1, 1, l, "cheese", 1, 2);
Error, COPY_LIST_ENTRIES: argument 5  must be a small integer, not a list (str\
ing)
gap> CopyListEntries(s, 1, 1, l, 1, "cheese", 2);
Error, COPY_LIST_ENTRIES: argument 6  must be a small integer, not a list (str\
ing)
gap> CopyListEntries(s, 1, 1, l, 1, 1, "cheese");
Error, COPY_LIST_ENTRIES: argument 7  must be a small integer, not a list (str\
ing)
gap> CopyListEntries(s,0,1,l,1,1,2);
Error, COPY_LIST_ENTRIES: list indices must be positive integers
gap> CopyListEntries(s,1,-1,l,1,1,2);
Error, COPY_LIST_ENTRIES: list indices must be positive integers
gap> CopyListEntries(s,1,1,l,1,-1,2);
Error, COPY_LIST_ENTRIES: list indices must be positive integers
gap> CopyListEntries(s,1,1,l,0,1,2);
Error, COPY_LIST_ENTRIES: list indices must be positive integers
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
gap> l := [[]];;
gap> l[1,2] := 4;
4
gap> l;
[ [ , 4 ] ]
gap> l[1,1] := 3;;
gap> l;
[ [ 3, 4 ] ]
gap> l[2,1];
Error, List Element: <list>[2] must have an assigned value
gap> MakeImmutable(l[1]);;
gap> l[1,1] := 2;;
Error, Lists Assignment: <list> must be a mutable list
gap> l;
[ [ 3, 4 ] ]

# that's all, folks
gap> STOP_TEST( "listindex.tst", 1);

#############################################################################
##
#E
