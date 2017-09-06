#############################################################################
##
#W  cache.gd                     GAP library                 Chris Jefferson
##
##
#Y  Copyright (C) 2017 University of St Andrews, Scotland
##
##  This file defines various types of caching data structures
##

#############################################################################
##
#F  MemoizePosIntFunction(<function> [,<defaults> ] )
##
##  <#GAPDoc Label="MemoizePosIntFunction">
##  <ManSection>
##  <Func Name="MemoizePosIntFunction" Arg='function [,defaults]'/>
##
##  <Description>
##  <Ref Func="MemoizePosIntFunction"/> returns a function which behaves the same
##  as <A>function</A>, except it caches the results; if the new function is
##  called with the same input, then any call after the first will return the
##  cached value, instead of recomputing it. The cache is flushed by calling
##  <Ref Func="FlushCaches"/>.
##  <P/>
##  The returned function will only accept positive integers.
##  <P/>
##  This function does not promise to never call <A>function</A> more than
##  once for any input -- values may be removed if the cache gets too large,
##  or GAP chooses to flush all caches, or if multiple threads try to calculate
##  the same value simultaneously.
##  <P/>
##  <A>defaults</A>, if given, is used to initalise the cache.
##  <P/>
##  <Example><![CDATA[
##  gap> f := MemoizePosIntFunction(
##  >           function(i) Print("Check: ",i,"\n"); return i*i; end
##  >         ,[,,9]);;
##  gap> f(2);
##  Check: 2
##  4
##  gap> f(2);
##  4
##  gap> FlushCaches();
##  gap> f(2);
##  Check: 2
##  4
##  gap> f(3);
##  9
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareGlobalFunction("MemoizePosIntFunction");
