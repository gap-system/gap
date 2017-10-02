# syntaxtree.gi

#
InstallGlobalFunction( SyntaxTree,
function(f)
    # TODO: Maybe move this to the kernel function
    if IsOperation(f) or IsKernelFunction(f) then
        Error("f has to be a GAP function (not an operation or a kernel function)");
    fi;

    return Objectify( SyntaxTreeType, rec( tree := SYNTAX_TREE(f) ) );
end);

InstallMethod( ViewString, "for a syntax tree"
               , [ IsSyntaxTree ]
               , t -> "<syntax tree>" );

InstallMethod( ViewString, "for a compiler"
               , [ IsGAPCompiler ]
               , t -> Concatenation("<compiler: ", t!.name, ">") );

InstallMethod( CallFuncList, "for a compiler and syntax tree"
               , [ IsGAPCompiler, IsList ]
               , { c, t } -> c!.compiler.compile(t[1]!.tree) );


# Unifies the different proccall, funccall, seq stat, while, for, repeat
InstallGlobalFunction(CleanupCompiler,
function()
    local compiler,
          compile,
          compile_record,
          unsupported;

    # Basic setup of compiler
    compiler := rec();
    compiler.compile := tree -> Objectify( SyntaxTreeType,
                                           rec( tree := compiler.(tree.type)(tree) ) );

    # Helper functions
    compile_record := function(expr)
        local n, res;
        res := rec( type := expr.type );
        # if we were allowed to change expr, or copy it
        # we could just Unbind, but the tree could be huge
        for n in RecNames(expr) do
            if n <> "type" then
                res.(n) := compiler.compile(expr.(n));
            fi;
        od;
        return res;
    end;

    unsupported := function(expr)
        Error("Expressions of type ", expr.type,
              " are not supported by this compiler");
    end;

    compiler.T_PROCCALL_XARGS := function(expr)
        return rec( type := "T_PROCCALL"
                  , funcref := compiler.compile(expr.funcref)
                  , args := List(expr.args, compile) );
    end;
    compiler.T_FUNCCALL_XARGS := function(expr)
        return rec( type := "T_FUNCCALL"
                  , funcref := compiler.compile(expr.funcref)
                  , args := List(expr.args, compile) );
    end;
    # There is no difference between a proccall and a funccall other than
    # a funccall being an expression (it yields a value) and a proccall
    # being a statement (if the call results in a value its ignored)
    # Also all argument counts at this level are handled uniformly
    # so it is enough to implement one function for this
    compiler.T_FUNCCALL_0ARGS := compiler.T_PROCCALL_XARGS;
    compiler.T_PROCCALL_1ARGS := compiler.T_PROCCALL_XARGS;
    compiler.T_PROCCALL_2ARGS := compiler.T_PROCCALL_XARGS;
    compiler.T_PROCCALL_3ARGS := compiler.T_PROCCALL_XARGS;
    compiler.T_PROCCALL_4ARGS := compiler.T_PROCCALL_XARGS;
    compiler.T_PROCCALL_5ARGS := compiler.T_PROCCALL_XARGS;
    compiler.T_PROCCALL_6ARGS := compiler.T_PROCCALL_XARGS;

    compiler.T_FUNCCALL_0ARGS := compiler.T_FUNCCALL_XARGS;
    compiler.T_FUNCCALL_1ARGS := compiler.T_FUNCCALL_XARGS;
    compiler.T_FUNCCALL_2ARGS := compiler.T_FUNCCALL_XARGS;
    compiler.T_FUNCCALL_3ARGS := compiler.T_FUNCCALL_XARGS;
    compiler.T_FUNCCALL_4ARGS := compiler.T_FUNCCALL_XARGS;
    compiler.T_FUNCCALL_5ARGS := compiler.T_FUNCCALL_XARGS;
    compiler.T_FUNCCALL_6ARGS := compiler.T_FUNCCALL_XARGS;
    compiler.T_FUNCCALL_XARGS := compiler.T_FUNCCALL_XARGS;

    # Sequence of statements
    # This might be too complicated: it makes sure that
    # a nested T_SEQ_STAT is flattened to a single
    # sequence, but GAP's coder probably only
    # nests at depth 1. 
    compiler.T_SEQ_STAT := function(expr)
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
                Add(seqstat, compiler.compile(seq[pos]));
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
    compiler.T_SEQ_STAT2 := compiler.T_SEQ_STAT;
    compiler.T_SEQ_STAT3 := compiler.T_SEQ_STAT;
    compiler.T_SEQ_STAT4 := compiler.T_SEQ_STAT;
    compiler.T_SEQ_STAT5 := compiler.T_SEQ_STAT;
    compiler.T_SEQ_STAT6 := compiler.T_SEQ_STAT;
    compiler.T_SEQ_STAT7 := compiler.T_SEQ_STAT;

    # If statements are also handled uniformly in the
    # SYNTAX_TREE module
    compiler.T_IF := function(expr)
        local compile_branch;
        compile_branch := function(branch)
            return rec( condition := compiler.compile(branch.condition) 
                      , body := compiler.compile(branch.body) );
        end;
        return rec( type := "T_IF"
                  , branches := List(expr.branches, compile_branch) );
    end;
    compiler.T_IF_ELSE := compiler.T_IF;
    compiler.T_IF_ELIF := compiler.T_IF;
    compiler.T_IF_ELIF_ELSE := compiler.T_IF;

    compiler.T_FOR := function(expr) 
        local res;
        res := rec( type := "T_FOR"
                  , variable := expr.variable
                  , collection := compiler.compile(expr.collection)
                  , body := List(expr.body, compile) );
        if res.body[1].type <> "T_SEQ_STAT" then
            res.body := rec( type := "T_SEQ_STAT"
                           , statements := res.body );
        fi;
        return res;
    end;
    compiler.T_FOR2 := compiler.T_FOR;
    compiler.T_FOR3 := compiler.T_FOR;

    compiler.T_FOR_RANGE := compiler.T_FOR;
    compiler.T_FOR_RANGE2 := compiler.T_FOR;
    compiler.T_FOR_RANGE3 := compiler.T_FOR;

    compiler.T_WHILE := function(expr)
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
    compiler.T_WHILE2 := function(expr) end;
    compiler.T_WHILE3 := function(expr) end;

    compiler.T_REPEAT := function(expr)
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
    compiler.T_BREAK := expr -> expr;
    compiler.T_CONTINUE := expr -> expr;

    # Return statements (could also be folded into one)
    compiler.T_RETURN_VOID := function(expr)
        return expr;
    end;
    compiler.T_RETURN_OBJ := function(expr)
        return rec( type := "T_RETURN_OBJ"
                  , obj := compiler.compile(expr.obj) );
    end;

    compiler.T_ASS_LVAR := function(expr)
        return rec( type := expr.type
                  , lvar := expr.lvar
                  , rhs := compiler.compile(expr.rhs));
    end;
    compiler.T_UNB_LVAR := expr -> expr;

    compiler.T_ASS_HVAR := function(expr)
        return rec( type := expr.type
                  , hvar := expr.hvar
                  , rhs := compiler.compile(expr.rhs) );
    end;
    compiler.T_UNB_HVAR := expr -> expr;

    compiler.T_ASS_GVAR := function(expr)
        return rec( type := expr.type
                  , gvar := expr.gvar
                  , rhs := compiler.compile(expr.rhs));
    end;
    compiler.T_UNB_GVAR := expr -> expr;

    compiler.T_ASS_LIST := compile_record;
    compiler.T_ASSS_LIST := compile_record;

    compiler.T_ASS_LIST_LEV := compile_record;
    compiler.T_ASSS_LIST_LEV := compile_record;

    compiler.T_UNB_LIST := compile_record;

    compiler.T_ASS_REC_NAME := function(expr)
        return rec( type := expr.type
                  , rnam := expr.rnam
                  , rhs := compiler.compile(expr.rhs) );
    end;
    compiler.T_ASS_REC_EXPR := compile_record;

    compiler.T_UNB_REC_NAME := expr -> expr;
    compiler.T_UNB_REC_EXPR := compile_record;

    compiler.T_ASS_POSOBJ := compile_record;
    compiler.T_ASSS_POSOBJ := compile_record;
    compiler.T_ASS_POSOBJ_LEV := compile_record;
    compiler.T_ASSS_POSOBJ_LEV := compile_record;
    compiler.T_UNB_POSOBJ := compile_record;

    compiler.T_ASS_COMOBJ_NAME := function(expr)
        return rec( type := expr.type
                  , rnam := expr.rnam
                  , rhs := compiler.compile(expr.rhs) );
    end;
    compiler.T_ASS_COMOBJ_EXPR := compile_record;
    compiler.T_UNB_COMOBJ_NAME := expr -> expr;
    compiler.T_UNB_COMOBJ_EXPR := compile_record;

    # Compiler.evaluates arguments lazily
    compiler.T_INFO := unsupported;

    compiler.T_ASSERT_2ARGS := unsupported;
    compiler.T_ASSERT_3ARGS := unsupported;

    compiler.T_EMPTY := expr -> expr;

    # Options
    compiler.T_PROCCALL_OPTS := unsupported;

    # HPC-GAP's atomic statement (what about readwrite/readonly?)
    compiler.T_ATOMIC := unsupported;

    # A function expression
    compiler.T_FUNC_EXPR := function(expr)
        return rec( type := "T_FUNC_EXPR"
                  , argnams := expr.argnams
                  , narg := expr.narg
                  , locnams := expr.locnams
                  , nloc := expr.nloc
                  , stats := compiler.compile(expr.stats) );
    end;

    compiler.T_OR := compile_record;
    compiler.T_AND := compile_record;
    compiler.T_NOT := compile_record;
    compiler.T_EQ := compile_record;
    compiler.T_NE := compile_record;
    compiler.T_LT := compile_record;
    compiler.T_GE := compile_record;
    compiler.T_GT := compile_record;
    compiler.T_LE := compile_record;
    compiler.T_IN := compile_record;
    compiler.T_SUM := compile_record;
    compiler.T_AINV := compile_record;
    compiler.T_DIFF := compile_record;
    compiler.T_PROD := compile_record;
    compiler.T_INV := compile_record;
    compiler.T_QUO := compile_record;
    compiler.T_MOD := compile_record;
    compiler.T_POW := compile_record;

    # These come from literals
    # TODO: Maybe make the component names uniform
    compiler.T_TRUE_EXPR := expr -> expr;
    compiler.T_FALSE_EXPR := expr -> expr;
    compiler.T_INTEXPR := expr -> expr;
    compiler.T_INT_EXPR := expr -> expr;
    compiler.T_CHAR_EXPR := expr -> expr;
    compiler.T_STRING_EXPR := expr -> expr;

    # TODO: Understand the Float parsing code.
    compiler.T_FLOAT_EXPR_EAGER := expr -> expr;
    compiler.T_FLOAT_EXPR_LAZY := expr -> expr;

    # Composite data types
    #
    # Even though they look like literals mostly,
    # permutations behave more like lists, because they
    # can contain arbitrary expressions
    compiler.T_PERM_EXPR := function(expr)
        return rec( type := expr.type
                  , cycles := List( expr.cycles
                                  , cyc -> List(cyc, compile) ) );
    end;

    compiler.T_PERM_CYCLE := function(expr)
        Error("encountered T_PERM_CYCLE");
    end;

    compiler.T_LIST_EXPR := function(expr)
        return rec( type := expr.type
                  , list := List(expr.list, compile));
    end;

    compiler.T_LIST_TILD_EXPR := function(expr)
    end;

    compiler.T_RANGE_EXPR := function(expr)
        return expr;
    end;

    compiler.T_REC_EXPR := function(expr)
        local kvcomp;
        kvcomp := function(r)
            local res;
            res := rec();
            if IsString(r.key) then
                res.key := r.key;
            else
                res.key := compiler.compile(r.key);
            fi;
            res.value := compiler.compile(r.value);
            return res;
        end;

        return rec( type := expr.type
                  , keyvalue := List(expr.keyvalue, kvcomp) );
    end;

    compiler.T_REC_TILD_EXPR := function(expr) end;

    # Different variable references, and the
    # appropriate IsBound constructs
    compiler.T_REFLVAR := expr -> expr;
    compiler.T_ISB_LVAR := expr -> expr;
    compiler.T_REF_HVAR := expr -> expr;
    compiler.T_ISB_HVAR := expr -> expr;
    compiler.T_REF_GVAR := expr -> expr;
    compiler.T_ISB_GVAR := expr -> expr;

    compiler.T_ELM_LIST := compile_record;
    compiler.T_ELMS_LIST := compile_record;
    compiler.T_ELM_LIST_LEV := compile_record;
    compiler.T_ELMS_LIST_LEV := compile_record;
    compiler.T_ISB_LIST := compile_record;
    compiler.T_ELM_REC_NAME := compile_record;
    compiler.T_ELM_REC_EXPR := compile_record;
    compiler.T_ISB_REC_NAME := compile_record;
    compiler.T_ISB_REC_EXPR := compile_record;
    compiler.T_ELM_POSOBJ := compile_record;
    compiler.T_ELMS_POSOBJ := compile_record;
    compiler.T_ELM_POSOBJ_LEV := compile_record;
    compiler.T_ELMS_POSOBJ_LEV := compile_record;
    compiler.T_ISB_POSOBJ := compile_record;
    compiler.T_ELM_COMOBJ_NAME := compile_record;
    compiler.T_ELM_COMOBJ_EXPR := compile_record;
    compiler.T_ISB_COMOBJ_NAME := compile_record;
    compiler.T_ISB_COMOBJ_EXPR := compile_record;
    compiler.T_FUNCCALL_OPTS := compile_record;
    compiler.T_ELM2_LIST := compile_record;
    compiler.T_ELMX_LIST := compile_record;
    compiler.T_ASS2_LIST := compile_record;
    compiler.T_ASSX_LIST := compile_record;

    return Objectify(GAPCompilerType, rec( name := "CleanupCompiler"
                                         , compiler := compiler) );
end);

# Pretty printer based on Wadler's Prettier Printer.
# It is hugely inefficient I guess, but fun.
# Also this only works on a "cleaned" syntax tree (probably flag this somehow)
InstallGlobalFunction(PrettyPrintCompiler,
function()
    local compiler,
          compile,
          compile_record,
          unsupported,

          DOC,
          Doc,

          pretty,
          best,
          layout,
          group,
          flatten,
          folddoc,
          addline,
          addspace,
          spread,
          stack,
          bracket,
          concat;

    # Basic setup of compiler
    compiler := rec();
    compiler.compile := tree -> pretty(80,
                                       group( DOC.CONCAT( DOC.CONCAT( DOC.CONCAT( DOC.TEXT("hello"), bracket("(", DOC.TEXT("world") ,")"))
                                                                    , DOC.LINE )
                                                                    , bracket( "begin"
                                                                           , DOC.CONCAT( DOC.CONCAT( DOC.LINE
                                                                                                   , DOC.TEXT("body") )
                                                                                       , DOC.LINE )
                                                                                       , "end" ) ) ) );

    # Maybe one can do this pretty printer
    # More generically (and prettier) maybe
    # using method selection and overloading + (or *), 'or'?
    DOC := rec( NIL := rec( type := "NIL" )
              , CONCAT := function(d1, d2) return rec( type := ":<>", d1 := d1, d2 := d2 ); end
              , NEST := function(i,x) return rec(type := "NEST", indent := i, doc := x ); end
              , TEXT := function(s) return rec(type := "TEXT", text := s); end
              , LINE := rec( type := "LINE" )
              , ALT  := function(d1, d2) return rec( type := ":<|>", d1 := d1, d2 := d2 ); end );

    Doc := rec( Nil := rec( type := "Nil" )
              , Text := function(s, d) return rec( type := "Text", text := s, doc := d ); end
              , Line := function(i, d) return rec( type := "Line", indent := i, doc := d ); end );


    group := function(doc)
        return rec( type := ":<|>"
                  , d1 := flatten(doc)
                  , d2 := doc );
    end;

    flatten := function(doc)
        if doc.type = "NIL" then
            return DOC.NIL;
        elif doc.type = ":<>" then
            return DOC.CONCAT(flatten(doc.d1), flatten(doc.d2));
        elif doc.type = "NEST" then
            return DOC.NEST(doc.indent, flatten(doc.doc));
        elif doc.type = "TEXT" then
            return DOC.TEXT(ShallowCopy(doc.text));
        elif doc.type = "LINE" then
            return DOC.TEXT(" ");
        elif doc.type = ":<|>" then
            return flatten(doc.d1);
        else
            Error("Unknown document type");
        fi;
    end;

    best := function(w, k, x)
        local be, better, fits;
        fits := function(w,x)
            if w < 0 then
                return false;
            elif x = Doc.Nil then
                return true;
            elif x.type = "Text" then
                return fits(w-Length(x.text), x.doc);
            elif x.type = "Line" then
                return true;
            else
                Error("");
            fi;
        end;
        better := function(w,k,x,y)
            if fits(w-k,x) then
                return x;
            else
                return y;
            fi;
        end;
        be := function(w, k, l)
            local indent, d1, d2, rem;

            rem := l{[2..Length(l)]};

            if l = [] then
                return Doc.Nil;
            elif l[1][2] = DOC.NIL then
                return be(w,k,rem);
            elif l[1][2].type = ":<>" then
                indent := l[1][1];
                d1 := l[1][2].d1;
                d2 := l[1][2].d2;
                return be(w,k,Concatenation([[indent, d1], [indent, d2]], rem));
            elif l[1][2].type = "NEST" then
                indent := l[1][1] + l[1][2].indent;
                return be(w,k,Concatenation([[indent, l[1][2].doc]], rem));
            elif l[1][2].type = "TEXT" then
                return Doc.Text(l[1][2].text, be(w,k+Length(l[1][2].text), rem));
            elif l[1][2].type = "LINE" then
                return Doc.Line(l[1][1], be(w, l[1][1], rem));
            elif l[1][2].type = ":<|>" then
                return better(w, k
                              , be(w, k, Concatenation( [ [ l[1][1], l[1][2].d1 ] ], rem) )
                              , be(w, k, Concatenation( [ [ l[1][1], l[1][2].d2 ] ], rem) ) );
            else
                Error("");
            fi;
        end;
        return be(w, k, [ [0,x] ]);
    end;

    layout := function(doc)
        if doc.type = "Nil" then
            return "";
        elif doc.type = "Text" then
            return Concatenation(doc.text, layout(doc.doc));
        elif doc.type = "Line" then
            return Concatenation("\n", ListWithIdenticalEntries(' ', doc.indent)
                                 , layout(doc.x));
        else
            Error("");
        fi;
    end;

    pretty := function(width, tree)
        return layout(best(width, 0, tree));
    end;

    folddoc := function(f, docs)
        local res, doc;
        if Length(docs) = 0 then
            return DOC.NIL;
        else
            res := docs[1];
            for doc in docs{[2..Length(docs)]} do
                res := f(res, doc);
            od;
        fi;
        return res;
    end;

    addspace := {x,y} -> DOC.CONCAT(x, DOC.CONCAT( DOC.TEXT(" "), y) );
    addline := {x,y} -> DOC.CONCAT(x, DOC.CONCAT( DOC.LINE, y) );
    spread := doc -> folddoc(addspace, doc);
    stack := doc -> folddoc(addline, doc);
    concat := docs -> folddoc(DOC.CONCAT, docs);

#    text := s -> DOC.TEXT(s);

    bracket := function(l, x, r)
        return group( DOC.CONCAT( DOC.TEXT(l),
                                  DOC.CONCAT( DOC.CONCAT( DOC.NEST(2, DOC.CONCAT(DOC.LINE, x)),
                                                          DOC.LINE ), DOC.TEXT(r) ) ) );
    end;

    compile_record := function(expr)
        local n, res;
        res := rec( type := expr.type );
        # if we were allowed to change expr, or copy it
        # we could just Unbind, but the tree could be huge
        for n in RecNames(expr) do
            if n <> "type" then
                res.(n) := compiler.compile(expr.(n));
            fi;
        od;
        return res;
    end;

    unsupported := function(expr)
        Error("Expressions of type ", expr.type,
              " are not supported by this compiler");
    end;

    compiler.T_PROCCALL_XARGS := function(expr)
        return rec( type := "T_PROCCALL"
                  , funcref := compiler.compile(expr.funcref)
                  , args := List(expr.args, compile) );
    end;
    compiler.T_FUNCCALL_XARGS := function(expr)
        return rec( type := "T_FUNCCALL"
                  , funcref := compiler.compile(expr.funcref)
                  , args := List(expr.args, compile) );
    end;

    # Sequence of statements
    # This might be too complicated: it makes sure that
    # a nested T_SEQ_STAT is flattened to a single
    # sequence, but GAP's coder probably only
    # nests at depth 1.
    compiler.T_SEQ_STAT := function(expr)
    end;

    # If statements are also handled uniformly in the
    # SYNTAX_TREE module
    compiler.T_IF := function(expr)
        local compile_branch;
        compile_branch := function(branch)
            return rec( condition := compiler.compile(branch.condition) 
                      , body := compiler.compile(branch.body) );
        end;
        return rec( type := "T_IF"
                  , branches := List(expr.branches, compile_branch) );
    end;

    compiler.T_FOR := function(expr) 
        return folddoc(DOC.CONCAT, 
                       [ DOC.TEXT("for"), DOC.TEXT(" ")
                         , String(expr.variable), DOC.TEXT(" ")
                         , DOC.TEXT("in"), DOC.TEXT(" ")
                         , compiler.compile(expr.collection)
                         , DOC.TEXT(" "), DOC.TEXT("do")
                         , folddoc(DOC.CONCAT(List(expr.body, compiler.compile)))
                         , DOC.TEXT("od"), DOC.TEXT(";") ] );
    end;

    compiler.T_WHILE := function(expr)
        return folddoc(DOC.CONCAT, [ DOC.TEXT("while"), DOC.TEXT(" ") ,
                       String(expr.condition), DOC.TEXT(" ") , DOC.TEXT("do"),
                       DOC.LINE, , folddoc(DOC.CONCAT(List(expr.body,
                       compiler.compile))) , DOC.TEXT("od"), DOC.TEXT(";") ] );

    end;

    compiler.T_REPEAT := function(expr)
        return folddoc(DOC.CONCAT, 
                       [ DOC.TEXT("repeat"), DOC.TEXT(" ")
                         , folddoc(DOC.CONCAT(List(expr.body, compiler.compile)))
                         , DOC.TEXT("until"), DOC.TEXT(";") ] );

    end;
    compiler.T_BREAK := expr -> DOC.TEXT("break");
    compiler.T_CONTINUE := expr -> DOC.TEXT("continue");

    # Return statements (could also be folded into one)
    compiler.T_RETURN_VOID := expr -> DOC.TEXT("return");
    compiler.T_RETURN_OBJ := expr -> DOC.CONCAT("return", bracket"(", compiler.compile(expr.obj), ")");

    compiler.T_ASS_LVAR := expr -> DOC.CONCAT(expr.lvar, " := ", compiler.compile(expr.rhs));
    compiler.T_UNB_LVAR := expr -> DOC.CONCAT(DOC.TEXT("Unbind"), bracket("(", expr.lvar, ")"));

    compiler.T_ASS_HVAR := expr -> DOC.CONCAT(expr.hvar, " := ", compiler.compile(expr.rhs));
    compiler.T_UNB_HVAR := expr -> DOC.CONCAT(DOC.TEXT("Unbind"), bracket("(", expr.hvar, ")"));

    compiler.T_ASS_GVAR := expr -> DOC.CONCAT(expr.gvar, " := ", compiler.compile(expr.rhs));
    compiler.T_UNB_HVAR := expr -> DOC.CONCAT(DOC.TEXT("Unbind"), bracket("(", expr.gvar, ")"));

    compiler.T_ASS_LIST := compile_record;
    compiler.T_ASSS_LIST := compile_record;

    compiler.T_ASS_LIST_LEV := compile_record;
    compiler.T_ASSS_LIST_LEV := compile_record;

    compiler.T_UNB_LIST := compile_record;

    compiler.T_ASS_REC_NAME := function(expr)
        return rec( type := expr.type
                  , rnam := expr.rnam
                  , rhs := compiler.compile(expr.rhs) );
    end;
    compiler.T_ASS_REC_EXPR := compile_record;

    compiler.T_UNB_REC_NAME := expr -> expr;
    compiler.T_UNB_REC_EXPR := compile_record;

    compiler.T_ASS_POSOBJ := compile_record;
    compiler.T_ASSS_POSOBJ := compile_record;
    compiler.T_ASS_POSOBJ_LEV := compile_record;
    compiler.T_ASSS_POSOBJ_LEV := compile_record;
    compiler.T_UNB_POSOBJ := compile_record;

    compiler.T_ASS_COMOBJ_NAME := function(expr)
        return rec( type := expr.type
                  , rnam := expr.rnam
                  , rhs := compiler.compile(expr.rhs) );
    end;
    compiler.T_ASS_COMOBJ_EXPR := compile_record;
    compiler.T_UNB_COMOBJ_NAME := expr -> expr;
    compiler.T_UNB_COMOBJ_EXPR := compile_record;

    # Compiler.evaluates arguments lazily
    compiler.T_INFO := unsupported;

    compiler.T_ASSERT_2ARGS := unsupported;
    compiler.T_ASSERT_3ARGS := unsupported;

    compiler.T_EMPTY := expr -> expr;

    # Options
    compiler.T_PROCCALL_OPTS := unsupported;

    # HPC-GAP's atomic statement (what about readwrite/readonly?)
    compiler.T_ATOMIC := unsupported;

    # A function expression
    compiler.T_FUNC_EXPR := function(expr)
        return rec( type := "T_FUNC_EXPR"
                  , argnams := expr.argnams
                  , narg := expr.narg
                  , locnams := expr.locnams
                  , nloc := expr.nloc
                  , stats := compiler.compile(expr.stats) );
    end;

    compiler.T_OR := compile_record;
    compiler.T_AND := compile_record;
    compiler.T_NOT := compile_record;
    compiler.T_EQ := compile_record;
    compiler.T_NE := compile_record;
    compiler.T_LT := compile_record;
    compiler.T_GE := compile_record;
    compiler.T_GT := compile_record;
    compiler.T_LE := compile_record;
    compiler.T_IN := compile_record;
    compiler.T_SUM := compile_record;
    compiler.T_AINV := compile_record;
    compiler.T_DIFF := compile_record;
    compiler.T_PROD := compile_record;
    compiler.T_INV := compile_record;
    compiler.T_QUO := compile_record;
    compiler.T_MOD := compile_record;
    compiler.T_POW := compile_record;

    # These come from literals
    # TODO: Maybe make the component names uniform
    compiler.T_TRUE_EXPR := expr -> DOC.TEXT("true");
    compiler.T_FALSE_EXPR := expr -> DOC.TEXT("false");
    compiler.T_INTEXPR := expr -> DOC.TEXT(String(expr.value));
    compiler.T_INT_EXPR := expr -> DOC.TEXT(String(expr.value));
    compiler.T_CHAR_EXPR := expr -> DOC.TEXT("''");
    compiler.T_STRING_EXPR := expr -> DOC.TEXT(".");

    # TODO: Understand the Float parsing code.
    compiler.T_FLOAT_EXPR_EAGER := expr -> expr;
    compiler.T_FLOAT_EXPR_LAZY := expr -> expr;

    # Composite data types
    #
    # Even though they look like literals mostly,
    # permutations behave more like lists, because they
    # can contain arbitrary expressions
    compiler.T_PERM_EXPR := function(expr)
        return rec( type := expr.type
                  , cycles := List( expr.cycles
                                  , cyc -> List(cyc, compile) ) );
    end;

    compiler.T_PERM_CYCLE := function(expr)
        Error("encountered T_PERM_CYCLE");
    end;

    compiler.T_LIST_EXPR := expr -> bracket("[", folddoc(DOC.CONCAT, List(expr.list, compile ), "]");

    compiler.T_LIST_TILD_EXPR := function(expr)
    end;

    compiler.T_RANGE_EXPR := function(expr)
        return expr;
    end;

    compiler.T_REC_EXPR := function(expr)
        local kvcomp;
        kvcomp := function(r)
            local res;
            res := rec();
            if IsString(r.key) then
                res.key := r.key;
            else
                res.key := compiler.compile(r.key);
            fi;
            res.value := compiler.compile(r.value);
            return res;
        end;

        return rec( type := expr.type
                  , keyvalue := List(expr.keyvalue, kvcomp) );
    end;

    compiler.T_REC_TILD_EXPR := function(expr) end;

    # Different variable references, and the
    # appropriate IsBound constructs
    compiler.T_REFLVAR := expr -> expr;
    compiler.T_ISB_LVAR := expr -> expr;
    compiler.T_REF_HVAR := expr -> expr;
    compiler.T_ISB_HVAR := expr -> expr;
    compiler.T_REF_GVAR := expr -> expr;
    compiler.T_ISB_GVAR := expr -> expr;

    compiler.T_ELM_LIST := compile_record;
    compiler.T_ELMS_LIST := compile_record;
    compiler.T_ELM_LIST_LEV := compile_record;
    compiler.T_ELMS_LIST_LEV := compile_record;
    compiler.T_ISB_LIST := compile_record;
    compiler.T_ELM_REC_NAME := compile_record;
    compiler.T_ELM_REC_EXPR := compile_record;
    compiler.T_ISB_REC_NAME := compile_record;
    compiler.T_ISB_REC_EXPR := compile_record;
    compiler.T_ELM_POSOBJ := compile_record;
    compiler.T_ELMS_POSOBJ := compile_record;
    compiler.T_ELM_POSOBJ_LEV := compile_record;
    compiler.T_ELMS_POSOBJ_LEV := compile_record;
    compiler.T_ISB_POSOBJ := compile_record;
    compiler.T_ELM_COMOBJ_NAME := compile_record;
    compiler.T_ELM_COMOBJ_EXPR := compile_record;
    compiler.T_ISB_COMOBJ_NAME := compile_record;
    compiler.T_ISB_COMOBJ_EXPR := compile_record;
    compiler.T_FUNCCALL_OPTS := compile_record;
    compiler.T_ELM2_LIST := compile_record;
    compiler.T_ELMX_LIST := compile_record;
    compiler.T_ASS2_LIST := compile_record;
    compiler.T_ASSX_LIST := compile_record;

    return Objectify(GAPCompilerType, rec( name := "PrettyPrintCompiler"
                                         , compiler := compiler) );
end);

