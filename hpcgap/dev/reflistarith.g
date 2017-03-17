FirstUnbound := function(list)
    local i;
    for i in [1..Length(list)] do
        if IsBound(list[i]) then
            return list[i];
        fi;
    od;
    Assert(1,Length(list) = 0);
    Error("Empty list has no first unbound entry");
end;

NestingDepth := function(list)
    if not IsGeneralizedRowVector(list) then
        return 0;
    else
        if Length(list) = 0 then
            return 1;
        fi;
        return 1 + NestingDepth( FirstUnbound( list ));
    fi;
end;

ImmutabilityLevelInner := function( list )
    if not IsList( list) or Length(list) = 0 then
        return 0;
    elif not IsMutable( list ) then
        return NestingDepth(list);
    else
        return  ImmutabilityLevelInner( FirstUnbound( list) );
    fi;
end;

ImmutabilityLevel := function( list )
    if not IsMutable( list ) then
        return infinity;
    else
        return ImmutabilityLevelInner( list );
    fi;
end;

MultiplicativeNestingDepth := function(list)
    if not IsMultiplicativeGeneralizedRowVector(list) then
        return 0;
    else
        if Length(list) = 0 then
            return 1;
        fi;
        return 1 + MultiplicativeNestingDepth( FirstUnbound( list ) );
    fi;
end;


CompressionStatus := function(obj)
    local n;
    n := NestingDepth(obj);
    if n < 1 then
        return [0,0];
    elif n = 1 then 
        if IsGF2VectorRep(obj) then
            return [1,2];
        elif Is8BitVectorRep(obj) then
            return [1,Q_VEC8BIT(obj)];
        else
            return [0,0];
        fi;
    elif n = 2 then 
        if IsGF2MatrixRep(obj) then
            return [2,2]; 
        elif Is8BitMatrixRep(obj) then
            return [2,Q_VEC8BIT(obj[1])];
        fi;
    fi;
    return CompressionStatus(FirstUnbound(obj));
end;

CorrectedMutabilityCopy := function( obj, mutlevel )
    local n, c, l, i;
    n := NestingDepth(obj);
    c := [];
    if n > mutlevel then
        l := Length(obj);
        for i in [1..l] do
            if IsBound(obj[i]) then
                c[i] := CorrectedMutabilityCopy( obj[i], mutlevel);
            fi;
        od;
    else
       c := Immutable( obj );
   fi;
   return c;
end;

CorrectedCompressionCopy := function( obj, complevel, field)
    local n, l, i, c;
    n := NestingDepth(obj);
    if n = 0 then 
        return obj;
    elif n = 1 then
        l := Length(obj);
        if complevel = 1 then
            c := StructuralCopy(obj);
            ConvertToVectorRep(c, field);
            return c;
        else
            Assert(1, complevel = 0);
        fi;
    elif n = 2 then
        l := Length(obj);
        if complevel = 2 then
            c:= StructuralCopy(obj);
            ConvertToMatrixRep(c, field);
            return c;
            
        fi;
    fi;
    
    c := [];
    for i in [1..l] do
        if IsBound(obj[i]) then
            c[i] := CorrectedCompressionCopy( obj[i], complevel, field);
        fi;
    od;
    if not IsMutable(obj) then
        MakeImmutable(c);
    fi;
    return c;
end;
            

AdditiveOpInner := function(onscalars)
    local foo;
    foo := function( left, right)
        local i,l, sum, cs1, cs2, cs, nl, nr;
        nl := NestingDepth(left);
        nr := NestingDepth(right);
        if nl = 0 and nr = 0 then
            return onscalars(left, right);
        elif nr > nl then
            l := Length(right);
            sum := [];
            for i in [1..l] do
                if IsBound(right[i]) then
                    sum[i] := foo(left, right[i]);
                fi;
            od;
            return sum;
        elif nl > nr then
            l := Length(left);
            sum := [];
            for i in [1..l] do
                if IsBound(left[i]) then
                    sum[i] := foo(left[i],right);
                fi;
            od;
            return sum;
        else
            l := Maximum( Length(left), Length(right));
            sum := [];
            for i in [1..l] do
                if IsBound( left[i] ) then
                    if IsBound( right[i] ) then
                        sum[i] := foo(left[i],  right[i]);
                    else
                        sum[i] := left[i];
                    fi;
                elif IsBound( right[i] ) then
                    sum[i] := right[i];
                fi;
            od;
            return sum;
        fi;
    end;
    return foo;
end;


AdditiveOp := onscalars ->
              function(left, right)
    local sum, cs1, cs2, cs;
    sum := AdditiveOpInner(onscalars)(left, right);
    cs1 := CompressionStatus(left);
    cs2 := CompressionStatus(right);
    if  cs1[2] = cs2[2] then
        cs := [Minimum(cs1[1], cs2[1]), cs1[2]];
    else
        cs := [0,0];
    fi;
    sum :=  CorrectedMutabilityCopy( sum, Minimum(ImmutabilityLevel( left),
                    ImmutabilityLevel(right )));
    return CorrectedCompressionCopy(sum, cs[1], cs[2]);
end;

    
TestSum := AdditiveOp(\+);

TestAInv := function(x)
    local ai, l, i, cs;
    if not IsGeneralizedRowVector(x) then
        return -x;
    fi;
    ai := [];
    l := Length(x);
    for i in [1..l] do
        if IsBound(x[i]) then
            ai[i] := TestAInv(x[i]);
        fi;
    od;
    ai := CorrectedMutabilityCopy(ai, ImmutabilityLevel(x));
    cs := CompressionStatus(x);
    ai := CorrectedCompressionCopy(ai, cs[1], cs[2]);
    return ai;
end;
    
TestDiff := function(left, right)     
    return TestSum(left, TestAInv(right));
end;

MultiplicativeOpInner := function( basemult, adder)
    local foo;
    foo := function(left, right )
        local nl, nr, l, i, total, result;
        nl := MultiplicativeNestingDepth(left);
        nr := MultiplicativeNestingDepth(right);
        
        
        if nl = 0 and nr = 0 then
            
            # scalar x scalar
            
            return basemult(left, right);
        elif nl mod 2 = 1 and (nr mod 2 = 1 or nr > nl) then
            
            # vector x vector or vector x matrix 
            
            l := Maximum(Length(left), Length(right));
            for i in [1..l] do
                if IsBound(left[i])  and IsBound(right[i]) then
                    if not IsBound(total) then
                        total := foo(left[i],right[i]);
                    else
                        total := adder(total, foo(left[i],right[i]));
                    fi;
                fi;
            od;
            if not IsBound(total) then
                Error("Inner product of two lists has no summands");
            fi;
            return total;
        elif nl >= nr  then
            
            # matrix x anything
            
            l := Length(left);
            result := [];
            for i in [1..l] do
                if IsBound(left[i]) then
                    result[i] := foo(left[i],right);
                fi;
            od;
            return result;
        elif nl mod 2 = 0 and nr > nl then
            
            # scalat * vector or matrix
            
            l := Length(right);
            result := [];
            for i in [1..l] do
                result[i] := foo(left, right[i]);
            od;
            return result;
        else 
            Error("impossible fallthrough");
        fi;
    end;
    return foo;
end;


                        
MultiplicativeOp := function( basemult, adder)
    return function(left, right)
        local prod, cs1, cs2, cs;
        prod := MultiplicativeOpInner(basemult, adder) (left, right);
        
        cs1 := CompressionStatus(left);
        cs2 := CompressionStatus(right);
        if cs1[2] = cs2[2] then
            cs := [Minimum(cs1[1], cs2[1]), cs1[2]];
        else
            cs := [0,0];
        fi;
        prod :=  CorrectedMutabilityCopy( prod, Minimum(ImmutabilityLevel( left),
                        ImmutabilityLevel(right )));
        return CorrectedCompressionCopy(prod, cs[1], cs[2]);
    end;
end;
        
TestMult := MultiplicativeOp( \*, TestSum);

                            
             