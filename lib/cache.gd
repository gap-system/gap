#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Chris Jefferson.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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
##  <Ref Func="MemoizePosIntFunction"/> returns a function which behaves the
##  same as <A>function</A>, except it caches the results for any inputs that
##  are positive integers. Thus if the new function is called multiple times
##  with the same input, then any call after the first will return the cached
##  value, instead of recomputing it. By default, the cache can be flushed by
##  calling <Ref Oper="FlushCaches"/>.
##  <P/>
##  The returned function will by default only accept positive integers.
##  <P/>
##  This function does not promise to never call <A>function</A> more than
##  once for any input -- values may be removed if the cache gets too large,
##  or if <Ref Oper="FlushCaches"/> is called, or if multiple threads try to
##  calculate the same value simultaneously.
##  <P/>
##  The optional second argument is a record which provides a number
##  of configuration options. The following options are supported.
##  <List>
##  <Mark><C>defaults</C> (default an empty list)</Mark>
##  <Item>
##    Used to initalise the cache, both initially and after each flush.
##    If <C>defaults[i]</C> is bound, then this is used as default vale
##    for the input <C>i</C>.
##  </Item>
##  <Mark><C>flush</C> (default <K>true</K>)</Mark>
##  <Item>
##    If this is <K>true</K>, the cache is emptied whenever
##    <Ref Oper="FlushCaches"/> is called; if false, then the cache
##    cannot be flushed.
##  </Item>
##  <Mark><C>errorHandler</C> (defaults to <Ref Func="Error"/>)</Mark>
##  <Item>
##    A function to be called when an input which is not a positive integer
##    is passed to the cache. The function can either raise an error, or else
##    return a value which is then returned by the cache. Note that such a
##    value does not get cached itself.
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

#############################################################################
##
#F  GET_FROM_SORTED_CACHE(<cache>, <key>, <maker>)
##
DeclareGlobalFunction("GET_FROM_SORTED_CACHE");
