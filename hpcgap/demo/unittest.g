CurrentTestPrefix := "";
NumTestErrors := 0;

TestPrefix := function(title)
  CurrentTestPrefix := title;
end;

TestReportAndExit := function()
  if NumTestErrors = 1 then
    Print("*** 1 error occurred.\n");
    GAP_EXIT_CODE(1);
  elif NumTestErrors > 1 then
    Print("*** ", NumTestErrors, " errors occurred.\n");
    GAP_EXIT_CODE(1);
  else
    Print("*** No errors occurred.\n");
  fi;
end;

TestGeneral := function(success, message)
  local out;
  if success then
    out := "[+] ";
  else
    out := "[-] ";
    NumTestErrors := NumTestErrors + 1;
  fi;
  Append(out, INPUT_FILENAME());
  Append(out, ":");
  Append(out, String(INPUT_LINENUMBER()));
  if CurrentTestPrefix <> "" or message <> "" then
    Append(out, " (");
    if CurrentTestPrefix <> "" then
      Append(out, CurrentTestPrefix);
      if message <> "" then
        Append(out, ", ");
        Append(out, message);
      fi;
    else
      Append(out, message);
    fi;
    Append(out, ")");
  fi;
  while Length(out) < 50 do
    Add(out, ' ');
  od;
  Print(out, "\n");
end;

TestTrue := function(arg)
  if IsBound(arg[2]) then
    TestGeneral(arg[1], arg[2]);
  else
    TestGeneral(arg[1], "");
  fi;
end;

TestFalse := function(arg)
  if IsBound(arg[2]) then
    TestGeneral(not arg[1], arg[2]);
  else
    TestGeneral(not arg[1], "");
  fi;
end;

TestEqual := function(arg)
  if IsBound(arg[3]) then
    TestGeneral(arg[1] = arg[2], arg[3]);
  else
    TestGeneral(arg[1] = arg[2], "");
  fi;
end;
