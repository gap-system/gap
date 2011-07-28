#############################################################################
##
##  solveeq.gd                      CRISP                   Burkhard Höfling
##
##  @(#)$Id: solveeq.gd,v 1.4 2011/05/15 19:18:04 gap Exp $
##
##  Copyright (C) 2000,2001 Burkhard Höfling
##
Revision.solveeq_gd :=
    "@(#)$Id: solveeq.gd,v 1.4 2011/05/15 19:18:04 gap Exp $";


#############################################################################
##
#F  LinearSystem (nrvars, nrsolutions, field, conv, convsol)
##
##  LinearSystem returns a linear system of equations over the field <field>
##  with <nrvars> variables. Each equation has <nrsolutions> right hand 
##  sides, which are treated in parallel.
##
##  Initially, the linear system is empty. Equations can be added using
##  AddEquation.
##  
##  conv and convsol are booleans. They determine whether the coefficents
##  of the left hand side and the solutions on the right hand side will
##  be stored as compressed vectors if possible.
##
DeclareGlobalFunction ("LinearSystem");


#############################################################################
##
#F  AddEquation (sys, row, sol)
##
##  This function adds a new row to a system of linear equations <sys> 
##  obtained from LinearSystem. <row> is a vector containing the coefficents
##  of the variables, <sol> is a vector containing the solutions. 
##
##  If <sys> has no solution, AddEquation simply returns fail.
##
##  If <sys> has a solution, the new row is added to the system, and the
##  system is triangulised. If the resulting system has a solution, 
##  AddEquation returns true, otherwise false.
##
##  AddEquation may change sys, but does not change row or sol.
##
DeclareGlobalFunction ("AddEquation");


#############################################################################
##
#F  HasSolution (sys, n)
##
##  This function returns true or false, depending whether sys has a solution
##  or not, using the linear system whose right hand side consists of the 
##  <n>-th entries of the solutions added via AddEquation.
##
DeclareGlobalFunction ("HasSolution");


#############################################################################
##
#F  DimensionOfNullspace (sys)
##
##  This function returns the dimension of the nullspace of sys.
##
DeclareGlobalFunction ("DimensionOfNullspace");


#############################################################################
##
#F  OneSolution (sys, n)
##
##  This function returns fail if sys has no solutions. Otherwise it returns
##  a vector which is a solution for the linear system whose right hand side 
##  consists of the <n>-th entries of the solutions added via AddEquation.
##
DeclareGlobalFunction ("OneSolution");


#############################################################################
##
#F  BasisNullspaceSolution (sys)
##
##  This function returns list of row vectors representing a basis of the 
##  vector space of all solutions of the homogeneous system corresponding 
##  to sys. Note that this also works if sys does not have a solution.
##
DeclareGlobalFunction ("BasisNullspaceSolution");


############################################################################
##
#E
##
