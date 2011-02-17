#############################################################################
##
#W  varnames.tst                GAP Tests                 Alexander Konovalov
##
#H  @(#)$Id: varnames.tst,v 4.4 2011/01/20 21:33:55 alexk Exp $
##
##  Exclude from testinstall.g: too sensitive to the context
##
gap> START_TEST("$Id: varnames.tst,v 4.4 2011/01/20 21:33:55 alexk Exp $");

gap> Filtered( NamesSystemGVars(), x -> not x in ALL_KEYWORDS() and
>            ( Length(x)=1 or IsLowerAlphaChar(x[1]) ) );
[ "*", "+", "-", ".", "/", "<", "=", "E", "P", "X", "Z", "^", "errorCount", 
  "fail", "infinity", "last", "last2", "last3", "time" ]
gap> # Filtered(NamesSystemGVars(),name->IsSubset(LETTERS,name));;  
gap> E;
<Operation "E">
gap> P;
function( a ) ... end
gap> X;
<Operation "Indeterminate">
gap> Z;
function( q ) ... end
gap> Length;
<Attribute "Length">

gap> STOP_TEST( "varnames.tst", 2000 );

#############################################################################
##
#E  varnames.tst . . . . . . . . . . . . . . . . . . . . . . . . .  ends here