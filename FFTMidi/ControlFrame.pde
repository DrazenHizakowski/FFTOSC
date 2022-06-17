
import oscP5.*;
import controlP5.*;
import static controlP5.ControlP5.*;
import java.util.*;
import java.util.Map.Entry;

public class ControlFrame {

  int w, h;
  PApplet parent;
  OnValueChanged listener;
  ArrayList<GTextField> textFields = new ArrayList<GTextField>();

  public ControlFrame(PApplet _parent, int _w, int _h, String _name, OnValueChanged listener) {
    super();
    parent = _parent;
    this.listener = listener;
    // this.cp5 = control;
    w=_w;
    h=_h;
  }
  GTextField fileText;

  void createAWTWindow() {
    GWindow window = GWindow.getWindow(parent, "Controls", 50, 50, 400, 800, P2D);
    window.addDrawHandler(this, "drawUI");
  }

  public  void drawUI(PApplet applet, GWinData windata) {
    if (!updateMenu) {
      return;
    }
    G4P.messagesEnabled(true);
    G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
    G4P.setMouseOverEnabled(false);
    G4P.setDisplayFont("Arial", G4P.PLAIN, 16);
    for (int i =0; i<bands; i++) {
      GTextField txf1 = new GTextField(applet, 50, 25*i, 200, 20);
      txf1.tag = "field"+i;
      txf1.setPromptText("Channel "+i);
      textFields.add(txf1);

      GLabel label2 = new GLabel(applet, 10, 25*i, 30, 20);
      label2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
      label2.setText(""+i);
      label2.setOpaque(false);
    }
    GButton buttonSubmit = new GButton(applet, 300, 25, 80, 40);
    buttonSubmit.setText("Submit");
    buttonSubmit.tag = "submit";

    buttonSubmit.addEventHandler(parent, "buttonDispatcher");

    GButton buttonClear = new GButton(applet, 300, 70, 80, 40);
    buttonClear.setText("Clear");
    buttonClear.tag = "clear";
    buttonClear.addEventHandler(parent, "buttonDispatcher");

    GButton buttonSave = new GButton(applet, 300, 140, 80, 40);
    buttonSave.setText("Save");
    buttonSave.tag = "save";
    buttonSave.addEventHandler(parent, "buttonDispatcher");

    GButton buttonLoad = new GButton(applet, 300, 235, 80, 40);
    buttonLoad.setText("Load");
    buttonLoad.tag = "load";
    buttonLoad.addEventHandler(parent, "buttonDispatcher");

    fileText = new GTextField(applet, 300, 185, 80, 30);
    fileText.setPromptText("File ");

    updateMenu = false;
  }

  public void submit() {
    println("submit");
    checkTextFields();
  }

  void clear() {
    println("clear");
    for (int i = 0; i<textFields.size(); i++) {
      hmap.put(i, new ControllerData());

      textFields.get(i).setText("");
    }
  }

  void load() {
    String fname = G4P.selectInput("Input Dialog", "", "Choose FIle");
    fileText.setText(fname);
    if(fname!=null){
      fileSelected(new File(fname));
    }
    println("file name :"+fname);
    //  selectInput("Select a file to process:", "fileSelected");
  }

  void save() {
    String fileName =  fileText.getText();
    String[] array = new String[bands];

    HashMap<Integer, ControllerData> hmap = new HashMap<Integer, ControllerData>();

    for (int i = 0; i<bands; i++) {
      hmap.put(i, new ControllerData());
      GTextField field = textFields.get(i);
      if (field!=null) {
        String text =  field.getText();
        if (text.length() > 0) {
          println("value on "+i+"  is "+text);
          hmap.get(i).path = text;
        }
        array[i] = i+"#"+field.getText()+"#"+0.0f;
      }
    }
    String fname = G4P.selectOutput("Input Dialog", "", "Choose FIle");
    saveStrings(fname, array);
    fileText.setText(fname);

    println("strings saved "+fileName+"   "+array.length);
  }

  public void fileSelected(File selection) {
    if (selection == null) {
      println("Window was closed or the user hit cancel.");
    } else {
      println("User selected " + selection.getAbsolutePath());
     
        loadMyPreset(selection.getAbsolutePath());
      
    }
  }

  void loadMyPreset(String filename) {
    try {
      String[] lines = loadStrings(filename);
      for (int i=0; i<lines.length; i++) {
        String[] newSplit = split(lines[i], "#");
        GTextField field = textFields.get(i);
        if (field!=null) {
          field.setText(newSplit[1]);
        }
      }
       println("File loaded!");

    }
    catch(Exception e) {
      println("Error loading file!");
    }
  }

  void checkTextFields() {
    HashMap<Integer, ControllerData> hmap = new HashMap<Integer, ControllerData>();

    for (int i = 0; i<bands; i++) {
      hmap.put(i, new ControllerData());
      GTextField field = textFields.get(i);
      if (field!=null) {
        String text =  field.getText();
        if (text.length() > 0) {
          println("value on "+i+"  is "+text);
          hmap.get(i).path = text;
        }
      }
    }
    listener.onValueChanged(hmap);
  }
}



interface OnValueChanged {
  void onValueChanged(HashMap<Integer, ControllerData> newMap);
}
