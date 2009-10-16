#############################################################################
##
#A  banner.g                GUAVA library                       Reinald Baart
#A                                                         Jasper Cramwinckel
#A                                                            Erik Roijackers
#A                                                                Eric Minkes
#A                                                                 Lea Ruscio
#A                                                               David Joyner
##
##  This file displays the banner
##
#H  @(#)$Id: banner.g,v 1.3 2004/12/20 21:26:05 gap Exp $
##
#Revision.("guava/lib/banner_g") :=
#    "@(#)$Id: banner.g,v 1.3 2004/12/20 21:26:05 gap Exp $";

if BANNER and not QUIET then
    Print("\n");
    Print("   ____                          |\n");
    Print("  /            \\           /   --+--  Version ",
          InstalledPackageVersion( "guava" ), "\n");
    Print(" /      |    | |\\\\        //|    |\n");
    Print("|    _  |    | | \\\\      // |     Jasper Cramwinckel\n");
    Print("|     \\ |    | |--\\\\    //--|     Erik Roijackers\n");
    Print(" \\     ||    | |   \\\\  //   |     Reinald Baart\n");
    Print("  \\___/  \\___/ |    \\\\//    |     Eric Minkes\n");
    Print("                                  Lea Ruscio\n");
    Print("                                  David Joyner\n");
fi;

