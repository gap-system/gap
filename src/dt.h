#ifdef  INCLUDE_DECLARATION_PART
char * Revision_dt_h =
   "@(#)$Id$";
#endif

extern void  UnmarkTree(
                  Obj   z );


extern UInt   Mark(
            Obj   tree,
            Obj   reftree,
            int   index  );


extern int     AlmostEqual(
                     Obj    tree1,
                     int    index1,
                     Obj    tree2,
                     int    index2    );


extern int     Equal(
               Obj     tree1,
               int     index1,
               Obj     tree2,
               int     index2   );



extern Obj    Mark2(
              Obj        tree,
              int        index1,
              Obj        reftree,
              int        index2   );


extern UInt    FindTree(
                 Obj     tree,
                 int     index );


extern Obj    MakeFormulaVector(
                          Obj    tree,
                          Obj    pr   );


extern Obj  binomial(
               Obj     n,
               Obj     k    );


extern int     Leftof(
                Obj     tree1,
                int     index1,
                Obj     tree2,
                int     index2    );



extern int    Leftof2(
                Obj    tree1,
                int    index1,
                Obj    tree2,
                int    index2     );



extern int    Earlier(
                Obj    tree1,
                int    index1,
                Obj    tree2,
                int    index2         );

extern void   FindNewReps(
                    Obj     tree,
                    Obj     reps,
                    Obj     pr,
                    Obj     max      );



extern void  FindSubs(
                Obj        tree,
                int        x,
                Obj        list1,
                Obj        list2,
                Obj        a,
                Obj        b,
                int        al,
                int        ar,
                int        bl,
                int        br,
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
                      int   pos1,
                      int   pos2         );



extern void     InitDeepThought( void );

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
