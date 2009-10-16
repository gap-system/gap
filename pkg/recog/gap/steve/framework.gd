DeclareInfoClass("InfoRecog");

DeclareGlobalFunction("InstallNonConstructiveRecognizer");

DeclareGlobalFunction("InstallFactorizer");

DeclareGlobalFunction("InstallEpimorphismConstructor");

DeclareAttribute("RecognitionInfo", IsGroup, "mutable");

DeclareGlobalFunction("NonConstructivelyRecognize");

DeclareGlobalFunction("FindSimplifyingEpimorphism");

DeclareGlobalFunction("FactorizeGroupElement");

DeclareCategory("IsRecognitionOutcome",IsObject);

DeclareAttribute("NameOfRecognitionOutcome",IsRecognitionOutcome);

DeclareAttribute("DescriptionOfRecognitionOutcome",IsRecognitionOutcome);

DeclareGlobalFunction("DeclareRecognitionOutcome");
