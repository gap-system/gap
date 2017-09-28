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

# Unifies the different proccall, funccall, seq stat, while, for, repeat
CleanupCompiler := function(tree)
    local info, compile,
          compile_record, binary_op, unary_op;

    info := rec( );

    info.T_PROCCALL_XARGS := function(expr)
        return rec( type := "T_PROCCALL"
                  , funcref := compile(expr.funcref)
                  , args := List(expr.args, compile) );
    end;
    info.T_FUNCCALL_XARGS := function(expr)
        return rec( type := "T_FUNCCALL"
                  , funcref := compile(expr.funcref)
                  , args := List(expr.args, compile) );
    end;
    # There is no difference between a proccall and a funccall other than
    # a funccall being an expression (it yields a value) and a proccall
    # being a statement (if the call results in a value its ignored)
    # Also all argument counts at this level are handled uniformly
    # so it is enough to implement one function for this
    info.T_FUNCCALL_0ARGS := info.T_PROCCALL_XARGS;
    info.T_PROCCALL_1ARGS := info.T_PROCCALL_XARGS;
    info.T_PROCCALL_2ARGS := info.T_PROCCALL_XARGS;
    info.T_PROCCALL_3ARGS := info.T_PROCCALL_XARGS;
    info.T_PROCCALL_4ARGS := info.T_PROCCALL_XARGS;
    info.T_PROCCALL_5ARGS := info.T_PROCCALL_XARGS;
    info.T_PROCCALL_6ARGS := info.T_PROCCALL_XARGS;

    info.T_FUNCCALL_0ARGS := info.T_FUNCCALL_XARGS;
    info.T_FUNCCALL_1ARGS := info.T_FUNCCALL_XARGS;
    info.T_FUNCCALL_2ARGS := info.T_FUNCCALL_XARGS;
    info.T_FUNCCALL_3ARGS := info.T_FUNCCALL_XARGS;
    info.T_FUNCCALL_4ARGS := info.T_FUNCCALL_XARGS;
    info.T_FUNCCALL_5ARGS := info.T_FUNCCALL_XARGS;
    info.T_FUNCCALL_6ARGS := info.T_FUNCCALL_XARGS;
    info.T_FUNCCALL_XARGS := info.T_FUNCCALL_XARGS;

    # Sequence of statements
    # This might be too complicated: it makes sure that
    # a nested T_SEQ_STAT is flattened to a single
    # sequence, but GAP's coder probably only
    # nests at depth 1. 
    info.T_SEQ_STAT := function(expr)
        local tmp, seq, pos, stack, seqstat, sstypes;
        sstypes := [ "T_SEQ_STAT"
                   , "T_SEQ_STAT2"
                   , "T_SEQ_STAT3"
                   , "T_SEQ_STAT4"
                   , "T_SEQ_STAT5"
                   , "T_SEQ_STAT6"
                   , "T_SEQ_STAT7" ];
        stack := [ [ 1, expr.statements ] ];
        seqstat := [];

        repeat
            tmp := Remove(stack);
            pos := tmp[1];
            seq := tmp[2];
            while pos <= Length(seq)
                  and not (seq[pos].type in sstypes) do
                Add(seqstat, compile(seq[pos]));
                pos := pos + 1;
            od;
            if pos < Length(seq)
               and seq[pos] in sstypes then
                tmp := seq[pos];
                Add(stack, [ pos + 1, seq ]);
                seq := tmp;
            fi;
        until IsEmpty(stack);

        return rec( type := "T_SEQ_STAT"
                  , statements := seqstat );
    end;
    # These are compressed into a single
    # sequence of statements by the above function
    info.T_SEQ_STAT2 := info.T_SEQ_STAT;
    info.T_SEQ_STAT3 := info.T_SEQ_STAT;
    info.T_SEQ_STAT4 := info.T_SEQ_STAT;
    info.T_SEQ_STAT5 := info.T_SEQ_STAT;
    info.T_SEQ_STAT6 := info.T_SEQ_STAT;
    info.T_SEQ_STAT7 := info.T_SEQ_STAT;

    # If statements are also handled uniformly in the
    # SYNTAX_TREE module
    info.T_IF := function(expr)
        local compile_branch;
        compile_branch := function(branch)
            return rec( condition := compile(branch.condition) 
                      , body := compile(branch.body) );
        end;
        return rec( type := "T_IF"
                  , branches := List(expr.branches, compile_branch) );
    end;
    info.T_IF_ELSE := info.T_IF;
    info.T_IF_ELIF := info.T_IF;
    info.T_IF_ELIF_ELSE := info.T_IF;

    info.T_FOR := function(expr) 
        local res;
        res := rec( type := "T_FOR"
                  , variable := expr.variable
                  , collection := compile(expr.collection)
                  , body := List(expr.body, compile) );
        if res.body[1].type <> "T_SEQ_STAT" then
            res.body := rec( type := "T_SEQ_STAT"
                           , statements := res.body );
        fi;
        return res;
    end;
    info.T_FOR2 := info.T_FOR;
    info.T_FOR3 := info.T_FOR;

    info.T_FOR_RANGE := info.T_FOR;
    info.T_FOR_RANGE2 := info.T_FOR;
    info.T_FOR_RANGE3 := info.T_FOR;

    info.T_WHILE := function(expr)
        local res;
        res := rec( type := "T_WHILE"
                  , condition := expr.condition
                  , body := List(expr.body, compile));
        if res.body[1].type <> "T_SEQ_STAT" then
            res.body := rec( type := "T_SEQ_STAT"
                           , body := res.body );
        fi;
        return res;
    end;
    info.T_WHILE2 := function(expr) end;
    info.T_WHILE3 := function(expr) end;

    info.T_REPEAT := function(expr)
        local res;
        res := rec( type := "T_REPEAT"
                  , condition := expr.condition
                  , body := List(expr.body, compile));
        if res.body[1].type <> "T_SEQ_STAT" then
            res.body := rec( type := "T_SEQ_STAT"
                           , body := res.body );
        fi;
        return res;
    end;
    info.T_BREAK := expr -> expr;
    info.T_CONTINUE := expr -> expr;

    # Return statements (could also be folded into one)
    info.T_RETURN_VOID := function(expr)
        return expr;
    end;
    info.T_RETURN_OBJ := function(expr)
        return rec( type := "T_RETURN_OBJ"
                  , obj := compile(expr.obj) );
    end;

    info.T_ASS_LVAR := function(expr)
        return rec( type := expr.type
                  , lvar := expr.lvar
                  , rhs := compile(expr.rhs));
    end;
    info.T_UNB_LVAR := function(expr) end;

    info.T_ASS_HVAR := function(expr) end;
    info.T_UNB_HVAR := function(expr) end;

    info.T_ASS_GVAR := function(expr) end;
    info.T_UNB_GVAR := function(expr) end;

    info.T_ASS_LIST := function(expr) end;
    info.T_ASSS_LIST := function(expr) end;

    info.T_ASS_LIST_LEV := function(expr) end;
    info.T_ASSS_LIST_LEV := function(expr) end;

    info.T_UNB_LIST := function(expr) end;

    info.T_ASS_REC_NAME := function(expr) end;
    info.T_ASS_REC_EXPR := function(expr) end;

    info.T_UNB_REC_NAME := function(expr) end;
    info.T_UNB_REC_EXPR := function(expr) end;

    info.T_ASS_POSOBJ := function(expr) end;
    info.T_ASSS_POSOBJ := function(expr) end;

    info.T_ASS_POSOBJ_LEV := function(expr) end;
    info.T_ASSS_POSOBJ_LEV := function(expr) end;

    info.T_UNB_POSOBJ := function(expr) end;

    info.T_ASS_COMOBJ_NAME := function(expr) end;
    info.T_ASS_COMOBJ_EXPR := function(expr) end;

    info.T_UNB_COMOBJ_NAME := function(expr) end;
    info.T_UNB_COMOBJ_EXPR := function(expr) end;

    # Info evaluates arguments lazily
    info.T_INFO := function(expr) end;

    info.T_ASSERT_2ARGS := function(expr) end;
    info.T_ASSERT_3ARGS := function(expr) end;

    info.T_EMPTY := function(expr) end;

    # Options
    info.T_PROCCALL_OPTS := function(expr) end;

    # HPC-GAP's atomic statement (what about readwrite/readonly?)
    info.T_ATOMIC := function(expr) end;

    # A function expression
    info.T_FUNC_EXPR := function(expr)
        return rec( type := "T_FUNC_EXPR"
                  , argnams := expr.argnams
                  , narg := expr.narg
                  , locnams := expr.locnams
                  , nloc := expr.nloc
                  , stats := compile(expr.stats) );
    end;

    compile_record := function(expr)
        local n, res;
        res := rec( type := expr.type );
        # if we were allowed to change expr, or copy it
        # we could just Unbind, but the tree could be huge
        for n in RecNames(expr) do
            if n <> "type" then
                res.(n) := compile(expr.(n));
            fi;
        od;
        return res;
    end;

    binary_op := compile_record;
    unary_op := compile_record;

    info.T_OR := compile_record;
    info.T_AND := compile_record;
    info.T_NOT := compile_record;
    info.T_EQ := compile_record;
    info.T_NE := compile_record;
    info.T_LT := compile_record;
    info.T_GE := compile_record;
    info.T_GT := compile_record;
    info.T_LE := compile_record;
    info.T_IN := compile_record;
    info.T_SUM := compile_record;
    info.T_AINV := compile_record;
    info.T_DIFF := compile_record;
    info.T_PROD := compile_record;
    info.T_INV := compile_record;
    info.T_QUO := compile_record;
    info.T_MOD := compile_record;
    info.T_POW := compile_record;

    # These come from literals
    # TODO: Maybe make the component names uniform
    info.T_TRUE_EXPR := expr -> expr;
    info.T_FALSE_EXPR := expr -> expr;
    info.T_INTEXPR := expr -> expr;
    info.T_INT_EXPR := expr -> expr;
    info.T_CHAR_EXPR := expr -> expr;
    info.T_STRING_EXPR := expr -> expr;

    # TODO: Understand the Float parsing code.
    info.T_FLOAT_EXPR_EAGER := expr -> expr;
    info.T_FLOAT_EXPR_LAZY := expr -> expr;

    # Composite data types
    #
    # Even though they look like literals mostly,
    # permutations behave more like lists, because they
    # can contain arbitrary expressions
    info.T_PERM_EXPR := function(expr)
        return rec( type := expr.type
                  , cycles := List( expr.cycles
                                  , cyc -> List(cyc, compile) ) );
    end;

    info.T_PERM_CYCLE := function(expr)
        Error("encountered T_PERM_CYCLE");
    end;

    info.T_LIST_EXPR := function(expr)
        return rec( type := expr.type
                  , list := List(expr.list, compile));
    end;

    info.T_LIST_TILD_EXPR := function(expr)
    end;

    info.T_RANGE_EXPR := function(expr)
        return expr;
    end;

    info.T_REC_EXPR := function(expr)
        local kvcomp;
        kvcomp := function(r)
            local res;
            res := rec();
            if IsString(r.key) then
                res.key := r.key;
            else
                res.key := compile(r.key);
            fi;
            res.value := compile(r.value);
            return res;
        end;

        return rec( type := expr.type
                  , keyvalue := List(expr.keyvalue, kvcomp) );
    end;

    info.T_REC_TILD_EXPR := function(expr) end;

    # Different variable references, and the
    # appropriate IsBound constructs
    info.T_REFLVAR := expr -> expr;
    info.T_ISB_LVAR := expr -> expr;
    info.T_REF_HVAR := expr -> expr;
    info.T_ISB_HVAR := expr -> expr;
    info.T_REF_GVAR := expr -> expr;
    info.T_ISB_GVAR := expr -> expr;

    info.T_ELM_LIST := compile_record;
    info.T_ELMS_LIST := compile_record;
    info.T_ELM_LIST_LEV := compile_record;
    info.T_ELMS_LIST_LEV := compile_record;
    info.T_ISB_LIST := compile_record;
    info.T_ELM_REC_NAME := compile_record;
    info.T_ELM_REC_EXPR := compile_record;
    info.T_ISB_REC_NAME := compile_record;
    info.T_ISB_REC_EXPR := compile_record;
    info.T_ELM_POSOBJ := compile_record;
    info.T_ELMS_POSOBJ := compile_record;
    info.T_ELM_POSOBJ_LEV := compile_record;
    info.T_ELMS_POSOBJ_LEV := compile_record;
    info.T_ISB_POSOBJ := compile_record;
    info.T_ELM_COMOBJ_NAME := compile_record;
    info.T_ELM_COMOBJ_EXPR := compile_record;
    info.T_ISB_COMOBJ_NAME := compile_record;
    info.T_ISB_COMOBJ_EXPR := compile_record;
    info.T_FUNCCALL_OPTS := compile_record;
    info.T_ELM2_LIST := compile_record;
    info.T_ELMX_LIST := compile_record;
    info.T_ASS2_LIST := compile_record;
    info.T_ASSX_LIST := compile_record;

    compile := function(tree_)
        return info.(tree_.type)(tree_);
    end;

    return compile(tree);
end;

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
        Print("if fi;");
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

    info.T_BREAK := function(expr) end;
    info.T_CONTINUE := function(expr) end;

    # Return statements (could also be folded into one)
    info.T_RETURN_VOID := function(expr)
        Print("return");
    end;
    info.T_RETURN_OBJ := function(expr)
        Print("return ");
        compile(expr.obj);
        Print("\n");
    end;

    info.T_ASS_LVAR := function(expr) end;
    info.T_UNB_LVAR := function(expr) end;

    info.T_ASS_HVAR := function(expr) end;
    info.T_UNB_HVAR := function(expr) end;

    info.T_ASS_GVAR := function(expr) end;
    info.T_UNB_GVAR := function(expr) end;

    info.T_ASS_LIST := function(expr) end;
    info.T_ASSS_LIST := function(expr) end;

    info.T_ASS_LIST_LEV := function(expr) end;
    info.T_ASSS_LIST_LEV := function(expr) end;

    info.T_UNB_LIST := function(expr) end;

    info.T_ASS_REC_NAME := function(expr) end;
    info.T_ASS_REC_EXPR := function(expr) end;

    info.T_UNB_REC_NAME := function(expr) end;
    info.T_UNB_REC_EXPR := function(expr) end;

    info.T_ASS_POSOBJ := function(expr) end;
    info.T_ASSS_POSOBJ := function(expr) end;

    info.T_ASS_POSOBJ_LEV := function(expr) end;
    info.T_ASSS_POSOBJ_LEV := function(expr) end;

    info.T_UNB_POSOBJ := function(expr) end;

    info.T_ASS_COMOBJ_NAME := function(expr) end;
    info.T_ASS_COMOBJ_EXPR := function(expr) end;

    info.T_UNB_COMOBJ_NAME := function(expr) end;
    info.T_UNB_COMOBJ_EXPR := function(expr) end;

    # Info evaluates arguments lazily
    info.T_INFO := function(expr) end;

    info.T_ASSERT_2ARGS := function(expr) end;
    info.T_ASSERT_3ARGS := function(expr) end;

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

    info.T_OR := function(expr) end;
    info.T_AND := function(expr) end;
    info.T_NOT := function(expr) end;
    info.T_EQ := function(expr) end;
    info.T_NE := function(expr) end;
    info.T_LT := function(expr) end;
    info.T_GE := function(expr) end;
    info.T_GT := function(expr) end;
    info.T_LE := function(expr) end;
    info.T_IN := function(expr) end;
    info.T_SUM := function(expr) end;
    info.T_AINV := function(expr) end;
    info.T_DIFF := function(expr) end;
    info.T_PROD := function(expr) end;
    info.T_INV := function(expr) end;
    info.T_QUO := function(expr) end;
    info.T_MOD := function(expr) end;
    info.T_POW := function(expr) end;


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
    info.T_PERM_CYCLE := function(expr) end;
    info.T_LIST_EXPR := function(expr) end;
    info.T_LIST_TILD_EXPR := function(expr) end;
    info.T_RANGE_EXPR := function(expr) end;
    info.T_REC_EXPR := function(expr) end;
    info.T_REC_TILD_EXPR := function(expr) end;

    # Different variable references, and the
    # appropriate IsBound constructs
    info.T_REFLVAR := function(expr) end;
    info.T_ISB_LVAR := function(expr) end;
    info.T_REF_HVAR := function(expr) end;
    info.T_ISB_HVAR := function(expr) end;
    info.T_REF_GVAR := function(expr) end;
    info.T_ISB_GVAR := function(expr) end;

    info.T_ELM_LIST := function(expr) end;
    info.T_ELMS_LIST := function(expr) end;
    info.T_ELM_LIST_LEV := function(expr) end;
    info.T_ELMS_LIST_LEV := function(expr) end;
    info.T_ISB_LIST := function(expr) end;
    info.T_ELM_REC_NAME := function(expr) end;
    info.T_ELM_REC_EXPR := function(expr) end;
    info.T_ISB_REC_NAME := function(expr) end;
    info.T_ISB_REC_EXPR := function(expr) end;
    info.T_ELM_POSOBJ := function(expr) end;
    info.T_ELMS_POSOBJ := function(expr) end;
    info.T_ELM_POSOBJ_LEV := function(expr) end;
    info.T_ELMS_POSOBJ_LEV := function(expr) end;
    info.T_ISB_POSOBJ := function(expr) end;
    info.T_ELM_COMOBJ_NAME := function(expr) end;
    info.T_ELM_COMOBJ_EXPR := function(expr) end;
    info.T_ISB_COMOBJ_NAME := function(expr) end;
    info.T_ISB_COMOBJ_EXPR := function(expr) end;
    info.T_FUNCCALL_OPTS := function(expr) end;
    info.T_ELM2_LIST := function(expr) end;
    info.T_ELMX_LIST := function(expr) end;
    info.T_ASS2_LIST := function(expr) end;
    info.T_ASSX_LIST := function(expr) end;

    compile := function(tree_)
        info.(tree_.type)(tree_);
    end;

    compile(tree);
end;


CompileAllFunctions := function()
    local n, f;
    
    for n in NamesGVars() do
        Print("Inspecting ", n, ": ");
        if IsBoundGlobal(n) then
            f := ValueGlobal(n);
            if IsFunction(f) and (not IsOperation(f)) then
                Print(f);
            fi;
            Print("\n");
        else
            Print("No value bound to: ", n, "\n");
        fi;
    od;
end;
    
