#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Derek Holt, Sarah Rees, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for the 'Smash'-MeatAxe modified for
##  GAP4 and using the standard MeatAxe interface.  It defines the MeatAxe
##  SMTX.
##

#############################################################################
##
#F  GModuleByMats(<mats>,<f>)
##
DeclareGlobalFunction("GModuleByMats");

#############################################################################
##
#F  TrivialGModule ( g, F ) . . . trivial G-module
##
##  g is a finite group, F a field, trivial smash G-module computed.
DeclareGlobalFunction("TrivialGModule");

#############################################################################
##
#F  InducedGModule ( g, h, m ) . . . calculate an induced G-module
##
## h should be a subgroup of a finite group g, and m a smash
## GModule for h.
## The induced module for g is calculated.
DeclareGlobalFunction("InducedGModule");

#############################################################################
##
#F PermutationGModule ( g, F) . permutation module
##
## g is a permutation group, F a field.
## The corresponding permutation module is output.
DeclareGlobalFunction("PermutationGModule");

###############################################################################
##
#F  TensorProductGModule ( m1, m2 )  . . tensor product of two G-modules
##
## TensorProductGModule calculates the tensor product of smash
## modules m1 and m2.
## They are assumed to be modules over the same algebra so, in particular,
## they  should have the same number of generators.
##
DeclareGlobalFunction("TensorProductGModule");

###############################################################################
##
#F  WedgeGModule ( module ) . . . . . wedge product of a G-module
##
## WedgeGModule calculates the wedge product of a G-module.
## That is the action on antisymmetrix tensors.
##
DeclareGlobalFunction("WedgeGModule");

###############################################################################
##
#F  DualGModule ( module ) . . . . . dual of a G-module
##
## DualGModule calculates the dual of a G-module.
## The matrices of the module are inverted and transposed.
##
DeclareGlobalFunction("DualGModule");

###############################################################################
##
#F TestModulesFitTogether(m1,m2)
##
##  Given two modules <m1> and <m2> this routine tests whether both have the
##  same number of generators and are defined over the same field.
##
DeclareGlobalFunction("TestModulesFitTogether");

DeclareInfoClass("InfoMeatAxe");
DeclareInfoClass("InfoMtxHom");


SMTX:=rec(name:="The Smash MeatAxe");
MTX:=SMTX;

SMTX.Getter := function(string)
  MakeImmutable(string);
  return function(module)
    if not (IsBound(module.smashMeataxe) and
            IsBound(module.smashMeataxe.(string))) then
      return fail;
    else
      return module.smashMeataxe.(string);
    fi;
  end;
end;

