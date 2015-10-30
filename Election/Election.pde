import de.bezier.data.*;
import java.util.*;
import java.lang.Exception.*;
// KINECT SETIT
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
// /KINECT SETIT

XlsReader reader;
JSONObject json;
PShape map;
Boolean locked;
Boolean info = false;
int startX;
int startY;
int origoX = 0;
int origoY = 0;
float zoomX = 1024;
float zoomY = 617;
float zoomYX = 1024 / 617;
int x;
int y;
int infox;
int infoy;
int year = 2012;
boolean firstPressed = true;
PShape hiddenMap; // hidden Map
ArrayList<State> states;
District activeDistrict;
PImage pic;
Boolean mapMode;
Ball[] balls = new Ball[235];
boolean detailView;
String activeYear;


void setup() {
  size(1200,680);
  activeYear = "2012";
  frame.setResizable(true);
  setupData(2012);
  mapMode = true;
  detailView = false;
  setupBalls();
  
  // KINECT SETIT:
  
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
  
  // /KINECT SETIT
}
  
  void draw() {
  // KINECT SETIT
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
  // /KINECT SETIT
  background(242, 242, 242);
  
  if(mapMode) {
  drawHiddenStates();
  drawVisibleStates();
  drawMenu();
  }
  else if(!mapMode) {
    drawBalls();
    drawMenu();
  }
  fill(255,255,255);
  ellipse(mouseX, mouseY, 20, 20);
}

void setupData(int electionYear) {
  //candidates = new ArrayList<Candidate>();
  states = new ArrayList<State>();
  
  
  reader = new XlsReader( this, "data/formatted_data_" + electionYear + ".xls");
  reader.firstRow();
  
  map = loadShape("data/us_congressional_districts.svg");
  hiddenMap = loadShape("data/us_congressional_districts.svg");
  smooth();

  
  while (reader.hasMoreRows() ) {
    reader.nextRow();
    reader.firstCell();    
    String stateAbbreviation = reader.getString();    
    reader.nextCell();    
    String state = reader.getString();    
    State currentState;    
    if(states.size() == 0 || states.get(states.size()-1).name != state) {
       currentState = new State(state, stateAbbreviation);
       states.add(currentState);
    }
    else currentState = states.get(states.size()-1);   
    reader.nextCell();        
    String district = reader.getString();    
    District currentDistrict;    
    if(currentState.districts.size() == 0 || currentState.districts.get(currentState.districts.size()-1).number != district){
      currentDistrict = new District(currentState, district, map);
      currentState.districts.add(currentDistrict);
    }
    else currentDistrict = currentState.districts.get(currentState.districts.size()-1);    
    reader.nextCell();    
    String candidateID = reader.getString();    
    reader.nextCell();    
    String name = reader.getString();
    reader.nextCell();    
    String party = reader.getString();    
    reader.nextCell();
    reader.nextCell();
    Float votesPercent = reader.getFloat() * 100;  
    
    reader.nextCell();   
    Candidate newCandidate = new Candidate(name, party, candidateID);   
    currentDistrict.candidates.put(newCandidate, votesPercent);
    }

    for(int i = 0; i < states.size(); i++) {
    for(int j = 0; j < states.get(i).districts.size(); j++) {
      states.get(i).districts.get(j).setUp();
      states.get(i).districts.get(j).getWinner(year);
      states.get(i).districts.get(j).getRunnerUp(year);
   }
  }
}


void drawVisibleStates() {
   for(int j = 0; j < states.size(); j++) {    
   for(int i= 0; i < states.get(j).districts.size(); i++) {   
     if(states.get(j).districts.get(i).district != null) {
       states.get(j).districts.get(i).district.disableStyle();
       stroke(color(255,255,255));
       fill(states.get(j).districts.get(i).districtColor);  
       shape(states.get(j).districts.get(i).district, x ,y, zoomX, zoomY);
     }
   }
  }
  if(activeDistrict != null) {
  //activeDistrict.district.disableStyle();
  String districtDesc = activeDistrict.state.abbreviation + " - " + activeDistrict.number;
  fill(0,0,0,50);
  shape(activeDistrict.district, x, y, zoomX,zoomY);
  stroke(0,0,0);
  fill(219,189,149);
  rect(mouseX + 15,mouseY - 30, 100,30);
  fill(100);
  textSize(13);
  text(districtDesc, mouseX + 45, mouseY -22, 150,40);
  }
}

void drawHiddenStates() {
  for(int j = 0; j < states.size(); j++) {    
   for(int i= 0; i < states.get(j).districts.size(); i++) {   
     if(states.get(j).districts.get(i).district != null) {
       states.get(j).districts.get(i).district.disableStyle();
       color c = color(j,i,0);
       fill(c);
       shape(states.get(j).districts.get(i).district, x ,y, zoomX, zoomY);
       if(get(mouseX,mouseY) == c) {
         activeDistrict = states.get(j).districts.get(i);
       }
     }
   }
  }
}

void drawMenu(){
 int textwidth = width / 13;
 
 fill(65, 65, 65, 191);
 noStroke();
 rect(0, height - 35, width, height);
 
 fill(255, 255, 255);
 PFont font;
 font = loadFont("Kalinga-48.vlw");
 textFont(font, 16);
 if(activeYear == "2002") fill(0,0,0);
 text(2002, textwidth * 1, height - 10);
 fill(255, 255, 255);
 if(activeYear == "2004") fill(0,0,0);
 text(2004, textwidth * 3, height - 10);
 fill(255, 255, 255);
 if(activeYear == "2006") fill(0,0,0);
 text(2006, textwidth * 5, height - 10);
 fill(255, 255, 255);
 if(activeYear == "2008") fill(0,0,0);
 text(2008, textwidth * 7, height - 10);
 fill(255, 255, 255);
 if(activeYear == "2010") fill(0,0,0);
 text(2010, textwidth * 9, height - 10);
 fill(255, 255, 255);
 if(activeYear == "2012") fill(0,0,0);
 text(2012, textwidth * 11, height - 10);
 
}

void mousePressed() {
  if(firstPressed) {
   firstPressed = false;
   startX = mouseX;
   startY = mouseY; 
  }
}

void mouseDragged() {
  x = origoX + (mouseX - startX);
  y = origoY + (mouseY - startY);
}

void mouseReleased() {
  firstPressed = true;
  origoX = x;
  origoY = y;
}

void keyPressed() {
   if(keyCode == UP) {
    zoomY += 25;
    zoomX += 25 * zoomYX;
   } 
   if(keyCode == DOWN) {
     zoomY -= 25;
     zoomX -= 25 * zoomYX;
   }
   if(keyCode == CONTROL) {
     zoomX = 1024;
     zoomY = 617;
   }
   if(keyCode == SHIFT) {
     setupData(2010);
     setupBalls();
   }
   if(keyCode == 32) {
     int textBox = width / 13;
     if(mouseY > height - 20) {
       if(mouseX > textBox && mouseX < textBox * 2) {
         setupData(2002);
         setupBalls();
         activeYear="2002";
       }
       else if(mouseX > textBox * 3 && mouseX < textBox * 4) {
         setupData(2004);
         setupBalls();
         activeYear="2004";
       }
       else if(mouseX > textBox * 5 && mouseX < textBox * 6) {
         setupData(2006);
         setupBalls();
         activeYear="2006";
       }
       else if(mouseX > textBox * 7 && mouseX < textBox * 8) {
         setupData(2008);
         setupBalls();
         activeYear="2008";
       }
       else if(mouseX > textBox * 9 && mouseX < textBox * 10) {
         setupData(2010);
         setupBalls();
         activeYear="2010";
       } else {
         setupData(2012);
         setupBalls();
         activeYear="2012";
       }} else {
           if(!detailView) {
           noLoop();
           fill(45, 45, 45, 191);
           rect(width - 400, 35, 365, 550, 7);
           String headline = activeDistrict.state.name + "'s " + activeDistrict.number  + "th " + "\n" + "Congressional District";
           textSize(20);
           fill(255,255,255);
           text(headline, width - 380, 70);
           String winningpercent = String.format("%.1f", activeDistrict.candidates.get(activeDistrict.getWinner(year)));
           String runningUppercent = String.format("%.1f", activeDistrict.candidates.get(activeDistrict.getRunnerUp(year)));
           String nameQueryString = activeDistrict.getWinner(year).firstName + "_" + activeDistrict.getWinner(year).lastName;
           String link = "https://en.wikipedia.org/w/api.php?action=query&titles="+ nameQueryString +"&prop=pageimages&format=json&pithumbsize=200"; 

           String RUfirstName = activeDistrict.getRunnerUp(year).firstName;
           String RUlastName = activeDistrict.getRunnerUp(year).lastName;
           text(activeDistrict.getWinner(year).firstName + " " + activeDistrict.getWinner(year).lastName + " - " + activeDistrict.getWinner(year).party + 
                " " + winningpercent + "%" +
                "\n" + "\n"+ "\n" +  "\n" + "\n"+ "Runner Up:" + "\n" +
                RUfirstName + " " + RUlastName  + " - " + activeDistrict.getRunnerUp(year).party + " " + runningUppercent + "%", width - 380, 400);
         String url = "http://pcforalla.idg.se/polopoly_fs/1.539126.1386947577!teaserImage/imageTypeSelector/localImage/3217596809.jpg";
         String web = loadStrings(link)[0];
         if(web.charAt(0) == '{' && web.contains("http")) {
           JSONObject json = loadJSONObject(link);
           JSONObject query = json.getJSONObject("query");
           JSONObject pages = query.getJSONObject("pages");
           String page = pages.toString();
           int startLink = page.indexOf("http");
           int endLink = 2;
           if(page.contains(".jpeg")) {
             endLink = page.indexOf(".jpeg\"") + 5;
           } else {
             endLink = page.indexOf(".jpg\"") + 4;
           }
           url = page.substring(startLink, endLink);
           }
          PImage img = loadImage(url);
          image(img, width - 350, 150); 
          detailView = true;
        }
     }
   }
   if(keyCode == 65) {
     mapMode = false;
   }
  
}

//Placeholder implementation for changing year
void keyReleased() {
  if(keyCode == SHIFT) {
    setupData(2012);
    setupBalls();
  }
  if(keyCode == 32) {
     detailView = false;
     loop();
     info = false;
   }
   if(keyCode == 65) {
     mapMode = true;
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
/*void keyPressed()
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
*/
void reset() {
  drag = false;
  select = false;
  tracking = false;
}

  
  
  
