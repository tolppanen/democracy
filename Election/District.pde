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
   setDistrictColor();
  }
    
   Candidate getWinner(int year) {
    Candidate winner = new Candidate("b, v", "R", "s");
    int index = 0;
    for(Candidate candidate : candidates.keySet()) {
      if(index == 0) {
        winner = candidate;
      }
      index += 1;
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
  
  void setDistrictColor() {
    Candidate winner = this.getWinner(2012);
    Candidate runnerUp = this.getRunnerUp(2012);
    float difference = 0.50000;
    if(this.getWinner(2012) != null && this.getRunnerUp(2012).id != "s") difference = float(this.candidates.get(winner)) / (float(this.candidates.get(winner)) + float(this.candidates.get(runnerUp)));
    else difference = 1.0;
    if(this.getWinner(2012).party == "Republican") {
      if(difference > 0.75) districtColor = color(249, 72, 72);
      else if(difference > 0.55) districtColor = color(252, 153, 144);
      else districtColor = color(255,226,215);
    }
    else {
      if(difference > 0.75) districtColor = color(39, 103, 183);
      else if(difference > 0.55) districtColor = color(75, 149, 214);
      else districtColor = color(178, 216, 236);
    }
    
  }
  
}