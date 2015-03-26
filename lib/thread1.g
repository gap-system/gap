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

ShareObjWithPrecedence := function(arg1, precedence)
  return arg1;
end;

ShareObj := function(arg1)
  return arg1;
end;

ShareUserObj := function(arg1)
  return arg1;
end;

ShareLibraryObj := function(arg1)
  return arg1;
end;

ShareKernelObj := function(arg1)
  return arg1;
end;

ShareInternalObj := function(arg1)
  return arg1;
end;

ShareSpecialObj := function(arg1)
  return arg1;
end;

ShareSingleObjWithPrecedence := function(arg1, precedence)
  return arg1;
end;

ShareSingleObj := function(arg1)
  return arg1;
end;

ShareSingleLibraryObj := function(arg1)
  return arg1;
end;

ShareSingleKernelObj := function(arg1)
  return arg1;
end;

ShareSingleInternalObj := function(arg1)
  return arg1;
end;

ShareSingleSpecialObj := function(arg1)
  return arg1;
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

NewRegionWithPrecedence := function(arg1, precedence)
  return 0;
end;

NewRegion := function(arg1)
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

NewAutoReadRegion := function(arg1)
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
