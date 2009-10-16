#############################################################################
##
#W  utils.gd               GAP 4 package `genus'                Thomas Breuer
##
#H  @(#)$Id: utils.gd,v 1.6 2002/05/24 15:06:47 gap Exp $
##
#Y  Copyright (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
#1
##  The following functions are used by the package {\sf GENUS}
##  but belong to a more general context.
##
Revision.( "pkg/genus/utils_gd" ) :=
    "@(#)$Id: utils.gd,v 1.6 2002/05/24 15:06:47 gap Exp $";


#############################################################################
##
#P  IsPairwiseCoprimeList( <list> )
##
##  For a list <list> of positive integers, `IsPairwiseCoprimeList' returns
##  `true' if the entries in <list> are pairwise coprime,
##  and `false' otherwise.
##
DeclareProperty( "IsPairwiseCoprimeList",
    IsList and IsCyclotomicCollection );


#############################################################################
##
#F  IsCompatibleAbelianInvariants( <big>, <small> )
##
##  Let <big> and <small> be lists of nonnegative integers that describe the
##  abelian invariants of finitely generated abelian groups $\Gamma$ and $G$,
##  respectively.
##  `IsCompatibleAbelianInvariants' returns `true' if there is an epimorphism
##  from $\Gamma$ onto $G$, and `false' otherwise.
##
##  It is irrelevant whether or not the entries in <big> and <small> are
##  prime powers or composed numbers
##  (mention the format of the ab. inv.!);
##  for example, the lists `[ 2, 3, 4 ]', `[ 6, 4 ]', and `[ 2, 12 ]' are
##  all equivalent as one of the arguments for the function.
##
DeclareGlobalFunction( "IsCompatibleAbelianInvariants" );


#############################################################################
##
#A  EigenvalueInfo( <tbl> )
#O  EigenvalueInfo( <tbl>, <class> )
##
##  In `NongenerationByScottCriterion', we frequently calculate the
##  dimensions of fixed spaces with `DimensionFixedSpace'.
##  We store the information about the power maps needed in the character
##  table.
##
DeclareAttribute( "EigenvalueInfo", IsCharacterTable, "mutable" );
DeclareOperation( "EigenvalueInfo", [ IsCharacterTable, IsPosInt ] );
#T change the library function `Eigenvalues' to use this attribute!


#############################################################################
##
#F  DimensionFixedSpace( <tbl>, <chi>, <i> )
##
##  Let $M$ be a matrix of a representation with character <chi>, for a
##  group element in the <i>-th conjugacy class.
##  `DimensionFixedSpace' returns the dimension of the fixed space of $M$,
##  i.e., the multiplicity of the trivial character in the restriction to
##  $\langle M \rangle$.
##
##  The function `Eigenvalues' (see~"ref:Eigenvalues" in the {\GAP} Reference
##  Manual) could also be used for this purpose; the last entry in the list
##  returned by `Eigenvalues' (called with the same arguments as
##  `DimensionFixedSpace') is the required dimension.
##
DeclareGlobalFunction( "DimensionFixedSpace" );


#############################################################################
##
#V  ORDERS_SIMPLE
#V  MAX_ORDER_SIMPLE
##
DeclareGlobalVariable( "ORDERS_SIMPLE" );
DeclareGlobalVariable( "MAX_ORDER_SIMPLE" );


#############################################################################
##
#F  IsSolvableNumber( <n> )
##
##  For a positive integer <n>, `IsSolvableNumber' returns `true' if every
##  group of order <n> is solvable, and `false' otherwise.
##  In other words, the result is `true' if and only if <n> is not divisible
##  by the order of a nonabelian finite simple group.
##
##  The implementation uses the Classification of Finite Simple Groups.
##
##  cf. IsMonomialNumber?
##
DeclareGlobalFunction( "IsSolvableNumber" );


#############################################################################
##
#F  IsAbelianNumber( <n> )
##
##  For a positive integer <n>, `IsAbelianNumber' returns `true' if every
##  group of order <n> is abelian, and `false' otherwise.
##
DeclareGlobalFunction( "IsAbelianNumber" );


#############################################################################
##
#F  SizesSimpleGroupsInfo( <limit> )
#F  SizesSimpleGroupsInfo( <list> )
#F  SizesSimpleGroupsInfo( <list>, "divides" )
##
##  `SizesSimpleGroupsInfo' computes descriptions of all finite nonabelian
##  simple groups of prescribed orders.
##  The result is always a list of pairs $[ n, s ]$ where $n$ is the order
##  of the simple group in question and $s$ is a string that is a name of the
##  group.
##
##  For a positive integer <limit>, `SizesSimpleGroupsInfo' returns the list
##  of pairs for all nonabelian simple groups up to order <limit>.
##  For a list <list> of positive integers, `SizesSimpleGroupsInfo' returns
##  the list of pairs for all nonabelian simple groups whose orders occur
##  in <list>.
##  For a list <list> of positive integers as the first argument,
##  and the string `"divides"' as the second argument, `SizeSimpleGroupsInfo'
##  returns the list of pairs for all those nonabelian simple groups whose
##  order divides an entry of <list>.
##
##  The implementation uses the Classification of Finite Simple Groups.
##
DeclareGlobalFunction( "SizesSimpleGroupsInfo" );


#############################################################################
##
#V  SIZES_SIMPLE_GROUPS_INFO
##
##  This record stores information about the series of finite nonabelian
##  simple groups, which is used by `SizesSimpleGroupsInfo'
##  (see~"SizesSimpleGroupsInfo").
##  The components are `Lnq', `Snq', `Unq', `Onqevenplus', `Onqevenminus',
##  `Onqodd', `G2q', `F4q', `E6q', `E7q', `E8q', `2B2q', `3D4q', `2G2q',
##  `2F4q', `2E6q', and `Spor'.
##
##  Their values except the last are records with the components `qexp' and
##  `qprime', where `qexp' is a function of $n$ returning the exponent of the
##  $q$-part of the group order in question (for series not depending on $n$
##  the `qexp' value is the exponent itself),
##  and the `qprime' value is a function of ($n$ and) $q$ that returns the
##  $q$-prime part of the group order.
##
##  The `Spor' value is a list of pairs containing the orders and names of
##  the sporadic simple groups and the Tits group.
##
DeclareGlobalVariable( "SIZES_SIMPLE_GROUPS_INFO",
    "record with some functions corresponding to the series of groups" );


#############################################################################
##
#P  IsDihedralGroup( <G> )
##
##  A finite dihedral group $G$ has even order.
##  If the order of $G$ is not divisible by $4$ then the derived subgroup
##  $G^{\prime}$ has index $2$ in $G$,
##  and any element in $G \setminus G^{\prime}$ is of order $2$ and inverts
##  any cyclic generator of $G^{\prime}$.
##  If the order of $G$ is divisible by $4$ then for any generator $g$
##  outside $G^{\prime}$, the group $\langle G^{\prime}, g \rangle$ has index
##  $2$ in $G$, and exactly one such group is cyclic with the property that
##  any cyclic generator is inverted by outer involutions.
##
##  (Note that the cyclic group of order $2$ and the Klein four group are
##  regarded as dihedral groups.)
##
DeclareProperty( "IsDihedralGroup", IsGroup );


#############################################################################
##
#P  IsGroupOfGenusZero( <G> )
##
##  The finite groups with strong symmetric genus $0$
##  are exactly the finite cyclic and polyhedral groups,
##  i.e., dihedral groups, the alternating groups $A_4$ and $A_5$,
##  and the symmetric group $S_4$.
##
##  If <G> is such a group then `IsGroupOfGenusZero' returns `true',
##  otherwise `false'.
##
##  add a property IsPolyhedralGroup?
##
DeclareProperty( "IsGroupOfGenusZero", IsGroup );

InstallTrueMethod( IsGroupOfGenusZero, IsGroup and IsCyclic );
InstallTrueMethod( IsGroupOfGenusZero, IsGroup and IsDihedralGroup );


#############################################################################
##
#P  IsGroupOfGenusOne( <G> )
##
##  The finite groups with strong symmetric genus $1$
##  are exactly those finite factor groups of $\Gamma(0;2,2,2,2)$,
##  $\Gamma(0;2,4,4)$, $\Gamma(0;2,3,6)$, $\Gamma(0;3,3,3)$,
##  and $\Gamma(1;-)$ that do not have strong symmetric genus $0$
##  (see~"IsGroupOfGenusZero").
##
##  If <G> is such a group then `IsGroupOfGenusOne' returns `true',
##  otherwise `false'.
##
DeclareProperty( "IsGroupOfGenusOne", IsGroup );


#############################################################################
##
#E

