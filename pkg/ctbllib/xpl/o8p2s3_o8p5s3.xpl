%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%W  o8p2s3_o8p5s3.xpl         GAP applications              Thomas Breuer
%%
%H  @(#)$Id: o8p2s3_o8p5s3.xpl,v 1.1 2008/11/14 17:17:23 gap Exp $
%%
%Y  Copyright 2006,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,   Germany
%%
%X  NAME="o8p2s3_o8p5s3"
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
\newtheorem{lem}{Lemma}[section]
\newtheorem{corollary}[lem]{Corollary}
\newtheorem{remark}[lem]{Remark}
\def\proof{\rm \trivlist
    \item[\hskip \labelsep{\sc Proof.}]}
\def\endproof{{\large$\Box$}\endtrivlist}

\textwidth16cm
\oddsidemargin0pt

\parskip 1ex plus 0.5ex minus 0.5ex
\parindent0pt

\hfuzz 3pt

\usepackage{amssymb}

% Miscellaneous macros.
\def\GAP{\textsf{GAP}}
\def\ATLAS{\textsf{ATLAS}}
\def\Irr{{\rm Irr}}
\def\Aut{{\rm Aut}}
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

\def\Fix{{\rm Fix}}
\def\total{{\sigma}}
\def\prop{{P}}
\def\calC{{\cal C}}
\def\sprbound{{\cal P}}
\def\sprtotal{{\cal S}}
\def\M{{\cal M}}
%%tth: \def\MM{{\M/\sim}}
\tthdump{\def\MM{{\tilde{\M}}}}

%%%%%
\def\fpr{{\mu }}
\def\PSL{{\rm PSL}}
\def\SL{{\rm SL}}
\def\SO{{\rm SO}}
\def\SU{{\rm SU}}
\def\GU{{\rm GU}}
\def\PGO{{\rm PGO}}
\def\PSO{{\rm PSO}}
\def\PSU{{\rm PSU}}
\def\PGU{{\rm PGU}}
\def\PSp{{\rm PSp}}
\def\Sp{{\rm Sp}}
\def\GF{{\rm GF}}
\def\GL{{\rm GL}}
\def\Aut{{\rm Aut}}
\def\Out{{\rm Out}}
\def\AGL{{\rm AGL}}
\def\PGammaL{{\rm P\hbox{$\Gamma$}L}}
\def\GammaL{{\rm \hbox{$\Gamma$}L}}
\def\GO{{\rm GO}}
\def\POmega{{\rm P\hbox{$\Omega$}}}
%%%%%

\begin{document}

\tthdump{\title{{\GAP} Computations with $O_8^+(5).S_3$ and $O_8^+(2).S_3$}}
%%tth: \title{GAP Computations with O+(8,5).S3 and O+(8,2).S3}
%%tth: \begin{html} <body bgcolor="FFFFFF"> \end{html}

\author{\textsc{Thomas Breuer} \\[0.5cm]
\textit{Lehrstuhl D f\"ur Mathematik} \\
\textit{RWTH, 52056 Aachen, Germany}}

\date{October 08th, 2006}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\maketitle


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\abstract{
This note shows how to construct a representation of the automorphic
extension $G$ of the simple group $S = O_8^+(5)$
by a symmetric group on three points,
together with an embedding of the normalizer $H$ of an $O_8^+(2)$ type
subgroup of $O_8^+(5)$.

As an application, it is shown that the permutation representation of $G$
on the cosets of $H$ has a base of length two.
This question arose in~\cite{BGS07}.}

% using `\abstract' seems to reset `\parskip' and `parindent' ...
\textwidth16cm
\oddsidemargin0pt

\parskip 1ex plus 0.5ex minus 0.5ex
\parindent0pt


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\tableofcontents

% gap> START_TEST("$Id: o8p2s3_o8p5s3.xpl,v 1.1 2008/11/14 17:17:23 gap Exp $");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Overview}

Let $S$ denote the simple group $O_8^+(5) \cong \POmega^+(8,5)$,
that is, the nonabelian simple group that occurs as a composition factor
of the general orthogonal group $\GO^+(8,5)$ of $8 \times 8$ matrices
over the field with five elements.

The outer automorphism group of $S$ is isomorphic to the symmetric group
on four points.
Let $G$ be an automorphic extension of $S$ by the symmetric group
on three points.
By~\cite{Kle87},
the group $S$ contains a maximal subgroup $M$ of the type $O_8^+(2)$
such that the normalizer $H$, say, of $M$ in $G$ is an automorphic extension
of $M$ by a symmetric group on three points.
(In fact, $H$ is isomorphic to the full automorphism group of $O_8^+(2)$.)

Let $S.2$ and $S.3$ denote intermediate subgroups between $S$ and $G$,
in which $S$ has the indices $2$ and $3$, respectively.
Analogously, let $M.2 = H \cap S.2$ and $M.3 = H \cap S.3$.

In Section~\ref{sect2},
we use the following approach to construct representations of $M.2$ and
$S.2$.
By~\cite[p.~85]{CCN85},
the Weyl group $W$ of type $E_8$ is a double cover of $M.2$,
and the reduction of its rational $8$-dimensional representation modulo $5$
embeds into the general orthogonal group $\GO^+(8,5)$,
which has the structure $2.O_8^+(5).2^2$.
Then the actions of $\GO^+(8,5)$ and
an isomorphic image of $W$ in $\GO^+(8,5)$ on $1$-spaces in the
natural module of $\GO^+(8,5)$ yield $M.2$ as a subgroup of
(a supergroup of) $S.2$,
where both groups are represented as permutation groups on $N = 19\,656$
points.

In Section~\ref{sect3},
first we use {\GAP} to compute the automorphism group of $M$.
Then we take an outer automorphism $\alpha$ of $M$, of order three,
and extend $\alpha$ to an automorphism of $S$.
Concretely, we compute the images of generating sets of $S$ and $M$
under $\alpha$ and $\alpha^2$.
This yields permutation representations of $S.3$ and its subgroup $M.3$
on $3 N = 58\,968$ points.

In Section~\ref{sect4},
we put the above information together,
in order to construct permutation representations of $G$ and $M$,
on $3 N$ points.

As an application, it is shown in Section~\ref{appl}
that the permutation representation of $G$ on the cosets of $H$
has a base of length two;
this question arose in~\cite{BGS07}.

In two appendices, it is discussed how to derive a part of this result
from the permutation character $(1_H^G)_H$ (see Section~\ref{permchar}),
and a file containing the data used in the earlier sections is described
(see Section~\ref{data}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Constructing Representations of $M.2$ and $S.2$}\label{sect2}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{A Matrix Representation of the Weyl Group of Type $E_8$}

Following the recipe listed in~\cite[p.~85, Section Weyl]{CCN85},
we can generate the Weyl group $W$ of type $E_8$ as a group of rational
$8 \times 8$ matrices generated by the reflections in the vectors
\[
   \left(\pm 1/2, \pm 1/2, 0, 0, 0, 0, 0, 0\right)
\]
plus the vectors obtained from these by permuting the coordinates,
plus those those vectors of the form
\[
   \left( \pm 1/2, \pm 1/2, \pm 1/2, \pm 1/2,
          \pm 1/2, \pm 1/2, \pm 1/2, \pm 1/2 \right)
\]
that have an even number of negative signs.
(Clearly it is sufficient to consider only one vector form a pair $\pm v$.)

\beginexample
gap> rootvectors:= [];;
gap> for i in Combinations( [ 1 .. 8 ], 2 ) do
>      v:= 0 * [ 1 .. 8 ];
>      v{i}:= [ 1, 1 ];
>      Add( rootvectors, v );
>      v:= 0 * [ 1 .. 8 ];
>      v{i}:= [ 1, -1 ];
>      Add( rootvectors, v );
>    od;
gap> Append( rootvectors,
>         1/2 * Filtered( Tuples( [ -1, 1 ], 8 ),
>                   x -> x[1] = 1 and Number( x, y -> y = 1 ) mod 2 = 0 ) );
gap> we8:= Group( List( rootvectors, ReflectionMat ) );
<matrix group with 120 generators>
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Embedding the Weyl group of Type $E_8$ into $\GO^+(8,5)$}

The elements in the group constructed above respect the symmetric bilinear
form that is given by the identity matrix.

\beginexample
gap> I:= IdentityMat( 8 );;
gap> ForAll( GeneratorsOfGroup( we8 ), x -> x * TransposedMat(x) = I );
true
\endexample

So the reduction of the matrices modulo $5$ yields a group $W^{\ast}$
of orthogonal matrices w.~r.~t.~the identity matrix.
The group $\GO^+(8,5)$ returned by the {\GAP} function `GO' leaves
a different bilinear form invariant.

\beginexample
gap> largegroup:= GO(1,8,5);;
gap> Display( InvariantBilinearForm( largegroup ).matrix );
 . 1 . . . . . .
 1 . . . . . . .
 . . 2 . . . . .
 . . . 2 . . . .
 . . . . 2 . . .
 . . . . . 2 . .
 . . . . . . 2 .
 . . . . . . . 2
\endexample

In order to conjugate $W^{\ast}$ into this group,
we need a $2 \times 2$ matrix $T$ over the field with five elements
with the property that $T T^{tr}$
is half of the upper left $2 \times 2$ matrix in the above matrix.

\beginexample
gap> T:= [ [ 1, 2 ], [ 4, 2 ] ] * One( GF(5) );;
gap> Display( 2 * T * TransposedMat( T ) );
 . 1
 1 .
gap> I:= IdentityMat( 8, GF(5) );;
gap> I{ [ 1, 2 ] }{ [ 1, 2 ] }:= T;;
gap> conj:= List( GeneratorsOfGroup( we8 ), x -> I * x * I^-1 );;
gap> IsSubset( largegroup, conj );
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Compatible Generators of $M$, $M.2$, $S$, and $S.2$}\label{120pt}

For the next computations,
we switch from the natural matrix representation of $\GO^+(8,5)$
to a permutation representation of $\PGO^+(8,5)$,
of degree $N = 19\,656$,
which is given by the action of $\GO^+(8,5)$ on the smallest orbit
of $1$-spaces in its natural module.

\beginexample
gap> orbs:= OrbitsDomain( largegroup, NormedRowVectors( GF(5)^8 ), OnLines );;
gap> List( orbs, Length );
[ 39000, 39000, 19656 ]
gap> N:= Length( orbs[3] );
19656
gap> orbN:= SortedList( orbs[3] );;
gap> largepermgroup:= Action( largegroup, orbN, OnLines );;
\endexample

In the same way,
permutation representations of the subgroup $M.2 \cong \SO^+(8,2)$
and of its derived subgroup $M$ are obtained.
But first we compute a smaller generating set of the simple group $M$,
using a permutation representation on $120$ points.

\beginexample
gap> orbwe8:= SortedList( Orbit( we8, rootvectors[1], OnLines ) );;
gap> Length( orbwe8 );
120
gap> we8_to_m2:= ActionHomomorphism( we8, orbwe8, OnLines );;
gap> m2_120:= Image( we8_to_m2 );;
gap> m_120:= DerivedSubgroup( m2_120 );;
gap> sml:= SmallGeneratingSet( m_120 );;  Length( sml );
2
gap> gens_m:= List( sml, x -> PreImagesRepresentative( we8_to_m2, x ) );;
\endexample

Now we compute the actions of $M$ and $M.2$
on the above orbit of length $N$.
For generating $M.2$, we choose an element $b_N \in M.2 \setminus M$,
which is obtained from the action of a matrix $b \in 2.M.2 \setminus 2.M$.

\beginexample
gap> gens_m_N:= List( gens_m,
>      x -> Permutation( I * x * I^-1, orbN, OnLines ) );;
gap> m_N:= Group( gens_m_N );;
gap> b:= I * we8.1 * I^-1;;
gap> DeterminantMat( b );
Z(5)^2
gap> b_N:= Permutation( b, orbN, OnLines );;
gap> m2_N:= ClosureGroup( m_N, b_N );;
\endexample

(Note that $M.2$ is not contained in $\PSO^+(8,5)$,
since the determinant of $b$ is $-1$ in the field with five elements.)

The group $S$ is the derived subgroup of $\PSO^+(8,5)$,
and $S.2$ is generated by $S$ together with $b_N$.

\beginexample
gap> s_N:= DerivedSubgroup( largepermgroup );;
gap> s2_N:= ClosureGroup( s_N, b_N );;
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Constructing Representations of $M.3$ and $S.3$}\label{sect3}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Action of $M.3$ on $M$}

Let $\alpha$ be an automorphism of $M$, of order three.
Then a representation of the semidirect product $M.3$ of $M$ by
$\langle \alpha \rangle$ can be constructed as follows.

If $M$ is given by a matrix representation then we map $g \in M$
to the block diagonal matrix
\[
   \left[ \begin{array}{ccc} g & & \\ & g^\alpha & \\ & & g^{(\alpha^2)}
          \end{array} \right] ,
\]
and we represent $\alpha$ by the block permutation matrix
\[
   \left[ \begin{array}{ccc}  & & I \\ I & & \\ & I &
          \end{array} \right] ,
\]
where $I$ is the identity element in $M$.

So what we need is the action of $\alpha$ on $M$.
More precisely, we need images of the chosen generators of $M$
under $\alpha$ and $\alpha^2$.

The group $M$ is small enough for asking {\GAP} to compute
its automorphism group, which is isomorphic with $O^+_8(2).S_3$;
for that, we use the permutation representation of degree $120$
that was constructed in Section~\ref{120pt}.

\beginexample
gap> aut_m:= AutomorphismGroup( m_120 );;
\endexample

We pick an outer automorphism $\alpha$ of order three.

\beginexample
gap> nice_aut_m:= NiceMonomorphism( aut_m );;
gap> der:= DerivedSubgroup( Image( nice_aut_m ) );;
gap> der2:= DerivedSubgroup( der );;
gap> repeat x:= Random( der );
>      ord:= Order( x );
>    until ord mod 3 = 0 and ord mod 9 <> 0 and not x in der2;
gap> x:= x^( ord / 3 );;
gap> alpha_120:= PreImagesRepresentative( nice_aut_m, x );;
\endexample

Next we compute the images of the generators `sml' under $\alpha$ and
$\alpha^2$,
and the corresponding elements in the action of $M$ on $N$ points.

\beginexample
gap> sml_alpha:= List( sml, x -> Image( alpha_120, x ) );;
gap> sml_alpha_2:= List( sml_alpha, x -> Image( alpha_120, x ) );;
gap> gens_m_alpha:= List( sml_alpha,
>                         x -> PreImagesRepresentative( we8_to_m2, x ) );;
gap> gens_m_alpha_2:= List( sml_alpha_2,
>                         x -> PreImagesRepresentative( we8_to_m2, x ) );;
gap> gens_m_N_alpha:= List( gens_m_alpha,
>      x -> Permutation( I * x * I^-1, orbN, OnLines ) );;
gap> gens_m_N_alpha_2:= List( gens_m_alpha_2,
>      x -> Permutation( I * x * I^-1, orbN, OnLines ) );;
\endexample

Finally, we use the construction descibed in the beginning of this section,
and obtain a permutation representation of $M.3$ on $3 N = 58\,968$
points.

\beginexample
gap> alpha_3N:= PermList( Concatenation( [ [ 1 .. N ] + 2*N,
>                                          [ 1 .. N ],
>                                          [ 1 .. N ] + N ] ) );;
gap> gens_m_3N:= List( [ 1 .. Length( gens_m_N ) ],
>      i -> gens_m_N[i] *
>           ( gens_m_N_alpha[i]^alpha_3N ) *
>           ( gens_m_N_alpha_2[i]^(alpha_3N^2) ) );;
gap> m_3N:= Group( gens_m_3N );;
gap> m3_3N:= ClosureGroup( m_3N, alpha_3N );;
\endexample

% gap> shift:= Product( List( [ 1 .. N ], i -> (i,i+N,i+2N) ) );;
% # exceeds the memory!


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Action of $S.3$ on $S$}\label{M.3andS.3}

Our approach is to extend the automorphism $\alpha$ of $M$ to $S$;
we can do this because in the full automorphism group of $S$,
\emph{any} $O^+_8(2)$ type subgroup extends
to a group of the type $O^+_8(2).3$, and this extension lies in a subgroup
of the type $O^+_8(5).3$ (see~\cite{Kle87}).

The group $M$ is maximal in $S$,
so $S$ is generated by $M$ together with any element $s \in S \setminus M$.
Having fixed such an element $s$, what we have to is to find the images
of $s$ under the automorphisms that extend $\alpha$ and $\alpha^2$.

For that, we first choose $x \in M$ such that $C_S(x)$ is a small group
that is not contained in $M$.
Then we choose $s \in C_S(x) \setminus M$,
and using that $s^\alpha$ must lie in $C_S(C_M(s)^\alpha)$,
we then check which elements of this small subgroup can be the desired
image.

Each element $x$ of order nine in $M$ has a root $s$ of order $63$ in $S$,
and $C_S(x)$ has order $189$.
For suitable such $x$,
exactly one element $y \in C_S(C_M(s)^\alpha)$ has order $63$ and satisfies
the necessary conditions
that the orders of the products of $s$ and the generators of $M$ are equal
to the orders of the product of $y$ and the images of these generators
under $\alpha$.
In other words, we have $s^\alpha = y$.

\beginexample
gap> alpha:= GroupHomomorphismByImagesNC( m_N, m_N,
>                gens_m_N, gens_m_N_alpha );;
gap> CheapTestForHomomorphism:= function( gens, genimages, x, cand )
>        return Order( x ) = Order( cand ) and
>               ForAll( [ 1 .. Length( gens ) ],
>            i -> Order( gens[i] * x ) = Order( genimages[i] * cand ) );
> end;;
gap> repeat
>      repeat
>        x:= Random( m_N );
>      until Order( x ) = 9;
>      c_s:= Centralizer( s_N, x );;
>      repeat
>        s:= Random( c_s );
>      until Order( s ) = 63;
>      c_m_alpha:= Images( alpha, Centralizer( m_N, s ) );;
>      good:= Filtered( Elements( Centralizer( s_N, c_m_alpha ) ),
>        x -> CheapTestForHomomorphism( gens_m_N, gens_m_N_alpha, s, x ) );;
>    until Length( good ) = 1;
gap> s_alpha:= good[1];;
gap> c_m_alpha_2:= Images( alpha, c_m_alpha );;
gap> good:= Filtered( Elements( Centralizer( s_N, c_m_alpha_2 ) ),
>      x -> CheapTestForHomomorphism( gens_m_N_alpha, gens_m_N_alpha_2,
>                                     s_alpha, x ) );;
gap> s_alpha_2:= good[1];;
\endexample

Using the notation of the previous section,
this means that the permutation representation of $M.3$ on $3 N$
points can be extended to $S.3$ by choosing the permutation corresponding
to the block diagonal matrix
\[
   \left[ \begin{array}{ccc} s & & \\ & s^\alpha & \\ & & s^{(\alpha^2)}
          \end{array} \right] ,
\]
as an additional generator.

\beginexample
gap> outer:= s * ( s_alpha^alpha_3N ) * ( s_alpha_2^(alpha_3N^2) );;
gap> s3_3N:= ClosureGroup( m3_3N, outer );;
\endexample

(And of course we have $S = \langle M, s \rangle$,
which yields generators for $S$ that are compatible with those of $M$.)

\beginexample
gap> s_3N:= ClosureGroup( m_3N, outer );;
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Constructing Compatible Generators of $H$ and $G$}\label{sect4}

After having constructed compatible representations of $M.2$ and $G.2$
on $N$ points (see Section~\ref{120pt})
and of $M.3$ and $S.3$ on $3 N$ points (see Section~\ref{M.3andS.3}),
the last construction step is to find a permutation on $3 N$ points
with the following properties:
\begin{itemize}
\item
    The induced automorphism $\beta$ of $M$ extends to $M.3$
    such that the automorphism $\alpha$ of $M$ is inverted,
    modulo inner automorphisms of $M$.
\item
    The action on the first $N$ points coicides with that of the element
    $b_N \in M.2 \setminus M$ that was constructed in Section~\ref{120pt}.
\end{itemize}

Using the notation of the previous sections,
we represent $\beta$ by a block diagonal matrix
\[
   \left[ \begin{array}{ccc} b & & \\ & & b d \\ & b g &
          \end{array} \right] ,
\]
where $b$ describes the action of $\beta$ on $M$ (on $N$ points),
$g$ describes the inner automorphism $\gamma$ of $M$ that is defined by
the condition $\beta \alpha = \alpha^2 \beta \gamma$,
and $d$ describes $\gamma \gamma^\alpha$.

So we compute an element in $M$ that induces the conjugation automorphism
$\gamma$, and its image under $\alpha$.
We do this in the representation of $M$ on $120$ points,
and carry over the result to the representation on $N$ points,
via the rational matrix representation;
this approach had been used already in Section~\ref{120pt}.

\beginexample
gap> b_120:= Permutation( we8.1, orbwe8, OnLines );;
gap> g_120:= RepresentativeAction( m_120, List( sml_alpha_2, x -> x^b_120 ),
>                List( sml, x -> (x^b_120)^alpha_120 ), OnTuples );;
gap> g_120_alpha:= g_120^alpha_120;;
gap> g_N:= Permutation( I * PreImagesRepresentative( we8_to_m2, g_120 )
>                         * I^-1, orbN, OnLines );;
gap> g_N_alpha:= Permutation( I * PreImagesRepresentative( we8_to_m2,
>                                     g_120_alpha ) * I^-1, orbN, OnLines );;
gap> inv:= PermList( Concatenation( ListPerm( b_N ),
>                                   ListPerm( b_N * g_N ) + 2*N,
>                                   ListPerm( b_N * g_N * g_N_alpha ) + N ) );;
\endexample

So we have constructed compatible generators for $H$ and $G$.

\beginexample
gap> h:= ClosureGroup( m3_3N, inv );;
gap> g:= ClosureGroup( s3_3N, inv );;
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Application: Regular Orbits of $H$ on $G/H$}\label{appl}

We want to show that $H$ has regular orbits on the right cosets $G/H$.
The stabilizer in $H$ of the coset $H g$ is $H \cap H^g$,
so we compute that there are elements $s \in S$ with the property
$|H \cap H^s| = 1$.

(Of course this implies that also in the permutation representations of
the subgroups $S$, $S.2$, and $S.3$ of $G$ on the cosets of the intersection
with $H$, the point stabilizers have regular orbits.)

\beginexample
gap> repeat
>      conj:= Random( s_3N );
>      inter:= Intersection( h, h^conj );
>    until Size( inter ) = 1;
\endexample

Eventually {\GAP} will return from this loop,
so there are elements $c$ with the required property.

(Computing one such intersection takes about six minutes
on a 2.5 GHz Pentium 4,
so one may have to be a bit patient.)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Appendix: The Permutation Character $(1_H^G)_H$}\label{permchar}

As an alternative to the computation of $|H \cap H^s|$ for suitable
$s \in S$, we can try to derive information from the permutation character
$(1_H^G)_H$.
Unfortunately, there seems to be no easy way to prove the existence of
regular $H$-orbits on $G/H$ (cf.~Section~\ref{appl})
only by means of this character.

However, it is not difficult to show that regular orbits
of $M$, $M.2$, and $M.3$ exist.
For that, we compute $(1_H^G)_H$,
by computing class representatives of $H$,
their centralizer orders in $G$,
and the class fusion of $H$-classes in $G$.

We want to compute the class representatives in a small permutation
representation of $H$;
this could be done using the degree $360$ representation that was
implicitly constructed above,
% (Each class representative can be written in the form $h \alpha^i$ with
% $h \in M.2$.)
but it is technically easier to use a degree $405$ representation
that is obtained from the degree $58\,968$ representation
by the action of $H$ on blocks in an orbit of length $22\,680$.
(One could get this also using the {\GAP} function
`SmallerDegreePermutationRepresentation'.)

\beginexample
gap> orbs:= Orbits( h, MovedPoints( h ) );;
gap> List( orbs, Length );
[ 22680, 36288 ]
gap> orb:= orbs[1];;
gap> bl:= Blocks( h, orb );;  Length( bl[1] );
2
gap> actbl:= Action( h, bl, OnSets );;
gap> bll:= Blocks( actbl, MovedPoints( actbl ) );;  Length( bll );  
405
gap> oneblock:= Union( bl{ bll[1] } );;
gap> orb:= SortedList( Orbit( h, oneblock, OnSets ) );;
gap> acthom:= ActionHomomorphism( h, orb, OnSets );;
gap> ccl:= ConjugacyClasses( Image( acthom ) );;
gap> reps:= List( ccl, x -> PreImagesRepresentative( acthom,
>                               Representative( x ) ) );;
\endexample

Then we carry back class representatives to the degree $58\,968$
representation, and compute the class fusion and the centralizer orders
in $G$.

\beginexample
gap> reps:= List( ccl, x -> PreImagesRepresentative( acthom,
>                               Representative( x ) ) );;
gap> fusion:= [];;
gap> centralizers:= [];;
gap> fusreps:= [];;
gap> for i in [ 1 .. Length( reps ) ] do
>      found:= false;
>      cen:= Size( Centralizer( g, reps[i] ) );
>      for j in [ 1 .. Length( fusreps ) ] do
>        if cen = centralizers[j] and
>           IsConjugate( g, fusreps[j], reps[i] ) then
>          fusion[i]:= j;
>          found:= true;
>          break;
>        fi;
>      od;
>      if not found then
>        Add( fusreps, reps[i] );
>        Add( fusion, Length( fusreps ) );
>        Add( centralizers, cen );
>      fi;
>    od;
\endexample

Next we compute the permutation character values,
using the formula
\[
   (1_H)^G(g) = (|C_G(g)| \sum_{h} |h^H|) /|H| ,
\]
where the summation runs over class representatives $h \in H$
that are $G$-conjugate to $g$.

\beginexample
gap> pi:= 0 * [ 1 .. Length( fusreps ) ];;
gap> for i in [ 1 .. Length( ccl ) ] do
>      pi[ fusion[i] ]:= pi[ fusion[i] ] + centralizers[ fusion[i] ] *
>                                              Size( ccl[i] );
>    od;
gap> pi:= pi{ fusion } / Size( h );;
\endexample

In order to write the permutation character w.r.t.~the ordering of classes
in the {\GAP} character table, we use the {\GAP} function
`CompatibleConjugacyClasses'.

\beginexample
gap> tblh:= CharacterTable( "O8+(2).S3" );;
gap> map:= CompatibleConjugacyClasses( Image( acthom ), ccl, tblh );;
gap> pi:= pi{ map }; 
[ 51162109375, 69375, 1259375, 69375, 568750, 1750, 4000, 375, 135, 975, 135, 
  625, 150, 650, 30, 72, 80, 72, 27, 27, 3, 7, 25, 30, 6, 12, 25, 484375, 
  1750, 375, 375, 30, 40, 15, 15, 15, 6, 6, 3, 3, 3, 157421875, 121875, 4875, 
  475, 75, 3875, 475, 13000, 1750, 300, 400, 30, 60, 15, 15, 15, 125, 10, 30, 
  4, 8, 6, 9, 7, 5, 6, 5 ]
\endexample

% This would not work for $O^+_8(2)$, $O^+_8(2).2$, $O^+_8(2).3$;
% in these cases, we would have to consider invariants:
% element orders, centralizer orders,
% centralizer orders of second and third power,
% containment in the derived subgroup.

Now we consider the restrictions of this permutation character to
$M$, $M.2$, and $M.3$.
Note that
$(1_H^G)_M = (1_M^S)_M$,
$(1_H^G)_{M.2} = (1_{M.2}^{S.2})_{M.2}$, and
$(1_H^G)_{M.3} = (1_{M.3}^{S.3})_{M.3}$.

\beginexample
gap> tblm2:= CharacterTable( "O8+(2).2" );;
gap> tblm3:= CharacterTable( "O8+(2).3" );;
gap> tblm:= CharacterTable( "O8+(2)" );;
gap> pi_m2:= pi{ GetFusionMap( tblm2, tblh ) };;
gap> pi_m3:= pi{ GetFusionMap( tblm3, tblh ) };;
gap> pi_m:= pi_m3{ GetFusionMap( tblm, tblm3 ) };;
\endexample

The permutation character $(1_M^S)_M$ decomposes
into $483$ transitive permutation characters,
and regular $M$-orbits on $S/M$ correspond to regular constituents
in this decomposition.
If there is no regular transitive constituent in $(1_M^S)_M$ then
the largest degree of a transitive constituent is $|M|/2$;
but then the degree of $1_M^S$ is less than $483 |M|/2$,
which is smaller than $[S:M]$.

\beginexample
gap> n:= ScalarProduct( tblm, pi_m, TrivialCharacter( tblm ) );
483
gap> n * Size( tblm ) / 2;
42065049600
gap> pi[1];
51162109375
\endexample

For the case of $M.2 < S.2$, this argument turns out to be not sufficient.
So we first compute a lower bound on the number of regular $M$-orbits
on $S/M$.
For involutions $g \in M$, the number of transitive constituents
$1_{\langle g \rangle}^M$ in $(1_M^S)_M$ is at most the integral part of
$1_M^S(g) / 1_{\langle g \rangle}^M(g) = 2 \cdot 1_M^S(g) / |C_M(g)|$;
from this we compute that there are at most $208$ such constituents.

\beginexample
gap> inv:= Filtered( [ 1 .. NrConjugacyClasses( tblm ) ],
>              i -> OrdersClassRepresentatives( tblm )[i] = 2 );
[ 2, 3, 4, 5, 6 ]
gap> n2:= List( inv, i -> Int( 2 * pi_m[i] / SizesCentralizers( tblm )[i] ) );
[ 1, 54, 54, 54, 45 ]
gap> Sum( n2 );
208
\endexample

As a consequence, $M$ has at least $148$ regular orbits on $S/M$.

\beginexample
gap> First( [ 1 .. 483 ],                                           
>           i -> i * Size( tblm ) + 208 * Size( tblm ) / 2
>                + ( 483 - i - 208 - 1 ) * Size( tblm ) / 3 + 1 >= pi[1] );
148
\endexample

Now we consider the action of $M.2$ on $S.2/M.2$.
If $M.2$ has no regular orbit then the $148$ regular orbits of $M$
must arise from the restriction of transitive constituents $1_U^{M.2}$
to $M$ with $|U| = 2$ and such that $U$ is not contained in $M$.
(This follows from the fact that the restriction of a transitive constituent
of $(1_{M.2}^{S.2})_{M.2}$ to $M$ is either itself a transitive constituent
of $(1_M^S)_M$ or the sum of two such constituents;
the latter case occurs if and only if the point stabilizer is contained
in $M$.)
However, the number of these constituents is at most  $134$.

\beginexample
gap> inv:= Filtered( [ 1 .. NrConjugacyClasses( tblm2 ) ],
>              i -> OrdersClassRepresentatives( tblm2 )[i] = 2 and
>                   not i in ClassPositionsOfDerivedSubgroup( tblm2 ) );
[ 41, 42 ]
gap> n2:= List( inv,
>               i -> Int( 2 * pi_m2[i] / SizesCentralizers( tblm2 )[i] ) );
[ 108, 26 ]
gap> Sum( n2 );
134
\endexample

% The number of $M.2-S.2-M.2$ double cosets is $331$.

Finally, we consider the action of $M.3$ on $S.3/M.3$.
We compute that $(1_{M.3}^{S.3})_{M.3}$ has $205$ transitive constituents,
and at most $69$ of them can be induced from subgroups of order two.
This is already sufficient to show that there must be regular constituents.

\beginexample
gap> n:= ScalarProduct( tblm3, pi_m3, TrivialCharacter( tblm3 ) );
205
gap> inv:= Filtered( [ 1 .. NrConjugacyClasses( tblm3 ) ],
>              i -> OrdersClassRepresentatives( tblm3 )[i] = 2 );
[ 2, 3, 4 ]
gap> n2:= List( inv,
>               i -> Int( 2 * pi_m3[i] / SizesCentralizers( tblm3 )[i] ) );
[ 0, 54, 15 ]
gap> Sum( n2 );
69
gap> 69 * Size( tblm3 ) / 2 + ( n - 69 - 1 ) * Size( tblm3 ) / 3 + 1;
41542502401
gap> pi[1];
51162109375
\endexample

% at least $28$ regular constituents


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Appendix: The Data File}\label{data}

The file \texttt{o8p2s3\_o8p5s3.g} that can be found at

\URL{http://www.math.rwth-aachen.de/\~{}Thomas.Breuer/ctbllib/data/o8p2s3\_o8p5s3.g}{http://www.math.rwth-aachen.de/~Thomas.Breuer/ctbllib/data/o8p2s3_o8p5s3.g}

contains the relevant data used in the above computations.
This covers the representations for the groups
and the permutation character of $O^+_8(2).S_3$
computed in Section~\ref{permchar}.

Reading the file into {\GAP} will define a global variable
\texttt{o8p2s3\_o8p5s3\_data}, a record with the following components.

\begin{description}
\item[\texttt{pi}]
    the list of values of the permutation character of $G = O^+_8(5).S_3$
    on the cosets of its subgroup $H = O^+_8(2).S_3$,
    restricted to $H$,
    corresponding to the ordering of classes in the character table of $H$
    in the {\GAP} Character Table Library
    (this table has the `Identifier' value `"O8+(2).3.2"'),
\item[\texttt{dim8Q}]
    a record with generators for $2.M$ and $2.M.2$,
    matrices of dimension eight over the Rationals,
\item[\texttt{deg120}]
    a record with generators for $M$ and $M.2$,
    permutations of degree $120$,
\item[\texttt{deg360}]
    a record with generators for $M$, $M.2$, $M.3$, and $H$,
    permutations of degree $360$,
\item[\texttt{dim8f5}]
    a record with generators for $2.M$, $2.M.2$, $2.S$, and $2.S.2$,
    matrices of dimension eight over the field with five elements,
\item[\texttt{deg19656}]
    a record with generators for $M$, $M.2$, $S$, and $S.2$,
    permutations of degree $19\,656$,
\item[\texttt{deg58968}]
    a record with generators for $M$, $M.2$, $M.3$, $H$,
    $S$, $S.2$, $S.3$, and $G$,
    permutations of degree $58\,968$,
\item[\texttt{seed405}]
    a block whose $H$-orbit in the representation on $58\,968$ points,
    w.r.t.~the action `OnSets',
    yields a representation of $H$ on $405$ points.
\end{description}

For each of the permutation representations, we have (where applicable)
\[
   \begin{array}{lcl}
    M   & \cong & \langle a_1, a_2 \rangle , \\
    M.2 & \cong & \langle a_1, a_2, b \rangle , \\
    M.3 & \cong & \langle a_1, a_2, t \rangle , \\
    H   & \cong & \langle a_1, a_2, t, b \rangle , \\
    S   & \cong & \langle a_1, a_2, c \rangle , \\
    S.2 & \cong & \langle a_1, a_2, c, b \rangle , \\
    S.3 & \cong & \langle a_1, a_2, c, t \rangle , \\
    G   & \cong & \langle a_1, a_2, c, t, b \rangle ,
   \end{array}
\]
where $a_1, a_2, b, t, c$ are the values of the record components
\texttt{a1}, \texttt{a2}, \texttt{b}, \texttt{t}, and \texttt{c}.

Analogously,
for the matrix representations, we have (where applicable)
\[
   \begin{array}{lcl}
    2.M   & \cong & \langle a_1, a_2 \rangle , \\
    2.M.2 & \cong & \langle a_1, a_2, b \rangle , \\
    2.S   & \cong & \langle a_1, a_2, c \rangle , \\
    2.S.2 & \cong & \langle a_1, a_2, c, b \rangle ,
   \end{array}
\]

Additional components are used for deriving the representations from
initial data, as in the constructions in the previous sections.

For example, most of the permutations needed arise as the induced actions
of matrices on orbits of vectors;
these orbits computed when the file is read,
and are then stored in the components \texttt{orb120} and \texttt{orb19656}.

The file \texttt{o8p2s3\_o8p5s3.g} does not contain the generators
explicitly,
but it is self-contained in the sense that only a few {\GAP} functions
are actually needed to produce the data;
for example, it should not be difficult to translate the contents of
the file into the language of other computer algebra systems.

Advantages of this way to store the data are that the relations between
the representations become explicit,
and also that only very few space is needed to describe the representations
-- the size of the file is less than 10 kB,
whereas storing (explicitly) one of the permutations on $58\,968$ points
requires already about 350 kB.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\tthdump{\addcontentsline{toc}{section}{References}}

\bibliographystyle{amsalpha}
\bibliography{../../../doc/mrabbrev,manual,../../../doc/manual,../../atlasrep/doc/manual}

% gap> STOP_TEST( "o8p2s3_o8p5s3.tst", 75612500 );

\end{document}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%E

