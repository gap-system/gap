#############################################################################
#
#W  ree.gd                        GAP library                Alexander Hulpke
##
##
#Y  (C) 2001 School Math. Sci., University of St Andrews, Scotland
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
##  If <A>filt</A> is not given it defaults to <Ref Func="IsMatrixGroup"/>
##  and the generating matrices are based on&nbsp;<Cite Key="KLM01"/>.
##  (No particular choice of a generating set is guaranteed.)
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


#############################################################################
##
#E

