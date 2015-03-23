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
#E
