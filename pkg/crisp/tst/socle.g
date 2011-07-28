############################################################################
##
##  radicals.g                      CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: socle.g,v 1.3 2011/05/26 10:04:28 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp");
ReadPackage ("crisp", "tst/samples.g");

primefacs := function (n)

	if n = 1 then
		return [];
	else
		return Set (FactorsInt (n));
	fi;
end;


if PRINT_METHODS then
   TraceMethods (Socle);
   TraceMethods (SocleComponents);
   TraceMethods (PSocleOp);
   TraceMethods (PSocleComponentsOp);
fi;

for G in groups do
   Info (InfoTest, 1, G());
   old := Size (Socle (G()));
   new := Size (SolvableSocle (G()));
   
   if old = fail then
      old := new;
   elif old <> new then
      Error ("different results");
   fi;
  new := Product (SocleComponents (G()), Size);
   if old = fail then
      old := new;
   elif old <> new then
      Error ("different results");
   fi;
   new := Product (SolvableSocleComponents (G()), Size);
   if old = fail then
      old := new;
   elif old <> new then
      Error ("different results");
   fi;
   
   new := Product (primefacs (Size(G())), p -> Size (PSocle (G(), p)));
   if old = fail then
      old := new;
   elif old <> new then
      Error ("different results");
   fi;
   new := Product (primefacs (Size (G())), p -> 
   		Product (PSocleComponents (G(), p), Size));
   if old = fail then
      old := new;
   elif old <> new then
      Error ("different results");
   fi;
od;


for G in insolvgroups do
   Info (InfoTest, 1, G());
   old := Size (SolvableSocle (G()));
   
   new := Product (SolvableSocleComponents (G()), Size);
   if old = fail then
      old := new;
   elif old <> new then
      Error ("different results");
   fi;
   
   new := Product (primefacs (Size(G())), p -> Size (PSocle (G(), p)));
   if old = fail then
      old := new;
   elif old <> new then
      Error ("different results");
   fi;
   new := Product (primefacs (Size(G())), p -> 
   		Product (PSocleComponents (G(), p), Size));
   if old = fail then
      old := new;
   elif old <> new then
      Error ("different results");
   fi;
od;
if PRINT_METHODS then
   UntraceMethods (Socle);
   UntraceMethods (SocleComponents);
   UntraceMethods (PSocleOp);
   UntraceMethods (PSocleComponentsOp);
fi;


############################################################################
##
#E
##
