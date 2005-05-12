##  
##  colorprompt.g                                             Frank Lübeck
##  
##  A demo for customizing the GAP prompt.
##  
##  To switch off the coloring of prompt and input call
##     ColorPrompt(false);
##  To switch off use of colors completely say
##     ANSI_COLORS := false;
##  
Revision.colorprompt_g := 
    "$Id$";

# see comment below
BindGlobal("STDOut", OutputTextUser());

# same behaviour as with unbound functions
PrintPromptHook := CPROMPT;
EndLineHook := function() end;

############################################################################
##  
#F  ColorPrompt( <bool> ) . . . . . . (un)set using a colored prompt and input
##  
##  With  `ColorPrompt(true);' {\GAP}  changes its  user interface:  The
##  prompts and  the user  input are displayed  in different  colors. It
##  also sets the  variable `ANSI_COLORS' to `true' (which  has the side
##  effect that  some help pages  are also displayed with  color markup.
##  Switch the colored prompts off with `ColorPrompt(false);'.
##  
##  Note that  this will only work  if your terminal emulation  in which
##  you run {\GAP} understands the so called ANSI color escape sequences
##  -  almost all  terminal emulations  on current  UNIX/Linux (`xterm',
##  `rxvt', `konsole', ...) systems do so.
##  
##  The colors shown depend on  the terminal configuration and cannot be
##  forced  from  an application.  If  your  terminal follows  the  ANSI
##  conventions you see  the standard prompt in bold blue  and the break
##  loop prompt in bold red, as well as your input in red.
##  
##  If   it  works   for   you   and  you   like   it,   put  the   line
##  `ColorPrompt(true);' in your `.gaprc' file (see~"The .gaprc file").
##  
ColorPrompt := function(b)
  if b <> true then
    Unbind(PrintPromptHook);
    Unbind(EndLineHook);
    ANSI_COLORS := false;
    return;
  fi;
  ANSI_COLORS := true;

  # The colored interface
  # We stored STDOut above to avoid overwriting the last system error with 
  # a function call.
  # To print the prompt
  PrintPromptHook := function()
    local cp;
    cp := CPROMPT();
    if cp = "gap> " then
      cp := "gap> ";
    fi;
    # different color for brk...> prompts
    if Length(cp)>0 and cp[1] = 'b' then
      WriteAll(STDOut, "\033[1m\033[31m");
    else
      WriteAll(STDOut, "\033[1m\033[34m");
    fi;
    # use this instead of Print such that the column counter for the 
    # command line editor is correct
    PRINT_CPROMPT(cp);
    # another color for input
    WriteAll(STDOut, "\033[0m\033[31m");
  end;
  # reset attributes before going to the next line
  EndLineHook := function()
    WriteAll(STDOut, "\033[0m");
  end;
end;

# now, that the file is in the GAP library, the default is no colored prompt
ColorPrompt(false);


