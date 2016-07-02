# This file is only here temporarily until
# its functionality has been published as part
# of the profiling package.

LoadPackage("profiling");

CoverToJson := function(data, outfile)
    local outstream, lineinfo, prev, file, lines;

    outfile := USER_HOME_EXPAND(outfile);
    outstream := IO_File(outfile, "w");

    if not(IsRecord(data)) then
      data := ReadLineByLineProfile(data);
    fi;

    lineinfo := function(lineno, stat)
        if stat[1] > 0 then
            if stat[2] > 0 then
                return STRINGIFY("\"", lineno, "\": \"1\"");
            else
                return STRINGIFY("\"", lineno, "\": \"0\"");
            fi;
        fi;
        return "";
    end;

    IO_Write(outstream, "{ \"coverage\": {\n");
    prev := false;

    for file in data.line_info do
        if file[1] <> "stream" then
            if prev then
                IO_Write(outstream, ",\n");
            fi;
            IO_Write(outstream, Concatenation("\"", file[1], "\": {\n" ));
            lines := List([1..Length(file[2])], n -> lineinfo(n, file[2][n]));
            lines := Filtered(lines, l -> Length(l) > 0);
            IO_Write(outstream, JoinStringsWithSeparator(lines, ",\n"));
            IO_Write(outstream, "}\n");
            prev := true;
        fi;
    od;
    IO_Write(outstream, "} }");
    IO_Close(outstream);
end;

