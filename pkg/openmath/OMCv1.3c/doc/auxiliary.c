static OMstatus
pipeSymb(OMdev inDev, OMdev outDev)
{
  char cd[1024], name[1024];
  int cl, nl;

  pipeComments(inDev, outDev);
  /* a sample for getN/putN functions */
  checkStatus(OMgetSymbolLength(inDev, &cl, &nl));
  checkStatus(OMgetSymbolN(inDev, cd, cl, name, nl));
  checkStatus(OMputSymbolN(outDev, cd, cl, name, nl));
  return OMsuccess;
}

...

static OMstatus
pipeApp(OMdev inDev, OMdev outDev)
{
  OMtokenType ttype;

  /* begin tag */
  checkStatus(OMgetApp(inDev));
  checkStatus(OMputApp(outDev));

  /* applied symbol */
  checkStatus(pipeSymb(inDev, outDev));

  /* arguments */
  while (1) {
    checkStatus(OMgetType(inDev, &ttype));
    if (ttype == OMtokenEndApp)
      break;
    checkStatus(pipeObj(inDev, outDev));
  }

  /* end tag */
  checkStatus(OMgetEndApp(inDev));
  checkStatus(OMputEndApp(outDev));

  return OMsuccess;
}

...

/* pipeComments
 *   Pipes/skips comments (if any).
 */
static OMstatus
pipeComments(OMdev inDev, OMdev outDev)
{
  OMtokenType ttype;
  OMstatus status;
  char *buf;

  while (1) {
    if (status = OMgetType(inDev, &ttype)) {
      if (status == OMnoMoreToken)
	return status;		/* OK that may be a normal exit condition */
      checkStatus(status);	/* there is something realy wrong */
    }

    if (ttype == OMtokenComment) {
      /* this is a comment
       * (they can be put everywhere)
       * thus skip/process it and continue 
       * (fakes it wasn't here) 
       */
      checkStatus(OMgetComment(inDev, &buf));
      checkStatus(OMputComment(outDev, buf));
      free(buf);
    }
    else {
      /* this is a plain element thus process it 
       * (do real grammar check) */
      break;
    }
  }
  return OMsuccess;
}

