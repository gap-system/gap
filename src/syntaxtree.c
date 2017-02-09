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

/* TODO: Lose the parameter? */
static inline Obj NewSyntaxTreeNode(const char *type, Int size)
{
    Obj result;
    Obj typestr;

    C_NEW_STRING_DYN(typestr, type);
    result = NEW_PREC(size);
    AssPRec(result, RNamName("type"), typestr);
    return result;
}

Obj (* SyntaxTreeExprFuncs[256]) ( Expr expr );

static inline Obj SyntaxTreeExpr(Expr expr)
{
    return (* SyntaxTreeExprFuncs[ TNUM_EXPR(expr) ])( expr );
}

Obj SyntaxTreeUnknownExpr(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("UnknownExpr",2);
    AssPRec(result, RNamName("tnum"), INTOBJ_INT(TNUM_EXPR(expr)));
    return result;
}

/* TODO: Find out why BoolExpr is special */
Obj (* SyntaxTreeBoolExprFuncs[256]) ( Expr expr );

Obj SyntaxTreeBoolExpr(Expr expr)
{
    return (* SyntaxTreeBoolExprFuncs[ TNUM_EXPR(expr) ])( expr );
}

Obj SyntaxTreeUnknownBool(Expr expr)
{
    /* compile the expression and check that the value is boolean          */
    /* TODO: Check boolean? */
    return SyntaxTreeExpr( expr );
}

extern Obj SyntaxTreeRefGVarFopy (Expr expr);

Obj SyntaxTreeFunccall(Expr expr)
{
    Obj result;
    Obj func;
    Obj args, argi;
    UInt narg, i;

    result = NewSyntaxTreeNode("Funccall", 5);
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

    result = NewSyntaxTreeNode("FunccallOpts", 2);
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

    result = NewSyntaxTreeNode("FuncExpr", 1);

    fexs = FEXS_FUNC(CURR_FUNC);
    fexp = ELM_PLIST(fexs, ((Int *)ADDR_EXPR(expr))[0]);
    func = SyntaxTreeFunc(fexp);

    AssPRec(result, RNamName("func"), func);

    return result;
}

/* TODO: This is all the same, replace by SyntaxTreeBinaryOp(Expr,op) and
 * SyntaxTreeUnary(Expr, op) */
Obj SyntaxTreeOr(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Or", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeBoolExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeBoolExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeAnd(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("And",3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr(ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeExpr(ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeNot(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Not", 2);
    AssPRec(result, RNamName("op"), SyntaxTreeBoolExpr( ADDR_EXPR(expr)[0]));

    return result;
}

Obj SyntaxTreeEq(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Eq", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"),SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeNe(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Ne", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"),SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeLt(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Lt", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0] ) );
    AssPRec(result, RNamName("right"),  SyntaxTreeExpr( ADDR_EXPR(expr)[1] ) );

    return result;
}

Obj SyntaxTreeGe(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Ge", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeGt(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Gt", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeLe(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Le", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeIn(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("In", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeSum(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Sum", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeAInv(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("AInv", 2);
    AssPRec(result, RNamName("op"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));

    return result;
}

Obj SyntaxTreeDiff(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Diff", 3);
    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeProd(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Prod", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeInv(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Inv", 3);

    AssPRec(result, RNamName("op"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));

    return result;
}

Obj SyntaxTreeQuo(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Quot", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeMod(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Mod", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreePow(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("Pow", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeIntExpr(Expr expr)
{
    Obj result;
    Obj value;
    Int siz;
    UInt typ;
    Int i;

    result = NewSyntaxTreeNode("IntExpr", 1);

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

Obj SyntaxTreeTrueExpr(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("TrueExpr", 1);

    return result;
}

Obj SyntaxTreeFalseExpr(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("FalseExpr", 1);

    return result;
}

Obj SyntaxTreeCharExpr(Expr expr)
{
    Obj result;
    Obj value;

    /* TODO: How do I make a character literal? */
    result = NewSyntaxTreeNode("CharExpr",1);
    value = INTOBJ_INT(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("result"), value);

    return result;
}

Obj SyntaxTreePermExpr (Expr expr)
{
    Obj result;
    Obj cycles;
    Obj cycle;
    Obj val;
    Expr cycleexpr;
    Int csize, n;
    Int i, j;

    result = NewSyntaxTreeNode("PermExpr", 2);

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

/* TODO: FInd out why record and list subexpressions are handled
   special */
Obj SyntaxTreeListExpr (Expr expr)
{
    Obj result;
    Obj list;
    Int len;
    Int i;

    result = NewSyntaxTreeNode("ListExpr", 2);
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

    result = NewSyntaxTreeNode("RangeExpr", 4);

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

/* TODO: Can we still identify whether a string was triple quoted? */
Obj SyntaxTreeStringExpr(Expr expr)
{
    Obj result, string;

    result = NewSyntaxTreeNode("StringExpr",2);

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

    result = NewSyntaxTreeNode("RecExpr", 2);

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

    result = NewSyntaxTreeNode("RefLVar", 2);

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

    result = NewSyntaxTreeNode("IsBLvar", 2);

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
    result = NewSyntaxTreeNode("RefHVar", 2);
    hvar = (HVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("variable"), INTOBJ_INT(hvar));

    return result;
}

Obj SyntaxTreeIsbHVar(Expr expr)
{
    Obj result;
    HVar hvar;

    result = NewSyntaxTreeNode("IsBHVar", 2);
    hvar = (HVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("variable"), INTOBJ_INT(hvar));

    return result;
}

Obj SyntaxTreeRefGVar(Expr expr)
{
    Obj result;
    GVar gvar;

    result = NewSyntaxTreeNode("RefGVar", 2);
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("name"), NameGVarObj(gvar));

    return result;
}

Obj SyntaxTreeRefGVarFopy(Expr expr)
{
    Obj result;
    GVar gvar;

    result = NewSyntaxTreeNode("RefGVarFopy", 2);
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("name"), NameGVarObj(gvar));

    return result;
}

Obj SyntaxTreeIsbGVar(Expr expr)
{
    Obj result;
    GVar gvar;

    result = NewSyntaxTreeNode("IsBGVar", 2);
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("name"), NameGVarObj(gvar));

    return result;
}

Obj SyntaxTreeElmList(Expr expr)
{
    Obj result;
    Obj list;
    Obj pos;

    result = NewSyntaxTreeNode("ElmList", 3);

    list = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    pos = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);

    return result;
}

Obj SyntaxTreeElmsList(Expr expr)
{
    Obj result;
    Obj list;
    Obj poss;

    result = NewSyntaxTreeNode("ElmsList", 3);

    list = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    poss = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("poss"), poss);

    return result;
}

/* TODO: What is ElmListLev? */
Obj SyntaxTreeElmListLev(Expr expr)
{
    Obj result;

    Obj lists;
    Obj pos;
    Obj level;

    result = NewSyntaxTreeNode("ElmListLev", 3);

    lists = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    pos = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );
    level = INTOBJ_INT((Int)(ADDR_EXPR(expr)[2]));

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("pos"), pos);
    AssPRec(result, RNamName("level"), level);

    return result;
}

Obj SyntaxTreeElmsListLev(Expr expr)
{
    Obj result;
    Obj lists;
    Obj poss;
    Obj level;

    result = NewSyntaxTreeNode("ElmsListLev", 3);

    lists = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    poss = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );
    level = INTOBJ_INT((Int)(ADDR_EXPR(expr)[2]));

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("poss"), poss);
    AssPRec(result, RNamName("level"), level);

    return result;
}

Obj SyntaxTreeIsbList(Expr expr)
{
    Obj result;
    Obj list;
    Obj pos;

    result = NewSyntaxTreeNode("IsBList",2);

    list = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    pos = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);

    return result;
}

Obj SyntaxTreeElmRecName(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("ElmRecName", 2);

    record = SyntaxTreeExpr(ADDR_EXPR(expr)[0]);
    rnam = SyntaxTreeExpr(ADDR_EXPR(expr)[1]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeElmRecExpr(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("ElmRecExpr", 2);

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeIsbRecName(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("IsBRecName", 2);

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeIsbRecExpr(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("IsBRecExpr", 2);

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeElmPosObj(Expr expr)
{
    Obj result;
    Obj list;
    Obj pos;

    result = NewSyntaxTreeNode("ElmPosObj", 2);

    list = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    pos = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);

    return result;
}

Obj SyntaxTreeElmsPosObj(Expr expr)
{
    Obj result;
    Obj list;
    Obj poss;

    result = NewSyntaxTreeNode("ElmsPosObj", 2);

    list = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    poss = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("poss"), poss);

    return result;
}

Obj SyntaxTreeElmPosObjLev(Expr expr)
{
    Obj result;

    Obj lists;
    Obj pos;
    Obj level;

    result = NewSyntaxTreeNode("ElmPosObjLev", 3);

    lists = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    pos = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );
    level = INTOBJ_INT((Int)(ADDR_EXPR(expr)[2]));

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("pos"), pos);
    AssPRec(result, RNamName("level"), level);

    return result;
}

Obj SyntaxTreeElmsPosObjLev(Expr expr)
{
    Obj result;
    Obj lists;
    Obj poss;
    Obj level;

    result = NewSyntaxTreeNode("PosObjLev", 3);

    lists = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    poss = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );
    level = INTOBJ_INT((Int)(ADDR_EXPR(expr)[2]));

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("poss"), poss);
    AssPRec(result, RNamName("level"), level);

    return result;
;
}

Obj SyntaxTreeIsbPosObj(Expr expr)
{
    Obj result;
    Obj list;
    Obj pos;

    result = NewSyntaxTreeNode("IsBPosObj", 2);

    list = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    pos = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);

    return result;
}

Obj SyntaxTreeElmComObjName(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("ElmComObjName", 3);

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr(ADDR_EXPR(expr)[1]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeElmComObjExpr(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("ElmComObjExpr", 3);

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeIsbComObjName(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("IsBComObjName", 3);

    record = SyntaxTreeExpr(ADDR_EXPR(expr)[0]);
    rnam = SyntaxTreeExpr(ADDR_EXPR(expr)[1]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeIsbComObjExpr(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("IsBComObjExpr", 3);

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj (* SyntaxTreeStatFuncs[256])(Stat stat);

Obj SyntaxTreeStat( Stat stat )
{
    return (* SyntaxTreeStatFuncs[ TNUM_STAT(stat) ])( stat );
}

Obj SyntaxTreeUnknownStat(Stat stat)
{
    return NewSyntaxTreeNode("UnknownStat",1);
}

/* TODO: Options? */
Obj SyntaxTreeProccall(Stat stat)
{
    Obj result;
    Obj args;
    Obj func;
    UInt narg;
    UInt i;

    result = NewSyntaxTreeNode("Proccall", 2);

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

    result = NewSyntaxTreeNode("ProccallOpts", 5);
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

    result = NewSyntaxTreeNode("SeqStat", 2);

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
    Obj elif;
    Obj brelse;
    Obj branches;

    Int i, nr;

    result = NewSyntaxTreeNode("If", 3);

    nr = SIZE_STAT( stat ) / (2*sizeof(Stat));

    cond = SyntaxTreeBoolExpr( ADDR_STAT( stat )[0] );
    then = SyntaxTreeStat( ADDR_STAT( stat )[1] );

    AssPRec(result, RNamName("condition"), cond);
    AssPRec(result, RNamName("then"), then);

    branches = NEW_PLIST(T_PLIST, nr-1);
    SET_LEN_PLIST(branches, nr-1);
    AssPRec(result, RNamName("branches"), branches);

    for ( i = 2; i <= nr; i++ ) {

        elif = NewSyntaxTreeNode("elif", 3);

        if ( i == nr && TNUM_EXPR(ADDR_STAT(stat)[2*(i-1)]) == T_TRUE_EXPR )
            break;

        cond = SyntaxTreeBoolExpr( ADDR_STAT( stat )[2*(i-1)] );
        then = SyntaxTreeStat( ADDR_STAT( stat )[2*(i-1)+1] );
        AssPRec(elif, RNamName("condition"), cond);
        AssPRec(elif, RNamName("then"), then);
        SET_ELM_PLIST(branches, i - 1, elif);
        CHANGED_BAG(branches);
    }

    /* handle 'else' branch                                                */
    if ( i == nr ) {
        brelse = SyntaxTreeStat( ADDR_STAT( stat )[2*(i-1)+1] );
        AssPRec(result, RNamName("else"), brelse);
    }

    return result;
}

Obj SyntaxTreeFor(Stat stat)
{
    Obj result;
    Obj body;
    UInt i, nr;

    result = NewSyntaxTreeNode("For", 4);

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

    result = NewSyntaxTreeNode("While", 3);

    condition = SyntaxTreeBoolExpr( ADDR_STAT(stat)[0] );
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

    result = NewSyntaxTreeNode("Repeat", 4);

    cond = SyntaxTreeBoolExpr( ADDR_STAT(stat)[0] );
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
    return NewSyntaxTreeNode("Break",1);
}

Obj SyntaxTreeContinue(Stat stat)
{
    return NewSyntaxTreeNode("Continue", 1);
}

Obj SyntaxTreeReturnObj(Stat stat)
{
    Obj result;
    Obj obj;

    result = NewSyntaxTreeNode("Return", 2);
    obj = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    AssPRec(result, RNamName("obj"), obj);

    return result;
}

Obj SyntaxTreeReturnVoid(Stat stat)
{
    Obj result;
    result = NewSyntaxTreeNode("Return", 1);
    return result;
}

/* TODO: make sure this works correctly */
Obj SyntaxTreeAssLVar(Stat stat)
{
    Obj result;
    Obj lvar;
    Obj rhs;

    result = NewSyntaxTreeNode("AssLVar", 2);

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

    result = NewSyntaxTreeNode("UnbindLVar", 2);

    lvar = INTOBJ_INT(ADDR_STAT(stat)[0]);
    AssPRec(result, RNamName("lvar"), lvar);

    return result;
}

Obj SyntaxTreeAssHVar(Stat stat)
{
    Obj result;
    Obj hvar;
    Obj rhs;

    result = NewSyntaxTreeNode("AssHVar", 2);

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

    result = NewSyntaxTreeNode("UnbindHVar", 2);

    hvar = INTOBJ_INT(ADDR_STAT(stat)[0]);
    AssPRec(result, RNamName("hvar"), hvar);

    return result;
}

Obj SyntaxTreeAssGVar(Stat stat)
{
    Obj result;
    Obj gvar;
    Obj rhs;

    result = NewSyntaxTreeNode("AssGVar", 2);

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

    result = NewSyntaxTreeNode("UnbGVar", 2);

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

    result = NewSyntaxTreeNode("AssList", 2);

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

    result = NewSyntaxTreeNode("AsssList", 3);

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

    result = NewSyntaxTreeNode("AssListLev", 3);

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

    result = NewSyntaxTreeNode("AsssListLev", 3);

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

    result = NewSyntaxTreeNode("UnbList", 3);

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

    result = NewSyntaxTreeNode("AssRecName", 4);

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

    result = NewSyntaxTreeNode("AssRecExpr", 4);

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

    result = NewSyntaxTreeNode("UnbRecName", 4);

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

    result = NewSyntaxTreeNode("UnbRecExpr", 4);

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

    result = NewSyntaxTreeNode("AssPosObj", 4);

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

    result = NewSyntaxTreeNode("AsssPosObj", 4);

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

    result = NewSyntaxTreeNode("AssPosObjLev", 3);

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

    result = NewSyntaxTreeNode("AsssPosObjLev", 3);

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

    result = NewSyntaxTreeNode("UnbPosObj", 4);
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

    result = NewSyntaxTreeNode("AssComObjName", 4);

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

    result = NewSyntaxTreeNode("AssComObjExpr", 4);

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

    result = NewSyntaxTreeNode("UnbComObjName", 4);

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

    result = NewSyntaxTreeNode("UnbComObjExpr", 4);

    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    rnam = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeEmpty(Stat stat)
{
    Obj result;

    result = NewSyntaxTreeNode("Empty",1);

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

    result = NewSyntaxTreeNode("Info", 4);

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

    result = NewSyntaxTreeNode("Assert", 4);

    lev = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    cond = SyntaxTreeBoolExpr( ADDR_STAT(stat)[1] );

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

    result = NewSyntaxTreeNode("Assert", 4);

    lev = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    cond = SyntaxTreeBoolExpr( ADDR_STAT(stat)[1] );
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

    result = NewSyntaxTreeNode("Function", 5);

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

Obj FuncSYNTAX_TREE ( Obj self, Obj func )
{
    return SyntaxTreeFunc(func);
}

static StructGVarFunc GVarFuncs [] = {
    { "SYNTAX_TREE", 1, "func",
      FuncSYNTAX_TREE, "src/syntaxtree.c:SYNTAX_TREE" },

    { 0 }

};

static Int InitKernel (
    StructInitInfo *    module )
{
    Int                 i;              /* loop variable                   */

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* announce the global variables                                       */
    /*
    InitGlobalBag( &SyntaxTreeGVar,  "src/compiler.c:SyntaxTreeInfoGVar"  );
    InitGlobalBag( &SyntaxTreeRNam,  "src/compiler.c:SyntaxTreeInfoRNam"  );
    InitGlobalBag( &SyntaxTreeFunctions, "src/compiler.c:SyntaxTreeFunctions" );
    */

    /* enter the expression compilers into the table                       */
    for ( i = 0; i < 256; i++ ) {
        SyntaxTreeExprFuncs[ i ] = SyntaxTreeUnknownExpr;
    }

    SyntaxTreeExprFuncs[ T_FUNCCALL_0ARGS  ] = SyntaxTreeFunccall;
    SyntaxTreeExprFuncs[ T_FUNCCALL_1ARGS  ] = SyntaxTreeFunccall;
    SyntaxTreeExprFuncs[ T_FUNCCALL_2ARGS  ] = SyntaxTreeFunccall;
    SyntaxTreeExprFuncs[ T_FUNCCALL_3ARGS  ] = SyntaxTreeFunccall;
    SyntaxTreeExprFuncs[ T_FUNCCALL_4ARGS  ] = SyntaxTreeFunccall;
    SyntaxTreeExprFuncs[ T_FUNCCALL_5ARGS  ] = SyntaxTreeFunccall;
    SyntaxTreeExprFuncs[ T_FUNCCALL_6ARGS  ] = SyntaxTreeFunccall;
    SyntaxTreeExprFuncs[ T_FUNCCALL_XARGS  ] = SyntaxTreeFunccall;
    SyntaxTreeExprFuncs[ T_FUNC_EXPR       ] = SyntaxTreeFuncExpr;

    SyntaxTreeExprFuncs[ T_OR              ] = SyntaxTreeOr;
    SyntaxTreeExprFuncs[ T_AND             ] = SyntaxTreeAnd;
    SyntaxTreeExprFuncs[ T_NOT             ] = SyntaxTreeNot;
    SyntaxTreeExprFuncs[ T_EQ              ] = SyntaxTreeEq;
    SyntaxTreeExprFuncs[ T_NE              ] = SyntaxTreeNe;
    SyntaxTreeExprFuncs[ T_LT              ] = SyntaxTreeLt;
    SyntaxTreeExprFuncs[ T_GE              ] = SyntaxTreeGe;
    SyntaxTreeExprFuncs[ T_GT              ] = SyntaxTreeGt;
    SyntaxTreeExprFuncs[ T_LE              ] = SyntaxTreeLe;
    SyntaxTreeExprFuncs[ T_IN              ] = SyntaxTreeIn;

    SyntaxTreeExprFuncs[ T_SUM             ] = SyntaxTreeSum;
    SyntaxTreeExprFuncs[ T_AINV            ] = SyntaxTreeAInv;
    SyntaxTreeExprFuncs[ T_DIFF            ] = SyntaxTreeDiff;
    SyntaxTreeExprFuncs[ T_PROD            ] = SyntaxTreeProd;
    SyntaxTreeExprFuncs[ T_INV             ] = SyntaxTreeInv;
    SyntaxTreeExprFuncs[ T_QUO             ] = SyntaxTreeQuo;
    SyntaxTreeExprFuncs[ T_MOD             ] = SyntaxTreeMod;
    SyntaxTreeExprFuncs[ T_POW             ] = SyntaxTreePow;

    SyntaxTreeExprFuncs[ T_INTEXPR         ] = SyntaxTreeIntExpr;
    SyntaxTreeExprFuncs[ T_INT_EXPR        ] = SyntaxTreeIntExpr;
    SyntaxTreeExprFuncs[ T_TRUE_EXPR       ] = SyntaxTreeTrueExpr;
    SyntaxTreeExprFuncs[ T_FALSE_EXPR      ] = SyntaxTreeFalseExpr;
    SyntaxTreeExprFuncs[ T_CHAR_EXPR       ] = SyntaxTreeCharExpr;
    SyntaxTreeExprFuncs[ T_PERM_EXPR       ] = SyntaxTreePermExpr;
    SyntaxTreeExprFuncs[ T_PERM_CYCLE      ] = SyntaxTreeUnknownExpr;
    SyntaxTreeExprFuncs[ T_LIST_EXPR       ] = SyntaxTreeListExpr;
    SyntaxTreeExprFuncs[ T_LIST_TILD_EXPR  ] = SyntaxTreeListTildeExpr;
    SyntaxTreeExprFuncs[ T_RANGE_EXPR      ] = SyntaxTreeRangeExpr;
    SyntaxTreeExprFuncs[ T_STRING_EXPR     ] = SyntaxTreeStringExpr;
    SyntaxTreeExprFuncs[ T_REC_EXPR        ] = SyntaxTreeRecExpr;
    SyntaxTreeExprFuncs[ T_REC_TILD_EXPR   ] = SyntaxTreeRecTildeExpr;

    SyntaxTreeExprFuncs[ T_REFLVAR         ] = SyntaxTreeRefLVar;
    SyntaxTreeExprFuncs[ T_ISB_LVAR        ] = SyntaxTreeIsbLVar;
    SyntaxTreeExprFuncs[ T_REF_HVAR        ] = SyntaxTreeRefHVar;
    SyntaxTreeExprFuncs[ T_ISB_HVAR        ] = SyntaxTreeIsbHVar;
    SyntaxTreeExprFuncs[ T_REF_GVAR        ] = SyntaxTreeRefGVar;
    SyntaxTreeExprFuncs[ T_ISB_GVAR        ] = SyntaxTreeIsbGVar;

    SyntaxTreeExprFuncs[ T_ELM_LIST        ] = SyntaxTreeElmList;
    SyntaxTreeExprFuncs[ T_ELMS_LIST       ] = SyntaxTreeElmsList;
    SyntaxTreeExprFuncs[ T_ELM_LIST_LEV    ] = SyntaxTreeElmListLev;
    SyntaxTreeExprFuncs[ T_ELMS_LIST_LEV   ] = SyntaxTreeElmsListLev;
    SyntaxTreeExprFuncs[ T_ISB_LIST        ] = SyntaxTreeIsbList;
    SyntaxTreeExprFuncs[ T_ELM_REC_NAME    ] = SyntaxTreeElmRecName;
    SyntaxTreeExprFuncs[ T_ELM_REC_EXPR    ] = SyntaxTreeElmRecExpr;
    SyntaxTreeExprFuncs[ T_ISB_REC_NAME    ] = SyntaxTreeIsbRecName;
    SyntaxTreeExprFuncs[ T_ISB_REC_EXPR    ] = SyntaxTreeIsbRecExpr;

    SyntaxTreeExprFuncs[ T_ELM_POSOBJ      ] = SyntaxTreeElmPosObj;
    SyntaxTreeExprFuncs[ T_ELMS_POSOBJ     ] = SyntaxTreeElmsPosObj;
    SyntaxTreeExprFuncs[ T_ELM_POSOBJ_LEV  ] = SyntaxTreeElmPosObjLev;
    SyntaxTreeExprFuncs[ T_ELMS_POSOBJ_LEV ] = SyntaxTreeElmsPosObjLev;
    SyntaxTreeExprFuncs[ T_ISB_POSOBJ      ] = SyntaxTreeIsbPosObj;
    SyntaxTreeExprFuncs[ T_ELM_COMOBJ_NAME ] = SyntaxTreeElmComObjName;
    SyntaxTreeExprFuncs[ T_ELM_COMOBJ_EXPR ] = SyntaxTreeElmComObjExpr;
    SyntaxTreeExprFuncs[ T_ISB_COMOBJ_NAME ] = SyntaxTreeIsbComObjName;
    SyntaxTreeExprFuncs[ T_ISB_COMOBJ_EXPR ] = SyntaxTreeIsbComObjExpr;

    SyntaxTreeExprFuncs[ T_FUNCCALL_OPTS   ] = SyntaxTreeFunccallOpts;

    /* enter the boolean expression compilers into the table               */
    for ( i = 0; i < 256; i++ ) {
        SyntaxTreeBoolExprFuncs[ i ] = SyntaxTreeUnknownBool;
    }

    SyntaxTreeBoolExprFuncs[ T_OR              ] = SyntaxTreeOr;
    SyntaxTreeBoolExprFuncs[ T_AND             ] = SyntaxTreeAnd;
    SyntaxTreeBoolExprFuncs[ T_NOT             ] = SyntaxTreeNot;
    SyntaxTreeBoolExprFuncs[ T_EQ              ] = SyntaxTreeEq;
    SyntaxTreeBoolExprFuncs[ T_NE              ] = SyntaxTreeNe;
    SyntaxTreeBoolExprFuncs[ T_LT              ] = SyntaxTreeLt;
    SyntaxTreeBoolExprFuncs[ T_GE              ] = SyntaxTreeGe;
    SyntaxTreeBoolExprFuncs[ T_GT              ] = SyntaxTreeGt;
    SyntaxTreeBoolExprFuncs[ T_LE              ] = SyntaxTreeLe;
    SyntaxTreeBoolExprFuncs[ T_IN              ] = SyntaxTreeIn;

    /* enter the statement compilers into the table                        */
    for ( i = 0; i < 256; i++ ) {
        SyntaxTreeStatFuncs[ i ] = SyntaxTreeUnknownStat;
    }

    SyntaxTreeStatFuncs[ T_PROCCALL_0ARGS  ] = SyntaxTreeProccall;
    SyntaxTreeStatFuncs[ T_PROCCALL_1ARGS  ] = SyntaxTreeProccall;
    SyntaxTreeStatFuncs[ T_PROCCALL_2ARGS  ] = SyntaxTreeProccall;
    SyntaxTreeStatFuncs[ T_PROCCALL_3ARGS  ] = SyntaxTreeProccall;
    SyntaxTreeStatFuncs[ T_PROCCALL_4ARGS  ] = SyntaxTreeProccall;
    SyntaxTreeStatFuncs[ T_PROCCALL_5ARGS  ] = SyntaxTreeProccall;
    SyntaxTreeStatFuncs[ T_PROCCALL_6ARGS  ] = SyntaxTreeProccall;
    SyntaxTreeStatFuncs[ T_PROCCALL_XARGS  ] = SyntaxTreeProccall;

    SyntaxTreeStatFuncs[ T_SEQ_STAT        ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT2       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT3       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT4       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT5       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT6       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT7       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_IF              ] = SyntaxTreeIf;
    SyntaxTreeStatFuncs[ T_IF_ELSE         ] = SyntaxTreeIf;
    SyntaxTreeStatFuncs[ T_IF_ELIF         ] = SyntaxTreeIf;
    SyntaxTreeStatFuncs[ T_IF_ELIF_ELSE    ] = SyntaxTreeIf;
    SyntaxTreeStatFuncs[ T_FOR             ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_FOR2            ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_FOR3            ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_FOR_RANGE       ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_FOR_RANGE2      ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_FOR_RANGE3      ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_WHILE           ] = SyntaxTreeWhile;
    SyntaxTreeStatFuncs[ T_WHILE2          ] = SyntaxTreeWhile;
    SyntaxTreeStatFuncs[ T_WHILE3          ] = SyntaxTreeWhile;
    SyntaxTreeStatFuncs[ T_REPEAT          ] = SyntaxTreeRepeat;
    SyntaxTreeStatFuncs[ T_REPEAT2         ] = SyntaxTreeRepeat;
    SyntaxTreeStatFuncs[ T_REPEAT3         ] = SyntaxTreeRepeat;
    SyntaxTreeStatFuncs[ T_BREAK           ] = SyntaxTreeBreak;
    SyntaxTreeStatFuncs[ T_CONTINUE        ] = SyntaxTreeContinue;
    SyntaxTreeStatFuncs[ T_RETURN_OBJ      ] = SyntaxTreeReturnObj;
    SyntaxTreeStatFuncs[ T_RETURN_VOID     ] = SyntaxTreeReturnVoid;

    SyntaxTreeStatFuncs[ T_ASS_LVAR        ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_01     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_02     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_03     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_04     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_05     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_06     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_07     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_08     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_09     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_10     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_11     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_12     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_13     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_14     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_15     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_16     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_UNB_LVAR        ] = SyntaxTreeUnbLVar;
    SyntaxTreeStatFuncs[ T_ASS_HVAR        ] = SyntaxTreeAssHVar;
    SyntaxTreeStatFuncs[ T_UNB_HVAR        ] = SyntaxTreeUnbHVar;
    SyntaxTreeStatFuncs[ T_ASS_GVAR        ] = SyntaxTreeAssGVar;
    SyntaxTreeStatFuncs[ T_UNB_GVAR        ] = SyntaxTreeUnbGVar;

    SyntaxTreeStatFuncs[ T_ASS_LIST        ] = SyntaxTreeAssList;
    SyntaxTreeStatFuncs[ T_ASSS_LIST       ] = SyntaxTreeAsssList;
    SyntaxTreeStatFuncs[ T_ASS_LIST_LEV    ] = SyntaxTreeAssListLev;
    SyntaxTreeStatFuncs[ T_ASSS_LIST_LEV   ] = SyntaxTreeAsssListLev;
    SyntaxTreeStatFuncs[ T_UNB_LIST        ] = SyntaxTreeUnbList;
    SyntaxTreeStatFuncs[ T_ASS_REC_NAME    ] = SyntaxTreeAssRecName;
    SyntaxTreeStatFuncs[ T_ASS_REC_EXPR    ] = SyntaxTreeAssRecExpr;
    SyntaxTreeStatFuncs[ T_UNB_REC_NAME    ] = SyntaxTreeUnbRecName;
    SyntaxTreeStatFuncs[ T_UNB_REC_EXPR    ] = SyntaxTreeUnbRecExpr;

    SyntaxTreeStatFuncs[ T_ASS_POSOBJ      ] = SyntaxTreeAssPosObj;
    SyntaxTreeStatFuncs[ T_ASSS_POSOBJ     ] = SyntaxTreeAsssPosObj;
    SyntaxTreeStatFuncs[ T_ASS_POSOBJ_LEV  ] = SyntaxTreeAssPosObjLev;
    SyntaxTreeStatFuncs[ T_ASSS_POSOBJ_LEV ] = SyntaxTreeAsssPosObjLev;
    SyntaxTreeStatFuncs[ T_UNB_POSOBJ      ] = SyntaxTreeUnbPosObj;
    SyntaxTreeStatFuncs[ T_ASS_COMOBJ_NAME ] = SyntaxTreeAssComObjName;
    SyntaxTreeStatFuncs[ T_ASS_COMOBJ_EXPR ] = SyntaxTreeAssComObjExpr;
    SyntaxTreeStatFuncs[ T_UNB_COMOBJ_NAME ] = SyntaxTreeUnbComObjName;
    SyntaxTreeStatFuncs[ T_UNB_COMOBJ_EXPR ] = SyntaxTreeUnbComObjExpr;

    SyntaxTreeStatFuncs[ T_INFO            ] = SyntaxTreeInfo;
    SyntaxTreeStatFuncs[ T_ASSERT_2ARGS    ] = SyntaxTreeAssert2;
    SyntaxTreeStatFuncs[ T_ASSERT_3ARGS    ] = SyntaxTreeAssert3;
    SyntaxTreeStatFuncs[ T_EMPTY           ] = SyntaxTreeEmpty;

    SyntaxTreeStatFuncs[ T_PROCCALL_OPTS   ] = SyntaxTreeProccallOpts;

    return 0;
}

static Int PostRestore (
    StructInitInfo *    module )
{
    return 0;
}

static Int InitLibrary (
    StructInitInfo *    module )
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


/****************************************************************************
**
*E  compiler.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
