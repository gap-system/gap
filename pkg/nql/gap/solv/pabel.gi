############################################################################
##
#W pabel.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: pabel.gi,v 1.1 2010/07/26 05:18:45 gap Exp $
##
Revision.("isopcp/gap/solv/pabel_gi"):=
  "@(#)$Id: pabel.gi,v 1.1 2010/07/26 05:18:45 gap Exp $";

# Solution via Sylow-decomposition

############################################################################
##
#F SolutionPGroup( <mat>, <b>, <mod> )
##
SolutionPGroup := function( arg )
  if Length( arg ) = 1 then
    return( SolutionPGroup_Hensel( arg[1].matrix, arg[1].rhs, arg[1].modulus ));
  elif Length( arg ) = 2 then 
    if arg[2] = 1 then 
      return( SolutionPGroup_Hensel( arg[1].matrix, arg[1].rhs, 
                                     arg[1].modulus ));
    elif arg[2] = 2 then 
      return( SolutionPGroup_Block( arg[1].matrix, arg[1].rhs, 
                                    arg[1].modulus ));
    elif arg[2] = 3 then 
      return( SolutionPGroup_SNF( arg[1].matrix, arg[1].rhs, arg[1].modulus ));
    elif arg[2] = 4 then 
      return( SolutionPGroup_Polycyclic( arg[1].matrix, arg[1].rhs, 
                                         arg[1].modulus ));
    fi;
  elif Length( arg ) = 3 then 
    return( SolutionPGroup_Hensel( arg[1], arg[2], arg[3] ));
  elif Length( arg ) = 4 then 
   if arg[4] = 1 then 
     return( SolutionPGroup_Hensel( arg[1], arg[2], arg[3] ));
   elif arg[4] = 2 then 
     return( SolutionPGroup_Block( arg[1], arg[2], arg[3] ));
   elif arg[4] = 3 then 
     return( SolutionPGroup_SNF( arg[1], arg[2], arg[3] ));
   elif arg[4] = 4 then 
     return( SolutionPGroup_Polycyclic( arg[1], arg[2], arg[3] ));
   fi;
  fi;
  Display( "No method found!" );
  end;
#X#InstallMethod( SolutionPGroup,
#X#  "for a matrix, a vector, and a modulus", true,
#X#  [ IsMatrix, IsList, IsList ], 0,
#X#  function( Mat, rhs, modulus )
#X#
#X#  return( SolutionPGroup_Hensel( Mat, rhs, modulus ) );
#X#  end);
#X#
#X#InstallOtherMethod( SolutionPGroup,
#X#  "for a matrix, a vector, a modulus, and an integer", true,
#X#  [ IsMatrix, IsList, IsList, IsPosInt ], 0,
#X#  function( Mat, rhs, modulus, ell )
#X# 
#X#  if ell = 1 then 
#X#    return( SolutionPGroup_Hensel( Mat, rhs, modulus ) );
#X#  elif ell = 2 then 
#X#    return( SolutionPGroup_Polycyclic( Mat, rhs, modulus ) );
#X#  elif ell = 3 then 
#X#    return( SolutionPGroup_SNF( Mat, rhs, modulus ) );
#X#  else 
#X#    TRY_NEXT_METHOD();
#X#  fi;
#X#  end);
#X#
#X#InstallOtherMethod( SolutionPGroup,
#X#  "for a record", true, [ IsRecord ], 0, 
#X#  R -> SolutionPGroup_Hensel( R.matrix, R.rhs, R.modulus ));
#X#  
#X#InstallOtherMethod( SolutionPGroup, 
#X#  "for a record and a positive integer", true, [ IsRecord, IsPosInt ], 0,
#X#  function( R, ell )
#X#  if ell = 1 then 
#X#    return( SolutionPGroup_Hensel( R.matrix, R.rhs, R.modulus ) );
#X#  elif ell = 2 then 
#X#    return( SolutionPGroup_Polycyclic( R.matrix, R.rhs, R.modulus ) );
#X#  elif ell = 3 then 
#X#    return( SolutionPGroup_SNF( R.matrix, R.rhs, R.modulus ));
#X#  fi;
#X#  TRY_NEXT_METHOD();
#X#  end);
