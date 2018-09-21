# Check InstallAtExit is run in reverse order
InstallAtExit(function() Print("First Call\n"); end);

# Check InstallAtExit recovers from Errors
InstallAtExit(function() Print("Step 1\n"); Error("ERROR!"); Print("Step 2\n"); end);
InstallAtExit(function() Print("Last Call\n"); end);
