#########################################################33
##
## GAP code linking to Singular's ag code construction
##    via the GAP singular package
##
## gap_singular_agcode.gap,wdj,8-2004
## http://cadigweb.ew.usna.edu/~wdj/gap/singular/gap_singular_agcode.gap
##########################################################

################### priminaries ################
#
#LogTo("/home/wdj/gapfiles/gap_singular_test8.log");
LoadPackage("guava");
LoadPackage("singular");

ag_code_path := DirectoriesPackageLibrary("singular", "contrib" );
for ag_file in [ "all_pts.lib", "rr_space.lib" ] do
    f_ag_file := Filename( ag_code_path, ag_file );
    if not f_ag_file in sing_exec_options then
        Add(sing_exec_options, f_ag_file );
    fi;
od;

StartSingular();



AllPointsOnCurve:=function(f,F)
 # F is a finite field GP(p), where
 #   p is a prime (prime power's not yet implemented)
 # f is a polynomial over GF(p)
 #   representing the curve f(x,y)=0 over GF(p)
 local i,CP,pt,I,L,gens,x,y,indet,g,R;
 L:=[];
 R:=DefaultRing(f);
 indet:= IndeterminatesOfPolynomialRing(R);;
 x:= indet[1];; y:= indet[2];;
 for pt in F do
   g:=x-pt;
   I:= Ideal( R, [f,g] );;
   CP:=SingularInterface("closed_points", [ I ], "list" );
   for i in [1 .. Length(CP) ] do
       gens:=GeneratorsOfIdeal( CP[i] );
 #      Print(pt, "   ", i, "   ", gens,"\n");
 #      if Degree(gens[1])=1 then 
         Add(L,gens);
 #      fi;
   od;
 od;
 return(L);
end;




AGCode:=function(f,G,D)
 # f is a polynomial over GF(p) representing curve f=0,
 #   where p is a prime (prime power's not yet implemented)
 # G, D are disjoint "divisors" on the curve
local agc,genmat,mat,i,j;
 agc:=SingularInterface("ag_code", [ f,1,G,D ], "list" );
 genmat:=agc[1]; # poly coeffs 
 mat:=List([1..Length(genmat)],i->List([1..Length(genmat[1])],j->LeadingCoefficient(genmat[i][j])));
 return([mat,agc[2],agc[3]]);
end;

##
## this ***doesn't work*** (at the moment) in GAP
## 
#RiemannRochSpaceBasis:=function(f,G)
# # f is a polynomial over GF(p) representing curve f=0,
# #   where p is a prime (prime power's not yet implemented)
# # G is a "divisor" on curve f=0
#local rr;
# rr:=SingularInterface("rr_space", [ f,G ], "string" );
# return(rr);
#end;



################### example ################
#
#F:=GF(7);; 
#R2:= PolynomialRing( F, 2);;
#SetTermOrdering(R2, "lp" );; # <--- note the term odering
#indet:= IndeterminatesOfPolynomialRing(R2);;
#x:= indet[1];; y:= indet[2];;
#f:=x^7-y^2-x;;
#AllPointsOnCurve(f,F);
#
#G:=[2,2,0,0,0,0,0]; D:=[4..8];
#agc:=AGCode(f,G,D);
#ag_mat:=agc[1];
#C := GeneratorMatCode( ag_mat, GF(7) );
#MinimumDistance(C);
#
#rr:=RiemannRochSpaceBasis(f,G);


