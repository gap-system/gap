#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declarations of functions that report information from
##  the GASMAN garbage collector.
##


#############################################################################
##
#F  CollectGarbage( <full> )
##
##  <#GAPDoc Label="CollectGarbage">
##  <ManSection>
##  <Func Name="CollectGarbage" Arg='full'/>
##
##  <Returns>
##  nothing.
##  </Returns>
##  <Description>
##  This function forces a garbage collection.
##  If <A>full</A> is <K>true</K> then it triggers a full garbage collection,
##  otherwise a partial one.
##  <P/>
##  &GAP; invokes its garbage collector automatically, thus there is normally
##  no need to call <Ref Func="CollectGarbage"/>.
##  <P/>
##  The function <Ref Func="CollectGarbage"/> was introduced in
##  &GAP;&nbsp;4.12.
##  In older &GAP; versions,
##  one can use <C>GASMAN( "collect" )</C> (if <A>full</A> is <K>true</K>)
##  or <C>GASMAN( "partial" )</C> (if <A>full</A> is not <K>true</K>)
##  instead.
##  <P/>
##  <Example><![CDATA[
##  gap> CollectGarbage( false );
##  gap> CollectGarbage( true );
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("CollectGarbage");


#############################################################################
##
#F  GasmanStatistics( )
##
##  <#GAPDoc Label="GasmanStatistics">
##  <ManSection>
##  <Func Name="GasmanStatistics" Arg=''/>
##
##  <Description>
##  This function is meaningful only if <C>GASMAN</C> is
##  the garbage collector used by &GAP;,
##  see Section <Ref Subsect="Garbage Collection"/>.
##  <P/>
##  <Ref Func="GasmanStatistics"/> returns a record containing some
##  information from the garbage collection mechanism.
##  The record may contain up to four components:
##  <C>full</C>, <C>partial</C>, <C>npartial</C>, and <C>nfull</C>.
##  <P/>
##  The <C>full</C> component will be present if a full garbage collection
##  has taken place since &GAP; started. It contains information about
##  the most recent full garbage collection. It is a record, with eight
##  components: <C>livebags</C> contains the number of bags which survived
##  the garbage collection; <C>livekb</C> contains the total number of
##  kilobytes occupied by those bags; <C>deadbags</C> contains the total
##  number of bags which were reclaimed by that garbage collection and
##  all the partial garbage collections preceding it, since the
##  previous full garbage collection; <C>deadkb</C> contains the total
##  number of kilobytes occupied by those bags; <C>freekb</C> reports the
##  total number of kilobytes available in the &GAP; workspace for new
##  objects; <C>totalkb</C> reports the actual size of the workspace;
##  <C>time</C> reports the CPU time in milliseconds spent on the last garbage
##  collection and <C>cumulative</C> the total CPU time in milliseconds spent
##  on that type of garbage collection since &GAP; started.
##  <P/>
##  These figures should be viewed with some caution. They are
##  stored internally in fixed length integer formats, and <C>deadkb</C>
##  and <C>deadbags</C> are liable to overflow if there are many partial
##  collections before a full collection. Also, note that <C>livekb</C> and
##  <C>freekb</C> will not usually add up to <C>totalkb</C>. The difference is
##  essentially the space overhead of the memory management system.
##  <P/>
##  The <C>partial</C> component will be present if there has been a
##  partial garbage collection since the last full one. It is also a
##  record with the same six components as <C>full</C>. In this case
##  <C>deadbags</C> and <C>deadkb</C> refer only to the number and total size of
##  the garbage bags reclaimed in this partial garbage collection and
##  <C>livebags</C>and <C>livekb</C> only to the numbers and total size of the
##  young bags that were considered for garbage collection, and survived.
##  <P/>
##  The <C>npartial</C> and <C>nfull</C> components will contain the number
##  of full and partial garbage collections performed since &GAP; started.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("GasmanStatistics");


#############################################################################
##
#F  GasmanMessageStatus( )
#F  SetGasmanMessageStatus( <stat> )
##
##  <#GAPDoc Label="GasmanMessageStatus">
##  <ManSection>
##  <Func Name="GasmanMessageStatus" Arg=''/>
##  <Func Name="SetGasmanMessageStatus" Arg='stat'/>
##
##  <Description>
##  This function is meaningful only if <C>GASMAN</C> is
##  the garbage collector used by &GAP;,
##  see Section <Ref Subsect="Garbage Collection"/>.
##  <P/>
##  <Ref Func="GasmanMessageStatus"/> returns one of the strings
##  <C>"none"</C>, <C>"full"</C>, or <C>"all"</C>,
##  depending on whether the garbage collector is currently set to print
##  messages on
##  no collections, full collections only, or all collections, respectively.
##  <P/>
##  Calling <Ref Func="SetGasmanMessageStatus"/> with the argument
##  <A>stat</A>, which should be one of the three strings mentioned above,
##  sets the garbage collector messaging level.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("GasmanMessageStatus");
DeclareGlobalFunction("SetGasmanMessageStatus");


#############################################################################
##
#F  GasmanLimits()
##
##  <#GAPDoc Label="GasmanLimits">
##  <ManSection>
##  <Func Name="GasmanLimits" Arg=''/>
##
##  <Description>
##  This function is meaningful only if <C>GASMAN</C> is
##  the garbage collector used by &GAP;,
##  see Section <Ref Subsect="Garbage Collection"/>.
##  <P/>
##  <Ref Func="GasmanLimits"/> returns a record with three components:
##  <C>min</C> is the minimum workspace size as set by the <C>-m</C>
##  command line option in kilobytes.
##  The workspace size will never be reduced below this by the garbage
##  collector.
##  <C>max</C> is the maximum workspace size,
##  as set by the <C>-o</C> command line option, also in kilobytes.
##  If the workspace would need to grow past this point,
##  &GAP; will enter a break loop to warn the user.
##  A value of 0 indicates no limit.
##  <C>kill</C> is the absolute maximum, set by the <C>-K</C> command line
##  option.
##  The workspace will never be allowed to grow past this limit.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("GasmanLimits");
