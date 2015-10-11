import de.bezier.data.*;

XlsReader reader;

ArrayList<Candidate> candidates = new ArrayList<Candidate>();
ArrayList<State> states = new ArrayList<State>();

void setup() {
  size(600,400);
  
  reader = new XlsReader( this, "data/formatted_data_2012.xls");
  reader.firstRow();
  
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
      currentDistrict = new District(currentState, district);
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
      State accessState = states.get(i);
      for(int k = 0; k < accessState.districts.size() - 1; k++){
      District currentDistrict = accessState.districts.get(k);
      println(accessState.name + " district No. " + currentDistrict.number + " results: " + currentDistrict.candidates_2012);
      }
    }
  }
  
  