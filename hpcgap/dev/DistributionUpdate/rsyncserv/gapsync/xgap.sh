#!/bin/sh
if [ "x$XGAP_DIR" = "x" ];  then
XGAP_DIR=$GAP_DIR
fi
if [ "x$GAP_PRG" = "x" ];  then
GAP_PRG=i686*/gap
fi
if [ "x$XGAP_PRG" = "x" ];  then
XGAP_PRG=i686-pc-linux-gnu-gcc/xgap
fi
DAEMON="YES"
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
                                                                                
if [ $DAEMON = "YES" ];  then
  $XGAP -G $GAP $XP -- -l $LIBARG  $GP &
else
  $XGAP -G $GAP $XP -- -l $LIBARG  $GP
fi

exit 0
