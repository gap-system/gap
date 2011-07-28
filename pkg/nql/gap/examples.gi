############################################################################
##
#W examples.gi			NQL				René Hartung
##
#H   @(#)$Id: examples.gi,v 1.12 2010/03/17 12:51:26 gap Exp $
##
Revision.("nql/gap/examples_gi"):=
  "@(#)$Id: examples.gi,v 1.12 2010/03/17 12:51:26 gap Exp $";


############################################################################
##
#F  ExamplesOfLPresentations ( <int> )
##
## returns some important examples of L-presented groups (e.g. Grigorchuk).
##
InstallGlobalFunction(ExamplesOfLPresentations,
  function( n )
  local F,F2,		# free group
        rels,		# fixed relators
        sigma,tau,	# endomorphism
        endos,		# set of endomorphisms
        itrels,		# iterated relators
        a,b,c,d,	# free group generators
        t,r,u,v, 	# free group generators
        T,U,V, 		# free group generators
        G,		# L-presented group
	e,f,g,h,i,	# for abbreviation in the Hanoi tower group
	IL;		# info level of InfoNQL


  if n=1 then 
    # The Grigorchuk group on 4 generators
    Info(InfoNQL,1,"The Grigorchuk group on 4 generators from [Lys85]");
    F:=FreeGroup("a","b","c","d");
    a:=F.1;;b:=F.2;;c:=F.3;;d:=F.4;;
    rels:=[a^2,b^2,c^2,d^2,b*c*d];
    sigma:=GroupHomomorphismByImagesNC(F,F,[a,b,c,d],[c^a,d,b,c]);
    endos:=[sigma];
    itrels:=[Comm(d,d^a),Comm(d,d^(a*c*a*c*a))];
    
    G:=LPresentedGroup(F,rels,endos,itrels);
    SetIsInvariantLPresentation(G,true);
    SetSize( G, infinity );
  elif n=2 then
    # The Grigorchuk group on 3 generators
    Info(InfoNQL,1,"The Grigorchuk group on 3 generators");
    F:=FreeGroup("a","c","d");
    a:=F.1;;c:=F.2;;d:=F.3;;
    rels:=[];
    sigma:=GroupHomomorphismByImagesNC(F,F,[a,c,d],[c^a,c*d,c]);
    endos:=[sigma];
    itrels:=[a^2,Comm(d,d^a),Comm(d,d^(a*c*a*c*a))];
  
    G:=LPresentedGroup(F,rels,endos,itrels);
    SetSize( G, infinity );
  elif n=3 then 
    # The lamplighter group \Z_2 \wr \Z
    Info(InfoNQL,1,"The lamplighter group on two lamp states");
    IL := InfoLevel( InfoNQL );
    SetInfoLevel( InfoNQL, 0 );
    G := LamplighterGroup( IsLpGroup, 2 );
    SetInfoLevel( InfoNQL, IL );
    SetSize( G, infinity );
  elif n=4 then 
    # Brunner-Sidki-Vieira group
    Info(InfoNQL,1,"The Brunner-Sidki-Vieira group");
    F:=FreeGroup("a","b");
    a:=F.1;;b:=F.2;;
    rels:=[];
    sigma:=GroupHomomorphismByImagesNC(F,F,[a,b],[b^2*a^(-1)*b^2,b^2]);
    endos:=[sigma];
    itrels:=[Comm(a,a^b),Comm(a,a^(b^3))];
  
    G:=LPresentedGroup(F,rels,endos,itrels);
    SetSize( G, infinity );
  elif n=5 then 
    # The Grigorchuk supergroup
    Info(InfoNQL,1,"The Grigorchuk supergroup");
    F:=FreeGroup("a","b","c","d");
    a:=F.1;;b:=F.2;;c:=F.3;;d:=F.4;;
    rels:=[];
    sigma:=GroupHomomorphismByImagesNC(F,F,[a,b,c,d],[a*b*a,d,b,c]);
    endos:=[sigma];
    itrels:=[a^2,Comm(b,c),Comm(c,c^a),Comm(c,d^a),Comm(d,d^a),Comm(c^(a*b),
             (c^(a*b))^a),Comm(c^(a*b),(d^(a*b))^a),Comm(d^(a*b),(d^(a*b))^a)];
  
    G:=LPresentedGroup(F,rels,endos,itrels);
    SetSize( G, infinity );
  elif n=6 then 
    # The Fabrykowski-Gupta group
    Info(InfoNQL,1,"The Fabrykowski-Gupta group");
    G:=GeneralizedFabrykowskiGuptaLpGroup( 3 );
    SetSize( G, infinity );
  elif n=7 then 
    # The Gupta-Sidki group
    Info(InfoNQL,1,"The Gupta-Sidki group");
    F:=FreeGroup("a","t","u","v");
    a:=F.1;;t:=F.2;;   u:=F.3;;   v:=F.4;;
            T:=F.2^-1;;U:=F.3^-1;;V:=F.4^-1;;

    rels:=[a^3,t^3,t^a/u,t^(a^2)/v];

    itrels:=[ u*T*v*T*U*V*t*v*U*t*U*V*T*u*T*u*v*t*U*t*V*U*v*t*u*V*u*T, 
            u*T*v*T*U*V*T*U*v*U*T*V*u*T*u*v*t*U*t*V*u, 
            u*T*v*T*U*V*t*U*T*u*v*t*U*t*V*U*t*v*u*T*u*V, 
            v*T*u*T*V*U*t*v*U*t*U*V*T*u*t*U*v*t*u*V*u*T, 
            v*T*u*T*V*U*T*U*v*U*T*V*u*t*u, v*T*u*T*V*U*t*U*t*U*t*v*u*T*u*V, 
            T*v*U*t*U*V*T*u*T*v*u*t*V*t*u*v*t*u*V*u*T, U*v*U*T*V*u*T*v*u*t*V*t, 
 	    T*U*T*v*u*t*V*t*u*t*v*u*T*u*V, u*T*v*T*U*V*T*V*u*V*T*U*v*t*v, 
            u*T*v*T*U*V*t*u*V*t*V*U*T*v*t*V*u*t*v*U*v*T, 
            u*T*v*T*U*V*t*V*t*V*t*u*v*T*v*U,
            v*T*u*T*V*U*T*V*u*V*T*U*v*T*v*u*t*V*t*U*v, 
            v*T*u*T*V*U*t*u*V*t*V*U*T*v*T*v*u*t*V*t*U*V*u*t*v*U*v*T, 
            v*T*u*T*V*U*t*V*T*v*u*t*V*t*U*V*t*u*v*T*v*U, 
            V*u*V*T*U*v*T*u*v*t*U*t, T*V*T*u*v*t*U*t*v*t*u*v*T*v*U, 
            T*u*V*t*V*U*T*v*T*u*v*t*U*t*v*u*t*v*U*v*T, 
            t*U*v*U*T*V*u*v*T*u*T*V*U*t*U*t*v*u*T*u*V*T*v*u*t*V*t*U, 
            t*U*v*U*T*V*u*T*U*t*v*u*T*u*V*T*u*v*t*U*t*V, 
            t*U*v*U*T*V*U*T*v*T*U*V*t*U*t*v*u*T*u*V*t, 
            U*v*T*u*T*V*U*t*U*v*t*u*V*u*t*v*u*t*V*t*U,
            U*T*U*v*t*u*V*u*t*u*v*t*U*t*V, T*v*T*U*V*t*U*v*t*u*V*u,
            v*U*t*U*V*T*u*v*T*u*T*V*U*t*u*T*v*u*t*V*t*U, 
            v*U*t*U*V*T*u*T*u*T*u*v*t*U*t*V, v*U*t*U*V*T*U*T*v*T*U*V*t*u*t, 
            t*U*v*U*T*V*U*V*t*V*U*T*v*u*v, t*U*v*U*T*V*u*V*u*V*u*t*v*U*v*T,
            t*U*v*U*T*V*u*t*V*u*V*T*U*v*u*V*t*u*v*T*v*U, 
            V*t*V*U*T*v*U*t*v*u*T*u, U*V*U*t*v*u*T*u*v*u*t*v*U*v*T,
            U*t*V*u*V*T*U*v*U*t*v*u*T*u*v*t*u*v*T*v*U, 
            v*U*t*U*V*T*U*V*t*V*U*T*v*U*v*t*u*V*u*T*v, 
            v*U*t*U*V*T*u*V*U*v*t*u*V*u*T*V*u*t*v*U*v*T, 
            v*U*t*U*V*T*u*t*V*u*V*T*U*v*U*v*t*u*V*u*T*V*t*u*v*T*v*U, 
            V*T*V*u*t*v*U*v*t*v*u*t*V*t*U, 
            V*u*T*v*T*U*V*t*V*u*t*v*U*v*t*u*v*t*U*t*V, T*u*T*V*U*t*V*u*t*v*U*v, 
            t*V*u*V*T*U*v*T*V*t*u*v*T*v*U*T*v*u*t*V*t*U, 
            t*V*u*V*T*U*v*u*T*v*T*U*V*t*V*t*u*v*T*v*U*T*u*v*t*U*t*V, 
            t*V*u*V*T*U*V*T*u*T*V*U*t*V*t*u*v*T*v*U*t, 
            u*V*t*V*U*T*v*T*v*T*v*u*t*V*t*U,  u*V*t*V*U*T*V*T*u*T*V*U*t*v*t, 
            u*V*t*V*U*T*v*u*T*v*T*U*V*t*v*T*u*v*t*U*t*V, 
            V*U*V*t*u*v*T*v*u*v*t*u*V*u*T, U*t*U*V*T*u*V*t*u*v*T*v, 
            V*t*U*v*U*T*V*u*V*t*u*v*T*v*u*t*v*u*T*u*V, 
            t*V*u*V*T*U*v*U*v*U*v*t*u*V*u*T, t*V*u*V*T*U*V*U*t*U*V*T*u*v*u,
            t*V*u*V*T*U*v*t*U*v*U*T*V*u*v*U*t*v*u*T*u*V, 
            u*V*t*V*U*T*v*U*V*u*t*v*U*v*T*U*v*t*u*V*u*T, 
            u*V*t*V*U*T*V*U*t*U*V*T*u*V*u*t*v*U*v*T*u, 
            u*V*t*V*U*T*v*t*U*v*U*T*V*u*V*u*t*v*U*v*T*U*t*v*u*T*u*V ];

    endos:=[ GroupHomomorphismByImagesNC( F, F, [a,t,u,v],
                                          [a,t,T*v*u*t*V*t*U,T*u*v*t*U*t*V]) ];
    G:=LPresentedGroup(F,rels,endos,itrels);
  
    SetUnderlyingInvariantLPresentation(G,
           LPresentedGroup(F,[a^3],endos,itrels));
    SetSize( G, infinity );
  elif n=8 then 
    # An index-3 subgroups of the Gupta-Sidki group
    Info(InfoNQL,1,"An index-3 subgroup of the Gupta-Sidki group");
    F:=FreeGroup("t","u","v");
    t:=F.1;    u:=F.2;    v:=F.3; 
    T:=F.1^-1; U:=F.2^-1; V:=F.3^-1; 
    rels:=[];
    endos:=[GroupHomomorphismByImagesNC(F,F,[t,u,v],
                                            [t,T*v*u*t*V*t*U,T*u*v*t*U*t*V]),
            GroupHomomorphismByImagesNC(F,F,[t,u,v],[u,v,t])];

    itrels:=[ t^3,#u^3, v^3,
            u*T*v*T*U*V*t*v*U*t*U*V*T*u*T*u*v*t*U*t*V*U*v*t*u*V*u*T, 
            u*T*v*T*U*V*T*U*v*U*T*V*u*T*u*v*t*U*t*V*u, 
            u*T*v*T*U*V*t*U*T*u*v*t*U*t*V*U*t*v*u*T*u*V, 
            v*T*u*T*V*U*t*v*U*t*U*V*T*u*t*U*v*t*u*V*u*T, 
            v*T*u*T*V*U*T*U*v*U*T*V*u*t*u, v*T*u*T*V*U*t*U*t*U*t*v*u*T*u*V, 
            T*v*U*t*U*V*T*u*T*v*u*t*V*t*u*v*t*u*V*u*T, U*v*U*T*V*u*T*v*u*t*V*t, 
 	    T*U*T*v*u*t*V*t*u*t*v*u*T*u*V, u*T*v*T*U*V*T*V*u*V*T*U*v*t*v, 
            u*T*v*T*U*V*t*u*V*t*V*U*T*v*t*V*u*t*v*U*v*T, 
            u*T*v*T*U*V*t*V*t*V*t*u*v*T*v*U,
            v*T*u*T*V*U*T*V*u*V*T*U*v*T*v*u*t*V*t*U*v, 
            v*T*u*T*V*U*t*u*V*t*V*U*T*v*T*v*u*t*V*t*U*V*u*t*v*U*v*T, 
            v*T*u*T*V*U*t*V*T*v*u*t*V*t*U*V*t*u*v*T*v*U, 
            V*u*V*T*U*v*T*u*v*t*U*t, T*u*V*t*V*U*T*v*T*u*v*t*U*t*v*u*t*v*U*v*T, 
            T*V*T*u*v*t*U*t*v*t*u*v*T*v*U, 
            t*U*v*U*T*V*u*v*T*u*T*V*U*t*U*t*v*u*T*u*V*T*v*u*t*V*t*U, 
            t*U*v*U*T*V*u*T*U*t*v*u*T*u*V*T*u*v*t*U*t*V, 
            t*U*v*U*T*V*U*T*v*T*U*V*t*U*t*v*u*T*u*V*t, 
            U*v*T*u*T*V*U*t*U*v*t*u*V*u*t*v*u*t*V*t*U,
            U*T*U*v*t*u*V*u*t*u*v*t*U*t*V, T*v*T*U*V*t*U*v*t*u*V*u,
            v*U*t*U*V*T*u*v*T*u*T*V*U*t*u*T*v*u*t*V*t*U, 
            v*U*t*U*V*T*u*T*u*T*u*v*t*U*t*V, v*U*t*U*V*T*U*T*v*T*U*V*t*u*t, 
            t*U*v*U*T*V*U*V*t*V*U*T*v*u*v, t*U*v*U*T*V*u*V*u*V*u*t*v*U*v*T,
            t*U*v*U*T*V*u*t*V*u*V*T*U*v*u*V*t*u*v*T*v*U, 
            V*t*V*U*T*v*U*t*v*u*T*u, U*V*U*t*v*u*T*u*v*u*t*v*U*v*T,
            U*t*V*u*V*T*U*v*U*t*v*u*T*u*v*t*u*v*T*v*U, 
            v*U*t*U*V*T*U*V*t*V*U*T*v*U*v*t*u*V*u*T*v, 
            v*U*t*U*V*T*u*V*U*v*t*u*V*u*T*V*u*t*v*U*v*T, 
            v*U*t*U*V*T*u*t*V*u*V*T*U*v*U*v*t*u*V*u*T*V*t*u*v*T*v*U, 
            V*T*V*u*t*v*U*v*t*v*u*t*V*t*U, 
            V*u*T*v*T*U*V*t*V*u*t*v*U*v*t*u*v*t*U*t*V, T*u*T*V*U*t*V*u*t*v*U*v, 
            t*V*u*V*T*U*v*T*V*t*u*v*T*v*U*T*v*u*t*V*t*U, 
            t*V*u*V*T*U*v*u*T*v*T*U*V*t*V*t*u*v*T*v*U*T*u*v*t*U*t*V, 
            t*V*u*V*T*U*V*T*u*T*V*U*t*V*t*u*v*T*v*U*t, 
            u*V*t*V*U*T*v*T*v*T*v*u*t*V*t*U,  u*V*t*V*U*T*V*T*u*T*V*U*t*v*t, 
            u*V*t*V*U*T*v*u*T*v*T*U*V*t*v*T*u*v*t*U*t*V, 
            V*U*V*t*u*v*T*v*u*v*t*u*V*u*T, U*t*U*V*T*u*V*t*u*v*T*v, 
            V*t*U*v*U*T*V*u*V*t*u*v*T*v*u*t*v*u*T*u*V, 
            t*V*u*V*T*U*v*U*v*U*v*t*u*V*u*T, t*V*u*V*T*U*V*U*t*U*V*T*u*v*u,
            t*V*u*V*T*U*v*t*U*v*U*T*V*u*v*U*t*v*u*T*u*V, 
            u*V*t*V*U*T*v*U*V*u*t*v*U*v*T*U*v*t*u*V*u*T, 
            u*V*t*V*U*T*V*U*t*U*V*T*u*V*u*t*v*U*v*T*u, 
            u*V*t*V*U*T*v*t*U*v*U*T*V*u*V*u*t*v*U*v*T*U*t*v*u*T*u*V ];
  
    G := LPresentedGroup(F,rels,endos,itrels);
    SetSize( G, infinity );
  elif n=9 then 
    # The Basilica group
    Info(InfoNQL,1,"The Basilica group");
    F:=FreeGroup("a","b");
    a:=F.1; b:=F.2;
    rels:=[];
    endos:=[GroupHomomorphismByImagesNC(F,F,[a,b],[b^2,a])];
    itrels:=[Comm(a,a^b)];
    G := LPresentedGroup( F, rels, endos, itrels );
    SetSize( G, infinity );
  elif n=10 then 
    # Gilbert Baumslag's group
    Info(InfoNQL,1,"Baumslag's group");
    F:=FreeGroup("a","b","t","u");
    a:=F.1; b:= F.2; t:=F.3; u:=F.4;
    rels:=[u/b];
    endos:=[GroupHomomorphismByImagesNC(F,F,[a,b,t,u],[a,b,t,u^t]), 
            GroupHomomorphismByImagesNC(F,F,[a,b,t,u],[a,b,t,u^(t^-1)])];
    itrels:=[ a^t/a^4, (b^2)^t/b, Comm(a,u) ];
    G := LPresentedGroup( F, rels, endos, itrels );
    SetIsInvariantLPresentation( G, false );  # as proved in [Har08];
    SetSize( G, infinity );
  elif n = 11 then 
    Info( InfoNQL, 1, "The modified L-presentation of the Basilica Group" );
    F := FreeGroup( "a", "b" );;
    a := F.1; b := F.2;;
    rels := [];;
    endos := [ GroupHomomorphismByImagesNC( F, F, [a,b], [b^2,a] ),
               GroupHomomorphismByImagesNC( F, F, [a,b], [a*b,a^2] ) ];;
    itrels := [ Comm( a, a^b ) ];;
    G := LPresentedGroup( F, rels, endos, itrels );
    SetSize( G, infinity );
  elif n = 12 then 
    Info( InfoNQL, 1, "The Hanoi-Tower group from [BSZ09]" );
    # as determined in Bartholdi, Siegenthaler, Zalesski, 2009
    F := FreeGroup( "a", "b", "c" );;
    a := F.1;; b := F.2;; c := F.3;;
    d := Comm( a, b );
    e := Comm( b, c );
    f := Comm( c, a );
    g := d ^ c;;
    h := e ^ a;;
    i := f ^ b;;
    rels := [ a^2, b^2, c^2 ];
    endos := [ GroupHomomorphismByImagesNC( F, F, [a,b,c], [a,b^c,c^b] ) ];
    itrels := [ d^-1*e*f*i^-1*g*e, h*e^-1*d^-1*f*d*i^-1, e^-1*g^-1*f^-1*e*g*f,
                e^-1*d*h*e^-2*d^-1*h^2, h*g*d^-2*f^-1*g*f*e^-1 ];
    G := LPresentedGroup( F, rels, endos, itrels );
    SetIsInvariantLPresentation( G, true );
    SetSize( G, infinity );
  else
    Error("<n> must be an integer less than 12");
  fi;

  return(G);
  end);


############################################################################
##
#O  FreeEngelGroup ( <n>, <num> )
##
## returns an L-presentation for the Free n-th Engel Group on <num> 
## generators; see Section~2.4 of [Har08].
##
InstallMethod( FreeEngelGroup, 
  "for positive integers", 
  true,
  [IsPosInt,IsPosInt], 0,
  function( c, n )
  local L,	# L-presented Group
        F,	# free group
	gens,	# generators of the free group
	itrel,	# commutators/iterated relator
   	i,	# loop variable
	imgs,	# loop variable to build Endos
        Endos;	# the endomorphism of the free group F 

  Info(InfoNQL,1,"Free ",c,"-Engel group on ",n," generators");
  
  # construct an L-presentation by introducing two "stable letters"
  F:=FreeGroup( n + 2 );

  # generators of the free group
  gens:=GeneratorsOfGroup(F);

  # build the iterated relator ( [u,[u,..[u,v]]] )
  itrel:=Comm(gens[n+1],gens[n+2]);
  for i in [1..c-1] do
    itrel:=Comm(itrel,gens[n+2]);
  od;
  
  # build the endomorphisms
  Endos:=[];
  for i in [1..n] do
    imgs:=ShallowCopy(gens{[1..n]});
    Append(imgs,[gens[i]*gens[n+1],gens[n+2]]);
    Add(Endos,GroupHomomorphismByImagesNC(F,F,gens,imgs));

    imgs:=ShallowCopy(gens{[1..n]});
    Append(imgs,[gens[n+1],gens[i]*gens[n+2]]);
    Add(Endos,GroupHomomorphismByImagesNC(F,F,gens,imgs));

    imgs:=ShallowCopy(gens{[1..n]});
    Append(imgs,[gens[i]^-1*gens[n+1],gens[n+2]]);
    Add(Endos,GroupHomomorphismByImagesNC(F,F,gens,imgs));

    imgs:=ShallowCopy(gens{[1..n]});
    Append(imgs,[gens[n+1],gens[i]^-1*gens[n+2]]);
    Add(Endos,GroupHomomorphismByImagesNC(F,F,gens,imgs));
  od;
  
  return(LPresentedGroup(F,[gens[n+1],gens[n+2]],Endos,[itrel]));
  end);


############################################################################
##
#O  FreeBurnsideGroup( <exp>, <num> )
##
## returns an $L$-presentation for the free Burnside group B(m,n) on
## <num> generators with exponent <exp>; see Section~2.4 of [Har08].
##
InstallMethod( FreeBurnsideGroup,
  "for positive integers",
  true,
  [IsPosInt,IsPosInt], 0,
  function(m,n)
  local F,	# underlying free group  
	gens,	# generators of the free group F
	rels,	# fixed relators
	itrels,	# iterated relators
	endos,	# substitutions of the $L$-presentations
	imgs,	# generators images of a substitution
	j;	# loop variable

  Info(InfoNQL,1,"The Free Burnside Group B(",m,",",n,")\n");

  # introduce a "stable letter"
  F:=FreeGroup(m+1);

  gens:=GeneratorsOfGroup(F);
  rels:=[gens[m+1]];
  itrels:=[gens[m+1]^n];
  endos:=[];
  for j in [1..m] do 
    imgs:=ShallowCopy(gens);
    imgs[m+1]:=imgs[m+1]*gens[j];
    Add(endos,GroupHomomorphismByImagesNC(F,F,gens,imgs));

    imgs:=ShallowCopy(gens);
    imgs[m+1]:=imgs[m+1]*gens[j]^-1;
    Add(endos,GroupHomomorphismByImagesNC(F,F,gens,imgs));
  od;
   
  return(LPresentedGroup(F,rels,endos,itrels));
  end);

############################################################################
##
#O  FreeNilpotentGroup( <c>, <num> )
##
## returns an L-presentation for the free nilpotent group of class <c> 
## on <num> generators; see Section~2.4 of [Har08].
##
InstallMethod(FreeNilpotentGroup,
  "for positive integers",
  true,
  [ IsPosInt, IsPosInt ], 0,
  function(n,c)
  local F, 	# underlying free group
	gens, 	# free generators
	i,j,	# loop variables
	rels,	# fixed relators
	itrels,	# iterated relators
	imgs,	# images under the epimorphism
	endos,	# endomorphisms
	L;	# L presented group

   Info(InfoNQL,1,"Free nilpotent group on ",n," generators of class ",c);

   # underlying free group <n> gens + <c+1> gens for the iterated rels
   F:=FreeGroup(n+c+1);

   # free generators
   gens:=GeneratorsOfGroup(F);
   
   rels:=gens{[n+1..n+c+1]};
   itrels:=[LeftNormedComm(gens{[n+1..n+c+1]})];
   endos:=[];
   for i in [n+1..n+c+1] do
     for j in [1..n] do 
       imgs:=ShallowCopy(gens);
       imgs[i]:=imgs[i]*gens[j];
       Add(endos,GroupHomomorphismByImagesNC(F,F,gens,imgs));

       imgs:=ShallowCopy(gens);
       imgs[i]:=imgs[i]*gens[j]^-1;
       Add(endos,GroupHomomorphismByImagesNC(F,F,gens,imgs));
     od;
   od;
   
   return(LPresentedGroup(F,rels,endos,itrels));
  end);

############################################################################
##
#O  GeneralizedFabrykowskiGuptaLpGroup ( <n> )
##
## returns an L-presentation for the generalized Fabrykowski-Gupta group for
## a positive integer <n>; for details on the L-presentation see [BEH].
##
InstallMethod( GeneralizedFabrykowskiGuptaLpGroup,
  "for a positive integer", true,
  [ IsPosInt ], 0,
  function( p )
  local F,	# underlying free group
	a,r,	# free group generators
	itrels,	# iterated relators
	endos,	# set of endomorphisms
	s,	# list of r^(a^i)'s
	i,j,m,n;# loop variables
 
  F:=FreeGroup("a","r");
  a:=F.1;; r:=F.2;
  s:=List([0..p-1],i-> r^(a^i));;
  Append(s,s);

  itrels:=[a^p];

  for m in [0..p-1] do 
    for n in [0..p-1] do 
      for i in [1..p] do 
        for j in [1..p] do 
          if AbsInt(i-j) in [2..p-2] then
           Add(itrels,Comm( s[i+1]^(s[i]^n), 
                            s[j+1]^(s[j]^m)));
          fi;
        od;   
        Add(itrels,
            s[i+1]^(s[i]^(n+1))/(s[i+1]^(s[i]^n*s[i]^((a^1*s[i]*a^-1)^m))));
      od;
    od;
  od;
  endos:=[ GroupHomomorphismByImagesNC( F, F, [a,r], [ r^(a^-1), r ]) ];
  return( LPresentedGroup( F, [], endos, itrels ) );
  end);

############################################################################
##
#M  LamplighterGroup( <fil>, <int> )
#M  LamplighterGroup( <fil>, <PcGroup> )
##
## returns an L-presentation for the lamplighter group Z_<int> \wr Z
##
InstallMethod( LamplighterGroup,
  "for the filter IsLpGroup and a positive integer",
  [ IsLpGroup, IsPosInt ], 0,
  function( filter, c )
  local F,	# underlying free group
	a,t,u,	# free group generators
	rels,	# fixed relators
	itrels,	# iterated relators
	endos,	# set of endomorphisms
	G;	# the LpGroup 

  Info(InfoNQL,1,"The lamplighter group on ",c," lamp states");
  F:=FreeGroup( "a", "t", "u" );
  a:=F.1;;t:=F.2;;u:=F.3;;
  rels:=[ a^-1*u ];
  endos:=[ GroupHomomorphismByImagesNC(F,F,[a,t,u],[a,t,u^t]) ];
  itrels:=[a^c,Comm(a,u)];
  
  G:=LPresentedGroup( F, rels, endos, itrels );
  SetUnderlyingInvariantLPresentation(G, UnderlyingAscendingLPresentation( G ));
  return( G );
  end);

############################################################################
##
#M  LamplighterGroup( <fil>, <PcGroup> )
##
## returns an L-presentation for the lamplighter group <PcGroup> \wr Z
##
InstallMethod( LamplighterGroup,
  "for the filter IsLpGroup and a cyclic PcGroup",
  [ IsLpGroup, IsPcGroup ], 0, 
  function( filter, C )
  if not IsCyclic(C) then 
    TryNextMethod();
  else 
     return( LamplighterGroup(IsLpGroup,Size(C)) );
  fi;
  end);

############################################################################
##
#M SymmetricGroupCons
##
## `economical' L-presentations for the symmetric groups by L. Bartholdi.
##
############################################################################
InstallMethod( SymmetricGroupCons,
  "for an LpGroup and a positive integer", true,
  [ IsLpGroup, IsPosInt ], 0,
  function( filter, n )
  local F, rels, map, PHI, gens;

  if n < 3 then return( fail ); fi;

  F    := FreeGroup( n-1 );
  rels := [ F.1^2, (F.1*F.2)^3, (F.1*F.3)^2 ];

  gens := GeneratorsOfGroup( F );

  # for p = (1..n)
  PHI :=[ GroupHomomorphismByImagesNC( F, F, gens,
          Concatenation( gens{[2..n-1]}, [ F.1^Product( gens{[2..n-1]} ) ] ) ),

  # for p = (1,2)
          GroupHomomorphismByImagesNC( F, F, gens,
          Concatenation( [ F.1, F.2^F.1 ], gens{[3..n-1]} ) ),

  # for p = (3..n)
          GroupHomomorphismByImagesNC( F, F, gens,
          Concatenation( [ F.1, F.2^F.3 ], gens{[4..n-1]}, 
                         [ F.3^Product( gens{[4..n-1]} ) ] ) ) ];;

  return( LPresentedGroup( F, [], PHI, rels ) );
  end);
