/****************************************************************************
**
*A  system.h                    GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  The file 'system.c' declares  all  operating system dependent  functions.
*/
#ifdef  INCLUDE_DECLARATION_PART
char *          Revision_system_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**
*T  Char, Int1, Int2, Int4, Int, UChar, UInt1, UInt2, UInt4, UInt .  integers
**
** Note that to get this to work, all files must be compiled with or without
** -DSYS_IS_64_BIT, not just system.c
**
** (U)Int<n> should be exactly <n> bytes long
** (U)Int should be the same length as a bag identifier
*/

#ifdef SYS_IS_64_BIT		          /* 64 bit machines -- well alphas anyway */
typedef char                    Char;
typedef char                    Int1;
typedef short int               Int2;
typedef int                     Int4;
typedef long int                Int;
typedef unsigned char           UChar;
typedef unsigned char           UInt1;
typedef unsigned short int      UInt2;
typedef unsigned int            UInt4;
typedef unsigned long int       UInt;
#else                                     /* 32bit machines */
typedef char                    Char;
typedef char                    Int1;
typedef short int               Int2;
typedef long int                Int4;
typedef long int                Int;
typedef unsigned char           UChar;
typedef unsigned char           UInt1;
typedef unsigned short int      UInt2;
typedef unsigned long int       UInt4;
typedef unsigned long int       UInt;
#endif

/****************************************************************************
**
*V  SyFlags . . . . . . . . . . . . . . . . . . . . flags used when compiling
**
**  'SyFlags' is the name of the target for which GAP was compiled.
**
**  It is
**
**      [bsd|mach|usg|os2|msdos|tos|vms|mac] [gcc|emx|djgpp|mpw|syc] [ansi]
**
**  It is used in 'InitGap' for the 'VERSYS' variable.
*/
extern  Char            SyFlags [];


/****************************************************************************
**
*V  SyLibname . . . . . . . . . . . . . . . . . name of the library directory
**
**  'SyLibname' is the name of the directory where the GAP library files  are
**  located.
**
**  This is per default the subdirectory 'lib/'  of  the  current  directory.
**  It is usually changed with the '-l' option in the script that starts GAP.
**
**  Is copied into the GAP variable called 'LIBNAME'  and used by  'Readlib'.
**  This is also used in 'LIBNAME/init.g' to find the group library directory
**  by replacing 'lib' with 'grp', etc.
**
**  It must end with the pathname seperator, eg. if 'init.g' is the name of a
**  library file 'strcat( SyLibname, "init.g" );' must be a  valid  filename.
**  Further neccessary transformation of the filename are done  in  'SyOpen'.
**
**  Put in this package because the command line processing takes place here.
*/
extern  Char            SyLibname [256];


/****************************************************************************
**
*V  SyHelpname  . . . . . . . . . . . . . . name of the online help directory
**
**  'SyHelpname' is the name of the directory where the GAP online help files
**  are located.
**
**  By default it is computed from 'SyLibname' by replacing 'lib' with 'doc'.
**  It can be changed with the '-h' option.
**
**  It is used by 'SyHelp' to find the online documentation.
*/
extern  Char            SyHelpname [256];


/****************************************************************************
**
*V  SyBanner  . . . . . . . . . . . . . . . . . . . . . . . . surpress banner
**
**  'SyBanner' determines whether GAP should print the banner.
**
**  Per default it  is true,  i.e.,  GAP prints the  nice  banner.  It can be
**  changed by the '-b' option to have GAP surpress the banner.
**
**  It is copied into the GAP variable 'BANNER', which  is used  in 'init.g'.
**
**  Put in this package because the command line processing takes place here.
*/
extern  UInt            SyBanner;


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
**  Is also copied into the GAP variable 'QUIET' which is used  in  'init.g'.
**
**  Put in this package because the command line processing takes place here.
*/
extern  UInt            SyQuiet;


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
extern  UInt            SyNrCols;


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
extern  UInt            SyNrRows;


/****************************************************************************
**
*V  SyMsgsFlagBags  . . . . . . . . . . . . . . . . .  enable gasman messages
**
**  'SyMsgsFlagBags' determines whether garabage collections are reported  or
**  not.
**
**  Per default it is false, i.e. Gasman is silent about garbage collections.
**  It can be changed by using the  '-g'  option  on the  GAP  command  line.
**
**  This is used in the function 'SyMsgsBags' below.
**
**  Put in this package because the command line processing takes place here.
*/
extern  UInt            SyMsgsFlagBags;


/****************************************************************************
**
*V  SyStorMin . . . . . . . . . . . . . .  default size for initial workspace
**
**  'SyStorMin' is the size of the initial workspace allocated by Gasman.
**
**  This is per default  4 Megabyte,  which  is  often  a  reasonable  value.
**  It is usually changed with the '-m' option in the script that starts GAP.
**
**  This value is used in the function 'SyAllocBags' below.
**
**  Put in this package because the command line processing takes place here.
*/
extern  Int             SyStorMin;


/****************************************************************************
**
*V  SyStorMax . . . . . . . . . . . . . . . . . . . maximal size of workspace
**
**  'SyStorMax' is the maximal size of the workspace allocated by Gasman.
**
**  This is per default 16 MByte,  which is often a  reasonable value.  It is
**  usually changed with the '-t' option in the script that starts GAP.
**
**  This is used in the function 'SyAllocBags'below.
**
**  Put in this package because the command line processing takes place here.
*/
extern  Int             SyStorMax;


/****************************************************************************
**
*F  SyStackAlign  . . . . . . . . . . . . . . . . . .  alignment of the stack
**
**  'SyStackAlign' is  the  alignment  of items on the stack.   It  must be a
**  divisor of  'sizof(Bag)'.  The  addresses of all identifiers on the stack
**  must be  divisable by 'SyStackAlign'.  So if it  is 1, identifiers may be
**  anywhere on the stack, and if it is  'sizeof(Bag)',  identifiers may only
**  be  at addresses  divisible by  'sizeof(Bag)'.  This value is initialized
**  from a macro passed from the makefile, because it is machine dependent.
**
**  This value is passed to 'InitBags'.
*/
extern  UInt            SyStackAlign;


/****************************************************************************
**
*V  SyCacheSize . . . . . . . . . . . . . . . . . . . . . . size of the cache
**
**  'SyCacheSize' is the size of the data cache.
**
**  This is per  default 0, which means that  there is no usuable data cache.
**  It is usually changed with the '-c' option in the script that starts GAP.
**
**  This value is passed to 'InitBags'.
**
**  Put in this package because the command line processing takes place here.
*/
extern  UInt            SyCacheSize;


/****************************************************************************
**
*V  SyInitfiles[] . . . . . . . . . . .  list of filenames to be read in init
**
**  'SyInitfiles' is a list of file to read upon startup of GAP.
**
**  It contains the 'init.g' file and a user specific init file if it exists.
**  It also contains all names all the files specified on the  command  line.
**
**  This is used in 'InitGap' which tries to read those files  upon  startup.
**
**  Put in this package because the command line processing takes place here.
**
**  For UNIX this list contains 'LIBNAME/init.g' and '$HOME/.gaprc'.
*/
extern  Char            SyInitfiles [16] [256];


/****************************************************************************
**
*F  IsAlpha( <ch> ) . . . . . . . . . . . . .  is a character a normal letter
*F  IsDigit( <ch> ) . . . . . . . . . . . . . . . . .  is a character a digit
**
**  'IsAlpha' returns 1 if its character argument is a normal character  from
**  the range 'a..zA..Z' and 0 otherwise.
**
**  'IsDigit' returns 1 if its character argument is a digit from  the  range
**  '0..9' and 0 otherwise.
*/
#include        <ctype.h>
#define IsAlpha(ch)     (isalpha(ch))
#define IsDigit(ch)     (isdigit(ch))


/****************************************************************************
**
*F  SyStrlen( <str> ) . . . . . . . . . . . . . . . . . .  length of a string
**
**  'SyStrlen' returns the length of the string <str>, i.e.,  the  number  of
**  characters in <str> that precede the terminating null character.
*/
extern  UInt            SyStrlen (
            Char *              str );


/****************************************************************************
**
*F  SyStrcmp( <str1>, <str2> )  . . . . . . . . . . . . . compare two strings
**
**  'SyStrcmp' returns an integer greater than, equal to, or less  than  zero
**  according to whether <str1> is greater  than,  equal  to,  or  less  than
**  <str2> lexicographically.
*/
extern  Int             SyStrcmp (
            Char *              str1,
            Char *              str2 );


/****************************************************************************
**
*F  SyStrncmp( <str1>, <str2>, <len> )  . . . . . . . . . compare two strings
**
**  'SyStrncmp' returns an integer greater than, equal to,  or less than zero
**  according  to whether  <str1>  is greater than,  equal  to,  or less than
**  <str2> lexicographically.  'SyStrncmp' compares at most <len> characters.
*/
extern  Int             SyStrncmp (
            Char *              str1,
            Char *              str2,
            UInt                len );


/****************************************************************************
**
*F  SyStrncat( <dst>, <src>, <len> )  . . . . .  append one string to another
**
**  'SyStrncat'  appends characters from the  <src>  to <dst>  until either a
**  null character  is  encoutered  or  <len>  characters have   been copied.
**  <dst> becomes the concatenation of <dst> and <src>.  The resulting string
**  is always null terminated.  'SyStrncat' returns a pointer to <dst>.
*/
extern  Char *          SyStrncat (
            Char *              dst,
            Char *              src,
            UInt                len );


/****************************************************************************
**
*F  SyFopen( <name>, <mode> ) . . . . . . . .  open the file with name <name>
**
**  The function 'SyFopen'  is called to open the file with the name  <name>.
**  If <mode> is "r" it is opened for reading, in this case  it  must  exist.
**  If <mode> is "w" it is opened for writing, it is created  if  neccessary.
**  If <mode> is "a" it is opened for appending, i.e., it is  not  truncated.
**
**  'SyFopen' returns an integer used by the scanner to  identify  the  file.
**  'SyFopen' returns -1 if it cannot open the file.
**
**  The following standard files names and file identifiers  are  guaranteed:
**  'SyFopen( "*stdin*", "r")' returns 0 identifying the standard input file.
**  'SyFopen( "*stdout*","w")' returns 1 identifying the standard outpt file.
**  'SyFopen( "*errin*", "r")' returns 2 identifying the brk loop input file.
**  'SyFopen( "*errout*","w")' returns 3 identifying the error messages file.
**
**  If it is necessary to adjust the  filename  this  should  be  done  here.
**  Right now GAP does not read nonascii files, but if this changes sometimes
**  'SyFopen' must adjust the mode argument to open the file in binary  mode.
*/
extern  Int             SyFopen (
            Char *              name,
            Char *              mode );


/****************************************************************************
**
*F  SyFclose( <fid> ) . . . . . . . . . . . . . . . . .  close the file <fid>
**
**  'SyFclose' closes the file with the identifier <fid>  which  is  obtained
**  from 'SyFopen'.
*/
extern  void            SyFclose (
            Int                 fid );


/****************************************************************************
**
*F  SyFgets( <line>, <lenght>, <fid> )  . . . . .  get a line from file <fid>
**
**  'SyFgets' is called to read a line from the file  with  identifier <fid>.
**  'SyFgets' (like 'fgets') reads characters until either  <length>-1  chars
**  have been read or until a <newline> or an  <eof> character is encoutered.
**  It retains the '\n' (unlike 'gets'), if any, and appends '\0' to  <line>.
**  'SyFgets' returns <line> if any char has been read, otherwise '(char*)0'.
**
**  'SyFgets'  allows to edit  the input line if the  file  <fid> refers to a
**  terminal with the following commands:
**
**      <ctr>-A move the cursor to the beginning of the line.
**      <esc>-B move the cursor to the beginning of the previous word.
**      <ctr>-B move the cursor backward one character.
**      <ctr>-F move the cursor forward  one character.
**      <esc>-F move the cursor to the end of the next word.
**      <ctr>-E move the cursor to the end of the line.
**
**      <ctr>-H, <del> delete the character left of the cursor.
**      <ctr>-D delete the character under the cursor.
**      <ctr>-K delete up to the end of the line.
**      <esc>-D delete forward to the end of the next word.
**      <esc>-<del> delete backward to the beginning of the last word.
**      <ctr>-X delete entire input line, and discard all pending input.
**      <ctr>-Y insert (yank) a just killed text.
**
**      <ctr>-T exchange (twiddle) current and previous character.
**      <esc>-U uppercase next word.
**      <esc>-L lowercase next word.
**      <esc>-C capitalize next word.
**
**      <tab>   complete the identifier before the cursor.
**      <ctr>-L insert last input line before current character.
**      <ctr>-P redisplay the last input line, another <ctr>-P will redisplay
**              the line before that, etc.  If the cursor is not in the first
**              column only the lines starting with the string to the left of
**              the cursor are taken. The history is limitied to ~8000 chars.
**      <ctr>-N Like <ctr>-P but goes the other way round through the history
**      <esc>-< goes to the beginning of the history.
**      <esc>-> goes to the end of the history.
**      <ctr>-O accept this line and perform a <ctr>-N.
**
**      <ctr>-V enter next character literally.
**      <ctr>-U execute the next command 4 times.
**      <esc>-<num> execute the next command <num> times.
**      <esc>-<ctr>-L repaint input line.
**
**  Not yet implemented commands:
**
**      <ctr>-S search interactive for a string forward.
**      <ctr>-R search interactive for a string backward.
**      <esc>-Y replace yanked string with previously killed text.
**      <ctr>-_ undo a command.
**      <esc>-T exchange two words.
*/
extern  Char *          SyFgets (
            Char *              line,
            UInt                length,
            Int                 fid );


/****************************************************************************
**
*F  SyFputs( <line>, <fid> )  . . . . . . . .  write a line to the file <fid>
**
**  'SyFputs' is called to put the  <line>  to the file identified  by <fid>.
*/
extern  void            SyFputs (
            Char *              line,
            Int                 fid );


/****************************************************************************
**
*F  syWinPut(<fid>,<cmd>,<str>) . . . . . . send a line to the window handler
**
**  'syWinPut'  send the command   <cmd> and the  string  <str> to the window
**  handler associated with the  file identifier <fid>.   In the string <str>
**  '@'  characters are duplicated, and   control characters are converted to
**  '@<chr>', e.g., <newline> is converted to '@J'.
*/
extern  void            syWinPut (
            Int                 fid,
            Char *              cmd,
            Char *              str );


/****************************************************************************
**
*F  SyWinCmd( <str>, <len> )  . . . . . . . . . . . .  . execute a window cmd
**
**  'SyWinCmd' send   the  command <str> to  the   window  handler (<len>  is
**  ignored).  In the string <str> '@' characters are duplicated, and control
**  characters  are converted to  '@<chr>', e.g.,  <newline> is converted  to
**  '@J'.  Then  'SyWinCmd' waits for  the window handlers answer and returns
**  that string.
*/
extern  Char *          SyWinCmd (
            Char *              str,
            UInt                len );


/****************************************************************************
**
*F  SyIsIntr()  . . . . . . . . . . . . . . . . check wether user hit <ctr>-C
**
**  'SyIsIntr' is called from the evaluator at  regular  intervals  to  check
**  wether the user hit '<ctr>-C' to interrupt a computation.
**
**  'SyIsIntr' returns 1 if the user typed '<ctr>-C' and 0 otherwise.
*/
extern  UInt            SyIsIntr ( void );


/****************************************************************************
**
*F  SyExit( <ret> ) . . . . . . . . . . . . . exit GAP with return code <ret>
**
**  'SyExit' is the offical  way  to  exit GAP, bus errors are the inoffical.
**  The function 'SyExit' must perform all the neccessary cleanup operations.
**  If ret is 0 'SyExit' should signal to a calling proccess that all is  ok.
**  If ret is 1 'SyExit' should signal a  failure  to  the  calling proccess.
*/
extern  void            SyExit (
            UInt                ret );


/****************************************************************************
**
*F  SyExec( <cmd> ) . . . . . . . . . . . execute command in operating system
**
**  'SyExec' executes the command <cmd> (a string) in the operating system.
**
**  'SyExec'  should call a command  interpreter  to execute the command,  so
**  that file name expansion and other common  actions take place.  If the OS
**  does not support this 'SyExec' should print a message and return.
**
**  For UNIX we can use 'system', which does exactly what we want.
*/
extern  void            SyExec (
            Char *              cmd );


/****************************************************************************
**
*F  SyTime()  . . . . . . . . . . . . . . . return time spent in milliseconds
**
**  'SyTime' returns the number of milliseconds spent by GAP so far.
**
**  Should be as accurate as possible,  because it  is  used  for  profiling.
*/
extern  UInt            SyTime ( void );


/****************************************************************************
**
*F  SyTmpname() . . . . . . . . . . . . . . . . . return a temporary filename
**
**  'SyTmpname' creates and returns a new temporary name.
*/
extern  Char *          SyTmpname ( void );


/****************************************************************************
**
*F  SyHelp( <topic>, <fid> )  . . . . . . . . . . . . . . display online help
**
**  This function is of course way to large.  But what the  heck,  it  works.
*/
extern  void            SyHelp (
            Char *              topic,
            Int                 fin );


/****************************************************************************
**
*F  SyMsgsBags(<full>,<phase>,<nr>) . . . . . . . . . display Gasman messages
**
**  'SyMsgsBags' is the function that is used by Gasman to  display  messages
**  during garbage collections.
*/
extern  void            SyMsgsBags (
            UInt                full,
            UInt                phase,
            Int                 nr );


/****************************************************************************
**
*F  SyAllocBags(<size>,<need>)  . . . . allocate memory block of <size> bytes
**
**  'SyAllocBags' is called from Gasman to get new storage from the operating
**  system.  <size> is the needed amount in bytes (it is always a multiple of
**  512 KByte),  and <need> tells 'SyAllocBags' whether  Gasman  really needs
**  the storage or only wants it to have a reasonable amount of free storage.
**
**  Currently  Gasman  expects this function to return  immediately  adjacent
**  areas on subsequent calls.  So 'sbrk' will  work  on  most  systems,  but
**  'malloc' will not.
**
**  If <need> is 0, 'SyAllocBags' must return 0 if it cannot or does not want
**  to extend the workspace,  and a pointer to the allocated area to indicate
**  success.   If <need> is 1  and 'SyAllocBags' cannot extend the workspace,
**  'SyAllocBags' must abort,  because GAP assumes that  'NewBag'  will never
**  fail.
**
**  <size> may also be negative in which case 'SyAllocBags' should return the
**  storage to the operating system.  In this case  <need>  will always be 0.
**  'SyAllocBags' can either accept this reduction and  return 1  and  return
**  the storage to the operating system or refuse the reduction and return 0.
**
**  If the operating system does not support dynamic memory managment, simply
**  give 'SyAllocBags' a static buffer, from where it returns the blocks.
*/
extern  UInt * * *      SyAllocBags (
            Int                 size,
            UInt                need );


/****************************************************************************
**
*F  SyAbortBags(<msg>)  . . . . . . . . . . abort GAP in case of an emergency
**
**  'SyAbortBags' is the function called by Gasman in case of an emergency.
*/
extern  void            SyAbortBags (
            Char *              msg );


/****************************************************************************
**
*F  InitSystem( <argc>, <argv> )  . . . . . . . . . initialize system package
**
**  'InitSystem' is called very early during the initialization from  'main'.
**  It is passed the command line array  <argc>, <argv>  to look for options.
**
**  For UNIX it initializes the default files 'stdin', 'stdout' and 'stderr',
**  installs the handler 'syAnsIntr' to answer the user interrupts '<ctr>-C',
**  scans the command line for options, tries to  find  'LIBNAME/init.g'  and
**  '$HOME/.gaprc' and copies the remaining arguments into 'SyInitfiles'.
*/
extern  void            InitSystem (
            Int                 argc,
            Char *              argv [] );



