#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Chris Jefferson.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the gap frontend of profile.c in src.
##


#############################################################################
##
##
##  <#GAPDoc Label="ProfileLineByLine">
##  <ManSection>
##  <Func Name="ProfileLineByLine" Arg="filename[,options]"/>
##
##  <Description>
##  <Ref Func="ProfileLineByLine"/> begins GAP recording profiling
##  data to the file <A>filename</A>. This file will get *very* large
##  very quickly. This file is compressed using gzip to reduce its size.
##
##  <A>options</A> is an optional dictionary, which sets various
##  configuration options. These are
##  <List>
##  <Mark>coverage</Mark>
##      <Item> Boolean (defaults to false). If this is enabled,
##      only information about which lines are read and executed is
##      stored. Enabling this is the same as calling
##      <Ref Func="CoverageLineByLine"/>. Using this ignores all other
##      options.</Item>
##
##  <Mark>wallTime</Mark>
##      <Item> Boolean (defaults to true). Sets if time should be measured
##             using wall-clock time (true) or CPU time (false).
##             (measuring CPU-time has a higher overhead).
##      </Item>
##
##  <Mark>recordMem</Mark>
##      <Item> Boolean (defaults to false). Instead of recording the
##             CPU time taken by statements, record the total size of all
##             new objects created by each line.
##      </Item>
##
##  <Mark>resolution</Mark>
##      <Item> Integer (defaults to 0). By default profiling will record a trace
##             of all executed code. When <A>resolution</A> non-zero, GAP
##             instead samples which piece of code is being executed every
##             <A>resolution</A> nanoseconds. Increasing this
##             improves performance and produces smaller traces,
##             at the cost of accuracy. GAP will still accurately record
##             which statements are executed at least once.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ProfileLineByLine",function(arg)
    local optRec, r;
    if Length(arg) = 0 or Length(arg) > 2 or not(IsString(arg[1])) then
      Error("usage: ProfileLineByLine(filename,[options]");
    fi;

    optRec := rec(coverage := false,
                  wallTime := true,
                  recordMem := false,
                  resolution := 0);
    if Length(arg) = 2 then
      if not(IsRecord(arg[2])) then
        Error("usage: ProfileLineByLine(filename,[options]");
      fi;

      for r in RecNames(arg[2]) do
        if not(IsBound(optRec.(r))) then
          Error(Concatenation("Bad option: ", r));
        fi;
        optRec.(r) := arg[2].(r);
      od;
    fi;

    if Length(arg[1]) < 3 or
       arg[1]{[Length(arg[1])-2..Length(arg[1])]} <> ".gz" then
      Info(InfoWarning, 1, "Profile filenames must end in .gz to enable compression");
    fi;
    return ACTIVATE_PROFILING(arg[1], optRec.coverage, optRec.wallTime,
                                      optRec.recordMem, optRec.resolution);
end);

##  <#GAPDoc Label="IsLineByLineProfileActive">
##  <ManSection>
##  <Func Name="IsLineByLineProfileActive" Arg=""/>
##
##  <Description>
##  <Ref Func="IsLineByLineProfileActive"/> returns if line-by-line
##  profiling is currently activated.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>


##  <#GAPDoc Label="CoverageLineByLine">
##  <ManSection>
##  <Func Name="CoverageLineByLine" Arg="filename"/>
##
##  <Description>
##  <Ref Func="CoverageLineByLine"/> begins GAP recording code coverage
##  to the file <A>filename</A>. This is equivalent to calling
##  <Ref Func="ProfileLineByLine"/> with coverage=true.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

BIND_GLOBAL("CoverageLineByLine", function(name)
  return ProfileLineByLine(name, rec(coverage := true));
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
##  <Ref Func="ProfileLineByLine"/> or <Ref Func="CoverageLineByLine"/>.
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
##  <#GAPDoc Label="UncoverageLineByLine">
##  <ManSection>
##  <Func Name="UncoverageLineByLine" Arg=""/>
##
##  <Description>
##  Stops profiling which was previously started with
##  <Ref Func="ProfileLineByLine"/> or <Ref Func="CoverageLineByLine"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("UncoverageLineByLine", function()
  return DEACTIVATE_PROFILING();
end);
