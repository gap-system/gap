import java.net.*;
import java.io.*;



public class CubbyHole 
{
	private Request contents;
	private boolean available = false; //available = "there's something to get"

	public boolean IsEmpty()
	{
		return (!available);
	}

	public synchronized Request get() 
	{
		while (this.IsEmpty()) 
		{
			try 
			{
				wait();
			} 
			catch (InterruptedException e)
			{
				System.err.println("Consumer is hungry!");
				System.exit(1);
			}
		}
		available = false;
		notifyAll();
		return contents;
	}

	public synchronized void put(Request r) 
	{
		while (!this.IsEmpty()) 
		{
			try 
			{
				wait();
			} 
			catch (InterruptedException e) { }
		}
		contents = r;
		available = true;
		notifyAll();
	}
}
