#ifndef GAP_OBJSET_H
#define GAP_OBJSET_H

#define OBJSET_HDRSIZE 4

#define OBJSET_SIZE 0
#define OBJSET_BITS 1
#define OBJSET_USED 2
#define OBJSET_DIRTY 3

Obj NewObjSet();
Int FindObjSet(Obj set, Obj obj);
void AddObjSet(Obj set, Obj obj);
void RemoveObjSet(Obj set, Obj obj);
void ClearObjSet(Obj set);
Obj ObjSetValues(Obj set);

Obj NewObjMap();
Int FindObjMap(Obj map, Obj key);
Obj LookupObjMap(Obj map, Obj key);
void AddObjMap(Obj map, Obj key, Obj value);
void RemoveObjMap(Obj map, Obj obj);
void ClearObjMap(Obj map);
Obj ObjMapValues(Obj map);
Obj ObjMapKeys(Obj map);

StructInitInfo *InitInfoObjSets( void );

#endif // GAP_OBJSET_H
