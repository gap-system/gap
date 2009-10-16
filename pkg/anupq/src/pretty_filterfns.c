/****************************************************************************
**
*A  pretty_filterfns.c          ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: pretty_filterfns.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pretty_filterfns.h"
#include "constants.h"

/* filter functions to process "pretty" presentation input; 
   this code was written and supplied by Sarah Rees */

int num_gens=0;
gen_type * inv_of=0;
word * user_gen_name=0;
int gen_array_size=53;
int * pairnumber=0;
int paired_gens;

pc_word_init (wp) 
word *wp; 
{ 
   wp->g =valloc(gen_type,16); 
   wp->first = 0;
   wp->last = -1;
   wp->space = 16;
   wp->type = 0;                /* later set as 's' or 'c' */
   wp->n = 1;                   /* only one for trivial or unexpanded words. After initialisation
				   this is set to 0 if the word is not a proper power, and to the power otherwise.
				   */
} 

word_init (wp)
word * wp;
{
   wp->g =valloc(gen_type,16); 
   wp->first = 0;
   wp->last = -1;
   wp->space = 16;
   wp->type = 's'; 
   wp->n = 0; 
} 

/* Clear space allocated to a word.
The space assigned to a word (as a pointer to generators) is cleared.
*/
word_clear (wp) 
    word * wp; 
{ 
   free((char*)wp->g); wp->g = 0; 
} 

pc_word_reset (wp) 
  word *wp; 
{ 
   wp->last = wp->first - 1;
   wp->type = 0;
   wp->n = 1;
} 

word_reset (wp) 
  word *wp; 
{ 
   wp->last = wp->first - 1;
} 

/* 
The word |*wp| has certainly been initialized, and may already contain a
non-trivial word. But the information it contains, if any, is redundant, and
can be thrown away. We just require the space for new information but there
may not be enough of it. If the word currently contains space for less than
n generators we increase the amount of space to this. We set the position
for the first word entry at a, and the last at a-1 (since at this stage the
word is empty).  
*/
word_stretch_reset (wp,N,a) 
  word *wp;
  int N;
  int a;
{
   if (wp->space < N) {
      free((char*) wp->g); wp->g = 0; 
      wp->g = valloc(gen_type,N); 
      wp->space = N;
   }
   wp->first = a;
   wp->last = a - 1;

}


/* Initialize a |word_traverser| to make it traverse a particular
word, whose address is given in the second argument.
*/
word_traverser_init (wtp,wp)
  word_traverser *wtp; 
  word *wp; 
{ 
   wtp->wp = wp; 
   wtp->posn = wp->first;
} 

word_link * word_link_create ()
{
   word_link * wlp = valloc(word_link,1);
   wlp->wp=0; wlp->next=0;
   return wlp;
}

word_link_init (wlp)
  word_link * wlp;
{
   wlp->wp = valloc(word,1);
   word_init (wlp->wp);
   wlp->next = word_link_create ();
}

word_link_clear (wlp)
  word_link * wlp;
{
   word_clear (wlp->wp);
   free((char *)(wlp->wp));
}


/* |word_get_first ()| gets hold of the first generator in a word without
changing it. It returns |1| provided the word is non-trivial, |0| 
otherwise.
The  pointer |gp| is set to point to the first generator in the word pointed
to by |wp|.
*/
char
word_get_first (wp,gp) 
  word *wp; 
  gen_type *gp; 
{ 
   if (wp->first <= wp->last) {
      *gp = (wp->g)[wp->first];
      return 1;
   }
   else {
      *gp = 0;
      return 0; 
   }
} 

/* |word_next ()| is used when traversing a word, generator by generator. It
returns |1| while the |list_traverser| points to a generator, |0| 
once the last generator in the word has been passed.
The  pointer |gp| is set to point to the generator at which the
|word_traverser| is currently positioned..
The procedure does not change the word being traversed.
*/
char
word_next (wtp,gp) 
  word_traverser *wtp; 
  gen_type *gp; 
{ 
   if (wtp->posn <= wtp->wp->last) {
      *gp = (wtp->wp->g)[wtp->posn]; 
      wtp->posn++;
      return 1; 
   } 
   else {
      *gp = 0;
      return 0; 
   }
} 



/* Construct the inverse of a word.
If a word is read as a sequence of generators the inverse word consists of
the string of the inverses of these generators, but in the reverse order.
Before the function is applied |*inverse| could be a freshly initialized word or
an actual word already in use. It might be the same word as |*given|.
 Space is assigned or reassigned as necessary
within this function.
*/
word_inv (given, inverse)
  word *given, *inverse; 
{
   int i;
   int j;
   gen_type * gp=0;
   gp = valloc(gen_type,given->space);
   for (i=given->first,j=given->last;i<=given->last;i++,j--)
      gp[i] = inv(given->g[j]);  
   inverse->space=given->space;
   inverse->first=given->first;
   inverse->last = given->last;
   free((char*)inverse->g);inverse->g=0;
   inverse->g = gp;
}

word_put_last (wp,g) 
  word *wp; 
  gen_type g; 
{ 
   int i;
   int n;
   n=wp->space;
   if (wp->last == n - 1){      /* there's an entry in the rightmost
				   piece of space */
      if (wp->first>n/2) {
	 int k;
	 k=n/4;
	 wp->first -=k;
	 wp->last -=k;
	 for (i=wp->first;i<=wp->last;++i)
	    wp->g[i]=wp->g[i+k];
      }
      else
	 word_double (wp);
   }
   (wp->last)++;
   wp->g[wp->last] = g;
}   

/*Adding on a generator to the left hand end of a word (left
multiplication).
*/
word_put_first (wp,g) 
  word *wp; 
  gen_type g; 
{ 
   if (wp->first == 0) {
      int i;
      int n;  
      n = wp->space;
      if (wp->last<=n/2) {
	 int k;
	 k=n/4;
	 wp->first +=k;
	 wp->last +=k;
	 for (i=wp->last;i>=wp->first;--i)
	    wp->g[i]=wp->g[i-k];
      }
      else  
	 word_double (wp);
   }
   (wp->first)--;
   wp->g[wp->first] = g;
}   

/* Double the amount of space available to a word, while preserving the
information stored in the word.
*/
word_double (wp)
  word * wp;
{
   int n;
   int k;
   int i;
   gen_type * gp;
   n = wp->space;
   k = n/2;
   gp = valloc(gen_type,2*n);
   for (i=k;i<3*k;++i) 
      gp[i] = (wp->g)[i-k];
   free((char*)wp->g); wp->g=0;
   wp->g = gp;
   wp->space *= 2 ;
   wp->first += k;
   wp->last += k; 
}

/*Get the first generator out of a word, and at the same time delete it from 
that word. 
The function returns |0| if the word is trivial, |1| otherwise.
*/
char
word_delget_first (wp,gp) 
  word *wp; 
  gen_type *gp; 
{ 
   if (wp->first > wp->last) {
      *gp = 0;
      return 0;
   }
   else {
      *gp =  wp->g[wp->first++];
      return 1; 
   } 
} 
    
/* Delete the last generator in a word.
The function returns |0| if the word is trivial, |1| otherwise.
*/
char
word_del_last (wp) 
  word *wp; 
{
   if (wp->first > wp->last) 
      return 0;
   else  {
      wp->last--;
      return 1; 
   }
} 

/* Concatenate two words.
|wp1|, |wp2| and |wp3| are pointers to initialized words. |*wp1| and |*wp2| are
not changed by this procedure (provided that they are both distinct from
|*wp3|). At the end |*wp3| contains the concatenation
of |*wp1| and |*wp2|.
*/
word_concat (wp1,wp2,wp3) 
  word *wp1, *wp2, *wp3; 
{ 
   int n1,n2,n; 
   int N;
   int i;
   gen_type *factor,*concat; 

   n1 = word_length(wp1);
   n2 = word_length(wp2);
   n = n1 + n2;
   if (n<=0){
      wp3->last = wp3->first -1;
      return;
   } /* avoid malloc()ing 0 bytes */
   concat = valloc(gen_type,n); 
   factor = wp1->g + wp1->first; 
   for (i=0;i<n1;i++)
      concat[i] = factor[i];
   factor = wp2->g + wp2->first; 
   for (i=n1;i<n;i++)
      concat[i] = factor[i-n1]; 
   N = wp1->space>wp2->space? wp1->space:wp2->space;
   while (N<2*n)
      N *=2;
   word_stretch_reset (wp3,N,n/2);
   for (i=0;i<n;++i)
      wp3->g[wp3->first + i] = concat[i];
   wp3->last = wp3->first + n - 1;
   free((char*)concat); concat = 0;
}   

word_append (wp1,wp2)
  word * wp1, * wp2;
{
   int N = wp1->space;
   int last = wp1->last;
   int n2 = (wp2->last) - (wp2->first) + 1;
   int i;
   gen_type * genp1, * genp2, * genp3;
   while (N - 1 - last <= n2)
      N *= 2;
   if (N > wp1->space){
      gen_type * genp=vzalloc(gen_type,N);
      for (i=wp1->first;i<=last;i++)
	 genp[i]=(wp1->g)[i];
      free((char*)(wp1->g));
      wp1->g = genp;
      wp1->space = N;
   }
   genp1 = (wp1->g) + last;
   genp3 = genp1 + n2;
   genp2 = (wp2->g) + (wp2->first);
   while (++genp1<=genp3) *genp1 = *(genp2++);
   wp1->last += n2;
}


char
word_eq (w1p,w2p)
  word * w1p, * w2p;
{
   int m;
   if ((m=((w1p->last) - (w1p->first))) != ((w2p->last) - (w2p->first)))
      return 0;
   else if (m>=0){
      int i;
      gen_type * g1p = w1p->g + w1p->first;
      gen_type * g2p = w2p->g + w2p->first;
      for (i=0;i<=m;i++)
	 if (g1p[i]!=g2p[i])
	    return 0;
   }
   return 1;
}


word_cpy (oldwp,newwp) 
  word * oldwp, * newwp;
{ 
   int m;
   int n;
   int i;
   gen_type *newgp, *oldgp; 

   newwp->type = oldwp->type;
   newwp->n = oldwp->n;
    
   m = word_length(oldwp); 
   if ((n=newwp->space) < 2*m) {
      while (n<2*m)
	 n *= 2;
      free((char*)(newwp->g)); newwp->g = 0; 
      newwp->g = valloc(gen_type,n); 
      newwp->space = n;
   }
   newwp->first = m/2;
   newwp->last = newwp->first+m-1;
   newgp = newwp->g + newwp->first; 
   oldgp = oldwp->g + oldwp->first; 
   for (i=0;i<m;++i)
      newgp[i]=oldgp[i];
} 

char read_next_gen (wp,file)
  word * wp;
  FILE * file;
{
   char ans=1;
   int c;
   word_reset (wp);
   while ((c=read_char (file))!=EOF && !(isalpha(c))){
      if (c=='$') 
	 return 1;
      if (c=='}') {
	 /* a '}' is used to terminate the input of gens */
	 ungetc('}',file);
	 ans = 0;
	 break;
      }
      else if (c!=' ' && c!=','){
	 fprintf(stderr,"Generators must start with a letter.\n");
	 bad_data ();
      }
   }
   if (c==EOF){
      fprintf(stderr,"Unexpected end of file.\n");
      bad_data ();
   }
   if (ans==1){
      do {
	 if (c==EOF)
	    break;
	 if (c=='^'){
	    int d,e;
	    d=read_char (file); e=read_char (file);
	    if (d!='-' || e!='1'){
	       fprintf(stderr,
		       "Invalid generator name.\n");
	       bad_data ();
	    }
	    word_put_last (wp,c);
	    word_put_last (wp,d);
	    word_put_last (wp,e);
	    c=read_char (file);
	    break;
	 }
      
	 if (!isalpha(c) && !isdigit(c) && c!='_' && c!='.'){
	    fprintf(stderr,
		    "Only letters, digits, underscores and .'s are allowed in generator names.\n");
	    bad_data ();
	 }
	 word_put_last (wp,c);
	 c = read_char (file);
      } while (isalpha(c) || isdigit(c)
	       ||c=='^'||c=='-'||c=='_'||c=='.');
      if (c!=EOF && c!= ' ')
	 ungetc(c,file);
   }
   return ans;
}

char read_next_word (wp,file)
  word * wp;
  FILE * file;
{
   /*
     A word is recognisable as a power of a single commutator iff
     a) the first symbol after any number of ('s is a [ and
     b) it contains no *'s, no ['s or ^'s inside the []'s, and only ('s, )'s ^'s -'s
     and digits outside.
     wp->type is initialised as 0, then we reset it
     when we encounter the first symbol that is not a (. If set to
     c it will be reset to s once an inappropriate symbol is encountered.
     is encountered .
     A word is recognised as a power if it contains no *'s
     unless enclosed by ()'s. wp->n is reset to 0 as soon
     as such a '*' is encountered.
     */
   char ans=1;
   int c;
   word_reset (wp);
   while ((c=read_char (file))!=EOF && !(isalpha(c)) &&!(isdigit(c))&&
	  c!='(' && c!='['){
      if (c=='$') 
	 return 1;
      if (c=='}') {
	 /* a '}' is used to terminate the input of words */
	 ungetc('}',file);
	 ans = 0;
	 break;
      }
   }
   if (c==EOF){
      fprintf(stderr,"Unexpected end of file.\n");
      bad_data ();
   }
   if (ans==1 && c=='1') return ans;
   /* 1 is used to represent the identity. It will only be the first symbol in a 
      word when it's the whole word. */
   if (ans==1){
      gen_type separator = '*'; 
      char bracket_level=0;
      char comm_level=0;
      do {
	 if (c==EOF)
	    break;
	 if (c==' '||(c==','&&comm_level==0)){
	    /* if this happens, the previous character must have been an
	       alphanumeric character or a ), and we are not within commutators (since 
	       spaces after ^,( and * and inside commutators are dealt with
	       elsewhere). If the next non-space character is not *,^ or ) we must have
	       reached the end of the word. */
	    do {
	       c=read_char (file);
	       if (c==EOF) break;
	    } while (c==' ');
	    if (c==EOF||(c!='^'&&c!='*'&&c!=']'&&c!=')')) 
	       break; /* we have got to the end of the word */
	 }
	 if (c=='['){
	    comm_level++;
	    if (wp->type!=0) wp->type = 's';
	    if (wp->type==0) wp->type = 'c';
	 }
	 else if (c==']')
	    comm_level--;  
	 else if (c=='(')
	    bracket_level++;
	 else if (c==')')
	    bracket_level--;  
	 if ((c=='*')|| (wp->type==0 && c!='(')|| (comm_level==0 && c!=']' 
						   && c!='('&& c!=')' && c!='^' && c!='-' && (!isdigit(c))))
	    wp->type = 's';
	 if (bracket_level==0 && comm_level==0 && c=='*') wp->n=0;
	 if (bracket_level>=0 && comm_level>=0)
	    word_put_last (wp,c);
	 else break;
	 /* word reading is terminated by an unmatched right bracket of either type */
	 if (c=='*'||c=='^'||c=='('|| comm_level!=0){
	    /* '*','^' and '(' are non-terminal characters, so we can automatically 
	       skip over any
	       white spaces that appear after them, without further investigation */
	    do {
	       c=read_char (file);
	       if (c==EOF) break;
	    } while (c==' ');
	 }
	 else { 
	    c = read_char (file);
	    if (c==EOF) break;
	 }
      } while (isalpha(c) ||isdigit(c) || c=='_'||c=='.'
	       ||c=='^'||c=='-'||c=='('||c==')'||c=='['||
	       c==']'||c==','||c=='*'||c==' ');
      if (c!=EOF) ungetc(c,file);
   }
   if (c==EOF){
      fprintf(stderr,"Unexpected end of file.\n");
      bad_data ();
   }
   else if (word_length(wp)==0) 
      wp->type = 's'; /* then we'd have the trivial word */
   else word_expand (wp);
   return ans;
}

word_expand (wp) word *wp;
{
   word expansion;
   word buf;
   word temp;
   word temp2;
   gen_type g;
   char type = wp->type;
   int n = wp->n;
   int separator= '*';
   int bracket_level=0;
   int commutator_level=0;
   int exponent;
   int sign=1;
   if (type=='c'){
      if (n){
	 int i = wp->first; /* i is the position we're currently at in gp */
	 gen_type * gp = wp->g + wp->first;
	 gen_type * ggp = wp->g + wp->last;
	 while (gp<=ggp){
	    if ((*gp)=='^'){
	       int j=i;
	       exponent = 0;
	       gp++; i++; 
	       if ((*gp)=='-') sign = -1; else exponent = (*gp) - '0';
	       gp++; i++;
	       while (gp<=ggp && isdigit(*gp)){
		  exponent = 10*exponent + (*gp) - '0'; gp++; i++;
	       }
	       exponent *= sign;
	       if (commutator_level==0){ 
		  /* in the case the whole commutator is raised to a power */
		  wp->last = j-1; /* this is to delete the exponent from the end */
		  if (exponent==0) word_reset(wp);
		  else n *= exponent;
		  break;
	       }
	       else if (exponent != -1){
		  /* if we see any exponent other than a -1 inside a commutator we expand it */
		  wp->type = type = 's';
		  break;
	       }
	    }
	    else {
	       if ((*gp)=='[') commutator_level=1;
	       else if ((*gp)==']') commutator_level=0;
	       gp++; i++; 
	    }
	 }
	 wp->n = n;
      }
      if (wp->type == 'c') return;
   }
   word_init (&expansion);
   word_init (&buf);
   word_init (&temp);
   word_init (&temp2);
   while (word_delget_first (wp,&g)){
      if (isalpha(g) || isdigit(g) || g=='_'||g=='.')
	 word_put_last (&buf,g);
      else if (g==separator){
	 if (word_length(&buf)>0){
	    word_append (&expansion,&buf);
	    word_put_last (&expansion,g);
	    word_reset (&buf);
	 }
      }
      else if (g=='^'){
	 /*  read the exponent that follows and replace whatever's currently in
	     the buf by the appropriate number of copies of it or its inverse */ 
	 int i;
	 sign=1;
	 (void)word_delget_first (wp,&g);
	 if (g=='-'){
	    sign = -1;
	    word_delget_first (wp,&g);
	 }
	 if (isdigit(g)){
	    exponent=0;
	    /*Now g must be a digit */
	    exponent= g - '0' + 10*exponent;
	    while (word_get_first (wp,&g) && isdigit(g)){
	       exponent= g - '0' + 10*exponent;
	       word_delget_first (wp,&g);
	    }
	    if ((n) && word_length(wp)==0){
	       /* wp->n non-zero means we believe we're looking for a power at the end of 
		  the word. We know we are at the end of the word if we've deleted every character */
	       if (exponent==0) word_reset(wp);
	       else n = sign*exponent;
	    }
	    else {
	       if (sign == -1) {
		  gen_type h;
		  word2prog_word (&buf,&temp);
		  if (word_length(&temp)==1 && word_get_last (&temp,&h) &&
		      (inv_of==0 || inv_of[h]==0)){
		     /* in this case we're reading the name of a new generator */
		     word_put_last (&buf,'^');
		     word_put_last (&buf,'-');
		     word_put_last (&buf,'1');
		  }
		  else {
		     word_inv (&temp,&temp);
		     word2user_name (&temp,&buf);
		  }
	       }
	       word_cpy (&buf,&temp);
	       word_reset (&buf);
	       for (i=1;i<=exponent;i++){
		  word_append (&buf,&temp);
		  if (i<exponent && word_length(&buf)>0)
		     word_put_last (&buf,separator);
	       }
	       word_reset (&temp);
	    }
	 }
	 else {
	    word exp;
	    bracket_level=0;
	    commutator_level=0;
	    word_init (&exp);
	    do{
	       if (commutator_level==0 && bracket_level==0 &&
		   (g=='*'||g=='^')){
		  word_put_first (wp,g);
		  break;
	       }
	       if (g=='(')
		  bracket_level++;
	       else if (g==')')
		  bracket_level--;
	       if (g=='[')
		  commutator_level++;
	       else if (g==']')
		  commutator_level--;
	       word_put_last (&exp,g);
	    } while (word_delget_first (wp,&g));
	    word_expand (&exp);
	    if (word_length(&exp)>0){
	       word2prog_word (&exp,&temp);
	       word_inv (&temp,&temp);
	       word2user_name (&temp,&temp2);
	       word_put_last (&temp2,separator);
	       word_concat (&temp2,&buf,&buf);
	       word_put_last (&buf,separator);
	       word_append (&buf,&exp);
	       word_reset (&temp);
	       word_reset (&temp2);
	    }
	    word_clear (&exp);
	 }
      }
      else if (g=='(') {
	 bracket_level = 1;
	 while (word_delget_first (wp,&g)){
	    if (g=='(')
	       bracket_level++;
	    else if (g==')')
	       bracket_level--;
	    if (bracket_level==0)
	       break;
	    word_put_last (&buf,g);
	 }
	 word_expand (&buf);
      }
      else if (g=='[') {
	 word w1, w2;
	 commutator_level = 1;
	 word_init (&w1);
	 while (word_delget_first (wp,&g)){
	    if (g==',' && commutator_level==1)
	       break;
	    else if (g=='[')
	       commutator_level++;
	    else if (g==']')
	       commutator_level--;
	    word_put_last (&w1,g);
	 }
	 word_expand (&w1);
	 word_init (&w2);
	 while (word_delget_first (wp,&g)){
	    if (g=='[')
	       commutator_level++;
	    else if (g==',' && commutator_level==1){
	       /* convert to nested binary commutators, to make expansion easier */
	       word_put_first(&w1,'[');
	       word_put_last(&w1,',');
	       word_append(&w1,&w2);
	       word_put_last(&w1,']');
	       word_expand(&w1);
	       word_reset(&w2);
	       continue; /* we don't want to put the ',' onto the end of w2 */
	    }
	    else if (g==']'){
	       commutator_level--;
	       if (commutator_level==0)
		  break;
	    }
	    word_put_last (&w2,g);
	 }
	 word_expand (&w2);
	 if (word_length(&w1)>0 && word_length(&w2)>0){
	    word2prog_word (&w1,&temp);
	    word_inv (&temp,&temp);
	    word2user_name (&temp,&buf);
	    word_put_last (&buf,separator);
	    word2prog_word (&w2,&temp);
	    word_inv (&temp,&temp);
	    word2user_name (&temp,&temp2);
	    word_append (&buf,&temp2);
	    word_put_last (&buf,separator);
	    word_append (&buf,&w1);
	    word_put_last (&buf,separator);
	    word_append (&buf,&w2);
	    word_reset (&temp);
	    word_reset (&temp2);  
	 }
	 word_clear (&w1); word_clear (&w2); 
      }
   }
   if (bracket_level!=0 || commutator_level!=0){
      fprintf(stderr,"Unmatched bracket in relation.\n");
      bad_data ();
   }
   word_append (&expansion,&buf);
   /* there's no * at the end */
   if (word_get_last (&expansion,&g) && g==separator) word_del_last (&expansion);
   word_cpy (&expansion,wp);
   word_clear (&expansion);
   word_clear (&temp);
   word_clear (&temp2);
   word_clear (&buf);
   if (n==1) wp->n = 0;
   else wp->n = n;
   wp->type = type;
}

char word_get_last (wp,gp)
word *wp;
gen_type *gp;
{
   char ans = 1;
   if (wp->first > wp->last) {
      *gp = 0;
      ans = 0;
   }
   else
      *gp = wp->g[wp->last];
   return ans;
}
  
char
word_delget_last (wp,gp)
  word *wp;
  gen_type *gp;
{
   char ans = 1;
   if (wp->first > wp->last) {
      *gp = 0;
      ans = 0;
   }
   else {
      *gp = wp->g[wp->last];
      wp->last--;
   }
   return ans;
}
  


word2prog_gen (user_namep,prog_genp) 
  word* user_namep;  
  gen_type * prog_genp;
{ 

   gen_type g; 

   *prog_genp=0;
   for (g=1;g<=num_gens;++g) 
      if (word_eq (user_namep,user_gen_name+g)) { 
	 *prog_genp = g; 
	 break; 
      } 
}  

word2prog_word (user_wordp,prog_wordp)
  word * user_wordp;
  word * prog_wordp;
{
   word  user_gen;
   word_traverser wt;
   gen_type g;
   gen_type h;
   int i;
   int n=word_length(user_wordp);
   char* epsilon ="epsilon";
   word identity;
   word_init (&identity);
   for (i=0;i<=6;i++)
      word_put_last (&identity,(gen_type)epsilon[i]);
   i=0;
   word_reset (prog_wordp);
   prog_wordp->type = user_wordp->type;
   prog_wordp->n = user_wordp->n;
   if (word_eq (user_wordp,&identity)==0){
      word_init (&user_gen);
      word_traverser_init (&wt,user_wordp);
      while (word_next (&wt,&g)){
	 i++;
	 if (g!='*' && g!=',' && g!='[' && g!=']' && g!='(' && g!=')')
	    word_put_last(&user_gen,g);
	 if ((g=='*'||g==','||g==']'||g==')'||i==n) && word_length(&user_gen)!=0){
	    word2prog_gen (&user_gen,&h);
	    word_reset (&user_gen);
	    word_put_last (prog_wordp,h);
	 }
      }
      word_clear (&user_gen);
   }
   word_clear (&identity);
}

gen2prog_gen (user_gen,prog_genp)
  gen_type user_gen;
  gen_type * prog_genp;
{
   word w;
   word_init (&w);
   word_put_last (&w,user_gen);
   word2prog_gen (&w,prog_genp);
   word_clear (&w);
}


gen2user_name (program_gen,user_wordp) 
  gen_type program_gen;  
  word * user_wordp; 
{ 

   word_reset (user_wordp);
   if (program_gen==0||(num_gens!=0 && program_gen>num_gens)){
      gen_type g='$';
      word_put_last (user_wordp,g);
   }
   else 
      word_cpy (user_gen_name+program_gen,user_wordp); 

}  

word2user_name (prog_wordp,user_wordp)
  word * prog_wordp, * user_wordp;
{
   word w;
   gen_type separator;
   gen_type g=0;
   word_traverser wt;
   word_traverser_init (&wt,prog_wordp);
   word_reset (user_wordp);
   word_init (&w);
   user_wordp->n = prog_wordp->n;
   user_wordp->type = prog_wordp->type;
   if (user_wordp->type == 'c'){
      word_put_first(user_wordp,'[');
      separator = ',';
   }
   else separator = '*';
   while (word_next (&wt,&g)){
      gen2user_name (g,&w);
      word_append (user_wordp,&w);
      word_put_last (user_wordp,separator);
      word_reset (&w);
   }
   word_del_last (user_wordp); /* delete the final separator */
   if (user_wordp->type == 'c') word_put_last(user_wordp,']');
   word_clear (&w);
}

read_gen_name_array (file)
  FILE * file;  
{
   word w;
   int i;
   num_gens=0;
   user_gen_name = vzalloc(word,gen_array_size);
   for (i=0;i<gen_array_size;++i)
      word_init (user_gen_name+i);
   find_char ('{',file);
   word_init (&w);
   while (read_next_gen (&w,file)){
      define_next_gen (&w);
      word_reset (&w);
   }
   word_clear (&w);
   find_char ('}',file);
}

define_next_gen (wp)
  word * wp;
{
   word * ucpy;
   int size = gen_array_size;
   num_gens++;
   if (num_gens==gen_array_size-1){ 
      /* need more space */
      int i;
      gen_array_size = 2*num_gens + 1;
      ucpy = vzalloc(word,gen_array_size);
      for (i=0;i<gen_array_size;++i) 
	 word_init (ucpy+i);
      for (i=0;i<num_gens;++i){ 
	 word_cpy (user_gen_name+i,ucpy+i);
	 word_clear (user_gen_name+i);
      }
      free((char*)user_gen_name); user_gen_name=0;
      user_gen_name = ucpy;
      ucpy=0;
   }
   word_cpy (wp,user_gen_name+num_gens);
}

insert_gen (h,wp)
  gen_type h;
  word * wp;
{
   word * ucpy;
   gen_type * icpy;
   int i;
   int size = gen_array_size;
   num_gens++;
   if (num_gens==gen_array_size-1) 
      /* need more space */
      gen_array_size = 2*num_gens + 1;
   ucpy = vzalloc(word,gen_array_size);
   icpy = vzalloc(gen_type,gen_array_size);
   for (i=0;i<gen_array_size;++i) 
      word_init (ucpy+i);
   for (i=0;i<h;++i){ 
      word_cpy (user_gen_name+i,ucpy+i);
   }
   word_cpy (wp,ucpy+h);
   for (i=h;i<=num_gens-1;++i) 
      word_cpy (user_gen_name+i,ucpy+i+1);
   for (i=0;i<size;++i)
      word_clear (user_gen_name+i);
   free((char*)user_gen_name); user_gen_name=0;
   user_gen_name = ucpy;
   ucpy=0;
   for (i=0;i<h;++i){
      if (inv_of[i]>=h) icpy[i] = inv_of[i]+1;
      else icpy[i]=inv_of[i];
   }
   for (i=h;i<num_gens;i++){
      if (inv_of[i]>=h) icpy[i+1] = inv_of[i]+1;
      else icpy[i+1] = inv_of[i];
   }
   free((char*)inv_of);
   inv_of = icpy;
   icpy = 0;
}


default_inverse_array ()
{
   word w;
   word_traverser wt;
   gen_type g,h,k;
   gen_type l=0;
   if (inv_of==0)
      inv_of=vzalloc(gen_type,gen_array_size);
   word_init (&w);
   for (g = 1; g <= num_gens; ++g) { 
      if (inv_of[g]!=0)
	 continue;
      /* we may have set some inverses already explicitly */
      if (word_length(user_gen_name+g)==1){
	 /* we're just checking here to see that the user hasn't assumed the old
	    default of case change. Therefore if the lower and upper case versions of
	    the same character appear, the program exits with a bad data message. */
	 word_get_first (user_gen_name+g,&h);
	 if (islower(h))
	    k=toupper(h);
	 else
	    k=tolower(h);
	 gen2prog_gen (k,&l);
	 if (l!=0){
	    /* h and k are lower and upper case versions of the same alphabet character.
	       We don't allow this unless the generators are inverse to each other. This
	       isn't the case here. */
	    fprintf(stderr,
		    "%c and %c aren't allowed as generator names\n",h,k);
	    fprintf(stderr,
		    "unless they're defined to be inverse to each other.\n");
	    bad_data ();
	 }
      }
      /* now we'll set the inverse of g appropriately */
      word_traverser_init (&wt,user_gen_name+g);
      while (word_next (&wt,&h)){
	 if (h=='^')
	    break;
	 else
	    word_put_last (&w,h);
      }
      if (h!='^'){
	 word_put_last (&w,'^');
	 word_put_last (&w,'-');
	 word_put_last (&w,'1');
      }
      word2prog_gen (&w,&k);
      if (k==0){
	 /* There's no generator yet defined with user name w, so we have to slot one
	    in, just after g.  */
	 insert_gen (g+1,&w);
	 k = g+1;
      }
      inv_of[g]=k;
      inv_of[k]=g;
      word_reset (&w);
   }
   word_clear (&w);
} 


word_factor (wp,wwp,ep)
  word * wp,* wwp;
  int  * ep;
{
   int length = word_length(wp);
   int baselength = 0;
   word power;
   word_init (&power);
   word_reset (wwp);
   if (length==0){ *ep=0; return;}
   while (baselength <= length){
      word_traverser wt;
      int count = 0;
      gen_type g;
      int i;
      word_traverser_init (&wt,wp);
      while (word_next (&wt,&g)){
	 count++;
	 if (count<=baselength) continue;
	 word_put_last (wwp,g);
	 baselength++;
	 if (baselength>length/2 ||length%baselength==0)
	    break;
      }  
      if (baselength > length/2){
	 baselength = length;
	 *ep = 1;
	 break;
      }  
      else {
	 *ep = length/baselength;
	 for (i=1;i<=*ep;i++)
	    word_append (&power,wwp);
	 if (word_eq (wp,&power))
	    break;
      }  
      word_reset (&power);
   }
   word_clear (&power);
   if (baselength == length)
      word_cpy (wp,wwp);
}

char read_next_int (kp,rfile)
  int * kp;
  FILE * rfile;
{
   char ans=1;
   int sign=1;
   int c;
   *kp=0;
   while ((c=read_char (rfile))!=EOF && !(isdigit(c))){
      if (c=='-')
	 sign = -1;
      else if (c=='}' || c==';') {
	 /* a '}' or ';' is used to terminate the input */
	 ungetc(c,rfile);
	 ans = 0;
	 break;
      }
      else
	 sign = 1;
   }
   if (c==EOF)
      bad_data ();
   if (ans==1) {
      do {
	 *kp = 10*(*kp) + c - '0';
      } while (isdigit(c=getc(rfile)));
      ungetc(c,rfile);
   }
   *kp = sign*(*kp);
   return ans;
}
  
/* The next complete string is read and the first n or less  non-null characters are
stored in cp. Any space between the last non-null character of the string
and
 the terminating null character of cp is filled
with blank spaces.  Spaces, tabs and
returns, and also matched pairs {} (and all the stuff between them) are skipped
over until other symbols are met. The string is terminated by a tab, space,
return , (,), { or } (which remains unread ).
A string beginning with } or  ;  causes the function to stop
reading and return false.  The character is then returned to the buffer as if
unread.
*/
char
read_next_string (cp,n,rfile)
  char * cp;
  int n;
  FILE * rfile;
{
   int i=0;
   int c;
   char ans=1;
   while ((c=read_char (rfile))!=EOF){
      if (i==0){
	 if ( c=='}' || c==';' ) {
	    ungetc(c,rfile);
	    return  0;
	 }
	 else if (c=='{'){ /* skip over {}'s */
	    int count=1;
	    while (count>0){
	       if  ((c=read_char (rfile))=='{')
		  count++;
	       else if (c=='}')
		  count--;
	       if (c==EOF) break;
	    }
	 }
	 else if (c==' ')
	    continue;
	 else{
	    cp[0]=c;
	    i=1;
	 }
      }
      else if (i>0){
	 if (c==' '||c==';'||c=='{'||c=='}'||c=='('||c==')'||c=='=') {
	    if (c!=' ') ungetc(c,rfile);
	    break;
	 }
	 else {
	    if (i<n)
	       cp[i++]=c;
	 }
      }
   }
   if (c==EOF){
      ans = 0;
      i=0; /* if the function's returning false, we'd like to empty the
	      string */
   }
   while (i<n)
      cp[i++]=' ';
   cp[n]='\0';
   return ans;
}
 
 
char
find_keyword (label,rfile)
  char * label;
  FILE * rfile;
{
   char * string;
   char found=1;
   int k=0;
   while (label[k]!='\0')
      k++;
   string = vzalloc(char,k+1);
   do {
      found=1;
      if (read_next_string (string,k,rfile)==0){
	 found = 0;
	 break;
      }
   } while ((strcmp(string,label)!=0));
   free(string); string=0;
   return found;
}
 
/* The next function should be used in place of getc. It reads and returns
the next character, except that comments (preceded by # and going to the
next new line) and tabs and new lines are replaced by a single space.
*/
read_char (rfile)
  FILE * rfile;
{ int n;
n=getc(rfile);
/* The input may contain a '\' character which is printed before '\n'
   -- this is particularly true if the input file is generated by GAP */
if (n=='\\') {
   n = getc(rfile);
   if (n == '\n') n = getc (rfile); 
}
if (n=='#') while ((n=getc(rfile))!='\n' && n!=EOF);
if (n=='\n' || n=='\t') return(' ');
return(n);
}
 
find_char (c,rfile)
  char c;
  FILE * rfile;
{ int n;
while ((n=read_char (rfile))!=c){
   if (n==EOF){
      fprintf(stderr,"Unexpected end of file.\n");
      bad_data ();
   }
}
return;
}
 
char
read_next_char (cp,rfile)
  int * cp;
  FILE * rfile;
{
   while ((*cp=read_char (rfile))==' ');
   if (*cp==EOF) bad_data ();
   else if (*cp=='}'){ ungetc(*cp,rfile); return 0;}
   else return 1;
}

bad_data ()
{
   fprintf(stderr,"Bad data.\n");
   exit(FAILURE);
}
