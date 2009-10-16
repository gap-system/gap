import java.net.*;
import java.io.*;


public class GAPSockMultiServerThread extends Thread 
{
	private Socket socket = null;
	private CubbyHole cHole;
	private int clientNum = -1;

	public GAPSockMultiServerThread(Socket socket,CubbyHole cHole,int clientNum) 
	{
			super("GAPSockMultiServerThread");
			this.socket = socket;
			this.cHole = cHole;
			this.clientNum = clientNum;
	}

	public void run() 
	{
		final int MAXARGS = 100;
		String gapVarName;
		String omObject;
		String gapCode;
		String fnVarName;
		String[] fnArgs = new String[MAXARGS];
		int numArgs;
		int i;
		Request rqLocal;

		try 
		{
			DataOutputStream toClient = 
				new DataOutputStream(socket.getOutputStream());

			DataInputStream fromClient = 
				new DataInputStream(socket.getInputStream());

			String clientCommand;
			toClient.writeUTF("Ready");

			while (true)
			{
					clientCommand = fromClient.readUTF();
					if (clientCommand.equals("AssignData"))
					{
						// read the input
						gapVarName = fromClient.readUTF();
						omObject = fromClient.readUTF();

						//construct the request
						this.cHole.put(rqLocal = new Request(clientNum, 
							Request.rqAssignData,  gapVarName, omObject));

						
						toClient.writeUTF("Client " + this.clientNum 
							+ " AssignDataOK: gapVarName = \"" + gapVarName + 
							"\" omObject = \"" + omObject + "\"" + 
							" GAP output is \"" + rqLocal.getGAPOutput() +
							"\" OpenMath output is \"" + rqLocal.getOpenMathOutput() + "\"");

						// return the result
						toClient.writeUTF(rqLocal.getGAPOutput()+"\n");
					}
					else if (clientCommand.equals("AssignCode"))
					{
						fnVarName = fromClient.readUTF();
            gapCode = fromClient.readUTF();

						//construct the request
						this.cHole.put(rqLocal = new Request(clientNum, 
							Request.rqAssignCode,  fnVarName, gapCode));

						toClient.writeUTF("Client " + this.clientNum 
							+ " AssignCodeOK: fnVarName = \"" + fnVarName + 
							"\" gapCode = \"" + gapCode + "\"" +
							" GAP output is \"" + rqLocal.getGAPOutput() +
							"\" OpenMath output is \"" + rqLocal.getOpenMathOutput() + "\"");

						// return the result
						toClient.writeUTF(rqLocal.getGAPOutput()+"\n");
					}
					else if (clientCommand.equals("AssignExecute"))
					{
						// n, gapVarName, fnVarName, args1, ..., argsn
						numArgs = fromClient.readInt();
System.out.println("Client sends " + String.valueOf(numArgs) + " as number of arguments\n");
						if (numArgs >= MAXARGS)
						{
							toClient.writeUTF("Error: more than " + MAXARGS + 
								" to AssignExecute");
						}
						else
						{
							// read the input
							gapVarName = fromClient.readUTF();
							fnVarName = fromClient.readUTF();
							for (i=0; i<numArgs; i++)
								fnArgs[i] = fromClient.readUTF();


							//construct the request
							this.cHole.put(rqLocal = new Request(clientNum, 
								Request.rqAssignExecute,numArgs,gapVarName,fnVarName,fnArgs));

							toClient.writeUTF("Client " + this.clientNum 
								+ " AssignExecuteOK:numArgs = " + numArgs + 
								" gapVarName = \"" + gapVarName + 
								"\" fnVarName = \"" + fnVarName + "\"" + 
								" GAP output is \"" + rqLocal.getGAPOutput() + 
								"\" OpenMath output is \"" + 
								rqLocal.getOpenMathOutput() + "\"");

							// return the result
							toClient.writeUTF(rqLocal.getGAPOutput()+"\n");
						}
					}
					else if (clientCommand.equals("Retrieve"))
					{
						gapVarName = fromClient.readUTF();

						//construct the request
						this.cHole.put(rqLocal = new Request(clientNum,
							Request.rqRetrieve, gapVarName));

						toClient.writeUTF("Client " + this.clientNum 
							+ " RetrieveOK:gapVarName= \"" + gapVarName + "\"" + 
							" GAP output is \"" + rqLocal.getGAPOutput() +
							"\" OpenMath output is \"" +
							rqLocal.getOpenMathOutput() + "\"");

						// return the result
						toClient.writeUTF(rqLocal.getGAPOutput()+"\n");
						toClient.writeUTF(rqLocal.getOpenMathOutput()+"\n");

					}
					else if (clientCommand.equals("EndSession"))
					{
						toClient.writeUTF("Bye");
						toClient.close();
						fromClient.close();
						socket.close();
						return;
					}
					else 
					{
						toClient.writeUTF("Error");
						toClient.writeUTF("Unexpected command "
							+ clientCommand + " recieved from client");
					}
					toClient.writeUTF("Ready");
			}

		} 
		catch (IOException e) 
		{
				System.err.println("IOException in GAPSockMultiServerThread");
				e.printStackTrace();
		}
/*
		catch (EOFException e) 
		{
				System.err.println("EOFException");
		}
		catch (UTFDataFormatException  e) 
		{
				System.err.println("UTFDataFormatException");
		}
*/
	}
}







