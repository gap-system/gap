#############################################################################
##
#W  callsis.gd               GAP Share Library               Martin Wursthorn
##
#H  @(#)$Id: callsis.gd,v 1.1 2000/10/23 17:05:01 gap Exp $
##
#Y  Copyright 1994-1995,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of the low level interface
##  between {\SISYPHOS} and {\GAP}~4.
##
Revision.callsis_gd :=
    "@(#)$Id: callsis.gd,v 1.1 2000/10/23 17:05:01 gap Exp $";


#############################################################################
##
#V  SISYPHOS
#V  p
##
##  These are global variables.
##  A perhaps existing variable 'p' will be saved always (except if the
##  computation is interrupted during the run of one of the programs in this
##  file).
##
DeclareGlobalVariable( "SISYPHOS" );


#############################################################################
##
#A  IsCompatiblePCentralSeries( <G> ) . . . .  compatible to p-central series
##
##  Let <G> be a polycyclicly presented $p$-group.
##  `IsCompatiblePCentralSeries' returns `true' if the presentation of <G> is
##  compatible to the exponent-$p$-central series of <G> in the sense that
##  the generators of each term of this series form a subset of
##  the generators of <G>.
##  Otherwise `false' is returned.
##
DeclareAttribute( "IsCompatiblePCentralSeries", IsGroup );
#T PcGroup?


#############################################################################
##
#F  OrderGL( <n>, <q> ) . . . . . . . . . . . . order of general linear group
##
##  computes the order of $GL(n,q)$, where $q$ is a power of a prime $p$
##
DeclareGlobalFunction( "OrderGL" );


#############################################################################
##
#F  EstimateAmount( <G>, <flags> )  .  amount of memory needed in {\SISYPHOS}
##
##  estimate amount of temporary memory needed by {\SISYPHOS} to compute the
##  automorphism group of <G>.
##  The calculation is based on the well known upper bound for $Aut(<G>)$,
##  the size of the {\SISYPHOS} data structures that hold a description
##  of $<G>$ and $Aut(<G>)$, and several scalar values.
##  The minimal value returned is 200000, the maximal value 12000000 (bytes).
##
##  <flags> is a list of two boolean values.
##  If the first one is `true' then the amount of memory needed to compute
##  generators for the full automorphism group is taken into account;
##  otherwise only the amount for normalized automorphisms is calculated.
##  If the second value is `true', the amount of memory needed to compute 
##  an element list for $Aut(<G>)$ is added.
##
DeclareGlobalFunction( "EstimateAmount" );


#############################################################################
##
#F  SisyphosWord( <P>, <a> )  . . . . . .  convert agword to {\SISYPHOS} word
##
##  For a polycyclicly presented group <P> and an element <a> of <P>,
##  `SisyphosWord( <P>, <a> )' returns a string that encodes <a> in the
##  input format of the {\SISYPHOS} system.
##
##  The string `\"1\"' means the identity element, the other elements are
##  written as products of powers of generators,
##  where the <i>-th generator is given the name `g<i>'.
##
##  (This function is used only inside `SisyphosInputPGroup'.)
##
DeclareGlobalFunction( "SisyphosWord" );


#############################################################################
##
#F  SisyphosGenWord( <S>, <a>, <pp> ) . .  convert agword to {\SISYPHOS} word
##
##  Let <a> be an exponent vector representing an element $g$, say,
##  in a policyclicly presented group.
##  `SisyphosGenWord' returns a string that encodes $g$ in the {\SISYPHOS}
##  format for group elements.
##  <S> must be a string representing the {\SISYPHOS} name of the group.
##  The output string consists of products of generators of the form
##  `<S><sep><i>', separated by `*'.
##  If <pp> has the value `true' then <sep> is `.', otherwise it is the empty
##  string; `<S>.id' means the identity element.
##
DeclareGlobalFunction( "SisyphosGenWord" );


#############################################################################
##
#F  SisyphosInputPGroup( <P>, <name>, <type>[, <weights>] )
##
##  returns the string describing the presentation of the finite
##  $p$-group <P> in a format readable by the {\SISYPHOS} system.
##  <P> must be a polycyclicly or freely presented group.
##
##  In {\SISYPHOS}, the group will be named <name>.
##  If <P> is polycyclicly presented the <i>-th generator gets the name
##  'g<i>'.
##  In the case of a free presentation the names of the generators are not
##  changed; note that {\SISYPHOS} accepts only generators names beginning
##  with a letter followed by a sequence of letters and digits.
##
##  <type> must be either the string `\"pcgroup\"' or the unique prime
##  dividing the order of <P>.
##  In the former case the {\SISYPHOS} object has type `pcgroup',
##  <P> must be polycyclicly presented for that.
##  In the latter case a {\SISYPHOS} object of type `group' is created.
##  For avoiding computations in freely presented groups,
##  it is *neither* checked that the presentation describes a $p$-group,
##  *nor* that the given prime really divides the group order.
##
##  If the optional argument <weights> is given, it must be a list of
##  weights w.r.t.~the Jennings series of the group.
##  The weights are needed whenever one wants to deal with the group ring.
##
##  See the {\SISYPHOS} manual~\cite{Wur93} for details.
##
DeclareGlobalFunction( "SisyphosInputPGroup" );


#############################################################################
##
#F  SisyphosCall( ... )
##
##  common part of all calls to the standalone
##
DeclareGlobalFunction( "SisyphosCall" );


#############################################################################
##
#E

