%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%W  ambigfus.xpl              GAP applications              Thomas Breuer
%%
%H  @(#)$Id: ambigfus.xpl,v 1.18 2011/01/26 18:24:05 gap Exp $
%%
%Y  Copyright 2003,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,   Germany
%%
%X  NAME="ambigfus"
%X  rm -rf doc/$NAME.tex
%X  etc/xpl2tst xpl/$NAME.xpl tst/$NAME.tst ctbllib
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

\textwidth16cm
\oddsidemargin0pt

\parskip 1ex plus 0.5ex minus 0.5ex
\parindent0pt

\hfuzz 3pt

\usepackage{amssymb}

% Miscellaneous macros.
\def\GAP{\textsf{GAP}}
\def\ATLAS{\textsc{Atlas}}
\def\Irr{{\rm Irr}}
\def\PGL{{\rm PGL}}
%%tth: \font\mathbb=msbm10
\def\N{{\mathbb N}} \def\Z{{\mathbb Z}} \def\Q{{\mathbb Q}}
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

\tthdump{\title{Ambiguous Class Fusions in the {\GAP} Character Table Library}}
%%tth: \title{Ambiguous Class Fusions in the GAP Character Table Library}
%%tth: \begin{html} <body bgcolor="FFFFFF"> \end{html}

\author{\textsc{Thomas Breuer} \\[0.5cm]
\textit{Lehrstuhl D f{\"u}r Mathematik} \\
\textit{RWTH, 52056 Aachen, Germany}}

\date{January 11th, 2004}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\maketitle


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\abstract{
This is a collection of examples showing how class fusions between character
tables can be determined using the {\GAP} system~\cite{GAP4}.
In each of these examples, the fusion is \emph{ambiguous} in the sense that
the character tables do not determine it up to table automorphisms.
Our strategy is to compute first all possibilities with the {\GAP} function
`PossibleClassFusions', and then to use either other character tables or
information about the groups for excluding some of these candidates until
only one (orbit under table automorphisms) remains.

The purpose of this writeup is twofold.
On the one hand, the computations are documented this way.
On the other hand, the {\GAP} code shown for the examples can be used as
test input for automatic checking of the data and the functions used;
therefore, each example ends with a comparison of the result with the
fusion that is actually stored in
the {\GAP} Character Table Library~\cite{CTblLib1.1.3}.}

% using `\abstract' seems to reset `\parskip' and `parindent' ...
\textwidth16cm
\oddsidemargin0pt

\parskip 1ex plus 0.5ex minus 0.5ex
\parindent0pt


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\tableofcontents

% gap> START_TEST("$Id: ambigfus.xpl,v 1.18 2011/01/26 18:24:05 gap Exp $");


The examples use the {\GAP} Character Table Library,
so we first load this package.

\beginexample
gap> LoadPackage( "ctbllib" );
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Some {\GAP} Utilities}

The function `SetOfComposedClassFusions' takes two list of class fusions,
where the first list consists of fusions between the character tables of
the groups $H$ and $G$, say,
and the second list consists of class fusions between the character tables
of the groups $U$ and $H$, say;
the return value is the set of compositions of each map in the first list
with each map in the second list (via `CompositionMaps').

Note that the returned list may be a proper subset of the set of
all possible class fusions between $U$ and $G$,
which can be computed with `PossibleClassFusions'.

\beginexample
gap> SetOfComposedClassFusions:= function( hfusg, ufush )
>     local result, map1, map2;
>     result:= [];;
>     for map2 in hfusg do
>       for map1 in ufush do
>         AddSet( result, CompositionMaps( map2, map1 ) );
>       od;
>     od;
>     return result;
> end;;
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Fusions Determined by Factorization through Intermediate Subgroups}

This situation clearly occurs only for nonmaximal subgroups.
Interesting examples are Sylow normalizers.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$Co_3N5 \rightarrow Co_3$ (September 2002)}

Let $H$ be the Sylow $5$ normalizer in the sporadic simple group $Co_3$.
The class fusion of $H$ into $Co_3$ is not uniquely determined by the
character tables of the two groups.

\beginexample
gap> co3:= CharacterTable( "Co3" );
CharacterTable( "Co3" )
gap> h:= CharacterTable( "Co3N5" );
CharacterTable( "5^(1+2):(24:2)" )
gap> hfusco3:= PossibleClassFusions( h, co3 );;
gap> Length( RepresentativesFusions( h, hfusco3, co3 ) );
2
\endexample

As $H$ is not maximal in $Co_3$, we look at those maximal subgroups of $Co_3$
whose order is divisible by that of $H$.

\beginexample
gap> mx:= Maxes( co3 );
[ "McL.2", "HS", "U4(3).(2^2)_{133}", "M23", "3^5:(2xm11)", "2.S6(2)", 
  "U3(5).3.2", "3^1+4:4s6", "2^4.a8", "L3(4).D12", "2xm12", 
  "2^2.(2^7.3^2).s3", "s3xpsl(2,8).3", "a4xs5" ]
gap> maxes:= List( mx, CharacterTable );;
gap> filt:= Filtered( maxes, x -> Size( x ) mod Size( h ) = 0 );
[ CharacterTable( "McL.2" ), CharacterTable( "HS" ), 
  CharacterTable( "U3(5).3.2" ) ]
\endexample

According to the {\ATLAS} (see~\cite[pp.~34 and~100]{CCN85}),
$H$ occurs as the Sylow $5$ normalizer in $U_3(5).3.2$ and in $McL.2$;
however, $H$ is not a subgroup of $HS$,
since otherwise $H$ would be contained in subgroups of type $U_3(5).2$
(see~\cite[p.~80]{CCN85}), but the only possible subgroups
in these groups are too small (see~\cite[p.~34]{CCN85}).

We compute the possible class fusions from $H$ into $McL.2$
and from $McL.2$ to $Co_3$, and then form the compositions of these maps.

\beginexample
gap> max:= filt[1];;
gap> hfusmax:= PossibleClassFusions( h, max );;
gap> maxfusco3:= PossibleClassFusions( max, co3 );;
gap> comp:= SetOfComposedClassFusions( maxfusco3, hfusmax );;
gap> Length( comp );
2
gap> reps:= RepresentativesFusions( h, comp, co3 );
[ [ 1, 2, 3, 4, 8, 8, 7, 9, 10, 11, 17, 17, 19, 19, 22, 23, 27, 27, 30, 33, 
      34, 40, 40, 40, 40, 42 ] ]
\endexample

So factoring through a maximal subgroup of type $McL.2$
determines the fusion from $H$ to $Co_3$ uniquely up to table automorphisms.

Alternatively, we can use the group $U_3(5).3.2$ as intermediate
subgroup, which leads to the same result.

\beginexample
gap> max:= filt[3];;
gap> hfusmax:= PossibleClassFusions( h, max );;
gap> maxfusco3:= PossibleClassFusions( max, co3 );;
gap> comp:= SetOfComposedClassFusions( maxfusco3, hfusmax );;
gap> reps2:= RepresentativesFusions( h, comp, co3 );;
gap> reps2 = reps;
true
\endexample

Finally, we compare the result with the map that is stored on the library
table of $H$.

\beginexample
gap> GetFusionMap( h, co3 ) in reps;
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$31:15 \rightarrow B$ (March 2003)}

The Sylow $31$ normalizer $H$ in the sporadic simple group $B$
has the structure $31:15$.

\beginexample
gap> b:= CharacterTable( "B" );;
gap> h:= CharacterTable( "31:15" );;
gap> hfusb:= PossibleClassFusions( h, b );;
gap> Length( RepresentativesFusions( h, hfusb, b ) );
2
\endexample

We determine the correct fusion using the fact that
$H$ is contained in a (maximal) subgroup of type $Th$ in $B$.

\beginexample
gap> th:= CharacterTable( "Th" );;
gap> hfusth:= PossibleClassFusions( h, th );;
gap> thfusb:= PossibleClassFusions( th, b );;
gap> comp:= SetOfComposedClassFusions( thfusb, hfusth );;
gap> Length( comp );
2
gap> reps:= RepresentativesFusions( h, comp, b );
[ [ 1, 145, 146, 82, 82, 19, 82, 7, 19, 82, 82, 19, 7, 82, 19, 82, 82 ] ]
gap> GetFusionMap( h, b ) in reps;
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$SuzN3 \rightarrow Suz$ (September 2002)}

The class fusion from the Sylow $3$ normalizer into the sporadic simple group
$Suz$ is not uniquely determined by the character tables of these groups.

\beginexample
gap> h:= CharacterTable( "SuzN3" );
CharacterTable( "3^5:(3^2:SD16)" )
gap> suz:= CharacterTable( "Suz" );
CharacterTable( "Suz" )
gap> hfussuz:= PossibleClassFusions( h, suz );;
gap> Length( RepresentativesFusions( h, hfussuz, suz ) );
2
\endexample

Since $H$ is not maximal in $Suz$, we try to factorize the fusion through
a suitable maximal subgroup.

\beginexample
gap> maxes:= List( Maxes( suz ), CharacterTable );;
gap> filt:= Filtered( maxes, x -> Size( x ) mod Size( h ) = 0 );
[ CharacterTable( "3_2.U4(3).2_3'" ), CharacterTable( "3^5:M11" ), 
  CharacterTable( "3^2+4:2(2^2xa4)2" ) ]
\endexample

The group $3_2.U_4(3).2_3^{\prime}$ does not admit a fusion from $H$.

\beginexample
gap> PossibleClassFusions( h, filt[1] );
[  ]
\endexample

Definitely $3^5:M_{11}$ contains a group isomorphic with $H$,
because the Sylow $3$ normalizer in $M_{11}$ has the structure $3^2:SD_{16}$;
using $3^{2+4}:2(2^2 \times A_4)2$ would lead to the same result as
we get below.
We compute the compositions of possible class fusions.

\beginexample
gap> max:= filt[2];;
gap> hfusmax:= PossibleClassFusions( h, max );;
gap> maxfussuz:= PossibleClassFusions( max, suz );;
gap> comp:= SetOfComposedClassFusions( maxfussuz, hfusmax );;
gap> repr:= RepresentativesFusions( h, comp, suz );
[ [ 1, 2, 2, 4, 5, 4, 5, 5, 5, 5, 5, 6, 9, 9, 14, 15, 13, 16, 16, 14, 15, 13, 
      13, 13, 16, 15, 14, 16, 16, 16, 21, 21, 23, 22, 29, 29, 29, 38, 39 ] ]
\endexample

So the factorization determines the fusion map up to table automorphisms.
We check that this map is equal to the stored one.

\beginexample
gap> GetFusionMap( h, suz ) in repr;
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$F_{3+}N5 \rightarrow F_{3+}$ (March 2002)}

The class fusion from the table of the Sylow $5$ normalizer $H$ in the
sporadic simple group $F_{3+}$ into $F_{3+}$ is ambiguous.

\beginexample
gap> f3p:= CharacterTable( "F3+" );;
gap> h:= CharacterTable( "F3+N5" );;
gap> hfusf3p:= PossibleClassFusions( h, f3p );;
gap> Length( RepresentativesFusions( h, hfusf3p, f3p ) );
2
\endexample

$H$ is not maximal in $F_{3+}$,
so we look for tables of maximal subgroups that can contain $H$.

\beginexample
gap> maxes:= List( Maxes( f3p ), CharacterTable );;
gap> filt:= Filtered( maxes, x -> Size( x ) mod Size( h ) = 0 );
[ CharacterTable( "Fi23" ), CharacterTable( "2.Fi22.2" ), 
  CharacterTable( "(3xO8+(3):3):2" ), CharacterTable( "O10-(2)" ), 
  CharacterTable( "(A4xO8+(2).3).2" ), CharacterTable( "He.2" ), 
  CharacterTable( "F3+M14" ), CharacterTable( "(A5xA9):2" ) ]
gap> possfus:= List( filt, x -> PossibleClassFusions( h, x ) );
[ [  ], [  ], [  ], [  ], 
  [ [ 1, 69, 110, 12, 80, 121, 4, 72, 113, 11, 11, 79, 79, 120, 120, 3, 71, 
          11, 79, 23, 91, 112, 120, 132, 29, 32, 97, 100, 37, 37, 105, 105, 
          139, 140, 145, 146, 155, 155, 156, 156, 44, 44, 167, 167, 48, 48, 
          171, 171, 57, 57, 180, 180, 66, 66, 189, 189 ], 
      [ 1, 69, 110, 12, 80, 121, 4, 72, 113, 11, 11, 79, 79, 120, 120, 3, 71, 
          11, 79, 23, 91, 112, 120, 132, 29, 32, 97, 100, 37, 37, 105, 105, 
          140, 139, 146, 145, 156, 156, 155, 155, 44, 44, 167, 167, 48, 48, 
          171, 171, 57, 57, 180, 180, 66, 66, 189, 189 ] ], [  ], [  ], [  ] ]
\endexample

We see that from the eight possible classes of maximal subgroups in $F_{3+}$
that might contain $H$, only the group of type $(A_4 \times O_8^+(2).3).2$
admits a class fusion from $H$.
Hence we can compute the compositions of the possible fusions from $H$ into
this group with the possible fusions from this group into $F_{3+}$.

\beginexample
gap> max:= filt[5];
CharacterTable( "(A4xO8+(2).3).2" )
gap> hfusmax:= possfus[5];;
gap> maxfusf3p:= PossibleClassFusions( max, f3p );;
gap> comp:= SetOfComposedClassFusions( maxfusf3p, hfusmax );;
gap> Length( comp );
2
gap> repr:= RepresentativesFusions( h, comp, f3p );
[ [ 1, 2, 4, 12, 35, 54, 3, 3, 16, 9, 9, 11, 11, 40, 40, 2, 3, 9, 11, 35, 36, 
      13, 40, 90, 7, 22, 19, 20, 43, 43, 50, 50, 8, 8, 23, 23, 46, 46, 47, 
      47, 10, 10, 9, 9, 10, 10, 11, 11, 26, 26, 28, 28, 67, 67, 68, 68 ] ]
\endexample

Finally, we check whether the map stored in the table library is correct.

\beginexample
gap> GetFusionMap( h, f3p ) in repr;
true
\endexample

Note that we did *not* determine the class fusion from the maximal subgroup
$(A_4 \times O_8^+(2).3).2$ into $F_{3+}$ up to table automorphisms
(see Section~\ref{A4xO8p2d32fusf3p} for this problem),
since also the ambiguous result was enough for computing the fusion from
$H$ into $F_{3+}$.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Fusions Determined Using Commutative Diagrams Involving Smaller
Subgroups}

\tthdump{\begin{tabular}{p{90mm}p{45mm}}}
%%tth: \begin{html} <table><tr><td width="75%"> \end{html}
In each of the following examples, the class fusion of a (not necessarily
maximal) subgroup $M$ of a group $G$ into $G$ is determined
by considering a proper subgroup $U$ of $M$
whose class fusion into $G$ can be computed, perhaps using another subgroup
$S$ of $G$ that also contains $U$.

\tthdump{&}
%%tth: \begin{html} </td><td width="25%"> \end{html}

\begin{center}
%%tth: \includegraphics{ambigfus1.png}
%BP ambigfus1
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(40,20)(-10,0)
\put(10, 5){\circle*{1}} % trivial group
\put(10,10){\circle{1}} \put(13,10){\makebox(0,0){$U$}}
\put(10,15){\circle{1}}  % intersection of M and S
\put( 5,20){\circle{1}} \put(2,20){\makebox(0,0){$M$}}
\put(15,20){\circle{1}} \put(17,20){\makebox(0,0){$S$}}
\put(10,25){\circle*{1}} \put(10,28){\makebox(0,0){$G$}}
\put(10, 5){\line(0,1){10}}
\put(10,15){\line(-1,1){5}}
\put(10,15){\line(1,1){5}}
\put( 5,20){\line(1,1){5}}
\put(15,20){\line(-1,1){5}}
\end{picture}}
%EP
\end{center}

\tthdump{\end{tabular}}
%%tth: \begin{html} </td></tr></table> \end{html}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$BN7 \rightarrow B$ (March 2002)}\label{BN7}

Let $H$ be a Sylow $7$ normalizer in the sporadic simple group $B$.
The class fusion of $H$ into $B$ is not uniquely determined by the
character tables of the two groups.

\beginexample
gap> b:= CharacterTable( "B" );
CharacterTable( "B" )
gap> h:= CharacterTable( "BN7" );
CharacterTable( "BN7" )
gap> hfusb:= PossibleClassFusions( h, b );;
gap> Length( RepresentativesFusions( h, hfusb, b ) );
2
\endexample

Let us consider a maximal subgroup of the type $Th$ in $B$
(cf.~\cite[p.~217]{CCN85}).
By~\cite[p.~177]{CCN85},
the Sylow $7$ normalizers in $Th$ are maximal subgroups of $Th$
and have the structure $7^2:(3 \times 2S_4)$.
Let $U$ be such a subgroup.

Note that the only maximal subgroups of $Th$ whose order is divisible by
the order of a Sylow $7$ subgroup of $B$ have the types ${}^3D_4(2).3$
and $7^2:(3 \times 2S_4)$,
and the Sylow $7$ normalizers in the former groups have the structure
$7^2:(3 \times 2A_4)$, cf.~\cite[p.~89]{CCN85}.

\beginexample
gap> Number( Factors( Size( b ) ), x -> x = 7 );
2
gap> th:= CharacterTable( "Th" );
CharacterTable( "Th" )
gap> Filtered( Maxes( th ), x -> Size( CharacterTable( x ) ) mod 7^2 = 0 );
[ "3D4(2).3", "7^2:(3x2S4)" ]
\endexample

The class fusion of $U$ into $B$ via $Th$ is uniquely determined by the
character tables of these groups.

\beginexample
gap> thn7:= CharacterTable( "ThN7" );
CharacterTable( "7^2:(3x2S4)" )
gap> comp:= SetOfComposedClassFusions( PossibleClassFusions( th, b ),
>               PossibleClassFusions( thn7, th ) );
[ [ 1, 31, 7, 7, 5, 28, 28, 17, 72, 72, 6, 6, 7, 28, 27, 27, 109, 109, 17, 
      45, 45, 72, 72, 127, 127, 127, 127 ] ]
\endexample

The condition that the class fusion of $U$ into $B$ factors through $H$
determines the class fusion of $H$ into $B$ up to table automorphisms.

\beginexample
gap> thn7fush:= PossibleClassFusions( thn7, h );;
gap> filt:= Filtered( hfusb, x ->
>               ForAny( thn7fush, y -> CompositionMaps( x, y ) in comp ) );;
gap> Length( RepresentativesFusions( h, filt, b ) );
1
\endexample

Finally, we compare the result with the map that is stored on the library
table of $H$.

\beginexample
gap> GetFusionMap( h, b ) in filt;
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$(A_4 \times O_8^+(2).3).2 \rightarrow Fi_{24}^{\prime}$
(November 2002)}\label{A4xO8p2d32fusf3p}

The class fusion of the maximal subgroup $M \cong (A_4 \times O_8^+(2).3).2$
of $G = Fi_{24}^{\prime}$ is ambiguous.

\beginexample
gap> m:= CharacterTable( "(A4xO8+(2).3).2" );;
gap> t:= CharacterTable( "F3+" );;
gap> mfust:= PossibleClassFusions( m, t );;
gap> repr:= RepresentativesFusions( m, mfust, t );;
gap> Length( repr );
2
\endexample

We first observe that the elements of order three in the normal subgroup
of type $A_4$ in $M$ lie in the class `3A' of $Fi_{24}^{\prime}$.

\beginexample
gap> a4inm:= Filtered( ClassPositionsOfNormalSubgroups( m ),
>                      n -> Sum( SizesConjugacyClasses( m ){ n } ) = 12 );
[ [ 1, 69, 110 ] ]
gap> OrdersClassRepresentatives( m ){ a4inm[1] };
[ 1, 2, 3 ]
gap> List( repr, map -> map[110] );
[ 4, 4 ]
gap> OrdersClassRepresentatives( t ){ [ 1 .. 4 ] };
[ 1, 2, 2, 3 ]
\endexample

Let us take one such element $g$, say.
Its normalizer $S$ in $G$ has the structure $(3 \times O_8^+(3).3).2$;
this group is maximal in $G$, and its character table is available in {\GAP}.

\beginexample
gap> s:= CharacterTable( "F3+N3A" );
CharacterTable( "(3xO8+(3):3):2" )
\endexample

The intersection $N_M(g) = S \cap M$ contains a subgroup $U$ of the type
$3 \times O_8^+(2).3$,
and in the following we compute the class fusions of $U$ into $S$ and $M$,
and then utilize the fact that only those class fusions from $M$ into $G$
are possible whose composition with the class fusion from $U$ into $M$
equals a composition of class fusions from $U$ into $S$
and from $S$ into $G$.

\beginexample
gap> u:= CharacterTable( "Cyclic", 3 ) * CharacterTable( "O8+(2).3" );
CharacterTable( "C3xO8+(2).3" )
gap> ufuss:= PossibleClassFusions( u, s );;
gap> ufusm:= PossibleClassFusions( u, m );;
gap> sfust:= PossibleClassFusions( s, t );;
gap> comp:= SetOfComposedClassFusions( sfust, ufuss );;
gap> Length( comp );
6
gap> filt:= Filtered( mfust,
>     x -> ForAny( ufusm, map -> CompositionMaps( x, map ) in comp ) );;
gap> repr:= RepresentativesFusions( m, filt, t );;
gap> Length( repr );
1
gap> GetFusionMap( m, t ) in repr;
true
\endexample

So the class fusion from $M$ into $G$ is determined up to table automorphisms
by the commutative diagram.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$A_6 \times L_2(8).3 \rightarrow Fi_{24}^{\prime}$
(November 2002)}

The class fusion of the maximal subgroup $M \cong A_6 \times L_2(8).3$
of $G = Fi_{24}^{\prime}$ is ambiguous.

\beginexample
gap> m:= CharacterTable( "A6xL2(8):3" );;
gap> t:= CharacterTable( "F3+" );;
gap> mfust:= PossibleClassFusions( m, t );;
gap> Length( RepresentativesFusions( m, mfust, t ) );
2
\endexample

We will use the fact that the direct factor of the type $A_6$ in $M$
contains elements in the class `3A' of $G$.
This fact can be shown as follows.

\beginexample
gap> dppos:= ClassPositionsOfDirectProductDecompositions( m );
[ [ [ 1, 12 .. 67 ], [ 1 .. 11 ] ] ]
gap> List( dppos[1], l -> Sum( SizesConjugacyClasses( t ){ l } ) );
[ 17733424133316996808705, 4545066196775803392 ]
gap> List( dppos[1], l -> Sum( SizesConjugacyClasses( m ){ l } ) );
[ 360, 1512 ]
gap> 3Apos:= Position( OrdersClassRepresentatives( t ), 3 );
4
gap> 3Ainm:= List( mfust, map -> Position( map, 3Apos ) );
[ 23, 23, 23, 23, 34, 34, 34, 34 ]
gap> ForAll( 3Ainm, x -> x in dppos[1][1] );
true
\endexample

Since the normalizer of an element of order three in $A_6$ has the form
$3^2:2$,
such a `3A' element in $M$ contains a subgroup $U$ of the structure
$3^2:2 \times L_2(8).3$ which is contained in the `3A' normalizer $S$ in $G$,
which has the structure $(3 \times O_8^+(3).3).2$.

(Note that all classes in the $3^2:2$ type group are rational,
and its character table is available in the {\GAP} Character Table Library
with the identifier `"3^2:2"'.)

\beginexample
gap> u:= CharacterTable( "3^2:2" ) * CharacterTable( "L2(8).3" );
CharacterTable( "3^2:2xL2(8).3" )
gap> s:= CharacterTable( "F3+N3A" );
CharacterTable( "(3xO8+(3):3):2" )
gap> ufuss:= PossibleClassFusions( u, s );;
gap> comp:= SetOfComposedClassFusions( sfust, ufuss );;
gap> ufusm:= PossibleClassFusions( u, m );;
gap> filt:= Filtered( mfust,
>               map -> ForAny( ufusm,
>                          map2 -> CompositionMaps( map, map2 ) in comp ) );;
gap> repr:= RepresentativesFusions( m, filt, t );;
gap> Length( repr );
1
gap> GetFusionMap( m, t ) in repr;
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$(3^2:D_8 \times U_4(3).2^2).2 \rightarrow B$ (June 2007)}%
\label{BM14}

Let $G$ be a maximal subgroup of the type $(3^2:D_8 \times U_4(3).2^2).2$
in the sporadic simple group $B$, cf.~\cite[p.~217]{CCN85}.
Computing the class fusion of $G$ into $B$ just from the character tables
of the two groups takes extremely long.
So we use additional information.

According to~\cite[p.~217]{CCN85},
$G$ is the normalizer in $B$ of an elementary abelian group
$\langle x, y \rangle$ of order $9$, with $x, y$ in the class `3A' of $B$,
and $N = N_B(\langle x \rangle)$ has the structure $S_3 \times Fi_{22}.2$.
The intersection $G \cap N$ has the structure
$S_3 \times S_3 \times U_4(3).2^2$,
which is the direct product of $S_3$ and the normalizer in $Fi_{22}.2$
of a `3A' element of $Fi_{22}.2$, see~\cite[p.~163]{CCN85}.
Thus we may use that the class fusions from $G \cap N$ into $B$
through $G$ or $N$ coincide.

The class fusion from $N$ into $B$ is uniquely determined by the character
tables.

\beginexample
gap> b:= CharacterTable( "B" );;
gap> n:= CharacterTable( "BN3A" );
CharacterTable( "S3xFi22.2" )
gap> nfusb:= PossibleClassFusions( n, b );;
gap> Length( nfusb );
1
gap> nfusb:= nfusb[1];;
\endexample

The computation of the class fusion from $G \cap N$ into $N$ is sped up
by computing first the class fusion modulo the direct factor $S_3$,
and then lifting these fusion maps.

\beginexample
gap> fi222:= CharacterTable( "Fi22.2" );;
gap> fi222n3a:= CharacterTable( "S3xU4(3).(2^2)_{122}" );;
gap> s3:= CharacterTable( "S3" );;
gap> inter:= s3 * fi222n3a;;
gap> intermods3fusnmods3:= PossibleClassFusions( fi222n3a, fi222 );;
gap> Length( intermods3fusnmods3 );
2
gap> Length( RepresentativesFusions( fi222n3a, intermods3fusnmods3, fi222 ) );
1
\endexample

We get two equivalent possibilities,
and need to consider only one of them.
For lifting it to a map between $G \cap N$ and $N$,
the safe way is to use the fusion map between the two factors for computing
an approximation.
(Additionally, we could interpret the known maps as fusions between two
subgroups, and use this for improving the approximation,
but in this case the speedup is not worth the effort.)

\beginexample
gap> interfusn:= CompositionMaps( InverseMap( GetFusionMap( n, fi222 ) ),
>        CompositionMaps( intermods3fusnmods3[1],
>            GetFusionMap( inter, fi222n3a ) ) );;
gap> interfusn:= PossibleClassFusions( inter, n,
>        rec( fusionmap:= interfusn, quick:= true ) );;
gap> Length( interfusn );
1
\endexample

The lift is unique.
Since we lift a class fusion to direct products,
we could also ``extend'' the fusion directly.
But note that this would assume the ordering of classes in character tables
of direct products.
This alternative would work as follows.

\beginexample
gap> nccl:= NrConjugacyClasses( fi222 );;
gap> interfusn[1] = Concatenation( List( [ 0 .. 2 ],
>                       i -> intermods3fusnmods3[1] + i * nccl ) );
true
\endexample

Next we compute the class fusions from $G \cap N$ to $G$.
We get two equivalent solutions.

\beginexample
gap> tblg:= CharacterTable( "BM14" );
CharacterTable( "(3^2:D8xU4(3).2^2).2" )
gap> interfusg:= PossibleClassFusions( inter, tblg );;
gap> Length( interfusg );
2
gap> Length( RepresentativesFusions( inter, interfusg, tblg ) );
1
\endexample

The approximation of the class fusion from $G$ to $B$ is computed
by composing the known maps.
Because we have chosen one of the two possible maps from $G \cap N$ to $N$,
here we consider the two possibilities.
 From these approximations, we compute the possible class fusions.

\beginexample
gap> interfusb:= CompositionMaps( nfusb, interfusn[1] );;
gap> approx:= List( interfusg,
>        map -> CompositionMaps( interfusb, InverseMap( map ) ) );;
gap> gfusb:= Set( Concatenation( List( approx,
>                     map -> PossibleClassFusions( tblg, b,
>                                rec( fusionmap:= map ) ) ) ) );;
gap> Length( gfusb );
4
gap> Length( RepresentativesFusions( tblg, gfusb, b ) );
1
\endexample

Finally, we compare the result with the class fusion that is stored
on the library table.

\beginexample
gap> GetFusionMap( tblg, b ) in gfusb;
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$7^{1+4}:(3 \times 2.S_7) \rightarrow M$ (May 2009)}%
\label{MM24}

The class fusion of the maximal subgroup $U$ of type
$7^{1+4}:(3 \times 2.S_7)$ of the Monster group $M$ into $M$ is ambiguous.

\beginexample
gap> tblu:= CharacterTable( "7^(1+4):(3x2.S7)" );;
gap> m:= CharacterTable( "M" );;
gap> ufusm:= PossibleClassFusions( tblu, m );;
gap> Length( RepresentativesFusions( tblu, ufusm, m ) );
2
\endexample

The subgroup $U$ contains a Sylow $7$-subgroup of $M$,
and the only maximal subgroups of $M$ with this property are the class of $U$
and another class of subgroups of the type $7^{2+1+2}:GL_2(7)$.
% show this explicitly!
Moreover, it turns out that the Sylow $7$ normalizers in the subgroups
in both classes have the same order, hence they are the Sylow $7$
normalizers in $M$.

For that, we use representations from the {\ATLAS} of Group
Representations~\cite{AGR}, and access it via the {\GAP} package
{\textsf{AtlasRep}} (\cite{AtlasRep}).

\beginexample
gap> LoadPackage( "atlasrep" );
true
gap> g1:= AtlasGroup( "7^(2+1+2):GL2(7)" );;
gap> s1:= SylowSubgroup( g1, 7 );;
gap> n1:= Normalizer( g1, s1 );;
gap> g2:= AtlasGroup( "7^(1+4):(3x2.S7)" );;
gap> s2:= SylowSubgroup( g2, 7 );;
gap> n2:= Normalizer( g2, s2 );;
gap> Size( n1 ) = Size( n2 );
true
gap> ( Size( m ) / Size( s1 ) ) mod 7 <> 0;
true
\endexample

So let $N$ be a Sylow $7$ normalizer in $U$, and choose a subgroup $S$ of
the type $7^{2+1+2}:GL_2(7)$ that contains $N$.

We compute the character table of $N$.
Computing the possible class fusions of $N$ into $M$ directly
yields two possibilities,
but the class fusion of $N$ into $M$ via $S$ is uniquely determined by the
character tables.

\beginexample
gap> tbln:= CharacterTable( Image( IsomorphismPcGroup( n1 ) ) );;
gap> tbls:= CharacterTable( "7^(2+1+2):GL2(7)" );;
gap> nfusm:= PossibleClassFusions( tbln, m );;
gap> Length( RepresentativesFusions( tbln, nfusm, m ) );
2
gap> nfuss:= PossibleClassFusions( tbln, tbls );;
gap> sfusm:= PossibleClassFusions( tbls, m );;
gap> nfusm:= SetOfComposedClassFusions( sfusm, nfuss );;
gap> Length( nfusm );
1
\endexample

Now we use the condition that the class fusions from $N$ into $M$ factors
through $U$.
This determines the class fusion of $U$ into $M$ up to table automorphisms.

\beginexample
gap> nfusu:= PossibleClassFusions( tbln, tblu );;
gap> ufusm:= Filtered( ufusm, map2 -> ForAny( nfusu, 
>        map1 -> CompositionMaps( map2, map1 ) in nfusm ) );;
gap> Length( RepresentativesFusions( tblu, ufusm, m ) );
1
\endexample

Let $C$ be the centralizer in $U$ of the normal subgroup of order $7$;
note that $C$ is the `7B' centralizer on $M$.
We can use the information about the class fusion of $U$ into $M$
for determining the class fusion of $C$ into $M$.
The class fusion of $C$ into $M$ is not determined by the character tables,
but the class fusion of $C$ into $U$ is determined up to table automorphisms,
so the same holds for the class fusion of $C$ into $M$.

\beginexample
gap> tblc:= CharacterTable( "MC7B" );                             
CharacterTable( "7^1+4.2A7" )
gap> cfusm:= PossibleClassFusions( tblc, m );;             
gap> Length( RepresentativesFusions( tblc, cfusm, m ) );
2
gap> cfusu:= PossibleClassFusions( tblc, tblu );;
gap> cfusm:= SetOfComposedClassFusions( ufusm, cfusu );;
gap> Length( RepresentativesFusions( tblc, cfusm, m ) );
1
\endexample

% Compare tables and fusions with the ones in the library!


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$3^7.O_7(3):2 \rightarrow Fi_{24}$
(November 2010)}

The class fusion of the maximal subgroup $M \cong 3^7.O_7(3):2$
of $G = Fi_{24} = F_{3+}.2$ is ambiguous.

\beginexample
gap> m:= CharacterTable( "3^7.O7(3):2" );;
gap> t:= CharacterTable( "F3+.2" );;
gap> mfust:= PossibleClassFusions( m, t );;
gap> Length( RepresentativesFusions( m, mfust, t ) );
2
\endexample

We will use the fact that the elementary abelian normal subgroup of order
$3^7$ in $M$ contains an element $x$, say, in the class `3A' of $G$.
This fact can be shown as follows.

\beginexample
gap> nsg:= ClassPositionsOfNormalSubgroups( m );
[ [ 1 ], [ 1 .. 4 ], [ 1 .. 158 ], [ 1 .. 291 ] ]
gap> Sum( SizesConjugacyClasses( m ){ nsg[2] } );
2187
gap> 3^7;
2187
gap> rest:= Set( List( mfust, map -> map{ nsg[2] } ) );
[ [ 1, 4, 5, 6 ] ]
gap> List( rest, l -> ClassNames( t, "Atlas" ){ l } );
[ [ "1A", "3A", "3B", "3C" ] ]
\endexample

The normalizer $S$ of $\langle x \rangle$ in $G$ has the form
$S_3 \times O_8^+(3):S_3$,
and the order of $U = S \cap M = N_M( \langle x \rangle)$
is $53059069440$, so $U$ has index $3360$ in $S$.

\beginexample
gap> s:= CharacterTable( "F3+.2N3A" );
CharacterTable( "S3xO8+(3):S3" )
gap> PowerMap( m, 2 )[4];
4
gap> size_u:= 2 * SizesCentralizers( m )[ 2 ];
53059069440
gap> Size( s ) / size_u;
3360
\endexample

Using the list of maximal subgroups of $O_8^+(3)$,
we see that only the maximal subgroups of the type $3^6:L_4(3)$
have index dividing $3360$ in $O_8^+(3)$.
(There are three classes of such subgroups.)
This implies that $U$ contains a subgroup of the type
$S_3 \times 3^6:L_4(3)$.

\beginexample
gap> o8p3:= CharacterTable( "O8+(3)" );;
gap> mx:= List( Maxes( o8p3 ), CharacterTable );;
gap> filt:= Filtered( mx, x -> 3360 mod Index( o8p3, x ) = 0 );
[ CharacterTable( "3^6:L4(3)" ), CharacterTable( "O8+(3)M8" ), 
  CharacterTable( "O8+(3)M9" ) ]
gap> List( filt, x -> Index( o8p3, x ) );
[ 1120, 1120, 1120 ]
\endexample

We compute the possible class fusions from $U$ into $M$ and $S$ in two
steps, because this is faster.
First the possible class fusions from $U^{\prime\prime} \cong 3^6:L_4(3)$
into $M$ and $S$ are computed, and then these fusions are used to derive
approximations for the fusions from $U$ into $M$ and $S$.

\beginexample
gap> uu:= filt[1];;
gap> u:= CharacterTable( "Symmetric", 3 ) * uu;
CharacterTable( "Sym(3)x3^6:L4(3)" )
gap> uufusm:= PossibleClassFusions( uu, m );;
gap> Length( uufusm );
8
gap> approx:= List( uufusm, map -> CompositionMaps( map,
>                   InverseMap( GetFusionMap( uu, u ) ) ) );;
gap> ufusm:= Concatenation( List( approx, map ->
>        PossibleClassFusions( u, m, rec( fusionmap:= map ) ) ) );;
gap> Length( ufusm );
8
gap> uufuss:= PossibleClassFusions( uu, s );;
gap> Length( uufuss );
8
gap> approx:= List( uufuss, map -> CompositionMaps( map,
>              InverseMap( GetFusionMap( uu, u ) ) ) );;
gap> ufuss:= Concatenation( List( approx, map ->
>   PossibleClassFusions( u, s, rec( fusionmap:= map ) ) ) );;
gap> Length( ufuss );
8
\endexample

Now we compute the possible class fusions from $S$ into $G$,
and the compositions of these maps with the possible class fusions
from $U$ into $S$.

\beginexample
gap> sfust:= PossibleClassFusions( s, t );;
gap> comp:= SetOfComposedClassFusions( sfust, ufuss );;
gap> Length( comp );
8
\endexample

It turns out that only one orbit of the possible class fusions from $M$ to
$G$ is compatible with these possible class fusions from $U$ to $G$.

\beginexample
gap> filt:= Filtered( mfust, map2 -> ForAny( ufusm, map1 ->
>        CompositionMaps( map2, map1 ) in comp ) );;
gap> Length( filt );
4
gap> Length( RepresentativesFusions( m, filt, t ) );
1
\endexample

The class fusion stored in the {\GAP} Character Table Library is one of them.

\beginexample
gap> GetFusionMap( m, t ) in filt;
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Fusions Determined Using Commutative Diagrams Involving Factor
Groups}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$3.A_7 \rightarrow 3.Suz$ (December 2010)}

The maximal subgroups of type $A_7$ in the sporadic simple Suzuki group $Suz$
lift to groups of the type $3.A_7$ in $3.Suz$.
This can be seen from the fact that $3.Suz$ does not admit a class fusion
from $A_7$.

\beginexample
gap> t:= CharacterTable( "Suz" );;
gap> 3t:= CharacterTable( "3.Suz" );;
gap> s:= CharacterTable( "A7" );;
gap> 3s:= CharacterTable( "3.A7" );;
gap> PossibleClassFusions( s, 3t );
[  ]
\endexample

The class fusion of $3.A_7$ into $3.Suz$ is ambiguous.

\beginexample
gap> 3sfus3t:= PossibleClassFusions( 3s, 3t );;
gap> Length( 3sfus3t );
6
gap> RepresentativesFusions( 3s, 3sfus3t, 3t );
[ [ 1, 2, 3, 7, 8, 9, 16, 16, 26, 27, 28, 32, 33, 34, 47, 47, 47, 48, 49, 50, 
      48, 49, 50 ], 
  [ 1, 11, 12, 4, 36, 37, 13, 16, 23, 82, 83, 32, 100, 101, 44, 38, 41, 48, 
      112, 116, 48, 115, 113 ] ]
gap> ClassPositionsOfCentre( 3t );
[ 1, 2, 3 ]
\endexample

We see that the possible fusions in the second orbit avoid the centre of
$3.Suz$.
Since the preimages in $3.Suz$ of the $A_7$ type subgroups of $Suz$
contain the centre of $3.Suz$, we know that the class fusion of these
preimages belong to the first orbit.
This can be formalized by checking the commutativity of the diagram
of fusions between $3.A_7$, $3.Suz$, and their factors $A_7$ and $Suz$.

\beginexample
gap> sfust:= PossibleClassFusions( s, t );;
gap> Length( sfust );
1
gap> filt:= Filtered( 3sfus3t, map -> CompositionMaps( GetFusionMap( 3t, t ),
>                                         map )
>               = CompositionMaps( sfust[1], GetFusionMap( 3s, s ) ) );
[ [ 1, 2, 3, 7, 8, 9, 16, 16, 26, 27, 28, 32, 33, 34, 47, 47, 47, 48, 49, 50, 
      48, 49, 50 ], 
  [ 1, 3, 2, 7, 9, 8, 16, 16, 26, 28, 27, 32, 34, 33, 47, 47, 47, 48, 50, 49, 
      48, 50, 49 ] ]
\endexample

So the class fusion of maximal $3.A_7$ type subgroups of $3.Suz$ is
determined up to table automorphisms.
One of these fusions is stored on the table of $3.A_7$.

\beginexample
gap> RepresentativesFusions( 3s, filt, 3t );
[ [ 1, 2, 3, 7, 8, 9, 16, 16, 26, 27, 28, 32, 33, 34, 47, 47, 47, 48, 49, 50, 
      48, 49, 50 ] ]
gap> GetFusionMap( 3s, 3t ) in filt;
true
\endexample

Also the class fusions in the other orbit belong to subgroups of type
$3.A_7$ in $3.Suz$.
Note that $Suz$ contains maximal subgroups of the type
$3_2.U_4(3).2_3^{\prime}$ (see~\cite[p.~131]{CCN85}),
and the $A_7$ type subgroups of $U_4(3)$ (see~\cite[p.~52]{CCN85})
lift to groups of the type $3.A_7$ in $3_2.U_4(3)$ because
$3_2.U_4(3)$ does not admit a class fusion from $A_7$.
The preimages in $3.Suz$ of the $3.A_7$ tape subgroups of $Suz$
have the structure $3 \times 3.A_7$.

\beginexample
gap> u:= CharacterTable( "3_2.U4(3)" );;
gap> PossibleClassFusions( s, u );
[  ]
gap> Length( PossibleClassFusions( 3s, u ) );
8
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Fusions Determined Using Commutative Diagrams Involving
Automorphic Extensions}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$U_3(8).3_1 \rightarrow {}^2E_6(2)$ (December 2010)}%
\label{u383to2e62}

According to the {\ATLAS} (see~\cite[p.~191]{CCN85}),
the group $G = {}^2E_6(2)$ contains a maximal subgroup $U$ of the type
$U_3(8).3_1$.
The class fusion of $U$ into $G$ is ambiguous.

\beginexample
gap> s:= CharacterTable( "U3(8).3_1" );;
gap> t:= CharacterTable( "2E6(2)" );;
gap> sfust:= PossibleClassFusions( s, t );;
gap> Length( sfust );
24
gap> Length( RepresentativesFusions( s, sfust, t ) );
2
\endexample

In the automorphic extension $G.2 = {}^2E_6(2).2$ of $G$,
the subgroup $U$ extends to a group $U.2$ of the type $U_3(8).6$
(again, see ~\cite[p.~191]{CCN85}).
The class fusion of $U.2$ into $G.2$ is unique up to table automorphisms.

\beginexample
gap> s2:= CharacterTable( "U3(8).6" );;
gap> t2:= CharacterTable( "2E6(2).2" );;
gap> s2fust2:= PossibleClassFusions( s2, t2 );;
gap> Length( s2fust2 );
2
gap> Length( RepresentativesFusions( s2, s2fust2, t2 ) );
1
\endexample

Only half of the possible class fusions from $U$ into $G$ are compatible
with the embeddings of $U$ into $G.2$ via $U.2$ and $G$,
and the compatible maps form one orbit under table automorphisms.

\beginexample
gap> sfuss2:= PossibleClassFusions( s, s2 );;
gap> comp:= SetOfComposedClassFusions( s2fust2, sfuss2 );;
gap> tfust2:= PossibleClassFusions( t, t2 );;
gap> filt:= Filtered( sfust, map -> ForAny( tfust2,
>               map2 -> CompositionMaps( map2, map ) in comp ) );;
gap> Length( filt );
12
gap> Length( RepresentativesFusions( s, filt, t ) );
1
\endexample

Let us see which classes of $U$ and $G$ are involved in the
disambiguation of the class fusion.
The ``good'' fusion candidates differ from the excluded ones on the
classes at the positions $31$ to $36$:
Under all possible class fusions, two pairs of classes are mapped to
the classes $81$ and $82$ of $G$;
from these classes, the excluded maps fuse classes at odd positions
with classes at even positions, whereas the ``good'' class fusions
do not have this property.

\beginexample
gap> Set( List( filt, x -> x{ [ 31 .. 36 ] } ) );
[ [ 74, 74, 81, 82, 81, 82 ], [ 74, 74, 82, 81, 82, 81 ], 
  [ 81, 82, 74, 74, 81, 82 ], [ 81, 82, 81, 82, 74, 74 ], 
  [ 82, 81, 74, 74, 82, 81 ], [ 82, 81, 82, 81, 74, 74 ] ]
gap> Set( List( Difference( sfust, filt ), x -> x{ [ 31 .. 36 ] } ) );
[ [ 74, 74, 81, 82, 82, 81 ], [ 74, 74, 82, 81, 81, 82 ], 
  [ 81, 82, 74, 74, 82, 81 ], [ 81, 82, 82, 81, 74, 74 ], 
  [ 82, 81, 74, 74, 81, 82 ], [ 82, 81, 81, 82, 74, 74 ] ]
\endexample

None of the possible class fusions from $U$ to $U.2$ fuses classes
at odd positions in the interval from $31$ to $36$ with classes at
even positions.

\beginexample
gap> Set( List( sfuss2, x -> x{ [ 31 .. 36 ] } ) );
[ [ 28, 29, 30, 31, 30, 31 ], [ 29, 28, 31, 30, 31, 30 ], 
  [ 30, 31, 28, 29, 30, 31 ], [ 30, 31, 30, 31, 28, 29 ], 
  [ 31, 30, 29, 28, 31, 30 ], [ 31, 30, 31, 30, 29, 28 ] ]
\endexample

This suffices to exclude the ``bad'' fusion candidates
because no further fusion of the relevant classes of $G$ happens in $G.2$.

\beginexample
gap> List( tfust2, x -> x{ [ 74, 81, 82 ] } );
[ [ 65, 70, 71 ], [ 65, 70, 71 ], [ 65, 71, 70 ], [ 65, 71, 70 ], 
  [ 65, 70, 71 ], [ 65, 70, 71 ], [ 65, 71, 70 ], [ 65, 71, 70 ], 
  [ 65, 70, 71 ], [ 65, 70, 71 ], [ 65, 71, 70 ], [ 65, 71, 70 ] ]
\endexample

(The same holds for the fusion of the relevant classes of $U.2$ in $G.2$.)

\beginexample
gap> List( s2fust2, x -> x{ [ 28 .. 31 ] } );
[ [ 65, 65, 70, 71 ], [ 65, 65, 71, 70 ] ]
\endexample

Finally, we check that a correct map is stored on the library table.

\beginexample
gap> GetFusionMap( s, t ) in filt;
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$L_3(4).2_1 \rightarrow U_6(2)$ (December 2010)}

According to the {\ATLAS} (see~\cite[p.~115]{CCN85}),
the group $G = U_6(2)$ contains a maximal subgroup $U$ of the type
$L_3(4).2_1$.
The class fusion of $U$ into $G$ is ambiguous.

\beginexample
gap> s:= CharacterTable( "L3(4).2_1" );;
gap> t:= CharacterTable( "U6(2)" );;
gap> sfust:= PossibleClassFusions( s, t );;
gap> Length( sfust );
27
gap> Length( RepresentativesFusions( s, sfust, t ) );
3
\endexample

In the automorphic extension $G.3 = U_6(2).3$ of $G$,
the subgroup $U$ extends to a group $U.3$ of the type $L_3(4).6$
(again, see ~\cite[p.~115]{CCN85}).
The class fusion of $U.3$ into $G.3$ is unique up to table automorphisms.

\beginexample
gap> s3:= CharacterTable( "L3(4).6" );;
gap> t3:= CharacterTable( "U6(2).3" );;
gap> s3fust3:= PossibleClassFusions( s3, t3 );;
gap> Length( s3fust3 );
2
gap> Length( RepresentativesFusions( s3, s3fust3, t3 ) );
1
\endexample

Here the argument used in Section~\ref{u383to2e62} does not work,
because all possible class fusions from $U$ into $G$ are compatible
with the embeddings of $U$ into $G.3$ via $U.3$ and $G$.

\beginexample
gap> sfuss3:= PossibleClassFusions( s, s3 );;
gap> comp:= SetOfComposedClassFusions( s3fust3, sfuss3 );;
gap> tfust3:= PossibleClassFusions( t, t3 );;
gap> sfust = Filtered( sfust, map -> ForAny( tfust3,
>                map2 -> CompositionMaps( map2, map ) in comp ) );
true
\endexample

Consider the elements of order four in $U$.
There are three such classes inside $U^{\prime} \cong L_3(4)$,
which fuse to one class of $U.3$.

\beginexample
gap> OrdersClassRepresentatives( s );
[ 1, 2, 3, 4, 4, 4, 5, 7, 2, 4, 6, 8, 8, 8 ]
gap> sfuss3;
[ [ 1, 2, 3, 4, 4, 4, 5, 6, 7, 8, 9, 10, 10, 10 ] ]
\endexample

These classes of $U$ fuse into some of the classes $10$ to $12$ of $G$.
In $G.3$, these three classes fuse into one class.

\beginexample
gap> Set( List( sfust, map -> map{ [ 4 .. 6 ] } ) );
[ [ 10, 10, 10 ], [ 10, 10, 11 ], [ 10, 10, 12 ], [ 10, 11, 10 ], 
  [ 10, 11, 11 ], [ 10, 11, 12 ], [ 10, 12, 10 ], [ 10, 12, 11 ], 
  [ 10, 12, 12 ], [ 11, 10, 10 ], [ 11, 10, 11 ], [ 11, 10, 12 ], 
  [ 11, 11, 10 ], [ 11, 11, 11 ], [ 11, 11, 12 ], [ 11, 12, 10 ], 
  [ 11, 12, 11 ], [ 11, 12, 12 ], [ 12, 10, 10 ], [ 12, 10, 11 ], 
  [ 12, 10, 12 ], [ 12, 11, 10 ], [ 12, 11, 11 ], [ 12, 11, 12 ], 
  [ 12, 12, 10 ], [ 12, 12, 11 ], [ 12, 12, 12 ] ]
gap> Set( List( tfust3, map -> map{ [ 10 .. 12 ] } ) );
[ [ 10, 10, 10 ] ]
\endexample

This means that the automorphism $\alpha$ of $G$ that is induced by
the action of $G.3$ permutes the classes $10$ to $12$ of $G$ transitively.
The fact that $U$ extends to $U.3$ in $G.3$ means that $U$ is invariant
under $\alpha$.
This implies that $U$ contains either no elements from the classes
$10$ to $12$ or elements from all of these classes.
The possible class fusions from $U$ to $G$ satisfying this condition
form one orbit under table automprhisms.

\beginexample
gap> Filtered( sfust, map -> Intersection( map, [ 10 .. 12 ] ) = [] );
[  ]
gap> filt:= Filtered( sfust, map -> IsSubset( map, [ 10 .. 12 ] ) );
[ [ 1, 3, 7, 10, 11, 12, 15, 24, 4, 14, 23, 26, 27, 28 ], 
  [ 1, 3, 7, 10, 12, 11, 15, 24, 4, 14, 23, 26, 28, 27 ], 
  [ 1, 3, 7, 11, 10, 12, 15, 24, 4, 14, 23, 27, 26, 28 ], 
  [ 1, 3, 7, 11, 12, 10, 15, 24, 4, 14, 23, 27, 28, 26 ], 
  [ 1, 3, 7, 12, 10, 11, 15, 24, 4, 14, 23, 28, 26, 27 ], 
  [ 1, 3, 7, 12, 11, 10, 15, 24, 4, 14, 23, 28, 27, 26 ] ]
gap> Length( RepresentativesFusions( s, filt, t ) );
1
\endexample

Finally, we check that a correct map is stored on the library table.

\beginexample
gap> GetFusionMap( s, t ) in filt;
true
\endexample

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Conditions Imposed by Brauer Tables}

The examples in this section show that symmetries can be broken as soon as
the class fusions between two ordinary tables shall be compatible with
the corresponding Brauer character tables.
More precisely, we assume that the class fusion from each Brauer table
to its ordinary table is already fixed;
choosing these fusions consistently can be a nontrivial task,
solving so-called ``generality problems'' may require the construction
of certain modules, similar to the arguments used in~\ref{generality} below.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$L_2(16).4 \rightarrow J_3.2$ (January~2004)}

It can happen that Brauer tables decide ambiguities of class fusions between
the corresponding ordinary tables.
An easy example is the class fusion of $L_2(16).4$ into $J_3.2$.
The ordinary tables admit four possible class fusions,
of which two are essentially different.

\beginexample
gap> s:= CharacterTable( "L2(16).4" );;
gap> t:= CharacterTable( "J3.2" );;
gap> fus:= PossibleClassFusions( s, t );
[ [ 1, 2, 3, 6, 14, 15, 16, 2, 5, 7, 12, 5, 5, 8, 8, 13, 13 ],
  [ 1, 2, 3, 6, 14, 15, 16, 2, 5, 7, 12, 19, 19, 22, 22, 23, 23 ],
  [ 1, 2, 3, 6, 14, 16, 15, 2, 5, 7, 12, 5, 5, 8, 8, 13, 13 ],
  [ 1, 2, 3, 6, 14, 16, 15, 2, 5, 7, 12, 19, 19, 22, 22, 23, 23 ] ]
gap> RepresentativesFusions( s, fus, t );
[ [ 1, 2, 3, 6, 14, 15, 16, 2, 5, 7, 12, 5, 5, 8, 8, 13, 13 ], 
  [ 1, 2, 3, 6, 14, 15, 16, 2, 5, 7, 12, 19, 19, 22, 22, 23, 23 ] ]
\endexample

Using Brauer tables, we will see that just one fusion is admissible.

We can exclude two possible fusions by the fact that their images all
lie inside the normal subgroup $J_3$, but $J_3$ does not contain a subgroup
of type $L_2(16).4$; so still one orbit of length two remains.

\beginexample
gap> j3:= CharacterTable( "J3" );;
gap> PossibleClassFusions( s, j3 );
[  ]
gap> GetFusionMap( j3, t );
[ 1, 2, 3, 4, 5, 6, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 14, 15, 16, 17, 17 ]
gap> filt:= Filtered( fus,
>          x -> not IsSubset( ClassPositionsOfDerivedSubgroup( t ), x ) );
[ [ 1, 2, 3, 6, 14, 15, 16, 2, 5, 7, 12, 19, 19, 22, 22, 23, 23 ], 
  [ 1, 2, 3, 6, 14, 16, 15, 2, 5, 7, 12, 19, 19, 22, 22, 23, 23 ] ]
\endexample

Now the remaining wrong fusion is excluded by the fact that the table
automorphism of $J_3.2$ that swaps the two classes of element order $17$
--which swaps two of the possible class fusions--
does not live in the $2$-modular table.

\beginexample
gap> smod2:= s mod 2;;
gap> tmod2:= t mod 2;;
gap> admissible:= [];;
gap> for map in filt do
>      modmap:= CompositionMaps( InverseMap( GetFusionMap( tmod2, t ) ),
>                   CompositionMaps( map, GetFusionMap( smod2, s ) ) );
>      if not fail in Decomposition( Irr( smod2 ),
>            List( Irr( tmod2 ), chi -> chi{ modmap } ), "nonnegative" ) then
>        AddSet( admissible, map );
>      fi;
>    od;
gap> admissible;
[ [ 1, 2, 3, 6, 14, 16, 15, 2, 5, 7, 12, 19, 19, 22, 22, 23, 23 ] ]
\endexample

The test of all available Brauer tables is implemented in the function
`CTblLibTestDecompositions' of the {\GAP} Character Table Library
(\cite{CTblLib1.1.3}).

\beginexample
gap> CTblLibTestDecompositions( s, fus, t ) = admissible;
true
\endexample

We see that $p$-modular tables alone determine the class fusion uniquely;
in fact the primes $2$ and $3$ suffice for that.

\beginexample
gap> GetFusionMap( s, t ) in admissible;
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$L_2(17) \rightarrow S_8(2)$ (July 2004)}

The class fusion of the maximal subgroup $M \cong L_2(17)$
of $G = S_8(2)$ is ambiguous.

\beginexample
gap> m:= CharacterTable( "L2(17)" );;
gap> t:= CharacterTable( "S8(2)" );;
gap> mfust:= PossibleClassFusions( m, t );;
gap> Length( RepresentativesFusions( m, mfust, t ) );
4
\endexample

The Brauer tables for $M$ and $G$ determine the class fusion up to
table automorphisms.

\beginexample
gap> filt:= CTblLibTestDecompositions( m, mfust, t );;
gap> repr:= RepresentativesFusions( m, filt, t );;
gap> Length( repr );
1
gap> GetFusionMap( m, t ) in repr;
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$L_2(19) \rightarrow J_3$ (April 2003)}\label{generality}

It can happen that Brauer tables impose conditions such that ambiguities
arise which are not visible if one considers only ordinary tables.

The class fusion between the ordinary character tables of $L_2(19)$ and $J_3$
is unique up to table automorphisms.

\beginexample
gap> s:= CharacterTable( "L2(19)" );;
gap> t:= CharacterTable( "J3" );;
gap> sfust:= PossibleClassFusions( s, t );
[ [ 1, 2, 4, 6, 7, 10, 11, 12, 13, 14, 20, 21 ],
  [ 1, 2, 4, 6, 7, 10, 11, 12, 13, 14, 21, 20 ],
  [ 1, 2, 4, 6, 7, 11, 12, 10, 13, 14, 20, 21 ],
  [ 1, 2, 4, 6, 7, 11, 12, 10, 13, 14, 21, 20 ],
  [ 1, 2, 4, 6, 7, 12, 10, 11, 13, 14, 20, 21 ],
  [ 1, 2, 4, 6, 7, 12, 10, 11, 13, 14, 21, 20 ],
  [ 1, 2, 4, 7, 6, 10, 11, 12, 14, 13, 20, 21 ],
  [ 1, 2, 4, 7, 6, 10, 11, 12, 14, 13, 21, 20 ],
  [ 1, 2, 4, 7, 6, 11, 12, 10, 14, 13, 20, 21 ],
  [ 1, 2, 4, 7, 6, 11, 12, 10, 14, 13, 21, 20 ],
  [ 1, 2, 4, 7, 6, 12, 10, 11, 14, 13, 20, 21 ],
  [ 1, 2, 4, 7, 6, 12, 10, 11, 14, 13, 21, 20 ] ]
gap> fusreps:= RepresentativesFusions( s, sfust, t );
[ [ 1, 2, 4, 6, 7, 10, 11, 12, 13, 14, 20, 21 ] ]
\endexample

The Galois automorphism that permutes the three classes of element order $9$
in the tables of ($L_2(19)$ and) $J_3$ does not live in characteristic $19$.
For example, the unique irreducible Brauer character of degree $110$
in the $19$-modular table of $J_3$ is $\varphi_3$,
and the value of this character on the class {\tt 9A} is {\tt -1+2y9+\&4}.

\beginexample
gap> tmod19:= t mod 19;
BrauerTable( "J3", 19 )
gap> deg110:= Filtered( Irr( tmod19 ), phi -> phi[1] = 110 );
[ Character( BrauerTable( "J3", 19 ), [ 110, -2, 5, 2, 2, 0, 0, 1, 0, 
      -2*E(9)^2+E(9)^3-E(9)^4-E(9)^5+E(9)^6-2*E(9)^7, 
      E(9)^2+E(9)^3-E(9)^4-E(9)^5+E(9)^6+E(9)^7, 
      E(9)^2+E(9)^3+2*E(9)^4+2*E(9)^5+E(9)^6+E(9)^7, -2, -2, -1, 0, 0, 
      E(17)+E(17)^2+E(17)^4+E(17)^8+E(17)^9+E(17)^13+E(17)^15+E(17)^16, 
      E(17)^3+E(17)^5+E(17)^6+E(17)^7+E(17)^10+E(17)^11+E(17)^12+E(17)^14 ] ) 
 ]
gap> 9A:= Position( OrdersClassRepresentatives( tmod19 ), 9 );
10
gap> deg110[1][ 9A ];
-2*E(9)^2+E(9)^3-E(9)^4-E(9)^5+E(9)^6-2*E(9)^7
gap> AtlasIrrationality( "-1+2y9+&4" ) = deg110[1][ 9A ];
true
\endexample

It turns out that four of the twelve possible class fusions are not compatible
with the $19$-modular tables.

\beginexample
gap> smod19:= s mod 19;
BrauerTable( "L2(19)", 19 )
gap> compatible:= [];;
gap> for map in sfust do
>      comp:= CompositionMaps( InverseMap( GetFusionMap( tmod19, t ) ),
>      CompositionMaps( map, GetFusionMap( smod19, s ) ) );
>      rest:= List( Irr( tmod19 ), phi -> phi{ comp } );
>      if not fail in Decomposition( Irr( smod19 ), rest, "nonnegative" ) then
>        Add( compatible, map );
>      fi;
>    od;
gap> compatible;
[ [ 1, 2, 4, 6, 7, 11, 12, 10, 13, 14, 20, 21 ],
  [ 1, 2, 4, 6, 7, 11, 12, 10, 13, 14, 21, 20 ],
  [ 1, 2, 4, 6, 7, 12, 10, 11, 13, 14, 20, 21 ],
  [ 1, 2, 4, 6, 7, 12, 10, 11, 13, 14, 21, 20 ],
  [ 1, 2, 4, 7, 6, 11, 12, 10, 14, 13, 20, 21 ],
  [ 1, 2, 4, 7, 6, 11, 12, 10, 14, 13, 21, 20 ],
  [ 1, 2, 4, 7, 6, 12, 10, 11, 14, 13, 20, 21 ],
  [ 1, 2, 4, 7, 6, 12, 10, 11, 14, 13, 21, 20 ] ]
\endexample

Moreover, the subgroups of those table automorphisms of the ordinary tables
that leave the set of compatible fusions invariant make two orbits on this
set.
Indeed, the two orbits belong to essentially different decompositions of the
restriction of $\varphi_3$.

\beginexample
gap> reps:= RepresentativesFusions( s, compatible, t );
[ [ 1, 2, 4, 6, 7, 11, 12, 10, 13, 14, 20, 21 ],
  [ 1, 2, 4, 6, 7, 12, 10, 11, 13, 14, 20, 21 ] ]
gap> compatiblemod19:= List( reps, map -> CompositionMaps(
>        InverseMap( GetFusionMap( tmod19, t ) ),
>        CompositionMaps( map, GetFusionMap( smod19, s ) ) ) );
[ [ 1, 2, 4, 6, 7, 11, 12, 10, 13, 14 ], 
  [ 1, 2, 4, 6, 7, 12, 10, 11, 13, 14 ] ]
gap> rest:= List( compatiblemod19, map -> Irr( tmod19 )[3]{ map } );;
gap> dec:= Decomposition( Irr( smod19 ), rest, "nonnegative" );
[ [ 0, 0, 1, 2, 1, 2, 2, 1, 0, 1 ], [ 0, 2, 0, 2, 0, 1, 2, 0, 2, 1 ] ]
gap> List( Irr( smod19 ), phi -> phi[1] );
[ 1, 3, 5, 7, 9, 11, 13, 15, 17, 19 ]
\endexample

In order to decide which class fusion is correct,
we take the matrix representation of $J_3$ that affords $\varphi_3$,
restrict it to $L_2(19)$, which is the second maximal subgroup of $J_3$,
and compute the composition factors.
For that, we use a representation from the {\ATLAS} of Group
Representations~\cite{AGR}, and access it via the {\GAP} package
{\textsf{AtlasRep}} (\cite{AtlasRep}).

\beginexample
gap> LoadPackage( "atlasrep" );
true
gap> prog:= AtlasStraightLineProgram( "J3", "maxes", 2 );
rec( groupname := "J3", identifier := [ "J3", "J3G1-max2W1", 1 ],
  program := <straight line program>, size := 3420, standardization := 1 )
gap> gens:= OneAtlasGeneratingSet( "J3", Characteristic, 19, Dimension, 110 );
rec( dim := 110,
  generators := [ < immutable compressed matrix 110x110 over GF(19) >,
      < immutable compressed matrix 110x110 over GF(19) > ],
  groupname := "J3", id := "",
  identifier := [ "J3", [ "J3G1-f19r110B0.m1", "J3G1-f19r110B0.m2" ], 1, 19 ],
  repnr := 35, ring := GF(19), size := 50232960, standardization := 1 )
gap> restgens:= ResultOfStraightLineProgram( prog.program, gens.generators );
[ < immutable compressed matrix 110x110 over GF(19) >,
  < immutable compressed matrix 110x110 over GF(19) > ]
gap> module:= GModuleByMats( restgens, GF( 19 ) );;
gap> facts:= SMTX.CollectedFactors( module );;
gap> Length( facts );
7
gap> List( facts, x -> x[1].dimension );
[ 5, 7, 9, 11, 13, 15, 19 ]
gap> List( facts, x -> x[2] );
[ 1, 2, 1, 2, 2, 1, 1 ]
\endexample

This means that there are seven pairwise nonisomorphic composition factors,
the smallest one of dimension five.
In other words, the first of the two maps is the correct one.
Let us check whether this map equals the one that is stored on the library
table.

\beginexample
gap> GetFusionMap( s, t ) = reps[1];
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Fusions Determined by Information about the Groups}

In the examples in this section, character theoretic arguments do not suffice
for determining the class fusions.
So we use computations with the groups in question or information about
these groups beyond the character table,
and perhaps additionally character theoretic arguments.

The group representations are taken from the {\ATLAS} of Group
Representations~\cite{AGR} and are accessed via the {\GAP} package
{\textsf{AtlasRep}} (\cite{AtlasRep}).

\beginexample
gap> LoadPackage( "atlasrep" );
true
\endexample


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \subsection{\textbf{OPEN!!} $2 \times L_2(31) \rightarrow 2.B$}
% 
% First we determine the fusions between the factor groups modulo the centre.
% 
% \beginexample
% gap> l:= CharacterTable( "L2(31)" );
% CharacterTable( "L2(31)" )
% gap> s:= CharacterTable( "31:15" );
% CharacterTable( "31:15" )
% gap> sfusl:= PossibleClassFusions( s, l );;
% #I  RepresentativesFusions: 1 orbit(s) of length(s) [ 8 ]
% #I  PossibleClassFusions: 8 solutions
% gap> lfusb:= PossibleClassFusions( l, b );;
% #I  RepresentativesFusions: 2 orbit(s) of length(s) [ 2, 2 ] 
% #I  PossibleClassFusions: 4 solutions
% gap> filt:= Filtered( lfusb, x -> ForAny( sfusl, map ->
% > # comp is s -> b as determined by factorization through Th!
% > CompositionMaps( x, map ) in comp ) );
% [ [ 1, 5, 7, 15, 19, 19, 44, 44, 82, 82, 82, 82, 90, 90, 90, 90, 145, 146 ], 
%   [ 1, 5, 7, 15, 19, 19, 44, 44, 82, 82, 82, 82, 90, 90, 90, 90, 146, 145 ] ]
% gap> RepresentativesFusions( l, filt, b );
% #I  RepresentativesFusions: 1 orbit(s) of length(s) [ 2 ]
% [ [ 1, 5, 7, 15, 19, 19, 44, 44, 82, 82, 82, 82, 90, 90, 90, 90, 145, 146 ] ]
% \endexample
% 
% Now we compute the fusions between the groups themselves.
% 
% Note that since ... it is clear that $L_2(31)$ does not lift to the
% proper covering group $2.L_2(31)$.
% (Alternatively, show that no fusion is possible.)
% 
% \beginexample
% gap> 2l:= CharacterTable( "2.L2(31)" );
% CharacterTable( "2.L2(31)" )
% gap> PossibleClassFusions( 2l, 2b );
% [  ]
% gap> dp:= c2 * l;
% CharacterTable( "C2xL2(31)" )
% gap> 2lfus2b:= PossibleClassFusions( dp, 2b );;
% #I  RepresentativesFusions: 6 orbit(s) of length(s) [ 2, 2, 2, 2, 2, 2 ]
% #I  PossibleClassFusions: 12 solutions
% gap> filt:= Filtered( 2lfus2b, x -> CompositionMaps( GetFusionMap( 2b, b ), x ) =
% > CompositionMaps( [1,5,7,15,19,19,44,44,82,82,82,82,90,90,90,90,145,146],
% > GetFusionMap( dp, l ) ) );
% #I  GetFusionMap: Used fusion has specification 2
% #I  GetFusionMap: Used fusion has specification 2
% #I  GetFusionMap: Used fusion has specification 2
% #I  GetFusionMap: Used fusion has specification 2
% #I  GetFusionMap: Used fusion has specification 2
% #I  GetFusionMap: Used fusion has specification 2
% #I  GetFusionMap: Used fusion has specification 2
% #I  GetFusionMap: Used fusion has specification 2
% #I  GetFusionMap: Used fusion has specification 2
% #I  GetFusionMap: Used fusion has specification 2
% #I  GetFusionMap: Used fusion has specification 2
% #I  GetFusionMap: Used fusion has specification 2
% [ [ 1, 7, 10, 20, 25, 25, 56, 56, 107, 107, 107, 107, 116, 116, 116, 116, 
%       190, 192, 2, 7, 11, 20, 26, 26, 56, 56, 108, 108, 108, 108, 117, 117, 
%       117, 117, 191, 193 ], 
%   [ 1, 7, 10, 20, 25, 25, 56, 56, 107, 107, 107, 107, 117, 117, 117, 117, 
%       190, 192, 2, 7, 11, 20, 26, 26, 56, 56, 108, 108, 108, 108, 116, 116, 
%       116, 116, 191, 193 ] ]
% gap> RepresentativesFusions( dp, filt, 2b );
% #I  RepresentativesFusions: Not all table automorphisms of the
% #I    subgroup table act; computing the admiss. subgroup.
% #I  RepresentativesFusions: Not all table automorphisms of the
% #I    supergroup table act; computing the admiss. subgroup.
% #I  RepresentativesFusions: 2 orbit(s) of length(s) [ 1, 1 ]
% [ [ 1, 7, 10, 20, 25, 25, 56, 56, 107, 107, 107, 107, 116, 116, 116, 116, 
%       190, 192, 2, 7, 11, 20, 26, 26, 56, 56, 108, 108, 108, 108, 117, 117, 
%       117, 117, 191, 193 ], 
%   [ 1, 7, 10, 20, 25, 25, 56, 56, 107, 107, 107, 107, 117, 117, 117, 117, 
%       190, 192, 2, 7, 11, 20, 26, 26, 56, 56, 108, 108, 108, 108, 116, 116, 
%       116, 116, 191, 193 ] ]
% gap> List( filt, x -> ConsiderStructureConstants( dp, 2b, x ) );
% [ true, true ]
% \endexample
% 
% So we still have a problem!!
% 
% Is 116 or 117 inside L2(31) ?
% (order 16, cont. in 2xD32)
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$U_3(3).2 \rightarrow Fi_{24}^{\prime}$ (November 2002)}

The group $G = Fi_{24}^{\prime}$ contains a maximal subgroup $H$ of type
$U_3(3).2$.  From the character tables of $G$ and $H$, one gets a lot of
essentially different possibilities (and additionally this takes quite some
time).
We use the description of $H$ as the normalizer in $G$ of a $U_3(3)$ type
subgroup containing elements in the classes `2B', `3D', `3E', `4C', `4C',
`6J', `7B', `8C', and `12M' (see~\cite{BN95}).
% ``Improvements to the ATLAS''

\beginexample
gap> t:= CharacterTable( "F3+" );
CharacterTable( "F3+" )
gap> s:= CharacterTable( "U3(3).2" );
CharacterTable( "U3(3).2" )
gap> tnames:= ClassNames( t, "ATLAS" );
[ "1A", "2A", "2B", "3A", "3B", "3C", "3D", "3E", "4A", "4B", "4C", "5A", 
  "6A", "6B", "6C", "6D", "6E", "6F", "6G", "6H", "6I", "6J", "6K", "7A", 
  "7B", "8A", "8B", "8C", "9A", "9B", "9C", "9D", "9E", "9F", "10A", "10B", 
  "11A", "12A", "12B", "12C", "12D", "12E", "12F", "12G", "12H", "12I", 
  "12J", "12K", "12L", "12M", "13A", "14A", "14B", "15A", "15B", "15C", 
  "16A", "17A", "18A", "18B", "18C", "18D", "18E", "18F", "18G", "18H", 
  "20A", "20B", "21A", "21B", "21C", "21D", "22A", "23A", "23B", "24A", 
  "24B", "24C", "24D", "24E", "24F", "24G", "26A", "27A", "27B", "27C", 
  "28A", "29A", "29B", "30A", "30B", "33A", "33B", "35A", "36A", "36B", 
  "36C", "36D", "39A", "39B", "39C", "39D", "42A", "42B", "42C", "45A", 
  "45B", "60A" ]
gap> OrdersClassRepresentatives( s );
[ 1, 2, 3, 3, 4, 4, 6, 7, 8, 12, 2, 4, 6, 8, 12, 12 ]
gap> sfust:= List( [ "1A", "2B", "3D", "3E", "4C", "4C", "6J", "7B", "8C",
>                    "12M" ], x -> Position( tnames, x ) );
[ 1, 3, 7, 8, 11, 11, 22, 25, 28, 50 ]
gap> sfust:= PossibleClassFusions( s, t, rec( fusionmap:= sfust ) );
[ [ 1, 3, 7, 8, 11, 11, 22, 25, 28, 50, 3, 9, 23, 28, 43, 43 ], 
  [ 1, 3, 7, 8, 11, 11, 22, 25, 28, 50, 3, 11, 23, 28, 50, 50 ] ]
gap> OrdersClassRepresentatives( s );
[ 1, 2, 3, 3, 4, 4, 6, 7, 8, 12, 2, 4, 6, 8, 12, 12 ]
\endexample

So we still have two possibilities, which differ on the outer classes of
element order $4$ and $12$.

Our idea is to take a subgroup $U$ of $H$ that contains such elements,
and to compute the possible class fusions of $U$ into $G$, via the
factorization through a suitable maximal subgroup $M$ of $G$.

We take $U = N_H(\langle g \rangle)$ where $g$ is an element in the first
class of order three elements of $H$;
this is a maximal subgroup of $H$, of order $216$.

\beginexample
gap> Maxes( s );
[ "U3(3)", "3^(1+2):SD16", "L3(2).2", "2^(1+4).S3", "4^2:D12" ]
gap> SizesCentralizers( s );
[ 12096, 192, 216, 18, 96, 32, 24, 7, 8, 12, 48, 48, 6, 8, 12, 12 ]
gap> u:= CharacterTable( Maxes( s )[2] );;
gap> ufuss:= GetFusionMap( u, s );
[ 1, 2, 11, 3, 4, 5, 12, 7, 13, 9, 9, 15, 16, 10 ]
\endexample

Candidates for $M$ are those subgroups of $G$ that contain elements
in the class `3D' of $G$ whose centralizer is the full `3D' centralizer
in $G$.

\beginexample
gap> 3Dcentralizer:= SizesCentralizers( t )[7];
153055008
gap> cand:= [];;                                                               
gap> for name in Maxes( t ) do
>      m:= CharacterTable( name );
>      mfust:= GetFusionMap( m, t );        
>      if ForAny( [ 1 .. Length( mfust ) ],                    
>          i -> mfust[i] = 7 and SizesCentralizers( m )[i] = 3Dcentralizer )   
>      then
>        Add( cand, m );
>      fi;
>    od;
gap> cand;
[ CharacterTable( "3^7.O7(3)" ), CharacterTable( "3^2.3^4.3^8.(A5x2A4).2" ) ]
\endexample

For these two groups $M$, we show that the possible class fusions from $U$
to $G$ via $M$ factorize through $H$ only if the second possible class fusion
from $H$ to $G$ is chosen.

\beginexample
gap> possufust:= List( sfust, x -> CompositionMaps( x, ufuss ) );
[ [ 1, 3, 3, 7, 8, 11, 9, 22, 23, 28, 28, 43, 43, 50 ], 
  [ 1, 3, 3, 7, 8, 11, 11, 22, 23, 28, 28, 50, 50, 50 ] ]
gap> m:= cand[1];;
gap> ufusm:= PossibleClassFusions( u, m );;
gap> Length( ufusm );
242
gap> comp:= List( ufusm, x -> CompositionMaps( GetFusionMap( m, t ), x ) );;
gap> Intersection( possufust, comp );
[ [ 1, 3, 3, 7, 8, 11, 11, 22, 23, 28, 28, 50, 50, 50 ] ]
gap> m:= cand[2];;
gap> ufusm:= PossibleClassFusions( u, m );;
gap> Length( ufusm );                        
256
gap> comp:= List( ufusm, x -> CompositionMaps( GetFusionMap( m, t ), x ) );;   
gap> Intersection( possufust, comp );
[ [ 1, 3, 3, 7, 8, 11, 11, 22, 23, 28, 28, 50, 50, 50 ] ]
\endexample

Finally, we check that the correct fusion is stored in the {\GAP} Character
Table Library.

\beginexample
gap> GetFusionMap( s, t ) = sfust[2];
true
\endexample

% challenge:
% How much of the information about the classes of $U_3(3)$ is really needed?
% For example, (just) twelve possibilities satisfy the factorization of
% fusions from the $L_2(7).2$ subgroups.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$L_2(13).2 \rightarrow Fi_{24}^{\prime}$ (September 2002)}

The class fusion of maximal subgroups $U$ of type $L_2(13).2$
in $G = Fi_{24}^{\prime}$ is ambiguous.

\beginexample
gap> t:= CharacterTable( "F3+" );;
gap> u:= CharacterTable( "L2(13).2" );;
gap> fus:= PossibleClassFusions( u, t );;
gap> repr:= RepresentativesFusions( u, fus, t );;
gap> Length( repr );
3
\endexample

In~\cite[p.~155]{LW91}, it is stated that $U^{\prime}$ contains elements
in the classes `2B', `3D', and `7B' of $G$.
(Note that the two conjugacy classes of groups isomorphic to $U$ have
the same class fusion because the outer automorphism of $G$ fixes
the relevant classes.)

\beginexample
gap> filt:= Filtered( repr, x -> t.2b in x and t.3d in x and t.7b in x );
[ [ 1, 3, 7, 22, 25, 25, 25, 51, 3, 9, 43, 43, 53, 53, 53 ], 
  [ 1, 3, 7, 22, 25, 25, 25, 51, 3, 11, 50, 50, 53, 53, 53 ] ]
gap> ClassNames( t ){ [ 43, 50 ] };
[ "12f", "12m" ]
\endexample

So we have to decide whether $U$ contains elements in the class `12F' or
in `12M' of $G$.

The order $12$ elements in question lie inside subgroups of type $13 : 12$
in $U$.
These subgroups are clearly contained in the Sylow $13$ normalizers of $G$,
which are contained in maximal subgroups of type $(3^2:2 \times G_2(3)).2$
in $G$;
the class fusion of the latter groups is unique up to table automorphisms.

\beginexample
gap> pos:= Position( OrdersClassRepresentatives( t ), 13 );
51
gap> SizesCentralizers( t )[ pos ];
234
gap> ClassOrbit( t, pos );
[ 51 ]
gap> cand:= [];;                                                         
gap> for name in Maxes( t ) do
>      m:= CharacterTable( name );
>      pos:= Position( OrdersClassRepresentatives( m ), 13 );
>      if pos <> fail and                                             
>         SizesCentralizers( m )[ pos ] = 234                         
>         and ClassOrbit( m, pos ) = [ pos ] then
>        Add( cand, m );
>      fi;
>    od;
gap> cand;
[ CharacterTable( "(3^2:2xG2(3)).2" ) ]
gap> s:= cand[1];;
gap> sfust:= PossibleClassFusions( s, t );;
\endexample

As no $13:12$ type subgroup is contained in the derived subgroup of
$(3^2:2 \times G_2(3)).2$, we look at the elements of order $12$ in the
outer half.

\beginexample
gap> der:= ClassPositionsOfDerivedSubgroup( s );;
gap> outer:= Difference( [ 1 .. NrConjugacyClasses( s ) ], der );;
gap> sfust:= PossibleClassFusions( s, t );;
gap> imgs:= Set( Flat( List( sfust, x -> x{ outer } ) ) );
[ 2, 3, 10, 11, 15, 17, 18, 19, 21, 22, 26, 44, 45, 49, 50, 52, 62, 83, 87, 
  98 ]
gap> t.12f in imgs;
false
gap> t.12m in imgs;
true
\endexample

So $L_2(13).2 \setminus L_2(13)$ does not contain `12F' elements of $G$,
i.~e., we have determined the class fusion of $U$ in $G$.

Finally, we check whether the correct fusion is stored in the
{\GAP} Character Table Library.

\beginexample
gap> GetFusionMap( u, t ) = filt[2];
true
\endexample


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \subsection{$2.HS.2 \rightarrow HN$}
% 
% 
% \beginexample
% - 2.HS.2 -> HN (2 possibilities)
% 
% note that HNN2A = 2.HS.2
% 
% rep:=
% #I  RepresentativesFusions: 2 orbit(s) of length(s) [ 8, 8 ]
% [ [ 1, 2, 2, 3, 7, 4, 14, 6, 6, 7, 10, 21, 9, 22, 13, 26, 30, 14, 15, 17, 33,
%       19, 18, 21, 23, 41, 29, 45, 31, 34, 48, 39, 40, 2, 3, 6, 7, 18, 14, 14,
%       15, 19, 19, 22, 27, 28, 30, 33, 33, 53, 54, 39, 39, 40, 40, 48, 48 ],
%   [ 1, 2, 2, 3, 7, 4, 14, 6, 6, 7, 10, 21, 9, 22, 13, 26, 30, 14, 15, 17, 33,
%       19, 18, 21, 23, 41, 29, 45, 31, 34, 48, 39, 40, 2, 3, 6, 7, 18, 14, 14,
%       15, 19, 19, 22, 27, 28, 30, 33, 33, 53, 54, 40, 40, 39, 39, 48, 48 ] ]
% gap> Parametrized( rep ); 
% [ 1, 2, 2, 3, 7, 4, 14, 6, 6, 7, 10, 21, 9, 22, 13, 26, 30, 14, 15, 17, 33,
%   19, 18, 21, 23, 41, 29, 45, 31, 34, 48, 39, 40, 2, 3, 6, 7, 18, 14, 14, 15,
%   19, 19, 22, 27, 28, 30, 33, 33, 53, 54, [ 39, 40 ], [ 39, 40 ], [ 39, 40 ],
%   [ 39, 40 ], 48, 48 ]
% gap> ClassNames( hn ){[39,40]};
% [ "20a", "20b" ]
% (irrational values, and s.c. do not help!)
% 
% problem is: more than one pair of 20a/b classes!
% 
% (distinguished only by $\chi_{41,42}^{\pm}$
% 
% gap> t:= CharacterTable( "HN" );
% CharacterTable( "HN" )
% gap> s:= CharacterTable( "2.HS.2" );
% CharacterTable( "2.HS.2" )
% 
% try the Sylow 5 normalizer in 2.HS.2:
% 
% gap> u:= CharacterTable( "2.HS.2N5" );
% CharacterTable( "2.HS.2N5" )
% gap> s;
% CharacterTable( "2.HS.2" )
% gap> GetFusionMap( u, s );
% [ 1, 2, 11, 12, 13, 14, 15, 16, 4, 3, 25, 24, 10, 10, 23, 23, 23, 23, 8, 33, 
%   32, 5, 5, 26, 26, 35, 45, 46, 38, 50, 51, 38, 51, 50, 52, 53, 36, 54, 55, 
%   38, 38 ]
% gap> SizesConjugacyClasses( u );
% [ 1, 1, 4, 4, 40, 40, 80, 80, 25, 25, 100, 100, 250, 250, 500, 500, 500, 500, 
%   100, 200, 200, 50, 50, 200, 200, 200, 400, 400, 100, 200, 200, 100, 200, 
%   200, 200, 200, 200, 200, 200, 500, 500 ]
% gap> OrdersClassRepresentatives( u );
% [ 1, 2, 5, 10, 5, 10, 5, 10, 2, 2, 10, 10, 4, 4, 8, 8, 8, 8, 4, 20, 20, 4, 4, 
%   20, 20, 2, 10, 10, 8, 40, 40, 8, 40, 40, 20, 20, 4, 20, 20, 8, 8 ]
% gap> sfust:= GetFusionMap( s, t );
% [ 1, 2, 2, 3, 7, 4, 14, 6, 6, 7, 10, 21, 9, 22, 13, 26, 30, 14, 15, 17, 33, 
%   19, 18, 21, 23, 41, 29, 45, 31, 34, 48, 39, 40, 2, 3, 6, 7, 18, 14, 14, 15, 
%   19, 19, 22, 27, 28, 30, 33, 33, 53, 54, 40, 40, 39, 39, 48, 48 ]
% gap> sfust[11];
% 10
% gap> ClassNames( t )[ sfust[11] ];
% "5b"
% 
% so it is contained in the 5B normalizer in HN (HNN5B = HNM6, order 2*10^6)
% 
% gap> n:= CharacterTable( "HNM6" );
% CharacterTable( "5^(1+4):2^(1+4).5.4" )
% gap> GetFusionMap( n, t );
% [ 1, 10, 9, 13, 11, 12, 10, 3, 23, 2, 6, 21, 22, 26, 39, 40, 10, 11, 12, 13, 
%   13, 47, 46, 23, 24, 25, 27, 28, 3, 7, 7, 19, 27, 28, 24, 25, 23, 41, 41, 8, 
%   8, 18, 18, 18, 18, 42, 43, 42, 43, 53, 53, 54, 54 ]
% gap> ufusn:= PossibleClassFusions( u, n );;
% #I  RepresentativesFusions: 2 orbit(s) of length(s) [ 32, 32 ]
% 
% 
% so the same problem occurs already in these subgroups!
% (NB: 2.HS.2N5 = HNN10A, order 8000)
% [hence this problem can be solved if the original problem is solved;
% add the corresponding fusion then!]
% 
% permutation character of degree 5775 for HS.2:
% the preimage of the 2A normalizer in HS.2 contains 20AB and 20D, 20E elements
% 
% construct the group:
% 
% gap> g;  # from atlasrep!
% <permutation group of size 177408000 with 2 generators>
% gap> syl2:= SylowSubgroup( g, 2 );
% <permutation group with 10 generators>
% gap> repeat x:= Random( syl2 ); until Order( x ) = 4;
% gap> c:= Centralizer( g, x );; Size( c );
% 512
% gap> repeat x:= Random( syl2 ); until Order( x ) = 4;
% gap> c:= Centralizer( g, x );; Size( c );
% 7680
% gap> n:= Normalizer( g, Subgroup( g, [ x ] ) );;
% Size( n );
% gap> Size( n );
% 15360
% gap> nn:= Normalizer( g, n );
% Size( nn );
% <permutation group with 7 generators>
% gap> Size( nn );
% 30720
% gap> n:= nn;;
% gap> nt:= CharacterTable( n );;
% gap> Irr( nt );;
% gap> ntfuss:= PossibleClassFusions( nt, s );;
% #I  RepresentativesFusions: 1 orbit(s) of length(s) [ 32 ]
% #I  PossibleClassFusions: 32 solutions
% gap> ntfust:= PossibleClassFusions( nt, t );;
% #I  RepresentativesFusions: 2 orbit(s) of length(s) [ 8, 8 ]
% #I  PossibleClassFusions: 16 solutions
% gap> rep:= RepresentativesFusions( nt, ntfust, t );
% #I  RepresentativesFusions: 2 orbit(s) of length(s) [ 8, 8 ]
% [ [ 1, 3, 6, 2, 6, 3, 6, 3, 2, 2, 2, 7, 7, 19, 6, 6, 6, 6, 19, 19, 7, 3, 7, 
%       6, 7, 2, 3, 6, 7, 7, 2, 3, 19, 19, 18, 18, 19, 19, 15, 14, 15, 15, 4, 
%       31, 14, 14, 39, 40, 40, 39, 39, 10, 23, 21, 21, 40, 30, 14, 15, 30, 15, 
%       14 ], [ 1, 3, 6, 2, 6, 3, 6, 3, 2, 2, 2, 7, 7, 19, 6, 6, 6, 6, 19, 19, 
%       7, 3, 7, 6, 7, 2, 3, 6, 7, 7, 2, 3, 19, 19, 18, 18, 19, 19, 15, 14, 15, 
%       15, 4, 31, 14, 14, 39, 40, 40, 39, 40, 10, 23, 21, 21, 39, 30, 14, 15, 
%       30, 15, 14 ] ]
% gap> Parametrized( rep );
% [ 1, 3, 6, 2, 6, 3, 6, 3, 2, 2, 2, 7, 7, 19, 6, 6, 6, 6, 19, 19, 7, 3, 7, 6, 
%   7, 2, 3, 6, 7, 7, 2, 3, 19, 19, 18, 18, 19, 19, 15, 14, 15, 15, 4, 31, 14, 
%   14, 39, 40, 40, 39, [ 39, 40 ], 10, 23, 21, 21, [ 39, 40 ], 30, 14, 15, 30, 
%   15, 14 ]
% gap> SizesConjugacyClasses( nt );
% [ 1, 1, 4, 30, 60, 30, 48, 40, 40, 1, 1, 240, 240, 960, 120, 120, 120, 120, 
%   480, 480, 480, 480, 480, 480, 160, 80, 80, 480, 480, 160, 80, 80, 960, 960, 
%   1920, 1920, 960, 960, 640, 1280, 640, 320, 320, 1280, 320, 320, 768, 768, 
%   768, 768, 768, 384, 384, 384, 384, 768, 1280, 640, 640, 1280, 640, 640 ]
% 
% 
% so nt lies in the 2B centralizer!
% 
% gap> v:= CharacterTable( "HNM4" ); 
% CharacterTable( "2^(1+8).(A5xA5).2" )
% gap> ntfusv:= PossibleClassFusions( nt, v );;
% #I  RepresentativesFusions: 2 orbit(s) of length(s) [ 16, 16 ]
% #I  PossibleClassFusions: 32 solutions
% gap> rep:= RepresentativesFusions( nt, ntfusv, v );
% #I  RepresentativesFusions: 2 orbit(s) of length(s) [ 16, 16 ]
% [ [ 1, 2, 5, 3, 5, 4, 5, 4, 3, 3, 3, 17, 17, 18, 15, 15, 15, 15, 18, 18, 17, 
%       14, 44, 43, 44, 41, 42, 43, 44, 44, 41, 42, 46, 46, 47, 47, 46, 46, 25, 
%       24, 26, 23, 22, 27, 24, 24, 37, 38, 38, 37, 37, 34, 35, 36, 36, 38, 50, 
%       49, 48, 50, 48, 49 ], 
%   [ 1, 2, 5, 3, 5, 4, 5, 4, 3, 3, 3, 17, 17, 18, 15, 15, 15, 15, 18, 18, 17, 
%       14, 44, 43, 44, 41, 42, 43, 44, 44, 41, 42, 46, 46, 47, 47, 46, 46, 25, 
%       24, 26, 23, 22, 27, 24, 24, 37, 38, 38, 37, 38, 34, 35, 36, 36, 37, 50, 
%       49, 48, 50, 48, 49 ] ]
% gap> Parametrized( rep );
% [ 1, 2, 5, 3, 5, 4, 5, 4, 3, 3, 3, 17, 17, 18, 15, 15, 15, 15, 18, 18, 17, 
%   14, 44, 43, 44, 41, 42, 43, 44, 44, 41, 42, 46, 46, 47, 47, 46, 46, 25, 24, 
%   26, 23, 22, 27, 24, 24, 37, 38, 38, 37, [ 37, 38 ], 34, 35, 36, 36, 
%   [ 37, 38 ], 50, 49, 48, 50, 48, 49 ]
% 
% so we have the same problem again!!
% [NB: the subgroup is HNN4A!]
% 
% systematically:
% which maxes of 2.HS.2 can contain elements in both 20AB and 20DE?
% (for that, first those maxes of HS that contain elements in 20AB!)
% 
% gap> hs;
% CharacterTable( "HS" )
% gap> maxes:= List( Maxes( hs ), CharacterTable );
% [ CharacterTable( "M22" ), CharacterTable( "U3(5).2" ), 
%   CharacterTable( "HSM3" ), CharacterTable( "L3(4).2_1" ), 
%   CharacterTable( "A8.2" ), CharacterTable( "2^4.s6" ), 
%   CharacterTable( "4^3:psl(3,2)" ), CharacterTable( "M11" ), 
%   CharacterTable( "HSM9" ), CharacterTable( "4.2^4.S5" ), 
%   CharacterTable( "2xa6.2^2" ), CharacterTable( "5:4xa5" ) ]
% gap> perms:= List( maxes, x -> TrivialCharacter( x )^hs );;
% gap> List( perms, x -> x[23] );
% [ 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 2 ]
% gap> Filtered( perms, x -> x[23] <> 0 );
% [ Character( CharacterTable( "HS" ), [ 176, 16, 12, 5, 16, 0, 4, 1, 6, 1, 3, 
%       1, 1, 0, 2, 2, 1, 2, 0, 0, 1, 0, 1, 1 ] ), 
%   Character( CharacterTable( "HS" ), [ 176, 16, 12, 5, 16, 0, 4, 1, 6, 1, 3, 
%       1, 1, 0, 2, 2, 1, 2, 0, 0, 1, 0, 1, 1 ] ), 
%   Character( CharacterTable( "HS" ), [ 5775, 111, 75, 15, 31, 15, 3, 25, 0, 
%       0, 3, 3, 0, 3, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1 ] ), 
%   Character( CharacterTable( "HS" ), [ 36960, 32, 216, 6, 32, 0, 8, 10, 25, 
%       0, 0, 2, 0, 0, 0, 0, 2, 1, 0, 0, 2, 1, 2, 2 ] ) ]
% 
% The first two do not extend to HS.2, the novelty HS.2N5 has been considered
% already.
% The third extends to HS.2N2A, which was considered above.
% The last one:
% Trying the preimage of 5:4xS5 does not help: does not contain 20DE elements
% 
% 
% what about subgroups of HN that may contain the interesting subgroups
% of 2.HS.2:
% 
% gap> maxes:= List( Maxes( t ), CharacterTable );
% [ CharacterTable( "A12" ), CharacterTable( "2.HS.2" ), 
%   CharacterTable( "U3(8).3_1" ), CharacterTable( "2^(1+8).(A5xA5).2" ), 
%   CharacterTable( "(D10xU3(5)).2" ), CharacterTable( "5^(1+4):2^(1+4).5.4" ), 
%   CharacterTable( "2^6.U4(2)" ), CharacterTable( "(A6xA6).D8" ), 
%   CharacterTable( "2^3.2^2.2^6.(3xL3(2))" ), CharacterTable( "5^2.5.5^2.4A5" )
%     , CharacterTable( "M12.2" ), CharacterTable( "HNM12" ), 
%   CharacterTable( "3^4:2(A4xA4).4" ), CharacterTable( "3^(1+4):4A5" ) ]
% gap> Position( OrdersClassRepresentatives( t ), 20 );
% 39
% gap> filt:= Filtered( maxes, x -> 39 in GetFusionMap( x, t ) );
% [ CharacterTable( "2.HS.2" ), CharacterTable( "2^(1+8).(A5xA5).2" ), 
%   CharacterTable( "(D10xU3(5)).2" ), CharacterTable( "5^(1+4):2^(1+4).5.4" ) ]
% gap> fus:= GetFusionMap( filt[3], t );
% [ 1, 2, 4, 7, 10, 9, 13, 14, 17, 18, 21, 9, 22, 34, 41, 9, 13, 11, 12, 48, 
%   51, 52, 53, 54, 22, 7, 6, 30, 18, 41, 31, 39, 40, 2, 3, 14, 7, 21, 22, 26, 
%   15, 33, 18, 23, 7, 6, 30, 18, 41, 31, 40, 39 ]
% gap> PositionsProperty( fus, x -> x = 6 );
% [ 27, 46 ]
% gap> SizesCentralizers( filt[3] ){[27,46]};
% [ 480, 480 ]
% gap> u;
% CharacterTable( "2.HS.2N5" )
% gap> PossibleClassFusions( u, filt[3] );
% #I  InitFusion: no images possible for class 4
% #I  PossibleClassFusions: no initialisation possible
% [  ]
% gap> OrdersClassRepresentatives( filt[3] );
% [ 1, 2, 3, 4, 5, 5, 5, 6, 7, 8, 10, 5, 10, 15, 20, 5, 5, 5, 5, 30, 35, 35, 
%   40, 40, 10, 4, 4, 12, 8, 20, 12, 20, 20, 2, 2, 6, 4, 10, 10, 10, 6, 14, 8, 
%   10, 4, 4, 12, 8, 20, 12, 20, 20 ]
% 
% ?????
% 
% 
% try to compute the intersection of 2.HS.2N5 with (D10xU3(5)).2,
% which is the 10A normalizer inside the second group
% (note that the first group is the full 10A normalizer in HN!),
% which has index 2 in the first group
% 
% gap> syl5:= SylowSubgroup( g, 5 );
% <permutation group of size 125 with 3 generators>
% gap> ns:= Normalizer( g, syl5 );
% <permutation group of size 8000 with 6 generators>
% gap> dns:= DerivedSubgroup( ns );
% <permutation group of size 1000 with 5 generators>
% gap> Centre( ns );
% <permutation group with 1 generators>
% gap> Size( g ) / 4;
% 44352000
% gap> Centre( g );
% <permutation group of size 2 with 1 generators>
% gap> IsSubset( ns, Centre( g ) );
% true
% gap> Centre( ns );
% <permutation group with 1 generators>
% gap> Size( Centre( ns ) );
% 2
% gap> cl:= ClosureGroup( ns, Centre( ns ) );
% <permutation group of size 8000 with 6 generators>
% gap> cl:= ClosureGroup( dns, Centre( ns ) );
% <permutation group of size 1000 with 5 generators>
% gap> nathom:= NaturalHomomorphismByNormalSubgroup( ns, dns );;
% gap> fact:= Image( nathom );
% Group([ f1, f2, f3 ])
% gap> AbelianInvariants( fact );
% [ 2, 4 ]
% 
% so three possibilities!
% 
% gap> pc:= Image( IsomorphismPcGroup( ns ) );
% Group([ f1, f2, f3, f4, f5, f6, f7, f8, f9 ])
% gap> Size( pc );
% 8000
% gap> ccl:= ConjugacyClasses( pc );;
% gap> reps:= List( ccl, Representative );;
% gap> filt:= Filtered( reps, x -> Order( x ) = 10 );;
% gap> Length( filt );
% 7
% gap> List( filt, x -> Size( Normalizer( pc, Subgroup( pc, [ x ] ) ) ) );
% [ 320, 320, 400, 800, 8000, 40, 40 ]
% gap> dns:= DerivedSubgroup( pc );
% Group([ f2*f3*f4*f7*f8^3, f4*f5*f6, f6, f7, f8, f9 ])
% gap> Size( dns );
% 1000
% gap> c1:= ClosureGroup( dns, Pcgs( pc ){ [ 4, 5 ] } );
% Group([ f2*f3*f4*f7*f8^3, f4*f5*f6, f5, f6, f7, f8, f9 ])
% gap> Size( c1 );
% 2000
% gap> c1:= ClosureGroup( dns, Pcgs( pc ){ [ 3, 4, 5 ] } );
% Group([ f2*f3*f4*f7*f8^3, f3, f4*f5*f6, f5, f6, f7, f8, f9 ])
% gap> Size( c1 );
% 4000
% gap> c2:= ClosureGroup( dns, Pcgs( pc ){ [ 2, 4, 5 ] } );
% Group([ f2*f3*f4*f7*f8^3, f3*f4*f5*f6*f9^4, f4*f5*f6, f5, f6, f7, f8, f9 ])
% gap> Size( c1 );
% 4000
% gap> Size( c2 );
% 4000
% gap> c1 = c2;
% true
% gap> c2:= ClosureGroup( dns, Pcgs( pc ){ [ 1, 4, 5 ] } );
% Group([ f1, f2*f3*f4*f7*f8^3, f4, f5, f6, f7, f8, f9 ])
% gap> Size( c2 );
% 4000
% gap> c1 = c2;
% false
% gap> c3:= ClosureGroup( dns, Pcgs( pc ){ [ 4, 5 ] } );
% Group([ f2*f3*f4*f7*f8^3, f4*f5*f6, f5, f6, f7, f8, f9 ])
% gap> Size( c3 );
% 2000
% gap> c3:= ClosureGroup( c3, Product( Pcgs( pc ){ [ 1, 2 ] } ) );
% Group([ f1*f2, f2*f3*f4*f7*f8^3, f4, f5, f6, f7, f8, f9 ])
% gap> Size( c3 );
% 4000
% gap> c1 = c3;
% false
% gap> c2 = c3;
% false
% gap> tbls:= List( [ c1, c2, c3 ], CharacterTable );;
% gap> List( tbls, Irr );;
% gap> List( tbls, NrConjugacyClasses );
% [ 34, 46, 46 ]
% gap> filt:= Filtered( maxes, x -> 39 in GetFusionMap( x, t ) );
% [ CharacterTable( "2.HS.2" ), CharacterTable( "2^(1+8).(A5xA5).2" ), 
%   CharacterTable( "(D10xU3(5)).2" ), CharacterTable( "5^(1+4):2^(1+4).5.4" ) ]
% gap> PossibleClassFusions( tbls[2], filt[3] );;
% #I  PossibleClassFusions: fusion initialized
% #I  TransferDiagram: inconsistency at class 23
% #I  TestConsistencyMaps: inconsistency in powermap 2
% #I  PossibleClassFusions: inconsistency of fusion and power maps
% gap> PossibleClassFusions( tbls[3], filt[3] );;
% #I  InitFusion: no images possible for class 18
% #I  PossibleClassFusions: no initialisation possible
% gap> myfus:= PossibleClassFusions( tbls[1], filt[3] );;
% #I  RepresentativesFusions: 1 orbit(s) of length(s) [ 16 ]
% #I  PossibleClassFusions: 16 solutions
% 
% so just one possibility!
% 
% gap> newfus:= PossibleClassFusions( tbls[1], u );;
% #I  RepresentativesFusions: 1 orbit(s) of length(s) [ 16 ]
% #I  PossibleClassFusions: 16 solutions
% gap> Set( List( newfus, x -> CompositionMaps( GetFusionMap( u, s ), x ) ) );
% [ [ 1, 11, 15, 13, 3, 24, 10, 10, 10, 10, 25, 4, 16, 14, 12, 2, 23, 23, 23, 
%       23, 32, 8, 33, 26, 5, 26, 5, 8, 32, 33, 23, 23, 23, 23 ], 
%   [ 1, 11, 15, 13, 3, 24, 10, 10, 10, 10, 25, 4, 16, 14, 12, 2, 23, 23, 23, 
%       23, 33, 8, 32, 26, 5, 26, 5, 8, 33, 32, 23, 23, 23, 23 ] ]
% 
% Aha.
% The intersection lies inside 2.HS, thus this does not help!!
% 
% Only idea now:
% Explicitly compute HNN10A -> HNN5B from the group!
% 
% 
% gap> g:= OneAtlasGeneratingSet( "HN", Dimension, 132 );
% rec( generators := [ < immutable compressed matrix 132x132 over GF(4) >, 
%       < immutable compressed matrix 132x132 over GF(4) > ], 
%   standardization := 1, 
%   identifier := [ "HN", [ "HNG1-f4r132aB0.m1", "HNG1-f4r132aB0.m2" ], 1, 4 ] )
% gap> prg:= AtlasStraightLineProgram( "HN", "maxes", 6 );
% rec( program := <straight line program>, standardization := 1, 
%   identifier := [ "HN", "HNG1-max6W1", 1 ] )
% gap> s:= ResultOfStraightLineProgram( prg.program, g.generators );
% [ < immutable compressed matrix 132x132 over GF(4) >, 
%   < immutable compressed matrix 132x132 over GF(4) > ]
% gap> s:= Group( s );
% <matrix group with 2 generators>
% gap> SetSize( s, 2*10^6 );
% gap> iso:= IsomorphismPermGroup( s );;
% 
% .....
% \endexample
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \subsection{$D_8 \times V_4 \rightarrow HS$}
% 
% Let $G$ denote the sporadic simple Higman-Sims group $HS$,
% and choose a Sylow $2$ subgroup $S$ of $G$.
% 
% The subgroup $D_8 \times V_4$ occurs as an intersection of the normalizer of
% $S$ in $G$ with the normalizer of an element in the class {\tt 2B} of $G$.
% (There is exactly one $G$-conjugacy class of such groups.)
% 
% \beginexample
% gap> g:= OneAtlasGeneratingSet( "HS", NrMovedPoints, 100 );;
% gap> g:= Group( g.generators );;
% gap> syl:= SylowSubgroup( g, 2 );;
% gap> syln:= Normalizer( g, syl );;
% gap> id:= IdGroup( DirectProduct( DihedralGroup( 8 ),
% >                                 ElementaryAbelianGroup( 4 ) ) );
% [ 32, 46 ]
% gap> repeat
% >      repeat
% >        x:= Random( syl );
% >      until Order( x ) = 2;
% >      c:= Subgroup( g, [ x ] );
% >      n:= Intersection( syln, Normalizer( g, c ) );
% >    until IdGroup( n ) = id;
% \endexample
% 
% The class fusion is determined uniquely by the natural character in the
% faithful permutation representation of $G$ of degree $100$.
% 
% \beginexample
% gap> hs:= CharacterTable( "HS" );;
% gap> perms:= PermChars( hs, rec( torso:= [ 100 ] ) );
% [ Character( CharacterTable( "HS" ), [ 100, 20, 0, 10, 0, 8, 4, 0, 0, 5, 0, 
%       2, 2, 2, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0 ] ) ]
% gap> nat:= ValuesOfClassFunction( perms[1] );;
% gap> tbl:= CharacterTable( n );;
% gap> libtbl:= CharacterTable( "D8xV4" );;
% gap> trans:= TransformingPermutationsCharacterTables( libtbl, tbl );;
% gap> pi:= List( ConjugacyClasses( tbl ),
% >               x -> 100 - NrMovedPoints( Representative( x ) ) );;
% gap> pi:= Permuted( pi, trans.columns^-1 );
% [ 100, 20, 0, 0, 8, 0, 4, 4, 20, 20, 0, 0, 0, 0, 20, 20, 20, 20, 0, 0 ]
% gap> fus:= InitFusion( libtbl, hs );;
% [ 1, [ 2, 3 ], [ 2, 3 ], [ 2, 3 ], [ 5, 6, 7 ], [ 5, 6, 7 ], [ 5, 6, 7 ], 
%   [ 5, 6, 7 ], [ 2, 3 ], [ 2, 3 ], [ 2, 3 ], [ 2, 3 ], [ 2, 3 ], [ 2, 3 ], 
%   [ 2, 3 ], [ 2, 3 ], [ 2, 3 ], [ 2, 3 ], [ 2, 3 ], [ 2, 3 ] ]
% gap> UpdateMap( nat, fus, pi );;
% gap> fus;
% [ 1, 2, 3, 3, 6, 5, 7, 7, 2, 2, 3, 3, 3, 3, 2, 2, 2, 2, 3, 3 ]
% \endexample
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \subsection{Ambiguities in the MGA case}
% 
% \beginexample
% (mention possible problems in the bicyclic case:
% 3_2.U4(3) -> 3_2.U4(3).2_3' is ambiguous, but the MGA situation determines
% the fusion)
% \endexample
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$M_{11} \rightarrow B$ (April 2009)}\label{M11fusB}

The sporadic simple group $B$ contains a maximal subgroup $M$ of the type
$M_{11}$ whose class fusion is ambiguous.

\beginexample
gap> b:= CharacterTable( "B" );;
gap> m11:= CharacterTable( "M11" );;
gap> m11fusb:= PossibleClassFusions( m11, b );;
gap> Length( m11fusb );
31
gap> CompositionMaps( ClassNames( b, "ATLAS" ), Parametrized( m11fusb ) );
[ "1A", [ "2B", "2D" ], [ "3A", "3B" ], [ "4B", "4E", "4G", "4H", "4J" ], 
  [ "5A", "5B" ], [ "6C", "6E", "6H", "6I", "6J" ], 
  [ "8B", "8E", "8G", "8J", "8K", "8L", "8M", "8N" ], 
  [ "8B", "8E", "8G", "8J", "8K", "8L", "8M", "8N" ], "11A", "11A" ]
\endexample

According to~\cite[Thm.~12.1]{Wil93a}, $M$ contains no `5A' elements of $B$.
By the proof of~\cite[Prop.~4.1]{Wil99},
the involutions in any $S_5$ type subgroup $U$ of $M$
lie in the class `2C' or `2D' of $B$,
and since the possible class fusions of $M$ computed above
admit only involutions in the class `2B' or `2D',
all involutions of $U$ lie in the class `2D'.
Again by the proof of~\cite[Prop.~4.1]{Wil99}, $U$ is contained in a maximal
subgroup of type $Th$ in $B$.

Now we use the embedding of $U$ into $B$ via $M$ and $Th$ for determining
the class fusion of $M$ into $B$.
The class fusion of the embedding of $U$ via $Th$ is uniquely determined.

\beginexample
gap> th:= CharacterTable( "Th" );;
gap> s5:= CharacterTable( "S5" );;
gap> s5fusth:= PossibleClassFusions( s5, th );
[ [ 1, 2, 4, 8, 2, 7, 11 ] ]
gap> thfusb:= PossibleClassFusions( th, b );;
gap> s5fusb:= Set( List( thfusb, x -> CompositionMaps( x, s5fusth[1] ) ) );
[ [ 1, 5, 7, 19, 5, 17, 29 ] ]
\endexample

Also the class fusion of $U$ into $M$ is unique,
and this determines the class fusion of $M$ into $B$.

\beginexample
gap> s5fusm11:= PossibleClassFusions( s5, m11 );
[ [ 1, 2, 3, 5, 2, 4, 6 ] ]
gap> m11fusb:= Filtered( m11fusb,
>                  map -> CompositionMaps( map, s5fusm11[1] ) = s5fusb[1] );
[ [ 1, 5, 7, 17, 19, 29, 45, 45, 54, 54 ] ]
gap> CompositionMaps( ClassNames( b, "ATLAS" ), m11fusb[1] );
[ "1A", "2D", "3B", "4J", "5B", "6J", "8N", "8N", "11A", "11A" ]
\endexample

(Using the information that the $M_{10}$ type subgroups of $M$ are also
contained in $Th$ type subgroups would not have helped us,
since these subgroups do not contain elements of order $6$,
and two possibilities would have remained.)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$L_2(11):2 \rightarrow B$ (April 2009)}

The sporadic simple group $B$ contains a maximal subgroup $L$ of the type
$L_2(11):2$ whose class fusion is ambiguous.

\beginexample
gap> b:= CharacterTable( "B" );;
gap> l:= CharacterTable( "L2(11).2" );;
gap> lfusb:= PossibleClassFusions( l, b );;
gap> Length( lfusb );
16
gap> CompositionMaps( ClassNames( b, "ATLAS" ), Parametrized( lfusb ) );
[ "1A", [ "2B", "2D" ], [ "3A", "3B" ], [ "5A", "5B" ], [ "5A", "5B" ], 
  [ "6C", "6H", "6I", "6J" ], "11A", [ "2C", "2D" ], 
  [ "4D", "4E", "4F", "4G", "4H", "4J" ], [ "10C", "10E", "10F" ], 
  [ "10C", "10E", "10F" ], 
  [ "12E", "12F", "12H", "12I", "12J", "12L", "12N", "12P", "12Q", "12R", 
      "12S" ], 
  [ "12E", "12F", "12H", "12I", "12J", "12L", "12N", "12P", "12Q", "12R", 
      "12S" ] ]
\endexample

According to~\cite[Thm.~12.1]{Wil93a}, $L$ contains no `5A' elements of $B$.
By the proof of~\cite[Prop.~4.1]{Wil99}, $B$ contains exactly one class of
$L_2(11)$ type subgroups with this property.
Hence the subgroup $U$ of index two in $L$ is contained in a maximal subgroup
$M$ of type $M_{11}$ in $B$,
whose class fusion was determined in Section~\ref{M11fusB}.

In the same way as we proceeded in Section~\ref{M11fusB},
we use the embedding of $U$ into $B$ via $L$ and $M$ for determining
the class fusion of $L$ into $B$.

\beginexample
gap> m:= CharacterTable( "M11" );;
gap> u:= CharacterTable( "L2(11)" );;
gap> ufusm:= PossibleClassFusions( u, m );;
gap> mfusb:= GetFusionMap( m, b );;
gap> ufusb:= Set( List( ufusm, x -> CompositionMaps( mfusb, x ) ) );
[ [ 1, 5, 7, 19, 19, 29, 54, 54 ] ]
gap> ufusl:= PossibleClassFusions( u, l );
[ [ 1, 2, 3, 4, 5, 6, 7, 7 ], [ 1, 2, 3, 5, 4, 6, 7, 7 ] ]
gap> lfusb:= Filtered( lfusb, 
>              map2 -> ForAny( ufusl, 
>                        map1 -> CompositionMaps( map2, map1 ) in ufusb ) );
[ [ 1, 5, 7, 19, 19, 29, 54, 5, 15, 53, 53, 73, 73 ] ]
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$L_3(3) \rightarrow B$ (April 2009)}

The sporadic simple group $B$ contains a maximal subgroup $T$ of the type
$L_3(3)$ whose class fusion is ambiguous.

\beginexample
gap> b:= CharacterTable( "B" );;
gap> t:= CharacterTable( "L3(3)" );;
gap> tfusb:= PossibleClassFusions( t, b );;
gap> Length( tfusb );
36
\endexample

According to~\cite[Section~9]{Wil99}, $T$ contains a subgroup $U$ of the type
$3^2:2S_4$ that is contained also in a maximal subgroup $M$ of the type
$3^2.3^3.3^6.(S_4 \times 2S_4)$.
So we throw away the possible fusions from $T$ to $B$ that are not compatible
with the compositions of the embeddings of $U$ into $B$ via $T$ and $M$.

\beginexample
gap> m:= CharacterTable( "3^2.3^3.3^6.(S4x2S4)" );;
gap> g:= PSL(3,3);;
gap> mx:= MaximalSubgroupClassReps( g );;
gap> u:= First( mx, x -> Size( x ) = 432 );;
gap> u:= CharacterTable( u );;
gap> ufusm:= PossibleClassFusions( u, m );;
gap> ufust:= PossibleClassFusions( u, t );;
gap> mfusb:= GetFusionMap( m, b );;
gap> ufusb:= Set( List( ufusm, map -> CompositionMaps( mfusb, map ) ) );;
gap> tfusb:= Filtered( tfusb, map -> ForAny( ufust,
>        map2 -> CompositionMaps( map, map2 ) in ufusb ) );;
gap> tfusb;
[ [ 1, 5, 6, 7, 12, 27, 41, 41, 75, 75, 75, 75 ], 
  [ 1, 5, 7, 6, 12, 28, 41, 41, 75, 75, 75, 75 ], 
  [ 1, 5, 7, 7, 12, 28, 41, 41, 75, 75, 75, 75 ], 
  [ 1, 5, 7, 7, 12, 29, 41, 41, 75, 75, 75, 75 ], 
  [ 1, 5, 7, 7, 17, 29, 45, 45, 75, 75, 75, 75 ] ]
\endexample

Now we use that $T$ does not contain `4E' elements of $B$
(again see~\cite[Section~9]{Wil99}).
Thus the last of the five candidates is the correct class fusion.

\beginexample
gap> ClassNames( b, "ATLAS" ){ [ 12, 17 ] };
[ "4E", "4J" ]
\endexample

We check that this map is stored on the library table.

\beginexample
gap> GetFusionMap( t, b ) = tfusb[5];
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$L_2(17).2 \rightarrow B$ (March 2004)}

The sporadic simple group $B$ contains a maximal subgroup $U$ of the type
$L_2(17).2$ whose class fusion is ambiguous.

\beginexample
gap> b:= CharacterTable( "B" );;
gap> u:= CharacterTable( "L2(17).2" );;
gap> ufusb:= PossibleClassFusions( u, b );
[ [ 1, 5, 7, 15, 42, 42, 47, 47, 47, 91, 4, 30, 89, 89, 89, 89, 97, 97, 97 ], 
  [ 1, 5, 7, 15, 44, 44, 46, 46, 46, 91, 5, 29, 90, 90, 90, 90, 96, 96, 96 ], 
  [ 1, 5, 7, 15, 44, 44, 47, 47, 47, 91, 5, 29, 90, 90, 90, 90, 95, 95, 95 ] ]
\endexample

According to~\cite[Prop.~11.1]{Wil99}, $U$ contains elements in the classes
`8M' and `9A' of $B$.
This determines the fusion map.

\beginexample
gap> names:= ClassNames( b, "ATLAS" );;
gap> pos:= List( [ "8M", "9A" ], x -> Position( names, x ) );
[ 44, 46 ]
gap> ufusb:= Filtered( ufusb, map -> IsSubset( map, pos ) );
[ [ 1, 5, 7, 15, 44, 44, 46, 46, 46, 91, 5, 29, 90, 90, 90, 90, 96, 96, 96 ] ]
\endexample

We check that this map is stored on the library table.

\beginexample
gap> GetFusionMap( u, b ) = ufusb[1];
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$L_2(49).2_3 \rightarrow B$ (June 2006)}

The sporadic simple group $B$ contains a class of maximal subgroups
of the type $L_2(49).2_3$ (a non-split extension of $L_2(49)$,
see~\cite[Theorem~2]{Wilson93}).
Let $U$ be such a subgroup.
The class fusion of $U$ in $B$ is not determined by the character tables
of $U$ and $B$.

\beginexample
gap> u:= CharacterTable( "L2(49).2_3" );;
gap> b:= CharacterTable( "B" );;
gap> ufusb:= PossibleClassFusions( u, b );;
gap> Length( RepresentativesFusions( u, ufusb, b ) );
2
gap> ufusb;
[ [ 1, 5, 7, 15, 19, 28, 31, 42, 42, 71, 125, 125, 128, 128, 128, 128, 128, 
      15, 71, 71, 89, 89, 89, 89 ], 
  [ 1, 5, 7, 15, 19, 28, 31, 42, 42, 71, 125, 125, 128, 128, 128, 128, 128, 
      17, 72, 72, 89, 89, 89, 89 ] ]
\endexample

We show that the fusion is determined by the embeddings of the Sylow $7$
normalizer $N$, say, of $U$ into $U$
and into the Sylow $7$ normalizer of $B$.
(Note that the fusion of the latter group into $B$ has been determined
in Section~\ref{BN7}.)

For that, we compute the character table of $N$ from a representation of $U$.
Note that $U$ is a non-split extension of the simple group $L_2(49)$ by
the product of a diagonal automorphism and a field automorphism.
In~\cite{Wilson93}, the structure of $N$ is described as
$7^2:(3 \times Q_{16})$.

\beginexample
gap> g:= SL( 2, 49 );;
gap> gens:= GeneratorsOfGroup( g );;
gap> f:= GF(49);;
gap> mats:= List( gens, x -> IdentityMat( 4, f ) );;
gap> for i in [ 1 .. Length( gens ) ] do
>      mats[i]{ [ 1, 2 ] }{ [ 1, 2 ] }:= gens[i];
>      mats[i]{ [ 3, 4 ] }{ [ 3, 4 ] }:= List( gens[i],
>                                              x -> List( x, y -> y^7 ) );
>    od;
gap> fieldaut:= PermutationMat( (1,3)(2,4), 4, f );;
gap> diagaut:= IdentityMat( 4, f );;
gap> diagaut[1][1]:= Z(49);;
gap> diagaut[3][3]:= Z(49)^7;;
gap> g:= Group( Concatenation( mats, [ fieldaut * diagaut ] ) );;
gap> v:= [ 1, 0, 0, 0 ] * Z(7)^0;;
gap> orb:= Orbit( g, v, OnLines );;
gap> act:= Action( g, orb, OnLines );;
gap> n:= Normalizer( act, SylowSubgroup( act, 7 ) );;
gap> ntbl:= CharacterTable( n );;
\endexample

Now we compute the possible class fusions of $N$ into $B$, via the Sylow $7$
normalizer in $B$.

\beginexample
gap> bn7:= CharacterTable( "BN7" );;
gap> nfusbn7:= PossibleClassFusions( ntbl, bn7 );;
gap> Length( RepresentativesFusions( ntbl, nfusbn7, bn7 ) );
3
gap> nfusb:= SetOfComposedClassFusions( PossibleClassFusions( bn7, b ),
>                                       nfusbn7 );;
gap> Length( RepresentativesFusions( ntbl, nfusb, b ) );
5
\endexample

Although there are several possibilities, this information is enough to
exclude one of the possible fusions of $U$ into $B$.

\beginexample
gap> nfusu:= PossibleClassFusions( ntbl, u );;
gap> Length( nfusu );
4
gap> filt:= Filtered( ufusb,
>              x -> ForAny( nfusu, y -> CompositionMaps( x, y ) in nfusb ) );
[ [ 1, 5, 7, 15, 19, 28, 31, 42, 42, 71, 125, 125, 128, 128, 128, 128, 128, 
      17, 72, 72, 89, 89, 89, 89 ] ]
gap> ClassNames( b, "ATLAS" ){ filt[1] };
[ "1A", "2D", "3B", "4H", "5B", "6I", "7A", "8K", "8K", "12Q", "24L", "24L", 
  "25A", "25A", "25A", "25A", "25A", "4J", "12R", "12R", "16G", "16G", "16G", 
  "16G" ]
\endexample

So the class fusion of $U$ into $B$ can be described by the property that
the elements of order four inside and outside the simple subgroup $L_2(49)$
are not conjugate in $B$.

We check that the correct map is stored on the library table.

\beginexample
gap> GetFusionMap( u, b ) in filt;
true
\endexample

%T Is it possible that computing L2(49).2_2 -> B is *faster* at info level 2?
%T There are 5 solutions (in 4 orbits) left.

Let us confirm that the two groups of the types $L_2(49).2_1$ and
$L_2(49).2_2$ cannot occur as subgroups of $B$.
First we show that $L_2(49).2_1$ is isomorphic with $\PGL(2,49)$,
an extension of $L_2(49)$ by a diagonal automorphism,
and $L_2(49).2_2$ is an extension by a field automorphism.

\beginexample
gap> NrConjugacyClasses( u );  NrConjugacyClasses( act );
24
24
gap> u:= CharacterTable( "L2(49).2_1" );;
gap> g:= Group( Concatenation( mats, [ diagaut ] ) );;
gap> orb:= Orbit( g, v, OnLines );;
gap> act:= Action( g, orb, OnLines );;
gap> Size(act );
117600
gap> NrConjugacyClasses( u );  NrConjugacyClasses( act );
51
51
gap> u:= CharacterTable( "L2(49).2_2" );;
gap> g:= Group( Concatenation( mats, [ fieldaut ] ) );;
gap> orb:= Orbit( g, v, OnLines );;
gap> act:= Action( g, orb, OnLines );;
gap> NrConjugacyClasses( u );  NrConjugacyClasses( act );
27
27
\endexample

The group $L_2(49).2_1$ can be excluded because no class fusion into $B$
is possible.

\beginexample
gap> PossibleClassFusions( CharacterTable( "L2(49).2_1" ), b );
[  ]
\endexample

For $L_2(49).2_2$, it is not that easy.
We would get several possible class fusions into $B$.
%T Note that computing the possible fusions of $L_2(49).2_2$ into $B$
%T takes *VERY LONG*.
However, the Sylow $7$ normalizer of $L_2(49).2_2$ does not admit
a class fusion into the Sylow $7$ normalizer of $B$.

\beginexample
gap> n:= Normalizer( act, SylowSubgroup( act, 7 ) );;
gap> Length( PossibleClassFusions( CharacterTable( n ), bn7 ) );
0
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$2^3.L_3(2) \rightarrow G_2(5)$ (January~2004)}

The Chevalley group $G = G_2(5)$ contains a maximal subgroup $U$ of the type
$2^3.L_3(2)$ whose class fusion is ambiguous.

\beginexample
gap> t:= CharacterTable( "G2(5)" );;
gap> s:= CharacterTable( "2^3.L3(2)" );;
gap> sfust:= PossibleClassFusions( s, t );;
gap> RepresentativesFusions( s, sfust, t );
[ [ 1, 2, 2, 5, 6, 4, 13, 16, 17, 15, 15 ], 
  [ 1, 2, 2, 5, 6, 4, 14, 16, 17, 15, 15 ] ]
gap> OrdersClassRepresentatives( s );
[ 1, 2, 2, 4, 4, 3, 6, 8, 8, 7, 7 ]
\endexample

So the question is whether $U$ contains elements in the class `6B' or `6C'
of $G$ (position $13$ or $14$ in the {\ATLAS} table).
We use a permutation representation of $G$, restrict it to $U$,
and compute the centralizer in $G$ of a suitable element of order $6$ in $U$.

\beginexample
gap> g:= AtlasGroup( "G2(5)" );;
gap> u:= AtlasSubgroup( "G2(5)", 7 );;
gap> Size( u );
1344
gap> repeat
>      x:= Random( u );
>    until Order( x ) = 6;
gap> siz:= Size( Centralizer( g, x ) );
36
gap> Filtered( [ 1 .. NrConjugacyClasses( t ) ],
>              i -> SizesCentralizers( t )[i] = siz );
[ 14 ]
\endexample

So $U$ contains `6C' elements in $G_2(5)$.

\beginexample
gap> GetFusionMap( s, t ) in Filtered( sfust, map -> 14 in map );  
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$5^{1+4}.2^{1+4}.A_5.4 \rightarrow B$ (April 2009)}

The sporadic simple group $B$ contains a maximal subgroup $M$ of the type
$5^{1+4}.2^{1+4}.A_5.4 \rightarrow B$ whose class fusion is ambiguous.

\beginexample
gap> b:= CharacterTable( "B" );;
gap> m:= CharacterTable( "5^(1+4).2^(1+4).A5.4" );;
gap> mfusb:= PossibleClassFusions( m, b );;
gap> Length( mfusb );
4
gap> repres:= RepresentativesFusions( m, mfusb, b );; 
gap> Length( repres );
2
\endexample

The restriction of the unique irreducible character of degree $4\,371$
distinguishes the two possibilities,

\beginexample
gap> char:= Filtered( Irr( b ), x -> x[1] = 4371 );;
gap> Length( char );
1
gap> rest:= List( repres, map -> char[1]{ map } );;
gap> scprs:= MatScalarProducts( m, Irr( m ), rest );;
gap> constit:= List( scprs,
>                x -> Filtered( [1 .. Length(x) ], i -> x[i] <> 0 ) );
[ [ 2, 27, 60, 63, 73, 74, 75, 79, 82 ], 
  [ 2, 27, 60, 63, 70, 72, 75, 79, 84 ] ]
gap> List( constit, x -> List( Irr( m ){ x }, Degree ) );
[ [ 1, 6, 384, 480, 400, 400, 500, 1000, 1200 ], 
  [ 1, 6, 384, 480, 100, 300, 500, 1000, 1600 ] ]
\endexample

The database~\cite{AGR} contains the $3$-modular reduction of the
irreducible representation of degree $4\,371$
and also a straight line program for restricting this representation
to $M$.
We access these data via the {\GAP} package {\textsf{AtlasRep}}
(see~\cite{AtlasRep}), and compute the composition factors of the
natural module of this restriction.

\beginexample
gap> g:= AtlasSubgroup( "B", Dimension, 4371, Ring, GF(3), 21 );;
gap> module:= GModuleByMats( GeneratorsOfGroup( g ), GF(3) );;
gap> dec:= MTX.CompositionFactors( module );;
gap> SortedList( List( dec, x -> x.dimension ) );
[ 1, 6, 100, 384, 400, 400, 400, 480, 1000, 1200 ]
\endexample

% The `AtlasSubgroup' call needs 5247 seconds,
% the computation of the composition factors needs 911 seconds.

We see that exactly one ordinary constituent does not stay irreducible
upon restriction to characteristic $3$.
Thus the first of the two possible class fusions is the correct one.

% The analogous computation with the degree 4370 in characteristic two
% is much faster.
% However, it does not help us, since this decomposition is finer
% and fits to both possibilities.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The fusion from the character table of $7^2:2L_2(7).2$
into the table of marks (January~2004)}

It can happen that the class fusion from the ordinary character table of a
group $G$ into the table of marks of $G$ is not unique up to table
automorphisms of the character table of $G$.

As an example, consider $G = 7^2:2L_2(7).2$, a maximal subgroup in the
sporadic simple group $He$.

$G$ contains four classes of cyclic subgroups of order $7$.
One contains the elements in the normal subgroup of type $7^2$,
and the other three are preimages of the order $7$ elements in the
factor group $L_2(7)$.
The conjugacy classes of nonidentity elements in the latter three classes
split into two Galois conjugates each, which are permuted cyclicly by the
table automorphisms of the character table of $G$,
but on which the stabilizer of one class acts trivially.
This means that determining one of the three classes determines also the
other two.
% (The degree 48 representations would do the job.)

\beginexample
gap> tbl:= CharacterTable( "7^2:2psl(2,7)" );
CharacterTable( "7^2:2psl(2,7)" )
gap> tom:= TableOfMarks( tbl );
TableOfMarks( "7^2:2L2(7)" )
gap> fus:= PossibleFusionsCharTableTom( tbl, tom );
[ [ 1, 6, 2, 4, 3, 5, 13, 13, 7, 8, 10, 9, 16, 7, 10, 9, 8, 16 ], 
  [ 1, 6, 2, 4, 3, 5, 13, 13, 7, 9, 8, 10, 16, 7, 8, 10, 9, 16 ], 
  [ 1, 6, 2, 4, 3, 5, 13, 13, 7, 10, 9, 8, 16, 7, 9, 8, 10, 16 ], 
  [ 1, 6, 2, 4, 3, 5, 13, 13, 7, 8, 9, 10, 16, 7, 9, 10, 8, 16 ], 
  [ 1, 6, 2, 4, 3, 5, 13, 13, 7, 10, 8, 9, 16, 7, 8, 9, 10, 16 ], 
  [ 1, 6, 2, 4, 3, 5, 13, 13, 7, 9, 10, 8, 16, 7, 10, 8, 9, 16 ] ]
gap> reps:= RepresentativesFusions( tbl, fus, Group(()) );        
[ [ 1, 6, 2, 4, 3, 5, 13, 13, 7, 8, 9, 10, 16, 7, 9, 10, 8, 16 ], 
  [ 1, 6, 2, 4, 3, 5, 13, 13, 7, 8, 10, 9, 16, 7, 10, 9, 8, 16 ] ]
gap> AutomorphismsOfTable( tbl );
Group([ (9,14)(10,17)(11,15)(12,16)(13,18), (7,8), (10,11,12)(15,16,17) ])
gap> OrdersClassRepresentatives( tbl );
[ 1, 7, 2, 4, 3, 6, 8, 8, 7, 7, 7, 7, 14, 7, 7, 7, 7, 14 ]
gap> perms1:= PermCharsTom( reps[1], tom );;
gap> perms2:= PermCharsTom( reps[2], tom );;
gap> perms1 = perms2;      
false
gap> Set( perms1 ) = Set( perms2 );
true
\endexample

The table of marks of $G$ does not distinguish the three classes
of cyclic subgroups,
there are permutations of rows and columns that act as an $S_3$ on them.

Note that an $S_3$ acts on the classes in question in the *rational*
character table.
So it is due to the irrationalities in the character table that it
contains more information.

\beginexample
gap> Display( tbl );
7^2:2psl(2,7)

      2  4  .  4  3  1  1  3  3   1   .   .   .   1   1   .   .   .   1
      3  1  .  1  .  1  1  .  .   .   .   .   .   .   .   .   .   .   .
      7  3  3  1  .  .  .  .  .   2   2   2   2   1   2   2   2   2   1

        1a 7a 2a 4a 3a 6a 8a 8b  7b  7c  7d  7e 14a  7f  7g  7h  7i 14b
     2P 1a 7a 1a 2a 3a 3a 4a 4a  7b  7c  7d  7e  7b  7f  7g  7h  7i  7f
     3P 1a 7a 2a 4a 1a 2a 8b 8a  7f  7i  7g  7h 14b  7b  7d  7e  7c 14a
     5P 1a 7a 2a 4a 3a 6a 8b 8a  7f  7i  7g  7h 14b  7b  7d  7e  7c 14a
     7P 1a 1a 2a 4a 3a 6a 8a 8b  1a  1a  1a  1a  2a  1a  1a  1a  1a  2a
    11P 1a 7a 2a 4a 3a 6a 8b 8a  7b  7c  7d  7e 14a  7f  7g  7h  7i 14b
    13P 1a 7a 2a 4a 3a 6a 8b 8a  7f  7i  7g  7h 14b  7b  7d  7e  7c 14a

X.1      1  1  1  1  1  1  1  1   1   1   1   1   1   1   1   1   1   1
X.2      3  3  3 -1  .  .  1  1   B   B   B   B   B  /B  /B  /B  /B  /B
X.3      3  3  3 -1  .  .  1  1  /B  /B  /B  /B  /B   B   B   B   B   B
X.4      6  6  6  2  .  .  .  .  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1
X.5      7  7  7 -1  1  1 -1 -1   .   .   .   .   .   .   .   .   .   .
X.6      8  8  8  . -1 -1  .  .   1   1   1   1   1   1   1   1   1   1
X.7      4  4 -4  .  1 -1  .  .  -B  -B  -B  -B   B -/B -/B -/B -/B  /B
X.8      4  4 -4  .  1 -1  .  . -/B -/B -/B -/B  /B  -B  -B  -B  -B   B
X.9      6  6 -6  .  .  .  A -A  -1  -1  -1  -1   1  -1  -1  -1  -1   1
X.10     6  6 -6  .  .  . -A  A  -1  -1  -1  -1   1  -1  -1  -1  -1   1
X.11     8  8 -8  . -1  1  .  .   1   1   1   1  -1   1   1   1   1  -1
X.12    48 -1  .  .  .  .  .  .   6  -1  -1  -1   .   6  -1  -1  -1   .
X.13    48 -1  .  .  .  .  .  .   C  -1  /C  /D   .  /C   C   D  -1   .
X.14    48 -1  .  .  .  .  .  .   C  /C  /D  -1   .  /C   D  -1   C   .
X.15    48 -1  .  .  .  .  .  .  /C   D  -1   C   .   C  -1  /C  /D   .
X.16    48 -1  .  .  .  .  .  .   C  /D  -1  /C   .  /C  -1   C   D   .
X.17    48 -1  .  .  .  .  .  .  /C   C   D  -1   .   C  /D  -1  /C   .
X.18    48 -1  .  .  .  .  .  .  /C  -1   C   D   .   C  /C  /D  -1   .

A = E(8)-E(8)^3
  = Sqrt(2) = r2
B = E(7)+E(7)^2+E(7)^4
  = (-1+Sqrt(-7))/2 = b7
C = 2*E(7)+2*E(7)^2+2*E(7)^4
  = -1+Sqrt(-7) = 2b7
D = -3*E(7)-3*E(7)^2-2*E(7)^3-3*E(7)^4-2*E(7)^5-2*E(7)^6
  = (5-Sqrt(-7))/2 = 2-b7
gap> mat:= MatTom( tom );;
gap> mataut:= MatrixAutomorphisms( mat );;
gap> Print( mataut, "\n" );
Group( [ (11,12)(23,24)(27,28)(46,47)(53,54)(56,57), 
  ( 9,10)(20,21)(31,32)(38,39), ( 8, 9)(20,22)(31,33)(38,40) ] )
gap> RepresentativesFusions( Group( () ), reps, mataut );
[ [ 1, 6, 2, 4, 3, 5, 13, 13, 7, 8, 9, 10, 16, 7, 9, 10, 8, 16 ] ]
\endexample

We could say that thus the fusion is unique up to table automorphisms
and automorphisms of the table of marks.
But since a group is associated with the table of marks,
we compute the character table from the group,
and decide which class fusion is correct.

\beginexample
gap> g:= UnderlyingGroup( tom );;
gap> tg:= CharacterTable( g );;
gap> tgfustom:= FusionCharTableTom( tg, tom );;
gap> trans:= TransformingPermutationsCharacterTables( tg, tbl );;
gap> tblfustom:= Permuted( tgfustom, trans.columns );;
gap> orbits:= List( reps, map -> OrbitFusions( AutomorphismsOfTable( tbl ),
>                                              map, Group( () ) ) );;
gap> PositionProperty( orbits, orb -> tblfustom in orb );
2
gap> PositionProperty( orbits, orb -> FusionToTom( tbl ).map in orb );
2
\endexample

So we see that the second one of the possibilities above is the right one.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$3 \times U_4(2) \rightarrow 3_1.U_4(3)$ (March 2010)}

According to the {\ATLAS} (see~\cite[p.~52]{CCN85}),
the simple group $U_4(3)$ contains two classes of maximal subgroups
of the type $U_4(2)$.
The class fusion of $U_4(2)$ into $U_4(3)$ is unique up to table
automorphisms.

\beginexample
gap> u42:= CharacterTable( "U4(2)" );;
gap> u43:= CharacterTable( "U4(3)" );;
gap> u42fusu43:= PossibleClassFusions( u42, u43 );;
gap> Length( u42fusu43 );
4
gap> Length( RepresentativesFusions( u42, u42fusu43, u43 ) );
1
\endexample

More precisely, take the outer automorphism group of $U_4(3)$,
which is a dihedral group of order eight,
and consider the subgroup generated by its central involution
(this automorphism is denoted by $2_1$ in the {\ATLAS})
and another involution called $2_3$ in the {\ATLAS}.
This subgroup is a Klein four group that induces a permutation group
on the classes of $U_4(3)$ and thus acts on the four possible class
fusions of $U_4(2)$ into $U_4(3)$.
In fact, this action is transitive.

The automorphism $2_1$ swaps each pair of mutually inverse classes
of order nine,
that is, `9A' is swapped with `9B' and `9C' is swapped with `9D'.
All $U_4(2)$ type subgroups of $U_4(3)$ are invariant under this
automorphism, they extend to subgroups of the type $U_4(2).2$ in
$U_4(3).2_1$.

\beginexample
gap> u43_21:= CharacterTable( "U4(3).2_1" );;
gap> fus1:= GetFusionMap( u43, u43_21 );
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 16, 17, 17, 18 ]
gap> act1:= Filtered( InverseMap( fus1 ), IsList );
[ [ 16, 17 ], [ 18, 19 ] ]
gap> CompositionMaps( ClassNames( u43, "Atlas" ), act1 );
[ [ "9A", "9B" ], [ "9C", "9D" ] ]
\endexample

The automorphism $2_3$ swaps `6B' with `6C', `9A' with `9C',
and `9B' with `9D'.
The two classes of $U_4(2)$ type subgroups of $U_4(3)$ are swapped
by this automorphism.

\beginexample
gap> u43_23:= CharacterTable( "U4(3).2_3" );;
gap> fus3:= GetFusionMap( u43, u43_23 );
[ 1, 2, 3, 4, 4, 5, 6, 7, 8, 9, 10, 10, 11, 11, 12, 13, 14, 13, 14, 15 ]
gap> act3:= Filtered( InverseMap( fus3 ), IsList );
[ [ 4, 5 ], [ 11, 12 ], [ 13, 14 ], [ 16, 18 ], [ 17, 19 ] ]
gap> CompositionMaps( ClassNames( u43, "Atlas" ), act3 );
[ [ "3B", "3C" ], [ "6B", "6C" ], [ "7A", "7B" ], [ "9A", "9C" ], 
  [ "9B", "9D" ] ]
\endexample

The {\ATLAS} states that the permutation character induced by the
first class of $U_4(2)$ type subgroups is `1a+35a+90a',
which means that the subgroups in this class contain `9A' and `9B' elements.
Then the permutation character induced by the second class
of $U_4(2)$ type subgroups is `1a+35b+90a',
and the subgroups in this class contain `9C' and `9D' elements.

So we choose appropriate fusions for the two classes of maximal
$U_4(2)$ type subgroups.

\beginexample
gap> firstfus:= First( u42fusu43, x -> IsSubset( x, [ 16, 17 ] ) );
[ 1, 2, 2, 3, 3, 5, 4, 7, 8, 9, 10, 10, 12, 12, 11, 12, 16, 17, 20, 20 ]
gap> secondfus:= First( u42fusu43, x -> IsSubset( x, [ 18, 19 ] ) );
[ 1, 2, 2, 3, 3, 4, 5, 7, 8, 9, 10, 10, 11, 11, 12, 11, 18, 19, 20, 20 ]
\endexample

Let us now consider the central extension $3_1.U_4(3)$.
Since the Schur multiplier of $U_4(2)$ has order two,
the $U_4(2)$ type subgroups of $U_4(3)$ lift to groups of the structure
$3 \times U_4(2)$ in $3_1.U_4(3)$.
There are eight possible class fusions from $3 \times U_4(2)$ to $3_1.U_4(3)$,
in two orbits of length four under the action of table automorphisms.

\beginexample
gap> 3u42:= CharacterTable( "Cyclic", 3 ) * u42;
CharacterTable( "C3xU4(2)" )
gap> 3u43:= CharacterTable( "3_1.U4(3)" );
CharacterTable( "3_1.U4(3)" )
gap> 3u42fus3u43:= PossibleClassFusions( 3u42, 3u43 );;
gap> Length( 3u42fus3u43 );
8
gap> Length( RepresentativesFusions( 3u42, 3u42fus3u43, 3u43 ) );
2
\endexample

More precisely, each of the four fusions from $U_4(2)$ to $U_4(3)$ has
exactly two lifts.
The four lifts of those fusions from $U_4(2)$ to $U_4(3)$ with
`9A' and `9B' in their image form one orbit under the action of
table automorphisms.
The other orbit consists of the lifts of those fusions with
`9C' and `9D' in their image.

\beginexample
gap> inducedmaps:= List( 3u42fus3u43, map -> CompositionMaps(
>        GetFusionMap( 3u43, u43 ), CompositionMaps( map,
>        InverseMap( GetFusionMap( 3u42, u42 ) ) ) ) );;
gap> List( inducedmaps, map -> Position( u42fusu43, map ) );
[ 1, 1, 2, 2, 4, 4, 3, 3 ]
\endexample

This solves the ambiguity:
Fusions from each of the two orbits occur,
and we can assign them to the two classes of subgroups
by the choice of the fusions from $U_4(2)$ to $U_4(3)$.

The reason for the asymmetry is that the automorphism $2_3$ of $U_4(3)$
does not lift to $3_1.U_4(3)$.
Note that each of the classes `9A', `9B' of $U_4(3)$ has three preimages
in $3_1.U_4(3)$,
whereas each of the classes `9C', `9D' has only one preimage.

In fact the two classes of $3 \times U_4(2)$ type subgroups of $3_1.U_4(3)$
behave differently.
For example,
inducing the irreducible characters of a $3 \times U_4(2)$ type subgroup
in the first class of maximal subgroups of $3_1.U_4(3)$
yields no irreducible character, whereas the two irreducible characters
of degree $630$ are obtained by inducing the irreducible characters
of a subgroup in the second class.

\beginexample
gap> rep:= RepresentativesFusions( 3u42, 3u42fus3u43, 3u43 );
[ [ 1, 4, 4, 7, 7, 10, 13, 15, 18, 21, 24, 24, 27, 27, 30, 27, 48, 49, 50, 
      50, 2, 5, 5, 8, 8, 11, 13, 16, 19, 22, 25, 25, 28, 28, 31, 28, 48, 49, 
      51, 51, 3, 6, 6, 9, 9, 12, 13, 17, 20, 23, 26, 26, 29, 29, 32, 29, 48, 
      49, 52, 52 ], 
  [ 1, 4, 4, 8, 9, 13, 10, 15, 18, 21, 25, 26, 31, 32, 27, 30, 46, 44, 51, 
      52, 2, 5, 5, 9, 7, 13, 11, 16, 19, 22, 26, 24, 32, 30, 28, 31, 47, 42, 
      52, 50, 3, 6, 6, 7, 8, 13, 12, 17, 20, 23, 24, 25, 30, 31, 29, 32, 45, 
      43, 50, 51 ] ]
gap> irr:= Irr( 3u42 );;
gap> ind:= InducedClassFunctionsByFusionMap( 3u42, 3u43, irr, rep[1] );;
gap> Intersection( ind, Irr( 3u43 ) );
[ Character( CharacterTable( "3_1.U4(3)" ), [ 630, 630*E(3)^2, 630*E(3), 6, 
      6*E(3)^2, 6*E(3), 9, 9*E(3)^2, 9*E(3), -9, -9*E(3)^2, -9*E(3), 0, 0, 2, 
      2*E(3)^2, 2*E(3), -2, -2*E(3)^2, -2*E(3), 0, 0, 0, -3, -3*E(3)^2, 
      -3*E(3), 3, 3*E(3)^2, 3*E(3), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 0, 0, -1, -E(3)^2, -E(3) ] ), 
  Character( CharacterTable( "3_1.U4(3)" ), [ 630, 630*E(3), 630*E(3)^2, 6, 
      6*E(3), 6*E(3)^2, 9, 9*E(3), 9*E(3)^2, -9, -9*E(3), -9*E(3)^2, 0, 0, 2, 
      2*E(3), 2*E(3)^2, -2, -2*E(3), -2*E(3)^2, 0, 0, 0, -3, -3*E(3), 
      -3*E(3)^2, 3, 3*E(3), 3*E(3)^2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 0, 0, 0, -1, -E(3), -E(3)^2 ] ) ]
gap> ind:= InducedClassFunctionsByFusionMap( 3u42, 3u43, irr, rep[2] );;
gap> Intersection( ind, Irr( 3u43 ) );
[  ]
\endexample

For $6_1.U_4(3)$ and $12_1.U_4(3)$, one gets the same phenomenon:
We have two orbits of class fusions,
one corresponding to each of the two classes of subgroups
of the type $3 \times 4 Y 2.U_4(2)$.
We get $10$ irreducible induced characters from
a subgroup in the second class (four faithful ones,
four with kernel of order two, and the two abovementioned
degree $630$ characters with kernel of order four)
and no irreducible character from a subgroup in the first class.

%T Computing the possible class fusions from $3 \times 4 Y 2.U_4(2)$
%T to $12_1.U_4(3)$ takes a long time ...

% \beginexample
% \endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\tthdump{\addcontentsline{toc}{section}{References}}

\bibliographystyle{amsalpha}
\bibliography{manualbib.xml,../../../doc/manualbib.xml,../../atlasrep/doc/manualbib.xml,../../Browse/doc/browsebib.xml}

% gap> STOP_TEST( "ambigfus.tst", 6129230950 );

\end{document}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%E

