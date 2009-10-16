
##  $Id: gap64.sh,v 1.2 2008/07/19 15:02:53 gap Exp $    Frank Lübeck

exec ${GAP_DIR}/bin/x86_64*/gap -m 40m  -l ${GAP_DIR}"/local;"${GAP_DIR} "$@"

