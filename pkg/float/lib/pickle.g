# picklers

if IsBound(MPFR_INT) then
InstallMethod( IO_Pickle, "for a MPFR float", [ IsFile, IsMPFRFloat ],
  function( f, v )
    if IO_Write(f,"MPFR")=fail or IO_Pickle(f,ExtRepOfObj(v))<>IO_OK then
        return IO_Error;
    fi;
    return IO_OK;
end);

IO_Unpicklers.MPFR :=
  function( f )
    local r;
    r := IO_Unpickle(f);
    if not IsList(r) then return IO_Error; fi;
    return NewFloat(IsMPFRFloat,r);
end;
fi;

if IsBound(MPFI_INT) then
InstallMethod( IO_Pickle, "for a MPFI float", [ IsFile, IsMPFIFloat ],
  function( f, v )
    if IO_Write(f,"MPFI")=fail or IO_Pickle(f,ExtRepOfObj(v))<>IO_OK then
        return IO_Error;
    fi;
    return IO_OK;
end);

IO_Unpicklers.MPFI := function( f )
    local r;
    r := IO_Unpickle(f);
    if not IsList(r) then return IO_Error; fi;
    return NewFloat(IsMPFIFloat,r);
end;
fi;

if IsBound(MPC_INT) then
InstallMethod( IO_Pickle, "for a MPC float", [ IsFile, IsMPCFloat ],
  function( f, v )
    if IO_Write(f,"MPCX")=fail or IO_Pickle(f,ExtRepOfObj(v))<>IO_OK then
        return IO_Error;
    fi;
    return IO_OK;
end);

IO_Unpicklers.MPC := function( f )
    local r;
    r := IO_Unpickle(f);
    if not IsList(r) then return IO_Error; fi;
    return NewFloat(IsMPCFloat,r);
end;
fi;

if IsBound(CXSC_INT) then
InstallMethod( IO_Pickle, "for a CXSC float", [ IsFile, IsCXSCReal ],
  function( f, v )
    if IO_Write(f,"XSCR")=fail or IO_Pickle(f,ExtRepOfObj(v))<>IO_OK then
        return IO_Error;
    fi;
    return IO_OK;
end);

IO_Unpicklers.XSCR := function( f )
    local r;
    r := IO_Unpickle(f);
    if not IsList(r) then return IO_Error; fi;
    return NewFloat(IsCXSCReal,r);
end;

InstallMethod( IO_Pickle, "for a CXSC float", [ IsFile, IsCXSCInterval ],
  function( f, v )
    if IO_Write(f,"XSCI")=fail or IO_Pickle(f,ExtRepOfObj(v))<>IO_OK then
        return IO_Error;
    fi;
    return IO_OK;
end);

IO_Unpicklers.XSCI := function( f )
    local r;
    r := IO_Unpickle(f);
    if not IsList(r) then return IO_Error; fi;
    return NewFloat(IsCXSCInterval,r);
end;

InstallMethod( IO_Pickle, "for a CXSC float", [ IsFile, IsCXSCComplex ],
  function( f, v )
    if IO_Write(f,"XSCC")=fail or IO_Pickle(f,ExtRepOfObj(v))<>IO_OK then
        return IO_Error;
    fi;
    return IO_OK;
end);

IO_Unpicklers.XSCC := function( f )
    local r;
    r := IO_Unpickle(f);
    if not IsList(r) then return IO_Error; fi;
    return NewFloat(IsCXSCComplex,r);
end;

InstallMethod( IO_Pickle, "for a CXSC float", [ IsFile, IsCXSCBox ],
  function( f, v )
    if IO_Write(f,"XSCB")=fail or IO_Pickle(f,ExtRepOfObj(v))<>IO_OK then
        return IO_Error;
    fi;
    return IO_OK;
end);

IO_Unpicklers.XSCB := function( f )
    local r;
    r := IO_Unpickle(f);
    if not IsList(r) then return IO_Error; fi;
    return NewFloat(IsCXSCBox,r);
end;
fi;
