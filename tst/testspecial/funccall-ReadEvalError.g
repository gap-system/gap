Read(InputTextString("quit;")); # trigger ReadEvalError in EvalOrExecCall
1+1;

READ_STREAM(InputTextString("quit;")); # trigger ReadEvalError in IntrFuncCallEnd
1+1;
