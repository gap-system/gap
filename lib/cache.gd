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
#O  FlushCaches( ) . . . . . . . . . . . . . . . . . . . . . Clear all caches
##
##  <#GAPDoc Label="FlushCaches">
##  <ManSection>
##  <Oper Name="FlushCaches" Arg=""/>
##
##  <Description>
##  <Ref Oper="FlushCaches"/> resets the value of each global variable that
##  has been declared with <Ref Func="DeclareGlobalVariable"/> and for which
##  the initial value has been set with <Ref Func="InstallFlushableValue"/>
##  or <Ref Func="InstallFlushableValueFromFunction"/>
##  to this initial value.
##  <P/>
##  <Ref Oper="FlushCaches"/> should be used only for debugging purposes,
##  since the involved global variables include for example lists that store
##  finite fields and cyclotomic fields used in the current &GAP; session,
##  in order to avoid that these fields are constructed anew in each call
##  to <Ref Func="GF" Label="for field size"/> and
##  <Ref Func="CF" Label="for (subfield and) conductor"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "FlushCaches", [] );
# This method is just that one method is callable. It is installed first, so
# it will be last in line.
InstallMethod( FlushCaches, "return method", [], function() end );


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
##    Used to initialise the cache, both initially and after each flush.
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
#F  NEW_SORTED_CACHE(<flushable>)
##
##  Set up a cache object suitable for use with `GET_FROM_SORTED_CACHE`.
##  If `flushable` is `true` (which is also the default), then the cache will
##  be flushed whenever `FlushCaches` is called.
##
BIND_GLOBAL("NEW_SORTED_CACHE",
function(flushable)
    local cache;
    cache := [ [], [] ];
    if IsHPCGAP then
        ShareSpecialObj(cache);
    fi;
    if flushable then
        InstallMethod( FlushCaches, [],
          function()
              atomic readwrite cache do
                cache[1] := MigrateObj([], cache);
                cache[2] := MigrateObj([], cache);
              od;
              TryNextMethod();
          end );
    fi;
    return cache;
end);


#############################################################################
##
#F  GET_FROM_SORTED_CACHE(<cache>, <key>, <maker>)
##
##  Lookup the the given `key` inside `cache`, and return it. If the key is
##  not yet in the cache, call the 0-argument function `maker`, store its
##  return value under `key`, and return that value.
##
##  Internally, the cache is represented by a list of two lists. The first
##  of the two lists contains the sorted keys; the second list contains the
##  corresponding values. So if `cache[1][i]` equals `key`, then the
##  associated value is stored in `cache[2][i]`.
##
##  The advantage of using this helper function is reduced code duplication,
##  and thread safety when using HPC-GAP.
##
DeclareGlobalFunction("GET_FROM_SORTED_CACHE");
