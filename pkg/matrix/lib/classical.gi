# default is set to everything is possible. We do not store case-dependent
# information in a single flag.

InstallMethod(RecognitionInfoRec,"initial value",true,[IsMatrixGroup],0,
function(G)
local f;
  f:=DefaultFieldOfMatrixGroup(G);
  return rec(group:=G,
	     E:=[],
	     LE:=[],
             d:=DimensionOfMatrixGroup(G),
	     q:=Size(f),
	     p:=Characteristic(f),
	     a:=DegreeOverPrimeField(f),
	     field:=f,
	     module:=GModuleByMats(GeneratorsOfGroup(G),f),
	     #the possible over larger field for both e-values
	     possibleLarge:=[fail,fail],
	     # ruled out extension cases, depending on the differnet
	     # recognition cases (RC_CASES list)
	     ruledOut:=[],
	     count:=0);
end);

InstallGlobalFunction(CleanRecognitionInfo,function(INF)
local i;
  # preserve E,LE,basic
  for i in RecNames(INF) do
    if INF.(i)=RC_IGNORE then
      Unbind(INF.(i));
    fi;
  od;
  Unbind(INF.Case);
  INF.caseFail:=false;
  INF.count:=0;
  Unbind(INF.limit);
end);

InstallRCDeduction(FormType,
function(INF)
  if Case(INF)=UNKNOWN then
    SetzCase(INF,FormType(INF));
  elif Case(INF)<>FormType(INF) then
    INF.caseFail:=true;
    Error("inconsistent");
  fi;
end);

InstallGlobalFunction(RC_ApplicableParameters,function(INF)
local d;
  d:=INF.d;
  if d<=2 then
    INF.caseFail:=true;
  fi;
  #TODO
end);

InstallRCDeduction(Case,
function(INF)
  if HatFormType(INF) and Case(INF)<>FormType(INF) then
    Error("inconsistent");
  fi;
  RC_ApplicableParameters(INF);
end);

######################################################################
##
#F  RC_ReducibilityTest
##   
InstallGlobalFunction(RC_ReducibilityTest,function( INF,  cpol )
local   deg,  dims,  g;

  if not HatRC_IsReducible(INF) then
    
    # compute the degrees of the irreducible factors
    deg := List(Factors(cpol), DegreeOfUnivariateLaurentPolynomial);
    
    # compute all possible dims (one could restrict this to 2s <=d)
    dims := [0];
    for g  in deg  do
        UniteSet( dims, dims+g );
    od;
    
    if not IsBound(INF.dimsReducible) then
      INF.dimsReducible:=dims;
    else
      IntersectSet(INF.dimsReducible,dims);
    fi;

    # G acts irreducibly if only 0 and d are possible
    if 2 = Length(INF.dimsReducible)  then
	SetzRC_IsReducible(INF,false);
        Info(InfoRecog,2,"<G> acts irreducibly, block criteria failed\n");
    fi;
    
  fi;
end);

InstallRCMethod(RC_IsReducible,function(I)
  return not MTX.IsIrreducible(I.module);
end);
                   
######################################################################
##
#F  TestRandomElement( INF )
##   
##  The  function  TestRandomElement() takes  a  group  <grp>  and  an
##  element <g> as  input.  It is assumed that  grp contains a  record
##  component   'recog'  storing  information   for  the   recognition
##  algorithm.  TestRandomElement() calls the  function IsPpdElement()
##  to determine whether <g> is a ppd(d, q;e)-element for some d/2 < e
##  <= d, and whether it is large.  If <g> is a ppd(d,q;e)-element the
##  value e is  added to  the set  grp.recognise.E, which records  all
##  values e  for  which  ppd-elements  have  been  selected.  If,  in
##  addition,  <g>   is   large,  e   is   also  stored   in  the  set
##  grp.recognise.LE,  which records all  values e  for which a  large
##  ppd-element has been selected.  The component grp.recognise.basic,
##  is  used to record  one value e for which a basic  ppd-element has
##  been  found,  as we  only require  one basic  ppd-element  in  our
##  algorithm.  Until such an element has been  found it is set to the
##  value 'false'.   Therefore the  function TestRandomElement()  only
##  calls the  function IsPpdElement() with input  parameters <g>, d*a
##  and p  if grp.recognise.basic  is  'false'.   If <g>  is  a  basic
##  ppd(d,q;e)-element then e is stored as grp.recognise.basic.
##  
InstallGlobalFunction(TestRandomElement,function(INF)
local   ppd, bppd, cpol,g;

  g := PseudoRandom(INF.group);
  INF.count:=INF.count+1;
  
  # compute the characteristic polynomial
  cpol := CharacteristicPolynomial( g );
  RC_ReducibilityTest( INF,  cpol );
  ppd := IsPpdElement( INF.field, cpol, INF.d, INF.q, 1 );
  if ppd = false then
    return INF.d;
  fi;
  
  AddSet( INF.E, ppd[1] );
  if ppd[2] = true then
    AddSet( INF.LE, ppd[1] );
  fi;
  if not HatBasicPPD(INF) then
      # We only need one basic ppd-element. 
      # Also each basic ppd-element is a ppd-element.
      bppd := IsPpdElement( INF.field, cpol, INF.d, INF.p, INF.a);
      if bppd <> false then
	SetzBasicPPD(INF,bppd[1]);
      fi;
  fi;
  
  return ppd[1];
end);

######################################################################
## 
#F  IsGeneric(INF ) . . . . . . .  is <grp> a generic subgroup
##
##   In  our  algorithm we attempt to find two different ppd-elements,
##  that is  a ppd(d, q; e_1)-element and a ppd(d, q; e_2)-element for
##  d/2 < e_1 < e_2 <= d.  We also require that  at least one  of them
##  is a large ppd-element and one  is a  basic ppd-element.   In that
##  case  <grp> is  a  generic  subgroup  of  GL(d,q).   The  function
##  IsGeneric()  takes  as  input  the  parameters <grp> and  <N_gen>.
##  It chooses up to <N_gen> random elements in <grp>.  If among these
##  it  finds  the  two  required  different  ppd-elements,  which  is
##  established   by    examining    the    sets    <grp>.recognise.E,
##  <grp>.recognise.LE,  and  <grp>.recognise.basic,  then it  returns  
##  true. If after <N_gen> independent  random selections  it fails to
##  find two  different  ppd-elements,  the  function returns 'false';
##  
InstallRCMethod(IsGeneric,function(INF)
local   b,  N,  g;
    
    b := INF.d;
    while INF.count<=INF.limit do
        TestRandomElement( INF);
        if Length(INF.E) >= 2 and Length(INF.LE) >= 1 and HatBasicPPD(INF) then
	  return true;
        fi;
    od;
    return UNKNOWN;
end);

#############################################################################
##
##  RuledOutExtFieldParameters
##
InstallGlobalFunction(RuledOutExtFieldParameters,function (INF)
local differmodfour, d, q, E,wert,casepos;
    
  casepos:=Position(RC_CASES,INF.Case);
  if not IsBound(INF.ruledOut[casepos]) then
    wert:=fail;
    d := INF.d;
    q := INF.q;
    E := INF.E;

    differmodfour := E->ForAny([2..Length(E)],x->(E[x]-E[1]) mod 4 <>0);

    if INF.Case  = RC_LINEAR then 
        if not IsPrime(d) 
           or  E <> Set([d-1,d])  
           or d-1 in  INF.LE then
            wert:= true;
        fi;
    elif INF.Case = RC_UNITARY then
        wert:=  true;
    elif INF.Case = RC_SYMPLECTIC then
        if d mod 4 = 2 and q mod 2 = 1 then
            wert:= (PositionProperty( E, x ->(x mod 4 = 0)) <> false); 
        elif d mod 4 = 0 and q mod 2 = 0 then
            wert:= (PositionProperty( E, x -> (x mod 4 = 2)) <> false);
        elif d mod 4 = 0 and q mod 2 = 1 then
            wert:= differmodfour(E);
        elif d mod 4 = 2 and q mod 2 = 0 then
            wert:= (Length(E) > 0);  
        else
            Error("d cannot be odd in case Sp");
        fi;            
    elif INF.Case = RC_ORTHPLUS then
        if d mod 4 = 2  then
            wert:= (PositionProperty (E, x -> (x mod 4 = 0 )) <> false);
        elif d mod 4 = 0  then
            wert:= differmodfour(E);
        else  Error("d cannot be odd in case O+");
        fi;
    elif INF.Case = RC_ORTHMINUS then
        if d mod 4 = 0  then
            wert:= (PositionProperty ( E, x -> (x mod 4 = 2)) <> false);
        elif d mod 4 = 2  then
            wert:= differmodfour(E);
        else  Error("d cannot be odd in case O-");
        fi;
    elif INF.Case = RC_ORTHCIRCLE then
        wert:= true;
    fi;

    if wert=fail then
      wert:=false;
    fi;
    INF.ruledOut[casepos]:=wert;
  fi;
  return INF.ruledOut[casepos];
end);

#############################################################################
##
##  RC_IsExtensionField
##
BindGlobal("DoRC_IsExtField",function(INF,N_ext)
local   grp,b, g,  ppd,  N,  testext;

  grp:=INF.group;
  b := INF.d;
  if Length(INF.E) > 0 then 
      b := Gcd(UnionSet(INF.E,[INF.d])); 
  fi;

  if b = INF.bx then
    if RuledOutExtFieldParameters(INF) then
      return false;
    fi;
  fi;

  while INF.count <= N_ext do
      ppd := TestRandomElement(INF); 
      if b > INF.bx then 
	  b := Gcd(b, ppd); 
      fi;
      if b = INF.bx or b=1 then
	  return false;
      fi;
      if b = INF.bx then
	# force computation of a form -- that's how we ensure linear type
	FormType(INF);
	if INF.Case in [ RC_LINEAR,  RC_UNITARY, RC_ORTHCIRCLE  ] then 
	  INF.bx:=1;
	fi;
      fi;

    if b=INF.bx and HatFormType(INF) then
      if RuledOutExtFieldParameters(INF) then
	return false;
      fi;
    fi;
  od;
  
  Info(InfoRecog,1,"The group could preserve an extension field");
  return true;
end);

InstallGlobalFunction(RC_IsExtensionField,function( INF, N_ext )
local w;
  if INF.Case in [ RC_LINEAR,  RC_UNITARY, RC_ORTHCIRCLE  ] then 
    INF.bx := 1;
  else
    INF.bx := 2;
  fi;

  if INF.possibleLarge[INF.bx]=fail then
    w:=DoRC_IsExtField(INF,N_ext);



    INF.possibleLarge[INF.bx]:=w;
  fi;

  return INF.possibleLarge[INF.bx];
end);

#############################################################################
##
##  RecogniseClassicalNP
##
InstallGlobalFunction(RecogniseClassicalNP,function( arg )
    
    local   grp,  N,  forms,  case, a,  module,INF;

    if not Length(arg)  in [1..3] then
        Error("usage: RecogniseClassicalNP( <grp> [, [case], N]])" );
    fi;

    grp := arg[1];

    case := UNKNOWN;
    N := 25;

    for a  in arg{[ 2 .. Length(arg) ]}  do
        # the cases
        if a = "sl" or a = RC_LINEAR  then
            case := RC_LINEAR;
        elif a = "sp" or a = RC_SYMPLECTIC  then
            case := RC_SYMPLECTIC;
        elif a = "su" or a = "u" or a = RC_UNITARY  then
            case := RC_UNITARY;
        elif a = "o0" or a = "orthogonalzero" or a = RC_ORTHCIRCLE  then
            case := RC_ORTHCIRCLE;
        elif a = "o+" or a = RC_ORTHPLUS  then
            case := RC_ORTHPLUS;
        elif a = "o-" or a = RC_ORTHMINUS  then
            case := RC_ORTHMINUS;

            # number of elements
        elif IsInt(a) and 0 <= a  then
            N := a;

        # unknown parameter
        else
            Error( "unknown parameter ", a );
        fi;
    od;

    INF:=RecognitionInfoRec(grp);
    CleanRecognitionInfo(INF);
    INF.limit:=N;

    SetzCase(INF,case);

    #TODO: GenericParameters

    IsGeneric(INF);

    if Case(INF)=UNKNOWN then
      FormType(INF);
    fi;

    if RC_IsExtensionField(INF,N) then
      return false;
    fi;

    #TODO: IsGenericNearlySimple

    if RC_IsReducible(INF) then
      return false;
    fi;
Print("Case is:",Case(INF),"\n");
    Error("end");
    SetGroupType(INF.group,Case(INF));
    return Case(INF);

end);

InstallMethod(GroupType,"initial value",true,[IsMatrixGroup],0,
function(G)
  return RecogniseClassicalNP(G);
end);
