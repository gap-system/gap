%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% WS-P8-50x6-00.CLS  : 20-11-97
%% Class file to be used for single column proceedings (smaller
%% size [8.50" x 6.00"]) to be published by World Scientific
%% Publishing Co. written in Latex2e and using some reconstruc-
%% tions designed by R. Sankaran based on and to match the spec.
%% fixed in the latex style file designed by Susan Hezlet and Lukas 
%% Nellen. Suggestions/comments to:rsanka@wspc.com.sg
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{ws-p8-50x6-00}
               [1996/05/26 v1.3r Standard LaTeX document class]
\newif\if@restonecol
\newif\if@titlepage
%
\DeclareOption{draft}{\setlength\overfullrule{5pt}}
\DeclareOption{final}{\setlength\overfullrule{0pt}}
\DeclareOption{twocolumn}{\@twocolumntrue}
%
\ExecuteOptions{a4paper,10pt,twoside,twocolumn,final}
\ProcessOptions
%
\renewcommand\normalsize{%
   \@setfontsize\normalsize\@xpt\@xiipt
   \abovedisplayskip6\p@\@plus4\p@\@minus2\p@
   \abovedisplayshortskip\abovedisplayskip
   \belowdisplayshortskip\abovedisplayshortskip
   \belowdisplayskip\abovedisplayskip
   \let\@listi\@listI}
\normalsize
\newcommand\small{%
   \@setfontsize\small\@ixpt{11}%
   \abovedisplayskip 8.5\p@ \@plus3\p@ \@minus4\p@
   \abovedisplayshortskip \z@ \@plus2\p@
   \belowdisplayshortskip 4\p@ \@plus2\p@ \@minus2\p@
   \def\@listi{\leftmargin\leftmargini
               \topsep 4\p@ \@plus2\p@ \@minus2\p@
               \parsep 2\p@ \@plus\p@ \@minus\p@
               \itemsep \parsep}%
   \belowdisplayskip \abovedisplayskip
}
\newcommand\footnotesize{%
   \@setfontsize\footnotesize\@viiipt{9.5}%
   \abovedisplayskip 6\p@ \@plus2\p@ \@minus4\p@
   \abovedisplayshortskip \z@ \@plus\p@
   \belowdisplayshortskip 3\p@ \@plus\p@ \@minus2\p@
   \def\@listi{\leftmargin\leftmargini
               \topsep 3\p@ \@plus\p@ \@minus\p@
               \parsep 2\p@ \@plus\p@ \@minus\p@
               \itemsep \parsep}%
   \belowdisplayskip \abovedisplayskip
}
\newcommand\scriptsize{\@setfontsize\scriptsize\@viipt\@viiipt}
\newcommand\tiny{\@setfontsize\tiny\@vpt\@vipt}
\newcommand\large{\@setfontsize\large\@xiipt{14}}
\newcommand\Large{\@setfontsize\Large\@xivpt{18}}
\newcommand\LARGE{\@setfontsize\LARGE\@xviipt{22}}
\newcommand\huge{\@setfontsize\huge\@xxpt{25}}
\newcommand\Huge{\@setfontsize\Huge\@xxvpt{30}}
\setlength\parindent{0.25in}
\setlength\smallskipamount{3\p@ \@plus 1\p@ \@minus 1\p@}
\setlength\medskipamount{6\p@ \@plus 2\p@ \@minus 2\p@}
\setlength\bigskipamount{12\p@ \@plus 4\p@ \@minus 4\p@}
%%%%%%
%
\newdimen\trimheight
\newdimen\trimwidth
\newdimen\typeheight
\newdimen\typewidth
\newdimen\tempdimen
\newdimen\normaltextheight
%
\trimheight8.50in
\trimwidth6.00in
\typeheight40.10pc
%
\setlength\topmargin{0.75in}
\setlength\footskip{0.3in}
\setlength\maxdepth{4\p@} 
\setlength\@maxdepth\maxdepth
\setlength\textwidth{28pc}
\setlength\textheight\typeheight
\setlength\normaltextheight{\textheight}
\setlength\marginparsep {10\p@}
\setlength\marginparpush{5\p@}
\setlength\oddsidemargin  {0.75in}
\setlength\evensidemargin {-\textwidth}
\addtolength\evensidemargin{-\oddsidemargin}
\setlength\marginparwidth {48\p@}
\setlength\footnotesep{6.65\p@}
\setlength{\skip\footins}{12\p@ \@plus 4\p@ \@minus 2\p@}%9
\setlength\floatsep    {12\p@ \@plus 2\p@ \@minus 2\p@}
\setlength\textfloatsep{20\p@ \@plus 2\p@ \@minus 4\p@}
\setlength\intextsep   {12\p@ \@plus 2\p@ \@minus 2\p@}
\setlength\dblfloatsep    {12\p@ \@plus 2\p@ \@minus 2\p@}
\setlength\dbltextfloatsep{20\p@ \@plus 2\p@ \@minus 4\p@}
\setlength\@fptop{0\p@ \@plus 1fil}
\setlength\@fpsep{8\p@ \@plus 2fil}
\setlength\@fpbot{0\p@ \@plus 1fil}
\setlength\@dblfptop{0\p@ \@plus 1fil}
\setlength\@dblfpsep{8\p@ \@plus 2fil}
\setlength\@dblfpbot{0\p@ \@plus 1fil}
\setlength\partopsep{2\p@ \@plus 1\p@ \@minus 1\p@}
%
%
\def\@listi{\leftmargin\leftmargini
            \parsep 4\p@ \@plus2\p@ \@minus\p@
            \topsep 8\p@ \@plus2\p@ \@minus4\p@
            \itemsep4\p@ \@plus2\p@ \@minus\p@}
\let\@listI\@listi
\@listi
\def\@listii {\leftmargin\leftmarginii
              \labelwidth\leftmarginii
              \advance\labelwidth-\labelsep
              \topsep    4\p@ \@plus2\p@ \@minus\p@
              \parsep    2\p@ \@plus\p@  \@minus\p@
              \itemsep   \parsep}
\def\@listiii{\leftmargin\leftmarginiii
              \labelwidth\leftmarginiii
              \advance\labelwidth-\labelsep
              \topsep    2\p@ \@plus\p@\@minus\p@
              \parsep    \z@
              \partopsep \p@ \@plus\z@ \@minus\p@
              \itemsep   \topsep}
\def\@listiv {\leftmargin\leftmarginiv
              \labelwidth\leftmarginiv
              \advance\labelwidth-\labelsep}
\def\@listv  {\leftmargin\leftmarginv
              \labelwidth\leftmarginv
              \advance\labelwidth-\labelsep}
\def\@listvi {\leftmargin\leftmarginvi
              \labelwidth\leftmarginvi
              \advance\labelwidth-\labelsep}
%
\setlength\lineskip{1\p@}
\setlength\normallineskip{1\p@}
\renewcommand\baselinestretch{}
\setlength\parskip{0\p@}
\@lowpenalty   51
\@medpenalty  151
\@highpenalty 301
%
\setcounter{topnumber}{3}
\def\topfraction{.98}
\setcounter{bottomnumber}{3}
\def\bottomfraction{.98}
\setcounter{totalnumber}{6}%4
\def\textfraction{.01}
\def\floatpagefraction{.98100}
\setcounter{dbltopnumber}{2}
\def\dbltopfraction{.981}
\def\dblfloatpagefraction{.99}
%
\def\ps@headings{%
      \let\@oddfoot\@empty\let\@evenfoot\@empty
      \def\@evenhead{\thepage\hfil\slshape\leftmark}%
      \def\@oddhead{{\slshape\rightmark}\hfil\thepage}%
      \let\@mkboth\markboth
    \def\sectionmark##1{%
      \markboth {\MakeUppercase{%
        \ifnum \c@secnumdepth >\z@
          \thesection\quad
        \fi
        ##1}}{}}%
    \def\subsectionmark##1{%
      \markright {%
        \ifnum \c@secnumdepth >\@ne
          \thesubsection\quad
        \fi
        ##1}}}
%
\def\ps@plain{\let\@mkboth\@gobbletwo
     \let\@oddhead\@empty
	\def\@oddfoot{\lower2pc\hbox{\fbox{\hbox to \hsize{\reset@font\rightnote\hfill {\bf \thepage}}}}}
\let\@evenhead\@empty\let\@evenfoot\@oddfoot}
%
\def\ps@myheadings{%
    \let\@oddfoot\@empty\let\@evenfoot\@empty
    \def\@evenhead{\thepage\hfil\slshape\leftmark}%
    \def\@oddhead{{\slshape\rightmark}\hfil\thepage}%
    \let\@mkboth\@gobbletwo
    \let\sectionmark\@gobble
    \let\subsectionmark\@gobble
}%   
%
\newcommand\maketitle{\par
  \begingroup
    \renewcommand\thefootnote{\@fnsymbol\c@footnote}%
    \def\@makefnmark{\rlap{\@textsuperscript{\normalfont\@thefnmark}}}%
    \long\def\@makefntext##1{\parindent 1em\noindent
            \hb@xt@1.8em{%
                \hss\@textsuperscript{\normalfont\@thefnmark}}##1}%
 \if@twocolumn
      \ifnum \col@number=\@ne
        \@maketitle
      \else
        \twocolumn[\@maketitle]%
      \fi
    \else
      \newpage
      \global\@topnum\z@   % Prevents figures from going at top of page.
      \@maketitle
    \fi
    \thispagestyle{plain}\@thanks
  \endgroup
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}
%
\def\title#1{\gdef\@title{\uppercase{#1}}}
\def\@title{\@latex@error{No \expand\title given}\@ehc}
%%
\def\@maketitle{%
  \newpage
  \null
%  \vskip 2em%
\vspace*{-14pt}
  \begin{center}%
  \let \footnote \thanks
    {\bf \@title \par}%
    \vskip 2em%
   \@aabuffer
\end{center}%
 \par}
%  \vskip 1.5em}
%
\def\@aabuffer{}
\def\author #1{\expandafter\def\expandafter\@aabuffer\expandafter
	{\@aabuffer\small\rm\uppercase{#1}\relax\par
	\vspace*{2pt}}}%\vspace{0.75em}
\def\address#1{\expandafter\def\expandafter\@aabuffer\expandafter
	{\@aabuffer\small\it #1\relax\par
	\vspace*{10pt}}}
%
\setcounter{secnumdepth}{2}
\newcounter {section}
\newcounter {subsection}[section]
\renewcommand\thesection      {\@arabic\c@section}
\renewcommand\thesubsection   {\thesection.\@arabic\c@subsection}
%
\newcommand\section{\@startsection {section}{1}{\z@}%
                                   {-3.50ex \@plus -1ex \@minus -.2ex}%
                                   {2.3ex \@plus.2ex}%
                                   {\rightskip1pc plus1fil\normalfont\normalsize\bfseries}}
\newcommand\subsection{\@startsection{subsection}{2}{\z@}%
                                     {-3.25ex\@plus -1ex \@minus -.2ex}%
                                     {1.5ex \@plus .2ex}%
                                     {\rightskip1pc plus1fil\normalfont\normalsize\it }}
%
\setlength\leftmargini  {2em}
\leftmargin  \leftmargini
\setlength\leftmarginii  {2.2em}
\setlength\leftmarginiii {1.87em}
\setlength\leftmarginiv  {1.7em}
\setlength\leftmarginv  {.5em}
\setlength\leftmarginvi {.5em}
\setlength  \labelsep  {.5em}
\setlength  \labelwidth{\leftmargini}
\addtolength\labelwidth{-\labelsep}
\@beginparpenalty -\@lowpenalty
\@endparpenalty   -\@lowpenalty
\@itempenalty     -\@lowpenalty
\renewcommand\theenumi{\@arabic\c@enumi}
\renewcommand\theenumii{\@alph\c@enumii}
\renewcommand\theenumiii{\@roman\c@enumiii}
\renewcommand\theenumiv{\@Alph\c@enumiv}
\newcommand\labelenumi{\theenumi.}
\newcommand\labelenumii{(\theenumii)}
\newcommand\labelenumiii{\theenumiii.}
\newcommand\labelenumiv{\theenumiv.}
\renewcommand\p@enumii{\theenumi}
\renewcommand\p@enumiii{\theenumi(\theenumii)}
\renewcommand\p@enumiv{\p@enumiii\theenumiii}
\newcommand\labelitemi{$\m@th\bullet$}
\newcommand\labelitemii{\normalfont\bfseries --}
\newcommand\labelitemiii{$\m@th\ast$}
\newcommand\labelitemiv{$\m@th\cdot$}
\newenvironment{description}
               {\list{}{\labelwidth\z@ \itemindent-\leftmargin
                        \let\makelabel\descriptionlabel}}
               {\endlist}
\newcommand*\descriptionlabel[1]{\hspace\labelsep
                                \normalfont\bfseries #1}
%

\def\abstracts#1{
\begin{center}
{\begin{minipage}{4.2truein}
                 \footnotesize
                 \parindent=0pt #1\par
                 \end{minipage}}\end{center}
                 \vskip 2em \par}

\newenvironment{quotation}
               {\list{}{\listparindent 1.5em%
                        \itemindent    \listparindent
                        \rightmargin   \leftmargin
                        \parsep        \z@ \@plus\p@}%
                \item\relax}
               {\endlist}
%
\newenvironment{quote}
               {\list{}{\rightmargin\leftmargin}%
                \item\relax}
               {\endlist}
%
%FOLLOWING THREE COMMANDS ARE FOR `LIST' COMMAND.
\topsep=0in
\parsep=0in
\itemsep=0in
%
\newcounter{arabiclistc}
\newenvironment{arabiclist}
	{\setcounter{arabiclistc}{0}
	 \begin{list}{\arabic{arabiclistc}}
	{\usecounter{arabiclistc}
	 \setlength{\parsep}{0pt}
	 \setlength{\itemsep}{0pt}}}{\end{list}}
%
%ACKNOWLEDGEMENT: this portion is from John Hershberger 
%
\def\@citex[#1]#2{\if@filesw\immediate\write\@auxout
	{\string\citation{#2}}\fi
\def\@citea{}\@cite{\@for\@citeb:=#2\do
	{\@citea\def\@citea{,}\@ifundefined
	{b@\@citeb}{{\bf ?}\@warning
	{Citation `\@citeb' on page \thepage \space undefined}}
	{\csname b@\@citeb\endcsname}}}{#1}}
%
\newif\if@cghi
\def\cite{\@cghitrue\@ifnextchar [{\@tempswatrue
	\@citex}{\@tempswafalse\@citex[]}}
\def\citelow{\@cghifalse\@ifnextchar [{\@tempswatrue
	\@citex}{\@tempswafalse\@citex[]}}
\def\@cite#1#2{{$^{#1}$\if@tempswa\typeout
	{IJCGA warning: optional citation argument 
	ignored: `#2'} \fi}}
\newcommand{\citeup}{\cite}
%
\newcommand\appendix{\par
  \setcounter{section}{0}%
  \setcounter{subsection}{0}%
  \renewcommand\thesection{\@Alph\c@section}
	\section*{\appendixname}}
%
\setlength\arraycolsep{1.5\p@}%5pt
\setlength\tabcolsep{6\p@}
\setlength\arrayrulewidth{.4\p@}
\setlength\doublerulesep{2\p@}
\setlength\tabbingsep{\labelsep}
\skip\@mpfootins = \skip\footins
\setlength\fboxsep{3\p@}
\setlength\fboxrule{.4\p@}
\renewcommand\theequation{\@arabic\c@equation}
%%
\InputIfFileExists{psfig.sty}{}{}
\InputIfFileExists{epsf.sty}{}{}
\InputIfFileExists{epsfsafe.tex}{}{}
\InputIfFileExists{epsfig.sty}{}{}
%
\newcounter{figure}
\renewcommand\thefigure{\@arabic\c@figure}
\def\fps@figure{tbp}
\def\ftype@figure{1}
\def\ext@figure{lof}
\def\fnum@figure{\figurename~\thefigure}
\newenvironment{figure}
               {\@float{figure}}
               {\end@float}
\newenvironment{figure*}
               {\@dblfloat{figure}}
               {\end@dblfloat}
%
\newcounter{table}
\renewcommand\thetable{\@arabic\c@table}
\def\fps@table{tbp}
\def\ftype@table{2}
\def\ext@table{lot}
\def\fnum@table{\tablename~\thetable}
\newenvironment{table}
               {\@float{table}}
               {\end@float}
\newenvironment{table*}
               {\@dblfloat{table}}
               {\end@dblfloat}
%
\newlength\abovecaptionskip
\newlength\belowcaptionskip
\setlength\abovecaptionskip{10\p@}
\setlength\belowcaptionskip{6\p@}
\def\captionfont{\normalfont\footnotesize{}}
\long\def\@makecaption#1#2{%
	\captionfont
 \vskip\abovecaptionskip
  \sbox\@tempboxa{#1.\hskip.5em#2}%
  \ifdim \wd\@tempboxa >\hsize
    \noindent #1.\hskip.5em#2\par
  \else
    \global \@minipagefalse
    \hb@xt@\hsize{\hfil\box\@tempboxa\hfil}%
  \fi
  \vskip\belowcaptionskip}
%
\def\figurebox#1#2#3{%
  	\def\arg{#3}%
  	\ifx\arg\empty
  	{\hfill\vbox{\hsize#2\hrule\hbox to #2{\vrule\hfill\vbox to #1{\hsize#2\vfill}\vrule}\hrule}\hfill}%
  	\else
   	{\hfill\epsfbox{#3}\hfill}% 
  	\fi}
%
\def\@figurecaption#1#2{\unskip\vskip10pt{#1.\hskip.5em#2\par}}
%
\DeclareOldFontCommand{\rm}{\normalfont\rmfamily}{\mathrm}
\DeclareOldFontCommand{\sf}{\normalfont\sffamily}{\mathsf}
\DeclareOldFontCommand{\tt}{\normalfont\ttfamily}{\mathtt}
\DeclareOldFontCommand{\bf}{\normalfont\bfseries}{\mathbf}
\DeclareOldFontCommand{\it}{\normalfont\itshape}{\mathit}
\DeclareOldFontCommand{\sl}{\normalfont\slshape}{\@nomath\sl}
\DeclareOldFontCommand{\sc}{\normalfont\scshape}{\@nomath\sc}
\DeclareRobustCommand*\cal{\@fontswitch\relax\mathcal}
\DeclareRobustCommand*\mit{\@fontswitch\relax\mathnormal}
\newcommand\@pnumwidth{1.55em}
\newcommand\@tocrmarg{2.55em}
\newcommand\@dotsep{4.5}
%
\newenvironment{thebibliography}[1]
	{\section*{\refname}
	\begin{list}{\arabic{enumi}.}
	{\usecounter{enumi}\setlength{\parsep}{0pt}
	 \setlength{\itemsep}{0pt} \settowidth
	{\labelwidth}{#1.}\sloppy}}{\end{list}}
%%
\newenvironment{theindex}
               {\if@twocolumn
                  \@restonecolfalse
                \else
                  \@restonecoltrue
                \fi
                \columnseprule \z@
                \columnsep 35\p@
                \twocolumn[\section*{\indexname}]%
                \@mkboth{\MakeUppercase\indexname}%
                        {\MakeUppercase\indexname}%
                \thispagestyle{plain}\parindent\z@
                \parskip\z@ \@plus .3\p@\relax
                \let\item\@idxitem}
               {\if@restonecol\onecolumn\else\clearpage\fi}
\newcommand\@idxitem{\par\hangindent 40\p@}
\newcommand\subitem{\@idxitem \hspace*{20\p@}}
\newcommand\subsubitem{\@idxitem \hspace*{30\p@}}
\newcommand\indexspace{\par \vskip 10\p@ \@plus5\p@ \@minus3\p@\relax}
%
\renewcommand\footnoterule{%
  \kern-3\p@
  \hrule\@width.4\columnwidth
  \kern2.6\p@}
\newcommand\@makefntext[1]{%
    \parindent 1em%
    \noindent
     \@makefnmark#1}
%
\def\thefootnote{\alph{footnote}}
\def\@makefnmark{{$^{\@thefnmark}$}}
%
\newcommand\contentsname{Contents}
\newcommand\listfigurename{List of Figures}
\newcommand\listtablename{List of Tables}
\newcommand\refname{References}
\newcommand\indexname{Index}
\newcommand\figurename{Figure}
\newcommand\tablename{Table}
\newcommand\partname{Part}
\newcommand\appendixname{Appendix}
\newcommand\abstractname{Abstract}
%
\def\rightnote{{\it \jobname : submitted to  {\bf World Scientific} on \today}}%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% definitions retained from the latex2.09 file %%%%%%%%
%
\bibliographystyle{unsrt}    % for BibTeX - sorted numerical labels by order of
                             % first citation.
\arraycolsep1.5pt
% A useful Journal macro
\def\Journal#1#2#3#4{{#1} {\bf #2}, #3 (#4)}

% Some useful journal names
\def\NCA{\em Nuovo Cimento}
\def\NIM{\em Nucl. Instrum. Methods}
\def\NIMA{{\em Nucl. Instrum. Methods} A}
\def\NPB{{\em Nucl. Phys.} B}
\def\PLB{{\em Phys. Lett.}  B}
\def\PRL{\em Phys. Rev. Lett.}
\def\PRD{{\em Phys. Rev.} D}
\def\ZPC{{\em Z. Phys.} C}
% Some other macros used in the sample text
\def\st{\scriptstyle}
\def\sst{\scriptscriptstyle}
\def\mco{\multicolumn}
\def\epp{\epsilon^{\prime}}
\def\vep{\varepsilon}
\def\ra{\rightarrow}
\def\ppg{\pi^+\pi^-\gamma}
\def\vp{{\bf p}}
\def\ko{K^0}
\def\kb{\bar{K^0}}
\def\al{\alpha}
\def\ab{\bar{\alpha}}
\def\be{\begin{equation}}
\def\ee{\end{equation}}
\def\bea{\begin{eqnarray}}
\def\eea{\end{eqnarray}}
\def\CPbar{\hbox{{\rm CP}\hskip-1.80em{/}}}%temp replacement due to no font
%
\arraycolsep1.5pt
%
%%%%%%%%%%%%%%%%
%
\newcommand\today{}
\edef\today{\ifcase\month\or
  January\or February\or March\or April\or May\or June\or
  July\or August\or September\or October\or November\or December\fi
  \space\number\day, \number\year}
\setlength\columnsep{0.25in}
\setlength\columnseprule{0\p@}
\pagestyle{plain}
\pagenumbering{arabic}
\sloppy
\onecolumn
\flushbottom
\endinput
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%




