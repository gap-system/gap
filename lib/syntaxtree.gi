# Prototype compiler that processes a syntax tree.
# At the moment a syntax tree is a record, we might
# make this into proper GAP objects later

# (<>) :: Doc -> Doc -> Doc
# nil :: Doc
# text :: String -> Doc
# line :: Doc
# nest :: Int -> Doc -> Doc
# layout :: Doc -> String


# Attempt at a Wadler Prettier Printer
#
# http://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf
#
PP := rec( concat := {docs...} -> Concatenation(docs)
         , nil := ""
         , text := txt -> txt
         , line := "\n"
         , nest := function(i, doc)
             local lines;
             lines := SplitString(doc, '\n');
             lines{[2..Length(lines)]} := List(lines{[2..Length(lines)]}, x -> Concatenation(ListWithIdenticalEntries(i, ' '), x));
             return JoinStringsWithSeparator(lines, "\n");
         end
         , layout := function(doc)  end
);

# data Tree = Node String [Tree]
# showTree (Node s ts) = text s <> nest (length s) (showBracket ts)
# showBracket [] = nil
# showBracket ts = text "[" <> nest 1 (showTrees ts) <> text "]"
# showTrees [t] = showTree t
# showTrees (t:ts) = showTree t <> text "," <> line <> showTrees ts

ShowTree := function(tr)
    local ShowT, ShowB, ShowTs;

    ShowT := function(tr)
        return PP.concat( PP.text(tr.s)
                        , PP.nest(Length(tr.s), ShowB(tr.tr)));
    end;

    ShowB := function(trs)
        if Length(trs) = 0 then
            return PP.nil;
        else
            return PP.concat( PP.text("[")
                            , PP.nest(1, ShowTs(trs))
                            , PP.text("]"));
        fi;
    end;

    ShowTs := function(trs)
        local t, res;
        res := [];
        Add(res, ShowT(trs[1]));
        for t in trs{[2..Length(trs)]} do
            Add(res, PP.text(","));
            Add(res, PP.line);
            Add(res, ShowT(t));
        od;
        return CallFuncList(PP.concat, res);
    end;

    return ShowT(tr);
end;

# showTree’ (Node s ts) = text s <> showBracket’ ts
# showBracket’ [] = nil
# showBracket’ ts = text "[" <>
# nest 2 (line <> showTrees’ ts) <>
# line <> text "]")
# showTrees’ [t] = showTree t
# showTrees’ (t:ts) = showTree t <> text "," <> line <> showTrees ts

ShowTree2 := function(tr)
    local ShowT, ShowB, ShowTs;

    ShowT := function(tr)
        return PP.concat( PP.text(tr.s)
                        , PP.nest(Length(tr.s), ShowB(tr.tr)));
    end;

    ShowB := function(trs)
        if Length(trs) = 0 then
            return PP.nil;
        else
            return PP.concat( PP.text("[")
                            , PP.nest(2, PP.concat( PP.line, ShowTs(trs)))
                            , PP.line
                            , PP.text("]"));
        fi;
    end;

    ShowTs := function(trs)
        local t, res;
        res := [];
        Add(res, ShowT(trs[1]));
        for t in trs{[2..Length(trs)]} do
            Add(res, PP.text(","));
            Add(res, PP.line);
            Add(res, ShowT(t));
        od;
        return CallFuncList(PP.concat, res);
    end;

    return ShowT(tr);
end;


intexpr := x -> 5;
int_expr := x -> 500000000000000000000000000000;
char_expr := x -> ' ';
string_expr := x -> "Hello, world";
perm_expr := x -> (1,2,3);
list_expr := x -> [1];
range_expr_1 := x -> [1..4];
range_expr_2 := x -> [1,3..5];
rec_expr := x -> rec( x := 4 );

if_stat := function()
    if true then
        return 0;
    fi;
end;

if_else_stat := function()
    if true then
        return 0;
    else
        return 1;
    fi;
end;

if_elif_stat := function()
    if true then
        return 0;
    elif false then
        return 1;
    fi;
end;

if_elif_else_stat := function()
    if true then
        return 0;
    elif false then
        return 1;
    else
        return 2;
    fi;
end;


trees := List([intexpr, int_expr, char_expr, perm_expr, list_expr, range_expr_1, range_expr_2, string_expr, rec_expr], SYNTAX_TREE);


PrintCompiler := function(tree)
    local info, compile, indent, _Print;
    indent := 0;
    _Print := function(obj)
        Print(ListWithIdenticalEntries(indent, ' '));
    end;

    info := rec( );

    info.T_PROCCALL_0ARGS := function(expr)
        local e;

        compile(expr.("function"));
        Print("\n");
        for e in expr.args do
            compile(e);
        od;
    end;
    # There is no difference between a proccall and a funccall other than
    # a funccall being an expression (it yields a value) and a proccall
    # being a statement (if the call results in a value its ignored)
    # Also all argument counts at this level are handled uniformly
    # so it is enough to implement one function for this
    info.T_PROCCALL_1ARGS := info.T_PROCCALL_0ARGS;
    info.T_PROCCALL_2ARGS := info.T_PROCCALL_0ARGS;
    info.T_PROCCALL_3ARGS := info.T_PROCCALL_0ARGS;
    info.T_PROCCALL_4ARGS := info.T_PROCCALL_0ARGS;
    info.T_PROCCALL_5ARGS := info.T_PROCCALL_0ARGS;
    info.T_PROCCALL_6ARGS := info.T_PROCCALL_0ARGS;
    info.T_PROCCALL_XARGS := info.T_PROCCALL_0ARGS;
    info.T_FUNCCALL_0ARGS := info.T_PROCCALL_0ARGS;
    info.T_FUNCCALL_1ARGS := info.T_PROCCALL_0ARGS;
    info.T_FUNCCALL_2ARGS := info.T_PROCCALL_0ARGS;
    info.T_FUNCCALL_3ARGS := info.T_PROCCALL_0ARGS;
    info.T_FUNCCALL_4ARGS := info.T_PROCCALL_0ARGS;
    info.T_FUNCCALL_5ARGS := info.T_PROCCALL_0ARGS;
    info.T_FUNCCALL_6ARGS := info.T_PROCCALL_0ARGS;
    info.T_FUNCCALL_XARGS := info.T_PROCCALL_0ARGS;

    # Sequence of statements
    info.T_SEQ_STAT := function(expr)
        local s;
        for s in expr.statements do
            compile(s);
            Print("\n");
        od;
    end;
    info.T_SEQ_STAT2 := info.T_SEQ_STAT;
    info.T_SEQ_STAT3 := info.T_SEQ_STAT;
    info.T_SEQ_STAT4 := info.T_SEQ_STAT;
    info.T_SEQ_STAT5 := info.T_SEQ_STAT;
    info.T_SEQ_STAT6 := info.T_SEQ_STAT;
    info.T_SEQ_STAT7 := info.T_SEQ_STAT;

    # If statements are also handled uniformly in the
    # SYNTAX_TREE module
    info.T_IF := function(expr)
        Print("if fi;")
    end;
    info.T_IF_ELSE := info.T_IF;
    info.T_IF_ELIF := info.T_IF;
    info.T_IF_ELIF_ELSE := info.T_IF;

    info.T_FOR := function(expr) end;
    info.T_FOR2 := function(expr) end;
    info.T_FOR3 := function(expr) end;

    info.T_FOR_RANGE := function(expr) end;
    info.T_FOR_RANGE2 := function(expr) end;
    info.T_FOR_RANGE3 := function(expr) end;

    info.T_WHILE := function(expr) end;
    info.T_WHILE2 := function(expr) end;
    info.T_WHILE3 := function(expr) end;

    info.T_REPEAT := function(expr) end;
    info.T_REPEAT2 := function(expr) end;
    info.T_REPEAT3 := function(expr) end;

    # Info evaluates arguments lazily
    info.T_INFO := function(expr) end;
    info.T_EMPTY := function(expr) end;

    # Options
    info.T_PROCCALL_OPTS := function(expr) end;
    
    # HPC-GAP's atomic statement (what about readwrite/readonly?)
    info.T_ATOMIC := function(expr) end;

    # A function expression
    info.T_FUNC_EXPR := function(expr)
        local i;
        Print("function");
        if expr.argnams <> [] then
            Print(" ");
            for i in expr.argnams do
                Print(i);
                Print(" ");
            od;
        fi;
        Print("\n");
        if expr.locnams <> [] then
            Print(" local ");
            for i in expr.locnams do
                Print(i);
                Print(" ");
            od;
            Print("\n");
        fi;
        compile(expr.stats);
        Print("\n");
    end;

    # These come from literals
    # TODO: Maybe make the component names uniform
    info.T_TRUE_EXPR := expr -> "true";
    info.T_FALSE_EXPR := expr -> "false";
    info.T_INTEXPR := expr -> String(expr.value);
    info.T_INT_EXPR := expr -> String(expr.value);
    info.T_CHAR_EXPR := expr -> String(expr.value);
    info.T_STRING_EXPR := function(expr) Print(expr.string);
                          end;

    # TODO: Understand the Float parsing code.
    info.T_FLOAT_EXPR_EAGER := function(expr) end;
    info.T_FLOAT_EXPR_LAZY := function(expr) end;

    # Composite data types
    #
    # Even though they look like literals mostly,
    # permutations behave more like lists, because they
    # can contain arbitrary expressions
    info.T_PERM_EXPR := expr -> String(expr.value);
    info.T_LIST_EXPR := function(expr) end;
    info.T_LIST_TILD_EXPR := function(expr) end;
    info.T_RANGE_EXPR := function(expr) end;
    info.T_REC_EXPR := function(expr) end;

    # Different variable references, and the
    # appropriate IsBound constructs
    info.T_REFLVAR := function(expr) end;
    info.T_ISB_LVAR := function(expr) end;
    info.T_REFHVAR := function(expr) end;
    info.T_ISB_HVAR := function(expr) end;
    info.T_REFLGAR := function(expr) end;
    info.T_ISB_GVAR := function(expr) end;

    # Return statements (could also be folded into one)
    info.T_RETURN_VOID := function(expr)
        Print("return");
    end;
    info.T_RETURN_OBJ := function(expr)
        Print("return ");
        compile(expr.obj);
        Print("\n");
    end;

    compile := function(tree_)
        info.(tree_.type)(tree_);
    end;

    compile(tree);
end;

