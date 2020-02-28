# test CheckGlobalName
gap> CheckGlobalName(" ");
#I  suspicious global variable name " ", non-identifier character found at position 1
gap> CheckGlobalName("");
#I  suspicious global variable name "", name is the empty string
gap> CheckGlobalName("name");
