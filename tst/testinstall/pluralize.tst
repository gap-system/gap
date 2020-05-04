gap> START_TEST("pluralize.tst");

#
gap> Pluralize(0);
Error, Usage: Pluralize([<count>, ]<string>[, <plural>])
gap> Pluralize(0, fail);
Error, Usage: Pluralize([<count>, ]<string>[, <plural>])
gap> Pluralize(0, "");
Error, the argument <str> must be a non-empty string
gap> Pluralize(1, "");
Error, the argument <str> must be a non-empty string
gap> Pluralize(0, "str", fail);
Error, Usage: Pluralize([<count>, ]<string>[, <plural>])
gap> Pluralize(0, "", "str");
Error, the argument <str> must be a non-empty string
gap> Pluralize(1, "", "str");
Error, the argument <str> must be a non-empty string
gap> Pluralize(-1, "str1", "str2");
Error, Usage: Pluralize([<count>, ]<string>[, <plural>])
gap> Pluralize(-1, "str1", "str2");
Error, Usage: Pluralize([<count>, ]<string>[, <plural>])
gap> Pluralize(0, "str1", "str2", fail);
Error, Usage: Pluralize([<count>, ]<string>[, <plural>])

#
gap> Pluralize(0, "A");
"\>0\< As"
gap> Pluralize(1, "A");
"\>1\< A"
gap> Pluralize("A");
"As"

#
gap> Pluralize(0, "ox", "oxen");
"\>0\< oxen"
gap> Pluralize(1, "ox", "oxen");
"\>1\< ox"
gap> Pluralize("ox", "oxen");
"oxen"

#
gap> Pluralize(1, "loaf");
"\>1\< loaf"
gap> Pluralize(2, "loaf");
"\>2\< loaves"
gap> Pluralize("loaf");
"loaves"

#
gap> Pluralize(1, "wharf");
"\>1\< wharf"
gap> Pluralize(2, "wharf");
"\>2\< wharves"
gap> Pluralize("wharf");
"wharves"

#
gap> Pluralize(1, "calf");
"\>1\< calf"
gap> Pluralize(2, "calf");
"\>2\< calves"
gap> Pluralize("calf");
"calves"

#
gap> Pluralize("matrix");
"matrices"
gap> Pluralize(2, "matrix");
"\>2\< matrices"

#
gap> Pluralize("vertex");
"vertices"
gap> Pluralize(3, "vertex");
"\>3\< vertices"

#
gap> Pluralize("index");
"indices"
gap> Pluralize(4, "index");
"\>4\< indices"

#
gap> Pluralize("ash");
"ashes"
gap> Pluralize(5, "ash");
"\>5\< ashes"

#
gap> Pluralize("success");
"successes"
gap> Pluralize(6, "success");
"\>6\< successes"

#
gap> Pluralize("box");
"boxes"
gap> Pluralize(7, "box");
"\>7\< boxes"

#
gap> Pluralize("axis");
"axes"
gap> Pluralize(8, "axis");
"\>8\< axes"

#
gap> Pluralize("child");
"children"
gap> Pluralize(9, "child");
"\>9\< children"

#
gap> Pluralize("person");
"people"
gap> Pluralize(8, "person");
"\>8\< people"

#
gap> Pluralize("equipment");
"equipment"
gap> Pluralize(7, "equipment");
"\>7\< equipment"

#
gap> Pluralize("information");
"information"
gap> Pluralize(6, "information");
"\>6\< information"

#
gap> Pluralize("series");
"series"
gap> Pluralize(5, "series");
"\>5\< series"

#
gap> Pluralize("species");
"species"
gap> Pluralize(4, "species");
"\>4\< species"

#
gap> Pluralize("gaffe");
"gaffes"
gap> Pluralize(3, "gaffe");
"\>3\< gaffes"

#
gap> Pluralize("life");
"lives"
gap> Pluralize(2, "life");
"\>2\< lives"

#
gap> Pluralize("try");
"tries"
gap> Pluralize(0, "try");
"\>0\< tries"

#
gap> Pluralize("bay");
"bays"
gap> Pluralize(2, "bay");
"\>2\< bays"

#
gap> Pluralize("money");
"moneys"
gap> Pluralize(3, "money");
"\>3\< moneys"

#
gap> Pluralize("toy");
"toys"
gap> Pluralize(4, "toy");
"\>4\< toys"

#
gap> Pluralize("guy");
"guys"
gap> Pluralize(5, "guy");
"\>5\< guys"

#
gap> Pluralize("church");
"churches"
gap> Pluralize(6, "church");
"\>6\< churches"

#
gap> Pluralize("billiards");
"billiards"
gap> Pluralize(7, "billiards");
"\>7\< billiards"

#
gap> Pluralize("train");
"trains"
gap> Pluralize(8, "train");
"\>8\< trains"

#
gap> Pluralize("tractor");
"tractors"
gap> Pluralize(9, "tractor");
"\>9\< tractors"

#
gap> Pluralize("datum");
"data"
gap> Pluralize(8, "datum");
"\>8\< data"

#
gap> Pluralize("quantum");
"quanta"
gap> Pluralize(7, "quantum");
"\>7\< quanta"

#
gap> Pluralize("equilibrium");
"equilibria"
gap> Pluralize(6, "equilibrium");
"\>6\< equilibria"

#
gap> Pluralize("millennium");
"millennia"
gap> Pluralize(5, "millennium");
"\>5\< millennia"

#
gap> STOP_TEST("format.tst",1);
