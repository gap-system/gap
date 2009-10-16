#############################################################################
##
#W  crystcat.gd                GAP library                     Volkmar Felsch
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations for fthe crystallographic groups
##  library.
##


#############################################################################
##
##  Some global variables.
##


#############################################################################
##
#A  CrystCatRecord( <G> )
##
DeclareAttribute( "CrystCatRecord", IsGroup, "mutable" );


#############################################################################
##
#F  CR_CharTableQClass( <CR parameter list> )
##
##  'CR_CharTableQClass'  returns  the  character table  of a  representative
##  group of the specified Q-class.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'CharTableQClass'.
##
DeclareGlobalFunction("CR_CharTableQClass");


#############################################################################
##
#F  CR_DisplayQClass( <CR parameter list> )
##
##  'CR_DisplayQClass'  displays  for the  specified  Q-class  the  following
##  information:
##  - the size of the groups in the Q-class,
##  - the isomorphism type of the groups in the Q-class,
##  - the Hurley pattern,
##  - the rational constituents,
##  - the number of Z-classes in the Q-class, and
##  - the number of space-group types in the Q-class.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'DisplayQClass'.
##
DeclareGlobalFunction("CR_DisplayQClass");


#############################################################################
##
#F  CR_DisplaySpaceGroupGenerators( <CR parameter list> )
##
##  'CR_DisplaySpaceGroupGenerators'  displays the non-translation generators
##  of the space group specified by the given parameters.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'DisplaySpaceGroupGenerators'.
##
DeclareGlobalFunction("CR_DisplaySpaceGroupGenerators");


#############################################################################
##
#F  CR_DisplaySpaceGroupType( <CR parameter list> )
##
##  'CR_DisplaySpaceGroupType'  displays  for the  specified space-group type
##  the following information:
##  - the orbit size associated with the space-group type,
##  - the IT number (only in case dim = 2 or dim = 3), and
##  - the Hermann-Mauguin symbol (only in case dim = 2 or dim = 3).
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'DisplaySpaceGroupType'.
##
DeclareGlobalFunction("CR_DisplaySpaceGroupType");


#############################################################################
##
#F  CR_DisplayZClass( <CR parameter list> )
##
##  'CR_DisplayZClass'  displays  for the  specified  Z-class  the  following
##  information:
##  - the Hermann-Mauguin symbol  of a representative space-group type  which
##    belongs to the Z-class (only in case dim = 2 or dim = 3),
##  - the Bravais type,
##  - some decomposability information,
##  - the number of space-group types belonging to the Z-class, and
##  - the size of the associated cohomology group.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'DisplayZClass'.
##
DeclareGlobalFunction("CR_DisplayZClass");


#############################################################################
##
#F  CR_FpGroupQClass( <CR parameter list> )
##
##  'CR_FpGroupQClass'  returns a f. p. group isomorphic to the groups in the
##  specified Q-class.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'FpGroupQClass'.
##
DeclareGlobalFunction("CR_FpGroupQClass");


#############################################################################
##
#F  CR_GeneratorsSpaceGroup( <CR parameter list> )
##
##  'CR_GeneratorsSpaceGroup'  returns the  non-translation generators of the
##  space group specified by the given parameters.
##
DeclareGlobalFunction("CR_GeneratorsSpaceGroup");


#############################################################################
##
#F  CR_GeneratorsZClass( <dim>, <zclass> )
##
##  'CR_GeneratorsZClass'   returns  a   set  of  matrix  generators   for  a
##  representative of the specified Z-class. These generators are chosen such
##  that  they  satisfy  the  defining  relators  which are  returned  by the
##  'CR_FpGroupQClass'  function for the representative  of the corresponding
##  Q-class.
##
DeclareGlobalFunction("CR_GeneratorsZClass");


#############################################################################
##
#F  CR_InitializeRelators( <CR catalogue> )
##
##  'CR_InitializeRelators'   initializes  the  relator  words  list  of  the
##  crystallographic goups catalogue.
##
DeclareGlobalFunction("CR_InitializeRelators");


#############################################################################
##
#F  CR_MatGroupZClass( <CR parameter list> )
##
##  'CR_MatGroupZClass'  returns  a  representative  group  of the  specified
##  Z-class.  The generators  of the  resulting matrix group  are chosen such
##  that they  satisfy  the  defining  relators  which  are  returned  by the
##  'CR_FpGroupQClass' function  for the representative  of the corresponding
##  Q-class.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'MatGroupZClass'.
##
DeclareGlobalFunction("CR_MatGroupZClass");


#############################################################################
##
#F  CR_Name( <string>, <CR parameter list>, <nparms> )
##
##  'CR_Name'  returns  the "name"  of the  specified object  which  may be a
##  Z-class representative,  a Q-class representative or its character table,
##  or a space group.  The resulting name  is a string  which consists of the
##  given string  followed by the relevant parameters  which are separated by
##  commas and enclosed in parentheses.
##
DeclareGlobalFunction("CR_Name");


#############################################################################
##
#F  CR_NormalizerZClass( <CR parameter list> )
##
##  'CR_NormalizerZClass'   returns   the  normalizer  in  GL(dim,Z)  of  the
##  specified  Z-class  representative  matrix  group.  If the  order  of the
##  normalizer is  finite,  then the  group record components  "crZClass" and
##  "crConjugator" will be set properly.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'NormalizerZClass'.
##
DeclareGlobalFunction("CR_NormalizerZClass");


#############################################################################
##
#F  CR_Parameters( [ <dim>, <system>, <qclass>, <zclass>, <sgtype> ], nparms)
#F  CR_Parameters( [ <dim>, <system>, <qclass>, <zclass> ], nparms )
#F  CR_Parameters( [ <dim>, <system>, <qclass> ], nparms )
#F  CR_Parameters( [ <dim>, <IT number> ], nparms )
#F  CR_Parameters( [ <Hermann-Mauguin symbol> ], nparms )
##
##  Valid argument lists are
##
##     [ dim, sys, qcl, zcl, sgt ], 5
##     [ dim, sys, qcl, zcl ], 4
##     [ dim, sys, qcl ], 3
##     [ 3, it ], n
##     [ 2, it ], n
##     [ symbol ], n
##
##  where
##
##  dim = dimension,
##  sys = crystal system number with respect to a given dimension,
##  qcl = Q-class number  with respect to given dimension and crystal system,
##  zcl = Z-class number with respect to given dimension, crystal system, and
##        Q-class,
##  sgt = space-group type  with respect to given dimension,  crystal system,
##        Q-class, and Z-class,
##  it  = corresponding  number   in  the   International  Tables  (only  for
##        dimensions 2 and 3),
##  n   = 3 or 4 or 5,
##  symbol = Hermann-Mauguin symbol (only for dimensions 2 or 3).
##
##  'CR_Parameters' checks the given arguments to be consistent and in range,
##   and returns them in form of an "internal CR parameter list"
##
##      [ dim, sys, qcl, zcl, sgt ]
##
##  which  contains  the  "local parameters"  of the  respective object.  The
##  following  "global parameters"  of the  same  object  are used  as  local
##  variables.
##
##  q   = Q-class number  with respect to the  list of all  Q-classes  of the
##        current dimension,
##  z   = Z-class number  with respect to the  list of all  Z-classes  of the
##        current dimension,
##  t   = space-group type  with respect to the list of all space-group types
##        of the current dimension,
##  CR  = catalogue   record   CrystGroupsCatalogue[dim]   for  the   current
##        dimension dim.
##
DeclareGlobalFunction("CR_Parameters");


#############################################################################
##
#F  CR_PcGroupQClass(<CR parameter list>,<warning>)
##                                                         
##  'CR_PcGroupQClass'  returns  a pc group  isomorphic  to the groups in the
##  specified Q-class.  If <warning> = true, then a warning will be displayed
##  in case that the given presentation is not a prime order pcgs.
##                               
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'PcGroupQClass'.
##
DeclareGlobalFunction("CR_PcGroupQClass");


#############################################################################
##
#F  CR_SpaceGroup( <CR parameter list> )
##
##  'CR_SpaceGroup'  returns  a  representative  matrix  group  (of dimension
##  dim+1) of the specified space-group type.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'SpaceGroup'.
##
##  In particular, the function expects that, whenever the order of the point
##  group is not a multiple of 60,  the given  point group presentation  is a
##  polycyclic power commutator presentation  containing  a list of  n  power
##  relators  and  n*(n-1)/2  commutator relators  in some  prescribed order,
##  where n is the number of its generators.
##
DeclareGlobalFunction("CR_SpaceGroup");


#############################################################################
##
#F  CR_ZClassRepsDadeGroup( <CR parameter list>, <d> )
##
##  'CR_ZClassRepsDadeGroup'  returns  a  list of  representatives  of  those
##  conjugacy classes  of subgroups of the given Dade group  which consist of
##  groups belonging to the given Z-class.
##
##  This is an  internal function  which does  not  check the arguments.  The
##  corresponding public function is 'ZClassRepsDadeGroup'.
##
DeclareGlobalFunction("CR_ZClassRepsDadeGroup");


#############################################################################
##
#F  CharTableQClass( <dim>, <system>, <qclass> )
#F  CharTableQClass( <dim>, <IT number> )
#F  CharTableQClass( <Hermann-Mauguin symbol> )
##
##  'CharTableQClass'  returns the  character table of a representative group
##  of the specified Q-class.
##
DeclareGlobalFunction("CharTableQClass");


#############################################################################
##
#F  DadeGroup( <dim>, <n> )
##
##  'DadeGroup'  returns the n-th Dade group of dimension dim.
##
DeclareGlobalFunction("DadeGroup");


#############################################################################
##
#F  DadeGroupNumbersZClass( <dim>, <system>, <qclass>, <zclass> )
#F  DadeGroupNumbersZClass( <dim>, <IT number> )
#F  DadeGroupNumbersZClass( <Hermann-Mauguin symbol> )
##
##  'DadeGroupNumbersZClass'  returns  a list  of the  numbers of  those Dade
##  groups which contain groups from the given Z-class.
##
DeclareGlobalFunction("DadeGroupNumbersZClass");


#############################################################################
##
#F  DisplayCrystalFamily( <dim>, <family> )
##
##  'DisplayCrystalFamily'  displays  for the  specified  crystal family  the
##  following information:
##  - the family name,
##  - the number of parameters,
##  - the common rational decomposition pattern,
##  - the common real decomposition pattern,
##  - the number of crystal systems in the family, and
##  - the number of Bravais flocks in the family.
##
DeclareGlobalFunction("DisplayCrystalFamily");


#############################################################################
##
#F  DisplayCrystalSystem( <dim>, <system> )
##
##  'DisplayCrystalSystem'  displays  for the  specified  crystal system  the
##  following information:
##  - the number of Q-classes in the crystal system, and
##  - the triple  (dim, sys, qcl)  of parameters of the Q-class  which is the
##    holohedry of the crystal system.
##
DeclareGlobalFunction("DisplayCrystalSystem");


#############################################################################
##
#F  DisplayQClass( <dim>, <system>, <qclass> )
#F  DisplayQClass( <dim>, <IT number> )
#F  DisplayQClass( <Hermann-Mauguin symbol> )
##
##  'DisplayQClass'   displays   for  the  specified  Q-class  the  following
##  information:
##  - the size of the groups in the Q-class,
##  - the isomorphism type of the groups in the Q-class,
##  - the Hurley pattern,
##  - the rational constituents,
##  - the number of Z-classes in the Q-class, and
##  - the number of space-group types in the Q-class.
##
DeclareGlobalFunction("DisplayQClass");


#############################################################################
##
#F  DisplaySpaceGroupGenerators( <dim>, <system>,<qclass>,<zclass>,<sgtype> )
#F  DisplaySpaceGroupGenerators( <dim>, <IT number> )
#F  DisplaySpaceGroupGenerators( <Hermann-Mauguin symbol> )
##
##  'DisplaySpaceGroupGenerators'  displays the non-translation generators of
##  the space group specified by the given parameters.
##
DeclareGlobalFunction("DisplaySpaceGroupGenerators");


#############################################################################
##
#F  DisplaySpaceGroupType( <dim>, <system>, <qclass>, <zclass>, <sgtype> )
#F  DisplaySpaceGroupType( <dim>, <IT number> )
#F  DisplaySpaceGroupType( <Hermann-Mauguin symbol> )
##
##  'DisplaySpaceGroupType'  displays for the  specified space-group type the
##  following information:
##  - the orbit size associated with the space-group type,
##  - the IT number (only in case dim = 2 or dim = 3), and
##  - the Hermann-Mauguin symbol (only in case dim = 2 or dim = 3).
##
DeclareGlobalFunction("DisplaySpaceGroupType");


#############################################################################
##
#F  DisplayZClass( <dim>, <system>, <qclass>, <zclass> )
#F  DisplayZClass( <dim>, <IT number> )
#F  DisplayZClass( <Hermann-Mauguin symbol> )
##
##  'DisplayZClass'   displays   for  the  specified  Z-class  the  following
##  information:
##  - the Hermann-Mauguin symbol  of a representative space-group type  which
##    belongs to the Z-class (only in case dim = 2 or dim = 3),
##  - the Bravais type,
##  - some decomposability information,
##  - the number of space-group types belonging to the Z-class, and
##  - the size of the associated cohomology group.
##
DeclareGlobalFunction("DisplayZClass");


#############################################################################
##
#F  FpGroupQClass( <dim>, <system>, <qclass> )
#F  FpGroupQClass( <dim>, <IT number> )
#F  FpGroupQClass( <Hermann-Mauguin symbol> )
##
##  'FpGroupQClass'  returns a  f. p. group  isomorphic to the groups  in the
##  specified Q-class.
##
DeclareGlobalFunction("FpGroupQClass");


#############################################################################
##
#F  MatGroupZClass( <dim>, <system>, <qclass>, <zclass> )
#F  MatGroupZClass( <dim>, <IT number> )
#F  MatGroupZClass( <Hermann-Mauguin symbol> )
##
##  'MatGroupZClass' returns a representative group of the specified Z-class.
##  The generators  of the resulting matrix group  are chosen such  that they
##  satisfy   the    defining   relators    which   are   returned   by   the
##  'FpGroupQClass'  function  for the  representative  of the  corresponding
##  Q-class.
##
DeclareGlobalFunction("MatGroupZClass");


#############################################################################
##
#F  NormalizerZClass( <dim>, <system>, <qclass>, <zclass> )
#F  NormalizerZClass( <dim>, <IT number> )
#F  NormalizerZClass( <Hermann-Mauguin symbol> )
##
##  'NormalizerZClass'  returns the normalizer in GL(dim,Z)  of the specified
##  Z-class representative matrix group.  If the  order of the  normalizer is
##  finite,  then the  group record components  "crZClass" and "crConjugator"
##  will be set properly.
##
DeclareGlobalFunction("NormalizerZClass");


#############################################################################
##
#F  NrCrystalFamilies( <dim> )
##
##  'NrCrystalFamilies'  returns the  number of crystal families of the given
##  dimension.
##
DeclareGlobalFunction("NrCrystalFamilies");


#############################################################################
##
#F  NrCrystalSystems( <dim> )
##
##  'NrCrystalSystems'  returns  the number  of crystal systems  of the given
##  dimension.
##
DeclareGlobalFunction("NrCrystalSystems");


#############################################################################
##
#F  NrDadeGroups( <dim> )
##
##  'NrDadeGroups'  returns the number of Dade groups of the given dimension.
##
DeclareGlobalFunction("NrDadeGroups");


#############################################################################
##
#F  NrQClassesCrystalSystem( <dim>, <system> )
##
##  'NrQClassesCrystalSystem'  returns the  number of Q-classes  in the given
##  crystal system.
##
DeclareGlobalFunction("NrQClassesCrystalSystem");


#############################################################################
##
#F  NrSpaceGroupTypesZClass( <dim>, <system>, <qclass>, <zclass> )
#F  NrSpaceGroupTypesZClass( <dim>, <IT number> )
#F  NrSpaceGroupTypesZClass( <Hermann-Mauguin symbol> )
##
##  'NrSpaceGroupTypesZClass'  returns the number of space-group types in the
##  given Z-class.
##
DeclareGlobalFunction("NrSpaceGroupTypesZClass");


#############################################################################
##
#F  NrZClassesQClass( <dim>, <system>, <qclass> )
#F  NrZClassesQClass( <dim>, <IT number> )
#F  NrZClassesQClass( <Hermann-Mauguin symbol> )
##
##  'NrZClassesQClass'  returns the number of Z-classes in the given Q-class.
##
DeclareGlobalFunction("NrZClassesQClass");


#############################################################################
##
#F  PcGroupQClass( <dim>, <system>, <qclass> )
#F  PcGroupQClass( <dim>, <IT number> )
#F  PcGroupQClass( <Hermann-Mauguin symbol> )
##
##  'PcGroupQClass'  returns  an ag group  isomorphic  to the  groups  in the
##  specified Q-class.
##
DeclareGlobalFunction("PcGroupQClass");


#############################################################################
##
#F  SpaceGroupOnLeftBBNWZ( <dim>, <system>, <qclass>, <zclass>, <sgtype> )
#F  SpaceGroupOnLeftBBNWZ( <dim>, <IT number> )
#F  SpaceGroupOnLeftBBNWZ( <Hermann-Mauguin symbol> )
##
##  'SpaceGroupOnLeftBBNWZ'  returns a  representative matrix group 
##  (of dimension dim+1) of the specified space-group type.
##
DeclareGlobalFunction("SpaceGroupOnLeftBBNWZ");


#############################################################################
##
#F  SpaceGroupOnRightBBNWZ( <dim>, <system>, <qclass>, <zclass>, <sgtype> )
#F  SpaceGroupOnRightBBNWZ( <dim>, <IT number> )
#F  SpaceGroupOnRightBBNWZ( <Hermann-Mauguin symbol> )
#F  SpaceGroupOnRightBBNWZ( S )
##
##  'SpaceGroupOnRightBBNWZ'  returns the transposed matrix group of
##  the given or specified space group.
##
##  The reason is the following. Each space group is presented in the form of
##  a group of augmented matrices (of dimension dim+1) of the following form:
##
##          [  M  | t ]
##          [-----+---]          Here, M is the `linear part' and
##          [  0  | 1 ]          t is the `translational part'.
##
##  Therefore,  the natural action of a space group in this form  is from the
##  left.  This collides with the convention in GAP  to have all actions from
##  the right. This function does the necessary conversions. In fact, it does
##  not only transpose the matrices, but it also adapts the relators given in
##  CrystCatRecord(S).fpGroup to the new generators.
##
DeclareGlobalFunction("SpaceGroupOnRightBBNWZ");


#############################################################################
##
#F  SpaceGroupBBNWZ( <dim>, <system>, <qclass>, <zclass>, <sgtype> ) .
#F  SpaceGroupBBNWZ( <dim>, <IT number> )  . . . . . . . . . . . . . .
#F  SpaceGroupBBNWZ( <Hermann-Mauguin symbol> )  . . . . . . . . . . .
##
##  Calls either `SpaceGroupOnRightBBNWZ' or `SpaceGroupOnLeftBBNWZ'
##  depending on the value of `CrystGroupDefaultAction'
##
DeclareGlobalFunction( "SpaceGroupBBNWZ" );


#############################################################################
##
#F  ZClassRepsDadeGroup( <dim>, <system>, <qclass>, <zclass>, <n> )
#F  ZClassRepsDadeGroup( <dim>, <IT number>, <n> )
#F  ZClassRepsDadeGroup( <Hermann-Mauguin symbol>, <n> )
##          
##  'ZClassRepsDadeGroup'  returns  a   list  of  representatives   of  those
##  conjugacy classes  of subgroups of the given Dade group  which consist of
##  groups belonging to the given Z-class.
##
DeclareGlobalFunction("ZClassRepsDadeGroup");


#############################################################################
##
#F  FpGroupSpaceGroupBBNWZ( <S> ) . . FpGroup isomorphic to BBNWZ space group
##
DeclareGlobalFunction( "FpGroupSpaceGroupBBNWZ" );


#############################################################################
##
#E  cryst.gd . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here


