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
#F  MemoizePosIntFunction(<function> [,<options> ] )
##
##  <#GAPDoc Label="MemoizePosIntFunction">
##  <ManSection>
##  <Func Name="MemoizePosIntFunction" Arg='function [,options]'/>
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
##  The optional second argument is a record which provides a number
##  of configuration options. The following options are supported.
##  <List>
##  <Mark><C>defaults</C> (default an empty list)</Mark>
##  <Item>
##    Used to initalise the cache, both initially and after each flush.
##  </Item>
##  <Mark><C>flush</C> (default <K>true</K>)</Mark>
##  <Item>
##    If this is <K>true</K>, the cache is emptied whenever
##    <Ref Func="FlushCaches"/> is called.
##  </Item>
##  <Mark><C>errorHandler</C> (defaults to <Ref Func="Error"/>)</Mark>
##  <Item>
##    A function to be called when an input which is not a positive integer
##    is passed to the cache. If this function returns a value, that
##    value is returned by the cache.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> f := MemoizePosIntFunction(
##  >           function(i) Print("Check: ",i,"\n"); return i*i; end,
##  >           rec(defaults := [,,50], errorHandler := x -> "Bad") );;
##  gap> f(2);
##  Check: 2
##  4
##  gap> f(2);
##  4
##  gap> f(3);
##  50
##  gap> f(-3);
##  "Bad"
##  gap> FlushCaches();
##  gap> f(2);
##  Check: 2
##  4
##  gap> f(3);
##  50
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareGlobalFunction("MemoizePosIntFunction");
