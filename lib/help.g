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
#F  ReplaceSubstring( <string>, <old>, <new> )
##
ReplaceSubstring := function( string, old, new )
    local   i;
    
    for i  in [ 0 .. Length( string ) - Length( old ) ]  do
        if string{ i + [ 1 .. Length( old ) ] } = old  then
            string{ i + [ 1 .. Length( old ) ] } := new;
        fi;
    od;
end;

#############################################################################
##

#F  MATCH_BEGIN_LOWER( <a>, <b> )
##
MATCH_BEGIN_LOWER := function( a, b )
    local   l,  u,  i,  p,  aa,  bb;

    l := "abcdefghijklmnopqrstuvwxyz";
    u := "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    if 0 = Length(b) or Length(a) < Length(b)  then
        return false;
    fi;

    for i  in [ 1 .. Length(b) ]  do
        p := Position( u, a[i] );
        if p = fail  then aa := a[i];  else aa := l[p];  fi;
        p := Position( u, b[i] );
        if p = fail  then bb := b[i];  else bb := l[p];  fi;
        if aa <> bb  then
            return false;
        fi;
    od;
    return true;

end;


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
    w := w - Length(l) - Length(r);
    n := ShallowCopy(l);
    Add( n, ' ' );
    if 0 < w  then
        while 0 < w  do
            Add( n, f );
            w := w - 1;
        od;
    fi;
    Add( n, ' ' );
    Append( n, r );

    return n;

end;


#############################################################################
##
#F  STRING_LOWER_DIGIT( <str> )
##
STRING_LOWER_DIGIT1 := "";
STRING_LOWER_DIGIT2 := "";

STRING_LOWER_DIGIT := function( str )
    local   new,  s,  p;

    if 0 = Length(STRING_LOWER_DIGIT1)  then
        Append( STRING_LOWER_DIGIT1, "abcdefghijklmnopqrstuvwxyz" );
        Append( STRING_LOWER_DIGIT2, "ABCDEFGHIJKLMNOPQRSTUVWXYZ" );
        Append( STRING_LOWER_DIGIT1, "abcdefghijklmnopqrstuvwxyz" );
        Append( STRING_LOWER_DIGIT2, "abcdefghijklmnopqrstuvwxyz" );
        Append( STRING_LOWER_DIGIT1, "0123456789   " );
        Append( STRING_LOWER_DIGIT2, "0123456789!~ " );
        SortParallel( STRING_LOWER_DIGIT2, STRING_LOWER_DIGIT1 );
    fi;

    new := "";
    for s  in str  do
        p := PositionSorted( STRING_LOWER_DIGIT2, s );
        if p <> fail  then
            Add( new, STRING_LOWER_DIGIT1[p] );
        fi;
    od;
    ConvertToStringRep(new);
    return new;
end;


#############################################################################
##

#F  HELP_PRINT_LINES( <lines> )
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
#V  HELP_BOOKS_INFO
##
HELP_BOOKS_INFO := rec();


#############################################################################
##
#V  HELP_MAIN_BOOKS
##
HELP_MAIN_BOOKS := Immutable( [
    "tutorial",  "tut", "GAP 4 Tutorial",
    "reference", "tut", "GAP 4 Reference Manual"
] );


#############################################################################
##

#F  HELP_BOOK_INFO( <book> )
##
HELP_BOOK_INFO := function( book )
    local   nums,  readNumber,  path,  i,  bnam,  six,  stream,  c,  
            s,  f,  line,  c1,  c2,  pos,  name,  num,  x,  s1,  sec,
            s2,  dirs,  j; 

    if 0 = Length(book)  then
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
    for i  in [ 1, 4 .. Length(HELP_MAIN_BOOKS)-2 ]  do
        if MATCH_BEGIN_LOWER( HELP_MAIN_BOOKS[i], book )  then
            path := HELP_MAIN_BOOKS[i+1];
            break;
        fi;
    od;

    # otherwise it is a share package
    if path = false  then
        path := Concatenation( "pkg/", book, "/doc" );
        bnam := Concatenation( "Share Package '", book, "'" );
    else
        path := Concatenation( "doc/", path );
        bnam := HELP_MAIN_BOOKS[i+2];
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
                    Add( x, line );
                elif line[1] = 'F'  then
                    Add( f, line );
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
                Add( s2, [ STRING_LOWER_DIGIT(s1[i][j]), i, j ] );
            od;
        od;
        for i  in [ 1 .. Length(c2) ]  do
            Add( s2, [ STRING_LOWER_DIGIT(c2[i]), i, 0 ] );
        od;
        Sort( s2, function(a,b) return a[1]<b[1]; end );


        HELP_BOOKS_INFO.(bnam) := rec(
          bookname    := Immutable(bnam),
          directories := dirs,
          filenames   := Immutable(c1),
          chapters    := Immutable(c2),
          sections    := Immutable(s1),
          secchaps    := Immutable(s2),
          secposs     := [],
          chappos     := [],
          index       := x,
          functions   := f
        );
    fi;

    return HELP_BOOKS_INFO.(bnam);

end;


#############################################################################
##
#F  HELP_CHAPTER_INFO( <book>, <chapter> )
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
#F  HELP_TEST_EXAMPLES( <book>, <chapter> )
##
HELP_TEST_EXAMPLES := function( book, chapter )
    local   info,  chap,  filename,  stream,  examples,  test,  line;

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
                else
                    line := line{[5..Length(line)]};
                    Append( test, line );
                fi;
            fi;
        fi;
    until IsEndOfStream(stream);
    CloseStream(stream);

    # now do the test
    stream := InputTextString( test );
    ReadTest(stream);

end;


#############################################################################
##
#F  HELP_PRINT_SECTION( <book>, <chapter>, <section> )
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
                        ReplaceSubstring( line, "~", " " );
                        ReplaceSubstring( line, "{\\GAP}", "  GAP " );
                        ReplaceSubstring( line, "\\", " " );
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

#F  HELP_SHOW_BOOKS( <book> )
##
HELP_SHOW_BOOKS := function( book )
    local   books,  i;

    books := [];
    for i  in [ 1, 4 .. Length(HELP_MAIN_BOOKS)-2 ]  do
        Add( books, FILLED_LINE(
                        HELP_MAIN_BOOKS[i+2],
                        HELP_MAIN_BOOKS[i],
                        '.' ) );
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
#F  HELP_SHOW_CHAPTERS( <book> )
##
HELP_SHOW_CHAPTERS := function( book )
    local   info,  chap,  i;

    # one book
    if 0 < Length(book)  then

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
        for i  in [ 1, 4 .. Length(HELP_MAIN_BOOKS)-2 ]  do
            HELP_SHOW_CHAPTERS( HELP_MAIN_BOOKS[i] );
        od;
    fi;

    return true;

end;


#############################################################################
##
#F  HELP_SHOW_SECTIONS( <book> )
##
HELP_SHOW_SECTIONS := function( book )
    local   info,  lines,  chap,  sec,  i;

    # one book
    if 0 < Length(book)  then

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
        for i  in [ 1, 4 .. Length(HELP_MAIN_BOOKS)-2 ]  do
            HELP_SHOW_SECTIONS( HELP_MAIN_BOOKS[i] );
        od;
    fi;

    return true;

end;


#############################################################################
##
#F  HELP_SHOW_TOPIC( <book>, <topic> )
##
HELP_SHOW_TOPIC := function( book, topic )
    local   info,  match,  line,  lines,  i;

    # read in the information file "manual.six" of this book
    info := HELP_BOOK_INFO(book);
    if info = fail  then
        Print( "Help: unknown book \"", book, "\"\n" );
        return false;
    fi;

    match := [];
    topic := STRING_LOWER_DIGIT(topic);
    for line  in info.secchaps  do
        if MATCH_BEGIN( line[1], topic )  then
            Add( match, line );
        fi;
    od;

    # no topic found
    if 0 = Length(match)  then
        Print( "Help: no section with this name was found\n" );
        return false;

    # one topic found
    elif 1 = Length(match)  then
        HELP_PRINT_SECTION( book, match[1][2], match[1][3] );
        return true;

    # more than one topic found
    else
        Print( "Help: several sections match this topic\n" );
        lines := [];
        for i  in match  do
            Add( lines, i[1] );
        od;
        HELP_PRINT_LINES(lines);
        return false;
    fi;
end;


#############################################################################
##
#F  HELP_SHOW_WELCOME( <book> )
##
HELP_SHOW_WELCOME := function( book )
    local   lines;

    lines := [
    "Welcome to GAP\n"
    ];
    HELP_PRINT_LINES(lines);
end;


#############################################################################
##
#F  HELP( <string> )
##
HELP_RING_IDX   := 0;
HELP_BOOK_RING  := List( [1..16], x -> "tutorial" );
HELP_TOPIC_RING := List( [1..16], x -> "Welcome to GAP" );

HELP := function( str )
    local   p,  book,  move;

    # extract the book
    p := Position( str, ':' );
    if p <> fail  then
        book := str{[1..p-1]};
        str  := str{[p+1..Length(str)]};
    else
        book := "";
    fi;
    move := false;

    # if the topic is empty take the last one again
    if str = ""  then
        book := HELP_BOOK_RING[HELP_RING_IDX+1];
        str  := HELP_TOPIC_RING[HELP_RING_IDX+1];
        move := true;

    # if the topic is '-' we are interested in the previous section again
    elif str = "-"  then
        HELP_RING_IDX := (HELP_RING_IDX-1) mod 16;
        book := HELP_BOOK_RING[HELP_RING_IDX+1];
        str  := HELP_TOPIC_RING[HELP_RING_IDX+1];
        move := true;

    # if the topic is '+' we are interested in the last section again
    elif str = "+"  then
        HELP_RING_IDX := (HELP_RING_IDX+1) mod 16;
        book := HELP_BOOK_RING[HELP_RING_IDX+1];
        str  := HELP_TOPIC_RING[HELP_RING_IDX+1];
        move := true;
    fi;

    # if the topic is '<' we are interested in the one before 'LastTopic'
    if str = '<'  then
        ;

    # if the topic is '>' we are interested in the one after 'LastTopic'
    elif str = '>'  then
        ;

    # if the topic is '<<' we are interested in the first section
    elif str = "<<"  then
        ;

    # if the topic is '>>' we are interested in the next chapter
    elif str = ">>"  then
        ;

    # if the subject is 'Welcome to GAP' display a welcome message
    elif str = "Welcome to GAP"  then
        if HELP_SHOW_WELCOME(book) and not move  then
            HELP_RING_IDX := (HELP_RING_IDX+1) mod 16;
            HELP_BOOK_RING[HELP_RING_IDX+1]  := book;
            HELP_TOPIC_RING[HELP_RING_IDX+1] := "Welcome to GAP";
        fi;

    # if the topic is 'books' display the table of books
    elif MATCH_BEGIN_LOWER( "books", str )  then
        if HELP_SHOW_BOOKS(book) and not move  then
            HELP_RING_IDX := (HELP_RING_IDX+1) mod 16;
            HELP_BOOK_RING[HELP_RING_IDX+1]  := book;
            HELP_TOPIC_RING[HELP_RING_IDX+1] := "books";
        fi;

    # if the topic is 'chapter' display the table of chapters
    elif MATCH_BEGIN_LOWER( "chapters", str )  then
        if HELP_SHOW_CHAPTERS(book) and not move  then
            HELP_RING_IDX := (HELP_RING_IDX+1) mod 16;
            HELP_BOOK_RING[HELP_RING_IDX+1]  := book;
            HELP_TOPIC_RING[HELP_RING_IDX+1] := "chapters";
        fi;

    # if the topic is 'sections' display the table of sections
    elif MATCH_BEGIN_LOWER( "sections", str )  then
        if HELP_SHOW_SECTIONS(book) and not move  then
            HELP_RING_IDX := (HELP_RING_IDX+1) mod 16;
            HELP_BOOK_RING[HELP_RING_IDX+1]  := book;
            HELP_TOPIC_RING[HELP_RING_IDX+1] := "sections";
        fi;

    # if the topic is 'Copyright' print the copyright
    elif MATCH_BEGIN_LOWER( "copyright", str )  then
        HELP_COPYRIGHT();

    # if the topic is '?<string>' search the index
    elif str[1] = '?'  then
        HELP_INDEX( str{[2..Length(str)]} );

    # search for this topic
    else
        if HELP_SHOW_TOPIC( book, str ) and not move  then
            HELP_RING_IDX := (HELP_RING_IDX+1) mod 16;
            HELP_BOOK_RING[HELP_RING_IDX+1]  := book;
            HELP_TOPIC_RING[HELP_RING_IDX+1] := str;
        fi;
    fi;
end;


#############################################################################
##

#E  help.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
