/****************************************************************************
**
*W  code.h                      GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the coder package.
**
**  The  coder package  is   the part of   the interpreter  that creates  the
**  expressions.  Its functions are called from the reader.
*/

#ifndef GAP_CODE_H
#define GAP_CODE_H


/****************************************************************************
**
*T  Stat  . . . . . . . . . . . . . . . . . . . . . . . .  type of statements
**
**  'Stat' is the type of statements.
**
**  If 'Stat' is different  from 'Expr', then  a lot of things will  probably
**  break.
*/
typedef UInt8 Stat;


/****************************************************************************
**
*V  PtrBody . . . . . . . . . . . . . . . . . . . . . pointer to current body
**
**  'PtrBody' is a pointer to the current body.
*/
/* TL: extern  Stat *          PtrBody; */


/****************************************************************************
**
** Function headers
**
** 'FILENAME_BODY' is a string containing the file of a function
** 'STARTLINE_BODY' is the line number where a function starts.
** 'ENDLINE_BODY' is the line number where a function ends.
** 'LOCATION_BODY' is a string describing the location of a function.
**  Typically this will be the name of a C function implementing it.
**
**  These each have a 'GET' and a 'SET' variant, to read or set the value.
**  Note that STARTLINE_BODY and LOCATION_BODY are stored in the same place,
**  so writing one will overwrite the other.
**
**  All of these variables may be 0, if the information is not known,
*/

Obj GET_FILENAME_BODY(Obj body);
void SET_FILENAME_BODY(Obj body, Obj val);
Obj GET_STARTLINE_BODY(Obj body);
void SET_STARTLINE_BODY(Obj body, Obj val);
Obj GET_LOCATION_BODY(Obj body);
void SET_LOCATION_BODY(Obj body, Obj val);
Obj GET_ENDLINE_BODY(Obj body);
void SET_ENDLINE_BODY(Obj body, Obj val);

#define NUMBER_HEADER_ITEMS_BODY 3

/****************************************************************************
**
*V  FIRST_STAT_CURR_FUNC  . . . . . . . .  index of first statement in a body
**
**  'FIRST_STAT_CURR_FUNC' is the index of the first statement in a body.
*/

#define FIRST_STAT_CURR_FUNC    (sizeof(Stat)+NUMBER_HEADER_ITEMS_BODY*sizeof(Bag))

/****************************************************************************
**
*S  T_<name>  . . . . . . . . . . . . . .  symbolic names for statement types
*S  FIRST_STAT_TNUM . . . . . . . . . . . . . . . . . .  first statement type
*S  LAST_STAT_TNUM  . . . . . . . . . . . . . . . . . . . last statement type
**
**  For every type  of statements there is  a symbolic name  defined for this
**  type.
**
**  As long as statements   are represented by  bags,  these types  must  not
**  overlap with the object types, lest Gasman becomes confused.
*/
#define FIRST_STAT_TNUM         (0UL)

#define T_PROCCALL_0ARGS        (FIRST_STAT_TNUM+ 0)
#define T_PROCCALL_1ARGS        (FIRST_STAT_TNUM+ 1)
#define T_PROCCALL_2ARGS        (FIRST_STAT_TNUM+ 2)
#define T_PROCCALL_3ARGS        (FIRST_STAT_TNUM+ 3)
#define T_PROCCALL_4ARGS        (FIRST_STAT_TNUM+ 4)
#define T_PROCCALL_5ARGS        (FIRST_STAT_TNUM+ 5)
#define T_PROCCALL_6ARGS        (FIRST_STAT_TNUM+ 6)
#define T_PROCCALL_XARGS        (FIRST_STAT_TNUM+ 7)

#define T_SEQ_STAT              (FIRST_STAT_TNUM+ 8)
#define T_SEQ_STAT2             (FIRST_STAT_TNUM+ 9)
#define T_SEQ_STAT3             (FIRST_STAT_TNUM+10)
#define T_SEQ_STAT4             (FIRST_STAT_TNUM+11)
#define T_SEQ_STAT5             (FIRST_STAT_TNUM+12)
#define T_SEQ_STAT6             (FIRST_STAT_TNUM+13)
#define T_SEQ_STAT7             (FIRST_STAT_TNUM+14)
#define T_IF                    (FIRST_STAT_TNUM+15)
#define T_IF_ELSE               (FIRST_STAT_TNUM+16)
#define T_IF_ELIF               (FIRST_STAT_TNUM+17)
#define T_IF_ELIF_ELSE          (FIRST_STAT_TNUM+18)
#define T_FOR                   (FIRST_STAT_TNUM+19)
#define T_FOR2                  (FIRST_STAT_TNUM+20)
#define T_FOR3                  (FIRST_STAT_TNUM+21)
#define T_FOR_RANGE             (FIRST_STAT_TNUM+22)
#define T_FOR_RANGE2            (FIRST_STAT_TNUM+23)
#define T_FOR_RANGE3            (FIRST_STAT_TNUM+24)
#define T_WHILE                 (FIRST_STAT_TNUM+25)
#define T_WHILE2                (FIRST_STAT_TNUM+26)
#define T_WHILE3                (FIRST_STAT_TNUM+27)
#define T_REPEAT                (FIRST_STAT_TNUM+28)
#define T_REPEAT2               (FIRST_STAT_TNUM+29)
#define T_REPEAT3               (FIRST_STAT_TNUM+30)
#define T_BREAK                 (FIRST_STAT_TNUM+31)
#define T_CONTINUE              (FIRST_STAT_TNUM+32)
#define T_RETURN_OBJ            (FIRST_STAT_TNUM+33)
#define T_RETURN_VOID           (FIRST_STAT_TNUM+34)

#define T_ASS_LVAR              (FIRST_STAT_TNUM+35)
#define T_ASS_LVAR_01           (FIRST_STAT_TNUM+36)
#define T_ASS_LVAR_02           (FIRST_STAT_TNUM+37)
#define T_ASS_LVAR_03           (FIRST_STAT_TNUM+38)
#define T_ASS_LVAR_04           (FIRST_STAT_TNUM+39)
#define T_ASS_LVAR_05           (FIRST_STAT_TNUM+40)
#define T_ASS_LVAR_06           (FIRST_STAT_TNUM+41)
#define T_ASS_LVAR_07           (FIRST_STAT_TNUM+42)
#define T_ASS_LVAR_08           (FIRST_STAT_TNUM+43)
#define T_ASS_LVAR_09           (FIRST_STAT_TNUM+44)
#define T_ASS_LVAR_10           (FIRST_STAT_TNUM+45)
#define T_ASS_LVAR_11           (FIRST_STAT_TNUM+46)
#define T_ASS_LVAR_12           (FIRST_STAT_TNUM+47)
#define T_ASS_LVAR_13           (FIRST_STAT_TNUM+48)
#define T_ASS_LVAR_14           (FIRST_STAT_TNUM+49)
#define T_ASS_LVAR_15           (FIRST_STAT_TNUM+50)
#define T_ASS_LVAR_16           (FIRST_STAT_TNUM+51)
#define T_UNB_LVAR              (FIRST_STAT_TNUM+52)
#define T_ASS_HVAR              (FIRST_STAT_TNUM+53)
#define T_UNB_HVAR              (FIRST_STAT_TNUM+54)
#define T_ASS_GVAR              (FIRST_STAT_TNUM+55)
#define T_UNB_GVAR              (FIRST_STAT_TNUM+56)
#define T_ASS_LIST              (FIRST_STAT_TNUM+57)
#define T_ASSS_LIST             (FIRST_STAT_TNUM+58)
#define T_ASS_LIST_LEV          (FIRST_STAT_TNUM+59)
#define T_ASSS_LIST_LEV         (FIRST_STAT_TNUM+60)
#define T_UNB_LIST              (FIRST_STAT_TNUM+61)
#define T_ASS_REC_NAME          (FIRST_STAT_TNUM+62)
#define T_ASS_REC_EXPR          (FIRST_STAT_TNUM+63)
#define T_UNB_REC_NAME          (FIRST_STAT_TNUM+64)
#define T_UNB_REC_EXPR          (FIRST_STAT_TNUM+65)
#define T_ASS_POSOBJ            (FIRST_STAT_TNUM+66)
#define T_ASSS_POSOBJ           (FIRST_STAT_TNUM+67)
#define T_ASS_POSOBJ_LEV        (FIRST_STAT_TNUM+68)
#define T_ASSS_POSOBJ_LEV       (FIRST_STAT_TNUM+69)
#define T_UNB_POSOBJ            (FIRST_STAT_TNUM+70)
#define T_ASS_COMOBJ_NAME       (FIRST_STAT_TNUM+71)
#define T_ASS_COMOBJ_EXPR       (FIRST_STAT_TNUM+72)
#define T_UNB_COMOBJ_NAME       (FIRST_STAT_TNUM+73)
#define T_UNB_COMOBJ_EXPR       (FIRST_STAT_TNUM+74)

#define T_INFO                  (FIRST_STAT_TNUM+75)
#define T_ASSERT_2ARGS          (FIRST_STAT_TNUM+76)
#define T_ASSERT_3ARGS          (FIRST_STAT_TNUM+77)

#define T_EMPTY                 (FIRST_STAT_TNUM+78)

#define T_PROCCALL_OPTS         (FIRST_STAT_TNUM+ 79)

#define T_ATOMIC               (FIRST_STAT_TNUM+80)

#define LAST_STAT_TNUM          T_ATOMIC

#define T_NO_STAT		(Stat)(-1)


/****************************************************************************
**
*F  TNUM_STAT(<stat>) . . . . . . . . . . . . . . . . . . type of a statement
**
**  'TNUM_STAT' returns the type of the statement <stat>.
*/
#define TNUM_STAT(stat) ((Int)(ADDR_STAT(stat)[-1] & 0xFF))


/****************************************************************************
**
*F  SIZE_STAT(<stat>) . . . . . . . . . . . . . . . . . . size of a statement
**
**  'SIZE_STAT' returns the size of the statement <stat>.
*/
#define SIZE_STAT(stat) ((Int)(ADDR_STAT(stat)[-1] >> 8 & 0xFFFFFF))

/****************************************************************************
**
*F  LINE_STAT(<stat>) . . . . . . . . . . . . . . line number of a statement
**
**  'LINE_STAT' returns the line number of the statement <stat>.
*/
#define LINE_STAT(stat) ((Int)(ADDR_STAT(stat)[-1] >> 32 & 0xFFFF))

/****************************************************************************
**
*F  FILENAMEID_STAT(<stat>) . . . . . . . . . . . . file name of a statement
**
**  'FILENAMEID_STAT' returns the file the statment <stat> was read from.
**  This should be looked up in the FilenameCache variable
*/
#define FILENAMEID_STAT(stat) ((Int)(ADDR_STAT(stat)[-1] >> 48 & 0x7FFF))

/****************************************************************************
**
*F  FILENAME_STAT(<stat>) . . . . . . . . . . . . file name of a statement
**
**  'FILENAME_STAT' returns a gap string containing the file where the statment
**  <stat> was read from.
*/
Obj FILENAME_STAT(Stat stat);

/****************************************************************************
**
*F  VISITED_STAT(<stat>) . . . . . . . . . . . . if statement has even been run
**
**  'VISITED_STAT' returns true if the statement has ever been executed
**  while profiling is turned on.
*/
#define VISITED_STAT(stat) (ADDR_STAT(stat)[-1] >> 63 && 0x1)



/****************************************************************************
**
*F  ADDR_STAT(<stat>) . . . . . . . . . . . . absolute address of a statement
**
**  'ADDR_STAT' returns   the  absolute address of the    memory block of the
**  statement <stat>.
*/
#define ADDR_STAT(stat) ((Stat*)(((char*)STATE(PtrBody))+(stat)))


/****************************************************************************
**
*T  Expr  . . . . . . . . . . . . . . . . . . . . . . . . type of expressions
**
**  'Expr' is the type of expressions.
**
**  If 'Expr' is different  from 'Stat', then  a lot of things will  probably
**  break.
*/
typedef Stat Expr;


/****************************************************************************
**
*F  IS_REFLVAR(<expr>). . . . test if an expression is a reference to a local
*F  REFLVAR_LVAR(<lvar>)  . . . . . convert a local to a reference to a local
*F  LVAR_REFLVAR(<expr>)  . . . . . convert a reference to a local to a local
**
**  'IS_REFLVAR'  returns  1  if  the  expression <expr>  is  an  (immediate)
**  reference to a local variable, and 0 otherwise.
**
**  'REFLVAR_LVAR'  returns  a (immediate) reference  to   the local variable
**  <lvar> (given by its index).
**
**  'LVAR_REFLVAR' returns the local variable (by  its index) to which <expr>
**  is a (immediate) reference.
*/
#define IS_REFLVAR(expr)        \
                        (((Int)(expr) & 0x03) == 0x03)

#define REFLVAR_LVAR(lvar)      \
                        ((Expr)(((lvar) << 2) + 0x03))

#define LVAR_REFLVAR(expr)      \
                        ((Int)(expr) >> 2)


/****************************************************************************
**
*F  IS_INTEXPR(<expr>). . . .  test if an expression is an integer expression
*F  INTEXPR_INT(<i>)  . . . . .  convert a C integer to an integer expression
*F  INT_INTEXPR(<expr>) . . . .  convert an integer expression to a C integer
**
**  'IS_INTEXPR' returns 1 if the expression <expr> is an (immediate) integer
**  expression, and 0 otherwise.
**
**  'INTEXPR_INT' converts    the C integer <i>    to  an (immediate) integer
**  expression.
**
**  'INT_INTEXPR' converts the (immediate) integer  expression <expr> to a  C
**  integer.
*/
#define IS_INTEXPR(expr)        \
                        (((Int)(expr) & 0x03) == 0x01)

#define INTEXPR_INT(indx)       \
                        ((Expr)(((UInt)(indx) << 2) + 0x01))

#define INT_INTEXPR(expr)       \
                        (((Int)(expr)-0x01) >> 2)


/****************************************************************************
**
*S  T_<name>  . . . . . . . . . . . . . . symbolic names for expression types
*S  FIRST_EXPR_TNUM . . . . . . . . . . . . . . . . . . first expression type
*S  LAST_EXPR_TNUM  . . . . . . . . . . . . . . . . . .  last expression type
**
**  For every type of expressions there  is a symbolic  name defined for this
**  type.
**
**  As long as  expressions  are represented by  bags,  these types must  not
**  overlap with the object types, lest Gasman becomes confused.
*/
#define FIRST_EXPR_TNUM         ((UInt)128)

#define T_FUNCCALL_0ARGS        (FIRST_EXPR_TNUM+ 0)
#define T_FUNCCALL_1ARGS        (FIRST_EXPR_TNUM+ 1)
#define T_FUNCCALL_2ARGS        (FIRST_EXPR_TNUM+ 2)
#define T_FUNCCALL_3ARGS        (FIRST_EXPR_TNUM+ 3)
#define T_FUNCCALL_4ARGS        (FIRST_EXPR_TNUM+ 4)
#define T_FUNCCALL_5ARGS        (FIRST_EXPR_TNUM+ 5)
#define T_FUNCCALL_6ARGS        (FIRST_EXPR_TNUM+ 6)
#define T_FUNCCALL_XARGS        (FIRST_EXPR_TNUM+ 7)
#define T_FUNC_EXPR             (FIRST_EXPR_TNUM+ 8)

#define T_OR                    (FIRST_EXPR_TNUM+ 9)
#define T_AND                   (FIRST_EXPR_TNUM+10)
#define T_NOT                   (FIRST_EXPR_TNUM+11)
#define T_EQ                    (FIRST_EXPR_TNUM+12)
#define T_NE                    (FIRST_EXPR_TNUM+13)
#define T_LT                    (FIRST_EXPR_TNUM+14)
#define T_GE                    (FIRST_EXPR_TNUM+15)
#define T_GT                    (FIRST_EXPR_TNUM+16)
#define T_LE                    (FIRST_EXPR_TNUM+17)
#define T_IN                    (FIRST_EXPR_TNUM+18)
#define T_SUM                   (FIRST_EXPR_TNUM+19)
#define T_AINV                  (FIRST_EXPR_TNUM+20)
#define T_DIFF                  (FIRST_EXPR_TNUM+21)
#define T_PROD                  (FIRST_EXPR_TNUM+22)
#define T_INV                   (FIRST_EXPR_TNUM+23)
#define T_QUO                   (FIRST_EXPR_TNUM+24)
#define T_MOD                   (FIRST_EXPR_TNUM+25)
#define T_POW                   (FIRST_EXPR_TNUM+26)

#define T_INTEXPR               (FIRST_EXPR_TNUM+27)
#define T_INT_EXPR              (FIRST_EXPR_TNUM+28)
#define T_TRUE_EXPR             (FIRST_EXPR_TNUM+29)
#define T_FALSE_EXPR            (FIRST_EXPR_TNUM+30)
#define T_CHAR_EXPR             (FIRST_EXPR_TNUM+31)
#define T_PERM_EXPR             (FIRST_EXPR_TNUM+32)
#define T_PERM_CYCLE            (FIRST_EXPR_TNUM+33)
#define T_LIST_EXPR             (FIRST_EXPR_TNUM+34)
#define T_LIST_TILD_EXPR        (FIRST_EXPR_TNUM+35)
#define T_RANGE_EXPR            (FIRST_EXPR_TNUM+36)
#define T_STRING_EXPR           (FIRST_EXPR_TNUM+37)
#define T_REC_EXPR              (FIRST_EXPR_TNUM+38)
#define T_REC_TILD_EXPR         (FIRST_EXPR_TNUM+39)

#define T_REFLVAR               (FIRST_EXPR_TNUM+40)

#define T_ISB_LVAR              (FIRST_EXPR_TNUM+58)
#define T_REF_HVAR              (FIRST_EXPR_TNUM+59)
#define T_ISB_HVAR              (FIRST_EXPR_TNUM+60)
#define T_REF_GVAR              (FIRST_EXPR_TNUM+61)
#define T_ISB_GVAR              (FIRST_EXPR_TNUM+62)
#define T_ELM_LIST              (FIRST_EXPR_TNUM+63)
#define T_ELMS_LIST             (FIRST_EXPR_TNUM+64)
#define T_ELM_LIST_LEV          (FIRST_EXPR_TNUM+65)
#define T_ELMS_LIST_LEV         (FIRST_EXPR_TNUM+66)
#define T_ISB_LIST              (FIRST_EXPR_TNUM+67)
#define T_ELM_REC_NAME          (FIRST_EXPR_TNUM+68)
#define T_ELM_REC_EXPR          (FIRST_EXPR_TNUM+69)
#define T_ISB_REC_NAME          (FIRST_EXPR_TNUM+70)
#define T_ISB_REC_EXPR          (FIRST_EXPR_TNUM+71)
#define T_ELM_POSOBJ            (FIRST_EXPR_TNUM+72)
#define T_ELMS_POSOBJ           (FIRST_EXPR_TNUM+73)
#define T_ELM_POSOBJ_LEV        (FIRST_EXPR_TNUM+74)
#define T_ELMS_POSOBJ_LEV       (FIRST_EXPR_TNUM+75)
#define T_ISB_POSOBJ            (FIRST_EXPR_TNUM+76)
#define T_ELM_COMOBJ_NAME       (FIRST_EXPR_TNUM+77)
#define T_ELM_COMOBJ_EXPR       (FIRST_EXPR_TNUM+78)
#define T_ISB_COMOBJ_NAME       (FIRST_EXPR_TNUM+79)
#define T_ISB_COMOBJ_EXPR       (FIRST_EXPR_TNUM+80)

#define T_FUNCCALL_OPTS         (FIRST_EXPR_TNUM+81)
#define T_FLOAT_EXPR_EAGER      (FIRST_EXPR_TNUM+82)
#define T_FLOAT_EXPR_LAZY       (FIRST_EXPR_TNUM+83)

#define T_ELM2_LIST             (FIRST_EXPR_TNUM+84)
#define T_ELMX_LIST             (FIRST_EXPR_TNUM+85)
#define T_ASS2_LIST             (FIRST_EXPR_TNUM+86)
#define T_ASSX_LIST             (FIRST_EXPR_TNUM+87)

#define LAST_EXPR_TNUM          T_ASSX_LIST


/****************************************************************************
**
*F  TNUM_EXPR(<expr>) . . . . . . . . . . . . . . . . . type of an expression
**
**  'TNUM_EXPR' returns the type of the expression <expr>.
*/
#define TNUM_EXPR(expr)         \
                        (IS_REFLVAR( (expr) ) ? T_REFLVAR : \
                         (IS_INTEXPR( (expr) ) ? T_INTEXPR : \
                          TNUM_STAT(expr) ))


/****************************************************************************
**
*F  SIZE_EXPR(<expr>) . . . . . . . . . . . . . . . . . size of an expression
**
**  'SIZE_EXPR' returns the size of the expression <expr>.
**
**  Note  that  it is *fatal*  to apply  'SIZE_EXPR'   to expressions of type
**  'T_REFLVAR' or 'T_INTEXPR'.
*/
#define SIZE_EXPR(expr) SIZE_STAT(expr)


/****************************************************************************
**
*F  ADDR_EXPR(<expr>) . . . . . . . . . . . absolute address of an expression
**
**  'ADDR_EXPR' returns  the absolute  address  of  the memory  block of  the
**  expression <expr>.
**
**  Note  that  it is *fatal*  to apply  'ADDR_EXPR'   to expressions of type
**  'T_REFLVAR' or 'T_INTEXPR'.
*/
#define ADDR_EXPR(expr) ADDR_STAT(expr)


/****************************************************************************
**
*F  FUNC_CALL(<call>) . . . . . . . . . . . . .  function for a function call
*F  ARGI_CALL(<call>,<i>) . . . .  <i>-th formal argument for a function call
*F  NARG_SIZE_CALL(<size>)  . . . . . number of arguments for a function call
*F  SIZE_NARG_CALL(<narg>)  . . . . . . . size of the bag for a function call
**
**  'FUNC_CALL'  returns the expression that should  evaluate to the function
**  for the procedure or  function call <call>.   This is a legal left value,
**  so it can be used to set the expression too.
**
**  'ARGI_CALL'  returns  the expression that evaluate   to the <i>-th actual
**  argument for the procedure or function call <call>.  This is a legal left
**  value, so it can be used to set the expression too.
**
**  'NARG_SIZE_CALL' returns the number of  arguments in a function call from
**  the size <size> of the function call bag (as returned by 'SIZE_EXPR').
**
**  'SIZE_NARG_CALL' returns the size a  function call bag  should have for a
**  function call bag with <narg> arguments.
*/
#define FUNC_CALL(call)         (* (ADDR_EXPR((call)) +0     ) )
#define ARGI_CALL(call,i)       (* (ADDR_EXPR((call)) +0 +(i)) )
#define NARG_SIZE_CALL(size)    (((size) / sizeof(Expr)) - 1)
#define SIZE_NARG_CALL(narg)    (((narg) + 1) * sizeof(Expr))


/****************************************************************************
**
*F  ARGI_INFO(<info>,<i>) . . .  <i>-th formal argument for an Info statement
*F  NARG_SIZE_INFO(<size>)  . . . . number of arguments for an Info statement
*F  SIZE_NARG_INFO(<narg>)  . . . . . . size of the bag for an Info statement
**
**  'ARGI_INFO' returns the expression   that evaluates to the <i>-th  actual
**  argument for the Info  statement <info>.  This is a  legal left value, so
**  it can be used to set the expression too.
**
**  'NARG_SIZE_INFO' returns the number of  arguments in a function call from
**  the size <size> of the function call bag (as returned by 'SIZE_STAT').
**
**  'SIZE_NARG_INFO' returns the size a  function call bag  should have for a
**  function call bag with <narg> arguments.
*/
#define ARGI_INFO(info,i)       (* (ADDR_STAT((info))+(i) -1) )
#define NARG_SIZE_INFO(size)    ((size) / sizeof(Expr))
#define SIZE_NARG_INFO(narg)    ((narg) * sizeof(Expr))


/****************************************************************************
**
*V  CodeResult  . . . . . . . . . . . . . . . . . . . . . .  result of coding
**
**  'CodeResult'  is the result  of the coding, i.e.,   the function that was
**  coded.
*/
/* TL: extern  Obj             CodeResult; */


/****************************************************************************
**
*F  PushStat(<stat>)  . . . . . . . . . . . . . push statement onto the stack
*F  PopStat() . . . . . . . . . . . . . . . . .  pop statement from the stack
**
**  'StackStat' is the stack of statements that have been coded.
**
**  'CountStat'   is the number   of statements  currently on  the statements
**  stack.
**
**  'PushStat'  pushes the statement  <stat> onto the  statements stack.  The
**  stack is automatically resized if necessary.
**
**  'PopStat' returns the  top statement from the  statements  stack and pops
**  it.  It is an error if the stack is empty.
*/
extern void PushStat (
            Stat                stat );

extern Stat PopStat ( void );


/****************************************************************************
**

*F * * * * * * * * * * * * *  coder functions * * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  CodeBegin() . . . . . . . . . . . . . . . . . . . . . . . start the coder
*F  CodeEnd(<error>)  . . . . . . . . . . . . . . . . . . . .  stop the coder
**
**  'CodeBegin'  starts  the  coder.    It is   called  from  the   immediate
**  interpreter   when he encounters  a construct  that it cannot immediately
**  interpret.
**
**  'CodeEnd' stops the coder.  It  is called from the immediate  interpreter
**  when he is done with the construct  that it cannot immediately interpret.
**  If <error> is  non-zero, a syntax error  was detected by the  reader, and
**  the coder should only clean up.
**
**  ...only function expressions inbetween...
*/
extern  void            CodeBegin ( void );

extern  UInt            CodeEnd (
            UInt                error );


/****************************************************************************
**
*F  CodeFuncCallBegin() . . . . . . . . . . . . . . code function call, begin
*F  CodeFuncCallEnd(<funccall>,<options>, <nr>)  . code function call, end
**
**  'CodeFuncCallBegin'  is an action to code  a function call.  It is called
**  by the reader  when it encounters the parenthesis  '(', i.e., *after* the
**  function expression is read.
**
**  'CodeFuncCallEnd' is an action to code a  function call.  It is called by
**  the reader when  it  encounters the parenthesis  ')',  i.e.,  *after* the
**  argument expressions are read.   <funccall> is 1  if  this is a  function
**  call,  and 0  if  this  is  a procedure  call.    <nr> is the   number of
**  arguments. <options> is 1 if options were present after the ':' in which
**  case the options have been read already.
*/
extern  void            CodeFuncCallBegin ( void );

extern  void            CodeFuncCallEnd (
            UInt                funccall,
            UInt                options,
            UInt                nr );


/****************************************************************************
**
*F  CodeFuncExprBegin(<narg>,<nloc>,<nams>,<startline>) . code function expression, begin
*F  CodeFuncExprEnd(<nr>) . . . . . . . . . . . code function expression, end
**
**  'CodeFuncExprBegin'  is an action to code  a  function expression.  It is
**  called when the reader encounters the beginning of a function expression.
**  <narg> is the number of  arguments (-1 if the  function takes a  variable
**  number of arguments), <nloc> is the number of locals, <nams> is a list of
**  local variable names.
**
**  'CodeFuncExprEnd'  is an action to  code  a function  expression.  It  is
**  called when the reader encounters the end of a function expression.  <nr>
**  is the number of statements in the body of the function.
**
*/
extern void CodeFuncExprBegin (
            Int                 narg,
            Int                 nloc,
            Obj                 nams,
            Int startLine);

extern void CodeFuncExprEnd (
            UInt                nr,
            UInt                mapsto );

/****************************************************************************
**
*F  CodeFuncCallOptionsBegin() . . . . . . . . . . . . .  code options, begin
*F  CodeFuncCallOptionsBeginElmName(<rnam>). . .  code options, begin element
*F  CodeFuncCallOptionsBeginElmExpr() . .. . . . .code options, begin element
*F  CodeFuncCallOptionsEndElm() . . .. .  . . . . . code options, end element
*F  CodeFuncCallOptionsEndElmEmpty() .. .  . . . . .code options, end element
*F  CodeFuncCallOptionsEnd(<nr>)  . . . . . . . . . . . . . code options, end
**
**  The net effect of all of these is to leave a record expression on the stack
**  containing the options record. It will be picked up by
**  CodeFuncCallEnd()
**
*/
extern void            CodeFuncCallOptionsBegin ( void );


extern void            CodeFuncCallOptionsBeginElmName (
    UInt                rnam );

extern void            CodeFuncCallOptionsBeginElmExpr ( void );

extern void            CodeFuncCallOptionsEndElm ( void );


extern void            CodeFuncCallOptionsEndElmEmpty ( void );

extern void            CodeFuncCallOptionsEnd ( UInt nr );


/****************************************************************************
**
*F  CodeIfBegin() . . . . . . . . . . . code if-statement, begin of statement
*F  CodeIfElif()  . . . . . . . . . . code if-statement, begin of elif-branch
*F  CodeIfElse()  . . . . . . . . . . code if-statement, begin of else-branch
*F  CodeIfBeginBody() . . . . . . . . . . .  code if-statement, begin of body
*F  CodeIfEndBody(<nr>) . . . . . . . . . . .  code if-statement, end of body
*F  CodeIfEnd(<nr>) . . . . . . . . . . . code if-statement, end of statement
**
**  'CodeIfBegin' is an  action to code an  if-statement.  It is called  when
**  the reader encounters the 'if', i.e., *before* the condition is read.
**
**  'CodeIfElif' is an action to code an if-statement.  It is called when the
**  reader encounters an 'elif', i.e., *before* the condition is read.
**
**  'CodeIfElse' is an action to code an if-statement.  It is called when the
**  reader encounters an 'else'.
**
**  'CodeIfBeginBody' is  an action to   code an if-statement.  It  is called
**  when  the  reader encounters the beginning   of the statement  body of an
**  'if', 'elif', or 'else' branch, i.e., *after* the condition is read.
**
**  'CodeIfEndBody' is an action to code an if-statement.   It is called when
**  the reader encounters the end of the  statements body of an 'if', 'elif',
**  or 'else' branch.  <nr> is the number of statements in the body.
**
**  'CodeIfEnd' is an action to code an if-statement.  It  is called when the
**  reader encounters the end of the statement.   <nr> is the number of 'if',
**  'elif', or 'else' branches.
*/
extern  void            CodeIfBegin ( void );

extern  void            CodeIfElif ( void );

extern  void            CodeIfElse ( void );

extern  void            CodeIfBeginBody ( void );

extern  void            CodeIfEndBody (
            UInt                nr );

extern  void            CodeIfEnd (
            UInt                nr );


/****************************************************************************
**
*F  CodeForBegin()  . . . . . . . . .  code for-statement, begin of statement
*F  CodeForIn() . . . . . . . . . . . . . . . . code for-statement, 'in' read
*F  CodeForBeginBody()  . . . . . . . . . . code for-statement, begin of body
*F  CodeForEndBody(<nr>)  . . . . . . . . . . code for-statement, end of body
*F  CodeForEnd()  . . . . . . . . . . .  code for-statement, end of statement
**
**  'CodeForBegin' is  an action to code  a for-statement.  It is called when
**  the reader encounters the 'for', i.e., *before* the variable is read.
**
**  'CodeForIn' is an action to code a for-statement.  It  is called when the
**  reader encounters  the 'in',  i.e., *after*  the  variable  is  read, but
**  *before* the list expression is read.
**
**  'CodeForBeginBody'  is an action to  code a for-statement.   It is called
**  when   the reader encounters the beginning   of the statement body, i.e.,
**  *after* the list expression is read.
**
**  'CodeForEndBody' is an action to code a for-statement.  It is called when
**  the reader encounters the end of the statement  body.  <nr> is the number
**  of statements in the body.
**
**  'CodeForEnd' is an action to code a for-statement.  It is called when the
**  reader encounters  the end of   the  statement, i.e., immediately   after
**  'CodeForEndBody'.
*/
extern  void            CodeForBegin ( void );

extern  void            CodeForIn ( void );

extern  void            CodeForBeginBody ( void );

extern  void            CodeForEndBody (
            UInt                nr );

extern  void            CodeForEnd ( void );

/****************************************************************************
**
*F  CodeAtomicBegin()  . . . . . . .  code atomic-statement, begin of statement
*F  CodeAtomicBeginBody()  . . . . . . . . code atomic-statement, begin of body
*F  CodeAtomicEndBody( <nr> )  . . . . . . . code atomic-statement, end of body
*F  CodeAtomicEnd()  . . . . . . . . .  code atomic-statement, end of statement
**
**  'CodeAtomicBegin'  is an action to  code a atomic-statement.   It is called
**  when the  reader encounters the 'atomic',  i.e., *before* the condition is
**  read.
**
**  'CodeAtomicBeginBody'  is  an action   to code a  atomic-statement.   It is
**  called when  the reader encounters  the beginning  of the statement body,
**  i.e., *after* the condition is read.
**
**  'CodeAtomicEndBody' is an action to  code a atomic-statement.  It is called
**  when the reader encounters  the end of  the statement body.  <nr> is  the
**  number of statements in the body.
**
**  'CodeAtomicEnd' is an action to code a atomic-statement.  It is called when
**  the reader encounters  the end  of the  statement, i.e., immediate  after
**  'CodeAtomicEndBody'.
*/

void CodeAtomicBegin ( void );

void CodeAtomicBeginBody ( UInt nrexprs );

void CodeAtomicEndBody (
    UInt                nrstats );
void CodeAtomicEnd ( void );

/****************************************************************************
**
*F  CodeQualifiedExprBegin()  . . . code readonly/readwrite expression start
*F  CodeQualifiedExprEnd()  . . . . . code readonly/readwrite expression end
**
*/

void CodeQualifiedExprBegin(UInt qual);

void CodeQualifiedExprEnd( void );


/****************************************************************************
**
*F  CodeWhileBegin()  . . . . . . .  code while-statement, begin of statement
*F  CodeWhileBeginBody()  . . . . . . . . code while-statement, begin of body
*F  CodeWhileEndBody(<nr>)  . . . . . . . . code while-statement, end of body
*F  CodeWhileEnd()  . . . . . . . . .  code while-statement, end of statement
**
**  'CodeWhileBegin'  is an action to  code a while-statement.   It is called
**  when the  reader encounters the 'while',  i.e., *before* the condition is
**  read.
**
**  'CodeWhileBeginBody'  is  an action   to code a  while-statement.   It is
**  called when  the reader encounters  the beginning  of the statement body,
**  i.e., *after* the condition is read.
**
**  'CodeWhileEndBody' is an action to  code a while-statement.  It is called
**  when the reader encounters  the end of  the statement body.  <nr> is  the
**  number of statements in the body.
**
**  'CodeWhileEnd' is an action to code a while-statement.  It is called when
**  the reader encounters  the end  of the  statement, i.e., immediate  after
**  'CodeWhileEndBody'.
*/
extern  void            CodeWhileBegin ( void );

extern  void            CodeWhileBeginBody ( void );

extern  void            CodeWhileEndBody (
            UInt                nr );

extern  void            CodeWhileEnd ( void );


/****************************************************************************
**
*F  CodeRepeatBegin() . . . . . . . code repeat-statement, begin of statement
*F  CodeRepeatBeginBody() . . . . . . .  code repeat-statement, begin of body
*F  CodeRepeatEndBody(<nr>) . . . . . . .  code repeat-statement, end of body
*F  CodeRepeatEnd() . . . . . . . . . code repeat-statement, end of statement
**
**  'CodeRepeatBegin' is an action to code a  repeat-statement.  It is called
**  when the reader encounters the 'repeat'.
**
**  'CodeRepeatBeginBody' is an  action  to code  a  repeat-statement.  It is
**  called when the reader encounters  the  beginning of the statement  body,
**  i.e., immediately after 'CodeRepeatBegin'.
**
**  'CodeRepeatEndBody'   is an action  to code   a repeat-statement.  It  is
**  called when  the reader encounters the end  of  the statement body, i.e.,
**  *before* the condition is read.  <nr> is the  number of statements in the
**  body.
**
**  'CodeRepeatEnd' is an action to   code a repeat-statement.  It is  called
**  when  the reader encounters the end  of the statement,  i.e., *after* the
**  condition is read.
*/
extern  void            CodeRepeatBegin ( void );

extern  void            CodeRepeatBeginBody ( void );

extern  void            CodeRepeatEndBody (
            UInt                nr );

extern  void            CodeRepeatEnd ( void );


/****************************************************************************
**
*F  CodeBreak() . . . . . . . . . . . . . . . . . . . .  code break-statement
**
**  'CodeBreak' is the  action to code a  break-statement.  It is called when
**  the reader encounters a 'break;'.
*/
extern  void            CodeBreak ( void );


/****************************************************************************
**
*F  CodeReturnObj() . . . . . . . . . . . . . . . code return-value-statement
**
**  'CodeReturnObj' is the  action to code  a return-value-statement.  It  is
**  called when the reader encounters a 'return <expr>;', but *after* reading
**  the expression <expr>.
*/
extern  void            CodeReturnObj ( void );


/****************************************************************************
**
*F  CodeReturnVoid()  . . . . . . . . . . . . . .  code return-void-statement
**
**  'CodeReturnVoid' is the action  to  code a return-void-statement.   It is
**  called when the reader encounters a 'return;'.
*/
extern  void            CodeReturnVoid ( void );


/****************************************************************************
**
*F  CodeOr()  . . . . . . . . . . . . . . . . . . . . . .  code or-expression
*F  CodeAnd() . . . . . . . . . . . . . . . . . . . . . . code and-expression
*F  CodeNot() . . . . . . . . . . . . . . . . . . . . . . code not-expression
*F  CodeEq()  . . . . . . . . . . . . . . . . . . . . . . . code =-expression
*F  CodeNe()  . . . . . . . . . . . . . . . . . . . . . .  code <>-expression
*F  CodeLt()  . . . . . . . . . . . . . . . . . . . . . . . code <-expression
*F  CodeGe()  . . . . . . . . . . . . . . . . . . . . . .  code >=-expression
*F  CodeGt()  . . . . . . . . . . . . . . . . . . . . . . . code >-expression
*F  CodeLe()  . . . . . . . . . . . . . . . . . . . . . .  code <=-expression
*F  CodeIn()  . . . . . . . . . . . . . . . . . . . . . .  code in-expression
*F  CodeSum() . . . . . . . . . . . . . . . . . . . . . . . code +-expression
*F  CodeAInv()  . . . . . . . . . . . . . . . . . . . code unary --expression
*F  CodeDiff()  . . . . . . . . . . . . . . . . . . . . . . code --expression
*F  CodeProd()  . . . . . . . . . . . . . . . . . . . . . . code *-expression
*F  CodeInv() . . . . . . . . . . . . . . . . . . . . . . code ^-1-expression
*F  CodeQuo() . . . . . . . . . . . . . . . . . . . . . . . code /-expression
*F  CodeMod() . . . . . . . . . . . . . . . . . . . . . . code mod-expression
*F  CodePow() . . . . . . . . . . . . . . . . . . . . . . . code ^-expression
**
**  'CodeOr', 'CodeAnd', 'CodeNot',  'CodeEq', 'CodeNe',  'CodeGt', 'CodeGe',
**  'CodeIn',  'CodeSum',  'CodeDiff', 'CodeProd', 'CodeQuo',  'CodeMod', and
**  'CodePow' are the actions to   code the respective operator  expressions.
**  They are called by the reader *after* *both* operands are read.
*/
extern  void            CodeOrL ( void );

extern  void            CodeOr ( void );

extern  void            CodeAndL ( void );

extern  void            CodeAnd ( void );

extern  void            CodeNot ( void );

extern  void            CodeEq ( void );

extern  void            CodeNe ( void );

extern  void            CodeLt ( void );

extern  void            CodeGe ( void );

extern  void            CodeGt ( void );

extern  void            CodeLe ( void );

extern  void            CodeIn ( void );

extern  void            CodeSum ( void );

extern  void            CodeAInv ( void );

extern  void            CodeDiff ( void );

extern  void            CodeProd ( void );

extern  void            CodeInv ( void );

extern  void            CodeQuo ( void );

extern  void            CodeMod ( void );

extern  void            CodePow ( void );


/****************************************************************************
**
*F  CodeIntExpr(<str>)  . . . . . . . . . . . code literal integer expression
**
**  'CodeIntExpr' is the action to code a literal integer expression.  <str>
**  is the integer as a (null terminated) C character string.
*/
extern  void            CodeIntExpr (
            Char *              str );
extern  void            CodeLongIntExpr (
            Obj                 string ); 

/****************************************************************************
**
*F  CodeTrueExpr()  . . . . . . . . . . . . . .  code literal true expression
**
**  'CodeTrueExpr' is the action to code a literal true expression.
*/
extern  void            CodeTrueExpr ( void );


/****************************************************************************
**
*F  CodeFalseExpr() . . . . . . . . . . . . . . code literal false expression
**
**  'CodeFalseExpr' is the action to code a literal false expression.
*/
extern  void            CodeFalseExpr ( void );


/****************************************************************************
**
*F  CodeCharExpr(<chr>) . . . . . . . . . . code literal character expression
**
**  'CodeCharExpr'  is the action  to  code a  literal  character expression.
**  <chr> is the C character.
*/
extern  void            CodeCharExpr (
            Char                chr );


/****************************************************************************
**
*F  CodePermCycle(<nrx>,<nrc>)  . . . . . code literal permutation expression
*F  CodePerm(<nrc>) . . . . . . . . . . . code literal permutation expression
**
**  'CodePermCycle'  is an action to code  a  literal permutation expression.
**  It is called when one cycles is read completely.  <nrc>  is the number of
**  elements in that cycle.  <nrx> is the number of that  cycles (i.e., 1 for
**  the first cycle, 2 for the second, and so on).
**
**  'CodePerm' is an action to code a  literal permutation expression.  It is
**  called when  the permutation is read completely.   <nrc> is the number of
**  cycles.
*/
extern  void            CodePermCycle (
            UInt                nrx,
            UInt                nrc );

extern  void            CodePerm (
            UInt                nrc );


/****************************************************************************
**
*F  CodeListExprBegin(<top>)  . . . . . . . . . . code list expression, begin
*F  CodeListExprBeginElm(<pos>) . . . . . code list expression, begin element
*F  CodeListExprEndElm()  . . . . . . . . . code list expression, end element
*F  CodeListExprEnd(<nr>,<range>,<top>,<tilde>) . . code list expression, end
*/
extern  void            CodeListExprBegin (
            UInt                top );

extern  void            CodeListExprBeginElm (
            UInt                pos );

extern  void            CodeListExprEndElm ( void );

extern  void            CodeListExprEnd (
            UInt                nr,
            UInt                range,
            UInt                top,
            UInt                tilde );


/****************************************************************************
**
*F  CodeStringExpr(<str>) . . . . . . . . . .  code literal string expression
*/
extern  void            CodeStringExpr (
            Obj              str );

/****************************************************************************
**
*F  CodeFloatExpr(<str>) . . . . . . . . . .  code literal float expression
*/
extern  void            CodeFloatExpr (
            Char *              str );

extern  void            CodeLongFloatExpr (
            Obj              str );


/****************************************************************************
**
*F  CodeRecExprBegin(<top>) . . . . . . . . . . code record expression, begin
*F  CodeRecExprBeginElmName(<rnam>) . . code record expression, begin element
*F  CodeRecExprBeginElmExpr() . . . . . code record expression, begin element
*F  CodeRecExprEndElmExpr() . . . . . . . code record expression, end element
*F  CodeRecExprEnd(<nr>,<top>,<tilde>)  . . . . . code record expression, end
*/
extern  void            CodeRecExprBegin (
            UInt                top );

extern  void            CodeRecExprBeginElmName (
            UInt                rnam );

extern  void            CodeRecExprBeginElmExpr ( void );

extern  void            CodeRecExprEndElm ( void );

extern  void            CodeRecExprEnd (
            UInt                nr,
            UInt                top,
            UInt                tilde );


/****************************************************************************
**
*F  CodeAssLVar(<lvar>) . . . . . . . . . . . . . .  code assignment to local
**
**  'CodeAssLVar' is the action  to code an  assignment to the local variable
**  <lvar> (given  by its  index).  It is   called by the  reader *after* the
**  right hand side expression is read.
**
**  An assignment  to a  local variable  is   represented by a  bag with  two
**  subexpressions.  The  *first* is the local variable,  the *second* is the
**  right hand side expression.
*/
extern  void            CodeAssLVar (
            UInt                lvar );

extern  void            CodeUnbLVar (
            UInt                lvar );


/****************************************************************************
**
*F  CodeRefLVar(<lvar>) . . . . . . . . . . . . . . . code reference to local
**
**  'CodeRefLVar' is  the action  to code a  reference  to the local variable
**  <lvar> (given  by its   index).  It is   called by  the  reader  when  it
**  encounters a local variable.
**
**  A   reference to   a local  variable    is represented immediately   (see
**  'REFLVAR_LVAR').
*/
extern  void            CodeRefLVar (
            UInt                lvar );

extern  void            CodeIsbLVar (
            UInt                lvar );


/****************************************************************************
**
*F  CodeAssHVar(<hvar>) . . . . . . . . . . . . . . code assignment to higher
**
**  'CodeAssHVar' is the action to code an  assignment to the higher variable
**  <hvar> (given by its  level  and  index).  It  is  called by  the  reader
**  *after* the right hand side expression is read.
**
**  An assignment to a higher variable is represented by a statement bag with
**  two subexpressions.  The *first* is the higher  variable, the *second* is
**  the right hand side expression.
*/
extern  void            CodeAssHVar (
            UInt                hvar );

extern  void            CodeUnbHVar (
            UInt                hvar );


/****************************************************************************
**
*F  CodeRefHVar(<hvar>) . . . . . . . . . . . . . .  code reference to higher
**
**  'CodeRefHVar' is the  action to code  a reference to the higher  variable
**  <hvar> (given by its level  and index).  It is  called by the reader when
**  it encounters a higher variable.
**
**  A reference to a higher variable is represented by an expression bag with
**  one subexpression.  This is the higher variable.
*/
extern  void            CodeRefHVar (
            UInt                hvar );

extern  void            CodeIsbHVar (
            UInt                hvar );


/****************************************************************************
**
*F  CodeAssGVar(<gvar>) . . . . . . . . . . . . . . code assignment to global
**
**  'CodeAssGVar' is the action to code  an assignment to the global variable
**  <gvar>.  It is  called   by  the reader    *after* the right   hand  side
**  expression is read.
**
**  An assignment to a global variable is represented by a statement bag with
**  two subexpressions.  The *first* is the  global variable, the *second* is
**  the right hand side expression.
*/
extern  void            CodeAssGVar (
            UInt                gvar );

extern  void            CodeUnbGVar (
            UInt                gvar );


/****************************************************************************
**
*F  CodeRefGVar(<gvar>) . . . . . . . . . . . . . .  code reference to global
**
**  'CodeRefGVar' is the  action to code a  reference to  the global variable
**  <gvar>.  It is called by the reader when it encounters a global variable.
**
**  A reference to a global variable is represented by an expression bag with
**  one subexpression.  This is the global variable.
*/
extern  void            CodeRefGVar (
            UInt                gvar );

extern  void            CodeIsbGVar (
            UInt                gvar );


/****************************************************************************
**
*F  CodeAssList() . . . . . . . . . . . . . . . . . code assignment to a list
*F  CodeAsssList()  . . . . . . . . . . .  code multiple assignment to a list
*F  CodeAssListLevel(<level>) . . . . . . .  code assignment to several lists
*F  CodeAsssListLevel(<level>)  . . code multiple assignment to several lists
*/
extern  void            CodeAssList ( Int narg );

extern  void            CodeAsssList ( void );

extern  void            CodeAssListLevel ( Int narg,
            UInt                level );

extern  void            CodeAsssListLevel (
            UInt                level );

extern  void            CodeUnbList ( Int narg );


/****************************************************************************
**
*F  CodeElmList() . . . . . . . . . . . . . . . . .  code selection of a list
*F  CodeElmsList()  . . . . . . . . . . . . code multiple selection of a list
*F  CodeElmListLevel(<level>) . . . . . . . . code selection of several lists
*F  CodeElmsListLevel(<level>)  . .  code multiple selection of several lists
*/
extern  void            CodeElmList ( Int narg );

extern  void            CodeElmsList ( void );

extern  void            CodeElmListLevel (
					  Int narg,
					  UInt level);

extern  void            CodeElmsListLevel (
            UInt                level );

extern  void            CodeIsbList ( Int narg );


/****************************************************************************
**
*F  CodeAssRecName(<rnam>)  . . . . . . . . . . . code assignment to a record
*F  CodeAssRecExpr()  . . . . . . . . . . . . . . code assignment to a record
*/
extern  void            CodeAssRecName (
            UInt                rnam );

extern  void            CodeAssRecExpr ( void );

extern  void            CodeUnbRecName (
            UInt                rnam );

extern  void            CodeUnbRecExpr ( void );


/****************************************************************************
**
*F  CodeElmRecName(<rnam>)  . . . . . . . . . . .  code selection of a record
*F  CodeElmRecExpr()  . . . . . . . . . . . . . .  code selection of a record
*/
extern  void            CodeElmRecName (
            UInt                rnam );

extern  void            CodeElmRecExpr ( void );

extern  void            CodeIsbRecName (
            UInt                rnam );

extern  void            CodeIsbRecExpr ( void );


/****************************************************************************
**
*F  CodeAssPosObj() . . . . . . . . . . . . . . . . code assignment to a list
*F  CodeAsssPosObj()  . . . . . . . . . .  code multiple assignment to a list
*F  CodeAssPosObjLevel(<level>) . . . . . .  code assignment to several lists
*F  CodeAsssPosObjLevel(<level>)  . code multiple assignment to several lists
*/
extern  void            CodeAssPosObj ( void );

extern  void            CodeAsssPosObj ( void );

extern  void            CodeAssPosObjLevel (
            UInt                level );

extern  void            CodeAsssPosObjLevel (
            UInt                level );

extern  void            CodeUnbPosObj ( void );


/****************************************************************************
**
*F  CodeElmPosObj() . . . . . . . . . . . . . . . .  code selection of a list
*F  CodeElmsPosObj()  . . . . . . . . . . . code multiple selection of a list
*F  CodeElmPosObjLevel(<level>) . . . . . . . code selection of several lists
*F  CodeElmsPosObjLevel(<level>)  .  code multiple selection of several lists
*/
extern  void            CodeElmPosObj ( void );

extern  void            CodeElmsPosObj ( void );

extern  void            CodeElmPosObjLevel (
            UInt                level );

extern  void            CodeElmsPosObjLevel (
            UInt                level );

extern  void            CodeIsbPosObj ( void );


/****************************************************************************
**
*F  CodeAssComObjName(<rnam>) . . . . . . . . . . code assignment to a record
*F  CodeAssComObjExpr() . . . . . . . . . . . . . code assignment to a record
*/
extern  void            CodeAssComObjName (
            UInt                rnam );

extern  void            CodeAssComObjExpr ( void );

extern  void            CodeUnbComObjName (
            UInt                rnam );

extern  void            CodeUnbComObjExpr ( void );


/****************************************************************************
**
*F  CodeElmComObjName(<rnam>) . . . . . . . . . .  code selection of a record
*F  CodeElmComObjExpr() . . . . . . . . . . . . .  code selection of a record
*/
extern  void            CodeElmComObjName (
            UInt                rnam );

extern  void            CodeElmComObjExpr ( void );

extern  void            CodeIsbComObjName (
            UInt                rnam );

extern  void            CodeIsbComObjExpr ( void );

/****************************************************************************
**
*F  CodeEmpty()  . . . . code an empty statement
**
*/

extern void CodeEmpty( void );

/****************************************************************************
**
*F  CodeInfoBegin() . . . . . . . . . . . . .  start coding of Info statement
*F  CodeInfoMiddle()  . . . . . . . . .   shift to coding printable arguments
*F  CodeInfoEnd( <narg> ) . . Info statement complete, <narg> things to print
**
**  These  actions deal  with the  Info  statement, which is coded specially,
**  because not all of its arguments are always evaluated.
*/
extern  void            CodeInfoBegin ( void );

extern  void            CodeInfoMiddle ( void );

extern  void            CodeInfoEnd   (
            UInt                narg );


/****************************************************************************
**
*F  CodeAssertBegin() . . . . . . .  start interpretation of Assert statement
*F  CodeAsseerAfterLevel()  . . called after the first argument has been read
*F  CodeAssertAfterCondition() called after the second argument has been read
*F  CodeAssertEnd2Args() . . . . called after reading the closing parenthesis
*F  CodeAssertEnd3Args() . . . . called after reading the closing parenthesis
*/
extern  void            CodeAssertBegin ( void );

extern  void            CodeAssertAfterLevel ( void );

extern  void            CodeAssertAfterCondition ( void );

extern  void            CodeAssertEnd2Args ( void );

extern  void            CodeAssertEnd3Args ( void );

/*  CodeContinue() .  . . . . . . . . . . . .  code continue-statement */
extern  void            CodeContinue ( void );



/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoCode() . . . . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoCode ( void );



#endif // GAP_CODE_H

/****************************************************************************
**

*E  code.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
