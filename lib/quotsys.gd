#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Werner Nickel.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#C  IsQuotientSystem  . . . . . . . . . . . . . . . . .  declare the category
##
##  A quotient system contains all the data necessary for computing a
##  quotient group of  finitely presented group.  Typically, the quotient
##  group is a p-group, a nilpotent group, a finite soluble group or a
##  polycyclic group.
##
##  Every quotient system contains the finitely presented group, a quotient
##  group and lots of auxiliary information.
##
##  Here I should have the list of components that every quotient system
##  *must* have and a list of operations for which there *must* be methods
##  installed.
##
DeclareCategory( "IsQuotientSystem", IsObject );


#############################################################################
##
#I  InfoQuotientSystem  . . . . . . . . . . . . . . . . . provide information
##
DeclareInfoClass( "InfoQuotientSystem" );

#############################################################################
##
#P  IsPQuotientSystem . . . . . . . . . . . . . . . . .  declare the category
##
##  Here I should have a list of components that every p-quotient system
##  *must* have and a list of operations for which there *must* be methods
##  installed.
##
DeclareProperty( "IsPQuotientSystem", IsQuotientSystem );
InstallTrueMethod( IsQuotientSystem, IsPQuotientSystem );


#############################################################################
##
#P  IsNilpQuotientSystem  . . . . . . . . . . . . . . .  declare the category
##
##  Here I should have a list of components that every nilpotent quotient
##  system *must* have and a list of operations for which there *must* be
##  methods installed.
##
DeclareProperty( "IsNilpQuotientSystem", IsQuotientSystem );
InstallTrueMethod( IsQuotientSystem, IsNilpQuotientSystem );


#############################################################################
##
#O  QuotientSystem  . . . . . . . . . . . . . . . . . . declare the operation
##
DeclareOperation( "QuotientSystem",
        [ IsObject, IsPosInt, IsPosInt, IsString ] );

#############################################################################
##
#F  QuotSysDefinitionByIndex  . . . . . . . . . . convert index to definition
##
DeclareGlobalFunction( "QuotSysDefinitionByIndex" );

#############################################################################
##
#F  QuotSysIndexByDefinition  . . . . . . . . . . convert definition to index
##
DeclareGlobalFunction( "QuotSysIndexByDefinition" );

#############################################################################
##
#O  GetDefinitionNC . . . . . . . . . . . . . . . . . . declare the operation
##
DeclareOperation( "GetDefinitionNC",
        [IsQuotientSystem, IsPosInt] );


#############################################################################
##
#O  SetDefinitionNC . . . . . . . . . . . . . . . . . . declare the operation
##
DeclareOperation( "SetDefinitionNC",
        [IsQuotientSystem, IsPosInt, IsObject] );


#############################################################################
##
#O  ClearDefinitionNC . . . . . . . . . . . . . . . . . declare the operation
##
DeclareOperation( "ClearDefinitionNC", [IsQuotientSystem, IsPosInt] );

#############################################################################
##
#O  DefineNewGenerators . . . . . . . . . . . .  generators of the next layer
##
DeclareOperation( "DefineNewGenerators", [IsQuotientSystem] );

#############################################################################
##
#O  SplitWordTail . . . . . . . . . . . . . . split a word into word and tail
##
DeclareOperation( "SplitWordTail", [IsQuotientSystem, IsAssocWord] );

#############################################################################
##
#O  ExtRepByTailVector  . . . . .  ext repr from an exponent vector of a tail
##
DeclareOperation( "ExtRepByTailVector", [IsQuotientSystem,IsVector] );

#############################################################################
##
#O  GeneratorNumberOfQuotient . . . . . min. generator number of the quotient
##
DeclareOperation( "GeneratorNumberOfQuotient", [IsQuotientSystem] );

#############################################################################
##
#O  TailsInverses . . compute the tails of the inverses in a single collector
##
DeclareOperation( "TailsInverses", [IsQuotientSystem] );

#############################################################################
##
#O  ComputeTails  . . . . . . . . . . . . compute the tails of a presentation
##
DeclareOperation( "ComputeTails", [IsQuotientSystem] );

#############################################################################
##
#O  EvaluateConsistency . . . . . . . . . . . . . . run the consistency tests
##
DeclareOperation( "EvaluateConsistency", [IsQuotientSystem] );

#############################################################################
##
#O  IncorporateCentralRelations . . . . . . . . . . .  relations into pc pres
##
DeclareOperation( "IncorporateCentralRelations", [IsQuotientSystem] );

#############################################################################
##
#O  RenumberHighestWeightGenerators . . . . . . . . . . . renumber generators
##
DeclareOperation( "RenumberHighestWeightGenerators", [IsQuotientSystem] );

#############################################################################
##
#O  EvaluateRelators  . . . . . . . . evaluate relations of a quotient system
##
DeclareOperation( "EvaluateRelators", [IsQuotientSystem] );

#############################################################################
##
#O  LiftEpimorphism . . . . . . . . lift the epimorphism of a quotient system
##
DeclareOperation( "LiftEpimorphism", [IsQuotientSystem] );

#############################################################################
##
#O  GeneratorsOfLayer . . . .  generators of a layer in the descending series
##
DeclareOperation( "GeneratorsOfLayer", [IsQuotientSystem, IsPosInt] );

#############################################################################
##
#O  LengthOfDescendingSeries  . . . . . . . . length of the descending series
##
DeclareOperation( "LengthOfDescendingSeries", [IsQuotientSystem] );

#############################################################################
##
#O  RanksOfDescendingSeries   . ranks of the factors in the descending series
##
DeclareOperation( "RanksOfDescendingSeries", [IsQuotientSystem] );

#############################################################################
##
#O  CheckConsistencyOfDefinitions . .  check definitions of a quotient system
##
DeclareOperation( "CheckConsistencyOfDefinitions", [IsQuotientSystem] );

#############################################################################
##
#O  GroupByQuotientSystem . . . . .  construct a group from a quotient system
##
DeclareOperation( "GroupByQuotientSystem", [IsQuotientSystem] );


#############################################################################
##
#O  TraceDefinition . . . . . . trace a generator back to defining generators
##
DeclareOperation( "TraceDefinition", [IsQuotientSystem, IsPosInt] );

#############################################################################
##
#E  Emacs . . . . . . . . . . . . . . . . . . . . . . . . . . emacs variables
##
##  Local Variables:
##  mode:               outline
##  tab-width:          4
##  outline-regexp:     "#[ACEFHMOPRWY]"
##  fill-column:        77
##  fill-prefix:        "##  "
##  eval:               (hide-body)
##  End:
