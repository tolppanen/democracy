class District {
  State state;
  String number;
  HashMap<Candidate, Integer> candidates_2012;
  District(State parentState, String districtNo){
    state = parentState;
    number = districtNo;
    candidates_2012 = new HashMap<Candidate, Integer>();
  }
  
}