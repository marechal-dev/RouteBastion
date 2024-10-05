%% This is sbc20.cls
%% Copyright 2020 Sociedade Brasileira de Computação - SBC <publicacoes@sbc.org.br>
%
% This work may be distributed and/or modified under the conditions of the
% LaTeX Project Public License, either version 1.3 of this license or (at
% your option) any later version. The latest version of this license can be
% found at http://www.latex-project.org/lppl.txt and version 1.3 or later
% is part of all distributions of LaTeX version 2005/12/01 or later.
%
% This work has the LPPL maintenance status `maintained'.
%
% The Current Maintainers of this work are Nelson Lago <lago@ime.usp.br>,
% Jose Viterbo Filho <viterbo@ic.uff.br>, and the SBC <publicacoes@sbc.org.br>.
%
% This work consists of the files sbc20.cls, sbc20.bbx, sbc20.cbx,
% sbc20-authordate.bbx, and sbc20-authordate.cbx.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%   OVERVIEW / HOW TO CUSTOMIZE THIS CLASS    %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% While this class was created to address the needs of the SBC, you
% are welcome to adapt it to other uses. Although it is somewhat long
% and, in some parts, complex, customizing it should not be too hard
% if you know where to look. To help you with that, here is an overview
% of the contents (search for the strings before the hyphen to find the
% corresponding code section):
%
%  1. Identification - boilerplate, nothing interesting
%
%  2. Essential tools - etoolbox, xparse, etc., nothing interesting
%
%  3. Sanitize languages - make sure at least Portuguese and English
%     languages are set as class options. This probably/hopefully does
%     not affect other languages, but you may want to check this
%
%  4. Declaration of class options - just some toggles regarding page
%     numbers, color hyperlinks, and preferred layout
%
%  5. Basic LaTeX parameters and packages - babel, ams, ragged2e,
%     xcolor, parskip, emergencystretch...
%
%  6. Fonts - including FiraSans for the title block, unicode-math or
%     libertinust1-math etc.
%
%  7. Page layout: margins, headers, etc. - geometry and fancyhdr
%
%  8. Sections, environments, lists, captions, spacing - titlesec,
%     enumitem etc. This is where the environments abstract,
%     acks, furtherinformation, fundinginformation, authorinfo,
%     and affiliationdetails are defined (including localization),
%     as well as \sep and the localizations for the "and" string
%     used in lists (\andTwo, \andMany)
%
%  9. Bibliography - load biblatex; a localization-related variable
%     is used here
%
% 10. Footnotes - defines stuff like "titlethanks"; this section
%     is *long*, but there is probably nothing worth changing
%
% 11. Metadata gathering (event name, title, authors & institutions etc.) -
%     this section is *long* and *complex*, but there is probably
%     nothing worth changing except:
%
%     * Collecting some other info with the \metadata or \author
%       commands; just copy/adapt something that is already there
%
%     * When the language is set to Portuguese, we demand an English
%       translation for the title; you may want to extend this to
%       other languages or disable this completely
%
%     * The format of the markers when we use markers to link an
%       author to an institution is set here. Search for a comment
%       that says "Then the fake marker value, formatted"
%
%     * At the very end of this section, we set up the authorinfo,
%       furtherinformation, acks, etc. environments to show up at
%       the end of the document; you may want to relocate something
%
% 12. Hyperlink support and PDF metadata (XMP) - there is some
%     language-related logic here, as well as the link colors
%
% 13. Front matter layout (title, abstract, list of authors etc.) -
%     this section is also long and complex and there is potentially
%     a lot of things to customize, but that should not be too hard
%     if you understand the basics:
%
%     * \maketitle just makes a few preparations and then calls
%       \@SBCtitleblock, which actually defines the structure and
%       appearance of the title block; \@SBCtitleblock should be easy
%       to understand and modify.
%
%     * \@SBCtitleblock uses \@SBCshowInstitutionsAs{Block|Footnotes}
%       and \@SBCshowAuthors to typeset the corresponding lists. These
%       in turn delegate to \@SBCformat{Authors|Institutions}.
%
%     * The \@SBCformatAuthors and \@SBCformatInstitutions macros
%       process each author/institution and build the corresponding
%       formatted text (orcid, name, country etc.) in the \@SBCtext
%       temporary macro. The contents of this macro is appended to
%       \@SBCtextList, which is a LaTeX3 sequence (similar to a python
%       list). It is this list that is typeset by the \@SBCshowAuthors
%       or \@SBCshowInstitutionsAs{Block|Footnotes|EndBlock} macros,
%       which simply iterate over the list of institutions/authors.
%       Therefore, to customize each author or institution formatting,
%       check the \@SBCformat{Authors|Institutions} macros; to customize
%       the presentation of each list as a whole, look into the
%       \@SBCshow... macros.
%
% 14. Auxiliary macros: ORCID and envelope logos - nothing interesting
%
% 15. Auxiliary macros: removeLineBreaksEtc - nothing interesting
%
% 16. Auxiliary macros: squeezeText and related material - nothing interesting


%===============================================================================
% 1. Identification
%===============================================================================

% Because of the bigfoot bugfix mentioned below, we probably
% need at least this version of the LaTeX kernel.
\NeedsTeXFormat{LaTeX2e}[2015/01/01]
\ProvidesClass{sbc20}%
[2021/01/12 v2.0beta1 SBC (Brazilian Computer Society) articles]


%===============================================================================
% 2. Essential tools
%===============================================================================

% Extra TeX development commands
\RequirePackage{etoolbox}

% LaTeX 3 extensions
\RequirePackage{expl3}
\RequirePackage{xparse}

% Identify engine in use (pdftex, luatex, xetex)
\RequirePackage{iftex}

% String manipulation
\RequirePackage{xstring}
\RequirePackage{trimspaces}

% Arithmetic expressions in \set{length,counter} & \addto{length,counter};
% commands \widthof, \heightof, \depthof, \totalheightof, \settototalheight
\usepackage{calc}

% Backport (from LaTeX release 2018-11-28) the fix for this bug:
% https://github.com/latex3/latex2e/issues/94 . If the patch cannot
% be applied, this means we have a version of LaTeX that already
% incorporates it.
\patchcmd\@combinedblfloats{\box\@outputbox}{\unvbox\@outputbox}{}{}


%===============================================================================
% 3. Sanitize languages
%===============================================================================

\ExplSyntaxOn

% We need to have at least some variant of Portuguese and of English
% loaded to generate the abstract/resumo.
%
% babel traditionally uses "portuguese", "brazilian", "portugues", or
% "brazil" to support the Portuguese language, using .ldf files. babel
% is also in the process of implementing a new scheme, using .ini
% files, based on the concept of "locales" instead of "languages". This
% mechanism uses the names "portuguese-portugal", "portuguese-brazil",
% "portuguese-pt", "portuguese-br", "portuguese", "brazilian", "pt",
% "pt-PT", and "pt-BR" (i.e., neither "portugues" nor "brazil"). To avoid
% compatibility problems, let's stick with "brazilian" or "portuguese"
% by substituting portugues and brazil if necessary.

\seq_gclear_new:N \l_tmpa_seq
\seq_gclear_new:N \l_tmpb_seq
\seq_gset_from_clist:NN \l_tmpa_seq \@classoptionslist

% First, make sure any instances of "portugues" and "brazil" are replaced
% by "portuguese" and "brazilian"; other options are unchanged.
\seq_map_inline:Nn \l_tmpa_seq {
  \def\@tempa{#1}
  \ifstrequal{portugues}{#1}
    {
      \ClassWarning{sbc20}{Substituting~language~portugues~->~portuguese}
      \def\@tempa{portuguese}
    }
    {}
  \ifstrequal{brazil}{#1}
    {
      \ClassWarning{sbc20}{Substituting~language~brazil~->~brazilian}
      \def\@tempa{brazilian}
    }
    {}
  \seq_gput_right:NV \l_tmpb_seq {\@tempa}
}

% Remove the leftmost duplicates (default is to remove the rightmost ones).
% Necessary in case the user did "portugues,portuguese", "brazil,brazilian"
% or some variation: When we substitute the language, we may end up with the
% exact same language twice, which may mess up the main language selection.
\seq_greverse:N \l_tmpb_seq
\seq_gremove_duplicates:N \l_tmpb_seq
\seq_greverse:N \l_tmpb_seq

% If the user failed to select some variation of English and Portuguese,
% we add them here. We also remember which ones of portuguese/brazilian,
% english/american/british etc. were selected.
\exp_args:Nnx \regex_extract_all:nnNTF
  {\b(portuguese|brazilian)\b}
  {\seq_use:Nn \l_tmpb_seq {,}}
  \l_tmpa_tl
  {
    \tl_reverse:N \l_tmpa_tl
    \xdef\@SBCpt{\tl_head:N \l_tmpa_tl}
  }
  {
    \seq_gput_left:Nn \l_tmpb_seq {brazilian}
    \gdef\@SBCpt{brazilian}
  }

\exp_args:Nnx \regex_extract_all:nnNTF
  {\b(spanish)\b}
  {\seq_use:Nn \l_tmpb_seq {,}}
  \l_tmpa_tl
  {
    \tl_reverse:N \l_tmpa_tl
    \xdef\@SBCes{\tl_head:N \l_tmpa_tl}
  }
  {
    \seq_gput_left:Nn \l_tmpb_seq {spanish}
    \gdef\@SBCes{spanish}
  }

\exp_args:Nnx \regex_extract_all:nnNTF
  {\b(english|american|USenglish|canadian|british|UKenglish|australian|newzealand)\b}
  {\seq_use:Nn \l_tmpb_seq {,}}
  \l_tmpa_tl
  {
    \tl_reverse:N \l_tmpa_tl
    \xdef\@SBCen{\tl_head:N \l_tmpa_tl}
  }
  {
    \seq_put_left:Nn \l_tmpb_seq {english}
    \gdef\@SBCen{english}
  }

\xdef\@classoptionslist{\seq_use:Nn \l_tmpb_seq {,}}

\ExplSyntaxOff


%===============================================================================
% 4. Declaration of class options
%===============================================================================

% Let's pretend this class received these options from the user.
% With this, these options become global and therefore are seen
% by all packages (among them, babel). This may be important if
% some option affects multiple packages.

% We only need the twoside option if we use page numbers, which
% are disabled by default. Still, it causes no harm.

\xdef\@classoptionslist{twoside,twocolumn,11pt,a4paper,\@classoptionslist}
\expandafter\let\csname opt@sbc20.cls\endcsname\@classoptionslist

% Default false
\newtoggle{@SBCblind}
\DeclareOption{blind}{\togglefalse{@SBCblind}}
\DeclareOption{notblind}{\toggletrue{@SBCblind}}

% Default false
\newtoggle{@SBCenglish}
\DeclareOption{english}{\toggletrue{@SBCenglish}}
\DeclareOption{portuguese}{\togglefalse{@SBCenglish}}

% Default false
\newtoggle{@SBCpagenumbers}
\DeclareOption{pagenumbers}{\toggletrue{@SBCpagenumbers}}

\newtoggle{@SBCcolorlinks}
\DeclareOption{colorlinks}{\toggletrue{@SBCcolorlinks}}
\DeclareOption{nocolorlinks}{\togglefalse{@SBCcolorlinks}}

% The title block may use a few different
% layouts, defined by these class options
\newtoggle{@SBCinstitutionsInFootnotes}
\DeclareOption{institutionsInFootnotes}{
  \togglefalse{@SBCinstitutionsInBlock}
  \togglefalse{@SBCinstitutionsInParagraph}
  \toggletrue{@SBCinstitutionsInFootnotes}
  \togglefalse{@SBCinstitutionsAtEnd}
}

\newtoggle{@SBCinstitutionsInBlock}
\DeclareOption{institutionsInBlock}{
  \toggletrue{@SBCinstitutionsInBlock}
  \togglefalse{@SBCinstitutionsInParagraph}
  \togglefalse{@SBCinstitutionsInFootnotes}
  \togglefalse{@SBCinstitutionsAtEnd}
}

\newtoggle{@SBCinstitutionsInParagraph}
\DeclareOption{institutionsInParagraph}{
  \togglefalse{@SBCinstitutionsInBlock}
  \toggletrue{@SBCinstitutionsInParagraph}
  \togglefalse{@SBCinstitutionsInFootnotes}
  \togglefalse{@SBCinstitutionsAtEnd}
}

\newtoggle{@SBCinstitutionsAtEnd}
\DeclareOption{institutionsAtEnd}{
  \togglefalse{@SBCinstitutionsInBlock}
  \togglefalse{@SBCinstitutionsInParagraph}
  \togglefalse{@SBCinstitutionsInFootnotes}
  \toggletrue{@SBCinstitutionsAtEnd}
}

% It does not make sense to use authorsInParagraph
% without one of the grouped institution layouts.
\newtoggle{@SBCauthorsInParagraph}
\DeclareOption{authorsInParagraph}{
  \toggletrue{@SBCauthorsInParagraph}
  \ifboolexpr
    {
      togl {@SBCinstitutionsInBlock} or
      togl {@SBCinstitutionsInParagraph} or
      togl {@SBCinstitutionsInFootnotes} or
      togl {@SBCinstitutionsAtEnd}
    }
    {}
    {\toggletrue{@SBCinstitutionsInParagraph}}
}

\ExecuteOptions{colorlinks}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\LoadClass{article}


%===============================================================================
% 5. Basic LaTeX parameters and packages
%===============================================================================

% There is a lot of discussion about these parameters, but these
% values are very likely to be good choices for most documents.
\tolerance=800
\setlength{\emergencystretch}{1.5em}

% Do not produce warnings for overfull boxes by less than this
\hfuzz=1pt
\vfuzz\hfuzz

% Do not produce warnings for underfull boxes of badness < 1000
\hbadness=1000
\vbadness=1000

\frenchspacing

\flushbottom

% Default is 0pt plus 1pt. With this, the total variation
% range is the same, but we add a little shrinkability.
\setlength{\parskip}{1pt plus .5pt minus .5pt}

% Default for two-column text is a little smaller;
% let's use the single-column default.
\setlength{\parindent}{17pt}

% \baselineskip is 13.6pt, so these amount to 1.1% and 0.7%;
% hopefully such minuscule variations will be completely
% imperceptible. At the same time, on a page with some 40
% lines of text, these add up to plus 6pt minus 4pt, which
% is useful.
\apptocmd{\normalsize}
  {\setlength{\baselineskip}{1\baselineskip plus .15pt minus .1pt}}
  {}{}


% Parameters that influence float placement. We will change these to make
% LaTeX less strict (almost as if "!" was used) and prefer more floats per
% column/page, creating float-only columns/pages only as a last resort.

% Fraction of the column that may be occupied by top floats. Default: 0.7
\renewcommand{\topfraction}{.8}
% Same for dblfloats (page-wide floats in two-column documents). Default: 0.7
%\renewcommand{\dbltopfraction}{.7}
% Fraction of the column that may be occupied by bottom floats. Default: 0.3
%\renewcommand{\bottomfraction}{.3}
% Minimum fraction of the column that should contain text. Default: 0.2
%\renewcommand{\textfraction}{.2}
% Minimum fraction of a float-only column that has to be occupied. Default: 0.5
% floatpagefraction *must* be less than topfraction.
\renewcommand{\floatpagefraction}{.75}
% Same for dblfloats. Default: 0.5
\renewcommand{\dblfloatpagefraction}{.66}
% Maximum number of top floats. Default: 2
\setcounter{topnumber}{3}
% Maximum number of top dblfloats. Default: 2
%\setcounter{dbltopnumber}{2}
% Maximum number of bottom floats. Default: 1
\setcounter{bottomnumber}{2}
% Maximum number of floats per page. Default: 3
\setcounter{totalnumber}{5}


% The ragged2e algorithm should be the LaTeX default for ragged{right,left}...
\RequirePackage[newcommands]{ragged2e}
% ...but not for centered text: it is very unlikely that we want automatic
% hyphenation with centered text. newcommands also messes up float captions
% if the float uses \centering (which is very common). So, let's just return
% \centering and \begin{center} to the default.
\let\centering\LaTeXcentering
\let\center\LaTeXcenter

% Disable useless warnings
% https://tex.stackexchange.com/questions/17659/ragged2e-newcommands-option-produces-underfull-hbox-warnings
\gappto{\raggedright}{\hbadness=\@M}
\gappto{\RaggedRight}{\hbadness=\@M}
\gappto{\raggedleft}{\hbadness=\@M}
\gappto{\RaggedLeft}{\hbadness=\@M}
\gappto{\flushleft}{\hbadness=\@M}
\gappto{\FlushLeft}{\hbadness=\@M}
\gappto{\flushright}{\hbadness=\@M}
\gappto{\FlushRight}{\hbadness=\@M}

% babel likes to be loaded early.
\RequirePackage{babel}
\RequirePackage{iflang}

% Most AMS packages like to be loaded early
\RequirePackage{amssymb}
\RequirePackage{amsthm}
\RequirePackage{amsmath}

\RequirePackage[hyperref,svgnames,x11names,table]{xcolor} % color support

% hyperref likes to be loaded later on but, in case some package
% forces it to be loaded before our explicit \RequirePackage, let's
% make sure these options are set.
\PassOptionsToPackage{
  unicode=true,
  pdfencoding=unicode,
  plainpages=false,
  pdfpagelabels,
  bookmarksopen=true,
  breaklinks=true,
  hyperfootnotes=false, % incompatible with bigfoot
}{hyperref}

% TeXLive 2018 includes microtype version 2.7a and luatex version 1.07.
% This combination triggers a bug:
% https://tex.stackexchange.com/questions/476740/microtype-error-with-lualatex-attempt-to-call-field-warning-a-nil-value
% Let's apply the suggested workaround, which does not have any drawbacks.
% TODO: also check the luatex version before loading this
\ifLuaTeX
  \RequirePackage{luatexbase}
\fi

\RequirePackage{microtype}

% Fix some limitations of dblfloats (\begin{figure*} and \begin{table*})
\RequirePackage{stfloats}

% Default float placement: first, try to put the float where it is
% defined; if that is not possible, try the top of the page; if that
% too is not possible, try the bottom of the page; if that too is not
% possible, defer to the next page (first top, then bottom). If this
% goes on for too long without success, create a page of floats.
\RequirePackage{float}
\floatplacement{table}{htbp}
\floatplacement{figure}{htbp}
\floatplacement{table*}{tbp}
\floatplacement{figure*}{tbp}


%===============================================================================
% 6. Fonts
%===============================================================================

% Let's use only fonts available in OTF format and with math support to ease
% compatibility for authors not using LaTeX. Still, most fonts (including
% libertinus) load textcomp, wich may "borrow" unavailable characters from
% latin modern.
\ifPDFTeX
\else
  \RequirePackage{fontspec}
  \RequirePackage{unicode-math}
\fi

% TODO: document how to install these fonts in windows and
%       consider how to handle the creative commons icons
%       for authors not using LaTeX.

% TODO: Figure out how to handle the size difference between
%       sourcecodepro and libertinus for authors not using LaTeX.

% This package makes FiraSans the default sans font, but we only use
% it in the title block. That is not a problem because the libertinus
% package below also sets the default sans font, overriding FiraSans.
\usepackage[book]{FiraSans}

% The roman and sans fonts. This overrides the previously selected
% FiraSans. If we are using a unicode engine, this also sets the
% math font to libertinus (using unicode-math).
\usepackage[mono=false]{libertinus}

\ifPDFTeX
  \usepackage{libertinust1math} % if not using a unicode engine
\fi

% The teletype font
\RequirePackage[scale=.85]{sourcecodepro}

% TODO: Consider using images to eliminate this font and ensure
%       visual consistency with authors not using LaTeX.
\RequirePackage{ccicons}


%===============================================================================
% 7. Page layout: margins, headers, etc.
%===============================================================================

\RequirePackage{geometry}
\geometry{
  headsep=10pt,
  headheight=28pt, % Two lines in the header of the first page
  columnsep=18pt,
  footskip=18pt,
  left=17.5mm,
  right=17.5mm,
  % This makes the text area height very close to a multiple of \baselineskip
  top=27mm, % ~14mm including header
  bottom=24mm, % ~18mm including footer
  % this is way too narrow, but works acceptably with pdfcomment
  marginparsep=1mm,
  marginpar=15mm,
}

\RequirePackage{fancyhdr}

% Clear all default headers and remove header line
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}

% Define fancy as the default page style and configure it
\pagestyle{fancy}
\fancyhead[L]{\footnotesize\itshape\@shorttitle}
\fancyhead[R]{\footnotesize\itshape\@shortauthor}
% we do not normally insert the page number because it will be added
% later, when producing the proceedings. Still, if needed for some
% reason, it is possible to use a class option to turn numbering on.
\iftoggle{@SBCpagenumbers}
  {
    \fancyfoot[OR]{\thepage}
    \fancyfoot[EL]{\thepage}
  }
  {\fancyfoot{}}

% Configure "plain" page style, used on the first page.
% There is nothing plain about it! :)

\fancypagestyle{plain}{
  % Clear all default headers
  \fancyhf{}
  \lhead[L]{%
    \footnotesize
    \leavevmode \@pubTitle \space (\@pubAcron).%
    \space\textsc{doi}:\space \href{doi.org/\@doi}{\@doi}%
        {}
        {%
            \\[.25em]%
            \bgroup
            \hypersetup{hidelinks}%
            \@articleLicense
            \egroup
        }%
  }
}


%===============================================================================
% 8. Sections, environments, lists, captions, spacing
%===============================================================================

% We do not want hyphenated section/subsection titles and we do not want
% warnings about "underfull box" when things get too ragged. Therefore, we
% (1) temporarily revert \raggedright to the default without ragged2e and
% (2) disable hyphenation.

\RequirePackage[explicit]{titlesec}
\titleformat{\section}
  {%
    \let\raggedright\LaTeXraggedright
    \filright\hyphenrules{nohyphenation}%
    \large\bfseries\mathversion{bold}%
  }
  {\thesection}
  {0.5em}
  {#1}

\titleformat{\subsection}
  {%
    \let\raggedright\LaTeXraggedright
    \filright\hyphenrules{nohyphenation}%
    \normalsize\bfseries\mathversion{bold}%
  }
  {\thesubsection}
  {0.5em}
  {#1}

\titleformat{\subsubsection}
  {%
    \let\raggedright\LaTeXraggedright
    \filright\hyphenrules{nohyphenation}%
    \normalsize\itshape\mathversion{normal}%
  }
  {\thesubsubsection}
  {0.5em}
  {#1}

\titleformat{\paragraph}[runin]
  {%
    \let\raggedright\LaTeXraggedright
    \filright\hyphenrules{nohyphenation}%
    \normalsize\itshape\mathversion{normal}%
  }
  {\theparagraph}
  {0.5em}
  {#1}

\titlespacing*{\section}{0pt}
    {.75\baselineskip plus .5\baselineskip minus .2\baselineskip}
    {.2\baselineskip plus .1\baselineskip minus .1\baselineskip}

\titlespacing*{\subsection}{0pt}
    {.75\baselineskip plus .5\baselineskip minus .2\baselineskip}
    {.2\baselineskip plus .1\baselineskip minus .1\baselineskip}

\titlespacing*{\subsubsection}{0pt}
    {.5\baselineskip plus .2\baselineskip minus .1\baselineskip}
    {.15\baselineskip plus .1\baselineskip}

\titlespacing*{\paragraph}{0pt}
    {.5\baselineskip plus .2\baselineskip minus .1\baselineskip}
    {.5em}


%==============================
% Better spacing for two-column text

\patchcmd{\quotation}
  {\listparindent 1.5em}{\listparindent 17pt}
  {}{\ClassWarning{sbc20}{Failed to adjust quotation spacing}}

\patchcmd{\quotation}
  {\rightmargin\leftmargin}{\leftmargin1.5em\relax\rightmargin1em\relax}
  {}{\ClassWarning{sbc20}{Failed to adjust quotation spacing}}

\patchcmd{\quote}
  {\rightmargin\leftmargin}{\leftmargin1.5em\relax\rightmargin1em\relax}
  {}{\ClassWarning{sbc20}{Failed to adjust quote spacing}}

\patchcmd{\verse}
  {\itemindent -1.5em}{\itemindent -1em}
  {}{\ClassWarning{sbc20}{Failed to adjust verse spacing}}

\patchcmd{\verse}
  {\rightmargin\leftmargin}{\leftmargin1.5em\relax\rightmargin1em\relax}
  {}{\ClassWarning{sbc20}{Failed to adjust verse spacing}}

\patchcmd{\verse}
  {\advance\leftmargin 1.5em}{\advance\leftmargin 1em\relax}
  {}{\ClassWarning{sbc20}{Failed to adjust verse spacing}}


%==============================
% Lists customizations

\RequirePackage{enumitem}
\setlist{noitemsep,labelindent=\parindent}
\setlist[itemize]{labelsep=.3em}
\setlist[enumerate]{labelsep=.35em}
\setlist[itemize,description,1]{leftmargin=\parindent}
\setlist[itemize,2]{leftmargin=.85em,label=\char"BB}
\setlist[description,2]{leftmargin=.85em}
\setlist[itemize,description,3]{leftmargin=.66em}
\setlist[itemize,description,4]{leftmargin=.54em}
\setlist[enumerate,2]{leftmargin=.7em,label=\alph*.}
\setlist[enumerate,3]{leftmargin=.65em,label=\roman*.}
\setlist[enumerate,4]{leftmargin=1.3em,label=\Alph*.}


%==============================
% Captions customizations

\RequirePackage{caption}

% Semibold
% TODO: check how to do this for authors not using LaTeX
\DeclareCaptionFont{sbf}{\LibertinusSerifSB\bfseries}

\captionsetup*{
  justification=justified,
  singlelinecheck=true,
  labelsep=period,
  font={footnotesize,sf},
  labelfont={footnotesize,sbf},
  skip=10pt plus 2pt minus 0pt,
  margin=1em,
}

% Customize threeparttable notes if it is loaded:
\AtEndPreamble{
  \@ifpackageloaded{threeparttable}
    {
      \appto{\TPTnoteSettings}{\footnotesize\itshape}
      \def\TPTtagStyle{\textit}
    }
    {}
}


%=======================================================================
% Abstract

\newenvironment{SBCabstract}
  {\par\justifying
    \list{}{
        \setlength{\topsep}{5pt plus 2pt minus 2pt}
        % Spacing should not change depending on whether
        % the previous paragraph ended or not
        \setlength{\partopsep}{0pt}
        %\leftmargin=0.8cm
        %\rightmargin\leftmargin
        \leftmargin=0pt
        \rightmargin=0.7cm
        \parsep=\z@
        \labelsep=.7em
        \itemindent=\labelsep
        \labelwidth=\z@
        \listparindent=\z@
    }
    \normalfont\small
    \item[{\bfseries\scshape\MakeLowercase{\abstractname}.}]%
  }
  {\endlist\par}


%==============================
% Special environments at the end of the document

\gdef\ackname{Declarations}
\expandafter\addto\csname captions\@SBCen\endcsname{\gdef\declname{Declarations}}
\expandafter\addto\csname captions\@SBCpt\endcsname{\gdef\declname{Declarações complementares}}
\expandafter\addto\csname captions\@SBCes\endcsname{\gdef\declname{Declaraciones complementarias}}
\newenvironment{decl}{\section*{\declname}\small}{}

\gdef\ackname{Acknowledgements}
\expandafter\addto\csname captions\@SBCen\endcsname{\gdef\ackname{Acknowledgements}}
\expandafter\addto\csname captions\@SBCpt\endcsname{\gdef\ackname{Agradecimentos}}
\expandafter\addto\csname captions\@SBCes\endcsname{\gdef\ackname{Agradecimientos}}
\newenvironment{acks}{\subsection*{\ackname}\small}{}

\gdef\furthername{Further relevant information}
\expandafter\addto\csname captions\@SBCen\endcsname{\gdef\furthername{Further relevant information}}
\expandafter\addto\csname captions\@SBCpt\endcsname{\gdef\furthername{Outras informações relevantes}}
\expandafter\addto\csname captions\@SBCes\endcsname{\gdef\furthername{Otra información relevante}}
\newenvironment{furtherinformation}{\subsection*{\furthername}\small}{}

\gdef\fundingname{Funding}
\expandafter\addto\csname captions\@SBCen\endcsname{\gdef\fundingname{Funding}}
\expandafter\addto\csname captions\@SBCpt\endcsname{\gdef\fundingname{Financiamento}}
\expandafter\addto\csname captions\@SBCes\endcsname{\gdef\fundingname{Financiación}}
\newenvironment{fundinginformation}{\subsection*{\fundingname}\small}{}

\gdef\dataname{Availability of data and additional materials}
\expandafter\addto\csname captions\@SBCen\endcsname{\gdef\dataname{Availability of data and additional materials}}
\expandafter\addto\csname captions\@SBCpt\endcsname{\gdef\dataname{Disponibilidade de dados e materiais adicionais}}
\expandafter\addto\csname captions\@SBCes\endcsname{\gdef\dataname{Disponibilidad de datos y materiales adicionales}}
\newenvironment{datainformation}{\subsection*{\dataname}\small}{}

\gdef\contributename{Authors’ contributions}
\expandafter\addto\csname captions\@SBCen\endcsname{\gdef\contributename{Authors’ contributions}}
\expandafter\addto\csname captions\@SBCpt\endcsname{\gdef\contributename{Contribuições dos autores}}
\expandafter\addto\csname captions\@SBCes\endcsname{\gdef\contributename{Contribuciones de los autores}}
\newenvironment{contributeinformation}{\subsection*{\contributename}\small}{}



\AtEndPreamble{
  \ifnumgreater{\value{numberOfAuthors}}{1}
    {
      \gdef\authorinfoname{About the Authors}
      \expandafter\addto\csname captions\@SBCen\endcsname{\gdef\authorinfoname{About the Authors}}
      \expandafter\addto\csname captions\@SBCpt\endcsname{\gdef\authorinfoname{Sobre os autores}}
      \expandafter\addto\csname captions\@SBCes\endcsname{\gdef\authorinfoname{Sobre los autores}}
    }
    {
      \gdef\authorinfoname{About the Author}
      \expandafter\addto\csname captions\@SBCen\endcsname{\gdef\authorinfoname{About the Author}}
      \expandafter\addto\csname captions\@SBCpt\endcsname{\gdef\authorinfoname{Sobre o autor}}
      \expandafter\addto\csname captions\@SBCes\endcsname{\gdef\authorinfoname{Sobre el autor}}
    }
}
\newenvironment{authorinfo}{\section*{\authorinfoname}\small}{}

\AtEndPreamble{
  \ifnumgreater{\value{numberOfAuthors}}{1}
    {
      \gdef\affiliationname{Affiliations}
      \expandafter\addto\csname captions\@SBCen\endcsname{\gdef\affiliationname{Affiliations}}
      \expandafter\addto\csname captions\@SBCpt\endcsname{\gdef\affiliationname{Afiliações}}
      \expandafter\addto\csname captions\@SBCes\endcsname{\gdef\affiliationname{Afiliaciones}}
    }
    {
      \gdef\affiliationname{Affiliation}
      \expandafter\addto\csname captions\@SBCen\endcsname{\gdef\affiliationname{Affiliation}}
      \expandafter\addto\csname captions\@SBCpt\endcsname{\gdef\affiliationname{Afiliação}}
      \expandafter\addto\csname captions\@SBCes\endcsname{\gdef\affiliationname{Afiliación}}
    }
}
\newenvironment{affiliationdetails}
  {
    \section*{\affiliationname}\small
    \begin{list}
      {}
      {
        \rightmargin 0pt
        \parsep 0pt
        \partopsep 0pt
        \topsep 0pt
        \leftmargin 6pt
        \itemindent 0pt
      }%
    \item[]%
  }
  {\end{list}}


%==============================
% List separators

% The separator between name, country, institution etc. for each author.
% If the information for a given author does not fit in a single line,
% we don't want the breaks to be at the separator (it may seem like a
% good idea, but the end result is confusing), so we use \nobreak.
\def\@SBCsep{\unskip\nobreak\space\nobreak\textbullet\nobreak\space\nobreak}
\def\@SBChyphensep{\unskip\nobreak\space\nobreak--\nobreak\space\nobreak}
% For the user. We need this to be robust so that we may redefine
% it correctly in a footnote (see \@SBCformatInstitution,
% \@SBCshowInstitutionsAsFootnotes, and \institutionthanks).
\newrobustcmd\sep{\@SBCsep}

% andTwo/andMany are used with \seq_use:Nnnn (in simpleAuthorListWithAnd)
\gdef\andTwo{
  \IfLanguagePatterns{brazilian} % This detects all dialects
    {\space e\space}
    {\space and\space}
}
\gdef\andMany{
  \IfLanguagePatterns{brazilian} % This detects all dialects
    {\space e\space}
    {,\space and\space}
}


%===============================================================================
% 9. Bibliography
%===============================================================================

\RequirePackage{csquotes}

% Each SBC event may choose to use one of two different bibliographic styles.
% We could do \PassOptionsToPackage here to set the other options and let the
% user call \usepackage[style=something]{biblatex} to select the correct style.
% However, we want to be able to instruct authors to simply copy the \metadata
% command for each particular SBC event and have everything work - including
% the bibliographic style. This forces us to load biblatex from within the
% \metadata command which, in turn, means that \addbibresource has to be called
% *after* \metadata. This is a hack to work around this limitation.
\newrobustcmd*\addbibresource[1]{\AtEndPreamble{\addbibresource{#1}}}

\NewDocumentCommand\@SBCbibConfig{m}{
  \undef\addbibresource % eliminate the above hack
  \RequirePackage[
      natbib=true,
      hyperref=true,
      autolang=hyphen,
      % biblatex-abnt presets language=brazil. As mentioned before, we prefer
      % brazilian. Setting language=auto here *should* override the default,
      % but does not, so we set the language here. We also set "auto" hoping
      % that it works, but that is not so important.
      language=\languagename,
      language=auto,
      style=#1,
  ]{biblatex}

  % TODO: remove mention to atenddvi bug after 2024
  % Prevent a bibliography entry to be split in two pages or columns.
  % Beyond the asthetic aspect, this bypasses this bug, which is more
  % likely to appear in the bibliography:
  % https://github.com/ho-tex/atenddvi/issues/1
  % We also implemented another, more radical workaround in the section
  % where hyperxmp is loaded.
  \AtBeginBibliography{\interlinepenalty=10000\raggedbottom}

  \renewcommand*{\bibfont}{\small}
}


%===============================================================================
% 10. Footnotes
%===============================================================================

\RequirePackage[bottom]{footmisc} % Fix a bug of LaTeX footnotes

% bigfoot is an extension to the manyfoot package, which allows us to define
% multiple footnote apparatus. We use it to define the footnotes on the
% first page. We might use manyfoot, but bigfoot fixes some manyfoot bugs,
% allows different formatting for different footnote classes, and improves
% the LaTeX pagebreak algorithm when footnotes are involved.

% bigfoot uses the perpage package. However, perpage is incompatible
% with the zref-abspage package: both of them try to define the
% "abspage" counter and use it in incompatible ways. According to this:
% https://github.com/ho-tex/zref/issues/3#issuecomment-564498677
% we cannot change the counter name in zref-abspage, as other packages
% use it. But apparently the counter in perpage is used only internally
% and, therefore, can be changed without problems. For this to work,
% zref-abspage must be loaded before perpage (this prevents perpage
% from trying to define the counter).

\RequirePackage{zref-abspage}
\RequirePackage{perpage}

% Now create an alternative counter name...
\AddAbsoluteCounter{pp@abspage}

% And redefine the perpage macro that uses it.
\def\theabspage{\ifx\thepage\relax
    \noexpand\thepp@abspage
  \else
    \number\c@pp@abspage
  \fi}

\RequirePackage{bigfoot}

% Taken from package "latex-firstaid": prevent
% bigfoot problems with recent LaTeX versions
\ifnum\count10<\insc@unt
  \global\count10=\insc@unt
\fi

% bigfoot has a compatibility problem with recent (post-2015) LaTeX versions;
% Fortunately, there is a fix: https://tex.stackexchange.com/a/472710
% This is also included in package "latex-firstaid".
\patchcmd\FN@allmarks{266}{256}{}{}

% For different reasons, bigfoot does not always do "para" style footnotes
% in a single paragraph. Since we really want that, let's handle all of them.

% The first reason is that it tries to be smart and disable para mode
% dynamically in cases when it would "look bad" (by temporarily redefining
% \@makefnbreak). This "smartness" can be disabled with these commands:
\def\hfootfraction{1}
\def\vtypefraction{1}

% The second reason is the bug indicated in this post as "problem 1":
% https://tex.stackexchange.com/a/451388/217608 . While this does not
% affect us, the post has a fix:
\patchcmd\FN@makefnstart
  {\ifx\FN@par\par\else}
  {\ifx\FN@indent\indent\else}
  {}{}

% The third reason is that, when typesetting a paragraph of footnotes,
% bigfoot encourages TeX to prefer line breaks between them: it adds a
% negative penalty with \@makefnbreak using its "magicglue" algorithm.
% While it seems reasonable to do that, the calculated value is very
% large for all but really small footnotes. This is described as
% "problem 2" in the post mentioned above. The proposed solution,
% however, is only effective when it is possible to use less lines,
% which is not always the case. Instead, let's just add a fixed and
% more modest incentive:
\def\@makefnbreak{\unskip\linebreak[0]\quad}

% Some bigfoot features are poorly documented, so here are a few things
% I have figured out:
%
% 1. bigfoot loads manyfoot and patches/enhances it. Therefore,
%    some things are done using manyfoot commands.
%
%    * manyfoot customizes the rules between notes with the commands
%      \defaultfoonoterule, \extrafootnoterule, \SelectFootnoteRule,
%      \footnoterulepriority.
%
%    * manyfoot allows us to run custom code at the beginning of each
%      note with \SetFootnoteHook{}, but bigfoot does not honor that.
%
% 2. With bigfoot, it is possible to call
%    \FootnoteSpecific{footnote-series}\def\@macroname{code} to
%    redefine certain macros for a specific footnote series:
%
%    * \@makefntext (from the default LaTeX classes, the most important)
%
%    * \interfootlinepenalty, \footnoteclubpenalty, \footnotewidowpenalty,
%      \finalfootnotewidowpenalty (the former prevents a widow when there
%      are subsequent footnote paragraphs on the following page; the latter
%      prevents a widow that is also the last and only footnote line on
%      the following page)
%
%    * \@preparefnhtext (executed before every footnote in horizontal
%      mode to fix indentation and other stuff; seems complex, but
%      I suppose most useful things can be done with \@makefntext)
%
%    * \footnotecarryratio (Influences badness calculations related to
%      footnotes that get split between two pages)
%
%    * \FootnoteMinimum (minimum amount of text per page)
%
%    * \FN@beforebreak and \FN@afterbreak (continuation text, needs to
%      have vertical material)


%==============================
% Now we can finally define the footnote classes we want:
%
% 1. "extra" -> used by \bottominfo, just typeset the text with no marker
% 2. "title" -> for title and author footnotes, use symbols as markers
% 3. "institution" -> for information about each institution; no markers,
%    as we will use our own "fake" markers (see the "metadata gathering"
%    section).

% The rules separating footnotes of different classes
\newcommand{\firstfootnoterule}{
  \kern-3\p@
  \hrule \@width \columnwidth
  \kern 2.6\p@
}

\newcommand{\middlefootnoterule}{
  \kern-3\p@
  \moveright 5\p@ \vbox{\hrule \@width .2\columnwidth}
  \kern 2.6\p@
}

% Footnotes will be typeset in this order
\SelectFootnoteRule[1]{first}
\DeclareNewFootnote{extra}[fnsymbol] % hidden markers, not really symbol
\SelectFootnoteRule[1]{middle}
\DeclareNewFootnote{title}[fnsymbol]
\DeclareNewFootnote[para]{institution}[fnsymbol] % hidden markers, not really symbol
\SelectFootnoteRule[1]{default}
\DeclareNewFootnote{default}


%==============================
% Footnotes appearance and auxiliary commands

% While adding footnotes to the title or authors is probably
% unecessary and a bad idea, it might happen. In this case,
% we use symbols as the footnote markers. However, the default
% footnote symbols are not so great, so we define a different
% set. Since these symbols were not created for this, sizes
% and spacing are all over the place; we need to adjust each
% of them manually. This is tuned to libertinus as the main
% document font and will probably result in very bad results
% with other fonts (including Computer Modern).

\ExplSyntaxOn
\newrobustcmd\@SBCscaleFont[2]{%
  \bgroup
  \rmfamily\upshape % return to libertinus
  % Beyond the specific scaling factor for each symbol
  % received as a parameter, we also enlarge all symbols
  % by 1.25, which looks better when the surrounding text
  % is FiraSans (always the case in this template). For
  % this to work, we also need to lower the symbols by
  % .15ex, as larger symbols have a higher baseline.
  \fontsize{\fp_to_dim:n {\f@size * #1 * 1.25}}{\z@}\selectfont
  \raisebox{-.15ex}{#2}%
  \egroup
}
\ExplSyntaxOff

% Spacing and sizes are not exactly the same with T1 and OTF fonts.
\ifPDFTeX
  \def\@fnsymbol#1{%
    \ifcase#1\or
      \raisebox{-.6ex}{\@SBCscaleFont{1.15}{*}}\or
      \raisebox{-.6ex}{\@SBCscaleFont{1.15}{**}}\or
      \raisebox{.05ex}{\@SBCscaleFont{.95}{\ensuremath{\dag}}}\or
      \raisebox{.1ex}{\@SBCscaleFont{.89}{\ensuremath{\ddag}}}\or
      \raisebox{.35ex}{\@SBCscaleFont{.95}{\textreferencemark}}\or
      \hspace{-.07em}\raisebox{-.07ex}{\@SBCscaleFont{1.45}{\ensuremath{\natural}}}\or
      \raisebox{.35ex}{\@SBCscaleFont{1}{\ensuremath{\circledcirc}}}\or
      \raisebox{.35ex}{\@SBCscaleFont{1}{\ensuremath{\fisheye}}}\or
      \raisebox{.35ex}{\@SBCscaleFont{1}{\ensuremath{\otimes}}}\or
      \raisebox{.3ex}{\@SBCscaleFont{.95}{\ensuremath{\mdlgwhtlozenge}}}\or
      \raisebox{.35ex}{\@SBCscaleFont{.92}{\ensuremath{\diamondsuit}}}\or
      \hspace{-.08em}\raisebox{.55ex}{\@SBCscaleFont{.72}{\ensuremath{\bigstar}}}\or
      \hspace{.07em}\raisebox{.25ex}{\@SBCscaleFont{1.02}{\ensuremath{\S}}}\or
      \raisebox{.5ex}{\@SBCscaleFont{.89}{\ensuremath{\P}}}%
    \else
      \@ctrerr
    \fi
  }
\else
  \def\@fnsymbol#1{%
    \ifcase#1\or
      \raisebox{-.55ex}{\@SBCscaleFont{1.05}{*}}\or
      \raisebox{-.55ex}{\@SBCscaleFont{1.05}{**}}\or
      \@SBCscaleFont{.86}{\ensuremath{\dag}}\or % † \char"2020
      \raisebox{.05ex}{\@SBCscaleFont{.82}{\ensuremath{\ddag}}}\or % ‡ \char"2021
      \raisebox{.3ex}{\@SBCscaleFont{.86}{\textreferencemark}}\or % ※ \char"203B
      \hspace{-.07em}\raisebox{-.1ex}{\@SBCscaleFont{1.35}{\ensuremath{\natural}}}\or % ♮ \char"266E
      \raisebox{.4ex}{\@SBCscaleFont{.91}{\ensuremath{\circledcirc}}}\or % ⊚ \char"229A
      \raisebox{.35ex}{\@SBCscaleFont{.91}{\ensuremath{\fisheye}}}\or % ◉ \char"25C9
      \raisebox{.35ex}{\@SBCscaleFont{.91}{\ensuremath{\otimes}}}\or % ⊗ \char"2297
      \raisebox{.33ex}{\@SBCscaleFont{.87}{\ensuremath{\mdlgwhtlozenge}}}\or % ◊ \char"25CA
      \raisebox{.27ex}{\@SBCscaleFont{.85}{\ensuremath{\vardiamondsuit}}}\or % ♦ \char"2666
      \hspace{-.05em}\raisebox{.3ex}{\@SBCscaleFont{1.08}{\ensuremath{\bigstar}}}\or % ★ \char"2605
      \hspace{.07em}\raisebox{.19ex}{\@SBCscaleFont{.94}{\ensuremath{\S}}}\or % § \char"00A7
      \raisebox{.45ex}{\@SBCscaleFont{.81}{\ensuremath{\P}}}% ¶ \char"00B6
      % These are also nice, but only work with a unicode engine
      %\ensuremath{\char"2695}% ⚕
      %\ensuremath{\char"263C}% ☼
      %\ensuremath{\char"2718}% ✘
      %\ensuremath{\char"25D1}% ◑
      %\ensuremath{\char"25D3}% ◓
      %\ensuremath{\char"2698}% ⚘
    \else
      \@ctrerr
    \fi
  }
\fi

% We do not want to use arabic numbers for footnotes indicating
% information for institutions because they would be mixed up
% with ordinary text footnotes. Symbols could work, but with a
% potentially large number of footnotes, that becomes confusing
% (and it is hard to come up with a good set of symbols). So,
% let's use greek letters.
\def\@SBCfnsymbolgreek#1{%
  \ifcase#1\or
    \ensuremath{\alpha}\or
    \ensuremath{\beta}\or
    \ensuremath{\gamma}\or
    \ensuremath{\delta}\or
    \ensuremath{\epsilon}\or
    \ensuremath{\zeta}\or
    \ensuremath{\eta}\or
    \ensuremath{\theta}\or
    \ensuremath{\iota}\or
    \ensuremath{\kappa}\or
    \ensuremath{\lambda}\or
    \ensuremath{\mu}\or
    \ensuremath{\nu}\or
    \ensuremath{\xi}\or
    \ensuremath{\omicron}\or
    \ensuremath{\pi}\or
    \ensuremath{\rho}\or
    \ensuremath{\sigma}\or
    \ensuremath{\tau}\or
    \ensuremath{\upsilon}\or
    \ensuremath{\phi}\or
    \ensuremath{\chi}\or
    \ensuremath{\psi}\or
    \ensuremath{\omega}%
  \else
    \@ctrerr
  \fi
}

% This is a copy of \@textsuperscript, but size is 7pt instead of
% \sf@size (6pt). We need this because the size of the institution
% markers at the default size is a little too small.
\def\@SBCtextsuperscriptlarger#1{%
  {\m@th\ensuremath{^{\mbox{\fontsize{7pt}\z@\selectfont#1}}}}%
}

% Custom appearance for footnotes. Copied almost verbatim from the
% example in the LaTeX2e classes documentation (texdoc classes). It
% would be possible to do something similar using a single item
% \list{} with \@thefnmark as the label.
%
% \footnotesep is not really added space; it is the size of a strut
% that exists at the beginning of each footnote. That is why it is
% "big" (\baselineskip) but the resulting separation is small.
\renewcommand\@makefntext[1]{%
    \setlength{\footnotesep}{1\baselineskip}%
    \@setpar{%
        \@@par
        \@tempdima = \hsize
        \advance\@tempdima-4pt\relax
        \parshape \@ne 4pt \@tempdima
    }%
    \par
    \parindent 1em\noindent
    \parskip .3\baselineskip
    \hbox to \z@{\hss\@makefnmark\,}#1%
}

% "extra" footnotes are not indented, so we define
% a different version of \@makefntext for them
\FootnoteSpecific{extra}\def\@makefntext#1{%
    \setlength{\footnotesep}{1\baselineskip}%
    \parindent 0pt%
    \parskip .3\baselineskip
    \noindent#1%
}

% Detached footnotes, i.e., text that appears as a footnote
% but is not referenced anywhere. "0" disables the marker
% because there is no 0th symbol.
\newcommand\detachedfootnote[1]{%
    \bgroup
    \renewcommand\thefootnote{\fnsymbol{footnote}}%
    \renewcommand\thempfootnote{\fnsymbol{mpfootnote}}%
    \footnotetext[0]{#1}%
    \egroup
}

% The \footnote command does not work in the preamble (there is no place
% to insert the footnotemark and no page to attach the footnote to yet).
% So, the LaTeX format deals with footnotes defined in the preamble
% (usually to be attached to the title) in a special way, using \thanks
% and \@thanks: \thanks inserts a protected \footnotemark to be typeset
% with the \title or similar command and also saves a corresponding
% \footnotetext command inside the \@thanks macro. After the title etc.
% is typeset, we call \@thanks to typeset all the pending footnotes it
% contains. This is normally used for footnotes attached to the title,
% but we do it for extra data and author info as well, using the different
% footnote classes we defined above with bigfoot. So, we need to create
% variants of the \thanks macro that use the different kinds of footnote
% for each case (but in the end they all are attached to \@thanks).
% Ordinary footnotes will only be used inside the abstract.

\newcommand\titlethanks[1]{%
    \footnotemarktitle
    \protected@xdef\@thanks{%
        \@thanks
        \protect\footnotetexttitle[\the\c@footnotetitle]{#1}%
    }%
}

% For extra data and institution, "0" disables numbering just like
% \detachedfootnote above because these footnote classes use
% fnsymbol as the default counter.

\newcommand\extrathanks[1]{%
    \protected@xdef\@thanks{%
        \@thanks
        \protect\footnotetextextra[0]{#1}%
    }%
}

\newcommand\bottominfo[1]{\extrathanks{#1}}

% \institutionthanks should not have any marker of its
% own, because we will use "fake" markers with it (see
% the explanation in the "metadata gathering" section).
\newcommand\institutionthanks[1]{%
    \protected@xdef\@thanks{%
        \@thanks
        \protect\footnotetextinstitution[0]{#1}%
    }%
}

% If needed, authors may add free text to the institution information,
% either at the start or at the end of the list.
\newcommand{\extraAffiliationsLast}[1]{\def\@SBCextraAffiliationsLast{#1}}
\newcommand{\extraAffiliationsFirst}[1]{\def\@SBCextraAffiliationsFirst{#1}}
\let\extraAffiliations\extraAffiliationsLast


%===============================================================================
% 11. Metadata gathering (event name, title, authors & institutions etc.)
%===============================================================================

% Here we define \metadata, \title, \author, \institution, \keywords, and
% \abstract. We collect all this data in the preamble to have it available
% to typeset the title block and headers and to record it as pdf metadata.
%
% Most of this data is simply stored in named macros (\@pubTitle,
% \@title etc.). Information on the authors and their institutions,
% however, is more complex, because (1) the number of authors and
% institutions is unknown and (2) for each one, there are several data
% items we want to collect (name, email etc.).
%
% To address the multiple data items per author/institution, we create
% a LaTeX3 property list (similar to a hash map, check texdoc l3prop)
% for each author and each institution to store the relevant data. To
% address the varying number of authors and institutions, we create
% the counters numberOfAuthors and numberOfInstitutions and use them to
% define the names of the corresponding property lists: \@SBCauthorI,
% \@SBCauthorII, \@SBCinstI, \@SBCinstII etc. We can then process all
% authors and institutions by iterating on a temporary counter (authornum
% and instnum).
%
% We also want to be able to easily find the data for an institution when
% all we have is its "ID" as referenced in \author. Therefore, we create
% the \@SBCinstIDsMap property list, in which each ID is a key and the
% name of the corresponding institution property list is the value.
%
% Together with each author, we may present (1) all information about the
% institutions they are affiliated with, or (2) just a reference marker
% to a footnote or text block with their affiliation information. However,
% in the second case, we must take care to put each institution in the
% footnote or text block only once, even if multiple authors belong to
% it. So, we define a number for each institution and (1) add a single
% "detached" footnote for each institution with this number as a fake
% marker and (2) append this same fake marker to the corresponding authors.
% To handle this, we add a fixed, sequential number to the property list
% of each institution and use this number as the fake marker. We may render
% this number with arabic numbers, symbols, or greek letters.
%
%==============================
% Email addresses that might appear in the first, optional argument of
% \author may include characters that are special for TeX (such as "_"
% and "%"). The usual way of handling this is to use \url, from the url
% package, which works in part by performing custom tokenization of its
% argument. However, when \url is called from within the argument to another
% command, wich is what we want to do here, it cannot handle "%" and
% "#" correctly: in this case, these chars are tokenized before \url
% may do anything about them.
%
% To solve this problem, we will redefine the tokenization of the first
% argument of \author, forcing the catcode of "%" and "#" to "other",
% and then process "%" to manually remove actual comments. As for "#",
% we can safely ignore its special meaning in this context, so nothing
% else is done with it. Note that "\%" and "\#" are not affected in any
% way; they continue to work as expected.
%
% To perform this special tokenization, we need to use two separate
% macros (note that \bgroup from \author is paired with \egroup
% from \@SBCauthorPrepare). To know more, check out
% https://www.overleaf.com/learn/latex/How_TeX_macros_actually_work:_Part_6 .
%
% This special tokenization has a nasty side effect: comments within
% these arguments will not be understood as such because of the change
% in meaning of the "%" character. Accordingly, we will have to process
% comments ourselves, which means we need to tokenize newlines ("^^M")
% as "other" too in order to be able to detect the end of comments.
% On the flip side, this means empty lines inside the parameter are not
% interpreted as \par, which is nice in this context. We will apply the
% same technique to \metadata and \title so that we may use blank lines
% in them.

% If we try to use ^^M within a macro definition, LaTeX will just see an
% end-of-line and remove it. This means we need to change the tokenization
% *before* defining a macro that will change the tokenization! So, let's
% make ^^M become "other" and use ^^A as end-of-line to define two small
% auxiliary macros here:
\@makeother\^^M\catcode`\^^A=5\relax^^A
\def\@SBCmakeotherEOL{\@makeother\^^M}^^A
\def\@SBCifnextcharEOL{\@ifnextchar^^M}^^A
\catcode`\^^A=12\catcode`\^^M=5\relax % back to sanity :)

\gdef\metadata{
    \bgroup
    \@makeother\%
    \@makeother\#
    \@SBCmakeotherEOL
    \@SBCifnextcharEOL{\expandafter\@SBCmetadataPrepare\@gobble}{\@SBCmetadataPrepare}
}

\gdef\title{
    \bgroup
    \@makeother\%
    \@makeother\#
    \@SBCmakeotherEOL
    \@SBCifnextcharEOL{\expandafter\@SBCtitlePrepare\@gobble}{\@SBCtitlePrepare}
}

\gdef\author{
    \bgroup
    \@makeother\%
    \@makeother\#
    \@SBCmakeotherEOL
    \@SBCifnextcharEOL{\expandafter\@SBCauthorPrepare\@gobble}{\@SBCauthorPrepare}
}

% Entering LaTeX 3 territory; check "texdoc expl3", "texdoc xparse",
% and "texdoc interface3" to learn more.
\ExplSyntaxOn

% \@SBCtext is defined by \@SBCremoveComments;
% yes, this is a little dirty.

\newcommand{\@SBCmetadataPrepare}[1]{
    \egroup
    \tl_gclear_new:N \@SBCtext
    \@SBCremoveComments{#1}
    \exp_args:NV \@SBCrealMetadata\@SBCtext
}

\newcommand{\@SBCtitlePrepare}[1]{
    \egroup
    \tl_gclear_new:N \@SBCtext
    \@SBCremoveComments{#1}
    \exp_args:NV \@SBCrealTitle\@SBCtext
}

\newcommand{\@SBCauthorPrepare}[1]{
    \egroup
    \tl_gclear_new:N \@SBCtext
    \@SBCremoveComments{#1}
    \exp_args:NV \@SBCrealAuthor\@SBCtext
}

% Now the code to "manually" remove comments as discussed before. This
% works because if the "%" character is used as part of an email address
% or URL, it will be enclosed (with the rest of the address) in a pair
% of braces. Since \tl_map_variable treats the contents of braces as a
% single item, if we "see" a "%" character, it is not enclosed in braces,
% which means it is a comment.
\newbool{@SBCinComment}

\xdef\@SBCnewline{\char_generate:nn {`\^^M}{12}}

\newcommand{\@SBCremoveComments}[1]{

  \tl_gclear_new:N \@SBCtext

  \tl_map_variable:nNn {#1} \l_tmpa_tl {

    % If we read a newline, ignore it. We need to not output it to
    % prevent spurious newlines from being interpreted as \par. If
    % we are currently reading a comment, newlines also indicate
    % the end of the comment.
    \tl_if_head_eq_meaning:nNTF {\l_tmpa_tl} \@SBCnewline
      {
        \ifbool{@SBCinComment}
          {\boolfalse{@SBCinComment}}
          {}
      }
      {
        % Not a newline. If we are currently reading a comment,
        % do nothing; otherwise, output what was read, unless
        % it is the beginning of a comment (character "%").
        \ifbool{@SBCinComment}
          {}
          {
            \tl_if_head_eq_meaning:nNTF {\l_tmpa_tl} \c_percent_str
              {\booltrue{@SBCinComment}}
              {
                \tl_if_single:NTF \l_tmpa_tl
                  {\tl_put_right:NV \@SBCtext \l_tmpa_tl}
                  {\tl_put_right:Nx \@SBCtext {{\exp_not:V\l_tmpa_tl}}}
              }
          }
      }
  }

  % Re-tokenize without special treatment for newlines,
  % so they are treated/ignored as spaces
  \tl_set_rescan:Nno
      \@SBCtext
      {\@makeother\% \@makeother\#}
      {\@SBCtext}
}


%==============================
% Define the core macros

% LaTeX3 options as key/values (similar to pgfkeys, check texdoc l3keys)
% for the \metadata command to collect additional information about the
% article.
\keys_define:nn { SBC / metadata }
  {
    % keys on the left set the variables on the right
    category .tl_gset:N = \@articleCategory,
    category .value_required:n = true,
    license .tl_gset:N = \@articleLicense,
    license .value_required:n = true,
    copyrightyear .tl_gset:N = \@copyrightYear,
    copyrightyear .value_required:n = true,
    idjems .tl_gset:N = \@idjems,
    idjems .value_required:n = true,
    pubname.tl_gset:N = \@pubTitle,
    pubname .value_required:n = true,
    pubacron.tl_gset:N = \@pubAcron,
    pubacron .value_required:n = true,
    bibstyle .tl_gset:N = \@SBCbibStyle,
    bibstyle .value_required:n = true,
    colorlinks .code:n = {\ifstrequal{#1}{true}{\toggletrue{@SBCcolorlinks}}{\togglefalse{@SBCcolorlinks}}},
    colorlinks .default:n = {true},
    nocolorlinks .code:n = {\togglefalse{@SBCcolorlinks}},
    nocolorlinks .value_forbidden:n = true,
  }

\NewDocumentCommand\@SBCrealMetadata{m}{
  % Process arguments
  \tl_gclear_new:N \@articleCategory
  \tl_gclear_new:N \@articleLicense
  \tl_gclear_new:N \@copyrightYear
  \tl_gclear_new:N \@doi
  \tl_gclear_new:N \@idjems
  \tl_gclear_new:N \@pubTitle
  \tl_gclear_new:N \@pubAcron
  \tl_gclear_new:N \@pubAcronLC
  \tl_gclear_new:N \@SBCbibStyle
  \tl_gset:Nn \@articleLicense {CC-BY} % Default license
  \tl_gset:Nn \@SBCbibStyle {sbc20} % Default bibliographic style
  \keys_set:nn {SBC/metadata}{#1}

  \tl_gset:Nn \@pubAcronLC {\MakeLowercase{\@pubAcron}}
  
  \tl_gset:Nn \@doi {10.5753/{\@pubAcronLC}.{\@copyrightYear}.{\@idjems}}

  \exp_args:NV \@SBCbibConfig\@SBCbibStyle

  \exp_args:NV \str_case:nnF \@articleLicense
    {
      {CC-BY}{\gdef\@articleLicense{%
        \href{https\c_colon_str//creativecommons.org/licenses/by/4.0/}{\ccby
        \scriptsize\space\space\@copyrightYear\space
        Creative~Commons~Attribution~4.0~International~License~(CC~BY~4.0)}}
      }

      {CC-BY-NC}{\gdef\@articleLicense{%
        \href{https\c_colon_str//creativecommons.org/licenses/by-nc/4.0/}{\ccbync
        \scriptsize\space\space\@copyrightYear\space
        Creative~Commons~Attribution-NonCommercial~4.0~International~License~(CC~BY-NC~4.0)}}
      }

      {CC-BY-ND}{\gdef\@articleLicense{%
        \href{https\c_colon_str//creativecommons.org/licenses/by-nd/4.0/}{\ccbynd
        \scriptsize\space\space\@copyrightYear\space
        Creative~Commons~Attribution-NoDerivatives~4.0~International~License~(CC~BY-ND~4.0)}}
      }

      {CC-BY-SA}{\gdef\@articleLicense{%
        \href{https\c_colon_str//creativecommons.org/licenses/by-sa/4.0/}{\ccbysa
        \scriptsize\space\space\@copyrightYear\space
        Creative~Commons~Attribution-ShareAlike~4.0~International~License~(CC~BY-SA~4.0)}}
      }

      {CC-BY-NC-SA}{\gdef\@articleLicense{%
        \href{https\c_colon_str//creativecommons.org/licenses/by-nc-sa/4.0/}{\ccbyncsa
        \scriptsize\space\space\@copyrightYear\space
        Creative~Commons~Attribution-NonCommercial-ShareAlike~4.0~International~License~(CC~BY-NC-SA~4.0)}}
      }

      {CC-BY-NC-ND}{\gdef\@articleLicense{%
        \href{https\c_colon_str//creativecommons.org/licenses/by-nc-nd/4.0/}{\ccbyncnd
        \scriptsize\space\space\@copyrightYear\space
        Creative~Commons~Attribution-NonCommercial-NoDerivatives~4.0~International~License~(CC~BY-NC-ND~4.0)}}
      }
    }
    % If there is no match, use the user-supplied text
    {
      \ifdefvoid{\@articleLicense}
        {}
        {\tl_put_left:Nn \@articleLicense {\scriptsize}}
    }
}

\AtEndPreamble{
  \IfLanguagePatterns{brazilian}
    {
      \ifdefvoid{\@translatedtitle}
        {
          \ClassError{sbc20}
            {
              \MessageBreak
              *****************************************************\MessageBreak
              Language~is~set~to~Portuguese,~so~you~should~provide\MessageBreak
              a~title~translation~(or~set~the~language~to~English).\MessageBreak
              *****************************************************
            }
            {If~you~continue,~the~document~will~compile,~but~you~really\MessageBreak
             should~provide~the~translated~title~(or~switch~to~English).}

          \ClassWarningNoLine{sbc20}
            {
              \MessageBreak
              ***********************************************\MessageBreak
              Grudgingly~continuing~without~translated~title.\MessageBreak
              ***********************************************
            }
        }
        {}
    }
    {}
}

% LaTeX3 options as key/values (similar to pgfkeys, check texdoc l3keys) for
% the \title command to collect additional information about the article.
\keys_define:nn {SBC/title}
  {
    % keys on the left set the variables on the right
    mainlanguagetitle .tl_gset:N = \@title,
    mainlanguagetitle .value_required:n = true,
    translatedtitle .tl_gset:N = \@translatedtitle,
    translatedtitle .value_required:n = true,
  }



\NewDocumentCommand\@SBCrealTitle{m}{
  % Process arguments
  \tl_gclear_new:N \@title
  \tl_gclear_new:N \@translatedtitle
  \keys_set:nn {SBC/title}{#1}

}

% We will create one LaTeX3 property list (similar to a hash map, check
% texdoc l3prop) for each institution (\@SBCinstI, \@SBCinstII etc.) to
% store their information (name, ID, marker). We need this counter to
% create these names and also to set the value of fake markers for them.
\newcounter{numberOfInstitutions}

% We also need to find an institution when we have its ID. Let's create
% a property list that maps ID -> Name of institution propList
\prop_gclear_new:N \@SBCinstIDsMap

\NewDocumentCommand\institution{m m}{
    % Generate the name for this institution's property list. We will
    % need that later, but might also use it during argument processing
    \stepcounter{numberOfInstitutions}
    \tl_gclear_new:N \@SBCcurrInst
    \tl_gset:Nx \@SBCcurrInst {@SBCinst\Roman{numberOfInstitutions}}

    % Create a new property list for this institution
    \prop_gclear_new:c {\@SBCcurrInst}

    % Add the institution data to the property list. First the name...
    \prop_put:cnn {\@SBCcurrInst} {name} {#2}

    % Then the ID...
    \ifstrequal{#1}{}
      {
        \ClassError{sbc20}
          {
            \MessageBreak
            *******************************************\MessageBreak
            "#2"~has~no~ID,\MessageBreak
            so~it~cannot~be~associated~with~any~author!\MessageBreak
            *******************************************\MessageBreak
          }
          {If~you~continue,~the~document~might~compile,\MessageBreak
          but~this~does~not~make~sense.}

        \ClassWarningNoLine{sbc20}
          {
            \MessageBreak
            **************************\MessageBreak
            Grudgingly~continuing~with\MessageBreak
            dangling~institution.\MessageBreak
            **************************
          }
      }
      {
        \prop_put:cnn {\@SBCcurrInst} {id} {#1}
        \prop_put:NnV \@SBCinstIDsMap {#1} \@SBCcurrInst
      }

    % Then the fake marker value, formatted.
    \iftoggle{@SBCinstitutionsInFootnotes}
      {\edef\@tempa {\exp_not:N\@SBCfnsymbolgreek{\the\value{numberOfInstitutions}}}}
      {\edef\@tempa {\arabic{numberOfInstitutions}}}
      %{\edef\@tempa {\alph{numberOfInstitutions}}}
    \prop_put:cnx {\@SBCcurrInst} {marker} {\@tempa}
}

\NewDocumentCommand\SBCprintInitKeyBibliography{}{
    \vspace{2mm}
    \textcolor{white}{\#\#init_bibliography\#\#} 
    \vspace{-7mm}
}

\NewDocumentCommand\SBCprintEndKeyBibliography{}{
    \vspace{-5mm}
    \textcolor{white}{\#\#end_bibliography\#\#} 
}

% LaTeX3 options as key/values (similar to pgfkeys, check texdoc l3keys)
% for the \author command to collect additional information for each author.
\keys_define:nn { SBC / author }
  {
    % keys on the left set the variables on the right
    orcid .tl_set:N = \l_sbc_orcid,
    orcid .value_required:n = true,
    % A pointer to the list of institutions indicating to which ones
    % this author belongs. The institution names are provided by
    % another command. This accepts a comma-separated list but
    % may also be used multiple times per author.
    institutionID .value_required:n = true,
    institutionID .code:n = {\clist_put_right:Nn \l_sbc_instids {#1}},
    email .tl_set:N = \l_sbc_mail,
    email .value_required:n = true,
    country .tl_set:N = \l_sbc_country,
    country .value_required:n = true,
    firstName .tl_set:N = \l_sbc_first_name,
    firstName .value_required:n = true,
    middleName .tl_set:N = \l_sbc_middle_name,
    middleName .value_required:n = true,
    lastName .tl_set:N = \l_sbc_last_name,
    lastName .value_required:n = true,
  }

% We will create one LaTeX3 property list (similar to a hash
% map, check texdoc l3prop) for each author (\@SBCauthorI,
% \@SBCauthorII etc.) to store their information (name, email,
% affiliation, etc.). We need this counter to create these names.
\newcounter{numberOfAuthors}

\NewDocumentCommand\@SBCrealAuthor{m}{
    % Generate the name for this author's property list. We will need
    % that later, but might also use it during argument processing
    \stepcounter{numberOfAuthors}
    \tl_gclear_new:N \@SBCcurrAuthor
    \tl_gset:Nx \@SBCcurrAuthor {@SBCauthor\Roman{numberOfAuthors}}

    % Create a new property list for this author
    \prop_gclear_new:c {\@SBCcurrAuthor}

    % Process optional arguments
    \tl_clear_new:N \l_sbc_orcid
    \tl_clear_new:N \l_sbc_mail
    \tl_clear_new:N \l_sbc_country
    \tl_clear_new:N \l_sbc_first_name
    \tl_clear_new:N \l_sbc_middle_name
    \tl_clear_new:N \l_sbc_last_name
    \clist_clear_new:N \l_sbc_instids
    \keys_set:nn {SBC/author}{#1}

    % The email may contain special characters, such as "_", "^" etc.
    % Characters "%" and "#" have already been handled by the special
    % tokenization in \author. Since we may be reasonably sure that
    % any other such characters are not LaTeX commands in this context,
    % let's just convert this to a string.
    \tl_set:Nx \l_sbc_mail {\tl_to_str:V \l_sbc_mail}

    % Add the author data to the property list. First the name...
    \tl_if_blank:VTF \l_sbc_middle_name
      {\prop_put:cnx {\@SBCcurrAuthor} {name} {\l_sbc_first_name\space\l_sbc_last_name}}
      {\prop_put:cnx {\@SBCcurrAuthor} {name} {\l_sbc_first_name\space\l_sbc_middle_name\space\l_sbc_last_name}}

    % Then the other variables from the optional parameters
    \tl_if_blank:VF \l_sbc_orcid
      {\prop_put:cnV {\@SBCcurrAuthor} {orcid} \l_sbc_orcid}

    \tl_if_blank:VF \l_sbc_mail
      {\prop_put:cnV {\@SBCcurrAuthor} {email} \l_sbc_mail}

    \tl_if_blank:VF \l_sbc_country
      {\prop_put:cnV {\@SBCcurrAuthor} {country} \l_sbc_country}

    \tl_if_blank:VF \l_sbc_first_name
      {\prop_put:cnV {\@SBCcurrAuthor} {firstName} \l_sbc_first_name}

    \tl_if_blank:VF \l_sbc_middle_name
      {\prop_put:cnV {\@SBCcurrAuthor} {middleName} \l_sbc_middle_name}

    \tl_if_blank:VF \l_sbc_last_name
      {\prop_put:cnV {\@SBCcurrAuthor} {lastName} \l_sbc_last_name}
    
    \clist_remove_duplicates:N \l_sbc_instids
    \clist_if_empty:NF \l_sbc_instids
      {\prop_put:cnV {\@SBCcurrAuthor} {instids} \l_sbc_instids}
}

\newcommand\shorttitle[1]{\gdef\@shorttitle{#1}}

\newcommand\shortauthor[1]{\gdef\@shortauthor{#1}}

\renewcommand\abstract[1]{
    \long\xdef\@abstract{\trim@spaces@noexp{#1}}
}

\newcommand\resumo[1]{
    \long\xdef\@resumo{\trim@spaces@noexp{#1}}
}

\newcommand\keywords[1]{
    \xdef\@keywords{\trim@spaces@noexp{#1}}
}

\newcommand\palavraschave[1]{
    \xdef\@pchaves{\trim@spaces@noexp{#1}}
}

% These need to be set in the preamble because
% they are used to register the XMP metadata.
\@onlypreamble\author
\@onlypreamble\title
\@onlypreamble\abstract
\@onlypreamble\resumo
\@onlypreamble\keywords
\@onlypreamble\palavraschave

\@onlypreamble\metadata % this loads biblatex
\@onlypreamble\shortauthor % we need to check if the headers fit in the page
\@onlypreamble\shorttitle % we need to check if the headers fit in the page

% These should work ok after \begin{document} (perhaps before \maketitle),
% but having everything in the preamble is more consistent.
\@onlypreamble\institution
\@onlypreamble\extraAffiliationsLast
\@onlypreamble\extraAffiliationsFirst
\@onlypreamble\extraAffiliations
\@onlypreamble\bottominfo
\@onlypreamble\funding
\@onlypreamble\declinfo
\@onlypreamble\acknowledgements
\@onlypreamble\furtherinfo
\@onlypreamble\datainfo
\@onlypreamble\contributeinfo
\@onlypreamble\aboutauthors
\@onlypreamble\SBCprintbibliography

% Build two macros with the names of the authors:
%
% 1. Names separated by commas, to be inserted as metadata in the
%    generated pdf file using hyperref (\simpleAuthorList}.
%
% 2. Names separated by commas with "and" at the end, to be used
%    in the page headers (\simpleAuthorListWithAnd).
%
% Since this needs to be executed *after* all authors have been
% defined, let's use \AtEndPreamble.
\AtEndPreamble{
  \seq_clear_new:N \@SBCtextList
  \seq_clear_new:N \@SBCauthorEmailList
  \seq_clear_new:N \@SBCauthorOrcidList
  \seq_clear_new:N \@SBCauthorCountryList
  \seq_clear_new:N \@SBCauthorFirstNameList
  \seq_clear_new:N \@SBCauthorMiddleNameList
  \seq_clear_new:N \@SBCauthorLastNameList
  \seq_clear_new:N \@SBCauthorInstitutionList

  \setcounter{authornum}{0}

  \int_while_do:nNnn {\value{authornum}} < {\value{numberOfAuthors}} {
      \stepcounter{authornum}
      \tl_gclear_new:N \@SBCcurrAuthor
      \tl_gset:Nx \@SBCcurrAuthor {@SBCauthor\Roman{authornum}}

      \seq_put_right:Nx \@SBCtextList {\prop_item:cn {\@SBCcurrAuthor} {firstName}}
      \seq_put_right:Nx \@SBCauthorEmailList {\prop_item:cn {\@SBCcurrAuthor} {email}}
      \seq_put_right:Nx \@SBCauthorOrcidList {\prop_item:cn {\@SBCcurrAuthor} {orcid}}
      \seq_put_right:Nx \@SBCauthorCountryList {\prop_item:cn {\@SBCcurrAuthor} {country}}
      \seq_put_right:Nx \@SBCauthorFirstNameList {\prop_item:cn {\@SBCcurrAuthor} {firstName}}
      \seq_put_right:Nx \@SBCauthorMiddleNameList {\prop_item:cn {\@SBCcurrAuthor} {middleName}}
      \seq_put_right:Nx \@SBCauthorLastNameList {\prop_item:cn {\@SBCcurrAuthor} {lastName}}
      \seq_put_right:Nx \@SBCauthorInstitutionList {\prop_item:cn {\@SBCcurrAuthor} {instids}}
  }

  \tl_gclear_new:N \simpleAuthorList
  \tl_gset:Nx \simpleAuthorList {\seq_use:Nn \@SBCtextList {;}}
  \@SBCremoveLinebreaksEtc{\simpleAuthorList}

  \tl_gclear_new:N \simpleAuthorListWithAnd
  \tl_gset:Nx
      \simpleAuthorListWithAnd
      {%
          \seq_use:Nnnn \@SBCtextList
            {\andTwo}%
            {,\space}%
            {\andMany}%
      }
  \@SBCremoveLinebreaksEtc{\simpleAuthorListWithAnd}

  \tl_gclear_new:N \simpleAuthorEmailList
  \tl_gset:Nx \simpleAuthorEmailList
  {
    \iftoggle{@SBCblind}
    {
        \seq_use:Nn \@SBCauthorEmailList {;}
    }{}
  }
  \@SBCremoveLinebreaksEtc{\simpleAuthorEmailList}

  \tl_gclear_new:N \simpleAuthorOrcidList
  \tl_gset:Nx \simpleAuthorOrcidList
  {
    \iftoggle{@SBCblind}
    {
        \seq_use:Nn \@SBCauthorOrcidList {;}
    }{}
  }
  \@SBCremoveLinebreaksEtc{\simpleAuthorOrcidList}

  \tl_gclear_new:N \simpleAuthorCountryList
  \tl_gset:Nx \simpleAuthorCountryList
  {
    \iftoggle{@SBCblind}
    {
        \seq_use:Nn \@SBCauthorCountryList {;}
    }{}
  }
  \@SBCremoveLinebreaksEtc{\simpleAuthorCountryList}

  \tl_gclear_new:N \simpleAuthorFirstNameList
  \tl_gset:Nx \simpleAuthorFirstNameList 
  {
    \iftoggle{@SBCblind}
    {
        \seq_use:Nn \@SBCauthorFirstNameList {;}
    }{}
  }
  \@SBCremoveLinebreaksEtc{\simpleAuthorFirstNameList}

  \tl_gclear_new:N \simpleAuthorMiddleNameList
  \tl_gset:Nx \simpleAuthorMiddleNameList
  {
    \iftoggle{@SBCblind}
    {
        \seq_use:Nn \@SBCauthorMiddleNameList {;}
    }{}
  }
  \@SBCremoveLinebreaksEtc{\simpleAuthorMiddleNameList}

  \tl_gclear_new:N \simpleAuthorLastNameList
  \tl_gset:Nx \simpleAuthorLastNameList
  {
    \iftoggle{@SBCblind}
    {
        \seq_use:Nn \@SBCauthorLastNameList {;}
    }{}
  }
  \@SBCremoveLinebreaksEtc{\simpleAuthorLastNameList}

  \tl_gclear_new:N \simpleAuthorInstitutionList
  \tl_gset:Nx \simpleAuthorInstitutionList
  {
    \iftoggle{@SBCblind}
    {
        \seq_use:Nn \@SBCauthorInstitutionList {;}
    }{}
  }
  \@SBCremoveLinebreaksEtc{\simpleAuthorInstitutionList}

  \ifdefvoid{\@shorttitle}
    {\let\@shorttitle\@title}
    {}

  % If the user did not define \@shortauthor, use
  % the full author list and hope for the best.
  \ifdefvoid{\@shortauthor}
    {\let\@shortauthor\simpleAuthorListWithAnd}
    {}

  \setlength{\@tempdima}{\widthof{\@shorttitle\quad\@shortauthor}}
  \ifdimgreater{\@tempdima}{\textwidth}
    {
      \ClassError{sbc20}
        {
          \MessageBreak
          ***************************************\MessageBreak
          Together,~the~title~and~author~list~are\MessageBreak
          too~wide~for~the~page~header;~please\MessageBreak
          define~shortauthor~and/or~shorttitle.\MessageBreak
          ***************************************
        }
        {If~you~continue,~the~document~will~compile,\MessageBreak
         but~the~page~headers~will~be~wrong.}

      \ClassWarningNoLine{sbc20}
        {
          \MessageBreak
          **************************\MessageBreak
          Grudgingly~continuing~with\MessageBreak
          messed-up~page~headers.\MessageBreak
          **************************
        }
    }
    {}

}

\ExplSyntaxOff

\def\@declinfo{}
\def\@fundinginfo{}
\def\@acknowledgements{}
\def\@furtherinfo{}
\def\@datainfo{}
\def\@contributeinfo{}
\def\@aboutauthors{}
\def\@SBCprintbibliography{}

% Why \protected@xdef? No idea, just copied this from \@thanks ;) .
\newcommand\declinfo[1]{%
    \protected@xdef\@declinfo{\par
        \@declinfo\par
        \trim@spaces@noexp{#1}\par
    }%
}

\newcommand\funding[1]{%
    \protected@xdef\@fundinginfo{\par
        \@fundinginfo\par
        \trim@spaces@noexp{#1}\par
    }%
}

\newcommand\furtherinfo[1]{%
    \protected@xdef\@furtherinfo{\par
        \@furtherinfo\par
        \trim@spaces@noexp{#1}\par
    }%
}

\newcommand\datainfo[1]{%
    \protected@xdef\@datainfo{\par
        \@datainfo\par
        \trim@spaces@noexp{#1}\par
    }%
}

\newcommand\contributeinfo[1]{%
    \protected@xdef\@contributeinfo{\par
        \@contributeinfo\par
        \trim@spaces@noexp{#1}\par
    }%
}

\newcommand\acknowledgements[1]{%
    \protected@xdef\@acknowledgements{\par
        \@acknowledgements\par
        \trim@spaces@noexp{#1}\par
    }%
}

\newcommand\aboutauthors[1]{%
    \protected@xdef\@aboutauthors{\par
        \@aboutauthors\par
        \trim@spaces@noexp{#1}\par
    }%
}

\newcommand\SBCprintbibliography[1]{%
    \protected@xdef\@SBCprintbibliography{\par
        \SBCprintInitKeyBibliography\par
        \printbibliography\par
        \SBCprintEndKeyBibliography\par
        \trim@spaces@noexp{#1}\par
    }%
}

\ExplSyntaxOn
\newcommand\@SBCshowInstitutionsAsEndBlock{
  \@SBCformatInstitutions

  \seq_if_empty:NF \@SBCtextList
    {
      \begin{affiliationdetails}
      \seq_use:Nn \@SBCtextList {\quad\space}
      \end{affiliationdetails}
    }
}
\ExplSyntaxOff

\AtEndDocument{\par
  {\begin{decl}\@declinfo\end{decl}}
  
  \ifdefvoid{\@contributeinfo}
    {}
    {\begin{contributeinformation}\@contributeinfo\end{contributeinformation}}

  \ifdefvoid{\@aboutauthors}
    {}
    {\begin{authorinfo}\@aboutauthors\end{authorinfo}}

  \ifdefvoid{\@acknowledgements}
    {}
    {\begin{acks}\@acknowledgements\end{acks}}

  \ifdefvoid{\@fundinginfo}
    {}
    {\begin{fundinginformation}\@fundinginfo\end{fundinginformation}}

  \ifdefvoid{\@datainfo}
    {}
    {\begin{datainformation}\@datainfo\end{datainformation}}

  \ifdefvoid{\@furtherinfo}
    {}
    {\begin{furtherinformation}\@furtherinfo\end{furtherinformation}}

  \ifdefvoid{\@SBCprintbibliography}
    {}
    {\@SBCprintbibliography}

  \iftoggle{@SBCinstitutionsAtEnd}
    {\@SBCshowInstitutionsAsEndBlock}
    {}
}

%===============================================================================
% 12. Hyperlink support and PDF metadata (XMP)
%===============================================================================

\RequirePackage{url}
\urlstyle{sf}

\RequirePackage{hyperref}

% The choice of using colors or not can be modified
% by \metadata, so let's process this later on.
\AtEndPreamble{
  \iftoggle{@SBCcolorlinks}{
    \hypersetup{
      colorlinks=true, % also disables pdfborderstyle
      %citecolor=black,
      %linkcolor=black,
      %urlcolor=black,
      %filecolor=black,
      %anchorcolor=black,
      citecolor=DarkGreen,
      linkcolor=NavyBlue,
      urlcolor=DarkRed,
      filecolor=green,
      anchorcolor=black,
    }
  }{
    \hypersetup{
      colorlinks=false,
      pdfborder={0 0 .6},
      pdfborderstyle={/S/U/W .6},
      urlbordercolor=DodgerBlue,
      citebordercolor=White,
      linkbordercolor=White,
      filebordercolor=White,
    }
  }
}

\hyperbaseurl{http://} % make \url{www.example.com} do the right thing

% By default, hyperref links float references to the end of the float's
% caption. This package makes the reference point to the top of the float.
\usepackage[all]{hypcap}

% Since we want to support XMP metadata inside the generated PDF, hyperref
% is mandatory. Order matters: hyperxmp should be loaded after hyperref but
% before hyperref options related to metadata are defined.
\RequirePackage{hyperxmp}

% HACK ALERT! hyperxmp uses atenddvi, which has this bug:
% https://github.com/ho-tex/atenddvi/issues/1 . Apparently, this bug
% does not affect xelatex (check this discussion on a related bug:
% https://github.com/latex3/latex2e/issues/94 ), so we only need to
% worry about lualatex and pdflatex. With pdflatex, the package
% should not use atenddvi, but sometimes it does. With lualatex, it
% seems that hyperxmp does not really need atenddvi either (it does
% not use \write or \special with lualatex). So, we let hyperxmp
% load atenddvi but (1) prevent it from doing anything and (2) make
% hyperxmp use AtEndDocument to do its job, as with pdflatex. There
% is a comment about another workaround in the biblatex section, but
% we cannot assume only the bibliography might be affected.

% TODO: this bug is solved with the 2020-10-01 release of LaTeX,
%       which should be included in TeXlive 2021. Therefore, we
%       may eliminate this code in 2024.
\ifLuaTeX
    \let\AtEndDvi@AtBeginShipout\relax
    \let\AtEndDvi@CheckImpl\relax
    \let\hyxmp@at@end\AtEndDocument
\fi

% When defining the XMP metadata, the separator has to be a comma.
% Since we are not typesetting this, \unskip does not work; this
% means simply redefining \def might leave extra spaces here. That
% is not really a problem, but still...
\ExplSyntaxOn
\newcommand\@SBCsepToSemicolon[1]{\regex_replace_all:nnN {\s*\c{sep}\s*} {;\ } #1}
\ExplSyntaxOff

\AtEndPreamble{

  % Let's insert the metadata in the generated pdf file.

  % Empty fields are ignored by hyperxmp, so we can just do this
  % and skip testing whether the macros are undefined or empty.
  \providecommand{\@abstract}{}
  \providecommand{\@resumo}{}
  \providecommand{\@keywords}{}
  \providecommand{\@palavraschave}{}

  % Remove forced linebreaks and footnotes from the title
  % and abstract before adding it as PDF metadata.
  \let\@cleantitle\@title
  \let\@cleantranslatedtitle\@translatedtitle
  \let\@cleanabstract\@abstract
  \let\@cleanresumo\@resumo
  \let\@cleankeywords\@keywords
  \let\@cleanpalavraschave\@pchaves

  \@SBCremoveLinebreaksEtc{\@cleantitle}
  \@SBCremoveLinebreaksEtc{\@cleantranslatedtitle}
  \@SBCremoveLinebreaksEtc{\@cleanabstract}
  \@SBCremoveLinebreaksEtc{\@cleanresumo}

  \@SBCsepToSemicolon{\@cleankeywords}
  \@SBCsepToSemicolon{\@cleanpalavraschave}

  % TODO: check if we will use a different license
  % Now we actually add the metadata
  \iftoggle{@SBCenglish}
    {\def\@language{en}
      \hypersetup{
          pdflang={\@language},
          pdfmetalang={\@language},
          pdfauthor={\simpleAuthorList},
          pdftitle={\@cleantitle},
          pdfkeywords={\@cleankeywords}, % cannot be translated
          pdflicenseurl={https://creativecommons.org/licenses/by/4.0/},
          pdfinfo={
              templateVersion={1.0},
              % Informações de artigos
              language={\@language},
              titleOrig={\@cleantitle},
              titleEn={\@cleantitle},
              abstractOrig={\@cleanabstract},
              abstractEn={\@cleanabstract},
              keywordsOrig={\@cleankeywords},
              keywordsEn={\@cleankeywords},
              idjems={\@idjems},
              % 
              % Informações de autores
              authorListFirstName={\simpleAuthorFirstNameList},
              authorListMiddleName={\simpleAuthorMiddleNameList},
              authorListLastName={\simpleAuthorLastNameList},
              authorAffiliation={\simpleAuthorInstitutionList},
              authorCountry={\simpleAuthorCountryList},
              authorEmail={\simpleAuthorEmailList},
              orcid={\simpleAuthorOrcidList}
          },
        }
    }
    {\def\@language{pt}
      \hypersetup{
          pdflang={\@language},
          pdfmetalang={\@language},
          pdfauthor={\simpleAuthorList},
          pdftitle={\@cleantitle},
          pdfkeywords={\@cleanpalavraschave}, % cannot be translated
          pdflicenseurl={https://creativecommons.org/licenses/by/4.0/},
          pdfinfo={
              templateVersion={1.0},
              % Informações de artigos
              language={\@language},
              titleOrig={\@cleantitle},
              titleEn={\@cleantranslatedtitle},
              abstractOrig={\@cleanresumo},
              abstractEn={\@cleanabstract},
              keywordsOrig={\@cleanpalavraschave},
              keywordsEn={\@cleankeywords},
              idjems={\@idjems},
              % 
              % Informações de autores
              authorListFirstName={\simpleAuthorFirstNameList},
              authorListMiddleName={\simpleAuthorMiddleNameList},
              authorListLastName={\simpleAuthorLastNameList},
              authorAffiliation={\simpleAuthorInstitutionList},
              authorCountry={\simpleAuthorCountryList},
              authorEmail={\simpleAuthorEmailList},
              orcid={\simpleAuthorOrcidList}
          },
        }
    }


  \iftoggle{@SBCenglish}
    {
       \hypersetup{pdfsubject={\@cleanabstract}}
       %\XMPLangAlt{en}{pdfsubject={\@cleanabstract}}
       %\XMPLangAlt{en}{pdftitle={\@cleantranslatedtitle}}
    }
    {
       \hypersetup{pdfsubject={\@cleanresumo}}
       \XMPLangAlt{en}{pdfsubject={\@cleanabstract}}
       \XMPLangAlt{en}{pdftitle={\@cleantranslatedtitle}}
    }
  \def\do{} % https://github.com/plk/biblatex/issues/1105
}

%===============================================================================
% 13. Front matter layout (title, abstract, list of authors etc.)
%===============================================================================

\renewcommand{\maketitle}{
    % Prevent floats at the top of the page; since the article
    % class does this, it probably works correctly :). The value
    % is reset by \@startdblcolumn (defined in the LaTeX format).
    \global\@topnum\z@
    \thispagestyle{plain}

    % Code adapted from \maketitle as defined by the article class
    % to handle footnotes defined in the preamble (for example,
    % in \title). We first limit the changes to a group:
    \bgroup

    % Now temporarily disable hyperlink colors
    \hypersetup{hidelinks}

    % Then make footnotes that might appear in the abstract use the
    % \thanks & \@thanks mechanism. Footnotes in the title or the
    % authors use \titlethanks, defined earlier.
    \let\footnote\thanks

    % The paper is typeset in two columns, but the title, abstract etc.
    % are typeset in a single column. To do this, we insert this initial
    % material as the first argument of the \twocolumn command.
    \twocolumn [\@SBCtitleblock]

    % Typeset the footnotes from the title block and restore normal
    % footnote behavior. As mentioned before, we piggyback \@thanks and
    % process all the footnote classes defined with bigfoot/manyfoot
    % here too.
    \@thanks
    \egroup

    % Since \@thanks calls \footnotetext, which only works in outer
    % paragraph mode, \@thanks just inserted an empty line above. We
    % need to compensate for that.
    \par\vspace{-\baselineskip}

    % The first paragraph should not be indented, should not be preceded
    % by a page/column break, and should not have a widow line. This is
    % probably unnecessary, as the first paragraph will probably be
    % "\section{Introduction}", but let's cover all the bases.
    \@afterindentfalse\@afterheading

    % Most likely, the article will begin with "\section{Introduction}".
    % \section adds space before itself, except at the beginning of a
    % page or column. However, we just added an empty line, so we are
    % not at the start of the column anymore. To prevent the unwanted
    % extra space before "Introduction", we could just do \vspace{-X pt}
    % here. Unfortunately, that would break badly if the column did not
    % start with \section for some reason. Thankfully, \section uses
    % \addvspace. 30pt here simply means "something larger than the
    % space \section inserts before itself".
    \vspace{-30pt}\addvspace{30pt}

} % End of \maketitle


\newcommand{\@SBCtitleblock}{
    \bgroup

    \ifPDFTeX
      \renewcommand*\sfdefault{\fira@family} % From the FiraSans package
    \else
        \setsansfont{FiraSans}[
          Extension       = .otf,
          Numbers         = {Proportional,OldStyle},
          UprightFont     = *-Book,
          ItalicFont      = *-BookItalic,
          BoldFont        = *-Bold,
          BoldItalicFont  = *-BoldItalic,
        ]
    \fi

    \sffamily

    \LaTeXraggedright
    \hyphenrules{nohyphenation}

    \setlength{\parindent}{0pt}

    \rule{\linewidth}{.27pt}\par

    \vspace{4.5pt}
    {\footnotesize\scshape\bfseries\leavevmode\@articleCategory\par}

    \vspace{4pt}
    \bgroup
    \let\footnote\titlethanks
    \let\thanks\titlethanks
    \LARGE\bfseries\mathversion{bold}
    \@title\par
    \egroup

    \ifdefvoid{\@translatedtitle}
      {}
      {
        \vspace{4pt}
        \bgroup
          \let\footnote\titlethanks
          \let\thanks\titlethanks
          \fontsize{13}{17}\selectfont
          \bfseries\mathversion{bold}
          \textcolor{Gray}{\@translatedtitle}\par
        \egroup
      }

    \vspace{10pt}
    \bgroup
    \footnotesize
    \iftoggle{@SBCblind}
    {
      \@SBCshowAuthors\par
    }{}
    \egroup

    \ifboolexpr {togl {@SBCinstitutionsInBlock} or togl {@SBCinstitutionsInParagraph}}
      {
        \vspace{9.2pt}
        \bgroup
        % In case someone adds a footnote to an institution...
        \let\footnote\titlethanks
        \let\thanks\titlethanks
        \sffamily\tiny\itshape\@SBCshowInstitutionsAsBlock\par
        \egroup
      }
      {}

    \iftoggle{@SBCinstitutionsInFootnotes}{\@SBCshowInstitutionsAsFootnotes}{}

    \ifboolexpr
      {
        togl {@SBCinstitutionsInBlock} or
        togl {@SBCinstitutionsInParagraph} or
        togl {@SBCinstitutionsInFootnotes} or
        togl {@SBCinstitutionsAtEnd}
      }
      {}
      {
        \ifdefvoid{\@SBCextraAffiliationsFirst}
          {}
	  {\institutionthanks{\@SBCextraAffiliationsFirst}}

        \ifdefvoid{\@SBCextraAffiliationsLast}
          {}
	  {\institutionthanks{\@SBCextraAffiliationsLast}}
      }

    \vspace{6pt}
    \ifdefvoid{\@resumo}
      {}
      {
        \bgroup
        \expandafter\selectlanguage\expandafter{\@SBCpt} % reenable hyphenation
        \begin{SBCabstract}\@resumo\end{SBCabstract}
        \egroup
      }

    \ifdefvoid{\@abstract}
      {\ClassWarningNoLine{sbc20}{No abstract defined!}}
      {
        \bgroup
        \expandafter\selectlanguage\expandafter{\@SBCen} % reenable hyphenation
        \begin{SBCabstract}\@abstract\end{SBCabstract}
        \egroup
      }

    \vspace{4pt}
    \ifdefvoid{\@pchaves}
      {}
      {
        \bgroup
        \normalfont\small
        {\bfseries\scshape\MakeLowercase{Palavras-chave:\enspace\space}}\@pchaves\par
        \egroup
        \vspace{2pt}
      }

    \ifdefvoid{\@keywords}
      {\ClassWarningNoLine{sbc20}{No keywords defined!}}
      {
        \bgroup
        \normalfont\small        {\bfseries\scshape\MakeLowercase{Keywords:\enspace\space}}\@keywords\par
        \egroup
      }
    \par

    \vspace{-2pt}
    \rule{\linewidth}{.27pt}\par
    \vspace{13.2pt}

    \egroup
}

%==============================
% \@SBCshowAuthors and \@SBCshowInstitutionsAs{Block|Footnotes}
% typeset the author and institution lists. They do this by
% processing the contents of the sequence \@SBCtextList, which
% stores one author/institution per item. This list is populated
% by \@SBCformatAuthors and \@SBCformatInstitutions, called at
% the beginning of the @SBCshow* macros.
%
% \@SBCformat{Authors|Institutions*} call other \@SBCformat* macros to
% store the complete information for a single author or institution in
% the \@SBCtext macro. It is the contents of this macro that is added
% to the \@SBCtextList sequence.

\ExplSyntaxOn

% Iterators
\newcounter{authornum}
\newcounter{instnum}

\newbool{SBCdifferentInstitutions}

\AtEndPreamble{
  % Depending on the layout, there is no need to create reference
  % markers linking each author to the corresponding institutions
  % if all authors belong to the same institutions.

  \tl_set:Nx \l_tmpa_tl {\prop_item:Nn \@SBCauthorI {instids}}

  \setcounter{authornum}{1}
  \int_while_do:nNnn {\value{authornum}} < {\value{numberOfAuthors}} {
    \stepcounter{authornum}
    \tl_set:Nx \l_tmpb_tl {\prop_item:cn {@SBCauthor\Roman{authornum}} {instids}}
    \tl_if_eq:NNF \l_tmpa_tl \l_tmpb_tl
      {\booltrue{SBCdifferentInstitutions}}
  }
}

\newcommand\@SBCshowAuthors{
  \@SBCformatAuthors

  \bgroup
  \let\footnote\titlethanks
  \let\thanks\titlethanks

  \@SBCmeasureTextWidth{\@SBCorcidlogo\space}
  \dimgdef{\@SBCauthorIndent}{\@SBCtextWidth}

  \begin{list}
  {}
  {
    \rightmargin 0pt
    \parsep 0pt
    \partopsep 0pt
    \topsep 0pt
    \itemsep 0pt
    \leftmargin \@SBCauthorIndent
    \itemindent 0pt
  }
    % "-1.7cm" because the abstract has a right margin
    % of 0.7cm and we want to stay narrower than that
    \dimgdef{\@SBCavailableWidth}{\textwidth - \@SBCauthorIndent -1.7cm}

    \iftoggle{@SBCauthorsInParagraph}
      {
        \item[]\@SBCsqueezeText
               {right}
               {\@SBCavailableWidth}
               {0pt} % First line indent
               {\seq_use:Nn \@SBCtextList {\quad\quad}}\par
      }
      {
        \seq_map_inline:Nn \@SBCtextList {
          \item[]##1
          \ifboolexpr
            {
              togl {@SBCinstitutionsInBlock} or
              togl {@SBCinstitutionsInParagraph} or
              togl {@SBCinstitutionsInFootnotes} or
              togl {@SBCinstitutionsAtEnd}
            }
            {}
            {\vspace{.3\baselineskip}}%
          \par
        }
      }
  \end{list}\par
  \egroup
}

\newcommand\@SBCformatAuthors{
  \seq_clear_new:N \@SBCtextList

  % Build the formatted text for each author in
  % \@SBCtext and register the result in \@SBCtextList
  \setcounter{authornum}{0}
  \int_while_do:nNnn {\value{authornum}} < {\value{numberOfAuthors}} {

      \stepcounter{authornum}
      \tl_gclear_new:N \@SBCcurrAuthor
      \tl_gset:Nx \@SBCcurrAuthor {@SBCauthor\Roman{authornum}}

      \tl_gclear_new:N \@SBCtext

      \@SBCformatAuthorOrcid
      \@SBCformatAuthorName

      \ifboolexpr
        {
          togl {@SBCinstitutionsInBlock} or
          togl {@SBCinstitutionsInParagraph} or
          togl {@SBCinstitutionsInFootnotes} or
          togl {@SBCinstitutionsAtEnd}
        }
        {
          \@SBCformatAuthorInstitutions
          \@SBCformatAuthorCountry
          \@SBCformatAuthorEmail
        }
        {
          \@SBCformatAuthorEmail
          \@SBCformatAuthorInstitutions
        }

      \tl_if_blank:VF \@SBCtext
        {\seq_put_right:NV \@SBCtextList \@SBCtext}
  }
}

% We may put the institutional information that is separated from
% the list of authors as a block of text, probably below the list
% of authors.
\newcommand\@SBCshowInstitutionsAsBlock{
  \@SBCformatInstitutions

  % Don't know why we need to add "\," to align the beginning of
  % the institution name with the beginning of the author name;
  % should be only \@SBCorcidlogo\space...
  \@SBCmeasureTextWidth{\@SBCorcidlogo\space\,}
  \dimgdef{\@SBCauthorIndent}{\@SBCtextWidth}

  \begin{list}
    {}
    {
      \leftmargin \@SBCauthorIndent
      \rightmargin 0pt
      \parsep 0pt
      \partopsep 0pt
      \topsep 0pt
    }%
    \item[]%
    % "-1.7cm" because the abstract has a right margin
    % of 0.7cm and we want to stay narrower than that
    \dimgdef{\@SBCavailableWidth}{\textwidth - \leftmargin -1.7cm}%
    \@SBCsqueezeText
      {right}
      {\@SBCavailableWidth}
      {0pt}
      {%
        \iftoggle{@SBCinstitutionsInParagraph}
          {\seq_use:Nn \@SBCtextList {\quad\quad}\par}
          {\seq_use:Nn \@SBCtextList {\par}\par}%
      }%
  \end{list}\par
}

% We may present the institutional information that
% is separated from the list of authors as footnotes.
\newcommand\@SBCshowInstitutionsAsFootnotes{
  \@SBCformatInstitutions
  \seq_map_inline:Nn \@SBCtextList {\institutionthanks{##1}}
}

\newcommand\@SBCformatInstitutions{
  \seq_clear_new:N \@SBCtextList

  \setcounter{instnum}{0}
  \int_while_do:nNnn {\value{instnum}} < {\value{numberOfInstitutions}} {
    \stepcounter{instnum}
    \tl_gclear_new:N \@SBCcurrInst
    \tl_gset:Nx \@SBCcurrInst {@SBCinst\Roman{instnum}}

    \tl_clear_new:N \@SBCtext

    \@SBCformatInstitutionMarker
    \@SBCformatInstitutionName

    \tl_if_blank:VF \@SBCtext
      {\seq_put_right:NV \@SBCtextList \@SBCtext}
  }

  \ifdefvoid{\@SBCextraAffiliationsLast}
    {}
    {\seq_put_right:NV \@SBCtextList \@SBCextraAffiliationsLast}

  \ifdefvoid{\@SBCextraAffiliationsFirst}
    {}
    {\seq_put_left:NV \@SBCtextList \@SBCextraAffiliationsFirst}
}


%==============================
% Now the support macros (\@SBCformat"Something").

\newcommand\@SBCformatAuthorName{
  \tl_put_right:Nn \@SBCtext {\bgroup\bfseries}
  \tl_put_right:Nx \@SBCtext {\prop_item:cn {\@SBCcurrAuthor} {name}}
  \tl_put_right:Nn \@SBCtext {\egroup}
}

\newcommand\@SBCformatAuthorOrcid{
  \prop_if_in:cnTF {\@SBCcurrAuthor} {orcid} {

      % Build the URL for href; note that, in LaTeX3 context (ExplSyntaxOn),
      % the colon is a "letter", so we need to treat it specially here,
      % otherwise \href does not figure out the schema correctly.
      \tl_set:Nf \l_tmpa_tl {\prop_item:cn {\@SBCcurrAuthor} {orcid}}
      \tl_put_left:Nx \l_tmpa_tl {https\c_colon_str//orcid.org/}

      \tl_put_right:Nn \@SBCtext{\href}
      \tl_put_right:Nx \@SBCtext{{\exp_not:V\l_tmpa_tl}}
      \tl_put_right:Nn \@SBCtext{{\@SBCorcidlogo}\nobreak\space\nobreak}
  }
  {\tl_put_right:Nn \@SBCtext {\phantom{\@SBCorcidlogo\space}\nobreak}}

  % Based on \@makefntext: typeset the marker to the left of
  % the current paragraph margin. Works in the middle of the
  % line too: in this case, the marker appears to the left of
  % the current position in the line, which works well for us.
  % Why do this with the orcid logo? Because if we have multiple
  % authors on a single paragraph, ordinary linebreaks will be
  % indented but linebreaks that put the orcid logo at the
  % beginning of the line will not, making the logos align (if
  % you experiment a bit with the authorsInParagraph option you
  % will understand what this does).
  \tl_set:Nx \@SBCtext {
    \exp_not:n {\noindent \hbox to \z@}
    {\exp_not:N \hss \exp_not:V \@SBCtext}
  }
}

\newcommand\@SBCformatAuthorEmail{
  \prop_if_in:cnT {\@SBCcurrAuthor} {email} {
      \tl_put_right:Nn \@SBCtext {\@SBCsep}

      % Build the URL for href; see the comment in \@SBCformatAuthorOrcid
      \tl_set:Nf \l_tmpa_tl {\prop_item:cn {\@SBCcurrAuthor} {email}}
      \tl_put_left:Nx \l_tmpa_tl {mailto\c_colon_str}

      \tl_put_right:Nn \@SBCtext{\href}
      \tl_put_right:Nx \@SBCtext{{\exp_not:V\l_tmpa_tl}}
      \tl_put_right:Nn \@SBCtext {{\@SBCenvelope}\nobreak\space\nobreak}
      \tl_put_right:Nx \@SBCtext {\prop_item:cn {\@SBCcurrAuthor} {email}}
  }
}

\newcommand\@SBCformatAuthorCountry{
  \prop_if_in:cnT {\@SBCcurrAuthor} {country} {
    \tl_put_right:Nn \@SBCtext {\nobreak\space\nobreak(}
    \tl_put_right:Nx \@SBCtext {\prop_item:cn {\@SBCcurrAuthor} {country}}
    \tl_put_right:Nn \@SBCtext {)}
  }
}

\newcommand\@SBCformatAuthorInstitutions{
  % We will collect the fake markers for the institutions
  % to display them in superscript text later on.
  \seq_gclear_new:N \@SBCmarkersList

  \exp_args:NNx \seq_gset_from_clist:Nn \l_tmpa_seq {\prop_item:cn {\@SBCcurrAuthor} {instids}}

  \seq_map_variable:NNn \l_tmpa_seq \l_tmpa_tl {
    \prop_get:NVN \@SBCinstIDsMap \l_tmpa_tl \@SBCcurrInst

    \quark_if_no_value:NTF \@SBCcurrInst
      {
        \ClassError{sbc20}
          {
            \MessageBreak
            ***********************\MessageBreak
            Cannot~find~institution\MessageBreak
            with~ID=\l_tmpa_tl.\MessageBreak
            ***********************\MessageBreak
          }
          {If~you~continue,~only~parts~of~its~data~will~be~presented.}

        \ClassWarningNoLine{sbc20}
          {
            \MessageBreak
            **************************\MessageBreak
            Grudgingly~continuing~with\MessageBreak
            missing~institution.\MessageBreak
            **************************
          }
      }
      {
      % Remember the marker for this institution
      \seq_gput_right:Nx \@SBCmarkersList {\prop_item:cn {\@SBCcurrInst} {marker}}

      % write out the institutions, either one at a time...
      \ifboolexpr
        {
          togl {@SBCinstitutionsInBlock} or
          togl {@SBCinstitutionsInParagraph} or
          togl {@SBCinstitutionsInFootnotes} or
          togl {@SBCinstitutionsAtEnd}
        }
        {}
        {\@SBCformatAuthorInstitution}
      }
  }
  % ... or just the markers, all at once
  \ifboolexpr
    {
      togl {@SBCinstitutionsInBlock} or
      togl {@SBCinstitutionsInParagraph} or
      togl {@SBCinstitutionsInFootnotes} or
      togl {@SBCinstitutionsAtEnd}
    }
    {\@SBCformatAuthorInstitutionMarkers}
    {}
}

\newcommand\@SBCformatAuthorInstitution{
  \tl_put_right:Nn \@SBCtext {\newline}
  \tl_put_right:Nn \@SBCtext {\bgroup\itshape\scriptsize}
  \tl_put_right:Nx \@SBCtext {\prop_item:cn {\@SBCcurrInst} {name}}
  \tl_put_right:Nx \@SBCtext {\space ( \prop_item:cn {\@SBCcurrInst} {id})}
  \tl_put_right:Nn \@SBCtext {\egroup}
}

\newcommand\@SBCformatAuthorInstitutionMarkers{
  \ifbool{SBCdifferentInstitutions}
    {
      \xdef\@tempa{\seq_use:Nn \@SBCmarkersList {,\,}}
      \tl_put_right:Nx \@SBCtext {\exp_not:N\@SBCtextsuperscriptlarger}
      \tl_put_right:Nx \@SBCtext {{\,\@tempa}}
    }
    {}
}

\newcommand\@SBCformatInstitutionMarker{
  \ifbool{SBCdifferentInstitutions}
    {
      \tl_set:Nx \@SBCtext {\exp_not:N\textsuperscript}
      \tl_put_right:Nx \@SBCtext {{\prop_item:cn{\@SBCcurrInst} {marker}}}

      % Based on \@makefntext: typeset the marker to the left of
      % the current paragraph margin. Works in the middle of the
      % line too: in this case, the marker appears to the left of
      % the current position in the line, which works well for us.
      \tl_set:Nx \@SBCtext {
        \exp_not:n {\noindent \hbox to \z@}
        {\exp_not:N \hss \exp_not:V \@SBCtext \,}
      }
    }
    {}
}

\newcommand\@SBCformatInstitutionName{
  \tl_put_right:Nn \@SBCtext {\bgroup}
  % TODO: use bullet (default) or endash as separator?
  \tl_put_right:Nn \@SBCtext {\renewrobustcmd\sep{\@SBChyphensep}}
  \tl_put_right:Nx \@SBCtext {\prop_item:cn {\@SBCcurrInst} {name}}
  \tl_put_right:Nn \@SBCtext {\egroup}
}

\ExplSyntaxOff


%=======================================================================
% 14. Auxiliary macros: ORCID and envelope logos
%=======================================================================

% This orcid-related code is based on the orcidlink package v1.0.3.
% More information about the orcid brand and a link to the official
% logo are available at https://info.orcid.org/brand-guidelines/ .
\RequirePackage{tikz}
\usetikzlibrary{svg.path}
\definecolor{orcidcolor}{HTML}{A6CE39}

\tikzset{
  orcidlogo/.pic={
    \fill[orcidcolor]
        svg{M256,128c0,70.7-57.3,128-128,128C57.3,256,0,198.7,0,128C0,
            57.3,57.3,0,128,0C198.7,0,256,57.3,256,128z};

    \fill[white]
        svg{M86.3,186.2H70.9V79.1h15.4v48.4V186.2z}

        svg{M108.9,79.1h41.6c39.6,0,57,28.3,57,53.6c0,27.5-21.5,53.6-56.8,
            53.6h-41.8V79.1z M124.3,172.4h24.5c34.9,0,42.9-26.5,
            42.9-39.7c0-21.5-13.7-39.7-43.7-39.7h-23.7V172.4z}

        svg{M88.7,56.8c0,5.5-4.5,10.1-10.1,10.1c-5.6,
            0-10.1-4.6-10.1-10.1c0-5.6,4.5-10.1,10.1-10.1C84.2,
            46.7,88.7,51.3,88.7,56.8z};
  }
}

\newsavebox{\@SBCorcidlogobox}
\sbox{\@SBCorcidlogobox}{%
  \raisebox{-.1em}{%
    \mbox{%
      \hspace{.5pt}%
      \begin{tikzpicture}
        [
          % the code above generates a 256pt logo; scale to 7.7pt
          yscale=-7.7/256,
          xscale=7.7/256,
          transform shape,
        ]
          \pic{orcidlogo};
      \end{tikzpicture}%
      \hspace{.8pt}%
    }%
  }%
}

\newrobustcmd{\@SBCorcidlogo}{\usebox{\@SBCorcidlogobox}}

% Envelope from https://openclipart.org/detail/261678
\tikzset{
  envelope/.pic={
    \fill
        svg{M498.208,68.235c-8.945-8.947-19.701-13.418-32.261-13.418
            H45.682c-12.562,0-23.318,4.471-32.264,13.418
            C4.471,77.18,0,87.935,0,100.499v310.633c0,12.566,4.471,23.312,
            13.418,32.257c8.945,8.953,19.701,13.422,32.264,13.422h420.266
            c12.56,0,23.315-4.469,32.261-13.422c8.949-8.945,13.418-19.697,
            13.418-32.257V100.499
            C511.626,87.935,507.158,77.18,498.208,68.235z M475.078,
            411.125c0,2.475-0.903,4.616-2.714,6.424
            c-1.81,1.81-3.949,2.706-6.42,2.706H45.679c-2.474,
            0-4.616-0.896-6.423-2.706c-1.809-1.808-2.712-3.949-2.712-6.424
            V191.858
            c6.09,6.852,12.657,13.134,19.7,18.843c51.012,39.209,91.553,
            71.374,121.627,96.5c9.707,8.186,17.607,14.561,23.697,19.13
            c6.09,4.571,14.322,9.185,24.694,13.846c10.373,4.668,20.129,
            6.991,29.265,6.991h0.287h0.284c9.134,0,18.894-2.323,29.263-6.991
            c10.376-4.661,18.613-9.274,24.701-13.846c6.089-4.569,13.99-10.944,
            23.698-19.13c30.074-25.126,70.61-57.291,121.624-96.5
            c7.043-5.708,13.613-11.991,19.694-18.843V411.125L475.078,411.125z
            M475.078,107.92v3.14c0,11.229-4.421,23.745-13.271,37.543
            c-8.851,13.798-18.419,24.792-28.691,32.974c-36.74,28.936-74.897,
            59.101-114.495,90.506c-1.14,0.951-4.474,3.757-9.996,8.418
            c-5.514,4.668-9.894,8.241-13.131,10.712c-3.241,2.478-7.471,
            5.475-12.703,8.993c-5.236,3.518-10.041,6.14-14.418,7.851
            c-4.377,1.707-8.47,2.562-12.275,2.562h-0.284h-0.287c-3.806,
            0-7.895-0.855-12.275-2.562c-4.377-1.711-9.185-4.333-14.417-7.851
            c-5.231-3.519-9.467-6.516-12.703-8.993
            c-3.234-2.471-7.614-6.044-13.132-10.712
            c-5.52-4.661-8.854-7.467-9.995-8.418
            c-39.589-31.406-77.75-61.57-114.487-90.506
            c-27.981-22.076-41.969-49.106-41.969-81.083c0-2.472,
            0.903-4.615,2.712-6.421
            c1.809-1.809,3.949-2.714,6.423-2.714h420.266c1.52,0.855,2.854,
            1.093,3.997,0.715c1.143-0.385,1.998,0.331,2.566,2.138
            c0.571,1.809,1.095,2.664,1.57,2.57c0.477-0.096,0.764,1.093,
            0.859,3.571c0.089,2.473,0.137,3.718,0.137,3.718V107.92
            L475.078,107.92z};
  }
}

\newsavebox{\@SBCenvelopebox}
\sbox{\@SBCenvelopebox}{%
  \raisebox{-.065em}{%
    \mbox{%
      \begin{tikzpicture}
        [
          yscale=-.017578125,
          xscale=.017578125,
          transform shape,
        ]
          \pic{envelope};
      \end{tikzpicture}%
    }%
  }%
}

\newrobustcmd\@SBCenvelope{\usebox{\@SBCenvelopebox}}


\ExplSyntaxOn

%=======================================================================
% 15. Auxiliary macros: removeLineBreaksEtc
%=======================================================================

% \@shorttitle and all PDF metadata should not have forced linebreaks
% or footnotes. hyperref and hyperxmp automatically remove them, but
% this may cause two words to end up with no space between them. Let's
% define an auxiliary macro to do this more carefully.

% First, let's define the regex we will need. What we are
% doing here is "(regex1)|(regex2)|(regex3)|(regex4)"
\regex_const:Nn \@SBCbreakRegex
  {
    ( \c{break} ) % Matches "\break"
    |
    ( \c{newline} ) % Matches "\newline"
    |
      % This matches:
      % 1. The control sequence "\linebreak" -> "\c{linebreak}"
      % 2. Optionally followed by "[NUMBER]" -> "( \s*\x{5B}\s*\d\s*\x{5D} )?"
    ( \c{linebreak} (\s*\x{5B}\s*\d\s*\x{5D})? )
    |
      % This matches:
      % 1. The control sequence "\\" (forced line break) -> "\c{\\}"
      % 2. Optionally followed by "[...]" -> "( \s*\x{5B}\s*...\s*\x{5D} )?"
      % 3. Where "..." is any valid TeX dimension
      %    (see regex example in texdoc interface3)
    ( \c{\\}
      ( \s*\x{5B}\s*
          [\+\-]?(\d+|\d*\.\d+)\s*((?i)pt|in|[cem]m|ex|[bs]p|[dn]d|[pcn]c)
        \s*\x{5D}
      )?
    )
  }

\newcommand{\@SBCremoveLinebreaksEtc}[1]{
    % Replace all line breaks with spaces
    \regex_replace_all:NnN \@SBCbreakRegex {\ } #1

    % Kill footnotes
    \regex_replace_all:nnN {\s*\c{footnote}} {\c{@gobble}} #1
    \regex_replace_all:nnN {\s*\c{thanks}} {\c{@gobble}} #1

    % Make URLs plain text
    \regex_replace_all:nnN {\c{url}} {\c{@firstofone}} #1

    % All this may leave consecutive white spaces behind; remove them
    \regex_replace_all:nnN {\s+} {\ } #1
}


%=======================================================================
% 16. Auxiliary macros: squeezeText and related material
%=======================================================================

% Typeset the given text ragged left/right with less horizontal space,
% so that the last line is approximately the same size of the others.
% We achieve this by manipulating \rightskip and \parfillskip (see
% the ragged2e docs).

% Parameter 1: right or left (right -> raggedright; left -> raggedleft)
% Parameter 2: available (maximum) width
% Parameter 3: first line indent (positive or negative)
% Parameter 4: text to be typeset
\newcommand{\@SBCsqueezeText}[4]{

    \bgroup
    \hyphenrules{nohyphenation}
    % Suppress over/underfull hbox warnings, they are irrelevant here
    \hfuzz=50pt
    \hbadness=\@M

    % If the user defined manual linebreaks, do nothing (numLines = 1).
    % Otherwise, set \@SBCnumLines (the total text width divided by the
    % available width, rounded up) and \@SBCsqueeze (how much we should
    % reduce the width of the lines so that the same division yields an
    % integer).
    \exp_args:NNo\regex_match:NnTF \@SBCbreakRegex {#4}
      {\def\@SBCnumLines{1}}
      {\@SBCcalculateSqueezeNumLines{#2}{#3}{#4}}

    \ifnumgreater{\@SBCnumLines}{1}
      {
        % Spread the text evenly among the lines by reducing
        % each line width by approximately \@SBCsqueeze. These
        % values (.6, 10em etc.) are educated (ok, wild) guesses :)
        \dimdef\@SBCplusSqueeze{.6\dimexpr\@SBCsqueeze\relax}
        \ifdimless{\@SBCplusSqueeze}{10em}{\dimdef{\@SBCplusSqueeze}{10em}}{}
        \dimdef\@SBCminusSqueeze{.65\dimexpr\@SBCplusSqueeze\relax}
        \ifdimless{\@SBCsqueeze}{\@SBCminusSqueeze}{\dimdef{\@SBCminusSqueeze}{\@SBCsqueeze}}{}

        \RaggedRightRightskip \@SBCsqueeze plus \@SBCplusSqueeze minus \@SBCminusSqueeze
        \RaggedLeftLeftskip \@SBCsqueeze plus \@SBCplusSqueeze minus \@SBCminusSqueeze
        \RaggedRightParfillskip 2em plus 0pt minus 2em\relax
        \RaggedLeftParfillskip 0pt\relax

        \ifstrequal{#1}{right}
          {\RaggedRight}
          {\RaggedLeft}
      }
      {
        % For a single line, allow shrinking (see \@SBCcalculateSqueezeNumLines)
        \ifstrequal{#1}{right}
          {\LaTeXraggedright}
          {\LaTeXraggedleft}
      }

    #4\par
    \egroup
}

% Figure out the text width. To obtain this measurement, we typeset the
% text in a box and then throw it away. Therefore, we need to prevent
% footnotes from being processed here, otherwise they will be duplicated
% when we typeset the text for real (this also affects the calc package).
\newcounter{@SBCtmpcount}
\newcommand\@SBCmeasureTextWidth[1]{
  \setcounter{@SBCtmpcount}{\value{footnotetitle}} % Save the counter
  \bgroup
  % Only typeset the marker, not the actual footnote
  \renewcommand\titlethanks[1]{\footnotemarktitle}
  \let\footnote\titlethanks
  \let\thanks\titlethanks
  \hbox_gset:Nn \l_tmpa_box {#1}
  \egroup
  \setcounter{footnotetitle}{\value{@SBCtmpcount}} % Restore the counter
  \dimgdef{\@SBCtextWidth}{\box_wd:N \l_tmpa_box}
}

% Figure out how many lines a given text will occupy *and* how much to reduce
% horizontal space to make all lines have approximately the same width.
%
% Parameter 1: available width
% Parameter 2: first line indent
% Parameter 3: the text to process
%
% Globally sets \@SBCnumLines and \@SBCsqueeze
\newcommand\@SBCcalculateSqueezeNumLines[3]{
  \@SBCmeasureTextWidth{#3} % register the text size in \@SBCtextWidth

  % If the first line is indented, the length of the text we will
  % divide among the lines should include that extra space. This
  % also works if the indentation is negative, i.e., the first
  % line is "outdented" - think about it :).
  \dimdef{\@SBCtextWidth}{\@SBCtextWidth + #2}

  % The nominal width of a space in libertinus at 11pt is 2.7375pt, but
  % that can be squeezed down to 1.825pt. In Fira Sans, these are 2.9346pt
  % and 1.4673pt respectively (you may obtain these values with
  % \number\fontdimen2\font\relax and \number\fontdimen3\font\relax ; see
  % https://tex.stackexchange.com/questions/88991/what-do-different-fontdimennum-mean ).
  % With some 6 spaces, TeX may choose to make the line up to 5.47pt
  % smaller than its nominal width in libertinus or 8.82pt in Fira Sans.
  % Since we prefer not to break lines, let's pretend the text size is a
  % little smaller so that we only break lines if it would not fit even
  % with some shrink. Note that \RaggedRight/Left never shrinks spaces,
  % only \LaTeXraggedright/left.
  \dimdef{\@SBCtextWidth}{\@SBCtextWidth - 4pt}

  % How many lines do we need to typeset the text in the space we have?
  \edef\@tempa{
      \int_div_truncate:nn
          {\dim_to_decimal_in_sp:n{\@SBCtextWidth}}
          {\dim_to_decimal_in_sp:n{#1}}
  }
  \xdef\@SBCnumLines{\int_eval:n{\@tempa + 1}}

  % We want each line of text to have approximately this width
  \dimdef{\@SBCgoalTextWidth}{\@SBCtextWidth / \@SBCnumLines}

  % To do this, we need to increase the margins by approximately this amount
  \dimgdef{\@SBCsqueeze}{#1 - \@SBCgoalTextWidth}
}

\ExplSyntaxOff

\endinput
