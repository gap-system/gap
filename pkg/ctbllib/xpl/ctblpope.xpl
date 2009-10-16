%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%W  ctblpope.xpl              GAP applications              Thomas Breuer
%%
%H  @(#)$Id: ctblpope.xpl,v 1.22 2009/10/05 15:09:01 gap Exp $
%%
%Y  Copyright 1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,   Germany
%%
%X  NAME="ctblpope"
%X  rm -rf doc/$NAME.tex
%X  etc/xpl2tst xpl/$NAME.xpl tst/$NAME.tst
%X  etc/xpl2latex xpl/$NAME.xpl doc/$NAME.tex
%X  cd doc
%X  chmod 444 $NAME.tex
%X  latex $NAME; bibtex $NAME; latex $NAME; latex $NAME
%X  pdflatex $NAME
%X  sed -e 's/accent127 /"/g;s/accent127/"/g;s/\\~{}/~/g' < $NAME.bbl > tmp
%X  mv tmp $NAME.bbl
%X  ../etc/exportpictures $NAME.tex
%X  tth -e2 -u -L$NAME < $NAME.tex > ../htm/$NAME.htm
%%
\documentclass[a4paper]{article}

\usepackage{theorem}
\usepackage{epic}
\newtheorem{lem}{Lemma}[section]

\textwidth16cm
\oddsidemargin0pt

\parskip 1ex plus 0.5ex minus 0.5ex
\parindent0pt

\usepackage{amssymb}

% Miscellaneous macros.
\def\GAP{\textsf{GAP}}
\def\ATLAS{\textsc{Atlas}}
\def\Irr{{\rm Irr}}
%%tth: \font\mathbb=msbm10
\def\N{{\mathbb B}} \def\Z{{\mathbb Z}} \def\Q{{\mathbb Q}}
\def\R{{\mathbb R}} \def\C{{\mathbb C}} \def\F{{\mathbb F}}
\def\tthdump#1{#1}
\tthdump{\def\URL#1#2{\texttt{#1}}}
%%tth: \def\URL#1#2{\url{#2}}
%%tth: \def\abstract#1{#1}
%%tth: \def\colon{:}
%%tth: \def\thinspace{ }
%%tth: \def\textendash{--}
%%tth: \def\discretionary{}

\begin{document}

\tthdump{\title{Permutation Characters in {\GAP}}}
%%tth: \title{Permutation Characters in GAP}
%%tth: \begin{html} <body bgcolor="FFFFFF"> \end{html}

\author{\textsc{Thomas Breuer} \\[0.5cm]
\textit{Lehrstuhl D f{\"u}r Mathematik} \\
\textit{RWTH, 52056 Aachen, Germany}}

\date{April 17th, 1999}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\maketitle


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\abstract{This is a loose collection of examples of computations with
permutation characters and possible permutation characters in
the {\GAP} system~\cite{GAP4}.
We mainly use the {\GAP} implementation of the algorithms to compute
possible permutation characters that are described in~\cite{BP98copy},
and information from the Atlas of Finite Groups~\cite{CCN85}.
 
A *possible permutation character* of a finite group $G$ is a character
satisfying the conditions listed in Section
``Possible Permutation Characters'' of the
\tthdump{{\GAP} Reference Manual.}
%%tth: \href{link}{{\GAP} Reference Manual}.

(Sections~\ref{U35sub} and~\ref{O82sub} were added in October~2001,
Section~\ref{monsterperm1} was added in June~2009, and
Section~\ref{monsterperm2} was added in September~2009.)
}

% using `\abstract' seems to reset `\parskip' and `parindent' ...
\textwidth16cm
\oddsidemargin0pt

\parskip 1ex plus 0.5ex minus 0.5ex
\parindent0pt


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\tableofcontents

%T missing:
%T more examples for the combin. and ineq. algorithm,
%T the use of tables of marks,
%T and the examples in ~/Saxl/M12.2, ~/Saxl/Suz !!
%T show an example where the modular criteria are guaranteed by starting
%T from the matrix of projective indecomposables!

% gap> START_TEST("$Id: ctblpope.xpl,v 1.22 2009/10/05 15:09:01 gap Exp $");


In the following, the {\GAP} Character Table Library~\cite{CTblLib1.1.3}
will be used frequently.

\beginexample
gap> LoadPackage( "ctbllib", "1.1.2" );
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Some Computations with $M_{24}$}
 
We start with the sporadic simple Mathieu group $G = M_{24}$
in its natural action on $24$ points.

\beginexample
gap> g:= MathieuGroup( 24 );;
gap> SetName( g, "m24" );
gap> Size( g );  IsSimple( g );  NrMovedPoints( g );
244823040
true
24
\endexample

The permutation character `pi' of $G$ corresponding to the action on
the moved points is constructed.
This action is $5$-transitive.

\beginexample
gap> NrConjugacyClasses( g );
26
gap> pi:= NaturalCharacter( g );
Character( CharacterTable( m24 ), [ 24, 2, 1, 1, 4, 6, 0, 0, 3, 3, 0, 1, 1,
  8, 0, 2, 0, 0, 4, 2, 0, 0, 0, 1, 1, 0 ] )
gap> IsTransitive( pi );  Transitivity( pi );
true
5
gap> Display( pi );
CT1

     2 10   .   .   .  2  3   .   .  1  1  3   1   1 10   2  3  7  9  7  4   2
     3  3   .   1   1  1  3   1   1  1  1  2   .   .  1   1  1  1  1  .  .   1
     5  1   .   1   1  1  1   .   .  .  .  .   .   .  .   .  .  .  1  .  .   .
     7  1   .   .   .  .  .   1   1  1  1  1   1   1  1   .  .  .  .  .  .   .
    11  1   1   .   .  .  .   .   .  .  .  .   .   .  .   .  .  .  .  .  .   .
    23  1   .   .   .  .  .   .   .  .  .  .   .   .  .   .  .  .  .  .  .   .

       1a 11a 15a 15b 5a 3a 21a 21b 7a 7b 3b 14a 14b 2a 12a 6a 4a 2b 4b 8a 12b

Y.1    24   2   1   1  4  6   .   .  3  3  .   1   1  8   .  2  .  .  4  2   .

     2  3  5   .   .   2
     3  1  1   .   .   .
     5  .  .   .   .   1
     7  .  .   .   .   .
    11  .  .   .   .   .
    23  .  .   1   1   .

       6b 4c 23a 23b 10a

Y.1     .  .   1   1   .
\endexample

`pi' determines the permutation characters of the $G$-actions on
related sets,
for example `piop' on the set of ordered and `piup' on the set of
unordered pairs of points.

\beginexample
gap> piop:= pi * pi;
Character( CharacterTable( m24 ), [ 576, 4, 1, 1, 16, 36, 0, 0, 9, 9, 0, 1,
  1, 64, 0, 4, 0, 0, 16, 4, 0, 0, 0, 1, 1, 0 ] )
gap> IsTransitive( piop );
false
gap> piup:= SymmetricParts( UnderlyingCharacterTable(pi), [ pi ], 2 )[1];
Character( CharacterTable( m24 ), [ 300, 3, 1, 1, 10, 21, 0, 0, 6, 6, 0, 2,
  2, 44, 1, 5, 4, 12, 12, 4, 0, 0, 0, 1, 1, 2 ] )
gap> IsTransitive( piup );
false
\endexample

Clearly the action on unordered pairs is not transitive, since the pairs
$[ i, i ]$ form an orbit of their own.
There are exactly two $G$-orbits on the unordered pairs,
hence the $G$-action on $2$-sets of points is transitive.

\beginexample
gap> ScalarProduct( piup, TrivialCharacter( g ) );
2
gap> comb:= Combinations( [ 1 .. 24 ], 2 );;
gap> hom:= ActionHomomorphism( g, comb, OnSets );;
gap> pihom:= NaturalCharacter( hom );
Character( CharacterTable( m24 ), [ 276, 1, 0, 0, 6, 15, 0, 0, 3, 3, 0, 1, 1,
  36, 1, 3, 4, 12, 8, 2, 0, 0, 0, 0, 0, 2 ] )
gap> Transitivity( pihom );
1
\endexample

In terms of characters, the permutation character `pihom' is the difference
of `piup' and `pi' .
Note that {\GAP} does not know that this difference is in fact a character;
in general this question is not easy to decide without knowing the
irreducible characters of $G$,
and up to now {\GAP} has not computed the irreducibles.

\beginexample
gap> pi2s:= piup - pi;
VirtualCharacter( CharacterTable( m24 ), [ 276, 1, 0, 0, 6, 15, 0, 0, 3, 3,
  0, 1, 1, 36, 1, 3, 4, 12, 8, 2, 0, 0, 0, 0, 0, 2 ] )
gap> pi2s = pihom;
true
gap> HasIrr( g );  HasIrr( CharacterTable( g ) );
false
false
\endexample

The point stabilizer in the action on $2$-sets is in fact a maximal
subgroup of $G$, which is isomorphic to the automorphism group
$M_{22}:2$ of the Mathieu group $M_{22}$.
Thus this permutation action is primitive.
But we cannot apply `IsPrimitive' to the character `pihom' for getting
this answer because primitivity of characters is defined in a different
way, cf.~`IsPrimitiveCharacter' in the {\GAP} Reference Manual.

\beginexample
gap> IsPrimitive( g, comb, OnSets );
true
\endexample

%T It should be noted that for $k > 2$,
%T the $k$-th symmetrisation of a permutation character
%T does in general not decompose into permutation characters
%T corresponding to the action on $l$-sets, for $l \leq k$.
 
We could also have computed the transitive permutation character of
degree $276$ using the {\GAP} Character Table Library instead of
the group $G$,
since the character tables of $G$ and all its maximal subgroups are
available, together with the class fusions of the maximal subgroups
into $G$.

\beginexample
gap> tbl:= CharacterTable( "M24" );
CharacterTable( "M24" )
gap> maxes:= Maxes( tbl );
[ "M23", "M22.2", "2^4:a8", "M12.2", "2^6:3.s6", "L3(4).3.2_2",
  "2^6:(psl(3,2)xs3)", "L2(23)", "L3(2)" ]
gap> s:= CharacterTable( maxes[2] );
CharacterTable( "M22.2" )
gap> TrivialCharacter( s )^tbl;
Character( CharacterTable( "M24" ), [ 276, 36, 12, 15, 0, 4, 8, 0, 6, 3, 0,
  3, 3, 2, 2, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0 ] )
\endexample

Note that the sequence of conjugacy classes in the library table of
$G$ does in general not agree with the succession computed for the
group.
%T mention class identification program?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{All Possible Permutation Characters of $M_{11}$}
 
We compute all possible permutation characters of the Mathieu group
$M_{11}$, using the three different strategies available in {\GAP}.
 
First we try the algorithm that enumerates all candidates via solving
a system of inequalities, which is described in~\cite[Section~3.2]{BP98copy}.

\beginexample
gap> m11:= CharacterTable( "M11" );;
gap> SetName( m11, "m11" );
gap> perms:= PermChars( m11 );
[ Character( m11, [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] ),
  Character( m11, [ 11, 3, 2, 3, 1, 0, 1, 1, 0, 0 ] ),
  Character( m11, [ 12, 4, 3, 0, 2, 1, 0, 0, 1, 1 ] ),
  Character( m11, [ 22, 6, 4, 2, 2, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 55, 7, 1, 3, 0, 1, 1, 1, 0, 0 ] ),
  Character( m11, [ 66, 10, 3, 2, 1, 1, 0, 0, 0, 0 ] ),
  Character( m11, [ 110, 6, 2, 2, 0, 0, 2, 2, 0, 0 ] ),
  Character( m11, [ 110, 6, 2, 6, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 110, 14, 2, 2, 0, 2, 0, 0, 0, 0 ] ),
  Character( m11, [ 132, 12, 6, 0, 2, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 144, 0, 0, 0, 4, 0, 0, 0, 1, 1 ] ),
  Character( m11, [ 165, 13, 3, 1, 0, 1, 1, 1, 0, 0 ] ),
  Character( m11, [ 220, 4, 4, 0, 0, 4, 0, 0, 0, 0 ] ),
  Character( m11, [ 220, 12, 4, 4, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 220, 20, 4, 0, 0, 2, 0, 0, 0, 0 ] ),
  Character( m11, [ 330, 2, 6, 2, 0, 2, 0, 0, 0, 0 ] ),
  Character( m11, [ 330, 18, 6, 2, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 396, 12, 0, 4, 1, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 440, 8, 8, 0, 0, 2, 0, 0, 0, 0 ] ),
  Character( m11, [ 440, 24, 8, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 495, 15, 0, 3, 0, 0, 1, 1, 0, 0 ] ),
  Character( m11, [ 660, 4, 3, 4, 0, 1, 0, 0, 0, 0 ] ),
  Character( m11, [ 660, 12, 3, 0, 0, 3, 0, 0, 0, 0 ] ),
  Character( m11, [ 660, 12, 12, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 660, 28, 3, 0, 0, 1, 0, 0, 0, 0 ] ),
  Character( m11, [ 720, 0, 0, 0, 0, 0, 0, 0, 5, 5 ] ),
  Character( m11, [ 792, 24, 0, 0, 2, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 880, 0, 16, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 990, 6, 0, 2, 0, 0, 2, 2, 0, 0 ] ),
  Character( m11, [ 990, 6, 0, 6, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 990, 30, 0, 2, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 1320, 8, 6, 0, 0, 2, 0, 0, 0, 0 ] ),
  Character( m11, [ 1320, 24, 6, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 1584, 0, 0, 0, 4, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 1980, 12, 0, 4, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 1980, 36, 0, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 2640, 0, 12, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 3960, 24, 0, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( m11, [ 7920, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
gap> Length( perms );
39
\endexample

%T This algorithm admits a second search strategy, which uses the inequalities
%T for a sort of previewing.
%T But this does not work correctly,
%T already the GAP 3 version did not do what was promised.
%T (Apparently, the additional options were used rarely.)
 
Next we try the improved combinatorial approach that is sketched at the
end of Section~3.2 in~\cite{BP98copy}.
We get the same characters, except that they may be ordered in a different
way; thus we compare the ordered lists.

\beginexample
gap> degrees:= DivisorsInt( Size( m11 ) );;
gap> perms2:= [];;
gap> for d in degrees do
>      Append( perms2, PermChars( m11, d ) );
>    od;
gap> Set( perms ) = Set( perms2 );
true
\endexample

Finally, we try the algorithm that is based on Gaussian elimination
and that is described in~\cite[Section~3.3]{BP98copy}.

\beginexample
gap> perms3:= [];;
gap> for d in degrees do
>      Append( perms3, PermChars( m11, rec( torso:= [ d ] ) ) );
>    od;
gap> Set( perms ) = Set( perms3 );
true
\endexample

{\GAP} provides two more functions to test properties of permutation
characters.
The first one yields no new information in our case,
but the second excludes one possible permutation character;
note that `TestPerm5' needs a $p$-modular Brauer table,
and the {\GAP} character table library contains all Brauer tables
of $M_{11}$.

\beginexample
gap> newperms:= TestPerm4( m11, perms );;
gap> newperms = perms;
true
gap> newperms:= TestPerm5( m11, perms, m11 mod 11 );;
gap> newperms = perms;
false
gap> Difference( perms, newperms );
[ Character( m11, [ 220, 4, 4, 0, 0, 4, 0, 0, 0, 0 ] ) ]
\endexample

{\GAP} knows the table of marks of $M_{11}$,
from which the permutation characters can be extracted.
It turns out that $M_{11}$ has $39$ conjugacy classes of subgroups
but only $36$ different permutation characters,
so three candidates computed above are in fact not permutation characters.

\beginexample
gap> tom:= TableOfMarks( "M11" );
TableOfMarks( "M11" )
gap> trueperms:= PermCharsTom( m11, tom );;
gap> Length( trueperms );  Length( Set( trueperms ) );
39
36
gap> Difference( perms, trueperms );
[ Character( m11, [ 220, 4, 4, 0, 0, 4, 0, 0, 0, 0 ] ), 
  Character( m11, [ 660, 4, 3, 4, 0, 1, 0, 0, 0, 0 ] ), 
  Character( m11, [ 660, 12, 3, 0, 0, 3, 0, 0, 0, 0 ] ) ]
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{The Action of $U_6(2)$ on the Cosets of $M_{22}$}
 
We are interested in the permutation character of $U_6(2)$
(see~\cite[p.~115]{CCN85}) that corresponds to the action on the cosets
of a $M_{22}$ subgroup (see~\cite[p.~39]{CCN85}).
The character tables of both the group and the point stabilizer
are available in the {\GAP} character table library,
so we can compute class fusion and permutation character directly;
note that if the class fusion is not stored on the table of the subgroup,
in general one will not get a unique fusion but only a list of candidates
for the fusion.

\beginexample
gap> u62:= CharacterTable( "U6(2)" );;
gap> m22:= CharacterTable( "M22" );;
gap> fus:= PossibleClassFusions( m22, u62 );
[ [ 1, 3, 7, 10, 14, 15, 22, 24, 24, 26, 33, 34 ],
  [ 1, 3, 7, 10, 14, 15, 22, 24, 24, 26, 34, 33 ],
  [ 1, 3, 7, 11, 14, 15, 22, 24, 24, 27, 33, 34 ],
  [ 1, 3, 7, 11, 14, 15, 22, 24, 24, 27, 34, 33 ],
  [ 1, 3, 7, 12, 14, 15, 22, 24, 24, 28, 33, 34 ],
  [ 1, 3, 7, 12, 14, 15, 22, 24, 24, 28, 34, 33 ] ]
gap> RepresentativesFusions( m22, fus, u62 );
[ [ 1, 3, 7, 10, 14, 15, 22, 24, 24, 26, 33, 34 ] ]
\endexample

We see that there are six possible class fusions that are equivalent
under table automorphisms of $U_6(2)$ and $M22$.

\beginexample
gap> cand:= Set( List( fus,
>  x -> Induced( m22, u62, [ TrivialCharacter( m22 ) ], x )[1] ) );
[ Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      0, 0, 48, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 0, 0, 4, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      0, 48, 0, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 0, 4, 0, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      48, 0, 0, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 4, 0, 0, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
gap> PermCharInfo( u62, cand ).ATLAS;
[ "1a+22a+252a+616a+1155c+1386a+8064a+9240c",
  "1a+22a+252a+616a+1155b+1386a+8064a+9240b",
  "1a+22a+252a+616a+1155a+1386a+8064a+9240a" ]
gap> aut:= AutomorphismsOfTable( u62 );;  Size( aut );
24
gap> elms:= Filtered( Elements( aut ), x -> Order( x ) = 3 );
[ (10,11,12)(26,27,28)(40,41,42), (10,12,11)(26,28,27)(40,42,41) ]
gap> Position( cand, Permuted( cand[1], elms[1] ) );
3
gap> Position( cand, Permuted( cand[3], elms[1] ) );
2
\endexample

The six fusions induce three different characters,
they are conjugate under the action of the unique subgroup of order $3$
in the group of table automorphisms of $U_6(2)$.
The table automorphisms of order $3$ are induced by group automorphisms
of $U_6(2)$ (see~\cite[p.~120]{CCN85}).
As can be seen from the list of maximal subgroups of $U_6(2)$
in~\cite[p.~115]{CCN85},
the three induced characters are in fact permutation characters
which belong to the three classes of maximal subgroups of type $M_{22}$
in $U_6(2)$, which are permuted by an outer automorphism of order 3.
 
Now we want to compute the extension of the above permutation character
to the group $U_6(2).2$,
which corresponds to the action of this group on the cosets of a $M_{22}.2$
subgroup.

\beginexample
gap> u622:= CharacterTable( "U6(2).2" );;
gap> m222:= CharacterTable( "M22.2" );;
gap> fus:= PossibleClassFusions( m222, u622 );
[ [ 1, 3, 7, 10, 13, 14, 20, 22, 22, 24, 29, 38, 39, 42, 41, 46, 50, 53, 58,
      59, 59 ] ]
gap> cand:= Induced( m222, u622, [ TrivialCharacter( m222 ) ], fus[1] );
[ Character( CharacterTable( "U6(2).2" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      48, 0, 0, 16, 6, 0, 0, 0, 0, 0, 6, 0, 2, 0, 4, 0, 0, 0, 0, 1, 0, 0, 0,
      0, 0, 0, 0, 0, 1080, 72, 0, 48, 8, 0, 0, 0, 18, 0, 0, 0, 8, 0, 0, 2, 0,
      0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0 ] ) ]
gap> PermCharInfo( u622, cand ).ATLAS;
[ "1a+22a+252a+616a+1155a+1386a+8064a+9240a" ]
\endexample

We see that for the embedding of $M_{22}.2$ into $U_6(2).2$,
the class fusion is unique,
so we get a unique extension of one of the above permutation characters.
This implies that exactly one class of maximal subgroups of type $M_{22}$
extends to $M_{22}.2$ in a given group $U_6(2).2$.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Degree $20\,736$ Permutation Characters of $U_6(2)$}
 
Now we show an alternative way to compute the characters dealt with
in the previous example.
This works also if the character table of the point stabilizer is not
available.
In this situation we can compute all those characters that have certain
properties of permutation characters.
 
Of course this may take much longer than the above computations,
which needed only a few seconds.
(The following calculations may need several hours,
depending on the computer used.)

\begintt
gap> cand:= PermChars( u62, rec( torso := [ 20736 ] ) );
[ Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      0, 0, 48, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 0, 0, 4, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      0, 48, 0, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 0, 4, 0, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( CharacterTable( "U6(2)" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      48, 0, 0, 0, 16, 6, 0, 0, 0, 0, 0, 0, 6, 0, 2, 0, 4, 0, 0, 0, 0, 0, 0,
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
\endtt

For the next step, that is, the computation of the extension of the
permutation character to $U_6(2).2$, we may use the above information,
since the values on the inner classes are prescribed.
 
The question which of the three candidates for $U_6(2)$ extends to
$U_6(2).2$ depends on the choice of the class fusion of $U_6(2)$ into
$U_6(2).2$.
With respect to the class fusion that is stored on the {\GAP} library table,
the third candidate extends,
as can be seen from the fact that this one is invariant under the
permutation of conjugacy classes of $U_6(2)$ that is induced by the
action of the chosen supergroup $U_6(2).2$.

\begintt
gap> u622:= CharacterTable( "U6(2).2" );;
gap> inv:= InverseMap( GetFusionMap( u62, u622 ) );
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, [ 11, 12 ], 13, 14, 15, [ 16, 17 ], 18, 19,
  20, 21, 22, 23, 24, 25, 26, [ 27, 28 ], [ 29, 30 ], 31, 32, [ 33, 34 ],
  [ 35, 36 ], 37, [ 38, 39 ], 40, [ 41, 42 ], 43, 44, [ 45, 46 ] ]
gap> ext:= List( cand, x -> CompositionMaps( x, inv ) );
[ [ 20736, 0, 384, 0, 0, 0, 54, 0, 0, 0, [ 0, 48 ], 0, 16, 6, 0, 0, 0, 0, 0,
      6, 0, 2, 0, 0, [ 0, 4 ], 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ],
  [ 20736, 0, 384, 0, 0, 0, 54, 0, 0, 0, [ 0, 48 ], 0, 16, 6, 0, 0, 0, 0, 0,
      6, 0, 2, 0, 0, [ 0, 4 ], 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ],
  [ 20736, 0, 384, 0, 0, 0, 54, 0, 0, 48, 0, 0, 16, 6, 0, 0, 0, 0, 0, 6, 0,
      2, 0, 4, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ] ]
gap> cand:= PermChars( u622, rec( torso:= ext[3] ) );
[ Character( CharacterTable( "U6(2).2" ), [ 20736, 0, 384, 0, 0, 0, 54, 0, 0,
      48, 0, 0, 16, 6, 0, 0, 0, 0, 0, 6, 0, 2, 0, 4, 0, 0, 0, 0, 1, 0, 0, 0,
      0, 0, 0, 0, 0, 1080, 72, 0, 48, 8, 0, 0, 0, 18, 0, 0, 0, 8, 0, 0, 2, 0,
      0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0 ] ) ]
\endtt


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Degree $57\,572\,775$ Permutation Characters of $O_8^+(3)$}
 
The group $O_8^+(3)$ (see~\cite[p.~140]{CCN85}) contains a subgroup of
type $2^{3+6}.L_3(2)$,
which extends to a maximal subgroup $U$ in $O_8^+(3).3$.
For the computation of the permutation character,
we cannot use explicit induction since the table of $U$ is not available
in the {\GAP} table library.
 
Since $U \cap O_8^+(3)$ is contained in a $O_8^+(2)$ subgroup
of $O_8^+(3)$, we can try to find the permutation character of $O_8^+(2)$
corresponding to the action on the cosets of $U \cap O_8^+(3)$,
and then induce this character to $O_8^+(3)$.
 
This kind of computations becomes more difficult with increasing degree,
so we try to reduce the problem further.
In fact, the $2^{3+6}.L_3(2)$ group is contained in a $2^6:A_8$ subgroup
of $O_8^+(2)$, in which the index is only $15$;
the unique possible permutation character of this degree can be read off
immediately.
 
Induction to $O_8^+(3)$ through the chain of subgroups is possible
provided the class fusions are available.
There are $24$ possible fusions from $O_8^+(2)$ into $O_8^+(3)$,
which are all equivalent w.r.t.~table automorphisms of $O_8^+(3)$.
If we later want to consider the extension of the permutation character
in question to $O_8^+(3).3$ then we have to choose a fusion of an
$O_8^+(2)$ subgroup that does *not* extend to $O_8^+(2).3$.
But if for example our question is just whether the resulting permutation
character is multiplicity-free then this can be decided already from the
permutation character of $O_8^+(3)$.

\beginexample
gap> o8p3:= CharacterTable("O8+(3)");;
gap> Size( o8p3 ) / (2^9*168);
57572775
gap> o8p2:= CharacterTable( "O8+(2)" );;
gap> fus:= PossibleClassFusions( o8p2, o8p3 );;
gap> Length( fus );
24
gap> rep:= RepresentativesFusions( o8p2, fus, o8p3 );
[ [ 1, 5, 2, 3, 4, 5, 7, 8, 12, 16, 17, 19, 23, 20, 21, 22, 23, 24, 25, 26,
      37, 38, 42, 31, 32, 36, 49, 52, 51, 50, 43, 44, 45, 53, 55, 56, 57, 71,
      71, 71, 72, 73, 74, 78, 79, 83, 88, 89, 90, 94, 100, 101, 105 ] ]
gap> fus:= rep[1];;
gap> Size( o8p2 ) / (2^9*168);
2025
gap> sub:= CharacterTable( "2^6:A8" );;
gap> subfus:= GetFusionMap( sub, o8p2 );
[ 1, 3, 2, 2, 4, 5, 6, 13, 3, 6, 12, 13, 14, 7, 21, 24, 11, 30, 29, 31, 13,
  17, 15, 16, 14, 17, 36, 37, 18, 41, 24, 44, 48, 28, 33, 32, 34, 35, 35, 51,
  51 ]
gap> fus:= CompositionMaps( fus, subfus );
[ 1, 2, 5, 5, 3, 4, 5, 23, 2, 5, 19, 23, 20, 7, 37, 31, 17, 50, 51, 43, 23,
  23, 21, 22, 20, 23, 56, 57, 24, 72, 31, 78, 89, 52, 45, 44, 53, 55, 55,
  100, 100 ]
gap> Size( sub ) / (2^9*168);
15
gap> List( Irr( sub ), Degree );
[ 1, 7, 14, 20, 21, 21, 21, 28, 35, 45, 45, 56, 64, 70, 28, 28, 35, 35, 35,
  35, 70, 70, 70, 70, 140, 140, 140, 140, 140, 210, 210, 252, 252, 280, 280,
  315, 315, 315, 315, 420, 448 ]
gap> cand:= PermChars( sub, 15 );
[ Character( CharacterTable( "2^6:A8" ), [ 15, 15, 15, 7, 7, 7, 7, 7, 3, 3,
      3, 3, 3, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1,
      1, 1, 1, 1, 1, 0, 0 ] ) ]
gap> ind:= Induced( sub, o8p3, cand, fus );
[ Character( CharacterTable( "O8+(3)" ), [ 57572775, 59535, 59535, 59535,
      3591, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2187, 0, 27, 135, 135, 135, 243,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 27, 27, 0,
      0, 0, 0, 27, 27, 27, 27, 0, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
gap> o8p33:= CharacterTable( "O8+(3).3" );;
gap> inv:= InverseMap( GetFusionMap( o8p3, o8p33 ) );
[ 1, [ 2, 3, 4 ], 5, 6, [ 7, 8, 9 ], [ 10, 11, 12 ], 13, [ 14, 15, 16 ], 17,
  18, 19, [ 20, 21, 22 ], 23, [ 24, 25, 26 ], [ 27, 28, 29 ], 30,
  [ 31, 32, 33 ], [ 34, 35, 36 ], [ 37, 38, 39 ], [ 40, 41, 42 ],
  [ 43, 44, 45 ], 46, [ 47, 48, 49 ], 50, [ 51, 52, 53 ], 54, 55, 56, 57,
  [ 58, 59, 60 ], [ 61, 62, 63 ], 64, [ 65, 66, 67 ], 68, [ 69, 70, 71 ],
  [ 72, 73, 74 ], [ 75, 76, 77 ], [ 78, 79, 80 ], [ 81, 82, 83 ], 84, 85,
  [ 86, 87, 88 ], [ 89, 90, 91 ], [ 92, 93, 94 ], 95, 96, [ 97, 98, 99 ],
  [ 100, 101, 102 ], [ 103, 104, 105 ], [ 106, 107, 108 ], [ 109, 110, 111 ],
  [ 112, 113, 114 ] ]
gap> ext:= CompositionMaps( ind[1], inv );
[ 57572775, 59535, 3591, 0, 0, 0, 0, 0, 2187, 0, 27, 135, 243, 0, 0, 0, 0, 0,
  0, 0, 27, 0, 0, 27, 27, 0, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> perms:= PermChars( o8p33, rec( torso:= ext ) );
[ Character( CharacterTable( "O8+(3).3" ), [ 57572775, 59535, 3591, 0, 0, 0,
      0, 0, 2187, 0, 27, 135, 243, 0, 0, 0, 0, 0, 0, 0, 27, 0, 0, 27, 27, 0,
      8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 3159, 3159, 243, 243, 39, 39, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3,
      3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
     ] ) ]
gap> PermCharInfo( o8p33, perms ).ATLAS;
[ "1a+780aabb+2457a+2808abc+9450aaabbcc+18200abcdddef+24192a+54600a^{5}b+70200\
aabb+87360ab+139776a^{5}+147420a^{4}b^{4}+163800ab+184275aabc+199017aa+218700a\
+245700a+291200aef+332800a^{4}b^{5}c^{5}+491400aaabcd+531441a^{5}b^{4}c^{4}+55\
2825a^{4}+568620aabb+698880a^{4}b^{4}+716800aaabbccdddeeff+786240aabb+873600aa\
+998400aa+1257984a^{6}+1397760aa" ]
\endexample

%T Alternatively, if the table of marks of the group is available
%T then one can extract the permutation characters from it.
%T The table of marks of $O_8^+(2)$ is in fact available,
%T but it requires some time to read the data into {\GAP},
%T since the file is about $25$ MB large.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{The Action of $O_7(3).2$ on the Cosets of $2^7.S_7$}
 
We want to know whether the permutation character of $O_7(3).2$
(see~\cite[p.~108]{CCN85}) on the cosets of its maximal subgroup $U$
of type $2^7.S_7$ is multiplicity-free.
 
As in the previous examples, first we try to compute the permutation
character of the simple group $O_7(3)$.
It turns out that the direct computation of all candidates from the
degree is very time consuming.
But we can use for example the additional information provided by the fact
that $U$ contains an $A_7$ subgroup.
We compute the possible class fusions.

\beginexample
gap> o73:= CharacterTable( "O7(3)" );;
gap> a7:= CharacterTable( "A7" );;
gap> fus:= PossibleClassFusions( a7, o73 );
[ [ 1, 3, 6, 10, 15, 16, 24, 33, 33 ], [ 1, 3, 7, 10, 15, 16, 22, 33, 33 ] ]
\endexample

We cannot decide easily which fusion is the right one,
but already the fact that no other fusions are possible
gives us some information about impossible constituents of the
permutation character we want to compute.

\beginexample
gap> ind:= List( fus,
>       x -> Induced( a7, o73, [ TrivialCharacter( a7 ) ], x )[1] );;
gap> mat:= MatScalarProducts( o73, Irr( o73 ), ind );;
gap> sum:= Sum( mat );
[ 2, 6, 2, 0, 8, 6, 2, 4, 4, 8, 3, 0, 4, 4, 9, 3, 5, 0, 0, 9, 0, 10, 5, 6,
  15, 1, 12, 1, 15, 7, 2, 4, 14, 16, 0, 12, 12, 7, 8, 8, 14, 12, 12, 14, 6,
  6, 20, 16, 12, 12, 12, 10, 10, 12, 12, 8, 12, 6 ]
gap> const:= Filtered( [ 1 .. Length( sum ) ], x -> sum[x] <> 0 );
[ 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 20, 22, 23, 24, 25, 26,
  27, 28, 29, 30, 31, 32, 33, 34, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46,
  47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58 ]
gap> Length( const );
52
gap> const:= Irr( o73 ){ const };;
gap> rat:= RationalizedMat( const );;
\endexample

But much more can be deduced from the fact that certain zeros
of the permutation character can be predicted.

\beginexample
gap> names:= ClassNames( o73 );
[ "1a", "2a", "2b", "2c", "3a", "3b", "3c", "3d", "3e", "3f", "3g", "4a",
  "4b", "4c", "4d", "5a", "6a", "6b", "6c", "6d", "6e", "6f", "6g", "6h",
  "6i", "6j", "6k", "6l", "6m", "6n", "6o", "6p", "7a", "8a", "8b", "9a",
  "9b", "9c", "9d", "10a", "10b", "12a", "12b", "12c", "12d", "12e", "12f",
  "12g", "12h", "13a", "13b", "14a", "15a", "18a", "18b", "18c", "18d", "20a"
 ]
gap> List( fus, x -> names{ x } );
[ [ "1a", "2b", "3b", "3f", "4d", "5a", "6h", "7a", "7a" ],
  [ "1a", "2b", "3c", "3f", "4d", "5a", "6f", "7a", "7a" ] ]
gap> torso:= [ 28431 ];;
gap> zeros:= [ 5, 8, 9, 11, 17, 20, 23, 28, 29, 32, 36, 37, 38,
>              43, 46, 47, 48, 53, 54, 55, 56, 57, 58 ];;
gap> names{ zeros };
[ "3a", "3d", "3e", "3g", "6a", "6d", "6g", "6l", "6m", "6p", "9a", "9b", 
  "9c", "12b", "12e", "12f", "12g", "15a", "18a", "18b", "18c", "18d", "20a" ]
\endexample

Every order $3$ element of $U$ lies in an $A_7$ subgroup of $U$,
so among the classes of element order $3$, at most the classes `3B', `3C',
and `3F' can have nonzero permutation character values.
The excluded classes of element order $6$ are the square roots of the
excluded order $3$ elements,
likewise the given classes of element orders $9$, $12$, and $18$ are
excluded.
The character value on `20A' must be zero because $U$ does not contain
elements of this order.
So we enter the additional information about these zeros.

\beginexample
gap> for i in zeros do
>      torso[i]:= 0;
>    od;
gap> torso;
[ 28431,,,, 0,,, 0, 0,, 0,,,,,, 0,,, 0,,, 0,,,,, 0, 0,,, 0,,,, 0, 0, 0,,,,, 0,
  ,, 0, 0, 0,,,,, 0, 0, 0, 0, 0, 0 ]
gap> perms:= PermChars( o73, rec( torso:= torso, chars:= rat ) );
[ Character( CharacterTable( "O7(3)" ), [ 28431, 567, 567, 111, 0, 0, 243, 0,
      0, 81, 0, 15, 3, 27, 15, 6, 0, 0, 27, 0, 3, 27, 0, 0, 0, 3, 9, 0, 0, 3,
      3, 0, 4, 1, 1, 0, 0, 0, 0, 2, 2, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0 ] ) ]
gap> PermCharInfo( o73, perms ).ATLAS;
[ "1a+78a+168a+182a+260ab+1092a+2457a+2730a+4095b+5460a+11648a" ]
\endexample

We see that this character is already multiplicity free,
so this holds also for its extension to $O_7(3).2$,
and we need not compute this extension.
(Of course we could compute it in the same way as in the examples above.)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{The Action of $O_8^+(3).2_1$ on the Cosets of $2^7.A_8$}
 
We are interested in the permutation character of $O_8^+(3).2_1$
that corresponds to the action on the cosets of a subgroup of type
$2^7.A_8$.
The intersection of the point stabilizer with the simple group $O_8^+(3)$
is of type $2^6.A_8$.
First we compute the class fusion of these groups,
modulo problems with ambiguities due to table automorphisms.

\beginexample
gap> o8p3:= CharacterTable( "O8+(3)" );;
gap> o8p2:= CharacterTable( "O8+(2)" );;
gap> fus:= PossibleClassFusions( o8p2, o8p3 );;
gap> NamesOfFusionSources( o8p2 );
[ "A9", "2^8:O8+(2)", "2^(1+8)+.O8+(2)", "2^6:A8", "2.O8+(2)", "2^2.O8+(2)",
  "S6(2)" ]
gap> sub:= CharacterTable( "2^6:A8" );;
gap> subfus:= GetFusionMap( sub, o8p2 );
[ 1, 3, 2, 2, 4, 5, 6, 13, 3, 6, 12, 13, 14, 7, 21, 24, 11, 30, 29, 31, 13,
  17, 15, 16, 14, 17, 36, 37, 18, 41, 24, 44, 48, 28, 33, 32, 34, 35, 35, 51,
  51 ]
gap> fus:= List( fus, x -> CompositionMaps( x, subfus ) );;
gap> fus:= Set( fus );;
gap> Length( fus );
24
\endexample

The ambiguities due to Galois automorphisms disappear when we are
looking for the permutation characters induced by the fusions.

\beginexample
gap> ind:= List( fus, x -> Induced( sub, o8p3,
>                              [ TrivialCharacter( sub ) ], x )[1] );;
gap> ind:= Set( ind );;
gap> Length( ind );
6
\endexample

Now we try to extend the candidates to $O_8^+(3).2_1$;
the choice of the fusion of $O_8^+(3)$ into $O_8^+(3).2_1$ determines
which of the candidates may extend.

\beginexample
gap> o8p32:= CharacterTable( "O8+(3).2_1" );;
gap> fus:= GetFusionMap( o8p3, o8p32 );;
gap> ext:= List( ind, x -> CompositionMaps( x, InverseMap( fus ) ) );;
gap> ext:= Filtered( ext, x -> ForAll( x, IsInt ) );
[ [ 3838185, 17577, 8505, 8505, 873, 0, 0, 0, 0, 6561, 0, 0, 729, 0, 9, 105,
      45, 45, 105, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 189, 0, 0, 0, 9, 9, 27, 27,
      0, 0, 27, 9, 0, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0,
      0, 0, 9, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0,
      0, 0 ], [ 3838185, 17577, 8505, 8505, 873, 0, 6561, 0, 0, 0, 0, 0, 729,
      0, 9, 105, 45, 45, 105, 30, 0, 0, 0, 0, 0, 0, 189, 0, 0, 0, 9, 0, 0, 0,
      9, 27, 27, 0, 0, 9, 27, 0, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0,
      0, 0, 9, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0 ] ]
\endexample

We compute the extensions of the first candidate;
the other belongs to another class of subgroups,
which is the image under an outer automorphism.
(These calculations may need about one hour,
depending on the computer used.)

\begintt
gap> perms:= PermChars( o8p32, rec( torso:= ext[1] ) );
[ Character( CharacterTable( "O8+(3).2_1" ),
    [ 3838185, 17577, 8505, 8505, 873, 0, 0, 0, 0, 6561, 0, 0, 729, 0, 9,
      105, 45, 45, 105, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 189, 0, 0, 0, 9, 9,
      27, 27, 0, 0, 27, 9, 0, 8, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0,
      0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0,
      0, 0, 0, 0, 3159, 1575, 567, 63, 87, 15, 0, 0, 45, 0, 81, 9, 27, 0, 0,
      3, 3, 3, 3, 5, 5, 0, 0, 0, 4, 0, 0, 27, 0, 9, 0, 0, 15, 0, 3, 0, 0, 2,
      0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
gap> PermCharInfo( o8p32, perms ).ATLAS;
[ "1a+260abc+520ab+819a+2808b+9450aab+18200a+23400ac+29120b+36400aab+46592abce\
+49140d+66339a+98280ab+163800a+189540d+232960d+332800ab+368550a+419328a+531441\
ab" ]
\endtt

Now we repeat the calculations for $O_8^+(3).2_2$ instead of
$O_8^+(3).2_1$.

\begintt
gap> o8p32:= CharacterTable( "O8+(3).2_2" );;
gap> fus:= GetFusionMap( o8p3, o8p32 );;
gap> ext:= List( ind, x -> CompositionMaps( x, InverseMap( fus ) ) );;
gap> ext:= Filtered( ext, x -> ForAll( x, IsInt ) );;
gap> perms:= PermChars( o8p32, rec( torso:= ext[1] ) );
[ Character( CharacterTable( "O8+(3).2_2" ), [ 3838185, 17577, 8505, 873, 0,
      0, 0, 6561, 0, 0, 0, 0, 729, 0, 9, 105, 45, 105, 30, 0, 0, 0, 0, 0, 0,
      189, 0, 0, 0, 9, 0, 9, 27, 0, 0, 0, 27, 27, 9, 0, 8, 1, 1, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0,
      0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 199017, 2025, 297, 441, 73, 9, 0,
      1215, 0, 0, 0, 0, 0, 81, 0, 0, 0, 0, 27, 27, 0, 1, 9, 12, 0, 0, 45, 0,
      0, 1, 0, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 0, 0, 0, 0, 0, 0
     ] ) ]
gap> PermCharInfo( o8p32, perms ).ATLAS;
[ "1a+260aac+520ab+819a+2808a+9450aaa+18200accee+23400ac+29120a+36400a+46592aa\
+49140c+66339a+93184a+98280ab+163800a+184275ac+189540c+232960c+332800aa+419328\
a+531441aa" ]
\endtt

%T Remark:
%T If we are now interested in the extension to $O_8^+(3).(2^2)_{122}$
%T then the table library does not help, since this table is not (yet)
%T contained in it.
%T But the extension cannot be multiplicity free because of the multiplicity
%T `9450aaa' in the character of $O_8^+(3).2_2$.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{The Action of $S_4(4).4$ on the Cosets of $5^2.[2^5]$}
 
We want to know whether the permutation character corresponding to the
action of $S_4(4).4$ (see~\cite[p.~44]{CCN85}) on the cosets of its
maximal subgroup of type $5^2:[2^5]$ is multiplicity free.
 
The library names of subgroups for which the class fusions are stored
are listed as value of the attribute `NamesOfFusionSources',
and for groups whose isomorphism type is not determined by the name
this is the recommended way to find out whether the table of the subgroup
is contained in the {\GAP} library and known to belong to this group.
(It might be that a table with such a name is contained in the library
but belongs to another group,
and it may also be that the table of the group is contained in the
library --with any name-- but it is not known that this group is
isomorphic to a subgroup of $S_4(4).4$.)

\beginexample
gap> s444:= CharacterTable( "S4(4).4" );;
gap> NamesOfFusionSources( s444 );
[ "S4(4)", "S4(4).2" ]
\endexample

So we cannot simply fetch the table of the subgroup.
As in the previous examples, we compute the possible permutation
characters.

\beginexample
gap> perms:= PermChars( s444, rec( torso:= [ Size( s444 ) / ( 5^2*2^5 ) ] ) );
[ Character( CharacterTable( "S4(4).4" ), [ 4896, 384, 96, 0, 16, 32, 36, 16,
      0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ),
  Character( CharacterTable( "S4(4).4" ), [ 4896, 192, 32, 0, 0, 8, 6, 1, 0,
      2, 0, 0, 36, 0, 12, 0, 0, 0, 1, 0, 6, 6, 2, 2, 0, 0, 0, 0, 1, 1 ] ),
  Character( CharacterTable( "S4(4).4" ), [ 4896, 240, 64, 0, 8, 8, 36, 16,
      0, 0, 0, 0, 0, 12, 8, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
\endexample

So there are three candidates.
None of them is multiplicity free,
so we need not decide which of the candidates actually belongs
to the group $5^2:[2^5]$ we have in mind.

\beginexample
gap> PermCharInfo( s444, perms ).ATLAS;
[ "1abcd+50abcd+153abcd+170a^{4}b^{4}+680aabb",
  "1a+50ac+153a+170aab+256a+680abb+816a+1020a",
  "1ac+50ac+68a+153abcd+170aabbb+204a+680abb+1020a" ]
\endexample

(If we would be interested which candidate is the right one,
we could for example look at the intersection with $S_4(4)$,
and hope for a contradiction to the fact that the group must lie
in a $(A_5 \times A_5):2$ subgroup.)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{The Action of $Co_1$ on the Cosets of Involution Centralizers}
 
We compute the permutation characters of the sporadic simple Conway group
$Co_1$ (see~\cite[p.~180]{CCN85}) corresponding to the actions on
the cosets of involution centralizers.
Equivalently, we are interested in the action of $Co_1$ on conjugacy
classes of involutions.
These characters can be computed as follows.
First we take the table of $Co_1$.

\beginexample
gap> t:= CharacterTable( "Co1" );
CharacterTable( "Co1" )
\endexample

The centralizer of each {\tt 2A} element is a maximal subgroup of $Co_1$.
This group is also contained in the table library.
So we can compute the permutation character by explicit induction,
and the decomposition in irreducibles is computed with the command
`PermCharInfo'.

\beginexample
gap> s:= CharacterTable( Maxes( t )[5] );
CharacterTable( "2^(1+8)+.O8+(2)" )
gap> ind:= Induced( s, t, [ TrivialCharacter( s ) ] );;
gap> PermCharInfo( t, ind ).ATLAS;
[ "1a+299a+17250a+27300a+80730a+313950a+644644a+2816856a+5494125a+12432420a+24\
794000a" ]
\endexample

The centralizer of a {\tt 2B} element is not maximal.
First we compute which maximal subgroup can contain it.
The character tables of all maximal subgroups of $Co_1$ are contained
in the {\GAP}'s table library,
so we may take these tables and look at the group orders.

\beginexample
gap> centorder:= SizesCentralizers( t )[3];;
gap> maxes:= List( Maxes( t ), CharacterTable );;
gap> cand:= Filtered( maxes, x -> Size( x ) mod centorder = 0 );
[ CharacterTable( "(A4xG2(4)):2" ) ]
gap> u:= cand[1];;
gap> index:= Size( u ) / centorder;
3
\endexample

So there is a unique class of maximal subgroups containing the centralizer
of a {\tt 2B} element, as a subgroup of index $3$.
We compute the unique permutation character of degree $3$ of this group,
and induce this character to $G$.
 
%T In fact we compute all those characters that have certain properties
%T of permutation characters.
%T In our situation, this is sufficient.
%T
%T For a very small degree, the algorithm that needs the `torso' component
%T of the options record is a good choice.
%T If one wants to use the combinatorial algorithm for a small degree and
%T a not very small number of conjugacy classes, one should suppress the
%T computation of bounds by setting the `bounds' component to `false'.

\beginexample
gap> subperm:= PermChars( u, rec( degree := index, bounds := false ) );
[ Character( CharacterTable( "(A4xG2(4)):2" ),
    [ 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 3,
      3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] ) ]
gap> subperm = PermChars( u, rec( torso := [ 3 ] ) );
true
gap> ind:= Induced( u, t, subperm );
[ Character( CharacterTable( "Co1" ), [ 2065694400, 181440, 119408, 38016,
      2779920, 0, 0, 378, 30240, 864, 0, 720, 316, 80, 2520, 30, 0, 6480,
      1508, 0, 0, 0, 0, 0, 38, 18, 105, 0, 600, 120, 56, 24, 0, 12, 0, 0, 0,
      120, 48, 18, 0, 0, 6, 0, 360, 144, 108, 0, 0, 10, 0, 0, 0, 0, 0, 4, 2,
      3, 9, 0, 0, 15, 3, 0, 0, 4, 4, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 12,
      8, 0, 6, 0, 0, 3, 0, 1, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0 ] ) ]
gap> PermCharInfo( t, ind ).ATLAS;
[ "1a+1771a+8855a+27300aa+313950a+345345a+644644aa+871884aaa+1771000a+2055625a\
+4100096a+7628985a+9669660a+12432420aa+21528000aa+23244375a+24174150aa+2479400\
0a+31574400aa+40370176a+60435375a+85250880aa+100725625a+106142400a+150732800a+\
184184000a+185912496a+207491625a+299710125a+302176875a" ]
\endexample

Finally, we try the same for the centralizer of a `2C' element.

\beginexample
gap> centorder:= SizesCentralizers( t )[4];;
gap> cand:= Filtered( maxes, x -> Size( x ) mod centorder = 0 );
[ CharacterTable( "Co2" ), CharacterTable( "2^11:M24" ) ]
\endexample

The group order excludes all except two classes of maximal subgroups.
But the `2C' centralizer cannot lie in $Co_2$ because the involution
centralizers in $Co_2$ are too small.

\beginexample
gap> u:= cand[1];;
gap> GetFusionMap( u, t );
[ 1, 2, 2, 4, 7, 6, 9, 11, 11, 10, 11, 12, 14, 17, 16, 21, 23, 20, 22, 22,
  24, 28, 30, 33, 31, 32, 33, 33, 37, 42, 41, 43, 44, 48, 52, 49, 53, 55, 53,
  52, 54, 60, 60, 60, 64, 65, 65, 67, 66, 70, 73, 72, 78, 79, 84, 85, 87, 92,
  93, 93 ]
gap> centorder;
389283840
gap> SizesCentralizers( u )[4];
1474560
\endexample

So we try the second candidate.

\beginexample
gap> u:= cand[2];
CharacterTable( "2^11:M24" )
gap> index:= Size( u ) / centorder;
1288
gap> subperm:= PermChars( u, rec( torso := [ index ] ) );
[ Character( CharacterTable( "2^11:M24" ), [ 1288, 1288, 1288, 56, 56, 56,
      56, 56, 56, 48, 48, 48, 48, 48, 10, 10, 10, 10, 7, 7, 8, 8, 8, 8, 8, 8,
      4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 3, 3, 3, 0,
      0, 0, 0, 2, 2, 2, 2, 3, 3, 3, 1, 1, 2, 2, 2, 2, 1, 1, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0 ] ) ]
gap> subperm = PermChars( u, rec( degree:= index, bounds := false ) );
true
gap> ind:= Induced( u, t, subperm );
[ Character( CharacterTable( "Co1" ), [ 10680579000, 1988280, 196560, 94744,
      0, 17010, 0, 945, 7560, 3432, 2280, 1728, 252, 308, 0, 225, 0, 0, 0,
      270, 0, 306, 0, 46, 45, 25, 0, 0, 120, 32, 12, 52, 36, 36, 0, 0, 0, 0,
      0, 45, 15, 0, 9, 3, 0, 0, 0, 0, 18, 0, 30, 0, 6, 18, 0, 3, 5, 0, 0, 0,
      0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 6, 0, 2,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
gap> PermCharInfo( t, last ).ATLAS;
[ "1a+17250aa+27300a+80730aa+644644aaa+871884a+1821600a+2055625aaa+2816856a+54\
94125a^{4}+12432420aa+16347825aa+23244375a+24174150aa+24667500aa+24794000aaa+3\
1574400a+40370176a+55255200a+66602250a^{4}+83720000aa+85250880aaa+91547820aa+1\
06142400a+150732800a+184184000aaa+185912496aaa+185955000aaa+207491625aaa+21554\
7904aa+241741500aaa+247235625a+257857600aa+259008750a+280280000a+302176875a+32\
6956500a+387317700a+402902500a+464257024a+469945476b+502078500a+503513010a+504\
627200a+522161640a" ]
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{The Multiplicity Free Permutation Characters of $G_2(3)$}
 
We compute the multiplicity free possible permutation characters of
$G_2(3)$ (see~\cite[p.~60]{CCN85}).
 
For each divisor $d$ of the group order,
we compute all those possible permutation
characters of degree $d$ of $G$ for which each irreducible constituent
occurs with multiplicity at most $1$;
this is done by prescribing the `maxmult' component of the second argument
of `PermChars' to be the list with $1$ at each position.

\beginexample
gap> t:= CharacterTable( "G2(3)" );
CharacterTable( "G2(3)" )
gap> t:= CharacterTable( "G2(3)" );;
gap> n:= Length( RationalizedMat( Irr( t ) ) );;
gap> maxmult:= List( [ 1 .. n ], i -> 1 );;
gap> perms:= [];;
gap> divs:= DivisorsInt( Size( t ) );;
gap> for d in divs do
>      Append( perms,
>              PermChars( t, rec( bounds  := false,
>                                 degree  := d,
>                                 maxmult := maxmult ) ) );
>    od;
gap> Length( perms );
42
gap> List( perms, Degree );
[ 1, 351, 351, 364, 364, 378, 378, 546, 546, 546, 546, 546, 702, 702, 728,
  728, 1092, 1092, 1092, 1092, 1092, 1092, 1092, 1092, 1456, 1456, 1638,
  1638, 2184, 2184, 2457, 2457, 2457, 2457, 3159, 3276, 3276, 3276, 3276,
  4368, 6552, 6552 ]
\endexample

For finding out which of these candidates are really permutation
characters, we could inspect them piece by piece, using the information
in~\cite{CCN85}.
For example, the candidates of degrees $351$, $364$, and $378$ are
induced from the trivial characters of maximal subgroups of $G$,
whereas the candidates of degree $546$ are not permutation characters.
 
Since the table of marks of $G$ is available in {\GAP},
we can extract all permutation characters from the table of marks,
and then filter out the multiplicity free ones.

\beginexample
gap> tom:= TableOfMarks( "G2(3)" );
TableOfMarks( "G2(3)" )
gap> tbl:= CharacterTable( "G2(3)" );
CharacterTable( "G2(3)" )
gap> permstom:= PermCharsTom( tbl, tom );;
gap> Length( permstom );
433
gap> multfree:= Intersection( perms, permstom );;
gap> Length( multfree );
15
gap> List( multfree, Degree );
[ 1, 351, 351, 364, 364, 378, 378, 702, 702, 728, 728, 1092, 1092, 2184, 2184
 ]
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Degree $11\,200$ Permutation Characters of $O_8^+(2)$}
 
We compute the primitive permutation characters of degree $11\,200$ of
$O_8^+(2)$ and $O_8^+(2).2$ (see~\cite[p.~85]{CCN85}).
The character table of the maximal subgroup of type $3^4:2^3.S_4$ in
$O_8^+(2)$ is not available in the {\GAP} table library.
But the group extends to a wreath product of $S_3$ and $S_4$ in the
group $O_8^+(2).2$, and the table of this wreath product can be
constructed easily.

\beginexample
gap> tbl2:= CharacterTable("O8+(2).2");;
gap> s3:= CharacterTable( "Symmetric", 3 );;
gap> s:= CharacterTableWreathSymmetric( s3, 4 );
CharacterTable( "Sym(3)wrS4" )
\endexample

The permutation character `pi' of $O_8^+(2).2$ can thus be computed by
explicit induction, and the character of $O_8^+(2)$ is obtained by
restriction of `pi'.

\beginexample
gap> fus:= PossibleClassFusions( s, tbl2 );
[ [ 1, 41, 6, 3, 48, 9, 42, 19, 51, 8, 5, 50, 24, 49, 7, 2, 44, 22, 42, 12,
      53, 17, 58, 21, 5, 47, 26, 50, 37, 52, 23, 60, 18, 4, 46, 25, 14, 61,
      20, 9, 53, 30, 51, 26, 64, 8, 52, 31, 13, 56, 38 ] ]
gap> pi:= Induced( s, tbl2, [ TrivialCharacter( s ) ], fus[1] )[1];
Character( CharacterTable( "O8+(2).2" ), [ 11200, 256, 160, 160, 80, 40, 40,
  76, 13, 0, 0, 8, 8, 4, 0, 0, 16, 16, 4, 4, 4, 1, 1, 1, 1, 5, 0, 0, 0, 1, 1,
  0, 0, 0, 0, 0, 2, 2, 0, 0, 1120, 96, 0, 16, 0, 16, 8, 10, 4, 6, 7, 12, 3,
  0, 0, 2, 0, 4, 0, 1, 1, 0, 0, 1, 0, 0, 0 ] )
gap> PermCharInfo( tbl2, pi ).ATLAS;
[ "1a+84a+168a+175a+300a+700c+972a+1400a+3200a+4200b" ]
gap> tbl:= CharacterTable( "O8+(2)" );
CharacterTable( "O8+(2)" )
gap> rest:= RestrictedClassFunction( pi, tbl );
Character( CharacterTable( "O8+(2)" ), [ 11200, 256, 160, 160, 160, 80, 40,
  40, 40, 76, 13, 0, 0, 8, 8, 8, 4, 0, 0, 0, 16, 16, 16, 4, 4, 4, 4, 1, 1, 1,
  1, 1, 1, 5, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0 ] )
gap> PermCharInfo( tbl, rest ).ATLAS;
[ "1a+84abc+175a+300a+700bcd+972a+3200a+4200a" ]
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{A Proof of Nonexistence of a Certain Subgroup}
 
We prove that the sporadic simple Mathieu group $G = M_{22}$
(see~\cite[p.~39]{CCN85}) has no subgroup of index $56$.
In~\cite{Isa76}, remark after Theorem~5.18, this is stated as an example
of the case that a character may be a possible permutation character but
not a permutation character.
 
Let us consider the possible permutation character of degree $56$ of
$G$.

\beginexample
gap> tbl:= CharacterTable( "M22" );
CharacterTable( "M22" )
gap> perms:= PermChars( tbl, rec( torso:= [ 56 ] ) );
[ Character( CharacterTable( "M22" ), [ 56, 8, 2, 4, 0, 1, 2, 0, 0, 2, 1, 1
     ] ) ]
gap> pi:= perms[1];;
gap> Norm( pi );
2
gap> Display( tbl, rec( chars:= perms ) );
M22

     2  7  7  2  5  4  .  2  .  .  3   .   .
     3  2  1  2  .  .  .  1  .  .  .   .   .
     5  1  .  .  .  .  1  .  .  .  .   .   .
     7  1  .  .  .  .  .  .  1  1  .   .   .
    11  1  .  .  .  .  .  .  .  .  .   1   1

       1a 2a 3a 4a 4b 5a 6a 7a 7b 8a 11a 11b
    2P 1a 1a 3a 2a 2a 5a 3a 7a 7b 4a 11b 11a
    3P 1a 2a 1a 4a 4b 5a 2a 7b 7a 8a 11a 11b
    5P 1a 2a 3a 4a 4b 1a 6a 7b 7a 8a 11a 11b
    7P 1a 2a 3a 4a 4b 5a 6a 1a 1a 8a 11b 11a
   11P 1a 2a 3a 4a 4b 5a 6a 7a 7b 8a  1a  1a

Y.1    56  8  2  4  .  1  2  .  .  2   1   1

\endexample

Suppose that `pi' is a permutation character of $G$.
Since $G$ is $2$-transitive on the $56$ cosets of the point stabilizer $S$,
this stabilizer is transitive on $55$ points,
and thus $G$ has a subgroup $U$ of index $56 \cdot 55 = 3080$.
We compute the possible permutation character of this degree.

\beginexample
gap> perms:= PermChars( tbl, rec( torso:= [ 56 * 55 ] ) );;
gap> Length( perms );
16
\endexample

$U$ is contained in $S$, so only those candidates must be considered
that vanish on all classes where `pi' vanishes.
Furthermore, the index of $U$ in $S$ is odd, so the Sylow $2$ subgroups
of $U$ and $S$ are isomorphic;
$S$ contains elements of order $8$, hence also $U$ does.

\beginexample
gap> OrdersClassRepresentatives( tbl );
[ 1, 2, 3, 4, 4, 5, 6, 7, 7, 8, 11, 11 ]
gap> perms:= Filtered( perms, x -> x[5] = 0 and x[10] <> 0 );
[ Character( CharacterTable( "M22" ), [ 3080, 56, 2, 12, 0, 0, 2, 0, 0, 2, 0,
      0 ] ), Character( CharacterTable( "M22" ),
    [ 3080, 8, 2, 8, 0, 0, 2, 0, 0, 4, 0, 0 ] ),
  Character( CharacterTable( "M22" ), [ 3080, 24, 11, 4, 0, 0, 3, 0, 0, 2, 0,
      0 ] ), Character( CharacterTable( "M22" ),
    [ 3080, 24, 20, 4, 0, 0, 0, 0, 0, 2, 0, 0 ] ) ]
\endexample

For getting an overview of the distribution of the elements of $U$ to the
conjugacy classes of $G$, we use the output of `PermCharInfo'.

\beginexample
gap> infoperms:= PermCharInfo( tbl, perms );;
gap> Display( tbl, infoperms.display );
M22

      2    7  7  2  5  2  3
      3    2  1  2  .  1  .
      5    1  .  .  .  .  .
      7    1  .  .  .  .  .
     11    1  .  .  .  .  .

          1a 2a 3a 4a 6a 8a
     2P   1a 1a 3a 2a 3a 4a
     3P   1a 2a 1a 4a 2a 8a
     5P   1a 2a 3a 4a 6a 8a
     7P   1a 2a 3a 4a 6a 8a
    11P   1a 2a 3a 4a 6a 8a

I.1     3080 56  2 12  2  2
I.2        1 21  8 54 24 36
I.3        1  3  4  9 12 18
I.4     3080  8  2  8  2  4
I.5        1  3  8 36 24 72
I.6        1  3  4  9 12 18
I.7     3080 24 11  4  3  2
I.8        1  9 44 18 36 36
I.9        1  3  4  9 12 18
I.10    3080 24 20  4  .  2
I.11       1  9 80 18  . 36
I.12       1  3  4  9 12 18
\endexample

We have four candidates.
For each the above list shows first the character values,
then the cardinality of the intersection of $U$ with the classes,
and then lower bounds for the lengths of $U$-conjugacy classes of these
elements.
Only those classes of $G$ are shown that contain elements of $U$
for at least one of the characters.

If the first two candidates are permutation characters corresponding to
$U$ then $U$ contains exactly $8$ elements of order $3$
and thus $U$ has a normal Sylow $3$ subgroup $P$.
But the order of $N_G(P)$ is bounded by $72$,
which can be shown as follows.
The only elements in $G$ with centralizer order divisible by $9$
are of order $1$ or $3$, so $P$ is self-centralizing in $G$.
The factor $N_G(P)/C_G(P)$ is isomorphic with a subgroup of
${\rm Aut}(G) \cong GL(2,3)$ which has order divisible
by $16$, hence the order of $N_G(P)$ divides $144$.
Now note that $[ G : N_G(P) ] \equiv 1 \pmod{3}$ by Sylow's Theorem,
and $|G|/144 = 3\,080 \equiv -1 \pmod{3}$.
Thus the first two candidates are not permutation characters.
 
If the last two candidates are permutation characters corresponding to
$U$ then $U$ has self-normalizing Sylow subgroups.
This is because the index of a Sylow $2$ normalizer
in $G$ is odd and divides $9$,
and if it is smaller than $9$ then $U$ contains
at most $3 \cdot 15 + 1$ elements of $2$ power order;
the index of a Sylow $3$ normalizer
in $G$ is congruent to $1$ modulo $3$ and divides $16$,
and if it is smaller than $16$ then $U$ contains
at most $4 \cdot 8$ elements of order $3$.
 
But since $U$ is solvable and not a $p$-group,
not all its Sylow subgroups can be self-normalizing;
note that $U$ has a proper normal subgroup $N$ containing
a Sylow $p$ subgroup $P$ of $U$ for a prime divisor $p$ of $|U|$,
and $U = N \cdot N_U(P)$ holds by the Frattini argument
(see~\cite[Satz~I.7.8]{Hup67}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{A Permutation Character of the Lyons group}

Let $G$ be a maximal subgroup with structure $3^{2+4}:2A_5.D_8$
in the sporadic simple Lyons group $Ly$.
We want to compute the permutation character $1_G^{Ly}$.
(This construction has been explained in~\cite[Section~4.2]{BP98copy},
without showing explicit {\GAP} code.)

In the representation of $Ly$ as automorphism group of the rank $5$
graph `B' with $9\,606\,125$ points (see~\cite[p.~174]{CCN85}),
$G$ is the stabilizer of an edge.
A group $S$ with structure $3.McL.2$ is the point stabilizer.
So the two point stabilizer $U = S \cap G$ is a subgroup of index $2$
in $G$.
The index of $U$ in $S$ is $15\,400$, and according to the list of
maximal subgroups of $McL.2$ (see~\cite[p.~100]{CCN85}),
the group $U$ is isomorphic to the preimage in $3.McL.2$ of a subgroup $H$
of $McL.2$ with structure $3_+^{1+4}:4S_5$.

Using the improved combinatorial method described
in~\cite[Section~3.2]{BP98copy},
all possible permutation characters of degree $15\,400$ for the group $McL$
are computed.
(The method of~\cite[Section~3.3]{BP98copy} is slower but also needs only
a few seconds.)

\beginexample
gap> ly:= CharacterTable( "Ly" );;
gap> mcl:= CharacterTable( "McL" );;
gap> mcl2:= CharacterTable( "McL.2" );;
gap> 3mcl2:= CharacterTable( "3.McL.2" );;
gap> perms:= PermChars( mcl, rec( degree:= 15400 ) );
[ Character( CharacterTable( "McL" ), [ 15400, 56, 91, 10, 12, 25, 0, 11, 2,
      0, 0, 2, 1, 1, 1, 0, 0, 3, 0, 0, 1, 1, 1, 1 ] ),
  Character( CharacterTable( "McL" ), [ 15400, 280, 10, 37, 20, 0, 5, 10, 1,
      0, 0, 2, 1, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0 ] ) ]
\endexample

We get two characters, corresponding to the two classes of maximal
subgroups of index $15\,400$ in $McL$.
The permutation character $\pi = 1_{H \cap McL}^{McL}$ is the one with
nonzero value on the class `10A', since the subgroup of structure
$2S_5$ in $H \cap McL$ contains elements of order $10$.

\beginexample
gap> ord10:= Filtered( [ 1 .. NrConjugacyClasses( mcl ) ],
>                      i -> OrdersClassRepresentatives( mcl )[i] = 10 );
[ 15 ]
gap> List( perms, pi -> pi[ ord10[1] ] );
[ 1, 0 ]
gap> pi:= perms[1];
Character( CharacterTable( "McL" ), [ 15400, 56, 91, 10, 12, 25, 0, 11, 2, 0,
  0, 2, 1, 1, 1, 0, 0, 3, 0, 0, 1, 1, 1, 1 ] )
\endexample

The character $1_H^{McL.2}$ is an extension of $\pi$,
so we can use the method of~\cite[Section~3.3]{BP98copy} to compute all
possible permutation characters for the group $McL.2$ that have
the values of $\pi$ on the classes of $McL$.
We find that the extension of $\pi$ to a permutation character of $McL.2$
is unique.
Regarded as a character of $3.McL.2$, this character is equal to $1_U^S$.

\beginexample
gap> map:= InverseMap( GetFusionMap( mcl, mcl2 ) );
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, [ 10, 11 ], 12, [ 13, 14 ], 15, 16, 17, 18, 
  [ 19, 20 ], [ 21, 22 ], [ 23, 24 ] ]
gap> torso:= CompositionMaps( pi, map );
[ 15400, 56, 91, 10, 12, 25, 0, 11, 2, 0, 2, 1, 1, 0, 0, 3, 0, 1, 1 ]
gap> perms:= PermChars( mcl2, rec( torso:= torso ) );
[ Character( CharacterTable( "McL.2" ), [ 15400, 56, 91, 10, 12, 25, 0, 11, 
      2, 0, 2, 1, 1, 0, 0, 3, 0, 1, 1, 110, 26, 2, 4, 0, 0, 5, 2, 1, 1, 0, 0, 
      1, 1 ] ) ]
gap> pi:= Inflated( perms[1], 3mcl2 );
Character( CharacterTable( "3.McL.2" ), [ 15400, 15400, 56, 56, 91, 91, 10, 
  12, 12, 25, 25, 0, 0, 11, 11, 2, 2, 0, 0, 0, 2, 2, 1, 1, 1, 0, 0, 0, 0, 3, 
  3, 0, 0, 0, 1, 1, 1, 1, 1, 1, 110, 26, 2, 4, 0, 0, 5, 2, 1, 1, 0, 0, 1, 1 
 ] )
\endexample

The fusion of conjugacy classes of $S$ in $Ly$ can be computed from
the character tables of $S$ and $Ly$ given in~\cite{CCN85},
it is unique up to Galois automorphisms of the table of $Ly$.

\beginexample
gap> fus:= PossibleClassFusions( 3mcl2, ly );;  Length( fus );
4
gap> g:= AutomorphismsOfTable( ly );;
gap> OrbitLengths( g, fus, OnTuples );    
[ 4 ]
\endexample

Now we can induce $1_U^S$ to $Ly$, which yields $(1_U^S)^{Ly} = 1_U^{Ly}$.

\beginexample
gap> pi:= Induced( 3mcl2, ly, [ pi ], fus[1] )[1];
Character( CharacterTable( "Ly" ), [ 147934325000, 286440, 1416800, 1082, 
  784, 12500, 0, 672, 42, 24, 0, 40, 0, 2, 20, 0, 0, 0, 64, 10, 0, 50, 2, 0, 
  0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0 ] )
\endexample

All elements of odd order in $G$ are contained in $U$,
for such an element $g$ we have
\[ 1_G^{Ly}(g) = \frac{|C_{Ly}(g)|}{|G|} \cdot |G \cap Cl_{Ly}(g)|
   = \frac{|C_{Ly}(g)|}{2 \cdot |U|} \cdot |U \cap Cl_{Ly}(g)|
   = \frac{1}{2} \cdot 1_U^{Ly}(g) \ , \]
so we can prescribe the values of $1_G^{Ly}$ on all classes of odd
element order.
For elements $g$ of even order we have the weaker condition
$U\cap Cl_{Ly}(g) \subseteq G \cap Cl_{Ly}(g)$
and thus $1_G^{Ly}(g) \geq \frac{1}{2} \cdot 1_U^{Ly}(g)$,
which gives lower bounds for the value of $1_G^{Ly}$ on the
remaining classes.

\beginexample
gap> orders:= OrdersClassRepresentatives( ly );
[ 1, 2, 3, 3, 4, 5, 5, 6, 6, 6, 7, 8, 8, 9, 10, 10, 11, 11, 12, 12, 14, 15, 
  15, 15, 18, 20, 21, 21, 22, 22, 24, 24, 24, 25, 28, 30, 30, 31, 31, 31, 31, 
  31, 33, 33, 37, 37, 40, 40, 42, 42, 67, 67, 67 ]
gap> torso:= [];;                                   
gap> for i in [ 1 .. Length( orders ) ] do
>      if orders[i] mod 2 = 1 then
>        torso[i]:= pi[i]/2;
>      fi;
>    od;
gap> torso;
[ 73967162500,, 708400, 541,, 6250, 0,,,, 0,,, 1,,, 0, 0,,,, 25, 1, 0,,, 0, 0,
  ,,,,, 0,,,, 0, 0, 0, 0, 0, 0, 0, 0, 0,,,,, 0, 0, 0 ]
\endexample

Exactly one possible permutation character of $Ly$ satisfies these
conditions.

\beginexample
gap> perms:= PermChars( ly, rec( torso:= torso ) );;
gap> Length( perms );
43
gap> perms:= Filtered( perms, cand -> ForAll( [ 1 .. Length( orders ) ],
>        i -> cand[i] >= pi[i] / 2 ) );
[ Character( CharacterTable( "Ly" ), [ 73967162500, 204820, 708400, 541, 392, 
      6250, 0, 1456, 61, 25, 0, 22, 10, 1, 10, 0, 0, 0, 32, 5, 0, 25, 1, 0, 
      1, 2, 0, 0, 0, 0, 4, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 
      0, 0, 0, 0, 0 ] ) ]
\endexample

(The permutation character $1_G^{Ly}$ was used in the proof that the
character $\chi_{37}$ of $Ly$ (see~\cite[p.~175]{CCN85})
occurs with multiplicity at least 2 in each character of $Ly$
that is induced from a proper subgroup of $Ly$.)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Identifying two subgroups of ${\rm Aut}(U_3(5))$ (October~2001)}%
\label{U35sub}

According to the Atlas of Finite Groups~\cite[p.~34]{CCN85},
the group ${\rm Aut}(U_3(5))$ has two classes of maximal subgroups of
order $2^4 \cdot 3^3$, which have the structures $3^2 \colon 2S_4$ and
$6^2 \colon D_{12}$, respectively.

\beginexample
gap> tbl:= CharacterTable( "U3(5).3.2" );
CharacterTable( "U3(5).3.2" )
gap> deg:= Size( tbl ) / ( 2^4*3^3 );
1750
gap> pi:= PermChars( tbl, rec( torso:= [ deg ] ) );
[ Character( CharacterTable( "U3(5).3.2" ), [ 1750, 70, 13, 2, 0, 0, 1, 0, 0, 
      0, 10, 7, 10, 4, 2, 0, 0, 0, 0, 0, 0, 30, 10, 3, 0, 0, 1, 0, 0 ] ), 
  Character( CharacterTable( "U3(5).3.2" ), [ 1750, 30, 4, 6, 0, 0, 0, 0, 0, 
      0, 40, 7, 0, 6, 0, 0, 0, 0, 0, 0, 0, 20, 0, 2, 2, 0, 0, 0, 0 ] ) ]
\endexample

Now the question is which character belongs to which subgroup.
We see that the first character vanishes on the classes of element order
$8$ and the second does not, so only the first one can be the permutation
character induced from $6^2 \colon D_{12}$.

\beginexample
gap> ord8:= Filtered( [ 1 .. NrConjugacyClasses( tbl ) ],
>               i -> OrdersClassRepresentatives( tbl )[i] = 8 );
[ 9, 25 ]
gap> List( pi, x -> x{ ord8 } );
[ [ 0, 0 ], [ 0, 2 ] ]
\endexample

Thus the question is whether the second candidate is really a permutation
character.
Since none of the two candidates vanishes on any outer coset of
$U_3(5)$ in ${\rm Aut}(U_3(5))$, the point stabilizers are extensions
of groups of order $2^3 \cdot 3^2$ in $U_3(5)$.
The restrictions of the candidates to $U_3(5)$ are different,
so we can try to answer the question using information about this group.

\beginexample
gap> subtbl:= CharacterTable( "U3(5)" );
CharacterTable( "U3(5)" )
gap> rest:= RestrictedClassFunctions( pi, subtbl );
[ Character( CharacterTable( "U3(5)" ), [ 1750, 70, 13, 2, 0, 0, 0, 0, 1, 0, 
      0, 0, 0, 0 ] ), Character( CharacterTable( "U3(5)" ), 
    [ 1750, 30, 4, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ) ]
\endexample

The intersection of the $3^2 \colon 2S_4$ subgroup with $U_3(5)$ lies
inside the maximal subgroup of type $M_{10}$,
which does not contain elements of order$6$.
Only the second character has this property.

\beginexample
gap> ord6:= Filtered( [ 1 .. NrConjugacyClasses( subtbl ) ],
>               i -> OrdersClassRepresentatives( subtbl )[i] = 6 );
[ 9 ]
gap> List( rest, x -> x{ ord6 } );
[ [ 1 ], [ 0 ] ]
\endexample

In order to establish the two characters as permutation characters,
we could also compute the permutation characters of the degree in question
directly from the table of marks of $U_3(5)$, which is contained in the
{\GAP} library of tables of marks.

\beginexample
gap> tom:= TableOfMarks( "U3(5)" );
TableOfMarks( "U3(5)" )
gap> perms:= PermCharsTom( subtbl, tom );;
gap> Set( Filtered( perms, x -> x[1] = deg ) ) = Set( rest );
true
\endexample

We were mainly interested in the multiplicities of irreducible characters
in these characters.
The action of ${\rm Aut}(U_3(5)$ on the cosets of $3^2 \colon 2S_4$
turns out to be multiplicity-free whereas that on the cosets of
$6^2 \colon D_{12}$ is not.

\beginexample
gap> PermCharInfo( tbl, pi ).ATLAS;
[ "1a+21a+42a+84aac+105a+125a+126a+250a+252a+288bc", 
  "1a+42a+84ac+105ab+125a+126a+250a+252b+288bc" ]
\endexample

It should be noted that the restrictions of the multiplicity-free character
to the subgroups $U_3(5).2$ and $U_3(5).3$ of ${\rm Aut}(U_3(5)$ are not
multiplicity-free.

\beginexample
gap> subtbl2:= CharacterTable( "U3(5).2" );;
gap> rest2:= RestrictedClassFunctions( pi, subtbl2 );;
gap> PermCharInfo( subtbl2, rest2 ).ATLAS;
[ "1a+21aab+28aa+56aa+84a+105a+125aab+126aab+288aa", 
  "1a+21ab+28a+56a+84a+105ab+125aab+126a+252a+288aa" ]
gap> subtbl3:= CharacterTable( "U3(5).3" );;
gap> rest3:= RestrictedClassFunctions( pi, subtbl3 );;
gap> PermCharInfo( subtbl3, rest3 ).ATLAS;
[ "1a+21abc+84aab+105a+125abc+126abc+144bcef", 
  "1a+21bc+84ab+105aa+125abc+126adg+144bcef" ]
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{A Permutation Character of ${\rm Aut}(O_8^+(2))$ (October~2001)}%
\label{O82sub}

According to the Atlas of Finite Groups~\cite[p.~85]{CCN85},
the group $G = {\rm Aut}(O_8^+(2))$ has a class of maximal subgroups of
order $2^{13} \cdot 3^2$, thus the index of these subgroups in $G$ is
$3^4 \cdot 5^2 \cdot 7$.
The intersection of these subgroups with $H = O_8^+(2)$ lie inside maximal
subgroups of type $2^6 \colon A_8$.
We want to show that the permutation character of the action of $G$ on
the cosets of these subgroups is not multiplicity-free.

Since the table of marks for $H$ is available in {\GAP}, but not that for
$G$, we first compute the $H$-permutation characters of the intersections
with $H$ of index $3^4 \cdot 5^2 \cdot 7 = 14\,175$ subgroups in $G$.

(Note that these intersections have order $2^{12} \cdot 3$ because
subgroups of order $2^{12} \cdot 3^2$ are contained in $O_8^+(2).2$
and hence are not maximal in $G$.)

\beginexample
gap> t:= CharacterTable( "O8+(2).3.2" );;
gap> s:= CharacterTable( "O8+(2)" );;
gap> tom:= TableOfMarks( s );;
gap> perms:= PermCharsTom( s, tom );;
gap> deg:= 3^4*5^2*7;
14175
gap> perms:= Filtered( perms, x -> x[1] = deg );;
gap> Length( perms );
4
gap> Length( Set( perms ) );
1
\endexample

We see that there are four classes of subgroups $S$ in $H$ that may
belong to maximal subgroups of the desired index in $G$,
and that the permutation characters are equal.
They lead to such groups if they extend to $G$,
so we compute the possible permutation characters of $G$ that extend
these characters.

\beginexample
gap> fus:= PossibleClassFusions( s, t );
[ [ 1, 2, 3, 3, 3, 4, 5, 5, 5, 6, 7, 8, 9, 10, 10, 10, 11, 12, 12, 12, 13, 
      13, 13, 14, 14, 14, 15, 16, 16, 16, 17, 17, 17, 18, 19, 20, 21, 22, 22, 
      22, 23, 23, 23, 24, 24, 24, 25, 26, 26, 26, 27, 27, 27 ] ]
gap> fus:= fus[1];;
gap> inv:= InverseMap( fus );;
gap> comp:= CompositionMaps( perms[1], inv );
[ 14175, 1215, 375, 79, 0, 0, 27, 27, 99, 15, 7, 0, 0, 0, 0, 9, 3, 1, 0, 1, 
  1, 0, 0, 0, 0, 0, 0 ]
gap> ext:= PermChars( t, rec( torso:= comp ) );
[ Character( CharacterTable( "O8+(2).3.2" ), 
    [ 14175, 1215, 375, 79, 0, 0, 27, 27, 99, 15, 7, 0, 0, 0, 0, 9, 3, 1, 0, 
      1, 1, 0, 0, 0, 0, 0, 0, 63, 9, 15, 7, 1, 0, 3, 3, 3, 1, 0, 0, 1, 1, 
      945, 129, 45, 69, 21, 25, 13, 0, 0, 0, 9, 0, 3, 3, 7, 1, 0, 0, 0, 3, 1, 
      0, 0, 0, 0, 0, 0 ] ) ]
gap> PermCharInfo( t, ext[1] ).ATLAS;
[ "1a+50b+100a+252bb+300b+700b+972bb+1400a+1944a+3200b+4032b" ]
\endexample

Thus we get one permutation character of $G$ which is not multiplicity-free.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Two Primitive Permutation Characters of the Monster}%
\label{monsterperm}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Subgroup $2^2.2^{11}.2^{22}.(S_3 \times M_{24})$ (June~2009)}%
\label{monsterperm1}

\tthdump{\begin{tabular}{p{90mm}p{45mm}}}
%%tth: \begin{html} <table><tr><td width="65%"> \end{html}
According to the Atlas of Finite Groups~\cite[p.~234]{CCN85},
the Monster group $M$ has a class of maximal subgroups $H$ of the type
$2^2.2^{11}.2^{22}.(S_3 \times M_{24})$.
Currently the character table of $H$ and the class fusion into $M$
are not available in {\GAP},
but we are interested in the permutation character $1_H^G$.

The subgroup $H$ normalizes a Klein four group whose involutions lie in
the class `2B', so the index three subgroups of $H$ lie inside
`2B' normalizers in $M$, which have the structure $2^{1+24}_+.Co_1$.

Let $U$ denote an index three subgroup in $H$,
$Z$ denote the central subgroup of order $2$ in $U$,
and $N$ the normal subgroup of order $2^{25}$ in the centralizer $G$ of
$Z$ in $M$.
Then the order of $N U / N$ is a multiple of
$2^{2+11+22-25} \cdot 2 \cdot |M_{24}|$.
This is the order of a subgroup of $Co_1$.

The list of maximal subgroups of $Co_1$ (see~\cite[p.~183]{CCN85})
tells us that $NU / N$ is a maximal subgroup $K$ of $Co_1$
and has the structure $2^{11}:M_{24}$.
In particular, $U$ contains $N$ and thus $U/N \cong K$.

\tthdump{&}

%%tth: \begin{html} </td><td width="35%"> \end{html}
\begin{center}
%%tth: \includegraphics{ctblpope01.png}
%BP ctblpope01
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(30,50)(0,0)
\put(20,0){\circle*{1}} % trivial group
\put(20,5){\circle*{1}} \put(23,5){\makebox(0,0){$Z$}}
\put(20,10){\circle*{1}} % N \cap V
\put(25,15){\circle*{1}} \put(28,15){\makebox(0,0){$N$}}
\put(10,20){\circle*{1}} \put(7,20){\makebox(0,0){$V$}}
\put(15,25){\circle*{1}} \put(18,25){\makebox(0,0){$U$}}
\put(5,35){\circle*{1}} \put(2,35){\makebox(0,0){$G$}}
\put(20,30){\circle*{1}} \put(23,30){\makebox(0,0){$H$}}
\put(15,45){\circle*{1}} \put(15,48){\makebox(0,0){$M$}}
%
\put(20,0){\line(0,1){10}}
\put(20,10){\line(1,1){5}}
\put(20,10){\line(-1,1){10}}
\put(10,20){\line(1,1){10}}
\put(25,15){\line(-1,1){20}}
\put(5,35){\line(1,1){10}}
\put(20,30){\line(-1,3){5}}
\end{picture}}
%EP
\end{center}
\tthdump{\end{tabular}}
%%tth: \begin{html} </td></tr></table> \end{html}

\beginexample
gap> co1:= CharacterTable( "Co1" );;
gap> order:= 2^(2+11+22-25) * 2 * Size( CharacterTable( "M24" ) );
501397585920
gap> maxes:= List( Maxes( co1 ), CharacterTable );;
gap> filt:= Filtered( maxes, t -> Size( t ) mod order = 0 );
[ CharacterTable( "2^11:M24" ) ]
gap> k:= filt[1];;
\endexample

This means that we can compute the permutation character $\pi = 1_U^G$
by computing the primitive permutation character $1_K^{Co_1}$,
identifying it with $1_{U/N}^{G/N}$,
and then inflating this character to $G$.

\beginexample
gap> m:= CharacterTable( "M" );
CharacterTable( "M" )
gap> g:= CharacterTable( "MC2B" );
CharacterTable( "2^1+24.Co1" )
gap> pi:= RestrictedClassFunction( TrivialCharacter( k )^co1, g );;
\endexample

Next we consider the index $2$ subgroup $V$ of the type
$2^2.2^{11}.2^{22}.M_{24}$ in $U$;
we want to compute the permutation character $\psi = 1_V^G$.
The group $V$ does not contain $N$ because $K$ is perfect.
But $V$ contains $Z$ because otherwise $U$ would be a direct product
of $V$ and $Z$, which would imply that $N$ would be
a direct product of $V \cap N$ and $Z$.

Since $\psi(g) = [G:V] \cdot |g^G \cap V| / |g^G|$ holds for $g \in G$,
and since $g^G \cap V \subseteq g^G \cap U$,
with equality if $g$ has odd order,
we get $\psi(g) = 2 \cdot \pi(g)$ if $g$ has odd order,
and $\psi(g) = 0$ if $\pi(g) = 0$.

Moreover, $\psi$ is the inflation of $1_{V/Z}^{G/Z}$ from $G/Z$ to $G$,
so we can perform the computations with the character table of the
factor group $G/Z$.

\beginexample
gap> gmodz:= g / ClassPositionsOfCentre( g );
CharacterTable( "2^1+24.Co1/[ 1, 2 ]" )
gap> map:= InverseMap( GetFusionMap( g, gmodz ) );;
gap> pibar:= CompositionMaps( pi, map );
[ 8292375, 8292375, 8292375, 8292375, 32535, 32535, 32535, 32535, 32535, 
  32535, 4095, 4095, 1783, 1783, 1783, 1783, 1783, 1783, 0, 1701, 1701, 1701, 
  1701, 0, 0, 0, 135, 135, 135, 135, 135, 135, 231, 231, 231, 231, 231, 375, 
  375, 375, 375, 375, 375, 375, 375, 207, 207, 207, 207, 207, 207, 63, 63, 
  51, 51, 51, 51, 51, 51, 0, 75, 75, 75, 75, 0, 0, 0, 0, 0, 27, 27, 27, 0, 0, 
  0, 117, 117, 117, 117, 117, 117, 0, 0, 0, 19, 19, 19, 19, 19, 15, 15, 7, 7, 
  7, 7, 0, 14, 14, 14, 14, 14, 15, 15, 7, 7, 7, 7, 3, 3, 3, 11, 11, 11, 11, 
  11, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 
  15, 15, 5, 5, 5, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 9, 
  9, 9, 0, 15, 15, 15, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 9, 9, 9, 9, 0, 0, 3, 3, 
  3, 3, 3, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 0, 0, 0, 6, 6, 6, 6, 6, 0, 0, 0, 
  0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 2, 2, 2, 
  2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 3, 3, 0, 1, 1, 1, 0, 0, 0, 0, 
  0, 2, 2, 2, 2, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> orders:= OrdersClassRepresentatives( gmodz );;
gap> psibar:= [];;
gap> for i in [ 1 .. Length( pibar ) ] do
>   if pibar[i] = 0 then
>     psibar[i]:= 0;
>   elif orders[i] mod 2 = 1 then
>     psibar[i]:= pibar[i] * 2;
>   fi;
> od;
gap> psibar;
[ 16584750,,,,,,,,,,,,,,,,,, 0, 3402,,,, 0, 0, 0, 270,,,,,,,,,,,,,,,,,,,,,,,,,
  ,,,,,,,, 0, 150,,,, 0, 0, 0, 0, 0,,,, 0, 0, 0,,,,,,, 0, 0, 0,,,,,,,,,,,, 0, 
  28,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, 0, 0, 0, 0, 0, 0, 0, 0,,,,,, 0, 0, 0,,,,,
  , 6,,,,, 0, 0, 0, 0, 0,,,, 0,,,, 0, 0, 0, 0, 0,,,,,,,,,, 0, 0,,,,,, 0, 0,,,,
  ,,,,,, 0, 0, 0, 12,,,,, 0, 0, 0, 0,,,,,,, 0, 0, 0, 0, 0, 0,,,, 0, 0, 0, 0, 
  0, 0, 4,,,,,,,, 2,,,, 2,,,, 0, 0,,, 0,,,, 0, 0, 0, 0, 0,,,,, 0, 0, 0, 0,,,,
  , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
\endexample

These conditions suffice for computing $\psi$; it is the unique
possible permutation character of $G/Z$ that has the prescribed values.

\beginexample
gap> cand:= PermChars( gmodz, rec( torso:= psibar ) );
[ Character( CharacterTable( "2^1+24.Co1/[ 1, 2 ]" ), 
    [ 16584750, 8290350, 8294446, 8290350, 65070, 30510, 34350, 32302, 32526, 
      32558, 8190, 4094, 3566, 3566, 1742, 1806, 1774, 1782, 0, 3402, 1674, 
      1738, 1674, 0, 0, 0, 270, 126, 142, 270, 126, 142, 462, 206, 222, 238, 
      230, 750, 270, 462, 366, 390, 350, 382, 374, 414, 190, 222, 198, 214, 
      206, 126, 62, 102, 62, 50, 54, 46, 50, 0, 150, 70, 86, 70, 0, 0, 0, 0, 
      0, 54, 22, 30, 0, 0, 0, 234, 90, 138, 106, 114, 122, 0, 0, 0, 38, 38, 
      14, 22, 18, 30, 14, 14, 14, 6, 6, 0, 28, 20, 20, 12, 12, 30, 14, 14, 
      14, 6, 6, 6, 6, 2, 22, 6, 14, 10, 10, 30, 6, 22, 14, 18, 18, 10, 18, 
      14, 30, 14, 14, 0, 0, 0, 0, 0, 0, 0, 0, 30, 14, 10, 2, 6, 0, 0, 0, 6, 
      6, 6, 2, 2, 6, 6, 2, 2, 2, 0, 0, 0, 0, 0, 18, 6, 10, 0, 30, 14, 14, 0, 
      0, 0, 0, 0, 6, 6, 6, 2, 2, 18, 10, 6, 10, 0, 0, 6, 2, 6, 2, 2, 0, 0, 
      12, 4, 8, 8, 4, 4, 8, 8, 4, 0, 0, 0, 12, 4, 8, 8, 4, 0, 0, 0, 0, 2, 2, 
      0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 4, 0, 2, 2, 2, 
      2, 0, 0, 2, 0, 0, 2, 2, 0, 0, 2, 0, 0, 6, 2, 0, 2, 2, 0, 0, 0, 0, 0, 0, 
      4, 0, 2, 2, 0, 0, 0, 0, 4, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
     ] ) ]
gap> psi:= RestrictedClassFunction( cand[1], g );;
\endexample

% (if we would not prescribe the values except the degree then
% we would run into a backtrack with 39 constit. and 247 columns)

Now we use $\pi^M$ and $\psi^M$ for prescribing conditions on the values of
$1_H^M$.
Consider the factor group $F$ of the type $S_3$ of $H$.
Let $F_1$, $F_2$, $F_3$ denote its subgroups of the orders $1$, $2$,
and $3$, respectively.
The group $F$ is the disjoint union of $F_1$, $F_3 \setminus F_1$,
and the three $F$-conjugates of $F_2 \setminus F_1$.

Let $H'$ denote the index two subgroup of $H$, and let $g \in M$.
Then
\begin{eqnarray*}
  1_H^M(g) & = & [M:H] \cdot |g^M \cap H| / |g^M| \\
           & = & [M:H] \cdot \left( |g^M \cap V|
                             + 3 |g^M \cap U \setminus V|
                             + |g^M \cap H' \setminus V| \right) / |g^M| \\
           & = & [M:H] \cdot \left( 3 |g^M \cap U| - 2 |g^M \cap V|
                             + |g^M \cap H' \setminus V| \right) / |g^M| \\
           & = & 1_U^M(g) - 1/3 \cdot 1_V^G(g) + 
                    [M:H] \cdot |g^M \cap H' \setminus V| / |g^M| .
\end{eqnarray*}

So $1_H^M(g) \geq \pi^M(g) - \psi^M(g) / 3$,
with equality if the order of $g$ is not divisible by $3$,
or if $g^3$ is not contained in an $H$-conjugate of $U$;
the latter condition is satisfied if $\pi^M(g^3) = 0$.

We prescribe these values and lower bounds for $1_H^M$,

\beginexample
gap> mpi:= pi^m;;
gap> mpsi:= psi^m;;
gap> cand:= [];;
gap> lower:= [];;
gap> for i in [ 1 .. NrConjugacyClasses( m ) ] do
>   lower[i]:= mpi[i] - mpsi[i]/3;
>   if OrdersClassRepresentatives( m )[i] mod 3 <> 0 or
>      mpi[ PowerMap( m, 3 )[i] ] = 0 then
>     cand[i]:= lower[i];
>   fi;
> od;
gap> cand;
[ 16009115629875684006343550944921875, 7774182899642733721875, 
  120168544413337875,,,, 760550656275, 110042727795, 943894035, 568854195, 
  1851609375, 0,,,,,,, 874650, 0, 76995, 591163, 224055, 34955, 29539, 20727,,
  , 375375, 15775, 0, 0, 0, 495,,,,,,,,,,, 0, 0, 4410, 1498, 0,,,,, 83, 135, 
  31, 0,,,,,, 0, 255, 195, 0, 215, 0, 0,,,,, 35, 15, 1, 1, 109, 21, 0,, 11,,,,
  ,, 0, 0, 0, 0, 0, 98, 74, 42, 0, 0,, 90, 50, 0,, 0,, 0, 0, 1, 1,,, 0, 0, 0,,
  ,,, 0,,,,, 5, 3, 0, 0, 0,,,,, 3, 3,, 1, 1, 1, 1, 0, 0,, 0,, 0, 0,, 0, 2, 0, 
  0,, 0, 0,,,, 0,, 0, 0, 0,, 0, 0, 0, 0, 0, 0, 0, 0, 0,,,,,, 0, 0, 1, 1, 1, 1,
  ,, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
\endexample

Possible constituents of $1_H^M$ are those rational irreducible
characters of $M$ that are constituents of $\pi^M$.

\beginexample
gap> constit:= Filtered( rat:= RationalizedMat( Irr( m ) ),
>                        chi -> ScalarProduct( m, chi, mpi ) <> 0 );;
\endexample

Now we compute the possible permutation characters that
have the prescribed values,
are compatible with the given lower bounds for values,
and have only constituents in the given list.

\beginexample
gap> res:= PermChars( m, rec( torso:= cand, chars:= constit,
>                             lower:= lower,
>                             normalsubgroup:= [ 1 .. NrConjugacyClasses( m ) ],
>                             nonfaithful:= TrivialCharacter( m ) ) );
[ Character( CharacterTable( "M" ), [ 16009115629875684006343550944921875, 
      7774182899642733721875, 120168544413337875, 4436049512692980, 
      215448838605, 131873639625, 760550656275, 110042727795, 943894035, 
      568854195, 1851609375, 0, 4680311220, 405405, 78624756, 14467005, 
      178605, 248265, 874650, 0, 76995, 591163, 224055, 34955, 29539, 20727, 
      0, 0, 375375, 15775, 0, 0, 0, 495, 116532, 3645, 62316, 1017, 11268, 
      357, 1701, 45, 117, 705, 0, 0, 4410, 1498, 0, 3780, 810, 0, 0, 83, 135, 
      31, 0, 0, 0, 0, 0, 0, 0, 255, 195, 0, 215, 0, 0, 210, 0, 42, 0, 35, 15, 
      1, 1, 160, 48, 9, 92, 25, 9, 9, 5, 1, 21, 0, 0, 0, 0, 0, 98, 74, 42, 0, 
      0, 0, 120, 76, 10, 0, 0, 0, 0, 0, 1, 1, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 5, 3, 0, 0, 0, 18, 0, 10, 0, 3, 3, 0, 1, 1, 1, 1, 0, 0, 2, 
      0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 6, 12, 0, 0, 2, 0, 0, 0, 2, 0, 0, 
      1, 1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 0, 0 ] ) ]
\endexample

There is only one candidate, so we have found the permutation character.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Subgroup $2^3.2^6.2^{12}.2^{18}.(L_3(2) \times 3.S_6)$
(September~2009)}%
\label{monsterperm2}

\tthdump{\begin{tabular}{p{90mm}p{45mm}}}
%%tth: \begin{html} <table><tr><td width="65%"> \end{html}
According to the Atlas of Finite Groups~\cite[p.~234]{CCN85},
the Monster group $M$ has a class of maximal subgroups $H$ of the type
$2^3.2^6.2^{12}.2^{18}.(L_3(2) \times 3.S_6)$.
Currently the character table of $H$ and the class fusion into $M$
are not available in {\GAP},
but we are interested in the permutation character $1_H^G$.

The subgroup $H$ normalizes an elementary abelian group of order eight
whose involutions lie in the class `2B'.
The index seven subgroups of $H$ lie inside
`2B' normalizers in $M$, which have the structure $2^{1+24}_+.Co_1$.
% Note that there must be an orbit of odd length on the seven involutions,
% and there is no smaller nontrivial odd index than seven.

Let $U$ denote such an index seven subgroup in $H$,
$Z$ denote the central subgroup of order $2$ in $U$,
and $N$ the normal subgroup of order $2^{25}$ in the centralizer $G$ of
$Z$ in $M$.
Then the order of $N U / N$ is a multiple of
$2^{3+6+12+18-25} \cdot |L_3(2)| \cdot |3.S_6| / 7$.
This is the order of a subgroup of $Co_1$.

The list of maximal subgroups of $Co_1$ (see~\cite[p.~183]{CCN85})
tells us that $NU / N$ is a maximal subgroup $K$ of $Co_1$
and has the structure $2^{4+12}.(S_3 \times 3.S_6)$.
(Note that the group $O_8^+(2)$ has no proper subgroup of index $105$.)
In particular, $U$ contains $N$ and thus $U/N \cong K$.

\tthdump{&}

%%tth: \begin{html} </td><td width="35%"> \end{html}
\begin{center}
%%tth: \includegraphics{ctblpope02.png}
%BP ctblpope02
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(30,50)(0,0)
\put(20,0){\circle*{1}} % trivial group
\put(20,5){\circle*{1}} \put(23,5){\makebox(0,0){$Z$}}
\put(20,10){\circle*{1}} % N \cap V
\put(25,15){\circle*{1}} \put(28,15){\makebox(0,0){$N$}}
\put(15,15){\circle*{1}} \put(12,15){\makebox(0,0){$V$}}
\put(15,25){\circle*{1}} \put(18,25){\makebox(0,0){$U$}}
\put(20,20){\circle*{1}} \put(25,20){\makebox(0,0){$VN$}}
\put(5,35){\circle*{1}} \put(2,35){\makebox(0,0){$G$}}
\put(20,30){\circle*{1}} \put(23,30){\makebox(0,0){$H$}}
\put(15,45){\circle*{1}} \put(15,48){\makebox(0,0){$M$}}
%
\put(20,0){\line(0,1){10}}
\put(20,10){\line(1,1){5}}
\put(20,10){\line(-1,1){5}} % V cap N to V
\put(15,25){\line(1,1){5}}  % U to H
\put(15,15){\line(1,1){5}}  % V to VN
\put(25,15){\line(-1,1){20}}
\put(5,35){\line(1,1){10}}
\put(20,30){\line(-1,3){5}}
\end{picture}}
%EP
\end{center}
\tthdump{\end{tabular}}
%%tth: \begin{html} </td></tr></table> \end{html}

\beginexample
gap> co1:= CharacterTable( "Co1" );;
gap> order:= 2^(3+6+12+18-25) * 168 * 3 * Factorial( 6 ) / 7;
849346560
gap> maxes:= List( Maxes( co1 ), CharacterTable );;
gap> filt:= Filtered( maxes, t -> Size( t ) mod order = 0 );
[ CharacterTable( "2^(1+8)+.O8+(2)" ), CharacterTable( "2^(4+12).(S3x3S6)" ) ]
gap> List( filt, t -> Size( t ) / order );
[ 105, 1 ]
gap> o8p2:= CharacterTable( "O8+(2)" );;
gap> PermChars( o8p2, rec( torso:= [ 105 ] ) );
[  ]
gap> k:= filt[2];;
\endexample

This means that we can compute the permutation character $\pi = 1_U^G$
by computing the primitive permutation character $1_K^{Co_1}$,
identifying it with $1_{U/N}^{G/N}$,
and then inflating this character to $G$.

\beginexample
gap> m:= CharacterTable( "M" );
CharacterTable( "M" )
gap> g:= CharacterTable( "MC2B" );
CharacterTable( "2^1+24.Co1" )
gap> pi:= RestrictedClassFunction( TrivialCharacter( k )^co1, g );;
\endexample

The group $U$ has the structure $[2^{39}].(S_4 \times 3.S_6)$.
Let $V$ denote the subgroup of the structure $[2^{39}].3.S_6$ in $U$.
We have $H/V \cong L_3(2)$, $U/V \cong S_4$, and $U/VN \cong S_3$.

The permutation character $\psi = 1_{VN}^G$ can be computed as
the inflation of $1_{VN/N}^{G/N} = (1_{VN/N}^{U/N})^{G/N}$,
where $1_{VN/N}^{U/N}$ is a character of $K$ that can be
identified with the regular permutation character of $U/VN \cong S_3$.

\beginexample
gap> nsg:= ClassPositionsOfNormalSubgroups( k );;
gap> nsgsizes:= List( nsg, x -> Sum( SizesConjugacyClasses( k ){ x } ) );;
gap> nn:= nsg[ Position( nsgsizes, Size( k ) / 6 ) ];;
gap> psi:= 0 * [ 1 .. NrConjugacyClasses( k ) ];;
gap> for i in nn do
>      psi[i]:= 6;
>    od;
gap> psi:= InducedClassFunction( k, psi, co1 );;
gap> psi:= RestrictedClassFunction( psi, g );;
\endexample

Similarly, we compute the character $\sigma = 1_W^G$,
where $VN < W < U$, with $[U:W] = 3$.
(So we have $W/V \cong D_8$.)
We compute it from the character table of $K$,
as its unique possible permutation character of degree three.

\beginexample
gap> sigma:= PermChars( k, rec( torso:= [ 3 ] ) );;
gap> Length( sigma );
1
gap> sigma:= RestrictedClassFunction( sigma[1]^co1, g );;
\endexample

Next we consider the permutation character $\phi = 1_V^G$.
The group $V$ does not contain $N$ because $K$ does not have a factor group
of the type $S_4$.
But $V$ contains $Z$ because $U/V$ is centerless.
So we can regard $\phi$ as the inflation of $1_{V/Z}^{G/Z}$
from $G/Z$ to $G$,
i.~e., we can perform the computations with the character table of the
factor group $G/Z$.

\beginexample
gap> zclasses:= ClassPositionsOfCentre( g );;
gap> gmodz:= g / zclasses;
CharacterTable( "2^1+24.Co1/[ 1, 2 ]" )
gap> invmap:= InverseMap( GetFusionMap( g, gmodz ) );;
gap> psibar:= CompositionMaps( psi, invmap );;
\endexample

Since $\phi(g) = [G:V] \cdot |g^G \cap V| / |g^G|$ holds for $g \in G$,
and since $g^G \cap V \subseteq g^G \cap VN$,
with equality if $g$ has odd order,
we get $\phi(g) = 4 \cdot \psi(g)$ if $g$ has odd order,
and $\phi(g) = 0$ if $\psi(g) = 0$.

We want to compute the possible permutation characters with these
values.
This is easier if we ``go down'' from $VN$ to $V$ in two steps.

\beginexample
gap> factorders:= OrdersClassRepresentatives( gmodz );;
gap> phibar:= [];;
gap> upperphibar:= [];;
gap> for i in [ 1 .. NrConjugacyClasses( gmodz ) ] do
>      if factorders[i] mod 2 = 1 then
>        phibar[i]:= 2 * psibar[i];
>      elif psibar[i] = 0 then
>        phibar[i]:= 0;
>      else
>        upperphibar[i]:= 2 * psibar[i];
>      fi;
>    od;
gap> cand:= PermChars( gmodz, rec( torso:= phibar,
>             upper:= upperphibar,
>             normalsubgroup:= [ 1 .. NrConjugacyClasses( gmodz ) ],
>             nonfaithful:= TrivialCharacter( gmodz ) ) );;
gap> Length( cand );
3
\endexample

% This first step requires about 6.5 seconds.

One of the candidates computed in this first step is excluded by the fact
that it is induced from a subgroup that contains $N/Z$.

\beginexample
gap> nn:= First( ClassPositionsOfNormalSubgroups( gmodz ),
>                x -> Sum( SizesConjugacyClasses( gmodz ){x} ) = 2^24 );
[ 1 .. 4 ]
gap> cont:= PermCharInfo( gmodz, cand ).contained;;
gap> cand:= cand{ Filtered( [ 1 .. Length( cand ) ],
>                           i -> Sum( cont[i]{ nn } ) < 2^24 ) };;
gap> Length( cand );
2
\endexample

Now we run the second step.
After excluding the candidates that cannot be induced from subgroups
whose intersection with $N/Z$ has index four in $N/Z$,
we get four solutions.

\beginexample
gap> poss:= [];;
gap> for v in cand do
>      phibar:= [];
>      upperphibar:= [];
>      for i in [ 1 .. NrConjugacyClasses( gmodz ) ] do
>        if factorders[i] mod 2 = 1 then
>          phibar[i]:= 2 * v[i];
>        elif v[i] = 0 then
>          phibar[i]:= 0;
>        else
>          upperphibar[i]:= 2 * v[i];
>        fi;
>      od;
>      Append( poss, PermChars( gmodz, rec( torso:= phibar,
>                      upper:= upperphibar,
>                      normalsubgroup:= [ 1 .. NrConjugacyClasses( gmodz ) ],
>                      nonfaithful:= TrivialCharacter( gmodz ) ) ) );
>    od;
gap> Length( poss );
6
gap> cont:= PermCharInfo( gmodz, poss ).contained;;
gap> poss:= poss{ Filtered( [ 1 .. Length( poss ) ],
>                           i -> Sum( cont[i]{ nn } ) < 2^23 ) };;
gap> Length( poss );
4
gap> phicand:= RestrictedClassFunctions( poss, g );;
\endexample

% This needed about 40 seconds.

The last permutation character we are interested in is $\tau = 1_C^G$,
where $V < C < U$ and $C/V$ is a cyclic group of order four.
We may assume that $C$ is contained in $W$, of index two,
so we get the values of $\tau$ on elements of odd order from $\sigma$.

\beginexample
gap> sigmabar:= CompositionMaps( sigma, invmap );;
gap> taubar:= [];;
gap> uppertaubar:= [];;
gap> for i in [ 1 .. NrConjugacyClasses( gmodz ) ] do
>      if factorders[i] mod 2 = 1 then
>        taubar[i]:= 2 * sigmabar[i];
>      elif sigmabar[i] = 0 then
>        taubar[i]:= 0;
>      else
>        uppertaubar[i]:= 2 * sigmabar[i];
>      fi;
>    od;
gap> cand:= PermChars( gmodz, rec( torso:= taubar,
>             upper:= uppertaubar,
>             normalsubgroup:= [ 1 .. NrConjugacyClasses( gmodz ) ],
>             nonfaithful:= TrivialCharacter( gmodz ) ) );;
gap> Length( cand );
7
\endexample

We get seven solutions. Again, we exclude the candidates that are
induced from subgroups containing $N/Z$,
and we are left with four solutions.

\beginexample
gap> cont:= PermCharInfo( gmodz, cand ).contained;;
gap> cand:= cand{ Filtered( [ 1 .. Length( cand ) ],
>                           i -> Sum( cont[i]{ nn }) < 2^24 ) };;
gap> Length( cand );
4
gap> taucand:= RestrictedClassFunctions( cand, g );;
\endexample

Now we use the fact that any element $x \in H$ of order coprime to $7$
lies in an $H$-conjugate of $U$, because $x$ is the preimage
of an element in $L_3(2)$ that fixes at least one of the seven nonzero
vectors in the natural representation, and $U$ is the full stabilizer
in $H$ of such a vector.

\beginexample
gap> factgrp:= Action( GL(3,2), NormedRowVectors( GF(2)^3 ) );;
gap> List( ConjugacyClasses( factgrp ), Representative );
[ (), (4,5)(6,7), (2,3)(4,6,5,7), (2,4,6)(3,5,7), (1,2,4,3,6,7,5), 
  (1,2,4,5,7,3,6) ]
\endexample

More precisely, if we know the element orders in $L_3(2)$ of the images
of $x^M \cap U$ under the natural epimorphism $\theta\colon H \rightarrow H/V$
then we can compute $|x^M \cap H|$.

For example, if $x^M \cap U$ is empty and $x$ has order coprime to $7$
then also $x^M \cap H$ is empty.
If $x^M \cap U$ is contained in $V$ then also $x^M \cap H$ is contained
in $V$.
And if $x^M \cap U$ maps to elements of order three or four under
$\theta$ then $|x^M \cap H| = 7 |x^M \cap U|$
because each element in $x^M \cap H$ is contained in exactly one
$H$-conjugate of $U$,
since the elements of order three or four in $L_3(2)$ fix exactly one
of the seven vectors.

Using this idea systematically, we get the following.

\begin{eqnarray*}
%%%%%%%%%%%%%%%%%
   \left|\left\{ h \in x^M \cap H; |\theta(h)| = 4 \right\}\right| & = &
         7 \cdot \left|\left\{ h \in x^M \cap U; |\theta(h)| = 4 \right\}\right| \\
   & = & 21 \cdot \left|\left\{ h \in x^M \cap C; |\theta(h)| = 4 \right\}\right| \\
   & = & 21 \cdot \left( |x^M \cap C| - |x^M \cap C \cap VN| \right) \\
   & = & 21 \cdot |x^M \cap C|
         - 21 \cdot \left( |x^M \cap V| + 1/3 \cdot |x^M \cap VN \setminus V| \right) \\
   & = & 21 \cdot |x^M \cap C|
         - 21 \cdot \left( |x^M \cap V| + 1/3 \cdot |x^M \cap VN| - 1/3 \cdot |x^M \cap V| \right) \\
   & = & 21 \cdot |x^M \cap C| - 7 \cdot |x^M \cap VN| - 14 \cdot |x^M \cap V| , \\
%%%%%%%%%%%%%%%%%
   \left|\left\{ h \in x^M \cap H; |\theta(h)| = 3 \right\}\right| & = &
         7 \cdot \left|\left\{ h \in x^M \cap U; |\theta(h)| = 3 \right\}\right| \\
   & = & 7 \cdot \left( |x^M \cap U| - |x^M \cap \bigcup_{g \in U} W^g| \right) \\
   & = & 7 \cdot |x^M \cap U| - 21 \cdot |x^M \cap W| + 14 \cdot |x^M \cap VN| , \\
%%%%%%%%%%%%%%%%%
   \left|\left\{ h \in x^M \cap H; |\theta(h)| = 2 \right\}\right| & = &
   7/3 \cdot\left|\left\{ h \in x^M \cap U; |\theta(h)| = 2 \right\}\right| \\
   & = &
   7/3 \cdot \left( 3 \cdot |x^M \cap W| - 2 \cdot |x^M \cap VN| - |x^M \cap V| \right. \\
   &   & \left. - 3 \cdot \left|\left\{ h \in x^M \cap W; |\theta(h)| = 4 \right\}\right| \right) \\
   & = &
   7 \cdot |x^M \cap W| - 14/3 \cdot |x^M \cap VN| - 7/3 \cdot |x^M \cap V| \\
   &   & - 7 \cdot \left|\left\{ h \in x^M \cap C; |\theta(h)| = 4 \right\}\right| \\
   & = &
   7 \cdot |x^M \cap W| - 14/3 \cdot |x^M \cap VN| - 7/3 \cdot |x^M \cap V|
               - 7 \cdot |x^M \cap C| \\
   &   & + 7/3 \cdot |x^M \cap VN| + 14/3 \cdot |x^M \cap V| \\
   & = &
   7 \cdot |x^M \cap W| - 7/3 \cdot |x^M \cap VN|
   - 7 \cdot |x^M \cap C| + 7/3 \cdot |x^M \cap V| , \\
   \mbox{\rm and} & & \\
%%%%%%%%%%%%%%%%%
   \left|\left\{ h \in x^M \cap H; |\theta(h)| = 1 \right\}\right|
   & = &
   |x^M \cap V| .
\end{eqnarray*}

So

\begin{eqnarray*}
   |x^M \cap H| & = &
         \sum_{n = 1}^4
           \left|\left\{ h \in x^M \cap H; |\theta(h)| = n \right\}\right| \\
   & = & - \frac{32}{3} \cdot |x^M \cap V|
         + \frac{14}{3} \cdot |x^M \cap VN|
           + 14 \cdot |x^M \cap C|
           - 14 \cdot |x^M \cap W|
            + 7 \cdot |x^M \cap U|
\end{eqnarray*}

and thus

\begin{eqnarray*}
   1_H^M(x) & = & -\frac{4}{63} \cdot 1_V^M(x) + \frac{1}{9} \cdot 1_{VN}^M(x)
                  + \frac{1}{3} \cdot 1_C^M(x) - \frac{2}{3} \cdot 1_W^M(x)
                  + 1_U^M(x).
\end{eqnarray*}

Since we have several candidates for $1_V^G$ and $1_C^G$,
we form the linear combinations for all these candidates.

\beginexample
gap> phicand:= InducedClassFunctions( phicand, m );;
gap> psi:= psi^m;;
gap> taucand:= InducedClassFunctions( taucand, m );;
gap> sigma:= sigma^m;;
gap> pi:= pi^m;;
gap> cand:= [];;
gap> for phi in phicand do
>   for tau in taucand do
>     Add( cand, ShallowCopy( -32/(3*168) * phi + 1/9 * psi + 1/3 * tau
>                             - 2/3 * sigma + pi ) );
>   od;
> od;
gap> morders:= OrdersClassRepresentatives( m );;
gap> for x in cand do
>   for i in [ 1 .. Length( morders ) ] do
>     if morders[i] mod 7 = 0 then
>       Unbind( x[i] );
>     fi;
>   od;
> od;
\endexample

Only one of these candidates has only integral values.

\beginexample
gap> cand:= Filtered( cand, x -> ForAll( x, IsInt ) );
[ [ 4050306254358548053604918389065234375, 148844831270071996434375, 
      2815847622206994375, 14567365753025085, 3447181417680, 659368198125, 
      3520153823175, 548464353255, 5706077895, 3056566695, 264515625, 0, 
      19572895485, 6486480, 186109245, 61410960, 758160, 688365,,, 172503, 
      1264351, 376155, 137935, 99127, 52731, 0, 0, 119625, 3625, 0, 0, 0, 0, 
      402813, 29160, 185301, 2781, 21069, 1932, 4212, 360, 576, 1125, 0, 0,,,
      , 2160, 810, 0, 0, 111, 179, 43, 0, 0, 0, 0, 0, 0, 0, 185, 105, 0, 65, 
      0, 0,,,,, 0, 0, 0, 0, 337, 105, 36, 157, 37, 18, 18, 16, 4, 21, 0, 0, 
      0, 0, 0,,,,, 0, 0, 60, 40, 10, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0,,, 0, 0, 0, 
      0, 0, 0, 0, 0, 0, 5, 1, 0, 0, 0,,,,, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 
      0, 0, 0, 0, 0,,,, 0, 0, 0, 6, 8, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0,,, 0, 
      0, 0, 0, 0,,,, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,, 0 ] ]
\endexample
 
Possible constituents of $1_H^M$ are those rational irreducible
characters of $M$ that are constituents of $\pi^M$.

\beginexample
gap> constit:= Filtered( RationalizedMat( Irr( m ) ),
>                        chi -> ScalarProduct( m, chi, pi ) <> 0 );;
\endexample

Now we compute the possible permutation characters that
have the prescribed values
and have only constituents in the given list.

\beginexample
gap> cand:= PermChars( m, rec( torso:= cand[1], chars:= constit ) );
[ Character( CharacterTable( "M" ), [ 4050306254358548053604918389065234375, 
      148844831270071996434375, 2815847622206994375, 14567365753025085, 
      3447181417680, 659368198125, 3520153823175, 548464353255, 5706077895, 
      3056566695, 264515625, 0, 19572895485, 6486480, 186109245, 61410960, 
      758160, 688365, 58310, 0, 172503, 1264351, 376155, 137935, 99127, 
      52731, 0, 0, 119625, 3625, 0, 0, 0, 0, 402813, 29160, 185301, 2781, 
      21069, 1932, 4212, 360, 576, 1125, 0, 0, 1302, 294, 0, 2160, 810, 0, 0, 
      111, 179, 43, 0, 0, 0, 0, 0, 0, 0, 185, 105, 0, 65, 0, 0, 224, 0, 14, 
      0, 0, 0, 0, 0, 337, 105, 36, 157, 37, 18, 18, 16, 4, 21, 0, 0, 0, 0, 0, 
      70, 38, 14, 0, 0, 0, 60, 40, 10, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 10, 0, 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1, 0, 0, 0, 24, 0, 6, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 6, 8, 0, 0, 2, 0, 0, 
      0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 4, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 0, 0, 4, 0, 0, 0 ] ) ]
\endexample

There is only one candidate, so we have found the permutation character.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\tthdump{\addcontentsline{toc}{section}{References}}

\bibliographystyle{amsalpha}
\bibliography{manualbib.xml,../../../doc/manualbib.xml,../../atlasrep/doc/manualbib.xml}

% gap> STOP_TEST( "ctblpope.tst", 6129230950 );

\end{document}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%E

