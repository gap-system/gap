#############################################################################
##  
#W  laguna.gd                The LAGUNA package                  Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##
#H  @(#)$Id: mip.gd,v 1.1 2005/05/28 13:13:03 alexk Exp $
##
#############################################################################


#############################################################################
##
## ATTRIBUTES OF P-GROUPS AND THEIR MODULAR GROUP ALGBERAS
## RELATED WITH THE MODULAR ISOMORPHISM PROBLEM
##
#############################################################################

#############################################################################
##
#A  JenningsFactors( <G> )
##  
##  Let M[n](G) denote the n-th term of the Brauer-Jennings-Zassenhaus series
##  (in what follows - jennings series, see [S.A.Jennings, The structure of
##  the group ring of a p-group over a modular field, Trans.Amer.Math.Soc.,
##  50 (1941), 175-185 ]): M[n](G) = G \cap ( 1 + I^n ), where I is the 
##  augmentation ideal of the group algebra KG. Then the length of this 
##  series and isomorphism types of factors M[i]/M[i+1], M[i]/M[i+2] and
##  M[i]/M[2i+1] are determined by the group algebra KG [I.B.S.Passi, 
##  S.K.Sehgal, Isomorphism of modular group algebras, Math.Z., 129 (1972),
##  65-73; J.Ritter, S.K.Sehgal, Isomorphism of group rings, Arch.Math.
##  (Basel), 40 (1983), 32-39].
##  The method calculates this factors and returns a list containing three
##  lists of catalogue numbers of appropriate factors.
DeclareAttribute("JenningsFactors", IsPGroup);

#############################################################################
##
#A  SandlingFactorGroup( <G> )
##  
##  Let gamma[1]=G, ..., gamma[n] be the lower central series of the group G.
##  Then the isomorphism type of the factorgroup G / (gamma[2]^p * gamma[3])
##  is determined by the group algebra KG [R.Sandling, The modular group
##  algebra of a central elementary-by-abelian p-group, Arch.Math. (Basel),
##  52 (1989), 22-27]. This factorgroup is returned by this function.
DeclareAttribute("SandlingFactorGroup", IsPGroup);

#############################################################################
##
#A  QuillenSeries( <G> )
##  
##  Let G be a p-group of order p^n. It was proved in [D.Quillen, The 
##  spectrum of an equivariant cohomology ring II, Ann. of Math., (2) 94 
##  (1984), 573-602] that the number of conjugacy classes of maximal 
##  elementary abelian subgroups of given rank is determined by the group 
##  algebra KG. 
##  The function calculates this numbers for each possible rank and returns 
##  a list of the length n, where i-th element corresponds to the number of
##  conjugacy classes of maximal elementary abelian subgroups of the rank i.
DeclareAttribute("QuillenSeries", IsPGroup);

#############################################################################
##
#A  ClassSumNumbers( <G> )
##  
##  Let l[i] be the number of class sums S such that there exists class sum L
##  such that L^(p^i)=S. Equivalently, l[i] is the number of conjugacy 
##  classes S for which the following condition holds: if x in S, then there 
##  exists y in G such that y^(p^i)=x, but p^i-th powers of all of its 
##  conjugates are not equal to x. It was proved in [M.M.Parmenter, C.Polcino
##  Milies, A note on isomorphic group rings, Bol.Soc.Bras.Mat., 12 (1981), 
##  57-56] that the numbers l[i] are determined by the group algebra KG.
##  The function calculates the list of l[i]. The calculation is finished
##  when we reach i such that all p^i-th powers of class sums are trivial.
DeclareAttribute("ClassSumNumbers", IsPGroup);

#############################################################################
##
#A  NumberOfConjugacyClassesPPowers( <G> )
##  
##  The number of conjugacy classes of p^i-th powers of elements of the group
##  G is determined by the group algebra KG [M.Wursthorn, Die modularen
##  Gruppenringe der gruppen der Ordnung 2^6, Diplomarbeit, Universitat 
##  Stuttgart, 1990; M.Wursthorn, Isomorphisms of modular group algebras: an
##  algorithm and its application to groups of order 2^6, J.Symbolic Comput.
##  15 (1993), no.2, 211-227].
##  For a p-group G of exponent p^t, the function returns a list of the 
##  length t, i-th entry of which is the number of conjugacy classes of
##  p^i-th powers of elements of the group G.
DeclareAttribute("NumberOfConjugacyClassesPPowers",IsPGroup);


#############################################################################
##
#A  RoggenkampParameter( <G> )
##  
##  Let T = { g_1, ..., g_t} be the full system of representatives of 
##  conjugacy classes of the group G. Then the number
##     \sum_{i=1,...,t} log_p ( | C_G( g_i ) / \Phi( C_G( g_i ) ) |) 
##  is determined by the group algebra KG. This parameter was introduced
##  by K.Roggenkamp and was described in [M.Wursthorn, Die modularen
##  Gruppenringe der gruppen der Ordnung 2^6, Diplomarbeit, Universitat 
##  Stuttgart, 1990; M.Wursthorn, Isomorphisms of modular group algebras: an
##  algorithm and its application to groups of order 2^6, J.Symbolic Comput.
##  15 (1993), no.2, 211-227]. 
DeclareAttribute("RoggenkampParameter",IsPGroup);


#############################################################################
##
#A  KernelSize( < KG , [ n, m, k] > )
##  
##  Returns the size of the kernel of the following mapping, depending on
##  three parameters [ n, m, k]: Phi_nmk from I^n/I^n+m to I^(np^k)/I^(np^k+m),
##  which is induced by turning an element x from I^n to ist p^k-th power
##  and maps  x + I^n+m  to  x^(p^k) + I^(np^k+m). The kernel size of such
##  mapping is an invariant of KG [see M.Wursthorn, Die modularen 
##  Gruppenringe der gruppen der Ordnung 2^6, Diplomarbeit, Universitat 
##  Stuttgart, 1990; M.Wursthorn, Isomorphisms of modular group algebras: an
##  algorithm and its application to groups of order 2^6, J.Symbolic Comput.
##  15 (1993), no.2, 211-227]. 
KeyDependentOperation( "KernelSize", 
                       IsPModularGroupAlgebra, 
                       IsList, 
                       ReturnTrue );


#############################################################################
##
#E
##