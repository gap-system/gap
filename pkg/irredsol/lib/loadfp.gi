############################################################################
##
##  loadfp.gi                     IRREDSOL                  Burkhard Höfling
##
##  @(#)$Id: loadfp.gi,v 1.7 2011/05/18 16:28:21 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##

IRREDSOL_DATA.FP := [];
IRREDSOL_DATA.FP_INDEX := [];
IRREDSOL_DATA.FP_LOADED := [];


############################################################################
##
#F  IsAvailableAbsolutelyIrreducibleSolvableGroupFingerprintIndex(<n>, <q>)
##  
InstallGlobalFunction (IsAvailableAbsolutelyIrreducibleSolvableGroupFingerprintIndex,
    function (n, q)
    
        if not IsPosInt (n) or not IsPosInt (q) or not IsPPowerInt (q)  then
            Error ("n and q must be positive integers and q must be a prime power");
        fi;
        
        return TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex (n, q);
        
    end);
    
    
############################################################################
##
#F  TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex(<n>, <q>)
##  
InstallGlobalFunction (TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex,
    function (n, q)
    
        local pathname;
        
        if not IsPosInt (n) or not IsPosInt (q) or not IsPPowerInt (q)  then
            Error ("n and q must be positive integers and q must be a prime power");
        fi;
        
        if n = 1 then
            return true;
        fi;
        
        if not IsBound (IRREDSOL_DATA.FP_INDEX[n]) then
            IRREDSOL_DATA.FP_INDEX[n] := [];
        fi;
        
        if not IsBound (IRREDSOL_DATA.FP_INDEX[n][q]) then
            pathname := Concatenation ("fp/gl_", String (n), "_",String (q),".idx");

            Info (InfoIrredsol, 2, "Reading data file ", pathname);

            if not ReadPackage ("irredsol", pathname) then
                return false;
            fi;
            
            
            if not IsBound (IRREDSOL_DATA.FP_INDEX[n][q]) then
                Error ("Panic: reading data file didn't define required data");
            fi;
            MakeImmutable (IRREDSOL_DATA.FP_INDEX[n][q]);
            
        fi;
        return true;
    end);
    

###########################################################################
##
#F  LoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex(<n>, <q>)
##  
InstallGlobalFunction (LoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex,
    function (n, q)
    
        if not IsPosInt (n) or not IsPosInt (q) or not IsPPowerInt (q)  then
            Error ("n and q must be positive integers and q must be a prime power");
        fi;
        
        if not TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex (n, q) then
            Error ("Panic: missing fingerprint index file for GL(",n,", ", q, ")");
        fi;
    end);
    
    
############################################################################
##
#F  IsAvailableAbsolutelyIrreducibleSolvableGroupFingerprintData(<n>, <q>, <index>)
##  
InstallGlobalFunction (IsAvailableAbsolutelyIrreducibleSolvableGroupFingerprintData,

    function (n, q, index)
        if not IsPosInt (n) or not IsPosInt (q) or not IsPPowerInt (q) 
            or not IsPosInt (index) then
                Error ("n, q, and index must be positive integers",
                    ", and q must be a prime power");
        fi;
        
        return TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintData (n, q, index);
    end);
    
    
###########################################################################
##
#F  TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintData(<n>, <q>, <index>)
##
InstallGlobalFunction (TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintData,
    function (n, q, index)
    
        local pathname, i;
        
        if not IsPosInt (n) or not IsPosInt (q) or not IsPPowerInt (q) or not IsPosInt (index) then
            Error ("n and q must be positive integers, q must be a prime power, and pos must be a positive integer");
        fi;

        if n = 1 then
            return; # group is unique, up to conjugacy - no information stored
        fi;
        
        if not IsBound (IRREDSOL_DATA.FP[n]) then
            IRREDSOL_DATA.FP[n] := [];
        fi;
            
        if not IsBound (IRREDSOL_DATA.FP[n][q]) then
            IRREDSOL_DATA.FP[n][q] := [];
        fi;
        
        if not IsBound (IRREDSOL_DATA.FP_LOADED[n]) then
            IRREDSOL_DATA.FP_LOADED[n] := [];
        fi;
        
        if not IsBound (IRREDSOL_DATA.FP_LOADED[n][q]) then
            IRREDSOL_DATA.FP_LOADED[n][q] := [];
        fi;
        
        if not IsBound (IRREDSOL_DATA.FP_LOADED[n][q][index]) then
            
            Unbind(IRREDSOL_DATA.FP_LOADED[n][q][index]); # if anything fails during loading
                # we won't have inconsistencies
    
            pathname := Concatenation ("fp/gl_", String (n), "_",String (q),"_", String(index),".fp");

            Info (InfoIrredsol, 2, "Reading fingerprint file ", pathname);
            if not ReadPackage ("irredsol", pathname) then
                return false;
            fi;
            
            for i in [1..Length (IRREDSOL_DATA.FP_INDEX[n][q][2])] do
                if IRREDSOL_DATA.FP_INDEX[n][q][2][i] = index then
                    MakeImmutable (IRREDSOL_DATA.FP[n][q][i]);
                fi;
            od;
            IRREDSOL_DATA.FP_LOADED[n][q][index] := true;
            
        fi;
        return true;
    end);
    
        
###########################################################################
##
#F  LoadAbsolutelyIrreducibleSolvableGroupFingerprintData(<n>, <q>, <index>)
##  
InstallGlobalFunction (LoadAbsolutelyIrreducibleSolvableGroupFingerprintData,
    function (n, q, index)
    
        if not IsPosInt (n) or not IsPosInt (q) or not IsPPowerInt (q) or not IsPosInt (index) then
            Error ("n and q must be positive integers, q must be a prime power, and pos must be a positive integer");
        fi;
        if not TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintData (n, q, index) then
            Error ("Panic: ", index, "-th fingerprint file for GL(",n,", ", q, ") is missing");
        fi;
    end);

###########################################################################
##
#F  LoadAbsolutelyIrreducibleSolvableGroupFingerprints(<n>, <q>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (LoadAbsolutelyIrreducibleSolvableGroupFingerprints,
    function (n, q)
    
        local i;
        
        if not IsPosInt (n) or not IsPosInt (q) or not IsPPowerInt (q) then
            Error ("n and q must be positive integers, and q must be a prime power");
        fi;
    
        LoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex (n, q);
        for i in Set (IRREDSOL_DATA.FP_INDEX[n][q][2]) do
            LoadAbsolutelyIrreducibleSolvableGroupFingerprintData (n, q, i);
        od;
    end);
    

###########################################################################
##
#F  UnloadAbsolutelyIrreducibleSolvableGroupFingerprints(<arg>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (UnloadAbsolutelyIrreducibleSolvableGroupFingerprints,
    function (arg)
    
        local UnbindIfBound;
        
        UnbindIfBound := function (arg)
            local data, i;
            
            data := arg[1];
            i := 2;
            while i < Length (arg)  do
                if not IsBound (data[arg[i]]) then
                    return false;
                fi;
                data := data[arg[i]];
                i := i + 1;
            od;
            if IsBound (data[arg[i]]) then
                Unbind (data[arg[i]]);
                return true;
            else
                return false;
            fi;
        end;
                    
        if Length (arg) = 0 then
            IRREDSOL_DATA.FP := [];
            IRREDSOL_DATA.FP_INDEX := [];
            IRREDSOL_DATA.FP_LOADED := [];
        elif IsPosInt (arg[1]) and Length (arg) = 1 then
            if arg[1] > 1 then
                UnbindIfBound (IRREDSOL_DATA.FP, arg[1]);
                UnbindIfBound (IRREDSOL_DATA.FP_INDEX, arg[1]);
                UnbindIfBound (IRREDSOL_DATA.FP_LOADED, arg[1]);
            fi;
        elif Length (arg) = 2 and IsPosInt (arg[1]) and IsPPowerInt (arg[2]) and arg[2] <> 1 then
            if arg[1] > 1 then
                UnbindIfBound (IRREDSOL_DATA.FP, arg[1], arg[2]);
                UnbindIfBound (IRREDSOL_DATA.FP_INDEX, arg[1], arg[2]);
                UnbindIfBound (IRREDSOL_DATA.FP_LOADED, arg[1], arg[2]);
            fi;
        else
            Error ("Usage: `UnloadAbsolutelyIrreducibleSolvableGroupFingerprints ( [n [, q]] )'");
        fi;
    end);


############################################################################
##
#F  LoadedAbsolutelyIrreducibleSolvableGroupFingerprints()
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (LoadedAbsolutelyIrreducibleSolvableGroupFingerprints,
    function ()
    
        local n, p, data, fields;
        
        data := [];
        for n in [1..Length (IRREDSOL_DATA.FP)] do
            if IsBound (IRREDSOL_DATA.FP[n]) then
                fields := [];
                for p in [1..Length (IRREDSOL_DATA.FP[n])] do
                    if IsBound (IRREDSOL_DATA.FP[n][p]) then
                        Add (fields, p);
                    fi;
                od;
                if not IsEmpty (fields) then
                    Add (data, [n, fields]);
                fi;
            fi;
        od;
        return data;
    end);
                        



###########################################################################
##
#E
##
