InstallMethod(RecognitionData,"set up",true,[IsGroup],0,
  G->rec(orderStatistics:=[], # found element orders
         impossible:=[], # types that are provenly impossible
	 unlikely:=[] # types that are unlikely
	 ));

InstallGlobalFunction(OrderRecog,function(elm,data)
local o;
  o:=Order(elm);
  if not IsBound(data.orderStatistics[o]) then
    data.orderStatistics[o]:=1;
  else
    data.orderStatistics[o]:=data.orderStatistics[o]+1;
  fi;
end);

InstallGlobalFunction(InstallRecognitionMethod,
function(type,checkdim,checkfield,natchar,natrep,fct)
local val;
  val:=0;
  if natchar then
    val:=1;
    if natrep then
      val:=2;
    fi;
  fi;
  Add(RECOGMETHODS,[fct,type,checkdim,checkfield,val]);
end);

InstallGlobalFunction(ProbabilisticRecognitionType,function(G)
local data, cands;
  data:=RecognitionData(G);
  if IsBound(data.candidates) then
    cands:=data.candidates;
  else
    cands:=[];
  fi;

  repeat

    # get the most likely candidates by order statistic
    if Length(data.know)>0 then
      cands:=data.know;
    else
      Error("set cands:= <list of types>; and  return;");
    fi;

    if IsBound(data.know) then
      cands:=Filtered(cands,i->i in data.know);
    fi;
    if IsBound(data.impossible) then
      cands:=Filtered(cands,i->not i in data.impossible);
    fi;
  until Length(cands)>0; # if wrong input could iterate eternally

  # rearrange by likely/unlikeliness
  if IsBound(data.unlikely) then
    cands:=Concatenation(
             Filtered(cands,i->not i in data.unlikely),
             Filtered(cands,i->i in data.unlikely)    );
  fi;
  data.candidates:=cands{[2..Length(cands)]};
  return cands[1];
end);

InstallGlobalFunction(ConstructiveRecognition,function(arg)
local G, data, type, fct, val, i, meth, recog;

  G:=arg[1];

  # set up recog data attribute
  data:=RecognitionData(G);

  if Length(arg)>1 then
    # remember excluded groups
    Append(data.impossible,arg[2]);
  fi;
  if Length(arg)>2 then
    data.know:=arg[3];
  fi;

  repeat

    # what is the next candidate to test
    type:=ProbabilisticRecognitionType(G);

    data.type:=type;
    # find a suitable recognition method

    fct:=fail;

    val:=0;
    if Length(type)=3 and IsMatrixGroup(G) and Characteristic(G)=type[3] then
      # we are a matrix group in same characteristic
      val:=1;
      if DimensionOfMatrixGroup(G)=type[2] then
	# we might even be natural
	val:=2;
      fi;
    elif Length(type)=2 and IsPermGroup(G) and NrMovedPoints(G)=type[2] then
      # we are a perm group of same nr of points (natural An)
      val:=1;
    fi;

    repeat
      while val>=0 and fct=fail do
	# search for functions with value `val' (this will give us most
	# specific ones first
	i:=1;
	while i<=Length(RECOGMETHODS) do
	  meth:=RECOGMETHODS[i];
	  if meth[2]=type[1] # right type
	    and meth[5]=val  # right kind of ``naturality''
	    and meth[3](type[2]) # the method is happy with the dimension
	    and meth[4](type[3]) # the method is happy with the characteristic
	    then
	      if fct<>fail then
		# so far we assume only one method.
		Info(InfoWarning,1,"Several applicable methods for type ",
				    type,", choosing last");
	      fi;
	      fct:=meth[1];
	  fi;
	  i:=i+1;
	od;
	val:=val-1;
      od;

      # if there is no recognition method we set `recog' 
      if fct=fail then
	recog:=MISSINGID;
      else
	# call it
	recog:=fct(G,type,data);
	# interpret the results
	if recog=false then
	  if val<>1 then
	    Add(data.impossible,type);
	  fi;
	elif recog=fail then
	  if val<>1 then
	    if not IsBound(data.unlikely) then
	      data.unlikely:=[];
	    fi;
	    Add(data.unlikely,type);
	  fi;
	fi;
      fi;

    # if natural recognition failed, it might be nonnatural in same
    # characteristic and dimension -- can this ever happen?
    until IsGroupHomomorphism(recog) or recog=MISSINGID 
      or val<>1;

  until IsGroupHomomorphism(recog) or recog=MISSINGID;

  # clean up data
  Unbind(data.impossible);
  Unbind(data.unlikely);
  Unbind(data.know);
  if recog=MISSINGID then
    recog:=fail;
  fi;
  return recog;

end);

