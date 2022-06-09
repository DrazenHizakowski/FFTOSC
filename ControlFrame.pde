
import oscP5.*;
import controlP5.*;
import static controlP5.ControlP5.*;
import java.util.*;
import java.util.Map.Entry;

public class ControlFrame extends PApplet {

  int w, h;
  PApplet parent;
  ControlP5 cp5;
  Sound sound;
  OnValueChanged listener;
  
  public ControlFrame(PApplet _parent, int _w, int _h, String _name, OnValueChanged listener,Sound sound) {
    super();   
    parent = _parent;
    this.listener = listener;
   // this.cp5 = control;
    this.sound = sound;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h);
  }

  public void setup() {

    surface.setLocation(10, 10);
    cp5 = new ControlP5(this);
    String[] soundList = Sound.list();
   
   /*
   MenuList m = new MenuList( cp5, "menu", 200, 200 );
  m.setPosition(40, 40);
  // add some items to our menuList
  for (int i=0;i<soundList.length;i++) {
    m.addItem(makeItem("Device-"+i, soundList[i], "", createImage(50, 50, RGB)));
  }
     */
 for(int i = 0;i<bands;i++){
 
   cp5.addTextfield("address"+i)
     .setPosition(50,25*i)
     .setSize(400,20)
     .setFocus(true)
     .setColor(color(255,0,0));
    cp5.addTextlabel("label"+i)
                    .setText(str(i))
                    .setPosition(10,25*i)
                    .setColorValue(0xffffff00)
                    .setFont(createFont("Georgia",20))
                    ;
 }
   cp5.addButton("submit")
     .setPosition(480,25)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;
    cp5.addButton("clear")
     .setPosition(480,70)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;   
     
     cp5.addButton("save")
     .setPosition(480,140)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;
    cp5.addButton("load")
     .setPosition(480,235)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;   
     cp5.addTextfield("file_name")
     .setPosition(480,185)
     .setSize(80,30)
   
     ;   
     
  }
  void draw(){
     background(0);
  }
  
  void submit(){
      println("submit");
      checkTextFields();
  }
  void clear(){
    println("clear");
      for(int i = 0;i<bands;i++){
    hmap.put(i,new ControllerData());
    Textfield field = cp5.get(Textfield.class,"address"+i);
    if(field!=null){
      field.setText("");
      }
    }
  
  
  }
  
  void load(){
    selectInput("Select a file to process:", "fileSelected");
  }
  
  void save(){
    String fileName =  cp5.get(Textfield.class,"file_name").getText();
    String[] array = new String[bands];
    if(fileName.length()>0){
            HashMap<Integer, ControllerData> hmap = new HashMap<Integer, ControllerData>();
    
    for(int i = 0;i<bands;i++){
      hmap.put(i,new ControllerData());
      Textfield field = cp5.get(Textfield.class,"address"+i);
    if(field!=null){
         String text =  field.getText();
      if(text.length() > 0){
        println("value on "+i+"  is "+text);
        hmap.get(i).path = text;
      }
            array[i] = i+"#"+field.getText()+"#"+0.0f;
    }
  
  }
  saveStrings(fileName,array);
  println("strings saved "+fileName+"   "+array.length);
    }
  }
  
  public void fileSelected(File selection) {
    if (selection == null) {
      println("Window was closed or the user hit cancel.");
    } else {
      println("User selected " + selection.getAbsolutePath());
      int lastIndex = selection.getAbsolutePath().lastIndexOf("/");
      if(lastIndex!=-1){
        String fileName = selection.getAbsolutePath().substring(lastIndex + 1);
        cp5.get(Textfield.class,"file_name").setText(fileName);
         loadMyPreset(fileName);
      }
    }
  }
  
  void loadMyPreset(String filename){
    try{
       String[] lines = loadStrings(filename);
      for(int i=0;i<lines.length;i++){
        String[] newSplit = split(lines[i],"#");
      Textfield field = cp5.get(Textfield.class,"address"+i);
    if(field!=null){
         field.setText(newSplit[1]);
           
    }
  
  }
      
    }catch(Exception e){
      
    }
  }
  
  void checkTextFields(){
    HashMap<Integer, ControllerData> hmap = new HashMap<Integer, ControllerData>();
    
  for(int i = 0;i<bands;i++){
    hmap.put(i,new ControllerData());
    Textfield field = cp5.get(Textfield.class,"address"+i);
    if(field!=null){
       String text =  field.getText();
      if(text.length() > 0){
        println("value on "+i+"  is "+text);
        hmap.get(i).path = text;
      }
    }
  
  }
  listener.onValueChanged(hmap);
}
}



interface OnValueChanged{
  void onValueChanged(HashMap<Integer, ControllerData> newMap);
}

Map<String, Object> makeItem(String theHeadline, String theSubline, String theCopy, PImage theImage) {
  Map m = new HashMap<String, Object>();
  m.put("headline", theHeadline);
  m.put("subline", theSubline);
  m.put("copy", theCopy);
  m.put("image", theImage);
  return m;
}

void menu(int i) {
  println("got some menu event from item with index "+i);
}
/*
public void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom("menu")){
    Map m = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    println("got a menu event from item : "+m);
  }
}*/

class MenuList extends Controller<MenuList> {
PFont f1, f2;

  float pos, npos;
  int itemHeight = 100;
  int scrollerLength = 40;
  List< Map<String, Object>> items = new ArrayList< Map<String, Object>>();
  PGraphics menu;
  boolean updateMenu;

  MenuList(ControlP5 c, String theName, int theWidth, int theHeight) {
    super( c, theName, 0, 0, theWidth, theHeight );
    c.register( this );
    menu = createGraphics(getWidth(), getHeight() );
      f1 = createFont("Helvetica", 20);
  f2 = createFont("Helvetica", 12);
    
    setView(new ControllerView<MenuList>() {

      public void display(PGraphics pg, MenuList t ) {
        if (updateMenu) {
          updateMenu();
        }
        if (inside() ) {
          menu.beginDraw();
          int len = -(itemHeight * items.size()) + getHeight();
          int ty = int(map(pos, len, 0, getHeight() - scrollerLength - 2, 2 ) );
          menu.fill(255 );
          menu.rect(getWidth()-4, ty, 4, scrollerLength );
          menu.endDraw();
        }
        pg.image(menu, 0, 0);
      }
    }
    );
    updateMenu();
  }

  /* only update the image buffer when necessary - to save some resources */
  void updateMenu() {
    int len = -(itemHeight * items.size()) + getHeight();
    npos = constrain(npos, len, 0);
    pos += (npos - pos) * 0.1;
    menu.beginDraw();
    menu.noStroke();
    menu.background(255, 64 );
    menu.textFont(cp5.getFont().getFont());
    menu.pushMatrix();
    menu.translate( 0, pos );
    menu.pushMatrix();

    int i0 = PApplet.max( 0, int(map(-pos, 0, itemHeight * items.size(), 0, items.size())));
    int range = ceil((float(getHeight())/float(itemHeight))+1);
    int i1 = PApplet.min( items.size(), i0 + range );

    menu.translate(0, i0*itemHeight);

    for (int i=i0;i<i1;i++) {
      Map m = items.get(i);
      menu.fill(255, 100);
      menu.rect(0, 0, getWidth(), itemHeight-1 );
      menu.fill(255);
      menu.textFont(f1);
      menu.text(m.get("headline").toString(), 10, 20 );
      menu.textFont(f2);
      menu.textLeading(12);
      menu.text(m.get("subline").toString(), 10, 35 );
      menu.text(m.get("copy").toString(), 10, 50, 120, 50 );
      menu.image(((PImage)m.get("image")), 140, 10, 50, 50 );
      menu.translate( 0, itemHeight );
    }
    menu.popMatrix();
    menu.popMatrix();
    menu.endDraw();
    updateMenu = abs(npos-pos)>0.01 ? true:false;
  }
  
  /* when detecting a click, check if the click happend to the far right, if yes, scroll to that position, 
   * otherwise do whatever this item of the list is supposed to do.
   */
  public void onClick() {
    if (getPointer().x()>getWidth()-10) {
      npos= -map(getPointer().y(), 0, getHeight(), 0, items.size()*itemHeight);
      updateMenu = true;
    } 
    else {
      int len = itemHeight * items.size();
      int index = int( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
      setValue(index);
    }
  }
  
  public void onMove() {
  }

  public void onDrag() {
    npos += getPointer().dy() * 2;
    updateMenu = true;
  } 

  public void onScroll(int n) {
    npos += ( n * 4 );
    updateMenu = true;
  }

  void addItem(Map<String, Object> m) {
    items.add(m);
    updateMenu = true;
  }
  
  Map<String,Object> getItem(int theIndex) {
    return items.get(theIndex);
  }
}
