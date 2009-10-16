%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%W  ctblcons.xpl              GAP applications              Thomas Breuer
%%
%H  @(#)$Id: ctblcons.xpl,v 1.5 2007/06/05 08:02:20 gap Exp $
%%
%Y  Copyright 2004,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,   Germany
%%
%X  NAME="ctblcons"
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
\def\Aut{{\rm Aut}}
\def\PGL{{\rm PGL}}
%%tth: \font\Bbb=msbm10
\def\N{{\mathbb N}} \def\Z{{\mathbb Z}} \def\Q{{\mathbb Q}}
\def\R{{\mathbb R}} \def\C{{\mathbb C}} \def\F{{\mathbb F}}
\def\tthdump#1{#1}
\tthdump{\def\URL#1#2{\texttt{#1}}}
%%tth: \def\URL#1#2{\url{#2}}
%%tth: \def\abstract#1{#1}
%%tth: \def\colon{:}
%%tth: \def\thinspace{ }

\begin{document}

\tthdump{\title{Using Table Automorphisms for Constructing Character Tables in {\GAP}}}
%%tth: \title{Using Table Automorphisms for Constructing Character Tables in GAP}
%%tth: \begin{html} <body bgcolor="FFFFFF"> \end{html}

\author{\textsc{Thomas Breuer} \\[0.5cm]
\textit{Lehrstuhl D f{\"u}r Mathematik} \\
\textit{RWTH, 52056 Aachen, Germany}}

\date{June 27th, 2004}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\maketitle


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\abstract{This note has three aims.
First it shows how character table automorphisms can be utilized to
construct certain character tables from others
using the {\GAP} system~\cite{GAP4};
the {\GAP} functions used for that are part of the {\GAP} Character Table
Library~\cite{CTblLib}.
Second it documents several constructions of character tables which are
contained in the {\GAP} Character Table Library.
Third it serves as a testfile for the involved {\GAP} functions.}

% using `\abstract' seems to reset `\parskip' and `parindent' ...
\textwidth16cm
\oddsidemargin0pt

\parskip 1ex plus 0.5ex minus 0.5ex
\parindent0pt

%T TODO:
%T Mention Schur multipliers and full automorphism groups,
%T do we get all ATLAS cases (all exceptional cases) that are not bicyclic?

%T add an index of all tables that are constructed in this file!


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\tableofcontents

% gap> START_TEST("$Id: ctblcons.xpl,v 1.5 2007/06/05 08:02:20 gap Exp $");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Overview}

Several types of constructions of character tables of finite groups
from known tables of smaller groups are described in Section~\ref{constr}.
Selecting suitable character table automorphisms is an important
ingredient of these constructions.

Section~\ref{theory} collects the few representation theoretical facts
on which these constructions are based.

The remaining sections show examples of the constructions in {\GAP}.
These examples use the {\GAP} Character Table Library,
therefore we load this package first.

\beginexample
gap> LoadPackage( "ctbllib" );
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Theoretical Background}\label{theory}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Character Table Automorphisms}

Let $G$ be a finite group,
$\Irr(G)$ be the matrix of ordinary irreducible characters of $G$,
$Cl(G)$ be the set of conjugacy classes of elements in $G$,
$g^G$ the $G$-conjugacy class of $g \in G$,
and
\[
   pow_p \colon \begin{array}{ccc}
                     Cl(G) & \rightarrow & Cl(G) \\
                     g^G   & \mapsto     & (g^p)^G
                \end{array}
\]
the $p$-th power map, for each prime integer $p$.

A *table automorphism* of $G$ is a permutation
$\sigma \colon Cl(G) \rightarrow Cl(G)$ with the properties that
$\chi \circ \sigma \in \Irr(G)$ holds for all $\chi \in \Irr(G)$
and that $\sigma$ commutes with $pow_p$, for all prime integers $p$ that
divide the order of $G$.
Note that for prime integers $p$ that are coprime to the order of $G$,
$pow_p$ commutes with each $\sigma$ that permutes $\Irr(G)$,
since $pow_p$ acts as a field automorphism on the character values.

In {\GAP}, a character table covers the irreducible characters
--a matrix $M$ of character values-- as well as the power maps of the
underlying group --each power map $pow_p$ being represented as a list
$pow_p^{\prime}$ of positive integers denoting the positions of the image
classes.
The group of table automorphisms of a character table is represented
as a permutation group on the column positions of the table;
it can be computed with the function `AutomorphismsOfTable'.

In the following, we will mainly use that each *group automorphism* $\sigma$
of $G$ induces a table automorphism that maps the class of each element
in $G$ to the class of its image under $\sigma$.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Permutation Equivalence of Character Tables}

Two character tables with matrices $M_1$, $M_2$ of irreducibles and $p$-th
power maps $pow_{1,p}$, $pow_{2,p}$ are \emph{permutation equivalent}
if permutations $\psi$ and $\pi$ of row and column positions of the $M_i$
exist such that $[ M_1 ]_{i,j} = [ M_2 ]_{i \psi, j \pi}$ holds for all
indices $i$, $j$,
and such that $\pi \cdot pow_{2,p}^{\prime} = pow_{1,p}^{\prime} \cdot \pi$
holds for all primes $p$ that divide the (common) group order.
The first condition is equivalent to the existence of a permutation $\pi$
such that permuting the columns of $M_1$ with $\pi$ maps the set of rows of
$M_1$ to the set of rows of $M_2$.

$\pi$ is of course determined only up to table automorphisms of the two
character tables, that is, two transforming permutations $\pi_1$, $\pi_2$
satisfy that $\pi_1 \cdot \pi_2^{-1}$ is a table automorphism of the first
table, and $\pi_1^{-1} \cdot \pi_2$ is a table automorphism of the second.

Clearly two isomorphic groups have permutation equivalent character tables.

%T Interpret table automorphisms and transforming permutations in the
%T language of permutation group algorithms.
%T The table automorphisms are the stabilizer of the set of rows in the
%T symmetric group acting on the columns,
%T and the transforming permutations form a coset in this group,
%T or the empty set.
%T (Cite Butler's book?)

The {\GAP} library function `TransformingPermutationsCharacterTables' returns
a record that contains transforming permutations of rows and columns if the
two argument tables are permutation equivalent, and `fail' otherwise.

In the example sections, the following function for computing representatives
from a list of character tables w.r.t.~permutation equivalence will be used.
More precisely, the input is a list of records which have a component `table'
that is a character table, and the output is a sublist of the input.

\beginexample
gap> RepresentativesCharacterTables:= function( list )
>    local reps, i, t1, t2, found, r;
> 
>    reps:= [ list[1] ];
>    for i in [ 2 .. Length( list ) ] do
>      if IsRecord( list[i] ) then
>        t1:= list[i].table;
>      else
>        t1:= list[i];
>      fi;
>      found:= false;
>      for r in reps do
>        if IsRecord( r ) then
>          t2:= r.table;
>        else
>          t2:= r;
>        fi;
>        if TransformingPermutationsCharacterTables( t1, t2 ) <> fail then
>          found:= true;
>          break;
>        fi;
>      od;
>      if not found then
>        Add( reps, list[i] );
>      fi;
>    od;
>    return reps;
>    end;;
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Class Fusions}\label{class_fusions}

For two groups $H$, $G$ such that $H$ is isomorphic with a subgroup of $G$,
any embedding $\iota \colon H \rightarrow G$ induces a class function
\[
   fus_{\iota} \colon \begin{array}{ccc} 
                     Cl(H) & \rightarrow & Cl(G) \\
                     h^G   & \mapsto     & (\iota(h))^G
                \end{array}
\]
the *class fusion* of $H$ in $G$ via $\iota$.
Analogously, for a normal subgroup $N$ of $G$,
any epimorphism $\pi \colon G \rightarrow G/N$ induces a class function
\[
   fus_{\pi} \colon \begin{array}{ccc} 
                     Cl(G) & \rightarrow & Cl(G/N) \\
                     g^G   & \mapsto     & (\pi(g))^G
                \end{array}
\]
the *class fusion* of $G$ onto $G/N$ via $\pi$.

When one works only with character tables and not with groups,
these class fusions are the objects that describe subgroup and factor group
relations between character tables.
Technically, class fusions are necessary for restricting, inducing, and
inflating characters from one character table to another.
If one is faced with the problem to compute the class fusion between the
character tables of two groups $H$ and $G$ for which it is known that $H$
can be embedded into $G$
then one can use character-theoretic necessary conditions,
concerning that the restriction of all irreducible characters of $G$ to $H$
(via the class fusion) must decompose into the irreducible characters of $H$,
and that the class fusion must commute with the power maps of $H$ and $G$.

With this character-theoretic approach, one can clearly determine
possible class fusions only up to character table automorphisms.
Note that one can interpret each character table automorphisms of $G$
as a class fusion from the table of $G$ to itself.

If $N$ is a normal subgroup in $G$ then the class fusion of $N$ in $G$
determines the orbits of the conjugation action of $G$ on the classes of $N$.
Often the knowledge of these orbits suffices to identify the subgroup of
table automorphisms of $N$ that corresponds to this action of $G$;
for example, this is always the case if $N$ has index $2$ in $G$.

{\GAP} library functions for dealing with class fusions, power maps,
and character table automorphisms are described in the chapter
``Maps Concerning Character Tables'' in the {\GAP} Reference Manual.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Constructing Character Tables of Certain Isoclinic Groups}%
\label{isoclinism}

As is stated in~\cite[p.~xxiii]{CCN85},
two groups $G$, $H$ are called *isoclinic* if they can be embedded
into a group $K$ such that $K$ is generated by $Z(K)$ and $G$,
and also by $Z(K)$ and $H$.
In the following, two special cases of isoclinism will be used,
where the character tables of the isoclinic groups are closely related.

\begin{itemize}
\item[(1)]
    $G \cong 2 \times U$ for a group $U$ that has a central subgroup $N$
    of order $2$,
    and $H$ is the central product of $U$ and a cyclic group of order four.
    Here we can set $K = 2 \times H$.
\item[(2)]
    $G \cong 2 \times U$ for a group $U$ that has a normal subgroup $N$
    of index $2$,
    and $H$ is the subdirect product of $U$ and a cyclic
    group of order four,
    Here we can set $K = 4 \times U$.
\end{itemize}

\begin{center}
%%tth: \includegraphics{ctblcons01.png}
%BP ctblcons01
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(110,55)
\put(0,0){\begin{picture}(40,55)
\put(15, 5){\circle*{1}} % trivial group
\put( 5,15){\circle*{1}}
\put(10,15){\circle*{1}}
\put(15,15){\circle*{1}} \put(18,15){\makebox(0,0){$N$}}
\put( 5,25){\circle*{1}}
\put(10,25){\circle*{1}} \put( 8,25){\makebox(0,0){$\langle z \rangle$}}
\put(15,25){\circle*{1}}
\put( 5,35){\circle*{1}}
\put(30,30){\circle*{1}} \put(36,30){\makebox(0,0){$U = S$}}
%
\put(20,40){\circle*{1}} \put(17,40){\makebox(0,0){$G$}}
\put(25,40){\circle*{1}}
\put(30,40){\circle*{1}} \put(33,40){\makebox(0,0){$H$}}
\put(20,50){\circle*{1}} \put(20,53){\makebox(0,0){$K$}}
%
\put( 5,15){\line(0,1){20}}
\put(15, 5){\line(-1,2){10}}
\put(15, 5){\line(-1,1){10}}
\put(15, 5){\line(0,1){20}}
\put(15,15){\line(-1,2){10}}
\put(15,15){\line(-1,1){10}}
\put(15,25){\line(-1,1){10}}
%
\put(15,15){\line(1,1){15}}
\put( 5,25){\line(1,1){15}}
\put(10,25){\line(1,1){15}}
\put(15,25){\line(1,1){15}}
\put( 5,35){\line(1,1){15}}
%
\put(20,40){\line(0,1){10}}
\put(30,30){\line(-1,2){10}}
\put(30,30){\line(-1,1){10}}
\put(30,30){\line(0,1){10}}
\put(30,40){\line(-1,1){10}}
\end{picture}}
\put(50,0){\begin{picture}(60,55)
\put(25, 5){\circle*{1}} % trivial group
\put(17,13){\circle*{1}}
\put( 9,21){\circle*{1}} \put(6,21){\makebox(0,0){$\langle z \rangle$}}
%
\put(46,26){\circle*{1}} \put(49,26){\makebox(0,0){$N$}}
\put(54,34){\circle*{1}} \put(57,34){\makebox(0,0){$U$}}
\put(38,34){\circle*{1}} \put(35,34){\makebox(0,0){$S$}}
\put(30,42){\circle*{1}}
\put(38,42){\circle*{1}} \put(35,42){\makebox(0,0){$H$}}
\put(46,42){\circle*{1}} \put(49,42){\makebox(0,0){$G$}}
\put(38,50){\circle*{1}} \put(38,53){\makebox(0,0){$K$}}
\put(46,34){\circle*{1}}
%
\put(25, 5){\line(-1,1){16}}
\put(46,26){\line(-1,1){16}}
\put(54,34){\line(-1,1){16}}
%
\put(46,26){\line(0,1){16}}
\put(38,34){\line(0,1){16}}
%
\put(25, 5){\line(1,1){29}}
\put(17,13){\line(1,1){29}}
\put( 9,21){\line(1,1){29}}
\end{picture}}
\end{picture}}
%EP
\end{center}

Starting from the group $K$ containing both $G$ and $H$,
we first note that each irreducible representation of $G$ or $H$ extends
to $K$.
More specifically, if $\rho_G$ is an irreducible representation of $G$ then
we can define an extension $\rho$ of $K$ by defining it suitably on $Z(K)$
and then form $\rho_H$, the restriction of $\rho$ to $H$.

In our two cases, we set $S = G \cap H$,
so $K = S \cup G \setminus S \cup H \setminus S \cup z S$ holds for some
element $z \in Z(K) \setminus ( G \cup H )$ of order four,
and $G = S \cup g S$ for some $g \in G \setminus S$,
and $H = S \cup h S$ where $h = z \cdot g \in H \setminus S$.
For defining $\rho_H$, it suffices to consider $\rho(h) = \rho(z) \rho(g)$,
where $\rho(z) = \epsilon_{\rho}(z) \cdot I$ is a scalar matrix.

As for the character table heads of $G$ and $H$,
we have $s^G = s^H$ and $z (g \cdot s)^G = (h \cdot s)^H$ for each $s \in S$,
so this defines a bijection of the conjugacy classes of $G$ and $H$.
For a prime integer $p$,
$(h \cdot s)^p = (z \cdot g \cdot s)^p = z^p \cdot (g \cdot s)^p$ holds
for all $s \in S$,
so the $p$-th power maps of $G$ and $H$ are related as follows:
Inside $S$ they coincide for any $p$.
If $p \equiv 1 \bmod 4$ they coincide also outside $S$,
if $p \equiv -1 \bmod 4$ the images differ by exchanging the classes
of $(h \cdot s)^p$ and $z^2 \cdot (h \cdot s)^p$ (if these elements lie
in different classes),
and for $p = 2$ the images (which lie inside $S$) differ by exchanging
the classes of $(h \cdot s)^2$ and $z^2 \cdot (g \cdot s)^2$
(if these elements lie in different classes).

Let $\rho$ be an irreducible representation of $K$.
Then $\rho_G$ and $\rho_H$ are related as follows:
$\rho_G(s) = \rho_H(s)$
and $\rho(z) \cdot \rho_G(g \cdot s) = \rho_H(h \cdot s)$
for all $s \in S$.
If $\chi_G$ and $\chi_H$ are the characters afforded by $\rho_G$
and $\rho_H$, respectively,
then $\chi_G(s) = \chi_H(s)$ and
$\epsilon_{\rho}(z) \cdot \chi_G(g \cdot s) = \chi_H(h \cdot s)$ hold
for all $s \in S$.
In the case $\chi_G(z^2) = \chi(1)$ we have $\epsilon_{\rho}(z) = \pm 1$,
and both cases actually occur if one considers all irreducible
representations of $K$.
In the case $\chi_G(z^2) = - \chi(1)$ we have $\epsilon_{\rho}(z) = \pm i$,
and again both cases occur.
So we obtain the irreducible characters of $H$ from those of $G$ by
multiplying the values outside $S$ in all those characters by $i$ that
do not have $z^2$ in their kernels.

In {\GAP}, the function `CharacterTableIsoclinic' can be used for
computing the character table of $H$ from that of $G$, and vice versa.
(Note that in the above two cases, also the groups $U$ and $H$ are
isoclinic by definition,
but `CharacterTableIsoclinic' does not transfer the character table of $U$
to that of $H$.)

`CharacterTableIsoclinic' can also be used to switch between the character
tables of the two double covers of groups of the type $G.2$,
see~\cite[p.~xxiii]{CCN85}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Characters of Normal Subgroups}%
\label{theorClifford}

Let $G$ be a group and $N$ be a normal subgroup of $G$.
We will need the following well-known facts about the relation
between the irreducible characters of $G$ and $N$.

For an irreducible (Brauer) character $\chi$ of $N$ and $g \in G$,
we define $\chi^g$ by $\chi^g(n) = \chi(n^g)$ for all $n \in N$,
and set $I_G(\chi) = \{ g \in G; \chi^g = \chi \}$
(see~\cite[p.~86]{Feit82}).

If $I_G(\chi) = N$ then the induced character $\chi^G$ is an
irreducible (Brauer) character of $G$
(see~\cite[Lemma~III 2.11]{Feit82}).

If $G/N$ is cyclic and if $I_G(\chi) = G$ then $\chi = \psi_N$
for an irreducible (Brauer) character $\psi$ of $G$,
and each irreducible (Brauer) character $\theta$ with the property
$\chi = \theta_N$ is of the form $\theta = \chi \cdot \epsilon$,
where $\epsilon$ is an irreducible (Brauer) character of $G/N$
(see~\cite[Theorem~III 2.14]{Feit82}).

Clifford's theorem~\cite[Theorem~III 2.12]{Feit82} states that the
restriction of an irreducible (Brauer) character of $G$ to $N$
has the form $e \sum_{i=1}^t \varphi_i$ for a positive integer $e$
and irreducible (Brauer) characters $\varphi_i$ of $N$,
where $t$ is the index of $I_G(\varphi_1)$ in $G$.

Now assume that $G$ is a normal subgroup in a larger group $H$,
that $G/N$ is an abelian chief factor of $H$ and that $\psi$ is an
ordinary irreducible character of $G$ such that $I_H(\psi) = H$.
Then either $t = 1$ and $e^2$ is one of $1$, $|G/N|$,
or $t = |G/N|$ and $e = 1$
(see~\cite[Theorem~6.18]{Isa76}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{The Constructions}\label{constr}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Character Tables of Groups of the Structure $M.G.A$}%
\label{theorMGA}

Let $N$ denote a downward extension of the finite group $G$
by a finite group $M$,
let $H$ denote an automorphic (upward) extension of $N$ by
a finite cyclic group $A$ such that $M$ is normal in $H$,
and set $F = H / M$.
We consider the situation that each irreducible character of $N$
that does not contain $M$ in its kernel induces irreducibly to $H$.
Equivalently, the action of $A = \langle a \rangle$ on the characters of $N$,
via $\chi \mapsto \chi^a$, has orbits of length exactly $|A|$ on the set
$\{ \chi \in \Irr(N); M \not\subseteq \ker(\chi) \}$.

\begin{center}
%%tth: \includegraphics{ctblcons02.png}
%BP ctblcons02
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(55,40)
\put(0,0){\begin{picture}(20,40)
\put(10, 5){\circle*{1}} % trivial group
\put(10,10){\circle*{1}} \put(7,10){\makebox(0,0){$M$}}
\put(10,25){\circle*{1}} \put(7,25){\makebox(0,0){$N$}}
\put(10,30){\circle*{1}} \put(10,33){\makebox(0,0){$H$}}
\put(10, 5){\line(0,1){25}}
\end{picture}}
\put(30,7){\begin{picture}(25,25)
\put( 5, 5){\makebox(0,0){$N$}}
\put( 5,20){\makebox(0,0){$G$}}
\put(20, 5){\makebox(0,0){$H$}}
\put(20,20){\makebox(0,0){$F$}}
\put( 7, 5){\vector(1,0){11}}
\put( 5, 7){\vector(0,1){11}}
\put( 7,20){\vector(1,0){11}}
\put(20, 7){\vector(0,1){11}}
\end{picture}}
\end{picture}}
%EP
\end{center}

This occurs for example if $M$ is central in $N$ and $A$ acts
fixed-point freely on $M$,
we have $|M| \equiv 1 \bmod |A|$ in this case.
If $M$ has prime order then it is sufficient that $A$ does not
centralize $M$.

The ordinary (or $p$-modular) irreducible characters of $H$ are then given
by the ordinary (or $p$-modular) irreducible characters of $F$ and $N$,
the class fusions from the table of $N$ onto the table of $G$
and from the table of $G$ into that of $F$,
and the permutation $\pi$ that is induced by the action of $A$ on the
conjugacy classes of $N$.

In general, the action of $A$ on the classes of $M$ is not the right
thing to look at, one really must consider the action on the relevant
characters of $M.G$.
For example, take $H$ the quaternion group or the dihedral group of
order eight, $N$ a cyclic subgroup of index two, and $M$ the centre of $H$;
here $A$ acts trivially on $M$, but the relevant fact is that the action
of $A$ swaps those two irreducible characters of $N$ that take the value
$-1$ on the involution in $M$ --these are the faithful irreducible characters
of $N$.

If the orders of $M$ and $A$ are coprime then also the power maps of $H$
can be computed from the above data.
For each prime $p$ that divides the orders of both $M$ and $A$,
the $p$-th power map is in general not uniquely determined by these
input data.
In this case, we can compute the (finitely many) candidates for the
character table of $H$ that are described by these data.
One possible reason for ambiguities is the existence of several isoclinic
but nonisomorphic groups that can arise from the input tables
(cf. Section~\ref{isoclinism}, see Section~\ref{HN2} for an example).

With the {\GAP} function `PossibleActionsForTypeMGA', one can compute
the possible orbit structures induced by $G.A$ on the classes of $M.G$,
and `PossibleCharacterTablesForTypeMGA' computes the possible ordinary
character tables for a given orbit structure.
For constructing the $p$-modular Brauer table of a group $H$ of the structure
$M.G.A$, the {\GAP} function `BrauerTableOfTypeMGA' takes the ordinary
character table of $H$ and the $p$-modular tables of the subgroup $M.G$
and the factor group $G.A$ as its input.
The $p$-modular table of $G$ is not explicitly needed in the construction,
it is implicitly given by the class fusions from $M.G$ into $M.G.A$ and
from $M.G.A$ onto $G.A$;
these class fusions must of course be available.

The {\GAP} Character Table Library contains many tables of groups of the
structure $M.G.A$ as described above, which are encoded by references to
the tables of the groups $M.G$ and $G.A$, plus the fusion and action
information.
This reduces the space needed for storing these character tables.

For examples, see Section~\ref{explMGA}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Character Tables of Groups of the Structure $G.S_3$}

Let $G$ be a finite group, and $H$ be an upward extension of $G$
such that the factor group $H / G$ is a Frobenius group $F = K C$ with
abelian kernel $K$ and cyclic complement $C$ of prime order $c$.
(Typical cases for $F$ are the symmetric group $S_3$ on three points
and the alternating group $A_4$ on four points.)
Let $N$ and $U$ denote the preimages of $K$ and $C$ under the natural
epimorphim from $H$ onto $F$.

% what we need:
% $K$ is normal in $F$, $C$ is cyclic and acts semiregularly on $K$ and ...

\begin{center}
%%tth: \includegraphics{ctblcons03.png}
%BP ctblcons03
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(70,40)
\put(0,0){\begin{picture}(25,40)
\put(15, 5){\circle*{1}} % trivial group
\put(15,15){\circle*{1}} \put(12,15){\makebox(0,0){$G$}}
\put( 5,25){\circle*{1}} \put(2,25){\makebox(0,0){$N$}}
\put(20,20){\circle{1}} \put(23,20){\makebox(0,0){$U$}}
\put(10,30){\circle*{1}} \put(10,33){\makebox(0,0){$H$}}
\put(15, 5){\line(0,1){10}}
\put(15,15){\line(-1,1){10}}
\put(20,20){\line(-1,1){10}}
\put(15,15){\line(1,1){5}}
\put( 5,25){\line(1,1){5}}
\end{picture}}
\put(35,2){\begin{picture}(35,35)
\put( 5,15){\makebox(0,0){$G$}}
\put(15, 5){\makebox(0,0){$U$}}
\put(20,30){\makebox(0,0){$N$}}
\put(30,20){\makebox(0,0){$H$}}
\put( 7,17){\vector(1,1){11}}
\put( 7,13){\vector(1,-1){6}}
\put(17, 7){\vector(1,1){11}}
\put(22,28){\vector(1,-1){6}}
\end{picture}}
\end{picture}}
%EP
\end{center}

For certain isomorphism types of $F$,
the ordinary (or $p$-modular) character table of $H$ can be computed
from the ordinary (or $p$-modular) character tables of $G$, $U$, and $N$,
the class fusions from the table of $G$ into those of $U$ and $N$,
and the permutation $\pi$ induced by $H$ on the conjugacy classes of $N$.
This holds for example for $F = S_3$ and in the ordinary case also
for $F = A_4$.

Each class of $H$ is either a union of $\pi$-orbits or an $H$-class of
$U \setminus G$; the latter classes are in bijection with the
$U$-classes of $U \setminus G$, they are just $|K|$ times larger
since the $|K|$ conjugates of $U$ in $H$ are fused.
The power maps of $H$ are uniquely determined from the power maps of
$U$ and $N$, because each element in $F$ lies in $K$ or in an
$F$-conjugate of $C$.

Concerning the computation of the ordinary irreducible characters of $H$,
we could induce the irreducible characters of $U$ and $N$ to $H$,
and then take the union of the irreducible characters among those
and the irreducible differences of those.
(For the case $F = S_3$, this approach has been described in the
Appendix of~\cite{HL94}.)

The {\GAP} function `CharacterTableOfTypeGS3' proceeds in a different way,
which is suitable also for the construction of $p$-modular character tables
of $H$.

By the facts listed in Section~\ref{theorClifford},
for an irreducible (Brauer) character $\chi$ of $N$,
we have $I_H(\chi)$ equal to either $N$ or $H$.
In the former case, $\chi$ induces irreducibly to $H$.
In the latter case, there are extensions $\psi^{(i)}$,
$1 \leq i \leq |C|$ (or $|C|_{p^\prime}$), to $H$,
and we have the following possibilities,
depending on the restriction $\chi_G$.

If $\chi_G = e \varphi$, for an irreducible character $\varphi$ of $G$,
then $I_U(\varphi) = U$ holds,
hence the $\psi^{(i)}_U$ are $|C|$ (or $|C|_{p^\prime}$) extensions
of $\chi_G$ to $U$.
Moreover, we have either $e = 1$ or $e^2 = |K|$.
In the case $e = 1$, this determines the values of the $\psi^{(i)}$
on the classes of $U$ outside $G$.
In the case $e \not= 1$, we have the problem to combine $e$ extensions
of $\varphi$ to a character of $U$ that extends to $H$.

(One additional piece of information in the case of ordinary character tables
is that the norm of this linear combination equals $1 + (|K|-1)/|C|$,
% This follows from the decomposition
% $H = N \cup \bigcup_{n \in N/G} ( U^n \setminus G )$
% which implies
% \[
%    \sum_{h \in H} |\psi(h)|^2 = \sum_{h \in N} |\psi(h)|^2
%        + |N/G| ( \sum_{h \in U} |\psi(h)|^2 - \sum_{h \in G} |\psi(h)|^2 )
% \]
% and thus
% \[
%    |H| = |N| + |N/G| ( |U| (\psi_U, \psi_U) - |G| e^2 ) .
% \]
which determines the $\psi^{(i)}_U$ if $F = A_4 \cong 2^2:3$ or $F = 2^3:7$
holds;
in the former case, the sum of each two out of the three different extensions
of $\varphi$ extends to $U$;
in the latter case, the sum of all different extensions plus one of the
extensions extends.
Note that for $F = S_3$, the case $e \not= 1$ does not occur.)

The remaining case is that $\chi_G$ is not a multiple of an irreducible
character of $G$.
Then $\chi_G = \varphi_1 + \varphi_2 + \ldots + \varphi_{|K|}$,
for pairwise different irreducible characters $\varphi_i$, $1 \leq i \leq |K|$,
of $G$ with the property $\varphi_i^N = \chi$.
The action of $U$ on $G$ fixes at least one of the $\varphi_i$,
since $|K| \equiv 1 \bmod |C|$.
Without loss of generality, let $I_U(\varphi_1) = U$,
and let $\tilde{\varphi_1}^{(i)}$, $1 \leq i \leq |C|$,
be the extensions of $\varphi_1$ to $U$.
(In fact exactly $\varphi_1$ is fixed by $U$ since otherwise $k \in K$
would exist with $\varphi_1^k \not= \varphi_1$ and such that also
$\varphi_1^k$ would be invariant in $U$;
but then $\varphi_1$ would be invariant under both $C$ and $C^k$, which
generate $F$.
So each of the $|K|$ constituents is invariant in exactly one of the
$|K|$ subgroups of type $U$ above $G$.)

Then
$((\tilde{\varphi_1}^{(i)})^H)_N = \varphi_1^N = \chi$,
hence the values of $\psi^{(i)}$ on the classes of $U \setminus G$
are given by those of $(\tilde{\varphi_1}^{(i)})^H$.
(These are exactly the values of $\tilde{\varphi_1}^{(i)}$.
So in both cases, we take the values of $\chi$ on $N$,
and on the classes of $U \setminus G$ the values of the extensions
of the unique extendible constituent of $\chi_G$.)

For examples, see Section~\ref{GS3}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Character Tables of Groups of the Structure $G.2^2$}%
\label{theorGV4}

Let $G$ be a finite group, and $H$ be an upward extension of $G$
such that the factor group $H / G$ is a Klein four group.
We assume that the ordinary character tables of $G$ and of the three index
two subgroups $U_1$, $U_2$, and $U_3$ (of the structures $G.2_1$, $G.2_2$,
and $G.2_3$, respectively) of $H$ above $G$ are known,
as well as the class fusions of $G$ into these groups.
The idea behind the method that is described in this section is that
in this situation,
there are only few possibilities for the ordinary character table of $H$.

\begin{center}
%%tth: \includegraphics{ctblcons04.png}
%BP ctblcons04
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(70,30)
\put(0,0){\begin{picture}(40,30)(0,0)
\put(20,0){\circle*{1}} % trivial group
\put(20,10){\circle*{1}} \put(17,10){\makebox(0,0){$G$}}
\put(13,17){\circle*{1}} \put(10,17){\makebox(0,0){$U_1$}}
\put(20,17){\circle*{1}} \put(17,17){\makebox(0,0){$U_2$}}
\put(27,17){\circle*{1}} \put(30,17){\makebox(0,0){$U_3$}}
\put(20,24){\circle*{1}} \put(20,27){\makebox(0,0){$H$}}
\put(20,0){\line(0,1){24}}
\put(20,10){\line(-1,1){7}}
\put(20,10){\line(1,1){7}}
\put(27,17){\line(-1,1){7}}
\put(13,17){\line(1,1){7}}
\end{picture}}
\put(40,2){\begin{picture}(35,30)
\put( 5,15){\makebox(0,0){$G$}}
\put(16,25){\makebox(0,0){$U_1$}}
\put(16,15){\makebox(0,0){$U_2$}}
\put(16, 5){\makebox(0,0){$U_3$}}
\put(28,15){\makebox(0,0){$H$}}
\put( 7,17){\vector(1,1){6}}
\put( 7,15){\vector(1,0){6}}
\put( 7,13){\vector(1,-1){6}}
\put(19,23){\vector(1,-1){6}}
\put(19,15){\vector(1,0){6}}
\put(19, 7){\vector(1,1){6}}
\end{picture}}
\end{picture}}
%EP
\end{center}

Namely, the action of $H$ on the classes of $G.2_i$ is given by a table
automorphism $\pi_i$ of $G.2_i$, and $H$ realizes compatible choices of such
automorphisms $\pi_1$, $\pi_2$, $\pi_3$ in the sense that the orbits of all
three $\pi_i$ on the classes of $G$ inside the groups $G.2_i$ coincide.
Furthermore, if $G.2_i$ has $n_i$ conjugacy classes then an action $\pi_i$
that is a product of $f_i$ disjoint transpositions leads to a character table
candidate for $G.2^2$ that has $2 n_i - 3 f_i$ classes,
so also the $f_i$ must be compatible.

Taking the ``inner'' classes, i.e., the orbit sums of the classes inside $G$
under the $\pi_i$, plus the union of the $\pi_i$-orbits of
the classes of $G.2_i \setminus G$ gives a possibility for the classes
of $H$.
Furthermore, the power maps of the groups $G.2_i$ determine the power maps of
the candidate table constructed this way.

Concerning the computation of the irreducible characters of $H$,
we consider also the case of $p$-modular characters tables,
where we assume that the ordinary character table of $H$ is already known
and the only task is to compute the irreducible $p$-modular Brauer
characters.

Let $\chi$ be an irreducible ($p$-modular Brauer) character of $G$.
By the facts that are listed in Section~\ref{theorClifford},
there are three possibilities.
\begin{itemize}
\item[1.]
   $I_H(\chi) = G$; then $\chi^H$ is irreducible.
\item[2.]
   $I_H(\chi) = G.2_i$ for $i$ one of $1$, $2$, $3$;
   then $I_{G.2_i}(\chi) = G.2_i$ for this $i$,
   so $\chi$ extends to $G.2_i$;
   none of these extensions extends to $H$ (because otherwise $\chi$
   would be invariant in $H$),
   so they induce irreducible characters of $H$.
\item[3.]
   $I_H(\chi) = H$;
   then $\chi$ extends to each of the three groups $G.2_i$,
   and either all these extensions induce the same character of $H$
   (which vanishes on $H \setminus G$) or they are invariant in $H$
   and thus extend to $H$.
\end{itemize}

In the latter part of case~3. (except if $p  = 2$),
the problem is to combine the values of six irreducible characters
of the groups $G.2_i$ to four characters of $H$.
This yields essentially two choices, and we try to exclude one possibility
by forming scalar products with the $2$-nd symmetrizations of the known
irreducibles.
If several possibilities remain then we get several possible tables.

So we end up with a list of possible character tables of $H$.
% In certain situations it is clear from the beginning that there will be
% several solutions, for example if $G$ has a central involution and thus
% several (in general not isomorphic) isoclinic variants of $H$ exist.
% 
% An as example, consider $G = C_2$, the cyclic group of order two,
% and $H$ a nonabelian group of order $8$.

The first step is to specify a list of possible triples
$(\pi_1, \pi_2, \pi_3)$, using the table automorphisms of the groups $G.2_i$;
this can be done using the {\GAP} function `PossibleActionsForTypeGV4'.
Then the {\GAP} function `PossibleCharacterTablesOfTypeGV4' can be used
for computing the character table candidates for each given triple of
permutations; it may of course happen that some triples of automorphisms
are excluded in this second step.

For examples, see Section~\ref{xplGV4}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Character Tables of Groups of the Structure $2^2.G$
(August 2005)}%
\label{theorV4G}

Let $G$ be a finite group, and $H$ be a central extension of $G$
by a Klein four group $Z = \langle z_1, z_2 \rangle$;
set $z_3 = z_1 z_2$ and $Z_i = \langle z_i \rangle$, for $1 \leq i \leq 3$.
We assume that the ordinary character tables of the three factor groups
$2_i.G = H / Z_i$ of $H$ are known,
as well as the class fusions from these groups to $G$.
The idea behind the method that is described in this section is that
in this situation,
there are only few possibilities for the ordinary character table of $H$.

\begin{center}
%%tth: \includegraphics{ctblcons05.png}
%BP ctblcons05 
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(70,30)
\put(0,0){\begin{picture}(40,30)(0,0)
\put(20,0){\circle*{1}} % trivial group
\put(20,14){\circle*{1}} \put(17,19){\makebox(0,0){$G$}}
\put(13, 7){\circle*{1}} \put(10, 7){\makebox(0,0){$Z_1$}}
\put(20, 7){\circle*{1}} \put(17, 7){\makebox(0,0){$Z_2$}}
\put(27, 7){\circle*{1}} \put(30, 7){\makebox(0,0){$Z_3$}}
\put(20,24){\circle*{1}} \put(20,27){\makebox(0,0){$H$}}
\put(20,0){\line(0,1){24}}
\put(20, 0){\line(-1,1){7}}
\put(20, 0){\line(1,1){7}}
\put(27, 7){\line(-1,1){7}}
\put(13, 7){\line(1,1){7}} 
\end{picture}}
\put(40,2){\begin{picture}(35,30)
\put( 5,15){\makebox(0,0){$H$}}
\put(18,25){\makebox(0,0){$H/Z_1$}}
\put(18,15){\makebox(0,0){$H/Z_2$}}
\put(18, 5){\makebox(0,0){$H/Z_3$}}
\put(32,15){\makebox(0,0){$G$}}
\put( 7,17){\vector(1,1){6}}
\put( 7,15){\vector(1,0){6}}
\put( 7,13){\vector(1,-1){6}}
\put(23,23){\vector(1,-1){6}}
\put(23,15){\vector(1,0){6}}
\put(23, 7){\vector(1,1){6}}
\end{picture}} 
\end{picture}}
%EP
\end{center}

Namely, the irreducible ($p$-modular) characters of $H$ are exactly the
inflations of the irreducible ($p$-modular) characters of the three
factor groups $H / Z_i$.
(Note that for any noncyclic central subgroup $C$ of $H$
and any $chi \in \Irr(H)$, we have $|\ker(\chi) \cap C| > 1$;
this generalizes~\cite[Thm.~2.32~(a)]{Isa76}.)
% For that, let $N = \ker(\chi)$, then $|N| > 1$.
% If $|N \cap C| = 1$ then $N C / N \cong C$ is a noncyclic central
% subgroup of $H/N$, but $\chi$ can be regarded as a faithful
% irreducible character of $H/N$;
% this contradicts~\cite[Thm.~2.32~(a)]{Isa76}.
So all we have to construct is the character table head of $H$
--classes and power maps-- and the factor fusions from $H$ to these groups.

For fixed $h \in H$, we consider the question in which $H$-classes the
elements $h$, $h z_1$, $h z_2$, and $h z_3$ lie.
There are three possibilities.

\begin{itemize}
\item[1.]
   The four elements are all conjugate in $H$.
   Then in each of the three groups $H/Z_i$,
   the two preimages of $h Z \in H/Z$ are conjugate.
\item[2.] 
   We are not in case 1. but two of the four elements are conjugate in $H$,
   i.~e., $g^{-1} h g = h z_i$ for some $g \in H$ and some $i$;
   then $g^{-1} h z_j g = h z_i z_j$ for each $j$,
   so the four elements lie in exactly two $H$-classes.
   This implies that for $i \not= j$, the elements $h$ and $h z_j$ are not
   $H$-conjugate,
   so $h Z_i$ is not conjugate to $h z_j Z_i$ in $H/Z_i$
   and $h Z_j$ is conjugate to $h z_i Z_j$ in $H/Z_j$.
\item[3.]
   The four elements are pairwise nonconjugate in $H$.
   Then in each of the three groups $H/Z_i$,
   the two preimages of $h Z \in H/Z$ are nonconjugate.
\end{itemize}

We observe that the question which case actually applies for $h \in H$
can be decided from the three factor fusions from $H/Z_i$ to $G$.
So we attempt to construct the table head of $H$ and the three factor fusions
from $H$ to the groups $H/Z_i$, as follows.
Each class $g^G$ of $G$ yields either one or two or four preimage classes
in $H$.

In case 1., we get one preimage class in $H$,
and have no choice for the factor fusions.

In case 2., we get two preimage classes,
there is exactly one group $H/Z_i$ in which $g^G$ has two preimage classes
--which are in bijection with the two preimage classes of $H$--
and for the other two groups $H/Z_j$, the factor fusions from $H$
map the two classes of $H$ to the unique preimage class of $g^G$.
(In the following picture, this is shown for $i = 1$.)

\begin{center}
%%tth: \includegraphics{ctblcons06.png}
%BP ctblcons06
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(110,30)
\put( 3, 5){\makebox(0,0){$H$}}
\put( 3,15){\makebox(0,0){$H/Z_1$}}
\put( 3,25){\makebox(0,0){$H/Z$}}
\put(10, 5){\circle*{1}} \put(12, 5){\makebox(0,0){$h$}}
\put(10,15){\circle*{1}} \put(14,15){\makebox(0,0){$h Z_1$}}
\put(20, 5){\circle*{1}} \put(24, 5){\makebox(0,0){$h z_2$}}
\put(20,15){\circle*{1}} \put(25,15){\makebox(0,0){$h z_2 Z_1$}}
\put(15,25){\circle*{1}} \put(18,25){\makebox(0,0){$h Z$}}
\put(10, 5){\line(0,1){10}}
\put(20, 5){\line(0,1){10}}
\put(10,15){\line(1,2){5}}
\put(20,15){\line(-1,2){5}}
\put(43, 5){\makebox(0,0){$H$}}
\put(43,15){\makebox(0,0){$H/Z_2$}}
\put(43,25){\makebox(0,0){$H/Z$}}
\put(50, 5){\circle*{1}} \put(52, 5){\makebox(0,0){$h$}}
\put(55,15){\circle*{1}} \put(59,15){\makebox(0,0){$h Z_2$}}
\put(60, 5){\circle*{1}} \put(64, 5){\makebox(0,0){$h z_2$}}
\put(55,25){\circle*{1}} \put(58,25){\makebox(0,0){$h Z$}}
\put(50,5){\line(1,2){5}}
\put(60,5){\line(-1,2){5}}
\put(55,15){\line(0,1){10}}
\put(83, 5){\makebox(0,0){$H$}}
\put(83,15){\makebox(0,0){$H/Z_3$}}
\put(83,25){\makebox(0,0){$H/Z$}}
\put(90, 5){\circle*{1}} \put(92, 5){\makebox(0,0){$h$}}
\put(95,15){\circle*{1}} \put(99,15){\makebox(0,0){$h Z_3$}}
\put(100, 5){\circle*{1}} \put(104, 5){\makebox(0,0){$h z_2$}}
\put(95,25){\circle*{1}} \put(98,25){\makebox(0,0){$h Z$}}
\put(90,5){\line(1,2){5}}
\put(100,5){\line(-1,2){5}}
\put(95,15){\line(0,1){10}}
\end{picture}}
%EP
\end{center}

In case 3., the three factor fusions are in general not uniquely determined:
We get four classes, which are defined as two pairs of preimages of the two
preimages of $g^G$ in $H/Z_1$ and in $H/Z_2$
-- so we choose the relevant images in the two factor fusions to $H/Z_1$
and $H/Z_2$, respectively.
Note that the class of $h$ in $H$ is the unique class
that maps to the class of $h Z_1$ in $H/Z_1$ and to the class of $h Z_2$ in
$H/Z_2$, and so on,
and we define four classes of $H$ via the four possible combinations of
image classes in $H/Z_1$ and $H/Z_2$ (see the picture below).

\begin{center}
%%tth: \includegraphics{ctblcons07.png}
%BP ctblcons07
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(110,30)
\put( 3, 5){\makebox(0,0){$H$}}
\put( 3,15){\makebox(0,0){$H/Z_1$}}
\put( 3,25){\makebox(0,0){$H/Z$}}
\put(10, 5){\circle*{1}} \put(12, 5){\makebox(0,0){$h$}}
\put(20, 5){\circle*{1}} \put(23, 5){\makebox(0,0){$h z_1$}}
\put(30, 5){\circle*{1}} \put(33, 5){\makebox(0,0){$h z_2$}}
\put(40, 5){\circle*{1}} \put(43, 5){\makebox(0,0){$h z_3$}}
\put(15,15){\circle*{1}} \put(19,15){\makebox(0,0){$h Z_1$}}
\put(35,15){\circle*{1}} \put(40,15){\makebox(0,0){$h z_2 Z_1$}}
\put(25,25){\circle*{1}} \put(29,25){\makebox(0,0){$h Z$}}
\put(10, 5){\line(1,2){5}}
\put(20, 5){\line(-1,2){5}}
\put(30, 5){\line(1,2){5}}
\put(40, 5){\line(-1,2){5}}
\put(15,15){\line(1,1){10}}
\put(35,15){\line(-1,1){10}}
\put(63, 5){\makebox(0,0){$H$}}
\put(63,15){\makebox(0,0){$H/Z_2$}}
\put(63,25){\makebox(0,0){$H/Z$}} 
\put(70, 5){\circle*{1}} \put(72, 5){\makebox(0,0){$h$}}
\put(80, 5){\circle*{1}} \put(84, 5){\makebox(0,0){$h z_1$}}
\put(90, 5){\circle*{1}} \put(93, 5){\makebox(0,0){$h z_2$}}
\put(100, 5){\circle*{1}} \put(103, 5){\makebox(0,0){$h z_3$}}
\put(75,15){\circle*{1}} \put(80,15){\makebox(0,0){$h Z_2$}}
\put(95,15){\circle*{1}} \put(100,15){\makebox(0,0){$h z_1 Z_2$}}
\put(85,25){\circle*{1}} \put(89,25){\makebox(0,0){$h Z$}}
\put(70, 5){\line(1,2){5}}
\put(80, 5){\line(3,2){15}}
\put(90, 5){\line(-3,2){15}}
\put(100, 5){\line(-1,2){5}}
\put(75,15){\line(1,1){10}}
\put(95,15){\line(-1,1){10}}
\end{picture}}
%EP
\end{center}

Due to the fact that in general we do not know which of the two
preimage classes of $g^G$ in $H/Z_3$ is the class of $h Z_3$,
there are in general the following *two* possibilities
for the fusion from $H$ to $H/Z_3$.

\begin{center}
%%tth: \includegraphics{ctblcons08.png}
%BP ctblcons08
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(110,30)
\put( 3, 5){\makebox(0,0){$H$}}
\put( 3,15){\makebox(0,0){$H/Z_3$}}
\put( 3,25){\makebox(0,0){$H/Z$}}
\put(10, 5){\circle*{1}} \put(12, 5){\makebox(0,0){$h$}}
\put(20, 5){\circle*{1}} \put(24, 5){\makebox(0,0){$h z_1$}}
\put(30, 5){\circle*{1}} \put(33, 5){\makebox(0,0){$h z_2$}}
\put(40, 5){\circle*{1}} \put(43, 5){\makebox(0,0){$h z_3$}}
\put(15,15){\circle*{1}} \put(20,15){\makebox(0,0){$h Z_3$}}
\put(35,15){\circle*{1}} \put(40,15){\makebox(0,0){$h z_1 Z_3$}}
\put(25,25){\circle*{1}} \put(29,25){\makebox(0,0){$h Z$}}
\put(10, 5){\line(1,2){5}}
\put(20, 5){\line(3,2){15}}
\put(30, 5){\line(1,2){5}}
\put(40, 5){\line(-5,2){25}}
\put(15,15){\line(1,1){10}}
\put(35,15){\line(-1,1){10}}
\put(63, 5){\makebox(0,0){$H$}}
\put(63,15){\makebox(0,0){$H/Z_3$}}
\put(63,25){\makebox(0,0){$H/Z$}}
\put(70, 5){\circle*{1}} \put(74, 5){\makebox(0,0){$h$}}
\put(80, 5){\circle*{1}} \put(83, 5){\makebox(0,0){$h z_1$}}
\put(90, 5){\circle*{1}} \put(93, 5){\makebox(0,0){$h z_2$}}
\put(100, 5){\circle*{1}} \put(103, 5){\makebox(0,0){$h z_3$}}
\put(75,15){\circle*{1}} \put(81,15){\makebox(0,0){$h z_1 Z_3$}}
\put(95,15){\circle*{1}} \put(99,15){\makebox(0,0){$h Z_3$}}
\put(85,25){\circle*{1}} \put(89,25){\makebox(0,0){$h Z$}}
\put(70, 5){\line(5,2){25}}
\put(80, 5){\line(-1,2){5}}
\put(90, 5){\line(-3,2){15}}
\put(100, 5){\line(-1,2){5}}
\put(75,15){\line(1,1){10}}
\put(95,15){\line(-1,1){10}}
\end{picture}}
%EP
\end{center}

This means that we can inflate the irreducible characters of $H/Z_1$ and
of $H/Z_2$ to $H$ but that for the inflations of those irreducible characters
of $H/Z_3$ to $H$ that are not characters of $G$, the values on classes
where case 3.~applies are determined only up to sign.

The {\GAP} function `PossibleCharacterTablesOfTypeV4G' computes the
candidates for the table of $H$ from the tables of the groups $H/Z_i$
by setting up the character table head of $H$ using the class fusions
from $H/Z_1$ and $H/Z_2$ to $G$,
and then forming the possible class fusions from $H$ to $H/Z_3$.

If case 3.~applies for a class $g^G$ with $g$ of *odd* element order
then exactly one preimage class in $H$ has odd element order,
and we can identify this class in the groups $H/Z_i$,
which resolves the ambiguity in this situation.
More generally, if $g = k^2$ holds for some $k \in G$ then all preimages of
$k^G$ in $H$ square to the same class of $H$,
so again this class can be identified.
In fact `PossibleCharacterTablesOfTypeV4G' checks whether the $p$-th power
maps of the candidate table for $H$ and the $p$-th power map of $H/Z_3$
together with the fusion candidate form a commutative diagram.

An additional criterion used by `PossibleCharacterTablesOfTypeV4G' is given
by the property that the product of two characters inflated from
$H/Z_1$ and $H/Z_2$, respectively, that are not characters of $G$
is a character of $H$ that contains $Z_3$ in its kernel,
so it is checked whether the scalar products of these characters
with all characters that are inflated from $H/Z_3$ via the candidate fusion
are nonnegative integers.

Once the fusions from $H$ to the groups $H/Z_i$ are known,
the computation of the irreducible $p$-modular characters of $H$
from those of the groups $H/Z_i$ is straightforward.

The only open question is why this construction is described in this note.
That is, how is it related to table automorphisms?

The answer is that in several interesting cases, the three subgroups $Z_1$,
$Z_2$, $Z_3$ are conjugate under an order three automorphism $\sigma$, say,
of $H$.
In this situation, the three factor groups $2_i.G = H/Z_i$ are isomorphic,
and we can describe the input tables and fusions by the character table of
$2_1.G$, the factor fusion from this group to $G$,
and the automorphism $\overline{\sigma}$ of $G$ that is induced by $\sigma$.
Assume that $\sigma(Z_1) = Z_2$ holds, and choose $h \in H$.
Then $\sigma(h Z_1) = \sigma(h) Z_2$ is mapped to
$\sigma(h) Z = \overline{\sigma}(h Z)$ under the factor fusion from $2_2.G$
to $G$.
Let us start with the character table of $2_1.G$,
and fix the class fusion to the character table of $G$.
We may choose the identity map as isomorphism from the table of $2_1.G$ to
the tables of $2_2.G$ and $2_3.G$,
which implies that the class of $h Z_1$ is identified with the class
of $h Z_2$ and in turn the class fusion from the table of $2_2.G$ to that of
$G$ can be chosen as the class fusion from the table of $2_1.G$ followed by
the permutation of classes of $G$ induced by $\overline{\sigma}$;
analogously, the fusion from the table of $2_3.G$ is obtained by appying
this permutation twice to the class fusion from the table of $2_1.G$.

For examples, see Section~\ref{xplV4G}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$p$-Modular Tables of Extensions by $p$-singular Automorphisms}%
\label{theorpsing}

Let $G$ be a finite group, and $H$ be an upward extension of $G$
by an automorphism of prime order $p$, say.
$H$ induces a table automorphism of the $p$-modular character table of $G$;
let $\pi$ denote the corresponding permutation of classes of $G$.
The columns of the $p$-modular character table of $H$ are given by the
orbits of $\pi$,
and the irreducible Brauer characters of $H$ are exactly the orbit sums
of $\pi$ on the irreducible Brauer characters of $G$.

Note that for computing the $p$-modular character table of $H$ from that
of $G$, it is sufficient to know the orbits of $\pi$ and not $\pi$ itself.
Also the ordinary character table of $H$ is not needed,
but since {\GAP} stores Brauer character tables relative to their ordinary
tables, we are interested mainly in cases where the ordinary character
tables of $G$ and $H$ and the $p$-modular character table of $G$ are known.
Assuming that the class fusion between the ordinary tables of $G$ and $H$
is stored on the table of $G$, the orbits of the action of $H$ on the
$p$-regular classes of $G$ can be read off from it.

The {\GAP} function `IBrOfExtensionBySingularAutomorphism' can be used
to compute the $p$-modular irreducibles of $H$.

For examples, see Section~\ref{xplpsing}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Character Tables of Subdirect Products of Index Two}%
\label{theorsubdir}

Let $C_2$ denote the cyclic group of order two,
let $G_1$, $G_2$ be two finite groups,
and for $i \in \{ 1, 2 \}$, let $\varphi_i\colon G_i \rightarrow C_2$
be an epimorphism with kernel $H_i$.
Let $G$ be the subdirect product (pullback) of $G_1$ and $G_2$ w.r.t. the
epimorphisms $\varphi_i$, i.e.,
\[
   G = \{ (g_1, g_2) \in G_1 \times G_2; \varphi_1(g_1) = \varphi_2(g_2) \} .
\]
The group $G$ has index two in the direct product $G_1 \times G_2$,
and $G$ contains $H_1 \times H_2$ as a subgroup of index two.

In the following,
we describe how the ordinary (or $p$-modular) character table of $G$
can be computed from the ordinary (or $p$-modular) character tables of
the groups $G_i$ and $H_i$, and the class fusions from $H_i$ to $G_i$.

(For the case that one of the groups $G_i$ is a cyclic group of order four,
an alternative way to construct the character table of $G$ is described
in Section~\ref{isoclinism}.
For the case that one of the groups $G_i$ acts fixed point freely on the
nontrivial irreducible characters of $H_i$, an alternative construction
is described in Section~\ref{theorMGA}.)

\begin{center}
%%tth: \includegraphics{ctblcons09.png}
%BP ctblcons0?
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(100,45)
\put(0,0){\begin{picture}(45,45)
\put(20, 0){\circle*{1}} % trivial group
\put( 7,13){\circle*{1}} \put( 4,13){\makebox(0,0){$H_1$}}
\put( 0,20){\circle*{1}} \put(-3,20){\makebox(0,0){$G_1$}}
\put(33,13){\circle*{1}} \put(36,13){\makebox(0,0){$H_2$}}
\put(40,20){\circle*{1}} \put(43,20){\makebox(0,0){$G_2$}}
\put(20,26){\circle*{1}} \put(27,26){\makebox(0,0){$H_1 \times H_2$}}
\put(13,33){\circle*{1}} \put( 5,33){\makebox(0,0){$G_1 \times H_2$}}
\put(27,33){\circle*{1}} \put(35,33){\makebox(0,0){$H_1 \times G_2$}}
\put(20,33){\circle*{1}} \put(23,33){\makebox(0,0){$G$}}
\put(20,40){\circle*{1}} \put(20,43){\makebox(0,0){$G_1 \times G_2$}}
\put(20, 0){\line(1,1){20}}
\put(20, 0){\line(-1,1){20}}
\put( 7,13){\line(1,1){20}}
\put(33,13){\line(-1,1){20}}
\put( 0,20){\line(1,1){20}}
\put(40,20){\line(-1,1){20}}
\put(20,26){\line(0,1){14}}
\end{picture}}
\put(60,2){\begin{picture}(45,45)
\put( 0, 5){\makebox(0,0){$H_2$}}
\put( 0,20){\makebox(0,0){$H_1 \times H_2$}}
\put( 0,35){\makebox(0,0){$H_1$}}
\put(20,20){\makebox(0,0){$G$}}
\put(40, 5){\makebox(0,0){$G_2$}}
\put(40,20){\makebox(0,0){$G_1 \times G_2$}}
\put(40,35){\makebox(0,0){$G_1$}}
\put( 0, 7){\vector(0,1){11}}
\put( 0,33){\vector(0,-1){11}}
\put(40, 7){\vector(0,1){11}}
\put(40,33){\vector(0,-1){11}}
\put( 2, 5){\vector(1,0){35}}
\put( 2,35){\vector(1,0){35}}
\put( 7,20){\vector(1,0){11}}
\put(22,20){\vector(1,0){11}}
\end{picture}}
\end{picture}}
%EP
\end{center}

Each conjugacy class of $G$ is either contained in $H_1 \times H_2$ or not.
In the former case, let $h_i \in H_i$ and $g_i \in G_i \setminus H_i$;
in particular, $(g_1, g_2) \in G$ because both $\varphi_1(g_1)$ and
$\varphi_2(g_2)$ are not the identity.
There are four possibilities.
\begin{itemize}
\item[1.]
   If $h_1^{H_1} = h_1^{G_1}$ and $h_2^{H_2} = h_2^{G_2}$ then
   $(h_1, h_2)^{H_1 \times H_2} = (h_1, h_2)^{G_1 \times G_2}$ holds,
   hence this class is equal to $(h_1, h_2)^G$.
\item[2.]
   If $h_1^{H_1} \not= h_1^{G_1}$ and $h_2^{H_2} \not= h_2^{G_2}$ then
   the four $H_1 \times H_2$-classes with the representatives $(h_1, h_2)$,
   $(h_1^{g_1}, h_2)$, $(h_1, h_2^{g_2})$, and $(h_1^{g_1}, h_2^{g_2})$
   fall into two $G$-classes,
   where $(h_1, h_2)$ is $G$-conjugate with $(h_1^{g_1}, h_2^{g_2})$,
   and $(h_1^{g_1}, h_2)$ is $G$-conjugate with $(h_1, h_2^{g_2})$.
\item[3.]
   If $h_1^{H_1} = h_1^{G_1}$ and $h_2^{H_2} \not= h_2^{G_2}$ then
   the two $H_1 \times H_2$-classes with the representatives $(h_1, h_2)$
   and $(h_1, h_2^{g_2})$ fuse in $G$;
   note that there is $\tilde{g}_1 \in C_{G_1}(h_1) \setminus H_1$,
   so $(\tilde{g}_1, g_2) \in G$ holds.
\item[4.]
   The case of $h_1^{H_1} \not= h_1^{G_1}$ and $h_2^{H_2} = h_2^{G_2}$
   is analogous to case 3.
\end{itemize}

It remains to deal with the $G$-classes that are not contained in
$H_1 \times H_2$.
Each such class is in fact a conjugacy class of $G_1 \times G_2$.
Note that two elements $g_1, g_2 \in G_1 \setminus H_1$ are $G_1$-conjugate
if and only if they are $H_1$-conjugate.
(If $g_1^x = g_2$ for $x \in G_1 \setminus H_1$ then $g_1^{g_1 x} = g_2$
holds, and $g_1 x \in H$.)
This implies $(g_1, g_2)^{G_1 \times G_2} = (g_1, g_2)^{H_1 \times H_2}$,
and thus this class is equal to $(g_1, g_2)^G$.

The (ordinary or $p$-modular) irreducible characters of $G$ are given
by the restrictions $\chi_G$ of all those irreducible characters $\chi$
of $G_1 \times G_2$ whose restriction to $H_1 \times H_2$ is irreducible,
plus the induced characters $\varphi^G$, where $\varphi$ runs over all
those irreducible characters of $H_1 \times H_2$ that do not occur as
restrictions of characters of $G_1 \times G_2$.

In other words, no irreducible character of $H_1 \times H_2$
has inertia subgroup $G$ inside $G_1 \times G_2$.
This can be seen as follows.
Let $\varphi$ be an irreducible character of $H_1 \times H_2$.
Then $\varphi = \varphi_1 \cdot \varphi_2$,
where $\varphi_!$, $\varphi_2$ are irreducible characters of $H_1 \times H_2$
with the properties that $H_2 \subseteq \ker(\varphi_1)$ and
$H_1 \subseteq \ker(\varphi_2)$.
Sloppy speaking, $\varphi_i$ is an irreducible character of $H_i$.

There are four possibilities.
\begin{itemize}
\item[1.]
   If $\varphi_1$ extends to $G_1$ and $\varphi_2$ extends to $G_2$
   then $\varphi$ extends to $G$,
   so $\varphi$ has inertia subgroup $G_1 \times G_2$.
\item[2.]
   If $\varphi_1$ does not extend to $G_1$ and $\varphi_2$ does not extend
   to $G_2$ then $\varphi^{G_1 \times G_2}$ is irreducible,
   so $\varphi$ has inertia subgroup $H_1 \times H_2$.
\item[3.]
   If $\varphi_1$ extends to $G_1$ and $\varphi_2$ does not extend to $G_2$
   then $\varphi$ extends to $G_1 \times H_2$ but not to $G_1 \times G_2$,
   so $\varphi$ has inertia subgroup $G_1 \times H_2$.
\item[4.]
   The case that $\varphi_1$ does not extend to $G_1$ and $\varphi_2$
   extends to $G_2$ is analogous to case 3,
   $\varphi$ has inertia subgroup $H_1 \times G_2$.
\end{itemize}

For examples, see Section~\ref{Gsubdir}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Examples for the Type $M.G.A$}\label{explMGA}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Character Tables of Dihedral Groups}

Let $n = 2^k \cdot m$ where $k$ is a nonnegative integer and $m$ is an odd
integer, and consider the dihedral group $D_{2n}$ of order $2n$.
Let $N$ denote the derived subgroup of $D_{2n}$.

If $k = 0$ then $D_{2n}$ has the structure $M.G.A$, with $M = N$ and
$G$ the trivial group, and $A$ a cyclic group of order two
that inverts each element of $N$ and hence acts fixed-point freely on $N$.
The smallest nontrivial example is of course that of $D_6 \cong S_3$.

\beginexample
gap> tblMG:= CharacterTable( "Cyclic", 3 );;
gap> tblG:= CharacterTable( "Cyclic", 1 );;
gap> tblGA:= CharacterTable( "Cyclic", 2 );;
gap> StoreFusion( tblMG, [ 1, 1, 1 ], tblG );
gap> StoreFusion( tblG, [ 1 ], tblGA );
gap> elms:= Elements( AutomorphismsOfTable( tblMG ) );
[ (), (2,3) ]
gap> orbs:= [ [ 1 ], [ 2, 3 ] ];;
gap> new:= PossibleCharacterTablesOfTypeMGA( tblMG, tblG, tblGA, orbs,
>              "S3" );
[ rec( table := CharacterTable( "S3" ), MGfusMGA := [ 1, 2, 2 ] ) ]
gap> Display( new[1].table );
S3

     2  1  .  1
     3  1  1  .

       1a 3a 2a
    2P 1a 3a 1a
    3P 1a 1a 2a

X.1     1  1  1
X.2     1  1 -1
X.3     2 -1  .
\endexample

If $k > 0$ then $D_{2n}$ has the structure $M.G.A$, with $M = N$ and
$G$ a cyclic group of order two such that $M.G$ is cyclic,
and $A$ is a cyclic group of order two that inverts each element of $M.G$
and hence acts fixed-point freely on $M.G$.
The smallest nontrivial example is of course that of $D_8$.

\beginexample
gap> tblMG:= CharacterTable( "Cyclic", 4 );;
gap> tblG:= CharacterTable( "Cyclic", 2 );;
gap> tblGA:= CharacterTable( "2^2" );;           
gap> OrdersClassRepresentatives( tblMG );
[ 1, 4, 2, 4 ]
gap> StoreFusion( tblMG, [ 1, 2, 1, 2 ], tblG ); 
gap> StoreFusion( tblG, [ 1, 2 ], tblGA );      
gap> elms:= Elements( AutomorphismsOfTable( tblMG ) );
[ (), (2,4) ]
gap> orbs:= Orbits( Group( elms[2] ), [ 1 ..4 ] );;
gap> new:= PossibleCharacterTablesOfTypeMGA( tblMG, tblG, tblGA, orbs,
>              "order8" );
[ rec( table := CharacterTable( "order8" ), MGfusMGA := [ 1, 2, 3, 2 ] ), 
  rec( table := CharacterTable( "order8" ), MGfusMGA := [ 1, 2, 3, 2 ] ) ]
\endexample

Here we get two possible tables, which are the character tables of the
dihedral and the quaternion group of order eight, respectively.

\beginexample
gap> List( new, x -> OrdersClassRepresentatives( x.table ) );
[ [ 1, 4, 2, 2, 2 ], [ 1, 4, 2, 4, 4 ] ]
gap> Display( new[1].table );
order8

     2  3  2  3  2  2

       1a 4a 2a 2b 2c
    2P 1a 2a 1a 1a 1a

X.1     1  1  1  1  1
X.2     1  1  1 -1 -1
X.3     1 -1  1  1 -1
X.4     1 -1  1 -1  1
X.5     2  . -2  .  .
\endexample

For each $k > 1$ and $m = 1$, we get two possible tables this way,
that of the dihedral group of order $2^{k+1}$ and that of the generalized
quaternion group of order $2^{k+1}$.

% Note that the groups in question are $2$-groups of maximal class,
% where each element in the cyclic subgroup of index two is conjugate
% to its inverse.
% So the only thing one has to show is that no other candidate tables
% arise.
%T so why does the third group of maximal class not arise?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{An $M.G.A$ Type Example with $M$ noncentral in $M.G$ (May 2004)}

\tthdump{\begin{tabular}{p{80mm}p{55mm}}}
%%tth: \begin{html} <table><tr><td width="65%"> \end{html}
The Sylow $7$ normalizer in the symmetric group $S_{12}$ has the structure
$7:6 \times S_5$, its intersection $N$ with the alternating group $A_{12}$
is of index two, it has the structure $(7:3 \times A_5):2$.

Let $M$ denote the normal subgroup of order $7$ in $N$,
let $G$ denote the normal subgroup of the type $3 \times A_5$
in $F = N/M \cong 3 \times S_5$,
and $A = F/G$, the cyclic group of order two.
Then $N$ has the structure $M.G.A$, where $A$ acts fixed-point freely
on the irreducible characters of $M.G = 7:3 \times A_5$
that do not contain $M$ in their kernels,
hence the character table of $N$ is determined by the character tables of
$M.G$ and $F$, and the action of $A$ on $M.G$.

Note that in this example, the group $M$ is not central in $M.G$,
unlike in most of our examples.
\tthdump{&}
%%tth: \begin{html} </td><td width="35%"> \end{html}
\begin{center}
%%tth: \includegraphics{ctblcons10.png}
%BP ctblcons10
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(45,40)(0,0)
\put(20,0){\circle*{1}} % trivial group
\put(14,6){\circle*{1}} \put(12,5){\makebox(0,0){$7$}}
\put(10,10){\circle*{1}} \put(5,10){\makebox(0,0){$7:3$}}
\put(35,15){\circle*{1}} \put(38,15){\makebox(0,0){$A_5$}}
\put(29,21){\circle*{1}} \put(35,21){\makebox(0,0){$7 \times A_5$}}
\put(25,25){\circle*{1}} \put(17,26){\makebox(0,0){$7:3 \times A_5$}}
\put(29,31){\circle*{1}} \put(38,31){\makebox(0,0){$(7 \times A_5):2$}}
\put(25,35){\circle*{1}} \put(25,38){\makebox(0,0){$N$}}
\put(20,0){\line(-1,1){10}}
\put(20,0){\line(1,1){15}}
\put(35,15){\line(-1,1){10}}
\put(14,6){\line(1,1){15}}
\put(10,10){\line(1,1){15}}
\put(25,25){\line(0,1){10}}
\put(29,21){\line(0,1){10}}
\put(29,31){\line(-1,1){4}}
\end{picture}}
%EP
\end{center}
\tthdump{\end{tabular}}
%%tth: \begin{html} </td></tr></table> \end{html}

\beginexample
gap> tblMG:= CharacterTable( "7:3" ) * CharacterTable( "A5" );;
gap> nsg:= ClassPositionsOfNormalSubgroups( tblMG );
[ [ 1 ], [ 1, 6 .. 11 ], [ 1 .. 5 ], [ 1, 6 .. 21 ], [ 1 .. 15 ], [ 1 .. 25 ]
 ]
gap> List( nsg, x -> Sum( SizesConjugacyClasses( tblMG ){ x } ) );
[ 1, 7, 60, 21, 420, 1260 ]
gap> tblG:= tblMG / nsg[2];;
gap> tblGA:= CharacterTable( "Cyclic", 3 ) * CharacterTable( "A5.2" );;
gap> GfusGA:= PossibleClassFusions( tblG, tblGA );
[ [ 1, 2, 3, 4, 4, 8, 9, 10, 11, 11, 15, 16, 17, 18, 18 ],
  [ 1, 2, 3, 4, 4, 15, 16, 17, 18, 18, 8, 9, 10, 11, 11 ] ]
gap> reps:= RepresentativesFusions( Group(()), GfusGA, tblGA );
[ [ 1, 2, 3, 4, 4, 8, 9, 10, 11, 11, 15, 16, 17, 18, 18 ] ]
gap> StoreFusion( tblG, reps[1], tblGA );
gap> acts:= PossibleActionsForTypeMGA( tblMG, tblG, tblGA );
[ [ [ 1 ], [ 2 ], [ 3 ], [ 4, 5 ], [ 6, 11 ], [ 7, 12 ], [ 8, 13 ],
      [ 9, 15 ], [ 10, 14 ], [ 16 ], [ 17 ], [ 18 ], [ 19, 20 ], [ 21 ],
      [ 22 ], [ 23 ], [ 24, 25 ] ] ]
gap> poss:= PossibleCharacterTablesOfTypeMGA( tblMG, tblG, tblGA,
>               acts[1], "A12N7" );
[ rec( table := CharacterTable( "A12N7" ),
      MGfusMGA := [ 1, 2, 3, 4, 4, 5, 6, 7, 8, 9, 5, 6, 7, 9, 8, 10, 11, 12, 
          13, 13, 14, 15, 16, 17, 17 ] ) ]
\endexample

Let us compare the result table with the table of the Sylow $7$ normalizer
in $A_{12}$.

\beginexample
gap> g:= AlternatingGroup( 12 );;
gap> IsRecord( TransformingPermutationsCharacterTables( poss[1].table,
>                CharacterTable( Normalizer( g, SylowSubgroup( g, 7 ) ) ) ) );
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{{\ATLAS} Tables of the Type $M.G.A$}\label{ATLASMGA}

We show the construction of some character tables of groups of the type
$M.G.A$ that are contained in the {\GAP} Character Table Library.
Each entry in the following input list contains the names of the library
character tables of $M.G$, $G$, $G.A$, and $M.G.A$.

First we consider the situation where $G$ is a simple group or a central
extension of a simple group whose character table is shown in the {\ATLAS},
and $M$ and $A$ are cyclic groups such that $M$ is central in $M.G$.

In the following cases,
the character tables are uniquely determined by the input tables.
Note that in each of these cases, $|A|$ and $|M|$ are coprime.

\beginexample
gap> listMGA:= [
> [ "3.A6",        "A6",        "A6.2_1",        "3.A6.2_1"       ],
> [ "3.A6",        "A6",        "A6.2_2",        "3.A6.2_2"       ],
> [ "6.A6",        "2.A6",      "2.A6.2_1",      "6.A6.2_1"       ],
> [ "6.A6",        "2.A6",      "2.A6.2_2",      "6.A6.2_2"       ],
> [ "3.A7",        "A7",        "A7.2",          "3.A7.2"         ],
> [ "6.A7",        "2.A7",      "2.A7.2",        "6.A7.2"         ],
> [ "3.L3(4)",     "L3(4)",     "L3(4).2_2",     "3.L3(4).2_2"    ],
> [ "3.L3(4)",     "L3(4)",     "L3(4).2_3",     "3.L3(4).2_3"    ],
> [ "2^2.L3(4)",   "2.L3(4)",   "2.L3(4).2_2",   "2^2.L3(4).2_2"  ],
> [ "2^2.L3(4)",   "2.L3(4)",   "2.L3(4).2_3",   "2^2.L3(4).2_3"  ],
> [ "6.L3(4)",     "2.L3(4)",   "2.L3(4).2_2",   "6.L3(4).2_2"    ],
> [ "6.L3(4)",     "2.L3(4)",   "2.L3(4).2_3",   "6.L3(4).2_3"    ],
> [ "12_1.L3(4)",  "4_1.L3(4)", "4_1.L3(4).2_2", "12_1.L3(4).2_2" ],
> [ "12_1.L3(4)",  "4_1.L3(4)", "4_1.L3(4).2_3", "12_1.L3(4).2_3" ],
> [ "12_2.L3(4)",  "4_2.L3(4)", "4_2.L3(4).2_2", "12_2.L3(4).2_2" ],
> [ "3.U3(5)",     "U3(5)",     "U3(5).2",       "3.U3(5).2"      ],
> [ "3.M22",       "M22",       "M22.2",         "3.M22.2"        ],
> [ "6.M22",       "2.M22",     "2.M22.2",       "6.M22.2"        ],
> [ "12.M22",      "4.M22",     "4.M22.2",       "12.M22.2"       ],
> [ "3.L3(7)",     "L3(7)",     "L3(7).2",       "3.L3(7).2"      ],
> [ "3_1.U4(3)",   "U4(3)",     "U4(3).2_1",     "3_1.U4(3).2_1"  ],
> [ "3_1.U4(3)",   "U4(3)",     "U4(3).2_2'",    "3_1.U4(3).2_2'" ],
> [ "3_2.U4(3)",   "U4(3)",     "U4(3).2_1",     "3_2.U4(3).2_1"  ],
> [ "3_2.U4(3)",   "U4(3)",     "U4(3).2_3'",    "3_2.U4(3).2_3'" ],
> [ "6_1.U4(3)",   "2.U4(3)",   "2.U4(3).2_1",   "6_1.U4(3).2_1"  ],
> [ "6_2.U4(3)",   "2.U4(3)",   "2.U4(3).2_1",   "6_2.U4(3).2_1"  ],
> [ "6_2.U4(3)",   "2.U4(3)",   "2.U4(3).2_3'",  "6_2.U4(3).2_3'" ],
> [ "12_1.U4(3)",  "4.U4(3)",   "4.U4(3).2_1",   "12_1.U4(3).2_1" ],
> [ "12_2.U4(3)",  "4.U4(3)",   "4.U4(3).2_1",   "12_2.U4(3).2_1" ],
> [ "3.G2(3)",     "G2(3)",     "G2(3).2",       "3.G2(3).2"      ],
> [ "3.U3(8)",     "U3(8)",     "U3(8).2",       "3.U3(8).2"      ],
> [ "3.U3(8).3_1", "U3(8).3_1", "U3(8).6",       "3.U3(8).6"      ],
> [ "3.J3",        "J3",        "J3.2",          "3.J3.2"         ],
> [ "3.U3(11)",    "U3(11)",    "U3(11).2",      "3.U3(11).2"     ],
> [ "3.McL",       "McL",       "McL.2",         "3.McL.2"        ],
> [ "3.O7(3)",     "O7(3)",     "O7(3).2",       "3.O7(3).2"      ],
> [ "6.O7(3)",     "2.O7(3)",   "2.O7(3).2",     "6.O7(3).2"      ],
> [ "3.U6(2)",     "U6(2)",     "U6(2).2",       "3.U6(2).2"      ],
> [ "6.U6(2)",     "2.U6(2)",   "2.U6(2).2",     "6.U6(2).2"      ],
> [ "3.Suz",       "Suz",       "Suz.2",         "3.Suz.2"        ],
> [ "6.Suz",       "2.Suz",     "2.Suz.2",       "6.Suz.2"        ],
> [ "3.ON",        "ON",        "ON.2",          "3.ON.2"         ],
> [ "3.Fi22",      "Fi22",      "Fi22.2",        "3.Fi22.2"       ],
> [ "6.Fi22",      "2.Fi22",    "2.Fi22.2",      "6.Fi22.2"       ],
> [ "3.2E6(2)",    "2E6(2)",    "2E6(2).2",      "3.2E6(2).2"     ],
> [ "6.2E6(2)",    "2.2E6(2)",  "2.2E6(2).2",    "6.2E6(2).2"     ],
> [ "3.F3+",       "F3+",       "F3+.2",         "3.F3+.2"        ],
> ];;
\endexample

%T add:
%T [ "6_1.U4(3)",  "2.U4(3)",   "2.U4(3).2_2'",  "6_1.U4(3).2_2'" ],

Also in the following cases, $|A|$ and $|M|$ are coprime,
we have $|M| = 3$ and $|A| = 2$.
The group $M.G$ has a central subgroup of the type $2^2 \times 3$,
and $A$ acts on this group by inverting the elements in the subgroup
of order $3$ and by swapping two involutions in the Klein four group.

\beginexample
gap> Append( listMGA, [
> [ "(2^2x3).L3(4)",  "2^2.L3(4)",   "2^2.L3(4).2_2", "(2^2x3).L3(4).2_2" ],
> [ "(2^2x3).L3(4)",  "2^2.L3(4)",   "2^2.L3(4).2_3", "(2^2x3).L3(4).2_3" ],
> [ "(2^2x3).U6(2)",  "2^2.U6(2)",   "2^2.U6(2).2",   "(2^2x3).U6(2).2"   ],
> [ "(2^2x3).2E6(2)", "2^2.2E6(2)",  "2^2.2E6(2).2",  "(2^2x3).2E6(2).2"  ],
> ] );
\endexample

Alternatively, we can regard these groups $M.G.A$ also as $\hat{M}.\hat{G}.A$,
with $|\hat{M}| = 2$ and such that $\hat{G}$ has a central subgroup
of order $6$ that is not central in $\hat{G}.A$.
However, in this situation it is more involved to compute the second
power map of $M.G.A \cong \hat{M}.\hat{G}.A$.

\beginexample
gap> Append( listMGA, [
> [ "(2^2x3).L3(4)",  "6.L3(4)",   "6.L3(4).2_2", "(2^2x3).L3(4).2_2" ],
> [ "(2^2x3).L3(4)",  "6.L3(4)",   "6.L3(4).2_3", "(2^2x3).L3(4).2_3" ],
> [ "(2^2x3).U6(2)",  "6.U6(2)",   "6.U6(2).2",   "(2^2x3).U6(2).2"   ],
> [ "(2^2x3).2E6(2)", "6.2E6(2)",  "6.2E6(2).2",  "(2^2x3).2E6(2).2"  ],
> ] );
\endexample

In the following cases, $|A| = |M| = 2$ holds,
and the character tables are determined by the input tables
only up to isoclinism.

(If we would have regarded $12.M_{22}.2$ as $M.G.A$ type group with
$|M| = |A| = 2$ and $G = 6.M_{22}$ then we would also get two solutions,
but prescribing the factor group of the type $4.M_{22}.2$ resolves the
ambiguity.
Note that the groups of the types $12_1.L_3(4).2_1$ and $12_2.L_3(4).2_1$
have central subgroups of order six, so we cannot choose $G$ equal to
$4_1.L_3(4)$ and $4_2.L_3(4)$, respectively, in these cases.)

\beginexample
gap> Append( listMGA, [
> [ "4_1.L3(4)",  "2.L3(4)",   "2.L3(4).2_1",   "4_1.L3(4).2_1"  ],
> [ "4_1.L3(4)",  "2.L3(4)",   "2.L3(4).2_2",   "4_1.L3(4).2_2"  ],
> [ "4_2.L3(4)",  "2.L3(4)",   "2.L3(4).2_1",   "4_2.L3(4).2_1"  ],
> [ "12_1.L3(4)", "6.L3(4)",   "6.L3(4).2_1",   "12_1.L3(4).2_1" ],
> [ "12_2.L3(4)", "6.L3(4)",   "6.L3(4).2_1",   "12_2.L3(4).2_1" ],
> [ "4.M22",      "2.M22",     "2.M22.2",       "4.M22.2"        ],
> [ "4.U4(3)",    "2.U4(3)",   "2.U4(3).2_2",   "4.U4(3).2_2"    ],
> [ "4.U4(3)",    "2.U4(3)",   "2.U4(3).2_3",   "4.U4(3).2_3"    ],
> [ "12_1.U4(3)", "6_1.U4(3)", "6_1.U4(3).2_2", "12_1.U4(3).2_2" ],
> [ "12_2.U4(3)", "6_2.U4(3)", "6_2.U4(3).2_3", "12_2.U4(3).2_3" ],
> ] );
\endexample

Also in the following cases, we have $|A| = |M| = 2$,
but the situation is different because $M.G$ has a central subgroup of
the type $2^2$ containing a unique subgroup of order $2$ that is central
in $M.G.A$.

\beginexample
gap> Append( listMGA, [
> [ "2^2.L3(4)",  "2.L3(4)",   "2.L3(4).2_2", "2^2.L3(4).2_2" ],
> [ "2^2.L3(4)",  "2.L3(4)",   "2.L3(4).2_3", "2^2.L3(4).2_3" ],
> [ "2^2.O8+(2)", "2.O8+(2)",  "2.O8+(2).2",  "2^2.O8+(2).2"  ],
> [ "2^2.U6(2)",  "2.U6(2)",   "2.U6(2).2",   "2^2.U6(2).2"   ],
> [ "2^2.2E6(2)", "2.2E6(2)",  "2.2E6(2).2",  "2^2.2E6(2).2"  ],
> ] );
\endexample

Additionally, there are a few cases where $A$ has order two,
and $G.A$ has a factor group of the type $2^2$,\label{3.A_6.2^2etc}
and a few cases where $M$ has the type $2^2$ and $A$ is of order three
and acts transitively on the involutions in $M$.

\beginexample
gap> Append( listMGA, [
> [ "3.A6.2_3",       "A6.2_3",    "A6.2^2",      "3.A6.2^2"          ],
> [ "3.L3(4).2_1",    "L3(4).2_1", "L3(4).2^2",   "3.L3(4).2^2"       ],
> [ "3_2.U4(3).2_3",  "U4(3).2_3", "U4(3).(2^2)_{133}",
>                                             "3_2.U4(3).(2^2)_{133}" ],
> [ "3^2.U4(3).2_3'", "3_2.U4(3).2_3'", "3_2.U4(3).(2^2)_{133}",
>                                             "3^2.U4(3).(2^2)_{133}" ],
> [ "2^2.L3(4)",      "L3(4)",     "L3(4).3",     "2^2.L3(4).3"       ],
> [ "(2^2x3).L3(4)",  "3.L3(4)",   "3.L3(4).3",   "(2^2x3).L3(4).3"   ],
> [ "2^2.L3(4).2_1",  "L3(4).2_1", "L3(4).6",     "2^2.L3(4).6"       ],
> [ "2^2.Sz(8)",      "Sz(8)",     "Sz(8).3",     "2^2.Sz(8).3"       ],
> [ "2^2.U6(2)",      "U6(2)",     "U6(2).3",     "2^2.U6(2).3"       ],
> [ "(2^2x3).U6(2)",  "3.U6(2)",   "3.U6(2).3",   "(2^2x3).U6(2).3"   ],
> [ "2^2.O8+(2)",     "O8+(2)",    "O8+(2).3",    "2^2.O8+(2).3"      ],
> [ "2^2.2E6(2)",     "2E6(2)",    "2E6(2).3",    "2^2.2E6(2).3"      ],
> ] );
\endexample

The constructions of the character tables of groups of the types
$4_2.L_3(4).2_3$ and $12_2.L_3(4).2_3$
is described in Section~\ref{4_2.L_3(4).2_3},
in these cases the {\GAP} functions return several possible tables.

The following function takes the ordinary character tables of the groups
$M.G$, $G$, and $G.A$, a string to be used as the `Identifier' of the
character table of $M.G.A$, and the character table of $M.G.A$ that is
contained in the {\GAP} Character Table Library;
the function first computes the possible actions of $G.A$ on the classes of
$M.G$, using the function `PossibleActionsForTypeMGA',
then computes the union of possible character tables for these actions,
and then representatives up to permutation equivalence;
if there is only one solution then the result table is compared with the
library table.

\beginexample
gap> ConstructOrdinaryMGATable:= function( tblMG, tblG, tblGA, name, lib )
>      local acts, poss, trans;
> 
>      acts:= PossibleActionsForTypeMGA( tblMG, tblG, tblGA );
>      poss:= Concatenation( List( acts, pi ->
>                 PossibleCharacterTablesOfTypeMGA( tblMG, tblG, tblGA, pi,
>                     name ) ) );
>      poss:= RepresentativesCharacterTables( poss );
>      if Length( poss ) = 1 then
>        # Compare the computed table with the library table.
>        if not IsCharacterTable( lib ) then
>          List( poss, x -> AutomorphismsOfTable( x.table ) );
>          Print( "#I  no library table for ", name, "\n" );
>        else
>          trans:= TransformingPermutationsCharacterTables( poss[1].table,
>                      lib );
>          if not IsRecord( trans ) then
>            Print( "#E  computed table and library table for ", name,
>                   " differ\n" );
>          fi;
>          # Compare the computed fusion with the stored one.
>          if OnTuples( poss[1].MGfusMGA, trans.columns )
>                 <> GetFusionMap( tblMG, lib ) then
>            Print( "#E  computed and stored fusion for ", name,
>                   " differ\n" );
>          fi;
>        fi;
>      else
>        Print( "#E  table of ", name, " not uniquely determined\n" );
>      fi;
>      return poss;
>    end;;
\endexample

The following function takes the ordinary character tables of the groups
$M.G$, $G.A$, and $M.G.A$,
and tries to construct the $p$-modular character tables of $M.G.A$ from the
$p$-modular character tables of the first two of these tables,
for all prime divisors $p$ of the order of $M.G.A$.
Note that the tables of $G$ are not needed in the construction,
only the class fusions from $M.G$ to $M.G.A$ and from $M.G.A$ to $G.A$
must be stored.

\beginexample
gap> ConstructModularMGATables:= function( tblMG, tblGA, ordtblMGA )
>    local name, poss, p, modtblMG, modtblGA, modtblMGA, modlib, trans;
> 
>    name:= Identifier( ordtblMGA );
>    poss:= [];
>    for p in Set( Factors( Size( ordtblMGA ) ) ) do
>      modtblMG := tblMG mod p;
>      modtblGA := tblGA mod p;
>      if ForAll( [ modtblMG, modtblGA ], IsCharacterTable ) then
>        modtblMGA:= BrauerTableOfTypeMGA( modtblMG, modtblGA, ordtblMGA );
>        Add( poss, modtblMGA );
>        modlib:= ordtblMGA mod p;
>        if IsCharacterTable( modlib ) then
>          trans:= TransformingPermutationsCharacterTables( modtblMGA.table,
>                      modlib );
>          if not IsRecord( trans ) then
>            Print( "#E  computed table and library table for ", name,
>                   " mod ", p, " differ\n" );
>          fi;
>        else
>          AutomorphismsOfTable( modtblMGA.table );
>          Print( "#I  no library table for ", name, " mod ", p, "\n" );
>        fi;
>      else
>        Print( "#I  not all input tables for ", name, " mod ", p,
>               " available\n" );
>      fi;
>    od;
> 
>    return poss;
>    end;;
\endexample

Now we run the constructions for the cases in the list.
Note that in order to avoid conflicts of the class fusions that arise in
the construction with the class fusions that are already stored on the
library tables, we choose identifiers for the result tables that are
different from the identifiers of the library tables.

\beginexample
gap> for  input in listMGA do
>      tblMG := CharacterTable( input[1] );
>      tblG  := CharacterTable( input[2] );
>      tblGA := CharacterTable( input[3] );
>      name  := Concatenation( "new", input[4] );
>      lib   := CharacterTable( input[4] );
>      poss:= ConstructOrdinaryMGATable( tblMG, tblG, tblGA, name, lib );
>      if Length( poss ) = 2 then
>        iso:= CharacterTableIsoclinic( poss[1].table );
>        if IsRecord( TransformingPermutationsCharacterTables( poss[2].table,
>                         iso ) ) then
>          Unbind( poss[2] );
>        fi;
>      fi;
>      if 1 < Length( poss ) then
>        Print( "#I  more than one possibility for ", name, "\n" );
>      elif lib = fail then
>        Print( "#I  no library table for ", input[4], "\n" );
>      else
>        ConstructModularMGATables( tblMG, tblGA, lib );
>      fi;
>    od;
#I  not all input tables for 6.Suz.2 mod 13 available
#I  not all input tables for 3.ON.2 mod 3 available
#I  not all input tables for 3.Fi22.2 mod 2 available
#I  not all input tables for 3.Fi22.2 mod 3 available
#I  not all input tables for 6.Fi22.2 mod 2 available
#I  not all input tables for 6.Fi22.2 mod 3 available
#I  not all input tables for 3.2E6(2).2 mod 2 available
#I  not all input tables for 3.2E6(2).2 mod 3 available
#I  not all input tables for 3.2E6(2).2 mod 5 available
#I  not all input tables for 3.2E6(2).2 mod 7 available
#I  not all input tables for 3.2E6(2).2 mod 11 available
#I  not all input tables for 3.2E6(2).2 mod 13 available
#I  not all input tables for 3.2E6(2).2 mod 17 available
#I  not all input tables for 3.2E6(2).2 mod 19 available
#I  not all input tables for 6.2E6(2).2 mod 2 available
#I  not all input tables for 6.2E6(2).2 mod 3 available
#I  not all input tables for 6.2E6(2).2 mod 5 available
#I  not all input tables for 6.2E6(2).2 mod 7 available
#I  not all input tables for 6.2E6(2).2 mod 11 available
#I  not all input tables for 6.2E6(2).2 mod 13 available
#I  not all input tables for 6.2E6(2).2 mod 17 available
#I  not all input tables for 6.2E6(2).2 mod 19 available
#I  not all input tables for 3.F3+.2 mod 2 available
#I  not all input tables for 3.F3+.2 mod 3 available
#I  not all input tables for 3.F3+.2 mod 5 available
#I  not all input tables for 3.F3+.2 mod 7 available
#I  not all input tables for 3.F3+.2 mod 13 available
#I  not all input tables for 3.F3+.2 mod 17 available
#I  not all input tables for 3.F3+.2 mod 29 available
#I  not all input tables for 3^2.U4(3).(2^2)_{133} mod 2 available
#I  not all input tables for 3^2.U4(3).(2^2)_{133} mod 5 available
#I  not all input tables for 3^2.U4(3).(2^2)_{133} mod 7 available
#I  not all input tables for 2^2.L3(4).3 mod 3 available
#I  not all input tables for 2^2.L3(4).3 mod 5 available
#I  not all input tables for 2^2.L3(4).3 mod 7 available
#I  not all input tables for 2^2.Sz(8).3 mod 5 available
#I  not all input tables for 2^2.Sz(8).3 mod 7 available
#I  not all input tables for 2^2.Sz(8).3 mod 13 available
#I  not all input tables for 2^2.U6(2).3 mod 3 available
#I  not all input tables for 2^2.U6(2).3 mod 5 available
#I  not all input tables for 2^2.U6(2).3 mod 7 available
#I  not all input tables for 2^2.U6(2).3 mod 11 available
#I  not all input tables for 2^2.O8+(2).3 mod 3 available
#I  not all input tables for 2^2.O8+(2).3 mod 5 available
#I  not all input tables for 2^2.O8+(2).3 mod 7 available
#I  not all input tables for 2^2.2E6(2).3 mod 2 available
#I  not all input tables for 2^2.2E6(2).3 mod 3 available
#I  not all input tables for 2^2.2E6(2).3 mod 5 available
#I  not all input tables for 2^2.2E6(2).3 mod 7 available
#I  not all input tables for 2^2.2E6(2).3 mod 11 available
#I  not all input tables for 2^2.2E6(2).3 mod 13 available
#I  not all input tables for 2^2.2E6(2).3 mod 17 available
#I  not all input tables for 2^2.2E6(2).3 mod 19 available
\endexample

%T the above list seems to be not up to date!

We do not get any unexpected output, so the character tables in question are
determined (up to isoclinism) by the inputs.

Alternative constructions of the character tables of $3.A_6.2^2$,
$3.L_3(4).2^2$, and $3_2.U_4(3).(2^2)_{133}$ can be found
in Section~\ref{xplGV43.A6.V4}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Character Tables of $4_2.L_3(4).2_3$ and $12_2.L_3(4).2_3$}%
\label{4_2.L_3(4).2_3}

In the construction of the character table of $M.G.A = 4_2.L_3(4).2_3$
from the tables of $M.G = 4_2.L_3(4)$ and $G.A = 2.L_3(4).2_3$,
the action of $A$ on the classes of $M.G$ is uniquely determined,
but we get four possible character tables.

\beginexample
gap> tblMG := CharacterTable( "4_2.L3(4)" );;
gap> tblG  := CharacterTable( "2.L3(4)" );;
gap> tblGA := CharacterTable( "2.L3(4).2_3" );;
gap> name  := "new4_2.L3(4).2_3";;
gap> lib   := CharacterTable( "4_2.L3(4).2_3" );;
gap> poss  := ConstructOrdinaryMGATable( tblMG, tblG, tblGA, name, lib );
[ rec( table := CharacterTable( "new4_2.L3(4).2_3" ), 
      MGfusMGA := [ 1, 2, 3, 2, 4, 5, 6, 7, 8, 7, 9, 10, 11, 10, 12, 12, 13, 
          14, 15, 14, 16, 17, 18, 17, 19, 20, 21, 22, 19, 22, 21, 20 ] ), 
  rec( table := CharacterTable( "new4_2.L3(4).2_3" ), 
      MGfusMGA := [ 1, 2, 3, 2, 4, 5, 6, 7, 8, 7, 9, 10, 11, 10, 12, 12, 13, 
          14, 15, 14, 16, 17, 18, 17, 19, 20, 21, 22, 19, 22, 21, 20 ] ), 
  rec( table := CharacterTable( "new4_2.L3(4).2_3" ), 
      MGfusMGA := [ 1, 2, 3, 2, 4, 5, 6, 7, 8, 7, 9, 10, 11, 10, 12, 12, 13, 
          14, 15, 14, 16, 17, 18, 17, 19, 20, 21, 22, 19, 22, 21, 20 ] ), 
  rec( table := CharacterTable( "new4_2.L3(4).2_3" ), 
      MGfusMGA := [ 1, 2, 3, 2, 4, 5, 6, 7, 8, 7, 9, 10, 11, 10, 12, 12, 13, 
          14, 15, 14, 16, 17, 18, 17, 19, 20, 21, 22, 19, 22, 21, 20 ] ) ]
\endexample

The existence of \emph{two} possible tables is clear from the fact that two
different but isoclinic groups really exist.
Indeed the result consists of two pairs of isoclinic tables,
so we have to decide which pair of tables belongs to the groups of the
type $4_2.L_3(4).2_3$.

\beginexample
gap> IsRecord( TransformingPermutationsCharacterTables( poss[1].table,
>                  CharacterTableIsoclinic( poss[4].table ) ) );
true
gap> IsRecord( TransformingPermutationsCharacterTables( poss[2].table,
>                  CharacterTableIsoclinic( poss[3].table ) ) );
true
\endexample

The possible tables differ only w.r.t.~the second power map and perhaps the
element orders.
The {\ATLAS} prints the table of the split extension of $M.G$,
this table is one of the first two possibilities.

\beginexample
gap> List( poss, x -> PowerMap( x.table, 2 ) );
[ [ 1, 3, 1, 1, 3, 6, 8, 6, 4, 4, 4, 5, 16, 18, 16, 13, 15, 13, 19, 21, 19, 
      21, 1, 1, 6, 6, 9, 9, 11, 11, 16, 16, 13, 13 ], 
  [ 1, 3, 1, 1, 3, 6, 8, 6, 4, 4, 4, 5, 16, 18, 16, 13, 15, 13, 19, 21, 19, 
      21, 1, 1, 6, 6, 11, 11, 9, 9, 16, 16, 13, 13 ], 
  [ 1, 3, 1, 1, 3, 6, 8, 6, 4, 4, 4, 5, 16, 18, 16, 13, 15, 13, 19, 21, 19, 
      21, 3, 3, 8, 8, 9, 9, 11, 11, 18, 18, 15, 15 ], 
  [ 1, 3, 1, 1, 3, 6, 8, 6, 4, 4, 4, 5, 16, 18, 16, 13, 15, 13, 19, 21, 19, 
      21, 3, 3, 8, 8, 11, 11, 9, 9, 18, 18, 15, 15 ] ]
\endexample

Indeed the second power map is not determined by the irreducible characters
(and by the second power map of the factor group $2.L_3(4).2_3$).
We determine this map using the embedding of $4_2.L_3(4).2_3$ into
$4.U_4(3).2_3$.
Note that $L_3(4).2_3$ is a maximal subgroup of $U_4(3).2_3$
(see~\cite[p.~52]{CCN85}), and that the subgroup $L_3(4)$ lifts to
$4_2.L_3(4)$ in $4.U_4(3)$ because no embedding of $L_3(4)$, $2.L_3(4)$,
or $4_1.L_3(4)$ into $4.U_4(3)$ is possible.

\beginexample
gap> PossiblePowerMaps( poss[1].table, 2 );
[ [ 1, 3, 1, 1, 3, 6, 8, 6, 4, 4, 4, 5, 16, 18, 16, 13, 15, 13, 19, 21, 19, 
      21, 1, 1, 6, 6, 11, 11, 9, 9, 16, 16, 13, 13 ], 
  [ 1, 3, 1, 1, 3, 6, 8, 6, 4, 4, 4, 5, 16, 18, 16, 13, 15, 13, 19, 21, 19, 
      21, 1, 1, 6, 6, 9, 9, 11, 11, 16, 16, 13, 13 ] ]
gap> t:= CharacterTable( "4.U4(3)" );;
gap> List( [ "L3(4)", "2.L3(4)", "4_1.L3(4)", "4_2.L3(4)" ], name ->
>          Length( PossibleClassFusions( CharacterTable( name ), t ) ) );
[ 0, 0, 0, 4 ]
\endexample

So the split extension $4_2.L_3(4).2_3$ of $4_2.L_3(4)$ is a subgroup of
the split extension $4.U_4(3).2_3$ of $4.U_4(3)$,
and only one of the two possible tables of $4_2.L_3(4).2_3$ admits a
class fusion into the {\ATLAS} table of $4.U_3(4).2_3$;
the construction of this table has been shown in Section~\ref{ATLASMGA}.

\beginexample
gap> t2:= CharacterTable( "4.U4(3).2_3" );;
gap> List( poss, x -> Length( PossibleClassFusions( x.table, t2 ) ) );
[ 0, 16, 0, 0 ]
\endexample

The correct table is the one that is contained in the {\GAP} Character
Table Library.

\beginexample
gap> IsRecord( TransformingPermutationsCharacterTables( poss[2].table,
>                  lib ) );
true
gap> ConstructModularMGATables( tblMG, tblGA, lib );;
\endexample

The same ambiguity arises in the construction of the character table of
$12_2.L_3(4).2_3$.
We resolve it using the fact that $4_2.L_3(4).2_3$ occurs as a factor
group, modulo the unique normal subgroup of order three.

\beginexample
gap> tblMG := CharacterTable( "12_2.L3(4)" );;
gap> tblG  := CharacterTable( "6.L3(4)" );;
gap> tblGA := CharacterTable( "6.L3(4).2_3" );;
gap> name  := "new12_2.L3(4).2_3";;
gap> lib   := CharacterTable( "12_2.L3(4).2_3" );;
gap> poss  := ConstructOrdinaryMGATable( tblMG, tblG, tblGA, name, lib );;
gap> Length( poss );
4
gap> nsg:= ClassPositionsOfNormalSubgroups( poss[1].table );
[ [ 1 ], [ 1, 5 ], [ 1, 7 ], [ 1, 4 .. 7 ], [ 1, 3 .. 7 ], [ 1 .. 7 ], 
  [ 1 .. 50 ], [ 1 .. 62 ] ]
gap> List( nsg, x -> Sum( SizesConjugacyClasses( poss[1].table ){ x } ) );
[ 1, 3, 2, 4, 6, 12, 241920, 483840 ]
gap> factlib:= CharacterTable( "4_2.L3(4).2_3" );;
gap> List( poss, x -> IsRecord( TransformingPermutationsCharacterTables(
>                         x.table / [ 1, 5 ], factlib ) ) );
[ false, true, false, false ]
gap> IsRecord( TransformingPermutationsCharacterTables( poss[2].table,
>                  lib ) );
true
gap> ConstructModularMGATables( tblMG, tblGA, lib );;
\endexample


%T other MGA example: "2^2.U4(3).(2^2)_{122}"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%\subsection{The Character Table of $(2^2 \times F_4(2)):2 \leq B$
%(March~2003)}\label{BM6}
%
%\tthdump{\begin{tabular}{|p{80mm}|p{55mm}|}}
%%%tth: \begin{html} <table><tr><td width="65%"> \end{html}
%The sporadic simple group $B$ contains a maximal subgroup $\overline{N}$
%of type $(2^2 \times F_4(2)):2$, which is the normalizer of a {\tt 2C}
%element $\overline{x}$ in $B$ (see~\cite[p.~217]{CCN85}).
%
%Let $Z = \langle x \rangle$.
%
%prove that the outer two swaps the two 2A elements in the $2^2$!
%
%this is because in the 2A centralizer, a group of structure $2.{}^2E_6(2).2$,
%the $2^2 \times F_4(2)$ type subgroups are maximal, so the two `2A' elements
%in .. are conjugate.
%
%\tthdump{&}
%%%tth: \begin{html} </td><td width="35%"> \end{html}
%
%\begin{center}
%%%tth: \includegraphics{ctblcons11.png}
%%BP ctblcons11
%\tthdump{\setlength{\unitlength}{3pt}
%\begin{picture}(45,45)(0,0)
%\put(15,15){\circle*{1}} % trivial group
%\put(10,20){\circle{1}} \put(7,20){\makebox(0,0){$C_1$}}
%\put(15,20){\circle{1}} \put(13,20){\makebox(0,0){$C_2$}}
%\put(20,20){\circle*{1}} \put(23,19){\makebox(0,0){$Z$}}
%\put(15,25){\circle*{1}} \put(12,26){\makebox(0,0){$2^2$}}
%\put(30,30){\circle*{1}}  % 2xF4(2)
%\put(25,35){\circle*{1}} \put(22,36){\makebox(0,0){$U$}}
%\put(30,35){\circle*{1}}  % diagonal
%\put(35,35){\circle*{1}}  % 2xF4(2).2
%\put(30,40){\circle*{1}} \put(30,43){\makebox(0,0){$N$}}
%\put(15,15){\line(1,1){20}}
%\put(10,20){\line(1,1){20}}
%\put(15,15){\line(0,1){10}}
%\put(30,30){\line(0,1){10}}
%\put(15,15){\line(-1,1){5}}
%\put(20,20){\line(-1,1){5}}
%\put(30,30){\line(-1,1){5}}
%\put(35,35){\line(-1,1){5}}
%\end{picture}}
%%EP
%\end{center}
%
%\tthdump{\end{tabular}}
%%%tth: \begin{html} </td></tr></table> \end{html}
%
%We compute the class fusion of $U$ into $B$;
%in order to speed this up, we first compute the class fusion of the $F_4(2)$
%subgroup of $U$ into $B$, and use it and the stored embedding into $U$
%to prescribe an approximation of the class fusion.
%
%\beginexample
%gap> f42:= CharacterTable( "F4(2)" );;
%gap> v4:= CharacterTable( "2^2" );;
%gap> dp:= v4 * f42;
%CharacterTable( "V4xF4(2)" )
%gap> b:= CharacterTable( "B" );;
%gap> f42fusb:= PossibleClassFusions( f42, b );;
%gap> Length( f42fusb );
%1
%gap> f42fusdp:= GetFusionMap( f42, dp );;
%gap> comp:= CompositionMaps( f42fusb[1], InverseMap( f42fusdp ) );
%[ 1, 3, 3, 3, 5, 6, 6, 7, 9, 9, 9, 9, 14, 14, 13, 13, 10, 14, 14, 12, 14, 17,
%  15, 18, 22, 22, 22, 22, 26, 26, 22, 22, 27, 27, 28, 31, 31, 39, 39, 36, 36,
%  33, 33, 39, 39, 35, 41, 42, 47, 47, 49, 49, 49, 58, 58, 56, 56, 66, 66, 66,
%  66, 58, 58, 66, 66, 69, 69, 60, 72, 72, 75, 79, 79, 81, 81, 85, 86, 83, 83,
%  91, 91, 94, 94, 104, 104, 109, 109, 116, 116, 114, 114, 132, 132, 140, 140 ]
%gap> dpfusb:= PossibleClassFusions( dp, b, rec( fusionmap:= comp ) );;
%gap> Length( dpfusb );
%12
%gap> v4fusdp:= GetFusionMap( v4, dp );
%[ 1, 96 .. 286 ]
%gap> List( dpfusb, x -> x{ last } );
%[ [ 1, 2, 2, 4 ], [ 1, 2, 2, 4 ], [ 1, 2, 4, 2 ], [ 1, 2, 2, 4 ], 
%  [ 1, 2, 2, 4 ], [ 1, 2, 4, 2 ], [ 1, 4, 2, 2 ], [ 1, 2, 4, 2 ], 
%  [ 1, 2, 4, 2 ], [ 1, 4, 2, 2 ], [ 1, 4, 2, 2 ], [ 1, 4, 2, 2 ] ]
%\endexample
%
%we see that two 2A, one 2C
%
%choose 2C in class 96,
%
%Set $G = U / Z$, $M.G = U$, and $G.A = N / Z$.
%The latter group is the direct product of $F_4(2).2$ and a cyclic group
%of order $2$.
%
%prove that not the isoclinic variant (i.e., that split)!
%(try: result table would not admit a fusion into B)
%
%Compute the class fusion from $G$ into $G.A$, and store it on the table of $G$.
%
%\beginexample
%gap> tblG:= dp / v4fusdp{ [ 1, 2 ] };;
%gap> tblMG:= dp;;
%gap> c2:= CharacterTable( "Cyclic", 2 );;
%gap> tblGA:= c2 * CharacterTable( "F4(2).2" );
%CharacterTable( "C2xF4(2).2" )
%gap> GfusGA:= PossibleClassFusions( tblG, tblGA );;
%gap> Length( GfusGA );
%4
%gap> StoreFusion( tblG, GfusGA[1], tblGA );
%\endexample
%
%why are they equally good?
%
%\beginexample
%gap> elms:= PossibleActionsForTypeMGA( tblMG, tblG, tblGA );;
%gap> Length( elms );
%1
%gap> poss:= PossibleCharacterTablesOfTypeMGA( tblMG, tblG, tblGA, elms[1],
%>               "(2^2xF4(2)):2" );;
%gap> Length( poss );
%1
%gap> tblMGA:= poss[1].table;;
%\endexample
%
%compute class fusion into B!
%
%\beginexample
%gap> approx:= CompositionMaps( Parametrized( dpfusb ),
%>                 InverseMap( poss[1].MGfusMGA ) );;
%gap> subfusb:= PossibleClassFusions( poss[1].table, b,     
%>                  rec( fusionmap:= approx ) );;
%...
%\endexample
%
%Finally, we compare the table we constructed with the one that is contained
%in the {\GAP} Character Table Library.
%
%\beginexample
%gap> IsRecord( TransformingPermutationsCharacterTables( tblMGA,
%>                  CharacterTable( "(2^2xF4(2)):2" ) ) );
%true
%\endexample
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%\subsection{The Character Table of $2.(2^2 \times F_4(2)):2 \leq 2.B$
%(March~2003)}
%
%The sporadic simple group $B$ contains a maximal subgroup $\overline{N}$
%of type $(2^2 \times F_4(2)):2$, which is the normalizer of a {\tt 2C}
%element $\overline{x}$ in $B$.
%The construction of the character table of $\overline{N}$ is described
%in Section~\ref{BM6}.
%The preimage $N$ of $\overline{N}$ in $2.B$ is the normalizer in $2.B$
%of the preimage of $\langle \overline{x} \rangle$.
%This preimage is a cyclic group of order $4$,
%whose generators lie in the class {\tt 4B} of the Monster group $M$,
%in fact $N$ occurs as the full normalizer of this {\tt 4B} element in $M$,
%with an intermediate group of type $2.B$.
%
%The centralizer of this element in $M$ (and in $2.B$) is a group $C$
%which has index $2$ in $N$.
%So $\overline{N}$ acts nontrivially on the centre of $C$,
%and hence the character table of $N$ is determined by the tables of
%$\overline{N}$ and $C$, and the action of $N$ on the classes of $C$.
%(The character table of $C$ has been computed by Simon Norton.)
%
%Thus we first compute the character table of $\overline{N}$.
%For that, we do *not* start with the subgroup which is obtained
%as the factor group of $C$ by the central subgroup of order $2$.
%Instead, we use that the structure of $\overline{N}$ is
%$(2^2 \times F_4(2)):2$,
%and that the table of this group is determined by the character tables
%of the subgroup $H$ of type $2^2 \times F_4(2)$
%and of the factor group $2 \times F_4(2).2$,
%and the action of $\overline{N}$ on the classes of $H$.
%
%\beginexample
%...
%\endexample
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Character Table of $2.(S_3 \times Fi_{22}.2) \leq 2.B$
(March~2003)}

The sporadic simple group $B$ contains a maximal subgroup $\overline{M}$
of type $S_3 \times Fi_{22}.2$.
In order to compute the character table of its preimage $M$
in the Schur cover $2.B$,
we first analyse the structure of $M$ and then describe
the construction of the character table from known character tables.

Let $Z$ denote the centre of $2.B$.
We start with $\overline{M} = M/Z$.
Its class fusion into $B$ is uniquely determined by the character tables.

\beginexample
gap> s3:= CharacterTable( "Dihedral", 6 );;
gap> fi222:= CharacterTable( "Fi22.2" );;
gap> tblMbar:= s3 * fi222;;
gap> b:= CharacterTable( "B" );;
gap> Mbarfusb:= PossibleClassFusions( tblMbar, b );;
gap> Length( Mbarfusb );
1
\endexample

The subgroup of type $Fi_{22}$ lifts to the proper covering group $2.Fi_{22}$
(that is, a group that is {\em not} a direct product $2 \times Fi_{22}$)
in $2.B$ since $2.B$ admits no class fusion from $Fi_{22}$.

\beginexample
gap> 2b:= CharacterTable( "2.B" );;
gap> PossibleClassFusions( CharacterTable( "Fi22" ), 2b );
[  ]
\endexample

So the preimage of $Fi_{22}.2$ is one of the two nonisomorphic but isoclinic
groups of type $2.Fi_{22}.2$, and we have to decide which one really occurs.
For that, we consider the subgroup of type $3 \times Fi_{22}.2$ in $B$,
which is a {\tt 3A} centralizer in $B$.
Its preimage has the structure $3 \times 2.Fi_{22}.2$ because the preimage
of the central group of order $3$ is a cyclic group of order $6$ and thus
contains a normal complement of the $2.Fi_{22}$ type subgroup.
And a class fusion into $2.B$ is possible only from the direct product
containing the $2.Fi_{22}.2$ group that is printed in the {\ATLAS}.

\beginexample
gap> c3:= CharacterTable( "Cyclic", 3 );;
gap> 2fi222:= CharacterTable( "2.Fi22.2" );;
gap> PossibleClassFusions( c3 * CharacterTableIsoclinic( 2fi222 ), 2b );
[  ]
\endexample

Next we note that the involutions in the normal subgroup $\overline{S}$
of type $S_3$ in $\overline{M}$ lift to involutions in $2.B$.

\beginexample
gap> s3inMbar:= GetFusionMap( s3, tblMbar );
[ 1, 113 .. 225 ]
gap> s3inb:= Mbarfusb[1]{ s3inMbar };
[ 1, 6, 2 ]
gap> 2bfusb:= GetFusionMap( 2b, b );;
gap> 2s3in2B:= InverseMap( 2bfusb ){ s3inb };
[ [ 1, 2 ], [ 8, 9 ], 3 ]
gap> CompositionMaps( OrdersClassRepresentatives( 2b ), last );
[ [ 1, 2 ], [ 3, 6 ], 2 ]
\endexample

Thus the preimage $S$ of $\overline{S}$ contains elements of order $6$
but no elements of order $4$,
which implies that $S$ is a direct product $2 \times S_3$.

The two complements $C_1$, $C_2$ of $Z$ in $S$ are normal in the preimage
$N$ of $\overline{N} = S_3 \times Fi_{22}$,
which is thus of type $S_3 \times 2.Fi_{22}$.
However, they are conjugate under the action of $2.Fi_{22}.2$,
as no class fusion from $S_3 \times 2.Fi_{22}.2$ into $2.B$ is possible.

\beginexample
gap> PossibleClassFusions( s3 * 2fi222, 2b );
[  ]
\endexample

(More specifically, the classes of element order $36$ in $2.Fi_{22}.2$
have centralizer orders $36$ and $72$, so their centralizer orders in
$S_3 \times 2.Fi_{22}.2$ are $216$ and $432$;
but the centralizers of order $36$ elements in $2.B$ have centralizer order
at most $216$.)

\tthdump{\begin{tabular}{p{80mm}p{55mm}}}
%%tth: \begin{html} <table><tr><td width="65%"> \end{html}
Now let us see how the character table of $M$ can be constructed.

Let $Y$ denote the normal subgroup of order $3$ in $M$,
and $U$ its centralizer in $M$, which has index $2$ in $M$.
Then the character table of $M$ is determined by the tables of
$M/Y$, $U$, $U/Y \cong 2.Fi_{22}.2$, and the action of $M$ on the
classes of $U$.

As for $M/Y$, consider the normal subgroup $N = N_M(C_1)$ of index $2$ in $M$.
In particular, $S/Y$ is central in $N/Y$ but not in $M/Y$,
so the character table of $M/Y$ is determined by the tables of
$M/(YZ)$, $N/Y \cong 2 \times 2.Fi_{22}$, $N/(YZ) \cong 2 \times Fi_{22}$,
and the action of $M/Y$ on the classes of $N/Y$.

Thus we proceed in two steps, starting with the computation of the
character table of $M/Y$, for which we choose the name according to the
structure $2^2.Fi_{22}.2$.
\tthdump{&}
%%tth: \begin{html} </td><td width="35%"> \end{html}
\begin{center}
%%tth: \includegraphics{ctblcons12.png}
%BP ctblcons12
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(45,40)(0,0)
\put(15,0){\circle*{1}}  % trivial group
\put(15,10){\circle*{1}} \put(18,9){\makebox(0,0){$Y$}}
\put(10,15){\circle{1}} \put(7,15){\makebox(0,0){$C_1$}}
\put(15,15){\circle{1}} \put(13,15){\makebox(0,0){$C_2$}}
\put(20,15){\circle*{1}} \put(23,14){\makebox(0,0){$6$}}
\put(15,20){\circle*{1}} \put(12,21){\makebox(0,0){$S$}}
\put(20,5){\circle*{1}} \put(23,4){\makebox(0,0){$Z$}}
\put(30,15){\circle*{1}}  % 2.Fi22
\put(35,20){\circle*{1}}  % 2.Fi22.2
\put(30,25){\circle*{1}}  % 2x2.Fi22
\put(35,30){\circle*{1}} \put(38,30){\makebox(0,0){$U$}}
\put(30,30){\circle*{1}}  %
\put(25,30){\circle*{1}} \put(22,31){\makebox(0,0){$N$}}
\put(30,35){\circle*{1}} \put(30,38){\makebox(0,0){$M$}}
\put(15,0){\line(1,1){20}}
\put(15,10){\line(1,1){20}}
\put(10,15){\line(1,1){20}}
\put(15,0){\line(0,1){20}}
\put(20,5){\line(0,1){10}}
\put(30,15){\line(0,1){20}}
\put(35,20){\line(0,1){10}}
\put(15,10){\line(-1,1){5}}
\put(20,15){\line(-1,1){5}}
\put(30,25){\line(-1,1){5}}
\put(35,30){\line(-1,1){5}}
\end{picture}}
%EP
\end{center}
\tthdump{\end{tabular}}
%%tth: \begin{html} </td></tr></table> \end{html}

\beginexample
gap> c2:= CharacterTable( "Cyclic", 2 );;
gap> 2fi22:= CharacterTable( "2.Fi22" );;
gap> tblNmodY:= c2 * 2fi22;;
gap> centre:= GetFusionMap( 2fi22, tblNmodY ){
>                 ClassPositionsOfCentre( 2fi22 ) };
[ 1, 2 ]
gap> tblNmod6:= tblNmodY / centre;;
gap> tblMmod6:= c2 * fi222;;
gap> fus:= PossibleClassFusions( tblNmod6, tblMmod6 );;
gap> Length( fus );
1
gap> StoreFusion( tblNmod6, fus[1], tblMmod6 );
gap> elms:= PossibleActionsForTypeMGA( tblNmodY, tblNmod6, tblMmod6 );;
gap> Length( elms );
1
gap> poss:= PossibleCharacterTablesOfTypeMGA( tblNmodY, tblNmod6, tblMmod6,
>               elms[1], "2^2.Fi22.2" );;
gap> Length( poss );
1
gap> tblMmodY:= poss[1].table;
CharacterTable( "2^2.Fi22.2" )
\endexample

So we found a unique solution for the character table of $M/Y$.
Now we compute the table of $M$.
For that, we have to specify the class fusion of $U/Y$ into $M/Y$;
it is unique up to table automorphisms of $M/Y$.

\beginexample
gap> tblU:= c3 * 2fi222;;
gap> tblUmodY:= tblU / GetFusionMap( c3, tblU );;
gap> fus:= PossibleClassFusions( tblUmodY, tblMmodY );;
gap> Length( RepresentativesFusions( Group( () ), fus, tblMmodY ) );
1
gap> StoreFusion( tblUmodY, fus[1], tblMmodY );
gap> elms:= PossibleActionsForTypeMGA( tblU, tblUmodY, tblMmodY );;
gap> Length( elms );
1
gap> poss:= PossibleCharacterTablesOfTypeMGA( tblU, tblUmodY, tblMmodY,
>               elms[1], "(S3x2.Fi22).2" );;
gap> Length( poss );
1
gap> tblM:= poss[1].table;
CharacterTable( "(S3x2.Fi22).2" )
gap> mfus2b:= PossibleClassFusions( tblM, 2b );;
gap> Length( RepresentativesFusions( tblM, mfus2b, 2b ) );
1
\endexample

We did not construct $M$ as a central extension of $\overline{M}$,
so we verify that the tables fit together; note that this way we get also
the class fusion from $M$ onto $\overline{M}$.

\beginexample
gap> Irr( tblM / ClassPositionsOfCentre( tblM ) ) = Irr( tblMbar );
true
\endexample

Finally, we compare the table we constructed with the one that is contained
in the {\GAP} Character Table Library.

\beginexample
gap> IsRecord( TransformingPermutationsCharacterTables( tblM,
>                  CharacterTable( "(S3x2.Fi22).2" ) ) );
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Character Table of $S_3 \times 2.U_4(3).2_2 \leq 2.Fi_{22}$
 (September 2002)}

\tthdump{\begin{tabular}{p{80mm}p{55mm}}}
%%tth: \begin{html} <table><tr><td width="75%"> \end{html}
The sporadic simple Fischer group $Fi_{22}$ contains a maximal subgroup
$\overline{M}$ of type $S_3 \times U_4(3).2_2$ (see~\cite[p.~163]{CCN85}).
We claim that the preimage $M$ of $\overline{M}$ in the central extension
$2.Fi_{22}$ has the structure $S_3 \times 2.U_4(3).2_2$,
where the factor of type $2.U_4(3).2_2$ is the one printed in the {\ATLAS}.

For that, we first note that the normal subgroup $\overline{S}$ of type
$S_3$ in $\overline{M}$ lifts to a group $S$ which has the structure
$2 \times S_3$.
This follows from the fact that all involutions in $Fi_{22}$ lift to
involutions in $2.Fi_{22}$ or, equivalently, the central involution in
$2.Fi_{22}$ is not a square.
\tthdump{&}
%%tth: \begin{html} </td><td width="25%"> \end{html}
\begin{center}
%%tth: \includegraphics{ctblcons13.png}
%BP ctblcons13
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(45,35)(0,0)
\put(15,0){\circle*{1}}  % trivial group
\put(5,10){\circle*{1}} \put(2,10){\makebox(0,0){$S_3$}}
\put(10,15){\circle*{1}} \put(8,16){\makebox(0,0){$S$}}
\put(20,25){\circle*{1}}
\put(20,5){\circle*{1}}
\put(30,15){\circle*{1}} \put(33,14){\makebox(0,0){$U^{\prime}$}}
\put(35,20){\circle*{1}} \put(38,20){\makebox(0,0){$U$}}
\put(25,30){\circle*{1}} \put(25,33){\makebox(0,0){$M$}}
\put(15,0){\line(1,1){20}}
\put(5,10){\line(1,1){20}}
\put(15,0){\line(-1,1){10}}
\put(20,5){\line(-1,1){10}}
\put(30,15){\line(-1,1){10}}
\put(35,20){\line(-1,1){10}}
\end{picture}}
%EP
\end{center}
\tthdump{\end{tabular}}
%%tth: \begin{html} </td></tr></table> \end{html}

\beginexample
gap> 2Fi22:= CharacterTable( "2.Fi22" );;
gap> ClassPositionsOfCentre( 2Fi22 );
[ 1, 2 ]
gap> 2 in PowerMap( 2Fi22, 2 );
false
\endexample

Second, the normal subgroup $\overline{U} \cong U_4(3).2_2$ of $Fi_{22}$
lifts to a nonsplit extension $U$ in $2.Fi_{22}$,
since $2.Fi_{22}$ contains no $U_4(3)$ type subgroup.
Furthermore, $U$ is the $2.U_4(3).2_2$ type group printed in the {\ATLAS}
because the isoclinic variant does not admit a class fusion into $2.Fi_{22}$.

\beginexample
gap> PossibleClassFusions( CharacterTable( "U4(3)" ), 2Fi22 );
[  ]
gap> tblU:= CharacterTable( "2.U4(3).2_2" );;
gap> iso:= CharacterTableIsoclinic( tblU );
CharacterTable( "Isoclinic(2.U4(3).2_2)" )
gap> PossibleClassFusions( iso, 2Fi22 );                      
[  ]
\endexample

Now there are just two possibilities.
Either the two $S_3$ type subgroups in $S$ are normal in $M$
(and thus $M$ is the direct product of any such $S_3$ with the preimage
of the $U_4(3).2_2$ type subgroup),
or they are conjugate in $M$.

Suppose we are in the latter situation,
let $z$ be a generator of the centre of $2.Fi_{22}$,
and let $\tau$, $\sigma$ be an involution and an order three element
respectively, in one of the $S_3$ type subgroups.

Each element $g \in U \setminus U^{\prime}$ conjugates $\tau$ to an
involution in the other $S_3$ type subgroup of $S$,
so $g^{-1} \tau g = \tau \sigma^{i} z$ for some $i \in \{ 0, 1, 2 \}$.
Furthermore, it is possible to choose $g$ as an involution.

\beginexample
gap> derpos:= ClassPositionsOfDerivedSubgroup( tblU );;
gap> outer:= Difference( [ 1 .. NrConjugacyClasses( tblU ) ], derpos );;
gap> 2 in OrdersClassRepresentatives( tblU ){ outer };
true
\endexample

With this choice, $(g \tau)^2 = \tau \sigma^{i} z \tau = \sigma^{-i} z$
holds, which means that $(g \tau)^3$ squares to $z$.
As we have seen above, this is impossible,
hence $M$ is a direct product, as claimed.

The class fusion of $M$ into $2.Fi_{22}$ is determined by the character
tables, up to table automorphisms.

\beginexample
gap> tblM:= CharacterTable( "Dihedral", 6 ) * tblU;;
gap> fus:= PossibleClassFusions( tblM, 2Fi22 );;
gap> Length( RepresentativesFusions( tblM, fus, 2Fi22 ) );
1
gap> IsRecord( TransformingPermutationsCharacterTables( tblM,
>                  CharacterTable( "2.Fi22M8" ) ) );
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Character Table of $4.HS.2 \leq HN.2$ (May 2002)}\label{HN2}

% Eamonn needed this table but did not ask for it ...

\tthdump{\begin{tabular}{p{95mm}p{40mm}}}
%%tth: \begin{html} <table><tr><td width="75%"> \end{html}
The maximal subgroup $U$ of type $2.HS.2$ in the sporadic simple group $HN$
extends to a group $N$ of structure $4.HS.2$ in the automorphism group
$HN.2$ of $HN$ (see~\cite[p.~166]{CCN85}).

$N$ is the normalizer of a `4D' element $g \in HN.2 \setminus HN$.
The centralizer $C$ of $g$ is of type $4.HS$, which is the central product of
$2.HS$ and the cyclic group $\langle g \rangle$ of order $4$.
We have $Z = Z(N) = \langle g^2 \rangle$.
Since $U/Z \cong HS.2$ is a complement of $\langle g \rangle / Z$
in $N/Z$,
the factor group $N/Z$ is a direct product of $HS.2$ and a cyclic
group of order $2$.
\tthdump{&}
%%tth: \begin{html} </td><td width="25%"> \end{html}
\begin{center}
%%tth: \includegraphics{ctblcons14.png}
%BP ctblcons14
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(45,30)(0,0)
\put(15,0){\circle*{1}}  % trivial group
\put(15,5){\circle*{1}} \put(18,4){\makebox(0,0){$Z$}}
\put(10,10){\circle*{1}} \put(7,10){\makebox(0,0){$\langle g \rangle$}}
\put(25,15){\circle*{1}}  % 2.HS
\put(20,20){\circle*{1}} \put(18,22){\makebox(0,0){$C$}}
\put(25,20){\circle*{1}}  % 2.HS.2
\put(30,20){\circle*{1}} \put(33,20){\makebox(0,0){$U$}}
\put(25,25){\circle*{1}} \put(25,28){\makebox(0,0){$N$}}
\put(15,5){\line(1,1){15}}
\put(10,10){\line(1,1){15}}
\put(15,0){\line(0,1){5}}
\put(25,15){\line(0,1){10}}
\put(15,5){\line(-1,1){5}}
\put(25,15){\line(-1,1){5}}
\put(30,20){\line(-1,1){5}}
\end{picture}}
%EP
\end{center}
\tthdump{\end{tabular}}
%%tth: \begin{html} </td></tr></table> \end{html}

Thus $N$ has the structure $2.G.2$, the normal subgroup $2.G$ being $C$,
the factor group $G.2$ being $2 \times HS.2$,
and $G$ being $2 \times HS$.
Each element in $N \setminus C$ inverts $g$, so $N$ acts fixed point
freely on the faithful irreducible characters of $C$.
Hence we can use `PossibleCharacterTablesOfTypeMGA' for constructing the
character table of $N$ from the tables of $C$ and $N/Z$ and the action of
$N$ on the classes of $C$.

We start with the table of the central product $C$.
It can be viewed as an isoclinic table of the direct product of
$2.HS$ and a cyclic group of order $2$, see~\ref{isoclinism}.

\beginexample
gap> c2:= CharacterTable( "Cyclic", 2 );;
gap> tblC:= CharacterTableIsoclinic( CharacterTable( "2.HS" ) * c2 );;
\endexample

The table of $G$ is given as that of the factor group by the unique
normal subgroup of $C$ that consists of two conjugacy classes.

\beginexample
gap> ord2:= Filtered( ClassPositionsOfNormalSubgroups( tblC ),
>               x -> Length( x ) = 2 );
[ [ 1, 3 ] ]
gap> tblCbar:= tblC / ord2[1];;
\endexample

Finally, we construct the table of the extension $G.2$
and the class fusion of $G$ into this table (which is uniquely determined
by the character tables).

\beginexample
gap> tblNbar:= CharacterTable( "HS.2" ) * c2;;
gap> fus:= PossibleClassFusions( tblCbar, tblNbar );
[ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
      21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 29, 30, 31, 32, 33, 34, 35, 36, 
      35, 36, 37, 38, 39, 40, 41, 42, 41, 42 ] ]
gap> StoreFusion( tblCbar, fus[1], tblNbar );
\endexample

Now we compute the table automorphisms of the table of $C$ that are
compatible with the extension $N$; we get two solutions.

\beginexample
gap> elms:= PossibleActionsForTypeMGA( tblC, tblCbar, tblNbar );
[ [ [ 1 ], [ 2, 4 ], [ 3 ], [ 5 ], [ 6, 8 ], [ 7 ], [ 9 ], [ 10 ], [ 11 ],
      [ 12, 14 ], [ 13 ], [ 15 ], [ 16, 18 ], [ 17 ], [ 19 ], [ 20 ], [ 21 ],
      [ 22 ], [ 23 ], [ 24, 26 ], [ 25 ], [ 27 ], [ 28, 30 ], [ 29 ], [ 31 ],
      [ 32, 34 ], [ 33 ], [ 35 ], [ 36, 38 ], [ 37 ], [ 39 ], [ 40, 42 ],
      [ 41 ], [ 43 ], [ 44, 46 ], [ 45 ], [ 47 ], [ 48, 50 ], [ 49 ],
      [ 51, 53 ], [ 52, 54 ], [ 55 ], [ 56, 58 ], [ 57 ], [ 59 ], [ 60 ],
      [ 61, 65 ], [ 62, 68 ], [ 63, 67 ], [ 64, 66 ], [ 69 ], [ 70, 72 ],
      [ 71 ], [ 73 ], [ 74, 76 ], [ 75 ], [ 77, 81 ], [ 78, 84 ], [ 79, 83 ],
      [ 80, 82 ] ],
  [ [ 1 ], [ 2, 4 ], [ 3 ], [ 5 ], [ 6, 8 ], [ 7 ], [ 9 ], [ 10 ], [ 11 ],
      [ 12, 14 ], [ 13 ], [ 15, 17 ], [ 16 ], [ 18 ], [ 19 ], [ 20 ], [ 21 ],
      [ 22 ], [ 23 ], [ 24, 26 ], [ 25 ], [ 27 ], [ 28, 30 ], [ 29 ], [ 31 ],
      [ 32, 34 ], [ 33 ], [ 35, 37 ], [ 36 ], [ 38 ], [ 39 ], [ 40, 42 ],
      [ 41 ], [ 43 ], [ 44, 46 ], [ 45 ], [ 47, 49 ], [ 48 ], [ 50 ],
      [ 51, 53 ], [ 52, 54 ], [ 55 ], [ 56, 58 ], [ 57 ], [ 59 ], [ 60 ],
      [ 61, 65 ], [ 62, 68 ], [ 63, 67 ], [ 64, 66 ], [ 69, 71 ], [ 70 ],
      [ 72 ], [ 73 ], [ 74, 76 ], [ 75 ], [ 77, 83 ], [ 78, 82 ], [ 79, 81 ],
      [ 80, 84 ] ] ]
\endexample

We compute the possible character tables arising from these two actions.

\beginexample
gap> poss:= List( elms, pi -> PossibleCharacterTablesOfTypeMGA(
>                 tblC, tblCbar, tblNbar, pi, "4.HS.2" ) );;
gap> List( poss, Length );
[ 0, 2 ]
\endexample

So one of the two table automorphisms turned out to be impossible;
the reason is that the corresponding ``character table'' would not admit
a second power map.
(Alternatively, we could exclude this action on $C$ by the fact
that it is not compatible with the action of $2.HS.2$ on its subgroup
$2.HS$, which occurs here as the restriction of the action of $N$ on $C$
to that of $U$ on $C \cap U$.)

The other table automorphism leads to two possible character tables.
This is not surprising since $N$ contains a subgroup of type
$2.HS.2$, and the above setup does not determine which of the two isoclinism
types of this group occurs.
Let us look at the possible class fusions from these tables into that of
$HN.2$:

\beginexample
gap> result:= poss[2];;
gap> hn2:= CharacterTable( "HN.2" );;
gap> possfus:= List( result, r -> PossibleClassFusions( r.table, hn2 ) );;
gap> List( possfus, Length );
[ 32, 0 ]
gap> RepresentativesFusions( result[1].table, possfus[1], hn2 );
[ [ 1, 46, 2, 2, 47, 3, 7, 45, 4, 58, 13, 6, 46, 47, 6, 47, 7, 48, 10, 62, 
      20, 9, 63, 21, 12, 64, 24, 27, 49, 50, 13, 59, 14, 16, 70, 30, 18, 53, 
      52, 17, 54, 20, 65, 22, 36, 56, 26, 76, 39, 77, 28, 59, 58, 31, 78, 41, 
      34, 62, 35, 65, 2, 45, 3, 45, 6, 48, 7, 47, 17, 54, 13, 49, 13, 50, 14, 
      50, 18, 53, 18, 52, 21, 56, 25, 57, 27, 59, 30, 60, 44, 72, 34, 66, 35, 
      66, 41, 71 ] ]
\endexample

Only one of the candidates admits an embedding,
and the class fusion is unique up to table automorphisms.
So we are done.

Finally, we compare the table we have constructed with the one that is
contained in the {\GAP} Character Table Library.

\beginexample
gap> libtbl:= CharacterTable( "4.HS.2" );
gap> IsRecord( TransformingPermutationsCharacterTables( result[1].table,
>                  libtbl ) );
true
\endexample

(The following paragraphs have been added in May 2006.)

The Brauer tables of $N = 2.G.2$ can be constructed as in
Section~\ref{ATLASMGA}.
Note that the Brauer tables of $C = 2.G$ and of $N / Z = G.2$
are automatically available because the ordinary tables constructed above
arose as a direct product and as an isoclinic table of a direct product,
and the {\GAP} Character Table Library contains the Brauer tables of the
direct factors involved.

\beginexample
gap> ForAll( Set( Factors( Size( result[1].table ) ) ),
>            p -> IsRecord( TransformingPermutationsCharacterTables(
>                     BrauerTableOfTypeMGA( tblC mod p, tblNbar mod p,
>                         result[1].table ).table, libtbl mod p ) ) );
true
\endexample

Here it is advantageous that the Brauer table of $C / Z = G$ is not needed
in the construction,
since {\GAP} does not know how to compute the $p$-modular table of the
ordinary table of $G$ constructed above.
Of course we have $G \cong 2 \times HS$,
and the $p$-modular table of $HS$ is known,
but in the construction of the table of $G$ as a factor of the table of $2.G$,
the information is missing that the nonsolvable simple direct factor of $2.G$
corresponds to the library table of $HS$.

% The missing information could be provided by setting the attribute
% that tells {\GAP} about the decomposition as a direct product,
% and storing the factor fusions to the library table of the two factors.
% 
% \beginexample
% gap> tblCbar;
% CharacterTable( "Isoclinic(2.HSxC2)/[ 1, 3 ]" )
% gap> cen:= ClassPositionsOfCentre( tblCbar );;
% gap> simp:= tblCbar / cen;
% CharacterTable( "Isoclinic(2.HSxC2)/[ 1, 3 ]/[ 1, 2 ]" )
% gap> libsimp:= CharacterTable( "HS" );;
% gap> TransformingPermutationsCharacterTables( simp, libsimp );
% rec( columns := (), rows := (), group := Group([ (23,24), (19,20), (15,16) ]) 
%  )
% gap> StoreFusion( tblCbar, GetFusionMap( tblCbar, simp ), libsimp );
% gap> SetFactorsOfDirectProduct( tblCbar, [ libsimp, c2 ] );
% gap> dpdecomp:= ClassPositionsOfDirectProductDecompositions( tblCbar );
% [ [ [ 1, 2 ], [ 1, 3 .. 47 ] ] ]
% gap> factc2:= tblCbar / dpdecomp[1][2];;
% gap> StoreFusion( tblCbar, GetFusionMap( tblCbar, factc2 ), c2 );
% \endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Character Tables of $4.A_6.2_3$ $12.A_6.2_3$,
and $4.L_2(25).2_3$}

\tthdump{\begin{tabular}{p{95mm}p{40mm}}}
%%tth: \begin{html} <table><tr><td width="75%"> \end{html}
For the ``broken box'' cases in the {\ATLAS} (see~\cite[p.~xxiv]{CCN85}),
the character tables can be constructed with the $M.G.A$ construction
method from Section~\ref{theorMGA}.

%T  missing: $9.U_3(8).3_3$ and $9.U_3(8).3_3^{\prime}$

The group $N = 4.A_6.2_3$ (see~\cite[p.~5]{CCN85}) can be described as an
upward extension of the normal subgroup $C \cong 4.A_6$
--which is a central product of $U = 2.A_6$ and a cyclic group
$\langle g \rangle$ of order $4$-- by a cyclic group of order $2$,
such that the factor group of $N$ by the central subgroup
$Z = \langle g^2 \rangle$ of order $2$
is isomorphic to a subdirect product $\overline{N}$ of $M_{10} = A_6.2_3$
and a cyclic group of order $4$
and that $N$ acts nontrivially on its normal subgroup $\langle g \rangle$.
\tthdump{&}
%%tth: \begin{html} </td><td width="25%"> \end{html}
\begin{center}
%%tth: \includegraphics{ctblcons15.png}
%BP ctblcons15
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(25,30)(0,0)
\put(10,0){\circle*{1}}  % trivial group
\put(10,5){\circle*{1}} \put(7,4){\makebox(0,0){$Z$}}
\put(5,10){\circle*{1}} \put(2,10){\makebox(0,0){$\langle g \rangle$}}
\put(20,15){\circle*{1}} \put(23,15){\makebox(0,0){$U$}}  % 2.A6
\put(15,20){\circle*{1}} \put(12,20){\makebox(0,0){$C$}}
\put(15,25){\circle*{1}} \put(15,28){\makebox(0,0){$N$}}
\put(10,5){\line(1,1){10}}
\put(5,10){\line(1,1){10}}
\put(10,0){\line(0,1){5}}
\put(15,20){\line(0,1){5}}
\put(10,5){\line(-1,1){5}}
\put(20,15){\line(-1,1){5}}
\end{picture}}
%EP
\end{center}
\tthdump{\end{tabular}}
%%tth: \begin{html} </td></tr></table> \end{html}

Thus $N$ has the structure $2.G.2$, with $2.G = C$ and $G.2 = \overline{N}$.
These two groups are isoclinic tables of $2 \times 2.A_6$ and of
$2 \times M_{10}$, respectively.
Each element in $N \setminus C$ inverts $g$, so it acts fixed point
freely on the faithful irreducible characters of $C$.
Hence we can use `PossibleCharacterTablesOfTypeMGA' for constructing the
character table of $N$ from the tables of $C$ and $N/Z$ and the action of
$N$ on the classes of $C$.

\beginexample
gap> c2:= CharacterTable( "Cyclic", 2 );;
gap> tblC:= CharacterTableIsoclinic( CharacterTable( "2.A6" ) * c2 );;
gap> ord2:= Filtered( ClassPositionsOfNormalSubgroups( tblC ),
>               x -> Length( x ) = 2 );
[ [ 1, 3 ] ]
gap> tblG:= tblC / ord2[1];;
gap> tblNbar:= CharacterTableIsoclinic( CharacterTable( "A6.2_3" ) * c2 );;
gap> fus:= PossibleClassFusions( tblG, tblNbar );
[ [ 1, 2, 3, 4, 5, 6, 5, 6, 7, 8, 9, 10, 9, 10 ] ]
gap> StoreFusion( tblG, fus[1], tblNbar );
gap> elms:= PossibleActionsForTypeMGA( tblC, tblG, tblNbar );
[ [ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7, 11 ], [ 8, 12 ],
      [ 9, 13 ], [ 10, 14 ], [ 15, 17 ], [ 16, 18 ], [ 19, 23 ], [ 20, 24 ],
      [ 21, 25 ], [ 22, 26 ] ],
  [ [ 1 ], [ 2, 4 ], [ 3 ], [ 5 ], [ 6 ], [ 7, 11 ], [ 8, 14 ], [ 9, 13 ],
      [ 10, 12 ], [ 15 ], [ 16, 18 ], [ 17 ], [ 19, 23 ], [ 20, 26 ],
      [ 21, 25 ], [ 22, 24 ] ],
  [ [ 1 ], [ 2, 4 ], [ 3 ], [ 5 ], [ 6 ], [ 7, 11 ], [ 8, 14 ], [ 9, 13 ],
      [ 10, 12 ], [ 15, 17 ], [ 16 ], [ 18 ], [ 19, 23 ], [ 20, 26 ],
      [ 21, 25 ], [ 22, 24 ] ] ]
gap> poss:= List( elms, pi -> PossibleCharacterTablesOfTypeMGA(
>                 tblC, tblG, tblNbar, pi, "4.A6.2_3" ) );
[ [  ], [  ], 
  [ rec( table := CharacterTable( "4.A6.2_3" ), MGfusMGA := [ 1, 2, 3, 2, 4, 
              5, 6, 7, 8, 9, 6, 9, 8, 7, 10, 11, 10, 12, 13, 14, 15, 16, 13, 
              16, 15, 14 ] ) ] ]
\endexample

So we get a unique solution.
It coincides with the character table of $4.A_6.2_3$ that is stored
in the {\GAP} Character Table Library.

\beginexample
gap> IsRecord( TransformingPermutationsCharacterTables( poss[3][1].table,
>                  CharacterTable( "4.A6.2_3" ) ) );
true
\endexample

Note that the first of the three actions would centralize the centre of $C$,
so the resulting group $N$ would be a central product of a cyclic group of
order four with a group of the type $2.A_6.2_3$ that involves $2.A_6$ and
$A_6.2_3$, but such a group does not exist (cf.~\cite[p.~xxiv]{CCN85}).
The first two action would lead to tables that do not admit a second power
map.

In fact the second power map of the character table of $4.A_6.2_3$ is not
uniquely determined by the matrix of character values but is unique up to
automorphisms of this matrix;
the function `PossibleCharacterTablesOfTypeMGA' takes this into account,
and returns only representatives, in this case one table.

%T Show this explicitly!
% The four classes of order $16$ elements square to a pair of
% Galois conjugate classes of element order $8$,
% which differ only on two irreducible characters
% that are equal on all other classes.

\tthdump{\begin{tabular}{p{95mm}p{40mm}}}
%%tth: \begin{html} <table><tr><td width="75%"> \end{html}
The group $N = 12.A_6.2_3$ (see~\cite[p.~5]{CCN85}) can be described as an
upward extension of the normal subgroup $C \cong 12.A_6$
--which is a central product of $U = 6.A_6$ and a cyclic group
$\langle g \rangle$ of order $4$-- by a cyclic group of order $2$,
such that the factor group of $N$ by the central subgroup
$Z = \langle g^2 \rangle$ of order $2$
is isomorphic to a subdirect product $\overline{N}$ of $3.M_{10} = 3.A_6.2_3$
and a cyclic group of order $4$
and that $N$ acts nontrivially on its normal subgroup $\langle g \rangle$.

Note that $N$ has a central subgroup $Y$, say, of order $3$,
so the situation here differs from that for groups of the type $12.G.2$ with
$G$ one of $L_3(4)$, $U_4(3)$, where the action on the normal subgroup
of order three is nontrivial.

\tthdump{&}
%%tth: \begin{html} </td><td width="25%"> \end{html}

\begin{center} 
%%tth: \includegraphics{ctblcons16.png} 
%BP ctblcons16
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(45,35)(0,0)
\put(15,0){\circle*{1}}  % trivial group
\put(15,5){\circle*{1}} \put(12,4){\makebox(0,0){$Z$}}
\put(10,10){\circle*{1}} \put(7,10){\makebox(0,0){$\langle g \rangle$}}
\put(21,6){\circle*{1}} \put(24,6){\makebox(0,0){$Y$}}
\put(21,11){\circle*{1}}
\put(30,20){\circle*{1}} \put(33,20){\makebox(0,0){$U$}}  % 6.A6
\put(16,16){\circle*{1}}
\put(25,25){\circle*{1}} \put(22,25){\makebox(0,0){$C$}}
\put(25,30){\circle*{1}} \put(25,33){\makebox(0,0){$N$}}
\put(15,5){\line(1,1){15}}
\put(10,10){\line(1,1){15}}
\put(15,0){\line(1,1){6}}
\put(15,0){\line(0,1){5}}
\put(21,6){\line(0,1){5}}
\put(25,25){\line(0,1){5}}
\put(15,5){\line(-1,1){5}}
\put(21,11){\line(-1,1){5}}
\put(30,20){\line(-1,1){5}}
\end{picture}}
%EP
\end{center}

\tthdump{\end{tabular}} 
%%tth: \begin{html} </td></tr></table> \end{html}

Thus $N$ has the structure $2.G.2$, with $2.G = C$ and $G.2 = \overline{N}$.
These two groups are isoclinic tables of $2 \times 6.A_6$ and of
$2 \times 3.M_{10}$, respectively.
Each element in $N \setminus C$ inverts $g$, so it acts fixed point
freely on the faithful irreducible characters of $C$.
Hence we can use `PossibleCharacterTablesOfTypeMGA' for constructing the
character table of $N$ from the tables of $C$ and $N/Z$ and the action of
$N$ on the classes of $C$.

\beginexample
gap> c2:= CharacterTable( "Cyclic", 2 );;
gap> tblC:= CharacterTableIsoclinic( CharacterTable( "6.A6" ) * c2 );;
gap> ord2:= Filtered( ClassPositionsOfNormalSubgroups( tblC ),
>               x -> Length( x ) = 2 );
[ [ 1, 7 ] ]
gap> tblG:= tblC / ord2[1];;
gap> tblNbar:= CharacterTableIsoclinic( CharacterTable( "3.A6.2_3" ) * c2 );;
gap> fus:= PossibleClassFusions( tblG, tblNbar );
[ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 13, 14, 15, 16, 17, 18, 
      19, 20, 21, 22, 23, 24, 25, 26, 21, 22, 23, 24, 25, 26 ], 
  [ 1, 2, 5, 6, 3, 4, 7, 8, 11, 12, 9, 10, 13, 14, 13, 14, 15, 16, 19, 20, 
      17, 18, 21, 22, 25, 26, 23, 24, 21, 22, 25, 26, 23, 24 ] ]
gap> rep:= RepresentativesFusions( Group( () ), fus, tblNbar );
[ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 13, 14, 15, 16, 17, 18, 
      19, 20, 21, 22, 23, 24, 25, 26, 21, 22, 23, 24, 25, 26 ] ]
gap> StoreFusion( tblG, rep[1], tblNbar );
gap> elms:= PossibleActionsForTypeMGA( tblC, tblG, tblNbar );
[ [ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ], 
      [ 11 ], [ 12 ], [ 13 ], [ 14 ], [ 15 ], [ 16 ], [ 17 ], [ 18 ], 
      [ 19, 23 ], [ 20, 24 ], [ 21, 25 ], [ 22, 26 ], [ 27, 33 ], [ 28, 34 ], 
      [ 29, 35 ], [ 30, 36 ], [ 31, 37 ], [ 32, 38 ], [ 39, 51 ], [ 40, 52 ], 
      [ 41, 53 ], [ 42, 54 ], [ 43, 55 ], [ 44, 56 ], [ 45, 57 ], [ 46, 58 ], 
      [ 47, 59 ], [ 48, 60 ], [ 49, 61 ], [ 50, 62 ] ], 
  [ [ 1 ], [ 2, 8 ], [ 3 ], [ 4, 10 ], [ 5 ], [ 6, 12 ], [ 7 ], [ 9 ], 
      [ 11 ], [ 13 ], [ 14 ], [ 15 ], [ 16 ], [ 17 ], [ 18 ], [ 19, 23 ], 
      [ 20, 26 ], [ 21, 25 ], [ 22, 24 ], [ 27 ], [ 28, 34 ], [ 29 ], 
      [ 30, 36 ], [ 31 ], [ 32, 38 ], [ 33 ], [ 35 ], [ 37 ], [ 39, 51 ], 
      [ 40, 58 ], [ 41, 53 ], [ 42, 60 ], [ 43, 55 ], [ 44, 62 ], [ 45, 57 ], 
      [ 46, 52 ], [ 47, 59 ], [ 48, 54 ], [ 49, 61 ], [ 50, 56 ] ], 
  [ [ 1 ], [ 2, 8 ], [ 3 ], [ 4, 10 ], [ 5 ], [ 6, 12 ], [ 7 ], [ 9 ], 
      [ 11 ], [ 13 ], [ 14 ], [ 15 ], [ 16 ], [ 17 ], [ 18 ], [ 19, 23 ], 
      [ 20, 26 ], [ 21, 25 ], [ 22, 24 ], [ 27, 33 ], [ 28 ], [ 29, 35 ], 
      [ 30 ], [ 31, 37 ], [ 32 ], [ 34 ], [ 36 ], [ 38 ], [ 39, 51 ], 
      [ 40, 58 ], [ 41, 53 ], [ 42, 60 ], [ 43, 55 ], [ 44, 62 ], [ 45, 57 ], 
      [ 46, 52 ], [ 47, 59 ], [ 48, 54 ], [ 49, 61 ], [ 50, 56 ] ] ]
gap> poss:= List( elms, pi -> PossibleCharacterTablesOfTypeMGA(
>                 tblC, tblG, tblNbar, pi, "12.A6.2_3" ) );
[ [  ], [  ], 
  [ rec( table := CharacterTable( "12.A6.2_3" ), MGfusMGA := [ 1, 2, 3, 4, 5, 
              6, 7, 2, 8, 4, 9, 6, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
              16, 19, 18, 17, 20, 21, 22, 23, 24, 25, 20, 26, 22, 27, 24, 28, 
              29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 29, 36, 31, 38, 
              33, 40, 35, 30, 37, 32, 39, 34 ] ) ] ]
\endexample

So we get again a unique solution.
It coincides with the character table that is stored in the {\GAP}
Character Table Library.

\beginexample
gap> IsRecord( TransformingPermutationsCharacterTables( poss[3][1].table,
>                  CharacterTable( "12.A6.2_3" ) ) );
true
\endexample

The construction of the character table of $4.L_2(25).2_3$ is analogous
to that of the table of $4.A_6.2_3$.

\beginexample
gap> c2:= CharacterTable( "Cyclic", 2 );;
gap> tblC:= CharacterTableIsoclinic( CharacterTable( "2.L2(25)" ) * c2 );;
gap> ord2:= Filtered( ClassPositionsOfNormalSubgroups( tblC ),
>               x -> Length( x ) = 2 );
[ [ 1, 3 ] ]
gap> tblG:= tblC / ord2[1];;
gap> tblNbar:= CharacterTableIsoclinic( CharacterTable( "L2(25).2_3" ) * c2 );;
gap> fus:= PossibleClassFusions( tblG, tblNbar );
[ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 9, 10, 11, 12, 13, 14, 13, 14, 15, 16, 15, 
      16, 17, 18, 17, 18, 19, 20, 19, 20 ], 
  [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 9, 10, 11, 12, 13, 14, 13, 14, 17, 18, 17, 
      18, 19, 20, 19, 20, 15, 16, 15, 16 ], 
  [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 9, 10, 11, 12, 13, 14, 13, 14, 19, 20, 19, 
      20, 15, 16, 15, 16, 17, 18, 17, 18 ] ]
gap> rep:= RepresentativesFusions( Group( () ), fus, tblNbar );
[ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 9, 10, 11, 12, 13, 14, 13, 14, 15, 16, 15, 
      16, 17, 18, 17, 18, 19, 20, 19, 20 ] ]
gap> StoreFusion( tblG, rep[1], tblNbar );
gap> elms:= PossibleActionsForTypeMGA( tblC, tblG, tblNbar );
[ [ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ], 
      [ 11, 13 ], [ 12, 14 ], [ 15, 19 ], [ 16, 20 ], [ 17, 21 ], [ 18, 22 ], 
      [ 23, 25 ], [ 24, 26 ], [ 27, 33 ], [ 28, 34 ], [ 29, 31 ], [ 30, 32 ], 
      [ 35, 39 ], [ 36, 40 ], [ 37, 41 ], [ 38, 42 ], [ 43, 47 ], [ 44, 48 ], 
      [ 45, 49 ], [ 46, 50 ], [ 51, 55 ], [ 52, 56 ], [ 53, 57 ], [ 54, 58 ] ]
    , [ [ 1 ], [ 2, 4 ], [ 3 ], [ 5 ], [ 6 ], [ 7 ], [ 8, 10 ], [ 9 ], 
      [ 11 ], [ 12, 14 ], [ 13 ], [ 15, 19 ], [ 16, 22 ], [ 17, 21 ], 
      [ 18, 20 ], [ 23, 25 ], [ 24 ], [ 26 ], [ 27, 31 ], [ 28, 34 ], 
      [ 29, 33 ], [ 30, 32 ], [ 35, 39 ], [ 36, 42 ], [ 37, 41 ], [ 38, 40 ], 
      [ 43, 47 ], [ 44, 50 ], [ 45, 49 ], [ 46, 48 ], [ 51, 55 ], [ 52, 58 ], 
      [ 53, 57 ], [ 54, 56 ] ], 
  [ [ 1 ], [ 2, 4 ], [ 3 ], [ 5 ], [ 6 ], [ 7 ], [ 8, 10 ], [ 9 ], 
      [ 11, 13 ], [ 12 ], [ 14 ], [ 15, 19 ], [ 16, 22 ], [ 17, 21 ], 
      [ 18, 20 ], [ 23, 25 ], [ 24 ], [ 26 ], [ 27, 33 ], [ 28, 32 ], 
      [ 29, 31 ], [ 30, 34 ], [ 35, 39 ], [ 36, 42 ], [ 37, 41 ], [ 38, 40 ], 
      [ 43, 47 ], [ 44, 50 ], [ 45, 49 ], [ 46, 48 ], [ 51, 55 ], [ 52, 58 ], 
      [ 53, 57 ], [ 54, 56 ] ] ]
gap> poss:= List( elms, pi -> PossibleCharacterTablesOfTypeMGA(
>                 tblC, tblG, tblNbar, pi, "4.L2(25).2_3" ) );
[ [  ], [  ], 
  [ rec( table := CharacterTable( "4.L2(25).2_3" ), MGfusMGA := [ 1, 2, 3, 2, 
              4, 5, 6, 7, 8, 7, 9, 10, 9, 11, 12, 13, 14, 15, 12, 15, 14, 13, 
              16, 17, 16, 18, 19, 20, 21, 22, 21, 20, 19, 22, 23, 24, 25, 26, 
              23, 26, 25, 24, 27, 28, 29, 30, 27, 30, 29, 28, 31, 32, 33, 34, 
              31, 34, 33, 32 ] ) ] ]
gap> IsRecord( TransformingPermutationsCharacterTables( poss[3][1].table,
>                  CharacterTable( "4.L2(25).2_3" ) ) );
true
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\tthdump{\subsection{Pseudo Character Tables of the Type $M.G.A$ (May 2004)}}
%%tth: \subsection{
%%tth: \begin{html}<A name="pseudo_tables_MGA">\end{html}
%%tth: Pseudo Character Tables of the Type $M.G.A$
%%tth: \begin{html}</A>\end{html} (May 2004)}

With the construction method for character tables of groups of the type
$M.G.A$, one can construct tables that have many properties of character
tables but that are not character tables of groups.
For example, the group $3.A_6.2_3$ has a \emph{central} subgroup of order $3$,
so it is not of the type $M.G.A$ with fixed-point free action on the
faithful characters of $M.G$.

However, if we apply the ``$M.G.A$ construction'' to the groups $M.G = 3.A_6$,
$G = A_6$, and $G.A = A_6.2_3$ then we get a (in this case unique) result.

\beginexample
gap> tblMG := CharacterTable( "3.A6" );;
gap> tblG  := CharacterTable( "A6" );;
gap> tblGA := CharacterTable( "A6.2_3" );;
gap> elms:= PossibleActionsForTypeMGA( tblMG, tblG, tblGA );  
[ [ [ 1 ], [ 2, 3 ], [ 4 ], [ 5, 6 ], [ 7, 8 ], [ 9 ], [ 10, 11 ],
      [ 12, 15 ], [ 13, 17 ], [ 14, 16 ] ] ]
gap> poss:= PossibleCharacterTablesOfTypeMGA(                  
>                 tblMG, tblG, tblGA, elms[1], "pseudo" );    
[ rec( table := CharacterTable( "pseudo" ), 
      MGfusMGA := [ 1, 2, 2, 3, 4, 4, 5, 5, 6, 7, 7, 8, 9, 10, 8, 10, 9 ] ) ]
\endexample

Such a table automatically satisfies the orthogonality relations,
% For two rows in the factor group $G.A$, this follows form the first
% orthogonality relation for $G.A$; for two rows not from $G.A$,
% this follows from the first orthogonality relation in $M.G$;
% and for one row from $G.A$ and the other not from $G.A$,
% it follows from the first orthogonality relation for $G$.
and the tensor product of two ``irreducible characters'' of which at least
one is a row from $G.A$ decomposes into a sum of the
``irreducible characters'',
where the coefficients are nonnegative integers.
% For two rows in the factor group $G.A$, this follows form this property
% for $G.A$;
% and for one row from $G.A$ and the other not from $G.A$,
% it follows from this property for $M.G$.

In this example, any tensor product decomposes with nonnegative integral
coefficients,
$n$-th symmetrizations of ``irreducible characters'' decompose,
for $n \leq 5$,
and the ``class multiplication coefficients'' are nonnegative integers.

\beginexample
gap> pseudo:= poss[1].table;
CharacterTable( "pseudo" )
gap> Display( pseudo );
pseudo

      2  4   3  4  3  .  3   2  .   .   .  2  3  3
      3  3   3  1  1  2  1   1  1   1   1  .  .  .
      5  1   1  .  .  .  .   .  1   1   1  .  .  .

        1a  3a 2a 6a 3b 4a 12a 5a 15a 15b 4b 8a 8b
     2P 1a  3a 1a 3a 3b 2a  6a 5a 15a 15b 2a 4a 4a
     3P 1a  1a 2a 2a 1a 4a  4a 5a  5a  5a 4b 8a 8b
     5P 1a  3a 2a 6a 3b 4a 12a 1a  3a  3a 4b 8b 8a

X.1      1   1  1  1  1  1   1  1   1   1  1  1  1
X.2      1   1  1  1  1  1   1  1   1   1 -1 -1 -1
X.3     10  10  2  2  1 -2  -2  .   .   .  .  .  .
X.4     16  16  .  . -2  .   .  1   1   1  .  .  .
X.5      9   9  1  1  .  1   1 -1  -1  -1  1 -1 -1
X.6      9   9  1  1  .  1   1 -1  -1  -1 -1  1  1
X.7     10  10 -2 -2  1  .   .  .   .   .  .  B -B
X.8     10  10 -2 -2  1  .   .  .   .   .  . -B  B
X.9      6  -3 -2  1  .  2  -1  1   A  /A  .  .  .
X.10     6  -3 -2  1  .  2  -1  1  /A   A  .  .  .
X.11    12  -6  4 -2  .  .   .  2  -1  -1  .  .  .
X.12    18  -9  2 -1  .  2  -1 -2   1   1  .  .  .
X.13    30 -15 -2  1  . -2   1  .   .   .  .  .  .

A = -E(15)-E(15)^2-E(15)^4-E(15)^8
  = (-1-ER(-15))/2 = -1-b15
B = E(8)+E(8)^3
  = ER(-2) = i2
gap> IsInternallyConsistent( pseudo );
true
gap> irr:= Irr( pseudo );;
gap> test:= Concatenation( List( [ 2 .. 5 ],
>               n -> Symmetrizations( pseudo, irr, n ) ) );;
gap> Append( test, Set( Tensored( irr, irr ) ) );
gap> fail in Decomposition( irr, test, "nonnegative" );
false
gap> if ForAny( Tuples( [ 1 .. NrConjugacyClasses( pseudo ) ], 3 ),        
>      t -> not ClassMultiplicationCoefficient( pseudo, t[1], t[2], t[3] )   
>               in NonnegativeIntegers ) then                           
>      Error( "contradiction" );
> fi;
\endexample

I do not know a character-theoretic argument for showing that this table is
\emph{not} the character table of a group,
but we can use the following group-theoretic argument.
Suppose that the group $G$, say, has the above character table.
Then $G$ has a unique composition series with factors of the orders
$3$, $360$, and $2$, respectively.
Let $N$ denote the normal subgroup of order $3$ in $G$.
The factor group $F = G/N$ is an automorphic extension of $A_6$,
and according to~\cite[p.~4]{CCN85} it is isomorphic with $M_{10} = A_6.2_3$
and has Sylow $3$ normalizers of the structure $3^2 : Q_8$.
Since the Sylow $3$ subgroup of $G$ is a self-centralizing nonabelian group
of order $3^3$ and of exponent $3$,
the Sylow $3$ normalizers in $G$ have the structure $3^{1+2}_+ : Q_8$,
but the $Q_8$ type subgroups of $\Aut( 3^{1+2}_+ )$ act trivially on the
centre of $3^{1+2}_+$, contrary to the situation in the above table.

In general, this construction need not produce tables for which all
symmetrizations of irreducible characters decompose properly.
For example, applying `PossibleCharacterTablesOfTypeMGA' to the case
$M.G = 3.L_3(4)$ and $G.A = L_3(4).2_1$ does not yield a table because
the function suppresses tables that do not admit $p$-th power maps,
for prime divisors $p$ of the order of $M.G.A$,
and in this case no compatible second power map exists.

\beginexample
gap> tblMG := CharacterTable( "3.L3(4)" );;
gap> tblG  := CharacterTable( "L3(4)" );;
gap> tblGA := CharacterTable( "L3(4).2_1" );;
gap> elms:= PossibleActionsForTypeMGA( tblMG, tblG, tblGA );
[ [ [ 1 ], [ 2, 3 ], [ 4 ], [ 5, 6 ], [ 7 ], [ 8 ], [ 9, 10 ], [ 11 ], 
      [ 12, 13 ], [ 14 ], [ 15, 16 ], [ 17, 20 ], [ 18, 22 ], [ 19, 21 ], 
      [ 23, 26 ], [ 24, 28 ], [ 25, 27 ] ] ]
gap> PossibleCharacterTablesOfTypeMGA( tblMG, tblG, tblGA, elms[1], "?" );
[  ]
\endexample

Also, it may happen that already `PossibleActionsForTypeMGA' returns
an empty list.
Examples are $M.G = 3_1.U_4(3)$, $G.A = U_4(3).2_2$ and
$M.G = 3_2.U_4(3)$, $G.A = U_4(3).2_3$.

\beginexample
gap> tblG  := CharacterTable( "U4(3)" );;
gap> tblMG := CharacterTable( "3_1.U4(3)" );;
gap> tblGA := CharacterTable( "U4(3).2_2" );;
gap> PossibleActionsForTypeMGA( tblMG, tblG, tblGA );
[  ]
gap> tblMG:= CharacterTable( "3_2.U4(3)" );;
gap> tblGA:= CharacterTable( "U4(3).2_3" );;
gap> PossibleActionsForTypeMGA( tblMG, tblG, tblGA );
[  ]
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%\subsection{The Character Tables of Maximal Subgroups of $12.M_{22}.2$}
%
%Idea:
%
%Regard 12.M22.2 as M.G.A with M of order 6, G = 2.M22.
%Yes, there is an ambiguity due to isoclinism (see Section ...),
%but we assume that the table of 12.M22.2 is known.
%
%Now construct the tables of the maxes of 12.M22.2,
%which also have the structure 6.U.2 where U is a maximal subgroup of 2.M22.
%So we need the tables of all maxes of 2.M22.2 and of 12.M22,
%decide the isoclinism via the known table of 12.M22.2.
%
%This way we get at the same time the tables of the maxes of 3.M22.2
%(not suprising, for that we would have needed only the maxes of M22.2 ...),
%of 4.M22.2, and of 6.M22.2.
%
%First step:
%
%Compute the tables of the maxes of 2.M22.2.
%
%1. $2.M_{22}$ clear
%
%2. $2.L_3(4).2_2$ easy
%
%for the others, use atlasrep, perm. rep. of $2.M_{22}.2$,
%and scripts for maxes of $M_{22}.2$
%
%(Here is one example where the script yields a group that does not contain
%the centre, so we have to form the closure.)
%
%3. preimage of $2^4:S_6$ is already in the library, name is {\tt 2\^5:S6},
%   a subgroup of $S_6(2)$; add just the fusion ...
%
%4. this is the only case where we seem to be forced to add a new full table;
%   the structure is $2^5.(2 \times S_5)$
%
%5. $2 \times 2^3:L_3(2) \times 2$
%
%6. preimage of $A_6.2^2$ is $(2 \times A_6).2^2$, an isoclinic table of
%   {\tt A6.D8}, a subgroup of $2.M_{12}$.
%
%7. $2 \times L_2(11):2$ (clear from looking at lifting of involutions of
%   $M_{22}.2$?)
%
%
%\beginexample
%gap> tblMG:= CharacterTable( "12.M22" );;
%gap> tblG:= CharacterTable( "6.M22" );;
%gap> tblGA:= CharacterTable( "6.M22.2" );;
%gap> SetInfoLevel( InfoCharacterTable, 1 );
%gap> elms:= PossibleActionsForTypeMGA( tblMG, tblG, tblGA );
%#I  31 automorphism(s) of order 2
%#I  16 automorphism(s) mapping 2 compatibly
%#I  8 automorphism(s) mapping 36 compatibly
%#I  4 automorphism(s) mapping 48 compatibly
%#I  2 automorphism(s) mapping 54 compatibly
%#I  2 automorphism(s) acting semiregularly
%[ (2,12)(3,11)(4,10)(5,9)(6,8)(14,18)(15,17)(20,22)(24,28)(25,27)(30,31)(33,
%    43)(34,42)(35,41)(36,40)(37,39)(45,49)(46,48)(51,61)(52,60)(53,59)(54,
%    58)(55,57)(63,73)(64,72)(65,71)(66,70)(67,69)(74,77)(75,76)(78,85)(79,
%    84)(80,83)(81,82)(86,98)(87,109)(88,108)(89,107)(90,106)(91,105)(92,
%    104)(93,103)(94,102)(95,101)(96,100)(97,99), 
%  (2,12)(3,11)(4,10)(5,9)(6,8)(14,18)(15,17)(20,22)(24,28)(25,27)(30,31)(33,
%    43)(34,42)(35,41)(36,40)(37,39)(45,49)(46,48)(51,61)(52,60)(53,59)(54,
%    58)(55,57)(63,73)(64,72)(65,71)(66,70)(67,69)(74,83)(75,82)(76,81)(77,
%    80)(78,79)(84,85)(86,98)(87,109)(88,108)(89,107)(90,106)(91,105)(92,
%    104)(93,103)(94,102)(95,101)(96,100)(97,99) ]
%gap> elms[1]/elms[2];
%(74,80)(75,81)(76,82)(77,83)(78,84)(79,85)
%
%Aha!
%not unique!!
%(really different result tables?)
%(the first does not admit a 2nd power map,
%the second currently admits two different ones,
%for different element orders -- something such as isoclinism??)
%
%and if we try the step by a 3?
%
%gap> tblMG:= CharacterTable( "12.M22" );;
%gap> tblG:= CharacterTable( "4.M22" );;
%gap> tblGA:= CharacterTable( "4.M22.2" );;
%gap> elms:= PossibleActionsForTypeMGA( tblMG, tblG, tblGA );
%[ (2,12)(3,11)(4,10)(5,9)(6,8)(14,18)(15,17)(20,22)(24,28)(25,27)(30,31)(33,
%    43)(34,42)(35,41)(36,40)(37,39)(45,49)(46,48)(51,61)(52,60)(53,59)(54,
%    58)(55,57)(63,73)(64,72)(65,71)(66,70)(67,69)(74,83)(75,82)(76,81)(77,
%    80)(78,79)(84,85)(86,98)(87,109)(88,108)(89,107)(90,106)(91,105)(92,
%    104)(93,103)(94,102)(95,101)(96,100)(97,99) ]
%\endexample
%
%and now the tables of the maxes!!
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%\subsection{TODO: More $M.G.A$ Examples ...}
%
%Mention the question of computing fusions in the examples!
%
%Add an example that a wrong fusion choice leads to corrupt tables.
%
%Example ThM5: $(3 \times G_2(3)).2$ (cf. ~/construct/ThM5)
%
%Refer to ctblsuz.xpl for some table constructions
%
%Mention possible problems in the bicyclic case:
%$3_2.U_4(3) \rightarrow 3_2.U_4(3).2_3'$ is ambiguous,
%but the MGA situation determines the fusion.
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Some Extra-ordinary $p$-Modular Tables of the Type $M.G.A$
(September 2005)}

For a group $M.G.A$ in the sense of Section~\ref{theorMGA}
such that *not* all ordinary irreducible characters $\chi$ have the property
that $M$ is contained in the kernel of $\chi$ or $\chi$ is induced from
$M.G$,
it may happen that there are primes $p$ such that all irreducible $p$-modular
characters have this property.
This happens if and only if the preimages in $M.G.A$ of each $p$-regular
conjugacy class in $G.A \setminus G$ form one conjugacy class.
This occurs in the following cases.

% how to find the interesting cases -- ordinary tables suffice!
% (If this is added here then remove it from tutorial!)
% 
% find:= function( name )
%     local result, tblMGA, der, nsg, tblMGAclasses, orders, tblMG,
%           tblMGfustblMGA, tblMGclasses, pos, M, Mimg, tblGA, tblMGAfustblGA,
%           outer, inv, filt, other, primes, p;
% 
%     result:= [];
%     tblMGA:= CharacterTable( name );
%     der:= ClassPositionsOfDerivedSubgroup( tblMGA );
%     nsg:= ClassPositionsOfNormalSubgroups( tblMGA );
%     tblMGAclasses:= SizesConjugacyClasses( tblMGA );
%     orders:= OrdersClassRepresentatives( tblMGA );
%     if Length( der ) < NrConjugacyClasses( tblMGA ) then
%       # Look for tables of normal subgroups of the form $M.G$.
%       for tblMG in Filtered( List( NamesOfFusionSources( tblMGA ),
%                                    CharacterTable ), x -> x <> fail ) do
%         tblMGfustblMGA:= GetFusionMap( tblMG, tblMGA );
%         tblMGclasses:= SizesConjugacyClasses( tblMG );
%         pos:= Position( nsg, Set( tblMGfustblMGA ) );
%         if pos <> fail and
%            Size( tblMG ) = Sum( tblMGAclasses{ nsg[ pos ] } ) then
%           # Look for normal subgroups of the form $M$.
%           for M in Difference( ClassPositionsOfNormalSubgroups( tblMG ),
%                        [ [ 1 ], [ 1 .. NrConjugacyClasses( tblMG ) ] ] ) do
%             Mimg:= Set( tblMGfustblMGA{ M } );
%             if Sum( tblMGAclasses{ Mimg } ) = Sum( tblMGclasses{ M } ) then
%               tblGA:= tblMGA / Mimg;
%               tblMGAfustblGA:= GetFusionMap( tblMGA, tblGA );
%               outer:= Difference( [ 1 .. NrConjugacyClasses( tblGA ) ],
%                           CompositionMaps( tblMGAfustblGA, tblMGfustblMGA ) );
%               inv:= InverseMap( tblMGAfustblGA ){ outer };
%               filt:= Flat( Filtered( inv, IsList ) );
%               if filt <> [] then
%                 other:= Filtered( inv, IsInt );
%                 primes:= Filtered( Set( Factors( Size( tblMGA ) ) ),
%                    p -> ForAll( orders{ filt }, x -> x mod p = 0 )
%                         and ForAny( orders{ other }, x -> x mod p <> 0 ) );
%                 for p in primes do
%                   Add( result, [ tblMG, tblMGA, M, p ] );
%                 od;
%               fi;
%             fi;
%           od;
%         fi;
%       od;
%     fi;
%     return result;
% end;
% 
% gap> cases:= [];;
% gap> for name in AllCharacterTableNames() do
% >      Append( cases, find( name ) );
% >    od;
% 
% finds
% 
% gap> cases;
% [ [ CharacterTable( "2.A6" ), CharacterTable( "2.A6.2_1" ), [ 1, 2 ], 3 ], 
%   [ CharacterTable( "6.A6" ), CharacterTable( "6.A6.2_1" ), [ 1 .. 6 ], 3 ], 
%   [ CharacterTable( "6.A6" ), CharacterTable( "6.A6.2_1" ), [ 1, 4 ], 3 ], 
%   [ CharacterTable( "2.Fi22" ), CharacterTable( "2.Fi22.2" ), [ 1, 2 ], 3 ], 
%   [ CharacterTable( "6.Fi22" ), CharacterTable( "6.Fi22.2" ), [ 1 .. 6 ], 3 ],
%   [ CharacterTable( "6.Fi22" ), CharacterTable( "6.Fi22.2" ), [ 1, 4 ], 3 ], 
%   [ CharacterTable( "2.L2(25)" ), CharacterTable( "2.L2(25).2_2" ), [ 1, 2 ], 
%       5 ], [ CharacterTable( "2.L2(49)" ), CharacterTable( "2.L2(49).2_2" ), 
%       [ 1, 2 ], 7 ], 
%   [ CharacterTable( "2.L2(81)" ), CharacterTable( "2.L2(81).2_1" ), [ 1, 2 ], 
%       3 ], [ CharacterTable( "2.L2(81)" ), CharacterTable( "2.L2(81).4_1" ), 
%       [ 1, 2 ], 3 ], 
%   [ CharacterTable( "2.L2(81).2_1" ), CharacterTable( "2.L2(81).4_1" ), 
%       [ 1, 2 ], 3 ], 
%   [ CharacterTable( "2.L4(3)" ), CharacterTable( "2.L4(3).2_2" ), [ 1, 2 ], 3 
%      ], [ CharacterTable( "2.L4(3)" ), CharacterTable( "2.L4(3).2_3" ), 
%       [ 1, 2 ], 3 ], 
%   [ CharacterTable( "4^2:D12" ), CharacterTable( "4^2:D12.2" ), [ 1, 2, 6 ], 
%       3 ], 
%   [ CharacterTable( "2.U4(3).2_1" ), CharacterTable( "2.U4(3).(2^2)_{122}" ), 
%       [ 1, 2 ], 3 ], 
%   [ CharacterTable( "2.U4(3).2_1" ), CharacterTable( "2.U4(3).(2^2)_{133}" ), 
%       [ 1, 2 ], 3 ], 
%   [ CharacterTable( "2.U4(3).4" ), CharacterTable( "2.U4(3).D8" ), [ 1, 2 ], 
%       3 ], [ CharacterTable( "3.U3(8)" ), CharacterTable( "3.U3(8).3_1" ), 
%       [ 1 .. 3 ], 2 ], 
%   [ CharacterTable( "3.U3(8)" ), CharacterTable( "3.U3(8).6" ), [ 1 .. 3 ], 2 
%      ], 
%   [ CharacterTable( "3.U3(8)" ), CharacterTable( "3.U3(8).6" ), [ 1 .. 3 ], 3 
%      ], [ CharacterTable( "3.U3(8).2" ), CharacterTable( "3.U3(8).6" ), 
%       [ 1, 2 ], 2 ] ]

\beginexample
gap> list:= [                    
> [ "2.A6",     "A6.2_1",     "2.A6.2_1",     3 ],  
> [ "2.L2(25)", "L2(25).2_2", "2.L2(25).2_2", 5 ],
> [ "2.L2(49)", "L2(49).2_2", "2.L2(49).2_2", 7 ],
> [ "2.L2(81)", "L2(81).2_1", "2.L2(81).2_1", 3 ],
> [ "2.L2(81)", "L2(81).4_1", "2.L2(81).4_1", 3 ],
> [ "2.L4(3)",  "L4(3).2_2",  "2.L4(3).2_2",  3 ],  
> [ "2.L4(3)",  "L4(3).2_3",  "2.L4(3).2_3",  3 ],
> [ "2.Fi22",   "Fi22.2",     "2.Fi22.2",     3 ],    
> ];;
\endexample

The smallest example in this list is $2.A_6.2_1$.
The $3$-modular table of this group looks as follows.

\beginexample
gap> Display( CharacterTable( "2.A6.2_1" ) mod 3 );
2.A6.2_1mod3

     2  5   5  4  3  1   1  4  4  3
     3  2   2  .  .  .   .  1  1  .
     5  1   1  .  .  1   1  .  .  .

       1a  2a 4a 8a 5a 10a 2b 4b 8b
    2P 1a  1a 2a 4a 5a  5a 1a 2a 4a
    3P 1a  2a 4a 8a 5a 10a 2b 4b 8b
    5P 1a  2a 4a 8a 1a  2a 2b 4b 8b

X.1     1   1  1  1  1   1  1  1  1
X.2     1   1  1  1  1   1 -1 -1 -1
X.3     6   6 -2  2  1   1  .  .  .
X.4     4   4  . -2 -1  -1  2 -2  .
X.5     4   4  . -2 -1  -1 -2  2  .
X.6     9   9  1  1 -1  -1  3  3 -1
X.7     9   9  1  1 -1  -1 -3 -3  1
X.8     4  -4  .  . -1   1  .  .  .
X.9    12 -12  .  .  2  -2  .  .  .
\endexample

We see that the two faithful irreducible characters vanish on the three
classes outside $2.A_6$.

For the groups in the above list, the construction of the $p$-modular tables
of $M.G.A$ from the tables of $M.G$ and $G.A$, for the special primes $p$,
can be performed as follows.

\beginexample
gap> for input in list do
>      p:= input[4];
>      modtblMG:=  CharacterTable( input[1] ) mod p;
>      modtblGA:=  CharacterTable( input[2] ) mod p;
>      ordtblMGA:= CharacterTable( input[3] );
>      name:= Concatenation( Identifier( ordtblMGA ), "mod", String(p) );
>      if ForAll( [ modtblMG, modtblGA ], IsCharacterTable ) then
>        poss:= BrauerTableOfTypeMGA( modtblMG, modtblGA, ordtblMGA );
>        modlib:= ordtblMGA mod p;
>        if IsCharacterTable( modlib ) then
>          trans:= TransformingPermutationsCharacterTables( poss.table,
>                      modlib );
>          if not IsRecord( trans ) then
>            Print( "#E  computed table and library table for ", name,
>                   " differ\n" );
>          fi;
>        else
>          Print( "#I  no library table for ", name, "\n" );
>        fi;
>      else
>        Print( "#I  not all input tables for ", name, " available\n" );
>      fi;
>    od;
#I  not all input tables for 2.L2(49).2_2mod7 mod 7 available
#I  not all input tables for 2.L2(81).2_1mod3 mod 3 available
#I  not all input tables for 2.L2(81).4_1mod3 mod 3 available
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Examples for the Type $G.S_3$}\label{GS3}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Small Examples}

The symmetric group $S_4$ on four points has the form $G.S_3$
where $G$ is the Klein four group $V_4$,
$G.2$ is the dihedral group $D_8$ of order $8$,
and $G.3$ is the alternating group $A_4$.
The trivial character of $A_4$ extends twofold to $S_4$, in the same way
as the trivial character of $V_4$ extends to the dihedral group.
The nontrivial linear characters of $A_4$ induce irreducibly to $S_4$.
The irreducible degree three character of $A_4$ is induced from any of the
three nontrivial linear characters of $V_4$,
it extends to $S_4$ in the same way as the unique constituent of the
restriction to $V_4$ that is invariant in the chosen $D_8$ extends to $D_8$.

\beginexample
gap> c2:= CharacterTable( "Cyclic", 2 );;
gap> t:= c2 * c2;;
gap> tC:= CharacterTable( "Dihedral", 8 );;
gap> tK:= CharacterTable( "Alternating", 4 );;
gap> tfustC:= PossibleClassFusions( t, tC );
[ [ 1, 3, 4, 4 ], [ 1, 3, 5, 5 ], [ 1, 4, 3, 4 ], [ 1, 4, 4, 3 ], 
  [ 1, 5, 3, 5 ], [ 1, 5, 5, 3 ] ]
gap> StoreFusion( t, tfustC[1], tC );
gap> tfustK:= PossibleClassFusions( t, tK );
[ [ 1, 2, 2, 2 ] ]
gap> StoreFusion( t, tfustK[1], tK );
gap> elms:= PossibleActionsForTypeGS3( t, tC, tK );
[ (3,4) ]
gap> new:= CharacterTableOfTypeGS3( t, tC, tK, elms[1], "S4" );
rec( table := CharacterTable( "S4" ), tblCfustblKC := [ 1, 4, 2, 2, 5 ], 
  tblKfustblKC := [ 1, 2, 3, 3 ] )
gap> Display( new.table );
S4

     2  3  3  .  2  2
     3  1  .  1  .  .

       1a 2a 3a 4a 2b
    2P 1a 1a 3a 2a 1a
    3P 1a 2a 1a 4a 2b

X.1     1  1  1  1  1
X.2     1  1  1 -1 -1
X.3     3 -1  .  1 -1
X.4     3 -1  . -1  1
X.5     2  2 -1  .  .
\endexample

The case $e > 1$ occurs in the following example.
We choose $G$ the cyclic group of order two,
$G.C$ the cyclic group of order six,
$G.K$ the quaternion group of order eight,
and construct the character table of $G.F = SL_2(3)$,
with $F \cong A_4$.

We get three extensions of the trivial character of $G.K$ to $G.F$,
a degree three character induced from the nontrivial linear characters
of $G.K$,
and three extensions of the irreducible degree $2$ character of $G.K$.

\beginexample
gap> t:= CharacterTable( "Cyclic", 2 );;
gap> tC:= CharacterTable( "Cyclic", 6 );;
gap> tK:= CharacterTable( "Quaternionic", 8 );;
gap> tfustC:= PossibleClassFusions( t, tC );
[ [ 1, 4 ] ]
gap> StoreFusion( t, tfustC[1], tC );
gap> tfustK:= PossibleClassFusions( t, tK );
[ [ 1, 3 ] ]
gap> StoreFusion( t, tfustK[1], tK );
gap> elms:= PossibleActionsForTypeGS3( t, tC, tK );
[ (2,5,4) ]
gap> new:= CharacterTableOfTypeGS3( t, tC, tK, elms[1], "SL(2,3)" );
rec( table := CharacterTable( "SL(2,3)" ), 
  tblCfustblKC := [ 1, 4, 5, 3, 6, 7 ], tblKfustblKC := [ 1, 2, 3, 2, 2 ] )
gap> Display( new.table );
SL(2,3)

     2  3  2  3  1   1   1  1
     3  1  .  1  1   1   1  1

       1a 4a 2a 6a  3a  3b 6b
    2P 1a 2a 1a 3a  3b  3a 3b
    3P 1a 4a 2a 2a  1a  1a 2a

X.1     1  1  1  1   1   1  1
X.2     1  1  1  A  /A   A /A
X.3     1  1  1 /A   A  /A  A
X.4     3 -1  3  .   .   .  .
X.5     2  . -2 /A  -A -/A  A
X.6     2  . -2  1  -1  -1  1
X.7     2  . -2  A -/A  -A /A

A = E(3)
  = (-1+ER(-3))/2 = b3
\endexample

% small Brauer table?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{{\ATLAS} Tables of the Type $G.S_3$}\label{xplGS3}

We demonstrate the construction of all those ordinary and modular character
tables in the {\GAP} Character Table Library that are of the type $G.S_3$
where $G$ is a simple group or a central extension of a simple group whose
character table is contained in the {\ATLAS}.
Here is the list of `Identifier' values needed for accessing the input
tables and the known library tables corresponding to the output.

\beginexample
gap> listGS3:= [
> [ "U3(5)",      "U3(5).2",      "U3(5).3",      "U3(5).S3"        ],
> [ "3.U3(5)",    "3.U3(5).2",    "3.U3(5).3",    "3.U3(5).S3"      ],
> [ "L3(4)",      "L3(4).2_2",    "L3(4).3",      "L3(4).3.2_2"     ],
> [ "L3(4)",      "L3(4).2_3",    "L3(4).3",      "L3(4).3.2_3"     ],
> [ "3.L3(4)",    "3.L3(4).2_2",  "3.L3(4).3",    "3.L3(4).3.2_2"   ],
> [ "2^2.L3(4)",  "2^2.L3(4).2_2","2^2.L3(4).3",  "2^2.L3(4).3.2_2" ],
> [ "2^2.L3(4)",  "2^2.L3(4).2_3","2^2.L3(4).3",  "2^2.L3(4).3.2_3" ],
> [ "U6(2)",      "U6(2).2",      "U6(2).3",      "U6(2).S3"        ],
> [ "3.U6(2)",    "3.U6(2).2",    "3.U6(2).3",    "3.U6(2).3.2"     ],
> [ "2^2.U6(2)",  "2^2.U6(2).2",  "2^2.U6(2).3",  "2^2.U6(2).3.2"   ],
> [ "O8+(2)",     "O8+(2).2",     "O8+(2).3",     "O8+(2).3.2"      ],
> [ "2^2.O8+(2)", "2^2.O8+(2).2", "2^2.O8+(2).3", "2^2.O8+(2).3.2"  ],
> [ "L3(7)",      "L3(7).2",      "L3(7).3",      "L3(7).S3"        ],
> [ "3.L3(7)",    "3.L3(7).2",    "3.L3(7).3",    "3.L3(7).S3"      ],
> [ "U3(8)",      "U3(8).2",      "U3(8).3_2",    "U3(8).S3"        ],
> [ "3.U3(8)",    "3.U3(8).2",    "3.U3(8).3_2",  "3.U3(8).S3"      ],
> [ "U3(11)",     "U3(11).2",     "U3(11).3",     "U3(11).S3"       ],
> [ "3.U3(11)",   "3.U3(11).2",   "3.U3(11).3",   "3.U3(11).S3"     ],
> [ "O8+(3)",     "O8+(3).2_2",   "O8+(3).3",     "O8+(3).S3"       ],
> [ "2E6(2)",     "2E6(2).2",     "2E6(2).3",     "2E6(2).S3"       ],
> [ "2^2.2E6(2)", "2^2.2E6(2).2", "2^2.2E6(2).3", "2^2.2E6(2).S3"   ],
> ];;
\endexample

(For $G$ one of $L_3(4)$, $U_6(2)$, $O_8^+(2)$, and ${}^2E_6(2)$,
the tables of $2^2.G$, $2^2.G.2$, and $2^2.G.3$ can be constructed
with the methods described in Section~\ref{theorV4G}
and Section~\ref{theorMGA}, respectively.)

Analogously, the automorphism groups of $L_3(4)$ and $O_8^+(3)$
have factor groups isomorphic with $S_3$;
in these cases, we choose $G = L_3(4).2_1$ and $G = O_8^+(3).2^2_{111}$,
respectively.

\beginexample
gap> Append( listGS3, [
> [ "L3(4).2_1",          "L3(4).2^2",     "L3(4).6",     "L3(4).D12"     ],
> [ "2^2.L3(4).2_1",      "2^2.L3(4).2^2", "2^2.L3(4).6", "2^2.L3(4).D12" ],
> [ "O8+(3).(2^2)_{111}", "O8+(3).D8",     "O8+(3).A4",   "O8+(3).S4"     ],
> ] );
\endexample

In all these cases, the required table automorphism of $G.3$ is uniquely
determined.
We first compute the ordinary character table of $G.S_3$ and then
the $p$-modular tables,
for all prime divisors $p$ of the order of $G$ such that
the {\GAP} Character Table Library contains the necessary $p$-modular
input tables.

In each case, we compare the computed character tables with the ones in
the {\GAP} Character Table Library.
Note that in order to avoid conflicts of the class fusions that arise in
the construction with the class fusions that are already stored on the
library tables, we choose identifiers for the result tables that are
different from the identifiers of the library tables.

\beginexample
gap> ProcessGS3Example:= function( t, tC, tK, identifier, pi )
>    local tF, lib, trans, p, tmodp, tCmodp, tKmodp, modtF;
> 
>    tF:= CharacterTableOfTypeGS3( t, tC, tK, pi,
>             Concatenation( identifier, "new" ) );
>    lib:= CharacterTable( identifier );
>    if lib <> fail then
>      trans:= TransformingPermutationsCharacterTables( tF.table, lib );
>      if not IsRecord( trans ) then
>        Print( "#E  computed table and library table for `", identifier,
>               "' differ\n" );
>      fi;
>    else
>      Print( "#I  no library table for ", identifier, "\n" );
>    fi;
>    StoreFusion( tC, tF.tblCfustblKC, tF.table );
>    StoreFusion( tK, tF.tblKfustblKC, tF.table );
>    for p in Set( Factors( Size( t ) ) ) do
>      tmodp := t  mod p;
>      tCmodp:= tC mod p;
>      tKmodp:= tK mod p;
>      if IsCharacterTable( tmodp ) and
>         IsCharacterTable( tCmodp ) and
>         IsCharacterTable( tKmodp ) then
>        modtF:= CharacterTableOfTypeGS3( tmodp, tCmodp, tKmodp,
>                    tF.table,
>                    Concatenation(  identifier, "mod", String( p ) ) );
>        if lib <> fail and IsCharacterTable( lib mod p ) then
>          trans:= TransformingPermutationsCharacterTables( modtF.table,
>                                                           lib mod p );
>          if not IsRecord( trans ) then
>            Print( "#E  computed table and library table for `",
>                   identifier, " mod ", p, "' differ\n" );
>          fi;
>        else
>          Print( "#I  no library table for `", identifier, " mod ",
>                 p, "'\n" );
>        fi;
>      else
>        Print( "#I  not all inputs available for `", identifier,
>               " mod ", p, "'\n" );
>      fi;
>    od;
> end;;
\endexample

Now we call the function for the examples in the list.

\beginexample
gap> for input in listGS3 do
>      t := CharacterTable( input[1] );
>      tC:= CharacterTable( input[2] );
>      tK:= CharacterTable( input[3] );
>      identifier:= input[4];
>      elms:= PossibleActionsForTypeGS3( t, tC, tK );
>      if Length( elms ) = 1 then
>        ProcessGS3Example( t, tC, tK, identifier, elms[1] );
>      else
>        Print( "#I  action not unique for `", identifier, "'\n" );
>      fi;
>    od;
\endexample

%T is the following true:
%T The tables of $2^2.O8+(2)$ mod 3, 5, 7 are not yet available.
%T The table  of $O_8^+(3)$ mod 3 is not yet available.
%T The tables of ${}^2E_6(2)$ mod 2, 3, 5, 7 and of
%T               ${}^2E_6(2).3$ mod 11, 13, 17, 19 are not yet available
%T The tables of $2^2.{}^2E_6(2)$ mod 2, 3, 5, 7, 11, 13, 17, 19 are not yet
%T available.
%T The tables of $2^2.L_3(4)$ mod 3, 5, 7 are not yet available.
%T The tables of $2^2.U_6(2)$ mod 3, 5, 7, 11 are not yet available.

Also the ordinary character table of the automorphic extension
of the simple {\ATLAS} group $O_8^+(3)$ by $A_4$ can be constructed
with the same approach.
Here we get four possible permutations, which lead to essentially the
same character table.

\beginexample
gap> input:= [ "O8+(3)", "O8+(3).3", "O8+(3).(2^2)_{111}", "O8+(3).A4" ];;
gap> t := CharacterTable( input[1] );;
gap> tC:= CharacterTable( input[2] );;
gap> tK:= CharacterTable( input[3] );;
gap> identifier:= input[4];;
gap> elms:= PossibleActionsForTypeGS3( t, tC, tK );;
gap> Length( elms );
4
gap> differ:= MovedPoints( Group( List( elms, x -> x / elms[1] ) ) );;
gap> List( elms, x -> RestrictedPerm( x, differ ) );
[ (118,216,169)(119,217,170)(120,218,167)(121,219,168), 
  (118,216,170)(119,217,169)(120,219,168)(121,218,167), 
  (118,217,169)(119,216,170)(120,218,168)(121,219,167), 
  (118,217,170)(119,216,169)(120,219,167)(121,218,168) ]
gap> poss:= List( elms, pi -> CharacterTableOfTypeGS3( t, tC, tK, pi,
>             Concatenation( identifier, "new" ) ) );;
gap> lib:= CharacterTable( identifier );;
gap> ForAll( poss, r -> IsRecord(
>        TransformingPermutationsCharacterTables( r.table, lib ) ) );
true
\endexample

Also the construction of the $p$-modular tables of $O_8^+(3).A_4$ works.

\beginexample
gap> ProcessGS3Example( t, tC, tK, identifier, elms[1] );
\endexample

% add also
% [ "U3(8).3_1",   "U3(8).6",   "U3(8).(3^2)_{1233}",     "U3(8).(3xS3)" ],
% as soon as all compound tables are available


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Examples for the Type $G.2^2$}\label{xplGV4}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Character Table of $A_6.2^2$}

As the first example,
we consider the automorphism group $\Aut( A_6 ) \cong A_6.2^2$ of the
alternating group $A_6$ on six points.

In this case, the triple of actions on the subgroups $A_6.2_i$ is uniquely
determined by the condition on the number of conjugacy classes
in Section~\ref{theorGV4}.

\beginexample
gap> tblG:= CharacterTable( "A6" );;
gap> tblsG2:= List( [ "A6.2_1", "A6.2_2", "A6.2_3" ], CharacterTable );;
gap> List( tblsG2, NrConjugacyClasses );
[ 11, 11, 8 ]
gap> possact:= List( tblsG2, x -> Filtered( Elements( 
>        AutomorphismsOfTable( x ) ), y -> Order( y ) <= 2 ) );
[ [ (), (3,4)(7,8)(10,11) ], [ (), (8,9), (5,6)(10,11), (5,6)(8,9)(10,11) ], 
  [ (), (7,8) ] ]
\endexample

Note that $n_1 = n_2$ implies $f_1 = f_2$, and $n_1 - n_3 = 3$ implies
$f_1 - f_3 = 2$,
so we get $f_1 = 3$ and $f_3 = 1$,
and $A_6.2^2$ has $2 \cdot 11 - 3 \cdot 3 = 2 \cdot 8 - 3 \cdot 1 = 13$
classes.

(The compatibility on the classes inside $A_6$ yields only that the classes
$3$ and $4$ of $A_6.2_1 \cong S_6$ must be fused in $A_6.2^2$,
as well as the classes $5$ and $6$ of $A_6.2_2 \cong \PGL(2,9)$.)

\beginexample
gap> List( tblsG2, x -> GetFusionMap( tblG, x ) );
[ [ 1, 2, 3, 4, 5, 6, 6 ], [ 1, 2, 3, 3, 4, 5, 6 ], [ 1, 2, 3, 3, 4, 5, 5 ] ]
\endexample

These arguments are used by the {\GAP} function `PossibleActionsForTypeGV4',
which returns the list of all possible triples of permutations such that
the $i$-th permutation describes the action of $A_6.2^2$ on the classes of
$A_6.2_i$.

\beginexample
gap> acts:= PossibleActionsForTypeGV4( tblG, tblsG2 );    
[ [ (3,4)(7,8)(10,11), (5,6)(8,9)(10,11), (7,8) ] ]
\endexample

For the given actions, the {\GAP} function `PossibleCharacterTablesOfTypeGV4'
then computes the possibilities for the character table of $A_6.2^2$;
in this case, the result is unique.

\beginexample
gap> poss:= PossibleCharacterTablesOfTypeGV4( tblG, tblsG2, acts[1], "A6.2^2" );
[ rec( table := CharacterTable( "A6.2^2" ), 
      G2fusGV4 := [ [ 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 8 ], 
          [ 1, 2, 3, 4, 5, 5, 9, 10, 10, 11, 11 ], 
          [ 1, 2, 3, 4, 5, 12, 13, 13 ] ] ) ]
gap> IsRecord( TransformingPermutationsCharacterTables( poss[1].table,
>                  CharacterTable( "A6.2^2" ) ) );
true
\endexample

Finally, possible $p$-modular tables can be computed from the $p$-modular
input tables and the ordinary table of $A_6.2^2$;
here we show this for $p = 3$.

\beginexample
gap> PossibleCharacterTablesOfTypeGV4( tblG mod 3,
>        List( tblsG2, t -> t mod 3 ), poss[1].table );
[ rec( table := BrauerTable( "A6.2^2", 3 ), 
      G2fusGV4 := [ [ 1, 2, 3, 4, 5, 5, 6 ], [ 1, 2, 3, 4, 4, 7, 8, 8, 9, 9 ],
          [ 1, 2, 3, 4, 10, 11, 11 ] ] ) ]
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{{\ATLAS} Tables of the Type $G.2^2$ -- Easy Cases}%
\label{xplGV43.A6.V4}

We demonstrate the construction of all those ordinary and modular character
tables in the {\GAP} Character Table Library that are of the type $G.2^2$
where $G$ is a simple group or a central extension of a simple group whose
character table is contained in the {\ATLAS}.
Here is the list of `Identifier' values needed for accessing the input
tables and the result tables.

The construction of the character table of $O_8^+(3).2^2_{111}$ is more
involved and will be described in Section~\ref{O_8^+(3).2^2_{111}}.

\beginexample
gap> listGV4:= [
> [ "A6",      "A6.2_1",      "A6.2_2",      "A6.2_3",      "A6.2^2"      ],
> [ "3.A6",    "3.A6.2_1",    "3.A6.2_2",    "3.A6.2_3",    "3.A6.2^2"    ],
> [ "L2(25)",  "L2(25).2_1",  "L2(25).2_2",  "L2(25).2_3",  "L2(25).2^2"  ],
> [ "L3(4)",   "L3(4).2_1",   "L3(4).2_2",   "L3(4).2_3",   "L3(4).2^2"   ],
> [ "2^2.L3(4)", "2^2.L3(4).2_1", "2^2.L3(4).2_2", "2^2.L3(4).2_3",
>                                                         "2^2.L3(4).2^2" ],
> [ "L3(4).3", "L3(4).6",     "L3(4).3.2_2", "L3(4).3.2_3", "L3(4).D12"   ],
> [ "3.L3(4)", "3.L3(4).2_1", "3.L3(4).2_2", "3.L3(4).2_3", "3.L3(4).2^2" ],
> [ "U4(3)",   "U4(3).2_1",   "U4(3).2_2",   "U4(3).2_2'",
>                                                     "U4(3).(2^2)_{122}" ],
> [ "U4(3)",   "U4(3).2_1",   "U4(3).2_3",   "U4(3).2_3'",
>                                                     "U4(3).(2^2)_{133}" ],
> [ "3_2.U4(3)", "3_2.U4(3).2_1", "3_2.U4(3).2_3", "3_2.U4(3).2_3'",
>                                                 "3_2.U4(3).(2^2)_{133}" ],
> [ "L2(49)",  "L2(49).2_1",  "L2(49).2_2",  "L2(49).2_3",  "L2(49).2^2"  ],
> [ "L2(81)",  "L2(81).2_1",  "L2(81).2_2",  "L2(81).2_3",  "L2(81).2^2"  ],
> [ "L3(9)",   "L3(9).2_1",   "L3(9).2_2",   "L3(9).2_3",   "L3(9).2^2"   ],
> [ "O8+(3)",  "O8+(3).2_1",  "O8+(3).2_2",  "O8+(3).2_2'",
>                                                    "O8+(3).(2^2)_{122}" ],
> ];;
\endexample

%\hier!

%T add:
%T [ "2.U4(3)", "2.U4(3).2_1", "2.U4(3).2_2", "2.U4(3).2_2'",
%T                                                   "2.U4(3).(2^2)_{122}" ];
%T [ "2.U4(3)", "2.U4(3).2_1", "2.U4(3).2_3", "2.U4(3).2_3'",
%T                                                   "2.U4(3).(2^2)_{133}" ];
%T [ "2.U4(3).2_1", "2.U4(3).4", "2.U4(3).(2^2)_{122}", "2.U4(3).(2^2)_{133}",
%T                                                            "2.U4(3).D8" ],
%T -> two equiv. classes, distinguished by third power map,
%T    only one table admits one!
%T    Note: Recomputing the power maps is not sufficient,
%T    so add a test that decomposes ALL 3rd symmetrizations
%T    not just the minus characters!!

Analogously,
the automorphism groups $L_3(4).D_{12}$ of $L_3(4)$
and $U_4(3).D_8$ of $U_4(3)$,
and the subgroup $O_8^+(3).D_8$ of the automorphism group $O_8^+(3).S_4$
have factor groups that are isomorphic with $2^2$;
in these cases,
we choose $G = L_3(4).3$, $G = U_4(3).2_1$, and $G = O_8^+(3).2_1$,
respectively.
The automorphism group of $L_4(4)$ has the structure $L_4(4).2^2$;
its table is contained in the {\GAP} Character Table Library but not in the
{\ATLAS}.

\beginexample
gap> Append( listGV4, [
> [ "L3(4).3", "L3(4).6",     "L3(4).3.2_2", "L3(4).3.2_3", "L3(4).D12"   ],
> [ "U4(3).2_1", "U4(3).4", "U4(3).(2^2)_{122}", "U4(3).(2^2)_{133}",
>                                                              "U4(3).D8" ],
> [ "O8+(3).2_1", "O8+(3).(2^2)_{111}", "O8+(3).(2^2)_{122}", "O8+(3).4",
>                                                             "O8+(3).D8" ],
> [ "L4(4)",   "L4(4).2_1",   "L4(4).2_2",   "L4(4).2_3",   "L4(4).2^2"   ],
> ] );
\endexample

Now we proceed in two steps, the computation of the possible ordinary
character tables from the ordinary tables of the relevant subgroups,
and then the computation of the Brauer tables from the Brauer tables of the
relevant subgroups and from the ordinary table of the group.

The following function first computes the possible triples of actions on the
subgroups $G.2_i$, using the function `PossibleActionsForTypeGV4'.
Then the union of the candidate tables for these actions is computed,
and representatives of classes of permutation equivalent candidates are
inspected further with consistency checks.
Finally, if there is a unique solution, it is compared with the table that
is contained in the {\GAP} Character Table Library.

\beginexample
gap> ConstructOrdinaryGV4Table:= function( tblG, tblsG2, name, lib )
>      local acts, poss, i, cand, p, trans;
> 
>      # Compute the possible actions for the ordinary tables.
>      acts:= PossibleActionsForTypeGV4( tblG, tblsG2 );
>      # Compute the possible ordinary tables for the given actions.
>      poss:= Concatenation( List( acts, triple -> 
>          PossibleCharacterTablesOfTypeGV4( tblG, tblsG2, triple, name ) ) );
>      # Test the possibilities for permutation equivalence.
>      poss:= RepresentativesCharacterTables( poss );
>      if 1 < Length( poss ) then
>        Print( "#I  ", name, ": ", Length( poss ),
>               " equivalence classes\n" );
>      else
>        # Compare the computed table with the library table.
>        if not IsCharacterTable( lib ) then
>          Print( "#I  no library table for ", name, "\n" );
>        else
>          trans:= TransformingPermutationsCharacterTables( poss[1].table,
>                      lib );
>          if not IsRecord( trans ) then
>            Print( "#E  computed table and library table for ", name,
>                   " differ\n" );
>          fi;
>          # Compare the computed fusions with the stored ones.
>          if List( poss[1].G2fusGV4, x -> OnTuples( x, trans.columns ) )
>                 <> List( tblsG2, x -> GetFusionMap( x, lib ) ) then
>            Print( "#E  computed and stored fusions for ", name,
>                   " differ\n" );
>          fi;
>        fi;
>      fi;
>      return poss;
>    end;;
\endexample

The following function computes, for all prime divisors $p$ of the group
order in question, the possible $p$-modular Brauer tables.
If the solution is unique (up to permutation equivalence),
it is compared with the table that is contained in the
{\GAP} Character Table Library.

\beginexample
gap> ConstructModularGV4Tables:= function( tblG, tblsG2, ordtblGV4 )
>      local name, allposs, p, tmodp, t2modp, poss, modlib, trans;
> 
>      name:= Identifier( ordtblGV4 );
>      allposs:= [];
>      for p in Set( Factors( Size( tblG ) ) ) do
>        tmodp := tblG  mod p;
>        t2modp:= List( tblsG2, t2 -> t2 mod p );
>        if IsCharacterTable( tmodp ) and
>           ForAll( t2modp, IsCharacterTable ) then
>          poss:= PossibleCharacterTablesOfTypeGV4( tmodp, t2modp, ordtblGV4 );
>          poss:= RepresentativesCharacterTables( poss );
>          if Length( poss ) = 1 then
>            # Compare the computed table with the library table.
>            modlib:= ordtblGV4 mod p;
>            if IsCharacterTable( modlib ) then
>              trans:= TransformingPermutationsCharacterTables(
>                          poss[1].table, modlib );
>              if not IsRecord( trans ) then
>                Print( "#E  computed table and library table for ",
>                       name, " mod ", p, " differ\n" );
>              fi;
>            else
>              Print( "#I  no library table for ", name, " mod ", p, "\n" );
>            fi;
>          else
>            Print( "#I  ", name, " mod ", p, ": ", Length( poss ),
>                   " equivalence classes\n" );
>          fi;
>          Add( allposs, poss );
>        else
>          Print( "#I  not all input tables for ", name, " mod ", p,
>                 " available\n" );
>        fi;
>      od;
>      return allposs;
>    end;;
\endexample

Finally, here is the loop over the list of tables.

\beginexample
gap> for input in listGV4 do
>      tblG   := CharacterTable( input[1] );
>      tblsG2 := List( input{ [ 2 .. 4 ] }, CharacterTable );
>      name   := Concatenation( "new", input[5] );
>      lib    := CharacterTable( input[5] );
>      ConstructOrdinaryGV4Table( tblG, tblsG2, name, lib );
>      ConstructModularGV4Tables( tblG, tblsG2, lib );
>    od;
#I  not all input tables for L2(49).2^2 mod 7 available
#I  not all input tables for L2(81).2^2 mod 3 available
#I  not all input tables for O8+(3).(2^2)_{122} mod 3 available
#I  not all input tables for O8+(3).D8 mod 3 available
#I  not all input tables for L4(4).2^2 mod 2 available
#I  not all input tables for L4(4).2^2 mod 3 available
#I  not all input tables for L4(4).2^2 mod 5 available
#I  not all input tables for L4(4).2^2 mod 7 available
#I  not all input tables for L4(4).2^2 mod 17 available
\endexample

The groups $3.A_6.2^2$, $3.L_3(4).2^2$, and $3_2.U_4(3).(2^2)_{133}$
have also the structure $M.G.A$,
with $M.G$ equal to $3.A_6.2_3$, $3.L_3(4).2_1$, and $3_2.U_4(3).2_3$,
respectively,
and $G.A$ equal to $A_6.2^2$, $L_3(4).2^2$, and $U_4(3).(2^2)_{133}$,
respectively (see Section~\ref{3.A_6.2^2etc}).

Similarly, the group $L_3(4).D_{12}$ has also the structure $G.S_3$,
with $G = L_3(4).2_1$, $G.2 = L_3(4).2^2$, and $G.3 = L_3(4).6$,
respectively (see Section~\ref{xplGS3}).

%T  What about $U_3(8).3^2$?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Character Table of $\Aut(L_2(81))$}

The group $\Aut(L_2(81)) \cong L_2(81).(2 \times 4)$ has the structure
$G.2^2$ where $G = L_2(81).2_1$.
Here we get two triples of possible actions on the tables of the groups
$G.2_i$, and one possible character table for each triple.

\beginexample
gap> input:= [ "L2(81).2_1", "L2(81).4_1", "L2(81).4_2", "L2(81).2^2",
>                                                        "L2(81).(2x4)" ];;
gap> tblG   := CharacterTable( input[1] );;
gap> tblsG2 := List( input{ [ 2 .. 4 ] }, CharacterTable );;
gap> name   := Concatenation( "new", input[5] );;
gap> lib    := CharacterTable( input[5] );;
gap> poss   := ConstructOrdinaryGV4Table( tblG, tblsG2, name, lib );;
#I  newL2(81).(2x4): 2 equivalence classes
gap> Length( poss );
2
\endexample

Due to the different underlying actions, the power maps of the two candidate
tables differ.

\beginexample
gap> ord:= OrdersClassRepresentatives( poss[1].table );;
gap> ord = OrdersClassRepresentatives( poss[2].table ); 
true
gap> pos:= Position( ord, 80 );
33
gap> PowerMap( poss[1].table, 3 )[ pos ];
33
gap> PowerMap( poss[2].table, 3 )[ pos ];
34
\endexample

$\Aut(L_2(81))$ can be generated by $\PGL(2,81) = L_2(81).2_2$
and the Frobenius automorphism of order four that is defined on $GL(2,81)$
as the map that cubes the matrix entries.
The elements of order $80$ in $\Aut(L_2(81))$ are conjugates of diagonal
matrices modulo scalar matrices,
which are mapped to their third powers by the Frobenius homomorphism.
So the third power map of $\Aut(L_2(81))$ fixes the classes of elements of
order $80$.
In other words, the first of the two tables is the right one.

\beginexample
gap> trans:= TransformingPermutationsCharacterTables( poss[1].table, lib );;
gap> IsRecord( trans );
true
gap> List( poss[1].G2fusGV4, x -> OnTuples( x, trans.columns ) )
>  = List( tblsG2, x -> GetFusionMap( x, lib ) );
true
gap> ConstructModularGV4Tables( tblG, tblsG2, lib );;
#I  not all input tables for L2(81).(2x4) mod 3 available
#I  not all input tables for L2(81).(2x4) mod 5 available
#I  not all input tables for L2(81).(2x4) mod 41 available
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Character Table of $O_8^+(3).2^2_{111}$}%
\label{O_8^+(3).2^2_{111}}

The construction of the character table of the group $O_8^+(3).2^2_{111}$
is not as straightforward as the constructions shown in Section~\ref{xplGV4}.
Here we get $26$ triples of actions on the tables of the three subgroups
$G.2_i$ of index two,
but only one of them leads to candidates for the desired character table.
Specifically, we get $64$ such candidates, in two equivalence classes
w.r.t.~permutation equivalence.
% This computation needs about one and a half hour of CPU time for getting
% the candidates, and about two hours for the equivalence tests.

% As an alternative to the check of the 26 actions, one could use the group
% for showing that the elements of the orders 40 and 28 have centralizers
% of the orders 80 and 56, respectively.
% However, this part is not very time consuming.

\beginexample
gap> input:= [ "O8+(3)", "O8+(3).2_1",  "O8+(3).2_1'", "O8+(3).2_1''",
>                                                  "O8+(3).(2^2)_{111}" ];;
gap> tblG   := CharacterTable( input[1] );;
gap> tblsG2 := List( input{ [ 2 .. 4 ] }, CharacterTable );;
gap> name   := Concatenation( "new", input[5] );;
gap> lib    := CharacterTable( input[5] );;
gap> poss   := ConstructOrdinaryGV4Table( tblG, tblsG2, name, lib );;
#I  newO8+(3).(2^2)_{111}: 2 equivalence classes
gap> Length( poss );
2
\endexample

The two candidate tables differ only in four irreducible characters
involving irrationalities on the classes of element order $28$.
All three subgroups $G.2_i$ contain elements of order $28$ that do not lie
in the simple group $G$;
these classes are roots of the same (unique) class of element order $7$.
The centralizer $C$ of an order $7$ element in $G.2^2$ has order
$112 = 2^4 \cdot 7$, the intersection of $C$ with $G$ has the structure
$2^2 \times 7$ since $G$ contains three classes of cyclic subgroups of
the order $14$,
and each of the intersections of $C$ with one of the subgroups $G.2_i$
has the structure $2 \times 4 \times 7$,
so the structure of $C$ is $4^2 \times 7 \cong 4 \times 28$.

\beginexample
gap> t:= poss[1].table;;
gap> ord7:= Filtered( [ 1 .. NrConjugacyClasses( t ) ],                        
>               i -> OrdersClassRepresentatives( t )[i] = 7 );
[ 37 ]
gap> SizesCentralizers( t ){ ord7 };
[ 112 ]
gap> ord28:= Filtered( [ 1 .. NrConjugacyClasses( t ) ],
>               i -> OrdersClassRepresentatives( t )[i] = 28 );
[ 112, 113, 114, 115, 161, 162, 163, 164, 210, 211, 212, 213 ]
gap> List( poss[1].G2fusGV4, x -> Intersection( ord28, x ) );
[ [ 112, 113, 114, 115 ], [ 161, 162, 163, 164 ], [ 210, 211, 212, 213 ] ]
gap> sub:= CharacterTable( "Cyclic", 28 ) * CharacterTable( "Cyclic", 4 );;
gap> List( poss, x -> Length( PossibleClassFusions( sub, x.table ) ) );
[ 0, 96 ]
\endexample

It turns out that only one of the two candidate tables admits a class fusion
from the character table of $C$,
thus we have determined the ordinary character table of $O_8^+(3).2^2_{111}$.

% If we do not believe the statement about the structure of $C$ then
% we can check all $14$ groups of order $112$ that contain a central 7;
% a unique such group admits a fusion into at least one of the two
% candidate tables.

\beginexample
gap> trans:= TransformingPermutationsCharacterTables( poss[2].table, lib );;
gap> IsRecord( trans );
true
gap> List( poss[2].G2fusGV4, x -> OnTuples( x, trans.columns ) )
>  = List( tblsG2, x -> GetFusionMap( x, lib ) );
true
gap> ConstructModularGV4Tables( tblG, tblsG2, lib );;
#I  not all input tables for O8+(3).(2^2)_{111} mod 3 available
\endexample

So also the $p$-modular tables of $O_8^+(3).2^2_{111}$ can be computed
this way, provided that the $p$-modular tables of the index $2$ subgroups
are available.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Examples for the Type $2^2.G$}\label{xplV4G}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Character Table of $2^2.Sz(8)$}\label{2^2.Sz(8)}

The ordinary character table of $G = Sz(8)$ admits several
table automorphisms of order dividing $3$.
However, each of these possibilities leads to the same character table of
$2^2.G$, so we need not know which of the table automorphisms are induced
by outer group automorphisms of $G$.

\beginexample
gap> t:= CharacterTable( "Sz(8)" );;
gap> 2t:= CharacterTable( "2.Sz(8)" );;
gap> aut:= AutomorphismsOfTable( t );;
gap> elms:= Set( List( Filtered( aut, x -> Order( x ) in [ 1, 3 ] ),           
>                      SmallestGeneratorPerm ) );
[ (), (9,10,11), (6,7,8), (6,7,8)(9,10,11), (6,7,8)(9,11,10) ]
gap> poss:= List( elms,                                         
>       pi -> PossibleCharacterTablesOfTypeV4G( t, 2t, pi, "2^2.Sz(8)" ) );
[ [ CharacterTable( "2^2.Sz(8)" ) ], [ CharacterTable( "2^2.Sz(8)" ) ], 
  [ CharacterTable( "2^2.Sz(8)" ) ], [ CharacterTable( "2^2.Sz(8)" ) ], 
  [ CharacterTable( "2^2.Sz(8)" ) ] ]
gap> reps:= RepresentativesCharacterTables( Concatenation( poss ) );
[ CharacterTable( "2^2.Sz(8)" ) ]
\endexample

The tables coincide with the one that is stored in the {\GAP} library.

\beginexample
gap> IsRecord( TransformingPermutationsCharacterTables( reps[1],
>        CharacterTable( "2^2.Sz(8)" ) ) );
true
\endexample

The computation of the $p$-modular character table of $2^2.G$ from the
$p$-modular character table of $2.G$ and the three factor fusions from
$2^2.G$ to $2.G$ is straightforward, as was stated in Section~\ref{theorV4G}.
The three fusions are stored on the tables returned by
`PossibleCharacterTablesOfTypeV4G'.

\beginexample
gap> GetFusionMap( poss[1][1], 2t, "1" );
[ 1, 1, 2, 2, 3, 4, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 
  13, 14, 14, 15, 15, 16, 16, 17, 17, 18, 18, 19, 19 ]
gap> GetFusionMap( poss[1][1], 2t, "2" );
[ 1, 2, 1, 2, 3, 4, 5, 6, 7, 6, 7, 8, 9, 8, 9, 10, 11, 10, 11, 12, 13, 12, 
  13, 14, 15, 14, 15, 16, 17, 16, 17, 18, 19, 18, 19 ]
gap> GetFusionMap( poss[1][1], 2t, "3" );
[ 1, 2, 2, 1, 3, 4, 5, 6, 7, 7, 6, 8, 9, 9, 8, 10, 11, 11, 10, 12, 13, 13, 
  12, 14, 15, 15, 14, 16, 17, 17, 16, 18, 19, 19, 18 ]
\endexample

The {\GAP} library function `BrauerTableOfTypeV4G' can be used
to derive Brauer tables of $2^2.G$.
We have to compute the $p$-modular tables for prime divisors $p$ of $|G|$,
that is, for $p \in \{ 2, 5, 7, 13 \}$.

\beginexample
gap> Set( Factors( Size( t ) ) );
[ 2, 5, 7, 13 ]
\endexample

Clearly $p = 2$ is uninteresting because the $2$-modular table of $2^2.G$
can be identified with the $2$-modular table of $G$.

For each of the five ordinary tables (corresponding to the five possible
table automorphisms of $G$) constructed above,
we get one candidate of a $5$-modular table.
However, these tables are *not* all equivalent.
There are two equivalence classes, and one of the two possibilities is
inconsistent in the sense that not all tensor products of irreducibles
decompose into irreducibles.

\beginexample
gap> cand:= List( poss, l -> BrauerTableOfTypeV4G( l[1], 2t mod 5 ) );
[ BrauerTable( "2^2.Sz(8)", 5 ), BrauerTable( "2^2.Sz(8)", 5 ), 
  BrauerTable( "2^2.Sz(8)", 5 ), BrauerTable( "2^2.Sz(8)", 5 ), 
  BrauerTable( "2^2.Sz(8)", 5 ) ]
gap> Length( RepresentativesCharacterTables( cand ) );
2
gap> List( cand, CTblLibTestTensorDecomposition );
#E  tensor decomp. for 2^2.Sz(8)mod5 failed for products with X[18]
#E  tensor decomp. for 2^2.Sz(8)mod5 failed for products with X[18]
[ false, true, false, true, true ]
gap> Length( RepresentativesCharacterTables( cand{ [ 2, 4, 5 ] } ) );
1
gap> IsRecord( TransformingPermutationsCharacterTables( cand[2],
>        CharacterTable( "2^2.Sz(8)" ) mod 5 ) );
true
\endexample

This implies that only those table automorphisms of $G$ can be induced by
an outer group automorphism that move the classes of element order $13$.

The $7$-modular table of $2^2.G$ is uniquely determined, independent of the
choice of the table automorphism of $G$.

\beginexample
gap> cand:= List( poss, l -> BrauerTableOfTypeV4G( l[1], 2t mod 7 ) );
[ BrauerTable( "2^2.Sz(8)", 7 ), BrauerTable( "2^2.Sz(8)", 7 ), 
  BrauerTable( "2^2.Sz(8)", 7 ), BrauerTable( "2^2.Sz(8)", 7 ), 
  BrauerTable( "2^2.Sz(8)", 7 ) ]
gap> Length( RepresentativesCharacterTables( cand ) );
1
gap> IsRecord( TransformingPermutationsCharacterTables( cand[1],      
>        CharacterTable( "2^2.Sz(8)" ) mod 7 ) );
true
\endexample

We get two candidates for the $13$-modular table of $2^2.G$,
also if we consider only the three admissible table automorphisms.

\beginexample
gap> elms:= elms{ [ 2, 4, 5 ] };
[ (9,10,11), (6,7,8)(9,10,11), (6,7,8)(9,11,10) ]
gap> poss:= poss{ [ 2, 4, 5 ] };;                                     
gap> cand:= List( poss, l -> BrauerTableOfTypeV4G( l[1], 2t mod 13 ) );
[ BrauerTable( "2^2.Sz(8)", 13 ), BrauerTable( "2^2.Sz(8)", 13 ), 
  BrauerTable( "2^2.Sz(8)", 13 ) ]
gap> Length( RepresentativesCharacterTables( cand ) );
2
gap> List( cand, CTblLibTestTensorDecomposition );                      
[ true, true, true ]
\endexample

Here I do not know a character-theoretic argument to decide which table
is the correct one.
If we use the ordinary character table of $\Aut( G ) = G.3$ then we see
that the outer automorphisms of $G$ move the classes of element order $7$.

\beginexample
gap> Display( t );
Sz(8)

      2  6  6  4  4  .  .  .  .   .   .   .
      5  1  .  .  .  1  .  .  .   .   .   .
      7  1  .  .  .  .  1  1  1   .   .   .
     13  1  .  .  .  .  .  .  .   1   1   1

        1a 2a 4a 4b 5a 7a 7b 7c 13a 13b 13c
     2P 1a 1a 2a 2a 5a 7b 7c 7a 13b 13c 13a
     5P 1a 2a 4a 4b 1a 7b 7c 7a 13a 13b 13c
     7P 1a 2a 4b 4a 5a 1a 1a 1a 13c 13a 13b
    13P 1a 2a 4a 4b 5a 7a 7b 7c  1a  1a  1a

X.1      1  1  1  1  1  1  1  1   1   1   1
X.2     14 -2  A -A -1  .  .  .   1   1   1
X.3     14 -2 -A  A -1  .  .  .   1   1   1
X.4     35  3 -1 -1  .  .  .  .   E   G   F
X.5     35  3 -1 -1  .  .  .  .   F   E   G
X.6     35  3 -1 -1  .  .  .  .   G   F   E
X.7     64  .  .  . -1  1  1  1  -1  -1  -1
X.8     65  1  1  1  .  B  D  C   .   .   .
X.9     65  1  1  1  .  C  B  D   .   .   .
X.10    65  1  1  1  .  D  C  B   .   .   .
X.11    91 -5 -1 -1  1  .  .  .   .   .   .

A = 2*E(4)
  = 2*ER(-1) = 2i
B = E(7)+E(7)^6
C = E(7)^3+E(7)^4
D = E(7)^2+E(7)^5
E = -E(13)-E(13)^5-E(13)^8-E(13)^12
F = -E(13)^4-E(13)^6-E(13)^7-E(13)^9
G = -E(13)^2-E(13)^3-E(13)^10-E(13)^11
gap> t3:= CharacterTable( "Sz(8).3" );;
gap> Filtered( InverseMap( GetFusionMap( t, t3 ) ), IsList );
[ [ 6, 7, 8 ], [ 9, 10, 11 ] ]
\endexample

This means that the first candidate is ruled out;
this determines the character table.

\beginexample
gap> Length( RepresentativesCharacterTables( cand{ [ 2, 3 ] } ) );
1
gap> IsRecord( TransformingPermutationsCharacterTables( cand[2],
>        CharacterTable( "2^2.Sz(8)" ) mod 13 ) );
true
\endexample

{}From the class fusion into the automorphism group $G.3$ of $G$
it is clear that exactly the classes of orders $7$ and $13$ are not fixed,
but it is not clear whether the group automorphism (or its inverse)
acts as $({\tt 7A}, {\tt 7B}, {\tt 7C})({\tt 13A}, {\tt 13B}, {\tt 13C})$
or $({\tt 7A}, {\tt 7B}, {\tt 7C})({\tt 13A}, {\tt 13C}, {\tt 13B})$.

If we want to determine which of these two permutations describes the
action of an outer automorphism of $G$ on the classes of $G$
then we can use explicit computations with the group.
The lifting order rows in the {\ATLAS} tell us that the former permutation
must be taken, which corresponds to the Galois automorphism ${\ast 2}$;
we want to check this.
For that, we work with a representation of $G.3$ taken from the
{\ATLAS} of Group Representations~\cite{AGR},
via the {\GAP} interface~\cite{AtlasRep}.
So we first load this package and fetch a representation.

\beginexample
gap> LoadPackage( "atlasrep" );
true
gap> g3:= Group( OneAtlasGeneratingSet( "Sz(8).3" ).generators );;
\endexample

We show that the elements in $G.3 \setminus G$ act on the classes of the
element orders $7$ and $13$ in $G$ like the Galois automorphism that
squares the elements (or like the inverse of this automorphism).

\beginexample
gap> g3:= Image( IsomorphismPermGroup( g3 ) );;
gap> g:= DerivedSubgroup( g3 );;
gap> repeat outer:= Random( g3 ); until not outer in g;
gap> outer:= outer^( Order( outer ) / 3 );;
gap> repeat ord7:= Random( g ); until Order( ord7 ) = 7;
gap> repeat ord13:= Random( g ); until Order( ord13 ) = 7;
gap> ( IsConjugate( g, ord7^outer, ord7^2 ) and
>      IsConjugate( g, ord13^outer, ord13^2 ) ) or
>    ( IsConjugate( g, ord7^outer, ord7^4 ) and
>      IsConjugate( g, ord13^outer, ord13^4 ) );
true
\endexample

This means that the induced permutation is indeed $(6,7,8)(9,10,11)$.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{{\ATLAS} Tables of the Type $2^2.G$ (September 2005)}

Besides $2^2.Sz(8)$ (cf.~Section~\ref{2^2.Sz(8)})
and certain central extensions of $L_3(4)$ (cf.~Section~\ref{MultL34}),
the following examples of central extensions of nearly simple {\ATLAS} groups
$G$ by a Klein four group occur.

\beginexample
gap> info:= [
>          [ "2^2.L3(4)",      "2.L3(4)",     "L3(4)"     ],
>          [ "2^2.L3(4).2_1",  "2.L3(4).2_1", "L3(4).2_1" ],
>          [ "(2^2x3).L3(4)",  "6.L3(4)",     "3.L3(4)"   ],
>          [ "2^2.O8+(2)",     "2.O8+(2)",    "O8+(2)"    ],
>          [ "2^2.U6(2)",      "2.U6(2)",     "U6(2)"     ],
>          [ "(2^2x3).U6(2)",  "6.U6(2)",     "3.U6(2)"   ],
>          [ "2^2.2E6(2)",     "2.2E6(2)",    "2E6(2)"    ],
>          [ "(2^2x3).2E6(2)", "6.2E6(2)",    "3.2E6(2)"  ],
> ];;
\endexample

%T what about (2^2x3).L3(4).2_1 ?? (and modular tables)

(For the tables of $(2^2 \times 3).G$, with $G$ one of $L_3(4)$, $U_6(2)$,
or ${}^2E_6(2)$,
alternatively we could use the tables of $2^2.G$ and $3.G$,
and the construction described in~\cite{CCE}.)

In these cases, the action of the outer automorphism of order three on the
classes of $G$ turns out to be uniquely determined by the table automorphisms
of the character table of $G$.

\beginexample
gap> for entry in info do
>      tblG:= CharacterTable( entry[3] );
>      aut:= AutomorphismsOfTable( tblG );
>      ord3:= Set( List( Filtered( aut, x -> Order( x ) = 3 ),
>                        SmallestGeneratorPerm ) );
>      if 1 < Length( ord3 ) then
>        Error( "the action of the automorphism is not unique" );
>      fi;
>      pi:= ord3[1];
>      tbl2G:= CharacterTable( entry[2] );
>      poss:= PossibleCharacterTablesOfTypeV4G( tblG, tbl2G, pi, entry[1] );
>      poss:= RepresentativesCharacterTables( poss );
>      lib:= CharacterTable( entry[1] );
>      if Length( poss ) <> 1 then
>        Print( "#I  table of ", entry[1], " is not uniquely determined\n" );
>      elif lib = fail then
>        Print( "#I  no library table of ", entry[1], "\n" );
>      else
>        if TransformingPermutationsCharacterTables( poss[1], lib ) = fail then
>          Print( "#E  differences for ", entry[1], "\n" );
>        fi;
>        for p in Set( Factors( Size( poss[1] ) ) ) do
>          modtbl2G:= tbl2G mod p;
>          if modtbl2G = fail then
>            Print( "#I  The ", p, "-modular table of ",
>                   Identifier( tbl2G ), " is not available\n" );
>          else
>            modtblV4G:= BrauerTableOfTypeV4G( poss[1], modtbl2G );
>            lib:= lib mod p;
>            if Irr( modtblV4G ) <> Irr( lib ) then
>              Print( "#E  differences for ", entry[1], " mod ", p, "\n" );
>            fi;
>          fi;
>        od;
>      fi;
>    od;
#I  The 2-modular table of 2.2E6(2) is not available
#I  The 3-modular table of 2.2E6(2) is not available
#I  The 5-modular table of 2.2E6(2) is not available
#I  The 7-modular table of 2.2E6(2) is not available
\endexample

% still requires 5977734 msec! (without (2^2x3).2E6(2))

%T other examples:
%T 2.U6(2)M3
%T 6.U6(2)M3

%T and maxes of the above groups!


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{The Character Table of the Schur Cover of $L_3(4)$
(September 2005)}\label{MultL34}

The Schur cover of $G = L_3(4)$ has the structure $(4^2 \times 3).L_3(4)$.
Following~\cite[p.~23]{CCN85}, we regard the multiplier of $G$ as
\[
   M =
   \langle a, b, c, d \mid [a,b] = [a,c] = [a,d] = [b,c] = [b,d] = [c,d]
                                 = a^4 = b^4 = c^4 = d^3 = abc \rangle ,
\]
and we will consider the automorphism $\alpha$ of $M.G$
that acts as $(a,b,c)(d)$ on $M$.

The subgroup lattice of the subgroup
$\langle a, b, c \rangle = \langle a, b \rangle \cong 4^2$ of $M$
looks as follows.
(The subgroup in the centre of the picture is the Klein four group
$\langle a^2, b^2, c^2 \rangle = \langle a^2, b^2 \rangle$.)

\begin{center}
%%tth: \includegraphics{ctblcons17.png}
%BP ctblcons17
\tthdump{\setlength{\unitlength}{3pt}
\begin{picture}(70,45)(-35,-20)
% 4x4
\put(  0, 20){\circle*{1}}\put( 0,23){\makebox(0,0){$\langle a, b, c \rangle$}}
%
% 2x4 (three times)
\put(-10, 10){\circle*{1}}\put(-14,12){\makebox(0,0){$\langle a, b^2 \rangle$}}
\put(  0, 10){\circle*{1}}\put( -4,12){\makebox(0,0){$\langle b, c^2 \rangle$}}
\put( 10, 10){\circle*{1}}\put( 14,12){\makebox(0,0){$\langle c, a^2 \rangle$}}
% 2x2
\put(  0,  0){\circle*{1}}
% \put( -3, 0){\makebox(0,0){$\langle a^2, b^2, c^2 \rangle$}}
%   4 (six times)
\put(-30,  0){\circle*{1}}\put(-33, 0){\makebox(0,0){$\langle a \rangle$}}
\put(-20,  0){\circle*{1}}\put(-24, 0){\makebox(0,0){$\langle a b^2 \rangle$}}
\put(-10,  0){\circle*{1}}\put(-13, 0){\makebox(0,0){$\langle b \rangle$}}
\put( 10,  0){\circle*{1}}\put( 14, 0){\makebox(0,0){$\langle b c^2 \rangle$}}
\put( 20,  0){\circle*{1}}\put( 23, 0){\makebox(0,0){$\langle c \rangle$}}
\put( 30,  0){\circle*{1}}\put( 34, 0){\makebox(0,0){$\langle c a^2 \rangle$}}
%   2 (three times)
\put(-10,-10){\circle*{1}}\put(-12,-12){\makebox(0,0){$\langle a \rangle$}}
\put(  0,-10){\circle*{1}}\put( -2,-12){\makebox(0,0){$\langle b \rangle$}}
\put( 10,-10){\circle*{1}}\put( 12,-12){\makebox(0,0){$\langle c \rangle$}}
%   1
\put(  0,-20){\circle*{1}}
%
\put(-30,0){\line(2, 1){20}}
\put(-30,0){\line(2,-1){20}}
\put(-20,0){\line(1, 1){10}}
\put(-20,0){\line(1,-1){10}}
%
\put(-10,0){\line(1, 1){10}}
\put(-10,0){\line(1,-1){10}}
%
\put(-10,10){\line(1, 1){10}}
\put(-10,-10){\line(1,-1){10}}
%
\put(  0,-20){\line(0,1){40}}
%
\put(-10, 10){\line(1,-1){20}}
\put(-10,-10){\line(1,1){20}}
%
\put(30,0){\line(-2, 1){20}}
\put(30,0){\line(-2,-1){20}}
\put(20,0){\line(-1, 1){10}}
\put(20,0){\line(-1,-1){10}}
\put(10,0){\line(-1, 1){10}}
\put(10,0){\line(-1,-1){10}}
%
\put(10,10){\line(-1, 1){10}}
\put(10,-10){\line(-1,-1){10}}
\end{picture}}
%EP
\end{center}

(The symmetry w.r.t.~$\alpha$ would be reflected better
in a three dimensional model,
with $\langle a, b \rangle$, $\langle a^2, b^2 \rangle$, and the
trivial subgroup on a vertical symmetry axis,
and with the remaining subgroups on three circles such that $\alpha$
induces a rotation.)

% The following is a 3D variant of the picture,
% which shows the symmetry of order three of the group $4 \times 4$.
% However, this requires the epic package of LaTeX (command \drawline),
% and this is not supported by TtH.
%
% \begin{center}
% \setlength{\unitlength}{3pt}
% \begin{picture}(60,50)(-30,-25)
% \put(  0, 25){\circle*{2}} % 4x4
% %
% \put( 14, 10){\circle*{2}} % 2x4
% \put(  1, 17){\circle*{2}} % 2x4
% \put(-15, 11){\circle*{2}} % 2x4
% %
% \put(  0,  0){\circle*{2}} % 2x2
% %
% \put( 12, -7){\circle*{2}} %   4
% \put( 29, -1){\circle*{2}} %   4
% \put(-12,  7){\circle*{2}} %   4
% \put( 17,  6){\circle*{2}} %   4
% \put(-29,  1){\circle*{2}} %   4
% \put(-17, -6){\circle*{2}} %   4
% %
% \put( 14,-15){\circle*{2}} %   2
% \put(  1, -8){\circle*{2}} %   2
% \put(-15,-14){\circle*{2}} %   2
% %
% \put(  0,-25){\circle*{2}} %   1
% %
% \drawline(0,25)( 14,10)
% \drawline(0,25)(  1,17)
% \drawline(0,25)(-15,11)
% %
% \drawline( 14,10)(0,0)
% \drawline( 14,10)(29,-1)
% \drawline( 14,10)(12,-7)
% %
% \drawline( 1,17)(0,0)
% \drawline( 1,17)(16,6)
% \drawline( 1,17)(-12,7)
% %
% \drawline(-15,11)(0,0)
% \drawline(-15,11)(-29,1)
% \drawline(-15,11)(-17,-6)
% %
% \drawline( 14,-15)(0,0)
% \drawline( 14,-15)(29,-1)
% \drawline( 14,-15)(12,-7)
% %
% \drawline(  1, -8)(0,0)
% \drawline(  1, -8)(16,6)
% \drawline(  1, -8)(-12,7)
% %
% \drawline(-15,-14)(0,0)
% \drawline(-15,-14)(-29,1)
% \drawline(-15,-14)(-17,-6)
% %
% \drawline( 14,-15)(0,-25)
% \drawline(  1, -8)(0,-25)
% \drawline(-15,-14)(0,-25)
% \end{picture}
% \end{center}

We have
$(M / \langle a \rangle).G \cong (M / \langle b \rangle).G
                           \cong (M / \langle c \rangle).G \cong 12_2.G$
and
$(M / \langle a b^2 \rangle).G \cong (M / \langle b c^2 \rangle).G
                               \cong (M / \langle c a^2 \rangle).G
                               \cong 12_1.G$.
This is because the action of $G.2_2$ fixes $a$, and swaps $b$ and $c$;
so $b$ is inverted modulo $\langle a \rangle$ but fixed modulo
$\langle a b^2 \rangle$,
and the normal subgroup of order four in $4_2.G.2_2$ is central
but that in $4_1.G.2_2$ is not central.

The constructions of the character tables of $4^2.G$ and $(4^2 \times 3).G$
are essentially the same.
We start with the table of $4^2.G$.
It can be regarded as a central extension $H = V.2^2.G$ of
$2^2.G$ by a Klein four group $V$.
The three subgroups of order two in $V$ are cyclicly permuted
by the automorphism of $M / \langle d \rangle$ induced by $\alpha$,
so the three factors by these subgroups are isomorphic groups $F$, say,
with the structure $(2 \times 4).G$.

The group $F$ itself is a central extension of $2.G$ by a Klein four group,
but in this case the three factor groups by the order two subgroups of the
Klein four group are nonisomorphic groups, of the types
$4_1.G$, $4_2.G$, and $2^2.G$, respectively.
The {\GAP} function `PossibleCharacterTablesOfTypeV4G' can be used
to construct the character table of $F$ from the three factors.
Note that in this case, no information about table automorphisms is
required.

\beginexample
gap> tblG:= CharacterTable( "2.L3(4)" );;
gap> tbls2G:= List( [ "4_1.L3(4)", "4_2.L3(4)", "2^2.L3(4)"],
>                   CharacterTable );;
gap> poss:= PossibleCharacterTablesOfTypeV4G( tblG, tbls2G, "(2x4).L3(4)" );;
gap> Length( poss );
2
gap> reps:= RepresentativesCharacterTables( poss );
[ CharacterTable( "(2x4).L3(4)" ) ]
gap> lib:= CharacterTable( "(2x4).L3(4)" );;
gap> IsRecord( TransformingPermutationsCharacterTables( reps[1], lib ) );
true
\endexample

In the second step, we construct the table of $4^2.G$ from that of
$(2 \times 4).G$ and the table automorphism of $2^2.G$
that is induced by $\alpha$;
it turns out that the group of table automorphisms of $2^2.G$ contains
a unique subgroup of order three.

\beginexample
gap> tblG:= tbls2G[3];
CharacterTable( "2^2.L3(4)" )
gap> tbl2G:= lib;       
CharacterTable( "(2x4).L3(4)" )
gap> aut:= AutomorphismsOfTable( tblG );;
gap> ord3:= Set( List( Filtered( aut, x -> Order( x ) = 3 ),
>                  SmallestGeneratorPerm ) );
[ (2,3,4)(6,7,8)(10,11,12)(13,15,17)(14,16,18)(20,21,22)(24,25,26)(28,29,
    30)(32,33,34) ]
gap> pi:= ord3[1];;
gap> poss:= PossibleCharacterTablesOfTypeV4G( tblG, tbl2G, pi, "4^2.L3(4)" );;
gap> Length( poss );
4
gap> reps:= RepresentativesCharacterTables( poss );        
[ CharacterTable( "4^2.L3(4)" ) ]
gap> lib:= CharacterTable( "4^2.L3(4)" );;
gap> IsRecord( TransformingPermutationsCharacterTables( reps[1], lib ) );
true
\endexample

With the same approach,
we compute the table of $(2 \times 12).G = 2^2.6.G$
from the tables of the three nonisomorphic factor groups $12_1.G$, $12_2.G$,
and $(2^2 \times 3).G$,
and we compute the table of $(4^2 \times 3).G = 2^2.(2^2 \times 3).G$
from the three tables of the factor groups $(2 \times 12).G$ and the action
induced by $\alpha$.

\beginexample
gap> tblG:= CharacterTable( "6.L3(4)" );;
gap> tbls2G:= List( [ "12_1.L3(4)", "12_2.L3(4)", "(2^2x3).L3(4)"],            
>                   CharacterTable );;
gap> poss:= PossibleCharacterTablesOfTypeV4G( tblG, tbls2G, "(2x12).L3(4)" );;
gap> Length( poss );
2
gap> reps:= RepresentativesCharacterTables( poss );
[ CharacterTable( "(2x12).L3(4)" ) ]
gap> lib:= CharacterTable( "(2x12).L3(4)" );;
gap> IsRecord( TransformingPermutationsCharacterTables( reps[1], lib ) );
true
gap> tblG:= CharacterTable( "(2^2x3).L3(4)" ); 
CharacterTable( "(2^2x3).L3(4)" )
gap> tbl2G:= CharacterTable( "(2x12).L3(4)" );
CharacterTable( "(2x12).L3(4)" )
gap> aut:= AutomorphismsOfTable( tblG );;
gap> ord3:= Set( List( Filtered( aut, x -> Order( x ) = 3 ),
>                  SmallestGeneratorPerm ) );
[ (2,7,8)(3,4,10)(6,11,12)(14,19,20)(15,16,22)(18,23,24)(26,27,28)(29,35,
    41)(30,37,43)(31,39,45)(32,36,42)(33,38,44)(34,40,46)(48,53,54)(49,50,
    56)(52,57,58)(60,65,66)(61,62,68)(64,69,70)(72,77,78)(73,74,80)(76,81,
    82)(84,89,90)(85,86,92)(88,93,94) ]
gap> pi:= ord3[1];;
gap> poss:= PossibleCharacterTablesOfTypeV4G( tblG, tbl2G, pi,
>                                             "(4^2x3).L3(4)" );;
gap> Length( poss );
4
gap> RepresentativesCharacterTables( poss );
[ CharacterTable( "(4^2x3).L3(4)" ) ]
gap> lib:= CharacterTable( "(4^2x3).L3(4)" );;
gap> IsRecord( TransformingPermutationsCharacterTables( reps[1], lib ) );
true
\endexample

%\hier!

%-> and now: put anything on top!! 4^2.L3(4).3, (4^2x3).L3(4).3

%-> and do not forget the Brauer tables of (2x4).G, 4^2.G, (2x12).G,
%   (4^2x3).G !
%   (how does ConsiderFactorBlocks react?)

\beginexample
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Examples of Extensions by $p$-singular Automorphisms}%
\label{xplpsing}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Some $p$-Modular Tables of Groups of the Type $M.G.A$}

We show an alternative construction of $p$-modular tables
of certain groups that have been met in Section~\ref{ATLASMGA}.
Each entry in the {\GAP} list `listMGA' contains the `Identifier' values of
character tables of groups of the types $M.G$, $G$, $G.A$, and $M.G.A$.
For each entry with $|A| = p$, a prime integer, we fetch the $p$-modular
table of $G$ and the ordinary table of $G.A$, compute the action of $G.A$
on the $p$-regular classes of $G$,
and then compute the $p$-modular table of $G.A$.
Analogously, we compute the $p$-modular table of $M.G.A$ from the $p$-modular
table of $M.G$ and the ordinary table of $M.G.A$.

\beginexample
gap> for input in listMGA do
>      ordtblMG  := CharacterTable( input[1] );
>      ordtblG   := CharacterTable( input[2] );
>      ordtblGA  := CharacterTable( input[3] );
>      ordtblMGA := CharacterTable( input[4] );
>      p:= Size( ordtblGA ) / Size( ordtblG );
>      if IsPrimeInt( p ) then
>        modtblG:= ordtblG mod p;
>        if modtblG <> fail then
>          modtblGA := CharacterTableRegular( ordtblGA, p );
>          SetIrr( modtblGA, IBrOfExtensionBySingularAutomorphism( modtblG,
>                                ordtblGA ) );
>          if TransformingPermutationsCharacterTables( modtblGA,
>                 ordtblGA mod p ) = fail then
>            Print( "#E  computed table and library table for ", input[3],
>                   " mod ", p, " differ\n" );
>          fi;
>        fi;
>        modtblMG:= ordtblMG mod p;
>        if modtblMG <> fail then
>          modtblMGA := CharacterTableRegular( ordtblMGA, p );
>          SetIrr( modtblMGA, IBrOfExtensionBySingularAutomorphism( modtblMG,
>                                 ordtblMGA ) );
>          if TransformingPermutationsCharacterTables( modtblMGA,
>                 ordtblMGA mod p ) = fail then
>            Print( "#E  computed table and library table for ", input[4],
>                   " mod ", p, " differ\n" );
>          fi;
>        fi;
>      fi;
>    od;
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Some $p$-Modular Tables of Groups of the Type $G.S_3$}

We show an alternative construction of $2$- and $3$-modular tables
of certain groups that have been met in Section~\ref{xplGS3}.
Each entry in the {\GAP} list `listGS3' contains the `Identifier' values of
character tables of groups of the types $G$, $G.2$, $G.3$, and $G.S_3$.
For each entry, we fetch the $2$-modular table of $G$ and the ordinary table
of $G.2$, compute the action of $G.2$ on the $2$-regular classes of $G$,
and then compute the $2$-modular table of $G.2$.
Analogously, we compute the $3$-modular table of $G.3$ from the $3$-modular
table of $G$ and the ordinary table of $G.3$,
and we compute the $2$-modular table of $G.S_3$ from the $2$-modular table
of $G.3$ and the ordinary table of $G.S_3$.

\beginexample
gap> for input in listGS3 do
>      modtblG:= CharacterTable( input[1] ) mod 2;
>      if modtblG <> fail then
>        ordtblG2 := CharacterTable( input[2] );
>        modtblG2 := CharacterTableRegular( ordtblG2, 2 );
>        SetIrr( modtblG2, IBrOfExtensionBySingularAutomorphism( modtblG,
>                              ordtblG2 ) );
>        if TransformingPermutationsCharacterTables( modtblG2,
>               ordtblG2 mod 2 ) = fail then
>          Print( "#E  computed table and library table for ", input[2],
>                 " mod 2 differ\n" );
>        fi;
>      fi;
>      modtblG:= CharacterTable( input[1] ) mod 3;
>      if modtblG <> fail then
>      ordtblG3 := CharacterTable( input[3] );
>        modtblG3 := CharacterTableRegular( ordtblG3, 3 );
>        SetIrr( modtblG3, IBrOfExtensionBySingularAutomorphism( modtblG,
>                              ordtblG3 ) );
>        if TransformingPermutationsCharacterTables( modtblG3,
>               ordtblG3 mod 3 ) = fail then
>          Print( "#E  computed table and library table for ", input[3],
>                 " mod 3 differ\n" );
>        fi;
>      fi;
>      modtblG3:= CharacterTable( input[3] ) mod 2;
>      if modtblG3 <> fail then
>        ordtblGS3 := CharacterTable( input[4] );
>        modtblGS3 := CharacterTableRegular( ordtblGS3, 2 );
>        SetIrr( modtblGS3, IBrOfExtensionBySingularAutomorphism( modtblG3,
>                               ordtblGS3 ) );
>        if TransformingPermutationsCharacterTables( modtblGS3,
>               ordtblGS3 mod 2 ) = fail then
>          Print( "#E  computed table and library table for ", input[4],
>                 " mod 2 differ\n" );
>        fi;
>      fi;
>    od;
\endexample

%T (Note that the $2$-modular tables of $2^2.O_8^+(2).3.2$,
% $2^2.U_6(2).3.2$, and $2^2.{}^2E_6(2).3.2$ are available automatically
% as soon as the factor fusions onto the tables of the factor groups
% modulo the normal Klein four group are stored.)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{$2$-Modular Tables of Groups of the Type $G.2^2$}

We show an alternative construction of $2$-modular tables
of certain groups that have been met in Section~\ref{xplGV43.A6.V4}.
Each entry in the {\GAP} list `listGV4' contains the `Identifier' values of
character tables of groups of the types $G$, $G.2_1$, $G.2_2$, $G.2_3$,
and $G.2^2$.
For each entry, we fetch the $2$-modular table of $G$ and the ordinary tables
of the groups $G.2_i$, and compute the $2$-modular tables of $G.2_i$;
Then we compute from this modular table and the ordinary table of $G.2^2$
the $2$-modular table of $G.2^2$.

\beginexample
gap> for input in listGV4 do
>      modtblG   := CharacterTable( input[1] ) mod 2;
>      if modtblG <> fail then
>        ordtblsG2 := List( input{ [ 2 .. 4 ] }, CharacterTable );
>        ordtblGV4 := CharacterTable( input[5] );
>        for tblG2 in ordtblsG2 do
>          modtblG2:= CharacterTableRegular( tblG2, 2 );
>          SetIrr( modtblG2, IBrOfExtensionBySingularAutomorphism( modtblG,
>                                tblG2 ) );
>          if TransformingPermutationsCharacterTables( modtblG2,
>                 tblG2 mod 2 ) = fail then
>            Print( "#E  computed table and library table for ",
>                   Identifier( tblG2 ), " mod 2 differ\n" );
>          fi;
>          modtblGV4:= CharacterTableRegular( ordtblGV4, 2 );
>          SetIrr( modtblGV4, IBrOfExtensionBySingularAutomorphism( modtblG2,
>                                ordtblGV4 ) );
>          if TransformingPermutationsCharacterTables( modtblGV4,
>                 ordtblGV4 mod 2 ) = fail then
>            Print( "#E  computed table and library table for ", input[5],
>                   " mod 2 differ\n" );
>          fi;
>        od;
>      fi;
>    od;
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%subsection{$p$-Modular Irreducibles ``without Ordinary Table''}

%T $2$-modular tables of $O_8^-(3).2_i$ ?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Examples of Subdirect Products of Index Two}\label{Gsubdir}

hier!


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\bibliographystyle{amsalpha}
\bibliography{../../../doc/mrabbrev,manual,../../../doc/manual,../../atlasrep/doc/manual}

% gap> STOP_TEST( "ctblcons.tst", 612923095 );

\end{document}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%E

