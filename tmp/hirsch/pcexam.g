#############################################################################
##
#W  pcexam.g                 GAP Experimental                         BE & WN
##
#H  @(#)$Id: pcexam.g,v 1.5 1999/02/26 13:57:49 werner Exp $
##
##  This file contains examples of polycyclic groups.
##
Revision.pcexam_g :=
    "@(#)$Id: pcexam.g,v 1.5 1999/02/26 13:57:49 werner Exp $";


#############################################################################
##
##  Each group in this file should be appended to the following list.
##  This makes looping over all examples for test purposes easy.
##
AllPcpExamples := [];


#############################################################################
##
##                                             [ 0 1 ]   [ -1  0 ] 
##  The semidirect product of the matrices     [ 1 1 ],  [  0 -1 ]
##
##  and Z^2.  We let the generator corresponding to the second matrix
##  have infinite order. 
##
FTL := PcpGroupSplitByMatrices( [ [[0,1],[1,1]], [[-1,0],[0,-1]] ] );

Add( AllPcpExamples, FTL );


#############################################################################
##
##  The following matrices are a basis of the fundamental units of the
##  order defined by the polynomials x^4 - x - 1
##
FTL := PcpGroupSplitByMatrices( 
[ [ [ 0,1,0,0 ],  [ 0,0,1,0 ],  [ 0,0,0,1 ],  [ 1,1,0,0 ] ],
  [ [ 1,1,0,-1 ], [ -1,0,1,0 ], [ 0,-1,0,1 ], [ 1,1,-1,0 ] ] ] );

Add( AllPcpExamples, FTL );

#############################################################################
##
##  The infinite dihedral group.
##
FTL := FromTheLeftCollector( 2 );

SetRelativeOrder( FTL, 1, 2 );
SetConjugate( FTL, 2,  1, [2,-1] );
#SetConjugate( FTL, 2, -1, [2,-1] );
UpdatePolycyclicCollector( FTL );

Add( AllPcpExamples, PcpGroupByCollector(FTL) );

#############################################################################
##
##  A preimage of the infinite dihedral group: Here the involution has
##  become an element of order.
##
FTL := FromTheLeftCollector( 2 );

SetConjugate( FTL, 2,  1, [2,-1] );
#SetConjugate( FTL, 2, -1, [2,-1] );
UpdatePolycyclicCollector( FTL );

Add( AllPcpExamples, PcpGroupByCollector(FTL) );

#############################################################################
##
##  A gr oup of Hirsch length 3.  Interesting because the exponents in
##  words can become large very quickly.
##
FTL := FromTheLeftCollector( 3 );

SetConjugate( FTL, 2, 1, [3, 1] );
SetConjugate( FTL, 3, 1, [2, 1, 3, 7] );

#SetConjugate( FTL, 2,-1, [2,-7, 3, 1] );
#SetConjugate( FTL, 3,-1, [2, 1] );

UpdatePolycyclicCollector( FTL );

Add( AllPcpExamples, PcpGroupByCollector(FTL) );










#############################################################################
##
##  At last, clean the variable FTL.
##
Unbind( FTL );
