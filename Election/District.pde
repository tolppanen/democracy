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
  void colorDistrict() {    
    stateCode = state.abbreviation + "_" + number.substring(1);
    district = country.getChild(stateCode);
    fill(stateColor);
    shape(district);
  }
  
}
