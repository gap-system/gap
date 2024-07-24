ID_TO_SYMBOL_LIST:=[];
SYMBOL_COLORS:=rec();
# We split the scanner ids into the lower 3 bits, plus PValuation(id>>3, 2)
# compressing them to 3+5 = 8 bits
COMPRESS_SCANNER_ID := function(id)
    local lo, hi;
    lo := (id mod 8);
    hi := QuoInt(id, 8);
    if hi > 0 then
        hi := PValuation(hi, 2) + 1;
    fi;
    return lo + hi * 8 + 1;
end;

for name in RecNames(SCANNER_SYMBOLS) do
  SYMBOL_COLORS.(name) := TextAttr.reset;
  id := SCANNER_SYMBOLS.(name);
  #Print(name, ": ",id, " -> ", [ id mod 8, QuoInt(id,8), COMPRESS_SCANNER_ID(id)], "\n");
  ID_TO_SYMBOL_LIST[COMPRESS_SCANNER_ID(id)] := name;
od;
ID_TO_SYMBOL := id -> ID_TO_SYMBOL_LIST[COMPRESS_SCANNER_ID(id)];

# identifiers and keywords
SYMBOL_COLORS.S_IDENT     := TextAttr.1;
SYMBOL_COLORS.S_UNBIND    := TextAttr.1;
SYMBOL_COLORS.S_ISBOUND   := TextAttr.1;
SYMBOL_COLORS.S_TRYNEXT   := TextAttr.1;
SYMBOL_COLORS.S_INFO      := TextAttr.1;
SYMBOL_COLORS.S_ASSERT    := TextAttr.1;
SYMBOL_COLORS.S_READWRITE := TextAttr.1;
SYMBOL_COLORS.S_READONLY  := TextAttr.1;
SYMBOL_COLORS.S_ASSERT    := TextAttr.1;
SYMBOL_COLORS.S_REC       := TextAttr.1;
SYMBOL_COLORS.S_FUNCTION  := TextAttr.1;
SYMBOL_COLORS.S_LOCAL     := TextAttr.1;
SYMBOL_COLORS.S_END       := TextAttr.1;
SYMBOL_COLORS.S_IF        := TextAttr.1;
SYMBOL_COLORS.S_FOR       := TextAttr.1;
SYMBOL_COLORS.S_WHILE     := TextAttr.1;
SYMBOL_COLORS.S_REPEAT    := TextAttr.1;
SYMBOL_COLORS.S_ATOMIC    := TextAttr.1;
SYMBOL_COLORS.S_THEN      := TextAttr.1;
SYMBOL_COLORS.S_ELIF      := TextAttr.1;
SYMBOL_COLORS.S_ELSE      := TextAttr.1;
SYMBOL_COLORS.S_FI        := TextAttr.1;
SYMBOL_COLORS.S_DO        := TextAttr.1;
SYMBOL_COLORS.S_OD        := TextAttr.1;
SYMBOL_COLORS.S_UNTIL     := TextAttr.1;
SYMBOL_COLORS.S_BREAK     := TextAttr.1;
SYMBOL_COLORS.S_RETURN    := TextAttr.1;
SYMBOL_COLORS.S_QUIT      := TextAttr.1;
SYMBOL_COLORS.S_QQUIT     := TextAttr.1;
SYMBOL_COLORS.S_CONTINUE  := TextAttr.1;

SYMBOL_COLORS.S_MOD       := TextAttr.1;
SYMBOL_COLORS.S_IN        := TextAttr.1;
SYMBOL_COLORS.S_NOT       := TextAttr.1;
SYMBOL_COLORS.S_AND       := TextAttr.1;
SYMBOL_COLORS.S_OR        := TextAttr.1;

# brackets, parens, ...
SYMBOL_COLORS.S_LBRACK        := TextAttr.5;
SYMBOL_COLORS.S_LBRACE        := TextAttr.5;
SYMBOL_COLORS.S_BLBRACK       := TextAttr.5;
SYMBOL_COLORS.S_RBRACK        := TextAttr.5;
SYMBOL_COLORS.S_RBRACE        := TextAttr.5;
SYMBOL_COLORS.S_DOT           := TextAttr.5;
SYMBOL_COLORS.S_BDOT          := TextAttr.5;
SYMBOL_COLORS.S_LPAREN        := TextAttr.5;
SYMBOL_COLORS.S_RPAREN        := TextAttr.5;
SYMBOL_COLORS.S_COMMA         := TextAttr.5;
SYMBOL_COLORS.S_DOTDOT        := TextAttr.5;
SYMBOL_COLORS.S_COLON         := TextAttr.5;
SYMBOL_COLORS.S_DOTDOTDOT     := TextAttr.5;
SYMBOL_COLORS.S_SEMICOLON     := TextAttr.5;
SYMBOL_COLORS.S_DUALSEMICOLON := TextAttr.5;


# constants
SYMBOL_COLORS.S_INT   := TextAttr.4;
SYMBOL_COLORS.S_FLOAT := TextAttr.4;
SYMBOL_COLORS.S_TRUE  := TextAttr.4;
SYMBOL_COLORS.S_FALSE := TextAttr.4;
SYMBOL_COLORS.S_CHAR  := TextAttr.4;

# strings
SYMBOL_COLORS.S_STRING := TextAttr.3;

# operators
SYMBOL_COLORS.S_MULT   := TextAttr.2;
SYMBOL_COLORS.S_MULT   := TextAttr.2;
SYMBOL_COLORS.S_DIV    := TextAttr.2;
SYMBOL_COLORS.S_POW    := TextAttr.2;
SYMBOL_COLORS.S_PLUS   := TextAttr.2;
SYMBOL_COLORS.S_MINUS  := TextAttr.2;
SYMBOL_COLORS.S_EQ     := TextAttr.2;
SYMBOL_COLORS.S_LT     := TextAttr.2;
SYMBOL_COLORS.S_GT     := TextAttr.2;
SYMBOL_COLORS.S_NE     := TextAttr.2;
SYMBOL_COLORS.S_LE     := TextAttr.2;
SYMBOL_COLORS.S_GE     := TextAttr.2;
SYMBOL_COLORS.S_ASSIGN := TextAttr.2;


ExtractRangeFromLines := function(lines, startline, startpos, endline, endpos)
    local data, tmp, i;
    if startline = endline then
        return lines[startline]{[startpos+1 .. endpos]};
    fi;
    tmp := lines[startline];
    data := tmp{[startpos+1 .. Length(tmp)]};
    Add(data, '\n');
    for i in [startline+1 .. endline-1] do
        Append(data, lines[i]);
        Add(data, '\n');
    od;
    tmp := lines[endline];
    Append(data, tmp{[1 .. endpos]});
    return data;
end;


TOKENIZE_STRING:=function(str)
    local res, stat, token, symbol, lines, text, sep1, sep2;
    Add(str, '\n');
    sep1 := "";
    sep2 := "";
    #sep1 := "<";
    #sep2 := ">";
#     Print("Input:\n", str, "\n");
#     Print("Output:\n");
    lines := SplitString(str, "\n");
    res := TOKENIZE_STREAM(InputTextString(str));
    for stat in res do
        if not IsList(stat) then continue; fi;
        for token in stat do
            if not IsList(token) then continue; fi;
            if token[1] = "ERROR" then
                Print("\nEncountered an error: ", token[2], "\n");
                continue;
            fi;
            symbol := Remove(token);
            Add(token, ID_TO_SYMBOL(symbol));

            # extract symbol
            if Length(token) <> 8 then continue; fi;
            if symbol = SCANNER_SYMBOLS.S_EOF then
                Print("\n\n-- EOF --\n");
                continue;
            fi;
            text := ExtractRangeFromLines(lines, token[2], token[3], token[4], token[5]);
            if Length(text) > 0 then
                Print(TextAttr.6, sep1, text, sep2, TextAttr.reset);
                #Print(TextAttr.b6, sep1, text, sep2, TextAttr.reset);
            fi;
            text := ExtractRangeFromLines(lines, token[4], token[5], token[6], token[7]);
            if Length(text) > 0 then
                Print(SYMBOL_COLORS.(ID_TO_SYMBOL(symbol)), sep1, text, sep2, TextAttr.reset);
            fi;
            Add(token, text);
        od;
    od;
    Print("\n");
    return res;
end;


SetPrintFormattingStatus("*stdout*", false);

l:=TOKENIZE_STRING("1;");

l:=TOKENIZE_STRING("1");

l:=TOKENIZE_STRING("1-;");


l:=TOKENIZE_STRING("1+1;");

l:=TOKENIZE_STRING("123 + 456;");

l:=TOKENIZE_STRING("1+1; x:=y-3;");

l:=TOKENIZE_STRING("x:=0123 + 1234; xxxx+777777;");

l:=TOKENIZE_STRING("""
1+1; x:=y-3;
# This is a little test program
f := x -> x+1; # increment function
f(2);
""");
