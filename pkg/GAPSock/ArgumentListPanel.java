import java.net.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;



public class ArgumentListPanel extends Panel implements ActionListener
{
    public List strList;
    private ListEntryPanel sourceList;
    private Button addButton;
    private Button clearButton;

    public ArgumentListPanel(ListEntryPanel slist, int length)
    {
 
      this.sourceList = slist;
      strList = new List(length, false);

      // Buttons panel
      addButton = new Button("Add Argument");
      clearButton = new Button("Clear Arguments");
      Panel butCol  = new Panel();
      butCol.setLayout(new GridLayout(0,1));
      butCol.add(addButton);
      butCol.add(clearButton);


      setLayout(new BorderLayout());
      add("Center", strList);
      add("West", butCol);

      addButton.addActionListener(this);
      clearButton.addActionListener(this);
      strList.addActionListener(this);

    }

    public void actionPerformed(ActionEvent evt)
    {
        if (evt.getSource() instanceof List)
        {
          List list = (List) evt.getSource();
          // Delete the item acted on.
          list.delItem(list.getSelectedIndex());
        }
        else if (evt.getSource() instanceof Button)
        {
          if ((evt.getSource() == this.addButton) &&
              (this.sourceList.strList.getSelectedIndex() != -1))
          {
            this.strList.add(this.sourceList.strList.getSelectedItem());
          }
          else if (evt.getSource() == this.clearButton)
          {
            this.strList.removeAll();
          }
        }
    }
}



