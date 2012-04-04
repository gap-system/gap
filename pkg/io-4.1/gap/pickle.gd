#############################################################################
##
##  pickle.gd           GAP 4 package IO                    
##                                                           Max Neunhoeffer
##
##  Copyright (C) by Max Neunhoeffer
##  This file is free software, see license information at the end.
##
##  This file contains functions for pickling and unpickling.
##

DeclareGlobalVariable( "IO_PICKLECACHE" );
DeclareGlobalFunction( "IO_ClearPickleCache" );
DeclareGlobalFunction( "IO_AddToPickled" );
DeclareGlobalFunction( "IO_IsAlreadyPickled" );
DeclareGlobalFunction( "IO_FinalizePickled" );
DeclareGlobalFunction( "IO_AddToUnpickled" );
DeclareGlobalFunction( "IO_FinalizeUnpickled" );

DeclareGlobalFunction( "IO_WriteSmallInt" );
DeclareGlobalFunction( "IO_ReadSmallInt" );
DeclareGlobalFunction( "IO_WriteAttribute" );
DeclareGlobalFunction( "IO_ReadAttribute" );
DeclareGlobalFunction( "IO_PickleByString" );
DeclareGlobalFunction( "IO_UnpickleByEvalString" );
DeclareGlobalFunction( "IO_GenericObjectPickler" );
DeclareGlobalFunction( "IO_GenericObjectUnpickler" );

DeclareOperation( "IO_Pickle", [ IsFile, IsObject  ] );
DeclareOperation( "IO_Unpickle", [ IsFile ] );
DeclareOperation( "IO_Pickle", [ IsObject ]);
DeclareOperation( "IO_Unpickle", [ IsStringRep ]);
BindGlobal ("IO_Unpicklers", rec() );

# Here is an overview over the defined tags in this package:
#
# CHAR  a character
# CYCL  a cyclotomic
# FAIL  fail
# FALS  false
# FFEL  a finite field element
# FUNC  a GAP function, if it is a global one, only its name is pickled
# GAPL  a gap in a list (unbound entries)
# GSLP  a GAP straight line program
# IF2M  an immutable compressed GF2 matrix
# IF2V  an immutable compressed GF2 vector
# IF8M  an immutable compressed 8Bit matrix
# IF8V  an immutable compressed 8Bit vector
# ILIS  an immutable list
# INTG  an integer
# IREC  an immutable record
# ISTR  an immutable string
# MF2M  a mutable compressed GF2 matrix
# MF2V  a mutable compressed GF2 vector
# MF8M  a mutable compressed 8Bit matrix
# MF8V  a mutable compressed 8Bit vector
# MLIS  a mutable list
# MREC  a mutable record
# MSTR  a mutable string
# OPER  a GAP operation, only its name is pickled
# PERM  a permutation
# POLF  an object in the representation IsPolynomialDefaultRep
# POLY  a Laurent polynomial (or a rational function) deprecated
# RATF  an object in the representation IsRationalFunctionDefaultRep
# RSGL  the global random source
# RSGA  a GAP random source
# RSMT  a Mersenne twister random source
# RSRE  a really random source
# SPRF  SuPeRfail
# SREF  a self-reference
# TRUE  true
# UPOL  an object in the representation IsLaurentPolynomialDefaultRep
# URFU  an object in the representation IsUnivariateRationalFunctionDefaultRep
#
# Some tags defined in other packages:
#
# ICVC  an immutable cvec
# MCVC  a mutable cvec
# ICMA  an immutable cmat
# MCMA  a mutable cmat
# CMOD  a module from the CHOP package
# GWDG  a GAP word generator from the CHOP package
#

##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
