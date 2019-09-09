#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#O  ReeGroupCons( <filter>, <q> )
##
##  <ManSection>
##  <Oper Name="ReeGroupCons" Arg='filter, q'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "ReeGroupCons", [ IsGroup, IsInt ] );

#############################################################################
##
#F  ReeGroup( [<filt>, ] <q> )  . . . . . . . . . . . . . . . Ree group
#F  Ree( [<filt>, ] <q> )
##
##  <#GAPDoc Label="ReeGroup">
##  <ManSection>
##  <Func Name="ReeGroup" Arg='[filt, ] q'/>
##  <Func Name="Ree" Arg='[filt, ] q'/>
##
##  <Description>
##  Constructs a group isomorphic to the Ree group <M>^2G_2(q)</M> where
##  <M>q = 3^{{1+2m}}</M> for <M>m</M> a non-negative integer.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Filt="IsMatrixGroup"/>
##  and the generating matrices are based on&nbsp;<Cite Key="KLM01"/>.
##  (No particular choice of a generating set is guaranteed.)
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> ReeGroup( 27 );
##  Ree(27)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "ReeGroup", function ( arg )

  if Length(arg) = 1 then
    return ReeGroupCons( IsMatrixGroup, arg[1] );
  elif IsOperation(arg[1]) then
    if Length(arg) = 2 then
      return ReeGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage: ReeGroup( [<filter>, ] <m> )" );

end );

DeclareSynonym( "Ree", ReeGroup );
