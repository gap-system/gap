#############################################################################
##
##  Exclude from testinstall.g: too sensitive to the context
##
gap> START_TEST("varnames.tst");
gap> Filtered( NamesSystemGVars(), x -> not x in ALL_KEYWORDS() and
>            ( Length(x)=1 or (IsLowerAlphaChar(x[1]) and Length(x) < 5) ) );
[ "*", "+", "-", ".", "/", "<", "=", "E", "X", "Z", "^", "fail", "last", 
  "time" ]
gap> Filtered(NamesSystemGVars(),name->IsSubset(CHARS_ALPHA,name));;
gap> IsSubset(IDENTS_GVAR(), IDENTS_BOUND_GVARS() );
true
gap> E;
<Operation "E">
gap> X;
<Operation "Indeterminate">
gap> Z;
function( q ) ... end
gap> Length;
<Attribute "Length">
gap> zzzz -> zzzz + 1;;
gap> "zzzz" in Filtered(NamesGVars(), x -> not IsBoundGlobal(x));
false
gap> STOP_TEST("varnames.tst");
