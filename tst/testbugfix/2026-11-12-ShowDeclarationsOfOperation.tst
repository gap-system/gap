# ShowDeclarationsOfOperation used the plural "arguments" for one argument
gap> op1 := NewOperation("op1", [IsInt]);;
gap> ShowDeclarationsOfOperation(op1);
Available declarations for operation <Operation "op1">:
  1: stream:1 with 1 argument, and filters [ IsInt ]
gap> op2 := NewOperation("op2", [IsInt, IsString]);;
gap> ShowDeclarationsOfOperation(op2);
Available declarations for operation <Operation "op2">:
  1: stream:1 with 2 arguments, and filters [ IsInt, IsString ]
