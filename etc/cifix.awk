
BEGIN { 
    leave_out = 0;
}

##
##  A line starting with <<<<<<< should be left out.
##
/^<<<<<<</ { 
    next;
}

##
##  Leave out all lines between ======= and >>>>>>>.
##
/^=======/ {

    leave_out = 1;
    next;
}


/^>>>>>>>/ {
    leave_out = 0;
    next;
}


##
##  Print everything except lines that should be left out
##
{   
    if( leave_out ) {
        ##  Check if this is a CVS version line, if ot exit with a
        ##  characteristic exit code.
        if( match( $0, "\\$Id:" ) == 0 )
            exit 7; 
    }
    else
        print;
}





