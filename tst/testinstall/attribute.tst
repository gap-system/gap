gap> START_TEST("attribute.tst");
gap> DeclareAttribute();
Error, Function: number of arguments must be at least 2 (not 0)
gap> DeclareAttribute("banana");
Error, Function: number of arguments must be at least 2 (not 1)
gap> DeclareAttribute((), IsFinite);
Error, <name> must be a string
gap> DeclareAttribute("IsBanana", ());
Error, <filter> must be a filter
gap> DeclareAttribute("IsBanana", IsGroup);
gap> DeclareAttribute("IsBanana", IsGroup, ());
Error, Usage: DeclareAttribute( <name>, <filter>[, <mutable>][, <rank>] )
gap> DeclareAttribute("IsBanana", IsGroup, "mutable");
gap> DeclareAttribute("IsBanana", IsGroup, true);
gap> DeclareAttribute("IsBanana", IsGroup, false);
gap> DeclareAttribute("IsBanana", IsGroup, true, "shark");
Error, Usage: DeclareAttribute( <name>, <filter>[, <mutable>][, <rank>] )
gap> DeclareAttribute("IsBanana", IsGroup, true, 15);
gap> DeclareAttribute("IsBanana", IsGroup, "mutable", 15, "Hello, world");
Error, Usage: DeclareAttribute( <name>, <filter>[, <mutable>][, <rank>] )

#
gap> NewAttribute();
Error, Function: number of arguments must be at least 2 (not 0)
gap> NewAttribute("banana");
Error, Function: number of arguments must be at least 2 (not 1)
gap> NewAttribute((), IsFinite);
Error, <name> must be a string
gap> NewAttribute("IsBanana", ());
Error, <filter> must be a filter
gap> NewAttribute("IsBanana", IsGroup);
<Attribute "IsBanana">
gap> NewAttribute("IsBanana", IsGroup, ());
Error, Usage: NewAttribute( <name>, <filter>[, <mutable>][, <rank>] )
gap> NewAttribute("IsBanana", IsGroup, "mutable");
<Attribute "IsBanana">
gap> NewAttribute("IsBanana", IsGroup, true);
<Attribute "IsBanana">
gap> NewAttribute("IsBanana", IsGroup, false);
<Attribute "IsBanana">
gap> NewAttribute("IsBanana", IsGroup, true, "shark");
Error, Usage: NewAttribute( <name>, <filter>[, <mutable>][, <rank>] )
gap> NewAttribute("IsBanana", IsGroup, true, 15);
<Attribute "IsBanana">
gap> NewAttribute("IsBanana", IsGroup, "mutable", 15, "Hello, world");
Error, Usage: NewAttribute( <name>, <filter>[, <mutable>][, <rank>] )

#
gap> STOP_TEST("attribute.tst", 1);
