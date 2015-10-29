class District {
  State state;
  String number;
  HashMap<Candidate, Integer> candidates;
  PShape district;
  PShape country;
  String stateCode;
  color districtColor;
  
  
  District(State parentState, String districtNo, PShape map){
    state = parentState;
    number = districtNo;
    candidates = new HashMap<Candidate, Integer>();
    country = map;
    districtColor = color(0, 0, 0);
    
  }
  
  void setUp() {
   if(number.equals("S") == false) {
     if(number.equals("00") == true) {
       stateCode = state.abbreviation + "_" + "At-Large";
     } else if(number.charAt(0) == '0') {
         stateCode = state.abbreviation + "_" + number.substring(1);
       } else {
         stateCode = state.abbreviation + "_" + number;
       }     
     district = country.getChild(stateCode);
   }
  }
    
   Candidate getWinner(int year) {
    int maxValue = 0;
    Candidate winner = new Candidate("a, a","R","a");
    for(Candidate candidate : candidates.keySet()) {
     if(this.candidates.get(candidate) >= maxValue) {
       Candidate currentWinner = candidate;    
       if(currentWinner.party.equals("Republican")) {
        districtColor = color(123, 10, 2); 
       } else {
        districtColor = color(27, 40, 65); 
       }
       winner = candidate;
       maxValue = this.candidates.get(candidate);
     } 
    }
    return winner;
  }
  
  Candidate getRunnerUp(int year) {
    Candidate RunnerUp = new Candidate("b, v", "R", "s");
    int index = 0;
    for(Candidate candidate : candidates.keySet()) {
      if(index == 1) {
        RunnerUp = candidate;
      }
      index += 1;
    }
    return RunnerUp;
  }
}