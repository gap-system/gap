
int
main(int argc, char *argv[])
{
  FILE *inFile, *outFile;
  OMdev inDev, outDev;
  OMstatus status;

  ...

  inDev = OMmakeDevice(OMencodingUnknown, OMmakeIOFile(inFile));
  outDev = OMmakeDevice(OMencodingXML, OMmakeIOFile(outFile));

  /* Consider comments as plain tokens (thus pipe them). */
  OMignoreComment(inDev, OMfalse);

  /* Endless pipe of OpenMath objects */
  while (1) {
    checkStatus(OMbeginObject(outDev));
    if (status = pipeObj(inDev, outDev)) {
      if (status == OMnoMoreToken)
	break;			/* OK that's a normal exit condition */
      checkStatus(status);	/* there is something realy wrong */
    }
    checkStatus(OMendObject(outDev));
  }

  OMcloseDevice(inDev);
  OMcloseDevice(outDev);

  return 0;
}
