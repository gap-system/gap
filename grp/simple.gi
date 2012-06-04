#############################################################################
##
#W  simple.gi                 GAP Library                    Alexander Hulpke
##
##
#Y  Copyright (C) 2011 The GAP Group
##
##  This file contains basic constructions for simple groups of bounded size,
##  if necessary by calling the `atlasrep' package.
##

# data for simple groups of order up to 10^18 that are not L_2(q)
BindGlobal("SIMPLEGPSNONL2",
  [[60,"A",5],[360,"A",6],[2520,"A",7],
  [5616,"L",3,3],[6048,"U",3,3],[7920,"Spor","M(11)"],
  [20160,"A",8],
  [20160,"L",3,4],
  [25920,"S",4,3],[29120,"Sz",8],[62400,"U",3,4],
  [95040,"Spor","M(12)"],[126000,"U",3,5],[175560,"Spor","J(1)"],
  [181440,"A",9],[372000,"L",3,5],[443520,"Spor","M(22)"],
  [604800,"Spor","J(2)"],[979200,"S",4,4],
  [1451520,"S",6,2],[1814400,"A",10],[1876896,"L",3,7],
  [3265920,"U",4,3],[4245696,"G",2,3],[4680000,"S",4,5],
  [5515776,"U",3,8],[5663616,"U",3,7],[6065280,"L",4,3],
  [9999360,"L",5,2],[10200960,"Spor","M(23)"],[13685760,"U",5,2],
  [16482816,"L",3,8],[17971200,"T"],
  [19958400,"A",11],[32537600,"Sz",32],[42456960,"L",3,9],
  [42573600,"U",3,9],[44352000,"Spor","HS"],[50232960,"Spor","J(3)"],
  [70915680,"U",3,11],[138297600,"S",4,7],[174182400,"O+",8,2],
  [197406720,"O-",8,2],[211341312,"3D",4,2],[212427600,"L",3,11],
  [239500800,"A",12],[244823040,"Spor","M(24)"],[251596800,"G",2,4],
  [270178272,"L",3,13],[811273008,"U",3,13],[898128000,"Spor","McL"],
  [987033600,"L",4,4],[1018368000,"U",4,4],[1056706560,"S",4,8],
  [1425715200,"L",3,16],[1721606400,"S",4,9],[2317678272,"U",3,17],
  [3113510400,"A",13],[4030387200,"Spor","He"],
  [4279234560,"U",3,16],[4585351680,"S",6,3],[4585351680,"O",7,3],[5644682640,"L",3,19],
  [5859000000,"G",2,5],[6950204928,"L",3,17],[7254000000,"L",4,5],
  [9196830720,"U",6,2],[10073444472,"R",27],
  [12860654400,"S",4,11],[14742000000,"U",4,5],[16938986400,"U",3,19],
  [20158709760,"L",6,2],[26056457856,"U",3,23],[34093383680,"Sz",128],
  [43589145600,"A",14],[47377612800,"S",8,2],[50778000000,"L",3,25],
  [68518981440,"S",4,13],[78156525216,"L",3,23],
  [145926144000,"Spor","Ru"],[152353500000,"U",3,25],
  [166557358800,"U",3,29],[237783237120,"L",5,3],
  [258190571520,"U",5,3],[282027786768,"L",3,27],
  [282056445216,"U",3,27],[283991644800,"L",3,31],
  [366157135872,"U",3,32],[448345497600,"Spor","Suz"],
  [460815505920,"Spor","ON"],[495766656000,"Spor","Co(3)"],
  [499631102880,"L",3,29],[653837184000,"A",15],
  [664376138496,"G",2,7],[852032133120,"U",3,31],
  [1004497044480,"S",4,17],[1095199948800,"S",4,16],
  [1098404364288,"L",3,32],[1165572172800,"U",4,7],
  [1169948144736,"L",3,37],[2317591180800,"L",4,7],
  [2660096970720,"U",3,41],[3057017889600,"S",4,19],
  [3509983020816,"U",3,37],[3893910661872,"L",3,43],
  [4106059776000,"S",6,4],[4329310519296,"G",2,8],
  [4952179814400,"O+",8,3],[7933578895872,"U",3,47],
  [7980059337600,"L",3,41],[10151968619520,"O-",8,3],
  [10461394944000,"A",16],[11072935641600,"L",3,49],
  [11682025843488,"U",3,43],[20560831566912,"3D",4,3],
  [20674026236160,"S",4,23],[20745981365616,"U",3,53],
  [22594320403200,"G",2,9],[23499295948800,"O+",10,2],
  [23800278205248,"L",3,47],[25015379558400,"O-",10,2],
  [33219371640000,"U",3,49],[34558531338240,"L",4,8],
  [34693789777920,"U",4,8],[35115786567680,"Sz",512],
  [42305421312000,"Spor","Co(2)"],[47607300000000,"S",4,25],
  [48929657263200,"U",3,59],[50759843097600,"L",4,9],
  [53443952640000,"U",5,4],[62237108003616,"L",3,53],
  [63884982751200,"L",3,61],[64561751654400,"Spor","Fi(22)"],
  [93801727918080,"L",3,64],[101798586432000,"U",4,9],
  [102804157834560,"S",4,27],[135325289783376,"L",3,67],
  [146787542351760,"L",3,59],[163849992929280,"L",7,2],
  [177843714048000,"A",17],[191656636992240,"U",3,61],
  [210103196385600,"S",4,29],[215209078277760,"U",3,71],
  [227787103272960,"U",7,2],[228501000000000,"S",6,5],[228501000000000,"O",7,5],
  [258492255436800,"L",5,4],[268768894995072,"L",3,73],
  [273030912000000,"Spor","HN"],[281407330713600,"U",3,64],
  [376611192619200,"G",2,11],[405978568998816,"U",3,67],
  [409387254681600,"S",4,31],[505620881962560,"L",3,79],
  [645623627090400,"L",3,71],[750656410078176,"U",3,83],
  [806310830350368,"U",3,73],[1036388695478400,"U",4,11],
  [1124799322521600,"S",4,32],[1312032469255200,"U",3,89],
  [1516868799014400,"U",3,79],[1852734273062400,"L",3,81],
  [1852741245568320,"U",3,81],[2069665112592000,"L",4,11],
  [2251961353296816,"L",3,83],[2402534664555840,"S",4,37],
  [2612197345314816,"L",3,97],[3201186852864000,"A",18],
  [3311126603366400,"F",4,2],[3609172015066800,"U",3,101],
  [3914077489672896,"G",2,13],[3936086241056640,"L",3,89],
  [4222165056643872,"L",3,103],[5726791697419872,"U",3,107],
  [6641311310615520,"L",3,109],[6707334818822400,"S",4,41],
  [7836609208799616,"U",3,97],[8860792800073536,"U",3,113],
  [10799893897531200,"S",4,43],[10827495027060000,"L",3,101],
  [12666518353227648,"U",3,103],[12714519233969280,"L",4,13],
  [15315521833180800,"L",3,121],[17180347043675088,"L",3,107],
  [19866953531250000,"U",3,125],[19923964701735600,"U",3,109],
  [21032402889738240,"L",6,3],[22557001777261056,"L",3,127],
  [22837472432087040,"U",6,3],[24017743449686016,"U",3,128],
  [24815256521932800,"S",10,2],[25452197883665280,"U",4,13],
  [26287655087416320,"S",4,47],[26582341554402816,"L",3,113],
  [28908396044367840,"U",3,131],[36011213418659840,"Sz",2048],
  [39879509765760000,"S",4,49],[41363788790194272,"U",3,137],
  [45946617370848480,"U",3,121],[46448800925370480,"L",3,139],
  [49825657439340552,"R",243],
  [51765179004000000,"Spor","Ly"],[56653740000000000,"L",5,5],
  [57604365000000000,"U",5,5],[59600799562500000,"L",3,125],
  [60822550204416000,"A",19],[65784756654489600,"S",8,3],[65784756654489600,"O",9,3],
  [67010895544320000,"O+",8,4],[67536471195648000,"O-",8,4],
  [67671071404425216,"U",3,127],[67802350642790400,"3D",4,4],
  [71776114783027200,"G",2,16],[72053161633775616,"L",3,128],
  [80974721219670000,"U",3,149],[86725110978620400,"L",3,131],
  [87412594259315520,"S",4,53],[90089701905420000,"L",3,151],
  [90745943887872000,"Spor","Th"],
  [123043374372144096,"L",3,157],[124091269852276608,"L",3,137],
  [139346506548429600,"U",3,139],[166097514629752272,"L",3,163],
  [167795197370551296,"G",2,17],[201648518295622272,"U",3,167],
  [221797724414797440,"L",3,169],[242924016786074400,"L",3,149],
  [255484940347310400,"S",4,59],[267444174893824656,"U",3,173],
  [270269262714825600,"U",3,151],[273457218604953600,"S",6,7],
  [273457218604953600,"O",7,7],[351309192845176800,"U",3,179],
  [356575576421678400,"S",4,61],[369130313886677616,"U",3,157],
  [383967100578952800,"L",3,181],[498292774007829408,"U",3,163],
  [590382996204625920,"U",3,191],[604945295112210528,"L",3,167],
  [641690334200143872,"L",3,193],[665393448951722400,"U",3,169],
  [712975930219192320,"L",4,17],[756131656307437872,"U",3,197],
  [796793353927300800,"G",2,19],[802332214764045216,"L",3,173],
  [819770591880266400,"L",3,199],[911215823217986880,"S",4,67]]);

# call atlasrep, possibly with extra parameters, but only if atlasrep is available
BindGlobal("DoAtlasrepGroup",function(params)
local g;
  if LoadPackage("atlasrep")<>true then
    Error("`atlasrep' package must be available to construct group ",params[1]);
  fi;
  g:=CallFuncList(ValueGlobal("AtlasGroup"),params);
  SetName(g,params[1]);
  return g;
end);

InstallGlobalFunction(SimpleGroup,function(arg)
local brg,str,p,a,param,g,s,small;
  if IsRecord(arg[1]) then
    p:=arg[1];
    if p.series="Spor" then
      brg:=p.parameter;
    else
      brg:=Concatenation([p.series],p.parameter);
    fi;
  else
    brg:=arg;
  fi;
  str:=brg[1];
  # Case x(y gets replaced by x,y for x,y digits
  p:=Position(str,'(');
  if p>1 and p<Length(str) and str[p-1] in CHARS_DIGITS and str[p+1] in CHARS_DIGITS
    then
    str:=Concatenation(str{[1..p-1]},",",str{[p+1..Length(str)]});
  fi;
  # blanks,parentheses,_,^,' do not contribute to parsing
  a:=" ()_^'";
  str:=UppercaseString(Filtered(str,x->not x in a));
  # are there parameters in the string?
  # skip leading numbers for indicating 2/3 twist
  if Length(str)>1 then
    p:=PositionProperty(str{[2..Length(str)]},
      x->x in CHARS_DIGITS or x in "+-");
    if p<>fail then p:=p+1;fi;
  else
    p:=PositionProperty(str{[1..Length(str)]},
      x->x in CHARS_DIGITS or x in "+-");
  fi;
  param:=[];
  if p<>fail then
    a:=str{[p..Length(str)]};
    str:=str{[1..p-1]};
    # special case `O+' or `O-'
    if Length(a)=1 and a[1] in "+-" then
      if a[1]='+' then
        param:=[1];
      else
        param:=[-1];
      fi;
    else
      p:=Position(a,',');
      while p<>fail do
        s:=a{[1..p-1]};
	Add(param,Int(s));
	a:=a{[p+1..Length(a)]};
	p:=Position(a,',');
      od;
      Add(param,Int(a));
    fi;
  fi;
  param:=Concatenation(param,brg{[2..Length(brg)]});
  if ForAny(param,x->not IsInt(x)) then
    Error("parameters must be integral");
  fi;

  # replace Lie names with classical/discoverer equivalents if possible

  # now parse the name. Is it sporadic, alternating, suzuki, or ree?
  if Length(param)<=1 then
    if str="A" or str="ALT" then
      if Length(param)=1 and param[1]>4 then
        g:=AlternatingGroup(param[1]);
	SetName(g,Concatenation("A",String(param[1])));
	return g;
      else
        Error("Illegal Parameter for Alternating groups");
      fi;

    elif (str="M" and Length(param)=0) or str="FG" then
      Error("Monster not yet supported");
    elif (str="B" or str="BM") and Length(param)=0 then
      return DoAtlasrepGroup(["B"]);
    elif str="M" or str="MATHIEU" then
      if Length(param)=1 and param[1] in [11,12,22,23,24] then
        g:=MathieuGroup(param[1]);
	SetName(g,Concatenation("M",String(param[1])));
	return g;
      else
        Error("Illegal Parameter for Mathieu groups");
      fi;

    elif str="J" or str="JANKO" then
      if Length(param)=1 and param[1] in [1..4] then
	if param[1]=1 then
	  g:=PrimitiveGroup(266,1);
	elif param[1]=2 then
	  g:=PrimitiveGroup(100,1);
	else
	  g:=[,,"J3","J4"];
	  g:=DoAtlasrepGroup([g[param[1]]]);
	fi;
	return g;
      else
        Error("Illegal Parameter for Janko groups");
      fi;

    elif str="CO" or str="." or str="CONWAY" then
      if Length(param)=1 and param[1] in [1..3] then
	if param[1]=3 then
	  g:=PrimitiveGroup(276,3);
	elif param[1]=2 then
	  g:=PrimitiveGroup(2300,1);
	else
	  g:=DoAtlasrepGroup(["Co1"]);
	fi;
	return g;
      else
        Error("Illegal Parameter for Conway groups");
      fi;

    elif str="FI" or str="FISCHER" then
      if Length(param)=1 and param[1] in [22,23,24] then
	s:=Concatenation("Fi",String(param[1]));
	if param[1] = 24 then Append(s,"'"); fi;
        g:=DoAtlasrepGroup([s]);
	return g;
      else
        Error("Illegal Parameter for Fischer groups");
      fi;
    elif str="SUZ" or str="SZ" or str="SUZUKI" then
      if Length(param)=0 and str="SUZ" then
	return PrimitiveGroup(1782,1);
      elif Length(param)=1 and param[1]>7 and
        Set(Factors(param[1]))=[2] and IsOddInt(LogInt(param[1],2)) then
	g:=SuzukiGroup(IsPermGroup,param[1]);
	SetName(g,Concatenation("Sz(",String(param[1]),")"));
	return g;
      else
        Error("Illegal Parameter for Suzuki groups");
      fi;
    elif str="R" or str="REE" or str="2G" then
      if Length(param)=1 and param[1]>26 and
        Set(Factors(param[1]))=[3] and IsOddInt(LogInt(param[1],3)) then
	g:=ReeGroup(IsMatrixGroup,param[1]);
	SetName(g,Concatenation("Ree(",String(param[1]),")"));
	return g;
      else
        Error("Illegal Parameter for Ree groups");
      fi;

    elif str="ON" then
      return DoAtlasrepGroup(["ON"]);
    elif str="HE" then
      return PrimitiveGroup(2058,1);
    elif str="HS" then
      return PrimitiveGroup(100,3);
    elif str="HN" then
      return DoAtlasrepGroup(["HN"]);
    elif str="LY" then
      return DoAtlasrepGroup(["Ly"]);
    elif str="MC" or str="MCL" then
      return PrimitiveGroup(275,1);
    elif str="TH" then
      return DoAtlasrepGroup(["Th"]);
    elif str="RU" then
      return DoAtlasrepGroup(["Ru"]);
    elif str="B" then
      return DoAtlasrepGroup(["B"]);
    elif str="T" then
      return PrimitiveGroup(1600,20);
    fi;
  fi;

  # now the name is ``classical''. and the second parameter a prime power
  if not IsPrimePowerInt(param[Maximum(2,Length(param))]) then
    Error("field order must be a prime power");
  fi;

  small:=false;
  s:=fail;
  if str="L" or str="SL" or str="PSL" then
    g:=PSL(param[1],param[2]);
    s:=Concatenation("PSL(",String(param[1]),",",String(param[2]),")");
  elif str="U" or str="SU" or str="PSU" then
    g:=PSU(param[1],param[2]);
    s:=Concatenation("PSU(",String(param[1]),",",String(param[2]),")");
    small:=true;
  elif str="S" or str="SP" or str="PSP" then
    g:=PSp(param[1],param[2]);
    s:=Concatenation("PSp(",String(param[1]),",",String(param[2]),")");
    small:=true;
  elif str="O" or str="SO" or str="PSO" then
    if Length(param)=2 and IsOddInt(param[1]) then
      g:=SO(param[1],param[2]);
      g:=Action(g,NormedRowVectors(GF(param[2])^param[1]),OnLines);
      g:=DerivedSubgroup(g);
      s:=Concatenation("O(",String(param[1]),",",String(param[2]),")");
      small:=true;
    elif Length(param)=3 and param[1]=1 and IsEvenInt(param[2]) then
      g:=SO(1,param[2],param[3]);
      g:=Action(g,NormedRowVectors(GF(param[3])^param[2]),OnLines);
      g:=DerivedSubgroup(g);
      s:=Concatenation("O+(",String(param[2]),",",String(param[3]),")");
      small:=true;
    elif Length(param)=3 and param[1]=-1 and IsEvenInt(param[2]) then
      g:=SO(-1,param[2],param[3]);
      g:=Action(g,NormedRowVectors(GF(param[3])^param[2]),OnLines);
      g:=DerivedSubgroup(g);
      s:=Concatenation("O-(",String(param[2]),",",String(param[3]),")");
      small:=true;
    else
      Error("wrong dimension/parity for O");
    fi;

  elif str="E" then
    if Length(param)<2 or not param[1] in [6,7,8] then
      Error("E(n,q) needs n=6,7,8");
    fi;
    s:=Concatenation("E",String(param[1]),"(",String(param[2]),")");
    g:=DoAtlasrepGroup([s]);

  elif str="F" then
    if Length(param)>1 and param[1]<>4 then
      Error("F(n,q) needs n=4");
    fi;
    a:=param[Length(param)];
    if a=2 then
      g:=DoAtlasrepGroup(["F4(2)"]);
    else
      Error("Can't do yet");
    fi;
    s:=Concatenation("F_4(",String(a),")");

  elif str="G" then
    if Length(param)>1 and param[1]<>2 then
      Error("G(n,q) needs n=2");
    fi;
    a:=param[Length(param)];
    if a=2 then return SimpleGroup("U",3,3);
    elif a=3 then
      g:=PrimitiveGroup(351,7);
    elif a=4 then
      g:=PrimitiveGroup(416,7);
    elif a=5 then
      g:=DoAtlasrepGroup(["G2(5)"]);
    else
      Error("Can't do yet");
    fi;
    s:=Concatenation("G_2(",String(a),")");

  elif str="3D" then
    if Length(param)>1 and param[1]<>4 then
      Error("3D(n,q) needs n=4");
    fi;
    a:=param[Length(param)];
    if a=2 then
      g:=PrimitiveGroup(819,5);
    elif a=3 then
      g:=DoAtlasrepGroup(["3D4(3)"]);
    else
      Error("Can't do yet");
    fi;
    s:=Concatenation("3D4(",String(a),")");

  elif str="2E" then
    if Length(param)>1 and param[1]<>6 then
      Error("3D(n,q) needs n=4");
    fi;
    a:=param[Length(param)];
    s:=Concatenation("2E6(",String(a),")");
    g:=DoAtlasrepGroup([s]);

  else
    Error("Can't handle type ",str);
  fi;
  if small then
    a:=ShallowCopy(Orbits(g,MovedPoints(g)));
    if Length(a)>1 then
      SortParallel(List(a,Length),a);
      a:=Action(g,a[1]);
      SetSize(a,Size(g));
      g:=a;
    fi;

    a:=Blocks(g,MovedPoints(g));
    if Length(a)>1 then
      a:=Action(g,a,OnSets);
      SetSize(a,Size(g));
      g:=a;
    fi;
    
    SetIsSimpleGroup(g,true);
  fi;
  if s<>fail and not HasName(g) then
    SetName(g,s);
  fi;
  return g;

end);

BindGlobal("SizeL2Q",q->q*(q-1)*(q+1)*Gcd(2,q)/2);

# deal with irregular order for L2(2^a)
# return [usedegree, nexta, stackvalue]
BindGlobal("NextL2Q",function(a,stack)
local NextL2PrimePowerInt;

  NextL2PrimePowerInt:=function(a)
    repeat
      a:=a+1;
    # L2(q) for q=4,5,9 duplicates others
    until IsPrimePowerInt(a) and not a in [4,5,9];
    return a;
  end;

  a:=NextL2PrimePowerInt(a);
  if stack<>fail then
    if SizeL2Q(stack)<SizeL2Q(a) then
      return [stack,a-1,fail];
    else
      return [a,a,stack];
    fi;
  elif IsEvenInt(a) and SizeL2Q(a)>SizeL2Q(NextL2PrimePowerInt(a)) then
    stack:=a;
    a:=NextL2PrimePowerInt(a);
    return [a,a,stack];
  else
    return [a,a,fail];
  fi;
end);

BindGlobal("NextIterator_SimGp",function(it)
local a,l,pos,g;
  if it!.done then return fail;fi;
  a:=it!.b;
  if a>1259903 then
    # 1259903 is the last prime power whose L2 order is <10^18
    Error("List of simple groups is only available up to order 10^18");
  fi;
  l:=SizeL2Q(a);
  pos:=it!.pos;
  if l<SIMPLEGPSNONL2[pos][1] and not it!.nopsl2 then
    # next is a L2
    g:=SimpleGroup("L",2,a);
    a:=NextL2Q(it!.a,it!.stack);
    it!.a:=a[2];
    it!.b:=a[1];
    it!.stack:=a[3];
  else
    # next is from the list
    a:=SIMPLEGPSNONL2[pos];
    it!.pos:=pos+1;

    if a[2]="Spor" then
      g:=SimpleGroup(a[3]);
    else
      g:=CallFuncList(SimpleGroup,a{[2..Length(a)]});
    fi;
    # safety check
    if Size(g)<>a[1] then
      Error("order inconsistency");
    fi;
  fi;

  #Print("pos=",it!.pos," b=",it!.b,"\n");

  it!.done:=SIMPLEGPSNONL2[it!.pos][1]>it!.ende 
    and (SizeL2Q(it!.b)>it!.ende or it!.nopsl2);

  return g;
end);

BindGlobal("IsDoneIterator_SimGp",function(it)
  return it!.done;
end);

InstallGlobalFunction(SimpleGroupsIterator,function(arg)
  local a,b,stack,ende,start,pos,nopsl2;
  ende:=infinity;
  if Length(arg)=0 then
    start:=60;
  else
    start:=Maximum(60,arg[1]);
    if Length(arg)>1 then
      ende:=arg[2];
    fi;
  fi;
  nopsl2:=ValueOption("NOPSL2")=true or ValueOption("nopsl2")=true;

  # find relevant L2 order
  a:=RootInt(start,3)-1;
  stack:=fail;
  repeat
    a:=NextL2Q(a,stack);
    b:=a[1];
    stack:=a[3];
    a:=a[2];
  until SizeL2Q(b)>=start;
  pos:=First([1..Length(SIMPLEGPSNONL2)],x->SIMPLEGPSNONL2[x][1]>=start);

  return IteratorByFunctions(rec(
    IsDoneIterator:=IsDoneIterator_SimGp,
    NextIterator:=NextIterator_SimGp,
    ShallowCopy:=ShallowCopy,
    a:=a,
    b:=b,
    ende:=ende,
    stack:=stack,
    pos:=pos,
    nopsl2:=nopsl2,
    # if nopsl2 then the l2size is irrelevant
    done:=(SizeL2Q(b)>ende or nopsl2) and SIMPLEGPSNONL2[pos][1]>ende
  ));

end);

InstallGlobalFunction(ClassicalIsomorphismTypeFiniteSimpleGroup,function(G)
local t,r;
  t:=IsomorphismTypeInfoFiniteSimpleGroup(G);
  r:=rec();
  if t.series in ["Z","A"] then
    r.series:=t.series;
    r.parameter:=[t.parameter];
  elif t.series in ["L","E"] then
    r.series:=t.series;
    r.parameter:=t.parameter;
  elif t.series="Spor" then
    r.series:=t.series;
    # stupid naming of J2
    if Length(t.name)>5 and t.name{[1..5]}="HJ = " then
      r.parameter:=["J2"];
    else
      r.parameter:=[t.name];
    fi;
  elif t.series="B" then
    r.series:="O";
    r.parameter:=[t.parameter[1]*2+1,t.parameter[2]];
  elif t.series="C" then
    r.series:="S";
    r.parameter:=[t.parameter[1]*2,t.parameter[2]];
  elif t.series="D" then
    r.series:="O+";
    r.parameter:=[t.parameter[1]*2,t.parameter[2]];
  elif t.series="F" then
    r.series:="F";
    r.parameter:=[4,t.parameter];
  elif t.series="G" then
    r.series:="G";
    r.parameter:=[2,t.parameter];
  elif t.series="2A" then
    r.series:="U";
    r.parameter:=[t.parameter[1]+1,t.parameter[2]];
  elif t.series="2B" then
    r.series:="Sz";
    r.parameter:=[t.parameter];
  elif t.series="2D" then
    r.series:="O-";
    r.parameter:=[t.parameter[1]*2,t.parameter[2]];
  elif t.series="3D" then
    r.series:="3D";
    r.parameter:=[4,t.parameter];
  elif t.series="2E" then
    r.series:="2E";
    r.parameter:=[6,t.parameter];
  elif t.series="2F" then
    if t.parameter=2 then
      r.series:="Spor";
      r.parameter:="T";
    else
      r.series:="2F";
      r.parameter:=[t.parameter];
    fi;
  elif t.series="2G" then
    r.series:="2G";
    r.parameter:=[t.parameter];
  fi;
  return r;
end);
