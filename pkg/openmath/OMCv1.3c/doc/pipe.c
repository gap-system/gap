/* pipeObj
 *   Reads an OpenMath object from <inDev> and copy it to <outDev>.
 *   Syntax is checked to detect poorly structured obhects.
 *   It is able to dup an incomplete object.
 *   (ie: that lacks the bounding <OMOBJ> </OMOBJ>
 * inDev: source device
 * outDev: destibation device
 * return: 0 or some error status
 */
static OMstatus
pipeObj(OMdev inDev, OMdev outDev)
{
  OMtokenType ttype;
  OMstatus status;
  char *buf;
  OMUCS2 *wcbuf;
  double d;
  int i, l, sign;
  OMbigIntType format;

  /* pipes/skips comments (if any) */
  pipeComments(inDev, outDev);

  /* checks for end of parse */
  if (status = OMgetType(inDev, &ttype)) {
    if (status == OMnoMoreToken)
      return status;		/* OK that may be a normal exit condition */
    checkStatus(status);	/* there is something realy wrong */
  }

  /* pipes the token depending on its type */
  switch (ttype) {
  case OMtokenInt32:
    checkStatus(OMgetInt32(inDev, &i));
    checkStatus(OMputInt32(outDev, i));
    break;
  case OMtokenFloat64:
    checkStatus(OMgetFloat64(inDev, &d));
    checkStatus(OMputFloat64(outDev, &d));
    break;
  case OMtokenByteArray:
    checkStatus(OMgetByteArray(inDev, &buf, &l));
    checkStatus(OMputByteArray(outDev, buf, l));
    free(buf);
    break;
  case OMtokenBigInt:
    checkStatus(OMgetBigInt(inDev, &buf, &l, &sign, &format));
    checkStatus(OMputBigInt(outDev, buf, l, sign, format));
    free(buf);
    break;
  case OMtokenSymbol:
    checkStatus(pipeSymb(inDev, outDev));
    break;
  case OMtokenVar:
    checkStatus(pipeVar(inDev, outDev));
    break;
  case OMtokenString:
    /* some application may assume that they only use 
     * plain 8bits strings... (this is probably not a 
     * good idea but it may be ok if speed considerations
     * are in balance)
     * tpipe is suposed to work on all inputs thus it
     * must deal with wide char strings (16bits chars)
     */
    checkStatus(OMgetWCString(inDev, &wcbuf));
    checkStatus(OMputWCString(outDev, wcbuf));
    free(wcbuf);
    break;
  case OMtokenApp:
    checkStatus(pipeApp(inDev, outDev));
    break;
  case OMtokenEndApp:
    fatalError(1, "syntax error: </OMA> found out of <OMA> scope.");
    break;
  case OMtokenAttr:
    checkStatus(pipeAttr(inDev, outDev));
    break;
  case OMtokenEndAttr:
    fatalError(1, "syntax error: </OMATTR> found out of <OMATTR> scope.");
    break;
  case OMtokenAtp:
    fatalError(1, "syntax error: <OMATP> found out of <OMATTR> scope.");
    break;
  case OMtokenEndAtp:
    fatalError(1, "syntax error: </OMATP> found out of <OMATTR> scope.");
    break;
  case OMtokenBind:
    checkStatus(pipeBind(inDev, outDev));
    break;
  case OMtokenEndBind:
    fatalError(1, "syntax error: </OMBIND> found out of <OMBIND> scope.");
    break;
  case OMtokenBVar:
    fatalError(1, "syntax error: <OMBVAR> found out of <OMBIND> scope.");
    break;
  case OMtokenEndBVar:
    fatalError(1, "syntax error: </OMBVAR> found out of <OMBIND> scope.");
    break;
  case OMtokenError:
    pipeError(inDev, outDev);
    break;
  case OMtokenEndError:
    fatalError(1, "syntax error: </OME> found out of <OME> scope.");
    break;
  case OMtokenObject:
    /* this object is explicitly enclosed in <OMOBJ> ... </OMOBJ> */
    checkStatus(OMgetObject(inDev));
    checkStatus(OMputObject(outDev));
    /* parse embeded elements */
    checkStatus(pipeObj(inDev, outDev));
    /* end object tag */
    checkStatus(OMgetEndObject(inDev));
    checkStatus(OMputEndObject(outDev));
    break;
  case OMtokenEndObject:
    fprintf(stderr, "warning: empty <OMOBJ></OMOBJ>!\n");
    break;
  default:{
      char tmp[1024];
      sprintf(tmp, "Not yet implemented or unknown token type (%d).\n", ttype);
      fatalError(1, tmp);
    }
  }

  /* pipes/skips comments (if any) */
  pipeComments(inDev, outDev);

  return OMsuccess;
}

