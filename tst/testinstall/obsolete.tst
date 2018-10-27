gap> START_TEST("obsolete.tst");
gap> newfunc:=function() return 42; end;
function(  ) ... end
gap> DeclareObsoleteSynonym("obsoletetestfunc","newfunc",1);
gap> DeclareObsoleteSynonym("obsoletetestfunc2","newfunc",2);
gap> DeclareObsoleteSynonym("obsoletetestfunc3","newfunc",2);
gap> oldLevel := InfoLevel(InfoObsolete);;
gap> SetInfoLevel(InfoObsolete,1);
gap> obsoletetestfunc();
#I  'obsoletetestfunc' is obsolete.
#I  It may be removed in a future release of GAP.
#I  Use newfunc instead.
42
gap> obsoletetestfunc();
42
gap> obsoletetestfunc2();
42
gap> obsoletetestfunc2();
42
gap> SetInfoLevel(InfoObsolete, 2);
gap> obsoletetestfunc2();
#I  'obsoletetestfunc2' is obsolete.
#I  It may be removed in a future release of GAP.
#I  Use newfunc instead.
42
gap> obsoletetestfunc2();
42
gap> obsoletetestfunc3();
#I  'obsoletetestfunc3' is obsolete.
#I  It may be removed in a future release of GAP.
#I  Use newfunc instead.
42
gap> obsoletetestfunc3();
42
gap> DeclareObsoleteSynonymAttr("obsoleteattr", "IsEmpty");
gap> obsoleteattr([1,2,3]);
#I  'obsoleteattr' is obsolete.
#I  It may be removed in a future release of GAP.
#I  Use IsEmpty instead.
false
gap> obsoleteattr([1,2,3]);
false
gap> obsoleteattr([]);
true
gap> Hasobsoleteattr([]);
#I  'Hasobsoleteattr' is obsolete.
#I  It may be removed in a future release of GAP.
#I  Use HasIsEmpty instead.
true
gap> Hasobsoleteattr([]);
true
gap> Setobsoleteattr([], true);
#I  'Setobsoleteattr' is obsolete.
#I  It may be removed in a future release of GAP.
#I  Use SetIsEmpty instead.
gap> SetInfoLevel(InfoObsolete, oldLevel);
gap> STOP_TEST("obsolete.tst");
