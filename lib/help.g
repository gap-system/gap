#############################################################################
##
#W  help.g                     GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the help system.
##
Revision.help_g :=
    "@(#)$Id$";


#############################################################################
##

#F  # # # # # # # # utility functions dealing with strings  # # # # # # # # #
##


#############################################################################
##
#F  MATCH_BEGIN( <a>, <b> )
##
MATCH_BEGIN := function( a, b )
local p,q;

    if Length(a)=0 and Length(b)=0 then
      return true;
    fi;

    if 0 = Length(b) or Length(a) < Length(b)  then
        return false;
    fi;

    p:=Position(b,' ');
    if p=fail then
      return a{[1..Length(b)]} = b;
    else
      q:=Position(a,' ');
      if q=fail then
        q:=Length(a)+1;
      fi;
      # cope with blanks
      return MATCH_BEGIN(a{[1..q-1]},b{[1..p-1]}) and
             MATCH_BEGIN(a{[q+1..Length(a)]},b{[p+1..Length(b)]});
    fi;

end;


#############################################################################
##
#F  FILLED_LINE( <left>, <right>, <fill> )
##
FILLED_LINE := function( l, r, f )
    local   w,  n;

    w := SizeScreen()[1] - 8;
    if w < 8  then
        return "";
    fi;
    if w-7 < Length(l)  then
        l := Concatenation( l{[1..w-7]}, "..." );
    fi;
    if w-7 < Length(r)  then
        r := Concatenation( r{[1..w-7]}, "..." );
    fi;
    if w-7 < Length(l) + Length(r)  then
        r := Concatenation( r{[1..w-7-Length(l)]}, "..." );
    fi;
 
    w := w - Length(l) - Length(r);
    n := ShallowCopy(l);
    Add( n, ' ' );
    while 0 < w  do
        Add( n, f );
        w := w - 1;
    od;
    Add( n, ' ' );
    Append( n, r );

    return n;

end;


#############################################################################
##

#F  # # # # # # # # # # # information about the books # # # # # # # # # # # #
##


#############################################################################
##

#V  HELP_BOOKS_INFO . . . . . . . . . . . . .  collected info about the books
##
##  The record <HELP_BOOKS_INFO> contains  for each book (already looked  at)
##  an entry describing the information found in the "manual.six" file.  This
##  information is stored in a record with the following components:
##
##  bookname:	    The full name of the book, for example   "GAP 4 Reference
##                  manual" or "Share Package 'matrix'".
##
##  book:           The abbreviation of the book, e.g. "ref" or "matrix".
##
##  directories:    The directories object where the file "manual.six" can be
##                  found.
##
##  filenames:      A list of filenames  for the chapters.  At  position  <i>
##                  one finds the filename for the file containing the <i>.th
##                  chapter.
##
##  chapters:       The names of the chapters as list.
##
##  sections:       The names of the sections.  This is a list of lists,  the
##                  <i>.th list contains the sections for the <i>.th chapter.
##
##  secchaps:       A  list  of  triples  $[ <name>, <chap>, <sec> ]$,  where
##                  <name>  is  the  name  of  the  <sec>.th  section  in the 
##                  <chap>.th chapter.  If <sec> is zero then <name> is  name
##                  of the chapter.
##
##  seccposs:       List of positions of the beginnings of the sections. This
##                  is  a  list  of  lists,   the <i>.th  list  contains  the 
##                  positions of the sections of the <i>.th chapter.
##
##  chappos:        List of positions of the beginnings of the chapters.
##
##  index:          List of index entries, same format as 'secchaps'.
##
##  functions:      List of functions names, same format as 'secchaps'
##
##  Note that not  all   entries will  be  present  in the  beginning.    Use
##  'HELP_BOOK_INFO( <book> )' to get the information record for a book.  Use
##  'HELP_CHAPTER_INFO( <book>, <chapter-number>    )'  to get  the   entries
##  'chappos[<chapter-number>]' and 'secposs[<chapter-number>]'.
##
HELP_BOOKS_INFO := rec();


#############################################################################
##
#V  HELP_MAIN_BOOKS . . . . . . . . .  list of main books with share packages
##
##  A list of main books that are available.  This does not include the share
##  libraries.
##
HELP_MAIN_BOOKS := Immutable( [
    "tutorial",     "doc/tut",  "GAP 4 Tutorial",
    "reference",    "doc/ref",  "GAP 4 Reference Manual",
    "extending",    "doc/ext",  "Extending GAP 4 Reference Manual",
    "prg tutorial", "doc/prg",  "Programmers Tutorial",
    "new features", "doc/new",  "New Features for Developers",
] );


#############################################################################
##
#V  HELP_BOOKS	. . . . . . . . . . . . . . . . . . . . . . . . list of books
##
##  A list of books including the *loaded* share libraries.
##
HELP_BOOKS := ShallowCopy(HELP_MAIN_BOOKS);

HELP_NUMBERSTRING:=Immutable("0123456789");

#############################################################################
##
#F  HELP_BOOK_INFO( <book> )  . . . . . . . . . . . . . get info about a book
##
HELP_BOOK_INFO := function( book )
    local   readNumber,  path,  i,  bnam,  six,  stream,  c,  
            s,  f,  line, subline, c1,  c2,  pos,  name,  num,  x,  s1,  sec,
            s2,  dirs,  j,  x1,  f1;

    # if this is already a record return it
    if IsRecord(book)  then
        return book;

    # no information about the empty book
    elif 0 = Length(book)  then
        return fail;
    fi;

    # numbers
    readNumber := function( str )
        local   n;

        while str[pos] = ' '  do
            pos := pos+1;
        od;
        n := 0;
        while str[pos] <> '.'  do
            n := n * 10 + (Position(HELP_NUMBERSTRING,str[pos])-1);
            pos := pos+1;
        od;
        pos := pos+1;
        return n;
    end;

    # check if this is a book from the main library
    path := false;
    book := STRING_LOWER(book);
    for i  in [ 1, 4 .. Length(HELP_BOOKS)-2 ]  do
        if MATCH_BEGIN( HELP_BOOKS[i], book )  then
            path := HELP_BOOKS[i+1];
            book := HELP_BOOKS[i];
            bnam := book;
            break;
        fi;
    od;

    # otherwise it is a share package
    if path = false  then
        return fail;
    fi;

    # get the filename of the "manual.six" file
    dirs := DirectoriesLibrary( path );
    six  := Filename( dirs, "manual.six" );
    if six = fail  then
        return fail;
    fi;

    # read the file if we haven't see it yet
    if not IsBound(HELP_BOOKS_INFO.(bnam))  then

        # read the "manual.six" line by line
        stream := InputTextFile(six);
        c := [];  s := [];  x := [];  f := [];
        repeat
            line := ReadLine(stream);
            if line <> fail  then
		subline:=line{[3..Length(line)-1]} ;
                if line[1] = 'C'  then
                    if line{[1..10]} <> "C appendix"  then
                        Add( c, subline);
                    fi;
                elif line[1] = 'S'  then
                    Add( s, subline);
                elif line[1] = 'I'  then
                    Add( x, subline);
                elif line[1] = 'F'  then
		    # there are sometimes multiple definitions we have to
		    # cope with. For the time being we just check the last
		    # 10 entries to be quick.
		    if not (ForAny([Maximum(Length(f)-9,1)..Length(f)],
		                  i->f[i]=subline)
		        or ( not IsEmpty( s ) and
                           s[Length(s)]{[3..Length(s[Length(s)])]}
			    =subline{[3..Length(subline)]} )
		       )
		       
		      then
			Add( f, subline);
		    fi;
                else
                    Print( "#W  corrupted 'manual.six': ", line );
                fi;
            fi;
        until IsEndOfStream(stream);
        CloseStream(stream);

        # parse the chapters information
        c1 := [];
        c2 := [];
        for i  in c  do

            # first the filename
            pos  := Position( i, ' ' );
            name := i{[1..pos-1]};

            # then the chapter number
            num := readNumber(i);

            # then the chapter name
            while pos <= Length(i) and i[pos] = ' '  do pos := pos+1;  od;

            # store that information in <c1> and <c2>
            c1[num] := name;
            c2[num] := i{[pos..Length(i)]};
        od;

        # parse the sections information
        s1 := List( c1, x -> [] );
        for i  in s  do

            # chapter and section number
            pos := 1;
            num := readNumber(i);
            sec := readNumber(i);

            # then the section name
            while pos < Length(i) and i[pos] = ' '  do pos := pos+1;  od;

            # store the information in <s1>
            s1[num][sec] := i{[pos..Length(i)]};
            if pos = Length(i) then
                Print("#W Empty section name ", num, ".", sec,"\n");
            fi;
        od;

        # convert sections and chapters to lower case
        s2 := [];
        for i  in [ 1 .. Length(s1) ]  do
            for j  in [ 1 .. Length(s1[i]) ]  do
                Add( s2, [ STRING_LOWER(s1[i][j]), i, j ] );
            od;
        od;
        for i  in [ 1 .. Length(c2) ]  do
            Add( s2, [ STRING_LOWER(c2[i]), i, 0 ] );
        od;
        Sort( s2, function(a,b) return a[1]<b[1]; end );

        # parse the index information
        x1 := [];
        for i  in x  do

            # chapter and section number
            pos := 1;
            num := readNumber(i);
            sec := readNumber(i);

            # then the index entry
            while pos <= Length(i) and i[pos] = ' '  do pos := pos+1;  od;
 
            # store the information in <x1>
            Add( x1, [ STRING_LOWER(i{[pos..Length(i)]}), num, sec ] );
        od;
        Sort( x1, function(a,b) return a[1]<b[1];  end );

        # parse the function information
        f1 := [];
        for i  in f  do

            # chapter and section number
            pos := 1;
            num := readNumber(i);
            sec := readNumber(i);

            # then the index entry
            while pos <= Length(i) and i[pos] = ' '  do pos := pos+1;  od;
 
            # store the information in <x1>
            Add( f1, [ STRING_LOWER(i{[pos..Length(i)]}), num, sec ] );
        od;
        Sort( f1, function(a,b) return a[1]<b[1];  end );

        HELP_BOOKS_INFO.(bnam) := rec(
          bookname    := Immutable(bnam),
          book        := Immutable(book),
          directories := dirs,
          filenames   := Immutable(c1),
# the following three are not made immutable to allow change of names (if it
# is found out that several sections have the same name).
          chapters    := c2,
          sections    := s1,
          secchaps    := s2,
          secposs     := [],
          chappos     := [],
          index       := x1,
          functions   := f1
        );
    fi;

    return HELP_BOOKS_INFO.(bnam);

end;


#############################################################################
##
#F  HELP_CHAPTER_INFO( <book>, <chapter> )  . . . .  get info about a chapter
##
HELP_CHAPTER_BEGIN := Immutable("\\Chapter");
HELP_SECTION_BEGIN := Immutable("\\Section");
HELP_FAKECHAP_BEGIN := Immutable("%\\FakeChapter");
HELP_PRELCHAPTER_BEGIN := Immutable("\\PreliminaryChapter");

HELP_CHAPTER_INFO := function( book, chapter )
    local   info,  filename,  stream,  poss,  secnum,  pos,  line;

    # get the book info
    info := HELP_BOOK_INFO(book);

    # read in a chapter
    if not IsBound(info.secposs[chapter])  then

        filename := Filename( info.directories, info.filenames[chapter] );
        if filename = fail  then
            return fail;
        fi;
        stream := InputTextFile(filename);
        poss   := [];
        secnum := 0;
        repeat
            pos  := PositionStream(stream);
            line := ReadLine(stream);
            if line <> fail  then
                if MATCH_BEGIN( line, HELP_SECTION_BEGIN )  then
                    secnum := secnum + 1;
                    poss[secnum] := pos;
                elif MATCH_BEGIN( line, HELP_CHAPTER_BEGIN ) or
		     MATCH_BEGIN( line, HELP_PRELCHAPTER_BEGIN )  then
                    info.chappos[chapter] := pos;
                elif MATCH_BEGIN( line, HELP_FAKECHAP_BEGIN )  then
                    info.chappos[chapter] := pos;
                fi;
            fi;
        until IsEndOfStream(stream);
        CloseStream(stream);
        info.secposs[chapter] := Immutable(poss);
    fi;

    # return the info
    return [ info.chappos[chapter], info.secposs[chapter] ];

end;


#############################################################################
##
#F  # # # # # # # # # # # # # utility functions # # # # # # # # # # # # # # #
##


#############################################################################
##
#F  HELP_PRINT_LINES( <lines> )	. . . . . . . . . . . . . . . .  format lines
##
HELP_PRINT_LINES_BUILTIN := function( lines )
local   size,  stream,  count,  halt,  linepos,  i,  char,backstep;

    # cope with overfull lines
    count:=1;
    while count<=Length(lines) do
      if Length(lines[count])>78 then
	# find the last blank before position 78
        i:=78;
	while i>0 and lines[count][i]<>' ' do
	  i:=i-1;
	od;
	if i>0 then
	  if not IsBound(lines[count+1]) then
	    lines[count+1]:="";
	  fi;
	  lines[count+1]:=Concatenation(
	         lines[count]{[i+1..Length(lines[count])]}," ",
		 lines[count+1]);
	  lines[count]:=lines[count]{[1..i-1]};
	fi;
      fi;
      count:=count+1;
    od;


    size   := SizeScreen();
    stream := InputTextFile("*errin*");
    count  := 0;
    halt   := "    -- <space> for more, <q> to quit --";
    linepos:=1;
    backstep:=size[2]-1;
    while linepos<=Length(lines) do
        if count = size[2]-1  then
            Print( halt, "\c" );
            char := ReadByte(stream);
            for i  in halt  do Print( "\b" );  od;
            Print( "\c" );
            for i  in halt  do Print( " " );  od;
            for i  in halt  do Print( "\b" );  od;
            Print( "\c" );
            if char = 113 or char = 81  then
                Print( "\n" );
		backstep:=size[2]-1;
                return;
	    elif char=98 or char=66 then
	        Print("\n   < back >\n");
		count:=-1;
		backstep:=backstep+size[2]-1;
		linepos:=Maximum(1,linepos-backstep);
            elif char = 13  then
                count := size[2]-2;
		backstep:=size[2]-1;
            else
                count := 1;
		backstep:=size[2]-1;
            fi;
        fi;
        Print(lines[linepos], "\n" );
        linepos := linepos+1;
        count := count+1;
    od;
    CloseStream(stream);

end;

HELP_PRINT_LINES_LESS := function( lines )
local path,less,stream,str,i; 
  path:=DirectoriesSystemPrograms();
  less:=Filename(path,"less");
  str:="";
  for i in lines do
    Append(str,i);
    Add(str,'\n');
  od;
  stream:=InputTextString(str);
  Process(path[1],less,stream,OutputTextUser(),["-e"]);
end;

HELP_PRINT_LINES := HELP_PRINT_LINES_BUILTIN;

HELP_FLUSHRIGHT:=true;


#############################################################################
##
#F  HELP_PRINT_SECTION( <book>, <chapter>, <section> [,<key>] ) . print entry
##
##  key is a function name
HELP_PRINT_SECTION_SCREEN := function(arg)
local   book, chapter, section,key,p,lico,
	info,  chap,  filename,  stream,  done,  line,  lines,
	verbatim,macro,tail,lastblank,singleline,rund,width,
	buff,EmptyLine,ll,run;

  buff:="";
  lastblank:=false;
  singleline:=0;

  # add empty line, flush buffer before
  EmptyLine := function()
    if Length(buff)>0 then
      Add(lines,buff);
      buff:="";
    fi;
    if not lastblank then
      Add(lines,"");
      lastblank:=true;
    fi;
  end;

  width:=SizeScreen()[1]-6;
  book:=arg[1];
  chapter:=arg[2];
  section:=arg[3];

  # did we get the section only via a keyword?
  if Length(arg)>3 then
    key:=arg[4];
    # ignore appended numbers of a keyword (they are only used to cope
    # with multiply defined identifiers)
    p:=Position(key,'_');
    if p<>fail and p<Length(key) and key[p+1]='(' then
      key:=key{[1..p-1]};
    fi;
  else
    key:=fail;
  fi;

  # get the chapter info
  info := HELP_BOOK_INFO(book);
  chap := HELP_CHAPTER_INFO( book, chapter );
  if chap = fail  then
      return;
  fi;

  run:=0;
  repeat # run twice to find even more hidden index entries

    # store lines
    lines := [];

    # open the stream and read in the help
    filename := Filename( info.directories, info.filenames[chapter] );
    stream := InputTextFile(filename);
    done := false;
    if section = 0  then
        SeekPositionStream( stream, chap[1] );
        Add( lines, FILLED_LINE( info.chapters[chapter],
                                 info.bookname, '_' ) );
    else
        SeekPositionStream( stream, chap[2][section] );
        Add( lines, FILLED_LINE( info.sections[chapter][section],
                                 info.chapters[chapter], '_' ) );
      if ARCH_IS_UNIX() then
	# stream positioning works, we discard the line starting with
	# \Section...
	ReadLine(stream);
      else
        # on other architectures stream positioning might get confused due
	# to the CRLF problem. Continue reading until we know we have
	# actually reached the line.
	repeat
	  line:=ReadLine(stream);
	  if MATCH_BEGIN( line, HELP_SECTION_BEGIN ) then
	    # a section starts. Make sure it is the right section:
	    line:=line{[10..Length(line)]};
	    if MATCH_BEGIN( line, info.sections[chapter][section] ) then
	      # got the section header: break
	      line:=true;
	    fi;
	  fi;
        until line=true;
      fi;
    fi;

    if key<>fail then
      # we got the section only via a keyword.
      Add( lines, "");
      Add( lines, "[...]");
      EmptyLine();
    else
      lastblank:=false;
    fi;

    verbatim := false;
    repeat
        line := ReadLine(stream);
        if line <> fail  then

            if MATCH_BEGIN( line, HELP_SECTION_BEGIN )  then
                done := true;


            else
                line := line{[1..Length(line)-1]};

		if key<>fail then
		  # we got the section only via a keyword. Ignore the first
		  # part of the section and start only at the interesting
		  # bits.

		  # the first time we look for a function name
		  if run=0 then
		    p:=Position(line,'\\');
		    if p<>fail and p<Length(line) 
		      and line[p+1]='>' then

		      # try to match the key in the line
		      lico:=STRING_LOWER(line{[p+2..Length(line)]});
		      while Length(lico)>0 and lico[1]=' ' do
			lico:=lico{[2..Length(lico)]};
		      od;
		      if MATCH_BEGIN(lico,key) then
			# key has been found, disable the skip mode
			key:=fail;
		      fi;
		    fi;
		  else
		    # try to match the key in the line
		    lico:=STRING_LOWER(line);
		    p:=Position(lico,key[1]);
		    while p<>fail and key<>fail do
		      lico:=lico{[p..Length(lico)]};
		      if MATCH_BEGIN(lico,key) then
			# key has been found, disable the skip mode
			key:=fail;
		      else
			p:=Position(lico,key[1],2);
		      fi;
		    od;
		  fi;
		fi;

		if key<>fail then
                  # keyword not yet found, ignore.
		  line:=line;

                # blanks lines are ok
                elif 0 = Length(line)  then
                    if not verbatim then
		      EmptyLine();
                    fi;

                # ignore answers to exercises
                elif MATCH_BEGIN(line,"\\answer")  then
                    repeat
                        line := ReadLine(stream);
                    until line = fail  or  line = "\n";
                    
                # ignore displays for TeX or HTML
                elif MATCH_BEGIN(line,"%display{tex}")
                  or MATCH_BEGIN(line,"%display{html}")
                  or MATCH_BEGIN(line,"%display{jpeg}")  then
                    repeat
                        line := ReadLine(stream);
                    until line = fail
                       or MATCH_BEGIN(line,"%display{text}")
                       or MATCH_BEGIN(line,"%enddisplay");
                    if MATCH_BEGIN(line,"%display{text}")  then
                        verbatim := true;
		        EmptyLine();
                    fi;
                    
		elif MATCH_BEGIN(line,"\\index{") 
		  or MATCH_BEGIN(line,"\\indextt{") then
		  line:="";
                # example environment
                elif MATCH_BEGIN(line,"\\beginexample")
                  or MATCH_BEGIN(line,"\\begintt")
                  or MATCH_BEGIN(line,"%display{text}")  then
                    verbatim := true;
		    EmptyLine();
                elif MATCH_BEGIN(line,"\\endexample")
                  or MATCH_BEGIN(line,"\\endtt")
                  or MATCH_BEGIN(line,"%enddisplay")  then
                    verbatim := false;
		    lastblank:=false;
		    EmptyLine();

		elif MATCH_BEGIN(line,"\\beginitems") or
		     MATCH_BEGIN(line,"\\enditems") then
		  EmptyLine();

                # verbatim mode
                elif verbatim  and line[1] = '%'  then
                    Add( lines, line{[2..Length(line)]} );
                    
                # ignore lines starting or ending with '%'
                elif line[1] = '%'  or  line[Length(line)] = '%'  then
                    ;

                # use everything else
                else
                    if not verbatim  then
		      if   MATCH_BEGIN(line,"\\exercise")  then
			  line{[1..9]} := "EXERCISE:";
		      elif MATCH_BEGIN(line,"\\danger")  then
			  line{[1..7]} := "DANGER:";
		      fi;

		      # cope with `\>' entries
		      if MATCH_BEGIN(line,"\\>") or
		         MATCH_BEGIN(line,"\\)") then
			if singleline<>2 then
			  # force separator if the line above was not
			  # already a header
			  EmptyLine();
			fi;
			singleline:=2; # we want it on a single line and it
			               # may have a `cat' letter
			rund:=line[2]=')';
			line:=line{[3..Length(line)]}; # remove `>'

			line:=Concatenation("> ",line); # add the leading `>'
		      else
			# by default we don't request single lines
			singleline:=0;
                      fi;

		      # some further handling of TeX macros
		      p:=Position(line,'\\');
		      while p<>fail do
			tail:=line{[p+1..Length(line)]};
			line:=line{[1..p-1]};
			# accent-aigu/apostrophe
			if tail[1]='\'' then
			  if Length(line)>0 and line[Length(line)]='{' then 
			    line:=line{[1..Length(line)-1]};
			  fi;
			  tail:=Concatenation("'",tail{[2]},
					      tail{[4..Length(tail)]});
			elif tail[1]='>' or tail[1]=')' then
			  tail:=Concatenation(" ",tail);
			else
			  p:=1;
			  while p<=Length(tail) 
			    and tail[p]<>' ' and tail[p]<>'{' 
			    and tail[p]<>'\\' and tail[p]<>'}'
			    and tail[p]<>')' and tail[p]<>'$' do
			    p:=p+1;
			  od;
			  macro:=tail{[1..p-1]};
			  tail:=tail{[p..Length(tail)]};
			  # handle some macros
			  # Umlaut
			  if macro="accent127" then
			    line:=line{[1..Length(line)-1]};
			    tail:=Concatenation("\"",tail{[2]},
						tail{[4..Length(tail)]});
			  # sharp s
			  elif macro="ss" then
			    tail:=Concatenation("ss",tail);
                          elif macro="langle" then
			    tail:=Concatenation("<",tail);
                          elif macro="rangle" then
			    tail:=Concatenation(">",tail);
			  elif macro="copyright" then
			    tail:=Concatenation("C",tail);

			  elif macro="GAP" then
			    tail:=Concatenation("GAP",tail);
			  elif macro="MOC" then
			    tail:=Concatenation("MOC",tail);
			  elif macro="pif" then
			    tail:=Concatenation("'",tail);
			  elif macro="dots" or macro="ldots" then
			    tail:=Concatenation("...",tail);
			  elif macro="dot" then
			    tail:=Concatenation(".",tail);

			  elif macro="medskip" then
			    EmptyLine();
			  elif macro="bigskip" then
			    EmptyLine();

			  # math macros
			  elif macro="in" then
			    tail:=Concatenation(" in ",tail);
			  elif macro="mid" then
			    tail:=Concatenation("|",tail);
			  else
			    # display the macro name
			    tail:=Concatenation(macro,tail);
			  fi;
			fi;
			line:=Concatenation(line,tail);
			if IsEmpty(line) then line:="";fi;
			p:=Position(line,'\\');
		      od;
                    fi;

		    lastblank:=false;
		    if verbatim then
		      Add( lines, line );
		    elif singleline=2 then
		      # treat a trailing `category' letter
		      p:=line[Length(line)];
		      if p in "CROFPAV" then
			p:=Length(line);
			line:=FILLED_LINE(line{[1..p-1]},line{[p]},' ');
		      fi;
		      Add(lines,line);
		    elif singleline=0 then
		      if Length(buff)>0 then
		        Add(buff,' '); # separating ' '
		      fi;
		      buff:=Concatenation(buff,line);

		      if Length(buff)>width then # force to fill lines
			# find the last space to break
			p:=width;
			while p>=1 and buff[p]<>' ' do
			  p:=p-1;
			od;
			if p=0 then
			  # cope with overfull lines
			  Add(lines,Concatenation(buff{[1..width-1]},"-"));
			  buff:=buff{[width..Length(buff)]};
			else
			  line:=buff{[1..p-1]};
			  buff:=buff{[p+1..Length(buff)]}; # letter p is the ' '

			  if HELP_FLUSHRIGHT and ' ' in line then
			    # remove trailing blanks
			    ll:=Length(line);
			    while ll>0 and line[ll]=' ' do
			      ll:=ll-1;
			    od;
			    line:=line{[1..ll]};

			    # flush right adjustment, for this the line must
			    # contain spaces
			    p:=0;
			    while ll<width do
			      p:=Position(line,' ',p);
			      if p=fail then
				# start anew
				p:=Position(line,' ',0);
                              fi;
                              # if the line actually contains no
                              #  spaces then give up
                              if p = fail then
                                  break;
                              fi;    
			      # add a blank
			      line:=Concatenation(line{[1..p]},
			                          line{[p..ll]});
			      # avoid to add the next blank just there
			      ll:=ll+1;
			      p:=p+1;
			      while p<=ll and line[p]=' ' do
			        p:=p+1;
			      od;
			      if p>ll then
				p:=0;
			      fi;
			    od;
			  fi;

			  Add(lines,line);
			fi;
                      fi;
		    else
		      Add( lines, line );
		    fi;
                fi;
            fi;
        else
            done := true;
        fi;
    until done;
    CloseStream(stream);

    run:=run+1;
  until key=fail or run=2;

  EmptyLine();

  for line in lines do
    REPLACE_SUBSTRING( line, "~", " " );
  od;
  HELP_PRINT_LINES(lines);

end;

HTML_BROWSER:="netscape -remote \"openURL(";
HTML_BROWSER_TAIL:=")\"";

HELP_PRINT_SECTION_BROWSER := function(arg)
local   pos,book, chapter, section,path;

    book:=arg[1];
    pos:=First([1,4..Length(HELP_BOOKS)-2],i->HELP_BOOKS[i]=book);
    if pos=fail then
      Error("this book does not exist");
    fi;
    book:=HELP_BOOKS[pos+1];
    # find `doc'
    pos:=Length(book)-2;
    while pos>0 and (book[pos]<>'d' or book[pos+1]<>'o' or book[pos+2]<>'c') do
      pos:=pos-1;
    od;
    #see if it is only `doc', if yes skip
    if pos+2=Length(book) then
      # it ends in doc, replace `doc' by `htm'
      book:=Concatenation(book{[1..pos-1]},"htm");
    else
      # insert htm after doc
      book:=Concatenation(book{[1..pos+2]},"/htm",book{[pos+3..Length(book)]});
    fi;

    chapter:=String(arg[2]);
    while Length(chapter)<3 do
      chapter:=Concatenation("0",chapter);
    od;
    section:=arg[3];

    path:=Concatenation(GAP_ROOT_PATHS[1],book,"/CHAP",chapter,
                        ".htm");


    if section>0 then
      section:=String(section);
      while Length(section)<3 do
	section:=Concatenation("0",section);
      od;
      path:=Concatenation(path,"#SECT",section);
    fi;
    Exec(Concatenation(HTML_BROWSER,path,HTML_BROWSER_TAIL));
end;

HELP_EXTERNAL_URL := "";

HELP_PRINT_SECTION_MAC_IC := function(arg)
local   pos,book, chapter, section,path;

    book:=arg[1];
    pos:=First([1,4..Length(HELP_BOOKS)-2],i->HELP_BOOKS[i]=book);
    if pos=fail then
      Error("this book does not exist");
    fi;
    book:=HELP_BOOKS[pos+1];
    # find `doc'
    pos:=Length(book)-2;
    while pos>0 and (book[pos]<>'d' or book[pos+1]<>'o' or book[pos+2]<>'c') do
      pos:=pos-1;
    od;
 	if IsBound (HELP_EXTERNAL_URL) then
 		# remove "/doc"
	    book:=Concatenation(book{[1..pos-1]},book{[pos+3..Length(book)]});
	else
	    #see if it is only `doc', if yes skip
	    if pos+2=Length(book) then
	      # it ends in doc, replace `doc' by `htm'
	     	book:=Concatenation(book{[1..pos-1]},"htm");
	    else
	      # insert htm after doc
			book:=Concatenation(book{[1..pos+2]},"/htm",book{[pos+3..Length(book)]});
	    fi;
    fi;
    chapter:=String(arg[2]);
    while Length(chapter)<3 do
      chapter:=Concatenation("0",chapter);
    od;
    
    if IsBound (HELP_EXTERNAL_URL) then
        path:=Concatenation(HELP_EXTERNAL_URL, book,"/C",chapter);
    else
        path:=Concatenation(book,"/CHAP",chapter,".htm");
    fi;

    section:=arg[3];
    if section > 0 then
    	section:=String(section);
	    while Length(section)<3 do
 	       section:=Concatenation("0",section);
 	    od;
    	if IsBound (HELP_EXTERNAL_URL) then
            path:=Concatenation(path,"S",section,".htm");
        else
            path:=Concatenation(path,"#SECT",section);
        fi;
    elif IsBound (HELP_EXTERNAL_URL) then
        path:=Concatenation(path,"S000.htm");
    fi;
    if IsBound (HELP_EXTERNAL_URL) then
         ExecuteProcess ("", "Internet Config", 1, 0, [path]);
    else
        ExecuteProcess ("./", "Internet Config", 1, 0, [path]);
    fi;

end;

Unbind (HELP_EXTERNAL_URL);

HELP_PRINT_SECTION:=HELP_PRINT_SECTION_SCREEN;

#############################################################################
##
#F  SetHelpViewer(<viewer>):  Set the viewer used for help
##
SetHelpViewer := function(view)
  view:=LowercaseString(view);
  if view="screen" then
    HELP_PRINT_SECTION:=HELP_PRINT_SECTION_SCREEN;
    HELP_PRINT_LINES := HELP_PRINT_LINES_BUILTIN;
    Print("The Help function will display on the screen\n");
  elif view="netscape" then
    HELP_PRINT_SECTION:=HELP_PRINT_SECTION_BROWSER;
    HTML_BROWSER:="netscape -remote \"openURL(";
    HTML_BROWSER_TAIL:=")\"";
    Print("The Help function will use netscape\n");
  elif view="lynx" then
    HELP_PRINT_SECTION:=HELP_PRINT_SECTION_BROWSER;
    HTML_BROWSER:="lynx \"";
    HTML_BROWSER_TAIL:="\"";
    Print("The Help function will use lynx\n");
  elif view="less" then
    HELP_PRINT_SECTION:=HELP_PRINT_SECTION_SCREEN;
    HELP_PRINT_LINES := HELP_PRINT_LINES_LESS;
    Print("The Help function will display on the screen using `less'\n");
  elif view="internet config" then
    HELP_PRINT_SECTION:=HELP_PRINT_SECTION_MAC_IC;
    HTML_BROWSER:="";
    HTML_BROWSER_TAIL:="";
    Print("The Help function will use Internet Config\n");
  else
    Error("sorry, this manual browser is not yet supported");
  fi;
end;

#############################################################################
##
#F  HELP_TEST_EXAMPLES( <book>, <chapter> ) . . . . . . . . test the examples
##
HELP_TEST_EXAMPLES := function( book, chapter )
    local   info,  chap,  filename,  stream,  examples,  test,  line,
            size;

    # get the chapter info
    info := HELP_BOOK_INFO(book);
    chap := HELP_CHAPTER_INFO( book, chapter );
    if chap = fail  then
        return;
    fi;

    # open the stream and read in the help
    filename := Filename( info.directories, info.filenames[chapter] );
    stream := InputTextFile(filename);

    # search for examples
    examples := false;
    test := "";
    repeat
        line := ReadLine(stream);
        if line <> fail  then

            # example environment
            if MATCH_BEGIN(line,"\\beginexample")  then
                examples := true;
            elif MATCH_BEGIN(line,"\\endexample")  then
                examples := false;
            fi;

            # store the lines
            if examples and not MATCH_BEGIN(line,"\\beginexample")  then
                if Length(line) < 5  then
                    Print( "* ", line );
                elif line[5] <> '#'  then
                    line := line{[5..Length(line)]};
                    Append( test, line );
                fi;
            fi;
        fi;
    until IsEndOfStream(stream);
    CloseStream(stream);

    # now do the test
    stream := InputTextString( test );

    size := SizeScreen();
    SizeScreen( [ 72, ] );
    RANDOM_SEED(1);

    ReadTest(stream);

    SizeScreen(size);

end;


#############################################################################
##

#F  # # # # # # # # # # # # # # show functions  # # # # # # # # # # # # # # #
##


#############################################################################
##


#F  HELP_SHOW_BOOKS( <book> ) . . . . . . . . . . . . .  show available books
##
HELP_SHOW_BOOKS := function( book )
    local   books,  i;

    books := [];
    for i  in [ 1, 4 .. Length(HELP_BOOKS)-2 ]  do
        Add( books, FILLED_LINE( HELP_BOOKS[i+2], HELP_BOOKS[i], ' ' ) );
    od;
    Sort(books);
    HELP_PRINT_LINES( Concatenation(
        [ FILLED_LINE( "Table of Books", "GAP 4", '_' ) ],
        books,
        [ "" ]
    ) );
    return true;
    
end;


#############################################################################
##
#F  HELP_SHOW_CHAPTERS( <book> )  . . . . . . . . . . . . . show all chapters
##
HELP_SHOW_CHAPTERS := function( book )
    local   info,  chap,  i;

    # one book
    if IsRecord(book) or 0 < Length(book)  then

        # read in the information file "manual.six" of this book
        info := HELP_BOOK_INFO(book);
        if info = fail  then
            Print( "Help: unknown book \"", book, "\"\n" );
            return false;
        fi;

        # print the chapters
        chap := ShallowCopy(info.chapters);
        Sort(chap);
        HELP_PRINT_LINES( Concatenation(
            [ FILLED_LINE( "Table of Chapters", info.bookname, '_' ) ],
            chap,
            [ "" ]
        ) );

    # all books
    else
        for i  in [ 1, 4 .. Length(HELP_BOOKS)-2 ]  do
            HELP_SHOW_CHAPTERS( HELP_BOOKS[i] );
        od;
    fi;

    return true;

end;


#############################################################################
##
#F  HELP_SHOW_SECTIONS( <book> )  . . . . . . . . . . . . . show all sections
##
HELP_SHOW_SECTIONS := function( book )
    local   info,  lines,  chap,  sec,  i;

    # one book
    if IsRecord(book) or 0 < Length(book)  then

        # read in the information file "manual.six" of this book
        info := HELP_BOOK_INFO(book);
        if info = fail  then
            Print( "Help: unknown book \"", book, "\"\n" );
            return false;
        fi;

        # print the sections
        lines := [ FILLED_LINE( "Table of Sections", info.bookname, '_' ) ];
        for chap  in [ 1 .. Length(info.chapters) ]  do
            Add( lines, info.chapters[chap] );
            for sec  in [ 1 .. Length(info.sections[chap]) ]  do
                Add(lines,Concatenation("    ",info.sections[chap][sec]));
            od;
        od;
        Add( lines, "" );
        HELP_PRINT_LINES(lines);

    # all books
    else
        for i  in [ 1, 4 .. Length(HELP_BOOKS)-2 ]  do
            HELP_SHOW_SECTIONS( HELP_BOOKS[i] );
        od;
    fi;

    return true;

end;


#############################################################################
##
#F  HELP_SHOW_TOPIC( <book>, <topic> )  . . . . . . . . . . . .  find a topic
##
HELP_LAST_BOOK    := "tutorial";
HELP_LAST_CHAPTER := 1;
HELP_LAST_SECTION := 0;

HELP_LAST_TOPICS:=[]; # is used to shortcut several matching topics

NAMES_SYSTEM_GVARS:= "to be defined in init.g";

HELP_SHOW_TOPIC := function( book, topic )
    local origtopic, info, match, exact, line, lines, i, isfun_e,
          isfun_m,cnt,n;

    # is the topic a number?
    if ForAll(topic,i->i in HELP_NUMBERSTRING) then
      i:=Int(topic);
      if IsBound(HELP_LAST_TOPICS[i]) then
	topic:=HELP_LAST_TOPICS[i];
        i:=Position(topic,':');
	book:=topic{[1..i-1]};
	topic:=topic{[i+1..Length(topic)]};
      fi;
    fi;

    # lower case the <topic>
    origtopic:= topic;
    topic := STRING_LOWER(topic);

    # <match> contains the topics matching the beginning
    match := [];

    # <exact> contains the topics matching exactly
    exact := [];

    # read in the information file "manual.six" of this book
    if IsRecord(book) or 0 < Length(book)  then 
        info := HELP_BOOK_INFO(book);
        if info = fail  then
            Print( "Help: unknown book \"", book, "\"\n" );
            return false;
        fi;
        info := [ [book,info] ];
    else
        info := [];
        for i  in [ 1, 4 .. Length(HELP_BOOKS)-2 ]  do
            Add( info, [ HELP_BOOKS[i], HELP_BOOK_INFO(HELP_BOOKS[i]) ] );
        od;
    fi;

    isfun_e:=false;
    isfun_m:=false; # indicates whether it is a function name (in contrast to
                    # a section name)

    # look throught the section and chapter names
    for i  in [ 1 .. Length(info) ]  do
	if info[i][2]<>fail then
	  for line  in info[i][2].secchaps  do
	      if line[1] = topic  then
		  Add( exact, [info[i][1],line] );
		  Add( match, [info[i][1],line] );
	      elif MATCH_BEGIN( line[1], topic )  then
		  Add( match, [info[i][1],line] );
	      fi;
	  od;
        fi;
    od;

    # look throught the index entries
    for i  in [ 1 .. Length(info) ]  do
	if info[i][2]<>fail then
	  for line  in info[i][2].index  do
	      if line[1] = topic  then
		  Add( exact, [info[i][1],line] );
		  Add( match, [info[i][1],line] );
	      elif MATCH_BEGIN( line[1], topic )  then
		  Add( match, [info[i][1],line] );
	      fi;
	  od;
        fi;
    od;

    # no topic function try a function name
    #if 0 = Length(match)  then
        for i  in [ 1 .. Length(info) ]  do
	  if info[i][2]<>fail then
            for line in  info[i][2].functions  do
                if line[1] = topic  then
                    Add( exact, [info[i][1],line] );
		    isfun_e:=true;
                    Add( match, [info[i][1],line] );
                elif MATCH_BEGIN( line[1], topic )  then
                    Add( match, [info[i][1],line] );
		    isfun_m:=true;
                fi;
            od;
	  fi;
        od;

    if 0 = Length(exact)  then
        for i  in [ 1 .. Length(info) ]  do
	  if info[i][2]<>fail then
            for line in  info[i][2].functions  do
                if line[1] = topic  then
                    Add( exact, [info[i][1],line] );
		    isfun_e:=true;
                fi;
            od;
	  fi;
        od;
    fi;

    # no topic found
    if 0 = Length(match)  then
      if origtopic in NAMES_SYSTEM_GVARS then
        Print( "Help: `",origtopic,"' is currently undocumented.\n",
               "      For details, try ?Undocumented Variables\n" );
      else
        Print( "Help: no section about `",topic,"' was found\n" );
      fi;
      return false;

    # one exact match
    elif 1 = Length(exact)  then
	if isfun_e then
	  HELP_PRINT_SECTION( exact[1][1], exact[1][2][2], exact[1][2][3],
			      exact[1][2][1] );
	else
	  HELP_PRINT_SECTION( exact[1][1], exact[1][2][2], exact[1][2][3]);
	fi;
        HELP_LAST_BOOK    := exact[1][1];
        HELP_LAST_CHAPTER := exact[1][2][2];
        HELP_LAST_SECTION := exact[1][2][3];
        return true;

    # one topic found
    elif 1 = Length(match)  then
	if isfun_e or isfun_m then
	  HELP_PRINT_SECTION( match[1][1], match[1][2][2], match[1][2][3],
			      match[1][2][1]);
	else
	  HELP_PRINT_SECTION( match[1][1], match[1][2][2], match[1][2][3]);
	fi;
        HELP_LAST_BOOK    := match[1][1];
        HELP_LAST_CHAPTER := match[1][2][2];
        HELP_LAST_SECTION := match[1][2][3];
        return true;

    # more than one topic found
    else
  Print("Help: several sections match this topic, type ?2 to see topic 2.\n");
        lines := [];
	HELP_LAST_TOPICS:=[];
	cnt:=0;
        for i in [1..Length(match)]  do
	    # cope with multiple entries
	    n:=Number([1..i-1],j->match[j][1]=match[i][1]
	                          and match[j][2][1]=match[i][2][1]);
	    if n>0 then
	      # change the entry to permit separate display
	      Append(match[i][2][1],Concatenation("_(",Ordinal(n+1),")"));
	    fi;

	    cnt:=cnt+1;
	    topic:=Concatenation(match[i][1],":",match[i][2][1]);
	    Add(HELP_LAST_TOPICS,topic);
            Add(lines,Concatenation("[",String(cnt),"] ",topic));
        od;
        HELP_PRINT_LINES(lines);
        return false;
    fi;
end;


#############################################################################
##
#F  HELP_SHOW_COPYRIGHT( <book> ) . . . . . . . . . . . .  show the copyright
##
HELP_SHOW_COPYRIGHT := function( book )
    if 0 = Length(book)  then
        return HELP_SHOW_TOPIC( "reference", "copyright" );
    else
        return HELP_SHOW_TOPIC( book, "copyright" );
    fi;
end;


#############################################################################
##
#F  HELP_SHOW_FIRST( <book> ) . . . . . . . . . . . show chapter introduction
##
HELP_SHOW_FIRST := function( book )
    HELP_LAST_SECTION := 0;
    HELP_PRINT_SECTION( HELP_LAST_BOOK,
                        HELP_LAST_CHAPTER,
                        HELP_LAST_SECTION );
end;


#############################################################################
##
#F  HELP_SHOW_NEXT_CHAPTER( <book> )  . . . . . . . . . . . show next chapter
##
HELP_SHOW_NEXT_CHAPTER := function( book )
    book := HELP_BOOK_INFO(HELP_LAST_BOOK);
    if HELP_LAST_CHAPTER < Length(book.chapters)  then
        HELP_LAST_SECTION := 0;
        HELP_LAST_CHAPTER := HELP_LAST_CHAPTER+1;
    fi;

    HELP_PRINT_SECTION( HELP_LAST_BOOK,
                        HELP_LAST_CHAPTER,
                        HELP_LAST_SECTION );
end;


#############################################################################
##
#F  HELP_SHOW_PREV( <book> )  . . . . . . . . . . . . . show previous section
##
HELP_SHOW_PREV := function( book )
    HELP_LAST_SECTION := HELP_LAST_SECTION - 1;
    if HELP_LAST_SECTION < 0  then
        HELP_LAST_CHAPTER := HELP_LAST_CHAPTER-1;
        if HELP_LAST_CHAPTER <= 0  then
            HELP_LAST_CHAPTER := 1;
            HELP_LAST_SECTION := 0;
        else
            book := HELP_BOOK_INFO(HELP_LAST_BOOK);
            HELP_LAST_SECTION := Length(book.sections[HELP_LAST_CHAPTER]);
        fi;
    fi;

    HELP_PRINT_SECTION( HELP_LAST_BOOK,
                        HELP_LAST_CHAPTER,
                        HELP_LAST_SECTION );
end;


#############################################################################
##
#F  HELP_SHOW_NEXT( <book> )  . . . . . . . . . . . . . . . show next section
##
HELP_SHOW_NEXT := function( book )
    HELP_LAST_SECTION := HELP_LAST_SECTION + 1;
    book := HELP_BOOK_INFO(HELP_LAST_BOOK);
    if Length(book.sections[HELP_LAST_CHAPTER]) < HELP_LAST_SECTION  then
        if Length(book.chapters) <= HELP_LAST_CHAPTER  then
            HELP_LAST_SECTION := HELP_LAST_SECTION-1;
        else
            HELP_LAST_SECTION := 0;
            HELP_LAST_CHAPTER := HELP_LAST_CHAPTER+1;
        fi;
    fi;

    HELP_PRINT_SECTION( HELP_LAST_BOOK,
                        HELP_LAST_CHAPTER,
                        HELP_LAST_SECTION );
end;


#############################################################################
##
#F  HELP_SHOW_WELCOME( <book> ) . . . . . . . . . . . .  show welcome message
##
HELP_SHOW_WELCOME := function( book )
    local   lines;

    lines := [
"Welcome to GAP 4\n",
"Try '?tutorial:The Help system' (without quotes) for an introduction to",
"the help system.\n",
"`?chapters' and `?sections' will display a table of contents."
    ];
    HELP_PRINT_LINES(lines);
    return true;
end;


#############################################################################
##
#F  HELP_SHOW_INDEX( <book>, <topic> )  . . . . . . . . . .  search the index
##
HELP_SHOW_INDEX := function( book, topic )
    local   match,  info,  i,  what,  line,  lines,cnt;

    # lower case the <topic>
    topic := STRING_LOWER(topic);

    # <match> contains the topics matching
    match := [];

    # read in the information file "manual.six" of this book
    if IsRecord(book) or 0 < Length(book)  then 
        info := HELP_BOOK_INFO(book);
        if info = fail  then
            Print( "Help: unknown book \"", book, "\"\n" );
            return false;
        fi;
        info := [ [book,info] ];
    else
        info := [];
        for i  in [ 1, 4 .. Length(HELP_BOOKS)-2 ]  do
            Add( info, [ HELP_BOOKS[i], HELP_BOOK_INFO(HELP_BOOKS[i]) ] );
        od;
    fi;

    # look throught the section & chapter names, index, functions
    for i  in [ 1 .. Length(info) ]  do
	if info[i][2]<>fail then
	  what := Concatenation(info[i][2].secchaps,info[i][2].index,
				info[i][2].functions);

	  for line  in what  do
	      if IS_SUBSTRING( line[1], topic )  then
		  Add( match, [info[i][1],line] );
	      fi;
	  od;
      fi;
    od;

    # no topic found
    if 0 = Length(match)  then
        Print( "Help: no entry with this name was found\n" );
        return false;

    # one topic found
    elif 1 = Length(match)  then
        HELP_PRINT_SECTION( match[1][1], match[1][2][2], match[1][2][3] );
        HELP_LAST_BOOK    := match[1][1];
        HELP_LAST_CHAPTER := match[1][2][2];
        HELP_LAST_SECTION := match[1][2][3];
        return true;

    # more than one topic found
    else
        Print( "Help: several entries match this topic\n" );
        lines := [];
	HELP_LAST_TOPICS:=[];
	cnt:=0;
        for i  in match  do
	    cnt:=cnt+1;
	    topic:=Concatenation(i[1],":",i[2][1]);
	    Add(HELP_LAST_TOPICS,topic);
            Add(lines,Concatenation("[",String(cnt),"] ",topic));
        od;
        HELP_PRINT_LINES(lines);
        return false;
    fi;
end;


#############################################################################
##
#F  HELP( <string> )  . . . . . . . . . . . . . . .  deal with a help request
##
HELP_RING_IDX   := 0;
HELP_RING_SIZE  := 16;
HELP_BOOK_RING  := ListWithIdenticalEntries( HELP_RING_SIZE, 
                                             "tutorial" );
HELP_TOPIC_RING := ListWithIdenticalEntries( HELP_RING_SIZE, 
                                             "welcome to gap" );

HELP := function( str )
    local   p,  book,  move,  add, origstr;

    # remove leading ' '
    while 0 < Length(str) and str[1] = ' '  do
        str := str{[2..Length(str)]};
    od;

    # Replace double ' ' by single ' '.
    move:= false;
    for p in [ 1 .. Length( str ) - 1 ] do
      if str[p] = ' ' and str[ p+1 ] = ' ' then
        Unbind( str[p] );
        move:= true;
      fi;
    od;
    if move then
      str:= Compacted( str );
    fi;

    # remove trailing ';'
    while 0 < Length(str) and str[Length(str)] = ';'  do
        str := str{[1..Length(str)-1]};
    od;

    # extract the book
    p := Position( str, ':' );
    if p <> fail  then
        book := str{[1..p-1]};
        str  := str{[p+1..Length(str)]};
    else
        book := "";
    fi;
    origstr:= str;
    str := STRING_LOWER(str);

    # function to add a topic to the ring
    move := false;
    add  := function( book, topic )
        if not move  then
            HELP_RING_IDX := (HELP_RING_IDX+1) mod HELP_RING_SIZE;
            HELP_BOOK_RING[HELP_RING_IDX+1]  := book;
            HELP_TOPIC_RING[HELP_RING_IDX+1] := topic;
        fi;
    end;

    # if the topic is empty take the last one again
    if str = ""  then
        book := HELP_BOOK_RING[HELP_RING_IDX+1];
        str  := HELP_TOPIC_RING[HELP_RING_IDX+1];
        move := true;

    # if the topic is '-' we are interested in the previous section again
    elif str = "-"  then
        HELP_RING_IDX := (HELP_RING_IDX-1) mod HELP_RING_SIZE;
        book := HELP_BOOK_RING[HELP_RING_IDX+1];
        str  := HELP_TOPIC_RING[HELP_RING_IDX+1];
        move := true;

    # if the topic is '+' we are interested in the last section again
    elif str = "+"  then
        HELP_RING_IDX := (HELP_RING_IDX+1) mod HELP_RING_SIZE;
        book := HELP_BOOK_RING[HELP_RING_IDX+1];
        str  := HELP_TOPIC_RING[HELP_RING_IDX+1];
        move := true;
    fi;

    # if the topic is '<' we are interested in the one before 'LastTopic'
    if str = "<"  then
        HELP_SHOW_PREV(book);

    # if the topic is '>' we are interested in the one after 'LastTopic'
    elif str = ">"  then
        HELP_SHOW_NEXT(book);

    # if the topic is '<<' we are interested in the chapter intro
    elif str = "<<"  then
        HELP_SHOW_FIRST(book);

    # if the topic is '>>' we are interested in the next chapter
    elif str = ">>"  then
        HELP_SHOW_NEXT_CHAPTER(book);

    # if the subject is 'Welcome to GAP' display a welcome message
    elif str = "welcome to gap"  then
        if HELP_SHOW_WELCOME(book)  then
            add( book, "Welcome to GAP" );
        fi;

    # if the topic is 'books' display the table of books
    elif str = "books"  then
        if HELP_SHOW_BOOKS(book)  then
            add( book, "books" );
        fi;

    # if the topic is 'chapter' display the table of chapters
    elif str = "chapters"  then
        if HELP_SHOW_CHAPTERS(book)  then
            add( book, "chapters" );
        fi;

    # if the topic is 'sections' display the table of sections
    elif str = "sections"  then
        if HELP_SHOW_SECTIONS(book)  then
            add( book, "sections" );
        fi;

    # if the topic is 'Copyright' print the copyright
    elif str = "copyright"  then
        if HELP_SHOW_COPYRIGHT(book)  then
            add( book, "copyright" );
        fi;

    # if the topic is '?<string>' search the index
    elif str[1] = '?'  then
        if HELP_SHOW_INDEX( book, str{[2..Length(str)]} )  then
            add( book, str );
        fi;

    # search for this topic
    else
        if HELP_SHOW_TOPIC( book, origstr )  then
            add( book, str );
        fi;
    fi;
end;


#############################################################################
##
#E

