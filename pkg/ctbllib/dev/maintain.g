#############################################################################
##
#W  maintain.g           GAP 4 package `ctbllib'                Thomas Breuer
##
#H  @(#)$Id: maintain.g,v 1.6 2003/09/04 16:15:21 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains {\GAP} functions that are needed for maintaining the
##  {\GAP} Character Table Library but not intended for the distribution
##  of the package.
##
##  The following directories are used for that.
##  `dev/log' :
##      Logfiles for the {\GAP} script `testcons.g' are stored here.
##
##  ...
##
Revision.( "ctbllib/gap/maintain_g" ) :=
    "@(#)$Id: maintain.g,v 1.6 2003/09/04 16:15:21 gap Exp $";


#############################################################################
##
##  List the ``open problems'' in the data files and in the {\GAP} code files
##  (which are marked with `#T').
##
Print( "add some utilities to `dev/maintain.g'!\n" );


#############################################################################
##
##  ...
##

#############################################################################
##
#F  CTblLibTestFactorsModOP( [<ordname>] )
##
##  Let <tbl> be the ordinary character table of the group $G$, say,
##  and <p> be a prime divisor of $|G|$.
##  If <tbl> is not <p>-solvable and $O_{<p>}(G)$ is nontrivial then the
##  <p>-modular Brauer table for $G$ can be computed as that of the factor
##  $G / O_{<p>}(G)$.
##  So if the <p>-modular Brauer table of this factor is available in the
##  {\GAP} Character Table Library then the factor fusion from <tbl> to its
##  ordinary character table must be stored on <tbl>;
##  then the <p>-modular Brauer table of <tbl> can be automatically accessed.
#T better print a message only if the table of the factor group in question
#T is contained in the library *and* its <p>-modular table is available?
##
DeclareGlobalFunction( "CTblLibTestFactorsModOP" );

InstallGlobalFunction( CTblLibTestFactorsModOP, function( arg )
    local result, tbl, classes, nsg, sizes, pair, p, ppart, op, i, fact,
    trans, fun, cand, fus, name;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 1 then

      tbl:= CharacterTable( arg[1] );
      classes:= SizesConjugacyClasses( tbl );
      nsg:= ClassPositionsOfNormalSubgroups( tbl );
      sizes:= List( nsg, l -> Sum( classes{ l } ) );
      for pair in Collected( Factors( Size( tbl ) ) ) do
        p:= pair[1];
        if not IsPSolvableCharacterTable( tbl, p ) then

          ppart:= p^pair[2];
          op:= 0;
          for i in [ 2 .. Length( nsg ) ] do
            if ppart mod sizes[i] = 0 then
              op:= nsg[i];
            fi;
          od;

          if     op <> 0
             and ForAll( ComputedClassFusions( tbl ),
                     fus -> ClassPositionsOfKernel( fus.map ) <> op ) then
            Print( "#I  factor fusion from ", Identifier( tbl ),
                   " modulo O_", p, " is not stored\n" );

            # Try to find the table of the factor group in the library.
            fact:= CharacterTableFactorGroup( tbl, op );
            trans:= fail;

            fun:= function( ftbl )
              trans:= TransformingPermutationsCharacterTables( fact, ftbl );
              return trans <> fail;
            end;

            cand:= OneCharacterTableName( FingerprintOfCharacterTable,
                       FingerprintOfCharacterTable( fact ),
                       fun, true );

            if cand <> fail then
              fus:= rec( name := Identifier( cand ),
                         map  := OnTuples( GetFusionMap( tbl, fact ),
                                           trans.columns ) );
              Print( "#I  store the following fusion from `",
                     Identifier( tbl ), "' to `", Identifier( cand ), "':\n",
                     LibraryFusion( Identifier( tbl ), fus ) );
            fi;

          fi;
        fi;
      od;

    elif Length( arg ) = 0 then
      for name in LIBLIST.allnames do
        result:= CTblLibTestFactorsModOP( name ) and result;
      od;
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#E

