import de.bezier.data.*;
import java.util.*;

XlsReader reader;
JSONObject json;
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
ArrayList<Candidate> candidates;
ArrayList<State> states;
District activeDistrict;
PImage pic;
//ArrayList<PShape> districtShapes = new ArrayList<PShape>();


void setup() {
  size(1200,680);
  surface.setResizable(true);
  setupData(2012);
}
  
  void draw() {
  
  background(255);
  drawHiddenStates();
  drawVisibleStates();

  fill(255,255,255);
  ellipse(mouseX, mouseY, 20, 20);
}

void setupData(int electionYear) {
  candidates = new ArrayList<Candidate>();
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
    Integer votes = reader.getInt();  
    reader.nextCell();
    reader.nextCell();   
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
         //println(activeDistrict.stateCode + " " + activeDistrict.number + " won by " + activeDistrict.getWinner(2012).toString());
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
   if(keyCode == SHIFT) {
     setupData(2012);
   }
   if(keyCode == 32) {
         noLoop();
         fill(200,220,255,215);
         rect(50,50,width-100,height-100);
         String headline = activeDistrict.state.name + "'s " + activeDistrict.number + "th Congressional District";
         Candidate winningCandidate = activeDistrict.getWinner(2012);
         String winner = winningCandidate.firstName + " " + winningCandidate.lastName + "(" + winningCandidate.party + ")";
         Integer votes = activeDistrict.candidates_2012.get(winningCandidate);
         textSize(40);
         fill(0,0,0);
         text(headline, 80 + width/6, 100);
         textSize(29);
         text("Winner" + " " + winner + " with " + votes + " votes.", 80, 200); 
         //palauttaa jsonin
         // https://en.wikipedia.org/w/api.php?action=query&titles=TÄHÄN HAKUTERMIT!!!&prop=pageimages&format=json&pithumbsize=400.json  noLoop();
   }
  
}

//Placeholder implementation for changing year
void keyReleased() {
  if(keyCode == SHIFT) {
    setupData(2004);
  }
  if(keyCode == 32) {
     loop();
   }
}



  
  
  