#############################################################################
##
#W  ctblchar.gd                 GAP library                     Thomas Breuer
#W                                                              & Ansgar Kaup
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains those functions which mainly deal with characters.
##
Revision.ctblchar_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  DecompositionMatrix( <modtbl> )
#F  DecompositionMatrix( <modtbl>, <blocknr> )
#A  DecompositionMatrixAttr( <modtbl> )
##
##  Let <modtbl> be a Brauer character table.
##
##  In the first version `DecompositionMatrix' returns the decomposition
##  matrix of <modtbl>, where the rows are indexed by the irreducible
##  characters of the ordinary character table,
##  and the columns are indexed by `IBr( <modtbl> )'.
##
##  In the second version `DecompositionMatrix' returns the decomposition
##  matrix of the block of <modtbl> with number <blocknr>.
##
##  An ordinary irreducible character is in block $i$ if and only if all
##  characters before the first character of the same block lie in $i-1$
##  different blocks.
##  An irreducible Brauer character is in block $i$ if it has nonzero scalar
##  product with an ordinary irreducible character in block $i$.
##
#T problem:
#T There was a documented command `DecompositionMatrix' in the
#T `specht' package of GAP 3!
##
DeclareGlobalFunction( "DecompositionMatrix" );

DeclareAttribute( "DecompositionMatrixAttr",
    IsBrauerTable );


#############################################################################
##
#F  LaTeXStringDecompositionMatrix( <modtbl> )
#F  LaTeXStringDecompositionMatrix( <modtbl>, <blocknr> )
##
##  is a string that contains {\LaTeX} code to print a decomposition matrix
##  (see "DecompositionMatrix") nicely.
##
DeclareGlobalFunction(
    "LaTeXStringDecompositionMatrix" );


###############################################################################
##
#F  FrobeniusCharacterValue( <value>, <p> )
##
##  is the value of the Frobenius character corresponding to the Brauer
##  character value <value>, where <p> is the characteristic of the field.
##
##  Let $n$ be the conductor of $v$.
##  Let $k$ be the order of $p$ modulo $n$, that is, $GF( p^k )$ is the
##  smallest field of characteristic $p$ containing $n$-th roots of unity.
##  Let $m$ be minimal with $v^{\ast p^m} = v$, that is, $GF( p^m )$ is the
##  smallest field containing the Frobenius character value $\overline{v}$.
##
##  Let $C_k$ and $C_m$ be the Conway polynomials of degrees $k$ and $m$,
##  and $z = X + (C_k)$ in $GF( p^k ) = GF(p)[X] / (C_k)$.
##  Then $\hat{y} = z^{\frac{p^k-1}{p^m-1}}$ may be identified with
##  $y = X + (C_m)$ in $GF( p^m ) = GF(p)[X] / (C_m)$.
##
##  For $v = \sum_{i=1}^n a_i E(n)^i$ a representation of $\overline{v}$ in
##  $GF( p^k )$ is $\sum_{i=1}^n \overline{a_i} z^{\frac{p^k-1}{n} i}$ where
##  $\overline{a_i}$ is the reduction of $a_i$ modulo $p$, viewed as
##  element of $GF(p)$.
##
##  A representation of $\overline{v}$ in $GF( p^m )$ can be found by
##  solving the linear equation system
##  $\overline{v} = \sum_{i=0}^{m-1} c_i \hat{y}^i$ over $GF(p)$, which
##  gives us $\overline{v} = \sum{i=0}^{m-1} c_i y^i$ in $GF( p^m )$.
##
DeclareGlobalFunction( "FrobeniusCharacterValue" );


#############################################################################
##
#O  Tensored( <chars1>, <chars2> )
##
##  Let <chars1> and <chars2> be lists of class functions of the same
##  character table.
##  `Tensored' returns the list of tensor products of all in <chars1> with
##  all in <chars2>.
##
DeclareOperation( "Tensored",
    [ IsClassFunctionCollection, IsClassFunctionCollection ] );


#############################################################################
##
#F  Symmetrisations( <tbl>, <characters>, <Sn> )
#F  Symmetrisations( <tbl>, <characters>, <n> )
##
DeclareGlobalFunction( "Symmetrisations" );

Symmetrizations := Symmetrisations;


#############################################################################
##
#F  SymmetricParts( <tbl>, <character>, <n> )
##
DeclareGlobalFunction( "SymmetricParts" );


#############################################################################
##
#F  AntiSymmetricParts( <tbl>, <character>, <n> )
##
DeclareGlobalFunction( "AntiSymmetricParts" );


#############################################################################
##
#F  MinusCharacter( <character>, <prime_powermap>, <prime> )
##
##  is the (parametrized) character values list of $<character>^{<prime>-}$,
##  which is defined by
##  $\chi^{p-}(g):= ( \chi(g)^p - \chi(g^p) ) / p$.
##
DeclareGlobalFunction( "MinusCharacter" );


#############################################################################
##
#F  RefinedSymmetrisations( <tbl>, <chars>, <m>, <func> )
##
##  is the list of Murnaghan components for orthogonal
##  ('<func>(x,y)=x', see "OrthogonalComponents")
##  or symplectic ('<func>(x,y)=x-y', see "SymplecticComponents")
##  symmetrisations.
##
##  <m> must be an integer in `[ 1 .. 6 ]' in the orthogonal case,
##  and in `[ 1 .. 5 ]' for the symplectic case.
##
##  (Note:  It suffices to change `F2' and `F4' in order to get the
##  symplectic components from the orthogonal ones.)
##
##  We have (see J.S. Frame, Recursive computation of tensor power
##  components, Bayreuther Mathematische Schriften 10, 153--159)
##
##  component   orthogonal                symplectic
##  M0        = L0                        L0  ( = 1 )
##  M1        = L1                        L1
##  M11       = L11                       L11-L0
##  M2        = L2-L0                     L2
##  M111      = L111                      L111-L1
##  M21       = L21-L1                    L21-L1
##  M3        = L3-L1                     L3
##  M1111     = L1111                     L1111-L11
##  M211      = L211-L11                  L211-L11-L2+L0
##  M22       = L22-L2                    L22-L11
##  M31       = L31-L2-L11+L0             L31-L2
##  M4        = L4-L2                     L4
##  M11111    = L11111                    L11111-L111
##  M2111     = L2111-L111                L2111-L111-L21+L1
##  M221      = L221-L21                  L221-L111-L21+L1
##  M311      = L311-L21-L111+L1          L311-L21-L3+L1
##  M32       = L32-L3-L21+L1             L32-L21
##  M41       = L41-L3-L21+L1             L41-L3
##  M5        = L5-L3                     L5
##  M111111   = L111111                   L111111-L1111
##  M21111    = L21111-L1111              L21111-L1111-L211+L11
##  M2211     = L2211-L211                L2211-L1111-L211-L22+L11+L2
##  M3111     = L3111-L211-L1111+L11      L3111-L211-L31+L11+L2-L0
##  M222      = L222-L22                  L222-L211+L11-L0
##  M321      = L321-L31-L22-L211+L2+L11  L321-L31-L22-L211+L2+L11
##  M33       = L33-L31+L2-L0             L33-L22
##  M411      = L411-L31-L211+L2+L11-L0   L411-L31-L4+L2
##  M42       = L42-L4-L31-L22+L2+L11     L42-L31
##  M51       = L51-L4-L31+L2             L51-L4
##  M6        = L6-L4                     L6
##
DeclareGlobalFunction( "RefinedSymmetrisations" );


#############################################################################
##
#F  OrthogonalComponents( <tbl>, <chars>, <m> )
##
##  If $\chi$ is an irreducible character with indicator $+1$, a splitting
##  of the tensor power $\chi^m$ is given by the so-called Murnaghan
##  functions (see F. D. Murnaghan, The Orthogonal and Symplectic Groups,
##  Comm. Dublin Inst. Adv. Studies, Series A No. 13 (1958)).
##  These components in general have fewer irreducible constituents
##  than the symmetrizations with the symmetric group of degree <m>
##  (see "Symmetrizations").
##
##  `OrthogonalComponents' returns the Murnaghan components of the
##  characters <chars> of the character table <tbl> up to the power <m>,
##  where <m> is an integer between 2 and 6.
##
##  The Murnaghan functions are implemented as in J. S. Frame,
##  Recursive computation of tensor power components, Bayreuther
##  Mathematische Schriften 10, 153--159, see "RefinedSymmetrisations".
##
DeclareGlobalFunction( "OrthogonalComponents" );


#############################################################################
##
#F  SymplecticComponents( <tbl>, <chars>, <m> )
##
##  If $\chi$ is an irreducible character with indicator $-1$, there is a
##  splitting of the tensor power $\chi^m$ similar to the so-called Murnaghan
##  functions (see F. D. Murnaghan, The Orthogonal and Symplectic Groups,
##  Comm. Dublin Inst. Adv. Studies, Series A No. 13 (1958)).
##  These components in general have fewer irreducible constituents
##  than the symmetrizations with the symmetric group of degree <m>
##  (see "Symmetrizations").
##
##  `SymplecticComponents' returns the symplectic symmetrisations of the
##  characters <chars> of the character table <tbl> up to the power <m>,
##  where <m> is an integer between 2 and 5.
##
DeclareGlobalFunction( "SymplecticComponents" );


#############################################################################
##
#F  PrimeBlocks( <ordtbl>, <prime> )
##
##  For an ordinary character table <ordtbl> and a prime <prime>,
##  `PrimeBlocks' returns a record with components `block' and `defect',
##  both lists, where `block[i] = j' means that the `i'--th character
##  lies in the `j'--th <prime>-block of <ordtbl>,
##  and `defect[j]' is the defect of this block.
##
##  Two ordinary irreducible characters $\chi, \psi$ of a group $G$ are said
##  to lie in the same $p$-block if the images of their central characters
##  $\omega_{\chi}, \omega_{\psi}$ under the homomorphism
##  $\ast \colon R \rightarrow R / M$ are equal.
##  The central character is the class function defined by
##  $\omega_{\chi}(g) = \chi(g) \|Cl_G(g)\| / \chi(1)$.
##  $R$ denotes the ring of algebraic integers in the complex numbers, $M$ is
##  a maximal ideal in $R$ with $pR \subseteq M$.
##  Thus $F = R/M$ is a field of characteristics $p$.
##
##  $\chi$ and $\psi$ lie in the same $p$-block if and only if there is an
##  integer $n$ such that $(\omega_{chi}(g) - \omega_{\psi}(g))^n \in pR$
##  (see~\cite{Isaacs}, p. 271).
##
##  Following the proof in~\cite{Isaacs}, a sufficient value for $n$ is
##  $\varphi(\|g\|)$.
##  The test must be performed only for one class of each Galois family.
##
##  It is sufficient to test $p$-regular classes. (see Feit, p. 150)
##
##  Any character $\chi$ where $p$ does not divide $\|G\| / \chi(1)$
##  (such a character is called defect-zero-character) forms a block of its
##  own.
##
##  If `InfoCharacterTable' has level at least 2,
##  the defect of the blocks and the height of the characters are printed.
##
##  For $\|G\| = p^a m$ where $p$ does not divide $m$, the defect of a block
##  is that $d$ where $p^{a-d}$ is the largest power of $p$ that divides all
##  degrees of the characters in the block.
##
##  The height of a $\chi$ is then the largest exponent $h$ where $p^h$
##  divides $\chi(1) / p^{a-d}$.
##
DeclareGlobalFunction( "PrimeBlocks" );


#############################################################################
##
#F  IrreducibleDifferences( <tbl>, <reducibles>, <reducibles2> )
#F  IrreducibleDifferences( <tbl>, <reducibles>, <reducibles2>, <scprmat> )
#F  IrreducibleDifferences( <tbl>, <reducibles>, \"triangle\" )
#F  IrreducibleDifferences( <tbl>, <reducibles>, \"triangle\", <scprmat> )
##
##  `IrreducibleDifferences' returns the list of irreducible characters which
##  occur as difference of two elements of <reducibles>
##  (if \"triangle\" is specified)
##  or of an element of <reducibles> and an element of <reducibles2>.
##
##  If <scprmat> is not specified it will be calculated,
##  otherwise we must have
##  $'<scprmat>[i][j]=ScalarProduct(<tbl>,<reducibles>[j],<reducibles>[i])'$
##  resp.
##  $'<scprmat>[i][j]=ScalarProduct(<tbl>,<reducibles>[j],<reducibles2>[i])'$.
##
DeclareGlobalFunction( "IrreducibleDifferences" );


#############################################################################
##
#E  ctblchar.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



