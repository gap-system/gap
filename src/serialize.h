#ifndef GAP_SERIALIZE_H
#define GAP_SERIALIZE_H

typedef void (*SerializationFunction)(Obj obj);
typedef Obj (*DeserializationFunction)(UInt tnum);

typedef struct SerializerInterface {
  void (*WriteTNum)(UInt tnum);
  void (*WriteByte)(UChar tnum);
  void (*WriteByteBlock)(UInt size, void *addr);
  void (*WriteImmediateObj)(Obj obj);
} SerializerInterface;

typedef struct DeserializerInterface {
  UInt (*ReadTNum)(void);
  UChar (*ReadByte)(void);
  UInt (*ReadByteBlockLength)(void);
  void (*ReadByteBlockData)(UInt size, void *addr);
  Obj (*ReadImmediateObj)(void);
} DeserializerInterface;

StructInitInfo * InitInfoSerialize ( void );

#endif /* GAP_SERIALIZE_H */
