###########################################################################
##
#W  lex.g               OpenMath Package                     Andrew Solomon
#W                                                         Marco Costantini
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  This file contains the GAP level interface to the output of the 
##  lexical analyser gpipe.
##  Comprises the "instream" functions - deals with stream at byte level
##  and the "get" functions which get tokens and values from streams.
##


###########################################################################
##
##  Defining OpenMath tokens
##
BindGlobal("OMtokenDelimiter",255);
BindGlobal("OMtokenInteger",2);
BindGlobal("OMtokenFloat",3);
BindGlobal("OMtokenByteArray",4);
BindGlobal("OMtokenVar",5);
BindGlobal("OMtokenString",6);
BindGlobal("OMtokenWCString",7);
BindGlobal("OMtokenSymbol",8);
BindGlobal("OMtokenComment",15);
BindGlobal("OMtokenApp",16);
BindGlobal("OMtokenEndApp",17);
BindGlobal("OMtokenAttr",18);
BindGlobal("OMtokenEndAttr",19);
BindGlobal("OMtokenAtp",20);
BindGlobal("OMtokenEndAtp",21);
BindGlobal("OMtokenError",22);
BindGlobal("OMtokenEndError",23);
BindGlobal("OMtokenObject",24);
BindGlobal("OMtokenEndObject",25);
BindGlobal("OMtokenBind",26);
BindGlobal("OMtokenEndBind",27);
BindGlobal("OMtokenBVar",28);
BindGlobal("OMtokenEndBVar",29);


###########################################################################
##
#C  BTWOBJ
##
##  Indicates that the pointer into the byte stream has just read an
##  end object and not read the next token (in case it isn't there).
##

BindGlobal("BTWOBJ", "IN_BETWEEN_OBJECTS");


###########################################################################
##
##  OMinstream functions
##
##  functions for dealing with low level operations on an "instream"
##  which is a GAP level stream together with info about the next byte.
##

###########################################################################
##
#F  OMinstreamNextByte( <stream> ) 
##
##  The next byte on the stream which hasn't been "got".
##  
##  
BindGlobal("OMinstreamNextByte", function(stream)
	# if we're at BTWOBJ then we've been explicitly asked
	# for the next thing, so we try.
	if stream.next = BTWOBJ then
		stream.next :=  ReadByte(stream.stream);
	fi;
  return stream.next;
end);

###########################################################################
##
#F  OMinstreamPopByte( <stream> ) 
##
##  Pop a byte off the stream
##
BindGlobal("OMinstreamPopByte", function(stream)
	local next;

	next := OMinstreamNextByte(stream);
	# don't try to read another byte off the stream after endobj unless 
	# explicitly asked to (do this in next byte)
	if next = OMtokenEndObject then
		stream.next := BTWOBJ;
	else
		stream.next :=  ReadByte(stream.stream);
	fi;
	return next;
end);

###########################################################################
##
#F  OMinstreamPopString( <stream> ) 
##
##  Pop a string off the stream (all bytes until next OMtokenDelimiter).
##
BindGlobal("OMinstreamPopString", function(stream)
	local s,i;

	s := "";
	i := 1;
	while OMinstreamNextByte(stream) <> OMtokenDelimiter  and
		OMinstreamNextByte(stream) <> fail do
		s[i] := OMinstreamPopByte(stream);
		i := i +1;
	od;
	OMinstreamPopByte(stream); # get rid of the delimiter
	return List(s,CHAR_INT);
end);
		
	
###########################################################################
##
##  token level functions
##

###########################################################################
##
#F  OMnextToken( <stream> )
##
##  Just returns the next byte on the stream (without popping it).
##
BindGlobal("OMnextToken", function(stream)
	return OMinstreamNextByte(stream);
end);

###########################################################################
##
#F  OMgetToken( <stream> )
##
##  return value of the next token and gets next byte off the stream.
##
BindGlobal("OMgetToken", function(stream, token)
	local
		otok;

	otok := OMinstreamNextByte(stream);
  if otok <> token then
    Error("Invalid OpenMath object - expected ", token, " not ",otok);
  fi;

  # otherwise, just advance past the token
	OMinstreamPopByte(stream);
	return otok;
end);

###########################################################################
##
#F  OMgetInteger( <str> )
## 
##  Get the next OMtokenInteger off the stream (complains if it isn't
##  an OMtokenInteger) and then the value. Returns the value as a 
##  GAP integer.
##

# convert a string of the form "xaf93bc" or "-xaf93bc"  into an integer
BindGlobal("Xint" , function(str)
	local digmap, i, neg, start, tot;

	digmap := function(c)
		if (c >= '0') and (c <= '9') then
			return  INT_CHAR(c) -  INT_CHAR('0');
		fi;

		if  (c >= 'a') and  (c <= 'f') then
			return  INT_CHAR(c) -  INT_CHAR('a') + 10;
		fi;

		Error("invalid input to digmap");
	end;


	if (str[1] <> 'x') and (str[2] <> 'x') then
		Error("Invalid format for hexadecimal in Xint");
	fi;

	if (str[1] = 'x') then
		start := 2;
		neg := false;
	else
		start := 3;
		neg := true;
	fi;

	tot := 0;
	for i in [start .. Length(str)] do
		tot := 16*tot + digmap(str[i]);
	od;

	if neg then
		return -tot;
	else
		return tot;
	fi;


end);

BindGlobal("OMgetInteger", function(stream)
	local intstr;

  OMgetToken(stream,OMtokenInteger); # skip past token 
	# and get the value
	intstr := OMinstreamPopString(stream);
	if (intstr[1] = 'x') or 
           (Length(intstr) >= 2 and intstr[2]='x')
        then #need to convert hex
		return Xint(intstr);
	else
		return Int(intstr);
	fi;
end);

###########################################################################
##
#F  OMgetSymbol( <stream> )
## 
##  a symbol is returned as a pair [cd, name]
##
BindGlobal("OMgetSymbol", function(stream)
  OMgetToken(stream,OMtokenSymbol); # skip past token

	# now return the [cd, name] pair
  return [OMinstreamPopString(stream), OMinstreamPopString(stream)];
end);

######################################################################
##
#F  OMgetVar( <stream> )
##
##  a variable is returned as the string of its name.
##
BindGlobal("OMgetVar", function(stream)
  OMgetToken(stream,OMtokenVar); # skip past token
  return OMinstreamPopString(stream);
end);


###########################################################################
##
#F  OMgetString( <stream> )
##
##  a string  is popped from stream and it is returned as a GAP string.
##
BindGlobal("OMgetString", function(stream)
  local string;
  OMgetToken(stream,OMtokenString); # skip past token
  string := OMinstreamPopString(stream);

  # convert XML escaped chars
  string := ReplacedString( string, "&lt;", "<" );
  string := ReplacedString( string, "&gt;", ">" );
  string := ReplacedString( string, "&quot;", "\"" );
  string := ReplacedString( string, "&apos;", "\'" );
  string := ReplacedString( string, "&amp;", "&" );
  
  return string;
end);


###########################################################################
#E
