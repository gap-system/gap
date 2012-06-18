#ifdef WITH_ZMQ

#include "src/compiled.h"
#include "zmq.h"

static GVarDescriptor TYPE_ZMQ_SOCKETGVar;
static Obj TYPE_ZMQ_SOCKET;

static Obj TypeZmqSocket() {
  /* multiple threads may initialize this concurrently, but that is safe */
  if (!TYPE_ZMQ_SOCKET)
    TYPE_ZMQ_SOCKET = GVarObj(&TYPE_ZMQ_SOCKETGVar);
  return TYPE_ZMQ_SOCKET;
}

static void *ZmqContext;

#define ZMQ_DAT_SOCKET_OFF 1
#define ZMQ_DAT_TYPE_OFF 2
#define ZMQ_DAT_FLAG_OFF 2

static void BadArgType(Obj obj, char *fname, int pos, char *expected) {
  char buf[1024];
  sprintf(buf, "Bad argument #%d of %s, expected %s, got %s",
    pos, fname, expected, InfoBags[TNUM_OBJ(obj)].name);
}

static void BadArg(char *fname, int pos, char *message) {
  char buf[1024];
  sprintf(buf, "Bad argument #%d of %s, %s", pos, fname, message);
}

static int IsSocket(Obj obj) {
  return TNUM_OBJ(obj) == T_DATOBJ &&
    ADDR_OBJ(obj)[0] == TypeZmqSocket();
}

static void *Socket(Obj obj) {
  return ADDR_OBJ(obj)[ZMQ_DAT_SOCKET_OFF];
}

static Int SocketType(Obj obj) {
  return INT_INTOBJ(ADDR_OBJ(obj)[ZMQ_DAT_TYPE_OFF]);
}


static void ZmqError(char *funcname) {
  ErrorQuit("%s: %s", (Int) funcname, (Int) zmq_strerror(errno));
}

static Obj FuncZmqSocket(Obj self, Obj type) {
  char *tstring;
  int t;
  void *socket;
  Obj result;
  if (!IS_STRING(type))
    BadArgType(type, "ZmqSocket", 1, "string specifying the socket type");
  tstring = CSTR_STRING(type);
  t = -1;
  switch (tstring[0]) {
    case 'P':
      if (!strcmp(tstring, "PULL")) t = ZMQ_PULL;
      else if (!strcmp(tstring, "PUSH")) t = ZMQ_PUSH;
      else if (!strcmp(tstring, "PUB")) t = ZMQ_PUB;
      break;
    case 'R':
      if (!strcmp(tstring, "REQ")) t = ZMQ_REQ;
      else if (!strcmp(tstring, "REP")) t = ZMQ_REP;
      break;
    case 'S':
      if (!strcmp(tstring, "SUB")) t = ZMQ_SUB;
      break;
  }
  if (t < 0)
    BadArg("ZmqSocket", 1, "not a valid socket type");
  socket = zmq_socket(ZmqContext, t);
  if (!socket)
    ZmqError("ZmqSocket");
  result = NewBag(T_DATOBJ, 4 * sizeof(Bag));
  ADDR_OBJ(result)[0] = TypeZmqSocket();
  ADDR_OBJ(result)[ZMQ_DAT_SOCKET_OFF] = socket;
  ADDR_OBJ(result)[ZMQ_DAT_TYPE_OFF] = INTOBJ_INT(t);
  ADDR_OBJ(result)[ZMQ_DAT_FLAG_OFF] = 0;
  return result;
}

static Obj FuncZmqBind(Obj self, Obj socketobj, Obj addrobj) {
  void *socket;
  char *addr;
  if (!IsSocket(socketobj))
    BadArgType(socketobj, "ZmqBind", 1, "zmq socket");
  if (!IsStringConv(addrobj))
    BadArgType(addrobj, "ZmqBind", 2, "string specifying a local address");
  socket = Socket(socketobj);
  addr = CSTR_STRING(addrobj);
  if (zmq_bind(socket, addr) < 0)
    ZmqError("ZmqBind");
  return (Obj) 0;
}

static Obj FuncZmqConnect(Obj self, Obj socketobj, Obj addrobj) {
  void *socket;
  char *addr;
  if (!IsSocket(socketobj))
    BadArgType(socketobj, "ZmqConnect", 1, "zmq socket");
  if (!IsStringConv(addrobj))
    BadArgType(addrobj, "ZmqConnect", 2, "string specifying a remote address");
  socket = Socket(socketobj);
  addr = CSTR_STRING(addrobj);
  if (zmq_connect(socket, addr) < 0)
    ZmqError("ZmqConnect");
  return (Obj) 0;
}

static Obj FuncZmqSend(Obj self, Obj socketobj, Obj data) {
  int is_string = 1;
  int error = 0;
  void *socket;
  zmq_msg_t msg;
  if (!IsSocket(socketobj))
    BadArgType(socketobj, "ZmqSend", 1, "zmq socket");
  if (!IsStringConv(data)) {
    if (IS_LIST(data)) {
      Int i, len = LEN_LIST(data);
      if (len == 0)
	BadArgType(data, "ZmqSend", 2, "string or non-empty list of strings");
      for (i=1; i <= len; i++) {
        if (!IS_STRING(ELM_LIST(data, i)))
	  BadArgType(data, "ZmqSend", 2, "string or non-empty list of strings");
      }
      is_string = 0;
    }
  }
  if (is_string) {
    zmq_msg_init_size(&msg, GET_LEN_STRING(data));
    memcpy(zmq_msg_data(&msg), CSTR_STRING(data), GET_LEN_STRING(data));
    error = (zmq_send(Socket(socketobj), &msg, 0) < 0);
    zmq_msg_close(&msg);
  } else {
    Int i = 1;
    Int len = LEN_LIST(data);
    int flags = ZMQ_SNDMORE;
    socket = Socket(socketobj);
    do {
      Obj elem = ELM_LIST(data, i);
      zmq_msg_init_size(&msg, GET_LEN_STRING(elem));
      memcpy(zmq_msg_data(&msg), CSTR_STRING(elem), GET_LEN_STRING(elem));
      if (i == len)
        flags &= ~ZMQ_SNDMORE;
      error = (zmq_send(socket, &msg, flags) < 0);
      zmq_msg_close(&msg);
      i++;
    } while (!error && i <= len);
  }
  return (Obj) 0;
}

static Obj FuncZmqReceive(Obj self, Obj socketobj) {
  void *socket;
  int flags;
  zmq_msg_t msg;
  int64_t more;
  size_t more_size;
  Obj result;

  int is_list = 0;
  if (!IsSocket(socketobj))
    BadArgType(socketobj, "ZmqReceive", 1, "zmq socket");
  socket = Socket(socketobj);
  zmq_msg_init(&msg);
  if (zmq_recv(socket, &msg, 0) < 0)
    ZmqError("ZmqReceive");
  result = NEW_STRING(zmq_msg_size(&msg));
  memcpy(CSTR_STRING(result), zmq_msg_data(&msg), zmq_msg_size(&msg));
  zmq_msg_close(&msg);
  for (;;) {
    Obj elem;
    more_size = sizeof(more);
    zmq_getsockopt(socket, ZMQ_RCVMORE, &more, &more_size);
    if (!more) break;
    if (!is_list) {
      elem = result;
      result = NEW_PLIST(T_PLIST, 1);
      SET_LEN_PLIST(result, 1);
      SET_ELM_PLIST(result, 1, elem);
      is_list = 1;
    }
    zmq_msg_init(&msg);
    if (zmq_recv(socket, &msg, 0) < 0)
      ZmqError("ZmqReceive");
    elem = NEW_STRING(zmq_msg_size(&msg));
    memcpy(CSTR_STRING(elem), zmq_msg_data(&msg), zmq_msg_size(&msg));
    zmq_msg_close(&msg);
    AddPlist(result, elem);
  }
  return result;
}

static Obj FuncZmqClose(Obj self, Obj socketobj) {
  void *socket;
  if (!IsSocket(socketobj))
    BadArgType(socketobj, "ZmqClose", 1, "zmq socket");
  socket = Socket(socketobj);
  if (zmq_close(socket) < 0)
    ZmqError("ZmqClose");
}

#define FUNC_DEF(name, narg, argdesc) \
  { #name, narg, argdesc, Func ## name, __FILE__ ":Func" #name }

static StructGVarFunc GVarFuncs [] = {
  FUNC_DEF(ZmqSocket, 1, "string describing socket type"),
  FUNC_DEF(ZmqBind, 2, "zmq socket, local address"),
  FUNC_DEF(ZmqConnect, 2, "zmq socket, remote address"),
  FUNC_DEF(ZmqSend, 2, "zmq socket, string|list of strings"),
  FUNC_DEF(ZmqReceive, 1, "zmq socket"),
  FUNC_DEF(ZmqClose, 1, "zmq socket"),
};

/******************************************************************************
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel ( StructInitInfo *module )
{
    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );
    DeclareGVar(&TYPE_ZMQ_SOCKETGVar, "TYPE_ZMQ_SOCKET");

    /* return success                                                      */
    return 0;
}

/******************************************************************************
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary ( StructInitInfo *module )
{
  Int             i, gvar;
  Obj             tmp;

  /* init filters and functions
     we assign the functions to components of a record "IO"         */
  for ( i = 0; GVarFuncs[i].name != 0;  i++ ) {
    gvar = GVarName(GVarFuncs[i].name);
    AssGVar(gvar,NewFunctionC( GVarFuncs[i].name, GVarFuncs[i].nargs,
			       GVarFuncs[i].args, GVarFuncs[i].handler )); 
    MakeReadOnlyGVar(gvar);
  }
  ZmqContext = zmq_init(1);
  return 0;
}


/******************************************************************************
*F  InitInfo()  . . . . . . . . . . . . . . . . . table of init functions
*/

static StructInitInfo module = {
 /* type        = */ MODULE_BUILTIN,
 /* name        = */ "zmq",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 0,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ 0
};

StructInitInfo *InitInfoZmq ( void )
{
  FillInVersion( &module );
  return &module;
}



#endif WITH_ZMQ
