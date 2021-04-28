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

    if IsString(fnam) then
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
                fnam := Concatenation(fnam,res[2][1],":",String(res[2][2]));
            fi;
        fi;
    fi;
    DefaultReportDiff(inp, expout, found, fnam, line, time);
end;

TestManualChapter := function(filename)
    local testResult;
    
    GapExitCode(1);
    testResult := Test(filename, rec( width := 72,
		        compareFunction := "uptowhitespace",
		        reportDiff := ExamplesReportDiff ) );
    if not(testResult) then
        QuitGap(1);
    fi;
    QuitGap(0);
end;
