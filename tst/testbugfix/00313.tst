# 2015/02/16 (CJ, Reported by TB)
gap> a:= rec();; a.( "" ):= 1;; a; Print( a,"\n" );
rec( ("") := 1 )
rec(
  ("") := 1 )

#2015/02/16 (CJ, reported by TB)
gap> f1:= function( x, l ) return ( not x ) in l; end;;
gap> f2:= function( x, l ) return not ( x in l ); end;;
gap> f3:= function( x, l ) return not x in l;     end;;
gap> [f1(true,[]), f2(true,[]), f3(true,[])];
[ false, true, true ]
gap> Print([f1,f2,f3],"\n");
[ function ( x, l )
        return (not x) in l;
    end, function ( x, l )
        return not x in l;
    end, function ( x, l )
        return not x in l;
    end ]
