
##  $Id: pargap.sh,v 1.2 2008/07/19 15:02:53 gap Exp $    Frank Lübeck

# multiple root path don't seem to work
exec ${GAP_DIR}/bin/i686-pc-linux-gnu-gcc/pargapmpi -m 30m  -l ${GAP_DIR} "$@"

