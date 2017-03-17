#############################################################################
##
#W  varnames.tst                GAP Tests                 Alexander Konovalov
##
##
##  Exclude from testinstall.g: too sensitive to the context
##
gap> START_TEST("varnames.tst");
gap> Filtered( NamesSystemGVars(), x -> not x in ALL_KEYWORDS() and
>            ( Length(x)=1 or (IsLowerAlphaChar(x[1]) and Length(x) < 12) ) );
[ "*", "+", "-", ".", "/", "<", "=", "E", "X", "Z", "^", "fail", "infinity", 
  "last", "last2", "last3", "time" ]
gap> # Filtered(NamesSystemGVars(),name->IsSubset(LETTERS,name));;  
gap> E;
<Operation "E">
gap> X;
<Operation "Indeterminate">
gap> Z;
function( q ) ... end
gap> Length;
<Attribute "Length">
gap> STOP_TEST( "varnames.tst", 1);

#############################################################################
##
#E  varnames.tst . . . . . . . . . . . . . . . . . . . . . . . . .  ends here
