DeclareAttribute("RecognitionData",IsGroup,"mutable");

## OrderRecog(<elm>,<data>)
# same as `Order' but the order is cached in the `RecognitionData'
# component.
DeclareGlobalFunction("OrderRecog");

RECOGMETHODS:=[];

# flag to indicate a missing identification method
BindGlobal("MISSINGID","missing ID");

## InstallRecognitionMethod(<type>,<cdim>,<cf>,<natc>,<natr>,<fct>)
##  Installs a recognition method.
##  <fct> is the function (3 arguments: Group,type,data) that does the work
##  <type> is the 1st part of the type (name, no parameters)
##  <cdim> is a function that will check the first parameter (dimension). It
##  must return `true' to indicate applicability
##  <cf> is the same for the characteristic of the field
##  <natc> indicates that the function assumes natural characteristic
##  <natr> indicates whether the fct assumes natural representation
DeclareGlobalFunction("InstallRecognitionMethod");

## ConstructiveRecognition(<G> [,<nocands> [,<cands>]]):
##  Does a constructive recognition of the group <G>. If <nocands> is given
##  it is a list of impossible types. If <cands> is given it is a list of
##  types among which the candidate must be.
##  The function will return:
##  A group isomorphism <iso> from <G> to a ``nice'' isomorphic group.
##  ``nice'' in this context means that good methods are available to
##  compute in this group and if possible also that this group can obtain
##  information about itself from data bases.\\
##  `false' if the restirctions of candidates given are provenly wrong.\\
##  `fail' if the recognition did fail, because no suitable recognition
##  method was available. The component `RecognitionData(<G>).type'
##  gives the type for which this fails.
DeclareGlobalFunction("ConstructiveRecognition");

# ProbabilisticRecognitionType(<G>)
## returns the most likely type of recognition for <G>
DeclareGlobalFunction("ProbabilisticRecognitionType");
