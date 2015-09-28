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
gap> InstallMethod(\[\],[r,IsObject],function(l,ix) 
>     return ix;
> end);
gap> InstallMethod(\[\]\:\=,[r and IsMutable,IsObject, IsObject],function(l,ix,x) 
>     Print ("Assign ",ix," ",x,"\n");
> end);
gap> InstallMethod(Unbind\[\],[r and IsMutable,IsObject],function(l,ix) 
>     Print ("Unbind ",ix,"\n");
> end);
gap> InstallMethod(IsBound\[\],[r and IsMutable,IsObject],function(l,ix) 
>     Print ("IsBound ",ix,"\n");
>     return false;
> end);
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
gap> o[3,4,5];
[ 3, 4, 5 ]
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
gap> o[-1,"e"] := 1.0;
Assign [ -1, "e" ] 1
1.
gap> o[2.0,3.0,4.5] := infinity;
Assign [ 2, 3, 4.5 ] infinity
infinity
gap> Unbind(o[1]);
Unbind 1
gap> Unbind(o[-17]);
Unbind -17
gap> Unbind(o[Z(3)]);
Unbind Z(3)
gap> Unbind(o[[1,2]]);
Unbind [ 1, 2 ]
gap> Unbind(o[3,4]);
Unbind [ 3, 4 ]
gap> Unbind(o[3,4,5]);
Unbind [ 3, 4, 5 ]
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
IsBound [ 3, 4 ]
false
gap> IsBound(o[3,4,5]);
IsBound [ 3, 4, 5 ]
false
gap> IsBound(o["abc"]);
IsBound abc
false
gap> foo := function(a)
>     return[ a[1,2,3],
>             a[4,5],
>             o[1,2,3],
>             o[4,5],
>             function()
>         return [a[6,7], a[5,6,7]];
>     end];
> end;
function( a ) ... end
gap> Print(foo,"\n");
function ( a )
    return [ a[1, 2, 2], a[4, 5], o[1, 2, 2], o[4, 5], function (  )
  return [ a[6, 7], a[5, 6, 6] ];
end ];
end
gap> res := foo(o);
[ [ 1, 2, 3 ], [ 4, 5 ], [ 1, 2, 3 ], [ 4, 5 ], function(  ) ... end ]
gap> res[5]();
[ [ 6, 7 ], [ 5, 6, 7 ] ]

# that's all, folks
gap> STOP_TEST( "listgen.tst", 1000000 );

#############################################################################
##
#E
