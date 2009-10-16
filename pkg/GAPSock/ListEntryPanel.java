import java.io.*;
import java.awt.*;
import java.awt.event.*;


public class ListEntryPanel extends Panel implements ActionListener
{
    TextField textField;
    List strList;

    public ListEntryPanel(int width, int length)
    {
      textField = new TextField(width);
      strList = new List(length, false);

      //Add Components to the Applet.
      GridBagLayout gridBag = new GridBagLayout();
      setLayout(gridBag);
      GridBagConstraints c = new GridBagConstraints();
      c.gridwidth = GridBagConstraints.REMAINDER;

      c.fill = GridBagConstraints.HORIZONTAL;
      gridBag.setConstraints(textField, c);
      add(textField);

      c.fill = GridBagConstraints.BOTH;
      c.weightx = 1.0;
      c.weighty = 1.0;
      gridBag.setConstraints(strList, c);
      add(strList);

      textField.addActionListener(this);
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
        else if (evt.getSource() instanceof TextField)
        {
          // Add the text to the list
          String text = textField.getText();
          strList.add(text);
          textField.selectAll();
        }
    }
}


