%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%W  spornilp.xpl                GAP applications              Thomas Breuer
%%
%H  @(#)$Id: spornilp.xpl,v 1.1 2009/06/12 11:17:37 gap Exp $
%%
%Y  Copyright 2009,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,   Germany
%%
%X  NAME="spornilp"
%X  rm -rf doc/$NAME.tex
%X  etc/xpl2tst xpl/$NAME.xpl tst/$NAME.tst
%X  etc/xpl2latex xpl/$NAME.xpl doc/$NAME.tex
%X  cd doc
%X  chmod 444 $NAME.tex
%X  latex $NAME; bibtex $NAME;
%X  sed -e 's/accent127 /"/g;s/accent127/"/g;s/\MR{.* /\MRhref&&/g;s/MRhrefMR/MRhref/g;s/ MR{/}{/g' < $NAME.bbl > tmp
%X  mv tmp $NAME.bbl
%X  latex $NAME; latex $NAME
%X  pdflatex $NAME
%X  tth -u -L$NAME < $NAME.tex > ../htm/$NAME.htm
%%
\documentclass[a4paper]{article}

\usepackage{theorem}
\newtheorem{prop}{Proposition}
\newtheorem{lem}[prop]{Lemma}

\textwidth16cm
\oddsidemargin0pt

\parskip 1ex plus 0.5ex minus 0.5ex
\parindent0pt

\usepackage{amssymb}

\def\tthdump#1{#1}

% Miscellaneous macros.
\def\GAP{\textsf{GAP}}
\def\ATLAS{\textsc{Atlas}}
\def\Irr{{\rm Irr}}
\def\Aut{{\rm Aut}}
\def\Cent{{\rm\bf C}}
\def\Norm{{\rm\bf N}}
%%tth: \font\mathbb=msbm10
\def\N{{\mathbb N}} \def\Z{{\mathbb Z}} \def\Q{{\mathbb Q}}
\def\R{{\mathbb R}} \def\C{{\mathbb C}} \def\F{{\mathbb F}}
\tthdump{\def\M{{\mathbb M}}}
%%tth: \def\M{\begin{html}&#x1D544;\end{html}}
\tthdump{\def\URL#1#2{\texttt{#1}}}
%%tth: \def\URL#1#2{\url{#2}}
%%tth: \def\thinspace{ }
%%tth: \def\abstract#1{#1}
%%tth: \def\colon{:}
%%tth: \def\thinspace{ }
%%tth: \def\textendash{--}
%%tth: \def\discretionary{}

%\def\M{{\cal M}}

\begin{document}

\tthdump{\title{Large Nilpotent Subgroups of Sporadic Simple Groups}}
%%tth:\begin{html}<title>Large Nilpotent Subgroups of Sporadic Simple Groups</title>\end{html}
%%tth:\begin{html}<h1 align="center">Large Nilpotent Subgroups of Sporadic Simple Groups</h1>\end{html}
%%tth: \begin{html} <body bgcolor="FFFFFF"> \end{html}

\author{\textsc{Thomas Breuer} \\[0.5cm]
\textit{Lehrstuhl D f{\"u}r Mathematik} \\
\textit{RWTH, 52056 Aachen, Germany}}

\date{June 6th, 2009}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\maketitle


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\abstract{
We show that any nontrivial nilpotent subgroup $U$
in a sporadic simple group $G$ satisfies $|U| \cdot |\Norm_G(U)| < |G|$.
The proof uses the information in the {\ATLAS} of Finite Groups~\cite{CCN85}
and the {\GAP} system~\cite{GAP4},
in particular its Character Table Library~\cite{CTblLib1.1.3}
and its library of Tables of Marks.}

% using `\abstract' seems to reset `\parskip' and `parindent' ...
\textwidth16cm
\oddsidemargin0pt

\parskip 1ex plus 0.5ex minus 0.5ex
\parindent0pt


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \tableofcontents

% gap> START_TEST("$Id: spornilp.xpl,v 1.1 2009/06/12 11:17:37 gap Exp $");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{The Result}

The aim of this writeup is to show the following statement.

\begin{prop}\label{theresult}
Let $G$ be a sporadic simple group,
let $U$ be a nontrivial nilpotent subgroup in $G$,
and let $\Norm_G(U)$ denote the normalizer of $U$ in $G$.
Then $|U| \cdot |\Norm_G(U)| < |G|$ holds.
\end{prop}

The following criteria are sufficient to prove Proposition~\ref{theresult}.
Note that we are interested in an argument that uses only information about
the character tables of the sporadic simple groups and of their maximal
subgroups.

\begin{lem}\label{criteria}
Let $G$ be a nonabelian finite simple group,
and suppose that $U$ is a nontrivial nilpotent subgroup of $G$ such that
$|U| \cdot |\Norm_G(U)| \geq |G|$ holds.
Let $\Pi = \{ p_1, p_2, \ldots, p_n \}$ be the set of prime divisors
of $|U|$, and set $n = \prod_{p \in \Pi} p$.
\begin{itemize}
\item[(a)]
    $G$ contains an element $g$ of order $n$ and a maximal subgroup $M$
    with the properties $g \in Z(U)$ and $\Norm_G(U) \leq M$.
    Set $c:= \gcd(|\Cent_G(g)|_{\Pi}, |M|)$,
    where $|\Cent_G(g)|_{\Pi}$ denotes the largest divisor of the order of the
    centralizer of $g$ in $G$ whose prime divisors are elements of the set
    $\Pi$.
    Then we have $|U| \leq c$ and hence $c \cdot |M| \geq |G|$,
    in particular $|M|^2 \geq |G|$.
\item[(b)]
    If $(g, M)$ is as in part~(a) then one of the following holds.
    \begin{itemize}
    \item[(b1)]
        $U$ is normal in $M$, and the Fitting subgroup $Fit(M)$ of $M$
        satisfies $|Fit(M)| \cdot |M| \geq |G|$.
    \item[(b2)]
        $U$ is not normal in $M$, so $\Norm_G(U)$ is a proper subgroup of $M$,
        in particular $|G| \leq |U| \cdot |M|/2 \leq c \cdot |M| / 2$ holds.
    \end{itemize}
\item[(c)]
    Let $(g, M)$ be as in part~(b2) and assume that $M$ contains a normal
    subgroup $K$ such that $\overline{M}:= M/K$ is an almost simple group
    with socle $S$,
    i.~e., $\overline{M}$ has a nonabelian simple normal subgroup $S$
    such that $\Cent_{\overline{M}}(S)$ is trivial.
    Then either $U \leq K$ holds, and hence $|K| \cdot |M| \geq |G|$,
    or we are in the following situation.

    The group $\overline{U}:= U K / K$ is a nontrivial nilpotent normal
    subgroup of $\overline{N}:= \Norm_G(U) K / K$,
    and $H:= S \cap \overline{N}$ is a proper subgroup of $S$.
    The latter statement holds because otherwise $S \cap \overline{U}$
    would be normal in $S$ and thus would be trivial,
    which would imply that $S$ would centralize $\overline{U}$.

    As a consequence, $|\overline{N}|$ divides
    $|\overline{M}/S| \cdot |H| = |\overline{M}| / [S:H]$,
    in particular,
    $[S:H] \leq |\overline{M}| / |\overline{N}| = |M| / |\Norm_G(U) K|
    \leq |M| / |\Norm_G(U)| \leq |M| \cdot |U| / |G| \leq c / [G:M]$
    holds.
\end{itemize}
\end{lem}

We will apply Lemma~\ref{criteria} as follows.

{}From the character tables of $G$ and $M$,
the value $|Fit(M)|$ and the maximal possible $c$ can be computed.
If part~(a) of the lemma applies then we verify that part~(b1)
does \emph{not} apply, and that either (b2) or (c) yields a contradiction.
Note that we can determine from the character table of $M$
whether $M$ has a normal subgroup $K$ such that $M/K$ is almost simple,
and in this case we can compute the order of the socle $S$ of $M/K$.

For proving the nonexistence of the subgroup $H$ in the situation of
part~(c), we will show that all subgroups of $\overline{M}$ of index up to
$d:= c \cdot [\overline{M}:S] / [G:M]$ contain $S$.
For that, we will compute the complete list of those possible permutation
characters of $\overline{M}$ whose degree is at most $d$,
and then check that the kernels of these characters contain $S$.

(Note that these computations are cheap because
the bound $d$ is small in the cases that occur.
There are easier criteria for proving the nonexistence of a subgroup
of index at most $d$ in a simple group $S$,
for example in the case $|S| > d! / 2$ or if
the smallest nontrivial irreducible degree of $S$ is at least $d$;
but these criteria do not suffice in our situation.)

% We do not test whether $M$ contains elements in the class of $g$,
% since this would require fusion information.

We illustrate the application of Lemma~\ref{criteria} with some examples.

\begin{description}
\item[$J_1$:]
    The first Janko group $J_1$ (see~\cite[p.~36]{CCN85})
    has order $175\,560$,
    and the largest maximal subgroup has order $660$.
    The largest centralizer of a nonidentity element in $J_1$ has order
    $120$, and $660 \cdot 120 = 79\,200 < |J_1|$.
    Thus $J_1$ satisfies Proposition~\ref{theresult}.
\item[$\M$:]
    For the Monster group $\M$ (see~\cite[p.~234]{CCN85}),
    we read off from the list~\cite{Mmaxes}
    of maximal subgroups that the only maximal subgroups $M$ of $\M$ with the
    property $|M|^2 \geq |\M|$ have the structure $2.B$.
    Already for the second largest maximal subgroups,
    with the structure $2^{1+24}.Co_1$, the order is smaller than the
    index in the Monster.

    Only elements $g$ from the classes `2A', `2B', and `3A' have the property
    that the product of $|2.B|$ and the order of the centralizer of $g$
    in $\M$ is not smaller than $|\M|$.
    So $U$ can be only a $2$- or a $3$-subgroup of $2.B$.
    However, the $2$-part and the $3$-part of $|2.B|$ are
    $2^{42}$ and $3^{13}$, respectively, which are smaller than the index
    of $2.B$ in $\M$.
    Thus $\M$ satisfies Proposition~\ref{theresult}.
\item[$Fi_{23}$:]
    We show that no counterexample to Proposition~\ref{theresult} can arise
    from maximal subgroups $M$ of the type $O_8^+(3):S_3$ in the Fischer
    group $Fi_{23}$ (see~\cite[p.~177]{CCN85}).
    Several element centralizers in $G$ satisfy Lemma~\ref{criteria}~(a),
    the largest value $c$ arises from elements in the class `6B',
    whose centralizers have order $2^8 \cdot 3^9$,
    which divides $|M|$.
    So $|U| \leq 2^8 \cdot 3^9$, and a possible counterexample to
    Proposition~\ref{theresult} must satisfy
    $|\Norm_G(U)| \geq |G| / (2^8 \cdot 3^9) = 811\,588\,377\,600$.
    We have $|M| = 29\,713\,078\,886\,400$, which is less than $37$ times
    this minimal order required for $\Norm_G(U)$.
    However, the intersection $H$ of this group with the simple subgroup
    $S \cong O_8^+(3)$ in $M$ cannot be at most $36$,
    because the largest maximal subgroups in $S$ have index $1\,080$
    (see~\cite[p.~140]{CCN85}).
    Arguing not with $S$ but with $M$, we can show --using only the
    character table of $M$-- that all proper
    subgroups of index less than $37 \cdot 6$ in $M$ contain $S$.
\end{description}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{The Proof}

The following {\GAP} function utilizes Lemma~\ref{criteria}.
Its input are the {\GAP} character table `tbl' of a group $G$, say,
and a list `maxesinfo' of character tables of maximal subgroups of $G$,
covering at least all those maximal subgroups $M$ for which $|M|^2 \geq |G|$
holds.

The idea is to collect pairs $(M, g)$ that satisfy part~(a) of
Lemma~\ref{criteria},
and then to show that they do not satisfy part~(b) or part~(c).
For each maximal subgroup $M$ that admits elements $g$ as in
Lemma~\ref{criteria},
information is printed how this candidate is excluded.

The function returns a list of length three.
The first entry is `true' if the criteria of Lemma~\ref{criteria}
are sufficient to prove that Proposition~\ref{theresult} is true for $G$,
and `false' otherwise.
The second entry is the name of $G$,
and the third entry in the number of maximal subgroups $M$
for which an element $g$ as in Lemma~\ref{criteria}~(a) exists.

\beginexample
gap> ApplyTheLemma:= function( tbl, maxesinfo )
>     local Gname, Gsize, cents, orders, result, Mtbl, Msize, maxc, i, pi,
>           pipart, c, Mclasslengths, Fit, excluded, Kclasses, Mbar, Ksize,
>           Sclasses, Ssize, d;
>     Gname:= Identifier( tbl );
>     Gsize:= Size( tbl );
>     cents:= SizesCentralizers( tbl );
>     orders:= OrdersClassRepresentatives( tbl );
>     result:= [ true, Gname, 0 ];
>     # Run over the relevant maximal subgroups.
>     for Mtbl in maxesinfo do
>       Msize:= Size( Mtbl );
>       # Run over nonidentity class representatives g of squarefree order,
>       # compute the largest c that occurs.
>       maxc:= 1;
>       for i in [ 2 .. NrConjugacyClasses( tbl ) ] do
>         pi:= Factors( orders[i] );
>         if IsSet( pi ) then
>           # The elements in class `i' have squarefree order.
>           pipart:= Product( Filtered( Factors( cents[i] ),
>                                       x -> x in pi ) );
>           c:= Gcd( pipart, Msize );
>           if maxc < c then
>             maxc:= c;
>           fi;
>         fi;
>       od;
>       if maxc * Msize >= Gsize then
>         # Criterion (a) is satisfied, try to exclude (b) and (c).
>         result[3]:= result[3] + 1;
>         Print( Gname, ": consider M = ", Identifier( Mtbl ),
>                ", c = ", StringPP( maxc ),
>                ", c * |M| / |G| >= ", Int( maxc * Msize / Gsize ), "\n" );
>         Mclasslengths:= SizesConjugacyClasses( Mtbl );
>         Fit:= Mclasslengths{ ClassPositionsOfFittingSubgroup( Mtbl ) };
>         if Sum( Fit ) * Msize >= Gsize then
>           # Criterion (b1) is satisfied.
>           Print( Gname, ": not excludable by (b1)\n" );
>           result[1]:= false;
>         elif maxc * Msize < 2 * Gsize then
>           # Criterion (b2) is not satisfied.
>           Print( Gname, ":     excluded by (b2)\n" );
>         else
>           # Run over the normal subgroups of M.
>           excluded:= false;
>           for Kclasses in ClassPositionsOfNormalSubgroups( Mtbl ) do
>             Mbar:= Mtbl / Kclasses;
>             Ksize:= Sum( Mclasslengths{ Kclasses } );
>             if IsAlmostSimpleCharacterTable( Mbar ) and
>                Ksize * Msize < Gsize then
>               # We are in the situation of criterion (c).
>               # The socle is the unique minimal normal subgroup.
>               Sclasses:= ClassPositionsOfMinimalNormalSubgroups(
>                              Mbar )[1];
>               Ssize:= Sum( SizesConjugacyClasses( Mbar ){ Sclasses } );
>               d:= Int( maxc * Msize * Size( Mbar ) / ( Gsize * Ssize ) );
>               # Try to show that all subgroups of index up to d in Mbar
>               # contain the socle.
>               if ForAll( [ 2 .. d ],
>                    n -> ForAll( PermChars( Mbar, rec( torso:= [ n ] ) ),
>                           chi -> IsSubset( ClassPositionsOfKernel( chi ),
>                                            Sclasses ) ) ) then
>                 Print( Gname, ":     excluded by (c), |K| = ",
>                        StringPP( Ksize ), ", degree bound ", d, "\n" );
>                 excluded:= true;
>                 break;
>               fi;
>             fi;
>           od;
>           if not excluded then
>             Print( Gname, ": not excludable by (c)\n" );
>             result[1]:= false;
>           fi;
>         fi;
>       fi;
>     od;
>     return result;
> end;;
\endexample

So our proof relies on the classifications of maximal subgroups of
sporadic simple groups, see~\cite{CCN85} and~\cite{BN95}.

The {\GAP} Character Table Library~\cite{CTblLib1.1.3} contains
the character tables of the sporadic simple groups
and of their maximal subgroups,
except that not all character tables of maximal subgroups of
the Monster group are available yet.
(See Section~\ref{theresult} for the treatment of the Monster group.)

Since the {\GAP} Character Table Library is used for the computations
in this section, we first load this package.

\beginexample
gap> LoadPackage( "ctbllib" );
true
\endexample

Now we apply the function to the sporadic simple groups.

\beginexample
gap> info:= [];;                                       
gap> for name in AllCharacterTableNames( IsSporadicSimple, true ) do
>      tbl:= CharacterTable( name );
>      if HasMaxes( tbl ) then
>        mx:= List( Maxes( tbl ), CharacterTable );  
>      elif name = "M" then
>        mx:= [ CharacterTable( "2.B" ) ];
>      else
>        Error( "this should not happen ...");
>      fi;
>      Add( info, ApplyTheLemma( tbl, mx ) );
>    od;
B: consider M = 2.2E6(2).2, c = 2^38, c * |M| / |G| >= 20
B:     excluded by (c), |K| = 2, degree bound 40
Co1: consider M = Co2, c = 2^13*3^5, c * |M| / |G| >= 20
Co1:     excluded by (c), |K| = 1, degree bound 20
Co1: consider M = 3.Suz.2, c = 2^13*3^5, c * |M| / |G| >= 1
Co1:     excluded by (b2)
Co2: consider M = U6(2).2, c = 2^16, c * |M| / |G| >= 28
Co2:     excluded by (c), |K| = 1, degree bound 56
Co2: consider M = 2^10:m22:2, c = 2^18, c * |M| / |G| >= 5
Co2:     excluded by (c), |K| = 2^10, degree bound 11
Co2: consider M = 2^1+8:s6f2, c = 2^18, c * |M| / |G| >= 4
Co2:     excluded by (c), |K| = 2^9, degree bound 4
Co3: consider M = McL.2, c = 2^4*3^4, c * |M| / |G| >= 4
Co3:     excluded by (c), |K| = 1, degree bound 9
F3+: consider M = Fi23, c = 2^9*3^9, c * |M| / |G| >= 32
F3+:     excluded by (c), |K| = 1, degree bound 32
Fi22: consider M = 2.U6(2), c = 2^7*3^6, c * |M| / |G| >= 26
Fi22:     excluded by (c), |K| = 2, degree bound 26
Fi22: consider M = O7(3), c = 2^7*3^6, c * |M| / |G| >= 6
Fi22:     excluded by (c), |K| = 1, degree bound 6
Fi22: consider M = Fi22M3, c = 2^7*3^6, c * |M| / |G| >= 6
Fi22:     excluded by (c), |K| = 1, degree bound 6
Fi22: consider M = O8+(2).3.2, c = 2^7*3^6, c * |M| / |G| >= 1
Fi22:     excluded by (b2)
Fi23: consider M = 2.Fi22, c = 2^8*3^9, c * |M| / |G| >= 159
Fi23:     excluded by (c), |K| = 2, degree bound 159
Fi23: consider M = O8+(3).3.2, c = 2^8*3^9, c * |M| / |G| >= 36
Fi23:     excluded by (c), |K| = 1, degree bound 219
HS: consider M = M22, c = 2^7, c * |M| / |G| >= 1
HS:     excluded by (b2)
M11: consider M = A6.2_3, c = 2^4, c * |M| / |G| >= 1
M11:     excluded by (b2)
M12: consider M = M11, c = 2^4, c * |M| / |G| >= 1
M12:     excluded by (b2)
M12: consider M = M12M2, c = 2^4, c * |M| / |G| >= 1
M12:     excluded by (b2)
M22: consider M = L3(4), c = 2^6, c * |M| / |G| >= 2
M22:     excluded by (c), |K| = 1, degree bound 2
M22: consider M = 2^4:a6, c = 2^7, c * |M| / |G| >= 1
M22:     excluded by (b2)
M23: consider M = M22, c = 2^7, c * |M| / |G| >= 5
M23:     excluded by (c), |K| = 1, degree bound 5
M24: consider M = M23, c = 2^7, c * |M| / |G| >= 5
M24:     excluded by (c), |K| = 1, degree bound 5
M24: consider M = 2^4:a8, c = 2^10, c * |M| / |G| >= 1
M24:     excluded by (b2)
McL: consider M = U4(3), c = 3^6, c * |M| / |G| >= 2
McL:     excluded by (c), |K| = 1, degree bound 2
Ru: consider M = 2F4(2)'.2, c = 2^12, c * |M| / |G| >= 1
Ru:     excluded by (b2)
Suz: consider M = G2(4), c = 2^12, c * |M| / |G| >= 2
Suz:     excluded by (c), |K| = 1, degree bound 2
\endexample

First of all, we see that Lemma~\ref{criteria} is sufficient
to prove Proposition~\ref{theresult},
since all candidates were excluded.

Moreover, we see that for ten sporadic simple groups,
no candidates had to be considered.
(No information was printed about these groups.)

\beginexample
gap> Filtered( info, x -> x[3] = 0 );
[ [ true, "HN", 0 ], [ true, "He", 0 ], [ true, "J1", 0 ], [ true, "J2", 0 ], 
  [ true, "J3", 0 ], [ true, "J4", 0 ], [ true, "Ly", 0 ], [ true, "M", 0 ], 
  [ true, "ON", 0 ], [ true, "Th", 0 ] ]
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Alternative: Use {\GAP}'s Tables of Marks}\label{EASY}

We can easily inspect all conjugacy classes of subgroups of a group $G$
whose table of marks is contained in {\GAP}'s Library of Tables of Marks.
First we load this {\GAP} package.

\beginexample
gap> LoadPackage( "tomlib" );
true
\endexample

The following {\GAP} function takes the table of marks of a group $G$
and returns the list of pairs $[ U, \Norm_G(U) ]$
where $U$ ranges over representatives of conjugacy classes
of those nilpotent subgroups of $G$ for which
$|U| \cdot |\Norm_G(U)|$ is maximal.

\beginexample
gap> maximalpairs:= function( tom )
>    local g, max, result, i, u, n, prod;
>    g:= UnderlyingGroup( tom );
>    max:= 1;
>    result:= [];
>    for i in [ 1 .. Length( OrdersTom( tom ) ) ] do
>      u:= RepresentativeTom( tom, i );
>      if not IsTrivial( u ) and IsNilpotent( u ) then
>        n:= Normalizer( g, u );
>        prod:= Size( u ) * Size( n );
>        if max < prod then
>          max:= prod;
>          result:= [ [ u, n ] ];
>        elif max = prod then
>          Add( result, [ u, n ] );
>        fi;
>      fi;
>    od;
>    return result;
> end;;
\endexample

So let us collect the data for those sporadic simple groups
for which the table of marks is known.

\beginexample
gap> info:= [];;
gap> for name in AllCharacterTableNames( IsSporadicSimple, true ) do
>      tom:= TableOfMarks( name );
>      if tom <> fail then
>        Add( info, [ name, tom, maximalpairs( tom ) ] );
>      fi;
>    od;
gap> Length( info );
12
\endexample

% gap> time;
% 863154

We got results for twelve sporadic simple groups.
The following computations show that in ten cases,
the simple group $G$ contains a unique class of nontrivial nilpotent
subgroups $U$
for which the maximal value of $|U| \cdot |\Norm_G(U)|$ is attained.
The ratio of this value and $|G|$ is less than $21\%$.
The following table shows the name of the group $G$,
the orders of $U$ and $\Norm_G(U)$, and the integral part of $10^6$ times
the ratio.

\beginexample
gap> List( info, x -> Length( x[3] ) );
[ 1, 1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1 ]
gap> mat:= [];;
gap> for entry in info do
>      pair:= entry[3][1];                          # [ U, N_G(U) ]
>      bound:= Size( pair[1] ) * Size( pair[2] );   # |U|*|N_G(U)|
>      size:= Size( UnderlyingGroup( entry[2] ) );  # |G|
>      Add( mat, [ entry[1],
>                  StringPP( Size( pair[1] ) ), StringPP( Size( pair[2] ) ), 
>                  Int( 10^6 * bound / size ) ] );
>  if Size( pair[1] ) * Size( pair[2] ) > 20/100 * size then Error("!"); fi;
>    od;
gap> PrintArray( mat );
[ [           Co3,           3^5,  2^5*3^7*5*11,          1886 ],
  [            HS,           2^6,       2^9*3*7,         15515 ],
  [            He,           2^6,    2^10*3^3*5,          2195 ],
  [            J1,            19,        2*3*19,         12337 ],
  [            J2,           2^6,       2^7*3^2,        121904 ],
  [            J3,           3^5,       2^3*3^5,          9404 ],
  [           M11,           3^2,       2^4*3^2,        163636 ],
  [           M12,           2^5,         2^6*3,         64646 ],
  [           M22,           2^4,     2^7*3^2*5,        207792 ],
  [           M23,           2^4,   2^7*3^2*5*7,         63241 ],
  [           M24,           2^6,    2^10*3^3*5,         36137 ],
  [           McL,           3^5,     2^4*3^6*5,         15779 ] ]
\endexample

Moreover, we see that in most cases, the group $U$ for which the
maximum is attained is not the largest $p$-subgroup in the
simple group in question.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\bibliographystyle{amsalpha}
\bibliography{manualbib.xml,../../../doc/manualbib.xml,../../atlasrep/doc/manualbib.xml}

% gap> STOP_TEST( "sporsolv.tst", 3000000000 );

\end{document}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%E

