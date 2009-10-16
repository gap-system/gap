############################################################################
##
##  timing_projectors.g             CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: timing_projectors.g,v 1.4 2005/12/21 17:08:22 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp");
ReadPackage ("crisp", "tst/timing_test.g");
ReadPackage ("crisp", "tst/timing_samples.g");

nilp := Formation ("Nilpotent");

tests :=
[ [tmp -> PcgsElementaryAbelianSeries (tmp), ReturnFail, "elabpc", []],
  [tmp -> Projector (tmp, NilpotentGroups), Size, "form", [], MTXReset, MTXTime, "mtx"],
  [tmp -> Projector (tmp, SchunckClass (rec (
  	bound := G -> not IsPrimeInt (Size (G))))), Size, "bound", [], MTXReset, MTXTime, "mtx"],
  [tmp -> CoveringSubgroup1 (tmp, nilp), Size, "cov1", [], SpcgsCompute, SpcgsTime, "spcgs"],
  [tmp -> CoveringSubgroup2 (tmp, nilp), Size, "cov2", [], SpcgsCompute, SpcgsTime, "spcgs"],
];

Print ("nilpotent projector\n");
DoTests (groups, tests);

ssolv := Formation ("Supersolvable");

tests :=
[ [tmp -> PcgsElementaryAbelianSeries (tmp), ReturnFail, "elabpc", []],
  [tmp -> Projector (tmp, SupersolvableGroups), Size, "form", [], MTXReset, MTXTime, "mtx"],
  [tmp -> Projector (tmp, SchunckClass (rec (
  	bound := G -> not IsPrimeInt (Size ( Socle (G)))))), Size, "bound", [], MTXReset, MTXTime, "mtx"],
  [tmp -> CoveringSubgroup1 (tmp, ssolv), Size, "cov1", [], SpcgsCompute, SpcgsTime, "spcgs"],
  [tmp -> CoveringSubgroup2 (tmp, ssolv), Size, "cov2", [], SpcgsCompute, SpcgsTime, "spcgs"],
];


Print ("supersolvable projector\n");
DoTests (groups, tests);

metanilp := ProductOfFormations (nilp, nilp);
MetaNilpotentGroups := FormationProduct (NilpotentGroups, NilpotentGroups);

tests :=
[ [tmp -> PcgsElementaryAbelianSeries (tmp), ReturnFail, "elabpc", []],
  [tmp -> Projector (tmp, MetaNilpotentGroups), Size, "form", [], MTXReset, MTXTime, "mtx"],
  [tmp -> Projector (tmp, SchunckClass (rec (
  	bound := G -> not IsNilpotent (G/Socle (G))))), Size, "bound", [], MTXReset, MTXTime, "mtx"],
  [tmp -> CoveringSubgroup1 (tmp, metanilp), Size, "cov1", [], SpcgsCompute, SpcgsTime, "spcgs"],
  [tmp -> CoveringSubgroup2 (tmp, metanilp), Size, "cov2", [], SpcgsCompute, SpcgsTime, "spcgs"],
];
Print ("metanilpotent projector\n");
DoTests (groups, tests);

23groups := Formation ("PiGroups", [2,3]);
TwoThreeGroups := PiGroups ([2,3]);

tests :=
[ [tmp -> PcgsElementaryAbelianSeries (tmp), ReturnFail, "elabpc", []],
  [tmp -> Projector (tmp, TwoThreeGroups), Size, "form", [], MTXReset, MTXTime, "mtx"],
  [tmp -> Projector (tmp, SaturatedFormation (rec (locdef := LocalDefinitionFunction (TwoThreeGroups)
    ))), Size, "locdef", [], MTXReset, MTXTime, "mtx"],
  [tmp -> Projector (tmp, SchunckClass (rec (
  	bound := G -> not SmallestRootInt (Size (Socle(G))) in [2,3] ))), Size, "bound", [], MTXReset, MTXTime, "mtx"],
  [tmp -> CoveringSubgroup1 (tmp, 23groups), Size, "cov1", [], SpcgsCompute, SpcgsTime, "spcgs"],
  [tmp -> CoveringSubgroup2 (tmp, 23groups), Size, "cov2", [], SpcgsCompute, SpcgsTime, "spcgs"],
];
Print ("[2,3]- projector\n");
DoTests (groups, tests);

nilp23 := ChangedSupport (nilp, [2,3]);
NilpotentTwoThreeGroups := Intersection (NilpotentGroups, TwoThreeGroups);

tests :=
[ [tmp -> PcgsElementaryAbelianSeries (tmp), ReturnFail, "elabpc", []],
  [tmp -> Projector (tmp, NilpotentTwoThreeGroups), Size, "form", [], MTXReset, MTXTime, "mtx"],
  [tmp -> Projector (tmp, SchunckClass (rec (
  	bound := G -> not SmallestRootInt (Size (Socle(G))) in [2,3] 
  		or not IsNilpotent (G)))), 
  	Size, "bound", [], MTXReset, MTXTime, "mtx"],
  [tmp -> CoveringSubgroup1 (tmp, nilp23), Size, "cov1", [], SpcgsCompute, SpcgsTime, "spcgs"],
  [tmp -> CoveringSubgroup2 (tmp, nilp23), Size, "cov2", [], SpcgsCompute, SpcgsTime, "spcgs"],
];
Print ("nilp [2,3]- projector\n");
DoTests (groups, tests);


############################################################################
##
#E
##
