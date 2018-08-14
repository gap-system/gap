# constructors with zero arguments cannot be created
gap> DeclareConstructor("foobar",[]);
Error, constructors must have at least one argument
gap> NewConstructor("foobar",[]);
Error, constructors must have at least one argument

#
gap> c := NewConstructor("foobar",[IsObject]);
<Constructor "foobar">
gap> c(1);
Error, Constructor: the first argument must be a filter not a integer
gap> c(IsInt);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `foobar' on 1 arguments
gap> InstallMethod(c,[IsInt],x->x);
gap> c(IsInt);
<Category "IsInt">
gap> InstallOtherMethod(c,[IsInt,IsObject],{x,y}->[x,y]);
gap> c(IsInt, 0);
[ <Category "IsInt">, 0 ]

# constructors must not have methods with zero arguments, nor is it ever legal
# to invoke a constructor with zero arguments
gap> InstallOtherMethod(c,[],{}->[]);
Error, foobar: constructors must have at least one argument
gap> c();
Error, constructors must have at least one argument
