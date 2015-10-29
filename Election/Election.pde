import de.bezier.data.*;
import java.util.*;
import java.lang.Exception.*;

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
//ArrayList<Candidate> candidates;
ArrayList<State> states;
District activeDistrict;
PImage pic;
Boolean mapMode;
Ball[] balls = new Ball[235];
//ArrayList<PShape> districtShapes = new ArrayList<PShape>();


void setup() {
  size(1200,680);
  frame.setResizable(true);
  setupData(2012);
  mapMode = true;
  setupBalls();
}
  
  void draw() {
  
  background(242, 242, 242);
  
  if(mapMode) {
  drawHiddenStates();
  drawVisibleStates();
  drawMenu();
  }
  else if(!mapMode) {
    drawBalls();
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
    Integer votes = reader.getInt();  
    reader.nextCell();
    reader.nextCell();   
    Candidate newCandidate = new Candidate(name, party, candidateID);   
    currentDistrict.candidates_2012.put(newCandidate, votes);
    }

    for(int i = 0; i < states.size(); i++) {
    for(int j = 0; j < states.get(i).districts.size(); j++) {
      states.get(i).districts.get(j).setUp();
      states.get(i).districts.get(j).getWinner(year);
      states.get(i).districts.get(j).getRunnerUpper(year);
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

void drawMenu(){
 int textwidth = width / 13;
 
 fill(65, 65, 65, 191);
 noStroke();
 rect(0, height - 35, width, height);
 
 fill(255, 255, 255);
 PFont font;
 font = loadFont("Kalinga-48.vlw");
 textFont(font, 16);
 text(2002, textwidth * 1, height - 10);
 text(2004, textwidth * 3, height - 10);
 text(2006, textwidth * 5, height - 10);
 text(2008, textwidth * 7, height - 10);
 text(2010, textwidth * 9, height - 10);
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
       }
       else if(mouseX > textBox * 3 && mouseX < textBox * 4) {
         setupData(2004);
       }
       else if(mouseX > textBox * 5 && mouseX < textBox * 6) {
         setupData(2006);
       }
       else if(mouseX > textBox * 7 && mouseX < textBox * 8) {
         setupData(2008);
       }
       else if(mouseX > textBox * 9 && mouseX < textBox * 10) {
         setupData(2010);
       } else {
         setupData(2012);
       }} else {
         noLoop();
         fill(45, 45, 45, 191);
         rect(width - 400, 35, 365, 550, 7);
         String headline = activeDistrict.state.name + "'s " + activeDistrict.number  + "th " + "\n" + "Congressional District";
         textSize(20);
         fill(255,255,255);
         text(headline, width - 380, 70);
         String nameQueryString = activeDistrict.getWinner(year).firstName + "_" + activeDistrict.getWinner(year).lastName;
         String link = "https://en.wikipedia.org/w/api.php?action=query&titles="+ nameQueryString +"&prop=pageimages&format=json&pithumbsize=200"; 
         String RUfirstName = activeDistrict.getRunnerUpper(year).firstName;
         String RUlastName = activeDistrict.getRunnerUpper(year).lastName;
         text(activeDistrict.getWinner(year).firstName + " " + activeDistrict.getWinner(year).lastName + "\n" + 
              RUfirstName + " " + RUlastName, width - 380, 400);
         activeDistrict.getRunnerUpper(year);
         String url = "https://upload.wikimedia.org/wikipedia/commons/e/e9/Official_portrait_of_Barack_Obama.jpg";
         try {
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
         } catch (Exception e) {
           print("Barack");
         }
           PImage img = loadImage(url);
           image(img, width - 350, 150);        
         
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
     loop();
     info = false;
   }
   if(keyCode == 65) {
     mapMode = true;
   }
}




  
  
  