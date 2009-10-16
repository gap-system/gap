import java.net.*;
import java.io.*;

/*
** The gapThread reads a request which has been left in the cubbyhole
** and puts the result in the Request container.
*/
public class gapThread extends Thread 
{
	private CubbyHole cubbyhole;
	private Process GAPprocess;
	GAPOutputReader localIn;
	PrintWriter localOut;
	private File tmpFile = null; // to send OM objects to GAP

	public gapThread(CubbyHole c) 
	{
		cubbyhole = c;

    try
    {
      GAPprocess = Runtime.getRuntime().exec("gap4s -N -q -p -T");
    } catch (IOException e) { e.printStackTrace(); }



    /* The input stream (from which we read) associated with the
    ** output of GAPprocess
    */
    localIn = new GAPOutputReader(new
      InputStreamReader(GAPprocess.getInputStream()));

    /* The output stream (to which we write) associated with the
    ** input of GAPprocess
    */
    localOut = new PrintWriter(GAPprocess.getOutputStream(),true);

    System.out.println("Gap started...");

		

    // Skip banner and output from package load
    try
    {
      localIn.waitUntilOutputOccurred();
      localIn.gotoEnd();
			localOut.println( "RequirePackage(\"openmath\");;\n" );
      localIn.waitUntilOutputOccurred();
			System.out.println(localIn.readAll());
      localIn.gotoEnd();
    }
    catch(IOException e)
    {
      System.err.println("IOException in gapThread");
    }
    System.out.println("GAP ready.");
	}




	protected void finalize()
	{
		try
		{
			localIn.close();
			GAPprocess.destroy();
		}
		catch(IOException e)
		{
			System.err.println("IOException in gapThread.finalize()");
		}
		System.err.println("gapThread.finalize() called successfully");
	}

	public void handleRequest(Request r)
	{
		String gapInString;
		String gapOutString;
		StringBuffer stringOM;
		int n;
		int k;
		int i;

		try
		{
			switch (r.requestType)
			{
			case Request.rqAssignData:
				
				/* Processing OpenMath so it doesn't get mangled by the 
				** parser on stdin.	
				*/
				// stringOM is the String Buffer of the OM input
				stringOM = new StringBuffer(r.inputOpenMath);
				
				// now insert slosh before all newlines 
				n = 0;
				while ((k = stringOM.toString().indexOf("\n",n)) != -1)
				{
					n = k+2;
					stringOM.insert(k, '\\');
				}

				// also insert slosh before quotes
				n = 0;
				while ((k = stringOM.toString().indexOf("\"",n)) != -1)
				{
					n = k+2;
					stringOM.insert(k, '\\');
				}

				
				/* The command string */
				gapInString = new String("C"+ r.clientNum + r.gapVarName + 
					" :=  OMGetObject(InputTextString(\"" + 
					stringOM.toString() + "\")); \n");

				// diagnostics
				System.out.println("IN: "+gapInString);

				// sending the command and waiting for response
				localOut.println( gapInString );
				localIn.waitUntilOutputOccurred();
				gapOutString = localIn.readSelect();
				System.out.println("Gap output"+gapOutString);

				// returning the result
				r.putResult(gapOutString, "");
				break;

			case Request.rqAssignCode:
				// construct the command
				gapInString = new String("C" + r.clientNum + r.fnVarName + 
					" := " + r.inputGAPCode + ";\n");

        // diagnostics
        System.out.println("IN: "+ gapInString);
        
        // sending the command and waiting for response
        localOut.println( gapInString );
        localIn.waitUntilOutputOccurred();
        gapOutString = localIn.readSelect();
        System.out.println("Gap output"+gapOutString);
        
        // returning the result
        r.putResult(gapOutString, "");
        break;

			case Request.rqAssignExecute:
				// construct the command
        gapInString = new String("C" + r.clientNum + r.gapVarName +
					" := " + "C" + r.clientNum + r.fnVarName + "(");
				for (i=0;i<r.nArgs;i++)
				{
					gapInString = gapInString.concat("C" + r.clientNum + r.fnArgs[i] + 
						((i == r.nArgs-1) ? "" : ","));
				}
				gapInString = gapInString.concat(");\n");

        // diagnostics
        System.out.println("IN: "+ gapInString);
        
        // sending the command and waiting for response
        localOut.println( gapInString );
        localIn.waitUntilOutputOccurred();
        gapOutString = localIn.readSelect();
        System.out.println("Gap output"+gapOutString);
        
        // returning the result
        r.putResult(gapOutString, "");
				break;

			case Request.rqRetrieve:
				// construct the command
        gapInString = new String("OMPrint(" + "C" + r.clientNum 
					+ r.gapVarName + ");\n");

        // diagnostics
        System.out.println("IN: "+ gapInString);
        
        // sending the command and waiting for response
        localOut.println( gapInString );
        localIn.waitUntilOutputOccurred();
        gapOutString = localIn.readSelect();
        System.out.println("Gap output"+gapOutString);
        
        // returning the result
        r.putResult(gapOutString, gapOutString);
				break;


			default:
				r.putResult("mad","dog");
			}
		}
		catch (IOException e)
		{
			System.err.println("IOException in gapThread.handleRequest()");
		}
	}

	public void run() 
	{
		Request r;
		while  (true) 
		{
			if (cubbyhole.IsEmpty())
			{
				try
				{
					sleep(250);
				} catch (InterruptedException e) {}
			}
			else
			{
				r = cubbyhole.get();
				System.out.println("gapThread got request from Client " + r.clientNum);
				handleRequest(r);
			}
		}


	}
}



