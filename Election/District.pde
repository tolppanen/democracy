class District {
  State state;
  String number;
  HashMap<Candidate, Integer> candidates_2012;
  PShape district;
  PShape country;
  String stateCode;
  color stateColor;
  
  District(State parentState, String districtNo, PShape map){
    state = parentState;
    number = districtNo;
    candidates_2012 = new HashMap<Candidate, Integer>();
    country = map;
    stateColor = color(102, 0, 0);
  }
  
  color colorDistrict() {
   String party = getWinner(2012).getParty();
   if(party == "Rebublican") {
     stateColor = color(102, 0, 0);
   } else {
     stateColor = color(0, 0, 102);
   }
   return stateColor;
  }
  
   Candidate getWinner(int year) {
    Candidate currentWinner;
    int maxValue = 0;
    for(Candidate candidate : candidates_2012.keySet()) {
     if(this.candidates_2012.get(candidate) > maxValue) {
       currentWinner = candidate;
       print(currentWinner);
       maxValue = this.candidates_2012.get(candidate);
     }
     else currentWinner = new Candidate("whole", "thing", "sucks");
    }
    return currentWinner;
  }
}
