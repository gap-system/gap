#############################################################################
####
##
#W  banner.g                ParGAP Package                     Gene Cooperman
#W                                                                Greg Gamble
##
##  Print a nice banner.
##
#H  @(#)$Id: banner.g,v 1.4 2001/11/17 12:17:04 gap Exp $
##
#Y  Copyright (C) 1999-2001  Gene Cooperman
#Y    See included file, COPYING, for conditions for copying
##
Revision.pargap_banner_g :=
    "@(#)$Id: banner.g,v 1.4 2001/11/17 12:17:04 gap Exp $";

Print("\n",
      "    Adding parallel features, loading package ...\n",
      "\n",
      "    #######                 #######       ##       #######  \n",
      "    ########               #########     ####      ######## \n", 
      "    ###   ###             ####     #     ####      ###   ###\n",
      "    ###   ###             ###           ######     ###   ###\n",
      "    ########              ###   ####   ###  ###    ######## \n",
      "    #######   ##### # ### ###   ####   ########    #######  \n",
      "    ###      ##  ## ##    ####   ###  ##########   ###      \n",
      "    ###      ##  ## ##     #########  ###    ###   ###      \n",
      "    ###       ### # ##      ######   ###      ###  ###      \n",
      "\n",
      "    Parallel GAP, Version: ",   PACKAGES_VERSIONS.pargap,  "\n",
      "    by Gene Cooperman <gene@ccs.neu.edu>\n",
      "    Type `?ParGAP' for information about using ParGAP.\n",
      "\n");

#E  banner.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
