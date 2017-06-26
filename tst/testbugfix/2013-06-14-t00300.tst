# 2013/06/14 (AK, MH)
gap> foo:=function() return 42; end;
function(  ) ... end
gap> DeclareObsoleteSynonym("bar","foo");
gap> oldLevel := InfoLevel(InfoObsolete);;
gap> SetInfoLevel(InfoObsolete,1);
gap> bar();
#I  'bar' is obsolete.
#I  It may be removed in a future release of GAP.
#I  Use foo instead.
42
gap> SetInfoLevel(InfoObsolete, oldLevel);
gap> MakeReadWriteGlobal("bar");
gap> Unbind(bar);
