# 

gap> testOutputMethod := function(meth, obj)
> local str, stream;
> str := "";
> stream := OutputTextString(str, false);
> meth(stream, obj);
> return str;
> end;;
gap> testOutputMethod(ViewObj, rec( ));
"rec(  )"
gap> testOutputMethod(CodeObj, rec( ));
"rec(\n   )"
gap> testOutputMethod(DisplayObj, rec( ));
"rec(  )"

#
