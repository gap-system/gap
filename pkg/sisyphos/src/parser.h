typedef union {
	int ival;
	GENVAL *gval;
	} YYSTYPE;
#define	NUMBER	258
#define	NGEN	259
#define	CGEN	260
#define	GRGEN	261
#define	QUIT	262
#define	MOD	263
#define	IDEAL	264
#define	DEFGRP	265
#define	DEFPCGRP	266
#define	DEFAGGRP	267
#define	STRING	268
#define	IDENTIFIER	269
#define	NUM	270
#define	RELS	271
#define	SEQ	272
#define	MATRIX	273
#define	GEN	274
#define	ID	275
#define	READAUTGRP	276
#define	READGRP	277
#define	READPCGRP	278
#define	READAGGRP	279
#define	MINIMAL	280
#define	ACTUAL	281
#define	GENS	282
#define	WEIGHTS	283
#define	BATCH	284
#define	COMMUT	285
#define	UMINUS	286


extern YYSTYPE yylval;
