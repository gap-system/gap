#GAPOPTS -E --readline --minworkspace 300m --maxworkspace 600m --limitworkspace 1g
# the kernel must honour the long forms of its options
# readline is used if and only if the kernel has it
GAPInfo.KernelInfo.HAVE_LIBREADLINE = IsBound( READLINEINITLINE );
l := GASMAN_LIMITS();;
expected := [ 300, 600, 1024 ] * 1024;;
ForAll( [ 1 .. 3 ], i -> not IsBound( l[i] ) or l[i] = expected[i] );
