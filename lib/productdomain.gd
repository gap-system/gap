#############################################################################
##
##  This file declares everything we need to work with IsDirectProductDomain
##  objects.
##
##  <#GAPDoc Label="DirectProductFamily">
##  <ManSection>
##  <Func Name="DirectProductFamily" Arg='args'/>
##
##  <Description>
##  <A>args</A> must be a dense list of <Ref Attr="CollectionsFamily"/>
##  families, otherwise the function raises an error.
##  <P/>
##  <Ref Func="DirectProductFamily"/> returns <C>fam</C>, a collections
##  family of <Ref Filt="IsDirectProductElement"/> objects.
##  <P/>
##  <C>fam</C> is the <Ref Filt="CollectionsFamily"/> of
##  <Ref Filt="IsDirectProductElement"/> objects
##  whose <C>i</C>-th component is in <C>ElementsFamily(args[i])</C>.
##  <P/>
##  Note that a collection in <C>fam</C> may not itself be a
##  direct product; it just is a subcollection of a direct product.
##  <P/>
##  <Example><![CDATA[
##  gap> D8 := DihedralGroup(IsPermGroup, 8);;
##  gap> FamilyObj(D8) = CollectionsFamily(PermutationsFamily);
##  true
##  gap> fam := DirectProductFamily([FamilyObj(D8), FamilyObj(D8)]);;
##  gap> ComponentsOfDirectProductElementsFamily(ElementsFamily(fam));
##  [ <Family: "PermutationsFamily">, <Family: "PermutationsFamily"> ]
##  ]]></Example>
##  Also note that not all direct products in &GAP; are created via these
##  families. For example if the arguments to <Ref Func="DirectProduct"/>
##  are permutation groups, then it returns a permutation group as well, whose
##  elements are not <Ref Filt="IsDirectProductElement"/> objects.
##  <P/>
##  <Example><![CDATA[
##  gap> fam = FamilyObj(DirectProduct(D8, D8));
##  false
##  gap> D4 := DihedralGroup(IsPcGroup, 4);;
##  gap> fam2 := DirectProductFamily([FamilyObj(D8), FamilyObj(D4)]);;
##  gap> fam2 = FamilyObj(DirectProduct(D8, D4));
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "DirectProductFamily",
                       "for a dense list of collection families" );

DeclareCategory("IsDirectProductDomain",
               IsDirectProductElementCollection and IsDomain);

DeclareOperation("DirectProductDomain", [IsDenseList]);

DeclareAttribute("ComponentsOfDirectProductDomain", IsDirectProductDomain);
DeclareAttribute("DimensionOfDirectProductDomain", IsDirectProductDomain);
