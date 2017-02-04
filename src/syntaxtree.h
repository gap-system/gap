/****************************************************************************
**
*W  syntaxtree.h
**
*/

#ifndef GAP_SYNTAXTREE_H
#define GAP_SYNTAXTREE_H


/****************************************************************************
**
*F  SyntaxTreeFunc(<output>,<func>,<name>,<magic1>,<magic2>) . . . . . . compile
*/
extern Obj SyntaxTreeFunc (
            Char *              output,
            Obj                 func,
            Char *              name,
            Int                 magic1,
            Char *              magic2 );

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoSyntaxTree() . . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoSyntaxTree ( void );

#endif // GAP_COMPILER_H

/****************************************************************************
**
*E  syntaxtree.h . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
