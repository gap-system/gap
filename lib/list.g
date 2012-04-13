#############################################################################
##
#W  list.g                        GAP library                Martin Schönert
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains some  list types and functions that  have to be  known
##  very early in the bootstrap stage (therefore they are not in list.gi)
##


#############################################################################
##
#C  IsListDefault( <list> ) . . . . . . . . methods for arithmetic operations
##
##  <#GAPDoc Label="IsListDefault">
##  <ManSection>
##  <Filt Name="IsListDefault" Arg='list' Type='Category'/>
##
##  <Description>
##  For a list <A>list</A>, <Ref Func="IsListDefault"/> indicates that the
##  default methods for arithmetic operations of lists, such as pointwise
##  addition and multiplication as inner product or matrix product,
##  shall be applicable to <A>list</A>.
##  <P/>
##  <Ref Func="IsListDefault"/> implies <Ref Func="IsGeneralizedRowVector"/>
##  and <Ref Func="IsMultiplicativeGeneralizedRowVector"/>.
##  <P/>
##  All internally represented lists are in this category,
##  and also all lists in the representations <C>IsGF2VectorRep</C>,
##  <C>Is8BitVectorRep</C>, <C>IsGF2MatrixRep</C>, and
##  <C>Is8BitMatrixRep</C>
##  (see&nbsp;<Ref Sect="Row Vectors over Finite Fields"/> and
##  <Ref Sect="Matrices over Finite Fields"/>).
##  <!--  strings and blists:-->
##  <!--  It does not really make sense to have them in <C>IsGeneralizedRowVector</C>.-->
##  Note that the result of an arithmetic operation with lists in
##  <Ref Func="IsListDefault"/> will in general be an internally represented
##  list, so most <Q>wrapped list objects</Q> will not lie in
##  <Ref Func="IsListDefault"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> v:= [ 1, 2 ];;  m:= [ v, 2*v ];;
##  gap> IsListDefault( v );  IsListDefault( m );
##  true
##  true
##  gap> IsListDefault( bas );  IsListDefault( liemat );
##  true
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsListDefault", IsMultiplicativeGeneralizedRowVector );
#T IsListDefault should imply IsAdditiveElement and IsMultiplicativeElement?

InstallTrueMethod( IsListDefault, IsInternalRep and IsList );


#############################################################################
##
#P  IsRectangularTable( <list> )  . . . . table with all rows the same length
##
##  <#GAPDoc Label="IsRectangularTable">
##  <ManSection>
##  <Prop Name="IsRectangularTable" Arg='list'/>
##
##  <Description>
##  A list lies in <C>IsRectangularTable</C> when it is nonempty and its elements
##  are all homogeneous lists of the same family and the same length.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
##  This filter is a Property, not a Category, because it is not
##  always possible to determine cheaply the length of a row (which
##  might be some sort of Enumerator).  If the rows are plain lists
##  then this property should always be known (the kernel type determination
##  for plain lists handles this). Plain lists without mutable
##  elements will remember their rectangularity once it is determined.
##
DeclareProperty( "IsRectangularTable", IsList );

InstallTrueMethod( IsTable, IsRectangularTable );


#############################################################################
##
#V  TYPE_LIST_NDENSE_MUTABLE  . . . . . . . . type of non-dense, mutable list
##
##  <ManSection>
##  <Var Name="TYPE_LIST_NDENSE_MUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_LIST_NDENSE_MUTABLE", NewType( ListsFamily,
    IsMutable and IsList and IsPlistRep ) );


#############################################################################
##
#V  TYPE_LIST_NDENSE_IMMUTABLE	. . . . . . type of non-dense, immutable list
##
##  <ManSection>
##  <Var Name="TYPE_LIST_NDENSE_IMMUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_LIST_NDENSE_IMMUTABLE", NewType( ListsFamily,
    IsList and IsPlistRep ) );


#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_MUTABLE  . . . type of dense, non-homo, mutable list
##
##  <ManSection>
##  <Var Name="TYPE_LIST_DENSE_NHOM_MUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_MUTABLE", NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsPlistRep ) );


#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_IMMUTABLE  . type of dense, non-homo, immutable list
##
##  <ManSection>
##  <Var Name="TYPE_LIST_DENSE_NHOM_IMMUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_IMMUTABLE", NewType( ListsFamily,
        IsList and IsDenseList and IsPlistRep ) );

#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE  . . . 
##
##  <ManSection>
##  <Var Name="TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE", NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsPlistRep and IsSSortedList ) );

#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE  . . . 
##
##  <ManSection>
##  <Var Name="TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE", NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsPlistRep ) );


#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE  . 
##
##  <ManSection>
##  <Var Name="TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE", NewType( ListsFamily,
        IsList and IsDenseList and IsPlistRep and IsSSortedList ) );

#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE  . 
##
##  <ManSection>
##  <Var Name="TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE", NewType( ListsFamily,
        IsList and IsDenseList and IsPlistRep ) );

#############################################################################
##
#V  TYPE_LIST_EMPTY_MUTABLE . . . . . . . . . type of the empty, mutable list
##
##  <ManSection>
##  <Var Name="TYPE_LIST_EMPTY_MUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_LIST_EMPTY_MUTABLE", NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsString and IsPlistRep ) );


#############################################################################
##
#V  TYPE_LIST_EMPTY_IMMUTABLE . . . . . . . type of the empty, immutable list
##
##  <ManSection>
##  <Var Name="TYPE_LIST_EMPTY_IMMUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_LIST_EMPTY_IMMUTABLE", NewType( ListsFamily,
    IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsString and IsPlistRep ) );


#############################################################################
##
#V  TYPE_BLIST_*
##
##  <ManSection>
##  <Var Name="TYPE_BLIST_MUT"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_BLIST_MUT", 
  NewType( CollectionsFamily(BooleanFamily),
    IsMutable and IsInternalRep and IsDenseList and IsHomogeneousList and 
    IS_BLIST_REP ) );
BIND_GLOBAL( "TYPE_BLIST_IMM", 
  NewType( CollectionsFamily(BooleanFamily),
    IsCopyable and IsInternalRep and IsDenseList and IsHomogeneousList and 
    IS_BLIST_REP ) );
BIND_GLOBAL( "TYPE_BLIST_NSORT_MUT", 
  NewType( CollectionsFamily(BooleanFamily),
    IsMutable and IsInternalRep and IsDenseList and IsHomogeneousList and 
    IS_BLIST_REP and Tester(IsSSortedList) ) );
BIND_GLOBAL( "TYPE_BLIST_NSORT_IMM", 
  NewType( CollectionsFamily(BooleanFamily),
    IsCopyable and IsInternalRep and IsDenseList and IsHomogeneousList and 
    IS_BLIST_REP and Tester(IsSSortedList) ) );
BIND_GLOBAL( "TYPE_BLIST_SSORT_MUT", 
  NewType( CollectionsFamily(BooleanFamily),
    IsMutable and IsInternalRep and IsDenseList and IsHomogeneousList and 
    IS_BLIST_REP and Tester(IsSSortedList) and IsSSortedList ) );
BIND_GLOBAL( "TYPE_BLIST_SSORT_IMM", 
  NewType( CollectionsFamily(BooleanFamily),
    IsCopyable and IsInternalRep and IsDenseList and IsHomogeneousList and 
    IS_BLIST_REP and Tester(IsSSortedList) and IsSSortedList ) );
BIND_GLOBAL( "TYPE_BLIST_EMPTY_MUT",
  NewType( CollectionsFamily(BooleanFamily),
    IsMutable and IsInternalRep and IsDenseList and IsHomogeneousList and 
    IS_BLIST_REP and IsEmpty and Tester(IsEmpty) ) );
BIND_GLOBAL( "TYPE_BLIST_EMPTY_IMM", 
  NewType( CollectionsFamily(BooleanFamily),
    IsCopyable and IsInternalRep and IsDenseList and IsHomogeneousList and 
    IS_BLIST_REP and IsEmpty and Tester(IsEmpty) ) );

#############################################################################
##
#F  TYPE_LIST_HOM( <family>, <kernel_number> )	. . return the type of a list
##
##  <ManSection>
##  <Func Name="TYPE_LIST_HOM" Arg='family, kernel_number'/>
##
##  <Description>
##  For <A>kernel_number</A> see <F>objects.h</F> and <F>plist.c</F>:
##  <P/>
##   1: T_PLIST_HOM
##   2: T_PLIST_HOM       + IMMUTABLE
##   3: T_PLIST_HOM_NSORT
##   4: T_PLIST_HOM_NSORT + IMMUTABLE
##   5: T_PLIST_HOM_SSORT
##   6: T_PLIST_HOM_SSORT + IMMUTABLE
##   7: T_PLIST_TAB
##   8: T_PLIST_TAB       + IMMUTABLE
##   9: T_PLIST_TAB_NSORT
##  10: T_PLIST_TAB_NSORT + IMMUTABLE
##  11: T_PLIST_TAB_SSORT
##  12: T_PLIST_TAB_SSORT + IMMUTABLE
##  13: T_PLIST_TAB_RECT
##  14: T_PLIST_TAB_RECT       + IMMUTABLE
##  15: T_PLIST_TAB_RECT_NSORT
##  16: T_PLIST_TAB_RECT_NSORT + IMMUTABLE
##  17: T_PLIST_TAB_RECT_SSORT
##  18: T_PLIST_TAB_RECT_SSORT + IMMUTABLE
##  19: T_PLIST_CYC
##  20: T_PLIST_CYC       + IMMUTABLE
##  21: T_PLIST_CYC_NSORT
##  22: T_PLIST_CYC_NSORT + IMMUTABLE
##  23: T_PLIST_CYC_SSORT
##  24: T_PLIST_CYC_SSORT + IMMUTABLE
##  25: T_PLIST_FFE
##  26: T_PLIST_FFE + IMMUTABLE
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_LIST_HOM", function ( family, knr )
    local   colls;

    colls := CollectionsFamily( family );

    # The Cyclotomic types behave just like the corresponding
    # homogenous types

    if knr > 18 then 
        if knr < 25 then
            knr := knr -18;
        # The FFE types behave just like the corresponding
        # homogenous types
        else
            knr := knr -24;
        fi;
    fi;

    # T_PLIST_HOM
    if   knr = 1  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsPlistRep );

    # T_PLIST_HOM + IMMUTABLE
    elif knr = 2  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsPlistRep );

    # T_PLIST_HOM_NSORT
    elif knr = 3  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsPlistRep );

    # T_PLIST_HOM_NSORT + IMMUTABLE
    elif knr = 4  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsPlistRep );

    # T_PLIST_HOM_SSORT
    elif knr = 5  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsSSortedList and
                        IsPlistRep );

    # T_PLIST_HOM_SSORT + IMMUTABLE
    elif knr = 6  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsSSortedList and
                        IsPlistRep );

    # T_PLIST_TAB
    elif knr = 7  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and IsPlistRep );

    # T_PLIST_TAB + IMMUTABLE
    elif knr = 8  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and IsPlistRep );

    # T_PLIST_TAB_NSORT
    elif knr = 9  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable
                        and IsPlistRep );

    # T_PLIST_TAB_NSORT + IMMUTABLE
    elif knr = 10  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable
                        and IsPlistRep );

    # T_PLIST_TAB_SSORT
    elif knr = 11  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsSSortedList and IsTable and IsPlistRep );

    # T_PLIST_TAB_SSORT + IMMUTABLE
    elif knr = 12  then
        return NewType( colls,
                        IsList and IsDenseList and IsHomogeneousList
                        and Tester(IsSSortedList)
                        and IsCollection and IsSSortedList and IsTable
                        and IsPlistRep );

    # T_PLIST_TAB_RECT
    elif knr = 13  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and HasIsRectangularTable and IsRectangularTable and IsPlistRep );

    # T_PLIST_TAB_RECT + IMMUTABLE
    elif knr = 14  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and HasIsRectangularTable and IsRectangularTable and IsPlistRep );

    # T_PLIST_TAB_RECT_NSORT
    elif knr = 15  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable and HasIsRectangularTable and IsRectangularTable
                        and IsPlistRep );

    # T_PLIST_TAB_RECT_NSORT + IMMUTABLE
    elif knr = 16  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable and HasIsRectangularTable and IsRectangularTable
                        and IsPlistRep );

    # T_PLIST_TAB_RECT_SSORT
    elif knr = 17  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsSSortedList and IsTable and HasIsRectangularTable and IsRectangularTable and IsPlistRep );

    # T_PLIST_TAB_RECT_SSORT + IMMUTABLE
    elif knr = 18  then
        return NewType( colls,
                        IsList and IsDenseList and IsHomogeneousList
                        and Tester(IsSSortedList)
                       and IsCollection and IsSSortedList and IsTable and HasIsRectangularTable 
                       and IsRectangularTable
                        and IsPlistRep );

    else
        Error( "what?  Unknown kernel number ", knr );
    fi;
end );


#############################################################################
##
#M  ASS_LIST( <plist>, <pos>, <obj> ) . . . . . . . . . .  default assignment
##
InstallMethod( ASS_LIST,
    "for plain list and external objects",
    [ IsMutable and IsList and IsPlistRep,
      IsPosInt,
      IsObject ],
    ASS_PLIST_DEFAULT );


#############################################################################
##
#C  IsRange( <obj> )
##
##  <#GAPDoc Label="IsRange">
##  <ManSection>
##  <Filt Name="IsRange" Arg='obj' Type='Category'/>
##
##  <Description>
##  tests if the object <A>obj</A> is a range, i.e. is a dense list of
##  integers that is also a range
##  (see&nbsp;<Ref Sect="Ranges"/> for a definition of <Q>range</Q>).
##  <!-- shouldn't this better be a property?-->
##  <Example><![CDATA[
##  gap> IsRange( [1,2,3] );  IsRange( [7,5,3,1] );
##  true
##  true
##  gap> IsRange( [1,2,4,5] );  IsRange( [1,,3,,5,,7] );
##  false
##  false
##  gap> IsRange( [] );  IsRange( [1] );
##  true
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsRange",
    IsCollection and IsDenseList and IsCyclotomicCollection, IS_RANGE );


#############################################################################
##
#R  IsRangeRep( <obj> )
##
##  <ManSection>
##  <Filt Name="IsRangeRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  For internally represented ranges, there is a special representation
##  which requires only a small amount of memory.
##  </Description>
##  </ManSection>
##
DeclareRepresentationKernel( "IsRangeRep",                                   
    IsInternalRep, [], IS_OBJECT, IS_RANGE_REP );


#############################################################################
##
#F  ConvertToRangeRep( <list> )
##
##  <#GAPDoc Label="ConvertToRangeRep">
##  <ManSection>
##  <Func Name="ConvertToRangeRep" Arg='list'/>
##
##  <Description>
##  For some lists the &GAP; kernel knows that they are in fact ranges.
##  Those lists are represented internally in a compact way instead of the
##  ordinary way.
##  <P/>
##  If <A>list</A> is a range then <Ref Func="ConvertToRangeRep"/> changes
##  the representation of <A>list</A> to this compact representation.
##  <P/>
##  This is important since this representation needs only 12 bytes for
##  the entire range while the ordinary representation needs <M>4 length</M>
##  bytes.
##  <P/>
##  Note that a list that is represented in the ordinary way might still be a
##  range.
##  It is just that &GAP; does not know this.
##  The following rules tell you under which circumstances a range is
##  represented  in the compact way,
##  so you can write your program in such a way that you make best use of
##  this compact representation for ranges.
##  <P/>
##  Lists created by the syntactic construct
##  <C>[ <A>first</A>, <A>second</A>  .. <A>last</A> ]</C> are of course
##  known to be ranges and are represented in the compact way.
##  <P/>
##  If you call <Ref Func="ConvertToRangeRep"/> for a list represented the
##  ordinary way that is indeed a range,
##  the representation is changed from the ordinary to the compact
##  representation.
##  A call of <Ref Func="ConvertToRangeRep"/> for a list that is not a range
##  is ignored.
##  <P/>
##  If you change a mutable range that is represented in the compact way,
##  by assignment, <Ref Func="Add"/> or <Ref Func="Append"/>,
##  the range will be converted to the ordinary representation, even if the
##  change is such that the resulting list is still a proper range.
##  <P/>
##  Suppose you have built a proper range in such a way that it is
##  represented in the ordinary way and that you now want to convert it to
##  the compact representation to save space.
##  Then you should call <Ref Func="ConvertToRangeRep"/> with that list as an
##  argument.
##  You can think of the call to <Ref Func="ConvertToRangeRep"/> as a hint
##  to &GAP; that this list is a proper range.
##  <P/>
##  <Example><![CDATA[
##  gap> r:= [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ];
##  [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
##  gap> ConvertToRangeRep( r );  r;
##  [ 1 .. 10 ]
##  gap> l:= [ 1, 2, 4, 5 ];;  ConvertToRangeRep( l );  l;
##  [ 1, 2, 4, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "ConvertToRangeRep", function( list )
    IsRange( list );
end );

#N
#N This must change -- a range is NOT is IS_PLIST_REP
#N

#############################################################################
##
#V  TYPE_RANGE_SSORT_MUTABLE  . . . . . . . . . type of sorted, mutable range
##
##  <ManSection>
##  <Var Name="TYPE_RANGE_SSORT_MUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_RANGE_SSORT_MUTABLE", 
        NewType(CollectionsFamily(CyclotomicsFamily), 
                IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                Tester(IsSSortedList) and IsRange and IsMutable and
                IsSSortedList
                and IsRangeRep and IsInternalRep));


#############################################################################
##
#V  TYPE_RANGE_NSORT_MUTABLE  . . . . . . . . type of unsorted, mutable range
##
##  <ManSection>
##  <Var Name="TYPE_RANGE_NSORT_MUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_RANGE_NSORT_MUTABLE", 
        NewType(CollectionsFamily(CyclotomicsFamily), 
                IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                Tester(IsSSortedList) and IsRange and IsMutable
                and IsRangeRep and IsInternalRep));



#############################################################################
##
#V  TYPE_RANGE_SSORT_IMMUTABLE  . . . . . . . type of sorted, immutable range
##
##  <ManSection>
##  <Var Name="TYPE_RANGE_SSORT_IMMUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_RANGE_SSORT_IMMUTABLE", 
        NewType(CollectionsFamily(CyclotomicsFamily), 
                IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                Tester(IsSSortedList) and IsRange and
                IsSSortedList
                and IsRangeRep and IsInternalRep));


#############################################################################
##
#V  TYPE_RANGE_NSORT_IMMUTABLE  . . . . . . type of unsorted, immutable range
##
##  <ManSection>
##  <Var Name="TYPE_RANGE_NSORT_IMMUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_RANGE_NSORT_IMMUTABLE", 
        NewType(CollectionsFamily(CyclotomicsFamily), 
                IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                Tester(IsSSortedList) and IsRange 
                and IsRangeRep and IsInternalRep));




#############################################################################
##
#C  IsBlist(<obj>)
##
##  <#GAPDoc Label="IsBlist">
##  <ManSection>
##  <Filt Name="IsBlist" Arg='obj' Type='Category'/>
##
##  <Description>
##  A boolean list (<Q>blist</Q>) is a list that has no holes and contains
##  only <K>true</K> and <K>false</K>.
##  Boolean lists can be represented in an efficient compact form, see 
##  <Ref Sect="More about Boolean Lists"/>  for details.
##  <P/>
##  <Example><![CDATA[
##  gap> IsBlist( [ true, true, false, false ] );
##  true
##  gap> IsBlist( [] );
##  true
##  gap> IsBlist( [false,,true] );  # has holes
##  false
##  gap> IsBlist( [1,1,0,0] );      # contains not only boolean values
##  false
##  gap> IsBlist( 17 );             # is not even a list
##  false
##  ]]></Example>
##  <P/>
##  Boolean lists are lists and all operations for lists are therefore
##  applicable to boolean lists.
##  <P/>
##  Boolean lists can be used in various ways, but maybe the most important
##  application is their use for the description of <E>subsets</E> of finite
##  sets.
##  Suppose <M>set</M> is a finite set, represented as a list.
##  Then a subset <M>sub</M> of <M>set</M> is represented  by a boolean list
##  <M>blist</M> of the same length as <M>set</M> such that
##  <M>blist[i]</M> is <K>true</K>
##  if <M>set[i]</M> is in <M>sub</M>,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsBlist", IsHomogeneousList, IS_BLIST );


#############################################################################
##
#R  IsBlistRep( <obj> )
##
##  <#GAPDoc Label="IsBlistRep">
##  <ManSection>
##  <Filt Name="IsBlistRep" Arg='obj' Type='Representation'/>
##  <Func Name="ConvertToBlistRep"  Arg='blist' />
##  <Returns><K>true</K> or <K>false</K></Returns>
##  <Description>
##  The first function is a filter that returns <K>true</K> if 
##  the object <A>obj</A> is 
##  a boolean list in compact representation and <K>false</K> otherwise, 
##  see  <Ref Sect="More about Boolean Lists"/>.<P/>
##  
##  The second function converts the object <A>blist</A> to a boolean list 
##  in compact representation and returns <K>true</K> if this is possible.
##  Otherwise <A>blist</A> is unchanged and <K>false</K> is returned.
##  <Example>
##  gap> l := [true, false, true];
##  [ true, false, true ]
##  gap> IsBlistRep(l);
##  true
##  gap> l := [true, false, 1]; 
##  [ true, false, 1 ]
##  gap> l[3] := false;
##  false
##  gap> IsBlistRep(l);
##  false
##  gap> ConvertToBlistRep(l);
##  true
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentationKernel( "IsBlistRep",
    IsInternalRep, [], IS_OBJECT, IS_BLIST_REP );
BIND_GLOBAL( "ConvertToBlistRep", IS_BLIST_CONV );


#############################################################################
##
#F  BlistList( <list>, <sub> )
##
##  <#GAPDoc Label="BlistList">
##  <ManSection>
##  <Func Name="BlistList" Arg='list, sub'/>
##
##  <Description>
##  returns a new boolean list that describes the list <A>sub</A>
##  as a sublist of the dense list <A>list</A>.
##  That is <Ref Func="BlistList"/> returns a boolean list <M>blist</M> of
##  the same length as <A>list</A> such that <M>blist[i]</M>
##  is <K>true</K> if <A>list</A><M>[i]</M> is in <A>sub</A>
##  and <K>false</K> otherwise.
##  <P/>
##  <A>list</A> need not be a proper set
##  (see&nbsp;<Ref Sect="Sorted Lists and Sets"/>),
##  even though in this case <Ref Func="BlistList"/> is most efficient.
##  In particular <A>list</A> may contain duplicates.
##  <A>sub</A> need not be a proper sublist of <A>list</A>,
##  i.e., <A>sub</A> may contain elements that are not in <A>list</A>.
##  Those elements of course have no influence on the result of
##  <Ref Func="BlistList"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> BlistList( [1..10], [2,3,5,7] );
##  [ false, true, true, false, true, false, true, false, false, false ]
##  gap> BlistList( [1,2,3,4,5,2,8,6,4,10], [4,8,9,16] );
##  [ false, false, false, true, false, false, true, false, true, false ]
##  ]]></Example>
##  <P/>
##  See also&nbsp;<Ref Func="UniteBlistList"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "BlistList", BLIST_LIST );

#############################################################################
##
#F  UniteBlistList( <list>, <blist>, <sub> )
##
##  <#GAPDoc Label="UniteBlistList">
##  <ManSection>
##  <Func Name="UniteBlistList" Arg='list, blist, sub'/>
##
##  <Description>
##  works like
##  <C>UniteBlist(<A>blist</A>,BlistList(<A>list</A>,<A>sub</A>))</C>.
##  As no intermediate blist is created, the performance is better than the
##  separate function calls.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "UniteBlistList", UNITE_BLIST_LIST );


#############################################################################
##
#O  ListBlist( <list>, <blist> )
##
##  <#GAPDoc Label="ListBlist">
##  <ManSection>
##  <Oper Name="ListBlist" Arg='list, blist'/>
##
##  <Description>
##  returns the sublist <M>sub</M> of the list <A>list</A>, which must have
##  no holes, represented by the boolean list <A>blist</A>, which must have
##  the same length as <A>list</A>.
##  <P/>
##  <M>sub</M> contains the element <A>list</A><M>[i]</M> if
##  <A>blist</A><M>[i]</M> is <K>true</K> and does not contain the
##  element if <A>blist</A><M>[i]</M> is <K>false</K>.
##  The order of the elements in <M>sub</M> is
##  the same as the order of the corresponding elements in <A>list</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> ListBlist([1..8],[false,true,true,true,true,false,true,true]);
##  [ 2, 3, 4, 5, 7, 8 ]
##  gap> ListBlist( [1,2,3,4,5,2,8,6,4,10],
##  > [false,false,false,true,false,false,true,false,true,false] );
##  [ 4, 8, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "ListBlist", LIST_BLIST );


#############################################################################
##
#F  SizeBlist(<blist>)
##
##  <#GAPDoc Label="SizeBlist">
##  <ManSection>
##  <Func Name="SizeBlist" Arg='blist'/>
##
##  <Description>
##  returns the number of entries of the boolean list <A>blist</A> that are
##  <K>true</K>.
##  This is the size of the subset represented by the boolean list
##  <A>blist</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> SizeBlist( [ false, true, false, true, false ] );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "SizeBlist", SIZE_BLIST );


#############################################################################
##
#F  IsSubsetBlist( <blist1>, <blist2> )
##
##  <#GAPDoc Label="IsSubsetBlist">
##  <ManSection>
##  <Func Name="IsSubsetBlist" Arg='blist1, blist2'/>
##
##  <Description>
##  returns <K>true</K> if the boolean list <A>blist2</A> is a subset of the
##  boolean list <A>blist1</A>, which must have equal length,
##  and <K>false</K> otherwise.
##  <A>blist2</A> is a subset of <A>blist1</A> if
##  <A>blist1</A><M>[i] =</M> <A>blist1</A><M>[i]</M> <K>or</K>
##  <A>blist2</A><M>[i]</M> for all <M>i</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> blist1 := [ true, true, false, false ];;
##  gap> blist2 := [ true, false, true, false ];;
##  gap> IsSubsetBlist( blist1, blist2 );
##  false
##  gap> blist2 := [ true, false, false, false ];;
##  gap> IsSubsetBlist( blist1, blist2 );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsSubsetBlist", IS_SUB_BLIST );


#############################################################################
##
#F  UniteBlist( <blist1>, <blist2> )
##
##  <#GAPDoc Label="UniteBlist">
##  <ManSection>
##  <Func Name="UniteBlist" Arg='blist1, blist2'/>
##
##  <Description>
##  <Ref Func="UniteBlist"/> unites the boolean list <A>blist1</A> with the
##  boolean list <A>blist2</A>, which must have the same length.
##  This is equivalent to assigning
##  <A>blist1</A><M>[i] :=</M> <A>blist1</A><M>[i]</M> <K>or</K>
##  <A>blist2</A><M>[i]</M> for all <M>i</M>.
##  <P/>
##  <Ref Func="UniteBlist"/> returns nothing, it is only
##  called to change <A>blist1</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> blist1 := [ true, true, false, false ];;
##  gap> blist2 := [ true, false, true, false ];;
##  gap> UniteBlist( blist1, blist2 );
##  gap> blist1;
##  [ true, true, true, false ]
##  ]]></Example>
##  <P/>
##  The function <Ref Func="UnionBlist" Label="for a list"/> is the
##  nondestructive counterpart to <Ref Func="UniteBlist"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "UniteBlist", UNITE_BLIST );


#############################################################################
##
#F  IntersectBlist( <blist1>, <blist2> )
##
##  <#GAPDoc Label="IntersectBlist">
##  <ManSection>
##  <Func Name="IntersectBlist" Arg='blist1, blist2'/>
##
##  <Description>
##  intersects the boolean list <A>blist1</A> with the boolean list
##  <A>blist2</A>, which must have the same length.
##  This is equivalent to assigning
##  <A>blist1</A><M>[i]:=</M> <A>blist1</A><M>[i]</M> <K>and</K>
##  <A>blist2</A><M>[i]</M> for all <M>i</M>.
##  <P/>
##  <Ref Func="IntersectBlist"/> returns nothing,
##  it is only called to change <A>blist1</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> blist1 := [ true, true, false, false ];;
##  gap> blist2 := [ true, false, true, false ];;
##  gap> IntersectBlist( blist1, blist2 );
##  gap> blist1;
##  [ true, false, false, false ]
##  ]]></Example>
##  <P/>
##  The function <Ref Func="IntersectionBlist" Label="for a list"/> is the
##  nondestructive counterpart to <Ref Func="IntersectBlist"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IntersectBlist", INTER_BLIST );


#############################################################################
##
#F  SubtractBlist( <blist1>, <blist2> )
##
##  <#GAPDoc Label="SubtractBlist">
##  <ManSection>
##  <Func Name="SubtractBlist" Arg='blist1, blist2'/>
##
##  <Description>
##  subtracts the boolean list <A>blist2</A> from the boolean list
##  <A>blist1</A>, which must have equal length.
##  This is equivalent to assigning
##  <A>blist1</A><M>[i]:=</M> <A>blist1</A><M>[i]</M> <K>and</K> <K>not</K>
##  <A>blist2</A><M>[i]</M>
##  for all <M>i</M>.
##  <P/>
##  <Ref Func="SubtractBlist"/> returns nothing, it is only called to change
##  <A>blist1</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> blist1 := [ true, true, false, false ];;
##  gap> blist2 := [ true, false, true, false ];;
##  gap> SubtractBlist( blist1, blist2 );
##  gap> blist1;
##  [ false, true, false, false ]
##  ]]></Example>
##  <P/>
##  The function <Ref Func="DifferenceBlist"/> is the
##  nondestructive counterpart to <Ref Func="SubtractBlist"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "SubtractBlist", SUBTR_BLIST );


#############################################################################
##
#E

