#GAPOPTS -T
# Interrupt ReadLine while the reader's capture streams are still installed,
# outside the TRY_IF_NO_ERROR that handles ordinary statement errors.
DeclareCategory("IsInterruptReadTestStream", IsInputTextStream);;
streamType := NewType(StreamsFamily,
    IsInterruptReadTestStream and IsComponentObjectRep);;
savedErrorOutput := ERROR_OUTPUT;;
sawCapture := false;;
timedOut := false;;
callbacks := 0;;
trigger := InputOutputLocalProcess(DirectoryCurrent(),
    Filename(DirectoriesSystemPrograms(), "sh"),
    ["-c", "read ready; kill -INT $PPID"]);;
InstallMethod(PositionStream, [IsInterruptReadTestStream], s -> 0);;
InstallMethod(SeekPositionStream, [IsInterruptReadTestStream, IsInt],
    function(s, pos) return true; end);;
InstallMethod(ReadLine, [IsInterruptReadTestStream], function(s)
    local deadline;
    sawCapture := not IsIdenticalObj(ERROR_OUTPUT, savedErrorOutput);
    WriteLine(trigger, "ready");
    deadline := Runtime() + 5000;
    while Runtime() < deadline do od;
    timedOut := true;
    return fail;
end);;
stream := Objectify(streamType, rec());;
caught := CALL_WITH_CATCH(READ_EVAL_COMMANDS,
    [stream, rec(captureErrors := true, captureOutput := true),
     function(r) callbacks := callbacks + 1; return false; end]);;
CloseStream(trigger);
Print("interrupted while capturing: ",
      not caught[1] and sawCapture and not timedOut and callbacks = 0, "\n");
Print("error stream restored: ",
      IsIdenticalObj(ERROR_OUTPUT, savedErrorOutput), "\n");
results := [];;
READ_EVAL_COMMANDS(InputTextString("6*7;"), rec(),
    function(r) Add(results, r); return true; end);;
Print("reader recovered: ", results[1].value = 42, "\n");
