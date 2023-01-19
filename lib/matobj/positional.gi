#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

############################################################################
#
# Operations for positional matrix objects
#
############################################################################

InstallMethod( BaseDomain, [ IsPositionalVectorRep ],
  function( v )
    return v![VEC_BD_POS];
  end );

InstallMethod( Length, [ IsPositionalVectorRep ],
  function( v )
    return Length(v![VEC_DATA_POS]); # FIXME: assumptions
  end );


InstallMethod( ShallowCopy, [ IsPositionalVectorRep ],
  function( v )
    local i, res;
    res := List([1..LEN_POSOBJ(v)], i -> v![i]);
    res![VEC_DATA_POS] := ShallowCopy(v![VEC_DATA_POS]);
    res := Objectify(TypeObj(v), res);
# FIXME: actually the "generic" ShallowCopy method is wrong, as it
# e.g. doesn't reset IsZero etc -- if we want to keep this, we need
# something like a helper to produce a "basic" typeobj for the
# given basedomain.


    # 'ShallowCopy' MUST return a mutable object if such an object exists at all!
    if not IsMutable(v) then
      SetFilterObj(res, IsMutable);
    fi;
    return res;
  end );

# StructuralCopy works automatically

InstallMethod( PostMakeImmutable, [ IsPositionalVectorRep ],
  function( v )
    MakeImmutable( v![VEC_DATA_POS] );
  end );


############################################################################
#
# Operations for positional matrix objects
#
############################################################################

InstallMethod( BaseDomain, [ IsPositionalMatrixRep ],
  function( m )
    return m![MAT_BD_POS];
  end );

InstallMethod( NumberRows, [ IsPositionalMatrixRep ],
  function( m )
    return Length(m![MAT_DATA_POS]); # FIXME: this makes assumptions...
  end );

InstallMethod( NumberColumns, [ IsPositionalMatrixRep ],
  function( m )
    return m![MAT_NCOLS_POS];
  end );

InstallMethod( ShallowCopy, [ IsPositionalMatrixRep ],
  function( m )
    local res;
    res := List([1..LEN_POSOBJ(m)], i -> m![i]);
    res![MAT_DATA_POS] := ShallowCopy(m![MAT_DATA_POS]);
    res := Objectify(TypeObj(m), res);
# FIXME: actually the "generic" ShallowCopy method is wrong, as it
# e.g. doesn't reset IsZero etc -- if we want to keep this, we need
# something like a helper to produce a "basic" typeobj for the
# given basedomain.

    # 'ShallowCopy' MUST return a mutable object if such an object exists at all!
    if not IsMutable(m) then
      SetFilterObj(res, IsMutable);
    fi;
    return res;
  end );

InstallMethod( PostMakeImmutable, [ IsPositionalMatrixRep ],
  function( m )
    MakeImmutable( m![MAT_DATA_POS] );
  end );
