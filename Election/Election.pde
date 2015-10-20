import de.bezier.data.*;
import java.util.*;

XlsReader reader;

PShape map;
Boolean locked;
int startX;
int startY;
int origoX = 0;
int origoY = 0;
float zoomX = 1024;
float zoomY = 617;
float zoomYX = 1024 / 617;
int x;
int y;
boolean firstPressed = true;
PShape hiddenMap; // hidden Map
ArrayList<Candidate> candidates = new ArrayList<Candidate>();
ArrayList<State> states = new ArrayList<State>();
District activeDistrict;
//ArrayList<PShape> districtShapes = new ArrayList<PShape>();


void setup() {
  size(1200,680);
  surface.setResizable(true);
  frameRate(20);
  
  reader = new XlsReader( this, "data/formatted_data_2012.xls");
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
    
    Integer votes = reader.getInt();
    
    reader.nextCell();
    
    //Float percentage = reader.getFloat();
    
    reader.nextCell();
    
    //String winner = reader.getString();
    
    Candidate newCandidate = new Candidate(name, party, candidateID);
    
    currentDistrict.candidates_2012.put(newCandidate, votes);
    }

    for(int i = 0; i < states.size(); i++) {
    for(int j = 0; j < states.get(i).districts.size(); j++) {
      states.get(i).districts.get(j).setUp();
      states.get(i).districts.get(j).getWinner(2012);
   }
  }
    
    
  }
  
  void draw() {
  
  background(255);
  drawHiddenStates();
  drawVisibleStates();

  fill(255,255,255);
  ellipse(mouseX, mouseY, 20, 20);
}

void drawVisibleStates() {
   for(int j = 0; j < states.size(); j++) {    
   for(int i= 0; i < states.get(j).districts.size(); i++) {   
     if(states.get(j).districts.get(i).district != null) {
       states.get(j).districts.get(i).district.disableStyle();
       fill(states.get(j).districts.get(i).districtColor);  
       shape(states.get(j).districts.get(i).district, x ,y, zoomX, zoomY);
     }
   }
  }
  if(activeDistrict != null) {
  activeDistrict.district.disableStyle();
  fill(0,0,0);
  shape(activeDistrict.district, x, y, zoomX,zoomY);
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
         println(activeDistrict.stateCode + " " + activeDistrict.number + " won by " + activeDistrict.getWinner(2012).toString());
       }
     }
   }
  }
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
  
}



  
  
  