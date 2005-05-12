#############################################################################
##
#W  domain.gd                   GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This declares the operations for domains.
##

#1
##  *Domain* is {\GAP}'s name for structured sets.
##  The ring of Gaussian integers $Z[i]$ is an example of a domain,
##  the group $D_{12}$ of symmetries of a regular hexahedron is another.
##
##  The {\GAP} library predefines some domains.
##  For example the ring of Gaussian integers is predefined as
##  `GaussianIntegers' (see~"Gaussians") and the field of rationals
##  is predefined as `Rationals' (see~"Rational Numbers").
##  Most domains are constructed by functions,
##  which are called *domain constructors* (see~"Constructing Domains").
##  For example the group $D_{12}$ is constructed by the construction
##  `Group( (1,2,3,4,5,6), (2,6)(3,5) )' (see~"Group")
##  and the finite field with 16 elements is constructed by
##  `GaloisField( 16 )' (see~"GaloisField").
##
##  The first place where you need domains in {\GAP} is the obvious one.
##  Sometimes you simply want to deal with a domain.
##  For example if you want to compute the size of the group $D_{12}$,
##  you had better be able to represent this group in a way that the
##  `Size' function can understand.
##
##  The second place where you need domains in {\GAP} is when you want to
##  be able to specify that an operation or computation takes place in a
##  certain domain.
##  For example suppose you want to factor 10 in the ring of Gaussian
##  integers.
##  Saying `Factors( 10 )' will not do, because this will return the
##  factorization `[ 2, 5 ]' in the ring of integers.
##  To allow operations and computations to happen in a specific domain,
##  `Factors', and many other functions as well, accept this domain as
##  optional first argument.
##  Thus `Factors( GaussianIntegers, 10 )' yields the desired result
##  `[ 1+E(4), 1-E(4), 2+E(4), 2-E(4) ]'.
##  (The imaginary unit $\exp( 2 \pi i/4 )$ is written as `E(4)' in {\GAP}.)
##

#2
##  *Equality* and *comparison* of domains are defined as follows.
##
##  Two domains are considered *equal* if and only if the sets of their
##  elements as computed by `AsSSortedList' (see~"AsSSortedList") are equal.
##  Thus, in general `=' behaves as if each domain operand were replaced by
##  its set of elements.
##  Except that `=' will also sometimes, but not always,
##  work for infinite domains, for which of course {\GAP} cannot compute
##  the set of elements.
##  Note that this implies that domains with different algebraic structure
##  may well be equal.
##  As a special case of this, either operand of `=' may also be a proper set
##  (see~"Sorted Lists and Sets"),
##  i.e., a sorted list without holes or duplicates (see "AsSSortedList"),
##  and `=' will return `true' if and only if this proper set is equal to
##  the set of elements of the argument that is a domain.
##
#T  These statements imply that `\<' and `=' comparisons of *elements* in a
#T  domain are always defined.
#T  Do we really want to guarantee this?
##  
##  *No* general *ordering* of arbitrary domains via `\<' is defined in
##  {\GAP}~4.
##  This is because a well-defined `\<' for domains or, more general, for
##  collections, would have to be compatible with `=' and would need to be
##  transitive and antisymmetric in order to be used to form ordered sets.
##  In particular, `\<' would have to be independent of the algebraic
##  structure of its arguments because this holds for `=',
##  and thus there would be hardly a situation where one could implement
##  an efficient comparison method.
##  (Note that in the case that two domains are comparable with `\<',
##  the result is in general *not* compatible with the set theoretical
##  subset relation, which can be decided with `IsSubset'.)
##
Revision.domain_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsGeneralizedDomain( <D> )  . . . . . . . . . test for generalized domain
#C  IsDomain( <D> ) . . . . . . . . . . . . . . . . . . . . . test for domain
##
##  For some purposes, it is useful to deal with objects that are similar to
##  domains but that are not collections in the sense of {\GAP}
##  because their elements may lie in different families;
##  such objects are called *generalized domains*.
##  An instance of generalized domains are ``operation domains'',
##  for example any $G$-set for a permutation group $G$
##  consisting of some union of points, sets of points, sets of sets of
##  points etc., under a suitable action.
##
##  `IsDomain' is a synonym for `IsGeneralizedDomain and IsCollection'.
##
DeclareCategory( "IsGeneralizedDomain", IsObject );

DeclareSynonym( "IsDomain", IsGeneralizedDomain and IsCollection );

InstallTrueMethod( IsDuplicateFree, IsDomain );


#############################################################################
##
#A  GeneratorsOfDomain( <D> )
##
##  For a domain <D>, `GeneratorsOfDomain' returns a list containing all
##  elements of <D>, perhaps with repetitions.
##  Note that if the domain <D> shall be generated by a list of some elements
##  w.r.t.~the empty operational structure
##  (see~"Operational Structure of Domains"),
##  the only possible choice of elements is to take all elements of <D>.
##  See~"Constructing Domains" and "Changing the Structure" for the concepts
##  of other notions of generation.
##
DeclareAttribute( "GeneratorsOfDomain", IsDomain );


#############################################################################
##
#F  Domain( [<Fam>, ]<generators> )
#O  DomainByGenerators( <Fam>, <generators> )
##
##  `Domain' returns the domain consisting of the elements
##  in the homogeneous list <generators>.
##  If <generators> is empty then a family <Fam> must be entered as first
##  argument, and the returned (empty) domain lies in the collections
##  family of <Fam>.
##
##  `DomainByGenerators' is the operation called by `Domain'.
##
DeclareGlobalFunction( "Domain" );
DeclareOperation( "DomainByGenerators", [ IsFamily, IsList ] );


#############################################################################
##
#F  Parent( <D> )
#O  SetParent( <D>, <P> )
#F  HasParent( <D> )
##
##  It is possible to assign to a domain <D> one other domain <P> containing
##  <D> as a subset,
##  in order to exploit this subset relation between <D> and <P>.
##  Note that <P> need not have the same operational structure as <D>,
##  for example <P> may be a magma and <D> a field.
##
##  The assignment is done by calling `SetParent',
##  and <P> is called the *parent* of <D>.
##  If <D> has already a parent, calls to `SetParent' will be ignored.
##
##  If <D> has a parent <P> --this can be checked with `HasParent'--
##  then <P> can be used to gain information about <D>.
##  First, the call of `SetParent' causes `UseSubsetRelation'
##  (see~"UseSubsetRelation") to be called.
##  Second, for a domain <D> with parent, information relative to the parent
##  can be stored in <D>;
##  for example, there is an attribute `NormalizerInParent' for storing
##  `Normalizer( <P>, <D> )' in the case that <D> is a group.
##  (More about such parent dependent attributes can be found in
##  "ext:In Parent Attributes" in ``Extending GAP''.)
#T better make this part of the Reference Manual?
##  Note that because of this relative information,
##  one cannot change the parent;
##  that is, one can set the parent only once,
##  subsequent calls to `SetParent' for the same domain <D> are ignored.
#T better raise a warning/error?
##  Further note that contrary to `UseSubsetRelation'
##  (see~"UseSubsetRelation"),
##  also knowledge about the parent <P> might be used
##  that is discovered after the `SetParent' call.
##
##  A stored parent can be accessed using `Parent'.
##  If <D> has no parent then `Parent' returns <D> itself,
##  and `HasParent' will returns `false' also after a call to `Parent'.
##  So `Parent' is *not* an attribute,
##  the underlying attribute to store the parent is `ParentAttr'.
##
##  Certain functions that return domains with parent already set,
##  for example `Subgroup',
##  are described in Section~"Constructing Subdomains".
##  Whenever a function has this property,
##  the Reference Manual states this explicitly.
##  Note that these functions *do not guarantee* a certain parent,
##  for example `DerivedSubgroup' (see~"DerivedSubgroup") for a perfect
##  group $G$ may return $G$ itself, and if $G$ had already a parent
##  then this is not replaced by $G$.
##  As a rule of thumb, {\GAP} avoids to set a domain as its own parent,
##  which is consistent with the behaviour of `Parent',
##  at least until a parent is set explicitly with `SetParent'.
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
##  A free structure $F$ has natural generators by construction.
##  For example, the natural generators of a free group of rank two are the
##  two generators stored as value of the attribute `GeneratorsOfGroup',
##  and the natural generators of a free associative algebra are those
##  generators stored as value of the attribute `GeneratorsOfAlgebra'.
##  Note that semigroup generators are *not* considered as natural.
##
##  Each natural generator of $F$ can be accessed using the `\.' operator.
##  $F\.i$ returns the $i$-th generator if $i$ is a positive integer,
##  and if <name> is the name of a generator of $F$ then $F\.<name>$ returns
##  this generator.
##
DeclareGlobalFunction( "InstallAccessToGenerators" );


#############################################################################
##
#F  InParentFOA( <name>, <super>, <sub>, <AorP> ) . dispatcher, oper and attr
##
##  see~"ext:In Parent Attributes" in ``Extending {\GAP}''
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
##  We can get a representative of a domain by taking an element of a
##  suitable generators list, so the problem is to specify the generators.
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


#############################################################################
##
#E

