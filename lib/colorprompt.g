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
##  A demo for customizing the GAP prompt.
##
##  To switch off the coloring of prompt and input call
##     ColorPrompt(false);
##
##  The variable ANSI_COLORS used in earlier versions is no longer
##  supported, see GAPInfo.UserPreferences.UseColorsInTerminal.
##

# see comment below
if not IsBound(STDOut) then
  BindGlobal("STDOut", OutputTextUser());
else
  Info(InfoWarning, 1, "You probably have an 'ReadLib(\"colorprompt.g\");'",
                        " in your .gaprc file.");
  Info(InfoWarning, 1, "Its functionality is now in the GAP library.");
  Info(InfoWarning, 1, "Use now 'SetUserPreference(\"UseColorPrompt\", true);\
 in your 'gap.ini' file.");
fi;

# same behaviour as with unbound functions
PrintPromptHook := CPROMPT;
EndLineHook := function() end;

############################################################################
##
#F  ColorPrompt( <bool> ) . . . . . . (un)set using a colored prompt and input
#F  ColorPrompt( <bool>, <optrec> ) . . . . . . . . .  same with customization
##
##  <#GAPDoc Label="ColorPrompt">
##  <ManSection>
##  <Func Name="ColorPrompt" Arg='bool[, optrec]'/>
##
##  <Description>
##  <Ref Func="ColorPrompt"/> changes &GAP;'s user interface:
##  After calling <C>ColorPrompt(true);</C>,
##  the prompts and the user input are displayed in colors different from
##  the color that is used for the output.
##  This is also the default for a &GAP; session.
##  Switch off these colorings with <C>ColorPrompt(false);</C>.
##  <P/>
##  Note that colors will only work  if your terminal emulation  in which
##  you run &GAP; understands the so called ANSI color escape sequences
##  &ndash;almost all  terminal emulations  on current  UNIX/Linux
##  (<C>xterm</C>, <C>rxvt</C>, <C>konsole</C>, ...) systems do so.
##  <P/>
##  The colors shown depend on  the terminal configuration and cannot be
##  forced  from  an application.  If  your  terminal follows  the  ANSI
##  conventions you see  the standard prompt in bold blue  and the break
##  loop prompt in bold red, as well as your input in red.
##  <P/>
##  If you prefer to switch off colors for prompts and input at the start
##  of your &GAP; sessions, put a call of
##  <C>SetUserPreference("UseColorPrompt", false);</C>
##  in your <F>gap.ini</F> file.
##  If you want a more complicated setting as explained below then
##  put your <C>SetUserPreference("UseColorPrompt", rec( ... ) );</C>
##  call into your <F>gaprc</F> file.
##  <P/>
##  The optional second argument <A>optrec</A> allows one to further
##  customize the behaviour.
##  It must be a record from which the following components are recognized:
##  <P/>
##  <List>
##  <Mark><C>MarkupStdPrompt</C></Mark>
##  <Item>
##    a string or no argument function returning a string
##    containing the escape sequence used for the main prompt <C>gap> </C>.
##  </Item>
##  <Mark><C>MarkupContPrompt</C></Mark>
##  <Item>
##    a string or no argument function returning a string
##    containing the escape sequence used for the continuation prompt
##    <C>> </C>.
##  </Item>
##  <Mark><C>MarkupBrkPrompt</C></Mark>
##  <Item>
##    a string or no argument function returning a string
##    containing the escape sequence used for the break prompt
##    <C>brk...> </C>.
##  </Item>
##  <Mark><C>MarkupInput</C></Mark>
##  <Item>
##    a string or no argument function returning a string
##    containing the escape sequence used for user input.
##  </Item>
##  <Mark><C>TextPrompt</C></Mark>
##  <Item>
##    a no argument function returning the string with the text
##    of the prompt, but without any escape sequences.
##    The current standard prompt is returned by <C>CPROMPT()</C>.
##    But note that changing the standard prompts makes the automatic removal
##    of prompts from input lines impossible
##    (see&nbsp;<Ref Sect="Special Rules for Input Lines"/>).
##  </Item>
##  <Mark><C>PrePrompt</C></Mark>
##  <Item>
##    a function called before printing a prompt.
##  </Item>
##  </List>
##  <P/>
##  Here is an example.
##  <P/>
##  <Listing><![CDATA[
##  LoadPackage("GAPDoc");
##  timeSHOWMIN := 100;
##  ColorPrompt(true, rec(
##     # usually cyan bold, see ?TextAttr
##     MarkupStdPrompt := Concatenation(TextAttr.bold, TextAttr.6),
##     MarkupContPrompt := Concatenation(TextAttr.bold, TextAttr.6),
##     PrePrompt := function()
##       # show the 'time' automatically if at least timeSHOWMIN
##       if CPROMPT() = "gap> " and time >= timeSHOWMIN then
##         Print("Time of last command: ", time, " ms\n");
##       fi;
##     end)    );
##  ]]></Listing>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "ColorPrompt", function(arg)
  local b, r, a;
  b := arg[1];
  r := rec(
         MarkupStdPrompt := "\033[1m\033[34m",
         MarkupContPrompt := "\033[1m\033[34m",
         MarkupBrkPrompt := "\033[1m\033[31m",
         MarkupInput := "\033[31m",
         TextPrompt := CPROMPT,
         PrePrompt := function() end
       );
  if Length(arg) > 1 and IsRecord(arg[2]) then
    for a in RecNames(arg[2]) do
      r.(a) := arg[2].(a);
    od;
  fi;

  if b <> true then
    Unbind(PrintPromptHook);
    Unbind(EndLineHook);
    return;
  fi;

  # The colored interface
  # We stored STDOut above to avoid overwriting the last system error with
  # a function call.
  # To print the prompt
  PrintPromptHook := function()
    local cp;
    r.PrePrompt();
    cp := CPROMPT();
    # different color for brk...> prompts
    if Length(cp)>0 and cp[1] = 'b' then
      if IsString(r.MarkupBrkPrompt) then
        WriteAll(STDOut, r.MarkupBrkPrompt);
      else
        WriteAll(STDOut, r.MarkupBrkPrompt());
      fi;
    elif cp = "> " then
      if IsString(r.MarkupContPrompt) then
        WriteAll(STDOut, r.MarkupContPrompt);
      else
        WriteAll(STDOut, r.MarkupContPrompt());
      fi;
    else
      if IsString(r.MarkupStdPrompt) then
        WriteAll(STDOut, r.MarkupStdPrompt);
      else
        WriteAll(STDOut, r.MarkupStdPrompt());
      fi;
    fi;
    # use this instead of Print such that the column counter for the
    # command line editor is correct
    PRINT_CPROMPT(r.TextPrompt());
    # another color for input
    WriteAll(STDOut, "\033[0m");
    if IsString(r.MarkupInput) then
      WriteAll(STDOut, r.MarkupInput);
    else
      WriteAll(STDOut, r.MarkupInput());
    fi;
  end;
  # reset attributes before going to the next line
  EndLineHook := function()
    WriteAll(STDOut, "\033[0m");
  end;
end );

# Switch off colors for the moment.
# The default for the GAP session will be set in 'init.g',
# by evaluating the user preference 'UseColorPrompt'.
ColorPrompt(false);

# The coloring of the prompt after startup can be configured via a user
# preference.
DeclareUserPreference( rec(
  name:= "UseColorPrompt",
  description:= [
    "In a color capable terminal (almost any terminal application) you can \
run &GAP; such that the prompts, the input and output are distinguished \
by colors. Options are <K>true</K>, <K>false</K> or some record as explained \
in the help section for <Ref Func=\"ColorPrompt\"/>." ],
  default:= true,
  check:= val -> val in [ true, false ] or IsRecord( val ),
  ) );


