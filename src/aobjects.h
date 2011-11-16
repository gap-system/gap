StructInitInfo *InitInfoAObjects(void);
Obj SetARecordField(Obj record, UInt field, Obj obj);
Obj GetARecordField(Obj record, UInt field);
Obj AssTLRecord(Obj record, UInt field, Obj obj);
Obj GetTLRecordField(Obj record, UInt field);
Obj FromAtomicRecord(Obj record);
void SetTLDefault(Obj record, UInt rnam, Obj value);
void SetTLConstructor(Obj record, UInt rnam, Obj func);
