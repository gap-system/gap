#############################################################################
##
#W  ctblothe.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright 1990-1992,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file provides interfaces to the {\sf CAS} library format of
##  character tables and the {\MOC} format for characters and character
##  tables.
##
##  1. interface to {\sf CAS}
##  2. interface to {\MOC}
##
Revision.ctblothe_gd :=
    "@(#)$Id$";


#############################################################################
##
#T  TODO:
##
#a  MocData( <chi> )
#a  MocInfo( <tbl> )
#o  VirtualCharacterByMocData( <tbl>, <vector> )
#o  CharacterByMocData( <tbl>, <vector> )
##


#############################################################################
##
##  1. interface to {\sf CAS}
##
##  The interface to {\sf CAS} is thought just for printing the {\sf CAS}
##  data to a file.
##


#############################################################################
##
#F  CASString( <tbl> )
##
##  is a string that encodes the {\sf CAS} library format of the character
##  table <tbl>.
##  This string can be printed to a file which then can be read into the
##  {\sf CAS} system using its `get' command (see~\cite{NPP84}).
##
##  The used line length is `SizeScreen()[1]' (see~"SizeScreen").
##
##  Only the known values of the following attributes are used.
##  `ClassParameters' (for partitions only), `ComputedClassFusions',
##  `ComputedPowerMaps', `Identifier', `InfoText', `Irr',
##  `ComputedPrimeBlocks', `ComputedIndicators',
##  `OrdersClassRepresentatives', `Size', `SizesCentralizers'.
##
DeclareGlobalFunction( "CASString" );


#############################################################################
##
##  2. interface to {\MOC}
##
#1  The interface to {\MOC} can be used to print {\MOC} input.
##  Additionally it provides an alternative representation of (virtual)
##  characters.
##
##  The {\MOC}~3 code of a 5 digit number in {\MOC}~2 code is given by the
##  following list.
##  (Note that the code must contain only lower case letters.)
##
##  \begintt
##  ABCD    for  0ABCD
##  a       for  10000
##  b       for  10001          k       for  20001
##  c       for  10002          l       for  20002
##  d       for  10003          m       for  20003
##  e       for  10004          n       for  20004
##  f       for  10005          o       for  20005
##  g       for  10006          p       for  20006
##  h       for  10007          q       for  20007
##  i       for  10008          r       for  20008
##  j       for  10009          s       for  20009
##  tAB     for  100AB
##  uAB     for  200AB
##  vABCD   for  1ABCD
##  wABCD   for  2ABCD
##  yABC    for  30ABC
##  z       for  31000
##  \endtt
##
##  *Note* that any long number in {\MOC}~2 format is divided into packages
##  of length 4, the beginning (!) filled with leading zeros if necessary.
##  Such a number with decimals $d_1, d_2, \ldots, d_{4n+k}$ is the sequence
##  $$
##  0d_1d_2d_3d_4 \ldots 0d_{4n-3}d_{4n-2}d_{4n-1}d_{4n}
##     xd_{4n+1}\ldots d_{4n+k}
##  $$
##  where $0 \leq k \leq 3$,
##  the first digit of $x$ is $1$ if the number is positive and $2$ if the
##  number is negative,
##  and then follow $(4-k)$ zeros.
#1
##  A brief description of the {\MOC} system can be found in~\cite{LP91}.
##


#############################################################################
##
#F  MAKElb11( <listofns> )
##
##  `MAKElb11' prints field information for all number fields with conductor
##  $n$ where the positive integer $n$ is in the list <listofns>.
##
##  The output of `MAKElb11' is used by the {\MOC} system.
##  `MAKElb11( [ 3 .. 189 ] )' will print something very similar to
##  Richard Parker's file `lb11'.
##
DeclareGlobalFunction( "MAKElb11" );


#############################################################################
##
#F  MOCTable( <gaptbl> )
#F  MOCTable( <gaptbl>, <basicset> )
##
##  `MOCTable' returns the {\MOC} table record of the {\GAP} character table
##  <gaptbl>.
##
##  The first form can be used only if <gaptbl> is an ordinary ($G\.0$) table.
##  For Brauer ($G\.p$) tables one has to specify a basic set <basicset> of
##  ordinary irreducibles.
##  <basicset> must be a list of positions of the basic set characters in the
##  `Irr' list of the ordinary table of <gaptbl>.
##
##  The result is a record that contains the information of <gaptbl>
##  in a format similar to the {\MOC}~3 format.
##  This record can e.g.~easily be printed out or be used to print out
##  characters using `MOCString' (see~"MOCString").
##
##  The components of the result are
##  \beginitems
##  `identifier' &
##      the string `MOCTable(<name>)' where <name> is the `Identifier'
##      value of <gaptbl>,
##
##  `GAPtbl' &
##      <gaptbl>,
##
##  `prime' &
##      the characteristic of the field (label `30105' in {\MOC}),
##
##  `centralizers' &
##      centralizer orders for cyclic subgroups (label `30130')
##
##  `orders' &
##      element orders for cyclic subgroups (label `30140')
##
##  `fieldbases' &
##      at position $i$ the Parker basis of the number field generated
##      by the character values of the $i$-th cyclic subgroup.
##      The length of `fieldbases' is equal to the value of label `30110'
##      in {\MOC}.
##
##  `cycsubgps' &
##      `cycsubgps[i] = j' means that class `i' of the {\GAP} table
##      belongs to the `j'-th cyclic subgroup of the {\GAP} table,
##
##  `repcycsub' &
##      `repcycsub[j] = i' means that class `i' of the {\GAP} table
##      is the representative of the `j'-th cyclic subgroup of the
##      {\GAP} table.
##      *Note* that the representatives of {\GAP} table and {\MOC} table
##      need not agree!
##
##  `galconjinfo' &
##      a list $[ r_1, c_1, r_2, c_2, \ldots, r_n, c_n ]$
##      which means that the $i$-th class of the {\GAP} table is
##      the $c_i$-th conjugate of the representative of
##      the $r_i$-th cyclic subgroup on the {\MOC} table.
##      (This is used to translate back to {\GAP} format,
##      stored under label `30160')
##
##  `30170' &
##      (power maps) for each cyclic subgroup (except the trivial one)
##      and each prime divisor of the representative order store four values,
##      namely the number of the subgroup, the power,
##      the number of the cyclic subgroup containing the image,
##      and the power to which the representative must be raised to yield
##      the image class.
##      (This is used only to construct the `30230' power map/embedding
##      information.)
##      In `30170' only a list of lists (one for each cyclic subgroup)
##      of all these values is stored, it will not be used by {\GAP}.
##
##  `tensinfo' &
##      tensor product information, used to compute the coefficients
##      of the Parker base for tensor products of characters
##      (label `30210' in {\MOC}).
##      For a field with vector space basis $(v_1,v_2,\ldots,v_n)$
##      the tensor product information of a cyclic subgroup in {\MOC}
##      (as computed by `fct') is either 1 (for rational classes)
##      or a sequence
##      $$
##      n x_{1,1} y_{1,1} z_{1,1} x_{1,2} y_{1,2} z_{1,2}
##      \ldots x_{1,m_1} y_{1,m_1} z_{1,m_1} 0 x_{2,1} y_{2,1}
##      z_{2,1} x_{2,2} y_{2,2} z_{2,2} \ldots x_{2,m_2}
##      y_{2,m_2} z_{2,m_2} 0 \ldots z_{n,m_n} 0
##      $$
##      which means that the coefficient of $v_k$ in the product
##      $$
##      \left( \sum_{i=1}^{n} a_i v_i \right)
##      \left( \sum_{j=1}^{n} b_j v_j \right)
##      $$
##      is equal to
##      $$
##      \sum_{i=1}^{m_k} x_{k,i} a_{y_{k,i}} b_{z_{k,i}}\ .
##      $$
##      On a {\MOC} table in {\GAP} the `tensinfo' component is
##      a list of lists, each containing exactly the sequence mentioned
##      above.
##
##  `invmap' &
##      inverse map to compute complex conjugate characters,
##      label `30220' in {\MOC}.
##
##  `powerinfo' &
##      field embeddings for $p$-th symmetrizations,
##      $p$ prime in `[ 2 .. 19 ]';
##      note that the necessary power maps must be stored on <gaptbl>
##      to compute this component.
##      (label `30230' in {\MOC})
##
##  `30900' &
##      basic set of restricted ordinary irreducibles in the
##      case of nonzero characteristic,
##      all ordinary irreducibles otherwise.
##  \enditems
##
DeclareGlobalFunction( "MOCTable" );


#############################################################################
##
#F  MOCString( <moctbl> )
#F  MOCString( <moctbl>, <chars> )
##
##  Let <moctbl> be a {\MOC} table record as returned by `MOCTable'
##  (see~"MOCTable").
##  `MOCString' returns a string describing the {\MOC}~3 format of <moctbl>.
##
##  If the second argument <chars> is specified, it must be a list of {\MOC}
##  format characters as returned by `MOCChars' (see~"MOCChars").
##  In this case, these characters are stored under label `30900'.
##  If the second argument is missing then the basic set of ordinary
##  irreducibles is stored under this label.
##
DeclareGlobalFunction( "MOCString" );


#############################################################################
##
#F  ScanMOC( <list> )
##
##  returns a record containing the information encoded in the list <list>.
##  The components of the result are the labels that occur in <list>.
##  If <list> is in {\MOC}~2 format (10000-format),
##  the names of components are 30000-numbers;
##  if it is in {\MOC}~3 format the names of components have `yABC'-format.
##
DeclareGlobalFunction( "ScanMOC" );


#############################################################################
##
#F  GAPChars( <tbl>, <mocchars> )
##
##  Let <tbl> be a character table or a {\MOC} table record,
##  and <mocchars> either a list of {\MOC} format characters
##  (as returned by `MOCChars' (see~"MOCChars")
##  or a list of positive integers such as a record component encoding
##  characters, in a record produced by `ScanMOC' (see~"ScanMOC").
##
##  `GAPChars' returns translations of <mocchars> to {\GAP} character values
##  lists.
##
DeclareGlobalFunction( "GAPChars" );


#############################################################################
##
#F  MOCChars( <tbl>, <gapchars> )
##
##  Let <tbl> be a character table or a {\MOC} table record,
##  and <gapchars> a list of ({\GAP} format) characters.
##  `MOCChars' returns translations of <gapchars> to {\MOC} format.
##
DeclareGlobalFunction( "MOCChars" );


#############################################################################
##
#E

