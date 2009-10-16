#############################################################################
##
##  libhacks.gi           recog package                   Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2005 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  Some corrections to the library.
##
##  $Id: libhacks.gi,v 1.3 2005/10/11 15:19:33 gap Exp $
##
#############################################################################


#############################################################################
##
#M  Range( <hom>, <H> ) . . . . . . . . . . . . . . . . . . . . for const hom
##
RanImgSrcSurjTraho:=function(hom)
local   D,H,I,G;
  H:=Source(hom);
  # only worth if the source has a stab chain to utilize
  if not HasStabChainMutable(H) then
    TryNextMethod();
  fi;
  D := Enumerator( UnderlyingExternalSet( hom ) );
  I := EmptyStabChain( [  ], () );
  RemoveStabChain( ConjugateStabChain( StabChainOp( H, D ), I,
          hom, hom!.conperm,
          S -> BasePoint( S ) <> false
            and BasePoint( S ) in D ) );
  #GroupStabChain might give too many generators
  if Length(I.generators)<0 then    # this should not happen!
    return GroupStabChain( I );
  else
    G:=Group(List(GeneratorsOfGroup(H),i->Permutation(i,D)),());
    SetStabChainMutable(G,I);
    return G;
  fi;
end;

InstallMethod( Range,"surjective constituent homomorphism",true,
  [ IsConstituentHomomorphism and IsActionHomomorphism and IsSurjective ],0,
  RanImgSrcSurjTraho);

InstallMethod( ImagesSource,"constituent homomorphism",true,
  [ IsConstituentHomomorphism and IsActionHomomorphism ],0,
  RanImgSrcSurjTraho);


