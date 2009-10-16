import java.awt.*;
import java.awt.event.*;
import java.net.*;
import java.io.*;

public class GAPSockClient extends Frame implements ActionListener 
{
	final int textAreaWidth = 40; //columns
	final int textAreaDepth = 10; //lines
	boolean inAnApplet = true;

	static DataInputStream fromServer;
	static DataOutputStream toServer;
	static Socket gapSocket;

	// Class wide components
	TextArea transcriptTextArea;
	TextArea openMathText;
	TextArea gapCodeText;
	TextArea GAPoutTextArea;
	TextArea OMoutTextArea;
	Label varAssignName;
	Label varAssignCode;
	List argList;

	public GAPSockClient() 
	{
		// The command panel - all command buttons in a column
    Panel commandPanel = new Panel();
    commandPanel.setLayout(new GridLayout(0,1));
    Button assign_data_butt = new Button("AssignData");
    Button assign_code_butt = new Button("AssignCode");
    Button assign_exec_butt = new Button("AssignExecute");
    Button eval_butt = new Button("Retrieve");
    Button end_butt = new Button("EndSession");
    commandPanel.add(assign_data_butt);
    commandPanel.add(assign_code_butt);
    commandPanel.add(assign_exec_butt);
    commandPanel.add(eval_butt);
    commandPanel.add(end_butt);

		/*
		**
		** The input Panel
		**
		*/

		// The GAP code input Panel
		Panel GAPcodePanel = new Panel();
		GAPcodePanel.setLayout(new BorderLayout());
		GAPcodePanel.add("North", new Label("Input GAP Code", Label.CENTER));
		GAPcodePanel.add("Center", 
			gapCodeText = new TextArea("x->x+1", textAreaDepth, textAreaWidth));

		// The OpenMath input Panel
		Panel inOpenMathPanel = new Panel();
		inOpenMathPanel.setLayout(new BorderLayout());
		inOpenMathPanel.add("North", new Label("Input OpenMath", Label.CENTER));
		inOpenMathPanel.add("Center", openMathText = new TextArea(
			"<OMOBJ>\n\t<OMI> 1 </OMI>\n</OMOBJ>", textAreaDepth, textAreaWidth));

		// The input panel consists of the GAPcode and the OpenMath
		Panel inputPanel = new Panel();
		inputPanel.setLayout(new GridLayout(0,1));
		inputPanel.add(GAPcodePanel);
		inputPanel.add(inOpenMathPanel);

		/*
    **
    ** The output Panel
    **
    */

		// The GAP output panel
    Panel GAPoutputPanel = new Panel();
    GAPoutputPanel.setLayout(new BorderLayout());
    GAPoutputPanel.add("North", new Label("GAP Output", Label.CENTER));
    GAPoutputPanel.add("Center", 
			GAPoutTextArea = new TextArea(textAreaDepth, textAreaWidth));

    // The OpenMath output Panel
    Panel outOpenMathPanel = new Panel();
    outOpenMathPanel.setLayout(new BorderLayout());
    outOpenMathPanel.add("North", new Label("OpenMath Output", Label.CENTER));
    outOpenMathPanel.add("Center", 
			OMoutTextArea = new TextArea(textAreaDepth, textAreaWidth));

    // The Transcript panel
    Panel sessionTranscript = new Panel();
    sessionTranscript.setLayout(new BorderLayout());
    sessionTranscript.add("North",new Label("Session Transcript",Label.CENTER));
    sessionTranscript.add("Center", 
			transcriptTextArea = new TextArea(textAreaDepth, textAreaWidth));

		// The output panel consists of the GAPcode and the OpenMath
		Panel outputPanel = new Panel();
		outputPanel.setLayout(new GridLayout(0,1));
		outputPanel.add(GAPoutputPanel);
		outputPanel.add(outOpenMathPanel);
		outputPanel.add(sessionTranscript);

		/*
		**
		** The Control panel consists of the Input, Output, and Command panels
		**
		*/
		Panel controlPanel = new Panel();
		controlPanel.setLayout(new BorderLayout());
		Panel centerCP = new Panel();
		centerCP.setLayout(new GridLayout(0,2));
		centerCP.add(inputPanel);
		centerCP.add(outputPanel);
		controlPanel.add("Center", centerCP);
		controlPanel.add("East", commandPanel);
		controlPanel.add("North", new Label("GAPSock Control Panel", Label.CENTER));


		/*
		** The variable name input panel.
		**
		** This panel just consists of a text entry field and a list
		** box in which to store all the variables names of interest
		** to this session.
		*/
		ListEntryPanel variableEntryPanel = new ListEntryPanel(20,3);

		/*
		** Name Selection panels: assignName panel and
		** functionName panel.
		**
		** These consist of a button which transfers the
		** currently selected list item to the text field.
		*/
		Panel singleNamePanel = new Panel();
		singleNamePanel.setLayout(new GridLayout(4,0));
		NameSelectionPanel assignName = new NameSelectionPanel(variableEntryPanel, 
			20, "Set Assign Variable Name");
		varAssignName = assignName.textField;

		NameSelectionPanel functionName = new NameSelectionPanel(variableEntryPanel,
			20, "Set Function Variable Name");
		varAssignCode = functionName.textField;

		singleNamePanel.add(assignName);
		singleNamePanel.add(functionName);

		ArgumentListPanel argListPanel = 
			new ArgumentListPanel(variableEntryPanel, 15);
		argList = argListPanel.strList;


		/*
		** The variable panel
		*/
		Panel variablePanel = new Panel();
		variablePanel.setLayout(new BorderLayout());
		variablePanel.add("West",variableEntryPanel);
		variablePanel.add("Center", singleNamePanel);
		variablePanel.add("East", argListPanel);
		
		/* 
		** The whole panel
		*/
		setLayout(new BorderLayout());
		add("Center", controlPanel);
		add("South", variablePanel);


		// This allows you to close the program with the x button.
		addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
					if (inAnApplet) {
							dispose();
					} else {
							System.exit(0);
					}
			}
		});


		/* Listen to the command buttons. */
		assign_data_butt.addActionListener(this);
		assign_code_butt.addActionListener(this);
		eval_butt.addActionListener(this);
		assign_exec_butt.addActionListener(this);
		end_butt.addActionListener(this);
	}

	public void actionPerformed(ActionEvent event) 
	{
		String cstring;
		String sstring;
		int i;

		cstring = event.getActionCommand();

		try
		{
			// First we need to get the "Ready" signal from the server
			sstring = fromServer.readUTF();
			if (!sstring.equals("Ready"))
			{
				if (sstring.equals("Error"))
				{
					// get the error message
					sstring = fromServer.readUTF();
					transcriptTextArea.append("Server Error:" + sstring);
					return; // I guess we try again
				}
				else
				{
					System.err.println("Error: unexpected string " + sstring + 
						" from server");
					System.exit(1);
				}
			}
			
			if (cstring.equals("AssignData")) 
			{
				toServer.writeUTF(cstring);
				toServer.writeUTF(varAssignName.getText());
				toServer.writeUTF(openMathText.getText());
				transcriptTextArea.append("Client:" + cstring + " " + 
					varAssignName.getText() + " " + openMathText.getText() + "\n");

				sstring = fromServer.readUTF();
				transcriptTextArea.append("Server:" + sstring + "\n");

				// Now get the GAP output
				GAPoutTextArea.append(fromServer.readUTF());
			}
			else if (cstring.equals("AssignCode"))
			{
				toServer.writeUTF(cstring);
				toServer.writeUTF(varAssignCode.getText());
				toServer.writeUTF(gapCodeText.getText());
				transcriptTextArea.append("Client:" + cstring + " " + 
					varAssignCode.getText() + " " + gapCodeText.getText() + "\n");

				sstring = fromServer.readUTF();
				transcriptTextArea.append("Server:" + sstring + "\n");

				// Now get the GAP output
				GAPoutTextArea.append(fromServer.readUTF());
			}
			else if (cstring.equals("AssignExecute"))
			{
				toServer.writeUTF(cstring);
				toServer.writeInt(argList.getItemCount());
				toServer.writeUTF(varAssignName.getText());
				toServer.writeUTF(varAssignCode.getText());
				for (i=0; i<argList.getItemCount(); i++)
					toServer.writeUTF(argList.getItem(i));

				transcriptTextArea.append("Client:" + cstring + 
					" varAssignName = " + varAssignName.getText() +
					" functionName = " + varAssignCode.getText() + 
					" number of arguments = " + argList.getItemCount() + "\n");

				sstring = fromServer.readUTF();
				transcriptTextArea.append("Server:" + sstring + "\n");

				// Now get the GAP output
				GAPoutTextArea.append(fromServer.readUTF());
			}
			else if (cstring.equals("Retrieve"))
			{
				toServer.writeUTF(cstring);
				toServer.writeUTF(varAssignName.getText());
				transcriptTextArea.append("Client:" + cstring + 
					" varAssignName = " + varAssignName.getText() + "\n");
				sstring = fromServer.readUTF();
				transcriptTextArea.append("Server:" + sstring + "\n");

				// Now get the GAP and OM output
				GAPoutTextArea.append(fromServer.readUTF());
				OMoutTextArea.append(fromServer.readUTF());
			}
			else if (cstring.equals("EndSession"))
			{
				toServer.writeUTF(cstring);
				transcriptTextArea.append("Client:" + cstring + "\n");
				sstring = fromServer.readUTF();
				if (sstring.equals("Bye"))
				{
					toServer.close();
					fromServer.close();
					gapSocket.close();
					System.err.println("Session terminated normally");
					System.exit(0);
				}
				else
				{
					toServer.close();
					fromServer.close();
					gapSocket.close();
					System.err.println("Session terminated abnormally");
					System.exit(1);
				}
			}	
			else
			{
				System.err.println("Unknown Command button value " + cstring + "\n");
				System.exit(1);
			}
		}
		catch (IOException e)
		{
			System.err.println("IOException");
			System.exit(1);
		}

	}

	public static void main(String[] args) 
	{


		try 
		{
			gapSocket = new Socket("localhost", 4444);
			toServer = new DataOutputStream(gapSocket.getOutputStream());
			fromServer = new DataInputStream(gapSocket.getInputStream());
		} 
		catch (UnknownHostException e) 
		{
			System.err.println("UnknownHostException");
			System.exit(1);
		} 
		catch (IOException e) 
		{
			System.err.println("IOException");
			System.exit(1);
		}


		// GUI stuff
		GAPSockClient window = new GAPSockClient();
		window.inAnApplet = false;

		window.setTitle("The GAPSock Test Client");
		window.pack();
		window.setVisible(true);

	}
}
