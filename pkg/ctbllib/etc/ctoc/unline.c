#include <stdio.h>
#include <ctype.h>
main()
{
int i, c, flag=0;
   while (( c = getchar() ) != EOF)
   {
       if ( c == '(')
       {
	 if ((c = getchar()) == '#')
	 {
	    putchar('"');
	    while ((c = getchar()) != '#')
	    {
	       if (c == '\n')
	       {
		  putchar('\\');
		  putchar('n');
	       }
	       else putchar(c);
	    }
	    if ((c = getchar()) == ')') putchar('"');
	 }
	 else
	 {
	    ungetc(c, stdin);
	    flag = 1;
	    putchar('(');
	 }
      }
      else if ( c == ')' )
      {
	 flag = 0;
	 putchar(c);
      }
      else if ( c == '\n' || c == ' ' )
      {
	 if (flag == 0) putchar(c);
      }
      else putchar(c);
   }
}

