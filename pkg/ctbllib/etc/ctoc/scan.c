#include <stdio.h>
#include <ctype.h>
#define MAXIND 1000
main()
{
int i, c, findex, sign, ind, coe, coeff[MAXIND];
   while ((c = getchar()) != EOF)
   {
      if ( c == '"' ) 
      {
	 putchar(c);
	 while ((c = getchar()) != '"') putchar(c);
      }
      if ( c == '<' ) 
      {
	 while(isspace(c = getchar()));
	 if (c == 'w') ungetc(c,stdin);
	 else exit(5);
	 scanf("w%d", &findex);
	 while (isspace(c = getchar()) || c == ',');
	 for (i=0; i < findex; coeff[i++] = 0);
	 while ( c != '>' )
	 {
	    sign = 1;
	    if ( c == '-')
	    {
	       sign = -1;
	       c = getchar();
	    }
	    if (c == '+') c = getchar();
	    coe = 1;
	    if (isdigit(c))
	    {
	       ungetc(c, stdin);
	       scanf("%d", &coe);
	       c = getchar();
	    }
	    if (c == 'w')
	    {
	       c = getchar();
	       if (isdigit(c))
	       {
		  ungetc(c, stdin);
		  scanf("%d", &ind);
		  c = getchar();
	       }
	       else ind = 1;
	       coeff[ind] = sign * coe;
	    }
	    else coeff[0] = sign * coe;
	 }
	 printf("CycList([%d", coeff[0]);
	 for (i=1; i < findex; printf(",%d", coeff[i++]));
	 printf("])");
      }
      else putchar(c);
   }
}
