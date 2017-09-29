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

# Unifies the different proccall, funccall, seq stat, while, for, repeat
InstallGlobalFunction(PrettyPrintCompiler,
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

