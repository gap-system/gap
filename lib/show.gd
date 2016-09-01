#############################################################################
##
#W  show.gd
##
##  Contains the declarations of operations used for outputting objects
##  to streams
##

############################################################################
##
#O  ViewObjStream(<stream>, <obj>)
##
##  <ManSection>
##  <Oper Name="ViewObjStream" Arg='stream, obj'/>
##
##  <Description>
##  <Ref Oper="ViewObjStream"/> prints information about the object <A>obj</A>
##  to the stream <A>stream</A>.
##  This information should be concise and human readable,
##  in particular <E>not</E> necessarily detailed enough for defining <A>obj</A>,
##  an in general <E>not</E> &GAP; readable.
##  <P/>
##  More detailed information can be obtained by <Ref Func="ShowObj"/>
##  </Description>
##  </ManSection>
##
DeclareOperation("ViewObjStream", [IsOutputStream, IsObject]);

############################################################################
##
#O  DisplayObjStream(<stream>, <obj>)
##
##  <ManSection>
##  <Oper Name="DisplayObjStream" Arg='stream, obj'/>
##
##  <Description>
##  <Ref Oper="DisplayObjStream"/> prints information about the object
##  <A>obj</A> to the stream <A>stream</A> in a nicely formatted way.
##  <P/>
##  More detailed information can be obtained by <Ref Func="ShowObj"/>
##  </Description>
##  </ManSection>
##  Nicely formatted output
##
DeclareOperation("DisplayObjStream", [IsOutputStream, IsObject]);

############################################################################
##
#O  CodeObjStream(<stream>, <obj>)
##
##  <ManSection>
##  <Oper Name="CodeObjStream" Arg='stream, obj'/>
##
##  <Description>
##  <Ref Oper="CodeObjStream"/> prints GAP code to recreate the object
##  <A>obj</A> to the stream <A>stream</A>.
##  <P/>
##  More detailed information can be obtained by <Ref Func="ShowObj"/>
##  </Description>
##  </ManSection>
##
DeclareOperation("CodeObjStream", [IsOutputStream, IsObject]);

############################################################################
##
#E

