# 2005/08/19 (JS)
gap> f:=function() Assert(0,false); end;; g:=function() f(); end;;
gap> ##  The following should just trigger a normal error, but in 4.4.5
gap> ##  it will send a few hundred lines before crashing:
gap> # g();
