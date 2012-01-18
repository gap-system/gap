/****************************************************************************
**
**    presentation.c          Presentation                     Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/


#include "config.h"

#include "presentation.h"
#include "pcarith.h"

static node *Word(void);


/*
**    ------------------------ GENERAL PURPOSE -------------------------
**    The first part of this file just contain some auxiliary functions.
*/


/*
**    FreeNode() recursively frees a given node.
*/
void    FreeNode(node *n) {
	if (n->type != TGEN && n->type != TNUM) {
		FreeNode(n->cont.op.l);
		FreeNode(n->cont.op.r);
	}
	Free(n);
}

/*
**    GetNode() allocates space for a node of given type.
*/
static node    *GetNode(int type) {
	node    *n;

	n = (node *)Allocate(sizeof(node));
	n->type = type;

	return n;
}

/*
**    GenNumber() maintains the array GenNames[] of generator names which
**    have been read so far. GenNumber() is called from the parser in order
**    to create a new generator or to look up an existing one. The generator
**    name is communicated to GenNumber() through the variable gname.
**
**    If GenNumber() is called with the flag CREATE it checks if the generator
**    name in gname has not occurred before and, if not, creates a new entry
**    and returns the new generator number. If the name had occurred before
**    the illegal generator number 0 is returned.
**
**    If GenNumber() is called with the flag NOCREATE it searches for the
**    generator name and returns the corresponding number if a matching entry
**    in GenNames[] is found. If no matching entry is found, the illegal
**    generator number 0 is returned.
*/
static char     **GenNames;
static unsigned NrGens = 0;

#define NOCREATE 0
#define CREATE   1

static gen GenNumber(char *gname, int status) {
	unsigned        i;

	if (status == CREATE && NrGens == 0)  /* Initialize GenNames[]. */
		GenNames = (char **)Allocate(128 * sizeof(char*));

	for (i = 1; i <= NrGens; i++)  /* Find the generator name. */
		if (strcmp(gname, GenNames[i]) == 0) {
			if (status == CREATE) return (gen)0;
			return (gen)i;
		}

	/* It's a new generator. */
	if (status == NOCREATE) return (gen)0;
	NrGens++;
	if (NrGens % 128 == 0)
		GenNames = (char **)ReAllocate((void *)GenNames,
		                               (NrGens + 128) * sizeof(char *));

	i = strlen(gname);
	GenNames[ NrGens ] = (char *)Allocate((i + 1) * sizeof(char));
	strcpy(GenNames[NrGens], gname);

	return NrGens;
}

/*
**    GenName() is the inverse function for GenNumber(). It returns the
**    name of a generator given by its number.
*/
const char *GenName(gen g) {
	if (g > (gen)NrGens)
		return 0;
	return GenNames[g];
}

/*
**    ------------------------- SCANNER ---------------------------
**    The second part of this file contains the scanner. The parser
**    starts after the function Generator().
*/

/*
**    The following macros define tokens.
*/
typedef enum {
	LPAREN,
	RPAREN,
	LBRACK,
	RBRACK,
	LBRACE,
	RBRACE,

	MULT,
	POWER,
	EQUAL,
	DEQUALL,
	DEQUALR,

	PLUS,
	MINUS,

	LANGLE,
	RANGLE,

	PIPE,
	COMMA,
	SEMICOLON,
	NUMBER,
	GEN
} TokenType;

static int      Ch;             /* Contains the next char on the input. */
static TokenType Token;          /* Contains the current token. */
static int      Line;           /* Current line number. */
static int      TLine;          /* Line number where token starts. */
static int      Char;           /* Current character number. */
static int      TChar;          /* Character number where token starts. */
static const char     *InFileName;    /* Current input file name. */
static const char     *OutFileName;   /* Current output file name. */
static FILE     *InFp;          /* Current input file pointer. */
static FILE     *OutFp;         /* Current output file pointer. */
static int      N;              /* Contains the integer just read. */
static char     Gen[128];       /* Contains the generator name. */
/*
static const char     *TokenName[] = {
	"", "LParen", "RParen", "LBrack", "RBrack", "LBrace",
	"RBrace", "Mult",   "Power",  "Equal",  "DEqualL",
	"DEqualR", "Plus",   "Minus",  "LAngle", "RAngle",
	"Pipe",   "Comma",  "Number", "Gen"
};
*/

/*
**    SyntaxError() just prints a syntax error and the line and place
**    where is occurred and then exits.
**    No recovery from syntax errors :-)
*/
static void SyntaxError(const char *str) {
	if (str == 0)
		fprintf(stderr, "%s, line %d, char %d.\n",
		        InFileName, TLine, TChar);
	else
		fprintf(stderr, "%s, line %d, char %d: %s.\n",
		        InFileName, TLine, TChar, str);

	exit(1);
}

/*
**    ReadCh() reads the next character from the current input file.
**    At the same time it checks for lines terminated with '\'. Such
**    a line is continued in the next line, therefore ReadCh() discards
**    '\' and the following '\n'.
*/
static void ReadCh(void) {

	Ch = getc(InFp);
	Char++;
	if (Ch == '\\') {
		Ch = getc(InFp);
		if (Ch == '\n') { Line++; Char = 0; ReadCh(); }
		else             { ungetc(Ch, InFp); Ch = '\\'; }
	}
}

/*
**    SkipBlanks() skips the characters ' ', '\t' and '\n' as well as
**    comments. A comment starts with '#' and finishes at the end of
**    the line.
*/
static void     SkipBlanks(void) {

	/* If Ch is empty, the next character is fetched. */
	if (Ch == '\0') ReadCh();

	/* First blank characters and comments are skipped. */
	while (Ch == ' ' || Ch == '\t' || Ch == '\n' || Ch == '#') {
		if (Ch == '#') {  /* Skip to the end of line. */
			while (Ch != '\n') ReadCh();
		}
		if (Ch == '\n') { Line++; Char = 0; }
		ReadCh();
	}
}

/*
**    Number reads a number from the input.
*/
static void Number(void) {

	unsigned int    m, n = 0, overflow = 0;

	while (isdigit(Ch)) {
		m = n;
		n = 10 * n + (Ch - '0');
		if ((n - (Ch - '0')) / 10 != m) { overflow = 1; break; }
		ReadCh();
	}

	if (overflow) {
		fprintf(stderr, "Integer overflow reading %u%c", m, Ch);
		ReadCh();
		while (isdigit(Ch)) { fprintf(stderr, "%c", Ch); ReadCh(); }
		fprintf(stderr, " in\n");
		SyntaxError((char *)0);
	} else if (n >= (1U << (8 * sizeof(unsigned int) - 1))) {
		fprintf(stderr, "Integer overflow reading %u in\n", n);
		SyntaxError((char *)0);
	}

	N = n;
}

/*
**    Generator() reads characters from the input stream until a non-
**    alphanumeric character is encountered. Only the first 127 characters
**    are significant as generator name and are copied into the global
**    array Gen[]. All other characters are discarded.
*/
static void     Generator(void) {

	int     i;

	for (i = 0; i < 127 && (isalnum(Ch) || Ch == '_' || Ch == '.'); i++) {
		Gen[i] = Ch;
		ReadCh();
	}
	Gen[i] = '\0';
	/* Discard the rest. */
	while (isalnum(Ch) || Ch == '_' || Ch == '.') ReadCh();
}

/*
**    NextToken reads the next token from the input stream. It first
**    skips all the blank characters and comments.
*/
static void NextToken(void) {
	SkipBlanks();
	TChar = Char;
	TLine = Line;
	switch (Ch) {
	case '(':
	{ Token = LPAREN; ReadCh(); break; }
	case ')':
	{ Token = RPAREN; ReadCh(); break; }
	case '[':
	{ Token = LBRACK; ReadCh(); break; }
	case ']':
	{ Token = RBRACK; ReadCh(); break; }
	case '{':
	{ Token = LBRACE; ReadCh(); break; }
	case '}':
	{ Token = RBRACE; ReadCh(); break; }

	case '*':
	{ Token = MULT;   ReadCh(); break; }
	case '^':
	{ Token = POWER;  ReadCh(); break; }
	case ':': {
		ReadCh();
		if (Ch != '=') SyntaxError("illegal character");
		Token = DEQUALL;
		ReadCh();
		break;
	}
	case '=': {
		ReadCh();
		if (Ch != ':') Token = EQUAL;
		else { Token = DEQUALR; ReadCh(); }
		break;
	}

	case '+':
	{ Token = PLUS;   ReadCh(); break; }
	case '-':
	{ Token = MINUS;  ReadCh(); break; }

	case '<':
	{ Token = LANGLE; ReadCh(); break; }
	case '>':
	{ Token = RANGLE; ReadCh(); break; }

	case '|':
	{ Token = PIPE;      ReadCh(); break; }
	case ',':
	{ Token = COMMA;     ReadCh(); break; }
	case ';':
	{ Token = SEMICOLON; ReadCh(); break; }

	case '0':
	case '1' :
	case '2' :
	case '3' :
	case '4' :
	case '5':
	case '6' :
	case '7' :
	case '8' :
	case '9' :
	{ Token = NUMBER; Number(); break; }
	default :
		if (isalnum(Ch) || Ch == '_' || Ch == '.')
		{ Token = GEN; Generator(); break; }
		else SyntaxError("illegal character");
	}
	/*      printf( "# NextToken(): %s\n", TokenName[Token] );*/
}

/*
**    ------------------------- PARSER ----------------------------
**    Here the third part of this file starts containing the parser.
**
**    This is the grammar that defines the syntax of a finite presentation.
**    Quoted items (except 'empty') are recognized by the scanner and returned
**    as so called tokens. The unquoted symbol | indicates alternatives.
**
**    presentation: '<' genlist '|' rellist '>' |
**                  '<' genlist ; genlist '|' rellist '>'
**
**    genlist:         'empty' | genseq
**    genseq:          'generator' | 'generator' ',' genseq
**
**    rellist:         'empty' | relseq
**    relseq:          relation | relation ',' relseq
**
**    relation:        word | word '=' word | word '=:' word | word ':=' word
**
**    word:            power | power '*' word
**
**    power:           atom '^' atom | atom '^' snumber | atom
**
**    atom:            'generator' | '(' word ')' | commutator
**
**    commutator:      '[' word ',' wordseq ']'
**    wordseq          word | word ',' wordseq
**
**    snumber:         'sign' 'number' | 'number'
*/

/*
**    InitParser() does exactly what the name suggests.
*/
static void InitParser(FILE *fp, const char *filename) {
	InFp = fp;
	InFileName = filename;

	Ch = '\0';
	Char = 0;
	Line = 1;

	NextToken();
}

/*
**    Snumber() reads a signed number. The defining rule is:
**
**    snumber:         '+' 'number' | '-' 'number' | 'number'
*/
static node     *Snumber(void) {

	node    *n;

	if (Token == NUMBER) {
		n = GetNode(TNUM);
		n->cont.n = N;
		NextToken();
	} else if (Token == PLUS) {
		NextToken();
		if (Token != NUMBER) SyntaxError("Number expected");
		n = GetNode(TNUM);
		n->cont.n = N;
		NextToken();
	} else if (Token == MINUS) {
		NextToken();
		if (Token != NUMBER) SyntaxError("Number expected");
		n = GetNode(TNUM);
		n->cont.n = -N;
		NextToken();
	} else SyntaxError("Number expected");

	return n;
}

/*
**    The defining rules for commutators are:
**
**    commutator:      '[' word ',' wordseq ']'
**                   | '[' word ',' 'number' word ]
**    wordseq          word | word ',' wordseq
**
**    A word starts either with 'generator', with '(' or with '['.
*/
static node     *Commutator(void) {

	node            *n, *o;

	if (Token != LBRACK)
		SyntaxError("Left square bracket expected");

	NextToken();
	if (Token != GEN && Token != LPAREN && Token != LBRACK)
		SyntaxError("Word expected");

	o = Word();
	if (Token != COMMA) SyntaxError("Comma expected");
	while (Token == COMMA) {
		NextToken();
		if (Token != GEN && Token != NUMBER &&
		        Token != LPAREN && Token != LBRACK)
			SyntaxError("Word expected");

		if (Token == NUMBER) {
			/* An Engel relation is on the input stream. */
			n = GetNode(TENGEL);
			n->cont.op.l = o;

			if (N <= 0) SyntaxError("Engel-n must be positive");

			n->cont.op.e = GetNode(TNUM);
			n->cont.op.e->cont.n = N;
			NextToken();

			n->cont.op.r = Word();
			break;
		} else {
			n = GetNode(TCOMM);
			n->cont.op.l = o;
			n->cont.op.r = Word();
			o = n;
		}
	}
	if (Token != RBRACK) SyntaxError("Right square bracket missing");
	NextToken();
	return n;
}

/*
**    Atom() reads an atom. Note that Atom() creates a generator by
**    calling GenNumber().
**
**    The defining rule for atoms is:
**
**    atom:            'generator' | '(' word ')' | commutator
*/
static node     *Atom(void) {

	node            *n;

	if (Token == GEN) {
		n = GetNode(TGEN);
		n->cont.g = GenNumber(Gen, NOCREATE);
		if (n->cont.g == (gen)0) SyntaxError("Unkown generator");
		NextToken();
	} else if (Token == LPAREN) {
		NextToken();
		n = Word();
		if (Token != RPAREN)
			SyntaxError("Closing parenthesis expected");
		NextToken();
	} else if (Token == LBRACK) {
		n = Commutator();
	} else {
		SyntaxError("Generator, left parenthesis or commutator expected");
	}
	return n;
}

/*
**    Power() reads a power. The defining rule is:
**
**    power:           atom | atom '^' atom | atom '^' snumber |
**
*/
static node     *Power_(void) {

	node    *n, *o;

	o = Atom();
	if (Token == POWER) {
		NextToken();
		if (Token == PLUS || Token == MINUS || Token == NUMBER) {
			n = o;
			o = GetNode(TPOW);
			o->cont.op.l = n;
			o->cont.op.r = Snumber();
		} else {
			n = o;
			o = GetNode(TCONJ);
			o->cont.op.l = n;
			o->cont.op.r = Atom();
		}
	}
	return o;
}

/*
**    Word() reads a word. The defining rule is:
**
**    word:            power | power '*' word
**
**    A word starts either with 'generator', with '(' or with '['.
*/
static node *Word(void) {

	node    *n, *o;

	o = Power_();
	if (Token == MULT) {
		NextToken();
		n = o;
		o = GetNode(TMULT);
		o->cont.op.l = n;
		o->cont.op.r = Word();
	}

	return o;
}

/*
**    Relation() reads a relation. The defining rule is:
**
**    relation:        word | word '=' word | word '=:' word | word ':=' word
**
**    A relation starts either with 'generator', with '(' or with '['.
*/
static node     *Relation(void) {

	node    *n, *o;

	if (Token != GEN && Token != LPAREN && Token != LBRACK)
		SyntaxError("relation expected");

	o = Word();
	if (Token == EQUAL) {
		NextToken();
		n = o;
		o = GetNode(TREL);
		o->cont.op.l = n;
		o->cont.op.r = Word();
	} else if (Token == DEQUALL) {
		NextToken();
		n = o;
		o = GetNode(TDRELL);
		o->cont.op.l = n;
		o->cont.op.r = Word();
	} else if (Token == DEQUALR) {
		NextToken();
		n = o;
		o = GetNode(TDRELR);
		o->cont.op.l = n;
		o->cont.op.r = Word();
	}

	return o;
}

/*
**    RelList() reads a list of relations. The defining rules are:
**
**    rellist:         'empty' | relseq
**    relseq:          relation | relation ',' relseq
**
**    A relation starts either with 'generator', with '(' or with '['.
*/
static node     **RelList(void) {

	node     **rellist;
	unsigned n = 0;

	rellist = (node **)Allocate(sizeof(node *));
	rellist[0] = (node *)0;
	if (Token != GEN && Token != LPAREN && Token != LBRACK)
		return rellist;

	rellist = (node**)ReAllocate((void *)rellist, 2 * sizeof(node *));
	rellist[n++] = Relation();
	while (Token == COMMA) {
		NextToken();
		rellist = (node**)ReAllocate((void *)rellist, (n + 2) * sizeof(node *));
		rellist[n++] = Relation();
	}
	rellist[n] = (node *)0;

	return rellist;
}

/*
**    GenList() reads a list of generators.  The list of generators may
**    consist of abstract generators and identical generators.  Identical
**    generators are used to specify identical relations.
**
**    The defining rules are:
**
**    genlist:         'empty' | genseq | genseq ; genseq
**    genseq:          'generator' | 'generator' ',' genseq
*/
static int      GenList(void) {

	int     nrgens = 0;

	if (Token != GEN) return nrgens;

	nrgens++;
	if (GenNumber(Gen, CREATE) == (gen)0)
		SyntaxError("Duplicate generator");
	NextToken();
	while (Token == COMMA) {
		NextToken();
		if (Token != GEN) SyntaxError("Generator expected");
		nrgens++;
		if (GenNumber(Gen, CREATE) == (gen)0)
			SyntaxError("Duplicate generator");
		NextToken();
	}

	return nrgens;
}

/*
**    The following data structure holds a presentation.
*/
struct  pres {
	unsigned nragens;      /* number of abstract generators  */
	unsigned nrigens;      /* number of identical generators */
	unsigned nrrels;       /* number of relations            */
	node     **rels;       /* pointer to relations           */
};

static  struct pres Pres;

/*
**    NumberOfAbstractGens() returns the number of abstract generators.
*/
int     NumberOfAbstractGens(void) { return Pres.nragens; }

/*
**    NumberOfIdenticalGens() returns the number of identical generators.
*/
int     NumberOfIdenticalGens(void) { return Pres.nrigens; }

/*
**    NumberOfGens() returns the number of abstract and identical generators.
*/
int     NumberOfGens(void) { return Pres.nragens + Pres.nrigens; }

/*
**    NumberOfRels() returns the number of relations.
*/
int     NumberOfRels(void) { return Pres.nrrels; }

/*
**    NextRelation() returns the next relation, if it exists,
**    and returns the null pointer otherwise.
**    FirstRelation initializes the variable NextRel and calls
**    NextRelation().
**    NthRelation() returns the n-th relation, if n is in the
**    range [0..NumberOfRels()-1] and the null pointer otherwise.
**    CurrentRelation() returns the relation just being processed.
*/
static  int     NextRel;
node    *NextRelation(void) {

	if (NextRel >= NumberOfRels()) return (node *)0;

	return Pres.rels[NextRel++];
}

node    *FirstRelation(void) {

	NextRel = 0;
	return NextRelation();
}

node    *NthRelation(int n) {
	if (n < 0 || n >= NumberOfRels()) return (node *)0;

	return Pres.rels[n];
}

node    *CurrentRelation(void) { return Pres.rels[NextRel - 1]; }

/*
**    Presentation reads a finite presentation. The syntax of a presentation
**    is:
**        presentation: '<' genlist '|' rellist '>' |
**                      '<' genlist ; genlist '|' rellist '>'
*/
void    Presentation(FILE *fp, const char *filename) {
	InitParser(fp, filename);

	if (Token != LANGLE) SyntaxError("presentation expected");
	NextToken();

	if (Token != GEN && Token != PIPE)
		SyntaxError("generator or vertical bar expected");

	Pres.nragens = GenList();

	if (Token == SEMICOLON) {
		NextToken();
		Pres.nrigens = GenList();
	} else
		Pres.nrigens = 0;

	if (Token != PIPE) SyntaxError("vertical bar expected");
	NextToken();

	Pres.rels = RelList();
	Pres.nrrels = 0;
	while (Pres.rels[Pres.nrrels]) Pres.nrrels++;

	if (Token != RANGLE)
		SyntaxError("presentation has to be closed by '>'");
}

node    *ReadWord(void) {

	node    *n;

	if (Token != SEMICOLON) n = Word();
	else {
		NextToken();
		return ReadWord();
	}

	if (Token != SEMICOLON)
		SyntaxError("word has to be finished by ';'");

	return  n;
}

/*
**    ----------------------- EVALUATOR ------------------------
**    The fourth part of this file contains the evaluator.
*/
static EvalFunc EvalFunctions[TLAST];

void    SetEvalFunc(EvalType type, EvalFunc function) {
	if (type <= TNUM || type >= TLAST) {
		printf("Evaluation error: illegal type in SetEvalFunc()\n");
		exit(1);
	}

	EvalFunctions[type] = function;
}

void    *EvalNode(node *n) {
	void          *e, *l, *r;

	if (n->type == TNUM)
		return (void *) & (n->cont.n);

	switch (n->type) {
	case TGEN:                  /* TGEN is a unary node. */
		return WordGen(n->cont.g);

	case TCOMM:                 /* Adjust the class.     */
		Class--;
		l = EvalNode(n->cont.op.l);
		if (l != (void *)0) r = EvalNode(n->cont.op.r);
		Class++;

		if (l == (void *)0) return l;
		if (r == (void *)0) { Free(l); return r; }

		return WordComm((word)l, (word)r);

	case TENGEL:                /* TENGEL is a ternary node. */

		if ((e = EvalNode(n->cont.op.e)) == (void *)0) return e;

		Class -= *(int *)e;
		l = EvalNode(n->cont.op.l);
		if (l != (void *)0) r = EvalNode(n->cont.op.r);
		Class += *(int *)e;

		if (l == (void *)0) { Free(e); return l; }
		if (r == (void *)0) { Free(e); Free(l); return r; }

		return WordEngel((word)l, (word)r, (int *)e);

	default:

		if (EvalFunctions[n->type] == 0) {
			fprintf(stderr, "No evaluation function for type %d.\n", n->type);
			exit(5);
		}

		if ((l = EvalNode(n->cont.op.l)) == (void *)0) return l;
		if ((r = EvalNode(n->cont.op.r)) == (void *)0) {
			Free(l);
			return r;
		}

		return (*EvalFunctions[n->type])((word)l, r);
	}
}

static
void    TraverseNode(node *n, gen *igens) {
	if (n->type == TNUM) return;

	if (n->type == TGEN) {
		if (WordGen(n->cont.g) == (void *)0)

			igens[ n->cont.g - NumberOfAbstractGens() ] = 1;

		return;
	}

	TraverseNode(n->cont.op.l, igens);
	TraverseNode(n->cont.op.r, igens);
}

int  NrIdenticalGensNode = 0;
gen  *IdenticalGenNumberNode = 0;

int  NumberOfIdenticalGensNode(node *n) {
	gen  g,  nr;

	if (IdenticalGenNumberNode != (gen *)0)
		Free(IdenticalGenNumberNode);

	IdenticalGenNumberNode =
	    (gen *)Allocate((NumberOfIdenticalGens() + 1) * sizeof(gen));

	TraverseNode(n, IdenticalGenNumberNode);

	for (nr = 0, g = 1; g <= NumberOfIdenticalGens(); g++)
		if (IdenticalGenNumberNode[ g ] == 1)
			IdenticalGenNumberNode[ g ] = ++nr;

	NrIdenticalGensNode = nr;
	return nr;
}

void    **EvalRelations(void) {

	void     **results;
	unsigned r;

	results = (void **)Allocate((Pres.nrrels + 1) * sizeof(void *));
	for (r = 0; r < Pres.nrrels; r++)
		results[r] = EvalNode(Pres.rels[r]);

	results[r] = (void *)0;
	return results;
}

/*
**    ----------------------- PRINTING ------------------------
**    And the last part contains the print functions.
*/

/*
**    PrintNum() prints an integer.
*/
static void     PrintNum(int n) {
	fprintf(OutFp, "%d", n);
}

/*
**    PrintGen() prints a generator.
*/
void    PrintGen(gen g) {
	fprintf(OutFp, "%s", GenName(g));
}

/*
**    PrintComm() prints a commutator using the following rule for
**    left normed commutators :
**                              [[a,b],c] = [a,b,c]
*/
static void     PrintComm(node *l, node *r, int bracket) {
	if (bracket) fprintf(OutFp, "[");

	/* If the left operand is a commutator, don't print its brackets. */
	if (l->type == TCOMM)
		PrintComm(l->cont.op.l, l->cont.op.r, 0);
	else
		PrintNode(l);

	fprintf(OutFp, ",");
	PrintNode(r);

	if (bracket) fprintf(OutFp, "]");
}

/*
**    PrintEngel() prints a commutator using the following rule for
**    Engel relations:
**                              [u, n v]
*/
static void     PrintEngel(node *l, node *r, node *e) {
	fprintf(OutFp, "[");
	PrintNode(l);
	fprintf(OutFp, ", ");
	PrintNode(e);
	fprintf(OutFp, " ");
	PrintNode(r);
	fprintf(OutFp, "]");
}

/*
**    PrintMult() prints a product. It is not necessary to check if
**    parentheses have to be printed since '*' has the lowest precedence
**    of all operators except '='. But '=' can only occur at the top of
**    an expression tree.
*/
static void     PrintMult(node *l, node *r) {
	PrintNode(l);
	fprintf(OutFp, "*");
	PrintNode(r);
}

/*
**    PrintPow() prints an expression raised to an integer. If the expression
**    is a product, it has to be enclosed in parentheses because of the lower
**    precedence of '*'. If the expression is again a power or a conjugation,
**    it has to be enclosed in parenthesis because '^' is not an associative
**    operator.
*/
static void     PrintPow(node *l, node *r) {
	if (l->type == TPOW || l->type == TCONJ || l->type == TMULT) {
		putc('(', OutFp);
		PrintNode(l);
		putc(')', OutFp);
	} else
		PrintNode(l);

	putc('^', OutFp);
	if (r->type != TNUM) {
		fprintf(OutFp, "Fatal error in tree.\n");
		exit(5);
	}
	fprintf(OutFp, "%d", r->cont.n);
}

/*
**    PrintConj() prints an expression conjugated by another expression.
**    If one of the expressions is a product, a power or another conjugation,
**    it has to be enclosed in parentheses for the same reasons PrintPow()
**    has to enclose the basis in parentheses.
*/
static void     PrintConj(node *l, node *r) {
	if (l->type == TPOW || l->type == TCONJ || l->type == TMULT) {
		putc('(', OutFp);
		PrintNode(l);
		putc(')', OutFp);
	} else
		PrintNode(l);

	putc('^', OutFp);

	if (r->type == TPOW || r->type == TCONJ || r->type == TMULT) {
		putc('(', OutFp);
		PrintNode(r);
		putc(')', OutFp);
	} else
		PrintNode(r);
}

/*
**    PrintRel() prints a relation. No parenthesis are necessary since
**    '=' has the lowest precedence of all binary operators.
*/
static void     PrintRel(node *l, node *r) {
	PrintNode(l);
	fprintf(OutFp, " = ");
	PrintNode(r);
}

/*
**    PrintDRelL() prints a defining relation. No parenthesis are necessary
**    since '=:' has the lowest precedence of all binary operators.
*/
static void     PrintDRelL(node *l, node *r) {
	PrintNode(l);
	fprintf(OutFp, " := ");
	PrintNode(r);
}

/*
**    PrintDRelR() prints a defining relation. No parenthesis are necessary
**    since '=:' has the lowest precedence of all binary operators.
*/
static void     PrintDRelR(node *l, node *r) {
	PrintNode(l);
	fprintf(OutFp, " =: ");
	PrintNode(r);
}

/*
**    PrintNode() just looks at the type of a node and then calls the
**    appropriate print function.
*/
void    PrintNode(node *n) {
	switch (n->type) {
	case TNUM:
	{ PrintNum(n->cont.n); break; }
	case TGEN:
	{ PrintGen(n->cont.g); break; }
	case TMULT:
	{ PrintMult(n->cont.op.l, n->cont.op.r); break; }
	case TPOW:
	{ PrintPow(n->cont.op.l, n->cont.op.r); break; }
	case TCONJ:
	{ PrintConj(n->cont.op.l, n->cont.op.r); break; }
	case TCOMM:
	{ PrintComm(n->cont.op.l, n->cont.op.r, 1); break; }
	case TREL:
	{ PrintRel(n->cont.op.l, n->cont.op.r); break; }
	case TDRELL:
	{ PrintDRelL(n->cont.op.l, n->cont.op.r); break; }
	case TDRELR:
	{ PrintDRelR(n->cont.op.l, n->cont.op.r); break; }
	case TENGEL: {
		PrintEngel(n->cont.op.l, n->cont.op.r,
		           n->cont.op.e);
		break;
	}
	default:
	{ fprintf(OutFp, "\nunknown node type\n"); exit(5); }
	}
}

/*
**    PrintPresentation() prints the presentation stored in the global
**    variable Pres.
*/
void    PrintPresentation(FILE *fp) {
	gen     g;
	int     r;

	InitPrint(fp);

	if (Pres.nragens == 0) return;

	/* Open the presentation. */
	fprintf(OutFp, "< ");

	/* Print the generators first. */
	PrintGen(1);
	for (g = 2; g <= (gen)Pres.nragens; g++) {
		fprintf(OutFp, ", ");
		PrintGen(g);
	}

	if (Pres.nrigens > 0) {
		fprintf(OutFp, "; ");
		PrintGen(Pres.nragens + 1);
		for (g = Pres.nragens + 2; g <= (gen)(Pres.nragens + Pres.nrigens); g++) {
			fprintf(OutFp, ", ");
			PrintGen(g);
		}
	}

	/* Now the delimiter. */
	fprintf(OutFp, " |\n");

	/* Now the relations. */
	if (Pres.rels[0] != (node *)0) {
		fprintf(OutFp, "    ");
		PrintNode(Pres.rels[0]);
	}
	for (r = 1; Pres.rels[r] != (node *)0; r++) {
		fprintf(OutFp, ",\n    ");
		PrintNode(Pres.rels[r]);
	}

	/* And close the presentation. */
	fprintf(OutFp, " >\n");
}

void    InitPrint(FILE *fp) {
	OutFp = fp;
	OutFileName = "";
}
