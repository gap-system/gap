% ACMCONF DOCUMENT CLASS
%    adapted from ARTICLE document style by Ken Traub
%    Hacked for [preprint] option by Olin Shivers 4/91
%    Fixed up for LaTeX version 2e [compatibility mode] by Peter Lee 10/9
%       (with help from Simon Peyton Jones)
%    Converted to a LaTeX2e document class by David A. Berson 11/94
%
% ARTICLE DOCUMENT STYLE -- Released 16 March 1988
%    for LaTeX version 2.09
% Copyright (C) 1988 by Leslie Lamport

% To do:
%  - Possibly move the commands related to 9pt size to a file size9.clo
%    and write the stuff to unpack both acmconf.cls and size9.clo files
%    from a single distribution file.

%%% ACMCONF is a document class for producing two-column camera-ready pages for
%%% ACM conferences, according to ACM specifications.  The main features of
%%% this class are:
%%%
%%% 1)  Two columns.
%%% 2)  Side and top margins of 4.5pc, bottom margin of 7.5pc, column gutter of
%%%     2pc, hence columns are 20pc wide and 54pc tall.  (6pc = 1in, approx)
%%% 3)  First page has title information, and an extra 4.5pc of space at the
%%%     bottom of the first column for the ACM copyright notice. (You must
%%%     use one of the commands \copyrightspace or \toappear{} to obtain this
%%%     space.)
%%% 4)  Text is 9pt on 10pt baselines; titles are 9pt bold sans-serif.
%%%     (The acmconf.sty from which acmconf.cls was derived actually uses
%%%     9pt bold roman for section titles.  Functionally, I have left this
%%%     as is.  I have added a commented out alternate defination of
%%%     \acmtitlestyle that uses sans-serif)  --DAB
%%%
%%% This document class supports a [preprint] class option that allows you
%%% to run off a copy for a preprint -- with page numbers, "to appear"
%%% information, and so forth. This is documented below.

%%% There are a few restrictions you must observe:
%%%
%%% 1)  You cannot change the font size; ACM wants you to use 9pt.
%%% 3)  You must start your paper with the \maketitle command.  Prior to the
%%%     \maketitle you must have \title and \author commands.  If you have a
%%%     \date command it will be ignored; no date appears on the paper, since
%%%     the proceedings will have a date on the front cover.
%%%     Optionally, you may have an \affiliation command with text, such
%%%     as company or university name and address, that will be centered
%%%     just below the author(s).
%%% 4)  Marginal paragraphs, tables of contents, lists of figures and tables,
%%%     and page headings are all forbidden.
%%% 5)  The `figure' environment will produce a figure one column wide; if you
%%%     want one that is two columns wide, use `figure*'.  Ditto for the
%%%     `table' and `table*' environments.
%%%
%%% Page Headings:
%%% Normally, \pagestyle commands are ignored --- pages have no headings or
%%% numbers. ACM will number the pages for you when they are inserted into the
%%% proceedings (you should put page numbers on the BACK of each page, though,
%%% in case someone drops your paper on the floor).
%%%
%%% If the [preprint] option is present, then \pagestyle commands are obeyed,
%%% and the default is \pagestyle{plain}. The [twoside] option is also
%%% useful when using headers.
%%%
%%% The [draft] and [final] options as used in the article class are also
%%% supported.
%%%
%%%
%%% Copyright Space:
%%% You leave space at the bottom of page 1/column 1 one with the
%%% \copyrightspace command.  Alternatively, you can use the
%%% \toappear{...} command.  Normally, this turns into an unnumbered
%%% footnote 4.5pc high.  If [preprint] is on, then this space is
%%% filled with the {...} text; otherwise, it's blank. You must put
%%% one of these commands in the text of page 1/column 1 *after* all the
%%% other footnotes that go on page1/column 1, of course.
%%%
%%% A typical usage looks like this:
%%%     \toappear{To appear in the Ninth AES Conference on Midevil Lithuanian
%%%               Embalming Technique, June 1991, Alfaretta, Georgia.
%%%               Also available as Technical Report CMU-CS-91-119,
%%%               Cranberry Melon School of Cucumber Science.}
%%% This will be included in the preprint, and left out of the conference
%%% version.
%%%
%%% Acmconf defines two useful conditionals.
%%% - \ifacmconf{true-stuff}{false-stuff}
%%%   expands to true-stuff.
%%% - \ifpreprint true-stuff \else else-stuff \fi
%%%   expands to true-stuff if the [preprint] option is being used,
%%%   otherwise it expands to else-stuff.
%%% \ifacmconf is a latex command; \ifpreprint is a real latex conditional.
%%%
%%% WARNING:
%%% Some dvi-ps converters heuristically allow chars to drift from their
%%% true positions a few pixels. This loses noticeably with the 9pt sans-serif
%%% bold font used for section headers. You turn this hackery off in our
%%% dvi-ps converters with the -e option:
%%%     dvips -e 0 foo.dvi >foo.ps

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{acmconf}[1994/11/27 Alternative LaTeX document class]
\typeout{Bugs to berson@cs.pitt.edu}

%
% Define the conditionals and command for the options.
%
\newif\if@acmconf\@acmconftrue
\long\def\ifacmconf#1#2{\if@acmconf#1\else#2\fi}
\newif\ifpreprint

%
% Declare and process the options
%
\DeclareOption{draft}{\PassOptionsToClass{draft}{article}}
\DeclareOption{final}{\PassOptionsToClass{final}{article}}
\DeclareOption{twocolumn}{\PassOptionsToClass{twocolumn}{article}}
\DeclareOption{twoside}{\PassOptionsToClass{twoside}{article}}
\DeclareOption{preprint}{\preprintfalse}
%\DeclareOption{preprint}{\preprinttrue}
%
% Let them off with just a warning for any other option
%
\DeclareOption*{\ClassWarningNoLine{acmconf}{Unknown option `\CurrentOption'}}
%\DeclareOption*{\ClassError{acmconf}
%   {The `\CurrentOption' option is not supported}
%   {Remove the `\CurrentOption' option from the
%    \protect\documentclass\space line.}}

\ExecuteOptions{twocolumn}
\ProcessOptions

%
% This class simply modifies a few behaviors of the article class,
% so load it now
%
\LoadClass{article}


%**********************************************************************
%
% The following commands would normally be in a file such as
% size9.clo for the article class.  Since the size isn't really an
% option, I include them here.  I have followed the order of the commands
% as found in size10.clo.
%
% I could test for the presence of % the file size9.clo and load it when
% availale, instead of executing these commands.
%

%
% Set the font sizes and spacing
%
\renewcommand\baselinestretch{1}

\renewcommand\normalsize{%
   \@setfontsize\normalsize\@ixpt\@xpt 
   \abovedisplayskip 9\p@ \@plus2\p@ \@minus4.5\p@%
   \abovedisplayshortskip  \z@ \@plus3\p@%
   \belowdisplayshortskip  5.4\p@ \@plus3\p@ \@minus3\p@%
   \belowdisplayskip \abovedisplayskip
   \let\@listi\@listI}
\normalsize
\renewcommand\small{%
   \@setfontsize\small\@viiipt{9}%
   \abovedisplayskip 7.6\p@ \@plus 3\p@ \@minus 4\p@%
   \abovedisplayshortskip \z@ \@plus2\p@%
   \belowdisplayshortskip 3.6\p@ \@plus2\p@ \@minus 2\p@
   \def\@listi{\leftmargin\leftmargini
                \topsep 4\p@ \@plus 2\p@ \@minus 2\p@
                \parsep 2\p@ \@plus 1\p@ \@minus 1\p@
                \itemsep \parsep}
   \belowdisplayskip \abovedisplayskip
}
\renewcommand\footnotesize{%
   \@setfontsize\footnotesize\@viipt{8}
   \abovedisplayskip 6.4\p@ \@plus 2\p@ \@minus 4\p@%
   \abovedisplayshortskip \z@ \@plus 1\p@%
   \belowdisplayshortskip 2.7\p@ \@plus 1\p@ \@minus 2\p@
   \def\@listi{\leftmargin\leftmargini
               \topsep 3\p@ \@plus 1\p@ \@minus 1\p@
               \parsep 2\p@ \@plus 1\p@ \@minus 1\p@
               \itemsep \parsep}%
   \belowdisplayskip \abovedisplayskip
}
\renewcommand\scriptsize{\@setfontsize\scriptsize\@viipt{8pt}}
\renewcommand\tiny{\@setfontsize\tiny\@vpt{6pt}}
\renewcommand\large{\@setfontsize\large\@xipt{13.6\p@}}
\renewcommand\Large{\@setfontsize\Large\@xiipt{14\p@}}
\renewcommand\LARGE{\@setfontsize\LARGE\@xivpt{18\p@}}
\renewcommand\huge{\@setfontsize\huge\@xviipt{22\p@}}
\renewcommand\Huge{\@setfontsize\Huge\@xxpt{25\p@}}

\setlength\parindent{13.5\p@}    % This is what normally used for one
                                 % column.  Should it be 1em for us?
\setlength\headheight{0\p@}
\setlength\headsep{0\p@}
\setlength\headheight{0\p@}
\setlength\headsep{0\p@}
\setlength\footskip{30\p@}
%
% There was no \topskip or \@maxdepth in the original acmconf.sty.
% Thus, we inherit 
%\topskip 10pt 
%\maxdepth .5\topskip
% from size10.clo loaded via article.cls
%
\setlength\textwidth{42pc}
\setlength\textheight{650\p@}
\setlength\oddsidemargin{4.5pc}
\addtolength\oddsidemargin{-1in}    % Correct for LaTeX gratuittousness
\setlength\evensidemargin{4.5pc}
\addtolength\evensidemargin{-1in}   % Correct for LaTeX gratuittousness
\setlength\marginparwidth{0\p@}     % Margin pars are not allowed.
\setlength\marginparsep{11\p@}
\setlength\marginparpush{5\p@}
\setlength\topmargin{4.5pc}
\addtolength\topmargin{-1in}         % Correct for LaTeX gratuitousness
%
% I wonder if these next three lines should only be executed if
% the preprint option is in effect?  -- DAB
%
%% Must redefine the top margin so there's room for headers and
%% page numbers if you are using the preprint option. Footers
%% are OK as is. Olin.
\addtolength\topmargin{-37\p@} % Leave 37pt above text for headers
\setlength\headheight{12\p@}
\setlength\headsep{25\p@}

\setlength\footnotesep{5.6\p@}
\setlength{\skip\footins}{8.1\p@ \@plus 4\p@ \@minus 2\p@}
\setlength\floatsep{11\p@ \@plus 2\p@ \@minus 2\p@}
\setlength\textfloatsep{18\p@ \@plus 2\p@ \@minus 4\p@}
\setlength\intextsep{11\p@ \@plus 2\p@ \@minus 2\p@}
\setlength\dblfloatsep{11\p@ \@plus 2\p@ \@minus 2\p@}
\setlength\dbltextfloatsep{18\p@ \@plus 2\p@ \@minus 4\p@}
%
% These values will be inherited from the default size10.clo file
% included when we load the base article class.  I include them
% here for completeness in case we split out the size9.clo file someday.
%   --DAB
\setlength\@fptop{0\p@ \@plus 1fil}
\setlength\@fpsep{8\p@ \@plus 2fil}
\setlength\@fpbot{0\p@ \@plus 1fil}
\setlength\@dblfptop{0\p@ \@plus 1fil}
\setlength\@dblfpsep{8\p@ \@plus 2fil}
\setlength\@dblfpbot{0\p@ \@plus 1fil}
\setlength\partopsep{2\p@ \@plus 1\p@ \@minus 1\p@}
%
% I think that all of these should be renewcommands.  I also think
% that \setlength should be used.  But, they are not in the size10.clo
% file that I am following.   --DAB
%
\renewcommand\@listI{\leftmargin\leftmargini 
                     \parsep 3.6\p@ \@plus 2\p@ \@minus 1\p@%
                     \topsep 7.2\p@ \@plus 2\p@ \@minus 4\p@%
                     \itemsep 3.6\p@ \@plus 2\p@ \@minus 1\p@}
\let\@listi\@listI
\@listi
\def\@listii {\leftmargin\leftmarginii
              \labelwidth\leftmarginii
              \advance\labelwidth-\labelsep
              \topsep 3.6\p@ \@plus 2\p@ \@minus 1\p@
              \parsep 1.8\p@ \@plus 0.9\p@ \@minus 0.9\p@
              \itemsep \parsep}
\def\@listiii{\leftmargin\leftmarginiii
              \labelwidth\leftmarginiii
              \advance\labelwidth-\labelsep
              \topsep 1.8\p@ plus 0.9\p@ minus 0.9\p@
              \parsep \z@
              \partopsep 1\p@ plus 0\p@ minus 1\p@
              \itemsep \topsep}
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
% End of the "size9.clo" commands
%**********************************************************************

%
% here's a few things that I didn't find in either article.cls or
% size10.clo, so I left them here.  --DAB
%
\setlength\columnsep{2pc}          %    Space between columns
\setlength\columnseprule{0\p@}     %    Width of rule between columns.
\hfuzz 1pt               % Allow some variation in column width, otherwise it's
                         % too hard to typeset in narrow columns.


%**********************************************************************
%
% Now we get on with overriding things found in article.cls
%
\setlength\parindent{13.5\p@}

%
% This command is used to format section headings.  The format is the only
% thing that differs between these section commands and the ones in
% article.cls.
%
% Although the original documentation says that sans-serif is supposed to be
% used for section titles, the file as I received uses roman.  The
% commented out line implements sans-serif.  Be sure to comment out the
% \bfseries line if you switch.
%   --DAB
%
\newcommand\@acmtitlestyle{\normalsize\bfseries}
%\newcommand\@acmtitlestyle{\normalsize\sffamily}

\renewcommand\section{\@startsection {section}{1}{\z@}%
                                     {-3.5ex \@plus -1ex \@minus -.2ex}%
                                     {2.3ex \@plus .2ex}%
                                     {\@acmtitlestyle}}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
                                       {-3.25ex \@plus -1ex \@minus -.2ex}%
                                       {1.5ex \@plus .2ex}%
                                       {\@acmtitlestyle}}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
                                          {-3.25ex \@plus -1ex \@minus -.2ex}%
                                          {1.5ex \@plus .2ex}%
                                          {\@acmtitlestyle}}
\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
                                      {3.25ex \@plus 1ex \@minus .2ex}%
                                      {-1em}%
                                      {\@acmtitlestyle}}
\renewcommand\subparagraph{\@startsection{subparagraph}{4}{\parindent}%
                                         {3.25ex \@plus 1ex \@minus .2ex}%
                                         {-1em}%
                                         {\@acmtitlestyle}}

\setcounter{secnumdepth}{3}

\setlength\arraycolsep{4.5\p@}
\setlength\tabcolsep{5.4\p@}
\setlength\doublerulesep{1.8\p@}

\setlength\fboxsep{2.7\p@}
\setlength\fboxrule{.4\p@}

\def\tableofcontents{\ClassError{acmconf}%
  {\protect\tableofcontents: Tables of contents are not allowed in the `acmconf' document class}%
  {Remove the \protect\tableofcontents\space command from the file}}

\def\listoffigures{\ClassError{acmconf}%
  {\protect\listoffigures: Lists of figures are not allowed in the `acmconf' document class}%
  {Remove the \protect\listoffigures\space command from the file}}

\def\listoftables{\ClassError{acmconf}%
   {\protect\listoftables: Lists of tables are not allowed in the `acmconf' document class}%
   {Remove the \protect\listoftables\space command from the file}}
\let\l@table\l@figure

%
% Added \@makefntext definition so that the mark would not over print
% the beginning of the \thanks text.  --DAB
%
\def\maketitle{\par
 \begingroup
   \def\thefootnote{\fnsymbol{footnote}}%
   \def\@makefnmark{\hbox to 0pt{$\m@th^{\@thefnmark}$\hss}}%
   \long\def\@makefntext##1{\parindent 1em\noindent
               \hbox to1.8em{\hss$\m@th^{\@thefnmark}$}##1}%
   \if@twocolumn
     \twocolumn[\@maketitle]
     \else \newpage
     \global\@topnum\z@        % Prevents figures from going at top of page.
     \@maketitle \fi
   \thispagestyle{plain}\@thanks  % UE: Changed {empty} to {plain}
 \endgroup
 \setcounter{footnote}{0}
 \let\maketitle\relax
 \let\@maketitle\relax
 \gdef\@thanks{}\gdef\@author{}\gdef\@title{}\gdef\@affili{}\let\thanks\relax}

%
% extra declarations needed for our version of @maketitle
%
\newbox\@acmtitlebox
\gdef\affili{}
\def\affiliation#1{\gdef\affili{#1}}

%
% The modified @maketitle
%
\def\@maketitle{\newpage
 \null
 \setbox\@acmtitlebox\vbox{%
   \vskip 2em                 % Vertical space above title.
   \begin{center}
    {\LARGE \@title \par}     % Title set in \LARGE size.
    \vskip 1.5em                % Vertical space after title.
    {\large                        % each author set in \large, in a
     \lineskip .5em           % tabular environment
     \begin{tabular}[t]{c}\@author
     \end{tabular}\par}
     \vskip 1em
     \begin{center}
       {\large \affili}
     \end{center}
     \vskip 1.5em              % Vertical space after author.
   \end{center}}
 \dimen0=\ht\@acmtitlebox
 \advance\dimen0 by -13.5pc\relax
 \unvbox\@acmtitlebox
 \ifdim\dimen0<0.0pt\relax\vskip-\dimen0\fi}

\long\def\unmarkedfootnote#1{{\long\def\@makefntext##1{##1}\footnotetext{#1}}}

%% Use one of \copyrightspace or \toappear{To appear in the ACM ...}
\def\copyrightspace{\unmarkedfootnote{\vrule height 4.5pc
                                             width  0in depth 0in}}

%% \small is bigger than \footnotesize.
\def\toappear#1%
    {\ifpreprint \unmarkedfootnote{\vrule height 2.25pc%
                                          depth  2.25pc width 0in%
                                   \parbox{2.8in}{\small #1}}%
     \else \copyrightspace \fi}

\def\marginpar{\ClassError{acmconf}%
   {The \protect\marginpar command is not allowed in the `acmconf' document class}%
   {Remove the \protect\marginpar\space command from the file}}

\mark{{}{}}   % Initializes TeX's marks

%% Headings are ignored unless the [preprint] option is in force.
\ifpreprint\else % preprint off -- all \pagestyle commands ==> \pagestyle{empty}.
%  \let\ps@plain\ps@empty  % UE: Commented this line out
  \let\ps@headings\ps@empty
  \let\ps@myheadings\ps@empty
\fi

\raggedbottom               % Ragged bottom

\endinput
%%
%% End of file `acmconf.cls'.
