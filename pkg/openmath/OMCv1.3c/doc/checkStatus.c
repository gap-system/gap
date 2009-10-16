/* checkStatus
 *   Checks for errors reported in status.
 *   If status is not OMsuccess 
 *   then prints corresponding error message and exit;
 * status: status to check
 */
static void
checkStatus(OMstatus status)
{
  char tmp[1024];

  if (status != OMsuccess) {
    sprintf(tmp, "last call to OMlib returned error status %d (%s)", status, OMstatusToString(status));
    fatalError(status, tmp);
  }
}

