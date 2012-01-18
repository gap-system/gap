#############################################################################
##
#W  scanmtx.gd     GAP 4 packages AtlasRep and MeatAxe          Thomas Breuer
#W                                                              Frank L"ubeck
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  Whenever this file is changed in one of the packages
##  <Package>AtlasRep</Package> or `meataxe',
##  do not forget to update the corresponding file in the other package!
##
##  This file contains the implementation part of the interface routines for
##  reading and writing <C>C</C>-&MeatAxe; text and binary format,
##  and straight line programs used in the &ATLAS; of Group Representations.
##
##  The functions <Ref Func="CMtxBinaryFFMatOrPerm"/> and
##  <Ref Func="FFMatOrPermCMtxBinary"/> were contributed by Frank L"ubeck.
##


############################################################################
##
#V  CMeatAxe
##
##  <ManSection>
##  <Var Name="CMeatAxe"/>
##
##  <Description>
##  is a record containing relevant information about the usage of MeatAxe
##  under &GAP;.
##  Currently there are the following components.
##
##  <List>
##  <Mark><C>gennames</C></Mark>
##  <Item>
##      the list of strings that are used as generator names in
##      <C>abstract</C> components of <C>C</C>-&MeatAxe; matrices,
##  </Item>
##  <Mark><C>alpha</C></Mark>
##  <Item>
##      alphabet ober which <C>gennames</C> entries are formed.
##  </Item>
##  </List>
##  <P/>
##  Besides these, some components will be intermediately bound
##  when <C>C</C>-&MeatAxe; output files are read.
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable( "CMeatAxe" );


#############################################################################
##
#V  InfoCMeatAxe
##
##  <#GAPDoc Label="InfoCMeatAxe">
##  <ManSection>
##  <InfoClass Name="InfoCMeatAxe"/>
##
##  <Description>
##  If the info level of <Ref InfoClass="InfoCMeatAxe"/> is at least <M>1</M>
##  then information about <K>fail</K> results of <C>C</C>-&MeatAxe;
##  functions is printed.
##  The default level is zero, no information is printed on this level.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoCMeatAxe" );


#############################################################################
##
#F  FFList( <F> )
#V  FFLists
##
##  <#GAPDoc Label="FFList">
##  <ManSection>
##  <Func Name="FFList" Arg='F'/>
##  <Returns>
##  a list of elements in the given finite field.
##  </Returns>
##  <Var Name="FFLists"/>
##
##  <Description>
##  <Ref Func="FFList"/> is a utility program for the conversion of vectors
##  and matrices from &MeatAxe; format to &GAP; format and vice versa.
##  It is used by <Ref Func="ScanMeatAxeFile"/>
##  and <Ref Func="MeatAxeString"/>.
##  <P/>
##  For a finite field <A>F</A>, <Ref Func="FFList"/> returns a list <A>l</A>
##  giving the correspondence between the &MeatAxe; numbering and the &GAP;
##  numbering of the elements in <A>F</A>.
##  <P/>
##  The element of <A>F</A> corresponding to &MeatAxe; number <A>n</A> is
##  <M><A>l</A>[ <A>n</A>+1 ]</M>,
##  and the &MeatAxe; number of the field element <A>z</A> is
##  <C>Position( </C><A>l</A><C>, </C><A>z</A><C> ) - 1</C>.
##  <P/>
##  The global variable <Ref Var="FFLists"/> is used to store the information
##  about <A>F</A> once it has been computed.
##  <P/>
##  <Example><![CDATA[
##  gap> FFList( GF(4) );
##  [ 0*Z(2), Z(2)^0, Z(2^2), Z(2^2)^2 ]
##  gap> IsBound( FFLists[4] );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FFList" );
DeclareGlobalVariable( "FFLists",
    "list of info to translate FFE orderings between GAP and MeatAxe" );


#############################################################################
##
#F  FFLogList( <F> )
#V  FFLogLists
##
##  <ManSection>
##  <Func Name="FFLogList" Arg='F'/>
##  <Var Name="FFLogLists"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "FFLogList" );
DeclareGlobalVariable( "FFLogLists",
    "list of info to translate FFE orderings between GAP and MeatAxe" );


#############################################################################
##
#V  NONNEG_INTEGERS_STRINGS
##
##  <ManSection>
##  <Var Name="NONNEG_INTEGERS_STRINGS"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable( "NONNEG_INTEGERS_STRINGS",
    "list of strings for nonnegative integers" );


#############################################################################
##
#F  IntegerStrings( <q> )
##
##  <ManSection>
##  <Func Name="IntegerStrings" Arg='q'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "IntegerStrings" );


#############################################################################
##
#F  CMeatAxeFileHeaderInfo( <string> )
##
##  <ManSection>
##  <Func Name="CMeatAxeFileHeaderInfo" Arg='string'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CMeatAxeFileHeaderInfo" );


#############################################################################
##
#V  SMFSTRING
##
##  <ManSection>
##  <Var Name="SMFSTRING"/>
##
##  <Description>
##  This global variable is needed because <Ref Func="Read" BookName="ref"/>
##  (for a string) is executed in the main environment
##  not inside the function.
##  </Description>
##  </ManSection>
##
SMFSTRING := "";


#############################################################################
##
#F  ScanMeatAxeFile( <filename>[, <q>] )
#F  ScanMeatAxeFile( <string>[, <q>], "string" )
##
##  <#GAPDoc Label="ScanMeatAxeFile">
##  <ManSection>
##  <Func Name="ScanMeatAxeFile" Arg='filename[, q][, "string"]'/>
##
##  <Returns>
##  the matrix or list of permutations stored in the file or encoded by the
##  string.
##  </Returns>
##  <Description>
##  Let <A>filename</A> be the name of a &GAP; readable file
##  (see&nbsp;<Ref Sect="Filename" BookName="ref"/>)
##  that contains a matrix or a permutation or a list of permutations in
##  &MeatAxe; text format (see the section about the program
##  <F>zcv</F> <Index Key="zcv"><F>zcv</F></Index>
##  in the &MeatAxe; manual&nbsp;<Cite Key="Rin98"/>),
##  and let <A>q</A> be a prime power.
##  <Ref Func="ScanMeatAxeFile"/> returns the corresponding &GAP; matrix
##  or list of permutations, respectively.
##  <P/>
##  If the file contains a matrix then the way how it is read by
##  <Ref Func="ScanMeatAxeFile"/> depends on the
##  value of the global variable <Ref Var="CMeatAxe.FastRead"/>.
##  If the parameter <A>q</A> is given then the result matrix is represented
##  over the field with <A>q</A> elements,
##  the default for <A>q</A> is the field size stored in the file.
##  <P/>
##  If the file contains a list of permutations then it is read with
##  <Ref Func="StringFile" BookName="gapdoc"/>;
##  the parameter <A>q</A>, if given, is ignored in this case.
##  <P/>
##  If the string <C>"string"</C> is entered as the third argument then
##  the first argument must be a string as obtained by reading
##  a file in &MeatAxe; text format as a text stream
##  (see&nbsp;<Ref Func="InputTextFile" BookName="ref"/>).
##  Also in this case, <Ref Func="ScanMeatAxeFile"/> returns
##  the corresponding &GAP; matrix or list of permutations, respectively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ScanMeatAxeFile" );


#############################################################################
##
#O  MeatAxeString( <mat>, <q> )
#O  MeatAxeString( <perms>, <degree> )
#O  MeatAxeString( <perm>, <q>, <dims> )
##
##  <#GAPDoc Label="MeatAxeString">
##  <ManSection>
##  <Oper Name="MeatAxeString" Arg='mat, q'/>
##  <Oper Name="MeatAxeString" Arg='perms, degree'
##  Label="for permutations and a degree"/>
##  <Oper Name="MeatAxeString" Arg='perm, q, dims'
##  Label="for a permutation, q, and dims"/>
##
##  <Returns>
##  a string encoding the &GAP; objects given as input in &MeatAxe; format.
##  </Returns>
##  <Description>
##  In the first form, for a matrix <A>mat</A> whose entries lie in the
##  finite field with <A>q</A> elements,
##  <Ref Oper="MeatAxeString"/> returns a string that encodes <A>mat</A>
##  as a matrix over <C>GF(<A>q</A>)</C>, in &MeatAxe; text format.
##  <P/>
##  In the second form, for a nonempty list <A>perms</A> of permutations that
##  move only points up to the positive integer <A>degree</A>,
##  <Ref Oper="MeatAxeString"/> returns a string that encodes <A>perms</A> as
##  permutations of degree <A>degree</A>,
##  in &MeatAxe; text format (see&nbsp;<Cite Key="Rin98"/>).
##  <P/>
##  In the third form, for a permutation <A>perm</A> with largest moved point
##  <M>n</M>, say, a prime power <A>q</A>, and a list <A>dims</A> of length
##  two containing two positive integers larger than or equal to
##  <M>n</M>,
##  <Ref Oper="MeatAxeString"/> returns a string that encodes <A>perm</A>
##  as a matrix over <C>GF(<A>q</A>)</C>, of dimensions <A>dims</A>,
##  whose first <M>n</M> rows and columns describe the permutation matrix
##  corresponding to <A>perm</A>,
##  and the remaining rows and columns are zero.
##  <P/>
##  When strings are printed to files
##  using <Ref Func="PrintTo" BookName="ref"/>
##  or <Ref Func="AppendTo" BookName="ref"/>
##  then line breaks are inserted whenever lines exceed the number of
##  characters given by the second entry of the list returned by
##  <Ref Func="SizeScreen" BookName="ref"/>,
##  see&nbsp;<Ref Sect="Operations for Output Streams" BookName="ref"/>.
##  This behaviour is not desirable for creating data files.
##  So the recommended functions for printing the result of
##  <Ref Func="MeatAxeString"/> to a file
##  are <Ref Func="FileString" BookName="gapdoc"/>
##  and <Ref Func="WriteAll" BookName="ref"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> mat:= [ [ 1, -1 ], [ 0, 1 ] ] * Z(3)^0;;
##  gap> str:= MeatAxeString( mat, 3 );
##  "1 3 2 2\n12\n01\n"
##  gap> mat = ScanMeatAxeFile( str, "string" );
##  true
##  gap> str:= MeatAxeString( mat, 9 );
##  "1 9 2 2\n12\n01\n"
##  gap> mat = ScanMeatAxeFile( str, "string" );
##  true
##  gap> perms:= [ (1,2,3)(5,6) ];;
##  gap> str:= MeatAxeString( perms, 6 );
##  "12 1 6 1\n2\n3\n1\n4\n6\n5\n"
##  gap> perms = ScanMeatAxeFile( str, "string" );
##  true
##  gap> str:= MeatAxeString( perms, 8 );
##  "12 1 8 1\n2\n3\n1\n4\n6\n5\n7\n8\n"
##  gap> perms = ScanMeatAxeFile( str, "string" );
##  true
##  gap> perm:= (1,2,4);;
##  gap> str:= MeatAxeString( perm, 3, [ 5, 6 ] );
##  "2 3 5 6\n2\n4\n3\n1\n5\n"
##  gap> mat:= ScanMeatAxeFile( str, "string" );;  Print( mat, "\n" );
##  [ [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3) ], 
##    [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
##    [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
##    [ Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3) ], 
##    [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ] ]
##  gap> MeatAxeString( mat, 3 ) = str;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MeatAxeString", [ IsTable, IsPosInt ] );
DeclareOperation( "MeatAxeString",
    [ IsPermCollection and IsList, IsPosInt ] );
DeclareOperation( "MeatAxeString", [ IsPerm, IsPosInt, IsList ] );


#############################################################################
##
#F  CMtxBinaryFFMatOrPerm( <mat>, <q>, <outfile> )
#F  CMtxBinaryFFMatOrPerm( <perm>, <deg>, <outfile> )
##
##  <#GAPDoc Label="CMtxBinaryFFMatOrPerm">
##  <ManSection>
##  <Func Name="CMtxBinaryFFMatOrPerm" Arg='elm, def, outfile'/>
##
##  <Description>
##  Let the pair <M>(<A>elm</A>, <A>def</A>)</M> be either of the form
##  <M>(M, q)</M> where <M>M</M> is a matrix over a finite field <M>F</M>,
##  say, with <M>q \leq 256</M> elements,
##  or of the form <M>(\pi, n)</M> where <M>\pi</M> is a permutation with
##  largest moved point at most <M>n</M>.
##  Let <A>outfile</A> be a string.
##  <Ref Func="CMtxBinaryFFMatOrPerm"/> writes
##  the <C>C</C>-&MeatAxe; binary format of <M>M</M>, viewed as a matrix
##  over <M>F</M>,
##  or of <M>\pi</M>, viewed as a permutation on the points up to <M>n</M>,
##  to the file with name <A>outfile</A>.
##  <P/>
##  (The binary format is described
##  in the <C>C</C>-&MeatAxe; manual&nbsp;<Cite Key="Rin98"/>.)
##  <P/>
##  <Example><![CDATA[
##  gap> tmpdir:= DirectoryTemporary();;
##  gap> mat:= Filename( tmpdir, "mat" );;
##  gap> q:= 4;;
##  gap> mats:= GeneratorsOfGroup( GL(10,q) );;
##  gap> CMtxBinaryFFMatOrPerm( mats[1], q, Concatenation( mat, "1" ) );
##  gap> CMtxBinaryFFMatOrPerm( mats[2], q, Concatenation( mat, "2" ) );
##  gap> prm:= Filename( tmpdir, "prm" );;
##  gap> n:= 200;;
##  gap> perms:= GeneratorsOfGroup( SymmetricGroup( n ) );;
##  gap> CMtxBinaryFFMatOrPerm( perms[1], n, Concatenation( prm, "1" ) );
##  gap> CMtxBinaryFFMatOrPerm( perms[2], n, Concatenation( prm, "2" ) );
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CMtxBinaryFFMatOrPerm" );


#############################################################################
##
#F  FFMatOrPermCMtxBinary( <fname> )
##
##  <#GAPDoc Label="FFMatOrPermCMtxBinary">
##  <ManSection>
##  <Func Name="FFMatOrPermCMtxBinary" Arg='fname'/>
##
##  <Returns>
##  the matrix or permutation stored in the file.
##  </Returns>
##  <Description>
##  Let <A>fname</A> be the name of a file that contains the
##  <C>C</C>-&MeatAxe; binary format of a matrix over a finite field
##  or of a permutation,
##  as is described in&nbsp;<Cite Key="Rin98"/>.
##  <Ref Func="FFMatOrPermCMtxBinary"/> returns the corresponding
##  &GAP; matrix or permutation.
##  <P/>
##  <Example><![CDATA[
##  gap> FFMatOrPermCMtxBinary( Concatenation( mat, "1" ) ) = mats[1];
##  true
##  gap> FFMatOrPermCMtxBinary( Concatenation( mat, "2" ) ) = mats[2];
##  true
##  gap> FFMatOrPermCMtxBinary( Concatenation( prm, "1" ) ) = perms[1];
##  true
##  gap> FFMatOrPermCMtxBinary( Concatenation( prm, "2" ) ) = perms[2];
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FFMatOrPermCMtxBinary" );


#############################################################################
##
#F  ScanStraightLineProgram( <filename> )
#F  ScanStraightLineProgram( <string>, "string" )
##
##  <#GAPDoc Label="ScanStraightLineProgram">
##  <ManSection>
##  <Func Name="ScanStraightLineProgram" Arg='filename[, "string"]'/>
##
##  <Returns>
##  a record containing the straight line program.
##  </Returns>
##  <Description>
##  Let <A>filename</A> be the name of a file that contains a straight line
##  program in the sense that it consists only of lines in the following
##  form.
##  <List>
##  <Mark><C>#<A>anything</A></C></Mark>
##  <Item>
##      lines starting with a hash sign <C>#</C> are ignored,
##  </Item>
##  <Mark><C>echo <A>anything</A></C></Mark>
##  <Item>
##      lines starting with <C>echo</C> are ignored for the <C>program</C>
##      component of the result record (see below),
##      they are used to set up the bijection between the labels used in
##      the program and conjugacy class names in the case that the program
##      computes dedicated class representatives,
##  </Item>
##  <Mark><C>inp <A>n</A></C></Mark>
##  <Item>
##      means that there are <A>n</A> inputs, referred to via the labels
##      <C>1</C>, <C>2</C>, <M>\ldots</M>, <A>n</A>,
##  </Item>
##  <Mark><C>inp <A>k</A> <A>a1</A> <A>a2</A> ... <A>ak</A></C></Mark>
##  <Item>
##      means that the next <A>k</A> inputs are referred to via the labels
##      <A>a1</A>, <A>a2</A>, ..., <A>ak</A>,
##  </Item>
##  <Mark><C>cjr <A>a</A> <A>b</A></C></Mark>
##  <Item>
##      means that <A>a</A> is replaced by
##      <C><A>b</A>^(-1) * <A>a</A> * <A>b</A></C>,
##  </Item>
##  <Mark><C>cj <A>a</A> <A>b</A> <A>c</A></C></Mark>
##  <Item>
##      means that <A>c</A> is defined as
##      <C><A>b</A>^(-1) * <A>a</A> * <A>b</A></C>,
##  </Item>
##  <Mark><C>com <A>a</A> <A>b</A> <A>c</A></C></Mark>
##  <Item>
##      means that <A>c</A> is defined as
##      <C><A>a</A>^(-1) * <A>b</A>^(-1) * <A>a</A> * <A>b</A></C>,
##  </Item>
##  <Mark><C>iv <A>a</A> <A>b</A></C></Mark>
##  <Item>
##      means that <A>b</A> is defined as <C><A>a</A>^(-1)</C>,
##  </Item>
##  <Mark><C>mu <A>a</A> <A>b</A> <A>c</A></C></Mark>
##  <Item>
##      means that <A>c</A> is defined as <C><A>a</A> * <A>b</A></C>,
##  </Item>
##  <Mark><C>pwr <A>a</A> <A>b</A> <A>c</A></C></Mark>
##  <Item>
##      means that <A>c</A> is defined as
##      <C><A>b</A>^<A>a</A></C>,
##  </Item>
##  <Mark><C>cp <A>a</A> <A>b</A></C></Mark>
##  <Item>
##      means that <A>b</A> is defined as a copy of <A>a</A>,
##  </Item>
##  <Mark><C>oup <A>l</A></C></Mark>
##  <Item>
##      means that there are <A>l</A> outputs, stored in the labels
##      <C>1</C>, <C>2</C>, <M>\ldots</M>, <A>l</A>, and
##  </Item>
##  <Mark><C>oup <A>l</A> <A>b1</A> <A>b2</A> ... <A>bl</A></C></Mark>
##  <Item>
##      means that the next <A>l</A> outputs are stored in the labels
##      <A>b1</A>, <A>b2</A>, ... <A>bl</A>.
##  </Item>
##  </List>
##  <P/>
##  Each of the labels <A>a</A>, <A>b</A>, <A>c</A> can be any nonempty
##  sequence of digits and alphabet characters,
##  except that the first argument of <C>pwr</C> must denote an integer.
##  <P/>
##  If the <C>inp</C> or <C>oup</C> statements are missing then the input or
##  output, respectively, is assumed to be given by the labels <C>1</C> and
##  <C>2</C>.
##  There can be multiple <C>inp</C> lines at the beginning of the program
##  and multiple <C>oup</C> lines at the end of the program.
##  Only the first <C>inp</C> or <C>oup</C> line may omit the names of the
##  elements.
##  For example, an empty file <A>filename</A> or an empty string
##  <A>string</A>
##  represent a straight line program with two inputs that are returned as
##  outputs.
##  <P/>
##  No command except <C>cjr</C> may overwrite its own input.
##  For example, the line <C>mu a b a</C> is not legal.
##  (This is not checked.)
##  <P/>
##  <Ref Func="ScanStraightLineProgram"/> returns a record containing as the
##  value of its component <C>program</C> the corresponding &GAP; straight
##  line program
##  (see&nbsp;<Ref Func="IsStraightLineProgram" BookName="ref"/>)
##  if the input string satisfies the syntax rules stated above,
##  and returns <K>fail</K> otherwise.
##  In the latter case, information about the first corrupted line of the
##  program is printed if the info level of <Ref InfoClass="InfoCMeatAxe"/>
##  is at least <M>1</M>.
##  <P/>
##  If the string <C>"string"</C> is entered as the second argument then
##  the first argument must be a string as obtained by reading
##  a file in &MeatAxe; text format as a text stream
##  (see&nbsp;<Ref Func="InputTextFile" BookName="ref"/>).
##  Also in this case, <Ref Func="ScanStraightLineProgram"/> returns either
##  a record with the corresponding &GAP; straight line program
##  or <K>fail</K>.
##  <P/>
##  If the input describes a straight line program that computes certain
##  class representatives of the group in question then the result record
##  also contains the component <C>outputs</C>.
##  Its value is a list of strings, the entry at position <M>i</M> denoting
##  the name of the class in which the <M>i</M> output of the straight line
##  program lies; see
##  Section&nbsp;<Ref Sect="sect:Class Names Used in the AtlasRep Package"/>
##  for the definition of the class names that occur.
##  <P/>
##  Such straight line programs must end with a sequence of output
##  specifications of the following form.
##  <P/>
##  <Log><![CDATA[
##  echo "Classes 1A 2A 3A 5A 5B"
##  oup 5 3 1 2 4 5
##  ]]></Log>
##  <P/>
##  This example means that the list of outputs of the program contains
##  elements of the classes <C>1A</C>, <C>2A</C>, <C>3A</C>, <C>5A</C>,
##  and <C>5B</C> (in this order),
##  and that inside the program, these elements are referred to by the five
##  names <C>3</C>, <C>1</C>, <C>2</C>, <C>4</C>, and <C>5</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ScanStraightLineProgram" );


#############################################################################
##
#F  ScanStraightLineDecision( <string> )
##
##  <#GAPDoc Label="ScanStraightLineDecision">
##  <ManSection>
##  <Func Name="ScanStraightLineDecision" Arg='string'/>
##
##  <Returns>
##  a record containing the straight line decision, or <K>fail</K>.
##  </Returns>
##  <Description>
##  Let <A>string</A> be a string that encodes a straight line decision in
##  the sense that it consists of the lines listed for
##  <Ref Func="ScanStraightLineProgram"/>, except that <C>oup</C> lines are
##  not allowed, and instead lines of the following form may occur.
##  <P/>
##  <List>
##  <Mark><C>chor <A>a</A> <A>b</A></C></Mark>
##  <Item>
##      means that it is checked whether the order of the element at label
##      <A>a</A> is <A>b</A>.
##  </Item>
##  </List>
##  <P/>
##  <Ref Func="ScanStraightLineDecision"/> returns a record containing as the
##  value of its component <C>program</C> the corresponding &GAP; straight
##  line decision (see&nbsp;<Ref Func="IsStraightLineDecision"/>)
##  if the input string satisfies the syntax rules stated above,
##  and returns <K>fail</K> otherwise.
##  In the latter case, information about the first corrupted line of the
##  program is printed if the info level of <Ref InfoClass="InfoCMeatAxe"/>
##  is at least <M>1</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> str:= "inp 2\nchor 1 2\nchor 2 3\nmu 1 2 3\nchor 3 5";;
##  gap> prg:= ScanStraightLineDecision( str );
##  rec( program := <straight line decision> )
##  gap> prg:= prg.program;;
##  gap> Display( prg );
##  # input:
##  r:= [ g1, g2 ];
##  # program:
##  if Order( r[1] ) <> 2 then  return false;  fi;
##  if Order( r[2] ) <> 3 then  return false;  fi;
##  r[3]:= r[1]*r[2];
##  if Order( r[3] ) <> 5 then  return false;  fi;
##  # return value:
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ScanStraightLineDecision" );


#############################################################################
##
#F  AtlasStringOfProgram( <prog>[, <outputnames>] )
#F  AtlasStringOfProgram( <prog>[, "mtx"] )
##
##  <#GAPDoc Label="AtlasStringOfProgram">
##  <ManSection>
##  <Func Name="AtlasStringOfProgram" Arg='prog[, outputnames]'/>
##  <Func Name="AtlasStringOfProgram" Arg='prog[, "mtx"]'
##  Label="for MeatAxe format output"/>
##
##  <Returns>
##  a string encoding the straight line program/decision in the format used
##  in &ATLAS; files.
##  </Returns>
##  <Description>
##  For a straight line program or straight line decision <A>prog</A>
##  (see&nbsp;<Ref Func="IsStraightLineProgram" BookName="ref"/> and
##  <Ref Func="IsStraightLineDecision"/>),
##  this function returns a string describing the input format of an
##  equivalent straight line program or straight line decision
##  as used in the &ATLAS; of Group Representations, that is,
##  the lines are of the form described
##  in&nbsp;<Ref Func="ScanStraightLineProgram"/>.
##  <P/>
##  A list of strings that is given as the optional second argument
##  <A>outputnames</A> is interpreted as the class names corresponding to the
##  outputs; this argument has the effect that appropriate <C>echo</C>
##  statements appear in the result string.
##  <P/>
##  If the string <C>"mtx"</C> is given as the second argument then the
##  result has the format used in the <C>C</C>-&MeatAxe;
##  (see&nbsp;<Cite Key="Rin98"/>)
##  rather than the format described in
##  Section&nbsp;<Ref Sect="sect:Reading and Writing Atlas Straight Line Programs"/>.
##  (Note that the <C>C</C>-&MeatAxe; format does not make sense if the
##  argument <A>outputnames</A> is given, and that this format does not
##  support <C>inp</C> and <C>oup</C> statements.)
##  <P/>
##  The argument <A>prog</A> must not be a black box program
##  (see <Ref Func="IsBBoxProgram"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> str:= "inp 2\nmu 1 2 3\nmu 3 1 2\niv 2 1\noup 2 1 2";;
##  gap> prg:= ScanStraightLineProgram( str, "string" );
##  rec( program := <straight line program> )
##  gap> prg:= prg.program;;
##  gap> Display( prg );
##  # input:
##  r:= [ g1, g2 ];
##  # program:
##  r[3]:= r[1]*r[2];
##  r[2]:= r[3]*r[1];
##  r[1]:= r[2]^-1;
##  # return values:
##  [ r[1], r[2] ]
##  gap> StringOfResultOfStraightLineProgram( prg, [ "a", "b" ] );
##  "[ (aba)^-1, aba ]"
##  gap> AtlasStringOfProgram( prg );
##  "inp 2\nmu 1 2 3\nmu 3 1 2\niv 2 1\noup 2\n"
##  gap> prg:= StraightLineProgram( "(a^2b^3)^-1", [ "a", "b" ] );
##  <straight line program>
##  gap> Print( AtlasStringOfProgram( prg ) );
##  inp 2
##  pwr 2 1 4
##  pwr 3 2 5
##  mu 4 5 3
##  iv 3 4
##  oup 1 4
##  gap> prg:= StraightLineProgram( [ [2,3], [ [3,1,1,4], [1,2,3,1] ] ], 2 );
##  <straight line program>
##  gap> Print( AtlasStringOfProgram( prg ) );
##  inp 2
##  pwr 3 2 3
##  pwr 4 1 5
##  mu 3 5 4
##  pwr 2 1 6
##  mu 6 3 5
##  oup 2 4 5
##  gap> Print( AtlasStringOfProgram( prg, "mtx" ) );
##  # inputs are expected in 1 2
##  zsm pwr3 2 3
##  zsm pwr4 1 5
##  zmu 3 5 4
##  zsm pwr2 1 6
##  zmu 6 3 5
##  echo "outputs are in 4 5"
##  gap> str:= "inp 2\nchor 1 2\nchor 2 3\nmu 1 2 3\nchor 3 5";;
##  gap> prg:= ScanStraightLineDecision( str );;
##  gap> AtlasStringOfProgram( prg.program );
##  "inp 2\nchor 1 2\nchor 2 3\nmu 1 2 3\nchor 3 5\n"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasStringOfProgram" );


#############################################################################
##
#F  AtlasStringOfStraightLineProgram( ... )
##
##  This was the documented name before version 1.3 of the package,
##  when no straight line decisions and black box programs were available.
##  We keep it for backwards compatibility reasons,
##  but leave it undocumented.
##
DeclareSynonym( "AtlasStringOfStraightLineProgram", AtlasStringOfProgram );


#############################################################################
##
#E

