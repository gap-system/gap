#############################################################################
##
#W  pipeobj.g           OpenMath Package         Andrew Solomon
#W                                                     Marco Costantini
##
#H  @(#)$Id: pipeobj.g,v 1.12 2006/08/04 08:06:26 gap Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  Pipe exactly one OpenMath object from <input stream> to 
##  <output string>. 
##

Revision.("openmath/gap/pipeobj.g") :=
    "@(#)$Id: pipeobj.g,v 1.12 2006/08/04 08:06:26 gap Exp $";


#############################################################################
##
#F  ReadCharSkipSpace( <input> )
##
##  Reads and returns next non-space byte from input stream
##  returning the associated character.
##
BindGlobal("ReadCharSkipSpace", 
function(input)
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
	
#############################################################################
##
#F  ReadChar( <input> )
##
##  Reads and returns next byte as a character.
##
BindGlobal("ReadChar", 
function(input)
	local
		b,	# byte
		c;  # character

	b :=  ReadByte(input);
	if b <> fail then	
		return CHAR_INT(b);
	fi;

	return fail;
end);

#############################################################################
##
#F  CharIsSpace( <c> )
##
##  True iff c is a space, newline or tabstop.
##
BindGlobal("CharIsSpace", c -> c in  [' ','\n','\t']);

#############################################################################
##
#F  ReadTag( <input> )
##
##  Read a tag of the form < tag >
##  return "<tag>" - no spaces
##
BindGlobal("ReadTag", 
function(input)
	local
		s,	# the string to return	
		c,  # the character read
		d;	# string to discard: contains encode or comment
	# find the first '<'
	s := "";
	c := ReadCharSkipSpace(input);


# The following lines handle binary encoding (an OpenMath with binary
# encoding starts with CHAR_INT(24) and ends with CHAR_INT(25) ):

if c <> fail and INT_CHAR( c ) = 24  then
    s := [ c ];
    repeat
        c := ReadChar( input );
        if c = fail  then
            return fail;
        fi;
        Add( s, c );
    until INT_CHAR( c ) = 25;
    return s;
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
	

#############################################################################
##
#F  PipeOpenMathObject( <input>, <output> )
##
##  Return "true" if we succeed in piping an OMOBJ from
##  input to output, fail otherwise.
##
##  Based on a very complicated finite state automaton
##  which accepts "<OMOBJ>" then any amount of stuff
##  and terminates with "<\OMOBJ>" unless it is inside
##  a comment "<!-- -->".
##
BindGlobal("PipeOpenMathObject",
function(input,output)

	local
		s,	# string
		EndOMOBJstates, # list of states all of which behave almost the same way
		state,	# current state
		nextchar, # the next character we expect
		c;	# the last character read

	# first read " <OMOBJ >"
	s  := ReadTag(input);

# The following lines handle binary encoding
if IsList( s ) and Length( s ) >= 2 and INT_CHAR( s[1] ) = 24  then
    Append( output, s );
    return true;
fi;

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

#############################################################################
#E
