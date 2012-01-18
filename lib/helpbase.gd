#############################################################################
##  
#W  helpbase.gd                 GAP Library                      Frank Lübeck
##  
##  
#Y  Copyright (C)  2001,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 2001 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##  
## The files helpbase.g{d,i} contain the interface between GAP's online help
## and the actual help books.
##  
  
DeclareGlobalFunction("StringStreamInputTextFile");
DeclareGlobalFunction("MATCH_BEGIN");
DeclareGlobalFunction("MATCH_BEGIN_COUNT");
DeclareGlobalFunction("FILLED_LINE");
DeclareGlobalFunction("SIMPLE_STRING");
DeclareGlobalVariable("HELP_KNOWN_BOOKS");
DeclareGlobalFunction("HELP_ADD_BOOK");
DeclareGlobalFunction("HELP_REMOVE_BOOK");
DeclareGlobalVariable("HELP_BOOK_HANDLER");
DeclareGlobalVariable("HELP_BOOKS_INFO");
DeclareGlobalFunction("HELP_BOOK_INFO");
DeclareGlobalFunction("HELP_SHOW_BOOKS");
DeclareGlobalFunction("HELP_SHOW_CHAPTERS");
DeclareGlobalFunction("HELP_SHOW_SECTIONS");
DeclareGlobalFunction("HELP_PRINT_MATCH");
DeclareGlobalFunction("HELP_SHOW_PREV_CHAPTER");
DeclareGlobalFunction("HELP_SHOW_NEXT_CHAPTER");
DeclareGlobalFunction("HELP_SHOW_PREV");
DeclareGlobalFunction("HELP_SHOW_NEXT");
DeclareGlobalFunction("HELP_SHOW_WELCOME");
DeclareGlobalFunction("HELP_GET_MATCHES");
DeclareGlobalFunction("HELP_SHOW_MATCHES");
DeclareGlobalFunction("HELP_SHOW_FROM_LAST_TOPICS");
DeclareGlobalFunction("HELP_LAB_FILE");
DeclareGlobalVariable("HELP_BOOK_RING");
DeclareGlobalVariable("HELP_TOPIC_RING");
DeclareGlobalVariable("HELP_LAST");
DeclareGlobalFunction("HELP");

