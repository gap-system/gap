#############################################################################
##
#W  addgphom.gi                 GAP library                      Scott Murray
#W                                                           Alexander Hulpke
##
##
#Y  (C) 2000 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains declarations for mappings between groups and additive
##  groups.
##


#############################################################################
##
#F  GroupToAdditiveGroupHomomorphismByFunction( <S>, <R>, <fun> )
#F  GroupToAdditiveGroupHomomorphismByFunction( <S>, <R>, <fun>, <invfun> )
##
InstallGlobalFunction(GroupToAdditiveGroupHomomorphismByFunction,function(arg)
local map;

    # no inverse function given
    if Length(arg) = 3  then

      # make the general mapping
      map:= Objectify(
        NewType(GeneralMappingsFamily(ElementsFamily(FamilyObj(arg[1])),
        ElementsFamily(FamilyObj(arg[2]))),
                               IsSPMappingByFunctionRep
                           and IsSingleValued
                           and IsTotal 
			   and IsGroupToAdditiveGroupHomomorphism ),
                       rec( fun:= arg[3] ) );

    # inverse function given
    elif Length(arg) = 4  then

      # make the mapping
      map:= Objectify(
        NewType(GeneralMappingsFamily(ElementsFamily(FamilyObj(arg[1])),
        ElementsFamily(FamilyObj(arg[2]))),
                               IsSPMappingByFunctionWithInverseRep
                           and IsBijective
			   and IsGroupToAdditiveGroupHomomorphism ),
                       rec( fun    := arg[3],
                            invFun := arg[4] ) );

    # otherwise signal an error
    else
      Error(
 "usage: GroupToAdditiveGroupHomomorphismByFunction(<D>,<E>,<fun>[, <inv>])");
    fi;

    SetSource(map,arg[1]);
    SetRange(map,arg[2]);
    # return the mapping
    return map;
end );

#############################################################################
##
#E

