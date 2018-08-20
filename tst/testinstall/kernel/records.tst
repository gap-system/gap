#
# Tests for functions defined in src/records.c
#
gap> START_TEST("kernel/records.tst");

#
# setup: a precord, and a custom record object
#
gap> r:=rec(1:=2);
rec( 1 := 2 )
gap> fam := NewFamily("MockFamily");;
gap> cat := NewCategory("IsMockRecord", IsRecord);;
gap> type := NewType(fam, cat and IsPositionalObjectRep);;
gap> mockRec := Objectify(type,["myName"]);;

# RNamIntg, RNamObj
gap> ForAll([1,-1,"abc"], x -> IsInt(RNamObj(x)));
true
gap> RNamObj(fail);
Error, Record: '<rec>.(<obj>)' <obj> must be a string or an integer

# NameRNam
gap> ForAll([1,-1,"abc"], x -> NameRNam(RNamObj(x)) = String(x));
true
gap> NameRNam(-1);
Error, NameRName: <rnam> must be a record name (not a integer)
gap> NameRNam(fail);
Error, NameRName: <rnam> must be a record name (not a boolean or fail)

# ElmRecHandler
gap> ELM_REC(r, RNamObj(1));
2
gap> ELM_REC(r, RNamObj(2));
Error, Record Element: '<rec>.2' must have an assigned value

# ElmRecError
gap> fail.1;
Error, Record Element: <rec> must be a record (not a boolean or fail)

# ElmRecObject
gap> InstallMethod(\., [cat, IsPosInt], function(x,i) end);
gap> mockRec.1;
Error, Record access method must return a value
gap> InstallMethod(\., [cat, IsPosInt], function(x,i) return 42; end);
gap> mockRec.1;
42

# IsbRecHandler
gap> ISB_REC(r, RNamObj(1));
true
gap> ISB_REC(r, RNamObj(2));
false

# IsbRecError
gap> IsBound(fail.1);
Error, Record IsBound: <rec> must be a record (not a boolean or fail)

# IsbRecObject
gap> InstallMethod(IsBound\., [cat, IsPosInt], {x,i} -> (i = RNamObj(1)));
gap> IsBound(mockRec.1);
true
gap> IsBound(mockRec.2);
false

# AssRecHandler
gap> ASS_REC(r, RNamObj(3), 42);
gap> r;
rec( 1 := 2, 3 := 42 )

# AssRecError
gap> fail.1 := 2;
Error, Record Assignment: <rec> must be a record (not a boolean or fail)

# AssRecObject
gap> InstallMethod(\.\:\=, [cat, IsPosInt, IsObject], function(x,i,v) end);
gap> ASS_REC(mockRec, RNamObj(1), 2);
gap> mockRec.1 := 2;
2

# UnbRecHandler
gap> UNB_REC(r, RNamObj(2));

# UnbRecError
gap> Unbind(fail.1);
Error, Record Unbind: <rec> must be a record (not a boolean or fail)

# UnbRecObject
gap> InstallMethod(Unbind\., [cat, IsPosInt], function(x,i) end);
gap> Unbind(mockRec.1);

#
gap> STOP_TEST("kernel/records.tst", 1);
