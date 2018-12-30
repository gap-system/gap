# Bug #3139
gap> wreathy := WreathProduct(SymmetricGroup(2),SymmetricGroup(5));;
gap> classes := ConjugacyClasses(wreathy);;
gap> badsubgroup := StabilizerOfExternalSet( classes[2] );;
gap> ConjugacyClasses( badsubgroup );;
