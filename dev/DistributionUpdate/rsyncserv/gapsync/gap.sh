
##  $Id: gap.sh,v 1.3 2008/07/19 15:02:53 gap Exp $    Frank Lübeck

exec ${GAP_DIR}/bin/i686-pc-linux-gnu-gcc/gap -m 30m  -l ${GAP_DIR}"/local;"${GAP_DIR} "$@"

