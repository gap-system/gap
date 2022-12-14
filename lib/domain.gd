#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This declares the operations for domains.
##


#############################################################################
##
##  <#GAPDoc Label="[1]{domain}">
##  <E>Domain</E> is &GAP;'s name for structured sets.
##  The ring of Gaussian integers <M>&ZZ;[\sqrt{{-1}}]</M> is an example of a
##  domain,
##  the group <M>D_{12}</M> of symmetries of a regular hexahedron is another.
##  <P/>
##  The &GAP; library predefines some domains.
##  For example the ring of Gaussian integers is predefined as
##  <Ref Var="GaussianIntegers"/> (see&nbsp;<Ref Chap="Gaussians"/>)
##  and the field of rationals is predefined as <Ref Var="Rationals"/>
##  (see&nbsp;<Ref Chap="Rational Numbers"/>).
##  Most domains are constructed by functions,
##  which are called <E>domain constructors</E>
##  (see&nbsp;<Ref Sect="Constructing Domains"/>).
##  For example the group <M>D_{12}</M> is constructed by the construction
##  <C>Group( (1,2,3,4,5,6), (2,6)(3,5) )</C>
##  (see&nbsp;<Ref Func="Group" Label="for several generators"/>)
##  and the finite field with 16 elements is constructed by
##  <C>GaloisField( 16 )</C>
##  (see&nbsp;<Ref Func="GaloisField" Label="for field size"/>).
##  <P/>
##  The first place where you need domains in &GAP; is the obvious one.
##  Sometimes you simply want to deal with a domain.
##  For example if you want to compute the size of the group <M>D_{12}</M>,
##  you had better be able to represent this group in a way that the
##  <Ref Attr="Size"/> function can understand.
##  <P/>
##  The second place where you need domains in &GAP; is when you want to
##  be able to specify that an operation or computation takes place in a
##  certain domain.
##  For example suppose you want to factor 10 in the ring of Gaussian
##  integers.
##  Saying <C>Factors( 10 )</C> will not do, because this will return the
##  factorization <C>[ 2, 5 ]</C> in the ring of integers.
##  To allow operations and computations to happen in a specific domain,
##  <Ref Oper="Factors"/>, and many other functions as well,
##  accept this domain as optional first argument.
##  Thus <C>Factors( GaussianIntegers, 10 )</C> yields the desired result
##  <C>[ 1+E(4), 1-E(4), 2+E(4), 2-E(4) ]</C>.
##  (The imaginary unit <M>\sqrt{{-1}}</M> is written as <C>E(4)</C>
##  in &GAP;, see <Ref Oper="E"/>.)
##  <#/GAPDoc>
##
##  <#GAPDoc Label="[2]{domain}">
##  <E>Equality</E> and <E>comparison</E> of domains are defined as follows.
##  <P/>
##  Two domains are considered <E>equal</E> if and only if the sets of their
##  elements as computed by <Ref Attr="AsSSortedList"/>) are equal.
##  Thus, in general <C>=</C> behaves as if each domain operand were replaced
##  by its set of elements.
##  Except that <C>=</C> will also sometimes, but not always,
##  work for infinite domains, for which of course &GAP; cannot compute
##  the set of elements.
##  Note that this implies that domains with different algebraic structure
##  may well be equal.
##  As a special case of this, either operand of <C>=</C> may also be a
##  proper set (see&nbsp;<Ref Sect="Sorted Lists and Sets"/>),
##  i.e., a sorted list without holes or duplicates
##  (see <Ref Attr="AsSSortedList"/>),
##  and <C>=</C> will return <K>true</K> if and only if this proper set is
##  equal to the set of elements of the argument that is a domain.
##  <P/>
##  <!-- #T These statements imply that <C>&lt;</C> and <C>=</C> -->
##  <!-- #T comparisons of <E>elements</E> in a domain are always -->
##  <!-- #T defined.  Do we really want to guarantee this? -->
##  <E>No</E> general <E>ordering</E> of arbitrary domains via <C>&lt;</C>
##  is defined in &GAP;&nbsp;4.
##  This is because a well-defined <C>&lt;</C> for domains or, more general,
##  for collections, would have to be compatible with <C>=</C> and would need
##  to be transitive and antisymmetric in order to be used to form ordered
##  sets.
##  In particular, <C>&lt;</C> would have to be independent of the algebraic
##  structure of its arguments because this holds for <C>=</C>,
##  and thus there would be hardly a situation where one could implement
##  an efficient comparison method.
##  (Note that in the case that two domains are comparable with <C>&lt;</C>,
##  the result is in general <E>not</E> compatible with the set theoretical
##  subset relation, which can be decided with <Ref Oper="IsSubset"/>.)
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsGeneralizedDomain( <D> )  . . . . . . . . . test for generalized domain
#C  IsDomain( <D> ) . . . . . . . . . . . . . . . . . . . . . test for domain
##
##  <#GAPDoc Label="IsGeneralizedDomain">
##  <ManSection>
##  <Filt Name="IsGeneralizedDomain" Arg='obj' Type='Category'/>
##  <Filt Name="IsDomain" Arg='obj' Type='Category'/>
##
##  <Description>
##  For some purposes, it is useful to deal with objects that are similar to
##  domains but that are not collections in the sense of &GAP;
##  because their elements may lie in different families;
##  such objects are called <E>generalized domains</E>.
##  An instance of generalized domains are <Q>operation domains</Q>,
##  for example any <M>G</M>-set for a permutation group <M>G</M>
##  consisting of some union of points, sets of points, sets of sets of
##  points etc., under a suitable action.
##  <P/>
##  <Ref Filt="IsDomain"/> is a synonym for
##  <C>IsGeneralizedDomain and IsCollection</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsGeneralizedDomain", IsObject );

DeclareSynonym( "IsDomain", IsGeneralizedDomain and IsCollection );

InstallTrueMethod( IsDuplicateFree, IsDomain );


#############################################################################
##
#A  GeneratorsOfDomain( <D> )
##
##  <#GAPDoc Label="GeneratorsOfDomain">
##  <ManSection>
##  <Attr Name="GeneratorsOfDomain" Arg='D'/>
##
##  <Description>
##  For a domain <A>D</A>, <Ref Attr="GeneratorsOfDomain"/> returns a list
##  containing generators of <A>D</A> with respect to the trivial operational
##  structure, that is interpreting <A>D</A> as a set.
##  The returned list may contain repetitions.
##  <P/>
##  See&nbsp;<Ref Sect="Constructing Domains"/> and for
##  <C>GeneratorsOf<A>Struct</A></C> methods with respect to other available
##  operational structures.
##  <P/>
##  For many domains that have <E>natural generators by construction</E>
##  (for example, the natural generators of a free group of rank two
##  are the two generators stored as value of the attribute
##  <Ref Attr="GeneratorsOfGroup"/>, and the natural generators of
##  a free associative algebra are those generators stored as value of
##  the attribute <Ref Attr="GeneratorsOfAlgebra"/>), each <E>natural</E>
##  generator can be accessed using the <C>.</C> operator. For a domain
##  <A>D</A>, <C><A>D</A>.i</C> returns the <M>i</M>-th generator if
##  <M>i</M> is a positive integer, and if <C>name</C> is the name of a
##  generator of <A>D</A> then <C><A>D</A>.name</C> returns this generator.
##  <P/>
##  <Example><![CDATA[
##  gap> G := DihedralGroup(IsPermGroup, 4);;
##  gap> GeneratorsOfGroup(G);
##  [ (1,2), (3,4) ]
##  gap> GeneratorsOfDomain(G);
##  [ (), (3,4), (1,2), (1,2)(3,4) ]
##  gap> F := FreeGroup("x");
##  <free group on the generators [ x ]>
##  gap> GeneratorsOfGroup(F);
##  [ x ]
##  gap> GeneratorsOfDomain(F);
##  Error, resulting list would be too large (length infinity)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfDomain", IsDomain );


#############################################################################
##
#F  Domain( [<Fam>, ]<generators> )
#O  DomainByGenerators( <Fam>, <generators> )
##
##  <#GAPDoc Label="Domain">
##  <ManSection>
##  <Func Name="Domain" Arg='[Fam, ]generators'/>
##  <Oper Name="DomainByGenerators" Arg='Fam, generators'/>
##
##  <Description>
##  <Ref Func="Domain"/> returns the domain consisting of the elements
##  in the homogeneous list <A>generators</A>.
##  If <A>generators</A> is empty then a family <A>Fam</A> must be entered
##  as the first argument, and the returned (empty) domain lies in the
##  collections family of <A>Fam</A>.
##  <P/>
##  <Ref Oper="DomainByGenerators"/> is the operation called by
##  <Ref Func="Domain"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Domain" );
DeclareOperation( "DomainByGenerators", [ IsFamily, IsList ] );


#############################################################################
##
#F  Parent( <D> )
#O  SetParent( <D>, <P> )
#F  HasParent( <D> )
##
##  <#GAPDoc Label="Parent">
##  <ManSection>
##  <Func Name="Parent" Arg='D'/>
##  <Oper Name="SetParent" Arg='D, P'/>
##  <Filt Name="HasParent" Arg='D'/>
##
##  <Description>
##  It is possible to assign to a domain <A>D</A> one other domain <A>P</A>
##  containing <A>D</A> as a subset,
##  in order to exploit this subset relation between <A>D</A> and <A>P</A>.
##  Note that <A>P</A> need not have the same operational structure as <A>D</A>,
##  for example <A>P</A> may be a magma and <A>D</A> a field.
##  <P/>
##  The assignment is done by calling <Ref Oper="SetParent"/>,
##  and <A>P</A> is called the <E>parent</E> of <A>D</A>.
##  If <A>D</A> has already a parent,
##  calls to <Ref Oper="SetParent"/> will be ignored.
##  <P/>
##  If <A>D</A> has a parent <A>P</A>
##  &ndash;this can be checked with <Ref Filt="HasParent"/>&ndash;
##  then <A>P</A> can be used to gain information about <A>D</A>.
##  First, the call of <Ref Oper="SetParent"/> causes
##  <Ref Oper="UseSubsetRelation"/> to be called.
##  Second, for a domain <A>D</A> with parent,
##  information relative to the parent can be stored in <A>D</A>;
##  for example, there is an attribute <C>NormalizerInParent</C> for storing
##  <C>Normalizer( <A>P</A>, <A>D</A> )</C> in the case that <A>D</A> is a
##  group.
##  (More about such parent dependent attributes can be found in
##  <Ref Sect="In Parent Attributes"/>.)
##  <!-- better make this part of the Reference Manual?-->
##  Note that because of this relative information,
##  one cannot change the parent;
##  that is, one can set the parent only once,
##  subsequent calls to <Ref Oper="SetParent"/> for the same domain <A>D</A>
##  are ignored.
##  <!-- better raise a warning/error?-->
##  Further note that contrary to <Ref Oper="UseSubsetRelation"/>,
##  also knowledge about the parent <A>P</A> might be used
##  that is discovered after the <Ref Oper="SetParent"/> call.
##  <P/>
##  A stored parent can be accessed using <Ref Func="Parent"/>.
##  If <A>D</A> has no parent then <Ref Func="Parent"/> returns <A>D</A>
##  itself, and <Ref Filt="HasParent"/> will return <K>false</K>
##  also after a call to <Ref Func="Parent"/>.
##  So <Ref Func="Parent"/> is <E>not</E> an attribute,
##  the underlying attribute to store the parent is <C>ParentAttr</C>.
##  <!-- add a cross-ref. to section about attributes -->
##  <P/>
##  Certain functions that return domains with parent already set,
##  for example <Ref Func="Subgroup"/>,
##  are described in Section&nbsp;<Ref Sect="Constructing Subdomains"/>.
##  Whenever a function has this property,
##  the &GAP; Reference Manual states this explicitly.
##  Note that these functions <E>do not guarantee</E> a certain parent,
##  for example <Ref Attr="DerivedSubgroup"/> for a perfect
##  group <M>G</M> may return <M>G</M> itself, and if <M>G</M> had already a
##  parent then this is not replaced by <M>G</M>.
##  As a rule of thumb, &GAP; avoids to set a domain as its own parent,
##  which is consistent with the behaviour of <Ref Func="Parent"/>,
##  at least until a parent is set explicitly with <Ref Oper="SetParent"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= Group( (1,2,3), (1,2) );; h:= Group( (1,2) );;
##  gap> HasParent( g );  HasParent( h );
##  false
##  false
##  gap> SetParent( h, g );
##  gap> Parent( g );  Parent( h );
##  Group([ (1,2,3), (1,2) ])
##  Group([ (1,2,3), (1,2) ])
##  gap> HasParent( g );  HasParent( h );
##  false
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ParentAttr", IsDomain );

DeclareSynonym( "SetParent", SetParentAttr );
DeclareSynonym( "HasParent", HasParentAttr );
BIND_GLOBAL( "Parent", function( S )
    if HasParent( S ) then
        return ParentAttr( S );
    else
        return S;
    fi;
end );


#############################################################################
##
#F  InstallAccessToGenerators( <required>, <infotext>, <generators> )
##
##  <ManSection>
##  <Func Name="InstallAccessToGenerators" Arg='required, infotext, generators'/>
##
##  <Description>
##  A free structure <M>F</M> has natural generators by construction.
##  For example, the natural generators of a free group of rank two are the
##  two generators stored as value of the attribute <C>GeneratorsOfGroup</C>,
##  and the natural generators of a free associative algebra are those
##  generators stored as value of the attribute <C>GeneratorsOfAlgebra</C>.
##  Note that semigroup generators are <E>not</E> considered as natural.
##  <P/>
##  Each natural generator of <M>F</M> can be accessed using the <C>.</C> operator.
##  <M>F.i</M> returns the <M>i</M>-th generator if <M>i</M> is a positive integer,
##  and if <A>name</A> is the name of a generator of <M>F</M> then <M>F.<A>name</A></M> returns
##  this generator.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "InstallAccessToGenerators" );


#############################################################################
##
#F  InParentFOA( <name>, <super>, <sub>, <AorP> ) . dispatcher, oper and attr
##
##  <#GAPDoc Label="InParentFOA">
##  <ManSection>
##  <Func Name="InParentFOA" Arg='name, super, sub, AorP'/>
##
##  <Description>
##  This section describes how you can add  new <Q>in parent attributes</Q>
##  (see&nbsp;<Ref Sect="Constructing Subdomains"/>
##  and <Ref Sect="Parents"/>).
##  As an example, we describe how
##  <Ref Oper="Index" Label="for a group and its subgroup"/>
##  and its related functions are implemented.
##  <P/>
##  There are two operations
##  <Ref Oper="Index" Label="for a group and its subgroup"/> and
##  <C>IndexOp</C>,
##  and an attribute <C>IndexInParent</C>.
##  They are created together as shown below,
##  and after they have been created,
##  methods need be installed only for <C>IndexOp</C>.
##  In the creation process, <C>IndexInParent</C>
##  already gets one default method installed
##  (in addition to the usual system getter of each attribute,
##  see&nbsp;<Ref Sect="Attributes"/>),
##  namely <C>D -> IndexOp( Parent( D ), D )</C>.
##  <P/>
##  The operation <Ref Oper="Index" Label="for a group and its subgroup"/>
##  proceeds as follows.
##  <List>
##  <Item>
##    If it is called with the two arguments <A>super</A> and <A>sub</A>,
##    and if <C>HasParent( <A>sub</A> )</C> and
##    <C>IsIdenticalObj( <A>super</A>, Parent( <A>sub</A> ) )</C>
##    are <K>true</K>, <C>IndexInParent</C> is called
##    with argument <A>sub</A>, and the result is returned.
##  </Item>
##  <Item>
##    Otherwise, <C>IndexOp</C> is called with the same arguments that
##    <Ref Oper="Index" Label="for a group and its subgroup"/> was called with,
##    and the result is returned.
##  </Item>
##  </List>
##  (Note that it is in principle possible to install even
##  <Ref Oper="Index" Label="for a group and its subgroup"/>
##  and <C>IndexOp</C> methods
##  for a number of arguments different from two,
##  with <Ref Func="InstallOtherMethod"/>, see <Ref Sect="Attributes"/>).
##  <P/>
##  The call of <Ref Func="InParentFOA"/> declares the operations and the
##  attribute as described above,
##  with names <A>name</A>, <A>name</A><C>Op</C>,
##  and <A>name</A><C>InParent</C>.
##  <A>super-req</A> and <A>sub-req</A> specify the required filters for the
##  first and second argument of the operation <A>name</A><C>Op</C>,
##  which are needed to create this operation with
##  <Ref Func="DeclareOperation"/>.
##  <A>sub-req</A> is also the required filter for the corresponding
##  attribute <A>name</A><C>InParent</C>;
##  note that <Ref Filt="HasParent"/> is <E>not</E> required
##  for the argument <A>U</A> of <A>name</A><C>InParent</C>,
##  because even without a parent stored,
##  <C>Parent( <A>U</A> )</C> is legal, meaning <A>U</A> itself
##  (see&nbsp;<Ref Sect="Parents"/>).
##  The fourth argument must be <Ref Func="DeclareProperty"/>
##  if <A>name</A><C>InParent</C> takes only boolean values (for example in
##  the case <C>IsNormalInParent</C>),
##  and <Ref Func="DeclareAttribute"/> otherwise.
##  <P/>
##  For example, to set up the three objects
##  <Ref Oper="Index" Label="for a group and its subgroup"/>, <C>IndexOp</C>,
##  and <C>IndexInParent</C> together,
##  the declaration file <F>lib/domain.gd</F> contains the following line of
##  code.
##  <Log><![CDATA[
##  InParentFOA( "Index", IsGroup, IsGroup, DeclareAttribute );
##  ]]></Log>
##  <P/>
##  Note that no methods need be installed for
##  <Ref Oper="Index" Label="for a group and its subgroup"/>
##  and <C>IndexInParent</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "InParentFOA", function( name, superreq, subreq, DeclareAorP )
    local str, oper, attr, func;

    # Create the two-argument operation.
    str:= SHALLOW_COPY_OBJ( name );
    APPEND_LIST_INTR( str, "Op" );
    DeclareOperation( str, [ superreq, subreq ] );
    oper:= VALUE_GLOBAL( str );

    # Declare the attribute or property
    # (for cases where the first argument is the parent of the second).
    str:= SHALLOW_COPY_OBJ( name );
    APPEND_LIST_INTR( str, "InParent" );
    DeclareAorP( str, subreq );
    attr:= VALUE_GLOBAL( str );

    # Create the wrapper operation that mainly calls the operation,
    # but also checks resp. sets the attribute if the first argument
    # is identical with the parent of the second.
    DeclareOperation( name, [ superreq, subreq ] );
    func:= VALUE_GLOBAL( name );

    # Install the methods for the wrapper that calls the operation.
    str:= "try to exploit the in-parent attribute ";
    APPEND_LIST_INTR( str, name );
    APPEND_LIST_INTR( str, "InParent" );
    InstallMethod( func,
        str,
        [ superreq, subreq ],
        function( super, sub )
        local value;
        if HasParent( sub ) and IsIdenticalObj( super, Parent( sub ) ) then
          value:= attr( sub );
        else
          value:= oper( super, sub );
        fi;
        return value;
        end );

    # Install the method for the attribute that calls the operation.
    str:= "method that calls the two-argument operation ";
    APPEND_LIST_INTR( str, name );
    APPEND_LIST_INTR( str, "Op" );
    InstallMethod( attr, str, [ subreq and HasParent ],
            D -> oper( Parent( D ), D ) );
end );


#############################################################################
##
#F  RepresentativeFromGenerators( <GeneratorsOfStruct> )
##
##  <ManSection>
##  <Func Name="RepresentativeFromGenerators" Arg='GeneratorsOfStruct'/>
##
##  <Description>
##  We can get a representative of a domain by taking an element of a
##  suitable generators list, so the problem is to specify the generators.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "RepresentativeFromGenerators", function( GeneratorsOfStruct )
    return function( D )
           D:= GeneratorsOfStruct( D );
           if IsEmpty( D ) then
             TryNextMethod();
           fi;
           return Representative( D );
           end;
end );
