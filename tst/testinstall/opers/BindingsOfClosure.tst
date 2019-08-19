gap> START_TEST("BindingsOfClosure");

# Test bad input
gap> BindingsOfClosure(0);
Error, ENVI_FUNC: <func> must be a function (not the integer 0)

# Test some boundary cases
gap> BindingsOfClosure(IsInt); # category
fail
gap> BindingsOfClosure(IsCommutative); # property
fail
gap> BindingsOfClosure(DerivedSubgroup); # attribute
fail
gap> BindingsOfClosure(ENVI_FUNC); # kernel function
fail
gap> BindingsOfClosure(INSTALL_METHOD); # gac compiled function
rec(  )

# function with no bindings
gap> makeFun:=n -> x -> x + n;;
gap> BindingsOfClosure(makeFun);
rec(  )

# simple binding
gap> f:=makeFun(42);;
gap> BindingsOfClosure(f);
rec( n := 42 )
gap> Display(f);
function ( x )
    return x + n;
end

# real world example from the library
gap> f := ApplicableMethod( OrbitsDomain, [ SymmetricGroup(5), [1..5] ] );;
gap> BindingsOfClosure(f);
rec( NewAorP := function( name, filter, args... ) ... end, 
  name := "OrbitsDomain", op := <Attribute "OrbitsDomain">, 
  reqs := [ <Filter "(IsMagmaWithInverses and IsAssociative)">, 
      <Category "IsListOrCollection">, <Category "IsList">, 
      <Category "IsList">, <Category "IsFunction"> ], usetype := false )
gap> Display(f);
function ( G, D )
    if D = MovedPoints( G ) then
        return op( G );
    else
        TryNextMethod();
    fi;
    return;
end

#
gap> STOP_TEST("BindingsOfClosure");
