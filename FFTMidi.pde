import controlP5.*;
import processing.sound.*;
import oscP5.*;
import netP5.*;
import java.util.HashMap;

OscP5 oscP5;

NetAddress myBroadcastLocation;
FFT fft;
AudioIn input;
ControlP5 cp5;
ControlFrame cf;

int bands = 32;

// Define a smoothing factor which determines how much the spectrums of consecutive
// points in time should be combined to create a smoother visualisation of the spectrum.
// A smoothing factor of 1.0 means no smoothing (only the data from the newest analysis
// is rendered), decrease the factor down towards 0.0 to have the visualisation update
// more slowly, which is easier on the eye.
float smoothingFactor = 0.2;

// Create a vector to store the smoothed spectrum data in
float[] sum = new float[bands];

// Variables for drawing the spectrum:
// Declare a scaling factor for adjusting the height of the rectangles
int scale = 5;
// Declare a drawing variable for calculating the width of the
float barWidth;
String[] controls = new String[bands];
CheckBox checkbox;
int barHeight = 720;
HashMap<Integer, ControllerData> hmap = new HashMap<Integer, ControllerData>();

Sound s;
public void setup() {
  size(1280, 850);
      cp5 = new ControlP5(this);
  s = new Sound(this);
  
    cf = new ControlFrame(this, 600, 850, "Controls",new OnOSCValueListener(),s);
    PFont font = createFont("arial",20);

  background(255);
      barWidth = width/float(bands);

      checkbox = cp5.addCheckBox("checkBox")
                .setPosition(0, barHeight-barWidth)
                .setSize(int(barWidth), int(barWidth))
                .setItemsPerRow(bands)
                .setSpacingColumn(0)
                .setSpacingRow(0);
   for(int i=0;i<controls.length;i++){
     controls[i] = str(i);
     checkbox.addItem(str(i),i*barWidth);
      cp5.addTextlabel("checkBoxLabel"+i)
                    .setText(str(i))
                    .setPosition(i*barWidth,720)
                    .setColorValue(0xffffff00)
                    .setFont(createFont("Georgia",20))
                    ;
     hmap.put(i,new ControllerData());  
 }
  Sound.list();
   
  

 
 // s.inputDevice(12);
  input = new AudioIn(this, 0);

  input.start();


  oscP5 = new OscP5(this, 12000);
  myBroadcastLocation = new NetAddress("127.0.0.1", 32000);

  fft = new FFT(this, bands);
  fft.input(input);
}

public void draw() {
  // Set background color, noStroke and fill color
  background(125, 255, 125);
    barWidth = width/float(bands);

  fill(255, 0, 150);
  noStroke();

  // Perform the analysis
  fft.analyze();

  for (int i = 0; i < bands; i++) {
    Toggle item = checkbox.getItem(i);
    // Smooth the FFT spectrum data by smoothing factor
    sum[i] += (fft.spectrum[i] - sum[i]) * smoothingFactor;
    float value = -sum[i]*(barHeight-barWidth)*scale;
     if(item.getBooleanValue()){
        //   println("givven vlaue "+value);
        
         float mapped= map(value*-1, 0f, height,0,1);
         sendMessage(hmap.get(i).path,constrain(mapped,0,1));
     }
    // Draw the rectangles, adjust their height using the scale factor
    rect(i*barWidth, barHeight-barWidth, barWidth,value );
  }
  fill(0,0,0);
  rect(0,barHeight,width,height);
}

class OnOSCValueListener implements OnValueChanged{
     void onValueChanged(HashMap<Integer, ControllerData> newMap){
        hmap = newMap;
        println("received new map");
      }
}

void sendMessage(String path, float value){
  if(path==null || path.length()<4){
    return;
  }
    println("sending message on channel "+path+"  "+value);

  OscMessage myOscMessage = new OscMessage(path);
  myOscMessage.add(value);
  oscP5.send(myOscMessage, myBroadcastLocation);
}

void keyPressed() {
  OscMessage m;
  switch(key) {
    case('c'):
    /* connect to the broadcaster */
    m = new OscMessage("/server/connect", new Object[0]);
    oscP5.flush(m, myBroadcastLocation);
    break;
    case('d'):
    /* disconnect from the broadcaster */
    m = new OscMessage("/server/disconnect", new Object[0]);
    oscP5.flush(m, myBroadcastLocation);
    break;
  }
}

void mousePressed() {
  /* create a new OscMessage with an address pattern, in this case /test. */
  OscMessage myOscMessage = new OscMessage("/test");
  /* add a value (an integer) to the OscMessage */
  myOscMessage.add(100);
  /* send the OscMessage to a remote location specified in myNetAddress */
  oscP5.send(myOscMessage, myBroadcastLocation);
}

void amp(float theColor) {
  println("a slider event. setting background to "+theColor);
}



public void controlEvent(ControlEvent theEvent) {
    println("got some event ");

  if(theEvent.isFrom("menu")){
    Map m = ((MenuList)theEvent.getController()).getItem(int(theEvent.getValue()));
    println("got a menu event from item : "+m);
  }
}

/*
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
  }
}
*/
public void address(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
}
