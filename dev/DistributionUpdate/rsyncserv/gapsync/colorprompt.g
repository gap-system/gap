##  
##  colorprompt.g                                             Frank Lübeck
##  
##  A demo for customizing the GAP prompt.
##  
Revision.colorprompt_g := 
    "$Id$";

ANSI_COLORS:=true;

# my colored interface
# store this to avoid overwriting last system error with function call
STDOUT := OutputTextUser();
# print the prompt
PrintPromptHook := function()
  local cp;
  cp := CPROMPT();
  if cp = "gap> " then
    cp := "gap> ";
  fi;
  # different color for brk...> prompts
  if Length(cp)>0 and cp[1] = 'b' then
    WriteAll(STDOUT, "\033[1m\033[31m");
  else
    WriteAll(STDOUT, "\033[1m\033[34m");
  fi;
  # use this instead of `Print' such that the column counter for the 
  # command line editor is correct
  PRINT_CPROMPT(cp);
  # another color for input
  WriteAll(STDOUT, "\033[0m\033[31m");
end;
# reset attributes before going to the next line
EndLineHook := function()
  WriteAll(STDOUT, "\033[0m");
end;

