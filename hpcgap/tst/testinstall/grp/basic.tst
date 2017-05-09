#
# tests for grp/basic*.*
#
# groups appear in the order they appear in grp/basic.gd
#
gap> START_TEST("basic.tst");

#
# trivial groups
#
gap> TrivialGroup();
<pc group of size 1 with 0 generators>
gap> TrivialGroup(IsPcGroup);
<pc group of size 1 with 0 generators>
gap> TrivialGroup(IsPermGroup);
Group(())

#
gap> TrivialGroup(1);
Error, usage: TrivialGroup( [<filter>] )
gap> TrivialGroup(IsRing);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `TrivialGroupCons' on 1 arguments

#
# abelian groups
#
gap> AbelianGroup([2,3]);
<pc group of size 6 with 2 generators>
gap> AbelianGroup(IsPcGroup,[2,3]);
<pc group of size 6 with 2 generators>
gap> AbelianGroup(IsPermGroup,[2,3]);
Group([ (1,2), (3,4,5) ])
gap> AbelianGroup(IsFpGroup,[2,3]);
<fp group of size 6 on the generators [ f1, f2 ]>

#
gap> AbelianGroup(2,3);
Error, usage: AbelianGroup( [<filter>, ]<ints> )
gap> AbelianGroup(IsRing,[2,3]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `AbelianGroupCons' on 2 arguments

#
# alternating groups
#
gap> AlternatingGroup(4);
Alt( [ 1 .. 4 ] )
gap> AlternatingGroup(IsPcGroup,4);
<pc group of size 12 with 3 generators>
gap> AlternatingGroup(IsPermGroup,4);
Alt( [ 1 .. 4 ] )

# not (yet?) supported
gap> AlternatingGroup(IsFpGroup,4);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `AlternatingGroupCons' on 2 arguments

#
gap> AlternatingGroup(2,3);
Error, usage: AlternatingGroup( [<filter>, ]<deg> )
gap> AlternatingGroup(IsRing,3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `AlternatingGroupCons' on 2 arguments

#
# cyclic groups
#
gap> CyclicGroup(4);
<pc group of size 4 with 2 generators>
gap> CyclicGroup(IsPcGroup,4);
<pc group of size 4 with 2 generators>
gap> CyclicGroup(IsPermGroup,4);
Group([ (1,2,3,4) ])
gap> CyclicGroup(IsFpGroup,4);
<fp group of size 4 on the generators [ a ]>
gap> G:=CyclicGroup(IsMatrixGroup, GF(2), 12);
<matrix group of size 12 with 1 generators>
gap> FieldOfMatrixGroup(G); DimensionOfMatrixGroup(G);
GF(2)
12

#
gap> CyclicGroup(2,3);
Error, usage: CyclicGroup( [<filter>, ]<size> )
gap> CyclicGroup(IsRing,3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CyclicGroupCons' on 2 arguments

#
# dihedral groups
#
gap> DihedralGroup(8);
<pc group of size 8 with 3 generators>
gap> DihedralGroup(IsPcGroup,8);
<pc group of size 8 with 3 generators>
gap> DihedralGroup(IsPermGroup,8);
Group([ (1,2,3,4), (2,4) ])
gap> DihedralGroup(IsFpGroup,8);
<fp group of size 8 on the generators [ r, s ]>

#
gap> DihedralGroup(2,3);
Error, usage: DihedralGroup( [<filter>, ]<size> )
gap> DihedralGroup(IsRing,3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DihedralGroupCons' on 2 arguments

#
# quaternion groups
#
gap> QuaternionGroup(8);
<pc group of size 8 with 3 generators>
gap> QuaternionGroup(IsPcGroup,8);
<pc group of size 8 with 3 generators>
gap> QuaternionGroup(IsPermGroup,8);
Group([ (1,5,3,7)(2,8,4,6), (1,2,3,4)(5,6,7,8) ])
gap> QuaternionGroup(IsFpGroup,8);
<fp group of size 8 on the generators [ r, s ]>
gap> G:=QuaternionGroup(IsMatrixGroup, GF(3), 8);
<matrix group of size 8 with 2 generators>
gap> FieldOfMatrixGroup(G); DimensionOfMatrixGroup(G);
GF(3)
4

#
gap> QuaternionGroup(2,3);
Error, usage: QuaternionGroup( [<filter>, ]<size> )
gap> QuaternionGroup(IsRing,3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `QuaternionGroupCons' on 2 arguments

#
# elementary abelian groups
#
gap> ElementaryAbelianGroup(8);
<pc group of size 8 with 3 generators>
gap> ElementaryAbelianGroup(IsPcGroup,8);
<pc group of size 8 with 3 generators>
gap> ElementaryAbelianGroup(IsPermGroup,8);
Group([ (1,2), (3,4), (5,6) ])
gap> ElementaryAbelianGroup(IsFpGroup,8);
<fp group of size 8 on the generators [ f1, f2, f3 ]>

#
gap> ElementaryAbelianGroup(2,3);
Error, usage: ElementaryAbelianGroup( [<filter>, ]<size> )
gap> ElementaryAbelianGroup(IsRing,3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ElementaryAbelianGroupCons' on 2 argume\
nts

#
# free abelian groups
#
gap> FreeAbelianGroup(2);
<fp group of size infinity on the generators [ f1, f2 ]>
gap> FreeAbelianGroup(IsFpGroup,2);
<fp group of size infinity on the generators [ f1, f2 ]>

#
gap> FreeAbelianGroup(2,3);
Error, usage: FreeAbelianGroup( [<filter>, ]<rank> )
gap> FreeAbelianGroup(IsRing,3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `FreeAbelianGroupCons' on 2 arguments

#
# extra special groups
#
gap> ExtraspecialGroup(27, 3);
<pc group of size 27 with 3 generators>
gap> ExtraspecialGroup(27, '+');
<pc group of size 27 with 3 generators>
gap> ExtraspecialGroup(8, "-");
<pc group of size 8 with 3 generators>
gap> ExtraspecialGroup(IsPcGroup, 125, 25);
<pc group of size 125 with 3 generators>

#
gap> ExtraspecialGroup(8,3);
Error, <exp> must be '+', '-', "+", or "-"
gap> ExtraspecialGroup(27,2);
Error, <exp> must be <p>, <p>^2, '+', '-', "+", or "-"
gap> ExtraspecialGroup(9,3);
Error, order of an extraspecial group is a nonprime odd power of a prime
gap> ExtraspecialGroup(8);
Error, usage: ExtraspecialGroup( [<filter>, ]<order>, <exponent> )
gap> ExtraspecialGroup(IsRing,27,3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ExtraspecialGroupCons' on 3 arguments

#
# Mathieu groups
#
gap> Transitivity(MathieuGroup(IsPermGroup, 24));
5
gap> Stabilizer(MathieuGroup(24),24) = MathieuGroup(23);
true

# The following does *not* hold (probably for backwards compatibility?)
# gap> Stabilizer(MathieuGroup(23),23) = MathieuGroup(22);
# true
#gap> IsomorphismGroups(Stabilizer(MathieuGroup(23),23), MathieuGroup(22)) <> fail;
#true
gap> Stabilizer(MathieuGroup(22),22) = MathieuGroup(21);
true
gap> Size(Stabilizer(MathieuGroup(21),21));
960

#
gap> Transitivity(MathieuGroup(IsPermGroup, 12));
5
gap> Stabilizer(MathieuGroup(12),12) = MathieuGroup(11);
true
gap> Stabilizer(MathieuGroup(11),11) = MathieuGroup(10);
true
gap> Stabilizer(MathieuGroup(10),10) = MathieuGroup(9);
true
gap> Size(Stabilizer(MathieuGroup(9),9));
8

# not (yet?) supported
gap> MathieuGroup(IsFpGroup,12);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `MathieuGroupCons' on 2 arguments

#
gap> MathieuGroup(13);
Error, degree <d> must be 9, 10, 11, 12, 21, 22, 23, or 24
gap> MathieuGroup(2,3);
Error, usage: MathieuGroup( [<filter>, ]<degree> )
gap> MathieuGroup(IsRing,12);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `MathieuGroupCons' on 2 arguments

#
# symmetric groups
#
gap> SymmetricGroup(3);
Sym( [ 1 .. 3 ] )
gap> SymmetricGroup(IsPcGroup,3);
<pc group of size 6 with 2 generators>
gap> SymmetricGroup(IsPermGroup,3);
Sym( [ 1 .. 3 ] )

# not (yet?) supported
gap> SymmetricGroup(IsFpGroup,4);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `SymmetricGroupCons' on 2 arguments

#
gap> SymmetricGroup(2,3);
Error, usage: SymmetricGroup( [<filter>, ]<deg> )
gap> SymmetricGroup(IsRing,3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `SymmetricGroupCons' on 2 arguments

#
gap> STOP_TEST("basic.tst", 1);
