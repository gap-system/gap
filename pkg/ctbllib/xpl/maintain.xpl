%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%W  maintain.xpl                GAP applications              Thomas Breuer
%%
%H  @(#)$Id: maintain.xpl,v 1.1 2006/12/06 16:44:52 gap Exp $
%%
%Y  Copyright 2006,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,   Germany
%%
%X  NAME="maintain"
%X  rm -rf doc/$NAME.tex
%X  etc/xpl2tst xpl/$NAME.xpl tst/$NAME.tst
%X  etc/xpl2latex xpl/$NAME.xpl doc/$NAME.tex
%X  cd doc
%X  chmod 444 $NAME.tex
%X  latex $NAME; bibtex $NAME; latex $NAME; latex $NAME
%X  pdflatex $NAME
%X  sed -e 's/accent127 /"/g;s/accent127/"/g' < $NAME.bbl > tmp
%X  mv tmp $NAME.bbl
%X  tth -u -L$NAME < $NAME.tex > ../htm/$NAME.htm
%%
\documentclass[a4paper]{article}

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
%%tth: \font\mathbb=msbm10
\def\N{{\mathbb N}} \def\Z{{\mathbb Z}} \def\Q{{\mathbb Q}}
\def\R{{\mathbb R}} \def\C{{\mathbb C}} \def\F{{\mathbb F}}
\def\tthdump#1{#1}
\tthdump{\def\URL#1#2{\texttt{#1}}}
%%tth: \def\URL#1#2{\url{#2}}
%%tth: \def\abstract#1{#1}
%%tth: \def\thinspace{ }

\def\M{{\cal M}}

\begin{document}

\tthdump{\title{Maintenance Issues for the {\GAP} Character Table Library}}
%%tth:\begin{html}<title>Maintenance Issues for the GAP Character Table Library</title>\end{html}
%%tth:\begin{html}<h1 align="center">Maintenance Issues for the GAP Character Table Library</h1>\end{html}
%%tth: \begin{html} <body bgcolor="FFFFFF"> \end{html}

\author{\textsc{Thomas Breuer} \\[0.5cm]
\textit{Lehrstuhl D f{\"u}r Mathematik} \\
\textit{RWTH, 52056 Aachen, Germany}}

\date{November 24th, 2006}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\maketitle


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\abstract{This note collects examples of computations that arose
in the context of maintaining the {\GAP} Character Table Library.}

% using `\abstract' seems to reset `\parskip' and `parindent' ...
\textwidth16cm
\oddsidemargin0pt

\parskip 1ex plus 0.5ex minus 0.5ex
\parindent0pt


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\tableofcontents

% gap> START_TEST("$Id: maintain.xpl,v 1.1 2006/12/06 16:44:52 gap Exp $");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{Disproving Possible Character Tables}\label{disprove}

I do not know a necessary and sufficient criterion for checking
whether a given matrix together with a list of power maps
describes the character table of a finite group.
Examples of \emph{pseudo character tables}
(tables which satisfy certain necessary conditions
but for which actually no group exists) have been given in~\cite{Gag86}.

Another such example is described in
\tthdump{\cite{Auto}.}
%%tth:\begin{html}<A href="ctblcons.htm#pseudo_tables_MGA">another collection of examples</A>.\end{html}

% (other aspect: table of a group but not of the group it is claimed for:
% the LyN2 example -> ctosylno.xpl, put an explicit link!)

The tables in the {\GAP} Character Table Library satisfy the usual tests.
However,
there are table candidates for which these tests are not good enough.
% (mention that this should be run when a table is going to be added)

% (example: the candidate with nonintegral structure constants)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{A Perfect Pseudo Character Table (November 2006)}

Up to version~1.1.3 of the {\GAP} Character Table Library,
the table with identifier \texttt{"P41/G1/L1/V4/ext2"} was not correct.
(The problem occurs already in the microfiches
that are attached to~\cite{HP89}.)

In the following, we show that this table is not the character table
of a finite group,
using the {\GAP} library of perfect groups.
Currently we do not know how to prove this inconsistency
alone from the table.

We start with the construction of the inconsistent table;
apart from a little editing,
the following input equals the data formerly stored
in the file `data/ctoholpl.tbl' of the {\GAP} Character Table Library.

\beginexample
gap> tbl:= rec(
>   Identifier:= "P41/G1/L1/V4/ext2",
>   InfoText:= Concatenation( [
>     "origin: Hanrath library,\n",
>     "structure is 2^7.L2(8),\n",
>     "characters sorted with permutation (12,14,15,13)(19,20)" ] ),
>   UnderlyingCharacteristic:= 0,
>   SizesCentralizers:= [64512,1024,1024,64512,64,64,64,64,128,128,64,64,128,
>     128,18,18,14,14,14,14,14,14,18,18,18,18,18,18],
>   ComputedPowerMaps:= [,[1,1,1,1,2,3,3,2,3,2,2,1,3,2,16,16,20,20,22,22,18,
>     18,26,26,27,27,23,23],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,4,1,21,22,17,
>     18,19,20,16,15,15,16,16,15],,,,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,
>     4,1,4,1,4,1,26,25,28,27,23,24]],
>   Irr:= 0,
>   AutomorphismsOfTable:= Group( [(23,26,27)(24,25,28),(9,13)(10,14),
>     (17,19,21)(18,20,22)] ),
>   ConstructionInfoCharacterTable:= ["ConstructClifford",[[[1,2,3,4,5,6,7,8,
>     9],[1,7,8,3,9,2],[1,4,5,6,2],[1,2,2,2,2,2,2,2]],[["L2(8)"],["Dihedral",
>     18],["Dihedral",14],["2^3"]],[[[1,2,3,4],[1,1,1,1],["elab",4,25]],[[1,
>     2,3,4,4,4,4,4,4,4],[2,6,5,2,3,4,5,6,7,8],["elab",10,17]],[[1,2],[3,4],[
>     [1,1],[-1,1]]],[[1,3],[4,2],[[1,1],[-1,1]]],[[1,3],[5,3],[[1,1],[-1,1]]
>     ],[[1,3],[6,4],[[1,1],[-1,1]]],[[1,2],[7,2],[[1,1],[1,-1]]],[[1,2],[8,
>     3],[[1,1],[-1,1]]],[[1,2],[9,5],[[1,1],[1,-1]]]]]],
>   );;
gap> ConstructClifford( tbl, tbl.ConstructionInfoCharacterTable[2] );
gap> ConvertToLibraryCharacterTableNC( tbl );;
\endexample

Suppose that there is a group $G$, say, with this table.
Then $G$ is perfect since the table has only one linear character.

\beginexample
gap> Length( LinearCharacters( tbl ) );
1
gap> IsPerfectCharacterTable( tbl );
true
\endexample

The table satisfies the orthogonality relations,
the structure constants are nonnegative integers,
and symmetrizations of the irreducibles decompose
into the irreducibles, with nonnegative integral coefficients.

\beginexample
gap> IsInternallyConsistent( tbl );
true
gap> irr:= Irr( tbl );;
gap> test:= Concatenation( List( [ 2 .. 7 ],
>               n -> Symmetrizations( tbl, irr, n ) ) );;
gap> Append( test, Set( Tensored( irr, irr ) ) );
gap> fail in Decomposition( irr, test, "nonnegative" );
false
gap> if ForAny( Tuples( [ 1 .. NrConjugacyClasses( tbl ) ], 3 ),
>      t -> not ClassMultiplicationCoefficient( tbl, t[1], t[2], t[3] )
>               in NonnegativeIntegers ) then
>      Error( "contradiction" );
> fi;
\endexample

The {\GAP} Library of Perfect Groups contains representatives of the
four isomorphism types of perfect groups of order $|G| = 64\,512$.

\beginexample
gap> n:= Size( tbl );
64512
gap> NumberPerfectGroups( n );
4
gap> grps:= List( [ 1 .. 4 ], i -> PerfectGroup( IsPermGroup, n, i ) );
[ L2(8) 2^6 E 2^1, L2(8) N 2^6 E 2^1 I, L2(8) N 2^6 E 2^1 II, 
  L2(8) N 2^6 E 2^1 III ]
\endexample

If we believe that the classification of perfect groups of order $|G|$
is correct then all we have to do is to show that none of the
character tables of these four groups is equivalent to the given table.

\beginexample
gap> tbls:= List( grps, CharacterTable );;
gap> List( tbls, x -> TransformingPermutationsCharacterTables( x, tbl ) );
[ fail, fail, fail, fail ]
\endexample

In fact, already the matrices of irreducible characters of the four groups
do not fit to the given table.

\beginexample
gap> List( tbls, t -> TransformingPermutations( Irr( t ), Irr( tbl ) ) );
[ fail, fail, fail, fail ]
\endexample

Let us look closer at the tables in question.
Each character table of a perfect group of order $64\,512$
has exactly one irreducible character of degree $63$ that takes exactly
the values $-1$, $0$, $7$, and $63$;
moreover, the value $7$ occurs in exactly two classes.

\beginexample
gap> testchars:= List( tbls,
>   t -> Filtered( Irr( t ),
>          x -> x[1] = 63 and Set( x ) = [ -1, 0, 7, 63 ] ) );;
gap> List( testchars, Length );
[ 1, 1, 1, 1 ]
gap> List( testchars, l -> Number( l[1], x -> x = 7 ) );
[ 2, 2, 2, 2 ]
\endexample

(Another way to state this is that in each of the four tables $t$ in
question,
there are ten preimage classes of the involution class in the simple
factor group $L_2(8)$,
there are eight preimage classes of this class in the factor group
$2^6.L_2(8)$,
and that the unique class in which an irreducible degree $63$ character
of this factor group takes the value $7$ splits in $t$.)

In the erroneous table, however,
there is only one class with the value $7$ in this character.

\beginexample
gap> testchars:= List( [ tbl ],
>   t -> Filtered( Irr( t ),
>          x -> x[1] = 63 and Set( x ) = [ -1, 0, 7, 63 ] ) );;
gap> List( testchars, Length );
[ 1 ]
gap> List( testchars, l -> Number( l[1], x -> x = 7 ) );
[ 1 ]
\endexample

This property can be checked easily for the displayed table stored
in fiche $2$, row $4$, column $7$ of~\cite{HP89},
with the name \texttt{6L1<>Z\^7<>L2(8); V4; MOD 2},
and it turns out that this table is not correct.

Note that these microfiches contain \emph{two} tables of order $64\,512$,
and there were \emph{three} tables in the {\GAP} Character Table Library
that contain \texttt{origin: Hanrath library} in their \texttt{InfoText}
value.
Besides the incorrect table, these library tables are
the character tables of the groups
\texttt{PerfectGroup( 64512, 1 )} and \texttt{PerfectGroup( 64512, 3 )},
respectively.
(The matrices of irreducible characters of these tables are equivalent.)

\beginexample
gap> Filtered( [ 1 .. 4 ], i ->
>        TransformingPermutationsCharacterTables( tbls[i],
>            CharacterTable( "P41/G1/L1/V1/ext2" ) ) <> fail );
[ 1 ]
gap> Filtered( [ 1 .. 4 ], i ->
>        TransformingPermutationsCharacterTables( tbls[i],
>            CharacterTable( "P41/G1/L1/V2/ext2" ) ) <> fail );
[ 3 ]
gap> TransformingPermutations( Irr( tbls[1] ), Irr( tbls[3] ) ) <> fail;
true
\endexample

Since version~1.1.4 of the {\GAP} Character Table Library,
the character table with the \texttt{Identifier} value
\texttt{"P41/G1/L1/V4/ext2"} corresponds to the group
\texttt{PerfectGroup( 64512, 4 )}.
The choice of this group was somewhat arbitrary since the vector system
\texttt{V4} seems to be not defined in~\cite{HP89};
anyhow, this group and the remaining perfect group,
\texttt{PerfectGroup( 64512, 2 )},
have equivalent matrices of irreducibles.

\beginexample
gap> Filtered( [ 1 .. 4 ], i ->
>        TransformingPermutationsCharacterTables( tbls[i],
>            CharacterTable( "P41/G1/L1/V4/ext2" ) ) <> fail );
[ 4 ]
gap> TransformingPermutations( Irr( tbls[2] ), Irr( tbls[4] ) ) <> fail;
true 
\endexample


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\bibliographystyle{amsalpha}
\bibliography{../../../doc/mrabbrev,manual,../../../doc/manual,../../atlasrep/doc/manual}

% gap> STOP_TEST( "maintain.tst", 3000000000 );

\end{document}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%E

