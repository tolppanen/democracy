import de.bezier.data.*;

XlsReader reader;

PShape map;
Boolean locked;
int startX;
int startY;
int origoX = 0;
int origoY = 0;
int x;
int y;
float zoom = 1;
boolean firstPressed = true;

ArrayList<Candidate> candidates = new ArrayList<Candidate>();
ArrayList<State> states = new ArrayList<State>();
ArrayList<PShape> stateShapes = new ArrayList<PShape>();

void setup() {
  size(1200,680);
  
  reader = new XlsReader( this, "data/formatted_data_2012.xls");
  reader.firstRow();
  
  map = loadShape("data/us_congressional_districts.svg");
  map.scale(0.4);
  
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
    
/*    for(int i = 0; i < states.size(); i++) {
      State accessState = states.get(i);
      for(int k = 0; k < accessState.districts.size() - 1; k++){
      District currentDistrict = accessState.districts.get(k);
      println(accessState.name + " district No. " + currentDistrict.number + " results: " + currentDistrict.candidates_2012);
      }
    } */
    
    
    for(int i = 0; i < states.size(); i++) {
    int size = states.get(i).districts.size();
    if(states.get(i).abbreviation.equals("CT")) {
      size = 5;
    }
    for(int j = 0; j < size; j++) {
      String stateCode;
      if(states.get(i).districts.get(j).number.equals("S") == false) {
        if(size == 1 || (size == 2 && states.get(i).districts.get(1).number.equals("S") == true)) {
          stateCode = states.get(i).abbreviation + "_" + "At-Large";
        }
        else {
          stateCode = states.get(i).abbreviation + "_" + (j + 1);
        }
      if(map.getChild(stateCode) != null) {
      PShape district = map.getChild(stateCode);
      stateShapes.add(district);   
      }
    }    
   }
  }
    
    
  }
  
  void draw() {
  background(0);
  shape(map, x, y);
  for(int i= 0; i < stateShapes.size(); i++) {
    stateShapes.get(i).disableStyle();
    fill(102, 0, 0);
    shape(stateShapes.get(i));
  }
  fill(255,255,255);
  ellipse(mouseX, mouseY, 20, 20);
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
   if(key == CONTROL) {
    zoom += 0.1;
    
   } 
  
}
  
  
  
  