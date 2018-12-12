#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

# This code extracts the examples from manuals chapter-wise and
# stores them in a file that can be passed to the Test function

ExamplesReportDiff := function(inp, expout, found, fnam, line, time)
    local tstf, i, loc, res;

    Print("########> Diff in ");
    if IsStream(fnam) then
        Print("test stream, line ",line,"\n");
    else
        tstf := SplitString(StringFile(fnam), "\n");
        i := line;
        # Look for location marker
        while (i > 0) and
              ((Length(tstf[i]) < 5) or (tstf[i]{[1..5]} <> "#LOC#")) do
            i := i - 1;
        od;
        # Found a location marker
        if i > 0 then
            loc := InputTextString(Concatenation(tstf[i]{[6..Length(tstf[i])]}, ";"));
            res := READ_COMMAND_REAL(loc, false);
            if res[1] = true then
                Print(res[2][1],":",res[2][2]);
            fi;
            Print(" (", fnam,":",line,")\n");
        else # did not find a location marker
            Print(fnam,":",line,"\n");
        fi;
    fi;
    Print("# Input is:\n", inp);
    Print("# Expected output:\n", expout);
    Print("# But found:\n", found);
    Print("########\n");
end;

TestManualChapter := function(filename)
    local testResult;
    
    GAP_EXIT_CODE(1);
    testResult := Test(filename, rec( width := 72,
		        compareFunction := "uptowhitespace",
		        reportDiff := ExamplesReportDiff ) );
    if not(testResult) then
        QUIT_GAP(1);
    fi;
    QUIT_GAP(0);
end;
