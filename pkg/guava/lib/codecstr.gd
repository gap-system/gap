#############################################################################
##
#A  codecstr.gd             GUAVA library                       Reinald Baart
#A                                                         Jasper Cramwinckel
#A                                                            Erik Roijackers
#A                                                                Eric Minkes
#A                                                               David Joyner
##
##  This file contains functions for constructing codes
##
#H  @(#)$Id: codecstr.gd,v 1.4 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/codecstr_gd") :=
    "@(#)$Id: codecstr.gd,v 1.4 2004/12/20 21:26:06 gap Exp $";

########################################################################
##
#F  AmalgamatedDirectSumCode( <C>, <D>, [, <check> ] )
##
##  Return the amalgamated direct sum code of C en D.
##  
##  This construction is derived from the direct sum construction,
##  but it saves one coordinate over the direct sum.
##  
##  The amalgamated direct sum construction goes as follows:
##
##  Put the generator matrices G and H of C respectively D
##  in standard form as follows:
##     
##     G => [ G' | I ]     and    H => [ I | H' ]
##
##  The generator matrix of the new code then has the following form:
##     
##      [          1 0 ... 0   0 | 0 0 ............ 0 ]
##      [          0 1 ... 0   0 | 0 0 ............ 0 ] 
##      [          .........   . | .................. ] 
##      [   G'     0 0 ... 1   0 | 0 0 ............ 0 ]
##      [                    |---------------|--------]
##      [          0 0 ... 0 | 1 | 0 ... 0 0          ]
##      [--------|-----------|---|                    ]
##      [ 0 0 ............ 0 | 0   1 ... 0 0    H'    ]
##      [ .................. | 0   .........          ]
##      [ 0 0 ............ 0 | 0   0 ... 1 0          ]
##      [ 0 0 ............ 0 | 0   0 ... 0 1          ]
##
##  The codes resulting from [ G' | I ] and [ I | H' ] must
##  be acceptable in the last resp. the first coordinate.
##  Checking whether this is true takes a lot of time, however,
##  and is only performed when the boolean variable check is true.
##
DeclareOperation("AmalgamatedDirectSumCode", 
							[IsCode, IsCode, IsBool]);  

########################################################################
##
#F  BlockwiseDirectSumCode( <C1>, <L1>, <C2>, <L2> )
##
##  Return the blockwise direct sum of C1 and C2 with respect to 
##  the cosets defined by the codewords in L1 and L2.
##
DeclareOperation("BlockwiseDirectSumCode", 
							[IsCode, IsList, IsCode, IsList]); 

########################################################################
##
#F  ExtendedDirectSumCode( <L>, <B>, m )
##
##  The construction as described in the article of Graham and Sloane,
##  section V.
##  ("On the Covering Radius of Codes", R.L. Graham and N.J.A. Sloane,
##    IEEE Information Theory, 1985 pp 385-401)
##
DeclareOperation("ExtendedDirectSumCode", 
							[IsCode, IsCode, IsInt]); 

########################################################################
##
#F  PiecewiseConstantCode( <partition>, <constraints> [, <field> ] )
##
DeclareGlobalFunction("PiecewiseConstantCode"); 

########################################################################
##
#F  GabidulinCode( );
##
DeclareOperation("GabidulinCode", [IsInt, IsFFE, IsFFE, IsBool]); 
    
########################################################################
##
#F  EnlargedGabidulinCode( );
##
DeclareOperation("EnlargedGabidulinCode", 
							[IsInt, IsFFE, IsFFE, IsFFE]);    	

########################################################################
##
#F  DavydovCode( );
##
DeclareOperation("DavydovCode", [IsInt, IsInt, IsFFE, IsFFE]); 

########################################################################
##
#F  TombakCode( );
##
DeclareGlobalFunction("TombakCode");  
    
########################################################################
##
#F  EnlargedTombakCode( );
##
DeclareGlobalFunction("EnlargedTombakCode"); 


