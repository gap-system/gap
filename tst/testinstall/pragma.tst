#
gap> #% pragma
gap> 
gap> x := function( x )
>       #% pragma
>       return x;
>    end;;
gap> Display( x );
function ( x )
    #% pragma
    return x;
end
gap> x := function( x )
>       #% pragma	with	tab
>       return x;
>    end;;
gap> Display( x );
function ( x )
    #% pragma	with	tab
    return x;
end
