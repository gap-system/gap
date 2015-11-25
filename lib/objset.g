BindGlobal("ObjSetFamily", NewFamily("ObjSetFamily", IsObject));
DeclareFilter("IsObjSet", IsObject and IsInternalRep);
DeclareFilter("IsObjMap", IsObject and IsInternalRep);

BindGlobal("TYPE_OBJSET", NewType(ObjSetFamily, IsObjSet));
BindGlobal("TYPE_OBJMAP", NewType(ObjSetFamily, IsObjMap));
