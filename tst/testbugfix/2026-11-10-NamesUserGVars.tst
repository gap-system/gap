# NamesUserGVars must not list globals bound by the library at startup
gap> START_TEST("NamesUserGVars.tst");
gap> "ProcessInitFiles" in NamesUserGVars();
false
gap> STOP_TEST("NamesUserGVars.tst");
