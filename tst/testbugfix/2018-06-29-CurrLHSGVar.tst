# This always produced a warning"
gap> Unbind(string);
gap> for i in [ 1 .. 10 ] do
>     string := "aaaabbbb";
>     xxx := List( [], x -> string );
> od;
Syntax warning: Unbound global variable in stream:3
    xxx := List( [], x -> string );
                          ^^^^^^

# ... but this did not; now it does
gap> Unbind(string);
gap> for i in [ 1 .. 10 ] do
>     string := "aaaabbbb";
>     List( [], x -> string );
> od;
Syntax warning: Unbound global variable in stream:3
    List( [], x -> string );
                   ^^^^^^
