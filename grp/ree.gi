#############################################################################
##
#W  ree.gi                     GAP library
##
##
#Y  (C) 2001 School Math. Sci., University of St Andrews, Scotland
##

#############################################################################
##
#M  ReeGroupCons( <IsMatrixGroup>, <q> )
##
InstallMethod(ReeGroupCons,"matrix",true,
  [IsMatrixGroup,IsPosInt],0, 
function ( filter, q )
local theta, m, f, bas, one, zero, x, h, r, gens, G, i;

  m:=Int((LogInt(q,3)-1)/2);
  if m<0 or q<>3^(1+2*m) then
    Error("Usage: ReeGroup(<filter>,3^(1+2m))");
  fi;

  theta:=3^m;
  f:=GF(q);
  bas:=BasisVectors(Basis(f));
  one:=One(f);
  zero:=Zero(f);

  x:=function(t,u,v)
    return 
    [[1,t^theta,-u^theta,(t*u)^theta-v^theta,-u-t^(3*theta+1)-(t*v)^theta,
    -v-(u*v)^theta-t^(3*theta+2)-t^theta*u^(2*theta),
    t^theta*v-u^(theta+1)+t^(4*theta+2)-v^(2*theta)
       -t^(3*theta+1)*u^theta-(t*u*v)^theta],
    [0,1,t,u^theta+t^(theta+1),
    -t^(2*theta+1)-v^theta,-u^(2*theta)+t^(theta+1)*u^theta+t*v^theta,
    v+t*u-t^(2*theta+1)*u^theta-(u*v)^theta-t^(3*theta+2)-t^(theta+1)*v^theta],
    [0,0,1,t^theta,-t^(2*theta),v^theta+(t*u)^theta,
    u+t^(3*theta+1)-(t*v)^theta-t^(2*theta)*u^theta],
    [0,0,0,1,t^theta,u^theta,(t*u)^theta-v^theta],
    [0,0,0,0,1,-t,u^theta+t^(theta+1)],
    [0,0,0,0,0,1,-t^theta],
    [0,0,0,0,0,0,1]]*one;
  end;

  h:=function(t)
    return [[t^theta,0,0,0,0,0,0],
    [0,t^(1-theta),0,0,0,0,0],
    [0,0,t^(2*theta-1),0,0,0,0],
    [0,0,0,1,0,0,0],
    [0,0,0,0,t^(1-2*theta),0,0],
    [0,0,0,0,0,t^(theta-1),0],
    [0,0,0,0,0,0,t^(-theta)]]*one;
  end;

  r:=[[0,0,0,0,0,0,-1],
  [0,0,0,0,0,-1,0],
  [0,0,0,0,-1,0,0],
  [0,0,0,-1,0,0,0],
  [0,0,-1,0,0,0,0],
  [0,-1,0,0,0,0,0],
  [-1,0,0,0,0,0,0]]*one;

  # this generating set is not very good -- there is a 2-generator set. AH
  gens:=[];
  for i in bas do
    Add(gens,x(i,zero,zero));
    Add(gens,x(zero,i,zero));
    Add(gens,x(zero,zero,i));
  od;

  Add(gens,h(PrimitiveRoot(f)));
  Add(gens,r);
  G:=Group(gens,One(gens[1]));
  SetName(G,Concatenation("Ree(",String(q),")"));
  SetDimensionOfMatrixGroup(G,7);
  SetFieldOfMatrixGroup(G,f);
  SetIsFinite(G,true);
  SetSize(G,q^3*(q-1)*(q^3+1));
  if q > 3 then SetIsSimpleGroup(G,true); fi;
  return G;
end );

PermConstructor(ReeGroupCons,[IsPermGroup,IsObject], IsMatrixGroup);

#############################################################################
##
#E  ree.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here
