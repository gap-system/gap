#!/bin/sh
#############################################################################
##
#A  xgap                        XGAP source                      Frank Celler
##
##
#Y  Copyright (C) 1998,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##


#############################################################################
##
##  xgap.sh                     GAP                           Max Neunhoeffer
##
##  This is a shell script for the  UNIX  operating system  that starts XGAP.
##  This is the place  where  you  make  all  the  necessary  customizations.
##  Then copy this file to a  directory in your  search path,  e.g., '~/bin'.
##  If you later move GAP to another location you must only change this file.
##

#############################################################################
##
##  GAP_DIR . . . . . . . . . . . . . . . . . . . . directory where GAP lives
##
##  Set 'GAP_DIR' to the name of the directory where you have installed  GAP,
##  i.e., the directory with the subdirectories  'lib',  'grp',  'doc',  etc.
##  The default is '/Applications/gap/gapdev',  which is the root directory if you install
##  XGAP in the default `pkg' directory.
##  If you install XGAP in a private directory you have to change this.
##
if [ "x$GAP_DIR" = "x" ];  then
GAP_DIR="/Applications/gap/gapdev"
fi


#############################################################################
##
##  XGAP_DIR . . . . . . . . . . . . . . . . . . . directory where XGAP lives
##
##  Set 'XGAP_DIR' to the name of the directory where you have unpacked XGAP
##  The default is '$GAP_DIR', which is a standard location.
##  You have to change this unless you have installed XGAP in this  location.
##  Comment:
##  Note that this path should *not* contain the part 'pkg/xgap' because
##  this is added automatically when needed. We need this information without
##  the last part for the GAP library path when XGAP is not installed in
##  the standard location!
##
if [ "x$XGAP_DIR" = "x" ];  then
XGAP_DIR="$GAP_DIR"
fi


#############################################################################
##
##  GAP_MEM . . . . . . . . . . . . . . . . . . . amount of initial workspace
##
##  Set 'GAP_MEM' to the amount of memory GAP shall use as initial workspace.
##  The default is 70 MB,  which is  a reasonable amount of memory  to start.
##  You have to change it if you want  GAP to use a larger initial workspace.
##  If you are not going to run  GAP  in parallel with other programs you may
##  want to set this value close to the  amount of memory your  computer has.
##
if [ "x$GAP_MEM" = "x" ];  then
GAP_MEM=70m
fi


#############################################################################
##
##  GAP_PRG . . . . . . . . . . . . . . . . .  name of the executable program
##
##  Set 'GAP_PRG' to the  name of the executable  program of the  GAP kernel.
##  The  default is  '`hostname'/gap'.    You  can   either change this    to
##  '<target>/gap' where <target> is the  target you have selected during the
##  compilation or create  a symbolic link  from <target> to  '`hostname`' in
##  the 'bin' directory.
##
if [ "x$GAP_PRG" = "x" ];  then
GAP_PRG=x86_64-apple-darwin16.5.0-gcc-default64/gap
fi


#############################################################################
##
##  XGAP_PRG . . . . . . . . . . . . . . . . . name of the executable program
##
##  Set 'XGAP_PRG' to the  name of the executable program of the XGAP kernel.
##  The  default is  '`hostname'/gap'.    You  can   either change this    to
##  '<target>/gap' where <target> is the  target you have selected during the
##  compilation or create  a symbolic link  from <target> to  '`hostname`' in
##  the 'bin' directory.
##
if [ "x$XGAP_PRG" = "x" ];  then
XGAP_PRG=x86_64-apple-darwin16.5.0-gcc/xgap
fi


#############################################################################
##
##  DAEMON . . . . . . . . . . . . . .  flag, whether xgap goes to background
##
##  Set 'DAEMON' to "NO" if you don't want the usual behaviour, that xgap
##  goes to the background directly after starting up.
##
DAEMON="YES"

#############################################################################
##
##  VERBOSE . . . . . . . . . . . . . . flag, whether lots of messages appear
##
##  Set 'VERBOSE' to "YES", if you want exact information about the options
##  with which the xgap executable is executed. Mainly used for debugging
##  purposes.
##
VERBOSE="NO"


#############################################################################
##
##  STOP EDITING HERE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
##
##  Unless you know what you are doing! This should not be necessary if you
##  installed GAP and XGAP in the standard way as a share package within the
##  GAP directory.
##  If you really want to edit the variables below, insert additional 
##  definitions above, they will *not* be overwritten!
##
#############################################################################

#############################################################################
##
#F  options . . . . . . . . . . . . . . . . .  parse the command line options
##
##  GAP accepts the following options:
##
##  -b          toggle banner supression
##  -q          toggle quiet mode
##  -e          toggle quitting on <ctr>-D
##  -f          force line editing
##  -n          disable line editing
##  -x <num>    set line width
##  -y <num>    set number of lines
##
##  -g          toggle GASMAN messages
##  -m <mem>    set the initial workspace size
##  -o <mem>    set the maximal workspace size
##  -c <mem>    set the cache size value
##  -a <mem>    set amount to pre-malloc-ate
##              postfix 'k' = *1024, 'm' = *1024*1024
##  -l <paths>  set the GAP root paths
##  -r          toggle reading of the '.gaprc' file 
##  -D          toggle debuging the loading of library files
##  -B <name>   current architecture
##  -M          toggle loading of compiled modules
##  -N          toggle check for completion files
##  -X          toggle CRC for comp. files while reading
##  -Y          toggle CRC for comp. files while completing
##  -i <file>   change the name of the init file
##
##  -L <file>   restore a saved workspace
##
##
##  XGAP accepts the following options:
##
##  -display <dis>, --display <dis>
##                  set the display
##
##  -geometry <geo>, --geometry <geo>
##                  set the geometry
##
##  -normal <font>, --normal <font>
##                  set the normal font
##
##  -huge <font>, --huge <font>
##                  set the huge font
##
##  -large <font>, --large <font>
##                  set the large font
##
##  -small <font>, --small <font>
##                  set the small font
##
##  -tiny <font>, --tiny <font>
##                  set the tiny font
##
##
##  XGAP accepts the following debug options:
##
##  --debug <num>
##                  enter debug mode (XGAP must be compiled with DEBUG_ON)
##
##  -G <exec>, --gap-exec <exec>, --gap-prg <exec>
##                  use another GAP executable
##
##  -X <exec>, --xgap-exec <exec>, --xgap-prg <exec>
##                  use another XGAP executable
##
##
##  this scripts accepts the following debug options:
##
##  -V, --verbose
##                  be verbose
##
##  --stay
##                  don't put XGAP into the backgroup
##

## we parse all options:

XP=""
GP=""

while [ $# -gt 0 ];  do
  case $1 in

    # GAP options
    -b|-q|-e|-f|-n|-g|-r|-D|-M|-N|-X|-Y) GP="$GP $1"                 ;;
    -x|-y|-o|-c|-a|-B|-i|-L)             GP="$GP $1 $2"; shift       ;;
    -l|--gap-lib)              GAP_DIR="$2";             shift       ;;
    -m|--gap-mem)              GAP_MEM="$2";             shift       ;;

    # XGAP options
    -display|--display)        XP="$XP -display $2";     shift       ;;
    -geometry|--geometry)      XP="$XP -geometry $2";    shift       ;;
    -huge|--huge*)             XP="$XP -huge $2";        shift       ;;
    -large|--large*)           XP="$XP -large $2";       shift       ;;
    -normal|--normal*)         XP="$XP -normal $2";      shift       ;;
    -small|--small*)           XP="$XP -small $2";       shift       ;;
    -tiny|--tiny*)             XP="$XP -tiny $2";        shift       ;;

    # DEBUG options
    --debug)                   XP="$XP -D $2";           shift       ;;
    -G|--gap-exec|--gap-prg)   GAP_PRG="$2";             shift       ;;
    -X|--xgap-exec|--xgap-prg) XGAP_PRG="$2";            shift       ;;

    # script options
    -V|--verbose)              VERBOSE="YES"                         ;;
    --stay)                    DAEMON="NO"                           ;;

    # everything else is passed to GAP:
    *)                         GP="$GP $1"                           ;;

  esac
  shift
done


#############################################################################
##
#V  DISPLAY . . . . . . . . . . . . . . . . . .  display variable must be set
##
if [ "x$DISPLAY" = "x" ];  then
  echo 'sorry: xgap is a program running under the X Window System, so'
  echo 'you need a graphics display.'
  echo 'you must either set $DISPLAY or use "-display HOST:0.0"'
  echo 'where you replace HOST by the name of your machine.'
  exit 1;
fi;


#############################################################################
##  We calculate the library path argument for GAP:
##
if [ "$XGAP_DIR" = "$GAP_DIR" ]; then
  LIBARG="$GAP_DIR"
else
  LIBARG="$XGAP_DIR;$GAP_DIR"
fi


#############################################################################
##
#F  verbose . . . . . . . . . . . . . . . . . . . . .  print some information
##
if [ $VERBOSE = "YES" ];  then
  echo
  echo "XGAP path:         $XGAP_DIR"
  echo "XGAP executable:   $XGAP_DIR/pkg/xgap/bin/$XGAP_PRG"
  echo "GAP path:          $GAP_DIR"
  echo "GAP executable:    $GAP_DIR/bin/$GAP_PRG"
  echo "GAP library arg:   $LIBARG"
  echo "Display:           $DISPLAY"
  echo "XGAP parameters:   $XP"
  echo "GAP parameters:    $GP"
  echo
fi


#############################################################################
##
#F  XGAP  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  start XGAP
##
XGAP=$XGAP_DIR/pkg/xgap/bin/$XGAP_PRG
GAP=$GAP_DIR/bin/$GAP_PRG
                                                                                
export TERM=dumb

if [ $DAEMON = "YES" ];  then
  $XGAP -G $GAP $XP -- -l $LIBARG -m $GAP_MEM $GP &
else
  $XGAP -G $GAP $XP -- -l $LIBARG -m $GAP_MEM $GP
fi

exit 0
