#############################################################################
##
##  pickle.gi           GAP 4 package IO
##                                                           Max Neunhoeffer
##
##  Copyright (C) by Max Neunhoeffer
##  This file is free software, see license information at the end.
##
##  This file contains functions for pickling and unpickling.
##

#################
# (Un-)Pickling: 
#################

InstallValue( IO_PICKLECACHE, rec( ids := [], nrs := [], obs := [],
                                   depth := 0 ) );

InstallGlobalFunction( IO_ClearPickleCache,
  function( )
    IO_PICKLECACHE.ids := [];
    IO_PICKLECACHE.nrs := [];
    IO_PICKLECACHE.obs := [];
    IO_PICKLECACHE.depth := 0;
  end );

InstallGlobalFunction( IO_AddToPickled,
  function( ob )
    local id,pos;
    IO_PICKLECACHE.depth := IO_PICKLECACHE.depth + 1;
    id := IO_MasterPointerNumber(ob);
    pos := PositionSorted( IO_PICKLECACHE.ids, id );
    if pos <= Length(IO_PICKLECACHE.ids) and IO_PICKLECACHE.ids[pos] = id then
        return IO_PICKLECACHE.nrs[pos];
    else
        Add(IO_PICKLECACHE.ids,id,pos);
        Add(IO_PICKLECACHE.nrs,Length(IO_PICKLECACHE.ids),pos);
        return false;
    fi;
  end );

InstallGlobalFunction( IO_IsAlreadyPickled,
  function( ob )
    local id,pos;
    id := IO_MasterPointerNumber(ob);
    pos := PositionSorted( IO_PICKLECACHE.ids, id );
    if pos <= Length(IO_PICKLECACHE.ids) and IO_PICKLECACHE.ids[pos] = id then
        return IO_PICKLECACHE.nrs[pos];
    else
        return false;
    fi;
  end );

InstallGlobalFunction( IO_FinalizePickled,
  function( )
    if IO_PICKLECACHE.depth <= 0 then
        Error("pickling depth has gone below zero!");
    fi;
    IO_PICKLECACHE.depth := IO_PICKLECACHE.depth - 1;
    if IO_PICKLECACHE.depth = 0 then
        # important to clear the cache:
        IO_PICKLECACHE.ids := [];
        IO_PICKLECACHE.nrs := [];
    fi;
  end );

InstallGlobalFunction( IO_AddToUnpickled,
  function( ob )
    IO_PICKLECACHE.depth := IO_PICKLECACHE.depth + 1;
    Add( IO_PICKLECACHE.obs, ob );
  end );

InstallGlobalFunction( IO_FinalizeUnpickled,
  function( )
    if IO_PICKLECACHE.depth <= 0 then
        Error("pickling depth has gone below zero!");
    fi;
    IO_PICKLECACHE.depth := IO_PICKLECACHE.depth - 1;
    if IO_PICKLECACHE.depth = 0 then
        # important to clear the cache:
        IO_PICKLECACHE.obs := [];
    fi;
  end );

InstallGlobalFunction( IO_WriteSmallInt,
  function( f, i )
    local h,l;
    h := HexStringInt(i);
    l := Length(h);
    Add(h,CHAR_INT(Length(h)),1);
    if IO_Write(f,h) = fail then
        return IO_Error;
    else
        return IO_OK;
    fi;
  end ); 

InstallGlobalFunction( IO_ReadSmallInt,
  function( f )
    local h,l;
    l := IO_ReadBlock(f,1);
    if l = "" or l = fail then return IO_Error; fi;
    h := IO_ReadBlock(f,INT_CHAR(l[1]));
    if h = fail or Length(h) < INT_CHAR(l[1]) then return IO_Error; fi;
    return IntHexString(h);
  end );

InstallGlobalFunction( IO_WriteAttribute,
  # can also do properties
  function( f, at, ob )
    if IO_Pickle(f, Tester(at)(ob)) = IO_Error then return IO_Error; fi;
    if Tester(at)(ob) then
        if IO_Pickle(f, at(ob)) = IO_Error then return IO_Error; fi;
    fi;
    return IO_OK;
  end );

InstallGlobalFunction( IO_ReadAttribute,
  # can also do properties
  function( f, at, ob )
    local val;
    val := IO_Unpickle(f);
    if val = IO_Error then return IO_Error; fi;
    if val = true then
        val := IO_Unpickle(f);
        if val = IO_Error then return IO_Error; fi;
        Setter(at)(ob,val);
    fi;
    return IO_OK;
  end );

InstallGlobalFunction( IO_PickleByString,
  function( f, ob, tag )
    local s;
    s := String(ob);
    if IO_Write(f,tag) = fail then return IO_Error; fi;
    if IO_WriteSmallInt(f,Length(s)) = IO_Error then return IO_Error; fi;
    if IO_Write(f,s) = fail then return IO_Error; fi;
    return IO_OK;
  end );
  
InstallGlobalFunction( IO_UnpickleByEvalString,
  function( f )
    local len,s;
    len := IO_ReadSmallInt(f);
    if len = IO_Error then return IO_Error; fi;
    s := IO_ReadBlock(f,len);
    if s = fail then return IO_Error; fi;
    return EvalString(s);
  end );
  
InstallGlobalFunction( IO_GenericObjectPickler,
  function( f, tag, prepickle, ob, atts, filts, comps )
    local at,com,fil,nr,o;
    nr := IO_IsAlreadyPickled(ob);
    if nr = false then    # not yet known
        if IO_Write(f,tag) = fail then return IO_Error; fi;
        for o in prepickle do
            if IO_Pickle(f,o) = IO_Error then return IO_Error; fi;
        od;
        nr := IO_AddToPickled(ob);
        if nr <> false then
            Error("prepickle objects had references to object - panic!");
            return IO_Error;
        fi;
        for at in atts do
            if IO_WriteAttribute(f,at,ob) = IO_Error then 
                IO_FinalizePickled();
                return IO_Error;
            fi;
        od;
        for fil in filts do
            if IO_Pickle(f,fil(ob)) = IO_Error then 
                IO_FinalizePickled();
                return IO_Error; 
            fi;
        od;
        for com in comps do
            if IsBound(ob!.(com)) then
                if IO_Pickle(f,com) = IO_Error then 
                    IO_FinalizePickled();
                    return IO_Error; 
                fi;
                if IO_Pickle(f,ob!.(com)) = IO_Error then 
                    IO_FinalizePickled();
                    return IO_Error; 
                fi;
            fi;
        od;
        IO_FinalizePickled();
        if IO_Pickle(f,fail) = IO_Error then return IO_Error; fi;
        return IO_OK;
    else   # this object was already pickled once!
        if IO_Write(f,"SREF") = IO_Error then 
            return IO_Error;
        fi;
        if IO_WriteSmallInt(f,nr) = IO_Error then
            return IO_Error;
        fi;
        return IO_OK;
    fi;
  end );

InstallGlobalFunction( IO_GenericObjectUnpickler,
  function( f, ob, atts, filts )
    local at,fil,val,val2;
    IO_AddToUnpickled(ob);
    for at in atts do
        if IO_ReadAttribute(f,at,ob) = IO_Error then 
            IO_FinalizeUnpickled();
            return IO_Error; 
        fi;
    od;
    for fil in filts do
        val := IO_Unpickle(f);
        if val = IO_Error then 
            IO_FinalizeUnpickled();
            return IO_Error; 
        fi;
        if val <> fil(ob) then
            if val then
                SetFilterObj(ob,fil);
            else
                ResetFilterObj(ob,fil);
            fi;
        fi;
    od;
    while true do
        val := IO_Unpickle(f);
        if val = fail then 
            IO_FinalizeUnpickled();
            return ob;
        fi;
        if val = IO_Error then 
            IO_FinalizeUnpickled();
            return IO_Error; 
        fi;
        if IsString(val) then
            val2 := IO_Unpickle(f);
            if val2 = IO_Error then 
                IO_FinalizeUnpickled();
                return IO_Error; 
            fi;
            ob!.(val) := val2;
        fi;
    od;
  end );

        
InstallMethod( IO_Unpickle, "for a file",
  [ IsFile ],
  function( f )
    local magic,up;
    magic := IO_ReadBlock(f,4);
    if magic = fail then return IO_Error; 
    elif Length(magic) < 4 then return IO_Nothing; 
    fi;
    if not(IsBound(IO_Unpicklers.(magic))) then
        Print("No unpickler for magic value \"",magic,"\"\n");
        Print("Maybe you have to load a package for this to work?\n");
        return IO_Error;
    fi;
    up := IO_Unpicklers.(magic);
    if IsFunction(up) then
        return up(f);
    else
        return up;
    fi;
  end );

InstallMethod(IO_Pickle, "for an object, pickle to string method",
  [IsObject],
  function(o)
    local f,s;
    s := EmptyString(1000000);
    f := IO_WrapFD(-1,false,s);
    IO_Pickle(f,o);
    IO_Close(f);
    ShrinkAllocationString(s);
    return s;
  end);

InstallMethod(IO_Unpickle, "for a string, unpickle from string method",
  [IsStringRep],
  function(s)
    local f,o;
    f := IO_WrapFD(-1,s,false);
    o := IO_Unpickle(f);
    IO_Close(f);
    return o;
  end);

InstallMethod( IO_Pickle, "for an integer",
  [ IsFile, IsInt ],
  function( f, i )
    local h;
    if IO_Write( f, "INTG" ) = fail then return IO_Error; fi;
    h := HexStringInt(i);
    if IO_WriteSmallInt( f, Length(h) ) = fail then return IO_Error; fi;
    if IO_Write(f,h) = fail then return fail; fi;
    return IO_OK;
  end );

IO_Unpicklers.INTG :=
  function( f )
    local h,len;
    len := IO_ReadSmallInt(f);
    if len = IO_Error then return IO_Error; fi;
    h := IO_ReadBlock(f,len);
    if h = fail or Length(h) < len then return IO_Error; fi;
    return IntHexString(h);
  end;

InstallMethod( IO_Pickle, "for a string",
  [ IsFile, IsStringRep and IsList ],
  function( f, s )
    local tag;
    if IsMutable(s) then tag := "MSTR";
    else tag := "ISTR"; fi;
    if IO_Write(f,tag) = fail then return IO_Error; fi;
    if IO_WriteSmallInt(f, Length(s)) = IO_Error then return IO_Error; fi;
    if IO_Write(f,s) = fail then return IO_Error; fi;
    return IO_OK;
  end );

IO_Unpicklers.MSTR :=
  function( f )
    local len,s;
    len := IO_ReadSmallInt(f);
    if len = IO_Error then return IO_Error; fi;
    s := IO_ReadBlock(f,len);
    if s = fail or Length(s) < len then return IO_Error; fi;
    return s;
  end;

IO_Unpicklers.ISTR := 
  function( f )
    local s;
    s := IO_Unpicklers.MSTR(f); if s = IO_Error then return IO_Error; fi;
    MakeImmutable(s);
    return s;
  end;

InstallMethod( IO_Pickle, "for a boolean",
  [ IsFile, IsBool ],
  function( f, b )
    local val;
    if b = false then val := "FALS";
    elif b = true then val := "TRUE";
    elif b = fail then val := "FAIL";
    elif b = SuPeRfail then val := "SPRF";
    else
        Error("Unknown boolean value");
    fi;
    if IO_Write(f,val) = fail then 
        return IO_Error;
    else
        return IO_OK;
    fi;
  end );

IO_Unpicklers.FALS := false;
IO_Unpicklers.TRUE := true;
IO_Unpicklers.FAIL := fail;
IO_Unpicklers.SPRF := SuPeRfail;

InstallMethod( IO_Pickle, "for a permutation",
  [ IsFile, IsPerm ],
  function( f, p )
    return IO_PickleByString( f, p, "PERM" );
  end );

IO_Unpicklers.PERM := IO_UnpickleByEvalString;

InstallMethod( IO_Pickle, "for a character",
  [ IsFile, IsChar ],
  function(f, c)
    local s;
    s := "CHARx";
    s[5] := c;
    if IO_Write(f,s) = fail then return IO_Error; fi;
    return IO_OK;
  end );

IO_Unpicklers.CHAR :=
  function( f )
    local s;
    s := IO_ReadBlock(f,1);
    if s = fail or Length(s) < 1 then return IO_Error; fi;
    return s[1];
  end;

InstallMethod( IO_Pickle, "for a finite field element",
  [ IsFile, IsFFE ], 
  function( f, ffe )
    return IO_PickleByString( f, ffe, "FFEL" );
  end );

IO_Unpicklers.FFEL := IO_UnpickleByEvalString;

InstallMethod( IO_Pickle, "for a cyclotomic",
  [ IsFile, IsCyclotomic ],
  function( f, cyc )
    return IO_PickleByString( f, cyc, "CYCL" );
  end );

IO_Unpicklers.CYCL := IO_UnpickleByEvalString;

InstallMethod( IO_Pickle, "for a list",
  [ IsFile, IsList ],
  function( f, l )
    local count,i,nr,tag;
    nr := IO_AddToPickled(l);
    if nr = false then   # not yet known
        # Here we have to do something
        if IsMutable(l) then tag := "M"; else tag := "I"; fi;
        if IsGF2VectorRep(l) then Append(tag,"F2V");
        elif Is8BitVectorRep(l) then Append(tag,"F8V");
        elif IsGF2MatrixRep(l) then Append(tag,"F2M");
        elif Is8BitMatrixRep(l) then Append(tag,"F8M");
        else Append(tag,"LIS"); fi;
        if IO_Write(f,tag) = fail then 
            IO_FinalizePickled();
            return IO_Error;
        fi;
        if IO_WriteSmallInt(f,Length(l)) = IO_Error then
            IO_FinalizePickled();
            return IO_Error;
        fi;
        count := 0;
        i := 1;
        while i <= Length(l) do
            if not(IsBound(l[i])) then
                count := count + 1;
            else
                if count > 0 then
                    if IO_Write(f,"GAPL") = fail then
                        IO_FinalizePickled();
                        return IO_Error;
                    fi;
                    if IO_WriteSmallInt(f,count) = IO_Error then
                        IO_FinalizePickled();
                        return IO_Error;
                    fi;
                    count := 0;
                fi;
                if IO_Pickle(f,l[i]) = IO_Error then
                    IO_FinalizePickled();
                    return IO_Error;
                fi;
            fi;
            i := i + 1;
        od;
        # Note that the last entry is always bound!
        IO_FinalizePickled();
        return IO_OK;
    else
        if IO_Write(f,"SREF") = IO_Error then 
            IO_FinalizePickled();
            return IO_Error;
        fi;
        if IO_WriteSmallInt(f,nr) = IO_Error then
            IO_FinalizePickled();
            return IO_Error;
        fi;
        IO_FinalizePickled();
        return IO_OK;
    fi;
  end );

IO_Unpicklers.MLIS := 
  function( f )
    local i,j,l,len,ob;
    len := IO_ReadSmallInt(f);
    if len = IO_Error then return IO_Error; fi;
    l := 0*[1..len];
    IO_AddToUnpickled(l);
    i := 1;
    while i <= len do
        ob := IO_Unpickle(f);
        if ob = IO_Error then
            IO_FinalizeUnpickled();
            return IO_Error;
        fi;
        # IO_OK or IO_Nothing cannot happen!
        if IO_Result(ob) then
            if ob!.val = "Gap" then   # this is a Gap
                for j in [0..ob!.nr-1] do
                    Unbind(l[i+j]);
                od;
                i := i + ob!.nr;
            fi;
        else
            l[i] := ob;
            i := i + 1;
        fi;
    od;  # i is already incremented
    IO_FinalizeUnpickled();
    return l;
  end;

IO_Unpicklers.ILIS :=
  function( f )
    local l;
    l := IO_Unpicklers.MLIS(f); if l = IO_Error then return IO_Error; fi;
    MakeImmutable(l);
    return l;
  end;

IO_Unpicklers.MF2V :=
  function( f )
    local v;
    v := IO_Unpicklers.MLIS(f); if v = IO_Error then return IO_Error; fi;
    ConvertToVectorRep(v,2);
    return v;
  end;

IO_Unpicklers.MF8V :=
  function( f )
    local v;
    v := IO_Unpicklers.MLIS(f); if v = IO_Error then return IO_Error; fi;
    ConvertToVectorRep(v);
    return v;
  end;
 
IO_Unpicklers.IF2V :=
  function( f )
    local v;
    v := IO_Unpicklers.MLIS(f); if v = IO_Error then return IO_Error; fi;
    ConvertToVectorRep(v);
    MakeImmutable(v);
    return v;
  end;
    
IO_Unpicklers.IF8V :=
  function( f )
    local v;
    v := IO_Unpicklers.MLIS(f); if v = IO_Error then return IO_Error; fi;
    ConvertToVectorRep(v);
    MakeImmutable(v);
    return v;
  end;
 
IO_Unpicklers.MF2M :=
  function( f )
    local v;
    v := IO_Unpicklers.MLIS(f); if v = IO_Error then return IO_Error; fi;
    ConvertToMatrixRep(v,2);
    return v;
  end;

IO_Unpicklers.MF8M :=
  function( f )
    local v;
    v := IO_Unpicklers.MLIS(f); if v = IO_Error then return IO_Error; fi;
    ConvertToMatrixRep(v);
    return v;
  end;
 
IO_Unpicklers.IF2M :=
  function( f )
    local v;
    v := IO_Unpicklers.MLIS(f); if v = IO_Error then return IO_Error; fi;
    ConvertToMatrixRep(v);
    MakeImmutable(v);
    return v;
  end;
    
IO_Unpicklers.IF8M :=
  function( f )
    local v;
    v := IO_Unpicklers.MLIS(f); if v = IO_Error then return IO_Error; fi;
    ConvertToMatrixRep(v);
    MakeImmutable(v);
    return v;
  end;
 
IO_Unpicklers.GAPL :=
  function( f )
    local ob;
    ob := rec( val := "Gap", nr := IO_ReadSmallInt(f) );
    if ob.nr = IO_Error then
        return IO_Error;
    fi;
    return Objectify( NewType( IO_ResultsFamily, IO_Result ), ob );
  end;

IO_Unpicklers.SREF := 
  function( f )
    local nr;
    nr := IO_ReadSmallInt(f); if nr = IO_Error then return IO_Error; fi;
    if not(IsBound(IO_PICKLECACHE.obs[nr])) then
        Print("Found a self-reference to an unknown object!\n");
        return IO_Error;
    fi;
    return IO_PICKLECACHE.obs[nr];
  end;

InstallMethod( IO_Pickle, "for a record",
  [ IsFile, IsRecord ],
  function( f, r )
    local n,names,nr,tag;
    nr := IO_AddToPickled(r);
    if nr = false then   # not yet known
        # Here we have to do something
        if IsMutable(r) then tag := "MREC";
        else tag := "IREC"; fi;
        if IO_Write(f,tag) = fail then
            IO_FinalizePickled();
            return IO_Error;
        fi;
        names := RecNames(r);
        if IO_WriteSmallInt(f,Length(names)) = IO_Error then
            IO_FinalizePickled();
            return IO_Error;
        fi;
        for n in names do
            if IO_Pickle(f,n) = IO_Error then
                IO_FinalizePickled();
                return IO_Error;
            fi;
            if IO_Pickle(f,r.(n)) = IO_Error then
                IO_FinalizePickled();
                return IO_Error;
            fi;
        od;
        IO_FinalizePickled();
        return IO_OK;
    else
        if IO_Write(f,"SREF") = IO_Error then 
            IO_FinalizePickled();
            return IO_Error;
        fi;
        if IO_WriteSmallInt(f,nr) = IO_Error then
            IO_FinalizePickled();
            return IO_Error;
        fi;
        IO_FinalizePickled();
        return IO_OK;
    fi;
  end );

IO_Unpicklers.MREC := 
  function( f )
    local i,len,name,ob,r;
    len := IO_ReadSmallInt(f);
    if len = IO_Error then return IO_Error; fi;
    r := rec();
    IO_AddToUnpickled(r);
    for i in [1..len] do
        name := IO_Unpickle(f);
        if name = IO_Error or not(IsString(name)) then
            IO_FinalizeUnpickled();
            return IO_Error;
        fi;
        ob := IO_Unpickle(f);
        if IO_Result(ob) then
            if ob = IO_Error then
                IO_FinalizeUnpickled();
                return IO_Error;
            fi;
        else
            r.(name) := ob;
        fi;
    od;
    IO_FinalizeUnpickled();
    return r;
  end;

IO_Unpicklers.IREC :=
  function( f )
    local r;
    r := IO_Unpicklers.MREC(f); if r = IO_Error then return IO_Error; fi;
    MakeImmutable(r);
    return r;
  end;

InstallMethod( IO_Pickle, "IO_Results are forbidden",
  [ IsFile, IO_Result ],
  function( f, ob )
    Print("Pickling of IO_Result is forbidden!\n");
    return IO_Error;
  end );

InstallMethod( IO_Pickle, "for rational functions",
  [ IsFile, IsPolynomialFunction and IsRationalFunctionDefaultRep ],
  function( f, pol )
    local num,den,one;
    one := One(CoefficientsFamily(FamilyObj(pol)));
    num := ExtRepNumeratorRatFun(pol);
    den := ExtRepDenominatorRatFun(pol);
    if IO_Write(f,"RATF") = fail then return IO_Error; fi;
    if IO_Pickle(f,one) = IO_Error then return IO_Error; fi;
    if IO_Pickle(f,num) = IO_Error then return IO_Error; fi;
    if IO_Pickle(f,den) = IO_Error then return IO_Error; fi;
    return IO_OK;
  end );

IO_Unpicklers.RATF := 
  function( f )
    local num,den,one,poly;
    one := IO_Unpickle(f);
    if one = IO_Error then return IO_Error; fi;
    num := IO_Unpickle(f);
    if num = IO_Error then return IO_Error; fi;
    den := IO_Unpickle(f);
    if den = IO_Error then return IO_Error; fi;
    poly := RationalFunctionByExtRepNC( 
                   RationalFunctionsFamily(FamilyObj(one)),num,den);
    return poly;
  end;

InstallMethod( IO_Pickle, "for rational functions",
  [ IsFile, IsPolynomialFunction and IsPolynomialDefaultRep ],
  function( f, pol )
    local num,one;
    one := One(CoefficientsFamily(FamilyObj(pol)));
    num := ExtRepNumeratorRatFun(pol);
    if IO_Write(f,"POLF") = fail then return IO_Error; fi;
    if IO_Pickle(f,one) = IO_Error then return IO_Error; fi;
    if IO_Pickle(f,num) = IO_Error then return IO_Error; fi;
    return IO_OK;
  end );

IO_Unpicklers.POLF := 
  function( f )
    local num,one,poly;
    one := IO_Unpickle(f);
    if one = IO_Error then return IO_Error; fi;
    num := IO_Unpickle(f);
    if num = IO_Error then return IO_Error; fi;
    poly := PolynomialByExtRepNC( 
                   RationalFunctionsFamily(FamilyObj(one)),num);
    return poly;
  end;

# This is for compatibility only and will go eventually:
IO_Unpicklers.POLY :=
  function( f )
    local ext,one,poly;
    one := IO_Unpickle(f);
    if one = IO_Error then return IO_Error; fi;
    ext := IO_Unpickle(f);
    if ext = IO_Error then return IO_Error; fi;
    poly := PolynomialByExtRepNC( RationalFunctionsFamily(FamilyObj(one)),ext);
    IsUnivariatePolynomial(poly);   # to make it learn
    IsLaurentPolynomial(poly);      # to make it learn
    return poly;
  end;

InstallMethod( IO_Pickle, "for a univariate Laurent polynomial",
  [ IsFile, IsLaurentPolynomial and IsLaurentPolynomialDefaultRep ],
  function( f, pol )
  local cofs,one,ind;
    one := One(CoefficientsFamily(FamilyObj(pol)));
    cofs := CoefficientsOfLaurentPolynomial(pol);
    ind := IndeterminateNumberOfLaurentPolynomial(pol);
    if IO_Write(f,"UPOL") = fail then return IO_Error; fi;
    if IO_Pickle(f,one) = IO_Error then return IO_Error; fi;
    if IO_Pickle(f,cofs) = IO_Error then return IO_Error; fi;
    if IO_Pickle(f,ind) = IO_Error then return IO_Error; fi;
    return IO_OK;
  end );

IO_Unpicklers.UPOL :=
  function( f )
    local cofs,one,ind,poly;
    one := IO_Unpickle(f);
    if one = IO_Error then return IO_Error; fi;
    cofs := IO_Unpickle(f);
    if cofs = IO_Error then return IO_Error; fi;
    ind := IO_Unpickle(f);
    if ind = IO_Error then return IO_Error; fi;
    poly := LaurentPolynomialByCoefficients(FamilyObj(one),cofs[1],cofs[2],ind);
    return poly;
  end;

InstallMethod( IO_Pickle, "for a univariate rational function",
  [ IsFile, 
    IsUnivariateRationalFunction and IsUnivariateRationalFunctionDefaultRep ],
  function( f, pol )
    local cofs,one,ind;
    one := One(CoefficientsFamily(FamilyObj(pol)));
    cofs := CoefficientsOfUnivariateRationalFunction(pol);
    ind := IndeterminateNumberOfUnivariateRationalFunction(pol);
    if IO_Write(f,"URFU") = fail then return IO_Error; fi;
    if IO_Pickle(f,one) = IO_Error then return IO_Error; fi;
    if IO_Pickle(f,cofs) = IO_Error then return IO_Error; fi;
    if IO_Pickle(f,ind) = IO_Error then return IO_Error; fi;
    return IO_OK;
  end );

IO_Unpicklers.URFU :=
  function( f )
    local cofs,one,ind,poly;
    one := IO_Unpickle(f);
    if one = IO_Error then return IO_Error; fi;
    cofs := IO_Unpickle(f);
    if cofs = IO_Error then return IO_Error; fi;
    ind := IO_Unpickle(f);
    if ind = IO_Error then return IO_Error; fi;
    poly := UnivariateRationalFunctionByCoefficients(
               FamilyObj(one),cofs[1],cofs[2],cofs[3],ind);
    return poly;
  end;

InstallMethod( IO_Pickle, "for a straight line program",
  [ IsFile, IsStraightLineProgram ],
  function( f, s )
    if IO_Write(f,"GSLP") = fail then return IO_Error; fi;
    if IO_Pickle(f,LinesOfStraightLineProgram(s)) = IO_Error then 
        return IO_Error;
    fi;
    if IO_Pickle(f,NrInputsOfStraightLineProgram(s)) = IO_Error then
        return IO_Error;
    fi;
    return IO_OK;
  end);

IO_Unpicklers.GSLP :=
  function( f )
    local l,n,s;
    l := IO_Unpickle(f);
    if l = IO_Error then return IO_Error; fi;
    n := IO_Unpickle(f);
    if l = IO_Error then return IO_Error; fi;
    s := StraightLineProgramNC(l,n);
    return s;
  end;

InstallMethod( IO_Pickle, "for the global random source",
  [ IsFile, IsRandomSource and IsGlobalRandomSource ],
  function( f, r )
    local s;
    if IO_Write(f,"RSGL") = fail then return IO_Error; fi;
    s := State(r);
    if IO_Pickle(f,s) = IO_Error then return IO_Error; fi;
    return IO_OK;
  end );

IO_Unpicklers.RSGL :=
  function( f )
    local s;
    s := IO_Unpickle(f);
    if s = IO_Error then return IO_Error; fi;
    return RandomSource(IsGlobalRandomSource,s);
  end;

InstallMethod( IO_Pickle, "for a GAP random source",
  [ IsFile, IsRandomSource and IsGAPRandomSource ],
  function( f, r )
    local s;
    if IO_Write(f,"RSGA") = fail then return IO_Error; fi;
    s := State(r);
    if IO_Pickle(f,s) = IO_Error then return IO_Error; fi;
    return IO_OK;
  end );

IO_Unpicklers.RSGA :=
  function( f )
    local s;
    s := IO_Unpickle(f);
    if s = IO_Error then return IO_Error; fi;
    return RandomSource(IsGAPRandomSource,s);
  end;

InstallMethod( IO_Pickle, "for a Mersenne twister random source",
  [ IsFile, IsRandomSource and IsMersenneTwister ],
  function( f, r )
    local s;
    if IO_Write(f,"RSMT") = fail then return IO_Error; fi;
    s := State(r);
    if IO_Pickle(f,s) = IO_Error then return IO_Error; fi;
    return IO_OK;
  end );

IO_Unpicklers.RSMT :=
  function( f )
    local s;
    s := IO_Unpickle(f);
    if s = IO_Error then return IO_Error; fi;
    return RandomSource(IsMersenneTwister,s);
  end;

InstallMethod( IO_Pickle, "for an operation",
  [ IsFile, IsOperation and IsFunction ],
  function(f,o)
    if IO_Write(f,"OPER") = fail then return IO_Error; fi;
    if IO_Pickle(f,NAME_FUNC(o)) = IO_Error then return IO_Error; fi;
    return IO_OK;
  end );

IO_FuncToUnpickle := fail;
IO_Unpicklers.OPER :=
  function( f )
    local i,s;
    s := IO_Unpickle(f); if s = IO_Error then return IO_Error; fi;
    s := Concatenation( "IO_FuncToUnpickle := ",s,";" );
    i := InputTextString(s);
    Read(i);
    if not(IsBound(IO_FuncToUnpickle)) then return IO_Error; fi;
    s := IO_FuncToUnpickle;
    Unbind(IO_FuncToUnpickle);
    return s;
  end;

InstallMethod( IO_Pickle, "for a function",
  [ IsFile, IsFunction ],
  function( f, fu )
    local o,s;
    s := NAME_FUNC(fu);
    if not(IsBoundGlobal(s)) or not(IsIdenticalObj(ValueGlobal(s),fu)) then
        s := "";
        o := OutputTextString(s,true);
        PrintTo(o,fu);
        CloseStream(o);
        if PositionSublist(s,"<<compiled code>>") <> fail then
            Print("#Error: Cannot pickle compiled function.\n");
            return IO_Error;
        fi;
    fi;
    if IO_Write(f,"FUNC") = fail then return IO_Error; fi;
    if IO_Pickle(f,s) = IO_Error then return IO_Error; fi;
    return IO_OK;
  end );

IO_Unpicklers.FUNC :=
  function( f )
    local i,s;
    s := IO_Unpickle(f); if s = IO_Error then return IO_Error; fi;
    s := Concatenation( "IO_FuncToUnpickle := ",s,";" );
    i := InputTextString(s);
    Read(i);
    if not(IsBound(IO_FuncToUnpickle)) then return IO_Error; fi;
    s := IO_FuncToUnpickle;
    Unbind(IO_FuncToUnpickle);
    return s;
  end;
Unbind(IO_FuncToUnpickle);

InstallMethod( IO_Pickle, "for a weak pointer object",
  [ IsFile, IsWeakPointerObject and IsList ],
  function( f, l )
    local count,i,nr;
    nr := IO_AddToPickled(l);
    if nr = false then   # not yet known
        # Here we have to do something
        if IO_Write(f,"WPOB") = fail then
            IO_FinalizePickled();
            return IO_Error;
        fi;
        if IO_WriteSmallInt(f,Length(l)) = IO_Error then
            IO_FinalizePickled();
            return IO_Error;
        fi;
        count := 0;
        i := 1;
        while i <= Length(l) do
            if not(IsBound(l[i])) then
                count := count + 1;
            else
                if count > 0 then
                    if IO_Write(f,"GAPL") = fail then
                        IO_FinalizePickled();
                        return IO_Error;
                    fi;
                    if IO_WriteSmallInt(f,count) = IO_Error then
                        IO_FinalizePickled();
                        return IO_Error;
                    fi;
                    count := 0;
                fi;
                if IO_Pickle(f,l[i]) = IO_Error then
                    IO_FinalizePickled();
                    return IO_Error;
                fi;
            fi;
            i := i + 1;
        od;
        # Note that the last entry is always bound!
        IO_FinalizePickled();
        return IO_OK;
    else
        if IO_Write(f,"SREF") = IO_Error then 
            IO_FinalizePickled();
            return IO_Error;
        fi;
        if IO_WriteSmallInt(f,nr) = IO_Error then
            IO_FinalizePickled();
            return IO_Error;
        fi;
        IO_FinalizePickled();
        return IO_OK;
    fi;
  end );

IO_Unpicklers.WPOB := 
  function( f )
    local i,l,len,ob;
    len := IO_ReadSmallInt(f);
    if len = IO_Error then return IO_Error; fi;
    l := WeakPointerObj( [] );
    if len > 0 then
        SetElmWPObj(l,len,0);
    fi;
    IO_AddToUnpickled(l);
    i := 1;
    while i <= len do
        ob := IO_Unpickle(f);
        if ob = IO_Error then
            IO_FinalizeUnpickled();
            return IO_Error;
        fi;
        # IO_OK or IO_Nothing cannot happen!
        if IO_Result(ob) then
            if ob!.val = "Gap" then   # this is a Gap
                i := i + ob!.nr;
            fi;
        else
            SetElmWPObj(l,i,ob);
            i := i + 1;
        fi;
    od;  # i is already incremented
    IO_FinalizeUnpickled();
    return l;
  end;

InstallMethod( IO_Pickle, "for a permutation group",
  [ IsFile, IsPermGroup ],
  function( f, g )
    if IO_Write(f,"PRMG") = fail then return IO_Error; fi;
    if IO_Pickle(f,GeneratorsOfGroup(g)) = IO_Error then return IO_Error; fi;
    if HasSize(g) then
        if IO_Pickle(f,Size(g)) = IO_Error then return IO_Error; fi;
    else
        if IO_Pickle(f,fail) = IO_Error then return IO_Error; fi;
    fi;
    if HasStabChainImmutable(g) then
        if IO_Pickle(f,BaseStabChain(StabChainImmutable(g))) = IO_Error then
            return IO_Error;
        fi;
    elif HasStabChainMutable(g) then
        if IO_Pickle(f,BaseStabChain(StabChainMutable(g))) = IO_Error then
            return IO_Error;
        fi;
    else
        if IO_Pickle(f,fail) = IO_Error then return IO_Error; fi;
    fi;
    return IO_OK;
  end );

IO_Unpicklers.PRMG := 
  function(f)
    local base,g,gens,size;
    gens := IO_Unpickle(f); if gens = IO_Error then return IO_Error; fi;
    g := GroupWithGenerators(gens);
    size := IO_Unpickle(f); if size = IO_Error then return IO_Error; fi;
    if size <> fail then SetSize(g,size); fi;
    base := IO_Unpickle(f); if base = IO_Error then return IO_Error; fi;
    if base <> fail then
        StabChain(g,rec(knownBase := base));
    fi;
    return g;
  end;

InstallMethod( IO_Pickle, "for a matrix group",
  [ IsFile, IsMatrixGroup ],
  function( f, g )
    return IO_GenericObjectPickler(f,"MATG",[GeneratorsOfGroup(g)],g,
               [Name,Size,DimensionOfMatrixGroup,FieldOfMatrixGroup],[],[]);
  end );

IO_Unpicklers.MATG := 
  function(f)
    local g,gens;
    gens := IO_Unpickle(f); if gens = IO_Error then return IO_Error; fi;
    g := GroupWithGenerators(gens);
    return
    IO_GenericObjectUnpickler(f,g,
                 [Name,Size,DimensionOfMatrixGroup,FieldOfMatrixGroup],[]);
    return g;
  end;

InstallMethod( IO_Pickle, "for a finite field",
  [ IsFile, IsField and IsFinite ],
  function(f,F)
    return IO_GenericObjectPickler(f,"FFIE",
              [Characteristic(F),DegreeOverPrimeField(F)],F,[],[],[]);
  end );

IO_Unpicklers.FFIE :=
  function(f)
    local d,p;
    p := IO_Unpickle(f); if p = IO_Error then return IO_Error; fi;
    d := IO_Unpickle(f); if d = IO_Error then return IO_Error; fi;
    if IO_Unpickle(f) <> fail then return IO_Error; fi;
    return GF(p,d);
  end;

##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
