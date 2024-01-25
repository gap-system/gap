#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains basic constructions for simple groups of bounded size,
##  if necessary by calling the `atlasrep' package.
##

# data for simple groups of order up to 10^18 that are not L_2(q)
# for some of the groups entry #5 indicates the smallest permutation degree
BindGlobal("SIMPLEGPSNONL2",
  MakeImmutable(
  [[60,"A",5,0,5],[360,"A",6,0,6],[2520,"A",7,0,7],
    [5616,"L",3,3,13],[6048,"U",3,3,28],
    [7920,"Spor","M(11)",0,11],[20160,"A",8,0,8],
    [20160,"L",3,4,21],[25920,"S",4,3,40],
    [29120,"Sz",8,0,65],[62400,"U",3,4,65],
    [95040,"Spor","M(12)",0,12],[126000,"U",3,5,126],
    [175560,"Spor","J(1)",0,266],[181440,"A",9,0,9],
    [372000,"L",3,5,31],[443520,"Spor","M(22)",0,22],
    [604800,"Spor","J(2)",0,100],[979200,"S",4,4,85],
    [1451520,"S",6,2,63],[1814400,"A",10,0,10],
    [1876896,"L",3,7,57],[3265920,"U",4,3,280],
    [4245696,"G",2,3,351],[4680000,"S",4,5,156],
    [5515776,"U",3,8,513],[5663616,"U",3,7,344],
    [6065280,"L",4,3,40],[9999360,"L",5,2,31],
    [10200960,"Spor","M(23)",0,23],[13685760,"U",5,2,165],
    [16482816,"L",3,8,73],[17971200,"Spor","T",0,1600],
    [19958400,"A",11,0,11],[32537600,"Sz",32,0,1025],
    [42456960,"L",3,9,91],[42573600,"U",3,9,730],
    [44352000,"Spor","HS",0,100],[50232960,"Spor","J(3)",0,6156],
    [70915680,"U",3,11,1332],[138297600,"S",4,7,400],
    [174182400,"O+",8,2,120],[197406720,"O-",8,2,119],
    [211341312,"3D",4,2,819],[212427600,"L",3,11,133],
    [239500800,"A",12,0,12],[244823040,"Spor","M(24)",0,24],
    [251596800,"G",2,4,416],[270178272,"L",3,13,183],
    [811273008,"U",3,13,2198],[898128000,"Spor","McL",0,275],
    [987033600,"L",4,4,85],[1018368000,"U",4,4,1105],
    [1056706560,"S",4,8,585],[1425715200,"L",3,16,273],
    [1721606400,"S",4,9,820],[2317678272,"U",3,17,4914],
    [3113510400,"A",13,0,13],[4030387200,"Spor","He",0,2058],
    [4279234560,"U",3,16,4097],[4585351680,"S",6,3,364],
    [4585351680,"O",7,3,351],[5644682640,"L",3,19,381],
    [5859000000,"G",2,5,3906],[6950204928,"L",3,17,307],
    [7254000000,"L",4,5,156],[9196830720,"U",6,2,672],
    [10073444472,"R",27,0,19684],[12860654400,"S",4,11,1464],
    [14742000000,"U",4,5,3276],[16938986400,"U",3,19,6860],
    [20158709760,"L",6,2,63],[26056457856,"U",3,23,12168],
    [34093383680,"Sz",128,0,16385],[43589145600,"A",14,0,14],
    [47377612800,"S",8,2,255],[50778000000,"L",3,25,651],
    [68518981440,"S",4,13,2380],[78156525216,"L",3,23,553],
    [145926144000,"Spor","Ru",0,4060],[152353500000,"U",3,25,15626]
    ,[166557358800,"U",3,29,24390],[237783237120,"L",5,3,121],
    [258190571520,"U",5,3,2440],[282027786768,"L",3,27,757],
    [282056445216,"U",3,27,19684],[283991644800,"L",3,31,993],
    [366157135872,"U",3,32,32769],
    [448345497600,"Spor","Suz",0,1782],
    [460815505920,"Spor","ON",0,122760],
    [495766656000,"Spor","Co(3)",0,276],[499631102880,"L",3,29,871]
    ,[653837184000,"A",15,0,15],[664376138496,"G",2,7],
    [852032133120,"U",3,31,29792],[1004497044480,"S",4,17,5220],
    [1095199948800,"S",4,16,4369],[1098404364288,"L",3,32,1057],
    [1165572172800,"U",4,7,17200],[1169948144736,"L",3,37,1407],
    [2317591180800,"L",4,7,400],[2660096970720,"U",3,41,68922],
    [3057017889600,"S",4,19,7240],[3509983020816,"U",3,37,50654],
    [3893910661872,"L",3,43,1893],[4106059776000,"S",6,4,1365],
    [4329310519296,"G",2,8],[4952179814400,"O+",8,3,1080],
    [7933578895872,"U",3,47,103824],[7980059337600,"L",3,41,1723],
    [10151968619520,"O-",8,3,1066],[10461394944000,"A",16,0,16],
    [11072935641600,"L",3,49,2451],[11682025843488,"U",3,43],
    [20560831566912,"3D",4,3,26572],[20674026236160,"S",4,23,12720]
    ,[20745981365616,"U",3,53],[22594320403200,"G",2,9],
    [23499295948800,"O+",10,2,496],[23800278205248,"L",3,47,2257],
    [25015379558400,"O-",10,2,495],[33219371640000,"U",3,49],
    [34558531338240,"L",4,8,585],[34693789777920,"U",4,8],
    [35115786567680,"Sz",512,0,262145],
    [42305421312000,"Spor","Co(2)",0,2300],
    [47607300000000,"S",4,25,16276],[48929657263200,"U",3,59],
    [50759843097600,"L",4,9,820],[53443952640000,"U",5,4],
    [62237108003616,"L",3,53,2863],[63884982751200,"L",3,61,3783],
    [64561751654400,"Spor","Fi(22)",0,3510],
    [93801727918080,"L",3,64,4161],[101798586432000,"U",4,9],
    [102804157834560,"S",4,27,20440],
    [135325289783376,"L",3,67,4557],[146787542351760,"L",3,59,3541]
    ,[163849992929280,"L",7,2,127],[177843714048000,"A",17,0,17]
    ,[191656636992240,"U",3,61],[210103196385600,"S",4,29,25260],
    [215209078277760,"U",3,71],[227787103272960,"U",7,2],
    [228501000000000,"S",6,5,3906],[228501000000000,"O",7,5,3906],
    [258492255436800,"L",5,4,341],[268768894995072,"L",3,73,5403],
    [273030912000000,"Spor","HN",0,1140000],
    [281407330713600,"U",3,64],[376611192619200,"G",2,11],
    [405978568998816,"U",3,67],[409387254681600,"S",4,31,30784],
    [505620881962560,"L",3,79,6321],[645623627090400,"L",3,71,5113]
    ,[750656410078176,"U",3,83],[806310830350368,"U",3,73],
    [1036388695478400,"U",4,11],[1124799322521600,"S",4,32,33825],
    [1312032469255200,"U",3,89],[1516868799014400,"U",3,79],
    [1852734273062400,"L",3,81,6643],[1852741245568320,"U",3,81],
    [2069665112592000,"L",4,11,1464],
    [2251961353296816,"L",3,83,6973],
    [2402534664555840,"S",4,37,52060],
    [2612197345314816,"L",3,97,9507],[3201186852864000,"A",18,0,18]
    ,[3311126603366400,"F",4,2,69888],
    [3609172015066800,"U",3,101],[3914077489672896,"G",2,13],
    [3936086241056640,"L",3,89,8011],
    [4222165056643872,"L",3,103,10713],[5726791697419872,"U",3,107],
    [6641311310615520,"L",3,109,11991],
    [6707334818822400,"S",4,41,70644],[7836609208799616,"U",3,97],
    [8860792800073536,"U",3,113],[10799893897531200,"S",4,43,81400],
    [10827495027060000,"L",3,101,10303],
    [12666518353227648,"U",3,103],[12714519233969280,"L",4,13,2380],
    [15315521833180800,"L",3,121,14763],
    [17180347043675088,"L",3,107,11557],
    [19866953531250000,"U",3,125],[19923964701735600,"U",3,109],
    [21032402889738240,"L",6,3,364],
    [22557001777261056,"L",3,127,16257],[22837472432087040,"U",6,3],
    [24017743449686016,"U",3,128],[24815256521932800,"S",10,2,1023],
    [25452197883665280,"U",4,13],[26287655087416320,"S",4,47,106080]
    ,[26582341554402816,"L",3,113,12883],
    [28908396044367840,"U",3,131],
    [36011213418659840,"Sz",2048,0,4194305],
    [39879509765760000,"S",4,49,120100],
    [41363788790194272,"U",3,137],[45946617370848480,"U",3,121],
    [46448800925370480,"L",3,139,19461],
    [49825657439340552,"R",243,0],
    [51765179004000000,"Spor","Ly",0,8835156],
    [56653740000000000,"L",5,5],[57604365000000000,"U",5,5],
    [59600799562500000,"L",3,125],[60822550204416000,"A",19,0],
    [65784756654489600,"S",8,3],[65784756654489600,"O",9,3],
    [67010895544320000,"O+",8,4],[67536471195648000,"O-",8,4],
    [67671071404425216,"U",3,127],[67802350642790400,"3D",4,4],
    [71776114783027200,"G",2,16],[72053161633775616,"L",3,128],
    [80974721219670000,"U",3,149],[86725110978620400,"L",3,131],
    [87412594259315520,"S",4,53],[90089701905420000,"L",3,151],
    [90745943887872000,"Spor","Th",0,143127000],
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
    [819770591880266400,"L",3,199],[911215823217986880,"S",4,67]]
    ));

# call atlasrep, possibly with extra parameters, but only if atlasrep is available
BindGlobal("DoAtlasrepGroup",function(params)
local g;
  if IsPackageMarkedForLoading("atlasrep","")<>true then
    Error("`atlasrep' package must be available to construct group ",params[1]);
  fi;
  g:=CallFuncList(ValueGlobal("AtlasGroup"),params);
  if not IsGroup(g) then
     Error("The AtlasRep package could not load a group with parameters ",params);
  fi;
  SetName(g,params[1]);
  if not '.' in params[1] then
    SetIsSimpleGroup(g,true);
  fi;
  return g;
end);

BindGlobal("ChevalleyG",function(q)
local p,f,z,G,o;
  # Generators probably due to Don Taylor, communicated by Derek Holt
  p:=Factors(q);
  if Length(Set(p))>1 then Error("<q> must be prime power");fi;
  p:=p[1];
  f:=GF(q);
  z:=PrimitiveRoot(f);
  o:=One(f);

  # first generator differs for q=2,p=3
  if q=2 then
    G:=Group(
        o*[[1,1,0,0,0,0,0],
        [0,1,0,0,0,0,0],
        [0,0,1,1,1,0,0],
        [0,0,0,1,0,0,0],
        [0,0,0,0,1,0,0],
        [0,0,0,0,0,1,1],
        [0,0,0,0,0,0,1]],
        o*[[0,0,1,0,0,0,0],
        [1,0,0,0,0,0,0],
        [0,0,0,0,0,1,0],
        [0,0,0,1,0,0,0],
        [0,1,0,0,0,0,0],
        [0,0,0,0,0,0,1],
        [0,0,0,0,1,0,0]]);
  elif p=3 then
    G:=Group(
    o*[[z^2,0,0,0,0,0,0],
      [0,z,0,0,0,0,0],
      [0,0,z,0,0,0,0],
      [0,0,0,1,0,0,0],
      [0,0,0,0,z^(q-2),0,0],
      [0,0,0,0,0,z^(q-2),0],
      [0,0,0,0,0,0,z^(q-3)]],
      o*[[0,0,1,0,0,0,0],
      [2,0,1,0,0,1,0],
      [0,0,0,0,0,1,0],
      [0,0,0,2,0,2,0],
      [0,2,0,2,0,1,1],
      [0,0,0,0,0,0,1],
      [0,0,0,0,1,0,1]]
    );
  else
    G:=Group(
     o*[[z,0,0,0,0,0,0],
      [0,z^(q-2),0,0,0,0,0],
      [0,0,z^2,0,0,0,0],
      [0,0,0,1,0,0,0],
      [0,0,0,0,z^(q-3),0,0],
      [0,0,0,0,0,z,0],
      [0,0,0,0,0,0,z^(q-2)]],
      o*[[p-1,0,1,0,0,0,0],
      [p-1,0,0,0,0,0,0],
      [0,p-1,0,p-1,0,1,0],
      [0,p-2,0,p-1,0,0,0],
      [0,p-1,0,0,0,0,0],
      [0,0,0,0,1,0,1],
      [0,0,0,0,1,0,0]]);
  fi;

  SetSize(G,q^6*(q^6-1)*(q^2-1));
  return G;
end);

# generators from
# Howlett, R. B.(5-SYD-SM); Rylands, L. J.; Taylor, D. E.(5-SYD-SM)
# Matrix generators for exceptional groups of Lie type.
# J. Symbolic Comput. 31 (2001), no. 4, 429–445.
# Note that Magma uses slightly different generators
BindGlobal("Chevalley3D4",function(q)
local f,mu,m1,m2,x,n,o;
  f:=GF(q^3);
  o:=One(f);
  mu:=PrimitiveRoot(f);
  m1:=DiagonalMat([mu^(q^2),mu^(-q^2),mu^(q+1),mu^(q-1),
                   mu^(-q+1),mu^(-q-1),mu^(q^2),mu^(-q^2)]);
  x:=IdentityMat(8,f);
  x[1,2]:=o;
  x[3,4]:=o;
  x[3,5]:=o;
  x[3,6]:=o;
  x[4,6]:=o;
  x[5,6]:=o;
  x[7,8]:=o;
  n:=NullMat(8,8,f);
  n[1,3]:=o;
  n[2,1]:=-o;
  n[3,7]:=o;
  n[4,5]:=-o;
  n[5,4]:=-o;
  n[6,2]:=-o;
  n[7,8]:=o;
  n[8,6]:=o;
  m2:=x*n;
  x:=Group(m1,m2);
  SetName(x,Concatenation("3D4(",String(q),")"));
  SetSize(x,q^12*(q^8+q^4+1)*(q^6-1)*(q^2-1));
  return x;
end);

InstallGlobalFunction(SimpleGroup,function(arg)
local brg,str,p,a,param,g,s,small,plus,sets;
  if IsRecord(arg[1]) then
    p:=arg[1];
    if p.series="Spor" then
      brg:=p.parameter[1];
      if '=' in brg then
        brg:=brg{[1..Position(brg,'=')-1]};
      fi;
      while brg[Length(brg)]=' ' do
        brg:=brg{[1..Length(brg)-1]};
      od;
      brg:=[brg];
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
    if '+' in a or '-' in a then
      p:=Position(a,'+');
      if p<>fail then
        plus:=1;
      else
        p:=Position(a,'-');
        plus:=-1;
      fi;
      if Length(a)=1 then
        # deal with "O+" class
        Add(a,'1');
      elif Length(a)>=p+1 and a[p+1]='1' and a[p+2]=',' then
        # gave O(+1,8,2) or so
        plus:=fail;
      fi;
      if plus<>fail then
        if p=1 then
          # leading +-, possibly with comma
          a:=a{[2..Length(a)]};
          if a="1" then a:="";fi;
          if Length(a)>1 and a[1]=',' then
            a:=a{[2..Length(a)]};
          fi;
        else
          # internal +-
          a[p]:=',';
        fi;
      fi;

    else
      plus:=fail;
    fi;

    if Length(a)>0 then
      p:=Position(a,',');
      while p<>fail do
        s:=a{[1..p-1]};
        if s[1]='+' then
          s:=s{[2..Length(s)]};
        fi;
        Add(param,Int(s));
        a:=a{[p+1..Length(a)]};
        p:=Position(a,',');
      od;
      if a[1]='+' then
        a:=a{[2..Length(a)]};
      fi;
      Add(param,Int(a));
    fi;

    if plus<>fail then
      param:=Concatenation([plus],param);
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
        SetIsNonabelianSimpleGroup(g,true);
        return g;
      else
        Error("illegal parameter for alternating groups");
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
        Error("illegal parameter for Mathieu groups");
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
        SetIsNonabelianSimpleGroup(g,true);
        return g;
      else
        Error("illegal parameter for Janko groups");
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
        SetIsNonabelianSimpleGroup(g,true);
        return g;
      else
        Error("illegal parameter for Conway groups");
      fi;

    elif str="FI" or str="FISCHER" then
      if Length(param)=1 and param[1] in [22,23,24] then
        s:=Concatenation("Fi",String(param[1]));
        if param[1] = 24 then Append(s,"'"); fi;
        g:=DoAtlasrepGroup([s]);
        SetIsNonabelianSimpleGroup(g,true);
        return g;
      else
        Error("illegal parameter for Fischer groups");
      fi;
    elif str="SUZ" or str="SZ" or str="SUZUKI" then
      if Length(param)=0 and str="SUZ" then
        g:=PrimitiveGroup(1782,1);
        SetIsNonabelianSimpleGroup(g,true);
        return g;
      elif Length(param)=1 and param[1]>7 and
        PrimeDivisors(param[1])=[2] and IsOddInt(LogInt(param[1],2)) then
        g:=SuzukiGroup(IsPermGroup,param[1]);
        SetName(g,Concatenation("Sz(",String(param),")"));
        SetIsNonabelianSimpleGroup(g,true);
        return g;
      else
        Error("illegal parameter for Suzuki groups");
      fi;
    elif str="R" or str="REE" or str="2G" then
      if Length(param)=1 and param[1]>26 and
        PrimeDivisors(param[1])=[3] and IsOddInt(LogInt(param[1],3)) then
        g:=ReeGroup(IsMatrixGroup,param[1]);
        SetName(g,Concatenation("Ree(",String(param[1]),")"));
        SetIsNonabelianSimpleGroup(g,true);
        return g;
      else
        Error("illegal parameter for Ree groups");
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
      g:=PrimitiveGroup(1600,20);
      s:=Size(g);
      g:=Group(GeneratorsOfGroup(g));
      SetSize(g,s);
      SetName(g,"2F(4,2)'");
      SetIsNonabelianSimpleGroup(g,true);
      return g;
    fi;
  fi;

  # now the name is ``classical''. and the second parameter a prime power
  if not IsPrimePowerInt(param[Maximum(2,Length(param))]) then
    Error("field order must be a prime power");
  fi;

  small:=false;
  s:=fail;
  if str="L" or str="SL" or str="PSL" then
    if param = [2,2] or param = [2,3] then
        Error("illegal parameter for linear groups");
    fi;
    g:=PSL(param[1],param[2]);
    s:=Concatenation("PSL(",String(param[1]),",",String(param[2]),")");
  elif str="U" or str="SU" or str="PSU" then
    if param in [ [2,2], [2,3], [3,2] ] then
      Error("illegal parameter for unitary groups");
    fi;
    g:=PSU(param[1],param[2]);
    s:=Concatenation("PSU(",String(param[1]),",",String(param[2]),")");
    small:=true;
  elif str="S" or str="SP" or str="PSP" then
    if param in [ [2,2], [2,3], [4,2] ] then
      Error("illegal parameter for symplectic groups");
    fi;
    g:=PSp(param[1],param[2]);
    s:=Concatenation("PSp(",String(param[1]),",",String(param[2]),")");
    small:=true;
  elif str="O" or str="SO" or str="PSO" then
    if Length(param)=2 and IsOddInt(param[1]) then
      if param[1] < 3 or (param[1] = 3 and param[2] <= 3) then
        Error("illegal parameter for orthogonal groups");
      fi;
      g:=SO(param[1],param[2]);
      g:=Action(g,NormedRowVectors(GF(param[2])^param[1]),OnLines);
      s:=DerivedSubgroup(g);
      if s<>g and IsBound(g!.actionHomomorphism) then
        s!.actionHomomorphism:=ActionHomomorphism(
          PreImage(g!.actionHomomorphism,s),
          HomeEnumerator(UnderlyingExternalSet(g!.actionHomomorphism)),
          OnLines,"surjective");
      fi;
      g:=s;
      s:=Concatenation("O(",String(param[1]),",",String(param[2]),")");
      small:=true;
    elif Length(param)=3 and param[1]=1 and IsEvenInt(param[2]) then
      if param[2] < 6 then
        Error("illegal parameter for orthogonal groups");
      fi;
      g:=SO(1,param[2],param[3]);
      g:=Action(g,NormedRowVectors(GF(param[3])^param[2]),OnLines);
      g:=DerivedSubgroup(g);
      s:=Concatenation("O+(",String(param[2]),",",String(param[3]),")");
      small:=true;
    elif Length(param)=3 and param[1]=-1 and IsEvenInt(param[2]) then
      if param[2] < 4 then
        Error("illegal parameter for orthogonal groups");
      fi;
      g:=SO(-1,param[2],param[3]);
      g:=Action(g,NormedRowVectors(GF(param[3])^param[2]),OnLines);
      g:=DerivedSubgroup(g);
      s:=Concatenation("O-(",String(param[2]),",",String(param[3]),")");
      small:=true;
    else
      Error("wrong dimension/parity for O");
    fi;

  elif str="D" then
    return SimpleGroup("O",1,param[1]*2,param[2]);
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
    else
      g:=ChevalleyG(a);
      g:=Action(g,
           Set(Orbit(g,One(DefaultFieldOfMatrixGroup(g))*[1,0,0,0,0,0,0],
             OnLines)),
          OnLines);
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
      return Chevalley3D4(a);
    fi;
    s:=Concatenation("3D4(",String(a),")");

  elif str="2E" then
    if Length(param)>1 and param[1]<>6 then
      Error("2E(n,q) needs n=6");
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
      if IsBound(g!.actionHomomorphism) then
        # pull back
        p:=UnderlyingExternalSet(g!.actionHomomorphism);
        a:=Action(Source(g!.actionHomomorphism),HomeEnumerator(p){a[1]},
             FunctionAction(p));
      else
        a:=Action(g,a[1]);
      fi;
      SetSize(a,Size(g));
      g:=a;
    fi;

    a:=Blocks(g,MovedPoints(g));
    if Length(a)>1 then
      if IsBound(g!.actionHomomorphism) then
        # pull back
        p:=UnderlyingExternalSet(g!.actionHomomorphism);
        sets:=Set(List(a,x->HomeEnumerator(p){x}));
        p:=FunctionAction(p);
        a:=Action(Source(g!.actionHomomorphism),sets,
             function(set,g)
               return Set(List(set,x->p(x,g)));
             end);
      else
        a:=Action(g,a,OnSets);
      fi;
      SetSize(a,Size(g));
      g:=a;
    fi;

  fi;
  if s<>fail and not HasName(g) then
    SetName(g,s);
  fi;
  SetIsNonabelianSimpleGroup(g,true);
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

BindGlobal("LOADSIMPLE2",function()
local a;
  if not IsBound(SIMPLEGPSNONL2[248]) then
    MakeReadWriteGlobal("SIMPLEGPSNONL2");
    a:=ReadAsFunction(Filename(List(GAPInfo.RootPaths,Directory),
      "grp/simple2.g"));
    SIMPLEGPSNONL2:=Immutable(Concatenation(SIMPLEGPSNONL2,a()));
    MakeReadOnlyGlobal("SIMPLEGPSNONL2");
  fi;
end);

BindGlobal("NextIterator_SimGp",function(it)
local a,l,pos,g,b;
  if it!.done then return fail;fi;
  a:=it!.b;
  if a>=1316848669 then
    # 1316848669 is the first prime power whose L2 order is beyond the
    # simple2 list
    Error("List of simple groups only available up to order",
      SIMPLE_GROUPS_ITERATOR_RANGE);
  fi;
  l:=SizeL2Q(a);
  pos:=it!.pos;
  if pos>=245  then LOADSIMPLE2(); fi;
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
      if a[4]=0 then
        b:=a{[2,3]}; # 0 is filler
      else
        b:=a{[2..4]};
      fi;
      g:=CallFuncList(SimpleGroup,b);
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
  if start>=10^18 then LOADSIMPLE2(); fi;
  pos:=First([1..Length(SIMPLEGPSNONL2)],x->SIMPLEGPSNONL2[x][1]>=start);
  return IteratorByFunctions(rec(
    IsDoneIterator:=IsDoneIterator_SimGp,
    NextIterator:=NextIterator_SimGp,
    ShallowCopy:=iter -> rec( a:=iter!.a,
      b:=iter!.b, ende:=iter!.ende,
      stack:=ShallowCopy(iter!.stack), pos:=iter!.pos,
      nopsl2:=iter!.nopsl2,
      done:=iter!.done),
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
  if IsGroup(G) then
    t:=IsomorphismTypeInfoFiniteSimpleGroup(G);
  else
    t:=G;
  fi;
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
      r.parameter:=["T"];
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

InstallMethod(DataAboutSimpleGroup,true,[IsGroup],0,
function(G)
local id;
  id:=IsomorphismTypeInfoFiniteSimpleGroup(G);
  return DataAboutSimpleGroup(id);
end);

# Tables for outer automorphisms from Bray/Holt/Roney-Dougal p. 36/37 [BHRD2013]
BindGlobal("OuterAutoSimplePres",function(class,n,q)
local p,e,f,rels,gp;
  class:=UppercaseString(class);
  p:=SmallestPrimeDivisor(q);
  e:=LogInt(q,p);
  if class="L" and n=2 then
    f:=FreeGroup("d","f");
    rels:=StringFormatted("d{}=f{}=[d,f]=1",Gcd(q-1,2),e);
  elif class="L" and n>=3 then
    f:=FreeGroup("d","g","f");
    rels:=StringFormatted("d{}=g2=f{}=[g,f]=1,d^g=D,d^f=d{}",Gcd(q-1,n),e,p);
  elif class="U" and n>=3 then
    f:=FreeGroup("d","g","f");
    rels:=StringFormatted("d{}=g2=1,f{}=g,d^g=D,d^f=d{}",Gcd(q+1,n),e,p);
  elif class="S" and n>=2 and (n<>4 or p<>2) then
    f:=FreeGroup("d","f");
    rels:=StringFormatted("d{}=f{}=[d,f]=1",Gcd(q-1,2),e);
  elif class="S" and n=4 and p=2 then
    f:=FreeGroup("g","f");
    rels:=StringFormatted("g2=f,f{}=1",e);
  elif (class="O" or class="O0" or class="OO") and n>=3 then
    # special case of characteristic 2 -- copy S status
    if p=2 then
      f:=FreeGroup("d","f");
      rels:=StringFormatted("d{}=f{}=[d,f]=1",Gcd(q-1,2),e);
    else
      f:=FreeGroup("d","f");
      rels:=StringFormatted("d2=f{}=[d,f]=1",e);
    fi;
  elif class="O+" and n>=6 and IsEvenInt(n) and n<>8 and p=2 then
    f:=FreeGroup("g","f");
    rels:=StringFormatted("g2=f{}=[g,f]=1",e);
  elif class="O+" and n=8 and p=2 then
    f:=FreeGroup("t","g","f");
    rels:=StringFormatted("t^3=g2=(gt)2=f{}=[t,f]=[g,f]=1",e);
  elif class="O-" and n>=4 and IsEvenInt(n) and p=2 then
    f:=FreeGroup("g","f");
    rels:=StringFormatted("g2,f{}=g",e);
  elif class="O+" and n=8 and IsOddInt(p) then
    f:=FreeGroup("p","t","g","d","f");
    rels:=StringFormatted(
      "p2=t3=g2=(gt)2=d2=1,d^t=p,p^dp,(dg)2=p,f{}=[d,f]=[t,f]=[g,f]=1",e);
  elif class="O+" and n>=12 and n mod 4=0 and IsOddInt(q) then
    f:=FreeGroup("p","g","d","f");
    rels:=StringFormatted("p2=g2=d2=1,(dg)2=p,f{}=[d,f]=[g,f]=1",e);
  elif class="O+" and n>=6 and n mod 4=2 and q mod 4=1 then
    f:=FreeGroup("p","g","d","f");
    rels:=StringFormatted("p2=g2=1,d2=p,d^g=D,f{}=[g,f]=1,d^f=d{}",e,p);
  elif class="O+" and n>=6 and n mod 4=2 and q mod 4=3 then
    f:=FreeGroup("g","d","f");
    rels:=StringFormatted("g2=d2=[d,g]=f{}=[g,f]=[d,f]=1",e);
  elif class="O-" and n>=4 and (n mod 4=0 or q mod 4=1) and IsOddInt(q) then
    f:=FreeGroup("g","d","f");
    rels:=StringFormatted("g2=d2=[d,g]=[d,f]=1,f{}=g",e);
  elif class="O-" and n>=4 and n mod 4=2 and q mod 4=3 then
    f:=FreeGroup("p","g","d","f");
    rels:=StringFormatted("p2=g2=1,d2=p,d^g=D,f{}=[g,f]=[d,f]=1",e);
  else
    return fail;
  fi;
  gp:=f/ParseRelators(f,rels);
  SetReducedMultiplication(gp);
  Size(gp);
  return gp;
end);

InstallOtherMethod(DataAboutSimpleGroup,true,[IsRecord],0,
function(id)
local nam,e,efactors,par,expo,prime,result,aut,i,classical,classaut,shortname,
      multElabel;

  shortname:=function(gp)
  local s;
    if IsCyclic(gp) then
      return String(Size(gp));
    elif IdGroup(gp)=[4,2] then
      return "2^2";
    elif IdGroup(gp)=[6,1] then
      return "3.2";
    elif IdGroup(gp)=[8,3] then
      return "2^2.2";
    elif IdGroup(gp)=[9,2] then
      return "3^2";
    elif IdGroup(gp)=[18,3] then
      return "3^2.2";
    elif Size(gp)<=31 or Size(gp) in [33..47] then
      s:=StructureDescription(gp);
      s:=Filtered(s,x->not x in "C ");
      if Length(s)>3 and s{[Length(s)-2..Length(s)]}="xS3" then
        s:=Concatenation(s{[1..Length(s)-3]},".3.2");
      fi;
      return s;
    else
      Error("name not yet found");
    fi;
  end;

  multElabel:=function()
  local a,b,j;
    for a in e do
      b:=Filtered(e,x->x[2]=a[2]);
      if Length(b)>1 then
        for j in [1..Length(b)] do
          b[j][2]:=Concatenation(b[j][2],"_",String(j));
        od;
      fi;
    od;
    Sort(e);
  end;

  # fix O5 to SP4
  if id.series="B" and id.parameter[1]=2 then
    id:=rec(name:=id.name,series:="C",parameter:=id.parameter,
      shortname:=Concatenation("S4(",String(id.parameter[2]),")"));
  fi;

  # fix

  if IsBound(id.parameter) then
    par:=id.parameter;
    if IsList(par) then
      prime:=Factors(par[2])[1];
      expo:=LogInt(par[2],prime);
    else
      prime:=Factors(par)[1];
      expo:=LogInt(par,prime);
    fi;
  fi;

  efactors:=fail;
  classaut:=fail;
  e:=fail;

  classical:=fail;
  if id.series="Spor" then
    nam:=id.name;
    # deal wirth stupid names in identification

    if nam in ["M(11)","M(12)","M(22)","M(23)","M(24)","J(1)","J(3)",
               "J(4)","Co(3)","Co(2)","Fi(22)","Fi(23)"] then
      nam:=Filtered(nam,x->x<>'(' and x<>')');
    elif nam="HJ = J(2) = F(5-)" then
      nam:="J2";
    elif nam="He = F(7)" then
      nam:="He";
    elif nam="Fi(24) = F(3+)" then
      nam:="F3+";
    elif nam="Mc" then
      nam:="McL";
    elif nam="HN = F(5) = F = F(5+)" then
      nam:="HN";
    elif nam="Th = F(3) = E = F(3/3)" then
      nam:="Th";
    elif nam="Co(1) = F(2-)" then
      nam:="Co1";
    elif nam="B = F(2+)" then
      nam:="B";
    elif nam="M = F(1)" then
      nam:="M";
    fi;
    if nam in ["M12","M22","HS","McL","He","Fi22","F3+","HN","Suz","ON",
               "J2","J3"] then
      e:=[[2,"2"]];
    else
      e:=[];
    fi;
  elif id.series="A" then
    nam:=Concatenation("A",String(par));
    if par=6 then
      e:=[[2,"2_1"],[2,"2_2"],[2,"2_3"],[4,"2^2"]];
    else
      e:=[[2,"2"]];
    fi;
  elif id.series="L" then
    classical:=["L",par[1],par[2]];
    nam:=Concatenation("L",String(par[1]),"(",String(par[2]),")");
    if par[1]=2 then
      efactors:=[Gcd(2,par[2]-1),expo,1];
    else
      efactors:=[Gcd(par[1],par[2]-1),expo,2];
    fi;
  elif id.series="2A" then
    classical:=["U",par[1]+1,par[2]];
    nam:=Concatenation("U",String(par[1]+1),"(",String(par[2]),")");
    efactors:=[Gcd(par[1]+1,par[2]+1),2*expo,1];
  elif id.series="B" then
    classical:=["O",2*par[1]+1,par[2]];
    if IsEvenInt(par[2]) then
      nam:=Concatenation("S",String(2*par[1]),"(",String(par[2]),")");
    else
      nam:=Concatenation("O",String(2*par[1]+1),"(",String(par[2]),")");
    fi;
    if par[1]=2 and par[2]=3 then
      nam:="U4(2)"; # library name
    fi;
    if par[1]=2 and prime=2 then
      efactors:=[Gcd(2,par[2]-1),expo,2];
    else
      efactors:=[Gcd(2,par[2]-1),expo,1];
    fi;
  elif id.series="2B" then
    nam:=Concatenation("Sz(",String(par),")");
    efactors:=[1,expo,1];
  elif id.series="C" then
    classical:=["S",2*par[1],par[2]];
    nam:=Concatenation("S",String(par[1]*2),"(",String(par[2]),")");
    if par[1]=2 and prime=2 then
      efactors:=[Gcd(2,par[2]-1),expo,2];
    else
      efactors:=[Gcd(2,par[2]-1),expo,1];
    fi;
  elif id.series="D" then
    classical:=["O+",2*par[1],par[2]];
    nam:=Concatenation("O",String(par[1]*2),"+(",String(par[2]),")");
    if par[1]=4 then
      efactors:=[Gcd(2,par[2]-1)^2,expo,6];
    elif IsEvenInt(par[1]) then
      efactors:=[Gcd(2,par[2]-1)^2,expo,2];
    else
      efactors:=[Gcd(4,par[2]^par[1]-1),expo,2];
    fi;
  elif id.series="2D" then
    classical:=["O-",2*par[1],par[2]];
    nam:=Concatenation("O",String(par[1]*2),"-(",String(par[2]),")");

    efactors:=[Gcd(4,par[2]^par[1]+1),2*expo,1];

  elif id.series="F" then
    nam:=Concatenation("F4(",String(par),")");
    if prime=2 then
      efactors:=[1,expo,2];
      # outer automorphism group is cyclic
      classaut:=CyclicGroup(2*expo);
    else
      efactors:=[1,expo,1];
    fi;

  elif id.series="G" then
    nam:=Concatenation("G2(",String(par),")");
    if prime=3 then
      efactors:=[1,expo,2];
      # outer automorphism group is cyclic
      classaut:=CyclicGroup(2*expo);
    else
      efactors:=[1,expo,1];
    fi;

  elif id.series="3D" then
    nam:=Concatenation("3D4(",String(par),")");
    efactors:=[1,3*expo,1];
  elif id.series="2G" then
    nam:=Concatenation("R(",String(par),")");
    efactors:=[1,expo,1];
  elif id.series="2F" and id.parameter=2 then
    # special case for tits' group before sorting out further 2F4's
    nam:="2F4(2)'";
    e:=[[2,"2"]];
  else
    Info(InfoWarning,1,"simple group tom nonidentified/not yet done");
    nam:=fail;
    e:=fail;
  fi;

  aut:=fail;
  if classical<>fail then
    classaut:=OuterAutoSimplePres(classical[1],classical[2],classical[3]);
    if classaut<>fail then
      if efactors<>fail and Size(classaut)<>Product(efactors) then
        Error("outer automorphism efactor fail");
      fi;
      if IdGroup(classaut)=[4,2] then
        # subgroup classes V4
        e:=[[2,"2_1"],[2,"2_2"],[2,"2_3"],[4,"2^2"]];
      elif IdGroup(classaut)=[6,1] then
        # subgroup classes S_3
        e:=[  [ 2, "2" ], [ 3, "3" ], [ 6, "3.2" ] ];
      elif IdGroup(classaut)=[12,4] then
        # subgroup classes 2\times S_3 (since S3 cannot act on C2)
        e:=[ [ 2, "2_1" ], [ 2, "2_2" ], [ 2, "2_3" ], [ 3, "3" ],
             [ 4, "2^2" ], [ 6, "3.2_1" ], [ 6, "3.2_2" ], [ 6, "6" ],
             [ 12, "3.2^2" ] ];
      elif IdGroup(classaut)=[24,12] then
        # subgroup classes S_4
        e:=[  [ 2, "2_1" ],[ 2, "2_2" ], [ 3, "3" ],
              [ 4, "4" ], [ 4, "(2^2)_{111}" ], [4,"(2^2)_{122}"],
              [ 6, "3.2" ], [ 8, "D8" ], [ 12, "A4" ],
              [ 24, "S4" ] ];
      else
        e:=List(ConjugacyClassesSubgroups(classaut),Representative);
        e:=Filtered(e,x->Size(x)>1);
        e:=List(e,x->[Size(x),shortname(x)]);
        multElabel();
      fi;
    fi;
  elif e=fail and efactors<>fail then

# outer automorphism group -- also being described through efactors.
# Atlas of Finite Groups (Chapter 3, Section 3) says:
#
#The outer automorphism group is a semidirect product (in this order) of
#groups of orders d (diagonal automorphisms), f (field automorphisms), and g
#(graph automorphisms modulo field automorphisms), except that for
#B_2(2^f), G_2(3^f), F_4(2^f)
# Note that B2 is handled as C2 -- symplectic

    if not IsGroup(classaut) then
      if Number(efactors,x->x>1)>1 then
        Error("Code currently does not support more than one efactor,\n",
          "Group could be nonabelian");
      fi;
      classaut:=AbelianGroup(efactors);
    fi;
    e:=List(ConjugacyClassesSubgroups(classaut),Representative);
    e:=Filtered(e,x->Size(x)>1);
    e:=List(e,x->[Size(x),shortname(x)]);
    multElabel();
  fi;
  if e=fail then Error("eh?");fi;

  if aut=fail then
    if Length(e)=0 then
      aut:=[1,"1"];
    else
      aut:=Maximum(e);
    fi;
  fi;

  result:=rec(idSimple:=id,
              tomName:=nam,
              allExtensions:=e,
              fullAutGroup:=aut,
              classicalId:=ClassicalIsomorphismTypeFiniteSimpleGroup(id));
  if classaut<>fail then
    result.outerAutomorphismGroup:=classaut;
  fi;
  if efactors<>fail then result.efactors:=efactors;fi;

  return result;
end);

InstallGlobalFunction(SufficientlySmallDegreeSimpleGroupOrder,function(n)
local a;
  if n<168 then return 5;fi;
  a:=Filtered(SIMPLEGPSNONL2,x->x[1]=n);
  # we have degree data up to order 2^55
  if n<=2^55 and Length(a)=0 then
    # L2 case
    return 2*RootInt(n,3);
  elif Length(a)>0 and ForAll(a,x->Length(x)>4) then
    return Maximum(List(a,x->x[5]));
  fi;
  # we don't know a smallest degree
  a:=2^Number(Factors(n),x->x=2);
  return n/a; # 2-Sylow index
end);

InstallGlobalFunction("EpimorphismFromClassical",function(G)
local H,d,id,hom,field,C,dom,orbs;
  if not IsSimpleGroup(G) then
    H:=PerfectResiduum(G);
  else
    H:=G;
  fi;
  id:=ValueOption("forcetype");
  if id=fail then
    d:=DataAboutSimpleGroup(H);
    id:=d.idSimple;
  fi;
  if not id.series in ["L","2A","C","D","2D","B"] then
    return fail;
  fi;

  # TODO: Recognize subgroups of almost
  if G<>H then
    return fail;
  fi;

  field:=id.parameter[2];
  if id.series="2A" then
    field:=field^2;
  fi;

  # the source group we are expecting
  if id.series="L" then
    C:=SL(id.parameter[1],id.parameter[2]);
  elif id.series="C" then
    C:=SP(2*id.parameter[1],id.parameter[2]);
  elif id.series="2A" then
    C:=SU(id.parameter[1]+1,id.parameter[2]);
  elif id.series="D" then
    C:=SO(1,2*id.parameter[1],id.parameter[2]);
    C:=DerivedSubgroup(C);
  elif id.series="2D" then
    C:=SO(-1,2*id.parameter[1],id.parameter[2]);
    C:=DerivedSubgroup(C);
  elif id.series="B" then
    C:=SO(0,2*id.parameter[1]+1,id.parameter[2]);
    C:=DerivedSubgroup(C);
  else
    Error("not yet done");
  fi;

  # was the fgroup created as ``P...''?
  if IsBound(G!.actionHomomorphism) then
    hom:=G!.actionHomomorphism;
    if IsMatrixGroup(Source(hom)) and Image(hom)=G and Size(Source(hom))/Size(G)<field then
      # test that the source is really the group we want
      if GeneratorsOfGroup(C)=GeneratorsOfGroup(Source(hom))
        or Source(hom)=C then
          return hom;
      #else
#       Print("different source -- ID\n");
      fi;
    fi;
  fi;


  # build isom
  dom:=NormedRowVectors(DefaultFieldOfMatrixGroup(C)^DimensionOfMatrixGroup(C));
  hom:=ActionHomomorphism(C,dom,OnLines,"surjective");
  orbs:=Orbits(Image(hom),MovedPoints(Image(hom)));
  if Length(orbs)>1 then
    # reduce domain
    orbs:=ShallowCopy(orbs);
    SortBy(orbs,Length);
    dom:=dom{Set(orbs[1])};
    hom:=ActionHomomorphism(C,dom,OnLines,"surjective");
  fi;

  if Size(Image(hom))<>Size(G) then
    Error("inconsistent image");
  fi;

  if # catch if one group is with memory
     RepresentationsOfObject(One(Image(hom)))=
     RepresentationsOfObject(One(G))
     and Image(hom)=G then
    d:=IdentityMapping(G);
  else
    # only force isomorphism if we really want it -- e.g. maximal subgroups
    if ValueOption("classicepiuseiso")<>true then
      return fail;
    fi;
    # Image(hom) is the better group to search in, e.g. classes.
    d:=Image(hom);
    d!.actionHomomorphism:=hom;
    # option to avoid infinite recursion
    d:=IsomorphismGroups(G,Image(hom):classicepiuseiso:=false);
  fi;
  if d=fail then
    Error("inconsistent image 2");
  fi;
  return hom*RestrictedInverseGeneralMapping(d);

end);
