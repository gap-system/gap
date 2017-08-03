# Bug: NewSetterFilter from opers.c was being called before the
# InitLibrary function from opers.c was, leading to StringFilterSetter
# not being initialized. This would cause the setter for IS_MUTABLE_OBJ
# to get an essentially undefined name, resp. "garbage".
gap> IS_MUTABLE_OBJ;
<Category "IsMutable">
gap> Setter(IS_MUTABLE_OBJ);
<Category "<<filter-setter>>">
