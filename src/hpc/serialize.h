#ifndef GAP_SERIALIZE_H
#define GAP_SERIALIZE_H

typedef struct SerializationState {
    Obj    obj;
    UInt   index;
    void * dispatcher;
    Obj    registry;
    Obj    stack;
} SerializationState;

typedef void (*SerializationFunction)(Obj obj);
typedef Obj (*DeserializationFunction)(UInt tnum);

typedef struct SerializerInterface {
  void (*WriteTNum)(UInt tnum);
  void (*WriteByte)(UChar tnum);
  void (*WriteByteBlock)(Obj obj, UInt offset, UInt len);
  void (*WriteImmediateObj)(Obj obj);
} SerializerInterface;

typedef struct DeserializerInterface {
  UInt (*ReadTNum)(void);
  UChar (*ReadByte)(void);
  UInt (*ReadByteBlockLength)(void);
  void (*ReadByteBlockData)(Obj obj, UInt offset, UInt len);
  Obj (*ReadImmediateObj)(void);
} DeserializerInterface;

StructInitInfo * InitInfoSerialize ( void );

#endif /* GAP_SERIALIZE_H */
