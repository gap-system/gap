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

typedef Obj (*CompileExpr)(Expr expr);

typedef struct {
  UInt tnum;
  CompileExpr compiler;
  const Char *name;
  UInt arity;
  const Char *argnames[6];
} ExprT;

static const ExprT AllExpressions[];

static inline Obj NewSyntaxTreeNode(const char *type)
{
    Obj result;
    Obj typestr;

    C_NEW_STRING_DYN(typestr, type);
    result = NEW_PREC(1);
    AssPRec(result, RNamName("type"), typestr);

    return result;
}

static Obj SyntaxTreeDefaultExpr(Expr expr)
{
    Obj result;

    /* TODO: Check that TNUM in range */

    result = NewSyntaxTreeNode(AllExpressions[TNUM_EXPR(expr)].name);
    return result;
}

static inline Obj SyntaxTreeExpr(Expr expr)
{
    return AllExpressions[TNUM_EXPR(expr)].compiler(expr);
}

Obj SyntaxTreeUnknownExpr(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("UnknownExpr");;
    AssPRec(result, RNamName("tnum"), INTOBJ_INT(TNUM_EXPR(expr)));
    return result;
}

Obj SyntaxTreeUnknownBool(Expr expr)
{
    /* compile the expression and check that the value is boolean          */
    /* TODO: Check boolean? */
    return SyntaxTreeExpr(expr);
}

extern Obj SyntaxTreeRefGVarFopy (Expr expr);

Obj SyntaxTreeFunccall(Expr expr)
{
    Obj result;
    Obj func;
    Obj args, argi;
    UInt narg, i;

    result = NewSyntaxTreeNode("Funccall");;
    /* TODO: If this is a gvar ref, put name? */
    func = SyntaxTreeExpr( FUNC_CALL(expr) );

    /*
    if ( TNUM_EXPR( FUNC_CALL(expr) ) == T_REF_GVAR ) {
    } */
    AssPRec(result, RNamName("function"), func);

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_EXPR(expr));
    args = NEW_PLIST(T_PLIST, narg);
    SET_LEN_PLIST(args, narg);

    for ( i = 1; i <= narg; i++ ) {
        argi = SyntaxTreeExpr( ARGI_CALL( expr, i ) );
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
    opts = SyntaxTreeExpr(ADDR_STAT(expr)[0]);
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
            val = SyntaxTreeExpr(ADDR_EXPR(cycleexpr)[j-1]);
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
            SET_ELM_PLIST(list, i, SyntaxTreeExpr(ADDR_EXPR(expr)[i-1]));
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
        first  = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
        last   = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

        AssPRec(result, RNamName("first"), first);
        AssPRec(result, RNamName("last"), last);
    } else {
        first  = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
        second = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );
        last   = SyntaxTreeExpr( ADDR_EXPR(expr)[2] );

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
                key = SyntaxTreeExpr(tmp);
            }
            AssPRec(subrec, RNamName("key"), key);

            tmp = ADDR_EXPR(expr)[2*i-1];
            val = SyntaxTreeExpr(tmp);
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
        func = SyntaxTreeExpr( FUNC_CALL(stat) );
    }
    AssPRec(result, RNamName("function"), func);

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_STAT(stat));
    args = NEW_PLIST(T_PLIST, narg);
    SET_LEN_PLIST(args, narg);
    for ( i = 1; i <= narg; i++ ) {
        SET_ELM_PLIST(args, i, SyntaxTreeExpr( ARGI_CALL(stat,i) ) );
    }
    AssPRec(result, RNamName("args"), args);
    return result;
}

Obj SyntaxTreeProccallOpts(Stat stat)
{
    Obj result;
    Obj opts;

    result = NewSyntaxTreeNode("ProccallOpts");;
    opts = SyntaxTreeExpr(ADDR_STAT(stat)[0]);

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
        SET_ELM_PLIST(list, i, SyntaxTreeStat( ADDR_STAT( stat )[i-1] ) );
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

    cond = SyntaxTreeExpr( ADDR_STAT( stat )[0] );
    then = SyntaxTreeStat( ADDR_STAT( stat )[1] );

    for(i=0;i<nr;i++) {
        cond = SyntaxTreeExpr( ADDR_STAT( stat )[2*i] );
        then = SyntaxTreeStat( ADDR_STAT( stat )[2*i+1] );

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

    AssPRec(result, RNamName("variable"), SyntaxTreeExpr(ADDR_STAT(stat)[0]));
    AssPRec(result, RNamName("collection"), SyntaxTreeExpr(ADDR_STAT(stat)[1]));

    nr = SIZE_STAT(stat)/sizeof(Stat);
    body = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for ( i = 2; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
        SET_ELM_PLIST(body, i - 1, SyntaxTreeStat( ADDR_STAT(stat)[i] ) );
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

    condition = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    AssPRec(result, RNamName("condition"), condition);

    nr = SIZE_STAT(stat)/sizeof(Stat);
    body = NEW_PLIST(T_PLIST, nr - 1);
    SET_LEN_PLIST(body, nr - 1);
    AssPRec(result, RNamName("body"), body);

    for ( i = 1; i < nr; i++ ) {
        SET_ELM_PLIST(body, i, SyntaxTreeStat( ADDR_STAT(stat)[i]));
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

    cond = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    AssPRec(result, RNamName("condition"), cond);

    nr = SIZE_STAT(stat)/sizeof(Stat);
    body = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for ( i = 1; i < nr; i++ ) {
        SET_ELM_PLIST(body, i, SyntaxTreeStat( ADDR_STAT(stat)[i] ) );
        CHANGED_BAG(body);
    }

    return result;
}

Obj SyntaxTreeBreak(Stat stat)
{
    return NewSyntaxTreeNode("Break");;
}

Obj SyntaxTreeContinue(Stat stat)
{
    return NewSyntaxTreeNode("Continue");;
}

Obj SyntaxTreeReturnObj(Stat stat)
{
    Obj result;
    Obj obj;

    result = NewSyntaxTreeNode("Return");;
    obj = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    AssPRec(result, RNamName("obj"), obj);

    return result;
}

Obj SyntaxTreeReturnVoid(Stat stat)
{
    Obj result;
    result = NewSyntaxTreeNode("Return");;
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
    rhs = SyntaxTreeExpr(ADDR_STAT(stat)[1]);

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
    rhs = SyntaxTreeExpr(ADDR_STAT(stat)[1]);

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
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

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

    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

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

    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    poss = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

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

    lists = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeExpr( ADDR_STAT(stat)[2] );
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

    lists = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    poss = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeExpr( ADDR_STAT(stat)[2] );
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

    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

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

    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    /* TODO: Record Access */
    rnam = INTOBJ_INT(ADDR_STAT(stat)[1]);
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

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

    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    rnam = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

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

    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
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

    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    rnam = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

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

    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

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

    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    poss = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

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

    lists = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeExpr( ADDR_STAT(stat)[2] );
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

    lists = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    poss = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    rhss = SyntaxTreeExpr( ADDR_STAT(stat)[2] );
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
    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

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

    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    rnam = (UInt)(ADDR_STAT(stat)[1]);
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

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

    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    rnam = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

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

    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
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

    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    rnam = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

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

    sel = SyntaxTreeExpr( ARGI_INFO( stat, 1 ) );
    lev = SyntaxTreeExpr( ARGI_INFO( stat, 2 ) );

    AssPRec(result, RNamName("sel"), sel);
    AssPRec(result, RNamName("lev"), lev);

    narg = NARG_SIZE_INFO(SIZE_STAT(stat))-2;
    lst = NEW_PLIST(T_PLIST, narg);
    SET_LEN_PLIST(lst, narg);

    for(i=1; i<=narg; i++) {
        tmp = SyntaxTreeExpr( ARGI_INFO( stat, i+2 ) );
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

    lev = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    cond = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

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

    lev = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    cond = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    msg = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

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
    stats = SyntaxTreeStat( FIRST_STAT_CURR_FUNC );
    SWITCH_TO_OLD_LVARS( oldFrame );

    AssPRec(result, RNamName("stats"), stats);

    return result;
}

#define EXPR_COMPILER(tnum, compiler, arity, names) \
    { tnum, compiler, "tnum", arity, names }
#define EXPR_COMPILER_DEFAULT(tnum) \
    EXPR_COMPILER(tnum, SyntaxTreeDefaultExpr, 0, { })

static const ExprT AllExpressions[] = {
    EXPR_COMPILER(T_FUNCCALL_0ARGS, SyntaxTreeFunccall, 0, { }),
//    { T_FUNCCALL_0ARGS, SyntaxTreeFunccall, "T_FUNCCALL_0ARGS", 0, { } },
    { T_FUNCCALL_1ARGS, SyntaxTreeFunccall, "T_FUNCCALL_1ARGS", 0, { } },
    { T_FUNCCALL_2ARGS, SyntaxTreeFunccall, "T_FUNCCALL_2ARGS", 0, { } },
    { T_FUNCCALL_3ARGS, SyntaxTreeFunccall, "T_FUNCCALL_3ARGS", 0, { } },
    { T_FUNCCALL_4ARGS, SyntaxTreeFunccall, "T_FUNCCALL_4ARGS", 0, { } },
    { T_FUNCCALL_5ARGS, SyntaxTreeFunccall, "T_FUNCCALL_5ARGS", 0, { } },
    { T_FUNCCALL_6ARGS, SyntaxTreeFunccall, "T_FUNCCALL_6ARGS", 0, { } },
    { T_FUNCCALL_XARGS, SyntaxTreeFunccall, "T_FUNCCALL_XARGS", 0, { } },
    { T_FUNC_EXPR, SyntaxTreeFuncExpr, "T_FUNC_EXPR", 0, { } },

    { T_OR, SyntaxTreeDefaultExpr, "T_OR", 2, { "left", "right" } },
    { T_AND, SyntaxTreeDefaultExpr, "T_AND", 2, {"left", "right"} },
    { T_NOT, SyntaxTreeDefaultExpr, "T_NOT", 1, {"op"} },
    { T_EQ, SyntaxTreeDefaultExpr, "T_EQ", 2, {"left", "right"} },
    { T_NE, SyntaxTreeDefaultExpr, "T_NE", 2, {"left", "right"} },
    { T_LT, SyntaxTreeDefaultExpr, "T_LT", 2, {"left", "right"} },
    { T_GE, SyntaxTreeDefaultExpr, "T_GE", 2, {"left", "right"} },
    { T_GT, SyntaxTreeDefaultExpr, "T_GT", 2, {"left", "right"} },
    { T_LE, SyntaxTreeDefaultExpr, "T_LE", 2, {"left", "right"} },
    { T_IN, SyntaxTreeDefaultExpr, "T_IN", 2, {"left", "right"} },
    { T_SUM, SyntaxTreeDefaultExpr, "T_SUM", 2, {"left", "right"} },
    { T_AINV, SyntaxTreeDefaultExpr, "T_AINV", 1, {"left", "right"} },
    { T_DIFF, SyntaxTreeDefaultExpr, "T_DIFF", 2, {"left", "right"} },
    { T_PROD, SyntaxTreeDefaultExpr, "T_PROD", 2, {"left", "right"} },
    { T_INV, SyntaxTreeDefaultExpr, "T_INV", 1, {"left", "right"} },
    { T_QUO, SyntaxTreeDefaultExpr, "T_QUO", 2, {"left", "right"} },
    { T_MOD, SyntaxTreeDefaultExpr, "T_MOD", 2, {"left", "right"} },
    { T_POW, SyntaxTreeDefaultExpr, "T_POW", 2, {"left", "right"} },

    { T_INTEXPR, SyntaxTreeDefaultExpr, "T_INTEXPR", 0, { } },
    { T_INT_EXPR, SyntaxTreeDefaultExpr, "T_INT_EXPR", 0, { } },
    { T_TRUE_EXPR, SyntaxTreeDefaultExpr, "T_TRUE_EXPR", 0, { } },
    { T_FALSE_EXPR, SyntaxTreeDefaultExpr, "T_FALSE_EXPR", 0, { } },
    { T_CHAR_EXPR, SyntaxTreeDefaultExpr, "T_CHAR_EXPR", 0, { } },
    { T_PERM_EXPR, SyntaxTreeDefaultExpr, "T_PERM_EXPR", 0, { } },
    { T_PERM_CYCLE, SyntaxTreeDefaultExpr, "T_PERM_CYCLE", 0, { } },
    { T_LIST_EXPR, SyntaxTreeDefaultExpr, "T_LIST_EXPR", 0, { } },
    { T_LIST_TILD_EXPR, SyntaxTreeDefaultExpr, "T_LIST_TILD_EXPR", 0, { } },
    { T_RANGE_EXPR, SyntaxTreeDefaultExpr, "T_RANGE_EXPR", 0, { } },
    { T_STRING_EXPR, SyntaxTreeDefaultExpr, "T_STRING_EXPR", 0, { } },
    { T_REC_EXPR, SyntaxTreeDefaultExpr, "T_REC_EXPR", 0, { } },
    { T_REC_TILD_EXPR, SyntaxTreeDefaultExpr, "T_REC_TILD_EXPR", 0, { } },

    { T_REFLVAR, SyntaxTreeDefaultExpr, "T_REFLVAR", 0, { } },

    DEF_EXPR_DEFAULT(41),
    DEF_EXPR_DEFAULT(42),
    DEF_EXPR_DEFAULT(43),
    DEF_EXPR_DEFAULT(44),
    DEF_EXPR_DEFAULT(45),
    DEF_EXPR_DEFAULT(46),
    DEF_EXPR_DEFAULT(47),
    DEF_EXPR_DEFAULT(48),
    DEF_EXPR_DEFAULT(49),
    DEF_EXPR_DEFAULT(50),
    DEF_EXPR_DEFAULT(51),
    DEF_EXPR_DEFAULT(52),
    DEF_EXPR_DEFAULT(53),
    DEF_EXPR_DEFAULT(54),
    DEF_EXPR_DEFAULT(55),
    DEF_EXPR_DEFAULT(56),
    DEF_EXPR_DEFAULT(57),

    { T_ISB_LVAR, SyntaxTreeDefaultExpr, "T_ISB_LVAR", 1, { "var" } },
    { T_REF_HVAR, SyntaxTreeDefaultExpr, "T_REF_HVAR", 1, { "var" } },
    { T_ISB_HVAR, SyntaxTreeDefaultExpr, "T_ISB_HVAR", 1, { "var" } },
    { T_REF_GVAR, SyntaxTreeDefaultExpr, "T_REF_GVAR", 1, { "var" } },
    { T_ISB_GVAR, SyntaxTreeDefaultExpr, "T_ISB_GVAR", 1, { "var" } },
    { T_ELM_LIST, SyntaxTreeDefaultExpr, "T_ELM_LIST", 2, { "list", "pos" } },
    { T_ELMS_LIST, SyntaxTreeDefaultExpr, "T_ELMS_LIST", 2, { "list", "poss" } },
    { T_ELM_LIST_LEV, SyntaxTreeDefaultExpr, "T_ELM_LIST_LEV", 3, { "lists", "pos", "level" } },
    { T_ELMS_LIST_LEV, SyntaxTreeDefaultExpr, "T_ELMS_LIST_LEV", 3, { "lists", "poss", "level" } },
    { T_ISB_LIST, SyntaxTreeDefaultExpr, "T_ISB_LIST", 2, { "list", "pos" } },
    { T_ELM_REC_NAME, SyntaxTreeDefaultExpr, "T_ELM_REC_NAME", 2, { "record", "name" } },
    { T_ELM_REC_EXPR, SyntaxTreeDefaultExpr, "T_ELM_REC_EXPR", 2, { "record", "expression" } },
    { T_ISB_REC_NAME, SyntaxTreeDefaultExpr, "T_ISB_REC_NAME", 2, { "record", "name" } },
    { T_ISB_REC_EXPR, SyntaxTreeDefaultExpr, "T_ISB_REC_EXPR", 2, { "record", "expression" } },
    { T_ELM_POSOBJ, SyntaxTreeDefaultExpr, "T_ELM_POSOBJ", 2, { "posobj", "pos" } },
    { T_ELMS_POSOBJ, SyntaxTreeDefaultExpr, "T_ELMS_POSOBJ", 2, { "posobj", "pos" } },
    { T_ELM_POSOBJ_LEV, SyntaxTreeDefaultExpr, "T_ELM_POSOBJ_LEV", 3, { "posobj", "pos", "level" } },
    { T_ELMS_POSOBJ_LEV, SyntaxTreeDefaultExpr, "T_ELMS_POSOBJ_LEV", 3, { "posobj", "poss", "level" } },
    { T_ISB_POSOBJ, SyntaxTreeDefaultExpr, "T_ISB_POSOBJ", 2, { "posobj", "pos" } },
    { T_ELM_COMOBJ_NAME, SyntaxTreeDefaultExpr, "T_ELM_COMOBJ_NAME", 2, { "comobj", "name" } },
    { T_ELM_COMOBJ_EXPR, SyntaxTreeDefaultExpr, "T_ELM_COMOBJ_EXPR", 2, { "comobj", "expression" } },
    { T_ISB_COMOBJ_NAME, SyntaxTreeDefaultExpr, "T_ISB_COMOBJ_NAME", 2, { "comobj", "name" } },
    { T_ISB_COMOBJ_EXPR, SyntaxTreeDefaultExpr, "T_ISB_COMOBJ_EXPR", 2, { "comobj", "expression" } },

    { T_FUNCCALL_OPTS, SyntaxTreeDefaultExpr, "T_FUNCCALL_OPTS", 0, { } },
    { T_FLOAT_EXPR_EAGER, SyntaxTreeDefaultExpr, "T_FLOAT_EXPR_EAGER", 0, { } },
    { T_FLOAT_EXPR_LAZY, SyntaxTreeDefaultExpr, "T_FLOAT_EXPR_LAZY", 0, { } },

    { T_ELM2_LIST, SyntaxTreeDefaultExpr, "T_ELM", 0, { } },
    { T_ELMX_LIST, SyntaxTreeDefaultExpr, "T_ELMX_LIST", 0, { } },
    { T_ASS2_LIST, SyntaxTreeDefaultExpr, "T_ASS", 0, { } },
    { T_ASSX_LIST, SyntaxTreeDefaultExpr, "T_ASSX_LIST", 0, { } },

    { 0, 0, 0, 0, 0}
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
    for (int i = 0; i < 88; i++ ) {
        if(!(AllExpressions[i].tnum == i)) {
            fprintf(stderr, "Warning, tnum desync\n");
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
