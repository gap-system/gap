gap> f := function()
> local a,b,c;
> if IsBound(a) then Print("1"); fi;
> a := 2;
> if not IsBound(a) then Print("2"); fi;
> if IsBound(b) then Print("3"); fi;
> Unbind(a);
> Unbind(b);
> if IsBound(a) then Print("4"); fi;
> if IsBound(b) then Print("4"); fi;
> end;;
gap> f();
gap> Print(f,"\n");
function (  )
    local a, b, c;
    if IsBound( a ) then
        Print( "1" );
    fi;
    a := 2;
    if not IsBound( a ) then
        Print( "2" );
    fi;
    if IsBound( b ) then
        Print( "3" );
    fi;
    Unbind( a );
    Unbind( b );
    if IsBound( a ) then
        Print( "4" );
    fi;
    if IsBound( b ) then
        Print( "4" );
    fi;
    return;
end

# Now nested
gap> g := function()
> local a,b,f;
> f := function()
> if IsBound(a) then Print("1"); fi;
> a := 2;
> if not IsBound(a) then Print("2"); fi;
> if IsBound(b) then Print("3"); fi;
> Unbind(a);
> Unbind(b);
> if IsBound(a) then Print("4"); fi;
> if IsBound(b) then Print("4"); fi;
> end;
> return f;
> end;;
gap> func := g();;
gap> Print(g, "\n");
function (  )
    local a, b, f;
    f := function (  )
          if IsBound( a ) then
              Print( "1" );
          fi;
          a := 2;
          if not IsBound( a ) then
              Print( "2" );
          fi;
          if IsBound( b ) then
              Print( "3" );
          fi;
          Unbind( a );
          Unbind( b );
          if IsBound( a ) then
              Print( "4" );
          fi;
          if IsBound( b ) then
              Print( "4" );
          fi;
          return;
      end;
    return f;
end
gap> Print(func, "\n");
function (  )
    if IsBound( a ) then
        Print( "1" );
    fi;
    a := 2;
    if not IsBound( a ) then
        Print( "2" );
    fi;
    if IsBound( b ) then
        Print( "3" );
    fi;
    Unbind( a );
    Unbind( b );
    if IsBound( a ) then
        Print( "4" );
    fi;
    if IsBound( b ) then
        Print( "4" );
    fi;
    return;
end
