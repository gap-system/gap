#############################################################################
##
#W  domain.gd                   GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This declares the operations for domains.
##
##  *Domain* is {\GAP}\'s  name  for structured sets.   The ring  of Gaussian
##  integers  $Z[I]$  is  an  example  of  a  domain,  the group  $D_{12}$ of
##  symmetries of a regular hexahedron is another.
##
##  The {\GAP}  library predefines some   domains.  For example  the  ring of
##  Gaussian integers is  predefined as 'GaussianIntegers' (see  "Gaussians")
##  and the   field   of rationals   is predefined  as      'Rationals'  (see
##  "Rationals").   Most domains  are  constructed  by  functions,  which are
##  called  *domain   constructors*.   For  example  the    group $D_{12}$ is
##  constructed by the construction 'Group( (1,2,3,4,5,6), (2,6)(3,5) )' (see
##  "Group") and  the finite  field  with  16  elements   is constructed   by
##  'GaloisField( 16 )' (see "GaloisField").
##
##  The first place where  you need domains  in {\GAP}  is  the  obvious one.
##  Sometimes you simply want to talk about a  domain.  For  example  if  you
##  want to compute the size of the group $D_{12}$, you had better be able to
##  represent this group in a way that the 'Size' function can understand.
##
##  The second place where you need domains in {\GAP} is when  you want to be
##  able to specify that an operation or computation takes place in a certain
##  domain.   For  example suppose  you want   to factor 10    in the ring of
##  Gaussian integers.  Saying 'Factors( 10 )' will not do, because this will
##  return the factorization in  the ring of integers '[  2, 5 ]'.  To  allow
##  operations and  computations to happen in   a specific domain, 'Factors',
##  and many other functions  as well, accept  this domain as optional  first
##  argument.   Thus 'Factors( GaussianIntegers,   10 )'  yields  the desired
##  result '[ 1+E(4), 1-E(4), 2+E(4), 2-E(4) ]'.
##
##  Each domain  in  {\GAP} belongs to one  or  more *categories*, which  are
##  simply sets of objects.  The categories in  which a domain lies determine
##  the operations that  are  applicable to   this  domain and  its elements.
##  Examples  of domains are *rings*  (the  functions applicable to a  domain
##  that  is a  ring  are  described in "Rings"),  *fields*   (see "Fields"),
##  *groups*  (see "Groups"), *vector spaces*  (see "Vector  Spaces"), and of
##  course  the category *domains* that   contains all domains (the functions
##  applicable to any domain are described in this chapter).
##
##  Equality and comparison of domains is defined as follows.
##  
##  Two domains are considered equal if and only if the sets of their
##  elements as computed by 'AsListSorted' (see "AsListSorted") are equal.
##  Thus, in general '=' behaves as if each domain operand were replaced by
##  its set of elements.
##  Except  that '=' will also sometimes, but not always, work for infinite
##  domains, for which it is of course difficult to compute the set of
##  elements.
##  Note that this implies that domains with different algebraic structure
##  may well be equal.
##  As a special case of this, either operand may also be a proper set, i.e.,
##  a sorted list without holes or duplicates (see "AsListSorted"), and the
##  result will be 'true' if and only if the set of elements of the domain
##  is, as a set, equal to the set.
##  
#T  *No* general ordering of domains via '\<' is defined in {\GAP}-4.
#T  (But note that the set theoretical subset relation is available via
#T  'IsSubset'.)
#T  Note that a well-defined '\<' for domains or, more general, for
#T  collections, would have to be compatible with '\=' and would need to be
#T  transitive, reflexive, and antisymmetric in order to be used to form
#T  ordered sets.
#T  Then '\<' would have to be independent of the algebraic structure because
#T  '\=' is, and thus there would be hardly a situation where one could
#T  implement a clever comparison method.
#T  (Conversely, locally one can define better comparison methods.)
##  
Revision.domain_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsDomain(<D>) . . . . . . . . . . . . . . . . . . . . . . test for domain
##
##  'IsDomain' returns 'true' if <D> is a domain and 'false' otherwise.
##
IsDomain :=
    NewCategory( "IsDomain",
        IsCollection );


#############################################################################
##
#A  GeneratorsOfDomain(<D>)
##
GeneratorsOfDomain := AsList;
SetGeneratorsOfDomain := SetAsList;
HasGeneratorsOfDomain := HasAsList;


#############################################################################
##
#O  DomainByGenerators(<F>,<generators>)
##
DomainByGenerators := NewOperation( "DomainByGenerators",
    [ IsFamily, IsCollection ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  Domain(<F>,<generators>)
##
Domain := DomainByGenerators;
#T Do we need a dispatcher function around 'DomainByGenerators'?


#############################################################################
##
#O  FinalizeDomain( <D> )
##
##  There are several cases where a domain cannot be constructed by the
##  default method that calls 'Objectify' and sets some attributes.
##  The reason is that --depending on the elements-- one wants to set some
##  more attributes or one wants to specialize the representation and add
##  some components.
##  Examples for this situation are polycyclically presented groups and
##  matrix algebras.
##
##  In order to avoid too many methods for the constructors one can install
##  methods for 'FinalizeDomain'.
##  This operation should be called in the default constructor method after
##  the default construction.
##  Its (non-default) methods must end with a call to 'TryNextMethod',
##  otherwise it cannot be guaranteed that all finalization methods are
##  executed.
##
FinalizeDomain := NewOperation( "FinalizeDomain", [ IsDomain ] );


#############################################################################
##
#A  Parent(<D>)
#O  SetParent(<D>,<P>)
#F  HasParent(<D>)
##
##  'Parent' returns the parent domain of the domain <D>.
##  If the parent has not been set with 'SetParent' then 'Parent( <D> )' is
##  identical to <D>.
##
##  One can set a super-collection <P> of a domain <D> to be the parent of
##  <D> using 'SetParent( <D>, <P>  )'.
##  After this, <P> is the value of 'Parent( <D> )',
##  and 'HasParent( <D> )' is 'true'.
##
ParentAttr := NewAttribute( "Parent", IsDomain );
SetParent  := Setter( ParentAttr );
HasParent  := Tester( ParentAttr );

Parent := function( S )
    if HasParent( S ) then
        return ParentAttr( S );
    else
        return S;
    fi;
end;


#############################################################################
##
#C  IsDomainEnumerator( <obj> )
##
##  Enumerators of domains that are not represented as plain lists may be in
##  this category.
##
IsDomainEnumerator := NewCategory( "IsDomainEnumerator",
    IsEnumerator and IsDuplicateFreeList );


#############################################################################
##
#A  UnderlyingCollection( <enum> )
##
##  An enumerator of a domain can delegate the task to compute its length to
##  'Size' for the underlying domain.
##
UnderlyingCollection := NewAttribute( "UnderlyingCollection",
    IsDomainEnumerator );
SetUnderlyingCollection := Setter( UnderlyingCollection );
HasUnderlyingCollection := Tester( UnderlyingCollection );

InstallInParentMethod := function( attr, filter, op )
    InstallMethod( attr, true, [ filter ], 0,
        dom -> op( Parent( dom ), dom ) );
end;


#############################################################################
##
#F  OperationSubdomain( ... ) makes `ConjugateSubgroup' from `ConjugateGroup'
##
OperationSubdomain := function( name, opr, rel )
    local   req,  i,  oper,  method,  rank,  narg,  methods,  tmp,  k,  info;

    req := false;
    for i  in [ 1, 3 .. LEN_LIST(OPERATIONS)-1 ]  do
        if IS_IDENTICAL_OBJ( OPERATIONS[i], opr )  then
            req := OPERATIONS[i+1];
            break;
        fi;
    od;
    if req = false  then
        Error( "unknown operation ", NAME_FUNCTION(opr) );
    fi;
    req := ShallowCopy( req );
    req[ 1 ] := WITH_HIDDEN_IMPS_FLAGS( AND_FLAGS
                        ( req[ 1 ], FLAGS_FILTER( HasParent ) ) );
    oper := NEW_OPERATION( name );
    ADD_LIST( OPERATIONS, oper );
    ADD_LIST( OPERATIONS, req );

    method := function( D, obj )
        local   E;

        E := opr( D, obj );
        SetParent( E, Parent( D ) );
        return E;
    end;

    # find the rank
    rank := 0;
    for i  in req  do
        rank := rank + SIZE_FLAGS(WITH_HIDDEN_IMPS_FLAGS(i));
    od;

    # get the methods list
    narg := LEN_LIST( req );
    methods := METHODS_OPERATION( oper, narg );

    # find the place to put the new method
    i := 0;
    while i < LEN_LIST(methods) and rank < methods[i+(narg+3)]  do
        i := i + (narg+4);
    od;

    # push the other functions back
    methods{[i+1..LEN_LIST(methods)]+(narg+4)}
        := methods{[i+1..LEN_LIST(methods)]};

    # install the new method
    if   rel = true  then
        methods[i+1] := RETURN_TRUE;
    elif rel = false  then
        methods[i+1] := RETURN_FALSE;
    elif IS_FUNCTION(rel)  then
        methods[i+1] := rel;
        tmp := NARG_FUNCTION(rel);
        if tmp <> AINV(1) and tmp <> LEN_LIST(req)  then
           Error( "<rel> must accept ", LEN_LIST(req), " arguments" );
        fi;
    else
        Error( "<rel> must be a function, 'true', or 'false'" );
    fi;

    # install the filters
    for k  in [ 1 .. narg ]  do
        methods[i+k+1] := req[ k ];
    od;

    # install the method
    if   method = true  then
        methods[i+(narg+2)] := RETURN_TRUE;
    elif method = false  then
        methods[i+(narg+2)] := RETURN_FALSE;
    elif IS_FUNCTION(method)  then
        methods[i+(narg+2)] := method;
        tmp := NARG_FUNCTION(method);
        if tmp <> AINV(1) and tmp <> LEN_LIST(req)  then
           Error( "<method> must accept ", LEN_LIST(req), " arguments" );
        fi;
    else
        Error( "<method> must be a function, 'true', or 'false'" );
    fi;
    methods[i+(narg+3)] := rank;

    # set the name
    info := NAME_FUNCTION(oper);
    methods[i+(narg+4)] := IMMUTABLE_COPY_OBJ(info);

    # flush the cache
    CHANGED_METHODS_OPERATION( oper, narg );

    return oper;
end;

#############################################################################
##
#E  domain.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



