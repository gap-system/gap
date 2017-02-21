/****************************************************************************
**
*W  syntaxtree.c
**
*/
#include        <stdarg.h>              /* variable argument list macros   */
#include        "system.h"              /* Ints, UInts                     */


#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gvars.h"               /* global variables                */

#include        "ariths.h"              /* basic arithmetic                */
#include        "integer.h"

#include        "bool.h"                /* booleans                        */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "calls.h"               /* generic call mechanism          */

#include        "lists.h"               /* generic lists                   */

#include        "records.h"             /* generic records                 */
#include        "permutat.h"
#include        "precord.h"             /* plain records                   */

#include        "plist.h"               /* plain lists                     */

#include        "stringobj.h"              /* strings                         */

#include        "code.h"                /* coder                           */

#include        "exprs.h"               /* expressions                     */
#include        "stats.h"               /* statements                      */

#include        "compiler.h"            /* compiler                        */

#include        "hpc/tls.h"             /* thread-local storage            */

#include        "vars.h"                /* variables                       */
#include        "compiled.h"

#include <ctype.h>

typedef UInt4 LVar;
typedef UInt4 HVar;
typedef UInt GVar;

typedef Obj (*CompileFuncT)(Expr expr);

typedef struct {
  UInt tnum;
  CompileFuncT compile;
  const Char *name;
  UInt arity;
  const Char *argnames[6];
} CompilerT;

static const CompilerT StatCompilers[];
static const CompilerT ExprCompilers[];


#define COMPILER_ARITY(...) (sizeof((char *[]){ __VA_ARGS__ })/sizeof(char *))
#define COMPILER(tnum, compiler, ...)                                   \
    { tnum, compiler, #tnum, COMPILER_ARITY(__VA_ARGS__), { __VA_ARGS__ } }

static inline Obj NewSyntaxTreeNode(const char *type)
{
    Obj result;
    Obj typestr;

    C_NEW_STRING_DYN(typestr, type);
    result = NEW_PREC(1);
    AssPRec(result, RNamName("type"), typestr);

    return result;
}

static Obj SyntaxTreeCompiler(Expr expr)
{
    UInt tnum;
    CompilerT comp;

    tnum = TNUM_EXPR(expr);

    if((0 <= tnum) && (tnum < 128)) {
        comp = StatCompilers[tnum];
    } else if((128 <= tnum) && (tnum < 256)) {
        comp = ExprCompilers[tnum-128];
    } else {
        // error
    }

    return comp.compile(expr);
}

/* TODO: Make just one compiler table? */
/*       Can we get rid of the duplication between
         SyntaxTreeCompiler and SyntaxTreeDefaultCompiler? */
static Obj SyntaxTreeDefaultCompiler(Expr expr)
{
    Obj result;
    UInt tnum;
    CompilerT comp;

    tnum = TNUM_EXPR(expr);

    if((0 <= tnum) && (tnum < 128)) {
        comp = StatCompilers[tnum];
    } else if((128 <= tnum) && (tnum < 256)) {
        comp = ExprCompilers[tnum-128];
    } else {
        // error
    }
    result = NewSyntaxTreeNode(comp.name);
    for(int i=0; i<comp.arity; i++) {
        AssPRec(result, RNamName(comp.argnames[i]), SyntaxTreeCompiler(ADDR_EXPR(expr)[i]));
    }
    return result;
}

Obj SyntaxTreeFunccall(Expr expr)
{
    Obj result;
    Obj func;
    Obj args, argi;
    UInt narg, i;

    result = NewSyntaxTreeNode("Funccall");;
    /* TODO: If this is a gvar ref, put name? */
    func = SyntaxTreeCompiler( FUNC_CALL(expr) );

    /*
    if ( TNUM_EXPR( FUNC_CALL(expr) ) == T_REF_GVAR ) {
    } */
    AssPRec(result, RNamName("function"), func);

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_EXPR(expr));
    args = NEW_PLIST(T_PLIST, narg);
    SET_LEN_PLIST(args, narg);

    for ( i = 1; i <= narg; i++ ) {
        argi = SyntaxTreeCompiler( ARGI_CALL( expr, i ) );
        SET_ELM_PLIST(args, i, argi);
        CHANGED_BAG(args);
    }
    AssPRec(result, RNamName("args"), args);
    return result;
}

/* TODO: FuncCall options */
Obj SyntaxTreeFunccallOpts(Expr expr)
{
    Obj result;
    Obj opts;

    result = NewSyntaxTreeNode("FunccallOpts");;
    opts = SyntaxTreeCompiler(ADDR_STAT(expr)[0]);
    AssPRec(result, RNamName("opts"), opts);

    return result;
}

static Obj SyntaxTreeFunc(Obj func);

/* TODO: again? */
Obj SyntaxTreeFuncExpr(Expr expr)
{
    Obj result;
    Obj fexs;
    Obj fexp;
    Obj func;

    result = NewSyntaxTreeNode("FuncExpr");;

    fexs = FEXS_FUNC(CURR_FUNC);
    fexp = ELM_PLIST(fexs, ((Int *)ADDR_EXPR(expr))[0]);
    func = SyntaxTreeFunc(fexp);

    AssPRec(result, RNamName("func"), func);

    return result;
}

Obj SyntaxTreeIntExpr(Expr expr)
{
    Obj result;
    Obj value;
    Int siz;
    UInt typ;
    Int i;

    result = NewSyntaxTreeNode("IntExpr");;

    if(IS_INTEXPR(expr)) {
        value = OBJ_INTEXPR(expr);
    } else {
        siz = SIZE_EXPR(expr) - sizeof(UInt);
        typ = *(UInt *)ADDR_EXPR(expr);
        value = C_MAKE_INTEGER_BAG(siz, typ);
        for ( i = 0; i < siz/INTEGER_UNIT_SIZE; i++ ) {
#if INTEGER_UNIT_SIZE == 2
            C_SET_LIMB2(value, i, ((UInt2 *)((UInt *)ADDR_EXPR(expr) + 1))[i]);
#elif INTEGER_UNIT_SIZE == 4
            C_SET_LIMB4(value, i, ((UInt4 *)((UInt *)ADDR_EXPR(expr) + 1))[i]);
#elif INTEGER_UNIT_SIZE == 8
            C_SET_LIMB8(value, i, ((UInt8 *)((UInt *)ADDR_EXPR(expr) + 1))[i]);
#else
            #error unsupported INTEGER_UNIT_SIZE
#endif
        }
        if (siz <= 8) {
            value = C_NORMALIZE_64BIT(value);
        }
    }

    AssPRec(result, RNamName("value"), value);

    return result;
}

Obj SyntaxTreeCharExpr(Expr expr)
{
    Obj result;
    Obj value;

    /* TODO: How do I make a character literal? */
    result = NewSyntaxTreeNode("CharExpr");;
    value = INTOBJ_INT(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("result"), value);

    return result;
}

Obj SyntaxTreePermExpr(Expr expr)
{
    Obj result;
    Obj cycles;
    Obj cycle;
    Obj val;
    Expr cycleexpr;
    Int csize, n;
    Int i, j;

    result = NewSyntaxTreeNode("PermExpr");;

    /* determine number of cycles */
    n = SIZE_EXPR(expr)/sizeof(Expr);
    cycles = NEW_PLIST( T_PLIST, n );
    AssPRec(result, RNamName("cycles"), cycles);
    SET_LEN_PLIST(cycles, n);

    /* enter cycles */
    for(i=1;i <= n;i++) {
        cycleexpr = ADDR_EXPR(expr)[i-1];
        csize = SIZE_EXPR(cycleexpr)/sizeof(Expr);
        cycle = NEW_PLIST(T_PLIST, csize);
        SET_LEN_PLIST(cycle, csize);
        SET_ELM_PLIST(cycles, i, cycle);
        CHANGED_BAG(cycles);

        /* entries of the cycle */
        for (j=1; j<=csize; j++) {
            val = SyntaxTreeCompiler(ADDR_EXPR(cycleexpr)[j-1]);
            SET_ELM_PLIST(cycle, j, val);
            CHANGED_BAG(cycle);
        }
    }
    return result;
}

/* TODO: Find out why record and list subexpressions are handled
   special */
Obj SyntaxTreeListExpr (Expr expr)
{
    Obj result;
    Obj list;
    Int len;
    Int i;

    result = NewSyntaxTreeNode("ListExpr");;
    len = SIZE_EXPR( expr ) / sizeof(Expr);

    list = NEW_PLIST(T_PLIST, len);
    SET_LEN_PLIST(list, len);

    for(i=1;i<=len;i++) {
        if(ADDR_EXPR(expr)[i-1] == 0) {
            continue;
        } else {
            SET_ELM_PLIST(list, i, SyntaxTreeCompiler(ADDR_EXPR(expr)[i-1]));
            CHANGED_BAG(list);
        }
    }

    AssPRec(result, RNamName("list"), list);

    return result;
}

/* TODO: Deal With tilde */
Obj SyntaxTreeListTildeExpr(Expr expr)
{
    Obj result;

    result = SyntaxTreeListExpr(expr);

    return result;
}

Obj SyntaxTreeRangeExpr(Expr expr)
{
    Obj result, first, second, last;

    result = NewSyntaxTreeNode("RangeExpr");;

    if ( SIZE_EXPR(expr) == 2 * sizeof(Expr) ) {
        first  = SyntaxTreeCompiler( ADDR_EXPR(expr)[0] );
        last   = SyntaxTreeCompiler( ADDR_EXPR(expr)[1] );

        AssPRec(result, RNamName("first"), first);
        AssPRec(result, RNamName("last"), last);
    } else {
        first  = SyntaxTreeCompiler( ADDR_EXPR(expr)[0] );
        second = SyntaxTreeCompiler( ADDR_EXPR(expr)[1] );
        last   = SyntaxTreeCompiler( ADDR_EXPR(expr)[2] );

        AssPRec(result, RNamName("first"), first);
        AssPRec(result, RNamName("second"), second);
        AssPRec(result, RNamName("last"), last);
    }

    return result;
}

Obj SyntaxTreeStringExpr(Expr expr)
{
    Obj result, string;

    result = NewSyntaxTreeNode("StringExpr");;

    C_NEW_STRING( string, SIZE_EXPR(expr)-1-sizeof(UInt),
                  sizeof(UInt) + (Char*)ADDR_EXPR(expr) );


    AssPRec( result, RNamName("string"), string );

    return result;
}

Obj SyntaxTreeRecExpr(Expr expr)
{
    Obj result;
    Obj key;
    Obj val;
    Obj list;
    Obj subrec;
    Expr tmp;
    Int i, len;

    result = NewSyntaxTreeNode("RecExpr");;

    len = SIZE_EXPR(expr) / (2*sizeof(Expr));
    list = NEW_PLIST(T_PLIST, len);
    SET_LEN_PLIST(list, len);

    for ( i = 1; i <= len; i++ ) {
        // Check whether this can happen and *why*
        tmp = ADDR_EXPR(expr)[2*i-2];
        if(tmp == 0 ) {
            continue;
        } else {
            subrec = NEW_PREC(2);
            SET_ELM_PLIST(list, i, subrec);
            CHANGED_BAG(list);

            if(IS_INTEXPR(tmp)) {
                key = NAME_OBJ_RNAM((UInt)INT_INTEXPR(tmp));
            } else {
                key = SyntaxTreeCompiler(tmp);
            }
            AssPRec(subrec, RNamName("key"), key);

            tmp = ADDR_EXPR(expr)[2*i-1];
            val = SyntaxTreeCompiler(tmp);
            AssPRec(subrec, RNamName("value"), val);
        }
    }
    AssPRec(result, RNamName("keyvalue"), list);

    return result;
}

/* A tilde just refers to the structure it is used in */
/* But this seems to be an expression that *contains* a tilde? */
Obj SyntaxTreeRecTildeExpr(Expr expr)
{
    Obj result;

    result = SyntaxTreeRecExpr(expr);

    return result;
}

Obj SyntaxTreeRefLVar(Expr expr)
{
    Obj result;
    LVar lvar;

    result = NewSyntaxTreeNode("RefLVar");;

    if ( IS_REFLVAR(expr) ) {
        lvar = LVAR_REFLVAR(expr);
    } else {
        lvar = -1;
//        lvar = (LVar)(ADDR_EXPR(expr)[0]);
    }

    /* TODO: Local variable references */
    AssPRec(result, RNamName("variable"), INTOBJ_INT(lvar));

    return result;
}

Obj SyntaxTreeIsbLVar(Expr expr)
{
    Obj result;
    LVar lvar;

    result = NewSyntaxTreeNode("IsBLvar");;

    lvar = (LVar)(ADDR_EXPR(expr)[0]);

    AssPRec(result, RNamName("variable"), INTOBJ_INT(lvar));

    return result;
}

Obj SyntaxTreeRefHVar(Expr expr)
{
    Obj result;
    HVar hvar;

    /*
     * TODO: Deal with higher variables? This is not necessary for a
     * syntax tree!
     */
    result = NewSyntaxTreeNode("RefHVar");;
    hvar = (HVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("variable"), INTOBJ_INT(hvar));

    return result;
}

Obj SyntaxTreeIsbHVar(Expr expr)
{
    Obj result;
    HVar hvar;

    result = NewSyntaxTreeNode("IsBHVar");;
    hvar = (HVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("variable"), INTOBJ_INT(hvar));

    return result;
}

Obj SyntaxTreeRefGVar(Expr expr)
{
    Obj result;
    GVar gvar;

    result = NewSyntaxTreeNode("RefGVar");;
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("name"), NameGVarObj(gvar));

    return result;
}

Obj SyntaxTreeRefGVarFopy(Expr expr)
{
    Obj result;
    GVar gvar;

    result = NewSyntaxTreeNode("RefGVarFopy");;
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("name"), NameGVarObj(gvar));

    return result;
}

Obj SyntaxTreeIsbGVar(Expr expr)
{
    Obj result;
    GVar gvar;

    result = NewSyntaxTreeNode("IsBGVar");;
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("name"), NameGVarObj(gvar));

    return result;
}

/* TODO: Options? */
Obj SyntaxTreeProccall(Stat stat)
{
    Obj result;
    Obj args;
    Obj func;
    UInt narg;
    UInt i;

    result = NewSyntaxTreeNode("Proccall");;

    /* TODO: What to do about this? */
    /* compile the reference to the function                               */
    if ( TNUM_EXPR( FUNC_CALL(stat) ) == T_REF_GVAR ) {
        /* mhm */
        func = SyntaxTreeRefGVarFopy( FUNC_CALL(stat) );
    } else {
        func = SyntaxTreeCompiler( FUNC_CALL(stat) );
    }
    AssPRec(result, RNamName("function"), func);

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_STAT(stat));
    args = NEW_PLIST(T_PLIST, narg);
    SET_LEN_PLIST(args, narg);
    for ( i = 1; i <= narg; i++ ) {
        SET_ELM_PLIST(args, i, SyntaxTreeCompiler( ARGI_CALL(stat,i) ) );
    }
    AssPRec(result, RNamName("args"), args);
    return result;
}

Obj SyntaxTreeProccallOpts(Stat stat)
{
    Obj result;
    Obj opts;

    result = NewSyntaxTreeNode("ProccallOpts");;
    opts = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);

    AssPRec(result, RNamName("opts"), opts);

    return result;
}

Obj SyntaxTreeSeqStat(Stat stat)
{
    Obj result;
    Obj list;
    UInt nr;
    UInt i;

    result = NewSyntaxTreeNode("SeqStat");;

    /* get the number of statements                                        */
    nr = SIZE_STAT( stat ) / sizeof(Stat);
    list = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(list, nr);

    /* compile the statements                                              */
    for ( i = 1; i <= nr; i++ ) {
        SET_ELM_PLIST(list, i, SyntaxTreeCompiler( ADDR_STAT( stat )[i-1] ) );
        CHANGED_BAG(list);
    }
    AssPRec(result, RNamName("statements"), list);

    return result;
}

Obj SyntaxTreeIf(Stat stat)
{
    Obj result;

    Obj cond;
    Obj then;
    Obj pair;
    Obj branches;

    Int i, nr;

    result = NewSyntaxTreeNode("If");;

    nr = SIZE_STAT(stat) / (2*sizeof(Stat));
    branches = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(branches, nr);

    AssPRec(result, RNamName("branches"), branches);

    cond = SyntaxTreeCompiler( ADDR_STAT( stat )[0] );
    then = SyntaxTreeCompiler( ADDR_STAT( stat )[1] );

    for(i=0;i<nr;i++) {
        cond = SyntaxTreeCompiler( ADDR_STAT( stat )[2*i] );
        then = SyntaxTreeCompiler( ADDR_STAT( stat )[2*i+1] );

        pair = NEW_PREC(2);
        AssPRec(pair, RNamName("condition"), cond);
        AssPRec(pair, RNamName("then"), then);

        SET_ELM_PLIST(branches, i + 1, pair);
        CHANGED_BAG(branches);
    }
    return result;
}

Obj SyntaxTreeFor(Stat stat)
{
    Obj result;
    Obj body;
    UInt i, nr;

    result = NewSyntaxTreeNode("For");;

    AssPRec(result, RNamName("variable"), SyntaxTreeCompiler(ADDR_STAT(stat)[0]));
    AssPRec(result, RNamName("collection"), SyntaxTreeCompiler(ADDR_STAT(stat)[1]));

    nr = SIZE_STAT(stat)/sizeof(Stat);
    body = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for ( i = 2; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
        SET_ELM_PLIST(body, i - 1, SyntaxTreeCompiler( ADDR_STAT(stat)[i] ) );
    }

    return result;
}

Obj SyntaxTreeWhile(Stat stat )
{
    Obj result;
    Obj condition;
    Obj body;
    UInt nr, i;

    result = NewSyntaxTreeNode("While");;

    condition = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    AssPRec(result, RNamName("condition"), condition);

    nr = SIZE_STAT(stat)/sizeof(Stat);
    body = NEW_PLIST(T_PLIST, nr - 1);
    SET_LEN_PLIST(body, nr - 1);
    AssPRec(result, RNamName("body"), body);

    for ( i = 1; i < nr; i++ ) {
        SET_ELM_PLIST(body, i, SyntaxTreeCompiler( ADDR_STAT(stat)[i]));
        CHANGED_BAG(body);
    }

    return result;
}

Obj SyntaxTreeRepeat(Stat stat)
{
    Obj result;
    Obj cond;
    Obj body;
    UInt i, nr;

    result = NewSyntaxTreeNode("Repeat");;

    cond = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    AssPRec(result, RNamName("condition"), cond);

    nr = SIZE_STAT(stat)/sizeof(Stat);
    body = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for ( i = 1; i < nr; i++ ) {
        SET_ELM_PLIST(body, i, SyntaxTreeCompiler( ADDR_STAT(stat)[i] ) );
        CHANGED_BAG(body);
    }

    return result;
}

/* TODO: make sure this works correctly */
Obj SyntaxTreeAssLVar(Stat stat)
{
    Obj result;
    Obj lvar;
    Obj rhs;

    result = NewSyntaxTreeNode("AssLVar");;

    lvar = INTOBJ_INT(ADDR_STAT(stat)[0]);
    rhs = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);

    AssPRec(result, RNamName("lvar"), lvar);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeUnbLVar(Stat stat)
{
    Obj result;
    Obj lvar;

    result = NewSyntaxTreeNode("UnbindLVar");;

    lvar = INTOBJ_INT(ADDR_STAT(stat)[0]);
    AssPRec(result, RNamName("lvar"), lvar);

    return result;
}

Obj SyntaxTreeAssHVar(Stat stat)
{
    Obj result;
    Obj hvar;
    Obj rhs;

    result = NewSyntaxTreeNode("AssHVar");;

    hvar = INTOBJ_INT(ADDR_STAT(stat)[0]);
    rhs = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);

    AssPRec(result, RNamName("hvar"), hvar);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeUnbHVar(Stat stat)
{
    Obj result;
    Obj hvar;

    result = NewSyntaxTreeNode("UnbindHVar");;

    hvar = INTOBJ_INT(ADDR_STAT(stat)[0]);
    AssPRec(result, RNamName("hvar"), hvar);

    return result;
}

Obj SyntaxTreeAssGVar(Stat stat)
{
    Obj result;
    Obj gvar;
    Obj rhs;

    result = NewSyntaxTreeNode("AssGVar");;

    gvar = NameGVarObj(ADDR_STAT(stat)[0]);
    rhs = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );

    AssPRec(result, RNamName("gvar"), gvar);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeUnbGVar(Stat stat)
{
    Obj result;
    Obj gvar;

    result = NewSyntaxTreeNode("UnbGVar");;

    gvar = NameGVarObj(ADDR_STAT(stat)[0]);
    AssPRec(result, RNamName("gvar"), gvar);

    return result;
}

Obj SyntaxTreeAssList(Stat stat)
{
    Obj result;
    Obj list;
    Obj pos;
    Obj rhs;

    result = NewSyntaxTreeNode("AssList");;

    list = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );
    rhs = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeAsssList (Stat stat)
{
    Obj result;
    Obj list;
    Obj poss;
    Obj rhss;

    result = NewSyntaxTreeNode("AsssList");;

    list = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    poss = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("poss"), poss);
    AssPRec(result, RNamName("rhss"), rhss);

    return result;
}

Obj SyntaxTreeAssListLev(Stat stat)
{
    Obj result;
    Obj lists;
    Obj pos;
    Obj rhss;
    Int level;

    result = NewSyntaxTreeNode("AssListLev");;

    lists = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );
    level = (Int)(ADDR_STAT(stat)[3]);

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("pos"), pos);
    AssPRec(result, RNamName("rhss"), rhss);
    AssPRec(result, RNamName("level"), INTOBJ_INT(level));

    return result;
}

Obj SyntaxTreeAsssListLev(Stat stat)
{
    Obj result;
    Obj lists;
    Obj poss;
    Obj rhss;
    Int level;

    result = NewSyntaxTreeNode("AsssListLev");;

    lists = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    poss = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );
    level = (Int)(ADDR_STAT(stat)[3]);

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("poss"), poss);
    AssPRec(result, RNamName("rhss"), rhss);
    AssPRec(result, RNamName("level"), INTOBJ_INT(level));

    return result;
}

Obj SyntaxTreeUnbList(Stat stat)
{
    Obj result;
    Obj list;
    Obj pos;

    result = NewSyntaxTreeNode("UnbList");;

    list = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);

    return result;
}

Obj SyntaxTreeAssRecName(Stat stat)
{
    Obj result;
    Obj record;
    Obj rnam;
    Obj rhs;

    result = NewSyntaxTreeNode("AssRecName");;

    record = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    /* TODO: Record Access */
    rnam = INTOBJ_INT(ADDR_STAT(stat)[1]);
    rhs = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeAssRecExpr(Stat stat)
{
    Obj result;
    Obj record;
    Obj rnam;
    Obj rhs;

    result = NewSyntaxTreeNode("AssRecExpr");;

    record = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    rnam = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );
    rhs = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeUnbRecName(Stat stat)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("UnbRecName");;

    record = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    rnam = INTOBJ_INT(ADDR_STAT(stat)[1]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));

    return result;
}

Obj SyntaxTreeUnbRecExpr(Stat stat)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("UnbRecExpr");;

    record = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    rnam = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));

    return result;
}

Obj SyntaxTreeAssPosObj(Stat stat)
{
    Obj result;
    Obj list;
    Obj pos;
    Obj rhs;

    result = NewSyntaxTreeNode("AssPosObj");;

    list = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );
    rhs = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeAsssPosObj(Stat stat)
{
    Obj result;
    Obj list;
    Obj poss;
    Obj rhss;

    result = NewSyntaxTreeNode("AsssPosObj");;

    list = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    poss = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("poss"), poss);
    AssPRec(result, RNamName("rhss"), rhss);

    return result;
}

Obj SyntaxTreeAssPosObjLev(Stat stat)
{
    Obj result;
    Obj lists;
    Obj pos;
    Obj rhss;
    Int level;

    result = NewSyntaxTreeNode("AssPosObjLev");;

    lists = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );
    level = (Int)(ADDR_STAT(stat)[3]);

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("pos"), pos);
    AssPRec(result, RNamName("rhss"), rhss);
    AssPRec(result, RNamName("level"), INTOBJ_INT(level));

    return result;
}

Obj SyntaxTreeAsssPosObjLev(Stat stat)
{
    Obj result;
    Obj lists;
    Obj poss;
    Obj rhss;
    Int level;

    result = NewSyntaxTreeNode("AsssPosObjLev");;

    lists = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    poss = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );
    level = (Int)(ADDR_STAT(stat)[3]);

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("poss"), poss);
    AssPRec(result, RNamName("rhss"), rhss);
    AssPRec(result, RNamName("level"), INTOBJ_INT(level));

    return result;
}

Obj SyntaxTreeUnbPosObj(Stat stat)
{
    Obj result;
    Obj list;
    Obj pos;

    result = NewSyntaxTreeNode("UnbPosObj");;
    list = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);

    return result;
}

Obj SyntaxTreeAssComObjName(Stat stat)
{
    Obj result;
    Obj record;
    UInt rnam;
    Obj rhs;

    result = NewSyntaxTreeNode("AssComObjName");;

    record = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    rnam = (UInt)(ADDR_STAT(stat)[1]);
    rhs = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeAssComObjExpr(Stat stat)
{
    Obj result;
    Obj record;
    Obj rnam;
    Obj rhs;

    result = NewSyntaxTreeNode("AssComObjExpr");;

    record = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    rnam = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );
    rhs = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeUnbComObjName(Stat stat)
{
    Obj result;
    Obj record;
    UInt rnam;

    result = NewSyntaxTreeNode("UnbComObjName");;

    record = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    rnam = (UInt)(ADDR_STAT(stat)[1]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));

    return result;
}

Obj SyntaxTreeUnbComObjExpr(Stat stat)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("UnbComObjExpr");;

    record = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    rnam = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeEmpty(Stat stat)
{
    Obj result;

    result = NewSyntaxTreeNode("Empty");;

    return result;
}

Obj SyntaxTreeInfo(Stat stat)
{
    Obj result;
    Obj sel;
    Obj lev;
    Obj lst;
    Obj tmp;
    UInt narg, i;

    result = NewSyntaxTreeNode("Info");;

    sel = SyntaxTreeCompiler( ARGI_INFO( stat, 1 ) );
    lev = SyntaxTreeCompiler( ARGI_INFO( stat, 2 ) );

    AssPRec(result, RNamName("sel"), sel);
    AssPRec(result, RNamName("lev"), lev);

    narg = NARG_SIZE_INFO(SIZE_STAT(stat))-2;
    lst = NEW_PLIST(T_PLIST, narg);
    SET_LEN_PLIST(lst, narg);

    for(i=1; i<=narg; i++) {
        tmp = SyntaxTreeCompiler( ARGI_INFO( stat, i+2 ) );
        SET_ELM_PLIST(lst, i, tmp);
        CHANGED_BAG(lst);
    }
    AssPRec(result, RNamName("args"), lst);

    return result;
}

Obj SyntaxTreeAssert2(Stat stat)
{
    Obj result;
    Obj lev;
    Obj cond;

    result = NewSyntaxTreeNode("Assert");;

    lev = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    cond = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );

    AssPRec(result, RNamName("level"), lev);
    AssPRec(result, RNamName("condition"), cond);

    return result;
}

Obj SyntaxTreeAssert3(Stat stat)
{
    Obj result;
    Obj lev;
    Obj cond;
    Obj msg;

    result = NewSyntaxTreeNode("Assert");;

    lev = SyntaxTreeCompiler( ADDR_STAT(stat)[0] );
    cond = SyntaxTreeCompiler( ADDR_STAT(stat)[1] );
    msg = SyntaxTreeCompiler( ADDR_STAT(stat)[2] );

    AssPRec(result, RNamName("level"), lev);
    AssPRec(result, RNamName("condition"), cond);
    AssPRec(result, RNamName("message"), msg);

    return result;
}

static Obj SyntaxTreeFunc( Obj func )
{
    Obj result;
    Obj str;
    Obj stats;
    Obj argnams;
    Obj locnams;

    Bag oldFrame;
    Int narg;
    Int nloc;
    Int i;

    result = NewSyntaxTreeNode("Function");;

    if (NAME_FUNC(func)) {
        AssPRec(result, RNamName("name"), NAME_FUNC(func));
    }

    narg = NARG_FUNC(func);
    if(narg < 0) {
        AssPRec(result, RNamName("variadic"), True);
        narg = -narg;
    } else {
        AssPRec(result, RNamName("variadic"), False);
    }
    AssPRec(result, RNamName("narg"), INTOBJ_INT(narg));

    /* names of arguments */
    argnams = NEW_PLIST(T_PLIST, narg);
    SET_LEN_PLIST(argnams, narg);
    AssPRec(result, RNamName("argnams"), argnams);
    for(i=1; i<= narg; i++) {
        if(NAMI_FUNC(func, i) != 0) {
            C_NEW_STRING_DYN(str, NAMI_FUNC(func, i));
        } else {
            /* TODO: Probably put the number in */
            C_NEW_STRING_CONST(str, "localvar");
        }
        SET_ELM_PLIST(argnams, i, str);
        CHANGED_BAG(argnams);
    }

    /* names of local variables */
    nloc = NLOC_FUNC(func);
    AssPRec(result, RNamName("nloc"), INTOBJ_INT(nloc));
    locnams = NEW_PLIST(T_PLIST, nloc);
    SET_LEN_PLIST(locnams, nloc);
    AssPRec(result, RNamName("locnams"), locnams);
    for(i=1;i<=nloc; i++) {
        if(NAMI_FUNC(func, narg + i) != 0) {
            C_NEW_STRING_DYN(str, NAMI_FUNC(func, narg + i));
        } else {
            /* TODO: Probably put the number in */
            C_NEW_STRING_CONST(str, "localvar");
        }
        SET_ELM_PLIST(locnams, i, str);
        CHANGED_BAG(locnams);
    }

    /* switch to this function (so that 'ADDR_STAT' and 'ADDR_EXPR' work)  */
    SWITCH_TO_NEW_LVARS( func, narg, nloc, oldFrame );
    stats = SyntaxTreeCompiler( FIRST_STAT_CURR_FUNC );
    SWITCH_TO_OLD_LVARS( oldFrame );

    AssPRec(result, RNamName("stats"), stats);

    return result;
}

/* TODO: Make this the table for all compilers? */
static CompilerT AllCompilers[256];

static const CompilerT StatCompilers[] = {
    COMPILER(T_PROCCALL_0ARGS, SyntaxTreeDefaultCompiler),
    COMPILER(T_PROCCALL_1ARGS, SyntaxTreeDefaultCompiler),
    COMPILER(T_PROCCALL_2ARGS, SyntaxTreeDefaultCompiler),
    COMPILER(T_PROCCALL_3ARGS, SyntaxTreeDefaultCompiler),
    COMPILER(T_PROCCALL_4ARGS, SyntaxTreeDefaultCompiler),
    COMPILER(T_PROCCALL_5ARGS, SyntaxTreeDefaultCompiler),
    COMPILER(T_PROCCALL_6ARGS, SyntaxTreeDefaultCompiler),
    COMPILER(T_PROCCALL_XARGS, SyntaxTreeDefaultCompiler),

    COMPILER(T_SEQ_STAT, SyntaxTreeDefaultCompiler),
    COMPILER(T_SEQ_STAT2, SyntaxTreeDefaultCompiler),
    COMPILER(T_SEQ_STAT3, SyntaxTreeDefaultCompiler),
    COMPILER(T_SEQ_STAT4, SyntaxTreeDefaultCompiler),
    COMPILER(T_SEQ_STAT5, SyntaxTreeDefaultCompiler),
    COMPILER(T_SEQ_STAT6, SyntaxTreeDefaultCompiler),
    COMPILER(T_SEQ_STAT7, SyntaxTreeDefaultCompiler),
    COMPILER(T_IF, SyntaxTreeDefaultCompiler),
    COMPILER(T_IF_ELSE, SyntaxTreeDefaultCompiler),
    COMPILER(T_IF_ELIF, SyntaxTreeDefaultCompiler),
    COMPILER(T_IF_ELIF_ELSE, SyntaxTreeDefaultCompiler),
    COMPILER(T_FOR, SyntaxTreeDefaultCompiler),
    COMPILER(T_FOR2, SyntaxTreeDefaultCompiler),
    COMPILER(T_FOR3, SyntaxTreeDefaultCompiler),
    COMPILER(T_FOR_RANGE, SyntaxTreeDefaultCompiler),
    COMPILER(T_FOR_RANGE2, SyntaxTreeDefaultCompiler),
    COMPILER(T_FOR_RANGE3, SyntaxTreeDefaultCompiler),
    COMPILER(T_WHILE, SyntaxTreeDefaultCompiler),
    COMPILER(T_WHILE2, SyntaxTreeDefaultCompiler),
    COMPILER(T_WHILE3, SyntaxTreeDefaultCompiler),
    COMPILER(T_REPEAT, SyntaxTreeDefaultCompiler),
    COMPILER(T_REPEAT2, SyntaxTreeDefaultCompiler),
    COMPILER(T_REPEAT3, SyntaxTreeDefaultCompiler),
    COMPILER(T_BREAK, SyntaxTreeDefaultCompiler),
    COMPILER(T_CONTINUE, SyntaxTreeDefaultCompiler),
    COMPILER(T_RETURN_OBJ, SyntaxTreeDefaultCompiler),
    COMPILER(T_RETURN_VOID, SyntaxTreeDefaultCompiler),

    COMPILER(T_ASS_LVAR, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_01, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_02, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_03, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_04, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_05, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_06, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_07, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_08, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_09, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_10, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_11, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_12, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_13, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_14, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_15, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LVAR_16, SyntaxTreeDefaultCompiler),
    COMPILER(T_UNB_LVAR, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_HVAR, SyntaxTreeDefaultCompiler),
    COMPILER(T_UNB_HVAR, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_GVAR, SyntaxTreeDefaultCompiler),
    COMPILER(T_UNB_GVAR, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LIST, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASSS_LIST, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_LIST_LEV, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASSS_LIST_LEV, SyntaxTreeDefaultCompiler),
    COMPILER(T_UNB_LIST, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_REC_NAME, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_REC_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_UNB_REC_NAME, SyntaxTreeDefaultCompiler),
    COMPILER(T_UNB_REC_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_POSOBJ, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASSS_POSOBJ, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_POSOBJ_LEV, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASSS_POSOBJ_LEV, SyntaxTreeDefaultCompiler),
    COMPILER(T_UNB_POSOBJ, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_COMOBJ_NAME, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_COMOBJ_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_UNB_COMOBJ_NAME, SyntaxTreeDefaultCompiler),
    COMPILER(T_UNB_COMOBJ_EXPR, SyntaxTreeDefaultCompiler),

    COMPILER(T_INFO, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASSERT_2ARGS, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASSERT_3ARGS, SyntaxTreeDefaultCompiler),

    COMPILER(T_EMPTY, SyntaxTreeDefaultCompiler),

    COMPILER(T_PROCCALL_OPTS, SyntaxTreeDefaultCompiler),

    COMPILER(T_ATOMIC, SyntaxTreeDefaultCompiler),
};

static const CompilerT ExprCompilers[] = {
    COMPILER(T_FUNCCALL_0ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_1ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_2ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_3ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_4ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_5ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_6ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_XARGS, SyntaxTreeFunccall),

    COMPILER(T_FUNC_EXPR, SyntaxTreeDefaultCompiler),

    COMPILER(T_OR, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_AND, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_NOT, SyntaxTreeDefaultCompiler, "op"),
    COMPILER(T_EQ, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_NE, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_LT, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_GE, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_GT, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_LE, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_IN, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_SUM, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_AINV, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_DIFF, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_PROD, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_INV, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_QUO, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_MOD, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_POW, SyntaxTreeDefaultCompiler, "left", "right"),

    COMPILER(T_INTEXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_INT_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_TRUE_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_FALSE_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_CHAR_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_PERM_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_PERM_CYCLE, SyntaxTreeDefaultCompiler),
    COMPILER(T_LIST_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_LIST_TILD_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_RANGE_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_STRING_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_REC_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_REC_TILD_EXPR, SyntaxTreeDefaultCompiler),

    COMPILER(T_REFLVAR, SyntaxTreeDefaultCompiler),

    COMPILER(128 + 41, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 42, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 43, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 44, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 45, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 46, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 47, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 48, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 49, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 50, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 51, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 52, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 53, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 54, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 55, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 56, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 57, SyntaxTreeDefaultCompiler),

    COMPILER(T_ISB_LVAR, SyntaxTreeDefaultCompiler, "var"),
    COMPILER(T_REF_HVAR, SyntaxTreeDefaultCompiler, "var"),
    COMPILER(T_ISB_HVAR, SyntaxTreeDefaultCompiler, "var"),
    COMPILER(T_REF_GVAR, SyntaxTreeDefaultCompiler, "var"),
    COMPILER(T_ISB_GVAR, SyntaxTreeDefaultCompiler, "var"),
    COMPILER(T_ELM_LIST, SyntaxTreeDefaultCompiler, "list", "pos"),
    COMPILER(T_ELMS_LIST, SyntaxTreeDefaultCompiler, "list", "poss"),
    COMPILER(T_ELM_LIST_LEV, SyntaxTreeDefaultCompiler, "lists", "pos", "level"),
    COMPILER(T_ELMS_LIST_LEV, SyntaxTreeDefaultCompiler, "lists", "poss", "level"),
    COMPILER(T_ISB_LIST, SyntaxTreeDefaultCompiler, "list", "pos"),
    COMPILER(T_ELM_REC_NAME, SyntaxTreeDefaultCompiler, "record", "name"),
    COMPILER(T_ELM_REC_EXPR, SyntaxTreeDefaultCompiler, "record", "expression"),
    COMPILER(T_ISB_REC_NAME, SyntaxTreeDefaultCompiler, "record", "name"),
    COMPILER(T_ISB_REC_EXPR, SyntaxTreeDefaultCompiler, "record", "expression"),
    COMPILER(T_ELM_POSOBJ, SyntaxTreeDefaultCompiler, "posobj", "pos"),
    COMPILER(T_ELMS_POSOBJ, SyntaxTreeDefaultCompiler, "posobj", "pos"),
    COMPILER(T_ELM_POSOBJ_LEV, SyntaxTreeDefaultCompiler, "posobj", "pos", "level"),
    COMPILER(T_ELMS_POSOBJ_LEV, SyntaxTreeDefaultCompiler, "posobj", "poss", "level"),
    COMPILER(T_ISB_POSOBJ, SyntaxTreeDefaultCompiler, "posobj", "pos"),
    COMPILER(T_ELM_COMOBJ_NAME, SyntaxTreeDefaultCompiler, "comobj", "name"),
    COMPILER(T_ELM_COMOBJ_EXPR, SyntaxTreeDefaultCompiler, "comobj", "expression"),
    COMPILER(T_ISB_COMOBJ_NAME, SyntaxTreeDefaultCompiler, "comobj", "name"),
    COMPILER(T_ISB_COMOBJ_EXPR, SyntaxTreeDefaultCompiler, "comobj", "expression"),

    COMPILER(T_FUNCCALL_OPTS, SyntaxTreeDefaultCompiler),
    COMPILER(T_FLOAT_EXPR_EAGER, SyntaxTreeDefaultCompiler),
    COMPILER(T_FLOAT_EXPR_LAZY, SyntaxTreeDefaultCompiler),

    COMPILER(T_ELM2_LIST, SyntaxTreeDefaultCompiler),
    COMPILER(T_ELMX_LIST, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS2_LIST, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASSX_LIST, SyntaxTreeDefaultCompiler),
};

Obj FuncSYNTAX_TREE ( Obj self, Obj func )
{
    return SyntaxTreeFunc(func);
}

static StructGVarFunc GVarFuncs [] = {
    { "SYNTAX_TREE", 1, "func",
      FuncSYNTAX_TREE, "src/syntaxtree.c:SYNTAX_TREE" },
    { 0 }
};

static Int InitKernel( StructInitInfo *module )
{
    /* init filters and functions */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* check TNUMS table */
    for (int i = 0; i < LAST_STAT_TNUM; i++ ) {
        if(!(StatCompilers[i].tnum == i )) {
            fprintf(stderr, "Warning, statement tnum desync %d %d %s\n", StatCompilers[i].tnum, i, StatCompilers[i].name);
        }
    }

    for (int i = FIRST_EXPR_TNUM; i < LAST_EXPR_TNUM; i++ ) {
      if(!(ExprCompilers[i-FIRST_EXPR_TNUM].tnum == i)) {
          fprintf(stderr, "Warning, expression tnum desync %d %d %s\n", ExprCompilers[i-FIRST_EXPR_TNUM].tnum, i, ExprCompilers[i-FIRST_EXPR_TNUM].name);
      }
    }
    return 0;
}

static Int PostRestore( StructInitInfo *module )
{
    return 0;
}

static Int InitLibrary( StructInitInfo *module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return PostRestore( module );
}

static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "syntaxtree",                       /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    PostRestore                         /* postRestore                    */
};

StructInitInfo * InitInfoSyntaxTree ( void )
{
    return &module;
}

/*E syntaxtree.c */
