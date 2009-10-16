#############################################################################
##
#W  frdepend.gi                GAP4 Package `RCWA'                Stefan Kohl
##
#H  @(#)$Id: frdepend.gi,v 1.1 2008/02/19 14:41:47 stefan Exp $
##
##  This file contains code which depends on the FR package.
##  Therefore it is read only when FR is available.
##
Revision.frdepend_gi :=
  "@(#)$Id: frdepend.gi,v 1.1 2008/02/19 14:41:47 stefan Exp $";

#############################################################################
##
#S  Methods concerning periodic lists, e.g. the action of rcwa mappings /////
#S  and -groups on them. ////////////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#M  \^( <perlist>, <g> ) . . for a periodic list and an rcwa permutation of Z
##
##  Returns the periodic list which is obtained from <perlist> by permuting
##  the entries by the rcwa permutation <g>.
##  Periodic lists are implemented in the FR package, which therefore needs
##  to be loaded in order to use this method.
##
InstallMethod( \^,
               "for a periodic list and an rcwa permutation of Z (RCWA)",
               ReturnTrue, [ IsPeriodicList, IsRcwaMappingOfZ ], 0,

  function ( perlist, g )

    local  preperiod, period,
           preperiod_bound, preperiod_img, period_bound, period_img,
           perlist_img, inv;

    preperiod := PrePeriod(perlist);
    period    := Period(perlist);

    if not IsBijective(g) then TryNextMethod(); fi;

    if not IsSignPreserving(g) then
      Error("\^ for a periodic list <l> and an rcwa permutation <g>: \n",
            "<g> must fix the nonnegative integers setwise, as <l> \n",
            "does not have entries at negative positions.");
      TryNextMethod();
    fi;

    inv := Inverse(g);
    period_bound := Mod(g) * Mult(g) * Div(g) * Length(period);
    if not IsEmpty(preperiod) then
      preperiod_bound := Maximum([0..Length(preperiod)-1]^g)+1;
      preperiod_bound := period_bound
                       * (Int((preperiod_bound-1)/period_bound)+1);
    else preperiod_bound := 0; fi;
    preperiod_img := List([0..preperiod_bound-1],n->perlist[n^inv+1]);
    period_img := List([preperiod_bound..preperiod_bound+period_bound-1],
                       n->perlist[n^inv+1]);

    perlist_img := PeriodicList(preperiod_img,period_img);
    CompressPeriodicList(perlist_img);
    return perlist_img;
  end );

#############################################################################
##
#M  \^( <perlist>, <f> ) for a periodic list and a non-bijective rcwa mapping
##
##  Returns the periodic list whose n-th entry is the sum of the n^(f^-1)-th
##  entries of <perlist>, where n^(f^-1) denotes the preimage of n under <f>.
##  Periodic lists are implemented in the FR package, which therefore needs
##  to be loaded in order to use this method.
##
InstallMethod( \^,
               "for a periodic list and an rcwa mapping of Z (RCWA)",
               ReturnTrue, [ IsPeriodicList, IsRcwaMappingOfZ ], 0,

  function ( perlist, f )

    local  preperiod, period,
           preperiod_bound, preperiod_img, period_bound, period_img,
           perlist_img, m, r, i;

    preperiod := PrePeriod(perlist);
    period    := Period(perlist);

    if IsBijective(f) or Multiplier(f) = 0 then TryNextMethod(); fi;

    if not IsSignPreserving(f) then
      Error("\^ for a periodic list <l> and an rcwa mapping <f>: \n",
            "<f> must fix the nonnegative integers setwise, as <l> \n",
            "does not have entries at negative positions.");
      TryNextMethod();
    fi;

    period_bound := Mod(f) * Mult(f) * Div(f) * Length(period);
    if not IsEmpty(preperiod) then
      preperiod_bound := Maximum([0..Length(preperiod)-1]^f)+1;
      preperiod_bound := period_bound
                       * (Int((preperiod_bound-1)/period_bound)+1);
    else preperiod_bound := 0; fi;
    preperiod_img := List([0..preperiod_bound-1],
                          n->Sum(perlist{PreImagesElm(f,n)+1}));
    period_img := List([preperiod_bound..preperiod_bound+period_bound-1],
                       n->Sum(perlist{PreImagesElm(f,n)+1}));

    perlist_img := PeriodicList(preperiod_img,period_img);
    CompressPeriodicList(perlist_img);
    return perlist_img;
  end );

#############################################################################
##
#M  IsSubset( <C>, <perlist> ) . . . . . for a collection and a periodic list
##
InstallMethod( IsSubset,
               "for a collection and a periodic list (RCWA)", ReturnTrue,
               [ IsListOrCollection, IsPeriodicList ], 0,

  function ( C, perlist )
    return IsSubset(C,PrePeriod(perlist)) and IsSubset(C,Period(perlist));
  end );

#############################################################################
##
#M  SumOp( <perlist> ) . . . . . . . . . . . . . . . . . . for periodic lists
##
InstallMethod( SumOp,
               "for periodic lists (RCWA)", true, [ IsPeriodicList ], 0,

  function ( perlist )
    if not IsSubset(Rationals,perlist) then TryNextMethod(); fi;
    if   ForAll(Period(perlist),IsZero) then return Sum(PrePeriod(perlist));
    elif Sum(Period(perlist)) > 0 then return infinity;
    elif Sum(Period(perlist)) < 0 then TryNextMethod(); # -infinity
    else return fail; fi; # Alternating case, like 1, -1, 1, -1, 1, -1, ...
  end );

#############################################################################
##
#M  ProductOp( <perlist> ) . . . . . . . . . . . . . . . . for periodic lists
##
InstallMethod( ProductOp,
               "for periodic lists (RCWA)", true, [ IsPeriodicList ], 0,

  function ( perlist )
    if not IsSubset(Rationals,perlist) then TryNextMethod(); fi;
    if   Product(PrePeriod(perlist)) = 0 or Product(Period(perlist)) = 0
    then return 0;
    elif Product(List(Period(perlist),AbsoluteValue)) < 1 then return 0;
    elif Minimum(Period(perlist)) > 0 and Product(Period(perlist)) > 1
    then return infinity;
    elif Set(Period(perlist)) = [1] # Constant period 1, 1, 1, ... case.
    then return Product(PrePeriod(perlist));
    else return fail; fi; # Negative factors, non-convergent case.
  end );

#############################################################################
##
#S  Attributes and properties of certain rcwa groups, ///////////////////////
#S  which are defined in the FR package. ////////////////////////////////////
##
#############################################################################

#############################################################################
##
#M  IsBranch( RCWA( <R> ) ) . . . . . . . . . . . . . . . . . . . for RCWA(R)
#M  IsBranch( CT( <R> ) ) . . . . . . . . . . . . . . . . . . . . . for CT(R)
#M  IsBranchingSubgroup( RCWA( <R> ) )  . . . . . . . . . . . . . for RCWA(R)
#M  IsBranchingSubgroup( CT( <R> ) )  . . . . . . . . . . . . . . . for CT(R)
##
InstallTrueMethod( IsBranch, IsNaturalRCWA_OR_CT );
InstallTrueMethod( IsBranchingSubgroup, IsNaturalRCWA_OR_CT );

#############################################################################
##
#E  frdepend.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here