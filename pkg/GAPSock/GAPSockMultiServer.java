import java.net.*;
import java.io.*;

public class GAPSockMultiServer 
{
	public static void main(String[] args) throws IOException 
	{
		ServerSocket serverSocket = null;
		boolean listening = true;
		int i;

		try 
		{
			serverSocket = new ServerSocket(4444);
		} 
		catch (IOException e) 
		{
			System.err.println("Could not listen on port: 4444.");
			System.exit(-1);
		}

		/* A place for data being passed to the GAP thread */
		CubbyHole c = new CubbyHole(); 

		/* Start a GAP thread */
		gapThread gt = new gapThread(c);
		gt.start();

		i = 0; // count the number of clients
		while (listening)
		{
			new GAPSockMultiServerThread(serverSocket.accept(),c,i).start();
			i++;
		}

		serverSocket.close();
	}
}
