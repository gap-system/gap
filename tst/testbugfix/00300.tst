# 2013/06/14 (AK, MH)
gap> foo:=function() return 42; end;
function(  ) ... end
gap> DeclareObsoleteSynonym("bar","foo","4.8");
gap> SetInfoLevel(InfoObsolete,1);
gap> bar();
#I  'bar' is obsolete.
#I  It may be removed in the future release of GAP 4.8
#I  Use foo instead.
42
gap> SetInfoLevel(InfoObsolete,0);
