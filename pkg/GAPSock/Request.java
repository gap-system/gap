import java.net.*;
import java.io.*;




public class Request 
{
	/* Possible request types */
	static public final int rqNone = 0;
	static public final int rqAssignData = 1;
	static public final int rqAssignCode = 2;
	static public final int rqAssignExecute = 3;
	static public final int rqRetrieve = 4;

	/* Members of the Request class */

	// is it done?
	public boolean processed = false;

	// who sent the request
  public int clientNum = -1;

	// object input data
	int requestType = rqNone;
	String inputOpenMath;
	String inputGAPCode;
	String gapVarName;
	String fnVarName;
	int nArgs;
	String fnArgs[];

	// object output data
	String outputOpenMath;
	String outputGAPCode;

	// requestType = rqRetrieve
  public Request(int clientNum, int requestType, String varName) 
	{
		if (requestType != rqRetrieve)
		{
			System.err.println("Invalid request");
			System.exit(1);
		}
		this.clientNum = clientNum;
		this.requestType = requestType;
		this.gapVarName = new String(varName);
	}

	// requestType = rqAssignData or rqAssignCode
  public Request(int clientNum, int requestType, String varName, String data) 
	{
		if ((requestType != rqAssignData) && (requestType != rqAssignCode))
		{
			System.err.println("Invalid request");
			System.exit(1);
		}
		this.clientNum = clientNum;
		this.requestType = requestType;
		if ((this.requestType = requestType) == rqAssignData)
		{	
			this.gapVarName = new String(varName);
			this.inputOpenMath = new String(data);
		}
		else
		{
			this.fnVarName = new String(varName);
			this.inputGAPCode = new String(data);
		}
	}

  // requestType == rqAssignExecute
  public Request(int clientNum, int requestType, int numargs,
		String varName, String fnName, String[] fnArgs)
	{
		int i;

		if (requestType != rqAssignExecute) 
		{
			System.err.println("Invalid request");
			System.exit(1);
		}
		this.clientNum = clientNum;
		this.requestType = requestType;
		this.gapVarName = new String(varName);
		this.fnVarName = new String(fnName);
		this.nArgs = numargs;
		this.fnArgs = new String[numargs];
		for (i=0; i<numargs; i++)
		{
			this.fnArgs[i] = new String(fnArgs[i]);
		}
	}


  public synchronized void putResult(String outGAP, String outOM)
  {
    if  (processed)
    {
      System.err.println("Results already written in putResult");
      System.exit(1);
    }
    this.outputOpenMath = new String(outOM);
    this.outputGAPCode = new String(outGAP);
		processed = true;
    notifyAll();

  }

  public synchronized String getOpenMathOutput()
  {
    while (!processed)
    {
      try {
          wait();
      } catch (InterruptedException e)
      {
        System.err.println("InterruptedException in getOpenMathOutput");
        System.exit(1);
      }
    }
		return outputOpenMath;
  }

  public synchronized String getGAPOutput()
  {
    while (!processed)
    {
      try {
          wait();
      } catch (InterruptedException e)
      {
        System.err.println("InterruptedException in getGAPOutput");
        System.exit(1);
      }
    }
		return outputGAPCode;
  }
}
