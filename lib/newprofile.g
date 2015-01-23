#############################################################################
##
#W  newprofile.g                   GAP Library                  Chris Jefferson
##
##
#Y  Copyright (C) 2014 The GAP Group
##
##  This file contains the gap frontend of profile.c in src.
##


#############################################################################
##
##
##  <#GAPDoc Label="ProfileLineByLine">
##  <ManSection>
##  <Func Name="ProfileLineByLine" Arg="filename,access,repeats"/>
##
##  <Description>
##  <Ref Func="ProfileLineByLine"/> begins GAP recording profiling
##  data to the file <A>filename</A>. <A>access</A> should be one of
##  "w" or "a", to denote if the file should be cleared before writing
##  ("w") or appended to ("a").
##  If <A>repeats</A> is false, GAP will only output each access to a
##  statement once. This makes the file useful for code coverage, but
##  less useful for profiling. If <A>repeats</A> is true, the created
##  file can get VERY large.
##  <P/>
##  Note that <A>repeats</A> is a global setting -- once a line access
##  has been outputted to any profiling file in a GAP session, then
##  it will not be outputted to any future call where <A>repeats</A>
##  is false.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ProfileLineByLine",function(name, access, repeats)
    
    if access <> "w" and access <> "a" then
        Error("access must be \"w\" or \"a\"");
    fi;
    
    return ACTIVATE_PROFILING(name, access, repeats);
end);

#############################################################################
##
##
##  <#GAPDoc Label="UnprofileLineByLine">
##  <ManSection>
##  <Func Name="UnprofileLineByLine" Arg=""/>
##
##  <Description>
##  Stops profiling which was previously started with
##  <Ref Func="ProfileLineByLine"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("UnprofileLineByLine",function()
    return DEACTIVATE_PROFILING();
end);

#############################################################################
##
##
##  <#GAPDoc Label="ActivateProfileColour">
##  <ManSection>
##  <Func Name="ActivateProfileColour" Arg=""/>
##
##  <Description>
##  Called with argument <K>true</K>,
##  <Ref Func="ActivateProfileColour"/>
##  makes GAP colour functions when printing them to show which lines
##  have been executed while profiling was active via
##  <Ref Func="ProfileLineByLine" /> at any time during this GAP session.
##  Passing <K>false</K> disables this behaviour.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
BIND_GLOBAL("ActivateProfileColour",function(b)
    return ACTIVATE_COLOR_PROFILING(b);
end);

#############################################################################
##
##
##  <#GAPDoc Label="ReadLineByLineProfile">
##  <ManSection>
##  <Func Name="ReadLineByLineProfile" Arg="filename"/>
##
##  <Description>
##  <Ref Func="ReadLineByLineProfile"/> reads a previous output of 
##  <Ref Func="ProfileLineByLine"/> (or the concatenation of several runs)
##  and converts it into a pair [l,readd,execd] where l is a list of all the files
##  which were access, and readd and execd are dictionaries, which map each
##  element of l to the lines in l which have statements on, and where
##  statements were executed, respectively, for use in code coverage
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ReadLineByLineProfile",function(filename)
    local stream, line,
          linedict, funcdict, stackdict, filelist, funclist, stacklist,
          lasttime, parts, prevparts,
          gatherline, recursive_gen, LookupWithDefault, makefullfuncname;
    prevparts := [];
    filelist := Set([]);
    funclist := Set([]);
    stacklist := Set([]);
    
    linedict := NewDictionary("", true, IsString);
    funcdict := NewDictionary("", true, IsString);
    stackdict := NewDictionary("", true, IsString);
    
    LookupWithDefault := function(dict, val, default)
        local v;
        v := LookupDictionary(dict, val);
        if v = fail then
            return default;
        else
            return v;
        fi;
    end;
    
    # parts[1] = R/E, parts[2] = time, parts[3] = line, parts[4] = name.
    gatherline := function(str)
      local split;
      if str[Length(line)] = '\n' then
        str := str{[1..Length(str)-1]};
      fi;
      split := SplitString(str, " ");
      if Length(split) > 4 then
          # The file name had spaces! Chop it out manually
          split[4] := str{[Sum(split{[1..3]}, Length)+4..Length(str)]};
      fi;
      split[2] := Int(split[2]);
      split[3] := Int(split[3]);
      return split;
    end;
    
    makefullfuncname := function(shortname, line, file)
      return rec(shortname := shortname,
                 longname := Concatenation(shortname, "@", String(line), ":", file),
                 line := String(line),
                 file := file);
    end;
    
    # This function is recursive, so whenever we hit a new function we can collect
    # the runtime within that function.
    recursive_gen := function(funcname, stack)
      local fullfuncname, funcnestedtime, totaltime, infunctime,
            fullstack, funcreturn, localprevparts,
            ld, prevld, calledfns, lastrecursetime, newfuncname;
      totaltime := 0;
      infunctime := 0;
      funcnestedtime := 0;
      while line <> fail do
          if line[1] = 'R' or line[1] = 'E' then
              parts := gatherline(line);
              if not(IsBound(fullfuncname)) and line[1] = 'E' then
                  fullfuncname := makefullfuncname(funcname, parts[3], parts[4]);
                  AddSet(funclist, fullfuncname.longname);
                  funcnestedtime := LookupWithDefault(funcdict, fullfuncname.longname, 0);
              fi;
              
              totaltime := totaltime + parts[2];
              infunctime := infunctime + parts[2];
              
              if not(parts[4] in filelist) then
                  AddSet(filelist, parts[4]);
                  AddDictionary(linedict, parts[4], 
                    rec(read := Set([]), exec := Set([]),
                        time := NewDictionary(0, true, IsInt),
                        recursetime := NewDictionary(0, true, IsInt),
                        calledfuncs := NewDictionary(0, true, IsInt)));
              fi;
              
              ld := LookupDictionary(linedict, parts[4]);
              if line[1] = 'E' then
                  AddSet(ld.exec, parts[3]);
              else
                  AddSet(ld.read, parts[3]);
              fi;

              if prevparts <> [] then
                  prevld := LookupDictionary(linedict, prevparts[4]);
                  lasttime := LookupWithDefault(prevld.time, prevparts[3], 0);
                  AddDictionary(prevld.time, prevparts[3], lasttime + parts[2]);
              fi;
          
              prevparts := parts;
          fi;
          if line[1] = 'I' then
              localprevparts := prevparts;
              if Length(localprevparts) > 1 and localprevparts[1] = "E" then
                ld := LookupDictionary(linedict, localprevparts[4]);
                lastrecursetime := LookupWithDefault(ld.recursetime, localprevparts[3], 0);
              fi;
              if not(IsBound(fullfuncname)) then
                fullfuncname := makefullfuncname(funcname, "?", "?");
              fi;
              newfuncname := line{[3..Length(line)-1]};
              line := ReadLine(stream);
              funcreturn := recursive_gen(newfuncname, Concatenation(stack,";",fullfuncname.longname));
              totaltime := totaltime + funcreturn[2];
              
              if Length(localprevparts) > 1 and localprevparts[1] = "E" then
                ld := LookupDictionary(linedict, localprevparts[4]);
                AddDictionary(ld.recursetime, localprevparts[3], lastrecursetime + funcreturn[2]);
                calledfns := LookupWithDefault(ld.calledfuncs, localprevparts[3], Set([]));
                AddSet(calledfns, funcreturn[1]);
                AddDictionary(ld.calledfuncs, localprevparts[3], calledfns);
              fi;
              
          elif line[1] = 'O' then
              if not(IsBound(fullfuncname)) then
                fullfuncname := makefullfuncname(funcname,"?","?");
              fi;
              AddDictionary(funcdict, fullfuncname.longname, funcnestedtime + totaltime);
              fullstack := Concatenation(stack,";",fullfuncname.longname);
              AddSet(stacklist, fullstack);
              AddDictionary(stackdict, fullstack, 
                            LookupWithDefault(stackdict, fullstack, 0) + infunctime);
              return [fullfuncname, totaltime];
          fi;
          line := ReadLine(stream);
      od;
      
      if not(IsBound(fullfuncname)) then
        fullfuncname := makefullfuncname(funcname,"?","?");
      fi;
      return [fullfuncname, totaltime];
    end;
    
    stream := InputTextFile(filename);
    line := ReadLine(stream);
    while(line <> fail) do
        recursive_gen("root","");
        line := ReadLine(stream);
    od;
    
    CloseStream(stream);
    return rec(filelist := filelist, funclist := funclist, stacklist := stacklist,
               linedict := linedict, funcdict := funcdict, stackdict := stackdict);
end);



#############################################################################
##
##
##  <#GAPDoc Label="OutputFlameGraph">
##  <ManSection>
##  <Func Name="OutputFlameGraph" Arg="cover, filename"/>
##
##  <Description>
##  <Ref Func="OutputFlameGraph"/> takes <A>cover</A> (an output of
##  <Ref Func="ReadLineByLineProfile"/>), and a file name. It translates
##  profiling information in <A>cover</A> into a suitable format to
##  generate flame graphs.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("OutputFlameGraph",function(data, filename)
  local outstream, i;
  outstream := OutputTextFile(filename, false);
  SetPrintFormattingStatus(outstream, false);
  for i in data.stacklist do
    PrintTo(outstream, i, " ", LookupDictionary(data.stackdict, i), "\n");
  od;
  CloseStream(outstream);
end);

#############################################################################
##
##
##  <#GAPDoc Label="OutputAnnotatedCodeCoverageFiles">
##  <ManSection>
##  <Func Name="OutputAnnotatedCodeCoverageFiles" Arg="cover, indir, outdir"/>
##
##  <Description>
##  <Ref Func="OutputAnnotatedCodeCoverageFiles"/> takes <A>cover</A> (an output of
##  <Ref Func="ReadLineByLineProfile"/>), and two directory names. It outputs a copy
##  of each file in <A>cover</A> which is contained in <A>indir</A>
##  into <A>outdir</A>, annotated with which lines were executed.
##  <A>indir</A> may also be the name of a single file, in which case
##  only code coverage for that file is produced.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("OutputAnnotatedCodeCoverageFiles",function(data, indir, outdir)
    local infile, outname, instream, outstream, line, allLines, 
          coverage, counter, overview, i,
          readlineset, execlineset, outchar, outputtext, 
          outputhtml, outputoverviewhtml, LookupWithDefault;
    
    LookupWithDefault := function(dict, val, default)
        local v;
        v := LookupDictionary(dict, val);
        if v = fail then
            return default;
        else
            return v;
        fi;
    end;
    
    outputtext := function(lines, coverage, outstream)
      local i, outchar;
      for i in [1..Length(lines)] do
        if coverage[i] = 0 then
          outchar := "  ";
        elif coverage[i] = 1 then
          outchar := "* ";
        elif coverage[i] = 2 then
          outchar := "! ";
        elif coverage[i] = 3 then
          outchar := "- ";
        else
          Error("Internal error");
        fi;
        PrintTo(outstream, outchar, lines[i]);
      od;
    end;
    
    outputhtml := function(lines, coverage, linedict, outstream)
      local i, outchar, str, time, totaltime, calledfns, linkname, fn, name;
      PrintTo(outstream, "<html><body>\n",
        "<style>\n",
        ".linenum { text-align: right; border-right: 3px solid #FFFFFF; }\n",
        ".exec { border-right: 3px solid #2EFE2E; }\n",
        ".missed { border-right: 3px solid #FE2E64; }\n",
        ".ignore { border-right: 3px solid #BDBDBD; }\n",
        " td {border-right: 5px solid #FFFFFF;}\n",
        "}\n",
        "</style>\n",
        "<table cellspacing='0' cellpadding='0'>\n");
      
      for i in [1..Length(lines)] do
        if coverage[i] = 0 then
          outchar := "nocode";
        elif coverage[i] = 1 then
          outchar := "exec";
        elif coverage[i] = 2 then
          outchar := "missed";
        elif coverage[i] = 3 then
          outchar := "ignore";
        else
          Error("Internal error");
        fi;
        
        str := List(lines[i]);
        str := ReplacedString(str, "&", "&amp;");
        str := ReplacedString(str, "<", "&lt;");
        str := ReplacedString(str, " ", "&nbsp;");
        PrintTo(outstream, "<a name=\"line",i,"\"></a><tr>");
        time := LookupWithDefault(linedict.time, i, "");
        totaltime := LookupWithDefault(linedict.recursetime, i, "");
        calledfns := "";
        for fn in LookupWithDefault(linedict.calledfuncs, i, []) do
          linkname := ReplacedString(fn.file, "/", "_");
          Append(linkname, ".html");
          name := fn.shortname;
          if name = "nameless" then
            name := fn.longname;
          fi;
          Append(calledfns, Concatenation("<a href=\"",linkname,"#line",fn.line,"\">",name,"</a> "));
        od;
        
        PrintTo(outstream, "<td><p class='linenum ",outchar,"'>",i,"</p></td>");
        PrintTo(outstream, "<td>",time,"</td><td>",totaltime,"</td>");
        PrintTo(outstream, "<td><span><tt>",str,"</tt></span></td>");
        PrintTo(outstream, "<td><span>",calledfns,"</span></td");
        PrintTo(outstream, "</tr>");
      od;
            
      PrintTo(outstream,"</table></body></html>");
    end;
    
    outputoverviewhtml := function(overview, outdir)
      local filename, outstream, codecover, i;
      
      Sort(overview, function(v,w) return v.inname < w.inname; end);
      
      filename := Concatenation(outdir, "/index.html");
      outstream := OutputTextFile(filename, false);
      SetPrintFormattingStatus(outstream, false);
      PrintTo(outstream, "<html><body>\n",
        "<style>\n</style>\n",
        "<table cellspacing='0' cellpadding='0'>\n",
        "<tr><td valign='top'>\n");
      
      for i in [1..Length(overview)] do
        PrintTo(outstream, "<p><a href='",
           Remove(SplitString(overview[i].outname,"/")),
           "'>",overview[i].inname,"</a></p>");
      od;
      
      PrintTo(outstream, "</td><td class='text' valign='top'>");
      
      for i in overview do
        codecover := 1 - (i.readnotexeclines / (i.execlines + i.readnotexeclines));
        # We have to do a slightly horrible thing to get the formatting we want
        codecover := String(Floor(codecover*100.0));
        PrintTo(outstream, "<p>",codecover{[1..Length(codecover)-1]},"% (",
          i.execlines,"/",i.execlines + i.readnotexeclines,")</p>");
      od;
      
      PrintTo(outstream,"</td></tr></table></body></html>");
      CloseStream(outstream);
    end;
    
    overview := [];
    for infile in data.filelist do
        if Length(indir) <= Length(infile)
                and indir = infile{[1..Length(indir)]} then
            readlineset := LookupDictionary(data.linedict, infile).read;
            execlineset := LookupDictionary(data.linedict, infile).exec;
            outname := ReplacedString(infile, "/", "_");
            outname := Concatenation(outdir, "/", outname);
            outname := Concatenation(outname, ".html");
            instream := InputTextFile(infile);
            outstream := OutputTextFile(outname, false);
            SetPrintFormattingStatus(outstream, false);
            allLines := [];
            line := ReadLine(instream);
            while line <> fail do
              Add(allLines, line);
              line := ReadLine(instream);
            od;
            CloseStream(instream);
            
            coverage := List([1..Length(allLines)], x -> 0);
            for i in readlineset do
              coverage[i] := 2;
            od;
            for i in execlineset do
              coverage[i] := 1;
            od;
            
            Add(overview, rec(outname := outname, inname := infile,
            execlines := Length(Filtered(coverage, x -> x = 1)),
            readnotexeclines := Length(Filtered(coverage, x -> x = 2))));
            outputhtml(allLines, coverage, LookupDictionary(data.linedict, infile),
                                           outstream);

            CloseStream(outstream);
        fi;
    od;    
    # Output an overview page
    outputoverviewhtml(overview, outdir);
end);
#############################################################################
##
#E

