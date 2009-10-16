/********************************************************************/
/*                                                                  */
/*  Module        : LEX input                                       */
/*                                                                  */
/*  Description :                                                   */
/*     Scanner specification for flex/lex                           */
/*                                                                  */
/********************************************************************/

/*	$Id: sisscan.l,v 1.1 2000/10/23 17:05:03 gap Exp $	*/
/*	$Log: sisscan.l,v $
/*	Revision 1.1  2000/10/23 17:05:03  gap
/*	initial checkin of the original version,
/*	before changing the GAP 3 interface in a few src files
/*	to a GAP 4 interface
/*	
/*	    TB
/*	
 *	Revision 3.2  1995/08/14 14:45:18  pluto
 *	Added dummy 'yywrap' function to avoid use of 'libfl'.
 *
 *	Revision 3.1  1995/06/29 09:51:08  pluto
 *	Added 'id' token.
 *
 *	Revision 3.0  1995/06/23 16:47:31  pluto
 *	New revision corresponding to sisyphos 0.8.
 *	Removed function and procedure names.
 *
 * Revision 1.7  1995/03/20  09:45:06  pluto
 * Added support for GNU readline.
 *
 * Revision 1.6  1995/01/11  15:58:56  pluto
 * Added new functions griso and grauto.
 *
 * Revision 1.5  1995/01/09  12:03:12  pluto
 * Moved rule for "1".
 *
 * Revision 1.4  1995/01/09  11:57:11  pluto
 * Added support for new lifting routine.
 *
 * Revision 1.3  1995/01/07  17:27:44  pluto
 * Corrected comment syntax.
 *
 * Revision 1.2  1995/01/05  17:34:10  pluto
 * Initial version under RCS control.
 *	*/

%{
#include "config.h"
#include "aglobals.h"
#include <stdlib.h>
#include "error.h"
#include "dispatch.h"
#include "graut.h"
#include "aut.h"
#ifdef UNIX
#include "sisgram.tab.h"
#else
#include "sisgram_.h"
#endif

# include	"parsesup.h"

extern int nl_count;
extern int read_group_el;
extern int use_prompt1;
static int read_from_file = FALSE;

void show_prompt		_(( void ));
void put_back			_(( char c ));
char *do_gets            _(( char *buf, int max_size  ));

#undef YY_INPUT
#ifdef HAVE_LIBREADLINE
#define YY_INPUT(buf,result,max_size) \
	{if ( (read_from_file ? fgets( (char *) buf, max_size, yyin ) :\
	    do_gets ( buf, max_size )) == NULL ) \
		if ( feof ( yyin ) ) \
			result = YY_NULL;\
		else \
			YY_FATAL_ERROR( "read() in flex scanner failed" ); \
	else { \
		result = strlen ( buf ); \
  	}}
#else
#define YY_INPUT(buf,result,max_size) \
        { if ( !read_from_file ) show_prompt(); \
        if ( (fgets( (char *) buf, max_size, yyin )) == NULL ) \
                if ( feof ( yyin ) ) \
                        result = YY_NULL;\
                else \
                        YY_FATAL_ERROR( "read() in flex scanner failed" ); \
        else { \
                result = strlen ( buf ); \
			 if ( result == 1 ) \
			      use_prompt1 = TRUE; \
        }}
#endif

#define MAX_INCLUDE_DEPTH 20
YY_BUFFER_STATE fstack[MAX_INCLUDE_DEPTH];
int fstack_ptr = 0;

%}
white		[\t\n\r\\ ]
ngens		[A-F]
cgens		[a-f]
digit		[0-9]
digseq		{digit}+
string		\"[^\n\r\"]+\"
any			[^a-zA-Z0-9]
%x prel
%x comment
%s wprel
%x rfile rfile1 rfile2 rfile3 rfile4
%x bfile bfile1 bfile2 bfile3

%%
	static int yy_eq = 0;
	static int i;
	static int filepos;
	static int read_rel_file = FALSE;
	static char yystring[256];
	static char yyfile[50];
	static FILE *yy_t_in;

{white}+			; 
"#"				BEGIN(comment);
<comment>[^\n]*	/* eat up */
<comment>\n		BEGIN(INITIAL);

"comm"			{ return COMMUT; }
"I"				{ return IDEAL; }
("mod"|"modulo")    { return MOD; }
"seq"               { return SEQ; }
("matrix"|"mat")    { return MATRIX; }
("regular"{white}+"representation"|"regular")	{yylval.ival = 0; return NUMBER; }
"true"			               { yylval.ival = TRUE; return NUMBER; }
"false"			               { yylval.ival = FALSE; return NUMBER; }
"all"			               { yylval.ival = ALL; return NUMBER; }
"outer"			               { yylval.ival = OUTER; return NUMBER; }
"id"			                    { yylval.ival = 0; return NUMBER; }
"memory"			               { yylval.ival = MEMORY; return NUMBER; }
"prompt"			               { yylval.ival = PROMPT; return NUMBER; }
"flags"			               { yylval.ival = FLAGS; return NUMBER; }
"prime"			               { yylval.ival = PRIME; return NUMBER; }
"end"		                    { yylval.ival = END; return NUMBER; }
"cut"			               { yylval.ival = CUT; return NUMBER; }
"version"			               { yylval.ival = VERSION; return NUMBER; }
"symbols"			               { yylval.ival = SYMBOLS; return NUMBER; }
"multiplication"{white}+"table"	{ yylval.ival = MTABLE; return NUMBER; }
"jennings"{white}+"table"		{ yylval.ival = JTABLE; return NUMBER; }
"grpautos"		               { yylval.ival = GRPAUTOS; return NUMBER; }
"nogrpautos"		               { yylval.ival = NOGRPAUTOS; return NUMBER; }
"on"				               { yylval.ival = ON; return NUMBER; }
"off"			               { yylval.ival = OFF; return NUMBER; }
("full"|"maximal")	               { yylval.ival = FULL; return NUMBER; }
"small"			               { yylval.ival = SMALL; return NUMBER; }
"verbosity"		               { yylval.ival = VERBOSE; return NUMBER; }
"displaystyle"		               { yylval.ival = DISSTYLE; return NUMBER; }
"gap"					     { yylval.ival = GAP; return NUMBER; }
"sisyphos"		               { yylval.ival = SISYPHOS; return NUMBER; }
"cayley"			               { yylval.ival = CAYLEY; return NUMBER; }
"left"			               { yylval.ival = 1; return NUMBER; }
"right"			               { yylval.ival = 0; return NUMBER; }
"twoside"d?			          { yylval.ival = 2; return NUMBER; }
"images"			               { yylval.ival = IMAGES; return NUMBER; }
"permutations"		               { yylval.ival = PERMUTATIONS; return NUMBER; }
"binaryp"			               { yylval.ival = BINARYP; return NUMBER; }
"cycles"			               { yylval.ival = CYCLES; return NUMBER; }
"none"			               { yylval.ival = NONE; return NUMBER; }
("standard"{white}+"base"|"sbase") { yylval.ival = SBASE; return NUMBER; }
("quit"|"exit")	{ return QUIT; }
"meet"			{ return '*'; }
"join"			{ return '+'; }

"group"			{ return DEFGRP; }
"pcgroup"			{ return DEFPCGRP; }
"aggroup"			{ return DEFAGGRP; }

"actual"			{ return ACTUAL; }

"minimal"						{ return MINIMAL; }
("gen"|"gens"|"generators")		{ BEGIN(prel); return GENS; }
<prel>("rel"|"rels"|"relations")	{ return RELS; }
<prel>[A-Za-z][A-Za-z0-9_.]*		{ yy_eq = 0;
							yylval.gval = tallocate ( sizeof ( GENVAL ) ); 
							yylval.gval->pval = tallocate ( yyleng+1 );
							strncpy ( (char *)yylval.gval->pval, yytext, yyleng );
							((char *)yylval.gval->pval)[yyleng] = '\0';
							return GEN; }
<prel>";"						{ BEGIN(INITIAL);
							if ( read_rel_file ) {
								if ( --fstack_ptr == 0 )
									read_from_file = FALSE;
								fclose ( yyin );
								yy_switch_to_buffer ( fstack[fstack_ptr] );
								read_rel_file = FALSE;
							}
							else
								unput (';'); }
<prel>{white}+					;
<prel>{digseq}					{ yylval.ival = atoi ( yytext );
								if ( yylval.ival == 1 && yy_eq == 1 ) {
									yy_eq = 0;
									return ID;
								}
								else {
									yy_eq = 0;
									return NUM;

							} }
<prel>","{white}+"weights"		{ BEGIN(wprel); return WEIGHTS; }
<prel>"="						{ yy_eq = 1; return yytext[0]; }
<prel>{any}					{ return yytext[0]; }

<wprel>")"					{ BEGIN(prel); return yytext[0]; }

"readautgroup"					{ return READAUTGRP; }
"readgroup"					{ BEGIN(rfile); yyfile[0] = '\0'; return READGRP; }
"readpcgroup"					{ BEGIN(rfile); yyfile[0] = '\0'; return READPCGRP; }
"readaggroup"					{ BEGIN(rfile); yyfile[0] = '\0'; return READAGGRP; }
<rfile,rfile1,rfile2,rfile3,rfile4>{white}+			; 
<rfile>"("					{ BEGIN(rfile1); return '('; }
<rfile>[^(\t\n\r ]				{ BEGIN(INITIAL); return '$'; }
<rfile1>{digseq}				{ BEGIN(rfile2); yylval.ival = filepos = atoi ( yytext );
							return NUMBER; }
<rfile1>[^0-9\t\n\r ].*			{ BEGIN(INITIAL); return '$'; }
<rfile2>","					{ BEGIN(rfile3); return ','; }
<rfile2>[^,\t\n\r ]				{ BEGIN(INITIAL); return '$'; }
<rfile3>{string}				{ BEGIN(rfile4); yylval.gval = tallocate ( sizeof ( GENVAL ) ); 
							yylval.gval->pval = tallocate ( yyleng-1 );
							strncpy ( (char *)yylval.gval->pval, yytext+1, yyleng-1 );
							((char *)yylval.gval->pval)[yyleng-2] = '\0';
							strcpy ( yyfile, (char *)yylval.gval->pval );
							return STRING; }
<rfile3>[^\"\t\n\r ].*			{ BEGIN(INITIAL); return '$'; }
<rfile4>")"					{ BEGIN(INITIAL);
							fstack[fstack_ptr++] = YY_CURRENT_BUFFER;
							if ( yyfile[0] != '\0' && (yy_t_in = fopen ( add_path ( "GROUPDSC", yyfile ), "r" )) != NULL ) {
								read_from_file = TRUE;
								yyin = yy_t_in;
								i = 0;
								do {
									fgets ( yystring, 256, yyin );
									if ( yystring[0] == '-' ) i++;
								} while ( i < filepos );
								yy_switch_to_buffer ( yy_create_buffer ( yyin, YY_BUF_SIZE ) );
								read_rel_file = TRUE;
								return ')';
							}
							else {
								yy_switch_to_buffer ( fstack[--fstack_ptr] );
								set_error ( FILE_OPEN_ERR );
								/* unput ( ';' ); */
								return '$';
							} }
<rfile4>[^)\t\n\r ]				{ BEGIN(INITIAL); return '$'; }

("execute"|"batch")				{ BEGIN(bfile); yyfile[0] = '\0'; return BATCH; }
<bfile,bfile1,bfile2,bfile3>{white}+		;
<bfile>"("					{ BEGIN(bfile1); return '('; }
<bfile>[^(\t\n\r ]				{ BEGIN(INITIAL); return '$'; }
<bfile1>{string}				{ BEGIN(bfile2);
							yylval.gval = tallocate ( sizeof ( GENVAL ) ); 
							yylval.gval->pval = tallocate ( yyleng-1 );
							strncpy ( (char *)yylval.gval->pval, yytext+1, yyleng-1 );
							((char *)yylval.gval->pval)[yyleng-2] = '\0';
							strcpy ( yyfile, (char *)yylval.gval->pval );
							return STRING; }
<bfile1>[^\"\t\n\r ].*			{ BEGIN(INITIAL); return '$'; }
<bfile2>")"					{ BEGIN(bfile3); return ')'; }
<bfile2>[^)\t\n\r ]				{ BEGIN(INITIAL); return '$'; }
<bfile3>";"					{ BEGIN(INITIAL);
							fstack[fstack_ptr++] = YY_CURRENT_BUFFER;
							if ( yyfile[0] != '\0' && (yy_t_in = fopen ( yyfile, "r" )) != NULL ) {
								yyin = yy_t_in;
								yy_switch_to_buffer ( yy_create_buffer ( yyin, YY_BUF_SIZE ) );
								read_from_file = TRUE;
								return ';';
							}
							else {
								yy_switch_to_buffer ( fstack[--fstack_ptr] );
								set_error ( FILE_OPEN_ERR );
								unput ( ';' );
								return '$';
							} }
<bfile3>[^;\t\n\r ]				{ BEGIN(INITIAL); return '$'; }

<<EOF>>						{ if ( --fstack_ptr == 0 )
								read_from_file = FALSE;
							fclose ( yyin );
							yy_switch_to_buffer ( fstack[fstack_ptr] );
							}


"1"							{ if ( read_group_el ) {
								yylval.ival = -1;
								return GRGEN;
							}
							else {
								yylval.ival = 1;
								return NUMBER;
							}
							}
{digseq}						{ yylval.ival = atoi ( yytext );  return NUMBER; }
\"[^\n\r\"]+\"					{ yylval.gval = tallocate ( sizeof ( GENVAL ) );
							yylval.gval->pval = tallocate ( yyleng-1 );
							strncpy ( (char *)yylval.gval->pval, yytext+1, yyleng-1 );
							((char *)yylval.gval->pval)[yyleng-2] = '\0';
							return STRING; }

[a-z][a-z0-9_]*				{ if ( (i=findcgen ( yytext, yyleng) ) == -1 ) {
								yylval.gval = tallocate ( sizeof ( GENVAL ) );
								yylval.gval->pval = tallocate ( yyleng );
								strcpy ( (char *)yylval.gval->pval, yytext );
								return IDENTIFIER;
							}
							else {
								yylval.ival = i;
								if ( read_group_el )
									return GRGEN;
								else
									return CGEN;
							}
							}
[A-Z][A-Z0-9_]*					{ if ( (i=findcgen ( yytext, yyleng) ) == -1 ) {
								yylval.gval = tallocate ( sizeof ( GENVAL ) );
								yylval.gval->pval = tallocate ( yyleng );
								strcpy ( (char *)yylval.gval->pval, yytext );
								return IDENTIFIER;
							}
							else {
								yylval.ival = i;
								if ( read_group_el )
									return GRGEN;
								else
									return NGEN;
							}
							}
[A-Za-z$_][A-Za-z0-9$_]*			{ yylval.gval = tallocate ( sizeof ( GENVAL ) );
							yylval.gval->pval = tallocate ( yyleng );
							strcpy ( (char *)yylval.gval->pval, yytext );
							return IDENTIFIER; }
								
{any}						{ return yytext[0]; }

%%

void put_back ( char c )
{
	unput ( c );
}
						
int yywrap ( void )
{
    return ( 1 );
}
