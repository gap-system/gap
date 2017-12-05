#############################################################################
##
#W  memusage.gd                   GAP library
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##


#############################################################################
##
#O  MemoryUsage( <obj> )
##
##  <#GAPDoc Label="MemoryUsage">
##  <ManSection>
##  <Func Name="MemoryUsage" Arg='obj'/>
##
##  <Description>
##  Returns the amount of memory in bytes used by the object <A>obj</A>
##  and its subobjects. Note that in general, objects can reference
##  each other in very difficult ways such that determining the memory
##  usage is a recursive procedure. In particular, computing the memory
##  usage of a complicated structure itself uses some additional memory,
##  which is however no longer used after completion of this operation.
##  This procedure descends into lists and records, positional and
##  component objects; however it deliberately does not take into account
##  the type and family objects. For functions, it only takes the memory usage of
##  the function body, not of the local context the function was created
##  in, although the function keeps a reference to that as well.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MemoryUsage" );

DeclareOperation( "MemoryUsageOp", [IsObject, IsFunction] );


BIND_GLOBAL( "MU_MemPointer", GAPInfo.BytesPerVariable );
if GAPInfo.BytesPerVariable = 4 then
  BIND_GLOBAL( "MU_MemBagHeader", 12 );
else
  BIND_GLOBAL( "MU_MemBagHeader", 16 );
fi;
