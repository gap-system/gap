#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_dt_h =
   "@(#)$Id: dt.h,v 4.12 2001/12/20 13:02:42 gap Exp $";
#endif

extern void  UnmarkTree(
                  Obj   z );


extern UInt   Mark(
            Obj   tree,
            Obj   reftree,
            Int   indexx  );


extern Int     AlmostEqual(
                     Obj    tree1,
                     Int    index1,
                     Obj    tree2,
                     Int    index2    );


extern Int     Equal(
               Obj     tree1,
               Int     index1,
               Obj     tree2,
               Int     index2   );



extern Obj    Mark2(
              Obj        tree,
              Int        index1,
              Obj        reftree,
              Int        index2   );


extern UInt    FindTree(
                 Obj     tree,
                 Int     indexx );


extern Obj    MakeFormulaVector(
                          Obj    tree,
                          Obj    pr   );


extern Obj  binomial(
               Obj     n,
               Obj     k    );


extern Int     Leftof(
                Obj     tree1,
                Int     index1,
                Obj     tree2,
                Int     index2    );



extern Int    Leftof2(
                Obj    tree1,
                Int    index1,
                Obj    tree2,
                Int    index2     );



extern Int    Earlier(
                Obj    tree1,
                Int    index1,
                Obj    tree2,
                Int    index2         );

extern void   FindNewReps(
                    Obj     tree,
                    Obj     reps,
                    Obj     pr,
                    Obj     max      );



extern void  FindSubs(
                Obj        tree,
                Int        x,
                Obj        list1,
                Obj        list2,
                Obj        a,
                Obj        b,
                Int        al,
                Int        ar,
                Int        bl,
                Int        br,
                Obj        reps,
                Obj        pr,
                Obj        max       );



extern void    SetSubs(
                 Obj       list,
                 Obj       a,
                 Obj       tree    );



extern void    UnmarkAEClass(
                       Obj      tree,
                       Obj      list  );


extern void    TestTree(
                         Obj     tree);


extern Obj      Part(
                      Obj   list,
                      Int   pos1,
                      Int   pos2         );



/*
**  Functions from dteval.c.
*/
extern void MultGen(
                    Obj     xk,
                    UInt    gen,
                    Obj     power,
                    Obj     pseudoreps    );

extern Obj Power(
                Obj         x,
                Obj         n,
                Obj         pseudoreps     );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoDeepThought() . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoDeepThought ( void );


/****************************************************************************
**

*E  dt.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
**
*/
