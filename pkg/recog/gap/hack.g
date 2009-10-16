# Here I collect some hacks that are necessary with the current GAP,
# they should be removed some day:

InstallMethod( ExtractSubMatrix, "hack: for a compressed GF2 matrix",
  [ IsGF2MatrixRep, IsList, IsList ],
  function( m, poss1, poss2 )
    local i,n;
    n := [];
    for i in poss1 do
        Add(n,ShallowCopy(m[i]{poss2}));
    od;
    ConvertToMatrixRep(n,2);
    return n;
  end );

InstallMethod( ExtractSubMatrix, "hack: for a compressed 8bit matrix",
  [ Is8BitMatrixRep, IsList, IsList ],
  function( m, poss1, poss2 )
    local i,n;
    n := [];
    for i in poss1 do
        Add(n,ShallowCopy(m[i]{poss2}));
    od;
    ConvertToMatrixRep(n,Q_VEC8BIT(m[1]));
    return n;
  end );

InstallMethod( ExtractSubMatrix, "hack: for lists of compressed vectors",
  [ IsList, IsList, IsList ],
  function( m, poss1, poss2 )
    local i,n;
    n := [];
    for i in poss1 do
        Add(n,ShallowCopy(m[i]{poss2}));
    od;
    if IsFFE(m[1][1]) then
        ConvertToMatrixRep(n);
    fi;
    return n;
  end );

InstallMethod( MutableCopyMat, "for a compressed GF2 matrix",
  [ IsList and IsGF2MatrixRep ],
  function(m)
    local n;
    n := List(m,ShallowCopy);
    ConvertToMatrixRep(n,2);
    return n;
  end );

InstallMethod( MutableCopyMat, "for a compressed 8bit matrix",
  [ IsList and Is8BitMatrixRep ],
  function(m)
    local n;
    n := List(m,ShallowCopy);
    ConvertToMatrixRep(n,Q_VEC8BIT(m[1]));
    return n;
  end );

