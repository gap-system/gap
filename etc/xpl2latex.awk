#############################################################################
##
#W  xpl2latex.awk              GAP utilities                    Thomas Breuer
##
BEGIN {
    verb = 0;
    doub = 0
}

# Simply copy everything if a line does not match.
! /\`/ {
    print( $0 )
}

# Text not contained in examples and enclosed in singlequotes is set
# in verbatim.
/\`/ {
    pos = index( $0, "`" );
    if ( pos > 1 && substr( $0, pos-1, 1 ) == "\\" ) {
        printf( "%s`", substr( $0, 1, pos-2 ) );
        lline = substr( $0, pos+1 );
        pos = index( lline, "`" )
    }
    else {
        lline = $0
    }
    if ( pos == 0 ) {
        print( lline )
    }
    else {
        if ( ( pos < length( $0 ) ) && ( substr( $0, pos+1, 1 ) == "`" ) ) {
            printf( "%s", substr( $0, 1, pos+1 ) );
            lline = substr( $0, pos+2 );
            verb = 0;
            doub = 1
        }
        else {
            printf( "%s\\verb|", substr( $0, 1, pos-1 ) );
            lline = substr( $0, pos+1 );
            verb = 1;
            doub = 0
        }
        while ( verb == 1 || doub == 1 ) {
            if ( verb == 1 ) {
                pos = index( lline, "'" );
                while ( pos == 0 ) {
                    print( lline );
                    if ( getline != 1 ){
                        break
                    }
                    lline = $0;
                    pos = index( lline, "'" )
                }
                if ( pos == 0 ) {
                    break
                }
                printf( "%s|", substr( lline, 1, pos-1 ) );
                lline = substr( lline, pos+1 );
                verb = 0
            }
            if ( doub == 1 ) {
                pos1 = index( lline, "`" );
                pos2 = index( lline, "''" );
                while ( ( pos1 == 0 ) && ( pos2 == 0 ) ) {
                    print( lline );
                    if ( getline != 1 ){
                        break
                    }
                    lline = $0;
                    pos1 = index( lline, "`" )
                    pos2 = index( lline, "''" )
                }
                if ( pos1 == 0 && pos2 == 0 ) {
                    break
                }
                if ( pos1 != 0 ) {
                    if ( pos2 == 0 ) {
                      printf( "%s\\verb|", substr( lline, 1, pos1-1 ) );
                      verb = 1;
                      lline = substr( lline, pos1+1 )
                    }
                    else {
                      if ( pos2 < pos 1 ) {
                        printf( "%s", substr( lline, 1, pos2+1 ) );
                        doub = 0;
                        lline = substr( lline, pos2+2 );
                      }
                      else {
                        printf( "%s\\verb|", substr( lline, 1, pos1-1 ) );
                        verb = 1;
                        lline = substr( lline, pos1+1 )
                      }
                    }
                }
                else {
                  if ( pos2 != 0 ) {
                    printf( "%s", substr( lline, 1, pos2+1 ) );
                    doub = 0;
                    lline = substr( lline, pos2+2 );
                  }
                }
            }
            if ( verb == 0 && doub == 0 ) {
                pos1 = index( lline, "`" );
                pos2 = index( lline, "``" );
                if ( pos2 != 0 ) {
                  if ( pos1 < pos2 ) {
                    printf( "%s\\verb|", substr( lline, 1, pos1-1 ) );
                    lline = substr( lline, pos1+1 );
                    verb = 1
                  }
                  else {
                    printf( "%s", substr( lline, 1, pos2+1 ) );
                    lline = substr( lline, pos2+2 );
                    doub = 1
                  }
                }
                else {
                    if ( pos1 != 0 ) {
                        printf( "%s\\verb|", substr( lline, 1, pos1-1 ) );
                        lline = substr( lline, pos1+1 );
                        verb = 1
                    }
                    else {
                        print( lline )
                    }
                }
            }
        }
    }
}

END {
    # Check that no brackets are open.
    if ( verb == 1 ) {
        print( "still in verbatim at end of file" ) > "/dev/stderr"
    }
    if ( doub == 1 ) {
        print( "still in double quotes at end of file" ) > "/dev/stderr"
    }
}


#############################################################################
##
#E

