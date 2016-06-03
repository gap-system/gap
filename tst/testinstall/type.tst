#
gap> IsFilter(IsFinite);
true
gap> IsCategory(IsFinite);
false
gap> IsAttribute(IsFinite);
true
gap> IsProperty(IsFinite);
true
gap> IsOperation(IsFinite);
true

#
gap> IsFilter(IsMagma);
true
gap> IsCategory(IsMagma);
true
gap> IsAttribute(IsMagma);
false
gap> IsProperty(IsMagma);
false
gap> IsOperation(IsMagma);
true

#
gap> IsFilter(IsCommutative);
true
gap> IsCategory(IsCommutative);
false
gap> IsAttribute(IsCommutative);
true
gap> IsProperty(IsCommutative);
true
gap> IsOperation(IsCommutative);
true

#
gap> IsFilter(Size);
false
gap> IsCategory(Size);
false
gap> IsAttribute(Size);
false
gap> IsProperty(Size);
false
gap> IsOperation(Size);
true

#
gap> FilterByName("IsCommutative");
<Property "IsCommutative">
gap> CategoryByName("IsMagma");
<Category "IsMagma">

#
gap> r := LocationOfDeclaration(IsCommutative);;
gap> IsRecord(r);
true
gap> IsBound(r.file); IsBound(r.line);
true
true
