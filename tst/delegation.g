#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#F  CheckOutputDelegations
##
##  A method to output an object may only delegate to another operation
##  which appears further right in the following list: Display, ViewObj,
##  PrintObj, DisplayString, ViewString, PrintString, String.
##
##  This function parses the code of all installed methods for these
##  operations and checks whether this rule is followed, and shortlists
##  methods that require further inspection. Since it may still report
##  some cases where it is safe to call a predecessor of an operations
##  for a subobject of the original object, the check cannot be fully
##  automated.
##
BindGlobal( "CheckOutputDelegations",
function()
local rules, name, f, str, ots, met, pos, nargs, r, i, tmp,
      report, line, m, n, illegal_delegations, checklist;

rules := [ "Display", "ViewObj", "PrintObj", "DisplayString",
           "ViewString", "PrintString", "String" ];

for pos in [1..Length(rules)] do
  name := rules[pos];
  report:=[];

  for nargs in [1..2] do
    f:=MethodsOperation( ValueGlobal(name), nargs );
    for m in f do
      met := m.func;
      str := "";
      ots := OutputTextString(str,true);;
      PrintTo( ots, met );
      CloseStream(ots);
      illegal_delegations:=[];
      checklist:=rules{[1..pos-1]};
      for r in checklist do
        # check for all occurrences of the string, but
        # ignore those which are preceded or followed by a letter
        n := 0;
        while true do
          n := POSITION_SUBSTRING(str, r, n);
          if n = fail then break; fi;
          if n > 1 and str[n-1] in CHARS_ALPHA then continue; fi;
          if Length(str) >= n + Length(r) then
            if not str[n + Length(r)] in CHARS_ALPHA then
              Add( illegal_delegations, r );
              break;
            fi;
          fi;
        od;
      od;
      if Length(illegal_delegations) > 0 then
        tmp := [];
        if IsBound(m.location) then
          Add(tmp, m.location);
        else
          Add(tmp, [ FILENAME_FUNC( met ), STARTLINE_FUNC( met ) ]);
        fi;
        Append(tmp, [ m.info, illegal_delegations, met ]);
        Add(report, tmp);
      fi;
    od;
  od;

  if Length(report) > 0 then
    Print("\nDetected incorrect delegations for ", name, "\n");
    for line in report do
      Print("---------------------------------------------------------------\n");
      Print( line[2], "\n", " delegates to ", line[3], "\n",
             "Filename: ", line[1][1], ":", line[1][2], "\n", line[4], "\n");
    od;
    Print("---------------------------------------------------------------\n");
  else
    Print("All delegations correct for ", name, "\n");
  fi;

od;
end);
