#############################################################################
##
#W  help.g                     GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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

    if 0 = Length(b) or Length(a) < Length(b)  then
        return false;
    fi;
    return a{[1..Length(b)]} = b;

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
] );


#############################################################################
##
#V  HELP_BOOKS	. . . . . . . . . . . . . . . . . . . . . . . . list of books
##
##  A list of books including the *loaded* share libraries.
##
HELP_BOOKS := ShallowCopy(HELP_MAIN_BOOKS);


#############################################################################
##

#F  HELP_BOOK_INFO( <book> )  . . . . . . . . . . . . . get info about a book
##
HELP_BOOK_INFO := function( book )
    local   nums,  readNumber,  path,  i,  bnam,  six,  stream,  c,  
            s,  f,  line,  c1,  c2,  pos,  name,  num,  x,  s1,  sec,
            s2,  dirs,  j,  x1,  f1;

    # if this is already a record return it
    if IsRecord(book)  then
        return book;

    # no information about the empty book
    elif 0 = Length(book)  then
        return fail;
    fi;

    # numbers
    nums := "0123456789";
    readNumber := function( str )
        local   n;

        while str[pos] = ' '  do
            pos := pos+1;
        od;
        n := 0;
        while str[pos] <> '.'  do
            n := n * 10 + (Position(nums,str[pos])-1);
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
                if line[1] = 'C'  then
                    if line{[1..10]} <> "C appendix"  then
                        Add( c, line{[3..Length(line)-1]} );
                    fi;
                elif line[1] = 'S'  then
                    Add( s, line{[3..Length(line)-1]} );
                elif line[1] = 'I'  then
                    Add( x, line{[3..Length(line)-1]} );
                elif line[1] = 'F'  then
                    Add( f, line{[3..Length(line)-1]} );
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
            while i[pos] = ' '  do pos := pos+1;  od;

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
            while i[pos] = ' '  do pos := pos+1;  od;

            # store the information in <s1>
            s1[num][sec] := i{[pos..Length(i)]};
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
            while i[pos] = ' '  do pos := pos+1;  od;
 
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
            while i[pos] = ' '  do pos := pos+1;  od;
 
            # store the information in <x1>
            Add( f1, [ STRING_LOWER(i{[pos..Length(i)]}), num, sec ] );
        od;
        Sort( f1, function(a,b) return a[1]<b[1];  end );

        HELP_BOOKS_INFO.(bnam) := rec(
          bookname    := Immutable(bnam),
          book        := Immutable(book),
          directories := dirs,
          filenames   := Immutable(c1),
          chapters    := Immutable(c2),
          sections    := Immutable(s1),
          secchaps    := Immutable(s2),
          secposs     := [],
          chappos     := [],
          index       := Immutable(x1),
          functions   := Immutable(f1)
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
                elif MATCH_BEGIN( line, HELP_CHAPTER_BEGIN )  then
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
HELP_PRINT_LINES := function( lines )
    local   size,  stream,  count,  halt,  line,  i,  char;

    size   := SizeScreen();
    stream := InputTextFile("*errin*");
    count  := 0;
    halt   := "    -- <space> for more, <q> to quit --";
    for line  in lines  do
        if count = size[2]-1  then
            Print( halt, "\c" );
            for i  in halt  do Print( "\b" );  od;
            Print( "\c" );
            char := ReadByte(stream);
            for i  in halt  do Print( " " );  od;
            for i  in halt  do Print( "\b" );  od;
            Print( "\c" );
            if char = 113 or char = 81  then
                Print( "\n" );
                return;
            elif char = 13  then
                count := size[2]-2;
            else
                count := 1;
            fi;
        fi;
        Print( "    ", line, "\n" );
        count := count+1;
    od;
    CloseStream(stream);

end;


#############################################################################
##
#F  HELP_PRINT_SECTION( <book>, <chapter>, <section> )	. . . . . print entry
##
HELP_PRINT_SECTION := function( book, chapter, section )
    local   info,  chap,  filename,  stream,  done,  line,  lines,
            verbatim;

    # get the chapter info
    info := HELP_BOOK_INFO(book);
    chap := HELP_CHAPTER_INFO( book, chapter );
    if chap = fail  then
        return;
    fi;

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
    fi;
    ReadLine(stream);
    verbatim := false;
    repeat
        line := ReadLine(stream);
        if line <> fail  then
            if MATCH_BEGIN( line, HELP_SECTION_BEGIN )  then
                done := true;
            else
                line := line{[1..Length(line)-1]};

                # blanks lines are ok
                if 0 = Length(line)  then
                    if not verbatim  then
                        Add( lines, line );
                    fi;

                # ignore lines starting or ending with '%'
                elif line[1] = '%'  or  line[Length(line)] = '%'  then
                    ;

                # ignore answers to exercises
                elif MATCH_BEGIN(line,"\\answer")  then
                    repeat
                        line := ReadLine(stream);
                    until line = fail  or  line = "\n";
                    
                # example environment
                elif MATCH_BEGIN(line,"\\beginexample")
                  or MATCH_BEGIN(line,"\\begintt")  then
                    verbatim := true;
                    Add( lines, "" );
                elif MATCH_BEGIN(line,"\\endexample")
                  or MATCH_BEGIN(line,"\\endtt")  then
                    verbatim := false;
                    Add( lines, "" );
                
                # use everything else
                else
                    if not verbatim  then
                        if MATCH_BEGIN(line,"\\exercise")  then
                            line{[1..9]} := "EXERCISE:";
                        fi;
                        REPLACE_SUBSTRING( line, "~", " " );
                        REPLACE_SUBSTRING( line, "{\\GAP}", "  GAP " );
                        REPLACE_SUBSTRING( line, "\\", " " );
                    fi;
                    Add( lines, line );
                fi;
            fi;
        else
            done := true;
        fi;
    until done;
    CloseStream(stream);
    Add( lines, "" );
    HELP_PRINT_LINES(lines);

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

HELP_SHOW_TOPIC := function( book, topic )
    local   info,  match,  exact,  line,  lines,  i;

    # lower case the <topic>
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

    # look throught the section and chapter names
    for i  in [ 1 .. Length(info) ]  do
        for line  in info[i][2].secchaps  do
            if line[1] = topic  then
                Add( exact, [info[i][1],line] );
                Add( match, [info[i][1],line] );
            elif MATCH_BEGIN( line[1], topic )  then
                Add( match, [info[i][1],line] );
            fi;
        od;
    od;

    # no topic function try a function name
    if 0 = Length(match)  then
        for i  in [ 1 .. Length(info) ]  do
            for line in  info[i][2].functions  do
                if line[1] = topic  then
                    Add( exact, [info[i][1],line] );
                    Add( match, [info[i][1],line] );
                elif MATCH_BEGIN( line[1], topic )  then
                    Add( match, [info[i][1],line] );
                fi;
            od;
        od;
    elif 0 = Length(exact)  then
        for i  in [ 1 .. Length(info) ]  do
            for line in  info[i][2].functions  do
                if line[1] = topic  then
                    Add( exact, [info[i][1],line] );
                fi;
            od;
        od;
    fi;

    # no topic found
    if 0 = Length(match)  then
        Print( "Help: no section with this name was found\n" );
        return false;

    # one exact match
    elif 1 = Length(exact)  then
        HELP_PRINT_SECTION( exact[1][1], exact[1][2][2], exact[1][2][3] );
        HELP_LAST_BOOK    := exact[1][1];
        HELP_LAST_CHAPTER := exact[1][2][2];
        HELP_LAST_SECTION := exact[1][2][3];
        return true;

    # one topic found
    elif 1 = Length(match)  then
        HELP_PRINT_SECTION( match[1][1], match[1][2][2], match[1][2][3] );
        HELP_LAST_BOOK    := match[1][1];
        HELP_LAST_CHAPTER := match[1][2][2];
        HELP_LAST_SECTION := match[1][2][3];
        return true;

    # more than one topic found
    else
        Print( "Help: several sections match this topic\n" );
        lines := [];
        for i  in match  do
            Add( lines, Concatenation( i[1], ":", i[2][1] ) );
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
"the help system",
    ];
    HELP_PRINT_LINES(lines);
    return true;
end;


#############################################################################
##
#F  HELP_SHOW_INDEX( <book>, <topic> )  . . . . . . . . . .  search the index
##
HELP_SHOW_INDEX := function( book, topic )
    local   match,  info,  i,  what,  line,  lines;

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
        what := Concatenation(info[i][2].secchaps,info[i][2].index,
                              info[i][2].functions);

        for line  in what  do
            if IS_SUBSTRING( line[1], topic )  then
                Add( match, [info[i][1],line] );
            fi;
        od;
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
        for i  in match  do
            Add( lines, Concatenation( i[1], ":", i[2][1] ) );
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
                                             "Welcome to GAP" );

HELP := function( str )
    local   p,  book,  move,  add;

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
    elif str = "Welcome to GAP"  then
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
        if HELP_SHOW_TOPIC( book, str )  then
            add( book, str );
        fi;
    fi;
end;


#############################################################################
##

#E  help.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
