############################################################################
##
#W  endos.gi			NQL				René Hartung
##
#H   @(#)$Id: endos.gi,v 1.5 2009/07/02 12:34:34 gap Exp $
##
Revision.("nql/gap/endos_gi"):=
  "@(#)$Id: endos.gi,v 1.5 2009/07/02 12:34:34 gap Exp $";


############################################################################
##
#F  NQL_EndomorphismsOfCover
##
## translates the endomorphisms of the LpGroup to endomorphisms of the 
## covering group and determines the images of the relators in the 
## multiplier.
##
InstallGlobalFunction( NQL_EndomorphismsOfCover,
  function( G, ftl, Imgs, Defs, weights )
  local H,	# covering group as Pcp group
	orders, # relative orders of the covering group
	b,	# first new (pseudo) generator/tail
	Epim,	# epimorphism from LpGroup into the covering group 
        fam, 	# family of an LpGroup element
        map,	# loop variable to determine 'endos'
	imgs,	# loop variable to build the endomorphisms
	endos,	# set of endomorphisms of the covering group
	obj, 	# loop variable do determine the 'imgs'
	i,j,k,	# loop variables
	w,	# word in the Pcp group
	A,	# set of endos as matrices, set of (it.) rels as vectors
        rel, 	# loop variable to determine the images of the (it.) rels
	image;	# exponent vector of each (iterated) relation

	
  # family of an LpGroup element (for the mappings)
  fam:=FamilyObj(GeneratorsOfGroup( G )[1]);

  # covering group (possibly inconsistent)
  H:=PcpGroupByCollectorNC(ftl);
  orders:=RelativeOrders(ftl);

  # first position of a new (pseudo) generator
  b:=Position(weights,Maximum(weights));

  # build the epimorphism into the covering group
  imgs:=[];
  for i in [1..Length(Imgs)] do
    if IsInt(Imgs[i]) then 
      imgs[i]:=PcpElementByGenExpList(ftl,[Imgs[i],1]);
    else
      imgs[i]:=PcpElementByGenExpList(ftl,Imgs[i]);
    fi;
  od;
  Epim:=GroupHomomorphismByImagesNC( G , H , GeneratorsOfGroup( G ), imgs );
	  
  # build the endomorphisms of the covering group 
  endos:=[];
  for map in EndomorphismsOfLpGroup( G ) do
    imgs:=[];
    for j in [1..Length(Defs)] do 
      if IsInt(Defs[j]) then
	if Defs[j]>0 and weights[j]=1 then 
	  # generator of G/G'

	  # map is an endomorphism of the free group (no LpGroup-element)
	  imgs[j]:=ElementOfLpGroup(fam,
                        FreeGeneratorsOfLpGroup( G )[Defs[j]]^map)^Epim;

          if NQL_TEST_ALL then 
            if j>=b and not PositionNonZero(Exponents(imgs[j]))>=b then 
              Info(InfoNQL,3,"wrong image of type 1\n");
              return(fail);
            fi;
          fi;
        elif Defs[j]>0 and weights[j]>1 then 
          # pseudo generator defined by an image
          w:=One(H);
          for k in [1,3..Length(Imgs[Defs[j]])-3] do
            if not IsBound(imgs[Imgs[Defs[j]][k]]) then 
              Error("in computing the endomorphism\n");
            fi; 
            w:=w*(imgs[Imgs[Defs[j]][k]]^Imgs[Defs[j]][k+1]);
          od;
          # map is an endomorphism of the free group (no LpGroup-element)
          imgs[j]:=w^-1* ElementOfLpGroup(fam,
                         FreeGeneratorsOfLpGroup( G )[Defs[j]]^map)^Epim;
          if NQL_TEST_ALL then 
            if j>=b and not PositionNonZero(Exponents(imgs[j]))>=b then 
              Info(InfoNQL,3,"wrong image of type 2\n");
              return(fail);
            fi;
          fi;
        elif Defs[j]<0 then 
          # pseudo generator from power relation
          w:=One(H);
          obj:=GetPower(ftl,-Defs[j]);
          obj:=obj{[1..Length(obj)-2]};
          for k in [1,3..Length(obj)-1] do
            w:=w*imgs[obj[k]]^obj[k+1];
          od;

          imgs[j]:=w^-1*imgs[-Defs[j]]^orders[-Defs[j]];

          if NQL_TEST_ALL then
            if j>=b and not PositionNonZero(Exponents(imgs[j]))>=b then 
              Info(InfoNQL,3,"wrong image of type 3\n");
              return(fail);
            fi;
          fi;
        else
          Error("Strange Entry in Defs\n");
        fi;
      elif IsList(Defs[j]) then 
        # (pseudo) generator from COMM ( Defs[i][1], Defs[i][2] )
        w:=One(H);
        obj:=GetConjugate(ftl,Defs[j][1],Defs[j][2]);
        obj:=obj{[3..Length(obj)-2]};
        for k in [1,3..Length(obj)-1] do
          w:=w*imgs[obj[k]]^obj[k+1];
        od;
         
        imgs[j]:=w^-1*Comm(imgs[Defs[j][1]],imgs[Defs[j][2]]);
        if NQL_TEST_ALL then 
          if j>=b and not PositionNonZero(Exponents(imgs[j]))>=b then 
            Info(InfoNQL,3,"wrong image of type 4\n");
            return(fail);
          fi;
        fi;
      else
        Error("Strange Entry in Defs\n");
      fi;
    od;
    Add(endos,imgs);
  od;

  # return a record containing the endomorphisms
  # and the relators under Epim
  A:=rec();
  
  # endomorphisms on T by matrices
  A.Endomorphisms:=[];
  for i in [1..Length(endos)] do
    A.Endomorphisms[i]:=[];
    for k in [b..Length(endos[i])] do
      if not IsZero(Exponents(endos[i][k]){[1..b-1]}) then 
        Info(InfoNQL,3,"L-presentation is not invariant\n");
        return(fail);
      fi;
      Add(A.Endomorphisms[i],Exponents(endos[i][k]){[b..Length(weights)]});
    od;
  od;

  # the fixed relators
  A.Relations:=[];
  for rel in FixedRelatorsOfLpGroup( G ) do
    image:=ElementOfLpGroup(fam,rel)^Epim;
    if not IsZero(Exponents(image){[1..b-1]}) then 
      Error("in NQL_EndomorphismsOfCover: wrong image in cover\n");
    fi;
    Add(A.Relations,Exponents(image){[b..Length(weights)]});
  od;

  # the iterated relators
  A.IteratedRelations:=[];
  for rel in IteratedRelatorsOfLpGroup( G ) do
    image:=ElementOfLpGroup(fam,rel)^Epim;
    if not IsZero(Exponents(image){[1..b-1]}) then 
      Error("in NQL_EndomorphismsOfCover: wrong image in cover\n");
    fi;
    Add(A.IteratedRelations,Exponents(image){[b..Length(weights)]});
  od;

  return(A);
  end);
