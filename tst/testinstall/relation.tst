#############################################################################
##
#W  relation.tst                 GAP library                Robert F. Morse
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  To be listed in testinstall.g
##
gap> START_TEST("relation.tst");
gap> ##################################################
gap> ##
gap> ##  Categories
gap> ##      IsBinaryRelation   (IsEndoGeneralMapping)
gap> ##      IsEquivalenceClass
gap> ##
gap> ##################################################
gap> dom := Domain([1..10]);;  
gap> m := GeneralMappingByElements(dom,dom,List(dom,x->DirectProductElement([x,x])));;
gap> IsBinaryRelation(m);
true
gap> IsEndoGeneralMapping(m);
true
gap> IsReflexiveBinaryRelation(m);
true
gap> HasIsTotal(m);
true
gap> IsSymmetricBinaryRelation(m);
true
gap> IsTransitiveBinaryRelation(m);
true
gap> m=IdentityMapping(dom);
true
gap> e := EquivalenceRelationByRelation(m);;
gap> r := Random(dom);;
gap> c := EquivalenceClassOfElement(e,r);;
gap> IsEquivalenceClass(c);
true
gap> ##################################################
gap> ##
gap> ##  Properties
gap> ##      IsEquivalenceRelation
gap> ##      IsSymmetricBinaryRelation
gap> ##      IsTransitiveBinaryRelation
gap> ##      IsReflexiveBinaryRelation (implies IsTotal)
gap> ##
gap> ##################################################
gap> dom := Domain([1..10]);; tup:=[DirectProductElement([2,4])];;
gap> m := GeneralMappingByElements(dom,dom,Concatenation(List(dom,x->DirectProductElement([x,x])),tup));;
gap> IsReflexiveBinaryRelation(m);
true
gap> HasIsTotal(m);
true
gap> IsTotal(m);
true
gap> IsSymmetricBinaryRelation(m);
false
gap> IsTransitiveBinaryRelation(m);
true
gap> tup := [DirectProductElement([3,4]),DirectProductElement([4,3])];;
gap> m := GeneralMappingByElements(dom,dom,Concatenation(List(dom,x->DirectProductElement([x,x])),tup));;
gap> IsTransitiveBinaryRelation(m);
true
gap> IsReflexiveBinaryRelation(m);
true
gap> IsSymmetricBinaryRelation(m);
true
gap> IsEquivalenceRelation(m);
true
gap> m := GeneralMappingByElements(dom,dom,Concatenation(List(dom,x->DirectProductElement([x,x])),tup));;
gap> IsEquivalenceRelation(m);
true
gap> e := EquivalenceRelationByPairs(dom,[[3,4]]);;
gap> m=e;
true
gap> IsEquivalenceRelation(e);
true
gap> ##################################################
gap> ##
gap> ##  Attributes
gap> ##      EquivalenceRelationPartition
gap> ##      GeneratorsOfEquivalenceRelationPartition
gap> ##      EquivalenceClassRelation
gap> ##      EquivalenceClasses
gap> ##      ImagesListOfBinaryRelation
gap> ##     
gap> ##################################################
gap> dom := Domain([1..10]);; tup:=[DirectProductElement([2,4]),DirectProductElement([4,2])];;
gap> m := GeneralMappingByElements(dom,dom,Concatenation(List(dom,x->DirectProductElement([x,x])),tup));;
gap> IsReflexiveBinaryRelation(m);; IsSymmetricBinaryRelation(m);; 
gap> IsTransitiveBinaryRelation(m);; IsEquivalenceRelation(m);;
gap> e := EquivalenceRelationByPairs(dom,[[2,4]]);;
gap> EquivalenceRelationPartition(e);
[ [ 2, 4 ] ]
gap> GeneratorsOfEquivalenceRelationPartition(e);
[ [ 2, 4 ] ]
gap> e := EquivalenceRelationByPairs(dom,[[2,4],[4,5], [4,5],[1,1]]);;
gap> GeneratorsOfEquivalenceRelationPartition(e);
[ [ 2, 4 ], [ 4, 5 ] ]
gap> r := Random(dom);;
gap> c:= EquivalenceClassOfElement(e,r);;
gap> e = EquivalenceClassRelation(c);
true
gap> ec := EquivalenceClassOfElement(e,2);
{2}
gap> 4 in ec;
true
gap> 1 in ec;
false
gap> Images(e,2); 
[ 2, 4, 5 ]
gap> Images(e,10);
[ 10 ]
gap> br:=BinaryRelationOnPoints([[1],[2,4,5],[3],[4,2,5],[2,4,5],[6],[7],[8],[9],[10]]);;
gap> e=br;
true
gap> Successors(br);
[ [ 1 ], [ 2, 4, 5 ], [ 3 ], [ 2, 4, 5 ], [ 2, 4, 5 ], [ 6 ], [ 7 ], [ 8 ], 
  [ 9 ], [ 10 ] ]
gap> EquivalenceRelationPartition(br);
[ [ 2, 4, 5 ] ]
gap> ##################################################
gap> ##  Operations   (Constructors)
gap> ##      ReflexiveClosureBinaryRelation
gap> ##      SymmetricClosureBinaryRelation
gap> ##      TransitiveClosureBinaryRelation
gap> ##      JoinEquivalenceRelations
gap> ##      MeetEquivalenceRelations
gap> ##      EquivalenceClassOfElement
gap> ##################################################
gap> br := BinaryRelationOnPoints([[2],[3],[4],[5],[6],[7],[8],[9],[10],[]]);;
gap> rc := ReflexiveClosureBinaryRelation(br);;
gap> Successors(rc);
[ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ], [ 5, 6 ], [ 6, 7 ], [ 7, 8 ], 
  [ 8, 9 ], [ 9, 10 ], [ 10 ] ]
gap> sc := SymmetricClosureBinaryRelation(br);;
gap> Successors(sc);
[ [ 2 ], [ 1, 3 ], [ 2, 4 ], [ 3, 5 ], [ 4, 6 ], [ 5, 7 ], [ 6, 8 ], 
  [ 7, 9 ], [ 8, 10 ], [ 9 ] ]
gap> tc := TransitiveClosureBinaryRelation(br);;
gap> Successors(tc);
[ [ 2, 3, 4, 5, 6, 7, 8, 9, 10 ], [ 3, 4, 5, 6, 7, 8, 9, 10 ], 
  [ 4, 5, 6, 7, 8, 9, 10 ], [ 5, 6, 7, 8, 9, 10 ], [ 6, 7, 8, 9, 10 ], 
  [ 7, 8, 9, 10 ], [ 8, 9, 10 ], [ 9, 10 ], [ 10 ], [  ] ]
gap> er := EquivalenceRelationByRelation(br);;
gap> er1 := EquivalenceRelationByPairs(dom,[[2,3],[4,5],[6,5]]);;
gap> UnderlyingRelation(MeetEquivalenceRelations(er,er1))=Intersection(UnderlyingRelation(er),UnderlyingRelation(er1));
true
gap> er2 := EquivalenceRelationByPairs(dom,[[1,2],[3,4],[6,7],[7,8],[8,9],[9,10]]);;
gap> j1 := JoinEquivalenceRelations(er1,er2);;
gap> j2 := JoinEquivalenceRelations(er,er1);;
gap> j1=j2; 
true
gap> m1 := MeetEquivalenceRelations(j1,er2);;
gap> m1=er2;
true
gap> m2 := MeetEquivalenceRelations (er1,er2);;
gap> EquivalenceRelationByPairs(dom,[]) = m2;
true
gap> ##################################################
gap> ##      
gap> ##  Functions    (Constructors)
gap> ##      BinaryRelationByListOfImages
gap> ##      EquivalenceRelationsByProperty
gap> ##      EquivalenceRelationByRelation
gap> ##      EquivalenceRelationByPairs
gap> ##
gap> ##################################################
gap> n:=10;; dom := Domain([1..n]);;
gap> el := List([1..n-1],x->DirectProductElement([x,x+1]));;
gap> e := EquivalenceRelationByRelation(IdentityMapping(dom));;
gap> EquivalenceRelationPartition(e)=[];
true
gap> er := EquivalenceRelationByPairs(dom,el);;
gap> Size(EquivalenceRelationPartition(er))=1;
true
gap> er := EquivalenceRelationByPairs(dom, el);;
gap> Size(EquivalenceClasses(er)) =1;
true
gap> g := SymmetricGroup(4);;
gap> sgs := Domain(NormalSubgroups(g));;
gap> d := Size(sgs);;
gap> el :=  List([1..d-1],x->DirectProductElement([AsList(sgs)[x],AsList(sgs)[x+1]]));;
gap> er1 := EquivalenceRelationByRelation(GeneralMappingByElements(sgs,sgs,el));;
gap> er := EquivalenceRelationByPairs(sgs,el);;
gap> er=er1;
true
gap> el := List([1..n-1],x->DirectProductElement([x,x+1]));;
gap> rel := TransitiveClosureBinaryRelation(GeneralMappingByElements(dom,dom,el));;
gap> Size(UnderlyingRelation(rel));
45
gap> Size(GeneratorsOfEquivalenceRelationPartition(EquivalenceRelationByPairs(dom,el)));
9
gap> STOP_TEST( "relation.tst", 750000);

#############################################################################
##
#E
