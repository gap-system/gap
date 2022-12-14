#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler / Frank Lübeck.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  The  files  helpdef.g{d,i}  contain  the  `default'  help  book  handler
##  functions, which implement access of GAP's online help to help documents
##  produced  from `gapmacro.tex'-  .tex and  .msk files  using buildman.pe,
##  tex, pdftex and convert.pl.
##
##  The function  which converts the  TeX sources  to text for  the "screen"
##  viewer is outsourced into `helpt2t.g{d,i}'.
##

DeclareGlobalFunction("GapLibToc2Gap");
DeclareGlobalName("HELP_CHAPTER_BEGIN");
DeclareGlobalName("HELP_SECTION_BEGIN");
DeclareGlobalName("HELP_FAKECHAP_BEGIN");
DeclareGlobalName("HELP_PRELCHAPTER_BEGIN");
DeclareGlobalFunction("HELP_CHAPTER_INFO");
DeclareGlobalFunction("HELP_PRINT_SECTION_URL");
DeclareGlobalFunction("HELP_PRINT_SECTION_MAC_IC_URL");

