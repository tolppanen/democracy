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
  setupKinect();
  thread("drawKinect");
}
  
void draw() {
  updateGestures();
  background(242, 242, 242);
  if(mapMode) {
  //drawHiddenStates();
  //drawVisibleStates();
  //drawMenu();
}
  else if(!mapMode) {
    drawBalls();
    drawMenu();
  }
  fill(255,255,255);
  ellipse(cursor.x, cursor.y, 20, 20);
}

void setupData(int electionYear) {
  //candidates = new ArrayList<Candidate>();
  states = new ArrayList<State>();
  
  
  reader = new XlsReader( this, "data/formatted_data_" + electionYear + ".xls");
  reader.firstRow();
  
  map = loadShape("data/us_congressional_districts.svg");
  hiddenMap = loadShape("data/us_congressional_districts.svg");
  smooth();
  
  int col = 0;
  int row = 0;
  while (reader.hasMoreRows()) {
    int previousrow = Math.max(row - 1, 0);
    if(reader.getString(row, col + 2) != reader.getString(previousrow, col + 2)) {
      for(int i = 0; i < 2; i++) {
        col = 0;
        String stateAbbreviation = reader.getString(row, col);
        String state = reader.getString(row, col + 1);
        State currentState;    
        if(states.size() == 0 || states.get(states.size()-1).name != state) {
         currentState = new State(state, stateAbbreviation);
         states.add(currentState);
        } else currentState = states.get(states.size()-1);   
        String district = reader.getString(row, col + 2);
        District currentDistrict;    
        if(currentState.districts.size() == 0 || currentState.districts.get(currentState.districts.size()-1).number != district){
          currentDistrict = new District(currentState, district, map);
          currentState.districts.add(currentDistrict);
        } else currentDistrict = currentState.districts.get(currentState.districts.size()-1);    
        String name = reader.getString(row, col + 4);
        String party = reader.getString(row, col + 5);
        Float votePercent = reader.getFloat(row, col + 7) * 100;
        Candidate newCandidate = new Candidate(name, party);   
        currentDistrict.candidates.put(newCandidate, votePercent);
        reader.nextRow();
        row = row + 1;
      }

        
    } else {
     reader.nextRow();
     row = row + 1;
    }
  }
  
  for(int i = 0; i < states.size(); i++) {
          for(int j = 0; j < states.get(i).districts.size(); j++) {
            states.get(i).districts.get(j).setUp();
            states.get(i).districts.get(j).getTop2();
         }
        }
  //  reader.firstCell();      
  /* String stateAbbreviation = reader.getString(row, col);
   print(stateAbbreviation);
  //  String stateAbbreviation = reader.getString();    
  //  reader.nextCell();    
  //  String state = reader.getString();   
  String state = reader.getString(row, col + 1);
    State currentState;    
    if(states.size() == 0 || states.get(states.size()-1).name != state) {
       currentState = new State(state, stateAbbreviation);
       states.add(currentState);
    }
    else currentState = states.get(states.size()-1);   
   // reader.nextCell();        
   // String district = reader.getString();  
    String district = reader.getString(row, col + 2);
    District currentDistrict;    
    if(currentState.districts.size() == 0 || currentState.districts.get(currentState.districts.size()-1).number != district){
      currentDistrict = new District(currentState, district, map);
      currentState.districts.add(currentDistrict);
    }
    else currentDistrict = currentState.districts.get(currentState.districts.size()-1);    
   /* reader.nextCell();    
    String candidateID = reader.getString();    
    reader.nextCell();    
    String name = reader.getString();
    reader.nextCell();    
    String party = reader.getString();    
    reader.nextCell();
    reader.nextCell();
    Float votesPercent = reader.getFloat() * 100;  
    
    reader.nextCell();   
    
    String name = reader.getString(row, col + 4);
    String party = reader.getString(row, col + 5);
    Float votePercent = reader.getFloat(row, col + 6) * 100;
    Candidate newCandidate = new Candidate(name, party);   
    currentDistrict.candidates.put(newCandidate, votePercent);
    

    for(int i = 0; i < states.size(); i++) {
    for(int j = 0; j < states.get(i).districts.size(); j++) {
      states.get(i).districts.get(j).setUp();
      states.get(i).districts.get(j).getTop2().get(0);
      states.get(i).districts.get(j).getTop2().get(1);
   }
    }*/
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
  rect((int)cursor.x + 15,(int)cursor.y - 30, 100,30);
  fill(100);
  textSize(13);
  text(districtDesc, (int)cursor.x + 45, (int)cursor.y -22, 150,40);
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
       if(get((int)cursor.x,(int)cursor.y) == c) {
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
 //Kalinga-48
 //AvenirNextCondensed-Regular-48
 font = loadFont("KozGoPro-Regular-48.vlw");
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

void updateGestures() {
  if(drag) {
    if(firstPressed) {
     startX = (int)cursor.x;
     startY = (int)cursor.y;
     return;
    }
    x = origoX + ((int)cursor.x - startX);
    y = origoY + ((int)cursor.y - startY);
  }
  else {origoX = x; origoY = y;
  }
   if(select) { // keyCode == 32 // Space
   int textBox = width / 13;
   if((int)cursor.y > height - 20) {
     if((int)cursor.x > textBox && (int)cursor.x < textBox * 2) {
       setupData(2002);
       setupBalls();
       activeYear="2002";
     }
     else if((int)cursor.x > textBox * 3 && (int)cursor.x < textBox * 4) {
       setupData(2004);
       setupBalls();
       activeYear="2004";
     }
     else if((int)cursor.x > textBox * 5 && (int)cursor.x < textBox * 6) {
       setupData(2006);
       setupBalls();
       activeYear="2006";
     }
     else if((int)cursor.x > textBox * 7 && (int)cursor.x < textBox * 8) {
       setupData(2008);
       setupBalls();
       activeYear="2008";
     }
     else if((int)cursor.x > textBox * 9 && (int)cursor.x < textBox * 10) {
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
         String winningpercent = String.format("%.1f", activeDistrict.candidates.get(activeDistrict.getTop2().get(0)));
         String runningUppercent = String.format("%.1f", activeDistrict.candidates.get(activeDistrict.getTop2().get(1)));
         String nameQueryString = activeDistrict.getTop2().get(0).firstName + "_" + activeDistrict.getTop2().get(0).lastName;
         String link = "https://en.wikipedia.org/w/api.php?action=query&titles="+ nameQueryString +"&prop=pageimages&format=json&pithumbsize=200"; 

         String RUfirstName = activeDistrict.getTop2().get(1).firstName;
         String RUlastName = activeDistrict.getTop2().get(1).lastName;
         text(activeDistrict.getTop2().get(0).firstName + " " + activeDistrict.getTop2().get(0).lastName + " - " + activeDistrict.getTop2().get(0).party + 
              " " + winningpercent + "%" +
              "\n" + "\n"+ "\n" +  "\n" + "\n"+ "Runner Up:" + "\n" +
              RUfirstName + " " + RUlastName  + " - " + activeDistrict.getTop2().get(1).party + " " + runningUppercent + "%", width - 380, 400);
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
}
/*
void mousePressed() {
  if(firstPressed) {
   firstPressed = false;
   startX = (int)cursor.x;
   startY = (int)cursor.y; 
  }
}

void mouseDragged() {
  x = origoX + ((int)cursor.x - startX);
  y = origoY + ((int)cursor.y - startY);
}

void mouseReleased() {
  firstPressed = true;
  origoX = x;
  origoY = y;
}
*/
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
<<<<<<< HEAD
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
           textSize(16);
           fill(255,255,255);
           text(headline, width - 380, 70);
           String winningpercent = String.format("%.1f", activeDistrict.candidates.get(activeDistrict.getTop2().get(0)));
           String runningUppercent = String.format("%.1f", activeDistrict.candidates.get(activeDistrict.getTop2().get(1)));
           String nameQueryString = activeDistrict.getTop2().get(0).firstName + "_" + activeDistrict.getTop2().get(0).lastName;
           String link = "https://en.wikipedia.org/w/api.php?action=query&titles="+ nameQueryString +"&prop=pageimages&format=json&pithumbsize=200"; 

           String RUfirstName = activeDistrict.getTop2().get(1).firstName;
           String RUlastName = activeDistrict.getTop2().get(1).lastName;
           text(activeDistrict.getTop2().get(0).firstName + " " + activeDistrict.getTop2().get(0).lastName + " - " + activeDistrict.getTop2().get(0).party + 
                " " + winningpercent + "%" +
                "\n" + "\n"+ "\n" +  "\n" + "\n"+ "Runner Up:" + "\n" +
                RUfirstName + " " + RUlastName  + " - " + activeDistrict.getTop2().get(1).party + " " + runningUppercent + "%", width - 380, 400);
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
=======
   if(keyCode == 65) { // A
>>>>>>> feature/tracker
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

