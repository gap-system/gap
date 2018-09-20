#############################################################################
##
#W  show.gd
##
##  Contains the declarations of operations used for outputting objects
##  to streams
##

############################################################################
##
#O  ViewObj(<stream>, <obj>)
##
##  <ManSection>
##  <Oper Name="ViewObj" Arg='stream, obj'/>
##
##  <Description>
##  <Ref Oper="ViewObj"/> prints information about the object <A>obj</A>
##  to the stream <A>stream</A>.
##  This information should be concise and human readable,
##  in particular <E>not</E> necessarily detailed enough for defining <A>obj</A>,
##  an in general <E>not</E> &GAP; readable.
##  <P/>
##  More detailed information can be obtained by <Ref Func="ShowObj"/>
##  </Description>
##  </ManSection>
##
DeclareOperation("ViewObj", [IsOutputStream, IsObject]);

############################################################################
##
#O  DisplayObj(<stream>, <obj>)
##
##  <ManSection>
##  <Oper Name="DisplayObj" Arg='stream, obj'/>
##
##  <Description>
##  <Ref Oper="DisplayObj"/> prints information about the object
##  <A>obj</A> to the stream <A>stream</A> in a nicely formatted way.
##  <P/>
##  More detailed information can be obtained by <Ref Func="ShowObj"/>
##  </Description>
##  </ManSection>
##
DeclareOperation("DisplayObj", [IsOutputStream, IsObject]);

############################################################################
##
#O  CodeObj(<stream>, <obj>)
##
##  <ManSection>
##  <Oper Name="CodeObj" Arg='stream, obj'/>
##
##  <Description>
##  <Ref Oper="CodeObj"/> prints GAP code to recreate the object
##  <A>obj</A> to the stream <A>stream</A>.
##  <P/>
##  More detailed information can be obtained by <Ref Func="ShowObj"/>
##  </Description>
##  </ManSection>
##
DeclareOperation("CodeObj", [IsOutputStream, IsObject]);

############################################################################
##
#E

