/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares functions and variables related to command line
**  settable options.
*/

#ifndef GAP_SYSOPT_H
#define GAP_SYSOPT_H

#include "system.h"

/****************************************************************************
**
*F * * * * * * * * * * * command line settable options  * * * * * * * * * * *
*/

/****************************************************************************
**
*V  SyCTRD  . . . . . . . . . . . . . . . . . . .  true if '<ctr>-D' is <eof>
*/
extern UInt SyCTRD;


/****************************************************************************
**
*V  SyCompilePlease . . . . . . . . . . . . . . .  tell GAP to compile a file
*V  SyCompileOutput . . . . . . . . . . . . . . . . . . into this output file
*V  SyCompileInput  . . . . . . . . . . . . . . . . . .  from this input file
*V  SyCompileName . . . . . . . . . . . . . . . . . . . . . .  with this name
*V  SyCompileMagic1 . . . . . . . . . . . . . . . . . . and this magic string
*/
extern Int SyCompilePlease;
extern Char * SyCompileOutput;
extern Char * SyCompileInput;
extern Char * SyCompileName;
extern Char * SyCompileMagic1;


/****************************************************************************
**
*V  SyDebugLoading  . . . . . . . . .  output messages about loading of files
*/
extern Int SyDebugLoading;

/****************************************************************************
**
*F  SyDotGapPath()
*/
const Char * SyDotGapPath(void);

/****************************************************************************
**
*V  SyLineEdit  . . . . . . . . . . . . . . . . . . . .  support line editing
**
**  0: no line editing
**  1: line editing if terminal
**  2: always line editing (EMACS)
*/
extern UInt SyLineEdit;

/****************************************************************************
**
*V  SyUseReadline   . . . . . . . . . . . . . . . . . .  support line editing
**
**  Switch for not using readline although GAP is compiled with libreadline
*/
extern UInt SyUseReadline;

/****************************************************************************
**
*V  SyNrCols  . . . . . . . . . . . . . . . . . .  length of the output lines
**
**  'SyNrCols' is the length of the lines on the standard output  device.
**
**  Per default this is 80 characters which is the usual width of  terminals.
**  It can be changed by the '-x' options for larger terminals  or  printers.
**
**  'Pr' uses this to decide where to insert a <newline> on the output lines.
**  'SyRead' uses it to decide when to start scrolling the echoed input line.
**
**  Put in this package because the command line processing takes place here.
*/
extern UInt SyNrCols;
extern UInt SyNrColsLocked;

/****************************************************************************
**
*V  SyNrRows  . . . . . . . . . . . . . . . . . number of lines on the screen
**
**  'SyNrRows' is the number of lines on the standard output device.
**
**  Per default this is 24, which is the  usual  size  of  terminal  screens.
**  It can be changed with the '-y' option for larger terminals or  printers.
**
**  'SyHelp' uses this to decide where to stop with '-- <space> for more --'.
*/
extern UInt SyNrRows;
extern UInt SyNrRowsLocked;


/****************************************************************************
**
*V  SyQuiet . . . . . . . . . . . . . . . . . . . . . . . . . surpress prompt
**
**  'SyQuit' determines whether GAP should print the prompt and  the  banner.
**
**  Per default its false, i.e. GAP prints the prompt and  the  nice  banner.
**  It can be changed by the '-q' option to have GAP operate in silent  mode.
**
**  It is used by the functions in 'gap.c' to surpress printing the  prompts.
**
**  Put in this package because the command line processing takes place here.
*/
extern UInt SyQuiet;

/****************************************************************************
**
*V  SyQuitOnBreak . . . . . . . . . . exit GAP instead of entering break loop
**
**  'SyQuitOnBreak' determines whether GAP should quit (with non-zero return
**  value) instead of entering the break loop.
**
**  False by default, can be changed with the '--quitonbreak' option.
**
**  Put in this package because the command line processing takes place here.
*/
extern UInt SyQuitOnBreak;

/****************************************************************************
**
*V  SyRestoring . . . . . . . . . . . . . . . . . . . . restoring a workspace
**
**  'SyRestoring' determines whether GAP is restoring a workspace or not.  If
**  it is zero no restoring should take place otherwise it holds the filename
**  of a workspace to restore.
**
*/
#ifdef GAP_ENABLE_SAVELOAD
extern Char * SyRestoring;
#endif

/****************************************************************************
**
*V  SyInitializing                               set to 1 during library init
**
**  'SyInitializing' is set to 1 during the library intialization phase of
**  startup. It supresses some behaviours that may not be possible so early
**  such as homogeneity tests in the plist code.
*/

extern UInt SyInitializing;

extern Char ** SyOriginalArgv;
extern UInt    SyOriginalArgc;

/****************************************************************************
**
*V  SyLoadSystemInitFile  . . . . . . should GAP load 'lib/init.g' at startup
*/
extern Int SyLoadSystemInitFile;


/****************************************************************************
**
*V  SyUseModule . . . . . . . . . check for static modules in 'READ_GAP_ROOT'
*/
extern int SyUseModule;


/****************************************************************************
**
*V  SyWindow  . . . . . . . . . . . . . . . .  running under a window handler
**
**  'SyWindow' is 1 if GAP  is running under  a window handler front end such
**  as 'xgap', and 0 otherwise.
**
**  If running under  a window handler front  end, GAP adds various  commands
**  starting with '@' to the output to let 'xgap' know what is going on.
*/
extern UInt SyWindow;


#endif    // GAP_SYSOPT_H
