/* --------------------------------------------------------------------------
 * SimpleOpenNI Hands3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 * This demos shows how to use the gesture/hand generator.
 * It's not the most reliable yet, a two hands example will follow
 * ----------------------------------------------------------------------------
 */
 
import java.util.Map;
import java.util.Iterator;

import SimpleOpenNI.*;

SimpleOpenNI kinect;
boolean select = false;
boolean drag = false;
boolean tracking = false;
int handVecListSize = 20;
Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
PVector cursor;
void setup()
{

  frameRate(30);
  size(640,480);

  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }   

  // enable depthMap generation 
  kinect.enableDepth();
  
  // disable mirror
  kinect.setMirror(true);

  // enable hands + gesture generation
  //kinect.enableGesture();
  kinect.enableHand();
  kinect.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE);
  kinect.startGesture(SimpleOpenNI.GESTURE_WAVE);
  kinect.startGesture(SimpleOpenNI.GESTURE_CLICK);
  
  // set how smooth the hand capturing should be
  //kinect.setSmoothingHands(.5);
  cursor = new PVector(-200,-200);
 }

void draw()
{
  // update the cam
  kinect.update();

  //image(kinect.depthImage(),0,0);
    
  // draw the tracked hands
  if(handPathList.size() > 0)  
  {    
    Iterator itr = handPathList.entrySet().iterator();     
    while(itr.hasNext())
    {
      Map.Entry mapEntry = (Map.Entry)itr.next(); 
      int handId =  (Integer)mapEntry.getKey();
      ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
      PVector p;
      PVector p2d = new PVector();
      
        stroke(userClr[ (handId - 1) % userClr.length ]);
        noFill(); 
        strokeWeight(1);        
        Iterator itrVec = vecList.iterator(); 
        beginShape();
          while( itrVec.hasNext() ) 
          { 
            p = (PVector) itrVec.next(); 
            
            kinect.convertRealWorldToProjective(p,p2d);
            vertex(p2d.x,p2d.y);
          }
        endShape();   
  
        stroke(userClr[ (handId - 1) % userClr.length ]);
        strokeWeight(4);
        p = vecList.get(0);
        kinect.convertRealWorldToProjective(p,p2d);
        point(p2d.x,p2d.y);
 
    }        
  }
}


// -----------------------------------------------------------------
// hand events

void onNewHand(SimpleOpenNI curkinect,int handId,PVector pos)
{
  //println("onNewHand - handId: " + handId + ", pos: " + pos);
 
  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);
  
  handPathList.put(handId,vecList);
}

void onTrackedHand(SimpleOpenNI curkinect,int handId,PVector pos)
{
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );
  
  ArrayList<PVector> vecList = handPathList.get(handId);
  if(vecList != null)
  {
    vecList.add(0,pos);
    if(vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1); 
  }
  cursor = pos;
  //println(cursor.x + " " + cursor.y);
  
}

void onLostHand(SimpleOpenNI curkinect,int handId)
{
  println("LOST");
  handPathList.remove(handId);
  if (handPathList.size() < 1) {
    reset();
  }
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curkinect,int gestureType, PVector pos)
{
  //println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
  if (gestureType == 0) {
    println("WAVE");
    //int handId = kinect.startTrackingHand(pos);
    if (!select) select = true; else select = false;
  } else if (gestureType == 1) {
    println("CLICK");
    //int handId = kinect.startTrackingHand(pos);
    if (!drag) drag = true; else drag = false; 
  } else if (gestureType == 2) {
    //println("RAISE_HAND");
    if (!tracking) {
      int handId = kinect.startTrackingHand(pos);
      tracking = true;
    }
    
  }
}

// -----------------------------------------------------------------
// Keyboard event
void keyPressed()
{

  switch(key)
  {
  case ' ':
    kinect.setMirror(!kinect.mirror());
    break;
  case '1':
    kinect.setMirror(true);
    break;
  case '2':
    kinect.setMirror(false);
    break;
  }
}

void reset() {
  drag = false;
  select = false;
  tracking = false;
}
