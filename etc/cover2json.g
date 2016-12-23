if LoadPackage("profiling") <> true then
    Print("ERROR: could not load profiling package");
    FORCE_QUIT_GAP(1);
fi;

OutputJsonCoverage("coverage", "coverage.json");
QUIT_GAP(0);
