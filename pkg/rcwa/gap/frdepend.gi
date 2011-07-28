#############################################################################
##
#W  frdepend.gi                GAP4 Package `RCWA'                Stefan Kohl
##
##  This file contains code which depends on the FR package.
##  Therefore it is read only when FR is available.
##
#############################################################################

#############################################################################
##
#S  Methods dealing with periodic lists. ////////////////////////////////////
##
#############################################################################

#############################################################################
##
#M  Permuted( <perlist>, <g> ) . for a periodic list and an rcwa permut. of Z
##
##  Returns the periodic list which is obtained from <perlist> by permuting
##  the entries by the rcwa permutation <g>.
##  Periodic lists are implemented in the FR package, which therefore needs
##  to be loaded in order to use this method.
##
InstallOtherMethod( Permuted,
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
      Error("`Permuted' for a periodic list <l> and a <g> in RCWA(Z): \n",
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
#M  Permuted( <perlist>, <f> ) .  for periodic list and non-bij. rcwa mapping
##
##  Returns the periodic list whose n-th entry is the sum of the n^(f^-1)-th
##  entries of <perlist>, where n^(f^-1) denotes the preimage of n under <f>.
##  Periodic lists are implemented in the FR package, which therefore needs
##  to be loaded in order to use this method.
##
InstallOtherMethod( Permuted,
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
      Error("`Permuted' for a periodic list <l> and an rcwa mapping <f>: \n",
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
#M  AdditiveInverseOp( <perlist> ) . . . . . . . . . . . . for periodic lists
##
InstallOtherMethod( AdditiveInverseOp,
                    "for periodic lists (RCWA)", true, [ IsPeriodicList ], 0,
                    l -> PeriodicList(-PrePeriod(l),-Period(l)));

#############################################################################
##
#M  \+( <l1>, <l2> ) . . . . . . . . . . . . . . . . . . . for periodic lists
##
InstallOtherMethod( \+,
                    "for periodic lists (RCWA)", ReturnTrue,
                    [ IsPeriodicList, IsPeriodicList ], 0,

  function ( l1, l2 )

    local  prelng, perlng, sum;

    prelng := Maximum(Length(PrePeriod(l1)),Length(PrePeriod(l2)));
    perlng := Lcm(Length(Period(l1)),Length(Period(l2)));
    sum := PeriodicList(l1{[1..prelng]} + l2{[1..prelng]},
                        l1{[prelng+1..prelng+perlng]}
                      + l2{[prelng+1..prelng+perlng]});
    CompressPeriodicList(sum);
    return sum;
  end );

#############################################################################
##
#M  \+( <l>, <n> ) . . . . . . . . . . . . . . for periodic list and constant
#M  \+( <n>, <l> ) . . . . . . . . . . . . . . for constant and periodic list
##
InstallOtherMethod( \+,"for periodic list and constant (RCWA)", ReturnTrue,
                       [ IsPeriodicList, IsAdditiveElement ], 0,
  function ( l, n ) return PeriodicList(PrePeriod(l)+n,Period(l)+n); end );
InstallOtherMethod( \+,"for constant and periodic list (RCWA)", ReturnTrue,
                       [ IsAdditiveElement, IsPeriodicList ], 0,
  function ( n, l ) return PeriodicList(n+PrePeriod(l),n+Period(l)); end );

#############################################################################
##
#M  \*( <l>, <n> ) . . . . . . . . . . . . . . for periodic list and constant
#M  \*( <n>, <l> ) . . . . . . . . . . . . . . for constant and periodic list
##
InstallOtherMethod( \*,"for periodic list and constant (RCWA)", ReturnTrue,
                       [ IsPeriodicList, IsMultiplicativeElement ], 0,
  function ( l, n ) return PeriodicList(PrePeriod(l)*n,Period(l)*n); end );
InstallOtherMethod( \*,"for constant and periodic list (RCWA)", ReturnTrue,
                       [ IsMultiplicativeElement, IsPeriodicList ], 0,
  function ( n, l ) return PeriodicList(n*PrePeriod(l),n*Period(l)); end );

#############################################################################
##
#M  \/( <l>, <n> ) . . . . . . . . . . . . . . for periodic list and constant
##
InstallOtherMethod( \/,"for periodic list and constant (RCWA)", ReturnTrue,
                       [ IsPeriodicList, IsMultiplicativeElement ], 0,
  function ( l, n ) return PeriodicList(PrePeriod(l)/n,Period(l)/n); end );

#############################################################################
##
#E  frdepend.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here