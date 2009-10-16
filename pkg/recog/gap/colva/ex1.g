gap> g := Group ( (1,2) );
Group([ (1,2) ])
gap> gg := Group( (4,5) );
Group([ (4,5) ])
gap> ggg := Group( (1,3)(2,4) );
Group([ (1,3)(2,4) ])
gap> f := function(x) if x = (1,2) then return (4,5); else return (); fi; end;
function( x ) ... end
gap> f2 := function(x) if x = (4,5) then return (1,3)(2,4); else return (); fi; end;
function( x ) ... end
gap> h1 := GroupHomomorphismByFunction(g,gg,f);
MappingByFunction( Group([ (1,2) ]), Group([ (4,5) ]), function( x ) ... end )
gap> h2 := GroupHomomorphismByFunction(gg,ggg,f2);
MappingByFunction( Group([ (4,5) ]), Group(
[ (1,3)(2,4) ]), function( x ) ... end )
gap> CompositionMaps2(h2,h1);
Variable: 'CompositionMaps2' must have a value

gap> CompositionMapping2(h2,h1);
[ (1,2) ] -> [ (1,3)(2,4) ]
gap> CompositionMapping(h2,h1);
[ (1,2) ] -> [ (1,3)(2,4) ]
gap> h1*h2;
[ (1,2) ] -> [ (1,3)(2,4) ]
gap> h1;
MappingByFunction( Group([ (1,2) ]), Group([ (4,5) ]), function( x ) ... end )
gap> LogTo();
