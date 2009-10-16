import java.io.*;
import java.awt.*;
import java.awt.event.*;


public class NameSelectionPanel extends Panel implements ActionListener
{
    public Label textField;
    Button transfer;
    private ListEntryPanel sourceList;

    public NameSelectionPanel(ListEntryPanel slist,
      int width, String label)
    {
      textField = new Label();
      textField.setBackground(Color.white);
      transfer = new Button(label);
      this.sourceList = slist;

      setLayout(new GridLayout(0,2));
      add(transfer);
      add(textField);

      transfer.addActionListener(this);
    }

    /* The only event is when the button is pressed.
    ** - transfer the selected text from the variable list
    ** or do nothing if no selection has been made.
    */

    public void actionPerformed(ActionEvent evt)
    {
      if (this.sourceList.strList.getSelectedIndex() != -1)
      {
        textField.setText(this.sourceList.strList.getSelectedItem());
      }
    }
}


