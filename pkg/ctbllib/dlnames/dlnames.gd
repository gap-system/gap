#############################################################################
##
#W  dlnames.gd            GAP 4 package `ctbllib'      Michael Cla\3en-Houben
##
#H  @(#)$Id: dlnames.gd,v 1.3 2008/11/14 17:22:25 gap Exp $
##
#Y  Copyright (C)  2005,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains declarations concerning Deligne-Lusztig names of
##  unipotent characters of finite groups of Lie type.
##
Revision.( "ctbllib/dlnames/dlnames_gd" ) :=
    "@(#)$Id: dlnames.gd,v 1.3 2008/11/14 17:22:25 gap Exp $";


#############################################################################
##
##  <#GAPDoc Label="sec:unipot">
##  Unipotent characters are defined for finite groups of Lie type.
##  For most of these groups whose character table is in the &GAP; Character
##  Table Library, the unipotent characters are known and parametrised by
##  labels.
##  This labeling is due to the work of P. Deligne and G. Lusztig,
##  thus the label of a unipotent character is called its Deligne-Lusztig
##  name (see&nbsp;<Cite Key="Cla05"/>).
##  <#/GAPDoc>
##


#############################################################################
##
#A  DeligneLusztigNames( <tbl> )
#A  DeligneLusztigNames( <string> )
#A  DeligneLusztigNames( <record> )
##
##  <#GAPDoc Label="DeligneLusztigNames">
##  <ManSection>
##  <Attr Name="DeligneLusztigNames" Arg="obj"/>
##  
##  <Description> 
##  For a character table <A>obj</A>, <Ref Attr="DeligneLusztigNames"/>
##  returns a list of Deligne-Lusztig names of the the unipotent characters
##  of <A>obj</A>.
##  If the <M>i</M>-th entry is bound then it is the name of the <M>i</M>-th
##  irreducible character of <A>obj</A>, and this character is irreducible.
##  If an irreducible character is not unipotent the accordant position is
##  unbound.
##  <P/>
##  <Ref Attr="DeligneLusztigNames"/> called with a string <A>obj</A>,
##  calls itself with the argument <C>CharacterTable( <A>obj</A> )</C>.
##  <P/>
##  When <Ref Attr="DeligneLusztigNames"/> is called with a record <A>obj</A>
##  then this should have the components <C>isoc</C>, <C>isot</C>, <C>l</C>,
##  and <C>q</C>,
##  where <C>isoc</C> and <C>isot</C> are strings defining the isogeny class
##  and isogeny type, and <C>l</C> and <C>q</C> are integers.
##  <!-- which strings are supported? -->
##  These components define a finite group of Lie type uniquely.
##  Moreover this way one can choose Deligne-Lusztig names for a prescribed
##  type in those cases where a group has more than one interpretation
##  as a finite group of Lie type, see the example below.
##  (The first call of <Ref Attr="DeligneLusztigNames"/> sets the attribute
##  value in the character table.)
##  <!-- be more precise here! -->
##  <P/>
##  <Example>
##  gap> DeligneLusztigNames( "L2(7)" );
##  [ [ 2 ],,,, [ 1, 1 ] ]
##  gap> tbl:= CharacterTable( "L2(7)" );
##  CharacterTable( "L3(2)" )
##  gap> HasDeligneLusztigNames( tbl );
##  true
##  gap> DeligneLusztigNames( rec( isoc:= "A", isot:= "simple",
##  >                              l:= 2, q:= 2 ) );
##  [ [ 3 ],,, [ 2, 1 ],, [ 1, 1, 1 ] ]
##  </Example>
##  </Description>
##  </ManSection> 
##  <#/GAPDoc>
##
DeclareAttribute( "DeligneLusztigNames", IsCharacterTable );
DeclareAttribute( "DeligneLusztigNames", IsString );
DeclareAttribute( "DeligneLusztigNames", IsRecord );


#############################################################################
##
#A  DeligneLusztigName( <chi> )
##
##  <#GAPDoc Label="DeligneLusztigName">
##  <ManSection>
##  <Func Name="DeligneLusztigName" Arg="chi"/>
##  
##  <Description> 
##  For a unipotent character <A>chi</A>, <Ref Attr="DeligneLusztigName"/>
##  returns the Deligne-Lusztig name of <A>chi</A>.
##  For that, <Ref Func="DeligneLusztigNames"/> is called with the argument
##  <C>UnderlyingCharacterTable( <A>chi</A> )</C>.
##  <P/>
##  <Example>
##  gap> tbl:= CharacterTable( "F4(2)" );;
##  gap> DeligneLusztigName( Irr( tbl )[9] );
##  fail
##  gap> HasDeligneLusztigNames( tbl );
##  true
##  gap> List( [ 1 .. 8 ], i -> DeligneLusztigName( Irr( tbl )[i] ) );
##  [ "phi{1,0}", "[ [ 2 ], [  ] ]", "phi{2,4}''", "phi{2,4}'", "F4^II[1]",
##    "phi{4,1}", "F4^I[1]", "phi{9,2}" ]
##  </Example>
##  </Description>
##  </ManSection> 
##  <#/GAPDoc>
##
DeclareAttribute( "DeligneLusztigName", IsCharacter );


#############################################################################
##
#O  UnipotentCharacter( <tbl>, <label> )
##
##  <#GAPDoc Label="UnipotentCharacter">
##  <ManSection>
##  <Func Name="UnipotentCharacter" Arg="tbl, label"/>
##  
##  <Description> 
##  Let <A>tbl</A> be the ordinary character table of a finite group
##  of Lie type in the &GAP; Character Table Library.
##  <Ref Oper="UnipotentCharacter"/> returns the unipotent character with
##  Deligne-Lusztig name <A>label</A>.
##  <P/>
##  The object <A>label</A> must be either
##  a list of integers which describes a partition
##  (if the finite group of Lie type is of the type <M>A_l</M> or
##  <M>{}^2\!A_l</M>),
##  a list of two lists of integers which describes a symbol
##  (if the group is of classical type other than <M>A_l</M> and
##  <M>{}^2\!A_l</M>) or a string (if the group is of exceptional type).
##  <P/>
##  A call of <Ref Oper="UnipotentCharacter"/> sets the attribute
##  <Ref Func="DeligneLusztigNames"/> for <A>tbl</A>.
##  <P/>
##  <Example>
##  gap> tbl:= CharacterTable( "U4(2).2" );;
##  gap> UnipotentCharacter( tbl, [ [ 0, 1 ], [ 2 ] ] );
##  Character( CharacterTable( "U4(2).2" ), [ 15, 7, 3, -3, 0, 3, -1, 1, 0, 1,
##    -2, 1, 0, 0, -1, 5, 1, 3, -1, 2, -1, 1, -1, 0, 0 ] )
##  </Example>
##  </Description>
##  </ManSection> 
##  <#/GAPDoc>
##
DeclareOperation( "UnipotentCharacter", [ IsCharacterTable, IsObject ] );


#############################################################################
##
#E

