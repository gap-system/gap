#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Lübeck.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  The  files  pager.g{d,i}  contain  the `Pager'  utility.  A  rudimentary
##  version of this  was integrated in first versions of  GAP's help system.
##  But this utility is certainly useful for other purposes as well.
##

#############################################################################
##
#F  Pager( <lines> ) . . . . . . . . . . . . display text on screen in a pager

##  <#GAPDoc Label="Pager">
##  <ManSection>
##  <Func Name="Pager" Arg='lines'/>
##
##  <Description>
##  This function can be used to display a text on screen using a pager,
##  i.e., the text is shown page by page.
##  <P/>
##  There is a default builtin pager in &GAP; which has very limited
##  capabilities but should work on any system.
##  <P/>
##  At least on a UNIX system one should use an external pager program like
##  <C>less</C> or <C>more</C>.
##  &GAP; assumes that this program has command line options <C>+nr</C> and
##  <C>+/str</C> which start the display of the text with line number
##  <C>nr</C> or at the line with the first occurrence of the string
##  <C>str</C>.
##  <P/>
##  Which pager is used can be controlled by setting the user preference
##  <C>"Pager"</C>.
##  The default value is <C>"builtin"</C>
##  which means that the internal pager is used.
##  <P/>
##  On UNIX systems you probably want to set the user preference
##  <C>"Pager"</C> to the value <C>"less"</C> or <C>"more"</C>,
##  you can do this for example in your <F>gap.ini</F>
##  file (see <Ref Sect="sect:gap.ini"/>).
##  In that case you can also tell &GAP; a list of standard options for the
##  external pager, via the user preference <C>"PagerOptions"</C>.
##  <P/>
##  <Log><![CDATA[
##    SetUserPreference( "Pager", "less" );
##    SetUserPreference( "PagerOptions", ["-f","-r","-a","-i","-M","-j2"] );
##  ]]></Log>
##  <P/>
##  The argument <A>lines</A> can have one of the following forms:
##  <P/>
##  <Enum>
##  <Item>
##   a string (i.e., lines are separated by newline characters)
##  </Item>
##  <Item>
##   a list of strings (without  newline characters)
##  which are interpreted as lines of the text to be shown
##  </Item>
##  <Item>
##   a record with component <C>lines</C> as in 1. or 2. and
##  optional further components
##  </Item>
##  </Enum>
##  <P/>
##  In case&nbsp;3. currently the following additional components are used:
##  <P/>
##  <List>
##  <Mark><C>formatted</C></Mark>
##  <Item>
##    can be <K>false</K> or <K>true</K>.
##    If set to <K>true</K> the builtin pager tries to show the text exactly
##    as it is given (avoiding &GAP;'s automatic line breaking),
##  </Item>
##  <Mark><C>start</C></Mark>
##  <Item>
##    must be a positive integer or a string.
##    An integer is interpreted as the number of the first line shown by the
##    pager, a string is interpreted as a search string such that the first
##    line containing this string is the first line shown by the pager
##    (in both cases, one may see the beginning of the text via back
##    scrolling),
##  </Item>
##  <Mark><C>exitAtEnd</C></Mark>
##  <Item>
##    can be <K>false</K> or <K>true</K>.
##    If set to <K>true</K> (the default), the builtin pager is terminated
##    as soon as the end of the list is shown;
##    otherwise entering the <B>q</B> key is necessary in order to return
##    from the pager.
##  </Item>
##  </List>
##  <P/>
##  The <Ref Func="Pager"/> command is used by &GAP;'s help system for
##  displaying help sections in text format.
##  But, of course, it may be used for other purposes as well.
##  <P/>
##  <Log><![CDATA[
##  gap> s6 := SymmetricGroup(6);;
##  gap> words := ["This", "is", "a", "very", "stupid", "example"];;
##  gap> l := List(s6, p-> Permuted(words, p));;
##  gap> Pager(List(l, a-> JoinStringsWithSeparator(a," ")));;
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareGlobalFunction("Pager");

