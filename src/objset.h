#ifndef GAP_OBJSET_H
#define GAP_OBJSET_H

StructInitInfo *InitInfoObjSets( void );

Obj NewObjSet();
Int FindObjSet(Obj set, Obj obj);
void AddObjSet(Obj set, Obj obj);
void RemoveObjSet(Obj set, Obj obj);
void ClearObjSet(Obj set);

Obj NewObjMap();
Int FindObjMap(Obj map, Obj key);
void AddObjMap(Obj map, Obj key, Obj value);
void RemoveObjMap(Obj map, Obj obj);
void ClearObjMap(Obj map);


#endif // GAP_OBJSET_H
