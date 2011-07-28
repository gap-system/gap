# picklers

InstallMethod( IO_Pickle, "for a complex number",
  [ IsFile, IS_COMPLEX ],
  function( f, v )
    if IO_Write(f,"CPLX")=fail or IO_Pickle(f,RealPart(v))<>IO_OK or IO_Pickle(f,ImaginaryPart(v))<>IO_OK then
        return IO_Error;
    fi;
    return IO_OK;
end);

IO_Unpicklers.CPLX :=
  function( f )
    local r, i;
    r := IO_Unpickle(f);
    if not IsFloat(r) then return IO_Error; fi;
    i := IO_Unpickle(f);
    if not IsFloat(i) then return IO_Error; fi;
    return Complex(r,i);
end;
