Katsura:= function( F, n )
    
    local   R,  vars,  x1,  x2,  x3,  x4,  x5,  x6,  x7,  x8,  pols,  
            I,  x9,  x10;
    
    # From Fauge're's website `http://calfor.lip6.fr/~jcf/Benchs/index.html'
    
    if n= 7 then
        
        R:= PolynomialRing( F, ["x1","x2","x3","x4","x5","x6","x7","x8"]);
        vars:= IndeterminatesOfPolynomialRing( R );
        x1:= vars[1];
        x2:= vars[2];
        x3:= vars[3];
        x4:= vars[4];
        x5:= vars[5];
        x6:= vars[6];
        x7:= vars[7];
        x8:= vars[8];
        
        pols:= [ -x1+2*x8^2+2*x7^2+2*x6^2+2*x5^2+2*x4^2+2*x3^2+2*x2^2+x1^2,
                 -x2+2*x8*x7+2*x7*x6+2*x6*x5+2*x5*x4+2*x4*x3+2*x3*x2+2*x2*x1,
                 -x3+2*x8*x6+2*x7*x5+2*x6*x4+2*x5*x3+2*x4*x2+2*x3*x1+x2^2,
                 -x4+2*x8*x5+2*x7*x4+2*x6*x3+2*x5*x2+2*x4*x1+2*x3*x2,
                 -x5+2*x8*x4+2*x7*x3+2*x6*x2+2*x5*x1+2*x4*x2+x3^2,
                 -x6+2*x8*x3+2*x7*x2+2*x6*x1+2*x5*x2+2*x4*x3,
                 -x7+2*x8*x2+2*x7*x1+2*x6*x2+2*x5*x3+x4^2,
                 -1+2*x8+2*x7+2*x6+2*x5+2*x4+2*x3+2*x2+x1];
        
        I:= Ideal( R, pols );
        
        return [R,I];
    fi;
    
    if n = 8 then 
        

      R:= PolynomialRing( F, ["x1","x2","x3","x4","x5","x6","x7","x8","x9"]);
      vars:= IndeterminatesOfPolynomialRing( R );
      x1:= vars[1];
      x2:= vars[2];
      x3:= vars[3];
      x4:= vars[4];
      x5:= vars[5];
      x6:= vars[6];
      x7:= vars[7];
      x8:= vars[8];
      x9:= vars[9];
      
      pols:= [-x1+2*x9^2+2*x8^2+2*x7^2+2*x6^2+2*x5^2+2*x4^2+2*x3^2+2*x2^2+x1^2,
           -x2+2*x9*x8+2*x8*x7+2*x7*x6+2*x6*x5+2*x5*x4+2*x4*x3+2*x3*x2+2*x2*x1,
              -x3+2*x9*x7+2*x8*x6+2*x7*x5+2*x6*x4+2*x5*x3+2*x4*x2+2*x3*x1+x2^2,
              -x4+2*x9*x6+2*x8*x5+2*x7*x4+2*x6*x3+2*x5*x2+2*x4*x1+2*x3*x2,
              -x5+2*x9*x5+2*x8*x4+2*x7*x3+2*x6*x2+2*x5*x1+2*x4*x2+x3^2,
              -x6+2*x9*x4+2*x8*x3+2*x7*x2+2*x6*x1+2*x5*x2+2*x4*x3,
              -x7+2*x9*x3+2*x8*x2+2*x7*x1+2*x6*x2+2*x5*x3+x4^2,
              -x8+2*x9*x2+2*x8*x1+2*x7*x2+2*x6*x3+2*x5*x4,
              -1+2*x9+2*x8+2*x7+2*x6+2*x5+2*x4+2*x3+2*x2+x1];
      I:= Ideal( R, pols );
      
      return [R,I];
  fi;
  
  if n = 9 then 
      
      R:= PolynomialRing( F, 
                  ["x1","x2","x3","x4","x5","x6","x7","x8","x9","x10"]);
      vars:= IndeterminatesOfPolynomialRing( R );
      x1:= vars[1];
      x2:= vars[2];
      x3:= vars[3];
      x4:= vars[4];
      x5:= vars[5];
      x6:= vars[6];
      x7:= vars[7];
      x8:= vars[8];
      x9:= vars[9];
      x10:= vars[10];
      
      pols:=
    [-x1+2*x10^2+2*x9^2+2*x8^2+2*x7^2+2*x6^2+2*x5^2+2*x4^2+2*x3^2+2*x2^2+x1^2,
 -x2+2*x10*x9+2*x9*x8+2*x8*x7+2*x7*x6+2*x6*x5+2*x5*x4+2*x4*x3+2*x3*x2+2*x2*x1,
     -x3+2*x10*x8+2*x9*x7+2*x8*x6+2*x7*x5+2*x6*x4+2*x5*x3+2*x4*x2+2*x3*x1+x2^2,
     -x4+2*x10*x7+2*x9*x6+2*x8*x5+2*x7*x4+2*x6*x3+2*x5*x2+2*x4*x1+2*x3*x2,
     -x5+2*x10*x6+2*x9*x5+2*x8*x4+2*x7*x3+2*x6*x2+2*x5*x1+2*x4*x2+x3^2,
     -x6+2*x10*x5+2*x9*x4+2*x8*x3+2*x7*x2+2*x6*x1+2*x5*x2+2*x4*x3,
     -x7+2*x10*x4+2*x9*x3+2*x8*x2+2*x7*x1+2*x6*x2+2*x5*x3+x4^2,
     -x8+2*x10*x3+2*x9*x2+2*x8*x1+2*x7*x2+2*x6*x3+2*x5*x4,
     -x9+2*x10*x2+2*x9*x1+2*x8*x2+2*x7*x3+2*x6*x4+x5^2,
     -1+2*x10+2*x9+2*x8+2*x7+2*x6+2*x5+2*x4+2*x3+2*x2+x1];
      
      I:= Ideal( R, pols );
      
      return [R,I];
  fi;      
  
end;
