/****************************************************************************
**
*A  read.c                      GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This module contains the functions to read  expressions  and  statements.
*/
char *          Revision_read_c =
   "@(#)$Id$";

#include        <setjmp.h>              /* jmp_buf, setjmp, longjmp        */

#include        "system.h"              /* Ints, UInts                     */
#include        "scanner.h"             /* Pr                              */
#include        "gasman.h"              /* NewBag, CHANGED_BAG             */

#include        "objects.h"             /* Obj, TYPE_OBJ, types            */
#include        "gvars.h"               /* Tilde, VAL_GVAR, AssGVar        */

#include        "calls.h"               /* NAMS_FUNC, ENVI_FUNC            */

#include        "records.h"             /* SET_NAME_REC, SET_ELM_REC       */
#include        "lists.h"               /* generic lists                   */

#include        "plist.h"               /* SET_LEN_PLIST, SET_ELM_PLIST    */
#include        "string.h"              /* ObjsChar, NEW_STRING, CSTR_ST...*/

#include        "intrprtr.h"            /* IntrBegin, IntrEnd, IntrFunc... */

#define INCLUDE_DECLARATION_PART
#include        "read.h"                /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**
*F  READ_ERROR()  . . . . . . . . . . . . . . . . . . . reader found an error
**
**  'READ_ERROR' returns a non-zero value if the reader found an error, or if
**  the interpretation of  an expression  or  statement lead to an  error (in
**  which case 'ReadEvalError' jumps back to 'READ_ERROR' via 'longjmp').
*/
jmp_buf         ReadJmpError;

#define READ_ERROR()    (NrError || (NrError+=setjmp(ReadJmpError)))


/****************************************************************************
**
*V  StackNams . . . . . . . . . . . . .  stack of local variables names lists
*V  CountNams . . . . . . . . . number of local variables names list on stack
**
**  'StackNams' is a stack of local variables  names lists.  A new names list
**  is pushed onto this stack when the  reader begins to  read a new function
**  expression  (after  reading the argument   list  and the local  variables
**  list), and popped again when the reader has finished reading the function
**  expression (after reading the 'end').
**
**  'CountNams' is the number of local variables names lists currently on the
**  stack.
*/
Obj             StackNams;

UInt            CountNams;


/****************************************************************************
**
*V  ReadTop . . . . . . . . . . . . . . . . . . . . . . .  top level expression
*V  ReadTilde . . . . . . . . . . . . . . . . . . . . . . . . . . .  tilde read
**
**  'ReadTop' is 0  if the reader is   currently not reading  a  list or record
**  expression.  'ReadTop'  is 1 if the  reader is currently reading an outmost
**  list or record expression.   'ReadTop' is larger than   1 if the  reader is
**  currently reading a nested list or record expression.
**
**  'ReadTilde' is 1 if the reader has read a  reference to the global variable
**  '~' within the current outmost list or record expression.
*/
UInt            ReadTop;

UInt            ReadTilde;


/****************************************************************************
**
*V  CurrLHSGVar . . . . . . . . . . . .  current left hand side of assignment
**
**  'CurrLHSGVar' is the current left hand side of an assignment.  It is used
**  to prevent undefined global variable  warnings, when reading a  recursive
**  function.
*/
UInt            CurrLHSGVar;


/****************************************************************************
**
**  The constructs <Expr> and <Statments> may have themself as subpart, e.g.,
**  '<Var>( <Expr> )'  is  <Expr> and 'if   <Expr> then <Statments> fi;'   is
**  <Statments>.  The  functions 'ReadExpr' and  'ReadStats' must therefor be
**  declared forward.
*/
void            ReadExpr (
    TypSymbolSet        follow,
    Char                mode );

UInt            ReadStats (
    TypSymbolSet        follow );

void            ReadFuncExpr1 (
    TypSymbolSet        follow );


/****************************************************************************
**
*F  ReadVar(<follow>) . . . . . . . . . . . . . . . . . . . . read a variable
**
**  'ReadVar' reads a variable.  In case of an error  it skips all symbols up
**  to one contained in <follow>.
**
**      <Ident>         :=  a|b|..|z|A|B|..|Z { a|b|..|z|A|B|..|Z|0|..|9|_ }
**
**      <Var>           :=  <Ident>
**                      |   <Var> '[' <Expr> ']'
**                      |   <Var> '{' <Expr> '}'
**                      |   <Var> '.' <Ident>
**                      |   <Var> '(' [ <Expr> { ',' <Expr> } ] ')'
*/
extern  Obj             ExprGVars;

extern  Obj             ErrorLVars;

extern  Obj             BottomLVars;

void            ReadCallVarAss (
    TypSymbolSet        follow,
    Char                mode )
{
    volatile Char       type = ' ';     /* type of variable                */
    volatile Obj        nams;           /* list of names of local vars.    */
    volatile Obj        lvars;          /* environment                     */
    volatile UInt       nest  = 0;      /* nesting level of a higher var.  */
    volatile UInt       indx  = 0;      /* index of a local variable       */
    volatile UInt       var   = 0;      /* variable                        */
    volatile UInt       level = 0;      /* number of '{}' selectors        */
    volatile UInt       rnam  = 0;      /* record component name           */
    volatile UInt       narg  = 0;      /* number of arguments             */

    /* all variables must begin with an identifier                         */
    if ( Symbol != S_IDENT ) {
        SyntaxError( "identifier expected" );
        return;
    }

    /* try to look up the variable on the stack of local variables         */
    nest = 0;
    while ( type == ' ' && nest < CountNams ) {
        nams = ELM_LIST( StackNams, CountNams-nest );
        for ( indx = LEN_LIST( nams ); 1 <= indx; indx-- ) {
            if ( SyStrcmp( Value, CSTR_STRING(ELM_LIST(nams,indx)) ) == 0 ) {
                if ( nest == 0 ) {
                    type = 'l';
                    var = indx;
                }
                else {
                    type = 'h';
                    var = (nest << 16) + indx;
                }
                break;
            }
        }
        nest++;
    }

    /* try to look up the variable on the error stack                      */
    nest = 0;
    lvars = ErrorLVars;
    while ( type == ' ' && lvars != 0 && lvars != BottomLVars ) {
        nams = NAMS_FUNC( PTR_BAG(lvars)[0] );
        for ( indx = LEN_LIST( nams ); 1 <= indx; indx-- ) {
            if ( SyStrcmp( Value, CSTR_STRING(ELM_LIST(nams,indx)) ) == 0 ) {
                type = 'd';
                var = (nest << 16) + indx;
                break;
            }
        }
        lvars = ENVI_FUNC( PTR_BAG( lvars )[0] );
        nest++;
    }

    /* get the variable as a global variable                               */
    if ( type == ' ' ) {
        type = 'g';
        var = GVarName( Value );
    }

    /* match away the identifier, now that we know the variable            */
    Match( S_IDENT, "identifier", follow );

    /* if this was actually the beginning of a function literal            */
    /* then we are in the wrong function                                   */
    if ( Symbol == S_MAPTO ) {
        ReadFuncExpr1( follow );
        return;
    }

    /* check whether this is an unbound global variable                    */
    if ( type == 'g' && CountNams != 0
      && var != CurrLHSGVar && var != Tilde
      && VAL_GVAR(var) == 0 && ELM_PLIST(ExprGVars,var) == 0
      && CompNowFuncs == 0 ) {
        SyntaxError("warning: unbound global variable");
        NrError--;
        NrErrLine--;
    }

    /* check whether this is a reference to the global variable '~'        */
    if ( type == 'g' && var == Tilde ) { ReadTilde = 1; }

    /* followed by one or more selectors                                   */
    while ( IS_IN( Symbol, S_LPAREN|S_LBRACK|S_LBRACE|S_DOT ) ) {

        /* so the prefix was a reference                                   */
        if ( READ_ERROR() ) {}
        else if ( type == 'l' ) { IntrRefLVar( var );           level=0; }
        else if ( type == 'h' ) { IntrRefHVar( var );           level=0; }
        else if ( type == 'd' ) { IntrRefDVar( var );           level=0; }
        else if ( type == 'g' ) { IntrRefGVar( var );           level=0; }
        else if ( type == '[' ) { IntrElmList();                         }
        else if ( type == ']' ) { IntrElmListLevel( level );             }
        else if ( type == '{' ) { IntrElmsList();               level++; }
        else if ( type == '}' ) { IntrElmsListLevel( level );   level++; }
        else if ( type == '<' ) { IntrElmPosobj();                         }
        else if ( type == '>' ) { IntrElmPosobjLevel( level );             }
        else if ( type == '(' ) { IntrElmsPosobj();               level++; }
        else if ( type == ')' ) { IntrElmsPosobjLevel( level );   level++; }
        else if ( type == '.' ) { IntrElmRecName( rnam );       level=0; }
        else if ( type == ':' ) { IntrElmRecExpr();             level=0; }
        else if ( type == '!' ) { IntrElmComobjName( rnam );      level=0; }
        else if ( type == '|' ) { IntrElmComobjExpr();            level=0; }
        else if ( type == 'c' ) { IntrFuncCallEnd( 1UL, narg ); level=0; }

        /* <Var> '[' <Expr> ']'  list selector                             */
        if ( Symbol == S_LBRACK ) {
            Match( S_LBRACK, "[", follow );
            ReadExpr( S_RBRACK|follow, 'r' );
            Match( S_RBRACK, "]", follow );
            type = (level == 0 ? '[' : ']');
        }

        /* <Var> '{' <Expr> '}'  sublist selector                          */
        else if ( Symbol == S_LBRACE ) {
            Match( S_LBRACE, "{", follow );
            ReadExpr( S_RBRACE|follow, 'r' );
            Match( S_RBRACE, "}", follow );
            type = (level == 0 ? '{' : '}');
        }

        /* <Var> '![' <Expr> ']'  list selector                            */
        else if ( Symbol == S_BLBRACK ) {
            Match( S_BLBRACK, "![", follow );
            ReadExpr( S_RBRACK|follow, 'r' );
            Match( S_RBRACK, "]", follow );
            type = (level == 0 ? '<' : '>');
        }

        /* <Var> '!{' <Expr> '}'  sublist selector                         */
        else if ( Symbol == S_BLBRACE ) {
            Match( S_BLBRACE, "!{", follow );
            ReadExpr( S_RBRACE|follow, 'r' );
            Match( S_RBRACE, "}", follow );
            type = (level == 0 ? '(' : ')');
        }

        /* <Var> '.' <Ident>  record selector                              */
        else if ( Symbol == S_DOT ) {
            Match( S_DOT, ".", follow );
            if ( Symbol == S_IDENT || Symbol == S_INT ) {
                rnam = RNamName( Value );
                Match( Symbol, "identifier", follow );
                type = '.';
            }
            else if ( Symbol == S_LPAREN ) {
                Match( S_LPAREN, "(", follow );
                ReadExpr( S_RPAREN|follow, 'r' );
                Match( S_RPAREN, ")", follow );
                type = ':';
            }
            else {
                SyntaxError("record component name expected");
            }
            level = 0;
        }

        /* <Var> '!.' <Ident>  record selector                             */
        else if ( Symbol == S_BDOT ) {
            Match( S_BDOT, "!.", follow );
            if ( Symbol == S_IDENT || Symbol == S_INT ) {
                rnam = RNamName( Value );
                Match( Symbol, "identifier", follow );
                type = '!';
            }
            else if ( Symbol == S_LPAREN ) {
                Match( S_LPAREN, "(", follow );
                ReadExpr( S_RPAREN|follow, 'r' );
                Match( S_RPAREN, ")", follow );
                type = '|';
            }
            else {
                SyntaxError("record component name expected");
            }
            level = 0;
        }

        /* <Var> '(' [ <Expr> { ',' <Expr> } ] ')'  function call          */
        else if ( Symbol == S_LPAREN ) {
            Match( S_LPAREN, "(", follow );
            if ( ! READ_ERROR() ) { IntrFuncCallBegin(); }
            narg = 0;
            if ( Symbol != S_RPAREN ) {
                ReadExpr( S_RPAREN|follow, 'r' );
                narg++;
            }
            while ( Symbol == S_COMMA ) {
                Match( S_COMMA, ",", follow );
                ReadExpr( S_RPAREN|follow, 'r' );
                narg++;
            }
            Match( S_RPAREN, ")", follow );
            type = 'c';
        }

    }

    /* if we need a reference                                              */
    if      ( mode == 'r' || (mode == 'x' && Symbol != S_ASSIGN) ) {
        if ( READ_ERROR() ) {}
        else if ( type == 'l' ) { IntrRefLVar( var );           }
        else if ( type == 'h' ) { IntrRefHVar( var );           }
        else if ( type == 'd' ) { IntrRefDVar( var );           }
        else if ( type == 'g' ) { IntrRefGVar( var );           }
        else if ( type == '[' ) { IntrElmList();                }
        else if ( type == ']' ) { IntrElmListLevel( level );    }
        else if ( type == '{' ) { IntrElmsList();               }
        else if ( type == '}' ) { IntrElmsListLevel( level );   }
        else if ( type == '<' ) { IntrElmPosobj();                }
        else if ( type == '>' ) { IntrElmPosobjLevel( level );    }
        else if ( type == '(' ) { IntrElmsPosobj();               }
        else if ( type == ')' ) { IntrElmsPosobjLevel( level );   }
        else if ( type == '.' ) { IntrElmRecName( rnam );       }
        else if ( type == ':' ) { IntrElmRecExpr();             }
        else if ( type == '!' ) { IntrElmComobjName( rnam );      }
        else if ( type == '|' ) { IntrElmComobjExpr();            }
        else if ( type == 'c' ) {
            if ( mode == 'x' && Symbol == S_SEMICOLON ) {
                IntrFuncCallEnd( 0UL, narg );
            }
            else {
                IntrFuncCallEnd( 1UL, narg );
            }
        }
    }

    /* if we need a statement                                              */
    else if ( mode == 's' || (mode == 'x' && Symbol == S_ASSIGN) ) {
        if ( type != 'c' ) {
            Match( S_ASSIGN, ":=", follow );
            if ( CountNams == 0 ) { CurrLHSGVar = var; }
            ReadExpr( follow, 'r' );
        }
        if ( READ_ERROR() ) {}
        else if ( type == 'l' ) { IntrAssLVar( var );           }
        else if ( type == 'h' ) { IntrAssHVar( var );           }
        else if ( type == 'd' ) { IntrAssDVar( var );           }
        else if ( type == 'g' ) { IntrAssGVar( var );           }
        else if ( type == '[' ) { IntrAssList();                }
        else if ( type == ']' ) { IntrAssListLevel( level );    }
        else if ( type == '{' ) { IntrAsssList();               }
        else if ( type == '}' ) { IntrAsssListLevel( level );   }
        else if ( type == '<' ) { IntrAssPosobj();                }
        else if ( type == '>' ) { IntrAssPosobjLevel( level );    }
        else if ( type == '(' ) { IntrAsssPosobj();               }
        else if ( type == ')' ) { IntrAsssPosobjLevel( level );   }
        else if ( type == '.' ) { IntrAssRecName( rnam );       }
        else if ( type == ':' ) { IntrAssRecExpr();             }
        else if ( type == '!' ) { IntrAssComobjName( rnam );      }
        else if ( type == '|' ) { IntrAssComobjExpr();            }
        else if ( type == 'c' ) { IntrFuncCallEnd( 0UL, narg ); }
    }

    /*  if we need an unbind                                               */
    else if ( mode == 'u' ) {
        if ( READ_ERROR() ) {}
        else if ( type == 'l' ) { IntrUnbLVar( var );           }
        else if ( type == 'h' ) { IntrUnbHVar( var );           }
        else if ( type == 'd' ) { IntrUnbDVar( var );           }
        else if ( type == 'g' ) { IntrUnbGVar( var );           }
        else if ( type == '[' ) { IntrUnbList();                }
        else if ( type == '<' ) { IntrUnbPosobj();                }
        else if ( type == '.' ) { IntrUnbRecName( rnam );       }
        else if ( type == ':' ) { IntrUnbRecExpr();             }
        else if ( type == '!' ) { IntrUnbComobjName( rnam );      }
        else if ( type == '|' ) { IntrUnbComobjExpr();            }
        else { SyntaxError("illegal operand for 'Unbind'");     }
    }

    
    /* if we need an isbound                                               */
    else /* if ( mode == 'i' ) */ {
        if ( READ_ERROR() ) {}
        else if ( type == 'l' ) { IntrIsbLVar( var );           }
        else if ( type == 'h' ) { IntrIsbHVar( var );           }
        else if ( type == 'd' ) { IntrIsbDVar( var );           }
        else if ( type == 'g' ) { IntrIsbGVar( var );           }
        else if ( type == '[' ) { IntrIsbList();                }
        else if ( type == '<' ) { IntrIsbPosobj();                }
        else if ( type == '.' ) { IntrIsbRecName( rnam );       }
        else if ( type == ':' ) { IntrIsbRecExpr();             }
        else if ( type == '!' ) { IntrIsbComobjName( rnam );      }
        else if ( type == '|' ) { IntrIsbComobjExpr();            }
        else { SyntaxError("illegal operand for 'IsBound'");    }
    }

}


/****************************************************************************
**
*F  ReadIsBound(<follow>) . . . . . . . . . . . .  read an isbound expression
**
**  'ReadIsBound' reads an isbound expression.  In  case of an error it skips
**  all symbols up to one contained in <follow>.
**
**      <Atom>          :=  'IsBound' '(' <Var> ')'
*/
void            ReadIsBound (
    TypSymbolSet        follow )
{
    Match( S_ISBOUND, "IsBound", follow );
    Match( S_LPAREN, "(", follow );
    ReadCallVarAss( S_RPAREN|follow, 'i' );
    Match( S_RPAREN, ")", follow );
}


/****************************************************************************
**
*F  ReadPerm(<follow>)  . . . . . . . . . . . . . . . . .  read a permutation
**
**  'ReadPerm' reads a permutation.  In case of an error it skips all symbols
**  up to one contained in <follow>.
**
**  Note that the first expression has already been read.  The reason is that
**  until the first  expression has been  read and a  comma is found it could
**  also be a parenthesized expression.
**
**      <Perm>          :=  ( <Expr> {, <Expr>} ) { ( <Expr> {, <Expr>} ) }
**
*/
void            ReadPerm (
    TypSymbolSet        follow )
{
    volatile UInt       nrc;            /* number of cycles                */
    volatile UInt       nrx;            /* number of expressions in cycle  */

    /* read the first cycle (first expression has already been read)       */
    nrx = 1;
    while ( Symbol == S_COMMA ) {
        Match( S_COMMA, ",", follow );
        ReadExpr( S_COMMA|S_RPAREN|follow, 'r' );
        nrx++;
    }
    Match( S_RPAREN, ")", follow );
    nrc = 1;
    if ( ! READ_ERROR() ) { IntrPermCycle( nrx, nrc ); }

    /* read the remaining cycles                                           */
    while ( Symbol == S_LPAREN ) {
        Match( S_LPAREN, "(", follow );
        ReadExpr( S_COMMA|S_RPAREN|follow, 'r' );
        nrx = 1;
        while ( Symbol == S_COMMA ) {
            Match( S_COMMA, ",", follow );
            ReadExpr( S_COMMA|S_RPAREN|follow, 'r' );
            nrx++;
        }
        Match( S_RPAREN, ")", follow );
        nrc++;
        if ( ! READ_ERROR() ) { IntrPermCycle( nrx, nrc ); }
    }

    /* that was the permutation                                            */
    if ( ! READ_ERROR() ) { IntrPerm( nrc ); }
}


/****************************************************************************
**
*F  ReadListExpr(<follow>)  . . . . . . . . . . . . . . . . . . . read a list
**
**  'ReadListExpr'  reads a list literal expression.   In case of an error it
**  skips all symbols up to one contained in <follow>.
**
**      <List>          :=  '[' [ <Expr> ] {',' [ <Expr> ] } ']'
**                      |   '[' <Expr> [',' <Expr>] '..' <Expr> ']'
*/
void            ReadListExpr (
    TypSymbolSet        follow )
{
    volatile UInt       pos;            /* actual position of element      */
    volatile UInt       nr;             /* number of elements              */
    volatile UInt       range;          /* is the list expression a range  */

    /* '['                                                                 */
    Match( S_LBRACK, "[", follow );
    ReadTop++;
    if ( ReadTop == 1 ) { ReadTilde = 0; }
    if ( ! READ_ERROR() ) { IntrListExprBegin( (ReadTop == 1) ); }
    pos   = 1;
    nr    = 0;
    range = 0;

    /* [ <Expr> ]                                                          */
    if ( Symbol != S_COMMA && Symbol != S_RBRACK ) {
        if ( ! READ_ERROR() ) { IntrListExprBeginElm( pos ); }
        ReadExpr( S_RBRACK|follow, 'r' );
        if ( ! READ_ERROR() ) { IntrListExprEndElm(); }
        nr++;
    }

    /* {',' [ <Expr> ] }                                                   */
    while ( Symbol == S_COMMA ) {
        Match( S_COMMA, ",", follow );
        pos++;
        if ( Symbol != S_COMMA && Symbol != S_RBRACK ) {
            if ( ! READ_ERROR() ) { IntrListExprBeginElm( pos ); }
            ReadExpr( S_RBRACK|follow, 'r' );
            if ( ! READ_ERROR() ) { IntrListExprEndElm(); }
            nr++;
        }
    }

    /* '..' <Expr> ']'                                                     */
    if ( Symbol == S_DOTDOT ) {
        if ( pos != nr ) {
            SyntaxError("must have no unbound entries in range");
        }
        if ( 2 < nr ) {
            SyntaxError("must have at most 2 entries before '..'");
        }
        range = 1;
        Match( S_DOTDOT, "..", follow );
        pos++;
        if ( ! READ_ERROR() ) { IntrListExprBeginElm( pos ); }
        ReadExpr( S_RBRACK|follow, 'r' );
        if ( ! READ_ERROR() ) { IntrListExprEndElm(); }
        nr++;
        if ( ReadTop == 1 && ReadTilde == 1 ) {
            SyntaxError("sorry, '~' not allowed in range");
        }
    }

    /* ']'                                                                 */
    Match( S_RBRACK, "]", follow );
    if ( ! READ_ERROR() ) {
        IntrListExprEnd( nr, range, (ReadTop == 1), (ReadTilde == 1) );
    }
    if ( ReadTop == 1 ) { ReadTilde = 0; }
    ReadTop--;
}


/****************************************************************************
**
*F  ReadRecExpr(<follow>) . . . . . . . . . . . . . . . . . . . read a record
**
**  'ReadRecExpr' reads a record literal expression.  In  case of an error it
**  skips all symbols up to one contained in <follow>.
**
**      <Record>        :=  'rec( [ <Ident>:=<Expr> {, <Ident>:=<Expr> } ] )'
*/
void            ReadRecExpr (
    TypSymbolSet        follow )
{
    volatile UInt       rnam;           /* record component name           */
    volatile UInt       nr;             /* number of components            */

    /* 'rec('                                                              */
    Match( S_REC, "rec", follow );
    Match( S_LPAREN, "(", follow|S_RPAREN|S_COMMA );
    ReadTop++;
    if ( ReadTop == 1 ) { ReadTilde = 0; }
    if ( ! READ_ERROR() ) { IntrRecExprBegin( (ReadTop == 1) ); }
    nr = 0;

    /* [ <Ident> | '(' <Expr> ')' ':=' <Expr>                              */
    if ( Symbol != S_RPAREN ) {
        if ( Symbol == S_INT ) {
            rnam = RNamName( Value );
            Match( S_INT, "integer", follow );
            if ( ! READ_ERROR() ) { IntrRecExprBeginElmName( rnam ); }
        }
        else if ( Symbol == S_IDENT ) {
            rnam = RNamName( Value );
            Match( S_IDENT, "identifier", follow );
            if ( ! READ_ERROR() ) { IntrRecExprBeginElmName( rnam ); }
        }
        else if ( Symbol == S_LPAREN ) {
            Match( S_LPAREN, "(", follow );
            ReadExpr( follow, 'r' );
            Match( S_RPAREN, ")", follow );
            if ( ! READ_ERROR() ) { IntrRecExprBeginElmExpr(); }
        }
        else {
            SyntaxError("identifier expected");
        }
        Match( S_ASSIGN, ":=", follow );
        ReadExpr( S_RPAREN|follow, 'r' );
        if ( ! READ_ERROR() ) { IntrRecExprEndElm(); }
        nr++;
    }


    /* {',' <Ident> ':=' <Expr> } ]                                        */
    while ( Symbol == S_COMMA ) {
        Match( S_COMMA, "", 0UL );
        if ( Symbol == S_INT ) {
            rnam = RNamName( Value );
            Match( S_INT, "integer", follow );
            if ( ! READ_ERROR() ) { IntrRecExprBeginElmName( rnam ); }
        }
        else if ( Symbol == S_IDENT ) {
            rnam = RNamName( Value );
            Match( S_IDENT, "identifier", follow );
            if ( ! READ_ERROR() ) { IntrRecExprBeginElmName( rnam ); }
        }
        else if ( Symbol == S_LPAREN ) {
            Match( S_LPAREN, "(", follow );
            ReadExpr( follow, 'r' );
            Match( S_RPAREN, ")", follow );
            if ( ! READ_ERROR() ) { IntrRecExprBeginElmExpr(); }
        }
        else {
            SyntaxError("identifier expected");
        }
        Match( S_ASSIGN, ":=", follow );
        ReadExpr( S_RPAREN|follow, 'r' );
        if ( ! READ_ERROR() ) { IntrRecExprEndElm(); }
        nr++;
    }

    /* ')'                                                                 */
    Match( S_RPAREN, ")", follow );
    if ( ! READ_ERROR() ) {
        IntrRecExprEnd( nr, (ReadTop == 1), (ReadTilde == 1) );
    }
    if ( ReadTop == 1) { ReadTilde = 0; }
    ReadTop--;
}


/****************************************************************************
**
*F  ReadFuncExpr(<follow>)  . . . . . . . . . . .  read a function definition
**
**  'ReadFuncExpr' reads a function literal expression.  In  case of an error
**  it skips all symbols up to one contained in <follow>.
**
**      <Function>      :=  'function (' [ <Ident> {',' <Ident>} ] ')'
**                              [ 'local'  <Ident> {',' <Ident>} ';' ]
**                              <Statments>
**                          'end'
*/
void            ReadFuncExpr (
    TypSymbolSet        follow )
{
    volatile Obj        nams;           /* list of local variables names   */
    volatile Obj        name;           /* one local variable name         */
    volatile UInt       narg;           /* number of arguments             */
    volatile UInt       nloc;           /* number of locals                */
    volatile UInt       nr;             /* number of statements            */

    /* begin the function                                                  */
    Match( S_FUNCTION, "function", follow );
    Match( S_LPAREN, "(", S_IDENT|S_RPAREN|S_LOCAL|STATBEGIN|S_END|follow );

    /* make and push the new local variables list (args and locals)        */
    narg = nloc = 0;
    nams = NEW_PLIST( T_PLIST, narg+nloc );
    SET_LEN_PLIST( nams, narg+nloc );
    CountNams += 1;
    ASS_LIST( StackNams, CountNams, nams );
    if ( Symbol != S_RPAREN ) {
        name = NEW_STRING( SyStrlen(Value) );
        SyStrncat( CSTR_STRING(name), Value, SyStrlen(Value) );
        narg += 1;
        ASS_LIST( nams, narg+nloc, name );
        Match(S_IDENT,"identifier",S_RPAREN|S_LOCAL|STATBEGIN|S_END|follow);
    }
    while ( Symbol == S_COMMA ) {
        Match( S_COMMA, ",", follow );
        name = NEW_STRING( SyStrlen(Value) );
        SyStrncat( CSTR_STRING(name), Value, SyStrlen(Value) );
        narg += 1;
        ASS_LIST( nams, narg+nloc, name );
        Match(S_IDENT,"identifier",S_RPAREN|S_LOCAL|STATBEGIN|S_END|follow);
    }
    Match( S_RPAREN, ")", S_LOCAL|STATBEGIN|S_END|follow );
    if ( Symbol == S_LOCAL ) {
        Match( S_LOCAL, "local", follow );
        name = NEW_STRING( SyStrlen(Value) );
        SyStrncat( CSTR_STRING(name), Value, SyStrlen(Value) );
        nloc += 1;
        ASS_LIST( nams, narg+nloc, name );
        Match( S_IDENT, "identifier", STATBEGIN|S_END|follow );
        while ( Symbol == S_COMMA ) {
            Match( S_COMMA, ",", follow );
            name = NEW_STRING( SyStrlen(Value) );
            SyStrncat( CSTR_STRING(name), Value, SyStrlen(Value) );
            nloc += 1;
            ASS_LIST( nams, narg+nloc, name );
            Match( S_IDENT, "identifier", STATBEGIN|S_END|follow );
        }
        Match( S_SEMICOLON, ";", STATBEGIN|S_END|follow );
    }

    /* function ( arg ) takes a variable number of arguments               */
    if ( narg == 1 && ! SyStrcmp( "arg", CSTR_STRING( ELM_LIST(nams,1) ) ) )
        narg = -1;

    /* now finally begin the function                                      */
    if ( ! READ_ERROR() ) { IntrFuncExprBegin( narg, nloc, nams ); }

    /* <Statments>                                                         */
    nr = ReadStats( S_END|follow );

    /* and end the function again                                          */
    if ( ! READ_ERROR() ) { IntrFuncExprEnd( nr, 0UL ); }

    /* pop the new local variables list                                    */
    CountNams--;

    /* 'end'                                                               */
    Match( S_END, "end", follow );
}


/****************************************************************************
**
*F  ReadFuncExpr1(<follow>) . . . . . . . . . . .  read a function expression
**
**  'ReadFuncExpr1' reads  an abbreviated  function literal   expression.  In
**  case of an error it skips all symbols up to one contained in <follow>.
**
**      <Function>      := <Var> '->' <Expr>
*/
void            ReadFuncExpr1 (
    TypSymbolSet        follow )
{
    Obj                 nams;           /* list of local variables names   */
    Obj                 name;           /* one local variable name         */

    /* make and push the new local variables list                          */
    nams = NEW_PLIST( T_PLIST, 1 );
    SET_LEN_PLIST( nams, 0 );
    CountNams++;
    ASS_LIST( StackNams, CountNams, nams );
    name = NEW_STRING( SyStrlen(Value) );
    SyStrncat( CSTR_STRING(name), Value, SyStrlen(Value) );
    ASS_LIST( nams, 1, name );

    /* match away the '->'                                                 */
    Match( S_MAPTO, "->", follow );

    /* begin interpreting the function expression (with 1 argument)        */
    if ( ! READ_ERROR() ) { IntrFuncExprBegin( 1L, 0L, nams ); }

    /* read the expression and turn it into a return-statement             */
    ReadExpr( follow, 'r' );
    if ( ! READ_ERROR() ) { IntrReturnObj(); }

    /* end interpreting the function expression (with 1 statement)         */
    if ( ! READ_ERROR() ) { IntrFuncExprEnd( 1UL, 1UL ); }

    /* pop the new local variables list                                    */
    CountNams--;
}


/****************************************************************************
**
*F  ReadLiteral(<follow>) . . . . . . . . . . . . . . . . . . .  read an atom
**
**  'ReadLiteral' reads a  literal expression.  In  case of an error it skips
**  all symbols up to one contained in <follow>.
**
**      <Literal>       :=  <Int>
**                      |   'true'
**                      |   'false'
**                      |   <Char>
**                      |   <Perm>
**                      |   <String>
**                      |   <List>
**                      |   <Record>
**                      |   <Function>
**
**      <Int>           :=  0|1|..|9 { 0|1|..|9 }
**
**      <Char>          :=  ' <any character> '
**
**      <String>        :=  " { <any character> } "
*/
void            ReadLiteral (
    TypSymbolSet        follow )
{
    /* <Int>                                                               */
    if ( Symbol == S_INT ) {
        if ( ! READ_ERROR() ) { IntrIntExpr( Value ); }
        Match( S_INT, "integer", follow );
    }

    /* 'true'                                                              */
    else if ( Symbol == S_TRUE ) {
        Match( S_TRUE, "true", follow );
        IntrTrueExpr();
    }

    /* 'false'                                                             */
    else if ( Symbol == S_FALSE ) {
        Match( S_FALSE, "false", follow );
        IntrFalseExpr();
    }

    /* <Char>                                                              */
    else if ( Symbol == S_CHAR ) {
        if ( ! READ_ERROR() ) { IntrCharExpr( Value[0] ); }
        Match( S_CHAR, "character", follow );
    }

    /* <String>                                                            */
    else if ( Symbol == S_STRING ) {
        if ( ! READ_ERROR() ) { IntrStringExpr( Value ); }
        Match( S_STRING, "string", follow );
    }

    /* <List>                                                              */
    else if ( Symbol == S_LBRACK ) {
        ReadListExpr( follow );
    }

    /* <Rec>                                                               */
    else if ( Symbol == S_REC ) {
        ReadRecExpr( follow );
    }

    /* <Function>                                                          */
    else if ( Symbol == S_FUNCTION ) {
        ReadFuncExpr( follow );
    }

    /* signal an error, we want to see a literal                           */
    else {
        Match( S_INT, "literal", follow );
    }
}


/****************************************************************************
**
*F  ReadAtom(<follow>)  . . . . . . . . . . . . . . . . . . . .  read an atom
**
**  'ReadAtom' reads an atom.  In case  of an error it skips  all symbols up to
**  one contained in <follow>.
**
**      <Atom>          :=  <Var>
**                      |   'IsBound' '(' <Var> ')'
**                      |   <Literal>
**                      |   '(' <Expr> ')'
*/
void            ReadAtom (
    TypSymbolSet        follow,
    Char                mode )
{
    /* read a variable                                                     */
    if ( Symbol == S_IDENT ) {
        ReadCallVarAss( follow, mode );
    }

    /* 'IsBound' '(' <Var> ')'                                             */
    else if ( Symbol == S_ISBOUND ) {
        ReadIsBound( follow );
    }

    /* otherwise read a literal expression                                 */
    else if (IS_IN(Symbol,S_INT|S_TRUE|S_FALSE|S_CHAR|S_STRING|S_LBRACK|S_REC|S_FUNCTION)) {
        ReadLiteral( follow );
    }

    /* '(' <Expr> ')'                                                      */
    else if ( Symbol == S_LPAREN ) {
        Match( S_LPAREN, "(", follow );
        if ( Symbol == S_RPAREN ) {
            Match( S_RPAREN, ")", follow );
            if ( ! READ_ERROR() ) { IntrPerm( 0UL ); }
            return;
        }
        ReadExpr( S_RPAREN|follow, 'r' );
        if ( Symbol == S_COMMA ) {
            ReadPerm( follow );
            return;
        }
        Match( S_RPAREN, ")", follow );
    }

    /* otherwise signal an error                                           */
    else {
        Match( S_INT, "expression", follow );
    }
}


/****************************************************************************
**
*F  ReadFactor(<follow>)  . . . . . . . . . . . . . . . . . . . read a factor
**
**  'ReadFactor' reads a factor.  In case of an error it skips all symbols up
**  to one contained in <follow>.
**
**      <Factor>        :=  {'+'|'-'} <Atom> [ '^' {'+'|'-'} <Atom> ]
*/
void            ReadFactor (
    TypSymbolSet        follow,
    Char                mode )
{
    volatile Int        sign1;
    volatile Int        sign2;

    /* { '+'|'-' }  leading sign                                           */
    sign1 = 0;
    while ( Symbol == S_MINUS  || Symbol == S_PLUS ) {
        if ( sign1 == 0 )  sign1 = 1;
        if ( Symbol == S_MINUS ) { sign1 = -sign1; }
        Match( Symbol, "unary + or -", follow );
    }
    if ( ! READ_ERROR() && sign1 == -1 ) {
	IntrRefGVar( GVarName( "AdditiveInverse" ) );
	IntrFuncCallBegin();
    }

    /* <Atom>                                                              */
    ReadAtom( follow, (sign1 == 0 ? mode : 'r') );

    /* ['^' <Atom> ] implemented as {'^' <Atom> } for better error message */
    while ( Symbol == S_POW ) {

        /* match the '^' away                                              */
        Match( S_POW, "^", follow );

        /* { '+'|'-' }  leading sign                                       */
        sign2 = 0;
        while ( Symbol == S_MINUS  || Symbol == S_PLUS ) {
            if ( sign2 == 0 )  sign2 = 1;
            if ( Symbol == S_MINUS ) { sign2 = -sign2; }
            Match( Symbol, "unary + or -", follow );
        }
	if ( ! READ_ERROR() && sign2 == -1 ) {
	    IntrRefGVar( GVarName( "AdditiveInverse" ) );
	    IntrFuncCallBegin();
	}

        /* ['^' <Atom>]                                                    */
        ReadAtom( follow, 'r' );

        /* interpret the unary minus                                       */
        if ( sign2 == -1 && ! READ_ERROR() ) {
	    IntrFuncCallEnd( 1, 1 );
        }

        /* interpret the power                                             */
        if ( ! READ_ERROR() ) { IntrPow(); }

        /* check for multiple '^'                                          */
        if ( Symbol == S_POW ) { SyntaxError("'^' is not associative"); }

    }

    /* interpret the unary minus                                           */
    if ( sign1 == -1 && ! READ_ERROR() ) {
	IntrFuncCallEnd( 1, 1 );
    }
}


/****************************************************************************
**
*F  ReadTerm(<follow>)  . . . . . . . . . . . . . . . . . . . . . read a term
**
**  'ReadTerm' reads a term.  In case of an error it  skips all symbols up to
**  one contained in <follow>.
**
**      <Term>          :=  <Factor> { '*'|'/'|'mod' <Factor> }
*/
void            ReadTerm (
    TypSymbolSet        follow,
    Char                mode )
{
    UInt                symbol;

    /* <Factor>                                                            */
    ReadFactor( follow, mode );

    /* { '*'|'/'|'mod' <Factor> }                                          */
    /* do not use 'IS_IN', since 'IS_IN(S_POW,S_MULT|S_DIV|S_MOD)' is true */
    while ( Symbol == S_MULT || Symbol == S_DIV || Symbol == S_MOD ) {
        symbol = Symbol;
        Match( Symbol, "*, /, or mod", follow );
        ReadFactor( follow, 'r' );
        if ( READ_ERROR() ) {}
        else if ( symbol == S_MULT  ) { IntrProd();  }
        else if ( symbol == S_DIV   ) { IntrQuo();   }
        else if ( symbol == S_MOD   ) { IntrMod();   }
    }
}


/****************************************************************************
**
*F  ReadAri(<follow>) . . . . . . . . . . . . . read an arithmetic expression
**
**  'ReadAri' reads an  arithmetic expression.  In  case of an error it skips
**  all symbols up to one contained in <follow>.
**
**      <Arith>         :=  <Term> { '+'|'-' <Term> }
*/
void            ReadAri (
    TypSymbolSet        follow,
    Char                mode )
{
    UInt                symbol;

    /* <Term>                                                              */
    ReadTerm( follow, mode );

    /* { '+'|'-' <Term> }                                                  */
    while ( IS_IN( Symbol, S_PLUS|S_MINUS ) ) {
        symbol = Symbol;
        Match( Symbol, "+ or -", follow );
        ReadTerm( follow, 'r' );
        if ( READ_ERROR() ) {}
        else if ( symbol == S_PLUS  ) { IntrSum();   }
        else if ( symbol == S_MINUS ) { IntrDiff();  }
    }
}


/****************************************************************************
**
*F  ReadRel(<follow>) . . . . . . . . . . . . .. read a relational expression
**
**  'ReadRel' reads a relational  expression.  In case  of an error it  skips
**  all symbols up to one contained in <follow>.
**
**      <Rel>           :=  { 'not' } <Arith> { '=|<>|<|>|<=|>=|in' <Arith> }
*/
void            ReadRel (
    TypSymbolSet        follow,
    Char                mode )
{
    volatile UInt       symbol;
    volatile UInt       isNot;

    /* { 'not' }                                                           */
    isNot = 0;
    while ( Symbol == S_NOT ) {
        isNot++;
        Match( S_NOT, "not", follow );
    }

    /* <Arith>                                                             */
    ReadAri( follow, (isNot == 0 ? mode : 'r') );

    /* { '=|<>|<|>|<=|>=|in' <Arith> }                                     */
    if ( IS_IN( Symbol, S_EQ|S_LT|S_GT|S_NE|S_LE|S_GE|S_IN ) ) {
        symbol = Symbol;
        Match( Symbol, "comparison operator", follow );
        ReadAri( follow, 'r' );
        if ( READ_ERROR() ) {}
        else if ( symbol == S_EQ ) { IntrEq(); }
        else if ( symbol == S_NE ) { IntrNe(); }
        else if ( symbol == S_LT ) { IntrLt(); }
        else if ( symbol == S_GE ) { IntrGe(); }
        else if ( symbol == S_GT ) { IntrGt(); }
        else if ( symbol == S_LE ) { IntrLe(); }
        else if ( symbol == S_IN ) { IntrIn(); }
    }

    /* interpret the not                                                   */
    if ( (isNot % 2) != 0 ) {
        if ( ! READ_ERROR() ) { IntrNot(); }
    }
}


/****************************************************************************
**
*F  ReadAnd(<follow>) . . . . . . . . . . . . . read a logical and expression
**
**  'ReadAnd' reads an and   expression.  In case of  an  error it  skips all
**  symbols up to one contained in <follow>.
**
**      <And>           :=  <Rel> { 'and' <Rel> }
*/
void            ReadAnd (
    TypSymbolSet        follow,
    Char                mode )
{
    /* <Rel>                                                               */
    ReadRel( follow, mode );

    /* { 'and' <Rel> }                                                     */
    while ( Symbol == S_AND ) {
        Match( S_AND, "and", follow );
        if ( ! READ_ERROR() ) { IntrAndL(); }
        ReadRel( follow, 'r' );
        if ( ! READ_ERROR() ) { IntrAnd(); }
    }
}


/****************************************************************************
**
*F  ReadExpr(<follow>) . . . . . . . . . . . . . . . . . . read an expression
**
**  'ReadExpr' reads an expression.  In case of an error it skips all symbols
**  up to one contained in <follow>.
**
**      <Expr>          :=  <And> { 'or' <And> }
*/
void            ReadExpr (
    TypSymbolSet        follow,
    Char                mode )
{
    /* <And>                                                               */
    ReadAnd( follow, mode );

    /* { 'or' <And> }                                                      */
    while ( Symbol == S_OR ) {
        Match( S_OR, "or", follow );
        if ( ! READ_ERROR() ) { IntrOrL(); }
        ReadAnd( follow, 'r' );
        if ( ! READ_ERROR() ) { IntrOr(); }
    }
}


/****************************************************************************
**
*F  ReadUnbind(<follow>)  . . . . . . . . . . . . .  read an unbind statement
**
**  'ReadUnbind' reads an unbind statement.  In case of an error it skips all
**  symbols up to one contained in <follow>.
**
**      <Statment>      :=  'Unbind' '(' <Var> ')' ';'
*/
void            ReadUnbind (
    TypSymbolSet        follow )
{
    Match( S_UNBIND, "Unbind", follow );
    Match( S_LPAREN, "(", follow );
    ReadCallVarAss( S_RPAREN|follow, 'u' );
    Match( S_RPAREN, ")", follow );
}

/****************************************************************************
**
*F  ReadInfo(<follow>)  . . . . . . . . . . . . . . .  read an info statement
**
**  'ReadInfo' reads an info statement.  In case of an error it skips all
**  symbols up to one contained in <follow>.
**
**      <Statment>      :=  'Info' '(' <Expr> ',' <Expr> { ',' <Expr> }  ')' ';'
*/
void            ReadInfo (
    TypSymbolSet        follow )
{
    volatile UInt narg;  	/* numer of arguments to print (or not) */
    if ( !READ_ERROR() ) { IntrInfoBegin(); }
    Match( S_INFO, "Info", follow );
    Match( S_LPAREN, "(", follow );
    ReadExpr( S_RPAREN | S_COMMA | follow, 'r');
    Match( S_COMMA, ",", S_RPAREN|follow);
    ReadExpr( S_RPAREN | S_COMMA | follow, 'r');
    if ( !READ_ERROR() ) {IntrInfoMiddle(); }
    narg = 0;
    while ( Symbol == S_COMMA )
      {
	narg ++;
	Match( S_COMMA, "", 0L);
	ReadExpr( S_RPAREN | S_COMMA | follow, 'r');
      }
    Match(S_RPAREN, ")", follow );
    if ( !READ_ERROR() ) { IntrInfoEnd(narg); }
}

/****************************************************************************
**
*F  ReadAssert(<follow>)  . . . . . . . . . . . . . .read an assert statement
**
**  'ReadAssert' reads an assert statement.  In case of an error it skips all
**  symbols up to one contained in <follow>.
**
**      <Statment>      :=  'Assert' '(' <Expr> ',' <Expr> [ ',' <Expr> ]  ')' ';'
*/
void            ReadAssert (
    TypSymbolSet        follow )
{
    if ( !READ_ERROR() ) { IntrAssertBegin(); }
    Match( S_ASSERT, "Assert", follow );
    Match( S_LPAREN, "(", follow );
    ReadExpr( S_RPAREN | S_COMMA | follow, 'r');
    if ( !READ_ERROR() ) { IntrAssertAfterLevel(); }
    Match( S_COMMA, ",", S_RPAREN|follow);
    ReadExpr( S_RPAREN | S_COMMA | follow, 'r');
    if ( !READ_ERROR() ) { IntrAssertAfterCondition(); }
    if ( Symbol == S_RPAREN )
      {
	Match( S_RPAREN, ")", follow);
	if ( !READ_ERROR() ) { IntrAssertEnd2Args(); }
      }
    else if ( Symbol == S_COMMA )
      {
	Match( S_COMMA, "", 0L);
	ReadExpr( S_RPAREN |  follow, 'r');
	Match( S_RPAREN, ")", follow);
	if ( !READ_ERROR() ) { IntrAssertEnd3Args(); }
      }
}


/****************************************************************************
**
*F  ReadIf(<follow>)  . . . . . . . . . . . . . . . . .  read an if statement
**
**  'ReadIf' reads an if-statement.  In case of an error it skips all symbols
**  up to one contained in <follow>.
**
**      <Statement>     :=    'if'   <Expr> 'then' <Statments>
**                          { 'elif' <Expr> 'then' <Statments> }
**                          [ 'else'               <Statments> ]
**                            'fi' ';'
*/
void            ReadIf (
    TypSymbolSet        follow )
{
    volatile UInt       nrb;            /* number of branches              */
    volatile UInt       nrs;            /* number of statements in a body  */

    /* 'if' <Expr>  'then' <Statments>                                     */
    nrb = 0;
    if ( ! READ_ERROR() ) { IntrIfBegin(); }
    Match( S_IF, "if", follow );
    ReadExpr( S_THEN|S_ELIF|S_ELSE|S_FI|follow, 'r' );
    Match( S_THEN, "then", STATBEGIN|S_ELIF|S_ELSE|S_FI|follow );
    if ( ! READ_ERROR() ) { IntrIfBeginBody(); }
    nrs = ReadStats( S_ELIF|S_ELSE|S_FI|follow );
    if ( ! READ_ERROR() ) { IntrIfEndBody( nrs ); }
    nrb++;

    /* { 'elif' <Expr>  'then' <Statments> }                               */
    while ( Symbol == S_ELIF ) {
        if ( ! READ_ERROR() ) { IntrIfElif(); }
        Match( S_ELIF, "elif", follow );
        ReadExpr( S_THEN|S_ELIF|S_ELSE|S_FI|follow, 'r' );
        Match( S_THEN, "then", STATBEGIN|S_ELIF|S_ELSE|S_FI|follow );
        if ( ! READ_ERROR() ) { IntrIfBeginBody(); }
        nrs = ReadStats( S_ELIF|S_ELSE|S_FI|follow );
        if ( ! READ_ERROR() ) { IntrIfEndBody( nrs ); }
        nrb++;
    }

    /* [ 'else' <Statments> ]                                              */
    if ( Symbol == S_ELSE ) {
        if ( ! READ_ERROR() ) { IntrIfElse(); }
        Match( S_ELSE, "else", follow );
        if ( ! READ_ERROR() ) { IntrIfBeginBody(); }
        nrs = ReadStats( S_FI|follow );
        if ( ! READ_ERROR() ) { IntrIfEndBody( nrs ); }
        nrb++;
    }

    /* 'fi'                                                                */
    Match( S_FI, "fi", follow );
    if ( ! READ_ERROR() ) { IntrIfEnd( nrb ); }
}


/****************************************************************************
**
*F  ReadFor(<follow>) . . . . . . . . . . . . . . . . .  read a for statement
**
**  'ReadFor' reads a for-loop.  In case of an error it  skips all symbols up
**  to one contained in <follow>.
**
**      <Statement>     :=  'for' <Var>  'in' <Expr>  'do'
**                              <Statments>
**                          'od' ';'
*/
void            ReadFor (
    TypSymbolSet        follow )
{
    UInt                nrs;            /* number of statements in body    */

    /* 'for'                                                               */
    if ( ! READ_ERROR() ) { IntrForBegin(); }
    Match( S_FOR, "for", follow );

    /* <Var>                                                               */
    ReadCallVarAss( follow, 'r' );

    /* 'in' <Expr>                                                         */
    Match( S_IN, "in", S_DO|S_OD|follow );
    if ( ! READ_ERROR() ) { IntrForIn(); }
    ReadExpr( S_DO|S_OD|follow, 'r' );

    /* 'do' <Statments>                                                    */
    Match( S_DO, "do", STATBEGIN|S_OD|follow );
    if ( ! READ_ERROR() ) { IntrForBeginBody(); }
    nrs = ReadStats( S_OD|follow );
    if ( ! READ_ERROR() ) { IntrForEndBody( nrs ); }

    /* 'od'                                                                */
    Match( S_OD, "od", follow );
    if ( ! READ_ERROR() ) { IntrForEnd(); }
}


/****************************************************************************
**
*F  ReadWhile(<follow>) . . . . . . . . . . . . . . .  read a while statement
**
**  'ReadWhile' reads a while-loop.  In case of an error it skips all symbols
**  up to one contained in <follow>.
**
**      <Statement>     :=  'while' <Expr>  'do'
**                              <Statments>
**                          'od' ';'
*/
void            ReadWhile (
    TypSymbolSet        follow )
{
    UInt                nrs;            /* number of statements in body    */

    /* 'while' <Expr>  'do'                                                */
    if ( ! READ_ERROR() ) { IntrWhileBegin(); }
    Match( S_WHILE, "while", follow );
    ReadExpr( S_DO|S_OD|follow, 'r' );
    Match( S_DO, "do", STATBEGIN|S_DO|follow );

    /*     <Statments>                                                     */
    if ( ! READ_ERROR() ) { IntrWhileBeginBody(); }
    nrs = ReadStats( S_OD|follow );
    if ( ! READ_ERROR() ) { IntrWhileEndBody( nrs ); }

    /* 'od'                                                                */
    Match( S_OD, "od", follow );
    if ( ! READ_ERROR() ) { IntrWhileEnd(); }
}


/****************************************************************************
**
*F  ReadRepeat(<follow>)  . . . . . . . . . . . . . . read a repeat statement
**
**  'ReadRepeat' reads a  repeat-loop.   In case  of an  error it skips   all
**  symbols up to one contained in <follow>.
**
**      <Statement>     :=  'repeat'
**                              <Statments>
**                          'until' <Expr> ';'
*/
void            ReadRepeat (
    TypSymbolSet        follow )
{
    UInt                nrs;            /* number of statements in body    */

    /* 'repeat'                                                            */
    if ( ! READ_ERROR() ) { IntrRepeatBegin(); }
    Match( S_REPEAT, "repeat", follow );

    /*  <Statments>                                                        */
    if ( ! READ_ERROR() ) { IntrRepeatBeginBody(); }
    nrs = ReadStats( S_UNTIL|follow );
    if ( ! READ_ERROR() ) { IntrRepeatEndBody( nrs ); }

    /* 'until' <Expr>                                                      */
    Match( S_UNTIL, "until", EXPRBEGIN|follow );
    ReadExpr( follow, 'r' );
    if ( ! READ_ERROR() ) { IntrRepeatEnd(); }
}


/****************************************************************************
**
*F  ReadBreak(<follow>) . . . . . . . . . . . . . . .  read a break statement
**
**  'ReadBreak' reads a  break-statement.  In case  of an error  it skips all
**  symbols up to one contained in <follow>.
**
**      <Statement>     :=  'break' ';'
*/
void            ReadBreak (
    TypSymbolSet        follow )
{
    /* skip the break symbol                                               */
    Match( S_BREAK, "break", follow );

    /* interpret the break statement                                       */
    if ( ! READ_ERROR() ) { IntrBreak(); }
}


/****************************************************************************
**
*F  ReadReturn(<follow>)  . . . . . . . . . . . . . . read a return statement
**
**  'ReadReturn'   reads  a  return-statement.   Return  with   no expression
**  following is used  in functions to return void.   In case of an error  it
**  skips all symbols up to one contained in <follow>.
**
**      <Statement>     :=  'return' [ <Expr> ] ';'
**
**  It is still legal to use parenthesis but they  are  no  longer  required,
**  a return statememt is not a function call and should not look  like  one.
*/
void            ReadReturn (
    TypSymbolSet        follow )
{
    /* skip the return symbol                                              */
    Match( S_RETURN, "return", follow );

    /* 'return' with no expression following                               */
    if ( Symbol == S_SEMICOLON ) {
        if ( ! READ_ERROR() ) { IntrReturnVoid(); }
    }

    /* 'return' with an expression following                               */
    else {
        ReadExpr( follow, 'r' );
        if ( ! READ_ERROR() ) { IntrReturnObj(); }
    }
}


/****************************************************************************
**
*F  ReadTryNext(<follow>) . . . . . . . . .  read a try-next-method statement
**
**  'ReadTryNext' reads a try-next-method statement.  In case of an error  it
**  skips all symbols up to one contained in <follow>.
**
**      <Statment>      :=  'TryNextMethod' '(' ')' ';'
*/
void            ReadTryNext (
    TypSymbolSet        follow )
{
    Match( S_TRYNEXT, "TryNextMethod", follow );
    Match( S_LPAREN, "(", follow );
    Match( S_RPAREN, ")", follow );
    if ( ! READ_ERROR() ) {
        IntrRefGVar( GVarName( "TRY_NEXT_METHOD" ) );
        IntrReturnObj();
    }
}


/****************************************************************************
**
*F  ReadQuit(<follow>)  . . . . . . . . . . . . . . . . read a quit statement
**
**  'ReadQuit' reads a  quit  statement.  In case   of an error it skips  all
**  symbols up to one contained in <follow>.
**
**      <Statement>     :=  'quit' ';'
*/
void            ReadQuit (
    TypSymbolSet        follow )
{
    /* skip the quit symbol                                                */
    Match( S_QUIT, "quit", follow );

    /* 'quit' is not allowed in functions                                  */
    if ( CountNams != 0 ) {
        SyntaxError("'quit' must not be used in functions");
    }

    /* interpret the quit                                                  */
    if ( ! READ_ERROR() ) { IntrQuit(); }
}


/****************************************************************************
**
*F  ReadStats(<follow>) . . . . . . . . . . . . . . read a statement sequence
**
**  'ReadStats' reads a statement sequence.  In case of an error it skips all
**  symbols up to one contained in <follow>.
**
**      <Statments>     :=  { <Statment> }
**
**      <Statment>      :=  <Var> ':=' <Expr> ';'
**                      |   <Var> '(' [ <Expr> { ',' <Expr> } ] ')' ';'
**                      |   'Unbind' '(' <Var> ')' ';'
**                      |   'if'   <Expr>  'then' <Statments>
**                        { 'elif' <Expr>  'then' <Statments> }
**                        [ 'else'                <Statments> ] 'fi' ';'
**                      |   'for' <Var> 'in' <Expr> 'do' <Statments> 'od' ';'
**                      |   'while' <Expr>  'do' <Statments>  'od' ';'
**                      |   'repeat' <Statments>  'until' <Expr> ';'
**                      |   'break' ';'
**                      |   'return' [ <Expr> ] ';'
**                      |   ';'
*/
UInt            ReadStats (
    TypSymbolSet        follow )
{
    short               nr;            /* number of statements            */

    /* read the statements                                                 */
    nr = 0;
    while ( IS_IN( Symbol, STATBEGIN|S_SEMICOLON ) ) {

        /* read a statement                                                */
        if      ( Symbol == S_IDENT  ) { ReadCallVarAss(follow,'s'); nr++; }
        else if ( Symbol == S_UNBIND ) { ReadUnbind(    follow    ); nr++; }
        else if ( Symbol == S_INFO   ) { ReadInfo(      follow    ); nr++; }
        else if ( Symbol == S_ASSERT ) { ReadAssert(    follow    ); nr++; }
        else if ( Symbol == S_IF     ) { ReadIf(        follow    ); nr++; }
        else if ( Symbol == S_FOR    ) { ReadFor(       follow    ); nr++; }
        else if ( Symbol == S_WHILE  ) { ReadWhile(     follow    ); nr++; }
        else if ( Symbol == S_REPEAT ) { ReadRepeat(    follow    ); nr++; }
        else if ( Symbol == S_BREAK  ) { ReadBreak(     follow    ); nr++; }
        else if ( Symbol == S_RETURN ) { ReadReturn(    follow    ); nr++; }
        else if ( Symbol == S_TRYNEXT) { ReadTryNext(   follow    ); nr++; }
        Match( S_SEMICOLON, ";", follow );
    
    }

    /* return the number of statements                                     */
    return nr;
}


/****************************************************************************
**
*V  ReadEvalResult  . . . . . . . . result of reading one command immediately
*/
Obj             ReadEvalResult;


/****************************************************************************
**
*F  ReadEvalCommand() . . . . . . . . . . . . . . . . . . .  read one command
**
**  'ReadEvalCommand' reads one command and interprets it immediately.
**
**  It does not expect the  first symbol of its input  already read and  wont
**  read the  first symbol of the  next  input.
*/
UInt            ReadEvalCommand ( void )
{
    UInt                type;
    Obj                 stackNams;
    UInt                countNams;
    UInt                readTop;
    UInt                readTilde;
    UInt                currLHSGVar;
    jmp_buf             readJmpError;

    /* get the first symbol from the input                                 */
    Match( Symbol, "", 0UL );

    /* if we have hit <end-of-file>, then give up                          */
    if ( Symbol == S_EOF )  { return 16; }

    /* print only a partial prompt from now on                             */
    Prompt = "> ";

    /* remember the old reader context                                     */
    stackNams   = StackNams;
    countNams   = CountNams;
    readTop     = ReadTop;
    readTilde   = ReadTilde;
    currLHSGVar = CurrLHSGVar;
    memcpy( readJmpError, ReadJmpError, sizeof(jmp_buf) );

    /* intialize everything and begin an interpreter                       */
    StackNams   = NEW_PLIST( T_PLIST, 16 );
    CountNams   = 0;
    ReadTop     = 0;
    ReadTilde   = 0;
    CurrLHSGVar = 0;
    IntrBegin();

    /* read an expression or an assignment or a procedure call             */
    if      ( Symbol == S_IDENT  ) { ReadExpr(   S_SEMICOLON|S_EOF, 'x' ); }

    /* otherwise read a statement                                          */
    else if ( Symbol == S_UNBIND ) { ReadUnbind( S_SEMICOLON|S_EOF      ); }
    else if ( Symbol == S_INFO   ) { ReadInfo(   S_SEMICOLON|S_EOF      ); }
    else if ( Symbol == S_ASSERT ) { ReadAssert( S_SEMICOLON|S_EOF      ); }
    else if ( Symbol == S_IF     ) { ReadIf(     S_SEMICOLON|S_EOF      ); }
    else if ( Symbol == S_FOR    ) { ReadFor(    S_SEMICOLON|S_EOF      ); }
    else if ( Symbol == S_WHILE  ) { ReadWhile(  S_SEMICOLON|S_EOF      ); }
    else if ( Symbol == S_REPEAT ) { ReadRepeat( S_SEMICOLON|S_EOF      ); }
    else if ( Symbol == S_BREAK  ) { ReadBreak(  S_SEMICOLON|S_EOF      ); }
    else if ( Symbol == S_RETURN ) { ReadReturn( S_SEMICOLON|S_EOF      ); }
    else if ( Symbol == S_TRYNEXT) { ReadTryNext(S_SEMICOLON|S_EOF      ); }
    else if ( Symbol == S_QUIT   ) { ReadQuit(   S_SEMICOLON|S_EOF      ); }

    /* otherwise try to read an expression                                 */
    else                           { ReadExpr(   S_SEMICOLON|S_EOF, 'r' ); }

    /* every statement must be terminated by a semicolon                   */
    if ( Symbol != S_SEMICOLON ) {
        SyntaxError( "; expected");
    }

    /* end the interpreter                                                 */
    if ( ! READ_ERROR() ) {
        type = IntrEnd( 0UL );
    }
    else {
        IntrEnd( 1UL );
        type = 32;
    }

    /* switch back to the old reader context                               */
    memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
    StackNams   = stackNams;
    CountNams   = countNams;
    ReadTop     = readTop;
    ReadTilde   = readTilde;
    CurrLHSGVar = currLHSGVar;

    /* copy the result (if any)                                            */
    ReadEvalResult = IntrResult;

    /* return whether a return-statement or a quit-statement were executed */
    return type;
}


/****************************************************************************
**
*F  ReadEvalError() . . . . . . . . . . . . . . . . . .  return with an error
*/
void            ReadEvalError ( void )
{
    longjmp( ReadJmpError, 1 );
}


/****************************************************************************
**
*F  InitRead()  . . . . . . . . . . . . . . . . . . . . initialize the reader
**
**  'InitRead' initializes the reader.
*/
void            InitRead ( void )
{
    InitGlobalBag( &ReadEvalResult );
    InitGlobalBag( &StackNams );
}



