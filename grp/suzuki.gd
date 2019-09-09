#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Stefan Kohl.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#O  SuzukiGroupCons( <filter>, <q> )
##
##  <ManSection>
##  <Oper Name="SuzukiGroupCons" Arg='filter, q'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "SuzukiGroupCons", [ IsGroup, IsInt ] );

#############################################################################
##
#F  SuzukiGroup( [<filt>, ] <q> )  . . . . . . . . . . . . . . . Suzuki group
#F  Sz( [<filt>, ] <q> )
##
##  <#GAPDoc Label="SuzukiGroup">
##  <ManSection>
##  <Func Name="SuzukiGroup" Arg='[filt, ] q'/>
##  <Func Name="Sz" Arg='[filt, ] q'/>
##
##  <Description>
##  Constructs a group isomorphic to the Suzuki group Sz( <A>q</A> )
##  over the field with <A>q</A> elements, where <A>q</A> is a non-square
##  power of <M>2</M>.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Filt="IsMatrixGroup"/>,
##  and the returned group is the Suzuki group itself.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  <Example><![CDATA[
##  gap> SuzukiGroup( 32 );
##  Sz(32)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "SuzukiGroup", function ( arg )

  if Length(arg) = 1 then
    return SuzukiGroupCons( IsMatrixGroup, arg[1] );
  elif IsOperation(arg[1]) then
    if Length(arg) = 2 then
      return SuzukiGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage: SuzukiGroup( [<filter>, ] <q> )" );

end );

DeclareSynonym( "Sz", SuzukiGroup );
