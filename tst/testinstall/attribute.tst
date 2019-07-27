gap> START_TEST("attribute.tst");
gap> attributeinfo := InfoLevel(InfoAttributes);;
gap> SetInfoLevel(InfoAttributes, 3);
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
gap> DeclareAttribute("FavouriteFruit", IsObject);
gap> foo := rec();;
gap> fam := NewFamily("FruitFamily");
<Family: "FruitFamily">
gap> Objectify(NewType(fam, IsMutable and IsAttributeStoringRep), foo);
<object>
gap> InstallMethod(FavouriteFruit, [IsObject], x-> "apple");
gap> FavouriteFruit(foo);
"apple"
gap> HasFavouriteFruit(foo);
false
gap> SetSize(foo, 17);
gap> HasSize(foo);
true
gap> Size(foo);
17
gap> SetSize(foo, 16);
#I  Attribute Size of <object> already set to 17, cannot be changed to 16
gap> Size(foo);
17
gap> HasDimension(foo);
false
gap> SetDimension(foo, 3);
gap> HasDimension(foo);
true
gap> SetDimension(foo, 4);
#I  Attribute Dimension of <object> already set to 3, cannot be changed to 4
gap> Dimension(foo);
3
gap> InstallMethod(FavouriteFruit, [HasSize], x-> "pear");
gap> FavouriteFruit(foo);
"pear"
#@if not IsHPCGAP
gap> MakeImmutable(foo);
<object>
gap> FavouriteFruit(foo);
"pear"
gap> HasFavouriteFruit(foo);
true
gap> SetFavouriteFruit(foo, "apple");
#I  Attribute FavouriteFruit of <object> already set to pear, cannot be changed to apple
gap> FavouriteFruit(foo);
"pear"
gap> Unbind(foo!.FavouriteFruit);
gap> SetFavouriteFruit(foo, "apple");
#I  Attribute FavouriteFruit of <object> is marked as assigned, but it has no value
#@fi

# Check a mutable attribute
gap> grp := Group(());;
gap> SetStabChainMutable(grp, [1,2]);
gap> StabChainMutable(grp);
[ 1, 2 ]
gap> SetStabChainMutable(grp, [3,4]);
gap> StabChainMutable(grp);
[ 3, 4 ]
gap> SetInfoLevel(InfoAttributes, attributeinfo);
gap> STOP_TEST("attribute.tst", 1);
