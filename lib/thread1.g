#############################################################################
##
#W  thread1.g                    GAP library                 Chris Jefferson
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file provides trivial mocks of thread-related primitives for 
##  traditional GAP.
##


AtomicList := function(l) return l; end;
FixedAtomicList := function(l) return l; end;
MakeWriteOnceAtomic := function(obj) return obj; end;
AtomicRecord := function(r) return r; end;

# Convenience aliases

IsShared := function(obj) return true; end;
IsLockable := IsShared;

ShareObjWithPrecedence := function(arg, precedence)
  return arg;
end;

ShareObj := function(arg)
  return arg;
end;

ShareUserObj := function(arg)
  return arg;
end;

ShareLibraryObj := function(arg)
  return arg;
end;

ShareKernelObj := function(arg)
  return arg;
end;

ShareInternalObj := function(arg)
  return arg;
end;

ShareSpecialObj := function(arg)
  return arg;
end;

ShareSingleObjWithPrecedence := function(arg, precedence)
  return arg;
end;

ShareSingleObj := function(arg)
  return arg;
end;

ShareSingleLibraryObj := function(arg)
  return arg;
end;

ShareSingleKernelObj := function(arg)
  return arg;
end;

ShareSingleInternalObj := function(arg)
  return arg;
end;

ShareSingleSpecialObj := function(arg)
  return arg;
end;

MigrateObj := function(obj,target)
  return obj;
end;

MigrateSingleObj :=MigrateObj;

AdoptObj := function(obj)
  return obj;
end;

AdoptSingleObj := AdoptObj;
CopyRegion := function(x)
  return x; 
end;

RegionSubObjects := function(x)
  return x;
end;

NewRegionWithPrecedence := function(arg, precedence)
  return 0;
end;

NewRegion := function(arg)
  return 0;
end;

NewLibraryRegion := NewRegion;

NewKernelRegion := NewRegion;

NewInternalRegion := NewRegion;

NewSpecialRegion := NewRegion;

ShareAutoReadObj := function(obj)
  return obj;
end;

AutoReadLock := function(obj)
  return obj;
end;

NewAutoReadRegion := function(arg)
  return 0;
end;

LockAndMigrateObj := function(obj, target)
  return obj;
end;

LockAndAdoptObj := function(obj)
  return obj;
end;

IncorporateObj := function(target, index, value)
    if IS_PLIST_REP(target) then
      target[index] := target;
    elif IS_REC(target) then
      target.(index) := target;
    else
      Error("IncorporateObj: target must be plain list or record");
    fi;
end;

AtomicIncorporateObj := function(target, index, value)
    if IS_PLIST_REP(target) then
      target[index] := target;
    elif IS_REC(target) then
      target.(index) := target;
    else
      Error("IncorporateObj: target must be plain list or record");
    fi;
end;

CopyRegion := function(obj) end;
CopyFromRegion := CopyRegion;

CopyToRegion := function(obj, target) end;
