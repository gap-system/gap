

##############################################################################
##
#A  sq.g                        29 Mar 1994                   Alice C Niemeyer
#A                                   and functions of            Werner Nickel
##
##  This file contains the interface to the ANU SQ program. 
##    


#############################################################################
##
#V  SqPresentation  . . . . . . . . . . . . . . . . . . . .  globale variable
##
SqPresentation := [];


#############################################################################
##
#F  SqUsage() . . . . . . . . . . . . . . . show usage of 'NilpotentQuotient'
##
SqUsage := function()
    return Error("usage: Sq( <file>|<fpgroup> [<Lseries>] )");
end;
	

#############################################################################
##
#F  SqPresPrintToFile( <file>, <fp> ) . . . . . .  print presentation to file
##
##  Print a finite presentation in Sq format. 
##  (modified from Werner Nickel's function NqPresPrintToFile)
##
SqPresPrintToFile := function( file, fp )
    local   i,  gens,  append,  size,fprels;

    # append a relator (this is a hack)
    append := function( rel )
	local   pos,  len,  max;

	max := 10;
	pos := 1;
	rel := MappedWord( rel, FreeGeneratorsOfFpGroup(fp), gens );
	len := Length(rel);
	while 0 < len  do
	   if len <= max  then
	        AppendTo( file, Subword(rel,pos,pos+len-1) );
		pos := pos+len;
		len := 0;
	    else
	    	AppendTo( file, Subword(rel,pos,pos+max-1), "*\n      " );
		pos := pos+max;
		len := len-max;
	    fi;
	od;
    end;

    # raise screen size
    size := SizeScreen();
    SizeScreen( [ 100, 24 ] );

    # print presentation to file using generators "x1" ... "xn"
    PrintTo( file, "< " );
    if 0 < Length(GeneratorsOfGroup(fp))  then
	gens:=GeneratorsOfGroup(FreeGroup(Length(GeneratorsOfGroup(fp)), "x" ));
	AppendTo( file, gens[1] );
    fi;
    for i  in [2..Length(GeneratorsOfGroup(fp))]  do
	AppendTo( file, ", ", gens[i] );
    od;
    AppendTo( file, " |\n    " );
    fprels:=RelatorsOfFpGroup(fp);
    if IsBound(fprels)  then
        if 0 < Length(fprels)  then
	    append( fprels[1] );
	fi;
	for i  in [2..Length(fprels)]  do
	    AppendTo( file, ",\n    " );
	    append( fprels[i] );
	od;
    fi;
    AppendTo( file, "\n>\n" );

    # restore screen size
    SizeScreen( size );

end;

IsLseries := function( ls )
	local i, l;

	l := Length(ls);
        for i in [ 1 .. l ] do
	    if not IsPrime(ls[i][1]) then return false; fi;
        od;
	return true;
end;

#############################################################################
##
#F  Sq( <F>, <Lseries> )  . . . . . . . . . . . . . . soluble quotient of <F>
##
##  The interface to the Solublequotient standalone.
##
Sq := function( arg )
    local   ll,  lseries,  dir,  name,  res,  cmd;

    if not Length(arg) in [1,2]  then SqUsage();  fi;

    # Check if a list is an L-series

    lseries := [];
    if Length(arg) = 2 then
	lseries := arg[2];
	if not IsLseries(lseries)  then SqUsage();  fi;
    fi;

    # create a tmp directory
##    Changed.   WN
##    dir := TmpName();
    dir := TmpDirectory();
##
##    No longer necessary.   WN
##    Exec(Concatenation( "mkdir ", dir ));
    name := Concatenation( dir, "/SQ_INPUT" );
    res  := Concatenation( dir, "/SQ_OUTPUT" );

    # set up SQ input file SQ_INPUT in <dir>
    if IsFpGroup( arg[1] ) then
	SqPresPrintToFile( name, arg[1] );
    elif IsString( arg[1] ) then
        Exec(Concatenation( "cp ", arg[1], " ", name ));
    else
        Exec(Concatenation( "rm -rf ", dir ));
	return SqUsage();
    fi;

    cmd := "";

    # add lower central series if known
    if lseries <> [] then
	for ll in lseries do 
	    AppendTo( name, ll[1], " ", ll[2], "\n" );
	od;
    fi;

    # call the sq
    cmd := Concatenation( cmd, " < ", name, " " );
    cmd := Concatenation( cmd, " > ", res );
    Exec(Concatenation(Filename(DirectoriesPackagePrograms("anusq"),"Sq"),cmd));

    # read in the result
    AppendTo( res, ";\n" );
    Read(res);

    # remove the tmp dir
    Exec(Concatenation( "rm -rf ", dir ));

    # and return
    return SqPresentation;

end;
