gap> START_TEST ("$Id: test.tst,v 1.3 2007/10/04 16:40:57 gap Exp $");
gap> LoadPackage ("crisp", "", false);
true
gap> 
gap> PRINT_METHODS := false;
false
gap> 
gap> ReadPackage ("crisp", "tst/classes.g");
true
gap> ReadPackage ("crisp", "tst/basis.g");
true
gap> ReadPackage ("crisp", "tst/boundary.g");
true
gap> ReadPackage ("crisp", "tst/char.g");
true
gap> ReadPackage ("crisp", "tst/in.g");
true
gap> ReadPackage ("crisp", "tst/injectors.g");
true
gap> ReadPackage ("crisp", "tst/normals.g");
true
gap> ReadPackage ("crisp", "tst/projectors.g");
true
gap> ReadPackage ("crisp", "tst/radicals.g");
true
gap> ReadPackage ("crisp", "tst/residuals.g");
true
gap> ReadPackage ("crisp", "tst/socle.g");
true
gap> STOP_TEST ("test.tst", 0);
