
/**************************************************************************

	snippets.c

Bits of code that, at one time or another, were in ACE.

**************************************************************************/

	/******************************************************************
	Mode 5 in an experimental mode where we specify the percentage of
	deductions to be stacked via dedper.  So we will, in general, run
	an RA phase at the end of the enumeration.  If the number of cosets
	doesn't blow out to badly, then we could achieve a significant
	speed-up; without the complications of PACE's parallelisation. 

	This code might more properly be in PACE, which is intended as a 
	test-bed for various dedn handling strategies (incl the `parallel' 
	stategy!).

	Note that we also need to declare dedper in al0.h, define it in 
	enum.c, initialise it, and print it out in, eg, `dump:0;' & 
	`sr:1;'.
	******************************************************************/

	/* The SAVED macro for dedmode #5 */

#define SAVED(cos,gen)                               \
  INCR(xsaved);                                      \
  if (dedmode == 5 && ((1 + (rand()%100)) > dedper)) \
    { disded = TRUE; }        \
  else                        \
    {                         \
    if (topded >= dedsiz-1)   \
      {                       \
      INCR(sdoflow);          \
      switch(dedmode)         \
        {                     \
        case 3:               \
          disded = TRUE;      \
          topded = -1;        \
          break;              \
        case 4:               \
        case 5:               \
          al0_dedn(cos,gen);  \
          break;              \
        default:              \
          disded = TRUE;      \
          break;              \
        }                     \
      }                       \
    else                      \
      {                       \
      dedrow[++topded] = cos; \
      dedcol[topded]   = gen; \
      }                       \
    }                         \
  SAVED00;               

	/* The `dmod' parsing */

    if (al2_match("ded mo[de]") || al2_match("dmod[e]"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt == 0)
        {
        fprintf(fop, "deduction mode = %d", dedmode);
        if (dedmode == 5)
          { fprintf(fop, " (%d%%)", dedper); }
        fprintf(fop, "\n");
        }
      else if (intcnt == 1)
        {
        if (intarr[0] < 0 || intarr[0] > 5)
          { al2_continue("bad mode parameter"); }
        dedmode = intarr[0];
        dedper  = 50;			/* default is 1/2 the dedns */
        }
      else if (intcnt == 2)
        {
        if (intarr[0] != 5)
          { al2_continue("too many parameters"); }
        if (intarr[1] < 0 || intarr[1] > 100)
          { al2_continue("bad percentage parameter"); }
        dedmode = intarr[0];
        dedper  = intarr[1];
        }
      else
        { al2_continue("bad parameter count"); }

      continue;
      }

	/******************************************************************
	******************************************************************/

	/******************************************************************
	******************************************************************/

	/******************************************************************
	******************************************************************/

	/******************************************************************
	******************************************************************/

