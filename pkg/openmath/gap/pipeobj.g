###########################################################################
##
#W  pipeobj.g           OpenMath Package                     Andrew Solomon
#W                                                         Marco Costantini
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  Pipe exactly one OpenMath object from <input stream> to 
##  <output string>. 
##


###########################################################################
##
#F  ReadCharSkipSpace( <input> )
##
##  Reads and returns next non-space byte from input stream
##  returning the associated character.
##
BindGlobal("ReadCharSkipSpace", function(input)
	local
		b,	# byte
		c;  # character

	b :=  ReadByte(input);
	while b <> fail and (CHAR_INT(b) in [' ','\n','\t','\r']) do
		 b := ReadByte(input);
	od;
	if b <> fail then	
		return CHAR_INT(b);
	fi;

	return fail;
end);
	
###########################################################################
##
#F  ReadChar( <input> )
##
##  Reads and returns next byte as a character.
##
BindGlobal("ReadChar", function(input)
	local
		b,	# byte
		c;  # character

	b :=  ReadByte(input);
	if b <> fail then	
		return CHAR_INT(b);
	fi;

	return fail;
end);

###########################################################################
##
#F  CharIsSpace( <c> )
##
##  True iff c is a space, newline or tabstop.
##
BindGlobal("CharIsSpace", c -> c in  [' ','\n','\t']);

###########################################################################
##
#F  ReadTag( <input>, <firstbyte> )
##
##  Read a tag of the form < tag >
##  return "<tag>" - no spaces
##
BindGlobal("ReadTag", function(input,firstbyte)
	local
		s,	# the string to return	
		c,  # the character read
		d;	# string to discard: contains encode or comment

	s := "";
	# find the first '<'
    if CHAR_INT(firstbyte) in [' ','\n','\t','\r'] then
		c := ReadCharSkipSpace(input);
	else
	    c := CHAR_INT(firstbyte);	
	fi;
		
    if c <> '<' then
	   return fail;
	fi;   

	s[1] := c;
	c := ReadCharSkipSpace(input);

	# code inserted later to ensure encoding node (i.e <? ... ?>) is ignored 
	# ignore also things like <!-- this is a comment -->
	if c = '?' or c = '!'  then

        d := "";
        repeat
            c := ReadChar( input );
            if c = fail  then
                return fail;
            fi;
            Add( d, c );
        until Length( d ) >= 2 and d{[ Length( d ) - 1 .. Length( d ) ]} = "?>"
          or Length( d ) >= 3 and d{[ Length( d ) - 2 .. Length( d ) ]} = "-->";


		# now find the real beginning of the tag
		s := "";
		c := ReadCharSkipSpace(input);
		if c <> '<' then
			return fail;
		fi;

		s[1] := c;
		c := ReadCharSkipSpace(input);
	fi;

    repeat
        if c = fail  then
            return fail;
        fi;
        Add( s, c );
        c := ReadChar( input );
    until c = '>';
    while CharIsSpace( s[Length(s)] ) do
        Unbind( s[Length(s)] );
    od;
    Add( s, c );
    return s;

end);
	

###########################################################################
##
#F  PipeOpenMathObject( <input>, <output>, <firstbyte> )
##
##  Return "true" if we succeed in piping an OMOBJ from
##  input to output, fail otherwise.
##
##  Based on a very complicated finite state automaton
##  which accepts "<OMOBJ>" then any amount of stuff
##  and terminates with "<\OMOBJ>" unless it is inside
##  a comment "<!-- -->".
##
BindGlobal("PipeOpenMathObject", function(input,output,firstbyte)

	local
		s,	# string
		EndOMOBJstates, # list of states all of which behave almost the same way
		state,	# current state
		nextchar, # the next character we expect
		c;	# the last character read

	# first read " <OMOBJ >"
	s  := ReadTag(input,firstbyte);

	if not (IsList( s ) and Length( s ) > 6 and s{[ 1 .. 6 ]} = "<OMOBJ")  then
		return fail;
	fi;
	Append( output, s );


	EndOMOBJstates:= ["InXMLRead</","InXMLRead</O","InXMLRead</OM",
		"InXMLRead</OMO","InXMLRead</OMOB","InXMLRead</OMOBJ"];

	# start state
	state := "InXML";

	c := ReadChar(input);
	while c <> fail do

		## Start state
		if state =  "InXML" then
			if c = '<' then
				state := "InXMLRead<";
			fi;

		## Read a `<`
		elif state = "InXMLRead<" then
			if c = '!' then
				state := "InXMLRead<!";
			elif c = '/' then
				state := "InXMLRead</";
			elif c <> '<' then # if c = '<' then we stay in this state
				state := "InXML";
			fi; 


		## Read some part of InXMLRead</OMOBJ
		## these states are all dealt with together
		elif state in  EndOMOBJstates then
			if state <> EndOMOBJstates[Length(EndOMOBJstates)] then # this isn't the last one
				nextchar := EndOMOBJstates[Length(EndOMOBJstates)][Length(state)+1];
			else
				nextchar := '>';
				# skip to next nonblank
				while c <> fail and CharIsSpace(c) do
					Append(output, [c]);
					c := ReadChar(input);
				od;
				if c = fail then 
					return fail;
				elif c = nextchar then
					Append(output, [c]);
					return true;
				fi;
			fi;

			if c = nextchar then
				state := Concatenation(state, [nextchar]);
			elif c = '<' then
				state := "InXMLRead<";
			else 
				state := "InXML";
			fi;


		## now on to the comments
		elif state = "InXMLRead<!" then
			if c = '-' then
				state := "InXMLRead<!-";
			elif c = '<' then
				state := "InXMLRead<";
			else
				state := "InXML";
			fi;

		elif state = "InXMLRead<!-" then
			if c = '-' then
				state := "InComment";
			elif c = '<' then
				state := "InXMLRead<";
			else
				state := "InXML";
			fi;


		elif state = "InComment" then
			if c = '-' then
				state := "InComment-";
			fi;

		elif state = "InComment-" then
			if c = '-' then
				state := "InComment--";
			else 
				state := "InComment";
			fi;

		elif state = "InComment--" then
			if c = '>' then
				state := "InXML";
			else 
				state := "InComment";
			fi;

		else
			Error("Invalid state:",state);
		fi;


		# finally send the character off to the output and get the next one
	
		Append(output, [c]);
		c := ReadChar(input);
	od;
	return fail;
end);

###########################################################################
#E
