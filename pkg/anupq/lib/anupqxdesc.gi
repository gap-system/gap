#############################################################################
####
##
#W  anupqxdesc.gi              ANUPQ package                    Werner Nickel
#W                                                                Greg Gamble
##
##  Installs functions to do recursive development of a descendants tree.
##  If ANUPQ is loaded from XGAP the development is seen graphically.
##    
#H  @(#)$Id: anupqxdesc.gi,v 1.3 2005/08/16 18:48:50 gap Exp $
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.anupqxdesc_gi :=
    "@(#)$Id: anupqxdesc.gi,v 1.3 2005/08/16 18:48:50 gap Exp $";

#############################################################################
##
#F  PqDescendantsTreeCoclassOne([<i>]) . . . generate a coclass one des. tree
##
##  for the <i>th  or  default  interactive  {\ANUPQ}  process,  generates  a
##  descendant tree for the  group  of  the  process  (which  must  be  a  pc
##  $p$-group) consisting of descendants of $p$-coclass 1  and  extending  to
##  the class determined by the option `TreeDepth' (or 6  if  the  option  is
##  omitted). In an  {\XGAP}  session,  a  graphical  representation  of  the
##  descendants tree appears  in  a  separate  window.  Subsequent  calls  to
##  `PqDescendantsTreeCoclassOne' for the same process may be used to  extend
##  the descendant tree from the last descendant  computed  that  itself  has
##  more than one descendant. `PqDescendantsTreeCoclassOne' also accepts  the
##  options  `CapableDescendants'  (or  `AllDescendants')  and  any   options
##  accepted     by     the     interactive     `PqDescendants'      function
##  (see~"PqDescendants!interactive").
##
##  *Notes*
##
##  `PqDescendantsTreeCoclassOne'    first    calls    `PqDescendants'.    If
##  `PqDescendants' has already been called for  the  process,  the  previous
##  value computed is used and a warning is `Info'-ed at `InfoANUPQ" level 1.
##
##  As each descendant is processed its unique  label  defined  by  the  `pq'
##  program and number of descendants is `Info'-ed at `InfoANUPQ' level 1.
##
##  `PqDescendantsTreeCoclassOne' is an  ``experimental''  function  that  is
##  included to demonstrate the sort of things that  are  possible  with  the
##  $p$-group generation machinery.
##
InstallGlobalFunction( PqDescendantsTreeCoclassOne, function( arg )
    local   datarec,  title,  des,  node;

    datarec := ANUPQ_ARG_CHK("PqDescendantsTreeCoclassOne", arg);
    if datarec.procId = 0 then
        Error("non-interactive `PqDescendantsTreeCoclassOne' is not ",
              "currently supported\n");
    fi;
    if IsBound(datarec.treepos) then
        PQX_RECURSE_DESCENDANTS( datarec, 
                                 datarec.treepos.class,
                                 datarec.treepos.node,
                                 datarec.treepos.ndes );
        return;
    fi;

    des := PqDescendants( datarec.procId : StepSize := 1 );
    if IsBound(LOADED_PACKAGES.xgap) then
        title := Concatenation( "Descendants Tree, p=",
                     String( PrimePGroup(datarec.group) ),
                     ", order: ",
                     String( Size(datarec.group) ),
                     ", class <= ",
                     String( VALUE_PQ_OPTION("TreeDepth", 6, datarec) ) );
        if VALUE_PQ_OPTION("CapableDescendants",
                           not VALUE_PQ_OPTION("AllDescendants", true, datarec),
                           datarec) then
            Append( title, ", capable descendants" );
        else
            Append( title, ", all descendants" );
        fi;
        datarec.xgapsheet := GraphicSheet( title, 800, 700 );
        datarec.nextX     := [0, 0];
        node := PQX_PLACE_NEXT_NODE( datarec, 1 );
    else
        node := 0;
    fi;

    PQX_RECURSE_DESCENDANTS( datarec, 2, node, Length(des) );
        
    if datarec.calltype = "non-interactive" then
        PQ_COMPLETE_NONINTERACTIVE_FUNC_CALL(datarec);
        if IsBound( datarec.setupfile ) then
            return true;
        fi;
    fi;
end);

#############################################################################
##
#F  PQX_PLACE_NEXT_NODE( <datarec>, <class> ) . place a node on an XGAP sheet
##
##  places a node for the current descendant of class <class> on the  {\XGAP}
##  sheet `<datarec>.xgapsheet'.
##
InstallGlobalFunction( PQX_PLACE_NEXT_NODE, function( datarec, class )
    local   y,  x;

    y := 40 * class;
    datarec.nextX[class] := datarec.nextX[class] + 16;
    x := datarec.nextX[class];

    Disc( datarec.xgapsheet, x, y, 6 );
    return [x,y];
end);

#############################################################################
##
#F  PQX_MAKE_CONNECTION( <datarec>, <a>, <b> ) . .  join two XGAP sheet nodes
##
##  joins the nodes <a> and <b> on the  {\XGAP}  sheet  `<datarec>.xgapsheet'
##  with a straight line, where <a> and <b> are each `[<x>, <y>]'  coordinate
##  pairs (lists) of integers.
##
InstallGlobalFunction( PQX_MAKE_CONNECTION, function( datarec, a, b )

    Line( datarec.xgapsheet, a[1], a[2], b[1]-a[1], b[2]-a[2] );
end);

#############################################################################
##
#F  PQX_RECURSE_DESCENDANTS(<datarec>,<class>,<parent>,<n>)  extend des. tree
##
##  extends a descendant tree of coclass 1 descendants from the current  `pq'
##  descendant  that  has  <n>  descendants  from  class  <class>  to   class
##  determined by the option `TreeDepth' (or 6, by  default)  from  the  node
##  <parent> which is an `[<x>, <y>]' coordinate pair (list) of integers.
##
InstallGlobalFunction( PQX_RECURSE_DESCENDANTS, 
function( datarec, class, parent, n)
local   i,  node,  nr;

    if class > VALUE_PQ_OPTION("TreeDepth", 6, datarec) then 
        datarec.treepos := rec(class:=class, node:=parent, ndes:=n);
        return;
    fi;

    if parent <> 0 then
        datarec.nextX[class] := datarec.nextX[class] + 14;
    fi;
    for i in [1..n] do
        PQ_PG_RESTORE_GROUP( datarec, class, i );
        PQ_PG_EXTEND_AUTOMORPHISMS( datarec );
        nr := PqPGConstructDescendants( datarec.procId : StepSize := 1 );

        if parent <> 0 and (not datarec.CapableDescendants or nr > 0) then 
            # Place a node on the Graphic Sheet and connect it with its
            # parent node.
            node := PQX_PLACE_NEXT_NODE( datarec, class );
            PQX_MAKE_CONNECTION( datarec, node, parent );
        else
            node := 0;
        fi;
            
        Info(InfoANUPQ, 1, "Number of descendants of group ", datarec.gpnum,
                           " to class ", class, ": ", nr);
        if nr > 0 then
            if IsBound(datarec.nextX) and 
               not IsBound(datarec.nextX[class + 1]) then
                datarec.nextX[class + 1] := 0;
            fi;
            PQX_RECURSE_DESCENDANTS( datarec, class+1, node, nr );
        fi;
    od;
    return;
end);

#E  anupqxdesc.gi . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
