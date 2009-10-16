/* 	$Id: error.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: error.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 16:54:47  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:28:12  pluto
 * Initial version under RCS control.
 *	 */

#ifdef ALLOC
#	define ALLOC_CLS /* empty */
#else
#	define ALLOC_CLS extern
#endif

typedef enum {
	NO_ERROR,
	UNDEFINED_EXPRESSION,
	IS_NOT_TYPE_GROUP,
	IS_NOT_TYPE_PCGROUP,
	IS_NOT_TYPE_GROUPRING,
	IS_NOT_TYPE_GROUPEL,
	IS_NOT_TYPE_INT,
	IS_NOT_TYPE_GRELEMENT,
	IS_NOT_TYPE_VECTORSPACE,
	IS_NOT_TYPE_DLIST,
	IS_NOT_TYPE_HOMREC,
	IS_NOT_TYPE_GRHOMREC,
	IS_NOT_TYPE_SGRHOMREC,
	NO_SUCH_HOM,
	INCOMPATIBLE_TYPES,
	INCOMPATIBLE_SPACES,
	INVREL_WRONG_GENERATOR,
	INVREL_UNEXP_CHAR,
	NO_GEN_DECL,
	NO_REL_DECL,
	MISSING_LPAR,
	INVALID_GENERATOR,
	INVALID_SEPARATOR,
	INVREL,
	INV_PC_REL,
	MEMORY_EXHAUSTED,
	TMEMORY_EXHAUSTED,
	NO_AUTOMORPHISMS,
	STRING_EXPECTED,
	WRONG_TYPE,
	FILE_OPEN_ERR,
	SYNTAX_ERROR,
	GEN_MAY_NOT_BE_REASSIGNED,
	IS_NOT_UNIT,
	DIVISION_BY_ZERO,
	NO_WEIGHTS,
	NO_INNER_AUTOMORPHISMS,
	UNDEF_IDENTIFIER,
	NO_SUCH_PROC,
	SPECIAL_ERROR
} ERR_MSG;

ALLOC_CLS ERR_MSG error_no;
ALLOC_CLS ERR_MSG warning_no;

void proc_error		_(( void ));
void set_error			_(( ERR_MSG error_num ));
void set_warning		_(( ERR_MSG error_num ));

