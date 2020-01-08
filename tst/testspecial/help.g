SetUserPreference("Pager", "builtin");
?IsNonExistentKeyWord

# trick: in general, we cannot assume the GAP documentation was built
# prior to running this test; but that of GAPDoc definitely is available
?MakeGAPDocDoc

q # this gets send to the pager
