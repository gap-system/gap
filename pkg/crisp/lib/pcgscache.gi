#############################################################################
##
##  pcgscache.gi                    CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: pcgscache.gi,v 1.1 2005/12/21 16:51:12 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
Revision.pcgscache_gi :=
    "@(#)$Id: pcgscache.gi,v 1.1 2005/12/21 16:51:12 gap Exp $";


#############################################################################
##
#M  InducedPcgs (<pcgs>, <grp>)
##
##  WARNING: this function replaces the standard library function - if this
##  library function changes, presumably also this function will have to be
##  changed. Also it uses the undocumented attribute HomePcgs.
##
InstallMethod (InducedPcgs, "for group which has a pcgs", IsIdenticalObj,
   [IsPcgs, IsGroup], 1, # replace library method
   function (pcgs, G)
       if IsIdenticalObj( ParentPcgs( HomePcgs( G ) ), ParentPcgs( pcgs ) )  then
           return InducedPcgsWrtHomePcgs( G );
       elif
           HasParent( G ) and HasSpecialPcgs( Parent( G ) ) 
              and IsIdenticalObj( SpecialPcgs( Parent( G ) ), 
                 ParentPcgs( pcgs ) )  then
           return InducedPcgsWrtSpecialPcgs( G );
       else
         return InducedPcgsWrtPcgs (G, ParentPcgs (pcgs));
      fi;
   end);
   

#############################################################################
##
#M  InducedPcgsWrtPcgsOp (<grp>, <pcgs>)
##
InstallMethod (InducedPcgsWrtPcgsOp, "sift existing pcgs",
   [IsGroup and HasPcgs, IsPcgs], 0,
   function (grp, pcgs)
   
      local ppcgs, seq, depths, x;
      ppcgs := ParentPcgs (pcgs);
      depths := [];
      seq := [];
      for x in Reversed (Pcgs (grp)) do
         if not AddPcElementToPcSequence (ppcgs, seq, depths, x) then
            Error ("Pcgs (grp) does not seem to be a pcgs");
         fi;
      od;
      return InducedPcgsByPcSequence (ppcgs, seq);
   end);
   
   
#############################################################################
##
#M  InducedPcgsWrtPcgsOp (<grp>, <pcgs>)
##
InstallMethod (InducedPcgsWrtPcgsOp, "generic method",
   [IsGroup, IsPcgs], 0,
   function (grp, pcgs)
   
      return InducedPcgsByGenerators (ParentPcgs (pcgs), 
         GeneratorsOfGroup (grp));
   end);
   
   
############################################################################
##
#E
##
